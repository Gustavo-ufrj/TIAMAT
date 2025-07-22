<% 
if Session("email") = "" then
	response.redirect ("/index.asp")
end if 

stepID = Request.QueryString("stepID")

%>

<html>
<head>
<meta charset="utf-8">

<title>Database connection</title>

<link rel="shortcut icon" href="/css/favicon.png">
<link rel="stylesheet" href="/css/main.css">
<link rel="stylesheet" href="/css/mobileFIX.css">
<link rel="stylesheet" href="/css/text.css">

</head>

<body>
 
<form action="actions.asp?action=save&stepID=<%=stepID%>" method="post">

<table class="principal" width=100% height=100%>
		<tr>
			<td align=center class="padded">
				<p class="font_6" align="justify">DATABASE CONNECTION <font color="red">//</font></p>							
			</td>
		</tr>
		<tr>
			<td align=center>
				<hr class="linhaDupla">
			</td>
		</tr>
		<tr>
			<td align=center class="padded">
				<table>
				<tbody>
				<tr>
				<td width="30%"><p align="center">Server: </p></td>
				<td width="70%"><input type="text" name="server"></td>
				</tr>
				<tr>
				<td width="30%"><p align="center">Username: </p></td>
				<td width="70%"><input type="text" name="uid"></td>
				</tr>
				<tr>
				<td width="30%"><p align="center">Password: </p></td>
				<td width="70%"><input type="password" name="pw"></td>
				</tr>
				<tr>
				<td width="30%"><p align="center">Database: </p></td>
				<td width="70%"><input type="text" name="database"></td>
				</tr>
				<tr>
				<td width="30%"><p align="center">Table: </p></td>
				<td width="70%"><input type="text" name="table"></td>
				</tr>
				</tbody>
				</table>
			</td>
		<tr>
			<td align=center>
				<hr class="linhaDupla">
			</td>
		</tr>
		<tr>
			<td align=center class="padded">
				<input type="submit" name="getdata" value="Get data"  class="TIAMATbutton">
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