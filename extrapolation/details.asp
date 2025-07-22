<!--#include virtual="/system.asp"-->
<!--#include virtual="/checkstep.asp"-->
<!--#include file="INC_EXTRAPOLATION.inc"-->
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
<link rel="stylesheet" href="/css/jsgrid.css">
<link rel="stylesheet" href="/css/jsgrid.min.css">
<link rel="stylesheet" href="/css/jsgrid-theme.css">
<link rel="stylesheet" href="/css/jsgrid-theme.min.css">

<script src="/js/jquery.js"></script>
<script src="/js/jquery-ui-1.10.0.min.js"></script>
<script src="/js/jsgrid.js"></script>
<script src="/js/jsgrid.min.js"></script>
<script src="/js/i18n/jsgrid-pt-br.js"></script>
<script src="/js/tiamat.js"></script> 

<script> 
 $(function(){
   $("#title").load("/includes/title.asp"); 
   $("#footer").load("/includes/footer.html"); 
   $("#copyright").load("/includes/copyright.asp"); 
 });
</script> 

<style>
.jsgrid-pager {font-size: small;}
</style>
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
									<form action="actions.asp?action=setinfo" method="POST">
										<table width=1184 class="padded">

											<!-- INICIO AREA EDITAVEL -->
							

											<tr>
												<td>
													<p class="font_6" align="justify">EXTRAPOLATION: DETAILS <font color="red">//</font></p>							
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
												Dim xn,xd,yn,yd,tp,rg,fp,fn
												
												if not ri.eof then																							
													xn=ri("x_name")
													xd=ri("x_desc")
													yn=ri("y_name")
													yd=ri("y_desc")
													tp=ri("adj_type")
													rg=ri("range")
													sr=ri("source")
													
												else rg = 0
												
												end if
												
												tp_split = Split(tp,"|")
												up = .0
												if UBound(tp_split) = 1 then 
													tp = tp_split(0)
													up = Cdbl(tp_split(1))
												end if
		
												%>

											<tr>
												<td>
												
													<table width=100% class="padded">
													
													<tr>
														<td colspan=2 align="center">
														<p class="font_8" style="text-indent:0; margin-bottom: 20px; text-align:center;"><b>Data preview</b></p>
														<div id="grid" class="padded alignCenter">
														</div>
														</td>
													</tr>
													<tr>
														<td width="50%" valign="top" class="padded" style="padding: 20px 20px 0 0">														
														<p class="font_8" style="text-indent:0; margin-bottom: 20px; text-align:center;"><b>Column 1</b></p>
														Name: <input type="text" style="width: 90%" maxlength="100" name="x_name" value="<%=xn%>"></input>
														<td width="50%" valign="top" class="padded" style="padding: 20px 0 0 20px">
														<p class="font_8" style="text-indent:0; margin-bottom: 20px; text-align:center;"><b>Column 2</b></p>
														Name: <input type="text" style="width: 90%" maxlength="100" name="y_name" value="<%=yn%>"></input>
														</td>
													</tr>
													<tr>
														<td width="50%" valign="top" class="padded" style="padding: 20px 20px 0 0">
														Description: 
															<textarea name="x_desc" maxlength="500" style="width:100%;height:60px;"><%=xd%></textarea>
														</td>
														<td width="50%" valign="top" class="padded" style="padding: 20px 0 0 20px">
														Description: 
															<textarea name="y_desc" maxlength="500" style="width:100%;height:60px;"><%=yd%></textarea>
														</td>
													</tr>
													<tr>
														<td colspan=2 valign="top" class="padded">
														<table width="100%">
														<tr>
														<td width="50%">
														<div style="width: 60%; display: table-cell">
														<p class="font_8" style="text-align: center; padding: 20px 0; text-indent: 0"><strong>Regression type:</strong></p>
														<p class="font_8" style="text-align: center; text-indent: 0">
														<select name="adj_type" id="adj_type">
														<option id="type_linear" value="linear" 
														<% if tp="linear" then response.write("selected")%>>Linear</option>
														<option id="type_quad" value="quad" 
														<% if tp="quad" then response.write("selected")%>>Quadratic</option>
														<option id="type_cub" value="cub" 
														<% if tp="cub" then response.write("selected")%>>Cubic</option>
														<option id="type_exp" value="exp"
														<% if tp="exp" then response.write("selected")%>>Exponential</option>
														<option id="type_invexp" value="negexp" 
														<% if tp="negexp" then response.write("selected")%>>Negative-Exponential</option>
														<option id="type_invexp" value="invexp" 
														<% if tp="invexp" then response.write("selected")%>>Inverse-Exponential</option>
														<option id="type_niexp" value="niexp" 
														<% if tp="niexp" then response.write("selected")%>>Neg&amp;Inv-Exponential</option>
														<option id="type_pearl" value="pearl" 
														<% if tp="pearl" then response.write("selected")%>>Logarithmic (Pearl)</option>
														<option id="type_gompertz" value="gompertz" 
														<% if tp="gompertz" then response.write("selected")%>>Logarithmic (Gompertz)</option>
														<!--<option id="type_bestfit" value="bestfit" 
														<% if tp="bestfit" then response.write("selected")%>>Best fit</option>-->
														</select></p>
														</div>
														<div id="upperlimit" style="display: table-cell; text-align: center; width: 40%">
														<p class="font_8" style="text-indent: 0; padding: 20px 0;"><strong>Upper limit</strong></p>
															<input name="upperlimit" type="text" style="width: 60%;" value="<%=up%>"></input> 
														</div>
														</td>
														<td width="50%" style="align: center">
															<p class="font_8" style="padding: 20px 0; text-align: center; text-indent: 0"><strong>Extrapolation range</strong></p>
															<div id="range-slider" style="width: 400px; margin-right: 20px; float: left" ></div>
															<input id="range" name="range" type="hidden" value="<%=rg%>"></input> 
															<span id="range_val"></span>&nbsp; (<span id="range_perc"></span>%)
														</td>
														</tr>
														</table>
															</div>	
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
												<input type=hidden name="source" value="<%=sr%>" />
												<input type=hidden name="stepID" value="<%=request.querystring("stepID")%>" />
												<a class="TIAMATButton" href="data.asp?stepID=<%=stepID%>"><< Prev</a>
												<!--<a class="TIAMATButton" href="actions.asp?action=setinfo&stepID=<%=stepID%>">Results ></a>-->
												<button class="TIAMATButton">Results >></button>
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

	$(document).ready( function() {
	
	$('#upperlimit').hide();
	if ($("#adj_type").val() == "pearl" || $("#adj_typex").val() == "gompertz")
		$('#upperlimit').show();
		
	$('#adj_type').on("change",function(){
		$('#upperlimit').hide();
		if ($(this).val() == "pearl" || $(this).val() == "gompertz")
			$('#upperlimit').show();
	});
	
		loadGrid($("#grid"));
	});
	
	function updateSliderValues(value,min,max) {
		$("#range").val(value);
		$("#range_val").text(value);
		$("#range_perc").text(((value-min)/(max-min)*100).toFixed(2));
	};
	
	function loadSlider(actualValue,minValue,maxValue) {
		$("#range-slider").slider({
			step: 1,
			min: minValue + 1,
			max: maxValue,
			value: actualValue,
			create: function( event, ui ) {
				updateSliderValues(actualValue, minValue, maxValue);
			},
			slide: function( event, ui ) {
				updateSliderValues(ui.value, minValue, maxValue);
			},
		});
		
	};
  
	function loadGrid(gridDiv) {
		 
		//jsGrid.locale("pt-br");
		
		function FloatNumberField(config) {
			jsGrid.TextField.call(this, config);
		}

		FloatNumberField.prototype = new jsGrid.TextField({
			itemTemplate: function(value) {return value.toFixed(2); },
			filterValue: function() { return parseFloat(this.filterControl.val()); },
			insertValue: function() { return parseFloat(this.insertControl.val()); },
			editValue: function() { return parseFloat(this.editControl.val()); }
		});

		jsGrid.fields.floatNumber = FloatNumberField;
		
		gridDiv.jsGrid({
			height: "auto",
			width: "50%",
			inserting: false,
			editing: false,
			paging: true,
			pageSize: 10,
			autoload: true,
			sorting: true,
			noDataContent: "No data",
			
			onDataLoaded: function(args) {
				this.sort({field: "x", order: "asc"});
			},
			
			controller: {
				
				loadData: function(filter) {
					return $.ajax({
						type: "GET",
						url: "actions.asp?action=list&stepID=<%=stepID%>",
						data: filter
					}).success(function( data ) { 
						var firstValue = data[0].x;
						var lastValue = data[data.length-1].x;
						var actualValue = <%=rg%>;
						if (actualValue == 0) actualValue = lastValue + 1;
						loadSlider(actualValue,lastValue, 2 * lastValue - firstValue);
					});
				},

			},
				 
			fields: [
				{ name: "pointid", visible: false },
				{ name: "x", title: "Column 1", type: "floatNumber", validate: [ function(n) { return !isNaN(n) } ] },
				//{width: "40%"},
				{ name: "y", title: "Column 2", type: "floatNumber", validate: [ function(n) { return !isNaN(n) } ] },
				//{
				//	type: "control",
				//	modeSwitchButton: true,
				//	editButton: true,
				//	deleteButton: true,
				//},
			]
		});	
	};
</script>

</body>
</html>