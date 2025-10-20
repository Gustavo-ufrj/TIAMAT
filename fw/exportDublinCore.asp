<!--#include virtual="/system.asp"-->
<!--#include virtual="/checkstep.asp"-->
<!--#include file="INC_FUTURES_WHEEL.inc"-->

<%
saveCurrentURL

Dim stepID
stepID = request.querystring("stepID")

' Processar formulário se enviado
If Request.Form("submit") <> "" Then
    Dim dc_title, dc_description, dc_subject, dc_contributor
    
    dc_title = Request.Form("dc_title")
    dc_description = Request.Form("dc_description")
    dc_subject = Request.Form("dc_subject")
    dc_contributor = Session("userName")
    If dc_contributor = "" Then dc_contributor = "System"
    
    If dc_title <> "" Then
        ' Salvar no Dublin Core
        On Error Resume Next
        Call ExecuteSQL("INSERT INTO tiamat_dublin_core (step_id, dc_title, dc_description, dc_subject, dc_contributor, dc_date) " & _
                       "VALUES (" & stepID & ", '" & Replace(dc_title, "'", "''") & "', " & _
                       "'" & Replace(dc_description, "'", "''") & "', '" & Replace(dc_subject, "'", "''") & "', " & _
                       "'" & Replace(dc_contributor, "'", "''") & "', GETDATE())")
        
        If Err.Number = 0 Then
            Session("futuresWheelSuccess") = "Data successfully saved to Dublin Core"
        Else
            Session("futuresWheelError") = "Error saving to Dublin Core: " & Err.Description
        End If
        On Error GoTo 0
        
        Response.Redirect "index.asp?stepID=" & stepID
    End If
End If

render.renderTitle()
%>

<div class="p-3">
    <form action="" method="POST" class="requires-validation m-0" novalidate>

        <div class="alert alert-info" role="alert">
            <h5><i class="bi bi-info-circle"></i> Export Futures Wheel to Dublin Core</h5>
            <p>Save your Futures Wheel analysis as Dublin Core metadata for use in subsequent FTA methods.</p>
        </div>

        <div class="row">
            <div class="col-md-12">
                <div class="mb-3">
                    <label for="dc_title" class="form-label">Title <span class="text-danger">*</span></label>
                    <input type="text" class="form-control" id="dc_title" name="dc_title" required 
                           placeholder="Enter a descriptive title for this Futures Wheel analysis"
                           value="Futures Wheel Analysis">
                    <div class="invalid-feedback">
                        Please provide a title.
                    </div>
                </div>
            </div>
        </div>

        <div class="row">
            <div class="col-md-12">
                <div class="mb-3">
                    <label for="dc_description" class="form-label">Description</label>
                    <textarea class="form-control" id="dc_description" name="dc_description" rows="4" 
                              placeholder="Describe the main findings and impacts identified in this Futures Wheel"></textarea>
                </div>
            </div>
        </div>

        <div class="row">
            <div class="col-md-12">
                <div class="mb-3">
                    <label for="dc_subject" class="form-label">Subjects/Keywords</label>
                    <input type="text" class="form-control" id="dc_subject" name="dc_subject" 
                           placeholder="Enter keywords separated by semicolons (e.g., technology; innovation; impact)">
                    <small class="text-muted">These keywords will help categorize and connect this analysis with other methods</small>
                </div>
            </div>
        </div>

        <!-- Preview of Futures Wheel events to be exported -->
        <hr>
        <h5>Events to be Exported</h5>
        
        <%
        Dim eventCount
        eventCount = 0
        
        Call getRecordSet(SQL_CONSULTA_FUTURES_WHEEL_PRINCIPAL(stepID), rs)
        
        If Not rs.EOF Then
            Dim centralEvent
            centralEvent = rs("event")
        %>
        <div class="alert alert-secondary">
            <strong>Central Event:</strong> <%=centralEvent%>
        </div>
        
        <%
            ' Get all events
            Call getRecordSet("SELECT * FROM T_FTA_METHOD_FUTURES_WHEEL WHERE stepID = " & stepID & " ORDER BY fwID", rs)
            
            If Not rs.EOF Then
        %>
        <ul class="list-group mb-3">
        <%
                While Not rs.EOF
                    eventCount = eventCount + 1
        %>
            <li class="list-group-item"><%=rs("event")%></li>
        <%
                    rs.MoveNext()
                Wend
        %>
        </ul>
        <p class="text-muted">Total events: <%=eventCount%></p>
        <%
            End If
        Else
        %>
        <div class="alert alert-warning">
            No events found in this Futures Wheel.
        </div>
        <%
        End If
        %>

        <div class="d-flex justify-content-between mt-4">
            <button type="button" class="btn btn-secondary" onclick="window.location.href='index.asp?stepID=<%=stepID%>'">
                <i class="bi bi-arrow-left"></i> Cancel
            </button>
            <button type="submit" name="submit" value="1" class="btn btn-danger">
                <i class="bi bi-cloud-upload"></i> Export to Dublin Core
            </button>
        </div>
    </form>
</div>

<script>
// Form validation
(function() {
    'use strict';
    window.addEventListener('load', function() {
        var forms = document.getElementsByClassName('requires-validation');
        var validation = Array.prototype.filter.call(forms, function(form) {
            form.addEventListener('submit', function(event) {
                if (form.checkValidity() === false) {
                    event.preventDefault();
                    event.stopPropagation();
                }
                form.classList.add('was-validated');
            }, false);
        });
    }, false);
})();
</script>

<%
render.renderFooter()
%>