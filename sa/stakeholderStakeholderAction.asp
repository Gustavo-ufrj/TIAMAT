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
	
		sql_consulta = SQL_CONSULTA_STAKEHOLDER_X_STAKEHOLDER(SAID)

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
		
		if request.form("FirstStakeholderID") <> "" AND request.form("SecondStakeholderID") <> "" AND request.form("relationship") <> "" then
			
			if request.form("FirstStakeholderID") <> request.form("SecondStakeholderID") then
				
				Call getRecordSet(SQL_CONSULTA_STAKEHOLDER_X_STAKEHOLDER_FIRSTSTAKEHOLDER_SECONDSTAKEHOLDER_RELATIONSHIP(cstr(request.form("FirstStakeholderID")), cstr(request.form("SecondStakeholderID")), cstr(request.form("relationship")) ), rs2)
				Call getRecordSet(SQL_CONSULTA_STAKEHOLDER_X_STAKEHOLDER_FIRSTSTAKEHOLDER_SECONDSTAKEHOLDER_RELATIONSHIP(cstr(request.form("SecondStakeholderID")), cstr(request.form("FirstStakeholderID")), cstr(request.form("relationship")) ), rs3)
				
				if rs2.EOF and rs3.EOF then
				
					Set cnn = getConnection
					Call chamaSP(True, objSP, "SP_CREATE_FTA_METHOD_STAKEHOLDER_ANALYSIS_STAKEHOLDER_X_STAKEHOLDER",cnn)
					With objSP
						.Parameters.Append .CreateParameter("RETORNO", adBigInt,adParamReturnValue)
						.Parameters.Append .CreateParameter("@SAID",adBigInt,adParamInput,8,cint(SAID))
						.Parameters.Append .CreateParameter("@firstStakeholderID",adBigInt,adParamInput,8,cint(request.form("FirstStakeholderID")))
						.Parameters.Append .CreateParameter("@secondStakeholderID",adBigInt,adParamInput,8,cint(request.form("SecondStakeholderID")))
						.Parameters.Append .CreateParameter("@relationship",advarchar,adParamInput,50,request.form("relationship"))
						.Execute

					StakeholderStakeholderID = .Parameters("RETORNO")

					End With

					Call chamaSP(False, objSP, Null, Null)
					dispose(cnn)
						

					Call getRecordSet(SQL_CONSULTA_STAKEHOLDER_X_STAKEHOLDER_BY_STAKEHOLDERSTAKEHOLDERID(cstr(StakeholderStakeholderID)), rs)

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
					d.add "Message", "This relation already exists. " 
			
					retorno = (new JSON).toJSON("data", array(d),0)
					retorno = mid(retorno, 11, len(retorno)-12)
					call response.write (retorno)
				
				end if
				
			else
			
				d.add "Result", "ERROR"
				d.add "Message", "Can't have stakeholder with self association. " 
		
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

		if request.form("FirstStakeholderID") <> "" AND request.form("SecondStakeholderID") <> "" AND request.form("relationship") <> "" then
	
			Call getRecordSet(SQL_CONSULTA_STAKEHOLDER_X_STAKEHOLDER_BY_STAKEHOLDERSTAKEHOLDERID(cstr(request.form("StakeholderStakeholderID"))), rs)
	
			if ( cstr(rs("FirstStakeholderID")) = cstr(request.form("FirstStakeholderID")) or cstr(rs("FirstStakeholderID")) = cstr(request.form("SecondStakeholderID")) ) and ( cstr(rs("SecondStakeholderID")) = cstr(request.form("SecondStakeholderID")) or cstr(rs("SecondStakeholderID")) = cstr(request.form("FirstStakeholderID")) ) and cstr(rs("relationship")) = cstr(request.form("relationship") ) then
				' Salvar
					call ExecuteSQL(SQL_ATUALIZA_STAKEHOLDER_X_STAKEHOLDER(request.form("FirstStakeholderID"), request.form("SecondStakeholderID"),  request.form("relationship"), request.form("StakeholderStakeholderID")))
					d.add "Result", "OK"
			else
			
				if request.form("FirstStakeholderID") <> request.form("SecondStakeholderID") then
						
					Call getRecordSet(SQL_CONSULTA_STAKEHOLDER_X_STAKEHOLDER_FIRSTSTAKEHOLDER_SECONDSTAKEHOLDER_RELATIONSHIP(cstr(request.form("FirstStakeholderID")), cstr(request.form("SecondStakeholderID")), cstr(request.form("relationship")) ), rs2)
					Call getRecordSet(SQL_CONSULTA_STAKEHOLDER_X_STAKEHOLDER_FIRSTSTAKEHOLDER_SECONDSTAKEHOLDER_RELATIONSHIP(cstr(request.form("SecondStakeholderID")), cstr(request.form("FirstStakeholderID")), cstr(request.form("relationship")) ), rs3)
					
					if rs2.EOF and rs3.EOF then
		
						' Salvar
						call ExecuteSQL(SQL_ATUALIZA_STAKEHOLDER_X_STAKEHOLDER(request.form("FirstStakeholderID"), request.form("SecondStakeholderID"),  request.form("relationship"), request.form("StakeholderStakeholderID")))
						d.add "Result", "OK"
						
					else
					
						d.add "Result", "ERROR"
						d.add "Message", "This relation already exists. " 
					
					end if
					
				else
				
					d.add "Result", "ERROR"
					d.add "Message", "Can't have stakeholder with self association. " 
				
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
		
		call ExecuteSQL(SQL_DELETE_STAKEHOLDER_X_STAKEHOLDER(request.form("StakeholderStakeholderID")))
		
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

