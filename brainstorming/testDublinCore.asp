<!--#include virtual="/system.asp"-->
<!--#include file="INC_BRAINSTORMING.inc"-->
<%
Response.ContentType = "text/html"
%>
<!DOCTYPE html>
<html>
<head>
    <title>Teste Dublin Core - Brainstorming</title>
    <style>
        body { font-family: Arial; padding: 20px; background: #f5f5f5; }
        .container { max-width: 1000px; margin: 0 auto; background: white; padding: 20px; border-radius: 10px; }
        h2 { color: #007bff; border-bottom: 2px solid #007bff; padding-bottom: 10px; }
        .section { margin: 20px 0; padding: 15px; background: #f8f9fa; border-radius: 5px; }
        .success { color: green; }
        .error { color: red; }
        .data-box { background: white; padding: 10px; margin: 10px 0; border-left: 4px solid #007bff; }
        table { width: 100%; border-collapse: collapse; }
        td { padding: 5px; border-bottom: 1px solid #ddd; }
    </style>
</head>
<body>
    <div class="container">
        <h1>🔍 Teste de Integração Dublin Core</h1>
        
        <%
        Dim stepID, workflowID
        stepID = 50380 ' Brainstorming step
        
        Response.Write "<div class='section'>"
        Response.Write "<h2>1. Identificando Workflow</h2>"
        
        ' Buscar workflow
        On Error Resume Next
        call getRecordSet("SELECT * FROM T_WORKFLOW_STEP WHERE stepID = " & stepID, rs)
        If Err.Number <> 0 Then
            Response.Write "<p class='error'>❌ Erro ao buscar workflow: " & Err.Description & "</p>"
            Err.Clear
        ElseIf Not rs.EOF Then
            workflowID = rs("workflowID")
            Dim stepName
            stepName = "Step " & stepID
            On Error Resume Next
            If Not IsNull(rs.Fields("name")) Then stepName = rs("name")
            On Error Goto 0
            Response.Write "<p class='success'>✅ Workflow encontrado: ID = " & workflowID & "</p>"
            Response.Write "<p>Step: " & stepName & " (ID: " & stepID & ")</p>"
        Else
            Response.Write "<p class='error'>❌ Workflow não encontrado para stepID " & stepID & "</p>"
        End If
        On Error Goto 0
        Response.Write "</div>"
        
        ' Buscar todos os steps do workflow
        Response.Write "<div class='section'>"
        Response.Write "<h2>2. Steps do Workflow</h2>"
        
        On Error Resume Next
        call getRecordSet("SELECT stepID, workflowID FROM T_WORKFLOW_STEP " & _
                         "WHERE workflowID = " & workflowID & " ORDER BY stepID", rs)
        
        If Err.Number <> 0 Then
            Response.Write "<p class='error'>Erro: " & Err.Description & "</p>"
            Err.Clear
        Else
            Response.Write "<table>"
            Response.Write "<tr><th>StepID</th><th>Nome</th><th>Status</th></tr>"
            While Not rs.EOF
                Response.Write "<tr>"
                Response.Write "<td>" & rs("stepID") & "</td>"
                Response.Write "<td>Step " & rs("stepID") & "</td>"
                Response.Write "<td>"
                If rs("stepID") = stepID Then
                    Response.Write "<strong>📍 ATUAL</strong>"
                ElseIf rs("stepID") < stepID Then
                    Response.Write "✅ Anterior"
                Else
                    Response.Write "⏭️ Posterior"
                End If
                Response.Write "</td>"
                Response.Write "</tr>"
                rs.MoveNext
            Wend
            Response.Write "</table>"
        End If
        On Error Goto 0
        Response.Write "</div>"
        
        ' Buscar dados do Bibliometrics
        Response.Write "<div class='section'>"
        Response.Write "<h2>3. Dados do Bibliometrics</h2>"
        
        Dim biblioStepID
        call getRecordSet("SELECT TOP 1 s.stepID FROM T_WORKFLOW_STEP s " & _
                         "WHERE s.workflowID = " & workflowID & " AND s.stepID < " & stepID & _
                         " AND EXISTS (SELECT 1 FROM T_FTA_METHOD_BIBLIOMETRICS b WHERE b.stepID = s.stepID) " & _
                         " ORDER BY s.stepID DESC", rs)
        
        If Not rs.EOF Then
            biblioStepID = rs("stepID")
            Response.Write "<p class='success'>✅ Bibliometrics encontrado no step " & biblioStepID & "</p>"
            
            ' Contar referências
            call getRecordSet("SELECT COUNT(*) as total FROM T_FTA_METHOD_BIBLIOMETRICS WHERE stepID = " & biblioStepID, rs)
            Response.Write "<div class='data-box'>"
            Response.Write "<strong>Total de referências:</strong> " & rs("total") & "<br>"
            
            ' Listar algumas referências
            call getRecordSet("SELECT TOP 5 * FROM T_FTA_METHOD_BIBLIOMETRICS WHERE stepID = " & biblioStepID & " ORDER BY year DESC", rs)
            Response.Write "<strong>Exemplos de títulos:</strong><ul>"
            While Not rs.EOF
                Response.Write "<li>" & Left(rs("title") & "", 80) & "... (" & rs("year") & ")</li>"
                rs.MoveNext
            Wend
            Response.Write "</ul>"
            
            ' Autores principais
            call getRecordSet("SELECT TOP 5 a.name, COUNT(*) as freq FROM T_FTA_METHOD_BIBLIOMETRICS_AUTHORS a " & _
                             "INNER JOIN T_FTA_METHOD_BIBLIOMETRICS b ON a.referenceID = b.referenceID " & _
                             "WHERE b.stepID = " & biblioStepID & _
                             " GROUP BY a.name ORDER BY COUNT(*) DESC", rs)
            Response.Write "<strong>Autores mais frequentes:</strong><ul>"
            While Not rs.EOF
                Response.Write "<li>" & rs("name") & " (" & rs("freq") & " publicações)</li>"
                rs.MoveNext
            Wend
            Response.Write "</ul>"
            Response.Write "</div>"
        Else
            Response.Write "<p class='error'>❌ Nenhum dado bibliométrico encontrado nos steps anteriores</p>"
        End If
        Response.Write "</div>"
        
        ' Buscar dados do Scenarios
        Response.Write "<div class='section'>"
        Response.Write "<h2>4. Dados do Scenarios</h2>"
        
        Dim scenarioStepID
        call getRecordSet("SELECT TOP 1 s.stepID FROM T_WORKFLOW_STEP s " & _
                         "WHERE s.workflowID = " & workflowID & " AND s.stepID < " & stepID & _
                         " AND EXISTS (SELECT 1 FROM T_FTA_METHOD_SCENARIOS sc WHERE sc.stepID = s.stepID) " & _
                         " ORDER BY s.stepID DESC", rs)
        
        If Not rs.EOF Then
            scenarioStepID = rs("stepID")
            Response.Write "<p class='success'>✅ Scenarios encontrado no step " & scenarioStepID & "</p>"
            
            ' Listar cenários
            call getRecordSet("SELECT * FROM T_FTA_METHOD_SCENARIOS WHERE stepID = " & scenarioStepID, rs)
            Response.Write "<div class='data-box'>"
            Response.Write "<strong>Cenários desenvolvidos:</strong><ul>"
            While Not rs.EOF
                Response.Write "<li><strong>" & rs("name") & ":</strong> " & Left(rs("scenario") & "", 200) & "...</li>"
                rs.MoveNext
            Wend
            Response.Write "</ul>"
            Response.Write "</div>"
        Else
            Response.Write "<p class='error'>❌ Nenhum cenário encontrado nos steps anteriores</p>"
        End If
        Response.Write "</div>"
        
        ' Teste de integração
        Response.Write "<div class='section'>"
        Response.Write "<h2>5. Teste de Integração Dublin Core</h2>"
        
        If biblioStepID <> "" Or scenarioStepID <> "" Then
            Response.Write "<p class='success'>✅ Dados disponíveis para integração:</p>"
            Response.Write "<ul>"
            If biblioStepID <> "" Then Response.Write "<li>Bibliometrics (Step " & biblioStepID & ")</li>"
            If scenarioStepID <> "" Then Response.Write "<li>Scenarios (Step " & scenarioStepID & ")</li>"
            Response.Write "</ul>"
            Response.Write "<p>Estes dados estarão disponíveis ao criar novas ideias no Brainstorming!</p>"
        Else
            Response.Write "<p class='error'>❌ Nenhum dado de métodos anteriores disponível</p>"
        End If
        Response.Write "</div>"
        %>
        
        <hr>
        <div style="margin-top: 20px;">
            <a href="manageIdea.asp?stepID=50380&brainstormingID=20021&action=add" 
               style="padding: 10px 20px; background: #28a745; color: white; text-decoration: none; border-radius: 5px;">
                🚀 Testar Criar Nova Ideia com Dublin Core
            </a>
            <a href="index.asp?stepID=50380" 
               style="padding: 10px 20px; background: #007bff; color: white; text-decoration: none; border-radius: 5px; margin-left: 10px;">
                📋 Voltar ao Brainstorming
            </a>
        </div>
    </div>
</body>
</html>