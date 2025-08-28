<!--#include virtual="/system.asp"-->
<!--#include virtual="/checkstep.asp"-->
<!--#include file="INC_BRAINSTORMING.inc"-->
<%
saveCurrentURL
render.renderTitle()

' Obter dados básicos
Dim brainstormingID, stepID
stepID = Request.QueryString("stepID")

' Buscar ou criar brainstorming
call getRecordSet(SQL_CONSULTA_BRAINSTORMING(stepID), rs)

If rs.EOF Then
    call ExecuteSQL(SQL_CRIA_BRAINSTORMING(stepID, "Brainstorming Session", 3))
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

' Verificar se o step está ativo
Dim isActive
isActive = True ' Forçado para testes
%>

<style>
/* Estilo TIAMAT Original */
.brainstorming-container {
    background: #f5f5f5;
    min-height: calc(100vh - 60px);
    padding: 20px;
}

.ideas-columns {
    display: flex;
    gap: 20px;
    margin-bottom: 100px; /* Espaço para barra inferior */
}

.idea-column {
    flex: 1;
    background: white;
    border-radius: 5px;
    box-shadow: 0 2px 4px rgba(0,0,0,0.1);
}

.column-header {
    background: #2c3e50;
    color: white;
    padding: 15px;
    font-weight: bold;
    display: flex;
    justify-content: space-between;
    align-items: center;
}

.column-body {
    padding: 15px;
    min-height: 400px;
    max-height: 600px;
    overflow-y: auto;
}

.idea-item {
    background: #fffbeb;
    padding: 15px;
    margin-bottom: 10px;
    border: 1px solid #e5e5e5;
    border-radius: 3px;
    position: relative;
}

.idea-item:hover {
    background: #fff8dc;
    border-color: #d4d4d4;
}

.idea-title {
    font-weight: bold;
    color: #2c3e50;
    margin-bottom: 5px;
}

.idea-description {
    color: #555;
    font-size: 0.9em;
    margin-bottom: 10px;
}

.idea-meta {
    font-size: 0.85em;
    color: #777;
    border-top: 1px solid #e5e5e5;
    padding-top: 5px;
}

.idea-actions {
    position: absolute;
    top: 10px;
    right: 10px;
}

.vote-btn {
    background: #5cb85c;
    color: white;
    border: none;
    padding: 5px 10px;
    border-radius: 3px;
    cursor: pointer;
    font-size: 0.9em;
}

.vote-btn:hover {
    background: #4cae4c;
}

.vote-btn.remove {
    background: #d9534f;
}

.vote-btn.remove:hover {
    background: #c9302c;
}

.vote-btn:disabled {
    background: #ccc;
    cursor: not-allowed;
}

.votes-info {
    background: white;
    padding: 15px;
    margin-bottom: 20px;
    border-radius: 5px;
    box-shadow: 0 2px 4px rgba(0,0,0,0.1);
    display: flex;
    justify-content: space-around;
    align-items: center;
}

.vote-stat {
    text-align: center;
}

.vote-stat .number {
    font-size: 2em;
    font-weight: bold;
    color: #2c3e50;
}

.vote-stat .label {
    color: #777;
    font-size: 0.9em;
}

.no-ideas {
    text-align: center;
    color: #999;
    padding: 50px;
    font-style: italic;
}

/* Barra inferior fixa */
.bottom-toolbar {
    position: fixed;
    bottom: 0;
    left: 0;
    right: 0;
    background: #f8f9fa;
    border-top: 1px solid #ddd;
    padding: 15px;
    display: flex;
    justify-content: center;
    gap: 10px;
    z-index: 1000;
}

.toolbar-btn {
    padding: 8px 20px;
    border: 1px solid #ddd;
    background: #f8f9fa;
    color: #333;
    border-radius: 3px;
    cursor: pointer;
    display: inline-flex;
    align-items: center;
    gap: 5px;
}

.toolbar-btn:hover {
    background: #e9ecef;
}

.move-buttons {
    margin-top: 10px;
    display: flex;
    gap: 5px;
}

.move-btn {
    font-size: 0.8em;
    padding: 3px 8px;
    background: #6c757d;
    color: white;
    border: none;
    border-radius: 3px;
    cursor: pointer;
}

.move-btn:hover {
    background: #5a6268;
}

.delete-btn {
    color: #dc3545;
    cursor: pointer;
    font-size: 0.9em;
    text-decoration: none;
}

.delete-btn:hover {
    text-decoration: underline;
}

.toolbar-btn.primary {
    background: #337ab7;
    color: white;
    border-color: #2e6da4;
}

.toolbar-btn.primary:hover {
    background: #286090;
}

.toolbar-btn.danger {
    background: #d9534f;
    color: white;
    border-color: #d43f3a;
}

.toolbar-btn.danger:hover {
    background: #c9302c;
}

.toolbar-btn.success {
    background: #5cb85c;
    color: white;
    border-color: #4cae4c;
}

.toolbar-btn.success:hover {
    background: #449d44;
}
</style>

<div class="brainstorming-container">
    
    <!-- Informações de votos -->
    <div class="votes-info">
        <div class="vote-stat">
            <div class="number"><%=votesRemaining%></div>
            <div class="label">Votos disponíveis</div>
        </div>
        <div class="vote-stat">
            <div class="number"><%=votingPoints%></div>
            <div class="label">Total de votos</div>
        </div>
        <div class="vote-stat">
            <div class="number"><%=userVotesUsed%></div>
            <div class="label">Votos usados</div>
        </div>
    </div>

    <!-- Colunas de ideias -->
    <div class="ideas-columns">
        
        <!-- Coluna 1: Novas Ideias (status = 1) -->
        <div class="idea-column">
            <div class="column-header">
                <span>Novas Ideias</span>
                <span>Status</span>
            </div>
            <div class="column-body">
                <%
                call getRecordSet("SELECT i.*, " & _
                                 "(SELECT COUNT(*) FROM T_FTA_METHOD_BRAINSTORMING_VOTING v WHERE v.ideaID = i.ideaID) as totalVotes " & _
                                 "FROM T_FTA_METHOD_BRAINSTORMING_IDEAS i " & _
                                 "WHERE i.brainstormingID = " & brainstormingID & " AND i.status = 1 " & _
                                 "ORDER BY i.dateTime DESC", rs)
                
                If rs.EOF Then
                    Response.Write "<div class='no-ideas'>Não há ideias nesta fase.</div>"
                Else
                    While Not rs.EOF
                        Dim ideaID1, hasVoted1
                        ideaID1 = rs("ideaID")
                        hasVoted1 = false
                        
                        call getRecordSet(SQL_CHECK_USER_VOTE(ideaID1, userEmail), rsVote)
                        If Not rsVote.EOF Then
                            If rsVote("hasVoted") > 0 Then hasVoted1 = true
                        End If
                %>
                    <div class="idea-item">
                        <div class="idea-actions">
                            <% If rs("email") = userEmail Then %>
                                <a href="manageIdea.asp?stepID=<%=stepID%>&brainstormingID=<%=brainstormingID%>&ideaID=<%=ideaID1%>&action=edit" 
                                   style="color: #337ab7; margin-right: 10px;">Editar</a>
                                <a href="javascript:deleteIdea(<%=ideaID1%>)" class="delete-btn">Excluir</a>
                            <% End If %>
                        </div>
                        <div class="idea-title"><%=rs("title")%></div>
                        <div class="idea-description"><%=Left(rs("description"), 200)%>...</div>
                        <div class="idea-meta">
                            Por: <%=rs("email")%> | Votos: <%=rs("totalVotes")%>
                            <% If hasVoted1 Then %>
                                <button class="vote-btn remove" onclick="removeVote(<%=ideaID1%>)" style="float: right;">Remover Voto</button>
                            <% ElseIf votesRemaining > 0 Then %>
                                <button class="vote-btn" onclick="addVote(<%=ideaID1%>)" style="float: right;">Votar</button>
                            <% End If %>
                        </div>
                        <% If rs("email") = userEmail Then %>
                        <div class="move-buttons">
                            <button class="move-btn" onclick="moveIdea(<%=ideaID1%>, 2)">Mover para Discussão</button>
                            <button class="move-btn" onclick="moveIdea(<%=ideaID1%>, 3)">Mover para Votação</button>
                        </div>
                        <% End If %>
                    </div>
                <%
                    rs.MoveNext
                    Wend
                End If
                %>
            </div>
        </div>

        <!-- Coluna 2: Em Discussão (status = 2) -->
        <div class="idea-column">
            <div class="column-header">
                <span>Em Discussão</span>
                <span>Status</span>
            </div>
            <div class="column-body">
                <%
                call getRecordSet("SELECT i.*, " & _
                                 "(SELECT COUNT(*) FROM T_FTA_METHOD_BRAINSTORMING_VOTING v WHERE v.ideaID = i.ideaID) as totalVotes " & _
                                 "FROM T_FTA_METHOD_BRAINSTORMING_IDEAS i " & _
                                 "WHERE i.brainstormingID = " & brainstormingID & " AND i.status = 2 " & _
                                 "ORDER BY i.dateTime DESC", rs)
                
                If rs.EOF Then
                    Response.Write "<div class='no-ideas'>Não há ideias nesta fase.</div>"
                Else
                    While Not rs.EOF
                        Dim ideaID2, hasVoted2
                        ideaID2 = rs("ideaID")
                        hasVoted2 = false
                        
                        call getRecordSet(SQL_CHECK_USER_VOTE(ideaID2, userEmail), rsVote)
                        If Not rsVote.EOF Then
                            If rsVote("hasVoted") > 0 Then hasVoted2 = true
                        End If
                %>
                    <div class="idea-item">
                        <div class="idea-actions">
                            <% If rs("email") = userEmail Then %>
                                <a href="manageIdea.asp?stepID=<%=stepID%>&brainstormingID=<%=brainstormingID%>&ideaID=<%=ideaID2%>&action=edit" 
                                   style="color: #337ab7; margin-right: 10px;">Editar</a>
                                <a href="javascript:deleteIdea(<%=ideaID2%>)" class="delete-btn">Excluir</a>
                            <% End If %>
                        </div>
                        <div class="idea-title"><%=rs("title")%></div>
                        <div class="idea-description"><%=Left(rs("description"), 200)%>...</div>
                        <div class="idea-meta">
                            Por: <%=rs("email")%> | Votos: <%=rs("totalVotes")%>
                            <% If hasVoted2 Then %>
                                <button class="vote-btn remove" onclick="removeVote(<%=ideaID2%>)" style="float: right;">Remover Voto</button>
                            <% ElseIf votesRemaining > 0 Then %>
                                <button class="vote-btn" onclick="addVote(<%=ideaID2%>)" style="float: right;">Votar</button>
                            <% End If %>
                        </div>
                        <% If rs("email") = userEmail Then %>
                        <div class="move-buttons">
                            <button class="move-btn" onclick="moveIdea(<%=ideaID2%>, 1)">Voltar para Novas</button>
                            <button class="move-btn" onclick="moveIdea(<%=ideaID2%>, 3)">Mover para Votação</button>
                        </div>
                        <% End If %>
                    </div>
                <%
                        rs.MoveNext
                    Wend
                End If
                %>
            </div>
        </div>

        <!-- Coluna 3: Votação (status = 3) -->
        <div class="idea-column">
            <div class="column-header">
                <span>Votação</span>
                <span>Status</span>
            </div>
            <div class="column-body">
                <%
                call getRecordSet("SELECT i.*, " & _
                                 "(SELECT COUNT(*) FROM T_FTA_METHOD_BRAINSTORMING_VOTING v WHERE v.ideaID = i.ideaID) as totalVotes " & _
                                 "FROM T_FTA_METHOD_BRAINSTORMING_IDEAS i " & _
                                 "WHERE i.brainstormingID = " & brainstormingID & " AND i.status = 3 " & _
                                 "ORDER BY totalVotes DESC, i.dateTime DESC", rs)
                
                If rs.EOF Then
                    Response.Write "<div class='no-ideas'>Não há ideias nesta fase.</div>"
                Else
                    While Not rs.EOF
                        Dim ideaID3, hasVoted3
                        ideaID3 = rs("ideaID")
                        hasVoted3 = false
                        
                        call getRecordSet(SQL_CHECK_USER_VOTE(ideaID3, userEmail), rsVote)
                        If Not rsVote.EOF Then
                            If rsVote("hasVoted") > 0 Then hasVoted3 = true
                        End If
                %>
                    <div class="idea-item">
                        <div class="idea-actions">
                            <% If rs("email") = userEmail Then %>
                                <a href="manageIdea.asp?stepID=<%=stepID%>&brainstormingID=<%=brainstormingID%>&ideaID=<%=ideaID3%>&action=edit" 
                                   style="color: #337ab7; margin-right: 10px;">Editar</a>
                                <a href="javascript:deleteIdea(<%=ideaID3%>)" class="delete-btn">Excluir</a>
                            <% End If %>
                        </div>
                        <div class="idea-title"><%=rs("title")%></div>
                        <div class="idea-description"><%=Left(rs("description"), 200)%>...</div>
                        <div class="idea-meta">
                            Por: <%=rs("email")%> | Votos: <%=rs("totalVotes")%>
                            <% If hasVoted3 Then %>
                                <button class="vote-btn remove" onclick="removeVote(<%=ideaID3%>)" style="float: right;">Remover Voto</button>
                            <% ElseIf votesRemaining > 0 Then %>
                                <button class="vote-btn" onclick="addVote(<%=ideaID3%>)" style="float: right;">Votar</button>
                            <% End If %>
                        </div>
                        <% If rs("email") = userEmail Then %>
                        <div class="move-buttons">
                            <button class="move-btn" onclick="moveIdea(<%=ideaID3%>, 1)">Voltar para Novas</button>
                            <button class="move-btn" onclick="moveIdea(<%=ideaID3%>, 2)">Voltar para Discussão</button>
                        </div>
                        <% End If %>
                    </div>
                <%
                        rs.MoveNext
                    Wend
                End If
                %>
            </div>
        </div>
    </div>

    <!-- Barra de ferramentas inferior -->
    <div class="bottom-toolbar">
        <button class="toolbar-btn" onclick="location.href='manageBrainstorming.asp?stepID=<%=stepID%>'">
            <i class="bi bi-gear"></i> Configurar
        </button>
        <button class="toolbar-btn success" onclick="location.href='manageIdea.asp?stepID=<%=stepID%>&brainstormingID=<%=brainstormingID%>&action=add'">
            <i class="bi bi-plus"></i> Adicionar Ideia
        </button>
        <button class="toolbar-btn primary" onclick="location.href='?stepID=<%=stepID%>'">
            <i class="bi bi-arrow-clockwise"></i> Atualizar
        </button>
        <button class="toolbar-btn" onclick="verDublinCore()">
            <i class="bi bi-database"></i> Ver Dados DC
        </button>
        <button class="toolbar-btn" onclick="verRanking()">
            <i class="bi bi-trophy"></i> Ranking
        </button>
        <button class="toolbar-btn" onclick="verRelatorio()">
            <i class="bi bi-file-text"></i> Relatório
        </button>
        <button class="toolbar-btn danger" onclick="finalizeBrainstorming()">
            <i class="bi bi-check-circle"></i> Finalizar
        </button>
    </div>
</div>

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

function deleteIdea(ideaID) {
    if (confirm('Tem certeza que deseja excluir esta ideia?\n\nEsta ação não pode ser desfeita.')) {
        window.location.href = 'ideaActions.asp?action=delete&ideaID=' + ideaID + '&stepID=<%=stepID%>';
    }
}

function moveIdea(ideaID, newStatus) {
    var statusName = '';
    if (newStatus == 2) statusName = 'Em Discussão';
    if (newStatus == 3) statusName = 'Votação';
    
    if (confirm('Mover esta ideia para ' + statusName + '?')) {
        window.location.href = 'ideaActions.asp?action=move&ideaID=' + ideaID + '&newStatus=' + newStatus + '&stepID=<%=stepID%>';
    }
}

function finalizeBrainstorming() {
    if (confirm('Tem certeza que deseja finalizar o Brainstorming?\n\nApós finalizar, não será possível adicionar novas ideias ou votar.')) {
        window.location.href = 'finalizeBrainstorming.asp?stepID=<%=stepID%>&action=finalize';
    }
}

function verDublinCore() {
    var popup = window.open('dublinCorePanel.asp?stepID=<%=stepID%>&brainstormingID=<%=brainstormingID%>', 
                           'DublinCore', 
                           'width=900,height=700,scrollbars=yes');
    popup.focus();
}

function verRanking() {
    // Criar popup com ranking
    var popup = window.open('', 'Ranking', 'width=600,height=500');
    popup.document.write('<html><head><title>Ranking de Ideias</title>');
    popup.document.write('<style>body{font-family:Arial;padding:20px;} table{width:100%;border-collapse:collapse;} th,td{border:1px solid #ddd;padding:8px;} th{background:#2c3e50;color:white;}</style>');
    popup.document.write('</head><body>');
    popup.document.write('<h2>Ranking das Ideias Mais Votadas</h2>');
    popup.document.write('<p>Funcionalidade em desenvolvimento...</p>');
    popup.document.write('</body></html>');
}

function verRelatorio() {
    window.location.href = 'finalizeBrainstorming.asp?stepID=<%=stepID%>&action=report';
}
</script>

<%
render.renderFooter()
%>