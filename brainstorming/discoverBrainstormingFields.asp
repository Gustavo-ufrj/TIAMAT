<!--#include virtual="/system.asp"-->
<%
' discoverBrainstormingFields.asp - Descobrir os nomes corretos dos campos
%>
<!DOCTYPE html>
<html>
<head>
    <title>Discover Brainstorming Fields</title>
    <style>
        body { font-family: Arial; padding: 20px; }
        table { border-collapse: collapse; width: 100%; margin: 20px 0; }
        th, td { border: 1px solid #ddd; padding: 8px; text-align: left; }
        th { background: #f4f4f4; }
        .success { background: #d4edda; padding: 10px; margin: 10px 0; }
        .error { background: #f8d7da; padding: 10px; margin: 10px 0; }
    </style>
</head>
<body>
    <h1>Descobrir Estrutura das Tabelas Brainstorming</h1>
    
    <%
    Dim stepID
    stepID = Request.QueryString("stepID")
    If stepID = "" Then stepID = "50382"
    %>
    
    <div class="success">
        <strong>Step ID:</strong> <%=stepID%>
    </div>
    
    <%
    On Error Resume Next
    %>
    
    <h2>1. Estrutura de T_FTA_METHOD_BRAINSTORMING</h2>
    <%
    ' Usar INFORMATION_SCHEMA para descobrir colunas
    Dim sql
    sql = "SELECT COLUMN_NAME, DATA_TYPE, CHARACTER_MAXIMUM_LENGTH " & _
          "FROM INFORMATION_SCHEMA.COLUMNS " & _
          "WHERE TABLE_NAME = 'T_FTA_METHOD_BRAINSTORMING' " & _
          "ORDER BY ORDINAL_POSITION"
    
    call getRecordSet(sql, rs)
    
    If Err.Number = 0 Then
        Response.Write "<table>"
        Response.Write "<tr><th>Nome da Coluna</th><th>Tipo de Dados</th><th>Tamanho</th></tr>"
        
        While Not rs.EOF
            Response.Write "<tr>"
            Response.Write "<td><strong>" & rs("COLUMN_NAME") & "</strong></td>"
            Response.Write "<td>" & rs("DATA_TYPE") & "</td>"
            Response.Write "<td>" & rs("CHARACTER_MAXIMUM_LENGTH") & "</td>"
            Response.Write "</tr>"
            rs.MoveNext
        Wend
        
        Response.Write "</table>"
    Else
        Response.Write "<div class='error'>Erro: " & Err.Description & "</div>"
    End If
    Err.Clear
    %>
    
    <h2>2. Estrutura de T_FTA_METHOD_BRAINSTORMING_IDEAS</h2>
    <%
    sql = "SELECT COLUMN_NAME, DATA_TYPE, CHARACTER_MAXIMUM_LENGTH " & _
          "FROM INFORMATION_SCHEMA.COLUMNS " & _
          "WHERE TABLE_NAME = 'T_FTA_METHOD_BRAINSTORMING_IDEAS' " & _
          "ORDER BY ORDINAL_POSITION"
    
    call getRecordSet(sql, rs)
    
    If Err.Number = 0 Then
        Response.Write "<table>"
        Response.Write "<tr><th>Nome da Coluna</th><th>Tipo de Dados</th><th>Tamanho</th></tr>"
        
        While Not rs.EOF
            Response.Write "<tr>"
            Response.Write "<td><strong>" & rs("COLUMN_NAME") & "</strong></td>"
            Response.Write "<td>" & rs("DATA_TYPE") & "</td>"
            Response.Write "<td>" & rs("CHARACTER_MAXIMUM_LENGTH") & "</td>"
            Response.Write "</tr>"
            rs.MoveNext
        Wend
        
        Response.Write "</table>"
    Else
        Response.Write "<div class='error'>Erro: " & Err.Description & "</div>"
    End If
    Err.Clear
    %>
    
    <h2>3. Estrutura de T_FTA_METHOD_BRAINSTORMING_VOTING</h2>
    <%
    sql = "SELECT COLUMN_NAME, DATA_TYPE, CHARACTER_MAXIMUM_LENGTH " & _
          "FROM INFORMATION_SCHEMA.COLUMNS " & _
          "WHERE TABLE_NAME = 'T_FTA_METHOD_BRAINSTORMING_VOTING' " & _
          "ORDER BY ORDINAL_POSITION"
    
    call getRecordSet(sql, rs)
    
    If Err.Number = 0 Then
        Response.Write "<table>"
        Response.Write "<tr><th>Nome da Coluna</th><th>Tipo de Dados</th><th>Tamanho</th></tr>"
        
        While Not rs.EOF
            Response.Write "<tr>"
            Response.Write "<td><strong>" & rs("COLUMN_NAME") & "</strong></td>"
            Response.Write "<td>" & rs("DATA_TYPE") & "</td>"
            Response.Write "<td>" & rs("CHARACTER_MAXIMUM_LENGTH") & "</td>"
            Response.Write "</tr>"
            rs.MoveNext
        Wend
        
        Response.Write "</table>"
    Else
        Response.Write "<div class='error'>Erro: " & Err.Description & "</div>"
    End If
    Err.Clear
    %>
    
    <h2>4. Dados Existentes em T_FTA_METHOD_BRAINSTORMING</h2>
    <%
    call getRecordSet("SELECT * FROM T_FTA_METHOD_BRAINSTORMING WHERE stepID = " & stepID, rs)
    
    If Err.Number = 0 Then
        If Not rs.EOF Then
            Response.Write "<table>"
            Response.Write "<tr>"
            
            Dim i
            For i = 0 to rs.Fields.Count - 1
                Response.Write "<th>" & rs.Fields(i).Name & "</th>"
            Next
            Response.Write "</tr>"
            
            While Not rs.EOF
                Response.Write "<tr>"
                For i = 0 to rs.Fields.Count - 1
                    Response.Write "<td>" & rs.Fields(i).Value & "</td>"
                Next
                Response.Write "</tr>"
                rs.MoveNext
            Wend
            
            Response.Write "</table>"
        Else
            Response.Write "<p>Nenhum registro encontrado para stepID = " & stepID & "</p>"
        End If
    Else
        Response.Write "<div class='error'>Erro: " & Err.Description & "</div>"
    End If
    Err.Clear
    %>
    
    <h2>5. Tentar Buscar Ideias (sem especificar campo)</h2>
    <%
    ' Buscar qualquer ideia para ver estrutura
    call getRecordSet("SELECT TOP 5 * FROM T_FTA_METHOD_BRAINSTORMING_IDEAS", rs)
    
    If Err.Number = 0 Then
        If Not rs.EOF Then
            Response.Write "<p class='success'>Ideias encontradas! Estrutura:</p>"
            Response.Write "<table>"
            Response.Write "<tr>"
            
            For i = 0 to rs.Fields.Count - 1
                Response.Write "<th>" & rs.Fields(i).Name & "</th>"
            Next
            Response.Write "</tr>"
            
            While Not rs.EOF
                Response.Write "<tr>"
                For i = 0 to rs.Fields.Count - 1
                    Dim value
                    value = rs.Fields(i).Value & ""
                    If Len(value) > 50 Then value = Left(value, 50) & "..."
                    Response.Write "<td>" & Server.HTMLEncode(value) & "</td>"
                Next
                Response.Write "</tr>"
                rs.MoveNext
            Wend
            
            Response.Write "</table>"
        Else
            Response.Write "<p>Tabela IDEAS vazia</p>"
        End If
    Else
        Response.Write "<div class='error'>Erro ao buscar ideias: " & Err.Description & "</div>"
    End If
    Err.Clear
    %>
    
    <h2>6. Buscar Ideias Relacionadas ao brainstormingID</h2>
    <%
    ' Primeiro buscar o brainstormingID
    Dim brainstormingID
    call getRecordSet("SELECT brainstormingID FROM T_FTA_METHOD_BRAINSTORMING WHERE stepID = " & stepID, rs)
    
    If Not rs.EOF Then
        brainstormingID = rs("brainstormingID")
        Response.Write "<p>BrainstormingID encontrado: <strong>" & brainstormingID & "</strong></p>"
        
        ' Buscar ideias com este brainstormingID
        call getRecordSet("SELECT * FROM T_FTA_METHOD_BRAINSTORMING_IDEAS WHERE brainstormingID = " & brainstormingID, rs)
        
        If Not rs.EOF Then
            Response.Write "<p class='success'>Ideias encontradas para brainstormingID = " & brainstormingID & ":</p>"
            Response.Write "<table>"
            Response.Write "<tr>"
            
            For i = 0 to rs.Fields.Count - 1
                Response.Write "<th>" & rs.Fields(i).Name & "</th>"
            Next
            Response.Write "</tr>"
            
            While Not rs.EOF
                Response.Write "<tr>"
                For i = 0 to rs.Fields.Count - 1
                    value = rs.Fields(i).Value & ""
                    If Len(value) > 50 Then value = Left(value, 50) & "..."
                    Response.Write "<td>" & Server.HTMLEncode(value) & "</td>"
                Next
                Response.Write "</tr>"
                rs.MoveNext
            Wend
            
            Response.Write "</table>"
        Else
            Response.Write "<p>Nenhuma ideia encontrada para brainstormingID = " & brainstormingID & "</p>"
        End If
    Else
        Response.Write "<p>Nenhum brainstormingID encontrado para stepID = " & stepID & "</p>"
    End If
    %>
    
    <div style="margin-top: 30px; padding: 20px; background: #f0f0f0;">
        <h3>Conclusões:</h3>
        <ul>
            <li>O campo correto provavelmente NÃO é 'ideaStepID'</li>
            <li>Verificar se existe um campo 'stepID' na tabela IDEAS</li>
            <li>Ou se as ideias são relacionadas apenas por 'brainstormingID'</li>
        </ul>
        <p>
            <a href="index.asp?stepID=<%=stepID%>">Voltar ao Brainstorming</a>
        </p>
    </div>
    
    <%
    On Error Goto 0
    %>
    
</body>
</html>