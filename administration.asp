<!--#include virtual="/system.asp"-->
<!--#include virtual="/checklogin.asp"-->
<!--#include virtual="/checkadmin.asp"-->

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
	
	
 <%
												
	dim rs
	Dim counter
	
	call getRecordset(SQL_CONSULTA_USUARIO_TODOS(),rs)
	
	if rs.eof then
		response.write "No users in the system. Check that with administrators (?) :)"
	else
	%>
	

<table class="table table-striped table-hover">
  <thead class="table-dark">
	<tr>
		<td></td>
		<td>Name</td>
		<td>E-mail</td>
		<td>Roles</td>
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
		<%
		Dim isadmin 
		isadmin = rs("admin")
		Dim ismanager 
		ismanager = rs("ftacreator")
		
  	    if isadmin and ismanager then
			Response.Write "Admin, Manager"
		else
			if isadmin or ismanager then
				if isadmin then 
					Response.Write "Admin"
				end if
				if ismanager then 
					Response.Write "Manager"			
				end if
				Response.Write join(split(roles, ","), ", ")
			else
				Response.Write "User"			
			end if
		end if
		%>
		</td>
		<td>
			<a href="#" title="Edit" data-bs-toggle="modal" data-bs-target="#editUserModal" data-email="<%=cstr(rs("email"))%>" data-name="<%=cstr(rs("name"))%>" data-admin="<% Response.write IIF(isadmin,"on", "off") %>" data-manager="<% Response.write IIF(ismanager,"on", "off") %>"><img src="/img/edit.png" style="height:20px;width:auto;"></a>
			<a href="adminUserActions.asp?action=delete&email=<%=cstr(rs("email"))%>" title="Delete"><img src="/img/delete.png" style="height:20px;width:auto;"></a>
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
  <nav class="navbar fixed-bottom navbar-light bg-light">
         <div class="container-fluid justify-content-center p-0">
            <button class="btn btn-sm btn-danger m-1" type="button" data-bs-toggle="modal" data-bs-target="#addUserModal"> <i class="bi bi-person-plus text-light"></i> Add User</button>
         </div>
   </nav>
   
	   
	   <!-- ADD USER Modal -->
	<div class="modal fade" id="addUserModal" tabindex="-1" aria-labelledby="uploadModalLabel" aria-hidden="true">
	  <div class="modal-dialog modal-dialog-centered">
		<div class="modal-content">
		<form method="post" action="/adminUserActions.asp?action=new" class="m-0">
		  <div class="modal-header">
			<h5 class="modal-title" id="addModalLabel">New User</h5>
			<button type="button" class="btn-close" data-bs-dismiss="modal" aria-label="Close"></button>
		  </div>
		  <div class="modal-body">

		   <div class="mb-3">
			<label for="email" class="form-label">E-mail</label>
			<input type="email" class="form-control" id="email" name="email"> 
		  </div>
		  
		  <div class=" mb-3">
			<label for="username" class="form-label">Name</label>
			<input type="text" class="form-control" id="username" name="newname" autocomplete="one-time-code">
		  </div>
		  
		  <div class="mb-3">
			<label for="password" class="form-label">Password</label>
			<input type="password" class="form-control" id="password" name="newpassword" autocomplete="one-time-code">
		  </div>
		  
		  
		  <div class="mb-3">
			<div class="form-check form-switch">
				<input class="form-check-input" type="checkbox" id="isadmin" name="isadmin">
				<label for="isadmin" class="form-check-label">Admin</label>
			</div>
		  </div>
		  
		<div class="mb-3">
		  	<div class="form-check form-switch">
				<input class="form-check-input" type="checkbox" id="ismanager" name="ismanager">
				<label for="ismanager" class="form-check-label">Manager</label>
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
render.renderFooter()
%>
