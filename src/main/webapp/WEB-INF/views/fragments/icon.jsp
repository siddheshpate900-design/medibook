<%@ page contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" %>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
<%--
    Small line icon set. Called as:
      <jsp:include page="/WEB-INF/views/fragments/icon.jsp">
        <jsp:param name="name" value="calendar"/>
        <jsp:param name="size" value="16"/>
      </jsp:include>
    Everything is drawn as an SVG path: no emoji and no icon font to download.
--%>
<svg width="${param.size}" height="${param.size}" viewBox="0 0 24 24" fill="none"
     stroke="currentColor" stroke-width="1.7" stroke-linecap="round" stroke-linejoin="round"
     aria-hidden="true" focusable="false">
<c:choose>
    <c:when test="${param.name eq 'calendar'}">
        <rect x="3" y="5" width="18" height="16" rx="2"/><path d="M8 3v4M16 3v4M3 10h18"/>
    </c:when>
    <c:when test="${param.name eq 'clock'}">
        <circle cx="12" cy="12" r="9"/><path d="M12 7v5l3.5 2"/>
    </c:when>
    <c:when test="${param.name eq 'user'}">
        <circle cx="12" cy="8" r="3.6"/><path d="M4.5 20c1.2-3.6 4-5.4 7.5-5.4s6.3 1.8 7.5 5.4"/>
    </c:when>
    <c:when test="${param.name eq 'logout'}">
        <path d="M15 4h3.5A1.5 1.5 0 0 1 20 5.5v13A1.5 1.5 0 0 1 18.5 20H15M10 8l-4 4 4 4M6 12h10"/>
    </c:when>
    <c:when test="${param.name eq 'print'}">
        <path d="M7 9V4h10v5M7 19H5a1 1 0 0 1-1-1v-6a1 1 0 0 1 1-1h14a1 1 0 0 1 1 1v6a1 1 0 0 1-1 1h-2"/>
        <rect x="7" y="15" width="10" height="6" rx="1"/>
    </c:when>
    <c:when test="${param.name eq 'plus'}">
        <path d="M12 5v14M5 12h14"/>
    </c:when>
    <c:when test="${param.name eq 'check'}">
        <path d="M4.5 12.5l5 5 10-11"/>
    </c:when>
    <c:when test="${param.name eq 'alert'}">
        <path d="M12 4l8.5 15H3.5L12 4zM12 10v4M12 16.5v.5"/>
    </c:when>
    <c:when test="${param.name eq 'shield'}">
        <path d="M12 3.5l7 2.5v5.5c0 4.3-2.9 7.4-7 8.5-4.1-1.1-7-4.2-7-8.5V6l7-2.5z"/><path d="M9 12l2 2 4-4"/>
    </c:when>
    <c:when test="${param.name eq 'info'}">
        <circle cx="12" cy="12" r="9"/><path d="M12 11v6M12 7.5v.5"/>
    </c:when>
    <c:when test="${param.name eq 'arrow-right'}">
        <path d="M5 12h13M13 7l5 5-5 5"/>
    </c:when>
    <c:when test="${param.name eq 'chevron-right'}">
        <path d="M9 5l7 7-7 7"/>
    </c:when>
    <c:when test="${param.name eq 'phone'}">
        <path d="M5.5 3.5h3l1.5 4-2 1.5a11 11 0 0 0 5 5l1.5-2 4 1.5v3a2 2 0 0 1-2.2 2A16 16 0 0 1 3.5 5.7 2 2 0 0 1 5.5 3.5z"/>
    </c:when>
    <c:when test="${param.name eq 'mail'}">
        <rect x="3" y="5" width="18" height="14" rx="2"/><path d="M3.5 6.5L12 13l8.5-6.5"/>
    </c:when>
    <c:when test="${param.name eq 'pin'}">
        <path d="M12 21c4.5-5 7-8.2 7-11.5A7 7 0 0 0 5 9.5C5 12.8 7.5 16 12 21z"/><circle cx="12" cy="9.5" r="2.4"/>
    </c:when>
    <c:when test="${param.name eq 'list'}">
        <path d="M8 6h13M8 12h13M8 18h13M3.5 6h.5M3.5 12h.5M3.5 18h.5"/>
    </c:when>
    <c:when test="${param.name eq 'cross'}">
        <path d="M10 3.5h4v6.5h6.5v4H14V20.5h-4V14H3.5v-4H10z"/>
    </c:when>
    <c:when test="${param.name eq 'clipboard'}">
        <rect x="5" y="4.5" width="14" height="16" rx="2"/><path d="M9 4.5V3h6v1.5M8.5 10h7M8.5 14h7M8.5 18h4"/>
    </c:when>
    <c:when test="${param.name eq 'search'}">
        <circle cx="11" cy="11" r="6.5"/><path d="M16 16l4.5 4.5"/>
    </c:when>
    <c:otherwise>
        <circle cx="12" cy="12" r="9"/>
    </c:otherwise>
</c:choose>
</svg>
