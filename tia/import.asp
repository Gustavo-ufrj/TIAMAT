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
									
										<table width=1184 class="padded">

											<!-- INICIO AREA EDITAVEL -->
							

											<tr>
												<td>
													<p class="font_6" align="justify">TIA: IMPORT SERIES DATA <font color="red">//</font></p>							
												</td>
											</tr>
											<tr>
												<td>
												<hr class="linhaDupla">
												</td>
											</tr>

											<tr>
												<td>
												
													<table width=100% class="padded">
													
													<tr>
														<td width="49%" valign="top" class="padded" style="text-align: center;">														
														Import data and information from existing <em>Extrapolation</em> step
														</td>
														<td colspan=2 width="2%" va;ign="top" class="padded" style="text-align: center; ">
														<strong>or</strong>
														</td>
														<td width="49%" valign="top" class="padded" style="text-align: center; ">		

														<%
																
															call getRecordSet(SQL_READ_INFORMATION(stepID), ri)
															if not ri.eof then 
																response.write ("Edit data")
															else 	
																response.write ("Create new data")
															end if															
														%>					
														</td>
													</tr>
													<tr>
														<td colspan=2 width="50%" class="padded" style="text-align: center; border-right:solid 1px #888888">
														<%
																
															call getRecordSet(SQL_LIST_EXTRAPOLATION_INFORMATION(), rei)
															dim extr_id, x_name, y_name, adj_type
															if not rei.eof then	
															
														%>
														<form action="actions.asp?action=import" method="POST">
														<p class="font_8" style="padding: 20px 0; text-indent: 0"><strong>Previous steps:</strong></p>
														<p class="font_8" style="text-indent: 0">
														<select name="extrapolation_step_id">
														<%
																rei.moveFirst
																do until rei.eof
																	extr_id = rei("stepID")
																	x_name = rei("x_name")
																	y_name = rei("y_name")
																	adj_type = rei("adj_type")
														%>
															<option id="id_<%=extr_id%>" value="<%=extr_id%>"><%=y_name%> vs <%=x_name%> (<%=adj_type%>)</option>
														<%
																	rei.moveNext
																loop
														
														%><input type=hidden name="stepID" value="<%=stepID%>" />
												<button class="TIAMATButton">Import</button>
														</select></p>
														</form>
														<%
															else response.write ("No previous data to import.")
															end if
														%><%
																
															call getRecordSet(SQL_LIST_EXTRAPOLATION_INFORMATION(), rei)
															dim extr_id, x_name, y_name, adj_type
															if not rei.eof then	
															
														%>
														<form action="actions.asp?action=import" method="POST">
														<p class="font_8" style="padding: 20px 0; text-indent: 0"><strong>Previous steps:</strong></p>
														<p class="font_8" style="text-indent: 0">
														<select name="extrapolation_step_id">
														<%
																rei.moveFirst
																do until rei.eof
																	extr_id = rei("stepID")
																	x_name = rei("x_name")
																	y_name = rei("y_name")
																	adj_type = rei("adj_type")
														%>
															<option id="id_<%=extr_id%>" value="<%=extr_id%>"><%=y_name%> vs <%=x_name%> (<%=adj_type%>)</option>
														<%
																	rei.moveNext
																loop
														
														%><input type=hidden name="stepID" value="<%=stepID%>" />
												<button class="TIAMATButton">Import</button>
														</select></p>
														</form>
														<%
															else response.write ("No previous data to import.")
															end if
														%>
														</td>
														<td colspan=2 width="50%" class="padded" style="text-align: center;">
														<a class="TIAMATButton" href="details.asp?stepID=<%=stepID%>">Next >></a>
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
												
												</td>
											

										<!-- FIM AREA EDITAVEL -->

											</tr>
										</table>
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