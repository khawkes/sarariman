<%--
  Copyright (C) 2012 StackFrame, LLC
  This code is licensed under GPLv2.
--%>

<%@page contentType="application/xhtml+xml" pageEncoding="UTF-8"%>
<%@taglib prefix="sql" uri="http://java.sun.com/jsp/jstl/sql" %>
<%@taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
<%@taglib prefix="fmt" uri="http://java.sun.com/jsp/jstl/fmt" %>

<!DOCTYPE html PUBLIC "-//W3C//DTD XHTML 1.1//EN" "http://www.w3.org/TR/xhtml11/DTD/xhtml11.dtd">
<html xmlns="http://www.w3.org/1999/xhtml">
    <head>
        <link href="style.css" rel="stylesheet" type="text/css"/>
        <title>Stats</title>
    </head>
    <body>
        <%@include file="header.jsp" %>
        <h1>Stats</h1>      

        <!--
        how long in operation
        total with clearances?
        total with degrees?
        -->

        <c:set var="totalEmployees" value="0"/>
        <c:set var="totalFullTime" value="0"/>
        <c:set var="totalPartTime" value="0"/>
        <c:forEach var="e" items="${directory.byUserName}">
            <c:set var="employee" value="${e.value}"/>
            <c:if test="${employee.active}">
                <c:set var="totalEmployees" value="${totalEmployees + 1}"/>
                <c:choose>
                    <c:when test="${employee.fulltime}">
                        <c:set var="totalFullTime" value="${totalFullTime + 1}"/>                        
                    </c:when>
                    <c:otherwise>
                        <c:set var="totalPartTime" value="${totalPartTime + 1}"/>                                                
                    </c:otherwise>
                </c:choose>
            </c:if>
        </c:forEach>
        
        <table>
            <caption>Employees</caption>
            <tr><th>Type</th><th>Total</th></tr>
            <tr><td>Full Time</td><td>${totalFullTime}</td></tr>
            <tr><td>Part Time</td><td>${totalPartTime}</td></tr>
            <tr><td>Total</td><td>${totalEmployees}</td></tr>
        </table>

        <%@include file="footer.jsp" %>
    </body>
</html>
