package com.medibook.web;

import java.io.IOException;
import java.sql.Connection;
import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.sql.SQLException;
import java.time.LocalDate;
import java.util.ArrayList;
import java.util.HashMap;
import java.util.List;
import java.util.Map;
import javax.servlet.ServletException;
import javax.servlet.annotation.WebServlet;
import javax.servlet.http.HttpServlet;
import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;
import com.medibook.model.Appointment;
import com.medibook.model.Patient;
import com.medibook.util.DBUtil;
import com.medibook.util.Records;
import com.medibook.util.WebUtil;

/**
 * Patient dashboard.
 *
 * Every figure on this page is counted from this patient's own rows in the
 * appointments table. Nothing is hard coded, so the numbers move as soon as
 * a booking is made or cancelled.
 */
@WebServlet(name = "DashboardServlet", urlPatterns = {"/dashboard"})
public class DashboardServlet extends HttpServlet {

    private static final long serialVersionUID = 1L;

    private static final String APPOINTMENT_SELECT =
            "SELECT a.appointment_id, a.patient_id, a.doctor_id, a.appointment_date, a.appointment_time, "
                    + "a.token_no, a.reason, a.status, doc.doctor_name, dep.department_name, "
                    + "doc.qualification, doc.room_no, doc.consultation_fee "
                    + "FROM appointments a "
                    + "JOIN doctors doc ON doc.doctor_id = a.doctor_id "
                    + "JOIN departments dep ON dep.department_id = doc.department_id ";

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        Patient patient = (Patient) request.getSession().getAttribute(WebUtil.SESSION_PATIENT);
        Connection connection = null;
        try {
            connection = DBUtil.getConnection();

            // past bookings that nobody marked are recorded as completed visits
            PreparedStatement sweep = null;
            try {
                sweep = connection.prepareStatement(
                        "UPDATE appointments SET status = 'Completed', updated_at = NOW() "
                                + "WHERE patient_id = ? AND status = 'Booked' "
                                + "AND (appointment_date < CURDATE() "
                                + "     OR (appointment_date = CURDATE() AND appointment_time < CURTIME()))");
                sweep.setInt(1, patient.getPatientId());
                sweep.executeUpdate();
            } finally {
                DBUtil.close(sweep);
            }

            // read the account row again so a profile edit shows up at once
            PreparedStatement ps = null;
            ResultSet rs = null;
            try {
                ps = connection.prepareStatement(
                        "SELECT patient_id, full_name, email, phone, gender, dob, address, city, "
                                + "pincode, blood_group, allergies, created_at, last_login_at "
                                + "FROM patients WHERE patient_id = ?");
                ps.setInt(1, patient.getPatientId());
                rs = ps.executeQuery();
                if (rs.next()) {
                    Patient fresh = Records.patient(rs);
                    request.getSession().setAttribute(WebUtil.SESSION_PATIENT, fresh);
                    request.setAttribute("patient", fresh);
                } else {
                    request.getSession().invalidate();
                    WebUtil.redirect(request, response, "/login");
                    return;
                }
            } finally {
                DBUtil.close(rs, ps);
            }

            LocalDate today = LocalDate.now();

            List<Appointment> upcoming = new ArrayList<Appointment>();
            List<Appointment> history = new ArrayList<Appointment>();
            PreparedStatement upcomingStmt = null;
            PreparedStatement historyStmt = null;
            ResultSet upcomingRs = null;
            ResultSet historyRs = null;
            try {
                upcomingStmt = connection.prepareStatement(APPOINTMENT_SELECT
                        + "WHERE a.patient_id = ? AND a.status = 'Booked' "
                        + "AND (a.appointment_date > CURDATE() OR (a.appointment_date = CURDATE() "
                        + "     AND a.appointment_time >= CURTIME())) "
                        + "ORDER BY a.appointment_date, a.appointment_time LIMIT 20");
                upcomingStmt.setInt(1, patient.getPatientId());
                upcomingRs = upcomingStmt.executeQuery();
                while (upcomingRs.next()) {
                    Appointment a = Records.appointment(upcomingRs);
                    a.setCancellable(true);
                    upcoming.add(a);
                }

                historyStmt = connection.prepareStatement(APPOINTMENT_SELECT
                        + "WHERE a.patient_id = ? AND (a.status <> 'Booked' OR a.appointment_date < CURDATE()) "
                        + "ORDER BY a.appointment_date DESC, a.appointment_time DESC LIMIT 20");
                historyStmt.setInt(1, patient.getPatientId());
                historyRs = historyStmt.executeQuery();
                while (historyRs.next()) {
                    history.add(Records.appointment(historyRs));
                }
            } finally {
                DBUtil.close(upcomingRs, historyRs, upcomingStmt, historyStmt);
            }

            Map<String, Integer> counts = new HashMap<String, Integer>();
            int visitCount = 0;
            int doctorCount = 0;
            PreparedStatement stats = null;
            ResultSet statsRs = null;
            try {
                stats = connection.prepareStatement(
                        "SELECT status, COUNT(*) AS total FROM appointments "
                                + "WHERE patient_id = ? GROUP BY status");
                stats.setInt(1, patient.getPatientId());
                statsRs = stats.executeQuery();
                while (statsRs.next()) {
                    counts.put(statsRs.getString("status"), statsRs.getInt("total"));
                }
                statsRs.close();
                statsRs = null;

                stats.close();
                stats = connection.prepareStatement(
                        "SELECT COUNT(*) AS visits, COUNT(DISTINCT doctor_id) AS doctors "
                                + "FROM appointments WHERE patient_id = ? AND status <> 'Cancelled'");
                stats.setInt(1, patient.getPatientId());
                statsRs = stats.executeQuery();
                if (statsRs.next()) {
                    visitCount = statsRs.getInt("visits");
                    doctorCount = statsRs.getInt("doctors");
                }
            } finally {
                DBUtil.close(statsRs, stats);
            }

            request.setAttribute("upcoming", upcoming);
            request.setAttribute("next", upcoming.isEmpty() ? null : upcoming.get(0));
            request.setAttribute("history", history);
            request.setAttribute("countBooked", intOf(counts, "Booked"));
            request.setAttribute("countCompleted", intOf(counts, "Completed"));
            request.setAttribute("countCancelled", intOf(counts, "Cancelled"));
            request.setAttribute("visitCount", visitCount);
            request.setAttribute("doctorCount", doctorCount);
            request.setAttribute("todayLabel", today.toString());

            Patient shown = (Patient) request.getSession().getAttribute(WebUtil.SESSION_PATIENT);
            List<String> missing = new ArrayList<String>();
            if (shown.getDob() == null) {
                missing.add("date of birth");
            }
            if (isBlank(shown.getAddress())) {
                missing.add("address");
            }
            if (isBlank(shown.getBloodGroup())) {
                missing.add("blood group");
            }
            request.setAttribute("missingFields", missing);

            WebUtil.render(request, response, "dashboard.jsp");
        } catch (SQLException e) {
            WebUtil.error(request, response, "Dashboard could not load", e.getMessage());
        } finally {
            DBUtil.close(connection);
        }
    }

    private static int intOf(Map<String, Integer> map, String key) {
        Integer value = map.get(key);
        return value == null ? 0 : value.intValue();
    }

    private static boolean isBlank(String value) {
        return value == null || value.trim().isEmpty();
    }
}
