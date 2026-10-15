package com.medibook.web;

import java.io.IOException;
import java.sql.Connection;
import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.sql.SQLException;
import java.time.LocalDate;
import java.util.ArrayList;
import java.util.List;
import javax.servlet.ServletException;
import javax.servlet.annotation.WebServlet;
import javax.servlet.http.HttpServlet;
import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;
import com.medibook.model.Department;
import com.medibook.model.Doctor;
import com.medibook.util.DBUtil;
import com.medibook.util.Records;
import com.medibook.util.SlotUtil;
import com.medibook.util.WebUtil;

/**
 * Landing page. Reads the department list, the doctor list and the OPD board
 * for today straight from MySQL so that the public page never shows stale text.
 */
@WebServlet(name = "HomeServlet", urlPatterns = {"/home"})
public class HomeServlet extends HttpServlet {

    private static final long serialVersionUID = 1L;

    private static final String DEPARTMENTS_SQL =
            "SELECT dep.department_id, dep.department_name, dep.description, "
                    + "COUNT(doc.doctor_id) AS doctorCount, "
                    + "MIN(doc.consultation_fee) AS minFee, "
                    + "MAX(doc.consultation_fee) AS maxFee "
                    + "FROM departments dep "
                    + "LEFT JOIN doctors doc ON doc.department_id = dep.department_id "
                    + "GROUP BY dep.department_id, dep.department_name, dep.description "
                    + "ORDER BY dep.department_name";

    private static final String DOCTORS_SQL =
            "SELECT doc.doctor_id, doc.doctor_name, doc.department_id, dep.department_name, "
                    + "doc.qualification, doc.experience_years, doc.consultation_fee, doc.room_no, "
                    + "doc.available_days, doc.start_time, doc.end_time, doc.slot_minutes "
                    + "FROM doctors doc JOIN departments dep ON dep.department_id = doc.department_id "
                    + "ORDER BY dep.department_name, doc.doctor_name";

    /** Same list, but only the doctors who have OPD on the given day name. */
    private static final String TODAY_SQL =
            "SELECT doc.doctor_id, doc.doctor_name, doc.department_id, dep.department_name, "
                    + "doc.qualification, doc.experience_years, doc.consultation_fee, doc.room_no, "
                    + "doc.available_days, doc.start_time, doc.end_time, doc.slot_minutes "
                    + "FROM doctors doc JOIN departments dep ON dep.department_id = doc.department_id "
                    + "WHERE FIND_IN_SET(?, doc.available_days) > 0 "
                    + "ORDER BY doc.start_time, doc.doctor_name";

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        Connection connection = null;
        try {
            connection = DBUtil.getConnection();
            LocalDate today = LocalDate.now();

            request.setAttribute("departments", departments(connection));
            request.setAttribute("doctors", doctors(connection, DOCTORS_SQL, null));
            request.setAttribute("todayDoctors", todayBoard(connection, today));
            request.setAttribute("todayDate", java.sql.Date.valueOf(today));
            request.setAttribute("todayLabel", today.toString());
            WebUtil.render(request, response, "home.jsp");
        } catch (SQLException e) {
            WebUtil.error(request, response, "Database not reachable", e.getMessage());
        } finally {
            DBUtil.close(connection);
        }
    }

    private List<Department> departments(Connection connection) throws SQLException {
        List<Department> list = new ArrayList<Department>();
        PreparedStatement ps = null;
        ResultSet rs = null;
        try {
            ps = connection.prepareStatement(DEPARTMENTS_SQL);
            rs = ps.executeQuery();
            while (rs.next()) {
                list.add(Records.department(rs));
            }
        } finally {
            DBUtil.close(rs, ps);
        }
        return list;
    }

    private List<Doctor> doctors(Connection connection, String sql, String dayName) throws SQLException {
        List<Doctor> list = new ArrayList<Doctor>();
        PreparedStatement ps = null;
        ResultSet rs = null;
        try {
            ps = connection.prepareStatement(sql);
            if (dayName != null) {
                ps.setString(1, dayName);
            }
            rs = ps.executeQuery();
            while (rs.next()) {
                list.add(Records.doctor(rs));
            }
        } finally {
            DBUtil.close(rs, ps);
        }
        return list;
    }

    /**
     * Doctors on duty today together with the number of slots still open,
     * counted from the live appointments table.
     */
    private List<Doctor> todayBoard(Connection connection, LocalDate today) throws SQLException {
        List<Doctor> onDuty = doctors(connection, TODAY_SQL, SlotUtil.dayName(today));
        PreparedStatement ps = null;
        for (Doctor doctor : onDuty) {
            List<java.time.LocalTime> booked = new ArrayList<java.time.LocalTime>();
            try {
                ps = connection.prepareStatement(
                        "SELECT appointment_time FROM appointments "
                                + "WHERE doctor_id = ? AND appointment_date = ? AND status = 'Booked'");
                ps.setInt(1, doctor.getDoctorId());
                ps.setDate(2, java.sql.Date.valueOf(today));
                ResultSet rs = ps.executeQuery();
                while (rs.next()) {
                    booked.add(rs.getTime(1).toLocalTime());
                }
                rs.close();
            } finally {
                DBUtil.close(ps);
                ps = null;
            }
            doctor.setOpenSlotsToday(SlotUtil.freeSlots(doctor, today, booked).size());
        }
        return onDuty;
    }
}
