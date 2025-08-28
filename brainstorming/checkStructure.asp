<!--#include virtual="/system.asp"-->
<%
Response.ContentType = "text/html"
%>
<!DOCTYPE html>
<html>
<head>
    <title>Estrutura das Tabelas - Brainstorming</title>
    <style>
        body { font-family: Arial, sans-serif; padding: 20px; background: #f5f5f5; }
        .container { max-width: 1200px; margin: 0 auto; background: white; padding: 20px; border-radius: 8px; }
        h2 { color: #007bff; border-bottom: 2px solid #007bff; padding-bottom: 5px; }
        table { width: 100%; border-collapse: collapse; margin: 15px 0; }
        th { background: #007bff; color: white; padding: 8px; text-align: left; }
        td { border: 1px solid #ddd; padding: 8px; }
        .error { color: red; background: #ffe0e0; padding: 10px; margin: 10px 0; }
        .success { color: green; background: #e0ffe0; padding: 10px; margin: 10px 0; }
    </style>
</head>
<body>
    <div class="container">
        <h1>📊 Estrutura das Tabelas do Brainstorming</h1>
        
        <%
        On Error Resume Next
        
        ' 1. T_FTA_METHOD_BRAINSTORMING
        Response.Write "<h2>1. T_FTA_METHOD_BRAINSTORMING</h2>"
        
        Err.Clear
        call getRecordSet("SELECT TOP 1 * FROM T_FTA_METHOD_BRAINSTORMING", rs)
        If Err.Number = 0 Then
            Response.Write "<div class='success'>✅ Tabela existe</div>"
            Response.Write "<table><tr><th>Campo</th><th>Tipo</th></tr>"
            
            For i = 0 To rs.Fields.Count - 1
                Response.Write "<tr><td>" & rs.Fields(i).Name & "</td>"
                Response.Write "<td>Type " & rs.Fields(i).Type & " (Size: " & rs.Fields(i).DefinedSize & ")</td></tr>"
            Next
            Response.Write "</table>"
            
            ' Contar registros
            call getRecordSet("SELECT COUNT(*) as total FROM T_FTA_METHOD_BRAINSTORMING", rs)
            Response.Write "<p>Total de registros: " & rs("total") & "</p>"
        Else
            Response.Write "<div class='error'>❌ Erro: " & Err.Description & "</div>"
        End If
        
        ' 2. T_FTA_METHOD_BRAINSTORMING_IDEAS
        Response.Write "<h2>2. T_FTA_METHOD_BRAINSTORMING_IDEAS</h2>"
        
        Err.Clear
        call getRecordSet("SELECT TOP 1 * FROM T_FTA_METHOD_BRAINSTORMING_IDEAS", rs)
        If Err.Number = 0 Then
            Response.Write "<div class='success'>✅ Tabela existe</div>"
            Response.Write "<table><tr><th>Campo</th><th>Tipo</th></tr>"
            
            For i = 0 To rs.Fields.Count - 1
                Response.Write "<tr><td>" & rs.Fields(i).Name & "</td>"
                Response.Write "<td>Type " & rs.Fields(i).Type & " (Size: " & rs.Fields(i).DefinedSize & ")</td></tr>"
            Next
            Response.Write "</table>"
            
            ' Contar registros
            call getRecordSet("SELECT COUNT(*) as total FROM T_FTA_METHOD_BRAINSTORMING_IDEAS", rs)
            Response.Write "<p>Total de registros: " & rs("total") & "</p>"
        Else
            Response.Write "<div class='error'>❌ Erro: " & Err.Description & "</div>"
        End If
        
        ' 3. T_FTA_METHOD_BRAINSTORMING_VOTING
        Response.Write "<h2>3. T_FTA_METHOD_BRAINSTORMING_VOTING</h2>"
        
        Err.Clear
        call getRecordSet("SELECT TOP 1 * FROM T_FTA_METHOD_BRAINSTORMING_VOTING", rs)
        If Err.Number = 0 Then
            Response.Write "<div class='success'>✅ Tabela existe</div>"
            Response.Write "<table><tr><th>Campo</th><th>Tipo</th></tr>"
            
            For i = 0 To rs.Fields.Count - 1
                Response.Write "<tr><td>" & rs.Fields(i).Name & "</td>"
                Response.Write "<td>Type " & rs.Fields(i).Type & " (Size: " & rs.Fields(i).DefinedSize & ")</td></tr>"
            Next
            Response.Write "</table>"
            
            ' Contar registros
            call getRecordSet("SELECT COUNT(*) as total FROM T_FTA_METHOD_BRAINSTORMING_VOTING", rs)
            Response.Write "<p>Total de registros: " & rs("total") & "</p>"
        Else
            Response.Write "<div class='error'>❌ Erro: " & Err.Description & "</div>"
        End If
        
        ' 4. T_FTA_METHOD_BRAINSTORMING_DISCUSSION (se existir)
        Response.Write "<h2>4. T_FTA_METHOD_BRAINSTORMING_DISCUSSION</h2>"
        
        Err.Clear
        call getRecordSet("SELECT TOP 1 * FROM T_FTA_METHOD_BRAINSTORMING_DISCUSSION", rs)
        If Err.Number = 0 Then
            Response.Write "<div class='success'>✅ Tabela existe</div>"
            Response.Write "<table><tr><th>Campo</th><th>Tipo</th></tr>"
            
            For i = 0 To rs.Fields.Count - 1
                Response.Write "<tr><td>" & rs.Fields(i).Name & "</td>"
                Response.Write "<td>Type " & rs.Fields(i).Type & " (Size: " & rs.Fields(i).DefinedSize & ")</td></tr>"
            Next
            Response.Write "</table>"
        Else
            Response.Write "<div class='error'>❌ Tabela não encontrada ou erro: " & Err.Description & "</div>"
        End If
        
        On Error Goto 0
        %>
        
        <hr>
        <h2>Testes de Consulta</h2>
        
        <%
        On Error Resume Next
        
        ' Teste 1: Buscar brainstorming do step 50380
        Response.Write "<h3>Teste 1: Buscar Brainstorming do Step 50380</h3>"
        Err.Clear
        call getRecordSet("SELECT * FROM T_FTA_METHOD_BRAINSTORMING WHERE stepID = 50380", rs)
        If Err.Number = 0 Then
            If rs.EOF Then
                Response.Write "<p>Nenhum registro encontrado para stepID = 50380</p>"
            Else
                Response.Write "<p>✅ Encontrado: brainstormingID = " & rs("brainstormingID") & "</p>"
            End If
        Else
            Response.Write "<div class='error'>Erro: " & Err.Description & "</div>"
        End If
        
        On Error Goto 0
        %>
        
        <hr>
        <div style="margin-top: 20px;">
            <a href="index.asp?stepID=50380" style="padding: 10px 20px; background: #007bff; color: white; text-decoration: none; border-radius: 4px;">
                Testar Brainstorming
            </a>
        </div>
    </div>
</body>
</html>