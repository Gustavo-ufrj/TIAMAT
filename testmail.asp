<!--#include file="system.asp"-->

<%


	
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
	sbHTML.AppendLine("	 <div style=""margin:0 auto;max-width:600px;padding:10px 10px 10px 10px;background-color:#f5f5f5;text-align:left;color:#888888;font-size:14px;line-height:19px"">")
	sbHTML.AppendLine("		<h2 style=""text-align:center;padding-bottom:20px;text-transform:uppercase;font-weight:normal;letter-spacing:10px""><span>Password Recovery</span></h2>")
	sbHTML.AppendLine("  <h3>Hi " & name &",</h3>")
	sbHTML.AppendLine("		<p> We received a request to change the password of your TIAMAT account. <strong> This request is valid for 24 hours</strong>.</p>")
	sbHTML.AppendLine("		<p align=center style=""padding:15px;""><a href='" & link &"' style=""padding:12px 16px 12px 16px;border-radius:5px;background-color:#dc3545;color:#dc3545;border:0;color:#ffffff;text-decoration:none;font-size:18px;font-weight:normal;display:inline-block"" target=_blank>Change Password</a></p>")
	sbHTML.AppendLine("		<p>If the button don't work, copy and paste the link below in your browser:</p>")
	sbHTML.AppendLine("		<a href='" & link &"' style=""color:#121212;text-decoration:none"" target=_blank>" & link &"</a>")
	sbHTML.AppendLine("		<p>If you didn't ask for your password, it's likely that another user entered your email address by mistake while trying to reset their password. If that's the case, you don't need to take any further action and can safely disregard this email.</p>")
	sbHTML.AppendLine("  	<p>Regards,<br>TIAMAT Team</p>")
	sbHTML.AppendLine("  </div>")
	sbHTML.AppendLine("  <div style=""height:20px""></div>")
	sbHTML.AppendLine("</div>")

	Dim recoveryMail
	recoveryMail = SendMail (email, "TIAMAT <tiamat.cos.ufrj.br@gmail.com>", "TIAMAT Password Recovery", sb.toString(), sbHTML.toString())

	if not recoveryMail then
		Session("error")= "Error sending recovery e-mail. Please contact the administrator."
		SendRecoveryPasswordMail = False
		else
		SendRecoveryPasswordMail = True
	end if
	
End Function
	
	
retorno = SendRecoveryPasswordMail("Carlos Eduardo Barbosa", "edubarbosa@gmail.com", "http://tiamat.cos.ufrj.br/recovery.asp?edubarbosa@gmail.com&verification=1231213213213113541354")
	

%>


