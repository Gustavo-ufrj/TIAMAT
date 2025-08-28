<%
'==================================================
' INC_SCENARIO.inc - VERSAO SIMPLIFICADA
' Funcoes SQL para o modulo Scenario
' Tabela correta: T_FTA_METHOD_SCENARIOS (com S)
'==================================================

' ========== FUNCOES SQL BASICAS ==========

Function SQL_CONSULTA_SCENARIOS(stepID)
    SQL_CONSULTA_SCENARIOS = "SELECT scenarioID, name, description, scenario " & _
                             "FROM T_FTA_METHOD_SCENARIOS " & _
                             "WHERE stepID = " & stepID & " " & _
                             "ORDER BY scenarioID"
End Function

Function SQL_CONSULTA_SCENARIOS_BY_SCENARIO_ID(scenarioID)
    SQL_CONSULTA_SCENARIOS_BY_SCENARIO_ID = "SELECT scenarioID, stepID, name, description, scenario " & _
                                            "FROM T_FTA_METHOD_SCENARIOS " & _
                                            "WHERE scenarioID = " & scenarioID
End Function

Function SQL_CRIA_SCENARIO(stepID, name, scenario)
    ' Escapar aspas simples
    name = Replace(name, "'", "''")
    scenario = Replace(scenario, "'", "''")
    
    SQL_CRIA_SCENARIO = "INSERT INTO T_FTA_METHOD_SCENARIOS (stepID, name, scenario, description) " & _
                        "VALUES (" & stepID & ", '" & name & "', '" & scenario & "', '')"
End Function

Function SQL_ATUALIZA_SCENARIO(scenarioID, name, scenario)
    ' Escapar aspas simples
    name = Replace(name, "'", "''")
    scenario = Replace(scenario, "'", "''")
    
    SQL_ATUALIZA_SCENARIO = "UPDATE T_FTA_METHOD_SCENARIOS " & _
                           "SET name = '" & name & "', " & _
                           "scenario = '" & scenario & "' " & _
                           "WHERE scenarioID = " & scenarioID
End Function

Function SQL_DELETA_SCENARIO(scenarioID)
    SQL_DELETA_SCENARIO = "DELETE FROM T_FTA_METHOD_SCENARIOS WHERE scenarioID = " & scenarioID
End Function

' ========== FUNCAO AUXILIAR ==========

Function CountWords(text)
    On Error Resume Next
    
    If IsNull(text) Or text = "" Then
        CountWords = 0
        Exit Function
    End If
    
    ' Remove tags HTML basico
    text = Replace(text, "<", " <")
    text = Replace(text, ">", "> ")
    
    Dim pos1, pos2
    Do While InStr(text, "<") > 0
        pos1 = InStr(text, "<")
        pos2 = InStr(pos1, text, ">")
        If pos2 > pos1 Then
            text = Left(text, pos1 - 1) & " " & Mid(text, pos2 + 1)
        Else
            Exit Do
        End If
    Loop
    
    ' Limpar espacos multiplos
    Do While InStr(text, "  ") > 0
        text = Replace(text, "  ", " ")
    Loop
    
    ' Contar palavras
    text = Trim(text)
    If text = "" Then
        CountWords = 0
    Else
        Dim words
        words = Split(text, " ")
        CountWords = UBound(words) + 1
    End If
    
    On Error Goto 0
End Function

%>