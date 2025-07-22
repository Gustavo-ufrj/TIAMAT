<%@Language="VBScript" CodePage = 65001 %>
<% 
'IIS should process this page as 65001 (UTF-8), responses should be 
'treated as 28591 (ISO-8859-1).

Response.CharSet = "ISO-8859-1"
Response.CodePage = 28591
%>

<!--#include virtual="/system.asp"-->
<%
Response.Buffer = true
Server.ScriptTimeout = 18000
'On Error Resume Next
'---------------------------------------------------------------------------------------------------------
'declare all variables at top of page is best practice
'---------------------------------------------------------------------------------------------------------
Dim strFullFileName,strSplitArray,intUpper,strFileName,strPath,strServerName,strServerRoot,strFinalPath,strFinalDownload,strAbsFile,objFSO,objFile,objStream



'---------------------------------------------------------------------------------------------------------
'set variables
'---------------------------------------------------------------------------------------------------------
strFullFileName = CStr(Request.QueryString("FilePath"))'get full href and convert to string
strSplitArray = Split(strFullFileName,"/")'split above string at each forward slash
intUpper = Ubound(strSplitArray)'takes last part of split which will be the last number ie: the file name
strFileName = strSplitArray(intUpper)'file name is last part of url
strPath = Replace(strFullFileName,strFileName,"")'gets the path to the image
strServerName = Request.ServerVariables("Server_Name")'gets domain url ie: www.yourdomain.com
strServerRoot = Server.MapPath("\")'gets the proper path to the root of the server
strFinalPath = Replace(Replace(Replace(Replace(strFullFileName,strServerName,""),strFileName,""),"http://",""),"/","\")'leaves me with the path to the image
strFinalDownload = strFinalPath&strFileName'add our new path and file name together and we have what we needed!



'---------------------------------------------------------------------------------------------------------
'do some basic error checking for the QueryString
'---------------------------------------------------------------------------------------------------------
If strPath = "" Then
	Response.Clear
	Response.Write("No file specified.")
	Response.End
ElseIf InStr(strPath, "..") > 0 Then
	Response.Clear
	Response.Write("Illegal folder location.")
	Response.End
ElseIf Len(strPath) > 1024 Then
	Response.Clear
	Response.Write("Folder path too long.")
	Response.End
Else
	Call DownloadFile(strFinalDownload)
End If



'---------------------------------------------------------------------------------------------------------
'now call the function that does all the work
'---------------------------------------------------------------------------------------------------------
Private Sub DownloadFile(file)

	'set absolute file location which our new path from the websites root (thats what all the work above was for)
	strAbsFile = Server.MapPath("\")&strFinalDownload
	
	'create FSO object to check if file exists and get properties
	Set objFSO = Server.CreateObject("Scripting.FileSystemObject")

	
	'check to see if the file exists
	IF (objFSO.FileExists(strAbsFile)) THEN
		Set objFile = objFSO.GetFile(strAbsFile)
		
		'first clear the response, and then set the appropriate headers
		Response.Clear

		'response.write Replace(strFileName,"'","''")
		'response.end
		
'		Response.Buffer = True		

		'the filename you give it will be the one that is shown to the users by default when they save
		'could be easy to give user the choice too name the file by passing a variable and replacing that with 'objFile.Name' below
		'Response.AddHeader "Content-Length", objFile.Size
		Response.AddHeader "Content-Disposition", "attachment; filename=""" & strFileName & """"
		Response.ContentType = "application/octet-stream"

	
		Set objStream = Server.CreateObject("ADODB.Stream")
		objStream.Open
'		
'		'set as binary
		objStream.Type = 1
'		Response.CharSet = "UTF-8"

		'load into the stream the file
		objStream.LoadFromFile(strAbsFile)
		
		'send the stream in the response
		Response.BinaryWrite(objStream.Read)

		objStream.Close
		Set objStream = Nothing
		Set objFile = Nothing
		Response.End
	ELSE
		Response.Clear
		Response.Write("No such file exists.")
	END IF
	
	'release memory
	objFSO.Close
	Set objFSO = Nothing
End Sub
%>