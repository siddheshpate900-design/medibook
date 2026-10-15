package com.medibook.model;

import java.math.BigDecimal;
import java.sql.Time;

/** One row of the doctors table, joined with its department name. */
public class Doctor {

    private int doctorId;
    private String doctorName;
    private int departmentId;
    private String departmentName;
    private String qualification;
    private int experienceYears;
    private BigDecimal consultationFee;
    private String roomNo;
    private String availableDays;
    private Time startTime;
    private Time endTime;
    private int slotMinutes;
    /** Filled in only by the landing page: free slots left for today. */
    private int openSlotsToday;

    public int getDoctorId() {
        return doctorId;
    }

    public void setDoctorId(int doctorId) {
        this.doctorId = doctorId;
    }

    public String getDoctorName() {
        return doctorName;
    }

    public void setDoctorName(String doctorName) {
        this.doctorName = doctorName;
    }

    public int getDepartmentId() {
        return departmentId;
    }

    public void setDepartmentId(int departmentId) {
        this.departmentId = departmentId;
    }

    public String getDepartmentName() {
        return departmentName;
    }

    public void setDepartmentName(String departmentName) {
        this.departmentName = departmentName;
    }

    public String getQualification() {
        return qualification;
    }

    public void setQualification(String qualification) {
        this.qualification = qualification;
    }

    public int getExperienceYears() {
        return experienceYears;
    }

    public void setExperienceYears(int experienceYears) {
        this.experienceYears = experienceYears;
    }

    public BigDecimal getConsultationFee() {
        return consultationFee;
    }

    public void setConsultationFee(BigDecimal consultationFee) {
        this.consultationFee = consultationFee;
    }

    public String getRoomNo() {
        return roomNo;
    }

    public void setRoomNo(String roomNo) {
        this.roomNo = roomNo;
    }

    public String getAvailableDays() {
        return availableDays;
    }

    public void setAvailableDays(String availableDays) {
        this.availableDays = availableDays;
    }

    public Time getStartTime() {
        return startTime;
    }

    public void setStartTime(Time startTime) {
        this.startTime = startTime;
    }

    public Time getEndTime() {
        return endTime;
    }

    public void setEndTime(Time endTime) {
        this.endTime = endTime;
    }

    public int getSlotMinutes() {
        return slotMinutes;
    }

    public void setSlotMinutes(int slotMinutes) {
        this.slotMinutes = slotMinutes;
    }

    public int getOpenSlotsToday() {
        return openSlotsToday;
    }

    public void setOpenSlotsToday(int openSlotsToday) {
        this.openSlotsToday = openSlotsToday;
    }

    /** "09:30 AM to 01:30 PM" built from the two TIME columns. */
    public String getTimingsText() {
        if (startTime == null || endTime == null) {
            return "Timings not set";
        }
        return com.medibook.util.SlotUtil.label(startTime.toLocalTime())
                + " to " + com.medibook.util.SlotUtil.label(endTime.toLocalTime());
    }
}
