<%
'=========================================
' TIAMAT OUTPUT MANAGER - VERSÃO PRODUÇÃO
' Sistema para capturar outputs dos métodos FTA
' e estruturá-los com Dublin Core para reutilização
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
    Public Function CaptureStepOutput(stepID, outputData, outputType, processingTime)
        Dim stepInfo, workflowInfo, methodInfo
        Dim jsonOutput, success
        
        On Error Resume Next
        
        ' Busca informações do step
        Set stepInfo = GetStepInfo(stepID)
        If stepInfo Is Nothing Then
            CaptureStepOutput = False
            Exit Function
        End If
        
        ' Busca informações do workflow
        Set workflowInfo = GetWorkflowInfo(stepInfo("workflowID"))
        
        ' Busca informações do método FTA
        Set methodInfo = GetMethodInfoFromManifest(stepInfo("methodID"))
        
        ' Cria estrutura JSON com Dublin Core
        Set jsonOutput = CreateOutputJSON(stepInfo, workflowInfo, methodInfo, outputData, outputType)
        
        ' Salva no banco usando SQL direto
        success = SaveOutputToDB(stepID, jsonOutput.JSONoutput(), outputType, processingTime)
        
        If Err.Number = 0 Then
            CaptureStepOutput = success
        Else
            CaptureStepOutput = False
        End If
        
        On Error Goto 0
    End Function
    
    ' Busca informações do step
    Private Function GetStepInfo(stepID)
        Dim rs
        On Error Resume Next
        
        Call getRecordSet("SELECT stepID, workflowID, methodID, description, goal, status, created, updated FROM tiamat_steps WHERE stepID = " & stepID, rs)
        
        If Not rs.eof And Err.Number = 0 Then
            Set GetStepInfo = Server.CreateObject("Scripting.Dictionary")
            GetStepInfo.Add "stepID", rs("stepID")
            GetStepInfo.Add "workflowID", rs("workflowID")
            GetStepInfo.Add "methodID", IIf(IsNull(rs("methodID")), 0, rs("methodID"))
            GetStepInfo.Add "description", rs("description")
            GetStepInfo.Add "goal", IIf(IsNull(rs("goal")), "", rs("goal"))
            GetStepInfo.Add "status", rs("status")
            GetStepInfo.Add "created", rs("created")
            GetStepInfo.Add "updated", IIf(IsNull(rs("updated")), Now(), rs("updated"))
        Else
            Set GetStepInfo = Nothing
        End If
        
        On Error Goto 0
    End Function
    
    ' Busca informações do workflow
    Private Function GetWorkflowInfo(workflowID)
        Dim rs
        On Error Resume Next
        
        Call getRecordSet("SELECT workflowID, description, goal, status, created FROM tiamat_workflows WHERE workflowID = " & workflowID, rs)
        
        If Not rs.eof And Err.Number = 0 Then
            Set GetWorkflowInfo = Server.CreateObject("Scripting.Dictionary")
            GetWorkflowInfo.Add "workflowID", rs("workflowID")
            GetWorkflowInfo.Add "description", rs("description")
            GetWorkflowInfo.Add "goal", IIf(IsNull(rs("goal")), "", rs("goal"))
            GetWorkflowInfo.Add "status", rs("status")
            GetWorkflowInfo.Add "created", rs("created")
        Else
            Set GetWorkflowInfo = Nothing
        End If
        
        On Error Goto 0
    End Function
    
    ' Busca informações do método FTA do manifest
    Private Function GetMethodInfoFromManifest(methodID)
        Dim methodList, i
        On Error Resume Next
        
        If Not manifest Is Nothing Then
            Set methodList = getFTAMethodList(manifest)
            
            For i = 0 To methodList.length - 1
                If methodList(i).getAttribute("id") = CStr(methodID) Then
                    Set GetMethodInfoFromManifest = Server.CreateObject("Scripting.Dictionary")
                    GetMethodInfoFromManifest.Add "id", methodList(i).getAttribute("id")
                    GetMethodInfoFromManifest.Add "name", methodList(i).getAttribute("name")
                    GetMethodInfoFromManifest.Add "input_format", methodList(i).getAttribute("input_format")
                    GetMethodInfoFromManifest.Add "output_format", methodList(i).getAttribute("output_format")
                    GetMethodInfoFromManifest.Add "base_folder", methodList(i).getAttribute("base_folder")
                    Exit Function
                End If
            Next
        End If
        
        ' Se não encontrou no manifest, busca no banco
        Set GetMethodInfoFromManifest = GetMethodInfoFromDB(methodID)
        
        On Error Goto 0
    End Function
    
    ' Busca método no banco como fallback
    Private Function GetMethodInfoFromDB(methodID)
        Dim rs
        On Error Resume Next
        
        Call getRecordSet("SELECT methodID, name, input_format, output_format, base_folder FROM tiamat_fta_methods WHERE methodID = " & methodID, rs)
        
        If Not rs.eof And Err.Number = 0 Then
            Set GetMethodInfoFromDB = Server.CreateObject("Scripting.Dictionary")
            GetMethodInfoFromDB.Add "id", rs("methodID")
            GetMethodInfoFromDB.Add "name", rs("name")
            GetMethodInfoFromDB.Add "input_format", IIf(IsNull(rs("input_format")), "Unknown", rs("input_format"))
            GetMethodInfoFromDB.Add "output_format", IIf(IsNull(rs("output_format")), "Unknown", rs("output_format"))
            GetMethodInfoFromDB.Add "base_folder", IIf(IsNull(rs("base_folder")), "/", rs("base_folder"))
        Else
            ' Método padrão se não encontrar
            Set GetMethodInfoFromDB = Server.CreateObject("Scripting.Dictionary")
            GetMethodInfoFromDB.Add "id", methodID
            GetMethodInfoFromDB.Add "name", "Método FTA " & methodID
            GetMethodInfoFromDB.Add "input_format", "Array"
            GetMethodInfoFromDB.Add "output_format", "Array"
            GetMethodInfoFromDB.Add "base_folder", "/methods/"
        End If
        
        On Error Goto 0
    End Function
    
    ' Cria estrutura JSON com Dublin Core
    Private Function CreateOutputJSON(stepInfo, workflowInfo, methodInfo, outputData, outputType)
        Dim outputJSON, userCreator
        Set outputJSON = New aspJSON
        
        ' Define criador baseado na sessão ou sistema
        If Session("name") <> "" Then
            userCreator = Session("name")
        Else
            userCreator = "TIAMAT System"
        End If
        
        With outputJSON.data
            ' Dublin Core Metadata (padrão internacional)
            .add "dublinCore", outputJSON.Collection()
            With .item("dublinCore")
                .add "title", stepInfo("description")
                .add "description", stepInfo("goal")
                .add "creator", userCreator
                .add "subject", IIf(workflowInfo Is Nothing, "", workflowInfo("description"))
                .add "publisher", "TIAMAT Framework"
                .add "date", FormatDateTime(Now(), 2)
                .add "type", IIf(methodInfo Is Nothing, "Unknown Method", methodInfo("name"))
                .add "format", IIf(methodInfo Is Nothing, "Unknown", methodInfo("output_format"))
                .add "identifier", "TIAMAT-" & stepInfo("stepID") & "-" & Replace(FormatDateTime(Now(), 2), "/", "")
                .add "source", "Step " & stepInfo("stepID") & " - " & IIf(methodInfo Is Nothing, "Unknown Method", methodInfo("name"))
                .add "language", "pt-BR"
                .add "relation", "Workflow " & stepInfo("workflowID")
                .add "coverage", "Technology Foresight Analysis"
                .add "rights", "Internal Use - TIAMAT Framework"
            End With
            
            ' Metadados específicos do TIAMAT
            .add "tiamatMetadata", outputJSON.Collection()
            With .item("tiamatMetadata")
                .add "stepID", stepInfo("stepID")
                .add "workflowID", stepInfo("workflowID")
                .add "methodID", stepInfo("methodID")
                If Not methodInfo Is Nothing Then
                    .add "methodName", methodInfo("name")
                    .add "inputFormat", methodInfo("input_format")
                    .add "outputFormat", methodInfo("output_format")
                    .add "baseFolder", methodInfo("base_folder")
                End If
                .add "status", stepInfo("status")
                .add "created", FormatDateTime(stepInfo("created"), 2)
                .add "updated", FormatDateTime(Now(), 2)
                .add "systemVersion", "TIAMAT 2.0"
            End With
            
            ' Dados de entrada (sources)
            .add "inputData", outputJSON.Collection()
            With .item("inputData")
                .add "sources", GetStepInputSources(stepInfo("stepID"))
                If Not methodInfo Is Nothing Then
                    .add "expectedFormat", methodInfo("input_format")
                End If
            End With
            
            ' Dados de saída principais
            .add "outputData", outputJSON.Collection()
            With .item("outputData")
                If Not methodInfo Is Nothing Then
                    .add "format", methodInfo("output_format")
                End If
                .add "type", outputType
                .add "timestamp", FormatDateTime(Now(), 2)
                .add "data", outputData
                .add "dataSize", Len(CStr(outputData))
                .add "checksum", GenerateChecksum(outputData)
            End With
            
            ' Metadados de processamento
            .add "processingMetadata", outputJSON.Collection()
            With .item("processingMetadata")
                .add "processed", True
                .add "processedBy", IIf(Session("email") <> "", Session("email"), "system@tiamat.com")
                .add "processedAt", FormatDateTime(Now(), 2)
                .add "version", "2.0"
                .add "framework", "TIAMAT"
                .add "environment", "ASP Classic"
            End With
        End With
        
        Set CreateOutputJSON = outputJSON
    End Function
    
    ' Busca inputs de steps anteriores
    Private Function GetStepInputSources(stepID)
        Dim rs, inputSources, i, sql
        ReDim inputSources(0)
        i = 0
        
        On Error Resume Next
        
        sql = "SELECT parentStepID FROM tiamat_step_relationships WHERE stepID = " & stepID
        Call getRecordSet(sql, rs)
        
        If Err.Number = 0 Then
            While Not rs.eof
                ReDim Preserve inputSources(i)
                inputSources(i) = rs("parentStepID")
                i = i + 1
                rs.movenext
            Wend
        End If
        
        If i = 0 Then
            ReDim inputSources(0)
            inputSources(0) = "No parent steps"
        End If
        
        GetStepInputSources = inputSources
        
        On Error Goto 0
    End Function
    
    ' Gera checksum simples para os dados
    Private Function GenerateChecksum(data)
        Dim checksum, i, dataStr
        checksum = 0
        dataStr = CStr(data)
        
        For i = 1 To Len(dataStr)
            checksum = checksum + Asc(Mid(dataStr, i, 1))
        Next
        
        GenerateChecksum = CStr(checksum)
    End Function
    
    ' Salva output no banco de dados usando SQL direto
    Private Function SaveOutputToDB(stepID, jsonData, outputType, processingTime)
        Dim sql, escapedJSON
        On Error Resume Next
        
        ' Escapa aspas no JSON
        escapedJSON = Replace(jsonData, "'", "''")
        
        ' Verifica se tabela dublin_core existe
        Dim tableExists
        Call getRecordSet("SELECT TABLE_NAME FROM INFORMATION_SCHEMA.TABLES WHERE TABLE_NAME = 'tiamat_dublin_core'", rs)
        tableExists = Not rs.eof
        
        If tableExists Then
            ' Salva o Dublin Core
            sql = "INSERT INTO tiamat_dublin_core (stepID, dc_title, dc_description, dc_creator, dc_subject, " & _
                  "dc_publisher, dc_date, dc_type, dc_format, dc_identifier, dc_source, dc_language, dc_relation, dc_coverage, dc_rights) " & _
                  "SELECT " & stepID & ", s.description, s.goal, '" & IIf(Session("name") <> "", Session("name"), "TIAMAT System") & "', " & _
                  "w.description, 'TIAMAT Framework', GETDATE(), 'FTA Method', 'JSON', " & _
                  "'TIAMAT-" & stepID & "-' + REPLACE(CONVERT(VARCHAR(10), GETDATE(), 112), '/', ''), " & _
                  "'Step " & stepID & "', 'pt-BR', 'Workflow ' + CAST(w.workflowID AS VARCHAR(10)), " & _
                  "'Technology Foresight Analysis', 'Internal Use - TIAMAT Framework' " & _
                  "FROM tiamat_steps s " & _
                  "INNER JOIN tiamat_workflows w ON s.workflowID = w.workflowID " & _
                  "WHERE s.stepID = " & stepID
            
            Call ExecuteSQL(sql)
        End If
        
        If Err.Number = 0 Then
            ' Atualiza o step com o output JSON
            sql = "UPDATE tiamat_steps SET "
            
            ' Verifica se colunas existem
            Call getRecordSet("SELECT COLUMN_NAME FROM INFORMATION_SCHEMA.COLUMNS WHERE TABLE_NAME = 'tiamat_steps' AND COLUMN_NAME = 'output_json'", rs)
            If Not rs.eof Then
                sql = sql & "output_json = '" & escapedJSON & "', "
            End If
            
            Call getRecordSet("SELECT COLUMN_NAME FROM INFORMATION_SCHEMA.COLUMNS WHERE TABLE_NAME = 'tiamat_steps' AND COLUMN_NAME = 'output_size'", rs)
            If Not rs.eof Then
                sql = sql & "output_size = " & Len(jsonData) & ", "
            End If
            
            Call getRecordSet("SELECT COLUMN_NAME FROM INFORMATION_SCHEMA.COLUMNS WHERE TABLE_NAME = 'tiamat_steps' AND COLUMN_NAME = 'output_checksum'", rs)
            If Not rs.eof Then
                sql = sql & "output_checksum = '" & GenerateChecksum(jsonData) & "', "
            End If
            
            Call getRecordSet("SELECT COLUMN_NAME FROM INFORMATION_SCHEMA.COLUMNS WHERE TABLE_NAME = 'tiamat_steps' AND COLUMN_NAME = 'processing_time'", rs)
            If Not rs.eof Then
                sql = sql & "processing_time = " & IIf(IsNull(processingTime) Or processingTime = "", "0", processingTime) & ", "
            End If
            
            ' Sempre atualiza updated
            sql = sql & "updated = GETDATE() WHERE stepID = " & stepID
            
            ' Remove vírgula extra se houver
            sql = Replace(sql, ", updated", " updated")
            
            Call ExecuteSQL(sql)
            
            If Err.Number = 0 Then
                ' Log de sucesso se tabela existe
                Call getRecordSet("SELECT TABLE_NAME FROM INFORMATION_SCHEMA.TABLES WHERE TABLE_NAME = 'tiamat_execution_log'", rs)
                If Not rs.eof Then
                    sql = "INSERT INTO tiamat_execution_log (stepID, action, details, success, executed_by, executed_at) " & _
                          "VALUES (" & stepID & ", 'OUTPUT_SAVED', 'Output saved with Dublin Core metadata', 1, '" & _
                          IIf(Session("email") <> "", Session("email"), "system") & "', GETDATE())"
                    
                    Call ExecuteSQL(sql)
                End If
                SaveOutputToDB = True
            Else
                SaveOutputToDB = False
            End If
        Else
            SaveOutputToDB = False
        End If
        
        ' Log de erro se houver
        If Err.Number <> 0 Then
            Call getRecordSet("SELECT TABLE_NAME FROM INFORMATION_SCHEMA.TABLES WHERE TABLE_NAME = 'tiamat_execution_log'", rs)
            If Not rs.eof Then
                sql = "INSERT INTO tiamat_execution_log (stepID, action, error_message, success, executed_by, executed_at) " & _
                      "VALUES (" & stepID & ", 'OUTPUT_ERROR', '" & Replace(Err.Description, "'", "''") & "', 0, '" & _
                      IIf(Session("email") <> "", Session("email"), "system") & "', GETDATE())"
                
                On Error Resume Next
                Call ExecuteSQL(sql)
            End If
            SaveOutputToDB = False
        End If
        
        On Error Goto 0
    End Function
    
    ' Recupera output de um step
    Public Function GetStepOutput(stepID)
        Dim rs, sql
        On Error Resume Next
        
        sql = "SELECT "
        
        ' Verifica se coluna output_json existe
        Call getRecordSet("SELECT COLUMN_NAME FROM INFORMATION_SCHEMA.COLUMNS WHERE TABLE_NAME = 'tiamat_steps' AND COLUMN_NAME = 'output_json'", rs)
        If Not rs.eof Then
            sql = sql & "output_json"
        Else
            sql = sql & "description as output_json"
        End If
        
        sql = sql & " FROM tiamat_steps WHERE stepID = " & stepID
        
        Call getRecordSet(sql, rs)
        
        If Not rs.eof And Not IsNull(rs("output_json")) And Err.Number = 0 Then
            GetStepOutput = rs("output_json")
        Else
            GetStepOutput = ""
        End If
        
        On Error Goto 0
    End Function
    
End Class

%>