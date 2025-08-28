<!--#include virtual="/system.asp"-->
<%
Response.ContentType = "text/html"

Dim stepID, workflowID
stepID = 50380 ' Brainstorming
%>
<!DOCTYPE html>
<html>
<head>
    <title>Verificar Dados Anteriores</title>
    <style>
        body { font-family: Arial; padding: 20px; }
        .found { color: green; font-weight: bold; }
        .not-found { color: red; }
        table { border-collapse: collapse; width: 100%; margin: 10px 0; }
        td, th { border: 1px solid #ddd; padding: 8px; }
        th { background: #f2f2f2; }
    </style>
</head>
<body>
    <h1>Verificar Dados Anteriores para Brainstorming (Step <%=stepID%>)</h1>
    
    <%
    ' 1. Buscar workflow
    Response.Write "<h2>1. Workflow</h2>"
    On Error Resume Next
    call getRecordSet("SELECT * FROM T_WORKFLOW_STEP WHERE stepID = " & stepID, rs)
    If Err.Number <> 0 Then
        Response.Write "<p class='not-found'>Erro ao buscar: " & Err.Description & "</p>"
        Err.Clear
    ElseIf Not rs.EOF Then
        workflowID = rs("workflowID")
        Dim stepName
        stepName = ""
        If Not IsNull(rs.Fields("name")) Then stepName = rs("name")
        Response.Write "<p class='found'>✓ Workflow: " & workflowID & " - " & stepName & "</p>"
    Else
        Response.Write "<p class='not-found'>✗ Workflow não encontrado</p>"
        Response.End
    End If
    On Error Goto 0
    
    ' 2. Listar todos os steps do workflow
    Response.Write "<h2>2. Todos os Steps do Workflow " & workflowID & "</h2>"
    Response.Write "<table>"
    Response.Write "<tr><th>StepID</th><th>Nome</th><th>Ordem</th></tr>"
    
    On Error Resume Next
    call getRecordSet("SELECT stepID, workflowID FROM T_WORKFLOW_STEP WHERE workflowID = " & workflowID & " ORDER BY stepID", rs)
    If Err.Number <> 0 Then
        Response.Write "</table>"
        Response.Write "<p class='not-found'>Erro: " & Err.Description & "</p>"
        Err.Clear
    Else
        While Not rs.EOF
            Response.Write "<tr>"
            Response.Write "<td>" & rs("stepID") & "</td>"
            Response.Write "<td>Step " & rs("stepID") & "</td>"
            Response.Write "<td>"
            If rs("stepID") = stepID Then
                Response.Write "<strong>← ATUAL (Brainstorming)</strong>"
            ElseIf rs("stepID") < stepID Then
                Response.Write "Anterior"
            Else
                Response.Write "Posterior"
            End If
            Response.Write "</td>"
            Response.Write "</tr>"
            rs.MoveNext
        Wend
        Response.Write "</table>"
    End If
    On Error Goto 0
    
    ' 3. Verificar Bibliometrics
    Response.Write "<h2>3. Verificar Bibliometrics</h2>"
    
    ' Buscar em todos os steps anteriores
    call getRecordSet("SELECT s.stepID, s.name, COUNT(b.referenceID) as total " & _
                     "FROM T_WORKFLOW_STEP s " & _
                     "LEFT JOIN T_FTA_METHOD_BIBLIOMETRICS b ON s.stepID = b.stepID " & _
                     "WHERE s.workflowID = " & workflowID & " AND s.stepID < " & stepID & _
                     " GROUP BY s.stepID, s.name " & _
                     " ORDER BY s.stepID", rs)
    
    Dim foundBiblio
    foundBiblio = false
    
    Response.Write "<table>"
    Response.Write "<tr><th>StepID</th><th>Step Nome</th><th>Referências</th></tr>"
    While Not rs.EOF
        Response.Write "<tr>"
        Response.Write "<td>" & rs("stepID") & "</td>"
        Response.Write "<td>" & rs("name") & "</td>"
        Response.Write "<td>"
        If rs("total") > 0 Then
            Response.Write "<span class='found'>" & rs("total") & " referências</span>"
            foundBiblio = true
        Else
            Response.Write "0"
        End If
        Response.Write "</td>"
        Response.Write "</tr>"
        rs.MoveNext
    Wend
    Response.Write "</table>"
    
    If Not foundBiblio Then
        Response.Write "<p class='not-found'>✗ Nenhum dado bibliométrico encontrado nos steps anteriores</p>"
    End If
    
    ' 4. Verificar Scenarios
    Response.Write "<h2>4. Verificar Scenarios</h2>"
    
    call getRecordSet("SELECT s.stepID, s.name, COUNT(sc.scenarioID) as total " & _
                     "FROM T_WORKFLOW_STEP s " & _
                     "LEFT JOIN T_FTA_METHOD_SCENARIOS sc ON s.stepID = sc.stepID " & _
                     "WHERE s.workflowID = " & workflowID & " AND s.stepID < " & stepID & _
                     " GROUP BY s.stepID, s.name " & _
                     " ORDER BY s.stepID", rs)
    
    Dim foundScenarios
    foundScenarios = false
    
    Response.Write "<table>"
    Response.Write "<tr><th>StepID</th><th>Step Nome</th><th>Cenários</th></tr>"
    While Not rs.EOF
        Response.Write "<tr>"
        Response.Write "<td>" & rs("stepID") & "</td>"
        Response.Write "<td>" & rs("name") & "</td>"
        Response.Write "<td>"
        If rs("total") > 0 Then
            Response.Write "<span class='found'>" & rs("total") & " cenários</span>"
            foundScenarios = true
            
            ' Mostrar detalhes dos cenários
            Dim stepIDTemp
            stepIDTemp = rs("stepID")
            call getRecordSet("SELECT name FROM T_FTA_METHOD_SCENARIOS WHERE stepID = " & stepIDTemp, rsScenarios)
            Response.Write "<ul>"
            While Not rsScenarios.EOF
                Response.Write "<li>" & rsScenarios("name") & "</li>"
                rsScenarios.MoveNext
            Wend
            Response.Write "</ul>"
        Else
            Response.Write "0"
        End If
        Response.Write "</td>"
        Response.Write "</tr>"
        rs.MoveNext
    Wend
    Response.Write "</table>"
    
    If Not foundScenarios Then
        Response.Write "<p class='not-found'>✗ Nenhum cenário encontrado nos steps anteriores</p>"
    End If
    
    ' 5. Resumo
    Response.Write "<h2>5. Resumo para Integração Dublin Core</h2>"
    If foundBiblio Or foundScenarios Then
        Response.Write "<div style='background: #e8f5e9; padding: 15px; border-radius: 5px;'>"
        Response.Write "<p class='found'>✓ Dados disponíveis para integração:</p>"
        Response.Write "<ul>"
        If foundBiblio Then Response.Write "<li>Dados Bibliométricos</li>"
        If foundScenarios Then Response.Write "<li>Cenários</li>"
        Response.Write "</ul>"
        Response.Write "<p>Estes dados devem aparecer ao criar uma nova ideia no Brainstorming!</p>"
        Response.Write "</div>"
    Else
        Response.Write "<div style='background: #ffebee; padding: 15px; border-radius: 5px;'>"
        Response.Write "<p class='not-found'>✗ Nenhum dado de métodos anteriores disponível para integração</p>"
        Response.Write "<p>Para ter dados disponíveis, é necessário:</p>"
        Response.Write "<ul>"
        Response.Write "<li>Executar o Bibliometrics em um step anterior</li>"
        Response.Write "<li>Criar Scenarios em um step anterior</li>"
        Response.Write "</ul>"
        Response.Write "</div>"
    End If
    %>
    
    <hr>
    <p>
        <a href="manageIdea.asp?stepID=50380&brainstormingID=20021&action=add">Testar Nova Ideia</a> |
        <a href="index.asp?stepID=50380">Voltar ao Brainstorming</a>
    </p>
</body>
</html>