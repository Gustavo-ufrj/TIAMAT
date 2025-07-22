<!--#include virtual="/system.asp"-->
<!--#include virtual="/checkstep.asp"-->
<!--#include file="INC_CIA.inc"-->

<%
saveCurrentURL
'tiamat.addCSS("cia.css")

render.renderTitle()

Call getRecordSet(SQL_CONSULTA_CIA(Request.Querystring("stepID")), rs)
dim ciaID , is_qualitative

is_qualitative = "invalid"
ciaID = 0


if not rs.eof then
	ciaID = cstr(rs("ciaID"))
	is_qualitative = rs("tipo")
	Call getRecordSet(SQL_CONSULTA_EVENT(CIAID), rs)
end if

%>





<div class="p-3">


<nav>
  <div class="nav nav-tabs" id="nav-tab" role="tablist">
    <button class="nav-link text-dark active" id="nav-events-tab" data-bs-toggle="tab" data-bs-target="#nav-events" type="button" role="tab" aria-controls="nav-events" aria-selected="true">Events</button>
    <button class="nav-link text-dark " id="nav-cia-tab" data-bs-toggle="tab" data-bs-target="#nav-cia" type="button" role="tab" aria-controls="nav-cia" aria-selected="false">Cross-Impact Analysis</button>
  </div>
</nav>

<div class="tab-content" id="nav-tabContent">
  <div class="tab-pane fade show active" id="nav-events" role="tabpanel" aria-labelledby="nav-events">
 

 
 
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
				<%=cstr(rs("defaultprobability"))%>%
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
			
 
 
 
 
 
 
 
 
  </div>
   <div class="tab-pane fade" id="nav-cia" role="tabpanel" aria-labelledby="nav-cia">
   <div class="p-3">
 
 
 <%
										
call getRecordSet (SQL_CONSULTA_CIA(request.querystring("stepID")), rs)

if not rs.eof then																							
 
call getRecordSet (SQL_CONSULTA_EVENT(CStr(rs("CIAID"))), rsEvent)
i = 1


	Const HIGHLY_INCREASE = 6
	Const INCREASE = 5
	Const NO_IMPACT = 2
	Const DECREASE = 4
	Const HIGHLY_DECREASE = 3
%>
		<% 
			call getRecordSet (SQL_CONSULTA_EVENT(CStr(rs("CIAID"))), rsEvent2)
			dim eventNumber

			eventNumber = rsEvent2.recordcount + 1
		%>

		<table class="w-100 p-2">
			<tr>
				<td /> 
				<td class="border text-center" height="45" colspan="<%=eventNumber%>">
					<b>
						<%
						if rs("tipo") = False then
							response.write("New probability of E<sub style='font-weight: normal;'>x</sub>")
						else
							response.write("Effect")
						end if
						%>
					</b>
				</td>
			</tr>
			<tr class="border text-center">
				<td class="border" rowspan="<%=eventNumber%>" style="height:110px;width:10px;transform: rotate(270deg);white-space: nowrap;">
					<b>
						<%
						if rs("tipo") = False then
							response.write("If E<sub style='font-weight: normal;'>x</sub> occurs")
						else
							response.write("Cause")
						end if
						%>
					</b>
				</td>
				<td class="border bg-light"/>
					<%
					if not rsEvent2.EOF then 
						j = 1
						do
					%>
					<td class="border text-center text-center align-top p-2">
						<a class="fs-6 fw-bolder link-dark text-decoration-none" style="text-indent:0;" title="<%=rsEvent2("event")%>">E<sub><%=j%></sub></a>
					</td>
					<%	
							rsEvent2.MoveNext()
							j = j+1
						loop until rsEvent2.EOF
					End If
					%>
			</tr>
			<% 
			if not rsEvent.EOF then 
				do
			%>
				<tr>
					<td class="border text-center text-center align-top p-2">
						<a class="fs-6 fw-bolder link-dark text-decoration-none" style="text-indent:0;" title="<%=rsEvent("event")%>">E<sub><%=i%></sub></a>
					</td>
					<% 
					j = 1
					call getRecordSet (SQL_CONSULTA_EVENT(CStr(rs("CIAID"))), rsEvent2)
					if not rsEvent2.EOF then 
						do
							if i = j then
								%>	
								<td class="border text-center align-top p-2 bg-light"></td>
								<%	
							else 
								%>
								<td nowrap class="border text-center align-top p-2">
									<%
									call getRecordSet (SQL_CONSULTA_EVENT_X_EVENT(CStr(rsEvent("eventID")), CStr(rsEvent2("eventID")) ), rsProbability)
									dim probability
									
									if rs("tipo") = 0 then	
										if not rsProbability.EOF then
											probability = rsProbability("probability")
										else
											probability = rsEvent2("defaultprobability")
										end if
										probability = replace(probability,",",".")
										
										' if Len(probability) = 1 then
											' probability = probability & ".00"
										' else 
											' if Len(probability) = 3 then
												' probability = probability & "0"
											' end if
										' end if
										probability = probability & "%"
									else
										if not rsProbability.EOF then
											probability = rsProbability("probability")
										else
											probability = "-"
										end if
									end if
									
									%> 
									<a class="fs-6 w-100 h-100 link-dark text-decoration-none <%if not rsProbability.EOF then response.write("fw-bold text-danger") end if%>" style="text-indent:0;" data-bs-toggle="modal" data-bs-target="#manageProbability" data-title="Configure Impact" data-url="causeEffectAction.asp?action=update&stepID=<%=Request.QueryString("stepID")%>" data-cause="<%=rsEvent("event")%>" data-cause-id="<%=rsEvent("eventID")%>" data-effect="<%=rsEvent2("event")%>" data-effect-id="<%=rsEvent2("eventID")%>" data-cprobability="<%=probability%>" role="button">   
										<div class="w-100" style="width:40px; height:16px;">
											<%
											select case probability
												case HIGHLY_INCREASE
													response.write("<img width='15' height='15' src='Images\seta_cima.png'></img><img width='15' height='15' src='Images\seta_cima.png'></img>")
												case INCREASE
													response.write("<img width='15' height='15' src='Images\seta_cima.png'></img>")
												case DECREASE
													response.write("<img width='15' height='15' src='Images\seta_baixo.png'></img>")
												case HIGHLY_DECREASE
													response.write("<img width='15' height='15' src='Images\seta_baixo.png'></img><img width='15' height='15' src='Images\seta_baixo.png'></img>")
												case else
													response.write(probability)
											end select
											%>
										</div>
									</a>
								</td>
								<%
							end if
							rsEvent2.MoveNext()
							j = j + 1
						loop until rsEvent2.EOF
					End If
					%>
				</tr>
			<%	
					rsEvent.MoveNext()
					i = i + 1
				loop until rsEvent.EOF
			End If

			%>
		</table>
<%end if%>		
  </div>
  </div>
  
  
</div>

		
   <div class="p-5">
  </div>
  <nav class="navbar fixed-bottom navbar-light bg-light">
      <div class="container-fluid justify-content-center p-0">
		 
			<%if getStatusStep(request.querystring("stepID")) = STATE_ACTIVE then %>
				<button class="btn btn-sm btn-secondary m-1" type="button" id="configureButton" data-bs-toggle="modal" data-bs-target="#manageEffectModal" data-step-id="<%=request.querystring("stepID")%>" data-title="Configure CIA" data-url="editCIA.asp?stepID=<%=request.queryString("stepID")%>" ><i class="bi bi-gear text-light"></i> Configure</button>
				<button class="btn btn-sm btn-secondary m-1" type="button" data-bs-toggle="modal" data-bs-target="#manageEvents" data-step-id="<%=request.querystring("stepID")%>" data-title="Add Event" data-url="eventActions.asp?action=new"  > <i class="bi bi-plus-square text-light"></i> Add Event</button>
				
	

				<button class="btn btn-sm btn-danger m-1" onclick="window.location.href='/stepsupportInformation.asp?stepID=<%=request.queryString("stepID")%>';"><i class="bi bi-journal-plus text-light"></i> Supporting Information</button>
				<button class="btn btn-sm btn-danger m-1" onclick="if(confirm('This action cannot be undone. Are you sure to end this FTA method now?'))window.location.href='/workflowActions.asp?action=end&stepID=<%=request.queryString("stepID")%>'"><i class="bi bi-check-lg text-light"></i> Finish</button>
			<%end if%>
			
      </div>
  </nav>		
		
</div>



 <!-- Manage Probability -->
<div class="modal fade" id="manageProbability" tabindex="-1" aria-labelledby="probabilityModalLabel" aria-hidden="true">
  <div class="modal-dialog modal-dialog-centered">
	<div class="modal-content">
	<form method="post" action="" autocomplete="off"  id ="formManageProbability" class="requires-validation m-0" novalidate>
	  <div class="modal-header">
		<h5 class="modal-title" id="probabilityModalLabel">xx</h5>
		<button type="button" class="btn-close" data-bs-dismiss="modal" aria-label="Close"></button>
	  </div>
	  <div class="modal-body">

	  <div class=" mb-3">
		<label for="cause" class="form-label">Cause</label>
		<input class="form-control" id="cause" name="cause" readonly>
	  </div>
	 
 	 <div class=" mb-3">
		<label for="effect" class="form-label">Effect</label>
		<input class="form-control" id="effect" name="effect" readonly>
	  </div>
						
	  <%

	  if is_qualitative <> "invalid" then
		if is_qualitative then
	  %>
	
	  <div class=" mb-3">
		<label for="probability" class="form-label">Impact</label>
		<select class="form-control" id="probability" name="probability">
		<%
		response.write("<option value='" & HIGHLY_INCREASE & "'>Highly increase the probability</option>")
		response.write("<option value='" & INCREASE & "'>Increase the probability</option>")
		response.write("<option value='" & NO_IMPACT & "'>No impact</option>")
		response.write("<option value='" & DECREASE & "'>Decrease the probability</option>")
		response.write("<option value='" & HIGHLY_DECREASE & "'>Highly Decrease the probability</option>")
		%>
		</select>
	  </div>
	  
	  <%
		else
	  %>
		<label for="probability" class="form-label">New Probability</label>
		<div class="input-group mb-3">
		<input type='number' min=0 max=100 class='form-control' id='probability' name='probability' required>
		<div class="input-group-append">
			<span class="input-group-text">%</span>
   	    </div>
		<div class="invalid-feedback">Probability should be between 0-100.</div>
	  </div>
	  <%
			end if
		end if
	  %>
	  
	  </div>
	  <div class="modal-footer">
		<input id="causeID" name="causeID" type="hidden">
		<input id="effectID" name="effectID" type="hidden">

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


<!-- Add/Edit Modal -->
<div class="modal fade" id="manageEffectModal" tabindex="-1" aria-labelledby="manageEffectModal" aria-hidden="true">
  <div class="modal-dialog modal-dialog-centered">
    <div class="modal-content">
      <div class="modal-header">
        <h5 class="modal-title" id="effectModal"></h5>
        <button type="button" class="btn-close" data-bs-dismiss="modal" aria-label="Close"></button>
      </div>
      <div class="modal-body p-0">
        <iframe id="iframeEffect" src="" class="w-100" style="height:400px">
		</iframe>
      </div>
     </div>
  </div>
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
	  if is_qualitative <> "invalid" then
		if not is_qualitative then
	  %>
	  <label for="defaultprobability" class="form-label">Initial Probability</label>
		<div class="input-group mb-3">
		<input type='number' min=0 max=100 class='form-control' id='defaultprobability' name='defaultprobability' required>
		<div class="input-group-append">
			<span class="input-group-text">%</span>
   	    </div>
		<div class="invalid-feedback">Probability should be between 0-100.</div>
	  </div>
	  <%
		end if
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

$('#manageProbability').on('show.bs.modal', function(e) {

	var title = $(e.relatedTarget).data('title');

	var cause = $(e.relatedTarget).data('cause');
	var causeID = $(e.relatedTarget).data('causeId');
	var effect = $(e.relatedTarget).data('effect');
	var effectID = $(e.relatedTarget).data('effectId');

	var url = $(e.relatedTarget).data('url');
	var currentProbablility = $(e.relatedTarget).data('cprobability');
	
    $(e.currentTarget).find('#formManageProbability').attr('action', url);
    $(e.currentTarget).find('#probabilityModalLabel').html(title);
    $(e.currentTarget).find('input[name="cause"]').val(cause);
    $(e.currentTarget).find('input[name="causeID"]').val(causeID);
	$(e.currentTarget).find('input[name="effect"]').val(effect);
    $(e.currentTarget).find('input[name="effectID"]').val(effectID);
	

	<%
	 if is_qualitative <> "invalid" then
		if is_qualitative then
	 %>
		if (currentProbablility == "-") currentProbablility = <%=NO_IMPACT%>;
		$('#probability option[value=' + currentProbablility + ']').attr('selected', 'selected');
	 <%else%>    
		$(e.currentTarget).find('input[name="probability"]').val(probability);
	 <%
	 end if
	 end if
	 %>    
});
</script>

<script>
$('#manageEvents').on('show.bs.modal', function(e) {
	
	var title = $(e.relatedTarget).data('title');
	var event = $(e.relatedTarget).data('event');
	var url = $(e.relatedTarget).data('url');
	var eventID = $(e.relatedTarget).data('eventId');
	
    $(e.currentTarget).find('#formManageEvents').attr('action', url);
    $(e.currentTarget).find('#eventModalLabel').html(title);
    $(e.currentTarget).find('textarea[name="event"]').val(event);
	$(e.currentTarget).find('input[name="eventID"]').val(eventID);

	<%
	  if is_qualitative <> "invalid" then
		if not is_qualitative then
	 %>
    var defaultprobability = $(e.relatedTarget).data('defaultprobability');
    $(e.currentTarget).find('input[name="defaultprobability"]').val(defaultprobability);
	  <%
		end if
	  end if
	  %>    
});
</script>	

<script>

$('#manageEffectModal').on('show.bs.modal', function(e) {
	var title = $(e.relatedTarget).data('title');
	var url = $(e.relatedTarget).data('url');
    
	$('#effectModal').html(title);
	$('#iframeEffect').attr('src',url);
});
</script>

<script>
$('#nav-tab').on("shown.bs.tab",function(e){
	localStorage.setItem("cia-idtab", e.target.id);
});


$( document ).ready(function() {
   var id_tab = localStorage.getItem("cia-idtab"); 
   if (id_tab!="") {
	   var triggerEl = document.querySelector("#"+id_tab)
	   triggerEl.click();

<% if is_qualitative = "invalid" then%>	   
		// Click of Configuration button Forcibly
	   triggerEl = document.querySelector("#configureButton")
	   triggerEl.click();	   
<%end if%>	   
	   
	   
   }

   
});
</script>


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
