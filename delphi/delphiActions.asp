<!--#include virtual="/system.asp"-->
<!--#include virtual="/includes/JSON.asp"-->
<!--#include file="INC_DELPHI.inc"-->

<%

Dim rs
Dim action
Dim redirectLink

Dim url
url =""



Dim stepID
Dim roundID

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

Session("delphiError") = ""
Session("delphiRoundsError") = ""
Session("delphiQuestionsError") = ""

Set d = server.createObject("scripting.dictionary")

select case action

			
	case "new_round"
		
		stepID = request.form("stepID")
		text = trim(request.form("description"))
		state = 0 ' Always created as unpublished
		
		If stepID <> "" Then
			
			If text <> "" And state <> "" Then
				
				insert = True
				
				If Clng(state) = STATE_PUB Then
					Call getRecordSet(SQL_CONSULTA_DELPHI_ROUNDS_STATE(stepID, STATE_PUB), rs)
					
					If Not rs.EOF Then
						insert = False
  						    Session("message") = "You cannot add a new round when there is another published one."	
							url="index.asp?stepID="+request.form("stepID")
					End If
				End If
				
				If insert Then
					Set cnn = getConnection
					Call chamaSP(True, objSP, "SP_CREATE_FTA_METHOD_DELPHI_ROUND",cnn)
					With objSP
						 .Parameters.Append .CreateParameter("RETORNO", adBigInt,adParamReturnValue)
						 .Parameters.Append .CreateParameter("@delphiID",adBigInt,adParamInput,8,stepID)
						 .Parameters.Append .CreateParameter("@state",adInteger,adParamInput,4,state)
						 .Parameters.Append .CreateParameter("@text",advarchar,adParamInput,1023,text)
						 .Execute
						 
						 insertedRoundID = .Parameters("RETORNO")
					End With
					Call chamaSP(False, objSP, Null, Null)
					dispose(cnn)
				
					If insertedRoundID > -1 Then
							url="index.asp?stepID="+request.form("stepID")
					Else
						Response.write "An error has occurred when inserting the round. Please inform the system administrator."
					End If
				End If
			Else
				Response.write "No round necessary information supplied."
			End If
		Else
			Response.write "No stepID supplied information supplied. Please inform the system administrator."
		End If
		
	case "update_round"
		
		stepID = request.form("stepID")
		
		If stepID <> "" Then
			
			roundID = request.form("roundID")
			state = request.form("state")
			text = trim(request.form("description"))
			
			If roundID <> "" And state <> "" And text <> "" Then
			    
				
				 url="index.asp?stepID="+request.form("stepID")
				 update = True
				
				 Call getRecordSet(SQL_CONSULTA_DELPHI_ROUND(roundID), rs)
				
				If Clng(rs("state")) = STATE_END And CLng(state) < STATE_END Then
					
					update = False
					Session("message") = "Once a round is ended, it is not possible to change its state."	
				
					
				ElseIf Clng(rs("state")) = STATE_PUB And CLng(state) < STATE_PUB Then
					
					update = False
					Session("message") = "Once a round is published, it is not possible to change its state to ""unpublished""."	
					
					
				ElseIf Clng(state) = STATE_PUB Then
					Call getRecordSet(SQL_CONSULTA_DELPHI_ROUNDS_STATE(stepID, STATE_PUB), rs)
					
					If Not rs.EOF Then
						update = False
						Session("message") = "You cannot publish a round when there is another published one."	
					End If
				End If
				
				If update Then
					Call ExecuteSQL(SQL_ATUALIZA_DELPHI_ROUND(roundID, state, text))
					
				End If
			Else
				Response.write "No round informations supplied."
			End If
		Else
			Response.write "No stepID supplied. Please inform the system administrator."
		End If
		
	case "delete_round"
		
		roundID = request.Querystring("roundID")
		
		If roundID <> "" Then
			
			Call ExecuteSQL(SQL_EXCLUI_DELPHI_ROUND(roundID))
		
		End If
			
		url="index.asp?stepID="+request.Querystring("stepID")

	case "save"
		Dim retorno
		retorno = 0
		
		stepID = request.form("stepID")
		
		If stepID <> "" Then
			
			text = SQLInject(trim(request.form("description")))

			If text <> "" Then
			
				Call getRecordSet(SQL_CONSULTA_DELPHI(stepID), rs)

				if not rs.EOF then
					Call ExecuteSQL(SQL_ATUALIZA_DELPHI(stepID, text))
				else
					
					
						Set cnn = getConnection
						Call chamaSP(True, objSP, "SP_CREATE_FTA_METHOD_DELPHI",cnn)
						With objSP
							 .Parameters.Append .CreateParameter("RETORNO", adBigInt,adParamReturnValue)
							 .Parameters.Append .CreateParameter("@stepID",adBigInt,adParamInput,8,clng(stepID))
							 .Parameters.Append .CreateParameter("@text",adLongVarChar,adParamInput,len(text),text)
							 .Execute
							 
							retorno = .Parameters("RETORNO")
							 
						End With
						Call chamaSP(False, objSP, Null, Null)
						dispose(cnn)
					
				end if
				
				
			else
				Session("delphiError") = "No delphi information supplied. Please inform the system administrator."	
			
			end if
		else
			Session("delphiError") = "Invalid delphi id. Please inform the system administrator."	
		
		end if
		
		url="index.asp?stepID="+stepID
	

	case "save_question"

		url="manageQuestions.asp?stepID="+request.form("stepID")+"&roundID="+request.form("roundID")
	
		stepID = request.form("stepID")
		roundID = request.form("roundID")
		
		if stepID <> "" And roundID <> "" then
			
			newQuestionText = SQLInject(trim(request.form("question")))
			newOptionID = split(request.form("OptionID[]"), ", ")
			newOptionText = split(request.form("Option[]"), ", ")
	
			Set cnn = getConnection
			Call chamaSP(True, objSP, "SP_CREATE_FTA_METHOD_DELPHI_QUESTION",cnn)
			With objSP
				 .Parameters.Append .CreateParameter("RETORNO", adBigInt,adParamReturnValue)
				 .Parameters.Append .CreateParameter("@text",adLongVarChar,adParamInput,len(newQuestionText),newQuestionText)
				 .Parameters.Append .CreateParameter("@roundID",adBigInt,adParamInput,8,roundID)
				 .Execute
				 
				 insertedQuestionID = .Parameters("RETORNO")
				 
			End With
			Call chamaSP(False, objSP, Null, Null)
			dispose(cnn)
			
			If insertedQuestionID = -1 Then
				Session("delphiQuestionsError") = "An error has occurred when trying to create a new question. Please inform the system administrator."
			Else
				insertedOptionID = -1
				
				j = 0
				While j <= UBound(newOptionText)
					If trim(newOptionText(j)) <> "" Then
						
						Set cnn = getConnection
						Call chamaSP(True, objSP, "SP_CREATE_FTA_METHOD_DELPHI_OPTION",cnn)
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
							Session("delphiQuestionsError") = "An error has occurred when trying to create a new question option. Please inform the system administrator."
						Else
							'
						End If
					
					End If
					
					j = j + 1
				Wend
			
			
			end if
	end if
		
		
	case "update_question"

		url="manageQuestions.asp?stepID="+request.form("stepID")+"&roundID="+request.form("roundID")

		
		stepID = request.form("stepID")
		roundID = request.form("roundID")
		questionID = request.form("questionID")
		
		if stepID <> "" And roundID <> "" then

   		    newQuestionText = SQLInject(trim(request.form("question")))
			newOptionID = split(request.form("OptionID[]"), ", ")
			newOptionText = split(request.form("Option[]"), ", ")
			
			Call ExecuteSQL(SQL_ATUALIZA_DELPHI_QUESTION(questionID, newQuestionText))
						
			j = 0
			While j <= UBound(newOptionText)
				insertedOptionID = -1
				
				If newOptionID(j) = ""  AND  trim(newOptionText(j)) <> "" Then 'NEW
					Set cnn = getConnection
					Call chamaSP(True, objSP, "SP_CREATE_FTA_METHOD_DELPHI_OPTION",cnn)
					With objSP
						 .Parameters.Append .CreateParameter("RETORNO", adBigInt,adParamReturnValue)
						 .Parameters.Append .CreateParameter("@text",advarchar,adParamInput,1023,trim(newOptionText(j)))
						 .Parameters.Append .CreateParameter("@questionID",adBigInt,adParamInput,8,questionID)
						 .Execute
						 
						 insertedOptionID = .Parameters("RETORNO")
						 
					End With
					Call chamaSP(False, objSP, Null, Null)
					dispose(cnn)
					
					If insertedOptionID = -1 Then
						Session("delphiQuestionsError") = "An error has occurred when trying to create a new question option. Please inform the system administrator."
					Else
						'
					End If
				ElseIf newOptionID(j) <> "" AND  trim(newOptionText(j)) <> "" Then
						Call ExecuteSQL(SQL_ATUALIZA_DELPHI_OPTION(newOptionID(j), trim(newOptionText(j))))
				ElseIf newOptionID(j) <> "" AND  trim(newOptionText(j)) = "" Then
					Call ExecuteSQL(SQL_EXCLUI_DELPHI_OPTION(newOptionID(j)))
				End If
				
				j = j + 1
			Wend
			
			
		end if

		
	case "delete_question"
		
		roundID = request.Querystring("roundID")
		stepID = request.Querystring("stepID")
		questionID = request.Querystring("questionID")
		
		If questionID <> "" Then
			
			Call ExecuteSQL(SQL_EXCLUI_DELPHI_QUESTION(questionID))
		
		End If
			
		url="manageQuestions.asp?stepID="+stepID+"&roundID="+roundID
				

	case "save_answers"
		
		roundID = request.form("roundID")
		stepID = request.form("stepID")

		if roundID <> "" then
			
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
						
						Call getRecordSet(SQL_CONSULTA_DELPHI_TEXT_ANSWER(questionID(i), participant), rs)
						
						textAnswer = SQLInject(trim(request.form("textAnswer[" & (i + 1) & "]")))
						
						If rs.EOF Then
							If textAnswer <> "" Then
								Call executeSQL(SQL_CRIA_DELPHI_TEXT_ANSWER(questionID(i), participant, textAnswer))
							End If
						Else
							Call executeSQL(SQL_ATUALIZA_DELPHI_TEXT_ANSWER(questionID(i), participant, textAnswer))
						End if
						
					ElseIf Clng(questionType(i)) = QUESTION_TYPE_OPT Then
						
						optionAnswer = request.form("optionAnswer[" & (i + 1) & "]")
						
						If optionAnswer <> "" Then
							Call executeSQL(SQL_CRIA_DELPHI_OPTION_ANSWER(questionID(i), participant, optionAnswer))
						End If
						
					End If
					
				ElseIf CLng(operation(i)) = OPER_EDIT Then ' Edit
					
					If Clng(questionType(i)) = QUESTION_TYPE_TXT Then
						
						Call getRecordSet(SQL_CONSULTA_DELPHI_TEXT_ANSWER(questionID(i), participant), rs)
						
						textAnswer = SQLInject(trim(request.form("textAnswer[" & (i + 1) & "]")))
						
						If rs.EOF Then
							If textAnswer <> "" Then
								Call executeSQL(SQL_CRIA_DELPHI_TEXT_ANSWER(questionID(i), participant, textAnswer))
							End If
						Else
							Call executeSQL(SQL_ATUALIZA_DELPHI_TEXT_ANSWER(questionID(i), participant, textAnswer))
						End if
						
					ElseIf Clng(questionType(i)) = QUESTION_TYPE_OPT Then
						
						optionAnswer = request.form("optionAnswer[" & (i + 1) & "]")
						
						If optionAnswer <> "" Then
							Call executeSQL(SQL_ATUALIZA_DELPHI_OPTION_ANSWER(questionID(i), participant, optionAnswer))
						End If
						
					End If
				
				ElseIf CLng(operation(i)) = OPER_DEL Then ' Edit
					'
				Else
					Session("delphiAnswerError") = "Invalid operation for delphi question. Please inform the system administrator."	
				End If
				
				i = i + 1
			Wend
			
		else
		
			Session("delphiError") = "No round id supplied. Please inform the system administrator."	
		
		end if
		
		redirectLink = "index.asp?stepID=" & stepID & "&redirect=1"
		response.redirect redirectLink

	case "move_up"

	roundID = request.querystring("roundID")
	stepID = request.querystring("stepID")
	questionID = request.querystring("questionID")

	url="manageQuestions.asp?stepID="+stepID+"&roundID="+roundID

	'Dim ordemUltima, ordemPenultima,ordemAtual, newOrder
	ordemUltima = 0
	ordemPenultima = 0
	
	Call getRecordSet(SQL_CONSULTA_DELPHI_ROUND_QUESTIONS(roundID), rs)
		
	do while (not rs.eof)
		ordemAtual = IIf(isnull(rs("questionOrder")), 0, rs("questionOrder"))
			
		if cstr(rs("questionID")) = questionID then
			exit do
		end if 
		ordemPenultima = ordemUltima
		ordemUltima = ordemAtual

		rs.movenext
	loop
	
	if (ordemPenultima = ordemUltima or ordemAtual = ordemUltima) then
		newOrder = ordemAtual / 2
	else
		newOrder = (ordemPenultima + ordemUltima) / 2
	end if


	Call ExecuteSQL(SQL_ATUALIZA_DELPHI_QUESTION_ORDER(questionID, newOrder))
	
	
	case "move_down"

	roundID = request.querystring("roundID")
	stepID = request.querystring("stepID")
	questionID = request.querystring("questionID")

	url="manageQuestions.asp?stepID="+stepID+"&roundID="+roundID

	'Dim ordemProxima, ordemSeguinte, ordemAtual, newOrder
	ordemProxima = -1
	ordemSeguinte = -1
	
	Call getRecordSet(SQL_CONSULTA_DELPHI_ROUND_QUESTIONS(roundID), rs)
		
	do while (not rs.eof)
		ordemAtual = 0
		if not isnull(rs("questionOrder")) then
			ordemAtual = rs("questionOrder")
		end if
	
		if cstr(rs("questionID")) = questionID then
			rs.movenext
			if rs.eof then
			exit do
			end if
			
				ordemProxima = 0
				if not isnull(rs("questionOrder")) then
					ordemProxima = rs("questionOrder")
				end if
			
			rs.movenext
			if rs.eof then
			exit do
			end if
			
				ordemSeguinte = 0
				if not isnull(rs("questionOrder")) then
					ordemSeguinte = rs("questionOrder")
				end if
			
			exit do
		end if 
	
		rs.movenext
	loop
	
	if (ordemProxima = ordemSeguinte or ordemAtual = ordemProxima) then
		newOrder = ordemAtual + 1
	else
		if  ordemSeguinte = -1 and ordemProxima >= ordemAtual then
			newOrder = ordemProxima  + 1
		else
			newOrder = (ordemProxima + ordemSeguinte) / 2
		end if
	end if
	

	Call ExecuteSQL(SQL_ATUALIZA_DELPHI_QUESTION_ORDER(questionID, newOrder))
	
	
	case "end"

		if request.querystring("stepID") <> "" then
			call endStep(request.querystring("stepID"))
		
			response.redirect "/workplace.asp"
		end if
	
end select

%>
<% if url <> "" then %>
<script>
top.location.href="<%=url%>"
</script>
<% End if %>
