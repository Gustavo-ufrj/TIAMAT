<!--#include virtual="/system.asp"-->
<%
' investigateAuthors.asp - Descobrir de onde vêm os dados de autores
%>
<!DOCTYPE html>
<html>
<head>
    <title>Investigate Authors Display</title>
    <style>
        body { font-family: Arial; padding: 20px; }
        table { border-collapse: collapse; width: 100%; margin: 20px 0; }
        th, td { border: 1px solid #ddd; padding: 8px; text-align: left; }
        th { background: #f4f4f4; }
        .info { background: #d1ecf1; padding: 10px; margin: 10px 0; }
    </style>
</head>
<body>
    <h1>Investigação: De onde vêm os Autores?</h1>
    
    <%
    Dim stepID
    stepID = Request.QueryString("stepID")
    If stepID = "" Then stepID = "50378"
    %>
    
    <div class="info">
        <strong>Investigando step:</strong> <%=stepID%>
    </div>
    
    <h2>1. Dados na tabela T_FTA_METHOD_BIBLIOMETRICS:</h2>
    <%
    On Error Resume Next
    
    ' Mostrar TODOS os dados da tabela
    call getRecordSet("SELECT * FROM T_FTA_METHOD_BIBLIOMETRICS WHERE stepID = " & stepID, rs)
    
    If Not rs.EOF Then
        Response.Write "<table>"
        Response.Write "<tr>"
        
        ' Cabeçalhos
        Dim i
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
                If Len(value) > 100 Then
                    value = Left(value, 100) & "..."
                End If
                Response.Write "<td>" & Server.HTMLEncode(value) & "</td>"
            Next
            Response.Write "</tr>"
            rs.MoveNext
        Wend
        
        Response.Write "</table>"
    Else
        Response.Write "<p>Nenhum dado encontrado.</p>"
    End If
    
    Err.Clear
    %>
    
    <h2>2. Verificar tabela T_FTA_METHOD_BIBLIOMETRICS_AUTHORS:</h2>
    <%
    ' Verificar se existe uma tabela separada para autores
    call getRecordSet("SELECT * FROM T_FTA_METHOD_BIBLIOMETRICS_AUTHORS WHERE referenceID IN (SELECT referenceID FROM T_FTA_METHOD_BIBLIOMETRICS WHERE stepID = " & stepID & ")", rs)
    
    If Err.Number = 0 Then
        Response.Write "<p style='color: green;'><strong>? Tabela AUTHORS existe!</strong></p>"
        
        Response.Write "<table>"
        Response.Write "<tr>"
        
        ' Cabeçalhos
        For i = 0 to rs.Fields.Count - 1
            Response.Write "<th>" & rs.Fields(i).Name & "</th>"
        Next
        Response.Write "</tr>"
        
        ' Dados
        While Not rs.EOF
            Response.Write "<tr>"
            For i = 0 to rs.Fields.Count - 1
                Response.Write "<td>" & Server.HTMLEncode(rs.Fields(i).Value & "") & "</td>"
            Next
            Response.Write "</tr>"
            rs.MoveNext
        Wend
        
        Response.Write "</table>"
    Else
        Response.Write "<p style='color: red;'>? Erro ao acessar T_FTA_METHOD_BIBLIOMETRICS_AUTHORS: " & Err.Description & "</p>"
    End If
    
    Err.Clear
    %>
    
    <h2>3. Verificar tabela T_FTA_METHOD_BIBLIOMETRICS_DUBLIN_CORE:</h2>
    <%
    ' Verificar se os dados estão na tabela Dublin Core
    call getRecordSet("SELECT * FROM T_FTA_METHOD_BIBLIOMETRICS_DUBLIN_CORE WHERE stepID = " & stepID, rs)
    
    If Err.Number = 0 And Not rs.EOF Then
        Response.Write "<p style='color: green;'><strong>? Dados encontrados em DUBLIN_CORE!</strong></p>"
        
        Response.Write "<table>"
        Response.Write "<tr>"
        
        ' Cabeçalhos
        For i = 0 to rs.Fields.Count - 1
            Response.Write "<th>" & rs.Fields(i).Name & "</th>"
        Next
        Response.Write "</tr>"
        
        ' Dados
        While Not rs.EOF
            Response.Write "<tr>"
            For i = 0 to rs.Fields.Count - 1
                Dim val
                val = rs.Fields(i).Value & ""
                If Len(val) > 50 Then
                    val = Left(val, 50) & "..."
                End If
                Response.Write "<td>" & Server.HTMLEncode(val) & "</td>"
            Next
            Response.Write "</tr>"
            rs.MoveNext
        Wend
        
        Response.Write "</table>"
    Else
        If Err.Number <> 0 Then
            Response.Write "<p style='color: red;'>? Erro: " & Err.Description & "</p>"
        Else
            Response.Write "<p>Nenhum dado encontrado em DUBLIN_CORE para step " & stepID & "</p>"
        End If
    End If
    
    Err.Clear
    %>
    
    <h2>4. Verificar se há uma VIEW ou campo calculado:</h2>
    <%
    ' Tentar algumas queries que poderiam revelar de onde vêm os autores
    
    ' Teste 1: Verificar se title tem os autores incorporados
    Response.Write "<h3>Análise dos títulos:</h3>"
    call getRecordSet("SELECT title FROM T_FTA_METHOD_BIBLIOMETRICS WHERE stepID = " & stepID, rs)
    Response.Write "<ul>"
    While Not rs.EOF
        Response.Write "<li>" & Server.HTMLEncode(rs("title") & "") & "</li>"
        rs.MoveNext
    Wend
    Response.Write "</ul>"
    %>
    
    <h2>5. Conclusão:</h2>
    <div style="background: #ffffcc; padding: 15px; margin: 20px 0;">
        <h3>Possibilidades:</h3>
        <ol>
            <li><strong>Os autores estão na tabela T_FTA_METHOD_BIBLIOMETRICS_AUTHORS</strong> - tabela separada relacionada por referenceID</li>
            <li><strong>Os autores estão na tabela T_FTA_METHOD_BIBLIOMETRICS_DUBLIN_CORE</strong> - no campo dc_creator</li>
            <li><strong>Os autores são inseridos manualmente na interface</strong> - não estão no banco</li>
            <li><strong>Há uma VIEW ou stored procedure</strong> que gera esses dados</li>
        </ol>
        
        <p><strong>RECOMENDAÇÃO:</strong> Se os autores aparecem na interface mas não no banco principal, 
        provavelmente estão em T_FTA_METHOD_BIBLIOMETRICS_AUTHORS ou são inseridos de outra forma.</p>
    </div>
    
    <p>
        <a href="index.asp?stepID=50378">Ver Interface Bibliometrics</a> |
        <a href="manageScenario.asp?stepID=50379">Voltar ao Scenario</a>
    </p>
    
</body>
</html>