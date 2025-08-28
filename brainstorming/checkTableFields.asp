<!--#include virtual="/system.asp"-->
<%
Response.ContentType = "text/html"
%>
<!DOCTYPE html>
<html>
<head>
    <title>Verificar Campos das Tabelas</title>
    <style>
        body { font-family: Arial; padding: 20px; }
        .section { margin: 20px 0; padding: 15px; background: #f5f5f5; border-radius: 5px; }
        table { width: 100%; border-collapse: collapse; }
        th, td { border: 1px solid #ddd; padding: 8px; text-align: left; }
        th { background: #e0e0e0; }
        .error { color: red; }
        .success { color: green; }
    </style>
</head>
<body>
    <h1>Verificar Estrutura das Tabelas</h1>
    
    <%
    On Error Resume Next
    
    ' 1. T_WORKFLOW_STEP
    Response.Write "<div class='section'>"
    Response.Write "<h2>1. T_WORKFLOW_STEP</h2>"
    
    Err.Clear
    call getRecordSet("SELECT TOP 1 * FROM T_WORKFLOW_STEP WHERE stepID = 50380", rs)
    
    If Err.Number <> 0 Then
        Response.Write "<p class='error'>Erro: " & Err.Description & "</p>"
        Err.Clear
    ElseIf rs.EOF Then
        Response.Write "<p class='error'>Nenhum registro encontrado para stepID = 50380</p>"
    Else
        Response.Write "<p class='success'>✓ Registro encontrado</p>"
        Response.Write "<table>"
        Response.Write "<tr><th>Campo</th><th>Valor</th><th>Tipo</th></tr>"
        
        For i = 0 To rs.Fields.Count - 1
            Response.Write "<tr>"
            Response.Write "<td>" & rs.Fields(i).Name & "</td>"
            Response.Write "<td>"
            If Not IsNull(rs.Fields(i).Value) Then
                Response.Write rs.Fields(i).Value
            Else
                Response.Write "<i>NULL</i>"
            End If
            Response.Write "</td>"
            Response.Write "<td>" & rs.Fields(i).Type & "</td>"
            Response.Write "</tr>"
        Next
        Response.Write "</table>"
    End If
    Response.Write "</div>"
    
    ' 2. Buscar todos os steps do workflow
    Response.Write "<div class='section'>"
    Response.Write "<h2>2. Todos os Steps do Workflow</h2>"
    
    ' Primeiro descobrir o workflowID
    Dim workflowID
    workflowID = 0
    
    Err.Clear
    call getRecordSet("SELECT workflowID FROM T_WORKFLOW_STEP WHERE stepID = 50380", rs)
    If Err.Number = 0 And Not rs.EOF Then
        workflowID = rs("workflowID")
        Response.Write "<p class='success'>WorkflowID = " & workflowID & "</p>"
        
        ' Agora buscar todos os steps
        call getRecordSet("SELECT stepID, workflowID FROM T_WORKFLOW_STEP WHERE workflowID = " & workflowID & " ORDER BY stepID", rs)
        
        Response.Write "<table>"
        Response.Write "<tr><th>StepID</th><th>WorkflowID</th><th>Posição</th></tr>"
        
        While Not rs.EOF
            Response.Write "<tr>"
            Response.Write "<td>" & rs("stepID") & "</td>"
            Response.Write "<td>" & rs("workflowID") & "</td>"
            Response.Write "<td>"
            If rs("stepID") = 50380 Then
                Response.Write "<strong>← BRAINSTORMING</strong>"
            ElseIf rs("stepID") < 50380 Then
                Response.Write "Anterior"
            Else
                Response.Write "Posterior"
            End If
            Response.Write "</td>"
            Response.Write "</tr>"
            rs.MoveNext
        Wend
        Response.Write "</table>"
    Else
        Response.Write "<p class='error'>Não foi possível obter o workflowID</p>"
    End If
    Response.Write "</div>"
    
    ' 3. Verificar Bibliometrics
    Response.Write "<div class='section'>"
    Response.Write "<h2>3. Dados Bibliométricos</h2>"
    
    If workflowID > 0 Then
        ' Buscar bibliometrics em steps anteriores
        Dim sql
        sql = "SELECT s.stepID, COUNT(b.referenceID) as total " & _
              "FROM T_WORKFLOW_STEP s " & _
              "LEFT JOIN T_FTA_METHOD_BIBLIOMETRICS b ON s.stepID = b.stepID " & _
              "WHERE s.workflowID = " & workflowID & " AND s.stepID < 50380 " & _
              "GROUP BY s.stepID " & _
              "HAVING COUNT(b.referenceID) > 0"
        
        Err.Clear
        call getRecordSet(sql, rs)
        
        If Err.Number <> 0 Then
            Response.Write "<p class='error'>Erro: " & Err.Description & "</p>"
        ElseIf rs.EOF Then
            Response.Write "<p>Nenhum dado bibliométrico encontrado em steps anteriores</p>"
        Else
            Response.Write "<table>"
            Response.Write "<tr><th>StepID</th><th>Total Referências</th></tr>"
            While Not rs.EOF
                Response.Write "<tr>"
                Response.Write "<td>" & rs("stepID") & "</td>"
                Response.Write "<td>" & rs("total") & "</td>"
                Response.Write "</tr>"
                rs.MoveNext
            Wend
            Response.Write "</table>"
        End If
    End If
    Response.Write "</div>"
    
    ' 4. Verificar Scenarios
    Response.Write "<div class='section'>"
    Response.Write "<h2>4. Dados de Cenários</h2>"
    
    If workflowID > 0 Then
        sql = "SELECT s.stepID, COUNT(sc.scenarioID) as total " & _
              "FROM T_WORKFLOW_STEP s " & _
              "LEFT JOIN T_FTA_METHOD_SCENARIOS sc ON s.stepID = sc.stepID " & _
              "WHERE s.workflowID = " & workflowID & " AND s.stepID < 50380 " & _
              "GROUP BY s.stepID " & _
              "HAVING COUNT(sc.scenarioID) > 0"
        
        Err.Clear
        call getRecordSet(sql, rs)
        
        If Err.Number <> 0 Then
            Response.Write "<p class='error'>Erro: " & Err.Description & "</p>"
        ElseIf rs.EOF Then
            Response.Write "<p>Nenhum cenário encontrado em steps anteriores</p>"
        Else
            Response.Write "<table>"
            Response.Write "<tr><th>StepID</th><th>Total Cenários</th></tr>"
            While Not rs.EOF
                Response.Write "<tr>"
                Response.Write "<td>" & rs("stepID") & "</td>"
                Response.Write "<td>" & rs("total") & "</td>"
                Response.Write "</tr>"
                rs.MoveNext
            Wend
            Response.Write "</table>"
        End If
    End If
    Response.Write "</div>"
    
    On Error Goto 0
    %>
    
    <hr>
    <p>
        <a href="index.asp?stepID=50380">Voltar ao Brainstorming</a> |
        <a href="manageIdea.asp?stepID=50380&brainstormingID=20021&action=add">Criar Nova Ideia</a>
    </p>
</body>
</html>