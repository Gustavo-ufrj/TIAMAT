<!--#include virtual="/system.asp"-->
<!--#include file="INC_SCENARIO.inc"-->
<!--#include virtual="/TiamatOutputManager.asp"-->

Response.ContentType = "text/html; charset=utf-8"
%>
<!DOCTYPE html>
<html lang="pt-BR">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Teste - Correção Scenario/index.asp</title>
    <link href="https://cdn.jsdelivr.net/npm/bootstrap@5.1.3/dist/css/bootstrap.min.css" rel="stylesheet">
    <link rel="stylesheet" href="https://cdn.jsdelivr.net/npm/bootstrap-icons@1.7.2/font/bootstrap-icons.css">
</head>
<body>
    <div class="container mt-4">
        <h1><i class="bi bi-tools"></i> Teste de Correção - Scenario Module</h1>
        <div class="alert alert-info">
            <strong>Local do teste:</strong> /FTA/scenario/test_scenario_fix.asp<br>
            <strong>Objetivo:</strong> Verificar se o erro SQL na linha 133 foi resolvido e se a integração Dublin Core está funcionando.
        </div>

        <div class="row">
            <div class="col-md-6">
                <div class="card">
                    <div class="card-header bg-primary text-white">
                        <h5>1. Verificação de Inclusões</h5>
                    </div>
                    <div class="card-body">
                        <%
                        Response.Write "<h6>Testando arquivos incluídos:</h6>"
                        
                        ' Teste 1: system.asp
                        On Error Resume Next
                        Dim testConnection
                        Set testConnection = getConnection()
                        If Err.Number = 0 And Not testConnection Is Nothing Then
                            Response.Write "<div class='text-success'><i class='bi bi-check'></i> system.asp: Carregado com sucesso</div>"
                            testConnection.Close
                            Set testConnection = Nothing
                        Else
                            Response.Write "<div class='text-danger'><i class='bi bi-x'></i> system.asp: Erro - " & Err.Description & "</div>"
                            Err.Clear
                        End If
                        
                        ' Teste 2: INC_SCENARIO.inc
                        Dim testSQL
                        testSQL = SQL_CONSULTA_SCENARIOS("1")
                        If Err.Number = 0 And testSQL <> "" Then
                            Response.Write "<div class='text-success'><i class='bi bi-check'></i> INC_SCENARIO.inc: Carregado com sucesso</div>"
                        Else
                            Response.Write "<div class='text-danger'><i class='bi bi-x'></i> INC_SCENARIO.inc: Erro ou não encontrado - " & Err.Description & "</div>"
                            Err.Clear
                        End If
                        
                        ' Teste 3: TiamatOutputManager (opcional)
                        Dim testOutputManager
                        Set testOutputManager = Server.CreateObject("Scripting.Dictionary") ' Fallback se TiamatOutputManager não estiver disponível
                        Response.Write "<div class='text-info'><i class='bi bi-info'></i> TiamatOutputManager: Usando fallback (normal se arquivo não existir ainda)</div>"
                        
                        On Error Goto 0
                        %>
                    </div>
                </div>
            </div>

            <div class="col-md-6">
                <div class="card">
                    <div class="card-header bg-success text-white">
                        <h5>2. Teste das Funções SQL</h5>
                    </div>
                    <div class="card-body">
                        <%
                        Response.Write "<h6>Testando funções corrigidas:</h6>"
                        
                        On Error Resume Next
                        
                        ' Teste das funções uma por uma
                        Dim testResults(4)
                        Dim testNames(4)
                        
                        testNames(0) = "SQL_CONSULTA_SCENARIOS"
                        testResults(0) = SQL_CONSULTA_SCENARIOS("1")
                        
                        testNames(1) = "SQL_CONSULTA_SCENARIOS_BY_SCENARIO_ID"
                        testResults(1) = SQL_CONSULTA_SCENARIOS_BY_SCENARIO_ID("1")
                        
                        testNames(2) = "SQL_CRIA_SCENARIO"
                        testResults(2) = SQL_CRIA_SCENARIO("1", "Teste", "Conteúdo")
                        
                        testNames(3) = "SQL_ATUALIZA_SCENARIO"
                        testResults(3) = SQL_ATUALIZA_SCENARIO("1", "Teste", "Conteúdo")
                        
                        testNames(4) = "SQL_DELETE_SCENARIO"
                        testResults(4) = SQL_DELETE_SCENARIO("1")
                        
                        Dim i
                        For i = 0 To 4
                            If testResults(i) <> "" And Err.Number = 0 Then
                                Response.Write "<div class='text-success'><i class='bi bi-check'></i> " & testNames(i) & ": OK</div>"
                            Else
                                Response.Write "<div class='text-danger'><i class='bi bi-x'></i> " & testNames(i) & ": Erro</div>"
                                If Err.Number <> 0 Then
                                    Response.Write "<small class='text-muted'>Erro: " & Err.Description & "</small><br>"
                                    Err.Clear
                                End If
                            End If
                        Next
                        
                        On Error Goto 0
                        %>
                    </div>
                </div>
            </div>
        </div>

        <div class="row mt-4">
            <div class="col-12">
                <div class="card">
                    <div class="card-header bg-warning text-dark">
                        <h5>3. Teste de Conexão com Banco</h5>
                    </div>
                    <div class="card-body">
                        <%
                        Response.Write "<h6>Verificando conexão e estrutura:</h6>"
                        
                        On Error Resume Next
                        
                        ' Teste de conexão
                        Dim conn
                        Set conn = getConnection()
                        If Err.Number = 0 And Not conn Is Nothing Then
                            Response.Write "<div class='text-success'><i class='bi bi-check'></i> Conexão com banco: OK</div>"
                            
                            ' Verificar tabelas relacionadas a scenario
                            Dim rs
                            Call getRecordSet("SELECT TABLE_NAME FROM INFORMATION_SCHEMA.TABLES WHERE TABLE_NAME LIKE '%scenario%'", rs)
                            
                            If Err.Number = 0 Then
                                Response.Write "<h6 class='mt-3'>Tabelas encontradas:</h6>"
                                If Not rs.eof Then
                                    Response.Write "<ul>"
                                    While Not rs.eof
                                        Response.Write "<li>" & rs("TABLE_NAME") & "</li>"
                                        rs.movenext
                                    Wend
                                    Response.Write "</ul>"
                                Else
                                    Response.Write "<div class='text-warning'>Nenhuma tabela com 'scenario' encontrada</div>"
                                End If
                            Else
                                Response.Write "<div class='text-danger'>Erro ao consultar tabelas: " & Err.Description & "</div>"
                                Err.Clear
                            End If
                            
                            conn.Close
                            Set conn = Nothing
                        Else
                            Response.Write "<div class='text-danger'><i class='bi bi-x'></i> Conexão com banco: Erro - " & Err.Description & "</div>"
                            Err.Clear
                        End If
                        
                        On Error Goto 0
                        %>
                    </div>
                </div>
            </div>
        </div>

        <div class="row mt-4">
            <div class="col-12">
                <div class="card">
                    <div class="card-header bg-info text-white">
                        <h5>4. Teste Específico do Erro Original</h5>
                    </div>
                    <div class="card-body">
                        <%
                        Response.Write "<h6>Simulando condições que causavam 'Sintaxe incorreta próxima a =':</h6>"
                        
                        ' Teste com inputs problemáticos
                        Dim problematicCases(3)
                        problematicCases(0) = "Nome com 'aspas simples'"
                        problematicCases(1) = "Nome com ""aspas duplas"""
                        problematicCases(2) = "Nome com = sinal igual"
                        problematicCases(3) = "Nome com; ponto vírgula"
                        
                        Dim j
                        For j = 0 To 3
                            On Error Resume Next
                            
                            Dim safeName
                            safeName = ValidateScenarioInput(problematicCases(j))
                            
                            Dim testSQLCreate
                            testSQLCreate = SQL_CRIA_SCENARIO("1", safeName, "Conteúdo de teste")
                            
                            If Err.Number = 0 And testSQLCreate <> "" Then
                                Response.Write "<div class='text-success'><i class='bi bi-check'></i> Caso " & (j+1) & ": SQL gerado sem erro</div>"
                                Response.Write "<small class='text-muted'>Input: " & problematicCases(j) & "</small><br>"
                                Response.Write "<small class='text-muted'>Sanitizado: " & safeName & "</small><br><br>"
                            Else
                                Response.Write "<div class='text-danger'><i class='bi bi-x'></i> Caso " & (j+1) & ": Ainda há problema - " & Err.Description & "</div>"
                                Err.Clear
                            End If
                            
                            On Error Goto 0
                        Next
                        %>
                    </div>
                </div>
            </div>
        </div>

        <div class="row mt-4">
            <div class="col-12">
                <div class="card border-primary">
                    <div class="card-header bg-primary text-white">
                        <h5><i class="bi bi-info-circle"></i> Próximos Passos</h5>
                    </div>
                    <div class="card-body">
                        <div class="alert alert-light">
                            <h6>Se os testes acima passaram:</h6>
                            <ol>
                                <li><strong>Substitua o arquivo original:</strong> 
                                    <code>/FTA/scenario/index.asp</code> pela versão corrigida</li>
                                <li><strong>Substitua o arquivo de funções:</strong> 
                                    <code>/FTA/scenario/INC_SCENARIO.inc</code> pela versão corrigida</li>
                                <li><strong>Teste o módulo scenario:</strong> 
                                    <a href="index.asp?stepID=1" class="btn btn-sm btn-primary">Testar Scenario</a></li>
                            </ol>
                        </div>
                        
                        <div class="alert alert-warning">
                            <h6>Se ainda houver erros:</h6>
                            <ul class="mb-0">
                                <li>Verifique se a tabela scenarios existe (ou qual é o nome correto)</li>
                                <li>Ajuste os nomes das tabelas no INC_SCENARIO.inc</li>
                                <li>Verifique as permissões de acesso ao banco</li>
                                <li>Confirme se o system.asp está no local correto</li>
                            </ul>
                        </div>
                        
                        <div class="mt-3">
                            <a href="../" class="btn btn-secondary me-2">
                                <i class="bi bi-arrow-left"></i> Voltar para FTA
                            </a>
                            <a href="index.asp" class="btn btn-primary">
                                <i class="bi bi-play"></i> Testar Scenario Module
                            </a>
                        </div>
                    </div>
                </div>
            </div>
        </div>
    </div>

    <script src="https://cdn.jsdelivr.net/npm/bootstrap@5.1.3/dist/js/bootstrap.bundle.min.js"></script>
</body>
</html>