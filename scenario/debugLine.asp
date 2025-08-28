<%
On Error Resume Next
Response.Write "<pre>"
Response.Write "1. Iniciando..." & vbCrLf

' Include 1
%>
<!--#include virtual="/system.asp"-->
<%
If Err.Number <> 0 Then
    Response.Write "ERRO em system.asp: " & Err.Description & vbCrLf
    Response.End
End If
Response.Write "2. system.asp OK" & vbCrLf

' Include 2
%>
<!--#include virtual="/checkstep.asp"-->
<%
If Err.Number <> 0 Then
    Response.Write "ERRO em checkstep.asp: " & Err.Description & vbCrLf
    Response.End
End If
Response.Write "3. checkstep.asp OK" & vbCrLf

' Include 3
%>
<!--#include file="INC_SCENARIO.inc"-->
<%
If Err.Number <> 0 Then
    Response.Write "ERRO em INC_SCENARIO.inc: " & Err.Description & vbCrLf
    Response.End
End If
Response.Write "4. INC_SCENARIO.inc OK" & vbCrLf

' Funcoes Tiamat
Response.Write "5. Testando saveCurrentURL..." & vbCrLf
saveCurrentURL
If Err.Number <> 0 Then
    Response.Write "ERRO: " & Err.Description & vbCrLf
    Err.Clear
End If

Response.Write "6. Testando tiamat.addJS..." & vbCrLf
tiamat.addJS("/js/tinymce/tinymce.min.js")
If Err.Number <> 0 Then
    Response.Write "ERRO: " & Err.Description & vbCrLf
    Err.Clear
End If

Response.Write "7. Testando render.renderToBody..." & vbCrLf
render.renderToBody()
If Err.Number <> 0 Then
    Response.Write "ERRO: " & Err.Description & vbCrLf
    Err.Clear
End If

' Variaveis
Dim currentStepID
currentStepID = Request.QueryString("stepID")
If currentStepID = "" Then currentStepID = "50379"
Response.Write "8. currentStepID = " & currentStepID & vbCrLf

' Status
Response.Write "9. Testando getStatusStep..." & vbCrLf
Dim status
status = getStatusStep(currentStepID)
Response.Write "   Status = " & status & vbCrLf
If Err.Number <> 0 Then
    Response.Write "ERRO: " & Err.Description & vbCrLf
    Err.Clear
End If

' Query Bibliometrics
Response.Write "10. Buscando bibliometrics..." & vbCrLf
call getRecordSet("SELECT TOP 1 stepID FROM T_FTA_METHOD_BIBLIOMETRICS WHERE stepID < " & currentStepID & " ORDER BY stepID DESC", rs)
If Err.Number <> 0 Then
    Response.Write "ERRO: " & Err.Description & vbCrLf
    Err.Clear
Else
    If Not rs.EOF Then
        Response.Write "   Encontrou step: " & rs("stepID") & vbCrLf
    Else
        Response.Write "   Nenhum step encontrado" & vbCrLf
    End If
End If

' Query Authors
Response.Write "11. Testando query de autores..." & vbCrLf
call getRecordSet("SELECT TOP 5 a.name FROM T_FTA_METHOD_BIBLIOMETRICS_AUTHORS a INNER JOIN T_FTA_METHOD_BIBLIOMETRICS b ON a.referenceID = b.referenceID WHERE b.stepID = 50378", rs)
If Err.Number <> 0 Then
    Response.Write "ERRO: " & Err.Description & vbCrLf
    Err.Clear
Else
    Dim count
    count = 0
    While Not rs.EOF
        count = count + 1
        rs.MoveNext
    Wend
    Response.Write "   Encontrou " & count & " autores" & vbCrLf
End If

Response.Write vbCrLf & "=== TESTES COMPLETOS ===" & vbCrLf
Response.Write "Se chegou aqui, o problema pode estar no processamento dos dados" & vbCrLf
Response.Write "</pre>"
%>