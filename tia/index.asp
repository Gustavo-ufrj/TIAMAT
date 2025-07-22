<!--#include virtual="/system.asp"-->
<!--#include virtual="/checkstep.asp"-->
<!--#include file="INC_TIA.inc"-->

<%saveCurrentURL

stepID = request.querystring("stepID")

call getRecordSet(SQL_READ_INFORMATION(stepID), ri)
Dim xn,xd,yn,yd

if not ri.eof then																						
xn=ri("x_name")
xd=ri("x_desc")
yn=ri("y_name")
yd=ri("y_desc")
tp=ri("adj_type")
rg=ri("range")
end if

if xn = "" and yn = "" then
response.redirect "data.asp?stepID="+stepID
end if

%>
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
<script type="text/javascript" src="https://www.google.com/jsapi?autoload= {'modules':[{'name':'visualization','version':'1.1','packages':['corechart']}]}"></script>
<script type="text/javascript" src="https://www.gstatic.com/charts/loader.js"></script>
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
										<table width=1184 class="padded">

											<!-- INICIO AREA EDITAVEL -->
							

											<tr>
												<td colspan=2>
													<p class="font_6" align="justify">TIA RESULTS: <%=yn%> by <%=xn%> <font color="red">//</font></p>							
												</td>
											</tr>
											<tr>
												<td colspan=2>
													<hr class="linhaDupla">
												</td>
											</tr>
											<tr>
												<td style="width: 35%; vertical-align: top">
													<div id="grid" class="padded alignCenter">
													</div>
													<div id="export" class="padded alignCenter" style="padding-top: 20px"></div>
												</td>
												<td style="width: 65%; vertical-align: top">
												<!--<p style="margin-bottom: 40px; text-align: center">Adjust type: <input id="type_linear" type="radio" name="adjust_type" value="linear"> Linear <input id="type_exp" type="radio" name="adjust_type" value="exp"> Exponential</p>
												<div style="margin-bottom: 40px; text-align: center">Extrapolation range:  <div id="slider" style="margin-left: 5px; width: 50%; display: inline-block;"></div>
												<div id="slider-value" style="margin-left: 5px; display: inline-block;"></div>
												</div>-->
													<div id="chart" style="margin-left: 40px; height: 500px"></div>
													<div id="toolbar"></div>
												</td>
												
											</tr>
											<tr>
												<td colspan=2>
													<hr class="linhaDupla">
												</td>
											</tr>
											<tr>
												<td colspan=2 align=center>
												<a class="TIAMATButton" href="data.asp?stepID=<%=stepID%>">Edit details</a>
												<a class="TIAMATButton" href="actions.asp?action=execute&stepID=<%=stepID%>">Re-generate scenarios</a>
												<button class="TIAMATButton" style="width: 100px;" onclick="window.location.href='actions.asp?action=end&stepID=<%=stepID%>'">End TIA</button>
												
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

	var dataTable = null;

	
	function createCSVData(data) {
		const header = ["<%=xn%>", "<%=yn%>", "Forecast (Median)"];
		var csvContent = "data:text/csv;charset=utf-8,";
		csvContent += header.join(";") + "\r\n";;
		data.forEach(function(json){
			row = json.x + ";" + json.y + ";" + json.z;
			csvContent += row + "\r\n";
		});
		var encodedUri = encodeURI(csvContent);
		// var link = document.getElementById("export").createElement("a");
		// link.setText("Download");
		// link.setAttribute("href", encodedUri);
		// link.setAttribute("download", "export.csv");
		// document.getElementById("export").appendChild(link); // Required for FF
		jQuery('<a/>', {
			id: 'download',
			class: 'TIAMATButton',
			href: encodedUri,
			title: 'Download',
			rel: 'external',
			text: 'Download',
			download: 'export.csv'
		}).appendTo('#export');

	}; 
	
	function loadGrid() {
		 
		var grid = $("#grid");
		//jsGrid.locale("pt-br");
		
		function FloatNumberField(config) {
			jsGrid.TextField.call(this, config);
		}

		FloatNumberField.prototype = new jsGrid.TextField({
			itemTemplate: function(value) {
				if (value) 
					if (value == parseInt(value, 10)) 
						return value;
					else
						return value.toFixed(2); 
			},
			filterValue: function() { return parseFloat(this.filterControl.val()); },
			insertValue: function() { return parseFloat(this.insertControl.val()); },
			editValue: function() { return parseFloat(this.editControl.val()); }
		});


		jsGrid.fields.floatNumber = FloatNumberField;
		
		grid.jsGrid({
			height: "auto",
			width: "100%",
			paging: true,
			// inserting: true,
			// editing: true,
			pageSize: 10,
			autoload: true,
			sorting: true,
			noDataContent: "No data",
			
			onDataLoaded: function(args) {
				this.sort({field: "x", order: "asc"});
			},
			
			onItemInserted: function(args) {
				loadGraphData();
				this.sort({field: "x", order: "asc"});
			},
			
			// onItemUpdating: function(args) {
			// 	previousItem = args.previousItem;
			// },
			// 
			// onItemUpdated: function(args) {
			// 	loadGraphData();
			// 	this.sort({field: "x", order: "asc"});
			// },
			// 
			// onItemDeleted: function(args) {
			// 	loadGraphData();
			// 	this.sort({field: "x", order: "asc"});
			// },

			controller: {
				
				loadData: function(filter) {
					return $.ajax({
						type: "GET",
						url: "actions.asp?action=listresult&stepID=<%=stepID%>",
						data: filter
					}).success(function( data ) { 
						dataTable = data;
						createCSVData(data);
					});
				},
				
				// insertItem: function(item) {
				// 	return $.ajax({
				// 		type: "GET",
				// 		url: "actions.asp?action=insert&stepID=<%=stepID%>",
				// 		data: item
				// 	});
				// },
				// 
				// updateItem: function(item) { 
				// 	var d = $.Deferred();
				// 	$.ajax({
				// 		type: "GET",
				// 		url: "actions.asp?action=update",
				// 		data: item
				// 	}).done(function(response) {
				// 		d.resolve(response);
				// 	}).fail(function() {
				// 		d.resolve(previousItem);
				// 	});
				// 	return d.promise();
				// },
				// 
				// deleteItem: function(item) {
				// 	return $.ajax({
				// 		type: "GET",
				// 		url: "actions.asp?action=delete",
				// 		data: item
				// 	});
				// },
			},
				 
			fields: [
				{ name: "x", title: "<%=xn%>", type: "floatNumber", validate: [ function(n) { return !isNaN(n) } ] },
				{ name: "y", title: "<%=yn%>", type: "floatNumber", validate: [ function(n) { return !isNaN(n) } ] },
				{ name: "z", title: "Forecast (Median)", type: "floatNumber", validate: [ function(n) { return !isNaN(n) } ] },
				// {
				// 	type: "control",
				// 	modeSwitchButton: true,
				// 	editButton: true,
				// 	deleteButton: true,
				// },
			]
		});	
	};
	
	// Graph
	
	function loadGraphData() {
		$.ajax({ 
			url: "actions.asp?action=result&stepID=<%=stepID%>",
			type: 'GET', 
			dataType: 'json',
			success: function (response) { 
				google.charts.setOnLoadCallback(loadGraph(response));
			}
		});
	}
	var v = null;
	function loadGraph(data) {
	
		// Array positions:
		// 0: X value
		// 1: Y value (real + fitted curve)
		// 2: Y' value (forecast baseline)
		// 3: Median
		// 4: Min
		// 5: Max

			
		// Grouping values (real + extrapolation + scenarios) by X value
		v = [];
		var r = data.values.reduce(function(array, object) {
			if ( !array[object.x] ) { 
				if (object.y)
					array[object.x] = [object.x, object.y, object.z, null, null, null];
				else 
					array[object.x] = [object.x, null, null, null, null, null];
			}
			if (object.info == "Baseline")
				array[object.x][2] = object.z;
			else if (object.info == "Median")
				array[object.x][3] = object.z;
			else if (object.info == "Min")
				array[object.x][4] = object.z;
			else if (object.info == "Max")
				array[object.x][5] = object.z;
			
			return array;
		}, {});
		for (var key in r) {
			v.push(r[key]);
		}
		
		
        var dataTable = new google.visualization.DataTable();
        dataTable.addColumn('number', 'X');
        dataTable.addColumn('number', 'Values');
        dataTable.addColumn('number', 'Baseline');
		dataTable.addColumn('number', 'Median');
		dataTable.addColumn('number', '5th Percentile');
		dataTable.addColumn('number', '95th Percentile');
		dataTable.addRows(v);
		
		var formatterInt = new google.visualization.NumberFormat({ pattern: '#' });
		var formatterDec = new google.visualization.NumberFormat({ pattern: '#.##' });
		formatterInt.format(dataTable,0);
		formatterDec.format(dataTable,1);
		formatterDec.format(dataTable,2);
		formatterDec.format(dataTable,3);
		formatterDec.format(dataTable,4);
		formatterDec.format(dataTable,5);
		
        var options_lines = {
			title : "<%=yn%> by <%=xn%>",
			vAxis: {title: "<%=yn%>", format: "#"},
			hAxis: {title: "<%=xn%>", format: "#"},
			series: [
				{type: 'line', lineWidth: 0, pointSize: 3, 'color': '#00f',  pattern: '#'},
				{'color': '#00f', pattern: '#'},
				{'color': '#000', pattern: '#', lineDashStyle: [10, 2]},
				{'color': '#0f0', pattern: '#', lineDashStyle: [4, 2]},
				{'color': '#f00', pattern: '#', lineDashStyle: [4, 2]},
			],
			legend: {position: 'top', alignment: 'center', maxLines: 2},
			curveType:'function',
            lineWidth: 1,
			backgroundColor: '#E2E2E0',
        };
  
        var chart_lines = new google.visualization.LineChart(document.getElementById('chart'));
        chart_lines.draw(dataTable, options_lines);
	
	};
	
	
    $(document).ready(function () {	
		google.charts.load('current', {'packages':['corechart'], 'language': 'en'});
		loadGrid();
		loadGraphData();
    });
	
</script>
</body>
</html>