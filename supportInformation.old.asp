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
														<p class="font_6" align="justify">WORKFLOW SUPPORTING INFORMATION <font color="red">//</font></p>							
												</td>
											</tr>
											<tr>
												<td>
												<hr class="linhaDupla">
												</td>
											</tr>
											<tr>
												<td>

												
												<table class="metro" width=100%>
												<th class="metro" colspan=3>Workflow Supporting Information</th>
												<tr>
													<td class="metroTitle">File Name</td>
													<td class="metroTitle" style="width:70px;">Actions</td>
												</tr>
												
												
												<%
												
												
												dim rs
												Dim counter
												dim rsTemp
												
												call getRecordset(SQL_CONSULTA_WORKFLOW_SUPPORTING_INFORMATION(Request.queryString("workflowID")),rs)

												while not rs.eof
													counter = 0 							
%>
														<tr>
															<td class="metro<%=cstr(counter)%>">
																<%if rs("filepath") <> "" then%>
																	<a href="/upload/download.asp?FilePath=<%=rs("filepath")%>"><%=getFileName(rs("filepath"))%></a>
																	<%else%>
																	<center><font color="red">No Supporting Information</font></center>
																	<%end if%>
															</td>
															<td class="metro<%=cstr(counter)%>" align=center>
																<a href="#" title="Add Supporting Information" onclick="window.location.href='/upload/upform.asp?numfiles=5&workflowID=<%=rs("workflowID")%>&resize=0&url=<%=getcurrentURL()%>';"><img src="/img/plus.png" height=15 width=auto class="changeOpacity"></a>
																<%if rs("filepath") <> "" then%>
																<a href="workflowActions.asp?action=deleteSI&workflowID=<%=cstr(rs("workflowID"))%>&file=<%=rs("filepath")%>" title="Delete"><img src="/img/delete.png"  height=15 width=auto class="changeOpacity"></a>
																<%end if%>
																
															</td>
														</tr>
													
														<%rs.movenext
														Wend%>
													</table>














												</td>
											</tr>
											<tr>
												<td>
												<hr class="linhaDupla">
												</td>
											</tr>
<!--											<tr>
												<td height=60px align=center>
												  <button class="TIAMATbutton" style="width:300px;" onclick="window.open('/upload/upform.asp?numfiles=5&workflowID=<%=request.queryString("workflowID")%>&resize=0&url=<%=Session("currentURL")%>', 'Upload', 'width=400, height=400');">Add Workflow Support Information</button>
												</td>
											</tr>
											<tr>
												<td>
												<hr class="linhaDupla">
												</td>
											</tr>
-->											<tr>
												<td>
													<p class="font_6" align="justify">STEP SUPPORTING INFORMATION <font color="red">//</font></p>							
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
												

												
												
												call getRecordset(SQL_CONSULTA_WORKFLOW_STEPS(Request.queryString("workflowID")),rsTemp)
												
												if not rsTemp.eof then
												
												%>
												<table class="metro" width=100%>
												<th class="metro" colspan=3>Supporting Information by FTA Step</th>
												<tr>
													<td class="metroTitle" style="width:150px;">FTA Method</td>
													<td class="metroTitle">File Name</td>
													<td class="metroTitle" style="width:70px;">Actions</td>
												</tr>
												<%
												while not rsTemp.eof
												
													call getRecordset(SQL_CONSULTA_WORKFLOW_STEP_SUPPORTING_INFORMATION(cstr(rsTemp("stepID"))),rs)
													
													if rs.eof then
														response.write "No FTA supporting information uploaded."
														
													end if 

													counter = 0
													
													if rs("type") = 0 then
														call getRecordset(SQL_CONSULTA_SUB_WORKFLOW_SUPPORTING_INFORMATION(cstr(rsTemp("stepID"))),rs2)
														
														while not rs2.eof %>
														<tr>
															<td class="metro<%=cstr(counter)%>">
																<%=getFTAMethodNamebyFTAmethodID(cstr(rs("type")))%>
															</td>
															<td class="metro<%=cstr(counter)%>">
																<%if rs2("filepath") <> "" then%>
																	<a href="/upload/download.asp?FilePath=<%=rs2("filepath")%>"><%=getFileName(rs2("filepath"))%></a>
																	<%else%>
																	<center><font color="red">No Supporting Information</font></center>
																	<%end if%>
															</td>
															<td class="metro<%=cstr(counter)%>" align=center>
																<a href="?workflowID=<%=rs2("workflowID")%>" title="Go to FTA Subworkflow"><img src="/img/go.png" height=15 width=auto class="changeOpacity"></a>
																<a href="#" title="Add Supporting Information"  onclick="window.location.href='/upload/upform.asp?numfiles=5&workflowID=<%=rs2("workflowID")%>&resize=0&url=<%=Session("currentURL")%>';"><img src="/img/plus.png" height=15 width=auto class="changeOpacity"></a>
																<%if rs2("filepath") <> "" then%>
																<a href="workflowActions.asp?action=deleteSI&workflowID=<%=cstr(rs2("workflowID"))%>&file=<%=rs2("filepath")%>" title="Delete"><img src="/img/delete.png"  height=15 width=auto class="changeOpacity"></a>
																<%end if%>
																
															</td>
														</tr>
													
														<%rs2.movenext
														Wend

													else
													
														while not rs.eof
														
														 base_folder = getBaseFolderByFTAmethodID(cstr(rs("type")))
														 
														%>
														<tr>
															<td class="metro<%=cstr(counter)%>">
																<%=getFTAMethodNamebyFTAmethodID(cstr(rs("type")))%>
															</td>
															<td class="metro<%=cstr(counter)%>">
																<%if rs("filepath") <> "" then%>
																	<a href="/upload/download.asp?FilePath=<%=rs("filepath")%>"><%=getFileName(rs("filepath"))%></a>
																	<%else%>
																	<center><font color="red">No Supporting Information</font></center>
																	<%end if%>
															</td>
															<td class="metro<%=cstr(counter)%>" align=center>
																<a href="<%=base_folder%>index.asp?stepID=<%=cstr(rs("stepID"))%>" title="Go to FTA Step"><img src="/img/go.png" height=15 width=auto class="changeOpacity"></a>
																<%if rs("filepath") <> "" then%>
																<a href="stepActions.asp?action=deleteSI&stepID=<%=cstr(rs("stepID"))%>&file=<%=rs("filepath")%>" title="Delete"><img src="/img/delete.png"  height=15 width=auto class="changeOpacity"></a>
																<%end if%>
																
															</td>
														</tr>
														<%
														counter = (counter+1) mod 2
														rs.movenext
														wend
													end if
													rsTemp.movenext
												wend
												%>
												</table>
												<%end if %>

										<!-- FIM AREA EDITAVEL -->
												</td>
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