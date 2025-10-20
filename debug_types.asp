<!--#include file="TiamatOutputManager.asp"-->
<%
'=========================================
' DEBUG DE TIPOS - TIAMAT OUTPUT MANAGER
' Identificar exatamente onde está o problema de tipos
'=========================================

Response.ContentType = "text/html; charset=utf-8"
%>
<!DOCTYPE html>
<html>
<head>
    <title>Debug Tipos - TIAMAT</title>
    <style>
        body { font-family: Arial, sans-serif; margin: 20px; }
        .success { background-color: #d4edda; border: 1px solid #c3e6cb; padding: 10px; margin: 10px 0; border-radius: 4px; }
        .error { background-color: #f8d7da; border: 1px solid #f5c6cb; padding: 10px; margin: 10px 0; border-radius: 4px; }
        .info { background-color: #d1ecf1; border: 1px solid #bee5eb; padding: 10px; margin: 10px 0; border-radius: 4px; }
        .code { background-color: #f8f9fa; border: 1px solid #e9ecef; padding: 10px; font-family: monospace; white-space: pre-wrap; }
    </style>
</head>
<body>
    <h1>?? Debug de Tipos - TIAMAT Output Manager</h1>
    
    <%
    Dim stepID, testData, outputType
    stepID = 2 ' ID que sabemos que existe
    testData = "{""debug"": ""test""}"
    outputType = "debug"
    
    Response.Write "<div class='info'><h3>Parâmetros de Teste:</h3>"
    Response.Write "<p><strong>stepID:</strong> " & stepID & " (Tipo: " & TypeName(stepID) & ")</p>"
    Response.Write "<p><strong>testData:</strong> " & testData & " (Tipo: " & TypeName(testData) & ")</p>"
    Response.Write "<p><strong>outputType:</strong> " & outputType & " (Tipo: " & TypeName(outputType) & ")</p>"
    Response.Write "</div>"
    
    ' TESTE 1: Instanciar classe
    Response.Write "<h3>1. Instanciar Classe</h3>"
    On Error Resume Next
    Dim outputManager
    Set outputManager = New TiamatOutputManager
    
    If Err.Number = 0 Then
        Response.Write "<div class='success'>? Classe instanciada</div>"
    Else
        Response.Write "<div class='error'>? Erro ao instanciar: " & Err.Description & "</div>"
    End If
    Err.Clear
    
    ' TESTE 2: Testar GetStepInfo isoladamente
    Response.Write "<h3>2. Testar GetStepInfo</h3>"
    On Error Resume Next
    
    Dim stepInfo
    Set stepInfo = outputManager.GetStepInfo(stepID)
    
    If Err.Number = 0 And Not stepInfo Is Nothing Then
        Response.Write "<div class='success'>? GetStepInfo funcionou</div>"
        Response.Write "<div class='code'>"
        Dim key
        For Each key In stepInfo.Keys
            Response.Write key & ": " & stepInfo(key) & " (Tipo: " & TypeName(stepInfo(key)) & ")" & vbCrLf
        Next
        Response.Write "</div>"
    Else
        Response.Write "<div class='error'>? Erro GetStepInfo: " & Err.Description & "</div>"
    End If
    Err.Clear
    
    ' TESTE 3: Testar GetWorkflowInfo isoladamente
    If Not stepInfo Is Nothing Then
        Response.Write "<h3>3. Testar GetWorkflowInfo</h3>"
        On Error Resume Next
        
        Dim workflowInfo
        Set workflowInfo = outputManager.GetWorkflowInfo(stepInfo("workflowID"))
        
        If Err.Number = 0 And Not workflowInfo Is Nothing Then
            Response.Write "<div class='success'>? GetWorkflowInfo funcionou</div>"
        Else
            Response.Write "<div class='error'>? Erro GetWorkflowInfo: " & Err.Description & "</div>"
        End If
        Err.Clear
    End If
    
    ' TESTE 4: Testar CreateOutputJSON isoladamente
    If Not stepInfo Is Nothing Then
        Response.Write "<h3>4. Testar CreateOutputJSON</h3>"
        On Error Resume Next
        
        Dim methodInfo, jsonOutput
        Set methodInfo = outputManager.GetMethodInfoFromDB(stepInfo("methodID"))
        
        If Err.Number = 0 Then
            Response.Write "<div class='success'>? GetMethodInfoFromDB funcionou</div>"
            
            ' Testar criação do JSON
            Set jsonOutput = outputManager.CreateOutputJSON(stepInfo, workflowInfo, methodInfo, testData, outputType)
            
            If Err.Number = 0 And Not jsonOutput Is Nothing Then
                Response.Write "<div class='success'>? CreateOutputJSON funcionou</div>"
                
                ' Testar JSONoutput
                Dim jsonString
                jsonString = jsonOutput.JSONoutput()
                
                If Err.Number = 0 Then
                    Response.Write "<div class='success'>? JSONoutput funcionou</div>"
                    Response.Write "<div class='code'>" & Left(jsonString, 500) & "...</div>"
                Else
                    Response.Write "<div class='error'>? Erro JSONoutput: " & Err.Description & "</div>"
                End If
            Else
                Response.Write "<div class='error'>? Erro CreateOutputJSON: " & Err.Description & "</div>"
            End If
        Else
            Response.Write "<div class='error'>? Erro GetMethodInfoFromDB: " & Err.Description & "</div>"
        End If
        Err.Clear
    End If
    
    ' TESTE 5: Testar SaveOutputToDB isoladamente
    If Not stepInfo Is Nothing And Not jsonOutput Is Nothing Then
        Response.Write "<h3>5. Testar SaveOutputToDB</h3>"
        On Error Resume Next
        
        Dim saveResult
        saveResult = outputManager.SaveOutputToDB(stepID, jsonString, outputType)
        
        If Err.Number = 0 Then
            If saveResult Then
                Response.Write "<div class='success'>? SaveOutputToDB funcionou (retornou True)</div>"
            Else
                Response.Write "<div class='error'>? SaveOutputToDB retornou False</div>"
            End If
        Else
            Response.Write "<div class='error'>? Erro SaveOutputToDB: " & Err.Description & "</div>"
        End If
        Err.Clear
    End If
    
    ' TESTE 6: Testar método principal step by step
    Response.Write "<h3>6. Testar CaptureStepOutput Completo</h3>"
    On Error Resume Next
    
    ' Converter explicitamente todos os tipos
    Dim safeStepID, safeTestData, safeOutputType
    safeStepID = CLng(stepID)
    safeTestData = CStr(testData)
    safeOutputType = CStr(outputType)
    
    Response.Write "<div class='info'>"
    Response.Write "<p><strong>Tipos convertidos:</strong></p>"
    Response.Write "<p>safeStepID: " & safeStepID & " (Tipo: " & TypeName(safeStepID) & ")</p>"
    Response.Write "<p>safeTestData: " & safeTestData & " (Tipo: " & TypeName(safeTestData) & ")</p>"
    Response.Write "<p>safeOutputType: " & safeOutputType & " (Tipo: " & TypeName(safeOutputType) & ")</p>"
    Response.Write "</div>"
    
    Dim finalResult
    finalResult = outputManager.CaptureStepOutput(safeStepID, safeTestData, safeOutputType)
    
    If Err.Number = 0 Then
        If finalResult Then
            Response.Write "<div class='success'>? CaptureStepOutput FUNCIONOU!</div>"
        Else
            Response.Write "<div class='error'>? CaptureStepOutput retornou False</div>"
        End If
    Else
        Response.Write "<div class='error'>? Erro CaptureStepOutput: " & Err.Description & "</div>"
        Response.Write "<div class='info'>Número do erro: " & Err.Number & "</div>"
    End If
    Err.Clear
    
    ' TESTE 7: Verificar se salvou
    Response.Write "<h3>7. Verificar se Output foi Salvo</h3>"
    On Error Resume Next
    
    Dim retrievedData
    retrievedData = outputManager.GetStepOutput(safeStepID)
    
    If Err.Number = 0 Then
        Response.Write "<div class='success'>? GetStepOutput funcionou</div>"
        Response.Write "<div class='code'>" & Server.HTMLEncode(retrievedData) & "</div>"
        
        ' Verificar se contém nossos dados de teste
        If InStr(retrievedData, "debug") > 0 Then
            Response.Write "<div class='success'>? Dados de teste encontrados no output!</div>"
        Else
            Response.Write "<div class='error'>? Dados de teste não encontrados</div>"
        End If
    Else
        Response.Write "<div class='error'>? Erro GetStepOutput: " & Err.Description & "</div>"
    End If
    Err.Clear
    
    ' TESTE 8: Verificar diretamente no banco
    Response.Write "<h3>8. Verificar Diretamente no Banco</h3>"
    On Error Resume Next
    
    Dim rs
    Call getRecordSet("SELECT output_json FROM tiamat_steps WHERE stepID = " & safeStepID, rs)
    
    If Err.Number = 0 And Not rs.eof Then
        If Not IsNull(rs("output_json")) And rs("output_json") <> "" Then
            Response.Write "<div class='success'>? Dados encontrados no banco</div>"
            Response.Write "<div class='code'>" & Server.HTMLEncode(Left(CStr(rs("output_json")), 500)) & "...</div>"
        Else
            Response.Write "<div class='error'>? Campo output_json está vazio no banco</div>"
        End If
    Else
        Response.Write "<div class='error'>? Erro ao verificar banco: " & Err.Description & "</div>"
    End If
    Err.Clear
    
    ' TESTE 9: Verificar arquivo de fallback
    Response.Write "<h3>9. Verificar Arquivo de Fallback</h3>"
    On Error Resume Next
    
    Dim fso, fileName
    Set fso = Server.CreateObject("Scripting.FileSystemObject")
    fileName = "C:\Windows\TEMP\tiamat\output_" & safeStepID & ".json"
    
    If fso.FileExists(fileName) Then
        Response.Write "<div class='success'>? Arquivo de fallback existe</div>"
        
        Dim file, fileContent
        Set file = fso.OpenTextFile(fileName, 1)
        fileContent = file.ReadAll
        file.Close
        Set file = Nothing
        
        Response.Write "<div class='code'>" & Server.HTMLEncode(fileContent) & "</div>"
    Else
        Response.Write "<div class='info'>?? Arquivo de fallback não existe (normal se salvou no banco)</div>"
    End If
    
    Set fso = Nothing
    Err.Clear
    
    ' TESTE 10: Função global
    Response.Write "<h3>10. Testar Função Global</h3>"
    On Error Resume Next
    
    Dim globalResult
    globalResult = SaveFTAMethodOutput(safeStepID, safeTestData, safeOutputType)
    
    If Err.Number = 0 Then
        If globalResult Then
            Response.Write "<div class='success'>? Função global SaveFTAMethodOutput funcionou!</div>"
        Else
            Response.Write "<div class='error'>? Função global retornou False</div>"
        End If
    Else
        Response.Write "<div class='error'>? Erro função global: " & Err.Description & "</div>"
    End If
    Err.Clear
    
    Set outputManager = Nothing
    %>
    
    <div class="info">
        <h3>?? Resumo do Debug</h3>
        <p>Este teste mostra exatamente onde está falhando o sistema.</p>
        <p>Se todos os testes passaram, o problema estava nos tipos de dados.</p>
        <p>Se algum teste falhou, você pode ver exatamente qual função tem problema.</p>
    </div>
    
    <div class="info">
        <h3>?? Próximos Passos</h3>
        <p>Se este debug funcionou, tente novamente:</p>
        <ul>
            <li><a href="test_manual_simple.asp?action=test_capture&stepID=2">Teste Manual com stepID 2</a></li>
            <li><a href="test_output_manager.asp">Testes Automatizados</a></li>
        </ul>
    </div>
    
</body>
</html>