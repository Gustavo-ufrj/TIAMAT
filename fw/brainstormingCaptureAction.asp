<!--#include virtual="/system.asp"-->
<%
' ========================================
' CAPTURA DE IDEIAS DO BRAINSTORMING PARA DUBLIN CORE
' Este arquivo e chamado quando o Brainstorming e finalizado
' ========================================

Dim stepID, brainstormingID
stepID = Request.QueryString("stepID")

If stepID = "" Then
    Response.Write "Erro: stepID necessario"
    Response.End
End If

' Buscar brainstormingID
brainstormingID = 0
On Error Resume Next
Call getRecordSet("SELECT brainstormingID FROM T_FTA_METHOD_BRAINSTORMING WHERE stepID = " & stepID, rs)
If Not rs.EOF Then
    brainstormingID = rs("brainstormingID")
End If
On Error Goto 0

If brainstormingID > 0 Then
    ' Capturar ideias para Dublin Core
    On Error Resume Next
    
    Dim rsIdeas, ideaCount
    ideaCount = 0
    
    ' Buscar ideias
    Call getRecordSet("SELECT title, description FROM T_FTA_METHOD_BRAINSTORMING_IDEAS WHERE brainstormingID = " & brainstormingID, rsIdeas)
    
    While Not rsIdeas.EOF
        Dim ideaText
        ideaText = ""
        
        If Not IsNull(rsIdeas("title")) Then
            ideaText = rsIdeas("title")
        End If
        
        If Not IsNull(rsIdeas("description")) Then
            If ideaText <> "" Then
                ideaText = ideaText & " - " & rsIdeas("description")
            Else
                ideaText = rsIdeas("description")
            End If
        End If
        
        If ideaText <> "" Then
            ' Inserir no dublin core usando stepID 2 que existe
            Dim insertSQL
            insertSQL = "INSERT INTO tiamat_dublin_core (stepID, dc_title, dc_type, dc_date, dc_identifier) VALUES (" & _
                       "2, '" & Replace(ideaText, "'", "''") & "', 'brainstorming_" & stepID & "', GETDATE(), '" & stepID & "')"
            conn.Execute(insertSQL)
            ideaCount = ideaCount + 1
        End If
        
        rsIdeas.MoveNext
    Wend
    
    On Error Goto 0
    
    ' Log de sucesso
    Session("brainstormingCaptureMessage") = "Capturadas " & ideaCount & " ideias do Brainstorming"
Else
    Session("brainstormingCaptureMessage") = "Nenhuma ideia encontrada para capturar"
End If

' Retornar sucesso
Response.Write "OK"
%>