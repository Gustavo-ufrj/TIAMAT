<!--#include virtual="/system.asp"-->
<%
' fixScenarioFinalize.asp - Debug e correção da finalização de scenarios
%>
<!DOCTYPE html>
<html>
<head>
    <title>Fix Scenario Finalize</title>
    <style>
        body { font-family: Arial; padding: 20px; }
        .success { background: #d4edda; padding: 10px; margin: 10px 0; }
        .error { background: #f8d7da; padding: 10px; margin: 10px 0; }
        .info { background: #d1ecf1; padding: 10px; margin: 10px 0; }
        table { border-collapse: collapse; width: 100%; margin: 20px 0; }
        th, td { border: 1px solid #ddd; padding: 8px; }
        th { background: #f4f4f4; }
    </style>
</head>
<body>
    <h1>Debug: Finalização de Scenarios</h1>
    
    <%
    Dim stepID, action
    stepID = Request.QueryString("stepID")
    If stepID = "" Then stepID = "50379"
    action = Request.QueryString("action")
    %>
    
    <div class="info">
        <strong>Step ID:</strong> <%=stepID%>
    </div>
    
    <h2>1. Verificar Cenários Existentes</h2>
    <%
    On Error Resume Next
    
    call getRecordSet("SELECT * FROM T_FTA_METHOD_SCENARIOS WHERE stepID = " & stepID, rs)
    
    If Err.Number = 0 Then
        If Not rs.EOF Then
            Response.Write "<div class='success'>Cenários encontrados:</div>"
            Response.Write "<table>"
            Response.Write "<tr><th>ID</th><th>Nome</th><th>Descrição (preview)</th></tr>"
            
            While Not rs.EOF
                Response.Write "<tr>"
                Response.Write "<td>" & rs("scenarioID") & "</td>"
                Response.Write "<td>" & rs("name") & "</td>"
                Response.Write "<td>" & Left(rs("scenario") & "", 100) & "...</td>"
                Response.Write "</tr>"
                rs.MoveNext
            Wend
            
            Response.Write "</table>"
        Else
            Response.Write "<div class='error'>Nenhum cenário encontrado para step " & stepID & "</div>"
        End If
    Else
        Response.Write "<div class='error'>Erro ao buscar cenários: " & Err.Description & "</div>"
    End If
    Err.Clear
    %>
    
    <h2>2. Verificar Status do Step</h2>
    <%
    Dim status
    status = getStatusStep(stepID)
    Response.Write "<div class='info'>"
    Response.Write "Status atual: <strong>" & status & "</strong><br>"
    Response.Write "STATE_ACTIVE = " & STATE_ACTIVE & "<br>"
    If status = STATE_ACTIVE Then
        Response.Write "✓ Step está ATIVO e pode ser finalizado"
    Else
        Response.Write "✗ Step NÃO está ativo"
    End If
    Response.Write "</div>"
    %>
    
    <h2>3. Testar Finalização</h2>
    <%
    If action = "finalize" Then
        Response.Write "<div class='info'>Tentando finalizar step...</div>"
        
        On Error Resume Next
        
        ' Verificar se tem cenários
        call getRecordSet("SELECT COUNT(*) as total FROM T_FTA_METHOD_SCENARIOS WHERE stepID = " & stepID, rs)
        
        If Not rs.EOF Then
            If rs("total") > 0 Then
                Response.Write "<p>Total de cenários: <strong>" & rs("total") & "</strong></p>"
                
                ' Tentar finalizar
                Call endStep(stepID)
                
                If Err.Number = 0 Then
                    Response.Write "<div class='success'>✓ Step finalizado com sucesso!</div>"
                    Response.Write "<p><a href='/workplace.asp'>Ir para Workplace</a></p>"
                Else
                    Response.Write "<div class='error'>Erro ao finalizar: " & Err.Description & "</div>"
                End If
            Else
                Response.Write "<div class='error'>Não há cenários para finalizar</div>"
            End If
        End If
        
        Err.Clear
        On Error Goto 0
    Else
        %>
        <form method="GET">
            <input type="hidden" name="stepID" value="<%=stepID%>">
            <input type="hidden" name="action" value="finalize">
            <input type="submit" value="Testar Finalização Manual" class="btn btn-warning" style="padding: 10px;">
        </form>
        <% 
    End If
    %>
    
    <h2>4. Verificar Workflow</h2>
    <%
    call getRecordSet("SELECT workflowID FROM T_WORKFLOW_STEP WHERE stepID = " & stepID, rs)
    If Not rs.EOF Then
        Dim workflowID
        workflowID = rs("workflowID")
        Response.Write "<div class='info'>Workflow ID: <strong>" & workflowID & "</strong></div>"
        
        ' Listar todos os steps do workflow
        call getRecordSet("SELECT stepID, methodID FROM T_WORKFLOW_STEP WHERE workflowID = " & workflowID & " ORDER BY stepID", rs)
        Response.Write "<table>"
        Response.Write "<tr><th>Step ID</th><th>Method ID</th><th>Status</th></tr>"
        
        While Not rs.EOF
            Response.Write "<tr>"
            Response.Write "<td>" & rs("stepID") & "</td>"
            Response.Write "<td>" & rs("methodID") & "</td>"
            Response.Write "<td>" & getStatusStep(rs("stepID")) & "</td>"
            Response.Write "</tr>"
            rs.MoveNext
        Wend
        
        Response.Write "</table>"
    End If
    %>
    
    <h2>5. Correção no index.asp</h2>
    <div class="info">
        <p>O problema pode estar no link de finalização. O correto deve ser:</p>
        <pre>
&lt;button onclick="finalizeScenarios()"&gt;Finalizar Cenários&lt;/button&gt;

&lt;script&gt;
function finalizeScenarios() {
    if(confirm('Finalizar todos os cenários?')) {
        window.location.href = 'scenarioActions.asp?action=finalize_scenarios&stepID=<%=stepID%>';
    }
}
&lt;/script&gt;
        </pre>
    </div>
    
    <div style="margin-top: 30px; padding: 20px; background: #f0f0f0;">
        <h3>Links Úteis:</h3>
        <ul>
            <li><a href="index.asp?stepID=<%=stepID%>">Voltar ao Scenarios</a></li>
            <li><a href="scenarioActions.asp?action=finalize_scenarios&stepID=<%=stepID%>">Tentar Finalizar Diretamente</a></li>
            <li><a href="/workplace.asp">Workplace</a></li>
        </ul>
    </div>
    
</body>
</html>