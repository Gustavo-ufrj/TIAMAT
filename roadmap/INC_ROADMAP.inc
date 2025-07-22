<%

CONST EXHIBITION_YEAR = 0
CONST EXHIBITION_MONTH = 1
CONST EXHIBITION_DAY = 2

function SQL_CONSULTA_ROADMAP(stepID)
	SQL_CONSULTA_ROADMAP = "Select * from T_FTA_METHOD_ROADMAP where stepID="+stepID
end function

function SQL_CONSULTA_ROADMAP_ROADMAP_ID(roadmapID)
	SQL_CONSULTA_ROADMAP_ROADMAP_ID = "Select * from T_FTA_METHOD_ROADMAP where roadmapID="+roadmapID
end function


function SQL_ATUALIZA_ROADMAP(roadmapID, title, description, exhibition)
	SQL_ATUALIZA_ROADMAP = "UPDATE T_FTA_METHOD_ROADMAP SET description = '"+description+"', title= '"+title+"', exhibition = "+exhibition+" WHERE roadmapID="+roadmapID
end function

function SQL_CRIA_ROADMAP(stepID, title, description, exhibition)
	SQL_CRIA_ROADMAP = "INSERT INTO T_FTA_METHOD_ROADMAP (stepID, title, description, exhibition) VALUES ('"+stepID+"','"+title+"','"+description+"', "+exhibition+")" 
end function

function SQL_CONSULTA_ROADMAP_EVENTS(roadmapID)
	SQL_CONSULTA_ROADMAP_EVENTS = "Select eventID, event, CONVERT(char(10), date,126) as date from T_FTA_METHOD_ROADMAP_EVENT where roadmapID="+roadmapID
end function

function SQL_CONSULTA_ROADMAP_EVENTS_SORTING(roadmapID, sorting)
	SQL_CONSULTA_ROADMAP_EVENTS_SORTING = SQL_CONSULTA_ROADMAP_EVENTS(roadmapID) + " Order By " + sorting
end function

function SQL_CONSULTA_ROADMAP_EVENT_BY_EVENTID(eventID)
	SQL_CONSULTA_ROADMAP_EVENT_BY_EVENTID = "Select eventID, event, CONVERT(char(10), date,126) as date from T_FTA_METHOD_ROADMAP_EVENT where eventID="+eventID
end function


function SQL_ATUALIZA_ROADMAP_EVENT(eventID, d, ev)
	SQL_ATUALIZA_ROADMAP_EVENT = "UPDATE T_FTA_METHOD_ROADMAP_EVENT SET date = CONVERT(datetime, '"+d+"', 126), event= '"+ev+"' WHERE eventID="+eventID
end function

function SQL_DELETE_ROADMAP_EVENT(eventID)
	SQL_DELETE_ROADMAP_EVENT = "DELETE FROM T_FTA_METHOD_ROADMAP_EVENT WHERE eventID="+eventID
end function


function FormatExhibition (EventDate, ChosenFormat)

	select case ChosenFormat
	case EXHIBITION_YEAR 
		FormatExhibition = cstr(year(EventDate))
	case EXHIBITION_MONTH 
		FormatExhibition = cstr(year(EventDate)) + "-" + cstr(month(EventDate))
	case EXHIBITION_DAY
		FormatExhibition = cstr(EventDate)
	case else 
		FormatExhibition = cstr(EventDate)
	end select
	
end function
%>