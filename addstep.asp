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


render.renderToBody()
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

	
	
	
	
<form action="stepActions.asp?action=new" method="post" autocomplete="off">	
<div class="py-0 px-2">
	<div class=" mb-3">
		<label for="ftamethod" class="form-label">FTA Method</label>
		<select class="form-control"  name="ftamethod" id="ftamethod" onchange="selectForm(this);">
			<option value="" dafault>Select the FTA Method</option>
			<% for i = 0 to methods.length-1 %>
			  <option value="<%=methods(i).getAttribute("id")%>"><%=methods(i).getAttribute("name")%></option>
			<%Next%>
		</select>
	</div>
</div>		

	<input type="hidden" name="workflowID" value="<%=request.querystring("workflowID")%>">
	<input type="hidden" name="parentStepID" value="<%=request.querystring("parentStepID")%>">
	<div class="modal-footer fixed-bottom pb-0 px-0 mx-0">
		<!--	<button type="button" class="btn btn-sm btn-secondary m-1 text-center" data-bs-dismiss="modal">Close</button> -->
			<button class="btn btn-sm btn-secondary m-1" onclick="top.location.href='/manageWorkflow.asp?workflowID=<%=request.querystring("workflowID")%>';"> Close</button>
			<button class="btn btn-sm btn-danger m-1" type="submit" value="Save"  onclick="return validateForm();"> <i class="bi bi-save text-light"></i> Save</button>
	</div>
  
</form>		
		
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


<%
render.renderFromBody()
%>