<!--#include virtual="/system.asp"-->
<%
Response.Buffer = True
Dim brainstormingStepID
brainstormingStepID = Request.QueryString("brainstormingStepID")
If brainstormingStepID = "" Then brainstormingStepID = "70387"
%>

<!DOCTYPE html>
<html>
<head>
    <title>Busca Completa - Brainstorming</title>
    <style>
        body { font-family: Arial; padding: 20px; }
        .box { background: #f0f0f0; padding: 15px; margin: 10px 0; border-radius: 5px; }
        .success { background: #d4edda; }
        .error { background: #f8d7da; }
        table { width: 100%; border-collapse: collapse; }
        td, th { border: 1px solid #ddd; padding: 5px; font-size: 12px; }
        th { background: #007bff; color: white; }
    </style>
</head>
<body>
    <h1>Busca Completa de Dados - Brainstorming</h1>
    <p>StepID sendo pesquisado: <strong><%=brainstormingStepID%></strong></p>
    
    <%
    On Error Resume Next
    Dim rs
    
    ' 1. Buscar em T_FTA_METHOD_BRAINSTORMING
    Response.Write "<div class='box'>"
    Response.Write "<h3>1. T_FTA_METHOD_BRAINSTORMING</h3>"
    
    Call getRecordSet("SELECT * FROM T_FTA_METHOD_BRAINSTORMING WHERE stepID = " & brainstormingStepID, rs)
    
    If Not rs.EOF Then
        Response.Write "<table>"
        Response.Write "<tr>"
        Dim i
        For i = 0 to rs.Fields.Count - 1
            Response.Write "<th>" & rs.Fields(i).Name & "</th>"
        Next
        Response.Write "</tr><tr>"
        For i = 0 to rs.Fields.Count - 1
            Response.Write "<td>" & rs.Fields(i).Value & "</td>"
        Next
        Response.Write "</tr></table>"
    Else
        Response.Write "<p>Nenhum registro encontrado</p>"
    End If
    Response.Write "</div>"
    
    ' 2. Buscar em T_FTA_METHOD_BRAINSTORMING_IDEAS (todas)
    Response.Write "<div class='box'>"
    Response.Write "<h3>2. T_FTA_METHOD_BRAINSTORMING_IDEAS (brainstormingID = 20023)</h3>"
    
    Call getRecordSet("SELECT * FROM T_FTA_METHOD_BRAINSTORMING_IDEAS WHERE brainstormingID = 20023", rs)
    
    If Not rs.EOF Then
        Response.Write "<table>"
        Response.Write "<tr>"
        For i = 0 to rs.Fields.Count - 1
            Response.Write "<th>" & rs.Fields(i).Name & "</th>"
        Next
        Response.Write "</tr>"
        
        While Not rs.EOF
            Response.Write "<tr>"
            For i = 0 to rs.Fields.Count - 1
                Response.Write "<td>" & Left(rs.Fields(i).Value & "", 50) & "</td>"
            Next
            Response.Write "</tr>"
            rs.MoveNext
        Wend
        Response.Write "</table>"
    Else
        Response.Write "<p>Nenhuma ideia encontrada</p>"
    End If
    Response.Write "</div>"
    
    ' 3. Buscar em T_FTA_METHOD_BRAINSTORMING_DISCUSSION
    Response.Write "<div class='box'>"
    Response.Write "<h3>3. T_FTA_METHOD_BRAINSTORMING_DISCUSSION</h3>"
    
    Call getRecordSet("SELECT * FROM T_FTA_METHOD_BRAINSTORMING_DISCUSSION WHERE brainstormingID = 20023", rs)
    
    If Not rs.EOF Then
        Response.Write "<p>Encontrados registros na tabela DISCUSSION:</p>"
        Response.Write "<ol>"
        While Not rs.EOF
            Response.Write "<li>" & Left(rs("comment") & "", 200) & "</li>"
            rs.MoveNext
        Wend
        Response.Write "</ol>"
    Else
        Response.Write "<p>Nenhum registro encontrado</p>"
    End If
    Response.Write "</div>"
    
    ' 4. Buscar em T_FTA_METHOD_BRAINSTORMING_VOTING
    Response.Write "<div class='box'>"
    Response.Write "<h3>4. T_FTA_METHOD_BRAINSTORMING_VOTING</h3>"
    
    Call getRecordSet("SELECT * FROM T_FTA_METHOD_BRAINSTORMING_VOTING WHERE brainstormingID = 20023", rs)
    
    If Not rs.EOF Then
        Response.Write "<p>Encontrados votos:</p>"
        While Not rs.EOF
            Response.Write "IdeaID: " & rs("ideaID") & " - Votes: " & rs("votes") & "<br>"
            rs.MoveNext
        Wend
    Else
        Response.Write "<p>Nenhum voto encontrado</p>"
    End If
    Response.Write "</div>"
    
    ' 5. Buscar QUALQUER registro com stepID 70387
    Response.Write "<div class='box'>"
    Response.Write "<h3>5. Busca geral por stepID " & brainstormingStepID & "</h3>"
    
    ' Verificar se existe alguma ideia em qualquer lugar
    Call getRecordSet("SELECT TOP 10 * FROM T_FTA_METHOD_BRAINSTORMING_IDEAS ORDER BY ideaID DESC", rs)
    
    Response.Write "<p>Ultimas 10 ideias cadastradas (de qualquer brainstorming):</p>"
    Response.Write "<table>"
    Response.Write "<tr><th>IdeaID</th><th>BrainstormingID</th><th>Title</th><th>Description</th></tr>"
    
    While Not rs.EOF
        Response.Write "<tr>"
        Response.Write "<td>" & rs("ideaID") & "</td>"
        Response.Write "<td>" & rs("brainstormingID") & "</td>"
        Response.Write "<td>" & Left(rs("title") & "", 30) & "</td>"
        Response.Write "<td>" & Left(rs("description") & "", 50) & "</td>"
        Response.Write "</tr>"
        rs.MoveNext
    Wend
    Response.Write "</table>"
    Response.Write "</div>"
    
    On Error Goto 0
    %>
    
    <div class="box success">
        <h3>Resumo:</h3>
        <p>Se as ideias nao aparecem aqui, pode ser que:</p>
        <ol>
            <li>Estao sendo salvas em outra tabela</li>
            <li>Estao sendo salvas com outro brainstormingID</li>
            <li>O sistema nao esta salvando no banco de dados</li>
            <li>Ha um erro no processo de salvamento</li>
        </ol>
    </div>
</body>
</html>