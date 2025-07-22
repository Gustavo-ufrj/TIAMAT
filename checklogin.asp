<%
if not (Session("email") <> "") then
	if lcase(Request.ServerVariables("URL")) <> "/join.asp" then
		Session("loginError") = "Session expired. Please log in again."
	else
		Session("loginError") = "Your invitation requires a TIAMAT account. Please log in or sign up to continue."
	end if
	
	
	if Request.Querystring & Request.Form <> "" then
		Session("afterLoginGoTo") = Request.ServerVariables("URL") & "?" & Request.Querystring & Request.Form
	else
		Session("afterLoginGoTo") = Request.ServerVariables("URL")
	end if
%>

<script>

if (window.opener) {
	window.opener.document.reload();
	window.close();
}
else {
	top.location.href="/signin.asp";
	}

</script>

<%
	
end if 

%>