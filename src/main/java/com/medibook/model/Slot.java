package com.medibook.model;

/** One selectable time slot on the booking form. */
public class Slot {

    private final String time;
    private final String label;
    private final String period;

    public Slot(String time, String label, String period) {
        this.time = time;
        this.label = label;
        this.period = period;
    }

    public String getTime() {
        return time;
    }

    public String getLabel() {
        return label;
    }

    public String getPeriod() {
        return period;
    }

    public boolean isMorning() {
        return "Morning".equals(period);
    }
}
