<%@LANGUAGE="VBSCRIPT"%>
<!--#include virtual="/system.asp"-->
<%
Response.Write "System.asp OK<br>"

Dim stepID
stepID = Request.QueryString("stepID")
Response.Write "StepID: " & stepID & "<br>"

' Teste simples de query
On Error Resume Next
call getRecordSet("SELECT COUNT(*) as total FROM T_FTA_METHOD_BIBLIOMETRICS", rs)
If Err.Number = 0 Then
    Response.Write "Query OK - Total: " & rs("total") & "<br>"
Else
    Response.Write "Query Error: " & Err.Description & "<br>"
End If

Response.Write "Teste completo!"
%>