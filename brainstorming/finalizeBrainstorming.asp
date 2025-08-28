<!--#include virtual="/system.asp"-->
<!--#include file="INC_BRAINSTORMING.inc"-->
<%
Dim stepID, action, brainstormingID
stepID = Request.QueryString("stepID")
action = Request.QueryString("action")

' Buscar brainstorming
call getRecordSet(SQL_CONSULTA_BRAINSTORMING(stepID), rs)
If Not rs.EOF Then
    brainstormingID = rs("brainstormingID")
End If

' Se ação for finalizar
If action = "finalize" Then
    ' Atualizar status do step para finalizado (assumindo que 5 = finalizado)
    call ExecuteSQL("UPDATE T_WORKFLOW_STEP SET status = 5 WHERE stepID = " & stepID)
    
    ' Redirecionar para o relatório
    Response.Redirect "finalizeBrainstorming.asp?stepID=" & stepID & "&action=report"
End If

' Gerar relatório
render.renderTitle()
%>

<style>
.report-container {
    max-width: 900px;
    margin: 0 auto;
    padding: 20px;
}

.report-header {
    background: linear-gradient(135deg, #667eea 0%, #764ba2 100%);
    color: white;
    padding: 30px;
    border-radius: 10px;
    margin-bottom: 30px;
}

.stat-card {
    background: white;
    border-radius: 10px;
    padding: 20px;
    box-shadow: 0 2px 10px rgba(0,0,0,0.1);
    margin-bottom: 20px;
}

.stat-number {
    font-size: 3em;
    font-weight: bold;
    color: #667eea;
}

.winner-card {
    background: linear-gradient(135deg, #f093fb 0%, #f5576c 100%);
    color: white;
    border-radius: 10px;
    padding: 20px;
    margin: 20px 0;
}

.idea-list {
    background: #f8f9fa;
    border-radius: 10px;
    padding: 20px;
    margin: 20px 0;
}

.print-button {
    position: fixed;
    top: 80px;
    right: 20px;
    z-index: 1000;
}

@media print {
    .no-print {
        display: none;
    }
    .report-container {
        max-width: 100%;
    }
}
</style>

<div class="report-container">
    <button class="btn btn-primary print-button no-print" onclick="window.print()">
        <i class="bi bi-printer"></i> Imprimir Relatório
    </button>

    <div class="report-header">
        <h1><i class="bi bi-file-text"></i> Relatório Final do Brainstorming</h1>
        <p>Step ID: <%=stepID%> | Data: <%=FormatDateTime(Now(), 2)%></p>
    </div>

    <%
    ' Estatísticas gerais
    Dim totalIdeas, totalVotes, totalParticipants
    
    ' Total de ideias
    call getRecordSet("SELECT COUNT(*) as total FROM T_FTA_METHOD_BRAINSTORMING_IDEAS WHERE brainstormingID = " & brainstormingID, rs)
    totalIdeas = rs("total")
    
    ' Total de votos
    call getRecordSet("SELECT COUNT(*) as total FROM T_FTA_METHOD_BRAINSTORMING_VOTING v " & _
                     "INNER JOIN T_FTA_METHOD_BRAINSTORMING_IDEAS i ON v.ideaID = i.ideaID " & _
                     "WHERE i.brainstormingID = " & brainstormingID, rs)
    totalVotes = rs("total")
    
    ' Total de participantes
    call getRecordSet("SELECT COUNT(DISTINCT email) as total FROM T_FTA_METHOD_BRAINSTORMING_IDEAS WHERE brainstormingID = " & brainstormingID, rs)
    totalParticipants = rs("total")
    %>

    <div class="row">
        <div class="col-md-4">
            <div class="stat-card text-center">
                <div class="stat-number"><%=totalIdeas%></div>
                <div>Ideias Propostas</div>
            </div>
        </div>
        <div class="col-md-4">
            <div class="stat-card text-center">
                <div class="stat-number"><%=totalVotes%></div>
                <div>Votos Registrados</div>
            </div>
        </div>
        <div class="col-md-4">
            <div class="stat-card text-center">
                <div class="stat-number"><%=totalParticipants%></div>
                <div>Participantes</div>
            </div>
        </div>
    </div>

    <!-- Top 3 Ideias -->
    <h2 class="mt-4"><i class="bi bi-trophy"></i> Ideias Vencedoras</h2>
    
    <%
    call getRecordSet(SQL_GET_IDEAS_RANKING(brainstormingID), rs)
    Dim position
    position = 1
    
    While Not rs.EOF And position <= 3
        Dim medalha
        If position = 1 Then medalha = "??"
        If position = 2 Then medalha = "??"
        If position = 3 Then medalha = "??"
    %>
        <div class="winner-card">
            <h3><%=medalha%> <%=position%>º Lugar - <%=rs("totalVotes")%> votos</h3>
            <h4><%=rs("title")%></h4>
            <p><%=rs("description")%></p>
            <small>Proposto por: <%=rs("email")%> em <%=FormatDateTime(rs("dateTime"), 2)%></small>
        </div>
    <%
        position = position + 1
        rs.MoveNext
    Wend
    %>

    <!-- Lista completa de ideias -->
    <h2 class="mt-4"><i class="bi bi-list-ul"></i> Todas as Ideias</h2>
    <div class="idea-list">
        <table class="table">
            <thead>
                <tr>
                    <th>Posição</th>
                    <th>Título</th>
                    <th>Autor</th>
                    <th>Votos</th>
                </tr>
            </thead>
            <tbody>
                <%
                call getRecordSet(SQL_GET_IDEAS_RANKING(brainstormingID), rs)
                position = 1
                While Not rs.EOF
                %>
                <tr>
                    <td><%=position%>º</td>
                    <td><%=rs("title")%></td>
                    <td><%=rs("email")%></td>
                    <td><%=rs("totalVotes")%></td>
                </tr>
                <%
                    position = position + 1
                    rs.MoveNext
                Wend
                %>
            </tbody>
        </table>
    </div>

    <!-- Análise Dublin Core -->
    <%
    ' Verificar se houve integração com Dublin Core
    Dim workflowID
    call getRecordSet("SELECT workflowID FROM T_WORKFLOW_STEP WHERE stepID = " & stepID, rs)
    If Not rs.EOF Then workflowID = rs("workflowID")
    
    Dim biblioCount, scenarioCount
    biblioCount = 0
    scenarioCount = 0
    
    ' Contar dados utilizados - CORRIGIDO para pegar apenas do step mais recente
    Dim biblioStepID, scenarioStepID
    
    ' Buscar step mais recente com bibliometrics
    call getRecordSet("SELECT TOP 1 s.stepID FROM T_WORKFLOW_STEP s " & _
                     "WHERE s.workflowID = " & workflowID & " AND s.stepID < " & stepID & _
                     " AND EXISTS (SELECT 1 FROM T_FTA_METHOD_BIBLIOMETRICS b WHERE b.stepID = s.stepID) " & _
                     " ORDER BY s.stepID DESC", rs)
    If Not rs.EOF Then
        biblioStepID = rs("stepID")
        call getRecordSet("SELECT COUNT(*) as total FROM T_FTA_METHOD_BIBLIOMETRICS WHERE stepID = " & biblioStepID, rs)
        If Not rs.EOF Then biblioCount = rs("total")
    End If
    
    ' Buscar step mais recente com scenarios
    call getRecordSet("SELECT TOP 1 s.stepID FROM T_WORKFLOW_STEP s " & _
                     "WHERE s.workflowID = " & workflowID & " AND s.stepID < " & stepID & _
                     " AND EXISTS (SELECT 1 FROM T_FTA_METHOD_SCENARIOS sc WHERE sc.stepID = s.stepID) " & _
                     " ORDER BY s.stepID DESC", rs)
    If Not rs.EOF Then
        scenarioStepID = rs("stepID")
        call getRecordSet("SELECT COUNT(*) as total FROM T_FTA_METHOD_SCENARIOS WHERE stepID = " & scenarioStepID, rs)
        If Not rs.EOF Then scenarioCount = rs("total")
    End If    
    If biblioCount > 0 Or scenarioCount > 0 Then
    %>
    <div class="stat-card mt-4">
        <h3><i class="bi bi-diagram-3"></i> Integração Dublin Core</h3>
        <p>Este brainstorming utilizou dados de métodos anteriores:</p>
        <ul>
            <% If biblioCount > 0 Then %>
            <li>?? <%=biblioCount%> referências bibliométricas</li>
            <% End If %>
            <% If scenarioCount > 0 Then %>
            <li>?? <%=scenarioCount%> cenários desenvolvidos</li>
            <% End If %>
        </ul>
    </div>
    <% End If %>

    <!-- Botões de ação -->
    <div class="text-center mt-5 no-print">
        <button class="btn btn-success btn-lg" onclick="exportarDados()">
            <i class="bi bi-download"></i> Exportar Dados
        </button>
        <button class="btn btn-primary btn-lg ms-3" onclick="window.print()">
            <i class="bi bi-printer"></i> Imprimir
        </button>
        <a href="index.asp?stepID=<%=stepID%>" class="btn btn-secondary btn-lg ms-3">
            <i class="bi bi-arrow-left"></i> Voltar
        </a>
    </div>
</div>

<script>
function exportarDados() {
    alert('Função de exportação será implementada.\nPor enquanto, use Ctrl+C para copiar ou imprima o relatório.');
    // Aqui poderia gerar CSV ou conectar com uma API de exportação
}
</script>

<%
render.renderFooter()
%>