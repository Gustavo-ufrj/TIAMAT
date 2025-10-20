<%
Response.Write("<h1>Teste 1: ASP Funcionando</h1>")

Dim stepID
stepID = Request.QueryString("stepID")
Response.Write("<p>StepID: " & stepID & "</p>")
%>

<!--#include virtual="/system.asp"-->

<%
Response.Write("<h1>Teste 2: System.asp incluído com sucesso</h1>")
%>

<!--#include virtual="/checkstep.asp"-->

<%
Response.Write("<h1>Teste 3: Checkstep.asp incluído com sucesso</h1>")
%>

<!--#include file="INC_FUTURES_WHEEL.inc"-->

<%
Response.Write("<h1>Teste 4: INC_FUTURES_WHEEL.inc incluído com sucesso</h1>")

On Error Resume Next
Call getRecordSet("SELECT COUNT(*) as total FROM T_FTA_METHOD_FUTURES_WHEEL WHERE stepID = " & stepID, rs)
If Err.Number = 0 Then
    Response.Write("<p>Teste 5: Query funcionou. Total de eventos: " & rs("total") & "</p>")
Else
    Response.Write("<p>Erro na query: " & Err.Description & "</p>")
End If
On Error Goto 0
%>

<h2>Se todos os testes passaram, o problema está no JavaScript ou HTML do index.asp</h2>