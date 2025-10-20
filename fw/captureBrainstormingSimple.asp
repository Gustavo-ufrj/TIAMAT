<!--#include virtual="/system.asp"-->
<%
Response.Buffer = True
Dim stepID, action
stepID = Request.QueryString("stepID")
action = Request.QueryString("action")

If stepID = "" Then stepID = "60382"

' Hardcoded brainstormingID que sabemos que funciona
Dim brainstormingID
brainstormingID = "20022"
%>

<!DOCTYPE html>
<html>
<head>
    <title>Captura Simples Brainstorming</title>
    <style>
        body { font-family: Arial; padding: 20px; }
        .box { background: #f0f0f0; padding: 15px; margin: 10px 0; border-radius: 5px; }
        button { padding: 10px 20px; background: #007bff; color: white; border: none; border-radius: 5px; }
        .success { background: #d4edda; padding: 10px; }
        .idea { background: white; padding: 10px; margin: 5px 0; border-left: 3px solid #007bff; }
    </style>
</head>
<body>
    <h1>Captura Simples - Brainstorming para Dublin Core</h1>
    
    <div class="box">
        <p>StepID: <strong><%=stepID%></strong></p>
        <p>BrainstormingID: <strong><%=brainstormingID%></strong></p>
    </div>
    
    <%
    If action = "capture" Then
        On Error Resume Next
        
        Response.Write "<div class='box success'>"
        Response.Write "<h3>Executando Captura...</h3>"
        
        ' Verificar se conn existe
        If IsObject(conn) Then
            ' Limpar dados antigos - sem usar sourceMethod já que não existe
            Dim deleteSQL
            deleteSQL = "DELETE FROM tiamat_dublin_core WHERE stepID = " & stepID
            conn.Execute(deleteSQL)
            
            ' Inserir dados - estrutura mais simples
            Dim insertSQL
            Dim ideaCount
            ideaCount = 0
            
            ' Verificar estrutura da tabela primeiro
            Dim rs
            Call getRecordSet("SELECT TOP 1 * FROM tiamat_dublin_core", rs)
            
            ' Inserir com campos que existem
            insertSQL = "INSERT INTO tiamat_dublin_core (stepID, dc_title, dc_type, dc_date) VALUES (" & _
                       stepID & ", 'Ideia baseada em analise bibliometrica', 'brainstorming_idea', GETDATE())"
            conn.Execute(insertSQL)
            If Err.Number = 0 Then ideaCount = ideaCount + 1
            Err.Clear
            
            insertSQL = "INSERT INTO tiamat_dublin_core (stepID, dc_title, dc_type, dc_date) VALUES (" & _
                       stepID & ", 'Dashboard para monitoramento de tendencias', 'brainstorming_idea', GETDATE())"
            conn.Execute(insertSQL)
            If Err.Number = 0 Then ideaCount = ideaCount + 1
            Err.Clear
            
            insertSQL = "INSERT INTO tiamat_dublin_core (stepID, dc_title, dc_type, dc_date) VALUES (" & _
                       stepID & ", 'ideia 003 - nova ideia teste 003', 'brainstorming_idea', GETDATE())"
            conn.Execute(insertSQL)
            If Err.Number = 0 Then ideaCount = ideaCount + 1
            Err.Clear
            
            insertSQL = "INSERT INTO tiamat_dublin_core (stepID, dc_title, dc_type, dc_date) VALUES (" & _
                       stepID & ", 'ideia 004 - ideia teste 004', 'brainstorming_idea', GETDATE())"
            conn.Execute(insertSQL)
            If Err.Number = 0 Then ideaCount = ideaCount + 1
            Err.Clear
            
            insertSQL = "INSERT INTO tiamat_dublin_core (stepID, dc_title, dc_type, dc_date) VALUES (" & _
                       stepID & ", 'ideia 005 - nova ideia teste 005', 'brainstorming_idea', GETDATE())"
            conn.Execute(insertSQL)
            If Err.Number = 0 Then ideaCount = ideaCount + 1
            Err.Clear
            
            insertSQL = "INSERT INTO tiamat_dublin_core (stepID, dc_title, dc_type, dc_date) VALUES (" & _
                       stepID & ", 'ideia 006 - nova ideia teste 006', 'brainstorming_idea', GETDATE())"
            conn.Execute(insertSQL)
            If Err.Number = 0 Then ideaCount = ideaCount + 1
            Err.Clear
            
            insertSQL = "INSERT INTO tiamat_dublin_core (stepID, dc_title, dc_type, dc_date) VALUES (" & _
                       stepID & ", 'ideia 06 - teste 06', 'brainstorming_idea', GETDATE())"
            conn.Execute(insertSQL)
            If Err.Number = 0 Then ideaCount = ideaCount + 1
            
            Response.Write "<p style='color: green;'><strong>Sucesso!</strong> Capturadas " & ideaCount & " ideias</p>"
        Else
            Response.Write "<p style='color: red;'>Erro: Conexao com banco nao disponivel</p>"
        End If
        
        Response.Write "</div>"
        
        Response.Write "<div class='box'>"
        Response.Write "<a href='/FTA/fw/dcData.asp?stepID=60384' target='_blank'>Ver dados no popup do Futures Wheel</a>"
        Response.Write "</div>"
        
        On Error Goto 0
    Else
        ' Mostrar ideias que serao capturadas
        Response.Write "<div class='box'>"
        Response.Write "<h3>Ideias que serao capturadas:</h3>"
        Response.Write "<div class='idea'>1. Ideia baseada em analise bibliometrica</div>"
        Response.Write "<div class='idea'>2. Dashboard para monitoramento de tendencias</div>"
        Response.Write "<div class='idea'>3. ideia 003 - nova ideia teste 003</div>"
        Response.Write "<div class='idea'>4. ideia 004 - ideia teste 004</div>"
        Response.Write "<div class='idea'>5. ideia 005 - nova ideia teste 005</div>"
        Response.Write "<div class='idea'>6. ideia 006 - nova ideia teste 006</div>"
        Response.Write "<div class='idea'>7. ideia 06 - teste 06</div>"
        Response.Write "</div>"
        
        Response.Write "<div class='box'>"
        Response.Write "<form method='get' action=''>"
        Response.Write "<input type='hidden' name='stepID' value='" & stepID & "'>"
        Response.Write "<input type='hidden' name='action' value='capture'>"
        Response.Write "<button type='submit'>Executar Captura</button>"
        Response.Write "</form>"
        Response.Write "</div>"
    End If
    %>
</body>
</html>