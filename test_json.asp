<!--#include file="includes/aspJSON1.19.asp"-->
<%
Response.ContentType = "text/html; charset=utf-8"

Response.Write "<h2>Teste aspJSON</h2>"

On Error Resume Next
Dim testJSON
Set testJSON = New aspJSON

If Err.Number = 0 Then
    Response.Write "<p style='color:green'>✓ aspJSON carregado com sucesso!</p>"
    
    ' Teste criação de JSON
    With testJSON.data
        .add "teste", "funcionando"
        .add "versao", "1.19"
        .add "data", FormatDateTime(Now(), 2)
    End With
    
    Response.Write "<p><strong>JSON criado:</strong></p>"
    Response.Write "<pre>" & testJSON.JSONoutput() & "</pre>"
Else
    Response.Write "<p style='color:red'>✗ Erro ao carregar aspJSON: " & Err.Description & "</p>"
End If

On Error Goto 0
%>