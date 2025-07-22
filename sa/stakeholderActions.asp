<!--#include virtual="/system.asp"-->
<!--#include virtual="/includes/JSON.asp"-->
<!--#include file="INC_SA.inc"-->

<%	
	Dim usuarios
	dim sql_consulta, retorno
	Dim action
	dim organizationName			
	
	Function ValidEmail(ByVal emailAddress) 
		Dim objRegEx, retVal 
		Set objRegEx = CreateObject("VBScript.RegExp") 
		With objRegEx 
			  .Pattern = "^\b[A-Z0-9._%+-]+@[A-Z0-9.-]+\.[A-Z]{2,4}\b$" 
			  .IgnoreCase = True 
		End With 
		retVal = objRegEx.Test(emailAddress) 
		Set objRegEx = Nothing 

		ValidEmail = retVal 
	End Function
			
	action = Request.Querystring("action")
	SAID = Request.Querystring("SAID")
	
	select case action
	
	case "list"
	
		sql_consulta = SQL_CONSULTA_STAKEHOLDER(SAID)

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
		
		if (request.form("type") <> ""  and request.form("organizationname") <> "" and request.form("contactname") <> "" and request.form("email") <> "" and request.form("role") <> "") or (request.form("type") = "1"  and request.form("organizationname") = "" and request.form("contactname") <> "" and request.form("email") <> "" and request.form("role") <> "" ) then
			
			if ValidEmail(request.form("email")) then
			
				organizationName = request.form("organizationname")
				conflictRole = request.form("conflictrole")
				
				if organizationName = "" and request.form("type") = "1" then
					organizationName = 0
				end if
				
				if conflictRole = "" then
					conflictRole = 0
				end if
				
				Set cnn = getConnection
				Call chamaSP(True, objSP, "SP_CREATE_FTA_METHOD_STAKEHOLDER_ANALYSIS_STAKEHOLDER",cnn)
				With objSP
					.Parameters.Append .CreateParameter("RETORNO", adBigInt,adParamReturnValue)
					.Parameters.Append .CreateParameter("@SAID",adBigInt,adParamInput,8,cint(SAID))
					.Parameters.Append .CreateParameter("@type",adInteger,adParamInput,4,request.form("type"))
					.Parameters.Append .CreateParameter("@organizationname",advarchar,adParamInput,150,organizationName)
					.Parameters.Append .CreateParameter("@contactname",advarchar,adParamInput,150,request.form("contactname"))
					.Parameters.Append .CreateParameter("@email",advarchar,adParamInput,150,request.form("email"))
					.Parameters.Append .CreateParameter("@role",advarchar,adParamInput,150,request.form("role"))
					.Parameters.Append .CreateParameter("@conflictrole",advarchar,adParamInput,150,conflictRole)
					.Execute

				StakeholderID = .Parameters("RETORNO")

				End With

				Call chamaSP(False, objSP, Null, Null)
				dispose(cnn)
					

				Call getRecordSet(SQL_CONSULTA_STAKEHOLDER_BY_STAKEHOLDERID(cstr(StakeholderID)), rs)

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
				d.add "Message", "E-mail not correct. " 
				
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

		if (request.form("type") <> ""  and request.form("organizationname") <> "" and request.form("contactname") <> "" and request.form("email") <> "" and request.form("role") <> "") or (request.form("type") = "1"  and request.form("organizationname") = "" and request.form("contactname") <> "" and request.form("email") <> "" and request.form("role") <> "" ) then

		' Salvar
			
			if ValidEmail(request.form("email")) then
			
				organizationName = request.form("organizationname")
				conflictRole = request.form("conflictrole")
				
				if organizationName = "" and request.form("type") = "1"  and conflictRole = "" then
					call ExecuteSQL(SQL_ATUALIZA_STAKEHOLDER_4(request.form("stakeholderid"), request.form("type"), request.form("contactname"), request.form("email"), request.form("role")))
					d.add "Result", "OK"
				else
					if organizationName = "" and request.form("type") = "1" then
						call ExecuteSQL(SQL_ATUALIZA_STAKEHOLDER_2(request.form("stakeholderid"), request.form("type"), request.form("contactname"), request.form("email"), request.form("role"), conflictRole))
						d.add "Result", "OK"
					else
						if conflictRole = "" then
							call ExecuteSQL(SQL_ATUALIZA_STAKEHOLDER_3(request.form("stakeholderid"), request.form("type"), organizationName, request.form("contactname"), request.form("email"), request.form("role")))
							d.add "Result", "OK"
						else
							call ExecuteSQL(SQL_ATUALIZA_STAKEHOLDER(request.form("stakeholderid"), request.form("type"), organizationName, request.form("contactname"), request.form("email"), request.form("role"), conflictRole ))
							d.add "Result", "OK"
						end if
					end if
				end if
			else
			
				d.add "Result", "ERROR"
				d.add "Message", "E-mail not correct. " 
				
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
		
		call ExecuteSQL(SQL_DELETE_STAKEHOLDER(request.form("stakeholderid")))
		
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

