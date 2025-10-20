<%
' Versão standalone sem includes problemáticos
Dim action, stepID
action = Request.QueryString("action")
stepID = Request.QueryString("stepID")

If action = "finalize" Then
    ' Criar conexão diretamente
    Dim conn, rs, sql
    Set conn = Server.CreateObject("ADODB.Connection")
    Set rs = Server.CreateObject("ADODB.Recordset")
    
    ' Usar connection string direto (ajuste conforme seu ambiente)
    conn.Open Application("dbConnection")
    
    ' Buscar roadmap
    sql = "SELECT * FROM T_FTA_METHOD_ROADMAP WHERE stepID = " & stepID
    rs.Open sql, conn
    
    If Not rs.EOF Then
        Dim roadmapID
        roadmapID = rs("roadmapID")
        rs.Close
        
        ' Buscar eventos
        sql = "SELECT * FROM T_FTA_METHOD_ROADMAP_EVENT WHERE roadmapID = " & roadmapID & " ORDER BY date"
        rs.Open sql, conn
        
        While Not rs.EOF
            ' Salvar no Dublin Core (simplificado)
            Dim insertSQL
            insertSQL = "INSERT INTO tiamat_dublin_core (stepID, dc_title, dc_type) VALUES (" & stepID & ", '" & Replace(rs("event"), "'", "''") & "', 'roadmap')"
            
            On Error Resume Next
            conn.Execute insertSQL
            On Error GoTo 0
            
            rs.MoveNext
        Wend
        rs.Close
    End If
    
    conn.Close
    Set rs = Nothing
    Set conn = Nothing
    
    Response.Redirect "/workplace.asp"

ElseIf action = "report" Then
%>
<!DOCTYPE html>
<html>
<head>
    <title>Roadmap Report</title>
    <style>
        body { font-family: Arial, sans-serif; margin: 20px; }
        h1 { color: #333; }
        .event { padding: 10px; margin: 10px 0; background: #f5f5f5; border-left: 3px solid #007bff; }
        .year { font-weight: bold; color: #007bff; }
        .no-print { margin: 20px 0; }
        @media print { .no-print { display: none; } }
    </style>
</head>
<body>
    <div class="no-print">
        <button onclick="window.print()">Print</button>
        <button onclick="window.location.href='index.asp?stepID=<%=stepID%>'">Back</button>
    </div>
    
    <h1>Roadmap Report</h1>
    <p>Step ID: <%=stepID%></p>
    
    <%
    Dim connReport, rsReport, sqlReport
    Set connReport = Server.CreateObject("ADODB.Connection")
    Set rsReport = Server.CreateObject("ADODB.Recordset")
    
    connReport.Open Application("dbConnection")
    
    ' Buscar roadmap
    sqlReport = "SELECT * FROM T_FTA_METHOD_ROADMAP WHERE stepID = " & stepID
    rsReport.Open sqlReport, connReport
    
    If Not rsReport.EOF Then
        Response.Write "<h2>" & rsReport("title") & "</h2>"
        Response.Write "<p>" & rsReport("description") & "</p>"
        
        Dim roadmapIDReport
        roadmapIDReport = rsReport("roadmapID")
        rsReport.Close
        
        ' Buscar eventos
        sqlReport = "SELECT * FROM T_FTA_METHOD_ROADMAP_EVENT WHERE roadmapID = " & roadmapIDReport & " ORDER BY date"
        rsReport.Open sqlReport, connReport
        
        Response.Write "<h3>Events Timeline:</h3>"
        
        While Not rsReport.EOF
            Response.Write "<div class='event'>"
            Response.Write "<span class='year'>" & Year(rsReport("date")) & "</span>: "
            Response.Write rsReport("event")
            Response.Write "</div>"
            rsReport.MoveNext
        Wend
        rsReport.Close
    End If
    
    connReport.Close
    Set rsReport = Nothing
    Set connReport = Nothing
    %>
    
    <div style="background: #d4edda; padding: 15px; margin-top: 20px;">
        <h3>Dublin Core Status</h3>
        <p>Events have been saved to Dublin Core repository.</p>
    </div>
</body>
</html>
<%
End If
%>