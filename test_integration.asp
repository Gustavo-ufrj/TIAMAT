<!--#include file="system.asp"-->
<%
Response.ContentType = "text/html; charset=utf-8"

Response.Write "<h2>Teste de Integração TIAMAT</h2>"

' Teste 1: aspJSON
Response.Write "<h3>1. Teste aspJSON</h3>"
On Error Resume Next
Set jsonTest = New aspJSON
If Err.Number = 0 Then
    jsonTest.data.add "status", "OK"
    Response.Write "<p style='color:green'>✓ aspJSON: " & jsonTest.JSONoutput() & "</p>"
Else
    Response.Write "<p style='color:red'>✗ aspJSON: " & Err.Description & "</p>"
End If
On Error Goto 0

' Teste 2: Conexão com Banco
Response.Write "<h3>2. Teste Conexão Banco</h3>"
On Error Resume Next
Dim rs
Call getRecordSet("SELECT COUNT(*) as total FROM tiamat_workflows", rs)
If Err.Number = 0 Then
    Response.Write "<p style='color:green'>✓ Banco conectado - " & rs("total") & " workflows encontrados</p>"
Else
    Response.Write "<p style='color:red'>✗ Erro no banco: " & Err.Description & "</p>"
End If
On Error Goto 0

' Teste 3: Manifest
Response.Write "<h3>3. Teste Manifest</h3>"
On Error Resume Next
Set manifest = LoadManifest()
If Err.Number = 0 And Not manifest Is Nothing Then
    Set methodList = getFTAMethodList(manifest)
    Response.Write "<p style='color:green'>✓ Manifest carregado - " & methodList.length & " métodos FTA encontrados</p>"
Else
    Response.Write "<p style='color:red'>✗ Erro no manifest: " & Err.Description & "</p>"
End If
On Error Goto 0

' Teste 4: Tabelas do banco
Response.Write "<h3>4. Teste Tabelas</h3>"
On Error Resume Next
Call getRecordSet("SELECT TABLE_NAME FROM INFORMATION_SCHEMA.TABLES WHERE TABLE_NAME LIKE 'tiamat_%'", rs)
If Err.Number = 0 Then
    Response.Write "<p style='color:green'>✓ Tabelas encontradas:</p><ul>"
    While Not rs.eof
        Response.Write "<li>" & rs("TABLE_NAME") & "</li>"
        rs.movenext
    Wend
    Response.Write "</ul>"
Else
    Response.Write "<p style='color:red'>✗ Erro ao verificar tabelas: " & Err.Description & "</p>"
End If
On Error Goto 0

Response.Write "<h3>Resumo</h3>"
Response.Write "<p>Se todos os testes acima passaram, o sistema está pronto para o OutputManager!</p>"
%>