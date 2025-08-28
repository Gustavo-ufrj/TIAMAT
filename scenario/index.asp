<!--#include virtual="/system.asp"-->
<!--#include virtual="/checkstep.asp"-->
<!--#include file="INC_SCENARIO.inc"-->
<%
saveCurrentURL

' Processar ação de finalização se vier por GET
Dim action
action = Request.QueryString("action")

If action = "finalize_scenarios" Then
    Dim stepID
    stepID = Request.QueryString("stepID")
    
    ' Verificar se tem cenários
    call getRecordSet("SELECT COUNT(*) as total FROM T_FTA_METHOD_SCENARIOS WHERE stepID = " & stepID, rs)
    
    If Not rs.EOF Then
        If rs("total") > 0 Then
            ' Finalizar o step
            Call endStep(stepID)
            Response.Redirect "/workplace.asp"
            Response.End
        Else
            ' Não tem cenários
            Response.Write "<script>alert('Please create at least one scenario before finalizing.'); window.location.href='index.asp?stepID=" & stepID & "';</script>"
            Response.End
        End If
    End If
End If

render.renderToBody()
%>

<div class="p-3">

<%
' CORRIGIDO: Usar a funcao correta que existe no INC_SCENARIO.inc
call getRecordSet(SQL_CONSULTA_SCENARIOS(request.querystring("stepID")), rs)

if rs.eof then
%>

<div class="alert alert-info text-center">
  <h5>No scenarios found</h5>
  <p>Please click on <b>Add Scenario</b> button to include the first scenario.</p>
</div>

<%
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
			<a href="#" class="link-dark text-decoration-none" onclick="openScenarioEditor(<%=rs("scenarioID")%>)">
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

<!-- Botoes de acao CORRIGIDOS -->
<nav class="navbar fixed-bottom navbar-light bg-light">
    <div class="container-fluid justify-content-center p-0">
		<%if getStatusStep(request.querystring("stepID")) = STATE_ACTIVE then %>
		<button class="btn btn-sm btn-primary m-1" type="button" onclick="openScenarioEditor()"> 
            <i class="bi bi-plus-square text-light"></i> Add Scenario
        </button>
        
		<button class="btn btn-sm btn-secondary m-1" onclick="window.location.href='/stepsupportInformation.asp?stepID=<%=request.queryString("stepID")%>';"><i class="bi bi-journal-plus text-light"></i> Supporting Information</button>
		
        <!-- BOTÃO FINALIZAR CORRIGIDO -->
        <button class="btn btn-sm btn-success m-1" type="button" onclick="finalizeScenarios()">
            <i class="bi bi-collection text-light"></i> Finalize Scenarios
        </button>
        
		<%else%>
		<button class="btn btn-sm btn-secondary m-1" onclick="window.location.href='/workplace.asp';"><i class="bi bi-arrow-left text-light"></i> Back to Workplace</button>
		<%end if%>
	</div>
</nav>

<!-- Modal para gestao de cenarios -->
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
// Funcao para abrir o editor de cenarios
function openScenarioEditor(scenarioID) {
    var stepID = '<%=request.querystring("stepID")%>';
    var modal = document.getElementById('manageScenarioModal');
    var modalTitle = modal.querySelector('.modal-title');
    var modalBody = modal.querySelector('.modal-body');
    
    // Definir titulo
    modalTitle.textContent = scenarioID ? 'Edit Scenario' : 'Add Scenario';
    
    // Mostrar loading
    modalBody.innerHTML = '<div class="text-center"><div class="spinner-border" role="status"><span class="visually-hidden">Loading...</span></div></div>';
    
    // Construir URL
    var url = 'manageScenario.asp?stepID=' + stepID;
    if (scenarioID) {
        url += '&scenarioID=' + scenarioID;
    }
    
    console.log('Loading scenario editor from URL:', url);
    
    // Carregar conteudo via AJAX
    fetch(url)
        .then(response => {
            console.log('Response status:', response.status, response.statusText);
            if (!response.ok) {
                throw new Error('HTTP ' + response.status + ': ' + response.statusText + ' - URL: ' + url);
            }
            return response.text();
        })
        .then(html => {
            console.log('Content loaded successfully, length:', html.length);
            modalBody.innerHTML = html;
            
            // Inicializar TinyMCE se necessario
            setTimeout(function() {
                initializeTinyMCE();
            }, 500);
            
            // Executar scripts que podem estar no HTML carregado
            executeScriptsInModal(modalBody);
        })
        .catch(error => {
            console.error('Error loading scenario editor:', error);
            modalBody.innerHTML = '<div class="alert alert-danger">Error loading scenario editor: ' + error.message + '</div>';
        });
    
    // Mostrar modal
    var bootstrapModal = new bootstrap.Modal(modal);
    bootstrapModal.show();
}

// FUNÇÃO CORRIGIDA PARA FINALIZAR CENÁRIOS
function finalizeScenarios() {
    console.log('Finalize scenarios button clicked');
    
    if (confirm('This action will finalize all scenarios and complete the step. Continue?')) {
        console.log('User confirmed - finalizing scenarios');
        
        // Método 1: Enviar por GET para scenarioActions
        var stepID = '<%=request.querystring("stepID")%>';
        var url = 'scenarioActions.asp?action=finalize_scenarios&stepID=' + stepID;
        
        console.log('Redirecting to: ' + url);
        window.location.href = url;
        
        // Método alternativo: Se não redirecionar em 2 segundos, tentar POST
        setTimeout(function() {
            console.log('Trying alternative POST method...');
            
            // Criar form para POST
            var form = document.createElement('form');
            form.method = 'POST';
            form.action = 'scenarioActions.asp';
            
            var actionInput = document.createElement('input');
            actionInput.type = 'hidden';
            actionInput.name = 'action';
            actionInput.value = 'finalize_scenarios';
            form.appendChild(actionInput);
            
            var stepInput = document.createElement('input');
            stepInput.type = 'hidden';
            stepInput.name = 'stepID';
            stepInput.value = stepID;
            form.appendChild(stepInput);
            
            document.body.appendChild(form);
            form.submit();
        }, 2000);
    }
}

// Funcao para inicializar TinyMCE
function initializeTinyMCE() {
    if (typeof tinymce !== 'undefined') {
        // Remover instancias existentes
        tinymce.remove('#scenario');
        
        tinymce.init({
            selector: '#scenario',
            height: 340,
            menubar: false,
            plugins: [
                'advlist autolink lists link image charmap print preview anchor',
                'searchreplace visualblocks code fullscreen',
                'table contextmenu paste code'
            ],
            toolbar: 'undo redo | insert | styleselect formatselect fontselect fontsizeselect bold italic | alignleft aligncenter alignright alignjustify | numlist bullist | table link image',
            paste_data_images: true,
            setup: function(editor) {
                editor.on('init', function() {
                    console.log('TinyMCE initialized successfully in modal');
                });
            }
        });
    } else {
        console.log('TinyMCE not available');
    }
}

// Funcao para executar scripts no conteudo carregado via AJAX
function executeScriptsInModal(container) {
    var scripts = container.querySelectorAll('script');
    scripts.forEach(function(script) {
        try {
            eval(script.innerHTML);
        } catch (error) {
            console.error('Error executing script in modal:', error);
        }
    });
}

// Auto-dismiss alerts
document.addEventListener('DOMContentLoaded', function() {
    setTimeout(function() {
        var alerts = document.querySelectorAll('.alert');
        alerts.forEach(function(alert) {
            if (alert.classList.contains('alert-info') || alert.classList.contains('alert-success')) {
                var alertInstance = new bootstrap.Alert(alert);
                alertInstance.close();
            }
        });
    }, 5000);
    
    console.log('Scenario index loaded - finalize button ready');
});
</script>

<%
render.renderFromBody()
%>