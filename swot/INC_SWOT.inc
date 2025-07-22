<%

function SQL_CONSULTA_SWOT(stepID)
	SQL_CONSULTA_SWOT = "Select * from T_FTA_METHOD_SWOT where stepID="+stepID
end function



function SQL_ATUALIZA_SWOT(stepID, strengths, weakness, opportunities, threats)
	SQL_ATUALIZA_SWOT = "UPDATE T_FTA_METHOD_SWOT SET strengths='"+strengths+"', weakness='"+weakness+"', opportunities = '"+opportunities+"', threats= '"+threats+"' WHERE stepID="+stepID
end function

function SQL_CRIA_SWOT(stepID, strengths, weakness, opportunities, threats)
	SQL_CRIA_SWOT = "INSERT INTO T_FTA_METHOD_SWOT (stepID,strengths,weakness,opportunities,threats) VALUES ('"+stepID+"','"+strengths+"','"+weakness+"','"+opportunities+"','"+threats+"')" 
end function

%>