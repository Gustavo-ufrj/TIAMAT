<%
' Funções SQL para o Brainstorming

Function SQL_CONSULTA_BRAINSTORMING(stepID)
    SQL_CONSULTA_BRAINSTORMING = "SELECT * FROM T_FTA_METHOD_BRAINSTORMING WHERE stepID = " & stepID
End Function

Function SQL_CRIA_BRAINSTORMING(stepID, description, votingPoints)
    SQL_CRIA_BRAINSTORMING = "INSERT INTO T_FTA_METHOD_BRAINSTORMING (stepID, description, votingPoints) " & _
                             "VALUES (" & stepID & ", '" & Replace(description, "'", "''") & "', " & votingPoints & ")"
End Function

Function SQL_ATUALIZA_BRAINSTORMING(brainstormingID, description, votingPoints)
    SQL_ATUALIZA_BRAINSTORMING = "UPDATE T_FTA_METHOD_BRAINSTORMING SET " & _
                                 "description = '" & Replace(description, "'", "''") & "', " & _
                                 "votingPoints = " & votingPoints & " " & _
                                 "WHERE brainstormingID = " & brainstormingID
End Function

Function SQL_CONSULTA_IDEIAS(brainstormingID)
    SQL_CONSULTA_IDEIAS = "SELECT * FROM T_FTA_METHOD_BRAINSTORMING_IDEAS " & _
                         "WHERE brainstormingID = " & brainstormingID & " " & _
                         "ORDER BY dateTime DESC"
End Function

Function SQL_CRIA_IDEIA(brainstormingID, email, title, description, status)
    SQL_CRIA_IDEIA = "INSERT INTO T_FTA_METHOD_BRAINSTORMING_IDEAS " & _
                     "(brainstormingID, email, dateTime, title, description, status) " & _
                     "VALUES (" & brainstormingID & ", '" & Replace(email, "'", "''") & "', GETDATE(), " & _
                     "'" & Replace(title, "'", "''") & "', '" & Replace(description, "'", "''") & "', " & status & ")"
End Function

Function SQL_ATUALIZA_IDEIA(ideaID, title, description)
    SQL_ATUALIZA_IDEIA = "UPDATE T_FTA_METHOD_BRAINSTORMING_IDEAS SET " & _
                        "title = '" & Replace(title, "'", "''") & "', " & _
                        "description = '" & Replace(description, "'", "''") & "' " & _
                        "WHERE ideaID = " & ideaID
End Function

Function SQL_DELETE_IDEIA(ideaID)
    SQL_DELETE_IDEIA = "DELETE FROM T_FTA_METHOD_BRAINSTORMING_IDEAS WHERE ideaID = " & ideaID
End Function

Function SQL_COUNT_USER_VOTES(brainstormingID, email)
    SQL_COUNT_USER_VOTES = "SELECT COUNT(*) as totalVotes FROM T_FTA_METHOD_BRAINSTORMING_VOTING v " & _
                          "INNER JOIN T_FTA_METHOD_BRAINSTORMING_IDEAS i ON v.ideaID = i.ideaID " & _
                          "WHERE i.brainstormingID = " & brainstormingID & " " & _
                          "AND v.email = '" & Replace(email, "'", "''") & "'"
End Function

Function SQL_CHECK_USER_VOTE(ideaID, email)
    SQL_CHECK_USER_VOTE = "SELECT COUNT(*) as hasVoted FROM T_FTA_METHOD_BRAINSTORMING_VOTING " & _
                          "WHERE ideaID = " & ideaID & " AND email = '" & Replace(email, "'", "''") & "'"
End Function

Function SQL_ADD_VOTE(ideaID, email)
    SQL_ADD_VOTE = "INSERT INTO T_FTA_METHOD_BRAINSTORMING_VOTING (ideaID, email, voteDate) " & _
                   "VALUES (" & ideaID & ", '" & Replace(email, "'", "''") & "', GETDATE())"
End Function

Function SQL_REMOVE_VOTE(ideaID, email)
    SQL_REMOVE_VOTE = "DELETE FROM T_FTA_METHOD_BRAINSTORMING_VOTING " & _
                     "WHERE ideaID = " & ideaID & " AND email = '" & Replace(email, "'", "''") & "'"
End Function
%>