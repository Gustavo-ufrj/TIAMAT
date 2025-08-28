<!DOCTYPE html>
<html>
<head>
    <title>Test Buttons</title>
    <link href="https://cdn.jsdelivr.net/npm/bootstrap@5.1.3/dist/css/bootstrap.min.css" rel="stylesheet">
</head>
<body>
<div class="container p-4">
    <h2>Teste de Botões e JavaScript</h2>
    
    <div class="card mb-3">
        <div class="card-header">Teste 1: JavaScript Básico</div>
        <div class="card-body">
            <button onclick="alert('Teste 1 OK!');" class="btn btn-primary">Teste Alert Simples</button>
            <button onclick="document.getElementById('campo1').value = 'FUNCIONOU!';" class="btn btn-success">Teste Inserir Texto</button>
            <input type="text" id="campo1" class="form-control mt-2" placeholder="Texto aparecerá aqui">
        </div>
    </div>
    
    <div class="card mb-3">
        <div class="card-header">Teste 2: Função JavaScript</div>
        <div class="card-body">
            <button onclick="testeFunction();" class="btn btn-warning">Teste Função</button>
            <textarea id="campo2" class="form-control mt-2" rows="3" placeholder="Template aparecerá aqui"></textarea>
        </div>
    </div>
    
    <div class="card mb-3">
        <div class="card-header">Teste 3: Template Completo</div>
        <div class="card-body">
            <button id="btnTemplate3" class="btn btn-info">Teste Template Completo</button>
            <textarea id="campo3" class="form-control mt-2" rows="5" placeholder="Template completo aparecerá aqui"></textarea>
        </div>
    </div>
    
    <div class="card mb-3">
        <div class="card-header">Teste 4: Diferentes Métodos</div>
        <div class="card-body">
            <button type="button" onclick="metodo1();" class="btn btn-secondary">Método 1: onclick inline</button>
            <button type="button" id="btnMetodo2" class="btn btn-secondary">Método 2: addEventListener</button>
            <button type="button" id="btnMetodo3" class="btn btn-secondary">Método 3: jQuery (se disponível)</button>
            <input type="button" value="Método 4: Input button" onclick="metodo4();" class="btn btn-secondary">
            <textarea id="campo4" class="form-control mt-2" rows="3"></textarea>
        </div>
    </div>
    
    <div class="card">
        <div class="card-header">Console Log</div>
        <div class="card-body">
            <div id="logArea" style="background: #f0f0f0; padding: 10px; min-height: 100px; font-family: monospace;">
                Logs aparecerão aqui...<br>
            </div>
        </div>
    </div>
</div>

<script type="text/javascript">
// Função de log customizada
function addLog(msg) {
    var logArea = document.getElementById('logArea');
    logArea.innerHTML += msg + '<br>';
    console.log(msg);
}

addLog('Script carregado');

// Teste de função simples
function testeFunction() {
    addLog('testeFunction() chamada');
    var campo = document.getElementById('campo2');
    if (campo) {
        campo.value = '=== TEMPLATE TESTE ===\nLinha 1\nLinha 2\nLinha 3';
        alert('Template inserido!');
    } else {
        alert('Campo não encontrado!');
    }
}

// Métodos diferentes
function metodo1() {
    addLog('Método 1 (onclick inline) funcionou');
    document.getElementById('campo4').value += 'Método 1 OK\n';
}

function metodo4() {
    addLog('Método 4 (input button) funcionou');
    document.getElementById('campo4').value += 'Método 4 OK\n';
}

// Quando o DOM estiver pronto
document.addEventListener('DOMContentLoaded', function() {
    addLog('DOM carregado');
    
    // Método 2: addEventListener
    var btn2 = document.getElementById('btnMetodo2');
    if (btn2) {
        btn2.addEventListener('click', function() {
            addLog('Método 2 (addEventListener) funcionou');
            document.getElementById('campo4').value += 'Método 2 OK\n';
        });
        addLog('Listener do Método 2 adicionado');
    }
    
    // Método 3: jQuery (se disponível)
    if (typeof jQuery !== 'undefined') {
        $('#btnMetodo3').click(function() {
            addLog('Método 3 (jQuery) funcionou');
            $('#campo4').val($('#campo4').val() + 'Método 3 OK\n');
        });
        addLog('jQuery disponível - Listener do Método 3 adicionado');
    } else {
        addLog('jQuery NÃO disponível');
        // Fallback sem jQuery
        document.getElementById('btnMetodo3').addEventListener('click', function() {
            addLog('Método 3 (fallback sem jQuery) funcionou');
            document.getElementById('campo4').value += 'Método 3 (sem jQuery) OK\n';
        });
    }
    
    // Template completo
    document.getElementById('btnTemplate3').addEventListener('click', function() {
        addLog('Template completo clicado');
        var texto = '=== CENÁRIO TESTE ===\n\n';
        texto += 'Referências: 5\n';
        texto += 'Step: 50378\n\n';
        texto += '=== TÍTULOS ===\n';
        texto += '1. Título de teste 1\n';
        texto += '2. Título de teste 2\n\n';
        texto += '=== AUTORES ===\n';
        texto += 'Silva, J., Santos, M.\n\n';
        texto += '=== PERÍODO ===\n';
        texto += '2016-2024\n\n';
        texto += '=== DESCRIÇÃO ===\n';
        texto += '[Seu cenário aqui]';
        
        document.getElementById('campo3').value = texto;
        addLog('Template inserido com sucesso');
        alert('Template completo inserido!');
    });
});

// Teste se o script chegou até o fim
addLog('Script completamente carregado');
</script>

<!-- Teste com jQuery do CDN -->
<script src="https://code.jquery.com/jquery-3.6.0.min.js"></script>
<script>
if (typeof jQuery !== 'undefined') {
    $(document).ready(function() {
        addLog('jQuery ready executado');
    });
}
</script>

</body>
</html>