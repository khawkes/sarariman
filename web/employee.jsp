<%--
  Copyright (C) 2009-2010 StackFrame, LLC
  This code is licensed under GPLv2.
--%>

<%@page import="java.util.Collection,com.stackframe.sarariman.Sarariman,com.stackframe.sarariman.Employee"%>
<%@page contentType="application/xhtml+xml" pageEncoding="UTF-8"%>
<%@taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
<%@taglib prefix="du" uri="/WEB-INF/tlds/DateUtils" %>
<%@taglib prefix="fmt" uri="http://java.sun.com/jsp/jstl/fmt" %>
<%@taglib prefix="fn" uri="http://java.sun.com/jsp/jstl/functions" %>
<%@taglib prefix="joda" uri="http://www.joda.org/joda/time/tags" %>
<%@taglib prefix="sql" uri="http://java.sun.com/jsp/jstl/sql" %>

<c:if test="${!user.administrator}">
    <jsp:forward page="unauthorized"/>
</c:if>

<!DOCTYPE html PUBLIC "-//W3C//DTD XHTML 1.1//EN" "http://www.w3.org/TR/xhtml11/DTD/xhtml11.dtd">
<html xmlns="http://www.w3.org/1999/xhtml">
    <c:set var="employee" value="${directory.byNumber[param.id]}"/>
    <head>
        <link href="style.css" rel="stylesheet" type="text/css"/>
        <title>${employee.fullName}</title>
    </head>
    <body>
        <%@include file="header.jsp" %>

        <h1>${employee.fullName}</h1>

        <%
            Sarariman sarariman = (Sarariman)getServletContext().getAttribute("sarariman");
            Employee employee = (Employee)pageContext.getAttribute("employee");
            Collection<Integer> managers = sarariman.getOrganizationHierarchy().getManagers(employee.getNumber());
            pageContext.setAttribute("managers", managers);
        %>
        <c:if test="${!empty managers}">
            <h2>Managers</h2>
            <ul>
                <c:forEach var="manager" items="${managers}">
                    <c:url var="managerURL" value="${pageContext.request.servletPath}"><c:param name="id" value="${manager}"/></c:url>
                    <li><a href="${managerURL}">${directory.byNumber[manager].fullName}</a></li>
                </c:forEach>
            </ul>
        </c:if>   

        <%
            Collection<Integer> directReports = sarariman.getOrganizationHierarchy().getDirectReports(employee.getNumber());
            pageContext.setAttribute("directReports", directReports);
        %>
        <c:if test="${!empty directReports}">
            <h2>Direct Reports</h2>
            <ul>
                <c:forEach var="report" items="${directReports}">
                    <c:url var="reportURL" value="${pageContext.request.servletPath}"><c:param name="id" value="${report}"/></c:url>
                    <li><a href="${reportURL}">${directory.byNumber[report].fullName}</a></li>
                </c:forEach>
            </ul>
        </c:if>   

        <c:if test="${user.administrator}">
            <h2>Info</h2>
            Birthdate: <joda:format value="${directory.byNumber[param.id].birthdate}" style="L-" /><br/>
            Age: ${directory.byNumber[param.id].age}

            <h2>Direct Rate</h2>
            <sql:query dataSource="jdbc/sarariman" var="resultSet">
                SELECT rate, effective
                FROM direct_rate
                WHERE employee=?
                ORDER BY effective DESC
                <sql:param value="${param.id}"/>
            </sql:query>
            <table class="altrows">
                <tr><th>Rate</th><th>Effective Date</th><th>Duration</th></tr>
                <c:set var="endDate" value="${du:now()}"/>
                <c:forEach var="rate_row" items="${resultSet.rows}" varStatus="varStatus">
                    <tr class="${varStatus.index % 2 == 0 ? 'evenrow' : 'oddrow'}">
                        <td class="currency"><fmt:formatNumber type="currency" value="${rate_row.rate}"/></td>
                        <fmt:parseDate var="effective" value="${rate_row.effective}" pattern="yyyy-MM-dd"/>
                        <td><fmt:formatDate value="${effective}" pattern="yyyy-MM-dd"/></td>
                        <td>${du:daysBetween(effective, endDate)} days</td>
                        <c:set var="endDate" value="${effective}"/>
                    </tr>
                </c:forEach>
            </table>
        </c:if>

        <sql:query dataSource="jdbc/sarariman" var="resultSet">
            SELECT project FROM project_managers WHERE employee=?
            <sql:param value="${param.id}"/>
        </sql:query>
        <c:if test="${resultSet.rowCount != 0}">
            <h2>Projects Managed</h2>
            <ul>
                <c:forEach var="mapping_row" items="${resultSet.rows}">
                    <c:set var="project" value="${sarariman.projects[mapping_row.project]}"/>
                    <c:set var="customer" value="${sarariman.customers[project.customer]}"/>
                    <c:url var="link" value="project">
                        <c:param name="id" value="${mapping_row.project}"/>
                    </c:url>
                    <li><a href="${link}">${fn:escapeXml(project.name)} - ${fn:escapeXml(customer.name)}</a></li>
                </c:forEach>
            </ul>
        </c:if>

        <h2>Task Assignments</h2>
        <form method="POST" action="TaskAssignmentController">
            <input type="hidden" name="employee" value="${param.id}"/>
            <input type="hidden" name="action" value="delete"/>
            <ul>
                <sql:query dataSource="jdbc/sarariman" var="resultSet">
                    SELECT a.task, t.name, t.project
                    FROM task_assignments AS a
                    JOIN tasks AS t ON t.id = a.task
                    WHERE a.employee=?
                    <sql:param value="${param.id}"/>
                </sql:query>
                <c:forEach var="mapping_row" items="${resultSet.rows}">
                    <c:url var="link" value="task">
                        <c:param name="task_id" value="${mapping_row.task}"/>
                    </c:url>
                    <c:if test="${!empty mapping_row.project}">
                        <c:set var="project" value="${sarariman.projects[mapping_row.project]}"/>
                        <c:set var="customer" value="${sarariman.customers[project.customer]}"/>
                    </c:if>
                    <li><a href="${link}">${fn:escapeXml(mapping_row.name)} (${mapping_row.task})
                            <c:if test="${!empty mapping_row.project}">
                                - ${fn:escapeXml(project.name)} - ${fn:escapeXml(customer.name)}
                            </c:if>
                        </a>
                        <c:if test="${user.administrator}">
                            <button type="submit" name="task" value="${mapping_row.task}">X</button>
                        </c:if>
                    </li>
                </c:forEach>
            </ul>
        </form>

        <c:if test="${user.administrator}">
            <form method="POST" action="TaskAssignmentController">
                <input type="hidden" name="employee" value="${param.id}"/>
                <input type="hidden" name="action" value="add"/>
                <select name="task">
                    <sql:query dataSource="jdbc/sarariman" var="resultSet">
                        SELECT id, name
                        FROM tasks
                        WHERE active = 1
                    </sql:query>
                    <c:forEach var="row" items="${resultSet.rows}">
                        <option value="${row.id}">${row.id} - ${fn:escapeXml(row.name)}</option>
                    </c:forEach>
                </select>
                <input type="submit" name="Add" value="Add"/>
            </form>
        </c:if>

        <h2>Tasks Worked</h2>
        <ul>
            <sql:query dataSource="jdbc/sarariman" var="resultSet">
                SELECT DISTINCT(h.task), t.name, t.project
                FROM hours AS h
                JOIN tasks AS t ON t.id = h.task
                WHERE h.employee=?
                <sql:param value="${param.id}"/>
            </sql:query>
            <c:forEach var="mapping_row" items="${resultSet.rows}">
                <c:url var="link" value="task">
                    <c:param name="task_id" value="${mapping_row.task}"/>
                </c:url>
                <c:if test="${!empty mapping_row.project}">
                    <c:set var="project" value="${sarariman.projects[mapping_row.project]}"/>
                    <c:set var="customer" value="${sarariman.customers[project.customer]}"/>
                </c:if>
                <li><a href="${link}">${fn:escapeXml(mapping_row.name)} (${mapping_row.task})
                        <c:if test="${!empty mapping_row.project}">
                            - ${fn:escapeXml(project.name)} - ${fn:escapeXml(customer.name)}
                        </c:if>
                    </a>
                </li>
            </c:forEach>
        </ul>

        <%@include file="footer.jsp" %>
    </body>
</html>
