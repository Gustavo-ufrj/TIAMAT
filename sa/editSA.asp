<!--#include virtual="/system.asp"-->
<!--#include virtual="/checkstep.asp"-->
<!--#include file="INC_SA.inc"-->
<%
saveCurrentURL

tiamat.addCSS("sa.css")


render.renderTitle()
%>


							<table class="principal" width=100%>
								<tr>
									<td width=20px>
										&nbsp;
									</td>
									<td align=center>
									<form id="saAction" name="saAction" action="saActions.asp?action=save" method="POST">
										<table width=1184 class="padded">

											<!-- INICIO AREA EDITAVEL -->
							

											<tr>
												<td>
													<p class="font_6" align="justify">EDIT STAKEHOLDER ANALYSIS<font color="red">//</font></p>							
												</td>
											</tr>
											<tr>
												<td>
												<hr class="linhaDupla">
												</td>
											</tr>

											<%
												
											Dim description

											call getRecordSet (SQL_CONSULTA_SA(request.querystring("stepID")), rs)
											
											if not rs.eof then																							
												SAID=rs("SAID")
												description=rs("description")
											else
												SAID=""
												description=""
											end if
								
											%>

											<tr>
												<td>
												<table width=100% class="padded">
													<tr>
														<td align=right width=30%>
															<p class="font_8" style="text-indent:0;"><b>Description: &nbsp;</b></p>
														</td>
														<td width=60%>
															<textarea name="description" style="width:60%;height:180px;"><%=description%></textarea>
														</td>
													</tr>
												</table>
											</tr>
											
											<tr>
												<td>
													<hr class="linhaDupla">
												</td>
											</tr>
											<tr>
												<td align=center>
												<input type=hidden name="hidden_SAID" id="hidden_SAID" value="<%=SAID%>" />
												<input type=hidden name="stepID" value="<%=request.querystring("stepID")%>" />
												<input class="TIAMATButton" type="submit" value="Save" />
												</td>
											

										<!-- FIM AREA EDITAVEL -->

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