<!--#include virtual="/system.asp"-->
<!--#include virtual="/checklogin.asp"-->
<!--#include virtual="/checkadmin.asp"-->
<!--#include virtual="/includes/JSON.asp"-->


<%


	Dim usuarios
	dim sql_consulta, retorno
	Dim action
			
	action = Request.Querystring("action")
	
	select case action
	
	

	case "new"
		
		'Call FormDataDump(false, false)

		set d = server.createObject("scripting.dictionary")
		
		if request.form("email") <> "" and request.form("newpassword") <> "" then
		
			dim usuario
			
			Call getRecordSet(SQL_CONSULTA_USUARIO_EMAIL(request.form("email")), usuario)
			
			' Checar se o email esta cadastrado
			if usuario.eof then
				' Salvar
				
				FTAcreator = "0"
				if not isnull(request.form("ismanager")) and request.form("ismanager") = "on" then
				FTAcreator = "1"
				end if

				isadmin = "0"
				if not isnull(request.form("isadmin")) and request.form("isadmin") = "on"  then
				isadmin = "1"
				end if

				call ExecuteSQL(SQL_CRIA_USUARIO(request.form("email"), request.form("newname"), sha256(request.form("newpassword")), FTAcreator, isadmin))

				Session("message") = "User saved successfully."
			else
				Session("message") = "The supplied e-mail is already registered. Try another e-mail."
			end if
		else 
			Session("message") = "You must supply a email and password for the user. Try again."
		end if 
		
		
	case "update"
	
		set d = server.createObject("scripting.dictionary")

		if request.form("editname") <> "" then
			' Salvar
			
				Dim flagChangePassword
				flagChangePassword = request.form("changePasswordCheck") = "on"

				FTAcreator = "0"
				if not isnull(request.form("editismanager")) and request.form("editismanager") = "on" then
					FTAcreator = "1"
				end if

				isadmin = "0"
				if not isnull(request.form("editisadmin")) and request.form("editisadmin") = "on"  then
					isadmin = "1"
				end if
				
				if flagChangePassword then
					if request.form("editpassword") <> "" then
					  call ExecuteSQL(SQL_ATUALIZA_USUARIO(request.form("editemail"), request.form("editname"), sha256(request.form("editpassword")), FTAcreator, isadmin))
					  Session("message") = "User saved successfully."
					else
						Session("message") = "Please, provide a password for the user. Try again."
					end if 
				else
					 call ExecuteSQL(SQL_ATUALIZA_USUARIO_SEM_SENHA(request.form("editemail"), request.form("editname"), FTAcreator, isadmin))
 					 Session("message") = "User saved successfully."
				end if 

		else
			Session("message") = "Please, provide a name for the user. Try again."
		end if 

	case "delete"
		call ExecuteSQL(SQL_DELETE_USUARIO_EMAIL(request.QueryString("email")))
		
		call ExecuteSQL(SQL_DELETE_USUARIO_FROM_STEP(request.QueryString("email")))
		
			Call getRecordSet(SQL_CONSULTA_USUARIO_EMAIL(request.QueryString("email")), usuario)
			
			' Checar se o email esta cadastrado
			if usuario.eof then
				Session("message") = "The user was successfully removed from the system."
			else
				Session("message") = "The user cannot be removed from the system."
			end if
			
	case else
	
		Session("message") = "Invalid action supplied. Please inform the system administrator."
		
	end select
	
	Response.Redirect "/administration.asp"
	
	
%>

