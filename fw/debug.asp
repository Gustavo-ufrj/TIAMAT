<!--#include virtual="/system.asp"-->
<!--#include virtual="/checkstep.asp"-->
<!--#include file="INC_FUTURES_WHEEL.inc"-->
<%
Response.Write("<h2>Debug Futures Wheel</h2>")

Dim stepID
stepID = Request.QueryString("stepID")
Response.Write("<p>StepID: " & stepID & "</p>")

' Teste 1: printAllFWEvents está causando problema?
Response.Write("<h3>Teste 1: Verificando função printAllFWEvents</h3>")
On Error Resume Next
Call printAllFWEvents(stepID, False)
If Err.Number <> 0 Then
    Response.Write("<p style='color:red'>ERRO em printAllFWEvents: " & Err.Description & "</p>")
    Err.Clear
Else
    Response.Write("<p style='color:green'>printAllFWEvents funcionou</p>")
End If
On Error Goto 0

' Teste 2: Verificar se há loop infinito nos dados
Response.Write("<h3>Teste 2: Verificando dados</h3>")
Call getRecordSet("SELECT COUNT(*) as total FROM T_FTA_METHOD_FUTURES_WHEEL WHERE stepID = " & stepID, rs)
Response.Write("<p>Total de eventos: " & rs("total") & "</p>")
rs.Close

Call getRecordSet("SELECT COUNT(*) as total FROM T_FTA_METHOD_FUTURES_WHEEL_LINK l " & _
                  "INNER JOIN T_FTA_METHOD_FUTURES_WHEEL f ON l.actualFWID = f.fwID " & _
                  "WHERE f.stepID = " & stepID, rs)
Response.Write("<p>Total de links: " & rs("total") & "</p>")
rs.Close

' Teste 3: Verificar se há eventos problemáticos
Response.Write("<h3>Teste 3: Listando eventos</h3>")
Call getRecordSet("SELECT TOP 10 * FROM T_FTA_METHOD_FUTURES_WHEEL WHERE stepID = " & stepID, rs)
Response.Write("<ul>")
While Not rs.EOF
    Response.Write("<li>ID: " & rs("fwID") & " - Event: " & rs("event") & "</li>")
    rs.MoveNext
Wend
Response.Write("</ul>")
rs.Close

Response.Write("<h3>Se esta página carregou, o problema está no JavaScript ou no HTML complexo</h3>")
%>