<% 
if Session("email") = "" then
	response.redirect ("/index.asp")
end if 

dim numFiles, isIMG, i, urlback

urlback = Request.QueryString("url")
numFiles = Request.QueryString("numFiles")
img = Request.QueryString("resize")
workflowID = Request.QueryString("workflowID")
stepID = Request.QueryString("stepID")
method = Request.QueryString("method")

if (not numFiles>0) or img = 1 then
numFiles = 1
end if


%>

<html>
<head>
<meta charset="utf-8">

<title>Upload</title>

<link rel="shortcut icon" href="/css/favicon.png">
<link rel="stylesheet" href="/css/main.css">
<link rel="stylesheet" href="/css/mobileFIX.css">
<link rel="stylesheet" href="/css/text.css">

</head>
 
<body>
 
<form action="upload.asp?workflowID=<%=workflowID%>&stepID=<%=stepID%>&method=<%=method%>&resize=<%=img%>&url=<%=urlback%>" method="post" enctype="multipart/form-data">

<table class="principal" width=100% height=100%>
		<tr>
			<td align=center class="padded">
				<p class="font_6" align="justify">FILE UPLOAD <font color="red">//</font></p>							
			</td>
		</tr>
		<tr>
			<td align=center>
				<hr class="linhaDupla">
			</td>
		</tr>
		<tr>
			<td align=center class="padded">

				<%for i=1 to numFiles%>
				<p align="center">
				<input type="file" name="txtArquivo<%=i%>">
				</p>
				<%next%>

			</td>
		<tr>
			<td align=center>
				<hr class="linhaDupla">
			</td>
		</tr>
		<tr>
			<td align=center class="padded">
				<input type="submit" name="upload" value="Upload"  class="TIAMATbutton">
			</td>
		</tr>
		<tr>
			<td align=center>
			</td>
		</tr>
	</table>
</form>
 
</body>
</html>