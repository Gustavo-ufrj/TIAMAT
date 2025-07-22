<!--#include virtual="/system.asp"-->
<!--#include virtual="/checkstep.asp"-->
<!--#include file="INC_BIBLIOMETRICS.inc"-->
<%
saveCurrentURL

'tiamat.addCSS("/js/TIAMATPopup/TIAMATPopup.css")
'tiamat.addJS("/js/TIAMATPopup/TIAMATPopup.js")

render.renderToBody()
%>

	<%
		Dim action 
		
		if isempty(request.querystring("referenceID")) then
			action = "add"
		else
			action = "edit"
		end if
														
		if action="edit" then
			call getRecordSet (SQL_CONSULTA_BIBLIOMETRICS_REFERENCE(request.querystring("referenceID")), rs)

			if not rs.eof then																							
				title=rs("title")
				bib_year=rs("year")
				
				
				call getRecordSet (SQL_CONSULTA_BIBLIOMETRICS_AUTHORS(request.querystring("referenceID")), rsAuthor)
				author = ""
				while not rsAuthor.eof
					author = author + rsAuthor("name")
					rsAuthor.movenext
					if not rsAuthor.eof then
						author = author +  "; "
					end if
				wend
				
				
				call getRecordSet (SQL_CONSULTA_BIBLIOMETRICS_REFERENCE_X_TAG(request.querystring("referenceID")), rsTag)
				if not rsTag.eof then
				subjectID=cstr(rsTag("tagID"))
				end if
				
				
			end if
		end if
		
	
		%>			

<div class="p-3">
	
	<form action="referenceActions.asp?action=save&stepID=<%=request.querystring("stepID")%>" method="POST" enctype="multipart/form-data" class="requires-validation m-0" novalidate>

	   <div class="mb-3">
		<label for="title" class="form-label">Subject</label>
		<div class="d-flex justify-content-end">
			<div class="flex-grow-1">
				<select class="form-control w-70" id="subject" type="text" name="subject" required> 
					<option value="">Select a subject</option>
					<%
					call getRecordset(SQL_CONSULTA_BIBLIOMETRICS_TAGS_LIST_PER_STEP_ID(request.querystring("stepID")),rsTag)
					
					while not rsTag.eof
						if subjectID = cstr(rsTag("tagID")) then
							response.write "<option selected value='"+cstr(rsTag("tagID"))+"'>"+rsTag("tag")+"</option>"
						else
							response.write "<option value='"+cstr(rsTag("tagID"))+"'>"+rsTag("tag")+"</option>"
						end if
						rsTag.movenext
					wend
					%>
				</select>
				<div class="invalid-feedback">Subject must be selected!</div>
			</div>
			<div class="flex-shrink-1 mx-0 px-0 align-middle">
				&nbsp;<button type="button" class="btn btn btn-secondary me-2" data-bs-toggle="modal" data-bs-target="#addSubject"><i class="bi bi-plus-square text-light"></i></button>
			</div>
			<div class="flex-shrink-1 mx-0 px-0 align-middle">
				&nbsp;<button type="button" class="btn btn btn-secondary me-2" onclick="removeTag(document.getElementById('subject').value);return false;"><i class="bi bi-dash-square text-light"></i></button>
			</div>
		</div>
	  </div>

	  
<nav>
  <div class="nav nav-tabs" id="nav-tab" role="tablist">
    <button class="nav-link text-dark active" id="nav-home-tab" data-bs-toggle="tab" data-bs-target="#nav-enter" type="button" role="tab" aria-controls="nav-enter" aria-selected="true">Enter Data</button>
    <button class="nav-link text-dark " id="nav-profile-tab" data-bs-toggle="tab" data-bs-target="#nav-import" type="button" role="tab" aria-controls="nav-import" aria-selected="false">Import from Bibtex</button>
</div>
</nav>
<div class="tab-content" id="nav-tabContent">
	<div class="tab-pane fade show active border border-top-0 p-2 mb-2" id="nav-enter" role="tabpanel" aria-labelledby="nav-enter" style="height:280px;">

	
	  <div class="mb-2">
		<label for="year" class="form-label">Year</label>
		<input type="text" class="form-control" id="year" name="year" maxlength="4" value="<%=bib_year%>" > 
	  </div>

  	   <div class="mb-2">
		<label for="authors" class="form-label">Authors (format Surname, First Name) use ; as separator</label>
		<input type="text" class="form-control"  id="authors" type="text" name="authors"  value="<%=author%>" > 
	  </div>


  	   <div class="mb-2">
		<label for="title" class="form-label">Title</label>
		<input type="text" class="form-control" id="bib_title" name="title" maxlength="500" value="<%=title%>" required> 
		<div class="invalid-feedback">Title cannot be blank!</div>
	  </div>
	  
	
	
	</div>
	<div class="tab-pane fade border border-top-0 p-2 mb-2" id="nav-import" role="tabpanel" aria-labelledby="nav-enter" style="height:280px;">

	   <div class="mb-2">
		<label for="import" class="form-label">Paste Bibtex here</label>
		<textarea class="form-control" type="text" id="import" name="import" onKeyUp="processBibitex(this.value);" onpaste="setTimeout(function() {processBibitex(this.value);}.bind(this), 0);" style="height:200px;"></textarea>
	  </div>
	
	
	</div>
</div>
	  

		  
  	   <div class="mb-2">
		<label for="upFile" class="form-label">File (PDF only)</label>
		<input type="file" name="upFile" accept=".pdf, application/pdf" class="form-control" id="upFile">
	  </div>
  

	  
		<input type=hidden name="referenceID" value="<%=request.querystring("referenceID")%>" />
		<input type=hidden name="stepID" value="<%=request.querystring("stepID")%>" />

 <div class="modal-footer fixed-bottom pb-0 px-0 mx-0 bg-white">
 
 		<button class="btn btn-sm btn-secondary m-1" type="button" onclick="top.location.href = './index.asp?stepID=<%=request.querystring("stepID")%>';return false;">Cancel</button>
		<button class="btn btn-sm btn-danger m-1" type="submit"> <i class="bi bi-save text-light"></i> Save</button>
</div>		
	</form>

</div>


	   <!-- Add subject Modal -->
	<div class="modal fade" id="addSubject" tabindex="-1" aria-labelledby="addSubjectLabel" aria-hidden="true">
	  <div class="modal-dialog modal-dialog-centered">
		<div class="modal-content">
		<form method="POST" action="tagActions.asp?action=save&stepID=<%=request.querystring("stepID")%>" class="requires-validation m-0" novalidate>
		  <div class="modal-header">
			<h5 class="modal-title" id="addSubjectLabel">Add Subject</h5>
			<button type="button" class="btn-close" data-bs-dismiss="modal" aria-label="Close"></button>
		  </div>
		  <div class="modal-body">

	
		   <div class="mb-3">
			<label for="new-subject" class="form-label">Subject</label>
			<input type="text" class="form-control" id="new-subject" name="subject" maxlength="255" value="" required> 
			<div class="invalid-feedback">Subject field cannot be blank!</div>
		  </div>
			  
			<input type=hidden name="referenceID" value="<%=request.querystring("referenceID")%>" />
			<input type=hidden name="stepID" value="<%=request.querystring("stepID")%>" />

		  </div>
		  <div class="modal-footer">
			<button type="button" class="btn btn-sm btn-secondary m-1 text-center" data-bs-dismiss="modal">Close</button>
			<button type="submit" class="btn btn-sm btn-danger m-1 text-center" ><i class="bi bi-save text-light"></i> Save</button>
		  </div> 
		</form>
		</div>
	  </div>
	</div>		

<script>
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
	
	function removeTag(tagID){
		console.log("1");
		var stepID = <%=request.querystring("stepID")%>;
		var referenceID = "<%=request.querystring("referenceID")%>";
		var url ="tagActions.asp?action=delete&stepID="+stepID+"&subjectID=" + tagID; 
		if (referenceID !== "") url = url + "&referenceID=" + referenceID; 
		window.location.href=url;
	}
	
													
</script>

<script>
														
	function processBibitex(bbt){
		bbt = replaceAll(bbt, " = ", "=");
		bbt = replaceAll(bbt, "shorttitle=", "sht=");
		bbt = replaceAll(bbt, "booktitle=", "bkt=");															
		var y = bbt.match(/year={(.*)}/gm);
		var a = bbt.match(/author={(.*)}/gm);
		var t = bbt.match(/title={(.*)}/gm);
		document.getElementById("bib_title").value= removeExtras(t);
		document.getElementById("year").value = removeExtras(y);
		document.getElementById("authors").value = replaceAll(removeExtras(a), " and", ";");
		document.getElementById("import").value = "";
		$('#nav-home-tab').click(); // Muda a aba
	}

	function removeExtras(param){
		var text = param.toString();
		text = text.substring(text.indexOf("{")+1,text.lastIndexOf("}"));
		text = replaceAll(text, "{", "");
		text = replaceAll(text, "}", "");
		text = text.split("\\").join(""); // cannot use "\\" in the regex
		text = replaceAll(text, "'", "");
		text = replaceAll(text, "\"", "");
		text = replaceAll(text, "^", "");
		text = replaceAll(text, "~", "");
		text = replaceAll(text, "´", "");
		text = replaceAll(text, "`", "");
		return text;
	}
	
</script>

<script>
											
function validateForm(){
var message = "";
	if ($("#subject").val()=="0") {
		message = message + "- Please inform a subject.\n";
	}
	if ($.trim($("#bib_title").val())=="") {
		message = message + "- Please inform the title.\n";
	}
	if (message!="") {
		alert("The reference could not be saved due:\n"+message);
	}
	return message=="";
}


</script>

<%
render.renderFromBody()
%>
