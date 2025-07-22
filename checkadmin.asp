<%

if not Session("admin") then
	Session.Contents.RemoveAll()
	
	Session("loginError") = "Access Denied. Please log in with an administrative account."
	
	if Request.Querystring & Request.Form <> "" then
		Session("afterLoginGoTo") = Request.ServerVariables("URL") & "?" & Request.Querystring & Request.Form
	else
		Session("afterLoginGoTo") = Request.ServerVariables("URL")
	end if

	response.redirect "/index.asp"
end if 

%>