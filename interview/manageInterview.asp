<!--#include virtual="/system.asp"-->
<!--#include virtual="/checkstep.asp"-->
<!--#include file="INC_INTERVIEW.inc"-->

<%
saveCurrentURL

Dim rs
Dim stepID
Dim role

If Request.querystring("stepID") <> "" Then
	stepID = request.querystring("stepID")
	
	role = getRole(stepID, Session("email"))
	
	If role = "Interviewer" Then
		Call getRecordSet (SQL_CONSULTA_INTERVIEW(stepID), rs)

		If rs.EOF Then
			Call ExecuteSQL(SQL_CRIA_INTERVIEW(stepID))
		End If
	Else
		Session("interviewError") = "You are not an interview coordinator."
		response.redirect "index.asp?stepID=" & stepID & "&redirect=1"
	End If
End If

tiamat.addCSS("interview.css")

render.renderTitle()
%>

							<table class="principal" width=100%>
								<tr>
									<td width=20px>
										&nbsp;
									</td>
									<td align=center>
									<form action="interviewActions.asp?action=save" method="POST">
										<table width="1184px" class="padded">

											<!-- INICIO AREA EDITAVEL -->
							

											<tr>
												<td>
													<p class="font_6" align="justify">EDIT INTERVIEW <font color="red">//</font></p>							
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
														If stepID <> "" Then
															Call getRecordSet(SQL_CONSULTA_INTERVIEW(stepID), rs)
															
															response.write("<div id=""interview-info"">")
															response.write("<label class=""description"">Description: </label>")
															
															response.write("<textarea class=""description"" name=""text"">")
															If Not rs.EOF Then
																response.write(rs("text"))
															End If
															response.write("</textarea>")
															
															If Not rs.EOF Then
																state = Clng(rs("state"))
																
																If state = STATE_UNP Or state = STATE_PUB Or state = STATE_END Then
																	response.write("<label class=""description"">Status: </label>")
																	
																	If state = STATE_UNP Then
																		response.write("<p class=""description"">The interview is unpublished. Participants cannot answer it, but you can edit it anytime.</p>")
																	ElseIf state = STATE_PUB Then
																		response.write("<p class=""description"">The interview has already been published. You cannot edit it anymore, but participants can answer it. Its statistics is available for analysis.</p>")
																	ElseIf state = STATE_END Then
																		response.write("<p class=""description"">The interview is already ended.</p>")
																	End If
																End If
															End If
															
															response.write("</div>")
														End If
													%>
												</td>
											</tr>
											<tr>
												<td>
													<hr class="linhaDupla">
												</td>
											</tr>
											<tr>
											
												<td align=center>
													<input type=hidden name="stepID" value="<%=stepID%>" />
													<button class="TIAMATButton" onclick="window.location.href='index.asp?stepID=<%=stepID%>';return false;">Back</button>
													<button class="TIAMATButton">Save</button>
												</td>

										<!-- FIM AREA EDITAVEL -->

											</tr>
											<tr>
												<td height="60px" valign="middle" align="center" colspan="2" class="padded" >
													<font class="error-msg" color=red><%=Session("interviewError")%></font>
													<%
													Session("interviewError") = ""
													%>
												</td>
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