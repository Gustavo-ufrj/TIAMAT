<!--#include virtual="/system.asp"-->
<%
' checkManageIdea.asp - Entender como o manageIdea.asp funciona
%>
<!DOCTYPE html>
<html>
<head>
    <title>Check ManageIdea Structure</title>
    <style>
        body { font-family: Arial; padding: 20px; }
        .info { background: #d1ecf1; padding: 10px; margin: 10px 0; }
        .success { background: #d4edda; padding: 10px; margin: 10px 0; }
        pre { background: #f5f5f5; padding: 10px; overflow: auto; }
    </style>
</head>
<body>
    <h1>Análise do Sistema de Brainstorming</h1>
    
    <%
    Dim stepID, brainstormingID
    stepID = Request.QueryString("stepID")
    If stepID = "" Then stepID = "50382"
    
    ' Buscar brainstormingID
    call getRecordSet("SELECT brainstormingID FROM T_FTA_METHOD_BRAINSTORMING WHERE stepID = " & stepID, rs)
    If Not rs.EOF Then
        brainstormingID = rs("brainstormingID")
    End If
    %>
    
    <div class="info">
        <strong>Step ID:</strong> <%=stepID%><br>
        <strong>Brainstorming ID:</strong> <%=brainstormingID%>
    </div>
    
    <h2>1. Arquivos Encontrados na Pasta</h2>
    <div class="success">
        <ul>
            <li><strong>index.asp</strong> - Página principal</li>
            <li><strong>manageBrainstorming.asp</strong> - Gerenciar configurações</li>
            <li><strong>manageIdea.asp</strong> - Adicionar/Editar ideias</li>
            <li><strong>showIdea.asp</strong> - Visualizar ideia</li>
            <li><strong>manageComment.asp</strong> - Gerenciar comentários</li>
            <li><strong>ranking.asp</strong> - Ver ranking das ideias</li>
            <li><strong>brainstormingActions.asp</strong> - Ações (salvar, deletar, etc)</li>
            <li><strong>ideaActions.asp</strong> - Ações das ideias</li>
            <li><strong>commentActions.asp</strong> - Ações dos comentários</li>
            <li><strong>INC_BRAINSTORMING.inc</strong> - Funções SQL</li>
        </ul>
    </div>
    
    <h2>2. Fluxo do Brainstorming</h2>
    <div class="info">
        <ol>
            <li><strong>Configuração:</strong> Define voting points (manageBrainstorming.asp)</li>
            <li><strong>Nova Ideia:</strong> Adiciona ideias (manageIdea.asp) - Status = 1</li>
            <li><strong>Discussão:</strong> Ideias em discussão - Status = 2</li>
            <li><strong>Votação:</strong> Ideias para votar - Status = 3</li>
            <li><strong>Ranking:</strong> Ver resultados (ranking.asp)</li>
        </ol>
    </div>
    
    <h2>3. Integração Dublin Core - Onde Implementar</h2>
    <div class="success">
        <h3>Arquivos a Modificar:</h3>
        <ol>
            <li><strong>manageIdea.asp</strong>
                <ul>
                    <li>Adicionar seção Dublin Core quando action="add"</li>
                    <li>Mostrar dados do Bibliometrics/Scenarios anteriores</li>
                    <li>Botões para usar dados DC como inspiração</li>
                </ul>
            </li>
            
            <li><strong>INC_BRAINSTORMING.inc</strong>
                <ul>
                    <li>Adicionar funções GetDublinCoreData()</li>
                    <li>Funções para salvar metadados DC das ideias</li>
                </ul>
            </li>
            
            <li><strong>index.asp</strong>
                <ul>
                    <li>Mostrar indicador quando há dados DC disponíveis</li>
                </ul>
            </li>
        </ol>
    </div>
    
    <h2>4. Mapeamento Dublin Core Proposto</h2>
    <table border="1" cellpadding="5">
        <tr><th>Campo Brainstorming</th><th>Dublin Core</th><th>Descrição</th></tr>
        <tr><td>title</td><td>dc:title</td><td>Título da ideia</td></tr>
        <tr><td>description</td><td>dc:description</td><td>Descrição detalhada</td></tr>
        <tr><td>categoria/tags</td><td>dc:subject</td><td>Categorias/temas</td></tr>
        <tr><td>email</td><td>dc:creator</td><td>Autor da ideia</td></tr>
        <tr><td>dateTime</td><td>dc:date</td><td>Data de criação</td></tr>
        <tr><td>status</td><td>dc:type</td><td>Tipo/Estado da ideia</td></tr>
        <tr><td>votos</td><td>dc:relation</td><td>Relevância/Ranking</td></tr>
    </table>
    
    <h2>5. Teste de Links</h2>
    <div class="info">
        <p>Testar os links principais:</p>
        <ul>
            <li><a href="index.asp?stepID=<%=stepID%>" target="_blank">Index - Página Principal</a></li>
            <li><a href="manageIdea.asp?stepID=<%=stepID%>&brainstormingID=<%=brainstormingID%>&action=add" target="_blank">Adicionar Nova Ideia</a></li>
            <li><a href="manageBrainstorming.asp?stepID=<%=stepID%>" target="_blank">Configurações</a></li>
            <li><a href="ranking.asp?stepID=<%=stepID%>" target="_blank">Ranking</a></li>
        </ul>
    </div>
    
    <h2>6. Próximos Passos</h2>
    <div style="background: #ffffcc; padding: 15px;">
        <h3>Implementação Dublin Core no Brainstorming:</h3>
        <ol>
            <li>✅ Entender estrutura das tabelas</li>
            <li>✅ Identificar arquivos principais</li>
            <li>⏳ Inserir ideias de teste</li>
            <li>📝 Modificar manageIdea.asp para mostrar dados DC</li>
            <li>📝 Criar funções no INC_BRAINSTORMING.inc</li>
            <li>📝 Testar integração completa</li>
        </ol>
    </div>
    
</body>
</html>