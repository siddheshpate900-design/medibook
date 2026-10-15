<%@ page contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" %>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
<jsp:include page="/WEB-INF/views/fragments/header.jsp">
  <jsp:param name="title" value="Create an account"/>
</jsp:include>

<div class="auth-page">
  <div class="container" style="max-width:940px">
    <div class="auth-shell">
      <aside class="auth-aside">
        <div class="eyebrow">Step 1 of 2</div>
        <h2>Register once to hold a slot</h2>
        <p class="muted" style="font-size:13.5px">The clinic links every appointment to your mobile
          number, so it has to be a number you can show at the counter.</p>
        <div class="divider"></div>
        <h3 style="font-size:13.5px; margin-bottom:8px">Keep ready</h3>
        <ul>
          <li>A working mobile number (10 digits)</li>
          <li>An email id, used for the sign in</li>
          <li>The date of birth from an ID proof</li>
          <li>Blood group, only if you know it</li>
        </ul>
        <div class="divider"></div>
        <p style="font-size:13px; color:var(--muted)">
          By creating this account you agree to the
          <a href="${ctx}/privacy">privacy policy</a>. We never ask for Aadhaar, bank details or
          medical reports.
        </p>
      </aside>

      <div class="auth-main">
        <div class="auth-head">
          <h1>Create your patient account</h1>
          <p class="muted" style="font-size:14px">Fields marked with an asterisk are required.</p>
        </div>

        <form method="post" action="${ctx}/signup" novalidate>
          <fieldset>
            <legend>Patient details</legend>
            <div class="form-grid">
              <div class="field ${not empty errors.fullName ? 'is-invalid' : ''}">
                <label class="field-label req" for="fullName">Full name</label>
                <input class="control" type="text" id="fullName" name="fullName" maxlength="60"
                       autocomplete="name" value="<c:out value="${valFullName}"/>" required>
                <c:if test="${not empty errors.fullName}">
                  <p class="error-text"><c:out value="${errors.fullName}"/></p>
                </c:if>
              </div>

              <div class="field ${not empty errors.dob ? 'is-invalid' : ''}">
                <label class="field-label req" for="dob">Date of birth</label>
                <input class="control" type="date" id="dob" name="dob"
                       value="<c:out value="${valDob}"/>" max="${today}" required>
                <c:if test="${not empty errors.dob}">
                  <p class="error-text"><c:out value="${errors.dob}"/></p>
                </c:if>
              </div>

              <div class="field ${not empty errors.gender ? 'is-invalid' : ''}">
                <label class="field-label req" for="gender">Gender</label>
                <select class="control" id="gender" name="gender" required>
                  <option value="">Select</option>
                  <c:forEach var="g" items="${['Male','Female','Other']}">
                    <option value="${g}" ${g eq valGender ? 'selected="selected"' : ''}>${g}</option>
                  </c:forEach>
                </select>
                <c:if test="${not empty errors.gender}">
                  <p class="error-text"><c:out value="${errors.gender}"/></p>
                </c:if>
              </div>

              <div class="field ${not empty errors.bloodGroup ? 'is-invalid' : ''}">
                <label class="field-label" for="bloodGroup">Blood group</label>
                <select class="control" id="bloodGroup" name="bloodGroup">
                  <option value="">Not filled</option>
                  <c:forEach var="b" items="${['A+','A-','B+','B-','O+','O-','AB+','AB-']}">
                    <option value="${b}" ${b eq valBloodGroup ? 'selected="selected"' : ''}>${b}</option>
                  </c:forEach>
                </select>
                <p class="hint">Optional. Printed on the slip so the desk can find it fast.</p>
              </div>
            </div>
          </fieldset>

          <fieldset>
            <legend>Contact</legend>
            <div class="form-grid">
              <div class="field ${not empty errors.email ? 'is-invalid' : ''}">
                <label class="field-label req" for="email">Email address</label>
                <input class="control" type="email" id="email" name="email" maxlength="120"
                       autocomplete="email" value="<c:out value="${valEmail}"/>" required>
                <c:if test="${not empty errors.email}">
                  <p class="error-text"><c:out value="${errors.email}"/></p>
                </c:if>
              </div>

              <div class="field ${not empty errors.phone ? 'is-invalid' : ''}">
                <label class="field-label req" for="phone">Mobile number</label>
                <div class="input-group">
                  <span class="prefix">+91</span>
                  <input class="control" type="tel" id="phone" name="phone" inputmode="numeric"
                         maxlength="10" autocomplete="tel" value="<c:out value="${valPhone}"/>" required>
                </div>
                <c:if test="${not empty errors.phone}">
                  <p class="error-text"><c:out value="${errors.phone}"/></p>
                </c:if>
                <c:if test="${empty errors.phone}"><p class="hint">Ten digits, no spaces.</p></c:if>
              </div>

              <div class="field ${not empty errors.address ? 'is-invalid' : ''}">
                <label class="field-label" for="address">Address</label>
                <input class="control" type="text" id="address" name="address" maxlength="200"
                       autocomplete="street-address" value="<c:out value="${valAddress}"/>">
                <c:if test="${not empty errors.address}">
                  <p class="error-text"><c:out value="${errors.address}"/></p>
                </c:if>
              </div>

              <div class="field">
                <label class="field-label" for="city">City and PIN code</label>
                <div class="form-grid" style="gap:0 10px">
                  <input class="control" type="text" id="city" name="city" maxlength="60"
                         placeholder="Kolhapur" value="<c:out value="${valCity}"/>">
                  <input class="control" type="text" id="pincode" name="pincode" maxlength="6"
                         inputmode="numeric" placeholder="416001" value="<c:out value="${valPincode}"/>">
                </div>
                <c:if test="${not empty errors.pincode}">
                  <p class="error-text"><c:out value="${errors.pincode}"/></p>
                </c:if>
              </div>

              <div class="field span-2 ${not empty errors.allergies ? 'is-invalid' : ''}">
                <label class="field-label" for="allergies">Known drug allergies</label>
                <textarea class="control" id="allergies" name="allergies" maxlength="255"
                          placeholder="For example: penicillin rash in 2019"><c:out value="${valAllergies}"/></textarea>
                <c:if test="${not empty errors.allergies}">
                  <p class="error-text"><c:out value="${errors.allergies}"/></p>
                </c:if>
                <p class="hint">Optional. Shown to the doctor on their screen, not published anywhere.</p>
              </div>
            </div>
          </fieldset>

          <fieldset>
            <legend>Password</legend>
            <div class="form-grid">
              <div class="field ${not empty errors.password ? 'is-invalid' : ''}">
                <label class="field-label req" for="password">Choose a password</label>
                <input class="control" type="password" id="password" name="password" minlength="8"
                       maxlength="64" autocomplete="new-password" required
                       data-strength="pwMeter">
                <div class="pw-meter" id="pwMeter" aria-hidden="true"><span></span><span></span><span></span></div>
                <c:choose>
                  <c:when test="${not empty errors.password}">
                    <p class="error-text"><c:out value="${errors.password}"/></p>
                  </c:when>
                  <c:otherwise>
                    <p class="hint">At least 8 characters, with one letter and one digit.</p>
                  </c:otherwise>
                </c:choose>
              </div>

              <div class="field ${not empty errors.confirmPassword ? 'is-invalid' : ''}">
                <label class="field-label req" for="confirmPassword">Type it again</label>
                <input class="control" type="password" id="confirmPassword" name="confirmPassword"
                       minlength="8" maxlength="64" autocomplete="new-password" required>
                <c:if test="${not empty errors.confirmPassword}">
                  <p class="error-text"><c:out value="${errors.confirmPassword}"/></p>
                </c:if>
              </div>
            </div>
          </fieldset>

          <div class="field ${not empty errors.consent ? 'is-invalid' : ''}" style="margin-top:6px">
            <label class="check">
              <input type="checkbox" name="consent" value="yes">
              <span>I have read the <a href="${ctx}/privacy" target="_blank" rel="noopener">privacy
                policy</a> and allow <c:out value="${site.clinicName}"/> to keep these details for
                my appointments.</span>
            </label>
            <c:if test="${not empty errors.consent}">
              <p class="error-text"><c:out value="${errors.consent}"/></p>
            </c:if>
          </div>

          <div class="form-actions">
            <button class="btn btn-primary btn-lg" type="submit">Create account</button>
            <a class="btn btn-link" href="${ctx}/login">Already registered? Sign in</a>
          </div>
        </form>

        <p class="auth-foot">
          Step 2 is signing in. After the account is created you are sent back to the sign in page,
          so you can confirm that the password works.
        </p>
      </div>
    </div>
  </div>
</div>

<jsp:include page="/WEB-INF/views/fragments/footer.jsp"/>
