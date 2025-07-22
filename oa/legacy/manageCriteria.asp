<!--#include virtual="/system.asp"-->
<!--#include virtual="/checklogin.asp"-->
<!--#include virtual="/checkadmin.asp"-->

<%saveCurrentURL

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
													<p class="font_6" align="justify">MANAGE CRITERIA <font color="red">//</font></p>
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
																title: 'Criteria List',
																paging: false, //Enable paging
																sorting: false, //Enable sorting
																columnResizable: false, //Disable column resizing
																columnSelectable: false, //Disable column selecting
																actions: {
																	listAction: 'effectActions.asp?action=list',
																	createAction: 'effectActions.asp?action=new',
																	updateAction: 'effectActions.asp?action=update',
																	deleteAction: 'effectActions.asp?action=delete'
																},
																fields: {
																	criteriaid: {
																		title: 'CriteriaID',																		
																		key: true,
																		edit: false,
																		visibility: 'hidden' 																		
																	},																	
																	effectid: {
																		title: 'Effect',
																		width: '20%',
																		options: ??????:
																	},
																	natureofeffect: {
																		title: 'Nature of Effect',
																		width: '25%'
																	},
																	statusquo: {
																		title: 'Status Quo (Future if nothing is made)',
																		width: '55%'
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