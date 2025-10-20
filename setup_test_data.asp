<!--#include file="system.asp"-->
<%
'=========================================
' SETUP TEST DATA - Criar dados de teste para o OutputManager
'=========================================

Response.ContentType = "text/html; charset=utf-8"
%>
<!DOCTYPE html>
<html lang="pt-BR">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Setup Test Data - TIAMAT</title>
    <link href="https://cdn.jsdelivr.net/npm/bootstrap@5.1.3/dist/css/bootstrap.min.css" rel="stylesheet">
    <link rel="stylesheet" href="https://cdn.jsdelivr.net/npm/bootstrap-icons@1.7.2/font/bootstrap-icons.css">
</head>
<body>
    <div class="container mt-4">
        <h2><i class="bi bi-database-gear"></i> Setup Test Data</h2>
        <p class="text-muted">Criando dados de teste para o TIAMAT Output Manager</p>
        <hr>
        
        <%
        Sub WriteStep(stepNumber, title, success, details)
            Response.Write "<div class='alert "
            If success Then
                Response.Write "alert-success'><i class='bi bi-check-circle'></i> "
            Else
                Response.Write "alert-danger'><i class='bi bi-x-circle'></i> "
            End If
            Response.Write "<strong>" & stepNumber & ". " & title & "</strong><br>"
            Response.Write details & "</div>"
        End Sub
        
        Dim success, testWorkflowID, testStepID
        testWorkflowID = 999
        testStepID = 999
        
        ' PASSO 1: Verificar se já existem dados de teste
        Dim rs
        On Error Resume Next
        Call getRecordSet("SELECT COUNT(*) as total FROM tiamat_workflows WHERE workflowID = " & testWorkflowID, rs)
        
        If Err.Number = 0 And Not rs.eof Then
            If rs("total") > 0 Then
                Call WriteStep(1, "Verificar Dados Existentes", True, "Workflow de teste já existe (ID: " & testWorkflowID & ")")
            Else
                Call WriteStep(1, "Verificar Dados Existentes", True, "Nenhum dado de teste encontrado - criando novos dados")
            End If
        Else
            Call WriteStep(1, "Verificar Dados Existentes", False, "Erro ao verificar: " & Err.Description)
        End If
        Err.Clear
        
        ' PASSO 2: Criar workflow de teste (corrigido)
        On Error Resume Next
        Dim sql
        
        ' Verificar quais colunas existem na tabela tiamat_workflows
        Call getRecordSet("SELECT COLUMN_NAME FROM INFORMATION_SCHEMA.COLUMNS WHERE TABLE_NAME = 'tiamat_workflows'", rs)
        Dim workflowColumns
        workflowColumns = ""
        While Not rs.eof
            workflowColumns = workflowColumns & rs("COLUMN_NAME") & " "
            rs.movenext
        Wend
        
        Response.Write "<p><small>Colunas disponíveis em tiamat_workflows: " & workflowColumns & "</small></p>"
        
        ' Construir SQL baseado nas colunas disponíveis
        sql = "INSERT INTO tiamat_workflows (workflowID, description"
        
        ' Verificar se coluna goal existe
        If InStr(workflowColumns, "goal") > 0 Then sql = sql & ", goal"
        
        ' Verificar se coluna status existe
        If InStr(workflowColumns, "status") > 0 Then sql = sql & ", status"
        
        ' Verificar se coluna created existe
        If InStr(workflowColumns, "created") > 0 Then sql = sql & ", created"
        
        sql = sql & ") VALUES (" & testWorkflowID & ", 'Test Workflow for OutputManager'"
        
        If InStr(workflowColumns, "goal") > 0 Then sql = sql & ", 'Testing TIAMAT Output Manager functionality'"
        If InStr(workflowColumns, "status") > 0 Then sql = sql & ", 1"
        If InStr(workflowColumns, "created") > 0 Then sql = sql & ", GETDATE()"
        
        sql = sql & ")"
        
        ' Verificar se já existe antes de inserir
        Call getRecordSet("SELECT workflowID FROM tiamat_workflows WHERE workflowID = " & testWorkflowID, rs)
        If rs.eof Then
            Call ExecuteSQL(sql)
            If Err.Number = 0 Then
                Call WriteStep(2, "Criar Workflow de Teste", True, "Workflow criado com sucesso (ID: " & testWorkflowID & ")")
            Else
                Call WriteStep(2, "Criar Workflow de Teste", False, "Erro ao criar workflow: " & Err.Description)
            End If
        Else
            Call WriteStep(2, "Criar Workflow de Teste", True, "Workflow já existe (ID: " & testWorkflowID & ")")
        End If
        Err.Clear
        
        ' PASSO 3: Criar step de teste (corrigido para IDENTITY)
        On Error Resume Next
        
        ' Verificar quais colunas existem na tabela tiamat_steps
        Call getRecordSet("SELECT COLUMN_NAME FROM INFORMATION_SCHEMA.COLUMNS WHERE TABLE_NAME = 'tiamat_steps'", rs)
        Dim stepColumns
        stepColumns = ""
        While Not rs.eof
            stepColumns = stepColumns & rs("COLUMN_NAME") & " "
            rs.movenext
        Wend
        
        Response.Write "<p><small>Colunas disponíveis em tiamat_steps: " & stepColumns & "</small></p>"
        
        ' Verificar se stepID é IDENTITY
        Call getRecordSet("SELECT COLUMNPROPERTY(OBJECT_ID('tiamat_steps'), 'stepID', 'IsIdentity') as IsIdentity", rs)
        Dim isIdentity
        isIdentity = False
        If Not rs.eof Then isIdentity = (rs("IsIdentity") = 1)
        
        ' Verificar se já existe antes de inserir
        Call getRecordSet("SELECT stepID FROM tiamat_steps WHERE stepID = " & testStepID, rs)
        If rs.eof Then
            If isIdentity Then
                ' Se é IDENTITY, permitir inserção explícita
                Call ExecuteSQL("SET IDENTITY_INSERT tiamat_steps ON")
                If Err.Number <> 0 Then
                    ' Se não pode usar IDENTITY_INSERT, inserir sem especificar stepID
                    sql = "INSERT INTO tiamat_steps (workflowID, description"
                    If InStr(stepColumns, "methodID") > 0 Then sql = sql & ", methodID"
                    If InStr(stepColumns, "goal") > 0 Then sql = sql & ", goal"
                    If InStr(stepColumns, "status") > 0 Then sql = sql & ", status"
                    If InStr(stepColumns, "created") > 0 Then sql = sql & ", created"
                    If InStr(stepColumns, "created_by") > 0 Then sql = sql & ", created_by"
                    If InStr(stepColumns, "sequence_order") > 0 Then sql = sql & ", sequence_order"
                    
                    sql = sql & ") VALUES (" & testWorkflowID & ", 'Test Step for OutputManager'"
                    If InStr(stepColumns, "methodID") > 0 Then sql = sql & ", 1"
                    If InStr(stepColumns, "goal") > 0 Then sql = sql & ", 'Testing step for output capture'"
                    If InStr(stepColumns, "status") > 0 Then sql = sql & ", 1"
                    If InStr(stepColumns, "created") > 0 Then sql = sql & ", GETDATE()"
                    If InStr(stepColumns, "created_by") > 0 Then sql = sql & ", 'system'"
                    If InStr(stepColumns, "sequence_order") > 0 Then sql = sql & ", 1"
                    sql = sql & ")"
                    
                    Call ExecuteSQL(sql)
                    If Err.Number = 0 Then
                        ' Buscar o ID que foi criado
                        Call getRecordSet("SELECT MAX(stepID) as newID FROM tiamat_steps WHERE workflowID = " & testWorkflowID, rs)
                        If Not rs.eof Then testStepID = rs("newID")
                        Call WriteStep(3, "Criar Step de Teste", True, "Step criado com ID automático: " & testStepID)
                    Else
                        Call WriteStep(3, "Criar Step de Teste", False, "Erro ao criar step: " & Err.Description)
                    End If
                Else
                    ' Pode usar IDENTITY_INSERT
                    sql = "INSERT INTO tiamat_steps (stepID, workflowID, description"
                    If InStr(stepColumns, "methodID") > 0 Then sql = sql & ", methodID"
                    If InStr(stepColumns, "goal") > 0 Then sql = sql & ", goal"
                    If InStr(stepColumns, "status") > 0 Then sql = sql & ", status"
                    If InStr(stepColumns, "created") > 0 Then sql = sql & ", created"
                    If InStr(stepColumns, "created_by") > 0 Then sql = sql & ", created_by"
                    If InStr(stepColumns, "sequence_order") > 0 Then sql = sql & ", sequence_order"
                    
                    sql = sql & ") VALUES (" & testStepID & ", " & testWorkflowID & ", 'Test Step for OutputManager'"
                    If InStr(stepColumns, "methodID") > 0 Then sql = sql & ", 1"
                    If InStr(stepColumns, "goal") > 0 Then sql = sql & ", 'Testing step for output capture'"
                    If InStr(stepColumns, "status") > 0 Then sql = sql & ", 1"
                    If InStr(stepColumns, "created") > 0 Then sql = sql & ", GETDATE()"
                    If InStr(stepColumns, "created_by") > 0 Then sql = sql & ", 'system'"
                    If InStr(stepColumns, "sequence_order") > 0 Then sql = sql & ", 1"
                    sql = sql & ")"
                    
                    Call ExecuteSQL(sql)
                    Call ExecuteSQL("SET IDENTITY_INSERT tiamat_steps OFF")
                    
                    If Err.Number = 0 Then
                        Call WriteStep(3, "Criar Step de Teste", True, "Step criado com sucesso (ID: " & testStepID & ")")
                    Else
                        Call WriteStep(3, "Criar Step de Teste", False, "Erro ao criar step: " & Err.Description)
                    End If
                End If
            Else
                ' Não é IDENTITY, inserir normalmente
                sql = "INSERT INTO tiamat_steps (stepID, workflowID, description"
                If InStr(stepColumns, "methodID") > 0 Then sql = sql & ", methodID"
                If InStr(stepColumns, "goal") > 0 Then sql = sql & ", goal"
                If InStr(stepColumns, "status") > 0 Then sql = sql & ", status"
                If InStr(stepColumns, "created") > 0 Then sql = sql & ", created"
                If InStr(stepColumns, "created_by") > 0 Then sql = sql & ", created_by"
                If InStr(stepColumns, "sequence_order") > 0 Then sql = sql & ", sequence_order"
                
                sql = sql & ") VALUES (" & testStepID & ", " & testWorkflowID & ", 'Test Step for OutputManager'"
                If InStr(stepColumns, "methodID") > 0 Then sql = sql & ", 1"
                If InStr(stepColumns, "goal") > 0 Then sql = sql & ", 'Testing step for output capture'"
                If InStr(stepColumns, "status") > 0 Then sql = sql & ", 1"
                If InStr(stepColumns, "created") > 0 Then sql = sql & ", GETDATE()"
                If InStr(stepColumns, "created_by") > 0 Then sql = sql & ", 'system'"
                If InStr(stepColumns, "sequence_order") > 0 Then sql = sql & ", 1"
                sql = sql & ")"
                
                Call ExecuteSQL(sql)
                If Err.Number = 0 Then
                    Call WriteStep(3, "Criar Step de Teste", True, "Step criado com sucesso (ID: " & testStepID & ")")
                Else
                    Call WriteStep(3, "Criar Step de Teste", False, "Erro ao criar step: " & Err.Description)
                End If
            End If
        Else
            Call WriteStep(3, "Criar Step de Teste", True, "Step já existe (ID: " & testStepID & ")")
        End If
        Err.Clear
        
        ' PASSO 4: Criar método FTA de teste
        On Error Resume Next
        
        ' Verificar se tabela tiamat_fta_methods existe
        Call getRecordSet("SELECT TABLE_NAME FROM INFORMATION_SCHEMA.TABLES WHERE TABLE_NAME = 'tiamat_fta_methods'", rs)
        If Not rs.eof Then
            sql = "INSERT INTO tiamat_fta_methods (methodID, name, input_format, output_format, base_folder) " & _
                  "VALUES (1, 'Test Method', 'JSON', 'JSON', '/test/')"
            
            Call getRecordSet("SELECT methodID FROM tiamat_fta_methods WHERE methodID = 1", rs)
            If rs.eof Then
                Call ExecuteSQL(sql)
                If Err.Number = 0 Then
                    Call WriteStep(4, "Criar Método FTA de Teste", True, "Método criado com sucesso (ID: 1)")
                Else
                    Call WriteStep(4, "Criar Método FTA de Teste", False, "Erro ao criar método: " & Err.Description)
                End If
            Else
                Call WriteStep(4, "Criar Método FTA de Teste", True, "Método já existe (ID: 1)")
            End If
        Else
            ' Criar tabela se não existe
            sql = "CREATE TABLE tiamat_fta_methods (" & _
                  "methodID INT PRIMARY KEY, " & _
                  "name VARCHAR(255), " & _
                  "input_format VARCHAR(50), " & _
                  "output_format VARCHAR(50), " & _
                  "base_folder VARCHAR(255))"
            
            Call ExecuteSQL(sql)
            If Err.Number = 0 Then
                ' Inserir método de teste
                sql = "INSERT INTO tiamat_fta_methods (methodID, name, input_format, output_format, base_folder) " & _
                      "VALUES (1, 'Test Method', 'JSON', 'JSON', '/test/')"
                Call ExecuteSQL(sql)
                
                Call WriteStep(4, "Criar Método FTA de Teste", True, "Tabela e método criados com sucesso")
            Else
                Call WriteStep(4, "Criar Método FTA de Teste", False, "Erro ao criar tabela: " & Err.Description)
            End If
        End If
        Err.Clear
        
        ' PASSO 5: Alternativa para diretório temp (usar diretório do sistema)
        On Error Resume Next
        
        ' Tentar diretórios alternativos se /temp/ falhar
        Dim tempPaths(3), tempPath, i, foundPath
        tempPaths(0) = "/temp/"
        tempPaths(1) = "/uploads/"
        tempPaths(2) = "/data/"
        tempPaths(3) = "/cache/"
        
        foundPath = False
        
        For i = 0 To 3
            tempPath = Server.MapPath(tempPaths(i))
            Set fso = Server.CreateObject("Scripting.FileSystemObject")
            
            If fso.FolderExists(tempPath) Then
                Call WriteStep(5, "Verificar Diretório", True, "Diretório encontrado: " & tempPath)
                foundPath = True
                Exit For
            Else
                ' Tentar criar
                On Error Resume Next
                fso.CreateFolder(tempPath)
                If Err.Number = 0 Then
                    Call WriteStep(5, "Criar Diretório", True, "Diretório criado: " & tempPath)
                    foundPath = True
                    Exit For
                Else
                    ' Ignorar erro e tentar próximo
                    Err.Clear
                End If
            End If
            Set fso = Nothing
        Next
        
        If Not foundPath Then
            ' Usar diretório temporário do Windows
            Dim wshShell, winTempPath
            Set wshShell = Server.CreateObject("WScript.Shell")
            On Error Resume Next
            winTempPath = wshShell.ExpandEnvironmentStrings("%TEMP%") & "\tiamat\"
            
            Set fso = Server.CreateObject("Scripting.FileSystemObject")
            If Not fso.FolderExists(winTempPath) Then
                fso.CreateFolder(winTempPath)
            End If
            
            If Err.Number = 0 Then
                Call WriteStep(5, "Usar Temp do Windows", True, "Usando: " & winTempPath)
            Else
                Call WriteStep(5, "Diretório Temp", False, "Não foi possível criar nenhum diretório temp")
            End If
            
            Set wshShell = Nothing
            Set fso = Nothing
        End If
        Err.Clear
        
        ' PASSO 6: Teste simples de permissões (sem arquivo)
        On Error Resume Next
        
        ' Simplesmente verificar se consegue acessar o objeto FileSystem
        Set fso = Server.CreateObject("Scripting.FileSystemObject")
        If Err.Number = 0 Then
            Call WriteStep(6, "Testar FileSystem Object", True, "FSO disponível - sistema pode manipular arquivos")
        Else
            Call WriteStep(6, "Testar FileSystem Object", False, "FSO indisponível: " & Err.Description)
        End If
        Set fso = Nothing
        Err.Clear
        
        ' PASSO 7: Verificar dados criados
        On Error Resume Next
        Call getRecordSet("SELECT s.stepID, s.description, w.description as workflow_desc " & _
                         "FROM tiamat_steps s " & _
                         "INNER JOIN tiamat_workflows w ON s.workflowID = w.workflowID " & _
                         "WHERE s.stepID = " & testStepID, rs)
        
        If Not rs.eof And Err.Number = 0 Then
            Call WriteStep(7, "Verificar Dados Criados", True, "Step: " & rs("description") & " | Workflow: " & rs("workflow_desc"))
        Else
            Call WriteStep(7, "Verificar Dados Criados", False, "Erro ao verificar dados: " & Err.Description)
        End If
        Err.Clear
        %>
        
        <div class="alert alert-info mt-4">
            <h5><i class="bi bi-info-circle"></i> Próximos Passos</h5>
            <p>Agora que os dados de teste foram criados, você pode:</p>
            <ol>
                <li><strong>Executar os testes:</strong> <a href="test_output_manager.asp" class="btn btn-sm btn-primary">test_output_manager.asp</a></li>
                <li><strong>Testar manualmente:</strong> <a href="test_manual_output.asp" class="btn btn-sm btn-success">Teste Manual</a></li>
                <li><strong>Ver a interface:</strong> <a href="output_manager_interface.asp" class="btn btn-sm btn-info">Interface</a></li>
            </ol>
        </div>
        
        <div class="alert alert-warning">
            <h6><i class="bi bi-exclamation-triangle"></i> Dados de Teste Criados</h6>
            <ul class="mb-0">
                <li><strong>Workflow ID:</strong> <%= testWorkflowID %></li>
                <li><strong>Step ID:</strong> <%= testStepID %></li>
                <li><strong>Method ID:</strong> 1</li>
                <li><strong>Diretório temp:</strong> <%= Server.MapPath("/temp/") %></li>
            </ul>
        </div>
    </div>
</body>
</html>