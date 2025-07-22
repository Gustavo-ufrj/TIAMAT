<!--#include virtual="/system.asp"-->
<!--#include virtual="/includes/JSON.asp"-->
<!--#include file="INC_CIA.inc"-->

<%


	Dim usuarios
	dim sql_consulta, retorno
	Dim action
	Dim formProb
	Dim defaultProb
			
	action = Request.Querystring("action")
	stepID = Request.Querystring("stepID")
	CIAID = Request.form("ciaID")
	
	
	select case action		
		
	case "update"
		set d = server.createObject("scripting.dictionary")

		if request.form("probability") <> ""  then

			Call getRecordSet(SQL_CONSULTA_EVENT_X_EVENT(request.form("causeID"), request.form("effectID")), rs)
			Call getRecordSet(SQL_CONSULTA_EVENT_BY_EVENTID(request.form("effectID")), rs2)
			
			formProb = Replace(Cstr(request.form("probability")),".",",")
			defaultProb = Cstr(rs2("defaultProbability"))
			
			if Len(defaultProb) = 1 then
				defaultProb = defaultProb & ",00"
			else 
				if Len(defaultProb) = 3 then
					defaultProb = defaultProb & "0"
				end if
			end if
			
			if Len(formProb) = 1 then
				formProb = formProb & ",00"
			else 
				if Len(formProb) = 3 then
					formProb = formProb & "0"
				end if
			end if
			
			if rs.EOF and request.form("probability") <> 2 then 'Adiciona nova probabilidade
				
				if formProb <> defaultProb then
					call ExecuteSQL(SQL_CRIA_EVENT_X_EVENT(request.form("causeID"), request.form("effectID"), request.form("probability"), CIAID))
				end if
				
				d.add "Result", "OK"
			
				Response.Redirect "index.asp?stepID=" + stepID
			
			else
				response.write(formProb + " ")
				response.write(defaultProb)
				if request.form("probability") = 2 or formProb = defaultProb then 
					call ExecuteSQL(SQL_DELETE_EVENT_X_EVENT_CAUSEID_EFFECTID(request.form("causeID"), request.form("effectID"))) 'Apaga probabilidade quando for qualitativa e o valor for igual a "No impact"
				end if
				
				call ExecuteSQL(SQL_ATUALIZA_EVENT_X_EVENT(request.form("causeID"), request.form("effectID"), request.form("probability"))) 'Atualiza probabilidade se já possuir algum valor
				d.add "Result", "OK"
			
				Response.Redirect "index.asp?stepID=" + stepID
			
			end if
			
		else
			'Usuário ou senha inválidos
			d.add "Result", "ERROR"
			d.add "Message", "The probability must be provided. Try again." 
		
		end if 
		retorno = (new JSON).toJSON("data", array(d),0)
		retorno = mid(retorno, 11, len(retorno)-12)
		call response.write (retorno)


	case else
	
		set d = server.createObject("scripting.dictionary")
		d.add "Result", "ERROR"
		d.add "Message", "Invalid action supplied. Please inform the system administrator."
				
		retorno = (new JSON).toJSON("data", array(d),0)
		retorno = mid(retorno, 11, len(retorno)-12)
		call response.write (retorno)
		
	end select
	
	
%>

