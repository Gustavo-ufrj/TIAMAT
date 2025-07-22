<!--#include virtual="/system.asp"-->
<!--#include virtual="/checkstep.asp"-->
<!--#include file="INC_DELPHI.inc"-->

<%


saveCurrentURL

Dim rs
Dim stepID
Dim roundID
Dim state
Dim role

If request.querystring("questionID") <> "" And request.querystring("roundID") <> "" Then
	roundID = request.querystring("roundID")
	questionID = request.querystring("questionID")
	
'	role = getRole(stepID, Session("email"))

End If

tiamat.addCSS("delphi.css")
tiamat.addCSS("/js/GoogleCharts/chart_bar.css")
tiamat.addCSS("/js/GoogleCharts/chart_pie.css")

tiamat.addJS("/js/google_jsapi.js")
tiamat.addJS("/js/GoogleCharts/chart_bar.js")
tiamat.addJS("/js/GoogleCharts/chart_pie.js")

render.renderToBody()
%>
	

<div class="p-3">


													<%
														If roundID <> "" Then
															response.write("<div id=""delphi-statistics"">")
															Call printAllAnswers(roundID, questionID)
															response.write("</div>")
														End If
													%>
</div>									

<script type="text/javascript">
function drawQuestionBarCharts() {
	var i = 0;
	var j = 0;
	var chartDataContainers = $('.question-chart-data-container');
	var chartDataContainer = null;
	var chartData = null;
	var chartDataElem = null;
	var optionID = '';
	var optionText = '';
	var numAnswers = '';
	var dataForChart = [];
	var chartContainer = null;
	var chartOptions = [];
	var data = null;
	var chart = null;
	var drawChart = false;
	
	for (i = 0; i < chartDataContainers.length; i++) {
		chartDataContainer = $(chartDataContainers[i]);
		chartData = chartDataContainer.find('.question-chart-data');
		
		drawChart = false;
		dataForChart = [[], []];
		
		if (chartData.length > 0) {
			dataForChart[0].push('');
			dataForChart[1].push('Options');
			
			for (j = 0; j < chartData.length; j++) {
				chartDataElem = $(chartData[j]);
				numAnswers = chartDataElem.find('.question-option-numanswers').first()[0].value;
				
				if (parseInt(numAnswers) > 0) {
					drawChart = true;
				}
			}
			
			if (drawChart) {
				for (j = 0; j < chartData.length; j++) {
					chartDataElem = $(chartData[j]);
					//optionID = chartDataElem.find('.question-option-id').first()[0].value;
					optionText = chartDataElem.find('.question-option-text').first()[0].value;
					numAnswers = chartDataElem.find('.question-option-numanswers').first()[0].value;
					
					dataForChart[0].push(optionText);
					dataForChart[1].push(parseInt(numAnswers));
				}
				
				chartOptions = {
					bars: 'vertical', 
					height: 300,
					width: 500,
					chartArea: {
						left: 30,
						top: 100,
						width: '80%',
						height: '75%'
					},
					//bar: { groupWidth: 50 }, 
					vAxis: {
						title: 'Number of Answers'
					}
				};
				
				data = google.visualization.arrayToDataTable(dataForChart);
				
				chart = new google.charts.Bar(chartDataContainer.parent().find('.question-chart-container').first()[0]);
				chart.draw(data, chartOptions);
			}
		}
	}
}

function drawQuestionPieCharts() {
	var i = 0;
	var j = 0;
	var chartDataContainers = $('.question-chart-data-container');
	var chartDataContainer = null;
	var chartData = null;
	var chartDataElem = null;
	var optionID = '';
	var optionText = '';
	var numAnswers = '';
	var dataForChart = [];
	var chartContainer = null;
	var chartOptions = [];
	var data = null;
	var chart = null;
	var drawChart = false;
	
	for (i = 0; i < chartDataContainers.length; i++) {
		chartDataContainer = $(chartDataContainers[i]);
		chartData = chartDataContainer.find('.question-chart-data');
		
		drawChart = false;
		dataForChart = [['Option', 'Number of Answers']];
		
		if (chartData.length > 0) {
			
			for (j = 0; j < chartData.length; j++) {
				chartDataElem = $(chartData[j]);
				numAnswers = chartDataElem.find('.question-option-numanswers').first()[0].value;
				
				if (parseInt(numAnswers) > 0) {
					drawChart = true;
				}
			}
			
			if (drawChart) {
				for (j = 0; j < chartData.length; j++) {
					chartDataElem = $(chartData[j]);
					//optionID = chartDataElem.find('.question-option-id').first()[0].value;
					optionText = chartDataElem.find('.question-option-text').first()[0].value;
					numAnswers = chartDataElem.find('.question-option-numanswers').first()[0].value;
					
					dataForChart.push([optionText, parseInt(numAnswers)]);
				}
				
				chartOptions = {
					height: 300,
					width: 500,
					is3D: true,
					chartArea: {
						left: 0,
						top: 0,
						width: '100%',
						height: '100%'
					}
				};
				
				data = google.visualization.arrayToDataTable(dataForChart);
				
				chart = new google.visualization.PieChart(chartDataContainer.parent().find('.question-chart-container').first()[0]);
				chart.draw(data, chartOptions);
			}
		}
	}
}

$(document).ready(function() {
	$('.question-header .toggle-question').click(function() {
		var elem = $(this);
		
		elem.parent().parent().find('.question-content').toggle();
		
		if (elem.html() === '[-]') {
			elem.html('[+]');
		} else if (elem.html() === '[+]') {
			elem.html('[-]');
		}
	});
	
	//google.load("visualization", "1.1", {packages:["bar"]});
	//google.load("visualization", "1", {packages:["corechart"]});
	//google.setOnLoadCallback(drawChart);
	
	//drawQuestionBarCharts();
	drawQuestionPieCharts();
});
</script>

<%
render.renderFromBody()
%>