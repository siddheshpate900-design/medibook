package com.medibook.web;

import java.io.IOException;
import javax.servlet.ServletException;
import javax.servlet.annotation.WebServlet;
import javax.servlet.http.HttpServlet;
import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;
import com.medibook.util.WebUtil;

/**
 * Privacy policy page, linked from the footer of every page and from the
 * sign up form. Static text, so no database call is needed.
 */
@WebServlet(name = "PrivacyServlet", urlPatterns = {"/privacy"})
public class PrivacyServlet extends HttpServlet {

    private static final long serialVersionUID = 1L;

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        request.setAttribute("pageTitle", "Privacy Policy");
        WebUtil.render(request, response, "privacy.jsp");
    }
}
