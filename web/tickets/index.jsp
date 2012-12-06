<%--
  Copyright (C) 2012 StackFrame, LLC
  This code is licensed under GPLv2.
--%>

<%@page contentType="application/xhtml+xml" pageEncoding="UTF-8"%>
<%@taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
<%@taglib prefix="fn" uri="http://java.sun.com/jsp/jstl/functions" %>
<%@taglib prefix="sarariman" uri="/WEB-INF/tlds/sarariman" %>

<jsp:useBean id="tickets" class="com.stackframe.sarariman.tickets.TicketsImpl"/>

<!DOCTYPE html PUBLIC "-//W3C//DTD XHTML 1.1//EN" "http://www.w3.org/TR/xhtml11/DTD/xhtml11.dtd">
<html xmlns="http://www.w3.org/1999/xhtml">
    <head>
        <link href="../style.css" rel="stylesheet" type="text/css"/>
        <title>Tickets</title>
        <script type="text/javascript" src="../utilities.js"/>
    </head>
    <body onload="altRows()">
        <%@include file="../header.jsp" %>
        <h1>Tickets</h1>

        <a href="create">Create a Ticket</a>
        <br/>
        <br/>

        <form method="GET">
            <label for="assignee">Assignee:</label>
            <select name="assignee" id="assignee">
                <option value="" <c:if test="${empty param.assignee}">selected="selected"</c:if>></option>
                <c:forEach var="e" items="${directory.byUserName}">
                    <c:if test="${e.value.active}">
                        <option value="${e.value.number}" <c:if test="${param.assignee eq e.value.number}">selected="selected"</c:if>>${e.value.displayName}</option>
                    </c:if>
                </c:forEach>
            </select>

            <label for="status">Status:</label>
            <select name="status" id="status">
                <option value="" <c:if test="${empty param.status}">selected="selected"</c:if>></option>
                <c:forEach var="type" items="${tickets.statusTypes}">
                    <option value="${type}" <c:if test="${param.status eq type}">selected="selected"</c:if>>${type}</option>
                </c:forEach>
            </select>

            <label for="notStatus">Not Status:</label>
            <select name="notStatus" id="notStatus">
                <option value="" <c:if test="${empty param.notStatus}">selected="selected"</c:if>></option>
                <c:forEach var="type" items="${tickets.statusTypes}">
                    <option value="${type}" <c:if test="${param.notStatus eq type}">selected="selected"</c:if>>${type}</option>
                </c:forEach>
            </select>

            <!-- FIXME: Use some JavaScript to make these pickers exclusive. -->

            <input type="submit" value="Search"/>
        </form>

        <table class="altrows">
            <tr>
                <th>#</th>
                <th>Name</th>
                <th>Status</th>
                <th>Creator</th>
                <th>Assignee</th>
            </tr>
            <c:forEach var="ticket" items="${tickets.all}">
                <c:url var="ticketViewURL" value="${ticket.id}"/>

                <c:set var="skip" value="false"/>

                <c:if test="${not empty param.status and param.status ne ticket.status}">
                    <c:set var="skip" value="true"/>
                </c:if>

                <c:if test="${not empty param.notStatus and param.notStatus eq ticket.status}">
                    <c:set var="skip" value="true"/>
                </c:if>

                <c:if test="${not empty param.assignee}">
                    <c:set var="assigneeEmployee" value="${directory.byNumber[param.assignee]}"/>
                    <c:if test="${not sarariman:contains(ticket.assignees, assigneeEmployee)}">
                        <c:set var="skip" value="true"/>
                    </c:if>
                </c:if>

                <c:if test="${not skip}">
                    <tr>
                        <td><a href="${ticketViewURL}">${ticket.id}</a></td>
                        <td><a href="${ticketViewURL}">${fn:escapeXml(ticket.name)}</a></td>
                        <td><a href="${ticketViewURL}">${ticket.status}</a></td>
                        <td>${ticket.employeeCreator.displayName}</td>
                        <td>
                            <c:set var="assignees" value="${ticket.assignees}"/>
                            <c:choose>
                                <c:when test="${fn:length(assignees) == 1}">
                                    ${assignees[0].displayName}
                                </c:when>
                                <c:otherwise>
                                    <ul>
                                        <c:forEach var="assignee" items="${assignees}">
                                            <li>${assignee.displayName}</li>
                                        </c:forEach>
                                    </ul>                                    
                                </c:otherwise>
                            </c:choose>
                        </td>
                    </tr>
                </c:if>
            </c:forEach>
        </table>

        <%@include file="../footer.jsp" %>
    </body>
</html>
