<%@ page contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" %>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
<jsp:include page="/WEB-INF/views/fragments/header.jsp">
  <jsp:param name="title" value="Sign in"/>
</jsp:include>

<div class="auth-page">
  <div class="container" style="max-width:860px">
    <div class="auth-shell">
      <aside class="auth-aside">
        <div class="eyebrow">Patient sign in</div>
        <h2>Two things are enough</h2>
        <p class="muted" style="font-size:13.5px">
          Use the email id or the 10 digit mobile number you gave while registering, plus your
          password. The portal opens straight on your appointment dashboard.
        </p>
        <div class="divider"></div>
        <h3 style="font-size:13.5px; margin-bottom:8px">Before you sign in</h3>
        <ul>
          <li>Passwords are case sensitive.</li>
          <li>After six wrong attempts the form waits two minutes.</li>
          <li>On a shared computer, sign out when you finish.</li>
        </ul>
        <div class="divider"></div>
        <p style="font-size:13px; color:var(--muted)">
          Forgot the password? The desk resets it in person against a photo ID; this portal keeps
          no email or SMS reset link because it stores no address for delivery.
        </p>
      </aside>

      <div class="auth-main">
        <div class="auth-head">
          <h1>Sign in to MediBook</h1>
          <p class="muted" style="font-size:14px">Account created but never used?
            <a href="${ctx}/signup">Register here</a>.</p>
        </div>

        <c:if test="${not empty loginError}">
          <div class="alert alert-err">
            <jsp:include page="/WEB-INF/views/fragments/icon.jsp">
              <jsp:param name="name" value="alert"/><jsp:param name="size" value="17"/>
            </jsp:include>
            <span><c:out value="${loginError}"/></span>
          </div>
        </c:if>

        <form method="post" action="${ctx}/login" novalidate>
          <input type="hidden" name="redirect" value="<c:out value="${redirectTarget}"/>">
          <div class="field ${not empty errors.login ? 'is-invalid' : ''}">
            <label class="field-label req" for="login">Email or mobile number</label>
            <input class="control" type="text" id="login" name="login" autocomplete="username"
                   value="<c:out value="${valLogin}"/>" required>
            <p class="hint">Both work. A mobile number is typed as 10 digits without +91.</p>
          </div>

          <div class="field">
            <label class="field-label req" for="password">Password</label>
            <input class="control" type="password" id="password" name="password"
                   autocomplete="current-password" required>
          </div>

          <div class="form-actions">
            <button class="btn btn-primary btn-lg" type="submit">Sign in</button>
            <a class="btn btn-link" href="${ctx}/signup">Create a new account</a>
          </div>
        </form>

        <p class="auth-foot">
          This portal is used by patients only. The clinic reception keeps its own register, and the
          doctor list on the landing page is maintained by the office.
        </p>
      </div>
    </div>
  </div>
</div>

<jsp:include page="/WEB-INF/views/fragments/footer.jsp"/>
