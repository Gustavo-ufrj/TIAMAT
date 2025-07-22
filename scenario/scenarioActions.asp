<!--#include virtual="/system.asp"-->
<!--#include file="INC_SCENARIO.inc"-->


<%

Dim usuarios
	dim sql_consulta, retorno
	Dim action
			
	action = Request.Querystring("action")
	
	select case action
	
	case "save"
		
		if request.form("stepID") <> ""  then
		 
			if request.form("scenarioID") <> "" then
			 
				call getRecordSet(SQL_CONSULTA_SCENARIOS_BY_SCENARIO_ID(request.form("scenarioID")), rs)
				
				if not rs.eof then 'update
				
'					call ExecuteSQLCommand(SQL_ATUALIZA_SCENARIO(request.form("scenarioID"), request.form("name"), request.form("description"), request.form("scenario")))
					call ExecuteSQLCommand(SQL_ATUALIZA_SCENARIO(request.form("scenarioID"), request.form("name"), "", request.form("scenario")))
				
				end if 
			
			else  'new
'					call ExecuteSQLCommand(SQL_CRIA_SCENARIO(request.form("stepID"), request.form("name"), request.form("description"), request.form("scenario")))
					call ExecuteSQLCommand(SQL_CRIA_SCENARIO(request.form("stepID"), request.form("name"), "", request.form("scenario")))
					
			end if
				
				'response.redirect "index.asp?stepID="+request.form("stepID")
				url = "index.asp?stepID="+request.form("stepID")
			
			else
			
			call response.write ("Invalid FTA method. Please inform the system administrator.")
			
		end if 
		
		case "delete"
		
		call ExecuteSQL(SQL_DELETE_SCENARIO(request.querystring("scenarioID")))
		
		'response.redirect "index.asp?stepID="+request.querystring("stepID")
		url = "index.asp?stepID="+request.querystring("stepID")
		
	case "end"

		if request.querystring("stepID") <> "" then
			call endStep(request.querystring("stepID"))
			
			url = "/workplace.asp"
		end if
	
	case else
	
		call response.write ("Invalid action supplied. Please inform the system administrator.")
	end select
	
	
%>
<script>
top.location.href="<%=url%>"
</script>
