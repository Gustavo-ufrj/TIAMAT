<!--#include virtual="/system.asp"-->
<!--#include virtual="/checklogin.asp"-->
<%
saveCurrentURL
render.renderTitle()
%>

<div class="container py-3">
<div class="d-flex justify-content-center">
<form action="updateprofile.asp" method="post">
  <div class="container py-2" > 
	<a href="#" data-bs-toggle="modal" data-bs-target="#uploadModal"> 
	<img src="<%response.write Session("photo")%>" class="rounded-circle align-middle" height="250px" width="auto">
	</a>
  </div>
  
  <div class="mb-3">
    <label for="email" class="form-label">E-mail</label>
    <input type="email" class="form-control" id="email" name="email" value="<%response.write Session("email")%>" disabled>
  </div>
  
  <div class=" mb-3">
    <label for="username" class="form-label">Name</label>
    <input type="text" class="form-control" id="username" name="name" value="<%response.write Session("name")%>">
  </div>
  
  <div class="mb-3">
    <label for="password" class="form-label">Current Password</label>
    <input type="password" class="form-control" id="password" name="password">
  </div>
    
  <div class=" mb-3">
    <label for="newpassword" class="form-label">New Password</label>
    <input type="password" class="form-control" id="newpassword" name="newpassword">
  </div>
  
  <div class="mb-3">
    <label for="newpassword2" class="form-label">New Password (again)</label>
    <input type="password" class="form-control" id="newpassword2" name="newpassword2">
  </div>
      
	<%if Session("loginError") <> "" then%>
		  <div class="alert alert-danger alert-dismissible" role="alert">
			<%=Session("loginError")%>
			<button type="button" class="btn-close" data-bs-dismiss="alert" aria-label="Close"></button>
		  </div>		
	<%
	Session("loginError") = ""
	end if%>	  
	  
	<div class="p-3">
    </div>
    <nav class="navbar fixed-bottom navbar-light bg-light">
         <div class="container-fluid justify-content-center p-0">
            <button class="btn btn-sm btn-danger m-1 text-center" type="submit"> <i class="bi bi-save text-light"></i> Save</button>
         </div>
     </nav>
  
  
  </form>
</div>
</div>

					  
   
<!-- Modal -->
<div class="modal fade" id="uploadModal" tabindex="-1" aria-labelledby="uploadModalLabel" aria-hidden="true">
  <div class="modal-dialog modal-dialog-centered">
    <div class="modal-content">
      <div class="modal-header">
        <h5 class="modal-title" id="uploadModalLabel">Update Avatar</h5>
        <button type="button" class="btn-close" data-bs-dismiss="modal" aria-label="Close"></button>
      </div>
      <div class="modal-body">
        <iframe src="/upload/upform.asp?numfiles=1&resize=1&url=/profile.asp" class="w-100" style="height:200px">
		</iframe>
      </div>
 <!-- <div class="modal-footer">
        <button type="button" class="btn btn-secondary" data-bs-dismiss="modal">Close</button>
        <button type="button" class="btn btn-primary">Save changes</button>
      </div> -->
    </div>
  </div>
</div>		
				
<%
render.renderFooter()
%>