package com.medibook.web;

import java.io.IOException;
import java.sql.Connection;
import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.sql.SQLException;
import javax.servlet.ServletException;
import javax.servlet.annotation.WebServlet;
import javax.servlet.http.HttpServlet;
import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;
import com.medibook.model.Patient;
import com.medibook.util.DBUtil;
import com.medibook.util.WebUtil;

/**
 * Cancelling a booking. Only reachable by POST from the dashboard, only for an
 * appointment that belongs to the signed in patient and is still in the future.
 */
@WebServlet(name = "CancelAppointmentServlet", urlPatterns = {"/cancel"})
public class CancelAppointmentServlet extends HttpServlet {

    private static final long serialVersionUID = 1L;

    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        Patient patient = (Patient) request.getSession().getAttribute(WebUtil.SESSION_PATIENT);
        int appointmentId;
        try {
            appointmentId = Integer.parseInt(request.getParameter("appointmentId"));
        } catch (RuntimeException e) {
            WebUtil.flash(request, "err", "That booking could not be found.");
            WebUtil.redirect(request, response, "/dashboard");
            return;
        }

        Connection connection = null;
        try {
            connection = DBUtil.getConnection();

            PreparedStatement find = null;
            ResultSet rs = null;
            String status = null;
            boolean inFuture = false;
            try {
                find = connection.prepareStatement(
                        "SELECT a.status FROM appointments a "
                                + "WHERE a.appointment_id = ? AND a.patient_id = ? "
                                + "AND (a.appointment_date > CURDATE() OR (a.appointment_date = CURDATE() "
                                + "AND a.appointment_time >= CURTIME()))");
                find.setInt(1, appointmentId);
                find.setInt(2, patient.getPatientId());
                rs = find.executeQuery();
                if (rs.next()) {
                    status = rs.getString("status");
                    inFuture = true;
                }
            } finally {
                DBUtil.close(rs, find);
            }

            if (!inFuture || !"Booked".equals(status)) {
                WebUtil.flash(request, "err",
                        "This appointment cannot be cancelled here. Please call the clinic desk.");
                WebUtil.redirect(request, response, "/dashboard");
                return;
            }

            PreparedStatement update = null;
            try {
                update = connection.prepareStatement(
                        "UPDATE appointments SET status = 'Cancelled', updated_at = NOW() "
                                + "WHERE appointment_id = ? AND patient_id = ? AND status = 'Booked'");
                update.setInt(1, appointmentId);
                update.setInt(2, patient.getPatientId());
                int rows = update.executeUpdate();
                if (rows == 1) {
                    WebUtil.flash(request, "ok", "Appointment cancelled. The time slot is open again.");
                } else {
                    WebUtil.flash(request, "err", "That appointment had already changed. Refresh and try again.");
                }
            } finally {
                DBUtil.close(update);
            }
        } catch (SQLException e) {
            WebUtil.error(request, response, "Cancellation failed", e.getMessage());
        } finally {
            DBUtil.close(connection);
        }
        WebUtil.redirect(request, response, "/dashboard");
    }
}
