<%@ page contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" %>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
<%@ taglib prefix="fmt" uri="http://java.sun.com/jsp/jstl/fmt" %>
<%@ taglib prefix="fn" uri="http://java.sun.com/jsp/jstl/functions" %>
<jsp:include page="/WEB-INF/views/fragments/header.jsp">
  <jsp:param name="title" value="Book an appointment"/>
</jsp:include>

<div class="page-bar">
  <div class="container page-bar-inner">
    <div>
      <h1>Book an appointment</h1>
      <div class="sub">
        Slots are generated from each doctor&rsquo;s sitting hours and then cleared of the bookings
        already in the database. Bookings open <c:out value="${windowDays}"/> days ahead.
      </div>
    </div>
    <span class="muted" style="font-size:13px">
      Showing <c:out value="${fn:length(slots)}"/> open slot<c:out value="${fn:length(slots) == 1 ? '' : 's'}"/>
      &middot; <c:out value="${takenCount}"/> already taken
    </span>
  </div>
</div>

<div class="page-body">
  <div class="container">
    <div class="split">
      <div class="stack">

        <%-- ------------------------------------------------ step 1: the pick --%>
        <div class="card">
          <div class="card-head"><h2>1. Department, doctor and date</h2></div>
          <div class="card-body">
            <form method="get" action="${ctx}/book" data-steps="true">
              <div class="form-grid-3">
                <div class="field">
                  <label class="field-label" for="department">Department</label>
                  <select class="control" id="department" name="department" data-autosubmit="true">
                    <option value="0">All departments</option>
                    <c:forEach var="dep" items="${departments}">
                      <option value="${dep.departmentId}"
                          ${dep.departmentId == selectedDepartment ? 'selected="selected"' : ''}>
                        <c:out value="${dep.departmentName}"/>
                      </option>
                    </c:forEach>
                  </select>
                </div>

                <div class="field ${not empty errors.doctor ? 'is-invalid' : ''}">
                  <label class="field-label" for="doctor">Doctor</label>
                  <select class="control" id="doctor" name="doctor" data-autosubmit="true">
                    <option value="0">Choose a doctor</option>
                    <c:forEach var="doc" items="${doctors}">
                      <option value="${doc.doctorId}" ${doc.doctorId == selectedDoctorId ? 'selected="selected"' : ''}>
                        <c:out value="${doc.doctorName}"/> &mdash; <c:out value="${doc.departmentName}"/>
                      </option>
                    </c:forEach>
                  </select>
                  <c:if test="${not empty errors.doctor}">
                    <p class="error-text"><c:out value="${errors.doctor}"/></p>
                  </c:if>
                </div>

                <div class="field ${not empty errors.date ? 'is-invalid' : ''}">
                  <label class="field-label" for="date">Date</label>
                  <input class="control" type="date" id="date" name="date" value="<c:out value="${dateText}"/>"
                         min="${minDate}" max="${maxDate}">
                  <c:if test="${not empty errors.date}">
                    <p class="error-text"><c:out value="${errors.date}"/></p>
                  </c:if>
                  <c:if test="${empty errors.date && not empty dayName}">
                    <p class="hint">Selected day: <c:out value="${dayName}"/></p>
                  </c:if>
                </div>
              </div>
              <div class="form-actions" style="margin-top:6px">
                <button class="btn btn-secondary" type="submit">Show open slots</button>
                <span class="hint" style="margin:0">
                  Changing a box reloads this page with the other two choices kept.
                </span>
              </div>
            </form>
          </div>
        </div>

        <%-- -------------------------------------------------- step 2: the slot --%>
        <div class="card">
          <div class="card-head">
            <h2>2. Pick a time and send it</h2>
            <c:if test="${not empty doctor}">
              <span class="tag tag-info"><c:out value="${doctor.doctorName}"/></span>
            </c:if>
          </div>
          <div class="card-body">
            <c:choose>
              <c:when test="${empty doctor}">
                <div class="slots-empty">
                  Choose a doctor above. The open slots for that doctor and date appear here.
                </div>
              </c:when>
              <c:when test="${empty slots}">
                <div class="slots-empty">
                  <strong>No slot is open on <c:out value="${dateText}"/>.</strong>
                  <p style="margin:6px 0 0; font-size:13.5px">
                    <c:out value="${doctor.doctorName}"/> sits on
                    <c:out value="${doctor.availableDays}"/>,
                    <c:out value="${doctor.timingsText}"/>. Either move the date, or come to the
                    counter for a walk-in slot if the doctor is already seated.
                  </p>
                </div>
              </c:when>
              <c:otherwise>
                <form method="post" action="${ctx}/book">
                  <input type="hidden" name="csrf" value="${csrfToken}">
                  <input type="hidden" name="department" value="${selectedDepartment}">
                  <input type="hidden" name="doctor" value="${selectedDoctorId}">
                  <input type="hidden" name="date" value="<c:out value="${dateText}"/>">

                  <div class="field ${not empty errors.slot ? 'is-invalid' : ''}">
                    <span class="field-label" id="slotLabel">Open slots &mdash; <c:out value="${dateText}"/></span>
                    <c:if test="${not empty errors.slot}">
                      <p class="error-text" style="margin:0 0 8px"><c:out value="${errors.slot}"/></p>
                    </c:if>
                    <div class="slots" role="group" aria-labelledby="slotLabel">
                      <c:forEach var="slot" items="${slots}">
                        <div class="slot">
                          <input type="radio" name="slot" id="slot-${slot.time}" value="${slot.time}">
                          <label for="slot-${slot.time}"><c:out value="${slot.label}"/></label>
                        </div>
                      </c:forEach>
                    </div>
                    <p class="hint">
                      Each slot is <c:out value="${doctor.slotMinutes}"/> minutes. The sitting closes
                      30 minutes before the first slot you can still take.
                    </p>
                  </div>

                  <div class="field ${not empty errors.reason ? 'is-invalid' : ''}">
                    <label class="field-label" for="reason">Complaint in a few words</label>
                    <textarea class="control" id="reason" name="reason" maxlength="300"
                              placeholder="For example: fever since Tuesday with body ache"><c:out value="${valReason}"/></textarea>
                    <c:choose>
                      <c:when test="${not empty errors.reason}">
                        <p class="error-text"><c:out value="${errors.reason}"/></p>
                      </c:when>
                      <c:otherwise>
                        <p class="hint">Written by you, shown to the doctor on the appointment row. 5 to 300 characters.</p>
                      </c:otherwise>
                    </c:choose>
                  </div>

                  <div class="form-actions">
                    <button class="btn btn-primary btn-lg" type="submit">Confirm booking</button>
                    <a class="btn btn-link" href="${ctx}/dashboard">Back to dashboard</a>
                  </div>
                </form>
              </c:otherwise>
            </c:choose>
          </div>
        </div>

        <p class="muted" style="font-size:13px">
          Confirming writes one row into the <code>appointments</code> table inside a transaction, so
          two patients cannot be given the same slot. Nothing is charged online.
          See the <a href="${ctx}/privacy">privacy policy</a> for what is stored.
        </p>
      </div>

      <%-- ------------------------------------------------------------- aside --%>
      <aside class="stack">
        <div class="card">
          <div class="card-head"><h3>Doctor chosen</h3></div>
          <c:choose>
            <c:when test="${empty doctor}">
              <div class="empty" style="border-top:0">Nothing selected yet.</div>
            </c:when>
            <c:otherwise>
              <div class="card-body">
                <div style="font-size:17px; font-weight:650"><c:out value="${doctor.doctorName}"/></div>
                <div class="muted" style="font-size:13.5px; margin-bottom:12px">
                  <c:out value="${doctor.qualification}"/>
                </div>
                <dl class="kv">
                  <dt>Department</dt><dd><c:out value="${doctor.departmentName}"/></dd>
                  <dt>Experience</dt><dd><c:out value="${doctor.experienceYears}"/> years</dd>
                  <dt>Sits on</dt><dd><c:out value="${doctor.availableDays}"/></dd>
                  <dt>Timings</dt><dd class="mono"><c:out value="${doctor.timingsText}"/></dd>
                  <dt>Room</dt><dd class="mono"><c:out value="${doctor.roomNo}"/></dd>
                  <dt>Fee</dt>
                  <dd>
                    <fmt:formatNumber value="${doctor.consultationFee}" maxFractionDigits="0" var="bfee"/>
                    &#8377;<c:out value="${bfee}"/> at the counter
                  </dd>
                </dl>
              </div>
            </c:otherwise>
          </c:choose>
        </div>

        <div class="card">
          <div class="card-head"><h3>Appointment held for</h3>
            <a class="btn btn-link btn-sm" href="${ctx}/profile">Update</a>
          </div>
          <div class="card-body">
            <dl class="kv">
              <dt>Name</dt><dd><c:out value="${patient.fullName}"/></dd>
              <dt>Patient ID</dt><dd class="mono"><c:out value="${patient.patientCode}"/></dd>
              <dt>Mobile</dt><dd class="mono">+91 <c:out value="${patient.phone}"/></dd>
              <dt>Blood group</dt><dd><c:out value="${empty patient.bloodGroup ? 'Not filled' : patient.bloodGroup}"/></dd>
              <dt>Allergies</dt><dd><c:out value="${empty patient.allergies ? 'None stated' : patient.allergies}"/></dd>
            </dl>
          </div>
        </div>

        <div class="card">
          <div class="card-head"><h3>Need help?</h3></div>
          <div class="card-body">
            <p style="font-size:13.5px; color:var(--ink-soft)">
              Call the desk on <c:out value="${site.phone}"/> between 9:00 AM and 7:00 PM, Monday to
              Saturday. They can move a booking when a doctor is on emergency leave.
            </p>
          </div>
        </div>
      </aside>
    </div>
  </div>
</div>

<jsp:include page="/WEB-INF/views/fragments/footer.jsp"/>
