<!--#include virtual="/system.asp"-->
<%
Response.Buffer = True
Dim stepID
stepID = Request.QueryString("stepID")
If stepID = "" Then stepID = "60382"

' Primeiro buscar o brainstormingID
Dim brainstormingID
brainstormingID = 0

Call getRecordSet("SELECT brainstormingID FROM T_FTA_METHOD_BRAINSTORMING WHERE stepID = " & stepID, rs)
If Not rs.EOF Then
    brainstormingID = rs("brainstormingID")
End If
%>

<!DOCTYPE html>
<html>
<head>
    <title>Verificar Estrutura Ideas</title>
    <style>
        body { font-family: Arial; padding: 20px; }
        .box { background: #f0f0f0; padding: 15px; margin: 10px 0; border-radius: 5px; }
        .success { background: #d4edda; padding: 10px; }
        table { width: 100%; border-collapse: collapse; }
        td, th { border: 1px solid #ddd; padding: 8px; }
        th { background: #007bff; color: white; }
    </style>
</head>
<body>
    <h1>Estrutura da Tabela IDEAS</h1>
    
    <div class="box">
        <h3>Informacoes:</h3>
        <p>StepID: <strong><%=stepID%></strong></p>
        <p>BrainstormingID: <strong><%=brainstormingID%></strong></p>
    </div>
    
    <%
    On Error Resume Next
    
    ' Verificar estrutura da tabela IDEAS
    Response.Write "<div class='box'>"
    Response.Write "<h3>Estrutura de T_FTA_METHOD_BRAINSTORMING_IDEAS:</h3>"
    
    Dim rs2
    Call getRecordSet("SELECT TOP 1 * FROM T_FTA_METHOD_BRAINSTORMING_IDEAS", rs2)
    
    If Not rs2.EOF Then
        Response.Write "<table>"
        Response.Write "<tr><th>Campo</th><th>Tipo</th><th>Valor Exemplo</th></tr>"
        
        Dim i
        For i = 0 to rs2.Fields.Count - 1
            Response.Write "<tr>"
            Response.Write "<td>" & rs2.Fields(i).Name & "</td>"
            Response.Write "<td>" & rs2.Fields(i).Type & "</td>"
            Response.Write "<td>" & Left(rs2.Fields(i).Value & "", 50) & "</td>"
            Response.Write "</tr>"
        Next
        Response.Write "</table>"
    End If
    Response.Write "</div>"
    
    ' Tentar buscar ideias usando brainstormingID
    Response.Write "<div class='box'>"
    Response.Write "<h3>Buscando ideias com brainstormingID = " & brainstormingID & ":</h3>"
    
    If brainstormingID > 0 Then
        Dim count
        count = 0
        
        Call getRecordSet("SELECT COUNT(*) as total FROM T_FTA_METHOD_BRAINSTORMING_IDEAS WHERE brainstormingID = " & brainstormingID, rs2)
        If Not rs2.EOF Then
            count = rs2("total")
        End If
        
        Response.Write "<p>Total de ideias encontradas: <strong>" & count & "</strong></p>"
        
        If count > 0 Then
            Response.Write "<div class='success'>"
            Response.Write "<h4>Ideias encontradas:</h4>"
            
            Call getRecordSet("SELECT * FROM T_FTA_METHOD_BRAINSTORMING_IDEAS WHERE brainstormingID = " & brainstormingID, rs2)
            
            Response.Write "<ol>"
            While Not rs2.EOF
                Response.Write "<li>"
                
                ' Tentar diferentes nomes de campo
                Dim ideaText
                ideaText = ""
                
                If Not IsNull(rs2("idea")) Then 
                    ideaText = rs2("idea")
                ElseIf Not IsNull(rs2("description")) Then
                    ideaText = rs2("description")
                ElseIf Not IsNull(rs2("text")) Then
                    ideaText = rs2("text")
                ElseIf Not IsNull(rs2("content")) Then
                    ideaText = rs2("content")
                End If
                
                Response.Write ideaText
                
                ' Mostrar outros campos relevantes
                If Not IsNull(rs2("userID")) Then
                    Response.Write " (User: " & rs2("userID") & ")"
                End If
                
                Response.Write "</li>"
                rs2.MoveNext
            Wend
            Response.Write "</ol>"
            Response.Write "</div>"
        End If
    End If
    Response.Write "</div>"
    
    ' Verificar tambem a tabela DISCUSSION
    Response.Write "<div class='box'>"
    Response.Write "<h3>Verificando T_FTA_METHOD_BRAINSTORMING_DISCUSSION:</h3>"
    
    Dim countDisc
    countDisc = 0
    Call getRecordSet("SELECT COUNT(*) as total FROM T_FTA_METHOD_BRAINSTORMING_DISCUSSION WHERE brainstormingID = " & brainstormingID, rs2)
    If Not rs2.EOF Then
        countDisc = rs2("total")
    End If
    
    Response.Write "<p>Total em DISCUSSION: <strong>" & countDisc & "</strong></p>"
    
    If countDisc > 0 Then
        Call getRecordSet("SELECT TOP 5 * FROM T_FTA_METHOD_BRAINSTORMING_DISCUSSION WHERE brainstormingID = " & brainstormingID, rs2)
        Response.Write "<ol>"
        While Not rs2.EOF
            Response.Write "<li>" & Left(rs2("comment") & "", 100) & "</li>"
            rs2.MoveNext
        Wend
        Response.Write "</ol>"
    End If
    Response.Write "</div>"
    
    On Error Goto 0
    %>
    
    <div class="box success">
        <h3>Resumo:</h3>
        <p>BrainstormingID para este step: <strong><%=brainstormingID%></strong></p>
        <p>Use este ID para buscar as ideias nas tabelas relacionadas.</p>
    </div>
</body>
</html>