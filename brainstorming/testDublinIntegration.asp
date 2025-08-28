<!--#include virtual="/system.asp"-->
<!--#include file="INC_BRAINSTORMING.inc"-->
<%
Response.ContentType = "text/html"
%>
<!DOCTYPE html>
<html>
<head>
    <title>Teste Integração Dublin Core</title>
    <style>
        body { font-family: Arial; padding: 20px; background: #f5f5f5; }
        .container { max-width: 1000px; margin: 0 auto; background: white; padding: 20px; border-radius: 10px; }
        .success { color: green; font-weight: bold; }
        .error { color: red; font-weight: bold; }
        .box { background: #f0f8ff; padding: 15px; margin: 15px 0; border-radius: 5px; border-left: 4px solid #007bff; }
        table { width: 100%; border-collapse: collapse; margin: 10px 0; }
        td, th { border: 1px solid #ddd; padding: 8px; }
        th { background: #e0e0e0; }
        .highlight { background: yellow; padding: 2px 5px; }
    </style>
</head>
<body>
    <div class="container">
        <h1>?? Teste Completo da Integração Dublin Core no Brainstorming</h1>
        
        <%
        Dim stepID, workflowID, brainstormingID
        stepID = 50380
        brainstormingID = 20021
        
        ' 1. Verificar workflow
        Response.Write "<div class='box'>"
        Response.Write "<h2>1. Identificação do Workflow</h2>"
        
        call getRecordSet("SELECT workflowID FROM T_WORKFLOW_STEP WHERE stepID = " & stepID, rs)
        If Not rs.EOF Then
            workflowID = rs("workflowID")
            Response.Write "<p class='success'>? Workflow: " & workflowID & "</p>"
        End If
        Response.Write "</div>"
        
        ' 2. Verificar steps anteriores
        Response.Write "<div class='box'>"
        Response.Write "<h2>2. Steps Anteriores no Workflow</h2>"
        
        call getRecordSet("SELECT stepID FROM T_WORKFLOW_STEP WHERE workflowID = " & workflowID & " AND stepID < " & stepID & " ORDER BY stepID", rs)
        
        Response.Write "<table>"
        Response.Write "<tr><th>StepID</th><th>Tem Bibliometrics?</th><th>Tem Scenarios?</th></tr>"
        
        While Not rs.EOF
            Dim tempStepID
            tempStepID = rs("stepID")
            
            Response.Write "<tr>"
            Response.Write "<td>" & tempStepID & "</td>"
            
            ' Verificar Bibliometrics
            call getRecordSet("SELECT COUNT(*) as total FROM T_FTA_METHOD_BIBLIOMETRICS WHERE stepID = " & tempStepID, rsBiblio)
            If Not rsBiblio.EOF And rsBiblio("total") > 0 Then
                Response.Write "<td class='success'>? " & rsBiblio("total") & " refs</td>"
            Else
                Response.Write "<td>-</td>"
            End If
            
            ' Verificar Scenarios
            call getRecordSet("SELECT COUNT(*) as total FROM T_FTA_METHOD_SCENARIOS WHERE stepID = " & tempStepID, rsScenario)
            If Not rsScenario.EOF And rsScenario("total") > 0 Then
                Response.Write "<td class='success'>? " & rsScenario("total") & " cenários</td>"
            Else
                Response.Write "<td>-</td>"
            End If
            
            Response.Write "</tr>"
            rs.MoveNext
        Wend
        Response.Write "</table>"
        Response.Write "</div>"
        
        ' 3. Buscar dados do Bibliometrics (como no manageIdea.asp)
        Response.Write "<div class='box'>"
        Response.Write "<h2>3. Dados do Bibliometrics para Dublin Core</h2>"
        
        Dim biblioStepID, biblioCount
        biblioCount = 0
        
        ' Query exata do manageIdea.asp
        call getRecordSet("SELECT TOP 1 s.stepID FROM T_WORKFLOW_STEP s " & _
                         "WHERE s.workflowID = " & workflowID & " AND s.stepID < " & stepID & _
                         " AND EXISTS (SELECT 1 FROM T_FTA_METHOD_BIBLIOMETRICS b WHERE b.stepID = s.stepID) " & _
                         " ORDER BY s.stepID DESC", rs)
        
        If Not rs.EOF Then
            biblioStepID = rs("stepID")
            Response.Write "<p class='success'>? Step com Bibliometrics: " & biblioStepID & "</p>"
            
            ' Contar e mostrar dados
            call getRecordSet("SELECT COUNT(*) as total FROM T_FTA_METHOD_BIBLIOMETRICS WHERE stepID = " & biblioStepID, rs)
            If Not rs.EOF Then
                biblioCount = rs("total")
                Response.Write "<p>Total de referências: <span class='highlight'>" & biblioCount & "</span></p>"
            End If
            
            ' Mostrar títulos
            Response.Write "<h4>Títulos encontrados:</h4><ul>"
            call getRecordSet("SELECT TOP 5 title FROM T_FTA_METHOD_BIBLIOMETRICS WHERE stepID = " & biblioStepID & " ORDER BY year DESC", rs)
            While Not rs.EOF
                Response.Write "<li>" & Left(rs("title") & "", 80) & "...</li>"
                rs.MoveNext
            Wend
            Response.Write "</ul>"
            
            ' Mostrar autores
            Response.Write "<h4>Autores principais:</h4><ul>"
            call getRecordSet("SELECT TOP 10 a.name, COUNT(*) as freq FROM T_FTA_METHOD_BIBLIOMETRICS_AUTHORS a " & _
                             "INNER JOIN T_FTA_METHOD_BIBLIOMETRICS b ON a.referenceID = b.referenceID " & _
                             "WHERE b.stepID = " & biblioStepID & _
                             " GROUP BY a.name ORDER BY COUNT(*) DESC", rs)
            While Not rs.EOF
                Response.Write "<li>" & rs("name") & " (" & rs("freq") & " publicações)</li>"
                rs.MoveNext
            Wend
            Response.Write "</ul>"
        Else
            Response.Write "<p class='error'>? Nenhum step com Bibliometrics encontrado</p>"
        End If
        Response.Write "</div>"
        
        ' 4. Buscar dados do Scenarios (como no manageIdea.asp)
        Response.Write "<div class='box'>"
        Response.Write "<h2>4. Dados do Scenarios para Dublin Core</h2>"
        
        Dim scenarioStepID, scenarioCount
        scenarioCount = 0
        
        ' Query exata do manageIdea.asp
        call getRecordSet("SELECT TOP 1 s.stepID FROM T_WORKFLOW_STEP s " & _
                         "WHERE s.workflowID = " & workflowID & " AND s.stepID < " & stepID & _
                         " AND EXISTS (SELECT 1 FROM T_FTA_METHOD_SCENARIOS sc WHERE sc.stepID = s.stepID) " & _
                         " ORDER BY s.stepID DESC", rs)
        
        If Not rs.EOF Then
            scenarioStepID = rs("stepID")
            Response.Write "<p class='success'>? Step com Scenarios: " & scenarioStepID & "</p>"
            
            ' Mostrar cenários
            Response.Write "<h4>Cenários encontrados:</h4><ul>"
            call getRecordSet("SELECT name, LEFT(scenario, 200) as snippet FROM T_FTA_METHOD_SCENARIOS WHERE stepID = " & scenarioStepID, rs)
            While Not rs.EOF
                scenarioCount = scenarioCount + 1
                Response.Write "<li><strong>" & rs("name") & ":</strong> " & Left(rs("snippet") & "", 150) & "...</li>"
                rs.MoveNext
            Wend
            Response.Write "</ul>"
            Response.Write "<p>Total de cenários: <span class='highlight'>" & scenarioCount & "</span></p>"
        Else
            Response.Write "<p class='error'>? Nenhum step com Scenarios encontrado</p>"
        End If
        Response.Write "</div>"
        
        ' 5. Resumo Final
        Response.Write "<div class='box' style='background: #fff3cd; border-left-color: #ffc107;'>"
        Response.Write "<h2>5. Resumo Final</h2>"
        
        If biblioCount > 0 Or scenarioCount > 0 Then
            Response.Write "<p class='success'>? <strong>DADOS DISPONÍVEIS PARA O BRAINSTORMING:</strong></p>"
            Response.Write "<ul style='font-size: 1.2em;'>"
            If biblioCount > 0 Then
                Response.Write "<li>?? <strong>" & biblioCount & " referências bibliométricas</strong> do step " & biblioStepID & "</li>"
            End If
            If scenarioCount > 0 Then
                Response.Write "<li>?? <strong>" & scenarioCount & " cenários</strong> do step " & scenarioStepID & "</li>"
            End If
            Response.Write "</ul>"
            Response.Write "<p style='background: #d4edda; padding: 10px; border-radius: 5px;'>"
            Response.Write "Estes dados <strong>DEVEM</strong> aparecer quando você clicar em 'Nova Ideia' no Brainstorming!"
            Response.Write "</p>"
        Else
            Response.Write "<p class='error'>? Nenhum dado disponível para o Dublin Core</p>"
        End If
        Response.Write "</div>"
        %>
        
        <hr>
        <div style="margin: 20px 0; text-align: center;">
            <a href="manageIdea.asp?stepID=50380&brainstormingID=20021&action=add" 
               style="padding: 15px 30px; background: #28a745; color: white; text-decoration: none; border-radius: 5px; font-size: 18px; font-weight: bold;">
                ?? TESTAR: Criar Nova Ideia com Dublin Core
            </a>
        </div>
        
        <div style="text-align: center;">
            <a href="index.asp?stepID=50380" style="padding: 10px 20px; background: #2196F3; color: white; text-decoration: none; border-radius: 5px;">
                ?? Voltar ao Brainstorming
            </a>
        </div>
    </div>
</body>
</html>