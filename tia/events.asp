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
<script src="/js/tiamat.js"></script> 
<script src="/js/jsgrid.js"></script>
<script src="/js/jsgrid.min.js"></script>
<script src="/js/i18n/jsgrid-pt-br.js"></script>

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
													<p class="font_6" align="justify">TIA: EVENTS AND IMPACTS <font color="red">//</font></p>							
												</td>
											</tr>
											<tr>
												<td>
												<hr class="linhaDupla">
												</td>
											</tr>
											<tr>
												<td>
												
													<div id="grid" class="padded alignCenter">
													</div>
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
												<a class="TIAMATButton" href="details.asp?stepID=<%=stepID%>"><< Info</a>
												<a class="TIAMATButton" href="actions.asp?action=execute&stepID=<%=stepID%>">Results >></a>
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

	function loadGrid() {
		 
		var grid = $("#grid");
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
		
		grid.jsGrid({
			height: "auto",
			width: "100%",
			inserting: true,
			editing: true,
			paging: true,
			pageSize: 5,
			autoload: true,
			sorting: true,
			noDataContent: "No events registered",
			
			onDataLoaded: function(args) {
				this.sort({field: "title", order: "asc"});
			},
			
			onItemInserted: function(args) {
				this.sort({field: "title", order: "asc"});
			},
			
			onItemUpdating: function(args) {
				previousItem = args.previousItem;
			},
			
			onItemUpdated: function(args) {
				this.sort({field: "title", order: "asc"});
			},
			
			onItemDeleted: function(args) {
				this.sort({field: "title", order: "asc"});
			},

			controller: {
				
				loadData: function(filter) {
					return $.ajax({
						type: "GET",
						url: "actions.asp?action=listEvents&stepID=<%=stepID%>",
						data: filter
					});
				},
				
				insertItem: function(item) {
					return $.ajax({
						type: "GET",
						url: "actions.asp?action=insertEvent&stepID=<%=stepID%>",
						data: item
					});
				},
				
				updateItem: function(item) { 
					var d = $.Deferred();
					$.ajax({
						type: "GET",
						url: "actions.asp?action=updateEvent",
						data: item
					}).done(function(response) {
						d.resolve(response);
					}).fail(function() {
						d.resolve(previousItem);
					});
					return d.promise();
				},
				
				deleteItem: function(item) {
					return $.ajax({
						type: "GET",
						url: "actions.asp?action=deleteEvent",
						data: item
					});
				},
			},
				 
			fields: [
				{ name: "eventid", visible: false },
				{ name: "title", 		title: "Event title", 					type: "text", 		width: "22%" },
				{ name: "description", 	title: "Event description", 			type: "textarea", 	width: "35%" },
				{ name: "probability", 	title: "Probability of occ. (%)",	 	type: "number",		width: "9%" },
				{ name: "max_impact", 	title: "Max. impact (%)", 				type: "number",		width: "7%" },
				{ name: "max_time", 	title: "Time to Max. impact", 			type: "number",		width: "7%" },
				{ name: "ss_impact", 	title: "Steady-state impact (%)", 		type: "number",		width: "7%" },
				{ name: "ss_time", 		title: "Time to Steady-state impact", 	type: "number",		width: "7%" },
				{
					type: "control",
					modeSwitchButton: true,
					editButton: true,
					deleteButton: true,
					width: "6%" 
				},
			]
		});	
	};


  $(document).ready(function () {
	loadGrid();
    });
</script>
</body>
</html>