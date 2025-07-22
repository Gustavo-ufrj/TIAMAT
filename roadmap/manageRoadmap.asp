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
									<form action="roadmapActions.asp?action=save" method="POST">
										<table width=1184 class="padded">

											<!-- INICIO AREA EDITAVEL -->
							<%
											disabled = ""
											action = ""
											
											if getStatusStep(request.querystring("stepID")) = STATE_ACTIVE then 
												if isempty(request.querystring("roadmapID")) then
													action = "Manage"
												end if
											else 
												disabled = "disabled"
												action = ""
											end if													
							%>
											<tr>
												<td>
													<p class="font_6" align="justify"><%=ucase(action)%> ROADMAP <font color="red">//</font></p>							
												</td>
											</tr>
											<tr>
												<td>
												<hr class="linhaDupla">
												</td>
											</tr>
												<%
												Dim description,title, exhibition
													description=""
													title=""
													exhibition =0
												Dim showCancel
												showCancel = true
												if not isempty(request.querystring("stepID")) then
																										
												
													call getRecordSet (SQL_CONSULTA_ROADMAP(request.querystring("stepID")), rs)
													
													if not rs.eof then																							
														description=rs("description")
														title=rs("title")
														exhibition=rs("exhibition")
														else
														showCancel = false
													end if
												end if
												%>
											<tr>
												<td>
													<table width=100% class="padded">
														<tr>
															<td width="10%" align="right" class="padded" >														
															Title:
															</td>
															<td width="90%" class="padded">
															<input id="title" type="text" name="title" maxlength="100" style="width:100%"  value="<%=title%>" <%=disabled%>>
															</td>
														</tr>
														<tr>
															<td width="10%" align="right" class="padded" >														
															Description:
															</td>
															<td width="90%" class="padded">
															<textarea id="description" name="description" maxlength="500" style="width:100%"  <%=disabled%>><%=description%></textarea>
															</td>
														</tr>
														<tr>
															<td width="10%" align="right" class="padded" >														
															Exhibition Format:
															</td>
															<td width="90%" class="padded">
															<select name="exhibition">
															<option value=0 <%if exhibition = 0 then response.write "selected" %> >Year</option>
															<option value=1 <%if exhibition = 1 then response.write "selected" %> >Month and Year</option>
															<option value=2 <%if exhibition = 2 then response.write "selected" %> >Day, Month and Year</option>
															</select>
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
											<tr>
												<td align=center>
												<input type=hidden name="roadmapID" value="<%=request.querystring("roadmapID")%>" />
												<input type=hidden name="stepID" value="<%=request.querystring("stepID")%>" />
												<% if getStatusStep(request.querystring("stepID")) = STATE_ACTIVE then %>
													<% if showCancel then %>
													<button class="TIAMATButton" onclick="window.location.href = './index.asp?stepID=<%=request.querystring("stepID")%>';return false;">Cancel</button>
													<%end if%>
												<button class="TIAMATButton" onclick="return validateForm();";>Save</button>
												<%else%>
												<button class="TIAMATButton" onclick="window.location.href = './index.asp?stepID=<%=request.querystring("stepID")%>';return false;">Back</button>
												<%end if%>
												</td>
											
											<script>

											function validateForm(){
											var message = "";
												if ($.trim($("#description").val())=="") {
														message = message + "- Please inform the roadmap description.\n";
												}
												if ($.trim($("#title").val())=="") {
													message = message + "- Please inform the roadmap title.\n";
												}
												if (message!="") {
													alert("The roadmap could not be saved due:\n"+message);
												}
												return message=="";
											}
											
											</script>

											<!-- FIM AREA EDITAVEL -->
											</tr>
										</table>
										</form>
									</td>
									<td width=20px>
									&nbsp;&nbsp;&nbsp;
									</td>
								</tr>
							</table>
<%
render.renderFooter()
%>
