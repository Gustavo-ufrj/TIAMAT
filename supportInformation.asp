<!--#include virtual="/system.asp"-->
<!--#include virtual="/checklogin.asp"-->
<%

saveCurrentURL
render.renderTitle()

%>

<div class="p-3">

<%
	Dim rsWf
	Dim rs
	dim rsTemp
	
	Call getRecordSet(SQL_CONSULTA_WORKFLOW_ID(Request.querystring("workflowID")), rsWf)
	%>
	<%if not rsWf.eof then %>
	<div class="col-lg-12 col-md-12 col-sm-12 align-self-center">
		<h1 class="fs-3 fw-bolder text-dark text-uppercase">Supporting Information for <i><%=rsWf("description")%></i></h1>
		<hr>
	</div>
	<%end if%>
	
	
	<%if Session("message") <> "" then%>
	  <div class="alert alert-danger alert-dismissible" role="alert">
		<%=Session("message")%>
		 <button type="button" class="btn-close" data-bs-dismiss="alert" aria-label="Close"></button>
	  </div>		
	<%
	Session("message") = ""
	end if
	%>	  

<nav>
  <div class="nav nav-tabs" id="nav-tab" role="tablist">
    <button class="nav-link text-dark active" id="nav-home-tab" data-bs-toggle="tab" data-bs-target="#nav-workflow" type="button" role="tab" aria-controls="nav-workflow" aria-selected="true">Global (FTA Workflow)</button>
    <button class="nav-link text-dark " id="nav-profile-tab" data-bs-toggle="tab" data-bs-target="#nav-step" type="button" role="tab" aria-controls="nav-step" aria-selected="false">FTA Step</button>
  </div>
</nav>
<div class="tab-content" id="nav-tabContent">
  <div class="tab-pane fade show active" id="nav-workflow" role="tabpanel" aria-labelledby="nav-workflow">

  
  
  
<table class="table table-striped table-hover">
  <thead class="table-dark">
	<tr>
		<td>File Name</td>
		<td>Actions</td>
	</tr>
  </thead>
  <tbody>
 	<%
														
	call getRecordset(SQL_CONSULTA_WORKFLOW_SUPPORTING_INFORMATION(Request.queryString("workflowID")),rs)

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
				<a class="link-dark text-decoration-none" href="workflowActions.asp?action=deleteSI&workflowID=<%=cstr(rs("workflowID"))%>&file=<%=rs("filepath")%>" title="Delete"><img src="/img/delete.png" height=20 width=auto></a>
			<%end if%>
		</td>
	 </tr>
	<%
	rs.movenext
	wend
	%>
	  </tbody>
	</table>

  
  
  
  </div>
  <div class="tab-pane fade" id="nav-step" role="tabpanel" aria-labelledby="nav-step">



 
  
<table class="table table-striped table-hover">
  <thead class="table-dark">
	<tr>
		<td>FTA Method</td>
		<td>File Name</td>
		<td>Actions</td>
	</tr>
  </thead>
  <tbody>
 	<%
													
	call getRecordset(SQL_CONSULTA_WORKFLOW_STEPS(Request.queryString("workflowID")),rsTemp)
											
	if not rsTemp.eof then
		while not rsTemp.eof
													
			call getRecordset(SQL_CONSULTA_WORKFLOW_STEP_SUPPORTING_INFORMATION(cstr(rsTemp("stepID"))),rs)
			
			if rs.eof then
				response.write "No FTA supporting information uploaded."
				
			end if 

			
			if rs("type") = 0 then
				call getRecordset(SQL_CONSULTA_SUB_WORKFLOW_SUPPORTING_INFORMATION(cstr(rsTemp("stepID"))),rs2)
				
				while not rs2.eof
	
	
	%>
	<tr>
		<td>
			<span class="text-dark"><%=getFTAMethodNamebyFTAmethodID(cstr(rs("type")))%></span>
		</td>
		<td>
			<%if rs2("filepath") <> "" then%>
				<a class="link-dark text-decoration-none" href="/upload/download.asp?FilePath=<%=rs2("filepath")%>"><%=getFileName(rs2("filepath"))%></a>
			<%else%>
				<span class="text-danger">No Supporting Information</span>
			<%end if%>
		</td>
		<td>
			<a class="link-dark text-decoration-none" href="?workflowID=<%=rs2("workflowID")%>" title="Go to FTA Subworkflow"><img src="/img/go.png" height=20 width=auto></a>
			<%if rs2("filepath") <> "" then%>
				<a class="link-dark text-decoration-none" href="workflowActions.asp?action=deleteSI&workflowID=<%=cstr(rs2("workflowID"))%>&file=<%=rs2("filepath")%>" title="Delete"><img src="/img/delete.png" height=20 width=auto></a>
			<%end if%>
			
		</td>
	 </tr>
	<%
	rs2.movenext
	wend

	
	else
		
			while not rs.eof
			
			 base_folder = getBaseFolderByFTAmethodID(cstr(rs("type")))
			 
			%>
			
	<tr>
		<td>
			<span class="text-dark"><%=getFTAMethodNamebyFTAmethodID(cstr(rs("type")))%></span>
		</td>
		<td>
			<%if rs("filepath") <> "" then%>
				<a class="link-dark text-decoration-none" href="/upload/download.asp?FilePath=<%=rs("filepath")%>"><%=getFileName(rs("filepath"))%></a>
			<%else%>
				<span class="text-danger">No Supporting Information</span>
			<%end if%>
		</td>
		<td>
			<a class="link-dark text-decoration-none" href="<%=base_folder%>index.asp?stepID=<%=cstr(rs("stepID"))%>" title="Go to FTA Step"><img src="/img/go.png" height=20 width=auto></a>
			<%if rs("filepath") <> "" then%>
					<a class="link-dark text-decoration-none" href="stepActions.asp?action=deleteSI&stepID=<%=cstr(rs("stepID"))%>&file=<%=rs("filepath")%>" title="Delete"><img src="/img/delete.png"  height=20 width=auto></a>
			<%end if%>
		</td>
	 </tr>	
			
			<%
			rs.movenext
			wend
		end if
		rsTemp.movenext
	wend
	%>
	  </tbody>
	</table>

  	<%
	end if
	%>

  </div>
  
</div>  

	<div class="p-3">
    </div>
    <nav class="navbar fixed-bottom navbar-light bg-light">
         <div class="container-fluid justify-content-center p-0">
			 <button class="btn btn-sm btn-danger m-1 text-center" type="button" data-bs-toggle="modal" data-bs-target="#uploadModal" data-url="/upload/upform.asp?numfiles=5&workflowID=<%=Request.QueryString("workflowID")%>&resize=0&url=<%=getcurrentURL()%>"> <i class="bi bi-file-earmark-plus text-light"></i> Add Files</button>
         </div>
     </nav>	

</div>


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
 <!-- <div class="modal-footer">
        <button type="button" class="btn btn-secondary" data-bs-dismiss="modal">Close</button>
        <button type="button" class="btn btn-primary">Save changes</button>
      </div> -->
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