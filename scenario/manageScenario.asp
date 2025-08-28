<!--#include virtual="/system.asp"-->
<!--#include virtual="/checkstep.asp"-->
<!--#include file="INC_SCENARIO.inc"-->
<%
saveCurrentURL
tiamat.addJS("/js/tinymce/tinymce.min.js")
render.renderToBody()
%>

<%
' Variaveis basicas
Dim disabled, action, name, description, scenario
Dim currentStepID, scenarioID

currentStepID = request.querystring("stepID")
scenarioID = request.querystring("scenarioID")
disabled = ""
name = ""
description = ""
scenario = ""

' Verificar status do step
if getStatusStep(currentStepID) = STATE_ACTIVE then 
    if scenarioID = "" then
        action = "add"
    else
        action = "edit"
    end if
else 
    disabled = "disabled"
    action = "view"
end if

' Se for edicao, buscar dados
if scenarioID <> "" then
    call getRecordSet(SQL_CONSULTA_SCENARIOS_BY_SCENARIO_ID(scenarioID), rs)
    if not rs.eof then
        name = rs("name") & ""
        description = rs("description") & ""
        scenario = rs("scenario") & ""
    end if
end if

' Buscar dados Dublin Core
Dim hasData, totalRefs, biblioStepID
Dim dcTitles, dcCreators, dcDates
hasData = false
totalRefs = 0
biblioStepID = ""
dcTitles = ""
dcCreators = ""
dcDates = ""

' String para armazenar todas as referencias formatadas
Dim allReferencesJS
allReferencesJS = ""

' Buscar step com bibliometrics
call getRecordSet("SELECT TOP 1 stepID FROM T_FTA_METHOD_BIBLIOMETRICS WHERE stepID < " & currentStepID & " ORDER BY stepID DESC", rs)

if not rs.eof then
    biblioStepID = rs("stepID")
    
    ' Contar referencias
    call getRecordSet("SELECT COUNT(*) as total FROM T_FTA_METHOD_BIBLIOMETRICS WHERE stepID = " & biblioStepID, rs)
    if not rs.eof then
        totalRefs = rs("total")
        hasData = (totalRefs > 0)
    end if
    
    if hasData then
        ' BUSCAR TODAS AS REFERENCIAS
        call getRecordSet("SELECT referenceID, title, year FROM T_FTA_METHOD_BIBLIOMETRICS WHERE stepID = " & biblioStepID & " ORDER BY year DESC, title", rs)
        
        Dim refIndex
        refIndex = 1
        
        while not rs.eof
            Dim currentRefID, currentTitle, currentYear, currentAuthors
            currentRefID = rs("referenceID")
            currentTitle = rs("title") & ""
            currentYear = rs("year") & ""
            currentAuthors = ""
            
            ' Buscar autores desta referencia
            call getRecordSet("SELECT name FROM T_FTA_METHOD_BIBLIOMETRICS_AUTHORS WHERE referenceID = " & currentRefID & " ORDER BY authorID", rs2)
            
            while not rs2.eof
                if currentAuthors <> "" then currentAuthors = currentAuthors & ", "
                currentAuthors = currentAuthors & rs2("name")
                
                ' Adicionar autor unico na lista geral
                If InStr(1, dcCreators, rs2("name"), 1) = 0 Then
                    if dcCreators <> "" then dcCreators = dcCreators & ", "
                    dcCreators = dcCreators & rs2("name")
                End If
                
                rs2.movenext
            wend
            
            ' Escapar caracteres para JavaScript
            currentTitle = Replace(currentTitle, "\", "\\")
            currentTitle = Replace(currentTitle, """", "'")
            currentTitle = Replace(currentTitle, vbCr, "")
            currentTitle = Replace(currentTitle, vbLf, "")
            currentTitle = Replace(currentTitle, vbTab, " ")
            
            currentAuthors = Replace(currentAuthors, "\", "\\")
            currentAuthors = Replace(currentAuthors, """", "'")
            currentAuthors = Replace(currentAuthors, vbCr, "")
            currentAuthors = Replace(currentAuthors, vbLf, "")
            
            ' Adicionar ao JavaScript
            allReferencesJS = allReferencesJS & "texto += """ & refIndex & ". " & currentTitle & " (" & currentYear & ")"";" & vbCrLf
            If currentAuthors <> "" Then
                allReferencesJS = allReferencesJS & "texto += ""\n   Autores: " & currentAuthors & """;" & vbCrLf
            End If
            allReferencesJS = allReferencesJS & "texto += ""\n"";" & vbCrLf
            
            ' Adicionar titulo na lista
            if dcTitles <> "" then dcTitles = dcTitles & " | "
            dcTitles = dcTitles & Left(currentTitle, 50)
            If Len(currentTitle) > 50 Then dcTitles = dcTitles & "..."
            
            refIndex = refIndex + 1
            rs.movenext
        wend
        
        ' BUSCAR ANOS
        call getRecordSet("SELECT MIN(year) as min_year, MAX(year) as max_year FROM T_FTA_METHOD_BIBLIOMETRICS WHERE stepID = " & biblioStepID & " AND year IS NOT NULL", rs)
        if not rs.eof then
            if rs("min_year") & "" = rs("max_year") & "" then
                dcDates = rs("min_year") & ""
            else
                dcDates = rs("min_year") & "-" & rs("max_year")
            end if
        end if
    end if
end if
%>

<!-- FUNÇÃO JAVASCRIPT -->
<script type="text/javascript">
window.inserirTemplateDC = function() {
    console.log('Inserindo template...');
    
    try {
        var campo = document.getElementById('scenario');
        if (!campo) {
            alert('Campo scenario não encontrado!');
            return;
        }
        
        var texto = "";
        texto += "=== CENÁRIO BASEADO EM ANÁLISE BIBLIOMÉTRICA ===\n\n";
        texto += "Este cenário foi desenvolvido com base em <%=totalRefs%> referências bibliográficas\n";
        texto += "coletadas no step <%=biblioStepID%> do workflow.\n\n";
        
        <% If allReferencesJS <> "" Then %>
        texto += "=== PUBLICAÇÕES ANALISADAS (dc:title) ===\n";
        <%=allReferencesJS%>
        texto += "\n";
        <% End If %>
        
        <% If dcCreators <> "" Then %>
        texto += "=== AUTORES/PESQUISADORES (dc:creator) ===\n";
        <%
        Dim safeCreators
        safeCreators = Replace(dcCreators, "\", "\\")
        safeCreators = Replace(safeCreators, """", "'")
        safeCreators = Replace(safeCreators, vbCr, "")
        safeCreators = Replace(safeCreators, vbLf, "")
        %>
        texto += "<%=safeCreators%>\n\n";
        <% End If %>
        
        <% If dcDates <> "" Then %>
        texto += "=== PERÍODO TEMPORAL (dc:date) ===\n";
        texto += "Período: <%=dcDates%>\n\n";
        <% End If %>
        
        texto += "=== DESCRIÇÃO DO CENÁRIO ===\n\n";
        texto += "Com base nas <%=totalRefs%> referências analisadas:\n\n";
        texto += "[Desenvolva aqui o cenário futuro]\n\n";
        
        texto += "=== DRIVERS DE MUDANÇA ===\n\n";
        texto += "1. [Driver tecnológico]\n";
        texto += "2. [Driver econômico]\n";
        texto += "3. [Driver ambiental]\n\n";
        
        texto += "=== PROJEÇÕES ===\n\n";
        texto += "CURTO PRAZO (1-2 anos):\n";
        texto += "• [Tendências]\n\n";
        
        texto += "MÉDIO PRAZO (3-5 anos):\n";
        texto += "• [Evolução]\n\n";
        
        texto += "LONGO PRAZO (5+ anos):\n";
        texto += "• [Transformação]\n\n";
        
        texto += "=== INCERTEZAS ===\n\n";
        texto += "• [Incerteza 1]\n";
        texto += "• [Incerteza 2]\n\n";
        
        texto += "=== CONCLUSÃO ===\n\n";
        texto += "[Síntese do cenário]";
        
        campo.value = texto;
        alert('Template inserido com sucesso!');
        
    } catch(e) {
        alert('Erro: ' + e.message);
        console.error('Erro:', e);
    }
};

console.log('Template function loaded');
</script>

<div class="p-3">

<% if hasData and action = "add" then %>
<div class="card mb-4 border-primary">
    <div class="card-header bg-primary text-white">
        <h5 class="mb-0">
            <i class="bi bi-database me-2"></i>
            Dados Dublin Core Disponíveis
        </h5>
        <small><%=totalRefs%> referências bibliográficas do step <%=biblioStepID%></small>
    </div>
    <div class="card-body">
        <table class="table table-sm table-bordered">
            <tr>
                <td width="130"><strong>Referências</strong></td>
                <td><small><%=totalRefs%> publicações identificadas</small></td>
            </tr>
            <% if dcCreators <> "" then %>
            <tr>
                <td><strong>Autores</strong></td>
                <td><small><%=Left(dcCreators, 150)%><% If Len(dcCreators) > 150 Then %>...<%End If%></small></td>
            </tr>
            <% end if %>
            <% if dcDates <> "" then %>
            <tr>
                <td><strong>Período</strong></td>
                <td><small><%=dcDates%></small></td>
            </tr>
            <% end if %>
        </table>
        
        <button type="button" 
                class="btn btn-primary btn-sm"
                onclick="window.inserirTemplateDC();">
            <i class="bi bi-file-text me-1"></i>
            Inserir Template com Dados
        </button>
    </div>
</div>
<% end if %>

<form action="scenarioActions.asp" method="POST" id="frmScenario">
    <input type="hidden" name="action" value="save">
    <input type="hidden" name="scenarioID" value="<%=scenarioID%>">
    <input type="hidden" name="stepID" value="<%=currentStepID%>">

    <div class="mb-3">
        <label for="name" class="form-label fw-bold">Nome do Cenário</label>
        <input type="text" class="form-control" id="name" name="name" value="<%=name%>" <%=disabled%>> 
    </div>

    <div class="mb-3">
        <label for="scenario" class="form-label fw-bold">Descrição do Cenário</label>
        <textarea id="scenario" name="scenario" class="form-control" rows="12" <%=disabled%>><%=scenario%></textarea>
    </div>

    <div class="d-flex justify-content-between">
        <button type="button" 
                class="btn btn-secondary"
                onclick="window.location.href='index.asp?stepID=<%=currentStepID%>';">
            Cancelar
        </button>
        
        <% if disabled = "" then %>
        <button type="submit" class="btn btn-primary">
            Salvar
        </button>
        <% end if %>
    </div>
</form>

</div>

<%
render.renderFromBody()
%>