<!--#include virtual="/system.asp"-->

<%
Dim stepID
stepID = Request.QueryString("stepID")
If stepID = "" Then stepID = "70390"

Dim action
action = Request.QueryString("action")
%>

<!DOCTYPE html>
<html>
<head>
    <title>Teste Dublin Core Insert - Step <%=stepID%></title>
    <style>
        body { font-family: Arial; margin: 20px; }
        .section { background: #f8f9fa; padding: 15px; margin: 10px 0; border-radius: 5px; }
        .success { background: #d4edda; color: #155724; }
        .error { background: #f8d7da; color: #721c24; }
        .info { background: #d1ecf1; color: #0c5460; }
        pre { background: #f8f9fa; padding: 10px; border: 1px solid #ddd; overflow-x: auto; }
        table { width: 100%; border-collapse: collapse; margin: 10px 0; }
        th, td { border: 1px solid #ddd; padding: 8px; text-align: left; }
        th { background: #f2f2f2; }
    </style>
</head>
<body>
    <h1>Teste Dublin Core Insert - Step <%=stepID%></h1>
    
    <%If action = "insert" Then%>
    <!-- EXECUTAR TESTE DE INSERÇÃO -->
    <div class="section">
        <h2>Executando Teste de Inserção</h2>
        <%
        On Error Resume Next
        
        ' Buscar uma ideia real do brainstorming
        Call getRecordSet("SELECT TOP 1 i.*, b.brainstormingID " & _
                         "FROM T_FTA_METHOD_BRAINSTORMING_IDEAS i " & _
                         "INNER JOIN T_FTA_METHOD_BRAINSTORMING b ON i.brainstormingID = b.brainstormingID " & _
                         "WHERE b.stepID = " & stepID, rs)
        
        If Not rs.EOF Then
            Dim ideaTitle, ideaDesc, ideaAuthor, ideaID
            ideaTitle = Replace(rs("title"), "'", "''")
            ideaDesc = Replace(rs("description"), "'", "''")
            ideaAuthor = Replace(rs("email"), "'", "''")
            ideaID = rs("ideaID")
            
            Response.Write "<p><strong>Testando com ideia real:</strong></p>"
            Response.Write "<p>Título: " & rs("title") & "</p>"
            Response.Write "<p>Autor: " & rs("email") & "</p>"
            
            ' Tentar inserção simples primeiro
            Dim sqlSimple
            sqlSimple = "INSERT INTO tiamat_dublin_core (stepID, dc_title, dc_creator, dc_description) " & _
                       "VALUES (" & stepID & ", 'TESTE', 'System', 'Teste simples')"
            
            Response.Write "<h3>Teste 1: Inserção Simples</h3>"
            Response.Write "<pre>" & sqlSimple & "</pre>"
            
            Call ExecuteSQL(sqlSimple)
            
            If Err.Number = 0 Then
                Response.Write "<p class='success'>Teste 1 SUCESSO - Inserção simples funcionou!</p>"
            Else
                Response.Write "<p class='error'>Teste 1 ERRO: " & Err.Description & "</p>"
                Response.Write "<p>Erro número: " & Err.Number & "</p>"
            End If
            
            Err.Clear
            
            ' Tentar inserção completa
            Dim sqlCompleta
            sqlCompleta = "INSERT INTO tiamat_dublin_core " & _
                         "(stepID, dc_title, dc_creator, dc_subject, dc_description, " & _
                         "dc_publisher, dc_date, dc_type, dc_format, dc_identifier, " & _
                         "dc_source, dc_language, dc_relation, dc_coverage, dc_rights) " & _
                         "VALUES (" & stepID & ", " & _
                         "'" & ideaTitle & "', " & _
                         "'" & ideaAuthor & "', " & _
                         "'brainstorming_idea', " & _
                         "'" & ideaDesc & "', " & _
                         "'TIAMAT', " & _
                         "GETDATE(), " & _
                         "'brainstorming', " & _
                         "'idea', " & _
                         "'IDEA_" & ideaID & "', " & _
                         "'Brainstorming Step " & stepID & "', " & _
                         "'pt-BR', " & _
                         "'Ranking: 1', " & _
                         "'Workflow', " & _
                         "'Public')"
            
            Response.Write "<h3>Teste 2: Inserção Completa</h3>"
            Response.Write "<pre>" & sqlCompleta & "</pre>"
            
            Call ExecuteSQL(sqlCompleta)
            
            If Err.Number = 0 Then
                Response.Write "<p class='success'>Teste 2 SUCESSO - Inserção completa funcionou!</p>"
            Else
                Response.Write "<p class='error'>Teste 2 ERRO: " & Err.Description & "</p>"
                Response.Write "<p>Erro número: " & Err.Number & "</p>"
            End If
            
        Else
            Response.Write "<p class='error'>Nenhuma ideia encontrada para testar!</p>"
        End If
        
        Err.Clear
        On Error GoTo 0
        %>
    </div>
    
    <!-- VERIFICAR RESULTADOS -->
    <div class="section">
        <h2>Verificar Registros Inseridos</h2>
        <%
        Call getRecordSet("SELECT * FROM tiamat_dublin_core WHERE stepID = " & stepID, rs)
        If Not rs.EOF Then
            Response.Write "<p class='success'>Registros encontrados no Dublin Core:</p>"
            Response.Write "<table>"
            Response.Write "<tr><th>ID</th><th>Title</th><th>Creator</th><th>Description</th><th>Type</th></tr>"
            While Not rs.EOF
                Response.Write "<tr>"
                Response.Write "<td>" & rs("dublinCoreID") & "</td>"
                Response.Write "<td>" & rs("dc_title") & "</td>"
                Response.Write "<td>" & rs("dc_creator") & "</td>"
                Response.Write "<td>" & Left(rs("dc_description"), 50) & "...</td>"
                Response.Write "<td>" & rs("dc_type") & "</td>"
                Response.Write "</tr>"
                rs.MoveNext
            Wend
            Response.Write "</table>"
        Else
            Response.Write "<p class='error'>Nenhum registro encontrado no Dublin Core para step " & stepID & "</p>"
        End If
        %>
    </div>
    
    <%Else%>
    <!-- ANÁLISE PRÉVIA -->
    <div class="section">
        <h2>1. Verificar Estrutura da Tabela</h2>
        <%
        On Error Resume Next
        Call getRecordSet("SELECT TOP 1 * FROM tiamat_dublin_core", rs)
        If Err.Number = 0 Then
            Response.Write "<p class='success'>Tabela acessível. Colunas:</p>"
            Response.Write "<table><tr>"
            For i = 0 to rs.Fields.Count - 1
                Response.Write "<th>" & rs.Fields(i).Name & " (" & rs.Fields(i).Type & ")</th>"
            Next
            Response.Write "</tr></table>"
        Else
            Response.Write "<p class='error'>Erro ao acessar tabela: " & Err.Description & "</p>"
        End If
        Err.Clear
        On Error GoTo 0
        %>
    </div>
    
    <div class="section">
        <h2>2. Verificar Ideias do Brainstorming</h2>
        <%
        Call getRecordSet("SELECT i.*, b.brainstormingID " & _
                         "FROM T_FTA_METHOD_BRAINSTORMING_IDEAS i " & _
                         "INNER JOIN T_FTA_METHOD_BRAINSTORMING b ON i.brainstormingID = b.brainstormingID " & _
                         "WHERE b.stepID = " & stepID, rs)
        
        If Not rs.EOF Then
            Response.Write "<p class='success'>Ideias encontradas:</p>"
            Response.Write "<table>"
            Response.Write "<tr><th>ID</th><th>Título</th><th>Autor</th><th>Caracteres Especiais?</th></tr>"
            While Not rs.EOF
                Dim hasSpecialChars
                hasSpecialChars = ""
                If InStr(rs("title"), "'") > 0 Then hasSpecialChars = hasSpecialChars & " [aspas simples]"
                If InStr(rs("description"), "'") > 0 Then hasSpecialChars = hasSpecialChars & " [aspas na desc]"
                If Len(rs("title")) > 100 Then hasSpecialChars = hasSpecialChars & " [título longo]"
                
                Response.Write "<tr>"
                Response.Write "<td>" & rs("ideaID") & "</td>"
                Response.Write "<td>" & Left(rs("title"), 40) & "...</td>"
                Response.Write "<td>" & rs("email") & "</td>"
                Response.Write "<td>" & hasSpecialChars & "</td>"
                Response.Write "</tr>"
                rs.MoveNext
            Wend
            Response.Write "</table>"
        Else
            Response.Write "<p class='error'>Nenhuma ideia encontrada!</p>"
        End If
        %>
    </div>
    
    <div class="section">
        <h2>3. Executar Teste</h2>
        <p>Clique no botão abaixo para executar um teste controlado de inserção no Dublin Core:</p>
        <p><a href="?stepID=<%=stepID%>&action=insert" style="padding: 10px 20px; background: #007bff; color: white; text-decoration: none; border-radius: 5px;">Executar Teste de Inserção</a></p>
    </div>
    
    <%End If%>
    
    <div class="section info">
        <h2>Links Úteis</h2>
        <ul>
            <li><a href="debugBrainstorming.asp?stepID=<%=stepID%>">Debug Brainstorming</a></li>
            <li><a href="finalizeBrainstorming.asp?stepID=<%=stepID%>&action=finalize">Tentar Finalizar Novamente</a></li>
            <li><a href="../fw/dcData.asp?stepID=70391">Ver Dublin Core Data (Futures Wheel)</a></li>
        </ul>
    </div>
    
</body>
</html>