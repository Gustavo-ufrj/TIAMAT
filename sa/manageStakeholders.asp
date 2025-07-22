<!--#include virtual="/system.asp"-->
<!--#include virtual="/checklogin.asp"-->
<!--#include virtual="/checkadmin.asp"-->

<%
saveCurrentURL

tiamat.addCSS("sa.css")

render.renderTitle()
%>

							<table class="principal" width=100%>
								<tr>
									<td width=20px>
										&nbsp;
									</td>
									<td align=center>
										<table width=1184 class="padded">

											<!-- INICIO AREA EDITAVEL -->
							

											<tr>
												<td>
													<p class="font_6" align="justify">MANAGE STAKEHOLDERS <font color="red">//</font></p>
												</td>
											</tr>
											<tr>
												<td>
												<hr class="linhaDupla">
												</td>
											</tr>
											<tr>
												<td>
													<div id="jTableContainer"></div>
													
													<script type="text/javascript">
														$(document).ready(function () {

															//Prepare jTable
															$('#jTableContainer').jtable({
																title: 'Stakeholder List',
																paging: false, //Enable paging
																sorting: false, //Enable sorting
																columnResizable: false, //Disable column resizing
																columnSelectable: false, //Disable column selecting
																openChildAsAccordion: true, //Enable this line to show child tables as accordion style
																actions: {
																	listAction: 'stakeholderActions.asp?action=list&SAID=<%=Request.QueryString("SAID")%>',
																	createAction: 'stakeholderActions.asp?action=new&SAID=<%=Request.QueryString("SAID")%>',
																	updateAction: 'stakeholderActions.asp?action=update&SAID=<%=Request.QueryString("SAID")%>',
																	deleteAction: 'stakeholderActions.asp?action=delete&SAID=<%=Request.QueryString("SAID")%>'
																},
																fields: {
																	stakeholderid: {
																		title: 'StakeholderID',																		
																		key: true,
																		edit: false,
																		visibility: 'hidden' 																		
																	},
																	
																	type: {
																		title: 'Type',
																		width: '15%',
																		options: [{Value:'1',DisplayText:'Individual'},{Value:'2',DisplayText:'Private Organization'},{Value:'3',DisplayText:'Governmental Organization'},{Value:'4',DisplayText:'Non-Governmental Organization'}],
																		input: function (data) {
																			if (data.record) {
																				if(data.record.type == 1){
																					return '<select name="type" style="width:200px;"  onchange="disableOrganization()">  <option value="1" selected>Individual</option> <option value="2">Private Organization</option> <option value="3">Governmental Organization</option> <option value="4">Non-Governmental Organization</option>  </select>';
																				}else
																				if(data.record.type == 2){
																					return '<select name="type" style="width:200px;"  onchange="disableOrganization()">  <option value="1">Individual</option> <option value="2" selected>Private Organization</option> <option value="3">Governmental Organization</option> <option value="4">Non-Governmental Organization</option>  </select>';
																				}else
																				if(data.record.type == 3){
																					return '<select name="type" style="width:200px;"  onchange="disableOrganization()">  <option value="1">Individual</option> <option value="2">Private Organization</option> <option value="3" selected>Governmental Organization</option> <option value="4">Non-Governmental Organization</option>  </select>';
																				}else
																				if(data.record.type == 4){
																					return '<select name="type" style="width:200px;"  onchange="disableOrganization()">  <option value="1">Individual</option> <option value="2">Private Organization</option> <option value="3">Governmental Organization</option> <option value="4" selected>Non-Governmental Organization</option>  </select>';
																				}
																			} else {
																				return '<select name="type" style="width:200px"  onchange="disableOrganization()" >  <option value="1">Individual</option> <option value="2">Private Organization</option> <option value="3">Governmental Organization</option> <option value="4">Non-Governmental Organization</option>  </select>';
																			}
																		}
																	},
																	
																	organizationname: {
																		title: 'Organization',
																		width: '15%',
																		input: function (data) {
																			if (data.record && data.record.type != 1) {
																				return '<input name="organizationname" style="width:200px;" value="' + data.record.organizationname + '"/>';
																			} else {
																				return '<input disabled name="organizationname" style="width:200px;" />';
																			}
																		}
																	},
																	
																	contactname: {
																		title: 'Contact name',
																		width: '15%',
																		input: function (data) {
																			if (data.record) {
																				return '<input name="contactname" style="width:200px;" value="' + data.record.contactname + '"/>';
																			} else {
																				return '<input name="contactname" style="width:200px;" />';
																			}
																		}
																	},
																	
																	email: {
																		title: 'E-mail',
																		width: '15%',
																		input: function (data) {
																			if (data.record) {
																				return '<input name="email" style="width:200px;" value="' + data.record.email + '"/>';
																			} else {
																				return '<input name="email" style="width:200px;" />';
																			}
																		}
																	},
																	
																	role: {
																		title: "Stakeholder's role",
																		width: '15%',
																		input: function (data) {
																			if (data.record) {
																				return '<input name="role" style="width:200px;" value="' + data.record.role + '"/>';
																			} else {
																				return '<input name="role" style="width:200px;" />';
																			}
																		}
																	},
																	
																	conflictrole: {
																		title: 'Conflict Role',
																		width: '15%',
																		input: function (data) {
																			if (data.record && data.record.conflictrole != null ) {
																				return '<input name="conflictrole" style="width:200px;" value="' + data.record.conflictrole + '"/>';
																			} else {
																				return '<input name="conflictrole" style="width:200px;" />';
																			}
																		}
																	}
																}
															});

															//Load person list from server
															$('#jTableContainer').jtable('load');

														});

													</script>
 
													
												</td>
											</tr>
											<tr>
												<td>
												<hr class="linhaDupla">
												</td>
											</tr>
											
											<tr>
												<td align=center>
														<button class="TIAMATButton" onclick="window.location.href='index.asp?stepID=<%=request.queryString("stepID")%>'">Back</button>
												</td>
											</tr>

										<!-- FIM AREA EDITAVEL -->

											</tr>
										</table>
									</td>
									<td width=20px>
									&nbsp;&nbsp;&nbsp;
									</td>
								</tr>
							</table>

<script>
function disableOrganization()
{
	var inputOrganization = document.getElementsByName("organizationname")[0];
	var inputType = document.getElementsByName("type")[0];
	
	if(inputType.value == "1"){
		inputOrganization.disabled = true;
		inputOrganization.value = "";
	}
	else
		inputOrganization.disabled = false;
}

function IsEmail(email) {
  var regex = /^([a-zA-Z0-9_.+-])+\@(([a-zA-Z0-9-])+\.)+([a-zA-Z0-9]{2,4})+$/;
  return regex.test(email);
}


</script>

<%
render.renderFooter()
%>