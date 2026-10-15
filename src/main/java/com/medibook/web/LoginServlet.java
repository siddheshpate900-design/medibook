package com.medibook.web;

import java.io.IOException;
import java.sql.Connection;
import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.sql.SQLException;
import java.util.Map;
import java.util.concurrent.ConcurrentHashMap;
import java.util.concurrent.atomic.AtomicInteger;
import javax.servlet.ServletException;
import javax.servlet.annotation.WebServlet;
import javax.servlet.http.HttpServlet;
import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;
import com.medibook.model.Patient;
import com.medibook.util.DBUtil;
import com.medibook.util.PasswordUtil;
import com.medibook.util.Records;
import com.medibook.util.Validation;
import com.medibook.util.WebUtil;

/**
 * Sign In.
 *
 * After six wrong attempts from the same browser for the same email the
 * form waits two minutes, so the password cannot simply be hammered.
 */
@WebServlet(name = "LoginServlet", urlPatterns = {"/login"})
public class LoginServlet extends HttpServlet {

    private static final long serialVersionUID = 1L;
    private static final int MAX_ATTEMPTS = 6;
    private static final long LOCK_MILLIS = 2 * 60 * 1000L;

    private static final String SELECT_SQL =
            "SELECT patient_id, full_name, email, phone, password_hash, gender, dob, address, "
                    + "city, pincode, blood_group, allergies, created_at, last_login_at "
                    + "FROM patients WHERE email = ? OR phone = ?";

    private final Map<String, AtomicInteger> failedAttempts = new ConcurrentHashMap<String, AtomicInteger>();
    private final Map<String, Long> lockedUntil = new ConcurrentHashMap<String, Long>();

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        if (WebUtil.currentUser(request) != null) {
            WebUtil.redirect(request, response, "/dashboard");
            return;
        }
        request.setAttribute("redirectTarget", safeTarget(request.getParameter("redirect")));
        WebUtil.render(request, response, "login.jsp");
    }

    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        request.setCharacterEncoding("UTF-8");
        String login = Validation.trim(request.getParameter("login"));
        String password = request.getParameter("password");
        String target = safeTarget(request.getParameter("redirect"));
        String throttleKey = login.toLowerCase() + "|" + request.getRemoteAddr();

        Long blocked = lockedUntil.get(throttleKey);
        if (blocked != null) {
            if (blocked > System.currentTimeMillis()) {
                long secondsLeft = (blocked - System.currentTimeMillis()) / 1000 + 1;
                request.setAttribute("loginError", "Too many wrong attempts. Try again in "
                        + secondsLeft + " seconds.");
                request.setAttribute("valLogin", login);
                request.setAttribute("redirectTarget", target);
                WebUtil.render(request, response, "login.jsp");
                return;
            }
            lockedUntil.remove(throttleKey);
            failedAttempts.remove(throttleKey);
        }

        Connection connection = null;
        PreparedStatement ps = null;
        ResultSet rs = null;
        try {
            connection = DBUtil.getConnection();
            ps = connection.prepareStatement(SELECT_SQL);
            ps.setString(1, login.toLowerCase());
            ps.setString(2, login.replaceAll("[^0-9]", ""));
            rs = ps.executeQuery();

            Patient patient = null;
            if (rs.next()) {
                if (PasswordUtil.matches(password, rs.getString("password_hash"))) {
                    patient = Records.patient(rs);
                }
            }
            rs.close();
            ps.close();
            rs = null;
            ps = null;

            if (patient == null) {
                recordFailure(throttleKey);
                request.setAttribute("loginError",
                        "Email or password is incorrect. Check the caps lock key and try once more.");
                request.setAttribute("valLogin", login);
                request.setAttribute("redirectTarget", target);
                WebUtil.render(request, response, "login.jsp");
                return;
            }

            failedAttempts.remove(throttleKey);
            lockedUntil.remove(throttleKey);

            // a fresh session id for the logged in user (stops session fixation);
            // the attributes of the session, including any notice from Sign Up, stay
            request.getSession(true);
            try {
                request.changeSessionId();
            } catch (IllegalStateException ignored) {
                // container kept the same id, nothing else to do
            }
            request.getSession().setAttribute(WebUtil.SESSION_PATIENT, patient);

            ps = connection.prepareStatement(
                    "UPDATE patients SET last_login_at = NOW() WHERE patient_id = ?");
            ps.setInt(1, patient.getPatientId());
            ps.executeUpdate();
            DBUtil.close(ps);
            ps = null;

            WebUtil.flash(request, "ok", "Signed in as " + patient.getFullName() + ".");
            WebUtil.redirect(request, response, "/dashboard");
        } catch (SQLException e) {
            WebUtil.error(request, response, "Sign in failed", e.getMessage());
        } finally {
            DBUtil.close(rs, ps, connection);
        }
    }

    private void recordFailure(String key) {
        AtomicInteger counter = failedAttempts.get(key);
        if (counter == null) {
            counter = failedAttempts.putIfAbsent(key, new AtomicInteger(1));
            if (counter == null) {
                return;
            }
        }
        if (counter.incrementAndGet() >= MAX_ATTEMPTS) {
            lockedUntil.put(key, System.currentTimeMillis() + LOCK_MILLIS);
            failedAttempts.remove(key);
        }
        if (failedAttempts.size() > 5000) {
            failedAttempts.clear();
            lockedUntil.clear();
        }
    }

    /**
     * Only ever send the browser to a path of this own application, never to
     * an address typed by someone else in the URL.
     */
    static String safeTarget(String given) {
        if (given == null) {
            return null;
        }
        String value = given.trim();
        if (value.length() < 2 || value.charAt(0) != '/' || value.startsWith("//")
                || value.contains("://") || value.contains("\\")) {
            return null;
        }
        return value;
    }
}
