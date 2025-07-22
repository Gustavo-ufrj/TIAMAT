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


render.renderToBody()
%>

		
	
<form action="stepActions.asp?action=generate_link" method="post" autocomplete="off">	
<div class="py-0 px-2">
	<p>The invitation code is used to generate the invitation link. You <b>can</b> reuse the code to invite users to multiple methods with a single link.</p>
		<div class="mb-3">
			<label for="code" class="form-label">Please define a Invitation Code</label>
			<input type="text" class="form-control w-100" id="code" name="code" required> 
			<div class="invalid-feedback">The Invitation Code cannot be blank!</div>
	  </div>
</div>		

	<input type="hidden" name="workflowID" value="<%=request.querystring("workflowID")%>">
	<input type="hidden" name="stepID" value="<%=request.querystring("stepID")%>">
	<input type="hidden" name="role" value="<%=request.querystring("role")%>">
	<div class="modal-footer fixed-bottom pb-0 px-0 mx-0">
		
			<button class="btn btn-sm btn-secondary m-1" onclick="top.location.href='/manageWorkflow.asp?workflowID=<%=request.querystring("workflowID")%>';"> Close</button>
			<button class="btn btn-sm btn-danger m-1" type="submit" value="Save"  onclick="return validateForm();"> <i class="bi bi-save text-light"></i> Save</button>
	</div>
  
</form>		
		
		<script>
		
		$( document ).ready(function() {
			$('#code').val(generateCode(8));
		});
		
		
			function validateForm(){	
			var message = "";
				if ($.trim($("#code").val())=="") {
					message = message + "Please inform a invitation code.";
				}
				if (message!="") {
					alert(message);
				}
				return message=="";
			}
											
		</script>


<%
render.renderFromBody()
%>
							