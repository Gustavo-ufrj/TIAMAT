<%
'Instancia o objeto XMLDOM.
Set objXMLDoc = CreateObject("MSXML2.DOMDocument.3.0")
 
'Indicamos que o download em segundo plano n�o � permitido
objXMLDoc.async = False
 
'Carrega o domcumento XML
objXMLDoc.load(Server.MapPath("manifest.xml"))
 
'Carrega o domcumento XML
 
'O m�todo parseError cont�m informa��es sobre o �ltimo erro ocorrido
if objXMLDoc.parseError <> 0 then
	response.write "C�digo do erro: " & objXMLDoc.parseError.errorCode & "<br>"
	response.write "Posi��o no arquivo: " & objXMLDoc.parseError.filepos & "<br>"
	response.write "Linha: " & objXMLDoc.parseError.line & "<br>"
	response.write "Posi��o na linha: " & objXMLDoc.parseError.linepos & "<br>"
	response.write "Descri��o: " & objXMLDoc.parseError.reason & "<br>"
	response.write "Texto que causa o erro: " & objXMLDoc.parseError.srcText & "<br>"
	response.write "Url do arquivo com problemas: " & objXMLDoc.parseError.url
else
	'A propriedade documentElement refere-se � raiz do documento
	Set raiz = objXMLDoc.documentElement
	Set FTAmethod = raiz.getElementsByTagName("FTAmethod")
	
	For i = 0 to FTAmethod.length -1
	  Set user = FTAmethod(i).getElementsByTagName("user")
		For j = 0 to user.length -1
		dim numberUsers
		if isnull(user(j).getAttribute("number")) then
		numberUsers = 0
		else
		numberUsers = user(j).getAttribute("number")
		end if
		Response.Write FTAmethod(i).getAttribute("name") & " - " & FTAmethod(i).getAttribute("base_folder") & " - " & user(j).getAttribute("role") & " - " & numberUsers & "<br>"
		Next
	Next

end if
%>