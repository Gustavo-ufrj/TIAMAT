<!--#include file="TiamatOutputManager.asp"-->
<%
Response.ContentType = "text/html; charset=utf-8"

Dim action, stepID, outputData, outputType
action = Request.QueryString("action")
stepID = Request.QueryString("stepID")
outputData = Request.Form("outputData")
outputType = Request.Form("outputType")

If stepID = "" Then stepID = 999 ' ID de teste padrão
%>
<!DOCTYPE html>
<html lang="pt-BR">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Teste Manual - TIAMAT Output Manager</title>
    <link href="https://cdn.jsdelivr.net/npm/bootstrap@5.1.3/dist/css/bootstrap.min.css" rel="stylesheet">
    <link rel="stylesheet" href="https://cdn.jsdelivr.net/npm/bootstrap-icons@1.7.2/font/bootstrap-icons.css">
    <style>
        .json-output {
            background-color: #f8f9fa;
            border: 1px solid #dee2e6;
            border-radius: 8px;
            padding: 15px;
            font-family: 'Courier New', monospace;
            font-size: 0.9em;
            white-space: pre-wrap;
        }
        .test-section {
            background-color: #f1f3f4;
            border-radius: 8px;
            padding: 20px;
            margin: 15px 0;
        }
    </style>
</head>
<body>
    <div class="container mt-4">
        <h2><i class="bi bi-tools"></i> Teste Manual - TIAMAT Output Manager</h2>
        <p class="text-muted">Interface para testar manualmente o sistema de captura de outputs</p>
        <hr>
        
        <%
        If action <> "" Then
            Response.Write "<div class='alert alert-primary'>"
            Response.Write "<h5>Executando: " & action & "</h5>"
            Response.Write "</div>"
            
            Select Case action
                Case "capture"
                    ' Testar captura de output
                    If outputData <> "" And outputType <> "" Then
                        Dim outputManager, result
                        Set outputManager = New TiamatOutputManager
                        
                        On Error Resume Next
                        result = outputManager.CaptureStepOutput(CInt(stepID), outputData, outputType)
                        
                        If Err.Number = 0 And result Then
                            Response.Write "<div class='alert alert-success'>"
                            Response.Write "<i class='bi bi-check-circle'></i> <strong>Sucesso!</strong> Output capturado para stepID " & stepID
                            Response.Write "</div>"
                        Else
                            Response.Write "<div class='alert alert-danger'>"
                            Response.Write "<i class='bi bi-x-circle'></i> <strong>Erro:</strong> " & Err.Description
                            Response.Write "</div>"
                        End If
                        
                        Set outputManager = Nothing
                        Err.Clear
                    End If
                    
                Case "retrieve"
                    ' Testar recuperação de output
                    Dim outputManager, retrievedData
                    Set outputManager = New TiamatOutputManager
                    
                    On Error Resume Next
                    retrievedData = outputManager.GetStepOutput(CInt(stepID))
                    
                    If Err.Number = 0 And retrievedData <> "" Then
                        Response.Write "<div class='alert alert-success'>"
                        Response.Write "<i class='bi bi-check-circle'></i> <strong>Output Recuperado:</strong>"
                        Response.Write "</div>"
                        Response.Write "<div class='json-output'>" & Server.HTMLEncode(retrievedData) & "</div>"
                    Else
                        Response.Write "<div class='alert alert-warning'>"
                        Response.Write "<i class='bi bi-exclamation-triangle'></i> <strong>Nenhum output encontrado ou erro:</strong> " & Err.Description
                        Response.Write "</div>"
                    End If
                    
                    Set outputManager = Nothing
                    Err.Clear
                    
                Case "list"
                    ' Testar listagem de outputs
                    Dim outputManager, outputList
                    Set outputManager = New TiamatOutputManager
                    
                    On Error Resume Next
                    outputList = outputManager.ListAvailableOutputs(999) ' Workflow de teste
                    
                    If Err.Number = 0 And outputList <> "" Then
                        Response.Write "<div class='alert alert-success'>"
                        Response.Write "<i class='bi bi-check-circle'></i> <strong>Lista de Outputs:</strong>"
                        Response.Write "</div>"
                        Response.Write "<div class='json-output'>" & Server.HTMLEncode(outputList) & "</div>"
                    Else
                        Response.Write "<div class='alert alert-warning'>"
                        Response.Write "<i class='bi bi-exclamation-triangle'></i> <strong>Erro ao listar:</strong> " & Err.Description
                        Response.Write "</div>"
                    End If
                    
                    Set outputManager = Nothing
                    Err.Clear
                    
                Case "global_test"
                    ' Testar funções globais
                    On Error Resume Next
                    
                    Dim globalResult
                    globalResult = SaveFTAMethodOutput(CInt(stepID), "{""global_test"": true, ""timestamp"": """ & Now() & """}", "global")
                    
                    If Err.Number = 0 And globalResult Then
                        Response.Write "<div class='alert alert-success'>"
                        Response.Write "<i class='bi bi-check-circle'></i> <strong>Função Global OK!</strong>"
                        Response.Write "</div>"
                        
                        ' Testar recuperação
                        Dim globalOutput
                        globalOutput = GetFTAMethodOutput(CInt(stepID))
                        Response.Write "<div class='json-output'>" & Server.HTMLEncode(globalOutput) & "</div>"
                    Else
                        Response.Write "<div class='alert alert-danger'>"
                        Response.Write "<i class='bi bi-x-circle'></i> <strong>Erro na função global:</strong> " & Err.Description
                        Response.Write "</div>"
                    End If
                    Err.Clear
            End Select
        End If
        %>
        
        <div class="row">
            <!-- Capturar Output -->
            <div class="col-md-6">
                <div class="test-section">
                    <h4><i class="bi bi-download"></i> Capturar Output</h4>
                    <form method="post" action="?action=capture&stepID=<%= stepID %>">
                        <div class="mb-3">
                            <label for="stepID" class="form-label">Step ID</label>
                            <input type="number" class="form-control" name="stepID" value="<%= stepID %>">
                        </div>
                        <div class="mb-3">
                            <label for="outputType" class="form-label">Tipo de Output</label>
                            <select class="form-select" name="outputType">
                                <option value="test">Test</option>
                                <option value="json">JSON</option>
                                <option value="bibliometrics">Bibliometrics</option>
                                <option value="analysis">Analysis</option>
                            </select>
                        </div>
                        <div class="mb-3">
                            <label for="outputData" class="form-label">Dados do Output (JSON)</label>
                            <textarea class="form-control" name="outputData" rows="5" placeholder='{"exemplo": "dados", "timestamp": "agora"}'></textarea>
                        </div>
                        <button type="submit" class="btn btn-primary">
                            <i class="bi bi-download"></i> Capturar Output
                        </button>
                    </form>
                </div>
            </div>
            
            <!-- Recuperar Output -->
            <div class="col-md-6">
                <div class="test-section">
                    <h4><i class="bi bi-upload"></i> Recuperar Output</h4>
                    <form method="get">
                        <input type="hidden" name="action" value="retrieve">
                        <div class="mb-3">
                            <label for="stepID" class="form-label">Step ID</label>
                            <input type="number" class="form-control" name="stepID" value="<%= stepID %>">
                        </div>
                        <button type="submit" class="btn btn-success">
                            <i class="bi bi-upload"></i> Recuperar Output
                        </button>
                    </form>
                    
                    <hr>
                    
                    <h5>Outras Ações</h5>
                    <div class="d-grid gap-2">
                        <a href="?action=list&stepID=<%= stepID %>" class="btn btn-info">
                            <i class="bi bi-list"></i> Listar Outputs
                        </a>
                        <a href="?action=global_test&stepID=<%= stepID %>" class="btn btn-warning">
                            <i class="bi bi-globe"></i> Testar Funções Globais
                        </a>
                    </div>
                </div>
            </div>
        </div>
        
        <div class="row mt-4">
            <div class="col-12">
                <div class="test-section">
                    <h4><i class="bi bi-info-circle"></i> Informações do Sistema</h4>
                    <div class="row">
                        <div class="col-md-6">
                            <%
                            ' Verificar se dados de teste existem
                            Dim rs
                            On Error Resume Next
                            Call getRecordSet("SELECT s.stepID, s.description, w.description as workflow_desc " & _
                                             "FROM tiamat_steps s " & _
                                             "INNER JOIN tiamat_workflows w ON s.workflowID = w.workflowID " & _
                                             "WHERE s.stepID = " & stepID, rs)
                            
                            If Not rs.eof And Err.Number = 0 Then
                            %>
                                <div class="alert alert-success">
                                    <h6>Dados de Teste Encontrados:</h6>
                                    <p><strong>Step:</strong> <%= rs("description") %></p>
                                    <p><strong>Workflow:</strong> <%= rs("workflow_desc") %></p>
                                    <p><strong>Step ID:</strong> <%= stepID %></p>
                                </div>
                            <%
                            Else
                            %>
                                <div class="alert alert-warning">
                                    <h6>Dados de Teste Não Encontrados</h6>
                                    <p>Execute primeiro: <a href="setup_test_data.asp" class="btn btn-sm btn-primary">Setup Test Data</a></p>
                                </div>
                            <%
                            End If
                            Err.Clear
                            %>
                        </div>
                        <div class="col-md-6">
                            <div class="alert alert-info">
                                <h6>Links Úteis:</h6>
                                <ul class="mb-0">
                                    <li><a href="setup_test_data.asp">Setup Test Data</a></li>
                                    <li><a href="test_output_manager.asp">Testes Automatizados</a></li>
                                    <li><a href="output_manager_interface.asp">Interface Principal</a></li>
                                    <li><a href="integration_complete.asp">Documentação</a></li>
                                </ul>
                            </div>
                        </div>
                    </div>
                </div>
            </div>
        </div>
        
        <div class="row mt-4">
            <div class="col-12">
                <div class="alert alert-secondary">
                    <h6><i class="bi bi-lightbulb"></i> Exemplos de JSON para Teste:</h6>
                    <p><strong>Simples:</strong> <code>{"test": "data", "timestamp": "2024-01-01"}</code></p>
                    <p><strong>Bibliométrico:</strong> <code>{"references": [{"title": "Test Paper", "author": "Author"}], "total": 1}</code></p>
                    <p><strong>Complexo:</strong> <code>{"analysis": {"result": "positive", "confidence": 0.95}, "data": [1,2,3,4,5]}</code></p>
                </div>
            </div>
        </div>
    </div>

    <script src="https://cdn.jsdelivr.net/npm/bootstrap@5.1.3/dist/js/bootstrap.bundle.min.js"></script>
</body>
</html>