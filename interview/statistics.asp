<!--#include virtual="/system.asp"-->
<!--#include virtual="/checkstep.asp"-->
<!--#include file="INC_INTERVIEW.inc"-->

<%
saveCurrentURL

Dim rs
Dim stepID
Dim state
Dim role

If request.querystring("stepID") <> "" Then
	stepID = request.querystring("stepID")
	
	role = getRole(stepID, Session("email"))

	If role <> "Interviewer" Then
		Session("interviewError") = "You are not an interview coordinator."
		response.redirect "index.asp?stepID=" & stepID & "&redirect=1"
	End If
	
	Call getRecordSet (SQL_CONSULTA_INTERVIEW(stepID), rs)
	
	state = Clng(rs("state"))
	
	If state = STATE_UNP Then
		Session("interviewError") = "This interview has not been published yet. It is not possible to view its statistics."
		response.redirect "index.asp?stepID=" & stepID
	End If
End If

tiamat.addCSS("interview.css")
tiamat.addCSS("/js/GoogleCharts/chart_pie.css")
tiamat.addCSS("/js/GoogleCharts/chart_bar.css")

tiamat.addJS("/js/google_jsapi.js")
tiamat.addJS("/js/GoogleCharts/chart_bar.js")
tiamat.addJS("/js/GoogleCharts/chart_pie.js")

render.renderTitle()
%>

							<table class="principal" width=100%>
								<tr>
									<td width=20px>
										&nbsp;
									</td>
									<td align=center>
										<table width="1184px" class="padded">

											<!-- INICIO AREA EDITAVEL -->
							

											<tr>
												<td>
													<p class="font_6" align="justify">INTERVIEW STATISTICS<font color="red">//</font></p>							
												</td>
											</tr>
											<tr>
												<td>
												<hr class="linhaDupla">
												</td>
											</tr>
											<tr>
												<td>
													<%
														If stepID <> "" Then
															response.write("<div id=""interview-statistics"">")
															Call printAllStatistics(stepID)
															response.write("</div>")
														End If
													%>
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
													<button class="TIAMATButton" onclick="window.location.href='index.asp?stepID=<%=stepID%>';return false;">Back</button>
												</td>

										<!-- FIM AREA EDITAVEL -->

											</tr>
											<tr>
												<td height="60px" valign="middle" align="center" colspan="2" class="padded" >
													<font class="error-msg" color=red><%=Session("interviewStatisticsError")%></font>
													<%
													Session("interviewStatisticsError") = ""
													%>
												</td>
											</tr>
										</table>
									</td>
									<td width=20px>
									&nbsp;&nbsp;&nbsp;
									</td>
								</tr>
							</table>

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
					sliceVisibilityThreshold: 0,
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
					sliceVisibilityThreshold: 0,
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
render.renderFooter()
%>