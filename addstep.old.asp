<!--#include virtual="/system.asp"-->
<!--#include virtual="/checklogin.asp"-->

<%

Dim raiz
set raiz = LoadManifest()
set methods = getFTAMethodList(raiz)

tiamat.addCSS("/textext/css/textext.core.css")
tiamat.addCSS("/textext/css/textext.plugin.tags.css")
tiamat.addCSS("/textext/css/textext.plugin.autocomplete.css")
tiamat.addCSS("/textext/css/textext.plugin.focus.css")
tiamat.addCSS("/textext/css/textext.plugin.prompt.css")
tiamat.addCSS("/textext/css/textext.plugin.arrow.css")
tiamat.addJS("/textext/js/textext.core.js")
tiamat.addJS("/textext/js/textext.plugin.tags.js")
tiamat.addJS("/textext/js/textext.plugin.autocomplete.js")
tiamat.addJS("/textext/js/textext.plugin.suggestions.js")
tiamat.addJS("/textext/js/textext.plugin.filter.js")
tiamat.addJS("/textext/js/textext.plugin.focus.js")
tiamat.addJS("/textext/js/textext.plugin.prompt.js")
tiamat.addJS("/textext/js/textext.plugin.ajax.js")
tiamat.addJS("/textext/js/textext.plugin.arrow.js")


render.renderTitle()
%>

<script>


function selectForm(method) {
	var container = document.getElementById("fields");
	
	if (method.value != "") {
		$.get("getFTAParam.asp?methodID="+method.value, function(data, status){
			if (status == "success") {
				container.innerHTML = data;
				var i=0;
				var insertRules= JSON.parse(replaceAll($("#rules").val(), "'", "\""));
				var id="textarea"+i.toString();
				var txarea = document.getElementById(id)
				while (txarea!==null) {
					$("#"+id).textext({
						plugins : 'tags prompt focus autocomplete ajax arrow',
						tagsItems : [],
						prompt : '',
						ajax : {
							url : 'getUsers.asp',
							dataType : 'json',
							cacheResults : true
						}
					}).bind('isTagAllowed', function(e, data){ var text = eval($("#itemfocus").val()+".value"); data.result=(text.indexOf("<") > 0 && text.indexOf(">") > 0);});

					i++;
					id="textarea"+i.toString();
					txarea = document.getElementById(id)
				}
			}
		});
	}
	else {
		container.innerHTML = "";
	}
}

</script>

							<table class="principal" width=100%>
								<tr>
									<td width=20px>
										&nbsp;
									</td>
									<td align=center>
										<table width=1184 class="padded">

											<!-- INICIO AREA EDITAVEL -->
							

											<tr>
												<td>	
	
	
	
	
<form action="stepActions.asp?action=new" method="post" autocomplete="off">	
	<table class="principal" width=100% height=100%>
		<tr>
			<td align=center class="padded">
				<br>
				<p class="font_6" align="justify">NEW FTA STEP <font color="red">//</font></p>							
			</td>
		</tr>
		<tr>
			<td align=center>
				<hr class="linhaDupla">
			</td>
		</tr>
		<tr>
			<td align=center class="padded">
				<table width=100%>
					<tr>
						<td class="padded" align=right width=40%>
							FTA Method: 
						</td>
						<td class="padded" width=60%>
							<select name="ftamethod" id="ftamethod" onchange="selectForm(this);">
								<option value="" dafault>Select the FTA Method</option>
								<% for i = 0 to methods.length-1 %>
								  <option value="<%=methods(i).getAttribute("id")%>"><%=methods(i).getAttribute("name")%></option>
								<%Next%>
							</select>
						</td>
					</tr>
				</table>
				<table width=100% id="fields">
				</table>
				</td>
			</tr>
			<tr>
				<td align=center>
					<hr class="linhaDupla">
				</td>
			</tr>
			<tr>
				<td align=center class="padded">
					<input type="hidden" name="workflowID" value="<%=request.querystring("workflowID")%>">
					<input type="hidden" name="parentStepID" value="<%=request.querystring("parentStepID")%>">
					<input type="submit" value="Save" class="TIAMATButton" onclick="return validateForm();">
			</td>
		</tr>
		
		<script>
			function validateForm(){	
			var message = "";
				if ($.trim($("#ftamethod").val())=="") {
					message = message + "- Please inform the FTA method.\n";
				}
				if (typeof($("#rules").val()) !== 'undefined') {
					var obj = JSON.parse(replaceAll($("#rules").val(), "'", "\""));
					for (var i=0; i < obj.rules.length; i++){
						if ($.trim($("input[name="+obj.rules[i].role+"]").val())=="[]") {
							message = message + "- Please inform someone for the '"+obj.rules[i].role+"' role.\n";
						}
					}
				}
				if (message!="") {
					alert("The FTA Step could not be saved due:\n"+message);
				}
				return message=="";
			}
											
		</script>
		<tr>
			<td align=center height=500px>
			</td>
		</tr>
	</table>
</form>


												</td>
											</tr>
												

										<!-- FIM AREA EDITAVEL -->

										</table>
									</td>
									<td width=20px>
									&nbsp;&nbsp;&nbsp;
									</td>
								</tr>
							</table>
<%
render.renderFooter()
%>