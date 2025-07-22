<!--#include virtual="/system.asp"-->
<!--#include virtual="/checklogin.asp"-->
<!--#include virtual="/checkworkflow.asp"-->

<%

Dim rs, usuario, workflowID

call getRecordSet(SQL_CONSULTA_WORKFLOW_STEP_ID(Request.QueryString("stepID")), rs)

if rs.eof then
	response.write "FTA Method not found in the Workflow."
	response.end
else 
	workflowID = rs("workflowID")
end if

function showOptions
 	Call getRecordSet(SQL_CONSULTA_WORKFLOW_AVAILABLE_USERS_BY_STEP_ROLE(Request.QueryString("stepID"), request.queryString("role")), usuario)

	response.write "[" 
		while not usuario.eof
			response.write "{ Value: '"+ usuario("email") + "', DisplayText: '"+ usuario("name") + "' }"
			usuario.movenext
			if not usuario.eof then response.write ", "
		wend
	response.write "]"	

end function

render.renderToBody()
%>

		
<div class="p-1">
	
	
 <%

 	call getRecordset(SQL_CONSULTA_WORKFLOW_USERS_BY_STEP_ROLE(request.queryString("stepID"), request.queryString("role")),rs)
	
	if rs.eof then
		Session("message") = "There is no participants in the role </b>" & request.queryString("role") & "</b>"
		%>
		
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
	else
	
	%>
	

 	<%if Session("message") <> "" then%>
	  <div class="alert alert-danger alert-dismissible" role="alert">
		<%=Session("message")%>
		<button type="button" class="btn-close" data-bs-dismiss="alert" aria-label="Close"></button>
	  </div>		
	<%
	Session("message") = ""
	end if%>
	
	
<table class="table table-striped table-hover">
  <thead class="table-dark">
	<tr>
		<td></td>
		<td>Name</td>
		<td>E-mail</td>
		<td style="min-width:50px;">Actions</td>
	</tr>
  </thead>
  <tbody>
 	<%
	
	while not rs.eof


	%>
	<tr>
		<td>
			<img src='<%=rs("photo")%>'  class="rounded-circle align-middle" style="height:24px;width:auto;" /> 
		</td>
		<td>
			<a><%=rs("name")%></a> 
		</td>
		<td>
			<a><%=rs("email")%></a> 
		</td>
		<td>
			<a href="/stepUserActions.asp?action=delete&stepID=<%=request.queryString("stepID")%>&email=<%=rs("email")%>&role=<%=request.queryString("role")%>" title="Delete"><img src="/img/delete.png" style="height:20px;width:auto;"></a>
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
	
  <div class="p-3">
  </div>
  
 <div class="modal-footer fixed-bottom pb-0 px-0 mx-0 bg-white">
		<button class="btn btn-sm btn-danger m-1" type="button" data-bs-toggle="modal" data-bs-target="#addUserModal"> <i class="bi bi-person-plus text-light"></i> Add Participant</button>
		<button class="btn btn-sm btn-secondary m-1" onclick="top.location.href='/manageWorkflow.asp?workflowID=<%=cstr(workflowID)%>';"> Close</button>
</div>		
   
	   
	   <!-- ADD USER Modal -->
	<div class="modal fade" id="addUserModal" tabindex="-1" aria-labelledby="uploadModalLabel" aria-hidden="true">
	  <div class="modal-dialog modal-dialog-centered">
		<div class="modal-content">
		<form method="post" action="/stepUserActions.asp?action=new&stepID=<%=request.queryString("stepID")%>&role=<%=request.queryString("role")%>" class="m-0">
		  <div class="modal-header">
			<h5 class="modal-title" id="addModalLabel">Add Participant</h5>
			<button type="button" class="btn-close" data-bs-dismiss="modal" aria-label="Close"></button>
		  </div>
		  <div class="modal-body">

		 <select class="form-control"  name="participant" id="participant">
			<option value="" dafault>Select a Participant</option>
			<% 
			Call getRecordSet(SQL_CONSULTA_WORKFLOW_AVAILABLE_USERS_BY_STEP_ROLE(Request.QueryString("stepID"), request.queryString("role")), usuario)
			while not usuario.eof
			%>
			  <option value="<%=usuario("email")%>"><%=usuario("name")%></option>
	
			<%
			usuario.movenext
			wend
			%>
		  </select>
		  
		  </div>
		  <div class="modal-footer">
			<button type="button" class="btn btn-sm btn-secondary m-1 text-center" data-bs-dismiss="modal">Close</button>
			<button type="submit" class="btn btn-sm btn-danger m-1 text-center" ><i class="bi bi-save text-light"></i> Save</button>
		  </div> 
		</form>
		</div>
	  </div>
	</div>		
   
   
   
   
   
	  	   <!-- EDIT USER Modal -->
	<div class="modal fade" id="editUserModal" tabindex="-1" aria-labelledby="uploadModalLabel" aria-hidden="true">
	  <div class="modal-dialog modal-dialog-centered">
		<div class="modal-content">
		<form method="post" action="/adminUserActions.asp?action=update" class="m-0">
		  <div class="modal-header">
			<h5 class="modal-title" id="editModalLabel">Edit User</h5>
			<button type="button" class="btn-close" data-bs-dismiss="modal" aria-label="Close"></button>
		  </div>
		  <div class="modal-body">

		   <div class="mb-3">
			<label for="editemail" class="form-label">E-mail</label>
			<input type="editemail" class="form-control" id="editemail" name="editemail" readonly> 
		  </div>
		  
		  <div class=" mb-3">
			<label for="editname" class="form-label">Name</label>
			<input type="text" class="form-control" id="editname" name="editname" autocomplete="one-time-code">
		  </div>

		  <div class=" mb-3">
			<div class="form-check form-switch">
			  <input class="form-check-input" type="checkbox" id="changePasswordCheck" name="changePasswordCheck">
			  <label class="form-check-label" for="changePasswordCheck">Change password</label>
			</div>
		  </div>

		  <div class="mb-3 d-none" id="editpasswordDiv">
			<label for="editpassword" class="form-label">Password</label>
			<input type="password" class="form-control" id="editpassword" name="editpassword" autocomplete="one-time-code">
		  </div>
		  
		  <div class="mb-3">
			<div class="form-check form-switch">
				<input class="form-check-input" type="checkbox" id="editisadmin" name="editisadmin">
				<label for="editisadmin" class="form-check-label">Admin</label>
			</div>
		  </div>
		  
		<div class="mb-3">
		  	<div class="form-check form-switch">
				<input class="form-check-input" type="checkbox" id="editismanager" name="editismanager">
				<label for="editismanager" class="form-check-label">Manager</label>
			</div>
		  </div>

			  
		  </div>
		  <div class="modal-footer">
			<button type="button" class="btn btn-sm btn-secondary m-1 text-center" data-bs-dismiss="modal">Close</button>
			<button type="submit" class="btn btn-sm btn-danger m-1 text-center" ><i class="bi bi-save text-light"></i> Save</button>
		  </div> 
		</form>
		</div>
	  </div>
	</div>		

</div>

<script>

$("#changePasswordCheck").change(function() {
  if ($(this).is(":checked")) {
    $('#editpasswordDiv').addClass("d-block");
    $('#editpasswordDiv').removeClass("d-none");
  } else {
    $('#editpasswordDiv').addClass("d-none");
    $('#editpasswordDiv').removeClass("d-block");
  }
});


$('#editUserModal').on('show.bs.modal', function(e) {
    var email = $(e.relatedTarget).data('email');
    var name = $(e.relatedTarget).data('name');
    var admin = $(e.relatedTarget).data('admin');
    var manager = $(e.relatedTarget).data('manager');
    $(e.currentTarget).find('input[name="editemail"]').val(email);
    $(e.currentTarget).find('input[name="editname"]').val(name);

	if (admin == "on") $(e.currentTarget).find('input[name="editisadmin"]').prop("checked", true );
	else $(e.currentTarget).find('input[name="editisadmin"]').prop("checked", false );
	
	if (manager == "on") $(e.currentTarget).find('input[name="editismanager"]').prop("checked", true );
	else $(e.currentTarget).find('input[name="editismanager"]').prop("checked", false );
    
});

</script>

<%
render.renderFromBody()
%>

							