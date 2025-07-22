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
	
		sql_consulta = SQL_CONSULTA_STAKEHOLDER_X_INTEREST(SAID)

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
		
		if request.form("StakeholderID") <> "" AND request.form("InterestID") <> "" then
			
			Call getRecordSet(SQL_CONSULTA_STAKEHOLDER_X_INTEREST_STAKEHOLDERID_INTERESTID(cstr(request.form("StakeholderID")), cstr(request.form("InterestID"))), rs2)
			
			if rs2.EOF then
			
				Set cnn = getConnection
				Call chamaSP(True, objSP, "SP_CREATE_FTA_METHOD_STAKEHOLDER_ANALYSIS_STAKEHOLDER_X_INTEREST",cnn)
				With objSP
					.Parameters.Append .CreateParameter("RETORNO", adBigInt,adParamReturnValue)
					.Parameters.Append .CreateParameter("@SAID",adBigInt,adParamInput,8,cint(SAID))
					.Parameters.Append .CreateParameter("@stakeholderID",adBigInt,adParamInput,8,cint(request.form("StakeholderID")))
					.Parameters.Append .CreateParameter("@interestID",adBigInt,adParamInput,8,cint(request.form("InterestID")))
					.Execute

				StakeholderInterestID = .Parameters("RETORNO")

				End With

				Call chamaSP(False, objSP, Null, Null)
				dispose(cnn)
					

				Call getRecordSet(SQL_CONSULTA_STAKEHOLDER_X_INTEREST_BY_STAKEHOLDERINTERESTID(cstr(StakeholderInterestID)), rs)

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
			
				d.add "Result", "ERROR"
				d.add "Message", "This relation already exits. " 
				
				retorno = (new JSON).toJSON("data", array(d),0)
				retorno = mid(retorno, 11, len(retorno)-12)
				call response.write (retorno)
			
			end if
			
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

		if request.form("StakeholderID") <> "" AND request.form("InterestID") <> "" then
			
			Call getRecordSet(SQL_CONSULTA_STAKEHOLDER_X_INTEREST_BY_STAKEHOLDERINTERESTID(cstr(request.form("StakeholderInterestID"))), rs3)
			
			if cstr(rs3("StakeholderID")) = cstr(request.form("StakeholderID")) and cstr(rs3("InterestID")) = cstr(request.form("InterestID")) then
			
				' Salvar	
				call ExecuteSQL(SQL_ATUALIZA_STAKEHOLDER_X_INTEREST(request.form("stakeholderID"), request.form("interestID"), request.form("stakeholderinterestid")))
				d.add "Result", "OK"
			
			else
			
				Call getRecordSet(SQL_CONSULTA_STAKEHOLDER_X_INTEREST_STAKEHOLDERID_INTERESTID(cstr(request.form("StakeholderID")), cstr(request.form("InterestID"))), rs2)
				
				if rs2.EOF  then
				
					' Salvar	
					call ExecuteSQL(SQL_ATUALIZA_STAKEHOLDER_X_INTEREST(request.form("stakeholderID"), request.form("interestID"), request.form("stakeholderinterestid")))
					d.add "Result", "OK"

				else
				
					d.add "Result", "ERROR"
					d.add "Message", "This relation already exits. " 
				
				end if
			
			end if
			
			
		else
			'Usuário ou senha inválidos
			d.add "Result", "ERROR"
			d.add "Message", "All inputs must be provided. Try again. " 
		
		end if 
		retorno = (new JSON).toJSON("data", array(d),0)
		retorno = mid(retorno, 11, len(retorno)-12)
		call response.write (retorno)

	case "delete"
		
		call ExecuteSQL(SQL_DELETE_STAKEHOLDER_X_INTEREST(request.form("StakeholderInterestID")))
		
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

