<%@ page contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" %>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
<jsp:include page="/WEB-INF/views/fragments/header.jsp">
  <jsp:param name="title" value="Privacy policy"/>
</jsp:include>

<div class="page-bar">
  <div class="container page-bar-inner">
    <div>
      <h1>Privacy policy</h1>
      <div class="sub">Last updated October 2026 &middot; applies to this portal and the MySQL database behind it</div>
    </div>
    <a class="btn btn-secondary" href="${ctx}/signup">Back to sign up</a>
  </div>
</div>

<div class="page-body">
  <div class="container container-narrow prose">

    <p class="lead">
      This page says what <c:out value="${site.productName}"/> records about you, why the clinic needs
      it, who can look at it and how you get it corrected or removed. It is written for the patients
      of <c:out value="${site.clinicName}"/> and for the evaluators of this course project.
    </p>

    <h2>1. Who runs this portal</h2>
    <p>
      The portal is developed and maintained by the project team named below for
      <c:out value="${site.college}"/>. In the demo the clinic data is sample data. If the portal is
      used by a real clinic, the clinic becomes the data fiduciary and this page is issued in its name.
    </p>
    <dl class="kv">
      <dt>Team</dt><dd>Firstname Lastname (Roll No. _), Firstname Lastname (Roll No. _), Firstname Lastname (Roll No. _)</dd>
      <dt>Supervisor</dt><dd>Mrs. Asitha Nadar</dd>
      <dt>Grievance contact</dt><dd><c:out value="${site.email}"/> &middot; <c:out value="${site.phone}"/></dd>
    </dl>

    <h2>2. What we collect and why</h2>
    <div class="card card-body-flush table-wrap" style="margin:14px 0 18px">
      <table class="table doc-table">
        <thead>
        <tr><th scope="col">Field</th><th scope="col">Why it is needed</th><th scope="col">Who sees it</th></tr>
        </thead>
        <tbody>
        <tr>
          <td>Name, gender, date of birth</td>
          <td>To match the person at the counter with the booking, and to write the token slip.</td>
          <td>Clinic desk, the doctor on duty</td>
        </tr>
        <tr>
          <td>Mobile number, email address</td>
          <td>To sign you in, to reach you if a doctor goes on emergency leave.</td>
          <td>Clinic desk only</td>
        </tr>
        <tr>
          <td>Address, PIN code</td>
          <td>Optional. Used only when the desk has to print your address on a record.</td>
          <td>Clinic desk only</td>
        </tr>
        <tr>
          <td>Blood group, known allergies</td>
          <td>Optional. Shown to the doctor so that an unsafe medicine is not prescribed.</td>
          <td>Your doctor</td>
        </tr>
        <tr>
          <td>Complaint text on the booking form</td>
          <td>Tells the doctor what the visit is about before you are called in.</td>
          <td>Your doctor</td>
        </tr>
        <tr>
          <td>Appointment rows</td>
          <td>Date, time, token, status. This is what the dashboard and the history table read.</td>
          <td>You, the desk, your doctor</td>
        </tr>
        </tbody>
      </table>
    </div>

    <h2>3. What we do not collect</h2>
    <ul>
      <li>No password in plain text. Only a salted PBKDF2 hash is written to the database.</li>
      <li>No Aadhaar number, no PAN, no passport detail.</li>
      <li>No bank account, card or UPI information. There is no payment on this portal.</li>
      <li>No prescriptions, lab reports, scan images or diagnosis notes.</li>
      <li>No advertising tracker, analytics script or third party pixel. The page loads no file from
        outside this application, so the browser asks nothing else on the internet while you use it.</li>
    </ul>

    <h2>4. How the data is kept</h2>
    <p>
      Records are stored in a MySQL database named <code>medibook</code> on the same server that runs
      the portal, inside the clinic network. Tables are reached only by the application through JDBC
      with prepared statements; no page can be opened without signing in, except the landing page and
      this policy.
    </p>
    <ul>
      <li>Every page after sign in is behind a filter that checks the session and a CSRF token on each form.</li>
      <li>The session ends after 20 minutes of no activity, and the browser is told not to cache those pages.</li>
      <li>A new session id is issued at sign in, so a link copied from another machine cannot reuse a session.</li>
      <li>The sign in form waits after six wrong passwords, which slows down guessing.</li>
      <li>A patient can read and cancel only their own appointments; the patient id in the session is
        part of every query.</li>
    </ul>

    <h2>5. Cookies</h2>
    <p>
      One cookie is used: <code>JSESSIONID</code>, marked HttpOnly, which keeps your session alive while
      you are signed in. No cookie is set for tracking, personalisation or advertising, and no cookie
      is shared with another website. Clearing cookies or closing the browser signs you out.
    </p>

    <h2>6. Sharing</h2>
    <p>
      Your record is not sold, rented or handed to any company. It is shown to the clinic desk and to
      the doctor you are booked with, and it may be inspected by the project guide and the university
      evaluator while the academic demonstration is being assessed. If a government authority asks for
      records, the clinic handles that request, not this portal.
    </p>

    <h2>7. How long we keep it</h2>
    <p>
      Appointment rows are kept so that you can see your own history. A cancelled or completed row is
      never edited, only kept. You may ask for your account to be removed; the account row and your
      appointment rows are then deleted together by a cascade delete on the <code>patients</code> table.
      A backup taken before that date is overwritten when the next backup cycle runs.
    </p>

    <h2>8. Your choices</h2>
    <ul>
      <li><strong>Correct a detail</strong> at any time from the Profile page. Nothing needs the desk&rsquo;s help except a forgotten password.</li>
      <li><strong>Cancel a booking</strong> from the dashboard while the slot is still in the future; the slot goes back to the list for other patients.</li>
      <li><strong>Ask for a copy</strong> of your appointment rows by writing to the grievance contact above.</li>
      <li><strong>Ask for deletion</strong> of the account. The desk will confirm it in person against an ID.</li>
    </ul>
    <p>
      These choices follow the Digital Personal Data Protection Act, 2023, which gives a user the right
      to access, correct and remove personal data, and asks the data fiduciary to keep collection
      limited to what the purpose needs. Only the fields in section 2 are collected, and each one has a
      purpose on this page.
    </p>

    <h2>9. If something goes wrong</h2>
    <p>
      Should you notice that another person has seen your record, sign out from every device by closing
      the browser, change the password from the Profile page and tell the desk on
      <c:out value="${site.phone}"/>. The portal does not keep an audit log of who viewed a profile, so
      the desk checks the server access log in such a case.
    </p>

    <h2>10. Changes to this page</h2>
    <p>
      If a new field is added to sign up, this page is changed in the same release and the date at the
      top is updated. Continued use of the portal after that means the new page applies.
    </p>

    <div class="card" style="margin-top:24px">
      <div class="card-body">
        <h3 style="margin-bottom:6px">Academic project notice</h3>
        <p class="muted" style="font-size:13.5px">
          <c:out value="${site.projectNote}"/> Names, mobile numbers and emails entered for the college
          demonstration are removed at the end of the evaluation. Do not register here with a real
          medical complaint unless the clinic has told you the portal is live.
        </p>
      </div>
    </div>
  </div>
</div>

<jsp:include page="/WEB-INF/views/fragments/footer.jsp"/>
