<%--
  Copyright (C) 2009-2010 StackFrame, LLC
  This code is licensed under GPLv2.
--%>

<%@page contentType="application/xhtml+xml" pageEncoding="UTF-8"%>
<%@taglib prefix="sql" uri="http://java.sun.com/jsp/jstl/sql" %>
<%@taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
<%@taglib prefix="fmt" uri="http://java.sun.com/jsp/jstl/fmt" %>
<%@taglib prefix="fn" uri="http://java.sun.com/jsp/jstl/functions" %>
<%@taglib prefix="du" uri="/WEB-INF/tlds/DateUtils" %>
<%@taglib prefix="sarariman" uri="/WEB-INF/tlds/sarariman" %>
<!DOCTYPE html PUBLIC "-//W3C//DTD XHTML 1.1//EN" "http://www.w3.org/TR/xhtml11/DTD/xhtml11.dtd">
<html xmlns="http://www.w3.org/1999/xhtml">
    <sql:setDataSource var="db" dataSource="jdbc/sarariman"/>
    <fmt:parseNumber var="project_id" value="${param.project}"/>
    <c:set var="project" value="${sarariman.projects[project_id]}"/>
    <c:set var="customer" value="${sarariman.customers[project.customer]}"/>
    <head>
        <link href="style.css" rel="stylesheet" type="text/css"/>
        <title>${fn:escapeXml(customer.name)} - ${fn:escapeXml(project.name)} - ${param.week}</title>
    </head>

    <body>
        <%@include file="header.jsp" %>
        <h1>${fn:escapeXml(customer.name)} - ${fn:escapeXml(project.name)} - ${param.week}</h1>

        <sql:query dataSource="jdbc/sarariman" var="result">
            SELECT DISTINCT h.employee
            FROM hours as h
            JOIN tasks AS t ON h.task = t.id
            JOIN projects AS p ON t.project = p.id
            WHERE p.id = ? AND h.date >= ? AND h.date < DATE_ADD(?, INTERVAL 7 DAY) AND h.duration > 0
            ORDER BY h.employee ASC
            <sql:param value="${param.project}"/>
            <sql:param value="${param.week}"/>
            <sql:param value="${param.week}"/>
        </sql:query>
        <ul>
            <c:forEach var="row" items="${result.rows}">
                <c:url var="html" value="timereport">
                    <c:param name="project" value="${param.project}"/>
                    <c:param name="week" value="${param.week}"/>
                    <c:param name="employee" value="${row.employee}"/>
                </c:url>
                <c:url var="pdf" value="${html}">
                    <c:param name="outputType" value="pdf"/>
                </c:url>
                <li><a href="${fn:escapeXml(html)}">${directory.byNumber[row.employee].fullName}</a>
                    <a href="${fn:escapeXml(pdf)}">[PDF]</a></li>
                </c:forEach>
        </ul>

        <p>Email will go to:</p>
        <sql:query dataSource="jdbc/sarariman" var="emailResult">
            SELECT email
            FROM project_emails as e
            JOIN projects AS p ON e.project = p.id
            WHERE p.id = ?
            <sql:param value="${param.project}"/>
        </sql:query>

        <ul>
            <c:forEach var="row" items="${emailResult.rows}"><li>${row.email}</li></c:forEach>
        </ul>

        <form action="${pageContext.request.contextPath}/PDFTimesheetBuilder" method="POST">
            <c:forEach var="row" items="${result.rows}">
                <c:url var="pdf" value="timereport">
                    <c:param name="project" value="${param.project}"/>
                    <c:param name="week" value="${param.week}"/>
                    <c:param name="employee" value="${row.employee}"/>
                    <c:param name="outputType" value="pdf"/>
                </c:url>
                <input type="hidden" name="employee" value="${directory.byNumber[row.employee].fullName}"/>
                <input type="hidden" name="pdf" value="${fn:escapeXml(pdf)}"/>
            </c:forEach>

            <input type="hidden" name="project" value="${fn:escapeXml(project.name)}"/>
            <input type="hidden" name="week" value="${param.week}"/>

            <c:forEach var="row" items="${emailResult.rows}">
                <input type="hidden" name="to" value="${row.email}"/>
            </c:forEach>

            <input type="hidden" name="cc" value="mcculley@stackframe.com"/>
            <input type="hidden" name="cc" value="awetteland@stackframe.com"/>

            <label for="testaddress">Test Address: </label><input type="text" id="testaddress" name="testaddress"/><br/>
            <input type="submit" value="Send"/>
        </form>

        <%@include file="footer.jsp" %>
    </body>
</html>
