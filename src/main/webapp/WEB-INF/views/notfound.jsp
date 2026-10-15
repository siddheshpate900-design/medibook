<%@ page contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" %>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
<jsp:include page="/WEB-INF/views/fragments/header.jsp">
  <jsp:param name="title" value="Page not found"/>
</jsp:include>

<div class="page-body">
  <div class="container container-narrow">
    <div class="card">
      <div class="card-body" style="padding:26px 28px">
        <div class="eyebrow">404</div>
        <h1 style="font-size:26px">No page at that address</h1>
        <p class="muted" style="font-size:14.5px; max-width:66ch">
          The portal only answers these addresses. A bookmark typed from memory is the usual reason
          for this page, since a slip link works only while you are signed in.
        </p>
        <ul style="font-size:14.5px">
          <li><a href="${ctx}/">Landing page</a> &mdash; departments, doctor list, today&rsquo;s OPD board</li>
          <li><a href="${ctx}/signup">Create an account</a></li>
          <li><a href="${ctx}/login">Sign in</a></li>
          <li><a href="${ctx}/book">Book an appointment</a> &mdash; needs a sign in</li>
          <li><a href="${ctx}/privacy">Privacy policy</a></li>
        </ul>
      </div>
    </div>
  </div>
</div>

<jsp:include page="/WEB-INF/views/fragments/footer.jsp"/>
