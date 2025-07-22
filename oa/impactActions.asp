<!--#include virtual="/system.asp"-->
<!--#include virtual="/includes/JSON.asp"-->
<!--#include file="INC_OA.inc"-->

<%


	Dim usuarios
	dim sql_consulta, retorno
	Dim action
			
	action = Request.Querystring("action")
	OAID = Request.Querystring("OAID")

	Dim url
	url="index.asp?stepID="+request.form("stepID")

	
	select case action
	
	case "list"
	
		sql_consulta = SQL_CONSULTA_IMPACT(OAID)

		Call getRecordSet(sql_consulta, rs)
		set d = server.createObject("scripting.dictionary")
		d.add "Result", "OK"
		d.add "Records", rs
		
		retorno = (new JSON).toJSON("data", array(d),0)
		retorno = mid(retorno, 11, len(retorno)-12)
		call response.write (retorno)
		
		
	case "listUnavailableOptions"
	
		set d = server.createObject("scripting.dictionary")
		criteriaID = Request.Querystring("criteriaID")
		
		if criteriaID <> "" then
		
			sql_consulta = SQL_CONSULTA_IMPACT_BY_CRITERIAID(criteriaID)

			Call getRecordSet(sql_consulta, rs)
			d.add "Result", "OK"
			d.add "Records", rs
			
			
		else 
		
			d.add "Result", "ERROR"
			d.add "Message", "Criteria ID missing from request." 
		end if
		
			retorno = (new JSON).toJSON("data", array(d),0)
			retorno = mid(retorno, 11, len(retorno)-12)
			call response.write (retorno)
			response.end
	case "new"
		

		set d = server.createObject("scripting.dictionary")

		Call getRecordSet(SQL_CONSULTA_IMPACT_BY_OPTIONID_CRITERIAID(request.form("optionID"), request.form("criteriaID")), rs)
		if rs.eof then
			if request.form("effect") <> "" and cint(request.form("impact")) > 0 then
				
				call ExecuteSQL(SQL_CRIA_IMPACT(request.form("optionID"), request.form("criteriaID"), request.form("effect"), request.form("impact")))

'				Call getRecordSet(SQL_CONSULTA_IMPACT_BY_OPTIONID_CRITERIAID(request.form("optionID"), request.form("criteriaID")), rs)
'
'				d.add "Result", "OK"
'				d.add "Record", rs
			
			 
'				retorno = (new JSON).toJSON("data", array(d),0)
				
				' Tratamento para retirar o "data" do inicio e final do JSON
'				retorno = mid(retorno, 11, len(retorno)-12)

				' Tratamento para retirar [ ] que não são aceitos pelo jTable
'				retorno1 = left(retorno, instr(retorno, "[")-1)
'				retorno1 = retorno1 + mid (retorno, instr(retorno, "[")+1, len(retorno) -  (len(retorno) - instrrev(retorno, "]")) - instr(retorno, "[")-1)
'				retorno1 = retorno1 + right(retorno, len(retorno) - instrrev(retorno, "]"))
				' Fim do tratamento

				
				'call response.write (retorno1)
				'call response.end

				
			else 
			d.add "Result", "ERROR"
			d.add "Message", "Effect and Impact must be provided. Try again." 
			
			end if 
		else 
			d.add "Result", "ERROR"
			d.add "Message", "The criteria already has an associated Effect and Impact for this Option. You must edit it!" 

		end if 
		
		retorno = (new JSON).toJSON("data", array(d),0)
		retorno = mid(retorno, 11, len(retorno)-12)
		call response.write (retorno)
		
		
		
	case "update"
	
		set d = server.createObject("scripting.dictionary")

		if request.form("effect") <> "" and cint(request.form("impact")) > 0 then

		' Salvar
				
			call ExecuteSQL(SQL_ATUALIZA_IMPACT(request.form("optionID"),request.form("criteriaID"), request.form("effect"), request.form("impact")))
			d.add "Result", "OK"

		else
			'Usuário ou senha inválidos
			d.add "Result", "ERROR"
			d.add "Message", "Effect and Impact must be provided. Try again." 
		
		end if 
		retorno = (new JSON).toJSON("data", array(d),0)
		retorno = mid(retorno, 11, len(retorno)-12)
		call response.write (retorno)

	case "delete"
	
		deleteKey = request.querystring("deletekey")
		set d = server.createObject("scripting.dictionary")

		url="index.asp?stepID="+request.querystring("stepID")

		if deleteKey <> "" then
		
		call ExecuteSQL(SQL_DELETE_IMPACT(deleteKey))
		
		set d = server.createObject("scripting.dictionary")
		d.add "Result", "OK"

		else
			d.add "Result", "ERROR"
			d.add "Message", "Delete Key missing!" 
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

<script>
top.location.href="<%=url%>"
</script>