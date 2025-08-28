<%
' checkBiblioFields.asp - Verificar estrutura da tabela T_FTA_METHOD_BIBLIOMETRICS
' Coloque na pasta /FTA/scenario/ e acesse pelo navegador
%>
<!--#include virtual="/system.asp"-->
<!DOCTYPE html>
<html>
<head>
    <title>Check Bibliometrics Table Structure</title>
    <style>
        body { font-family: Arial; padding: 20px; }
        table { border-collapse: collapse; width: 100%; margin: 20px 0; }
        th, td { border: 1px solid #ddd; padding: 8px; text-align: left; }
        th { background: #f4f4f4; }
        .info { background: #d1ecf1; padding: 10px; margin: 10px 0; }
        .data { background: #d4edda; padding: 10px; margin: 10px 0; }
    </style>
</head>
<body>
    <h1>Verificacao da Estrutura de T_FTA_METHOD_BIBLIOMETRICS</h1>
    
    <%
    Dim stepID
    stepID = Request.QueryString("stepID")
    If stepID = "" Then stepID = "50378"
    %>
    
    <div class="info">
        <strong>Verificando step:</strong> <%=stepID%>
    </div>
    
    <h2>1. Estrutura da Tabela (Colunas)</h2>
    <%
    On Error Resume Next
    
    ' Buscar estrutura da tabela
    call getRecordSet("SELECT TOP 1 * FROM T_FTA_METHOD_BIBLIOMETRICS WHERE stepID = " & stepID, rs)
    
    If Err.Number = 0 Then
        Response.Write "<table>"
        Response.Write "<tr><th>Nome da Coluna</th><th>Tipo</th></tr>"
        
        Dim i
        For i = 0 to rs.Fields.Count - 1
            Response.Write "<tr>"
            Response.Write "<td><strong>" & rs.Fields(i).Name & "</strong></td>"
            Response.Write "<td>" & rs.Fields(i).Type & "</td>"
            Response.Write "</tr>"
        Next
        
        Response.Write "</table>"
    Else
        Response.Write "<div style='color: red;'>Erro: " & Err.Description & "</div>"
    End If
    Err.Clear
    %>
    
    <h2>2. Dados de Exemplo (Primeiros 5 registros)</h2>
    <%
    call getRecordSet("SELECT TOP 5 * FROM T_FTA_METHOD_BIBLIOMETRICS WHERE stepID = " & stepID, rs)
    
    If Not rs.EOF Then
        Response.Write "<table>"
        Response.Write "<tr>"
        
        ' Cabecalhos
        For i = 0 to rs.Fields.Count - 1
            Response.Write "<th>" & rs.Fields(i).Name & "</th>"
        Next
        Response.Write "</tr>"
        
        ' Dados
        While Not rs.EOF
            Response.Write "<tr>"
            For i = 0 to rs.Fields.Count - 1
                Dim value
                value = rs.Fields(i).Value & ""
                If Len(value) > 50 Then
                    value = Left(value, 50) & "..."
                End If
                Response.Write "<td>" & Server.HTMLEncode(value) & "</td>"
            Next
            Response.Write "</tr>"
            rs.MoveNext
        Wend
        
        Response.Write "</table>"
    Else
        Response.Write "<p>Nenhum registro encontrado para o step " & stepID & "</p>"
    End If
    %>
    
    <h2>3. Verificacao dos Campos Importantes</h2>
    <div class="data">
    <%
    ' Verificar campo title
    call getRecordSet("SELECT COUNT(*) as total FROM T_FTA_METHOD_BIBLIOMETRICS WHERE stepID = " & stepID & " AND title IS NOT NULL", rs)
    If Not rs.EOF Then
        Response.Write "<p><strong>TITLE:</strong> " & rs("total") & " registros com titulo</p>"
    End If
    
    ' Verificar campo author (se existir)
    On Error Resume Next
    call getRecordSet("SELECT COUNT(*) as total FROM T_FTA_METHOD_BIBLIOMETRICS WHERE stepID = " & stepID & " AND author IS NOT NULL", rs)
    If Err.Number = 0 And Not rs.EOF Then
        Response.Write "<p><strong>AUTHOR:</strong> " & rs("total") & " registros com author</p>"
    Else
        Response.Write "<p><strong>AUTHOR:</strong> <span style='color: red;'>Campo nao existe</span></p>"
    End If
    Err.Clear
    
    ' Verificar campo email
    call getRecordSet("SELECT COUNT(*) as total FROM T_FTA_METHOD_BIBLIOMETRICS WHERE stepID = " & stepID & " AND email IS NOT NULL", rs)
    If Not rs.EOF Then
        Response.Write "<p><strong>EMAIL:</strong> " & rs("total") & " registros com email</p>"
    End If
    
    ' Verificar campo year
    call getRecordSet("SELECT MIN(year) as min_year, MAX(year) as max_year FROM T_FTA_METHOD_BIBLIOMETRICS WHERE stepID = " & stepID & " AND year IS NOT NULL", rs)
    If Not rs.EOF Then
        Response.Write "<p><strong>YEAR:</strong> Range de " & rs("min_year") & " a " & rs("max_year") & "</p>"
    End If
    %>
    </div>
    
    <h2>4. Amostra de Dados para Dublin Core</h2>
    <div class="data">
    <%
    ' Mostrar alguns titulos
    Response.Write "<h3>dc:title (Titulos):</h3><ul>"
    call getRecordSet("SELECT DISTINCT TOP 3 title FROM T_FTA_METHOD_BIBLIOMETRICS WHERE stepID = " & stepID & " AND title IS NOT NULL", rs)
    While Not rs.EOF
        Response.Write "<li>" & Server.HTMLEncode(rs("title") & "") & "</li>"
        rs.MoveNext
    Wend
    Response.Write "</ul>"
    
    ' Mostrar alguns autores
    Response.Write "<h3>dc:creator (Autores):</h3><ul>"
    On Error Resume Next
    call getRecordSet("SELECT DISTINCT TOP 3 author FROM T_FTA_METHOD_BIBLIOMETRICS WHERE stepID = " & stepID & " AND author IS NOT NULL AND author <> ''", rs)
    If Err.Number = 0 Then
        While Not rs.EOF
            Response.Write "<li>" & Server.HTMLEncode(rs("author") & "") & "</li>"
            rs.MoveNext
        Wend
    End If
    
    If Err.Number <> 0 Or rs.EOF Then
        ' Se nao tem author, usar email
        Err.Clear
        call getRecordSet("SELECT DISTINCT TOP 3 email FROM T_FTA_METHOD_BIBLIOMETRICS WHERE stepID = " & stepID & " AND email IS NOT NULL", rs)
        While Not rs.EOF
            Response.Write "<li>" & Server.HTMLEncode(rs("email") & "") & " (email)</li>"
            rs.MoveNext
        Wend
    End If
    Response.Write "</ul>"
    Err.Clear
    
    ' Mostrar anos
    Response.Write "<h3>dc:date (Anos):</h3>"
    call getRecordSet("SELECT DISTINCT year FROM T_FTA_METHOD_BIBLIOMETRICS WHERE stepID = " & stepID & " AND year IS NOT NULL ORDER BY year", rs)
    Dim years
    years = ""
    While Not rs.EOF
        If years <> "" Then years = years & ", "
        years = years & rs("year")
        rs.MoveNext
    Wend
    Response.Write "<p>" & years & "</p>"
    %>
    </div>
    
    <div style="margin-top: 30px; padding: 20px; background: #f0f0f0;">
        <h3>Conclusao</h3>
        <p>Os campos disponiveis para Dublin Core sao:</p>
        <ul>
            <li><strong>dc:title</strong> = campo title</li>
            <li><strong>dc:creator</strong> = campo author (se existir) ou email como fallback</li>
            <li><strong>dc:date</strong> = campo year</li>
        </ul>
        <p>
            <a href="manageScenario.asp?stepID=50379">Voltar ao Scenario</a> |
            <a href="index.asp?stepID=50379">Ir para Index</a>
        </p>
    </div>
    
</body>
</html>