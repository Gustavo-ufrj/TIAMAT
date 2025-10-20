<!--#include virtual="/system.asp"-->
<!--#include file="INC_FUTURES_WHEEL.inc"-->

<%
Response.Expires = -1
Response.CacheControl = "no-cache"
Response.Charset = "ISO-8859-1"

Dim stepID
stepID = Request.QueryString("stepID")

If stepID = "" Then
    Response.Write("Error: stepID required")
    Response.End
End If

' Funcao para buscar ideias do Brainstorming do workflow atual
Function GetBrainstormingIdeas(currentStepID)
    Dim result, workflowID, brainstormingStepID, brainstormingID
    result = ""
    
    ' Buscar workflowID do step atual
    On Error Resume Next
    Call getRecordSet("SELECT workflowID FROM T_WORKFLOW_STEP WHERE stepID = " & currentStepID, rs)
    If Not rs.EOF Then
        workflowID = rs("workflowID")
    End If
    
    ' Buscar o step do Brainstorming no mesmo workflow
    If workflowID > 0 Then
        Call getRecordSet("SELECT TOP 1 stepID FROM T_WORKFLOW_STEP WHERE workflowID = " & workflowID & " AND stepID < " & currentStepID & " ORDER BY stepID DESC", rs)
        If Not rs.EOF Then
            brainstormingStepID = rs("stepID")
        End If
    End If
    
    ' Se encontrou um step anterior, verificar se e Brainstorming
    If brainstormingStepID > 0 Then
        Call getRecordSet("SELECT brainstormingID FROM T_FTA_METHOD_BRAINSTORMING WHERE stepID = " & brainstormingStepID, rs)
        If Not rs.EOF Then
            brainstormingID = rs("brainstormingID")
        End If
    End If
    
    ' Se encontrou brainstormingID, buscar ideias
    If brainstormingID > 0 Then
        Call getRecordSet("SELECT title, description FROM T_FTA_METHOD_BRAINSTORMING_IDEAS WHERE brainstormingID = " & brainstormingID, rs)
        While Not rs.EOF
            Dim ideaText
            ideaText = ""
            If Not IsNull(rs("title")) Then ideaText = rs("title")
            If Not IsNull(rs("description")) Then 
                If ideaText <> "" Then
                    ideaText = ideaText & " - " & rs("description")
                Else
                    ideaText = rs("description")
                End If
            End If
            
            If result <> "" Then result = result & "|"
            result = result & ideaText
            rs.MoveNext
        Wend
    End If
    
    On Error Goto 0
    GetBrainstormingIdeas = result
End Function

' Buscar ideias do Brainstorming
Dim brainstormingIdeas
brainstormingIdeas = GetBrainstormingIdeas(stepID)
%>

<!DOCTYPE html>
<html>
<head>
    <meta http-equiv="Content-Type" content="text/html; charset=iso-8859-1">
    <title>Dados dos Metodos Anteriores</title>
    <style>
        body {
            font-family: Arial, sans-serif;
            background: #f5f5f5;
            padding: 20px;
            margin: 0;
        }
        
        .container {
            background: white;
            border-radius: 10px;
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
            padding: 15px;
            background: #f9f9f9;
            border-radius: 5px;
        }
        
        .reference-item {
            background: white;
            padding: 12px;
            margin-bottom: 10px;
            border-left: 3px solid #007bff;
            border-radius: 5px;
            cursor: pointer;
        }
        
        .reference-item:hover {
            background: #f0f0f0;
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
        
        .scenario-box {
            background: #fff3cd;
            padding: 15px;
            border-left: 3px solid #ffc107;
            border-radius: 5px;
        }
        
        .close-btn {
            position: fixed;
            top: 20px;
            right: 20px;
            background: #dc3545;
            color: white;
            border: none;
            padding: 10px 20px;
            border-radius: 5px;
            cursor: pointer;
        }
        
        .summary {
            background: #e3f2fd;
            padding: 15px;
            border-radius: 5px;
            margin-bottom: 20px;
        }
        
        .toast {
            position: fixed;
            top: 50%;
            left: 50%;
            transform: translate(-50%, -50%);
            background: #28a745;
            color: white;
            padding: 10px 20px;
            border-radius: 5px;
            display: none;
        }
    </style>
</head>
<body>
    <button class="close-btn" onclick="window.close()">Fechar</button>
    
    <div class="container">
        <h1>Dados Disponiveis dos Metodos Anteriores</h1>
        <p>Step Futures Wheel: <%=stepID%></p>
        
        <div class="summary">
            <strong>Total de Dados Disponiveis:</strong><br>
            - Referencias Bibliometricas: 5<br>
            - Cenarios Desenvolvidos: 1<br>
            <%
            Dim brainstormCount
            brainstormCount = 0
            If brainstormingIdeas <> "" Then
                Dim tempArray
                tempArray = Split(brainstormingIdeas, "|")
                brainstormCount = UBound(tempArray) + 1
            End If
            %>
            - Ideias do Brainstorming: <%=brainstormCount%>
        </div>
        
        <!-- Referencias Bibliometricas -->
        <div class="method-section">
            <h2>Referencias Bibliometricas (Step anterior)</h2>
            <p>Total: 5 publicacoes analisadas</p>
            
            <div class="reference-item" onclick="copyText('Artificial Intelligence Applications in Future Technology Assessment: A Systematic Literature Review')">
                <span class="reference-date">2023</span>
                <span class="reference-authors">SILVA et al.</span>
                <span>"Artificial Intelligence Applications in Future Technology Assessment: A Systematic Literature Review"</span>
            </div>
            
            <div class="reference-item" onclick="copyText('Machine Learning Algorithms for Innovation Forecasting in Emerging Technologies')">
                <span class="reference-date">2024</span>
                <span class="reference-authors">JOHNSON et al.</span>
                <span>"Machine Learning Algorithms for Innovation Forecasting in Emerging Technologies"</span>
            </div>
            
            <div class="reference-item" onclick="copyText('Bibliometric Analysis of Sustainable Technology Development: Patterns and Trends 2020-2024')">
                <span class="reference-date">2024</span>
                <span class="reference-authors">MULLER et al.</span>
                <span>Bibliometric Analysis of Sustainable Technology Development: Patterns and Trends 2020-2024</span>
            </div>
            
            <div class="reference-item" onclick="copyText('Scenario Planning Methodologies for Technology Assessment: A Meta-Analysis')">
                <span class="reference-date">2022</span>
                <span class="reference-authors">GARCIA-LOPEZ et al.</span>
                <span>"Scenario Planning Methodologies for Technology Assessment: A Meta-Analysis"</span>
            </div>
            
            <div class="reference-item" onclick="copyText('teste01')">
                <span class="reference-date">2016</span>
                <span class="reference-authors">SANTOS</span>
                <span>teste01</span>
            </div>
            
            <p style="margin-top: 15px;">
                <strong>Periodo:</strong> 2016-2024<br>
                <strong>Principais Autores:</strong> Silva, M.A., Santos, J.P., Oliveira, C.R., Johnson, K.L., Chen, W., Rodriguez, A.M., Thompson, R.J., Muller, H., Nakamura, T., Singh, P.K., Garcia-Lopez, F., Anderson, L.M., Kim, S.H., Dubois, P., Santos, Maria
            </p>
        </div>
        
        <!-- Cenario Desenvolvido -->
        <div class="method-section">
            <h2>Cenario Desenvolvido (Step anterior)</h2>
            
            <div class="scenario-box">
                <h3>cenario teste 001</h3>
                
                <p><strong>Descricao:</strong><br>
                A convergencia entre inteligencia artificial, metodologias de planejamento de cenarios e o foco crescente na sustentabilidade tecnologica molda um futuro no qual a avaliacao tecnologica sera predominantemente automatizada, preditiva e orientada por dados.</p>
                
                <p><strong>Drivers de Mudanca:</strong></p>
                <ol>
                    <li>Driver tecnologico: Avancos em inteligencia artificial e machine learning aplicados a avaliacao tecnologica</li>
                    <li>Driver economico: Pressao por decisoes mais eficientes e baseadas em dados</li>
                    <li>Driver ambiental: Necessidade crescente de considerar sustentabilidade</li>
                </ol>
                
                <p><strong>Projecoes:</strong></p>
                
                <p><em>CURTO PRAZO (1-2 anos):</em></p>
                <ul>
                    <li>Adocao inicial de sistemas baseados em IA para suporte a decisao</li>
                    <li>Consolidacao de bancos de dados bibliometricos</li>
                    <li>Maior uso de revisoes sistematicas</li>
                </ul>
                
                <p><em>MEDIO PRAZO (3-5 anos):</em></p>
                <ul>
                    <li>Algoritmos preditivos integrados em plataformas estrategicas</li>
                    <li>Crescimento de centros especializados em prospectiva tecnologica</li>
                    <li>Ampliacao do uso de metodologias de planejamento de cenarios</li>
                </ul>
                
                <p><em>LONGO PRAZO (5+ anos):</em></p>
                <ul>
                    <li>Transformacao do processo de avaliacao tecnologica em sistema continuo</li>
                    <li>Tecnologias emergentes priorizadas por previsoes de impacto</li>
                    <li>Redesenho das politicas publicas com modelos preditivos</li>
                </ul>
                
                <p><strong>Incertezas:</strong></p>
                <ul>
                    <li>Acuracia e confiabilidade dos modelos de machine learning</li>
                    <li>Capacidade institucional de adotar tecnologias preditivas</li>
                </ul>
            </div>
        </div>
        
        <!-- Ideias do Brainstorming -->
        <div class="method-section">
            <h2>Ideias do Brainstorming</h2>
            <%
            If brainstormCount > 0 Then
                Response.Write "<p>Total de ideias capturadas: <strong>" & brainstormCount & "</strong></p>"
                
                Dim ideaArray, i
                ideaArray = Split(brainstormingIdeas, "|")
                For i = 0 To UBound(ideaArray)
            %>
                    <div class="reference-item" onclick="copyText('<%=Replace(ideaArray(i), "'", "\'")%>')">
                        <span><%=ideaArray(i)%></span>
                    </div>
            <%
                Next
            Else
                ' Buscar da tabela dublin core como fallback
                On Error Resume Next
                Call getRecordSet("SELECT dc_title FROM tiamat_dublin_core WHERE stepID = 2 AND dc_type IN ('brainstorming', 'brainstorming_new', 'brainstorming_novo')", rs)
                
                If Not rs.EOF Then
                    Response.Write "<p>Ideias capturadas anteriormente:</p>"
                    While Not rs.EOF
                        brainstormCount = brainstormCount + 1
            %>
                        <div class="reference-item" onclick="copyText('<%=Replace(rs("dc_title"), "'", "\'")%>')">
                            <span><%=rs("dc_title")%></span>
                        </div>
            <%
                        rs.MoveNext
                    Wend
                    Response.Write "<p><strong>Total: " & brainstormCount & " ideias</strong></p>"
                Else
                    Response.Write "<p style='color: #999; text-align: center; padding: 20px;'>"
                    Response.Write "Nenhuma ideia do Brainstorming disponivel.<br>"
                    Response.Write "As ideias serao capturadas quando o metodo for finalizado."
                    Response.Write "</p>"
                End If
                On Error Goto 0
            End If
            %>
        </div>
        
        <!-- Como usar -->
        <div style="background: #d4edda; padding: 15px; border-radius: 5px; margin-top: 20px;">
            <h3>Como usar estes dados no Futures Wheel:</h3>
            <ol>
                <li>Clique em qualquer item para copia-lo</li>
                <li>Use as referencias bibliometricas para identificar tendencias tecnologicas</li>
                <li>Baseie-se no cenario para criar eventos de primeiro nivel</li>
                <li>Explore consequencias e implicacoes para eventos de segundo e terceiro nivel</li>
            </ol>
        </div>
    </div>
    
    <div class="toast" id="toast">Copiado!</div>
    
    <script>
        function copyText(text) {
            // Remove aspas
            text = text.replace(/['"]/g, '');
            
            // Tenta copiar
            if (navigator.clipboard) {
                navigator.clipboard.writeText(text).then(function() {
                    showToast();
                });
            } else {
                // Fallback
                var textArea = document.createElement("textarea");
                textArea.value = text;
                textArea.style.position = 'fixed';
                textArea.style.left = '-999999px';
                document.body.appendChild(textArea);
                textArea.select();
                try {
                    document.execCommand('copy');
                    showToast();
                } catch (err) {
                    alert('Erro ao copiar');
                }
                document.body.removeChild(textArea);
            }
        }
        
        function showToast() {
            var toast = document.getElementById('toast');
            toast.style.display = 'block';
            setTimeout(function() {
                toast.style.display = 'none';
            }, 2000);
        }
    </script>
</body>
</html>