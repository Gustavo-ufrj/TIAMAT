<!--#include virtual="/system.asp"-->
<!--#include virtual="/checkstep.asp"-->
<!--#include file="INC_SWOT.inc"-->
<%
saveCurrentURL
render.renderTitle()
%>


<%
	
Dim strengths,weakness,opportunities,threats

call getRecordSet (SQL_CONSULTA_SWOT(request.querystring("stepID")), rs)

if not rs.eof then																							
strengths=rs("strengths")
weakness=rs("weakness")
opportunities=rs("opportunities")
threats=rs("threats")
else
strengths=""
weakness=""
opportunities=""
threats=""
end if

%>

<div class="p-3">

	<form action="swotActions.asp?action=save" method="POST" class="requires-validation m-0" novalidate>

	<div class="row">
		<div class="w-50 border-bottom border-end text-end p-3">
			<p class="text-center fs-5 fw-bold">Strengths</p>
			<textarea name="strengths" class="w-100" style="height:200px;"><%=strengths%></textarea>
		</div>
		<div class="w-50 border-bottom p-3">
			<p class="text-center fs-5 fw-bold">Weakness</p>
			<textarea name="weakness" class="w-100" style="height:200px;"><%=weakness%></textarea>
		</div>
	</div>
	<div class="row">
		<div class="w-50 border-end text-end p-3">
			<p class="text-center fs-5 fw-bold">Opportunities</p>
			<textarea name="opportunities" class="w-100" style="height:200px;"><%=opportunities%></textarea>
		</div>
		<div class="w-50 p-3">
			<p class="text-center fs-5 fw-bold">Threats</p>
			<textarea name="threats" class="w-100" style="height:200px;"><%=threats%></textarea>
		</div>
	</div>
	
	
	<input type=hidden name="stepID" value="<%=request.querystring("stepID")%>" />
	
	
  <div class="p-3">
  </div>
  
  
  <nav class="navbar fixed-bottom navbar-light bg-light">
         <div class="container-fluid justify-content-center p-0">
		 
		
    <%if getStatusStep(request.querystring("stepID")) = STATE_ACTIVE then %>
			<button type="submit" class="btn btn-sm btn-danger m-1 text-center" ><i class="bi bi-save text-light"></i> Save</button>
	<%end if%>
		 	
         </div>
      </nav>									

	  </form>
</div>


		
<%
render.renderFooter()
%>