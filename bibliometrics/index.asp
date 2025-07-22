<!--#include virtual="/system.asp"-->
<!--#include virtual="/checkstep.asp"-->
<!--#include file="INC_BIBLIOMETRICS.inc"-->
<!--#include virtual="/TIAMAT_OUTPUT_INTEGRATION.asp"-->
<%
saveCurrentURL
render.renderTitle()

' NOVO: Capturar output se vier de finalização
Dim action, stepID
action = Request.QueryString("action")
stepID = Request.QueryString("stepID")

If action = "capture_output" And stepID <> "" Then
    ' Capturar dados bibliométricos para output
    Call CapturebibliometricsOutput(stepID)
End If

		dim rs
		dim rsAuthor
		dim rsTag
		Dim counter
		dim filter
		
		filter = "0"
		if not isempty(request.querystring("filter")) then filter = request.querystring("filter")
			
		if cint(filter) > 0 then
			call getRecordset(SQL_CONSULTA_BIBLIOMETRICS_FILTER(request.querystring("stepID"), filter),rs)
		else
			call getRecordset(SQL_CONSULTA_BIBLIOMETRICS(request.querystring("stepID")),rs)
		end if

%>


<div class="p-3">

<%

	if rs.eof then
		response.write "<div class='py-3'><div class='alert alert-danger'> No reference was found.</div></div>"
	else
%>
<table class="table table-striped table-hover">
  <thead class="table-dark">
	<tr>
		<td>User</td>
		<td>Year</td>
		<td>Authors</td>
		<td>Title</td>
		<td>Actions</td>
	</tr>
  </thead>
  <tbody>

<%
			while not rs.eof
			 pdf_link = "#"
			 if rs("file_path") <> "" then
				pdf_link = rs("file_path")
			 end if

			
			%>
			<tr>
				<td class="p-1">														
				<img src="<%=getPhoto(rs("email"))%>" class="rounded-circle align-middle" title="<%=getName(rs("email"))%>" style="height:24px;width:auto;">						
				</td>												
				
				<td class="p-1">														
					<a class="link-dark text-decoration-none"  href="<%=pdf_link%>"><%=(rs("year"))%></a> 
				</td>
				<td class="p-1">														
					<a class="link-dark text-decoration-none"  href="<%=pdf_link%>"> 
				<%
				
					
					call getRecordset(SQL_CONSULTA_BIBLIOMETRICS_AUTHORS(cstr(rs("referenceID"))),rsAuthor)

					if rsAuthor.RecordCount > 2 then
						response.write ucase(strLeft(rsAuthor("name"),",")) & " et al."
					else
						while not rsAuthor.eof
							response.write ucase(strLeft(rsAuthor("name"),","))
							rsAuthor.movenext
							if not rsAuthor.eof then
								response.write "; "
							end if
						wend
					end if
					
				
				%>
				</a> 
				</td>
				<td class="p-1">														
					<a class="link-dark text-decoration-none"  href="<%=pdf_link%>"><%=(rs("title"))%></a> 
				</td>
				<td class="p-1">														
				 <div class="container p-0 m-0">
					<div class="row">
					<% if rs("file_path") <> "" then %>
					<div class="col-3  p-1 m-0"><a href="<%=rs("file_path")%>" title="Open"><img src="/img/pdf_icon.png" height=20 width=auto></a></div>
					<%end if%>
					
					<%if getStatusStep(request.querystring("stepID")) = STATE_ACTIVE then %>

					<div class="col-3  p-1 m-0"><a href="#" title="Edit" data-bs-toggle="modal" data-bs-target="#manageReferenceModal" data-step-id="<%=request.querystring("stepID")%>" data-filter="<%=request.querystring("filter")%>" data-title="Edit Reference" data-url="editReference.asp?stepID=<%=cstr(rs("stepID"))%>&referenceID=<%=cstr(rs("referenceID"))%>"><img src="/img/edit.png" height=20 width=auto></a></div>
						
					<div class="col-3 p-1 m-0"><a href="referenceActions.asp?action=delete&stepID=<%=cstr(rs("stepID"))%>&referenceID=<%=cstr(rs("referenceID"))%>" title="Delete"  onclick="if (!confirm('Are you sure?')) { return false; }"><img src="/img/delete.png" height=20 width=auto></a></div>
					<%end if%>
					</div>				
				 </div>									
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
		 
		 
			<!--<label for="filter" class="form-label mt-2">Filter</label>-->
			<select id="filter" class="form-control-sm mx-2" onChange="filterData(this.value);">
				<option value="0">All subjects</option>
				<%

				call getRecordset(SQL_CONSULTA_BIBLIOMETRICS_TAGS_LIST_PER_STEP_ID(request.querystring("stepID")),rsTag)

				while not rsTag.eof
				if filter = cstr(rsTag("tagID")) then
					response.write "<option selected value='"+cstr(rsTag("tagID"))+"'>"+rsTag("tag")+"</option>"
				else
					response.write "<option value='"+cstr(rsTag("tagID"))+"'>"+rsTag("tag")+"</option>"
				end if
				rsTag.movenext
				wend
				%>
			</select>
		  <div class="p-0 m-0">
		  </div>
		
		<button class="btn btn-sm btn-secondary m-1" onclick="window.location.href='referenceActions.asp?action=export&stepID=<%=request.queryString("stepID")%>';"><i class="bi bi-export text-light"></i> Export Data</button>
    <%if getStatusStep(request.querystring("stepID")) = STATE_ACTIVE then %>
		<button class="btn btn-sm btn-secondary m-1" type="button" data-bs-toggle="modal" data-bs-target="#manageReferenceModal" data-step-id="<%=request.querystring("stepID")%>" data-filter="<%=request.querystring("filter")%>" data-title="Add Reference" data-url="editReference.asp?stepID=<%=request.queryString("stepID")%>"  > <i class="bi bi-plus-square text-light"></i> Add Reference</button>
		<button class="btn btn-sm btn-danger m-1" onclick="window.location.href='/stepsupportInformation.asp?stepID=<%=request.queryString("stepID")%>';"><i class="bi bi-journal-plus text-light"></i> Supporting Information</button>
		<!-- MODIFICADO: Botão Finish agora captura output antes de finalizar -->
		<button class="btn btn-sm btn-danger m-1" onclick="if(confirm('This action will save the bibliometric analysis with Dublin Core metadata and finish the step. Continue?')) finishWithOutput(<%=request.queryString("stepID")%>)"><i class="bi bi-check-lg text-light"></i> Finish</button>
	<%end if%>
		 
		 
		 
        	
			
			
         </div>
      </nav>									

</div>
	
	<script>
	
	function filterData(newValue){
		if (newValue > 0) {
			window.location.href = './index.asp?stepID=<%=request.querystring("stepID")%>&filter='+newValue;
		}
		else {
			window.location.href = './index.asp?stepID=<%=request.querystring("stepID")%>';
		}
	}
	
	// NOVA FUNÇÃO: Capturar output antes de finalizar
	function finishWithOutput(stepID) {
		// Primeiro captura o output
		window.location.href = './index.asp?action=capture_output&stepID=' + stepID;
	}
	</script>
	
<!-- Add/Edit Reference Modal -->
<div class="modal fade" id="manageReferenceModal" tabindex="-1" aria-labelledby="manageReferenceModal" aria-hidden="true">
  <div class="modal-dialog modal-dialog-centered modal-xl">
    <div class="modal-content">
      <div class="modal-header">
        <h5 class="modal-title" id="referenceModal"></h5>
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

$('#manageReferenceModal').on('show.bs.modal', function(e) {
	var title = $(e.relatedTarget).data('title');
	var url = $(e.relatedTarget).data('url');
    
	$('#referenceModal').html(title);
	$('#iframeReference').attr('src',url);
});
</script>

<%
'=========================================
' NOVA FUNÇÃO: Capturar dados bibliométricos
'=========================================
Sub CapturebiblimetricsOutput(stepID)
    On Error Resume Next
    
    ' Buscar dados bibliométricos do step
    Dim rsBiblio, rsAuthors, rsYears, rsTags
    Dim totalReferences, authorCount, yearSpan, tagCount
    
    ' Total de referências
    Call getRecordset("SELECT COUNT(*) as total FROM tiamat_step_bib_references WHERE stepID = " & stepID, rsBiblio)
    totalReferences = 0
    If Not rsBiblio.eof Then totalReferences = rsBiblio("total")
    
    ' Contagem de autores únicos
    Call getRecordset("SELECT COUNT(DISTINCT authorID) as total FROM tiamat_step_bib_reference_authors ra INNER JOIN tiamat_step_bib_references r ON ra.referenceID = r.referenceID WHERE r.stepID = " & stepID, rsAuthors)
    authorCount = 0
    If Not rsAuthors.eof Then authorCount = rsAuthors("total")
    
    ' Span de anos
    Call getRecordset("SELECT MIN(year) as min_year, MAX(year) as max_year FROM tiamat_step_bib_references WHERE stepID = " & stepID, rsYears)
    yearSpan = "N/A"
    If Not rsYears.eof And Not IsNull(rsYears("min_year")) Then 
        yearSpan = rsYears("min_year") & "-" & rsYears("max_year")
    End If
    
    ' Tags/tópicos
    Call getRecordset("SELECT COUNT(DISTINCT tagID) as total FROM tiamat_step_bib_reference_tags rt INNER JOIN tiamat_step_bib_references r ON rt.referenceID = r.referenceID WHERE r.stepID = " & stepID, rsTags)
    tagCount = 0
    If Not rsTags.eof Then tagCount = rsTags("total")
    
    ' Estruturar output em JSON
    Dim outputData
    Set outputJSON = New aspJSON
    With outputJSON.data
        .add "analysisType", "Bibliometric Analysis"
        .add "stepID", stepID
        .add "processedAt", FormatDateTime(Now(), 2)
        .add "methodology", "Systematic Literature Review"
        
        ' Métricas principais
        .add "metrics", outputJSON.Collection()
        With .item("metrics")
            .add "totalReferences", totalReferences
            .add "uniqueAuthors", authorCount
            .add "timeSpan", yearSpan
            .add "topics", tagCount
            .add "averageReferencesPerYear", IIf(totalReferences > 0, Round(totalReferences / 5, 2), 0)
        End With
        
        ' Top autores (buscar os 5 mais citados)
        .add "topAuthors", outputJSON.Collection()
        Dim rsTopAuthors, i
        Call getRecordset("SELECT TOP 5 a.name, COUNT(*) as publications FROM tiamat_step_bib_reference_authors ra INNER JOIN tiamat_step_bib_references r ON ra.referenceID = r.referenceID INNER JOIN tiamat_bib_authors a ON ra.authorID = a.authorID WHERE r.stepID = " & stepID & " GROUP BY a.authorID, a.name ORDER BY publications DESC", rsTopAuthors)
        i = 0
        While Not rsTopAuthors.eof And i < 5
            .item("topAuthors").add i, outputJSON.Collection()
            With .item("topAuthors").item(i)
                .add "name", rsTopAuthors("name")
                .add "publications", rsTopAuthors("publications")
            End With
            i = i + 1
            rsTopAuthors.movenext
        Wend
        
        ' Distribuição por ano
        .add "yearlyDistribution", outputJSON.Collection()
        Dim rsYearDist, j
        Call getRecordset("SELECT year, COUNT(*) as count FROM tiamat_step_bib_references WHERE stepID = " & stepID & " GROUP BY year ORDER BY year", rsYearDist)
        j = 0
        While Not rsYearDist.eof
            .item("yearlyDistribution").add j, outputJSON.Collection()
            With .item("yearlyDistribution").item(j)
                .add "year", rsYearDist("year")
                .add "count", rsYearDist("count")
            End With
            j = j + 1
            rsYearDist.movenext
        Wend
        
        ' Top tópicos/tags
        .add "topTopics", outputJSON.Collection()
        Dim rsTopTags, k
        Call getRecordset("SELECT TOP 10 t.tag, COUNT(*) as frequency FROM tiamat_step_bib_reference_tags rt INNER JOIN tiamat_step_bib_references r ON rt.referenceID = r.referenceID INNER JOIN tiamat_bib_tags t ON rt.tagID = t.tagID WHERE r.stepID = " & stepID & " GROUP BY t.tagID, t.tag ORDER BY frequency DESC", rsTopTags)
        k = 0
        While Not rsTopTags.eof And k < 10
            .item("topTopics").add k, outputJSON.Collection()
            With .item("topTopics").item(k)
                .add "topic", rsTopTags("tag")
                .add "frequency", rsTopTags("frequency")
            End With
            k = k + 1
            rsTopTags.movenext
        Wend
        
        ' Metadados de qualidade
        .add "qualityMetrics", outputJSON.Collection()
        With .item("qualityMetrics")
            .add "dataCompleteness", IIf(totalReferences > 0, "High", "Low")
            .add "coverageYears", yearSpan
            .add "authorDiversity", IIf(authorCount > 10, "High", IIf(authorCount > 5, "Medium", "Low"))
            .add "topicCoverage", IIf(tagCount > 5, "Broad", IIf(tagCount > 2, "Medium", "Narrow"))
        End With
        
        ' Recomendações
        .add "recommendations", outputJSON.Collection()
        With .item("recommendations")
            If totalReferences < 20 Then
                .add 0, "Consider expanding the search to include more references"
            End If
            If yearSpan = "N/A" Or InStr(yearSpan, "-") = 0 Then
                .add 1, "Add publication years to improve temporal analysis"
            End If
            If tagCount < 3 Then
                .add 2, "Increase topic diversity for broader coverage"
            End If
        End With
    End With
    
    outputData = outputJSON.JSONoutput()
    
    ' Salvar output com Dublin Core
    If SaveFTAMethodOutput(stepID, outputData, "bibliometric_analysis", 0) Then
        ' Redirecionar para finalização normal
        Response.Write "<script>"
        Response.Write "alert('Bibliometric analysis saved with Dublin Core metadata!');"
        Response.Write "window.location.href='/workflowActions.asp?action=end&stepID=" & stepID & "';"
        Response.Write "</script>"
    Else
        ' Se falhou, prosseguir com finalização normal
        Response.Write "<script>"
        Response.Write "alert('Analysis completed. Proceeding to finish step.');"
        Response.Write "window.location.href='/workflowActions.asp?action=end&stepID=" & stepID & "';"
        Response.Write "</script>"
    End If
    
    ' Limpeza
    Set outputJSON = Nothing
    
    On Error Goto 0
End Sub

render.renderFooter()
%>