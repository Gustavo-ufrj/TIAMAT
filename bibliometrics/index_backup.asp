<!--#include virtual="/system.asp"-->
<!--#include virtual="/checkstep.asp"-->
<!--#include file="INC_BIBLIOMETRICS.inc"-->

<%
saveCurrentURL
render.renderTitle()

		dim rs
		dim rsAuthor
		dim rsTag
		Dim counter
		dim filter
		
		filter = "0"
		if not isempty(request.querystring("filter")) then filter = request.querystring("filter")
			
		if cint(filter) > 0 then
			call getRecordset(SQL_CONSULTA_BIBLIOMETRICS_FILTER(request.querystring("stepID"), filter),rs)
		else
			call getRecordset(SQL_CONSULTA_BIBLIOMETRICS(request.querystring("stepID")),rs)
		end if

%>


<div class="p-3">

<%

	if rs.eof then
		response.write "<div class='py-3'><div class='alert alert-danger'> No reference was found.</div></div>"
	else
%>
<table class="table table-striped table-hover">
  <thead class="table-dark">
	<tr>
		<td>User</td>
		<td>Year</td>
		<td>Authors</td>
		<td>Title</td>
		<td>Actions</td>
	</tr>
  </thead>
  <tbody>

<%
			while not rs.eof
			 pdf_link = "#"
			 if rs("file_path") <> "" then
				pdf_link = rs("file_path")
			 end if

			
			%>
			<tr>
				<td class="p-1">														
				<img src="<%=getPhoto(rs("email"))%>" class="rounded-circle align-middle" title="<%=getName(rs("email"))%>" style="height:24px;width:auto;">						
				</td>												
				
				<td class="p-1">														
					<a class="link-dark text-decoration-none"  href="<%=pdf_link%>"><%=(rs("year"))%></a> 
				</td>
				<td class="p-1">														
					<a class="link-dark text-decoration-none"  href="<%=pdf_link%>"> 
				<%
				
					
					call getRecordset(SQL_CONSULTA_BIBLIOMETRICS_AUTHORS(cstr(rs("referenceID"))),rsAuthor)

					if rsAuthor.RecordCount > 2 then
						response.write ucase(strLeft(rsAuthor("name"),",")) & " et al."
					else
						while not rsAuthor.eof
							response.write ucase(strLeft(rsAuthor("name"),","))
							rsAuthor.movenext
							if not rsAuthor.eof then
								response.write "; "
							end if
						wend
					end if
					
				
				%>
				</a> 
				</td>
				<td class="p-1">														
					<a class="link-dark text-decoration-none"  href="<%=pdf_link%>"><%=(rs("title"))%></a> 
				</td>
				<td class="p-1">														
				 <div class="container p-0 m-0">
					<div class="row">
					<% if rs("file_path") <> "" then %>
					<div class="col-3  p-1 m-0"><a href="<%=rs("file_path")%>" title="Open"><img src="/img/pdf_icon.png" height=20 width=auto></a></div>
					<%end if%>
					
					<%if getStatusStep(request.querystring("stepID")) = STATE_ACTIVE then %>

					<div class="col-3  p-1 m-0"><a href="#" title="Edit" data-bs-toggle="modal" data-bs-target="#manageReferenceModal" data-step-id="<%=request.querystring("stepID")%>" data-filter="<%=request.querystring("filter")%>" data-title="Edit Reference" data-url="editReference.asp?stepID=<%=cstr(rs("stepID"))%>&referenceID=<%=cstr(rs("referenceID"))%>"><img src="/img/edit.png" height=20 width=auto></a></div>
						
					<div class="col-3 p-1 m-0"><a href="referenceActions.asp?action=delete&stepID=<%=cstr(rs("stepID"))%>&referenceID=<%=cstr(rs("referenceID"))%>" title="Delete"  onclick="if (!confirm('Are you sure?')) { return false; }"><img src="/img/delete.png" height=20 width=auto></a></div>
					<%end if%>
					</div>				
				 </div>									
				</td>
				
			</tr>
			<%
			rs.movenext
			wend
			%>
										
  </tbody>
</table>
<%
end if
%>										
												
  <div class="p-3">
  </div>
  <nav class="navbar fixed-bottom navbar-light bg-light">
         <div class="container-fluid justify-content-center p-0">
		 
		 
			<!--<label for="filter" class="form-label mt-2">Filter</label>-->
			<select id="filter" class="form-control-sm mx-2" onChange="filterData(this.value);">
				<option value="0">All subjects</option>
				<%

				call getRecordset(SQL_CONSULTA_BIBLIOMETRICS_TAGS_LIST_PER_STEP_ID(request.querystring("stepID")),rsTag)

				while not rsTag.eof
				if filter = cstr(rsTag("tagID")) then
					response.write "<option selected value='"+cstr(rsTag("tagID"))+"'>"+rsTag("tag")+"</option>"
				else
					response.write "<option value='"+cstr(rsTag("tagID"))+"'>"+rsTag("tag")+"</option>"
				end if
				rsTag.movenext
				wend
				%>
			</select>
		  <div class="p-0 m-0">
		  </div>
		
		<button class="btn btn-sm btn-secondary m-1" onclick="window.location.href='referenceActions.asp?action=export&stepID=<%=request.queryString("stepID")%>';"><i class="bi bi-export text-light"></i> Export Data</button>
    <%if getStatusStep(request.querystring("stepID")) = STATE_ACTIVE then %>
		<button class="btn btn-sm btn-secondary m-1" type="button" data-bs-toggle="modal" data-bs-target="#manageReferenceModal" data-step-id="<%=request.querystring("stepID")%>" data-filter="<%=request.querystring("filter")%>" data-title="Add Reference" data-url="editReference.asp?stepID=<%=request.queryString("stepID")%>"  > <i class="bi bi-plus-square text-light"></i> Add Reference</button>
		<button class="btn btn-sm btn-danger m-1" onclick="window.location.href='/stepsupportInformation.asp?stepID=<%=request.queryString("stepID")%>';"><i class="bi bi-journal-plus text-light"></i> Supporting Information</button>
		<button class="btn btn-sm btn-danger m-1" onclick="if(confirm('This action cannot be undone. Are you sure to end this FTA method now?'))window.location.href='/workflowActions.asp?action=end&stepID=<%=request.queryString("stepID")%>'"><i class="bi bi-check-lg text-light"></i> Finish</button>
	<%end if%>
		 
		 
		 
        	
			
			
         </div>
      </nav>									

</div>
	
	<script>
	
	function filterData(newValue){
		if (newValue > 0) {
			window.location.href = './index.asp?stepID=<%=request.querystring("stepID")%>&filter='+newValue;
		}
		else {
			window.location.href = './index.asp?stepID=<%=request.querystring("stepID")%>';
		}
	}
	</script>
	
<!-- Add/Edit Reference Modal -->
<div class="modal fade" id="manageReferenceModal" tabindex="-1" aria-labelledby="manageReferenceModal" aria-hidden="true">
  <div class="modal-dialog modal-dialog-centered modal-xl">
    <div class="modal-content">
      <div class="modal-header">
        <h5 class="modal-title" id="referenceModal"></h5>
        <button type="button" class="btn-close" data-bs-dismiss="modal" aria-label="Close"></button>
      </div>
      <div class="modal-body p-0">
        <iframe id="iframeReference" src="" class="w-100" style="height:600px">
		</iframe>
      </div>
     </div>
  </div>
</div>		
<script>

$('#manageReferenceModal').on('show.bs.modal', function(e) {
	var title = $(e.relatedTarget).data('title');
	var url = $(e.relatedTarget).data('url');
    
	$('#referenceModal').html(title);
	$('#iframeReference').attr('src',url);
});
</script>


<%
render.renderFooter()
%>
