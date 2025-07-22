<!--#include virtual="/system.asp"-->
<!--#include virtual="/checkstep.asp"-->
<!--#include file="INC_DELPHI.inc"-->

<%
saveCurrentURL

Dim rs
Dim stepID
Dim role

If Request.querystring("stepID") <> "" Then
	stepID = request.querystring("stepID")
	
	role = getRole(stepID, Session("email"))
	
	If role = "Coordinator" Then
		Call getRecordSet (SQL_CONSULTA_DELPHI(stepID), rs)

		If rs.EOF Then
			Call ExecuteSQL(SQL_CRIA_DELPHI(stepID))
		End If
	Else
		Session("delphiError") = "You are not a delphi coordinator."
		response.redirect "index.asp?stepID=" & stepID & "&redirect=1"
	End If
End If


tiamat.addCSS("delphi.css")

render.renderTitle()
%>


							<table class="principal" width=100%>
								<tr>
									<td width=20px>
										&nbsp;
									</td>
									<td align=center>
									<form action="delphiActions.asp?action=save" method="POST">
										<table width="1184px" class="padded">

											<!-- INICIO AREA EDITAVEL -->
							

											<tr>
												<td>
													<p class="font_6" align="justify">EDIT DELPHI <font color="red">//</font></p>							
												</td>
											</tr>
											<tr>
												<td>
												<hr class="linhaDupla">
												</td>
											</tr>
											<tr>
												<td>
													<%
														If stepID <> "" Then
															Call getRecordSet(SQL_CONSULTA_DELPHI(stepID), rs)
															
															response.write("<div id=""delphi-info"">")
															response.write("<label class=""description"">Description: </label>")
															
															response.write("<textarea class=""description"" name=""text"">")
															If Not rs.EOF Then
																response.write(rs("text"))
															End If
															response.write("</textarea>")
															response.write("</div>")
														End If
													%>
												</td>
											</tr>
											<tr>
												<td>
													<hr class="linhaDupla">
												</td>
											</tr>
											<tr>
											
												<td align=center>
													<input type=hidden name="stepID" value="<%=stepID%>" />
													<button class="TIAMATButton" onclick="window.location.href='index.asp?stepID=<%=stepID%>';return false;">Back</button>
													<button class="TIAMATButton">Save</button>
												</td>

										<!-- FIM AREA EDITAVEL -->

											</tr>
											<tr>
												<td height="60px" valign="middle" align="center" colspan="2" class="padded" >
													<font class="error-msg" color=red><%=Session("delphiError")%></font>
													<%
													Session("delphiError") = ""
													%>
												</td>
											</tr>
										</table>
									</form>
									</td>
									<td width=20px>
									&nbsp;&nbsp;&nbsp;
									</td>
								</tr>
							</table>

<%
render.renderFooter()
%>
