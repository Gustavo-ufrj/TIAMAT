<!--#include file="system.asp"-->
<!--#include file="TiamatOutputManager.asp"-->
<%
Response.ContentType = "text/html; charset=utf-8"

Response.Write "<h2>Teste TiamatOutputManager</h2>"

' Teste 1: Instanciação
Response.Write "<h3>1. Teste Instanciação</h3>"
On Error Resume Next
Set outputManager = New TiamatOutputManager
If Err.Number = 0 Then
    Response.Write "<p style='color:green'>✓ OutputManager instanciado com sucesso!</p>"
Else
    Response.Write "<p style='color:red'>✗ Erro ao instanciar: " & Err.Description & "</p>"
    Response.End
End If
On Error Goto 0

' Teste 2: Buscar step existente
Response.Write "<h3>2. Teste Busca de Step</h3>"
On Error Resume Next
Dim stepOutput
stepOutput = outputManager.GetStepOutput(1) ' Tenta buscar step ID 1
If Err.Number = 0 Then
    If stepOutput <> "" Then
        Response.Write "<p style='color:green'>✓ Output encontrado para step 1</p>"
        Response.Write "<pre>" & Left(stepOutput, 200) & "...</pre>"
    Else
        Response.Write "<p style='color:orange'>⚠ Nenhum output encontrado para step 1 (normal se não tiver dados ainda)</p>"
    End If
Else
    Response.Write "<p style='color:red'>✗ Erro ao buscar output: " & Err.Description & "</p>"
End If
On Error Goto 0

' Teste 3: Teste de captura (com dados fictícios)
Response.Write "<h3>3. Teste Captura de Output</h3>"
On Error Resume Next
Dim testData, success
testData = "{""teste"": ""dados de exemplo"", ""timestamp"": """ & Now() & """}"

' Busca um step válido para testar
Call getRecordSet("SELECT TOP 1 stepID FROM tiamat_steps", rs)
If Not rs.eof Then
    Dim testStepID
    testStepID = rs("stepID")
    
    success = outputManager.CaptureStepOutput(testStepID, testData, "test_output", 5)
    
    If Err.Number = 0 Then
        If success Then
            Response.Write "<p style='color:green'>✓ Output capturado com sucesso para step " & testStepID & "!</p>"
        Else
            Response.Write "<p style='color:orange'>⚠ Captura executada mas retornou False (verificar logs)</p>"
        End If
    Else
        Response.Write "<p style='color:red'>✗ Erro na captura: " & Err.Description & "</p>"
    End If
Else
    Response.Write "<p style='color:orange'>⚠ Nenhum step encontrado para testar</p>"
End If
On Error Goto 0

Set outputManager = Nothing

Response.Write "<h3>Conclusão</h3>"
Response.Write "<p>Se os testes passaram, o OutputManager está funcionando!</p>"
%>