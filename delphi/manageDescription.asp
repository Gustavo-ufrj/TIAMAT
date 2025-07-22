<!--#include virtual="/system.asp"-->
<!--#include virtual="/checkstep.asp"-->
<!--#include file="INC_DELPHI.inc"-->
<%
saveCurrentURL

tiamat.addJS("/js/tinymce/tinymce.min.js")

render.renderToBody()
%>

<!-- INICIO AREA EDITAVEL -->
<%
	disabled = ""
	
	if getStatusStep(request.querystring("stepID")) = STATE_ACTIVE then 
			action = "edit"
	else 
		disabled = "disabled"
		action = ""
	end if													
%>

	<%
	Dim description
		description=""
	
	if not isempty(request.querystring("stepID"))  then
	
		call getRecordSet (SQL_CONSULTA_DELPHI(request.querystring("stepID")), rs)
		
		if not rs.eof then																							
			description=rs("text")
		end if
	end if
	%>
												
<div class="p-3">
<form action="delphiActions.asp?action=save" method="POST" novalidate>

	<div class="mb-2">
		<label for="description" class="form-label">Delphi Description</label>
		<textarea id="description" name="description" class="form-control w-100"><%=description%></textarea>
	</div>

	
	<!--	<input type=hidden name="scenarioID" value="<%=request.querystring("scenarioID")%>" /> -->
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
	if ($.trim($("#description").val())=="") {
		message = message + "- Please inform the description.\n";
	}
	if (message!="") {
		alert("The scenario could not be saved due:\n"+message);
	}
	return message=="";
}

</script>
							
 <script>
  tinymce.init({
	selector: '#description',
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
