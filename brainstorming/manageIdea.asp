<!--#include virtual="/system.asp"-->
<!--#include virtual="/checkstep.asp"-->
<!--#include file="INC_BRAINSTORMING.inc"-->
<%
saveCurrentURL
render.renderToBody()
%>

<%
' Variaveis basicas
Dim stepID, brainstormingID, ideaID, action
Dim title, description, status

stepID = Request.QueryString("stepID")
brainstormingID = Request.QueryString("brainstormingID")
ideaID = Request.QueryString("ideaID")
action = Request.QueryString("action")

title = ""
description = ""
status = 1 ' Default: New Idea

' Se for edicao, buscar dados existentes
If action = "edit" And ideaID <> "" Then
    call getRecordSet("SELECT * FROM T_FTA_METHOD_BRAINSTORMING_IDEAS WHERE ideaID = " & ideaID, rs)
    If Not rs.EOF Then
        title = rs("title") & ""
        description = rs("description") & ""
        status = rs("status")
    End If
End If

' ========== BUSCAR DADOS DUBLIN CORE DOS METODOS ANTERIORES ==========
Dim hasDCData, dcDataHTML
hasDCData = false
dcDataHTML = ""

' Arrays para armazenar dados DC
Dim biblioTitles, biblioAuthors, biblioPeriod, biblioCount
Dim scenarioNames, scenarioDescriptions, scenarioCount

biblioTitles = ""
biblioAuthors = ""
biblioPeriod = ""
biblioCount = 0
scenarioNames = ""
scenarioDescriptions = ""
scenarioCount = 0

' Buscar workflow
Dim workflowID
call getRecordSet("SELECT workflowID FROM T_WORKFLOW_STEP WHERE stepID = " & stepID, rs)
If Not rs.EOF Then
    workflowID = rs("workflowID")
    
    ' ===== BUSCAR DADOS DO BIBLIOMETRICS =====
    call getRecordSet("SELECT TOP 1 s.stepID FROM T_WORKFLOW_STEP s " & _
                     "INNER JOIN T_FTA_METHOD_BIBLIOMETRICS b ON s.stepID = b.stepID " & _
                     "WHERE s.workflowID = " & workflowID & " AND s.stepID < " & stepID & _
                     " ORDER BY s.stepID DESC", rs)
    
    If Not rs.EOF Then
        Dim biblioStepID
        biblioStepID = rs("stepID")
        
        ' Contar referencias
        call getRecordSet("SELECT COUNT(*) as total FROM T_FTA_METHOD_BIBLIOMETRICS WHERE stepID = " & biblioStepID, rs)
        If Not rs.EOF Then
            biblioCount = rs("total")
            hasDCData = true
        End If
        
        ' Buscar alguns titulos
        call getRecordSet("SELECT TOP 3 title FROM T_FTA_METHOD_BIBLIOMETRICS WHERE stepID = " & biblioStepID, rs)
        While Not rs.EOF
            If biblioTitles <> "" Then biblioTitles = biblioTitles & " | "
            biblioTitles = biblioTitles & rs("title")
            rs.MoveNext
        Wend
        
        ' Buscar autores
        call getRecordSet("SELECT DISTINCT TOP 5 a.name FROM T_FTA_METHOD_BIBLIOMETRICS_AUTHORS a " & _
                         "INNER JOIN T_FTA_METHOD_BIBLIOMETRICS b ON a.referenceID = b.referenceID " & _
                         "WHERE b.stepID = " & biblioStepID, rs)
        While Not rs.EOF
            If biblioAuthors <> "" Then biblioAuthors = biblioAuthors & ", "
            biblioAuthors = biblioAuthors & rs("name")
            rs.MoveNext
        Wend
        
        ' Buscar periodo
        call getRecordSet("SELECT MIN(year) as min_year, MAX(year) as max_year FROM T_FTA_METHOD_BIBLIOMETRICS WHERE stepID = " & biblioStepID, rs)
        If Not rs.EOF Then
            If rs("min_year") & "" = rs("max_year") & "" Then
                biblioPeriod = rs("min_year") & ""
            Else
                biblioPeriod = rs("min_year") & "-" & rs("max_year")
            End If
        End If
    End If
    
    ' ===== BUSCAR DADOS DO SCENARIOS =====
    call getRecordSet("SELECT TOP 1 s.stepID FROM T_WORKFLOW_STEP s " & _
                     "INNER JOIN T_FTA_METHOD_SCENARIOS sc ON s.stepID = sc.stepID " & _
                     "WHERE s.workflowID = " & workflowID & " AND s.stepID < " & stepID & _
                     " ORDER BY s.stepID DESC", rs)
    
    If Not rs.EOF Then
        Dim scenarioStepID
        scenarioStepID = rs("stepID")
        
        ' Buscar cenarios
        call getRecordSet("SELECT name, LEFT(scenario, 200) as snippet FROM T_FTA_METHOD_SCENARIOS WHERE stepID = " & scenarioStepID, rs)
        While Not rs.EOF
            scenarioCount = scenarioCount + 1
            If scenarioNames <> "" Then scenarioNames = scenarioNames & " | "
            scenarioNames = scenarioNames & rs("name")
            
            If scenarioDescriptions <> "" Then scenarioDescriptions = scenarioDescriptions & " ### "
            scenarioDescriptions = scenarioDescriptions & Left(rs("snippet") & "", 100)
            rs.MoveNext
        Wend
        
        If scenarioCount > 0 Then hasDCData = true
    End If
End If
%>

<div class="p-3">

<h2><% If action = "edit" Then %>Editar Ideia<% Else %>Nova Ideia<% End If %></h2>

<% If hasDCData And action = "add" Then %>
<!-- ========== SECAO DUBLIN CORE ========== -->
<div class="card mb-4 border-info">
    <div class="card-header bg-info text-white">
        <h5 class="mb-0">
            <i class="bi bi-lightbulb me-2"></i>
            Dados Disponíveis para Inspiração (Dublin Core)
        </h5>
    </div>
    <div class="card-body">
        <% If biblioCount > 0 Then %>
        <div class="mb-3">
            <h6 class="text-primary">📚 Dados Bibliométricos (<%=biblioCount%> referências)</h6>
            <table class="table table-sm">
                <% If biblioTitles <> "" Then %>
                <tr>
                    <td width="120"><strong>Títulos:</strong></td>
                    <td><small><%=biblioTitles%></small></td>
                </tr>
                <% End If %>
                <% If biblioAuthors <> "" Then %>
                <tr>
                    <td><strong>Autores:</strong></td>
                    <td><small><%=biblioAuthors%></small></td>
                </tr>
                <% End If %>
                <% If biblioPeriod <> "" Then %>
                <tr>
                    <td><strong>Período:</strong></td>
                    <td><small><%=biblioPeriod%></small></td>
                </tr>
                <% End If %>
            </table>
        </div>
        <% End If %>
        
        <% If scenarioCount > 0 Then %>
        <div class="mb-3">
            <h6 class="text-success">🎯 Cenários Desenvolvidos (<%=scenarioCount%> cenários)</h6>
            <table class="table table-sm">
                <tr>
                    <td width="120"><strong>Cenários:</strong></td>
                    <td><small><%=scenarioNames%></small></td>
                </tr>
            </table>
        </div>
        <% End If %>
        
        <div class="d-flex gap-2">
            <button type="button" class="btn btn-outline-primary btn-sm" onclick="useAsBasis()">
                <i class="bi bi-arrow-down-circle me-1"></i>
                Usar como Base
            </button>
            <button type="button" class="btn btn-outline-success btn-sm" onclick="generateIdea()">
                <i class="bi bi-magic me-1"></i>
                Gerar Ideia Sugerida
            </button>
        </div>
    </div>
</div>
<% End If %>

<!-- FORMULARIO PRINCIPAL -->
<form action="ideaActions.asp" method="POST" id="formIdea">
    <input type="hidden" name="action" value="<% If action = "edit" Then %>update<% Else %>save<% End If %>">
    <input type="hidden" name="stepID" value="<%=stepID%>">
    <input type="hidden" name="brainstormingID" value="<%=brainstormingID%>">
    <input type="hidden" name="ideaID" value="<%=ideaID%>">
    <input type="hidden" name="status" value="<%=status%>">
    
    <div class="mb-3">
        <label for="title" class="form-label fw-bold">Título da Ideia *</label>
        <input type="text" class="form-control" id="title" name="title" value="<%=title%>" required maxlength="100">
        <div class="form-text">Máximo 100 caracteres</div>
    </div>
    
    <div class="mb-3">
        <label for="description" class="form-label fw-bold">Descrição Detalhada *</label>
        <textarea class="form-control" id="description" name="description" rows="8" required maxlength="8000"><%=description%></textarea>
        <div class="form-text">Descreva sua ideia em detalhes. Máximo 8000 caracteres.</div>
    </div>
    
    <div class="d-flex justify-content-between">
        <button type="button" class="btn btn-secondary" onclick="window.location.href='index.asp?stepID=<%=stepID%>';">
            <i class="bi bi-arrow-left me-1"></i>
            Cancelar
        </button>
        <button type="submit" class="btn btn-primary">
            <i class="bi bi-save me-1"></i>
            Salvar Ideia
        </button>
    </div>
</form>

</div>

<!-- JAVASCRIPT PARA DUBLIN CORE -->
<script type="text/javascript">
// Usar dados como base
function useAsBasis() {
    var titleField = document.getElementById('title');
    var descField = document.getElementById('description');
    
    var sugestao = "Baseado em: ";
    
    <% If biblioTitles <> "" Then %>
    sugestao += "Literatura analisada (<%=biblioCount%> refs, período <%=biblioPeriod%>). ";
    <% End If %>
    
    <% If scenarioNames <> "" Then %>
    sugestao += "Cenários: <%=Replace(scenarioNames, """", "")%>. ";
    <% End If %>
    
    if (titleField.value === '') {
        titleField.value = "Ideia baseada em análise bibliométrica";
    }
    
    if (descField.value === '') {
        descField.value = sugestao + "\n\n[Desenvolva sua ideia aqui, considerando os dados acima]";
    } else {
        descField.value = sugestao + "\n\n" + descField.value;
    }
    
    alert('Dados inseridos como base. Agora desenvolva sua ideia!');
}

// Gerar ideia sugerida
function generateIdea() {
    var titleField = document.getElementById('title');
    var descField = document.getElementById('description');
    
    // Sugestões baseadas nos dados
    var sugestoes = [
        {
            title: "Aplicação de IA baseada em <%=Left(Replace(biblioTitles, """", ""), 30)%>...",
            desc: "Desenvolver solução usando técnicas identificadas na literatura:\n\nReferências: <%=biblioCount%> publicações (<%=biblioPeriod%>)\n\nProposta: [Detalhe como aplicar os conceitos identificados]"
        },
        {
            title: "Dashboard para monitoramento de tendências",
            desc: "Sistema visual para acompanhar evolução das tecnologias identificadas:\n\nBase: <%=biblioCount%> referências analisadas\nAutores-chave: <%=Left(biblioAuthors, 100)%>\n\n[Descreva funcionalidades do dashboard]"
        },
        {
            title: "Integração de dados para <%=Left(scenarioNames, 40)%>",
            desc: "Conectar fontes de dados para validar cenários desenvolvidos:\n\nCenários base: <%=scenarioCount%>\n\n[Explique como integrar e validar]"
        }
    ];
    
    // Escolher uma sugestão aleatória
    var idx = Math.floor(Math.random() * sugestoes.length);
    var sugestao = sugestoes[idx];
    
    titleField.value = sugestao.title.substring(0, 100);
    descField.value = sugestao.desc;
    
    alert('Ideia sugerida gerada! Personalize conforme necessário.');
}

// Validação do formulário
document.getElementById('formIdea').onsubmit = function(e) {
    var title = document.getElementById('title').value.trim();
    var desc = document.getElementById('description').value.trim();
    
    if (title === '' || desc === '') {
        alert('Por favor, preencha todos os campos obrigatórios.');
        e.preventDefault();
        return false;
    }
    
    if (title.length > 100) {
        alert('O título não pode ter mais de 100 caracteres.');
        e.preventDefault();
        return false;
    }
    
    if (desc.length > 8000) {
        alert('A descrição não pode ter mais de 8000 caracteres.');
        e.preventDefault();
        return false;
    }
    
    return true;
};

console.log('Dublin Core Integration loaded');
console.log('Bibliometric refs: <%=biblioCount%>');
console.log('Scenarios: <%=scenarioCount%>');
</script>

<%
render.renderFromBody()
%>