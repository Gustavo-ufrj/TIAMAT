<!--#include virtual="/system.asp"-->
<!--#include virtual="/checkstep.asp"-->
<!--#include file="INC_TIA.inc"-->
<%saveCurrentURL

stepID = request.querystring("stepID")%>

<html>

<head> 
<meta charset="utf-8">
<title>TIAMAT</title>

<link rel="shortcut icon" href="/css/favicon.png">
<link rel="stylesheet" href="/css/main.css">
<link rel="stylesheet" href="/css/mobileFIX.css">
<link rel="stylesheet" href="/css/text.css">
<link rel="stylesheet" href="/css/metro/jquery-ui.css">


<script src="/js/jquery.js"></script>
<script src="/js/jquery-ui-1.10.0.min.js"></script>
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
									<form action="actions.asp?action=save" method="POST">
										<table width=1184 class="padded">

											<!-- INICIO AREA EDITAVEL -->
							

											<tr>
												<td>
													<p class="font_6" align="justify">TIA: DATA SOURCE <font color="red">//</font></p>							
												</td>
											</tr>
											<tr>
												<td>
												<hr class="linhaDupla">
												</td>
											</tr>

												<%
													
												call getRecordSet(SQL_READ_INFORMATION(stepID), ri)
												call getRecordSet(SQL_READ_FILENAME(stepID), rf)
												call getRecordSet(SQL_READ_POINTS(stepID), rp)
												Dim xn,xd,yn,yd,tp,rg,fp,fn,sr
												
												if not ri.eof then						
													sr=ri("source")
												end if
												%>

											<tr>
												<td>
												
													<table width=100% class="padded">
													
													<tr>
														</td>
														<td width="60%" valign="top" class="padded">
														<p class="font_8" style="text-align: center; padding: 20px 0; text-indent: 0">
														Data source</p>
														<table width="100%">
														<tbody>
														<tr>
														<td width="32%" valign="top">
														<p class="font_8" style="text-align: center; text-indent: 0; padding-bottom: 20px"><input id="source_file" type="radio" name="source" value="file"
														<% if sr="file" then response.write("checked")%>> File</p>
														<p class="font_8" style="text-align: center; text-indent: 0">
														<% if not rp.eof and sr="file" then response.write("Uploaded ")%>
														<a id="file" class="TIAMATButton toggle" onclick="window.open('/upload/upform.asp?numfiles=1&stepID=<%=stepID%>&method=extrapolation&url=<%=Session("currentURL")%>', 'Upload', 'width=400, height=200');" <% if sr<>"file" then response.write("disabled")%>>
														<% if sr="file" and not rp.eof then response.write("Upload new file") else response.write("Upload file")%>
														</a></p>
														
														<!-- <p class="font_8" style="text-align: center; text-indent: 0"><small><% if sr="file" then Response.Write(fn) end if %></small></p> -->
														</td>
														<td width="33%" valign="top">
														<p class="font_8" style="text-align: center; text-indent: 0; padding-bottom: 20px;"><input id="source_database" type="radio" name="source" value="database"
														<% if sr="database" then response.write("checked")%>> Database</p>
														<p class="font_8" style="text-align: center; text-indent: 0"><a id="database" class="TIAMATButton toggle" onclick="window.open('dbform.asp?stepID=<%=stepID%>&url=<%=Session("currentURL")%>', 'Upload', 'width=400, height=400');" <% if sr="file" then response.write("disabled")%>>Connect</a></p>
														</td>
														<td width="35%" valign="top">
														<p class="font_8" style="text-align: center; text-indent: 0; padding-bottom: 20px;"><input id="source_extrapolation" type="radio" name="source" value="extrapolation"
														<% if sr <> "" and sr <> "file" and sr <> "database" then response.write("checked")%>> Previous <em>Extrapolation</em> step</p>
														
														<%
																
															call getRecordSet(SQL_LIST_EXTRAPOLATION_INFORMATION(stepID), rei)
															dim extr_id, x_name, y_name, adj_type
															if not rei.eof then	
															
														%>
														<div id="extrapolation" class="toggle">
														<select name="extrapolation_step_id">
														<%
																rei.moveFirst
																do until rei.eof
																	extr_id = rei("stepID")
																	x_name = rei("x_name")
																	y_name = rei("y_name")
																	adj_type = rei("adj_type")
														%>
															<option id="id_<%=extr_id%>" value="<%=extr_id%>" <% if CStr(extr_id) = sr then response.write "selected='selected'" %> ><%=y_name%> vs <%=x_name%> (<%=adj_type%>)</option>
														<%
																	rei.moveNext
																loop
														
														%><input type=hidden name="source" value="<%=stepID%>" />
														<button class="TIAMATButton">
														<% if sr <> "" and sr <> "file" and sr <> "database" and not rp.eof then response.write("Import") else response.write("Import")%></button>
														</select></p>
														</div>
														<%
															else response.write ("No previous data to import.")
															end if
														%>
														</td>
														</tr>
														</tbody>
														</table>
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
												<input type=hidden name="stepID" value="<%=stepID%>" />
												<% if sr<>"" then response.write("<a class=""TIAMATButton"" href=""details.asp?stepID=" & stepID & """>Next >></a> ")%>
												<!--<button class="TIAMATButton">Save</button>-->
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
<script type="text/javascript">
  $(document).ready(function () {
			$('.toggle').hide();
			$("#"+$('input[name="source"]:checked').val()).show();
		});
		
		$('[name="source"]').on("ready click",function(){
			$('.toggle').hide();
			$("#"+$(this).val()).show();
    });
</script>
</body>
</html>