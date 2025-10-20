<%
' Funções SQL para o Futures Wheel

function SQL_CONSULTA_FUTURES_WHEEL_PRINCIPAL(stepID)
	SQL_CONSULTA_FUTURES_WHEEL_PRINCIPAL = "SELECT fw.*, fwl.parentFWID " & vbCrLf & _
											"FROM T_FTA_METHOD_FUTURES_WHEEL fw" & vbCrLf & _
											"	INNER JOIN T_FTA_METHOD_FUTURES_WHEEL_LINK fwl ON fwl.actualFWID = fw.fwID" & vbCrLf & _
											"WHERE fw.stepID = " & stepID & _
											"	AND fwl.parentFWID = fw.fwID "
end function

function SQL_CONSULTA_FUTURES_WHEEL_DERIVADAS(stepID, fwIDs)
	SQL_CONSULTA_FUTURES_WHEEL_DERIVADAS = "SELECT fw.*, fwl.parentFWID " & vbCrLf & _
											"FROM T_FTA_METHOD_FUTURES_WHEEL fw" & vbCrLf & _
											"	INNER JOIN T_FTA_METHOD_FUTURES_WHEEL_LINK fwl ON fwl.actualFWID = fw.fwID" & vbCrLf & _
											"WHERE fw.stepID = " & stepID & _
											"	AND fwl.parentFWID IN (" & fwIDs & ")" & vbCrLf & _
											"	AND fwl.parentFWID <> fw.fwID" & vbCrLf & _
											"ORDER BY fwl.actualFWID"
end function

function SQL_CONSULTA_FUTURES_WHEEL_LINK(actualFWID)
	SQL_CONSULTA_FUTURES_WHEEL_LINK = "SELECT * " & vbCrLf & _
										"FROM T_FTA_METHOD_FUTURES_WHEEL_LINK " & vbCrLf & _
										"WHERE actualFWID = " & actualFWID & _
										" ORDER BY parentFWID"
end function

function SQL_CONSULTA_FUTURES_WHEEL_HEIGHT(stepID)
	SQL_CONSULTA_FUTURES_WHEEL_HEIGHT = "SELECT MAX(posY) AS height " & vbCrLf & _
											"FROM T_FTA_METHOD_FUTURES_WHEEL " & vbCrLf & _
											"WHERE stepID = " & stepID 
end function

function SQL_ATUALIZA_FUTURES_WHEEL(fwID, fwEvent, posX, posY)
	SQL_ATUALIZA_FUTURES_WHEEL = "UPDATE T_FTA_METHOD_FUTURES_WHEEL SET " & vbCrLf & _
								"event = '" & Replace(fwEvent, "'", "''") & "', "& vbCrLf & _
								"posX = '" & posX & "', " & vbCrLf & _
								"posY = '" & posY & "' " & vbCrLf & _
								"WHERE fwID = " & fwID
end function

function SQL_ATUALIZA_FUTURES_WHEEL_POSITION(fwID, posX, posY)
	SQL_ATUALIZA_FUTURES_WHEEL_POSITION = "UPDATE T_FTA_METHOD_FUTURES_WHEEL SET posX = '" & posX & "', posY = '" & posY & "' WHERE fwID = " & fwID
end function

function SQL_ATUALIZA_FUTURES_WHEEL_LINK(actualFWID, parentFWID)
	SQL_ATUALIZA_FUTURES_WHEEL_LINK = "UPDATE T_FTA_METHOD_FUTURES_WHEEL_LINK SET " & vbCrLf & _
										"parentFWID = '" & parentFWID & "' "& vbCrLf & _
										"WHERE actualFWID = " & actualFWID
end function

function SQL_CRIA_FUTURES_WHEEL(stepID, fwEvent, parentFWID, posX, posY)
	SQL_CRIA_FUTURES_WHEEL = "INSERT INTO T_FTA_METHOD_FUTURES_WHEEL (stepID, event, posX, posY) " & vbCrLf & _
							"VALUES (" & stepID & ", '" & Replace(fwEvent, "'", "''") & "', " & posX & ", " & posY & ")"
end function

function SQL_CRIA_FUTURES_WHEEL_LINK(actualFWID, parentFWID)
	SQL_CRIA_FUTURES_WHEEL_LINK = "INSERT INTO T_FTA_METHOD_FUTURES_WHEEL_LINK (actualFWID, parentFWID) " & vbCrLf & _
									"VALUES (" & actualFWID & ", " & parentFWID & ")"
end function

function SQL_EXCLUI_FUTURES_WHEEL_LINK(actualFWID)
	SQL_EXCLUI_FUTURES_WHEEL_LINK = "DELETE T_FTA_METHOD_FUTURES_WHEEL_LINK " & vbCrLf & _
									"WHERE actualFWID = " & actualFWID
end function

function SQL_EXCLUI_FUTURES_WHEEL(fwID)
	SQL_EXCLUI_FUTURES_WHEEL = "DELETE T_FTA_METHOD_FUTURES_WHEEL " & vbCrLf & _
								"WHERE fwID = " & fwID
end function

Sub printFWEvent(fwEvent, order, editMode) 
%>
	<div class="window context-menu order-<%=order%>" id="<%=fwEvent(0)%>" style="top:<%=fwEvent(5)%>px; left:<%=fwEvent(4)%>px;">
		<input type="hidden" name="fwID[]" value="<%=fwEvent(0)%>" />
		<input type="hidden" name="stepID[]" value="<%=fwEvent(1)%>" />
		<input type="hidden" name="parentFWID[]" value="<%=fwEvent(3)%>" />
		<input type="hidden" name="order[]" value="<%=order%>" />
		<input type="hidden" name="fwEvent[]" value="<%=fwEvent(2)%>" />
		<input type="hidden" name="posX[]" value="<%=fwEvent(4)%>" />
		<input type="hidden" name="posY[]" value="<%=fwEvent(5)%>" />
		<input type="hidden" name="operation[]" value="0" />
	
		<div class="fw-event-text-table w-100">
			<div class="fw-event-text-cell">
				<div class="fw-event-text"><%=fwEvent(2)%></div>
			</div>
		</div>
	</div>
<%End Sub

function getOrder(fwID) 
	Dim rsFW, maxOrder, currentOrder
	Call getRecordSet (SQL_CONSULTA_FUTURES_WHEEL_LINK(fwID), rsFW)

	getOrder = 0
	maxOrder = 0
	while not rsFW.eof 
		if cstr(rsFW("actualFWID")) = cstr(rsFW("parentFWID")) then
			getOrder = 0
			exit function
		else
			currentOrder = getOrder(rsFW("parentFWID"))
			if  currentOrder > maxOrder then
				maxOrder = currentOrder
			end if
		end if
		rsFW.moveNext()
	Wend
	getOrder = maxOrder +1
end function

function getParentList(fwID) 
	Dim rsFW, List
	Call getRecordSet (SQL_CONSULTA_FUTURES_WHEEL_LINK(fwID), rsFW)

	List=""

	while not rsFW.eof 
		List = List & rsFW("parentFWID") & " | "
		rsFW.moveNext()
	Wend

	If Len(List) > 3 Then
		getParentList = mid(List, 1, len(List) - 3)
	Else
		getParentList = ""
	End If
end function

Sub printAllFWEvents(stepID, editMode)
	Dim rsFW
	Dim termina, fwIDs, fwIDAnt
	Dim order
	Dim fwEvents(5)
	Dim printedEvents()
	
	termina = False
	
	Call getRecordSet (SQL_CONSULTA_FUTURES_WHEEL_PRINCIPAL(stepID), rsFW)
	
	If rsFW.eof then
		' Não há eventos ainda
	Else
		fwEvents(0) = rsFW("fwID")
		fwEvents(1) = rsFW("stepID")
		fwEvents(2) = rsFW("event")
		fwEvents(3) = rsFW("parentFWID")
		fwEvents(4) = rsFW("posX")
		fwEvents(5) = rsFW("posY")
		
		fwIDs = rsFW("fwID")
		
		order = 0
	
		Redim printedEvents(0)
		printedEvents(0) = fwEvents(0)
		
		Call printFWEvent(fwEvents, order, editMode)
		
		While Not termina
			Call getRecordSet (SQL_CONSULTA_FUTURES_WHEEL_DERIVADAS(stepID, fwIDs), rsFW)
		
			fwIDs = ""
			order = order + 1
			
			If rsFW.EOF Then
				termina = True
			Else
				While Not rsFW.EOF
					fwEvents(0) = rsFW("fwID")
					fwEvents(1) = rsFW("stepID")
					fwEvents(2) = trim(rsFW("event"))
					fwEvents(3) = getParentList(rsFW("fwID"))	
					fwEvents(4) = rsFW("posX")
					fwEvents(5) = rsFW("posY")
					
					if getOrder(fwEvents(0)) = order and not in_array(fwEvents(0), split(fwIDs, ", ")) then
						Call printFWEvent(fwEvents, order, editMode)
					end if
					
					fwIDs = fwIDs & rsFW("fwID") & ", "
					rsFW.moveNext()
				Wend
				
				fwIDs = mid(fwIDs, 1, len(fwIDs) - 2)
			End If
		Wend
	End If
End Sub

' ========== FUNÇÕES DUBLIN CORE ==========

Function getWorkflowID(stepID)
    Dim rs
    Call getRecordSet("SELECT workflowID FROM T_WORKFLOW_STEP WHERE stepID = " & stepID, rs)
    If Not rs.EOF Then
        getWorkflowID = rs("workflowID")
    Else
        getWorkflowID = 0
    End If
End Function

Function getPreviousSteps(workflowID, currentStepID)
    Dim rs, steps
    Dim i
    i = 0
    steps = ""
    
    Call getRecordSet("SELECT ws.stepID FROM T_WORKFLOW_STEP ws " & _
                      "INNER JOIN T_WORKFLOW_STEP_POSITION wsp ON ws.stepID = wsp.stepID " & _
                      "WHERE ws.workflowID = " & workflowID & " " & _
                      "AND wsp.position < (SELECT wsp2.position FROM T_WORKFLOW_STEP_POSITION wsp2 WHERE wsp2.stepID = " & currentStepID & ") " & _
                      "ORDER BY wsp.position", rs)
    
    While Not rs.EOF
        If steps <> "" Then steps = steps & ","
        steps = steps & rs("stepID")
        rs.MoveNext()
    Wend
    
    getPreviousSteps = steps
End Function

Function getStepPosition(stepID)
    Dim rs
    Call getRecordSet("SELECT position FROM T_WORKFLOW_STEP_POSITION WHERE stepID = " & stepID, rs)
    If Not rs.EOF Then
        getStepPosition = rs("position")
    Else
        getStepPosition = 0
    End If
End Function

Function getMethodName(stepID)
    Dim rs
    Call getRecordSet("SELECT fm.name FROM tiamat_fta_methods fm " & _
                      "INNER JOIN tiamat_steps s ON fm.id = s.method_id " & _
                      "WHERE s.step_id = " & stepID, rs)
    If Not rs.EOF Then
        getMethodName = rs("name")
    Else
        getMethodName = "Unknown"
    End If
End Function

Function SQL_CONSULTA_DUBLIN_CORE_PREVIOUS_STEPS(stepIDs)
    If stepIDs <> "" Then
        SQL_CONSULTA_DUBLIN_CORE_PREVIOUS_STEPS = "SELECT dc.*, s.step_id, fm.name as method_name " & vbCrLf & _
                                                  "FROM tiamat_dublin_core dc " & vbCrLf & _
                                                  "INNER JOIN tiamat_steps s ON dc.step_id = s.step_id " & vbCrLf & _
                                                  "INNER JOIN tiamat_fta_methods fm ON s.method_id = fm.id " & vbCrLf & _
                                                  "WHERE dc.step_id IN (" & stepIDs & ") " & vbCrLf & _
                                                  "ORDER BY dc.dc_date DESC"
    Else
        SQL_CONSULTA_DUBLIN_CORE_PREVIOUS_STEPS = "SELECT * FROM tiamat_dublin_core WHERE 1=0"
    End If
End Function

Function SQL_CONSULTA_FUTURES_WHEEL_DUBLIN_CORE(stepID)
    SQL_CONSULTA_FUTURES_WHEEL_DUBLIN_CORE = "SELECT fwdc.*, dc.* " & vbCrLf & _
                                             "FROM T_FTA_METHOD_FUTURES_WHEEL_DUBLIN_CORE fwdc " & vbCrLf & _
                                             "INNER JOIN tiamat_dublin_core dc ON fwdc.dublin_core_id = dc.dublin_core_id " & vbCrLf & _
                                             "INNER JOIN T_FTA_METHOD_FUTURES_WHEEL fw ON fwdc.fwID = fw.fwID " & vbCrLf & _
                                             "WHERE fw.stepID = " & stepID
End Function
%>