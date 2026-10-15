package com.medibook.web;

import java.io.IOException;
import java.net.URLEncoder;
import javax.servlet.Filter;
import javax.servlet.FilterChain;
import javax.servlet.FilterConfig;
import javax.servlet.ServletException;
import javax.servlet.ServletRequest;
import javax.servlet.ServletResponse;
import javax.servlet.annotation.WebFilter;
import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;
import javax.servlet.http.HttpSession;
import com.medibook.model.Patient;
import com.medibook.util.WebUtil;

/**
 * Guards every page that needs a login.
 *
 * 1. no session            -> send the browser to the login page and remember
 *                             which page was asked for
 * 2. POST without a valid CSRF token -> 403
 * 3. otherwise             -> add no-cache headers and continue
 */
@WebFilter(filterName = "AuthFilter",
        urlPatterns = {"/dashboard", "/profile", "/book", "/cancel", "/slip"})
public class AuthFilter implements Filter {

    @Override
    public void init(FilterConfig config) {
        // nothing to prepare
    }

    @Override
    public void doFilter(ServletRequest servletRequest, ServletResponse servletResponse,
                         FilterChain chain) throws IOException, ServletException {
        HttpServletRequest request = (HttpServletRequest) servletRequest;
        HttpServletResponse response = (HttpServletResponse) servletResponse;

        HttpSession session = request.getSession(false);
        Patient patient = session == null ? null : (Patient) session.getAttribute(WebUtil.SESSION_PATIENT);

        if (patient == null) {
            if ("GET".equalsIgnoreCase(request.getMethod())) {
                response.sendRedirect(loginTarget(request));
            } else {
                response.sendError(HttpServletResponse.SC_UNAUTHORIZED,
                        "Your session ended. Please sign in again.");
            }
            return;
        }

        if ("POST".equalsIgnoreCase(request.getMethod()) && !WebUtil.csrfOk(request)) {
            response.sendError(HttpServletResponse.SC_FORBIDDEN,
                    "The form had expired. Go back, refresh the page and try again.");
            return;
        }

        response.setHeader("Cache-Control", "no-store, must-revalidate");
        response.setHeader("Pragma", "no-cache");
        response.setDateHeader("Expires", 0);
        chain.doFilter(request, response);
    }

    /** /login?redirect=/dashboard after the current URL, without the context path. */
    private String loginTarget(HttpServletRequest request) throws IOException {
        StringBuilder target = new StringBuilder(request.getRequestURI());
        String context = request.getContextPath();
        if (context != null && !context.isEmpty() && target.indexOf(context) == 0) {
            target.delete(0, context.length());
        }
        if (request.getQueryString() != null) {
            target.append('?').append(request.getQueryString());
        }
        return request.getContextPath() + "/login?redirect="
                + URLEncoder.encode(target.toString(), "UTF-8");
    }

    @Override
    public void destroy() {
        // nothing to release
    }
}
