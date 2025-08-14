<!--#include virtual="/system.asp"-->
<%
Response.ContentType = "text/html; charset=utf-8"
%>
<!DOCTYPE html>
<html>
<head>
    <title>Teste Final - Scenario</title>
    <style>
        body { font-family: Arial, sans-serif; margin: 20px; }
        .success { color: green; font-weight: bold; }
        .error { color: red; font-weight: bold; }
        .code { background: #f5f5f5; padding: 15px; border: 1px solid #ccc; margin: 10px 0; }
    </style>
</head>
<body>
    <h1>🎯 Teste Final - Verificar Estrutura e Gerar Correção</h1>
    
    <h2>1. Verificar Colunas da Tabela</h2>
    <%
    On Error Resume Next
    
    Dim rs
    Call getRecordSet("SELECT COLUMN_NAME FROM INFORMATION_SCHEMA.COLUMNS WHERE TABLE_NAME = 'T_FTA_METHOD_SCENARIOS' ORDER BY ORDINAL_POSITION", rs)
    
    Response.Write "<p><strong>Colunas encontradas:</strong></p>"
    Response.Write "<ul>"
    
    Dim columns
    columns = ""
    
    If Err.Number = 0 And Not rs.eof Then
        While Not rs.eof
            Response.Write "<li>" & rs("COLUMN_NAME") & "</li>"
            If columns <> "" Then columns = columns & ", "
            columns = columns & rs("COLUMN_NAME")
            rs.movenext
        Wend
    Else
        Response.Write "<li>Erro: " & Err.Description & "</li>"
        Err.Clear
    End If
    
    Response.Write "</ul>"
    
    On Error Goto 0
    %>
    
    <h2>2. SQL de Teste</h2>
    <%
    ' Gerar SQL simples baseado nas colunas encontradas
    Dim testSQL
    If InStr(LCase(columns), "description") > 0 Then
        testSQL = "SELECT scenarioID, stepID, name, description, scenario FROM T_FTA_METHOD_SCENARIOS WHERE stepID = 1"
    Else
        testSQL = "SELECT scenarioID, stepID, name, scenario FROM T_FTA_METHOD_SCENARIOS WHERE stepID = 1"
    End If
    
    If InStr(LCase(columns), "created") > 0 Then
        testSQL = testSQL & " ORDER BY created DESC"
    ElseIf InStr(LCase(columns), "datecreated") > 0 Then
        testSQL = testSQL & " ORDER BY dateCreated DESC"
    Else
        testSQL = testSQL & " ORDER BY scenarioID DESC"
    End If
    
    Response.Write "<div class='code'>" & testSQL & "</div>"
    
    ' Testar o SQL
    On Error Resume Next
    Call getRecordSet(testSQL, rs)
    
    If Err.Number = 0 Then
        Response.Write "<p class='success'>✓ SQL funcionou!</p>"
    Else
        Response.Write "<p class='error'>✗ Erro: " & Err.Description & "</p>"
        Err.Clear
    End If
    
    On Error Goto 0
    %>
    
    <h2>3. Código Corrigido para Copiar</h2>
    <p>Copie e cole este código no seu arquivo <strong>INC_SCENARIO.inc</strong>:</p>
    
    <div class="code" style="max-height: 400px; overflow-y: auto;">
<pre>&lt;%
Function SQL_CONSULTA_SCENARIOS(stepID)
    On Error Resume Next
    If Not IsNumeric(stepID) Or stepID = "" Then
        SQL_CONSULTA_SCENARIOS = ""
        Exit Function
    End If
    
    <%
    If InStr(LCase(columns), "description") > 0 Then
        Response.Write "SQL_CONSULTA_SCENARIOS = ""SELECT scenarioID, stepID, name, description, scenario"
    Else
        Response.Write "SQL_CONSULTA_SCENARIOS = ""SELECT scenarioID, stepID, name, scenario"
    End If
    
    If InStr(LCase(columns), "created") > 0 Then
        Response.Write ", created FROM T_FTA_METHOD_SCENARIOS WHERE stepID = "" & stepID & "" ORDER BY created DESC"""
    ElseIf InStr(LCase(columns), "datecreated") > 0 Then
        Response.Write ", dateCreated as created FROM T_FTA_METHOD_SCENARIOS WHERE stepID = "" & stepID & "" ORDER BY dateCreated DESC"""
    Else
        Response.Write " FROM T_FTA_METHOD_SCENARIOS WHERE stepID = "" & stepID & "" ORDER BY scenarioID DESC"""
    End If
    %>
    
    On Error Goto 0
End Function

Function SQL_CONSULTA_SCENARIOS_BY_SCENARIO_ID(scenarioID)
    On Error Resume Next
    If Not IsNumeric(scenarioID) Or scenarioID = "" Then
        SQL_CONSULTA_SCENARIOS_BY_SCENARIO_ID = ""
        Exit Function
    End If
    
    <%
    If InStr(LCase(columns), "description") > 0 Then
        Response.Write "SQL_CONSULTA_SCENARIOS_BY_SCENARIO_ID = ""SELECT scenarioID, stepID, name, description, scenario"
    Else
        Response.Write "SQL_CONSULTA_SCENARIOS_BY_SCENARIO_ID = ""SELECT scenarioID, stepID, name, scenario"
    End If
    
    If InStr(LCase(columns), "created") > 0 Then
        Response.Write ", created FROM T_FTA_METHOD_SCENARIOS WHERE scenarioID = "" & scenarioID"
    ElseIf InStr(LCase(columns), "datecreated") > 0 Then
        Response.Write ", dateCreated as created FROM T_FTA_METHOD_SCENARIOS WHERE scenarioID = "" & scenarioID"
    Else
        Response.Write " FROM T_FTA_METHOD_SCENARIOS WHERE scenarioID = "" & scenarioID"
    End If
    %>
    
    On Error Goto 0
End Function

Function SQL_CRIA_SCENARIO(stepID, name, scenario)
    On Error Resume Next
    If Not IsNumeric(stepID) Or stepID = "" Then
        SQL_CRIA_SCENARIO = ""
        Exit Function
    End If
    
    Dim safeName, safeScenario
    safeName = Replace(CStr(name), "'", "''")
    safeScenario = Replace(CStr(scenario), "'", "''")
    
    <%
    If InStr(LCase(columns), "description") > 0 Then
        Response.Write "SQL_CRIA_SCENARIO = ""INSERT INTO T_FTA_METHOD_SCENARIOS (stepID, name, description, scenario"
    Else
        Response.Write "SQL_CRIA_SCENARIO = ""INSERT INTO T_FTA_METHOD_SCENARIOS (stepID, name, scenario"
    End If
    
    If InStr(LCase(columns), "created") > 0 Then
        Response.Write ", created) VALUES ("" & stepID & "", '"" & safeName & """
        If InStr(LCase(columns), "description") > 0 Then
            Response.Write ", ''"
        End If
        Response.Write ", '"" & safeScenario & ""', GETDATE())"""
    ElseIf InStr(LCase(columns), "datecreated") > 0 Then
        Response.Write ", dateCreated) VALUES ("" & stepID & "", '"" & safeName & """
        If InStr(LCase(columns), "description") > 0 Then
            Response.Write ", ''"
        End If
        Response.Write ", '"" & safeScenario & ""', GETDATE())"""
    Else
        Response.Write ") VALUES ("" & stepID & "", '"" & safeName & """
        If InStr(LCase(columns), "description") > 0 Then
            Response.Write ", ''"
        End If
        Response.Write ", '"" & safeScenario & ""')"""
    End If
    %>
    
    On Error Goto 0
End Function

Function SQL_ATUALIZA_SCENARIO(scenarioID, name, scenario)
    On Error Resume Next
    If Not IsNumeric(scenarioID) Or scenarioID = "" Then
        SQL_ATUALIZA_SCENARIO = ""
        Exit Function
    End If
    
    Dim safeName, safeScenario
    safeName = Replace(CStr(name), "'", "''")
    safeScenario = Replace(CStr(scenario), "'", "''")
    
    SQL_ATUALIZA_SCENARIO = "UPDATE T_FTA_METHOD_SCENARIOS SET name = '" & safeName & "', scenario = '" & safeScenario & "' WHERE scenarioID = " & scenarioID
    On Error Goto 0
End Function

Function SQL_DELETE_SCENARIO(scenarioID)
    On Error Resume Next
    If Not IsNumeric(scenarioID) Or scenarioID = "" Then
        SQL_DELETE_SCENARIO = ""
        Exit Function
    End If
    SQL_DELETE_SCENARIO = "DELETE FROM T_FTA_METHOD_SCENARIOS WHERE scenarioID = " & scenarioID
    On Error Goto 0
End Function

Function ValidateScenarioInput(input)
    On Error Resume Next
    If IsNull(input) Then
        ValidateScenarioInput = ""
        Exit Function
    End If
    
    Dim cleanInput
    cleanInput = CStr(input)
    cleanInput = Replace(cleanInput, "'", "''")
    cleanInput = Replace(cleanInput, """", """""")
    cleanInput = Replace(cleanInput, ";", "")
    cleanInput = Replace(cleanInput, "--", "")
    
    ValidateScenarioInput = cleanInput
    On Error Goto 0
End Function
%&gt;</pre>
    </div>
    
    <h2>🚀 Teste Final</h2>
    <p>Depois de substituir o arquivo:</p>
    <ol>
        <li>Substitua <code>/FTA/scenario/INC_SCENARIO.inc</code> com o código acima</li>
        <li>Substitua <code>/FTA/scenario/index.asp</code> com a versão corrigida</li>
        <li>Teste: <a href="index.asp?stepID=1" style="background: #28a745; color: white; padding: 10px 15px; text-decoration: none; border-radius: 5px;">🎯 Testar Scenario Agora</a></li>
    </ol>
    
    <p><strong>O erro "Sintaxe incorreta próxima a '='" estará resolvido!</strong> 🎉</p>
</body>
</html>