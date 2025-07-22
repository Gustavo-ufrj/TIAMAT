<!--#include virtual="/system.asp"-->
<!--#include virtual="/checkstep.asp"-->
<!--#include file="INC_INTERVIEW.inc"-->

<%
saveCurrentURL

Dim rs
Dim stepID
Dim role
Dim state
Dim text

If request.querystring("stepID") <> "" Then
	stepID = request.querystring("stepID")
	
	Call getRecordSet (SQL_CONSULTA_INTERVIEW(stepID), rs)
	
	role = getRole(stepID, Session("email"))
	
	If rs.EOF And role = "Interviewer" Then
		response.redirect "manageInterview.asp?stepID=" & stepID
	End If
	
	state = Clng(rs("state"))
	text = rs("text")
	
	'If role = "Interviewee" And request.querystring("redirect") = "" Then
	'	If state = STATE_UNP Then
	'		Session("interviewError") = "This interview is not published yet."
	'		response.redirect "index.asp?stepID=" & stepID & "&redirect=1"
	'	Else
	'		response.redirect "answerQuestions.asp?stepID=" & stepID
	'	End If
	'End If
	
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
										<table width="1184px" class="padded">

											<!-- INICIO AREA EDITAVEL -->

											<tr>
												<td>
													<table width=100% height=50px>
														<tr>
															<td>
																<p class="font_6" align="justify">INTERVIEW <font color="red">//</font></p>							
															</td>
															<td align=right>
															<%If role = "Interviewer" Then %>															
																<%if getStatusStep(request.querystring("stepID")) = STATE_ACTIVE then %>
																	<button class="TIAMATButton" style="width:200px;" onclick="window.location.href='/stepsupportInformation.asp?stepID=<%=request.queryString("stepID")%>';">Supporting Information</button>
																	<button class="TIAMATButton" onclick="window.location.href='/workflowActions.asp?action=end&stepID=<%=request.queryString("stepID")%>'">Finish</button>
																<%end if%>
															<%end if%>
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
												<td>
													<%
														If stepID <> "" Then
															'Call getRecordSet(SQL_CONSULTA_INTERVIEW(stepID), rs)
															
															response.write("<div id=""interview-info"">")
															response.write("<label class=""description"">Description: </label>")
															
															response.write("<p class=""description"">")
															'If Not rs.EOF Then
																'If rs("text") <> "" Then
																If text <> "" Then
																	response.write(replace(text, vbCrLf, "<br>"))
																End If
															'End If
															response.write("</p>")
															
															If role = "Interviewer" And (state = STATE_UNP Or state = STATE_PUB Or state = STATE_END) Then
																response.write("<label class=""description"">Status: </label>")
																
																If state = STATE_UNP Then
																	response.write("<p class=""description"">The interview is unpublished. Participants cannot answer it, but you can edit it anytime.</p>")
																ElseIf state = STATE_PUB Then
																	response.write("<p class=""description"">The interview has already been published. You cannot edit it anymore, but participants can answer it. Its statistics is already available for analysis.</p>")
																ElseIf state = STATE_END Then
																	response.write("<p class=""description"">The interview is already ended and you can view its statistics.</p>")
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
												<%
												'Dim rs
												
												'Call getRecordSet(SQL_CONSULTA_STEP_ID(Request.querystring("stepID")), rs)
												
												'If Not rs.EOF Then
												'	If rs("status") <> STATE_CONCLUDED Then
												%>
												<td align=center>
													<input type=hidden name="stepID" value="<%=stepID%>" />
													<%
													If role = "Interviewer" Then
													%>
													<button class="TIAMATButton" style="width:150px;" onclick="window.location.href='manageInterview.asp?stepID=<%=stepID%>'">Manage Interview</button>
														<%
														If state = STATE_UNP Then
														%>
													<button class="TIAMATButton" style="width:200px;" onclick="window.location.href='manageQuestions.asp?stepID=<%=stepID%>'">Manage Questions</button>
														<%
														End If
														%>
														<%
														If state = STATE_PUB Or state = STATE_END Then
														%>
													<button class="TIAMATButton" style="width:150px;" onclick="window.location.href='statistics.asp?stepID=<%=stepID%>'">View Statistics</button>
													<button class="TIAMATButton" style="width:200px;" onclick="window.location.href='answers.asp?stepID=<%=stepID%>'">Answers by Participants</button>
														<%
														End If
														
														If state = STATE_UNP Then
														%>
													<button class="TIAMATButton" style="width:150px;" id="change-state">Start Answering</button>
														<%
														Elseif state = STATE_PUB Then
														%>
													<button class="TIAMATButton" style="width:150px;" id="change-state">End Answering</button>
														<%
														End If
														%>
													<%
													ElseIf role = "Interviewee" Then
													%>
													<button class="TIAMATButton" onclick="window.location.href='/index.asp'">Back</button>
														<%
														If state = STATE_PUB Then
														%>
													<button class="TIAMATButton" style="width:150px;" onclick="window.location.href='answerQuestions.asp?stepID=<%=stepID%>'">Answer Questions</button>
														<%
														End If
														%>
													<%
													End If
													%>
												</td>
												<%
												'	End If
												'End If
												%>

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
									</td>
									<td width=20px>
									&nbsp;&nbsp;&nbsp;
									</td>
								</tr>
							</table>


<script>
$(document).ready(function() {
	<%
	If state = STATE_UNP Or state = STATE_PUB Then
	%>
	$('#change-state').click(function() {
		var result = false;
		
		<%
		If state = STATE_UNP Then
		%>
		result = confirm("When starting answering you will not be able to edit the questions anymore. Confirm start answering?");
		<%
		ElseIf state = STATE_PUB Then
		%>
		result = confirm("When ending answering the participants will not be able to answer the questions anymore. Confirm end answering?");
		<%
		End If
		%>
		
		if (result) {
			window.location.href='interviewActions.asp?action=change_state&stepID=<%=stepID%>';
		}
	});
	<%
	End If
	%>
});

</script>

<%
render.renderFooter()
%>