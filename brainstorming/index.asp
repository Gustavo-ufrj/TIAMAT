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

Dim rsRemainingVotes
dim remainingVotes

call getRecordSet (SQL_CONSULTA_BRAINSTORMING_VOTES_PER_USER(request.querystring("stepID"), Session("email")), rsRemainingVotes)
remainingVotes = rs("votingPoints")-rsRemainingVotes.RecordCount


dim actionList()  ' VARIÁVEL IMPORTANTE


If Request.querystring("stepID") <> "" Then
	stepID = request.querystring("stepID")
End If


render.renderTitle()
%>


<div class="p-3">
  <div class="row">
    <div class="col-sm">
		<div id="new-ideas">
			<%

			Redim actionList(1)
			Set actionList(1) = new BrainstormingAction.init("/img/changestatus.png", "Change to Discussion", "changestatus", STATE_ACTIVE)		
			Set actionList(0) = new BrainstormingAction.init("/img/delete.png", "Delete Idea", "delete", STATE_ACTIVE)		

			call renderTable(stepID, "New Ideas", STATUS_NEW,actionList)
			%>
		</div>
    </div>
    <div class="col-sm">
		<div id="discussion-ideas">
			<%
			Redim actionList(0)
			Set actionList(0) = new BrainstormingAction.init("/img/changestatus.png", "Change to Voting", "changestatus", STATE_ACTIVE)		
			call renderTable(stepID, "In Discussion", STATUS_DISCUSSION,actionList)
			%>
		</div>
    </div>
    <div class="col-sm">
		<div id="voting-ideas">
			<%
			Redim actionList(0)
			Set actionList(0) = new BrainstormingAction.init("vote", "vote", "vote", STATE_ACTIVE)		
			call renderTable(stepID, "Voting", STATUS_VOTING,actionList)
			%>
		</div>
    </div>
  </div>
  <hr />
  <div class="row">
     <div class="col-sm text-center fw-bold">
		Votes available: <%=cstr(rs("votingPoints"))%>
     </div>
     <div class="col-sm text-center fw-bold">
		Votes remaining: <%=cstr(remainingVotes)%>
     </div>
  </div>
  
  
  
   <div class="p-5">
  </div>
  <nav class="navbar fixed-bottom navbar-light bg-light">
      <div class="container-fluid justify-content-center p-0">
		 
			<%if getStatusStep(request.querystring("stepID")) = STATE_ACTIVE then %>
				<button class="btn btn-sm btn-secondary m-1" onclick="window.location.href='manageBrainstorming.asp?stepID=<%=stepID%>&brainstormingID=<%=cstr(rs("brainstormingID"))%>'"><i class="bi bi-gear text-light"></i> Configure</button>
				<button class="btn btn-sm btn-secondary m-1" type="button" data-bs-toggle="modal" data-bs-target="#manageIdeaModal" data-step-id="<%=request.querystring("stepID")%>" data-title="Add Idea" data-url="manageIdea.asp?stepID=<%=request.queryString("stepID")%>&brainstormingID=<%=rs("brainstormingID")%>"  > <i class="bi bi-plus-square text-light"></i> Add Idea</button>
			<%end if%>					
				<button class="btn btn-sm btn-secondary m-1" onclick="window.location.href='ranking.asp?stepID=<%=stepID%>'"><i class="bi bi-file-bar-graph text-light"></i> Ranking</button>

			<%if getStatusStep(request.querystring("stepID")) = STATE_ACTIVE then %>
				<button class="btn btn-sm btn-danger m-1" onclick="window.location.href='/stepsupportInformation.asp?stepID=<%=request.queryString("stepID")%>';"><i class="bi bi-journal-plus text-light"></i> Supporting Information</button>
				<button class="btn btn-sm btn-danger m-1" onclick="if(confirm('This action cannot be undone. Are you sure to end this FTA method now?'))window.location.href='/workflowActions.asp?action=end&stepID=<%=request.queryString("stepID")%>'"><i class="bi bi-check-lg text-light"></i> Finish</button>
			<%end if%>
			
      </div>
  </nav>		


	  
 </div>
		

<!-- Add/Edit Reference Modal -->
<div class="modal fade" id="manageIdeaModal" tabindex="-1" aria-labelledby="manageIdeaModal" aria-hidden="true">
  <div class="modal-dialog modal-dialog-centered modal-xl">
    <div class="modal-content">
      <div class="modal-header">
        <h5 class="modal-title" id="ideaModal"></h5>
        <button type="button" class="btn-close" data-bs-dismiss="modal" aria-label="Close"></button>
      </div>
      <div class="modal-body p-0">
        <iframe id="iframeReference" src="" class="w-100" style="height:600px">
		</iframe>
      </div>
     </div>
  </div>
</div>		
<script>

$('#manageIdeaModal').on('show.bs.modal', function(e) {
	var title = $(e.relatedTarget).data('title');
	var url = $(e.relatedTarget).data('url');
    
	$('#ideaModal').html(title);
	$('#iframeReference').attr('src',url);
});
</script>




		
<%
render.renderFooter()
%>



<%

function renderTable(table_stepID, table_title, table_status, table_actions)

												
dim rsTable
dim rsVote
dim filter

Dim hasActions

hasActions = false

for i=lbound(table_actions) to ubound(table_actions) 
	if getStatusStep(table_stepID) = table_actions(i).STATE then 
		hasActions = true
	end if
Next		
		
call getRecordset(SQL_CONSULTA_BRAINSTORMING_FILTER(table_stepID, table_status),rsTable)




												%>
												<h3 colspan=2><%=table_title%></h3>
												<table class="table table-striped table-hover w-100">
												<tr class="bg-dark text-light" >
												<% if hasActions then %>
													<td class="text-light">Title</td>
													<td class="text-light mx-0 px-0" style="width:58px;">Actions</td>
												<% else %>
													<td class="p-1" colspan=2>Title</td>
												<% end if %>
												</tr>
												<%


if rsTable.eof then
	response.write "<tr><td colspan=2 align=center><div class='pt-2 px-1'><div class='alert alert-warning'> There is no idea in this list.</div></div></td></tr>"
end if

while not rsTable.eof
												%>
												<tr>

												<% if hasActions then %>
													<td>
														<a class="link-dark text-decoration-none" href="showIdea.asp?stepID=<%=cstr(rsTable("stepID"))%>&ideaID=<%=cstr(rsTable("ideaID"))%>"><%=(rsTable("title"))%></a> 
													</td>
													<td align=center class="mx-0 px-0">
													<%
	
	for i=lbound(table_actions) to ubound(table_actions) 
	Dim effectiveAcion
	
	Set effectiveAcion = table_actions(i)
	script="return confirm('Are you sure?');"

	if getStatusStep(table_stepID) = table_actions(i).STATE then 

		if table_actions(i).Action = "vote" then
	
		call getRecordset(SQL_CONSULTA_BRAINSTORMING_VOTE(cstr(rsTable("ideaID")), Session("email")),rsVote)
			if rsVote.eof then
				if remainingVotes < 1 then
					script="alert ('You have no remaining votes.'); return false;"
				end if
				Set effectiveAcion = new BrainstormingAction.init("/img/vote.png", "Vote in this idea", "makevote", STATE_ACTIVE)		
			else
				Set effectiveAcion = new BrainstormingAction.init("/img/voteMarked.png", "Remove your vote", "removevote", STATE_ACTIVE)		
			end if
		end if 
				%>
				<a href="ideaActions.asp?action=<%=effectiveAcion.Action%>&stepID=<%=table_stepID%>&ideaID=<%=cstr(rsTable("ideaID"))%>" title="<%=effectiveAcion.ImageDescription%>" onclick="<%=script%>"><img src="<%=effectiveAcion.ImageSource%>"  height=20 width=auto></a>
				<%
		end if
	Next
	
													%>
													</td>
												<% else %>
													<td colspan=2>
														<a class="link-dark text-decoration-none" href="showIdea.asp?stepID=<%=cstr(rsTable("stepID"))%>&ideaID=<%=cstr(rsTable("ideaID"))%>"><%=(rsTable("title"))%></a> 
													</td>
												<% end if %>


												</tr>
												<%
	rsTable.movenext
wend
												%>
												</table>


<%
end function
%>