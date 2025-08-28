<!--#include virtual="/system.asp"-->
<!--#include file="INC_BRAINSTORMING.inc"-->
<%
' Obter parâmetros
Dim action, stepID, brainstormingID, ideaID
action = Request("action")
stepID = Request("stepID")
brainstormingID = Request("brainstormingID")
ideaID = Request("ideaID")

' Obter email do usuário
Dim userEmail
userEmail = Session("email")
If userEmail = "" Then userEmail = "user@example.com"

' Função para determinar a página de redirecionamento
Function GetRedirectPage(stepID)
    ' Verifica se existe indexTiamat.asp
    Dim fso, redirectPage
    Set fso = Server.CreateObject("Scripting.FileSystemObject")
    
    If fso.FileExists(Server.MapPath("indexTiamat.asp")) Then
        ' Se veio de indexTiamat, volta para lá
        If InStr(Request.ServerVariables("HTTP_REFERER"), "indexTiamat") > 0 Then
            redirectPage = "indexTiamat.asp?stepID=" & stepID
        Else
            redirectPage = "index.asp?stepID=" & stepID
        End If
    Else
        redirectPage = "index.asp?stepID=" & stepID
    End If
    
    Set fso = Nothing
    GetRedirectPage = redirectPage
End Function

' Determinar página de redirecionamento uma vez
Dim redirectURL
redirectURL = GetRedirectPage(stepID)

Select Case action
    
    Case "save"
        ' Criar nova ideia
        Dim title, description
        title = Request.Form("title")
        description = Request.Form("description")
        
        If title <> "" And description <> "" Then
            ' Status 1 = Nova ideia
            call ExecuteSQL(SQL_CREATE_IDEA(brainstormingID, userEmail, title, description, 1))
            
            ' Salvar Dublin Core metadata
            call getRecordSet("SELECT MAX(ideaID) as newID FROM T_FTA_METHOD_BRAINSTORMING_IDEAS WHERE brainstormingID = " & brainstormingID, rs)
            If Not rs.EOF Then
                Call SaveIdeaDublinCore(rs("newID"), stepID)
            End If
            
            Response.Redirect redirectURL
        Else
            Response.Write "Erro: Título e descrição são obrigatórios."
        End If
        
    Case "update"
        ' Atualizar ideia existente
        title = Request.Form("title")
        description = Request.Form("description")
        
        If title <> "" And description <> "" And ideaID <> "" Then
            call ExecuteSQL(SQL_UPDATE_IDEA(ideaID, title, description))
            Response.Redirect redirectURL
        Else
            Response.Write "Erro: Dados incompletos para atualização."
        End If
        
    Case "delete"
        ' Deletar ideia
        If ideaID <> "" Then
            ' Verificar se o usuário é o dono da ideia
            call getRecordSet(SQL_GET_IDEA(ideaID), rs)
            If Not rs.EOF Then
                If rs("email") = userEmail Then
                    ' Primeiro deletar os votos associados
                    call ExecuteSQL("DELETE FROM T_FTA_METHOD_BRAINSTORMING_VOTING WHERE ideaID = " & ideaID)
                    ' Depois deletar a ideia
                    call ExecuteSQL(SQL_DELETE_IDEA(ideaID))
                    Response.Redirect redirectURL
                Else
                    Response.Write "Erro: Você não tem permissão para deletar esta ideia."
                End If
            End If
        End If
        
    Case "vote"
        ' Adicionar voto
        If ideaID <> "" Then
            ' Verificar se ainda tem votos disponíveis
            call getRecordSet(SQL_GET_BRAINSTORMING(stepID), rs)
            If Not rs.EOF Then
                Dim votingPoints
                votingPoints = rs("votingPoints")
                brainstormingID = rs("brainstormingID")
                
                ' Contar votos usados
                call getRecordSet(SQL_COUNT_USER_VOTES(brainstormingID, userEmail), rs)
                Dim votesUsed
                votesUsed = 0
                If Not rs.EOF Then votesUsed = rs("totalVotes")
                
                If votesUsed < votingPoints Then
                    ' Verificar se já não votou nesta ideia
                    call getRecordSet(SQL_CHECK_USER_VOTE(ideaID, userEmail), rs)
                    If rs("hasVoted") = 0 Then
                        call ExecuteSQL(SQL_ADD_VOTE(ideaID, userEmail))
                    End If
                End If
            End If
            Response.Redirect redirectURL
        End If
        
    Case "unvote"
        ' Remover voto
        If ideaID <> "" Then
            call ExecuteSQL(SQL_REMOVE_VOTE(ideaID, userEmail))
            Response.Redirect redirectURL
        End If
        
    Case "move"
        ' Mover ideia entre colunas (mudar status)
        Dim newStatus
        newStatus = Request("newStatus")
        
        If ideaID <> "" And newStatus <> "" Then
            ' Verificar permissão (apenas moderadores ou o próprio autor)
            call getRecordSet(SQL_GET_IDEA(ideaID), rs)
            If Not rs.EOF Then
                ' Por enquanto, permitir apenas ao autor mover sua própria ideia
                If rs("email") = userEmail Then
                    call ExecuteSQL("UPDATE T_FTA_METHOD_BRAINSTORMING_IDEAS SET status = " & newStatus & " WHERE ideaID = " & ideaID)
                    Response.Redirect redirectURL
                Else
                    Response.Write "Erro: Você não tem permissão para mover esta ideia."
                End If
            End If
        End If
        
    Case "movetodiscussion"
        ' Mover para discussão (status = 2)
        If ideaID <> "" Then
            call getRecordSet(SQL_GET_IDEA(ideaID), rs)
            If Not rs.EOF Then
                If rs("email") = userEmail Then
                    call ExecuteSQL("UPDATE T_FTA_METHOD_BRAINSTORMING_IDEAS SET status = 2 WHERE ideaID = " & ideaID)
                End If
            End If
            Response.Redirect redirectURL
        End If
        
    Case "movetovoting"
        ' Mover para votação (status = 3)
        If ideaID <> "" Then
            call getRecordSet(SQL_GET_IDEA(ideaID), rs)
            If Not rs.EOF Then
                If rs("email") = userEmail Then
                    call ExecuteSQL("UPDATE T_FTA_METHOD_BRAINSTORMING_IDEAS SET status = 3 WHERE ideaID = " & ideaID)
                End If
            End If
            Response.Redirect redirectURL
        End If
        
    Case Else
        Response.Write "Ação inválida: " & action
        
End Select
%>