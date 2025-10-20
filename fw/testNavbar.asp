<%
Response.Write("<h2>Teste do Navbar</h2>")
Response.Write("<p>Se você está vendo esta página, o ASP está funcionando.</p>")

Dim stepID
stepID = Request.QueryString("stepID")
If stepID = "" Then stepID = "12345"

Response.Write("<p>StepID = " & stepID & "</p>")
%>

<h3>Navbar Correto (copie este código para o index.asp):</h3>
<pre style="background:#f5f5f5; padding:10px; border:1px solid #ccc;">
&lt;nav class="navbar fixed-bottom navbar-light bg-light" id="navbar"&gt;
    &lt;div class="container-fluid justify-content-center p-0"&gt;
        &lt;%If Not firstEvent Then%&gt;
        &lt;button class="btn btn-sm btn-primary m-1" type="button" onclick="showAddForm();"&gt; 
            &lt;i class="bi bi-plus-circle text-light"&gt;&lt;/i&gt; Add Event
        &lt;/button&gt;
        &lt;%End If%&gt;
        
        &lt;button class="btn btn-sm btn-secondary m-1" type="button" onclick="printDiv($('#fwform')[0]);"&gt; 
            &lt;i class="bi bi-download text-light"&gt;&lt;/i&gt; Export
        &lt;/button&gt;
        
        &lt;button class="btn btn-sm btn-info m-1" type="button" onclick="window.open('viewDC.asp?stepID=&lt;%=stepID%&gt;', 'DCWindow', 'width=800,height=600,scrollbars=yes,resizable=yes');"&gt; 
            &lt;i class="bi bi-eye text-light"&gt;&lt;/i&gt; View DC
        &lt;/button&gt;
        
        &lt;button class="btn btn-sm btn-danger m-1" onclick="top.location.href='/stepsupportInformation.asp?stepID=&lt;%=stepID%&gt;';"&gt;
            &lt;i class="bi bi-journal-plus text-light"&gt;&lt;/i&gt; Supporting Information
        &lt;/button&gt;
        
        &lt;button class="btn btn-sm btn-danger m-1" onclick="if(confirm('This action cannot be undone. Are you sure to end this FTA method now?'))top.location.href='/FTA/fw/fwActions.asp?action=end&amp;stepID=&lt;%=stepID%&gt;'"&gt;
            &lt;i class="bi bi-check-lg text-light"&gt;&lt;/i&gt; Finish
        &lt;/button&gt;
    &lt;/div&gt;
&lt;/nav&gt;
</pre>

<h3>Teste do botão View DC:</h3>
<button onclick="window.open('viewDC.asp?stepID=<%=stepID%>', 'DCWindow', 'width=800,height=600,scrollbars=yes,resizable=yes');">
    Clique aqui para testar o View DC
</button>

<hr>

<h3>Instruções:</h3>
<ol>
    <li>Abra o arquivo <strong>/FTA/fw/index.asp</strong> em seu editor</li>
    <li>Procure por: <code>&lt;nav class="navbar fixed-bottom</code></li>
    <li>Delete TODO o bloco desde &lt;nav até &lt;/nav&gt;</li>
    <li>Cole o código acima (sem o &lt;pre&gt; e &lt;/pre&gt;)</li>
    <li>Salve o arquivo</li>
    <li>Limpe o cache do navegador (Ctrl+F5)</li>
</ol>

<p><strong>Possível problema:</strong> O arquivo index.asp pode estar sendo cacheado pelo IIS. Tente:</p>
<ul>
    <li>Reiniciar o IIS</li>
    <li>Ou adicionar um parâmetro aleatório na URL: index.asp?stepID=XXX&refresh=<%=Now()%></li>
</ul>