<!--#include virtual="/system.asp"-->
<!--#include virtual="/checkstep.asp"-->
<!--#include file="INC_CIA.inc"-->
<%
saveCurrentURL
render.renderToBody()
%>
<%
	
Dim description

call getRecordSet (SQL_CONSULTA_CIA(request.querystring("stepID")), rs)

if not rs.eof then																							
	CIAID=rs("CIAID")
	description=rs("description")
	if rs("tipo") = True then
		tipo = 1
	else
		tipo = 0
	end if
else
	CIAID=""
	description=""
	tipo=""
end if

%>
<div class="p-3">
	
	<form id="ciaAction" name="ciaAction" action="ciaActions.asp?action=save"  method=post class="requires-validation m-0" novalidate>

	<p>Analysis type refers to the use of <b>qualitative measurement</b> of impact (ex., Event1 <i>highly increases</i> the probability of Event2), or <b>quantitative measurement</b> of the impact (ex., Event1 <i>increases</i> the probability of Event2 by <i>85%</i>).</p>
	<p class="text-danger pb-4">Changing the Analysis type reverts the inserted impacts to the events default probabilities.</p>

	 <div class="mb-2">
		<label for="tipo" class="form-label">Analysis Type</label>
			<select class="form-control w-100" id="tipo" type="text" name="tipo" onchange="selectForm(this);" required> 
				<option value="0" <%if tipo = "0" then  response.write("selected")  end if%>>Quantitative</option>
				<option value="1" <%if tipo = "1" then  response.write("selected")  end if%>>Qualitative</option>
			</select>
																
	  </div>
	
		<input type="hidden" name="hidden_tipo" id="hidden_tipo"  value="<%=tipo%>" />
		<input type=hidden name="description" value="" />
		<input type="hidden" name="ciaID" value="<%=cstr(CIAID)%>" />
		<input type=hidden name="stepID" value="<%=request.querystring("stepID")%>" />

 <div class="modal-footer fixed-bottom pb-0 px-0 mx-0 bg-white">
 
 		<button class="btn btn-sm btn-secondary m-1" type="button" onclick="top.location.href = './index.asp?stepID=<%=request.querystring("stepID")%>';return false;">Cancel</button>
		<button class="btn btn-sm btn-danger m-1" onClick="verifica_tipo();"> <i class="bi bi-save text-light"></i> Save</button>
</div>		
	</form>

</div>
<script>
function verifica_tipo(){
	<%if not rs.eof then%>
	if(document.getElementById("tipo").value != document.getElementById("hidden_tipo").value){
		ok = confirm("Analysis type has been changed, this will set all probabilities to default. Do you want to procede?");
		if(ok == true)
		{
			document.getElementById("ciaAction").submit();
		}
	}
	else{
		document.getElementById("ciaAction").submit();
	}
	<%else%>
		document.getElementById("ciaAction").submit();
	<%end if%>
}
</script>



<%
render.renderFromBody()
%>