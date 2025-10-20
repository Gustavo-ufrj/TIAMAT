<!--#include virtual="/system.asp"-->
<!DOCTYPE html>
<html>
<head>
    <title>Corrigir Status - Valores Ajustados</title>
    <style>
        body { font-family: Arial; padding: 20px; }
        .status-box { padding: 20px; margin: 10px; border-radius: 5px; text-align: center; }
        .real-3 { background: #6c757d; color: white; } /* Cinza */
        .real-4 { background: #5cb85c; color: white; } /* Verde */
        .real-5 { background: #fd7e14; color: white; } /* Laranja */
        button { padding: 15px 30px; margin: 10px; cursor: pointer; border: none; border-radius: 5px; font-size: 16px; }
        table { width: 100%; border-collapse: collapse; margin: 20px 0; }
        th, td { border: 1px solid #ddd; padding: 10px; }
        th { background: #f0f0f0; }
    </style>
</head>
<body>
    <h1>Corrigir Status do Brainstorming - Valores Ajustados</h1>
    
    <%
    Dim action
    action = Request.QueryString("action")
    
    ' Aplicar correção com offset
    Select Case action
        Case "setCinza"
            call ExecuteSQL("UPDATE T_WORKFLOW_STEP SET status = 2 WHERE stepID = 60382") ' 2 para aparecer cinza
            Response.Write "<div style='background: #6c757d; color: white; padding: 15px;'>Definido para aparecer CINZA</div>"
            
        Case "setVerde"
            call ExecuteSQL("UPDATE T_WORKFLOW_STEP SET status = 3 WHERE stepID = 60382") ' 3 para aparecer verde
            Response.Write "<div style='background: #5cb85c; color: white; padding: 15px;'>Definido para aparecer VERDE</div>"
            
        Case "setLaranja"
            call ExecuteSQL("UPDATE T_WORKFLOW_STEP SET status = 4 WHERE stepID = 60382") ' 4 para aparecer laranja
            Response.Write "<div style='background: #fd7e14; color: white; padding: 15px;'>Definido para aparecer LARANJA</div>"
            
        Case "setCorreto"
            ' Para aparecer verde, precisa ser 3
            call ExecuteSQL("UPDATE T_WORKFLOW_STEP SET status = 3 WHERE stepID = 60382")
            Response.Write "<div style='background: #5cb85c; color: white; padding: 15px;'>? Status definido para VERDE (valor 3)</div>"
    End Select
    %>
    
    <h2>Mapeamento Descoberto:</h2>
    <table>
        <tr>
            <th>Valor no Banco</th>
            <th>Cor que Aparece</th>
            <th>Deveria Ser</th>
        </tr>
        <tr>
            <td>2</td>
            <td class="real-3">Cinza</td>
            <td>3 = Cinza</td>
        </tr>
        <tr>
            <td>3</td>
            <td class="real-4">Verde</td>
            <td>4 = Verde</td>
        </tr>
        <tr>
            <td>4</td>
            <td class="real-5">Laranja</td>
            <td>5 = Laranja</td>
        </tr>
        <tr>
            <td>5</td>
            <td>Branco/Indefinido</td>
            <td>-</td>
        </tr>
    </table>
    
    <h2>Status Atual do Brainstorming:</h2>
    <%
    call getRecordSet("SELECT status FROM T_WORKFLOW_STEP WHERE stepID = 60382", rs)
    If Not rs.EOF Then
        Dim currentStatus
        currentStatus = rs("status")
    %>
        <div class="status-box">
            <h3>Valor no Banco: <%=currentStatus%></h3>
            <p>
            <% Select Case currentStatus
                Case 2
                    Response.Write "Aparece: CINZA"
                Case 3
                    Response.Write "Aparece: VERDE"
                Case 4
                    Response.Write "Aparece: LARANJA"
                Case 5
                    Response.Write "Aparece: BRANCO"
                Case Else
                    Response.Write "Aparece: INDEFINIDO"
            End Select %>
            </p>
        </div>
    <% End If %>
    
    <h2>Ações com Valores Corrigidos:</h2>
    <div style="text-align: center;">
        <button onclick="location.href='?action=setCinza'" style="background: #6c757d; color: white;">
            Definir para CINZA (valor 2)
        </button>
        <button onclick="location.href='?action=setVerde'" style="background: #5cb85c; color: white;">
            Definir para VERDE (valor 3)
        </button>
        <button onclick="location.href='?action=setLaranja'" style="background: #fd7e14; color: white;">
            Definir para LARANJA (valor 4)
        </button>
    </div>
    
    <div style="background: #e8f5e9; padding: 20px; margin: 30px 0; border-radius: 5px;">
        <h3>? Solução para o Brainstorming:</h3>
        <button onclick="location.href='?action=setCorreto'" style="background: #5cb85c; color: white; padding: 15px 30px; font-size: 18px;">
            APLICAR CORREÇÃO - Brainstorming Verde (valor 3)
        </button>
    </div>
    
    <h2>Também corrigir os outros steps:</h2>
    <p>Os steps 50378 e 50379 (Bibliometrics e Scenarios) devem estar com valor 4 para aparecer laranja (finalizado)</p>
    
    <hr>
    <div style="margin-top: 30px;">
        <a href="/manageWorkflow.asp?workflowID=30143" target="_blank">Abrir Workflow</a> |
        <a href="index.asp?stepID=60382">Voltar ao Brainstorming</a>
    </div>
</body>
</html>