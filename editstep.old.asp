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

render.renderTitle()
%>

							<table class="principal" width=100%>
								<tr>
									<td width=20px>
										&nbsp;
									</td>
									<td align=center>
										<table width=1184 class="padded">
										<tr>
											<td>


	<table class="principal" width=100% height=100%>
		<tr>
			<td align=center class="padded">
				<br>
				<p class="font_6" align="justify">EDIT <%=ucase(getFTAMethodNamebyFTAmethodID(cstr(rs("type"))))%> <font color="red">//</font></p>							
			</td>
		</tr>
		<tr>
			<td align=center>
				<hr class="linhaDupla">
			</td>
		</tr>
		<tr>
			<td align=center class="padded">
			

			

<div id="PeopleTableContainer"></div>
					
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

			
			
				
				
			</td>
		</tr>
		<tr>
			<td align=center>
				<hr class="linhaDupla">
			</td>
		</tr>
		<tr>
			<td align=center class="padded">
				<Button class="TIAMATButton" onclick="window.location.href='/manageWorkflow.asp?workflowID=<%=cstr(workflowID)%>';">Back</button>
				<script>
					selectForm(document.forms[0].ftamethod);
				</script>
			</td>
		</tr>
		<tr>
			<td align=center height=500px>
			</td>
		</tr>
	</table>
												</td>
												

										<!-- FIM AREA EDITAVEL -->

											</tr>
										</table>
									</td>
									<td width=20px>
									&nbsp;&nbsp;&nbsp;
									</td>
								</tr>
							</table>

<%
render.renderFooter()
%>

							