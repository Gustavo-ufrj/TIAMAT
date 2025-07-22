<!--#include virtual="/system.asp"-->
<!--#include virtual="/checkstep.asp"-->
<!--#include file="INC_SA.inc"-->

<%

saveCurrentURL

							
Dim stepID
							
call getRecordSet (SQL_CONSULTA_SA(request.querystring("stepID")), rs)

if rs.eof then																							
 response.redirect "editSA.asp?stepID="+request.querystring("stepID")
end if												

If request.querystring("stepID") <> "" Then
	stepID = request.querystring("stepID")
end if

tiamat.addCSS("/css/jsplumb.css")


tiamat.addCSS("sa.css")


tiamat.addCSS("/js/TIAMATPopup/TIAMATPopup.css")
tiamat.addCSS("/js/contextMenu/jquery.contextMenu.css")



tiamat.addJS("/js/contextMenu/jquery.ui.position.js")
tiamat.addJS("/js/contextMenu/jquery.contextMenu.js")
tiamat.addJS("/js/TIAMATPopup/TIAMATPopup.js")

'<link href="/css/jtable_jqueryui.css" rel="stylesheet" type="text/css" />
'<link href="/css/metro/jquery-ui.css" rel="stylesheet" type="text/css" />
'<link href="/js/themes/metro/darkgray/jtable.min.css" rel="stylesheet" type="text/css" />


'<script src="/js/jquery.js"></script> 
'<script src="/js/jquery-ui-1.10.0.min.js"></script> 
'<script src="/js/jquery.inputmask.js"></script> 


render.renderTitle()
%>

							<table class="principal" width=100%>
								<tr>
									<td width=20px>
										&nbsp;
									</td>
									<td align=center>
										<table width=1184 class="padded" >
											<tr>
												<td>
													<table width=100% >
														<tr>
															<td>
																<p class="font_6" align="justify">STAKEHOLDER ANALYSIS <font color="red">//</font></p>							
															</td>
															<td align=right>
																<%if getStatusStep(request.querystring("stepID")) = STATE_ACTIVE then %>
																<button class="TIAMATButton" style="width:200px;" onclick="window.location.href='/stepsupportInformation.asp?stepID=<%=request.queryString("stepID")%>';">Supporting Information</button>
																<button class="TIAMATButton" onclick="if(confirm('This action cannot be undone. Are you sure to end this FTA method now?'))window.location.href='/workflowActions.asp?action=end&stepID=<%=request.queryString("stepID")%>'">Finish</button>															
																<%end if%>
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
											<!-- INICIO AREA EDITAVEL -->
											<tr>
												<td>
													<div id="main">
														<div class="demo chart-demo" id="stakeholder-analysis" style="height:350px">
															<%
															If stepID <> "" Then
																Call printAllSAStakelholdersInterests(stepID, False)
															End If
															%>
														</div>
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
													<button class="TIAMATButton" style="width:150px;" onclick="window.location.href='editSA.asp?stepID=<%=request.queryString("stepID")%>'">Manage Analysis</button>
													<button class="TIAMATButton" style="width:180px;" onclick="window.location.href='manageStakeholders.asp?stepID=<%=request.queryString("stepID")%>&SAID=<%=cstr(rs("SAID"))%>'">Manage Stakeholders</button>
													<button class="TIAMATButton" style="width:150px;" onclick="window.location.href='manageInterest.asp?stepID=<%=request.queryString("stepID")%>&SAID=<%=cstr(rs("SAID"))%>'">Manage Interest</button>
													<button class="TIAMATButton" style="width:250px;" onclick="window.location.href='manageStakeholderInterests.asp?stepID=<%=request.queryString("stepID")%>&SAID=<%=cstr(rs("SAID"))%>'">Manage Stakeholder Interests</button>
													<button class="TIAMATButton" style="width:190px;" onclick="window.location.href='manageStakeholderStakeholder.asp?stepID=<%=request.queryString("stepID")%>&SAID=<%=cstr(rs("SAID"))%>'">Associate Stakeholders</button>
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

<script src="/js/dom.jsPlumb-1.7.3-min.js"></script>
<script>
$(document).ready(function() {
	jsPlumb.ready(function () {
		var color = "gray";
		
		window.saInstance = null;
		window.saStakeholders = null;
		window.saInterests = null;
		window.saStakeholderInterests = null;
		window.saStakeholderStakeholders = null;
		
		window.saInstance = jsPlumb.getInstance({
			Connector: "StateMachine",
			PaintStyle: { lineWidth: 2, strokeStyle: color },
			Endpoint: [ "Dot", { radius: 5 } ],
			EndpointStyle: { fillStyle: color },
			Container: "stakeholder-analysis"
		});
		
		window.saStakeholders = jsPlumb.getSelector(".chart-demo .stakeholder");
		window.saInterests = jsPlumb.getSelector(".chart-demo .interest");
		window.saStakeholderInterests = jsPlumb.getSelector(".chart-demo .stakeholderInterest");
		window.saStakeholderStakeholders = jsPlumb.getSelector(".chart-demo .stakeholderStakeholder");

		window.saInstance.draggable(window.saStakeholders);
		window.saInstance.draggable(window.saInterests);
		
		
	// arrows for connections
		var arrowCommon = { foldback: 0.7, fillStyle: color, width: 14 };
		var overlays = [[ "Arrow", { location: 1.0 }, arrowCommon ]];
		var elem = null;
		var elemChildren = [];
		
		for (i = 0; i < window.saStakeholderInterests.length; i++) {
			elem = $(window.saStakeholderInterests[i]);
			elemChildren = elem.children();
			
			for(j = 0; j < window.saStakeholders.length; j++){
				for(k = 0; k < window.saInterests.length; k++){
					if(window.saStakeholders[j].children[0].value == elemChildren[2].value && window.saInterests[k].children[0].value  == elemChildren[3].value){
						window.saInstance.connect({
							source: window.saStakeholders[j],
							target: window.saInterests[k],
							anchors: [
								[ "Perimeter", { shape: "Circle"}],
								[ "Perimeter", { shape: "Circle"}]
							],
							overlays: overlays
						});
					}
				}
			}	
		}
		
		for (i = 0; i < window.saStakeholderStakeholders.length; i++) {
			elem = $(window.saStakeholderStakeholders[i]);
			elemChildren = elem.children();
			
			for(j = 0; j < window.saStakeholders.length; j++){
				for(k = 0; k < window.saStakeholders.length; k++){
					if(window.saStakeholders[j].children[0].value == elemChildren[2].value && window.saStakeholders[k].children[0].value  == elemChildren[3].value){
						window.saInstance.connect({
							source: window.saStakeholders[j],
							target: window.saStakeholders[k],
							anchors: [
								[ "Perimeter", { shape: "Triangle"}],
								[ "Perimeter", { shape: "Triangle"}]
							],
							overlays:[
								[ "Label", {label:elemChildren[4].value, id:"label"}]
							]
						});
					}
				}
			}	
		}		
	});
});


function saveStakeholderFlowchart(){
            var nodes = []
			
            $(".stakeholder").each(function (idx, elem) {
            var $elem = $(elem);
            var endpoints = jsPlumb.getEndpoints($elem.attr('id'));
				nodes.push({
                    stakeholderID: $elem.attr('id'),
                    positionX: parseInt($elem.css("left"), 10),
                    positionY: parseInt($elem.css("top"), 10)
                });
	        });            
			
			var graph = {};
            graph.nodes = nodes;
			

			$.ajax({
				url: '/FTA/sa/positionsActions.asp?action=saveStakeholder',
				type: 'post',
				dataType: 'json',
				success: function (data) {
					alert("e");
				},
				data: JSON.stringify(graph)
			});
}

function saveInterestFlowchart(){
            var nodes = []
			
            $(".interest").each(function (idx, elem) {
            var $elem = $(elem);
            var endpoints = jsPlumb.getEndpoints($elem.attr('id'));
				nodes.push({
                    interestID: $elem.attr('id'),
                    positionX: parseInt($elem.css("left"), 10),
                    positionY: parseInt($elem.css("top"), 10)
                });
	        });            
			
			var graph = {};
            graph.nodes = nodes;
			

			$.ajax({
				url: '/FTA/sa/positionsActions.asp?action=saveInterest',
				type: 'post',
				dataType: 'json',
				success: function (data) {
					alert("e");
				},
				data: JSON.stringify(graph)
			});
}

setInterval(saveStakeholderFlowchart, 1000);
setInterval(saveInterestFlowchart, 1000);
</script>

<%
render.renderFooter()
%>