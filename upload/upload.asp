<%@ Language=VBScript %>
<!--#include virtual="/system.asp"-->

<%

Function RSBinaryToString(xBinary)
  'Antonin Foller, http://www.motobit.com
  'RSBinaryToString converts binary data (VT_UI1 | VT_ARRAY Or MultiByte string)
  'to a string (BSTR) using ADO recordset

  Dim Binary
  'MultiByte data must be converted To VT_UI1 | VT_ARRAY first.
  If vartype(xBinary)=8 Then Binary = MultiByteToBinary(xBinary) Else Binary = xBinary
  
  Dim RS, LBinary
  Const adLongVarChar = 201
  Set RS = CreateObject("ADODB.Recordset")
  LBinary = LenB(Binary)
  
  If LBinary>0 Then
    RS.Fields.Append "mBinary", adLongVarChar, LBinary
    RS.Open
    RS.AddNew
      RS("mBinary").AppendChunk Binary 
    RS.Update
    RSBinaryToString = RS("mBinary")
  Else
    RSBinaryToString = ""
  End If
End Function



Dim Contador, Tamanho
Dim ConteudoBinario, ConteudoTexto
Dim Delimitador, Posicao1, Posicao2
Dim ArquivoNome, ArquivoConteudo, PastaBase, PastaDestino
Dim objFSO, objArquivo


Dim tipoUpload
if Request.QueryString("stepID") <> "" then ' Step Supporting information
	PastaBase = "/files/step/"+Request.QueryString("stepID")
	tipoUpload = "step"
elseif Request.QueryString("workflowID") <> "" then ' Workflow Supporting information
	PastaBase = "/files/workflow/"+Request.QueryString("workflowID")
	tipoUpload = "workflow"
else ' User file
	PastaBase = "/files/user/"+replace(Session("email"),"@",".")
	tipoUpload = "user"
end if




PastaDestino = Server.MapPath(PastaBase)
 
'Determina o tamanho do conteúdo
Tamanho = Request.TotalBytes
 
 


'Obtém o conteúdo no formato binário
ConteudoBinario = Request.BinaryRead(Tamanho)

 
'Transforma o conteúdo binário em string
'For Contador = 1 To Tamanho
' ConteudoTexto = ConteudoTexto & Chr(AscB(MidB(ConteudoBinario, Contador, 1)))
'Next 
ConteudoTexto = RSBinaryToString(ConteudoBinario)

 
'Determina o delimitador de campos
Delimitador = Left(ConteudoTexto, InStr(ConteudoTexto, vbCrLf) - 1)
 
'Percorre a String procurando os campos
'identifica os arquivo e grava no disco
Set objFSO = Server.CreateObject("Scripting.FileSystemObject")
 
Posicao1 = InStr(ConteudoTexto, Delimitador) + Len(Delimitar)
 
do while True
  ArquivoNome = ""
  Posicao1 = InStr(Posicao1, ConteudoTexto, "filename=")
  if Posicao1 = 0 then
    exit do
  else
   'Determina o nome do arquivo
   Posicao1 = Posicao1 + 10
   Posicao2 = InStr(Posicao1, ConteudoTexto, """")
   For contador = (Posicao2 - 1) to Posicao1 step -1
    if Mid(ConteudoTexto, Contador, 1) <> "" then '"
      ArquivoNome = Mid(ConteudoTexto, Contador, 1) & ArquivoNome
    else
      exit for
    end if
   next
	
   'Determina o conteúdo do arquivo
   Posicao1 = InStr(Posicao1, ConteudoTexto, vbCrLf & vbCrLf) + 4
   Posicao2 = InStr(Posicao1, ConteudoTexto, Delimitador) - 2
   ArquivoConteudo = Mid(ConteudoTexto, Posicao1, (Posicao2 - Posicao1))
		
   'Grava o arquivo
   if ArquivoNome <> "" then

   ArquivoNome = ConvertFromUTF8(ArquivoNome)

   On error resume next
   ' Cria a pasta
	set fs=Server.CreateObject("Scripting.FileSystemObject")
	set f=fs.CreateFolder(PastaDestino)
	set f=nothing
	set fs=nothing
	On error goto 0

	' Salva o arquivo
     Set objArquivo = objFSO.CreateTextFile(PastaDestino & +"\" & ArquivoNome, true)
	 extensao = right(ArquivoNome, len(ArquivoNome) - instrrev(ArquivoNome, "."))
     objArquivo.Write ArquivoConteudo
     objArquivo.Close
			
	 'Response.write "Arquivo " & PastaDestino & "\" & ArquivoNome & " gravado com sucesso!<br>" 
	 
	 ArquivoNome = Replace(ArquivoNome,"'","''")
	 
	 if tipoUpload = "step" then
		on error resume next
		call ExecuteSQL(SQL_CRIA_STEP_SUPPORTING_INFORMATION(Request.QueryString("stepID"), PastaBase & +"/" & ArquivoNome)) 
		on error goto 0

	 elseif tipoUpload = "workflow" then
		on error resume next
		call ExecuteSQL(SQL_CRIA_WORKFLOW_SUPPORTING_INFORMATION(Request.QueryString("workflowID"), PastaBase & +"/" & ArquivoNome)) 
		on error goto 0
	 else
	 
		 if Request.QueryString("resize") = "1" and (lcase(extensao) = "jpg" or  lcase(extensao) = "jpeg" or  lcase(extensao) = "gif" or  lcase(extensao) = "png")  then
			call Refresh_User_Photo(Session("email"),PastaBase & +"/" & ArquivoNome)
			
			response.redirect "/image/resize.aspx?fsr=1&maxsize=200&img=" + PastaBase & +"/" & ArquivoNome+"&url="+ Request.QueryString("url")&"&parent="+ Request.QueryString("parent")
		 end if

	 end if 
	 
     Set objArquivo = nothing
   end if
end if
Loop
Set objFSO = nothing

%>

<script>
<%if lcase(Request.QueryString("parent")) = "true" then%>
parent.window.location.href='<%=getCurrentURL%>';
<%else%>
window.location.href='<%=getCurrentURL%>';
<%end if%>
</script>

