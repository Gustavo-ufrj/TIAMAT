<!--#include virtual="/system.asp"-->
<% 
if Session("email") = "" then
	response.redirect ("/login.asp")
end if 

dim numFiles, isIMG, i, urlback

urlback = Request.QueryString("url")
numFiles = Request.QueryString("numFiles")
img = Request.QueryString("resize")

if (not numFiles>0) or img = 1 then
numFiles = 1
end if

render.renderToBody()

%>
											<!-- INICIO AREA EDITAVEL -->
							

 
<form action="upload.asp?workflowID=<%=Request.QueryString("workflowID")%>&stepID=<%=Request.QueryString("stepID")%>&resize=<%=img%>&url=<%=urlback%>&parent=true" method="post" enctype="multipart/form-data">
 <div class="container py-2" >
				<%for i=1 to numFiles%>
				  <div class="mb-3">
					<label for="file<%=i%>" class="form-label">Select File</label>
					<input type="file" class="form-control" id="file<%=i%>" name="txtArquivo<%=i%>">
				  </div>
				<%next%>

				
	  <nav class="navbar fixed-bottom navbar-light">
         <div class="container-fluid justify-content-end">
            <button class="btn btn-sm btn-danger m-1" type="submit" name="upload" value="Upload"> <i class="bi bi-save text-light"></i> Save</button>
         </div>
      </nav>
	  
	  
				
 </div>
</form>
												
