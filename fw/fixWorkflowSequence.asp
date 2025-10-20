<!--#include virtual="/system.asp"-->

<%
Dim action
action = Request.QueryString("action")

Dim stepID
stepID = Request.QueryString("stepID")
If stepID = "" Then stepID = "70391" ' Futures Wheel step
%>

<!DOCTYPE html>
<html>
<head>
    <title>Fix Workflow Sequence</title>
    <style>
        body { font-family: Arial; margin: 20px; }
        .section { background: #f8f9fa; padding: 15px; margin: 10px 0; border-radius: 5px; }
        .success { background: #d4edda; color: #155724; }
        .error { background: #f8d7da; color: #721c24; }
        .info { background: #d1ecf1; color: #0c5460; }
        table { width: 100%; border-collapse: collapse; margin: 10px 0; }
        th, td { border: 1px solid #ddd; padding: 8px; text-align: left; }
        th { background: #f2f2f2; }
    </style>
</head>
<body>
    <h1>Fix Workflow Sequence</h1>
    
    <%If action = "fix" Then%>
    <!-- EXECUTAR CORREÇÃO -->
    <div class="section">
        <h2>Executando Correção da Sequência do Workflow</h2>
        <%
        On Error Resume Next
        
        ' PROBLEMA 1: Corrigir sequência dos steps
        Response.Write "<h3>1. Corrigindo sequência dos steps...</h3>"
        
        ' Buscar workflowID
        Call getRecordSet("SELECT workflowID FROM T_WORKFLOW_STEP WHERE stepID = " & stepID, rs)
        If Not rs.EOF Then
            Dim workflowID
            workflowID = rs("workflowID")
            
            ' Roadmap deve ficar ativo (status 3)
            Call ExecuteSQL("UPDATE T_WORKFLOW_STEP SET status = 3 WHERE workflowID = " & workflowID & " AND stepID = 70392")
            Response.Write "<p class='success'>Roadmap ativado (step 70392)</p>"
            
            ' Scenarios deve ficar bloqueado (status 2) até roadmap ser finalizado
            Call ExecuteSQL("UPDATE T_WORKFLOW_STEP SET status = 2 WHERE workflowID = " & workflowID & " AND stepID = 70393")
            Response.Write "<p class='success'>Scenarios voltou para bloqueado (step 70393)</p>"
        End If
        
        ' PROBLEMA 2: Corrigir dados do Futures Wheel no Dublin Core
        Response.Write "<h3>2. Corrigindo dados do Futures Wheel no Dublin Core...</h3>"
        
        ' Verificar se os eventos do Futures Wheel foram salvos corretamente
        Call getRecordSet("SELECT COUNT(*) as total FROM tiamat_dublin_core WHERE stepID = " & stepID & " AND dc_type = 'futures_wheel'", rs)
        If Not rs.EOF Then
            Response.Write "<p>Registros atuais no Dublin Core: " & rs("total") & "</p>"
        End If
        
        ' Verificar eventos na tabela original
        Call getRecordSet("SELECT COUNT(*) as total FROM T_FTA_METHOD_FUTURES_WHEEL WHERE stepID = " & stepID, rs)
        If Not rs.EOF And rs("total") > 0 Then
            Response.Write "<p>Eventos na tabela original: " & rs("total") & "</p>"
            
            ' Limpar e reinserir corretamente
            Call ExecuteSQL("DELETE FROM tiamat_dublin_core WHERE stepID = " & stepID & " AND dc_type = 'futures_wheel'")
            
            ' Reinserir eventos do Futures Wheel
            Call getRecordSet("SELECT fwID, event FROM T_FTA_METHOD_FUTURES_WHEEL WHERE stepID = " & stepID, rs)
            
            Dim eventCount
            eventCount = 0
            
            While Not rs.EOF
                Dim eventTitle, sqlInsert
                eventTitle = Replace(rs("event"), "'", "''")
                
                If Len(eventTitle) > 200 Then eventTitle = Left(eventTitle, 200) & "..."
                
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
                    Response.Write "<p class='success'>Evento salvo: " & Left(eventTitle, 40) & "...</p>"
                Else
                    Response.Write "<p class='error'>Erro ao salvar evento: " & Err.Description & "</p>"
                End If
                Err.Clear
                
                rs.MoveNext
            Wend
            
            Response.Write "<p class='success'>Total de eventos salvos: " & eventCount & "</p>"
        End If
        
        Response.Write "<h3>Correção concluída!</h3>"
        
        On Error GoTo 0
        %>
    </div>
    
    <%ElseIf action = "fix_dcdata" Then%>
    <!-- CORRIGIR DCDATA.ASP PARA ROADMAP -->
    <div class="section">
        <h2>Gerando dcData.asp corrigido para Roadmap</h2>
        <%
        Response.Write "<p>Criando versão específica do dcData.asp para roadmap...</p>"
        Response.Write "<p class='info'>Salve o código abaixo como dcData.asp na pasta do roadmap:</p>"
        %>
        
        <textarea rows="20" cols="100" style="width: 100%; font-family: monospace;">
<!--#include virtual="/system.asp"-->

<%
Response.Expires = -1
Response.CacheControl = "no-cache"
Response.AddHeader "Pragma", "no-cache"
Response.Charset = "ISO-8859-1"

Dim stepID, workflowID, previousSteps
stepID = Request.QueryString("stepID")

If stepID = "" Then
    Response.Write("Error: stepID is required")
    Response.End
End If

' Obter workflow ID e steps anteriores
workflowID = 0
previousSteps = ""

On Error Resume Next
Call getRecordSet("SELECT workflowID FROM T_WORKFLOW_STEP WHERE stepID = " & stepID, rs)
If Not rs.EOF Then workflowID = rs("workflowID")

Call getRecordSet("SELECT stepID FROM T_WORKFLOW_STEP WHERE workflowID = " & workflowID & " AND stepID < " & stepID & " ORDER BY stepID", rs)
While Not rs.EOF
    If previousSteps <> "" Then previousSteps = previousSteps & ","
    previousSteps = previousSteps & rs("stepID")
    rs.MoveNext
Wend

If previousSteps = "" Then previousSteps = stepID
On Error GoTo 0
%>

<!DOCTYPE html>
<html>
<head>
    <meta http-equiv="Content-Type" content="text/html; charset=iso-8859-1">
    <title>Dublin Core Data Repository - Roadmap View</title>
    <style>
        body { font-family: Arial, sans-serif; margin: 20px; background: #f5f5f5; }
        .container { background: white; padding: 20px; border-radius: 10px; max-width: 1200px; margin: 0 auto; }
        h1 { color: #333; border-bottom: 2px solid #007bff; padding-bottom: 10px; }
        .info { background: #e9ecef; padding: 10px; border-radius: 5px; margin-bottom: 20px; }
        .section { margin-bottom: 30px; }
        .section h2 { color: #495057; font-size: 1.3rem; margin-bottom: 15px; }
        .item { background: #f8f9fa; padding: 15px; margin-bottom: 10px; border-left: 3px solid #007bff; border-radius: 5px; cursor: pointer; transition: background 0.3s; }
        .item:hover { background: #e9ecef; }
        .item-title { font-weight: bold; color: #333; margin-bottom: 5px; }
        .item-desc { color: #666; font-size: 0.9rem; }
        .item-meta { color: #999; font-size: 0.8rem; margin-top: 5px; }
        .empty { text-align: center; padding: 40px; color: #999; }
        .close-btn { position: fixed; top: 20px; right: 20px; background: #dc3545; color: white; border: none; padding: 10px 20px; border-radius: 5px; cursor: pointer; }
        .usage-tips { background: #d1ecf1; padding: 15px; border-radius: 5px; margin-top: 20px; }
    </style>
</head>
<body>
    <button class="close-btn" onclick="window.close()">Fechar</button>
    
    <div class="container">
        <h1>Dublin Core Data Repository - Roadmap View</h1>
        
        <div class="info">
            <strong>Informações:</strong> Step ID: <%=stepID%> | Workflow ID: <%=workflowID%> | Steps do Workflow: <%=previousSteps%>
        </div>
        
        <!-- IDEIAS DO BRAINSTORMING -->
        <div class="section">
            <h2>Ideias do Brainstorming</h2>
            <%
            Call getRecordSet("SELECT * FROM tiamat_dublin_core WHERE stepID IN (" & previousSteps & ") AND dc_type = 'brainstorming' ORDER BY stepID DESC", rs)
            If rs.EOF Then
                Response.Write "<div class='empty'>Nenhuma ideia encontrada.</div>"
            Else
                While Not rs.EOF
                    Dim title, desc, creator
                    title = rs("dc_title")
                    desc = rs("dc_description")
                    creator = rs("dc_creator")
                    
                    ' Extrair número de votos da descrição
                    Dim votes
                    votes = "0"
                    If InStr(desc, "Votos: ") > 0 Then
                        votes = Mid(desc, InStr(desc, "Votos: ") + 7, 1)
                        desc = Left(desc, InStr(desc, " (Votos:") - 1)
                    End If
            %>
                    <div class="item" onclick="copyText('<%=Replace(title, "'", "\'")%>')">
                        <div class="item-title"><%=title%></div>
                        <div class="item-desc"><%=desc%></div>
                        <div class="item-meta">Votos: <%=votes%> | Por: <%=creator%> | Step: <%=rs("stepID")%></div>
                    </div>
            <%
                    rs.MoveNext
                Wend
            End If
            %>
        </div>
        
        <!-- EVENTOS DO FUTURES WHEEL -->
        <div class="section">
            <h2>Eventos do Futures Wheel</h2>
            <%
            Call getRecordSet("SELECT * FROM tiamat_dublin_core WHERE stepID IN (" & previousSteps & ") AND dc_type = 'futures_wheel' ORDER BY stepID DESC", rs)
            If rs.EOF Then
                Response.Write "<div class='empty'>Nenhum evento encontrado.</div>"
            Else
                While Not rs.EOF
            %>
                    <div class="item" onclick="copyText('<%=Replace(rs("dc_title"), "'", "\'")%>')">
                        <div class="item-title"><%=rs("dc_title")%></div>
                        <div class="item-desc"><%=rs("dc_description")%></div>
                        <div class="item-meta">Step: <%=rs("stepID")%></div>
                    </div>
            <%
                    rs.MoveNext
                Wend
            End If
            %>
        </div>
        
        <!-- CENÁRIOS -->
        <div class="section">
            <h2>Cenários</h2>
            <%
            Call getRecordSet("SELECT name, description, stepID FROM T_FTA_METHOD_SCENARIOS WHERE stepID IN (" & previousSteps & ")", rs)
            If rs.EOF Then
                Response.Write "<div class='empty'>Nenhum cenário encontrado.</div>"
            Else
                While Not rs.EOF
            %>
                    <div class="item" onclick="copyText('<%=Replace(rs("name"), "'", "\'")%>')">
                        <div class="item-title"><%=rs("name")%></div>
                        <div class="item-desc"><%=Left(rs("description"), 200)%>...</div>
                        <div class="item-meta">Step: <%=rs("stepID")%></div>
                    </div>
            <%
                    rs.MoveNext
                Wend
            End If
            %>
        </div>
        
        <!-- REFERÊNCIAS BIBLIOMÉTRICAS -->
        <div class="section">
            <h2>Referências Bibliométricas</h2>
            <%
            Call getRecordSet("SELECT title, year, stepID FROM T_FTA_METHOD_BIBLIOMETRICS WHERE stepID IN (" & previousSteps & ")", rs)
            If rs.EOF Then
                Response.Write "<div class='empty'>Nenhuma referência encontrada.</div>"
            Else
                While Not rs.EOF
            %>
                    <div class="item" onclick="copyText('<%=Replace(rs("title"), "'", "\'")%>')">
                        <div class="item-title"><%=rs("title")%></div>
                        <div class="item-desc">Ano: <%=rs("year")%></div>
                        <div class="item-meta">Step: <%=rs("stepID")%></div>
                    </div>
            <%
                    rs.MoveNext
                Wend
            End If
            %>
        </div>
        
        <div class="usage-tips">
            <h3>Como usar estes dados no Roadmap:</h3>
            <ol>
                <li>Clique em qualquer item para copiá-lo</li>
                <li>Use ideias do Brainstorming para definir marcos futuros</li>
                <li>Baseie-se nos cenários para criar timeline realista</li>
                <li>Use eventos do Futures Wheel para identificar consequências</li>
                <li>Apoie-se nas referências bibliométricas para fundamentar decisões</li>
            </ol>
        </div>
    </div>
    
    <script>
        function copyText(text) {
            var textArea = document.createElement("textarea");
            textArea.value = text.replace(/['"]/g, '').trim();
            textArea.style.position = 'fixed';
            textArea.style.left = '-999999px';
            document.body.appendChild(textArea);
            textArea.select();
            
            try {
                document.execCommand('copy');
                alert('Copiado: ' + textArea.value);
            } catch (err) {
                alert('Erro ao copiar');
            }
            
            document.body.removeChild(textArea);
        }
    </script>
</body>
</html>
        </textarea>
    </div>
    
    <%Else%>
    <!-- DIAGNÓSTICO INICIAL -->
    <div class="section">
        <h2>1. Diagnóstico dos Problemas</h2>
        
        <h3>Status atual dos steps:</h3>
        <%
        Call getRecordSet("SELECT stepID, status, type FROM T_WORKFLOW_STEP WHERE stepID IN (70389, 70390, 70391, 70392, 70393) ORDER BY stepID", rs)
        If Not rs.EOF Then
            Response.Write "<table>"
            Response.Write "<tr><th>Step ID</th><th>Método</th><th>Status</th><th>Situação</th></tr>"
            While Not rs.EOF
                Dim statusDesc, situacao
                Select Case rs("status")
                    Case 1: statusDesc = "Não iniciado"
                    Case 2: statusDesc = "Bloqueado"
                    Case 3: statusDesc = "Ativo"
                    Case 4: statusDesc = "Finalizado"
                    Case Else: statusDesc = "Desconhecido (" & rs("status") & ")"
                End Select
                
                situacao = "OK"
                If rs("stepID") = 70393 And rs("status") = 3 Then situacao = "PROBLEMA - Deveria estar bloqueado"
                
                Response.Write "<tr>"
                Response.Write "<td>" & rs("stepID") & "</td>"
                Response.Write "<td>" & rs("type") & "</td>"
                Response.Write "<td>" & statusDesc & "</td>"
                Response.Write "<td>" & situacao & "</td>"
                Response.Write "</tr>"
                rs.MoveNext
            Wend
            Response.Write "</table>"
        End If
        %>
        
        <h3>Dados do Futures Wheel no Dublin Core:</h3>
        <%
        Call getRecordSet("SELECT COUNT(*) as total FROM tiamat_dublin_core WHERE stepID = 70391 AND dc_type = 'futures_wheel'", rs)
        If Not rs.EOF Then
            Response.Write "<p>Registros no Dublin Core: " & rs("total") & "</p>"
            If rs("total") = 0 Then
                Response.Write "<p class='error'>PROBLEMA - Nenhum evento do Futures Wheel salvo no Dublin Core</p>"
            End If
        End If
        %>
    </div>
    
    <div class="section">
        <h2>2. Soluções Disponíveis</h2>
        
        <p><a href="?action=fix" style="padding: 10px 20px; background: #28a745; color: white; text-decoration: none; border-radius: 5px;">
           Corrigir Sequência e Dados</a></p>
        
        <p><a href="?action=fix_dcdata" style="padding: 10px 20px; background: #007bff; color: white; text-decoration: none; border-radius: 5px;">
           Gerar dcData.asp para Roadmap</a></p>
    </div>
    <%End If%>
    
    <div class="section info">
        <h2>Links Úteis</h2>
        <ul>
            <li><a href="/workplace.asp">Workplace</a></li>
            <li><a href="../roadmap/index.asp?stepID=70392">Roadmap</a></li>
            <li><a href="../scenario/index.asp?stepID=70393">Scenarios</a></li>
        </ul>
    </div>
    
</body>
</html>