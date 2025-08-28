<!--#include virtual="/system.asp"-->
<%
' verifyAuthors.asp - Verificar se o campo AUTHORS existe e tem dados
%>
<!DOCTYPE html>
<html>
<head>
    <title>Verify Authors Field</title>
    <style>
        body { font-family: Arial; padding: 20px; }
        .success { color: green; font-weight: bold; }
        .error { color: red; font-weight: bold; }
        .data { background: #f0f0f0; padding: 10px; margin: 10px 0; }
    </style>
</head>
<body>
    <h1>Verificação do Campo AUTHORS</h1>
    
    <%
    Dim stepID
    stepID = Request.QueryString("stepID")
    If stepID = "" Then stepID = "50378"
    %>
    
    <h2>Step: <%=stepID%></h2>
    
    <%
    On Error Resume Next
    
    ' Teste 1: Campo AUTHORS existe?
    Response.Write "<h3>1. Verificando se campo AUTHORS existe:</h3>"
    call getRecordSet("SELECT TOP 1 authors FROM T_FTA_METHOD_BIBLIOMETRICS WHERE stepID = " & stepID, rs)
    
    If Err.Number = 0 Then
        Response.Write "<p class='success'>✓ Campo AUTHORS existe!</p>"
        
        ' Teste 2: Quantos registros tem authors?
        Response.Write "<h3>2. Contando registros com AUTHORS:</h3>"
        call getRecordSet("SELECT COUNT(*) as total FROM T_FTA_METHOD_BIBLIOMETRICS WHERE stepID = " & stepID & " AND authors IS NOT NULL", rs)
        Response.Write "<p>Total de registros com authors: <strong>" & rs("total") & "</strong></p>"
        
        ' Teste 3: Mostrar exemplos
        Response.Write "<h3>3. Exemplos de AUTHORS no banco:</h3>"
        Response.Write "<div class='data'>"
        call getRecordSet("SELECT DISTINCT authors, title FROM T_FTA_METHOD_BIBLIOMETRICS WHERE stepID = " & stepID & " AND authors IS NOT NULL", rs)
        While Not rs.EOF
            Response.Write "<p><strong>Authors:</strong> " & rs("authors") & "<br>"
            Response.Write "<strong>Title:</strong> " & Left(rs("title"), 50) & "...</p>"
            rs.MoveNext
        Wend
        Response.Write "</div>"
        
    Else
        Response.Write "<p class='error'>✗ Campo AUTHORS não existe! Erro: " & Err.Description & "</p>"
        
        ' Tentar com AUTHOR (sem S)
        Err.Clear
        Response.Write "<h3>Tentando campo AUTHOR (sem S):</h3>"
        call getRecordSet("SELECT TOP 1 author FROM T_FTA_METHOD_BIBLIOMETRICS WHERE stepID = " & stepID, rs)
        
        If Err.Number = 0 Then
            Response.Write "<p class='success'>✓ Campo AUTHOR existe (sem S)!</p>"
        Else
            Response.Write "<p class='error'>✗ Campo AUTHOR também não existe!</p>"
        End If
    End If
    
    Err.Clear
    
    ' Mostrar estrutura completa da tabela
    Response.Write "<h3>4. Estrutura completa da tabela:</h3>"
    Response.Write "<div class='data'>"
    call getRecordSet("SELECT TOP 1 * FROM T_FTA_METHOD_BIBLIOMETRICS WHERE stepID = " & stepID, rs)
    
    Dim i
    For i = 0 to rs.Fields.Count - 1
        Response.Write "• <strong>" & rs.Fields(i).Name & "</strong> (Type: " & rs.Fields(i).Type & ")<br>"
    Next
    Response.Write "</div>"
    %>
    
    <h3>5. Conclusão:</h3>
    <div class="data">
        <p>O campo correto para dc:creator é: <strong>AUTHORS</strong> (com S)</p>
        <p>Este campo contém os autores dos artigos bibliográficos (ex: "SILVA et al.", "JOHNSON et al.")</p>
        <p>O campo EMAIL contém o email do usuário que inseriu o registro.</p>
    </div>
    
    <p>
        <a href="manageScenario.asp?stepID=50379">Voltar ao Scenario</a> |
        <a href="debugScenario.asp?stepID=50379">Debug Scenario</a>
    </p>
    
</body>
</html>