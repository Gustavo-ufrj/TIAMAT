<!--#include virtual="/system.asp"-->
<!--#include virtual="/includes/JSON.asp"-->
<!--#include file="INC_OA.inc"-->

<%


	Dim usuarios
	dim sql_consulta, retorno
	Dim action
			
	action = Request.Querystring("action")
	OAID = Request.Querystring("OAID")

	select case action
	
	case "list"
	
		sql_consulta = SQL_CONSULTA_EFFECT(OAID)

		Call getRecordSet(sql_consulta, rs)
		set d = server.createObject("scripting.dictionary")
		d.add "Result", "OK"
		d.add "Records", rs
		
		retorno = (new JSON).toJSON("data", array(d),0)
		retorno = mid(retorno, 11, len(retorno)-12)
		call response.write (retorno)
		

	case "new"
		
		'Call FormDataDump(false, false)

		set d = server.createObject("scripting.dictionary")
		
		if request.form("desiredeffect") <> ""  then
			
			Set cnn = getConnection
			Call chamaSP(True, objSP, "SP_CREATE_FTA_METHOD_OPTION_ANALYSIS_EFFECT",cnn)
			With objSP
				.Parameters.Append .CreateParameter("RETORNO", adBigInt,adParamReturnValue)
				.Parameters.Append .CreateParameter("@OAID",adBigInt,adParamInput,8,cint(OAID))
				.Parameters.Append .CreateParameter("@effect",advarchar,adParamInput,150,request.form("desiredeffect"))
				.Execute

			EffectID = .Parameters("RETORNO")

			End With

			Call chamaSP(False, objSP, Null, Null)
			dispose(cnn)
				

			Call getRecordSet(SQL_CONSULTA_EFFECT_BY_EFFECTID(cstr(EffectID)), rs)

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

			
			call response.write (retorno1)
			call response.end

			
		else 
		'Usuário ou senha inválidos
		d.add "Result", "ERROR"
		d.add "Message", "The Effect must be provided. Try again." 
		
		retorno = (new JSON).toJSON("data", array(d),0)
		retorno = mid(retorno, 11, len(retorno)-12)
		call response.write (retorno)
		end if 
		
		
		
		
	case "update"
	
		set d = server.createObject("scripting.dictionary")

		if request.form("desiredeffect") <> ""  then

		' Salvar
				
			call ExecuteSQL(SQL_ATUALIZA_EFFECT(request.form("effectid"), request.form("desiredeffect")))
			d.add "Result", "OK"

		else
			'Usuário ou senha inválidos
			d.add "Result", "ERROR"
			d.add "Message", "The Effect must be provided. Try again." 
		
		end if 
		retorno = (new JSON).toJSON("data", array(d),0)
		retorno = mid(retorno, 11, len(retorno)-12)
		call response.write (retorno)

	case "delete"
		
		call ExecuteSQL(SQL_DELETE_EFFECT(request.form("effectid")))
		
		set d = server.createObject("scripting.dictionary")
		d.add "Result", "OK"
		
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

