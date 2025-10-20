<!--#include virtual="/system.asp"-->
<%
' ========================================
' CAPTURA DE DADOS DO BRAINSTORMING
' Versao corrigida para estrutura real
' ========================================

Dim stepID, action
stepID = Request.QueryString("stepID")
action = Request.QueryString("action")

If stepID = "" Then
    Response.Write "Error: stepID required"
    Response.End
End If

' Funcao para capturar dados do Brainstorming
Sub CaptureBrainstormingData(stepID)
    On Error Resume Next
    
    Dim rs, sql
    Dim ideaCount
    Dim brainstormingID
    ideaCount = 0
    brainstormingID = 0
    
    ' Primeiro buscar o brainstormingID
    sql = "SELECT brainstormingID FROM T_FTA_METHOD_BRAINSTORMING WHERE stepID = " & stepID
    Call getRecordSet(sql, rs)
    
    If Not rs.EOF Then
        brainstormingID = rs("brainstormingID")
    End If
    
    If brainstormingID > 0 Then
        ' Limpar dados anteriores
        sql = "DELETE FROM tiamat_dublin_core WHERE stepID = " & stepID & " AND sourceMethod = 'BRAINSTORMING'"
        conn.Execute(sql)
        
        ' Buscar ideias usando brainstormingID
        sql = "SELECT * FROM T_FTA_METHOD_BRAINSTORMING_IDEAS WHERE brainstormingID = " & brainstormingID
        Call getRecordSet(sql, rs)
        
        If Not rs.EOF Then
            While Not rs.EOF
                Dim ideaText
                ideaText = ""
                
                ' Combinar title e description
                If Not IsNull(rs("title")) Then
                    ideaText = rs("title")
                End If
                
                If Not IsNull(rs("description")) Then
                    If ideaText <> "" Then
                        ideaText = ideaText & " - " & rs("description")
                    Else
                        ideaText = rs("description")
                    End If
                End If
                
                ' Se ainda estiver vazio, tentar outros campos
                If ideaText = "" And Not IsNull(rs("idea")) Then
                    ideaText = rs("idea")
                End If
                
                If ideaText <> "" Then
                    ' Inserir na tabela tiamat_dublin_core
                    Dim insertSQL
                    insertSQL = "INSERT INTO tiamat_dublin_core (stepID, sourceMethod, dc_title, dc_type, dc_date) VALUES (" & _
                               stepID & ", 'BRAINSTORMING', '" & Replace(ideaText, "'", "''") & "', 'brainstorming_idea', GETDATE())"
                    conn.Execute(insertSQL)
                    ideaCount = ideaCount + 1
                End If
                rs.MoveNext
            Wend
            
            Response.Write "<p style='color: green;'>Sucesso! Capturadas " & ideaCount & " ideias do Brainstorming</p>"
        Else
            Response.Write "<p style='color: orange;'>Nenhuma ideia encontrada para brainstormingID " & brainstormingID & "</p>"
        End If
    Else
        Response.Write "<p style='color: red;'>BrainstormingID nao encontrado para stepID " & stepID & "</p>"
    End If
    
    On Error Goto 0
End Sub

' Funcao para capturar dados do Brainstorming
Sub CaptureBrainstormingData(stepID)
    On Error Resume Next
    
    Dim rs, sql
    Dim ideaCount
    ideaCount = 0
    
    ' Primeiro, verificar se ja existe dados capturados para evitar duplicacao
    sql = "DELETE FROM T_FTA_DUBLIN_CORE_METADATA WHERE stepID = " & stepID & " AND sourceMethod = 'BRAINSTORMING'"
    conn.Execute(sql)
    
    ' Buscar todas as ideias do Brainstorming
    ' Tentativa 1: Tabela T_FTA_METHOD_BRAINSTORMING
    sql = "SELECT * FROM T_FTA_METHOD_BRAINSTORMING WHERE stepID = " & stepID
    Call getRecordSet(sql, rs)
    
    If Not rs.EOF Then
        While Not rs.EOF
            ' Inserir cada ideia no Dublin Core
            Dim insertSQL
            insertSQL = "INSERT INTO T_FTA_DUBLIN_CORE_METADATA (stepID, sourceMethod, dc_title, dc_type, dc_date) VALUES (" & _
                       stepID & ", 'BRAINSTORMING', '" & Replace(rs("idea"), "'", "''") & "', 'brainstorming_idea', GETDATE())"
            conn.Execute(insertSQL)
            ideaCount = ideaCount + 1
            rs.MoveNext
        Wend
        
        Response.Write "Capturadas " & ideaCount & " ideias do Brainstorming para Dublin Core"
    Else
        ' Tentativa 2: Tabela T_BRAINSTORMING (nome alternativo)
        sql = "SELECT * FROM T_BRAINSTORMING WHERE stepID = " & stepID
        Call getRecordSet(sql, rs)
        
        If Not rs.EOF Then
            While Not rs.EOF
                Dim ideaText
                ' Tentar diferentes nomes de campo
                If Not IsNull(rs("idea")) Then
                    ideaText = rs("idea")
                ElseIf Not IsNull(rs("description")) Then
                    ideaText = rs("description")
                ElseIf Not IsNull(rs("content")) Then
                    ideaText = rs("content")
                ElseIf Not IsNull(rs("text")) Then
                    ideaText = rs("text")
                End If
                
                If ideaText <> "" Then
                    insertSQL = "INSERT INTO T_FTA_DUBLIN_CORE_METADATA (stepID, sourceMethod, dc_title, dc_type, dc_date) VALUES (" & _
                               stepID & ", 'BRAINSTORMING', '" & Replace(ideaText, "'", "''") & "', 'brainstorming_idea', GETDATE())"
                    conn.Execute(insertSQL)
                    ideaCount = ideaCount + 1
                End If
                rs.MoveNext
            Wend
            
            Response.Write "Capturadas " & ideaCount & " ideias do Brainstorming para Dublin Core"
        Else
            Response.Write "Nenhuma ideia encontrada para capturar"
        End If
    End If
    
    On Error Goto 0
End Sub

' Executar captura se action = capture
If action = "capture" Then
    Call CaptureBrainstormingData(stepID)
    Response.Write "<br><br>"
    Response.Write "<a href='javascript:window.close()'>Fechar</a> | "
    Response.Write "<a href='/FTA/fw/dcData.asp?stepID=" & stepID & "' target='_blank'>Ver dados Dublin Core</a>"
End If

' Mostrar formulario de teste
%>
<!DOCTYPE html>
<html>
<head>
    <title>Captura Brainstorming para Dublin Core</title>
    <style>
        body { font-family: Arial; padding: 20px; }
        .box { background: #f0f0f0; padding: 20px; border-radius: 5px; margin: 20px 0; }
        button { padding: 10px 20px; background: #007bff; color: white; border: none; border-radius: 5px; cursor: pointer; }
        button:hover { background: #0056b3; }
    </style>
</head>
<body>
    <h1>Captura de Dados do Brainstorming</h1>
    
    <div class="box">
        <h2>Informacoes:</h2>
        <p>StepID do Brainstorming: <strong><%=stepID%></strong></p>
        <p>Este script captura as ideias do Brainstorming e salva no formato Dublin Core.</p>
    </div>
    
    <div class="box">
        <h2>Verificar dados existentes:</h2>
        <%
        Dim checkSQL, checkRS, existingCount
        Dim brainstormingID
        existingCount = 0
        brainstormingID = 0
        
        ' Buscar brainstormingID
        On Error Resume Next
        checkSQL = "SELECT brainstormingID FROM T_FTA_METHOD_BRAINSTORMING WHERE stepID = " & stepID
        Call getRecordSet(checkSQL, checkRS)
        If Not checkRS.EOF Then
            brainstormingID = checkRS("brainstormingID")
        End If
        
        Response.Write "<p>BrainstormingID: <strong>" & brainstormingID & "</strong></p>"
        
        ' Verificar dados ja capturados no Dublin Core
        checkSQL = "SELECT COUNT(*) as total FROM tiamat_dublin_core WHERE stepID = " & stepID & " AND sourceMethod = 'BRAINSTORMING'"
        Call getRecordSet(checkSQL, checkRS)
        If Not checkRS.EOF Then
            existingCount = checkRS("total")
        End If
        Response.Write "<p>Dados ja capturados no Dublin Core: <strong>" & existingCount & "</strong> ideias</p>"
        
        ' Verificar ideias no Brainstorming usando brainstormingID
        Dim brainstormCount
        brainstormCount = 0
        
        If brainstormingID > 0 Then
            checkSQL = "SELECT COUNT(*) as total FROM T_FTA_METHOD_BRAINSTORMING_IDEAS WHERE brainstormingID = " & brainstormingID
            Call getRecordSet(checkSQL, checkRS)
            If Not checkRS.EOF Then
                brainstormCount = checkRS("total")
            End If
            
            Response.Write "<p>Ideias no Brainstorming: <strong>" & brainstormCount & "</strong></p>"
            
            ' Mostrar preview das ideias
            If brainstormCount > 0 Then
                Response.Write "<hr>"
                Response.Write "<p><strong>Preview das ideias:</strong></p>"
                Response.Write "<ol>"
                
                checkSQL = "SELECT TOP 5 * FROM T_FTA_METHOD_BRAINSTORMING_IDEAS WHERE brainstormingID = " & brainstormingID
                Call getRecordSet(checkSQL, checkRS)
                
                While Not checkRS.EOF
                    Dim preview
                    preview = ""
                    
                    If Not IsNull(checkRS("title")) Then
                        preview = "Title: " & checkRS("title")
                    End If
                    
                    If Not IsNull(checkRS("description")) Then
                        If preview <> "" Then preview = preview & " | "
                        preview = preview & "Desc: " & checkRS("description")
                    End If
                    
                    If preview = "" Then
                        preview = "[Ideia vazia]"
                    End If
                    
                    Response.Write "<li>" & Left(preview, 100) & "</li>"
                    checkRS.MoveNext
                Wend
                Response.Write "</ol>"
            End If
        End If
        
        On Error Goto 0
        %>
    </div>
    
    <% If action <> "capture" Then %>
    <div class="box">
        <h2>Executar Captura:</h2>
        <form method="get" action="">
            <input type="hidden" name="stepID" value="<%=stepID%>">
            <input type="hidden" name="action" value="capture">
            <button type="submit">Capturar Dados do Brainstorming</button>
        </form>
    </div>
    <% End If %>
    
    <div class="box">
        <h3>Como usar:</h3>
        <ol>
            <li>Acesse esta pagina com o stepID do Brainstorming: <code>captureBrainstormingDC.asp?stepID=60382</code></li>
            <li>Clique no botao "Capturar Dados"</li>
            <li>Os dados serao salvos na tabela Dublin Core</li>
            <li>Depois, ao abrir o popup do Futures Wheel, os dados aparecerao</li>
        </ol>
    </div>
</body>
</html>