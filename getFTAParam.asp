<!--#include virtual="/system.asp"-->
<%
if request.querystring("methodID") = "" then
	Response.End
end if
if request.querystring("methodID") <> "0" then
	set userlist = getUserListbyID(request.querystring("methodID"))
	ListRules = "{'rules':["
for i=0 to userlist.length-1
%>

<%if i>0 then
ListRules = ListRules +","
%>
<tr>
<%end if
ListRules = ListRules + "{'role': '" & userlist(i).getAttribute("role") & "','tag':'textarea"& i & "','number':'"
currentNumber = "0"
if not isnull(userlist(i).getAttribute("number")) then
	currentNumber = userlist(i).getAttribute("number")
end if
ListRules = ListRules + currentNumber + "'}"
%>
<td class="padded" align=right width=40%>
User<% if isnull(userlist(i).getAttribute("number")) then response.write "s" end if%> (Role "<%=userlist(i).getAttribute("role")%>"): 
</td>
<td class="padded" width=60%>
<textarea id="textarea<%=i%>" name="<%=userlist(i).getAttribute("role")%>" rows="1" style="width:400px;" onfocus="itemfocus.value ='textarea<%=i%>'; itemfocusMax.value ='<%=currentNumber%>'; "></textarea>
</td>

<%if i<(userlist.length-1) then
%>

</tr>
<%end if%>

<%
Next
ListRules = ListRules + "]}"
%>
<input type="hidden" name="userrules" id="rules" value="<%=ListRules%>"/>
<input type="hidden" name="itemfocus" id="itemfocus" value=""/>
<input type="hidden" name="itemfocusMax" id="itemfocusMax" value="0"/>
<%
else ' Sub workflow


Call getRecordSet(SQL_CONSULTA_USUARIO_TODOS(), usuario)


%>
	
<td class="padded" align=right width=40%>
User Responsible: 
</td>
<td class="padded" width=60%>

<select name="owner" style="width:400px;">
<%
while not usuario.eof
%>
<option value="<%=usuario("email")%>"><%=usuario("name")%></option>
<%			
	usuario.movenext
wend
%>  
</select>
</td>


<%
end if

%>

