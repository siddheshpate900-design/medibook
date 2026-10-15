<%@ page contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" %>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
<%-- Closing part of every page: footer and the script that marks the current link. --%>
</main>

<footer class="site-footer">
  <div class="container">
    <div class="footer-grid">
      <div>
        <h4><c:out value="${site.clinicName}"/></h4>
        <p>
          <c:out value="${site.address}"/><br>
          OPD hours: <c:out value="${site.hours}"/>
        </p>
        <p>
          Help desk: <c:out value="${site.phone}"/><br>
          Email: <c:out value="${site.email}"/>
        </p>
      </div>
      <div>
        <h4>Portal</h4>
        <ul>
          <li><a href="${ctx}/">Landing page</a></li>
          <li><a href="${ctx}/signup">Create an account</a></li>
          <li><a href="${ctx}/login">Sign in</a></li>
          <li><a href="${ctx}/book">Book an appointment</a></li>
        </ul>
      </div>
      <div>
        <h4>Patients</h4>
        <ul>
          <li><a href="${ctx}/#how">How the booking works</a></li>
          <li><a href="${ctx}/#departments">Departments and fees</a></li>
          <li><a href="${ctx}/#doctors">Doctor list</a></li>
          <li><a href="${ctx}/privacy">Privacy policy</a></li>
        </ul>
      </div>
      <div>
        <h4>About this project</h4>
        <ul>
          <li>Course project, Semester III</li>
          <li><c:out value="${site.college}"/></li>
          <li>Academic year <c:out value="${site.academicYear}"/></li>
          <li>Built with Servlets, JSP, JSTL, JDBC and MySQL</li>
        </ul>
      </div>
    </div>
    <div class="footer-bottom">
      <span>&copy; 2026 <c:out value="${site.productName}"/> &mdash; <c:out value="${site.projectNote}"/></span>
      <span>For a medical emergency, call the clinic desk or the nearest hospital.</span>
    </div>
  </div>
</footer>
<script src="${ctx}/assets/js/app.js"></script>
</body>
</html>
