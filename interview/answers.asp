<!--#include virtual="/system.asp"-->
<!--#include virtual="/checkstep.asp"-->
<!--#include file="INC_INTERVIEW.inc"-->

<%
saveCurrentURL

Dim rs
Dim stepID
Dim state
Dim role
Dim participant

If request.querystring("stepID") <> "" Then
	stepID = request.querystring("stepID")
	participant = request.form("participant")
	
	role = getRole(stepID, Session("email"))

	If role <> "Interviewer" Then
		Session("interviewError") = "You are not an interview coordinator."
		response.redirect "index.asp?stepID=" & stepID & "&redirect=1"
	End If
	
	Call getRecordSet (SQL_CONSULTA_INTERVIEW(stepID), rs)
	
	state = Clng(rs("state"))
	
	If state = STATE_UNP Then
		Session("interviewError") = "This interview has not been published yet. It is not possible to view its answers."
		response.redirect "index.asp?stepID=" & stepID
	End If
End If

tiamat.addCSS("interview.css")
tiamat.addCSS("/js/TIAMATPopup/TIAMATPopup.css")
tiamat.addJS("/js/TIAMATPopup/TIAMATPopup.js")

render.renderTitle()
%>

<div id="tiamat-popup-background"></div>
<div id="tiamat-popup-container">
	<input type="hidden" id="email" value="" />
	
	<div id="tiamat-popup-header">
		<span id="tiamat-popup-header-text">Add new record</span>
	</div>
	<div id="tiamat-popup-content">
		<div id="tiamat-popup-fields-container">
			<div class="tiamat-popup-field tiamat-popup-field-last" id="change-participant-container">
				<select id="change-participant">
					<option value="none">Select a participant</option>
					<%
					Dim name
					
					Call getRecordSet (SQL_CONSULTA_INTERVIEW_PARTICIPANTS(stepID), rs)
					
					Do While Not rs.EOF
						name = trim(rs("name"))
						email = trim(rs("email"))
					%>
					<option value="<%=email%>"><%=name%></option>
					<%
						rs.moveNext()
					Loop
					%>
				</select>
			</div>
		</div>
		
		<div id="tiamat-popup-buttons-container">
			<div id="tiamat-popup-buttons-content">
				<button id="tiamat-popup-cancel">Cancel</button>
				<button id="tiamat-popup-save">Save</button>
			</div>
		</div>
	</div>
</div>


							<table class="principal" width=100%>
								<tr>
									<td width=20px>
										&nbsp;
									</td>
									<td align=center>
										<form action="answers.asp?stepID=<%=stepID%>" method="POST">
										<table width="1184px" class="padded">

											<!-- INICIO AREA EDITAVEL -->
							

											<tr>
												<td>
													<p class="font_6" align="justify">INTERVIEW ANSWERS<font color="red">//</font></p>							
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
														If stepID <> "" And participant <> "" Then
															response.write("<div id=""interview-answers"">")
															Call printAllParticipantAnswers(stepID, participant)
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
													<input type=hidden name="participant" id="participant" value="" />
													<button class="TIAMATButton" onclick="window.location.href='index.asp?stepID=<%=stepID%>';return false;">Back</button>
													<button class="TIAMATButton" style="width:200px;" id="change-participant-button">Change Participant</button>
												</td>

										<!-- FIM AREA EDITAVEL -->

											</tr>
											<tr>
												<td height="60px" valign="middle" align="center" colspan="2" class="padded" >
													<font class="error-msg" color=red><%=Session("interviewAnswersParticipantError")%></font>
													<%
													Session("interviewAnswersParticipantError") = ""
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


<script type="text/javascript">
$(document).ready(function() {
	loadTIAMATPopup();
	
	<%
	If participant = "" Then
	%>
	showTIAMATPopup();
	<%
	End If
	%>
	
	$('#change-participant-button').click(function() {
		showTIAMATPopup();
		return false;
	});
	
	$('#change-participant').change(function() {
		var elem = $(this);
		
		$('#email').prop('value', elem.prop('value'));
	});
	
	$('#tiamat-popup-save').click(function() {
		var email = $('#email').prop('value');
		var form = document.forms[0];
		
		if (email !== '' && form) {
			$('#participant').prop('value', email);
			form.submit();
		}
	});
	
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