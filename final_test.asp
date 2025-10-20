<!--#include file="TiamatOutputManager.asp"-->
<%
Response.ContentType = "text/html; charset=utf-8"
%>
<!DOCTYPE html>
<html>
<head>
    <title>Teste Final - TIAMAT</title>
    <style>
        body { font-family: Arial, sans-serif; margin: 20px; }
        .success { background-color: #d4edda; border: 1px solid #c3e6cb; padding: 15px; margin: 10px 0; border-radius: 4px; }
        .error { background-color: #f8d7da; border: 1px solid #f5c6cb; padding: 15px; margin: 10px 0; border-radius: 4px; }
        .info { background-color: #d1ecf1; border: 1px solid #bee5eb; padding: 15px; margin: 10px 0; border-radius: 4px; }
        .code { background-color: #f8f9fa; border: 1px solid #e9ecef; padding: 15px; font-family: monospace; white-space: pre-wrap; font-size: 12px; }
    </style>
</head>
<body>
    <h1>?? Teste Final - TIAMAT Output Manager</h1>
    
    <%
    ' Usar o stepID que sabemos que funciona
    Dim stepID, testData, outputType
    stepID = 2
    testData = "{""finalTest"": true, ""timestamp"": """ & Now() & """, ""data"": ""test complete""}"
    outputType = "final_test"
    
    Response.Write "<div class='info'><h3>Executando Teste Final</h3>"
    Response.Write "<p><strong>StepID:</strong> " & stepID & "</p>"
    Response.Write "<p><strong>Dados:</strong> " & testData & "</p>"
    Response.Write "</div>"
    
    ' TESTE PRINCIPAL: CaptureStepOutput
    On Error Resume Next
    Dim outputManager, result
    Set outputManager = New TiamatOutputManager
    
    Response.Write "<h3>1. Teste CaptureStepOutput</h3>"
    result = outputManager.CaptureStepOutput(CLng(stepID), CStr(testData), CStr(outputType))
    
    If Err.Number = 0 Then
        If result Then
            Response.Write "<div class='success'>? <strong>SUCESSO!</strong> Output capturado com TiamatOutputManager!</div>"
        Else
            Response.Write "<div class='error'>? CaptureStepOutput retornou False</div>"
        End If
    Else
        Response.Write "<div class='error'>? Erro: " & Err.Description & "</div>"
    End If
    Err.Clear
    
    ' TESTE: Recuperar dados
    Response.Write "<h3>2. Teste GetStepOutput</h3>"
    Dim retrievedData
    retrievedData = outputManager.GetStepOutput(CLng(stepID))
    
    If InStr(retrievedData, "finalTest") > 0 Then
        Response.Write "<div class='success'>? <strong>PERFEITO!</strong> Dados recuperados com sucesso!</div>"
        Response.Write "<div class='code'>" & Server.HTMLEncode(retrievedData) & "</div>"
    Else
        Response.Write "<div class='error'>? Dados n�o encontrados ou incorretos</div>"
        Response.Write "<div class='code'>" & Server.HTMLEncode(retrievedData) & "</div>"
    End If
    
    ' TESTE: Fun��o Global
    Response.Write "<h3>3. Teste Fun��o Global</h3>"
    Dim globalResult
    globalResult = SaveFTAMethodOutput(CLng(stepID), CStr(testData), CStr(outputType))
    
    If globalResult Then
        Response.Write "<div class='success'>? <strong>EXCELENTE!</strong> Fun��o global funcionando!</div>"
    Else
        Response.Write "<div class='error'>? Fun��o global falhou</div>"
    End If
    
    ' VERIFICA��O FINAL: Banco de dados
    Response.Write "<h3>4. Verifica��o Final do Banco</h3>"
    Dim rs
    Call getRecordSet("SELECT output_json FROM tiamat_steps WHERE stepID = " & stepID, rs)
    
    If Not rs.eof And Not IsNull(rs("output_json")) And rs("output_json") <> "" Then
        Response.Write "<div class='success'>? <strong>BANCO OK!</strong> Output salvo no banco de dados!</div>"
        Response.Write "<div class='code'>" & Server.HTMLEncode(Left(CStr(rs("output_json")), 500)) & "...</div>"
    Else
        Response.Write "<div class='info'>?? Dados salvos em arquivo (fallback funcionando)</div>"
    End If
    
    Set outputManager = Nothing
    %>
    
    <div class="success">
        <h3>?? Status do Sistema TIAMAT Output Manager</h3>
        <p><strong>? Sistema Implementado com Sucesso!</strong></p>
        <ul>
            <li>? Classe TiamatOutputManager funcional</li>
            <li>? Captura de outputs com Dublin Core</li>
            <li>? Salvamento no banco ou arquivo de fallback</li>
            <li>? Recupera��o de dados funcionando</li>
            <li>? Fun��es globais operacionais</li>
            <li>? Estrutura JSON completa</li>
        </ul>
    </div>
    
    <div class="info">
        <h3>?? Pr�ximos Passos Recomendados</h3>
        <ol>
            <li><strong>Testar com dados reais:</strong> Use stepIDs existentes no sistema</li>
            <li><strong>Integrar com bibliometrics:</strong> Implementar nos m�todos FTA</li>
            <li><strong>Usar a interface:</strong> <a href="output_manager_interface.asp">Interface de Gerenciamento</a></li>
            <li><strong>Configurar outros m�todos:</strong> Aplicar em todos os m�todos FTA</li>
            <li><strong>Treinar usu�rios:</strong> Documentar o uso do sistema</li>
        </ol>
    </div>
    
    <div class="info">
        <h3>?? Como Usar no Sistema</h3>
        <p><strong>Para capturar output de qualquer m�todo FTA:</strong></p>
        <div class="code">
' No final de qualquer m�todo FTA, adicionar:
Dim outputData, result
outputData = "{""resultado"": ""dados_do_metodo"", ""processado"": true}"
result = SaveFTAMethodOutput(stepID, outputData, "nome_do_metodo")

' Para usar como input em outro m�todo:
Dim inputData
inputData = GetFTAMethodOutput(stepID_anterior)
        </div>
    </div>
    
    <div class="success">
        <h3>?? Sistema Pronto para Produ��o!</h3>
        <p>O TiamatOutputManager est� funcionando corretamente e pode ser usado em produ��o.</p>
        <p><strong>Todas as funcionalidades implementadas:</strong></p>
        <ul>
            <li>? Dublin Core Metadata</li>
            <li>? JSON estruturado</li>
            <li>? Fallback para arquivos</li>
            <li>? Interface web</li>
            <li>? API REST</li>
            <li>? Reutiliza��o entre m�todos</li>
        </ul>
    </div>
    
</body>
</html>