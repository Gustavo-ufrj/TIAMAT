<!--#include virtual="/system.asp"-->
<!--#include virtual="/includes/JSON.asp"-->
<!--#include file="INC_ROADMAP.inc"-->

<%


	Dim usuarios
	dim sql_consulta, retorno
	Dim action
	
			
	action = Request.Querystring("action")
	roadmapID = Request.Querystring("roadmapID")

	Dim url
	url= "index.asp?stepID="+roadmapID		
	
	select case action
	
		

	case "new"
		

		set d = server.createObject("scripting.dictionary")

			if request.form("date") <> "" and request.form("event") <> "" then
				
				Set cnn = getConnection
				Call chamaSP(True, objSP, "SP_CREATE_FTA_METHOD_ROADMAP_EVENT",cnn)
				With objSP
					.Parameters.Append .CreateParameter("RETORNO", adBigInt,adParamReturnValue)
					.Parameters.Append .CreateParameter("@roadmapID",adBigInt,adParamInput,8,cint(roadmapID))
					.Parameters.Append .CreateParameter("@event",advarchar,adParamInput,300,request.form("event"))
					.Parameters.Append .CreateParameter("@d",adDBTimeStamp,adParamInput, ,cdate(request.form("date")+"-01-01"))
					.Execute

				eventID = .Parameters("RETORNO")

				End With

				Call chamaSP(False, objSP, Null, Null)
				dispose(cnn)
					
			
			end if 

		
		
		
		
		
	case "update"
	
		set d = server.createObject("scripting.dictionary")

		if request.form("date") <> "" and request.form("event") <> "" then

		' Salvar
				
			call ExecuteSQL(SQL_ATUALIZA_ROADMAP_EVENT(request.form("eventID"),request.form("date"), request.form("event")))
			d.add "Result", "OK"
		
		end if 
		
				

	case "delete"

		
		call ExecuteSQL(SQL_DELETE_ROADMAP_EVENT(request.Querystring("eventID")))


		
	end select
	
	
%>
<script>
top.location.href="<%=url%>"
</script>

