package com.medibook.util;

import java.time.LocalDate;
import java.time.LocalDateTime;
import java.time.LocalTime;
import java.util.ArrayList;
import java.util.Collection;
import java.util.HashSet;
import java.util.List;
import java.util.Set;
import com.medibook.model.Doctor;

/**
 * Builds the list of open time slots for one doctor on one date.
 * A slot is free when the doctor OPD covers it, nobody has already taken it,
 * and (for the current date) it is not in the past.
 */
public final class SlotUtil {

    private static final String[] DAY_NAMES = {"Mon", "Tue", "Wed", "Thu", "Fri", "Sat", "Sun"};
    /** Minutes of notice a patient must leave before the slot starts. */
    public static final int CLOSING_BUFFER_MINUTES = 30;

    private SlotUtil() {
    }

    public static String dayName(LocalDate date) {
        return DAY_NAMES[date.getDayOfWeek().getValue() - 1];
    }

    public static boolean clinicOpensOn(Doctor doctor, LocalDate date) {
        return Validation.worksOn(doctor.getAvailableDays(), dayName(date));
    }

    /**
     * @param doctor  the doctor whose OPD timings are used
     * @param date    the requested date
     * @param taken   times already booked for that doctor on that date
     */
    public static List<LocalTime> freeSlots(Doctor doctor, LocalDate date, Collection<LocalTime> taken) {
        List<LocalTime> free = new ArrayList<LocalTime>();
        if (doctor == null || date == null || !clinicOpensOn(doctor, date)) {
            return free;
        }
        Set<LocalTime> booked = taken == null ? new HashSet<LocalTime>() : new HashSet<LocalTime>(taken);
        int step = doctor.getSlotMinutes() <= 0 ? 15 : doctor.getSlotMinutes();
        LocalTime start = doctor.getStartTime().toLocalTime();
        LocalTime end = doctor.getEndTime().toLocalTime();
        if (start == null || end == null) {
            return free;
        }
        LocalDateTime nowLimit = LocalDateTime.now().plusMinutes(CLOSING_BUFFER_MINUTES);
        for (LocalTime t = start; !t.plusMinutes(step).isAfter(end); t = t.plusMinutes(step)) {
            if (booked.contains(t)) {
                continue;
            }
            if (date.isEqual(LocalDate.now()) && LocalDateTime.of(date, t).isBefore(nowLimit)) {
                continue;
            }
            free.add(t);
        }
        return free;
    }

    /** 09:30 -> "09:30 AM" */
    public static String label(LocalTime time) {
        int hour = time.getHour();
        int minute = time.getMinute();
        String suffix = hour >= 12 ? "PM" : "AM";
        int displayHour = hour % 12;
        if (displayHour == 0) {
            displayHour = 12;
        }
        return String.format("%02d:%02d %s", displayHour, minute, suffix);
    }
}
