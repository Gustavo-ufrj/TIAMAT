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
        .status-3 { background: #6c757d; color: white; padding: 2px 5px; }
        .status-4 { background: #5cb85c; color: white; padding: 2px 5px; }
        .status-5 { background: #fd7e14; color: white; padding: 2px 5px; }
        .problem { background: #ffebee; padding: 15px; border-left: 4px solid red; margin: 20px 0; }
        .solution { background: #e8f5e9; padding: 15px; border-left: 4px solid green; margin: 20px 0; }
        button { padding: 10px 20px; margin: 5px; cursor: pointer; border: none; border-radius: 5px; }
    </style>
</head>
<body>
    <h1>Diagnóstico do Workflow 30143</h1>
    
    <%
    Dim action
    action = Request.QueryString("action")
    
    ' Processar ações
    Select Case action
        Case "force3"
            call ExecuteSQL("UPDATE T_WORKFLOW_STEP SET status = 3 WHERE stepID = 60382")
            Response.Write "<div class='solution'>Status mudado para 3 (Cinza/Aguardando)</div>"
            
        Case "force4"
            call ExecuteSQL("UPDATE T_WORKFLOW_STEP SET status = 4 WHERE stepID = 60382")
            Response.Write "<div class='solution'>Status mudado para 4 (Verde/Ativo)</div>"
            
        Case "force5"
            call ExecuteSQL("UPDATE T_WORKFLOW_STEP SET status = 5 WHERE stepID = 60382")
            Response.Write "<div class='solution'>Status mudado para 5 (Laranja/Finalizado)</div>"
    End Select
    %>
    
    <h2>1. Todos os Steps do Workflow 30143</h2>
    <table>
        <tr>
            <th>StepID</th>
            <th>Type</th>
            <th>Status</th>
            <th>Cor</th>
            <th>Situação</th>
        </tr>
        <%
        On Error Resume Next
        
        call getRecordSet("SELECT * FROM T_WORKFLOW_STEP WHERE workflowID = 30143 ORDER BY stepID", rs)
        
        While Not rs.EOF
            Dim stepID, stepType, stepStatus
            stepID = CLng(rs("stepID"))
            stepType = rs("type")
            stepStatus = CLng(rs("status"))
            
            Response.Write "<tr>"
            Response.Write "<td><strong>" & stepID & "</strong></td>"
            Response.Write "<td>" & stepType & "</td>"
            Response.Write "<td><span class='status-" & stepStatus & "'>" & stepStatus & "</span></td>"
            Response.Write "<td>"
            
            Select Case stepStatus
                Case 3
                    Response.Write "<span class='status-3'>Cinza (Aguardando)</span>"
                Case 4
                    Response.Write "<span class='status-4'>Verde (Ativo)</span>"
                Case 5
                    Response.Write "<span class='status-5'>Laranja (Finalizado)</span>"
                Case Else
                    Response.Write "Status " & stepStatus
            End Select
            
            Response.Write "</td>"
            Response.Write "<td>"
            
            ' Análise específica
            If stepID = 50378 Or stepID = 50379 Then
                If stepStatus = 5 Then
                    Response.Write "? Correto (deve ser finalizado)"
                Else
                    Response.Write "Deveria ser 5 (finalizado)"
                End If
            ElseIf stepID = 60382 Then
                If stepStatus = 4 Then
                    Response.Write "<strong style='color: green;'>? CORRETO! Brainstorming ativo</strong>"
                Else
                    Response.Write "<strong style='color: red;'>ERRO! Brainstorming deveria ser status 4</strong>"
                End If
            End If
            
            Response.Write "</td>"
            Response.Write "</tr>"
            rs.MoveNext
        Wend
        
        On Error Goto 0
        %>
    </table>
    
    <h2>2. Status Atual do Brainstorming (Step 60382)</h2>
    <%
    call getRecordSet("SELECT status FROM T_WORKFLOW_STEP WHERE stepID = 60382", rs)
    If Not rs.EOF Then
        Dim brainstormingStatus
        brainstormingStatus = CLng(rs("status"))
    %>
        <div style="text-align: center; margin: 30px 0;">
            <h3>Status Atual: <span class="status-<%=brainstormingStatus%>" style="padding: 10px 20px; font-size: 20px;"><%=brainstormingStatus%></span></h3>
            
            <% If brainstormingStatus <> 4 Then %>
                <div class="problem">
                    <h3>Problema Detectado!</h3>
                    <p>O Brainstorming está com status <%=brainstormingStatus%> mas deveria estar com status 4 (Verde/Ativo)</p>
                </div>
            <% Else %>
                <div class="solution">
                    <h3>? Status Correto!</h3>
                    <p>O Brainstorming está com status 4 (Verde/Ativo) como esperado</p>
                </div>
            <% End If %>
        </div>
        
        <div style="text-align: center;">
            <h3>Testar Mudanças de Status:</h3>
            <button onclick="location.href='?action=force3'" style="background: #6c757d; color: white;">
                Mudar para 3 (Cinza)
            </button>
            <button onclick="location.href='?action=force4'" style="background: #5cb85c; color: white;">
                Mudar para 4 (Verde)
            </button>
            <button onclick="location.href='?action=force5'" style="background: #fd7e14; color: white;">
                Mudar para 5 (Laranja)
            </button>
        </div>
        
        <p style="text-align: center; margin-top: 20px;">
            <strong>Após mudar o status, recarregue o workflow para ver se a cor mudou</strong>
        </p>
    <% End If %>
    
    <h2>3. Por que pode estar aparecendo branco?</h2>
    <div class="problem">
        <ol>
            <li><strong>CSS do manageWorkflow.asp:</strong> Pode não ter uma regra CSS para o tipo de método + status atual</li>
            <li><strong>Cache do navegador:</strong> Tente CTRL+F5 no workflow</li>
            <li><strong>Classe CSS incorreta:</strong> O workflow pode estar aplicando uma classe errada ao quadrado</li>
        </ol>
    </div>
    
    <h2>4. Solução CSS Definitiva</h2>
    <div class="solution">
        <p>Adicione este código no início do seu <code>index.asp</code> do Brainstorming:</p>
        <pre style="background: #f5f5f5; padding: 15px; border-radius: 5px;">
&lt;%
' CSS para corrigir cor no workflow
Response.Write "&lt;style&gt;"
Response.Write "/* Força cor verde para Brainstorming no workflow */"
Response.Write ".workflow-container .step-60382,"
Response.Write "#step60382,"
Response.Write "div[data-stepid='60382'],"
Response.Write "td:has(a[href*='60382']) {"
Response.Write "    background-color: #5cb85c !important;"
Response.Write "}"
Response.Write "&lt;/style&gt;"
%&gt;
        </pre>
    </div>
    
    <hr>
    <div style="margin-top: 30px; text-align: center;">
        <a href="/manageWorkflow.asp?workflowID=30143" target="_blank" style="padding: 10px 20px; background: #007bff; color: white; text-decoration: none; border-radius: 5px;">
            Abrir Workflow
        </a>
        <a href="index.asp?stepID=60382" style="padding: 10px 20px; background: #17a2b8; color: white; text-decoration: none; border-radius: 5px; margin-left: 10px;">
            Voltar ao Brainstorming
        </a>
    </div>
</body>
</html>