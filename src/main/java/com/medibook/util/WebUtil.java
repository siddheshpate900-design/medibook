package com.medibook.util;

import java.io.IOException;
import java.security.SecureRandom;
import java.util.HashMap;
import java.util.Map;
import javax.servlet.ServletException;
import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;
import javax.servlet.http.HttpSession;

/**
 * Small helpers so that every servlet does forwarding, redirects, one time
 * messages and the CSRF token in exactly the same way.
 */
public final class WebUtil {

    /** Session key that holds the logged in patient. */
    public static final String SESSION_PATIENT = "patient";
    public static final String CSRF_FIELD = "csrf";
    private static final String CSRF_SESSION = "csrfToken";
    private static final char[] HEX = "0123456789abcdef".toCharArray();
    private static final SecureRandom RANDOM = new SecureRandom();

    private WebUtil() {
    }

    /** Forwards to /WEB-INF/views/&lt;name&gt;.jsp after pulling out the flash message. */
    public static void render(HttpServletRequest request, HttpServletResponse response, String view)
            throws ServletException, IOException {
        takeFlash(request);
        request.setAttribute("csrfToken", csrfToken(request));
        request.setAttribute("today", java.time.LocalDate.now().toString());
        request.setAttribute("loggedIn", request.getSession().getAttribute(SESSION_PATIENT) != null);
        response.setContentType("text/html; charset=UTF-8");
        request.getRequestDispatcher("/WEB-INF/views/" + view).forward(request, response);
    }

    public static void redirect(HttpServletRequest request, HttpServletResponse response, String path)
            throws IOException {
        response.sendRedirect(request.getContextPath() + path);
    }

    /** Message shown once on the next page and then removed. */
    public static void flash(HttpServletRequest request, String type, String message) {
        HttpSession session = request.getSession();
        Map<String, String> flash = new HashMap<String, String>();
        flash.put("type", type);
        flash.put("message", message);
        session.setAttribute("flash", flash);
    }

    public static void error(HttpServletRequest request, HttpServletResponse response,
                            String title, String detail) throws ServletException, IOException {
        takeFlash(request);
        request.setAttribute("csrfToken", csrfToken(request));
        request.setAttribute("today", java.time.LocalDate.now().toString());
        request.setAttribute("loggedIn", request.getSession().getAttribute(SESSION_PATIENT) != null);
        request.setAttribute("pageTitle", title);
        request.setAttribute("errorTitle", title);
        request.setAttribute("errorDetail", detail == null ? "" : detail);
        response.setStatus(HttpServletResponse.SC_SERVICE_UNAVAILABLE);
        response.setContentType("text/html; charset=UTF-8");
        request.getRequestDispatcher("/WEB-INF/views/error.jsp").forward(request, response);
    }

    @SuppressWarnings("unchecked")
    private static void takeFlash(HttpServletRequest request) {
        HttpSession session = request.getSession(false);
        if (session == null) {
            return;
        }
        Object flash = session.getAttribute("flash");
        if (flash instanceof Map) {
            request.setAttribute("flashType", ((Map<String, String>) flash).get("type"));
            request.setAttribute("flashMessage", ((Map<String, String>) flash).get("message"));
            session.removeAttribute("flash");
        }
    }

    /** Same token for the whole session; a new one is generated on first use. */
    public static String csrfToken(HttpServletRequest request) {
        HttpSession session = request.getSession(true);
        String token = (String) session.getAttribute(CSRF_SESSION);
        if (token == null) {
            byte[] bytes = new byte[20];
            RANDOM.nextBytes(bytes);
            StringBuilder sb = new StringBuilder(bytes.length * 2);
            for (byte b : bytes) {
                sb.append(HEX[(b >> 4) & 0x0f]).append(HEX[b & 0x0f]);
            }
            token = sb.toString();
            session.setAttribute(CSRF_SESSION, token);
        }
        return token;
    }

    public static boolean csrfOk(HttpServletRequest request) {
        String expected = (String) request.getSession().getAttribute(CSRF_SESSION);
        String given = request.getParameter(CSRF_FIELD);
        return expected != null && given != null && expected.equals(given);
    }

    /** Logged in patient, or null when nobody is signed in. */
    public static Object currentUser(HttpServletRequest request) {
        HttpSession session = request.getSession(false);
        return session == null ? null : session.getAttribute(SESSION_PATIENT);
    }

    public static String contextPath(HttpServletRequest request) {
        String ctx = request.getContextPath();
        return "/".equals(ctx) ? "" : ctx;
    }
}
