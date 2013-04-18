<%--
  Copyright (C) 2012-2013 StackFrame, LLC
  This code is licensed under GPLv2.
--%>

<%@taglib prefix="sql" uri="http://java.sun.com/jsp/jstl/sql" %>
<%@taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
<%@page contentType="text/html" pageEncoding="UTF-8"%>
<!DOCTYPE html>
<html>
    <head>
        <meta http-equiv="Content-Type" content="text/html; charset=UTF-8">
        <title>Access Log</title>
        <link href="style/font-awesome.css" rel="stylesheet" type="text/css"/>
        <link href="style.css" rel="stylesheet" type="text/css"/>
    </head>
    <body>
        <%@include file="header.jsp" %>

        <h1>Access Log</h1>
        <h2>Activity for the last 24 hours</h2>

        <p>
            <sql:query dataSource="jdbc/sarariman" var="resultSet">
                SELECT COUNT(timestamp) AS hits FROM access_log WHERE timestamp > DATE_SUB(NOW(), INTERVAL 1 DAY) AND remote_address NOT LIKE '0:0:0:0:0:0:0:1%0'
            </sql:query>
            Hits: ${resultSet.rows[0].hits}<br/>

            <sql:query dataSource="jdbc/sarariman" var="resultSet">
                SELECT AVG(time) AS average FROM access_log WHERE timestamp > DATE_SUB(NOW(), INTERVAL 1 DAY) AND remote_address NOT LIKE '0:0:0:0:0:0:0:1%0'
            </sql:query>
            Average time: ${resultSet.rows[0].average}
        </p>

        <sql:query dataSource="jdbc/sarariman" var="resultSet">
            SELECT * FROM access_log WHERE timestamp > DATE_SUB(NOW(), INTERVAL 1 DAY) AND remote_address NOT LIKE '0:0:0:0:0:0:0:1%0' GROUP BY path ORDER BY time DESC, timestamp DESC LIMIT 5
        </sql:query>
        <table id="worstPerforming">
            <caption>Worst Performing Pages</caption>
            <tr>
                <th>Timestamp</th>
                <th>Remote Address</th>
                <th>Employee</th>
                <th>Status</th>
                <th>Path</th>
                <th>Query</th>
                <th>Method</th>
                <th>Time</th>
                <th>User Agent</th>
            </tr>
            <c:forEach var="row" items="${resultSet.rows}">
                <tr>
                    <td>${row.timestamp}</td>
                    <td>${row.remote_address}</td>
                    <td>
                        <c:if test="${!empty row.employee}">
                            ${directory.byNumber[row.employee].userName}
                        </c:if>
                    </td>
                    <td>${row.status}</td>
                    <c:set var="target" value="${row.path}"/>
                    <c:if test="${not empty row.query}">
                        <c:set var="target" value="${target}?${row.query}"/>
                    </c:if>
                    <td><a href="${target}">${row.path}</a></td>
                    <td><a href="${target}">${row.query}</a></td>
                    <td>${row.method}</td>
                    <td>${row.time}</td>
                    <td>${row.user_agent}</td>
                </tr>
            </c:forEach>
        </table>

        <sql:query dataSource="jdbc/sarariman" var="resultSet">
            SELECT DISTINCT(user_agent) FROM access_log WHERE timestamp > DATE_SUB(NOW(), INTERVAL 1 DAY) ORDER BY user_agent
        </sql:query>
        <h3>User Agents</h3>
        <ul>
            <c:forEach var="row" items="${resultSet.rows}">
                <li>${row.user_agent}</li>
            </c:forEach>
        </ul>

        <sql:query dataSource="jdbc/sarariman" var="resultSet">
            SELECT * FROM access_log WHERE timestamp > DATE_SUB(NOW(), INTERVAL 1 DAY) ORDER BY timestamp DESC
        </sql:query>
        <table id="dayEntries">
            <caption>All Entries</caption>
            <tr>
                <th>Timestamp</th>
                <th>Remote Address</th>
                <th>Employee</th>
                <th>Status</th>
                <th>Path</th>
                <th>Query</th>
                <th>Method</th>
                <th>Time</th>
                <th>User Agent</th>
            </tr>
            <c:forEach var="row" items="${resultSet.rows}">
                <tr>
                    <td>${row.timestamp}</td>
                    <td>${row.remote_address}</td>
                    <td>
                        <c:if test="${!empty row.employee}">
                            ${directory.byNumber[row.employee].userName}
                        </c:if>
                    </td>
                    <td>${row.status}</td>
                    <c:set var="target" value="${row.path}"/>
                    <c:if test="${not empty row.query}">
                        <c:set var="target" value="${target}?${row.query}"/>
                    </c:if>
                    <td><a href="${target}">${row.path}</a></td>
                    <td><a href="${target}">${row.query}</a></td>
                    <td>${row.method}</td>
                    <td>${row.time}</td>
                    <td>${row.user_agent}</td>
                </tr>
            </c:forEach>
        </table>

        <%@include file="footer.jsp" %>
    </body>
</html>