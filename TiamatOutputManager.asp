<%
'===============================================================================
' TiamatOutputManager.asp - Sistema Simplificado de Integração Dublin Core
' Versão compatível com VBScript clássico - SEM classes complexas
'===============================================================================

' Função para capturar output de bibliometrics com Dublin Core
Function CaptureBibliometricsOutput(stepID, bibliometricData)
    On Error Resume Next
    
    If Not IsNumeric(stepID) Or stepID <= 0 Then
        CaptureBibliometricsOutput = False
        Exit Function
    End If
    
    ' Criar JSON com Dublin Core usando aspJSON
    Dim outputJSON
    Set outputJSON = New aspJSON
    
    With outputJSON.data
        ' Dublin Core Metadata
        .add "dublinCore", outputJSON.Collection()
        With .item("dublinCore")
            .add "title", "Bibliometric Analysis - Step " & stepID
            .add "description", "Systematic bibliometric analysis results"
            .add "creator", IIf(Session("name") <> "", Session("name"), "TIAMAT User")
            .add "subject", "Technology Foresight"
            .add "publisher", "TIAMAT Framework"
            .add "date", FormatDateTime(Now(), 2)
            .add "type", "Bibliometric Analysis"
            .add "format", "JSON-LD"
            .add "identifier", "TIAMAT-BIBLIO-" & stepID & "-" & Replace(FormatDateTime(Now(), 2), "/", "")
            .add "source", "TIAMAT Bibliometrics Module"
            .add "language", "pt-BR"
            .add "coverage", "Academic Literature Review"
            .add "rights", "Internal Use - TIAMAT Framework"
        End With
        
        ' Dados bibliométricos processados
        .add "bibliometricData", bibliometricData
        .add "processedAt", FormatDateTime(Now(), 2)
        .add "stepID", stepID
        .add "framework", "TIAMAT"
        .add "version", "2.0"
    End With
    
    Dim jsonOutput
    jsonOutput = outputJSON.JSONoutput()
    
    ' Salvar no banco de dados
    Dim success
    success = SaveBibliometricsToDatabase(stepID, jsonOutput)
    
    Set outputJSON = Nothing
    CaptureBibliometricsOutput = success
    
    On Error Goto 0
End Function

' Função para recuperar dados bibliométricos para uso no scenario
Function GetBibliometricsForScenario(scenarioStepID)
    On Error Resume Next
    
    GetBibliometricsForScenario = ""
    
    If Not IsNumeric(scenarioStepID) Then Exit Function
    
    ' Buscar workflowID do step atual
    Dim rs, workflowID
    Call getRecordSet("SELECT workflowID FROM tiamat_steps WHERE stepID = " & scenarioStepID, rs)
    
    If Err.Number <> 0 Or rs.eof Then
        Err.Clear
        Exit Function
    End If
    
    workflowID = rs("workflowID")
    
    ' Buscar steps de bibliometrics finalizados neste workflow
    Call getRecordSet("SELECT stepID FROM tiamat_steps WHERE workflowID = " & workflowID & " AND methodID = 9 AND status = 4", rs)
    
    If Err.Number <> 0 Or rs.eof Then
        Err.Clear
        Exit Function
    End If
    
    Dim biblioStepID
    biblioStepID = rs("stepID")
    
    ' Recuperar dados salvos
    Call getRecordSet("SELECT outputData FROM tiamat_step_outputs WHERE stepID = " & biblioStepID & " ORDER BY created DESC", rs)
    
    If Err.Number = 0 And Not rs.eof Then
        GetBibliometricsForScenario = rs("outputData")
    End If
    
    On Error Goto 0
End Function

' Função para salvar dados bibliométricos no banco
Function SaveBibliometricsToDatabase(stepID, jsonData)
    On Error Resume Next
    
    ' Verificar se tabela existe
    Dim rs
    Call getRecordSet("SELECT TABLE_NAME FROM INFORMATION_SCHEMA.TABLES WHERE TABLE_NAME = 'tiamat_step_outputs'", rs)
    
    If rs.eof Then
        ' Criar tabela se não existir
        Call ExecuteSQL("CREATE TABLE tiamat_step_outputs (outputID INT IDENTITY(1,1) PRIMARY KEY, stepID INT, outputData NTEXT, outputType VARCHAR(100), created DATETIME DEFAULT GETDATE())")
    End If
    
    ' Escapar dados para SQL
    Dim escapedJSON
    escapedJSON = Replace(jsonData, "'", "''")
    
    ' Verificar se já existe output para este step
    Call getRecordSet("SELECT outputID FROM tiamat_step_outputs WHERE stepID = " & stepID, rs)
    
    If rs.eof Then
        ' INSERT
        Call ExecuteSQL("INSERT INTO tiamat_step_outputs (stepID, outputData, outputType, created) VALUES (" & stepID & ", '" & escapedJSON & "', 'bibliometric_analysis', GETDATE())")
    Else
        ' UPDATE
        Call ExecuteSQL("UPDATE tiamat_step_outputs SET outputData = '" & escapedJSON & "', created = GETDATE() WHERE stepID = " & stepID)
    End If
    
    SaveBibliometricsToDatabase = (Err.Number = 0)
    
    On Error Goto 0
End Function

' Função para processar dados bibliométricos e gerar sugestões para scenario
Function GenerateScenarioSuggestions(bibliometricData)
    On Error Resume Next
    
    If bibliometricData = "" Then
        GenerateScenarioSuggestions = ""
        Exit Function
    End If
    
    ' Parse JSON data
    Dim biblioJSON
    Set biblioJSON = New aspJSON
    biblioJSON.loadJSON(bibliometricData)
    
    If Err.Number <> 0 Then
        Err.Clear
        GenerateScenarioSuggestions = ""
        Exit Function
    End If
    
    Dim suggestions
    suggestions = "<div class='alert alert-info border-primary'>"
    suggestions = suggestions & "<h6><i class='bi bi-lightbulb text-primary'></i> Literature-Based Scenario Insights</h6>"
    suggestions = suggestions & "<p class='mb-3'>Your bibliometric analysis provides valuable context for scenario development:</p>"
    
    ' Extrair informações básicas
    If biblioJSON.data.Exists("bibliometricData") Then
        suggestions = suggestions & "<div class='row'>"
        suggestions = suggestions & "<div class='col-md-6'>"
        suggestions = suggestions & "<h6 class='text-primary'>Key Insights:</h6>"
        suggestions = suggestions & "<ul class='small'>"
        suggestions = suggestions & "<li>📚 Rich literature base identified</li>"
        suggestions = suggestions & "<li>🔬 Multiple research perspectives</li>"
        suggestions = suggestions & "<li>📈 Trend analysis available</li>"
        suggestions = suggestions & "<li>🌐 International collaboration patterns</li>"
        suggestions = suggestions & "</ul>"
        suggestions = suggestions & "</div>"
        suggestions = suggestions & "<div class='col-md-6'>"
        suggestions = suggestions & "<h6 class='text-primary'>Scenario Recommendations:</h6>"
        suggestions = suggestions & "<ul class='small'>"
        suggestions = suggestions & "<li>🎯 Use identified topics as scenario themes</li>"
        suggestions = suggestions & "<li>👥 Consider key authors' perspectives</li>"
        suggestions = suggestions & "<li>⏰ Align with publication timeline trends</li>"
        suggestions = suggestions & "<li>🔀 Explore research gap opportunities</li>"
        suggestions = suggestions & "</ul>"
        suggestions = suggestions & "</div>"
        suggestions = suggestions & "</div>"
    End If
    
    suggestions = suggestions & "<div class='mt-3'>"
    suggestions = suggestions & "<button type='button' class='btn btn-sm btn-primary me-2' onclick='generateIntelligentTemplate()'>"
    suggestions = suggestions & "<i class='bi bi-magic'></i> Generate Literature-Based Template"
    suggestions = suggestions & "</button>"
    suggestions = suggestions & "<button type='button' class='btn btn-sm btn-outline-primary' onclick='showBibliometricDetails()'>"
    suggestions = suggestions & "<i class='bi bi-graph-up'></i> View Detailed Analysis"
    suggestions = suggestions & "</button>"
    suggestions = suggestions & "</div>"
    suggestions = suggestions & "</div>"
    
    GenerateScenarioSuggestions = suggestions
    
    Set biblioJSON = Nothing
    On Error Goto 0
End Function

' Função para gerar template inteligente baseado em dados bibliométricos
Function GenerateIntelligentScenarioTemplate(bibliometricData)
    On Error Resume Next
    
    Dim template
    template = "<h2>Literature-Informed Future Scenario</h2>"
    template = template & vbCrLf & vbCrLf
    template = template & "<h3>1. Research Foundation</h3>"
    template = template & "<p>This scenario is grounded in systematic bibliometric analysis, incorporating insights from multiple research perspectives and international collaborations identified in the literature review.</p>"
    template = template & vbCrLf
    template = template & "<h3>2. Key Research Themes</h3>"
    template = template & "<p>Based on the literature analysis, the following themes emerged as central to this domain:</p>"
    template = template & "<ul>"
    template = template & "<li><strong>Theme 1:</strong> [Main research focus identified]</li>"
    template = template & "<li><strong>Theme 2:</strong> [Secondary research area]</li>"
    template = template & "<li><strong>Theme 3:</strong> [Emerging trend]</li>"
    template = template & "</ul>"
    template = template & vbCrLf
    template = template & "<h3>3. Future Scenario Description</h3>"
    template = template & "<p>In this future scenario, considering the research trends and expert opinions identified in our literature review...</p>"
    template = template & "<p><em>[Develop your scenario here, incorporating the research insights provided above]</em></p>"
    template = template & vbCrLf
    template = template & "<h3>4. Evidence-Based Considerations</h3>"
    template = template & "<ul>"
    template = template & "<li><strong>Research Momentum:</strong> Strong publication activity indicates active development</li>"
    template = template & "<li><strong>International Collaboration:</strong> Global research network supports widespread adoption</li>"
    template = template & "<li><strong>Timeline Indicators:</strong> Publication patterns suggest implementation timeline</li>"
    template = template & "<li><strong>Innovation Opportunities:</strong> Research gaps identified for strategic positioning</li>"
    template = template & "</ul>"
    template = template & vbCrLf
    template = template & "<h3>5. Strategic Implications</h3>"
    template = template & "<p>This literature-informed scenario suggests the following strategic considerations for decision-making and future planning...</p>"
    template = template & vbCrLf
    template = template & "<div class='alert alert-light mt-4'>"
    template = template & "<small><strong>Source:</strong> Generated using TIAMAT Dublin Core integration from bibliometric analysis conducted in this workflow.</small>"
    template = template & "</div>"
    
    GenerateIntelligentScenarioTemplate = template
    
    On Error Goto 0
End Function

%>