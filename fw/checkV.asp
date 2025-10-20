<!--#include virtual="/system.asp"-->
<%
Dim stepID
stepID = Request.QueryString("stepID")
If stepID = "" Then stepID = "60382"
%>

<!DOCTYPE html>
<html>
<head>
    <title>Localizar Dados do Brainstorming</title>
    <style>
        body { font-family: Arial; padding: 20px; }
        .box { background: #f0f0f0; padding: 15px; margin: 10px 0; border-radius: 5px; }
        .found { background: #d4edda; }
        .empty { background: #f8d7da; }
        table { width: 100%; border-collapse: collapse; margin: 10px 0; }
        td, th { border: 1px solid #ddd; padding: 8px; text-align: left; }
        th { background: #007bff; color: white; }
    </style>
</head>
<body>
    <h1>Localizando Dados do Brainstorming</h1>
    <p>StepID: <strong><%=stepID%></strong></p>
    
    <%
    Dim tables, i, rs, sql, found
    found = False
    
    ' Lista de tabelas para verificar
    tables = Array( _
        "T_FTA_METHOD_BRAINSTORMING", _
        "T_FTA_METHOD_BRAINSTORMING_IDEAS", _
        "T_FTA_METHOD_BRAINSTORMING_DISCUSSION", _
        "T_FTA_METHOD_BRAINSTORMING_VOTING" _
    )
    
    For i = 0 To UBound(tables)
        Response.Write "<div class='box'>"
        Response.Write "<h3>Tabela: " & tables(i) & "</h3>"
        
        On Error Resume Next
        
        ' Primeiro verificar estrutura da tabela
        sql = "SELECT TOP 1 * FROM " & tables(i)
        Call getRecordSet(sql, rs)
        
        If Err.Number = 0 Then
            Response.Write "<p><strong>Estrutura da tabela:</strong></p>"
            Response.Write "<table>"
            Response.Write "<tr>"
            Dim j
            For j = 0 to rs.Fields.Count - 1
                Response.Write "<th>" & rs.Fields(j).Name & "</th>"
            Next
            Response.Write "</tr>"
            Response.Write "</table>"
            
            ' Agora buscar dados do stepID
            sql = "SELECT * FROM " & tables(i) & " WHERE stepID = " & stepID
            Call getRecordSet(sql, rs)
            
            If Not rs.EOF Then
                found = True
                Response.Write "<p class='found'><strong>DADOS ENCONTRADOS!</strong></p>"
                Response.Write "<table>"
                
                ' Cabecalho
                Response.Write "<tr>"
                For j = 0 to rs.Fields.Count - 1
                    Response.Write "<th>" & rs.Fields(j).Name & "</th>"
                Next
                Response.Write "</tr>"
                
                ' Dados
                Dim rowCount
                rowCount = 0
                While Not rs.EOF And rowCount < 10
                    Response.Write "<tr>"
                    For j = 0 to rs.Fields.Count - 1
                        Dim value
                        value = rs.Fields(j).Value
                        If IsNull(value) Then value = "[NULL]"
                        If Len(value & "") > 100 Then value = Left(value, 100) & "..."
                        Response.Write "<td>" & Server.HTMLEncode(value & "") & "</td>"
                    Next
                    Response.Write "</tr>"
                    rowCount = rowCount + 1
                    rs.MoveNext
                Wend
                Response.Write "</table>"
                
                If rowCount = 10 Then
                    Response.Write "<p>... mostrando apenas as primeiras 10 linhas</p>"
                End If
            Else
                Response.Write "<p class='empty'>Nenhum dado encontrado para stepID " & stepID & "</p>"
            End If
        Else
            Response.Write "<p>Erro ao acessar tabela: " & Err.Description & "</p>"
        End If
        
        Err.Clear
        On Error Goto 0
        
        Response.Write "</div>"
    Next
    
    ' Verificar tambem a tabela principal de metodos
    Response.Write "<div class='box'>"
    Response.Write "<h3>Verificando tabela tiamat_fta_methods</h3>"
    
    On Error Resume Next
    sql = "SELECT * FROM tiamat_fta_methods WHERE stepID = " & stepID
    Call getRecordSet(sql, rs)
    
    If Err.Number = 0 And Not rs.EOF Then
        Response.Write "<p class='found'><strong>Registro do metodo encontrado!</strong></p>"
        Response.Write "<p>MethodName: " & rs("methodName") & "</p>"
        Response.Write "<p>Status: " & rs("status") & "</p>"
    End If
    On Error Goto 0
    Response.Write "</div>"
    
    If Not found Then
        Response.Write "<div class='box' style='background: #fff3cd;'>"
        Response.Write "<h3>Nenhum dado encontrado!</h3>"
        Response.Write "<p>Possiveis causas:</p>"
        Response.Write "<ul>"
        Response.Write "<li>As ideias foram salvas em outro stepID</li>"
        Response.Write "<li>As ideias foram deletadas</li>"
        Response.Write "<li>O metodo nao salvou as ideias corretamente</li>"
        Response.Write "</ul>"
        Response.Write "</div>"
    End If
    %>
    
    <div class="box">
        <h3>Proximos passos:</h3>
        <ol>
            <li>Se encontrou dados, anote o nome da tabela e dos campos</li>
            <li>Atualize o codigo de captura para usar a tabela correta</li>
            <li>Execute a captura novamente</li>
        </ol>
    </div>
</body>
</html>