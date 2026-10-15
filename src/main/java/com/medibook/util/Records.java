package com.medibook.util;

import java.sql.ResultSet;
import java.sql.SQLException;
import com.medibook.model.Appointment;
import com.medibook.model.Department;
import com.medibook.model.Doctor;
import com.medibook.model.Patient;

/**
 * Turns a ResultSet row into a model object.
 * The SQL itself stays inside the servlets, this class only copies columns
 * into the beans so that the same mapping is not written four times.
 * Column labels are taken from the SELECT aliases (camelCase).
 */
public final class Records {

    private Records() {
    }

    public static Patient patient(ResultSet rs) throws SQLException {
        Patient p = new Patient();
        p.setPatientId(rs.getInt("patient_id"));
        p.setFullName(rs.getString("full_name"));
        p.setEmail(rs.getString("email"));
        p.setPhone(rs.getString("phone"));
        p.setGender(rs.getString("gender"));
        p.setDob(rs.getDate("dob"));
        p.setAddress(rs.getString("address"));
        p.setCity(rs.getString("city"));
        p.setPincode(rs.getString("pincode"));
        p.setBloodGroup(rs.getString("blood_group"));
        p.setAllergies(rs.getString("allergies"));
        p.setCreatedAt(rs.getTimestamp("created_at"));
        p.setLastLoginAt(rs.getTimestamp("last_login_at"));
        return p;
    }

    public static Department department(ResultSet rs) throws SQLException {
        Department d = new Department();
        d.setDepartmentId(rs.getInt("department_id"));
        d.setDepartmentName(rs.getString("department_name"));
        d.setDescription(rs.getString("description"));
        d.setDoctorCount(rs.getInt("doctorCount"));
        d.setMinFee(rs.getBigDecimal("minFee"));
        d.setMaxFee(rs.getBigDecimal("maxFee"));
        return d;
    }

    public static Doctor doctor(ResultSet rs) throws SQLException {
        Doctor d = new Doctor();
        d.setDoctorId(rs.getInt("doctor_id"));
        d.setDoctorName(rs.getString("doctor_name"));
        d.setDepartmentId(rs.getInt("department_id"));
        d.setDepartmentName(rs.getString("department_name"));
        d.setQualification(rs.getString("qualification"));
        d.setExperienceYears(rs.getInt("experience_years"));
        d.setConsultationFee(rs.getBigDecimal("consultation_fee"));
        d.setRoomNo(rs.getString("room_no"));
        d.setAvailableDays(rs.getString("available_days"));
        d.setStartTime(rs.getTime("start_time"));
        d.setEndTime(rs.getTime("end_time"));
        d.setSlotMinutes(rs.getInt("slot_minutes"));
        return d;
    }

    public static Appointment appointment(ResultSet rs) throws SQLException {
        Appointment a = new Appointment();
        a.setAppointmentId(rs.getInt("appointment_id"));
        a.setPatientId(rs.getInt("patient_id"));
        a.setDoctorId(rs.getInt("doctor_id"));
        a.setAppointmentDate(rs.getDate("appointment_date"));
        a.setAppointmentTime(rs.getTime("appointment_time"));
        a.setTokenNo(rs.getInt("token_no"));
        a.setReason(rs.getString("reason"));
        a.setStatus(rs.getString("status"));
        a.setDoctorName(rs.getString("doctor_name"));
        a.setDepartmentName(rs.getString("department_name"));
        a.setQualification(rs.getString("qualification"));
        a.setRoomNo(rs.getString("room_no"));
        a.setConsultationFee(rs.getBigDecimal("consultation_fee"));
        return a;
    }
}
