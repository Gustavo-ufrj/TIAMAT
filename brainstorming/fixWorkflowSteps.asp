<!--#include virtual="/system.asp"-->
<%
Response.ContentType = "text/html"
%>
<!DOCTYPE html>
<html>
<head>
    <title>Corrigir Steps no Workflow</title>
    <style>
        body { font-family: Arial; padding: 20px; background: #f5f5f5; }
        .container { max-width: 800px; margin: 0 auto; background: white; padding: 20px; border-radius: 10px; }
        .success { color: green; font-weight: bold; }
        .error { color: red; }
        .info { background: #e3f2fd; padding: 15px; border-radius: 5px; margin: 15px 0; }
        button { padding: 10px 20px; margin: 5px; cursor: pointer; }
    </style>
</head>
<body>
    <div class="container">
        <h1>?? Corrigir Steps no Workflow 30144</h1>
        
        <%
        Dim action
        action = Request.QueryString("action")
        
        If action = "fix" Then
            Response.Write "<h2>Executando Correções...</h2>"
            
            On Error Resume Next
            
            ' 1. Verificar se os steps 50370 e 50375 existem
            Response.Write "<h3>1. Verificando Steps 50370 e 50375</h3>"
            
            ' Verificar step 50370
            call getRecordSet("SELECT * FROM T_WORKFLOW_STEP WHERE stepID = 50370", rs)
            If rs.EOF Then
                Response.Write "<p>Step 50370 não existe. Criando...</p>"
                call ExecuteSQL("INSERT INTO T_WORKFLOW_STEP (stepID, workflowID, type, status) VALUES (50370, 30144, 1, 4)")
                If Err.Number = 0 Then
                    Response.Write "<p class='success'>? Step 50370 criado no workflow 30144</p>"
                Else
                    Response.Write "<p class='error'>? Erro: " & Err.Description & "</p>"
                    Err.Clear
                End If
            Else
                ' Verificar se está no workflow correto
                If rs("workflowID") <> 30144 Then
                    Response.Write "<p>Step 50370 existe mas está no workflow " & rs("workflowID") & ". Atualizando...</p>"
                    call ExecuteSQL("UPDATE T_WORKFLOW_STEP SET workflowID = 30144 WHERE stepID = 50370")
                    If Err.Number = 0 Then
                        Response.Write "<p class='success'>? Step 50370 movido para workflow 30144</p>"
                    Else
                        Response.Write "<p class='error'>? Erro: " & Err.Description & "</p>"
                        Err.Clear
                    End If
                Else
                    Response.Write "<p class='success'>? Step 50370 já está no workflow 30144</p>"
                End If
            End If
            
            ' Verificar step 50375
            call getRecordSet("SELECT * FROM T_WORKFLOW_STEP WHERE stepID = 50375", rs)
            If rs.EOF Then
                Response.Write "<p>Step 50375 não existe. Criando...</p>"
                call ExecuteSQL("INSERT INTO T_WORKFLOW_STEP (stepID, workflowID, type, status) VALUES (50375, 30144, 2, 4)")
                If Err.Number = 0 Then
                    Response.Write "<p class='success'>? Step 50375 criado no workflow 30144</p>"
                Else
                    Response.Write "<p class='error'>? Erro: " & Err.Description & "</p>"
                    Err.Clear
                End If
            Else
                ' Verificar se está no workflow correto
                If rs("workflowID") <> 30144 Then
                    Response.Write "<p>Step 50375 existe mas está no workflow " & rs("workflowID") & ". Atualizando...</p>"
                    call ExecuteSQL("UPDATE T_WORKFLOW_STEP SET workflowID = 30144 WHERE stepID = 50375")
                    If Err.Number = 0 Then
                        Response.Write "<p class='success'>? Step 50375 movido para workflow 30144</p>"
                    Else
                        Response.Write "<p class='error'>? Erro: " & Err.Description & "</p>"
                        Err.Clear
                    End If
                Else
                    Response.Write "<p class='success'>? Step 50375 já está no workflow 30144</p>"
                End If
            End If
            
            ' 2. Verificar dados após correção
            Response.Write "<h3>2. Verificando Dados Após Correção</h3>"
            
            ' Contar dados disponíveis
            Dim biblioCount, scenarioCount
            biblioCount = 0
            scenarioCount = 0
            
            call getRecordSet("SELECT COUNT(*) as total FROM T_FTA_METHOD_BIBLIOMETRICS b " & _
                             "INNER JOIN T_WORKFLOW_STEP s ON b.stepID = s.stepID " & _
                             "WHERE s.workflowID = 30144 AND s.stepID < 50380", rs)
            If Not rs.EOF Then biblioCount = rs("total")
            
            call getRecordSet("SELECT COUNT(*) as total FROM T_FTA_METHOD_SCENARIOS sc " & _
                             "INNER JOIN T_WORKFLOW_STEP s ON sc.stepID = s.stepID " & _
                             "WHERE s.workflowID = 30144 AND s.stepID < 50380", rs)
            If Not rs.EOF Then scenarioCount = rs("total")
            
            Response.Write "<div class='info'>"
            Response.Write "<h4>Resultado Final:</h4>"
            If biblioCount > 0 Or scenarioCount > 0 Then
                Response.Write "<p class='success'>? Dados disponíveis para Dublin Core:</p>"
                Response.Write "<ul>"
                If biblioCount > 0 Then Response.Write "<li>?? " & biblioCount & " referências bibliométricas</li>"
                If scenarioCount > 0 Then Response.Write "<li>?? " & scenarioCount & " cenários</li>"
                Response.Write "</ul>"
                Response.Write "<p><strong>Agora o Brainstorming pode acessar esses dados!</strong></p>"
            Else
                Response.Write "<p class='error'>? Ainda sem dados disponíveis</p>"
            End If
            Response.Write "</div>"
            
            On Error Goto 0
            
        Else
            ' Página inicial - verificar situação atual
            Response.Write "<h2>Situação Atual</h2>"
            
            On Error Resume Next
            
            ' Verificar steps no workflow
            Response.Write "<h3>Steps no Workflow 30144:</h3>"
            call getRecordSet("SELECT stepID FROM T_WORKFLOW_STEP WHERE workflowID = 30144 ORDER BY stepID", rs)
            Response.Write "<ul>"
            While Not rs.EOF
                Response.Write "<li>Step " & rs("stepID") & "</li>"
                rs.MoveNext
            Wend
            Response.Write "</ul>"
            
            ' Verificar onde estão 50370 e 50375
            Response.Write "<h3>Localização dos Steps de Teste:</h3>"
            
            call getRecordSet("SELECT stepID, workflowID FROM T_WORKFLOW_STEP WHERE stepID IN (50370, 50375)", rs)
            If rs.EOF Then
                Response.Write "<p class='error'>Steps 50370 e 50375 não existem!</p>"
            Else
                Response.Write "<ul>"
                While Not rs.EOF
                    Response.Write "<li>Step " & rs("stepID") & " está no workflow " & rs("workflowID")
                    If rs("workflowID") <> 30144 Then
                        Response.Write " <span class='error'>(PRECISA SER MOVIDO!)</span>"
                    Else
                        Response.Write " <span class='success'>(OK)</span>"
                    End If
                    Response.Write "</li>"
                    rs.MoveNext
                Wend
                Response.Write "</ul>"
            End If
            
            Response.Write "<div class='info'>"
            Response.Write "<p><strong>O que este script faz:</strong></p>"
            Response.Write "<ol>"
            Response.Write "<li>Verifica se os steps 50370 e 50375 existem</li>"
            Response.Write "<li>Se não existem, cria eles no workflow 30144</li>"
            Response.Write "<li>Se existem mas estão em outro workflow, move para 30144</li>"
            Response.Write "<li>Confirma que os dados estão disponíveis para o Dublin Core</li>"
            Response.Write "</ol>"
            Response.Write "</div>"
            
            Response.Write "<div style='margin: 20px 0;'>"
            Response.Write "<button onclick='if(confirm(""Corrigir steps no workflow?"")) location.href=""?action=fix""' style='background: #4CAF50; color: white;'>"
            Response.Write "?? Executar Correção"
            Response.Write "</button>"
            Response.Write "</div>"
            
            On Error Goto 0
        End If
        %>
        
        <hr>
        <div style="margin-top: 20px;">
            <a href="simpleCheck.asp" style="padding: 10px 20px; background: #2196F3; color: white; text-decoration: none; border-radius: 5px;">
                ?? Verificar Dados
            </a>
            <a href="manageIdea.asp?stepID=50380&brainstormingID=20021&action=add" style="padding: 10px 20px; background: #FF9800; color: white; text-decoration: none; border-radius: 5px; margin-left: 10px;">
                ? Criar Nova Ideia
            </a>
            <a href="index.asp?stepID=50380" style="padding: 10px 20px; background: #9C27B0; color: white; text-decoration: none; border-radius: 5px; margin-left: 10px;">
                ?? Ver Brainstorming
            </a>
        </div>
    </div>
</body>
</html>