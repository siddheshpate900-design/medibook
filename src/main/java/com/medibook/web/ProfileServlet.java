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
import com.medibook.model.Patient;
import com.medibook.util.DBUtil;
import com.medibook.util.PasswordUtil;
import com.medibook.util.Records;
import com.medibook.util.Validation;
import com.medibook.util.WebUtil;

/**
 * Profile: the patient can correct the details given during sign up and can
 * change the password. Two forms, separated by the hidden field "action".
 */
@WebServlet(name = "ProfileServlet", urlPatterns = {"/profile"})
public class ProfileServlet extends HttpServlet {

    private static final long serialVersionUID = 1L;

    private static final String SELECT_SQL =
            "SELECT patient_id, full_name, email, phone, gender, dob, address, city, pincode, "
                    + "blood_group, allergies, created_at, last_login_at FROM patients WHERE patient_id = ?";

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        Patient sessionPatient = (Patient) request.getSession().getAttribute(WebUtil.SESSION_PATIENT);
        Connection connection = null;
        try {
            connection = DBUtil.getConnection();
            Patient patient = reload(connection, sessionPatient.getPatientId());
            if (patient == null) {
                request.getSession().invalidate();
                WebUtil.redirect(request, response, "/login");
                return;
            }
            request.setAttribute("patient", patient);
            request.setAttribute("age", ageInYears(patient));
            WebUtil.render(request, response, "profile.jsp");
        } catch (SQLException e) {
            WebUtil.error(request, response, "Profile could not load", e.getMessage());
        } finally {
            DBUtil.close(connection);
        }
    }

    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        request.setCharacterEncoding("UTF-8");
        Patient sessionPatient = (Patient) request.getSession().getAttribute(WebUtil.SESSION_PATIENT);
        int patientId = sessionPatient.getPatientId();
        String action = request.getParameter("action");

        if ("password".equals(action)) {
            changePassword(request, response, patientId);
            return;
        }
        updateDetails(request, response, patientId, action);
    }

    private void updateDetails(HttpServletRequest request, HttpServletResponse response,
                               int patientId, String action) throws IOException, ServletException {
        String fullName = Validation.trim(request.getParameter("fullName"));
        String email = Validation.trim(request.getParameter("email")).toLowerCase();
        String phone = Validation.trim(request.getParameter("phone"));
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
        if (gender == null || !gender.matches("Male|Female|Other")) {
            errors.put("gender", "Please choose one.");
        }
        if (bloodGroup != null && !bloodGroup.trim().isEmpty()
                && !bloodGroup.matches("A\\+|A-|B\\+|B-|O\\+|O-|AB\\+|AB-")) {
            errors.put("bloodGroup", "Choose one of the listed groups.");
        }
        if (dobRaw != null && !dobRaw.trim().isEmpty()) {
            Validation.date(errors, dobRaw, false, 0, "dob");
        }
        Validation.optionalText(errors, address, 200, "address");
        Validation.optionalText(errors, city, 60, "city");
        Validation.pincode(errors, pincode);

        LocalDate dob = null;
        if (dobRaw != null && !dobRaw.trim().isEmpty() && !errors.containsKey("dob")) {
            dob = LocalDate.parse(dobRaw.trim());
        }

        Connection connection = null;
        try {
            connection = DBUtil.getConnection();
            if (!errors.isEmpty()) {
                request.setAttribute("errors", errors);
                request.setAttribute("patient", filled(fullName, email, phone, gender,
                        dobRaw, address, city, pincode, bloodGroup, allergies, patientId));
                request.setAttribute("age", dob == null ? 0 : java.time.Period.between(dob, LocalDate.now()).getYears());
                WebUtil.render(request, response, "profile.jsp");
                return;
            }

            PreparedStatement ps = null;
            try {
                ps = connection.prepareStatement(
                        "UPDATE patients SET full_name = ?, email = ?, phone = ?, gender = ?, dob = ?, "
                                + "address = ?, city = ?, pincode = ?, blood_group = ?, allergies = ? "
                                + "WHERE patient_id = ?");
                ps.setString(1, fullName);
                ps.setString(2, email);
                ps.setString(3, phone.replaceAll("[^0-9]", ""));
                ps.setString(4, gender);
                ps.setDate(5, dob == null ? null : Date.valueOf(dob));
                ps.setString(6, emptyToNull(address));
                ps.setString(7, emptyToNull(city));
                ps.setString(8, emptyToNull(pincode));
                ps.setString(9, emptyToNull(bloodGroup));
                ps.setString(10, emptyToNull(allergies));
                ps.setInt(11, patientId);
                ps.executeUpdate();
            } finally {
                DBUtil.close(ps);
            }

            Patient fresh = reload(connection, patientId);
            if (fresh != null) {
                request.getSession().setAttribute(WebUtil.SESSION_PATIENT, fresh);
            }
            WebUtil.flash(request, "ok", "Profile saved.");
            WebUtil.redirect(request, response, "/profile");
        } catch (SQLException e) {
            if (e.getMessage() != null && e.getMessage().toLowerCase().contains("duplicate")) {
                WebUtil.flash(request, "err",
                        "That email or mobile number already belongs to another account.");
                WebUtil.redirect(request, response, "/profile");
                return;
            }
            WebUtil.error(request, response, "Profile could not be saved", e.getMessage());
        } finally {
            DBUtil.close(connection);
        }
    }

    private void changePassword(HttpServletRequest request, HttpServletResponse response,
                                 int patientId) throws IOException, ServletException {
        String current = request.getParameter("currentPassword");
        String next = request.getParameter("newPassword");
        String confirm = request.getParameter("confirmPassword");

        Map<String, String> errors = Validation.newErrors();
        Validation.password(errors, next);
        Validation.confirmPassword(errors, next, confirm);

        Connection connection = null;
        try {
            connection = DBUtil.getConnection();
            String stored = null;
            PreparedStatement ps = null;
            ResultSet rs = null;
            try {
                ps = connection.prepareStatement("SELECT password_hash FROM patients WHERE patient_id = ?");
                ps.setInt(1, patientId);
                rs = ps.executeQuery();
                if (rs.next()) {
                    stored = rs.getString(1);
                }
            } finally {
                DBUtil.close(rs, ps);
            }

            if (current == null || !PasswordUtil.matches(current, stored)) {
                errors.put("currentPassword", "That is not your current password.");
            }
            if (current != null && current.equals(next) && !errors.containsKey("newPassword")) {
                errors.put("newPassword", "The new password should be different from the old one.");
            }

            if (!errors.isEmpty()) {
                request.setAttribute("errors", errors);
                request.setAttribute("passwordTab", "open");
                Patient patient = reload(connection, patientId);
                request.setAttribute("patient", patient);
                request.setAttribute("age", ageInYears(patient));
                WebUtil.render(request, response, "profile.jsp");
                return;
            }

            PreparedStatement update = null;
            try {
                update = connection.prepareStatement(
                        "UPDATE patients SET password_hash = ? WHERE patient_id = ?");
                update.setString(1, PasswordUtil.hash(next));
                update.setInt(2, patientId);
                update.executeUpdate();
            } finally {
                DBUtil.close(update);
            }
            WebUtil.flash(request, "ok", "Password changed. Use it the next time you sign in.");
            WebUtil.redirect(request, response, "/profile");
        } catch (SQLException e) {
            WebUtil.error(request, response, "Password could not be changed", e.getMessage());
        } finally {
            DBUtil.close(connection);
        }
    }

    private Patient reload(Connection connection, int patientId) throws SQLException {
        PreparedStatement ps = null;
        ResultSet rs = null;
        try {
            ps = connection.prepareStatement(SELECT_SQL);
            ps.setInt(1, patientId);
            rs = ps.executeQuery();
            if (rs.next()) {
                Patient patient = Records.patient(rs);
                patient.setAge(ageInYears(patient));
                return patient;
            }
            return null;
        } finally {
            DBUtil.close(rs, ps);
        }
    }

    private Patient filled(String fullName, String email, String phone, String gender, String dob,
                           String address, String city, String pincode, String bloodGroup,
                           String allergies, int patientId) {
        Patient p = new Patient();
        p.setPatientId(patientId);
        p.setFullName(fullName);
        p.setEmail(email);
        p.setPhone(phone);
        p.setGender(gender);
        p.setDob(dob == null || dob.trim().isEmpty() ? null : Date.valueOf(dob.trim()));
        p.setAddress(address);
        p.setCity(city);
        p.setPincode(pincode);
        p.setBloodGroup(bloodGroup);
        p.setAllergies(allergies);
        return p;
    }

    private int ageInYears(Patient patient) {
        if (patient == null || patient.getDob() == null) {
            return 0;
        }
        return java.time.Period.between(patient.getDob().toLocalDate(), LocalDate.now()).getYears();
    }

    private static String emptyToNull(String value) {
        return value == null || value.trim().isEmpty() ? null : value.trim();
    }
}
