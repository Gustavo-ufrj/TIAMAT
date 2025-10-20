<%
' Este arquivo apenas redireciona para viewDC.asp
Dim stepID
stepID = Request.QueryString("stepID")
Response.Redirect "viewDC.asp?stepID=" & stepID
%>