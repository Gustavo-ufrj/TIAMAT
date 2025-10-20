<!--#include virtual="/system.asp"-->
<!--#include file="INC_FUTURES_WHEEL.inc"-->

<%
Dim action
Dim stepID, workflowID
Dim selectedDCs
Dim centralEvent
Dim importLayout
Dim i
Dim insertedFWID, parentFWID
Dim fwEvent
Dim posX, posY
Dim firstEventID
Dim dcID
Dim rs

action = Request.QueryString("action")
stepID = request.form("stepID")
workflowID = request.form("workflowID")

Session("futuresWheelError") = ""

Select Case action

    Case "import"
        If stepID <> "" Then
            selectedDCs = request.form("selectedDC[]")
            centralEvent = Trim(request.form("centralEvent"))
            importLayout = request.form("importLayout")
            If importLayout = "" Then importLayout = "circular"
            
            If selectedDCs <> "" Then
                Dim selectedArray
                If InStr(selectedDCs, ",") > 0 Then
                    selectedArray = Split(selectedDCs, ",")
                Else
                    ReDim selectedArray(0)
                    selectedArray(0) = selectedDCs
                End If
                
                ' Verificar se já existe evento central
                Call getRecordSet(SQL_CONSULTA_FUTURES_WHEEL_PRINCIPAL(stepID), rs)
                
                If rs.EOF Then
                    ' Criar evento central
                    If centralEvent = "" Then
                        ' Usar primeiro Dublin Core como central
                        Call getRecordSet("SELECT dc_title FROM tiamat_dublin_core WHERE dublin_core_id = " & selectedArray(0), rs)
                        If Not rs.EOF Then
                            centralEvent = rs("dc_title")
                        Else
                            centralEvent = "Central Impact"
                        End If
                    End If
                    
                    ' Posição central
                    posX = 400
                    posY = 300
                    
                    ' Criar evento central
                    Set cnn = getConnection
                    Call chamaSP(True, objSP, "SP_CREATE_FTA_METHOD_FUTURES_WHEEL", cnn)
                    With objSP
                        .Parameters.Append .CreateParameter("RETORNO", adBigInt, adParamReturnValue)
                        .Parameters.Append .CreateParameter("@stepID", adBigInt, adParamInput, 8, stepID)
                        .Parameters.Append .CreateParameter("@fwEvent", adVarChar, adParamInput, Len(centralEvent), centralEvent)
                        .Parameters.Append .CreateParameter("@posX", adInteger, adParamInput, 4, posX)
                        .Parameters.Append .CreateParameter("@posY", adInteger, adParamInput, 4, posY)
                        .Execute
                        
                        firstEventID = .Parameters("RETORNO")
                    End With
                    Call chamaSP(False, objSP, Null, Null)
                    dispose(cnn)
                    
                    If firstEventID > 0 Then
                        ' Criar self-link
                        Call ExecuteSQL(SQL_CRIA_FUTURES_WHEEL_LINK(firstEventID, firstEventID))
                    Else
                        Session("futuresWheelError") = "Error creating central event"
                        Response.Redirect "dublinCore.asp?stepID=" & stepID
                    End If
                    
                    parentFWID = firstEventID
                Else
                    ' Evento central já existe
                    firstEventID = rs("fwID")
                    parentFWID = firstEventID
                End If
                
                ' Importar dados selecionados
                Dim angle, radius
                Dim PI
                PI = 3.14159265359
                radius = 200
                
                For i = 0 To UBound(selectedArray)
                    dcID = selectedArray(i)
                    
                    ' Buscar dados Dublin Core
                    Call getRecordSet("SELECT * FROM tiamat_dublin_core WHERE dublin_core_id = " & dcID, rs)
                    
                    If Not rs.EOF Then
                        ' Criar texto do evento
                        fwEvent = rs("dc_title")
                        
                        ' Calcular posição
                        If importLayout = "circular" Then
                            angle = (360 / (UBound(selectedArray) + 1)) * i
                            posX = 400 + CInt(radius * Cos(angle * PI / 180))
                            posY = 300 + CInt(radius * Sin(angle * PI / 180))
                        Else
                            ' Layout em cadeia
                            posX = 400 + (i * 150)
                            posY = 300 + (i * 50)
                        End If
                        
                        ' Criar evento
                        Set cnn = getConnection
                        Call chamaSP(True, objSP, "SP_CREATE_FTA_METHOD_FUTURES_WHEEL", cnn)
                        With objSP
                            .Parameters.Append .CreateParameter("RETORNO", adBigInt, adParamReturnValue)
                            .Parameters.Append .CreateParameter("@stepID", adBigInt, adParamInput, 8, stepID)
                            .Parameters.Append .CreateParameter("@fwEvent", adVarChar, adParamInput, Len(fwEvent), fwEvent)
                            .Parameters.Append .CreateParameter("@posX", adInteger, adParamInput, 4, posX)
                            .Parameters.Append .CreateParameter("@posY", adInteger, adParamInput, 4, posY)
                            .Execute
                            
                            insertedFWID = .Parameters("RETORNO")
                        End With
                        Call chamaSP(False, objSP, Null, Null)
                        dispose(cnn)
                        
                        If insertedFWID > 0 Then
                            ' Criar link
                            If importLayout = "circular" Then
                                Call ExecuteSQL(SQL_CRIA_FUTURES_WHEEL_LINK(insertedFWID, firstEventID))
                            Else
                                If i = 0 Then
                                    Call ExecuteSQL(SQL_CRIA_FUTURES_WHEEL_LINK(insertedFWID, firstEventID))
                                Else
                                    Call ExecuteSQL(SQL_CRIA_FUTURES_WHEEL_LINK(insertedFWID, parentFWID))
                                End If
                                parentFWID = insertedFWID
                            End If
                        End If
                    End If
                Next
                
                Response.Redirect "index.asp?stepID=" & stepID
            Else
                Session("futuresWheelError") = "Please select at least one item to import"
                Response.Redirect "dublinCore.asp?stepID=" & stepID
            End If
        Else
            Response.Write "Invalid step ID"
        End If
        
    Case Else
        Response.Write "Invalid action"
        
End Select
%>