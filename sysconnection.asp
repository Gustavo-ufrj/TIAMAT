<%


	Const DB_PROVIDER = "SQLOLEDB"
	Const DB_NAME = "TIAMAT"
	Const DB_DS = "TIAMAT"
	'Const DB_DS = "TIAMAT\SQLEXPRESS"
	Const DB_LOGIN = "sa"
	Const DB_SENHA = "Tiamat2015"
	


'Funчуo que faz conexуo com o banco de dados
Public Function GetConnection 
	Dim cnn : Set cnn = CreateObject("ADODB.Connection")
	cnn.Open "Provider=" & DB_PROVIDER & ";Data Source="& DB_DS &";Initial Catalog="&DB_NAME&";User ID="&DB_LOGIN&";Password="&DB_SENHA&";"
	Set GetConnection = cnn 
End Function
%>