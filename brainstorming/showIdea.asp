<!--#include virtual="/system.asp"-->
<!--#include virtual="/checkstep.asp"-->
<!--#include file="INC_BRAINSTORMING.inc"-->
<%
saveCurrentURL

render.renderTitle()
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
	
<table class="table border w-100 p-0 d-flex">
	<tbody class="w-100">
	<tr class="w-100">
		<td class="text-center flex-shrink-1 p-0">
			<img src="<%=getPhoto(rs("email"))%>" class="rounded-circle align-middle" style="width:192px;height:auto;">	
			<span class="fs-6"><%=getName(rs("email"))%></span>
		</td>
		<td class="w-100 p-0">														
			<table class="table w-100 p-2">
				<tr>
					<td class="fw-bolder"> 			
					<%=title%>
					</td>
					<td class="fw-bolder text-end">			
					<%=getTimeStamp(rs("dateTime"))%>
					</td>
				</tr>
				<tr>
					<td class="border-0" colspan=2>			
					<%=Description%>
					</td>
				</tr>
			</table>																
		</td>
	</tr>
	</tbody>
</table>
	

<div id="all-comments">
</div>

	
	
  
   <div class="p-5">
  </div>
  <nav class="navbar fixed-bottom navbar-light bg-light">
      <div class="container-fluid justify-content-center p-0">
		 
				<button class="btn btn-sm btn-secondary m-1" type="button" onClick="top.location.href='index.asp?stepID=<%=request.queryString("stepID")%>'"> Back</button>
			<%if getStatusStep(request.querystring("stepID")) = STATE_ACTIVE then %>
				<%if rs("email") = Session("email") then %>
				<button class="btn btn-sm btn-secondary m-1" type="button" data-bs-toggle="modal" data-bs-target="#manageIdeaModal" data-step-id="<%=request.querystring("stepID")%>" data-title="Edit Idea" data-url="manageIdea.asp?stepID=<%=request.queryString("stepID")%>&brainstormingID=<%=rs("brainstormingID")%>&ideaID=<%=rs("ideaID")%>"> Edit Idea</button>
				<%end if%>					
				<button class="btn btn-sm btn-secondary m-1" type="button" data-bs-toggle="modal" data-bs-target="#manageIdeaModal" data-step-id="<%=request.querystring("stepID")%>" data-title="Add Comment" data-url="manageComment.asp?stepID=<%=request.queryString("stepID")%>&brainstormingID=<%=rs("brainstormingID")%>&ideaID=<%=rs("ideaID")%>"> <i class="bi bi-plus-square text-light"></i> Add Comment</button>
			<%end if%>					

			
      </div>
  </nav>		
	
</div>



<!-- Add/Edit Reference Modal -->
<div class="modal fade" id="manageIdeaModal" tabindex="-1" aria-labelledby="manageIdeaModal" aria-hidden="true">
  <div class="modal-dialog modal-dialog-centered modal-xl">
    <div class="modal-content">
      <div class="modal-header">
        <h5 class="modal-title" id="ideaModal"></h5>
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
$('#manageIdeaModal').on('show.bs.modal', function(e) {
	var title = $(e.relatedTarget).data('title');
	var url = $(e.relatedTarget).data('url');
    
	$('#ideaModal').html(title);
	$('#iframeReference').attr('src',url);
});
</script>


<script>
	
	$(document).ready(function() {
		console.log("aaa");
		fetch('commentActions.asp?action=get&stepID=<%=request.querystring("stepID")%>&ideaID=<%=request.querystring("ideaID")%>').then(response=>response.text()).then(data => {
			console.log(data);
			document.getElementById('all-comments').innerHTML = (data);
		} );
		
	});
	
</script>
	

<%
render.renderFooter()
%>
