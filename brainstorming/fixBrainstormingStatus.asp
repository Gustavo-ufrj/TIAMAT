<!--#include virtual="/system.asp"-->
<!DOCTYPE html>
<html>
<head>
    <title>Corrigir Status do Brainstorming</title>
    <style>
        body { font-family: Arial; padding: 20px; }
        .status-box { 
            padding: 20px; 
            margin: 10px; 
            border-radius: 5px; 
            color: white; 
            font-weight: bold;
            text-align: center;
        }
        .status-3 { background: #6c757d; } /* Cinza - Aguardando */
        .status-4 { background: #5cb85c; } /* Verde - Ativo */
        .status-5 { background: #fd7e14; } /* Laranja - Finalizado */
        button { padding: 10px 20px; margin: 5px; cursor: pointer; font-size: 16px; }
    </style>
</head>
<body>
    <h1>Corrigir Status do Workflow</h1>
    
    <%
    Dim stepID, action
    stepID = Request.QueryString("stepID")
    If stepID = "" Then stepID = "60382"
    
    action = Request.QueryString("action")
    
    If action = "fix" Then
        ' Corrigir o Brainstorming para status 4 (Verde/Ativo)
        call ExecuteSQL("UPDATE T_WORKFLOW_STEP SET status = 4 WHERE stepID = " & stepID)
        Response.Write "<div style='background: #d4edda; color: #155724; padding: 15px; border-radius: 5px;'>"
        Response.Write "<h2>? Status Corrigido!</h2>"
        Response.Write "<p>Brainstorming (Step " & stepID & ") agora está com status 4 (Verde/Ativo)</p>"
        Response.Write "</div>"
    End If
    %>
    
    <h2>Status Atual do Step <%=stepID%></h2>
    
    <%
    call getRecordSet("SELECT * FROM T_WORKFLOW_STEP WHERE stepID = " & stepID, rs)
    If Not rs.EOF Then
        Dim currentStatus
        currentStatus = rs("status")
    %>
        <div class="status-box status-<%=currentStatus%>">
            Status Atual: <%=currentStatus%>
            <br>
            <% Select Case currentStatus
                Case 3
                    Response.Write "CINZA (Aguardando)"
                Case 4
                    Response.Write "VERDE (Ativo)"
                Case 5
                    Response.Write "LARANJA (Finalizado)"
            End Select %>
        </div>
        
        <% If currentStatus <> 4 Then %>
            <div style="background: #fff3cd; padding: 15px; margin: 20px 0; border-radius: 5px;">
                <h3>? Status Incorreto!</h3>
                <p>O Brainstorming deveria estar com status 4 (Verde/Ativo) mas está com status <%=currentStatus%></p>
                <button onclick="location.href='?stepID=<%=stepID%>&action=fix'" 
                        style="background: #5cb85c; color: white; border: none; border-radius: 5px;">
                    ?? Corrigir para Status 4 (Verde)
                </button>
            </div>
        <% Else %>
            <div style="background: #d4edda; padding: 15px; margin: 20px 0; border-radius: 5px;">
                <h3>? Status Correto!</h3>
                <p>O Brainstorming está com o status correto (4 - Verde/Ativo)</p>
            </div>
        <% End If %>
    <% End If %>
    
    <h2>Como devem ser os status:</h2>
    <table style="width: 100%; border-collapse: collapse;">
        <tr>
            <th style="padding: 10px; background: #f0f0f0;">Método</th>
            <th style="padding: 10px; background: #f0f0f0;">Status Correto</th>
            <th style="padding: 10px; background: #f0f0f0;">Cor</th>
        </tr>
        <tr>
            <td style="padding: 10px; border: 1px solid #ddd;">Bibliometrics (já executado)</td>
            <td style="padding: 10px; border: 1px solid #ddd;">5 - Finalizado</td>
            <td style="padding: 10px; border: 1px solid #ddd;"><span style="background: #fd7e14; color: white; padding: 2px 10px;">Laranja</span></td>
        </tr>
        <tr>
            <td style="padding: 10px; border: 1px solid #ddd;">Scenarios (já executado)</td>
            <td style="padding: 10px; border: 1px solid #ddd;">5 - Finalizado</td>
            <td style="padding: 10px; border: 1px solid #ddd;"><span style="background: #fd7e14; color: white; padding: 2px 10px;">Laranja</span></td>
        </tr>
        <tr>
            <td style="padding: 10px; border: 1px solid #ddd;"><strong>Brainstorming (em execução)</strong></td>
            <td style="padding: 10px; border: 1px solid #ddd;"><strong>4 - Ativo</strong></td>
            <td style="padding: 10px; border: 1px solid #ddd;"><span style="background: #5cb85c; color: white; padding: 2px 10px; font-weight: bold;">Verde</span></td>
        </tr>
        <tr>
            <td style="padding: 10px; border: 1px solid #ddd;">Futures Wheel (próximo)</td>
            <td style="padding: 10px; border: 1px solid #ddd;">3 - Aguardando</td>
            <td style="padding: 10px; border: 1px solid #ddd;"><span style="background: #6c757d; color: white; padding: 2px 10px;">Cinza</span></td>
        </tr>
    </table>
    
    <div style="margin-top: 30px;">
        <button onclick="location.href='/manageWorkflow.asp?workflowID=30143'" 
                style="background: #007bff; color: white; border: none; padding: 10px 20px; border-radius: 5px;">
            Ver Workflow
        </button>
        <button onclick="location.href='index.asp?stepID=<%=stepID%>'" 
                style="background: #17a2b8; color: white; border: none; padding: 10px 20px; border-radius: 5px;">
            Voltar ao Brainstorming
        </button>
    </div>
</body>
</html>