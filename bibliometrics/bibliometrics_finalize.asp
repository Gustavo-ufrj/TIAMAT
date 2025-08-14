<!--#include virtual="/system.asp"-->
<!--#include virtual="/TiamatOutputManager.asp"-->
<%
' Exemplo de como finalizar o método bibliometrics capturando dados com Dublin Core
' Este código deve ser adicionado ao bibliometrics quando finalizar

Dim stepID, action
stepID = Request.QueryString("stepID")
action = Request.QueryString("action")

If action = "finalize" And stepID <> "" And IsNumeric(stepID) Then
    
    ' 1. CAPTURAR DADOS BIBLIOMÉTRICOS
    Dim bibliometricAnalysis
    Set bibliometricAnalysis = Server.CreateObject("Scripting.Dictionary")
    
    ' Buscar todas as referências do step
    Dim rs, rsAuthors, rsTags
    Call getRecordset("SELECT * FROM bibliometrics_references WHERE stepID = " & stepID, rs)
    
    ' Coletar estatísticas básicas
    Dim totalRefs, yearList, authorList, topicList
    totalRefs = 0
    yearList = ""
    authorList = ""
    topicList = ""
    
    If Not rs.eof Then
        While Not rs.eof
            totalRefs = totalRefs + 1
            
            ' Coletar anos
            If rs("year") <> "" Then
                If InStr(yearList, rs("year")) = 0 Then
                    If yearList <> "" Then yearList = yearList & ","
                    yearList = yearList & rs("year")
                End If
            End If
            
            ' Coletar autores desta referência
            Call getRecordset("SELECT name FROM bibliometrics_authors WHERE referenceID = " & rs("referenceID"), rsAuthors)
            While Not rsAuthors.eof
                If InStr(authorList, rsAuthors("name")) = 0 Then
                    If authorList <> "" Then authorList = authorList & ","
                    authorList = authorList & rsAuthors("name")
                End If
                rsAuthors.movenext
            Wend
            
            rs.movenext
        Wend
    End If
    
    ' Coletar tópicos/tags
    Call getRecordset("SELECT DISTINCT bt.tag FROM bibliometrics_tags bt INNER JOIN bibliometrics_reference_x_tag brt ON bt.tagID = brt.tagID INNER JOIN bibliometrics_references br ON brt.referenceID = br.referenceID WHERE br.stepID = " & stepID, rsTags)
    While Not rsTags.eof
        If topicList <> "" Then topicList = topicList & ","
        topicList = topicList & rsTags("tag")
        rsTags.movenext
    Wend
    
    ' 2. CRIAR ESTRUTURA DE DADOS PARA O SCENARIO
    Dim bibliometricDataForScenario
    Set bibliometricDataForScenario = New aspJSON
    
    With bibliometricDataForScenario.data
        .add "totalReferences", totalRefs
        .add "years", Split(yearList, ",")
        .add "authors", Split(authorList, ",")
        .add "topics", Split(topicList, ",")
        .add "analysisDate", FormatDateTime(Now(), 2)
        .add "stepID", stepID
        .add "method", "bibliometrics"
        .add "status", "completed"
    End With
    
    Dim bibliometricJSON
    bibliometricJSON = bibliometricDataForScenario.JSONoutput()
    
    ' 3. CAPTURAR COM DUBLIN CORE
    Dim success
    success = CaptureBibliometricsOutput(stepID, bibliometricJSON)
    
    If success Then
        ' 4. FINALIZAR O STEP
        Call ExecuteSQL("UPDATE tiamat_steps SET status = 4 WHERE stepID = " & stepID)
        
        ' 5. ATIVAR PRÓXIMOS STEPS
        Dim workflowID
        Call getRecordSet("SELECT workflowID FROM tiamat_steps WHERE stepID = " & stepID, rs)
        If Not rs.eof Then
            workflowID = rs("workflowID")
            Call ExecuteSQL("UPDATE tiamat_steps SET status = 3 WHERE workflowID = " & workflowID & " AND status = 2")
        End If
        
        Response.Write "<script>alert('Bibliometric analysis completed with Dublin Core metadata! Scenario steps are now available.'); window.location.href='/manageWorkflow.asp?workflowID=" & workflowID & "';</script>"
    Else
        Response.Write "<script>alert('Error saving bibliometric data.'); history.back();</script>"
    End If
    
    Set bibliometricDataForScenario = Nothing
    Response.End
End If

Response.ContentType = "text/html; charset=utf-8"
%>
<!DOCTYPE html>
<html>
<head>
    <title>Finalize Bibliometrics</title>
    <link href="https://cdn.jsdelivr.net/npm/bootstrap@5.1.3/dist/css/bootstrap.min.css" rel="stylesheet">
</head>
<body>
    <div class="container mt-4">
        <h2>📚 Finalize Bibliometric Analysis</h2>
        
        <div class="alert alert-info">
            <h5>🔗 Dublin Core Integration</h5>
            <p>Finalizing this bibliometric analysis will:</p>
            <ul>
                <li>✅ Capture all references with Dublin Core metadata</li>
                <li>✅ Generate analysis summary for scenario development</li>
                <li>✅ Activate scenario steps in this workflow</li>
                <li>✅ Enable literature-based scenario suggestions</li>
            </ul>
        </div>
        
        <%
        ' Mostrar resumo dos dados que serão capturados
        If stepID <> "" And IsNumeric(stepID) Then
            Call getRecordset("SELECT COUNT(*) as total FROM bibliometrics_references WHERE stepID = " & stepID, rs)
            If Not rs.eof Then
                Response.Write "<div class='card'>"
                Response.Write "<div class='card-header'><h6>📊 Analysis Summary</h6></div>"
                Response.Write "<div class='card-body'>"
                Response.Write "<p><strong>Total References:</strong> " & rs("total") & "</p>"
                
                ' Mostrar anos
                Call getRecordset("SELECT DISTINCT year FROM bibliometrics_references WHERE stepID = " & stepID & " AND year IS NOT NULL ORDER BY year", rs)
                If Not rs.eof Then
                    Response.Write "<p><strong>Publication Years:</strong> "
                    Dim years
                    years = ""
                    While Not rs.eof
                        If years <> "" Then years = years & ", "
                        years = years & rs("year")
                        rs.movenext
                    Wend
                    Response.Write years & "</p>"
                End If
                
                ' Mostrar top autores
                Call getRecordset("SELECT TOP 5 ba.name, COUNT(*) as count FROM bibliometrics_authors ba INNER JOIN bibliometrics_references br ON ba.referenceID = br.referenceID WHERE br.stepID = " & stepID & " GROUP BY ba.name ORDER BY COUNT(*) DESC", rs)
                If Not rs.eof Then
                    Response.Write "<p><strong>Top Authors:</strong> "
                    Dim authors
                    authors = ""
                    While Not rs.eof
                        If authors <> "" Then authors = authors & ", "
                        authors = authors & rs("name") & " (" & rs("count") & ")"
                        rs.movenext
                    Wend
                    Response.Write authors & "</p>"
                End If
                
                ' Mostrar tópicos
                Call getRecordset("SELECT DISTINCT bt.tag FROM bibliometrics_tags bt INNER JOIN bibliometrics_reference_x_tag brt ON bt.tagID = brt.tagID INNER JOIN bibliometrics_references br ON brt.referenceID = br.referenceID WHERE br.stepID = " & stepID, rs)
                If Not rs.eof Then
                    Response.Write "<p><strong>Research Topics:</strong> "
                    Dim topics
                    topics = ""
                    While Not rs.eof
                        If topics <> "" Then topics = topics & ", "
                        topics = topics & rs("tag")
                        rs.movenext
                    Wend
                    Response.Write topics & "</p>"
                End If
                
                Response.Write "</div>"
                Response.Write "</div>"
            End If
        End If
        %>
        
        <div class="mt-4">
            <button class="btn btn-success btn-lg me-3" onclick="finalizeAnalysis()">
                <i class="bi bi-check-circle"></i> Finalize Analysis with Dublin Core
            </button>
            <button class="btn btn-secondary" onclick="history.back()">
                <i class="bi bi-arrow-left"></i> Back
            </button>
        </div>
        
        <div class="mt-4 alert alert-light">
            <h6>🎯 Next Steps After Finalization:</h6>
            <ol>
                <li>Go to the <strong>Scenario</strong> step in this workflow</li>
                <li>Click <strong>"Add Scenario"</strong></li>
                <li>Use the <strong>"Generate Literature-Based Template"</strong> button</li>
                <li>Create scenarios enriched with your bibliometric insights!</li>
            </ol>
        </div>
    </div>
    
    <script>
    function finalizeAnalysis() {
        if (confirm('This will finalize the bibliometric analysis and activate scenario steps. Continue?')) {
            window.location.href = 'bibliometrics_finalize.asp?action=finalize&stepID=<%=stepID%>';
        }
    }
    </script>
</body>
</html>