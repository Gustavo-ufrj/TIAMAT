<!--#include virtual="/system.asp"-->
<!--#include file="INC_FUTURES_WHEEL.inc"-->

<%
Response.Expires = -1
Response.CacheControl = "no-cache"
Response.AddHeader "Pragma", "no-cache"
Response.Charset = "ISO-8859-1"

' Debug mode - descomente para ver erros
' On Error GoTo 0

Dim stepID, workflowID, allWorkflowSteps, previousSteps
stepID = Request.QueryString("stepID")

If stepID = "" Then
    Response.Write("Error: stepID is required")
    Response.End
End If

' Inicializar variáveis
workflowID = 0
allWorkflowSteps = ""
previousSteps = ""

' Obter workflow ID com tratamento de erro
On Error Resume Next
Call getRecordSet("SELECT workflowID FROM T_WORKFLOW_STEP WHERE stepID = " & stepID, rs)
If Err.Number = 0 And Not rs.EOF Then
    workflowID = rs("workflowID")
End If
Err.Clear
On Error GoTo 0

' Buscar TODOS os steps do mesmo workflow (não apenas anteriores)
On Error Resume Next
Call getRecordSet("SELECT stepID FROM T_WORKFLOW_STEP WHERE workflowID = " & workflowID & " ORDER BY stepID", rs)
If Err.Number = 0 Then
    While Not rs.EOF
        If allWorkflowSteps <> "" Then allWorkflowSteps = allWorkflowSteps & ","
        allWorkflowSteps = allWorkflowSteps & rs("stepID")
        
        ' Construir previousSteps apenas com steps menores que o atual
        If CLng(rs("stepID")) < CLng(stepID) Then
            If previousSteps <> "" Then previousSteps = previousSteps & ","
            previousSteps = previousSteps & rs("stepID")
        End If
        
        rs.MoveNext
    Wend
End If
Err.Clear
On Error GoTo 0

' Se não houver steps, usar apenas o step atual
If allWorkflowSteps = "" Then
    allWorkflowSteps = stepID
End If

If previousSteps = "" Then
    previousSteps = stepID
End If

' Também buscar steps de brainstorming órfãos (temporário para dados legados)
Dim orphanBrainstormingSteps
orphanBrainstormingSteps = ""
On Error Resume Next
Call getRecordSet("SELECT DISTINCT b.stepID FROM T_FTA_METHOD_BRAINSTORMING b " & _
                  "INNER JOIN T_WORKFLOW_STEP ws ON b.stepID = ws.stepID " & _
                  "WHERE ws.workflowID = " & workflowID, rs)
If Err.Number = 0 Then
    While Not rs.EOF
        If orphanBrainstormingSteps <> "" Then orphanBrainstormingSteps = orphanBrainstormingSteps & ","
        orphanBrainstormingSteps = orphanBrainstormingSteps & rs("stepID")
        rs.MoveNext
    Wend
End If
Err.Clear
On Error GoTo 0
%>

<!DOCTYPE html>
<html>
<head>
    <meta http-equiv="Content-Type" content="text/html; charset=iso-8859-1">
    <title>Dublin Core Data</title>
    <style>
        body {
            font-family: Arial, sans-serif;
            margin: 20px;
            background: #f5f5f5;
        }
        
        .container {
            background: white;
            padding: 20px;
            border-radius: 10px;
            max-width: 1200px;
            margin: 0 auto;
        }
        
        h1 {
            color: #333;
            border-bottom: 2px solid #007bff;
            padding-bottom: 10px;
        }
        
        .info {
            background: #e9ecef;
            padding: 10px;
            border-radius: 5px;
            margin-bottom: 20px;
        }
        
        .section {
            margin-bottom: 30px;
        }
        
        .section h2 {
            color: #495057;
            font-size: 1.3rem;
            margin-bottom: 15px;
        }
        
        .item {
            background: #f8f9fa;
            padding: 15px;
            margin-bottom: 10px;
            border-left: 3px solid #007bff;
            border-radius: 5px;
            cursor: pointer;
            transition: background 0.3s;
        }
        
        .item:hover {
            background: #e9ecef;
        }
        
        .item-title {
            font-weight: bold;
            color: #333;
            margin-bottom: 5px;
        }
        
        .item-desc {
            color: #666;
            font-size: 0.9rem;
        }
        
        .item-meta {
            color: #999;
            font-size: 0.8rem;
            margin-top: 5px;
        }
        
        .empty {
            text-align: center;
            padding: 40px;
            color: #999;
        }
        
        .close-btn {
            position: fixed;
            top: 20px;
            right: 20px;
            background: #dc3545;
            color: white;
            border: none;
            padding: 10px 20px;
            border-radius: 5px;
            cursor: pointer;
        }
        
        .error {
            background: #f8d7da;
            color: #721c24;
            padding: 10px;
            border-radius: 5px;
            margin-bottom: 20px;
        }
        
        .success {
            background: #d4edda;
            color: #155724;
            padding: 10px;
            border-radius: 5px;
            margin-bottom: 20px;
        }
    </style>
</head>
<body>
    <button class="close-btn" onclick="window.close()">Fechar</button>
    
    <div class="container">
        <h1>Dublin Core Data Repository</h1>
        
        <div class="info">
            <strong>Debug Info:</strong><br>
            Step ID: <%=stepID%><br>
            Workflow ID: <%=workflowID%><br>
            All Workflow Steps: <%=allWorkflowSteps%><br>
            Previous Steps: <%=previousSteps%><br>
            Brainstorming Steps Found: <%=orphanBrainstormingSteps%><br>
        </div>
        
        <%
        ' Contador de itens
        Dim totalItems
        totalItems = 0
        %>
        
        <!-- BRAINSTORMING -->
        <div class="section">
            <h2>Brainstorming Ideas</h2>
            <%
            On Error Resume Next
            
            ' Query corrigida - usar a tabela direta do Dublin Core
            Dim sqlBrainstorm
            sqlBrainstorm = "SELECT * FROM tiamat_dublin_core " & _
                           "WHERE stepID IN (" & previousSteps & ") " & _
                           "AND dc_type = 'brainstorming' " & _
                           "ORDER BY stepID DESC"
            
            ' Debug - mostrar query
            Response.Write "<!-- SQL Brainstorm: " & sqlBrainstorm & " -->" & vbCrLf
            
            Call getRecordSet(sqlBrainstorm, rs)
            
            If Err.Number <> 0 Then
                Response.Write "<div class='error'>Erro ao buscar dados do brainstorming: " & Err.Description & "</div>"
                Err.Clear
            ElseIf rs.EOF Then
                ' Tentar buscar direto das ideias se não houver no Dublin Core
                Dim sqlDirectBrainstorm
                sqlDirectBrainstorm = "SELECT i.title, i.description, i.email, b.stepID " & _
                                     "FROM T_FTA_METHOD_BRAINSTORMING_IDEAS i " & _
                                     "INNER JOIN T_FTA_METHOD_BRAINSTORMING b ON i.brainstormingID = b.brainstormingID " & _
                                     "WHERE b.stepID IN (" & previousSteps & ") " & _
                                     "ORDER BY b.stepID DESC"
                
                Call getRecordSet(sqlDirectBrainstorm, rs)
                
                If Not rs.EOF Then
                    Response.Write "<div class='success'>Encontradas ideias diretas do brainstorming (não finalizadas no Dublin Core)</div>"
                    While Not rs.EOF
                        totalItems = totalItems + 1
            %>
                        <div class="item" onclick="copyText('<%=Replace(Replace(CStr(rs("title")), "'", "\'"), """", "")%>')">
                            <div class="item-title"><%=rs("title")%></div>
                            <div class="item-desc"><%=rs("description")%></div>
                            <div class="item-meta">Por: <%=rs("email")%> | Step: <%=rs("stepID")%></div>
                        </div>
            <%
                        rs.MoveNext
                    Wend
                Else
                    Response.Write "<div class='empty'>Nenhuma ideia de brainstorming encontrada.</div>"
                End If
            Else
                Dim itemCount
                itemCount = 0
                
                Do While Not rs.EOF
                    itemCount = itemCount + 1
                    totalItems = totalItems + 1
                    
                    Dim title, desc, contrib, sid
                    
                    ' Usar os campos corretos do Dublin Core
                    On Error Resume Next
                    title = rs("dc_title")
                    desc = rs("dc_description")
                    contrib = rs("dc_creator")
                    If IsNull(contrib) Or contrib = "" Then contrib = rs("dc_publisher")
                    sid = rs("stepID")
                    On Error GoTo 0
                    
                    If IsNull(title) Or title = "" Then title = "Item " & itemCount
                    If IsNull(desc) Or desc = "" Then desc = "Sem descrição disponível"
                    If IsNull(contrib) Or contrib = "" Then contrib = "Anônimo"
                    If IsNull(sid) Or sid = "" Then sid = "?"
            %>
                    <div class="item" onclick="copyText('<%=Replace(Replace(CStr(title), "'", "\'"), """", "")%>')">
                        <div class="item-title"><%=title%></div>
                        <div class="item-desc"><%=desc%></div>
                        <div class="item-meta">Por: <%=contrib%> | Step: <%=sid%></div>
                    </div>
            <%
                    rs.MoveNext
                    
                    ' Prevenir loop infinito
                    If itemCount > 100 Then
                        Response.Write "<div class='error'>Muitos itens, limitado a 100</div>"
                        Exit Do
                    End If
                Loop
                
                Response.Write "<div class='success'>Total: " & itemCount & " ideias encontradas</div>"
            End If
            
            On Error GoTo 0
            %>
        </div>
        
        <!-- SCENARIOS -->
        <div class="section">
            <h2>Scenarios</h2>
            <%
            On Error Resume Next
            
            ' Buscar cenários direto da tabela de scenarios
            Dim sqlScenarios
            sqlScenarios = "SELECT name, description, stepID FROM T_FTA_METHOD_SCENARIOS " & _
                          "WHERE stepID IN (" & previousSteps & ")"
            
            Response.Write "<!-- SQL Scenarios: " & sqlScenarios & " -->" & vbCrLf
            
            Call getRecordSet(sqlScenarios, rs)
            
            If Err.Number <> 0 Then
                Response.Write "<div class='error'>Erro: " & Err.Description & "</div>"
                Err.Clear
            ElseIf rs.EOF Then
                Response.Write "<div class='empty'>Nenhum cenário encontrado.</div>"
            Else
                While Not rs.EOF
                    totalItems = totalItems + 1
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
            
            On Error GoTo 0
            %>
        </div>
        
        <!-- BIBLIOMETRICS -->
        <div class="section">
            <h2>Bibliometric References</h2>
            <%
            On Error Resume Next
            
            ' Buscar referências bibliométricas
            Dim sqlBiblio
            sqlBiblio = "SELECT title, year, stepID FROM T_FTA_METHOD_BIBLIOMETRICS " & _
                       "WHERE stepID IN (" & previousSteps & ")"
            
            Response.Write "<!-- SQL Biblio: " & sqlBiblio & " -->" & vbCrLf
            
            Call getRecordSet(sqlBiblio, rs)
            
            If Err.Number <> 0 Then
                Response.Write "<div class='error'>Erro: " & Err.Description & "</div>"
                Err.Clear
            ElseIf rs.EOF Then
                Response.Write "<div class='empty'>Nenhuma referência encontrada.</div>"
            Else
                While Not rs.EOF
                    totalItems = totalItems + 1
            %>
                    <div class="item" onclick="copyText('<%=Replace(rs("title"), "'", "\'")%>')">
                        <div class="item-title"><%=rs("title")%></div>
                        <div class="item-desc"><%=rs("year")%></div>
                        <div class="item-meta">Step: <%=rs("stepID")%></div>
                    </div>
            <%
                    rs.MoveNext
                Wend
            End If
            
            On Error GoTo 0
            %>
        </div>
        
        <!-- FUTURES WHEEL EVENTS -->
        <div class="section">
            <h2>Futures Wheel Events</h2>
            <%
            On Error Resume Next
            
            ' Buscar eventos do Futures Wheel - CORRIGIDO sem a coluna order
            Dim sqlFW
            sqlFW = "SELECT fwID, event, stepID, posX, posY " & _
                    "FROM T_FTA_METHOD_FUTURES_WHEEL " & _
                    "WHERE stepID IN (" & previousSteps & ") " & _
                    "ORDER BY fwID"
            
            Response.Write "<!-- SQL Futures Wheel: " & sqlFW & " -->" & vbCrLf
            
            Call getRecordSet(sqlFW, rs)
            
            If Err.Number <> 0 Then
                Response.Write "<div class='error'>Erro: " & Err.Description & "</div>"
                Err.Clear
            ElseIf rs.EOF Then
                Response.Write "<div class='empty'>Nenhum evento do Futures Wheel encontrado.</div>"
            Else
                While Not rs.EOF
                    totalItems = totalItems + 1
            %>
                    <div class="item" onclick="copyText('<%=Replace(rs("event"), "'", "\'")%>')">
                        <div class="item-title"><%=rs("event")%></div>
                        <div class="item-desc">Posição: (<%=rs("posX")%>, <%=rs("posY")%>)</div>
                        <div class="item-meta">Step: <%=rs("stepID")%></div>
                    </div>
            <%
                    rs.MoveNext
                Wend
            End If
            
            On Error GoTo 0
            %>
        </div>
        
        <%
        ' Só mostrar Roadmap Events se NÃO estivermos no próprio Roadmap
        Dim currentMethodType
        currentMethodType = ""
        
        ' Identificar o tipo do método atual baseado no stepID
        On Error Resume Next
        Call getRecordSet("SELECT COUNT(*) as isRoadmap FROM T_FTA_METHOD_ROADMAP WHERE stepID = " & stepID, rs)
        If Not rs.EOF And rs("isRoadmap") > 0 Then
            currentMethodType = "roadmap"
        End If
        On Error GoTo 0
        
        ' Só mostrar seção de Roadmap se não estivermos no próprio Roadmap
        If currentMethodType <> "roadmap" Then
        %>
        <!-- ROADMAP EVENTS (apenas se não estivermos no Roadmap) -->
        <div class="section">
            <h2>Roadmap Events</h2>
            <%
            On Error Resume Next
            
            ' Buscar eventos de roadmap
            Dim sqlRoadmap
            sqlRoadmap = "SELECT re.event as title, YEAR(re.date) as year, r.stepID " & _
                        "FROM T_FTA_METHOD_ROADMAP_EVENT re " & _
                        "INNER JOIN T_FTA_METHOD_ROADMAP r ON re.roadmapID = r.roadmapID " & _
                        "WHERE r.stepID IN (" & previousSteps & ") " & _
                        "ORDER BY re.date"
            
            Call getRecordSet(sqlRoadmap, rs)
            
            If Err.Number <> 0 Then
                Response.Write "<div class='error'>Erro: " & Err.Description & "</div>"
                Err.Clear
            ElseIf rs.EOF Then
                Response.Write "<div class='empty'>Nenhum evento de roadmap encontrado.</div>"
            Else
                While Not rs.EOF
                    totalItems = totalItems + 1
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
            
            On Error GoTo 0
            %>
        </div>
        <%
        End If ' Fim do If currentMethodType <> "roadmap"
        %>
        
        <div class="success">
            <strong>Total de itens encontrados: <%=totalItems%></strong>
        </div>
    </div>
    
    <script>
        function copyText(text) {
            // Limpar texto
            text = text.replace(/['"]/g, '').trim();
            
            // Criar elemento temporário
            var textArea = document.createElement("textarea");
            textArea.value = text;
            textArea.style.position = 'fixed';
            textArea.style.left = '-999999px';
            document.body.appendChild(textArea);
            textArea.select();
            
            try {
                document.execCommand('copy');
                alert('Copiado: ' + text);
            } catch (err) {
                alert('Erro ao copiar');
            }
            
            document.body.removeChild(textArea);
        }
        
        console.log('Página carregada com sucesso');
        console.log('Step ID: <%=stepID%>');
        console.log('Previous Steps: <%=previousSteps%>');
    </script>
</body>
</html>