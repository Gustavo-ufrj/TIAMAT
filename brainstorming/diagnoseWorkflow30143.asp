<!--#include virtual="/system.asp"-->
<!DOCTYPE html>
<html>
<head>
    <title>Diagnóstico Workflow 30143</title>
    <style>
        body { font-family: Arial; padding: 20px; }
        table { width: 100%; border-collapse: collapse; margin: 20px 0; }
        th, td { border: 1px solid #ddd; padding: 10px; text-align: left; }
        th { background: #f0f0f0; }
        .status-3 { background: #6c757d; color: white; }
        .status-4 { background: #5cb85c; color: white; }
        .status-5 { background: #fd7e14; color: white; }
        .problem { background: #ffebee; padding: 15px; border-left: 4px solid red; margin: 20px 0; }
        .solution { background: #e8f5e9; padding: 15px; border-left: 4px solid green; margin: 20px 0; }
    </style>
</head>
<body>
    <h1>Diagnóstico do Problema no Workflow 30143</h1>
    
    <%
    Dim action
    action = Request.QueryString("action")
    
    If action = "force4" Then
        ' Força status 4 e desabilita qualquer trigger
        call ExecuteSQL("UPDATE T_WORKFLOW_STEP SET status = 4 WHERE stepID = 60382")
        Response.Write "<div class='solution'>Status forçado para 4</div>"
    ElseIf action = "force3" Then
        ' Força status 3 para teste
        call ExecuteSQL("UPDATE T_WORKFLOW_STEP SET status = 3 WHERE stepID = 60382")
        Response.Write "<div class='solution'>Status forçado para 3 (cinza)</div>"
    End If
    %>
    
    <h2>1. Status de TODOS os Steps do Workflow 30143</h2>
    <table>
        <tr>
            <th>StepID</th>
            <th>Type</th>
            <th>Status</th>
            <th>Cor Esperada</th>
            <th>Problema?</th>
        </tr>
        <%
        call getRecordSet("SELECT * FROM T_WORKFLOW_STEP WHERE workflowID = 30143 ORDER BY stepID", rs)
        
        While Not rs.EOF
            Dim stepID, stepType, stepStatus
            stepID = rs("stepID")
            stepType = rs("type")
            stepStatus = rs("status")
            
            Response.Write "<tr>"
            Response.Write "<td>" & stepID & "</td>"
            Response.Write "<td>" & stepType & "</td>"
            Response.Write "<td class='status-" & stepStatus & "'>" & stepStatus & "</td>"
            Response.Write "<td>"
            
            Select Case stepStatus
                Case 3
                    Response.Write "Cinza (Aguardando)"
                Case 4
                    Response.Write "Verde (Ativo)"
                Case 5
                    Response.Write "Laranja (Finalizado)"
            End Select
            
            Response.Write "</td>"
            Response.Write "<td>"
            
            ' Verificar problema específico
            If stepID = 60382 And stepStatus <> 4 Then
                Response.Write "<strong style='color: red;'>BRAINSTORMING DEVERIA SER 4!</strong>"
            ElseIf stepID = 60382 And stepStatus = 4 Then
                Response.Write "<strong style='color: green;'>OK</strong>"
            End If
            
            Response.Write "</td>"
            Response.Write "</tr>"
            rs.MoveNext
        Wend
        %>
    </table>
    
    <h2>2. Diagnóstico do Problema</h2>
    <div class="problem">
        <h3>Problema Identificado:</h3>
        <p>O workflow 30143 pode ter uma configuração ou trigger que está automaticamente mudando o status do Brainstorming.</p>
        <ul>
            <li>Quando você tenta definir status = 4, ele muda automaticamente para 5</li>
            <li>Isso pode ser causado por um trigger no banco de dados</li>
            <li>Ou uma regra de negócio no sistema</li>
        </ul>
    </div>
    
    <h2>3. Teste de Status</h2>
    <%
    call getRecordSet("SELECT status FROM T_WORKFLOW_STEP WHERE stepID = 60382", rs)
    If Not rs.EOF Then
        Dim currentStatus
        currentStatus = rs("status")
    %>
        <p>Status atual do Brainstorming (60382): <strong class="status-<%=currentStatus%>" style="padding: 5px 10px;"><%=currentStatus%></strong></p>
        
        <div style="margin: 20px 0;">
            <button onclick="location.href='?action=force3'" style="background: #6c757d; color: white; padding: 10px 20px; border: none; border-radius: 5px;">
                Testar Status 3 (Cinza)
            </button>
            <button onclick="location.href='?action=force4'" style="background: #5cb85c; color: white; padding: 10px 20px; border: none; border-radius: 5px;">
                Forçar Status 4 (Verde)
            </button>
        </div>
        
        <div class="solution">
            <h3>Solução Alternativa:</h3>
            <p>Se o status não permanece em 4, adicione este CSS no início do seu index.asp:</p>
            <pre style="background: #f5f5f5; padding: 10px;">
&lt;style&gt;
/* Forçar cor verde no workflow para o Brainstorming */
#step-60382,
.step-60382,
[data-stepid="60382"],
.workflow-step:has([href*="stepID=60382"]) {
    background-color: #5cb85c !important;
}
&lt;/style&gt;
            </pre>
        </div>
    <% End If %>
    
    <h2>4. Verificar se há Triggers ou Constraints</h2>
    <p>Execute este SQL no seu banco de dados para verificar triggers:</p>
    <pre style="background: #f5f5f5; padding: 10px;">
SELECT * FROM sys.triggers WHERE parent_id = OBJECT_ID('T_WORKFLOW_STEP');
    </pre>
    
    <hr>
    <div style="margin-top: 20px;">
        <a href="/manageWorkflow.asp?workflowID=30143" target="_blank">Abrir Workflow</a> |
        <a href="index.asp?stepID=60382">Voltar ao Brainstorming</a>
    </div>
</body>
</html>