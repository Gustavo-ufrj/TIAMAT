<!--#include virtual="/system.asp"-->
<%
Response.ContentType = "text/html"
%>
<!DOCTYPE html>
<html>
<head>
    <title>Adicionar Dados de Teste</title>
    <style>
        body { font-family: Arial; padding: 20px; background: #f5f5f5; }
        .container { max-width: 800px; margin: 0 auto; background: white; padding: 20px; border-radius: 10px; }
        .success { color: green; font-weight: bold; }
        .error { color: red; }
        .info { background: #e3f2fd; padding: 10px; border-radius: 5px; margin: 10px 0; }
        button { padding: 10px 20px; margin: 5px; cursor: pointer; }
    </style>
</head>
<body>
    <div class="container">
        <h1>🔧 Adicionar Dados de Teste para Dublin Core</h1>
        
        <div class="info">
            <p><strong>Situação Atual:</strong></p>
            <ul>
                <li>Workflow: 30144</li>
                <li>Step Brainstorming: 50380</li>
                <li>Não há steps anteriores no workflow (50380 é o primeiro)</li>
            </ul>
            <p><strong>Solução:</strong> Vamos criar dois steps fictícios com IDs menores para simular dados anteriores.</p>
        </div>
        
        <%
        Dim action
        action = Request.QueryString("action")
        
        If action = "create" Then
            Response.Write "<h2>Criando Dados de Teste...</h2>"
            
            On Error Resume Next
            
            ' 1. Criar um step fictício para Bibliometrics (ID menor que 50380)
            Dim biblioStepID
            biblioStepID = 50370 ' ID menor que 50380
            
            Response.Write "<h3>1. Criando Step Bibliometrics (ID: " & biblioStepID & ")</h3>"
            
            ' Verificar se já existe
            call getRecordSet("SELECT * FROM T_WORKFLOW_STEP WHERE stepID = " & biblioStepID, rs)
            If rs.EOF Then
                ' Criar o step
                Dim sql
                sql = "INSERT INTO T_WORKFLOW_STEP (stepID, workflowID, type, status) " & _
                      "VALUES (" & biblioStepID & ", 30144, 1, 4)"
                      
                call ExecuteSQL(sql)
                
                If Err.Number = 0 Then
                    Response.Write "<p class='success'>✓ Step criado com sucesso</p>"
                Else
                    Response.Write "<p class='error'>✗ Erro ao criar step: " & Err.Description & "</p>"
                    Err.Clear
                End If
            Else
                Response.Write "<p>Step já existe</p>"
            End If
            
            ' Adicionar algumas referências bibliométricas de teste
            Response.Write "<h4>Adicionando referências bibliométricas...</h4>"
            
            ' Limpar dados existentes
            call ExecuteSQL("DELETE FROM T_FTA_METHOD_BIBLIOMETRICS WHERE stepID = " & biblioStepID)
            
            ' Adicionar 5 referências de exemplo
            Dim titles(4), years(4), i
            titles(0) = "Artificial Intelligence in Future Studies: A Comprehensive Review"
            titles(1) = "Machine Learning Applications for Scenario Planning"
            titles(2) = "Digital Transformation and Strategic Foresight"
            titles(3) = "Innovation Management in the Age of AI"
            titles(4) = "Future Technologies: Trends and Implications"
            
            years(0) = 2023
            years(1) = 2023
            years(2) = 2024
            years(3) = 2024
            years(4) = 2025
            
            For i = 0 To 4
                ' T_FTA_METHOD_BIBLIOMETRICS precisa do campo email
                sql = "INSERT INTO T_FTA_METHOD_BIBLIOMETRICS (stepID, title, year, email) " & _
                      "VALUES (" & biblioStepID & ", '" & titles(i) & "', " & years(i) & ", 'teste@example.com')"
                
                call ExecuteSQL(sql)
                
                If Err.Number = 0 Then
                    Response.Write "<p>✓ Adicionada: " & titles(i) & "</p>"
                    
                    ' Buscar o ID da referência recém-criada
                    call getRecordSet("SELECT MAX(referenceID) as maxID FROM T_FTA_METHOD_BIBLIOMETRICS", rs)
                    If Not rs.EOF Then
                        Dim refID
                        refID = rs("maxID")
                        
                        ' Adicionar alguns autores
                        sql = "INSERT INTO T_FTA_METHOD_BIBLIOMETRICS_AUTHORS (referenceID, name) " & _
                              "VALUES (" & refID & ", 'Smith, J.')"
                        call ExecuteSQL(sql)
                        
                        sql = "INSERT INTO T_FTA_METHOD_BIBLIOMETRICS_AUTHORS (referenceID, name) " & _
                              "VALUES (" & refID & ", 'Johnson, M.')"
                        call ExecuteSQL(sql)
                    End If
                Else
                    Response.Write "<p class='error'>✗ Erro: " & Err.Description & "</p>"
                    Err.Clear
                End If
            Next
            
            ' 2. Criar um step fictício para Scenarios
            Dim scenarioStepID
            scenarioStepID = 50375 ' ID menor que 50380
            
            Response.Write "<h3>2. Criando Step Scenarios (ID: " & scenarioStepID & ")</h3>"
            
            ' Verificar se já existe
            call getRecordSet("SELECT * FROM T_WORKFLOW_STEP WHERE stepID = " & scenarioStepID, rs)
            If rs.EOF Then
                sql = "INSERT INTO T_WORKFLOW_STEP (stepID, workflowID, type, status) " & _
                      "VALUES (" & scenarioStepID & ", 30144, 2, 4)"
                      
                call ExecuteSQL(sql)
                
                If Err.Number = 0 Then
                    Response.Write "<p class='success'>✓ Step criado com sucesso</p>"
                Else
                    Response.Write "<p class='error'>✗ Erro ao criar step: " & Err.Description & "</p>"
                    Err.Clear
                End If
            Else
                Response.Write "<p>Step já existe</p>"
            End If
            
            ' Adicionar alguns cenários de teste
            Response.Write "<h4>Adicionando cenários...</h4>"
            
            ' Limpar dados existentes
            call ExecuteSQL("DELETE FROM T_FTA_METHOD_SCENARIOS WHERE stepID = " & scenarioStepID)
            
            ' Adicionar 3 cenários
            Dim scenarioNames(2), scenarioDescs(2)
            scenarioNames(0) = "Cenário Otimista"
            scenarioNames(1) = "Cenário Realista"
            scenarioNames(2) = "Cenário Pessimista"
            
            scenarioDescs(0) = "Em 2030, a IA transformou completamente a sociedade. A automação liberou as pessoas para atividades criativas, a educação é personalizada e acessível globalmente, e a sustentabilidade foi alcançada através de tecnologias verdes."
            scenarioDescs(1) = "Em 2030, a IA está integrada em muitos aspectos da vida, mas com desafios. Há progresso significativo em algumas áreas, mas questões de privacidade, emprego e ética ainda são debatidas. A transição é gradual e desigual."
            scenarioDescs(2) = "Em 2030, o desenvolvimento descontrolado da IA criou novos problemas. O desemprego tecnológico é alto, a desigualdade aumentou, e há conflitos sobre controle de dados e poder das big techs."
            
            For i = 0 To 2
                ' T_FTA_METHOD_SCENARIOS precisa do campo description
                sql = "INSERT INTO T_FTA_METHOD_SCENARIOS (stepID, name, scenario, description) " & _
                      "VALUES (" & scenarioStepID & ", '" & scenarioNames(i) & "', '" & _
                      Replace(scenarioDescs(i), "'", "''") & "', '" & _
                      "Descrição do " & scenarioNames(i) & "')"
                
                call ExecuteSQL(sql)
                
                If Err.Number = 0 Then
                    Response.Write "<p>✓ Adicionado: " & scenarioNames(i) & "</p>"
                Else
                    Response.Write "<p class='error'>✗ Erro: " & Err.Description & "</p>"
                    Err.Clear
                End If
            Next
            
            On Error Goto 0
            
            Response.Write "<hr>"
            Response.Write "<h2 class='success'>✓ Dados de teste criados com sucesso!</h2>"
            Response.Write "<p>Agora você pode testar a integração Dublin Core no Brainstorming.</p>"
            
        ElseIf action = "check" Then
            ' Verificar dados existentes
            Response.Write "<h2>Verificando Dados Existentes...</h2>"
            
            On Error Resume Next
            
            ' Verificar Bibliometrics
            Response.Write "<h3>Bibliometrics (Step 50370)</h3>"
            call getRecordSet("SELECT COUNT(*) as total FROM T_FTA_METHOD_BIBLIOMETRICS WHERE stepID = 50370", rs)
            If Not rs.EOF Then
                Response.Write "<p>Total de referências: " & rs("total") & "</p>"
            End If
            
            ' Verificar Scenarios
            Response.Write "<h3>Scenarios (Step 50375)</h3>"
            call getRecordSet("SELECT COUNT(*) as total FROM T_FTA_METHOD_SCENARIOS WHERE stepID = 50375", rs)
            If Not rs.EOF Then
                Response.Write "<p>Total de cenários: " & rs("total") & "</p>"
            End If
            
            On Error Goto 0
            
        Else
            ' Página inicial
            %>
            <h2>O que este script faz:</h2>
            <ol>
                <li>Cria dois steps fictícios com IDs menores (50370 e 50375)</li>
                <li>Adiciona dados de teste do Bibliometrics no step 50370</li>
                <li>Adiciona cenários de teste no step 50375</li>
                <li>Esses dados estarão disponíveis via Dublin Core no Brainstorming</li>
            </ol>
            
            <div style="margin: 20px 0;">
                <button onclick="location.href='?action=check'" style="background: #2196F3; color: white;">
                    🔍 Verificar Dados Existentes
                </button>
                <button onclick="if(confirm('Criar dados de teste?')) location.href='?action=create'" style="background: #4CAF50; color: white;">
                    ➕ Criar Dados de Teste
                </button>
            </div>
            <%
        End If
        %>
        
        <hr>
        <div style="margin-top: 20px;">
            <a href="testDublinCore.asp" style="padding: 10px 20px; background: #FF9800; color: white; text-decoration: none; border-radius: 5px;">
                🔍 Testar Dublin Core
            </a>
            <a href="manageIdea.asp?stepID=50380&brainstormingID=20021&action=add" style="padding: 10px 20px; background: #4CAF50; color: white; text-decoration: none; border-radius: 5px; margin-left: 10px;">
                ➕ Criar Nova Ideia
            </a>
            <a href="index.asp?stepID=50380" style="padding: 10px 20px; background: #2196F3; color: white; text-decoration: none; border-radius: 5px; margin-left: 10px;">
                📋 Voltar ao Brainstorming
            </a>
        </div>
    </div>
</body>
</html>