<%

function SQL_CONSULTA_BIBLIOMETRICS(stepID)
	SQL_CONSULTA_BIBLIOMETRICS = "Select * from T_FTA_METHOD_BIBLIOMETRICS where stepID="+stepID
end function

function SQL_CONSULTA_BIBLIOMETRICS_FILTER(stepID, filter)
	SQL_CONSULTA_BIBLIOMETRICS_FILTER = "Select * from T_FTA_METHOD_BIBLIOMETRICS b JOIN T_FTA_METHOD_BIBLIOMETRICS_REFERENCE_X_TAG t on b.referenceID = t.referenceID where stepID="+stepID + " and t.tagID = " + filter
end function




function SQL_CONSULTA_BIBLIOMETRICS_REFERENCE(referenceID)
	SQL_CONSULTA_BIBLIOMETRICS_REFERENCE = "Select * from T_FTA_METHOD_BIBLIOMETRICS where referenceID="+referenceID
end function

function SQL_CONSULTA_BIBLIOMETRICS_AUTHORS(referenceID)
	SQL_CONSULTA_BIBLIOMETRICS_AUTHORS = "Select * from T_FTA_METHOD_BIBLIOMETRICS_AUTHORS where referenceID="+referenceID + "order by authorID"
end function

function SQL_CONSULTA_BIBLIOMETRICS_TAGS_LIST_PER_REFERENCE(referenceID)
	SQL_CONSULTA_BIBLIOMETRICS_TAGS_LIST_PER_REFERENCE = "Select * from T_FTA_METHOD_BIBLIOMETRICS_TAGS t JOIN T_FTA_METHOD_BIBLIOMETRICS_REFERENCE_X_TAG r on r.referenceID = t.referenceID where r.referenceID="+referenceID
end function

function SQL_CONSULTA_BIBLIOMETRICS_TAGS_LIST_PER_STEP_ID(stepID)
	SQL_CONSULTA_BIBLIOMETRICS_TAGS_LIST_PER_STEP_ID = "Select * from T_FTA_METHOD_BIBLIOMETRICS_TAGS where stepID="+stepID + "order by tag"
end function

function SQL_CONSULTA_BIBLIOMETRICS_TAGS_LIST_PER_STEP_ID_AND_TAG(stepID, tag)
	SQL_CONSULTA_BIBLIOMETRICS_TAGS_LIST_PER_STEP_ID_AND_TAG = "Select * from T_FTA_METHOD_BIBLIOMETRICS_TAGS where stepID="+stepID + " and tag='"+tag +"'"
end function

function SQL_CONSULTA_BIBLIOMETRICS_REFERENCE_X_TAG_BY_TAG_ID(tagID)
	SQL_CONSULTA_BIBLIOMETRICS_REFERENCE_X_TAG_BY_TAG_ID = "Select * from T_FTA_METHOD_BIBLIOMETRICS_REFERENCE_X_TAG where tagID="+tagID
end function

function SQL_CONSULTA_BIBLIOMETRICS_REFERENCE_X_TAG(referenceID)
	SQL_CONSULTA_BIBLIOMETRICS_REFERENCE_X_TAG = "Select * from T_FTA_METHOD_BIBLIOMETRICS_REFERENCE_X_TAG where referenceID="+referenceID
end function



function SQL_ATUALIZA_REFERENCE(referenceID, title, year)
	Dim strYear
	strYear = ""
	if 	year <> "" then 'year é opcional
	 strYear = ", year= " + year
	end if 
	SQL_ATUALIZA_REFERENCE = "UPDATE T_FTA_METHOD_BIBLIOMETRICS SET title = '"+title+"'" + strYear + " WHERE referenceID="+referenceID
end function

function SQL_CRIA_REFERENCE(stepID, title, year)
	SQL_CRIA_REFERENCE = "INSERT INTO T_FTA_METHOD_BIBLIOMETRICS (stepID,title,year) VALUES ('"+stepID+"','"+title+"',"+year+")" 
end function



function SQL_DELETE_AUTHORS(referenceID)
	SQL_DELETE_AUTHORS = "DELETE FROM T_FTA_METHOD_BIBLIOMETRICS_AUTHORS where referenceID="+referenceID
end function

function SQL_DELETE_REFERENCE(referenceID)
	SQL_DELETE_REFERENCE = "DELETE FROM T_FTA_METHOD_BIBLIOMETRICS where referenceID="+referenceID
end function

function SQL_DELETE_REFERENCE_X_TAG(referenceID)
	SQL_DELETE_REFERENCE_X_TAG = "DELETE FROM T_FTA_METHOD_BIBLIOMETRICS_REFERENCE_X_TAG where referenceID="+referenceID
end function

function SQL_DELETE_TAG(tagID)
	SQL_DELETE_TAG = "DELETE FROM T_FTA_METHOD_BIBLIOMETRICS_TAGS where tagID="+tagID
end function



function SQL_ADICIONA_REFERENCE_X_TAG(referenceID, tagID)
	SQL_ADICIONA_REFERENCE_X_TAG = "INSERT INTO T_FTA_METHOD_BIBLIOMETRICS_REFERENCE_X_TAG (referenceID,tagID) VALUES ("+referenceID+","+tagID+")" 
end function

function SQL_ADICIONA_AUTHOR(referenceID, author)
	SQL_ADICIONA_AUTHOR = "INSERT INTO T_FTA_METHOD_BIBLIOMETRICS_AUTHORS (referenceID,name) VALUES ("+referenceID+",'"+author+"')" 
end function

function SQL_ADICIONA_FILE(referenceID, file_path)
	SQL_ADICIONA_FILE = "UPDATE T_FTA_METHOD_BIBLIOMETRICS SET file_path = '"+file_path+"' WHERE referenceID="+referenceID
end function

function SQL_ADICIONA_TAG(stepID, tagName)
	SQL_ADICIONA_TAG = "INSERT INTO T_FTA_METHOD_BIBLIOMETRICS_TAGS (stepID,tag) VALUES ("+stepID+",'"+tagName+"')" 
end function

%>