<!--#include virtual="/system.asp"-->
<!--#include virtual="/checkstep.asp"-->
<!--#include file="INC_BRAINSTORMING.inc"-->

<%
saveCurrentURL
render.renderTitle()

Dim stepID, brainstormingID, ideaID, action
Dim title, description, email

stepID = Request.QueryString("stepID")
brainstormingID = Request.QueryString("brainstormingID")
ideaID = Request.QueryString("ideaID")
action = Request.QueryString("action")

' Obter email do usuário
email = Session("email")
If email = "" Then email = "user@example.com"

' Se for edição, buscar dados da ideia
If action = "edit" And ideaID <> "" Then
    Call getRecordSet("SELECT * FROM T_FTA_METHOD_BRAINSTORMING_IDEAS WHERE ideaID = " & ideaID, rs)
    If Not rs.EOF Then
        title = rs("title")
        description = rs("description")
    End If
End If

' Processar formulário
If Request.Form("submit") <> "" Then
    title = Request.Form("title")
    description = Request.Form("description")
    
    If action = "edit" Then
        ' Atualizar ideia
        Call ExecuteSQL(SQL_ATUALIZA_IDEIA(ideaID, title, description))
    Else
        ' Criar nova ideia
        Call ExecuteSQL(SQL_CRIA_IDEIA(brainstormingID, email, title, description, 1))
    End If
    
    Response.Redirect "index.asp?stepID=" & stepID
End If
%>

<style>
.form-container {
    max-width: 800px;
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
    font-size: 14px;
}

.form-control:focus {
    outline: none;
    border-color: #337ab7;
}

.btn-group {
    display: flex;
    gap: 10px;
    justify-content: flex-end;
    margin-top: 20px;
}

.btn {
    padding: 10px 20px;
    border: none;
    border-radius: 3px;
    cursor: pointer;
    font-size: 14px;
}

.btn-primary {
    background: #337ab7;
    color: white;
}

.btn-primary:hover {
    background: #286090;
}

.btn-secondary {
    background: #6c757d;
    color: white;
}

.btn-secondary:hover {
    background: #5a6268;
}
</style>

<div class="form-container">
    <h2><% If action = "edit" Then %>Editar<% Else %>Adicionar<% End If %> Ideia</h2>
    
    <form method="POST" action="">
        <div class="form-group">
            <label for="title">Título *</label>
            <input type="text" class="form-control" id="title" name="title" value="<%=title%>" required maxlength="100">
        </div>
        
        <div class="form-group">
            <label for="description">Descrição *</label>
            <textarea class="form-control" id="description" name="description" rows="10" required maxlength="8000"><%=description%></textarea>
        </div>
        
        <div class="form-group">
            <label>Email</label>
            <input type="email" class="form-control" value="<%=email%>" disabled>
        </div>
        
        <div class="btn-group">
            <button type="button" class="btn btn-secondary" onclick="window.location.href='index.asp?stepID=<%=stepID%>'">Cancelar</button>
            <button type="submit" name="submit" value="1" class="btn btn-primary">Salvar</button>
        </div>
    </form>
</div>

<%
render.renderFooter()
%>