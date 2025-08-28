<!--#include virtual="/system.asp"-->
<%
Response.ContentType = "text/html"
%>
<!DOCTYPE html>
<html>
<head>
    <title>Verificação Simples</title>
    <style>
        body { font-family: Arial; padding: 20px; }
        .box { background: #f5f5f5; padding: 15px; margin: 10px 0; border-radius: 5px; }
        .success { color: green; font-weight: bold; }
        .error { color: red; font-weight: bold; }
        table { width: 100%; border-collapse: collapse; margin: 10px 0; }
        td, th { border: 1px solid #ddd; padding: 8px; }
        th { background: #e0e0e0; }
    </style>
</head>
<body>
    <h1>Verificação Simples do Brainstorming</h1>
    
    <%
    On Error Resume Next
    
    ' 1. Steps do Workflow 30144
    Response.Write "<div class='box'>"
    Response.Write "<h2>1. Steps do Workflow 30144</h2>"
    
    call getRecordSet("SELECT stepID FROM T_WORKFLOW_STEP WHERE workflowID = 30144 ORDER BY stepID", rs)
    
    Response.Write "<p>Steps encontrados:</p>"
    Response.Write "<ul>"
    While Not rs.EOF
        Response.Write "<li>Step " & rs("stepID")
        If rs("stepID") = 50380 Then Response.Write " <strong>? BRAINSTORMING</strong>"
        If rs("stepID") = 50370 Then Response.Write " <strong>? BIBLIOMETRICS TEST</strong>"
        If rs("stepID") = 50375 Then Response.Write " <strong>? SCENARIOS TEST</strong>"
        Response.Write "</li>"
        rs.MoveNext
    Wend
    Response.Write "</ul>"
    Response.Write "</div>"
    
    ' 2. Verificar Bibliometrics
    Response.Write "<div class='box'>"
    Response.Write "<h2>2. Dados Bibliométricos</h2>"
    
    call getRecordSet("SELECT stepID, COUNT(*) as total FROM T_FTA_METHOD_BIBLIOMETRICS GROUP BY stepID", rs)
    
    If rs.EOF Then
        Response.Write "<p>Nenhum dado bibliométrico encontrado</p>"
    Else
        Response.Write "<table><tr><th>StepID</th><th>Total</th></tr>"
        While Not rs.EOF
            Response.Write "<tr><td>" & rs("stepID") & "</td><td>" & rs("total") & "</td></tr>"
            rs.MoveNext
        Wend
        Response.Write "</table>"
    End If
    Response.Write "</div>"
    
    ' 3. Verificar Scenarios
    Response.Write "<div class='box'>"
    Response.Write "<h2>3. Dados de Cenários</h2>"
    
    call getRecordSet("SELECT stepID, COUNT(*) as total FROM T_FTA_METHOD_SCENARIOS GROUP BY stepID", rs)
    
    If rs.EOF Then
        Response.Write "<p>Nenhum cenário encontrado</p>"
    Else
        Response.Write "<table><tr><th>StepID</th><th>Total</th></tr>"
        While Not rs.EOF
            Response.Write "<tr><td>" & rs("stepID") & "</td><td>" & rs("total") & "</td></tr>"
            rs.MoveNext
        Wend
        Response.Write "</table>"
    End If
    Response.Write "</div>"
    
    ' 4. Verificar se o Brainstorming pode ver os dados
    Response.Write "<div class='box'>"
    Response.Write "<h2>4. Dados Disponíveis para o Brainstorming (Step 50380)</h2>"
    
    Dim biblioCount, scenarioCount
    biblioCount = 0
    scenarioCount = 0
    
    ' Buscar bibliometrics em steps < 50380 no mesmo workflow
    call getRecordSet("SELECT COUNT(*) as total FROM T_FTA_METHOD_BIBLIOMETRICS b " & _
                     "INNER JOIN T_WORKFLOW_STEP s ON b.stepID = s.stepID " & _
                     "WHERE s.workflowID = 30144 AND s.stepID < 50380", rs)
    If Not rs.EOF Then biblioCount = rs("total")
    
    ' Buscar scenarios em steps < 50380 no mesmo workflow
    call getRecordSet("SELECT COUNT(*) as total FROM T_FTA_METHOD_SCENARIOS sc " & _
                     "INNER JOIN T_WORKFLOW_STEP s ON sc.stepID = s.stepID " & _
                     "WHERE s.workflowID = 30144 AND s.stepID < 50380", rs)
    If Not rs.EOF Then scenarioCount = rs("total")
    
    If biblioCount > 0 Or scenarioCount > 0 Then
        Response.Write "<p class='success'>? Dados disponíveis para Dublin Core:</p>"
        Response.Write "<ul>"
        If biblioCount > 0 Then Response.Write "<li>?? " & biblioCount & " referências bibliométricas</li>"
        If scenarioCount > 0 Then Response.Write "<li>?? " & scenarioCount & " cenários</li>"
        Response.Write "</ul>"
    Else
        Response.Write "<p class='error'>? Nenhum dado disponível</p>"
        Response.Write "<p>Os steps 50370 e 50375 precisam ter dados para aparecer no Dublin Core</p>"
    End If
    Response.Write "</div>"
    
    On Error Goto 0
    %>
    
    <hr>
    <div style="margin: 20px 0;">
        <a href="addTestData.asp" style="padding: 10px 20px; background: #4CAF50; color: white; text-decoration: none; border-radius: 5px;">
            ?? Adicionar Dados de Teste
        </a>
        <a href="manageIdea.asp?stepID=50380&brainstormingID=20021&action=add" style="padding: 10px 20px; background: #FF9800; color: white; text-decoration: none; border-radius: 5px; margin-left: 10px;">
            ? Criar Nova Ideia
        </a>
        <a href="index.asp?stepID=50380" style="padding: 10px 20px; background: #2196F3; color: white; text-decoration: none; border-radius: 5px; margin-left: 10px;">
            ?? Ver Brainstorming
        </a>
    </div>
</body>
</html>