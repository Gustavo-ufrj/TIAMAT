<!--#include virtual="/system.asp"-->
<!--#include file="INC_BIBLIOMETRICS.inc"-->


<%

Dim usuarios
	dim sql_consulta, retorno
	Dim action
	Dim rsTag
		
	action = Request.Querystring("action")
	sID = Request.Querystring("stepID")
	rID = ""
	
	
	select case action
	
	case "save"
		
		rID = request.form("referenceID")
		
		call getRecordset(SQL_CONSULTA_BIBLIOMETRICS_TAGS_LIST_PER_STEP_ID_AND_TAG(sID, request.form("subject")),rsTag)
		
		if rsTag.eof then
		
			call ExecuteSQL(SQL_ADICIONA_TAG(sID, request.form("subject")))
		
		end if
		
	case "delete"
		
		rID = request.Querystring("referenceID")
		
		call getRecordset(SQL_CONSULTA_BIBLIOMETRICS_REFERENCE_X_TAG_BY_TAG_ID(request.Querystring("subjectID")),rsTag)
		
		if rsTag.eof then
			call ExecuteSQL(SQL_DELETE_TAG(request.Querystring("subjectID")))
		end if
		
		
	end select
	
	url = "editReference.asp?stepID=" +sID
	if rID <>  "" Then
		url = url + "&referenceID=" + rID
	end if 
	
%>
<script>
window.location.href="<%=url%>"
</script>

