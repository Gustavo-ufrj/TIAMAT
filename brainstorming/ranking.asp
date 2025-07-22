<!--#include virtual="/system.asp"-->
<!--#include virtual="/checkstep.asp"-->
<!--#include file="INC_BRAINSTORMING.inc"-->

<%
saveCurrentURL
Dim rs
Dim stepID


call getRecordSet (SQL_CONSULTA_BRAINSTORMING(request.querystring("stepID")), rs)

if rs.eof then																							
 response.redirect "manageBrainstorming.asp?stepID="+request.querystring("stepID")
end if		

votingPoints = rs("votingPoints")


dim actionList()  ' VARIÁVEL IMPORTANTE


If Request.querystring("stepID") <> "" Then
	stepID = request.querystring("stepID")
End If


render.renderTitle()
%>


<div class="p-3">
	<div class="row">
		<div class="col-sm">

<%
dim rsTable									
dim rsTotalVotes
call getRecordset(SQL_CONSULTA_BRAINSTORMING_FILTER_ORDERED(Request.querystring("stepID"), STATUS_VOTING),rsTable)

dim TotalVotes
dim votes
TotalVotes=1


			%>
			<h3> Vote Ranking</h3>
			<table class="table table-striped table-hover w-100">
			<tr class="bg-dark text-light" >
				<td class="text-light">Title</td>
				<td class="text-light text-center" style="width:100px;">Votes</td>
			</tr>
			<%

if rsTable.eof then
response.write "<tr><td class='metro0' colspan=3 align=center>No idea was voted.</td></tr>"
else
call getRecordset(SQL_CONSULTA_BRAINSTORMING_TOTAL_VOTES(cstr(rsTable("brainstormingID"))),rsTotalVotes)
TotalVotes=rsTotalVotes("votes")
end if

while not rsTable.eof
votes=rsTable("votes")
			%>
			<tr>
				<td>
					<%=(rsTable("title"))%>
				</td>
				<td class="text-center">
				<%=votes%> (<%=FormatPercent(votes/TotalVotes)%>)
				</td>
			</tr>
			<%
rsTable.movenext
wend
			%>
			</table>
			
		
		</div>
		<div class="col-sm">

																
<%

call getRecordset(SQL_CONSULTA_BRAINSTORMING_PERSON_VOTES(Request.querystring("stepID")),rsTable)

TotalVotes=1


			%>
			
			<h3> Votes Per Person</h3>
			<table class="table table-striped table-hover w-100">
			<tr class="bg-dark text-light" >
				<td class="text-light">Name</td>
				<td class="text-light text-center" style="width:100px;">Votes</td>
				<td class="text-light text-center" style="width:100px;">Remaining</td>
			</tr>
			<%

if rsTable.eof then
response.write "<tr><td class='metro0' colspan=3 align=center>No user is participating in this Brainstorming.</td></tr>"
end if

while not rsTable.eof
votes=rsTable("votes")
			%>
			<tr>

				<td>
					<%=getName(rsTable("email"))%>
				</td>
				<td class="text-center">
				<%=votes%>
				</td>
				<td class="text-center">
				<%=cstr(votingPoints-votes)%>
				</td>
			</tr>
			<%
rsTable.movenext
wend
			%>
			</table>
														
		
		</div>
	</div>

	
	  
   <div class="p-5">
  </div>
  <nav class="navbar fixed-bottom navbar-light bg-light">
      <div class="container-fluid justify-content-center p-0">
				<button class="btn btn-sm btn-secondary m-1" type="button" onClick="top.location.href='index.asp?stepID=<%=request.queryString("stepID")%>'"> Back</button>
      </div>
  </nav>		
	
</div>

	
<%
render.renderFooter()
%>






