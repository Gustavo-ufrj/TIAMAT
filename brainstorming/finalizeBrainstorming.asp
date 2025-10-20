<!--#include virtual="/system.asp"-->
<!--#include file="INC_BRAINSTORMING.inc"-->

<%
Dim action, stepID
action = Request.QueryString("action")
stepID = Request.QueryString("stepID")

If action = "finalize" Then
    ' Finalizar o brainstorming
    If stepID <> "" Then
        Dim rs, brainstormingID, ideaCount, topIdeas
        
        ' Buscar o brainstorming
        Call getRecordSet("SELECT brainstormingID, description FROM T_FTA_METHOD_BRAINSTORMING WHERE stepID = " & stepID, rs)
        If Not rs.EOF Then
            brainstormingID = rs("brainstormingID")
            Dim brainstormingDesc
            brainstormingDesc = rs("description")
            
            ' Contar todas as ideias
            Call getRecordSet("SELECT COUNT(*) as total FROM T_FTA_METHOD_BRAINSTORMING_IDEAS WHERE brainstormingID = " & brainstormingID, rs)
            If Not rs.EOF Then
                ideaCount = rs("total")
            Else
                ideaCount = 0
            End If
            
            ' CORRIGIDO: Limpar registros antigos do Dublin Core para este step
            On Error Resume Next
            Call ExecuteSQL("DELETE FROM tiamat_dublin_core WHERE stepID = " & stepID)
            If Err.Number <> 0 Then
                Response.Write "<!-- Erro ao limpar Dublin Core: " & Err.Description & " -->"
                Err.Clear
            End If
            On Error GoTo 0
            
            ' CORRIGIDO: Salvar TODAS as ideias no Dublin Core
            Call getRecordSet("SELECT i.*, " & _
                             "(SELECT COUNT(*) FROM T_FTA_METHOD_BRAINSTORMING_VOTING v WHERE v.ideaID = i.ideaID) as votes " & _
                             "FROM T_FTA_METHOD_BRAINSTORMING_IDEAS i " & _
                             "WHERE i.brainstormingID = " & brainstormingID & " " & _
                             "ORDER BY votes DESC", rs)
            
            Dim ideaNum, totalSaved
            ideaNum = 1
            totalSaved = 0
            
            While Not rs.EOF
                ' Preparar dados para inserção - ESCAPAR ASPAS CORRETAMENTE
                Dim ideaTitle, ideaDesc, ideaAuthor, ideaVotes, sqlInsert
                ideaTitle = Replace(rs("title"), "'", "''")
                ideaDesc = Replace(rs("description"), "'", "''")
                ideaAuthor = Replace(rs("email"), "'", "''")
                ideaVotes = rs("votes")
                
                ' CORRIGIDO: SQL mais simples e robusto
                sqlInsert = "INSERT INTO tiamat_dublin_core " & _
                           "(stepID, dc_title, dc_creator, dc_subject, dc_description, " & _
                           "dc_publisher, dc_date, dc_type, dc_format, " & _
                           "dc_identifier, dc_source, dc_language, dc_relation, dc_coverage, dc_rights) " & _
                           "VALUES (" & stepID & ", " & _
                           "'" & ideaTitle & "', " & _
                           "'" & ideaAuthor & "', " & _
                           "'brainstorming_idea', " & _
                           "'" & ideaDesc & " [Votos: " & ideaVotes & "]', " & _
                           "'TIAMAT', " & _
                           "GETDATE(), " & _
                           "'brainstorming', " & _
                           "'idea', " & _
                           "'IDEA_" & rs("ideaID") & "', " & _
                           "'Brainstorming Step " & stepID & "', " & _
                           "'pt-BR', " & _
                           "'Ranking: " & ideaNum & "', " & _
                           "'Workflow', " & _
                           "'Public')"
                
                ' Executar inserção com tratamento de erro individual
                On Error Resume Next
                Call ExecuteSQL(sqlInsert)
                
                If Err.Number = 0 Then
                    totalSaved = totalSaved + 1
                    Response.Write "<!-- Ideia " & ideaNum & " salva com sucesso -->" & vbCrLf
                Else
                    Response.Write "<!-- ERRO ao salvar ideia " & rs("ideaID") & ": " & Err.Description & " -->" & vbCrLf
                    Response.Write "<!-- SQL: " & sqlInsert & " -->" & vbCrLf
                End If
                Err.Clear
                On Error GoTo 0
                
                ideaNum = ideaNum + 1
                rs.MoveNext()
            Wend
            
            ' CORRIGIDO: Salvar resumo geral do brainstorming
            Dim summarySQL
            summarySQL = "INSERT INTO tiamat_dublin_core " & _
                        "(stepID, dc_title, dc_creator, dc_subject, dc_description, " & _
                        "dc_publisher, dc_date, dc_type, dc_format, " & _
                        "dc_identifier, dc_source, dc_language, dc_relation, dc_coverage, dc_rights) " & _
                        "VALUES (" & stepID & ", " & _
                        "'Brainstorming Session Summary', " & _
                        "'System', " & _
                        "'brainstorming_summary', " & _
                        "'Total de " & ideaCount & " ideias geradas. " & Replace(brainstormingDesc, "'", "''") & "', " & _
                        "'TIAMAT', " & _
                        "GETDATE(), " & _
                        "'brainstorming', " & _
                        "'summary', " & _
                        "'SUMMARY_" & brainstormingID & "', " & _
                        "'Brainstorming Step " & stepID & "', " & _
                        "'pt-BR', " & _
                        "'Step " & stepID & "', " & _
                        "'Workflow', " & _
                        "'Public')"
            
            On Error Resume Next
            Call ExecuteSQL(summarySQL)
            If Err.Number = 0 Then
                totalSaved = totalSaved + 1
                Response.Write "<!-- Resumo salvo com sucesso -->" & vbCrLf
            Else
                Response.Write "<!-- ERRO ao salvar resumo: " & Err.Description & " -->" & vbCrLf
            End If
            Err.Clear
            On Error GoTo 0
            
            ' CORRIGIDO: Registrar relacionamento entre steps
            On Error Resume Next
            
            ' Buscar o próximo step ID (Futures Wheel ou outro método)
            Dim nextStepID
            Call getRecordSet("SELECT TOP 1 stepID FROM T_WORKFLOW_STEP " & _
                             "WHERE workflowID = (SELECT workflowID FROM T_WORKFLOW_STEP WHERE stepID = " & stepID & ") " & _
                             "AND stepID > " & stepID & " " & _
                             "ORDER BY stepID", rs)
            
            If Not rs.EOF Then
                nextStepID = rs("stepID")
                
                ' Verificar se a tabela de relacionamentos existe
                Call getRecordSet("SELECT COUNT(*) as existe FROM sysobjects WHERE name='tiamat_step_relationships' AND xtype='U'", rs)
                If Not rs.EOF And rs("existe") > 0 Then
                    ' Registrar relacionamento
                    Call ExecuteSQL("INSERT INTO tiamat_step_relationships (stepID, parentStepID, relationship_type) " & _
                                   "VALUES (" & nextStepID & ", " & stepID & ", 'brainstorming_source')")
                    Response.Write "<!-- Relacionamento registrado: " & nextStepID & " <- " & stepID & " -->" & vbCrLf
                End If
            End If
            On Error GoTo 0
        End If
        
        ' CORRIGIDO: Finalizar o step (já estava finalizado, mas garantir)
        Call endStep(stepID)
        
        ' CORRIGIDO: Redirecionar com mensagem de sucesso mais informativa
        Session("futuresWheelSuccess") = "Brainstorming finalizado com sucesso! " & totalSaved & " registros foram salvos no Dublin Core (de " & ideaCount & " ideias + resumo)."
        Response.Redirect "/workplace.asp"
    End If
    
ElseIf action = "report" Then
    ' Código do relatório permanece o mesmo
    render.renderTitle()
%>
    <style>
    .report-container {
        max-width: 1000px;
        margin: 20px auto;
        padding: 20px;
        background: white;
    }
    
    .report-header {
        text-align: center;
        margin-bottom: 30px;
        padding-bottom: 20px;
        border-bottom: 2px solid #333;
    }
    
    .report-section {
        margin-bottom: 30px;
    }
    
    .report-section h3 {
        color: #2c3e50;
        border-bottom: 1px solid #ddd;
        padding-bottom: 10px;
        margin-bottom: 15px;
    }
    
    .idea-report {
        background: #f8f9fa;
        padding: 15px;
        margin-bottom: 10px;
        border-left: 3px solid #337ab7;
    }
    
    .stats-grid {
        display: grid;
        grid-template-columns: repeat(3, 1fr);
        gap: 20px;
        margin: 20px 0;
    }
    
    .stat-box {
        text-align: center;
        padding: 20px;
        background: #f8f9fa;
        border-radius: 5px;
    }
    
    .stat-number {
        font-size: 2em;
        font-weight: bold;
        color: #337ab7;
    }
    
    .dublin-core-section {
        background: #d4edda;
        padding: 20px;
        border-radius: 10px;
        margin-top: 30px;
    }
    
    .no-print {
        margin: 20px 0;
        text-align: center;
    }
    
    @media print {
        .no-print {
            display: none;
        }
    }
    </style>
    
    <div class="report-container">
        <div class="no-print">
            <button onclick="window.print()" class="btn btn-primary">Imprimir Relatório</button>
            <button onclick="window.location.href='index.asp?stepID=<%=stepID%>'" class="btn btn-secondary">Voltar</button>
        </div>
        
        <div class="report-header">
            <h1>Relatório de Brainstorming</h1>
            <p>Data: <%=FormatDateTime(Now(), 1)%></p>
            <p>Step ID: <%=stepID%></p>
        </div>
        
        <%
        Dim totalIdeas, totalVotes, totalParticipants
        
        Call getRecordSet("SELECT * FROM T_FTA_METHOD_BRAINSTORMING WHERE stepID = " & stepID, rs)
        If Not rs.EOF Then
            brainstormingID = rs("brainstormingID")
            
            ' Estatísticas
            Call getRecordSet("SELECT COUNT(*) as total FROM T_FTA_METHOD_BRAINSTORMING_IDEAS WHERE brainstormingID = " & brainstormingID, rs)
            totalIdeas = rs("total")
            
            Call getRecordSet("SELECT COUNT(*) as total FROM T_FTA_METHOD_BRAINSTORMING_VOTING v " & _
                             "INNER JOIN T_FTA_METHOD_BRAINSTORMING_IDEAS i ON v.ideaID = i.ideaID " & _
                             "WHERE i.brainstormingID = " & brainstormingID, rs)
            totalVotes = rs("total")
            
            Call getRecordSet("SELECT COUNT(DISTINCT email) as total FROM T_FTA_METHOD_BRAINSTORMING_IDEAS WHERE brainstormingID = " & brainstormingID, rs)
            totalParticipants = rs("total")
        %>
        
        <div class="report-section">
            <h3>Estatísticas Gerais</h3>
            <div class="stats-grid">
                <div class="stat-box">
                    <div class="stat-number"><%=totalIdeas%></div>
                    <div>Ideias Geradas</div>
                </div>
                <div class="stat-box">
                    <div class="stat-number"><%=totalVotes%></div>
                    <div>Votos Totais</div>
                </div>
                <div class="stat-box">
                    <div class="stat-number"><%=totalParticipants%></div>
                    <div>Participantes</div>
                </div>
            </div>
        </div>
        
        <div class="report-section">
            <h3>Todas as Ideias (Por Votação)</h3>
            <%
            Call getRecordSet("SELECT i.*, " & _
                             "(SELECT COUNT(*) FROM T_FTA_METHOD_BRAINSTORMING_VOTING v WHERE v.ideaID = i.ideaID) as votes " & _
                             "FROM T_FTA_METHOD_BRAINSTORMING_IDEAS i " & _
                             "WHERE i.brainstormingID = " & brainstormingID & " " & _
                             "ORDER BY votes DESC, i.dateTime DESC", rs)
            
            Dim rank
            rank = 1
            While Not rs.EOF
            %>
                <div class="idea-report">
                    <h4><%=rank%>. <%=rs("title")%> (<%=rs("votes")%> votos)</h4>
                    <p><%=rs("description")%></p>
                    <small>
                        Proposto por: <%=rs("email")%> | 
                        Status: <%
                        Select Case rs("status")
                            Case 1: Response.Write "Nova Ideia"
                            Case 2: Response.Write "Em Discussão"
                            Case 3: Response.Write "Votação"
                        End Select
                        %>
                    </small>
                </div>
            <%
                rank = rank + 1
                rs.MoveNext()
            Wend
            %>
        </div>
        
        <div class="dublin-core-section">
            <h3>Dados Salvos no Dublin Core</h3>
            <%
            ' Verificar quantos registros foram salvos
            Dim dcCount
            Call getRecordSet("SELECT COUNT(*) as total FROM tiamat_dublin_core WHERE stepID = " & stepID, rs)
            If Not rs.EOF Then
                dcCount = rs("total")
            Else
                dcCount = 0
            End If
            %>
            <p>Os dados foram salvos com sucesso no repositório Dublin Core:</p>
            <ul>
                <li><strong>Registros salvos:</strong> <%=dcCount%></li>
                <li><strong>Step ID:</strong> <%=stepID%></li>
                <li><strong>Tabela:</strong> tiamat_dublin_core</li>
                <li><strong>Disponível para:</strong> Futures Wheel e outros métodos FTA subsequentes</li>
            </ul>
            <p style="margin-top: 15px;">
                <em>Dica: No Futures Wheel, clique em "View DC Data" para acessar estas ideias e usá-las como eventos.</em>
            </p>
        </div>
        
        <%
        End If
        %>
    </div>
<%
    render.renderFooter()
End If
%>