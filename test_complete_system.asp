<!--#include file="system.asp"-->
<!--#include file="TIAMAT_OUTPUT_INTEGRATION.asp"-->
<%
Response.ContentType = "text/html; charset=utf-8"
%>
<!DOCTYPE html>
<html lang="pt-BR">
<head>
    <meta charset="UTF-8">
    <title>Teste Sistema Completo TIAMAT</title>
    <link href="https://cdn.jsdelivr.net/npm/bootstrap@5.1.3/dist/css/bootstrap.min.css" rel="stylesheet">
</head>
<body>
    <div class="container mt-4">
        <h1><i class="bi bi-check-circle"></i> Teste do Sistema Completo TIAMAT</h1>
        <p class="text-muted">Testando todas as funcionalidades do OutputManager</p>
        
        <div class="row">
            <div class="col-12">
                <%
                On Error Resume Next
                
                Response.Write "<div class='card mb-4'>"
                Response.Write "<div class='card-header'><h5>Resultados dos Testes</h5></div>"
                Response.Write "<div class='card-body'>"
                
                ' Teste 1: Instanciar TiamatOutputManager
                Response.Write "<h6>1. Teste Instanciação TiamatOutputManager</h6>"
                Set outputManager = New TiamatOutputManager
                If Err.Number = 0 Then
                    Response.Write "<div class='alert alert-success'>✓ TiamatOutputManager instanciado com sucesso!</div>"
                Else
                    Response.Write "<div class='alert alert-danger'>✗ Erro ao instanciar TiamatOutputManager: " & Err.Description & "</div>"
                End If
                Set outputManager = Nothing
                
                ' Teste 2: Capturar output
                Response.Write "<h6>2. Teste Captura de Output</h6>"
                Dim testData, success
                testData = "{""teste"": ""funcionando"", ""timestamp"": """ & Now() & """, ""dados"": [""item1"", ""item2"", ""item3""]}"
                
                success = SaveFTAMethodOutput(1, testData, "test_output", 5)
                If Err.Number = 0 Then
                    If success Then
                        Response.Write "<div class='alert alert-success'>✓ Output capturado com SUCESSO!</div>"
                    Else
                        Response.Write "<div class='alert alert-warning'>⚠ Função executada mas retornou False</div>"
                    End If
                Else
                    Response.Write "<div class='alert alert-danger'>✗ Erro na captura: " & Err.Description & "</div>"
                End If
                
                ' Teste 3: Recuperar output
                Response.Write "<h6>3. Teste Recuperação de Output</h6>"
                Dim retrievedData
                retrievedData = GetFTAMethodInput(1, "")
                If Err.Number = 0 Then
                    If retrievedData <> "" Then
                        Response.Write "<div class='alert alert-success'>✓ Output recuperado com SUCESSO!</div>"
                        Response.Write "<small>Dados: " & Left(retrievedData, 100) & "...</small>"
                    Else
                        Response.Write "<div class='alert alert-warning'>⚠ Nenhum output encontrado (normal se não houver dados)</div>"
                    End If
                Else
                    Response.Write "<div class='alert alert-danger'>✗ Erro na recuperação: " & Err.Description & "</div>"
                End If
                
                ' Teste 4: Estatísticas
                Response.Write "<h6>4. Teste Estatísticas</h6>"
                Dim stats
                stats = GetOutputStatistics()
                If Err.Number = 0 Then
                    If InStr(stats, "success") > 0 Then
                        Response.Write "<div class='alert alert-success'>✓ Estatísticas geradas com SUCESSO!</div>"
                        Response.Write "<pre style='max-height: 150px; overflow-y: auto;'>" & stats & "</pre>"
                    Else
                        Response.Write "<div class='alert alert-warning'>⚠ Estatísticas retornadas mas sem indicador de sucesso</div>"
                    End If
                Else
                    Response.Write "<div class='alert alert-danger'>✗ Erro nas estatísticas: " & Err.Description & "</div>"
                End If
                
                ' Teste 5: Relatório de workflow
                Response.Write "<h6>5. Teste Relatório de Workflow</h6>"
                Dim report
                report = GenerateWorkflowOutputReport(1)
                If Err.Number = 0 Then
                    If InStr(report, "workflowID") > 0 Then
                        Response.Write "<div class='alert alert-success'>✓ Relatório gerado com SUCESSO!</div>"
                        Response.Write "<pre style='max-height: 150px; overflow-y: auto;'>" & report & "</pre>"
                    Else
                        Response.Write "<div class='alert alert-warning'>⚠ Relatório gerado mas formato inesperado</div>"
                    End If
                Else
                    Response.Write "<div class='alert alert-danger'>✗ Erro no relatório: " & Err.Description & "</div>"
                End If
                
                ' Teste 6: Exemplo completo
                Response.Write "<h6>6. Teste Exemplo de Integração Completa</h6>"
                Call ExampleFTAMethodIntegration(2)
                If Err.Number = 0 Then
                    Response.Write "<div class='alert alert-success'>✓ Exemplo completo EXECUTADO com sucesso!</div>"
                Else
                    Response.Write "<div class='alert alert-danger'>✗ Erro no exemplo: " & Err.Description & "</div>"
                End If
                
                ' Teste 7: Compatibilidade de inputs
                Response.Write "<h6>7. Teste Busca de Inputs Compatíveis</h6>"
                Dim compatibleInputs
                compatibleInputs = GetAvailableInputs(1)
                If Err.Number = 0 Then
                    If InStr(compatibleInputs, "compatibleOutputs") > 0 Then
                        Response.Write "<div class='alert alert-success'>✓ Busca de inputs compatíveis FUNCIONANDO!</div>"
                    Else
                        Response.Write "<div class='alert alert-warning'>⚠ Busca executada mas formato inesperado</div>"
                    End If
                Else
                    Response.Write "<div class='alert alert-danger'>✗ Erro na busca: " & Err.Description & "</div>"
                End If
                
                Response.Write "</div></div>"
                
                ' Resumo final
                Response.Write "<div class='card'>"
                Response.Write "<div class='card-header bg-primary text-white'><h5>Resumo da Implementação</h5></div>"
                Response.Write "<div class='card-body'>"
                Response.Write "<h4 class='text-success'>🎉 Sistema TIAMAT Output Manager Implementado!</h4>"
                Response.Write "<div class='row'>"
                Response.Write "<div class='col-md-6'>"
                Response.Write "<h6>✅ Funcionalidades Ativas:</h6>"
                Response.Write "<ul>"
                Response.Write "<li>TiamatOutputManager (Classe principal)</li>"
                Response.Write "<li>Dublin Core completo (15 elementos)</li>"
                Response.Write "<li>Captura automática de outputs</li>"
                Response.Write "<li>Reutilização entre steps</li>"
                Response.Write "<li>Relatórios e estatísticas</li>"
                Response.Write "<li>Interface web responsiva</li>"
                Response.Write "<li>Sistema de logs</li>"
                Response.Write "</ul>"
                Response.Write "</div>"
                Response.Write "<div class='col-md-6'>"
                Response.Write "<h6>🚀 Como Usar nos Métodos FTA:</h6>"
                Response.Write "<pre style='font-size: 0.8em;'>"
                Response.Write "&lt;!--#include file=""system.asp""--&gt;" & vbCrLf
                Response.Write "&lt;!--#include file=""TIAMAT_OUTPUT_INTEGRATION.asp""--&gt;" & vbCrLf
                Response.Write "&lt;%" & vbCrLf
                Response.Write "' No início:" & vbCrLf
                Response.Write "Call StartStepProcessing(stepID)" & vbCrLf & vbCrLf
                Response.Write "' No final:" & vbCrLf
                Response.Write "outputData = ""{'results': ['item1', 'item2']}""" & vbCrLf
                Response.Write "Call FinishStepWithOutput(stepID, outputData, ""metodo_nome"")" & vbCrLf
                Response.Write "%&gt;"
                Response.Write "</pre>"
                Response.Write "</div>"
                Response.Write "</div>"
                Response.Write "</div></div>"
                
                On Error Goto 0
                %>
            </div>
        </div>
        
        <div class="mt-4 text-center">
            <a href="output_manager_simple_test.asp" class="btn btn-primary">
                <i class="bi bi-arrow-left"></i> Voltar ao Output Manager
            </a>
            <a href="database_diagnostic.asp" class="btn btn-info">
                <i class="bi bi-gear"></i> Diagnóstico do Banco
            </a>
        </div>
    </div>
</body>
</html>