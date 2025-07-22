<%

const STATUS_NEW = 1
const STATUS_DISCUSSION = 2
const STATUS_VOTING = 3

class BrainstormingAction 
	private image_Source
	private image_Description
	private action_TAG
	private showSTATE
	
	Public Function Init(s, d, a, ss)
         image_Source = s
         image_Description = d
         action_TAG = a
		 showSTATE = ss
         Set Init = Me
     End Function

	
	Public Property Get ImageSource()
		ImageSource = image_Source
	End Property

	Public Property Let ImageSource(p_Data)
		image_Source = p_Data
	End Property

	Public Property Get ImageDescription()
		ImageDescription = image_Description
	End Property

	Public Property Let ImageDescription(p_Data)
		image_Description = p_Data
	End Property

	Public Property Get Action()
		Action = action_TAG
	End Property

	Public Property Let Action(p_Data)
		action_TAG = p_Data
	End Property

	Public Property Get STATE()
		STATE = showSTATE
	End Property

	Public Property Let STATE(p_Data)
		showSTATE = p_Data
	End Property

end class 

function SQL_CONSULTA_BRAINSTORMING(stepID)
	SQL_CONSULTA_BRAINSTORMING = "Select * from T_FTA_METHOD_BRAINSTORMING where stepID="+stepID
end function

function SQL_CONSULTA_BRAINSTORMING_BRAINSTORMING_ID(brainstormingID)
	SQL_CONSULTA_BRAINSTORMING_BRAINSTORMING_ID = "Select * from T_FTA_METHOD_BRAINSTORMING where brainstormingID="+brainstormingID
end function

function SQL_CONSULTA_BRAINSTORMING_FILTER(stepID, filter)
	SQL_CONSULTA_BRAINSTORMING_FILTER = "Select * from T_FTA_METHOD_BRAINSTORMING b JOIN T_FTA_METHOD_BRAINSTORMING_IDEAS i on b.brainstormingID = i.brainstormingID where stepID="+stepID + " and i.status = " + cstr(filter)
end function

function SQL_CONSULTA_BRAINSTORMING_FILTER_ORDERED(stepID, filter)
	SQL_CONSULTA_BRAINSTORMING_FILTER_ORDERED = "SELECT  i.*, count(v.ideaID) as votes FROM  T_FTA_METHOD_BRAINSTORMING b JOIN T_FTA_METHOD_BRAINSTORMING_IDEAS i on b.brainstormingID = i.brainstormingID LEFT JOIN T_FTA_METHOD_BRAINSTORMING_VOTING v on v.ideaID = i.ideaID WHERE b.stepID="+stepID + " and i.status = " + cstr(filter) + " and v.email IN (SELECT email from T_WORKFLOW_STEP_X_USER WHERE stepID=b.stepID) GROUP BY i.ideaID, i.email, i.dateTime, i.title, i.description, i.status, i.brainstormingID ORDER BY votes DESC"
end function

function SQL_CONSULTA_BRAINSTORMING_TOTAL_VOTES(brainstormingID)
	SQL_CONSULTA_BRAINSTORMING_TOTAL_VOTES = "Select count(v.ideaID) as votes FROM T_FTA_METHOD_BRAINSTORMING_VOTING v JOIN T_FTA_METHOD_BRAINSTORMING_IDEAS i ON i.ideaID=v.ideaID where i.brainstormingID="+brainstormingID+" and v.email IN (SELECT email from T_WORKFLOW_STEP_X_USER u JOIN T_FTA_METHOD_BRAINSTORMING b ON b.stepID=u.stepID WHERE b.brainstormingID=i.brainstormingID)"
	end function

function SQL_CONSULTA_BRAINSTORMING_COMMENT_TOTAL_VOTES(ideaID)
	SQL_CONSULTA_BRAINSTORMING_COMMENT_TOTAL_VOTES = "Select count(ideaID) as votes FROM T_FTA_METHOD_BRAINSTORMING_VOTING where ideaID="+ideaID
end function


function SQL_CONSULTA_BRAINSTORMING_PERSON_VOTES(stepID)
	SQL_CONSULTA_BRAINSTORMING_PERSON_VOTES = "SELECT DISTINCT u.email, votes=(SELECT count(v.ideaID) FROM T_FTA_METHOD_BRAINSTORMING_IDEAS i JOIN T_FTA_METHOD_BRAINSTORMING_VOTING v on v.ideaID = i.ideaID  WHERE  v.ideaID IN (SELECT DISTINCT i.ideaID from T_FTA_METHOD_BRAINSTORMING b JOIN T_FTA_METHOD_BRAINSTORMING_IDEAS i on i.brainstormingID = b.brainstormingID WHERE b.stepID=u.stepID) and u.email = v.email) from T_WORKFLOW_STEP_X_USER u WHERE u.stepID=" + stepID + " ORDER BY votes DESC"
end function





function SQL_CONSULTA_BRAINSTORMING_VOTE(ideaID, email)
	SQL_CONSULTA_BRAINSTORMING_VOTE = "Select * from T_FTA_METHOD_BRAINSTORMING_VOTING where ideaID="+ideaID + " and email = '" + email +"'"
end function


function SQL_CONSULTA_BRAINSTORMING_VOTES_PER_USER(stepID, email)
	SQL_CONSULTA_BRAINSTORMING_VOTES_PER_USER = "Select * from T_FTA_METHOD_BRAINSTORMING_VOTING v JOIN T_FTA_METHOD_BRAINSTORMING_IDEAS i ON v.ideaID = i.ideaID  JOIN T_FTA_METHOD_BRAINSTORMING b ON b.brainstormingID = i.brainstormingID where b.stepID="+stepID + " and v.email = '" + email +"'"
end function


function SQL_ATUALIZA_BRAINSTORMING(brainstormingID, description, votingPoints)
	SQL_ATUALIZA_BRAINSTORMING = "UPDATE T_FTA_METHOD_BRAINSTORMING SET description = '"+description+"', votingPoints= "+votingPoints+" WHERE brainstormingID="+brainstormingID
end function

function SQL_CRIA_BRAINSTORMING(stepID, description, votingPoints)
	SQL_CRIA_BRAINSTORMING = "INSERT INTO T_FTA_METHOD_BRAINSTORMING (stepID,description,votingPoints) VALUES ('"+stepID+"','"+description+"',"+votingPoints+")" 
end function


function SQL_CONSULTA_BRAINSTORMING_IDEA(ideaID)
	SQL_CONSULTA_BRAINSTORMING_IDEA = "Select * from T_FTA_METHOD_BRAINSTORMING_IDEAS where ideaID="+ideaID 
end function


function SQL_CONSULTA_BRAINSTORMING_DISCUSSION(ideaID)
	SQL_CONSULTA_BRAINSTORMING_DISCUSSION = "Select * from T_FTA_METHOD_BRAINSTORMING_DISCUSSION where ideaID="+ideaID 
end function

function SQL_CONSULTA_BRAINSTORMING_DISCUSSION_COMMENT_ID(commentID)
	SQL_CONSULTA_BRAINSTORMING_DISCUSSION_COMMENT_ID = "Select * from T_FTA_METHOD_BRAINSTORMING_DISCUSSION where commentID="+commentID 
end function


function SQL_CRIA_BRAINSTORMING_IDEA(brainstormingID, email, title, description)
	SQL_CRIA_BRAINSTORMING_IDEA = "INSERT INTO T_FTA_METHOD_BRAINSTORMING_IDEAS (brainstormingID, email, title, description) VALUES ("+brainstormingID+", '" + email + "','" + title + "','" + description + "')" 
end function

function SQL_ATUALIZA_BRAINSTORMING_IDEA(ideaID, title, description)
	SQL_ATUALIZA_BRAINSTORMING_IDEA = "UPDATE T_FTA_METHOD_BRAINSTORMING_IDEAS SET description = '"+description+"', title= '"+title+"' WHERE ideaID="+ideaID
end function

function SQL_ATUALIZA_BRAINSTORMING_STATUS(ideaID, status)
	SQL_ATUALIZA_BRAINSTORMING_STATUS = "UPDATE T_FTA_METHOD_BRAINSTORMING_IDEAS SET status = "+status+" WHERE ideaID="+ideaID
end function



function SQL_CRIA_BRAINSTORMING_DISCUSSION(ideaID, email, title, message)
	SQL_CRIA_BRAINSTORMING_DISCUSSION = "INSERT INTO T_FTA_METHOD_BRAINSTORMING_DISCUSSION (ideaID, email, title, message) VALUES ("+ideaID+", '" + email + "','" + title + "','" + message + "')" 
end function

function SQL_ATUALIZA_BRAINSTORMING_DISCUSSION(commentID, title, message)
	SQL_ATUALIZA_BRAINSTORMING_DISCUSSION = "UPDATE T_FTA_METHOD_BRAINSTORMING_DISCUSSION SET message = '"+message+"', title= '"+title+"' WHERE commentID="+commentID
end function



function SQL_ADICIONA_VOTE(ideaID, email)
	SQL_ADICIONA_VOTE = "INSERT INTO T_FTA_METHOD_BRAINSTORMING_VOTING (ideaID,email) VALUES ("+ideaID+",'"+email+"')" 
end function

function SQL_DELETE_VOTE(ideaID, email)
	SQL_DELETE_VOTE = "DELETE FROM T_FTA_METHOD_BRAINSTORMING_VOTING where email= '"+email+"' and ideaID="+ideaID
end function

function SQL_DELETE_IDEA(ideaID)
	SQL_DELETE_IDEA = "DELETE FROM T_FTA_METHOD_BRAINSTORMING_IDEAS where ideaID="+ideaID
end function



%>