<!--#include virtual="/system.asp"-->
<!--#include file="INC_FUTURES_WHEEL.inc"-->

<%
Response.Charset = "UTF-8"
Response.CodePage = 65001

Dim stepID
stepID = Request.QueryString("stepID")

If stepID = "" Then
    Response.Write("Error: stepID is required")
    Response.End
End If
%>

<!DOCTYPE html>
<html>
<head>
    <meta http-equiv="Content-Type" content="text/html; charset=utf-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Dados Dispon?veis dos M?todos Anteriores</title>
    <link href="https://cdn.jsdelivr.net/npm/bootstrap@5.1.3/dist/css/bootstrap.min.css" rel="stylesheet">
    <link href="https://cdn.jsdelivr.net/npm/bootstrap-icons@1.7.2/font/bootstrap-icons.css" rel="stylesheet">
    <style>
        body {
            font-family: Arial, sans-serif;
            background: #f5f5f5;
            padding: 20px;
        }
        
        .container {
            background: white;
            border-radius: 10px;
            box-shadow: 0 2px 10px rgba(0,0,0,0.1);
            padding: 20px;
            max-width: 1200px;
            margin: 0 auto;
        }
        
        h1 {
            color: #333;
            border-bottom: 2px solid #007bff;
            padding-bottom: 10px;
            margin-bottom: 20px;
            font-size: 1.5rem;
        }
        
        h2 {
            color: #666;
            font-size: 1.2rem;
            margin-top: 20px;
            margin-bottom: 15px;
        }
        
        .method-section {
            margin-bottom: 30px;
        }
        
        .reference-item {
            background: #f8f9fa;
            padding: 12px;
            margin-bottom: 10px;
            border-left: 3px solid #007bff;
            border-radius: 5px;
            cursor: pointer;
            transition: all 0.3s ease;
        }
        
        .reference-item:hover {
            background: #e9ecef;
            transform: translateX(5px);
        }
        
        .reference-date {
            color: #28a745;
            font-weight: bold;
            margin-right: 10px;
        }
        
        .reference-authors {
            color: #6c757d;
            font-style: italic;
            margin-right: 10px;
        }
        
        .reference-title {
            color: #333;
        }
        
        .scenario-item {
            background: #fff3cd;
            padding: 12px;
            margin-bottom: 10px;
            border-left: 3px solid #ffc107;
            border-radius: 5px;
            cursor: pointer;
        }
        
        .scenario-item:hover {
            background: #ffeaa7;
        }
        
        .idea-item {
            background: #d1ecf1;
            padding: 12px;
            margin-bottom: 10px;
            border-left: 3px solid #17a2b8;
            border-radius: 5px;
            cursor: pointer;
        }
        
        .idea-item:hover {
            background: #bee5eb;
        }
        
        .empty-state {
            text-align: center;
            color: #999;
            padding: 40px;
            font-style: italic;
        }
        
        .close-btn {
            position: fixed;
            top: 20px;
            right: 20px;
            z-index: 1000;
        }
        
        .copy-toast {
            position: fixed;
            top: 50%;
            left: 50%;
            transform: translate(-50%, -50%);
            background: #28a745;
            color: white;
            padding: 10px 20px;
            border-radius: 5px;
            z-index: 2000;
            display: none;
        }
        
        .summary-box {
            background: #e3f2fd;
            padding: 15px;
            border-radius: 5px;
            margin-bottom: 20px;
        }
        
        .summary-box strong {
            color: #1976d2;
        }
        
        .description-text {
            color: #666;
            font-size: 0.9em;
            margin-top: 5px;
            padding-left: 10px;
            border-left: 2px solid #ddd;
        }
    </style>
</head>
<body>
    <button type="button" class="btn btn-danger close-btn" onclick="window.close()">
        <i class="bi bi-x-lg"></i> Fechar
    </button>
    
    <div class="container">
        <h1>Dados Dispon?veis dos M?todos Anteriores</h1>
        <p>Workflow ID: 30143 | Step Brainstorming: 60382</p>
        
        <div class="summary-box">
            <strong>?? Dados Bibliom?tricos:</strong> 6 refer?ncias<br>
            <strong>?? Cen?rios Desenvolvidos:</strong> 1 cen?rio<br>
            <strong>?? Ideias do Brainstorming:</strong> Em desenvolvimento
        </div>
        
        <!-- Dados Bibliom?tricos -->
        <div class="method-section">
            <h2>?? Dados Bibliom?tricos (Step 50379)</h2>
            <p class="text-muted">Total de Refer?ncias: 6</p>
            <div>
                <strong>Publica??es Analisadas:</strong>
                
                <div class="reference-item" onclick="copyToClipboard('Machine Learning Algorithms for Innovation Forecasting in Emerging Technologies')">
                    <span class="reference-date">2024</span>
                    <span class="reference-authors">JOHNSON et al.</span>
                    <span class="reference-title">"Machine Learning Algorithms for Innovation Forecasting in Emerging Technologies"</span>
                </div>
                
                <div class="reference-item" onclick="copyToClipboard('Bibliometric Analysis of Sustainable Technology Development: Patterns and Trends 2020-2024')">
                    <span class="reference-date">2024</span>
                    <span class="reference-authors">M?LLER et al.</span>
                    <span class="reference-title">Bibliometric Analysis of Sustainable Technology Development: Patterns and Trends 2020-2024</span>
                </div>
                
                <div class="reference-item" onclick="copyToClipboard('Blockchain Applications in Supply Chain Transparency')">
                    <span class="reference-date">2024</span>
                    <span class="reference-authors"></span>
                    <span class="reference-title">Blockchain Applications in Supply Chain Transparency</span>
                </div>
                
                <div class="reference-item" onclick="copyToClipboard('Artificial Intelligence Applications in Future Technology Assessment: A Systematic Literature Review')">
                    <span class="reference-date">2023</span>
                    <span class="reference-authors">SILVA et al.</span>
                    <span class="reference-title">"Artificial Intelligence Applications in Future Technology Assessment: A Systematic Literature Review"</span>
                </div>
                
                <div class="reference-item" onclick="copyToClipboard('Digital Twin Technology in Manufacturing: A Comprehensive Review')">
                    <span class="reference-date">2023</span>
                    <span class="reference-authors"></span>
                    <span class="reference-title">Digital Twin Technology in Manufacturing: A Comprehensive Review</span>
                </div>
                
                <div class="reference-item" onclick="copyToClipboard('Scenario Planning Methodologies for Technology Assessment: A Meta-Analysis')">
                    <span class="reference-date">2022</span>
                    <span class="reference-authors">GARC?A-L?PEZ et al.</span>
                    <span class="reference-title">"Scenario Planning Methodologies for Technology Assessment: A Meta-Analysis"</span>
                </div>
                
                <p class="mt-3"><strong>Autores Principais:</strong></p>
                <p class="text-muted">Johnson, K.L., Chen, W., Rodriguez, A.M., Thompson, R.J., M?ller, H., Nakamura, T., Singh, P.K., Silva, M.A., Santos, J.P., Oliveira, C.R., Garc?a-L?pez, F., Anderson, L.M., Kim, S.H., Dubois, P.</p>
                
                <p><strong>Per?odo:</strong> 2022 - 2024</p>
            </div>
        </div>
        
        <!-- Cen?rios Desenvolvidos -->
        <div class="method-section">
            <h2>?? Cen?rios Desenvolvidos (Step 50379)</h2>
            <div class="scenario-item" onclick="copyToClipboard('cenario teste 001')">
                <strong>cenario teste 001</strong>
                <div class="description-text">
                    === CEN?RIO BASEADO EM AN?LISE BIBLIOM?TRICA ===<br>
                    Este cen?rio foi desenvolvido com base em 5 refer?ncias bibliogr?ficas coletadas no step 50378 do workflow.<br><br>
                    
                    <strong>PUBLICA??ES ANALISADAS:</strong><br>
                    1. 'Machine Learning Algorithms for Innovation Forecasting in Emerging Technologies' (2024)<br>
                    2. Bibliometric Analysis of Sustainable Technology Development: Patterns and Trends 2020-2024 (2024)<br>
                    3. 'Artificial Intelligence Applications in Future Technology Assessment: A Systematic Literature Review' (2023)<br>
                    4. 'Scenario Planning Methodologies for Technology Assessment: A Meta-Analysis' (2022)<br>
                    5. teste01 (2016)<br><br>
                    
                    <strong>DESCRI??O DO CEN?RIO:</strong><br>
                    A converg?ncia entre intelig?ncia artificial, metodologias de planejamento de cen?rios e o foco crescente na sustentabilidade tecnol?gica molda um futuro no qual a avalia??o tecnol?gica ser? predominantemente automatizada, preditiva e orientada por dados...<br><br>
                    
                    <a href="#" onclick="event.preventDefault(); alert('Clique para copiar o t?tulo do cen?rio');">Ver detalhes completos</a>
                </div>
            </div>
        </div>
        
        <!-- Como Usar -->
        <div class="alert alert-info mt-4">
            <i class="bi bi-info-circle"></i>
            <strong>Como Usar Estes Dados no Futures Wheel:</strong><br>
            - <strong>Ao criar eventos:</strong> Use as referencias bibliometricas para identificar tendencias tecnologicas emergentes<br>
            - <strong>Primeiro nivel (eventos primarios):</strong> Baseie-se nos cenarios desenvolvidos<br>
            - <strong>Segundo/terceiro nivel:</strong> Explore consequencias e implicacoes das tecnologias identificadas<br>
            - <strong>Referencia manual:</strong> Clique em qualquer item para copia-lo e usar como base para seus eventos
        </div>
    </div>
    
    <div class="copy-toast" id="copyToast">
        <i class="bi bi-check-circle"></i> Copiado!
    </div>
    
    <script>
        function copyToClipboard(text) {
            // Limpar o texto de caracteres especiais
            text = text.replace(/['"]/g, '');
            
            if (navigator.clipboard && window.isSecureContext) {
                navigator.clipboard.writeText(text).then(function() {
                    showCopyToast();
                });
            } else {
                var textArea = document.createElement("textarea");
                textArea.value = text;
                textArea.style.position = 'fixed';
                textArea.style.left = '-999999px';
                document.body.appendChild(textArea);
                textArea.focus();
                textArea.select();
                try {
                    document.execCommand('copy');
                    showCopyToast();
                } catch (err) {
                    console.error('Erro ao copiar', err);
                }
                document.body.removeChild(textArea);
            }
        }
        
        function showCopyToast() {
            var toast = document.getElementById('copyToast');
            toast.style.display = 'block';
            setTimeout(function() {
                toast.style.display = 'none';
            }, 2000);
        }
    </script>
</body>
</html>