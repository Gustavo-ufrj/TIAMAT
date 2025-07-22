<!--#include file="INC_GENERAL.inc"-->
<!--#include file="ADOVBS.INC"-->
<!--#include file="SYSCONNECTION.ASP"-->
<!--#include file="INCLUDES/TEMPLATE.ASP"-->
<!--#include file="SHA256.ASP"-->
<!--#include file="INCLUDES/StringBuffer.ASP"-->
<!--#include file="includes/aspJSON1.19.asp"-->



<%



Dim tiamat, render
Set tiamat = New Page
Set render = New HTMLRender
render.Page = tiamat

tiamat.Title="TIAMAT"
tiamat.Icon = "/css/favicon.png"

tiamat.addMeta("charset='utf-8'")
tiamat.addMeta("name='viewport' content='width=device-width,initial-scale=1'")

'tiamat.addCSS("/css/main.css")

tiamat.addCSS("https://cdn.jsdelivr.net/npm/bootstrap@5.1.3/dist/css/bootstrap.min.css")
tiamat.addCSS("https://cdn.jsdelivr.net/npm/bootstrap-icons@1.8.1/font/bootstrap-icons.css")

tiamat.addJS("https://code.jquery.com/jquery-3.2.1.slim.min.js")
tiamat.addJS("https://cdn.jsdelivr.net/npm/bootstrap@5.1.3/dist/js/bootstrap.bundle.min.js")

tiamat.addJS("/js/external/json2.min.js")
tiamat.addJS("/js/tiamat.js")


'tiamat.addCSS("/css/tiamat.css")
'tiamat.addCSS("/css/main.css")
'tiamat.addCSS("/css/mobileFIX.css")
'tiamat.addCSS("/css/text.css")


'tiamat.addCSS("/js/themes/metro/darkgray/jtable.min.css")
'tiamat.addCSS("/css/metro/jquery-ui.css")
'tiamat.addCSS("/css/jtable_jqueryui.css")



'tiamat.addJS("/js/external/json2.min.js")
'tiamat.addJS("/js/jquery.js")
'tiamat.addJS("/js/jquery-ui-1.10.0.min.js")
'tiamat.addJS("/js/jquery.inputmask.js")
'tiamat.addJS("/js/jquery.jtable.min.js")
'tiamat.addJS("/js/tiamat.js")




''''''''''''''''''''''''''''''''''''''''''''''''''''
'''''Este arquivo contem as Funcoes de Sistema''''''
''''''''''''''''''''''''''''''''''''''''''''''''''''

'*****************************************	
'*		   OPÇÕES E CONFIGURAÇÕES
'*****************************************	
	
	' Hostname utilizado
	'Const HOSTNAME = "tiamat.cos.ufrj.br" 
	
	' Configure Email Notification
	'Const EMAIL_NOTIFICATION = False 

	' Tempo de Timeout de uma sessão 
	Session.Timeout=600


	Const SIGNUP_ALLOWED = True
	
'*****************************************	
'*	  CONSTANTES FIXAS (EVITE ALTERAR)
'*****************************************	
	
	
	Session.LCID = 1046 ' Brazil -> Força a localização do Site para o Brasil.
	Session.Codepage=65001 ' ativa o UTF-8 -> se remover quebra as strings acentuadas do BD
	
	
	' Força que as páginas não sejam cacheadas
	Response.CacheControl = "no-cache"
	Response.AddHeader "Pragma", "no-cache"
	Response.Expires = -1

	
	' Ciclo de vida do workflow: STATE_UNLOCKED -> STATE_ACTIVE -> STATE_CONCLUDED
	' Ciclo de vida do step: STATE_UNLOCKED -> STATE_LOCKED -> STATE_ACTIVE -> STATE_CONCLUDED
	Const STATE_UNLOCKED = 1  
	Const STATE_LOCKED = 2 ' and waiting
	Const STATE_ACTIVE = 3 
	Const STATE_CONCLUDED = 4 
	

'*****************************************	
'*	 		 FUNÇÕES E ROTINAS
'*****************************************	
	

'Função que faz a chamada da Stored Procedure 
Public Sub ChamaSP(opcao, command, strExec, conexao)
	Set command = Server.CreateObject("ADODB.Command")
	If(opcao)Then
		command.CommandType = adCmdStoredProc
		command.CommandText = strExec
		Set command.ActiveConnection = conexao
	Else
		Set command.ActiveConnection = Nothing
		Set command = Nothing
	End If
End Sub


'Função para liberar a conexão com o banco
Public Sub Dispose(obj)
	Set obj = nothing
End Sub

'Função que retorna um Recordset
Public Sub GetRecordSet(strExec, record)
		Dim cnn : Set cnn = CreateObject("ADODB.Connection")
		Set cnn = getConnection
		Set record = CreateObject("ADODB.RecordSet")
		record.CursorLocation = adUseClient
		record.Open strExec, cnn, adOpenStatic, adLockReadOnly
		set record.ActiveConnection = nothing
End Sub

'Função que retorna um Recordset com um número máximo de registros
Public Sub GetRecordSetMaxRec(strExec, maxRec, record)
		Dim cnn : Set cnn = CreateObject("ADODB.Connection")
		Set cnn = getConnection
		Set record = CreateObject("ADODB.RecordSet")
		record.MaxRecords = maxRec
		record.CursorLocation = adUseClient
		record.Open strExec, cnn, adOpenStatic, adLockReadOnly
		set record.ActiveConnection = nothing
End Sub

'Função que retorna o número de páginas de um RecordSet
Public Sub GetRecordSetPages(strExec, record)
		Dim cnn : Set cnn = CreateObject("ADODB.Connection")
		Set cnn = getConnection
		Set record = CreateObject("ADODB.RecordSet")
		record.cursortype=adopenstatic
		record.cursorlocation=aduseclient
		record.Open strExec, cnn, adLockReadOnly
		set record.ActiveConnection = nothing
End Sub

'Função que executa um SQL
'Public Sub ExecuteSQL2(strExec)
'		Dim cnn : Set cnn = CreateObject("ADODB.Connection")
'		Set cnn = getConnection
'		cnn.Execute(strExec)
'		cnn.Close()	
'End Sub

'Função que executa um SQL
Public Function ExecuteSQL(strExec)
		Dim cnn : Set cnn = CreateObject("ADODB.Connection")
		Set cnn = getConnection
		set ExecuteSQL = cnn.Execute(strExec)
		cnn.Close()	
End Function

'Função que executa um SQL
Public Function ExecuteSQLCommand(cmd)
		cmd.Execute
		cmd.ActiveConnection.Close()	
End Function

'Função que pega um SQL
Public Function getSQLCommand()
		Dim cnn : Set cnn = CreateObject("ADODB.Connection")
		Set cnn = getConnection

		set cmd  = Server.CreateObject("ADODB.Command")
		cmd.ActiveConnection = cnn //connection object already created
		cmd.CommandType = adCmdText
		
		set getSQLCommand = cmd
End Function


Public Sub Refresh_User_Photo(email,photopath) 
	call ExecuteSQL(SQL_ATUALIZA_FOTO(email,photopath))
	Session("photo") = photopath
End Sub

Public Sub Refresh_User_Profile(email,name, password) 
	call ExecuteSQL(SQL_ATUALIZA_PROFILE(email,name, password))
	Session("name") = name
End Sub

Public Sub Refresh_User_Password(email,password) 
	call ExecuteSQL(SQL_ATUALIZA_PASSWORD(email, password))
End Sub





Public Function LoadManifest()
	'Instancia o objeto XMLDOM.
	Set objXMLDoc = CreateObject("MSXML2.DOMDocument.3.0")
	 
	'Indicamos que o download em segundo plano não é permitido
	objXMLDoc.async = False
	 
	'Carrega o domcumento XML
	objXMLDoc.load(Server.MapPath("/manifest.xml"))
	 
	'Carrega o domcumento XML
	 
	'O método parseError contém informações sobre o último erro ocorrido
	if objXMLDoc.parseError <> 0 then
		SET LoadManifest = Nothing
	else
		SET LoadManifest = objXMLDoc.documentElement
	end if
end function


Public Function getFTAMethodList(raiz)
	Set getFTAMethodList = raiz.getElementsByTagName("FTAmethod")
end function

Public Function getUserList(FTAmethod)
	  Set getUserList = FTAmethod.getElementsByTagName("user")
end function

Public Function getUserListbyID(methodID)
	Set manifest = LoadManifest()
	Set methodList = getFTAMethodList(manifest)
	Set getUserListbyID = Nothing		
	for i=0 to methodList.length -1
		if methodList(i).getAttribute("id") = methodID then
			Set getUserListbyID = methodList(i).getElementsByTagName("user")		
		end if
	next
end function

''''''''''''''''''''''''''''''''
' função getFormatListbyFTAmethodID (aparentemente não faz nada)
''''''''''''''''''''''''''''''
Public Function getFormatListbyFTAmethodID(methodID)
	Dim listFormats()
	reDim listFormats(1)
	Set manifest = LoadManifest()
	Set methodList = getFTAMethodList(manifest)
	Set getFormatListbyFTAmethodID = Nothing		
	for i=0 to methodList.length -1
		if methodList(i).getAttribute("id") = methodID then
			set inputList = methodList(i).getElementsByTagName("input")
			for j=0 to inputlist.length -1
				listFormats(j) = inputlist(j).getAttribute("format")
				reDim Preserve listFormats(j+1)
			next
		end if	
	next
	if Ubound(listFormats)> 0 then
		reDim preserve listFormats(Ubound(listFormats)-1)
	end if
	getFormatListbyFTAmethodID = listFormats
end function


Public Function getRoleListbyFTAmethodID(methodID)
	Dim listRoles()
	reDim listRoles(1)
	Set manifest = LoadManifest()
	Set methodList = getFTAMethodList(manifest)
	Set getRoleListbyFTAmethodID = Nothing		
	for i=0 to methodList.length -1
		if methodList(i).getAttribute("id") = methodID then
			set userlist = methodList(i).getElementsByTagName("user")
			for j=0 to userlist.length -1
				listRoles(j) = userlist(j).getAttribute("role")		
				redim preserve listRoles(j+1)
			next
		end if
	next
	if Ubound(listRoles)> 0 then
		redim preserve listRoles(Ubound(listRoles)-1)
	end if
	getRoleListbyFTAmethodID = listRoles
end function


Public Function getFTAMethodNamebyFTAmethodID(methodID)
	Set manifest = LoadManifest()
	Set methodList = getFTAMethodList(manifest)
	getFTAMethodNamebyFTAmethodID = ""
	for i=0 to methodList.length -1
		if methodList(i).getAttribute("id") = methodID then
			getFTAMethodNamebyFTAmethodID = methodList(i).getAttribute("name")
		end if
	next
end function


Public Function getBaseFolderByFTAmethodID(methodID)
	Set manifest = LoadManifest()
	Set methodList = getFTAMethodList(manifest)
	getBaseFolderByFTAmethodID = ""
	for i=0 to methodList.length -1
		if methodList(i).getAttribute("id") = methodID then
			getBaseFolderByFTAmethodID = methodList(i).getAttribute("base_folder")
		end if
	next
end function

'''''''''''''''''''''''''''''
' função input_format
''''''''''''''''''''''''''''''''
Public Function getFTAMethodInputbyFTAmethodID(methodID)
	Set manifest = LoadManifest()
	Set methodList = getFTAMethodList(manifest)
	getFTAMethodInputbyFTAmethodID = ""
	for i=0 to methodList.length -1
		if methodList(i).getAttribute("id") = methodID then
			getFTAMethodInputbyFTAmethodID = methodList(i).getAttribute("input_format")
		end if
	next
end function


'''''''''''''''''''''''''''''''''
' função output_format
''''''''''''''''''''''''''''''''''
Public Function getFTAMethodOutputbyFTAmethodID(methodID)
	Set manifest = LoadManifest()
	Set methodList = getFTAMethodList(manifest)
	getFTAMethodOutputbyFTAmethodID = ""
	for i=0 to methodList.length -1
		if methodList(i).getAttribute("id") = methodID then
			getFTAMethodOutputbyFTAmethodID = methodList(i).getAttribute("output_format")
		end if
	next
end function




'Função utilitária temporária
Sub FormDataDump(bolShowOutput, bolEndPageExecution)
  Dim sItem

  'What linebreak character do we need to use?
  Dim strLineBreak
  If bolShowOutput then
    'We are showing the output, so set the line break character
    'to the HTML line breaking character
    strLineBreak = "<br>"
  Else
    'We are nesting the data dump in an HTML comment block, so
    'use the carraige return instead of <br>
    'Also start the HTML comment block
    strLineBreak = vbCrLf
    Response.AppendToLog("<!--" & strLineBreak)
  End If
  

  'Display the Request.Form collection
  Response.AppendToLog("DISPLAYING REQUEST.FORM COLLECTION" & strLineBreak)
  For Each sItem In Request.Form
    Response.AppendToLog(sItem)
    Response.AppendToLog(" - [" & Request.Form(sItem) & "]" & strLineBreak)
  Next
  
  
  'Display the Request.QueryString collection
  Response.AppendToLog(strLineBreak & strLineBreak)
  Response.AppendToLog("DISPLAYING REQUEST.QUERYSTRING COLLECTION" & strLineBreak)
  For Each sItem In Request.QueryString
    Response.AppendToLog(sItem)
    Response.AppendToLog(" - [" & Request.QueryString(sItem) & "]" & strLineBreak)
  Next

  
  'If we are wanting to hide the output, display the closing
  'HTML comment tag
  If Not bolShowOutput then Response.AppendToLog(strLineBreak & "-->")

  'End page execution if needed
  If bolEndPageExecution then Response.End
End Sub


function getStatusStep(stepID)
	Dim rsStep3
	call getRecordSet(SQL_CONSULTA_WORKFLOW_STEP_ID(StepID), rsStep3)
	if not rsStep3.eof then
		getStatusStep = rsStep3("status")
	else
		getStatusStep = -1
	end if 
end function


function getWfStatus(wfID)
	Dim rsWf3
	call getRecordSet(SQL_CONSULTA_WORKFLOW_ID(wfID), rsWf3)
	if not rsWf3.eof then
		getWfStatus = rsWf3("status")
	else
		getWfStatus = -1
	end if 
end function


function getStatus(code)
	select case code
		case STATE_UNLOCKED
			getStatus = "Unlocked"
		case STATE_LOCKED
			getStatus = "Locked"
		case STATE_ACTIVE
			getStatus = "Active"
		case STATE_CONCLUDED
			getStatus = "Concluded"
		case else
			getStatus = "Invalid"
	end select
end function

function getStatusWorkflow(code)
	select case code
		case STATE_UNLOCKED
			getStatusWorkflow = "Inactive"
		case STATE_LOCKED
			getStatusWorkflow = "Waiting"
		case STATE_ACTIVE
			getStatusWorkflow = "Active"
		case STATE_CONCLUDED
			getStatusWorkflow = "Concluded"
		case else
			getStatusWorkflow = "Invalid"
	end select
end function


sub lockWorkflow(rs)


	call getRecordSet (SQL_CONSULTA_WORKFLOW_STEP_ID(cstr(rs("parentstepID"))),rsTemp) 
	parentStatus = rsTemp("status")
	call ExecuteSQL(SQL_SET_STATUS_WORKFLOW(cstr(rs("workflowID")), parentStatus)) 
	call ExecuteSQL(SQL_SET_STATUS_WORKFLOW_STEPS(cstr(rs("workflowID")), STATE_LOCKED)) 
	call ExecuteSQL(SQL_SET_STATUS_WORKFLOW_PRIMARY_STEPS(cstr(rs("workflowID")), parentStatus)) 

	
	call getRecordSet (SQL_CONSULTA_SUB_WORKFLOW_BY_WORKFLOWID(cstr(rs("workflowID"))), rs2)
			
			while not rs2.eof
				call lockWorkflow(rs2)
				rs2.movenext
			wend
end sub




sub endWorkflow(workflowID)

	call ExecuteSQL(SQL_SET_STATUS_WORKFLOW(workflowID, STATE_CONCLUDED)) 
	
	call getRecordSet (SQL_CONSULTA_WORKFLOW_ID(workflowID),rs) 
	
	if not rs.eof then
		if not isnull(rs("parentStepID")) then
			call endStep (cstr(rs("parentStepID")))
		end if
	end if
				

end sub


function hasPendentParentStep(stepID,workflowID)
	hasPendentParentStep = false
	call getRecordSet(SQL_CONSULTA_WORKFLOW_STEPS(workflowID), rs364881320)
		while not rs364881320.eof
			if isParentStep(cstr(rs364881320("stepID")), stepID) and rs364881320("status") < STATE_CONCLUDED then
				hasPendentParentStep = true
			end if
			rs364881320.movenext
		wend
end function

sub endStep(stepID)
	Dim rs2,rs3,rs4
	call ExecuteSQL(SQL_SET_STATUS_WORKFLOW_STEP(stepID, STATE_CONCLUDED))

	call getRecordSet(SQL_CONSULTA_WORKFLOW_STEP_ID(stepID), rs2)
		if not rs2.eof then
			call getRecordSet(SQL_CONSULTA_WORKFLOW_STEPS(cstr(rs2("workflowID"))), rs3)
			Dim verifyStatus 
			verifyStatus = true
			while not rs3.eof
				if rs3("status") <> STATE_CONCLUDED then 
					verifyStatus = false ' WORKFLOW NÃO ACABOU
					if rs3("status") = STATE_LOCKED and not hasPendentParentStep(cstr(rs3("stepID")),cstr(rs2("workflowID"))) then
						call ExecuteSQL(SQL_SET_STATUS_WORKFLOW_STEP(cstr(rs3("stepID")), STATE_ACTIVE))
						if rs3("type") = 0 then
							call getRecordSet(SQL_CONSULTA_SUB_WORKFLOW_BY_PARENTSTEP(cstr(rs3("stepID"))), rs4)
							if not rs4.eof then call lockWorkflow(rs4)
						end if
					end if
				end if
				rs3.movenext
			wend
			if verifyStatus then
				call endWorkflow(cstr(rs2("workflowID")))
			end if
		end if

end sub




'sub endStep(stepID)
'	call getRecordSet (SQL_CONSULTA_WORKFLOW_NEXT_STEPS(stepID),rs) 
'
'	call ExecuteSQL(SQL_SET_STATUS_WORKFLOW_STEP(stepID, STATE_CONCLUDED))
'	
'	if not rs.eof then ' O STEP POSSUI FILHOS - É PRECISO ATIVÁ-LOS
'		while not rs.eof
'			call ExecuteSQL(SQL_SET_STATUS_WORKFLOW_STEP(cstr(rs("stepID")), STATE_ACTIVE))
'			if rs("type") = 0 then
'				call getRecordSet(SQL_CONSULTA_SUB_WORKFLOW_BY_PARENTSTEP(cstr(rs("stepID"))), rs2)
'				if not rs2.eof then call lockWorkflow(rs2)
'			end if
'			rs.movenext
'		wend
'	else   ' O STEP NÃO TEM FILHOS - PRECISO CHECAR SE O WORKFLOW ACABOU
'
'		call getRecordSet(SQL_CONSULTA_WORKFLOW_STEP_ID(stepID), rs2)
'		if not rs2.eof then
'			call getRecordSet(SQL_CONSULTA_WORKFLOW_STEPS(cstr(rs2("workflowID"))), rs3)
'			Dim verifyStatus 
'			verifyStatus = true
'			while not rs3.eof
'				if rs3("status") <> STATE_CONCLUDED then 
'					verifyStatus = false ' WORKFLOW NÃO ACABOU
'				end if
'				rs3.movenext
'			wend
'			if verifyStatus then
'				call endWorkflow(cstr(rs2("workflowID")))
'			end if
'		end if
'	end if
'end sub



function getFileName(pathname)
	getFileName = right(pathname, len(pathname) - instrrev(pathname,"/"))
end function

Sub saveCurrentURL()
	if Request.Querystring <> "" then
		Session("currentURL") = Request.ServerVariables("URL") & "?" & Request.Querystring
	else
		Session("currentURL") = Request.ServerVariables("URL") 
	end if
end sub

function getCurrentURL()
	getCurrentURL=Session("currentURL") 
end function

' Retorna o número de passos reais (excluindo subworkflows)
function getWorkflowRealSteps(workflowID)
	Dim rs, rs2
	Dim steps
	steps = 0
	call getRecordSet(SQL_CONSULTA_NUM_STEPS_BY_WORKFLOW_ID(workflowID), rs)
	if not rs.eof then
		steps = rs("steps")	 
	end if
	call getRecordSet(SQL_CONSULTA_SUB_WORKFLOWS_BY_WORKFLOW_ID(workflowID), rs2)
	while not rs2.eof
		steps = steps + getWorkflowRealSteps(cstr(rs2("workflowID")))
		rs2.movenext
	wend
	getWorkflowRealSteps = steps
end function



function strLeft(str1,str2)
	if (InStr(str1,str2) > 0) then
		strLeft = Left(str1,InStr(str1,str2)-1)
	else
		strLeft = str1
	end if
end function

function strRight(str1,str2)
strRight = Right(str1,len(str1) - (InStrRev(str1,str2)))
end function

function getRootURL()
	Dim domainName, urlParam 
	
	If lcase(Request.ServerVariables("HTTPS")) = "on" Then 
		strProtocol = "https://" 
	Else
		strProtocol = "http://" 
	End If

	domainName = Request.ServerVariables("SERVER_NAME") 
	urlParam   = Request.ServerVariables("HTTP_X_ORIGINAL_URL")
	
	getRootURL = strProtocol & domainName & urlParam  
end function

'PURPOSE: Obtain distinct values from an array
'PARAMETER:  OrigArray: any array
'RETURNS: A variant array with only the unique values of
'OrigArray E.g., pass in an array containing elements 2, 1, 2; 
'return value is an array with elements 2, 1

Public Function UniqueValues(OrigArray) 

Dim myDict, elem
Set myDict = Server.CreateObject("Scripting.Dictionary")
For Each elem In OrigArray
    If Not myDict.Exists(elem) Then myDict.Add elem, elem
Next

UniqueValues = myDict.Items

End Function

Public Function getName(email)
	call getRecordSet(SQL_CONSULTA_USUARIO_EMAIL(email), rs78099)
	if not rs78099.eof then
		getName = rs78099("name")	 
	end if
End Function

Public Function getPhoto(email)
	call getRecordSet(SQL_CONSULTA_USUARIO_EMAIL(email), rs464556)
	if not rs464556.eof then
		getPhoto = rs464556("photo")	 
	end if
End Function


Public Function getTimeStamp(ds)
	Dim lcid, dateStamp 
	lcid = Session.lcid
	Session.lcid = 1053  
	dateStamp = FormatDateTime(ds)
	Session.lcid = lcid 
	getTimeStamp = dateStamp
End Function

Public Function isParentStep(parentStepID, stepID)
	Dim rs7753166
	isParentStep = false
	call getRecordSet(SQL_CONSULTA_WORKFLOW_PARENT_STEPS(stepID), rs7753166)
	while not rs7753166.eof 
		if cstr(rs7753166("parentStepID")) = parentStepID then 
			isParentStep = true
			exit function
		else
			if not isParentStep then
				isParentStep = isParentStep(parentStepID, cstr(rs7753166("parentStepID")))
			end if
		end if
		rs7753166.movenext
	Wend
	
End Function


Function in_array(element, arr)
    For i=0 To Ubound(arr) 
        If Trim(arr(i)) = Trim(element) Then 
            in_array = True
            Exit Function
        Else 
            in_array = False
        End If  
    Next 
End Function 

Function array_in_array(arr1, big_array)
	array_in_array = True
    For i=0 To Ubound(arr1) 
        If not in_array(arr1(i), big_array ) Then 
            array_in_array = False
        End If  
    Next 

End Function 



Function ConvertFromUTF8(sIn)

    Dim oIn: Set oIn = CreateObject("ADODB.Stream")

    oIn.Open
    oIn.CharSet = "WIndows-1252"
    oIn.WriteText sIn
    oIn.Position = 0
    oIn.CharSet = "UTF-8"
    ConvertFromUTF8 = oIn.ReadText
    oIn.Close

End Function


Function ConvertToUTF8(sIn)

    Dim oIn: Set oIn = CreateObject("ADODB.Stream")

    oIn.Open
    oIn.CharSet = "UTF-8"
    oIn.WriteText sIn
    oIn.Position = 0
    oIn.CharSet = "WIndows-1252"
    ConvertToUTF8 = oIn.ReadText
    oIn.Close

End Function


' inline if
Public Function IIf(bClause, sTrue, sFalse)
    If CBool(bClause) Then
        IIf = sTrue
    Else 	
        IIf = sFalse
    End If

End Function



function SQLInject(strWords) 
	newChars = strWords 
	newChars= replace(newChars, "-", "&minus;")
	newChars= replace(newChars, "'", "&apos;")
	newChars= replace(newChars, "|", "&vert;")
	newChars= replace(newChars, "\""", "&quot;")
	SQLInject=newChars
end function 



Function SendMail(toAddress, replyAddress, subject, body, htmlBody)
	Dim httpPostData
	Const API_URL = "https://api.smtp2go.com/v3/email/send"
	Const API_KEY = "api-C2E5A512FF0C11EC9F4EF23C91C88F4E"
	'Const fromAddress = replyAddress
	
	Set oJSON = New aspJSON

	With oJSON.data
		.add "api_key", API_KEY
		.add "to", oJSON.Collection()
			With .item("to")
				.add 0, toAddress
			end with	
		.add "sender", replyAddress
		.add "subject", subject
		.add "text_body", body
		.add "html_body", htmlBody
		.add "custom_headers", oJSON.Collection()
			With oJSON.data("custom_headers")
				.add 0, oJSON.Collection()
					With .item(0)				
						.add "header", "Reply-To"
						.add "value", replyAddress
					end with
			end with
	end with
		
	httpPostData = oJSON.JSONoutput()

	set http = CreateObject("MSXML2.ServerXMLHTTP.6.0")
	
	http.Open "POST", API_URL, false, "api", API_KEY
	http.setRequestHeader "Content-Type", "application/json"
	http.setRequestHeader "Authorization", "Basic AUTH_STRING"
	http.Send httpPostdata
	
	Set data = new aspJSON
	Dim success
	
	response.write http.responseText

	
	data.loadJSON(http.responseText)
	' first data = JSON Object
	' second data = method declared on JSON Object
	' Third data = object returned from http.responseText that contains the needed data 
	' data.succeeded retuns 0 or 1, since we are doing single emails.
	success = cbool(data.data("data").item("succeeded"))

	If http.status <> 200 Then
		SendMail = False
		else
		SendMail = success
	End If
	Set http = Nothing
End Function


Function RandomString(iSize)
    Const VALID_TEXT = "abcdefghijklmnopqrstuvwxyz1234567890"
    Dim Length, sNewSearchTag, I

    Length = Len(VALID_TEXT)

    Randomize()

    For I = 1 To iSize            
        sNewSearchTag = sNewSearchTag & Mid(VALID_TEXT, Int(Rnd()*Length + 1), 1)
    Next

    RandomString = sNewSearchTag
End Function




function login(user,password)
	Dim usuario
	dim sql_consulta
	if not isnull(user) and not isnull(password) and not password = "" then
		login = 0
		sql_consulta = SQL_CONSULTA_USUARIO_LOGIN(user, sha256(replace(password, "'", "")))
		
		Call getRecordSet(sql_consulta, usuario)

		if not(usuario.eof) then
			Session("email") = usuario("email")
			Session("name") = usuario("name")
			Session("photo") = usuario("photo")
			Session("admin") = usuario("admin")
			Session("loginError") = NULL
			login=1
		else
			login = 0
		end if 
	else
		login = 2
	end if
end function


Sub ZipFolder(Folder,SaveTo,ZipName)

    Dim CMD, objShell
	const DontWaitUntilFinished = false, ShowWindow = 1, DontShowWindow = 0, WaitUntilFinished = true
    
    CMD = """%ProgramFiles%\7-Zip\7z.exe"" a " &_
    """" & Server.MapPath(SaveTo) & "\" & ZipName & """ " &_
    """" & Server.MapPath(Folder)& "\*" & """"
                                
    Set objShell = server.CreateObject("WScript.Shell")

	objShell.Run CMD, DontShowWindow, WaitUntilFinished
    
    'Call objShell.Exec(CMD)
                
    Set objShell = Nothing
            
End Sub
    

%>

