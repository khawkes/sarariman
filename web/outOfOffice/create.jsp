<%--
  Copyright (C) 2012 StackFrame, LLC
  This code is licensed under GPLv2.
--%>

<%@page contentType="application/xhtml+xml" pageEncoding="UTF-8"%>

<!DOCTYPE html PUBLIC "-//W3C//DTD XHTML 1.1//EN" "http://www.w3.org/TR/xhtml11/DTD/xhtml11.dtd">
<html xmlns="http://www.w3.org/1999/xhtml">
    <head>
        <link href="../style.css" rel="stylesheet" type="text/css"/>
        <title>Schedule Out of Office Time</title>

        <!-- jQuery -->
        <link type="text/css" href="../jquery/css/ui-lightness/jquery-ui-1.8.20.custom.css" rel="Stylesheet" />    
        <script type="text/javascript" src="../jquery/js/jquery-1.7.2.min.js"></script>
        <script type="text/javascript" src="../jquery/js/jquery-ui-1.8.20.custom.min.js"></script>
        <!-- /jQuery -->

        <script type="text/javascript" src="../js/jquery-ui-timepicker-addon.js"></script>
        <link href="../style/timepicker.css" rel="stylesheet" type="text/css"/>

        <script type="text/javascript">            
            $(function() {
                $( "#begin" ).datetimepicker({dateFormat: 'yy-mm-dd'});
                $( "#end" ).datetimepicker({dateFormat: 'yy-mm-dd'});
            });
        </script>
    </head>
    <body>
        <%@include file="../header.jsp" %>
        <h1>Schedule Out of Office Time</h1>

        <!-- FIXME: Validate that end is greater than begin. -->

        <form method="POST" action="handleCreate.jsp">
            <p>
                <label for="begin">Begin: </label>
                <input size="17" type="text" id="begin" name="begin"/>

                <label for="end">End: </label>
                <input size="17" type="text" id="end" name="end"/><br/>

                <label for="comment">Comment: </label>
                <input size="50" type="text" id="comment" name="comment"/><br/>

                <input type="submit" value="Schedule" name="schedule"/>
            </p>
            <p>                
                Enter the begin and end time for when you expect to be out of the office. Supplying a comment is optional.
            </p>
        </form>

        <%@include file="../footer.jsp" %>
    </body>
</html>
