<%

function SQL_CREATE_POINT(pointID, stepID, x, y)
	SQL_CREATE_POINT = "INSERT INTO T_FTA_METHOD_TIA_POINTS (pointID, stepID, x, y) VALUES ('"&pointID&"',"&stepID&","&x&","&y&")"
end function

function SQL_READ_POINT(pointID, stepID)
	SQL_READ_POINT = "Select * from T_FTA_METHOD_TIA_POINTS where pointID="&pointID&" and stepID="&stepID
end function

function SQL_READ_POINTS(stepID)
	SQL_READ_POINTS = "Select * from T_FTA_METHOD_TIA_POINTS where stepID="&stepID&" order by x asc"
end function

function SQL_READ_POINTS_FOR_GRAPH(stepID)
	SQL_READ_POINTS_FOR_GRAPH = "Select x, y from T_FTA_METHOD_TIA_POINTS where stepID='"+stepID+"' order by x,y asc"
end function

function SQL_UPDATE_POINT(pointID, stepID, x, y)
	SQL_UPDATE_POINT = "UPDATE T_FTA_METHOD_TIA_POINTS SET x="&x&", y="&y&" WHERE pointID="&pointID&" and stepID="&stepID
end function

function SQL_DELETE_POINT(pointID, stepID)
	SQL_DELETE_POINT = "DELETE FROM T_FTA_METHOD_TIA_POINTS where pointID="+pointID+" and stepID="+stepID
end function

function SQL_DELETE_ALL_POINTS(stepID)
	SQL_DELETE_ALL_POINTS = "Delete from T_FTA_METHOD_TIA_POINTS where stepID='"+stepID+"'"
end function

function SQL_CREATE_INFORMATION(stepID, x_name, x_desc, y_name, y_desc, adj_type, range, source, scenarios)
	SQL_CREATE_INFORMATION = "INSERT INTO T_FTA_METHOD_TIA_INFORMATION (stepID,x_name,x_desc,y_name,y_desc,adj_type,range,source,scenarios) VALUES ("&stepID&",'"&x_name&"','"&x_desc&"','"&y_name&"','"&y_desc&"','"&adj_type&"',"&range&",'"&source&"',"&scenarios&")" 
end function

function SQL_READ_INFORMATION(stepID)
	SQL_READ_INFORMATION = "Select * from T_FTA_METHOD_TIA_INFORMATION where stepID="&stepID
end function

function SQL_UPDATE_INFORMATION(stepID, x_name, x_desc, y_name, y_desc, adj_type, range, source, scenarios)
	SQL_UPDATE_INFORMATION = "UPDATE T_FTA_METHOD_TIA_INFORMATION SET x_name='"&x_name&"', x_desc='"&x_desc&"', y_name='"&y_name&"', y_desc='"&y_desc&"', adj_type='"&adj_type&"',range="&range&",source='"&source&"',scenarios="&scenarios&" WHERE stepID='"&stepID&"'"
end function

function SQL_DELETE_INFORMATION(stepID)
	SQL_DELETE_INFORMATION = "Delete from T_FTA_METHOD_TIA_INFORMATION where stepID='"+stepID+"'"
end function

function SQL_UPDATE_PARAMETERS(stepID, parameters)
	SQL_UPDATE_PARAMETERS = "UPDATE T_FTA_METHOD_TIA_INFORMATION SET parameters='"&parameters&"' WHERE stepID='"+stepID+"'"
end function

function SQL_CREATE_RESULTPOINT(pointID, stepID, scenario, x, y, z, info)
	if y then
		SQL_CREATE_RESULTPOINT = "INSERT INTO T_FTA_METHOD_TIA_RESULT (pointID, stepID, scenario, X, Y, Z, info) VALUES ('"&pointID&"','"&stepID&"','"&scenario&"','"&x&"','"&y&"','"&z&"','"&info&"')"
	else 
		SQL_CREATE_RESULTPOINT = "INSERT INTO T_FTA_METHOD_TIA_RESULT (pointID, stepID, scenario, X, Y, Z, info) VALUES ('"&pointID&"','"&stepID&"','"&scenario&"','"&x&"',null,'"&z&"','"&info&"')"
	end if
end function

function SQL_READ_BASERESULTPOINT(stepID, x)
	SQL_READ_BASERESULTPOINT = "Select pointID, stepID, X, Y, Z from T_FTA_METHOD_TIA_RESULT where stepID="&stepID&" and scenario = 0 and X = "&x
end function

function SQL_READ_BASERESULTPOINTS(stepID)
	SQL_READ_BASERESULTPOINTS = "Select pointID, stepID, X, Y, Z from T_FTA_METHOD_TIA_RESULT where stepID="&stepID&" and scenario = 0 order by X"
end function

function SQL_READ_RESULT(stepID)
	SQL_READ_RESULT = "select pointID, stepID, X, Y, case when y is null then Z else null end as Z from T_FTA_METHOD_TIA_RESULT where  stepID = " & stepID & " and scenario <= 0 and ( (info = 'Baseline' and Y is not null) or (info = 'Median') ) order by pointID asc"
end function

function SQL_READ_RESULTPOINTS(stepID)
	SQL_READ_RESULTPOINTS = "Select scenario, X, Y, Z, info from T_FTA_METHOD_TIA_RESULT where stepID="&stepID&" and scenario <= 0 order by info"
end function

function SQL_READ_ALL_RESULTPOINTS(stepID)
	SQL_READ_ALL_RESULTPOINTS = "Select scenario, X, Y, Z from T_FTA_METHOD_TIA_RESULT where stepID="&stepID&" and scenario > 0 order by scenario, x"
end function

function SQL_READ_X_FORECAST(stepID)
	SQL_READ_X_FORECAST = "Select pointID, X from T_FTA_METHOD_TIA_RESULT where stepID="&stepID&" and scenario = 0 order by X"
end function

function SQL_READ_Z_FORECAST(stepID, x)
	SQL_READ_Z_FORECAST = "Select Z from T_FTA_METHOD_TIA_RESULT where stepID="&stepID&" and X = "&X&" and scenario > 0 order by Z"
end function

function SQL_DELETE_ALL_RESULTPOINTS(stepID)
	SQL_DELETE_ALL_RESULTPOINTS = "Delete from T_FTA_METHOD_TIA_RESULT where stepID='"+stepID+"'"
end function


function SQL_UPDATE_DATASOURCE(stepID, source)
	SQL_UPDATE_DATASOURCE = "UPDATE T_FTA_METHOD_TIA_INFORMATION SET source='"+source+"' WHERE stepID='"+stepID+"'"
end function


function SQL_READ_FILENAME(stepID)
	SQL_READ_FILENAME = "Select * from T_STEP_SUPPORTING_INFORMATION where stepID='"+stepID+"'"
end function


function SQL_CREATE_EVENT(eventID, stepID, title, description, probability, max_impact, ss_impact, max_time, ss_time)
	SQL_CREATE_EVENT = "INSERT INTO T_FTA_METHOD_TIA_EVENTS (eventID, stepID, title, description, probability, max_impact, ss_impact, max_time, ss_time) VALUES ("&eventID&","&stepID&",'"&title&"','"&description&"',"&probability&","&max_impact&","&ss_impact&","&max_time&","&ss_time&")"
end function

function SQL_READ_EVENT(eventID, stepID)
	SQL_READ_EVENT = "Select * from T_FTA_METHOD_TIA_EVENTS where eventID="&eventID&" and stepID="&stepID
end function

function SQL_READ_EVENTS(stepID)
	SQL_READ_EVENTS = "Select * from T_FTA_METHOD_TIA_EVENTS where stepID="&stepID&" order by eventID asc"
end function

function SQL_UPDATE_EVENT(eventID, stepID, title, description, probability, max_impact, ss_impact, max_time, ss_time)
	SQL_UPDATE_EVENT = "UPDATE T_FTA_METHOD_TIA_EVENTS SET title='"&title&"', description='"&description&"', probability="&probability&", max_impact="&max_impact&", ss_impact="&ss_impact&", max_time="&max_time&", ss_time="&ss_time&" WHERE eventID="&eventID&" and stepID="&stepID
end function

function SQL_DELETE_EVENT(eventID, stepID)
	SQL_DELETE_EVENT = "DELETE FROM T_FTA_METHOD_TIA_EVENTS  WHERE eventID="&eventID&" and stepID="&stepID
end function


function SQL_LIST_EXTRAPOLATION_INFORMATION(stepID)
	SQL_LIST_EXTRAPOLATION_INFORMATION = "Select * from T_FTA_METHOD_EXTRAPOLATION_INFORMATION where stepID in (select stepID from T_WORKFLOW_STEP where workflowID in (select workflowID from T_WORKFLOW_STEP where stepID = " & stepID & "))"
end function

function SQL_READ_EXTRAPOLATION_INFORMATION(stepID)
	SQL_READ_EXTRAPOLATION_INFORMATION = "Select * from T_FTA_METHOD_EXTRAPOLATION_INFORMATION where stepID='"+stepID+"'"
end function

function SQL_READ_EXTRAPOLATION_POINTS(stepID)
	SQL_READ_EXTRAPOLATION_POINTS = "Select * from T_FTA_METHOD_EXTRAPOLATION_POINTS where stepID='"+stepID+"' order by pointID asc"
end function

%>