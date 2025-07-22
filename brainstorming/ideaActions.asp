<!--#include virtual="/system.asp"-->
<!--#include file="INC_BRAINSTORMING.inc"-->


<%

Dim usuarios
	dim sql_consulta, retorno
	Dim rs
	Dim rsRemainingVotes
	Dim action
		

	Dim url
	url="index.asp?stepID="+request.querystring("stepID")
	
	
	action = Request.Querystring("action")
		
		

	select case action
	
	case "save"
		if request.form("stepID") <> "" then
			if request.form("ideaID") <> "" then
				call getRecordSet(SQL_CONSULTA_BRAINSTORMING_IDEA(request.form("ideaID")), rs)
				if not rs.eof then 'update
					call ExecuteSQL(SQL_ATUALIZA_BRAINSTORMING_IDEA(request.form("ideaID"), request.form("title"), request.form("description")))
					url= "showIdea.asp?stepID="+request.form("stepID")+"&ideaID="+request.form("ideaID")		
				end if

			else 'new
				call ExecuteSQL(SQL_CRIA_BRAINSTORMING_IDEA(request.form("brainstormingID"), Session("email"), request.form("title"), request.form("description")))
				url= "index.asp?stepID="+request.form("stepID")	
			end if
		else
			call response.write ("Invalid FTA method. Please inform the system administrator.")
			response.end
		end if 

	case "changestatus"
		if request.querystring("stepID") <> "" then
			if request.querystring("ideaID") <> "" then
				call getRecordSet(SQL_CONSULTA_BRAINSTORMING_IDEA(request.querystring("ideaID")), rs)
				if not rs.eof then
					call ExecuteSQL(SQL_ATUALIZA_BRAINSTORMING_STATUS(request.querystring("ideaID"), cstr(rs("status")+1)))
				end if
			end if
		else
			call response.write ("Invalid FTA method. Please inform the system administrator.")
			response.end
		end if 

		
		
	case "makevote"
		if request.querystring("stepID") <> "" then
			if request.querystring("ideaID") <> "" then
			call getRecordSet (SQL_CONSULTA_BRAINSTORMING(request.querystring("stepID")), rs)
			call getRecordSet (SQL_CONSULTA_BRAINSTORMING_VOTES_PER_USER(request.querystring("stepID"), Session("email")), rsRemainingVotes)
				if (rs("votingPoints")-rsRemainingVotes.RecordCount) > 0 then
					call getRecordSet(SQL_CONSULTA_BRAINSTORMING_VOTE(request.querystring("ideaID"), Session("email")), rs)
					if rs.eof then
						call ExecuteSQL(SQL_ADICIONA_VOTE(request.querystring("ideaID"), Session("email")))
					end if
				end if
			end if
			else
			call response.write ("Invalid FTA method. Please inform the system administrator.")
			response.end
		end if 


	case "removevote"
		if request.querystring("stepID") <> "" then
			if request.querystring("ideaID") <> "" then
				call ExecuteSQL(SQL_DELETE_VOTE(request.querystring("ideaID"), Session("email")))
			end if
		else
			call response.write ("Invalid FTA method. Please inform the system administrator.")
			response.end
		end if 


	case "delete"
		call ExecuteSQL(SQL_DELETE_IDEA(request.querystring("ideaID")))
		
		
	case else
		call response.write ("Invalid action supplied. Please inform the system administrator.")
		response.end
	end select
	
	
%>

<script>
top.location.href="<%=url%>"
</script>