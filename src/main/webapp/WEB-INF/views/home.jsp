<%@ page contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" %>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
<%@ taglib prefix="fmt" uri="http://java.sun.com/jsp/jstl/fmt" %>
<jsp:include page="/WEB-INF/views/fragments/header.jsp">
  <jsp:param name="title" value="OPD appointment portal"/>
</jsp:include>

<section class="hero">
  <div class="container hero-inner">
    <div>
      <div class="eyebrow"><c:out value="${site.clinicName}"/></div>
      <h1>Take an OPD slot, get your token number, skip the registration counter queue.</h1>
      <p class="hero-sub">
        MediBook is the patient side of the clinic queue. You choose a department, pick a doctor
        who sits in OPD on that day, take one of the open half-hour slots and carry a printed slip
        to the counter. Booking an appointment costs nothing; the consultation fee is paid at the
        counter as usual.
      </p>
      <div class="hero-actions">
        <c:choose>
          <c:when test="${loggedIn}">
            <a class="btn btn-primary btn-lg" href="${ctx}/book">
              <jsp:include page="/WEB-INF/views/fragments/icon.jsp">
                <jsp:param name="name" value="plus"/><jsp:param name="size" value="16"/>
              </jsp:include>
              Book an appointment
            </a>
            <a class="btn btn-secondary btn-lg" href="${ctx}/dashboard">Go to my dashboard</a>
          </c:when>
          <c:otherwise>
            <a class="btn btn-primary btn-lg" href="${ctx}/signup">
              <jsp:include page="/WEB-INF/views/fragments/icon.jsp">
                <jsp:param name="name" value="user"/><jsp:param name="size" value="16"/>
              </jsp:include>
              Create an account
            </a>
            <a class="btn btn-secondary btn-lg" href="${ctx}/login">I already have an account</a>
          </c:otherwise>
        </c:choose>
      </div>
      <p class="hero-note">
        Accounts hold your name, contact number and the appointments you book. No reports,
        no payments and no test results are stored.
        <a href="${ctx}/privacy">Read the privacy policy</a>.
      </p>
    </div>

    <div class="board">
      <div class="board-head">
        <h2>Today&rsquo;s OPD board</h2>
        <span class="muted" style="font-size:13px">
          <fmt:formatDate value="${todayDate}" pattern="EEE, d MMM yyyy"/>
        </span>
      </div>
      <c:choose>
        <c:when test="${empty todayDoctors}">
          <div class="empty">
            No doctor has OPD hours on <fmt:formatDate value="${todayDate}" pattern="EEEE"/>.
            Bookings for the next working day stay open on the booking page.
          </div>
        </c:when>
        <c:otherwise>
          <c:forEach var="d" items="${todayDoctors}">
            <div class="board-row">
              <div style="min-width:0">
                <div class="table-title"><c:out value="${d.doctorName}"/></div>
                <div class="dept"><c:out value="${d.departmentName}"/> &middot; Room <c:out value="${d.roomNo}"/></div>
              </div>
              <div class="spacer"></div>
              <div class="right" style="flex:0 0 auto">
                <div class="mono" style="font-size:13px"><c:out value="${d.timingsText}"/></div>
                <div style="font-size:12.5px">
                  <c:choose>
                    <c:when test="${d.openSlotsToday > 0}">
                      <span class="tag tag-ok"><c:out value="${d.openSlotsToday}"/> slots open</span>
                    </c:when>
                    <c:otherwise>
                      <span class="tag tag-muted">Fully booked</span>
                    </c:otherwise>
                  </c:choose>
                </div>
              </div>
            </div>
          </c:forEach>
        </c:otherwise>
      </c:choose>
      <div class="board-foot">
        Counts are read live from the <code>appointments</code> table, so a slot taken a minute ago
        is already removed from this list.
      </div>
    </div>
  </div>
</section>

<section class="section" id="how">
  <div class="container">
    <div class="section-head">
      <div>
        <div class="eyebrow">How it works</div>
        <h2>Four steps, and the record keeps itself</h2>
      </div>
      <p>The same flow is used on the phone and on the desktop. Nothing is emailed to you, the
        appointment stays in your account.</p>
    </div>

    <div class="grid grid-4">
      <div class="card">
        <div class="card-body">
          <div class="feature">
            <span class="step-num">1</span>
            <div>
              <h3>Create an account</h3>
              <p class="muted" style="font-size:13.5px">Name, mobile number, email and a password.
                The mobile number also works as a login id, which helps when a patient does not use
                email often.</p>
            </div>
          </div>
        </div>
      </div>
      <div class="card">
        <div class="card-body">
          <div class="feature">
            <span class="step-num">2</span>
            <div>
              <h3>Choose department and doctor</h3>
              <p class="muted" style="font-size:13.5px">Only the doctors who sit in OPD on the date
                you pick are offered. The fee and room number are shown before you confirm.</p>
            </div>
          </div>
        </div>
      </div>
      <div class="card">
        <div class="card-body">
          <div class="feature">
            <span class="step-num">3</span>
            <div>
              <h3>Take an open slot</h3>
              <p class="muted" style="font-size:13.5px">Slots are generated from the doctor&rsquo;s
                start time, end time and sitting length. Booked and past slots are never listed.</p>
            </div>
          </div>
        </div>
      </div>
      <div class="card">
        <div class="card-body">
          <div class="feature">
            <span class="step-num">4</span>
            <div>
              <h3>Carry the slip</h3>
              <p class="muted" style="font-size:13.5px">The confirmation page prints a slip with the
                token number, room and time. Cancel from the dashboard and the slot opens again.</p>
            </div>
          </div>
        </div>
      </div>
    </div>
  </div>
</section>

<section class="section section-alt" id="departments">
  <div class="container">
    <div class="section-head">
      <div>
        <div class="eyebrow">Departments</div>
        <h2>Which OPD are you coming to?</h2>
      </div>
      <p>Fees below are the range quoted by the doctors of that department. Selecting a card opens
        the booking form with that department already chosen.</p>
    </div>

    <div class="grid grid-3">
      <c:forEach var="dep" items="${departments}">
        <a class="dept-card" href="${ctx}/${loggedIn ? 'book' : 'signup'}?department=${dep.departmentId}">
          <h3><c:out value="${dep.departmentName}"/></h3>
          <p><c:out value="${dep.description}"/></p>
          <div class="dept-meta">
            <span><c:out value="${dep.doctorCount}"/> doctors</span>
            <c:if test="${not empty dep.minFee}">
              <span>
                <fmt:formatNumber value="${dep.minFee}" maxFractionDigits="0" var="lo"/>
                <fmt:formatNumber value="${dep.maxFee}" maxFractionDigits="0" var="hi"/>
                &#8377;<c:out value="${lo}"/> to &#8377;<c:out value="${hi}"/>
              </span>
            </c:if>
          </div>
        </a>
      </c:forEach>
    </div>
  </div>
</section>

<section class="section" id="doctors">
  <div class="container">
    <div class="section-head">
      <div>
        <div class="eyebrow">Doctor list</div>
        <h2>Fixed OPD timings, printed as they are in the clinic</h2>
      </div>
      <p>This table is read from the <code>doctors</code> table. The clinic office updates it,
        patients only read it.</p>
    </div>

    <div class="card card-body-flush table-wrap">
      <table class="table">
        <caption style="padding:14px 14px 0">Consultation fee is charged by the clinic counter at the time of the visit.</caption>
        <thead>
        <tr>
          <th scope="col">Doctor</th>
          <th scope="col">Department</th>
          <th scope="col">Qualification</th>
          <th scope="col" class="num">Years</th>
          <th scope="col">Sits in OPD</th>
          <th scope="col">Timings</th>
          <th scope="col" class="num">Fee</th>
        </tr>
        </thead>
        <tbody>
        <c:forEach var="d" items="${doctors}">
          <tr>
            <td>
              <div class="table-title"><c:out value="${d.doctorName}"/></div>
              <div class="muted" style="font-size:12.5px">Room <c:out value="${d.roomNo}"/></div>
            </td>
            <td><c:out value="${d.departmentName}"/></td>
            <td class="muted"><c:out value="${d.qualification}"/></td>
            <td class="num"><c:out value="${d.experienceYears}"/></td>
            <td class="muted" style="font-size:13px"><c:out value="${d.availableDays}"/></td>
            <td class="mono" style="font-size:13px"><c:out value="${d.timingsText}"/></td>
            <td class="num">
              <fmt:formatNumber value="${d.consultationFee}" maxFractionDigits="0" var="fee"/>
              &#8377;<c:out value="${fee}"/>
            </td>
          </tr>
        </c:forEach>
        </tbody>
      </table>
    </div>
  </div>
</section>

<section class="section section-alt">
  <div class="container">
    <div class="grid grid-2">
      <div class="card">
        <div class="card-head">
          <h2>What an account holds</h2>
        </div>
        <div class="card-body">
          <dl class="definition">
            <dt>Given by you</dt>
            <dd>Name, mobile number, email, password, date of birth, gender and, if you fill them,
              address, blood group and known allergies.</dd>
            <dt>Written by the clinic</dt>
            <dd>Department, doctor, date, time, token number and the status of each visit.</dd>
            <dt>How the password is kept</dt>
            <dd>A salted PBKDF2 hash. The plain password is not stored anywhere, so it cannot be
              read out of the database.</dd>
          </dl>
        </div>
      </div>
      <div class="card">
        <div class="card-head">
          <h2>What this portal does not do</h2>
        </div>
        <div class="card-body">
          <ul style="margin:0; padding-left:18px; color:var(--ink-soft); font-size:14.5px">
            <li>No online payment. The fee is paid at the counter, so no card or UPI detail is taken.</li>
            <li>No prescriptions, reports or scan images are uploaded or stored.</li>
            <li>No ratings, comments or reviews are collected from patients.</li>
            <li>No diagnosis. A doctor examines you in person; the portal only holds the slot.</li>
          </ul>
          <div class="divider"></div>
          <p class="muted" style="font-size:13.5px">
            Full details of collection, storage and deletion are in the
            <a href="${ctx}/privacy">privacy policy</a>.
          </p>
        </div>
      </div>
    </div>
  </div>
</section>

<section class="section">
  <div class="container">
    <div class="card">
      <div class="card-body" style="display:flex; gap:20px; align-items:center; flex-wrap:wrap; padding:26px">
        <div style="flex:1 1 320px">
          <h2 style="margin-bottom:6px">Sign up once, book for the family later</h2>
          <p class="muted" style="font-size:14.5px">One account holds every appointment booked from it,
            which is what the dashboard lists under consultation history.</p>
        </div>
        <div class="row-flex">
          <c:choose>
            <c:when test="${loggedIn}">
              <a class="btn btn-primary" href="${ctx}/book">Book an appointment</a>
              <a class="btn btn-secondary" href="${ctx}/profile">Update my profile</a>
            </c:when>
            <c:otherwise>
              <a class="btn btn-primary" href="${ctx}/signup">Create an account</a>
              <a class="btn btn-secondary" href="${ctx}/login">Sign in</a>
            </c:otherwise>
          </c:choose>
        </div>
      </div>
    </div>
  </div>
</section>

<jsp:include page="/WEB-INF/views/fragments/footer.jsp"/>
