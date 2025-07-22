<!--#include virtual="/system.asp"-->
<!--#include virtual="/checklogin.asp"-->
<%
saveCurrentURL
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

<nav>
  <div class="nav nav-tabs" id="nav-tab" role="tablist">
    <button class="nav-link text-dark active" id="nav-fta-progress-tab" data-bs-toggle="tab" data-bs-target="#nav-fta-progress" type="button" role="tab" aria-controls="nav-fta-progress" aria-selected="true">Active FTA Steps</button>
    <button class="nav-link text-dark " id="nav-fta-all-tab" data-bs-toggle="tab" data-bs-target="#nav-fta-all" type="button" role="tab" aria-controls="nav-fta-all" aria-selected="false">All FTA Steps</button>
    <button class="nav-link text-dark " id="nav-my-fta-workflows-tab" data-bs-toggle="tab" data-bs-target="#nav-my-fta-workflows" type="button" role="tab" aria-controls="nav-my-fta-workflows" aria-selected="false">My FTAs in Progress</button>
    <button class="nav-link text-dark " id="nav-support-info-tab" data-bs-toggle="tab" data-bs-target="#nav-support-info" type="button" role="tab" aria-controls="nav-support-info" aria-selected="false">My Concluded FTAs</button>
<% if Session("admin") then %>
    <button class="nav-link text-dark " id="nav-fta-workflows-tab" data-bs-toggle="tab" data-bs-target="#nav-fta-workflows" type="button" role="tab" aria-controls="nav-fta-workflows" aria-selected="false">All FTAs</button>
<% end if %>
</div>
</nav>
<div class="tab-content" id="nav-tabContent">
  <div class="tab-pane fade show active" id="nav-fta-progress" role="tabpanel" aria-labelledby="nav-fta-progress">

  <%
												
	dim rs
	Dim counter
	
	call getRecordset(SQL_CONSULTA_WORKFLOW_STEPS_BY_OWNER_AND_STATUS(Session("email"), STATE_ACTIVE),rs)
	
	if rs.eof then
		response.write "<div class='py-3'><div class='alert alert-danger'> No FTA Step is waiting for your action.</div></div>"
	else
	if rs.RecordCount = 1 then
	base_folder = getBaseFolderByFTAmethodID(cstr(rs("type")))
	%>
	<script>
	
	$( document ).ready(function() {
		showConfirmationModal ('<%=getFTAMethodNamebyFTAmethodID(cstr(rs("type")))%>', '<%=rs("role")%>', '<%=base_folder%>index.asp?stepID=<%=cstr(rs("stepID"))%>');
	});
	
	</script>
	<%
	end if
	
	
	
	%>

<table class="table table-striped table-hover">
  <thead class="table-dark">
	<tr>
		<td>Method</td>
		<td>FTA</td>
		<td>Role</td>
	</tr>
  </thead>
  <tbody>
 	<%
	
	while not rs.eof

	base_folder = getBaseFolderByFTAmethodID(cstr(rs("type")))

	%>
	<tr>
		<td>
			<a class="link-dark text-decoration-none" href="<%=base_folder%>index.asp?stepID=<%=cstr(rs("stepID"))%>"><%=getFTAMethodNamebyFTAmethodID(cstr(rs("type")))%></a> 
		</td>
		<td>
		<%if rs("owner") = Session("email") or  Session("admin") then %>
			<a class="link-dark text-decoration-none" href="manageWorkflow.asp?workflowID=<%=cstr(rs("workflowID"))%>"><%=rs("description")%></a> 
		<%else%>
			<%=rs("description")%>
		<%end if%>
		</td>
		<td>
			<%=rs("role")%>
		</td>
	</tr>
	<%
	rs.movenext
	wend
	%>
	  </tbody>
	</table>
	<%
	end if
	%>
	
</div>
<div class="tab-pane fade" id="nav-fta-all" role="tabpanel" aria-labelledby="nav-fta-all">


	<%
	call getRecordset(SQL_CONSULTA_WORKFLOW_STEPS_BY_OWNER_AND_STATUS(Session("email"), STATE_CONCLUDED),rs)
	
	if rs.eof then
		response.write "<div class='py-3'><div class='alert alert-danger'> No FTA Step found.</div></div>"
	else
	%>

	<table class="table table-striped table-hover">
	  <thead class="table-dark">
		<tr>
			<td>Method</td>
			<td>FTA</td>
			<td>Role</td>
		</tr>
	  </thead>
	  <tbody>
	<%
	while not rs.eof
	base_folder = getBaseFolderByFTAmethodID(cstr(rs("type")))
	%>
	<tr>
		<td>
			<a class="link-dark text-decoration-none" href="<%=base_folder%>index.asp?stepID=<%=cstr(rs("stepID"))%>"><%=getFTAMethodNamebyFTAmethodID(cstr(rs("type")))%></a> 
		</td>
		<td>
			<% if not isnull(rs("workflowID")) then %>
				<%if rs("owner") = Session("email") or  Session("admin") then %>
					<a class="link-dark text-decoration-none" href="manageWorkflow.asp?workflowID=<%=cstr(rs("workflowID"))%>"><%=rs("description")%></a> 
				<%else%>
					<%=rs("description")%>
				<%end if%>
			<% end if %>
		</td>
		<td>
			<%=rs("role")%>
		</td>
	</tr>
	<%
	rs.movenext
	wend
	%>
	  </tbody>
	</table>
	<%
	end if
	%>
	
	
	
	</div>
  <div class="tab-pane fade" id="nav-support-info" role="tabpanel" aria-labelledby="nav-support-info">
  
  			<%
												
			
			call getRecordset(SQL_CONSULTA_WORKFLOW_PENDING_BY_OWNER(Session("email")),rs)
			
			if rs.eof then
				response.write "<div class='py-3'><div class='alert alert-danger'> No FTA workflows wirh pending support information.</div></div>"
			else
			%>
			<table class="table table-striped table-hover">
			  <thead class="table-dark">
				<tr>
					<td>Status</td>
					<td>Title</td>
					<td>Description</td>
					<td class="text-center">Steps</td>
					<td class="text-center" style="min-width:90px;">Actions</td>
				</tr>
			  </thead>
			  <tbody>
			<%
			
			while not rs.eof
			%>
			<tr>
				<td>
					<%if rs("owner") = Session("email") or  Session("admin") then %>
						<a class="link-dark text-decoration-none" href="manageWorkflow.asp?workflowID=<%=cstr(rs("workflowID"))%>"><%=getStatusWorkflow(rs("status"))%></a> 
					<%else%>
						<%=getStatusWorkflow(rs("status"))%>
					<%end if%>
				</td>
				<td>
					<%if rs("owner") = Session("email") or  Session("admin") then %>
						<a class="link-dark text-decoration-none" href="manageWorkflow.asp?workflowID=<%=cstr(rs("workflowID"))%>"><%=rs("description")%></a> 
					<%else%>
						<%=rs("description")%>
					<%end if%>
				</td>
				<td>
					<%if rs("owner") = Session("email") or  Session("admin") then %>
						<a class="link-dark text-decoration-none" href="manageWorkflow.asp?workflowID=<%=cstr(rs("workflowID"))%>"><%=left(rs("goal"), 60)%></a> 
					<%else%>
						<%=left(rs("goal"), 60)%>
					<%end if%>
				</td>
				<td class="text-center">
					<%=rs("steps")%>
				</td>
				<td class="text-center">

				<% if rs("status") > STATE_LOCKED then%>
						<a href="supportInformation.asp?workflowID=<%=cstr(rs("workflowID"))%>" title="Manage Supporting Information"><img src="/img/folder.png" style="height:20px;width:auto;"></a>
				<% end if%>
				<% if rs("status") = STATE_UNLOCKED then%>
						<a href="workflowActions.asp?action=lock&location=outside&workflowID=<%=cstr(rs("workflowID"))%>" title="Lock and Start FTA" onclick="if (!confirm('Are you sure?')) { return false; }"><img src="/img/locker.png" style="height:20px;width:auto;"></a>
										<a href="#" data-bs-toggle="modal" data-bs-target="#manageFTA" data-workflow-id="<%=cstr(rs("workflowID"))%>" data-title="<%=cstr(rs("description"))%>" data-description="<%=cstr(rs("goal"))%>" data-url="workflowActions.asp?action=update" data-form-title="Edit FTA"><img src="/img/edit.png" style="height:20px;width:auto;"></a>
					<% if isnull(rs("parentStepID")) then%>
						<a href="workflowActions.asp?action=delete&workflowID=<%=cstr(rs("workflowID"))%>" title="Delete"><img src="/img/delete.png"  style="height:20px;width:auto;"></a>
					<% end if%>
				<% end if%>
				
				</td>
			
			</tr>
			<%
			rs.movenext
			wend
			%>
		  </tbody>
		</table>
		<%
		end if
		%>
  
  
  </div>
  <div class="tab-pane fade" id="nav-my-fta-workflows" role="tabpanel" aria-labelledby="nav-my-fta-workflows">
  
  <%
												
		
														
		call getRecordset(SQL_CONSULTA_WORKFLOW_ACTIVE_INACTIVE_BY_OWNER(Session("email")),rs)
		
		if rs.eof then
				response.write "<div class='py-3'><div class='alert alert-danger'> No FTA workflows were created by you.</div></div>"
	
		else
		%>
		<table class="table table-striped table-hover">
		  <thead class="table-dark">
			<tr>
				<td>Status</td>
				<td>Title</td>
				<td>Description</td>
				<td class="text-center">Steps</td>
				<td class="text-center" style="min-width:90px;">Actions</td>
			</tr>
		  </thead>
		  <tbody>
		<%
		
		while not rs.eof
		%>
		<tr>
			<td>
			<%if rs("owner") = Session("email") or  Session("admin") then %>
				<a class="link-dark text-decoration-none" href="manageWorkflow.asp?workflowID=<%=cstr(rs("workflowID"))%>"><%=getStatusWorkflow(rs("status"))%></a> 
			<%else%>
				<%=getStatusWorkflow(rs("status"))%>
			<%end if%>
			</td>
			<td>
			<%if rs("owner") = Session("email") or  Session("admin") then %>
				<a class="link-dark text-decoration-none" href="manageWorkflow.asp?workflowID=<%=cstr(rs("workflowID"))%>"><%=rs("description")%></a> 
			<%else%>
				<%=rs("description")%>
			<%end if%>
			</td>
			<td>
			<%if rs("owner") = Session("email") or  Session("admin") then %>
				<a class="link-dark text-decoration-none" href="manageWorkflow.asp?workflowID=<%=cstr(rs("workflowID"))%>"><%=left(rs("goal"), 60)%></a> 
			<%else%>
				<%=left(rs("goal"), 60)%>
			<%end if%>
			</td>
			<td class="text-center">
				<%=rs("steps")%>
			</td>
			<td class="text-center">
			<% if rs("status") > STATE_LOCKED then%>
					<a href="supportInformation.asp?workflowID=<%=cstr(rs("workflowID"))%>" title="Manage Supporting Information"><img src="/img/folder.png" style="height:20px;width:auto;"></a>
			<% end if%>
			<% if rs("status") = STATE_UNLOCKED then%>
				<% if getWorkflowRealSteps(cstr(rs("workflowID"))) > 0 then
				%>
					<a href="workflowActions.asp?action=lock&location=outside&workflowID=<%=cstr(rs("workflowID"))%>" title="Lock and Start FTA" onclick="if (!confirm('Are you sure?')) { return false; }"><img src="/img/locker.png" style="height:20px;width:auto;"></a>
				<% end if
				%>
			
								<a href="#" data-bs-toggle="modal" data-bs-target="#manageFTA" data-workflow-id="<%=cstr(rs("workflowID"))%>" data-title="<%=cstr(rs("description"))%>" data-description="<%=cstr(rs("goal"))%>" data-url="workflowActions.asp?action=update" data-form-title="Edit FTA"><img src="/img/edit.png" style="height:20px;width:auto;"></a>
				
				<% if isnull(rs("parentStepID")) then%>
					<a href="workflowActions.asp?action=delete&workflowID=<%=cstr(rs("workflowID"))%>" title="Delete"><img src="/img/delete.png"  style="height:20px;width:auto;"></a>
				<% end if%>
			<% end if%>
				</td>
			
		</tr>
		<%
		rs.movenext
		wend
		%>
	  </tbody>
	</table>
	<%
	end if
	%>
  
   </div>
  <div class="tab-pane fade" id="nav-fta-workflows" role="tabpanel" aria-labelledby="nav-fta-workflows">
  
  
  <%
	call getRecordset(SQL_CONSULTA_WORKFLOW_JOIN_USER(),rs)
	
	if rs.eof then
		response.write "<div class='py-3'><div class='alert alert-danger'> No FTA workflows found.</div></div>"
	else
	%>
	<table class="table table-striped table-hover">
		  <thead class="table-dark">
			<tr>
				<td>Status</td>
				<td>Title</td>
				<td>Description</td>
				<td class="text-center">Steps</td>
				<td class="text-center" style="min-width:90px;">Actions</td>
			</tr>
		  </thead>
		  <tbody>
	<%

	while not rs.eof
	%>
	<tr>
			<td>
			<%if rs("owner") = Session("email") or  Session("admin") then %>
				<a class="link-dark text-decoration-none" href="manageWorkflow.asp?workflowID=<%=cstr(rs("workflowID"))%>"><%=getStatusWorkflow(rs("status"))%></a> 
			<%else%>
				<%=getStatusWorkflow(rs("status"))%>
			<%end if%>
			</td>
			<td>
			<%if rs("owner") = Session("email") or  Session("admin") then %>
				<a class="link-dark text-decoration-none" href="manageWorkflow.asp?workflowID=<%=cstr(rs("workflowID"))%>"><%=rs("description")%></a> 
			<%else%>
				<%=rs("description")%>
			<%end if%>
			</td>
			<td>
			<%if rs("owner") = Session("email") or  Session("admin") then %>
				<a class="link-dark text-decoration-none" href="manageWorkflow.asp?workflowID=<%=cstr(rs("workflowID"))%>"><%=left(rs("goal"), 60)%></a> 
			<%else%>
				<%=left(rs("goal"), 60)%>
			<%end if%>
			</td>
			<td class="text-center">
				<%=rs("steps")%>
			</td>
			<td class="text-center">
			<% if rs("status") > STATE_LOCKED then%>
					<a href="supportInformation.asp?workflowID=<%=cstr(rs("workflowID"))%>" title="Manage Supporting Information"><img src="/img/folder.png" style="height:20px;width:auto;"></a>
			<% end if%>
			<% if rs("status") = STATE_UNLOCKED then%>
				<% if getWorkflowRealSteps(cstr(rs("workflowID"))) > 0 then
				%>
					<a href="workflowActions.asp?action=lock&location=outside&workflowID=<%=cstr(rs("workflowID"))%>" title="Lock and Start FTA" onclick="if (!confirm('Are you sure?')) { return false; }"><img src="/img/locker.png" style="height:20px;width:auto;"></a>
				<% end if
				%>
			
				<a href="#" data-bs-toggle="modal" data-bs-target="#manageFTA" data-workflow-id="<%=cstr(rs("workflowID"))%>" data-title="<%=cstr(rs("description"))%>" data-description="<%=cstr(rs("goal"))%>" data-url="workflowActions.asp?action=update" data-form-title="Edit FTA"><img src="/img/edit.png" style="height:20px;width:auto;"></a>
				
			<% end if%>
			<% if (rs("status") = STATE_UNLOCKED and isnull(rs("parentStepID"))) or Session("admin") then%>
				<a href="workflowActions.asp?action=delete&workflowID=<%=cstr(rs("workflowID"))%>" title="Delete" onclick="if (!confirm('Are you sure?')) { return false; }"><img src="/img/delete.png"  style="height:20px;width:auto;"></a>
			<% end if%>
			</td>
			
	<%
	rs.movenext
	wend
	%>
	</tbody>
</table>
	<%
	end if
	%>


  
  </div>
    
</div>
  <div class="p-3">
  </div>
  <nav class="navbar fixed-bottom navbar-light bg-light">
         <div class="container-fluid justify-content-center p-0">
            <button class="btn btn-sm btn-danger m-1" type="button" data-bs-toggle="modal" data-bs-target="#manageFTA" data-url="workflowActions.asp?action=new" data-form-title="New FTA"> <i class="bi bi-plus-square text-light"></i> New FTA</button>
         </div>
      </nav>
	  
	  
	  
	     <!-- Redirect Modal -->
	<div class="modal fade" id="redirectFTA" tabindex="-1" aria-labelledby="redirectModalLabel" aria-hidden="true">
	  <div class="modal-dialog modal-dialog-centered">
		<div class="modal-content">

		  <div class="modal-header">
			<h5 class="modal-title" id="redirectTitleModal"></h5>
			<button type="button" class="btn-close" data-bs-dismiss="modal" aria-label="Close"></button>
		  </div>
		  <div class="modal-body" id="redirectTextModal">		  
		  
		  </div>
		  <div class="modal-footer">
			<button type="button" class="btn btn-sm btn-secondary m-1 text-center" data-bs-dismiss="modal" onclick="setLocalStorage('autoOpenMethod', false, 120);">No, Thanks.</button>
			<button type="button" class="btn btn-sm btn-danger m-1 text-center" id="redirectButtonModal"><i class="bi bi-forward text-light"></i> Let's Go!</button>
		  </div> 

		</div>
	  </div>
	</div>		

	  
	  
	  
	     
	   <!-- ADD FTA Modal -->
	<div class="modal fade" id="manageFTA" tabindex="-1" aria-labelledby="uploadModalLabel" aria-hidden="true">
	  <div class="modal-dialog modal-dialog-centered">
		<div class="modal-content">
		<form method="post" id="formManageFTA" action="" class="requires-validation m-0" novalidate>
		  <div class="modal-header">
			<h5 class="modal-title" id="ftaModalLabel">New FTA</h5>
			<button type="button" class="btn-close" data-bs-dismiss="modal" aria-label="Close"></button>
		  </div>
		  <div class="modal-body">

		   <div class="mb-3">
			<label for="title" class="form-label">Title</label>
			<input type="text" class="form-control" id="title" name="title" required> 
			<div class="invalid-feedback">Title cannot be blank!</div>
		  </div>
		  
		  <div class=" mb-3">
			<label for="description" class="form-label">Description</label>
 		    <textarea class="form-control" id="description" name="description" rows="3"></textarea>
		  </div>
		  
		  
		  </div>
		  <div class="modal-footer">
			<input type="hidden" name="workflowID">
			<input type="hidden" name="redirectTo" value="workplace">
			<button type="button" class="btn btn-sm btn-secondary m-1 text-center" data-bs-dismiss="modal">Close</button>
			<button type="submit" class="btn btn-sm btn-danger m-1 text-center" ><i class="bi bi-save text-light"></i> Save</button>
		  </div> 
		</form>
		</div>
	  </div>
	</div>		
	
	
	
	
</div>	

    
<script>

$('#manageFTA').on('show.bs.modal', function(e) {
    var workflowID = $(e.relatedTarget).data('workflowId');
	var title = $(e.relatedTarget).data('title');
    var description = $(e.relatedTarget).data('description');
	
	var formTitle = $(e.relatedTarget).data('formTitle');
	var url = $(e.relatedTarget).data('url');

	$(e.currentTarget).find('#formManageFTA').attr('action', url);
    $(e.currentTarget).find('#ftaModalLabel').html(formTitle);
	
    $(e.currentTarget).find('input[name="workflowID"]').val(workflowID);
    $(e.currentTarget).find('input[name="title"]').val(title);
    $(e.currentTarget).find('textarea[name="description"]').val(description);
    
});

$('#nav-tab').on("shown.bs.tab",function(e){
	localStorage.setItem("workplace-idtab", e.target.id);
});


$( document ).ready(function() {
   var id_tab = localStorage.getItem("workplace-idtab"); 
   if (id_tab!="") {
	   var triggerEl = document.querySelector("#"+id_tab)
	   triggerEl.click();
   }

   
});




  // Fetch all the forms we want to apply custom Bootstrap validation styles to
  var forms = document.querySelectorAll('.requires-validation');

  // Loop over them and prevent submission
  Array.prototype.slice.call(forms)
    .forEach(function (form) {
      form.addEventListener('submit', function (event) {
        if (!form.checkValidity()) {
          event.preventDefault()
          event.stopPropagation()
        }

        form.classList.add('was-validated')
      }, false)
    });


function showConfirmationModal (method, role, link) {
	var autoOpenMethod = getLocalStorage('autoOpenMethod');

	$('#redirectButtonModal').attr('onclick', "top.location.href='"+link+"';");
	$('#redirectTitleModal').html("Single Active Step");
	$('#redirectTextModal').html("You only one active step: <i>"+method+"</i> (role <i>"+role+"</i>). <br>Would you like to open it now?");

	// autoOpenMethod can only be undefined or false
	if (typeof autoOpenMethod === 'undefined') {
		$('#redirectFTA').modal('show');
	}

}

</script>
				
<%
render.renderFooter()
%>