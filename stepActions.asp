<!--#include virtual="/system.asp"-->

<% 

function processaEmail (email)
	Dim arrayTemp ()
	Dim arrayFinal ()
	Dim strTemp, i
	redim arrayTemp (1)
	strTemp = replace(email, "[""" , "")  
	strTemp = replace(strTemp, """]", "") 
	i=0

	while instrRev(strTemp, "<") > 0 and instrRev(strTemp, ">") > 0
		arrayTemp(i) = mid(strTemp, instrRev(strTemp, "<")+1, instrRev(strTemp, ">") - instrRev(strTemp, "<") -1)
		strTemp = left(strTemp, instrRev(strTemp, "<")-1)
		i = i+1
		redim preserve arrayTemp (i)
	wend
	redim preserve arrayTemp (i-1)
	redim arrayFinal(i-1)
	for j = 0 to i-1
		arrayFinal(j) = arrayTemp(ubound(arrayTemp)-j)
	next
	processaEmail = arrayFinal
end function

	Dim rs
	dim sql_consulta, retorno
	Dim action
	Dim stepID

	Dim workflowID, FTAMethodID
	Dim role	
	Dim x, y	
	
action = Request.Querystring("action")
	
select case action
	
case "new"
		
    Dim urlRetorno

	workflowID = request.form("workflowID")

	if workflowID = "" then
		' Cria o Workflow
		Set cnn = getConnection
		Call chamaSP(True, objSP, "SP_CREATE_WORKFLOW",cnn)
		With objSP
			 .Parameters.Append .CreateParameter("RETORNO", adBigInt,adParamReturnValue)
			 .Parameters.Append .CreateParameter("@description",advarchar,adParamInput,80,"Standard Workflow.")
			 .Parameters.Append .CreateParameter("@goal",advarchar,adParamInput,500,"")
			 .Parameters.Append .CreateParameter("@expectedresult",advarchar,adParamInput,500,"")
			 .Parameters.Append .CreateParameter("@owner_email",advarchar,adParamInput,150,Session("email"))
			 .Execute
			 
			 workflowID = .Parameters("RETORNO")
			 
		End With
		Call chamaSP(False, objSP, Null, Null)
		dispose(cnn)
	end if


	if request.form("ftamethod") <> "" then
		Set cnn = getConnection
		Call chamaSP(True, objSP, "SP_CREATE_WORKFLOW_STEP",cnn)
		With objSP
			 .Parameters.Append .CreateParameter("RETORNO", adBigInt,adParamReturnValue)
			 .Parameters.Append .CreateParameter("@workflowID",adBigInt,adParamInput,8,workflowID)
			 .Parameters.Append .CreateParameter("@type",adInteger,adParamInput,4,cint(request.form("ftamethod")))

			 if getWfStatus(workflowID) > STATE_UNLOCKED then
				.Parameters.Append .CreateParameter("@status",adInteger,adParamInput,4,STATE_LOCKED)
			 end if

			 .Execute
			 
			 stepID = .Parameters("RETORNO")
			 
		End With

		Call chamaSP(False, objSP, Null, Null)
		dispose(cnn)


		
		
		
		if stepID > 0 then
			
			
			
			if request.form("parentStepID") <> "" then
				call ExecuteSQL(SQL_CRIA_WORKFLOW_STEP(cstr(stepID),request.form("parentStepID")))
			 end if		 
			 
		
		
		'' Tratamento para subWorkflow
		if request.form("ftamethod") = "0" then
			call getRecordset(SQL_CONSULTA_WORKFLOW_ID(workflowID), rsWF)  

			' Cria o Workflow
			Set cnn = getConnection
			Call chamaSP(True, objSP, "SP_CREATE_WORKFLOW",cnn)
			With objSP
				 .Parameters.Append .CreateParameter("RETORNO", adBigInt,adParamReturnValue)
				 .Parameters.Append .CreateParameter("@description",advarchar,adParamInput,80,"Subworkflow of workflow """+rsWF("description")+"""")
				 .Parameters.Append .CreateParameter("@goal",advarchar,adParamInput,500,rsWF("goal"))
				 .Parameters.Append .CreateParameter("@expectedresult",advarchar,adParamInput,500,rsWF("expectedresult"))
				 .Parameters.Append .CreateParameter("@owner_email",advarchar,adParamInput,150,request.form("owner"))
				 .Parameters.Append .CreateParameter("@parentStepID",adBigInt,adParamInput,8,stepID)
				 .Execute
				 
				 subWorkflowID = .Parameters("RETORNO")
				 
			End With
			Call chamaSP(False, objSP, Null, Null)
			dispose(cnn)
		end if

		'' FIM - Tratamento para subWorkflow


 
			set userlist = getUserListbyID(request.form("ftamethod"))

			
			for i=0 to userlist.length-1
				role = userlist(i).getAttribute("role")
				
				for j=1 to request.form(role).Count 
	
					for each user in UniqueValues(processaEmail(request.form(role)(j)))
							set rs = ExecuteSQL(SQL_ADICIONA_USUARIO_WORKFLOW_STEP(stepID, user, role))
					next
				next
			next



			if request.form("parentStepID") <> "" then
				call getRecordSet (SQL_CONSULTA_WORKFLOW_PARENT_STEP_POSITION(request.form("parentStepID")), rs)
				if not rs.eof then
					x = rs("posX")
					y = rs("posY") + 400
				end if
			else
					x = 450
					y = 0
			end if
			
			Set cnn = getConnection
			Call chamaSP(True, objSP, "SP_SAVE_WORKFLOW_POSITION",cnn)
			With objSP
				.Parameters.Append .CreateParameter("@stepID",adInteger,adParamInput,8,stepID)
				.Parameters.Append .CreateParameter("@posX",adInteger,adParamInput,4,x)
				.Parameters.Append .CreateParameter("@posY",adInteger,adParamInput,4,y)
				.Execute

			End With

			Call chamaSP(False, objSP, Null, Null)
			dispose(cnn)


			if request.form("ftamethod") = "0" then
				' subWorkflow
				urlRetorno = "/manageWorkflow.asp?workflowID="+cstr(subWorkflowID)
			else
				' simple fta method
				urlRetorno = "/manageWorkflow.asp?workflowID="+cstr(workflowID)
			end if
			
			Response.Write ("<script>" & "top.location.href='" & urlRetorno & "';" & "</script>")
			
		else 
			response.write "Workflow Step could not be created. Please inform the system administrator."
		end if
	else
		response.write "FTA Method not informed. Please inform the system administrator."
	end if

	
	
	
	
	case "update"

	if request.form("ftamethod") <> "" then
		stepID = cint(request.form("stepID"))
		if stepID > 0 then
			set userlist = getUserListbyID(request.form("ftamethod"))
			
			set rs = ExecuteSQL(SQL_DELETE_USERS_FROM_WORKFLOW_STEP(cstr(stepID)))
			
			for i=0 to userlist.length-1

				role = userlist(i).getAttribute("role")
				
				for j=1 to request.form(role).Count 
	
					for each user in processaEmail(request.form(role)(j))
						set rs = ExecuteSQL(SQL_ADICIONA_USUARIO_WORKFLOW_STEP(stepID, user, role))
					next
				next
			next

			if request.form("parentStepID") <> "" then
				call getRecordSet (SQL_CONSULTA_WORKFLOW_PARENT_STEP_POSITION(request.form("parentStepID")), rs)
				if not rs.eof then
					x = rs("posX")
					y = rs("posY") + 400
				end if
			else
					x = 450
					y = 0
			end if
			
			Set cnn = getConnection
			Call chamaSP(True, objSP, "SP_SAVE_WORKFLOW_POSITION",cnn)
			With objSP
				.Parameters.Append .CreateParameter("@stepID",adInteger,adParamInput,8,stepID)
				.Parameters.Append .CreateParameter("@posX",adInteger,adParamInput,4,x)
				.Parameters.Append .CreateParameter("@posY",adInteger,adParamInput,4,y)
				.Execute

			End With

			Call chamaSP(False, objSP, Null, Null)
			dispose(cnn)


			
			Response.Write("<scr"+"ipt>")
			Response.Write("window.opener.location='/manageWorkflow.asp?workflowID="+request.form("workflowID")+"';")
			Response.Write("window.close();")
			Response.Write("</scr"+"ipt>")
			
		else 
			response.write "Workflow Step could not be created. Please inform the system administrator."
		end if
	else
		response.write "FTA Method not informed. Please inform the system administrator."
	end if

	
	case "rewind"
	
		if request.querystring("stepID") <> "" and request.querystring("status") <> ""  then
		
			status = cint(request.querystring("status"))
			if cint(request.querystring("status")) < 1 then
				status = 1
			end if			
			
			call ExecuteSQL(SQL_SET_STATUS_WORKFLOW_STEP(request.querystring("stepID"), cstr(status)))
	
			Response.redirect "manageWorkflow.asp?workflowID="+request.querystring("workflowID")

		else
		
			Response.Write "Step not found. Please inform the system administrator."
		
		end if 
		
		
	case "delete"
	
		if request.querystring("stepID") <> "" then
		
			call ExecuteSQL(SQL_DELETE_USERS_FROM_WORKFLOW_STEP(request.querystring("stepID")))

			
			call ExecuteSQL(SQL_DELETE_WORKFLOW_STEP_X_STEP(request.querystring("stepID")))
			
	
			call ExecuteSQL(SQL_DELETE_WORKFLOW_STEP(request.querystring("stepID")))

			Response.redirect "manageWorkflow.asp?workflowID="+request.querystring("workflowID")

		else
		
			Response.Write "Step not found. Please inform the system administrator."
		
		end if 
		

	case "deleteSI"
	
		if request.querystring("stepID") <> ""  and request.querystring("file") <> "" then
		
			call ExecuteSQL(SQL_DELETE_WORKFLOW_STEP_SUPPORTING_INFORMATION(request.querystring("stepID"), request.querystring("file")))

			' Remover arquivo fisicamente
			Set fs=Server.CreateObject("Scripting.FileSystemObject")
			if fs.FileExists(Server.MapPath(request.querystring("file"))) then
				call fs.DeleteFile(Server.MapPath(request.querystring("file")), true)
  			end if
			set fs=nothing
			
			Response.redirect getCurrentURL()
			

		else
		
			Response.Write "Step or file not found. Please inform the system administrator."
		
		end if 
		
	case "addParent"
	
		if request.querystring("stepID") <> ""  and request.querystring("parentStepID") <> "" and request.querystring("parentStepID") <> request.querystring("stepID") then 
			if not isParentStep(request.querystring("stepID"), request.querystring("parentStepID")) then
				call ExecuteSQL(SQL_CRIA_WORKFLOW_STEP(request.querystring("stepID"),request.querystring("parentStepID")))
				Response.Status = "202 Accepted"
			else 
				Response.Status = "410 Gone"
			end if
		else 
			Response.Status = "410 Gone"
		end if
		'Response.redirect "manageWorkflow.asp?workflowID="+request.querystring("workflowID")
		
	case "removeParent"

		if request.querystring("stepID") <> ""  and request.querystring("parentStepID") <> "" then 
			call ExecuteSQL(SQL_DELETE_WORKFLOW_STEP_PARENT(request.querystring("stepID"),request.querystring("parentStepID")))
			Response.Status = "202 Accepted"
		else 
			Response.Status = "410 Gone"
		end if
		'Response.redirect "manageWorkflow.asp?workflowID="+request.querystring("workflowID")
	
			
				
	case "generate_link"
		stepID = request.form("stepID") 
		role = request.form("role") 
		workflowID = request.form("workflowID") 
		code = request.form("code") 
		verification = sha256(workflowID & code)
		
		if stepID <> "" and role <> "" and role <> "" and workflowID <> "" and code <> "" and verification <> "" then 

			call getRecordSet(SQL_CONSULTA_WORKFLOW_STEP_INVITATION(stepID, role, workflowID, code, verification), rs)
			
			if rs.EOF then
				'Só insere se não for repetido
				call ExecuteSQL(SQL_CRIA_WORKFLOW_STEP_INVITATION(stepID, role, workflowID, code, verification))
			end if
		end if
		
		Response.redirect "link.asp?workflowID="&workflowID&"&code=" & code & "&verification=" & verification

			
case "join"
		code = request.querystring("code") 
		verification = request.querystring("verification")
		email = Session("email")
		
		if email <> "" and code <> "" and verification <> "" then 

			call getRecordSet(SQL_CONSULTA_WORKFLOW_STEP_INVITATION_VALIDATION(code, verification), rs)
			
			while not rs.EOF 

				stepID=rs("stepID")
				role= rs("role")
				call getRecordSet(SQL_CONSULTA_USUARIO_WORKFLOW_STEP(cstr(stepID), email, role), rs2)
				
				if rs2.EOF then
					call ExecuteSQL(SQL_ADICIONA_USUARIO_WORKFLOW_STEP(stepID, email, role))
				end if 

				rs.movenext
			wend
		end if
		
		Response.redirect "workplace.asp"

		
	case else
	
		call response.write ("Invalid action supplied. Please inform the system administrator.")
		
	end select
	
	
%>


		
	