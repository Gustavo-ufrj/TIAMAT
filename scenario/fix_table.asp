<!--#include virtual="/system.asp"-->
<%
Response.ContentType = "text/html; charset=utf-8"
%>
<!DOCTYPE html>
<html>
<head>
    <title>Verificar Tabela</title>
    <style>
        body { font-family: Arial, sans-serif; margin: 20px; }
        .success { color: green; font-weight: bold; }
        .error { color: red; font-weight: bold; }
        table { border-collapse: collapse; width: 100%; margin: 10px 0; }
        th, td { border: 1px solid #ddd; padding: 8px; text-align: left; }
        th { background-color: #f2f2f2; }
    </style>
</head>
<body>
    <h1>?? Verificar Estrutura da Tabela</h1>
    
    <%
    On Error Resume Next
    
    Dim rs
    Call getRecordSet("SELECT COLUMN_NAME FROM INFORMATION_SCHEMA.COLUMNS WHERE TABLE_NAME = 'T_FTA_METHOD_SCENARIOS' ORDER BY ORDINAL_POSITION", rs)
    
    If Err.Number = 0 And Not rs.eof Then
        Response.Write "<p class='success'>? Tabela T_FTA_METHOD_SCENARIOS encontrada</p>"
        Response.Write "<h2>Colunas da tabela:</h2>"
        Response.Write "<table>"
        Response.Write "<tr><th>Coluna</th></tr>"
        
        Dim hasCreated, hasDateCreated, hasDescription
        hasCreated = False
        hasDateCreated = False  
        hasDescription = False
        
        While Not rs.eof
            Response.Write "<tr><td>" & rs("COLUMN_NAME") & "</td></tr>"
            
            Dim colName
            colName = LCase(rs("COLUMN_NAME"))
            If colName = "created" Then hasCreated = True
            If colName = "datecreated" Then hasDateCreated = True
            If colName = "description" Then hasDescription = True
            
            rs.movenext
        Wend
        Response.Write "</table>"
        
        ' Teste de consulta
        Response.Write "<h2>Teste de Consulta:</h2>"
        
        Dim testSQL
        If hasDescription Then
            testSQL = "SELECT scenarioID, stepID, name, description, scenario FROM T_FTA_METHOD_SCENARIOS WHERE stepID = 1"
        Else
            testSQL = "SELECT scenarioID, stepID, name, scenario FROM T_FTA_METHOD_SCENARIOS WHERE stepID = 1"
        End If
        
        If hasCreated Then
            testSQL = testSQL & " ORDER BY created DESC"
        ElseIf hasDateCreated Then
            testSQL = testSQL & " ORDER BY dateCreated DESC"
        Else
            testSQL = testSQL & " ORDER BY scenarioID DESC"
        End If
        
        Response.Write "<p><strong>SQL gerado:</strong></p>"
        Response.Write "<div style='background: #f5f5f5; padding: 10px; border: 1px solid #ccc;'>"
        Response.Write "<code>" & testSQL & "</code>"
        Response.Write "</div>"
        
        ' Testar o SQL
        Call getRecordSet(testSQL, rs)
        If Err.Number = 0 Then
            Response.Write "<p class='success'>? SQL funcionou perfeitamente!</p>"
        Else
            Response.Write "<p class='error'>? Erro no SQL: " & Err.Description & "</p>"
            Err.Clear
        End If
        
        ' Mostrar informações para correção
        Response.Write "<h2>Informações para Correção:</h2>"
        Response.Write "<ul>"
        Response.Write "<li>Tem coluna 'created': " & IIf(hasCreated, "SIM", "NÃO") & "</li>"
        Response.Write "<li>Tem coluna 'dateCreated': " & IIf(hasDateCreated, "SIM", "NÃO") & "</li>"
        Response.Write "<li>Tem coluna 'description': " & IIf(hasDescription, "SIM", "NÃO") & "</li>"
        Response.Write "</ul>"
        
    Else
        Response.Write "<p class='error'>? Erro: " & Err.Description & "</p>"
    End If
    
    On Error Goto 0
    %>
    
    <h2>?? INC_SCENARIO.inc Corrigido</h2>
    <p>Com base na estrutura da tabela, use este código:</p>
    
    <div style="background: #f8f9fa; padding: 15px; border: 1px solid #dee2e6; margin: 20px 0;">
        <h3>Arquivo para Download:</h3>
        <a href="download_inc_scenario.asp" style="background: #007bff; color: white; padding: 10px 15px; text-decoration: none; border-radius: 5px;">?? Baixar INC_SCENARIO.inc Corrigido</a>
    </div>
    
    <h2>?? Próximos Passos</h2>
    <ol>
        <li>Clique no link acima para baixar o arquivo corrigido</li>
        <li>Substitua seu <code>/FTA/scenario/INC_SCENARIO.inc</code></li>
        <li>Substitua seu <code>/FTA/scenario/index.asp</code> pela versão corrigida</li>
        <li>Teste: <a href="index.asp?stepID=1">index.asp?stepID=1</a></li>
    </ol>
</body>
</html>