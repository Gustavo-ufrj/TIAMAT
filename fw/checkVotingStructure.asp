<!--#include virtual="/system.asp"-->
<%
Response.Buffer = True
%>

<!DOCTYPE html>
<html>
<head>
    <title>Verificar Estrutura Voting</title>
    <style>
        body { font-family: Arial; padding: 20px; }
        .box { background: #f0f0f0; padding: 15px; margin: 10px 0; }
        .success { color: green; }
        .error { color: red; }
        pre { background: white; padding: 10px; border: 1px solid #ddd; }
    </style>
</head>
<body>
    <h1>Verificar Estrutura da Tabela de Votacao</h1>
    
    <div class="box">
        <h3>1. Estrutura atual de T_FTA_METHOD_BRAINSTORMING_VOTING:</h3>
        <%
        On Error Resume Next
        Dim rs
        
        Call getRecordSet("SELECT TOP 1 * FROM T_FTA_METHOD_BRAINSTORMING_VOTING", rs)
        
        If Err.Number = 0 And Not rs.EOF Then
            Response.Write "<p>Campos existentes:</p><ul>"
            Dim i
            For i = 0 to rs.Fields.Count - 1
                Response.Write "<li>" & rs.Fields(i).Name & " (Type: " & rs.Fields(i).Type & ")</li>"
            Next
            Response.Write "</ul>"
        Else
            Response.Write "<p class='error'>Erro ao acessar tabela: " & Err.Description & "</p>"
        End If
        Err.Clear
        %>
    </div>
    
    <div class="box">
        <h3>2. SQL para corrigir o problema:</h3>
        <p>Se a coluna voteDate nao existe, execute este comando no SQL Server:</p>
        <pre>
-- Adicionar coluna voteDate se nao existir
ALTER TABLE T_FTA_METHOD_BRAINSTORMING_VOTING 
ADD voteDate DATETIME DEFAULT GETDATE();
        </pre>
        
        <p>Ou, se preferir ignorar a data, modifique o codigo que esta dando erro para remover a referencia a voteDate.</p>
    </div>
    
    <div class="box">
        <h3>3. Verificar ideias no Brainstorming 70387:</h3>
        <%
        ' Buscar brainstormingID
        Dim brainstormingID
        brainstormingID = 0
        
        Call getRecordSet("SELECT brainstormingID FROM T_FTA_METHOD_BRAINSTORMING WHERE stepID = 70387", rs)
        If Not rs.EOF Then
            brainstormingID = rs("brainstormingID")
        End If
        
        Response.Write "<p>BrainstormingID: <strong>" & brainstormingID & "</strong></p>"
        
        If brainstormingID > 0 Then
            ' Contar ideias
            Dim count
            count = 0
            Call getRecordSet("SELECT COUNT(*) as total FROM T_FTA_METHOD_BRAINSTORMING_IDEAS WHERE brainstormingID = " & brainstormingID, rs)
            If Not rs.EOF Then count = rs("total")
            
            Response.Write "<p>Total de ideias: <strong>" & count & "</strong></p>"
            
            If count > 0 Then
                Response.Write "<p class='success'>As ideias existem! Elas precisam ser capturadas para o Dublin Core.</p>"
            End If
        End If
        %>
    </div>
    
    <div class="box">
        <h3>4. Solucao rapida para capturar as ideias:</h3>
        <p>Execute este SQL diretamente no banco para capturar as ideias do Brainstorming 70387:</p>
        <pre>
-- Inserir ideias do Brainstorming no Dublin Core
INSERT INTO tiamat_dublin_core (stepID, dc_title, dc_type, dc_date)
SELECT 
    2, -- usando stepID 2 que sabemos que existe
    CASE 
        WHEN title IS NOT NULL AND description IS NOT NULL 
        THEN title + ' - ' + description
        WHEN title IS NOT NULL THEN title
        ELSE description
    END,
    'brainstorming_new',
    GETDATE()
FROM T_FTA_METHOD_BRAINSTORMING_IDEAS
WHERE brainstormingID = <%=brainstormingID%>;
        </pre>
    </div>
    
    <div class="box success">
        <h3>Resumo do Problema:</h3>
        <ol>
            <li>O sistema esta tentando usar a coluna 'voteDate' que nao existe</li>
            <li>As ideias estao sendo criadas corretamente</li>
            <li>O problema esta apenas no processo de votacao</li>
            <li>Para o Futures Wheel funcionar, precisamos capturar as ideias manualmente</li>
        </ol>
    </div>
</body>
</html>