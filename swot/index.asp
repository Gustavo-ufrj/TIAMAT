<!--#include virtual="/system.asp"-->
<!--#include virtual="/checkstep.asp"-->
<!--#include file="INC_SWOT.inc"-->

<%
saveCurrentURL
									
call getRecordSet (SQL_CONSULTA_SWOT(request.querystring("stepID")), rs)

if rs.eof then																							
 response.redirect "editSWOT.asp?stepID="+request.querystring("stepID")
end if			

render.renderTitle()									
%>


<div class="p-3">

	<div class="row">
		<div class="w-50 border-bottom border-end p-3">
			<p class="text-center fs-5 fw-bold">Strengths</p>
			<pre><%=rs("strengths")%></pre>
		</div>
		<div class="w-50 border-bottom p-3">
			<p class="text-center fs-5 fw-bold">Weakness</p>
			<pre><%=rs("weakness")%></pre>
		</div>
	</div>
	<div class="row">
		<div class="w-50 border-end p-3">
			<p class="text-center fs-5 fw-bold">Opportunities</p>
			<pre><%=rs("opportunities")%></pre>
		</div>
		<div class="w-50 p-3">
			<p class="text-center fs-5 fw-bold">Threats</p>
			<pre><%=rs("threats")%></pre>
		</div>
	</div>
	
  <div class="p-3">
  </div>
  
  
  <nav class="navbar fixed-bottom navbar-light bg-light">
         <div class="container-fluid justify-content-center p-0">
		 
		 
	<%if getStatusStep(request.querystring("stepID")) = STATE_ACTIVE then %>
		<button class="btn btn-sm btn-secondary m-1" onclick="window.location.href='editSWOT.asp?stepID=<%=request.queryString("stepID")%>'">Edit</button>
		<button class="btn btn-sm btn-danger m-1" onclick="window.location.href='/stepsupportInformation.asp?stepID=<%=request.queryString("stepID")%>';"><i class="bi bi-journal-plus text-light"></i> Supporting Information</button>
		<button class="btn btn-sm btn-danger m-1" onclick="if(confirm('This action cannot be undone. Are you sure to end this FTA method now?'))window.location.href='/workflowActions.asp?action=end&stepID=<%=request.queryString("stepID")%>'"><i class="bi bi-check-lg text-light"></i> Finish</button>
	<%end if%>

	</div>
      </nav>									

	  </form>
</div>

<%
render.renderFooter()
%>