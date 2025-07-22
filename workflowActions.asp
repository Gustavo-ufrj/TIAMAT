<!--#include virtual="/system.asp"-->
<!--#include virtual="/includes/JSON.asp"-->


<%



	
	
	Dim usuarios
	dim sql_consulta, retorno
	Dim action
			
	action = Request.Querystring("action")
	
	select case action
	
	case "new" 
		
		if Session("email") <> "" then
			
			Set cnn = getConnection
				Call chamaSP(True, objSP, "SP_CREATE_WORKFLOW",cnn)
				With objSP
					.Parameters.Append .CreateParameter("RETORNO", adBigInt,adParamReturnValue)
					.Parameters.Append .CreateParameter("@description",advarchar,adParamInput,80,request.form("title"))
					.Parameters.Append .CreateParameter("@goal",advarchar,adParamInput,500,request.form("description"))
					.Parameters.Append .CreateParameter("@expectedresult",advarchar,adParamInput,500,"")
					.Parameters.Append .CreateParameter("@owner_email",advarchar,adParamInput,150,Session("email"))
					.Parameters.Append .CreateParameter("@parentStepID",adBigInt,adParamInput,8,NULL)
					.Execute

				workflowID = .Parameters("RETORNO")
				
				End With

				Call chamaSP(False, objSP, Null, Null)
				dispose(cnn)

					msgTxt = "Congratulations,"+ vbNewLine + vbNewLine + "You have created a new FTA Workflow '" + request.form("title")+ "'."+ vbNewLine + vbNewLine +"You may manage it on " + getRootURL() +"manageWorkflow.asp?workflowID="+cstr(workflowID)
					msgHTML = "Congratulations,"+ vbNewLine + vbNewLine + "You have created a new FTA Workflow '" + request.form("title")+ "'."+ vbNewLine + vbNewLine +"You may manage it on <a href='" + getRootURL() +"manageWorkflow.asp?workflowID="+cstr(workflowID)+"'>here</a>."
					replyAddress  =  "TIAMAT <tiamat.cos.ufrj.br@gmail.com>"
					
					call SendMail(Session("email"), replyAddress, "TIAMAT - Workflow Successfully Created", msgTxt, msgHTML)

				
				response.redirect "manageWorkflow.asp?workflowID="+ cstr(workflowID) 
			
		else		
			Session("message") = "Cannot validate the user. Please login and try again."
		end if 
	
	case "update"  
	
	if request.form("workflowID") <> "" then ' UPDATE
			
			call ExecuteSQL(SQL_ATUALIZA_WORKFLOW(request.form("workflowID"),request.form("title"),request.form("description"), ""))
			
			if request.form("redirectTo") = "workflow" then
				response.redirect "manageWorkflow.asp?workflowID="+ request.form("workflowID")
			else
				Session("message") = "FTA successfully updated."
				response.redirect "workplace.asp"
			end if
			
	end if
	
	case "lock" ' and start the FTA
	
		if request.QueryString("workflowID") <> "" then
			

			call ExecuteSQL(SQL_SET_STATUS_WORKFLOW(request.QueryString("workflowID"), STATE_ACTIVE)) 

			call ExecuteSQL(SQL_SET_STATUS_WORKFLOW_STEPS(request.QueryString("workflowID"), STATE_LOCKED)) 

			call ExecuteSQL(SQL_SET_STATUS_WORKFLOW_PRIMARY_STEPS(request.QueryString("workflowID"), STATE_ACTIVE)) 

			
			call getRecordSet (SQL_CONSULTA_SUB_WORKFLOW_BY_WORKFLOWID(request.QueryString("workflowID")), rs)
			
			while not rs.eof
				call lockWorkflow(rs)
				rs.movenext
			wend
			

			if request.QueryString("location") <> "outside" then
				response.redirect "manageWorkflow.asp?workflowID="+ request.QueryString("workflowID")
			else
				response.redirect "workplace.asp"
			end if
		else		
			call response.write ("Workflow not found. Please try again.")	
		end if 
	
	
	case "savePos"


		Set oJSON = New aspJSON

		'Load JSON string
		oJSON.loadJSON(Request.Form)
		
		'Loop through collection
		For Each node In oJSON.data("nodes")
			Dim stepDIVID, posX, posY
			stepDIVID = oJSON.data("nodes").item(node).item("blockId")
			stepDIVID = replace(stepDIVID, "step", "")
			posX = oJSON.data("nodes").item(node).item("positionX")
			posY = oJSON.data("nodes").item(node).item("positionY")
			
			if cint(posX) <0 then posX = 0 
			if cint(posY) <0 then posY = 0 
			
			Set cnn = getConnection
			Call chamaSP(True, objSP, "SP_SAVE_WORKFLOW_POSITION",cnn)
			With objSP
				.Parameters.Append .CreateParameter("@stepID",adInteger,adParamInput,8,cint(stepDIVID))
				.Parameters.Append .CreateParameter("@posX",adInteger,adParamInput,4,cint(posX))
				.Parameters.Append .CreateParameter("@posY",adInteger,adParamInput,4,cint(posY))
				.Execute

			End With

			Call chamaSP(False, objSP, Null, Null)
			dispose(cnn)
			
			
		Next

	
	
		
	case "delete"
				
		if request.querystring("workflowID") <> "" then
			Dim workflowID
			Dim rsSteps
			
			workflowID = request.querystring("workflowID")
			
			call getRecordSet(SQL_CONSULTA_WORKFLOW_STEPS(workflowID),rsSteps) 
			
			while not rsSteps.eof 
			Dim stepID
			stepID = cstr(rsSteps("stepID"))
			
			call ExecuteSQL (SQL_DELETE_USERS_FROM_WORKFLOW_STEP(stepID))
			call ExecuteSQL (SQL_DELETE_STEP(stepID))

			rsSteps.movenext
			wend

			call ExecuteSQL (SQL_DELETE_WORKFLOW(workflowID))
			

			if request.QueryString("admin") <> "true" then
				response.redirect "workplace.asp"
			else
				response.redirect "administration.asp"
			end if

		
		else
			call response.write ("Workflow not found. Please try again.")	
		end if 
		
		
		
	case "deleteSI"
	
		if request.querystring("workflowID") <> ""  and request.querystring("file") <> "" then
		
			Response.Write SQL_DELETE_WORKFLOW_SUPPORTING_INFORMATION(request.querystring("workflowID"), request.querystring("file"))
			
			call ExecuteSQL(SQL_DELETE_WORKFLOW_SUPPORTING_INFORMATION(request.querystring("workflowID"), request.querystring("file")))

			' Remover arquivo fisicamente
			Set fs=Server.CreateObject("Scripting.FileSystemObject")
			if fs.FileExists(Server.MapPath(request.querystring("file"))) then
				call fs.DeleteFile(Server.MapPath(request.querystring("file")), true)
  			end if
			set fs=nothing
	
			Response.redirect getCurrentURL()


		else
		
			Response.Write "Workflow or file not found. Please inform the system administrator."
		
		end if 
		
	case "end" 'Step

		if request.querystring("stepID") <> "" then
			call endStep(request.querystring("stepID"))
			
			response.redirect "/workplace.asp"
		end if
		
	case else
	
		call response.write ("Invalid action supplied. Please inform the system administrator.")



		
	end select
	
	
%>


		
	