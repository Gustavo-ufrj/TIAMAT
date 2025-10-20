<!--#include virtual="/system.asp"-->

<%
Dim stepID
stepID = Request.QueryString("stepID")
If stepID = "" Then stepID = "70391"

Dim action
action = Request.QueryString("action")
%>

<!DOCTYPE html>
<html>
<head>
    <title>Fix EndStep Error - Step <%=stepID%></title>
    <style>
        body { font-family: Arial; margin: 20px; }
        .section { background: #f8f9fa; padding: 15px; margin: 10px 0; border-radius: 5px; }
        .success { background: #d4edda; color: #155724; }
        .error { background: #f8d7da; color: #721c24; }
        .info { background: #d1ecf1; color: #0c5460; }
        table { width: 100%; border-collapse: collapse; margin: 10px 0; }
        th, td { border: 1px solid #ddd; padding: 8px; text-align: left; }
        th { background: #f2f2f2; }
        pre { background: #f8f9fa; padding: 10px; border: 1px solid #ddd; }
    </style>
</head>
<body>
    <h1>Fix EndStep Error - Step <%=stepID%></h1>
    
    <%If action = "fix" Then%>
    <!-- EXECUTAR CORREÇÃO -->
    <div class="section">
        <h2>Executando Correção da Função endStep</h2>
        <%
        On Error Resume Next
        
        Response.Write "<h3>Tentando finalizar step manualmente...</h3>"
        
        ' Método 1: Atualizar status diretamente na tabela T_WORKFLOW_STEP
        Call ExecuteSQL("UPDATE T_WORKFLOW_STEP SET status = 4 WHERE stepID = " & stepID)
        
        If Err.Number = 0 Then
            Response.Write "<p class='success'>Status atualizado na T_WORKFLOW_STEP</p>"
        Else
            Response.Write "<p class='error'>Erro ao atualizar T_WORKFLOW_STEP: " & Err.Description & "</p>"
        End If
        Err.Clear
        
        ' Método 2: Verificar se existe na tiamat_steps e atualizar
        Call getRecordSet("SELECT COUNT(*) as existe FROM tiamat_steps WHERE stepID = " & stepID, rs)
        If Not rs.EOF And rs("existe") > 0 Then
            Call ExecuteSQL("UPDATE tiamat_steps SET status = 4 WHERE stepID = " & stepID)
            If Err.Number = 0 Then
                Response.Write "<p class='success'>Status atualizado na tiamat_steps</p>"
            Else
                Response.Write "<p class='error'>Erro ao atualizar tiamat_steps: " & Err.Description & "</p>"
            End If
        Else
            Response.Write "<p class='info'>Step não existe na tiamat_steps</p>"
        End If
        Err.Clear
        
        ' Método 3: Salvar dados do Futures Wheel no Dublin Core (se houver eventos)
        Call getRecordSet("SELECT COUNT(*) as total FROM T_FTA_METHOD_FUTURES_WHEEL WHERE stepID = " & stepID, rs)
        If Not rs.EOF And rs("total") > 0 Then
            Response.Write "<h3>Salvando eventos do Futures Wheel no Dublin Core...</h3>"
            
            ' Limpar dados antigos
            Call ExecuteSQL("DELETE FROM tiamat_dublin_core WHERE stepID = " & stepID & " AND dc_type = 'futures_wheel'")
            
            ' Buscar eventos do Futures Wheel
            Call getRecordSet("SELECT fwID, event FROM T_FTA_METHOD_FUTURES_WHEEL WHERE stepID = " & stepID, rs)
            
            Dim eventCount
            eventCount = 0
            
            While Not rs.EOF
                Dim eventTitle, sqlInsert
                eventTitle = Replace(rs("event"), "'", "''")
                
                sqlInsert = "INSERT INTO tiamat_dublin_core " & _
                           "(stepID, dc_title, dc_creator, dc_description, dc_type, dc_date, dc_source) " & _
                           "VALUES (" & stepID & ", " & _
                           "'" & eventTitle & "', " & _
                           "'System', " & _
                           "'" & eventTitle & "', " & _
                           "'futures_wheel', " & _
                           "GETDATE(), " & _
                           "'Futures Wheel Step " & stepID & "')"
                
                Call ExecuteSQL(sqlInsert)
                If Err.Number = 0 Then
                    eventCount = eventCount + 1
                End If
                Err.Clear
                
                rs.MoveNext
            Wend
            
            Response.Write "<p class='success'>Salvos " & eventCount & " eventos do Futures Wheel no Dublin Core</p>"
        End If
        
        ' Método 4: Ativar próximos steps do workflow
        Response.Write "<h3>Ativando próximos steps...</h3>"
        Call getRecordSet("SELECT workflowID FROM T_WORKFLOW_STEP WHERE stepID = " & stepID, rs)
        If Not rs.EOF Then
            Dim workflowID
            workflowID = rs("workflowID")
            
            ' Ativar próximos steps (status 2 -> 3)
            Call ExecuteSQL("UPDATE T_WORKFLOW_STEP SET status = 3 WHERE workflowID = " & workflowID & " AND stepID > " & stepID & " AND status = 2")
            If Err.Number = 0 Then
                Response.Write "<p class='success'>Próximos steps ativados</p>"
            End If
        End If
        
        Response.Write "<h3>Finalização manual concluída!</h3>"
        Response.Write "<p class='success'>O step foi finalizado sem usar a função endStep() problemática.</p>"
        
        On Error GoTo 0
        %>
    </div>
    
    <%ElseIf action = "remove_summary" Then%>
    <!-- REMOVER RESUMO DO BRAINSTORMING -->
    <div class="section">
        <h2>Removendo Resumo do Brainstorming</h2>
        <%
        On Error Resume Next
        
        Call ExecuteSQL("DELETE FROM tiamat_dublin_core WHERE stepID = 70390 AND dc_title = 'Brainstorming Session Summary'")
        
        If Err.Number = 0 Then
            Response.Write "<p class='success'>Resumo do brainstorming removido do Dublin Core</p>"
            Response.Write "<p>Agora só aparecerão as 3 ideias sem o resumo</p>"
        Else
            Response.Write "<p class='error'>Erro ao remover resumo: " & Err.Description & "</p>"
        End If
        
        On Error GoTo 0
        %>
    </div>
    
    <%Else%>
    <!-- DIAGNÓSTICO INICIAL -->
    <div class="section">
        <h2>1. Diagnóstico do Erro</h2>
        
        <p><strong>Erro:</strong> "Nome de coluna 'FTAMethodID' inválido"</p>
        <p><strong>Local:</strong> /system.asp, linha 133</p>
        <p><strong>Causa:</strong> A função endStep() está tentando acessar uma coluna que não existe</p>
        
        <h3>Verificar estrutura da tabela T_WORKFLOW_STEP:</h3>
        <%
        Call getRecordSet("SELECT TOP 1 * FROM T_WORKFLOW_STEP WHERE stepID = " & stepID, rs)
        If Not rs.EOF Then
            Response.Write "<table>"
            Response.Write "<tr>"
            For i = 0 to rs.Fields.Count - 1
                Response.Write "<th>" & rs.Fields(i).Name & "</th>"
            Next
            Response.Write "</tr>"
            Response.Write "<tr>"
            For i = 0 to rs.Fields.Count - 1
                Response.Write "<td>" & rs.Fields(i).Value & "</td>"
            Next
            Response.Write "</tr>"
            Response.Write "</table>"
        End If
        %>
        
        <p class='info'>Como você pode ver, a tabela tem 'methodID' mas o sistema está procurando 'FTAMethodID'</p>
    </div>
    
    <div class="section">
        <h2>2. Opções de Correção</h2>
        
        <h3>Opção 1: Finalizar Manualmente (RECOMENDADO)</h3>
        <p>Finalizar o step sem usar a função endStep() problemática</p>
        <p><a href="?stepID=<%=stepID%>&action=fix" 
             style="padding: 10px 20px; background: #28a745; color: white; text-decoration: none; border-radius: 5px;">
             Finalizar Step Manualmente</a></p>
        
        <h3>Opção 2: Remover Resumo do Brainstorming</h3>
        <p>Se você não quer que apareça o resumo "Brainstorming Session Summary"</p>
        <p><a href="?stepID=70390&action=remove_summary" 
             style="padding: 10px 20px; background: #ffc107; color: black; text-decoration: none; border-radius: 5px;">
             Remover Resumo</a></p>
    </div>
    
    <div class="section">
        <h2>3. Status Atual do Step</h2>
        <%
        Call getRecordSet("SELECT * FROM T_WORKFLOW_STEP WHERE stepID = " & stepID, rs)
        If Not rs.EOF Then
            Response.Write "<p>Step ID: " & rs("stepID") & "</p>"
            Response.Write "<p>Workflow ID: " & rs("workflowID") & "</p>"
            Response.Write "<p>Status: " & rs("status") & "</p>"
            Response.Write "<p>Method ID: " & rs("methodID") & "</p>"
            
            If rs("status") = 4 Then
                Response.Write "<p class='success'>Step já está finalizado!</p>"
            Else
                Response.Write "<p class='info'>Step precisa ser finalizado (status atual: " & rs("status") & ")</p>"
            End If
        End If
        %>
    </div>
    <%End If%>
    
    <div class="section info">
        <h2>Links Úteis</h2>
        <ul>
            <li><a href="/workplace.asp">Voltar ao Workplace</a></li>
            <li><a href="../fw/index.asp?stepID=<%=stepID%>">Voltar ao Futures Wheel</a></li>
            <li><a href="../fw/dcData.asp?stepID=<%=stepID%>">Testar Dublin Core Data</a></li>
        </ul>
    </div>
    
</body>
</html>