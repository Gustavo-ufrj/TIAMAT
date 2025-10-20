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

' Inicializar variáveis
workflowID = 0
previousSteps = ""

' Obter workflow ID
On Error Resume Next
Call getRecordSet("SELECT workflowID FROM T_WORKFLOW_STEP WHERE stepID = " & stepID, rs)
If Not rs.EOF Then
    workflowID = CLng(rs("workflowID"))
End If
On Error GoTo 0

' Buscar todos os steps anteriores do workflow
If workflowID > 0 Then
    Call getRecordSet("SELECT stepID FROM T_WORKFLOW_STEP WHERE workflowID = " & workflowID & " AND stepID < " & stepID & " ORDER BY stepID", rs)
    While Not rs.EOF
        If previousSteps <> "" Then previousSteps = previousSteps & ","
        previousSteps = previousSteps & rs("stepID")
        rs.MoveNext
    Wend
End If

If previousSteps = "" Then previousSteps = "0"
%>

<!DOCTYPE html>
<html>
<head>
    <meta http-equiv="Content-Type" content="text/html; charset=iso-8859-1">
    <title>Dublin Core Data - Scenarios</title>
    <style>
        body {
            font-family: 'Segoe UI', Arial, sans-serif;
            margin: 20px;
            background: #f5f5f5;
        }
        
        .container {
            background: white;
            padding: 25px;
            border-radius: 10px;
            max-width: 1200px;
            margin: 0 auto;
            box-shadow: 0 2px 10px rgba(0,0,0,0.1);
        }
        
        h1 {
            color: #2c3e50;
            border-bottom: 3px solid #3498db;
            padding-bottom: 10px;
            margin-bottom: 25px;
        }
        
        .debug-info {
            background: #fff3cd;
            border: 1px solid #ffc107;
            color: #856404;
            padding: 10px;
            margin-bottom: 20px;
            border-radius: 5px;
            font-family: monospace;
            font-size: 0.9em;
        }
        
        .section {
            margin-bottom: 30px;
        }
        
        .section h2 {
            color: #34495e;
            font-size: 1.3rem;
            margin-bottom: 15px;
            padding: 10px;
            background: #ecf0f1;
            border-left: 4px solid #3498db;
        }
        
        .item {
            background: #f8f9fa;
            padding: 15px;
            margin-bottom: 12px;
            border-left: 3px solid #3498db;
            border-radius: 5px;
            cursor: pointer;
            transition: all 0.3s;
        }
        
        .item:hover {
            background: #e8f4f8;
            transform: translateX(5px);
            box-shadow: 0 2px 5px rgba(0,0,0,0.1);
        }
        
        .item-title {
            font-weight: bold;
            color: #2c3e50;
            margin-bottom: 5px;
            font-size: 1.05rem;
        }
        
        .item-desc {
            color: #555;
            font-size: 0.9rem;
            margin-bottom: 5px;
        }
        
        .item-meta {
            color: #7f8c8d;
            font-size: 0.85rem;
            margin-top: 8px;
            padding-top: 8px;
            border-top: 1px dotted #bdc3c7;
        }
        
        .empty {
            text-align: center;
            padding: 30px;
            color: #95a5a6;
            font-style: italic;
        }
        
        .close-btn {
            position: fixed;
            top: 20px;
            right: 20px;
            background: #e74c3c;
            color: white;
            border: none;
            padding: 10px 20px;
            border-radius: 5px;
            cursor: pointer;
            font-weight: bold;
            transition: all 0.3s;
        }
        
        .close-btn:hover {
            background: #c0392b;
            transform: translateY(-2px);
        }
        
        .total {
            background: #3498db;
            color: white;
            padding: 15px;
            border-radius: 5px;
            margin-top: 20px;
            font-size: 1.1rem;
            text-align: center;
        }
        
        .copy-notification {
            position: fixed;
            top: 50%;
            left: 50%;
            transform: translate(-50%, -50%);
            background: #27ae60;
            color: white;
            padding: 15px 25px;
            border-radius: 5px;
            z-index: 9999;
            display: none;
        }
        
        .instructions {
            background: #e3f2fd;
            border: 1px solid #90caf9;
            padding: 15px;
            border-radius: 5px;
            margin-bottom: 20px;
        }
        
        .instructions h3 {
            margin-top: 0;
            color: #1565c0;
        }
    </style>
</head>
<body>
    <button class="close-btn" onclick="window.close()">Fechar</button>
    
    <div class="container">
        <h1>Dublin Core Data - Para uso em Cenários</h1>
        
        <div class="debug-info">
            <strong>Debug Info:</strong><br>
            Step ID: <%=stepID%><br>
            Workflow ID: <%=workflowID%><br>
            Previous Steps: <%=previousSteps%>
        </div>
        
        <div class="instructions">
            <h3>Como usar:</h3>
            <ul>
                <li>Clique em qualquer item para copiá-lo</li>
                <li>Use os dados dos métodos anteriores para enriquecer seu cenário</li>
                <li>Os dados estão organizados por tipo de método FTA</li>
            </ul>
        </div>
        
        <%
        Dim totalItems
        totalItems = 0
        %>
        
        <!-- BRAINSTORMING IDEAS -->
        <div class="section">
            <h2>Ideias do Brainstorming</h2>
            <%
            On Error Resume Next
            
            Dim sqlBrainstorm, rsBrainstorm
            sqlBrainstorm = "SELECT i.title, i.description, b.stepID, i.email " & _
                           "FROM T_FTA_METHOD_BRAINSTORMING_IDEAS i " & _
                           "INNER JOIN T_FTA_METHOD_BRAINSTORMING b ON i.brainstormingID = b.brainstormingID " & _
                           "WHERE b.stepID IN (" & previousSteps & ") " & _
                           "ORDER BY i.ideaID DESC"
            
            Set rsBrainstorm = Server.CreateObject("ADODB.Recordset")
            Call getRecordSet(sqlBrainstorm, rsBrainstorm)
            
            If Err.Number <> 0 Then
                Response.Write "<div class='error'>Erro: " & Err.Description & "</div>"
                Err.Clear
            ElseIf rsBrainstorm.EOF Then
                Response.Write "<div class='empty'>Nenhuma ideia de brainstorming encontrada.</div>"
            Else
                Dim brainstormCount
                brainstormCount = 0
                While Not rsBrainstorm.EOF And brainstormCount < 20
                    totalItems = totalItems + 1
                    brainstormCount = brainstormCount + 1
                    
                    Dim ideaTitle, ideaDesc
                    ideaTitle = rsBrainstorm("title") & ""
                    ideaDesc = rsBrainstorm("description") & ""
                    If Len(ideaDesc) > 150 Then ideaDesc = Left(ideaDesc, 150) & "..."
            %>
                    <div class="item" onclick="copyText('<%=Replace(Replace(ideaTitle, "'", "\'"), """", "\""")%>')">
                        <div class="item-title"><%=ideaTitle%></div>
                        <div class="item-desc"><%=ideaDesc%></div>
                        <div class="item-meta">
                            Email: <%=rsBrainstorm("email")%> | 
                            Step: <%=rsBrainstorm("stepID")%>
                        </div>
                    </div>
            <%
                    rsBrainstorm.MoveNext
                Wend
            End If
            
            Set rsBrainstorm = Nothing
            Err.Clear
            On Error GoTo 0
            %>
        </div>
        
        <!-- FUTURES WHEEL EVENTS -->
        <div class="section">
            <h2>Eventos do Futures Wheel</h2>
            <%
            On Error Resume Next
            
            Dim sqlFW, rsFW
            sqlFW = "SELECT fw.event, fw.stepID, fw.fwID " & _
                    "FROM T_FTA_METHOD_FUTURES_WHEEL fw " & _
                    "WHERE fw.stepID IN (" & previousSteps & ") " & _
                    "ORDER BY fw.fwID DESC"
            
            Set rsFW = Server.CreateObject("ADODB.Recordset")
            Call getRecordSet(sqlFW, rsFW)
            
            If Err.Number <> 0 Then
                Response.Write "<div class='error'>Erro: " & Err.Description & "</div>"
                Err.Clear
            ElseIf rsFW.EOF Then
                Response.Write "<div class='empty'>Nenhum evento do Futures Wheel encontrado.</div>"
            Else
                Dim fwCount
                fwCount = 0
                While Not rsFW.EOF And fwCount < 30
                    totalItems = totalItems + 1
                    fwCount = fwCount + 1
                    
                    Dim eventText
                    eventText = rsFW("event") & ""
            %>
                    <div class="item" onclick="copyText('<%=Replace(Replace(eventText, "'", "\'"), """", "\""")%>')">
                        <div class="item-title"><%=eventText%></div>
                        <div class="item-meta">
                            Step: <%=rsFW("stepID")%> | 
                            ID: <%=rsFW("fwID")%>
                        </div>
                    </div>
            <%
                    rsFW.MoveNext
                Wend
            End If
            
            Set rsFW = Nothing
            Err.Clear
            On Error GoTo 0
            %>
        </div>
        
        <!-- ROADMAP EVENTS - CORRIGIDO -->
        <div class="section">
            <h2>Marcos do Roadmap</h2>
            <%
            On Error Resume Next
            
            Dim sqlRoadmap, rsRoadmap
            ' CORREÇÃO: Buscar eventos onde roadmapID = stepID diretamente
            sqlRoadmap = "SELECT event, date, YEAR(date) as year, roadmapID as stepID " & _
                        "FROM T_FTA_METHOD_ROADMAP_EVENT " & _
                        "WHERE roadmapID IN (" & previousSteps & ") " & _
                        "ORDER BY date"
            
            Set rsRoadmap = Server.CreateObject("ADODB.Recordset")
            Call getRecordSet(sqlRoadmap, rsRoadmap)
            
            If Err.Number <> 0 Then
                Response.Write "<div class='error'>Erro ao buscar roadmap: " & Err.Description & "</div>"
                Err.Clear
            ElseIf rsRoadmap.EOF Then
                Response.Write "<div class='empty'>Nenhum evento de roadmap encontrado.</div>"
            Else
                Dim roadmapCount
                roadmapCount = 0
                While Not rsRoadmap.EOF And roadmapCount < 20
                    totalItems = totalItems + 1
                    roadmapCount = roadmapCount + 1
                    
                    Dim roadmapEvent, eventDate
                    roadmapEvent = rsRoadmap("event") & ""
                    eventDate = rsRoadmap("date") & ""
            %>
                    <div class="item" onclick="copyText('<%=Replace(Replace(roadmapEvent, "'", "\'"), """", "\""")%>')">
                        <div class="item-title"><%=roadmapEvent%></div>
                        <div class="item-meta">
                            Data: <%=FormatDateTime(eventDate, 2)%> | 
                            Ano: <%=rsRoadmap("year")%> | 
                            Step: <%=rsRoadmap("stepID")%>
                        </div>
                    </div>
            <%
                    rsRoadmap.MoveNext
                Wend
            End If
            
            Set rsRoadmap = Nothing
            Err.Clear
            On Error GoTo 0
            %>
        </div>
        
        <!-- BIBLIOMETRICS -->
        <div class="section">
            <h2>Referências Bibliométricas</h2>
            <%
            On Error Resume Next
            
            Dim sqlBiblio, rsBiblio
            sqlBiblio = "SELECT title, year, stepID FROM T_FTA_METHOD_BIBLIOMETRICS " & _
                       "WHERE stepID IN (" & previousSteps & ") " & _
                       "ORDER BY year DESC"
            
            Set rsBiblio = Server.CreateObject("ADODB.Recordset")
            Call getRecordSet(sqlBiblio, rsBiblio)
            
            If Err.Number <> 0 Then
                Response.Write "<div class='error'>Erro: " & Err.Description & "</div>"
                Err.Clear
            ElseIf rsBiblio.EOF Then
                Response.Write "<div class='empty'>Nenhuma referência encontrada.</div>"
            Else
                Dim biblioCount
                biblioCount = 0
                While Not rsBiblio.EOF And biblioCount < 15
                    totalItems = totalItems + 1
                    biblioCount = biblioCount + 1
                    
                    Dim biblioTitle
                    biblioTitle = rsBiblio("title") & ""
            %>
                    <div class="item" onclick="copyText('<%=Replace(Replace(biblioTitle, "'", "\'"), """", "\""")%>')">
                        <div class="item-title"><%=biblioTitle%></div>
                        <div class="item-meta">
                            Ano: <%=rsBiblio("year")%> | 
                            Step: <%=rsBiblio("stepID")%>
                        </div>
                    </div>
            <%
                    rsBiblio.MoveNext
                Wend
            End If
            
            Set rsBiblio = Nothing
            Err.Clear
            On Error GoTo 0
            %>
        </div>
        
        <%If totalItems > 0 Then%>
        <div class="total">
            <strong>Total de itens disponíveis: <%=totalItems%></strong>
        </div>
        <%Else%>
        <div class="error">
            Nenhum dado encontrado dos métodos anteriores. Complete os métodos anteriores primeiro.
        </div>
        <%End If%>
    </div>
    
    <div class="copy-notification" id="copyNotification">Copiado!</div>
    
    <script>
        function copyText(text) {
            // Limpar texto
            text = text.replace(/\\'/g, "'").replace(/\\"/g, '"');
            
            // Criar elemento temporário
            var textArea = document.createElement("textarea");
            textArea.value = text;
            textArea.style.position = 'fixed';
            textArea.style.left = '-999999px';
            document.body.appendChild(textArea);
            textArea.select();
            
            try {
                document.execCommand('copy');
                showNotification('Texto copiado: ' + text.substring(0, 30) + '...');
            } catch (err) {
                alert('Erro ao copiar');
            }
            
            document.body.removeChild(textArea);
        }
        
        function showNotification(message) {
            var notification = document.getElementById('copyNotification');
            notification.innerHTML = message;
            notification.style.display = 'block';
            setTimeout(function() {
                notification.style.display = 'none';
            }, 2000);
        }
        
        // Debug
        console.log('Dublin Core Data carregado');
        console.log('Step ID: <%=stepID%>');
        console.log('Previous Steps: <%=previousSteps%>');
    </script>
</body>
</html>