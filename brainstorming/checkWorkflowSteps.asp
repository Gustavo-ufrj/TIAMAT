<!--#include virtual="/system.asp"-->
<%
Response.ContentType = "text/html"
%>
<!DOCTYPE html>
<html>
<head>
    <title>Verificar Steps do Workflow</title>
    <style>
        body { font-family: Arial; padding: 20px; }
        table { width: 100%; border-collapse: collapse; margin: 20px 0; }
        th, td { border: 1px solid #ddd; padding: 8px; text-align: left; }
        th { background: #4CAF50; color: white; }
        .current { background: #ffeb3b; }
        .previous { background: #c8e6c9; }
        .success { color: green; font-weight: bold; }
        .error { color: red; }
    </style>
</head>
<body>
    <h1>📊 Análise Completa do Workflow 30144</h1>
    
    <%
    Dim workflowID, currentStepID
    workflowID = 30144
    currentStepID = 50380
    
    ' 1. Listar TODOS os steps do workflow
    Response.Write "<h2>1. Todos os Steps do Workflow</h2>"
    Response.Write "<table>"
    Response.Write "<tr><th>StepID</th><th>WorkflowID</th><th>Type</th><th>Status</th><th>Posição</th></tr>"
    
    call getRecordSet("SELECT * FROM T_WORKFLOW_STEP WHERE workflowID = " & workflowID & " ORDER BY stepID", rs)
    
    While Not rs.EOF
        Dim cssClass
        cssClass = ""
        If rs("stepID") = currentStepID Then
            cssClass = "current"
        ElseIf rs("stepID") < currentStepID Then
            cssClass = "previous"
        End If
        
        Response.Write "<tr class='" & cssClass & "'>"
        Response.Write "<td>" & rs("stepID") & "</td>"
        Response.Write "<td>" & rs("workflowID") & "</td>"
        Response.Write "<td>" & rs("type") & "</td>"
        Response.Write "<td>" & rs("status") & "</td>"
        Response.Write "<td>"
        If rs("stepID") = currentStepID Then
            Response.Write "<strong>← BRAINSTORMING ATUAL</strong>"
        ElseIf rs("stepID") < currentStepID Then
            Response.Write "✅ Step Anterior (disponível para Dublin Core)"
        Else
            Response.Write "Step Posterior"
        End If
        Response.Write "</td>"
        Response.Write "</tr>"
        rs.MoveNext
    Wend
    Response.Write "</table>"
    
    ' 2. Verificar dados do Bibliometrics em TODOS os steps
    Response.Write "<h2>2. Dados Bibliométricos em Todos os Steps</h2>"
    Response.Write "<table>"
    Response.Write "<tr><th>StepID</th><th>Total Referências</th><th>Disponível para Dublin Core?</th></tr>"
    
    call getRecordSet("SELECT stepID, COUNT(*) as total FROM T_FTA_METHOD_BIBLIOMETRICS " & _
                     "GROUP BY stepID ORDER BY stepID", rs)
    
    While Not rs.EOF
        Response.Write "<tr>"
        Response.Write "<td>" & rs("stepID") & "</td>"
        Response.Write "<td>" & rs("total") & "</td>"
        Response.Write "<td>"
        If rs("stepID") < currentStepID Then
            Response.Write "<span class='success'>✅ SIM</span>"
        Else
            Response.Write "❌ NÃO (step não é anterior)"
        End If
        Response.Write "</td>"
        Response.Write "</tr>"
        rs.MoveNext
    Wend
    Response.Write "</table>"
    
    ' 3. Verificar dados de Scenarios em TODOS os steps
    Response.Write "<h2>3. Dados de Cenários em Todos os Steps</h2>"
    Response.Write "<table>"
    Response.Write "<tr><th>StepID</th><th>Total Cenários</th><th>Disponível para Dublin Core?</th></tr>"
    
    call getRecordSet("SELECT stepID, COUNT(*) as total FROM T_FTA_METHOD_SCENARIOS " & _
                     "GROUP BY stepID ORDER BY stepID", rs)
    
    While Not rs.EOF
        Response.Write "<tr>"
        Response.Write "<td>" & rs("stepID") & "</td>"
        Response.Write "<td>" & rs("total") & "</td>"
        Response.Write "<td>"
        If rs("stepID") < currentStepID Then
            Response.Write "<span class='success'>✅ SIM</span>"
        Else
            Response.Write "❌ NÃO (step não é anterior)"
        End If
        Response.Write "</td>"
        Response.Write "</tr>"
        rs.MoveNext
    Wend
    Response.Write "</table>"
    
    ' 4. Análise Final
    Response.Write "<h2>4. Análise Final</h2>"
    
    ' Verificar se existem steps anteriores
    call getRecordSet("SELECT COUNT(*) as total FROM T_WORKFLOW_STEP " & _
                     "WHERE workflowID = " & workflowID & " AND stepID < " & currentStepID, rs)
    
    Dim hasAnteriores
    hasAnteriores = false
    If Not rs.EOF Then
        If rs("total") > 0 Then hasAnteriores = true
    End If
    
    If hasAnteriores Then
        Response.Write "<div style='background: #c8e6c9; padding: 15px; border-radius: 5px;'>"
        Response.Write "<p class='success'>✅ Existem steps anteriores no workflow!</p>"
        
        ' Verificar dados disponíveis
        call getRecordSet("SELECT COUNT(*) as total FROM T_FTA_METHOD_BIBLIOMETRICS b " & _
                         "INNER JOIN T_WORKFLOW_STEP s ON b.stepID = s.stepID " & _
                         "WHERE s.workflowID = " & workflowID & " AND s.stepID < " & currentStepID, rs)
        
        If Not rs.EOF And rs("total") > 0 Then
            Response.Write "<p>📚 " & rs("total") & " referências bibliométricas disponíveis</p>"
        End If
        
        call getRecordSet("SELECT COUNT(*) as total FROM T_FTA_METHOD_SCENARIOS sc " & _
                         "INNER JOIN T_WORKFLOW_STEP s ON sc.stepID = s.stepID " & _
                         "WHERE s.workflowID = " & workflowID & " AND s.stepID < " & currentStepID, rs)
        
        If Not rs.EOF And rs("total") > 0 Then
            Response.Write "<p>🎯 " & rs("total") & " cenários disponíveis</p>"
        End If
        
        Response.Write "</div>"
    Else
        Response.Write "<div style='background: #ffcdd2; padding: 15px; border-radius: 5px;'>"
        Response.Write "<p class='error'>❌ NÃO existem steps anteriores ao Brainstorming (50380) no workflow!</p>"
        Response.Write "<p>O step 50380 é o primeiro do workflow, por isso não há dados anteriores para o Dublin Core.</p>"
        Response.Write "</div>"
    End If
    %>
    
    <hr>
    <div style="margin-top: 20px;">
        <a href="addTestData.asp" style="padding: 10px; background: #4CAF50; color: white; text-decoration: none; border-radius: 5px;">
            🔧 Adicionar Dados de Teste
        </a>
        <a href="index.asp?stepID=50380" style="padding: 10px; background: #2196F3; color: white; text-decoration: none; border-radius: 5px; margin-left: 10px;">
            📋 Voltar ao Brainstorming
        </a>
    </div>
</body>
</html>