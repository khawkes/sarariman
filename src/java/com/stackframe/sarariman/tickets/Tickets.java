/*
 * Copyright (C) 2012 StackFrame, LLC
 * This code is licensed under GPLv2.
 */
package com.stackframe.sarariman.tickets;

import java.sql.SQLException;
import java.util.Collection;
import java.util.Map;

/**
 *
 * @author mcculley
 */
public interface Tickets {

    Collection<String> getStatusTypes() throws SQLException;

    Collection<Ticket> getAll() throws SQLException;

    Map<? extends Number, Ticket> getMap();

}
