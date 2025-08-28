<!--#include virtual="/system.asp"-->
<!--#include virtual="/checkstep.asp"-->
<%
Response.ContentType = "text/html"
%>
<!DOCTYPE html>
<html>
<head>
    <title>Verificar Status do Step</title>
    <style>
        body { font-family: Arial; padding: 20px; }
        .box { background: #f5f5f5; padding: 15px; margin: 10px 0; border-radius: 5px; }
        .success { color: green; font-weight: bold; }
        .error { color: red; font-weight: bold; }
        .warning { color: orange; font-weight: bold; }
        table { width: 100%; border-collapse: collapse; margin: 10px 0; }
        td, th { border: 1px solid #ddd; padding: 8px; }
        th { background: #e0e0e0; }
        button { padding: 10px 20px; margin: 5px; cursor: pointer; }
    </style>
</head>
<body>
    <h1>?? Verificar Status do Step 50380</h1>
    
    <%
    Dim stepID
    stepID = 50380
    
    ' Verificar o step
    Response.Write "<div class='box'>"
    Response.Write "<h2>1. Informações do Step</h2>"
    
    call getRecordSet("SELECT * FROM T_WORKFLOW_STEP WHERE stepID = " & stepID, rs)
    
    If Not rs.EOF Then
        Response.Write "<table>"
        Response.Write "<tr><th>Campo</th><th>Valor</th></tr>"
        Response.Write "<tr><td>stepID</td><td>" & rs("stepID") & "</td></tr>"
        Response.Write "<tr><td>workflowID</td><td>" & rs("workflowID") & "</td></tr>"
        Response.Write "<tr><td>type</td><td>" & rs("type") & "</td></tr>"
        Response.Write "<tr><td>status</td><td><strong>" & rs("status") & "</strong></td></tr>"
        Response.Write "</table>"
        
        Dim currentStatus
        currentStatus = rs("status")
        
        ' Verificar o que significa o status
        Response.Write "<h3>Interpretação do Status:</h3>"
        Response.Write "<p>Status atual: <strong>" & currentStatus & "</strong></p>"
        
        ' Testar a função getStatusStep
        Response.Write "<p>getStatusStep(" & stepID & ") retorna: <strong>" & getStatusStep(stepID) & "</strong></p>"
        
        ' Verificar se é STATE_ACTIVE
        Response.Write "<p>STATE_ACTIVE = <strong>" & STATE_ACTIVE & "</strong></p>"
        
        If getStatusStep(stepID) = STATE_ACTIVE Then
            Response.Write "<p class='success'>? Step está ATIVO - botões devem aparecer</p>"
        Else
            Response.Write "<p class='error'>? Step NÃO está ativo - botões não aparecem</p>"
            Response.Write "<p>Para ativar, o status precisa ser = " & STATE_ACTIVE & "</p>"
        End If
    Else
        Response.Write "<p class='error'>Step não encontrado!</p>"
    End If
    Response.Write "</div>"
    
    ' Opção para ativar o step
    If Request.QueryString("action") = "activate" Then
        Response.Write "<div class='box'>"
        Response.Write "<h2>Ativando Step...</h2>"
        
        call ExecuteSQL("UPDATE T_WORKFLOW_STEP SET status = " & STATE_ACTIVE & " WHERE stepID = " & stepID)
        
        Response.Write "<p class='success'>? Step ativado com sucesso!</p>"
        Response.Write "<p>Status alterado para: " & STATE_ACTIVE & "</p>"
        Response.Write "</div>"
    End If
    
    ' Verificar brainstorming
    Response.Write "<div class='box'>"
    Response.Write "<h2>2. Informações do Brainstorming</h2>"
    
    call getRecordSet("SELECT * FROM T_FTA_METHOD_BRAINSTORMING WHERE stepID = " & stepID, rs)
    
    If Not rs.EOF Then
        Response.Write "<table>"
        Response.Write "<tr><th>Campo</th><th>Valor</th></tr>"
        Response.Write "<tr><td>brainstormingID</td><td>" & rs("brainstormingID") & "</td></tr>"
        Response.Write "<tr><td>description</td><td>" & rs("description") & "</td></tr>"
        Response.Write "<tr><td>votingPoints</td><td>" & rs("votingPoints") & "</td></tr>"
        Response.Write "</table>"
    Else
        Response.Write "<p class='warning'>Nenhum brainstorming encontrado para este step</p>"
    End If
    Response.Write "</div>"
    
    ' Testar variável isActive
    Response.Write "<div class='box'>"
    Response.Write "<h2>3. Teste da Condição isActive</h2>"
    
    Dim isActive
    isActive = (getStatusStep(stepID) = STATE_ACTIVE)
    
    Response.Write "<p>isActive = (getStatusStep(" & stepID & ") = STATE_ACTIVE)</p>"
    Response.Write "<p>isActive = (" & getStatusStep(stepID) & " = " & STATE_ACTIVE & ")</p>"
    Response.Write "<p>Resultado: <strong>isActive = " & isActive & "</strong></p>"
    
    If isActive Then
        Response.Write "<p class='success'>? Os botões DEVEM aparecer</p>"
    Else
        Response.Write "<p class='error'>? Os botões NÃO vão aparecer</p>"
        Response.Write "<p>Os botões só aparecem quando isActive = True</p>"
    End If
    Response.Write "</div>"
    %>
    
    <hr>
    <div style="margin: 20px 0;">
        <% If getStatusStep(stepID) <> STATE_ACTIVE Then %>
        <button onclick="if(confirm('Ativar o step 50380?')) location.href='?action=activate'" style="background: #4CAF50; color: white; font-size: 16px;">
            ?? ATIVAR STEP
        </button>
        <% Else %>
        <p class="success" style="font-size: 18px;">? Step já está ativo!</p>
        <% End If %>
    </div>
    
    <div style="margin: 20px 0;">
        <a href="index.asp?stepID=50380" style="padding: 10px 20px; background: #2196F3; color: white; text-decoration: none; border-radius: 5px;">
            ?? Ver Brainstorming
        </a>
        <a href="manageIdea.asp?stepID=50380&brainstormingID=20021&action=add" style="padding: 10px 20px; background: #FF9800; color: white; text-decoration: none; border-radius: 5px; margin-left: 10px;">
            ? Criar Nova Ideia
        </a>
    </div>
</body>
</html>