<!--#include virtual="/system.asp"-->
<%
saveCurrentURL
render.renderTitle()
%>

   <div class="bg-dark" style="height:700px; background-position:center; background-repeat:no-repeat;background-size:cover; background-image:url(img/theme/notebook.jpg);">
      <div class="row h-100 p-5">
         <div class="col-lg-6 col-md-10 col-sm-12 align-self-center">
            <h1 class="fs-1 fw-bolder text-light text-shadow text-uppercase" style="text-shadow:1px 1px 2px #333333;">Welcome to TIAMAT</h1>
            <span class="fs-4 text-light" style="text-shadow:1px 1px 2px #333333;"> TIAMAT is a software designed to support integrated distributed Future-oriented Technology Analysis (FTA). It's model supports FTA workflows, in which some FTA methods are executed as strategic FTA, and the others as operational FTA.</span>
            <p class="center p-4">
               <a href="/workplace.asp" class="btn btn-large btn-danger"><i class="bi bi-forward"></i> Start TIAMAT!</a>
            </p>
         </div>
      </div>
   </div>
   <div style="height:700px;">
      <div class="row h-100 p-5">
         <div class="col-lg-12 col-md-12 col-sm-12 col-xs-12 align-self-center d-inline">
            <div class="p-3">
               <h1 class="fs-1 fw-bolder text-uppercase">Work Anytime, Anywhere</h1>
               <p class="fs-3"> TIAMAT allows you to perform FTA at your preferred time, using any device (computer, tablet, smartphone). </p>
            </div>
            <div class="p-3 text-end">
               <h1 class="fs-1 fw-bolder text-uppercase">Work in Group</h1>
               <p class="fs-3">With TIAMAT, your group may perform your FTA together through the Internet.</p>
            </div>
         </div>
      </div>
   </div>
   
   
    <div style="height:700px;">
   <div id="carouselHome" class="carousel slide" data-bs-ride="carousel">
  <div class="carousel-indicators">
    <button type="button" data-bs-target="#carouselHome" data-bs-slide-to="0" class="active" aria-current="true" aria-label="Slide 1"></button>
    <button type="button" data-bs-target="#carouselHome" data-bs-slide-to="1" aria-label="Slide 2"></button>
    <button type="button" data-bs-target="#carouselHome" data-bs-slide-to="2" aria-label="Slide 3"></button>
  </div>
  <div class="carousel-inner">
    <div class="carousel-item active">
      <img src="img/theme/organizational_focus.jpg" class="d-block w-100" style="object-fit: cover; object-position: center; height: 700px; overflow: hidden;" alt="...">
      <div class="carousel-caption d-none d-md-block" style="top:15rem;">
			<h1 class="fs-1 text-light fw-bolder text-uppercase">Organization Focus</h1>
		   <span class="fs-3 text-light">TIAMAT is an decision-making tool designed for organizations. TIAMAT helps the translation of the decision-makers needs into FTA studies. Our concept is to allow TIAMAT users to create FTA Workflows, improving the organization forecast capability.</span>
      </div>
    </div>
    <div class="carousel-item">
      <img src="img/theme/distributed.jpg" class="d-block w-100" style="object-fit: cover; object-position: center; height: 700px; overflow: hidden;" alt="...">
      <div class="carousel-caption d-none d-md-block" style="top:15rem;">
        <h1 class="fs-1 text-dark fw-bolder text-uppercase">Distributed and Integrated</h1>
        <span class="fs-3 text-dark">TIAMAT allows distributed and integrated FTA. Organizations spread worldwide benefit from this because the FTA may be done broadly and deeply into the organization, minimizing the chances of organizational myopia.</span>
      </div>
    </div>
    <div class="carousel-item">
      <img src="img/theme/adaptable.jpg" class="d-block w-100" style="object-fit: cover; object-position: center; height: 700px; overflow: hidden;" alt="...">
      <div class="carousel-caption d-none d-md-block" style="top:15rem;">
        <h1 class="fs-1 text-light fw-bolder text-uppercase">Adaptable</h1>
        <span class="fs-3 text-light">TIAMAT is easily adaptable to almost any organization because it supports multi-level nested FTA, e. g., an FTA as a step of other FTA. The organization controls in which FTA granularity they are comfortable to work with, and the effort size to achieve the FTA results.</span>
      </div>
    </div>
  </div>
  <button class="carousel-control-prev" type="button" data-bs-target="#carouselHome" data-bs-slide="prev">
    <span class="carousel-control-prev-icon" aria-hidden="true"></span>
    <span class="visually-hidden">Previous</span>
  </button>
  <button class="carousel-control-next" type="button" data-bs-target="#carouselHome" data-bs-slide="next">
    <span class="carousel-control-next-icon" aria-hidden="true"></span>
    <span class="visually-hidden">Next</span>
  </button>
	</div>
   </div>
   
   <div style="height:700px;">
      <div class="row h-100 p-5">
         <div class="d-none d-md-block"></div>
         <div class="col-xxl-3 col-xl-12 align-self-center d-inline">
            <p class="text-center">
               <img src="img/theme/working2050.png" width="auto" height="450px" alt="Technical Report Working in 2050">
            </p>
		</div>
         <div class="col-xxl-6 col-xl-12 align-self-center text-center d-inline p-2">
            <h1 class="fs-1 text-dark fw-bolder text-uppercase">Success Case: COPPE/UFRJ</h1>
            <span class="fs-3 text-dark">TIAMAT has been used as the default methodology and decision-support tool in the Laboratório do Futuro. The technical reports 'Working in 2050' and 'Healthcare 2030' were developed using TIAMAT.</span>
         </div>
		<div class="col-xxl-3 col-xl-12 align-self-center d-inline">
			<p class="text-center">
               <img src="img/theme/healthcare2030.png" width="auto" height="450px" alt="Technical Report Working in 2050">
            </p>
         </div>
      </div>
   </div>
   
 
 	  
	<% 
	render.renderFooter()
	Response.End
	
	%>
	
<% if Session("email") = "" then %>

									<form id="login" action="login.asp" method="post" class="monitor">
									<div style="padding:30px;">
										<b>LOGIN <font color=red>//</font></b><br>
										<hr class="linhaDupla">
										<table width=100% cellpadding=5px cellspacing=5px> 
											<tr> 
												<td align="right" class="label padded" width=35%>E-mail:</td>
												<td align="left" class="padded" width=65%>
													<input type="text" id="username" name="email">
												</td>
											</tr>
											<tr>
												<td align="right" class="label padded">Password:</td>
												<td align="left" class="padded" >
													<input type="password" id="password" name="password">
												</td>
											</tr>
											<tr>
												<td height="70px" valign="middle" align="center" colspan=2 class="padded" >
														<input type="hidden" name="afterLoginGoTo"  value="<%=Session("afterLoginGoTo")%>">
														<input type="submit" value="Login" class="TIAMATButton">
												</td>	
											</tr>
											<tr>
												<td height="60px" valign="middle" align="center" colspan=2 class="padded" >
<% if Session("loginError") <> "" then %>												 
													<font color=red><%=Session("loginError")%></font>
<%elseif SIGNUP_ALLOWED then %>
													<font><a href="#" onclick="showSignup(true);">Sign up</a></font>
<%end if %>													
													<%
													Session("loginError") = ""
													Session("afterLoginGoTo") = ""
													%>
												</td>
											</tr>
										</table>
									</div>
										</form>






									<form id="signup" action="signup.asp" method="post" class="monitor" style="display:none;">
									<div style="padding:30px;">
										<b>SIGN UP <font color=red>//</font></b><br>
										<hr class="linhaDupla">
										<table width=100% cellpadding=0px cellspacing=0px> 
											<tr> 
												<td align="right" class="label padded" width=35%>Name:</td>
												<td align="left" class="padded" width=65%>
													<input type="text" id="su_name" name="su_name" value=""> 
												</td>
											</tr>
											<tr> 
												<td align="right" class="label padded" width=35%>E-mail:</td>
												<td align="left" class="padded" width=65%>
													<input type="text" id="su_username" name="su_email" value=""> 
												</td>
											</tr>
											<tr>
												<td align="right" class="label padded">Password:</td>
												<td align="left" class="padded" >
													<input type="password" id="su_password" name="su_password" value="">
												</td>
											</tr>
											<tr>
												<td align="right" class="label padded">Re-enter Password:</td>
												<td align="left" class="padded" >
													<input type="password" id="su_rpassword" name="su_rpassword" value="">
												</td>
											</tr>
											<tr>
												<td height="70px" valign="middle" align="center" colspan=2 class="padded" >
														<input type="submit" value="Sign Up" class="TIAMATButton"  onclick="return validateSignUp();"">
														<input type="submit" value="Cancel" class="TIAMATButton" onclick="showSignup(false);return false;">
												</td>	
											</tr>
										</table>
									</div>									
										</form>
									
									
<script>
function showSignup(isSignup){
	if (isSignup) {
		$("#login").hide();
		$("#signup")[0].reset();
		$("#signup").show();
	}
	else{
		$("#signup").hide();
		$("#login")[0].reset();
		$("#login").show();
	}
}

function validateSignUp(){
	 var emailReg = /^([\w-\.]+@([\w-]+\.)+[\w-]{2,4})?$/;
	 var email = $('#su_username').val();
	 var pass = $('#su_password').val();
	 var pass2 = $('#su_rpassword').val();
	
	var errors = "";
	
	if(!emailReg.test(email)){
		errors = "Email must be a valid email address.\n";
    }
	
	if (pass.length < 8) {
		errors += "The password must be at least 8 characters long.\n";
	}
	
	if (errors=="" && pass==pass2) {
		return true;
	}
	else {
	if (pass!=pass2) errors = "Password confirmation doesn't match Password."
	alert(errors)
	return false;
	}
	 
}
</script>

									
<%else ' Usuário logado
 %>
	

									<form action="" class="monitor">
									<div style="height:290px;padding:30px;overflow-y:auto;">

	<%
												if Session("Message") <> "" then
												%>
												<table width=100%>
												<tr>
													<td height="60px" valign="middle" align="center" colspan=2 class="padded" >
														<font color=red><%=Session("Message")%></font>
														<%
														Session("Message") = ""
														%>
													</td>
												</tr>
												</table>
												<%
												end if
												%>
												
	
										<b>CONTROL PANEL <font color=red>//</font></b><br>
										<hr class="linhaDupla">
										<table width=100% cellpadding=5px cellspacing=5px> 
											<tr>
												<td>
												
											
												
												
												<%
												
												dim rs
												Dim counter
												
												call getRecordset(SQL_CONSULTA_WORKFLOW_STEPS_BY_OWNER_AND_STATUS(Session("email"), STATE_ACTIVE),rs)
												
												if rs.eof then
													response.write "No FTA is waiting for your action. Access your <a href='/workplace.asp'><b>workplace</b></a> to create a new FTA."
												else
												%>
												<table class="metro" width=100%>
												<th class="metro" colspan=3 style="font-size:100%;padding:7px;">Pending FTA Steps</th>
												<tr>
													<td class="metroTitle" style="width:100px;font-size:90%;padding:5px;">FTA Method</td>
													<td class="metroTitle" style="font-size:90%;padding:5px;">FTA Description</td>
													<td class="metroTitle" style="width:100px;font-size:90%;padding:5px;">Role</td>
												</tr>
												<%
												
												counter = 0
												while not rs.eof

												base_folder = getBaseFolderByFTAmethodID(cstr(rs("type")))

												%>
												<tr>
													<td class="metro<%=cstr(counter)%>" style="font-size:90%;padding:4px;">
														<a href="<%=base_folder%>index.asp?stepID=<%=cstr(rs("stepID"))%>"><%=getFTAMethodNamebyFTAmethodID(cstr(rs("type")))%></a> 
													</td>
													<td class="metro<%=cstr(counter)%>" style="font-size:90%;padding:4px;">
														<a href="<%=base_folder%>index.asp?stepID=<%=cstr(rs("stepID"))%>"><%=rs("description")%></a> 
													</td>
													<td class="metro<%=cstr(counter)%>" style="font-size:90%;padding:4px;">
														<%=rs("role")%>
													</td>
												</tr>
												<%
												counter = (counter+1) mod 2
												rs.movenext
												wend
												%>
												</table>
												<%
												end if
												%>
												</td>
											</tr>							

										</table>
										
									</div>
									</form>

<% end if%>
			

<%
render.renderFooter()
%>
