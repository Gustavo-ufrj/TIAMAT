<!--#include file="recupera_output.asp"-->
<%
'=========================================
' TIAMAT OUTPUT API
' API REST para gerenciar outputs dos métodos FTA
'=========================================

' Configuração de resposta JSON
Response.ContentType = "application/json"
Response.CharSet = "utf-8"

' Instancia o manager
Dim outputManager
Set outputManager = New TiamatOutputManager

call recupera_output.CaptureStepOutput(2530, "", "")

response.write "cheguei"





' Limpa objetos
Set outputManager = Nothing
Set response = Nothing
%>