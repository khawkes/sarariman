/*
 * Copyright (C) 2013 StackFrame, LLC
 * This code is licensed under GPLv2.
 */
package com.stackframe.sarariman;

import java.io.IOException;
import java.sql.Connection;
import java.sql.PreparedStatement;
import java.sql.SQLException;
import javax.servlet.Filter;
import javax.servlet.FilterChain;
import javax.servlet.FilterConfig;
import javax.servlet.ServletException;
import javax.servlet.ServletRequest;
import javax.servlet.ServletResponse;
import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;
import javax.sql.DataSource;

/**
 *
 * @author mcculley
 */
public class AccessLogFilter implements Filter {
    
    private DataSource dataSource;
    
    public void init(FilterConfig filterConfig) throws ServletException {
        Sarariman sarariman = (Sarariman)filterConfig.getServletContext().getAttribute("sarariman");
        dataSource = sarariman.getDataSource();
    }
    
    public void doFilter(ServletRequest request, ServletResponse response, FilterChain chain) throws IOException, ServletException {
        StatusExposingServletResponse sesr = new StatusExposingServletResponse((HttpServletResponse)response);
        long start = System.currentTimeMillis();
        chain.doFilter(request, sesr);
        long stop = System.currentTimeMillis();
        long took = stop - start;
        HttpServletRequest httpServletRequest = (HttpServletRequest)request;
        Employee employee = (Employee)request.getAttribute("user");
        try {
            Connection c = dataSource.getConnection();
            try {
                PreparedStatement s = c.prepareStatement(
                        "INSERT INTO access_log (path, query, method, employee, status, time, user_agent, remote_address) " +
                        "VALUES(?, ?, ?, ?, ?, ?, ?, ?)");
                try {
                    s.setString(1, httpServletRequest.getServletPath());
                    s.setString(2, httpServletRequest.getQueryString());
                    s.setString(3, httpServletRequest.getMethod());
                    s.setInt(4, employee.getNumber());
                    s.setInt(5, sesr.getStatus());
                    s.setLong(6, took);
                    s.setString(7, httpServletRequest.getHeader("User-Agent"));
                    s.setString(8, httpServletRequest.getRemoteAddr());
                    int numRowsInserted = s.executeUpdate();
                    assert numRowsInserted == 1;
                } finally {
                    s.close();
                }
            } finally {
                c.close();
            }
        } catch (SQLException e) {
            throw new ServletException(e);
        }
    }
    
    public void destroy() {
    }
    
}
