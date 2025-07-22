<!--#include virtual="/step.asp"-->
<!--#include virtual="/checklogin.asp"-->
<!--#include virtual="/checkworkflow.asp"-->

<%saveCurrentURL%>

<html>

<head> 
<meta charset="utf-8">
<title>TIAMAT</title>

<link rel="stylesheet" href="/css/jsplumb.css">
<link rel="shortcut icon" href="/css/favicon.png">
<link rel="stylesheet" href="/css/main.css">
<link rel="stylesheet" href="/css/mobileFIX.css">
<link rel="stylesheet" href="/css/text.css">



<style type="text/css">

<%

if Request.querystring("workflowID") <> "" then
	Dim rs0

	Call getRecordSet(SQL_CONSULTA_WORKFLOW_STEP_POSITION(Request.querystring("workflowID")), rs0)
	Dim maximumPosY
	maximumPosY=100
	while not rs0.eof
		if not isnull(rs0("posX")) and not isnull(rs0("posY")) then
			if rs0("posY")> maximumPosY then
			maximumPosY = rs0("posY")
			end if
%>		

  #step<%=cstr(rs0("stepID"))%> { 
	left:<%=cstr(rs0("posX"))%>px; 
	top:<%=cstr(rs0("posY"))%>px;
  }

		<%
		end if
		rs0.movenext
	Wend
end if
%>
</style>

<script src="/js/external/json2.min.js"></script> 
<script src="/js/jquery.js"></script> 
<script src="/js/tiamat.js"></script> 



<script> 
 $(function(){
   $("#title").load("includes/title.asp"); 
   $("#footer").load("includes/footer.html"); 
   $("#copyright").load("includes/copyright.asp"); 
 });
</script> 

</head> 

<body>
<script>
  $(document.body).addClass('not-ready');
  $(window).load(function(){
  setTimeout("$(document.body).removeClass('not-ready')",250);
  });
</script>
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
							
										<%
										Call getRecordSet(SQL_CONSULTA_WORKFLOW_ID(Request.querystring("workflowID")), rsWf)
										%>
										
											<tr>
												<td height=60px>
														<p class="font_6" align="justify">FTA WORKFLOW <font color="red">//</font></p>							
												</td>
											</tr>
											<tr>
												<td>
												<hr class="linhaDupla">
												</td>
											</tr>											
											<tr>
												<td height=80px>
													<%if not rsWf.eof then %>
														<br><p class="font_9"><b>Description</b>:<%=rsWf("description")%></p>
														<br><p class="font_9"><b>Goal</b>:<%=rsWf("goal")%></p>
														<br><p class="font_9"><b>Expected Results</b>:<%=rsWf("expectedresult")%></p>
													<%end if%>
												</td>
											</tr>
											<tr>
												<td>
												<hr class="linhaDupla">
												</td>
											</tr>
											<tr>
												<td>
												
												<div id="main">
												
													<div class="demo chart-demo" id="workflow" style="height:<%=(maximumPosY +350)%>px"> 
														
															<%
															if Request.querystring("workflowID") <> "" then
																Dim rs
																Call getRecordSet(SQL_CONSULTA_WORKFLOW_PRIMARY_STEPS(Request.querystring("workflowID")), rs)
																
																call printSteps(rs)
															end if
															%>
													</div>
												
												
        
												</div>
												</td>

										<%if not rsWf.eof then
											if rsWf("status") = STATE_UNLOCKED or not isnull(rsWf("parentStepID")) then 
										%>

										</tr>
											<tr>
												<td>
												<hr class="linhaDupla">
												</td>
											</tr>
											<tr>
												<td align=center height=60px>
												<%
													if rsWf("status") = STATE_UNLOCKED then 
												%>
													<button class="TIAMATButton" style="width:120px;" onclick="window.location.href='workflow.asp?workflowID=<%=Request.querystring("workflowID")%>';">Edit</button>
													<button class="TIAMATButton" style="width:150px;" onclick="window.location.href='addstep.asp?workflowID=<%=Request.querystring("workflowID")%>';">Add Step</button>
													
													<%if isnull(rsWf("parentStepID")) and getWorkflowRealSteps(Request.querystring("workflowID"))>0 then%>
														<button class="TIAMATButton" style="width:180px;" onclick="if(confirm('Are you sure?'))window.location.href='workflowActions.asp?action=lock&workflowID=<%=Request.querystring("workflowID")%>';">Lock and Start FTA</button>

												<%
														end if
													end if
													if not isnull(rsWf("parentStepID")) then
													
														call getRecordSet(SQL_CONSULTA_WORKFLOW_STEP_ID(cstr(rsWf("parentStepID"))), rsWfSon)

														if NOT rsWfSon.eof then
													%>													
													<button class="TIAMATButton" style="width:200px;" onclick="window.location.href='?workflowID=<%=rsWfSon("workflowID")%>';">Go to Parent Workflow</button>
													<%
														end if
													end if
													%>
	<!--											<button class="TIAMATButton" style="width:150px;" onclick="window.location.href='workflowActions.asp?action=balance&workflowID=<%=Request.querystring("workflowID")%>';"> Auto Organize</button>
											--></td>
												
														<%	end if
														end if
														%>

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
<script src="/js/dom.jsPlumb-1.7.3-min.js"></script>
<script>

jsPlumb.ready(function () {

    var color = "gray";

    var instance = jsPlumb.getInstance({
        // notice the 'curviness' argument to this Bezier curve.  the curves on this page are far smoother
        // than the curves on the first demo, which use the default curviness value.
        Connector: [ "Bezier", { curviness: 50 } ],
        DragOptions: { cursor: "pointer", zIndex: 2000 },
        PaintStyle: { strokeStyle: color, lineWidth: 2 },
        EndpointStyle: { radius: 9, fillStyle: color },
        HoverPaintStyle: {strokeStyle: "#ec9f2e" },
        EndpointHoverStyle: {fillStyle: "#ec9f2e" },
        Container: "workflow"
    });

    // suspend drawing and initialise.
    instance.batch(function () {
        // declare some common values:
        var arrowCommon = { foldback: 0.7, fillStyle: color, width: 14 },
        // use three-arg spec to create two different arrows with the common values:
            overlays = [
                [ "Arrow", { location: 0.7 }, arrowCommon ],
                [ "Arrow", { location: 0.3 }, arrowCommon ]
            ];

        // add endpoints, giving them a UUID.
        // you DO NOT NEED to use this method. You can use your library's selector method.
        // the jsPlumb demos use it so that the code can be shared between all three libraries.
        var windows = jsPlumb.getSelector(".chart-demo .window");
        for (var i = 0; i < windows.length; i++) {
            instance.addEndpoint(windows[i], {
                uuid: windows[i].getAttribute("id") + "-bottom",
                anchor: "Bottom",
                maxConnections: -1
            });
            instance.addEndpoint(windows[i], {
                uuid: windows[i].getAttribute("id") + "-top",
                anchor: "Top",
                maxConnections: -1
            });
        }

        
		<%
		
		
		if Request.querystring("workflowID") <> "" then
					Dim rs3
					Call getRecordSet(SQL_CONSULTA_WORKFLOW_STEPS(Request.querystring("workflowID")), rs3)
					
					while not rs3.eof
						if rs3("parentStepID") <> "" then
						%>
						
						instance.connect({uuids: ["step<%=cstr(rs3("parentStepID"))%>-bottom", "step<%=cstr(rs3("stepID"))%>-top" ], overlays: overlays, detachable: false, reattach: false});
						
						<%
						end if
						rs3.movenext
					Wend
		end if
		%>
		
   
        instance.draggable(windows);

    });

    jsPlumb.fire("jsPlumbDemoLoaded", instance);
});

setInterval(saveFlowchart, 1000);

</script>
</body>
</html>