package com.medibook.util;

import java.util.Collections;
import java.util.LinkedHashMap;
import java.util.Map;
import javax.servlet.ServletContext;
import javax.servlet.ServletContextEvent;
import javax.servlet.ServletContextListener;
import javax.servlet.annotation.WebListener;

/**
 * The few words that are repeated on many pages (clinic name, address, help
 * desk) are written once here and put into application scope as "site", so a
 * student can change them in one file instead of searching every JSP.
 *
 * The values below are placeholders for the college demo data. Replace the
 * phone number and email with the real clinic details before a live demo.
 */
@WebListener
public class SiteInfoListener implements ServletContextListener {

    public static final String ATTRIBUTE = "site";

    @Override
    public void contextInitialized(ServletContextEvent event) {
        Map<String, String> site = new LinkedHashMap<String, String>();
        site.put("clinicName", "Vidyavardhini General Clinic");
        site.put("productName", "MediBook");
        site.put("address", "Rankala Junction, Kolhapur 416001, Maharashtra");
        site.put("phone", "+91 231 000 0000");
        site.put("email", "clinic.desk@example.com");
        site.put("hours", "Monday to Saturday, 9:00 AM to 7:00 PM. Sunday: emergency desk only.");
        site.put("projectNote", "MediBook is a second year course project. It is not a live medical service.");
        site.put("college", "Department of Artificial Intelligence and Data Science, "
                + "Vidyavardhini's College of Engineering and Technology, University of Mumbai");
        site.put("academicYear", "2026-27");
        event.getServletContext().setAttribute(ATTRIBUTE, Collections.unmodifiableMap(site));
    }

    @Override
    public void contextDestroyed(ServletContextEvent event) {
        ServletContext context = event.getServletContext();
        context.removeAttribute(ATTRIBUTE);
    }
}
