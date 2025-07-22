<!--#include virtual="/system.asp"-->
<!--#include virtual="/checklogin.asp"-->
<!--#include virtual="/checkadmin.asp"-->

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
													<p class="font_6" align="justify">MANAGE OPTIONS <font color="red">//</font></p>
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
																title: 'Option List',
																paging: false, //Enable paging
																sorting: false, //Enable sorting
																columnResizable: false, //Disable column resizing
																columnSelectable: false, //Disable column selecting
																actions: {
																	listAction: 'optionActions.asp?action=list&OAID=<%=Request.QueryString("OAID")%>',
																	createAction: 'optionActions.asp?action=new&OAID=<%=Request.QueryString("OAID")%>',
																	updateAction: 'optionActions.asp?action=update&OAID=<%=Request.QueryString("OAID")%>',
																	deleteAction: 'optionActions.asp?action=delete&OAID=<%=Request.QueryString("OAID")%>'
																},
																fields: {
																	optionid: {
																		title: 'OptionID',																		
																		key: true,
																		edit: false,
																		visibility: 'hidden' 																		
																	},																	
																	name: {
																		title: 'Name',
																		width: '30%'
																	},
																	description: {
																		title: 'Description',
																		width: '70%',
																		input: function (data) {
																			if (data.record) {
																				return '<textarea name="description" style="width:300px; height:200px;">' + data.record.description + '</textarea>';
																			} else {
																				return '<textarea name="description" style="width:300px; height:200px;" />';
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