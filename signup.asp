<!--#include file="system.asp"-->

<% 

function signup(name,user,password)
	Dim usuario
	dim sql_consulta
	if not isnull(user) and not isnull(password) and not password = "" then
		signup = 0
		Call getRecordSet(SQL_CONSULTA_USUARIO_EMAIL(user), usuario)
		if usuario.eof then 
			call ExecuteSQL(SQL_CRIA_USUARIO(user, name, sha256(replace(password, "'", "")), "0", "0"))
			Call getRecordSet(SQL_CONSULTA_USUARIO_LOGIN(user, sha256(replace(password, "'", ""))), usuario)
			if not(usuario.eof) then
				Session("email") = usuario("email")
				Session("name") = usuario("name")
				Session("photo") = usuario("photo")
				Session("admin") = usuario("admin")
				Session("loginError") = NULL
				signup=1
			else
				signup = 0
			end if
		else
			signup = 3
		end if
	else
		signup = 2
	end if
end function


if not isnull(request.form("su_name")) and not isnull(request.form("su_email")) and not isnull(request.form("su_password")) and (request.servervariables("content_length") <> 0 ) then
	estado =  signup(trim(request.form("su_name")),trim(request.form("su_email")),trim(request.form("su_password")))
	if estado <> 1 then	
		Session("loginError") = "The e-mail "+request.form("su_email")+" is already in use."
		response.redirect "/signin.asp"
	else
		if request.form("afterLoginGoTo") <> "" then
			response.redirect request.form("afterLoginGoTo")
		else
			response.redirect "/workplace.asp"
		end if 
	end if
	
end if
	
	
%>


