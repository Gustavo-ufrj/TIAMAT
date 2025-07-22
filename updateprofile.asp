<!--#include file="system.asp"-->

<% 



if Session("email") <> "" and not isnull(request.form("password")) and (request.servervariables("content_length") <> 0 ) then
	estado = login(Session("email"),trim(request.form("password")))
	if estado = 1 then	
		if not isnull(request.form("newpassword")) and not isnull(request.form("newpassword2")) and request.form("newpassword") <> "" and request.form("newpassword2") <> "" then
			if request.form("newpassword") = request.form("newpassword2") then
				Call Refresh_User_Profile(Session("email"),request.form("name"), sha256(request.form("newpassword")))
				Session("message") = "Profile updated successfully."
				response.redirect "workplace.asp"
			else
				Session("loginError") = "The new password not match. Try again."
				response.redirect "profile.asp"
			end if 
		else
			Call Refresh_User_Profile(Session("email"),request.form("name"), sha256(request.form("password")))
			Session("message") = "Profile updated successfully."
			response.redirect "workplace.asp"
		end if
	else
			Session("loginError") = "Invalid e-mail or password. Try again."
			response.redirect "profile.asp"
	end if
else 
		Session("loginError") = "Invalid e-mail or password. Try again."
		response.redirect "profile.asp"
end if
		
	%>
