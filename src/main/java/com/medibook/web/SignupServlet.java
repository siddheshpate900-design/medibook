package com.medibook.web;

import java.io.IOException;
import java.sql.Connection;
import java.sql.Date;
import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.sql.SQLException;
import java.time.LocalDate;
import java.util.Map;
import javax.servlet.ServletException;
import javax.servlet.annotation.WebServlet;
import javax.servlet.http.HttpServlet;
import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;
import com.medibook.util.DBUtil;
import com.medibook.util.PasswordUtil;
import com.medibook.util.Validation;
import com.medibook.util.WebUtil;

/**
 * Sign Up. Checks the form, refuses a repeat email or mobile, hashes the
 * password and inserts one row into the patients table.
 */
@WebServlet(name = "SignupServlet", urlPatterns = {"/signup"})
public class SignupServlet extends HttpServlet {

    private static final long serialVersionUID = 1L;

    private static final String INSERT_SQL =
            "INSERT INTO patients (full_name, email, phone, password_hash, gender, dob, "
                    + "address, city, pincode, blood_group, allergies) "
                    + "VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?)";

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        if (WebUtil.currentUser(request) != null) {
            WebUtil.redirect(request, response, "/dashboard");
            return;
        }
        WebUtil.render(request, response, "signup.jsp");
    }

    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        request.setCharacterEncoding("UTF-8");

        String fullName = Validation.trim(request.getParameter("fullName"));
        String email = Validation.trim(request.getParameter("email")).toLowerCase();
        String phone = Validation.trim(request.getParameter("phone"));
        String password = request.getParameter("password");
        String confirm = request.getParameter("confirmPassword");
        String gender = request.getParameter("gender");
        String dobRaw = request.getParameter("dob");
        String address = Validation.trim(request.getParameter("address"));
        String city = Validation.trim(request.getParameter("city"));
        String pincode = Validation.trim(request.getParameter("pincode"));
        String bloodGroup = request.getParameter("bloodGroup");
        String allergies = Validation.trim(request.getParameter("allergies"));

        Map<String, String> errors = Validation.newErrors();
        Validation.fullName(errors, fullName);
        Validation.email(errors, email);
        Validation.phone(errors, phone);
        Validation.password(errors, password);
        Validation.confirmPassword(errors, password, confirm);
        if (gender == null || !gender.matches("Male|Female|Other")) {
            errors.put("gender", "Please choose one.");
        }
        LocalDate dob = Validation.date(errors, dobRaw, true, 0, "dob");
        Validation.optionalText(errors, address, 200, "address");
        Validation.optionalText(errors, city, 60, "city");
        Validation.optionalText(errors, allergies, 255, "allergies");
        Validation.pincode(errors, pincode);
        if (request.getParameter("consent") == null) {
            errors.put("consent", "Please read and accept the privacy policy.");
        }

        if (!errors.isEmpty()) {
            keepValues(request, fullName, email, phone, dobRaw, address, city, pincode, allergies, gender, bloodGroup);
            request.setAttribute("errors", errors);
            WebUtil.render(request, response, "signup.jsp");
            return;
        }

        Connection connection = null;
        PreparedStatement check = null;
        ResultSet rs = null;
        PreparedStatement insert = null;
        try {
            connection = DBUtil.getConnection();

            // email and mobile are UNIQUE in the table; check first for a readable message
            check = connection.prepareStatement(
                    "SELECT email, phone FROM patients WHERE email = ? OR phone = ?");
            check.setString(1, email);
            check.setString(2, phone.replaceAll("[^0-9]", ""));
            String digits = phone.replaceAll("[^0-9]", "");
            rs = check.executeQuery();
            while (rs.next()) {
                if (email.equalsIgnoreCase(nvl(rs.getString("email")))) {
                    errors.put("email", "An account already uses this email. Please sign in instead.");
                }
                if (digits.equals(nvl(rs.getString("phone")))) {
                    errors.put("phone", "This mobile number is already registered.");
                }
            }
            rs.close();
            check.close();
            rs = null;
            check = null;

            if (!errors.isEmpty()) {
                keepValues(request, fullName, email, phone, dobRaw, address, city, pincode, allergies, gender, bloodGroup);
                request.setAttribute("errors", errors);
                WebUtil.render(request, response, "signup.jsp");
                return;
            }

            insert = connection.prepareStatement(INSERT_SQL);
            insert.setString(1, fullName);
            insert.setString(2, email);
            insert.setString(3, phone.replaceAll("[^0-9]", ""));
            insert.setString(4, PasswordUtil.hash(password));
            insert.setString(5, gender);
            insert.setDate(6, dob == null ? null : Date.valueOf(dob));
            insert.setString(7, emptyToNull(address));
            insert.setString(8, emptyToNull(city));
            insert.setString(9, emptyToNull(pincode));
            insert.setString(10, emptyToNull(bloodGroup));
            insert.setString(11, emptyToNull(allergies));
            insert.executeUpdate();

            WebUtil.flash(request, "ok",
                    "Account created for " + fullName + ". Please sign in with your email.");
            WebUtil.redirect(request, response, "/login");
        } catch (SQLException e) {
            if (isDuplicateKey(e)) {
                keepValues(request, fullName, email, phone, dobRaw, address, city, pincode, allergies, gender, bloodGroup);
                errors.clear();
                errors.put("email", "That email or mobile number was just taken. Try another one.");
                request.setAttribute("errors", errors);
                WebUtil.render(request, response, "signup.jsp");
                return;
            }
            WebUtil.error(request, response, "Sign up failed", e.getMessage());
        } finally {
            DBUtil.close(rs, check, insert, connection);
        }
    }

    private void keepValues(HttpServletRequest request, String fullName, String email, String phone,
                            String dob, String address, String city, String pincode, String allergies,
                            String gender, String bloodGroup) {
        request.setAttribute("valFullName", fullName);
        request.setAttribute("valEmail", email);
        request.setAttribute("valPhone", phone);
        request.setAttribute("valDob", dob);
        request.setAttribute("valAddress", address);
        request.setAttribute("valCity", city);
        request.setAttribute("valPincode", pincode);
        request.setAttribute("valAllergies", allergies);
        request.setAttribute("valGender", gender);
        request.setAttribute("valBloodGroup", bloodGroup);
    }

    private static boolean isDuplicateKey(SQLException e) {
        String message = e.getMessage() == null ? "" : e.getMessage().toLowerCase();
        return message.contains("duplicate") || e.getSQLState() != null && e.getSQLState().startsWith("23");
    }

    private static String nvl(String value) {
        return value == null ? "" : value;
    }

    private static String emptyToNull(String value) {
        return value == null || value.trim().isEmpty() ? null : value.trim();
    }
}
