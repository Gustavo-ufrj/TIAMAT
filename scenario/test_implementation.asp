<!--#include virtual="/system.asp"-->
<!--#include virtual="/TiamatOutputManager.asp"-->
<%
'=========================================
' TESTE R�PIDO DA IMPLEMENTA��O CORRIGIDA
' Execute este arquivo para testar se tudo est� funcionando
'=========================================

Response.ContentType = "text/html; charset=utf-8"
%>
<!DOCTYPE html>
<html>
<head>
    <title>Teste - Implementa��o Dublin Core + Scenario</title>
    <link href="https://cdn.jsdelivr.net/npm/bootstrap@5.1.3/dist/css/bootstrap.min.css" rel="stylesheet">
    <link rel="stylesheet" href="https://cdn.jsdelivr.net/npm/bootstrap-icons@1.7.2/font/bootstrap-icons.css">
</head>
<body>
    <div class="container mt-4">
        <h1><i class="bi bi-check-circle text-success"></i> Teste da Implementa��o Corrigida</h1>
        
        <div class="alert alert-info">
            <strong>Status:</strong> Testando com nomes corretos das tabelas identificadas
        </div>

        <div class="row">
            <!-- Teste 1: Verificar Tabelas -->
            <div class="col-md-6">
                <div class="card">
                    <div class="card-header bg-primary text-white">
                        <h5>1. Teste de Acesso �s Tabelas</h5>
                    </div>
                    <div class="card-body">
                        <%
                        On Error Resume Next
                        
                        ' Teste 1: T_FTA_METHOD_BIBLIOMETRICS
                        Dim rs1
                        Call getRecordSet("SELECT COUNT(*) as total FROM T_FTA_METHOD_BIBLIOMETRICS", rs1)
                        If Err.Number = 0 And Not rs1.eof Then
                            Response.Write "<div class='text-success'><i class='bi bi-check'></i> T_FTA_METHOD_BIBLIOMETRICS: " & rs1("total") & " registros</div>"
                        Else
                            Response.Write "<div class='text-danger'><i class='bi bi-x'></i> T_FTA_METHOD_BIBLIOMETRICS: Erro - " & Err.Description & "</div>"
                            Err.Clear
                        End If
                        
                        ' Teste 2: T_FTA_METHOD_BIBLIOMETRICS_TAGS
                        Dim rs2
                        Call getRecordSet("SELECT COUNT(*) as total FROM T_FTA_METHOD_BIBLIOMETRICS_TAGS", rs2)
                        If Err.Number = 0 And Not rs2.eof Then
                            Response.Write "<div class='text-success'><i class='bi bi-check'></i> T_FTA_METHOD_BIBLIOMETRICS_TAGS: " & rs2("total") & " registros</div>"
                        Else
                            Response.Write "<div class='text-danger'><i class='bi bi-x'></i> T_FTA_METHOD_BIBLIOMETRICS_TAGS: Erro - " & Err.Description & "</div>"
                            Err.Clear
                        End If
                        
                        ' Teste 3: T_FTA_METHOD_BIBLIOMETRICS_AUTHORS
                        Dim rs3
                        Call getRecordSet("SELECT COUNT(*) as total FROM T_FTA_METHOD_BIBLIOMETRICS_AUTHORS", rs3)
                        If Err.Number = 0 And Not rs3.eof Then
                            Response.Write "<div class='text-success'><i class='bi bi-check'></i> T_FTA_METHOD_BIBLIOMETRICS_AUTHORS: " & rs3("total") & " registros</div>"
                        Else
                            Response.Write "<div class='text-danger'><i class='bi bi-x'></i> T_FTA_METHOD_BIBLIOMETRICS_AUTHORS: Erro - " & Err.Description & "</div>"
                            Err.Clear
                        End If
                        
                        ' Teste 4: tiamat_steps
                        Dim rs4
                        Call getRecordSet("SELECT COUNT(*) as total FROM tiamat_steps WHERE methodID = 9", rs4)
                        If Err.Number = 0 And Not rs4.eof Then
                            Response.Write "<div class='text-success'><i class='bi bi-check'></i> tiamat_steps (Bibliometrics): " & rs4("total") & " steps</div>"
                        Else
                            Response.Write "<div class='text-danger'><i class='bi bi-x'></i> tiamat_steps: Erro - " & Err.Description & "</div>"
                            Err.Clear
                        End If
                        
                        ' Teste 5: T_FTA_METHOD_SCENARIOS
                        Dim rs5
                        Call getRecordSet("SELECT COUNT(*) as total FROM T_FTA_METHOD_SCENARIOS", rs5)
                        If Err.Number = 0 And Not rs5.eof Then
                            Response.Write "<div class='text-success'><i class='bi bi-check'></i> T_FTA_METHOD_SCENARIOS: " & rs5("total") & " cen�rios</div>"
                        Else
                            Response.Write "<div class='text-danger'><i class='bi bi-x'></i> T_FTA_METHOD_SCENARIOS: Erro - " & Err.Description & "</div>"
                            Err.Clear
                        End If
                        
                        On Error Goto 0
                        %>
                    </div>
                </div>
            </div>

            <!-- Teste 2: Verificar Fun��es -->
            <div class="col-md-6">
                <div class="card">
                    <div class="card-header bg-success text-white">
                        <h5>2. Teste das Fun��es</h5>
                    </div>
                    <div class="card-body">
                        <%
                        On Error Resume Next
                        
                        ' Teste fun��o GetBibliometricsForScenario
                        Dim testResult1
                        testResult1 = GetBibliometricsForScenario(1)
                        If Err.Number = 0 Then
                            Response.Write "<div class='text-success'><i class='bi bi-check'></i> GetBibliometricsForScenario: OK</div>"
                            If testResult1 <> "" Then
                                Response.Write "<div class='text-info small'>? Retornou dados</div>"
                            Else
                                Response.Write "<div class='text-warning small'>? N�o encontrou dados (normal se n�o h� bibliometrics)</div>"
                            End If
                        Else
                            Response.Write "<div class='text-danger'><i class='bi bi-x'></i> GetBibliometricsForScenario: Erro - " & Err.Description & "</div>"
                            Err.Clear
                        End If
                        
                        ' Teste fun��o GenerateScenarioSuggestions
                        Dim testResult2
                        testResult2 = GenerateScenarioSuggestions("")
                        If Err.Number = 0 Then
                            Response.Write "<div class='text-success'><i class='bi bi-check'></i> GenerateScenarioSuggestions: OK</div>"
                        Else
                            Response.Write "<div class='text-danger'><i class='bi bi-x'></i> GenerateScenarioSuggestions: Erro - " & Err.Description & "</div>"
                            Err.Clear
                        End If
                        
                        ' Teste fun��o GenerateIntelligentScenarioTemplate
                        Dim testResult3
                        testResult3 = GenerateIntelligentScenarioTemplate("")
                        If Err.Number = 0 Then
                            Response.Write "<div class='text-success'><i class='bi bi-check'></i> GenerateIntelligentScenarioTemplate: OK</div>"
                        Else
                            Response.Write "<div class='text-danger'><i class='bi bi-x'></i> GenerateIntelligentScenarioTemplate: Erro - " & Err.Description & "</div>"
                            Err.Clear
                        End If
                        
                        On Error Goto 0
                        %>
                    </div>
                </div>
            </div>
        </div>

        <!-- Teste 3: Buscar Steps com Dados -->
        <div class="row mt-4">
            <div class="col-12">
                <div class="card">
                    <div class="card-header bg-info text-white">
                        <h5>3. Steps com Dados Bibliom�tricos Dispon�veis</h5>
                    </div>
                    <div class="card-body">
                        <%
                        On Error Resume Next
                        
                        Dim rsSteps
                        Call getRecordSet("SELECT br.stepID, COUNT(*) as total_refs, COUNT(DISTINCT bt.tag) as topics, COUNT(DISTINCT ba.name) as authors FROM T_FTA_METHOD_BIBLIOMETRICS br LEFT JOIN T_FTA_METHOD_BIBLIOMETRICS_REFERENCE_X_TAG brt ON br.referenceID = brt.referenceID LEFT JOIN T_FTA_METHOD_BIBLIOMETRICS_TAGS bt ON brt.tagID = bt.tagID LEFT JOIN T_FTA_METHOD_BIBLIOMETRICS_AUTHORS ba ON br.referenceID = ba.referenceID GROUP BY br.stepID ORDER BY total_refs DESC", rsSteps)
                        
                        If Err.Number = 0 And Not rsSteps.eof Then
                            Response.Write "<div class='table-responsive'>"
                            Response.Write "<table class='table table-sm table-striped'>"
                            Response.Write "<thead><tr><th>Step ID</th><th>Refer�ncias</th><th>T�picos</th><th>Autores</th><th>A��o</th></tr></thead>"
                            Response.Write "<tbody>"
                            
                            While Not rsSteps.eof
                                Response.Write "<tr>"
                                Response.Write "<td><strong>" & rsSteps("stepID") & "</strong></td>"
                                Response.Write "<td>" & rsSteps("total_refs") & "</td>"
                                Response.Write "<td>" & rsSteps("topics") & "</td>"
                                Response.Write "<td>" & rsSteps("authors") & "</td>"
                                Response.Write "<td><button class='btn btn-sm btn-outline-primary' onclick='testStep(" & rsSteps("stepID") & ")'>Testar</button></td>"
                                Response.Write "</tr>"
                                rsSteps.movenext
                            Wend
                            
                            Response.Write "</tbody></table>"
                            Response.Write "</div>"
                        Else
                            Response.Write "<div class='alert alert-warning'>Nenhum step com dados bibliom�tricos encontrado.</div>"
                            If Err.Number <> 0 Then
                                Response.Write "<div class='text-danger'>Erro: " & Err.Description & "</div>"
                                Err.Clear
                            End If
                        End If
                        
                        On Error Goto 0
                        %>
                    </div>
                </div>
            </div>
        </div>

        <!-- �rea de Teste Din�mico -->
        <div class="row mt-4">
            <div class="col-12">
                <div class="card">
                    <div class="card-header bg-warning text-dark">
                        <h5>4. Teste Din�mico</h5>
                    </div>
                    <div class="card-body">
                        <div id="testResults">
                            <p>Clique em "Testar" em algum step acima para ver os dados reais que ser�o gerados.</p>
                        </div>
                    </div>
                </div>
            </div>
        </div>

        <div class="mt-4">
            <div class="alert alert-success">
                <h6>? Pr�ximos Passos se Tudo Estiver OK:</h6>
                <ol>
                    <li>Substitua o <code>/TiamatOutputManager.asp</code> pela vers�o corrigida</li>
                    <li>Substitua o <code>/FTA/scenario/scenarioActions.asp</code> pela vers�o corrigida</li>
                    <li>Teste em um scenario real usando um stepID que tenha dados bibliom�tricos</li>
                </ol>
            </div>
        </div>
    </div>

    <script>
        function testStep(stepID) {
            document.getElementById('testResults').innerHTML = '<div class="spinner-border" role="status"></div> Testando step ' + stepID + '...';
            
            // Simular teste (em produ��o, faria chamada AJAX real)
            setTimeout(function() {
                document.getElementById('testResults').innerHTML = 
                    '<div class="alert alert-info">' +
                    '<h6>Teste para Step ID: ' + stepID + '</h6>' +
                    '<p>Este step tem dados bibliom�tricos. Para testar completamente:</p>' +
                    '<ol>' +
                    '<li>V� para o workflow que cont�m este step</li>' +
                    '<li>Abra um step de Scenario no mesmo workflow</li>' +
                    '<li>Clique em "Add Scenario"</li>' +
                    '<li>Teste os bot�es "Generate Literature-Based Template" e "View Detailed Analysis"</li>' +
                    '</ol>' +
                    '</div>';
            }, 1000);
        }
    </script>
</body>
</html>