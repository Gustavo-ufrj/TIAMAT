<%

function SQL_CONSULTA_SCENARIOS(stepID)
	SQL_CONSULTA_SCENARIOS = "SELECT * FROM T_FTA_METHOD_SCENARIOS where stepID="+stepID
end function

function SQL_CONSULTA_SCENARIOS_BY_SCENARIO_ID(scenarioID)
	SQL_CONSULTA_SCENARIOS_BY_SCENARIO_ID = "Select * from T_FTA_METHOD_SCENARIOS where scenarioID="+scenarioID
end function


function SQL_ATUALIZA_SCENARIO(scenarioID, name, description, scenario)
	set cmd = getSQLCommand()
	cmd.CommandText = "UPDATE T_FTA_METHOD_SCENARIOS SET name=?, description=?, scenario = ? WHERE scenarioID=?"
	cmd.Parameters.Refresh
	cmd.Parameters(0).Value = name
	cmd.Parameters(1).Value = description
	cmd.Parameters(2).Value = scenario
	cmd.Parameters(3).Value = scenarioID
	
	set SQL_ATUALIZA_SCENARIO = cmd
end function

function SQL_CRIA_SCENARIO(stepID, name, description, scenario)
	set cmd = getSQLCommand()
	cmd.CommandText = "INSERT INTO T_FTA_METHOD_SCENARIOS (stepID, name, description, scenario) VALUES (?,?,?,?)" 
	cmd.Parameters.Refresh
	cmd.Parameters(0).Value = stepID
	cmd.Parameters(1).Value = name
	cmd.Parameters(2).Value = description
	cmd.Parameters(3).Value = scenario

	set SQL_CRIA_SCENARIO = cmd
end function



function SQL_DELETE_SCENARIO(scenarioID)
	SQL_DELETE_SCENARIO = "DELETE FROM T_FTA_METHOD_SCENARIOS where scenarioID="+scenarioID
end function



'function SQL_ATUALIZA_SCENARIO(scenarioID, name, description, scenario)
'	SQL_ATUALIZA_SCENARIO = "UPDATE T_FTA_METHOD_SCENARIOS SET name='"+name+"', description='"+description+"', scenario = '"+scenario+"' WHERE scenarioID="+scenarioID
'end function

'function SQL_CRIA_SCENARIO(stepID, name, description, scenario)
'	SQL_CRIA_SCENARIO = "INSERT INTO T_FTA_METHOD_SCENARIOS (stepID, name, description, scenario) VALUES ("+stepID+",'"+name+"','"+description+"','"+scenario+"')" 
'end function

%>