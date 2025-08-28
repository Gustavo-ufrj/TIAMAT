<!--#include virtual="/system.asp"-->
<!--#include file="INC_BRAINSTORMING.inc"-->
<%
Dim stepID, workflowID
stepID = Request.QueryString("stepID")
If stepID = "" Then stepID = "60382"

' Buscar workflow
call getRecordSet("SELECT workflowID FROM T_WORKFLOW_STEP WHERE stepID = " & stepID, rs)
If Not rs.EOF Then
    workflowID = rs("workflowID")
End If
%>
<!DOCTYPE html>
<html>
<head>
    <title>Dados Dublin Core - Brainstorming</title>
    <style>
        body { font-family: Arial; margin: 0; padding: 0; }
        .dc-container { padding: 20px; }
        .dc-header {
            background: linear-gradient(135deg, #667eea 0%, #764ba2 100%);
            color: white;
            padding: 20px;
            border-radius: 10px 10px 0 0;
        }
        .dc-section {
            background: white;
            border: 1px solid #ddd;
            border-radius: 5px;
            padding: 15px;
            margin: 15px 0;
        }
        .dc-label {
            font-weight: bold;
            color: #667eea;
            margin-bottom: 10px;
        }
        .dc-content {
            background: #f8f9fa;
            padding: 10px;
            border-left: 3px solid #667eea;
            margin: 5px 0;
        }
        .no-data {
            color: #999;
            font-style: italic;
            padding: 20px;
            text-align: center;
        }
        table { width: 100%; border-collapse: collapse; }
        th, td { padding: 8px; text-align: left; border-bottom: 1px solid #ddd; }
        th { background: #f0f0f0; }
        .use-button {
            background: #28a745;
            color: white;
            padding: 10px 20px;
            border: none;
            border-radius: 5px;
            cursor: pointer;
            margin: 5px;
        }
        .use-button:hover { background: #218838; }
    </style>
</head>
<body>
    <div class="dc-container">
        <div class="dc-header">
            <h2>Dados Disponíveis dos Métodos Anteriores</h2>
            <p>Workflow ID: <%=workflowID%> | Step Brainstorming: <%=stepID%></p>
        </div>
        
        <%
        Dim hasBiblio, hasScenario
        hasBiblio = false
        hasScenario = false
        
        ' BUSCAR DADOS DO BIBLIOMETRICS
        Dim biblioStepID, biblioCount
        biblioCount = 0
        
        call getRecordSet("SELECT TOP 1 s.stepID FROM T_WORKFLOW_STEP s " & _
                         "WHERE s.workflowID = " & workflowID & " AND s.stepID < " & stepID & _
                         " AND EXISTS (SELECT 1 FROM T_FTA_METHOD_BIBLIOMETRICS b WHERE b.stepID = s.stepID) " & _
                         " ORDER BY s.stepID DESC", rs)
        
        If Not rs.EOF Then
            biblioStepID = rs("stepID")
            hasBiblio = true
            
            Response.Write "<div class='dc-section'>"
            Response.Write "<div class='dc-label'>?? Dados Bibliométricos (Step " & biblioStepID & ")</div>"
            
            ' Contar referências
            call getRecordSet("SELECT COUNT(*) as total FROM T_FTA_METHOD_BIBLIOMETRICS WHERE stepID = " & biblioStepID, rs)
            If Not rs.EOF Then biblioCount = rs("total")
            
            Response.Write "<p><strong>Total de Referências:</strong> " & biblioCount & "</p>"
            
            ' Listar títulos
            Response.Write "<div class='dc-content'>"
            Response.Write "<strong>Publicações Analisadas:</strong><br>"
            call getRecordSet("SELECT title, year FROM T_FTA_METHOD_BIBLIOMETRICS WHERE stepID = " & biblioStepID & " ORDER BY year DESC", rs)
            Response.Write "<ul>"
            While Not rs.EOF
                Response.Write "<li>" & rs("title") & " (" & rs("year") & ")</li>"
                rs.MoveNext
            Wend
            Response.Write "</ul>"
            Response.Write "</div>"
            
            ' Autores principais
            Response.Write "<div class='dc-content'>"
            Response.Write "<strong>Autores Principais:</strong><br>"
            call getRecordSet("SELECT TOP 10 a.name, COUNT(*) as freq FROM T_FTA_METHOD_BIBLIOMETRICS_AUTHORS a " & _
                             "INNER JOIN T_FTA_METHOD_BIBLIOMETRICS b ON a.referenceID = b.referenceID " & _
                             "WHERE b.stepID = " & biblioStepID & _
                             " GROUP BY a.name ORDER BY COUNT(*) DESC", rs)
            Response.Write "<ul>"
            While Not rs.EOF
                Response.Write "<li>" & rs("name") & " (" & rs("freq") & " publicações)</li>"
                rs.MoveNext
            Wend
            Response.Write "</ul>"
            Response.Write "</div>"
            
            ' Período
            call getRecordSet("SELECT MIN(year) as min_year, MAX(year) as max_year FROM T_FTA_METHOD_BIBLIOMETRICS WHERE stepID = " & biblioStepID, rs)
            If Not rs.EOF Then
                Response.Write "<p><strong>Período:</strong> " & rs("min_year") & " - " & rs("max_year") & "</p>"
            End If
            
            Response.Write "</div>"
        End If
        
        ' BUSCAR DADOS DO SCENARIOS
        Dim scenarioStepID, scenarioCount
        scenarioCount = 0
        
        call getRecordSet("SELECT TOP 1 s.stepID FROM T_WORKFLOW_STEP s " & _
                         "WHERE s.workflowID = " & workflowID & " AND s.stepID < " & stepID & _
                         " AND EXISTS (SELECT 1 FROM T_FTA_METHOD_SCENARIOS sc WHERE sc.stepID = s.stepID) " & _
                         " ORDER BY s.stepID DESC", rs)
        
        If Not rs.EOF Then
            scenarioStepID = rs("stepID")
            hasScenario = true
            
            Response.Write "<div class='dc-section'>"
            Response.Write "<div class='dc-label'>?? Cenários Desenvolvidos (Step " & scenarioStepID & ")</div>"
            
            ' Listar cenários
            call getRecordSet("SELECT * FROM T_FTA_METHOD_SCENARIOS WHERE stepID = " & scenarioStepID, rs)
            While Not rs.EOF
                scenarioCount = scenarioCount + 1
                Response.Write "<div class='dc-content'>"
                Response.Write "<strong>" & rs("name") & "</strong><br>"
                Response.Write "<p>" & rs("scenario") & "</p>"
                If Not IsNull(rs("description")) Then
                    Response.Write "<p><em>Descrição: " & rs("description") & "</em></p>"
                End If
                Response.Write "</div>"
                rs.MoveNext
            Wend
            
            Response.Write "<p><strong>Total de Cenários:</strong> " & scenarioCount & "</p>"
            Response.Write "</div>"
        End If
        
        ' SE NÃO HÁ DADOS
        If Not hasBiblio And Not hasScenario Then
            Response.Write "<div class='no-data'>"
            Response.Write "Nenhum dado de métodos anteriores disponível.<br>"
            Response.Write "Execute Bibliometrics ou Scenarios em steps anteriores para ter dados aqui."
            Response.Write "</div>"
        End If
        
        ' COMO USAR
        If hasBiblio Or hasScenario Then
        %>
        <div class="dc-section" style="background: #e8f5e9;">
            <div class="dc-label">?? Como Usar Estes Dados no Brainstorming</div>
            <ol>
                <li><strong>Ao criar nova ideia:</strong> Os dados aparecem automaticamente no formulário</li>
                <li><strong>Gerar ideias automáticas:</strong> Use os botões de geração baseada nos dados</li>
                <li><strong>Referência manual:</strong> Consulte este painel enquanto pensa em novas ideias</li>
            </ol>
            
            <div style="text-align: center; margin-top: 20px;">
                <button class="use-button" onclick="window.opener.location.href='manageIdea.asp?stepID=<%=stepID%>&brainstormingID=<%=Request.QueryString("brainstormingID")%>&action=add'; window.close();">
                    Criar Nova Ideia com Estes Dados
                </button>
                <button class="use-button" style="background: #007bff;" onclick="window.print();">
                    Imprimir Dados
                </button>
            </div>
        </div>
        <% End If %>
        
        <div style="text-align: center; margin-top: 20px;">
            <button onclick="window.close();" style="padding: 10px 20px; background: #6c757d; color: white; border: none; border-radius: 5px; cursor: pointer;">
                Fechar
            </button>
        </div>
    </div>
</body>
</html>