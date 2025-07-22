<!--#include virtual="/system.asp"-->
<!--#include virtual="/includes/JSON.asp"-->

<%
Dim usuario
Dim entries()
Dim entriesCount
entriesCount = 0 

	Call getRecordSet(SQL_CONSULTA_USUARIO_TODOS(), usuarios)

	if not(usuarios.eof) then
		set d = server.createObject("scripting.dictionary")
		
		while not usuarios.eof

			entriesCount = entriesCount + 1
			
			redim preserve entries(entriesCount)
			
			if usuarios("name") <> "" then
				entries(entriesCount) = usuarios("name") + " &lt;" + usuarios("email") + "&gt;"
			else
				entries(entriesCount) = usuarios("email")
			end if
			usuarios.MoveNext
		wend 
	end if

	retorno = (new JSON).toJSON("data", entries,0)
	retorno = "[" + mid(retorno, 14, len(retorno)-14)
	retorno = replace(retorno, "&lt;", "<")
	retorno = replace(retorno, "&gt;", ">")
	call response.write (retorno)
	
%>