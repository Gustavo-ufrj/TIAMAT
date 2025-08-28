<!--#include virtual="/system.asp"-->
<%
' insertBrainstormingIdeas.asp - Inserir ideias com campos corretos
%>
<!DOCTYPE html>
<html>
<head>
    <title>Insert Brainstorming Ideas</title>
    <style>
        body { font-family: Arial; padding: 20px; }
        .success { color: green; }
        .error { color: red; }
        table { border-collapse: collapse; width: 100%; margin: 20px 0; }
        th, td { border: 1px solid #ddd; padding: 8px; }
        th { background: #f4f4f4; }
    </style>
</head>
<body>
    <h1>Inserir Ideias no Brainstorming</h1>
    
    <%
    Dim stepID, action
    stepID = Request.QueryString("stepID")
    If stepID = "" Then stepID = "50382"
    action = Request.QueryString("action")
    
    Response.Write "<p>Step ID: <strong>" & stepID & "</strong></p>"
    
    ' Buscar brainstormingID
    Dim brainstormingID
    call getRecordSet("SELECT brainstormingID FROM T_FTA_METHOD_BRAINSTORMING WHERE stepID = " & stepID, rs)
    
    If Not rs.EOF Then
        brainstormingID = rs("brainstormingID")
        Response.Write "<p>Brainstorming ID: <strong>" & brainstormingID & "</strong></p>"
    Else
        Response.Write "<p class='error'>Nenhum brainstorming encontrado para step " & stepID & "</p>"
        Response.End
    End If
    
    If action = "insert" Then
        On Error Resume Next
        
        ' Inserir ideias de teste
        Dim titles(4), descriptions(4), i
        
        titles(0) = "IA para Análise Preditiva"
        descriptions(0) = "Utilizar algoritmos de machine learning para prever tendências tecnológicas baseadas nos dados bibliométricos coletados anteriormente"
        
        titles(1) = "Dashboard Interativo de Cenários"
        descriptions(1) = "Desenvolver interface visual para exploração dos cenários futuros de forma interativa, integrando dados do Bibliometrics e Scenarios"
        
        titles(2) = "Integração com Bases de Patentes"
        descriptions(2) = "Conectar o sistema com bases de dados de patentes internacionais para enriquecer a análise tecnológica com dados de inovação"
        
        titles(3) = "Automação com NLP"
        descriptions(3) = "Usar processamento de linguagem natural para gerar automaticamente cenários baseados nas referências bibliográficas"
        
        titles(4) = "Sistema de Alertas Tecnológicos"
        descriptions(4) = "Criar sistema de notificações em tempo real para mudanças relevantes nas áreas tecnológicas monitoradas"
        
        For i = 0 to 4
            Dim sql
            sql = "INSERT INTO T_FTA_METHOD_BRAINSTORMING_IDEAS " & _
                  "(brainstormingID, email, dateTime, title, description, status) VALUES ("
            sql = sql & brainstormingID & ", "
            sql = sql & "'teste@tiamat.com', "
            sql = sql & "GETDATE(), "
            sql = sql & "'" & Replace(titles(i), "'", "''") & "', "
            sql = sql & "'" & Replace(descriptions(i), "'", "''") & "', "
            sql = sql & "1)"  ' Status 1 = New Ideas
            
            Call ExecuteSQL(sql)
            
            If Err.Number <> 0 Then
                Response.Write "<p class='error'>Erro ao inserir ideia " & (i+1) & ": " & Err.Description & "</p>"
                Response.Write "<p>SQL: " & sql & "</p>"
                Err.Clear
            Else
                Response.Write "<p class='success'>✓ Ideia " & (i+1) & " inserida: " & titles(i) & "</p>"
            End If
        Next
        
        On Error Goto 0
        
        Response.Write "<hr>"
        Response.Write "<p><a href='index.asp?stepID=" & stepID & "'>Ver ideias no Brainstorming</a></p>"
        
    Else
        %>
        <p>Este script vai inserir 5 ideias de teste no Brainstorming.</p>
        
        <form method="GET">
            <input type="hidden" name="stepID" value="<%=stepID%>">
            <input type="hidden" name="action" value="insert">
            <input type="submit" value="Inserir 5 Ideias de Teste" style="padding: 10px 20px; font-size: 16px;">
        </form>
        <%
    End If
    %>
    
    <h2>Ideias Existentes (brainstormingID = <%=brainstormingID%>)</h2>
    <%
    call getRecordSet("SELECT * FROM T_FTA_METHOD_BRAINSTORMING_IDEAS WHERE brainstormingID = " & brainstormingID & " ORDER BY dateTime DESC", rs)
    
    If Not rs.EOF Then
        Response.Write "<table>"
        Response.Write "<tr><th>ID</th><th>Título</th><th>Descrição</th><th>Status</th><th>Email</th><th>Data</th></tr>"
        
        While Not rs.EOF
            Response.Write "<tr>"
            Response.Write "<td>" & rs("ideaID") & "</td>"
            Response.Write "<td><strong>" & rs("title") & "</strong></td>"
            Response.Write "<td>" & Left(rs("description") & "", 100) & IIf(Len(rs("description") & "") > 100, "...", "") & "</td>"
            Response.Write "<td>" & rs("status") & "</td>"
            Response.Write "<td>" & rs("email") & "</td>"
            Response.Write "<td>" & rs("dateTime") & "</td>"
            Response.Write "</tr>"
            rs.MoveNext
        Wend
        
        Response.Write "</table>"
    Else
        Response.Write "<p>Nenhuma ideia encontrada para este brainstorming.</p>"
    End If
    %>
    
    <%
    Function IIf(condition, trueValue, falseValue)
        If condition Then
            IIf = trueValue
        Else
            IIf = falseValue
        End If
    End Function
    %>
    
</body>
</html>