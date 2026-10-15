package com.medibook.web;

import java.io.IOException;
import java.sql.Connection;
import java.sql.Date;
import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.sql.SQLException;
import java.sql.Time;
import java.sql.Timestamp;
import java.time.LocalDate;
import java.time.LocalTime;
import java.util.ArrayList;
import java.util.List;
import java.util.Map;
import javax.servlet.ServletException;
import javax.servlet.annotation.WebServlet;
import javax.servlet.http.HttpServlet;
import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;
import com.medibook.model.Department;
import com.medibook.model.Doctor;
import com.medibook.model.Patient;
import com.medibook.model.Slot;
import com.medibook.util.DBUtil;
import com.medibook.util.Records;
import com.medibook.util.SlotUtil;
import com.medibook.util.Validation;
import com.medibook.util.WebUtil;

/**
 * Book an appointment.
 *
 * The form walks through department, doctor, date and then shows only the
 * slots that are really free in the database. The insert runs inside a
 * transaction and re-checks the slot, so two patients cannot take one slot.
 */
@WebServlet(name = "BookingServlet", urlPatterns = {"/book"})
public class BookingServlet extends HttpServlet {

    private static final long serialVersionUID = 1L;

    private static final int BOOKING_WINDOW_DAYS = 60;

    private static final String DOCTOR_SELECT =
            "SELECT doc.doctor_id, doc.doctor_name, doc.department_id, dep.department_name, "
                    + "doc.qualification, doc.experience_years, doc.consultation_fee, doc.room_no, "
                    + "doc.available_days, doc.start_time, doc.end_time, doc.slot_minutes "
                    + "FROM doctors doc JOIN departments dep ON dep.department_id = doc.department_id ";

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        Patient patient = (Patient) request.getSession().getAttribute(WebUtil.SESSION_PATIENT);
        Connection connection = null;
        try {
            connection = DBUtil.getConnection();
            int departmentId = intParam(request, "department");
            int doctorId = intParam(request, "doctor");
            LocalDate date = parseDate(request.getParameter("date"));
            if (date == null) {
                date = LocalDate.now();
            }
            prepare(request, connection, patient, departmentId, doctorId, date);
            WebUtil.render(request, response, "book.jsp");
        } catch (SQLException e) {
            WebUtil.error(request, response, "Booking form could not load", e.getMessage());
        } finally {
            DBUtil.close(connection);
        }
    }

    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        request.setCharacterEncoding("UTF-8");
        Patient patient = (Patient) request.getSession().getAttribute(WebUtil.SESSION_PATIENT);

        int departmentId = intParam(request, "department");
        int doctorId = intParam(request, "doctor");
        LocalDate date = parseDate(request.getParameter("date"));
        String slotValue = Validation.trim(request.getParameter("slot"));
        String reason = Validation.trim(request.getParameter("reason"));

        Map<String, String> errors = Validation.newErrors();
        if (date == null) {
            errors.put("date", "Choose a date in the format YYYY-MM-DD.");
        }
        if (doctorId <= 0) {
            errors.put("doctor", "Choose a doctor first.");
        }
        if (slotValue.isEmpty()) {
            errors.put("slot", "Pick one of the open time slots.");
        }
        if (reason.length() < 5) {
            errors.put("reason", "Write the complaint in a few words (at least 5 characters).");
        } else if (reason.length() > 300) {
            errors.put("reason", "Keep the complaint under 300 characters.");
        }
        LocalTime slotTime = null;
        if (!slotValue.isEmpty()) {
            try {
                slotTime = LocalTime.parse(slotValue);
            } catch (RuntimeException e) {
                errors.put("slot", "That time was not recognised.");
            }
        }
        if (date != null && date.isBefore(LocalDate.now())) {
            errors.put("date", "You cannot book a date that has already passed.");
        } else if (date != null && date.isAfter(LocalDate.now().plusDays(BOOKING_WINDOW_DAYS))) {
            errors.put("date", "Appointments open only " + BOOKING_WINDOW_DAYS + " days ahead.");
        }

        Connection connection = null;
        try {
            connection = DBUtil.getConnection();

            Doctor doctor = null;
            if (doctorId > 0) {
                doctor = loadDoctor(connection, doctorId);
                if (doctor == null) {
                    errors.put("doctor", "That doctor is not in the list any more.");
                } else if (date != null && !SlotUtil.clinicOpensOn(doctor, date)) {
                    errors.put("date", doctor.getDoctorName() + " sits in OPD on "
                            + doctor.getAvailableDays() + " only.");
                }
            }

            if (errors.isEmpty() && doctor != null && slotTime != null) {
                List<LocalTime> taken = bookedTimes(connection, doctorId, date);
                List<LocalTime> free = SlotUtil.freeSlots(doctor, date, taken);
                if (!free.contains(slotTime)) {
                    errors.put("slot", "That slot is no longer open. Pick another one.");
                }
            }

            if (!errors.isEmpty()) {
                request.setAttribute("errors", errors);
                request.setAttribute("valReason", reason);
                prepare(request, connection, patient, departmentId, doctorId,
                        date == null ? LocalDate.now() : date);
                WebUtil.render(request, response, "book.jsp");
                return;
            }

            int appointmentId = insert(connection, patient, doctor, date, slotTime, reason);
            WebUtil.flash(request, "ok", "Appointment booked with " + doctor.getDoctorName()
                    + " on " + date + " at " + SlotUtil.label(slotTime) + ".");
            WebUtil.redirect(request, response, "/slip?id=" + appointmentId + "&fresh=1");
        } catch (SQLException e) {
            WebUtil.error(request, response, "Booking could not be saved", e.getMessage());
        } finally {
            DBUtil.close(connection);
        }
    }

    /** Loads the drop downs, the chosen doctor and the open slots for the date. */
    private void prepare(HttpServletRequest request, Connection connection, Patient patient,
                         int departmentId, int doctorId, LocalDate date) throws SQLException {
        List<Department> departments = new ArrayList<Department>();
        PreparedStatement ps = null;
        ResultSet rs = null;
        try {
            ps = connection.prepareStatement(
                    "SELECT department_id, department_name, description, 0 AS doctorCount, "
                            + "NULL AS minFee, NULL AS maxFee FROM departments ORDER BY department_name");
            rs = ps.executeQuery();
            while (rs.next()) {
                departments.add(Records.department(rs));
            }
        } finally {
            DBUtil.close(rs, ps);
        }

        List<Doctor> doctors = new ArrayList<Doctor>();
        try {
            if (departmentId > 0) {
                ps = connection.prepareStatement(DOCTOR_SELECT + "WHERE doc.department_id = ? "
                        + "ORDER BY doc.doctor_name");
                ps.setInt(1, departmentId);
            } else {
                ps = connection.prepareStatement(DOCTOR_SELECT + "ORDER BY dep.department_name, doc.doctor_name");
            }
            rs = ps.executeQuery();
            while (rs.next()) {
                doctors.add(Records.doctor(rs));
            }
        } finally {
            DBUtil.close(rs, ps);
        }

        Doctor chosen = null;
        for (Doctor doctor : doctors) {
            if (doctor.getDoctorId() == doctorId) {
                chosen = doctor;
                break;
            }
        }
        if (chosen == null && doctorId > 0) {
            chosen = loadDoctor(connection, doctorId);
        }

        List<Slot> slots = new ArrayList<Slot>();
        int takenCount = 0;
        if (chosen != null && date != null) {
            List<LocalTime> taken = bookedTimes(connection, chosen.getDoctorId(), date);
            takenCount = taken.size();
            for (LocalTime time : SlotUtil.freeSlots(chosen, date, taken)) {
                String period = time.getHour() < 12 ? "Morning" : "Afternoon";
                slots.add(new Slot(time.toString(), SlotUtil.label(time), period));
            }
        }

        request.setAttribute("departments", departments);
        request.setAttribute("doctors", doctors);
        Integer shownDepartment = departmentId > 0 ? Integer.valueOf(departmentId)
                : (chosen == null ? null : Integer.valueOf(chosen.getDepartmentId()));
        request.setAttribute("selectedDepartment", shownDepartment);
        request.setAttribute("doctor", chosen);
        request.setAttribute("selectedDoctorId", doctorId > 0 ? doctorId : null);
        request.setAttribute("dateText", date == null ? LocalDate.now().toString() : date.toString());
        request.setAttribute("dayName", date == null ? "" : fullDayName(date));
        request.setAttribute("slots", slots);
        request.setAttribute("takenCount", takenCount);
        request.setAttribute("windowDays", BOOKING_WINDOW_DAYS);
        request.setAttribute("minDate", LocalDate.now().toString());
        request.setAttribute("maxDate", LocalDate.now().plusDays(BOOKING_WINDOW_DAYS).toString());
        request.setAttribute("patient", patient);
    }

    private Doctor loadDoctor(Connection connection, int doctorId) throws SQLException {
        PreparedStatement ps = null;
        ResultSet rs = null;
        try {
            ps = connection.prepareStatement(DOCTOR_SELECT + "WHERE doc.doctor_id = ?");
            ps.setInt(1, doctorId);
            rs = ps.executeQuery();
            return rs.next() ? Records.doctor(rs) : null;
        } finally {
            DBUtil.close(rs, ps);
        }
    }

    private List<LocalTime> bookedTimes(Connection connection, int doctorId, LocalDate date)
            throws SQLException {
        List<LocalTime> times = new ArrayList<LocalTime>();
        if (date == null) {
            return times;
        }
        PreparedStatement ps = null;
        ResultSet rs = null;
        try {
            ps = connection.prepareStatement(
                    "SELECT appointment_time FROM appointments "
                            + "WHERE doctor_id = ? AND appointment_date = ? AND status = 'Booked'");
            ps.setInt(1, doctorId);
            ps.setDate(2, Date.valueOf(date));
            rs = ps.executeQuery();
            while (rs.next()) {
                times.add(rs.getTime(1).toLocalTime());
            }
        } finally {
            DBUtil.close(rs, ps);
        }
        return times;
    }

    /**
     * One transaction: lock the slot, work out the token, insert the booking.
     * A rollback is done if anything fails so a half saved row is never left.
     */
    private int insert(Connection connection, Patient patient, Doctor doctor, LocalDate date,
                       LocalTime time, String reason) throws SQLException {
        boolean autoCommit = connection.getAutoCommit();
        PreparedStatement lock = null;
        PreparedStatement token = null;
        PreparedStatement insert = null;
        ResultSet rs = null;
        try {
            connection.setAutoCommit(false);

            lock = connection.prepareStatement(
                    "SELECT appointment_id FROM appointments "
                            + "WHERE doctor_id = ? AND appointment_date = ? AND appointment_time = ? "
                            + "AND status = 'Booked' FOR UPDATE");
            lock.setInt(1, doctor.getDoctorId());
            lock.setDate(2, Date.valueOf(date));
            lock.setTime(3, Time.valueOf(time));
            rs = lock.executeQuery();
            if (rs.next()) {
                connection.rollback();
                throw new SQLException("That slot was taken a moment ago. Please choose another time.");
            }
            rs.close();
            rs = null;

            token = connection.prepareStatement(
                    "SELECT COALESCE(MAX(token_no), 0) + 1 AS nextToken FROM appointments "
                            + "WHERE doctor_id = ? AND appointment_date = ?");
            token.setInt(1, doctor.getDoctorId());
            token.setDate(2, Date.valueOf(date));
            rs = token.executeQuery();
            int nextToken = rs.next() ? rs.getInt(1) : 1;
            rs.close();
            rs = null;

            insert = connection.prepareStatement(
                    "INSERT INTO appointments (patient_id, doctor_id, appointment_date, appointment_time, "
                            + "token_no, reason, status, created_at) VALUES (?, ?, ?, ?, ?, ?, 'Booked', ?)",
                    PreparedStatement.RETURN_GENERATED_KEYS);
            insert.setInt(1, patient.getPatientId());
            insert.setInt(2, doctor.getDoctorId());
            insert.setDate(3, Date.valueOf(date));
            insert.setTime(4, Time.valueOf(time));
            insert.setInt(5, nextToken);
            insert.setString(6, reason);
            insert.setTimestamp(7, new Timestamp(System.currentTimeMillis()));
            insert.executeUpdate();

            connection.commit();

            rs = insert.getGeneratedKeys();
            return rs.next() ? rs.getInt(1) : 0;
        } catch (SQLException e) {
            try {
                connection.rollback();
            } catch (SQLException ignored) {
                // connection already broken, the outer catch reports the original error
            }
            throw e;
        } finally {
            DBUtil.close(rs, lock, token, insert);
            try {
                connection.setAutoCommit(autoCommit);
            } catch (SQLException ignored) {
                // closing right after this
            }
        }
    }

    /** "Thu" reads like a database value, the form should say "Thursday". */
    static String fullDayName(LocalDate date) {
        switch (date.getDayOfWeek()) {
            case MONDAY: return "Monday";
            case TUESDAY: return "Tuesday";
            case WEDNESDAY: return "Wednesday";
            case THURSDAY: return "Thursday";
            case FRIDAY: return "Friday";
            case SATURDAY: return "Saturday";
            default: return "Sunday";
        }
    }

    private static int intParam(HttpServletRequest request, String name) {
        String raw = Validation.trim(request.getParameter(name));
        try {
            return raw.isEmpty() ? 0 : Integer.parseInt(raw);
        } catch (NumberFormatException e) {
            return 0;
        }
    }

    private static LocalDate parseDate(String raw) {
        String value = Validation.trim(raw);
        if (value.isEmpty()) {
            return null;
        }
        try {
            return LocalDate.parse(value);
        } catch (RuntimeException e) {
            return null;
        }
    }
}
