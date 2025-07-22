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
 
 $(document).ready(function(){
 
	$('#addPoints td a').click(function(){
		records = 0;
		if ($( "#records" ).length > 0) records = parseInt($( "#records" ).val());
	 
		records++;
		$("#addPoints").before("<tr id=\"point_" + (records) + "\">\r\n<td width=\"40%\" align=\"center\" class=\"padded\">X = <input name=\"x_value_" + (records) + "\" style=\"width:50%\"></input></td>\r\n<td width=\"40%\" align=\"center\" class=\"padded\">Y = <input name=\"y_value_" + (records) + "\" style=\"width:50%\"></input></td>\r\n<td width=\"20%\" valign=\"top\" class=\"padded\">\<a id=\"" + (records) + "\" class=\"delete_value TIAMATButton\" style=\"text-align:center;\" href=\"javascript:void(0);\">Delete value</a>\r\n</td></tr>");
		
		$( "#records" ).val(records);
	});
	
	$('.delete_value').click(function(){
		id = $(this).attr("id");
		console.log(id);
		$("#point_" + id).remove();
		records = parseInt($( "#records" ).val());
		$( "#records" ).val(records-1);
	 });
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
													<p class="font_6" align="justify">EDIT VALUES <font color="red">//</font></p>							
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
											<%
												
											call getRecordSet (SQL_READ_POINTS(request.querystring("stepID")), rsp)
											call getRecordSet (SQL_READ_INFORMATION(request.querystring("stepID")), rsi)
											
											index = 1
											
											if not rsi.eof then
												x_name = rsi("x_name")
												y_name = rsi("y_name")
											end if
											
											%>
													<thead>
													<tr>
														<td width="40%" valign="top" class="padded">
															<p class="font_8" style="text-indent:0; text-align:center;"><strong>X variable name</strong></p>
															<input name="x_name" style="width:100%" value="<%=x_name%>"></input>
														</td>
													
														<td width="40%" valign="top" class="padded">
															<p class="font_8" style="text-indent:0; text-align:center;"><strong>Y variable name</strong></p>
															<input name="y_name" style="width:100%" value="<%=y_name%>"></input>
														</td>
														
													</tr>
													</thead>
													<tbody>
											
													<tr>
														<td colspan="2">
															<hr class="linhaDupla">
															<p style="text-align: center"><strong>Values</strong></p>
														</td>
													</tr>
											
											<% 			
											if not rsp.eof then 
											
											do
											%>
													<tr id="point_<%=index%>">
														<td width="40%" align="center" valign="top" class="padded">
															X = <input name="x_value_<%=index%>" style="width:50%" value="<%=rsp("x")%>"></input>
														</td>
														<td width="40%" align="center" valign="top" class="padded">
															Y = <input name="y_value_<%=index%>" style="width:50%" value="<%=rsp("y")%>"></input>
														</td>
														<td width="20%" valign="top" class="padded">
															<a id="<%=index%>" class="delete_value TIAMATButton" style="text-align:center;" href="javascript:void(0);">Delete value</a>
														</td>
													</tr>
											
											<% 
											index = index + 1
											rsp.movenext
											loop while not rsp.eof
											index = index - 1
											else index = 0
											
											end if 
											%>
													<tr id="addPoints">
														<td style="text-align:center;" colspan="2" class="padded">
															<input type="hidden" name="records" id="records" value="<%=(index )%>">
															<a style="text-align:center;" href="javascript:void(0);" class="TIAMATButton">Add values</a>
														</td>
													</tr>											
													</tbody>
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
												<button  style="text-align:center;" class="TIAMATButton">Save</button>
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

<script>
 $(document).ready(function(){
 
	$( "#records" ).val(<%=index%>);
 });
</script>

</body>
</html>