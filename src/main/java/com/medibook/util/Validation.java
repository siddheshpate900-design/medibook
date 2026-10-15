package com.medibook.util;

import java.time.LocalDate;
import java.time.Period;
import java.time.format.DateTimeParseException;
import java.util.LinkedHashMap;
import java.util.Map;
import java.util.regex.Pattern;

/**
 * Form checks shared by the Sign Up and Profile servlets.
 * Every method puts a message into the returned map using the form field
 * name as the key, so the JSP can print the error under the right box.
 */
public final class Validation {

    private static final Pattern EMAIL =
            Pattern.compile("^[A-Za-z0-9._%+-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,}$");
    private static final Pattern PHONE = Pattern.compile("^[6-9][0-9]{9}$");
    private static final Pattern PINCODE = Pattern.compile("^[1-9][0-9]{5}$");
    private static final Pattern NAME = Pattern.compile("^[A-Za-z][A-Za-z .']{2,49}$");

    private Validation() {
    }

    public static Map<String, String> newErrors() {
        return new LinkedHashMap<String, String>();
    }

    public static String trim(String value) {
        return value == null ? "" : value.trim();
    }

    public static void fullName(Map<String, String> errors, String value) {
        String v = trim(value);
        if (v.isEmpty()) {
            errors.put("fullName", "Please enter your name as it appears on your ID proof.");
        } else if (!NAME.matcher(v).matches()) {
            errors.put("fullName", "Use letters, spaces and dots only (3 to 50 characters).");
        }
    }

    public static void email(Map<String, String> errors, String value) {
        String v = trim(value);
        if (v.isEmpty()) {
            errors.put("email", "Please enter your email address.");
        } else if (v.length() > 120 || !EMAIL.matcher(v).matches()) {
            errors.put("email", "That does not look like a valid email address.");
        }
    }

    public static void phone(Map<String, String> errors, String value) {
        String v = trim(value).replaceAll("[^0-9]", "");
        if (v.isEmpty()) {
            errors.put("phone", "Please enter your mobile number.");
        } else if (!PHONE.matcher(v).matches()) {
            errors.put("phone", "Enter a 10 digit Indian mobile number (no +91, no spaces).");
        }
    }

    /** At least 8 characters with one letter and one digit. */
    public static void password(Map<String, String> errors, String value) {
        String v = value == null ? "" : value;
        if (v.isEmpty()) {
            errors.put("password", "Please choose a password.");
        } else if (v.length() < 8) {
            errors.put("password", "Password must be at least 8 characters long.");
        } else if (!v.matches(".*[A-Za-z].*") || !v.matches(".*[0-9].*")) {
            errors.put("password", "Password must contain at least one letter and one digit.");
        } else if (v.length() > 64) {
            errors.put("password", "Password is too long (64 characters maximum).");
        }
    }

    public static void confirmPassword(Map<String, String> errors, String password, String confirm) {
        String p = password == null ? "" : password;
        String c = confirm == null ? "" : confirm;
        if (c.isEmpty()) {
            errors.put("confirmPassword", "Please type the password again.");
        } else if (!p.equals(c)) {
            errors.put("confirmPassword", "Both passwords should be the same.");
        }
    }

    /** @return the parsed date, null when blank or not a real calendar date. */
    public static LocalDate date(Map<String, String> errors, String value, boolean required,
                                 int minAgeYears, String field) {
        String v = trim(value);
        if (v.isEmpty()) {
            if (required) {
                errors.put(field, "This field is required.");
            }
            return null;
        }
        LocalDate parsed;
        try {
            parsed = LocalDate.parse(v);
        } catch (DateTimeParseException e) {
            errors.put(field, "Use the format YYYY-MM-DD.");
            return null;
        }
        LocalDate today = LocalDate.now();
        if (parsed.isAfter(today)) {
            errors.put(field, "A date in the future is not valid here.");
            return null;
        }
        if (Period.between(parsed, today).getYears() < minAgeYears) {
            errors.put(field, "Please check the year. That age is not accepted.");
            return null;
        }
        return parsed;
    }

    public static void optionalText(Map<String, String> errors, String value, int maxLength, String field) {
        String v = trim(value);
        if (v.length() > maxLength) {
            errors.put(field, "Please keep this under " + maxLength + " characters.");
        }
    }

    public static void pincode(Map<String, String> errors, String value) {
        String v = trim(value);
        if (!v.isEmpty() && !PINCODE.matcher(v).matches()) {
            errors.put("pincode", "PIN code should be 6 digits.");
        }
    }

    /** True when the day-of-week name (Mon, Tue ...) appears in the doctor's list. */
    public static boolean worksOn(String availableDays, String dayName) {
        if (availableDays == null) {
            return false;
        }
        for (String part : availableDays.split(",")) {
            if (part.trim().equalsIgnoreCase(dayName)) {
                return true;
            }
        }
        return false;
    }
}
