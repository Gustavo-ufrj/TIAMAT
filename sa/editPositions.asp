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



render.renderTitle()

%>
							<table class="principal" width=100%>
								<tr>
									<td width=20px>
										&nbsp;
									</td>
									<td align=center>
									<form action="positionsActions.asp?action=save" method="POST">
										<table width="1184px" class="padded">

											<!-- INICIO AREA EDITAVEL -->
							

											<tr>
												<td>
													<p class="font_6" align="justify">EDIT POSITIONS <font color="red">//</font></p>							
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
														<div class="demo chart-demo" id="futures-wheel" style="height:350px">
															<%
															If stepID <> "" Then
																Call printAllSAStakelholdersInterests(stepID, True)
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

function validateSave() {
	var saForm = $('form').first()[0];
	var stakeholderElements = $('.chart-demo .stakeholder');
	var interestElements = $('.chart-demo .interest');
	var i = 0;
	
	for (i = 0; i < stakeholderElements.length; i++) {
		elem = $(stakeholderElements[i]);
		elem.children()[10].value = elem[0].style.left.substring(0,elem[0].style.left.length-2);
		elem.children()[11].value = elem[0].style.top.substring(0,elem[0].style.top.length-2);
	}
	
	i = 0;
	for (i = 0; i < interestElements.length; i++) {
		elem = $(interestElements[i]);
		elem.children()[5].value = elem[0].style.left.substring(0,elem[0].style.left.length-2);
		elem.children()[6].value = elem[0].style.top.substring(0,elem[0].style.top.length-2);
	}
	
	saForm.submit();
}


$(document).ready(function () {
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
			Container: "futures-wheel"
		});
		
		window.saStakeholders = jsPlumb.getSelector(".chart-demo .stakeholder");
		window.saInterests = jsPlumb.getSelector(".chart-demo .interest");
		window.saStakeholderInterests = jsPlumb.getSelector(".chart-demo .stakeholderInterest");
		window.saStakeholderStakeholders = jsPlumb.getSelector(".chart-demo .stakeholderStakeholder");
		
		window.saInstance.draggable(window.saStakeholders);
		window.saInstance.draggable(window.saInterests);

		window.saInstance.batch(function () {
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

		jsPlumb.fire("jsPlumbDemoLoaded", window.saInstance);
	});
	
	// Saving the stakeholder analysis
	$('#fw-event-save').click(function() {
		$('#redirectLink').prop('value', '1');
		var fwForm = $('form').first()[0];
		validateSave();
		return false;
	});
	
});
</script>


<%
render.renderFooter()
%>