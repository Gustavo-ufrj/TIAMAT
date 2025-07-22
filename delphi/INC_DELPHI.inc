<%

const MODE_VIEW = 0
const MODE_EDIT = 1
const MODE_ANSWER = 2

const STATE_UNP = 0
const STATE_PUB = 1
const STATE_END = 2

const QUESTION_TYPE_TXT = 1
const QUESTION_TYPE_OPT = 2

function SQL_CONSULTA_DELPHI(stepID)
	SQL_CONSULTA_DELPHI = "SELECT * " & vbCrLf & _
							"FROM T_FTA_METHOD_DELPHI " & vbCrLf & _
							"WHERE stepID = " & stepID
end function

function SQL_CONSULTA_DELPHI_USER_ROLE(stepID, email)
	SQL_CONSULTA_DELPHI_USER_ROLE = "SELECT wsu.role " & vbCrLf & _
										"FROM T_WORKFLOW_STEP_X_USER wsu " & vbCrLf & _
										"WHERE wsu.stepID = " & stepID & vbCrLf & _
										"	AND wsu.email = '" & email & "' "
end function

function SQL_CONSULTA_DELPHI_USER_ROLE_ROUND(roundID, email)
	SQL_CONSULTA_DELPHI_USER_ROLE_ROUND = "SELECT wsu.role " & vbCrLf & _
										"FROM T_FTA_METHOD_DELPHI d " & vbCrLf & _
										"	INNER JOIN T_WORKFLOW_STEP_X_USER wsu ON wsu.stepID = d.stepID " & vbCrLf & _
										"	INNER JOIN T_FTA_METHOD_DELPHI_ROUND dr ON dr.delphiID = wsu.stepID " & vbCrLf & _
										"WHERE dr.roundID = " & roundID & vbCrLf & _
										"	AND wsu.email = '" & email & "' " & vbCrLf & _
										"ORDER BY wsu.role"
end function

function SQL_CONSULTA_DELPHI_ROUND(roundID)
	SQL_CONSULTA_DELPHI_ROUND = "SELECT * " & vbCrLf & _
								"FROM T_FTA_METHOD_DELPHI_ROUND dr " & vbCrLf & _
								"WHERE dr.roundID = " & roundID
end function

function SQL_CONSULTA_DELPHI_ROUNDS(stepID)
	SQL_CONSULTA_DELPHI_ROUNDS = "SELECT * " & vbCrLf & _
								"FROM T_FTA_METHOD_DELPHI_ROUND  " & vbCrLf & _
								"WHERE delphiID = " & stepID & vbCrLf & _
								"ORDER BY roundID"
end function

function SQL_CONSULTA_DELPHI_ROUNDS_STATE(stepID, state)
	SQL_CONSULTA_DELPHI_ROUNDS_STATE = "SELECT * " & vbCrLf & _
										"FROM T_FTA_METHOD_DELPHI_ROUND" & vbCrLf & _
										"WHERE delphiID = " & stepID & vbCrLf & _
										"	AND state = " & state & vbCrLf & _
										"ORDER BY roundID"
end function

function SQL_CONSULTA_DELPHI_ROUND_QUESTIONS(roundID)
	SQL_CONSULTA_DELPHI_ROUND_QUESTIONS = "SELECT dq.questionID, dq.text AS question, dq.questionOrder AS questionOrder, " & vbCrLf & _
								"	ISNULL(do.optionID, -1) AS optionID, ISNULL(do.text, '') AS optionText " & vbCrLf & _
								"FROM T_FTA_METHOD_DELPHI_ROUND dr " & vbCrLf & _
								"	INNER JOIN T_FTA_METHOD_DELPHI_QUESTION dq ON dq.roundID = dr.roundID " & vbCrLf & _
								"	LEFT JOIN T_FTA_METHOD_DELPHI_OPTION do ON do.questionID = dq.questionID " & vbCrLf & _
								"WHERE dr.roundID = " & roundID & vbCrLf & _
								"ORDER BY dq.questionOrder,dq.questionID, do.optionID"
end function

function SQL_CONSULTA_DELPHI_ROUND_QUESTION(questionID)
	SQL_CONSULTA_DELPHI_ROUND_QUESTION = "SELECT dq.questionID, dq.text AS question, " & vbCrLf & _
								"	ISNULL(do.optionID, -1) AS optionID, ISNULL(do.text, '') AS optionText " & vbCrLf & _
								"FROM T_FTA_METHOD_DELPHI_ROUND dr " & vbCrLf & _
								"	INNER JOIN T_FTA_METHOD_DELPHI_QUESTION dq ON dq.roundID = dr.roundID " & vbCrLf & _
								"	LEFT JOIN T_FTA_METHOD_DELPHI_OPTION do ON do.questionID = dq.questionID " & vbCrLf & _
								"WHERE dq.questionID = " & questionID & vbCrLf & _
								"ORDER BY dq.questionOrder,dq.questionID, do.optionID"
end function

function SQL_CONSULTA_DELPHI_ROUND_QUESTIONS_ONLY(roundID)
	SQL_CONSULTA_DELPHI_ROUND_QUESTIONS_ONLY = "SELECT dq.questionID, dq.text AS question, dq.questionOrder, count(do.optionID) AS options FROM [TIAMAT].[dbo].T_FTA_METHOD_DELPHI_ROUND dr INNER JOIN [TIAMAT].[dbo].T_FTA_METHOD_DELPHI_QUESTION dq ON dq.roundID = dr.roundID LEFT JOIN [TIAMAT].[dbo].T_FTA_METHOD_DELPHI_OPTION do ON do.questionID = dq.questionID WHERE dr.roundID = "& roundID &" group by dq.questionID, dq.text, dq.questionOrder ORDER BY dq.questionOrder"
end function

function SQL_CONSULTA_DELPHI_ROUND_TEXT_ANSWERS(roundID)
	SQL_CONSULTA_DELPHI_ROUND_TEXT_ANSWERS = "SELECT dq.questionID, dq.text AS question, ISNULL(dta.text, '') AS textAnswer, " & vbCrLf & _
												"FROM T_FTA_METHOD_DELPHI_ROUND dr " & vbCrLf & _
												"	INNER JOIN T_FTA_METHOD_DELPHI_QUESTION dq ON dq.roundID = dr.roundID " & vbCrLf & _
												"	INNER JOIN T_FTA_METHOD_DELPHI_TEXT_ANSWER dta ON dta.questionID = dq.questionID" & vbCrLf & _
												"WHERE dr.roundID = " & roundID & vbCrLf & _
												"ORDER BY dq.questionOrder,dq.questionID, dta.participant"
end function

function SQL_CONSULTA_DELPHI_ROUND_OPTION_ANSWERS(roundID)
	SQL_CONSULTA_DELPHI_ROUND_OPTION_ANSWERS = "SELECT dq.questionID, dq.text AS question, " & vbCrLf & _
												"	do.optionID AS optionID, do.text AS optionText, ISNULL(doa.optionID, -1) AS optionAnswer " & vbCrLf & _
												"FROM T_FTA_METHOD_DELPHI_ROUND dr " & vbCrLf & _
												"	INNER JOIN T_FTA_METHOD_DELPHI_QUESTION dq ON dq.roundID = dr.roundID " & vbCrLf & _
												"	INNER JOIN T_FTA_METHOD_DELPHI_OPTION do ON do.questionID = dq.questionID " & vbCrLf & _
												"	INNER JOIN T_FTA_METHOD_DELPHI_OPTION_ANSWER doa ON doa.optionID = do.optionID " & vbCrLf & _
												"WHERE dr.roundID = " & roundID & vbCrLf & _
												"ORDER BY dq.questionOrder,dq.questionID, doa.optionID, doa.participant"
end function

function SQL_CONSULTA_DELPHI_ROUND_ANSWERS(roundID)
	SQL_CONSULTA_DELPHI_ROUND_ANSWERS = "SELECT t.* FROM (" & vbCrLf & _
										"	SELECT dq1.questionID, dq1.text AS question, ISNULL(dta.text, '') AS textAnswer, dq1.questionOrder, " & vbCrLf & _
										"		-1 AS optionID, '' AS optionText, -1 AS numAnswers " & vbCrLf & _
										"	FROM T_FTA_METHOD_DELPHI_ROUND dr " & vbCrLf & _
										"		INNER JOIN T_FTA_METHOD_DELPHI_QUESTION dq1 ON dq1.roundID = dr.roundID " & vbCrLf & _
										"		LEFT JOIN T_FTA_METHOD_DELPHI_TEXT_ANSWER dta ON dta.questionID = dq1.questionID " & vbCrLf & _
										"	WHERE dr.roundID = " & roundID & vbCrLf & _
										"		AND dq1.questionID NOT IN (SELECT DISTINCT dq3.questionID " & vbCrLf & _
										"									FROM T_FTA_METHOD_DELPHI_ROUND dr " & vbCrLf & _
										"										INNER JOIN T_FTA_METHOD_DELPHI_QUESTION dq3 ON dq3.roundID = dr.roundID " & vbCrLf & _ 
										"										INNER JOIN T_FTA_METHOD_DELPHI_OPTION do ON do.questionID = dq3.questionID " & vbCrLf & _
										"									WHERE dq3.roundID = " & roundID & ") " & vbCrLf & _
										"	UNION " & vbCrLf & _
										"	SELECT dq2.questionID, dq2.text AS question, '' AS textAnswer, dq2.questionOrder, " & vbCrLf & _
										"		do.optionID AS optionID, do.text AS optionText, s.numAnswers " & vbCrLf & _
										"	FROM T_FTA_METHOD_DELPHI_ROUND dr " & vbCrLf & _
										"		INNER JOIN T_FTA_METHOD_DELPHI_QUESTION dq2 ON dq2.roundID = dr.roundID " & vbCrLf & _
										"		INNER JOIN T_FTA_METHOD_DELPHI_OPTION do ON do.questionID = dq2.questionID " & vbCrLf & _
										"		INNER JOIN (SELECT do.optionID AS optionID, COUNT(doa.optionID) AS numAnswers " & vbCrLf & _
										"					FROM T_FTA_METHOD_DELPHI_ROUND dr " & vbCrLf & _
										"					INNER JOIN T_FTA_METHOD_DELPHI_QUESTION dq2 ON dq2.roundID = dr.roundID " & vbCrLf & _
										"					INNER JOIN T_FTA_METHOD_DELPHI_OPTION do ON do.questionID = dq2.questionID " & vbCrLf & _
										"					LEFT JOIN T_FTA_METHOD_DELPHI_OPTION_ANSWER doa ON doa.optionID = do.optionID " & vbCrLf & _
										"					WHERE dr.roundID = " & roundID & vbCrLf & _
										"					GROUP BY do.optionID) s ON s.optionID = do.optionID) t " & vbCrLf & _
										"ORDER BY t.questionOrder,t.questionID, t.optionID"
end function


function SQL_CONSULTA_DELPHI_ROUND_QUESTION_ANSWERS(roundID, questionID)
	SQL_CONSULTA_DELPHI_ROUND_QUESTION_ANSWERS = "SELECT t.*, RAND() as ordenador FROM (" & vbCrLf & _
										"	SELECT dq1.questionID, dq1.text AS question, ISNULL(dta.text, '') AS textAnswer, " & vbCrLf & _
										"		-1 AS optionID, '' AS optionText, -1 AS numAnswers " & vbCrLf & _
										"	FROM T_FTA_METHOD_DELPHI_ROUND dr " & vbCrLf & _
										"		INNER JOIN T_FTA_METHOD_DELPHI_QUESTION dq1 ON dq1.roundID = dr.roundID " & vbCrLf & _
										"		LEFT JOIN T_FTA_METHOD_DELPHI_TEXT_ANSWER dta ON dta.questionID = dq1.questionID " & vbCrLf & _
										"	WHERE dr.roundID = " & roundID & vbCrLf & _
										"	AND dq1.questionID = " & questionID & vbCrLf & _
										"		AND dq1.questionID NOT IN (SELECT DISTINCT dq3.questionID " & vbCrLf & _
										"									FROM T_FTA_METHOD_DELPHI_ROUND dr " & vbCrLf & _
										"										INNER JOIN T_FTA_METHOD_DELPHI_QUESTION dq3 ON dq3.roundID = dr.roundID " & vbCrLf & _ 
										"										INNER JOIN T_FTA_METHOD_DELPHI_OPTION do ON do.questionID = dq3.questionID " & vbCrLf & _
										"									WHERE dq3.roundID = " & roundID & ") " & vbCrLf & _
										"	UNION " & vbCrLf & _
										"	SELECT dq2.questionID, dq2.text AS question, '' AS textAnswer, " & vbCrLf & _
										"		do.optionID AS optionID, do.text AS optionText, s.numAnswers " & vbCrLf & _
										"	FROM T_FTA_METHOD_DELPHI_ROUND dr " & vbCrLf & _
										"		INNER JOIN T_FTA_METHOD_DELPHI_QUESTION dq2 ON dq2.roundID = dr.roundID " & vbCrLf & _
										"		INNER JOIN T_FTA_METHOD_DELPHI_OPTION do ON do.questionID = dq2.questionID " & vbCrLf & _
										"		INNER JOIN (SELECT do.optionID AS optionID, COUNT(doa.optionID) AS numAnswers " & vbCrLf & _
										"					FROM T_FTA_METHOD_DELPHI_ROUND dr " & vbCrLf & _
										"					INNER JOIN T_FTA_METHOD_DELPHI_QUESTION dq2 ON dq2.roundID = dr.roundID " & vbCrLf & _
										"					INNER JOIN T_FTA_METHOD_DELPHI_OPTION do ON do.questionID = dq2.questionID " & vbCrLf & _
										"					LEFT JOIN T_FTA_METHOD_DELPHI_OPTION_ANSWER doa ON doa.optionID = do.optionID " & vbCrLf & _
										"					WHERE dr.roundID = " & roundID & vbCrLf & _
										"					AND dq2.questionID = " & questionID & vbCrLf & _
										"					GROUP BY do.optionID) s ON s.optionID = do.optionID) t " & vbCrLf & _
										"ORDER BY ordenador, t.optionID"
end function

function SQL_CONSULTA_DELPHI_ROUND_PARTICIPANT_ANSWERS(roundID, participant)
	SQL_CONSULTA_DELPHI_ROUND_PARTICIPANT_ANSWERS = "SELECT t.* FROM (" & vbCrLf & _
													"	SELECT dq1.questionID, dq1.text AS question, ISNULL(dta.text, '') AS textAnswer, dq1.questionOrder, " & vbCrLf & _ 
													"		-1 AS optionID, '' AS optionText, -1 AS optionAnswer " & vbCrLf & _
													"	FROM T_FTA_METHOD_DELPHI_ROUND dr " & vbCrLf & _
													"		INNER JOIN T_FTA_METHOD_DELPHI_QUESTION dq1 ON dq1.roundID = dr.roundID " & vbCrLf & _
													"		LEFT JOIN T_FTA_METHOD_DELPHI_TEXT_ANSWER dta ON dta.questionID = dq1.questionID AND dta.participant = '" & participant & "' " & vbCrLf & _
													"	WHERE dr.roundID = " & roundID & vbCrLf & _
													"		AND dq1.questionID NOT IN (SELECT DISTINCT dq3.questionID " & vbCrLf & _
													"									FROM T_FTA_METHOD_DELPHI_ROUND dr " & vbCrLf & _
													"										INNER JOIN T_FTA_METHOD_DELPHI_QUESTION dq3 ON dq3.roundID = dr.roundID " & vbCrLf & _ 
													"										INNER JOIN T_FTA_METHOD_DELPHI_OPTION do ON do.questionID = dq3.questionID " & vbCrLf & _
													"									WHERE dq3.roundID = " & roundID & ") " & vbCrLf & _
													"	UNION " & vbCrLf & _
													"	SELECT dq2.questionID, dq2.text AS question, '' AS textAnswer, dq2.questionOrder, " & vbCrLf & _
													"		do.optionID AS optionID, do.text AS optionText, ISNULL(doa.optionID, -1) AS optionAnswer " & vbCrLf & _
													"	FROM T_FTA_METHOD_DELPHI_ROUND dr " & vbCrLf & _
													"		INNER JOIN T_FTA_METHOD_DELPHI_QUESTION dq2 ON dq2.roundID = dr.roundID " & vbCrLf & _
													"		INNER JOIN T_FTA_METHOD_DELPHI_OPTION do ON do.questionID = dq2.questionID " & vbCrLf & _
													"		LEFT JOIN T_FTA_METHOD_DELPHI_OPTION_ANSWER doa ON doa.optionID = do.optionID AND doa.participant = '" & participant & "' " & vbCrLf & _
													"	WHERE dr.roundID = " & roundID & ") t " & vbCrLf & _
													"ORDER BY t.questionOrder, t.questionID, t.optionID"
end function

function SQL_CONSULTA_DELPHI_TEXT_ANSWER(questionID, participant)
	SQL_CONSULTA_DELPHI_TEXT_ANSWER = "SELECT * " & vbCrLf & _
										"FROM T_FTA_METHOD_DELPHI_TEXT_ANSWER " & vbCrLf & _
										"WHERE questionID = " & questionID & vbCrLf & _
										"	AND participant = '" & participant & "'"
end function

function SQL_ATUALIZA_DELPHI(stepID, text)
	SQL_ATUALIZA_DELPHI = "UPDATE T_FTA_METHOD_DELPHI SET " & vbCrLf & _
							"text = '" & text & "' "& vbCrLf & _
							"WHERE stepID = " & stepID
end function

function SQL_ATUALIZA_DELPHI_ROUND(roundID, state, text)
	SQL_ATUALIZA_DELPHI_ROUND = "UPDATE T_FTA_METHOD_DELPHI_ROUND SET " & vbCrLf & _
									"state = " & state & ", "& vbCrLf & _
									"text = '" & text & "' "& vbCrLf & _
									"WHERE roundID = " & roundID
end function

function SQL_ATUALIZA_DELPHI_QUESTION(questionID, text)
	SQL_ATUALIZA_DELPHI_QUESTION = "UPDATE T_FTA_METHOD_DELPHI_QUESTION SET " & vbCrLf & _
									"text = '" & text & "' "& vbCrLf & _
									"WHERE questionID = " & questionID
end function


function SQL_ATUALIZA_DELPHI_QUESTION_ORDER(questionID, newOrder)
	SQL_ATUALIZA_DELPHI_QUESTION_ORDER = "UPDATE T_FTA_METHOD_DELPHI_QUESTION SET " & vbCrLf & _
									"questionOrder = " & Replace(newOrder, ",", ".") & " "& vbCrLf & _
									"WHERE questionID = " & questionID
end function



function SQL_ATUALIZA_DELPHI_OPTION(optionID, text)
	SQL_ATUALIZA_DELPHI_OPTION = "UPDATE T_FTA_METHOD_DELPHI_OPTION SET " & vbCrLf & _
									"text = '" & text & "' "& vbCrLf & _
									"WHERE optionID = " & optionID
end function

function SQL_ATUALIZA_DELPHI_TEXT_ANSWER(questionID, participant, text)
	SQL_ATUALIZA_DELPHI_TEXT_ANSWER = "UPDATE T_FTA_METHOD_DELPHI_TEXT_ANSWER SET " & vbCrLf & _
										"text = '" & text & "' "& vbCrLf & _
										"WHERE questionID = " & questionID & vbCrLf & _
										"	AND participant = '" & participant & "'"
end function

function SQL_ATUALIZA_DELPHI_OPTION_ANSWER(questionID, participant, optionID)
	SQL_ATUALIZA_DELPHI_OPTION_ANSWER = "UPDATE T_FTA_METHOD_DELPHI_OPTION_ANSWER SET " & vbCrLf & _
											"optionID = " & optionID & vbCrLf & _
											"WHERE questionID = " & questionID & vbCrLf & _
											"	AND participant = '" & participant & "'"
end function

function SQL_EXCLUI_DELPHI_ROUND(roundID)
	SQL_EXCLUI_DELPHI_ROUND = "DELETE T_FTA_METHOD_DELPHI_ROUND " & vbCrLf & _
								"WHERE roundID = " & roundID
end function

function SQL_EXCLUI_DELPHI_QUESTION(questionID)
	SQL_EXCLUI_DELPHI_QUESTION = "DELETE T_FTA_METHOD_DELPHI_QUESTION " & vbCrLf & _
								"WHERE questionID = " & questionID
end function

function SQL_EXCLUI_DELPHI_OPTION(optionID)
	SQL_EXCLUI_DELPHI_OPTION = "DELETE T_FTA_METHOD_DELPHI_OPTION " & vbCrLf & _
								"WHERE optionID = " & optionID
end function

function SQL_EXCLUI_DELPHI_TEXT_ANSWER(questionID, participant)
	SQL_EXCLUI_DELPHI_TEXT_ANSWER = "DELETE T_FTA_METHOD_DELPHI_TEXT_ANSWER " & vbCrLf & _
									"WHERE questionID = " & questionID & vbCrLf & _
									"	AND participant = '" & participant & "'"
end function

function SQL_EXCLUI_DELPHI_OPTION_ANSWER(optionID, participant)
	SQL_EXCLUI_DELPHI_OPTION_ANSWER = "DELETE T_FTA_METHOD_DELPHI_TEXT_ANSWER " & vbCrLf & _
										"WHERE optionID = " & optionID & vbCrLf & _
										"	AND participant = '" & participant & "'"
end function

function SQL_CRIA_DELPHI(stepID)
	SQL_CRIA_DELPHI = "INSERT INTO T_FTA_METHOD_DELPHI (stepID) " & vbCrLf & _
						"VALUES (" & stepID & ") "
end function

function SQL_CRIA_DELPHI_TEXT_ANSWER(questionID, participant, text)
	SQL_CRIA_DELPHI_TEXT_ANSWER = "INSERT INTO T_FTA_METHOD_DELPHI_TEXT_ANSWER (questionID, participant, text) " & vbCrLf & _
									"VALUES (" & questionID & ", '" & participant & "', '" & text & "')"
end function

function SQL_CRIA_DELPHI_OPTION_ANSWER(questionID, participant, optionID)
	SQL_CRIA_DELPHI_OPTION_ANSWER = "INSERT INTO T_FTA_METHOD_DELPHI_OPTION_ANSWER (questionID, participant, optionID) " & vbCrLf & _
									"VALUES (" & questionID & ", '" & participant & "', " & optionID & ")"
end function



Sub printAllRoundQuestions(roundID, mode)
	Dim rs
	Dim question(2)
	Dim i, isOption
	Dim html, questionID, questionIDAnt, questionText, optionID, optionText
	
	Call getRecordSet(SQL_CONSULTA_DELPHI_ROUND_QUESTIONS(roundID), rs)
	
	i = 1
	j = 1
	
	If rs.EOF Then
		'
	Else
		'html = "<div id=""delphi-questions"">"
		questionID = rs("questionID")
		
		While Not rs.EOF
			questionText = trim(rs("question"))
			
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
			html = html & "<p class=""question-text"">" & replace(questionText, vbCrLf, "<br />") & "</p>"
			
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

Sub printAllRoundParticipantAnswers(roundID, editMode)
	Dim rs
	Dim question(2)
	Dim i, isOption, hasAnswer
	Dim html, questionID, questionIDAnt, questionText, optionID, optionText, optionAnswer
	
	Call getRecordSet(SQL_CONSULTA_DELPHI_ROUND_PARTICIPANT_ANSWERS(roundID, Session("email")), rs)
	
	i = 1
	j = 1
	hasAnswer = False
	
	If rs.EOF Then
		'
	Else
		html = "<div class='accordion' id='accordionQuestion'>"
		questionID = rs("questionID")
		
		While Not rs.EOF
			questionText = rs("question")
			
			questionIDAnt = questionID
					
			
			html = html & " <div class='accordion-item'>"
			
			html = html & " <h2 class='accordion-header' id='headingQuestion"& questionID &"'>"
			html = html & "<button class='accordion-button bg-dark text-light' type='button' data-bs-toggle='collapse' data-bs-target='#collapseQuestion"& questionID &"' aria-expanded='true' aria-controls='collapseQuestion"& questionID &"'>"
'			html = html & "<div class='d-flex w-100 mx-1'>"
			html = html & "<div class='flex-grow-1'>Question #" & i & "</div>"
'			html = html & "</div>"
			html = html & " </button> </h2>"

			
			html = html & "<div id='collapseQuestion"& questionID &"' class='accordion-collapse collapse show' aria-labelledby='headingQuestion"& questionID &"'>"
			html = html & "<span class='float-end px-3 mt-1' type='button' data-bs-toggle='modal' data-bs-target='#showAnswersModal'  data-title='Answers' data-url='showAnswers.asp?roundID="&roundID&"&questionID="& questionID & "'><img src='img/answer.png' style='height:25px;width:auto;'></span>"
			html = html & "<div class='accordion-body p-2 pt-1' id='" & questionID & "'>"
			

			html = html & "<input type=""hidden"" name=""questionID[]"" value=""" & questionID & """ />"
			html = html & "<p class=""question-text"">" & replace(questionText, vbCrLf, "<br />") & "</p>"
			

			
			
			
			j = 1
			hasAnswer = False
			Do While Clng(questionIDAnt) = Clng(questionID)
				optionID = rs("optionID")
				optionText = trim(rs("optionText"))
				textAnswer = trim(rs("textAnswer"))
				optionAnswer = rs("optionAnswer")
				
				If Clng(optionID) > -1 Then
					If j = 1 Then
						html = html & "<input type=""hidden"" name=""questionType[]"" value=""" & QUESTION_TYPE_OPT & """ />"
'						html = html & "<div class=""question-option-container"">"
					End If
					
'					html = html & "<div class=""question-option"">"
					html = html & "<div class='form-check'>"

					If mode = MODE_ANSWER Then
						If Clng(optionAnswer) > -1 Then
							html = html & "<input class='form-check-input' type=""radio"" name=""optionAnswer[" & i & "]"" id=""option-" & i & "-" & j & """ class=""question-option-id"" value=""" & optionID & """ checked=""checked"" />"
							hasAnswer = True
						Else
							html = html & "<input class='form-check-input' type=""radio"" name=""optionAnswer[" & i & "]"" id=""option-" & i & "-" & j & """ class=""question-option-id"" value=""" & optionID & """ />"
						End If
						
						html = html & "<label for=""option-" & i & "-" & j & """ class=""question-option-text"">" & optionText & "</label>"
					Else
						If Clng(optionAnswer) > -1 Then
							html = html & "<input class='form-check-input' type=""radio"" class=""question-option-id"" value=""" & optionID & """ checked=""checked"" />"
						Else
							html = html & "<input class='form-check-input' type=""radio"" class=""question-option-id"" value=""" & optionID & """ />"
						End If
						
						html = html & "<label class=""question-option-text"">" & optionText & "</label>"
					End If
					
					html = html & "</div>"
					
					isOption = True
				Else
					If mode = MODE_ANSWER Then
						html = html & "<textarea class='form-control' style='height:120px;' name=""textAnswer[" & i & "]"">" & textAnswer & "</textarea>"
						html = html & "<input type=""hidden"" name=""operation[]"" value=""2"" />"
						html = html & "<input type=""hidden"" name=""questionType[]"" value=""" & QUESTION_TYPE_TXT & """ />"
					Else
						html = html & "<textarea class='form-control' style='height:120px;'  disabled=""disabled"">" & textAnswer & "</textarea>"
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
			html = html & "</div>"
			
			If Not rs.EOF Then
				'rs.moveNext()
			End If
			
			i = i + 1
		Wend
		
		html = html & "</div>"
		
		response.write(html)
	End If
End Sub

Sub printAllRoundStatistics(roundID)
	Dim rs
	Dim question(2)
	Dim i
	Dim html, questionID, questionIDAnt, questionText, optionID, optionText, numAnswers
	
	
	
	
	Call getRecordSet(SQL_CONSULTA_DELPHI_ROUND_ANSWERS(roundID), rs)
	
	i = 1
	j = 1
	
	If rs.EOF Then
		'
	Else
		'html = "<div id=""delphi-questions"">"
		questionID = rs("questionID")
		
		While Not rs.EOF
			questionText = rs("question")
			
			questionIDAnt = questionID
			
'			html = html & "<div id=""" & questionID & """ class=""question-container"">"
'			html = html & "<div class=""question-header""><span>Question #" & i & "</span>"
			'If mode = MODE_EDIT Then
'				html = html & "<span class=""toggle-question"">[-]</span>"
			'End If
'			html = html & "</div>"
'			html = html & "<div class=""question-content"">"
'			html = html & "<p class=""question-text"">" & replace(questionText, vbCrLf, "<br />") & "</p>"


			html = html & " <div class='accordion-item'>"
			
			html = html & " <h2 class='accordion-header' id='headingQuestion"& questionID &"'>"
			html = html & " <button class='accordion-button bg-dark text-light' type='button' data-bs-toggle='collapse' data-bs-target='#collapseQuestion"& questionID &"' aria-expanded='true' aria-controls='collapseQuestion"& questionID &"'>"
			html = html & "Question #" & i 
			html = html & " </button> </h2>"

			
			html = html & "<div id='collapseQuestion"& questionID &"' class='accordion-collapse collapse show' aria-labelledby='headingQuestion"& questionID &"'>"
			html = html & "<div class='accordion-body' id='" & questionID & "'>"

			html = html & "<input type=""hidden"" name=""questionID[]"" value=""" & questionID & """ />"
			html = html & "<p class=""question-text"">" & replace(questionText, vbCrLf, "<br />") & "</p>"
			
			
			j = 1
			Do While Clng(questionIDAnt) = Clng(questionID)
				optionID = rs("optionID")
				optionText = trim(rs("optionText"))
				textAnswer = trim(rs("textAnswer"))
				numAnswers = rs("numAnswers")
				
				If Clng(optionID) > -1 Then
					If j = 1 Then
						html = html & "<div class=""question-chart-container d-flex justify-content-center"" id=""chart-" & j & """></div>"
						html = html & "<div class=""question-chart-data-container"">"
					End If
					
					html = html & "<div class=""question-chart-data"">"
					html = html & "<input type=""hidden"" class=""question-option-id"" value=""" & optionID & """ />"
					html = html & "<input type=""hidden"" class=""question-option-text"" value=""" & optionText & """ />"
					html = html & "<input type=""hidden"" class=""question-option-numanswers"" value=""" & numAnswers & """ />"
					html = html & "</div>"
					
				Else
'					If j = 1 Then
'						html = html & "<div class=""question-text-answers"">"
'					End If
					
					textAnswer = replace(textAnswer, vbCrLf, "<br />")
			
					If textAnswer <> "" Then

						html = html & " <div class='accordion-item'>"
								
						html = html & " <h2 class='accordion-header' id='headingQuestion"& questionID &"Answer"& j &"'>"
						html = html & " <button class='accordion-button bg-dark text-light' type='button' data-bs-toggle='collapse' data-bs-target='#collapseQuestion"& questionID &"Answer"& j &"' aria-expanded='true' aria-controls='collapseQuestion"& questionID &"Answer"& j &"'>"
						html = html & "Answer #" & j
						html = html & " </button> </h2>"

						
						html = html & "<div id='collapseQuestion"& questionID &"Answer"& j &"' class='accordion-collapse collapse show' aria-labelledby='headingQuestion"& questionID &"Answer"& j &"'>"
						html = html & "<div class='accordion-body'>"
						html = html & "<p class=""question-text"">" & replace(textAnswer, vbCrLf, "<br />") & "</p>"					
						html = html & "</div>"
						html = html & "</div>"
					
'						html = html & "<div class=""question-text-answer-container"">"
'						html = html & "<label>Answer #" & j & "</label>"
'						html = html & "<p class=""question-text-answer"">" & replace(textAnswer, vbCrLf, "<br />") & "</p>"
'						html = html & "</div>"
						else
						html = html & "<div class='py-3'><div class='alert alert-danger'> This question has no previous answer by any participant.</div></div>"
					End If
				End If
				
				rs.moveNext()
				
				If rs.EOF Then
					Exit Do	
				End If
				
				questionID = rs("questionID")
				j = j + 1
			Loop
			
			html = html & "</div>"
			html = html & "</div>"
			html = html & "</div>"
			html = html & "</div>"
			
			
			If Not rs.EOF Then
				'rs.moveNext()
			End If
			
			i = i + 1
		Wend
		
		html = html & "</div>"
		
		response.write(html)
	End If
End Sub


Sub printAllAnswers(roundID, questionID)
	Dim rs
	Dim question(2)
	Dim i
	Dim html, questionIDAnt, questionText, optionID, optionText, numAnswers
	
	Call getRecordSet(SQL_CONSULTA_DELPHI_ROUND_QUESTION_ANSWERS(roundID,questionID), rs)
	
	i = 1
	j = 1
	
	If rs.EOF Then
	  		response.write "<div class='py-3'><div class='alert alert-danger'> This question has no previous answer by any participant.</div></div>"
	
	Else

		
	
		While Not rs.EOF
			questionText = rs("question")
			
			questionIDAnt = questionID
			
			html = html & " <div class='accordion-item'>"
			
			html = html & " <h2 class='accordion-header' id='headingQuestion"& questionID &"'>"
			html = html & " <button class='accordion-button bg-dark text-light' type='button' data-bs-toggle='collapse' data-bs-target='#collapseQuestion"& questionID &"' aria-expanded='true' aria-controls='collapseQuestion"& questionID &"'>"
			html = html & "Question" 
			html = html & " </button> </h2>"

			
			html = html & "<div id='collapseQuestion"& questionID &"' class='accordion-collapse collapse show' aria-labelledby='headingQuestion"& questionID &"'>"
			html = html & "<div class='accordion-body' id='" & questionID & "'>"

			html = html & "<input type=""hidden"" name=""questionID[]"" value=""" & questionID & """ />"
			html = html & "<p class=""question-text"">" & replace(questionText, vbCrLf, "<br />") & "</p>"
			
			
			j = 1
			Do While Clng(questionIDAnt) = Clng(questionID)
				optionID = rs("optionID")
				optionText = trim(rs("optionText"))
				textAnswer = trim(rs("textAnswer"))
				numAnswers = rs("numAnswers")
				
				If Clng(optionID) > -1 Then
					If j = 1 Then
						html = html & "<div class=""question-chart-container d-flex justify-content-center"" id=""chart-" & j & """></div>"
						html = html & "<div class=""question-chart-data-container"">"
					End If
					
					html = html & "<div class=""question-chart-data"">"
					html = html & "<input type=""hidden"" class=""question-option-id"" value=""" & optionID & """ />"
					html = html & "<input type=""hidden"" class=""question-option-text"" value=""" & optionText & """ />"
					html = html & "<input type=""hidden"" class=""question-option-numanswers"" value=""" & numAnswers & """ />"
					html = html & "</div>"
				Else
'					If j = 1 Then
'						html = html & "<div class=""question-text-answers"">"
'					End If
					
					textAnswer = replace(textAnswer, vbCrLf, "<br />")
					
					If textAnswer <> "" Then

						html = html & " <div class='accordion-item'>"
								
						html = html & " <h2 class='accordion-header' id='headingQuestion"& questionID &"Answer"& j &"'>"
						html = html & " <button class='accordion-button bg-dark text-light' type='button' data-bs-toggle='collapse' data-bs-target='#collapseQuestion"& questionID &"Answer"& j &"' aria-expanded='true' aria-controls='collapseQuestion"& questionID &"Answer"& j &"'>"
						html = html & "Answer #" & j
						html = html & " </button> </h2>"

						
						html = html & "<div id='collapseQuestion"& questionID &"Answer"& j &"' class='accordion-collapse collapse show' aria-labelledby='headingQuestion"& questionID &"Answer"& j &"'>"
						html = html & "<div class='accordion-body'>"
						html = html & "<p class=""question-text"">" & replace(textAnswer, vbCrLf, "<br />") & "</p>"					
						html = html & "</div>"
						html = html & "</div>"
					
'						html = html & "<div class=""question-text-answer-container"">"
'						html = html & "<label>Answer #" & j & "</label>"
'						html = html & "<p class=""question-text-answer"">" & replace(textAnswer, vbCrLf, "<br />") & "</p>"
'						html = html & "</div>"
					End If
				End If
				
				rs.moveNext()
				
				If rs.EOF Then
					Exit Do	
				End If
				
				questionID = rs("questionID")
				j = j + 1
			Loop
			
			html = html & "</div>"
			html = html & "</div>"
			html = html & "</div>"
			html = html & "</div>"
			
			i = i + 1
		Wend
		
		html = html & "</div>"
		
		response.write(html)
	End If
End Sub

Function getRole(stepID, email)
	Dim rs
	
	getRole = ""
	
	Call getRecordSet(SQL_CONSULTA_DELPHI_USER_ROLE(stepID, email), rs)
	
	If Not rs.EOF Then
		getRole = rs("role")
	End If
	
End Function

Function getRoleRound(roundID, email)
	Dim rs
	
	getRoleRound = ""
	
	Call getRecordSet(SQL_CONSULTA_DELPHI_USER_ROLE_ROUND(roundID, email), rs)
	
	If Not rs.EOF Then
		getRoleRound = rs("role")
	End If
	
End Function
%>