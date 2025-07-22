<!--#include virtual="/system.asp"-->
<!--#include virtual="/includes/JSON.asp"-->


<%


	Dim usuarios
	dim sql_consulta, retorno
	Dim action
	Dim stepID
	Dim role
			
	action = Request.Querystring("action")
	stepID = Request.Querystring("stepID")
	role = Request.Querystring("role")

	select case action
	
	
	case "new"

	if request.form("participant") <> "" then

		dim usuario
		Call getRecordSet(SQL_CONSULTA_USUARIO_EMAIL(request.form("participant")), usuario)
				
		' Checar se o email esta cadastrado
		if not usuario.eof then

			Call getRecordSet(SQL_CONSULTA_USERS_FROM_WORKFLOW_STEP_BY_STEPID_EMAIL_ROLE(stepID, request.form("participant"), role), usuario)
					
			'checar se o usuário está no step
			if usuario.eof then
				call ExecuteSQL(SQL_ADICIONA_USUARIO_WORKFLOW_STEP(stepID, request.form("participant"), role))
				Session("message") = "The user was successfully added."
			else
				Session("message") = "The user is already a participant in this the FTA Step."
			end if
				
		else 
			Session("message") = "Invalid user. Try again."
		end if 

	else 
		Session("message") = "Invalid user. Try again."
	end if 
					
		
	case "delete"
		
		call ExecuteSQL(SQL_DELETE_USERS_FROM_WORKFLOW_STEP_BY_STEPID_EMAIL_ROLE(stepID, request.Querystring("email"), role))

		Session("message") = "User successfully removed from step."
		
	
	case else
		Session("message") = "Invalid action supplied. Please inform the system administrator."
		
	end select
	
	Response.Redirect "/editStep.asp?stepID=" & stepID & "&role=" & role
	
%>

