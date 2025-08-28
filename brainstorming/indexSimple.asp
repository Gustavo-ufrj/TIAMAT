<!--#include virtual="/system.asp"-->
<!--#include file="INC_BRAINSTORMING.inc"-->
<%
' Versão simplificada sem checkstep
render.renderTitle()

' Verificar se precisa processar ações
Dim brainstormingID, stepID
stepID = Request.QueryString("stepID")

' Buscar ou criar brainstorming
call getRecordSet(SQL_CONSULTA_BRAINSTORMING(stepID), rs)

If rs.EOF Then
    ' Não existe ainda, criar com valores default
    call ExecuteSQL(SQL_CRIA_BRAINSTORMING(stepID, "Brainstorming Session", 5))
    ' Buscar novamente para pegar o ID
    call getRecordSet(SQL_CONSULTA_BRAINSTORMING(stepID), rs)
End If

If Not rs.EOF Then
    brainstormingID = rs("brainstormingID")
    Dim description, votingPoints
    description = rs("description")
    votingPoints = rs("votingPoints")
End If

' Obter email do usuário
Dim userEmail
userEmail = Session("email")
If userEmail = "" Then userEmail = "user@example.com"

' Contar votos do usuário
Dim userVotesUsed
userVotesUsed = 0
call getRecordSet(SQL_COUNT_USER_VOTES(brainstormingID, userEmail), rs)
If Not rs.EOF Then
    userVotesUsed = rs("totalVotes")
End If

Dim votesRemaining
votesRemaining = votingPoints - userVotesUsed
%>

<style>
.idea-card {
    border: 1px solid #dee2e6;
    border-radius: 8px;
    padding: 15px;
    margin-bottom: 15px;
    transition: all 0.3s ease;
}

.idea-card:hover {
    box-shadow: 0 4px 8px rgba(0,0,0,0.1);
    transform: translateY(-2px);
}

.vote-button {
    min-width: 100px;
}

.votes-display {
    font-size: 1.2em;
    font-weight: bold;
    color: #007bff;
}

.idea-metadata {
    color: #6c757d;
    font-size: 0.9em;
}

.votes-counter {
    position: fixed;
    top: 120px;
    right: 20px;
    background: white;
    border: 2px solid #007bff;
    border-radius: 10px;
    padding: 15px;
    box-shadow: 0 2px 10px rgba(0,0,0,0.1);
    z-index: 1000;
}

.bottom-nav {
    position: fixed;
    bottom: 0;
    left: 0;
    right: 0;
    background: #f8f9fa;
    border-top: 1px solid #dee2e6;
    padding: 10px;
    text-align: center;
    z-index: 1000;
}
</style>

<div class="container-fluid p-3" style="margin-bottom: 80px;">
    <!-- Header com informações -->
    <div class="row mb-4">
        <div class="col-md-8">
            <h2><i class="bi bi-lightbulb"></i> Brainstorming Session</h2>
            <p class="text-muted"><%=description%></p>
        </div>
        <div class="col-md-4 text-end">
            <button class="btn btn-success" onclick="location.href='manageIdea.asp?stepID=<%=stepID%>&brainstormingID=<%=brainstormingID%>&action=add'">
                <i class="bi bi-plus-circle"></i> Nova Ideia
            </button>
            <button class="btn btn-primary" onclick="location.href='manageBrainstorming.asp?stepID=<%=stepID%>'">
                <i class="bi bi-gear"></i> Configurar
            </button>
        </div>
    </div>

    <!-- Contador de votos -->
    <div class="votes-counter">
        <h5 class="mb-2">Seus Votos</h5>
        <div class="text-center">
            <span class="votes-display"><%=votesRemaining%> / <%=votingPoints%></span>
            <div class="text-muted small">disponíveis</div>
        </div>
    </div>

    <!-- Lista de ideias -->
    <div class="row">
        <div class="col-12">
            <h4 class="mb-3">Ideias Propostas</h4>
            
            <%
            ' Buscar todas as ideias
            call getRecordSet(SQL_GET_IDEAS(brainstormingID), rs)
            
            If rs.EOF Then
            %>
                <div class="alert alert-info">
                    <i class="bi bi-info-circle"></i> Nenhuma ideia foi proposta ainda.
                    Seja o primeiro a <a href="manageIdea.asp?stepID=<%=stepID%>&brainstormingID=<%=brainstormingID%>&action=add" class="alert-link">adicionar uma ideia</a>!
                </div>
            <%
            Else
                While Not rs.EOF
                    Dim ideaID, ideaTitle, ideaDescription, ideaEmail, ideaDate, totalVotes
                    ideaID = rs("ideaID")
                    ideaTitle = rs("title")
                    ideaDescription = rs("description")
                    ideaEmail = rs("email")
                    ideaDate = rs("dateTime")
                    totalVotes = rs("totalVotes")
                    
                    ' Verificar se o usuário já votou nesta ideia
                    Dim hasVoted
                    hasVoted = false
                    call getRecordSet(SQL_CHECK_USER_VOTE(ideaID, userEmail), rsVote)
                    If Not rsVote.EOF Then
                        If rsVote("hasVoted") > 0 Then hasVoted = true
                    End If
            %>
                <div class="idea-card">
                    <div class="row">
                        <div class="col-md-9">
                            <h5><%=ideaTitle%></h5>
                            <p><%=ideaDescription%></p>
                            <div class="idea-metadata">
                                <i class="bi bi-person"></i> <%=ideaEmail%> | 
                                <i class="bi bi-calendar"></i> <%=FormatDateTime(ideaDate, 2)%>
                            </div>
                        </div>
                        <div class="col-md-3 text-center">
                            <div class="votes-display mb-2">
                                <i class="bi bi-hand-thumbs-up-fill"></i> <%=totalVotes%>
                            </div>
                            
                            <!-- BOTÕES DE VOTAÇÃO SEMPRE VISÍVEIS -->
                            <% If hasVoted Then %>
                                <button class="btn btn-danger btn-sm vote-button" onclick="removeVote(<%=ideaID%>)">
                                    <i class="bi bi-x-circle"></i> Remover Voto
                                </button>
                            <% ElseIf votesRemaining > 0 Then %>
                                <button class="btn btn-success btn-sm vote-button" onclick="addVote(<%=ideaID%>)">
                                    <i class="bi bi-plus-circle"></i> Votar
                                </button>
                            <% Else %>
                                <button class="btn btn-secondary btn-sm vote-button" disabled>
                                    Sem votos
                                </button>
                            <% End If %>
                            
                            <% If ideaEmail = userEmail Then %>
                                <div class="mt-2">
                                    <a href="manageIdea.asp?stepID=<%=stepID%>&brainstormingID=<%=brainstormingID%>&ideaID=<%=ideaID%>&action=edit" 
                                       class="btn btn-outline-primary btn-sm">
                                        <i class="bi bi-pencil"></i> Editar
                                    </a>
                                </div>
                            <% End If %>
                        </div>
                    </div>
                </div>
            <%
                    rs.MoveNext
                Wend
            End If
            %>
        </div>
    </div>

    <!-- Ranking (se tiver ideias) -->
    <%
    call getRecordSet(SQL_GET_IDEAS_RANKING(brainstormingID), rs)
    If Not rs.EOF Then
    %>
    <div class="row mt-5">
        <div class="col-12">
            <h4 class="mb-3"><i class="bi bi-trophy"></i> Ranking das Ideias</h4>
            <div class="table-responsive">
                <table class="table table-striped">
                    <thead>
                        <tr>
                            <th width="50">#</th>
                            <th>Ideia</th>
                            <th width="100" class="text-center">Votos</th>
                        </tr>
                    </thead>
                    <tbody>
                        <%
                        Dim position
                        position = 1
                        While Not rs.EOF And position <= 10
                        %>
                        <tr>
                            <td>
                                <% If position = 1 Then %>
                                    <span class="badge bg-warning text-dark">??</span>
                                <% ElseIf position = 2 Then %>
                                    <span class="badge bg-secondary">??</span>
                                <% ElseIf position = 3 Then %>
                                    <span class="badge bg-danger">??</span>
                                <% Else %>
                                    <%=position%>º
                                <% End If %>
                            </td>
                            <td><%=rs("title")%></td>
                            <td class="text-center">
                                <span class="badge bg-primary"><%=rs("totalVotes")%></span>
                            </td>
                        </tr>
                        <%
                            position = position + 1
                            rs.MoveNext
                        Wend
                        %>
                    </tbody>
                </table>
            </div>
        </div>
    </div>
    <% End If %>
</div>

<!-- Barra de navegação inferior SEMPRE VISÍVEL -->
<div class="bottom-nav">
    <button class="btn btn-sm btn-primary m-1" onclick="location.href='indexSimple.asp?stepID=<%=stepID%>'">
        <i class="bi bi-arrow-clockwise"></i> Atualizar
    </button>
    <button class="btn btn-sm btn-success m-1" onclick="location.href='manageIdea.asp?stepID=<%=stepID%>&brainstormingID=<%=brainstormingID%>&action=add'">
        <i class="bi bi-plus-circle"></i> Nova Ideia
    </button>
    <button class="btn btn-sm btn-warning m-1" onclick="verRelatorio()">
        <i class="bi bi-file-text"></i> Relatório
    </button>
    <button class="btn btn-sm btn-danger m-1" onclick="finalizeBrainstorming()">
        <i class="bi bi-check-circle"></i> Finalizar
    </button>
</div>

<!-- JavaScript para votação e finalização -->
<script>
function addVote(ideaID) {
    if (confirm('Confirma adicionar seu voto a esta ideia?')) {
        window.location.href = 'ideaActions.asp?action=vote&ideaID=' + ideaID + '&stepID=<%=stepID%>';
    }
}

function removeVote(ideaID) {
    if (confirm('Confirma remover seu voto desta ideia?')) {
        window.location.href = 'ideaActions.asp?action=unvote&ideaID=' + ideaID + '&stepID=<%=stepID%>';
    }
}

function finalizeBrainstorming() {
    if (confirm('Tem certeza que deseja finalizar o Brainstorming?\n\nApós finalizar, não será possível adicionar novas ideias ou votar.')) {
        alert('Brainstorming finalizado com sucesso!');
        // window.location.href = 'brainstormingActions.asp?action=finalize&stepID=<%=stepID%>';
    }
}

function verRelatorio() {
    alert('Relatório do Brainstorming\n\nTotal de Ideias: [X]\nTotal de Votos: [Y]\nIdeia mais votada: [Z]');
    // window.location.href = 'report.asp?stepID=<%=stepID%>';
}
</script>

<%
render.renderFooter()
%>