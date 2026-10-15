<%@ page contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" %>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
<%@ taglib prefix="fmt" uri="http://java.sun.com/jsp/jstl/fmt" %>
<%@ taglib prefix="fn" uri="http://java.sun.com/jsp/jstl/functions" %>
<jsp:include page="/WEB-INF/views/fragments/header.jsp">
  <jsp:param name="title" value="Dashboard"/>
</jsp:include>

<div class="page-bar">
  <div class="container page-bar-inner">
    <div>
      <h1><c:out value="${patient.fullName}"/></h1>
      <div class="sub">
        <c:choose>
          <c:when test="${empty patient.lastLoginAt}">Signed in from this browser</c:when>
          <c:otherwise>Signed in <fmt:formatDate value="${patient.lastLoginAt}" type="both" dateStyle="medium" timeStyle="short"/></c:otherwise>
        </c:choose>
        &middot; Patient ID <span class="mono"><c:out value="${patient.patientCode}"/></span>
      </div>
    </div>
    <div class="row-flex">
      <a class="btn btn-secondary" href="${ctx}/profile">
        <jsp:include page="/WEB-INF/views/fragments/icon.jsp">
          <jsp:param name="name" value="user"/><jsp:param name="size" value="15"/>
        </jsp:include>
        Profile
      </a>
      <a class="btn btn-primary" href="${ctx}/book">
        <jsp:include page="/WEB-INF/views/fragments/icon.jsp">
          <jsp:param name="name" value="calendar"/><jsp:param name="size" value="15"/>
        </jsp:include>
        Book appointment
      </a>
    </div>
  </div>
</div>

<div class="page-body">
  <div class="container">

    <c:if test="${not empty missingFields}">
      <div class="alert alert-warn">
        <jsp:include page="/WEB-INF/views/fragments/icon.jsp">
          <jsp:param name="name" value="info"/><jsp:param name="size" value="17"/>
        </jsp:include>
        <span>
          Your record is still missing
          <c:forEach var="f" items="${missingFields}" varStatus="s"><c:out value="${f}"/><c:if test="${not s.last}">, </c:if></c:forEach>.
          The counter asks for them on the day if they are left out.
          <a href="${ctx}/profile">Fill them now</a>.
        </span>
      </div>
    </c:if>

    <div class="split">
      <div class="stack">

        <%-- ------------------------------------------------ next appointment --%>
        <c:choose>
          <c:when test="${empty next}">
            <div class="card">
              <div class="card-head"><h2>No appointment is open right now</h2></div>
              <div class="card-body">
                <p class="muted" style="font-size:14.5px">
                  Pick a department, a doctor and an open slot. The token number is given as soon as
                  the booking is saved, so you can come at that time instead of standing in the queue.
                </p>
              </div>
              <div class="card-foot">
                <a class="btn btn-primary" href="${ctx}/book">
                  <jsp:include page="/WEB-INF/views/fragments/icon.jsp">
                    <jsp:param name="name" value="plus"/><jsp:param name="size" value="15"/>
                  </jsp:include>
                  Book an appointment
                </a>
              </div>
            </div>
          </c:when>
          <c:otherwise>
            <div class="card next-card">
              <div class="card-head">
                <h2>Next appointment</h2>
                <span class="tag tag-ok">Confirmed</span>
              </div>
              <div class="card-body">
                <div class="grid grid-2" style="gap:16px">
                  <div>
                    <div class="stat-label">Date</div>
                    <div style="font-size:19px; font-weight:650">
                      <fmt:formatDate value="${next.appointmentDate}" pattern="EEEE, d MMMM yyyy"/>
                    </div>
                    <div class="muted" style="font-size:13.5px">
                      Token <span class="mono"><c:out value="${next.tokenLabel}"/></span>
                    </div>
                  </div>
                  <div>
                    <div class="stat-label">Reporting time</div>
                    <div style="font-size:19px; font-weight:650">
                      <fmt:formatDate value="${next.appointmentTime}" pattern="hh:mm a"/>
                    </div>
                    <div class="muted" style="font-size:13.5px">Room <c:out value="${next.roomNo}"/></div>
                  </div>
                </div>
                <div class="divider"></div>
                <dl class="kv">
                  <dt>Doctor</dt>
                  <dd><c:out value="${next.doctorName}"/> <span class="muted">(<c:out value="${next.qualification}"/>)</span></dd>
                  <dt>Department</dt>
                  <dd><c:out value="${next.departmentName}"/></dd>
                  <dt>Your note</dt>
                  <dd><c:out value="${empty next.reason ? 'Not filled' : next.reason}"/></dd>
                  <dt>Fee at counter</dt>
                  <dd>
                    <fmt:formatNumber value="${next.consultationFee}" maxFractionDigits="0" var="dfee"/>
                    &#8377;<c:out value="${dfee}"/>
                  </dd>
                </dl>
              </div>
              <div class="card-foot" style="display:flex; gap:10px; flex-wrap:wrap">
                <a class="btn btn-secondary btn-sm" href="${ctx}/slip?id=${next.appointmentId}">
                  <jsp:include page="/WEB-INF/views/fragments/icon.jsp">
                    <jsp:param name="name" value="print"/><jsp:param name="size" value="15"/>
                  </jsp:include>
                  Print slip
                </a>
                <c:if test="${next.cancellable}">
                  <form method="post" action="${ctx}/cancel" data-confirm="Cancel this appointment? The slot is released for other patients.">
                    <input type="hidden" name="csrf" value="${csrfToken}">
                    <input type="hidden" name="appointmentId" value="${next.appointmentId}">
                    <button class="btn btn-danger btn-sm" type="submit">Cancel appointment</button>
                  </form>
                </c:if>
                <span class="spacer"></span>
                <span class="muted" style="font-size:12.5px">Reach the desk 10 minutes early.</span>
              </div>
            </div>
          </c:otherwise>
        </c:choose>

        <%-- ------------------------------------------------------ own record --%>
        <div class="card">
          <div class="card-head">
            <h2>Your appointment record</h2>
            <span class="muted" style="font-size:12.5px">counted from the appointments table</span>
          </div>
          <div class="card-body">
            <div class="grid grid-4" style="gap:14px">
              <div class="stat">
                <div class="stat-label">Open bookings</div>
                <div class="stat-value"><c:out value="${countBooked}"/></div>
                <div class="stat-note">still to be visited</div>
              </div>
              <div class="stat">
                <div class="stat-label">Completed</div>
                <div class="stat-value"><c:out value="${countCompleted}"/></div>
                <div class="stat-note">visits on record</div>
              </div>
              <div class="stat">
                <div class="stat-label">Cancelled</div>
                <div class="stat-value"><c:out value="${countCancelled}"/></div>
                <div class="stat-note">released slots</div>
              </div>
              <div class="stat">
                <div class="stat-label">Doctors consulted</div>
                <div class="stat-value"><c:out value="${doctorCount}"/></div>
                <div class="stat-note">
                  <c:choose>
                    <c:when test="${visitCount == 0}">nothing booked yet</c:when>
                    <c:otherwise><c:out value="${visitCount}"/> booking<c:out value="${visitCount == 1 ? '' : 's'}"/></c:otherwise>
                  </c:choose>
                </div>
              </div>
            </div>
          </div>
        </div>

        <%-- -------------------------------------------------------- upcoming --%>
        <c:if test="${fn:length(upcoming) > 1}">
          <div class="card">
            <div class="card-head"><h2>All open bookings</h2>
              <span class="muted" style="font-size:12.5px"><c:out value="${fn:length(upcoming)}"/> open bookings</span>
            </div>
            <div class="card-body-flush table-wrap">
              <table class="table">
                <thead>
                <tr>
                  <th scope="col">Date and time</th>
                  <th scope="col">Doctor</th>
                  <th scope="col">Department</th>
                  <th scope="col">Token</th>
                  <th scope="col">Room</th>
                  <th scope="col"></th>
                </tr>
                </thead>
                <tbody>
                <c:forEach var="a" items="${upcoming}">
                  <tr>
                    <td>
                      <div class="table-title"><fmt:formatDate value="${a.appointmentDate}" pattern="d MMM yyyy"/></div>
                      <div class="muted" style="font-size:13px"><fmt:formatDate value="${a.appointmentTime}" pattern="hh:mm a"/></div>
                    </td>
                    <td><c:out value="${a.doctorName}"/></td>
                    <td class="muted"><c:out value="${a.departmentName}"/></td>
                    <td class="mono"><c:out value="${a.tokenLabel}"/></td>
                    <td class="mono"><c:out value="${a.roomNo}"/></td>
                    <td class="right">
                      <a class="btn btn-secondary btn-sm" href="${ctx}/slip?id=${a.appointmentId}">Slip</a>
                    </td>
                  </tr>
                </c:forEach>
                </tbody>
              </table>
            </div>
          </div>
        </c:if>

        <%-- --------------------------------------------------------- history --%>
        <div class="card">
          <div class="card-head"><h2>Consultation history</h2>
            <span class="muted" style="font-size:12.5px">newest first</span>
          </div>
          <c:choose>
            <c:when test="${empty history}">
              <div class="empty">
                Nothing here yet. A visit is recorded as completed once its slot time has passed, and a
                cancellation is kept so the desk can see why a room went empty.
              </div>
            </c:when>
            <c:otherwise>
              <div class="card-body-flush table-wrap">
                <table class="table">
                  <thead>
                  <tr>
                    <th scope="col">Date</th>
                    <th scope="col">Doctor</th>
                    <th scope="col">Department</th>
                    <th scope="col">Reason you wrote</th>
                    <th scope="col">Status</th>
                  </tr>
                  </thead>
                  <tbody>
                  <c:forEach var="a" items="${history}">
                    <tr>
                      <td class="nowrap"><fmt:formatDate value="${a.appointmentDate}" pattern="d MMM yyyy"/></td>
                      <td><c:out value="${a.doctorName}"/></td>
                      <td class="muted"><c:out value="${a.departmentName}"/></td>
                      <td class="muted" style="max-width:230px"><c:out value="${empty a.reason ? 'Not filled' : a.reason}"/></td>
                      <td>
                        <c:choose>
                          <c:when test="${a.status == 'Completed'}"><span class="tag tag-muted">Completed</span></c:when>
                          <c:otherwise><span class="tag tag-danger">Cancelled</span></c:otherwise>
                        </c:choose>
                      </td>
                    </tr>
                  </c:forEach>
                  </tbody>
                </table>
              </div>
            </c:otherwise>
          </c:choose>
        </div>
      </div>

      <%-- ------------------------------------------------------------- aside --%>
      <aside class="stack">
        <div class="card">
          <div class="card-head"><h3>Account</h3>
            <a class="btn btn-link btn-sm" href="${ctx}/profile">Edit</a>
          </div>
          <div class="card-body">
            <dl class="kv">
              <dt>Name</dt><dd><c:out value="${patient.fullName}"/></dd>
              <dt>Patient ID</dt><dd class="mono"><c:out value="${patient.patientCode}"/></dd>
              <dt>Mobile</dt><dd class="mono">+91 <c:out value="${patient.phone}"/></dd>
              <dt>Email</dt><dd style="word-break:break-all"><c:out value="${patient.email}"/></dd>
              <dt>Gender</dt><dd><c:out value="${patient.gender}"/></dd>
              <dt>Blood group</dt>
              <dd><c:out value="${empty patient.bloodGroup ? 'Not filled' : patient.bloodGroup}"/></dd>
            </dl>
          </div>
        </div>

        <div class="card">
          <div class="card-head"><h3>Clinic desk</h3></div>
          <div class="card-body">
            <ul class="rows" style="margin:0">
              <li style="padding-left:0; padding-right:0">
                <div class="feature">
                  <span class="feature-icon">
                    <jsp:include page="/WEB-INF/views/fragments/icon.jsp">
                      <jsp:param name="name" value="phone"/><jsp:param name="size" value="15"/>
                    </jsp:include>
                  </span>
                  <div>
                    <div class="table-title"><c:out value="${site.phone}"/></div>
                    <div class="muted" style="font-size:12.5px">For same day changes</div>
                  </div>
                </div>
              </li>
              <li style="padding-left:0; padding-right:0">
                <div class="feature">
                  <span class="feature-icon">
                    <jsp:include page="/WEB-INF/views/fragments/icon.jsp">
                      <jsp:param name="name" value="clock"/><jsp:param name="size" value="15"/>
                    </jsp:include>
                  </span>
                  <div>
                    <div class="table-title">OPD hours</div>
                    <div class="muted" style="font-size:12.5px"><c:out value="${site.hours}"/></div>
                  </div>
                </div>
              </li>
              <li style="padding-left:0; padding-right:0; border-bottom:0">
                <div class="feature">
                  <span class="feature-icon">
                    <jsp:include page="/WEB-INF/views/fragments/icon.jsp">
                      <jsp:param name="name" value="pin"/><jsp:param name="size" value="15"/>
                    </jsp:include>
                  </span>
                  <div>
                    <div class="table-title"><c:out value="${site.clinicName}"/></div>
                    <div class="muted" style="font-size:12.5px"><c:out value="${site.address}"/></div>
                  </div>
                </div>
              </li>
            </ul>
          </div>
        </div>

        <div class="card">
          <div class="card-head"><h3>Booking rules on this portal</h3></div>
          <div class="card-body">
            <ul style="margin:0; padding-left:18px; font-size:13.5px; color:var(--ink-soft)">
              <li>Slots open 60 days ahead and close 30 minutes before the sitting starts.</li>
              <li>One slot belongs to one patient. The database check stops a double booking.</li>
              <li>Cancelling releases the slot at once, so another patient can take it.</li>
              <li>A booking whose time has passed is marked <strong>Completed</strong> by the portal.</li>
            </ul>
          </div>
        </div>
      </aside>
    </div>
  </div>
</div>

<jsp:include page="/WEB-INF/views/fragments/footer.jsp"/>
