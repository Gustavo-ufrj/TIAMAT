<!--#include virtual="/system.asp"-->
<!--#include virtual="/includes/JSON.asp"-->
<!--#include file="INC_SA.inc"-->

<%

Dim action
Dim insertedFWID
Dim redirectLink

Dim i, j
Dim fwID, stepID, parentFWID, parentFWIDs, fwEvent, posX, posY, operation, stakeholderID

const OPER_NO = 0
const OPER_ADD = 1
const OPER_EDIT = 2
const OPER_DEL = 3

action = Request.Querystring("action")
stepID = request.form("stepID")

Session("futuresWheelError") = ""

select case action

	case "saveStakeholder"
	
		Set oJSON = New aspJSON

		'Load JSON string
		oJSON.loadJSON(Request.Form)
		
		'Loop through collection
		For Each node In oJSON.data("nodes")
			stakeholderID = oJSON.data("nodes").item(node).item("stakeholderID")
			stakeholderID = replace(stakeholderID, "stakeholder_", "")
			posX = oJSON.data("nodes").item(node).item("positionX")
			posY = oJSON.data("nodes").item(node).item("positionY")
			
			if cint(posX) <0 then posX = 0 
			if cint(posY) <0 then posY = 0 
			
			Call ExecuteSQL(SQL_ATUALIZA_STAKEHOLDER_POSITION( cstr(stakeholderID), cstr(posX), cstr(posY) ) )
			
		Next

	case "saveInterest"
	
		Set oJSON = New aspJSON

		'Load JSON string
		oJSON.loadJSON(Request.Form)
		
		'Loop through collection
		For Each node In oJSON.data("nodes")
			interestID = oJSON.data("nodes").item(node).item("interestID")
			interestID = replace(interestID, "interest_", "")
			posX = oJSON.data("nodes").item(node).item("positionX")
			posY = oJSON.data("nodes").item(node).item("positionY")
			
			if cint(posX) <0 then posX = 0 
			if cint(posY) <0 then posY = 0 
			
			Call ExecuteSQL(SQL_ATUALIZA_INTEREST_POSITION( cstr(interestID), cstr(posX), cstr(posY) ))
			
		Next
		
	case "save"
		
		if stepID <> "" then
			stakeholdersID = split(request.form("stID[]"), ", ")
			stakeholdersPosX = split(request.form("stakeholderPosX[]"), ", ")
			stakeholdersPosY = split(request.form("stakeholderPosY[]"), ", ")
			
			i=0
			While i <= Ubound(stakeholdersID)
				response.write(i)
				Call ExecuteSQL(SQL_ATUALIZA_STAKEHOLDER_POSITION( StakeholdersID(i), stakeholdersPosX(i), stakeholdersPosY(i) ))
				i = i + 1
			Wend
			
			interestsID = split(request.form("irID[]"), ", ")
			interestsPosX = split(request.form("interestPosX[]"), ", ")
			interestsPosY = split(request.form("interestPosY[]"), ", ")
			
			i=0
			While i <= Ubound(interestsID)
				response.write(i)
				Call ExecuteSQL(SQL_ATUALIZA_INTEREST_POSITION( interestsID(i), interestsPosX(i), interestsPosY(i) ))
				i = i + 1
			Wend
			
			response.redirect "index.asp?stepID=" & stepID
			
		else
			
			call response.write ("Invalid FTA method. Please inform the system administrator.")
			
		end if 
		
	case "end"

		if request.querystring("stepID") <> "" then
			call endStep(request.querystring("stepID"))
			
			response.redirect "/workplace.asp"
		end if

	case else

		call response.write ("Invalid action supplied. Please inform the system administrator.")
	
end select
	
%>
