<!--#include virtual="/system.asp"-->
<!--#include file="INC_CIA.inc"-->


<%

Dim usuarios
	dim sql_consulta, retorno
	Dim action, url
	
	url = "/workplace.asp"
	
	action = Request.Querystring("action")
	
	select case action
	
	case "save"
		if request.form("stepID") <> "" then
			call getRecordSet(SQL_CONSULTA_CIA(request.form("stepID")), rs)
			if rs.eof then 'new
				call ExecuteSQL(SQL_CRIA_CIA(request.form("stepID"), request.form("description"), request.form("tipo")))
			else 'update
				if(request.form("tipo") = request.form("hidden_tipo")) then 'update sem mudanca de tipo
					call ExecuteSQL(SQL_ATUALIZA_CIA(request.form("stepID"), request.form("description"), request.form("tipo")))
				else 'update com mudanca de tipo
					call ExecuteSQL(SQL_ATUALIZA_CIA(request.form("stepID"), request.form("description"), request.form("tipo")))
					call ExecuteSQL(SQL_DELETE_EVENT_X_EVENT(request.form("CIAID")))
				end if
			end if 
			url="index.asp?stepID="+request.form("stepID")
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
<script>
top.location.href="<%=url%>"
</script>