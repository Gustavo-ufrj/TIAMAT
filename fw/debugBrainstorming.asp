<!--#include virtual="/system.asp"-->

<%
Dim stepID
stepID = Request.QueryString("stepID")
If stepID = "" Then stepID = "70390" ' Step do seu brainstorming
%>

<!DOCTYPE html>
<html>
<head>
    <title>Debug Brainstorming - Dublin Core</title>
    <style>
        body { font-family: Arial; margin: 20px; }
        .section { background: #f8f9fa; padding: 15px; margin: 10px 0; border-radius: 5px; }
        .success { background: #d4edda; color: #155724; }
        .error { background: #f8d7da; color: #721c24; }
        .info { background: #d1ecf1; color: #0c5460; }
        table { width: 100%; border-collapse: collapse; margin: 10px 0; }
        th, td { border: 1px solid #ddd; padding: 8px; text-align: left; }
        th { background: #f2f2f2; }
    </style>
</head>
<body>
    <h1>Debug Brainstorming - Step <%=stepID%></h1>
    
    <!-- 1. VERIFICAR TABELA DUBLIN CORE -->
    <div class="section">
        <h2>1. Verificar Tabela Dublin Core</h2>
        <%
        On Error Resume Next
        
        ' Verificar se a tabela existe
        Call getRecordSet("SELECT TOP 1 * FROM tiamat_dublin_core", rs)
        If Err.Number = 0 Then
            Response.Write "<p class='success'>✓ Tabela 'tiamat_dublin_core' existe</p>"
            
            ' Mostrar estrutura
            Response.Write "<p><strong>Colunas da tabela:</strong></p>"
            Response.Write "<table><tr>"
            For i = 0 to rs.Fields.Count - 1
                Response.Write "<th>" & rs.Fields(i).Name & "</th>"
            Next
            Response.Write "</tr></table>"
        Else
            Response.Write "<p class='error'>✗ Erro ao acessar tabela 'tiamat_dublin_core': " & Err.Description & "</p>"
        End If
        
        Err.Clear
        On Error GoTo 0
        %>
    </div>
    
    <!-- 2. VERIFICAR DADOS DO BRAINSTORMING -->
    <div class="section">
        <h2>2. Dados do Brainstorming - Step <%=stepID%></h2>
        <%
        On Error Resume Next
        
        ' Buscar brainstorming
        Call getRecordSet("SELECT * FROM T_FTA_METHOD_BRAINSTORMING WHERE stepID = " & stepID, rs)
        If Not rs.EOF Then
            Dim brainstormingID
            brainstormingID = rs("brainstormingID")
            Response.Write "<p class='success'>✓ Brainstorming ID: " & brainstormingID & "</p>"
            Response.Write "<p>Descrição: " & rs("description") & "</p>"
            Response.Write "<p>Voting Points: " & rs("votingPoints") & "</p>"
            
            ' Contar ideias
            Call getRecordSet("SELECT COUNT(*) as total FROM T_FTA_METHOD_BRAINSTORMING_IDEAS WHERE brainstormingID = " & brainstormingID, rs)
            If Not rs.EOF Then
                Response.Write "<p>Total de ideias: <strong>" & rs("total") & "</strong></p>"
            End If
        Else
            Response.Write "<p class='error'>✗ Nenhum brainstorming encontrado para step " & stepID & "</p>"
        End If
        
        Err.Clear
        On Error GoTo 0
        %>
    </div>
    
    <!-- 3. VERIFICAR DUBLIN CORE PARA ESTE STEP -->
    <div class="section">
        <h2>3. Dublin Core para Step <%=stepID%></h2>
        <%
        On Error Resume Next
        
        Call getRecordSet("SELECT * FROM tiamat_dublin_core WHERE stepID = " & stepID, rs)
        If Err.Number = 0 Then
            If rs.EOF Then
                Response.Write "<p class='error'>✗ Nenhum registro Dublin Core encontrado para step " & stepID & "</p>"
                Response.Write "<p class='info'>Isso explica por que a mensagem 'não finalizadas no Dublin Core' aparece!</p>"
            Else
                Response.Write "<p class='success'>✓ Encontrados registros Dublin Core:</p>"
                Response.Write "<table>"
                Response.Write "<tr><th>ID</th><th>Title</th><th>Description</th><th>Type</th><th>Date</th></tr>"
                While Not rs.EOF
                    Response.Write "<tr>"
                    Response.Write "<td>" & rs("stepID") & "</td>"
                    Response.Write "<td>" & rs("dc_title") & "</td>"
                    Response.Write "<td>" & Left(rs("dc_description"), 50) & "...</td>"
                    Response.Write "<td>" & rs("dc_type") & "</td>"
                    Response.Write "<td>" & rs("dc_date") & "</td>"
                    Response.Write "</tr>"
                    rs.MoveNext
                Wend
                Response.Write "</table>"
            End If
        Else
            Response.Write "<p class='error'>✗ Erro ao consultar Dublin Core: " & Err.Description & "</p>"
        End If
        
        Err.Clear
        On Error GoTo 0
        %>
    </div>
    
    <!-- 4. VERIFICAR SE O STEP FOI FINALIZADO -->
    <div class="section">
        <h2>4. Status do Step <%=stepID%></h2>
        <%
        On Error Resume Next
        
        Call getRecordSet("SELECT * FROM T_WORKFLOW_STEP WHERE stepID = " & stepID, rs)
        If Not rs.EOF Then
            Response.Write "<p>Step ID: " & rs("stepID") & "</p>"
            Response.Write "<p>Workflow ID: " & rs("workflowID") & "</p>"
            Response.Write "<p>Status: " & rs("status") & "</p>"
            Response.Write "<p>Method ID: " & rs("methodID") & "</p>"
            
            ' Verificar se o step foi "ended"
            If rs("status") = 4 Or rs("status") = "4" Then
                Response.Write "<p class='success'>✓ Step foi finalizado (status = 4)</p>"
            Else
                Response.Write "<p class='error'>✗ Step NÃO foi finalizado (status = " & rs("status") & ")</p>"
            End If
        End If
        
        Err.Clear
        On Error GoTo 0
        %>
    </div>
    
    <!-- 5. TESTE MANUAL DE SALVAMENTO -->
    <div class="section">
        <h2>5. Teste Manual - Salvar no Dublin Core</h2>
        <%
        If Request.QueryString("action") = "test" Then
            On Error Resume Next
            
            ' Tentar salvar manualmente
            Dim testSQL
            testSQL = "INSERT INTO tiamat_dublin_core " & _
                     "(stepID, dc_title, dc_creator, dc_subject, dc_description, " & _
                     "dc_publisher, dc_contributor, dc_date, dc_type, dc_format, " & _
                     "dc_identifier, dc_source, dc_language, dc_relation, dc_coverage, dc_rights) " & _
                     "VALUES (" & stepID & ", " & _
                     "'TESTE Manual', " & _
                     "'System', " & _
                     "'test', " & _
                     "'Teste de inserção manual no Dublin Core', " & _
                     "'TIAMAT', " & _
                     "'System', " & _
                     "GETDATE(), " & _
                     "'brainstorming', " & _
                     "'test', " & _
                     "'TEST_" & stepID & "', " & _
                     "'Teste Step " & stepID & "', " & _
                     "'pt-BR', " & _
                     "'Test', " & _
                     "'Manual', " & _
                     "'Test')"
            
            Call ExecuteSQL(testSQL)
            
            If Err.Number = 0 Then
                Response.Write "<p class='success'>✓ Teste manual FUNCIONOU! Dados salvos no Dublin Core.</p>"
                Response.Write "<p>Agora o problema é no processo de finalização do brainstorming.</p>"
            Else
                Response.Write "<p class='error'>✗ Teste manual FALHOU: " & Err.Description & "</p>"
            End If
            
            Err.Clear
            On Error GoTo 0
        Else
            Response.Write "<p><a href='?stepID=" & stepID & "&action=test'>🧪 Executar Teste Manual</a></p>"
        End If
        %>
    </div>
    
    <!-- 6. CONCLUSÃO -->
    <div class="section info">
        <h2>6. Conclusão e Próximos Passos</h2>
        <p><strong>Diagnóstico:</strong> O brainstorming não está salvando os dados no Dublin Core durante a finalização.</p>
        
        <p><strong>Possíveis soluções:</strong></p>
        <ol>
            <li>Corrigir o arquivo <code>finalizeBrainstorming.asp</code></li>
            <li>Verificar se a tabela Dublin Core tem a estrutura correta</li>
            <li>Adicionar logs de erro no processo de finalização</li>
            <li>Executar manualmente o salvamento para testar</li>
        </ol>
        
        <p><strong>Para testar:</strong></p>
        <ul>
            <li><a href="finalizeBrainstorming.asp?stepID=<%=stepID%>&action=finalize">Tentar Finalizar Novamente</a></li>
            <li><a href="index.asp?stepID=<%=stepID%>">Voltar ao Brainstorming</a></li>
        </ul>
    </div>
    
</body>
</html>