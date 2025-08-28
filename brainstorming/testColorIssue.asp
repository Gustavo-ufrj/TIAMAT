<!DOCTYPE html>
<html>
<head>
    <title>Teste de Cor do Workflow</title>
    <style>
        body { font-family: Arial; padding: 20px; }
        .workflow-box {
            width: 150px;
            height: 100px;
            margin: 10px;
            display: inline-block;
            text-align: center;
            line-height: 100px;
            color: white;
            font-weight: bold;
        }
        
        /* Estilos originais do TIAMAT */
        .status-3 { background-color: #6c757d !important; } /* Cinza */
        .status-4 { background-color: #5cb85c !important; } /* Verde */
        .status-5 { background-color: #fd7e14 !important; } /* Laranja */
        
        /* Possível conflito */
        .brainstorming-container { background: white; }
    </style>
</head>
<body>
    <h1>Teste de Cores do Workflow</h1>
    
    <h2>Como deveria aparecer:</h2>
    <div class="workflow-box status-3">Aguardando</div>
    <div class="workflow-box status-4">Ativo</div>
    <div class="workflow-box status-5">Finalizado</div>
    
    <h2>Verificar conflitos CSS:</h2>
    <p>Se o Brainstorming está aparecendo branco, pode ser porque:</p>
    <ol>
        <li>O CSS do indexTiamat está sobrescrevendo o CSS do workflow</li>
        <li>Há um background: white sendo aplicado globalmente</li>
        <li>O status do step não está sendo aplicado corretamente</li>
    </ol>
    
    <h2>Solução:</h2>
    <p>Remover ou ajustar qualquer CSS global que possa estar interferindo.</p>
    
    <hr>
    
    <h2>Verificar iframes:</h2>
    <p>O workflow usa iframes? Se sim, o CSS do indexTiamat pode estar vazando para o pai.</p>
    
    <iframe src="indexTiamat.asp?stepID=60382" width="100%" height="200" style="border: 2px solid red;"></iframe>
    
    <p>Se o iframe acima tem background branco, ele pode estar afetando o workflow.</p>
</body>
</html>