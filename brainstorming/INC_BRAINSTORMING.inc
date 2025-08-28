<%
'==================================================
' INC_BRAINSTORMING.inc
' Funcoes SQL e Dublin Core para o modulo Brainstorming
'==================================================

' ========== FUNCOES SQL PADRAO ==========

' Consultar brainstorming por stepID
Function SQL_CONSULTA_BRAINSTORMING(stepID)
    SQL_CONSULTA_BRAINSTORMING = "SELECT * FROM T_FTA_METHOD_BRAINSTORMING WHERE stepID = " & stepID
End Function

' Criar novo brainstorming
Function SQL_CRIA_BRAINSTORMING(stepID, description, votingPoints)
    description = Replace(description, "'", "''")
    SQL_CRIA_BRAINSTORMING = "INSERT INTO T_FTA_METHOD_BRAINSTORMING " & _
                            "(stepID, description, votingPoints) VALUES (" & _
                            stepID & ", '" & description & "', " & votingPoints & ")"
End Function

' Atualizar brainstorming existente
Function SQL_ATUALIZA_BRAINSTORMING(brainstormingID, description, votingPoints)
    description = Replace(description, "'", "''")
    SQL_ATUALIZA_BRAINSTORMING = "UPDATE T_FTA_METHOD_BRAINSTORMING SET " & _
                                 "description = '" & description & "', " & _
                                 "votingPoints = " & votingPoints & " " & _
                                 "WHERE brainstormingID = " & brainstormingID
End Function

' Obter brainstorming
Function SQL_GET_BRAINSTORMING(stepID)
    SQL_GET_BRAINSTORMING = "SELECT * FROM T_FTA_METHOD_BRAINSTORMING WHERE stepID = " & stepID
End Function

' ========== FUNCOES PARA IDEAS ==========

' Obter todas as ideias de um brainstorming
Function SQL_GET_IDEAS(brainstormingID)
    SQL_GET_IDEAS = "SELECT i.*, " & _
                   "(SELECT COUNT(*) FROM T_FTA_METHOD_BRAINSTORMING_VOTING v WHERE v.ideaID = i.ideaID) as totalVotes " & _
                   "FROM T_FTA_METHOD_BRAINSTORMING_IDEAS i " & _
                   "WHERE i.brainstormingID = " & brainstormingID & " " & _
                   "ORDER BY i.dateTime DESC"
End Function

' Obter uma ideia especifica
Function SQL_GET_IDEA(ideaID)
    SQL_GET_IDEA = "SELECT * FROM T_FTA_METHOD_BRAINSTORMING_IDEAS WHERE ideaID = " & ideaID
End Function

' Criar nova ideia
Function SQL_CREATE_IDEA(brainstormingID, email, title, description, status)
    title = Replace(title, "'", "''")
    description = Replace(description, "'", "''")
    email = Replace(email, "'", "''")
    
    SQL_CREATE_IDEA = "INSERT INTO T_FTA_METHOD_BRAINSTORMING_IDEAS " & _
                     "(brainstormingID, email, dateTime, title, description, status) VALUES (" & _
                     brainstormingID & ", '" & email & "', GETDATE(), '" & _
                     title & "', '" & description & "', " & status & ")"
End Function

' Atualizar ideia
Function SQL_UPDATE_IDEA(ideaID, title, description)
    title = Replace(title, "'", "''")
    description = Replace(description, "'", "''")
    
    SQL_UPDATE_IDEA = "UPDATE T_FTA_METHOD_BRAINSTORMING_IDEAS SET " & _
                     "title = '" & title & "', " & _
                     "description = '" & description & "' " & _
                     "WHERE ideaID = " & ideaID
End Function

' Deletar ideia
Function SQL_DELETE_IDEA(ideaID)
    SQL_DELETE_IDEA = "DELETE FROM T_FTA_METHOD_BRAINSTORMING_IDEAS WHERE ideaID = " & ideaID
End Function

' Atualizar status da ideia
Function SQL_UPDATE_IDEA_STATUS(ideaID, newStatus)
    SQL_UPDATE_IDEA_STATUS = "UPDATE T_FTA_METHOD_BRAINSTORMING_IDEAS SET status = " & newStatus & " WHERE ideaID = " & ideaID
End Function

' ========== FUNCOES PARA VOTOS ==========

' Obter votos de um usuario em um brainstorming
Function SQL_GET_USER_VOTES(brainstormingID, email)
    SQL_GET_USER_VOTES = "SELECT v.*, i.title " & _
                         "FROM T_FTA_METHOD_BRAINSTORMING_VOTING v " & _
                         "INNER JOIN T_FTA_METHOD_BRAINSTORMING_IDEAS i ON v.ideaID = i.ideaID " & _
                         "WHERE i.brainstormingID = " & brainstormingID & " " & _
                         "AND v.email = '" & Replace(email, "'", "''") & "'"
End Function

' Contar votos de um usuario
Function SQL_COUNT_USER_VOTES(brainstormingID, email)
    SQL_COUNT_USER_VOTES = "SELECT COUNT(*) as totalVotes " & _
                          "FROM T_FTA_METHOD_BRAINSTORMING_VOTING v " & _
                          "INNER JOIN T_FTA_METHOD_BRAINSTORMING_IDEAS i ON v.ideaID = i.ideaID " & _
                          "WHERE i.brainstormingID = " & brainstormingID & " " & _
                          "AND v.email = '" & Replace(email, "'", "''") & "'"
End Function

' Adicionar voto
Function SQL_ADD_VOTE(ideaID, email)
    SQL_ADD_VOTE = "INSERT INTO T_FTA_METHOD_BRAINSTORMING_VOTING (ideaID, email) " & _
                   "VALUES (" & ideaID & ", '" & Replace(email, "'", "''") & "')"
End Function

' Remover voto
Function SQL_REMOVE_VOTE(ideaID, email)
    SQL_REMOVE_VOTE = "DELETE FROM T_FTA_METHOD_BRAINSTORMING_VOTING " & _
                      "WHERE ideaID = " & ideaID & " AND email = '" & Replace(email, "'", "''") & "'"
End Function

' Verificar se usuario ja votou em uma ideia
Function SQL_CHECK_USER_VOTE(ideaID, email)
    SQL_CHECK_USER_VOTE = "SELECT COUNT(*) as hasVoted FROM T_FTA_METHOD_BRAINSTORMING_VOTING " & _
                         "WHERE ideaID = " & ideaID & " AND email = '" & Replace(email, "'", "''") & "'"
End Function

' ========== FUNCOES PARA RELATORIO ==========

' Obter ranking de ideias por votos
Function SQL_GET_IDEAS_RANKING(brainstormingID)
    SQL_GET_IDEAS_RANKING = "SELECT i.*, " & _
                           "(SELECT COUNT(*) FROM T_FTA_METHOD_BRAINSTORMING_VOTING v WHERE v.ideaID = i.ideaID) as totalVotes " & _
                           "FROM T_FTA_METHOD_BRAINSTORMING_IDEAS i " & _
                           "WHERE i.brainstormingID = " & brainstormingID & " " & _
                           "ORDER BY totalVotes DESC, i.dateTime DESC"
End Function

' ========== FUNCOES DUBLIN CORE ==========

' Buscar dados DC de todos os metodos anteriores
Function GetAllPreviousDublinCore(currentStepID)
    Dim dcData
    Set dcData = Server.CreateObject("Scripting.Dictionary")
    
    On Error Resume Next
    
    ' Buscar workflow
    Dim workflowID
    call getRecordSet("SELECT workflowID FROM T_WORKFLOW_STEP WHERE stepID = " & currentStepID, rs)
    If Not rs.EOF Then
        workflowID = rs("workflowID")
        
        ' Buscar todos os steps anteriores
        call getRecordSet("SELECT stepID FROM T_WORKFLOW_STEP WHERE workflowID = " & workflowID & " AND stepID < " & currentStepID & " ORDER BY stepID", rs)
        
        While Not rs.EOF
            Dim prevStepID
            prevStepID = rs("stepID")
            
            ' Verificar cada tipo de metodo
            If HasBibliometricData(prevStepID) Then
                dcData.Add "biblio_" & prevStepID, GetBibliometricDC(prevStepID)
            End If
            
            If HasScenarioData(prevStepID) Then
                dcData.Add "scenario_" & prevStepID, GetScenarioDC(prevStepID)
            End If
            
            If HasBrainstormingData(prevStepID) Then
                dcData.Add "brainstorm_" & prevStepID, GetBrainstormingDC(prevStepID)
            End If
            
            rs.MoveNext
        Wend
    End If
    
    On Error Goto 0
    Set GetAllPreviousDublinCore = dcData
End Function

' Verificar se tem dados bibliometricos
Function HasBibliometricData(stepID)
    Dim hasData
    hasData = false
    
    On Error Resume Next
    call getRecordSet("SELECT COUNT(*) as total FROM T_FTA_METHOD_BIBLIOMETRICS WHERE stepID = " & stepID, rs)
    If Not rs.EOF Then
        If rs("total") > 0 Then hasData = true
    End If
    On Error Goto 0
    
    HasBibliometricData = hasData
End Function

' Obter dados DC do Bibliometrics
Function GetBibliometricDC(stepID)
    Dim dcData
    Set dcData = Server.CreateObject("Scripting.Dictionary")
    
    On Error Resume Next
    
    ' Contar referencias
    call getRecordSet("SELECT COUNT(*) as total FROM T_FTA_METHOD_BIBLIOMETRICS WHERE stepID = " & stepID, rs)
    If Not rs.EOF Then
        dcData.Add "totalItems", rs("total")
    End If
    
    ' Buscar titulos
    Dim titles
    titles = ""
    call getRecordSet("SELECT TOP 5 title FROM T_FTA_METHOD_BIBLIOMETRICS WHERE stepID = " & stepID, rs)
    While Not rs.EOF
        If titles <> "" Then titles = titles & " | "
        titles = titles & rs("title")
        rs.MoveNext
    Wend
    dcData.Add "dc:title", titles
    
    ' Buscar autores
    Dim authors
    authors = ""
    call getRecordSet("SELECT DISTINCT TOP 10 a.name FROM T_FTA_METHOD_BIBLIOMETRICS_AUTHORS a " & _
                     "INNER JOIN T_FTA_METHOD_BIBLIOMETRICS b ON a.referenceID = b.referenceID " & _
                     "WHERE b.stepID = " & stepID, rs)
    While Not rs.EOF
        If authors <> "" Then authors = authors & ", "
        authors = authors & rs("name")
        rs.MoveNext
    Wend
    dcData.Add "dc:creator", authors
    
    ' Buscar periodo
    call getRecordSet("SELECT MIN(year) as min_year, MAX(year) as max_year FROM T_FTA_METHOD_BIBLIOMETRICS WHERE stepID = " & stepID, rs)
    If Not rs.EOF Then
        If rs("min_year") = rs("max_year") Then
            dcData.Add "dc:date", rs("min_year")
        Else
            dcData.Add "dc:date", rs("min_year") & "-" & rs("max_year")
        End If
    End If
    
    dcData.Add "dc:type", "bibliometric reference"
    dcData.Add "dc:source", "BIBLIOMETRICS"
    
    On Error Goto 0
    Set GetBibliometricDC = dcData
End Function

' Verificar se tem dados de cenarios
Function HasScenarioData(stepID)
    Dim hasData
    hasData = false
    
    On Error Resume Next
    call getRecordSet("SELECT COUNT(*) as total FROM T_FTA_METHOD_SCENARIOS WHERE stepID = " & stepID, rs)
    If Not rs.EOF Then
        If rs("total") > 0 Then hasData = true
    End If
    On Error Goto 0
    
    HasScenarioData = hasData
End Function

' Obter dados DC do Scenarios
Function GetScenarioDC(stepID)
    Dim dcData
    Set dcData = Server.CreateObject("Scripting.Dictionary")
    
    On Error Resume Next
    
    ' Buscar cenarios
    Dim names, descriptions
    names = ""
    descriptions = ""
    
    call getRecordSet("SELECT name, LEFT(scenario, 200) as snippet FROM T_FTA_METHOD_SCENARIOS WHERE stepID = " & stepID, rs)
    While Not rs.EOF
        If names <> "" Then names = names & " | "
        names = names & rs("name")
        
        If descriptions <> "" Then descriptions = descriptions & " ### "
        descriptions = descriptions & Left(rs("snippet"), 100)
        rs.MoveNext
    Wend
    
    dcData.Add "dc:title", names
    dcData.Add "dc:description", descriptions
    dcData.Add "dc:type", "future scenario"
    dcData.Add "dc:source", "SCENARIOS"
    
    On Error Goto 0
    Set GetScenarioDC = dcData
End Function

' Verificar se tem dados de brainstorming
Function HasBrainstormingData(stepID)
    Dim hasData
    hasData = false
    
    On Error Resume Next
    call getRecordSet("SELECT brainstormingID FROM T_FTA_METHOD_BRAINSTORMING WHERE stepID = " & stepID, rs)
    If Not rs.EOF Then
        Dim brainstormingID
        brainstormingID = rs("brainstormingID")
        
        call getRecordSet("SELECT COUNT(*) as total FROM T_FTA_METHOD_BRAINSTORMING_IDEAS WHERE brainstormingID = " & brainstormingID, rs)
        If Not rs.EOF Then
            If rs("total") > 0 Then hasData = true
        End If
    End If
    On Error Goto 0
    
    HasBrainstormingData = hasData
End Function

' Obter dados DC do Brainstorming
Function GetBrainstormingDC(stepID)
    Dim dcData
    Set dcData = Server.CreateObject("Scripting.Dictionary")
    
    On Error Resume Next
    
    ' Buscar brainstormingID
    call getRecordSet("SELECT brainstormingID FROM T_FTA_METHOD_BRAINSTORMING WHERE stepID = " & stepID, rs)
    If Not rs.EOF Then
        Dim brainstormingID
        brainstormingID = rs("brainstormingID")
        
        ' Buscar ideias
        Dim ideas, totalIdeas
        ideas = ""
        totalIdeas = 0
        
        call getRecordSet("SELECT title FROM T_FTA_METHOD_BRAINSTORMING_IDEAS WHERE brainstormingID = " & brainstormingID, rs)
        While Not rs.EOF
            totalIdeas = totalIdeas + 1
            If ideas <> "" Then ideas = ideas & " | "
            ideas = ideas & rs("title")
            rs.MoveNext
        Wend
        
        dcData.Add "dc:title", ideas
        dcData.Add "totalItems", totalIdeas
        dcData.Add "dc:type", "brainstorming idea"
        dcData.Add "dc:source", "BRAINSTORMING"
    End If
    
    On Error Goto 0
    Set GetBrainstormingDC = dcData
End Function

' Salvar metadados Dublin Core da ideia
Sub SaveIdeaDublinCore(ideaID, stepID)
    On Error Resume Next
    
    ' Criar entrada na tabela Dublin Core se existir
    Dim sql
    sql = "IF EXISTS (SELECT * FROM sysobjects WHERE name='T_FTA_DUBLIN_CORE_METADATA' AND xtype='U') " & _
          "BEGIN " & _
          "DELETE FROM T_FTA_DUBLIN_CORE_METADATA WHERE stepID = " & stepID & " AND sourceMethod = 'BRAINSTORMING'; " & _
          "INSERT INTO T_FTA_DUBLIN_CORE_METADATA (stepID, sourceMethod, dc_type) " & _
          "VALUES (" & stepID & ", 'BRAINSTORMING', 'brainstorming idea'); " & _
          "END"
    
    Call ExecuteSQL(sql)
    
    On Error Goto 0
End Sub
%>