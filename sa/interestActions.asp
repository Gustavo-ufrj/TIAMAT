<!--#include virtual="/system.asp"-->
<!--#include virtual="/includes/JSON.asp"-->
<!--#include file="INC_SA.inc"-->

<%
	Dim usuarios
	dim sql_consulta, retorno
	Dim action
			
	action = Request.Querystring("action")
	SAID = Request.Querystring("SAID")

	select case action
	
	case "list"
	
		sql_consulta = SQL_CONSULTA_INTEREST(SAID)

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
		
		if request.form("interest") <> "" then
			
			Set cnn = getConnection
			Call chamaSP(True, objSP, "SP_CREATE_FTA_METHOD_STAKEHOLDER_ANALYSIS_INTEREST",cnn)
			With objSP
				.Parameters.Append .CreateParameter("RETORNO", adBigInt,adParamReturnValue)
				.Parameters.Append .CreateParameter("@SAID",adBigInt,adParamInput,8,cint(SAID))
				.Parameters.Append .CreateParameter("@interest",advarchar,adParamInput,1000,request.form("interest"))
				.Execute

			InterestID = .Parameters("RETORNO")

			End With

			Call chamaSP(False, objSP, Null, Null)
			dispose(cnn)
				

			Call getRecordSet(SQL_CONSULTA_INTEREST_BY_INTERESTID(cstr(InterestID)), rs)

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
		d.add "Message", "All inputs must be provided. Try again. " 
		
		retorno = (new JSON).toJSON("data", array(d),0)
		retorno = mid(retorno, 11, len(retorno)-12)
		call response.write (retorno)
		end if 
		
		
		
		
	case "update"
	
		set d = server.createObject("scripting.dictionary")

		if request.form("interest") <> "" then

		' Salvar
				
			call ExecuteSQL(SQL_ATUALIZA_INTEREST(request.form("interestid"), request.form("interest")  ))
			d.add "Result", "OK"

		else
			'Usuário ou senha inválidos
			d.add "Result", "ERROR"
			d.add "Message", "All inputs must be provided. Try again. " 
		
		end if 
		retorno = (new JSON).toJSON("data", array(d),0)
		retorno = mid(retorno, 11, len(retorno)-12)
		call response.write (retorno)

	case "delete"
		
		call ExecuteSQL(SQL_DELETE_INTEREST(request.form("interestid")))
		
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

