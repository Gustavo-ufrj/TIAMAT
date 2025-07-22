<!--#include virtual="/system.asp"-->
<!--#include virtual="/checkstep.asp"-->
<!--#include file="INC_OA.inc"-->
<%
saveCurrentURL
render.renderToBody()
%>

	<%
													
	Dim benefit

	call getRecordSet (SQL_CONSULTA_OA(request.querystring("stepID")), rs)
	
	if not rs.eof then																							
		benefit=rs("benefit")
	else
		benefit=""
	end if

	%>

<div class="p-3">
	
	<form id="oaAction" name="oaAction" action="oaActions.asp?action=save"  method=post class="requires-validation m-0" novalidate>

	 <div class="mb-2">
		<label for="benefit" class="form-label">Benefit</label>
			<textarea class="form-control w-100" rows=10 id="benefit" name="benefit"><%=benefit%></textarea>
	  </div>
		<input type=hidden name="stepID" value="<%=request.querystring("stepID")%>" />

 <div class="modal-footer fixed-bottom pb-0 px-0 mx-0 bg-white">
 
 		<button class="btn btn-sm btn-secondary m-1" type="button" onclick="top.location.href = './index.asp?stepID=<%=request.querystring("stepID")%>';return false;">Cancel</button>
		<button class="btn btn-sm btn-danger m-1" onClick="verifica_tipo();"> <i class="bi bi-save text-light"></i> Save</button>
</div>		
	</form>

</div>


<%
render.renderFromBody()
%>