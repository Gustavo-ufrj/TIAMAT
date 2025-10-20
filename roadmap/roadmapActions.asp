<!--#include virtual="/system.asp"-->
<!--#include file="INC_ROADMAP.inc"-->

<%
Dim usuarios
dim sql_consulta, retorno
Dim action
			
action = Request.Querystring("action")

select case action

case "save"
    
    if request.form("stepID") <> "" then
    
        call getRecordSet(SQL_CONSULTA_ROADMAP(request.form("stepID")), rs)
        
        if rs.eof then 'new
            call ExecuteSQL(SQL_CRIA_ROADMAP(request.form("stepID"), request.form("title"), request.form("description"), request.form("exhibition")))
        else 'update
            call ExecuteSQL(SQL_ATUALIZA_ROADMAP(request.form("roadmapID"), request.form("title"), request.form("description"), request.form("exhibition")))
        end if 

        response.redirect "index.asp?stepID="+request.form("stepID")
            
    else
        call response.write ("Invalid FTA method. Please inform the system administrator.")
    end if 

case "finalize"
    ' NOVO: Finalizar roadmap e salvar no Dublin Core
    Dim stepID, roadmapID
    stepID = Request.QueryString("stepID")
    
    If stepID <> "" Then
        Dim eventCount
        
        ' Buscar informações do roadmap
        Call getRecordSet(SQL_CONSULTA_ROADMAP(stepID), rs)
        If Not rs.EOF Then
            roadmapID = rs("roadmapID")
            
            ' Contar eventos
            Call getRecordSet("SELECT COUNT(*) as total FROM T_FTA_METHOD_ROADMAP_EVENT WHERE roadmapID = " & roadmapID, rs)
            If Not rs.EOF Then
                eventCount = rs("total")
            Else
                eventCount = 0
            End If
            
            ' Limpar registros antigos
            On Error Resume Next
            Call ExecuteSQL("DELETE FROM tiamat_dublin_core WHERE stepID = " & stepID & " AND dc_type = 'roadmap'")
            On Error GoTo 0
            
            ' Salvar eventos no Dublin Core
            Call getRecordSet(SQL_CONSULTA_ROADMAP_EVENTS(roadmapID), rs)
            
            Dim eventNum
            eventNum = 1
            
            While Not rs.EOF
                On Error Resume Next
                Call ExecuteSQL("INSERT INTO tiamat_dublin_core " & _
                               "(stepID, dc_title, dc_creator, dc_subject, dc_description, " & _
                               "dc_publisher, dc_date, dc_type, dc_format, " & _
                               "dc_identifier, dc_source, dc_language, dc_relation, dc_coverage, dc_rights) " & _
                               "VALUES (" & stepID & ", " & _
                               "'" & Replace(rs("event"), "'", "''") & "', " & _
                               "'System', " & _
                               "'roadmap_event', " & _
                               "'Event " & eventNum & "', " & _
                               "'TIAMAT', " & _
                               "GETDATE(), " & _
                               "'roadmap', " & _
                               "'event', " & _
                               "'EVENT_" & rs("eventID") & "', " & _
                               "'Roadmap Step " & stepID & "', " & _
                               "'pt-BR', " & _
                               "'Sequence: " & eventNum & "', " & _
                               "'Year: " & Year(rs("date")) & "', " & _
                               "'Public')")
                
                On Error GoTo 0
                eventNum = eventNum + 1
                rs.MoveNext()
            Wend
        End If
        
        ' Finalizar o step
        Call endStep(stepID)
        
        ' Redirecionar
        Response.Redirect "/workplace.asp"
    End If

case "report"
    ' NOVO: Gerar relatório (redirecionar para página de relatório)
    Response.Write "<html><head><title>Roadmap Report</title>"
    Response.Write "<style>"
    Response.Write "body { font-family: Arial; margin: 40px; }"
    Response.Write ".header { text-align: center; margin-bottom: 30px; }"
    Response.Write ".event { margin: 20px 0; padding: 15px; border-left: 4px solid #007bff; background: #f8f9fa; }"
    Response.Write ".year { font-weight: bold; color: #007bff; }"
    Response.Write "</style></head><body>"
    Response.Write "<div class='header'>"
    Response.Write "<h1>Roadmap Report</h1>"
    Response.Write "<p>Step ID: " & Request.QueryString("stepID") & "</p>"
    Response.Write "<button onclick='window.print()'>Print</button> "
    Response.Write "<button onclick='window.close()'>Close</button>"
    Response.Write "</div>"
    
    Dim rsReport
    Call getRecordSet(SQL_CONSULTA_ROADMAP(Request.QueryString("stepID")), rsReport)
    If Not rsReport.EOF Then
        Dim roadmapIDReport
        roadmapIDReport = rsReport("roadmapID")
        Response.Write "<h2>" & rsReport("title") & "</h2>"
        Response.Write "<p>" & rsReport("description") & "</p>"
        
        Call getRecordSet(SQL_CONSULTA_ROADMAP_EVENTS_SORTING(roadmapIDReport, "date ASC"), rsReport)
        Response.Write "<div class='events'>"
        While Not rsReport.EOF
            Response.Write "<div class='event'>"
            Response.Write "<span class='year'>" & Year(rsReport("date")) & "</span> - "
            Response.Write rsReport("event")
            Response.Write "</div>"
            rsReport.MoveNext()
        Wend
        Response.Write "</div>"
    End If
    
    Response.Write "</body></html>"
    Response.End

case else
    call response.write ("Invalid action supplied. Please inform the system administrator.")

end select
%>