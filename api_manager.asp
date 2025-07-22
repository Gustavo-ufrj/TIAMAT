<!--#include file="outputManager.asp"-->
<%
'=========================================
' TIAMAT OUTPUT API
' API REST para gerenciar outputs dos métodos FTA
'=========================================

' Configuração de resposta JSON
Response.ContentType = "application/json"
Response.CharSet = "utf-8"

' Instancia o manager
Dim outputManager
Set outputManager = New TiamatOutputManager

Dim action, stepID, outputData, outputType, targetFormat
Dim response, success, message, data

' Inicializa variáveis
action = Request.QueryString("action")
stepID = Request.QueryString("stepID")
outputData = Request.Form("outputData")
outputType = Request.Form("outputType")
targetFormat = Request.QueryString("targetFormat")

' Cria objeto de resposta
Set response = New aspJSON

Select Case LCase(action)
    Case "capture"
        ' Capturar output de um step
        If stepID <> "" And outputData <> "" Then
            If outputType = "" Then outputType = "general"
            
            success = outputManager.CaptureStepOutput(stepID, outputData, outputType)
            
            With response.data
                .add "success", success
                .add "message", IIf(success, "Output capturado com sucesso", "Erro ao capturar output")
                .add "stepID", stepID
                .add "timestamp", FormatDateTime(Now(), 2)
            End With
        Else
            With response.data
                .add "success", False
                .add "message", "Parâmetros stepID e outputData são obrigatórios"
                .add "required", "stepID, outputData"
            End With
        End If
    
    Case "get"
        ' Recuperar output de um step
        If stepID <> "" Then
            data = outputManager.GetStepOutput(stepID)
            
            With response.data
                .add "success", (data <> "")
                .add "message", IIf(data <> "", "Output recuperado com sucesso", "Output não encontrado")
                .add "stepID", stepID
                .add "data", data
            End With
        Else
            With response.data
                .add "success", False
                .add "message", "Parâmetro stepID é obrigatório"
            End With
        End If
    
    Case "getmultiple"
        ' Recuperar outputs de múltiplos steps
        Dim stepIDs, stepIDsArray
        stepIDs = Request.QueryString("stepIDs")
        
        If stepIDs <> "" Then
            stepIDsArray = Split(stepIDs, ",")
            data = outputManager.GetMultipleStepOutputs(stepIDsArray)
            
            With response.data
                .add "success", True
                .add "message", "Outputs recuperados com sucesso"
                .add "data", data
            End With
        Else
            With response.data
                .add "success", False
                .add "message", "Parâmetro stepIDs é obrigatório (separado por vírgula)"
            End With
        End If
    
    Case "convert"
        ' Converter output para formato específico
        If stepID <> "" And targetFormat <> "" Then
            data = outputManager.ConvertOutputForInput(stepID, targetFormat)
            
            With response.data
                .add "success", (data <> "")
                .add "message", IIf(data <> "", "Conversão realizada com sucesso", "Erro na conversão")
                .add "stepID", stepID
                .add "targetFormat", targetFormat
                .add "data", data
            End With
        Else
            With response.data
                .add "success", False
                .add "message", "Parâmetros stepID e targetFormat são obrigatórios"
            End With
        End If
    
    Case "chain"
        ' Criar cadeia de inputs a partir de outputs anteriores
        Dim sourceSteps, targetStepID, chainFormat
        sourceSteps = Request.QueryString("sourceSteps")
        targetStepID = Request.QueryString("targetStepID")
        chainFormat = Request.QueryString("chainFormat")
        
        If sourceSteps <> "" And targetStepID <> "" Then
            Dim sourceStepsArray, chainedData
            sourceStepsArray = Split(sourceSteps, ",")
            
            ' Recupera outputs dos steps fonte
            chainedData = outputManager.GetMultipleStepOutputs(sourceStepsArray)
            
            ' Se especificado, converte para formato específico
            If chainFormat <> "" Then
                ' Aqui você pode implementar lógica específica para converter múltiplos outputs
                ' Para o formato desejado pelo step de destino
            End If
            
            With response.data
                .add "success", True
                .add "message", "Cadeia de inputs criada com sucesso"
                .add "sourceSteps", sourceSteps
                .add "targetStepID", targetStepID
                .add "chainedData", chainedData
            End With
        Else
            With response.data
                .add "success", False
                .add "message", "Parâmetros sourceSteps e targetStepID são obrigatórios"
            End With
        End If
    
    Case "metadata"
        ' Recuperar apenas metadados de um step
        If stepID <> "" Then
            Dim fullOutput, metadataOnly
            fullOutput = outputManager.GetStepOutput(stepID)
            
            If fullOutput <> "" Then
                Dim outputJSON
                Set outputJSON = New aspJSON
                outputJSON.loadJSON(fullOutput)
                
                Set metadataOnly = New aspJSON
                With metadataOnly.data
                    .add "dublinCore", outputJSON.data("dublinCore")
                    .add "tiamatMetadata", outputJSON.data("tiamatMetadata")
                    .add "processingMetadata", outputJSON.data("processingMetadata")
                End With
                
                With response.data
                    .add "success", True
                    .add "message", "Metadados recuperados com sucesso"
                    .add "stepID", stepID
                    .add "metadata", metadataOnly.JSONoutput()
                End With
            Else
                With response.data
                    .add "success", False
                    .add "message", "Output não encontrado para o step especificado"
                End With
            End If
        Else
            With response.data
                .add "success", False
                .add "message", "Parâmetro stepID é obrigatório"
            End With
        End If
    
    Case "validate"
        ' Validar compatibilidade entre output e input
        Dim sourceStepID, targetMethodID
        sourceStepID = Request.QueryString("sourceStepID")
        targetMethodID = Request.QueryString("targetMethodID")
        
        If sourceStepID <> "" And targetMethodID <> "" Then
            ' Busca formato de output do step fonte
            Dim sourceOutput, sourceFormat, targetInputFormat
            sourceOutput = outputManager.GetStepOutput(sourceStepID)
            
            If sourceOutput <> "" Then
                Dim sourceJSON
                Set sourceJSON = New aspJSON
                sourceJSON.loadJSON(sourceOutput)
                sourceFormat = sourceJSON.data("tiamatMetadata").item("outputFormat")
                
                ' Busca formato de input do método alvo
                targetInputFormat = getFTAMethodInputbyFTAmethodID(targetMethodID)
                
                Dim compatible
                compatible = (sourceFormat = targetInputFormat)
                
                With response.data
                    .add "success", True
                    .add "message", "Validação realizada com sucesso"
                    .add "sourceStepID", sourceStepID
                    .add "targetMethodID", targetMethodID
                    .add "sourceFormat", sourceFormat
                    .add "targetInputFormat", targetInputFormat
                    .add "compatible", compatible
                End With
            Else
                With response.data
                    .add "success", False
                    .add "message", "Output não encontrado para o step fonte"
                End With
            End If
        Else
            With response.data
                .add "success", False
                .add "message", "Parâmetros sourceStepID e targetMethodID são obrigatórios"
            End With
        End If
    
    Case Else
        ' Retorna informações de uso da API
        With response.data
            .add "success", False
            .add "message", "Ação não reconhecida"
            .add "availableActions", response.Collection()
            With .item("availableActions")
                .add "capture", "Capturar output de um step"
                .add "get", "Recuperar output de um step"
                .add "getmultiple", "Recuperar outputs de múltiplos steps"
                .add "convert", "Converter output para formato específico"
                .add "chain", "Criar cadeia de inputs a partir de outputs"
                .add "metadata", "Recuperar apenas metadados"
                .add "validate", "Validar compatibilidade entre output e input"
            End With
            .add "usage", response.Collection()
            With .item("usage")
                .add "capture", "POST outputAPI.asp?action=capture&stepID=123 com outputData e outputType no body"
                .add "get", "GET outputAPI.asp?action=get&stepID=123"
                .add "getmultiple", "GET outputAPI.asp?action=getmultiple&stepIDs=123,124,125"
                .add "convert", "GET outputAPI.asp?action=convert&stepID=123&targetFormat=Array"
                .add "chain", "GET outputAPI.asp?action=chain&sourceSteps=123,124&targetStepID=125"
                .add "metadata", "GET outputAPI.asp?action=metadata&stepID=123"
                .add "validate", "GET outputAPI.asp?action=validate&sourceStepID=123&targetMethodID=2"
            End With
        End With
End Select

' Retorna resposta JSON
Response.Write response.JSONoutput()

' Limpa objetos
Set outputManager = Nothing
Set response = Nothing
%>