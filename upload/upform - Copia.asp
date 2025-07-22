<!--#include virtual="/system.asp"-->
<% 
if Session("email") = "" then
	response.redirect ("/index.asp")
end if 

dim numFiles, isIMG, i, urlback

urlback = Request.QueryString("url")
numFiles = Request.QueryString("numFiles")
img = Request.QueryString("resize")

if (not numFiles>0) or img = 1 then
numFiles = 1
end if


render.renderTitle()
%>
							<table class="principal" width=100%>
								<tr>
									<td width=20px>
										&nbsp;
									</td>
									<td align=center>
										<table width=1184 class="padded">

											<!-- INICIO AREA EDITAVEL -->
							

											<tr>
												<td>
 
<form action="upload.asp?workflowID=<%=Request.QueryString("workflowID")%>&stepID=<%=Request.QueryString("stepID")%>&resize=<%=img%>&url=<%=urlback%>" method="post" enctype="multipart/form-data">

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
		<tr height=400px>
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
 
												</td>
											</tr>
												

										<!-- FIM AREA EDITAVEL -->

										</table>
									</td>
									<td width=20px>
									&nbsp;&nbsp;&nbsp;
									</td>
								</tr>
							</table>

<%
render.renderFooter()
%>							