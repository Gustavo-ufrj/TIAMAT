<!--#include virtual="/system.asp"-->

<html>
<title>TIAMAT</title>
<body>

<table class="s0_bg" width=100%>
	<tr>
		<td>
			<center>
			<table width=1184>
				<tr valign=middle>
					<td width=30 height=80 class="font_titulo_2">
					&nbsp;
					</td>
					<td width=50 class="font_titulo_2">
					<a href="/"> 
					<img src="/img/TiamatLogo.png" height=50 width=auto>
					</a>
					</td>
					<td width=300 class="font_titulo_1" >
					<a href="/" class="title"> 
					TIAMAT 
					<font color=white>/</font><font color=green>/</font><font color=red>/</font><font color=blue>/</font><font color=black>/</font>
					</a>
					</td>
					
<%
if Session("email") <> "" then

%>
					
					<td width=15% class="font_titulo_2" align=center >
					<%
					if Session("admin") then
					%>
					<a href="/administration.asp" class="title"> <font color="red">ADMINISTRATION</font></a>
					<%
					end if
					currentURL = Session("currentURL")
					%>
					</td>
					<td width=15% class="font_titulo_2" align=center>
					<a href="/workplace.asp" class="title"> MY WORKPLACE </a>
					</td>
					<td width=30% class="font_titulo_2" valign="top" >
						<div style="display: table; position:relative; height: 40px; margin-left: auto; cursor: pointer;" onclick="showUser(true);">
							<img src="<%response.write Session("photo")%>" height="40px" width="auto">
							<span style="display: table-cell;vertical-align: middle;">&nbsp;&nbsp;&nbsp;&nbsp;<b><%response.write Session("name")%></b></span>
							<div style="width: 5px;">
								<div id="popup">
									<table width="100%"> 
										<tr>
											<td colspan=2> 
												<div style="display: table; position:relative; height: 30px; width: 100%; margin-left: auto; margin-right: auto;">
												
												<div style="position: relative; width:100px; height:100px;">
													<div style="position: absolute; top: 85%; left: 50%;transform: translate(-50%, -15%); text-align: center;"> 
															<a href="#" class="changePicture" onclick="window.location.href='/upload/upform.asp?numfiles=1&resize=1&url=<%=currentURL%>';"><div class="grayBar">Change</div></a>
													</div>
													<img src="<%response.write Session("photo")%>" height="100px" width="auto">
												</div>
													<span style="display: table-cell;vertical-align: middle; text-align: right; font-size:15px; white-space: nowrap;">&nbsp;&nbsp;<b><%response.write Session("name")%></b><br>&nbsp;&nbsp;<%response.write Session("email")%></span>
												</div>
											</td>
										</tr>
										<tr>
											<td colspan=2> 
												<hr class="linhaDupla">
											</td>
										</tr>
										<tr>
											<td align=left> 
												<button onclick="window.location.href='/profile.asp';" class="TIAMATButton">Profile</button>
											</td>
											<td align=right> 
												<button onclick="window.location.href='/logout.asp';" class="TIAMATButton">Logout</button>
											</td>
										</tr>
									</table> 
								</div>
							</div>
						</div>
					</td>

<%
else
%>					
				<td width=60% >

				</td>
<%
end if
%>					
			</tr>
		</table>
	</tr>
</table>



</body>
</html>