<%@ page contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" %>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
<%@ taglib prefix="fmt" uri="http://java.sun.com/jsp/jstl/fmt" %>
<jsp:include page="/WEB-INF/views/fragments/header.jsp">
  <jsp:param name="title" value="Appointment slip"/>
</jsp:include>

<div class="page-body">
  <div class="container container-narrow">

    <c:if test="${fresh}">
      <div class="alert alert-ok no-print">
        <jsp:include page="/WEB-INF/views/fragments/icon.jsp">
          <jsp:param name="name" value="check"/><jsp:param name="size" value="17"/>
        </jsp:include>
        <span>Booking saved. Print this slip or show it on your phone at the registration counter.</span>
      </div>
    </c:if>

    <div class="row-flex no-print" style="justify-content:space-between; margin-bottom:14px">
      <a class="btn btn-secondary btn-sm" href="${ctx}/dashboard">
        <jsp:include page="/WEB-INF/views/fragments/icon.jsp">
          <jsp:param name="name" value="arrow-right"/><jsp:param name="size" value="14"/>
        </jsp:include>
        Back to dashboard
      </a>
      <button class="btn btn-primary btn-sm" type="button" onclick="window.print()">
        <jsp:include page="/WEB-INF/views/fragments/icon.jsp">
          <jsp:param name="name" value="print"/><jsp:param name="size" value="14"/>
        </jsp:include>
        Print this slip
      </button>
    </div>

    <div class="card print-sheet">
      <div class="card-body" style="padding:26px 28px">
        <div style="display:flex; gap:14px; align-items:flex-start; border-bottom:1px solid var(--line); padding-bottom:16px">
          <span class="brand-mark" style="width:34px; height:34px">
            <svg width="18" height="18" viewBox="0 0 24 24" aria-hidden="true" focusable="false">
              <path d="M10 3.5h4v6.5h6.5v4H14v6.5h-4V14H3.5v-4H10z" fill="#ffffff"/>
            </svg>
          </span>
          <div style="flex:1 1 auto">
            <div style="font-size:17px; font-weight:700"><c:out value="${site.clinicName}"/></div>
            <div class="muted" style="font-size:13px"><c:out value="${site.address}"/></div>
            <div class="muted" style="font-size:13px">
              Help desk <c:out value="${site.phone}"/> &middot; <c:out value="${site.hours}"/>
            </div>
          </div>
          <div class="right">
            <div class="eyebrow" style="margin:0">Appointment slip</div>
            <div class="mono" style="font-size:13px">Ref MB-<c:out value="${appointment.appointmentId}"/></div>
          </div>
        </div>

        <div style="display:flex; gap:26px; flex-wrap:wrap; padding:20px 0; border-bottom:1px solid var(--line)">
          <div style="flex:1 1 220px">
            <div class="stat-label">Date</div>
            <div style="font-size:21px; font-weight:650">
              <fmt:formatDate value="${appointment.appointmentDate}" pattern="EEEE, d MMMM yyyy"/>
            </div>
          </div>
          <div style="flex:1 1 160px">
            <div class="stat-label">Reporting time</div>
            <div style="font-size:21px; font-weight:650">
              <fmt:formatDate value="${appointment.appointmentTime}" pattern="hh:mm a"/>
            </div>
          </div>
          <div style="flex:0 0 120px; border-left:1px solid var(--line); padding-left:22px">
            <div class="stat-label">Token</div>
            <div style="font-size:30px; font-weight:700; letter-spacing:-0.02em" class="mono">
              <c:out value="${appointment.tokenLabel}"/>
            </div>
          </div>
        </div>

        <dl class="kv" style="padding-top:18px">
          <dt>Patient</dt>
          <dd><c:out value="${patient.fullName}"/> <span class="muted">(ID <c:out value="${patient.patientCode}"/>)</span></dd>
          <dt>Mobile</dt><dd class="mono">+91 <c:out value="${patient.phone}"/></dd>
          <dt>Department</dt><dd><c:out value="${appointment.departmentName}"/></dd>
          <dt>Doctor</dt>
          <dd><c:out value="${appointment.doctorName}"/> <span class="muted">(<c:out value="${appointment.qualification}"/>)</span></dd>
          <dt>Room</dt><dd class="mono"><c:out value="${appointment.roomNo}"/></dd>
          <dt>Complaint</dt><dd><c:out value="${empty appointment.reason ? 'Not filled' : appointment.reason}"/></dd>
          <dt>Fee</dt>
          <dd>
            <fmt:formatNumber value="${appointment.consultationFee}" maxFractionDigits="0" var="sfee"/>
            &#8377;<c:out value="${sfee}"/> payable at the counter
          </dd>
          <dt>Status</dt>
          <dd>
            <c:choose>
              <c:when test="${appointment.status == 'Booked'}"><span class="tag tag-ok">Confirmed</span></c:when>
              <c:when test="${appointment.status == 'Completed'}"><span class="tag tag-muted">Completed</span></c:when>
              <c:otherwise><span class="tag tag-danger">Cancelled</span></c:otherwise>
            </c:choose>
          </dd>
        </dl>

        <div class="divider"></div>
        <p class="muted" style="font-size:12.5px">
          Carry a photo ID. A slot is held for 15 minutes after its reporting time; after that the desk
          may call the next token. This slip was produced by the patient portal and is not a medical
          certificate. <c:out value="${site.projectNote}"/>
        </p>
      </div>
    </div>
  </div>
</div>

<jsp:include page="/WEB-INF/views/fragments/footer.jsp"/>
