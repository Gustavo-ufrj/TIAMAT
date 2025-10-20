<!--#include virtual="/system.asp"-->

<%
Dim stepID
stepID = Request.QueryString("stepID")
If stepID = "" Then stepID = "70390"

Dim action
action = Request.QueryString("action")
%>

<!DOCTYPE html>
<html>
<head>
    <title>Fix Foreign Key Issue - Step <%=stepID%></title>
    <style>
        body { font-family: Arial; margin: 20px; }
        .section { background: #f8f9fa; padding: 15px; margin: 10px 0; border-radius: 5px; }
        .success { background: #d4edda; color: #155724; }
        .error { background: #f8d7da; color: #721c24; }
        .info { background: #d1ecf1; color: #0c5460; }
        .warning { background: #fff3cd; color: #856404; }
        table { width: 100%; border-collapse: collapse; margin: 10px 0; }
        th, td { border: 1px solid #ddd; padding: 8px; text-align: left; }
        th { background: #f2f2f2; }
    </style>
</head>
<body>
    <h1>Fix Foreign Key Issue - Step <%=stepID%></h1>
    
    <!-- 1. VERIFICAR TABELAS DE STEPS -->
    <div class="section">
        <h2>1. Verificar Tabelas de Steps</h2>
        
        <h3>T_WORKFLOW_STEP (tabela original):</h3>
        <%
        Call getRecordSet("SELECT * FROM T_WORKFLOW_STEP WHERE stepID = " & stepID, rs)
        If Not rs.EOF Then
            Response.Write "<p class='success'>Step " & stepID & " encontrado na T_WORKFLOW_STEP:</p>"
            Response.Write "<table>"
            Response.Write "<tr><th>stepID</th><th>workflowID</th><th>status</th><th>methodID</th></tr>"
            Response.Write "<tr>"
            Response.Write "<td>" & rs("stepID") & "</td>"
            Response.Write "<td>" & rs("workflowID") & "</td>"
            Response.Write "<td>" & rs("status") & "</td>"
            Response.Write "<td>" & rs("methodID") & "</td>"
            Response.Write "</tr></table>"
        Else
            Response.Write "<p class='error'>Step " & stepID & " NÃO encontrado na T_WORKFLOW_STEP</p>"
        End If
        %>
        
        <h3>tiamat_steps (tabela nova para FK):</h3>
        <%
        On Error Resume Next
        Call getRecordSet("SELECT * FROM tiamat_steps WHERE stepID = " & stepID, rs)
        If Err.Number = 0 Then
            If Not rs.EOF Then
                Response.Write "<p class='success'>Step " & stepID & " encontrado na tiamat_steps:</p>"
                Response.Write "<table>"
                Response.Write "<tr><th>stepID</th><th>workflowID</th><th>status</th><th>methodID</th></tr>"
                Response.Write "<tr>"
                Response.Write "<td>" & rs("stepID") & "</td>"
                Response.Write "<td>" & rs("workflowID") & "</td>"
                Response.Write "<td>" & rs("status") & "</td>"
                Response.Write "<td>" & rs("methodID") & "</td>"
                Response.Write "</tr></table>"
            Else
                Response.Write "<p class='error'>Step " & stepID & " NÃO encontrado na tiamat_steps</p>"
                Response.Write "<p class='warning'>ESTE É O PROBLEMA! A FK referencia tiamat_steps mas o step não está lá.</p>"
            End If
        Else
            Response.Write "<p class='error'>Tabela tiamat_steps não existe ou erro de acesso: " & Err.Description & "</p>"
        End If
        Err.Clear
        On Error GoTo 0
        %>
    </div>
    
    <%If action = "fix" Then%>
    <!-- EXECUTAR CORREÇÃO -->
    <div class="section">
        <h2>Executando Correção</h2>
        <%
        On Error Resume Next
        
        ' Opção 1: Inserir o step na tabela tiamat_steps
        Call getRecordSet("SELECT * FROM T_WORKFLOW_STEP WHERE stepID = " & stepID, rs)
        If Not rs.EOF Then
            Dim workflowID, status, methodID
            workflowID = rs("workflowID")
            status = rs("status")
            methodID = rs("methodID")
            
            Response.Write "<p>Tentando inserir step na tabela tiamat_steps...</p>"
            
            Dim sqlInsert
            sqlInsert = "INSERT INTO tiamat_steps (stepID, workflowID, status, methodID) " & _
                       "VALUES (" & stepID & ", " & workflowID & ", " & status & ", " & methodID & ")"
            
            Call ExecuteSQL(sqlInsert)
            
            If Err.Number = 0 Then
                Response.Write "<p class='success'>Step inserido com sucesso na tiamat_steps!</p>"
                
                ' Agora tentar inserir no Dublin Core
                Response.Write "<p>Agora tentando inserir no Dublin Core...</p>"
                
                Dim sqlDC
                sqlDC = "INSERT INTO tiamat_dublin_core (stepID, dc_title, dc_creator, dc_description, dc_type) " & _
                       "VALUES (" & stepID & ", 'TESTE CORRIGIDO', 'System', 'Teste após correção FK', 'brainstorming')"
                
                Call ExecuteSQL(sqlDC)
                
                If Err.Number = 0 Then
                    Response.Write "<p class='success'>SUCESSO! Dados inseridos no Dublin Core após correção!</p>"
                Else
                    Response.Write "<p class='error'>Ainda há erro no Dublin Core: " & Err.Description & "</p>"
                End If
            Else
                Response.Write "<p class='error'>Erro ao inserir na tiamat_steps: " & Err.Description & "</p>"
            End If
        End If
        
        Err.Clear
        On Error GoTo 0
        %>
    </div>
    
    <%ElseIf action = "alternative" Then%>
    <!-- SOLUÇÃO ALTERNATIVA -->
    <div class="section">
        <h2>Testando Solução Alternativa</h2>
        <%
        Response.Write "<p>Tentando remover temporariamente a FK ou usar outra abordagem...</p>"
        
        On Error Resume Next
        
        ' Tentar desabilitar a FK temporariamente
        Call ExecuteSQL("ALTER TABLE tiamat_dublin_core NOCHECK CONSTRAINT FK_dublin_core_step")
        
        If Err.Number = 0 Then
            Response.Write "<p class='success'>FK temporariamente desabilitada</p>"
            
            ' Tentar inserir
            Dim sqlTest
            sqlTest = "INSERT INTO tiamat_dublin_core (stepID, dc_title, dc_creator, dc_description, dc_type) " & _
                     "VALUES (" & stepID & ", 'TESTE SEM FK', 'System', 'Teste sem FK', 'brainstorming')"
            
            Call ExecuteSQL(sqlTest)
            
            If Err.Number = 0 Then
                Response.Write "<p class='success'>Inserção funcionou sem FK!</p>"
                
                ' Reabilitar FK
                Call ExecuteSQL("ALTER TABLE tiamat_dublin_core CHECK CONSTRAINT FK_dublin_core_step")
                Response.Write "<p>FK reabilitada</p>"
            Else
                Response.Write "<p class='error'>Ainda há erro mesmo sem FK: " & Err.Description & "</p>"
                Call ExecuteSQL("ALTER TABLE tiamat_dublin_core CHECK CONSTRAINT FK_dublin_core_step")
            End If
        Else
            Response.Write "<p class='error'>Não foi possível desabilitar FK: " & Err.Description & "</p>"
        End If
        
        Err.Clear
        On Error GoTo 0
        %>
    </div>
    
    <%Else%>
    <!-- OPÇÕES DE CORREÇÃO -->
    <div class="section">
        <h2>2. Opções de Correção</h2>
        
        <div class="info">
            <h3>Problema Identificado:</h3>
            <p>A tabela <code>tiamat_dublin_core</code> tem uma foreign key que referencia <code>tiamat_steps.stepID</code>, 
            mas o step <%=stepID%> não existe nesta tabela.</p>
        </div>
        
        <h3>Opção 1: Sincronizar Steps</h3>
        <p>Copiar o step da tabela original T_WORKFLOW_STEP para tiamat_steps</p>
        <p><a href="?stepID=<%=stepID%>&action=fix" style="padding: 10px 20px; background: #28a745; color: white; text-decoration: none; border-radius: 5px;">Executar Correção</a></p>
        
        <h3>Opção 2: Solução Alternativa</h3>
        <p>Testar inserção sem FK temporariamente</p>
        <p><a href="?stepID=<%=stepID%>&action=alternative" style="padding: 10px 20px; background: #ffc107; color: black; text-decoration: none; border-radius: 5px;">Testar Alternativa</a></p>
    </div>
    
    <div class="section warning">
        <h2>3. Verificar Outros Steps</h2>
        <p>Vamos verificar se outros steps também têm esse problema:</p>
        <%
        ' Verificar quantos steps da T_WORKFLOW_STEP não estão na tiamat_steps
        On Error Resume Next
        Call getRecordSet("SELECT COUNT(*) as missing FROM T_WORKFLOW_STEP ws " & _
                         "WHERE NOT EXISTS (SELECT 1 FROM tiamat_steps ts WHERE ts.stepID = ws.stepID)", rs)
        If Err.Number = 0 And Not rs.EOF Then
            Response.Write "<p>Steps faltando na tiamat_steps: <strong>" & rs("missing") & "</strong></p>"
            If rs("missing") > 0 Then
                Response.Write "<p class='warning'>Vários steps podem precisar ser sincronizados!</p>"
            End If
        End If
        Err.Clear
        On Error GoTo 0
        %>
    </div>
    <%End If%>
    
    <div class="section info">
        <h2>Links Úteis</h2>
        <ul>
            <li><a href="testDublinCoreInsert.asp?stepID=<%=stepID%>">Voltar ao Teste de Inserção</a></li>
            <li><a href="debugBrainstorming.asp?stepID=<%=stepID%>">Debug Brainstorming</a></li>
            <li><a href="finalizeBrainstorming.asp?stepID=<%=stepID%>&action=finalize">Tentar Finalizar Após Correção</a></li>
        </ul>
    </div>
    
</body>
</html>