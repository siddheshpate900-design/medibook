<%@ page contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" %>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
<%--
    Page head, top navigation and the one time message bar.
    Opened here, the <main> element is closed by footer.jsp.
    Pass the page title with:  <jsp:param name="title" value="Dashboard"/>
--%>
<c:set var="ctx" value="${pageContext.request.contextPath}" scope="request"/>
<c:set var="site" value="${applicationScope.site}" scope="request"/>
<c:set var="me" value="${sessionScope.patient}" scope="request"/>
<!DOCTYPE html>
<html lang="en">
<head>
<meta charset="UTF-8">
<meta name="viewport" content="width=device-width, initial-scale=1">
<title><c:out value="${param.title}"/> &middot; <c:out value="${site.productName}"/></title>
<meta name="description" content="<c:out value="${site.clinicName}"/> appointment portal: register, book an OPD slot and keep your visit record.">
<meta name="robots" content="noindex">
<link rel="icon" href="data:image/svg+xml,%3Csvg xmlns='http://www.w3.org/2000/svg' viewBox='0 0 32 32'%3E%3Crect width='32' height='32' rx='4' fill='%230f6b5f'/%3E%3Cpath d='M14 7h4v7h7v4h-7v7h-4v-7H7v-4h7z' fill='%23ffffff'/%3E%3C/svg%3E">
<link rel="stylesheet" href="${ctx}/assets/css/main.css">
</head>
<body>
<a class="skip-link" href="#main">Skip to main content</a>
<header class="masthead">
  <div class="container masthead-inner">
    <a class="brand" href="${ctx}/">
      <span class="brand-mark">
        <svg width="16" height="16" viewBox="0 0 24 24" aria-hidden="true" focusable="false">
          <path d="M10 3.5h4v6.5h6.5v4H14v6.5h-4V14H3.5v-4H10z" fill="#ffffff"/>
        </svg>
      </span>
      <span>
        <span class="brand-name"><c:out value="${site.productName}"/></span>
        <span class="brand-sub">OPD portal</span>
      </span>
    </a>

    <nav class="nav" aria-label="Main">
      <c:choose>
        <c:when test="${loggedIn}">
          <a href="${ctx}/dashboard">Dashboard</a>
          <a href="${ctx}/book">Book appointment</a>
          <a href="${ctx}/profile">Profile</a>
          <a href="${ctx}/#doctors">Doctor list</a>
        </c:when>
        <c:otherwise>
          <a href="${ctx}/#how">How it works</a>
          <a href="${ctx}/#departments">Departments</a>
          <a href="${ctx}/#doctors">Doctors</a>
          <a href="${ctx}/privacy">Privacy</a>
        </c:otherwise>
      </c:choose>
    </nav>

    <div class="masthead-actions">
      <c:choose>
        <c:when test="${loggedIn}">
          <span class="who">
            <span class="who-initials"><c:out value="${me.initials}"/></span>
            <span><c:out value="${me.fullName}"/></span>
          </span>
          <form method="post" action="${ctx}/logout" class="row-flex" style="gap:0">
            <input type="hidden" name="csrf" value="${csrfToken}">
            <button type="submit" class="btn btn-secondary btn-sm">
              <jsp:include page="/WEB-INF/views/fragments/icon.jsp">
                <jsp:param name="name" value="logout"/>
                <jsp:param name="size" value="15"/>
              </jsp:include>
              Sign out
            </button>
          </form>
        </c:when>
        <c:otherwise>
          <a class="btn btn-secondary" href="${ctx}/login">Sign in</a>
          <a class="btn btn-primary" href="${ctx}/signup">Create account</a>
        </c:otherwise>
      </c:choose>
    </div>
  </div>
</header>

<c:if test="${not empty flashMessage}">
  <div class="container" style="padding-top:18px">
    <div class="alert alert-<c:out value="${flashType}"/>">
      <jsp:include page="/WEB-INF/views/fragments/icon.jsp">
        <jsp:param name="name" value="${flashType eq 'ok' ? 'check' : (flashType eq 'err' ? 'alert' : 'info')}"/>
        <jsp:param name="size" value="17"/>
      </jsp:include>
      <span><c:out value="${flashMessage}"/></span>
    </div>
  </div>
</c:if>

<main id="main">
