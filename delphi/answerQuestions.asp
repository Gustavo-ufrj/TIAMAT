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
Dim description

state = -1
mode = MODE_ANSWER
description = ""

If request.querystring("stepID") <> "" And request.querystring("roundID") <> "" Then
	roundID = request.querystring("roundID")
	stepID = request.querystring("stepID")
	
	role = getRole(stepID, Session("email"))

	If role <> "Participant" Then
		Session("delphiRoundsError") = "You are not a delphi participant."
		response.redirect "index.asp?stepID=" & stepID
	End If
	
	
	Call getRecordSet (SQL_CONSULTA_DELPHI(stepID), rs)
	if not rs.EOF then
	description = rs("text")
	end if
	
	
	Call getRecordSet (SQL_CONSULTA_DELPHI_ROUND(roundID), rs)
	
	state = Clng(rs("state"))
	
	If state <> STATE_PUB Then
		Session("delphiError") = "This delphi round has not been published yet or it has been ended. It is not possible to answer it."
		mode = MODE_VIEW
		response.redirect "index.asp?stepID=" & stepID & "&redirect=1"
	End If
End If

tiamat.addCSS("delphi.css")

render.renderTitle()
%>


<div class="p-3">
	
		<% If mode = MODE_ANSWER Then %>
			<form action="delphiActions.asp?action=save_answers" method="POST" class="requires-validation m-0" novalidate>
		<% End If %>
		<div class="p-3"><%=description%>
		</div>
		
	 	<div id="delphi-questions">
		<%
			If roundID <> "" Then
				Call printAllRoundParticipantAnswers(roundID, mode)
			End If
		%>
		</div>
		
	  
	  
	<div class="p-5">	</div>				  
	<input type=hidden name="stepID" value="<%=stepID%>" />
	<input type=hidden name="roundID" value="<%=roundID%>" />


  <nav class="navbar fixed-bottom navbar-light bg-light">
         <div class="container-fluid justify-content-center p-0"> 
 		
		
		<button class="btn btn-sm btn-secondary m-1" type="button" onclick="top.location.href = 'index.asp?stepID=<%=stepID%>&redirect=1';return false;">Back</button>
		<% If mode = MODE_ANSWER Then %>
		<button class="btn btn-sm btn-danger m-1" type="submit" onclick="validateForm();"> <i class="bi bi-save text-light"></i> Save</button>
		<% End If%>
		
		
		</div>
    </nav>	


	<% If mode = MODE_ANSWER Then%>
	</form>
	<% End If %>
	
		
</div>


<!-- Add/Edit Reference Modal -->
<div class="modal fade" id="showAnswersModal" tabindex="-1" aria-labelledby="showAnswersModal" aria-hidden="true">
  <div class="modal-dialog modal-dialog-centered modal-xl">
    <div class="modal-content">
      <div class="modal-header">
        <h5 class="modal-title" id="answersModal"></h5>
        <button type="button" class="btn-close" data-bs-dismiss="modal" aria-label="Close"></button>
      </div>
      <div class="modal-body p-0">
        <iframe id="iframeAnswers" src="" class="w-100" style="height:600px">
		</iframe>
      </div>
	  <div class="modal-footer">
        <button type="button" class="btn btn-secondary" data-bs-dismiss="modal" aria-label="Close">Close</button>
      </div>	  
     </div>
  </div>
</div>		
<script>

$('#showAnswersModal').on('show.bs.modal', function(e) {
	var title = $(e.relatedTarget).data('title');
	var url = $(e.relatedTarget).data('url');
	console.log(title);
	console.log(url);
    
	$('#answersModal').html(title);
	$('#iframeAnswers').attr('src',url);
	console.log("c");
});
</script>
<%
render.renderFooter()
%>