<!--#include virtual="/system.asp"-->
<!--#include file="INC_SCENARIO.inc"-->
<%
'=========================================
' scenarioActions.asp - VERSAO FINAL CORRIGIDA
'=========================================

Dim action, stepID, scenarioID, name, scenario

' Pegar parametros de GET ou POST
action = Request("action")  ' Pega de GET ou POST
stepID = Request("stepID")
scenarioID = Request("scenarioID")
name = Request("name")
scenario = Request("scenario")

' Debug
Response.Write "<!-- DEBUG: action=" & action & ", stepID=" & stepID & " -->" & vbCrLf

' Processar acao
Select Case LCase(action)

    Case "save"
        ' Salvar cenario (criar ou atualizar)
        name = Trim(name)
        scenario = Trim(scenario)
        
        If name <> "" And scenario <> "" And stepID <> "" Then
            On Error Resume Next
            
            If scenarioID <> "" And IsNumeric(scenarioID) Then
                ' Atualizar cenario existente
                Call ExecuteSQL(SQL_ATUALIZA_SCENARIO(scenarioID, name, scenario))
            Else
                ' Criar novo cenario
                Call ExecuteSQL(SQL_CRIA_SCENARIO(stepID, name, scenario))
            End If
            
            If Err.Number <> 0 Then
                Response.Write "<script>alert('Erro: " & Replace(Err.Description, "'", "\'") & "'); history.back();</script>"
                Response.End
            End If
            
            On Error Goto 0
        End If
        
        Response.Redirect "index.asp?stepID=" & stepID

    Case "delete"
        ' Deletar cenario
        If scenarioID <> "" And IsNumeric(scenarioID) Then
            On Error Resume Next
            Call ExecuteSQL(SQL_DELETA_SCENARIO(scenarioID))
            On Error Goto 0
        End If
        
        Response.Redirect "index.asp?stepID=" & stepID

    Case "finalize_scenarios", "end", "finalize"
        ' Finalizar cenarios - CORRIGIDO
        Response.Write "<!-- DEBUG: Finalizando cenarios para stepID=" & stepID & " -->" & vbCrLf
        
        If stepID <> "" And IsNumeric(stepID) Then
            On Error Resume Next
            
            ' Verificar se tem cenarios
            call getRecordSet("SELECT COUNT(*) as total FROM T_FTA_METHOD_SCENARIOS WHERE stepID = " & stepID, rs)
            
            If Err.Number <> 0 Then
                Response.Write "<script>alert('Erro ao verificar cenários: " & Replace(Err.Description, "'", "\'") & "'); history.back();</script>"
                Response.End
            End If
            
            If Not rs.EOF Then
                Dim totalScenarios
                totalScenarios = rs("total")
                Response.Write "<!-- DEBUG: Total de cenarios=" & totalScenarios & " -->" & vbCrLf
                
                If totalScenarios > 0 Then
                    ' Finalizar step
                    Response.Write "<!-- DEBUG: Chamando endStep(" & stepID & ") -->" & vbCrLf
                    
                    Call endStep(stepID)
                    
                    If Err.Number <> 0 Then
                        Response.Write "<script>alert('Erro ao finalizar step: " & Replace(Err.Description, "'", "\'") & "'); history.back();</script>"
                        Response.End
                    Else
                        Response.Write "<!-- DEBUG: Step finalizado com sucesso -->" & vbCrLf
                        Response.Write "<script>" & vbCrLf
                        Response.Write "alert('Cenários finalizados com sucesso!');" & vbCrLf
                        Response.Write "window.location.href = '/workplace.asp';" & vbCrLf
                        Response.Write "</script>" & vbCrLf
                        Response.End
                    End If
                Else
                    Response.Write "<script>" & vbCrLf
                    Response.Write "alert('Por favor, crie pelo menos um cenário antes de finalizar.');" & vbCrLf
                    Response.Write "window.location.href = 'index.asp?stepID=" & stepID & "';" & vbCrLf
                    Response.Write "</script>" & vbCrLf
                    Response.End
                End If
            Else
                Response.Write "<script>alert('Erro: Não foi possível verificar cenários.'); history.back();</script>"
                Response.End
            End If
            
            On Error Goto 0
        Else
            Response.Write "<script>alert('Erro: StepID inválido.'); history.back();</script>"
            Response.End
        End If

    Case Else
        ' Acao nao reconhecida
        Response.Write "<!-- DEBUG: Acao nao reconhecida: " & action & " -->" & vbCrLf
        Response.Redirect "index.asp?stepID=" & stepID

End Select
%>