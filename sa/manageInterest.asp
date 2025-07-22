<!--#include virtual="/system.asp"-->
<!--#include virtual="/checklogin.asp"-->
<!--#include virtual="/checkadmin.asp"-->
<!--#include file="INC_SA.inc"-->

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
																	listAction: 'interestActions.asp?action=list&SAID=<%=Request.QueryString("SAID")%>',
																	createAction: 'interestActions.asp?action=new&SAID=<%=Request.QueryString("SAID")%>',
																	updateAction: 'interestActions.asp?action=update&SAID=<%=Request.QueryString("SAID")%>',
																	deleteAction: 'interestActions.asp?action=delete&SAID=<%=Request.QueryString("SAID")%>'
																},
																fields: {
																	interestid: {
																		title: 'InterestID',																		
																		key: true,
																		edit: false,
																		visibility: 'hidden' 																		
																	},
																		
																	interest: {
																		title: 'Interest',
																		width: '100%',
																		input: function (data) {
																			if (data.record) {
																				return '<textarea name="interest" style="width:200px;" >' + data.record.interest + '</textarea>';
																			} else {
																				return '<textarea name="interest" style="width:200px;" />';
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