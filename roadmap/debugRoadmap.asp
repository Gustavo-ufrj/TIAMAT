<!--#include virtual="/system.asp"-->

<%
Response.ContentType = "text/html; charset=ISO-8859-1"
Response.Charset = "ISO-8859-1"

Dim stepID
stepID = Request.QueryString("stepID")
If stepID = "" Then stepID = "70399"
%>

<!DOCTYPE html>
<html>
<head>
    <meta charset="iso-8859-1">
    <title>Debug Roadmap Data</title>
    <style>
        body { font-family: monospace; margin: 20px; }
        .section { margin: 20px 0; padding: 10px; background: #f0f0f0; }
        table { border-collapse: collapse; width: 100%; }
        th, td { border: 1px solid #ccc; padding: 5px; text-align: left; }
        .error { color: red; }
        .success { color: green; }
    </style>
</head>
<body>
    <h1>Debug Roadmap - Step <%=stepID%></h1>
    
    <div class="section">
        <h2>1. Verificar T_FTA_METHOD_ROADMAP</h2>
        <%
        On Error Resume Next
        Call getRecordSet("SELECT * FROM T_FTA_METHOD_ROADMAP WHERE stepID = " & stepID, rs)
        
        If Err.Number <> 0 Then
            Response.Write "<div class='error'>Erro: " & Err.Description & "</div>"
            Err.Clear
        ElseIf rs.EOF Then
            Response.Write "<div class='error'>Nenhum roadmap encontrado para stepID " & stepID & "</div>"
        Else
            Response.Write "<table>"
            Response.Write "<tr><th>roadmapID</th><th>stepID</th><th>name</th></tr>"
            
            Dim roadmapID
            roadmapID = 0
            
            While Not rs.EOF
                roadmapID = rs("roadmapID")
                Response.Write "<tr>"
                Response.Write "<td>" & rs("roadmapID") & "</td>"
                Response.Write "<td>" & rs("stepID") & "</td>"
                Response.Write "<td>" & rs("name") & "</td>"
                Response.Write "</tr>"
                rs.MoveNext
            Wend
            Response.Write "</table>"
            Response.Write "<div class='success'>RoadmapID encontrado: " & roadmapID & "</div>"
            
            ' Agora buscar eventos deste roadmap
            If roadmapID > 0 Then
                Response.Write "<h3>Eventos do Roadmap ID " & roadmapID & ":</h3>"
                
                Call getRecordSet("SELECT * FROM T_FTA_METHOD_ROADMAP_EVENT WHERE roadmapID = " & roadmapID, rs)
                
                If rs.EOF Then
                    Response.Write "<div class='error'>Nenhum evento encontrado para roadmapID " & roadmapID & "</div>"
                Else
                    Response.Write "<table>"
                    Response.Write "<tr><th>roadmapEventID</th><th>roadmapID</th><th>event</th><th>date</th></tr>"
                    
                    Dim eventCount
                    eventCount = 0
                    
                    While Not rs.EOF
                        eventCount = eventCount + 1
                        Response.Write "<tr>"
                        Response.Write "<td>" & rs("roadmapEventID") & "</td>"
                        Response.Write "<td>" & rs("roadmapID") & "</td>"
                        Response.Write "<td>" & rs("event") & "</td>"
                        Response.Write "<td>" & rs("date") & "</td>"
                        Response.Write "</tr>"
                        rs.MoveNext
                    Wend
                    Response.Write "</table>"
                    Response.Write "<div class='success'>Total de eventos: " & eventCount & "</div>"
                End If
            End If
        End If
        On Error GoTo 0
        %>
    </div>
    
    <div class="section">
        <h2>2. Buscar TODOS os eventos com "teste"</h2>
        <%
        On Error Resume Next
        Call getRecordSet("SELECT * FROM T_FTA_METHOD_ROADMAP_EVENT WHERE event LIKE '%teste%'", rs)
        
        If Err.Number <> 0 Then
            Response.Write "<div class='error'>Erro: " & Err.Description & "</div>"
            Err.Clear
        ElseIf rs.EOF Then
            Response.Write "<div class='error'>Nenhum evento com 'teste' encontrado em toda a tabela</div>"
        Else
            Response.Write "<table>"
            Response.Write "<tr><th>roadmapEventID</th><th>roadmapID</th><th>event</th><th>date</th></tr>"
            
            While Not rs.EOF
                Response.Write "<tr>"
                Response.Write "<td>" & rs("roadmapEventID") & "</td>"
                Response.Write "<td>" & rs("roadmapID") & "</td>"
                Response.Write "<td>" & rs("event") & "</td>"
                Response.Write "<td>" & rs("date") & "</td>"
                Response.Write "</tr>"
                rs.MoveNext
            Wend
            Response.Write "</table>"
        End If
        On Error GoTo 0
        %>
    </div>
    
    <div class="section">
        <h2>3. Verificar estrutura das tabelas</h2>
        <%
        On Error Resume Next
        
        ' Tentar diferentes queries para entender a estrutura
        Response.Write "<h3>Colunas da tabela T_FTA_METHOD_ROADMAP:</h3>"
        Call getRecordSet("SELECT TOP 1 * FROM T_FTA_METHOD_ROADMAP", rs)
        
        If Not rs.EOF Then
            Response.Write "<ul>"
            For Each field In rs.Fields
                Response.Write "<li>" & field.Name & " (" & field.Type & ")</li>"
            Next
            Response.Write "</ul>"
        End If
        
        Response.Write "<h3>Colunas da tabela T_FTA_METHOD_ROADMAP_EVENT:</h3>"
        Call getRecordSet("SELECT TOP 1 * FROM T_FTA_METHOD_ROADMAP_EVENT", rs)
        
        If Not rs.EOF Then
            Response.Write "<ul>"
            For Each field In rs.Fields
                Response.Write "<li>" & field.Name & " (" & field.Type & ")</li>"
            Next
            Response.Write "</ul>"
        Else
            Response.Write "<div class='error'>Tabela vazia ou não existe</div>"
        End If
        
        On Error GoTo 0
        %>
    </div>
    
    <div class="section">
        <h2>4. Verificar todos os Roadmaps do Workflow</h2>
        <%
        Dim workflowID
        workflowID = 30147
        
        On Error Resume Next
        Call getRecordSet("SELECT r.*, COUNT(re.roadmapEventID) as eventCount " & _
                         "FROM T_FTA_METHOD_ROADMAP r " & _
                         "LEFT JOIN T_FTA_METHOD_ROADMAP_EVENT re ON r.roadmapID = re.roadmapID " & _
                         "WHERE r.stepID IN (SELECT stepID FROM T_WORKFLOW_STEP WHERE workflowID = " & workflowID & ") " & _
                         "GROUP BY r.roadmapID, r.stepID, r.name", rs)
        
        If rs.EOF Then
            Response.Write "<div class='error'>Nenhum roadmap no workflow " & workflowID & "</div>"
        Else
            Response.Write "<table>"
            Response.Write "<tr><th>roadmapID</th><th>stepID</th><th>name</th><th>Qtd Eventos</th></tr>"
            
            While Not rs.EOF
                Response.Write "<tr>"
                Response.Write "<td>" & rs("roadmapID") & "</td>"
                Response.Write "<td>" & rs("stepID") & "</td>"
                Response.Write "<td>" & rs("name") & "</td>"
                Response.Write "<td>" & rs("eventCount") & "</td>"
                Response.Write "</tr>"
                rs.MoveNext
            Wend
            Response.Write "</table>"
        End If
        On Error GoTo 0
        %>
    </div>
</body>
</html>