<!--#include virtual="/system.asp"-->
<!--#include virtual="/checkstep.asp"-->
<!--#include file="INC_BRAINSTORMING.inc"-->
<%
'saveCurrentURL


render.renderToBody()
%>

<%
Dim title,description,author, email
	title=""
	description=""
	author=""
	email=Session("email")
	

if (not isempty(request.querystring("stepID")) ) and (not isempty(request.querystring("ideaID"))) then

	call getRecordSet (SQL_CONSULTA_BRAINSTORMING_IDEA(request.querystring("ideaID")), rs)
	
	if not rs.eof then																							
		title=rs("title")
		description=rs("description") 
		author=getName(rs("email"))
		email=rs("email")
	end if
end if
%>

<div class="p-3">
	
	<form action="ideaActions.asp?action=save" method="POST" class="requires-validation m-0" novalidate>


	   <div class="mb-2">
		<label for="title" class="form-label">Title</label>
		<input type="text" class="form-control" id="bib_title" name="title" maxlength="500" value="<%=title%>" required> 
		<div class="invalid-feedback">Title cannot be blank!</div>
	  </div>
	  
	
	   <div class="mb-2">
		<label for="description" class="form-label">Description</label>
		<textarea class="form-control" type="text" id="description" name="description" maxlength="8000" style="height:200px;"><%=description%></textarea>
	  </div>
	
	  
		<input type=hidden name="brainstormingID" value="<%=request.querystring("brainstormingID")%>" />
		<input type=hidden name="ideaID" value="<%=request.querystring("ideaID")%>" />
		<input type=hidden name="stepID" value="<%=request.querystring("stepID")%>" />

 <div class="modal-footer fixed-bottom pb-0 px-0 mx-0 bg-white">
 
 		<button class="btn btn-sm btn-secondary m-1" type="button" onclick="top.location.href = './index.asp?stepID=<%=request.querystring("stepID")%>';return false;">Cancel</button>
		<button class="btn btn-sm btn-danger m-1" type="submit"> <i class="bi bi-save text-light"></i> Save</button>
</div>		
	</form>

</div>

<%
render.renderFromBody()
%>
