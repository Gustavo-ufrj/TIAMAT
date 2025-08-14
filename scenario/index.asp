<!--#include virtual="/system.asp"-->
<!--#include virtual="/checkstep.asp"-->
<!--#include file="INC_SCENARIO.inc"-->

<%
saveCurrentURL
render.renderTitle()

' Função auxiliar para contar palavras (CORRIGIDA)
Function CountWords(text)
    On Error Resume Next
    
    If IsNull(text) Or text = "" Then
        CountWords = 0
        Exit Function
    End If
    
    ' Remove HTML tags básico
    Dim cleanText
    cleanText = CStr(text)
    cleanText = Replace(cleanText, "<", " ")
    cleanText = Replace(cleanText, ">", " ")
    cleanText = Replace(cleanText, vbCrLf, " ")
    cleanText = Replace(cleanText, vbLf, " ")
    cleanText = Replace(cleanText, "  ", " ")
    
    cleanText = Trim(cleanText)
    If cleanText = "" Then
        CountWords = 0
    Else
        CountWords = UBound(Split(cleanText, " ")) + 1
    End If
    
    On Error Goto 0
End Function

' Processar ações
Dim action, stepID
action = Request.QueryString("action")
stepID = Request.QueryString("stepID")

If action = "finalize_scenarios" And stepID <> "" Then
    On Error Resume Next
    Call ExecuteSQL("UPDATE tiamat_steps SET status = 4 WHERE stepID = " & stepID)
    Response.Redirect("/workplace.asp")
    Response.End
End If

%>

<div class="p-3">

<%
' Mostrar mensagens de sucesso/erro
If Session("successMessage") <> "" Then
    Response.Write "<div class='alert alert-success alert-dismissible fade show' role='alert'>"
    Response.Write Session("successMessage")
    Response.Write "<button type='button' class='btn-close' data-bs-dismiss='alert'></button>"
    Response.Write "</div>"
    Session("successMessage") = ""
End If

If Session("errorMessage") <> "" Then
    Response.Write "<div class='alert alert-danger alert-dismissible fade show' role='alert'>"
    Response.Write Session("errorMessage")
    Response.Write "<button type='button' class='btn-close' data-bs-dismiss='alert'></button>"
    Response.Write "</div>"
    Session("errorMessage") = ""
End If

' Consultar cenários
On Error Resume Next

dim rs
Dim counter

' Validar stepID antes de usar na query
If Not IsEmpty(request.querystring("stepID")) And IsNumeric(request.querystring("stepID")) Then
    call getRecordset(SQL_CONSULTA_SCENARIOS(request.querystring("stepID")), rs)
    
    ' Verificar se houve erro na consulta SQL
    If Err.Number <> 0 Then
        Response.Write "<div class='alert alert-danger'>Database error: " & Err.Description & "</div>"
        Err.Clear
        Set rs = Nothing
    End If
Else
    Set rs = Nothing
End If

On Error Goto 0

If rs Is Nothing Then
    Response.Write "<div class='py-3'><div class='alert alert-danger'>Invalid step ID or database error.</div></div>"
ElseIf rs.eof Then
    Response.Write "<div class='py-3'><div class='alert alert-warning'> No Scenarios described yet. Please click on <b>Add Scenario</b> button to include the first scenario.</div></div>"
Else
%>

<table class="table table-striped table-hover">
  <thead class="table-dark">
	<tr class="d-flex">
		<td class="flex-grow-1">Title</td>
		<td class="col-2">Word Count</td>
		<td class="flex-shrink-1">Actions</td>
	</tr>
  </thead>
  <tbody>
  
  <%
	counter = 0
	while not rs.eof
	    counter = counter + 1
	%>
  <tr class="d-flex">
		<td class="flex-grow-1"> 														
			<a href="#" class="link-dark text-decoration-none" data-bs-toggle="modal" data-bs-target="#manageScenarioModal" data-title="Edit Scenario" data-url="manageScenario.asp?stepID=<%=request.querystring("stepID")%>&scenarioID=<%=rs("scenarioID")%>">
                <strong><%=Server.HTMLEncode(rs("name"))%></strong>
            </a>
            <br><small class="text-muted">Scenario #<%=counter%></small>
		</td>
        <td class="col-2 small text-muted">
            <%
            On Error Resume Next
            Dim wordCount
            wordCount = CountWords(rs("scenario"))
            If Err.Number <> 0 Then
                wordCount = 0
                Err.Clear
            End If
            Response.Write wordCount
            On Error Goto 0
            %> words
        </td>
		<td class="flex-shrink-1"> 																											
			<%if getStatusStep(request.querystring("stepID")) = STATE_ACTIVE then %>
			<a class="link-dark text-decoration-none" href="scenarioActions.asp?action=delete&stepID=<%=request.querystring("stepID")%>&scenarioID=<%=rs("scenarioID")%>" title="Delete" onclick="if (!confirm('Are you sure you want to delete this scenario?')) { return false; }">
			    <img src="/img/delete.png" height="20" width="auto" alt="Delete">
			</a>
			<%end if%>
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

</div>

<!-- Botões de ação -->
<nav class="navbar fixed-bottom navbar-light bg-light">
    <div class="container-fluid justify-content-center p-0">
		<%if getStatusStep(request.querystring("stepID")) = STATE_ACTIVE then %>
		<button class="btn btn-sm btn-primary m-1" type="button" data-bs-toggle="modal" data-bs-target="#manageScenarioModal" data-title="Add Scenario" data-url="manageScenario.asp?stepID=<%=request.queryString("stepID")%>"> 
            <i class="bi bi-plus-square text-light"></i> Add Scenario
        </button>
        
		<button class="btn btn-sm btn-secondary m-1" onclick="window.location.href='/stepsupportInformation.asp?stepID=<%=request.queryString("stepID")%>';"><i class="bi bi-journal-plus text-light"></i> Supporting Information</button>
		
        <button class="btn btn-sm btn-success m-1" onclick="if(confirm('This action will finalize all scenarios and complete the step. Continue?')) window.location.href='index.asp?action=finalize_scenarios&stepID=<%=request.queryString("stepID")%>';"><i class="bi bi-collection text-light"></i> Finalize Scenarios</button>
        
		<%else%>
		<button class="btn btn-sm btn-secondary m-1" onclick="window.location.href='/workplace.asp';"><i class="bi bi-arrow-left text-light"></i> Back to Workplace</button>
		<%end if%>
	</div>
</nav>

<!-- Modal para gestão de cenários -->
<div class="modal fade" id="manageScenarioModal" tabindex="-1" aria-labelledby="manageScenarioModalLabel" aria-hidden="true">
  <div class="modal-dialog modal-xl">
    <div class="modal-content">
      <div class="modal-header">
        <h5 class="modal-title" id="manageScenarioModalLabel">Scenario</h5>
        <button type="button" class="btn-close" data-bs-dismiss="modal" aria-label="Close"></button>
      </div>
      <div class="modal-body" id="manageScenarioModalBody">
        <div class="text-center">
            <div class="spinner-border" role="status">
                <span class="visually-hidden">Loading...</span>
            </div>
        </div>
      </div>
    </div>
  </div>
</div>

<script src="https://cdn.jsdelivr.net/npm/bootstrap@5.1.3/dist/js/bootstrap.bundle.min.js"></script>

<script>
// Configurar modal para carregar conteúdo dinamicamente
document.addEventListener('DOMContentLoaded', function() {
    var manageScenarioModal = document.getElementById('manageScenarioModal');
    if (manageScenarioModal) {
        manageScenarioModal.addEventListener('show.bs.modal', function(event) {
            var button = event.relatedTarget;
            var url = button.getAttribute('data-url');
            var title = button.getAttribute('data-title');
            
            var modalTitle = manageScenarioModal.querySelector('.modal-title');
            var modalBody = manageScenarioModal.querySelector('.modal-body');
            
            modalTitle.textContent = title;
            modalBody.innerHTML = '<div class="text-center"><div class="spinner-border" role="status"><span class="visually-hidden">Loading...</span></div></div>';
            
            // Carregar conteúdo via AJAX
            fetch(url)
                .then(response => {
                    if (!response.ok) {
                        throw new Error('Network response was not ok');
                    }
                    return response.text();
                })
                .then(html => {
                    modalBody.innerHTML = html;
                })
                .catch(error => {
                    modalBody.innerHTML = '<div class="alert alert-danger">Error loading content: ' + error.message + '</div>';
                });
        });
    }
    
    // Auto-dismiss alerts
    setTimeout(function() {
        var alerts = document.querySelectorAll('.alert');
        alerts.forEach(function(alert) {
            var alertInstance = new bootstrap.Alert(alert);
            alertInstance.close();
        });
    }, 5000);
});
</script>