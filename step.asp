<!--#include virtual="/system.asp"-->

<%

parentList=Array()
ReDim Preserve parentList(0)


Function countChild (stepID)

	Dim rs

	Call getRecordSet(SQL_CONSULTA_NUM_STEP_CHILD(stepID), rs)
	
	countChild = rs("total")

end function





Sub printStep(rs)
dim urlStep

	' Remove Duplicatas
	if  in_array(cstr(rs("stepID")), parentList) then
		exit sub
	else
		ReDim Preserve parentList(ubound(parentList)+1)
		parentList(ubound(parentList)) = cstr(rs("stepID"))
	end if



if rs("type") > 0 and rs("status") > STATE_LOCKED then
	urlStep = getBaseFolderByFTAmethodID(cstr(rs("type"))) + "index.asp?stepID="+cstr(rs("stepID"))
elseif  rs("type") = 0  then
	Call getRecordSet(SQL_CONSULTA_SUB_WORKFLOW_BY_PARENTSTEP(cstr(rs("stepID"))), rs2)
	if not rs2.eof then
		urlStep = "/manageWorkflow.asp?workflowID="+cstr(rs2("workflowID"))
		else
		urlStep = "/index.asp"
	end if
else
		urlStep = ""
end if
%>
<div class="window jtk-endpoint-anchor jtk-draggable p-0" id="step<%=cstr(rs("stepID"))%>" style="width:322px; height:322px;text-shadow:1px 1px 2px #333333;" <%if urlStep <> "" then%>ondblclick="window.location.href='<%=urlStep%>';" <%end if%>>
	<div class="step<%=getStatus(rs("status"))%>" style="height:320px;width:320px;float:left;"> 
		<table height="100%" width="100%" class="text-light">
			<tr height="25px">
				<td align=center>
					<h1 class="fs-5 text-uppercase"><%=getFTAMethodNamebyFTAmethodID(cstr(rs("type")))%></h1>
				</td>
			</tr>
			<tr height="200px">
				<td style="margin:0px;">
					<div style="height:240px; overflow-y: auto;" class="fs-6">
						<%
						Dim flagEditSubWorkflow
						flagEditSubWorkflow = false
						if rs("type") > 0 then
							dim roles
							roles = getRoleListbyFTAmethodID(cstr(rs("type")))
							
							for each role in roles
							
								' Get users from this step!
								Dim rs2

								Call getRecordSet(SQL_CONSULTA_WORKFLOW_USERS_BY_STEP_ROLE(cstr(rs("stepID")), role ), rs2)
								
								response.write "<p class=""px-2 small mt-3 mb-1 "">Role <b>"+ role +"</b>: " 

								if rs("status") = STATE_UNLOCKED or Session("admin") then 
								'response.write "<a href=""editStep.asp?stepID=" + cstr(rs("stepID"))+"&role="+ role +""" class=""text-light"">[Edit]</a>"
								%>
								<button class="btn btn-sm btn-danger m-0" type="button" data-bs-toggle="modal" data-bs-target="#participantsModal" data-workflow-id="<%=cstr(rsWf("workflowID"))%>" data-title="Edit <%=getFTAMethodNamebyFTAmethodID(cstr(rs("type")))%>" data-url="<%="editStep.asp?stepID=" & cstr(rs("stepID")) & "&role=" & role%>"><i class="bi bi-pencil"></i></button>
								<button class="btn btn-sm btn-danger m-0" type="button" data-bs-toggle="modal" data-bs-target="#linkModal" data-title="Generate Link" data-url="<%="showlink.asp?stepID=" & cstr(rs("stepID")) & "&role=" & role & "&workflowID=" & cstr(rsWf("workflowID")) %>"><i class="bi bi-link-45deg"></i></button>
								
								<%
								end if 
								response.write "</p>"

								response.write "<center class=""small"">"
								
								while not rs2.eof

								response.write rs2("name") + " <br>"

								rs2.movenext
								Wend
								response.write "</center>"

							
							Next
						else ' SUB WORKFLOW
							
							' chamada movida lá pra cima
							'Call getRecordSet(SQL_CONSULTA_SUB_WORKFLOW_BY_PARENTSTEP(cstr(rs("stepID"))), rs2) 
							
							if not rs2.eof then
							

								response.write "<br><p align=justify>&nbsp;&nbsp;&nbsp;User Responsible: " 
							

								if (rs2("owner") = Session("email") and rs("status") = STATE_UNLOCKED) or Session("admin") then ' sou o owner do subworkflow e o Step está desbloqueado.
									flagEditSubWorkflow = true
									response.write " <a href='/manageWorkflow.asp?workflowID="+cstr(rs2("workflowID"))+"'>Edit</a>"
								end if
								
								response.write "</p>"
								
								response.write "<center>"
								response.write rs2("name")  
								response.write "</center>"
							
							end if
							
						
						end if 
				
						%>
					</div>
				</td>
			</tr>
			<tr height="35px"> 
				<td valign=middle align=center>
					<% if  rs("status") > STATE_LOCKED and (Session("admin")) then %>
						<button class="btn btn-sm btn-danger m-1" type="button" onclick="window.location.href='/stepActions.asp?action=rewind&workflowID=<%=cstr(rs("workflowID"))%>&stepID=<%=cstr(rs("stepID"))%>&status=<%=cstr(cint(rs("status"))-1)%>';" ><i class="bi bi-skip-backward-circle text-light"></i> Rewind State</button>
					<%end if%>
						
					<%if rs("status") = STATE_UNLOCKED or (Session("admin") and rs("status") <= STATE_ACTIVE)then %>
<!--						<button class="TIAMATButton" style="width:70px" onclick="window.open('editstep.asp?workflowID=<%=cstr(rs("workflowID"))%>&stepID=<%=cstr(rs("stepID"))%>', 'AddStep', 'width=800, height=600');"> Edit </button>
						<button class="btn btn-sm btn-danger m-1" type="button" onclick="window.location.href='addstep.asp?workflowID=<%=cstr(rs("workflowID"))%>&parentStepID=<%=cstr(rs("stepID"))%>';"> <i class="bi bi-plus-square text-light"></i> Add</button>
						-->						
						<button class="btn btn-sm btn-danger m-1" type="button" data-bs-toggle="modal" data-bs-target="#stepModal" data-url="addstep.asp?workflowID=<%=cstr(rs("workflowID"))%>&parentStepID=<%=cstr(rs("stepID"))%>" data-title="Add Step"><i class="bi bi-plus-square text-light"></i> Add</button>
						
						<% if countChild (cstr(rs("stepID"))) = 0 then %>
							<button class="btn btn-sm btn-danger m-1" type="button" onclick="window.location.href='stepActions.asp?action=delete&workflowID=<%=cstr(rs("workflowID"))%>&stepID=<%=cstr(rs("stepID"))%>';"> <i class="bi bi-trash text-light"></i> Delete</button>
						<%end if%>
						
						<%if flagEditSubWorkflow then%>
							<button class="btn btn-sm btn-danger m-1" type="button" onclick="window.location.href='/manageWorkflow.asp?workflowID=<%=cstr(rs2("workflowID"))%>';"> <i class="bi bi-arrow-down-square text-light"></i> Sub WF</button>
						<%end if%>
						
						<button class="btn btn-sm btn-danger m-1" type="button" data-bs-toggle="modal" data-bs-target="#stepModal" data-url="configureio.asp?workflowID=<%=cstr(rs("workflowID"))%>&parentStepID=<%=cstr(rs("stepID"))%>" data-title="Configure I/O"><i class="bi bi-plus-square text-light"></i> I/O</button>

					<%end if%>
				</td>
			</tr>
		</table>
	</div>
</div>
<%
end sub


Function in_array(element, arr)
  in_array = False
  For i=0 To Ubound(arr)
     If arr(i) = element Then
        in_array = True
        Exit Function      
     End If
  Next
End Function

sub printSteps(rs)


while not rs.eof
	call printStep(rs)
	
	Call getRecordSet(SQL_CONSULTA_WORKFLOW_SECONDARY_STEPS(cstr(rs("workflowID")),cstr(rs("stepID"))), rs2)
	call printSteps(rs2)
	
	rs.movenext
Wend

end sub
%>													
													