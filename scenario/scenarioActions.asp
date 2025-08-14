<!--#include virtual="/system.asp"-->
<!--#include file="INC_SCENARIO.inc"-->

<%
' Processar ações dos cenários
Dim action, stepID, scenarioID, name, scenario, url

action = Request.QueryString("action")
stepID = Request.Form("stepID")
scenarioID = Request.Form("scenarioID")
name = Request.Form("name")
scenario = Request.Form("scenario")

' URL padrão de retorno
url = "index.asp?stepID=" & stepID

Select Case LCase(action)

Case "save"
    ' Validar dados obrigatórios
    If stepID = "" Or Not IsNumeric(stepID) Then
        Response.Write "Error: Invalid step ID"
        Response.End
    End If
    
    If name = "" Then
        Response.Write "Error: Scenario name is required"
        Response.End
    End If
    
    On Error Resume Next
    
    If scenarioID <> "" And IsNumeric(scenarioID) Then
        ' Atualizar cenário existente
        Dim updateSQL
        updateSQL = SQL_ATUALIZA_SCENARIO(scenarioID, name, scenario)
        
        If updateSQL <> "" Then
            Call ExecuteSQL(updateSQL)
            
            If Err.Number = 0 Then
                Session("successMessage") = "Scenario updated successfully!"
            Else
                Session("errorMessage") = "Error updating scenario: " & Err.Description
                Err.Clear
            End If
        Else
            Session("errorMessage") = "Error generating update SQL"
        End If
    Else
        ' Criar novo cenário
        Dim createSQL
        createSQL = SQL_CRIA_SCENARIO(stepID, name, scenario)
        
        If createSQL <> "" Then
            Call ExecuteSQL(createSQL)
            
            If Err.Number = 0 Then
                Session("successMessage") = "Scenario created successfully!"
            Else
                Session("errorMessage") = "Error creating scenario: " & Err.Description
                Err.Clear
            End If
        Else
            Session("errorMessage") = "Error generating create SQL"
        End If
    End If
    
    On Error Goto 0

Case "delete"
    ' Deletar cenário
    scenarioID = Request.QueryString("scenarioID")
    stepID = Request.QueryString("stepID")
    
    If scenarioID <> "" And IsNumeric(scenarioID) Then
        On Error Resume Next
        
        Dim deleteSQL
        deleteSQL = SQL_DELETE_SCENARIO(scenarioID)
        
        If deleteSQL <> "" Then
            Call ExecuteSQL(deleteSQL)
            
            If Err.Number = 0 Then
                Session("successMessage") = "Scenario deleted successfully!"
            Else
                Session("errorMessage") = "Error deleting scenario: " & Err.Description
                Err.Clear
            End If
        End If
        
        On Error Goto 0
    End If
    
    url = "index.asp?stepID=" & stepID

Case "end"
    ' Finalizar step
    If stepID <> "" And IsNumeric(stepID) Then
        Call endStep(stepID)
        url = "/workplace.asp"
    End If

Case Else
    Session("errorMessage") = "Invalid action: " & action

End Select

' Redirecionar
Response.Redirect url
%>