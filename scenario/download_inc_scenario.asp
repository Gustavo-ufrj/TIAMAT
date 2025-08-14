<!--#include virtual="/system.asp"-->
<%
Response.ContentType = "text/plain; charset=utf-8"
Response.AddHeader "Content-Disposition", "attachment; filename=INC_SCENARIO.inc"

' Verificar estrutura da tabela para gerar código correto
Dim rs, hasCreated, hasDateCreated, hasDescription
hasCreated = False
hasDateCreated = False  
hasDescription = False

On Error Resume Next
Call getRecordSet("SELECT COLUMN_NAME FROM INFORMATION_SCHEMA.COLUMNS WHERE TABLE_NAME = 'T_FTA_METHOD_SCENARIOS'", rs)

If Err.Number = 0 And Not rs.eof Then
    While Not rs.eof
        Dim colName
        colName = LCase(rs("COLUMN_NAME"))
        If colName = "created" Then hasCreated = True
        If colName = "datecreated" Then hasDateCreated = True
        If colName = "description" Then hasDescription = True
        rs.movenext
    Wend
End If

On Error Goto 0

' Gerar código baseado na estrutura encontrada
Response.Write "<%"
Response.Write vbCrLf & "'"
Response.Write vbCrLf & "' INC_SCENARIO.inc - Versão Corrigida Final"
Response.Write vbCrLf & "' Gerado automaticamente baseado na estrutura da tabela T_FTA_METHOD_SCENARIOS"
Response.Write vbCrLf & "' Data: " & FormatDateTime(Now(), 2)
Response.Write vbCrLf & "'"
Response.Write vbCrLf

' SQL_CONSULTA_SCENARIOS
Response.Write vbCrLf & "Function SQL_CONSULTA_SCENARIOS(stepID)"
Response.Write vbCrLf & "    On Error Resume Next"
Response.Write vbCrLf & "    If Not IsNumeric(stepID) Or stepID = """" Then"
Response.Write vbCrLf & "        SQL_CONSULTA_SCENARIOS = """""
Response.Write vbCrLf & "        Exit Function"
Response.Write vbCrLf & "    End If"
Response.Write vbCrLf

Response.Write vbCrLf & "    SQL_CONSULTA_SCENARIOS = ""SELECT scenarioID, stepID, name"

If hasDescription Then
    Response.Write ", description"
End If

Response.Write ", scenario"

If hasCreated Then
    Response.Write ", created"
ElseIf hasDateCreated Then
    Response.Write ", dateCreated as created"
End If

Response.Write " FROM T_FTA_METHOD_SCENARIOS WHERE stepID = "" & stepID & """

If hasCreated Then
    Response.Write " ORDER BY created DESC"""
ElseIf hasDateCreated Then
    Response.Write " ORDER BY dateCreated DESC"""
Else
    Response.Write " ORDER BY scenarioID DESC"""
End If

Response.Write vbCrLf & "    On Error Goto 0"
Response.Write vbCrLf & "End Function"
Response.Write vbCrLf

' SQL_CONSULTA_SCENARIOS_BY_SCENARIO_ID
Response.Write vbCrLf & "Function SQL_CONSULTA_SCENARIOS_BY_SCENARIO_ID(scenarioID)"
Response.Write vbCrLf & "    On Error Resume Next"
Response.Write vbCrLf & "    If Not IsNumeric(scenarioID) Or scenarioID = """" Then"
Response.Write vbCrLf & "        SQL_CONSULTA_SCENARIOS_BY_SCENARIO_ID = """""
Response.Write vbCrLf & "        Exit Function"
Response.Write vbCrLf & "    End If"
Response.Write vbCrLf

Response.Write vbCrLf & "    SQL_CONSULTA_SCENARIOS_BY_SCENARIO_ID = ""SELECT scenarioID, stepID, name"

If hasDescription Then
    Response.Write ", description"
End If

Response.Write ", scenario"

If hasCreated Then
    Response.Write ", created"
ElseIf hasDateCreated Then
    Response.Write ", dateCreated as created"
End If

Response.Write " FROM T_FTA_METHOD_SCENARIOS WHERE scenarioID = "" & scenarioID"

Response.Write vbCrLf & "    On Error Goto 0"
Response.Write vbCrLf & "End Function"
Response.Write vbCrLf

' SQL_CRIA_SCENARIO
Response.Write vbCrLf & "Function SQL_CRIA_SCENARIO(stepID, name, scenario)"
Response.Write vbCrLf & "    On Error Resume Next"
Response.Write vbCrLf & "    If Not IsNumeric(stepID) Or stepID = """" Then"
Response.Write vbCrLf & "        SQL_CRIA_SCENARIO = """""
Response.Write vbCrLf & "        Exit Function"
Response.Write vbCrLf & "    End If"
Response.Write vbCrLf
Response.Write vbCrLf & "    Dim safeName, safeScenario"
Response.Write vbCrLf & "    safeName = Replace(CStr(name), ""'"", ""''"")"
Response.Write vbCrLf & "    safeScenario = Replace(CStr(scenario), ""'"", ""''"")"
Response.Write vbCrLf

Response.Write vbCrLf & "    SQL_CRIA_SCENARIO = ""INSERT INTO T_FTA_METHOD_SCENARIOS (stepID, name"

If hasDescription Then
    Response.Write ", description"
End If

Response.Write ", scenario"

If hasCreated Then
    Response.Write ", created"
ElseIf hasDateCreated Then
    Response.Write ", dateCreated"
End If

Response.Write ") VALUES ("" & stepID & "", '"" & safeName & """"

If hasDescription Then
    Response.Write " & "", ''"" "
End If

Response.Write " & "", '"" & safeScenario & """"

If hasCreated Or hasDateCreated Then
    Response.Write " & "", GETDATE()"
End If

Response.Write " & "")"""

Response.Write vbCrLf & "    On Error Goto 0"
Response.Write vbCrLf & "End Function"
Response.Write vbCrLf

' SQL_ATUALIZA_SCENARIO
Response.Write vbCrLf & "Function SQL_ATUALIZA_SCENARIO(scenarioID, name, scenario)"
Response.Write vbCrLf & "    On Error Resume Next"
Response.Write vbCrLf & "    If Not IsNumeric(scenarioID) Or scenarioID = """" Then"
Response.Write vbCrLf & "        SQL_ATUALIZA_SCENARIO = """""
Response.Write vbCrLf & "        Exit Function"
Response.Write vbCrLf & "    End If"
Response.Write vbCrLf
Response.Write vbCrLf & "    Dim safeName, safeScenario"
Response.Write vbCrLf & "    safeName = Replace(CStr(name), ""'"", ""''"")"
Response.Write vbCrLf & "    safeScenario = Replace(CStr(scenario), ""'"", ""''"")"
Response.Write vbCrLf
Response.Write vbCrLf & "    SQL_ATUALIZA_SCENARIO = ""UPDATE T_FTA_METHOD_SCENARIOS SET name = '"" & safeName & ""', scenario = '"" & safeScenario & ""' WHERE scenarioID = "" & scenarioID"
Response.Write vbCrLf & "    On Error Goto 0"
Response.Write vbCrLf & "End Function"
Response.Write vbCrLf

' SQL_DELETE_SCENARIO
Response.Write vbCrLf & "Function SQL_DELETE_SCENARIO(scenarioID)"
Response.Write vbCrLf & "    On Error Resume Next"
Response.Write vbCrLf & "    If Not IsNumeric(scenarioID) Or scenarioID = """" Then"
Response.Write vbCrLf & "        SQL_DELETE_SCENARIO = """""
Response.Write vbCrLf & "        Exit Function"
Response.Write vbCrLf & "    End If"
Response.Write vbCrLf & "    SQL_DELETE_SCENARIO = ""DELETE FROM T_FTA_METHOD_SCENARIOS WHERE scenarioID = "" & scenarioID"
Response.Write vbCrLf & "    On Error Goto 0"
Response.Write vbCrLf & "End Function"
Response.Write vbCrLf

' ValidateScenarioInput
Response.Write vbCrLf & "Function ValidateScenarioInput(input)"
Response.Write vbCrLf & "    On Error Resume Next"
Response.Write vbCrLf & "    If IsNull(input) Then"
Response.Write vbCrLf & "        ValidateScenarioInput = """""
Response.Write vbCrLf & "        Exit Function"
Response.Write vbCrLf & "    End If"
Response.Write vbCrLf
Response.Write vbCrLf & "    Dim cleanInput"
Response.Write vbCrLf & "    cleanInput = CStr(input)"
Response.Write vbCrLf & "    cleanInput = Replace(cleanInput, ""'"", ""''"")"
Response.Write vbCrLf & "    cleanInput = Replace(cleanInput, """""", """""""")"
Response.Write vbCrLf & "    cleanInput = Replace(cleanInput, "";"", """")"
Response.Write vbCrLf & "    cleanInput = Replace(cleanInput, ""--"", """")"
Response.Write vbCrLf
Response.Write vbCrLf & "    ValidateScenarioInput = cleanInput"
Response.Write vbCrLf & "    On Error Goto 0"
Response.Write vbCrLf & "End Function"
Response.Write vbCrLf

Response.Write vbCrLf & "%>"
%>