<!--#include virtual="/system.asp"-->
<!--#include virtual="/checkstep.asp"-->
<%
Dim stepID
stepID = Request.QueryString("stepID")

render.renderTitle()
%>

<h2>Futures Wheel - List View</h2>
<p>StepID: <%=stepID%></p>

<h3>Events:</h3>
<ul>
<%
Call getRecordSet("SELECT * FROM T_FTA_METHOD_FUTURES_WHEEL WHERE stepID = " & stepID & " ORDER BY fwID", rs)
While Not rs.EOF
    Response.Write("<li>" & rs("event") & " (ID: " & rs("fwID") & ")</li>")
    rs.MoveNext
Wend
rs.Close
%>
</ul>

<button onclick="if(confirm('Finish?')) location.href='/FTA/fw/fwActions.asp?action=end&stepID=<%=stepID%>'">Finish</button>

<%
render.renderFooter()
%>