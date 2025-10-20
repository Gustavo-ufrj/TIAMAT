<!--#include file="TiamatOutputManager.asp"-->
<%
'=========================================
' TESTE MANUAL SIMPLIFICADO - TIAMAT OUTPUT MANAGER
' Versão sem dependências externas
'=========================================

Response.ContentType = "text/html; charset=utf-8"

Dim action, stepID, testData
action = Request.QueryString("action")
stepID = Request.QueryString("stepID")
testData = Request.QueryString("data")

' Usar um stepID existente se não fornecido
If stepID = "" Then
    ' Buscar qualquer stepID existente
    Dim rs
    On Error Resume Next
    Call getRecordSet("SELECT TOP 1 stepID FROM tiamat_steps ORDER BY stepID DESC", rs)
    If Not rs.eof Then
        stepID = rs("stepID")
    Else
        stepID = "999" ' Fallback
    End If
    Err.Clear
End If
%>
<!DOCTYPE html>
<html>
<head>
    <title>Teste Manual Simples - TIAMAT</title>
    <style>
        body { font-family: Arial, sans-serif; margin: 20px; }
        .success { background-color: #d4edda; border: 1px solid #c3e6cb; padding: 10px; margin: 10px 0; border-radius: 4px; }
        .error { background-color: #f8d7da; border: 1px solid #f5c6cb; padding: 10px; margin: 10px 0; border-radius: 4px; }
        .info { background-color: #d1ecf1; border: 1px solid #bee5eb; padding: 10px; margin: 10px 0; border-radius: 4px; }
        .code { background-color: #f8f9fa; border: 1px solid #e9ecef; padding: 10px; font-family: monospace; white-space: pre-wrap; }
        .form-group { margin: 15px 0; }
        label { display: block; margin-bottom: 5px; font-weight: bold; }
        input, textarea, select { width: 300px; padding: 5px; }
        button { background-color: #007bff; color: white; padding: 10px 15px; border: none; border-radius: 4px; cursor: pointer; }
        button:hover { background-color: #0056b3; }
        .button-group { margin: 10px 0; }
        .button-group a { margin-right: 10px; text-decoration: none; }
    </style>
</head>
<body>
    <h1>🔧 Teste Manual Simples - TIAMAT Output Manager</h1>
    
    <%
    If action <> "" Then
        Response.Write "<h2>Resultado do Teste: " & action & "</h2>"
        
        Select Case action
            Case "test_class"
                ' Testar instanciação da classe
                On Error Resume Next
                Dim outputManager
                Set outputManager = New TiamatOutputManager
                
                If Err.Number = 0 Then
                    Response.Write "<div class='success'>✅ Classe TiamatOutputManager instanciada com sucesso!</div>"
                Else
                    Response.Write "<div class='error'>❌ Erro ao instanciar classe: " & Err.Description & "</div>"
                End If
                Set outputManager = Nothing
                Err.Clear
                
            Case "test_capture"
                ' Testar captura simples
                If testData = "" Then testData = "{""test"": ""simple data"", ""timestamp"": """ & Now() & """}"
                
                On Error Resume Next
                Set outputManager = New TiamatOutputManager
                Dim result
                result = outputManager.CaptureStepOutput(CInt(stepID), testData, "test")
                
                If Err.Number = 0 And result Then
                    Response.Write "<div class='success'>✅ Output capturado com sucesso!</div>"
                    Response.Write "<div class='info'><strong>StepID:</strong> " & stepID & "<br>"
                    Response.Write "<strong>Dados:</strong> " & Server.HTMLEncode(testData) & "</div>"
                Else
                    Response.Write "<div class='error'>❌ Erro ao capturar: " & Err.Description & "</div>"
                End If
                Set outputManager = Nothing
                Err.Clear
                
            Case "test_retrieve"
                ' Testar recuperação
                On Error Resume Next
                Set outputManager = New TiamatOutputManager
                Dim retrievedData
                retrievedData = outputManager.GetStepOutput(CInt(stepID))
                
                If Err.Number = 0 And retrievedData <> "" Then
                    Response.Write "<div class='success'>✅ Output recuperado!</div>"
                    Response.Write "<div class='code'>" & Server.HTMLEncode(retrievedData) & "</div>"
                Else
                    Response.Write "<div class='error'>❌ Erro ao recuperar ou dados não encontrados</div>"
                    If Err.Description <> "" Then Response.Write "<div class='error'>Erro: " & Err.Description & "</div>"
                End If
                Set outputManager = Nothing
                Err.Clear
                
            Case "test_global"
                ' Testar funções globais
                On Error Resume Next
                Dim globalResult
                globalResult = SaveFTAMethodOutput(CInt(stepID), "{""global_test"": true, ""time"": """ & Now() & """}", "global")
                
                If Err.Number = 0 And globalResult Then
                    Response.Write "<div class='success'>✅ Função global SaveFTAMethodOutput funcionando!</div>"
                    
                    ' Testar recuperação global
                    Dim globalData
                    globalData = GetFTAMethodOutput(CInt(stepID))
                    Response.Write "<div class='info'><strong>Dados recuperados:</strong></div>"
                    Response.Write "<div class='code'>" & Server.HTMLEncode(globalData) & "</div>"
                Else
                    Response.Write "<div class='error'>❌ Erro na função global: " & Err.Description & "</div>"
                End If
                Err.Clear
                
            Case "show_structure"
                ' Mostrar estrutura do banco
                Response.Write "<div class='info'><h3>Estrutura do Banco de Dados</h3></div>"
                
                On Error Resume Next
                
                ' Verificar tiamat_steps
                Call getRecordSet("SELECT COLUMN_NAME, DATA_TYPE FROM INFORMATION_SCHEMA.COLUMNS WHERE TABLE_NAME = 'tiamat_steps' ORDER BY ORDINAL_POSITION", rs)
                Response.Write "<h4>Tabela tiamat_steps:</h4><ul>"
                While Not rs.eof
                    Response.Write "<li>" & rs("COLUMN_NAME") & " (" & rs("DATA_TYPE") & ")</li>"
                    rs.movenext
                Wend
                Response.Write "</ul>"
                
                ' Contar registros
                Call getRecordSet("SELECT COUNT(*) as total FROM tiamat_steps", rs)
                If Not rs.eof Then Response.Write "<p><strong>Total de steps:</strong> " & rs("total") & "</p>"
                
                ' Verificar tiamat_workflows
                Call getRecordSet("SELECT COLUMN_NAME, DATA_TYPE FROM INFORMATION_SCHEMA.COLUMNS WHERE TABLE_NAME = 'tiamat_workflows' ORDER BY ORDINAL_POSITION", rs)
                Response.Write "<h4>Tabela tiamat_workflows:</h4><ul>"
                While Not rs.eof
                    Response.Write "<li>" & rs("COLUMN_NAME") & " (" & rs("DATA_TYPE") & ")</li>"
                    rs.movenext
                Wend
                Response.Write "</ul>"
                
                ' Contar registros
                Call getRecordSet("SELECT COUNT(*) as total FROM tiamat_workflows", rs)
                If Not rs.eof Then Response.Write "<p><strong>Total de workflows:</strong> " & rs("total") & "</p>"
                
                Err.Clear
                
        End Select
        
        Response.Write "<hr>"
    End If
    %>
    
    <div class="info">
        <h3>📊 Informações do Sistema</h3>
        <p><strong>StepID atual para testes:</strong> <%= stepID %></p>
        <p><strong>Versão ASP:</strong> <%= ScriptEngine & " " & ScriptEngineMajorVersion & "." & ScriptEngineMinorVersion %></p>
        <p><strong>Servidor:</strong> <%= Request.ServerVariables("SERVER_SOFTWARE") %></p>
        <p><strong>Caminho:</strong> <%= Server.MapPath("/") %></p>
    </div>
    
    <h3>🧪 Testes Disponíveis</h3>
    
    <div class="button-group">
        <a href="?action=test_class"><button>1. Testar Classe</button></a>
        <a href="?action=show_structure"><button>2. Ver Estrutura BD</button></a>
        <a href="?action=test_capture&stepID=<%= stepID %>"><button>3. Testar Captura</button></a>
        <a href="?action=test_retrieve&stepID=<%= stepID %>"><button>4. Testar Recuperação</button></a>
        <a href="?action=test_global&stepID=<%= stepID %>"><button>5. Testar Funções Globais</button></a>
    </div>
    
    <h3>⚙️ Teste Personalizado</h3>
    
    <form method="get">
        <div class="form-group">
            <label>Ação:</label>
            <select name="action">
                <option value="test_capture">Capturar Output</option>
                <option value="test_retrieve">Recuperar Output</option>
                <option value="test_global">Testar Global</option>
            </select>
        </div>
        
        <div class="form-group">
            <label>Step ID:</label>
            <input type="number" name="stepID" value="<%= stepID %>">
        </div>
        
        <div class="form-group">
            <label>Dados JSON (para captura):</label>
            <textarea name="data" rows="3">{"custom": "test data", "timestamp": "<%= Now() %>"}</textarea>
        </div>
        
        <button type="submit">Executar Teste</button>
    </form>
    
    <h3>🔗 Links Úteis</h3>
    <div class="button-group">
        <a href="setup_test_data.asp"><button>Setup Dados</button></a>
        <a href="test_output_manager.asp"><button>Testes Automatizados</button></a>
        <a href="integration_complete.asp"><button>Documentação</button></a>
    </div>
    
    <div class="info">
        <h4>💡 Dicas:</h4>
        <ul>
            <li>Execute primeiro "Setup Dados" para criar dados de teste</li>
            <li>Use "Ver Estrutura BD" para entender as tabelas</li>
            <li>Teste passo a passo: Classe → Captura → Recuperação</li>
            <li>Se houver erros, verifique as permissões do servidor</li>
        </ul>
    </div>
</body>
</html>