<!--#include virtual="/system.asp"-->
<%
saveCurrentURL
render.renderTitle()
%>

	<section id="login" class="vh-100">
	<form id="loginForm" action="login.asp" method="post">
	
  <div class="container py-5 h-100">
    <div class="row d-flex justify-content-center align-items-center h-100">
      <div class="col-12 col-md-8 col-lg-6 col-xl-5">
        <div class="card bg-dark text-white" style="border-radius: 1rem;">
          <div class="card-body p-5 text-center">

            <div class="mb-md-2 mt-md-4 pb-2">

              <h2 class="fw-bold mb-2 text-uppercase">Sign In</h2>
              <p class="text-white-50 mb-5">Please enter your login and password!</p>

              <div class="form-floating text-dark mb-4">
                <input type="email" id="username" name="email" class="form-control form-control-lg" />
                <label class="form-label" for="username">Email</label>
              </div>

              <div class="form-floating text-dark mb-4">
                <input type="password" id="password" name="password" class="form-control form-control-lg" />
                <label class="form-label" for="password">Password</label>
              </div>

<!--              <p class="small mb-3 pb-lg-2"><a class="text-white-50" href="#!">Forgot password?</a></p> -->

              <button class="btn btn-outline-light btn-lg px-5" type="submit">Login</button>

            </div>

			
		<% if Session("loginError") <> "" then %>			
				<div class="alert alert-danger alert-dismissible" role="alert">
				  <%=Session("loginError")%>
				 <button type="button" class="btn-close" data-bs-dismiss="alert" aria-label="Close"></button>
				</div>		
		<% end if
		if SIGNUP_ALLOWED then %>
				<div>
				  <p class="mb-0">Don't have an account? <a href="#!" onclick="showPanel('#signup');" class="text-white-50 fw-bold">Sign Up</a></p>
				</div>								
		<%end if %>													
				<div>
				  <p class="mb-0">Forgot your password? <a href="#!" onclick="showPanel('#recovery');" class="text-white-50 fw-bold">Reset your Password</a></p>
				</div>						

          

          </div>
        </div>
      </div>
    </div>
  </div>
  <input type="hidden" name="afterLoginGoTo"  value="<%=Session("afterLoginGoTo")%>">
  </form>
</section>
   
   
   	<section id="signup" class="vh-100" style="display:none">
	<form id="signupForm" action="signup.asp" method="post">
	
  <div class="container py-5 h-100">
    <div class="row d-flex justify-content-center align-items-center h-100">
      <div class="col-12 col-md-8 col-lg-6 col-xl-5">
        <div class="card bg-dark text-white" style="border-radius: 1rem;">
          <div class="card-body p-5 text-center">

            <div class="mb-md-2 mt-md-4 pb-2">

              <h2 class="fw-bold mb-2 text-uppercase">Sign Up</h2>
              <p class="text-white-50 mb-5">Please enter your name, e-mail and password!</p>
			
			<div class="form-floating text-dark mb-4">
                <input type="text" id="su_name" name="su_name" class="form-control form-control-lg" />
                <label class="form-label" for="su_name">Name</label>
              </div>

			  
              <div class="form-floating text-dark mb-4">
                <input type="email" id="su_email" name="su_email" class="form-control form-control-lg" />
                <label class="form-label" for="su_email">Email</label>
              </div>

              <div class="form-floating text-dark mb-4">
                <input type="password" id="su_password" name="su_password" class="form-control form-control-lg" />
                <label class="form-label" for="su_password">Password</label>
              </div>

			  
              <div class="form-floating text-dark mb-4">
                <input type="password" id="su_rpassword" name="su_rpassword" class="form-control form-control-lg" />
                <label class="form-label" for="su_rpassword">Password (again)</label>
              </div>

			  <input type="hidden" name="afterLoginGoTo"  value="<%=Session("afterLoginGoTo")%>">

			  <button type="button" value="Cancel" class="btn btn-outline-light btn-lg px-5" onclick="showPanel('#login');return false;">Back</button>
              <button class="btn btn-outline-light btn-lg px-5" type="submit" onclick="return validateSignUp();">Sign Up</button>

            </div>

			
		<% if Session("loginError") <> "" then %>			
				<div class="alert alert-danger alert-dismissible" role="alert">
				  <%=Session("loginError")%>
				 <button type="button" class="btn-close" data-bs-dismiss="alert" aria-label="Close"></button>
				</div>		
		<%end if %>													
	

          

          </div>
        </div>
      </div>
    </div>
  </div>
  </form>
  
</section>




   
   	<section id="recovery" class="vh-100" style="display:none">
	<form id="recoveryForm" action="recovery.asp?action=request" method="post">
	
  <div class="container py-5 h-100">
    <div class="row d-flex justify-content-center align-items-center h-100">
      <div class="col-12 col-md-8 col-lg-6 col-xl-5">
        <div class="card bg-dark text-white" style="border-radius: 1rem;">
          <div class="card-body p-5 text-center">

            <div class="mb-md-2 mt-md-4 pb-2">

              <h2 class="fw-bold mb-2 text-uppercase">Password Reset</h2>
              <p class="text-white-50 mb-5">Please enter your e-mail to receive a password reset link.</p>
			
		
              <div class="form-floating text-dark mb-5">
                <input type="email" id="re_email" name="re_email" class="form-control form-control-lg" />
                <label class="form-label" for="re_email">Email</label>
              </div>

        
			  <button type="button" value="Cancel" class="btn btn-outline-light btn-lg px-5" onclick="showPanel('#login');return false;">Back</button>
              <button class="btn btn-outline-light btn-lg px-5" type="submit">Send Recovery Mail</button>

            </div>

			
		<% if Session("recoveryError") <> "" then %>			
				<div class="alert alert-danger alert-dismissible" role="alert">
				  <%=Session("recoveryError")%>
				 <button type="button" class="btn-close" data-bs-dismiss="alert" aria-label="Close"></button>
				</div>		
		<%end if %>													
		<% if Session("recoverySuccess") <> "" then %>			
				<div class="alert alert-success alert-dismissible" role="alert">
				  <%=Session("recoverySuccess")%>
				 <button type="button" class="btn-close" data-bs-dismiss="alert" aria-label="Close"></button>
				</div>		
		<%end if %>			

          

          </div>
        </div>
      </div>
    </div>
  </div>
  </form>
  
</section>





   	<section id="reset" class="vh-100" style="display:none">
	<form id="resetForm" action="recovery.asp?action=save" method="post">
	
  <div class="container py-5 h-100">
    <div class="row d-flex justify-content-center align-items-center h-100">
      <div class="col-12 col-md-8 col-lg-6 col-xl-5">
        <div class="card bg-dark text-white" style="border-radius: 1rem;">
          <div class="card-body p-5 text-center">

            <div class="mb-md-2 mt-md-4 pb-2">

              <h2 class="fw-bold mb-2 text-uppercase">Reset Password</h2>
              <p class="text-white-50 mb-5">We are almost done. Please enter your new password.</p>
			
              <div class="form-floating text-dark mb-4">
                <input type="password" id="re_password" name="re_password" class="form-control form-control-lg" />
                <label class="form-label" for="re_password">Password</label>
              </div>

			  
              <div class="form-floating text-dark mb-5">
                <input type="password" id="re_rpassword" name="re_rpassword" class="form-control form-control-lg" />
                <label class="form-label" for="re_rpassword">Password (again)</label>
              </div>

			  <input type="hidden" name="email"  value="<%=Session("resetUser")%>">
			  <input type="hidden" name="verification"  value="<%=Session("resetVerification")%>">

              <button class="btn btn-outline-light btn-lg px-5" type="submit" onclick="return validateReset();">Change Password</button>

            </div>

          </div>
        </div>
      </div>
    </div>
  </div>
  </form>
  
</section>


		
<script>
function showPanel(panel){
	var panels = ["#login", "#signup", "#recovery", "#reset"];
	var forms = ["#loginForm", "#signupForm", "#recoveryForm", "#resetForm"];
	
	for (let index = 0; index < panels.length; ++index) {
		if (panel===panels[index]) {
			$(panels[index]).show();
			$(forms[index])[0].reset();
		}
		else {
			$(panels[index]).hide();
		}
	}

}


function validateReset(){
	 var pass = $('#re_password').val();
	 var pass2 = $('#re_rpassword').val();
	
	var errors = "";

	if (pass.length < 8) {
		errors += "The password must be at least 8 characters long.\n";
	}
	
	if (pass!=pass2) {
		errors += "Password confirmation doesn't match Password."
	}
	
	if (errors=="") {
		return true;
	}
	else {
		alert(errors)
		return false;
	}
	 
}


function validateSignUp(){
	 var emailReg = /^([\w-\.]+@([\w-]+\.)+[\w-]{2,4})?$/;
	 var name = $('#su_name').val();
	 var email = $('#su_email').val();
	 var pass = $('#su_password').val();
	 var pass2 = $('#su_rpassword').val();
	
	var errors = "";
	
	if(name.length < 1){
		errors += "Please provide the user name.\n";
    }
	
	if(email.length < 1){
		errors += "Please provide the user e-mail.\n";
    }
	
	if(!emailReg.test(email)){
		errors += "Email must be a valid email address.\n";
    }
	
	if (pass.length < 8) {
		errors += "The password must be at least 8 characters long.\n";
	}
	
	if (pass!=pass2) {
		errors += "Password confirmation doesn't match Password."
	}
	
	if (errors=="") {
		return true;
	}
	else {
		alert(errors)
		return false;
	}
	 
}
</script>
 	  

	  	<%
		if Session("recoveryError") <> "" or Session("recoverySuccess") <> "" then
		%>
		<script>showPanel('#recovery');</script>
		<%
		elseif (Session("resetUser") <> "" and Session("resetVerification") <> "") then
		%>
		<script>showPanel('#reset');</script>
		<%
		end if
		Session("resetUser") = ""
		Session("resetVerification") = ""
		Session("loginError") = ""
		Session("recoveryError") = ""
		Session("recoverySuccess") = ""
		Session("afterLoginGoTo") = ""
		%>			

	  
<%
render.renderFooter()
%>
