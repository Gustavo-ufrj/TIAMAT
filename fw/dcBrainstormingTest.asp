<!--#include virtual="/system.asp"-->
<%
Response.Buffer = True
Response.Expires = -1

Dim brainstormingStepID
brainstormingStepID = Request.QueryString("brainstormingStepID")
If brainstormingStepID = "" Then brainstormingStepID = "70387"
%>

<!DOCTYPE html>
<html>
<head>
    <title>Teste Brainstorming Data</title>
    <style>
        body { font-family: Arial; padding: 20px; }
        .box { background: #f0f0f0; padding: 15px; margin: 10px 0; }
        .item { background: white; padding: 10px; margin: 5px 0; border-left: 3px solid #007bff; cursor: pointer; }
        .error { color: red; }
        .success { color: green; }
    </style>
</head>
<body>
    <h1>Buscar Dados do Brainstorming</h1>
    <p>Brainstorming StepID: <strong><%=brainstormingStepID%></strong></p>
    
    <%
    On Error Resume Next
    
    ' Passo 1: Buscar brainstormingID
    Response.Write "<div class='box'>"
    Response.Write "<h3>Passo 1: Buscar brainstormingID</h3>"
    
    Dim brainstormingID, rs
    brainstormingID = 0
    
    Call getRecordSet("SELECT brainstormingID FROM T_FTA_METHOD_BRAINSTORMING WHERE stepID = " & brainstormingStepID, rs)
    
    If Err.Number = 0 And Not rs.EOF Then
        brainstormingID = rs("brainstormingID")
        Response.Write "<p class='success'>BrainstormingID encontrado: " & brainstormingID & "</p>"
    Else
        Response.Write "<p class='error'>Erro ou nenhum registro encontrado</p>"
        If Err.Number <> 0 Then
            Response.Write "<p>Erro: " & Err.Description & "</p>"
        End If
    End If
    Response.Write "</div>"
    Err.Clear
    
    ' Passo 2: Buscar ideias
    If brainstormingID > 0 Then
        Response.Write "<div class='box'>"
        Response.Write "<h3>Passo 2: Buscar ideias</h3>"
        
        Call getRecordSet("SELECT title, description FROM T_FTA_METHOD_BRAINSTORMING_IDEAS WHERE brainstormingID = " & brainstormingID, rs)
        
        If Err.Number = 0 And Not rs.EOF Then
            Dim count
            count = 0
            
            While Not rs.EOF
                count = count + 1
                Dim ideaText
                ideaText = ""
                
                If Not IsNull(rs("title")) Then ideaText = rs("title")
                If Not IsNull(rs("description")) Then 
                    If ideaText <> "" Then
                        ideaText = ideaText & " - " & rs("description")
                    Else
                        ideaText = rs("description")
                    End If
                End If
                
                Response.Write "<div class='item' onclick='alert(""" & Replace(ideaText, """", "") & """)'>"
                Response.Write count & ". " & ideaText
                Response.Write "</div>"
                
                rs.MoveNext
            Wend
            
            Response.Write "<p class='success'>Total: " & count & " ideias</p>"
        Else
            Response.Write "<p class='error'>Nenhuma ideia encontrada</p>"
        End If
        Response.Write "</div>"
    End If
    
    On Error Goto 0
    %>
    
    <div class="box" style="background: #d4edda;">
        <h3>Teste com outros IDs:</h3>
        <form method="get" action="">
            <label>Brainstorming StepID: 
                <input type="text" name="brainstormingStepID" value="<%=brainstormingStepID%>">
            </label>
            <button type="submit">Buscar</button>
        </form>
        
        <p>IDs conhecidos:</p>
        <ul>
            <li>60382 - Brainstorming antigo (brainstormingID: 20022)</li>
            <li>70387 - Seu novo Brainstorming</li>
        </ul>
    </div>
</body>
</html>