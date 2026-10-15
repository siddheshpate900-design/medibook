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
import com.medibook.model.Appointment;
import com.medibook.model.Patient;
import com.medibook.util.DBUtil;
import com.medibook.util.Records;
import com.medibook.util.WebUtil;

/**
 * Printable appointment slip. A patient can only open the slip of their own
 * appointment: the patient id from the session is part of the WHERE clause.
 */
@WebServlet(name = "SlipServlet", urlPatterns = {"/slip"})
public class SlipServlet extends HttpServlet {

    private static final long serialVersionUID = 1L;

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        Patient patient = (Patient) request.getSession().getAttribute(WebUtil.SESSION_PATIENT);
        int appointmentId;
        try {
            appointmentId = Integer.parseInt(request.getParameter("id"));
        } catch (RuntimeException e) {
            WebUtil.redirect(request, response, "/dashboard");
            return;
        }

        Connection connection = null;
        try {
            connection = DBUtil.getConnection();
            PreparedStatement ps = null;
            ResultSet rs = null;
            Appointment appointment = null;
            try {
                ps = connection.prepareStatement(
                        "SELECT a.appointment_id, a.patient_id, a.doctor_id, a.appointment_date, "
                                + "a.appointment_time, a.token_no, a.reason, a.status, doc.doctor_name, "
                                + "dep.department_name, doc.qualification, doc.room_no, doc.consultation_fee "
                                + "FROM appointments a "
                                + "JOIN doctors doc ON doc.doctor_id = a.doctor_id "
                                + "JOIN departments dep ON dep.department_id = doc.department_id "
                                + "WHERE a.appointment_id = ? AND a.patient_id = ?");
                ps.setInt(1, appointmentId);
                ps.setInt(2, patient.getPatientId());
                rs = ps.executeQuery();
                if (rs.next()) {
                    appointment = Records.appointment(rs);
                }
            } finally {
                DBUtil.close(rs, ps);
            }

            if (appointment == null) {
                WebUtil.flash(request, "err", "That slip is not available for this account.");
                WebUtil.redirect(request, response, "/dashboard");
                return;
            }

            request.setAttribute("appointment", appointment);
            request.setAttribute("patient", patient);
            request.setAttribute("fresh", "1".equals(request.getParameter("fresh")));
            WebUtil.render(request, response, "slip.jsp");
        } catch (SQLException e) {
            WebUtil.error(request, response, "Slip could not be printed", e.getMessage());
        } finally {
            DBUtil.close(connection);
        }
    }
}
