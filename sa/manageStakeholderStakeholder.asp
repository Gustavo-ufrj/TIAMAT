<!--#include virtual="/system.asp"-->
<!--#include virtual="/checklogin.asp"-->
<!--#include virtual="/checkadmin.asp"-->
<!--#include file="INC_SA.inc"-->

<%
saveCurrentURL

tiamat.addCSS("sa.css")

render.renderTitle()
%>
<html>


<%
' Calculo das opções de Critérios 

	Dim firstStakeholderList, secondStakeholderList
	call getRecordSet(SQL_CONSULTA_STAKEHOLDER(Request.QueryString("SAID")), rs)

	firstStakeholderList = ""

	if not rs.eof then
		while not rs.eof
			firstStakeholderList = firstStakeholderList + "{ Value: '"+ cstr(rs("stakeholderID"))+"', DisplayText: '" +rs("ContactName")+ "'}"
			rs.movenext
		if not rs.eof then
		firstStakeholderList = firstStakeholderList + ", "
		end if
		wend
	end if

	firstStakeholderList = "[" + firstStakeholderList + "]"


' Calculo das opções de Opções

	call getRecordSet(SQL_CONSULTA_STAKEHOLDER(Request.QueryString("SAID")), rs)

	secondStakeholderList = ""

	if not rs.eof then
		while not rs.eof
			secondStakeholderList = secondStakeholderList + "{ Value: '"+ cstr(rs("stakeholderID"))+"', DisplayText: '" +rs("ContactName")+ "'}"
			rs.movenext
		if not rs.eof then
		secondStakeholderList = secondStakeholderList + ", "
		end if
		wend
	end if

	secondStakeholderList = "[" + secondStakeholderList + "]"

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
													<p class="font_6" align="justify">MANAGE STAKEHOLDER INTERESTS <font color="red">//</font></p>
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
																	listAction: 'stakeholderStakeholderAction.asp?action=list&SAID=<%=Request.QueryString("SAID")%>',
																	createAction: 'stakeholderStakeholderAction.asp?action=new&SAID=<%=Request.QueryString("SAID")%>',
																	updateAction: 'stakeholderStakeholderAction.asp?action=update&SAID=<%=Request.QueryString("SAID")%>',
																	deleteAction: 'stakeholderStakeholderAction.asp?action=delete&SAID=<%=Request.QueryString("SAID")%>'
																},
																fields: {
																	stakeholderstakeholderid: {
																		title: 'StakeholderStakeholderID',																		
																		key: true,
																		edit: false,
																		visibility: 'hidden' 																		
																	},
																	
																	firststakeholderid: {
																		title: 'First Stakeholder',
																		width: '33%',
																		options: <%=firstStakeholderList%>
																	},
																	
																	secondstakeholderid: {
																		title: 'Second Stakeholder',
																		width: '33%',
																		options: <%=secondStakeholderList%>
																	},
																	
																	relationship: {
																		title: 'Relationship',
																		width: '33%',
																		input: function (data) {
																			if (data.record) {
																				return '<input name="relationship" style="width:200px;" value="' + data.record.relationship + '"/>';
																			} else {
																				return '<input name="relationship" style="width:200px;" />';
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

<%
render.renderFooter()
%>