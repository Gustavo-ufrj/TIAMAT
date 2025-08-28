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
            Response.Write "<h2>Executando Corre��es...</h2>"
            
            On Error Resume Next
            
            ' 1. Verificar se os steps 50370 e 50375 existem
            Response.Write "<h3>1. Verificando Steps 50370 e 50375</h3>"
            
            ' Verificar step 50370
            call getRecordSet("SELECT * FROM T_WORKFLOW_STEP WHERE stepID = 50370", rs)
            If rs.EOF Then
                Response.Write "<p>Step 50370 n�o existe. Criando...</p>"
                call ExecuteSQL("INSERT INTO T_WORKFLOW_STEP (stepID, workflowID, type, status) VALUES (50370, 30144, 1, 4)")
                If Err.Number = 0 Then
                    Response.Write "<p class='success'>? Step 50370 criado no workflow 30144</p>"
                Else
                    Response.Write "<p class='error'>? Erro: " & Err.Description & "</p>"
                    Err.Clear
                End If
            Else
                ' Verificar se est� no workflow correto
                If rs("workflowID") <> 30144 Then
                    Response.Write "<p>Step 50370 existe mas est� no workflow " & rs("workflowID") & ". Atualizando...</p>"
                    call ExecuteSQL("UPDATE T_WORKFLOW_STEP SET workflowID = 30144 WHERE stepID = 50370")
                    If Err.Number = 0 Then
                        Response.Write "<p class='success'>? Step 50370 movido para workflow 30144</p>"
                    Else
                        Response.Write "<p class='error'>? Erro: " & Err.Description & "</p>"
                        Err.Clear
                    End If
                Else
                    Response.Write "<p class='success'>? Step 50370 j� est� no workflow 30144</p>"
                End If
            End If
            
            ' Verificar step 50375
            call getRecordSet("SELECT * FROM T_WORKFLOW_STEP WHERE stepID = 50375", rs)
            If rs.EOF Then
                Response.Write "<p>Step 50375 n�o existe. Criando...</p>"
                call ExecuteSQL("INSERT INTO T_WORKFLOW_STEP (stepID, workflowID, type, status) VALUES (50375, 30144, 2, 4)")
                If Err.Number = 0 Then
                    Response.Write "<p class='success'>? Step 50375 criado no workflow 30144</p>"
                Else
                    Response.Write "<p class='error'>? Erro: " & Err.Description & "</p>"
                    Err.Clear
                End If
            Else
                ' Verificar se est� no workflow correto
                If rs("workflowID") <> 30144 Then
                    Response.Write "<p>Step 50375 existe mas est� no workflow " & rs("workflowID") & ". Atualizando...</p>"
                    call ExecuteSQL("UPDATE T_WORKFLOW_STEP SET workflowID = 30144 WHERE stepID = 50375")
                    If Err.Number = 0 Then
                        Response.Write "<p class='success'>? Step 50375 movido para workflow 30144</p>"
                    Else
                        Response.Write "<p class='error'>? Erro: " & Err.Description & "</p>"
                        Err.Clear
                    End If
                Else
                    Response.Write "<p class='success'>? Step 50375 j� est� no workflow 30144</p>"
                End If
            End If
            
            ' 2. Verificar dados ap�s corre��o
            Response.Write "<h3>2. Verificando Dados Ap�s Corre��o</h3>"
            
            ' Contar dados dispon�veis
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
                Response.Write "<p class='success'>? Dados dispon�veis para Dublin Core:</p>"
                Response.Write "<ul>"
                If biblioCount > 0 Then Response.Write "<li>?? " & biblioCount & " refer�ncias bibliom�tricas</li>"
                If scenarioCount > 0 Then Response.Write "<li>?? " & scenarioCount & " cen�rios</li>"
                Response.Write "</ul>"
                Response.Write "<p><strong>Agora o Brainstorming pode acessar esses dados!</strong></p>"
            Else
                Response.Write "<p class='error'>? Ainda sem dados dispon�veis</p>"
            End If
            Response.Write "</div>"
            
            On Error Goto 0
            
        Else
            ' P�gina inicial - verificar situa��o atual
            Response.Write "<h2>Situa��o Atual</h2>"
            
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
            
            ' Verificar onde est�o 50370 e 50375
            Response.Write "<h3>Localiza��o dos Steps de Teste:</h3>"
            
            call getRecordSet("SELECT stepID, workflowID FROM T_WORKFLOW_STEP WHERE stepID IN (50370, 50375)", rs)
            If rs.EOF Then
                Response.Write "<p class='error'>Steps 50370 e 50375 n�o existem!</p>"
            Else
                Response.Write "<ul>"
                While Not rs.EOF
                    Response.Write "<li>Step " & rs("stepID") & " est� no workflow " & rs("workflowID")
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
            Response.Write "<li>Se n�o existem, cria eles no workflow 30144</li>"
            Response.Write "<li>Se existem mas est�o em outro workflow, move para 30144</li>"
            Response.Write "<li>Confirma que os dados est�o dispon�veis para o Dublin Core</li>"
            Response.Write "</ol>"
            Response.Write "</div>"
            
            Response.Write "<div style='margin: 20px 0;'>"
            Response.Write "<button onclick='if(confirm(""Corrigir steps no workflow?"")) location.href=""?action=fix""' style='background: #4CAF50; color: white;'>"
            Response.Write "?? Executar Corre��o"
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