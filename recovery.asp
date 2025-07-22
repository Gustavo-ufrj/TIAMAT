<!--#include file="system.asp"-->

<% 
Function GenerateResetLink(email)
	verification = RandomString(128)
		
	call ExecuteSQL(SQL_CRIA_USER_RESET(email, verification))
		
	Dim domainName, urlParam 
	
	If lcase(Request.ServerVariables("HTTPS")) = "on" Then 
		strProtocol = "https://" 
	Else
		strProtocol = "http://" 
	End If

	domainName = Request.ServerVariables("SERVER_NAME") 
	urlParam   = Request.ServerVariables("HTTP_X_ORIGINAL_URL")
	
	GenerateResetLink = strProtocol & domainName & urlParam & "/recovery.asp?action=reset&user=" & email & "&verification=" & verification
End Function


Function SendRecoveryPasswordMail(name, email, link)	
	Set sb = new StringBuffer

	sb.AppendLine("Hi " & name &",")
	sb.AppendLine("Click the link below if you would like to reset your password:")
	sb.AppendLine(link)
	sb.AppendLine("This link is valid for 24 hours.")
	sb.AppendLine("-----")
	sb.AppendLine("Didn't ask to reset your password?")
	sb.AppendLine("If you didn't ask for your password, it's likely that another user entered your email address by mistake while trying to reset their password. If that's the case, you don't need to take any further action and can safely disregard this email.")
	sb.AppendLine("-----")
	sb.AppendLine("Note: This e-mail was sent from an unmonitored account. Replies to this message will never be read. If you have any questions regarding this message please contact the administrator at eduardo@cos.urj.br")


	Set sbHTML = new StringBuffer
	sbHTML.AppendLine("<div style=""max-width:670px;margin:0 auto 30px;font-family:system-ui,-apple-system,'Segoe UI',Roboto,'Helvetica Neue',Arial,'Noto Sans','Liberation Sans',sans-serif,'Apple Color Emoji','Segoe UI Emoji','Segoe UI Symbol','Noto Color Emoji';background-color:#212529;padding-bottom:1px;padding-top:10px"">")
	sbHTML.AppendLine("	<div style=""max-width:670px;height:30px;margin:0 auto 5px;font-size: 1.5rem!important;padding: 1.5rem!important;"">")
	sbHTML.AppendLine("		<a href=""http://tiamat.cos.ufrj.br/"" style=""text-decoration:none;"" target=_blank><span style=""font-weight: bolder; color: #fff;"">TIAMAT</span></a>")
	sbHTML.AppendLine(" </div>")
	sbHTML.AppendLine("	 <div style=""margin:0 auto;max-width:600px;padding:10px 10px 10px 10px;background-color:#dddddd;text-align:left;color:#333333;font-size:14px;line-height:19px"">")
	sbHTML.AppendLine("		<h2 style=""text-align:center;padding-bottom:20px;text-transform:uppercase;font-weight:normal;letter-spacing:10px;color:#333333""><span>Password Recovery</span></h2>")
	sbHTML.AppendLine("  <h3 style=""color:#333333"">Hi " & name &",</h3>")
	sbHTML.AppendLine("		<p style=""color:#333333""> We received a request to change the password of your TIAMAT account. <strong> This request is valid for 24 hours</strong>.</p>")
	sbHTML.AppendLine("		<p align=center style=""padding:15px;""><a href='" & link &"' style=""padding:12px 16px 12px 16px;border-radius:5px;background-color:#dc3545;color:#dc3545;border:0;color:#ffffff;text-decoration:none;font-size:18px;font-weight:normal;display:inline-block"" target=_blank>Change Password</a></p>")
	sbHTML.AppendLine("		<p style=""color:#333333"">If the button don't work, copy and paste the link below in your browser:</p>")
	sbHTML.AppendLine("		<a href='" & link &"' style=""color:#121212;text-decoration:none"" target=_blank>" & link &"</a>")
	sbHTML.AppendLine("		<p style=""color:#333333"">If you didn't ask for your password, it's likely that another user entered your email address by mistake while trying to reset their password. If that's the case, you don't need to take any further action and can safely disregard this email.</p>")
	sbHTML.AppendLine("  	<p style=""color:#333333"">Regards,<br>TIAMAT Team</p>")
	sbHTML.AppendLine("  </div>")
	sbHTML.AppendLine("  <div style=""height:20px""></div>")
	sbHTML.AppendLine("</div>")

	
	SendRecoveryPasswordMail = SendMail (email, "TIAMAT <tiamat.cos.ufrj.br@gmail.com>", "TIAMAT Password Recovery", sb.toString(), sbHTML.toString())

End Function
	
	
	
	
	
action = Request.Querystring("action")
	
select case action

case "request"
	
	if not isnull(request.form("re_email")) then
		email = request.form("re_email")
		
			Call getRecordSet(SQL_CONSULTA_USUARIO_EMAIL(email), usuario)
		
		if not usuario.eof then 
			link = GenerateResetLink(email)
			retorno = SendRecoveryPasswordMail(usuario("name"), email, link)
			
			if retorno then	
				Session("recoverySuccess") = "Recovery e-mail successfully sent to " & email & "."
			else 
				Session("recoveryError") = "Error sending recovery e-mail. Please contact the administrator."
			end if
		
		else
			Session("recoveryError") = "Unable to find a user with the e-mail " & email & "."

		end if

	else 
		Session("recoveryError") = "A error occurred while processing your request. If the error continues, please contact the administrator."
	end if
	
	response.redirect "/signin.asp"


	
case "reset"

	email = Request.Querystring("user")
	verification = Request.Querystring("verification")

	'Limpa links expirados
	call ExecuteSQL(SQL_DELETE_EXPIRED_USER_RESET())
	
	'Busca o pedido do link	
	Call getRecordSet(SQL_CONSULTA_USER_RESET_VALIDATION(email, verification), rs)
	
	'Achou?
	if not rs.EOF then
	' Redireciona para nova senha
		Session("resetUser") = email 
		Session("resetVerification") = verification 
	else
	' Link inválido. Erro
		Session("recoveryError") = "Invalid or expired recovery link. Please restart the password reset process."
	end if

	response.redirect "/signin.asp"

	
	
		
case "save"

	email = Request.form("email")
	verification = Request.form("verification")

	password = Request.form("re_password")
	password2 = Request.form("re_rpassword")

	'Busca o pedido do link	
	Call getRecordSet(SQL_CONSULTA_USER_RESET_VALIDATION(email, verification), rs)

	'Achou?
	if not rs.EOF then
		if password <> "" and password2 <> "" and password = password2 then
			call Refresh_User_Password(email,sha256(password)) 
			estado = login(email,password)
		end if
	else
		' Link inválido. Erro
		Session("recoveryError") = "Invalid or expired recovery link. Please restart the password reset process."
	end if

	response.redirect "/workplace.asp"

	
end select
%>
