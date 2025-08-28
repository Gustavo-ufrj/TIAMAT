<!--#include virtual="/system.asp"-->
<!--#include virtual="/checkstep.asp"-->
<!--#include file="INC_BRAINSTORMING.inc"-->
<%
saveCurrentURL
render.renderTitle()

' Verificar status do step
Dim validation
validation = "required"

If Not getStatusStep(Request.QueryString("stepID")) = STATE_ACTIVE Then 
    validation = "disabled"
End If

' Variáveis
Dim description, votingPoints, brainstormingID
description = ""
votingPoints = 5

Dim showCancel
showCancel = true

If Not IsEmpty(Request.QueryString("stepID")) Then
    ' Buscar dados existentes
    call getRecordSet(SQL_CONSULTA_BRAINSTORMING(Request.QueryString("stepID")), rs)
    
    If Not rs.EOF Then
        brainstormingID = rs("brainstormingID")
        description = rs("description")
        votingPoints = rs("votingPoints")
    Else
        showCancel = false
    End If
End If
%>

<style>
.config-container {
    max-width: 800px;
    margin: 0 auto;
    padding: 20px;
}

.info-box {
    background: #f0f8ff;
    border-left: 4px solid #007bff;
    padding: 15px;
    margin-bottom: 20px;
}

.form-section {
    background: white;
    border-radius: 8px;
    padding: 20px;
    box-shadow: 0 2px 4px rgba(0,0,0,0.1);
}
</style>

<div class="config-container">
    <h2><i class="bi bi-gear"></i> Configurar Brainstorming</h2>
    
    <div class="info-box">
        <h5>Sistema de Votação Multi-pontos</h5>
        <p class="mb-0">
            O Brainstorming utiliza um sistema de votação onde cada participante recebe um número fixo de pontos 
            para distribuir entre as ideias propostas. Isso permite identificar as ideias mais promissoras 
            através da sabedoria coletiva do grupo.
        </p>
    </div>

    <form action="brainstormingActions.asp?action=save" method="POST" class="requires-validation" novalidate>
        <div class="form-section">
            <div class="mb-4">
                <label for="description" class="form-label fw-bold">Descrição da Sessão</label>
                <textarea id="description" name="description" class="form-control" rows="3" <%=validation%>><%=description%></textarea>
                <div class="form-text">Descreva o objetivo desta sessão de brainstorming</div>
            </div>

            <div class="mb-4">
                <label for="votingPoints" class="form-label fw-bold">Pontos de Votação por Participante</label>
                <div class="input-group" style="max-width: 200px;">
                    <span class="input-group-text"><i class="bi bi-hand-thumbs-up"></i></span>
                    <input id="votingPoints" type="number" min="1" max="20" name="votingPoints" 
                           class="form-control" value="<%=votingPoints%>" <%=validation%>>
                </div>
                <div class="form-text">
                    Número de votos que cada participante pode distribuir entre as ideias (recomendado: 3-10)
                </div>
                <div class="invalid-feedback">
                    Os pontos de votação devem estar entre 1 e 20.
                </div>
            </div>

            <% If brainstormingID <> "" Then %>
            <div class="alert alert-info">
                <i class="bi bi-info-circle"></i>
                <strong>Estatísticas Atuais:</strong>
                <%
                ' Contar ideias
                call getRecordSet("SELECT COUNT(*) as total FROM T_FTA_METHOD_BRAINSTORMING_IDEAS WHERE brainstormingID = " & brainstormingID, rs)
                Dim totalIdeas
                totalIdeas = 0
                If Not rs.EOF Then totalIdeas = rs("total")
                
                ' Contar votos
                call getRecordSet("SELECT COUNT(*) as total FROM T_FTA_METHOD_BRAINSTORMING_VOTES v " & _
                                 "INNER JOIN T_FTA_METHOD_BRAINSTORMING_IDEAS i ON v.ideaID = i.ideaID " & _
                                 "WHERE i.brainstormingID = " & brainstormingID, rs)
                Dim totalVotes
                totalVotes = 0
                If Not rs.EOF Then totalVotes = rs("total")
                %>
                <%=totalIdeas%> ideias propostas | <%=totalVotes%> votos registrados
            </div>
            <% End If %>

            <input type="hidden" name="brainstormingID" value="<%=brainstormingID%>">
            <input type="hidden" name="stepID" value="<%=Request.QueryString("stepID")%>">
        </div>

        <div class="mt-4 d-flex justify-content-between">
            <% If showCancel Then %>
                <button class="btn btn-secondary" type="button" 
                        onclick="window.location.href='./index.asp?stepID=<%=Request.QueryString("stepID")%>';">
                    <i class="bi bi-arrow-left"></i> Cancelar
                </button>
            <% Else %>
                <div></div>
            <% End If %>
            
            <% If getStatusStep(Request.QueryString("stepID")) = STATE_ACTIVE Then %>
                <button class="btn btn-primary" type="submit">
                    <i class="bi bi-save"></i> Salvar Configurações
                </button>
            <% Else %>
                <button class="btn btn-secondary" type="button" 
                        onclick="window.location.href='./index.asp?stepID=<%=Request.QueryString("stepID")%>';">
                    <i class="bi bi-arrow-left"></i> Voltar
                </button>
            <% End If %>
        </div>
    </form>
</div>

<script>
// Validação do formulário
(function() {
    'use strict';
    
    var forms = document.querySelectorAll('.requires-validation');
    
    Array.prototype.slice.call(forms).forEach(function(form) {
        form.addEventListener('submit', function(event) {
            if (!form.checkValidity()) {
                event.preventDefault();
                event.stopPropagation();
            }
            form.classList.add('was-validated');
        }, false);
    });
})();

// Validação customizada para votingPoints
document.getElementById('votingPoints').addEventListener('input', function() {
    var value = parseInt(this.value);
    if (value < 1 || value > 20 || isNaN(value)) {
        this.setCustomValidity('Os pontos devem estar entre 1 e 20');
    } else {
        this.setCustomValidity('');
    }
});
</script>

<%
render.renderFooter()
%>