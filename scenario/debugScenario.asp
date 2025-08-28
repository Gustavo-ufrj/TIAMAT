<%@LANGUAGE="VBSCRIPT"%>
<!--#include virtual="/system.asp"-->
<!--#include virtual="/checkstep.asp"-->
<!--#include file="INC_SCENARIO.inc"-->
<%
On Error Resume Next

Response.Write "<h2>Debug do Scenario Module</h2>"
Response.Write "<pre>"

' Teste 1: Includes
Response.Write "1. INCLUDES:" & vbCrLf
Response.Write "   system.asp: "
If Err.Number = 0 Then
    Response.Write "OK" & vbCrLf
Else
    Response.Write "ERRO: " & Err.Description & vbCrLf
End If
Err.Clear

Response.Write "   checkstep.asp: "
If Err.Number = 0 Then
    Response.Write "OK" & vbCrLf
Else
    Response.Write "ERRO: " & Err.Description & vbCrLf
End If
Err.Clear

Response.Write "   INC_SCENARIO.inc: "
If Err.Number = 0 Then
    Response.Write "OK" & vbCrLf
Else
    Response.Write "ERRO: " & Err.Description & vbCrLf
End If
Err.Clear

' Teste 2: Funcoes Tiamat
Response.Write vbCrLf & "2. FUNCOES TIAMAT:" & vbCrLf
Response.Write "   saveCurrentURL: "
saveCurrentURL
If Err.Number = 0 Then
    Response.Write "OK" & vbCrLf
Else
    Response.Write "ERRO: " & Err.Description & vbCrLf
End If
Err.Clear

Response.Write "   tiamat.addJS: "
tiamat.addJS("/js/tinymce/tinymce.min.js")
If Err.Number = 0 Then
    Response.Write "OK" & vbCrLf
Else
    Response.Write "ERRO: " & Err.Description & vbCrLf
End If
Err.Clear

Response.Write "   render.renderToBody: "
render.renderToBody()
If Err.Number = 0 Then
    Response.Write "OK" & vbCrLf
Else
    Response.Write "ERRO: " & Err.Description & vbCrLf
End If
Err.Clear

' Teste 3: Variaveis
Dim currentStepID
currentStepID = Request.QueryString("stepID")
If currentStepID = "" Then currentStepID = "50379"

Response.Write vbCrLf & "3. VARIAVEIS:" & vbCrLf
Response.Write "   stepID: " & currentStepID & vbCrLf

' Teste 4: getStatusStep
Response.Write vbCrLf & "4. STATUS DO STEP:" & vbCrLf
Response.Write "   getStatusStep(" & currentStepID & "): "
Dim status
status = getStatusStep(currentStepID)
If Err.Number = 0 Then
    Response.Write status & vbCrLf
    Response.Write "   STATE_ACTIVE: " & STATE_ACTIVE & vbCrLf
    If status = STATE_ACTIVE Then
        Response.Write "   Step esta ATIVO" & vbCrLf
    Else
        Response.Write "   Step NAO esta ativo" & vbCrLf
    End If
Else
    Response.Write "ERRO: " & Err.Description & vbCrLf
End If
Err.Clear

' Teste 5: Queries Bibliometrics
Response.Write vbCrLf & "5. QUERIES BIBLIOMETRICS:" & vbCrLf

' Query 1: Workflow
Response.Write "   Query Workflow: "
call getRecordSet("SELECT workflowID FROM T_WORKFLOW_STEP WHERE stepID = " & currentStepID, rs)
If Err.Number = 0 Then
    If Not rs.EOF Then
        Response.Write "OK - workflowID = " & rs("workflowID") & vbCrLf
    Else
        Response.Write "OK mas sem dados" & vbCrLf
    End If
Else
    Response.Write "ERRO: " & Err.Description & vbCrLf
End If
Err.Clear

' Query 2: Bibliometrics simples
Response.Write "   Query Bibliometrics simples: "
call getRecordSet("SELECT DISTINCT stepID FROM T_FTA_METHOD_BIBLIOMETRICS WHERE stepID < " & currentStepID & " ORDER BY stepID DESC", rs)
If Err.Number = 0 Then
    If Not rs.EOF Then
        Response.Write "OK - stepID = " & rs("stepID") & vbCrLf
    Else
        Response.Write "OK mas sem dados" & vbCrLf
    End If
Else
    Response.Write "ERRO: " & Err.Description & vbCrLf
End If
Err.Clear

' Query 3: Contagem
Response.Write "   Query Count: "
call getRecordSet("SELECT COUNT(*) as total FROM T_FTA_METHOD_BIBLIOMETRICS WHERE stepID = 50378", rs)
If Err.Number = 0 Then
    Response.Write "OK - total = " & rs("total") & vbCrLf
Else
    Response.Write "ERRO: " & Err.Description & vbCrLf
End If
Err.Clear

' Query 4: Titles
Response.Write "   Query Titles: "
call getRecordSet("SELECT TOP 3 title FROM T_FTA_METHOD_BIBLIOMETRICS WHERE stepID = 50378 AND title IS NOT NULL", rs)
If Err.Number = 0 Then
    Dim titleCount
    titleCount = 0
    While Not rs.EOF
        titleCount = titleCount + 1
        rs.MoveNext
    Wend
    Response.Write "OK - " & titleCount & " titulos encontrados" & vbCrLf
Else
    Response.Write "ERRO: " & Err.Description & vbCrLf
End If
Err.Clear

' Query 5: Emails
Response.Write "   Query Emails: "
call getRecordSet("SELECT DISTINCT TOP 3 email FROM T_FTA_METHOD_BIBLIOMETRICS WHERE stepID = 50378 AND email IS NOT NULL", rs)
If Err.Number = 0 Then
    Dim emailCount
    emailCount = 0
    While Not rs.EOF
        emailCount = emailCount + 1
        rs.MoveNext
    Wend
    Response.Write "OK - " & emailCount & " emails encontrados" & vbCrLf
Else
    Response.Write "ERRO: " & Err.Description & vbCrLf
End If
Err.Clear

' Query 6: Years
Response.Write "   Query Years: "
call getRecordSet("SELECT MIN(year) as min_year, MAX(year) as max_year FROM T_FTA_METHOD_BIBLIOMETRICS WHERE stepID = 50378 AND year IS NOT NULL", rs)
If Err.Number = 0 Then
    If Not rs.EOF Then
        Response.Write "OK - " & rs("min_year") & " a " & rs("max_year") & vbCrLf
    Else
        Response.Write "OK mas sem dados" & vbCrLf
    End If
Else
    Response.Write "ERRO: " & Err.Description & vbCrLf
End If
Err.Clear

' Teste 6: Funcoes SQL do INC_SCENARIO
Response.Write vbCrLf & "6. FUNCOES SQL DO INC_SCENARIO:" & vbCrLf
Response.Write "   SQL_CONSULTA_SCENARIOS: "
Dim sqlTest
sqlTest = SQL_CONSULTA_SCENARIOS(currentStepID)
If Err.Number = 0 Then
    Response.Write "OK" & vbCrLf
    Response.Write "   SQL: " & Left(sqlTest, 100) & "..." & vbCrLf
Else
    Response.Write "ERRO: " & Err.Description & vbCrLf
End If
Err.Clear

Response.Write vbCrLf & "========== FIM DO DEBUG ==========" & vbCrLf
Response.Write "</pre>"

' Teste final: render
Response.Write "<div style='background: #f0f0f0; padding: 10px; margin: 20px 0;'>"
Response.Write "<strong>Teste render.renderFromBody():</strong><br>"
render.renderFromBody()
If Err.Number = 0 Then
    Response.Write "OK - render funcionou"
Else
    Response.Write "ERRO: " & Err.Description
End If
Response.Write "</div>"
%>