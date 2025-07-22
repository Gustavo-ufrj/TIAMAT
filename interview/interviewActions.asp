<!--#include virtual="/system.asp"-->
<!--#include virtual="/includes/JSON.asp"-->
<!--#include file="INC_INTERVIEW.inc"-->

<%

Dim rs
Dim action
Dim redirectLink

Dim stepID

Dim i, j
Dim text, state
Dim questionID, newQuestionText, newOptionID, newOptionText, operation, operationOption
Dim questionType, textAnswer, optionAnswer
Dim participant
Dim insert, update

const OPER_NO = 0
const OPER_ADD = 1
const OPER_EDIT = 2
const OPER_DEL = 3

action = Request.Querystring("action")

Session("interviewError") = ""
Session("interviewQuestionsError") = ""
Session("welcomeMessage") = ""

select case action

	case "save"
		
		stepID = request.form("stepID")
		
		If stepID <> "" Then
			
			text = request.form("text")
			
			If text <> "" Then
			
				Call ExecuteSQL(SQL_ATUALIZA_INTERVIEW(stepID, trim(text)))
				
			else
			
				Session("interviewError") = "No interview information supplied. Please inform the system administrator."	
			
			end if
		else
		
			Session("interviewError") = "Invalid interview id. Please inform the system administrator."	
		
		end if
		
		'if Clng(request.form("redirectLink")) = 0 Then
		'	redirectLink = "manageInterview.asp?stepID=" & stepID
		'Else
			redirectLink = "index.asp?stepID=" & stepID
		'End If
		response.redirect redirectLink
	
	case "change_state"
		
		stepID = request.queryString("stepID")
		
		If stepID <> "" Then
			
			Call getRecordSet(SQL_CONSULTA_INTERVIEW(stepID), rs)
			
			If Not rs.EOF Then
				
				state = CLng(rs("state"))
				
				If state = STATE_UNP Then
					Call ExecuteSQL(SQL_ATUALIZA_INTERVIEW_STATE(stepID, STATE_PUB))
				ElseIf state = STATE_PUB Then
					Call ExecuteSQL(SQL_ATUALIZA_INTERVIEW_STATE(stepID, STATE_END))
				End If
			else
			
				Session("interviewError") = "Interview was not found. Please inform the system administrator."	
			
			end if
		else
		
			Session("interviewError") = "Invalid interview id. Please inform the system administrator."	
		
		end if
		
		'if Clng(request.form("redirectLink")) = 0 Then
		'	redirectLink = "manageInterview.asp?stepID=" & stepID
		'Else
			redirectLink = "index.asp?stepID=" & stepID
		'End If
		response.redirect redirectLink
	
	case "save_round"
		
		stepID = request.form("stepID")
		
		if stepID <> "" then
			
			questionID = split(request.form("questionID[]"), ", ")
			newQuestionText = request.form("newQuestionText")
			newOptionID = split(request.form("newOptionID[]"), ", ")
			newOptionText = split(request.form("newOptionText[]"), ", ")
			operation = split(request.form("operation[]"), ", ")
			operationOption = split(request.form("operationOption[]"), ", ")
			
			'response.write(request.form("stepID") & " --- " & request.form("roundID") & "<br>")
			'response.write(request.form("questionID[]") & "<br>")
			'response.write(request.form("operation[]") & "<br>")
			'response.write(request.form("newQuestionText") & "<br>")
			'response.write(request.form("operationOption[]") & "<br>")
			'response.write(request.form("newOptionID[]") & " --- " & request.form("newOptionText[]") & "<br>")
			'response.write(UBound(operation) & "<br>")
			'response.write(UBound(operationOption) & "<br>")
			
			i = 0
			While i <= UBound(operation)
				'response.write(fwID(i) & ", " & fwEvent(i) & ", " & parentFWID(i) & ", " & posX(i) & ", " & posY(i) & ", " & operation(i) & "<br />")
				
				If CLng(operation(i)) = OPER_NO Then
					'
				ElseIf CLng(operation(i)) = OPER_ADD Then ' New
					
					If newQuestionText <> "" Then
						Set cnn = getConnection
						Call chamaSP(True, objSP, "SP_CREATE_FTA_METHOD_INTERVIEW_QUESTION",cnn)
						With objSP
							 .Parameters.Append .CreateParameter("RETORNO", adBigInt,adParamReturnValue)
							 .Parameters.Append .CreateParameter("@text",advarchar,adParamInput,1023,trim(newQuestionText))
							 .Parameters.Append .CreateParameter("@stepID",adBigInt,adParamInput,8,stepID)
							 .Execute
							 
							 insertedQuestionID = .Parameters("RETORNO")
							 
						End With
						Call chamaSP(False, objSP, Null, Null)
						dispose(cnn)
					
						If insertedQuestionID = -1 Then
							Session("interviewQuestionsError") = "An error has occured when trying to create a new question. Please inform the system administrator."
						Else
							insertedOptionID = -1
						
							j = 0
							While j <= UBound(newOptionText)
								If newOptionText(j) <> "" Then
								
									Set cnn = getConnection
									Call chamaSP(True, objSP, "SP_CREATE_FTA_METHOD_INTERVIEW_OPTION",cnn)
									With objSP
										 .Parameters.Append .CreateParameter("RETORNO", adBigInt,adParamReturnValue)
										 .Parameters.Append .CreateParameter("@text",advarchar,adParamInput,1023,trim(newOptionText(j)))
										 .Parameters.Append .CreateParameter("@questionID",adBigInt,adParamInput,8,insertedQuestionID)
										 .Execute
										 
										 insertedOptionID = .Parameters("RETORNO")
										 
									End With
									Call chamaSP(False, objSP, Null, Null)
									dispose(cnn)
								
									If insertedOptionID = -1 Then
										Session("interviewQuestionsError") = "An error has occured when trying to create a new question option. Please inform the system administrator."
									Else
										'
									End If
							
								End If
							
								j = j + 1
							Wend
						End If
					End If
					
				ElseIf CLng(operation(i)) = OPER_EDIT Then ' Edit
					
					If newQuestionText <> "" Then
						Call ExecuteSQL(SQL_ATUALIZA_INTERVIEW_QUESTION(questionID(i), newQuestionText))
						
						j = 0
						While j <= UBound(newOptionText)
							insertedOptionID = -1
							
							If Clng(operationOption(j)) = OPER_ADD Then
								If newOptionText(j) <> "" Then
									Set cnn = getConnection
									Call chamaSP(True, objSP, "SP_CREATE_FTA_METHOD_INTERVIEW_OPTION",cnn)
									With objSP
										 .Parameters.Append .CreateParameter("RETORNO", adBigInt,adParamReturnValue)
										 .Parameters.Append .CreateParameter("@text",advarchar,adParamInput,1023,trim(newOptionText(j)))
										 .Parameters.Append .CreateParameter("@questionID",adBigInt,adParamInput,8,questionID(i))
										 .Execute
										 
										 insertedOptionID = .Parameters("RETORNO")
										 
									End With
									Call chamaSP(False, objSP, Null, Null)
									dispose(cnn)
								
									If insertedOptionID = -1 Then
										Session("interviewQuestionsError") = "An error has occurred when trying to create a new question option. Please inform the system administrator."
									Else
										'
									End If
								End If
							ElseIf Clng(operationOption(j)) = OPER_EDIT Then
								If newOptionText(j) <> "" Then
									Call ExecuteSQL(SQL_ATUALIZA_INTERVIEW_OPTION(newOptionID(j), trim(newOptionText(j))))
								End If
							ElseIf Clng(operationOption(j)) = OPER_DEL Then
								Call ExecuteSQL(SQL_EXCLUI_INTERVIEW_OPTION(newOptionID(j)))
							End If
							
							j = j + 1
						Wend
					End If
					
				ElseIf CLng(operation(i)) = OPER_DEL Then ' Delete
					
					' Delete cascade
					'Call ExecuteSQL(SQL_EXCLUI_INTERVIEW_OPTIONS(questionID(i)))
					
					Call ExecuteSQL(SQL_EXCLUI_INTERVIEW_QUESTION(questionID(i)))
					
				Else
					Session("interviewQuestionsError") = "Invalid operation for question. Please inform the system administrator."	
				End If
				
				i = i + 1
			Wend
			
		else
		
			Session("interviewQuestionsError") = "No step id supplied. Please inform the system administrator."	
		
		end if
		
		'if Clng(request.form("redirectLink")) = 0 Then
			redirectLink = "manageQuestions.asp?stepID=" & stepID
		'Else
		'	redirectLink = "manageRounds.asp?stepID=" & stepID
		'End If
		response.redirect redirectLink
	
	case "save_answers"
		
		stepID = request.form("stepID")
		
		if stepID <> "" then
			
			participant = Session("email")
			
			questionID = split(request.form("questionID[]"), ", ")
			questionType = split(request.form("questionType[]"), ", ")
			operation = split(request.form("operation[]"), ", ")
			
			'response.write(request.form("stepID") & " --- " & request.form("roundID") & "<br>")
			'response.write(request.form("questionID[]") & "<br>")
			'response.write(request.form("questionType[]") & "<br>")
			'response.write(request.form("textAnswer[1]") & "<br>")
			'response.write(request.form("textAnswer[2]") & "<br>")
			'response.write(request.form("textAnswer[3]") & "<br>")
			'response.write(request.form("operation[]") & "<br>")
			'response.write(request.form("optionAnswer[1]") & "<br>")
			'response.write(request.form("optionAnswer[2]") & "<br>")
			'response.write(request.form("optionAnswer[3]") & "<br>")
			'response.write(UBound(questionID) & "<br>")
			
			i = 0
			While i <= UBound(operation)
				'response.write(fwID(i) & ", " & fwEvent(i) & ", " & parentFWID(i) & ", " & posX(i) & ", " & posY(i) & ", " & operation(i) & "<br />")
				
				If CLng(operation(i)) = OPER_NO Then
					'
				ElseIf CLng(operation(i)) = OPER_ADD Then ' New
					
					If Clng(questionType(i)) = QUESTION_TYPE_TXT Then
						
						Call getRecordSet(SQL_CONSULTA_INTERVIEW_TEXT_ANSWER(questionID(i), participant), rs)
						
						textAnswer = ""
						If request.form("textAnswer[" & (i + 1) & "]") <> "" Then
							textAnswer = trim(request.form("textAnswer[" & (i + 1) & "]"))
						End If
						
						If rs.EOF Then
							If textAnswer <> "" Then
								Call executeSQL(SQL_CRIA_INTERVIEW_TEXT_ANSWER(questionID(i), participant, textAnswer))
							End If
						Else
							Call executeSQL(SQL_ATUALIZA_INTERVIEW_TEXT_ANSWER(questionID(i), participant, textAnswer))
						End if
						
					ElseIf Clng(questionType(i)) = QUESTION_TYPE_OPT Then
						
						optionAnswer = ""
						If request.form("optionAnswer[" & (i + 1) & "]") <> "" Then
							optionAnswer = trim(request.form("optionAnswer[" & (i + 1) & "]"))
						End If
						
						If optionAnswer <> "" Then
							Call executeSQL(SQL_CRIA_INTERVIEW_OPTION_ANSWER(questionID(i), participant, optionAnswer))
						End If
						
					End If
					
				ElseIf CLng(operation(i)) = OPER_EDIT Then ' Edit
					
					If Clng(questionType(i)) = QUESTION_TYPE_TXT Then
						
						Call getRecordSet(SQL_CONSULTA_INTERVIEW_TEXT_ANSWER(questionID(i), participant), rs)
						
						textAnswer = ""
						If request.form("textAnswer[" & (i + 1) & "]") <> "" Then
							textAnswer = trim(request.form("textAnswer[" & (i + 1) & "]"))
						End If
						
						If rs.EOF Then
							If textAnswer <> "" Then
								Call executeSQL(SQL_CRIA_INTERVIEW_TEXT_ANSWER(questionID(i), participant, textAnswer))
							End If
						Else
							Call executeSQL(SQL_ATUALIZA_INTERVIEW_TEXT_ANSWER(questionID(i), participant, textAnswer))
						End if
						
					ElseIf Clng(questionType(i)) = QUESTION_TYPE_OPT Then
						
						optionAnswer = ""
						If request.form("optionAnswer[" & (i + 1) & "]") <> "" Then
							optionAnswer = trim(request.form("optionAnswer[" & (i + 1) & "]"))
						End If
						
						If optionAnswer <> "" Then
							Call executeSQL(SQL_ATUALIZA_INTERVIEW_OPTION_ANSWER(questionID(i), participant, optionAnswer))
						End If
						
					End If
				
				ElseIf CLng(operation(i)) = OPER_DEL Then ' Edit
					'
				Else
					Session("welcomeMessage") = "Invalid operation for interview question. Please inform the system administrator."	
				End If
				
				i = i + 1
			Wend
			
		else
		
			Session("welcomeMessage") = "No step id supplied. Please inform the system administrator."	
		
		end if
		
		If Session("welcomeMessage") = "" Then
			Session("welcomeMessage") = "Interview answered successfully. Thanks for answering it."
		End If
		
		Session("Message") = "Answers successfully stored. Thank you for your time."

		'redirectLink = "index.asp?stepID=" & stepID & "&redirect=1"
		redirectLink = "/index.asp"
		response.redirect redirectLink
	
	case "end"

		if request.querystring("stepID") <> "" then
			call endStep(request.querystring("stepID"))
		
			response.redirect "/workplace.asp"
		end if

	case else
		
		call response.write ("Invalid action supplied. Please inform the system administrator.")
		
end select

%>
