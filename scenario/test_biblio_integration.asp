<!--#include virtual="/system.asp"-->
<!--#include virtual="/checkstep.asp"-->
<!--#include file="INC_SCENARIO.inc"-->
<%
Response.ContentType = "text/html; charset=utf-8"

' Verificar se TiamatOutputManager está disponível
Dim hasOutputManager
hasOutputManager = false

On Error Resume Next
' Tentar incluir o arquivo TiamatOutputManager
Server.Execute("/TiamatOutputManager.asp")
hasOutputManager = (Err.Number = 0)
On Error Goto 0

' Bootstrap e jQuery básicos
%>
<!DOCTYPE html>
<html lang="pt-BR">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Teste Integração Bibliométrica</title>
    <link href="https://cdn.jsdelivr.net/npm/bootstrap@5.1.3/dist/css/bootstrap.min.css" rel="stylesheet">
    <link href="https://cdn.jsdelivr.net/npm/bootstrap-icons@1.7.2/font/bootstrap-icons.css" rel="stylesheet">
    <script src="https://code.jquery.com/jquery-3.6.0.min.js"></script>
    <script src="https://cdn.jsdelivr.net/npm/bootstrap@5.1.3/dist/js/bootstrap.bundle.min.js"></script>
</head>
<body>
    <div class="container-fluid mt-4">
        <div class="row">
            <div class="col-12">
                <div class="card">
                    <div class="card-header bg-primary text-white">
                        <h4 class="mb-0">
                            <i class="bi bi-gear-fill me-2"></i>
                            ?? Teste de Integração Bibliométrica
                        </h4>
                    </div>
                    <div class="card-body">
                        
                        <!-- Status da Integração -->
                        <div class="alert alert-info">
                            <h5><i class="bi bi-info-circle me-2"></i>Status do Sistema</h5>
                            <ul class="mb-0">
                                <li><strong>Step ID:</strong> <%=Request.QueryString("stepID")%></li>
                                <li><strong>TiamatOutputManager:</strong> 
                                    <% if hasOutputManager then %>
                                        <span class="badge bg-success">? Disponível</span>
                                    <% else %>
                                        <span class="badge bg-danger">? Não Encontrado</span>
                                    <% end if %>
                                </li>
                                <li><strong>Data/Hora:</strong> <%=FormatDateTime(Now(), 0)%></li>
                            </ul>
                        </div>

                        <!-- Seção de Testes -->
                        <div class="row">
                            <div class="col-md-6">
                                <div class="card h-100">
                                    <div class="card-header bg-warning text-dark">
                                        <h6 class="mb-0">
                                            <i class="bi bi-database-fill-add me-2"></i>
                                            1. Criar Dados de Teste
                                        </h6>
                                    </div>
                                    <div class="card-body">
                                        <p class="small text-muted">Simula dados bibliométricos para testar a integração.</p>
                                        <button class="btn btn-warning w-100" onclick="createTestData()">
                                            <i class="bi bi-plus-circle me-2"></i>
                                            Criar Dados de Teste
                                        </button>
                                        <div id="testDataResult" class="mt-3"></div>
                                    </div>
                                </div>
                            </div>
                            
                            <div class="col-md-6">
                                <div class="card h-100">
                                    <div class="card-header bg-success text-white">
                                        <h6 class="mb-0">
                                            <i class="bi bi-play-circle-fill me-2"></i>
                                            2. Testar Add Scenario
                                        </h6>
                                    </div>
                                    <div class="card-body">
                                        <p class="small text-muted">Abre o manageScenario.asp para ver a integração funcionando.</p>
                                        <button class="btn btn-success w-100" onclick="testAddScenario()">
                                            <i class="bi bi-eye me-2"></i>
                                            Testar Add Scenario
                                        </button>
                                        <div id="testScenarioResult" class="mt-3"></div>
                                    </div>
                                </div>
                            </div>
                        </div>

                        <!-- Logs de Teste -->
                        <div class="card mt-4">
                            <div class="card-header bg-dark text-white">
                                <h6 class="mb-0">
                                    <i class="bi bi-terminal me-2"></i>
                                    Log de Teste
                                    <button class="btn btn-sm btn-outline-light float-end" onclick="clearLogs()">
                                        <i class="bi bi-trash"></i> Limpar
                                    </button>
                                </h6>
                            </div>
                            <div class="card-body p-0">
                                <div id="testLogs" style="height: 300px; overflow-y: auto; background: #1e1e1e; color: #fff; padding: 15px; font-family: 'Courier New', monospace; font-size: 12px;">
                                    <div class="text-muted">[Sistema] Aguardando início dos testes...</div>
                                </div>
                            </div>
                        </div>

                        <!-- Links Úteis -->
                        <div class="alert alert-secondary mt-4">
                            <h6><i class="bi bi-link-45deg me-2"></i>Links Úteis</h6>
                            <ul class="mb-0">
                                <li><a href="index.asp?stepID=<%=Request.QueryString("stepID")%>" target="_blank">Ver Step Scenario Normal</a></li>
                                <li><a href="manageScenario.asp?stepID=<%=Request.QueryString("stepID")%>" target="_blank">Add Scenario (Nova Aba)</a></li>
                                <li><a href="/test_integration.asp" target="_blank">Teste Sistema Geral</a></li>
                                <li><a href="javascript:void(0)" onclick="showWorkflowInfo()">Info do Workflow</a></li>
                            </ul>
                        </div>

                    </div>
                </div>
            </div>
        </div>
    </div>

<script>
function logMessage(message, type = 'info') {
    const timestamp = new Date().toLocaleTimeString();
    const colors = {
        'info': '#17a2b8',
        'success': '#28a745', 
        'error': '#dc3545',
        'warning': '#ffc107'
    };
    
    const logDiv = document.getElementById('testLogs');
    const color = colors[type] || '#17a2b8';
    
    logDiv.innerHTML += `<div style="color: ${color};">[${timestamp}] ${message}</div>`;
    logDiv.scrollTop = logDiv.scrollHeight;
}

function clearLogs() {
    document.getElementById('testLogs').innerHTML = '<div class="text-muted">[Sistema] Log limpo...</div>';
}

function createTestData() {
    logMessage('?? Iniciando criação de dados de teste...', 'info');
    
    const stepID = '<%=Request.QueryString("stepID")%>';
    
    // Dados de teste simulados
    const testData = {
        "analysisType": "Bibliometric Analysis",
        "stepID": stepID,
        "processedAt": new Date().toISOString(),
        "methodology": "Systematic Literature Review",
        "metrics": {
            "totalReferences": 25,
            "uniqueAuthors": 15,
            "timeSpan": "2020-2024",
            "topics": 8
        },
        "topAuthors": [
            {"name": "Silva, J.", "publications": 5},
            {"name": "Santos, M.", "publications": 4},
            {"name": "Oliveira, P.", "publications": 3}
        ],
        "yearlyDistribution": [
            {"year": 2020, "count": 3},
            {"year": 2021, "count": 5},
            {"year": 2022, "count": 7},
            {"year": 2023, "count": 6},
            {"year": 2024, "count": 4}
        ],
        "suggestions": "Based on bibliometric analysis, key research themes include artificial intelligence, machine learning, and data science applications."
    };
    
    // Simular sucesso
    setTimeout(() => {
        logMessage('? Dados de teste criados com sucesso!', 'success');
        logMessage('?? 25 referências, 15 autores únicos, 8 tópicos identificados', 'info');
        logMessage('?? Sugestões para cenários geradas', 'success');
        
        document.getElementById('testDataResult').innerHTML = `
            <div class="alert alert-success small">
                <strong>? Dados Criados:</strong><br>
                • 25 referências bibliográficas<br>
                • 15 autores únicos<br>
                • Período: 2020-2024<br>
                • 8 tópicos de pesquisa
            </div>
        `;
    }, 1500);
    
    logMessage('? Simulando análise bibliométrica...', 'warning');
}

function testAddScenario() {
    logMessage('?? Abrindo teste Add Scenario...', 'info');
    
    const stepID = '<%=Request.QueryString("stepID")%>';
    const url = `manageScenario.asp?stepID=${stepID}`;
    
    // Abrir em modal ou nova aba
    logMessage('?? Abrindo: ' + url, 'info');
    
    // Opção 1: Nova aba
    window.open(url, '_blank');
    
    logMessage('? Se a página carregar corretamente, a integração está funcionando!', 'success');
    logMessage('?? Procure pela seção azul "Literature-Based Scenario Development"', 'info');
    
    document.getElementById('testScenarioResult').innerHTML = `
        <div class="alert alert-info small">
            <strong>?? O que procurar:</strong><br>
            • Seção azul com título "Literature-Based Scenario Development"<br>
            • Botões "Generate Literature Template" e "Insert Research Insights"<br>
            • Badge "Literature-Enhanced" no campo scenario
        </div>
    `;
}

function showWorkflowInfo() {
    logMessage('?? Informações do Workflow:', 'info');
    logMessage('Step ID: <%=Request.QueryString("stepID")%>', 'info');
    logMessage('URL atual: ' + window.location.href, 'info');
    logMessage('User Agent: ' + navigator.userAgent.substring(0, 50) + '...', 'info');
}

// Executar ao carregar a página
document.addEventListener('DOMContentLoaded', function() {
    logMessage('?? Sistema de teste carregado', 'success');
    logMessage('?? Step ID: <%=Request.QueryString("stepID")%>', 'info');
    <% if hasOutputManager then %>
    logMessage('? TiamatOutputManager detectado', 'success');
    <% else %>
    logMessage('?? TiamatOutputManager não encontrado', 'warning');
    <% end if %>
});
</script>

</body>
</html>