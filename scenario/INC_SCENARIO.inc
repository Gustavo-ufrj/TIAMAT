<%
'
' INC_SCENARIO.inc - Versão Final Corrigida
' Baseado na estrutura real da tabela T_FTA_METHOD_SCENARIOS
' Colunas: scenarioID, stepID, name, description, scenario
' SEM coluna de data (por isso o erro original)
'

Function SQL_CONSULTA_SCENARIOS(stepID)
    On Error Resume Next
    If Not IsNumeric(stepID) Or stepID = "" Then
        SQL_CONSULTA_SCENARIOS = ""
        Exit Function
    End If
    
    SQL_CONSULTA_SCENARIOS = "SELECT scenarioID, stepID, name, description, scenario FROM T_FTA_METHOD_SCENARIOS WHERE stepID = " & stepID & " ORDER BY scenarioID DESC"
    
    On Error Goto 0
End Function

Function SQL_CONSULTA_SCENARIOS_BY_SCENARIO_ID(scenarioID)
    On Error Resume Next
    If Not IsNumeric(scenarioID) Or scenarioID = "" Then
        SQL_CONSULTA_SCENARIOS_BY_SCENARIO_ID = ""
        Exit Function
    End If
    
    SQL_CONSULTA_SCENARIOS_BY_SCENARIO_ID = "SELECT scenarioID, stepID, name, description, scenario FROM T_FTA_METHOD_SCENARIOS WHERE scenarioID = " & scenarioID
    
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
    
    ' CORREÇÃO: Sintaxe correta do INSERT com description vazia
    SQL_CRIA_SCENARIO = "INSERT INTO T_FTA_METHOD_SCENARIOS (stepID, name, description, scenario) VALUES (" & stepID & ", '" & safeName & "', '', '" & safeScenario & "')"
    
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

%>