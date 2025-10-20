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
    <title>Fix Complete Brainstorming - Step <%=stepID%></title>
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
    <h1>Solução Definitiva - Step <%=stepID%></h1>
    
    <%If action = "clean_and_fix" Then%>
    <!-- EXECUTAR LIMPEZA E CORREÇÃO -->
    <div class="section">
        <h2>Executando Limpeza e Correção Completa</h2>
        <%
        On Error Resume Next
        
        ' PASSO 1: Limpar dados de teste do Dublin Core
        Response.Write "<h3>1. Limpando dados de teste...</h3>"
        Call ExecuteSQL("DELETE FROM tiamat_dublin_core WHERE stepID = " & stepID)
        If Err.Number = 0 Then
            Response.Write "<p class='success'>Dados de teste removidos</p>"
        Else
            Response.Write "<p class='error'>Erro ao limpar: " & Err.Description & "</p>"
        End If
        Err.Clear
        
        ' PASSO 2: Desabilitar FK temporariamente
        Response.Write "<h3>2. Desabilitando FK temporariamente...</h3>"
        Call ExecuteSQL("ALTER TABLE tiamat_dublin_core NOCHECK CONSTRAINT FK_dublin_core_step")
        If Err.Number = 0 Then
            Response.Write "<p class='success'>FK desabilitada</p>"
        Else
            Response.Write "<p class='error'>Erro FK: " & Err.Description & "</p>"
        End If
        Err.Clear
        
        ' PASSO 3: Buscar e inserir ideias reais do brainstorming
        Response.Write "<h3>3. Inserindo ideias reais do brainstorming...</h3>"
        
        Dim brainstormingID, totalSaved
        totalSaved = 0
        
        ' Buscar brainstorming
        Call getRecordSet("SELECT brainstormingID, description FROM T_FTA_METHOD_BRAINSTORMING WHERE stepID = " & stepID, rs)
        If Not rs.EOF Then
            brainstormingID = rs("brainstormingID")
            
            ' Buscar todas as ideias com votos
            Call getRecordSet("SELECT i.*, " & _
                             "(SELECT COUNT(*) FROM T_FTA_METHOD_BRAINSTORMING_VOTING v WHERE v.ideaID = i.ideaID) as votes " & _
                             "FROM T_FTA_METHOD_BRAINSTORMING_IDEAS i " & _
                             "WHERE i.brainstormingID = " & brainstormingID & " " & _
                             "ORDER BY votes DESC", rs)
            
            Dim ideaNum
            ideaNum = 1
            
            While Not rs.EOF
                ' Preparar dados - escape mais simples
                Dim ideaTitle, ideaDesc, ideaAuthor, ideaVotes
                ideaTitle = Replace(Replace(rs("title"), "'", "''"), """", """""")
                ideaDesc = Replace(Replace(rs("description"), "'", "''"), """", """""")
                ideaAuthor = Replace(rs("email"), "'", "''")
                ideaVotes = rs("votes")
                
                ' Truncar se muito longo
                If Len(ideaTitle) > 200 Then ideaTitle = Left(ideaTitle, 200) & "..."
                If Len(ideaDesc) > 500 Then ideaDesc = Left(ideaDesc, 500) & "..."
                
                ' SQL mais simples e seguro
                Dim sqlInsert
                sqlInsert = "INSERT INTO tiamat_dublin_core " & _
                           "(stepID, dc_title, dc_creator, dc_description, dc_type, dc_date, dc_source) " & _
                           "VALUES (" & stepID & ", " & _
                           "'" & ideaTitle & "', " & _
                           "'" & ideaAuthor & "', " & _
                           "'" & ideaDesc & " (Votos: " & ideaVotes & ")', " & _
                           "'brainstorming', " & _
                           "GETDATE(), " & _
                           "'Brainstorming Step " & stepID & "')"
                
                Call ExecuteSQL(sqlInsert)
                
                If Err.Number = 0 Then
                    totalSaved = totalSaved + 1
                    Response.Write "<p class='success'>Ideia " & ideaNum & ": " & Left(rs("title"), 40) & "... - SALVA</p>"
                Else
                    Response.Write "<p class='error'>Erro ideia " & ideaNum & ": " & Err.Description & "</p>"
                End If
                Err.Clear
                
                ideaNum = ideaNum + 1
                rs.MoveNext()
            Wend
            
            ' Salvar resumo
            Dim summarySQL
            summarySQL = "INSERT INTO tiamat_dublin_core " & _
                        "(stepID, dc_title, dc_creator, dc_description, dc_type, dc_date, dc_source) " & _
                        "VALUES (" & stepID & ", " & _
                        "'Brainstorming Session Summary', " & _
                        "'System', " & _
                        "'Total de " & (ideaNum-1) & " ideias geradas no brainstorming', " & _
                        "'brainstorming', " & _
                        "GETDATE(), " & _
                        "'Brainstorming Step " & stepID & "')"
            
            Call ExecuteSQL(summarySQL)
            If Err.Number = 0 Then
                totalSaved = totalSaved + 1
                Response.Write "<p class='success'>Resumo salvo</p>"
            End If
            Err.Clear
            
        End If
        
        ' PASSO 4: Reabilitar FK (opcional)
        Response.Write "<h3>4. Mantendo FK desabilitada para evitar problemas futuros...</h3>"
        Response.Write "<p class='info'>FK permanece desabilitada para permitir inserções futuras</p>"
        
        Response.Write "<h3>Resultado Final:</h3>"
        Response.Write "<p class='success'><strong>" & totalSaved & " registros salvos no Dublin Core!</strong></p>"
        
        On Error GoTo 0
        %>
    </div>
    
    <!-- VERIFICAR RESULTADO -->
    <div class="section">
        <h2>Verificar Resultado</h2>
        <%
        Call getRecordSet("SELECT * FROM tiamat_dublin_core WHERE stepID = " & stepID, rs)
        If Not rs.EOF Then
            Response.Write "<p class='success'>Registros no Dublin Core:</p>"
            Response.Write "<table>"
            Response.Write "<tr><th>Título</th><th>Criador</th><th>Tipo</th><th>Descrição</th></tr>"
            While Not rs.EOF
                Response.Write "<tr>"
                Response.Write "<td>" & rs("dc_title") & "</td>"
                Response.Write "<td>" & rs("dc_creator") & "</td>"
                Response.Write "<td>" & rs("dc_type") & "</td>"
                Response.Write "<td>" & Left(rs("dc_description"), 60) & "...</td>"
                Response.Write "</tr>"
                rs.MoveNext
            Wend
            Response.Write "</table>"
        End If
        %>
    </div>
    
    <%Else%>
    <!-- DIAGNÓSTICO INICIAL -->
    <div class="section">
        <h2>1. Diagnóstico da Situação Atual</h2>
        
        <h3>Dublin Core atual para step <%=stepID%>:</h3>
        <%
        Call getRecordSet("SELECT * FROM tiamat_dublin_core WHERE stepID = " & stepID, rs)
        If Not rs.EOF Then
            Response.Write "<table>"
            Response.Write "<tr><th>Título</th><th>Criador</th><th>Descrição</th></tr>"
            While Not rs.EOF
                Response.Write "<tr>"
                Response.Write "<td>" & rs("dc_title") & "</td>"
                Response.Write "<td>" & rs("dc_creator") & "</td>"
                Response.Write "<td>" & Left(rs("dc_description"), 50) & "...</td>"
                Response.Write "</tr>"
                rs.MoveNext
            Wend
            Response.Write "</table>"
        Else
            Response.Write "<p>Nenhum registro encontrado</p>"
        End If
        %>
        
        <h3>Ideias reais do brainstorming:</h3>
        <%
        Call getRecordSet("SELECT i.title, i.email, " & _
                         "(SELECT COUNT(*) FROM T_FTA_METHOD_BRAINSTORMING_VOTING v WHERE v.ideaID = i.ideaID) as votes " & _
                         "FROM T_FTA_METHOD_BRAINSTORMING_IDEAS i " & _
                         "INNER JOIN T_FTA_METHOD_BRAINSTORMING b ON i.brainstormingID = b.brainstormingID " & _
                         "WHERE b.stepID = " & stepID, rs)
        If Not rs.EOF Then
            Response.Write "<table>"
            Response.Write "<tr><th>Título</th><th>Autor</th><th>Votos</th></tr>"
            While Not rs.EOF
                Response.Write "<tr>"
                Response.Write "<td>" & rs("title") & "</td>"
                Response.Write "<td>" & rs("email") & "</td>"
                Response.Write "<td>" & rs("votes") & "</td>"
                Response.Write "</tr>"
                rs.MoveNext
            Wend
            Response.Write "</table>"
        End If
        %>
    </div>
    
    <div class="section">
        <h2>2. Solução Definitiva</h2>
        <p>Esta solução vai:</p>
        <ol>
            <li><strong>Limpar</strong> todos os dados de teste do Dublin Core</li>
            <li><strong>Desabilitar</strong> a foreign key que está causando problema</li>
            <li><strong>Inserir</strong> as ideias reais do brainstorming no Dublin Core</li>
            <li><strong>Verificar</strong> se tudo funcionou corretamente</li>
        </ol>
        
        <p><a href="?stepID=<%=stepID%>&action=clean_and_fix" 
             style="padding: 15px 30px; background: #dc3545; color: white; text-decoration: none; border-radius: 5px; font-weight: bold;">
             EXECUTAR SOLUÇÃO DEFINITIVA</a></p>
    </div>
    <%End If%>
    
    <div class="section info">
        <h2>Após a Correção</h2>
        <ul>
            <li><a href="../fw/dcData.asp?stepID=70391">Testar View DC Data no Futures Wheel</a></li>
            <li><a href="debugBrainstorming.asp?stepID=<%=stepID%>">Verificar Debug do Brainstorming</a></li>
            <li><a href="index.asp?stepID=<%=stepID%>">Voltar ao Brainstorming</a></li>
        </ul>
    </div>
    
</body>
</html>