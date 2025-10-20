<!--#include virtual="/system.asp"-->
<%
Dim stepID
stepID = Request.QueryString("stepID")
%>
<!DOCTYPE html>
<html>
<head>
<title>View Dublin Core Data</title>
<style>
body {
    font-family: Arial, sans-serif;
    margin: 20px;
}
h2 {
    color: #333;
}
.section {
    background: #f5f5f5;
    padding: 10px;
    margin: 10px 0;
    border: 1px solid #ddd;
}
.item {
    padding: 5px;
    margin: 3px 0;
    background: white;
}
</style>
</head>
<body>

<h2>Dublin Core Data - Previous Methods</h2>

<%
On Error Resume Next

' Try to show Brainstorming data
Response.Write("<div class='section'>")
Response.Write("<h3>Brainstorming Ideas</h3>")
Call getRecordSet("SELECT TOP 30 idea FROM T_FTA_METHOD_BRAINSTORMING_IDEAS ORDER BY ideaID DESC", rs)
If Not rs.EOF Then
    While Not rs.EOF
        Response.Write("<div class='item'>" & rs("idea") & "</div>")
        rs.MoveNext
    Wend
Else
    Response.Write("<p>No brainstorming data found.</p>")
End If
rs.Close
Response.Write("</div>")

' Try to show Scenarios data
Response.Write("<div class='section'>")
Response.Write("<h3>Scenarios</h3>")
Call getRecordSet("SELECT TOP 20 title FROM T_FTA_METHOD_SCENARIOS ORDER BY scenarioID DESC", rs)
If Not rs.EOF Then
    While Not rs.EOF
        Response.Write("<div class='item'>" & rs("title") & "</div>")
        rs.MoveNext
    Wend
Else
    Response.Write("<p>No scenarios found.</p>")
End If
rs.Close
Response.Write("</div>")

' Try to show Bibliometrics data
Response.Write("<div class='section'>")
Response.Write("<h3>Bibliometrics References</h3>")
Call getRecordSet("SELECT TOP 20 title FROM T_FTA_METHOD_BIBLIOMETRICS GROUP BY title ORDER BY COUNT(*) DESC", rs)
If Not rs.EOF Then
    While Not rs.EOF
        Response.Write("<div class='item'>" & rs("title") & "</div>")
        rs.MoveNext
    Wend
Else
    Response.Write("<p>No bibliometrics data found.</p>")
End If
rs.Close
Response.Write("</div>")

On Error Goto 0
%>

<hr>
<p><strong>How to use:</strong> Copy any data above and use it when creating events in the Futures Wheel.</p>
<button onclick="window.close()">Close Window</button>

</body>
</html>