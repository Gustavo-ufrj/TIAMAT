<!--#include virtual="/system.asp"-->
<!--#include file="INC_FUTURES_WHEEL.inc"-->

<%
Response.Buffer = True
Response.Expires = -1
Response.CacheControl = "no-cache"
Response.AddHeader "Pragma", "no-cache"

Dim stepID, eventText, newEventID
Dim action

action = Request.QueryString("action")

Select Case action

Case "save"
    stepID = Request.Form("stepID")
    
    ' Verificar se stepID existe
    If stepID = "" Or Not IsNumeric(stepID) Then
        Session("futuresWheelError") = "Invalid Step ID"
        Response.Redirect "index.asp"
        Response.End
    End If
    
    eventText = Trim(Request.Form("fw-event-text"))
    
    ' Verificar se tem texto do evento
    If eventText <> "" Then
        On Error Resume Next
        
        ' 1. Inserir o evento na tabela principal usando ExecuteSQL existente
        Dim sqlInsert
        sqlInsert = "INSERT INTO T_FTA_METHOD_FUTURES_WHEEL (stepID, event, posX, posY) " & _
                   "VALUES (" & stepID & ", '" & Replace(eventText, "'", "''") & "', 300, 300)"
        
        Call ExecuteSQL(sqlInsert)
        
        If Err.Number <> 0 Then
            Session("futuresWheelError") = "Database Error: " & Err.Description
            Response.Redirect "index.asp?stepID=" & stepID
            Response.End
        End If
        
        ' 2. Obter ID do evento inserido usando getRecordSet existente
        Call getRecordSet("SELECT MAX(fwID) AS newID FROM T_FTA_METHOD_FUTURES_WHEEL WHERE stepID = " & stepID & " AND event = '" & Replace(eventText, "'", "''") & "'", rs)
        
        If Not rs.EOF Then
            newEventID = rs("newID")
            
            ' 3. Processar parents
            Dim parentList
            parentList = Request.Form("fw-event-parents")
            
            If parentList <> "" And parentList <> "undefined" Then
                ' Processar lista de parents (pode vir como CSV)
                Dim parentArray, i, parentID
                
                If InStr(parentList, ",") > 0 Then
                    ' Múltiplos parents separados por vírgula
                    parentArray = Split(parentList, ",")
                    For i = 0 To UBound(parentArray)
                        parentID = Trim(parentArray(i))
                        If IsNumeric(parentID) And parentID <> "" Then
                            Call ExecuteSQL("INSERT INTO T_FTA_METHOD_FUTURES_WHEEL_LINK (actualFWID, parentFWID) VALUES (" & newEventID & ", " & parentID & ")")
                        End If
                    Next
                Else
                    ' Único parent
                    If IsNumeric(parentList) Then
                        Call ExecuteSQL("INSERT INTO T_FTA_METHOD_FUTURES_WHEEL_LINK (actualFWID, parentFWID) VALUES (" & newEventID & ", " & parentList & ")")
                    End If
                End If
            Else
                ' Primeiro evento - criar link consigo mesmo
                Call ExecuteSQL("INSERT INTO T_FTA_METHOD_FUTURES_WHEEL_LINK (actualFWID, parentFWID) VALUES (" & newEventID & ", " & newEventID & ")")
            End If
            
            ' Definir mensagem de sucesso na sessão
            Session("futuresWheelSuccess") = "Event '" & eventText & "' added successfully!"
        Else
            Session("futuresWheelError") = "Could not retrieve new event ID"
        End If
        
        Err.Clear
        On Error GoTo 0
    Else
        Session("futuresWheelError") = "Event text cannot be empty"
    End If
    
    ' Redirecionar de volta para a página
    Response.Redirect "index.asp?stepID=" & stepID

Case "savePos"
    ' Salvar posições via AJAX
    Response.ContentType = "application/json"
    Response.Write "{""status"":""ok""}"
    Response.End

Case "delete"
    ' Deletar evento
    stepID = Request.Form("stepID")
    Dim fwID
    fwID = Request.Form("fwID")
    
    If IsNumeric(fwID) And IsNumeric(stepID) Then
        On Error Resume Next
        
        ' Deletar links primeiro
        Call ExecuteSQL("DELETE FROM T_FTA_METHOD_FUTURES_WHEEL_LINK WHERE actualFWID = " & fwID & " OR parentFWID = " & fwID)
        
        ' Deletar evento
        Call ExecuteSQL("DELETE FROM T_FTA_METHOD_FUTURES_WHEEL WHERE fwID = " & fwID & " AND stepID = " & stepID)
        
        If Err.Number = 0 Then
            Session("futuresWheelSuccess") = "Event deleted successfully"
        Else
            Session("futuresWheelError") = "Error deleting event: " & Err.Description
        End If
        
        Err.Clear
        On Error GoTo 0
    Else
        Session("futuresWheelError") = "Invalid parameters for deletion"
    End If
    
    Response.Redirect "index.asp?stepID=" & stepID

Case "end"
    ' Finalização do Futures Wheel
    stepID = Request.QueryString("stepID")
    
    If stepID = "" Or Not IsNumeric(stepID) Then
        Response.Write "Error: Invalid Step ID"
        Response.End
    End If
    
    On Error Resume Next
    
    ' Finalizar step
    Call ExecuteSQL("UPDATE T_WORKFLOW_STEP SET status = 4 WHERE stepID = " & stepID)
    
    ' Contar eventos
    Dim eventCount
    eventCount = 0
    
    Call getRecordSet("SELECT COUNT(*) as total FROM T_FTA_METHOD_FUTURES_WHEEL WHERE stepID = " & stepID, rs)
    
    If Not rs.EOF Then
        eventCount = rs("total")
    End If
    
    If eventCount > 0 Then
        ' Limpar Dublin Core antigo
        Call ExecuteSQL("DELETE FROM tiamat_dublin_core WHERE stepID = " & stepID & " AND dc_type = 'futures_wheel'")
        
        ' Salvar eventos no Dublin Core
        Call getRecordSet("SELECT fwID, event FROM T_FTA_METHOD_FUTURES_WHEEL WHERE stepID = " & stepID, rs)
        
        Dim savedCount
        savedCount = 0
        
        While Not rs.EOF
            Dim eventTitle, sqlDC
            eventTitle = Replace(rs("event"), "'", "''")
            If Len(eventTitle) > 200 Then eventTitle = Left(eventTitle, 200) & "..."
            
            sqlDC = "INSERT INTO tiamat_dublin_core (stepID, dc_title, dc_creator, dc_description, dc_type, dc_date, dc_source) " & _
                   "VALUES (" & stepID & ", '" & eventTitle & "', 'System', '" & eventTitle & "', 'futures_wheel', GETDATE(), 'Futures Wheel Step " & stepID & "')"
            
            Call ExecuteSQL(sqlDC)
            If Err.Number = 0 Then savedCount = savedCount + 1
            Err.Clear
            
            rs.MoveNext
        Wend
        
        Session("futuresWheelSuccess") = "Futures Wheel finalized! " & savedCount & " events saved to Dublin Core."
    Else
        Session("futuresWheelSuccess") = "Futures Wheel finalized with no events."
    End If
    
    ' Ativar próximo step
    Call getRecordSet("SELECT workflowID FROM T_WORKFLOW_STEP WHERE stepID = " & stepID, rs)
    If Not rs.EOF Then
        Dim workflowID
        workflowID = rs("workflowID")
        
        Call ExecuteSQL("UPDATE T_WORKFLOW_STEP SET status = 3 WHERE workflowID = " & workflowID & _
                       " AND stepID = (SELECT MIN(stepID) FROM T_WORKFLOW_STEP WHERE workflowID = " & workflowID & _
                       " AND stepID > " & stepID & " AND status = 2)")
    End If
    
    On Error GoTo 0
    
    Response.Redirect "/workplace.asp"

Case Else
    Response.Write "Invalid action: " & action

End Select
%>