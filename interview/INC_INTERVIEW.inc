<%

const MODE_VIEW = 0
const MODE_EDIT = 1
const MODE_ANSWER = 2

const STATE_UNP = 0
const STATE_PUB = 1
const STATE_END = 2

const QUESTION_TYPE_TXT = 1
const QUESTION_TYPE_OPT = 2

function SQL_CONSULTA_INTERVIEW(stepID)
	SQL_CONSULTA_INTERVIEW = "SELECT * " & vbCrLf & _
							"FROM T_FTA_METHOD_INTERVIEW " & vbCrLf & _
							"WHERE stepID = " & stepID
end function

function SQL_CONSULTA_INTERVIEW_USER_ROLE(stepID, email)
	SQL_CONSULTA_INTERVIEW_USER_ROLE = "SELECT wsu.role " & vbCrLf & _
										"FROM T_WORKFLOW_STEP_X_USER wsu " & vbCrLf & _
										"WHERE wsu.stepID = " & stepID & vbCrLf & _
										"	AND wsu.email = '" & email & "' "
end function

function SQL_CONSULTA_INTERVIEW_PARTICIPANTS(stepID)
	SQL_CONSULTA_INTERVIEW_PARTICIPANTS = "SELECT u.name, u.email " & vbCrLf & _
											"FROM T_WORKFLOW_STEP_X_USER wsu " & vbCrLf & _
											"	INNER JOIN T_USER u ON u.email = wsu.email " & vbCrLf & _
											"WHERE wsu.stepID = " & stepID & vbCrLf & _
											"	AND wsu.role = 'Interviewee'"
end function

function SQL_CONSULTA_INTERVIEW_QUESTIONS(stepID)
	SQL_CONSULTA_INTERVIEW_QUESTIONS = "SELECT iq.questionID, iq.text AS question, " & vbCrLf & _
										"	ISNULL(io.optionID, -1) AS optionID, ISNULL(io.text, '') AS optionText " & vbCrLf & _
										"FROM T_FTA_METHOD_INTERVIEW i " & vbCrLf & _
										"	INNER JOIN T_FTA_METHOD_INTERVIEW_QUESTION iq ON iq.interviewID = i.stepID " & vbCrLf & _
										"	LEFT JOIN T_FTA_METHOD_INTERVIEW_OPTION io ON io.questionID = iq.questionID " & vbCrLf & _
										"WHERE i.stepID = " & stepID & vbCrLf & _
										"ORDER BY iq.questionID, io.optionID"
end function

function SQL_CONSULTA_INTERVIEW_TEXT_ANSWERS(stepID)
	SQL_CONSULTA_INTERVIEW_TEXT_ANSWERS = "SELECT iq.questionID, iq.text AS question, ISNULL(ita.text, '') AS textAnswer, " & vbCrLf & _
												"FROM T_FTA_METHOD_INTERVIEW i " & vbCrLf & _
												"	INNER JOIN T_FTA_METHOD_INTERVIEW_QUESTION iq ON iq.interviewID = i.stepID " & vbCrLf & _
												"	INNER JOIN T_FTA_METHOD_INTERVIEW_TEXT_ANSWER ita ON ita.questionID = iq.questionID" & vbCrLf & _
												"WHERE i.stepID = " & stepID & vbCrLf & _
												"ORDER BY iq.questionID, ita.participant"
end function

function SQL_CONSULTA_INTERVIEW_OPTION_ANSWERS(stepID)
	SQL_CONSULTA_INTERVIEW_OPTION_ANSWERS = "SELECT iq.questionID, iq.text AS question, " & vbCrLf & _
												"	io.optionID AS optionID, io.text AS optionText, ISNULL(ioa.optionID, -1) AS optionAnswer " & vbCrLf & _
												"FROM T_FTA_METHOD_INTERVIEW i " & vbCrLf & _
												"	INNER JOIN T_FTA_METHOD_INTERVIEW_QUESTION iq ON iq.interviewID = i.stepID " & vbCrLf & _
												"	INNER JOIN T_FTA_METHOD_INTERVIEW_OPTION do ON io.questionID = iq.questionID " & vbCrLf & _
												"	INNER JOIN T_FTA_METHOD_INTERVIEW_OPTION_ANSWER ioa ON ioa.optionID = io.optionID " & vbCrLf & _
												"WHERE i.stepID = " & stepID & vbCrLf & _
												"ORDER BY iq.questionID, ioa.optionID, ioa.participant"
end function

function SQL_CONSULTA_INTERVIEW_ANSWERS(stepID)
	SQL_CONSULTA_INTERVIEW_ANSWERS = "SELECT t.* FROM (" & vbCrLf & _
										"	SELECT iq1.questionID, iq1.text AS question, ISNULL(ita.text, '') AS textAnswer, " & vbCrLf & _
										"		-1 AS optionID, '' AS optionText, ISNULL(u.name, '') AS participant " & vbCrLf & _
										"	FROM T_FTA_METHOD_INTERVIEW i " & vbCrLf & _
										"		INNER JOIN T_FTA_METHOD_INTERVIEW_QUESTION iq1 ON iq1.interviewID = i.stepID " & vbCrLf & _
										"		LEFT JOIN T_FTA_METHOD_INTERVIEW_TEXT_ANSWER ita ON ita.questionID = iq1.questionID " & vbCrLf & _
										"		LEFT JOIN T_USER u ON u.email = ita.participant " & vbCrLf & _
										"	WHERE i.stepID = " & stepID & vbCrLf & _
										"		AND iq1.questionID NOT IN (SELECT DISTINCT iq3.questionID " & vbCrLf & _
										"									FROM T_FTA_METHOD_INTERVIEW i " & vbCrLf & _
										"										INNER JOIN T_FTA_METHOD_INTERVIEW_QUESTION iq3 ON iq3.interviewID = i.stepID " & vbCrLf & _ 
										"										INNER JOIN T_FTA_METHOD_INTERVIEW_OPTION io ON io.questionID = iq3.questionID " & vbCrLf & _
										"									WHERE i.stepID = " & stepID & ") " & vbCrLf & _
										"	UNION " & vbCrLf & _
										"	SELECT iq2.questionID, iq2.text AS question, '' AS textAnswer, " & vbCrLf & _
										"		io.optionID AS optionID, io.text AS optionText, ISNULL(u.name, '') AS participant " & vbCrLf & _
										"	FROM T_FTA_METHOD_INTERVIEW i " & vbCrLf & _
										"		INNER JOIN T_FTA_METHOD_INTERVIEW_QUESTION iq2 ON iq2.interviewID = i.stepID " & vbCrLf & _
										"		INNER JOIN T_FTA_METHOD_INTERVIEW_OPTION io ON io.questionID = iq2.questionID " & vbCrLf & _
										"		LEFT JOIN T_FTA_METHOD_INTERVIEW_OPTION_ANSWER ioa ON ioa.optionID = io.optionID " & vbCrLf & _
										"		LEFT JOIN T_USER u ON u.email = ioa.participant " & vbCrLf & _
										"	WHERE i.stepID = " & stepID & ") t " & vbCrLf & _
										"ORDER BY t.questionID, t.optionID, t.participant"
end function

function SQL_CONSULTA_INTERVIEW_PARTICIPANT_ANSWERS(stepID, participant)
	SQL_CONSULTA_INTERVIEW_PARTICIPANT_ANSWERS = "SELECT t.* FROM (" & vbCrLf & _
													"	SELECT iq1.questionID, iq1.text AS question, ISNULL(ita.text, '') AS textAnswer, " & vbCrLf & _ 
													"		-1 AS optionID, '' AS optionText, -1 AS optionAnswer, ISNULL(u.name, '') AS participant " & vbCrLf & _
													"	FROM T_FTA_METHOD_INTERVIEW i " & vbCrLf & _
													"		INNER JOIN T_FTA_METHOD_INTERVIEW_QUESTION iq1 ON iq1.interviewID = i.stepID " & vbCrLf & _
													"		LEFT JOIN T_FTA_METHOD_INTERVIEW_TEXT_ANSWER ita ON ita.questionID = iq1.questionID AND ita.participant = '" & participant & "' " & vbCrLf & _
													"		LEFT JOIN T_USER u ON u.email = ita.participant " & vbCrLf & _
													"	WHERE i.stepID = " & stepID & vbCrLf & _
													"		AND iq1.questionID NOT IN (SELECT DISTINCT iq3.questionID " & vbCrLf & _
													"									FROM T_FTA_METHOD_INTERVIEW i " & vbCrLf & _
													"										INNER JOIN T_FTA_METHOD_INTERVIEW_QUESTION iq3 ON iq3.interviewID = i.stepID " & vbCrLf & _ 
													"										INNER JOIN T_FTA_METHOD_INTERVIEW_OPTION io ON io.questionID = iq3.questionID " & vbCrLf & _
													"									WHERE i.stepID = " & stepID & ") " & vbCrLf & _
													"	UNION " & vbCrLf & _
													"	SELECT iq2.questionID, iq2.text AS question, '' AS textAnswer, " & vbCrLf & _
													"		io.optionID AS optionID, io.text AS optionText, ISNULL(ioa.optionID, -1) AS optionAnswer, ISNULL(u.name, '') AS participant " & vbCrLf & _
													"	FROM T_FTA_METHOD_INTERVIEW i " & vbCrLf & _
													"		INNER JOIN T_FTA_METHOD_INTERVIEW_QUESTION iq2 ON iq2.interviewID = i.stepID " & vbCrLf & _
													"		INNER JOIN T_FTA_METHOD_INTERVIEW_OPTION io ON io.questionID = iq2.questionID " & vbCrLf & _
													"		LEFT JOIN T_FTA_METHOD_INTERVIEW_OPTION_ANSWER ioa ON ioa.optionID = io.optionID AND ioa.participant = '" & participant & "' " & vbCrLf & _
													"		LEFT JOIN T_USER u ON u.email = ioa.participant " & vbCrLf & _
													"	WHERE i.stepID = " & stepID & ") t " & vbCrLf & _
													"ORDER BY t.questionID, t.optionID"
end function

function SQL_CONSULTA_INTERVIEW_TEXT_ANSWER(questionID, participant)
	SQL_CONSULTA_INTERVIEW_TEXT_ANSWER = "SELECT * " & vbCrLf & _
										"FROM T_FTA_METHOD_INTERVIEW_TEXT_ANSWER " & vbCrLf & _
										"WHERE questionID = " & questionID & vbCrLf & _
										"	AND participant = '" & participant & "'"
end function

function SQL_ATUALIZA_INTERVIEW(stepID, text)
	SQL_ATUALIZA_INTERVIEW = "UPDATE T_FTA_METHOD_INTERVIEW SET " & vbCrLf & _
							"text = '" & text & "' "& vbCrLf & _
							"WHERE stepID = " & stepID
end function

function SQL_ATUALIZA_INTERVIEW_STATE(stepID, state)
	SQL_ATUALIZA_INTERVIEW_STATE = "UPDATE T_FTA_METHOD_INTERVIEW SET " & vbCrLf & _
							"state = '" & state & "' "& vbCrLf & _
							"WHERE stepID = " & stepID
end function

function SQL_ATUALIZA_INTERVIEW_QUESTION(questionID, text)
	SQL_ATUALIZA_INTERVIEW_QUESTION = "UPDATE T_FTA_METHOD_INTERVIEW_QUESTION SET " & vbCrLf & _
									"text = '" & text & "' "& vbCrLf & _
									"WHERE questionID = " & questionID
end function

function SQL_ATUALIZA_INTERVIEW_OPTION(optionID, text)
	SQL_ATUALIZA_INTERVIEW_OPTION = "UPDATE T_FTA_METHOD_INTERVIEW_OPTION SET " & vbCrLf & _
									"text = '" & text & "' "& vbCrLf & _
									"WHERE optionID = " & optionID
end function

function SQL_ATUALIZA_INTERVIEW_TEXT_ANSWER(questionID, participant, text)
	SQL_ATUALIZA_INTERVIEW_TEXT_ANSWER = "UPDATE T_FTA_METHOD_INTERVIEW_TEXT_ANSWER SET " & vbCrLf & _
										"text = '" & text & "' "& vbCrLf & _
										"WHERE questionID = " & questionID & vbCrLf & _
										"	AND participant = '" & participant & "'"
end function

function SQL_ATUALIZA_INTERVIEW_OPTION_ANSWER(questionID, participant, optionID)
	SQL_ATUALIZA_INTERVIEW_OPTION_ANSWER = "UPDATE T_FTA_METHOD_INTERVIEW_OPTION_ANSWER SET " & vbCrLf & _
											"optionID = " & optionID & vbCrLf & _
											"WHERE questionID = " & questionID & vbCrLf & _
											"	AND participant = '" & participant & "'"
end function

function SQL_EXCLUI_INTERVIEW_QUESTION(questionID)
	SQL_EXCLUI_INTERVIEW_QUESTION = "DELETE T_FTA_METHOD_INTERVIEW_QUESTION " & vbCrLf & _
								"WHERE questionID = " & questionID
end function

function SQL_EXCLUI_INTERVIEW_OPTION(optionID)
	SQL_EXCLUI_INTERVIEW_OPTION = "DELETE T_FTA_METHOD_INTERVIEW_OPTION " & vbCrLf & _
								"WHERE optionID = " & optionID
end function

function SQL_EXCLUI_INTERVIEW_TEXT_ANSWER(questionID, participant)
	SQL_EXCLUI_INTERVIEW_TEXT_ANSWER = "DELETE T_FTA_METHOD_INTERVIEW_TEXT_ANSWER " & vbCrLf & _
									"WHERE questionID = " & questionID & vbCrLf & _
									"	AND participant = '" & participant & "'"
end function

function SQL_EXCLUI_INTERVIEW_OPTION_ANSWER(optionID, participant)
	SQL_EXCLUI_INTERVIEW_OPTION_ANSWER = "DELETE T_FTA_METHOD_INTERVIEW_TEXT_ANSWER " & vbCrLf & _
										"WHERE optionID = " & optionID & vbCrLf & _
										"	AND participant = '" & participant & "'"
end function

function SQL_CRIA_INTERVIEW(stepID)
	SQL_CRIA_INTERVIEW = "INSERT INTO T_FTA_METHOD_INTERVIEW (stepID, state) " & vbCrLf & _
						"VALUES (" & stepID & ", " & cstr(STATE_UNP) & ") "
end function

function SQL_CRIA_INTERVIEW_TEXT_ANSWER(questionID, participant, text)
	SQL_CRIA_INTERVIEW_TEXT_ANSWER = "INSERT INTO T_FTA_METHOD_INTERVIEW_TEXT_ANSWER (questionID, participant, text) " & vbCrLf & _
									"VALUES (" & questionID & ", '" & participant & "', '" & text & "')"
end function

function SQL_CRIA_INTERVIEW_OPTION_ANSWER(questionID, participant, optionID)
	SQL_CRIA_INTERVIEW_OPTION_ANSWER = "INSERT INTO T_FTA_METHOD_INTERVIEW_OPTION_ANSWER (questionID, participant, optionID) " & vbCrLf & _
									"VALUES (" & questionID & ", '" & participant & "', " & optionID & ")"
end function

Sub printAllQuestions(stepID, mode)
	Dim rs
	Dim question(2)
	Dim i, isOption
	Dim html, questionID, questionIDAnt, questionText, optionID, optionText
	
	Call getRecordSet(SQL_CONSULTA_INTERVIEW_QUESTIONS(stepID), rs)
	
	i = 1
	j = 1
	
	If rs.EOF Then
		'
	Else
		'html = "<div id=""interview-questions"">"
		questionID = rs("questionID")
		
		While Not rs.EOF
			questionText = rs("question")
			
			questionIDAnt = questionID
				
			html = html & "<div id=""" & questionID & """ class=""question-container"">"
			html = html & "<input type=""hidden"" name=""questionID[]"" value=""" & questionID & """ />"
			html = html & "<input type=""hidden"" name=""operation[]"" value=""0"" />"
			html = html & "<div class=""question-header""><span>Question #" & i & "</span>"
			'If mode = MODE_EDIT Then
				html = html & "<span class=""toggle-question"">[-]</span>"
			'End If
			html = html & "</div>"
			html = html & "<div class=""question-content"">"
			html = html & "<p class=""question-text"">"
			If questionText <> "" Then
				html = html & replace(questionText, vbCrLf, "<br />")
			End If
			html = html & "</p>"
			
			j = 1
			Do While Clng(questionIDAnt) = Clng(questionID)
				optionID = rs("optionID")
				optionText = trim(rs("optionText"))
				
				If Clng(optionID) > -1 Then
					If j = 1 Then
						html = html & "<div class=""question-option-container"">"
					End If
					
					html = html & "<div class=""question-option"">"
					html = html & "<input type=""hidden"" name=""optionID[]"" class=""question-option-id"" value=""" & optionID & """ />"
					html = html & "<span>Option #" & j & ": </span><span class=""question-option-text"">" & optionText & "</span>"
					html = html & "</div>"
					
					isOption = True
				Else
					isOption = False
				End If
				
				rs.moveNext()
				
				If rs.EOF Then
					Exit Do	
				End If
				
				questionID = rs("questionID")
				j = j + 1
			Loop
			
			If isOption Then
				html = html & "</div>"
			End If
			
			If mode = MODE_EDIT Then
				html = html & "<div class=""buttons-container"">"
				html = html & "<button class=""TIAMATButton edit-question"">Edit</button>"
				html = html & "<button class=""TIAMATButton delete-question"">Delete</button>"
				html = html & "</div>"
			End If
			
			html = html & "</div>"
			html = html & "</div>"
			
			If Not rs.EOF Then
				'rs.moveNext()
			End If
			
			i = i + 1
		Wend
		
		'html = html & "</div>"
		
		response.write(html)
	End If
End Sub

Sub printAllParticipantAnswersAndQuestions(stepID, editMode)
	Dim rs
	Dim question(2)
	Dim i, isOption, hasAnswer
	Dim html, questionID, questionIDAnt, questionText, optionID, optionText, optionAnswer
	
	Call getRecordSet(SQL_CONSULTA_INTERVIEW_PARTICIPANT_ANSWERS(stepID, Session("email")), rs)
	
	i = 1
	j = 1
	hasAnswer = False
	
	If rs.EOF Then
		'
	Else
		'html = "<div id=""interview-questions"">"
		questionID = rs("questionID")
		
		While Not rs.EOF
			questionText = rs("question")
			
			questionIDAnt = questionID
			
			html = html & "<div id=""" & questionID & """ class=""question-container"">"
			html = html & "<input type=""hidden"" name=""questionID[]"" value=""" & questionID & """ />"
			'html = html & "<input type=""hidden"" name=""operation[]"" value=""0"" />"
			html = html & "<div class=""question-header""><span>Question #" & i & "</span>"
			'If mode = MODE_EDIT Then
				html = html & "<span class=""toggle-question"">[-]</span>"
			'End If
			html = html & "</div>"
			html = html & "<div class=""question-content"">"
			html = html & "<p class=""question-text"">"
			If questionText <> "" Then
				html = html & replace(questionText, vbCrLf, "<br />")
			End If
			html = html & "</p>"
			
			j = 1
			hasAnswer = False
			Do While Clng(questionIDAnt) = Clng(questionID)
				optionID = rs("optionID")
				optionText = rs("optionText")
				textAnswer = rs("textAnswer")
				optionAnswer = rs("optionAnswer")
				
				If Clng(optionID) > -1 Then
					If j = 1 Then
						html = html & "<input type=""hidden"" name=""questionType[]"" value=""" & QUESTION_TYPE_OPT & """ />"
						html = html & "<div class=""question-option-container"">"
					End If
					
					html = html & "<div class=""question-option"">"
					
					If mode = MODE_ANSWER Then
						If Clng(optionAnswer) > -1 Then
							html = html & "<input type=""radio"" name=""optionAnswer[" & i & "]"" id=""option-" & i & "-" & j & """ class=""question-option-id"" value=""" & optionID & """ checked=""checked"" />"
							hasAnswer = True
						Else
							html = html & "<input type=""radio"" name=""optionAnswer[" & i & "]"" id=""option-" & i & "-" & j & """ class=""question-option-id"" value=""" & optionID & """ />"
						End If
						
						html = html & "<label for=""option-" & i & "-" & j & """ class=""question-option-text"">" & optionText & "</label>"
					Else
						If Clng(optionAnswer) > -1 Then
							html = html & "<input type=""radio"" class=""question-option-id"" value=""" & optionID & """ checked=""checked"" />"
						Else
							html = html & "<input type=""radio"" class=""question-option-id"" value=""" & optionID & """ />"
						End If
						
						html = html & "<label class=""question-option-text"">" & optionText & "</label>"
					End If
					
					html = html & "</div>"
					
					isOption = True
				Else
					If mode = MODE_ANSWER Then
						html = html & "<textarea name=""textAnswer[" & i & "]"">" & textAnswer & "</textarea>"
						html = html & "<input type=""hidden"" name=""operation[]"" value=""2"" />"
						html = html & "<input type=""hidden"" name=""questionType[]"" value=""" & QUESTION_TYPE_TXT & """ />"
					Else
						html = html & "<textarea disabled=""disabled"">" & textAnswer & "</textarea>"
					End If
					
					isOption = False
				End If
				
				rs.moveNext()
				
				If rs.EOF Then
					Exit Do	
				End If
				
				questionID = rs("questionID")
				j = j + 1
			Loop
			
			If isOption Then
				If hasAnswer Then
					html = html & "<input type=""hidden"" name=""operation[]"" value=""2"" />"
				Else
					html = html & "<input type=""hidden"" name=""operation[]"" value=""1"" />"
				End If
				html = html & "</div>"
			End If
			
			If mode = MODE_EDIT Then
				html = html & "<div class=""buttons-container"">"
				html = html & "<button class=""TIAMATButton edit-question"">Edit</button>"
				html = html & "<button class=""TIAMATButton delete-question"">Delete</button>"
				html = html & "</div>"
			End If
			
			html = html & "</div>"
			html = html & "</div>"
			
			If Not rs.EOF Then
				'rs.moveNext()
			End If
			
			i = i + 1
		Wend
		
		'html = html & "</div>"
		
		response.write(html)
	End If
End Sub

Sub printAllParticipantAnswers(stepID, email)
	Dim rs
	Dim question(2)
	Dim i, isOption, hasAnswer
	Dim html, questionID, questionIDAnt, questionText, optionID, optionText, optionAnswer, participant
	
	Call getRecordSet(SQL_CONSULTA_INTERVIEW_PARTICIPANT_ANSWERS(stepID, email), rs)
	
	i = 1
	j = 1
	
	If rs.EOF Then
		'
	Else
		'html = "<div id=""interview-questions"">"
		questionID = Clng(rs("questionID"))
		
		While Not rs.EOF
			questionText = trim(rs("question"))
			
			questionIDAnt = questionID
			
			html = html & "<div id=""" & questionID & """ class=""question-container"">"
			html = html & "<div class=""question-header""><span>Question #" & i & "</span>"
			'If mode = MODE_EDIT Then
				html = html & "<span class=""toggle-question"">[-]</span>"
			'End If
			html = html & "</div>"
			html = html & "<div class=""question-content"">"
			html = html & "<p class=""question-text"">" & replace(questionText, vbCrLf, "<br />") & "</p>"
			
			j = 1
			optionHTML = ""
			Do While questionIDAnt = questionID
				optionID = Clng(rs("optionID"))
				optionIDAnt = optionID
				textAnswer = trim(rs("textAnswer"))
				
				If optionID > -1 Then
					participant = trim(rs("participant"))
					optionText = trim(rs("optionText"))
					
					If participant <> "" Then
						html = html & "<div class=""question-text-answers"">"
						html = html & "<div class=""question-text-answer-container"">"
						html = html & "<label>Answer of " & participant & "</label>"
						html = html & "<p class=""question-text-answer"">" & replace(optionText, vbCrLf, "<br />") & "</p>"
						html = html & "</div>"
						html = html & "</div>"
					End If
				Else
					participant = trim(rs("participant"))
					textAnswer = replace(textAnswer, vbCrLf, "<br />")
					
					If participant <> "" And textAnswer <> "" Then
						html = html & "<div class=""question-text-answers"">"
						html = html & "<div class=""question-text-answer-container"">"
						html = html & "<label>Answer of " & participant & "</label>"
						html = html & "<p class=""question-text-answer"">" & replace(textAnswer, vbCrLf, "<br />") & "</p>"
						html = html & "</div>"
						html = html & "</div>"
					End If
				End If
				
				If Not rs.EOF Then
					rs.moveNext()
				End If
				
				If rs.EOF Then
					Exit Do	
				End If
				
				questionID = Clng(rs("questionID"))
				j = j + 1
			Loop
			
			html = html & "</div>"
			html = html & "</div>"
			html = html & "</div>"
			
			If Not rs.EOF Then
				'rs.moveNext()
			End If
			
			i = i + 1
		Wend
		
		'html = html & "</div>"
		
		response.write(html)
	End If
End Sub

Sub printAllStatistics(stepID)
	Dim rs
	Dim question(2)
	Dim i
	Dim html, questionID, questionIDAnt, questionText, optionID, optionText, numAnswers, participant, optionIDAnt
	Dim optionHTML
	
	Call getRecordSet(SQL_CONSULTA_INTERVIEW_ANSWERS(stepID), rs)
	
	i = 1
	j = 1
	
	If rs.EOF Then
		'
	Else
		'html = "<div id=""interview-questions"">"
		questionID = Clng(rs("questionID"))
		
		While Not rs.EOF
			questionText = trim(rs("question"))
			
			questionIDAnt = questionID
			
			html = html & "<div id=""" & questionID & """ class=""question-container"">"
			html = html & "<div class=""question-header""><span>Question #" & i & "</span>"
			'If mode = MODE_EDIT Then
				html = html & "<span class=""toggle-question"">[-]</span>"
			'End If
			html = html & "</div>"
			html = html & "<div class=""question-content"">"
			html = html & "<p class=""question-text"">" & replace(questionText, vbCrLf, "<br />") & "</p>"
			
			j = 1
			optionHTML = ""
			numAnswers = 0
			Do While questionIDAnt = questionID
				optionID = Clng(rs("optionID"))
				optionIDAnt = optionID
				textAnswer = trim(rs("textAnswer"))
				
				If optionID > -1 Then
					Do While optionIDAnt = optionID
						participant = trim(rs("participant"))
						optionText = trim(rs("optionText"))
						
						If participant <> "" Then
							numAnswers = numAnswers + 1
							
							optionHTML = optionHTML & "<div class=""question-text-answer-container"">"
							optionHTML = optionHTML & "<label>Answer of " & participant & "</label>"
							optionHTML = optionHTML & "<p class=""question-text-answer"">" & replace(optionText, vbCrLf, "<br />") & "</p>"
							optionHTML = optionHTML & "</div>"
						End If
						
						rs.moveNext()
						
						If rs.EOF Then
							Exit Do	
						End If
						
						optionID = Clng(rs("optionID"))
						If optionID = -1 Then
							rs.movePrevious()
						End If
					Loop
					
					If j = 1 Then
						html = html & "<div class=""question-chart-container"" id=""chart-" & j & """></div>"
						html = html & "<div class=""question-chart-data-container"">"
					End If
					
					html = html & "<div class=""question-chart-data"">"
					html = html & "<input type=""hidden"" class=""question-option-id"" value=""" & optionID & """ />"
					html = html & "<input type=""hidden"" class=""question-option-text"" value=""" & optionText & """ />"
					html = html & "<input type=""hidden"" class=""question-option-numanswers"" value=""" & numAnswers & """ />"
					html = html & "</div>"
				Else
					If j = 1 Then
						html = html & "<div class=""question-text-answers"">"
					End If
					
					participant = trim(rs("participant"))
					textAnswer = replace(textAnswer, vbCrLf, "<br />")
					
					If textAnswer <> "" Then
						html = html & "<div class=""question-text-answer-container"">"
						html = html & "<label>Answer of " & participant & "</label>"
						html = html & "<p class=""question-text-answer"">" & replace(textAnswer, vbCrLf, "<br />") & "</p>"
						html = html & "</div>"
					End If
				End If
				
				numAnswers = 0
				
				If Not rs.EOF And optionID = -1 Then
					rs.moveNext()
				End If
				
				If rs.EOF Then
					Exit Do	
				End If
				
				questionID = Clng(rs("questionID"))
				j = j + 1
			Loop
			
			html = html & "</div>"
			
			If optionHTML <> "" Then
				html = html & "<div class=""question-text-answers"">"
				html = html & optionHTML
				html = html & "</div>"
			End If
			
			html = html & "</div>"
			html = html & "</div>"
			
			If Not rs.EOF Then
				'rs.moveNext()
			End If
			
			i = i + 1
		Wend
		
		'html = html & "</div>"
		
		response.write(html)
	End If
End Sub

Function getRole(stepID, email)
	Dim rs
	
	getRole = ""
	
	Call getRecordSet(SQL_CONSULTA_INTERVIEW_USER_ROLE(stepID, email), rs)
	
	If Not rs.EOF Then
		getRole = rs("role")
	End If
	
End Function

%>