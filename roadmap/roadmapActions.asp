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
		

	case else
	
		call response.write ("Invalid action supplied. Please inform the system administrator.")



		
	end select
	
	
%>
