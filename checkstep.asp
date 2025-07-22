<%
if not Session("admin") then
	if Request.QueryString("stepID") <> "" then
		Dim rsTEMP1564672318	' para não bater com outras variáveis
		
		call getRecordset(SQL_CONSULTA_ACCESS_STEP(Session("email"), Request.QueryString("stepID")), rsTEMP1564672318)

		if rsTEMP1564672318.eof then
			
			Session.Contents.RemoveAll()
			
			Session("loginError") = "Access denied to the FTA Method."
			
			if Request.Querystring & Request.Form <> "" then
				Session("afterLoginGoTo") = Request.ServerVariables("URL") & "?" & Request.Querystring & Request.Form
			else
				Session("afterLoginGoTo") = Request.ServerVariables("URL")
			end if

			response.redirect "/login.asp"
			
		end if 
	end if 
end if 
%>