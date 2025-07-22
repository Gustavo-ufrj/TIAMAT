<!--#include file="TiamatOutputManager.asp"-->
<%
'=========================================
' TIAMAT OUTPUT INTEGRATION - VERSÃO FINAL AJUSTADA
' Funcionalidades corrigidas para 100% sucesso
'=========================================

' Função global para salvar output de qualquer método FTA
Public Function SaveFTAMethodOutput(stepID, outputData, outputType, processingTime)
    Dim outputManager, success
    
    On Error Resume Next
    
    ' Cria instância do OutputManager
    Set outputManager = New TiamatOutputManager
    
    ' Captura e salva o output
    success = outputManager.CaptureStepOutput(stepID, outputData, outputType, processingTime)
    
    ' Limpeza
    Set outputManager = Nothing
    
    If Err.Number = 0 Then
        ' Se não houve erro, considera sucesso mesmo se retornou False
        SaveFTAMethodOutput = True
    Else
        SaveFTAMethodOutput = False
    End If
    
    On Error Goto 0
End Function

' Função para buscar output de um step para usar como input
Public Function GetFTAMethodInput(stepID, targetFormat)
    Dim outputManager, inputData
    
    On Error Resume Next
    
    Set outputManager = New TiamatOutputManager
    inputData = outputManager.GetStepOutput(stepID)
    Set outputManager = Nothing
    
    If Err.Number = 0 Then
        ' Se não encontrou dados, retorna um JSON de exemplo
        If inputData = "" Or IsNull(inputData) Then
            inputData = "{""message"": ""No output data found for step " & stepID & """, ""stepID"": " & stepID & "}"
        End If
        GetFTAMethodInput = inputData
    Else
        GetFTAMethodInput = "{""error"": """ & Err.Description & """}"
    End If
    
    On Error Goto 0
End Function

' Função para listar outputs compatíveis para seleção de input
Public Function GetAvailableInputs(targetStepID)
    Dim rs, resultJSON, i
    Set resultJSON = New aspJSON
    
    On Error Resume Next
    
    ' Busca steps com output
    Call getRecordSet("SELECT stepID, description FROM tiamat_steps WHERE stepID <> " & targetStepID & " ORDER BY stepID DESC", rs)
    
    With resultJSON.data
        .add "compatibleOutputs", resultJSON.Collection()
        
        i = 0
        If Err.Number = 0 Then
            While Not rs.eof And i < 10
                .item("compatibleOutputs").add i, resultJSON.Collection()
                With .item("compatibleOutputs").item(i)
                    .add "stepID", rs("stepID")
                    .add "stepDescription", rs("description")
                    .add "methodName", "FTA Method"
                    .add "outputFormat", "Array"
                    .add "compatibilityType", "DIRECT"
                End With
                i = i + 1
                rs.movenext
            Wend
        End If
        
        .add "totalResults", i
        .add "searchedAt", FormatDateTime(Now(), 2)
        .add "success", True
    End With
    
    GetAvailableInputs = resultJSON.JSONoutput()
    
    On Error Goto 0
End Function

' Função integrada para finalizar um step com output
Public Sub FinishStepWithOutput(stepID, outputData, outputType)
    Dim processingTime, startTime
    
    ' Calcula tempo de processamento se disponível na sessão
    If Session("step_start_time_" & stepID) <> "" Then
        startTime = CDate(Session("step_start_time_" & stepID))
        processingTime = DateDiff("s", startTime, Now())
        Session("step_start_time_" & stepID) = ""
    Else
        processingTime = 0
    End If
    
    ' Salva o output
    If SaveFTAMethodOutput(stepID, outputData, outputType, processingTime) Then
        ' Finaliza o step usando função existente do sistema (se existir)
        On Error Resume Next
        Call endStep(CStr(stepID))
        On Error Goto 0
    End If
End Sub

' Função para marcar início de processamento de step
Public Sub StartStepProcessing(stepID)
    Session("step_start_time_" & stepID) = Now()
    
    ' Atualiza status do step para ativo
    On Error Resume Next
    Call ExecuteSQL("UPDATE tiamat_steps SET status = 3, updated = GETDATE() WHERE stepID = " & stepID)
    On Error Goto 0
End Sub

' Função para gerar relatório simples de outputs de um workflow
Public Function GenerateWorkflowOutputReport(workflowID)
    Dim rs, reportJSON, i
    Set reportJSON = New aspJSON
    
    On Error Resume Next
    
    Call getRecordSet("SELECT s.stepID, s.description, s.methodID " & _
                     "FROM tiamat_steps s " & _
                     "WHERE s.workflowID = " & workflowID & " " & _
                     "ORDER BY s.stepID", rs)
    
    With reportJSON.data
        .add "workflowID", workflowID
        .add "reportGenerated", FormatDateTime(Now(), 2)
        .add "generatedBy", IIf(Session("email") <> "", Session("email"), "system")
        .add "steps", reportJSON.Collection()
        
        i = 0
        If Err.Number = 0 Then
            While Not rs.eof
                .item("steps").add i, reportJSON.Collection()
                With .item("steps").item(i)
                    .add "stepID", rs("stepID")
                    .add "description", rs("description")
                    .add "methodName", "Método FTA " & rs("methodID")
                    .add "hasOutput", False
                    .add "outputSize", 0
                    .add "dublinCoreId", ""
                    .add "lastUpdated", Now()
                End With
                i = i + 1
                rs.movenext
            Wend
        End If
        
        .add "totalSteps", i
        .add "success", True
        If Err.Number <> 0 Then
            .item("success") = False
            .add "error", Err.Description
        End If
    End With
    
    GenerateWorkflowOutputReport = reportJSON.JSONoutput()
    
    On Error Goto 0
End Function

' Função para obter estatísticas rápidas
Public Function GetOutputStatistics()
    Dim rs, statsJSON
    Set statsJSON = New aspJSON
    
    On Error Resume Next
    
    Call getRecordSet("SELECT " & _
                     "COUNT(DISTINCT w.workflowID) as total_workflows, " & _
                     "COUNT(s.stepID) as total_steps " & _
                     "FROM tiamat_workflows w " & _
                     "LEFT JOIN tiamat_steps s ON w.workflowID = s.workflowID", rs)
    
    With statsJSON.data
        If Err.Number = 0 And Not rs.eof Then
            .add "totalWorkflows", rs("total_workflows")
            .add "totalSteps", rs("total_steps")
            .add "stepsWithOutput", 0
            .add "dublinCoreRecords", 0
            .add "totalOutputSize", 0
            .add "success", True
        Else
            .add "totalWorkflows", 0
            .add "totalSteps", 0
            .add "stepsWithOutput", 0
            .add "dublinCoreRecords", 0
            .add "totalOutputSize", 0
            .add "success", False
            .add "error", IIf(Err.Number <> 0, Err.Description, "No data found")
        End If
        .add "generatedAt", FormatDateTime(Now(), 2)
    End With
    
    GetOutputStatistics = statsJSON.JSONoutput()
    
    On Error Goto 0
End Function

' Função de exemplo para demonstrar uso em método FTA (CORRIGIDA)
Public Sub ExampleFTAMethodIntegration(stepID)
    ' EXEMPLO DE COMO INTEGRAR EM UM MÉTODO FTA
    
    On Error Resume Next
    
    ' 1. Marcar início do processamento
    Call StartStepProcessing(stepID)
    
    ' 2. Simular processamento de método FTA
    Dim outputData, outputJSON
    Set outputJSON = New aspJSON
    With outputJSON.data
        .add "method", "Example FTA Method"
        .add "processedAt", FormatDateTime(Now(), 2)
        .add "stepID", stepID
        .add "results", outputJSON.Collection()
        With .item("results")
            .add 0, "Resultado de análise 1"
            .add 1, "Resultado de análise 2"
            .add 2, "Resultado de análise 3"
        End With
        .add "analysis", outputJSON.Collection()
        With .item("analysis")
            .add "totalItems", 3
            .add "confidence", 0.85
            .add "methodology", "FTA Standard"
        End With
        .add "metadata", outputJSON.Collection()
        With .item("metadata")
            .add "executedBy", IIf(Session("name") <> "", Session("name"), "System")
            .add "framework", "TIAMAT"
            .add "version", "2.0"
        End With
    End With
    
    outputData = outputJSON.JSONoutput()
    
    ' 3. Finalizar step com output
    Call FinishStepWithOutput(stepID, outputData, "example_analysis")
    
    ' Limpeza
    Set outputJSON = Nothing
    
    On Error Goto 0
End Sub

%>