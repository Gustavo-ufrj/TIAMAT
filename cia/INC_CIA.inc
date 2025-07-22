<%

function SQL_CONSULTA_CIA(stepID)
	SQL_CONSULTA_CIA = "Select * from T_FTA_METHOD_CROSS_IMPACT where stepID="+stepID
end function

function SQL_CRIA_CIA(stepID, description, tipo)
	SQL_CRIA_CIA = "INSERT INTO T_FTA_METHOD_CROSS_IMPACT (stepID, description, tipo) VALUES ('"+stepID+"','"+description+"','"+tipo+"')" 
end function

function SQL_ATUALIZA_CIA(stepID, description, tipo)
	SQL_ATUALIZA_CIA = "UPDATE T_FTA_METHOD_CROSS_IMPACT SET description='"+description+"', tipo='"+tipo+"' WHERE stepID="+stepID
end function



function SQL_CONSULTA_EVENT(CIAID)
	SQL_CONSULTA_EVENT = "Select * from T_FTA_METHOD_CROSS_IMPACT_EVENTS where CIAID="+CIAID +"order by eventID"
end function
		 
function SQL_CONSULTA_EVENT_BY_EVENTID(eventID)
	SQL_CONSULTA_EVENT_BY_EVENTID = "Select * from T_FTA_METHOD_CROSS_IMPACT_EVENTS where eventID="+eventID
end function

function SQL_ATUALIZA_EVENT(eventID, even, probability)
	SQL_ATUALIZA_EVENT = "UPDATE T_FTA_METHOD_CROSS_IMPACT_EVENTS SET event='"+even+"', defaultprobability='"+probability+"' WHERE eventID="+eventID
end function

function SQL_DELETE_EVENT(eventID)
	SQL_DELETE_EVENT = "DELETE FROM T_FTA_METHOD_CROSS_IMPACT_EVENTS WHERE eventID="+eventID
end function



function SQL_CONSULTA_EVENT_X_EVENT(causeID, effectID)
	SQL_CONSULTA_EVENT_X_EVENT = "Select * from T_FTA_METHOD_CROSS_IMPACT_EVENTS_X_EVENTS where causeID='"+causeID+"' AND effectID="+effectID
end function

function SQL_CRIA_EVENT_X_EVENT(causeID, effectID, probability, CIAID)
	SQL_CRIA_EVENT_X_EVENT = "INSERT INTO T_FTA_METHOD_CROSS_IMPACT_EVENTS_X_EVENTS (causeID, effectID, probability, CIAID) VALUES ('"+causeID+"','"+effectID+"','"+probability+"','"+CIAID+"')" 
end function

function SQL_ATUALIZA_EVENT_X_EVENT(causeID, effectID, probability)
	SQL_ATUALIZA_EVENT_X_EVENT = "UPDATE T_FTA_METHOD_CROSS_IMPACT_EVENTS_X_EVENTS SET probability = '"+probability+"' WHERE causeID='"+causeID+"' AND effectID="+effectID
end function

function SQL_DELETE_EVENT_X_EVENT(CIAID)
	SQL_DELETE_EVENT_X_EVENT = "DELETE FROM T_FTA_METHOD_CROSS_IMPACT_EVENTS_X_EVENTS WHERE CIAID="+CIAID
end function

function SQL_DELETE_EVENT_X_EVENT_BY_EVENTID(eventID)
	SQL_DELETE_EVENT_X_EVENT_BY_EVENTID = "DELETE FROM T_FTA_METHOD_CROSS_IMPACT_EVENTS_X_EVENTS WHERE effectID='"+eventID+"' OR causeID="+eventID
end function

function SQL_DELETE_EVENT_X_EVENT_CAUSEID_EFFECTID(causeID, effectID)
	SQL_DELETE_EVENT_X_EVENT_CAUSEID_EFFECTID = "DELETE FROM T_FTA_METHOD_CROSS_IMPACT_EVENTS_X_EVENTS WHERE effectID='"+effectID+"' AND causeID="+causeID
end function
%>