<!--#include virtual="/system.asp"-->
<!--#include virtual="/checkstep.asp"-->
<!--#include file="INC_BRAINSTORMING.inc"-->

<%
saveCurrentURL
render.renderTitle()

Dim stepID, brainstormingID
Dim description, votingPoints

stepID = Request.QueryString("stepID")

' Buscar dados do brainstorming
Call getRecordSet(SQL_CONSULTA_BRAINSTORMING(stepID), rs)

If Not rs.EOF Then
    brainstormingID = rs("brainstormingID")
    description = rs("description")
    votingPoints = rs("votingPoints")
Else
    description = "Brainstorming Session"
    votingPoints = 3
End If
%>

<style>
.config-container {
    max-width: 600px;
    margin: 20px auto;
    padding: 20px;
    background: white;
    border-radius: 5px;
    box-shadow: 0 2px 4px rgba(0,0,0,0.1);
}

.form-group {
    margin-bottom: 20px;
}

.form-group label {
    display: block;
    margin-bottom: 5px;
    font-weight: bold;
    color: #333;
}

.form-control {
    width: 100%;
    padding: 10px;
    border: 1px solid #ddd;
    border-radius: 3px;
}

.btn-group {
    display: flex;
    gap: 10px;
    justify-content: flex-end;
}

.btn {
    padding: 10px 20px;
    border: none;
    border-radius: 3px;
    cursor: pointer;
}

.btn-primary {
    background: #337ab7;
    color: white;
}

.btn-secondary {
    background: #6c757d;
    color: white;
}
</style>

<div class="config-container">
    <h2>Configurar Brainstorming</h2>
    
    <form action="brainstormingActions.asp?action=save" method="POST">
        <input type="hidden" name="stepID" value="<%=stepID%>">
        <% If brainstormingID <> "" Then %>
        <input type="hidden" name="brainstormingID" value="<%=brainstormingID%>">
        <% End If %>
        
        <div class="form-group">
            <label for="description">Descrição</label>
            <textarea class="form-control" id="description" name="description" rows="3"><%=description%></textarea>
        </div>
        
        <div class="form-group">
            <label for="votingPoints">Pontos de Votação por Usuário</label>
            <input type="number" class="form-control" id="votingPoints" name="votingPoints" value="<%=votingPoints%>" min="1" max="10">
            <small style="color: #666;">Cada participante terá este número de votos para distribuir entre as ideias.</small>
        </div>
        
        <div class="btn-group">
            <button type="button" class="btn btn-secondary" onclick="window.location.href='index.asp?stepID=<%=stepID%>'">Cancelar</button>
            <button type="submit" class="btn btn-primary">Salvar</button>
        </div>
    </form>
</div>

<%
render.renderFooter()
%>