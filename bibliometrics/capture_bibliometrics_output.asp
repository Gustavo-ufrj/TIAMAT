<!--#include virtual="/system.asp"-->
<%
Response.Clear
Response.ContentType = "application/json"
Response.CharSet = "utf-8"

' Declarar TODAS as variáveis uma única vez no início
Dim stepID, action, success, totalRefs
Dim safeStepID, rs, jsonOutput, escapedJSON

' Inicializar
stepID = Request.Form("stepID")
action = Request.Form("action")
success = False
totalRefs = 0

On Error Resume Next

If action = "finish" And stepID <> "" And IsNumeric(stepID) Then
    
    safeStepID = CLng(stepID)
    
    ' Contar referências usando o nome correto do campo
    Call getRecordSet("SELECT COUNT(*) as total FROM T_FTA_METHOD_BIBLIOMETRICS WHERE StepID = " & safeStepID, rs)
    If Not rs.eof And Err.Number = 0 Then 
        totalRefs = rs("total")
    End If
    Err.Clear
    
    ' Criar JSON
    jsonOutput = "{""method"": ""bibliometrics"", ""stepID"": " & safeStepID & ", ""totalReferences"": " & totalRefs & ", ""status"": ""completed"", ""timestamp"": """ & FormatDateTime(Now(), 2) & """, ""version"": ""2.0""}"
    
    ' Verificar qual coluna existe para o JSON
    Call getRecordSet("SELECT COLUMN_NAME FROM INFORMATION_SCHEMA.COLUMNS WHERE TABLE_NAME = 'tiamat_steps' AND (COLUMN_NAME LIKE '%json%' OR COLUMN_NAME LIKE '%output%')", rs)
    
    Dim jsonColumn
    jsonColumn = "description" ' fallback padrão
    
    If Not rs.eof Then
        jsonColumn = rs("COLUMN_NAME")
    End If
    
    ' Salvar no banco na coluna disponível
    escapedJSON = Replace(jsonOutput, "'", "''")
    Call ExecuteSQL("UPDATE tiamat_steps SET " & jsonColumn & " = '" & escapedJSON & "', updated = GETDATE() WHERE stepID = " & safeStepID)
    
    If Err.Number = 0 Then
        success = True
        Call ExecuteSQL("UPDATE tiamat_steps SET status = 4 WHERE stepID = " & safeStepID)
    End If
    Err.Clear
    
End If

' Retornar JSON
Response.Write "{""success"": " & IIf(success, "true", "false") & ", ""stepID"": " & stepID & ", ""totalReferences"": " & totalRefs & ", ""message"": """ & IIf(success, "Output captured successfully", "Failed to capture output") & """}"

On Error Goto 0
%>