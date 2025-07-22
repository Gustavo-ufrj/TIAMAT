<%

function SQL_CREATE_POINT(pointID, stepID, x, y)
	SQL_CREATE_POINT = "INSERT INTO T_FTA_METHOD_EXTRAPOLATION_POINTS (pointID, stepID, x, y) VALUES ("&pointID&","&stepID&","&x&","&y&")"
end function

function SQL_READ_POINT(pointID, stepID)
	SQL_READ_POINT = "Select * from T_FTA_METHOD_EXTRAPOLATION_POINTS where pointID="&pointID&" and stepID="&stepID
end function

function SQL_READ_POINTS(stepID)
	SQL_READ_POINTS = "Select * from T_FTA_METHOD_EXTRAPOLATION_POINTS where stepID="&stepID&" order by X asc"
end function

function SQL_READ_POINTS_FOR_GRAPH(stepID)
	SQL_READ_POINTS_FOR_GRAPH = "Select x, y from T_FTA_METHOD_EXTRAPOLATION_POINTS where stepID='"&stepID&"' order by x,y asc"
end function

function SQL_UPDATE_POINT(pointID, stepID, x, y)
	SQL_UPDATE_POINT = "UPDATE T_FTA_METHOD_EXTRAPOLATION_POINTS SET x="&x&", y="&y&" WHERE pointID="&pointID&" and stepID="&stepID
end function

function SQL_DELETE_POINT(pointID, stepID)
	SQL_DELETE_POINT = "DELETE FROM T_FTA_METHOD_EXTRAPOLATION_POINTS where pointID="&pointID&" and stepID="&stepID
end function

function SQL_DELETE_ALL_POINTS(stepID)
	SQL_DELETE_ALL_POINTS = "Delete from T_FTA_METHOD_EXTRAPOLATION_POINTS where stepID='"&stepID&"'"
end function

function SQL_CREATE_INFORMATION(stepID, x_name, x_desc, y_name, y_desc, adj_type, range, source)
	SQL_CREATE_INFORMATION = "INSERT INTO T_FTA_METHOD_EXTRAPOLATION_INFORMATION (stepID,x_name,x_desc,y_name,y_desc,adj_type,range,source) VALUES ('"&stepID&"','"&x_name&"','"&x_desc&"','"&y_name&"','"&y_desc&"','"&adj_type&"','"&range&"','"&source&"')" 
end function

function SQL_READ_INFORMATION(stepID)
	SQL_READ_INFORMATION = "Select * from T_FTA_METHOD_EXTRAPOLATION_INFORMATION where stepID='"&stepID&"'"
end function

function SQL_UPDATE_INFORMATION(stepID, x_name, x_desc, y_name, y_desc, adj_type, range, source)
	SQL_UPDATE_INFORMATION = "UPDATE T_FTA_METHOD_EXTRAPOLATION_INFORMATION SET x_name='"&x_name&"', x_desc='"&x_desc&"', y_name='"&y_name&"', y_desc='"&y_desc&"', adj_type='"&adj_type&"',range='"&range&"',source='"&source&"' WHERE stepID='"&stepID&"'"
end function

function SQL_UPDATE_PARAMETERS(stepID, parameters)
	SQL_UPDATE_PARAMETERS = "UPDATE T_FTA_METHOD_EXTRAPOLATION_INFORMATION SET parameters='"&parameters&"' WHERE stepID='"&stepID&"'"
end function

function SQL_CREATE_RESULTPOINT(pointID, stepID, x, y, z)
	if y then
		SQL_CREATE_RESULTPOINT = "INSERT INTO T_FTA_METHOD_EXTRAPOLATION_RESULT (pointID, stepID, X, Y, Z) VALUES ('"&pointID&"','"&stepID&"','"&x&"','"&y&"','"&z&"')"
	else 
		SQL_CREATE_RESULTPOINT = "INSERT INTO T_FTA_METHOD_EXTRAPOLATION_RESULT (pointID, stepID, X, Y, Z) VALUES ('"&pointID&"','"&stepID&"','"&x&"',null,'"&z&"')"
	end if
end function

function SQL_READ_RESULT(stepID)
	SQL_READ_RESULT = "Select pointID, stepID, X, Y, case when y is null then Z else null end as Z from T_FTA_METHOD_EXTRAPOLATION_RESULT where stepID="&stepID&" order by pointID asc"
end function

function SQL_READ_RESULTPOINTS(stepID)
	SQL_READ_RESULTPOINTS = "Select pointID, stepID, X, Y, Z from T_FTA_METHOD_EXTRAPOLATION_RESULT where stepID='"&stepID&"' order by pointID asc"
end function

function SQL_DELETE_ALL_RESULTPOINTS(stepID)
	SQL_DELETE_ALL_RESULTPOINTS = "Delete from T_FTA_METHOD_EXTRAPOLATION_RESULT where stepID='"&stepID&"'"
end function

function SQL_UPDATE_DATASOURCE(stepID, source)
	SQL_UPDATE_DATASOURCE = "UPDATE T_FTA_METHOD_EXTRAPOLATION_INFORMATION SET source='"&source&"' WHERE stepID='"&stepID&"'"
end function

function SQL_DELETE_INFORMATION(stepID)
	SQL_DELETE_INFORMATION = "Delete from T_FTA_METHOD_EXTRAPOLATION_INFORMATION where stepID='"&stepID&"'"
end function

function SQL_READ_FILENAME(stepID)
	SQL_READ_FILENAME = "Select * from T_STEP_SUPPORTING_INFORMATION where stepID='"&stepID&"'"
end function

%>