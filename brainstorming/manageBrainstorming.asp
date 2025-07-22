<!--#include virtual="/system.asp"-->
<!--#include virtual="/checkstep.asp"-->
<!--#include file="INC_BRAINSTORMING.inc"-->
<%
saveCurrentURL

render.renderTitle()


	validation = "required"
	
	if not getStatusStep(request.querystring("stepID")) = STATE_ACTIVE then 
		validation = "disabled"
	end if													
				
	Dim description,votingPoints
		description=""
		votingPoints=0
		
	Dim showCancel
	showCancel = true
	if not isempty(request.querystring("stepID")) then
															

		call getRecordSet (SQL_CONSULTA_BRAINSTORMING(request.querystring("stepID")), rs)
		
		if not rs.eof then																							
			description=rs("description")
			votingPoints=rs("votingPoints")
			else
			showCancel = false
		end if
	end if

				
%>
<div class="p-3">
	<form action="brainstormingActions.asp?action=save" method="POST" class="requires-validation m-0" novalidate>

	<p>Brainstorming requires defining a number of Voting Points in order to implement multi-voting system to rank the ideas/events proposed.</p>
	<p>Please select the number of Voting Points available for each participant of this Brainstorming.</p>
	   <div class="mb-3">
		<label for="votingPoints" class="form-label">Voting Points</label>
		<input id="votingPoints" type="number" min="0" name="votingPoints" maxlength="2" class="form-control" value="<%=votingPoints%>" <%=validation%>> 
		<div class="invalid-feedback">Voting Points must be at least 0.</div>
	  </div>

		<input type=hidden name="brainstormingID" value="<%=request.querystring("brainstormingID")%>" />
		<input type=hidden name="stepID" value="<%=request.querystring("stepID")%>" />
		<input id="description" type="hidden" name="description" value="<%=description%>"> 
	

	<div class="p-3">
	</div>

	<nav class="navbar fixed-bottom navbar-light bg-light">
         <div class="container-fluid justify-content-center p-0">

		 
		 
		 <% if getStatusStep(request.querystring("stepID")) = STATE_ACTIVE then %>
			<% if showCancel then %>
				<button class="btn btn-sm btn-secondary m-1" type="button" onclick="window.location.href = './index.asp?stepID=<%=request.querystring("stepID")%>';return false;">Cancel</button>
			<%end if%>
			<button class="btn btn-sm btn-danger m-1" type="submmit" ><i class="bi bi bi-save text-light"></i> Save</button>
		<%else%>
			<button class="btn btn-sm btn-secondary m-1" type="button" onclick="window.location.href = './index.asp?stepID=<%=request.querystring("stepID")%>';return false;">Back</button>
		<%end if%>
		 
         </div>
    </nav>							
	</form>
</div>

	
<script>

  // Fetch all the forms we want to apply custom Bootstrap validation styles to
  var forms = document.querySelectorAll('.requires-validation');

  // Loop over them and prevent submission
  Array.prototype.slice.call(forms)
    .forEach(function (form) {
      form.addEventListener('submit', function (event) {
        if (!form.checkValidity()) {
          event.preventDefault()
          event.stopPropagation()
        }

        form.classList.add('was-validated')
      }, false)
    });


</script>


<%
render.renderFooter()
%>
