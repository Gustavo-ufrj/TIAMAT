<!--#include file="system.asp"-->
<%
'=========================================
' SETUP CORRIGIDO PARA TABELAS COM IDENTITY
' Criar dados de teste respeitando IDENTITY
'=========================================

Response.ContentType = "text/html; charset=utf-8"
%>
<!DOCTYPE html>
<html>
<head>
    <title>Setup Corrigido - TIAMAT</title>
    <style>
        body { font-family: Arial, sans-serif; margin: 20px; }
        .success { background-color: #d4edda; border: 1px solid #c3e6cb; padding: 10px; margin: 10px 0; border-radius: 4px; }
        .error { background-color: #f8d7da; border: 1px solid #f5c6cb; padding: 10px; margin: 10px 0; border-radius: 4px; }
        .info { background-color: #d1ecf1; border: 1px solid #bee5eb; padding: 10px; margin: 10px 0; border-radius: 4px; }
    </style>
</head>
<body>
    <h1>🔧 Setup Corrigido - TIAMAT Output Manager</h1>
    
    <%
    Sub WriteStep(stepNumber, title, success, details)
        Response.Write "<div class='"
        If success Then
            Response.Write "success'>✅ "
        Else
            Response.Write "error'>❌ "
        End If
        Response.Write "<strong>" & stepNumber & ". " & title & "</strong><br>"
        Response.Write details & "</div>"
    End Sub
    
    Dim testWorkflowID, testStepID
    
    ' PASSO 1: Verificar workflow existente ou criar sem ID específico
    Dim rs
    On Error Resume Next
    Call getRecordSet("SELECT TOP 1 workflowID FROM tiamat_workflows ORDER BY workflowID DESC", rs)
    
    If Not rs.eof Then
        testWorkflowID = rs("workflowID")
        Call WriteStep(1, "Usar Workflow Existente", True, "Usando workflowID existente: " & testWorkflowID)
    Else
        ' Criar novo workflow sem especificar ID
        Dim sql
        sql = "INSERT INTO tiamat_workflows (description, goal, status, created, created_by) " & _
              "VALUES ('Test Workflow for OutputManager', 'Testing TIAMAT Output Manager', '1', GETDATE(), 'system')"
        
        Call ExecuteSQL(sql)
        If Err.Number = 0 Then
            ' Buscar o ID que foi criado
            Call getRecordSet("SELECT TOP 1 workflowID FROM tiamat_workflows ORDER BY workflowID DESC", rs)
            If Not rs.eof Then
                testWorkflowID = rs("workflowID")
                Call WriteStep(1, "Criar Novo Workflow", True, "Workflow criado com ID: " & testWorkflowID)
            End If
        Else
            Call WriteStep(1, "Criar Workflow", False, "Erro: " & Err.Description)
        End If
    End If
    Err.Clear
    
    ' PASSO 2: Verificar step existente ou criar novo
    Call getRecordSet("SELECT TOP 1 stepID FROM tiamat_steps WHERE workflowID = " & testWorkflowID & " ORDER BY stepID DESC", rs)
    
    If Not rs.eof Then
        testStepID = rs("stepID")
        Call WriteStep(2, "Usar Step Existente", True, "Usando stepID existente: " & testStepID)
    Else
        ' Criar novo step sem especificar ID
        sql = "INSERT INTO tiamat_steps (workflowID, methodID, description, goal, status, created, created_by, sequence_order) " & _
              "VALUES (" & testWorkflowID & ", 1, 'Test Step for OutputManager', 'Testing step for output capture', '1', GETDATE(), 'system', 1)"
        
        Call ExecuteSQL(sql)
        If Err.Number = 0 Then
            ' Buscar o ID que foi criado
            Call getRecordSet("SELECT TOP 1 stepID FROM tiamat_steps WHERE workflowID = " & testWorkflowID & " ORDER BY stepID DESC", rs)
            If Not rs.eof Then
                testStepID = rs("stepID")
                Call WriteStep(2, "Criar Novo Step", True, "Step criado com ID: " & testStepID)
            End If
        Else
            Call WriteStep(2, "Criar Step", False, "Erro: " & Err.Description)
        End If
    End If
    Err.Clear
    
    ' PASSO 3: Testar captura simples
    If testStepID <> "" Then
        On Error Resume Next
        
        ' Tentar inserir um output JSON simples direto no banco
        Dim testJSON
        testJSON = "{""test"": ""direct insert"", ""timestamp"": """ & Now() & """, ""status"": ""testing""}"
        testJSON = Replace(testJSON, "'", "''") ' Escapar aspas
        
        sql = "UPDATE tiamat_steps SET output_json = '" & testJSON & "', updated = GETDATE() WHERE stepID = " & testStepID
        Call ExecuteSQL(sql)
        
        If Err.Number = 0 Then
            Call WriteStep(3, "Teste Direto no Banco", True, "Output JSON inserido diretamente no stepID " & testStepID)
        Else
            Call WriteStep(3, "Teste Direto no Banco", False, "Erro: " & Err.Description)
        End If
        Err.Clear
    End If
    
    ' PASSO 4: Verificar se o output foi salvo
    Call getRecordSet("SELECT output_json FROM tiamat_steps WHERE stepID = " & testStepID & " AND output_json IS NOT NULL", rs)
    
    If Not rs.eof Then
        Call WriteStep(4, "Verificar Output Salvo", True, "Output encontrado no banco: " & Left(rs("output_json"), 100) & "...")
    Else
        Call WriteStep(4, "Verificar Output Salvo", False, "Nenhum output encontrado no banco")
    End If
    
    ' PASSO 5: Criar arquivo de fallback
    On Error Resume Next
    Dim fso, tempFile, tempPath
    tempPath = "C:\Windows\TEMP\tiamat\"
    
    Set fso = Server.CreateObject("Scripting.FileSystemObject")
    If Not fso.FolderExists(tempPath) Then
        fso.CreateFolder(tempPath)
    End If
    
    If fso.FolderExists(tempPath) Then
        Set tempFile = fso.CreateTextFile(tempPath & "output_" & testStepID & ".json", True)
        tempFile.Write("{""fallback_test"": true, ""stepID"": " & testStepID & ", ""created"": """ & Now() & """}")
        tempFile.Close
        
        If Err.Number = 0 Then
            Call WriteStep(5, "Criar Arquivo Fallback", True, "Arquivo criado: " & tempPath & "output_" & testStepID & ".json")
        Else
            Call WriteStep(5, "Criar Arquivo Fallback", False, "Erro: " & Err.Description)
        End If
    Else
        Call WriteStep(5, "Criar Arquivo Fallback", False, "Diretório não disponível")
    End If
    
    Set tempFile = Nothing
    Set fso = Nothing
    Err.Clear
    %>
    
    <div class="info">
        <h3>📊 Resultados do Setup</h3>
        <p><strong>Workflow ID para testes:</strong> <%= testWorkflowID %></p>
        <p><strong>Step ID para testes:</strong> <%= testStepID %></p>
        <p><strong>Diretório temp:</strong> C:\Windows\TEMP\tiamat\</p>
    </div>
    
    <div class="info">
        <h3>🔗 Próximos Testes</h3>
        <p>Agora use estes IDs nos testes:</p>
        <ul>
            <li><a href="test_manual_simple.asp?action=test_capture&stepID=<%= testStepID %>">Testar Captura com stepID <%= testStepID %></a></li>
            <li><a href="test_manual_simple.asp?action=test_retrieve&stepID=<%= testStepID %>">Testar Recuperação com stepID <%= testStepID %></a></li>
            <li><a href="test_manual_simple.asp?action=test_global&stepID=<%= testStepID %>">Testar Funções Globais com stepID <%= testStepID %></a></li>
        </ul>
    </div>
    
    <div class="info">
        <h3>🐛 Debug Info</h3>
        <p>Se os testes ainda falharem, o problema pode ser:</p>
        <ul>
            <li><strong>Permissões de escrita</strong> - tanto no banco quanto no arquivo</li>
            <li><strong>Tamanho do campo</strong> - output_json pode ter limite de caracteres</li>
            <li><strong>Transações</strong> - pode precisar de commit explícito</li>
            <li><strong>Aspas no JSON</strong> - problema de escape de caracteres</li>
        </ul>
    </div>
</body>
</html>