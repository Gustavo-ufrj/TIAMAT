<!--#include virtual="/system.asp"-->
<!--#include virtual="/checkstep.asp"-->
<!--#include file="INC_FUTURES_WHEEL.inc"-->

<%
saveCurrentURL




Dim backURL
Dim firstEvent
Dim height

firstEvent = False
height = 500

If request.querystring("stepID") <> "" Then
	stepID = request.querystring("stepID")
	
	Call getRecordSet (SQL_CONSULTA_FUTURES_WHEEL_PRINCIPAL(stepID), rs)

	If rs.EOF Then
		firstEvent = True
	End If

	Call getRecordSet(SQL_CONSULTA_FUTURES_WHEEL_HEIGHT(stepID), rs)

	If Not rs.EOF Then
		If Not rs("height") Then
			height = CLng(rs("height")) + 150
		End If
	End If
End If



tiamat.addCSS("/css/jsplumb.css")

' Workaround para determinar margin e padding da tabela com classe "padded", 
' pois com a tag <!DOCTYPE> essas regras não estão sendo aplicadas
tiamat.addCSS("fw.css")


'tiamat.addCSS("/js/TIAMATPopup/TIAMATPopup.css")
tiamat.addCSS("/js/contextMenu/jquery.contextMenu.css")



tiamat.addJS("/js/contextMenu/jquery.ui.position.js")
tiamat.addJS("/js/contextMenu/jquery.contextMenu.js")
'tiamat.addJS("/js/TIAMATPopup/TIAMATPopup.js")


tiamat.addJS("html2canvas.min.js")


tiamat.addJS("canvg.js")
tiamat.addJS("rgbcolor.min.js")
tiamat.addJS("stackblur.min.js")
tiamat.addJS("umd.js")


render.renderTitle()
%>


<div class="p-3">
		<form id="fwform" action="fwActions.asp?action=save" method="POST" class="requires-validation m-0" novalidate>	

	<%if Session("futuresWheelError") <> "" then%>
	  <div class="alert alert-danger alert-dismissible" role="alert">
		<%=Session("futuresWheelError")%>
		<button type="button" class="btn-close" data-bs-dismiss="alert" aria-label="Close"></button>
	  </div>		
	<%
	Session("futuresWheelError") = ""
	end if
	%>	  
	
	
	
	<div class="demo chart-demo" id="future-wheels" style="height:2000px">
		<%
		If stepID <> "" Then
			Call printAllFWEvents(stepID, False)
		End If
		%>
	</div>
	
	<canvas id="canvas"></canvas>

	  <!-- ADD FTA Modal -->
<div class="modal fade" id="addEvent" tabindex="-1" aria-labelledby="addEventLabel" aria-hidden="true">
  <div class="modal-dialog modal-dialog-centered">
	<div class="modal-content">

	  <div class="modal-header">
		<h5 class="modal-title" id="addModalLabel">Add Event</h5>
		<button type="button" class="btn-close" data-bs-dismiss="modal" aria-label="Close"></button>
	  </div>
	  <div class="modal-body">

		   <div class="mb-3">
			<label for="fw-event-text" class="form-label">Event</label>
			<input type="text" name="fw-event-text" id="fw-event-text" value="" class="form-control" required>
			<div class="invalid-feedback">Event cannot be blank!</div
		  </div>
		  
		  <div class=" mb-3">
			<label for="fw-event-parents" class="form-label">Parent events</label>
			<select class="form-control" name="fw-event-parents" id="fw-event-parents" size="10" multiple="multiple"></select>
		  </div>
		  
		  
		  </div>
		  <div class="modal-footer">
			<input type="hidden" name="stepID" value="<%=stepID%>" />
			<input type="hidden" id="redirectLink" name="redirectLink" value="0" />
			<input type="hidden" name="fw-event-id" id="fw-event-id" value="" />
			<button type="button" class="btn btn-sm btn-secondary m-1 text-center" data-bs-dismiss="modal">Close</button>
			<button type="submit" class="btn btn-sm btn-danger m-1 text-center" id="fw-save-event"><i class="bi bi-save text-light"></i> Save</button>
		  </div> 

	</div>
  </div>
</div>		


</div>
	
	
</form>	

	 <nav class="navbar fixed-bottom navbar-light bg-light" id="navbar">
         <div class="container-fluid justify-content-center p-0">
		 	<button class="btn btn-sm btn-secondary m-1" type="button" onclick="printDiv($('#fwform')[0]);"> <i class="bi bi-download text-light"></i> Export</button>
		<%if getStatusStep(request.querystring("stepID")) = STATE_ACTIVE then %>
			<button class="btn btn-sm btn-danger m-1" onclick="console.log(top.location.href); console.log('/stepsupportInformation.asp?stepID=<%=request.queryString("stepID")%>'); top.location.href='/stepsupportInformation.asp?stepID=<%=request.queryString("stepID")%>';"><i class="bi bi-journal-plus text-light"></i> Supporting Information</button>
			<button class="btn btn-sm btn-danger m-1" onclick="if(confirm('This action cannot be undone. Are you sure to end this FTA method now?'))top.location.href='/workflowActions.asp?action=end&stepID=<%=request.queryString("stepID")%>'"><i class="bi bi-check-lg text-light"></i> Finish</button>
		<%end if%>
			
         </div>
      </nav>				
	




 

<script src="/js/dom.jsPlumb-1.7.3-min.js"></script>
<script>
function fillFormAdd(order, parentFWID) {
	var elems = $('.chart-demo .window');
	var elem = null;
	var options = '';
	var i = 0;
	var possibleParentFWID = null;
	var possibleParentFWEvent = '';
	
	clearForm();
//	$('#tiamat-popup-save').html('Add');
	
	for (i = 0; i < elems.length; i++) {
		elem = $(elems[i]);
		
		if (parseInt(elem.find('input[name="order[]"]').prop('value'), 10) <= parseInt(order, 10)) {
			possibleParentFWID = elem.find('input[name="fwID[]"]').prop('value');
			possibleParentFWEvent = elem.find('input[name="fwEvent[]"]').prop('value');
			
			if (elem.find('input[name="fwID[]"]').prop('value') == parentFWID) {
				options += '<option value="' + possibleParentFWID + '" selected="selected">' + possibleParentFWEvent + '</option>';
			} else {
				options += '<option value="' + possibleParentFWID + '">' + possibleParentFWEvent + '</option>';
			}
		}
	}
	
	$('#fw-event-parents').html(options);
}

function fillFormEdit(fwID, fwEvent, order, parentFWID) {
	var elems = $('.chart-demo .window');
	var elem = null;
	var options = '';
	var i = 0;
	var possibleParentFWID = null;
	var possibleParentFWEvent = '';
	var parentFWIDs = null;
	
	clearForm();
//	$('#tiamat-popup-save').html('Update');
	$('#fw-event-id').prop('value', fwID);
	$('#fw-event-text').val(fwEvent);
	
	if (parentFWID !== fwID) {
		parentFWIDs = parentFWID.split(' | ');
		
		for (i = 0; i < elems.length; i++) {
			elem = $(elems[i]);
			
			if (parseInt(elem.find('input[name="order[]"]').prop('value'), 10) <= parseInt(order, 10)) {
				possibleParentFWID = elem.find('input[name="fwID[]"]').prop('value');
				possibleParentFWEvent = elem.find('input[name="fwEvent[]"]').prop('value');
				
				if (parentFWIDs.indexOf(elem.find('input[name="fwID[]"]').prop('value')) > -1) {
					options += '<option value="' + possibleParentFWID + '" selected="selected">' + possibleParentFWEvent + '</option>';
				} else {
					options += '<option value="' + possibleParentFWID + '">' + possibleParentFWEvent + '</option>';
				}
			}
		}
	}
	
	$('#fw-event-parents').html(options);
}

function confirmDeletion(fwID, fwEvent, order) {
	var fwForm = $('form').first()[0];
	var elems = $('.chart-demo .window');
	var parentFWIDs = null;
	var elem = null;
	var i = 0;
	var j = 0;
	var found = false;
	var del = null;
	
	for (i = 0; i < elems.length; i++) {
		elem = $(elems[i]);
		found = false;
		
		if (parseInt(elem.find('input[name="order[]"]').prop('value')) === parseInt(order) + 1) {
			parentFWIDs = elem.find('input[name="parentFWID[]"]').prop('value').split(' | ');
			
			for (j = 0; j < parentFWIDs.length; j++) {
				if (parseInt(parentFWIDs[j]) === parseInt(fwID)) {
					found = true;
					break;
				}
			}
		}
		if (found) {
			break;
		}
	}
	
	if (found) {
		alert("To delete the event \"" + fwEvent + "\", you must delete its child events before.");
		return;
	} else {
		del = confirm("Do you really want to delete the event \"" + fwEvent + "\"?");
	}
	
	if (del === true) {
		$('#' + fwID + ' input[name="operation[]"]').prop('value', window.OPER_DEL);
		validateSave();
	}
}

function clearForm() {
	$('#fw-event-id').prop('value', '');
	$('#fw-event-id').val('');
	$('#fw-event-text').val('');
	$('#fw-event-parents').html('');
}

function showForm(title) {

var addEventModal = new bootstrap.Modal(document.getElementById('addEvent'))
addEventModal.show()

}

function hideForm() {
	hideTIAMATPopup();
}

function validateSave() {
	console.log('validateSave');
	var fwForm = $('form').first()[0];
	var elements = $('.chart-demo .window');
	var i = 0;
	var operation = window.OPER_NO;
	
	for (i = 0; i < elements.length; i++) {
		elem = $(elements[i]);
		posX = parseInt(elem.find('input[name="posX[]"]').prop('value'));
		posY = parseInt(elem.find('input[name="posY[]"]').prop('value'));
		operation = elem.find('input[name="operation[]"]').prop('value');
		
		if (operation != window.OPER_ADD && (posX !== parseInt(elem.css('left')) || posY !== parseInt(elem.css('top')))) {
			if (operation == window.OPER_NO) {
				elem.find('input[name="operation[]"]').prop('value', window.OPER_EDIT);
			}
			elem.find('input[name="posX[]"]').prop('value', parseInt(elem.css('left')));
			elem.find('input[name="posY[]"]').prop('value', parseInt(elem.css('top')));
		} else {
			//elem.find('input[name="operation[]"]').prop('value', window.OPER_NO);
		}
	}
	var formEl = document.forms.fwform;
	var formData = new FormData(formEl);
	console.log(formData);
	
	fwForm.submit();
}




async function backgroundSave() {
	     var nodes = []


            $(".window").each(function (idx, elem) {
            var $elem = $(elem);
            //var endpoints = jsPlumb.getEndpoints($elem.attr('id'));

 			nodes.push({
                    fwID: $elem.attr('id'),
                   // nodetype: $elem.attr('data-nodetype'),
                    positionX: parseInt($elem.css("left"), 10),
                    positionY: parseInt($elem.css("top"), 10)
                });
				
	        });            


			var graph = {};
            graph.nodes = nodes;
	

			const response = await fetch('fwActions.asp?action=savePos', {
			  method: 'POST',
			  headers: {
				'Content-Type': 'application/x-www-form-urlencoded'
			  },
			  body: JSON.stringify(graph)
			});

			
}


<%if getStatusStep(request.querystring("stepID")) = STATE_ACTIVE then %>
	setInterval(backgroundSave, 5000);
<%end if%>


$(document).ready(function () {
	jsPlumb.ready(function () {
		var color = "gray";
		
		window.fwEvents = null;
		window.fwInstance = null;
		
		window.fwInstance = jsPlumb.getInstance({
			Connector: "StateMachine",
			PaintStyle: { lineWidth: 2, strokeStyle: color },
			Endpoint: [ "Dot", { radius: 5 } ],
			EndpointStyle: { fillStyle: color },
			Container: "future-wheels"
		});
		
		window.fwEvents = jsPlumb.getSelector(".chart-demo .window");
		
		window.fwInstance.draggable(window.fwEvents);

		window.fwInstance.batch(function () {
			// arrows for connections
			var arrowCommon = { foldback: 0.7, fillStyle: color, width: 14 };
			var overlays = [[ "Arrow", { location: 1.0 }, arrowCommon ]];
			var i = 0;
			var j = 0;
			var k = 0;
			var parentFWIDs = null;
			var elem = null;
			var elemChildren = [];
			
			for (i = 0; i < window.fwEvents.length; i++) {
				elem = $(window.fwEvents[i]);
				
				/*window.fwInstance.addEndpoint(window.fwEvents[i], {
					uuid: "endpoint-" + elem.prop('id'),
					anchor: [ "Perimeter", { shape: "Circle"}],
					maxConnections: -1
				});*/
				
				parentFWIDs = elem.find('input[name="parentFWID[]"]').prop('value').split(' | ');
				
				for (j = 0; j < parentFWIDs.length; j++) {
					for (k = 0; k < window.fwEvents.length; k++) {
						if (parentFWIDs[j] == window.fwEvents[k].getAttribute('id') && parentFWIDs[j] != window.fwEvents[i].getAttribute('id')) {
							window.fwInstance.connect({
								source: window.fwEvents[k],
								target: window.fwEvents[i],
								anchors: [
									[ "Perimeter", { shape: "Circle"}],
									[ "Perimeter", { shape: "Circle"}]
								],
								overlays: overlays
							});
							
							break;
						}
					}
				}
			}
		});

		jsPlumb.fire("jsPlumbDemoLoaded", window.fwInstance);
	});

	
	
	window.stepID = $('input[name="stepID"]').prop('value');
	window.OPER_NO = 0;
	window.OPER_ADD = 1;
	window.OPER_EDIT = 2;
	window.OPER_DEL = 3;
	
	//loadTIAMATPopup();
	
	$.contextMenu({
		selector: '.context-menu', 
		items: {
			"add": {name: "Add Event", icon: "add", 
				callback: function() {
					var elem = $(this);
					var fwID = elem.find('input[name="fwID[]"]').prop('value');
					var order = elem.find('input[name="order[]"]').prop('value');
					closeMenu();
					fillFormAdd(order, fwID);
					showForm('Add new record');
				}},
			"edit": {name: "Edit Event", icon: "edit", 
				callback: function() {
					var elem = $(this);
					var fwID = elem.find('input[name="fwID[]"]').prop('value');
					var fwEvent = elem.find('input[name="fwEvent[]"]').prop('value');
					var order = elem.find('input[name="order[]"]').prop('value');
					var parentFWID = elem.find('input[name="parentFWID[]"]').prop('value');
					closeMenu();
					fillFormEdit(fwID, fwEvent, order, parentFWID);
					showForm('Edit record');
				}},
			"del": {name: "Remove Event", icon: "delete", 
				callback: function() {
					var elem = $(this);
					var fwID = elem.find('input[name="fwID[]"]').prop('value');
					var fwEvent = elem.find('input[name="fwEvent[]"]').prop('value');
					var order = elem.find('input[name="order[]"]').prop('value');
					closeMenu();
					confirmDeletion(fwID, fwEvent, order);
				}},
			"cancel": {name: "Cancel", icon: "quit", 
				callback: function() {
					closeMenu(); // do nothing
				}}
		}
	});
	
	// Adding new elements
	$('.add-fw-event').click(function() {
		var fwID = $(this).parent().parent().find('input[name="fwID[]"]').prop('value');
		var order = $(this).parent().parent().find('input[name="order[]"]').prop('value');
		
		fillFormAdd(order, fwID);
		showForm('Add new record');
	});
	
	// Editing elements
	$('.chart-demo .window .fw-event-text').dblclick(function() {
		var elem = $(this);
		var fwID = elem.parent().find('input[name="fwID[]"]').prop('value');
		var fwEvent = elem.parent().find('input[name="fwEvent[]"]').prop('value');
		var order = elem.parent().find('input[name="order[]"]').prop('value');
		var parentFWID = elem.parent().find('input[name="parentFWID[]"]').prop('value');
		
		fillFormEdit(fwID, fwEvent, order, parentFWID);
		showForm('Edit record');
	});
	
	// Deleting elements
	$('.del-fw-event').click(function() {
		var elem = $(this);
		var fwID = elem.parent().parent().find('input[name="fwID[]"]').prop('value');
		var fwEvent = elem.parent().parent().find('input[name="fwEvent[]"]').prop('value');
		
		confirmDeletion(fwID, fwEvent);
	});
	
	// Confirming the addition/edition
	$('#fw-save-event').click(function() {
		var fwForm = $('form').first()[0];
			console.log("a");
			
		var fwID = $('#fw-event-id').prop('value');
			console.log("b");
				console.log(fwID);
				console.log("c");
		var fwEvent = $('#fw-event-text').val();
		var parentFWIDs = $('#fw-event-parents option:selected');
		var parentFWID = '';
		
		var fwEvents = null;
		var posX = 0;
		var posY = 0;
		
		var order = 0;
		var elem = null;
		
		if (fwEvent) {
			fwEvent = fwEvent.trim();
		}
		
		if (fwEvent === '') {
			alert('Please inform an event description.');
			$('#fw-event-text').focus();
			return;
		}
		
		<%
		If Not firstEvent Then
		%>
		if (parentFWIDs.length === 0) {
		
			console.log(fwID);
			console.log($('#' + fwID));
			console.log($('#' + fwID).find('input[name="parentFWID[]"]'));
			console.log($('#' + fwID).find('input[name="parentFWID[]"]').prop('value'));
			if (fwID !== $('#' + fwID).find('input[name="parentFWID[]"]').prop('value')) {
				alert("Events (except the first) must have at least one parent event.");
				return;
			}
		}
		<%
		End If
		%>
		
		for (i = 0; i < parentFWIDs.length; i++) {
			parentFWID += $(parentFWIDs[i]).prop('value') + ' | ';
		}
		if (parentFWID !== '') {
			parentFWID = parentFWID.substr(0, parentFWID.length - 3);
		}
		
		if (!fwID) { // New event
			<%
			If firstEvent Then
			%>
			if (parentFWID === '') {
				parentFWID = '0';
			}
			<%
			Else
			%>
			if (parentFWID === '') {
				alert('Please inform one or more parent events.');
				return;
			}
			
			elem = $('#' + $(parentFWIDs[parentFWIDs.length-1]).prop('value'));
			order = parseInt(elem.find('input[name="order[]"]').prop('value')) + 1;
			posX = parseInt(elem.find('input[name="posX[]"]').prop('value')) + 50;
			posY = parseInt(elem.find('input[name="posY[]"]').prop('value')) + 50;
			
			<%
			End If
			%>
			var element = '';
			element += '<div class="window order-0" id="" style="display:none;top:0px;left:0px;">'
			element += '<input type="hidden" name="fwID[]" value="" />';
			element += '<input type="hidden" name="stepID[]" value="<%=request.querystring("stepID")%>" />';
			element += '<input type="hidden" name="parentFWID[]" value="' + parentFWID + '" />';
			element += '<input type="hidden" name="fwEvent[]" value="' + fwEvent + '" />';
			element += '<input type="hidden" name="posX[]" value="' + posX + '" />';
			element += '<input type="hidden" name="posY[]" value="' + posY + '" />';
			element += '<input type="hidden" name="order[]" value="' + order + '" />';
			element += '<input type="hidden" name="operation[]" value="' + window.OPER_ADD + '" />';
			element += '<p>' + fwEvent + '</p>';
			element += '</div>';
			
			
			$('#future-wheels').append(element);
		} else { // Editing event
			if (parentFWID === '') {
				parentFWID = fwID;
			}
			$('#' + fwID + ' p').html(fwEvent);
			$('#' + fwID + ' input[name="fwEvent[]"]').prop('value', fwEvent);
			$('#' + fwID + ' input[name="parentFWID[]"]').prop('value', parentFWID);
			$('#' + fwID + ' input[name="operation[]"]').prop('value', window.OPER_EDIT);
		}
		
		//fwForm.submit();
		validateSave();
	});
	
	// Canceling adding/editing
	$('#tiamat-popup-cancel').click(function() {
		hideForm();
		clearForm();
	});
	
	// Saving the futures wheel
	$('#fw-event-save').click(function() {
		$('#redirectLink').prop('value', '1');
		validateSave();
		return false;
	});
	

	function closeMenu(){
		const collection = document.getElementsByClassName("context-menu-list context-menu-root");
		collection[0].classList.add("d-none");
		$('#context-menu-layer').hide();
	}


	
	<%
	if firstEvent then
	%>
	showForm();
	<%
	end if
	%>
});
</script>

<script>



function printDiv(div)
{

	$("#navbar").hide();

	var svgList = document.querySelectorAll('svg');
	window.scroll(0,0);
	
		for (var svg of svgList) {
			
		var svgData = new XMLSerializer().serializeToString(svg);
		//var svgData2 = new XMLSerializer().serializeToString(svg);
			try {
				
				
				// Removendo o XMLNS duplicado que quebra o canvg
				svgData = replaceAll(svgData, ' xmlns="http://www.w3.org/2000/svg"','');
			

				var canvas = document.createElement('canvas');
				var ctx = canvas.getContext('2d');
				
				v = canvg.Canvg.fromString(ctx, svgData);
				
				// Start SVG rendering with animations and mouse handling.
				v.start();
				
				canvas.style.position = "absolute";
				
				var offset = $(svg).offset();
				var posY = offset.top - $(window).scrollTop();
				var posX = offset.left - $(window).scrollLeft(); 
				
				canvas.style.left = posX;
				canvas.style.top = posY;
				
				div.appendChild(canvas);
				svg.remove();
			}
			catch (e) {
				console.log(e); 
			}
		}


	
	
    html2canvas(div).then((canvas) => {
		var myImage = canvas.toDataURL();
        downloadURI(myImage, "futures-wheel.png");
		
		window.location.reload();

	});
	
	$("#navbar").show();

	
}

function downloadURI(uri, name) {
    var link = document.createElement("a");
	console.log(link);
    link.download = name;
    link.href = uri;
    document.body.appendChild(link);
    link.click();   
}

</script>



<%
render.renderFooter()
%>
