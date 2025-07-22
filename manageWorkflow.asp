<!--#include virtual="/step.asp"-->
<!--#include virtual="/checklogin.asp"-->
<!--#include virtual="/checkworkflow.asp"-->

<%
saveCurrentURL
tiamat.addCSS("/css/jsplumb.css")
tiamat.addCSS("/css/main.css")
tiamat.addCSS("/css/workflow.asp?workflowID="+Request.querystring("workflowID"))
tiamat.addJS("/js/dom.jsPlumb-1.7.3-min.js")

render.renderTitle()
%>



<div class="container-fluid d-flex flex-grow-1 flex-column p-3">
 <div class="row d-flex">
        <div class="col d-flex">
	
	<%
	Call getRecordSet(SQL_CONSULTA_WORKFLOW_ID(Request.querystring("workflowID")), rsWf)
	%>
	<%if not rsWf.eof then %>
	<div class="col-lg-12 col-md-12 col-sm-12 align-self-center">
		<h1 class="fs-3 fw-bolder text-dark text-uppercase"><%=rsWf("description")%></h1>
		<p class="fs-5"><%=rsWf("goal")%></p>
		<hr>
	</div>
	<%end if%>
	
   </div>
    </div>
    <div class="row d-flex flex-grow-1 justify-content-start">	
	
	<div id="main" class="d-flex flex-column">
		<div class="flex-grow-1 demo chart-demo " id="workflow"> 
				<%
				' tiamat_dynamic_workflow_height
				if Request.querystring("workflowID") <> "" then
					Dim rs
					Call getRecordSet(SQL_CONSULTA_WORKFLOW_PRIMARY_STEPS(Request.querystring("workflowID")), rs)
					
					call printSteps(rs)
				end if
				%>
		</div>
	</div>
	
  </div>	
	
  
  <nav class="navbar fixed-bottom navbar-light bg-light">
	 <div class="container-fluid justify-content-center p-0">
<%
if rsWf("status") = STATE_UNLOCKED then 
%>

<%
if not isnull(rsWf("parentStepID")) then
	call getRecordSet(SQL_CONSULTA_WORKFLOW_STEP_ID(cstr(rsWf("parentStepID"))), rsWfSon)
	if NOT rsWfSon.eof then
%>													
	<button class="btn btn-sm btn-secondary m-1" type="button" onclick="window.location.href='?workflowID=<%=rsWfSon("workflowID")%>';"><i class="bi bi-arrow-up-square text-light"></i> Open Parent Workflow</button>
	<%
	end if
end if
%>

	<button class="btn btn-sm btn-secondary m-1" type="button" data-bs-toggle="modal" data-bs-target="#manageFTA" data-workflow-id="<%=cstr(rsWf("workflowID"))%>" data-title="<%=cstr(rsWf("description"))%>" data-description="<%=cstr(rsWf("goal"))%>"  data-url="workflowActions.asp?action=update" data-form-title="Edit FTA">Edit Title/Description</button>
	
	<button class="btn btn-sm btn-secondary m-1" type="button" data-bs-toggle="modal" data-bs-target="#stepModal" data-url="addstep.asp?workflowID=<%=cstr(rsWf("workflowID"))%>" data-title="Add Step"><i class="bi bi-plus-square text-light"></i> Add Step</button>
	
	
<%
	if isnull(rsWf("parentStepID")) and getWorkflowRealSteps(Request.querystring("workflowID"))>0 then
%>
		<button class="btn btn-sm btn-danger m-1" type="button" onclick="if(confirm('Are you sure?'))window.location.href='workflowActions.asp?action=lock&workflowID=<%=Request.querystring("workflowID")%>';"><i class="bi bi-forward text-light"></i> Start the FTA</button>

<%
	end if
end if
%>
	 
 
		
	 </div>
  </nav>
  
  
  
   

	   <!-- ADD FTA Modal -->
	<div class="modal fade" id="manageFTA" tabindex="-1" aria-labelledby="uploadModalLabel" aria-hidden="true">
	  <div class="modal-dialog modal-dialog-centered">
		<div class="modal-content">
		<form method="post" id="formManageFTA" action="" class="requires-validation m-0" novalidate>
		  <div class="modal-header">
			<h5 class="modal-title" id="ftaModalLabel">New FTA</h5>
			<button type="button" class="btn-close" data-bs-dismiss="modal" aria-label="Close"></button>
		  </div>
		  <div class="modal-body">

		   <div class="mb-3">
			<label for="title" class="form-label">Title</label>
			<input type="text" class="form-control w-100" id="title" name="title" required> 
			<div class="invalid-feedback">Title cannot be blank!</div>
		  </div>
		  
		  <div class=" mb-3">
			<label for="description" class="form-label">Description</label>
 		    <textarea class="form-control" id="description" name="description" rows="3"></textarea>
		  </div>
		  
		  
		  </div>
		  <div class="modal-footer">
			<input type="hidden" name="workflowID">
			<input type="hidden" name="redirectTo" value="workflow">
			<button type="button" class="btn btn-sm btn-secondary m-1 text-center" data-bs-dismiss="modal">Close</button>
			<button type="submit" class="btn btn-sm btn-danger m-1 text-center" ><i class="bi bi-save text-light"></i> Save</button>
		  </div> 
		</form>
		</div>
	  </div>
	</div>		
   </div>	
   
	
	
	
	
<!-- Add Step Modal -->
<div class="modal fade" id="stepModal" tabindex="-1" aria-labelledby="stepModalLabel" aria-hidden="true">
  <div class="modal-dialog modal-dialog-centered">
    <div class="modal-content">
      <div class="modal-header">
        <h5 class="modal-title" id="stepModalLabel"></h5>
        <button type="button" class="btn-close" data-bs-dismiss="modal" aria-label="Close"></button>
      </div>
      <div class="modal-body">
	    <iframe id="iframeStep" src="" class="w-100" style="height:200px">
	 	</iframe>
      </div>
     </div>
  </div>
</div>		


<!-- Add/Edit Users Modal -->
<div class="modal fade" id="participantsModal" tabindex="-1" aria-labelledby="participantsModalLabel" aria-hidden="true">
  <div class="modal-dialog modal-dialog-centered modal-xl">
    <div class="modal-content">
      <div class="modal-header">
        <h5 class="modal-title" id="participantsModalLabel"></h5>
        <button type="button" class="btn-close" data-bs-dismiss="modal" aria-label="Close"></button>
      </div>
      <div class="modal-body p-0">
        <iframe id="iframeParticipants" src="" class="w-100" style="height:500px">
		</iframe>
      </div>
     </div>
  </div>
</div>		
	  
	  


<!-- Link Modal -->
<div class="modal fade" id="linkModal" tabindex="-1" aria-labelledby="linkModalLabel" aria-hidden="true">
  <div class="modal-dialog modal-dialog-centered modal-lg">
    <div class="modal-content">
      <div class="modal-header">
        <h5 class="modal-title" id="linkModalLabel"></h5>
        <button type="button" class="btn-close" data-bs-dismiss="modal" aria-label="Close"></button>
      </div>
      <div class="modal-body">
	    <iframe id="iframeLink" src="" class="w-100" style="height:210px">
	 	</iframe>
      </div>
     </div>
  </div>
</div>			  
	  
	  
</div>


<script>
var askDetach = true;

async function attach(instance,sourceId, targetId){

		const response = await fetch('stepActions.asp?action=addParent&workflowID=<%=Request.querystring("workflowID")%>&stepID='+targetId.replace("step","")+'&parentStepID='+sourceId.replace("step",""), {
		  method: 'POST',
		  headers: {
			'Content-Type': 'application/x-www-form-urlencoded'
		  },
		  body: ""
		});
		console.log(response.status);
		if ( response.status!="202") {
				//Connection failed, rollback
				askDetach = false;
				var conn = instance.getConnections({
				  //only one of source and target is needed, better if both setted
				  source: sourceId,
				  target: targetId
							});
				if (conn[0]) {
				  instance.detach(conn[0]);
				}
				askDetach = true;
	 		    alert( "Could not save the new connection." );
			}

}

async function detach(instance,sourceId, targetId){

		const response = await fetch('stepActions.asp?action=removeParent&workflowID=<%=Request.querystring("workflowID")%>&stepID='+targetId.replace("step","")+'&parentStepID='+sourceId.replace("step",""), {
		  method: 'POST',
		  headers: {
			'Content-Type': 'application/x-www-form-urlencoded'
		  },
		  body: ""
		});
		console.log(response.status);
		if (response.status!="202") {
		
			// mudar lógica para instance.drop ??
			// tem que colocar logica do askdetach no drop tb
			
			/*	askDetach = false;
				var conn = instance.getConnections({
				  //only one of source and target is needed, better if both setted
				  source: params.sourceId,
				  target: params.targetId
							});
				if (conn[0]) {
				  instance.detach(conn[0]);
				}
				askDetach = true;
			*/
			  alert( "Could not remove connection." );
			}

}


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
						if (askDetach) {
							if (confirm("Detach connection?")){
							
							detach(instance,params.sourceId, params.targetId);
								
								
							//Código deprecado
					/*	
							$.ajax({
							  url: "stepActions.asp?action=removeParent&workflowID=<%=Request.querystring("workflowID")%>&stepID="+params.targetId.replace("step","")+"&parentStepID="+params.sourceId.replace("step",""),
							  context: document.body
							})
							.done(function(html) {
							if ( html==="true") {
									askDetach = false;
									var conn = instance.getConnections({
									  //only one of source and target is needed, better if both setted
									  source: params.sourceId,
									  target: params.targetId
												});
									if (conn[0]) {
									  instance.detach(conn[0]);
									}
									askDetach = true;
								};
							});
							
						*/	
							

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

							attach(instance,params.sourceId, params.targetId);
							
							//Código deprecado
					/*		$.ajax({
							  url: "stepActions.asp?action=addParent&workflowID=<%=Request.querystring("workflowID")%>&stepID="+params.targetId.replace("step","")+"&parentStepID="+params.sourceId.replace("step",""),
							  context: document.body
							})
							.done(function(html) {
							if ( html!="true") {
									askDetach = false;
									var conn = instance.getConnections({
									  //only one of source and target is needed, better if both setted
									  source: params.sourceId,
									  target: params.targetId
												});
									if (conn[0]) {
									  instance.detach(conn[0]);
									}
									askDetach = true;
								};
							})
							.fail(function() {
							  alert( "Could not save the new connection." );
							});
						*/	

							
						

							
							
							
							
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

<script>

$('#manageFTA').on('show.bs.modal', function(e) {
    var workflowID = $(e.relatedTarget).data('workflowId');
	var title = $(e.relatedTarget).data('title');
    var description = $(e.relatedTarget).data('description');
	
	var formTitle = $(e.relatedTarget).data('formTitle');
	var url = $(e.relatedTarget).data('url');

	$(e.currentTarget).find('#formManageFTA').attr('action', url);
    $(e.currentTarget).find('#ftaModalLabel').html(formTitle);
	
    $(e.currentTarget).find('input[name="workflowID"]').val(workflowID);
    $(e.currentTarget).find('input[name="title"]').val(title);
    $(e.currentTarget).find('textarea[name="description"]').val(description);
    
});


$('#stepModal').on('show.bs.modal', function(e) {
	var title = $(e.relatedTarget).data('title');
	var url = $(e.relatedTarget).data('url');
	
	$('#stepModalLabel').html(title) ;
	$('#iframeStep').attr('src',url);
});

$('#participantsModal').on('show.bs.modal', function(e) {
	var title = $(e.relatedTarget).data('title');
	var url = $(e.relatedTarget).data('url');
    
	$('#participantsModalLabel').html(title);
	$('#iframeParticipants').attr('src',url);
});



$('#linkModal').on('show.bs.modal', function(e) {
	var title = $(e.relatedTarget).data('title');
	var url = $(e.relatedTarget).data('url');
	
	$('#linkModalLabel').html(title) ;
	$('#iframeLink').attr('src',url);
});


  // Fetch all the forms we want to apply custom Bootstrap validation styles to
  var forms = document.querySelectorAll('.requires-validation');

  // Loop over them and prevent submission
  Array.prototype.slice.call(forms)
    .forEach(function (form) {
      form.addEventListener('submit', function (event) {
        if (!form.checkValidity()) {
          event.preventDefault()
          event.stopPropagation()
        }

        form.classList.add('was-validated')
      }, false)
    });

</script>
				
<%
render.renderFooter()
%>
