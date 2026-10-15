<%@ page contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" %>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
<%@ taglib prefix="fmt" uri="http://java.sun.com/jsp/jstl/fmt" %>
<jsp:include page="/WEB-INF/views/fragments/header.jsp">
  <jsp:param name="title" value="My profile"/>
</jsp:include>

<div class="page-bar">
  <div class="container page-bar-inner">
    <div>
      <h1>My profile</h1>
      <div class="sub">
        Patient ID <span class="mono"><c:out value="${patient.patientCode}"/></span>
        <c:if test="${not empty patient.createdAt}">
          &middot; registered on
          <fmt:formatDate value="${patient.createdAt}" dateStyle="medium"/>
        </c:if>
      </div>
    </div>
    <a class="btn btn-secondary" href="${ctx}/dashboard">Back to dashboard</a>
  </div>
</div>

<div class="page-body">
  <div class="container container-narrow">

    <div class="card">
      <div class="card-head">
        <h2>Details the counter uses</h2>
        <span class="muted" style="font-size:12.5px">email and mobile must stay reachable</span>
      </div>
      <div class="card-body">
        <form method="post" action="${ctx}/profile" novalidate>
          <input type="hidden" name="csrf" value="${csrfToken}">
          <input type="hidden" name="action" value="details">

          <fieldset>
            <legend>Patient</legend>
            <div class="form-grid">
              <div class="field ${not empty errors.fullName ? 'is-invalid' : ''}">
                <label class="field-label req" for="fullName">Full name</label>
                <input class="control" type="text" id="fullName" name="fullName" maxlength="60"
                       value="<c:out value="${patient.fullName}"/>" required>
                <c:if test="${not empty errors.fullName}">
                  <p class="error-text"><c:out value="${errors.fullName}"/></p>
                </c:if>
              </div>

              <div class="field ${not empty errors.dob ? 'is-invalid' : ''}">
                <label class="field-label" for="dob">Date of birth</label>
                <input class="control" type="date" id="dob" name="dob" max="${today}"
                       value="<c:out value="${patient.dob}"/>">
                <c:if test="${not empty errors.dob}">
                  <p class="error-text"><c:out value="${errors.dob}"/></p>
                </c:if>
                <c:if test="${empty errors.dob && age > 0}">
                  <p class="hint">Age <c:out value="${age}"/> years on the day of the visit.</p>
                </c:if>
              </div>

              <div class="field ${not empty errors.gender ? 'is-invalid' : ''}">
                <label class="field-label req" for="gender">Gender</label>
                <select class="control" id="gender" name="gender" required>
                  <c:forEach var="g" items="${['Male','Female','Other']}">
                    <option value="${g}" ${g eq patient.gender ? 'selected="selected"' : ''}>${g}</option>
                  </c:forEach>
                </select>
              </div>

              <div class="field ${not empty errors.bloodGroup ? 'is-invalid' : ''}">
                <label class="field-label" for="bloodGroup">Blood group</label>
                <select class="control" id="bloodGroup" name="bloodGroup">
                  <option value="">Not filled</option>
                  <c:forEach var="b" items="${['A+','A-','B+','B-','O+','O-','AB+','AB-']}">
                    <option value="${b}" ${b eq patient.bloodGroup ? 'selected="selected"' : ''}>${b}</option>
                  </c:forEach>
                </select>
                <c:if test="${not empty errors.bloodGroup}">
                  <p class="error-text"><c:out value="${errors.bloodGroup}"/></p>
                </c:if>
              </div>
            </div>
          </fieldset>

          <fieldset>
            <legend>Contact</legend>
            <div class="form-grid">
              <div class="field ${not empty errors.email ? 'is-invalid' : ''}">
                <label class="field-label req" for="email">Email address</label>
                <input class="control" type="email" id="email" name="email" maxlength="120"
                       value="<c:out value="${patient.email}"/>" required>
                <c:if test="${not empty errors.email}">
                  <p class="error-text"><c:out value="${errors.email}"/></p>
                </c:if>
                <p class="hint">This is what you type in the sign in box.</p>
              </div>

              <div class="field ${not empty errors.phone ? 'is-invalid' : ''}">
                <label class="field-label req" for="phone">Mobile number</label>
                <div class="input-group">
                  <span class="prefix">+91</span>
                  <input class="control" type="tel" id="phone" name="phone" inputmode="numeric"
                         maxlength="10" value="<c:out value="${patient.phone}"/>" required>
                </div>
                <c:if test="${not empty errors.phone}">
                  <p class="error-text"><c:out value="${errors.phone}"/></p>
                </c:if>
              </div>

              <div class="field span-2 ${not empty errors.address ? 'is-invalid' : ''}">
                <label class="field-label" for="address">Address</label>
                <input class="control" type="text" id="address" name="address" maxlength="200"
                       value="<c:out value="${patient.address}"/>">
                <c:if test="${not empty errors.address}">
                  <p class="error-text"><c:out value="${errors.address}"/></p>
                </c:if>
              </div>

              <div class="field ${not empty errors.city ? 'is-invalid' : ''}">
                <label class="field-label" for="city">City</label>
                <input class="control" type="text" id="city" name="city" maxlength="60"
                       value="<c:out value="${patient.city}"/>">
              </div>

              <div class="field ${not empty errors.pincode ? 'is-invalid' : ''}">
                <label class="field-label" for="pincode">PIN code</label>
                <input class="control" type="text" id="pincode" name="pincode" maxlength="6"
                       inputmode="numeric" value="<c:out value="${patient.pincode}"/>">
                <c:if test="${not empty errors.pincode}">
                  <p class="error-text"><c:out value="${errors.pincode}"/></p>
                </c:if>
              </div>
            </div>
          </fieldset>

          <div class="field">
            <label class="field-label" for="allergies">Known drug allergies</label>
            <textarea class="control" id="allergies" name="allergies" maxlength="255"
                      placeholder="Leave empty if none are known"><c:out value="${patient.allergies}"/></textarea>
          </div>

          <div class="form-actions">
            <button class="btn btn-primary" type="submit">Save changes</button>
            <a class="btn btn-link" href="${ctx}/profile">Undo what I have typed</a>
          </div>
        </form>
      </div>
    </div>

    <div class="card" id="password">
      <div class="card-head">
        <h2>Change password</h2>
        <c:if test="${not empty passwordTab}"><span class="tag tag-danger">Check the form below</span></c:if>
      </div>
      <div class="card-body">
        <form method="post" action="${ctx}/profile" novalidate>
          <input type="hidden" name="csrf" value="${csrfToken}">
          <input type="hidden" name="action" value="password">
          <div class="form-grid-3">
            <div class="field ${not empty errors.currentPassword ? 'is-invalid' : ''}">
              <label class="field-label req" for="currentPassword">Current password</label>
              <input class="control" type="password" id="currentPassword" name="currentPassword"
                     autocomplete="current-password" required>
              <c:if test="${not empty errors.currentPassword}">
                <p class="error-text"><c:out value="${errors.currentPassword}"/></p>
              </c:if>
            </div>
            <div class="field ${not empty errors.newPassword ? 'is-invalid' : ''}">
              <label class="field-label req" for="newPassword">New password</label>
              <input class="control" type="password" id="newPassword" name="newPassword" minlength="8"
                     maxlength="64" autocomplete="new-password" data-strength="newPwMeter" required>
              <div class="pw-meter" id="newPwMeter" aria-hidden="true"><span></span><span></span><span></span></div>
              <c:if test="${not empty errors.newPassword}">
                <p class="error-text"><c:out value="${errors.newPassword}"/></p>
              </c:if>
              <c:if test="${empty errors.newPassword}">
                <p class="hint">8 characters, one letter, one digit.</p>
              </c:if>
            </div>
            <div class="field ${not empty errors.confirmPassword ? 'is-invalid' : ''}">
              <label class="field-label req" for="confirmPassword">Repeat new password</label>
              <input class="control" type="password" id="confirmPassword" name="confirmPassword"
                     minlength="8" maxlength="64" autocomplete="new-password" required>
              <c:if test="${not empty errors.confirmPassword}">
                <p class="error-text"><c:out value="${errors.confirmPassword}"/></p>
              </c:if>
            </div>
          </div>
          <div class="form-actions">
            <button class="btn btn-primary" type="submit">Update password</button>
            <span class="hint" style="margin:0">
              The old password stops working the moment this is saved.
            </span>
          </div>
        </form>
      </div>
    </div>

    <div class="card">
      <div class="card-head"><h3>Account status</h3></div>
      <div class="card-body">
        <dl class="kv">
          <dt>Registered</dt>
          <dd>
            <c:choose>
              <c:when test="${not empty patient.createdAt}">
                <fmt:formatDate value="${patient.createdAt}" type="both" dateStyle="long" timeStyle="short"/>
              </c:when>
              <c:otherwise>Not recorded</c:otherwise>
            </c:choose>
          </dd>
          <dt>Last sign in</dt>
          <dd>
            <c:choose>
              <c:when test="${not empty patient.lastLoginAt}">
                <fmt:formatDate value="${patient.lastLoginAt}" type="both" dateStyle="medium" timeStyle="short"/>
              </c:when>
              <c:otherwise>This is the first session</c:otherwise>
            </c:choose>
          </dd>
          <dt>Password</dt>
          <dd>Stored as a salted PBKDF2 hash, never as plain text</dd>
          <dt>Deleting the account</dt>
          <dd>Ask the desk in person. The row in <code>patients</code> and the appointment rows are removed together.</dd>
        </dl>
      </div>
    </div>
  </div>
</div>

<jsp:include page="/WEB-INF/views/fragments/footer.jsp"/>
