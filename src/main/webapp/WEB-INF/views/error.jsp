<%@ page contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" isErrorPage="true" %>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
<jsp:include page="/WEB-INF/views/fragments/header.jsp">
  <jsp:param name="title" value="Not working"/>
</jsp:include>

<div class="page-body">
  <div class="container container-narrow">
    <div class="card">
      <div class="card-body" style="padding:26px 28px">
        <div class="eyebrow">Problem</div>
        <h1 style="font-size:26px">
          <c:out value="${empty errorTitle ? 'This page could not be shown' : errorTitle}"/>
        </h1>
        <p class="muted" style="font-size:14.5px; max-width:70ch">
          Nothing was lost on purpose. The portal stopped before it could finish the database work
          for this request. Your earlier bookings are still in the <code>appointments</code> table.
        </p>

        <c:if test="${not empty errorDetail}">
          <div class="alert alert-err" style="margin-top:18px">
            <span style="word-break:break-word"><c:out value="${errorDetail}"/></span>
          </div>
        </c:if>

        <h3 style="margin-top:22px">Try these in order</h3>
        <ol style="font-size:14.5px; color:var(--ink-soft)">
          <li>Check that MySQL is running. On XAMPP open the control panel and make sure MySQL shows
            <em>Running</em>.</li>
          <li>Check that the database <code>medibook</code> exists and that the tables were created
            from <code>sql/medibook.sql</code>.</li>
          <li>Open <code>WEB-INF/classes/db.properties</code> in the deployed application and confirm
            the username and password match your MySQL installation.</li>
          <li>Restart Tomcat after changing <code>db.properties</code>, because the file is read once
            when the application starts.</li>
        </ol>

        <div class="divider"></div>
        <p class="muted" style="font-size:12.5px">
          The message above is printed because this is a college project and the evaluator needs to see
          what failed. A live clinic would write it to a log file and show a plain apology instead.
        </p>
        <div class="row-flex" style="margin-top:16px">
          <a class="btn btn-primary" href="${ctx}/dashboard">Try the dashboard again</a>
          <a class="btn btn-secondary" href="${ctx}/">Back to the landing page</a>
        </div>
      </div>
    </div>
  </div>
</div>

<jsp:include page="/WEB-INF/views/fragments/footer.jsp"/>
