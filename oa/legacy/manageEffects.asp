<!--#include virtual="/system.asp"-->
<!--#include virtual="/checklogin.asp"-->
<!--#include virtual="/checkadmin.asp"-->

<%
saveCurrentURL

tiamat.addCSS("oa.css")

render.renderTitle()
%>

    <style>
  
</style>

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
													<p class="font_6" align="justify">MANAGE EFFECTS <font color="red">//</font></p>
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
																title: 'Effect List',
																paging: false, //Enable paging
																sorting: false, //Enable sorting
																columnResizable: false, //Disable column resizing
																columnSelectable: false, //Disable column selecting
																openChildAsAccordion: true, //Enable this line to show child tables as accordion style
																actions: {
																	listAction: 'effectActions.asp?action=list&OAID=<%=Request.QueryString("OAID")%>',
																	createAction: 'effectActions.asp?action=new&OAID=<%=Request.QueryString("OAID")%>',
																	updateAction: 'effectActions.asp?action=update&OAID=<%=Request.QueryString("OAID")%>',
																	deleteAction: 'effectActions.asp?action=delete&OAID=<%=Request.QueryString("OAID")%>'
																},
																fields: {
																	effectid: {
																		title: 'EffectID',																		
																		key: true,
																		edit: false,
																		visibility: 'hidden' 																		
																	},
																	criterion: {
																		title: 'Criteria',
																		width: '15%',
																		sorting: false,
																		edit: false,
																		create: false,
																		display: function (criterion) {
																			//Create an image that will be used to open child table
																			var $img = $('<center style="cursor:pointer;" onmouseover="this.style.color=\'red\';" onmouseout="this.style.color=\'black\';"> Open Criteria Panel</center>');
																			//Open child table when user clicks the image
																			$img.click(function () {
																				$('#jTableContainer').jtable('openChildTable',
																						$img.closest('tr'),
																						{
																							title: criterion.record.desiredeffect + ' - Criteria List',
																							actions: {
																								listAction: 'criteriaActions.asp?action=list&effectID='+criterion.record.effectid,
																								deleteAction: 'criteriaActions.asp?action=delete',
																								updateAction: 'criteriaActions.asp?action=update',
																								createAction: 'criteriaActions.asp?action=new'
																							},
																							fields: {
																								criteriaid: {
																									key: true,
																									create: false,
																									edit: false,
																									list: false
																								},
																								effectid: {
																									type: 'hidden',
																									defaultValue: criterion.record.effectid
																								},
																								natureofeffect: {
																									title: 'Nature of Effect',
																									width: '30%'
																								},
																								statusquo: {
																									title: 'Status Quo',
																									width: '70%',
																									input: function (data) {
																										if (data.record) {
																											return '<textarea name="statusquo" style="width:300px; height:300px;">' + data.record.statusquo + '</textarea>';
																										} else {
																											return '<textarea name="statusquo" style="width:300px; height:300px;" />';
																										}
																									}
																								}
																							}
																						}, function (data) { //opened handler
																							data.childTable.jtable('load');
																						});
																			});
																			//Return image to show on the person row
																			return $img;
																		}
																	
																	},
																	desiredeffect: {
																		title: 'Desired Effect',
																		width: '85%',
																		input: function (data) {
																			if (data.record) {
																				return '<textarea name="desiredeffect" style="width:400px; height:200px;">' + data.record.desiredeffect + '</textarea>';
																			} else {
																				return '<textarea name="desiredeffect" style="width:400px; height:200px;" />';
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