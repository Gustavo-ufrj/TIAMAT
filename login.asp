<!--#include file="system.asp"-->

<% 

if not isnull(request.form("email")) and not isnull(request.form("password")) and (request.servervariables("content_length") <> 0 ) then
	estado = login(trim(request.form("email")),trim(request.form("password")))
	if not (estado <> 1) then	
		' Login OK
		if request.form("afterLoginGoTo") <> "" then
			response.redirect request.form("afterLoginGoTo")
		else
			response.redirect "/workplace.asp"
		end if 
	else 
		Session("loginError") = "Incorrect e-mail or password. Try again."
	end if
else 
		Session("loginError") = "Invalid e-mail or password. Try again."
end if
	
	response.redirect "/workplace.asp"
%>
