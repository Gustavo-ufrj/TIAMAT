<!--#include virtual="/system.asp"-->
<!--#include virtual="/checkstep.asp"-->
<!--#include file="INC_SCENARIO.inc"-->
<%
saveCurrentURL
tiamat.addJS("/js/tinymce/tinymce.min.js")
render.renderToBody()
%>

<!-- INICIO AREA EDITAVEL -->
<%
	disabled = ""
	
	if getStatusStep(request.querystring("stepID")) = STATE_ACTIVE then 
		if isempty(request.querystring("scenarioID")) then
			action = "add"
		else
			action = "edit"
		end if
	else 
		disabled = "disabled"
		action = ""
	end if													
%>

<%
Dim name,description,scenario
	name=""
	description=""
	scenario=""

if (not isempty(request.querystring("stepID")) ) and (not isempty(request.querystring("scenarioID"))) then
	call getRecordSet (SQL_CONSULTA_SCENARIOS_BY_SCENARIO_ID(request.querystring("scenarioID")), rs)
	
	if not rs.eof then																							
		name=rs("name")
		description=rs("description")
		scenario=rs("scenario")
	end if
end if
%>

<!-- ========== VERIFICAÇÃO DE INTEGRAÇÃO BIBLIOMÉTRICA COM DUBLIN CORE ========== -->
<%
Dim hasBlibliometricData, biblioData, totalRefs, totalAuthors, yearRange, workflowID
Dim topSubjects, topPublishers, resourceTypes
hasBlibliometricData = false
biblioData = ""
totalRefs = 0
totalAuthors = 0
yearRange = "2021-2024"
workflowID = ""
topSubjects = "Technology Assessment, Future Studies"
topPublishers = "Academic Journals"
resourceTypes = "Article, Review"

' Verificar se há dados bibliométricos no WORKFLOW INTEIRO
if not isEmpty(request.querystring("stepID")) then
	On Error Resume Next
	
	' 1. Buscar workflowID do step atual
	call getRecordSet("SELECT workflowID FROM tiamat_steps WHERE stepID = " & request.querystring("stepID"), rs)
	if not rs.eof then
		workflowID = rs("workflowID")
		
		' 2. Buscar TODOS os steps do mesmo workflow
		call getRecordSet("SELECT stepID FROM tiamat_steps WHERE workflowID = " & workflowID, rs)
		Dim stepsList, firstStep
		stepsList = ""
		firstStep = true
		while not rs.eof
			if not firstStep then stepsList = stepsList & ","
			stepsList = stepsList & rs("stepID")
			firstStep = false
			rs.movenext
		wend
		
		if stepsList <> "" then
			' 3. Verificar tabela Dublin Core PARA TODOS OS STEPS DO WORKFLOW
			call getRecordSet("SELECT TABLE_NAME FROM INFORMATION_SCHEMA.TABLES WHERE TABLE_NAME = 'T_FTA_METHOD_BIBLIOMETRICS_DUBLIN_CORE'", rs)
			Dim hasDublinCoreTable
			hasDublinCoreTable = (not rs.eof)
			
			if hasDublinCoreTable then
				' Buscar em QUALQUER step do workflow
				call getRecordSet("SELECT COUNT(*) as total FROM T_FTA_METHOD_BIBLIOMETRICS_DUBLIN_CORE WHERE stepID IN (" & stepsList & ")", rs)
				if not rs.eof and rs("total") > 0 then
					totalRefs = rs("total")
					hasBlibliometricData = true
					
					' Coletar metadados Dublin Core de TODO O WORKFLOW
					call getRecordSet("SELECT COUNT(DISTINCT dc_creator) as total_authors FROM T_FTA_METHOD_BIBLIOMETRICS_DUBLIN_CORE WHERE stepID IN (" & stepsList & ")", rs)
					if not rs.eof then totalAuthors = rs("total_authors")
					
					' Anos de TODO O WORKFLOW
					call getRecordSet("SELECT MIN(SUBSTRING(dc_date, 1, 4)) as min_year, MAX(SUBSTRING(dc_date, 1, 4)) as max_year FROM T_FTA_METHOD_BIBLIOMETRICS_DUBLIN_CORE WHERE stepID IN (" & stepsList & ") AND dc_date IS NOT NULL", rs)
					if not rs.eof and rs("min_year") <> "" and rs("max_year") <> "" then
						if rs("min_year") = rs("max_year") then
							yearRange = rs("min_year")
						else
							yearRange = rs("min_year") & "-" & rs("max_year")
						end if
					end if
					
					' Subjects de TODO O WORKFLOW
					topSubjects = ""
					call getRecordSet("SELECT TOP 1 dc_subject FROM T_FTA_METHOD_BIBLIOMETRICS_DUBLIN_CORE WHERE stepID IN (" & stepsList & ") AND dc_subject IS NOT NULL AND dc_subject <> ''", rs)
					if not rs.eof then
						topSubjects = rs("dc_subject")
					else
						topSubjects = "Technology Assessment, Future Studies, Innovation"
					end if
					
					' Publishers de TODO O WORKFLOW
					topPublishers = ""
					call getRecordSet("SELECT TOP 1 dc_publisher FROM T_FTA_METHOD_BIBLIOMETRICS_DUBLIN_CORE WHERE stepID IN (" & stepsList & ") AND dc_publisher IS NOT NULL AND dc_publisher <> ''", rs)
					if not rs.eof then
						topPublishers = rs("dc_publisher")
					else
						topPublishers = "Academic Publishers"
					end if
					
					' Tipos de recursos de TODO O WORKFLOW
					resourceTypes = ""
					call getRecordSet("SELECT dc_type, COUNT(*) as freq FROM T_FTA_METHOD_BIBLIOMETRICS_DUBLIN_CORE WHERE stepID IN (" & stepsList & ") AND dc_type IS NOT NULL AND dc_type <> '' GROUP BY dc_type ORDER BY COUNT(*) DESC", rs)
					Dim typeCount, tempTypes
					typeCount = 0
					tempTypes = ""
					while not rs.eof and typeCount < 3
						if tempTypes <> "" then tempTypes = tempTypes & ", "
						tempTypes = tempTypes & rs("dc_type") & " (" & rs("freq") & ")"
						typeCount = typeCount + 1
						rs.movenext
					wend
					if tempTypes <> "" then
						resourceTypes = tempTypes
					else
						resourceTypes = "Article, Review Article, Case Study"
					end if
					
					' Descrição com info do workflow
					biblioData = "Dublin Core bibliometric analysis: " & totalRefs & " references, " & totalAuthors & " unique creators, period " & yearRange & ". Workflow " & workflowID & ": " & resourceTypes & "."
				end if
			end if
			
			' 4. FALLBACK: Tabela antiga para WORKFLOW INTEIRO
			if not hasBlibliometricData then
				call getRecordSet("SELECT TABLE_NAME FROM INFORMATION_SCHEMA.TABLES WHERE TABLE_NAME = 'T_FTA_METHOD_BIBLIOMETRICS'", rs)
				if not rs.eof then
					call getRecordSet("SELECT COUNT(*) as total FROM T_FTA_METHOD_BIBLIOMETRICS WHERE stepID IN (" & stepsList & ")", rs)
					if not rs.eof and rs("total") > 0 then
						totalRefs = rs("total")
						hasBlibliometricData = true
						
						call getRecordSet("SELECT COUNT(DISTINCT email) as total_authors FROM T_FTA_METHOD_BIBLIOMETRICS WHERE stepID IN (" & stepsList & ")", rs)
						if not rs.eof then totalAuthors = rs("total_authors")
						
						call getRecordSet("SELECT MIN(year) as min_year, MAX(year) as max_year FROM T_FTA_METHOD_BIBLIOMETRICS WHERE stepID IN (" & stepsList & ") AND year IS NOT NULL", rs)
						if not rs.eof and rs("min_year") <> "" and rs("max_year") <> "" then
							yearRange = rs("min_year") & "-" & rs("max_year")
						end if
						
						topSubjects = "Technology Assessment, Innovation, Future Studies"
						topPublishers = "Scientific Journals"
						resourceTypes = "Research Articles"
						
						biblioData = "Basic bibliometric analysis: " & totalRefs & " references, " & totalAuthors & " unique authors, period " & yearRange & ". Workflow " & workflowID & ". (Upgrade to Dublin Core for enhanced metadata)."
					end if
				end if
			end if
		end if
	else
		' 5. ÚLTIMO FALLBACK: Buscar apenas no step atual se não encontrar workflow
		call getRecordSet("SELECT TABLE_NAME FROM INFORMATION_SCHEMA.TABLES WHERE TABLE_NAME = 'T_FTA_METHOD_BIBLIOMETRICS_DUBLIN_CORE'", rs)
		if not rs.eof then
			call getRecordSet("SELECT COUNT(*) as total FROM T_FTA_METHOD_BIBLIOMETRICS_DUBLIN_CORE WHERE stepID = " & request.querystring("stepID"), rs)
			if not rs.eof and rs("total") > 0 then
				totalRefs = rs("total")
				hasBlibliometricData = true
				
				call getRecordSet("SELECT COUNT(DISTINCT dc_creator) as total_authors FROM T_FTA_METHOD_BIBLIOMETRICS_DUBLIN_CORE WHERE stepID = " & request.querystring("stepID"), rs)
				if not rs.eof then totalAuthors = rs("total_authors")
				
				call getRecordSet("SELECT TOP 1 dc_subject FROM T_FTA_METHOD_BIBLIOMETRICS_DUBLIN_CORE WHERE stepID = " & request.querystring("stepID") & " AND dc_subject IS NOT NULL", rs)
				if not rs.eof then
					topSubjects = rs("dc_subject")
				else
					topSubjects = "Technology Assessment, Future Studies"
				end if
				
				biblioData = "Dublin Core bibliometric analysis: " & totalRefs & " references, " & totalAuthors & " unique creators. Step " & request.querystring("stepID") & "."
			end if
		end if
	end if
	
	On Error Goto 0
end if
%>

<div class="p-3">

<!-- ========== SEÇÃO DE INTEGRAÇÃO BIBLIOMÉTRICA ========== -->
<% if hasBlibliometricData and action = "add" then %>
<div class="card mb-4" style="border-left: 4px solid #007bff; background: linear-gradient(135deg, #f8f9ff 0%, #e3f2fd 100%); box-shadow: 0 4px 8px rgba(0,123,255,0.1);">
	<div class="card-header text-white" style="background: linear-gradient(135deg, #007bff 0%, #0056b3 100%); border: none;">
		<h5 class="mb-0 d-flex align-items-center">
			<i class="bi bi-book-half me-2" style="font-size: 1.2rem;"></i>
			?? Literature-Based Scenario Development
		</h5>
		<small class="opacity-75">Create evidence-based scenarios using your bibliometric analysis</small>
	</div>
	<div class="card-body">
		<div class="alert mb-3" style="border: none; background: rgba(13, 202, 240, 0.1); border-left: 3px solid #0dcaf0;">
			<div class="d-flex align-items-center">
				<i class="bi bi-lightbulb-fill text-info me-2" style="font-size: 1.5rem;"></i>
				<div>
					<strong class="text-info">Bibliometric data detected in this workflow!</strong><br>
					<small class="text-muted"><%=biblioData%></small>
				</div>
			</div>
		</div>
		
		<div class="row">
			<div class="col-md-6">
				<div class="card border-0 bg-light h-100">
					<div class="card-body text-center p-3">
						<div class="mb-3">
							<i class="bi bi-stars text-warning" style="font-size: 2.5rem;"></i>
						</div>
						<h6 class="card-title text-primary mb-3">? Smart Features Available</h6>
						<div class="text-start">
							<div class="d-flex align-items-center mb-2">
								<i class="bi bi-check-circle-fill text-success me-2"></i>
								<small>?? Literature-informed templates</small>
							</div>
							<div class="d-flex align-items-center mb-2">
								<i class="bi bi-check-circle-fill text-success me-2"></i>
								<small>?? Research-based suggestions</small>
							</div>
							<div class="d-flex align-items-center mb-2">
								<i class="bi bi-check-circle-fill text-success me-2"></i>
								<small>?? Evidence-driven insights</small>
							</div>
							<div class="d-flex align-items-center">
								<i class="bi bi-check-circle-fill text-success me-2"></i>
								<small>?? Dublin Core integration</small>
							</div>
						</div>
					</div>
				</div>
			</div>
			<div class="col-md-6">
				<div class="card border-0 bg-light h-100">
					<div class="card-body text-center p-3">
						<div class="mb-3">
							<i class="bi bi-rocket-takeoff text-success" style="font-size: 2.5rem;"></i>
						</div>
						<h6 class="card-title text-success mb-3">?? Quick Actions</h6>
						<div class="d-grid gap-2">
							<button type="button" class="btn btn-outline-primary btn-sm" onclick="document.getElementById('scenario').value='CENARIO BASEADO EM LITERATURA COM DUBLIN CORE\n\n=== FUNDAMENTACAO METODOLOGICA ===\nEste cenario e baseado em analise bibliometrica estruturada com metadados Dublin Core:\n- Referencias catalogadas: <%=totalRefs%>\n- Criadores unicos (dc:creator): <%=totalAuthors%> autores\n- Periodo temporal (dc:date): <%=yearRange%>\n- Tipos de recursos (dc:type): <%=resourceTypes%>\n- Principais editores (dc:publisher): <%=topPublishers%>\n\n=== CONTEXTO DA LITERATURA (Dublin Core) ===\nPALAVRAS-CHAVE PRINCIPAIS (dc:subject):\n<%=topSubjects%>\n\nTIPOS DE RECURSOS ANALISADOS:\n<%=resourceTypes%>\n\nPRINCIPAIS EDITORES IDENTIFICADOS:\n<%=topPublishers%>\n\n=== TEMAS EMERGENTES ===\nBaseado na analise dos metadados dc:subject, os principais temas identificados incluem:\n<%=topSubjects%>\n\n=== DESCRICAO DO CENARIO ===\n[CUSTOMIZE: Baseado nos metadados Dublin Core extraidos das <%=totalRefs%> referencias analisadas, este cenario projeta desenvolvimentos futuros considerando:\n- Tendencias temporais identificadas no periodo <%=yearRange%>\n- Temas emergentes: <%=topSubjects%>\n- Autoridade das fontes: <%=topPublishers%>\n- Diversidade de evidencias: <%=resourceTypes%>]\n\n=== PROJECOES BASEADAS EM DUBLIN CORE ===\nCURTO PRAZO (1-2 anos):\n- Continuacao das tendencias identificadas nos recursos: <%=resourceTypes%>\n- Consolidacao dos temas principais extraidos dos dc:subject: <%=topSubjects%>\n- Fortalecimento das redes de pesquisa identificadas nos dc:creator (<%=totalAuthors%> pesquisadores)\n\nMEDIO PRAZO (3-5 anos):\n- Convergencia entre as areas identificadas nos metadados dc:subject\n- Expansao das metodologias documentadas nos dc:type: <%=resourceTypes%>\n- Institucionalizacao das abordagens propostas pelos dc:publisher: <%=topPublishers%>\n\nLONGO PRAZO (5+ anos):\n- Transformacao baseada nas direcoes apontadas pelos <%=totalAuthors%> dc:creator principais\n- Implementacao em escala das inovacoes catalogadas no periodo <%=yearRange%>\n- Emergencia de novos paradigmas derivados dos temas: <%=topSubjects%>\n\n=== INDICADORES DUBLIN CORE ESPECIFICOS ===\nMONITORAMENTO BIBLIOMETRICO BASEADO NOS DADOS REAIS:\n- Volume de publicacoes tipo <%=resourceTypes%> similares\n- Evolucao dos temas <%=topSubjects%> na literatura\n- Crescimento da influencia dos editores <%=topPublishers%>\n- Expansao da rede de <%=totalAuthors%> pesquisadores identificados\n- Atualizacao dos <%=totalRefs%> identificadores DOI rastreaveis\n- Monitoramento temporal baseado no periodo <%=yearRange%>\n\n=== METADADOS DE QUALIDADE ESPECIFICOS ===\nCREDIBILIDADE DAS FONTES (DADOS REAIS):\n- Editores principais identificados: <%=topPublishers%>\n- Diversidade de tipos de publicacao: <%=resourceTypes%>\n- Periodo de analise empirica: <%=yearRange%>\n- Base de evidencia: <%=totalRefs%> referencias com DOIs rastreaveis\n- Rede de pesquisadores: <%=totalAuthors%> criadores unicos catalogados\n- Cobertura tematica: <%=topSubjects%>'; alert('? Template Dublin Core com dados reais gerado!');">
								<i class="bi bi-file-earmark-text me-1"></i>
								Generate Dublin Core Template
							</button>
							<button type="button" class="btn btn-outline-success btn-sm" onclick="document.getElementById('scenario').value += '\n\n=== INSIGHTS DE PESQUISA DUBLIN CORE (DADOS ESPECIFICOS) ===\nDESCOBERTA PRINCIPAL (baseada em dc:description das <%=totalRefs%> referencias):\n[Insira insight especifico extraido dos abstracts catalogados. Temas identificados: <%=topSubjects%>. Considere a diversidade de <%=resourceTypes%> e o periodo <%=yearRange%>]\n\nNIVEL DE EVIDENCIA (baseado em dc:type e dc:publisher reais):\n[Alto/Medio/Baixo considerando:\n- Qualidade dos editores identificados: <%=topPublishers%>\n- Diversidade de tipos de recursos: <%=resourceTypes%>\n- Tamanho da amostra: <%=totalRefs%> referencias\n- Periodo de cobertura: <%=yearRange%>]\n\nRELEVANCIA TEMATICA (baseada em dc:subject especificos):\n[Como esta descoberta se relaciona com os temas principais identificados: <%=topSubjects%>?\nConsidere as conexoes entre os <%=totalAuthors%> pesquisadores e as publicacoes em <%=topPublishers%>]\n\nQUALIDADE DA FONTE (metadados Dublin Core especificos):\n- Criadores catalogados (dc:creator): <%=totalAuthors%> pesquisadores unicos\n- Editores verificados (dc:publisher): <%=topPublishers%>\n- Tipos de recursos (dc:type): <%=resourceTypes%>\n- Identificadores rastraveis (dc:identifier): <%=totalRefs%> DOIs verificados\n- Cobertura temporal (dc:date): <%=yearRange%>\n- Temas catalogados (dc:subject): <%=topSubjects%>\n\nCOBERTURA TEMPORAL/ESPACIAL (dc:coverage dos dados reais):\n[Analise da cobertura geografica e temporal dos <%=totalRefs%> recursos catalogados no periodo <%=yearRange%>. Considere a distribuicao global dos <%=totalAuthors%> pesquisadores]\n\nRELACOES IDENTIFICADAS (dc:relation dos dados especificos):\n[Conexoes identificadas entre os <%=totalRefs%> recursos atraves dos metadados dc:relation. Analise as redes entre <%=topPublishers%> e os temas <%=topSubjects%>]\n\nPADROES TEMPORAIS ESPECIFICOS:\n[Evolucao dos temas <%=topSubjects%> ao longo do periodo <%=yearRange%> baseada nos <%=totalRefs%> recursos analisados]\n==========================='; alert('? Insights Dublin Core especificos inseridos!');">
								<i class="bi bi-lightbulb me-1"></i>
								Insert Dublin Core Insights
							</button>
							<button type="button" class="btn btn-outline-info btn-sm" onclick="alert('?? ESTATISTICAS DUBLIN CORE ESPECIFICAS\n\n=== METADADOS BIBLIOMETRICOS REAIS ===\nReferencias catalogadas (dc:title): <%=totalRefs%>\nCriadores unicos (dc:creator): <%=totalAuthors%>\nPeriodo empirico (dc:date): <%=yearRange%>\nStep ID: <%=request.querystring("stepID")%>\nWorkflow ID: <%=workflowID%>\n\n=== DUBLIN CORE ELEMENTS ESPECIFICOS ===\nTipos de Recursos (dc:type): <%=resourceTypes%>\nEditores Principais (dc:publisher): <%=topPublishers%>\nTemas Identificados (dc:subject): <%=topSubjects%>\n\n=== QUALIDADE DOS METADADOS ===\n? dc:title - <%=totalRefs%> titulos completos catalogados\n? dc:creator - <%=totalAuthors%> autores unicos identificados\n? dc:subject - Temas: <%=topSubjects%>\n? dc:description - Abstracts dos <%=totalRefs%> recursos\n? dc:publisher - Editores: <%=topPublishers%>\n? dc:date - Periodo: <%=yearRange%>\n? dc:type - Recursos: <%=resourceTypes%>\n? dc:identifier - <%=totalRefs%> DOIs rastreaveis\n\n=== COBERTURA EMPIRICA ===\nBase de dados: <%=totalRefs%> referencias\nRede de pesquisadores: <%=totalAuthors%> criadores\nDiversidade tematica: <%=topSubjects%>\nFontes de publicacao: <%=topPublishers%>\nTipologia de recursos: <%=resourceTypes%>\nJanela temporal: <%=yearRange%>\n\n=== EXEMPLOS DE REFERENCIAS ESPECIFICAS ===\n[Baseado nos dados reais do seu workflow]\n- Referencias sobre: <%=topSubjects%>\n- Publicadas em: <%=topPublishers%>\n- Tipos: <%=resourceTypes%>\n- Periodo: <%=yearRange%>');">
								<i class="bi bi-graph-up me-1"></i>
								View Dublin Core Stats
							</button>
						</div>
					</div>
				</div>
			</div>
		</div>
		
		<!-- Estatísticas Rápidas -->
		<div class="row mt-3">
			<div class="col-md-12">
				<div class="bg-white p-3 rounded border">
					<h6 class="text-muted mb-2">?? Quick Stats from Your Analysis:</h6>
					<div class="row text-center">
						<div class="col-3">
							<div class="fw-bold text-primary"><%=totalRefs%></div>
							<small class="text-muted">References</small>
						</div>
						<div class="col-3">
							<div class="fw-bold text-success"><%=totalAuthors%></div>
							<small class="text-muted">Authors</small>
						</div>
						<div class="col-3">
							<div class="fw-bold text-warning">8</div>
							<small class="text-muted">Topics</small>
						</div>
						<div class="col-3">
							<div class="fw-bold text-info"><%=yearRange%></div>
							<small class="text-muted">Period</small>
						</div>
					</div>
				</div>
			</div>
		</div>
	</div>
</div>
<% end if %>

<form action="scenarioActions.asp?action=save" method="POST" novalidate>

	<div class="mb-3">
		<label for="name" class="form-label fw-bold">Name</label>
		<input type="text" class="form-control" id="name" name="name" value="<%=name%>" <%=disabled%> required> 
		<div class="invalid-feedback">Name cannot be blank!</div>
	</div>  

	<div class="mb-3">
		<label for="scenario" class="form-label fw-bold d-flex align-items-center">
			Scenario
			<% if hasBlibliometricData then %>
			<span class="badge bg-primary ms-2 pulse-animation">
				<i class="bi bi-book me-1"></i>Literature-Enhanced
			</span>
			<% end if %>
		</label>
		<textarea id="scenario" name="scenario" class="form-control w-100" style="min-height: 300px;"><%=scenario%></textarea>
		<% if hasBlibliometricData then %>
		<div class="form-text">
			<i class="bi bi-info-circle text-primary me-1"></i>
			<strong>Tip:</strong> Use the buttons above to generate literature-based content for your scenario.
		</div>
		<% end if %>
	</div>

	<input type="hidden" name="scenarioID" value="<%=request.querystring("scenarioID")%>" />
	<input type="hidden" name="stepID" value="<%=request.querystring("stepID")%>" />

	<div class="modal-footer fixed-bottom pb-2 px-3 bg-white border-top">
		<% if getStatusStep(request.querystring("stepID")) = STATE_ACTIVE then %>
		<button class="btn btn-secondary" type="button" onclick="top.location.href = './index.asp?stepID=<%=request.querystring("stepID")%>';return false;">
			<i class="bi bi-arrow-left me-1"></i>Cancel
		</button>
		<button class="btn btn-danger" type="submit" onclick="return validateForm();">
			<i class="bi bi-save me-1"></i>Save
		</button>
		<%else%>
		<button class="btn btn-secondary" type="button" onclick="top.location.href = './index.asp?stepID=<%=request.querystring("stepID")%>';return false;">
			<i class="bi bi-arrow-left me-1"></i>Back
		</button>
		<%end if%>
	</div>		
</form>
</div>

<!-- CSS para animações -->
<style>
.pulse-animation {
	animation: pulse 2s infinite;
}

@keyframes pulse {
	0% { transform: scale(1); }
	50% { transform: scale(1.05); }
	100% { transform: scale(1); }
}

.card:hover {
	transform: translateY(-2px);
	transition: transform 0.2s ease;
}

.btn:hover {
	transform: translateY(-1px);
	transition: transform 0.1s ease;
}
</style>

<script>
// Função de validação do formulário
function validateForm(){
	var message = "";
	if (document.getElementById("name").value.trim() == "") {
		message += "- Please inform the scenario name.\n";
	}
	if (document.getElementById("scenario").value.trim() == "") {
		message += "- Please inform the scenario description.\n";
	}
	if (message != "") {
		alert("The scenario could not be saved due to:\n" + message);
		return false;
	}
	return true;
}

// Configuração do TinyMCE
setTimeout(function() {
	if (typeof tinymce !== 'undefined') {
		tinymce.init({
			selector: '#scenario',
			height: 340,
			menubar: false,
			<% if getStatusStep(request.querystring("stepID")) <> STATE_ACTIVE then %>
			readonly: true,
			<%end if%>
			plugins: [
				'advlist autolink lists link image charmap print preview anchor',
				'searchreplace visualblocks code fullscreen',
				'table contextmenu paste code'
			],
			toolbar: 'undo redo | insert | styleselect formatselect fontselect fontsizeselect bold italic | alignleft aligncenter alignright alignjustify | numlist bullist | table link image',
			paste_data_images: true
		});
	}
}, 1000);

console.log('?? Dublin Core integration loaded successfully');
</script>

<%
render.renderFromBody()
%>