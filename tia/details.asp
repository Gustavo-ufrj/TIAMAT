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
													<p class="font_6" align="justify">TIA: SERIES DETAILS <font color="red">//</font></p>							
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
													si=ri("scenarios")
												end if
												%>

												<tr>
														<td colspan=2 align="center">
														<p class="font_8" style="text-indent:0; margin-bottom: 20px; text-align:center;"><b>Data preview</b></p>
														<div id="grid" class="padded alignCenter">
														</div>
														</td>
													</tr>
											<tr>
												<td>
												
													<table width=100% class="padded">
													
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
														<td width="40%">
														<p class="font_8" style="text-align: center; padding: 20px 0; text-indent: 0"><strong>Regression type:</strong></p>
														<p class="font_8" style="text-align: center; text-indent: 0"><select name="adj_type">
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
														<!--<option id="type_bestfit" value="bestfit" 
														<% if tp="bestfit" then response.write("selected")%>>Best fit</option>-->
														</select></p>
														</td>
														<td width="40%">
															<p class="font_8" style="padding: 20px 0; text-align: center; text-indent: 0"><strong>Extrapolation range</strong></p>
															<div id="range-slider" style="width: 400px; margin-right: 20px; float: left" ></div>
															<input id="range" name="range" type="hidden" value="<%=rg%>"></input> 
															<span id="range_val"></span>&nbsp; (<span id="range_perc"></span>%)
														</td>
														<td width="20%">
															<p class="font_8" style="padding: 20px 0; text-align: center; text-indent: 0"><strong>Number of scenarios:</strong> &nbsp; </p>
															<p class="font_8" style="text-align: center; text-indent: 0"><input id="scenarios" name="scenarios" type="text" style="width: 100px;" 
															value="<% if CInt(si) > 0 then response.write si %>"></input></p>
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
												<input type=hidden name="stepID" value="<%=stepID%>" />
												<a class="TIAMATButton" href="data.asp?stepID=<%=stepID%>"><< Data</a>
												<button class="TIAMATButton">Events >></button>
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
var dataT;
	$(document).ready( function() {
		loadGrid($("#grid"));		
	});
	
	
	function loadSlider(minValue,maxValue) {
		$("#range-slider").slider({
			step: 1,
			min: minValue + 1,
			max: maxValue,
			value: <%=rg%>,
			create: function( event, ui ) {
				updateSliderValues(<%=rg%>, minValue, maxValue);
			},
			slide: function( event, ui ) {
				updateSliderValues(ui.value, minValue, maxValue);
			},
		});
		
	};
  
	function updateSliderValues(value,min,max) {
		$("#range").val(value);
		$("#range_val").text(value);
		$("#range_perc").text(((value-min)/(max-min)*100).toFixed(2));
	};
	
	function loadGrid(gridDiv) {
		 
		//jsGrid.locale("pt-br");
		
		function FloatNumberField(config) {
			jsGrid.TextField.call(this, config);
		}

		FloatNumberField.prototype = new jsGrid.TextField({
			itemTemplate: function(value) {return value.toFixed(2); },
			filterValue: function() { return parseFloat(this.filterControl.val()); },
			// insertValue: function() { return parseFloat(this.insertControl.val()); },
			// editValue: function() { return parseFloat(this.editControl.val()); }
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
						loadSlider(lastValue, 2 * lastValue - firstValue);
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