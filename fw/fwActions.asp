<!--#include virtual="/system.asp"-->
<!--#include file="INC_FUTURES_WHEEL.inc"-->
<!--#include virtual="/includes/JSON.asp"-->



<%

Function dealArray(RequestFormArray)
Set subject = RequestFormArray

ReDim subjects(subject.Count - 1)

For i = 1 To subject.Count
	response.write "X"
    subjects(i - 1) = subject(i)
Next

dealArray = subjects

end function

Dim action
Dim insertedFWID
Dim redirectLink

Dim i, j
Dim fwID, stepID, parentFWID, parentFWIDs, fwEvent, posX, posY, operation

const OPER_NO = 0
const OPER_ADD = 1
const OPER_EDIT = 2
const OPER_DEL = 3

action = Request.Querystring("action")
stepID = request.form("stepID")

Session("futuresWheelError") = ""

select case action

	case "save"
		
		if stepID <> "" then
			
			if Clng(request.form("redirectLink")) = 0 Then
				redirectLink = "index.asp?stepID=" & stepID
			Else
				redirectLink = ""
			End If
			
			if stepID <> "" And trim(request.form("fwEvent[]")) <> "" And _
				request.form("parentFWID[]") <> "" And request.form("operation[]") <> "" And _
				request.form("posX[]") <> "" And request.form("posY[]") <> "" Then
				
				call getRecordSet(SQL_CONSULTA_FUTURES_WHEEL_PRINCIPAL(stepID), rs)
				
				if rs.eof then ' first event
					
					if CLng(request.form("operation[]")) = OPER_ADD Then
						
						Set cnn = getConnection
						Call chamaSP(True, objSP, "SP_CREATE_FTA_METHOD_FUTURES_WHEEL",cnn)
						With objSP
							 .Parameters.Append .CreateParameter("RETORNO", adBigInt,adParamReturnValue)
							 .Parameters.Append .CreateParameter("@stepID",adBigInt,adParamInput,8,request.form("stepID"))
							 .Parameters.Append .CreateParameter("@fwEvent",advarchar,adParamInput,len(request.form("fwEvent[]")),trim(request.form("fwEvent[]")))
							 '.Parameters.Append .CreateParameter("@parentFWID",adBigInt,adParamInput,8,request.form("parentFWID[]"))
							 .Parameters.Append .CreateParameter("@posX",adInteger,adParamInput,4,request.form("posX[]"))
							 .Parameters.Append .CreateParameter("@posY",adInteger,adParamInput,4,request.form("posY[]"))
							 .Execute
							 
							 insertedFwID = .Parameters("RETORNO")
							 
						End With
						Call chamaSP(False, objSP, Null, Null)
						dispose(cnn)
						
						If insertedFWID = -1 Then
							Session("futuresWheelError") = "An error has occurred when trying to create a new event. Please inform the system administrator."
						Else
							Call ExecuteSQL(SQL_CRIA_FUTURES_WHEEL_LINK(insertedFWID, insertedFWID)) 'request.form("parentFWID[]")))
							
							response.redirect "index.asp?stepID=" & stepID
						End If
					Else
						Session("futuresWheelError") = "Invalid operation for the first Futures Wheel event. Please inform the system administrator."
					End If
					
				Else
					
					 
					
					
					fwID = dealArray(request.form("fwID[]"))
					parentFWID = dealArray(request.form("parentFWID[]"))
					fwEvent = dealArray(request.form("fwEvent[]"))
					posX = dealArray(request.form("posX[]"))
					posY = dealArray(request.form("posY[]"))
					operation = dealArray(request.form("operation[]")) 
					
					
					
					i = 0
					While i <= UBound(operation)
						'response.write(fwID(i) & ", " & fwEvent(i) & ", " & parentFWID(i) & ", " & posX(i) & ", " & posY(i) & ", " & operation(i) & "<br />")
						
						if posX(i) < 0 then posX(i)=0
						if posY(i) < 0 then posY(i)=0						
						If CLng(operation(i)) = OPER_NO Then
							'
						ElseIf CLng(operation(i)) = OPER_ADD Then ' New
							
							Set cnn = getConnection
							Call chamaSP(True, objSP, "SP_CREATE_FTA_METHOD_FUTURES_WHEEL",cnn)
							With objSP
								 .Parameters.Append .CreateParameter("RETORNO", adBigInt,adParamReturnValue)
								 .Parameters.Append .CreateParameter("@stepID",adBigInt,adParamInput,8,stepID)
								 .Parameters.Append .CreateParameter("@fwEvent",advarchar,adParamInput,len(trim(fwEvent(i))),trim(fwEvent(i)))
								 '.Parameters.Append .CreateParameter("@parentFWID",adBigInt,adParamInput,8,parentFWID(i))
								 .Parameters.Append .CreateParameter("@posX",adInteger,adParamInput,4,posX(i))
								 .Parameters.Append .CreateParameter("@posY",adInteger,adParamInput,4,posY(i))
								 .Execute
								 
								 insertedFwID = .Parameters("RETORNO")
								 
							End With
							Call chamaSP(False, objSP, Null, Null)
							dispose(cnn)
							
							If insertedFWID = -1 Then
								Session("futuresWheelError") = "An error has occurred when trying to create a new event. Please inform the system administrator."
							Else
								
								j = 0
								parentFWIDs = split(parentFWID(i), " | ")
								
								While j <= UBound(parentFWIDs)
								
									If parentFWIDs(j) <> insertedFWID Then
										Call ExecuteSQL(SQL_CRIA_FUTURES_WHEEL_LINK(insertedFWID, parentFWIDs(j)))
									End If
									
									j = j + 1
								Wend
								
							End If
							
						ElseIf CLng(operation(i)) = OPER_EDIT Then ' Edit
							
							If fwID(i) <> "" And trim(fwEvent(i)) <> "" And parentFWID(i) <> "" Then
								Call ExecuteSQL(SQL_ATUALIZA_FUTURES_WHEEL(fwID(i), trim(fwEvent(i)), posX(i), posY(i)))
								
								j = 0
								parentFWIDs = split(parentFWID(i), " | ")
								
								If parentFWID(i) <> fwID(i) Then
									Call ExecuteSQL(SQL_EXCLUI_FUTURES_WHEEL_LINK(fwID(i)))
								End If
								
								While j <= UBound(parentFWIDs)
								
									If parentFWIDs(j) <> fwID(i) Then
										Call ExecuteSQL(SQL_CRIA_FUTURES_WHEEL_LINK(fwID(i), parentFWIDs(j)))
									End If
									
									j = j + 1
								Wend
								
							Else
								Session("futuresWheelError") = "Invalid Futures Wheel event. Please inform the system administrator."
							End If
							
						ElseIf CLng(operation(i)) = OPER_DEL Then ' Delete
							
							Call ExecuteSQL(SQL_EXCLUI_FUTURES_WHEEL_LINK(fwID(i)))
							
							Call ExecuteSQL(SQL_EXCLUI_FUTURES_WHEEL(fwID(i)))
							
						Else
							Session("futuresWheelError") = "Invalid operation for Futures Wheel event. Please inform the system administrator."	
						End If
						
						i = i + 1
					Wend
				End If
			Else
				Session("futuresWheelError") = "Invalid Futures Wheel event. Please inform the system administrator."	
			End If
			
			if redirectLink <> "" then response.redirect redirectLink
				
		else
			
			call response.write ("Invalid FTA method. Please inform the system administrator.")
			
		end if 
		
		
		
	case "savePos"


		Set oJSON = New aspJSON

		'Load JSON string
		oJSON.loadJSON(Request.Form)
		
		'Loop through collection
		For Each node In oJSON.data("nodes")
			fwID = oJSON.data("nodes").item(node).item("fwID")
			posX = oJSON.data("nodes").item(node).item("positionX")
			posY = oJSON.data("nodes").item(node).item("positionY")
			
			if cint(posX) <0 then posX = 0 
			if cint(posY) <0 then posY = 0 
			
			Call ExecuteSQL(SQL_ATUALIZA_FUTURES_WHEEL_POSITION(cint(fwID), cint(posX),cint(posY)))
			
		Next
		
	case "end"

		if request.querystring("stepID") <> "" then
			call endStep(request.querystring("stepID"))
			
			response.redirect "/workplace.asp"
		end if

	case else

		call response.write ("Invalid action supplied. Please inform the system administrator.")
	
end select
	
%>
