<!--#include virtual="/system.asp"-->
<!--#include virtual="/checkstep.asp"-->
<!--#include file="INC_DELPHI.inc"-->

<%
saveCurrentURL

Dim rs
Dim stepID
Dim role

If Request.querystring("stepID") <> "" Then
	stepID = request.querystring("stepID")
	
	role = getRole(stepID, Session("email"))
	
	If role <> "Coordinator" Then
		Session("delphiError") = "You are not a delphi coordinator."
		response.redirect "index.asp?stepID=" & stepID & "&redirect=1"
	End If
End If


tiamat.addCSS("delphi.css")

render.renderTitle()
%>
							<table class="principal" width=100%>
								<tr>
									<td width=20px>
										&nbsp;
									</td>
									<td align=center>
										<table width="1184px" class="padded">

											<!-- INICIO AREA EDITAVEL -->
							

											<tr>
												<td>
													<p class="font_6" align="justify">EDIT DELPHI ROUNDS <font color="red">//</font></p>							
												</td>
											</tr>
											<tr>
												<td>
												<hr class="linhaDupla">
												</td>
											</tr>
											<tr>
												<td>
													<%
														If stepID <> "" Then
															response.write("<div id=""delphi-rounds""></div>")
														End If
													%>
												</td>
											</tr>
											<tr>
												<td>
													<hr class="linhaDupla">
												</td>
											</tr>
											<tr>
											
												<td align=center>
													<input type=hidden name="stepID" value="<%=stepID%>" />
													<button class="TIAMATButton" onclick="window.location.href='index.asp?stepID=<%=stepID%>'">Back</button>
												</td>

										<!-- FIM AREA EDITAVEL -->

											</tr>
											<tr>
												<td height="60px" valign="middle" align="center" colspan="2" class="padded" >
													<font class="error-msg" color=red><%=Session("delphiRoundsError")%></font>
													<%
													Session("delphiRoundsError") = ""
													%>
												</td>
											</tr>
										</table>
									</td>
									<td width=20px>
									&nbsp;&nbsp;&nbsp;
									</td>
								</tr>
							</table>

<script type="text/javascript">
$(document).ready(function () {

	//Prepare jTable
	$('#delphi-rounds').jtable({
		title: 'Delphi Rounds',
		paging: false, //Enable paging
		sorting: true, //Enable sorting
		defaultSorting: 'id ASC',
		columnResizable: false, //Disable column resizing
		columnSelectable: false, //Disable column selecting
		selecting: true,
		multiselect: false,
		toolbar: {
			items: [{
				icon: '/js/contextMenu/images/page_white_edit.png',
				text: 'Manage',
				click: function () {
					var selectedRow = $('#delphi-rounds').jtable('selectedRows');
					var roundID = '';
					
					if (selectedRow.length === 0) {
						alert("Please select one round to be managed.");
					} else if (selectedRow.length > 1) {
						alert("Please select just one round to be managed.");
					} else {
						roundID = $(selectedRow).first().attr('data-record-key');
						
						window.location.href = 'manageQuestions.asp?stepID=<%=stepID%>&roundID=' + roundID;
					}
				}
			},{
				icon: '/js/contextMenu/images/page_white_paste.png',
				text: 'View Statistics',
				click: function () {
					var selectedRow = $('#delphi-rounds').jtable('selectedRows');
					var roundID = '';
					
					if (selectedRow.length === 0) {
						alert("Please select one round to view its statistics.");
					} else if (selectedRow.length > 1) {
						alert("Please select just one round to view its statistics.");
					} else {
						roundID = $(selectedRow).first().attr('data-record-key');
						
						window.location.href = 'statistics.asp?stepID=<%=stepID%>&roundID=' + roundID;
					}
				}
			}]
		},
		actions: {
			listAction: '/FTA/delphi/delphiActions.asp?action=list_rounds&stepID=<%=stepID%>',
			createAction: '/FTA/delphi/delphiActions.asp?action=new_round&stepID=<%=stepID%>',
			updateAction: '/FTA/delphi/delphiActions.asp?action=update_round&stepID=<%=stepID%>',
			deleteAction: '/FTA/delphi/delphiActions.asp?action=delete_round&stepID=<%=stepID%>'
		},
		fields: {
			roundid: {
				title: 'Id',
				key: true,
				type: 'hidden',
				create: false,
				edit: false,
				sorting: true,
				width: '0%'
			},
			text: {
				title: 'Description',
				type: 'text',
				width: '70%'
			},
			state: {
				title: 'State',
				options: { '0': 'Unpublished', '1': 'Published', '2': 'Ended' },
				width: '30%'
			}
		}
	});

	//Load person list from server
	$('#delphi-rounds').jtable('load');
	
});

</script>

<%
render.renderFooter()
%>