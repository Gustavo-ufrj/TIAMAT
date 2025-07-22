<!--#include virtual="/system.asp"-->
<!--#include virtual="/checkstep.asp"-->
<!--#include file="INC_SCENARIO.inc"-->
<%
saveCurrentURL

tiamat.addJS("/js/tinymce/tinymce.min.js")

render.renderToBody()
%>

<!-- INICIO AREA EDITAVEL -->
<%
	disabled = ""
	
	if getStatusStep(request.querystring("stepID")) = STATE_ACTIVE then 
		if isempty(request.querystring("scenarioID")) then
			action = "add"
		else
			action = "edit"
		end if
	else 
		disabled = "disabled"
		action = ""
	end if													
%>

	<%
	Dim name,description,scenario
		name=""
		description=""
		scenario=""
	
	if (not isempty(request.querystring("stepID")) ) and (not isempty(request.querystring("scenarioID"))) then
	
		call getRecordSet (SQL_CONSULTA_SCENARIOS_BY_SCENARIO_ID(request.querystring("scenarioID")), rs)
		
		if not rs.eof then																							
			name=rs("name")
			description=rs("description")
			scenario=rs("scenario")
		end if
	end if
	%>
												
<div class="p-3">
<form action="scenarioActions.asp?action=save" method="POST" novalidate>

	<div class="mb-2">
		<label for="name" class="form-label">Name</label>
		<input type="text" class="form-control"  id="name" type="text" name="name"  value="<%=name%>" <%=disabled%> class="requires-validation m-0" required> 
		<div class="invalid-feedback">Name cannot be blank!</div>
	</div>  
  
	<div class="mb-2">
		<label for="scenario" class="form-label">Scenario</label>
		<textarea id="scenario" name="scenario" class="form-control w-100"><%=scenario%></textarea>
	</div>

	
		<input type=hidden name="scenarioID" value="<%=request.querystring("scenarioID")%>" />
		<input type=hidden name="stepID" value="<%=request.querystring("stepID")%>" />

	<div class="modal-footer fixed-bottom pb-0 px-0 mx-0 bg-white">
		<% if getStatusStep(request.querystring("stepID")) = STATE_ACTIVE then %>
		<button class="btn btn-sm btn-secondary m-1" type="button"  onclick="top.location.href = './index.asp?stepID=<%=request.querystring("stepID")%>';return false;">Cancel</button>
		<button class="btn btn-sm btn-danger m-1" type="submit"> <i class="bi bi-save text-light"></i> Save</button>
		<%else%>
		<button class="btn btn-sm btn-secondary m-1" type="button" onclick="top.location.href = './index.asp?stepID=<%=request.querystring("stepID")%>';return false;">Back</button>
		<%end if%>
		</div>		
</form>

																	
											
											

<script>

function validateForm(){
var message = "";
	if ($("#name").val()=="") {
		message = message + "- Please inform the scenario name.\n";
	}
	if ($.trim($("#description").val())=="") {
		message = message + "- Please inform the scenario description.\n";
	}
	if (message!="") {
		alert("The scenario could not be saved due:\n"+message);
	}
	return message=="";
}

</script>
							
 <script>
  tinymce.init({
	selector: '#scenario',
	height: 340,
	menubar: false,
	<% if getStatusStep(request.querystring("stepID")) <> STATE_ACTIVE then %>
	readonly : 1,
	<%end if%>
	plugins: [
		'advlist autolink lists link image charmap print preview anchor',
		'searchreplace visualblocks code fullscreen',
		'table table contextmenu paste code'
	],
	toolbar: 'undo redo | insert | styleselect formatselect fontselect fontsizeselect bold italic | alignleft aligncenter alignright alignjustify |  numlist bullist | table link image',
	paste_data_images: true
  });
  </script>
							
<%
render.renderFromBody()
%>
