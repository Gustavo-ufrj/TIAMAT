<!--#include virtual="/system.asp"-->
<!--#include virtual="/checkstep.asp"-->
<!--#include file="INC_ROADMAP.inc"-->

<%
saveCurrentURL
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
													<p class="font_6" align="justify">MANAGE EVENTS <font color="red">//</font></p>
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
																title: 'Events',
																paging: false, //Enable paging
																sorting: true, //Enable sorting
																columnResizable: false, //Disable column resizing
																columnSelectable: false, //Disable column selecting
																actions: {
																	listAction: 'eventActions.asp?action=list&roadmapID=<%=Request.QueryString("roadmapID")%>',
																	createAction: 'eventActions.asp?action=new&roadmapID=<%=Request.QueryString("roadmapID")%>',
																	updateAction: 'eventActions.asp?action=update&roadmapID=<%=Request.QueryString("roadmapID")%>',
																	deleteAction: 'eventActions.asp?action=delete&roadmapID=<%=Request.QueryString("roadmapID")%>'
																},
																fields: {
																	eventid: {
																		title: 'Primary Key',																		
																		key: true,
																		create: false,
																		edit: false,
																		visibility: 'hidden' 
																	},		
																	date: {
																		title: 'Date',
																		type: 'date',
																		displayFormat: 'yy-mm-dd',
																		width: '150px'
																	},																	
																	event: {
																		title: 'Event',																		
																		width: '85%',
																		sorting: false,
																		input: function (data) {
																			if (data.record) {
																				return '<input name="event" maxlength="300" style="width:400px;" value="' + data.record.event + '" />';
																			} else {
																				return '<input name="event" maxlength="300" style="width:400px;" />';
																			}
																		}
																	},																	
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