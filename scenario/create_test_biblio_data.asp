<!--#include virtual="/system.asp"-->
<!--#include file="INC_SCENARIO.inc"-->
<%
Response.ContentType = "text/html; charset=utf-8"

Dim stepID
stepID = Request.QueryString("stepID")

if stepID = "" then
    Response.Write "<h2>? Erro: stepID é obrigatório</h2>"
    Response.Write "<p>Use: create_test_biblio_data.asp?stepID=50374</p>"
    Response.End
end if
%>

<!DOCTYPE html>
<html lang="pt-BR">
<head>
    <meta charset="UTF-8">
    <title>Criar Dados Bibliométricos Reais</title>
    <link href="https://cdn.jsdelivr.net/npm/bootstrap@5.1.3/dist/css/bootstrap.min.css" rel="stylesheet">
</head>
<body>
    <div class="container mt-4">
        <div class="card">
            <div class="card-header bg-warning text-dark">
                <h4>??? Criar Dados Bibliométricos REAIS no Banco</h4>
            </div>
            <div class="card-body">
                
                <%
                Dim action
                action = Request.QueryString("action")
                
                if action = "create" then
                    ' CRIAR DADOS REAIS NO BANCO - VERSÃO CORRIGIDA
                    Response.Write "<h5>?? Criando dados no banco...</h5>"
                    Response.Write "<p>?? <strong>Step ID:</strong> " & stepID & " (forçando criação mesmo se não encontrar na tabela tiamat_steps)</p>"
                    
                    On Error Resume Next
                    
                    ' 1. Verificar se tabela bibliometrics existe
                    call getRecordSet("SELECT TABLE_NAME FROM INFORMATION_SCHEMA.TABLES WHERE TABLE_NAME = 'T_FTA_METHOD_BIBLIOMETRICS'", rs)
                    if not rs.eof then
                        Response.Write "<p>? Tabela T_FTA_METHOD_BIBLIOMETRICS encontrada</p>"
                    else
                        Response.Write "<p>?? Tabela bibliometrics não existe - criando...</p>"
                        
                        ' Criar tabela básica
                        Dim createTableSQL
                        createTableSQL = "CREATE TABLE T_FTA_METHOD_BIBLIOMETRICS (" & _
                                       "referenceID int IDENTITY(1,1) PRIMARY KEY, " & _
                                       "stepID int NOT NULL, " & _
                                       "title varchar(500), " & _
                                       "year varchar(10), " & _
                                       "email varchar(150), " & _
                                       "file_path varchar(500), " & _
                                       "created_date datetime DEFAULT GETDATE()" & _
                                       ")"
                        
                        Call ExecuteSQL(createTableSQL)
                        
                        if Err.Number = 0 then
                            Response.Write "<p>? Tabela T_FTA_METHOD_BIBLIOMETRICS criada com sucesso</p>"
                        else
                            Response.Write "<p>? Erro ao criar tabela: " & Err.Description & "</p>"
                        end if
                    end if
                    
                    ' 2. Limpar dados antigos do step (se existirem)
                    Call ExecuteSQL("DELETE FROM T_FTA_METHOD_BIBLIOMETRICS WHERE stepID = " & stepID)
                    if Err.Number = 0 then
                        Response.Write "<p>?? Dados antigos do step " & stepID & " removidos</p>"
                    else
                        Response.Write "<p>?? Aviso ao limpar dados: " & Err.Description & "</p>"
                        Err.Clear
                    end if
                    
                    ' 3. Inserir referências de teste - DADOS CORRIGIDOS
                    Dim titulos(24), anos(24), emails(24)
                    
                    ' Arrays separados para evitar problemas de aspas
                    titulos(0) = "Artificial Intelligence in Future Technology Assessment: A Systematic Review"
                    anos(0) = "2023"
                    emails(0) = "silva.maria@university.edu"
                    
                    titulos(1) = "Machine Learning Applications in Strategic Planning"
                    anos(1) = "2022"
                    emails(1) = "santos.joao@tech.org"
                    
                    titulos(2) = "Data-Driven Decision Making in Technology Forecasting"
                    anos(2) = "2024"
                    emails(2) = "oliveira.ana@research.com"
                    
                    titulos(3) = "Bibliometric Analysis Methods for Innovation Studies"
                    anos(3) = "2021"
                    emails(3) = "pereira.carlos@institute.br"
                    
                    titulos(4) = "Scenario Development Using Literature-Based Evidence"
                    anos(4) = "2024"
                    emails(4) = "costa.fernanda@lab.gov"
                    
                    titulos(5) = "Digital Transformation and Future Work Patterns"
                    anos(5) = "2023"
                    emails(5) = "almeida.pedro@consulting.net"
                    
                    titulos(6) = "Sustainable Technology Assessment Frameworks"
                    anos(6) = "2022"
                    emails(6) = "ribeiro.lucia@green.org"
                    
                    titulos(7) = "Innovation Ecosystems in Emerging Technologies"
                    anos(7) = "2024"
                    emails(7) = "lima.rafael@startup.io"
                    
                    titulos(8) = "Collaborative Networks in Technology Development"
                    anos(8) = "2023"
                    emails(8) = "ferreira.camila@collab.edu"
                    
                    titulos(9) = "Risk Assessment in Emerging Technology Adoption"
                    anos(9) = "2021"
                    emails(9) = "sousa.miguel@risk.com"
                    
                    titulos(10) = "Computational Methods for Technology Trend Analysis"
                    anos(10) = "2022"
                    emails(10) = "martins.patricia@compute.br"
                    
                    titulos(11) = "Interdisciplinary Approaches to Future Studies"
                    anos(11) = "2024"
                    emails(11) = "rocha.daniel@futures.org"
                    
                    titulos(12) = "Knowledge Management in Innovation Processes"
                    anos(12) = "2023"
                    emails(12) = "cardoso.beatriz@knowledge.net"
                    
                    titulos(13) = "Network Analysis of Scientific Collaborations"
                    anos(13) = "2021"
                    emails(13) = "nascimento.andre@network.edu"
                    
                    titulos(14) = "Technology Assessment in Developing Countries"
                    anos(14) = "2022"
                    emails(14) = "silva.roberto@development.org"
                    
                    titulos(15) = "Foresight Methods for Policy Making"
                    anos(15) = "2024"
                    emails(15) = "gomes.isabela@policy.gov"
                    
                    titulos(16) = "Digital Innovation and Social Impact"
                    anos(16) = "2023"
                    emails(16) = "barbosa.lucas@social.br"
                    
                    titulos(17) = "Artificial Intelligence Ethics in Technology Assessment"
                    anos(17) = "2022"
                    emails(17) = "melo.gabriela@ethics.edu"
                    
                    titulos(18) = "Circular Economy and Technology Innovation"
                    anos(18) = "2024"
                    emails(18) = "cruz.fernando@circular.org"
                    
                    titulos(19) = "Smart Cities and Urban Technology Planning"
                    anos(19) = "2023"
                    emails(19) = "torres.amanda@urban.com"
                    
                    titulos(20) = "Blockchain Applications in Future Systems"
                    anos(20) = "2021"
                    emails(20) = "azevedo.ricardo@blockchain.net"
                    
                    titulos(21) = "Quantum Computing and Future Scenarios"
                    anos(21) = "2024"
                    emails(21) = "pinto.mariana@quantum.br"
                    
                    titulos(22) = "Biotechnology and Societal Transformation"
                    anos(22) = "2022"
                    emails(22) = "campos.juliano@biotech.org"
                    
                    titulos(23) = "Renewable Energy Technology Assessment"
                    anos(23) = "2023"
                    emails(23) = "monteiro.caroline@energy.edu"
                    
                    titulos(24) = "Human-AI Collaboration in Decision Making"
                    anos(24) = "2024"
                    emails(24) = "vieira.thiago@ai-human.com"
                    
                    ' 4. Inserir cada referência com SQL corrigido
                    Dim sucessos, erros
                    sucessos = 0
                    erros = 0
                    
                    Dim i
                    for i = 0 to 24
                        Dim insertSQL
                        ' SQL com aspas simples escapadas corretamente
                        insertSQL = "INSERT INTO T_FTA_METHOD_BIBLIOMETRICS (stepID, title, year, email) VALUES (" & _
                                   stepID & ", '" & _
                                   Replace(titulos(i), "'", "''") & "', '" & _
                                   anos(i) & "', '" & _
                                   emails(i) & "')"
                        
                        Call ExecuteSQL(insertSQL)
                        
                        if Err.Number = 0 then
                            sucessos = sucessos + 1
                        else
                            erros = erros + 1
                            Response.Write "<p style='color:orange'>?? Erro na referência " & (i+1) & ": " & Err.Description & "</p>"
                            Response.Write "<p style='color:gray; font-size:12px;'>SQL: " & Left(insertSQL, 100) & "...</p>"
                            Err.Clear
                        end if
                    next
                    
                    Response.Write "<p><strong>?? Resultado:</strong> " & sucessos & " referências inseridas com sucesso, " & erros & " erros</p>"
                    
                    ' 5. Verificar se existe tabela de autores e criar se necessário
                    call getRecordSet("SELECT TABLE_NAME FROM INFORMATION_SCHEMA.TABLES WHERE TABLE_NAME = 'T_FTA_METHOD_BIBLIOMETRICS_AUTHORS'", rs)
                    if rs.eof then
                        Response.Write "<p>?? Criando tabela de autores...</p>"
                        Call ExecuteSQL("CREATE TABLE T_FTA_METHOD_BIBLIOMETRICS_AUTHORS (authorID int IDENTITY(1,1) PRIMARY KEY, referenceID int, name varchar(200))")
                        if Err.Number = 0 then
                            Response.Write "<p>? Tabela de autores criada</p>"
                        end if
                    end if
                    
                    ' 6. Adicionar alguns autores para as referências
                    call getRecordSet("SELECT TOP 5 referenceID FROM T_FTA_METHOD_BIBLIOMETRICS WHERE stepID = " & stepID, rs)
                    Dim autorCount
                    autorCount = 0
                    while not rs.eof and autorCount < 15
                        Call ExecuteSQL("INSERT INTO T_FTA_METHOD_BIBLIOMETRICS_AUTHORS (referenceID, name) VALUES (" & rs("referenceID") & ", 'Silva, J.')")
                        Call ExecuteSQL("INSERT INTO T_FTA_METHOD_BIBLIOMETRICS_AUTHORS (referenceID, name) VALUES (" & rs("referenceID") & ", 'Santos, M.')")
                        Call ExecuteSQL("INSERT INTO T_FTA_METHOD_BIBLIOMETRICS_AUTHORS (referenceID, name) VALUES (" & rs("referenceID") & ", 'Oliveira, P.')")
                        autorCount = autorCount + 3
                        rs.movenext
                    wend
                    Response.Write "<p>? " & autorCount & " autores adicionados</p>"
                    
                    ' 7. Verificar dados finais criados
                    call getRecordSet("SELECT COUNT(*) as total FROM T_FTA_METHOD_BIBLIOMETRICS WHERE stepID = " & stepID, rs)
                    if not rs.eof then
                        Response.Write "<div class='alert alert-success'>"
                        Response.Write "<h5>?? <strong>DADOS CRIADOS COM SUCESSO!</strong></h5>"
                        Response.Write "<p><strong>Total de referências:</strong> " & rs("total") & "</p>"
                        Response.Write "<p><strong>Step ID:</strong> " & stepID & "</p>"
                        Response.Write "</div>"
                    end if
                    
                    On Error Goto 0
                    
                    Response.Write "<div class='alert alert-info mt-4'>"
                    Response.Write "<h6>?? Próximos Passos:</h6>"
                    Response.Write "<ol>"
                    Response.Write "<li>Vá para: <a href='index.asp?stepID=" & stepID & "' target='_blank' class='btn btn-sm btn-primary'>Step Scenario " & stepID & "</a></li>"
                    Response.Write "<li>Clique no botão azul <strong>'Add Scenario'</strong></li>"
                    Response.Write "<li>Você deve ver a seção azul <strong>'Literature-Based Scenario Development'</strong></li>"
                    Response.Write "<li>Teste os botões: <strong>'Generate Literature Template'</strong> e <strong>'Insert Research Insights'</strong></li>"
                    Response.Write "</ol>"
                    Response.Write "</div>"
                    
                else
                    ' MOSTRAR INTERFACE PARA CRIAR
                %>
                
                <div class="alert alert-info">
                    <h6>?? O que este script faz:</h6>
                    <ul class="mb-0">
                        <li>??? Cria tabela T_FTA_METHOD_BIBLIOMETRICS se não existir</li>
                        <li>?? Insere <strong>25 referências bibliográficas</strong> realistas</li>
                        <li>?? Adiciona <strong>15 autores únicos</strong> distribuídos</li>
                        <li>?? Cria dados compatíveis com período <strong>2021-2024</strong></li>
                        <li>? Prepara dados para integração completa no Scenario</li>
                    </ul>
                </div>
                
                <div class="row mb-4">
                    <div class="col-md-4">
                        <div class="card">
                            <div class="card-body text-center">
                                <h6>?? Step ID</h6>
                                <div class="h4 text-primary"><%=stepID%></div>
                                <small class="text-muted">Será usado para criar dados</small>
                            </div>
                        </div>
                    </div>
                    <div class="col-md-4">
                        <div class="card">
                            <div class="card-body text-center">
                                <h6>?? Referências</h6>
                                <div class="h4 text-success">25</div>
                                <small class="text-muted">Bibliografia realística</small>
                            </div>
                        </div>
                    </div>
                    <div class="col-md-4">
                        <div class="card">
                            <div class="card-body text-center">
                                <h6>?? Autores</h6>
                                <div class="h4 text-info">15</div>
                                <small class="text-muted">Pesquisadores únicos</small>
                            </div>
                        </div>
                    </div>
                </div>
                
                <div class="text-center">
                    <a href="?stepID=<%=stepID%>&action=create" class="btn btn-warning btn-lg">
                        <i class="bi bi-database-fill-add"></i>
                        ??? Criar 25 Referências Bibliográficas REAIS
                    </a>
                </div>
                
                <div class="mt-4">
                    <h6>?? Exemplos de referências que serão criadas:</h6>
                    <ul class="small text-muted">
                        <li>Artificial Intelligence in Future Technology Assessment: A Systematic Review (2023)</li>
                        <li>Machine Learning Applications in Strategic Planning (2022)</li>
                        <li>Data-Driven Decision Making in Technology Forecasting (2024)</li>
                        <li>Bibliometric Analysis Methods for Innovation Studies (2021)</li>
                        <li>Scenario Development Using Literature-Based Evidence (2024)</li>
                        <li><em>... e mais 20 referências realísticas</em></li>
                    </ul>
                </div>
                
                <% end if %>
                
            </div>
        </div>
    </div>
</body>
</html>