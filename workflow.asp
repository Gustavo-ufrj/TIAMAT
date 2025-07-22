<!--#include virtual="/system.asp"-->
<!--#include virtual="/checklogin.asp"-->

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
													<p class="font_6" align="justify">WORKFLOW INFORMATION <font color="red">//</font></p>							
												</td>
											</tr>
											<tr>
												<td>
												<hr class="linhaDupla">
												</td>
											</tr>
											<tr>
												<td>
													<form action="workflowActions.asp?action=new" method="POST">
													<table width=100% class="padded">
														<tr>															
															<td align="center" valign="middle" class="padded"> 
															<table class="padded">
																<tr>															
																	<%
																	Dim desc, goal, expResult
																	desc = "Add the FTA description."
																	goal = "Add the FTA Goal"
																	expResult = "Add the FTA Expected Results."
																		if Request.QueryString("workflowID") <> "" then
																			Dim rs
																			
																			call getRecordSet(SQL_CONSULTA_WORKFLOW_ID(Request.QueryString("workflowID")),rs)
																			
																			if not rs.eof then
																			desc = rs("description")
																			goal = rs("goal")
																			expResult = rs("expectedresult")
																			end if 
																		end if
	%>
																		<td class="padded"> 
																			<span class="font_8">Description: </span>
																		</td>
																		<td class="padded"> 
																			<input type="text" name="description" maxlength="80" value="<%=desc%>" />																			
																		</td>
																</tr>
																<tr>
																		<td class="padded"> 
																			<span class="font_8">Goal: </span>
																		</td>
																		<td class="padded"> 
																			<textarea name="goal" rows="4" cols="80"maxlength="500"><%=goal%></textarea>
																		</td>
																</tr>
																<tr>
																		<td class="padded"> 
																			<span class="font_8">Expected Results: </span>
																		</td>
																		<td class="padded"> 
																			<textarea name="expectedresult" rows="4" cols="80" maxlength="500"><%=expResult%></textarea>
																		</td>
																</tr>
																</table>
															</td>
														</tr>
														<tr>
															<td>
															<hr class="linhaDupla">
															</td>
														</tr>
														
														<tr height=60px >
															<td align="center" class="padded">
																<input type="hidden" name="owner" value="<%=Session("email")%>">
																<input type="hidden" name="workflowID" value="<%=Request.QueryString("workflowID")%>">
																<input type="hidden" name="admin" value="<%=Request.QueryString("admin")%>">
															<%if Request.QueryString("workflowID") <> "" then %>
																<button class="TIAMATButton" onclick="parent.window.location.href='manageWorkflow.asp?workflowID=<%=Request.QueryString("workflowID")%>'; return false;"> Back </button> 
															<% end if %>
																<input type="submit" value="Save" class="TIAMATButton">
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