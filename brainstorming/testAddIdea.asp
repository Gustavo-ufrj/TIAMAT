<!--#include virtual="/system.asp"-->
<!--#include file="INC_BRAINSTORMING.inc"-->
<%
' Teste para adicionar uma ideia de exemplo
Dim stepID, brainstormingID
stepID = 50380
brainstormingID = 20021

' Email do usuário
Dim userEmail
userEmail = Session("email")
If userEmail = "" Then userEmail = "teste@example.com"

Response.Write "<h2>Teste de Adição de Ideia</h2>"

' Verificar se deve adicionar
If Request.QueryString("add") = "1" Then
    ' Adicionar ideia de teste
    Dim sql
    sql = SQL_CREATE_IDEA(brainstormingID, userEmail, "Ideia de Teste - " & Now(), "Esta é uma descrição de teste para verificar se o sistema de ideias está funcionando corretamente. Criada em: " & Now(), 1)
    
    Response.Write "<p>SQL a executar:</p>"
    Response.Write "<pre>" & sql & "</pre>"
    
    On Error Resume Next
    call ExecuteSQL(sql)
    
    If Err.Number = 0 Then
        Response.Write "<p style='color:green'>✅ Ideia adicionada com sucesso!</p>"
    Else
        Response.Write "<p style='color:red'>❌ Erro ao adicionar: " & Err.Description & "</p>"
    End If
    On Error Goto 0
End If

' Listar ideias existentes
Response.Write "<h3>Ideias Existentes:</h3>"
call getRecordSet("SELECT * FROM T_FTA_METHOD_BRAINSTORMING_IDEAS WHERE brainstormingID = " & brainstormingID & " ORDER BY dateTime DESC", rs)

If rs.EOF Then
    Response.Write "<p>Nenhuma ideia encontrada.</p>"
Else
    Response.Write "<table border='1' cellpadding='5'>"
    Response.Write "<tr><th>ID</th><th>Título</th><th>Email</th><th>Data</th></tr>"
    
    While Not rs.EOF
        Response.Write "<tr>"
        Response.Write "<td>" & rs("ideaID") & "</td>"
        Response.Write "<td>" & rs("title") & "</td>"
        Response.Write "<td>" & rs("email") & "</td>"
        Response.Write "<td>" & rs("dateTime") & "</td>"
        Response.Write "</tr>"
        rs.MoveNext
    Wend
    
    Response.Write "</table>"
End If
%>

<hr>
<p>
    <a href="testAddIdea.asp?add=1">Adicionar Ideia de Teste</a> | 
    <a href="index.asp?stepID=50380">Voltar ao Brainstorming</a> |
    <a href="manageIdea.asp?stepID=50380&brainstormingID=20021&action=add">Adicionar Ideia (Formulário)</a>
</p>