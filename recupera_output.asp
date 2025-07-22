<!--#include file="system.asp"-->
<%
'=========================================
' TIAMAT OUTPUT MANAGER
' Sistema para capturar outputs dos métodos FTA
' e estruturá-los em JSON com Dublin Core
'=========================================

Class TiamatOutputManager
    Private oJSON
    Private manifest
    
    Private Sub Class_Initialize()
        Set oJSON = New aspJSON
        Set manifest = LoadManifest()
    End Sub
    
    Private Sub Class_Terminate()
        Set oJSON = Nothing
        Set manifest = Nothing
    End Sub
    
    ' Função principal para capturar e estruturar output de um step
    Public Function CaptureStepOutput(stepID, outputData, outputType)
        Dim stepInfo, workflowInfo, methodInfo
        Dim jsonOutput
        
        ' Busca informações do step
        Set stepInfo = GetStepInfo(stepID)
        If stepInfo Is Nothing Then
            CaptureStepOutput = False
            Exit Function
        End If
        
        ' Busca informações do workflow
        Set workflowInfo = GetWorkflowInfo(stepInfo("workflowID"))
        
        ' Busca informações do método FTA
        Set methodInfo = GetMethodInfo(stepInfo("type"))
        
        ' Cria estrutura JSON com Dublin Core
        Set jsonOutput = CreateOutputJSON(stepInfo, workflowInfo, methodInfo, outputData, outputType)
        
        ' Salva o output no banco de dados
        If SaveOutputToDB(stepID, jsonOutput.JSONoutput()) Then
            CaptureStepOutput = True
        Else
            CaptureStepOutput = False
        End If
    End Function
    
    ' Busca informações do step
    Private Function GetStepInfo(stepID)
        Dim rs
        Call getRecordSet(SQL_CONSULTA_WORKFLOW_STEP_ID(stepID), rs)
        
        If Not rs.eof Then
            Set GetStepInfo = Server.CreateObject("Scripting.Dictionary")
            GetStepInfo.Add "stepID", rs("stepID")
            GetStepInfo.Add "workflowID", rs("workflowID")
            GetStepInfo.Add "type", rs("type")
            GetStepInfo.Add "description", rs("description")
            GetStepInfo.Add "goal", rs("goal")
            GetStepInfo.Add "status", rs("status")
            GetStepInfo.Add "created", rs("created")
            GetStepInfo.Add "updated", rs("updated")
        Else
            Set GetStepInfo = Nothing
        End If
    End Function
    
    ' Busca informações do workflow
    Private Function GetWorkflowInfo(workflowID)
        Dim rs
        Call getRecordSet(SQL_CONSULTA_WORKFLOW_ID(workflowID), rs)
        
        If Not rs.eof Then
            Set GetWorkflowInfo = Server.CreateObject("Scripting.Dictionary")
            GetWorkflowInfo.Add "workflowID", rs("workflowID")
            GetWorkflowInfo.Add "description", rs("description")
            GetWorkflowInfo.Add "goal", rs("goal")
            GetWorkflowInfo.Add "status", rs("status")
            GetWorkflowInfo.Add "created", rs("created")
        Else
            Set GetWorkflowInfo = Nothing
        End If
    End Function
    
    ' Busca informações do método FTA do manifest
    Private Function GetMethodInfo(methodID)
        Dim methodList, i
        Set methodList = getFTAMethodList(manifest)
        
        For i = 0 To methodList.length - 1
            If methodList(i).getAttribute("id") = CStr(methodID) Then
                Set GetMethodInfo = Server.CreateObject("Scripting.Dictionary")
                GetMethodInfo.Add "id", methodList(i).getAttribute("id")
                GetMethodInfo.Add "name", methodList(i).getAttribute("name")
                GetMethodInfo.Add "input_format", methodList(i).getAttribute("input_format")
                GetMethodInfo.Add "output_format", methodList(i).getAttribute("output_format")
                GetMethodInfo.Add "base_folder", methodList(i).getAttribute("base_folder")
                Exit Function
            End If
        Next
        
        Set GetMethodInfo = Nothing
    End Function
    
    ' Cria estrutura JSON com Dublin Core
    Private Function CreateOutputJSON(stepInfo, workflowInfo, methodInfo, outputData, outputType)
        Dim outputJSON
        Set outputJSON = New aspJSON
        
        With outputJSON.data
            ' Dublin Core Metadata
            .add "dublinCore", outputJSON.Collection()
            With .item("dublinCore")
                .add "title", stepInfo("description")
                .add "description", stepInfo("goal")
                .add "creator", Session("name")
                .add "subject", workflowInfo("description")
                .add "publisher", "TIAMAT Framework"
                .add "date", FormatDateTime(Now(), 2)
                .add "type", methodInfo("name")
                .add "format", methodInfo("output_format")
                .add "identifier", "TIAMAT-" & stepInfo("stepID") & "-" & Replace(FormatDateTime(Now(), 2), "/", "")
                .add "source", "Step " & stepInfo("stepID") & " - " & methodInfo("name")
                .add "language", "pt-BR"
                .add "relation", "Workflow " & workflowInfo("workflowID")
                .add "coverage", "Technology Foresight Analysis"
                .add "rights", "Internal Use - TIAMAT Framework"
            End With
            
            ' Metadados do TIAMAT
            .add "tiamatMetadata", outputJSON.Collection()
            With .item("tiamatMetadata")
                .add "stepID", stepInfo("stepID")
                .add "workflowID", workflowInfo("workflowID")
                .add "methodID", methodInfo("id")
                .add "methodName", methodInfo("name")
                .add "inputFormat", methodInfo("input_format")
                .add "outputFormat", methodInfo("output_format")
                .add "status", stepInfo("status")
                .add "created", FormatDateTime(stepInfo("created"), 2)
                .add "updated", FormatDateTime(Now(), 2)
            End With
            
            ' Dados de entrada (se houver)
            .add "inputData", outputJSON.Collection()
            With .item("inputData")
                .add "sources", GetStepInputSources(stepInfo("stepID"))
                .add "format", methodInfo("input_format")
            End With
            
            ' Dados de saída
            .add "outputData", outputJSON.Collection()
            With .item("outputData")
                .add "format", methodInfo("output_format")
                .add "type", outputType
                .add "timestamp", FormatDateTime(Now(), 2)
                .add "data", outputData
            End With
            
            ' Metadados de processamento
            .add "processingMetadata", outputJSON.Collection()
            With .item("processingMetadata")
                .add "processed", True
                .add "processedBy", Session("email")
                .add "processedAt", FormatDateTime(Now(), 2)
                .add "version", "1.0"
                .add "checksum", GenerateChecksum(outputData)
            End With
        End With
        
        Set CreateOutputJSON = outputJSON
    End Function
    
    ' Busca inputs de steps anteriores
    Private Function GetStepInputSources(stepID)
        Dim rs, inputSources, i
        ReDim inputSources(0)
        i = 0
        
        Call getRecordSet(SQL_CONSULTA_WORKFLOW_PARENT_STEPS(stepID), rs)
        
        While Not rs.eof
            ReDim Preserve inputSources(i)
            inputSources(i) = rs("parentStepID")
            i = i + 1
            rs.movenext
        Wend
        
        GetStepInputSources = inputSources
    End Function
    
    ' Gera checksum simples para os dados
    Private Function GenerateChecksum(data)
        Dim checksum, i
        checksum = 0
        
        For i = 1 To Len(CStr(data))
            checksum = checksum + Asc(Mid(CStr(data), i, 1))
        Next
        
        GenerateChecksum = CStr(checksum)
    End Function
    
    ' Salva output no banco de dados
    Private Function SaveOutputToDB(stepID, jsonData)
        Dim sql
        On Error Resume Next
        
        sql = "UPDATE tiamat_steps SET output_json = '" & Replace(jsonData, "'", "''") & "', " & _
              "updated = GETDATE() WHERE stepID = " & stepID
        
        Call ExecuteSQL(sql)
        
        If Err.Number = 0 Then
            SaveOutputToDB = True
        Else
            SaveOutputToDB = False
        End If
    End Function
    
    ' Recupera output de um step
    Public Function GetStepOutput(stepID)
        Dim rs
        Call getRecordSet("SELECT output_json FROM tiamat_steps WHERE stepID = " & stepID, rs)
        
        If Not rs.eof And Not IsNull(rs("output_json")) Then
            GetStepOutput = rs("output_json")
        Else
            GetStepOutput = ""
        End If
    End Function
    
    ' Recupera outputs de múltiplos steps (para input chain)
    Public Function GetMultipleStepOutputs(stepIDs)
        Dim outputsJSON, i
        Set outputsJSON = New aspJSON
        
        With outputsJSON.data
            .add "combinedOutputs", outputsJSON.Collection()
            .add "sourceSteps", outputsJSON.Collection()
            
            For i = 0 To UBound(stepIDs)
                Dim stepOutput
                stepOutput = GetStepOutput(stepIDs(i))
                
                If stepOutput <> "" Then
                    .item("combinedOutputs").add i, stepOutput
                    .item("sourceSteps").add i, stepIDs(i)
                End If
            Next
            
            .add "combinedAt", FormatDateTime(Now(), 2)
            .add "totalSources", UBound(stepIDs) + 1
        End With
        
        GetMultipleStepOutputs = outputsJSON.JSONoutput()
    End Function
    
    ' Converte output para formato específico (para input de próximo step)
    Public Function ConvertOutputForInput(stepID, targetFormat)
        Dim outputData, convertedData
        Dim sourceJSON
        
        outputData = GetStepOutput(stepID)
        
        If outputData = "" Then
            ConvertOutputForInput = ""
            Exit Function
        End If
        
        Set sourceJSON = New aspJSON
        sourceJSON.loadJSON(outputData)
        
        Select Case LCase(targetFormat)
            Case "array"
                convertedData = ConvertToArray(sourceJSON)
            Case "matrix"
                convertedData = ConvertToMatrix(sourceJSON)
            Case "list of events"
                convertedData = ConvertToEventList(sourceJSON)
            Case "key-words"
                convertedData = ConvertToKeywords(sourceJSON)
            Case "map"
                convertedData = ConvertToMap(sourceJSON)
            Case "graph"
                convertedData = ConvertToGraph(sourceJSON)
            Case "bibliometric indicators"
                convertedData = ConvertToBibliometrics(sourceJSON)
            Case "cross-impact matrix"
                convertedData = ConvertToCrossImpact(sourceJSON)
            Case Else
                convertedData = sourceJSON.data("outputData").item("data")
        End Select
        
        ConvertOutputForInput = convertedData
    End Function
    
    ' Métodos de conversão (implementações básicas)
    Private Function ConvertToArray(sourceJSON)
        ConvertToArray = sourceJSON.data("outputData").item("data")
    End Function
    
    Private Function ConvertToMatrix(sourceJSON)
        ConvertToMatrix = sourceJSON.data("outputData").item("data")
    End Function
    
    Private Function ConvertToEventList(sourceJSON)
        ConvertToEventList = sourceJSON.data("outputData").item("data")
    End Function
    
    Private Function ConvertToKeywords(sourceJSON)
        ConvertToKeywords = sourceJSON.data("outputData").item("data")
    End Function
    
    Private Function ConvertToMap(sourceJSON)
        ConvertToMap = sourceJSON.data("outputData").item("data")
    End Function
    
    Private Function ConvertToGraph(sourceJSON)
        ConvertToGraph = sourceJSON.data("outputData").item("data")
    End Function
    
    Private Function ConvertToBibliometrics(sourceJSON)
        ConvertToBibliometrics = sourceJSON.data("outputData").item("data")
    End Function
    
    Private Function ConvertToCrossImpact(sourceJSON)
        ConvertToCrossImpact = sourceJSON.data("outputData").item("data")
    End Function
    
End Class

' Exemplo de uso:
' Dim outputManager
' Set outputManager = New TiamatOutputManager
' 
' ' Capturar output de um step
' Dim outputData = "{'results': ['item1', 'item2', 'item3']}"
' If outputManager.CaptureStepOutput(123, outputData, "analysis_result") Then
'     Response.Write "Output capturado com sucesso!"
' End If
' 
' ' Recuperar output para uso posterior
' Dim recoveredOutput = outputManager.GetStepOutput(123)
' Response.Write recoveredOutput
' 
' ' Converter output para input de próximo step
' Dim convertedData = outputManager.ConvertOutputForInput(123, "Array")

%>