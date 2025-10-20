<!--#include virtual="/system.asp"-->
<!--#include virtual="/checkstep.asp"-->
<!--#include virtual="/TiamatOutputManager.asp"-->
<%
' ===============================================================================
' bibliometrics_finalize.asp - Finalização com Integração Dublin Core
' ===============================================================================

Response.ContentType = "text/html; charset=utf-8"

Dim stepID
stepID = request.querystring("stepID")

' Verificar se é POST (finalizando)
If request.ServerVariables("REQUEST_METHOD") = "POST" And stepID <> "" And IsNumeric(stepID) Then
    On Error Resume Next
    
    ' 1. COLETAR DADOS BIBLIOMÉTRICOS
    Dim rs, totalRefs, authorList, yearList, topicList
    totalRefs = 0
    authorList = ""
    yearList = ""
    topicList = ""
    
    ' Verificar se existe tabela Dublin Core
    Call getRecordSet("SELECT TABLE_NAME FROM INFORMATION_SCHEMA.TABLES WHERE TABLE_NAME = 'T_FTA_METHOD_BIBLIOMETRICS_DUBLIN_CORE'", rs)
    Dim hasDublinCoreTable
    hasDublinCoreTable = (not rs.eof)
    
    If hasDublinCoreTable Then
        ' Usar dados Dublin Core
        Call getRecordSet("SELECT COUNT(*) as total FROM T_FTA_METHOD_BIBLIOMETRICS_DUBLIN_CORE WHERE stepID = " & stepID, rs)
        If Not rs.eof Then totalRefs = rs("total")
        
        ' Coletar criadores únicos
        Call getRecordSet("SELECT DISTINCT dc_creator FROM T_FTA_METHOD_BIBLIOMETRICS_DUBLIN_CORE WHERE stepID = " & stepID & " AND dc_creator IS NOT NULL ORDER BY dc_creator", rs)
        While Not rs.eof
            If authorList <> "" Then authorList = authorList & ","
            authorList = authorList & rs("dc_creator")
            rs.movenext
        Wend
        
        ' Coletar anos únicos
        Call getRecordSet("SELECT DISTINCT SUBSTRING(dc_date, 1, 4) as year FROM T_FTA_METHOD_BIBLIOMETRICS_DUBLIN_CORE WHERE stepID = " & stepID & " AND dc_date IS NOT NULL ORDER BY year", rs)
        While Not rs.eof
            If yearList <> "" Then yearList = yearList & ","
            yearList = yearList & rs("year")
            rs.movenext
        Wend
        
        ' Coletar tópicos únicos
        Call getRecordSet("SELECT DISTINCT dc_subject FROM T_FTA_METHOD_BIBLIOMETRICS_DUBLIN_CORE WHERE stepID = " & stepID & " AND dc_subject IS NOT NULL ORDER BY dc_subject", rs)
        While Not rs.eof
            If topicList <> "" Then topicList = topicList & ","
            topicList = topicList & rs("dc_subject")
            rs.movenext
        Wend
        
    Else
        ' Fallback para tabela antiga
        Call getRecordSet("SELECT COUNT(*) as total FROM T_FTA_METHOD_BIBLIOMETRICS WHERE stepID = " & stepID, rs)
        If Not rs.eof Then totalRefs = rs("total")
        
        Call getRecordSet("SELECT DISTINCT email FROM T_FTA_METHOD_BIBLIOMETRICS WHERE stepID = " & stepID & " AND email IS NOT NULL ORDER BY email", rs)
        While Not rs.eof
            If authorList <> "" Then authorList = authorList & ","
            authorList = authorList & rs("email")
            rs.movenext
        Wend
        
        Call getRecordSet("SELECT DISTINCT year FROM T_FTA_METHOD_BIBLIOMETRICS WHERE stepID = " & stepID & " AND year IS NOT NULL ORDER BY year", rs)
        While Not rs.eof
            If yearList <> "" Then yearList = yearList & ","
            yearList = yearList & rs("year")
            rs.movenext
        Wend
    End If
    
    ' 2. CRIAR ESTRUTURA DE DADOS PARA O SCENARIO COM DUBLIN CORE
    Dim bibliometricDataForScenario
    Set bibliometricDataForScenario = New aspJSON
    
    With bibliometricDataForScenario.data
        .add "totalReferences", totalRefs
        .add "authors", Split(authorList, ",")
        .add "years", Split(yearList, ",")
        .add "topics", Split(topicList, ",")
        .add "analysisDate", FormatDateTime(Now(), 2)
        .add "stepID", stepID
        .add "method", "bibliometrics"
        .add "status", "completed"
        .add "dublinCoreEnabled", hasDublinCoreTable
        
        ' Adicionar metadados Dublin Core se disponível
        If hasDublinCoreTable Then
            .add "dublinCoreMetadata", bibliometricDataForScenario.Collection()
            With .item("dublinCoreMetadata")
                .add "creators", authorList
                .add "subjects", topicList
                .add "temporalCoverage", yearList
                .add "totalRecords", totalRefs
                .add "metadataStandard", "Dublin Core Metadata Element Set"
                .add "harvestDate", FormatDateTime(Now(), 2)
            End With
        End If
    End With
    
    Dim bibliometricJSON
    bibliometricJSON = bibliometricDataForScenario.JSONoutput()
    
    ' 3. CAPTURAR COM DUBLIN CORE USANDO O TIAMAT OUTPUT MANAGER
    Dim success
    success = CaptureBibliometricsOutput(stepID, bibliometricJSON)
    
    If success Then
        ' 4. FINALIZAR O STEP
        Call ExecuteSQL("UPDATE tiamat_steps SET status = 4, completed_at = GETDATE() WHERE stepID = " & stepID)
        
        ' 5. ATIVAR PRÓXIMOS STEPS NO WORKFLOW
        Dim workflowID
        Call getRecordSet("SELECT workflowID FROM tiamat_steps WHERE stepID = " & stepID, rs)
        If Not rs.eof Then
            workflowID = rs("workflowID")
            ' Ativar steps que dependem de bibliometrics (como scenario)
            Call ExecuteSQL("UPDATE tiamat_steps SET status = 3 WHERE workflowID = " & workflowID & " AND status = 2")
        End If
        
        ' 6. LOG DA INTEGRAÇÃO DUBLIN CORE
        Dim logMessage
        If hasDublinCoreTable Then
            logMessage = "Bibliometric analysis completed with Dublin Core metadata integration. " & totalRefs & " references processed with full metadata standardization."
        Else
            logMessage = "Bibliometric analysis completed with basic metadata. Consider upgrading to Dublin Core for enhanced integration."
        End If
        
        Response.Write "<script>"
        Response.Write "alert('✅ " & logMessage & "\\n\\n📊 Results: " & totalRefs & " references processed\\n🔗 Scenario steps are now available!');"
        Response.Write "window.location.href='/manageWorkflow.asp?workflowID=" & workflowID & "';"
        Response.Write "</script>"
    Else
        Response.Write "<script>alert('❌ Error saving bibliometric data. Please try again.'); history.back();</script>"
    End If
    
    Set bibliometricDataForScenario = Nothing
    Response.End
End If

' Se não é POST, mostrar interface de finalização
%>
<!DOCTYPE html>
<html lang="pt-BR">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Finalize Bibliometric Analysis</title>
    <link href="https://cdn.jsdelivr.net/npm/bootstrap@5.1.3/dist/css/bootstrap.min.css" rel="stylesheet">
    <link rel="stylesheet" href="https://cdn.jsdelivr.net/npm/bootstrap-icons@1.7.2/font/bootstrap-icons.css">
    <style>
        .dublin-core-badge {
            background: linear-gradient(135deg, #007bff 0%, #0056b3 100%);
            color: white;
            padding: 0.5rem 1rem;
            border-radius: 50px;
            font-size: 0.875rem;
        }
        .metadata-card {
            border-left: 4px solid #007bff;
            background: linear-gradient(135deg, #f8f9ff 0%, #e3f2fd 100%);
        }
    </style>
</head>
<body class="bg-light">
    <div class="container mt-4">
        <div class="row justify-content-center">
            <div class="col-lg-8">
                <div class="card shadow">
                    <div class="card-header bg-primary text-white">
                        <h3 class="mb-0">
                            <i class="bi bi-check-circle-fill me-2"></i>
                            Finalize Bibliometric Analysis
                        </h3>
                        <small class="opacity-75">Complete your analysis and enable scenario development</small>
                    </div>
                    <div class="card-body">
                        
                        <!-- Dublin Core Status -->
                        <%
                        Dim hasDublinCore, dublinCoreStatus
                        Call getRecordSet("SELECT TABLE_NAME FROM INFORMATION_SCHEMA.TABLES WHERE TABLE_NAME = 'T_FTA_METHOD_BIBLIOMETRICS_DUBLIN_CORE'", rs)
                        hasDublinCore = (not rs.eof)
                        
                        If hasDublinCore Then
                            Call getRecordSet("SELECT COUNT(*) as total FROM T_FTA_METHOD_BIBLIOMETRICS_DUBLIN_CORE WHERE stepID = " & stepID, rs)
                            If not rs.eof And rs("total") > 0 Then
                                dublinCoreStatus = "enabled"
                            Else
                                dublinCoreStatus = "available"
                            End If
                        Else
                            dublinCoreStatus = "unavailable"
                        End If
                        %>
                        
                        <div class="alert alert-info metadata-card">
                            <div class="d-flex align-items-center justify-content-between">
                                <div>
                                    <h5 class="alert-heading mb-2">
                                        🔗 Dublin Core Integration Status
                                    </h5>
                                    <% If dublinCoreStatus = "enabled" Then %>
                                        <span class="dublin-core-badge">
                                            <i class="bi bi-check-circle-fill me-1"></i>
                                            Dublin Core Enabled
                                        </span>
                                        <p class="mt-2 mb-0">
                                            <small class="text-muted">
                                                Your bibliometric data includes full Dublin Core metadata, enabling enhanced scenario development with standardized metadata elements.
                                            </small>
                                        </p>
                                    <% ElseIf dublinCoreStatus = "available" Then %>
                                        <span class="badge bg-warning text-dark">
                                            <i class="bi bi-exclamation-triangle-fill me-1"></i>
                                            Dublin Core Available
                                        </span>
                                        <p class="mt-2 mb-0">
                                            <small class="text-muted">
                                                Dublin Core table exists but no data found for this step. Basic metadata will be used for scenario integration.
                                            </small>
                                        </p>
                                    <% Else %>
                                        <span class="badge bg-secondary">
                                            <i class="bi bi-info-circle-fill me-1"></i>
                                            Basic Metadata
                                        </span>
                                        <p class="mt-2 mb-0">
                                            <small class="text-muted">
                                                Using basic bibliometric metadata. Consider upgrading to Dublin Core for enhanced scenario integration capabilities.
                                            </small>
                                        </p>
                                    <% End If %>
                                </div>
                                <div class="text-end">
                                    <i class="bi bi-diagram-3 text-primary" style="font-size: 2rem;"></i>
                                </div>
                            </div>
                        </div>

                        <!-- Analysis Summary -->
                        <div class="row mb-4">
                            <div class="col-md-12">
                                <h5 class="mb-3">📊 Analysis Summary</h5>
                                <div class="card">
                                    <div class="card-body">
                                        <%
                                        ' Mostrar resumo dos dados que serão capturados
                                        If stepID <> "" And IsNumeric(stepID) Then
                                            Dim summaryRs, totalCount, uniqueAuthors, yearRange, subjectCount
                                            
                                            If hasDublinCore Then
                                                ' Dados Dublin Core
                                                Call getRecordSet("SELECT COUNT(*) as total FROM T_FTA_METHOD_BIBLIOMETRICS_DUBLIN_CORE WHERE stepID = " & stepID, summaryRs)
                                                If Not summaryRs.eof Then totalCount = summaryRs("total")
                                                
                                                Call getRecordSet("SELECT COUNT(DISTINCT dc_creator) as authors FROM T_FTA_METHOD_BIBLIOMETRICS_DUBLIN_CORE WHERE stepID = " & stepID & " AND dc_creator IS NOT NULL", summaryRs)
                                                If Not summaryRs.eof Then uniqueAuthors = summaryRs("authors")
                                                
                                                Call getRecordSet("SELECT MIN(SUBSTRING(dc_date, 1, 4)) as min_year, MAX(SUBSTRING(dc_date, 1, 4)) as max_year FROM T_FTA_METHOD_BIBLIOMETRICS_DUBLIN_CORE WHERE stepID = " & stepID & " AND dc_date IS NOT NULL", summaryRs)
                                                If Not summaryRs.eof And summaryRs("min_year") <> "" And summaryRs("max_year") <> "" Then
                                                    yearRange = summaryRs("min_year") & " - " & summaryRs("max_year")
                                                End If
                                                
                                                Call getRecordSet("SELECT COUNT(DISTINCT dc_subject) as subjects FROM T_FTA_METHOD_BIBLIOMETRICS_DUBLIN_CORE WHERE stepID = " & stepID & " AND dc_subject IS NOT NULL", summaryRs)
                                                If Not summaryRs.eof Then subjectCount = summaryRs("subjects")
                                            Else
                                                ' Dados básicos
                                                Call getRecordSet("SELECT COUNT(*) as total FROM T_FTA_METHOD_BIBLIOMETRICS WHERE stepID = " & stepID, summaryRs)
                                                If Not summaryRs.eof Then totalCount = summaryRs("total")
                                                
                                                Call getRecordSet("SELECT COUNT(DISTINCT email) as authors FROM T_FTA_METHOD_BIBLIOMETRICS WHERE stepID = " & stepID & " AND email IS NOT NULL", summaryRs)
                                                If Not summaryRs.eof Then uniqueAuthors = summaryRs("authors")
                                                
                                                Call getRecordSet("SELECT MIN(year) as min_year, MAX(year) as max_year FROM T_FTA_METHOD_BIBLIOMETRICS WHERE stepID = " & stepID & " AND year IS NOT NULL", summaryRs)
                                                If Not summaryRs.eof And summaryRs("min_year") <> "" And summaryRs("max_year") <> "" Then
                                                    yearRange = summaryRs("min_year") & " - " & summaryRs("max_year")
                                                End If
                                            End If
                                        %>
                                        
                                        <div class="row text-center">
                                            <div class="col-md-3">
                                                <div class="p-3 border rounded bg-light">
                                                    <div class="fs-2 fw-bold text-primary"><%=totalCount%></div>
                                                    <small class="text-muted">Total References</small>
                                                </div>
                                            </div>
                                            <div class="col-md-3">
                                                <div class="p-3 border rounded bg-light">
                                                    <div class="fs-2 fw-bold text-success"><%=uniqueAuthors%></div>
                                                    <small class="text-muted">Unique Authors</small>
                                                </div>
                                            </div>
                                            <div class="col-md-3">
                                                <div class="p-3 border rounded bg-light">
                                                    <div class="fs-6 fw-bold text-info"><%=yearRange%></div>
                                                    <small class="text-muted">Year Range</small>
                                                </div>
                                            </div>
                                            <div class="col-md-3">
                                                <div class="p-3 border rounded bg-light">
                                                    <div class="fs-2 fw-bold text-warning"><%=subjectCount%></div>
                                                    <small class="text-muted">Subjects</small>
                                                </div>
                                            </div>
                                        </div>
                                        
                                        <% End If %>
                                    </div>
                                </div>
                            </div>
                        </div>

                        <!-- Integration Benefits -->
                        <div class="row mb-4">
                            <div class="col-md-12">
                                <h5 class="mb-3">🚀 What happens when you finalize?</h5>
                                <div class="row">
                                    <div class="col-md-6">
                                        <div class="card h-100 border-primary">
                                            <div class="card-body">
                                                <h6 class="card-title text-primary">
                                                    <i class="bi bi-database-fill me-2"></i>
                                                    Data Capture
                                                </h6>
                                                <ul class="list-unstyled small">
                                                    <li><i class="bi bi-check text-success me-1"></i> Capture all bibliometric data</li>
                                                    <% If dublinCoreStatus = "enabled" Then %>
                                                    <li><i class="bi bi-check text-success me-1"></i> Generate Dublin Core metadata</li>
                                                    <li><i class="bi bi-check text-success me-1"></i> Standardize metadata elements</li>
                                                    <% End If %>
                                                    <li><i class="bi bi-check text-success me-1"></i> Create analysis summary</li>
                                                    <li><i class="bi bi-check text-success me-1"></i> Generate JSON-LD output</li>
                                                </ul>
                                            </div>
                                        </div>
                                    </div>
                                    <div class="col-md-6">
                                        <div class="card h-100 border-success">
                                            <div class="card-body">
                                                <h6 class="card-title text-success">
                                                    <i class="bi bi-arrow-right-circle-fill me-2"></i>
                                                    Workflow Activation
                                                </h6>
                                                <ul class="list-unstyled small">
                                                    <li><i class="bi bi-check text-success me-1"></i> Activate scenario development steps</li>
                                                    <li><i class="bi bi-check text-success me-1"></i> Enable literature-based templates</li>
                                                    <% If dublinCoreStatus = "enabled" Then %>
                                                    <li><i class="bi bi-check text-success me-1"></i> Provide Dublin Core insights</li>
                                                    <li><i class="bi bi-check text-success me-1"></i> Generate smart suggestions</li>
                                                    <% End If %>
                                                    <li><i class="bi bi-check text-success me-1"></i> Update workflow status</li>
                                                </ul>
                                            </div>
                                        </div>
                                    </div>
                                </div>
                            </div>
                        </div>

                        <!-- Sample Dublin Core Preview -->
                        <% If dublinCoreStatus = "enabled" Then %>
                        <div class="row mb-4">
                            <div class="col-md-12">
                                <h5 class="mb-3">🔍 Dublin Core Preview</h5>
                                <div class="card">
                                    <div class="card-body">
                                        <small class="text-muted">Sample of Dublin Core elements that will be captured:</small>
                                        <div class="row mt-2">
                                            <%
                                            ' Mostrar preview dos dados Dublin Core
                                            Call getRecordSet("SELECT TOP 1 dc_title, dc_creator, dc_subject, dc_publisher, dc_date, dc_type FROM T_FTA_METHOD_BIBLIOMETRICS_DUBLIN_CORE WHERE stepID = " & stepID, rs)
                                            If Not rs.eof Then
                                            %>
                                            <div class="col-md-6">
                                                <div class="small">
                                                    <strong>dc:title:</strong> <%=Left(rs("dc_title"), 50) & "..."%><br>
                                                    <strong>dc:creator:</strong> <%=rs("dc_creator")%><br>
                                                    <strong>dc:subject:</strong> <%=rs("dc_subject")%><br>
                                                </div>
                                            </div>
                                            <div class="col-md-6">
                                                <div class="small">
                                                    <strong>dc:publisher:</strong> <%=rs("dc_publisher")%><br>
                                                    <strong>dc:date:</strong> <%=rs("dc_date")%><br>
                                                    <strong>dc:type:</strong> <%=rs("dc_type")%><br>
                                                </div>
                                            </div>
                                            <% End If %>
                                        </div>
                                    </div>
                                </div>
                            </div>
                        </div>
                        <% End If %>

                        <!-- Action Buttons -->
                        <form method="POST" action="?stepID=<%=stepID%>">
                            <div class="d-grid gap-2 d-md-flex justify-content-md-end">
                                <button type="button" class="btn btn-outline-secondary" onclick="history.back()">
                                    <i class="bi bi-arrow-left me-1"></i>
                                    Back
                                </button>
                                <button type="submit" class="btn btn-primary btn-lg" onclick="return confirmFinalization()">
                                    <i class="bi bi-check-circle-fill me-2"></i>
                                    Finalize Analysis & Activate Scenarios
                                </button>
                            </div>
                        </form>
                    </div>
                </div>
            </div>
        </div>
    </div>

    <script>
    function confirmFinalization() {
        var dublinCoreStatus = '<%=dublinCoreStatus%>';
        var message = "🔄 Are you ready to finalize this bibliometric analysis?\n\n";
        message += "This will:\n";
        message += "✅ Capture all bibliometric data\n";
        
        if (dublinCoreStatus === 'enabled') {
            message += "✅ Generate Dublin Core metadata\n";
            message += "✅ Enable enhanced scenario features\n";
        } else {
            message += "⚠️ Use basic metadata (consider Dublin Core upgrade)\n";
        }
        
        message += "✅ Activate scenario development steps\n";
        message += "✅ Update workflow status\n\n";
        message += "Continue with finalization?";
        
        return confirm(message);
    }

    // Auto-scroll to action buttons on load
    window.addEventListener('load', function() {
        setTimeout(function() {
            document.querySelector('.btn-primary').scrollIntoView({ 
                behavior: 'smooth', 
                block: 'center' 
            });
        }, 500);
    });
    </script>
</body>
</html>