<!--#include virtual="/system.asp"-->
<%
if Request.querystring("workflowID") <> "" then
	Dim rs0

	Call getRecordSet(SQL_CONSULTA_WORKFLOW_STEP_POSITION(Request.querystring("workflowID")), rs0)
	Dim maximumPosY
	maximumPosY=100
	while not rs0.eof
		if not isnull(rs0("posX")) and not isnull(rs0("posY")) then
			if rs0("posY")> maximumPosY then
			maximumPosY = rs0("posY")
			end if
%>		

  #step<%=cstr(rs0("stepID"))%> { 
	left:<%=cstr(rs0("posX"))%>px; 
	top:<%=cstr(rs0("posY"))%>px;
  }

		<%
		end if
		rs0.movenext
	Wend
end if
%>

.tiamat_dynamic_workflow_height {
	height:<%=(maximumPosY +350)%>px; 
	}