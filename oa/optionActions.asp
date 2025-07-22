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
	
		sql_consulta = SQL_CONSULTA_OPTION(OAID)

		Call getRecordSet(sql_consulta, rs)
		set d = server.createObject("scripting.dictionary")
		d.add "Result", "OK"
		d.add "Records", rs
		
		retorno = (new JSON).toJSON("data", array(d),0)
		retorno = mid(retorno, 11, len(retorno)-12)
		call response.write (retorno)
		

	case "new"
		
'		Call FormDataDump(false, false)
		set d = server.createObject("scripting.dictionary")
		
		if  request.form("name") <> ""  and request.form("description") <> "" then
			
			Set cnn = getConnection
			Call chamaSP(True, objSP, "SP_CREATE_FTA_METHOD_OPTION_ANALYSIS_OPTION",cnn)
			With objSP
				.Parameters.Append .CreateParameter("RETORNO", adBigInt,adParamReturnValue)
				.Parameters.Append .CreateParameter("@OAID",adBigInt,adParamInput,8,request.form("OAID"))
				.Parameters.Append .CreateParameter("@name",advarchar,adParamInput,100,request.form("name"))
				.Parameters.Append .CreateParameter("@description",advarchar,adParamInput,500,request.form("description"))
				.Execute

			OptionID = .Parameters("RETORNO")

			End With

			Call chamaSP(False, objSP, Null, Null)
			dispose(cnn)
				

			Call getRecordSet(SQL_CONSULTA_OPTION_BY_OPTIONID(cstr(OptionID)), rs)

			d.add "Result", "OK"
			d.add "Record", rs
		
		 
			retorno = (new JSON).toJSON("data", array(d),0)
			
			' Tratamento para retirar o "data" do inicio e final do JSON
			retorno = mid(retorno, 11, len(retorno)-12)

			' Tratamento para retirar [ ] que não são aceitos pelo jTable
			retorno1 = left(retorno, instr(retorno, "[")-1)
			retorno1 = retorno1 + mid (retorno, instr(retorno, "[")+1, len(retorno) -  (len(retorno) - instrrev(retorno, "]")) - instr(retorno, "[")-1)
			retorno1 = retorno1 + right(retorno, len(retorno) - instrrev(retorno, "]"))
			' Fim do tratamento

			
'			call response.write (retorno1)
'			call response.end

			
		else 
		'Usuário ou senha inválidos
		d.add "Result", "ERROR"
		d.add "Message", "Name and Description must be provided. Try again." 
		
		retorno = (new JSON).toJSON("data", array(d),0)
		retorno = mid(retorno, 11, len(retorno)-12)
'		call response.write (retorno)
		end if 
		
	
		
		
	case "update"
	
		set d = server.createObject("scripting.dictionary")

		if request.form("name") <> "" and request.form("description") <> ""  then

		' Salvar
				
			call ExecuteSQL(SQL_ATUALIZA_OPTION(request.form("optionid"), request.form("name"), request.form("description")))
			d.add "Result", "OK"
			

		else
			'Usuário ou senha inválidos
			d.add "Result", "ERROR"
			d.add "Message", "Name and Description must be provided. Try again." 
		
		end if 
		retorno = (new JSON).toJSON("data", array(d),0)
		retorno = mid(retorno, 11, len(retorno)-12)
		'call response.write (retorno)


	case "delete"
		
		call ExecuteSQL(SQL_DELETE_OPTION(request.querystring("optionid")))
		
		set d = server.createObject("scripting.dictionary")
		d.add "Result", "OK"
		
		retorno = (new JSON).toJSON("data", array(d),0)
		retorno = mid(retorno, 11, len(retorno)-12)
'		call response.write (retorno)
		
		url="index.asp?stepID="+request.querystring("stepID")

	case else
	
		set d = server.createObject("scripting.dictionary")
		d.add "Result", "ERROR"
		d.add "Message", "Invalid action supplied. Please inform the system administrator."


				
		retorno = (new JSON).toJSON("data", array(d),0)
		retorno = mid(retorno, 11, len(retorno)-12)
'		call response.write (retorno)





		
	end select
	
	
%>

<script>
top.location.href="<%=url%>"
</script>