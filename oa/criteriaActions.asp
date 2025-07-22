<!--#include virtual="/system.asp"-->
<!--#include virtual="/includes/JSON.asp"-->
<!--#include file="INC_OA.inc"-->

<%


	Dim usuarios
	dim sql_consulta, retorno
	Dim action

	Dim url
	url="index.asp?stepID="+request.form("stepID")
	
	action = Request.Querystring("action")
	effectID = Request.Querystring("effectID")

	select case action
	
	case "list"
	
		sql_consulta = SQL_CONSULTA_CRITERIA(effectID)

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

		if request.form("natureofeffect") <> ""  and request.form("statusquo") <> "" then

			
			EffectID = request.form("effectID")
			OAID = request.form("OAID")
					
			' Vou salvar, agora preciso cadastrar o efeito se ele não existe.
			if EffectID = "" and request.form("desiredeffect") <> ""  then

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
			end if

			
			Set cnn = getConnection
			Call chamaSP(True, objSP, "SP_CREATE_FTA_METHOD_OPTION_ANALYSIS_CRITERIA",cnn)
			With objSP
				.Parameters.Append .CreateParameter("RETORNO", adBigInt,adParamReturnValue)
				.Parameters.Append .CreateParameter("@effectID",adBigInt,adParamInput,8,cint(EffectID))
				.Parameters.Append .CreateParameter("@natureofeffect",advarchar,adParamInput,150,request.form("natureofeffect"))
				.Parameters.Append .CreateParameter("@statusquo",advarchar,adParamInput,500,request.form("statusquo"))
				.Execute

			CriteriaID = .Parameters("RETORNO")

			End With

			Call chamaSP(False, objSP, Null, Null)
			dispose(cnn)
				



'			Call getRecordSet(SQL_CONSULTA_CRITERIA_BY_CRITERIAID(cstr(EffectID)), rs)
'
'			d.add "Result", "OK"
'			d.add "Record", rs
'		
'		 
'			retorno = (new JSON).toJSON("data", array(d),0)
'			
'			' Tratamento para retirar o "data" do inicio e final do JSON
'			retorno = mid(retorno, 11, len(retorno)-12)
'
'			' Tratamento para retirar [ ] que não são aceitos pelo jTable
'			retorno1 = left(retorno, instr(retorno, "[")-1)
'			retorno1 = retorno1 + mid (retorno, instr(retorno, "[")+1, len(retorno) -  (len(retorno) - instrrev(retorno, "]")) - instr(retorno, "[")-1)
'			retorno1 = retorno1 + right(retorno, len(retorno) - instrrev(retorno, "]"))
'			' Fim do tratamento

			
'			call response.write (retorno1)
'			call response.end

			
		else 
		'Usuário ou senha inválidos
		d.add "Result", "ERROR"
		d.add "Message", "Nature of Effect and Status Quo must be provided. Try again." 
		
		retorno = (new JSON).toJSON("data", array(d),0)
		retorno = mid(retorno, 11, len(retorno)-12)
		call response.write (retorno)
		end if 
		
		
		
		
	case "update"
	
		set d = server.createObject("scripting.dictionary")



		EffectID = request.form("effectID")
		OAID = request.form("OAID")
				
		' SALVANDO NOVO EFEITO
		if EffectID = "" and request.form("desiredeffect") <> ""  then

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
		end if

			' MUDANDO O EFEITO PARA OUTRO EXISTENTE

		if EffectID <> "" and request.form("natureofeffect") <> ""  and request.form("statusquo") <> ""  then

		' Salvar
				
			call ExecuteSQL(SQL_ATUALIZA_CRITERIA(request.form("criteriaid"), cstr(EffectID), request.form("natureofeffect"), request.form("statusquo")))
			
			call ExecuteSQL(SQL_DELETE_UNUSED_EFFECT(OAID))
			
			d.add "Result", "OK"

		else
			'Usuário ou senha inválidos
			d.add "Result", "ERROR"
			d.add "Message", "Nature of Effect and Status Quo must be provided. Try again." 
		
		end if 
		retorno = (new JSON).toJSON("data", array(d),0)
		retorno = mid(retorno, 11, len(retorno)-12)
		call response.write (retorno)

	case "delete"
		
		call ExecuteSQL(SQL_DELETE_CRITERIA(request.querystring("criteriaid")))
		
		call ExecuteSQL(SQL_DELETE_UNUSED_EFFECT(request.querystring("oaid")))

		url="index.asp?stepID="+request.querystring("stepID")

					
		
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

<script>
top.location.href="<%=url%>"
</script>