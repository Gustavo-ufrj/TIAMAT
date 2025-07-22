<!--#include virtual="/system.asp"-->
<!--#include virtual="/checkstep.asp"-->
<!--#include file="INC_BRAINSTORMING.inc"-->
<%
'saveCurrentURL


render.renderToBody()
%>

<%
Dim title,comment,author, email
	title=""
	comment=""
	author=""
	email=Session("email")
	
if (not isempty(request.querystring("stepID")) ) and (not isempty(request.querystring("ideaID"))) and (not isempty(request.querystring("commentID"))) then


	call getRecordSet (SQL_CONSULTA_BRAINSTORMING_DISCUSSION_COMMENT_ID(request.querystring("commentID")), rs)

	if not rs.eof then																							
		title=rs("title")
		comment=rs("message") 
		author=getName(rs("email"))
		email=rs("email")
	end if
end if
%>

<div class="p-3">
	
	<form action="commentActions.asp?action=save" method="POST" class="requires-validation m-0" novalidate>


	   <div class="mb-2">
		<label for="title" class="form-label">Title</label>
		<input type="text" class="form-control" id="bib_title" name="title" maxlength="500" value="<%=title%>" required> 
		<div class="invalid-feedback">Title cannot be blank!</div>
	  </div>
	  
	
	   <div class="mb-2">
		<label for="comment" class="form-label">Comment</label>
		<textarea class="form-control" type="text" id="comment" name="comment" maxlength="8000" style="height:200px;"><%=comment%></textarea>
	  </div>
	
	  
		<input type=hidden name="commentID" value="<%=request.querystring("commentID")%>" />
		<input type=hidden name="ideaID" value="<%=request.querystring("ideaID")%>" />
		<input type=hidden name="stepID" value="<%=request.querystring("stepID")%>" />

 <div class="modal-footer fixed-bottom pb-0 px-0 mx-0 bg-white">
 
 		<button class="btn btn-sm btn-secondary m-1" type="button" onclick="top.location.href = './showIdea.asp?stepID=<%=request.querystring("stepID")%>&ideaID=<%=request.querystring("ideaID")%>';return false;">Cancel</button>
		<button class="btn btn-sm btn-danger m-1" type="submit"> <i class="bi bi-save text-light"></i> Save</button>
</div>		
	</form>

</div>

<%
render.renderFromBody()
%>
