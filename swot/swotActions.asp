<!--#include virtual="/system.asp"-->
<!--#include file="INC_SWOT.inc"-->


<%

Dim usuarios
	dim sql_consulta, retorno
	Dim action
			
	action = Request.Querystring("action")
	
	select case action
	
	case "save"
		
		if request.form("stepID") <> "" then
		
			
			call getRecordSet(SQL_CONSULTA_SWOT(request.form("stepID")), rs)
			
			if rs.eof then 'new
			
				call ExecuteSQL(SQL_CRIA_SWOT(request.form("stepID"), request.form("strengths"), request.form("weakness"), request.form("opportunities"), request.form("threats")))
			
			else 'update
			
				call ExecuteSQL(SQL_ATUALIZA_SWOT(request.form("stepID"), request.form("strengths"), request.form("weakness"), request.form("opportunities"), request.form("threats")))
			
			end if 
		
				
			response.redirect "index.asp?stepID="+request.form("stepID")
				
			else
			
			call response.write ("Invalid FTA method. Please inform the system administrator.")
			
		end if 
		
	case "end"

		if request.querystring("stepID") <> "" then
			call endStep(request.querystring("stepID"))
			
			response.redirect "/workplace.asp"
		end if
	
	case else
	
		call response.write ("Invalid action supplied. Please inform the system administrator.")



		
	end select
	
	
%>
