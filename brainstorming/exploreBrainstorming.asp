<!--#include virtual="/system.asp"-->
<%
' exploreBrainstorming.asp - Descobrir estrutura do Brainstorming
' Coloque na pasta /FTA/brainstorming/ e acesse pelo navegador
%>
<!DOCTYPE html>
<html>
<head>
    <title>Explore Brainstorming Structure</title>
    <style>
        body { font-family: Arial; padding: 20px; }
        table { border-collapse: collapse; width: 100%; margin: 20px 0; }
        th, td { border: 1px solid #ddd; padding: 8px; text-align: left; }
        th { background: #f4f4f4; }
        .info { background: #d1ecf1; padding: 10px; margin: 10px 0; }
        .success { background: #d4edda; padding: 10px; margin: 10px 0; }
        pre { background: #f5f5f5; padding: 10px; overflow: auto; }
    </style>
</head>
<body>
    <h1>Estrutura do Brainstorming</h1>
    
    <%
    Dim stepID
    stepID = Request.QueryString("stepID")
    If stepID = "" Then stepID = "50382"
    %>
    
    <div class="info">
        <strong>Analisando step:</strong> <%=stepID%>
    </div>
    
    <h2>1. Tabela T_FTA_METHOD_BRAINSTORMING</h2>
    <%
    On Error Resume Next
    
    ' Verificar estrutura da tabela principal
    call getRecordSet("SELECT TOP 1 * FROM T_FTA_METHOD_BRAINSTORMING", rs)
    
    If Err.Number = 0 Then
        Response.Write "<p class='success'>Tabela existe!</p>"
        Response.Write "<h3>Estrutura:</h3>"
        Response.Write "<table><tr><th>Campo</th><th>Tipo</th></tr>"
        
        Dim i
        For i = 0 to rs.Fields.Count - 1
            Response.Write "<tr>"
            Response.Write "<td><strong>" & rs.Fields(i).Name & "</strong></td>"
            Response.Write "<td>" & rs.Fields(i).Type & "</td>"
            Response.Write "</tr>"
        Next
        Response.Write "</table>"
        
        ' Buscar dados do step
        call getRecordSet("SELECT * FROM T_FTA_METHOD_BRAINSTORMING WHERE brainstormingID IN (SELECT brainstormingID FROM T_FTA_METHOD_BRAINSTORMING_IDEAS WHERE ideaStepID = " & stepID & ")", rs)
        
        If Not rs.EOF Then
            Response.Write "<h3>Dados encontrados:</h3>"
            Response.Write "<pre>"
            While Not rs.EOF
                For i = 0 to rs.Fields.Count - 1
                    Response.Write rs.Fields(i).Name & ": " & rs.Fields(i).Value & vbCrLf
                Next
                Response.Write "---" & vbCrLf
                rs.MoveNext
            Wend
            Response.Write "</pre>"
        Else
            Response.Write "<p>Nenhum dado encontrado para step " & stepID & "</p>"
        End If
    Else
        Response.Write "<p style='color: red;'>Erro: " & Err.Description & "</p>"
    End If
    Err.Clear
    %>
    
    <h2>2. Tabela T_FTA_METHOD_BRAINSTORMING_IDEAS</h2>
    <%
    call getRecordSet("SELECT TOP 1 * FROM T_FTA_METHOD_BRAINSTORMING_IDEAS", rs)
    
    If Err.Number = 0 Then
        Response.Write "<p class='success'>Tabela existe!</p>"
        Response.Write "<h3>Estrutura:</h3>"
        Response.Write "<table><tr><th>Campo</th><th>Tipo</th></tr>"
        
        For i = 0 to rs.Fields.Count - 1
            Response.Write "<tr>"
            Response.Write "<td><strong>" & rs.Fields(i).Name & "</strong></td>"
            Response.Write "<td>" & rs.Fields(i).Type & "</td>"
            Response.Write "</tr>"
        Next
        Response.Write "</table>"
        
        ' Buscar ideias do step
        call getRecordSet("SELECT * FROM T_FTA_METHOD_BRAINSTORMING_IDEAS WHERE ideaStepID = " & stepID, rs)
        
        If Not rs.EOF Then
            Response.Write "<h3>Ideias encontradas:</h3>"
            Response.Write "<table>"
            Response.Write "<tr><th>ID</th><th>Título</th><th>Descrição</th><th>Status</th></tr>"
            While Not rs.EOF
                Response.Write "<tr>"
                Response.Write "<td>" & rs("ideaID") & "</td>"
                Response.Write "<td>" & rs("idea") & "</td>"
                Response.Write "<td>" & Left(rs("description") & "", 50) & "...</td>"
                Response.Write "<td>" & rs("ideaStatus") & "</td>"
                Response.Write "</tr>"
                rs.MoveNext
            Wend
            Response.Write "</table>"
        Else
            Response.Write "<p>Nenhuma ideia encontrada para step " & stepID & "</p>"
        End If
    Else
        Response.Write "<p style='color: red;'>Erro: " & Err.Description & "</p>"
    End If
    Err.Clear
    %>
    
    <h2>3. Tabela T_FTA_METHOD_BRAINSTORMING_VOTING</h2>
    <%
    call getRecordSet("SELECT TOP 1 * FROM T_FTA_METHOD_BRAINSTORMING_VOTING", rs)
    
    If Err.Number = 0 Then
        Response.Write "<p class='success'>Tabela existe!</p>"
        Response.Write "<h3>Estrutura:</h3>"
        Response.Write "<table><tr><th>Campo</th><th>Tipo</th></tr>"
        
        For i = 0 to rs.Fields.Count - 1
            Response.Write "<tr>"
            Response.Write "<td><strong>" & rs.Fields(i).Name & "</strong></td>"
            Response.Write "<td>" & rs.Fields(i).Type & "</td>"
            Response.Write "</tr>"
        Next
        Response.Write "</table>"
    Else
        Response.Write "<p style='color: red;'>Erro: " & Err.Description & "</p>"
    End If
    Err.Clear
    %>
    
    <h2>4. Verificar Arquivos da Pasta</h2>
    <%
    Response.Write "<div class='info'>"
    Response.Write "<p>Arquivos esperados em /FTA/brainstorming/:</p>"
    Response.Write "<ul>"
    Response.Write "<li>index.asp - Página principal</li>"
    Response.Write "<li>configure.asp - Configurar voting points</li>"
    Response.Write "<li>addIdea.asp ou manageIdea.asp - Adicionar ideias</li>"
    Response.Write "<li>voting.asp - Sistema de votação</li>"
    Response.Write "<li>ranking.asp - Ver ranking</li>"
    Response.Write "<li>INC_BRAINSTORMING.inc - Funções SQL</li>"
    Response.Write "</ul>"
    Response.Write "</div>"
    %>
    
    <h2>5. Testar Adicionar uma Ideia</h2>
    <div class="info">
        <form action="addIdea.asp" method="POST">
            <input type="hidden" name="ideaStepID" value="<%=stepID%>">
            <p><strong>Título da Ideia:</strong><br>
            <input type="text" name="idea" style="width: 400px;" value="Teste de Integração Dublin Core"></p>
            
            <p><strong>Descrição:</strong><br>
            <textarea name="description" rows="4" style="width: 400px;">Esta é uma ideia teste para verificar a integração com Dublin Core</textarea></p>
            
            <p><strong>Categoria:</strong><br>
            <input type="text" name="category" style="width: 400px;" value="Tecnologia"></p>
            
            <p><input type="submit" value="Adicionar Ideia (Teste)"></p>
        </form>
    </div>
    
    <h2>6. Campos Importantes para Dublin Core</h2>
    <div class="success">
        <h3>Mapeamento Proposto:</h3>
        <ul>
            <li><strong>idea</strong> (título da ideia) → <strong>dc:title</strong></li>
            <li><strong>description</strong> → <strong>dc:description</strong></li>
            <li><strong>category/tags</strong> → <strong>dc:subject</strong></li>
            <li><strong>email/user</strong> → <strong>dc:creator</strong></li>
            <li><strong>timestamp</strong> → <strong>dc:date</strong></li>
            <li><strong>votes</strong> → <strong>dc:relation</strong> (relevância)</li>
            <li><strong>ideaStatus</strong> → <strong>dc:type</strong></li>
        </ul>
    </div>
    
    <div style="margin-top: 30px; padding: 20px; background: #f0f0f0;">
        <h3>Próximos Passos:</h3>
        <ol>
            <li>Identificar os arquivos exatos (addIdea.asp, etc.)</li>
            <li>Modificar para receber dados Dublin Core do Bibliometrics</li>
            <li>Adicionar botões para usar dados DC</li>
            <li>Salvar os novos dados DC do Brainstorming</li>
        </ol>
        <p>
            <a href="index.asp?stepID=<%=stepID%>">Voltar ao Brainstorming</a> |
            <a href="/workplace.asp">Workplace</a>
        </p>
    </div>
    
</body>
</html>