<!--#include virtual="/system.asp"-->
<%
' testBrainstormingInsert.asp - Inserir ideias de teste no Brainstorming
%>
<!DOCTYPE html>
<html>
<head>
    <title>Test Brainstorming Insert</title>
    <style>
        body { font-family: Arial; padding: 20px; }
        .success { color: green; }
        .error { color: red; }
    </style>
</head>
<body>
    <h1>Inserir Ideias de Teste no Brainstorming</h1>
    
    <%
    Dim stepID, action
    stepID = Request.QueryString("stepID")
    If stepID = "" Then stepID = "50382"
    action = Request.QueryString("action")
    
    Response.Write "<p>Step ID: <strong>" & stepID & "</strong></p>"
    
    If action = "insert" Then
        On Error Resume Next
        
        ' Primeiro, verificar se existe registro na tabela principal
        Dim brainstormingID
        call getRecordSet("SELECT brainstormingID FROM T_FTA_METHOD_BRAINSTORMING WHERE stepID = " & stepID, rs)
        
        If rs.EOF Then
            ' Criar registro principal se não existir
            Response.Write "<p>Criando registro principal...</p>"
            Call ExecuteSQL("INSERT INTO T_FTA_METHOD_BRAINSTORMING (stepID, votingPoints) VALUES (" & stepID & ", 2)")
            
            If Err.Number <> 0 Then
                Response.Write "<p class='error'>Erro ao criar registro principal: " & Err.Description & "</p>"
                Err.Clear
            Else
                Response.Write "<p class='success'>Registro principal criado!</p>"
            End If
            
            ' Buscar o ID criado
            call getRecordSet("SELECT brainstormingID FROM T_FTA_METHOD_BRAINSTORMING WHERE stepID = " & stepID, rs)
        End If
        
        If Not rs.EOF Then
            brainstormingID = rs("brainstormingID")
            Response.Write "<p>Brainstorming ID: " & brainstormingID & "</p>"
            
            ' Inserir algumas ideias de teste
            Dim ideas(4), descriptions(4), i
            
            ideas(0) = "Implementar IA para análise preditiva"
            descriptions(0) = "Utilizar algoritmos de machine learning para prever tendências tecnológicas baseadas nos dados bibliométricos"
            
            ideas(1) = "Criar dashboard interativo"
            descriptions(1) = "Desenvolver interface visual para exploração dos cenários futuros de forma interativa"
            
            ideas(2) = "Integração com bases de patentes"
            descriptions(2) = "Conectar o sistema com bases de dados de patentes para enriquecer a análise tecnológica"
            
            ideas(3) = "Automação da geração de cenários"
            descriptions(3) = "Usar NLP para gerar automaticamente cenários baseados nas referências bibliográficas"
            
            ideas(4) = "Sistema de alertas tecnológicos"
            descriptions(4) = "Criar sistema de notificações para mudanças relevantes nas áreas monitoradas"
            
            For i = 0 to 4
                Dim sql
                sql = "INSERT INTO T_FTA_METHOD_BRAINSTORMING_IDEAS (brainstormingID, ideaStepID, idea, description, ideaStatus, email) VALUES ("
                sql = sql & brainstormingID & ", "
                sql = sql & stepID & ", "
                sql = sql & "'" & Replace(ideas(i), "'", "''") & "', "
                sql = sql & "'" & Replace(descriptions(i), "'", "''") & "', "
                sql = sql & "1, "  ' Status 1 = New Ideas
                sql = sql & "'test@example.com')"
                
                Call ExecuteSQL(sql)
                
                If Err.Number <> 0 Then
                    Response.Write "<p class='error'>Erro ao inserir ideia " & (i+1) & ": " & Err.Description & "</p>"
                    Err.Clear
                Else
                    Response.Write "<p class='success'>✓ Ideia " & (i+1) & " inserida: " & ideas(i) & "</p>"
                End If
            Next
        End If
        
        On Error Goto 0
        
        Response.Write "<hr>"
        Response.Write "<p><a href='index.asp?stepID=" & stepID & "'>Ver ideias no Brainstorming</a></p>"
        
    Else
        %>
        <p>Este script vai inserir 5 ideias de teste no Brainstorming.</p>
        
        <form method="GET">
            <input type="hidden" name="stepID" value="<%=stepID%>">
            <input type="hidden" name="action" value="insert">
            <input type="submit" value="Inserir Ideias de Teste" style="padding: 10px 20px; font-size: 16px;">
        </form>
        <%
    End If
    %>
    
    <h2>Verificar Ideias Existentes</h2>
    <%
    call getRecordSet("SELECT * FROM T_FTA_METHOD_BRAINSTORMING_IDEAS WHERE ideaStepID = " & stepID, rs)
    
    If Not rs.EOF Then
        Response.Write "<table border='1' cellpadding='5'>"
        Response.Write "<tr><th>ID</th><th>Ideia</th><th>Descrição</th><th>Status</th><th>Email</th></tr>"
        
        While Not rs.EOF
            Response.Write "<tr>"
            Response.Write "<td>" & rs("ideaID") & "</td>"
            Response.Write "<td>" & rs("idea") & "</td>"
            Response.Write "<td>" & Left(rs("description") & "", 100) & "...</td>"
            Response.Write "<td>" & rs("ideaStatus") & "</td>"
            Response.Write "<td>" & rs("email") & "</td>"
            Response.Write "</tr>"
            rs.MoveNext
        Wend
        
        Response.Write "</table>"
    Else
        Response.Write "<p>Nenhuma ideia encontrada.</p>"
    End If
    %>
    
</body>
</html>