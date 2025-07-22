<!--#include virtual="/system.asp"-->
<!--#include virtual="/checkstep.asp"-->
<!--#include file="INC_SCENARIO.inc"-->

<%
saveCurrentURL
render.renderTitle()
%>
							


<div class="p-3">

<%

dim rs
		Dim counter
		
		call getRecordset(SQL_CONSULTA_SCENARIOS(request.querystring("stepID")),rs)
		
		if rs.eof then
		response.write "<div class='py-3'><div class='alert alert-danger'> No Scenarios described yet. Please click on <b>Add Scenario</b> button to include the first scenario.</div></div>"
	else
%>
<table class="table table-striped table-hover">
  <thead class="table-dark">
	<tr class="d-flex">
		<td class="flex-grow-1">Title</td>
		<td class="flex-shrink-1">Actions</td>
	</tr>
  </thead>
  <tbody>
  
  <%
	while not rs.eof
	%>
  <tr class="d-flex">
  	
	
		<td class="flex-grow-1"> 														
			<a href="#" class="link-dark text-decoration-none" data-bs-toggle="modal" data-bs-target="#manageScenarioModal" data-title="Edit Scenario" data-url="manageScenario.asp?stepID=<%=request.querystring("stepID")%>&scenarioID=<%=cstr(rs("scenarioID"))%>"><%=(rs("name"))%></a> 
		</td>	
<!--		<td>														
			<a class="link-dark text-decoration-none" href="manageScenario.asp?stepID=<%=request.querystring("stepID")%>&scenarioID=<%=cstr(rs("scenarioID"))%>"><%=(rs("description"))%></a> 
		</td>	
-->
		<td class="flex-shrink-1"> 																											
			<%if getStatusStep(request.querystring("stepID")) = STATE_ACTIVE then %>
			<a class="link-dark text-decoration-none" href="scenarioActions.asp?action=delete&stepID=<%=request.querystring("stepID")%>&scenarioID=<%=cstr(rs("scenarioID"))%>" title="Delete"  onclick="if (!confirm('Are you sure?')) { return false; }"><img src="/img/delete.png"  height=20 width=auto></a>
			<%end if%>
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
		

    <%if getStatusStep(request.querystring("stepID")) = STATE_ACTIVE then %>
		<button class="btn btn-sm btn-secondary m-1" type="button" data-bs-toggle="modal" data-bs-target="#manageScenarioModal" data-title="Add Scenario" data-url="manageScenario.asp?stepID=<%=request.queryString("stepID")%>"> <i class="bi bi-plus-square text-light"></i> Add Scenario</button>
		<button class="btn btn-sm btn-danger m-1" onclick="window.location.href='/stepsupportInformation.asp?stepID=<%=request.queryString("stepID")%>';"><i class="bi bi-journal-plus text-light"></i> Supporting Information</button>
		<button class="btn btn-sm btn-danger m-1" onclick="if(confirm('This action cannot be undone. Are you sure to end this FTA method now?'))window.location.href='/workflowActions.asp?action=end&stepID=<%=request.queryString("stepID")%>'"><i class="bi bi-check-lg text-light"></i> Finish</button>
	<%end if%>
		 
         </div>
      </nav>									

</div>
  
  
  
<!-- Add/Edit Reference Modal -->
<div class="modal fade" id="manageScenarioModal" tabindex="-1" aria-labelledby="manageScenarioModal" aria-hidden="true">
  <div class="modal-dialog modal-dialog-centered modal-xl">
    <div class="modal-content">
      <div class="modal-header">
        <h5 class="modal-title" id="scenarioModal"></h5>
        <button type="button" class="btn-close" data-bs-dismiss="modal" aria-label="Close"></button>
      </div>
      <div class="modal-body p-0">
        <iframe id="iframeScenario" src="" class="w-100" style="height:600px">
		</iframe>
      </div>
     </div>
  </div>
</div>		

<script>
$('#manageScenarioModal').on('show.bs.modal', function(e) {
	var title = $(e.relatedTarget).data('title');
	var url = $(e.relatedTarget).data('url');
    
	$('#scenarioModal').html(title);
	$('#iframeScenario').attr('src',url);
});
</script>

  
  
<%
render.renderFooter()
%>
