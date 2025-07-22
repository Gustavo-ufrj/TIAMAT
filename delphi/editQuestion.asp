<!--#include virtual="/system.asp"-->
<!--#include virtual="/checkstep.asp"-->
<!--#include file="INC_DELPHI.inc"-->
<%
saveCurrentURL

tiamat.addJS("/js/tinymce/tinymce.min.js")

render.renderToBody()
%>

	<%
		Dim action, question, options(), optionsIDs(), TypeOfQuestion
		
		TypeOfQuestion = ""
		
		
		if isempty(request.querystring("questionID")) then
			action = "add"
		else
			action = "edit"
		end if
														
		if action="edit" then
			
			call getRecordSet (SQL_CONSULTA_DELPHI_ROUND_QUESTION(request.querystring("questionID")), rs)

			if not rs.eof then																							
				question=rs("question")
				TypeOfQuestion = "open"
				
				ReDim options(-1)
				ReDim optionsIDs(-1)
				
				while not rs.eof
					ReDim Preserve options(UBound(options)+1)
					ReDim Preserve optionsIDs(UBound(optionsIDs)+1)
					
					options(UBound(options)) = rs("optionText")
					optionsIDs(UBound(optionsIDs)) = rs("optionID")
					if cint(rs("optionID")) > -1 then
						TypeOfQuestion = "closed"	
					end	if			
					rs.movenext
				wend
				
				
				
			end if
		end if
		
	
		%>			

<div class="p-3">
	
	<form action="delphiActions.asp?action=<%response.write iif(action = "add", "save", "update")%>_question&stepID=<%=request.querystring("stepID")%>&roundID=<%=request.querystring("roundID")%>" method="POST" class="requires-validation m-0" novalidate>

	   <div class="mb-3">
		<label for="typeQuestion" class="form-label">Type of question</label>
		<select class="form-control w-100" id="typeQuestion" type="text" name="typeQuestion" onChange="changeType(this.value);" required> 
		
		<%if action = "add" then %>
			<option value="">Choose the type of question</option>
		<%end if%>
			
			<option value="open" <%if TypeOfQuestion = "open" then response.write "selected" end if%> >Open-ended</option>
			<option value="closed" <%if TypeOfQuestion = "closed" then response.write "selected" end if%> >Closed-ended</option>
		</select>
		<div class="invalid-feedback">Type of question must be selected!</div>
	  </div>
  
	  <div class="mb-2">
		<label for="question" class="form-label">Question</label>
		<textarea id="question" name="question"  class="form-control w-100"><%=question%></textarea>
	  </div>
	  
	  <div id="optionContainer">
		  <% 
		  if TypeOfQuestion = "closed" then
			
			' Close-ended
			For i = lbound(options) To ubound(options) 
		  %>
		  
		  <div class="mb-2">
			<label for="option<%=cstr(i+1)%>" class="form-label">Option #<%=cstr(i+1)%></label>
			<input type="text" class="form-control" id="option<%=cstr(i+1)%>" name="option[]" value="<%=options(i)%>" > 
			<input type=hidden name="optionID[]" value="<%=cstr(optionsIDs(i))%>" />
		  </div>

		  <% 
		  Next
		  end if
		  %>
	  </div>
	  
	  
	<div class="p-4">
	</div>				  

		<input type=hidden name="questionID" value="<%=request.querystring("questionID")%>" />
		<input type=hidden name="roundID" value="<%=request.querystring("roundID")%>" />
		<input type=hidden name="stepID" value="<%=request.querystring("stepID")%>" />


 <div class="modal-footer fixed-bottom pb-0 px-0 mx-0 bg-white">
 
 		<button class="btn btn-sm btn-secondary m-1" type="button" id="buttonMoreOptions" onclick="addOptions();return false;"> <i class="bi bi-plus-square text-light"></i> Add More Options</button>

 		<button class="btn btn-sm btn-secondary m-1" type="button" onclick="top.location.href = './manageQuestions.asp?stepID=<%=request.querystring("stepID")%>&roundID=<%=request.querystring("roundID")%>';return false;">Cancel</button>
		<button class="btn btn-sm btn-danger m-1" type="submit" onclick="validateForm();"> <i class="bi bi-save text-light"></i> Save</button>
</div>		
	</form>

</div>


 <script>
  tinymce.init({
	selector: '#question',
	height: 300,
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
				

<script>


function changeType(type){
 if (type === "closed") {
	$("#optionContainer").show();
	$("#buttonMoreOptions").show();
	if ($("#option1").length === 0) {
		for(i=1;i<6;i++) {
			addOption(i);			
		}
	}
 }
 else {
	$("#optionContainer").hide();
	$("#buttonMoreOptions").hide();
 }

}

changeType($("#typeQuestion").val());

function addOptions(){
	var numOptions = document.getElementById("optionContainer").children.length;

	for(i=numOptions+1;i<numOptions + 6;i++) {
		addOption(i);
	}
}


function addOption(i) {
	var externalDiv = document.createElement('div');
	externalDiv.classList.add('mb-2');

	var label = document.createElement('label');
	label.for = "option" + i;
	label.textContent = "Option #" + i;
	label.classList.add('form-label');

	var input = document.createElement('input');
	input.type = "text"
	input.id = "option" + i;
	input.name = "option[]";
	input.value = "";
	input.classList.add('form-control');

	var inputHidden = document.createElement('input');
	inputHidden.type = "hidden"
	inputHidden.name = "optionID[]";
	inputHidden.value = "";
	
	externalDiv.appendChild(label);
	externalDiv.appendChild(input);
	externalDiv.appendChild(inputHidden);

	$("#optionContainer").append(externalDiv);
}



(function () {
'use strict'
const forms = document.querySelectorAll('.requires-validation')
Array.from(forms)
  .forEach(function (form) {
    form.addEventListener('submit', function (event) {
    if (!form.checkValidity()) {
        event.preventDefault()
        event.stopPropagation()
    }
  
      form.classList.add('was-validated')
    }, false)
  })
})()
</script>


<script>
											
function validateForm(){
	 if ($("#typeQuestion").val() === "open") {

	 var nodeList = document.querySelectorAll('[id^="option"]');
	 nodeList.forEach(node=> {  node.value="";  });
	}

	return true;
 }


</script>

<%
render.renderFromBody()
%>
