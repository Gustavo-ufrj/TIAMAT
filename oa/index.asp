<!--#include virtual="/system.asp"-->
<!--#include virtual="/checkstep.asp"-->
<!--#include file="INC_OA.inc"-->

<%saveCurrentURL
													
call getRecordSet (SQL_CONSULTA_OA(request.querystring("stepID")), rs)
												
if rs.eof then
	response.redirect "editOA.asp?stepID="+request.querystring("stepID")
	response.end
end if

render.renderTitle()

%>



<%

function ConvertImpact(impact)
ImpactList = Array("++","+","=","-","--","?")
ConvertImpact = ImpactList(impact-1)
end function

	Const HIGHLY_POSITIVE = 1
	Const POSITIVE = 2
	Const NO_IMPACT = 3
	Const NEGATIVE = 4
	Const HIGHLY_NEGATIVE = 5
	Const UNKNWOWN = 6
		
	function getImpactStr(impact)
		select case impact
			case HIGHLY_POSITIVE: getImpactStr="Large positive impact compared to the status quo" 
			case POSITIVE: getImpactStr="Small positive impact compared to the status quo" 
			case NO_IMPACT: getImpactStr="No impact compared to the status quo" 
			case NEGATIVE: getImpactStr="Small negative impact compared to the status quo" 
			case HIGHLY_NEGATIVE: getImpactStr="Large negative impact compared to the status quo" 
			case UNKNWOWN: getImpactStr="No evidentiary basis for evaluating the effect" 
			case else: getImpactStr="Invalid Impact" 
		end select
	end function
	
Dim rsOptions, rsCriteria, rsEffect, oaID

oaID = cstr(rs("OAID"))

 call getRecordSet(SQL_CONSULTA_EFFECT(cstr(rs("OAID"))),rsEffect)
  
 call getRecordSet(SQL_CONSULTA_OPTION(cstr(rs("OAID"))),rsOptions)


%>




<div class="p-3">


<nav>
  <div class="nav nav-tabs" id="nav-tab" role="tablist">
    <button class="nav-link text-dark active" id="nav-effects-tab" data-bs-toggle="tab" data-bs-target="#nav-effects" type="button" role="tab" aria-controls="nav-effects" aria-selected="true">Effects</button>
    <button class="nav-link text-dark" id="nav-options-tab" data-bs-toggle="tab" data-bs-target="#nav-options" type="button" role="tab" aria-controls="nav-options" aria-selected="false">Options</button>
    <button class="nav-link text-dark" id="nav-impacts-tab" data-bs-toggle="tab" data-bs-target="#nav-impacts" type="button" role="tab" aria-controls="nav-impacts" aria-selected="false">Impacts</button>
    <button class="nav-link text-dark " id="nav-oa-tab" data-bs-toggle="tab" data-bs-target="#nav-oa" type="button" role="tab" aria-controls="nav-oa" aria-selected="false">Option Analysis</button>
  </div>
</nav>

<div class="tab-content" id="nav-tabContent">
  <div class="tab-pane fade show active" id="nav-effects" role="tabpanel" aria-labelledby="nav-effects">
  
  
  
  
 
 <%

	if rsEffect.eof then
		response.write "<div class='py-3'><div class='alert alert-danger'> No Effect was found.</div></div>"
	else		
%>
<table class="table table-striped table-hover">
  <thead class="table-dark">
	<tr>
		<td class="w-25">Desired Effect</td>
		<td class="w-auto">Nature</td>
		<td class="w-75">Status Quo</td>
		<td>Actions</td>
	</tr>
  </thead>
  <tbody>
  
<%

			
			while not rsEffect.eof

			call getRecordSet(SQL_CONSULTA_CRITERIA(cstr(rsEffect("effectID"))),rsCriteria)
			while not rsCriteria.eof

			%>
			<tr>
			
				<td>														
					<%=rsEffect("DesiredEffect")%>
				</td>		
				
				<td>														
					<%=rsCriteria("NatureOfEffect")%>
				</td>		

			
				<td>														
					<%=rsCriteria("StatusQuo")%>
				</td>						
			
				
				<td class="text-center">
					<%if getStatusStep(request.querystring("stepID")) = STATE_ACTIVE then %>
					<a href="#" data-bs-toggle="modal" data-bs-target="#manageEffects" data-step-id="<%=request.querystring("stepID")%>" data-criteria-id="<%=rsCriteria("criteriaID")%>"  data-effect-id="<%=rsEffect("effectID")%>" data-effect="<%=rsEffect("DesiredEffect")%>" data-nature="<%=rsCriteria("NatureOfEffect")%>" data-status-quo="<%=rsCriteria("StatusQuo")%>" data-title="Edit Effect" data-url="criteriaActions.asp?action=update"><img src="/img/edit.png"  height=20 width=auto></a>
					<a href="criteriaActions.asp?action=delete&stepID=<%=request.querystring("stepID")%>&oaID=<%=cstr(rsEffect("oaID"))%>&criteriaID=<%=cstr(rsCriteria("criteriaID"))%>" title="Delete"  onclick="if (!confirm('Are you sure?')) { return false; }"><img src="/img/delete.png"  height=20 width=auto></a>
					<%end if%>
				</td>
			
			</tr>
			<%
				rsCriteria.movenext
				wend
			rsEffect.movenext
			wend
			%>
										
  </tbody>
</table>				
			<% End if
			%>	
			
  
 
  </div>
  
  
  <div class="tab-pane fade" id="nav-options" role="tabpanel" aria-labelledby="nav-options">

  
 
 <%

	if rsOptions.eof then
		response.write "<div class='py-3'><div class='alert alert-danger'> No Option was found.</div></div>"
	else		
%>
<table class="table table-striped table-hover">
  <thead class="table-dark">
	<tr>
		<td class="w-25">Option</td>
		<td class="w-75">Description</td>
		<td>Actions</td>
	</tr>
  </thead>
  <tbody>
    
<%

			
			while not rsOptions.eof

			%>
			<tr>
			
				<td>														
					<%=rsOptions("Name")%>
				</td>		
				
				<td>														
					<%=rsOptions("Description")%>
				</td>		

			
			
				
				<td class="text-center">
					<%if getStatusStep(request.querystring("stepID")) = STATE_ACTIVE then %>
					<a href="#" data-bs-toggle="modal" data-bs-target="#manageOptions" data-step-id="<%=request.querystring("stepID")%>" data-option-id="<%=rsOptions("optionID")%>"  data-option="<%=rsOptions("Name")%>" data-description="<%=rsOptions("Description")%>" data-title="Edit Option" data-url="optionActions.asp?action=update"><img src="/img/edit.png"  height=20 width=auto></a>
					<a href="optionActions.asp?action=delete&stepID=<%=request.querystring("stepID")%>&oaID=<%=cstr(rsOptions("oaID"))%>&optionID=<%=cstr(rsOptions("optionID"))%>" title="Delete"  onclick="if (!confirm('Are you sure?')) { return false; }"><img src="/img/delete.png"  height=20 width=auto></a>
					<%end if%>
				</td>
			
			</tr>
			<%
				rsOptions.movenext
			wend
			%>
										
  </tbody>
</table>				
			<% End if
			%>	
			
  
  
  
  
  </div>
  
  
  
  
  
  
  
  <div class="tab-pane fade" id="nav-impacts" role="tabpanel" aria-labelledby="nav-impacts">

  
 
 <%
	call getRecordSet(SQL_CONSULTA_IMPACT(cstr(rs("OAID"))),rsImpatcs)

	if rsImpatcs.eof then
		response.write "<div class='py-3'><div class='alert alert-danger'> No Impact was found.</div></div>"
	else		
%>
<table class="table table-striped table-hover">
  <thead class="table-dark">
	<tr>
		<td class="w-25">Effect</td>
		<td class="w-25">Option</td>
		<td class="w-25">Expectation</td>
		<td class="w-25">Impact</td>
		<td>Actions</td>
	</tr>
  </thead>
  <tbody>
    
<%

			
			while not rsImpatcs.eof

			%>
			<tr>
			
				<td>														
					<%=rsImpatcs("DesiredEffect")%> - <%=rsImpatcs("NatureOfEffect")%>
				</td>		
				
				<td>														
					<%=rsImpatcs("name")%>
				</td>		

				<td>														
					<%=rsImpatcs("effect")%>
				</td>		
				
				<td>														
					<%=getImpactStr(rsImpatcs("impact"))%>
				</td>		
				
			
				
				<td class="text-center">
					<%if getStatusStep(request.querystring("stepID")) = STATE_ACTIVE then %>
					<a href="#" data-bs-toggle="modal" data-bs-target="#manageImpacts" data-step-id="<%=request.querystring("stepID")%>" data-criteria-id="<%=rsImpatcs("criteriaID")%>"  data-option-id="<%=rsImpatcs("optionID")%>"  data-option="<%=rsImpatcs("Name")%>" data-effect="<%=rsImpatcs("effect")%>" data-impact="<%=rsImpatcs("impact")%>" data-title="Estimate Impact" data-url="impactActions.asp?action=update"><img src="/img/edit.png"  height=20 width=auto></a>
					<a href="impactActions.asp?action=delete&stepID=<%=request.querystring("stepID")%>&deleteKey=<%=cstr(rsImpatcs("deleteKey"))%>" title="Delete"  onclick="if (!confirm('Are you sure?')) { return false; }"><img src="/img/delete.png"  height=20 width=auto></a>
					<%end if%>
				</td>
			
			</tr>
			<%
				rsImpatcs.movenext
			wend
			%>
										
  </tbody>
</table>				
			<% End if
			%>	
			
  
  
  
  
  </div>
  
  
  
  
  
  
  
  <div class="tab-pane fade" id="nav-oa" role="tabpanel" aria-labelledby="nav-oa">
   <div class="p-3">
 
 <%
 rsEffect.MoveFirst
 
 if rsOptions.recordCount > 0 then
	rsOptions.MoveFirst
end if 
 
 Dim larguraTabela

 larguraTabela = rsOptions.recordCount * 2 + 3
 
 %>
 
 
 <table width=100% class="padded">
	<tr>
		<td>
			
			
			<table style="border: solid 1px black;" width=100%>
				<tr style="border: solid 1px black;">
					<td align=right><b>Benefit: &nbsp;</b></td>	
					<td colspan=<%=larguraTabela-1%>><%=rs("benefit")%></td>
				</tr>
				
				<tr style="border: solid 1px black;">
					<td style="border: solid 1px black;text-align:center;">Effect</td>
					<td style="border: solid 1px black;text-align:center;">Nature of Effect</td>
					
					<% 
					dim i
					i=1
					while not rsOptions.eof 
					%>
					<td colspan=2 style="border: solid 1px black;text-align:center;">
						Option <%=cstr(i)%><br><%=rsOptions("Name")%>
					</td>
					<% 
						i=i+1
						rsOptions.movenext
						Wend
						on error resume next
						rsOptions.MoveFirst
						on error goto 0
					%>

					<td style="border: solid 1px black;text-align:center;">Status Quo</td>																		
				</tr>
				
				
				<%
				
				while not rsEffect.eof
				
					call getRecordSet(SQL_CONSULTA_CRITERIA(cstr(rsEffect("effectID"))),rsCriteria)
					if not rsCriteria.eof then
				%>
				<tr>
					<td rowspan=<%=rsCriteria.RecordCount%> style="border: solid 1px black;text-align:center;"><%=rsEffect("desiredeffect")%></td>
					
																								
						<%
						while not rsCriteria.eof 
						%>
						<% if rsCriteria.AbsolutePosition > 1 then%> <tr> <%end if%> 
						
							<td style="border: solid 1px black;text-align:center;">
							<%=rsCriteria("natureofeffect")%>
							</td>

							
							<%
							while not rsOptions.eof
							
								call getRecordSet(SQL_CONSULTA_IMPACT_BY_OPTIONID_CRITERIAID(cstr(rsOptions("optionID")), cstr(rsCriteria("criteriaID"))), rsImpact)
								if not rsImpact.eof then
								
							%>
								<td style="border: solid 1px black;padding:3px;vertical-align:top;"> <%=rsImpact("effect")%></td>
								<td width=20px style="border: solid 1px black;text-align:center;vertical-align:top;"> <%=ConvertImpact(rsImpact("impact"))%></td>
							<%else%>															
								<td style="border: solid 1px black;text-align:center;">&nbsp;</td>
								<td width=20px style="border: solid 1px black;text-align:center;">&nbsp;</td>
							<%
							end if
							rsOptions.movenext
							wend
							on error resume next
							rsOptions.MoveFirst
							on error goto 0
							
							%>	

							<td style="border: solid 1px black;padding:3px;vertical-align:top;">
							<%=rsCriteria("statusquo")%>
							</td>
							
						 </tr>  
						
						<% 																			
							rsCriteria.movenext
							Wend							
						%>
					</tr>
					<% 		end if																	
							rsEffect.movenext
							Wend
					%>
			</table>
<table>
  <tr>
    <td class="small">++</td>
    <td class="small">Large positive impact compared to the status quo.</td>
  </tr>
  <tr>
    <td class="small">+</td>
    <td class="small">Small positive impact compared to the status quo.</td>
  </tr>
  <tr>
    <td class="small">=</td>
    <td class="small">No impact compared to the status quo.</td>
  </tr>
  <tr>
    <td class="small">-</td>
    <td class="small">Small negative impact compared to the status quo.</td>
  </tr>
  <tr>
    <td class="small">--</td>
    <td class="small">Large negative impact compared to the status quo.</td>
  </tr>
  <tr>
    <td class="small">?</td>
    <td class="small">No evidentiary basis for evaluating the effect.</td>
  </tr>
</table>

		</td>
	</tr>
</table>												

 
 
  </div>
  </div>
  
</div>

		
   <div class="p-5">
  </div>
  <nav class="navbar fixed-bottom navbar-light bg-light">
      <div class="container-fluid justify-content-center p-0">
		 
			<%if getStatusStep(request.querystring("stepID")) = STATE_ACTIVE then %>
				<button class="btn btn-sm btn-secondary m-1" type="button" id="configureButton" data-bs-toggle="modal" data-bs-target="#iFrameModal" data-step-id="<%=request.querystring("stepID")%>" data-title="Configure" data-url="editOA.asp?stepID=<%=request.queryString("stepID")%>" ><i class="bi bi-gear text-light"></i> Configure</button>

				<button class="btn btn-sm btn-secondary m-1" type="button" data-bs-toggle="modal" data-bs-target="#manageEffects" data-step-id="<%=request.querystring("stepID")%>" data-title="Add Effect" data-url="criteriaActions.asp?action=new"  > <i class="bi bi-plus-square text-light"></i> Add Effect</button>
				<button class="btn btn-sm btn-secondary m-1" type="button" data-bs-toggle="modal" data-bs-target="#manageOptions" data-step-id="<%=request.querystring("stepID")%>" data-title="Add Option" data-url="optionActions.asp?action=new"  > <i class="bi bi-plus-square text-light"></i> Add Option</button>
				<button class="btn btn-sm btn-secondary m-1" type="button" data-bs-toggle="modal" data-bs-target="#manageImpacts" data-step-id="<%=request.querystring("stepID")%>" data-title="Estimate Impact" data-url="impactActions.asp?action=new"  > <i class="bi bi-plus-square text-light"></i> Estimate Impact</button>
				
	
				<button class="btn btn-sm btn-danger m-1" onclick="window.location.href='/stepsupportInformation.asp?stepID=<%=request.queryString("stepID")%>';"><i class="bi bi-journal-plus text-light"></i> Supporting Information</button>
				<button class="btn btn-sm btn-danger m-1" onclick="if(confirm('This action cannot be undone. Are you sure to end this FTA method now?'))window.location.href='/workflowActions.asp?action=end&stepID=<%=request.queryString("stepID")%>'"><i class="bi bi-check-lg text-light"></i> Finish</button>
			<%end if%>
      </div>
  </nav>		
		
</div>





 <!-- Manage Effect -->
<div class="modal fade" id="manageEffects" tabindex="-1" aria-labelledby="eventModalLabel" aria-hidden="true">
  <div class="modal-dialog modal-dialog-centered">
	<div class="modal-content">
	<form method="post" action="" autocomplete="off"  id ="formManageEffects" class="requires-validation m-0" novalidate>
	  <div class="modal-header">
		<h5 class="modal-title" id="eventModalLabel">xx</h5>
		<button type="button" class="btn-close" data-bs-dismiss="modal" aria-label="Close"></button>
	  </div>
	  <div class="modal-body">

	  <div class=" mb-3">
	  <label for="desiredeffect" class="form-label">Effect</label>
		<input class="form-control" list="datalistOptions" id="desiredeffect" name="desiredeffect" placeholder="Type to search..." required>
		<datalist id="datalistOptions">
		<% 
		 rsEffect.MoveFirst
			while not rsEffect.eof
		%>
		  <option data-value="<%=rsEffect("effectID")%>"><%=rsEffect("desiredeffect")%></option> 
		<% 
			rsEffect.movenext
			Wend
		%>
		</datalist>
		<input type="hidden" name="effectID" id="effectID">
		<div class="invalid-feedback">Desired Effect cannot be blank!</div>
	  </div>
	  
	  <div class=" mb-3">
		<label for="natureofeffect" class="form-label">Nature</label>
		<textarea class="form-control" id="natureofeffect" rows="2" name="natureofeffect" required></textarea>
		<div class="invalid-feedback">Nature of Effect cannot be blank!</div>
	  </div>
	  
	 <div class=" mb-3">
		<label for="statusquo" class="form-label">Status Quo</label>
		<textarea class="form-control" id="statusquo" rows="4" name="statusquo" required></textarea>
		<div class="invalid-feedback">Status Quo cannot be blank!</div>
	  </div>
	  
	  
	  </div>
	  <div class="modal-footer">
		<input type="hidden" name="criteriaID">		
		<input type="hidden" name="OAID" value="<%=oaID%>"> 
		<input type="hidden" name="stepID" value="<%=request.queryString("stepID")%>"> 
		<button type="button" class="btn btn-sm btn-secondary m-1 text-center" data-bs-dismiss="modal">Close</button>
		<button type="submit" class="btn btn-sm btn-danger m-1 text-center" ><i class="bi bi-save text-light"></i> Save</button>
	  </div> 
	</form>
	</div>
  </div>
</div>		


 <!-- Manage Options -->
<div class="modal fade" id="manageOptions" tabindex="-1" aria-labelledby="eventModalLabel" aria-hidden="true">
  <div class="modal-dialog modal-dialog-centered">
	<div class="modal-content">
	<form method="post" action="" autocomplete="off"  id ="formManageOptions" class="requires-validation m-0" novalidate>
	  <div class="modal-header">
		<h5 class="modal-title" id="eventModalLabel">xx</h5>
		<button type="button" class="btn-close" data-bs-dismiss="modal" aria-label="Close"></button>
	  </div>
	  <div class="modal-body">

	  <div class=" mb-3">
		<label for="name" class="form-label">Option</label>
		<input class="form-control" id="name" name="name" required />
		<div class="invalid-feedback">Option cannot be blank!</div>
	  </div>
	  
	  <div class=" mb-3">
		<label for="description" class="form-label">Description</label>
		<textarea class="form-control" id="description" rows="3" name="description" required></textarea>
		<div class="invalid-feedback">Description cannot be blank!</div>
	  </div>
	  
	  </div>
	  <div class="modal-footer">
		<input type="hidden" name="optionID">		
		<input type="hidden" name="OAID" value="<%=oaID%>"> 
		<input type="hidden" name="stepID" value="<%=request.queryString("stepID")%>"> 
		<button type="button" class="btn btn-sm btn-secondary m-1 text-center" data-bs-dismiss="modal">Close</button>
		<button type="submit" class="btn btn-sm btn-danger m-1 text-center" ><i class="bi bi-save text-light"></i> Save</button>
	  </div> 
	</form>
	</div>
  </div>
</div>		



 <!-- Manage Impacts -->
<div class="modal fade" id="manageImpacts" tabindex="-1" aria-labelledby="eventModalLabel" aria-hidden="true">
  <div class="modal-dialog modal-dialog-centered">
	<div class="modal-content">
	<form method="post" action="" autocomplete="off"  id ="formManageOptions" class="requires-validation m-0" novalidate>
	  <div class="modal-header">
		<h5 class="modal-title" id="eventModalLabel">xx</h5>
		<button type="button" class="btn-close" data-bs-dismiss="modal" aria-label="Close"></button>
	  </div>
	  <div class="modal-body">

		<div class=" mb-3">
			<label for="criteriaID" class="form-label">Effect</label>
			<select class="form-select" id="criteriaID" name="criteriaID" required>
			<option hidden disabled selected value>Select a Effect</option>
			<%
			
			rsEffect.movefirst
			
			while not rsEffect.eof
				call getRecordSet(SQL_CONSULTA_CRITERIA(cstr(rsEffect("effectID"))),rsCriteria)
				while not rsCriteria.eof
			
					response.write("<option value='" & rsCriteria("criteriaID") & "'>"+rsEffect("DesiredEffect")+" - "+ rsCriteria("NatureOfEffect")+"</option>")
					
					rsCriteria.movenext
				wend
				rsEffect.movenext
			wend
			%>
			</select>
		  </div>
		  
		 <div class=" mb-3">
			<label for="optionID" class="form-label">Option</label>
			<select class="form-select" id="optionID" name="optionID" required>
			<option hidden disabled selected value>Select a Option</option>
			<%
			rsOptions.movefirst
			while not rsOptions.eof
					response.write("<option value='" & rsOptions("optionID") & "'>"+rsOptions("name")+"</option>")
				rsOptions.movenext
			wend
			%>
			</select>
		  </div>
		  
		   
		  <div class=" mb-3">
			<label for="effect" class="form-label">Expectation</label>
			<textarea class="form-control" id="effect" rows="4" name="effect" required></textarea>
			<div class="invalid-feedback">Expected Effect cannot be blank!</div>
		  </div>
		  
		  
		 <div class=" mb-3">
			<label for="impact" class="form-label">Impact</label>
			<select class="form-select" id="impact" name="impact" required>
			<%
			response.write("<option value='" & HIGHLY_POSITIVE & "'>Large positive impact compared to the status quo</option>")
			response.write("<option value='" & POSITIVE & "'>Small positive impact compared to the status quo</option>")
			response.write("<option value='" & NO_IMPACT & "'>No impact compared to the status quo</option>")
			response.write("<option value='" & NEGATIVE & "'>Small negative impact compared to the status quo</option>")
			response.write("<option value='" & HIGHLY_NEGATIVE & "'>Large negative impact compared to the status quo</option>")
			response.write("<option value='" & UNKNWOWN & "'>No evidentiary basis for evaluating the effect</option>")
			%>
			</select>
		  </div>
	  
	  </div>
	  <div class="modal-footer">
		<input type="hidden" name="criteriaID"> 
		<input type="hidden" name="optionID"> 
		<input type="hidden" name="OAID" value="<%=oaID%>"> 
		<input type="hidden" name="stepID" value="<%=request.queryString("stepID")%>"> 
		<button type="button" class="btn btn-sm btn-secondary m-1 text-center" data-bs-dismiss="modal">Close</button>
		<button type="submit" class="btn btn-sm btn-danger m-1 text-center" ><i class="bi bi-save text-light"></i> Save</button>
	  </div> 
	</form>
	</div>
  </div>
</div>		


<!-- Add/Edit Modal -->
<div class="modal fade" id="iFrameModal" tabindex="-1" aria-labelledby="iFrameModal" aria-hidden="true">
  <div class="modal-dialog modal-dialog-centered">
    <div class="modal-content">
      <div class="modal-header">
        <h5 class="modal-title" id="iFrameModalTitle"></h5>
        <button type="button" class="btn-close" data-bs-dismiss="modal" aria-label="Close"></button>
      </div>
      <div class="modal-body p-0">
        <iframe id="iFrameModaliFrame" src="" class="w-100" style="height:400px">
		</iframe>
      </div>
     </div>
  </div>
</div>	





<script>

/*Fundamental para o funcionamento do formulário de seleção de efeitos. Em especial o campo "desiredeffect" */
document.querySelector('input[list]').addEventListener('input', function(e) {
    var input = e.target,
        list = input.getAttribute('list'),
        options = document.querySelectorAll('#' + list + ' option'),
        //hiddenInput = document.getElementById(input.getAttribute('id') + '-hidden'),
		hiddenInput = document.getElementById('effectID'),
        inputValue = input.value;

    hiddenInput.value = "";

    for(var i = 0; i < options.length; i++) {
        var option = options[i];

        if(option.innerText === inputValue) {
            hiddenInput.value = option.getAttribute('data-value');
            break;
        }
    }
});



$('#manageEffects').on('show.bs.modal', function(e) {
	
	var title = $(e.relatedTarget).data('title');
	var desiredeffect = $(e.relatedTarget).data('effect');
	var effectID = $(e.relatedTarget).data('effectId');
	var natureofeffect = $(e.relatedTarget).data('nature');
	var statusquo = $(e.relatedTarget).data('statusQuo');

	var url = $(e.relatedTarget).data('url');
	var criteriaID = $(e.relatedTarget).data('criteriaId');
	var oaID = $(e.relatedTarget).data('oaId');

	
    $(e.currentTarget).find('#formManageEffects').attr('action', url);
    $(e.currentTarget).find('#eventModalLabel').html(title);
	
	
	$(e.currentTarget).find('input[name="desiredeffect"]').val(desiredeffect);
    $(e.currentTarget).find('input[name="effectID"]').val(effectID);
    
	$(e.currentTarget).find('textarea[name="natureofeffect"]').val(natureofeffect);
    $(e.currentTarget).find('textarea[name="statusquo"]').val(statusquo);
	$(e.currentTarget).find('input[name="criteriaID"]').val(criteriaID);
	$(e.currentTarget).find('input[name="oaID"]').val(oaID);
	
	localStorage.setItem("nav-effects-tab", e.target.id);
	var triggerEl = document.querySelector("#nav-effects-tab")
	triggerEl.click();

});
</script>	





<script>
$('#manageOptions').on('show.bs.modal', function(e) {
	
	var title = $(e.relatedTarget).data('title');
	var option = $(e.relatedTarget).data('option');
	var description = $(e.relatedTarget).data('description');
	var url = $(e.relatedTarget).data('url');
	var optionID = $(e.relatedTarget).data('optionId');
	var oaID = $(e.relatedTarget).data('oaId');

	
    $(e.currentTarget).find('#formManageOptions').attr('action', url);
    $(e.currentTarget).find('#eventModalLabel').html(title);
	$(e.currentTarget).find('input[name="name"]').val(option);
    $(e.currentTarget).find('textarea[name="description"]').val(description);
	$(e.currentTarget).find('input[name="optionID"]').val(optionID);
	$(e.currentTarget).find('input[name="oaID"]').val(oaID);
	
	localStorage.setItem("nav-options-tab", e.target.id);
	var triggerEl = document.querySelector("#nav-options-tab")
	triggerEl.click();

});
</script>	



<script>
const effects = document.getElementById('criteriaID');

function enableAllOptions(selectElementId) {
  const selectElement = document.getElementById(selectElementId);
  Array.from(selectElement.options).forEach(option => {
    if (option.value) { // Ignora opções sem valor
      option.disabled = false; // Remove o estado "disabled"
    }
  });
  console.log(`Todas as opções válidas em #${selectElementId} foram habilitadas.`);
}


function disableOptions(response) {
  // Supondo que a resposta seja um objeto JSON, você pode acessar os dados dessa forma:
  console.log('Resposta da requisição:', response);
  
  // Exemplo de como usar a resposta no código
  if (response.success) {
    console.log('Ação realizada com sucesso!');
  } else {
    console.log('Erro ao realizar a ação.');
  }
}


effects.addEventListener('change', (e) => {
	console.log(`e.target.value = ${ e.target.value }`);
	enableAllOptions('optionID');

	fetch(`impactActions.asp?action=listUnavailableOptions&criteriaID=${e.target.value}`)
    .then(response => {
      if (!response.ok) {
        throw new Error(`Resquest error: ${response.statusText}`);
      }
	 // console.log(response.text());
//	  console.log(response.json());
      return response.json();
    })
    .then(data => {
	
	     if (data.Result === "OK" && Array.isArray(data.Records)) {
        // Obtém o select pelo ID
        const selectElement = document.getElementById('optionID');

        // Itera sobre os registros retornados
        data.Records.forEach(record => {
          const optionID = record.optionid;

          // Encontra o <option> correspondente pelo valor
          const optionToDisable = Array.from(selectElement.options).find(
            option => parseInt(option.value, 10) === optionID
          );

          // Se encontrado, desabilita o <option>
          if (optionToDisable) {
            optionToDisable.disabled = true;
            console.log(`Option ID ${optionID} desabilitado.`);
          }
        });
      } else {
        console.warn('Nenhum registro encontrado ou resposta inválida.');
      }
    })
    .catch(error => {
      console.error('Error:', error);
    });
  
//  console.log(`effects.options[effects.selectedIndex].value = ${ effects.options[effects.selectedIndex].value }`);
});




$('#manageImpacts').on('show.bs.modal', function(e) {
	
	var title = $(e.relatedTarget).data('title');
	var url = $(e.relatedTarget).data('url');
	var oaID = $(e.relatedTarget).data('oaId');
	var optionID = $(e.relatedTarget).data('optionId');
	var criteriaID = $(e.relatedTarget).data('criteriaId');
	var effect = $(e.relatedTarget).data('effect');
	var impact = $(e.relatedTarget).data('impact');
	var option = $(e.relatedTarget).data('option');

    $(e.currentTarget).find('#formManageOptions').attr('action', url);
    $(e.currentTarget).find('#eventModalLabel').html(title);
    $(e.currentTarget).find('textarea[name="effect"]').val(effect);
    $(e.currentTarget).find('select[name="impact"]').val(impact);
	$(e.currentTarget).find('input[name="oaID"]').val(oaID);

	console.log("optionID"+optionID);
	console.log("criteriaID"+criteriaID);
	if (optionID != undefined) {
		$(e.currentTarget).find('select[name="optionID"]').val(optionID).prop('disabled', true);
		$(e.currentTarget).find('input[name="optionID"]').val(optionID);
	}
	else $(e.currentTarget).find('select[name="optionID"]').prop('disabled', false);
	
	if (criteriaID != undefined) {
		$(e.currentTarget).find('select[name="criteriaID"]').val(criteriaID).prop('disabled', true);
		$(e.currentTarget).find('input[name="criteriaID"]').val(criteriaID);
	}
	else $(e.currentTarget).find('select[name="criteriaID"]').prop('disabled', false);
	
	
	localStorage.setItem("nav-impacts-tab", e.target.id);
	var triggerEl = document.querySelector("#nav-impacts-tab")
	triggerEl.click();

});
</script>	




<script>

$('#iFrameModal').on('show.bs.modal', function(e) {
	var title = $(e.relatedTarget).data('title');
	var url = $(e.relatedTarget).data('url');
    
	$('#iFrameModalTitle').html(title);
	$('#iFrameModaliFrame').attr('src',url);
});
</script>

<script>
$('#nav-tab').on("shown.bs.tab",function(e){
	localStorage.setItem("oa-idtab", e.target.id);
});


$( document ).ready(function() {
   var id_tab = localStorage.getItem("oa-idtab"); 
   if (id_tab!="") {
	   var triggerEl = document.querySelector("#"+id_tab)
	   triggerEl.click();

	   <% if rs("benefit") = "" Then%>
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
