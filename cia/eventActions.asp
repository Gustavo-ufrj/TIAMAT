<!--#include virtual="/system.asp"-->
<!--#include virtual="/includes/JSON.asp"-->
<!--#include file="INC_CIA.inc"-->

<%


	Dim usuarios
	dim sql_consulta, retorno
	Dim action, url
	
	url = ""
			
	action = Request.Querystring("action")
	CIAID = Request.Querystring("CIAID")
	stepID = Request.Querystring("stepID")
	
	dim prob
	
	select case action
				
	
	case "new"
	
		'Call FormDataDump(false, false)

		CIAID = Request.form("CIAID")
			
		if request.form("event") <> ""  then
			
			Set cnn = getConnection
			
			if request.form("defaultprobability") = "" then
				prob = "50"
			else
				prob = Cstr(request.form("defaultprobability"))
			end if 
					

			Call chamaSP(True, objSP, "SP_CREATE_FTA_METHOD_CROSS_IMPACT_EVENT",cnn)
			With objSP
				.Parameters.Append .CreateParameter("RETORNO", adBigInt,adParamReturnValue)
				.Parameters.Append .CreateParameter("@CIAID",adBigInt,adParamInput,8,cint(CIAID))
				.Parameters.Append .CreateParameter("@event",advarchar,adParamInput,150,request.form("event"))
				.Parameters.Append .CreateParameter("@defaultprobability",adDouble,adParamInput,8,  Replace(Cstr(prob),".",","))
				.Execute

			EventID = .Parameters("RETORNO")

			End With

			Call chamaSP(False, objSP, Null, Null)
			dispose(cnn)

			url="index.asp?stepID="+request.form("stepID")

		'	url="manageEvents.asp?stepID="+request.form("stepID")+"&ciaID="+request.form("ciaID")		
			
		end if 
		
		
		
		
	case "update"
	
		set d = server.createObject("scripting.dictionary")

		if request.form("event") <> ""  then

		' Salvar
			
			prob = request.form("defaultprobability")
			Call getRecordSet(SQL_CONSULTA_EVENT_BY_EVENTID(request.form("eventid")), rs)
			
			
			if request.form("defaultprobability") = "" then
				prob = rs("defaultprobability")
			else
				prob = request.form("defaultprobability")
			end if
			
			
			
			call ExecuteSQL(SQL_ATUALIZA_EVENT(request.form("eventid"), request.form("event"), Replace(Cstr(prob),",",".")))
			
			url="index.asp?stepID="+request.form("stepID")
			'url="manageEvents.asp?stepID="+request.form("stepID")+"&ciaID="+request.form("ciaID")		
			
			
		end if 

	case "delete"
		
		call ExecuteSQL(SQL_DELETE_EVENT(request.querystring("eventid")))
		call ExecuteSQL(SQL_DELETE_EVENT_X_EVENT_BY_EVENTID(request.querystring("eventid")))
		
		url="index.asp?stepID="+request.querystring("stepID")
		'url="manageEvents.asp?stepID="+request.querystring("stepID")+"&ciaID="+request.querystring("ciaID")				

		
	end select
	
	
%>

<script>
top.location.href="<%=url%>"
</script>