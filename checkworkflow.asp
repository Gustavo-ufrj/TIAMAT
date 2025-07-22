<%
if not Session("admin") then
	if Request.QueryString("workflowID") <> "" then
		Dim rsTEMP665480312315 ' para não bater com outras variáveis
		
		call getRecordset(SQL_CONSULTA_ACCESS_WORKFLOW(Session("email"), Request.QueryString("workflowID")), rsTEMP665480312315)


		if rsTEMP665480312315.eof then
			
			' Session.Contents.RemoveAll()
			
			' Session("loginError") = "Access denied to the workflow."
			
			' if Request.Querystring & Request.Form <> "" then
				' Session("afterLoginGoTo") = Request.ServerVariables("URL") & "?" & Request.Querystring & Request.Form
			' else
				' Session("afterLoginGoTo") = Request.ServerVariables("URL")
			' end if
			
			' rsTEMP665480312315.Close : Set rsTEMP665480312315 = Nothing
			
			' response.redirect "/login.asp"
			
			Session("message") = "Access denied to the Workflow. Only the owner and administrators can access them."
			
			response.redirect "/workplace.asp"
		end if 
	end if 
end if 

%>