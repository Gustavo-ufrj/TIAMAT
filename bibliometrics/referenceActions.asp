<!--#include virtual="/system.asp"-->
<!--#include file="INC_BIBLIOMETRICS.inc"-->
<!--#include file="upload.asp"-->


<%

Dim usuarios
	dim sql_consulta, retorno
	Dim action
	Dim url
			
	action = Request.Querystring("action")
	sID = Request.Querystring("stepID")
	
	select case action
	
	
	case "export"
	
	' 1. Cria pasta temporária
		PastaBase = "/files/step/"+sID+"/"+RandomString(10)
		tempDir = server.MapPath(PastaBase)
		
		set fs=Server.CreateObject("Scripting.FileSystemObject")
		' Garante uma pasta nova
		while fs.FolderExists(tempDir) 
			PastaBase = "/files/step/"+sID+"/"+RandomString(10)
			tempDir = server.MapPath(PastaBase)
		wend
		fs.CreateFolder (tempDir)   
	
	' -----
	
		call getRecordSet(SQL_CONSULTA_BIBLIOMETRICS(sID), rs)
	
	' cria o arquivo .bib
	Const Writing=2
	Dim OpenFileobj, FilePath
	FilePath=Server.MapPath(PastaBase+"/bibliometrics"+sID+".bib") 

	
	if not fs.fileExists(FilePath) Then 
		Set OpenFileobj = fs.CreateTextFile(FilePath, True, True)
	End if
	
	
	while not rs.EOF 
	if rs("file_path") <> "" then
	
	' 2. Copia PDFs para a pasta
	citationID = RandomString(32) ' Para evitar colisões

	name=strRight(rs("file_path"),"/")
	path=strLeft(rs("file_path"),name)
	
	source=Server.MapPath(path)+"\"+name
	destination=tempDir+"/"+citationID+".pdf" 
	fs.CopyFile source,destination
	
	' 3. Cria Bibtex
		OpenFileobj.WriteLine("@misc{"+citationID) +","
		OpenFileobj.WriteLine("title = {"+rs("title")) + "},"
		
		call getRecordset(SQL_CONSULTA_BIBLIOMETRICS_AUTHORS(cstr(rs("referenceID"))),rsAuthor)
		authors = ""
		while not rsAuthor.eof
			authors = authors + rsAuthor("name")
			rsAuthor.movenext
			if not rsAuthor.eof then
				authors = authors + " and "
			end if
		wend
		
		OpenFileobj.WriteLine("author = {"+authors + "},")
		OpenFileobj.WriteLine("year = {"+rs("year")+ "},")
		OpenFileobj.WriteLine("file = {"+citationID+".pdf:"+citationID+".pdf:application/pdf},")
		OpenFileobj.WriteLine("}")
		OpenFileobj.WriteBlankLines(2)

		
	end if
		rs.movenext
	wend


	OpenFileobj.Close
	Set OpenFileobj = Nothing

	' 4. Apaga arquivo padrão de retorno
		PastaExport = "/files/step/"+sID
		FileExport=Server.MapPath(PastaExport+"/bibliometrics"+sID+".zip") 
		if fs.FileExists(FileExport) then
			fs.DeleteFile(FileExport)
		end if
	
	' 5. Zipa com nome padrão bibliometricsID.zip
		Call ZipFolder(PastaBase,PastaExport,"bibliometrics"+sID+".zip")
	
	' 6. Apaga pasta temporária
		if fs.FolderExists(tempDir) then
			fs.DeleteFolder(tempDir)
		end if
		Set fs = Nothing
	
	' 7. Redireciona para o download.
		response.redirect PastaExport+"/bibliometrics"+sID+".zip"
	
	
	case "save"
	
		   Dim Upload, fileName, fileSize, ks, i, fileKey
	
				Set Upload = New FreeASPUpload
				
				PastaUser = "/files/user/"+replace(Session("email"),"@",".") 
				PastaBase = "/files/user/"+replace(Session("email"),"@",".") + "/"+sID
				userDirVar = server.MapPath(PastaUser)
				uploadsDirVar = server.MapPath(PastaBase)
				
				' Cria a pasta
'				on error resume next
				set fs=Server.CreateObject("Scripting.FileSystemObject")
				If  Not fs.FolderExists(userDirVar) Then      
				  fs.CreateFolder (userDirVar)   
				End If
				If  Not fs.FolderExists(uploadsDirVar) Then      
					set f=fs.CreateFolder(uploadsDirVar)
				End If
				set f=nothing
				set fs=nothing
				on error goto 0
				
				Upload.Save(uploadsDirVar)

				' If something fails inside the script, but the exception is handled
				If Err.Number<>0 then response.write "Error number "+cstr(Err.Number)
	
	
	

		if Upload.Form("stepID") <> "" then
				
			Dim referenceID	
				
			if Upload.Form("referenceID") <> ""  then 

				call getRecordSet(SQL_CONSULTA_BIBLIOMETRICS_REFERENCE(Upload.Form("referenceID")), rs)
				if not rs.eof then 'update
					call ExecuteSQL(SQL_ATUALIZA_REFERENCE(Upload.Form("referenceID"), Upload.Form("title"), Upload.Form("year")))
					referenceID = cint(Upload.Form("referenceID"))
				else ' error
					response.write "ERROR. Invalid ID!"
				end if 
				
			else 'new 
			
				Set cnn = getConnection
			
				Call chamaSP(True, objSP, "SP_CREATE_FTA_METHOD_BIBLIOMETRICS_REFERENCE",cnn)
				With objSP
					.Parameters.Append .CreateParameter("RETORNO", adBigInt,adParamReturnValue)
					.Parameters.Append .CreateParameter("@email",advarchar,adParamInput,150,Session("email"))
					.Parameters.Append .CreateParameter("@stepID",adBigInt,adParamInput,8,cint(Upload.Form("stepID")))
					.Parameters.Append .CreateParameter("@title",advarchar,adParamInput,500,Upload.Form("title"))
					.Parameters.Append .CreateParameter("@year",advarchar,adParamInput,8,Upload.Form("year"))
					.Execute

				referenceID = .Parameters("RETORNO")

				End With

				Call chamaSP(False, objSP, Null, Null)
				dispose(cnn)
			
		
			end if 
				call ExecuteSQL(SQL_DELETE_AUTHORS(cstr(referenceID)))
				
						
				authors=Split(Upload.Form("authors"), ";")
				
				for each author in authors
					call ExecuteSQL(SQL_ADICIONA_AUTHOR(cstr(referenceID), trim(author)))
				Next

				call ExecuteSQL(SQL_DELETE_REFERENCE_X_TAG(cstr(referenceID)))
				
				call ExecuteSQL(SQL_ADICIONA_REFERENCE_X_TAG(cstr(referenceID), Upload.Form("subject")))

				for each fileKey in Upload.UploadedFiles.keys
					ArquivoNome = Upload.UploadedFiles(fileKey).FileName 
					call ExecuteSQL(SQL_ADICIONA_FILE(cstr(referenceID), PastaBase & +"/" & ArquivoNome)) 
				next
				
				
				url="index.asp?stepID="+Upload.Form("stepID")
			else
			
			call response.write ("Invalid FTA method. Please inform the system administrator.")
			
		end if 
		
		
	case "delete"
		
		call ExecuteSQL(SQL_DELETE_REFERENCE(request.querystring("referenceID")))
		
		url= "index.asp?stepID="+request.querystring("stepID")		
		
	case "end"

		if request.querystring("stepID") <> "" then
			call endStep(request.querystring("stepID"))
			
			url = "/workplace.asp"
		end if
	
	case else
	
		call response.write ("Invalid action supplied. Please inform the system administrator.")



		
	end select
	
	
%>
<script>
top.location.href="<%=url%>"
</script>
