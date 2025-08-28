<!--#include virtual="/system.asp"-->
<%
Response.ContentType = "text/html"
%>
<!DOCTYPE html>
<html>
<head>
    <title>Rastrear Dados Dublin Core</title>
    <style>
        body { font-family: Arial; padding: 20px; background: #f5f5f5; }
        .container { max-width: 1200px; margin: 0 auto; background: white; padding: 20px; border-radius: 10px; }
        .workflow-box { border: 2px solid #007bff; padding: 15px; margin: 20px 0; border-radius: 8px; }
        .step-box { background: #f0f8ff; padding: 10px; margin: 10px 0; border-left: 4px solid #28a745; }
        .data-box { background: #fff3cd; padding: 10px; margin: 5px 0; }
        table { width: 100%; border-collapse: collapse; margin: 10px 0; }
        th, td { border: 1px solid #ddd; padding: 8px; text-align: left; }
        th { background: #007bff; color: white; }
        .highlight { background: yellow; font-weight: bold; }
        .success { color: green; font-weight: bold; }
        .error { color: red; }
    </style>
</head>
<body>
    <div class="container">
        <h1>?? Rastreamento Completo dos Dados Dublin Core</h1>
        
        <form method="get">
            <label>Digite o stepID do Brainstorming: </label>
            <input type="text" name="stepID" value="<%=Request.QueryString("stepID")%>" placeholder="Ex: 50380">
            <button type="submit">Analisar</button>
        </form>
        
        <%
        Dim stepID
        stepID = Request.QueryString("stepID")
        
        If stepID <> "" Then
            Dim workflowID
            
            ' 1. Identificar o workflow
            Response.Write "<div class='workflow-box'>"
            Response.Write "<h2>?? Workflow do Step " & stepID & "</h2>"
            
            call getRecordSet("SELECT * FROM T_WORKFLOW_STEP WHERE stepID = " & stepID, rs)
            If Not rs.EOF Then
                workflowID = rs("workflowID")
                Response.Write "<p>WorkflowID: <span class='highlight'>" & workflowID & "</span></p>"
                
                ' Buscar nome do workflow
                call getRecordSet("SELECT * FROM T_WORKFLOW WHERE workflowID = " & workflowID, rsWF)
                If Not rsWF.EOF Then
                    Response.Write "<p>Nome do Workflow: " & rsWF("name") & "</p>"
                    Response.Write "<p>Descrição: " & rsWF("description") & "</p>"
                End If
            Else
                Response.Write "<p class='error'>Step não encontrado!</p>"
            End If
            Response.Write "</div>"
            
            If workflowID <> "" Then
                ' 2. Listar TODOS os steps do workflow
                Response.Write "<div class='workflow-box'>"
                Response.Write "<h2>?? Todos os Steps do Workflow " & workflowID & "</h2>"
                
                call getRecordSet("SELECT stepID FROM T_WORKFLOW_STEP WHERE workflowID = " & workflowID & " ORDER BY stepID", rs)
                
                Response.Write "<table>"
                Response.Write "<tr><th>StepID</th><th>Posição</th><th>Bibliometrics</th><th>Scenarios</th><th>Dublin Core?</th></tr>"
                
                While Not rs.EOF
                    Dim currentStepID, biblioCount, scenarioCount, isDublinSource
                    currentStepID = rs("stepID")
                    biblioCount = 0
                    scenarioCount = 0
                    isDublinSource = false
                    
                    ' Contar bibliometrics
                    call getRecordSet("SELECT COUNT(*) as total FROM T_FTA_METHOD_BIBLIOMETRICS WHERE stepID = " & currentStepID, rsBiblio)
                    If Not rsBiblio.EOF Then biblioCount = rsBiblio("total")
                    
                    ' Contar scenarios
                    call getRecordSet("SELECT COUNT(*) as total FROM T_FTA_METHOD_SCENARIOS WHERE stepID = " & currentStepID, rsScenario)
                    If Not rsScenario.EOF Then scenarioCount = rsScenario("total")
                    
                    ' Verificar se é fonte para Dublin Core
                    If currentStepID < CLng(stepID) And (biblioCount > 0 Or scenarioCount > 0) Then
                        isDublinSource = true
                    End If
                    
                    Response.Write "<tr"
                    If currentStepID = CLng(stepID) Then
                        Response.Write " style='background: #ffeb3b;'"
                    ElseIf isDublinSource Then
                        Response.Write " style='background: #c8e6c9;'"
                    End If
                    Response.Write ">"
                    
                    Response.Write "<td>" & currentStepID & "</td>"
                    Response.Write "<td>"
                    If currentStepID = CLng(stepID) Then
                        Response.Write "<strong>? BRAINSTORMING</strong>"
                    ElseIf currentStepID < CLng(stepID) Then
                        Response.Write "Anterior"
                    Else
                        Response.Write "Posterior"
                    End If
                    Response.Write "</td>"
                    Response.Write "<td>" & biblioCount & "</td>"
                    Response.Write "<td>" & scenarioCount & "</td>"
                    Response.Write "<td>"
                    If isDublinSource Then
                        Response.Write "<span class='success'>? FONTE</span>"
                    Else
                        Response.Write "-"
                    End If
                    Response.Write "</td>"
                    Response.Write "</tr>"
                    
                    rs.MoveNext
                Wend
                Response.Write "</table>"
                Response.Write "</div>"
                
                ' 3. Dados que o Dublin Core vai capturar
                Response.Write "<div class='workflow-box'>"
                Response.Write "<h2>?? Dados que o Dublin Core VAI Capturar</h2>"
                
                ' Buscar step com bibliometrics mais recente
                Response.Write "<h3>Bibliometrics:</h3>"
                call getRecordSet("SELECT TOP 1 s.stepID FROM T_WORKFLOW_STEP s " & _
                                 "WHERE s.workflowID = " & workflowID & " AND s.stepID < " & stepID & _
                                 " AND EXISTS (SELECT 1 FROM T_FTA_METHOD_BIBLIOMETRICS b WHERE b.stepID = s.stepID) " & _
                                 " ORDER BY s.stepID DESC", rs)
                
                If Not rs.EOF Then
                    Dim biblioStepID
                    biblioStepID = rs("stepID")
                    Response.Write "<div class='step-box'>"
                    Response.Write "<p>Será capturado do Step: <span class='highlight'>" & biblioStepID & "</span></p>"
                    
                    ' Mostrar dados
                    call getRecordSet("SELECT COUNT(*) as total FROM T_FTA_METHOD_BIBLIOMETRICS WHERE stepID = " & biblioStepID, rs)
                    Response.Write "<p>Total: " & rs("total") & " referências</p>"
                    
                    Response.Write "<p>Títulos:</p><ul>"
                    call getRecordSet("SELECT title, year FROM T_FTA_METHOD_BIBLIOMETRICS WHERE stepID = " & biblioStepID & " ORDER BY year DESC", rs)
                    While Not rs.EOF
                        Response.Write "<li>" & rs("title") & " (" & rs("year") & ")</li>"
                        rs.MoveNext
                    Wend
                    Response.Write "</ul>"
                    Response.Write "</div>"
                Else
                    Response.Write "<p class='error'>Nenhum step anterior com Bibliometrics</p>"
                End If
                
                ' Buscar step com scenarios mais recente
                Response.Write "<h3>Scenarios:</h3>"
                call getRecordSet("SELECT TOP 1 s.stepID FROM T_WORKFLOW_STEP s " & _
                                 "WHERE s.workflowID = " & workflowID & " AND s.stepID < " & stepID & _
                                 " AND EXISTS (SELECT 1 FROM T_FTA_METHOD_SCENARIOS sc WHERE sc.stepID = s.stepID) " & _
                                 " ORDER BY s.stepID DESC", rs)
                
                If Not rs.EOF Then
                    Dim scenarioStepID
                    scenarioStepID = rs("stepID")
                    Response.Write "<div class='step-box'>"
                    Response.Write "<p>Será capturado do Step: <span class='highlight'>" & scenarioStepID & "</span></p>"
                    
                    ' Mostrar dados
                    call getRecordSet("SELECT name, LEFT(scenario, 200) as snippet FROM T_FTA_METHOD_SCENARIOS WHERE stepID = " & scenarioStepID, rs)
                    Response.Write "<p>Cenários:</p><ul>"
                    While Not rs.EOF
                        Response.Write "<li><strong>" & rs("name") & ":</strong> " & Left(rs("snippet"), 100) & "...</li>"
                        rs.MoveNext
                    Wend
                    Response.Write "</ul>"
                    Response.Write "</div>"
                Else
                    Response.Write "<p class='error'>Nenhum step anterior com Scenarios</p>"
                End If
                
                Response.Write "</div>"
                
                ' 4. Comparação com outros workflows
                Response.Write "<div class='workflow-box'>"
                Response.Write "<h2>?? Outros Workflows para Comparação</h2>"
                
                call getRecordSet("SELECT DISTINCT TOP 5 w.workflowID, w.name FROM T_WORKFLOW w " & _
                                 "INNER JOIN T_WORKFLOW_STEP s ON w.workflowID = s.workflowID " & _
                                 "WHERE w.workflowID <> " & workflowID & " ORDER BY w.workflowID DESC", rs)
                
                Response.Write "<table>"
                Response.Write "<tr><th>WorkflowID</th><th>Nome</th><th>Steps</th><th>Analisar</th></tr>"
                
                While Not rs.EOF
                    Response.Write "<tr>"
                    Response.Write "<td>" & rs("workflowID") & "</td>"
                    Response.Write "<td>" & rs("name") & "</td>"
                    
                    ' Contar steps
                    call getRecordSet("SELECT COUNT(*) as total FROM T_WORKFLOW_STEP WHERE workflowID = " & rs("workflowID"), rsCount)
                    Response.Write "<td>" & rsCount("total") & "</td>"
                    
                    ' Link para analisar
                    call getRecordSet("SELECT MAX(stepID) as maxStep FROM T_WORKFLOW_STEP WHERE workflowID = " & rs("workflowID"), rsMax)
                    Response.Write "<td><a href='?stepID=" & rsMax("maxStep") & "'>Analisar Step " & rsMax("maxStep") & "</a></td>"
                    
                    Response.Write "</tr>"
                    rs.MoveNext
                Wend
                Response.Write "</table>"
                Response.Write "</div>"
            End If
        End If
        %>
        
        <hr>
        <div style="background: #e8f5e9; padding: 20px; border-radius: 8px; margin: 20px 0;">
            <h3>?? Como o Dublin Core Funciona:</h3>
            <ol>
                <li>Busca o workflow do step atual (Brainstorming)</li>
                <li>Procura steps ANTERIORES (stepID menor) no MESMO workflow</li>
                <li>Para Bibliometrics: pega o step mais recente que tem dados</li>
                <li>Para Scenarios: pega o step mais recente que tem dados</li>
                <li>Mostra esses dados ao criar nova ideia</li>
            </ol>
            <p><strong>Importante:</strong> Cada workflow é independente. O Brainstorming só vê dados do seu próprio workflow!</p>
        </div>
    </div>
</body>
</html>