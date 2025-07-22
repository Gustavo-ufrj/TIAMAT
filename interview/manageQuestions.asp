<!--#include virtual="/system.asp"-->
<!--#include virtual="/checkstep.asp"-->
<!--#include file="INC_INTERVIEW.inc"-->

<%
saveCurrentURL

Dim rs
Dim stepID
Dim state
Dim role

state = -1
mode = MODE_EDIT

If request.querystring("stepID") <> "" Then
	stepID = request.querystring("stepID")
	
	role = getRole(stepID, Session("email"))

	If role <> "Interviewer" Then
		Session("interviewError") = "You are not an interview coordinator."
		response.redirect "index.asp?stepID=" & stepID & "&redirect=1"
	End If
	
	Call getRecordSet (SQL_CONSULTA_INTERVIEW(stepID), rs)
	
	state = Clng(rs("state"))
	
	If state <> STATE_UNP Then
		Session("interviewError") = "This interview has been published or ended. It is not possible to edit it anymore."
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
	<input type="hidden" id="question-id" value="" />
	<input type="hidden" id="operation" value="" />
	<input type="hidden" id="template" value="" />
	
	<div id="tiamat-popup-header">
		<span id="tiamat-popup-header-text">Add new record</span>
	</div>
	<div id="tiamat-popup-content">
		<div id="tiamat-popup-fields-container">
			<div class="tiamat-popup-field tiamat-popup-field-last" id="new-question-template-container">
				<select id="new-question-template">
					<option value="none">Select a template</option>
					<option value="textarea">Textarea</option>
					<option value="options">Options</option>
				</select>
			</div>
			<div class="tiamat-popup-field" id="new-question-text-container">
				<label>Question</label>
				<textarea id="new-question-text"></textarea>
			</div>
			<div class="tiamat-popup-field tiamat-popup-field-last">
				<div id="new-question-options-container">
					<div id="new-question-options-content">
						<div class="new-question-option-container">
							<label><span class="new-question-option-titlenumber">Option #1</span><span class="new-question-delete-option">x</span></label>
							<input type="hidden" class="new-question-option-id" value="" />
							<input type="hidden" class="new-question-option-operation" value="" />
							<input type="text" class="new-question-option-text" maxlength="255" value="" />
						</div>
					</div>
					<div id="new-question-option-buttons-container">
						<button id="new-option">New Option</button>
					</div>
				</div>
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
									<form action="interviewActions.asp?action=save_round" method="POST">
										<table width="1184px" class="padded">

											<!-- INICIO AREA EDITAVEL -->
							

											<tr>
												<td>
													<p class="font_6" align="justify">EDIT INTERVIEW QUESTIONS <font color="red">//</font></p>							
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
															response.write("<div id=""interview-questions"">")
															Call printAllQuestions(stepID, mode)
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
													<input type="hidden" name="stepID" value="<%=stepID%>" />
													<input type="hidden" name="state" id="state" value="-1" />
													<button class="TIAMATButton" onclick="window.location.href='index.asp?stepID=<%=stepID%>';return false;">Back</button>
													<button class="TIAMATButton" style="width:150px;" onclick="addQuestion();return false;">Add Question</button>
												</td>

										<!-- FIM AREA EDITAVEL -->

											</tr>
											<tr>
												<td height="60px" valign="middle" align="center" colspan="2" class="padded" >
													<font class="error-msg" color=red><%=Session("interviewQuestionsError")%></font>
													<%
													Session("interviewQuestionsError") = ""
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
If mode = MODE_EDIT Then
%>
<script>
function openQuestionForm(operation, template, questionID) {
	var i = 0;
	var elem = null;
	var text = '';
	var optionID = '';
	var optionText = '';
	
	unbindOptionDeletion();
	$('#new-question-options-container').hide();
	
	if (template === 'textarea' || template === 'options') {
		// Does nothing
	} else if (template === 'none') {
		return;
	} else {
		alert("Please choose a valid template for the new question.");
		return;
	}
	
	if (operation === window.OPER_ADD) {
		if (template === 'options') {
			$('#new-question-options-container').show();
		} else {
			$('.tiamat-popup-field').first().addClass('tiamat-popup-field-last');
		}
		
		clearQuestionForm();
		$('#operation').prop('value', operation);
		$('#tiamat-popup-save').html('Add');
		showTIAMATPopup('Add new record');
	} else if (operation === window.OPER_EDIT) {
		$('#question-id').prop('value', questionID);
		$('#new-question-template-container').hide();
		
		elem = $('#' + questionID);
		
		questionText = elem.find('.question-content p').first()[0].innerHTML;
		$('#new-question-text').val(questionText.replace(/<br>/g, '\n'));
		
		questionOptions = elem.find('.question-content .question-option');
		
		if (questionOptions.length > 0) {
			window.optionNum = questionOptions.length;
			
			for (i = 0; i < questionOptions.length; i++) {
				text += '<div class="new-question-option-container">';
				text += '<label><span class="new-question-option-titlenumber">Option #' + (i + 1) + '</span><span class="new-question-delete-option">x</span></label>';
				
				optionID = $(questionOptions[i]).find('.question-option-id').first()[0].getAttribute('value');
				optionText = $(questionOptions[i]).find('.question-option-text').first()[0].innerHTML;
				
				text += '<input type="hidden" class="new-question-option-operation" value="' + operation + '" />';
				text += '<input type="hidden" class="new-question-option-operation-ant" value="' + operation + '" />';
				text += '<input type="hidden" class="new-question-option-id" value="' + optionID + '" />';
				text += '<input type="text" class="new-question-option-text" maxlength="255" value="' + optionText + '" />';
				text += '</div>';
			}
			
			$('#new-question-options-content').html(text);
			$('#new-question-options-container').show();
		} else {
			$('.tiamat-popup-field').first().addClass('tiamat-popup-field-last');
		}
		
		$('#operation').prop('value', operation);
		$('#tiamat-popup-save').html('Update');
		showTIAMATPopup('Edit record');
	}
	
	bindOptionDeletion();
	$('#new-question-text').focus();
}

function deleteOption() {
	var elem = $(this).parent().parent();
	var operation = parseInt($('#operation').prop('value'));
	var newQuestionOptions = null;
	
	if (operation === window.OPER_ADD) {
		elem.remove();
		window.optionNum--;
		
		newQuestionOptions = $('.new-question-option-container');
		for (i = 0; i < newQuestionOptions.length; i++) {
			$(newQuestionOptions[i]).find('.new-question-option-titlenumber').html('Option #' + (i + 1));
		}
	} else if (operation === window.OPER_EDIT) {
		if (parseInt(elem.find('.new-question-option-operation').prop('value')) === window.OPER_DEL) {
			if (elem.find('.new-question-option-id').prop('value')) {
				elem.find('.new-question-option-operation').prop('value', elem.find('.new-question-option-operation-ant').prop('value'));
			}
			elem.find('.new-question-option-text').css('background-color', "#ffffff");
		} else {
			elem.find('.new-question-option-operation').prop('value', window.OPER_DEL);
			elem.find('.new-question-option-text').css('background-color', "#ffcccc");
		}
	}
}

function unbindOptionDeletion() {
	$('.new-question-delete-option').unbind();
}

function bindOptionDeletion() {
	$('.new-question-delete-option').click(deleteOption);
}

function confirmDeletion(questionID) {
	var result = confirm("Do you really want to delete the question?");
	
	if (result === true) {
		$('#' + questionID + ' input[name="operation[]"]').prop('value', window.OPER_DEL);
		validateSave(window.OPER_DEL);
	}
}

function clearQuestionForm() {
	var text = '';
	
	window.optionNum = 1;
	
	text += '<div class="new-question-option-container">';
	text += '<label><span class="new-question-option-titlenumber">Option #' + window.optionNum + '</span><span class="new-question-delete-option">x</span></label>';
	text += '<input type="hidden" class="new-question-option-operation" value="" />';
	text += '<input type="hidden" class="new-question-option-operation-ant" value="" />';
	text += '<input type="hidden" class="new-question-option-id" value="" />';
	text += '<input type="text" class="new-question-option-text" name="new_option[]" />';
	text += '</div>';
	
	$('#tiamat-popup-header-text').html('Add new record');
	$('#new-question-text').val('');
	$('#question-id').prop('value', '');
	$('#operation').prop('value', '');
	$('#template').prop('value', '');
	$('#new-question-options-content').html(text);
	$('#new-question-text-container').show();
	$('#new-question-template-container').hide();
}

function appendNewOption() {
	var text = '';
	
	unbindOptionDeletion();
	window.optionNum++;
	
	text += '<div class="new-question-option-container">';
	text += '<label><span class="new-question-option-titlenumber">Option #' + window.optionNum + '</span><span class="new-question-delete-option">x</span></label>';
	text += '<input type="hidden" class="new-question-option-operation" value="' + window.OPER_ADD + '" />';
	text += '<input type="hidden" class="new-question-option-operation-ant" value="' + window.OPER_ADD + '" />';
	text += '<input type="hidden" class="new-question-option-id" value="" />';
	text += '<input type="text" class="new-question-option-text" maxlength="255" value="" />';
	text += '</div>';
	
	$('#new-question-options-content').append(text);
	bindOptionDeletion();
}

function validateSave(operation) {
	var roundForm = $('form').first()[0];
	var elem = null;
	var newQuestionOptions = null;
	var text = '';
	var optionID = '';
	var optionText = '';
	var questionText = '';
	var operationOption = '';
	
	var operation = parseInt(operation);
	
	if (operation === window.OPER_DEL) {
		// Does nothing
	} else if (operation === window.OPER_ADD || operation === window.OPER_EDIT) {
		questionText = $('#new-question-text').val();
		
		if (questionText) {
			questionText = questionText.trim();
		}
		
		if (questionText === '') {
			alert("Please inform a question text.");
			$('#new-question-text').focus();
			return;
		}
		
		text += '<input type="hidden" name="operation[]" value="' + operation + '" />';
		text += '<input type="hidden" name="questionID[]" value="' + $('#question-id').prop('value') + '" />';
		text += '<input type="hidden" name="newQuestionText" value="' + questionText + '" />';
		
		elem = $('#new-question-options-content');
		newQuestionOptions = elem.find('.new-question-option-container');
		for (i = 0; i < newQuestionOptions.length; i++) {
			operationOption = $(newQuestionOptions[i]).find('.new-question-option-operation').first()[0].getAttribute('value');
			optionID = $(newQuestionOptions[i]).find('.new-question-option-id').first()[0].getAttribute('value');
			optionText = $(newQuestionOptions[i]).find('.new-question-option-text').first()[0].value.trim();
			
			if (optionText) {
				text += '<input type="hidden" name="operationOption[]" value="' + operationOption + '" />';
				text += '<input type="hidden" name="newOptionID[]" value="' + optionID + '" />';
				text += '<input type="hidden" name="newOptionText[]" value="' + optionText + '" />';
			}
		}
		
		$('#interview-questions').append(text);
	} else {
		alert("Invalid operation when saving record. Please inform the system administrator.");
		return;
	}
	
	roundForm.submit();
	hideTIAMATPopup();
}

function addQuestion() {
	$('#new-question-options-container').hide();
	$('#new-question-text-container').hide();
	$('#new-question-template-container').show();
	showTIAMATPopup('Choose a template question');
}

$(document).ready(function() {
	window.optionNum = 1;
	window.OPER_NO = 0;
	window.OPER_ADD = 1;
	window.OPER_EDIT = 2;
	window.OPER_DEL = 3;
	
	loadTIAMATPopup();
	
	$('#new-question-template').change(function() {
		var elem = $(this);
		
		$('#template').prop('value', elem.prop('value'));
	});
	
	$('.edit-question').click(function() {
		var elem = $(this);
		var question = elem.parent().parent().parent();
		var questionID = $(question.find('input[name="questionID[]"]')[0]).prop('value');
		var type = '';
		
		if (elem.parent().parent().find('input').length > 0) {
			type = "options";
		} else {
			type = 'textarea';
		}
		
		openQuestionForm(window.OPER_EDIT, type, questionID);
		return false;
	});
	
	$('.delete-question').click(function() {
		var elem = $(this).parent().parent().parent();
		var questionID = elem.find('input[name="questionID[]"]').prop('value');
		
		confirmDeletion(questionID);
		return false;
	});
	
	$('#new-option').click(function() {
		appendNewOption();
	});
	
	$('#tiamat-popup-save').click(function() {
		var operation = $('#operation').prop('value');
		var template = $('#template').prop('value');
		
		if (template !== '') {
			openQuestionForm(window.OPER_ADD, template);
		} else {
			validateSave(operation);
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
End If
%>

<%
render.renderFooter()
%>