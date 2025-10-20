<%
Response.Write("<h2>Verificação de StepID</h2>")
Response.Write("<p>Request.QueryString('stepID') = [" & Request.QueryString("stepID") & "]</p>")
Response.Write("<p>Request('stepID') = [" & Request("stepID") & "]</p>")

Dim stepID
stepID = Request.QueryString("stepID")
Response.Write("<p>Variável stepID = [" & stepID & "]</p>")

If stepID = "" Then
    Response.Write("<p style='color:red'>StepID está VAZIO!</p>")
Else
    Response.Write("<p style='color:green'>StepID está OK: " & stepID & "</p>")
End If

' Verificar se há algum problema com o valor
Response.Write("<p>Len(stepID) = " & Len(stepID) & "</p>")
Response.Write("<p>IsNumeric(stepID) = " & IsNumeric(stepID) & "</p>")

' Testar query
If stepID <> "" Then
    Response.Write("<h3>Testando Query:</h3>")
    Dim sql
    sql = "SELECT COUNT(*) as total FROM T_FTA_METHOD_FUTURES_WHEEL WHERE stepID = " & stepID
    Response.Write("<p>SQL: " & sql & "</p>")
    
    On Error Resume Next
    <!--#include virtual="/system.asp"-->
    Call getRecordSet(sql, rs)
    If Err.Number = 0 Then
        Response.Write("<p style='color:green'>Query funcionou! Total de eventos: " & rs("total") & "</p>")
        rs.Close
    Else
        Response.Write("<p style='color:red'>Erro na query: " & Err.Description & "</p>")
    End If
    On Error Goto 0
End If
%>