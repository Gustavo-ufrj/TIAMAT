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


tiamat.addCSS("/js/TIAMATPopup/TIAMATPopup.css")
tiamat.addCSS("/js/contextMenu/jquery.contextMenu.css")



tiamat.addJS("/js/contextMenu/jquery.ui.position.js")
tiamat.addJS("/js/contextMenu/jquery.contextMenu.js")
tiamat.addJS("/js/TIAMATPopup/TIAMATPopup.js")

render.renderTitle()
%>


<div id="tiamat-popup-background"></div>
<div id="tiamat-popup-container">
	<input type="hidden" name="fw-event-id" id="fw-event-id" value="" />
	
	<div id="tiamat-popup-header">
		<span id="tiamat-popup-header-text">Add new record</span>
	</div>
	<div id="tiamat-popup-content">
		<div id="tiamat-popup-fields-container">
			<div class="tiamat-popup-field">
				<label>Event description </label>
				<input type="text" name="fw-event-text" id="fw-event-text" value="" placeholder="New Event" />
			</div>
		</div>
		
		<div id="tiamat-popup-fields-container">
			<div class="tiamat-popup-field tiamat-popup-field-last">
				<label>Parent events </label>
				<select name="fw-event-parents" id="fw-event-parents" size="10" multiple="multiple"></select>
			</div>
		</div>
		
		<div id="tiamat-popup-buttons-container">
			<div id="tiamat-popup-buttons-content">
				<button id="tiamat-popup-cancel">Cancel</button>
				<button id="tiamat-popup-save">Save</button>
			</div>
		</div>
	</div>
</div>


							<table class="principal" width=100%>
								<tr>
									<td width=20px>
										&nbsp;
									</td>
									<td align=center>
									<form action="fwActions.asp?action=save" method="POST">
										<table width="1184px" class="padded">

											<!-- INICIO AREA EDITAVEL -->
							

											<tr>
												<td>
													<p class="font_6" align="justify">EDIT FUTURES WHEEL <font color="red">//</font></p>							
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
														<div class="demo chart-demo" id="futures-wheel" style="height:700px">
															<%
															If stepID <> "" Then
																Call printAllFWEvents(stepID, True)
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
												<td align="center">
													<input type="hidden" name="stepID" value="<%=stepID%>" />
													<input type="hidden" id="redirectLink" name="redirectLink" value="0" />
													<button class="TIAMATButton" onclick="window.location.href='index.asp?stepID=<%=stepID%>';return false;">Back</button>
													<button class="TIAMATButton" id="fw-event-save">Save</button>
												</td>
											

										<!-- FIM AREA EDITAVEL -->

											</tr>
											<tr>
												<td height="60px" valign="middle" align="center" colspan="2" class="padded" >
													<font class="error-msg" color=red><%=Session("futuresWheelError")%></font>
													<%
													Session("futuresWheelError") = ""
													%>
												</td>
											</tr>
										</table>
										</form>
									</td>
									<td width=20px>
									&nbsp;&nbsp;&nbsp;
									</td>
								</tr>
							</table>
	
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
	$('#tiamat-popup-save').html('Add');
	
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
	$('#tiamat-popup-save').html('Update');
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
	showTIAMATPopup(title);
	$('#fw-event-text').focus();
}

function hideForm() {
	hideTIAMATPopup();
}

function validateSave() {
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
	
	fwForm.submit();
}

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
			Container: "futures-wheel"
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

	//setInterval(saveFWFlowchart, 5000);
	
	window.stepID = $('input[name="stepID"]').prop('value');
	window.OPER_NO = 0;
	window.OPER_ADD = 1;
	window.OPER_EDIT = 2;
	window.OPER_DEL = 3;
	
	loadTIAMATPopup();
	
	$.contextMenu({
		selector: '.context-menu', 
		items: {
			"add": {name: "Add", icon: "add", 
				callback: function() {
					var elem = $(this);
					var fwID = elem.find('input[name="fwID[]"]').prop('value');
					var order = elem.find('input[name="order[]"]').prop('value');
					
					fillFormAdd(order, fwID);
					showForm('Add new record');
				}},
			"edit": {name: "Edit", icon: "edit", 
				callback: function() {
					var elem = $(this);
					var fwID = elem.find('input[name="fwID[]"]').prop('value');
					var fwEvent = elem.find('input[name="fwEvent[]"]').prop('value');
					var order = elem.find('input[name="order[]"]').prop('value');
					var parentFWID = elem.find('input[name="parentFWID[]"]').prop('value');
					
					fillFormEdit(fwID, fwEvent, order, parentFWID);
					showForm('Edit record');
				}},
			"del": {name: "Delete", icon: "delete", 
				callback: function() {
					var elem = $(this);
					var fwID = elem.find('input[name="fwID[]"]').prop('value');
					var fwEvent = elem.find('input[name="fwEvent[]"]').prop('value');
					var order = elem.find('input[name="order[]"]').prop('value');
					
					confirmDeletion(fwID, fwEvent, order);
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
	$('#tiamat-popup-save').click(function() {
		var fwForm = $('form').first()[0];
		
		var fwID = $('#fw-event-id').prop('value');
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
			
			
			$('#futures-wheel').append(element);
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
	
	<%
	if firstEvent then
	%>
	showForm();
	<%
	end if
	%>
});
</script>


<%
render.renderFooter()
%>
