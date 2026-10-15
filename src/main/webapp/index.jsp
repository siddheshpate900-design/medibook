<%@ page contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" %>
<%--
    This file exists for one reason. Tomcat serves the welcome page by looking
    for a real file, and the landing page has to read the department, doctor
    and appointment tables first, which a JSP should not do in this project.
    So the request is forwarded to HomeServlet ("/home"), which runs the SELECT
    statements and then renders /WEB-INF/views/home.jsp.
    No HTML is written here, so nothing is duplicated.
--%>
<jsp:forward page="/home"/>
