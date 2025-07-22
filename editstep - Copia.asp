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


function showOptions
 	Call getRecordSet(SQL_CONSULTA_USUARIO_TODOS(), usuario)

	response.write "[" 
		while not usuario.eof
			response.write "{ Value: '"+ usuario("email") + "', DisplayText: '"+ usuario("name") + "' }"
			usuario.movenext
			if not usuario.eof then response.write ", "
		wend
	response.write "]"	

end function

render.renderToBody()
%>

						

<div class="container-fluid d-flex flex-grow-1 flex-column p-3">
 <div class="row d-flex">
        <div class="col d-flex">
			<div class="col-lg-12 col-md-12 col-sm-12 align-self-center">
				<h1 class="fs-3 fw-bolder text-dark text-uppercase"><%=getFTAMethodNamebyFTAmethodID(cstr(rs("type")))%></h1>
				<hr>
			</div>
		   </div>
    </div>
    <div class="row d-flex flex-grow-1 justify-content-start">	
	

<div id="PeopleTableContainer"></div>

</div>
<Button class="TIAMATButton" onclick="window.location.href='/manageWorkflow.asp?workflowID=<%=cstr(workflowID)%>';">Back</button>
					
<div class="modal-footer fixed-bottom pb-0 px-0 mx-0">
		<button class="btn btn-sm btn-secondary m-1" onclick="top.location.href='/manageWorkflow.asp?workflowID=<%=cstr(workflowID)%>';"> Close</button>
</div>					
					
<script type="text/javascript">
$(document).ready(function () {

	//Prepare jTable
	$('#PeopleTableContainer').jtable({
		title: 'Users with Role <%=request.querystring("role")%>',
		paging: false, //Enable paging
		sorting: false, //Enable sorting
		columnResizable: false, //Disable column resizing
		columnSelectable: false, //Disable column selecting
		actions: {
			listAction: '/stepUserActions.asp?action=list&stepID=<%=request.queryString("stepID")%>&role=<%=request.queryString("role")%>',
			createAction: '/stepUserActions.asp?action=new&stepID=<%=request.queryString("stepID")%>&role=<%=request.queryString("role")%>',
			deleteAction: '/stepUserActions.asp?action=delete&stepID=<%=request.queryString("stepID")%>&role=<%=request.queryString("role")%>'
		},
		fields: {
			email: {
				title: 'User',
				key: true,
				create: true,
				edit: false,
				options: <%showOptions%> 
			}
		}
	});

	//Load person list from server
	$('#PeopleTableContainer').jtable('load');

});

</script>

				
<script>
	selectForm(document.forms[0].ftamethod);
</script>

<%
render.renderFromBody()
%>

							