<!--#include virtual="/system.asp"-->
<!--#include virtual="/checkstep.asp"-->
<!--#include file="INC_DELPHI.inc"-->

<%
saveCurrentURL

Dim rs
Dim stepID
Dim roundID
Dim state
Dim role

state = -1
mode = MODE_EDIT

If request.querystring("stepID") <> "" And request.querystring("roundID") <> "" Then
	roundID = request.querystring("roundID")
	stepID = request.querystring("stepID")
	
	role = getRole(stepID, Session("email"))

	If role <> "Coordinator" Then
		Session("message") = "You are not a Delphi coordinator."
		response.redirect "index.asp?stepID=" & stepID & "&redirect=1"
	End If
	
	Call getRecordSet (SQL_CONSULTA_DELPHI_ROUND(roundID), rs)
	
	state = Clng(rs("state"))
	
	If state <> STATE_UNP Then
		Session("message") = "This Delphi round has been published or ended. It is not possible to edit it anymore."
		response.redirect "index.asp?stepID=" & stepID
	End If
End If


tiamat.addCSS("delphi.css")

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

	

	Call getRecordSet(SQL_CONSULTA_DELPHI_ROUND_QUESTIONS_ONLY(roundID), rs)
	
	if rs.eof then
		response.write "<div class='py-3'><div class='alert alert-danger'> No Delphi question was found in this Round.</div></div>"
	else
%>
<table class="table table-striped table-hover">
  <thead class="table-dark">
	<tr>
		<td class="text-center" style="min-width:60px;">Order</td>
		<td class="w-100">Question</td>
		<td class="text-center" style="min-width:120px;">Type</td>
		<td class="text-center" style="min-width:90px;">Actions</td>
	</tr>
  </thead>
  <tbody>

<%
			while not rs.eof
			%>
			<tr>
				<td>														
					<a href="delphiActions.asp?action=move_up&stepID=<%=request.querystring("stepID")%>&roundID=<%=request.querystring("roundID")%>&questionID=<%=rs("questionID")%>" title="Move Up"><img src="img/seta_cima.png" height=20 width=auto></a>
					<a href="delphiActions.asp?action=move_down&stepID=<%=request.querystring("stepID")%>&roundID=<%=request.querystring("roundID")%>&questionID=<%=rs("questionID")%>" title="Move Up"><img src="img/seta_baixo.png" height=20 width=auto></a>
				</td>		
				<td>														
					<%=(rs("question"))%>
				</td>			
				
				<td class="text-center">
					<% if cint(rs("options")) > 0 then %>
						Close-ended
					<%	Else %>
						Open-ended
					<%	end if	%>
				</td>

				<td class="text-center">
				
					<%	if state = 0 then%>
						<a href="" title="Edit" data-bs-toggle="modal" data-bs-target="#manageQuestionModal" data-step-id="<%=request.querystring("stepID")%>" data-title="Edit Question" data-url="editQuestion.asp?stepID=<%=request.queryString("stepID")%>&roundID=<%=request.querystring("roundID")%>&questionID=<%=rs("questionID")%>" data-title="Edit Question" data-url="delphiActions.asp?action=update_question"><img src="/img/edit.png"  height=20 width=auto></a>
						<a href="delphiActions.asp?action=delete_question&stepID=<%=request.querystring("stepID")%>&roundID=<%=request.querystring("roundID")%>&questionID=<%=rs("questionID")%>" title="Delete"  onclick="if (!confirm('Are you sure?')) { return false; }"><img src="/img/delete.png"  height=20 width=auto></a>
					<%	end if	%>
					
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
				 
		 
		 
	<%if getStatusStep(request.querystring("stepID")) = STATE_ACTIVE then %>
		<button class="btn btn-sm btn-secondary m-1" onclick="window.location.href='index.asp?stepID=<%=request.queryString("stepID")%>'">Back</button>
		<% If role = "Coordinator" Then %>
			<button class="btn btn-sm btn-secondary m-1" type="button" data-bs-toggle="modal" data-bs-target="#manageQuestionModal" data-step-id="<%=request.querystring("stepID")%>" data-title="Add Question" data-url="editQuestion.asp?stepID=<%=request.queryString("stepID")%>&roundID=<%=request.querystring("roundID")%>"> <i class="bi bi-plus-square text-light"></i> Add Question</button>
		<% 	End If 	%>
	<%end if%>

		</div>
    </nav>			
	  
	  

</div>




<!-- Add/Edit Reference Modal -->
<div class="modal fade" id="manageQuestionModal" tabindex="-1" aria-labelledby="manageQuestionModal" aria-hidden="true">
  <div class="modal-dialog modal-dialog-centered modal-xl">
    <div class="modal-content">
      <div class="modal-header">
        <h5 class="modal-title" id="questionModal"></h5>
        <button type="button" class="btn-close" data-bs-dismiss="modal" aria-label="Close"></button>
      </div>
      <div class="modal-body p-0">
        <iframe id="iframeQuestion" src="" class="w-100" style="height:600px">
		</iframe>
      </div>
     </div>
  </div>
</div>		
<script>

$('#manageQuestionModal').on('show.bs.modal', function(e) {
	var title = $(e.relatedTarget).data('title');
	var url = $(e.relatedTarget).data('url');
    
	$('#questionModal').html(title);
	$('#iframeQuestion').attr('src',url);
});
</script>


<%
render.renderFooter()
%>
