<%@LANGUAGE="VBSCRIPT" CODEPAGE="1252"%>
<!--#include virtual="/system.asp"-->
<%
Dim stepID
stepID = Request.QueryString("stepID")

If stepID = "" Then
    Response.Write("Error: No stepID provided")
    Response.End
End If
%>

<!DOCTYPE html>
<html>
<head>
<title>Import Data from Previous Methods</title>
<style>
body { 
    font-family: Arial, sans-serif; 
    margin: 20px;
    background: #f5f5f5;
}
.container { 
    max-width: 800px; 
    margin: 0 auto;
}
.card {
    background: white;
    padding: 20px;
    margin-bottom: 20px;
    border: 1px solid #ddd;
}
h2 { color: #333; }
h3 { 
    color: #666; 
    border-bottom: 2px solid #4CAF50;
    padding-bottom: 5px;
}
.data-section {
    background: #f9f9f9;
    padding: 15px;
    margin: 10px 0;
    border-left: 4px solid #2196F3;
}
.data-item {
    padding: 8px;
    margin: 5px 0;
    background: white;
    border: 1px solid #ddd;
}
textarea {
    width: 100%;
    box-sizing: border-box;
    padding: 10px;
    border: 2px solid #ddd;
}
button {
    padding: 10px 20px;
    margin: 5px;
    font-size: 14px;
    border: none;
    cursor: pointer;
}
.btn-primary {
    background: #4CAF50;
    color: white;
}
.btn-secondary {
    background: #757575;
    color: white;
}
</style>
</head>
<body>

<div class="container">
    <div class="card">
        <h2>Import Data from Previous Methods</h2>
    </div>

    <form method="POST" action="index.asp?stepID=<%=stepID%>">
        <input type="hidden" name="importAction" value="doImport">
        
        <div class="card">
            <h3>Previous Methods Data</h3>
            
            <%
            Dim workflowID, hasData
            hasData = False
            
            ' Get workflowID
            On Error Resume Next
            Call getRecordSet("SELECT workflowID FROM T_WORKFLOW_STEP WHERE stepID = " & stepID, rs)
            If Not rs.EOF Then
                workflowID = rs("workflowID")
            End If
            rs.Close
            
            ' Show Brainstorming data
            If workflowID <> "" Then
                Call getRecordSet("SELECT TOP 30 idea FROM T_FTA_METHOD_BRAINSTORMING_IDEAS bi " & _
                                "INNER JOIN T_WORKFLOW_STEP ws ON bi.stepID = ws.stepID " & _
                                "WHERE ws.workflowID = " & workflowID & " " & _
                                "ORDER BY bi.ideaID DESC", rs)
                
                If Not rs.EOF Then
                    hasData = True
                    Response.Write("<div class='data-section'>")
                    Response.Write("<h4>Brainstorming Ideas</h4>")
                    Response.Write("<p>Copy the items you want to use:</p>")
                    While Not rs.EOF
                        Response.Write("<div class='data-item'>" & rs("idea") & "</div>")
                        rs.MoveNext
                    Wend
                    Response.Write("</div>")
                End If
                rs.Close
                
                ' Show Scenarios data
                Call getRecordSet("SELECT TOP 20 title FROM T_FTA_METHOD_SCENARIOS s " & _
                                "INNER JOIN T_WORKFLOW_STEP ws ON s.stepID = ws.stepID " & _
                                "WHERE ws.workflowID = " & workflowID & " " & _
                                "ORDER BY s.scenarioID DESC", rs)
                
                If Not rs.EOF Then
                    hasData = True
                    Response.Write("<div class='data-section'>")
                    Response.Write("<h4>Scenarios</h4>")
                    Response.Write("<p>Copy the items you want to use:</p>")
                    While Not rs.EOF
                        Response.Write("<div class='data-item'>" & rs("title") & "</div>")
                        rs.MoveNext
                    Wend
                    Response.Write("</div>")
                End If
                rs.Close
            End If
            
            On Error Goto 0
            
            If Not hasData Then
                Response.Write("<p>No data found from previous methods.</p>")
            End If
            %>
        </div>
        
        <div class="card">
            <h3>Events to Import</h3>
            <p>Enter or paste events below (one per line):</p>
            <textarea name="importText" rows="10" placeholder="Enter events here, one per line..."></textarea>
            
            <div style="margin-top: 20px;">
                <button type="submit" class="btn-primary">Import to Futures Wheel</button>
                <button type="button" class="btn-secondary" onclick="location.href='index.asp?stepID=<%=stepID%>'">Cancel</button>
            </div>
        </div>
    </form>
</div>

</body>
</html>