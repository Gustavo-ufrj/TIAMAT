<!--#include virtual="/system.asp"-->
<!--#include virtual="/checkstep.asp"-->
<!--#include file="INC_INTERVIEW.inc"-->

<%
saveCurrentURL

Dim rs
Dim stepID
Dim state
Dim role

Dim text

state = -1
mode = MODE_ANSWER

If request.querystring("stepID") <> "" Then
	stepID = request.querystring("stepID")
	
	role = getRole(stepID, Session("email"))

	If role <> "Interviewee" Then
		Session("indexError") = "You are not an interview participant."
		response.redirect "index.asp?stepID=" & stepID
	End If
	
	Call getRecordSet (SQL_CONSULTA_INTERVIEW(stepID), rs)
	
	state = Clng(rs("state"))
	text = rs("text")
	
	If state <> STATE_PUB Then
		Session("interviewError") = "This interview has not been published yet or it has been ended. It is not possible to answer it."
		mode = MODE_VIEW
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
									<%
									If mode = MODE_ANSWER Then
									%>
									<form action="interviewActions.asp?action=save_answers" method="POST">
									<%
									End If
									%>
										<table width="1184px" class="padded">

											<!-- INICIO AREA EDITAVEL -->
							

											<tr>
												<td>
													<p class="font_6" align="justify">ANSWER INTERVIEW <font color="red">//</font></p>							
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
															response.write("<div id=""interview-info"">")
															response.write("<label class=""description"">Interview description: </label>")
															
															response.write("<p class=""description"">")
															If text <> "" Then
																response.write(replace(text, vbCrLf, "<br>"))
															End If
															response.write("</p>")
															
															response.write("<div id=""interview-questions"">")
															Call printAllParticipantAnswersAndQuestions(stepID, mode)
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
													<button class="TIAMATButton" onclick="window.location.href='index.asp?stepID=<%=stepID%>&redirect=1';return false;">Back</button>
													<%
													If mode = MODE_ANSWER Then
													%>
													<button class="TIAMATButton">Save</button>
													<%
													End If
													%>
												</td>

										<!-- FIM AREA EDITAVEL -->

											</tr>
											<tr>
												<td height="60px" valign="middle" align="center" colspan="2" class="padded" >
													<font class="error-msg" color=red><%=Session("interviewAnswerError")%></font>
													<%
													Session("interviewAnswerError") = ""
													%>
												</td>
											</tr>
										</table>
									<%
									If mode = MODE_ANSWER Then
									%>
									</form>
									<%
									End If
									%>
									</td>
									<td width=20px>
									&nbsp;&nbsp;&nbsp;
									</td>
								</tr>
							</table>
			
<script>
$(document).ready(function() {
	$('.question-header .toggle-question').click(function() {
		var elem = $(this);
		
		elem.parent().parent().find('.question-content').toggle();
		
		if (elem.html() === '[-]') {
			elem.html('[+]');
		} else if (elem.html() === '[+]') {
			elem.html('[-]');
		}
	});
});
</script>

<%
render.renderFooter()
%>