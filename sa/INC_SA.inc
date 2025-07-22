<%

function SQL_CONSULTA_SA(stepID)
	SQL_CONSULTA_SA = "Select * from T_FTA_METHOD_STAKEHOLDER_ANALYSIS where stepID="+stepID
end function

function SQL_CRIA_SA(stepID, description)
	SQL_CRIA_SA = "INSERT INTO T_FTA_METHOD_STAKEHOLDER_ANALYSIS (stepID, description) VALUES ('"+stepID+"','"+description+"')" 
end function

function SQL_ATUALIZA_SA(stepID, description)
	SQL_ATUALIZA_SA = "UPDATE T_FTA_METHOD_STAKEHOLDER_ANALYSIS SET description='"+description+"' WHERE stepID="+stepID
end function



function SQL_CONSULTA_STAKEHOLDER(SAID)
	SQL_CONSULTA_STAKEHOLDER = "Select * from T_FTA_METHOD_STAKEHOLDER_ANALYSIS_STAKEHOLDERS where SAID="+SAID
end function

function SQL_CONSULTA_STAKEHOLDERS_BY_stepIP(stepID)
	SQL_CONSULTA_STAKEHOLDERS_BY_stepIP = "Select * from T_FTA_METHOD_STAKEHOLDER_ANALYSIS_STAKEHOLDERS stakeholder INNER JOIN T_FTA_METHOD_STAKEHOLDER_ANALYSIS sa ON sa.SAID = stakeholder.SAID where sa.stepID="+stepID
end function
		 
function SQL_CONSULTA_STAKEHOLDER_BY_STAKEHOLDERID(stakeholderID)
	SQL_CONSULTA_STAKEHOLDER_BY_STAKEHOLDERID = "Select * from T_FTA_METHOD_STAKEHOLDER_ANALYSIS_STAKEHOLDERS where stakeholderID="+stakeholderID
end function

function SQL_ATUALIZA_STAKEHOLDER(stakeholderID, tipe, organizationname, contactname, email, role, conflictrole)
	SQL_ATUALIZA_STAKEHOLDER = "UPDATE T_FTA_METHOD_STAKEHOLDER_ANALYSIS_STAKEHOLDERS SET type='"+tipe+"', organizationname='"+organizationname+"', contactname='"+contactname+"', email='"+email+"', role='"+role+"', conflictrole='"+conflictrole+"' WHERE stakeholderID="+stakeholderID
end function

function SQL_ATUALIZA_STAKEHOLDER_2(stakeholderID, tipe, contactname, email, role, conflictrole)
	SQL_ATUALIZA_STAKEHOLDER_2 = "UPDATE T_FTA_METHOD_STAKEHOLDER_ANALYSIS_STAKEHOLDERS SET type='"+tipe+"', organizationname=null , contactname='"+contactname+"', email='"+email+"', role='"+role+"', conflictrole='"+conflictrole+"' WHERE stakeholderID="+stakeholderID
end function

function SQL_ATUALIZA_STAKEHOLDER_3(stakeholderID, tipe, organizationname, contactname, email, role)
	SQL_ATUALIZA_STAKEHOLDER_3 = "UPDATE T_FTA_METHOD_STAKEHOLDER_ANALYSIS_STAKEHOLDERS SET type='"+tipe+"', organizationname='"+organizationname+"', contactname='"+contactname+"', email='"+email+"', conflictrole=null, role='"+role+"' WHERE stakeholderID="+stakeholderID
end function

function SQL_ATUALIZA_STAKEHOLDER_4(stakeholderID, tipe, contactname, email, role)
	SQL_ATUALIZA_STAKEHOLDER_4 = "UPDATE T_FTA_METHOD_STAKEHOLDER_ANALYSIS_STAKEHOLDERS SET type='"+tipe+"', organizationname=null, contactname='"+contactname+"', email='"+email+"', conflictrole=null, role='"+role+"' WHERE stakeholderID="+stakeholderID
end function

function SQL_ATUALIZA_STAKEHOLDER_POSITION(stakeholderID, posX, posY)
	SQL_ATUALIZA_STAKEHOLDER_POSITION = "UPDATE T_FTA_METHOD_STAKEHOLDER_ANALYSIS_STAKEHOLDERS SET posX='"+posX+"', posY='"+posY+"'  WHERE stakeholderID="+stakeholderID
end function

function SQL_DELETE_STAKEHOLDER(stakeholderID)
	SQL_DELETE_STAKEHOLDER = "DELETE FROM T_FTA_METHOD_STAKEHOLDER_ANALYSIS_STAKEHOLDERS WHERE stakeholderID="+stakeholderID
end function



function SQL_CONSULTA_INTEREST(SAID)
	SQL_CONSULTA_INTEREST = "Select * from T_FTA_METHOD_STAKEHOLDER_ANALYSIS_INTEREST where SAID="+SAID
end function

function SQL_CONSULTA_INTEREST_BY_stepID(stepID)
	SQL_CONSULTA_INTEREST_BY_stepID = "Select * from T_FTA_METHOD_STAKEHOLDER_ANALYSIS_INTEREST interest INNER JOIN T_FTA_METHOD_STAKEHOLDER_ANALYSIS sa ON sa.SAID = interest.SAID WHERE sa.stepID="+stepID
end function
		 
function SQL_CONSULTA_INTEREST_BY_INTERESTID(interestID)
	SQL_CONSULTA_INTEREST_BY_INTERESTID = "Select * from T_FTA_METHOD_STAKEHOLDER_ANALYSIS_INTEREST where interestID="+interestID
end function

function SQL_ATUALIZA_INTEREST(interestID, interest)
	SQL_ATUALIZA_INTEREST = "UPDATE T_FTA_METHOD_STAKEHOLDER_ANALYSIS_INTEREST SET interest='"+interest+"' WHERE interestID="+interestID
end function

function SQL_ATUALIZA_INTEREST_POSITION(interestID, posX, posY)
	SQL_ATUALIZA_INTEREST_POSITION = "UPDATE T_FTA_METHOD_STAKEHOLDER_ANALYSIS_INTEREST SET posX='"+posX+"', posY='"+posY+"'  WHERE interestID="+interestID
end function

function SQL_DELETE_INTEREST(interestID)
	SQL_DELETE_INTEREST = "DELETE FROM T_FTA_METHOD_STAKEHOLDER_ANALYSIS_INTEREST WHERE interestID="+interestID
end function


function SQL_CONSULTA_STAKEHOLDER_X_INTEREST(SAID)
	SQL_CONSULTA_STAKEHOLDER_X_INTEREST = "Select * from T_FTA_METHOD_STAKEHOLDER_ANALYSIS_STAKEHOLDER_X_INTEREST where SAID="+SAID
end function

function SQL_CONSULTA_STAKEHOLDER_X_INTEREST_BY_stepID(stepID)
	SQL_CONSULTA_STAKEHOLDER_X_INTEREST_BY_stepID = "select * from T_FTA_METHOD_STAKEHOLDER_ANALYSIS_STAKEHOLDER_X_INTEREST stakeholderInterest INNER JOIN T_FTA_METHOD_STAKEHOLDER_ANALYSIS sa ON sa.SAID = stakeholderInterest.SAID WHERE sa.stepID="+stepID
end function

function SQL_CONSULTA_STAKEHOLDER_X_INTEREST_BY_STAKEHOLDERINTERESTID(stakeholderInterestID)
	SQL_CONSULTA_STAKEHOLDER_X_INTEREST_BY_STAKEHOLDERINTERESTID = "Select * from T_FTA_METHOD_STAKEHOLDER_ANALYSIS_STAKEHOLDER_X_INTEREST where stakeholderInterestID="+stakeholderInterestID
end function

function SQL_CONSULTA_STAKEHOLDER_X_INTEREST_STAKEHOLDERID_INTERESTID(stakeholderID, interestID)
	SQL_CONSULTA_STAKEHOLDER_X_INTEREST_STAKEHOLDERID_INTERESTID = "Select * from T_FTA_METHOD_STAKEHOLDER_ANALYSIS_STAKEHOLDER_X_INTEREST where stakeholderID = '"+stakeholderID+"' AND interestID="+interestID
end function

function SQL_CRIA_STAKEHOLDER_X_INTEREST(stakeholderID, interestID, SAID)
	SQL_CRIA_STAKEHOLDER_X_INTEREST = "INSERT INTO T_FTA_METHOD_STAKEHOLDER_ANALYSIS_STAKEHOLDER_X_INTEREST (stakeholderID, interestID, SAID) VALUES ('"+stakeholderID+"','"+interestID+"','"+SAID+"')" 
end function

function SQL_ATUALIZA_STAKEHOLDER_X_INTEREST(stakeholderID, interestID, stakeholderInterestID)
	SQL_ATUALIZA_STAKEHOLDER_X_INTEREST = "UPDATE T_FTA_METHOD_STAKEHOLDER_ANALYSIS_STAKEHOLDER_X_INTEREST SET stakeholderID = '"+stakeholderID+"', interestID = '"+interestID+"' WHERE stakeholderInterestID="+stakeholderInterestID
end function

function SQL_DELETE_STAKEHOLDER_X_INTEREST(StakeholderInterestID)
	SQL_DELETE_STAKEHOLDER_X_INTEREST = "DELETE FROM T_FTA_METHOD_STAKEHOLDER_ANALYSIS_STAKEHOLDER_X_INTEREST WHERE StakeholderInterestID="+StakeholderInterestID
end function



function SQL_CONSULTA_STAKEHOLDER_X_STAKEHOLDER(SAID)
	SQL_CONSULTA_STAKEHOLDER_X_STAKEHOLDER = "Select * from T_FTA_METHOD_STAKEHOLDER_ANALYSIS_STAKEHOLDER_X_STAKEHOLDER where SAID="+SAID
end function

function SQL_CONSULTA_STAKEHOLDER_X_STAKEHOLDER_BY_stepID(stepID)
	SQL_CONSULTA_STAKEHOLDER_X_STAKEHOLDER_BY_stepID = "select * from T_FTA_METHOD_STAKEHOLDER_ANALYSIS_STAKEHOLDER_X_STAKEHOLDER stakeholderStakeholder INNER JOIN T_FTA_METHOD_STAKEHOLDER_ANALYSIS sa ON sa.SAID = stakeholderStakeholder.SAID WHERE sa.stepID="+stepID
end function

function SQL_CONSULTA_STAKEHOLDER_X_STAKEHOLDER_BY_STAKEHOLDERSTAKEHOLDERID(stakeholderStakeholderID)
	SQL_CONSULTA_STAKEHOLDER_X_STAKEHOLDER_BY_STAKEHOLDERSTAKEHOLDERID = "Select * from T_FTA_METHOD_STAKEHOLDER_ANALYSIS_STAKEHOLDER_X_STAKEHOLDER where stakeholderStakeholderID="+stakeholderStakeholderID
end function

function SQL_CONSULTA_STAKEHOLDER_X_STAKEHOLDER_FIRSTSTAKEHOLDER_SECONDSTAKEHOLDER_RELATIONSHIP(firstStakeholderID, secondStakeholderID, relationship)
	SQL_CONSULTA_STAKEHOLDER_X_STAKEHOLDER_FIRSTSTAKEHOLDER_SECONDSTAKEHOLDER_RELATIONSHIP = "Select * from T_FTA_METHOD_STAKEHOLDER_ANALYSIS_STAKEHOLDER_X_STAKEHOLDER where  firstStakeholderID = '"+firstStakeholderID+"' and relationship = '"+relationship+"' and  secondStakeholderID="+secondStakeholderID
end function

function SQL_CRIA_STAKEHOLDER_X_STAKEHOLDER(firstStakeholderID, secondStakeholderID, relationship, SAID)
	SQL_CRIA_STAKEHOLDER_X_STAKEHOLDER = "INSERT INTO T_FTA_METHOD_STAKEHOLDER_ANALYSIS_STAKEHOLDER_X_STAKEHOLDER (firstStakeholderID, secondStakeholderID, relationship, SAID) VALUES ('"+firstStakeholderID+"','"+secondStakeholderID+"','"+relationship+"','"+SAID+"')" 
end function

function SQL_ATUALIZA_STAKEHOLDER_X_STAKEHOLDER(firstStakeholderID, secondStakeholderID, relationship, StakeholderStakeholderID)
	SQL_ATUALIZA_STAKEHOLDER_X_STAKEHOLDER = "UPDATE T_FTA_METHOD_STAKEHOLDER_ANALYSIS_STAKEHOLDER_X_STAKEHOLDER SET firstStakeholderID = '"+firstStakeholderID+"', secondStakeholderID = '"+secondStakeholderID+"' , relationship = '"+relationship+"' WHERE StakeholderStakeholderID = "+StakeholderStakeholderID
end function

function SQL_DELETE_STAKEHOLDER_X_STAKEHOLDER(stakeholderStakeholderID)
	SQL_DELETE_STAKEHOLDER_X_STAKEHOLDER = "DELETE FROM T_FTA_METHOD_STAKEHOLDER_ANALYSIS_STAKEHOLDER_X_STAKEHOLDER WHERE stakeholderStakeholderID="+stakeholderStakeholderID
end function

Sub printSAStakeholder(saStakeholder, editMode) %>
	<div class="window stakeholder context-menu" id="stakeholder_<%=saStakeholder(0)%>" style="top:<%=saStakeholder(11)%>px; left:<%=saStakeholder(10)%>px;">
		<input type="hidden" name="StakeholderID[]" value="<%=saStakeholder(0)%>" />
		<input type="hidden" name="SAID[]" value="<%=saStakeholder(1)%>" />
		<input type="hidden" name="Type[]" value="<%=saStakeholder(2)%>" />
		<input type="hidden" name="OrganizationName[]" value="<%=saStakeholder(3)%>" />
		<input type="hidden" name="ContactName[]" value="<%=saStakeholder(4)%>" />
		<input type="hidden" name="Email[]" value="<%=saStakeholder(5)%>" />
		<input type="hidden" name="Role[]" value="<%=saStakeholder(6)%>" />
		<input type="hidden" name="ConflictRole[]" value="<%=saStakeholder(7)%>" />
		<input type="hidden" name="stepID[]" value="<%=saStakeholder(8)%>" />
		<input type="hidden" name="description[]" value="<%=saStakeholder(9)%>" />
		<input type="hidden" name="stakeholderPosX[]" value="<%=saStakeholder(10)%>" />
		<input type="hidden" name="stakeholderPosY[]" value="<%=saStakeholder(11)%>" />
		<input type="hidden" name="stID[]" value="<%=saStakeholder(0)%>" />
		<input type="hidden" name="window[]" value="0" />
	
		<div class="fw-event-text-table">
			<div class="fw-event-text-cell">
				<div class="fw-event-text"><%=saStakeholder(4)%></div>
			</div>
		</div>
	</div>
<%End Sub

Sub printSAInterest(saInterest, editMode) %>
	<div class="window interest context-menu" id="interest_<%=saInterest(0)%>" style="top:<%=saInterest(6)%>px; left:<%=saInterest(5)%>px;">
		<input type="hidden" name="InterestID[]" value="<%=saInterest(0)%>" />
		<input type="hidden" name="SAID[]" value="<%=saInterest(1)%>" />
		<input type="hidden" name="Interest[]" value="<%=saInterest(2)%>" />
		<input type="hidden" name="StepID[]" value="<%=saInterest(3)%>" />
		<input type="hidden" name="Description[]" value="<%=saInterest(4)%>" />
		<input type="hidden" name="interestPosX[]" value="<%=saInterest(5)%>" />
		<input type="hidden" name="interestPosY[]" value="<%=saInterest(6)%>" />
		<input type="hidden" name="irID[]" value="<%=saInterest(0)%>" />
		<input type="hidden" name="window[]" value="0" />
	
		<div class="fw-event-text-table">
			<div class="fw-event-text-cell">
				<div class="fw-event-text"><%=saInterest(2)%></div>
			</div>
		</div>
	</div>
<%End Sub


Sub printSAStakeholderInterest(saStakeholderInterest, editMode) %>
	<div class="stakeholderInterest context-menu" id="stakeholderInterest<%=saStakeholderInterest(0)%>" style="display:none">
		<input type="hidden" name="StakeholderInterestID[]" value="<%=saStakeholderInterest(0)%>" />
		<input type="hidden" name="SAID[]" value="<%=saStakeholderInterest(1)%>" />
		<input type="hidden" name="StakeholderID[]" value="<%=saStakeholderInterest(2)%>" />
		<input type="hidden" name="InterestID[]" value="<%=saStakeholderInterest(3)%>" />
		<input type="hidden" name="StepID[]" value="<%=saStakeholderInterest(4)%>" />
		<input type="hidden" name="description[]" value="<%=saStakeholderInterest(5)%>" />
		<input type="hidden" name="operation[]" value="0" />
	</div>
<%End Sub


Sub printSAStakeholderStakeholder(saStakeholderStakeholder, editMode) %>
	<div class="stakeholderStakeholder context-menu" id="stakeholderStakeholder<%=saStakeholderStakeholder(0)%>" style="display:none">
		<input type="hidden" name="StakeholderStakeholderID[]" value="<%=saStakeholderStakeholder(0)%>" />
		<input type="hidden" name="SAID[]" value="<%=saStakeholderStakeholder(1)%>" />
		<input type="hidden" name="FirstStakeholderID[]" value="<%=saStakeholderStakeholder(2)%>" />
		<input type="hidden" name="SecondStakeholderID[]" value="<%=saStakeholderStakeholder(3)%>" />
		<input type="hidden" name="Relationship[]" value="<%=saStakeholderStakeholder(4)%>" />
		<input type="hidden" name="stepID[]" value="<%=saStakeholderStakeholder(5)%>" />
		<input type="hidden" name="description[]" value="<%=saStakeholderStakeholder(6)%>" />
		<input type="hidden" name="operation[]" value="0" />
	</div>
<%End Sub

Sub printAllSAStakelholdersInterests(stepID, editMode)
	Dim rsStakeholders
	Dim saStakeholder(11)
	
	Call getRecordSet (SQL_CONSULTA_STAKEHOLDERS_BY_stepIP(stepID), rsStakeholders)
	
	If rsStakeholders.eof then
		
	Else
		While Not rsStakeholders.EOF
			saStakeholder(0) = rsStakeholders("StakeholderID")
			saStakeholder(1) = rsStakeholders("SAID")
			saStakeholder(2) = rsStakeholders("Type")
			saStakeholder(3) = rsStakeholders("OrganizationName")
			saStakeholder(4) = rsStakeholders("ContactName")
			saStakeholder(5) = rsStakeholders("Email")
			saStakeholder(6) = rsStakeholders("Role")
			saStakeholder(7) = rsStakeholders("ConflictRole")
			saStakeholder(8) = rsStakeholders("stepID")
			saStakeholder(9) = rsStakeholders("description")
			saStakeholder(10) = rsStakeholders("posX")
			saStakeholder(11) = rsStakeholders("posY")	
			
			Call printSAStakeholder(saStakeholder, editMode)
			
			rsStakeholders.moveNext()
		Wend	
	End If
	
	
	Dim rsInterests
	Dim saInterest(6)
	
	Call getRecordSet (SQL_CONSULTA_INTEREST_BY_stepID(stepID), rsInterests)
	
	If rsInterests.eof then
		
	Else
		While Not rsInterests.EOF
			saInterest(0) = rsInterests("InterestID")
			saInterest(1) = rsInterests("SAID")
			saInterest(2) = rsInterests("Interest")
			saInterest(3) = rsInterests("StepID")
			saInterest(4) = rsInterests("description")
			saInterest(5) = rsInterests("posX")
			saInterest(6) = rsInterests("posY")	
			
			Call printSAInterest(saInterest, editMode)
			
			rsInterests.moveNext()
		Wend	
	End If
	
	
	Dim rsStakeholderInterests
	Dim saStakeholderInterest(5)
	
	Call getRecordSet (SQL_CONSULTA_STAKEHOLDER_X_INTEREST_BY_stepID(stepID), rsStakeholderInterests)
	
	If rsStakeholderInterests.eof then
		
	Else
		While Not rsStakeholderInterests.EOF
			saStakeholderInterest(0) = rsStakeholderInterests("StakeholderInterestID")
			saStakeholderInterest(1) = rsStakeholderInterests("SAID")
			saStakeholderInterest(2) = rsStakeholderInterests("StakeholderID")
			saStakeholderInterest(3) = rsStakeholderInterests("InterestID")
			saStakeholderInterest(4) = rsStakeholderInterests("stepID")
			saStakeholderInterest(5) = rsStakeholderInterests("description")
			
			Call printSAStakeholderInterest(saStakeholderInterest, editMode)
			
			rsStakeholderInterests.moveNext()
		Wend	
	End If
	
	
	Dim rsStakeholderStakeholders
	Dim saStakeholderStakeholder(6)
	
	Call getRecordSet (SQL_CONSULTA_STAKEHOLDER_X_STAKEHOLDER_BY_stepID(stepID), rsStakeholderStakeholders)
	
	If rsStakeholderStakeholders.eof then
		
	Else
		While Not rsStakeholderStakeholders.EOF
			saStakeholderStakeholder(0) = rsStakeholderStakeholders("StakeholderStakeholderID")
			saStakeholderStakeholder(1) = rsStakeholderStakeholders("SAID")
			saStakeholderStakeholder(2) = rsStakeholderStakeholders("FirstStakeholderID")
			saStakeholderStakeholder(3) = rsStakeholderStakeholders("SecondStakeholderID")
			saStakeholderStakeholder(4) = rsStakeholderStakeholders("Relationship")
			saStakeholderStakeholder(5) = rsStakeholderStakeholders("stepID")
			saStakeholderStakeholder(6) = rsStakeholderStakeholders("description")
			
			Call printSAStakeholderStakeholder(saStakeholderStakeholder, editMode)
			
			rsStakeholderStakeholders.moveNext()
		Wend	
	End If
	
End Sub
%>