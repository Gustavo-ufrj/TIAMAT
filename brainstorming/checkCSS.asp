<!--#include virtual="/system.asp"-->
<!DOCTYPE html>
<html>
<head>
    <title>Verificar CSS e Status</title>
    <style>
        body { font-family: Arial; padding: 20px; }
        .info-box { 
            background: #f0f0f0; 
            padding: 15px; 
            margin: 10px 0; 
            border-radius: 5px; 
            border-left: 4px solid #007bff;
        }
        table { width: 100%; border-collapse: collapse; margin: 10px 0; }
        th, td { border: 1px solid #ddd; padding: 8px; text-align: left; }
        th { background: #e0e0e0; }
        .status-display {
            display: inline-block;
            padding: 5px 10px;
            border-radius: 3px;
            color: white;
            font-weight: bold;
        }
    </style>
</head>
<body>
    <h1>Diagnóstico do Problema de Cor</h1>
    
    <%
    Dim stepID
    stepID = Request.QueryString("stepID")
    If stepID = "" Then stepID = "60382"
    %>
    
    <div class="info-box">
        <h2>1. Status do Step <%=stepID%></h2>
        <%
        call getRecordSet("SELECT * FROM T_WORKFLOW_STEP WHERE stepID = " & stepID, rs)
        If Not rs.EOF Then
            Dim currentStatus, workflowID
            currentStatus = rs("status")
            workflowID = rs("workflowID")
        %>
            <p><strong>Status atual:</strong> <%=currentStatus%></p>
            <p><strong>WorkflowID:</strong> <%=workflowID%></p>
            <p><strong>Cor esperada:</strong> 
                <% Select Case currentStatus
                    Case 3 %>
                        <span class="status-display" style="background: #6c757d;">CINZA (Aguardando)</span>
                    <% Case 4 %>
                        <span class="status-display" style="background: #5cb85c;">VERDE (Ativo)</span>
                    <% Case 5 %>
                        <span class="status-display" style="background: #fd7e14;">LARANJA (Finalizado)</span>
                <% End Select %>
            </p>
        <% End If %>
    </div>
    
    <div class="info-box">
        <h2>2. Problema Identificado</h2>
        <p>O quadrado do Brainstorming aparece BRANCO no workflow porque:</p>
        <ul>
            <li>O CSS do workflow (manageWorkflow.asp) define as cores baseado em classes CSS</li>
            <li>O workflow provavelmente usa classes como .step-status-3, .step-status-4, .step-status-5</li>
            <li>Se o step não tem uma dessas classes ou tem uma classe diferente, fica com a cor padrão (branco)</li>
        </ul>
    </div>
    
    <div class="info-box">
        <h2>3. Solução</h2>
        <p><strong>O problema NÃO está no Brainstorming, mas sim no manageWorkflow.asp</strong></p>
        
        <p>Para corrigir, você precisa:</p>
        <ol>
            <li>Abrir o arquivo <code>/manageWorkflow.asp</code></li>
            <li>Procurar onde ele define as cores dos quadrados dos métodos</li>
            <li>Verificar se está aplicando a classe correta baseada no status</li>
        </ol>
        
        <p><strong>Alternativamente, force o status correto:</strong></p>
        <form method="post">
            <button type="submit" name="action" value="setStatus4" style="background: #5cb85c; color: white; padding: 10px;">
                Definir Status = 4 (Verde/Ativo)
            </button>
        </form>
        
        <%
        If Request.Form("action") = "setStatus4" Then
            call ExecuteSQL("UPDATE T_WORKFLOW_STEP SET status = 4 WHERE stepID = " & stepID)
            Response.Write "<p style='color: green; font-weight: bold;'>Status atualizado para 4 (Verde)!</p>"
            Response.Write "<p>Recarregue o workflow para ver a mudança.</p>"
        End If
        %>
    </div>
    
    <div class="info-box">
        <h2>4. Todos os Steps do Workflow</h2>
        <table>
            <tr>
                <th>StepID</th>
                <th>Nome</th>
                <th>Status</th>
                <th>Cor Esperada</th>
            </tr>
            <%
            call getRecordSet("SELECT * FROM T_WORKFLOW_STEP WHERE workflowID = " & workflowID & " ORDER BY stepID", rs)
            While Not rs.EOF
            %>
            <tr>
                <td><%=rs("stepID")%></td>
                <td>Step <%=rs("stepID")%></td>
                <td><%=rs("status")%></td>
                <td>
                    <% Select Case rs("status")
                        Case 3 %>
                            <span style="background: #6c757d; color: white; padding: 2px 5px;">Cinza</span>
                        <% Case 4 %>
                            <span style="background: #5cb85c; color: white; padding: 2px 5px;">Verde</span>
                        <% Case 5 %>
                            <span style="background: #fd7e14; color: white; padding: 2px 5px;">Laranja</span>
                    <% End Select %>
                </td>
            </tr>
            <%
                rs.MoveNext
            Wend
            %>
        </table>
    </div>
    
    <hr>
    <p>
        <a href="/manageWorkflow.asp?workflowID=<%=workflowID%>" target="_blank">Abrir Workflow</a> |
        <a href="index.asp?stepID=<%=stepID%>">Voltar ao Brainstorming</a>
    </p>
</body>
</html>