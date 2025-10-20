<!--#include virtual="/system.asp"-->
<!--#include file="INC_BRAINSTORMING.inc"-->

<%
Dim action
Dim stepID, brainstormingID, ideaID
Dim email, title, description, newStatus

action = Request.QueryString("action")
stepID = Request.QueryString("stepID")
ideaID = Request.QueryString("ideaID")

' Obter email do usuário
email = Session("email")
If email = "" Then email = "user@example.com"

Select Case action

    Case "vote"
        ' Adicionar voto
        If ideaID <> "" Then
            ' Verificar se já votou
            Call getRecordSet(SQL_CHECK_USER_VOTE(ideaID, email), rs)
            If Not rs.EOF Then
                If rs("hasVoted") = 0 Then
                    Call ExecuteSQL(SQL_ADD_VOTE(ideaID, email))
                End If
            End If
        End If
        Response.Redirect "index.asp?stepID=" & stepID
        
    Case "unvote"
        ' Remover voto
        If ideaID <> "" Then
            Call ExecuteSQL(SQL_REMOVE_VOTE(ideaID, email))
        End If
        Response.Redirect "index.asp?stepID=" & stepID
        
    Case "delete"
        ' Deletar ideia
        If ideaID <> "" Then
            ' Primeiro remove todos os votos
            Call ExecuteSQL("DELETE FROM T_FTA_METHOD_BRAINSTORMING_VOTING WHERE ideaID = " & ideaID)
            ' Depois deleta a ideia
            Call ExecuteSQL(SQL_DELETE_IDEIA(ideaID))
        End If
        Response.Redirect "index.asp?stepID=" & stepID
        
    Case "move"
        ' Mover ideia para outro status
        newStatus = Request.QueryString("newStatus")
        If ideaID <> "" And newStatus <> "" Then
            Call ExecuteSQL("UPDATE T_FTA_METHOD_BRAINSTORMING_IDEAS SET status = " & newStatus & " WHERE ideaID = " & ideaID)
        End If
        Response.Redirect "index.asp?stepID=" & stepID
        
    Case Else
        Response.Redirect "index.asp?stepID=" & stepID
        
End Select
%>