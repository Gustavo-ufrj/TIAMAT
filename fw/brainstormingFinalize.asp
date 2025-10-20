<!--#include virtual="/system.asp"-->
<%
' ========================================
' FINALIZACAO DO BRAINSTORMING COM CAPTURA PARA DUBLIN CORE
' ========================================

Dim stepID, action, brainstormingID
stepID = Request.QueryString("stepID")
action = Request.QueryString("action")

If stepID = "" Then
    Response.Write "Error: stepID required"
    Response.End
End If

' Buscar brainstormingID
brainstormingID = 0
Call getRecordSet("SELECT brainstormingID FROM T_FTA_METHOD_BRAINSTORMING WHERE stepID = " & stepID, rs)
If Not rs.EOF Then
    brainstormingID = rs("brainstormingID")
End If

' Funcao para capturar ideias para Dublin Core
Sub CaptureToDublinCore(brainstormingID, stepID)
    On Error Resume Next
    
    ' Usar stepID 2 que sabemos que existe na tiamat_steps
    Dim dcStepID
    dcStepID = 2
    
    ' Buscar ideias do brainstorming
    Dim rsIdeas, ideaCount
    ideaCount = 0
    
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
            ' Inserir no dublin core com um tipo unico para este brainstorming
            Dim insertSQL
            insertSQL = "INSERT INTO tiamat_dublin_core (stepID, dc_title, dc_type, dc_date, dc_identifier) VALUES (" & _
                       dcStepID & ", '" & Replace(ideaText, "'", "''") & "', 'brainstorming_" & stepID & "', GETDATE(), '" & stepID & "')"
            conn.Execute(insertSQL)
            ideaCount = ideaCount + 1
        End If
        
        rsIdeas.MoveNext
    Wend
    
    On Error Goto 0
End Sub

' Se action = finalize, executar finalizacao
If action = "finalize" And brainstormingID > 0 Then
    ' Capturar para Dublin Core
    Call CaptureToDublinCore(brainstormingID, stepID)
    
    ' Redirecionar de volta ao workflow
    Response.Redirect "/manageWorkflow.asp?message=Brainstorming finalizado com sucesso"
End If
%>

<!DOCTYPE html>
<html>
<head>
    <title>Finalizar Brainstorming</title>
    <link href="https://cdn.jsdelivr.net/npm/bootstrap@5.1.3/dist/css/bootstrap.min.css" rel="stylesheet">
    <style>
        body { padding: 20px; }
        .container { max-width: 800px; margin: 0 auto; }
    </style>
</head>
<body>
    <div class="container">
        <h1>Finalizar Brainstorming</h1>
        
        <div class="alert alert-info">
            <h4>Informacoes do Brainstorming</h4>
            <p>StepID: <strong><%=stepID%></strong></p>
            <p>BrainstormingID: <strong><%=brainstormingID%></strong></p>
            
            <%
            ' Mostrar ideias que serao capturadas
            Dim countIdeas
            countIdeas = 0
            Call getRecordSet("SELECT COUNT(*) as total FROM T_FTA_METHOD_BRAINSTORMING_IDEAS WHERE brainstormingID = " & brainstormingID, rs)
            If Not rs.EOF Then countIdeas = rs("total")
            %>
            <p>Total de ideias: <strong><%=countIdeas%></strong></p>
        </div>
        
        <% If countIdeas > 0 Then %>
        <div class="card">
            <div class="card-header">
                <h5>Ideias que serao capturadas:</h5>
            </div>
            <div class="card-body">
                <ol>
                <%
                Call getRecordSet("SELECT title, description FROM T_FTA_METHOD_BRAINSTORMING_IDEAS WHERE brainstormingID = " & brainstormingID, rs)
                While Not rs.EOF
                    Response.Write "<li><strong>" & rs("title") & "</strong>"
                    If Not IsNull(rs("description")) Then
                        Response.Write " - " & rs("description")
                    End If
                    Response.Write "</li>"
                    rs.MoveNext
                Wend
                %>
                </ol>
            </div>
        </div>
        
        <div class="mt-3">
            <a href="brainstormingFinalize.asp?stepID=<%=stepID%>&action=finalize" class="btn btn-success">
                Confirmar Finalizacao
            </a>
            <a href="javascript:history.back()" class="btn btn-secondary">
                Cancelar
            </a>
        </div>
        <% Else %>
        <div class="alert alert-warning">
            <p>Nenhuma ideia encontrada para capturar.</p>
        </div>
        <% End If %>
    </div>
</body>
</html>