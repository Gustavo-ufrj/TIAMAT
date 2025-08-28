<%
' testScenario.asp - Pagina de debug para identificar problemas
' Coloque este arquivo na pasta /FTA/scenario/ e acesse diretamente
%>
<!DOCTYPE html>
<html>
<head>
    <title>Test Scenario Debug</title>
    <style>
        body { font-family: Arial; padding: 20px; }
        .test { margin: 10px; padding: 10px; border: 1px solid #ccc; }
        .success { background: #d4edda; }
        .error { background: #f8d7da; }
        .info { background: #d1ecf1; }
        pre { background: #f4f4f4; padding: 10px; overflow: auto; }
    </style>
</head>
<body>
    <h1>Scenario Module Debug</h1>
    
    <%
    Dim stepID
    stepID = Request.QueryString("stepID")
    If stepID = "" Then stepID = "50379"
    %>
    
    <div class="test info">
        <strong>Testing with stepID:</strong> <%=stepID%>
    </div>
    
    <!-- Teste 1: Includes -->
    <div class="test">
        <h3>Test 1: Include Files</h3>
        <%
        On Error Resume Next
        %>
        
        <!--#include virtual="/system.asp"-->
        <% If Err.Number = 0 Then %>
            <div class="success">? system.asp loaded successfully</div>
        <% Else %>
            <div class="error">? Error loading system.asp: <%=Err.Description%></div>
        <% End If %>
        <% Err.Clear %>
        
        <!--#include virtual="/checkstep.asp"-->
        <% If Err.Number = 0 Then %>
            <div class="success">? checkstep.asp loaded successfully</div>
        <% Else %>
            <div class="error">? Error loading checkstep.asp: <%=Err.Description%></div>
        <% End If %>
        <% Err.Clear %>
        
        <!--#include file="INC_SCENARIO.inc"-->
        <% If Err.Number = 0 Then %>
            <div class="success">? INC_SCENARIO.inc loaded successfully</div>
        <% Else %>
            <div class="error">? Error loading INC_SCENARIO.inc: <%=Err.Description%></div>
        <% End If %>
        <% Err.Clear %>
    </div>
    
    <!-- Teste 2: Database Connection -->
    <div class="test">
        <h3>Test 2: Database Connection</h3>
        <%
        On Error Resume Next
        Dim testRS
        Set testRS = Server.CreateObject("ADODB.Recordset")
        If Err.Number = 0 Then
            Response.Write "<div class='success'>? ADODB.Recordset created</div>"
        Else
            Response.Write "<div class='error'>? Error creating recordset: " & Err.Description & "</div>"
        End If
        Err.Clear
        %>
    </div>
    
    <!-- Teste 3: Table Check -->
    <div class="test">
        <h3>Test 3: Check Tables</h3>
        <%
        On Error Resume Next
        
        ' Testar T_FTA_METHOD_SCENARIOS
        call getRecordSet("SELECT COUNT(*) as total FROM T_FTA_METHOD_SCENARIOS WHERE stepID = " & stepID, rs)
        If Err.Number = 0 Then
            If Not rs.EOF Then
                Response.Write "<div class='success'>? T_FTA_METHOD_SCENARIOS accessible - " & rs("total") & " records for step " & stepID & "</div>"
            Else
                Response.Write "<div class='info'>? T_FTA_METHOD_SCENARIOS accessible - 0 records</div>"
            End If
        Else
            Response.Write "<div class='error'>? Error accessing T_FTA_METHOD_SCENARIOS: " & Err.Description & "</div>"
        End If
        Err.Clear
        
        ' Testar T_WORKFLOW_STEP
        call getRecordSet("SELECT workflowID FROM T_WORKFLOW_STEP WHERE stepID = " & stepID, rs)
        If Err.Number = 0 Then
            If Not rs.EOF Then
                Response.Write "<div class='success'>? T_WORKFLOW_STEP accessible - workflowID: " & rs("workflowID") & "</div>"
            Else
                Response.Write "<div class='error'>? No workflow found for stepID " & stepID & "</div>"
            End If
        Else
            Response.Write "<div class='error'>? Error accessing T_WORKFLOW_STEP: " & Err.Description & "</div>"
        End If
        Err.Clear
        
        ' Testar T_FTA_METHOD_BIBLIOMETRICS
        call getRecordSet("SELECT COUNT(*) as total FROM T_FTA_METHOD_BIBLIOMETRICS", rs)
        If Err.Number = 0 Then
            If Not rs.EOF Then
                Response.Write "<div class='success'>? T_FTA_METHOD_BIBLIOMETRICS accessible - Total records: " & rs("total") & "</div>"
            End If
        Else
            Response.Write "<div class='error'>? Error accessing T_FTA_METHOD_BIBLIOMETRICS: " & Err.Description & "</div>"
        End If
        Err.Clear
        %>
    </div>
    
    <!-- Teste 4: Functions -->
    <div class="test">
        <h3>Test 4: SQL Functions</h3>
        <%
        On Error Resume Next
        
        ' Testar funcao SQL_CONSULTA_SCENARIOS
        Dim sqlTest
        sqlTest = SQL_CONSULTA_SCENARIOS(stepID)
        If Err.Number = 0 Then
            Response.Write "<div class='success'>? SQL_CONSULTA_SCENARIOS function works</div>"
            Response.Write "<pre>" & sqlTest & "</pre>"
        Else
            Response.Write "<div class='error'>? Error in SQL_CONSULTA_SCENARIOS: " & Err.Description & "</div>"
        End If
        Err.Clear
        %>
    </div>
    
    <!-- Teste 5: getStatusStep -->
    <div class="test">
        <h3>Test 5: Step Status</h3>
        <%
        On Error Resume Next
        Dim stepStatus
        stepStatus = getStatusStep(stepID)
        If Err.Number = 0 Then
            Response.Write "<div class='success'>? getStatusStep works - Status: " & stepStatus & "</div>"
            If stepStatus = STATE_ACTIVE Then
                Response.Write "<div class='info'>Step is ACTIVE</div>"
            Else
                Response.Write "<div class='info'>Step is NOT active</div>"
            End If
        Else
            Response.Write "<div class='error'>? Error in getStatusStep: " & Err.Description & "</div>"
        End If
        Err.Clear
        %>
    </div>
    
    <!-- Teste 6: Bibliometric Data -->
    <div class="test">
        <h3>Test 6: Find Bibliometric Data</h3>
        <%
        On Error Resume Next
        
        ' Buscar workflow
        Dim workflowID
        call getRecordSet("SELECT workflowID FROM T_WORKFLOW_STEP WHERE stepID = " & stepID, rs)
        If Not rs.EOF Then
            workflowID = rs("workflowID")
            Response.Write "<div class='info'>WorkflowID: " & workflowID & "</div>"
            
            ' Buscar steps anteriores
            call getRecordSet("SELECT stepID FROM T_WORKFLOW_STEP WHERE workflowID = " & workflowID & " AND stepID < " & stepID & " ORDER BY stepID", rs)
            Response.Write "<div class='info'>Previous steps in workflow:</div>"
            Response.Write "<ul>"
            While Not rs.EOF
                Response.Write "<li>Step " & rs("stepID") & "</li>"
                rs.MoveNext
            Wend
            Response.Write "</ul>"
            
            ' Buscar bibliometrics
            call getRecordSet("SELECT b.stepID, COUNT(*) as total FROM T_FTA_METHOD_BIBLIOMETRICS b " & _
                            "INNER JOIN T_WORKFLOW_STEP s ON b.stepID = s.stepID " & _
                            "WHERE s.workflowID = " & workflowID & " AND b.stepID < " & stepID & _
                            " GROUP BY b.stepID", rs)
            
            If Not rs.EOF Then
                Response.Write "<div class='success'>? Found bibliometric data:</div>"
                Response.Write "<ul>"
                While Not rs.EOF
                    Response.Write "<li>Step " & rs("stepID") & ": " & rs("total") & " references</li>"
                    rs.MoveNext
                Wend
                Response.Write "</ul>"
            Else
                Response.Write "<div class='info'>No bibliometric data found in previous steps</div>"
            End If
        End If
        Err.Clear
        %>
    </div>
    
    <div class="test info">
        <h3>Summary</h3>
        <p>If all tests pass, the scenario module should work correctly.</p>
        <p>If there are errors, fix them in the order they appear.</p>
        <p>
            <a href="manageScenario.asp?stepID=<%=stepID%>">Try opening manageScenario.asp</a> |
            <a href="index.asp?stepID=<%=stepID%>">Go to index.asp</a>
        </p>
    </div>
    
</body>
</html>