<!--#include virtual="/system.asp"-->
<!--#include virtual="/checklogin.asp"-->
<!--#include file="INC_CIA.inc"-->
<%
saveCurrentURL
Call getRecordSet(SQL_CONSULTA_CIA(Request.Querystring("stepID")), rs)
dim ciaID 

ciaID = cstr(rs("ciaID"))

is_qualitative = rs("tipo")

Call getRecordSet(SQL_CONSULTA_EVENT(CIAID), rs)

render.renderTitle()
%>


<div class="p-3">
<%

	if rs.eof then
		response.write "<div class='py-3'><div class='alert alert-danger'> No Event was found.</div></div>"
	else
%>
<table class="table table-striped table-hover">
  <thead class="table-dark">
	<tr>
		<td>ID</td>
		<td class="w-100">Event</td>
	  <%if not is_qualitative then%>
		<td>Probability</td>
	  <%End if%>				

		<td>Actions</td>
	</tr>
  </thead>
  <tbody>
  
<%
			dim counter 
			counter = 0
			while not rs.eof
			counter = counter +1
			%>
			<tr>
			
				<td>														
					E<sub><%=cstr(counter)%></sub>
				</td>		
				
				<td>														
				<%=rs("event")%>
				</td>		

			  <%if not is_qualitative then%>
				<td class="text-center">														
				<%=cstr(rs("defaultprobability")*100)%>%
				</td>						
			  <%End if%>				
				
				<td class="text-center">
					<%if getStatusStep(request.querystring("stepID")) = STATE_ACTIVE then %>
					<a href="#" data-bs-toggle="modal" data-bs-target="#manageEvents" data-step-id="<%=request.querystring("stepID")%>" data-event-id="<%=rs("eventID")%>"  data-event="<%=rs("event")%>" data-defaultprobability="<%=rs("defaultprobability")%>"  data-title="Edit Event" data-url="eventActions.asp?action=update"><img src="/img/edit.png"  height=20 width=auto></a>
					<a href="eventActions.asp?action=delete&stepID=<%=request.querystring("stepID")%>&ciaID=<%=cstr(rs("ciaID"))%>&eventID=<%=cstr(rs("eventID"))%>" title="Delete"  onclick="if (!confirm('Are you sure?')) { return false; }"><img src="/img/delete.png"  height=20 width=auto></a>
					<%end if%>
				</td>
			
			</tr>
			<%
			rs.movenext
			wend
			%>
										
  </tbody>
</table>				
			<% End if
			%>	
			
			
										
  <div class="p-3">
  </div>
  <nav class="navbar fixed-bottom navbar-light bg-light">
         <div class="container-fluid justify-content-center p-0">

		<button class="btn btn-sm btn-secondary m-1" type="button" onClick="top.location.href='index.asp?stepID=<%=request.queryString("stepID")%>'"> Back</button>
				
		 <%if getStatusStep(request.querystring("stepID")) = STATE_ACTIVE then %>
			<button class="btn btn-sm btn-secondary m-1" type="button" data-bs-toggle="modal" data-bs-target="#manageEvents" data-step-id="<%=request.querystring("stepID")%>" data-title="Add Event" data-url="eventActions.asp?action=new"  > <i class="bi bi-plus-square text-light"></i> Add Event</button>
		<%end if%>
			
			
         </div>
      </nav>					
</div>
				
				
				
			

 <!-- Manage Event -->
<div class="modal fade" id="manageEvents" tabindex="-1" aria-labelledby="eventModalLabel" aria-hidden="true">
  <div class="modal-dialog modal-dialog-centered">
	<div class="modal-content">
	<form method="post" action="" autocomplete="off"  id ="formManageEvents" class="requires-validation m-0" novalidate>
	  <div class="modal-header">
		<h5 class="modal-title" id="eventModalLabel">xx</h5>
		<button type="button" class="btn-close" data-bs-dismiss="modal" aria-label="Close"></button>
	  </div>
	  <div class="modal-body">

	  <div class=" mb-3">
		<label for="event" class="form-label">Event</label>
		<textarea class="form-control" id="event" rows="3" name="event" required></textarea>
		<div class="invalid-feedback">Event cannot be blank!</div>
	  </div>
	  
	  <%
	  if not is_qualitative then
	  %>
	   <div class="mb-3">
		<label for="defaultprobability" class="form-label">Initial Probability</label>
		<input type="text" class="form-control" id="defaultprobability" name="defaultprobability" size="4" required> 
		<div class="invalid-feedback">Probability cannot be blank!</div>
	  </div>
	  <%
		end if
	  %>
	  
	  </div>
	  <div class="modal-footer">
		<input type="hidden" name="eventID">		
		<input type="hidden" name="ciaID" value="<%=ciaID%>"> 
		<input type="hidden" name="stepID" value="<%=request.queryString("stepID")%>"> 
		<button type="button" class="btn btn-sm btn-secondary m-1 text-center" data-bs-dismiss="modal">Close</button>
		<button type="submit" class="btn btn-sm btn-danger m-1 text-center" ><i class="bi bi-save text-light"></i> Save</button>
	  </div> 
	</form>
	</div>
  </div>
</div>		
	
<script>
$('#manageEvents').on('show.bs.modal', function(e) {
	
	var title = $(e.relatedTarget).data('title');
	var eventx = $(e.relatedTarget).data('event');
	var url = $(e.relatedTarget).data('url');
	var eventID = $(e.relatedTarget).data('eventId');
	console.log(eventx);
	
    $(e.currentTarget).find('#formManageEvents').attr('action', url);
    $(e.currentTarget).find('#eventModalLabel').html(title);
    $(e.currentTarget).find('textarea[name="event"]').val(eventx);
	$(e.currentTarget).find('input[name="eventID"]').val(eventID);
		console.log("c");


	<%
	  if not is_qualitative then
	 %>
    var defaultprobability = $(e.relatedTarget).data('defaultprobability');
    $(e.currentTarget).find('input[name="defaultprobability"]').val(defaultprobability);
	  <%
		end if
	  %>    
});
</script>
    				
				
				

<script>
/*
function maskProb(){
	$(defaultprobability).inputmask({
		mask: ["0.9[9]","1.00"]
    });
}

function validaProb(event)
{
	var prob = document.getElementById("defaultprobability");
	
	//Funcionar no chrome
	if( (event.keyCode == 8) && (prob.value.substr(0,3) == "0._")){
		prob.value = "";
	};
	
	//Funcionar no firefox
	if((event.keyCode == 8) && (prob.value.length == 0)){
		prob.value = "";
	};
}
*/
</script>

<%
render.renderFooter()
%>