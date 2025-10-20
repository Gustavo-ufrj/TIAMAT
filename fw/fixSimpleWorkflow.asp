<%
' Script simplificado sem includes para evitar conflitos ADO
Response.Expires = -1
Response.CacheControl = "no-cache"

Dim action
action = Request.QueryString("action")
%>

<!DOCTYPE html>
<html>
<head>
    <title>Fix Workflow Sequence - Simple</title>
    <style>
        body { font-family: Arial; margin: 20px; }
        .section { background: #f8f9fa; padding: 15px; margin: 10px 0; border-radius: 5px; }
        .success { background: #d4edda; color: #155724; }
        .error { background: #f8d7da; color: #721c24; }
        .info { background: #d1ecf1; color: #0c5460; }
    </style>
</head>
<body>
    <h1>Fix Workflow Sequence - Simple Version</h1>
    
    <%If action = "fix" Then%>
    <div class="section">
        <h2>Executando Correção SQL Direta</h2>
        <%
        On Error Resume Next
        
        ' Conectar ao banco sem usar funções do sistema
        Set conn = Server.CreateObject("ADODB.Connection")
        conn.Open Application("ConnectionString")
        
        ' CORREÇÃO 1: Bloquear scenarios (step 70393)
        Response.Write "<h3>1. Bloqueando Scenarios...</h3>"
        conn.Execute("UPDATE T_WORKFLOW_STEP SET status = 2 WHERE stepID = 70393")
        If Err.Number = 0 Then
            Response.Write "<p class='success'>Scenarios bloqueado (step 70393)</p>"
        Else
            Response.Write "<p class='error'>Erro: " & Err.Description & "</p>"
        End If
        Err.Clear
        
        ' CORREÇÃO 2: Garantir que roadmap está ativo (step 70392)
        Response.Write "<h3>2. Ativando Roadmap...</h3>"
        conn.Execute("UPDATE T_WORKFLOW_STEP SET status = 3 WHERE stepID = 70392")
        If Err.Number = 0 Then
            Response.Write "<p class='success'>Roadmap ativo (step 70392)</p>"
        Else
            Response.Write "<p class='error'>Erro: " & Err.Description & "</p>"
        End If
        Err.Clear
        
        ' CORREÇÃO 3: Salvar eventos do Futures Wheel no Dublin Core
        Response.Write "<h3>3. Salvando eventos do Futures Wheel...</h3>"
        
        ' Limpar dados antigos
        conn.Execute("DELETE FROM tiamat_dublin_core WHERE stepID = 70391 AND dc_type = 'futures_wheel'")
        
        ' Buscar eventos do Futures Wheel
        Set rs = conn.Execute("SELECT fwID, event FROM T_FTA_METHOD_FUTURES_WHEEL WHERE stepID = 70391")
        
        Dim eventCount
        eventCount = 0
        
        If Not rs.EOF Then
            Do While Not rs.EOF
                Dim eventTitle, sqlInsert
                eventTitle = Replace(rs("event"), "'", "''")
                
                If Len(eventTitle) > 200 Then eventTitle = Left(eventTitle, 200) & "..."
                
                sqlInsert = "INSERT INTO tiamat_dublin_core " & _
                           "(stepID, dc_title, dc_creator, dc_description, dc_type, dc_date, dc_source) " & _
                           "VALUES (70391, " & _
                           "'" & eventTitle & "', " & _
                           "'System', " & _
                           "'" & eventTitle & "', " & _
                           "'futures_wheel', " & _
                           "GETDATE(), " & _
                           "'Futures Wheel Step 70391')"
                
                conn.Execute(sqlInsert)
                If Err.Number = 0 Then
                    eventCount = eventCount + 1
                    Response.Write "<p class='success'>Evento salvo: " & Left(eventTitle, 40) & "...</p>"
                Else
                    Response.Write "<p class='error'>Erro ao salvar: " & Err.Description & "</p>"
                End If
                Err.Clear
                
                rs.MoveNext
            Loop
        End If
        rs.Close
        
        Response.Write "<p class='success'>Total de eventos salvos: " & eventCount & "</p>"
        
        conn.Close
        Set conn = Nothing
        
        Response.Write "<h3>Correção Concluída!</h3>"
        Response.Write "<p class='info'>Agora teste o 'View DC' no roadmap</p>"
        
        On Error GoTo 0
        %>
    </div>
    
    <%ElseIf action = "manual" Then%>
    <div class="section">
        <h2>Comandos SQL Manuais</h2>
        <p>Se preferir, execute estes comandos SQL diretamente no banco:</p>
        
        <h3>1. Bloquear Scenarios:</h3>
        <pre style="background: #f8f9fa; padding: 10px; border: 1px solid #ddd;">
UPDATE T_WORKFLOW_STEP SET status = 2 WHERE stepID = 70393
        </pre>
        
        <h3>2. Ativar Roadmap:</h3>
        <pre style="background: #f8f9fa; padding: 10px; border: 1px solid #ddd;">
UPDATE T_WORKFLOW_STEP SET status = 3 WHERE stepID = 70392
        </pre>
        
        <h3>3. Salvar Eventos do Futures Wheel:</h3>
        <pre style="background: #f8f9fa; padding: 10px; border: 1px solid #ddd;">
DELETE FROM tiamat_dublin_core WHERE stepID = 70391 AND dc_type = 'futures_wheel';

INSERT INTO tiamat_dublin_core (stepID, dc_title, dc_creator, dc_description, dc_type, dc_date, dc_source)
SELECT 70391, event, 'System', event, 'futures_wheel', GETDATE(), 'Futures Wheel Step 70391'
FROM T_FTA_METHOD_FUTURES_WHEEL 
WHERE stepID = 70391;
        </pre>
    </div>
    
    <%Else%>
    <div class="section">
        <h2>Problema Identificado</h2>
        <p>O erro "Redefinição do nome" no ADOVBS.INC indica conflito de includes.</p>
        
        <h3>Soluções:</h3>
        <p><a href="?action=fix" style="padding: 10px 20px; background: #28a745; color: white; text-decoration: none; border-radius: 5px;">
           Executar Correção Direta</a></p>
           
        <p><a href="?action=manual" style="padding: 10px 20px; background: #007bff; color: white; text-decoration: none; border-radius: 5px;">
           Ver Comandos SQL Manuais</a></p>
    </div>
    
    <div class="section info">
        <h2>Status Atual</h2>
        <p>Roadmap e Scenarios estão ambos verdes, mas apenas o Roadmap deveria estar ativo.</p>
        <p>Os eventos do Futures Wheel não estão aparecendo no Dublin Core do roadmap.</p>
    </div>
    <%End If%>
    
    <div class="section">
        <h2>Links</h2>
        <ul>
            <li><a href="/workplace.asp">Workplace</a></li>
            <li><a href="../roadmap/dcData.asp?stepID=70392">Testar Dublin Core do Roadmap</a></li>
        </ul>
    </div>
    
</body>
</html>