<!--#include virtual="/system.asp"-->
<!--#include virtual="/checklogin.asp"-->
<!--#include virtual="/checkworkflow.asp"-->

<%

Dim rs, usuario, workflowID

	code = request.querystring("code") 
	verification = request.querystring("verification") 
		
	Dim domainName, urlParam, fullURL
	
	If lcase(Request.ServerVariables("HTTPS")) = "on" Then 
		strProtocol = "https://" 
	Else
		strProtocol = "http://" 
	End If

	domainName = Request.ServerVariables("SERVER_NAME") 
	urlParam   = Request.ServerVariables("HTTP_X_ORIGINAL_URL")
	
	fullURL = strProtocol & domainName & urlParam & "/join.asp?code=" & code & "&verification=" & verification
	
	tiamat.addJS("/js/clipboard.min.js")
render.renderToBody()
%>

		
	

<div class="py-0 px-2">
	<p>Copy and send this link to the people you want to join the study. We recommend you to <b>save</b> the link for later use.</p>
	<label for="link" class="form-label">Your Invitation Link is:</label>
	   <div class="input-group mb-3">
			<input type="text" class="form-control" id="link" name="link" value="<%=fullURL%>" readonly> 
			<button id="copyClipboard" class="btn btn-secondary" type="button" data-clipboard-demo="" data-clipboard-target="#link" data-bs-toggle="tooltip" data-bs-placement="bottom" title="Copy to Clipboard">Copy</button>
	  </div>
	  
	    
	  
	  
</div>		

	
	<div class="modal-footer fixed-bottom pb-0 px-0 mx-0">
		
			<button class="btn btn-sm btn-secondary m-1" onclick="top.location.href='/manageWorkflow.asp?workflowID=<%=request.querystring("workflowID")%>';"> Close</button>
	</div>
  

<script>
    let btn = document.getElementById('copyClipboard');
    let clipboard = new ClipboardJS(btn);

    clipboard.on('success', function(e) {
        $(':focus').blur();
    });

    clipboard.on('error', function(e) {
       $(':focus').blur();
    });
</script>
	


<%
render.renderFromBody()
%>
							