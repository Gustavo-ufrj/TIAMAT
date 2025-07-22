<!--#include virtual="/step.asp"-->
<!--#include virtual="/checklogin.asp"-->
<!--#include virtual="/checkworkflow.asp"-->

<%
saveCurrentURL
tiamat.addCSS("/css/jsplumb.css")
tiamat.addCSS("/css/workflow.asp?workflowID="+Request.querystring("workflowID"))
tiamat.addJS("/js/dom.jsPlumb-1.7.3-min.js")

render.renderTitle()
%>

							<table class="principal" width=100%>
								<tr>
									<td width=20px>
										&nbsp;
									</td>
									<td align=center>
										<table width=1184px class="padded">

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
												
													<div class="tiamat_dynamic_workflow_height demo chart-demo " id="workflow"> 
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


<script>
var askDeatach = true;
jsPlumb.ready(function () {

    var color = "gray";

    var instance = jsPlumb.getInstance({
        // notice the 'curviness' argument to this Bezier curve.  the curves on this page are far smoother
        // than the curves on the first demo, which use the default curviness value.
        Connector: [ "Bezier", { curviness: 50 } ],
        DragOptions: { cursor: "pointer", zIndex: 2000, grid:[20,20] },
        PaintStyle: { strokeStyle: color, lineWidth: 2 },
        EndpointStyle: { radius: 9, fillStyle: color },
        HoverPaintStyle: {strokeStyle: "#ec9f2e" },
        EndpointHoverStyle: {fillStyle: "#ec9f2e" },
        Container: "workflow"
    });

	

    // suspend drawing and initialise.
    instance.batch(function () {
        // declare some common values:
        var arrowCommon = { foldback: 0.8, fillStyle: color, width: 15 },
        // use three-arg spec to create two different arrows with the common values:
            overlays = [
                [ "Arrow", { location: 0.75 }, arrowCommon ],
                [ "Arrow", { location: 0.5 }, arrowCommon ],
                [ "Arrow", { location: 0.25 }, arrowCommon ]
            ];

        // add endpoints, giving them a UUID.
        // you DO NOT NEED to use this method. You can use your library's selector method.
        // the jsPlumb demos use it so that the code can be shared between all three libraries.
        var windows = jsPlumb.getSelector(".chart-demo .window");
        for (var i = 0; i < windows.length; i++) {
            instance.addEndpoint(windows[i], {
                uuid: windows[i].getAttribute("id") + "-bottom",
                anchor: "Bottom",
                maxConnections: -1, 
				isSource:true,
				beforeDetach:function(params) { 
						if (askDeatach) {
							if (confirm("Detach connection?")){
							
							
							$.ajax({
							  url: "stepActions.asp?action=removeParent&workflowID=<%=Request.querystring("workflowID")%>&stepID="+params.targetId.replace("step","")+"&parentStepID="+params.sourceId.replace("step",""),
							  context: document.body
							})
							.done(function(html) {
							if ( html==="true") {
									askDeatach = false;
									var conn = instance.getConnections({
									  //only one of source and target is needed, better if both setted
									  source: params.sourceId,
									  target: params.targetId
												});
									if (conn[0]) {
									  instance.detach(conn[0]);
									}
									askDeatach = true;
								};
							});

								//window.location.href="stepActions.asp?action=removeParent&workflowID=<%=Request.querystring("workflowID")%>&stepID="+params.targetId.replace("step","")+"&parentStepID="+params.sourceId.replace("step","");
							} 
						}
					}
            });
            instance.addEndpoint(windows[i], {
                uuid: windows[i].getAttribute("id") + "-top",
                anchor: "Top",
                maxConnections: -1, 
				isTarget:true,
				beforeDrop:function(params) { 
					if (params.targetId!=params.sourceId) {
						if (confirm("Connect the steps?")){
							var currConnection = instance.connect({uuids: [params.sourceId+"-bottom", params.targetId+"-top" ], overlays: overlays, detachable: true, reattach: false});
							currConnection.bind("dblclick",function(){
								instance.detach(this);
							});
							$.ajax({
							  url: "stepActions.asp?action=addParent&workflowID=<%=Request.querystring("workflowID")%>&stepID="+params.targetId.replace("step","")+"&parentStepID="+params.sourceId.replace("step",""),
							  context: document.body
							})
							.done(function(html) {
							if ( html!="true") {
									askDeatach = false;
									var conn = instance.getConnections({
									  //only one of source and target is needed, better if both setted
									  source: params.sourceId,
									  target: params.targetId
												});
									if (conn[0]) {
									  instance.detach(conn[0]);
									}
									askDeatach = true;
								};
							})
							.fail(function() {
							  alert( "Could not save the new connection." );
							});
						} 
					}
				}
            });
        }

        
		<%
		
		
		if Request.querystring("workflowID") <> "" then
					Dim rs3
					Call getRecordSet(SQL_CONSULTA_WORKFLOW_STEPS_X_STEPS(Request.querystring("workflowID")), rs3)
					
					while not rs3.eof
						if rs3("parentStepID") <> "" then
						%>
						
						var currConnection =  instance.connect({uuids: ["step<%=cstr(rs3("parentStepID"))%>-bottom", "step<%=cstr(rs3("stepID"))%>-top" ], overlays: overlays, detachable: true, reattach: false});
							currConnection.bind("dblclick",function(){
								instance.detach(this);
							});

						
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

<%
render.renderFooter()
%>
