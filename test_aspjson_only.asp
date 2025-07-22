<!--#include file="includes/aspJSON1.19.asp"-->
<%
Response.Write "Testando aspJSON isoladamente...<br>"

On Error Resume Next
Set testJSON = New aspJSON

If Err.Number = 0 Then
    Response.Write "SUCCESS: aspJSON carregado!<br>"
    
    testJSON.data.add "teste", "ok"
    Response.Write "JSON: " & testJSON.JSONoutput()
Else
    Response.Write "ERROR: " & Err.Description & " (Line: " & Err.Line & ")<br>"
    Response.Write "Erro número: " & Err.Number
End If
%>