<!--#include virtual="/system.asp"-->
<!--#include virtual="/includes/JSON.asp"-->
<!--#include file="INC_BRAINSTORMING.inc"-->


<%

Dim usuarios
	dim sql_consulta, retorno
	Dim rs, rsIdea, rsBrainstorming

	Dim url
	url=""

	Dim action
			
	action = Request.Querystring("action")
	
'	Set d = server.createObject("scripting.dictionary")
	
	select case action
	
	case "save"
	
		if request.form("ideaID") <> "" then
			if request.form("commentID") <> "" then
				call getRecordSet(SQL_CONSULTA_BRAINSTORMING_DISCUSSION_COMMENT_ID(request.form("commentID")), rs)
				if not rs.eof then 'update
					call ExecuteSQL(SQL_ATUALIZA_BRAINSTORMING_DISCUSSION(request.form("commentID"), request.form("title"), request.form("comment")))
				end if
			else 'new
				call ExecuteSQL(SQL_CRIA_BRAINSTORMING_DISCUSSION(request.form("ideaID"), Session("email"), request.form("title"), request.form("comment")))
			end if
			
			url="showIdea.asp?stepID="+request.form("stepID")+"&ideaID="+request.form("ideaID")
			
			else
			call response.write ("Invalid FTA method. Please inform the system administrator.")
			Response.end
		end if 

	case "get"
		if request.querystring("ideaID") <> "" then

			call getRecordSet (SQL_CONSULTA_BRAINSTORMING_IDEA(request.querystring("ideaID")), rsIdea)
			if not rsIdea.eof then
				call getRecordSet (SQL_CONSULTA_BRAINSTORMING_BRAINSTORMING_ID(cstr(rsIdea("brainstormingID"))), rsBrainstorming)
				if not rsBrainstorming.eof then
					call printComments(request.querystring("ideaID"), rsIdea("status"), rsBrainstorming("stepID"))
					Response.end
				end if
			end if
		
		end if 
	
	' case "getcomment"
		' if request.querystring("commentID") <> "" then

			' call getRecordSet (SQL_CONSULTA_BRAINSTORMING_DISCUSSION_COMMENT_ID(request.querystring("commentID")), rs)
			' if not rs.eof then
				' d.add "Result", "OK"
				' d.add "Records", rs
			' else
				' d.add "Result", "ERROR"
				' d.add "Message", "No comment supplied. Please inform the system administrator."
			' end if
		' end if 

		
		' retorno = (new JSON).toJSON("data", array(d),0)
		' retorno = mid(retorno, 11, len(retorno)-12)
		' response.write(retorno)
					
	case else
		call response.write ("Invalid action supplied. Please inform the system administrator.")
		Response.end
	end select
	
	
	if url <> "" then %>
		<script>
		top.location.href="<%=url%>"
		</script>
<%	end if
	
	function printComments(ideaID, ideaSTATUS, stepID) 
		Dim rs
		call getRecordSet(SQL_CONSULTA_BRAINSTORMING_DISCUSSION(cstr(ideaID)), rs)
		if not rs.eof then
			response.write "<br>"
		end if
		while not rs.eof
		
		%>
	
	
	<table class="table border w-100 p-0 d-flex">
	<tbody class="w-100">
	<tr class="w-100">
		<td class="text-center flex-shrink-1 p-0">
			<img src="<%=getPhoto(rs("email"))%>" class="rounded-circle align-middle" style="width:192px;height:auto;">	
			<span class="fs-6"><%=getName(rs("email"))%></span>
				<% if rs("email") = Session("email") and ideaSTATUS < 3 and getStatusStep(cstr(stepID)) = STATE_ACTIVE then %>
					<div class="p-1">
					<button class="btn btn-sm btn-secondary m-1" type="button" data-bs-toggle="modal" data-bs-target="#manageIdeaModal" data-step-id="<%=request.querystring("stepID")%>" data-title="Edit Comment" data-url="manageComment.asp?stepID=<%=request.queryString("stepID")%>&commentID=<%=rs("commentID")%>&ideaID=<%=rs("ideaID")%>"> Edit Comment</button>
					<div>
				<%end if%>			
		</td>
		<td class="w-100 p-0">														
			<table class="table w-100 p-2">
				<tr>
					<td class="fw-bolder"> 			
					<%=rs("title")%>
					</td>
					<td class="fw-bolder text-end">			
					<%=getTimeStamp(rs("dateTime"))%>
					</td>
				</tr>
				<tr>
					<td class="border-0" colspan=2>			
					<%=rs("message")%>
					</td>
				</tr>
			</table>																
		</td>
	</tr>
	</tbody>
</table>
			
		<%
	rs.moveNext
	wend
	end function
	
	
%>
