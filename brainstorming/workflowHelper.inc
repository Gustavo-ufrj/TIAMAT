<%
' Funções auxiliares para gerenciamento de workflow

' Estados dos steps
Const STATE_INACTIVE = 0
Const STATE_ACTIVE = 1
Const STATE_COMPLETED = 2
Const STATE_BLOCKED = 3

' Função para finalizar um step e ativar os próximos
Sub finalizeStepAndActivateNext(stepID)
    Dim rs, rs2
    Dim workflowID
    Dim nextStepID
    Dim canActivate
    
    ' Marca o step atual como completado
    Call ExecuteSQL("UPDATE T_WORKFLOW_STEP SET status = " & STATE_COMPLETED & ", end_date = GETDATE() WHERE stepID = " & stepID)
    
    ' Obtém o workflowID
    Call getRecordSet("SELECT workflowID FROM T_WORKFLOW_STEP WHERE stepID = " & stepID, rs)
    
    If Not rs.EOF Then
        workflowID = rs("workflowID")
        
        ' Busca todos os próximos steps ligados a este
        Call getRecordSet("SELECT nextStepID FROM T_WORKFLOW_STEP_X_STEP WHERE stepID = " & stepID, rs)
        
        While Not rs.EOF
            nextStepID = rs("nextStepID")
            canActivate = True
            
            ' Verifica se todos os pré-requisitos do próximo step foram completados
            Call getRecordSet("SELECT ws.status FROM T_WORKFLOW_STEP_X_STEP wss " & _
                             "INNER JOIN T_WORKFLOW_STEP ws ON wss.stepID = ws.stepID " & _
                             "WHERE wss.nextStepID = " & nextStepID, rs2)
            
            While Not rs2.EOF
                If rs2("status") <> STATE_COMPLETED Then
                    canActivate = False
                    Exit While
                End If
                rs2.MoveNext()
            Wend
            
            ' Se todos os pré-requisitos foram atendidos, ativa o próximo step
            If canActivate Then
                Call ExecuteSQL("UPDATE T_WORKFLOW_STEP SET status = " & STATE_ACTIVE & ", start_date = GETDATE() WHERE stepID = " & nextStepID)
            End If
            
            rs.MoveNext()
        Wend
    End If
End Sub

' Função para obter o status de um step
Function getStepStatus(stepID)
    Dim rs
    Call getRecordSet("SELECT status FROM T_WORKFLOW_STEP WHERE stepID = " & stepID, rs)
    
    If Not rs.EOF Then
        getStepStatus = rs("status")
    Else
        getStepStatus = STATE_INACTIVE
    End If
End Function

' Função para verificar se um step pode ser ativado
Function canActivateStep(stepID)
    Dim rs
    Dim canActivate
    canActivate = True
    
    ' Verifica se todos os steps anteriores foram completados
    Call getRecordSet("SELECT ws.status FROM T_WORKFLOW_STEP_X_STEP wss " & _
                     "INNER JOIN T_WORKFLOW_STEP ws ON wss.stepID = ws.stepID " & _
                     "WHERE wss.nextStepID = " & stepID, rs)
    
    If rs.EOF Then
        ' Se não há pré-requisitos, pode ativar
        canActivateStep = True
    Else
        While Not rs.EOF
            If rs("status") <> STATE_COMPLETED Then
                canActivate = False
                Exit While
            End If
            rs.MoveNext()
        Wend
        canActivateStep = canActivate
    End If
End Function

' Função para obter a cor do step baseado no status
Function getStepColor(status)
    Select Case status
        Case STATE_INACTIVE
            getStepColor = "#CCCCCC" ' Cinza
        Case STATE_ACTIVE
            getStepColor = "#90EE90" ' Verde claro
        Case STATE_COMPLETED
            getStepColor = "#FFFFFF" ' Branco
        Case STATE_BLOCKED
            getStepColor = "#FFB6C1" ' Vermelho claro
        Case Else
            getStepColor = "#CCCCCC" ' Cinza padrão
    End Select
End Function

' Função para atualizar o status de todos os steps de um workflow
Sub updateWorkflowStatus(workflowID)
    Dim rs, rs2
    Dim stepID
    Dim canActivate
    
    ' Busca todos os steps do workflow
    Call getRecordSet("SELECT stepID FROM T_WORKFLOW_STEP WHERE workflowID = " & workflowID, rs)
    
    While Not rs.EOF
        stepID = rs("stepID")
        
        ' Verifica o status atual
        Call getRecordSet("SELECT status FROM T_WORKFLOW_STEP WHERE stepID = " & stepID, rs2)
        
        If Not rs2.EOF Then
            If rs2("status") = STATE_INACTIVE Then
                ' Verifica se pode ser ativado
                If canActivateStep(stepID) Then
                    Call ExecuteSQL("UPDATE T_WORKFLOW_STEP SET status = " & STATE_ACTIVE & " WHERE stepID = " & stepID)
                End If
            End If
        End If
        
        rs.MoveNext()
    Wend
End Sub
%>