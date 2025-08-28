<!--#include virtual="/system.asp"-->
<!--#include virtual="/checkstep.asp"-->
<!--#include file="INC_SCENARIO.inc"-->
<%
Response.Write "TESTE 1: Includes OK<br>"

' Teste sem render
Response.Write "TESTE 2: Antes do saveCurrentURL<br>"
saveCurrentURL
Response.Write "TESTE 3: saveCurrentURL OK<br>"

Response.Write "TESTE 4: Antes do tiamat.addJS<br>"
tiamat.addJS("/js/tinymce/tinymce.min.js")
Response.Write "TESTE 5: tiamat.addJS OK<br>"

Response.Write "TESTE 6: Antes do render.renderToBody<br>"
' COMENTADO PARA TESTE: render.renderToBody()
Response.Write "TESTE 7: PUROU render.renderToBody por enquanto<br>"

Dim currentStepID
currentStepID = Request.QueryString("stepID")
Response.Write "TESTE 8: stepID = " & currentStepID & "<br>"

' Teste simples de query
call getRecordSet("SELECT COUNT(*) as total FROM T_FTA_METHOD_BIBLIOMETRICS", rs)
Response.Write "TESTE 9: Query OK - Total refs: " & rs("total") & "<br>"

Response.Write "<h2>Formulario Simples (sem render)</h2>"
%>

<form action="scenarioActions.asp" method="POST">
    <input type="hidden" name="action" value="save">
    <input type="hidden" name="stepID" value="<%=currentStepID%>">
    
    <p>Nome:<br>
    <input type="text" name="name" style="width: 400px;"></p>
    
    <p>Cenario:<br>
    <textarea name="scenario" rows="10" style="width: 400px;"></textarea></p>
    
    <p>
    <input type="submit" value="Salvar">
    <input type="button" value="Cancelar" onclick="location.href='index.asp?stepID=<%=currentStepID%>'">
    </p>
</form>

<%
Response.Write "<hr>"
Response.Write "TESTE 10: Agora vamos testar o render...<br>"

On Error Resume Next
render.renderToBody()
If Err.Number <> 0 Then
    Response.Write "ERRO no render.renderToBody: " & Err.Description & "<br>"
Else
    Response.Write "render.renderToBody OK<br>"
End If

render.renderFromBody()
If Err.Number <> 0 Then
    Response.Write "ERRO no render.renderFromBody: " & Err.Description & "<br>"
Else
    Response.Write "render.renderFromBody OK<br>"
End If
On Error Goto 0
%>