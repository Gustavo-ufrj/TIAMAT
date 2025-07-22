<!--#include virtual="/system.asp"-->
<!--#include virtual="/checkstep.asp"-->
<!--#include file="INC_EXTRAPOLATION.inc"-->
<%saveCurrentURL%>

<html>

<head> 
<meta charset="utf-8">
<title>TIAMAT</title>

<link rel="shortcut icon" href="/css/favicon.png">
<link rel="stylesheet" href="/css/main.css">
<link rel="stylesheet" href="/css/mobileFIX.css">
<link rel="stylesheet" href="/css/text.css">


<script src="/js/jquery.js"></script> 
<script src="/js/tiamat.js"></script> 

<script> 
 $(function(){
   $("#title").load("/includes/title.asp"); 
   $("#footer").load("/includes/footer.html"); 
   $("#copyright").load("/includes/copyright.asp"); 
 });
</script> 

</head> 

<body>

<table width=100% onclick="showUser(false);">
	<tr>
		<td>
			<center>
				<table width=100%>
					<tr>
						<td>
							<div id="title"></div>
						</td>
					</tr>

					<tr>
						<td>
							<table class="principal" width=100%>
								<tr>
									<td width=20px>
										&nbsp;
									</td>
									<td align=center>
									<form action="swotActions.asp?action=save" method="POST">
										<table width=1184 class="padded">

											<!-- INICIO AREA EDITAVEL -->
							

											<tr>
												<td>
													<p class="font_6" align="justify">EDIT SWOT <font color="red">//</font></p>							
												</td>
											</tr>
											<tr>
												<td>
												<hr class="linhaDupla">
												</td>
											</tr>

												<%
													
												call getRecordSet (SQL_READ_POINTS(request.querystring("stepID")), rs)
												Dim s,w,o,t
												
												if not rs.eof then																							
												s=rs("strengths")
												w=rs("weakness")
												o=rs("opportunities")
												t=rs("threats")
												end if
									
												%>

											<tr>
												<td>
													<table width=100% class="padded">
													<tr>
														<td width="50%" valign="top" height=200px class="padded" style="border-right:solid 1px #888888;border-bottom:solid 1px #888888;">														
														<p class="font_8" style="text-indent:0; text-align:center;"><b>Strengths</b></p>
															<textarea name="strengths" style="width:100%;height:180px;"><%=s%></textarea>
														</td>
														<td width="50%" valign="top" class="padded">
														<p class="font_8" style="text-indent:0; text-align:center;"><b>Weakness</b></p>
															<textarea name="weakness" style="width:100%;height:180px;"><%=w%></textarea>
														</td>
													</tr>
													<tr>
														<td width="50%" valign="top"  height=200px class="padded">
														<p class="font_8" style="text-indent:0; text-align:center;"><b>Opportunities</b></p>
															<textarea name="opportunities" style="width:100%;height:180px;"><%=o%></textarea>
														</td>
														<td width="50%" valign="top" class="padded" style="border-left:solid 1px #888888;border-top:solid 1px #888888;">
														<p class="font_8" style="text-indent:0; text-align:center;"><b>Threats</b></p>
															<textarea name="threats" style="width:100%;height:180px;"><%=t%></textarea>
														</td>
													</tr>

													</table>
												</td>
											</tr>
											<tr>
												<td>
													<hr class="linhaDupla">
												</td>
											</tr>
											
											<tr>
												<td align=center>
												<input type=hidden name="stepID" value="<%=request.querystring("stepID")%>" />
												<button class="TIAMATButton">Save</button>
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
						</td>
					</tr>

					<tr>
						<td>
						<!-- FOOTER -->
						<div id="footer"></div>
						</td>
					</tr>
					<tr>
						<td>
						<!-- COPYRIGHT -->
						<div id="copyright"></div>
						</td>
					</tr>
				</table>
			</center>
		</td>
	</tr>
</table>

</body>
</html>