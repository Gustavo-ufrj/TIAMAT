<!--#include virtual="/system.asp"-->
<!--#include virtual="/checklogin.asp"-->


<%
render.renderTitle()

		dim rs
		dim code
		dim validation
		
		code = request.querystring("code")
		verification = request.querystring("verification")
		
		call getRecordset(SQL_CONSULTA_WORKFLOW_STEP_INVITATION_VALIDATION(code, verification),rs)

%>


<div class="p-3">

<%

	if rs.eof then
		response.write "<div class='py-3'><div class='alert alert-danger'> The informed link is invalid, or has the mismatching code and verification.</div></div>"
	else
%>
<h3>Project Invitation</h3>
	<p>You have been invited to join the FTA study "<%=rs("description")%>":</p>
	<div class='py-1'>
		<div class='alert alert-secondary'><%=rs("goal")%></div>
	</div>
	<p>Upon confirming this invitation, you will able to perform the methods and roles listed below:</p>
<table class="table table-striped table-hover">
  <thead class="table-dark">
	<tr>
		<td>Method</td>
		<td>Role</td>
	</tr>
  </thead>
  <tbody>

<%
			while not rs.eof
			%>
			<tr>
				
				<td>
					<%=getFTAMethodNamebyFTAmethodID(cstr(rs("type")))%>
				</td>
				<td>
					<%=(rs("role"))%>
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
		<button class="btn btn-sm btn-secondary m-1" onclick="window.location.href='workplace.asp';">Cancel</button>
		<button class="btn btn-sm btn-danger m-1" onclick="window.location.href='stepActions.asp?action=join&code=<%=code%>&verification=<%=verification%>';" ><i class="bi bi-check-lg text-light"></i> Join the FTA study</button>
			
      </div>
    </nav>									

</div>			

<%
render.renderFooter()
%>
