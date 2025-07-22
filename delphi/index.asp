<!--#include virtual="/system.asp"-->
<!--#include virtual="/checkstep.asp"-->
<!--#include file="INC_DELPHI.inc"-->

<%
saveCurrentURL

Dim rs
Dim stepID
Dim role

If request.querystring("stepID") <> "" Then
	stepID = request.querystring("stepID")
	
'	Call getRecordSet (SQL_CONSULTA_DELPHI(stepID), rs)
	
	role = getRole(stepID, Session("email"))
	
'	If rs.EOF And role = "Coordinator" Then
'		response.redirect "manageDelphi.asp?stepID=" & stepID
'	End If
	
	If role = "Participant" And request.querystring("redirect") = "" Then
		Call getRecordSet (SQL_CONSULTA_DELPHI_ROUNDS_STATE(stepID, STATE_PUB), rs)
		
		If rs.EOF Then
			render.renderTitle()
		%>
		<div class="p-3">
			<div class="alert alert-danger">There is no published round for this Delphi.</div>
		</div>
			<%
			render.renderFooter()
			Response.end
		Else
			response.redirect "answerQuestions.asp?stepID=" & stepID & "&roundID=" & rs("roundID")
		End If
	End If
	
End If


tiamat.addCSS("delphi.css")

render.renderTitle()

%>


<div class="p-3">



<%if Session("message") <> "" then%>
  <div class="alert alert-danger alert-dismissible" role="alert">
	<%=Session("message")%>
	 <button type="button" class="btn-close" data-bs-dismiss="alert" aria-label="Close"></button>
  </div>		
<%
Session("message") = ""
end if
%>	  


<%

	

	Call getRecordSet(SQL_CONSULTA_DELPHI_ROUNDS(stepID), rs)
	
	if rs.eof then
		response.write "<div class='py-3'><div class='alert alert-danger'> No Delphi round was found.</div></div>"
	else
%>
<table class="table table-striped table-hover">
  <thead class="table-dark">
	<tr>
		<td class="w-100">Round Description</td>
		<td class="text-center">Status</td>
		<td class="text-center" style="min-width:90px;">Actions</td>
	</tr>
  </thead>
  <tbody>

<%
			while not rs.eof
			
				if (role = "Participant" and rs("state") > 0) or (role = "Coordinator") then
			%>
			<tr>
				<td>														
					<%=(rs("text"))%>
				</td>			
				
				<td class="text-center">
					<%
					 if rs("state") = 0 then
						Response.write "Unpublished"
					 elseif rs("state") = 1 then
						Response.write "Published"
					 else
						Response.write "Ended"
					 end if
					%>
				</td>
				<td class="text-center">
					<%	if rs("state") = 1 and role = "Participant" then%>
						<a href="answerQuestions.asp?stepID=<%=stepID%>&roundID=<%=rs("roundID")%>" title="Answer Questions"><img src="img/answer.png"  height=20 width=auto></a>
					<%	end if	%>
					
					<%	if rs("state") > 0 then%>
						<a href="statistics.asp?stepID=<%=stepID%>&roundID=<%=rs("roundID")%>" title="View Statistics"><img src="img/statistics.png"  height=20 width=auto></a>
					<%	end if	%>
					<%	if rs("state") = 0  And role = "Coordinator" then%>
						<a href="manageQuestions.asp?stepID=<%=stepID%>&roundID=<%=rs("roundID")%>" title="Manage Questions"><img src="img/question.png"  height=20 width=auto></a>
					<%	end if	%>
					<%	if rs("state") < 2 And role = "Coordinator" then%>
						<a href="" title="Edit" data-bs-toggle="modal" data-bs-target="#manageRounds" data-step-id="<%=request.querystring("stepID")%>"  data-round-id="<%=rs("roundID")%>" data-description="<%=rs("text")%>" data-state="<%=cstr(rs("state"))%>"  data-title="Edit Round" data-url="delphiActions.asp?action=update_round"><img src="/img/edit.png"  height=20 width=auto></a>
					<%	end if	%>
					<%	if rs("state") = 0  And role = "Coordinator" then%>
						<a href="delphiActions.asp?action=delete_round&stepID=<%=stepID%>&roundID=<%=rs("roundID")%>" title="Delete"  onclick="if (!confirm('Are you sure?')) { return false; }"><img src="/img/delete.png"  height=20 width=auto></a>
					<%	end if	%>
					
				</td>	
				
		</tr>
			<%
				end if
			rs.movenext
			wend
			%>
										
  </tbody>
</table>
<%
end if
%>												
				
				
	
  <div class="p-3">
  </div>
  
  
  <nav class="navbar fixed-bottom navbar-light bg-light">
         <div class="container-fluid justify-content-center p-0">
				 
		 
		 
	<%if getStatusStep(request.querystring("stepID")) = STATE_ACTIVE then %>
		<% If role = "Coordinator" Then %>
			<button class="btn btn-sm btn-secondary m-1" type="button" data-bs-toggle="modal" data-bs-target="#manageDescriptionModal" data-step-id="<%=request.querystring("stepID")%>" data-title="Delphi Description" data-url="manageDescription.asp?stepID=<%=request.querystring("stepID")%>"> <i class="bi bi-plus-square text-light"></i> Edit Description</button>
			<button class="btn btn-sm btn-secondary m-1" type="button" data-bs-toggle="modal" data-bs-target="#manageRounds" data-step-id="<%=request.querystring("stepID")%>" data-title="Add Round" data-url="delphiActions.asp?action=new_round"> <i class="bi bi-plus-square text-light"></i> Add Round</button>
			<button class="btn btn-sm btn-danger m-1" onclick="window.location.href='/stepsupportInformation.asp?stepID=<%=request.queryString("stepID")%>';"><i class="bi bi-journal-plus text-light"></i> Supporting Information</button>
			<button class="btn btn-sm btn-danger m-1" onclick="if(confirm('This action cannot be undone. Are you sure to end this FTA method now?'))window.location.href='/workflowActions.asp?action=end&stepID=<%=request.queryString("stepID")%>'"><i class="bi bi-check-lg text-light"></i> Finish</button>
		<% ElseIf role = "Participant" Then %>
			<button class="btn btn-sm btn-secondary m-1" onclick="window.location.href='/workplace.asp'">Back</button>
		<% 	End If 	%>
	<%end if%>

	</div>
      </nav>									

	  </form>
</div>


 <!-- Manage Event -->
<div class="modal fade" id="manageRounds" tabindex="-1" aria-labelledby="roundModalLabel" aria-hidden="true">
  <div class="modal-dialog modal-dialog-centered">
	<div class="modal-content">
	<form method="post" action="" autocomplete="off"  id ="formManageRounds" class="requires-validation m-0" novalidate>
	  <div class="modal-header">
		<h5 class="modal-title" id="roundModalLabel">xx</h5>
		<button type="button" class="btn-close" data-bs-dismiss="modal" aria-label="Close"></button>
	  </div>
	  <div class="modal-body">

	  <div class=" mb-3">
		<label for="description" class="form-label">Description</label>
		<textarea class="form-control" id="description" rows="3" name="description" required></textarea>
		<div class="invalid-feedback">Description cannot be blank!</div>
	  </div>
	  
	    <div class=" mb-3">
		<label for="state" class="form-label">Status</label>
		<select class="form-control" id="state" name="state" required>
		<option value="0">Unpublished</option>
		<option value="1">Published</option>
		<option value="2">Ended</option>
		</select>
	  </div>
		  
	  </div>
	  <div class="modal-footer">
		<input type="hidden" name="roundID">		
		<input type="hidden" name="delphiID" value="<%=request.queryString("stepID")%>"> 
		<input type="hidden" name="stepID" value="<%=request.queryString("stepID")%>"> 
		<button type="button" class="btn btn-sm btn-secondary m-1 text-center" data-bs-dismiss="modal">Close</button>
		<button type="submit" class="btn btn-sm btn-danger m-1 text-center" ><i class="bi bi-save text-light"></i> Save</button>
	  </div> 
	</form>
	</div>
  </div>
</div>		
	
	
	
	
<!-- manage description Modal -->
<div class="modal fade" id="manageDescriptionModal" tabindex="-1" aria-labelledby="manageDescriptionModal" aria-hidden="true">
  <div class="modal-dialog modal-dialog-centered modal-xl">
    <div class="modal-content">
      <div class="modal-header">
        <h5 class="modal-title" id="descriptionModal"></h5>
        <button type="button" class="btn-close" data-bs-dismiss="modal" aria-label="Close"></button>
      </div>
      <div class="modal-body p-0">
        <iframe id="iframeDescription" src="" class="w-100" style="height:600px">
		</iframe>
      </div>
     </div>
  </div>
</div>		

<script>
$('#manageDescriptionModal').on('show.bs.modal', function(e) {
	var title = $(e.relatedTarget).data('title');
	var url = $(e.relatedTarget).data('url');
    
	$('#descriptionModal').html(title);
	$('#iframeDescription').attr('src',url);
});
</script>

	
	
<script>

$('#manageRounds').on('show.bs.modal', function(e) {

	var title = $(e.relatedTarget).data('title');

	var description = $(e.relatedTarget).data('description');
	var state = $(e.relatedTarget).data('state');
	
	var roundID = $(e.relatedTarget).data('roundId');

	var url = $(e.relatedTarget).data('url');
	
    $(e.currentTarget).find('#formManageRounds').attr('action', url);
    $(e.currentTarget).find('#roundModalLabel').html(title);
    $(e.currentTarget).find('textarea[name="description"]').val(description);
	$(e.currentTarget).find('input[name="roundID"]').val(roundID);
	
	console.log(roundID);
	if (roundID === undefined) $('#state').attr("disabled", true); 

	$('#state option[value=' + state + ']').attr('selected', 'selected');

	});
</script>

<%
render.renderFooter()
%>
