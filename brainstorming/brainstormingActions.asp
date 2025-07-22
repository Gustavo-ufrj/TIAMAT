<!--#include virtual="/system.asp"-->
<!--#include file="INC_BRAINSTORMING.inc"-->


<%

Dim usuarios
	dim sql_consulta, retorno
	Dim action
			
	action = Request.Querystring("action")
	
	select case action
	
	case "save"
		
		if request.form("stepID") <> "" then
		
			
			call getRecordSet(SQL_CONSULTA_BRAINSTORMING(request.form("stepID")), rs)
			
			if rs.eof then 'new
			 response.write "NEW"
				call ExecuteSQL(SQL_CRIA_BRAINSTORMING(request.form("stepID"), request.form("description"), request.form("votingPoints")))
			
			else 'update
				call ExecuteSQL(SQL_ATUALIZA_BRAINSTORMING(request.form("brainstormingID"), request.form("description"), request.form("votingPoints")))
			
			end if 
		
				
			response.redirect "index.asp?stepID="+request.form("stepID")
				
			else
			
			call response.write ("Invalid FTA method. Please inform the system administrator.")
			
		end if 
		

	case else
	
		call response.write ("Invalid action supplied. Please inform the system administrator.")



		
	end select
	
	
%>
