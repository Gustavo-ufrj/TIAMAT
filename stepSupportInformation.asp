<!--#include virtual="/system.asp"-->
<!--#include virtual="/checklogin.asp"-->
<%
saveCurrentURL
render.renderTitle()
%>


<div class="p-3">

<%if Session("message") <> "" then%>
	  <div class="alert alert-danger alert-dismissible" role="alert">
		<%=Session("message")%>
		 <button type="button" class="btn-close" data-bs-dismiss="alert" aria-label="Close"></button>
	  </div>		
	<%
	Session("message") = ""
	end if
	%>	  

	
	
  

 	<%
														
	call getRecordset(SQL_CONSULTA_WORKFLOW_STEP_SUPPORTING_INFORMATION(Request.queryString("stepID")),rs)
												
	
	if rs.eof then
	%>
	
	  <div class="alert alert-danger alert-dismissible" role="alert">		
		 No FTA supporting information uploaded.
	  </div>	
	
	<%
	else
	%>
<table class="table table-striped table-hover">
  <thead class="table-dark">
	<tr>
		<td>File Name</td>
		<td>Actions</td>
	</tr>
  </thead>
  <tbody>

	<%


		if rs("type") = 0 then
			call getRecordset(SQL_CONSULTA_SUB_WORKFLOW_SUPPORTING_INFORMATION(cstr(rs("stepID"))),rs2)
			
			while not rs2.eof %>
		<tr>
			<td>
				<%if rs2("filepath") <> "" then%>
					<a class="link-dark text-decoration-none" href="/upload/download.asp?FilePath=<%=rs2("filepath")%>"><%=getFileName(rs2("filepath"))%></a>
				<%else%>
					<span class="text-danger">No Supporting Information</span>
				<%end if%>
			</td>
			<td>
				<a href="?workflowID=<%=rs2("workflowID")%>" title="Go to FTA Subworkflow"><img src="/img/go.png" height=20 width=auto"></a>

				<%if rs2("filepath") <> "" then%>
					<a class="link-dark text-decoration-none" href="workflowActions.asp?action=deleteSI&workflowID=<%=cstr(rs2("workflowID"))%>&file=<%=rs2("filepath")%>" title="Delete"><img src="/img/delete.png" height=20 width=auto></a>
				<%end if%>
				
			</td>
		 </tr>


		<%
			rs2.movenext
			Wend
		else
			while not rs.eof
	%>
		<tr>
			<td>
				<%if rs("filepath") <> "" then%>
					<a class="link-dark text-decoration-none" href="/upload/download.asp?FilePath=<%=rs("filepath")%>"><%=getFileName(rs("filepath"))%></a>
				<%else%>
					<span class="text-danger">No Supporting Information</span>
				<%end if%>
			</td>
			<td>

				<%if rs("filepath") <> "" then%>
					<a class="link-dark text-decoration-none" href="stepActions.asp?action=deleteSI&stepID=<%=cstr(rs("stepID"))%>&file=<%=Replace(rs("filepath"),"'","''")%>" title="Delete"><img src="/img/delete.png" height=20 width=auto></a>
				<%end if%>
				
			</td>
		 </tr>
		<%
			rs.movenext
			wend
		end if
	end if
	%>
	  </tbody>
	</table>

	
<div class="p-3">
    </div>
    <nav class="navbar fixed-bottom navbar-light bg-light">
         <div class="container-fluid justify-content-center p-0">
		<%
															
		call getRecordset(SQL_CONSULTA_WORKFLOW_STEP_SUPPORTING_INFORMATION(Request.queryString("stepID")),rs)
													
		
		if not rs.eof then
			base_folder = getBaseFolderByFTAmethodID(cstr(rs("type")))
		
		%>
			  <button class="btn btn-sm btn-secondary m-1 text-center" type="button" onclick="top.location.href='<%=base_folder%>index.asp?stepID=<%=cstr(rs("stepID"))%>';">Back</button>
		<%end if%>	 
			 <button class="btn btn-sm btn-danger m-1 text-center" type="button" data-bs-toggle="modal" data-bs-target="#uploadModal" data-url="/upload/upform.asp?numfiles=5&workflowID=<%=Request.QueryString("workflowID")%>&stepID=<%=Request.QueryString("stepID")%>&resize=0&url=<%=getcurrentURL()%>"> <i class="bi bi-file-earmark-plus text-light"></i> Add Files</button>

         </div>
     </nav>	
	 
	
<!-- Modal -->
<div class="modal fade" id="uploadModal" tabindex="-1" aria-labelledby="uploadModalLabel" aria-hidden="true">
  <div class="modal-dialog modal-dialog-centered">
    <div class="modal-content">
      <div class="modal-header">
        <h5 class="modal-title" id="uploadModalLabel">Add Support Information</h5>
        <button type="button" class="btn-close" data-bs-dismiss="modal" aria-label="Close"></button>
      </div>
      <div class="modal-body">
        <iframe id="iframeUpload" src="" class="w-100" style="height:500px">
		</iframe>
      </div>
     </div>
  </div>
</div>		

<script>
$('#uploadModal').on('show.bs.modal', function(e) {
	var url = $(e.relatedTarget).data('url');
    console.log(url);
	$('#iframeUpload').attr('src',url);
});
</script>

<%
render.renderFooter()
%>