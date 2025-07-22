<%@ OutputCache Duration="600" VaryByParam="*" %>
<%@ Page Debug="true" %>
<%@ Import Namespace="System.Net.Mail" %>

<script runat="server">


Private Sub Page_Load(ByVal sender As Object, ByVal e As System.EventArgs) Handles Me.Load

		Dim smtp As New SmtpClient()
		Dim smail as New MailMessage("tiamat.cos.ufrj.br@gmail.com", "edubarbosa@gmail.com")
		smail.Subject = "TIAMAT Notification"
		smail.IsBodyHtml = "true"
		smail.Body = "This text is the TIAMAT notification."
		smtp.EnableSsl = True
		smtp.Send(smail)
		
end sub

</script>