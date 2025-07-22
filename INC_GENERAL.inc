<%
'Verifica se o usuário que está logando existe no sistema 
function SQL_CONSULTA_USUARIO_LOGIN(user, pwd)
	SQL_CONSULTA_USUARIO_LOGIN = "Select * from T_USER u where u.email='"+user+"' and u.passhash='"+ pwd +"'"
end function


'Retorna todos os usuários
function SQL_CONSULTA_USUARIO_TODOS()
	SQL_CONSULTA_USUARIO_TODOS = "Select * from T_USER order by name"
end function


'Salva uma nova foto
function SQL_ATUALIZA_FOTO(user, photo)
	SQL_ATUALIZA_FOTO = "UPDATE T_USER SET photo='"+photo+"' WHERE email='"+user+"'"
end function


'Salva o profile do usuário
function SQL_ATUALIZA_PROFILE(user, name, pwd)
	SQL_ATUALIZA_PROFILE = "UPDATE T_USER SET name='"+name+"', passhash='"+pwd+"' WHERE email='"+user+"'"
end function


'Salva o password do usuário
function SQL_ATUALIZA_PASSWORD(user, pwd)
	SQL_ATUALIZA_PASSWORD = "UPDATE T_USER SET passhash='"+pwd+"' WHERE email='"+user+"'"
end function


'Salva o usuário administramente
function SQL_ATUALIZA_USUARIO(user, name, pwd,ftacreator, isadmin)
	SQL_ATUALIZA_USUARIO = "UPDATE T_USER SET name='"+name+"', passhash='"+pwd+"', ftacreator = '"+ftacreator+"', admin= '"+isadmin+"' WHERE email='"+user+"'"
end function

'Salva o usuário administramente, sem mudar senha
function SQL_ATUALIZA_USUARIO_SEM_SENHA(user, name, ftacreator, isadmin)
	SQL_ATUALIZA_USUARIO_SEM_SENHA = "UPDATE T_USER SET name='"+name+"', ftacreator = '"+ftacreator+"', admin= '"+isadmin+"' WHERE email='"+user+"'"
end function


' Cria um novo usuário
function SQL_CRIA_USUARIO(email, name, password, ftacreator, isadmin)
	SQL_CRIA_USUARIO = "INSERT INTO T_USER (email, name, passhash, ftacreator, admin, photo ) VALUES ('" + email + "', '" + name + "', '" + password + "', " + ftacreator + ", " + isadmin + ", '/img/defaultuser.jpg')" 
end function

'Verifica se o usuário que está logando existe no sistema 
function SQL_CONSULTA_USUARIO_EMAIL(user)
	SQL_CONSULTA_USUARIO_EMAIL = "Select * from T_USER u where u.email='"+user+"'"
end function

'Remove um usuário 
function SQL_DELETE_USUARIO_EMAIL(user)
	SQL_DELETE_USUARIO_EMAIL = "DELETE from T_USER where email='"+user+"'"
end function

'Coleta os Dados do Workflow
function SQL_CONSULTA_WORKFLOW_ID(workflowID)
	SQL_CONSULTA_WORKFLOW_ID = "Select * from T_WORKFLOW where workflowID="+workflowID
end function


'Coleta os Dados do Workflow
function SQL_CONSULTA_WORKFLOW_JOIN_USER()
	SQL_CONSULTA_WORKFLOW_JOIN_USER = "Select T_WORKFLOW.*, T_USER.name, (CASE T_WORKFLOW.status  WHEN 1 THEN 3  WHEN 2 THEN 2 WHEN 3 THEN 1 WHEN 4 THEN 4 ELSE 5 END) as statusorder, COUNT(T_WORKFLOW_STEP.stepID) as steps from T_WORKFLOW LEFT JOIN T_WORKFLOW_STEP ON T_WORKFLOW.workflowID = T_WORKFLOW_STEP.workflowID  JOIN T_USER ON T_WORKFLOW.owner = T_USER.email GROUP BY T_WORKFLOW.workflowID, T_WORKFLOW.description, T_WORKFLOW.goal, T_WORKFLOW.expectedresult, T_WORKFLOW.owner, T_WORKFLOW.parentStepID,  T_WORKFLOW.status, T_USER.name order by statusorder, T_USER.name"
end function



'Coleta os Dados do Workflow
function SQL_CONSULTA_WORKFLOW_BY_OWNER(owner)
	SQL_CONSULTA_WORKFLOW_BY_OWNER = "Select T_WORKFLOW.*, (CASE T_WORKFLOW.status  WHEN 1 THEN 3  WHEN 2 THEN 2 WHEN 3 THEN 1 WHEN 4 THEN 4 ELSE 5 END) as statusorder, COUNT(T_WORKFLOW_STEP.stepID) as steps from T_WORKFLOW LEFT JOIN T_WORKFLOW_STEP ON T_WORKFLOW.workflowID = T_WORKFLOW_STEP.workflowID WHERE owner='"+owner+"' GROUP BY T_WORKFLOW.workflowID, T_WORKFLOW.description, T_WORKFLOW.goal, T_WORKFLOW.expectedresult, T_WORKFLOW.owner, T_WORKFLOW.status, T_WORKFLOW.parentStepID ORDER BY statusorder"
end function


'Coleta os Dados do Workflow
function SQL_CONSULTA_WORKFLOW_ACTIVE_INACTIVE_BY_OWNER(owner)
	SQL_CONSULTA_WORKFLOW_ACTIVE_INACTIVE_BY_OWNER = "Select T_WORKFLOW.*, (CASE T_WORKFLOW.status  WHEN 1 THEN 3  WHEN 2 THEN 2 WHEN 3 THEN 1 WHEN 4 THEN 4 ELSE 5 END) as statusorder, COUNT(T_WORKFLOW_STEP.stepID) as steps from T_WORKFLOW LEFT JOIN T_WORKFLOW_STEP ON T_WORKFLOW.workflowID = T_WORKFLOW_STEP.workflowID WHERE owner='"+owner+"' and T_WORKFLOW.status < 4 GROUP BY T_WORKFLOW.workflowID, T_WORKFLOW.description, T_WORKFLOW.goal, T_WORKFLOW.expectedresult, T_WORKFLOW.owner, T_WORKFLOW.status, T_WORKFLOW.parentStepID ORDER BY statusorder"
end function


'Coleta os Dados do Workflow
function SQL_CONSULTA_WORKFLOW_PENDING_BY_OWNER(owner)
	SQL_CONSULTA_WORKFLOW_PENDING_BY_OWNER = "Select T_WORKFLOW.*, COUNT(T_WORKFLOW_STEP.stepID) as steps from T_WORKFLOW LEFT JOIN T_WORKFLOW_STEP ON T_WORKFLOW.workflowID = T_WORKFLOW_STEP.workflowID WHERE owner='"+owner+"' and T_WORKFLOW.status=4 and NOT EXISTS (SELECT * FROM T_WORKFLOW_SUPPORTING_INFORMATION WHERE T_WORKFLOW.workflowID = T_WORKFLOW_SUPPORTING_INFORMATION.workflowID) GROUP BY T_WORKFLOW.workflowID, T_WORKFLOW.description, T_WORKFLOW.goal, T_WORKFLOW.expectedresult, T_WORKFLOW.owner, T_WORKFLOW.status, T_WORKFLOW.parentStepID"
end function



'Coleta os Dados do Workflow
function SQL_CONSULTA_WORKFLOW_STEPS_X_STEPS(workflowID)
	SQL_CONSULTA_WORKFLOW_STEPS_X_STEPS = "Select * from T_WORKFLOW_STEP_X_STEP ss JOIN T_WORKFLOW_STEP s ON ss.stepID = s.stepID  where s.workflowID=" + workflowID
end function


'Coleta os Dados do Workflow
function SQL_CONSULTA_WORKFLOW_STEPS(workflowID) ' pode estar deprecated
	SQL_CONSULTA_WORKFLOW_STEPS = "Select * from T_WORKFLOW_STEP where workflowID=" + workflowID
end function


'Coleta os Dados do Workflow
function SQL_CONSULTA_WORKFLOW_PRIMARY_STEPS(workflowID)
	SQL_CONSULTA_WORKFLOW_PRIMARY_STEPS = "Select * from T_WORKFLOW_STEP where workflowID=" + workflowID + " and stepID NOT IN (SELECT stepID from T_WORKFLOW_STEP_X_STEP)"
end function


'Coleta os Dados do Workflow
function SQL_CONSULTA_WORKFLOW_SECONDARY_STEPS(workflowID, parentStepID)
	SQL_CONSULTA_WORKFLOW_SECONDARY_STEPS = "Select * from T_WORKFLOW_STEP where workflowID=" + workflowID + " and stepID IN (SELECT stepID from T_WORKFLOW_STEP_X_STEP WHERE parentStepID="+parentStepID + ")"
end function


'Coleta os Dados do Workflow
function SQL_CONSULTA_WORKFLOW_PARENT_STEPS(stepID)
	SQL_CONSULTA_WORKFLOW_PARENT_STEPS = "SELECT parentStepID from T_WORKFLOW_STEP_X_STEP WHERE stepID="+stepID 
end function

'Coleta os Dados do Workflow
function SQL_CONSULTA_WORKFLOW_USERS_BY_STEP_ROLE(stepID, role)
	SQL_CONSULTA_WORKFLOW_USERS_BY_STEP_ROLE = "Select * from T_WORKFLOW_STEP_X_USER JOIN T_USER ON T_WORKFLOW_STEP_X_USER.email = T_USER.email WHERE T_WORKFLOW_STEP_X_USER.stepID=" + stepID + " and T_WORKFLOW_STEP_X_USER.role='" + role + "'"
end function


'Remove um passo do workflow
function SQL_DELETE_WORKFLOW(workflowID)
	SQL_DELETE_WORKFLOW = "DELETE from T_WORKFLOW where workflowID="+workflowID
end function

 
'Remove um passo do workflow
function SQL_DELETE_STEP(stepID)
	SQL_DELETE_STEP = "DELETE from T_WORKFLOW_STEP where stepID="+stepID
end function

'Remove as pessoas de um passo do workflow
function SQL_DELETE_USERS_FROM_WORKFLOW_STEP(stepID)
	SQL_DELETE_USERS_FROM_WORKFLOW_STEP = "DELETE from T_WORKFLOW_STEP_X_USER where stepID="+stepID
end function


'Coloca um usuário em um FTA
function SQL_ADICIONA_USUARIO_WORKFLOW_STEP(stepID, email, role)
	SQL_ADICIONA_USUARIO_WORKFLOW_STEP = "INSERT INTO T_WORKFLOW_STEP_X_USER (stepID, email, role) VALUES (" + cstr(stepID) + ", '" + email + "', '" + role + "')" 
end function

'Verifica se um usuário está em um FTA em passo e papel específico
function SQL_CONSULTA_USUARIO_WORKFLOW_STEP(stepID, email, role)
	SQL_CONSULTA_USUARIO_WORKFLOW_STEP = "SELECT * FROM T_WORKFLOW_STEP_X_USER WHERE stepID="+stepID+" and email='"+email+"' and role='"+role+"'" 
end function

'Coleta os Dados do Workflow
function SQL_CONSULTA_NUM_STEP_CHILD(parentStepID)
	SQL_CONSULTA_NUM_STEP_CHILD = "Select count(T_WORKFLOW_STEP_X_STEP.stepID) as total from T_WORKFLOW_STEP_X_STEP where parentStepID="+parentStepID
end function


'Coleta os Dados do Workflow
function SQL_CONSULTA_WORKFLOW_STEP_POSITION(workflowID)
	SQL_CONSULTA_WORKFLOW_STEP_POSITION = "Select T_WORKFLOW_STEP.*, T_WORKFLOW_STEP_POSITION.* from T_WORKFLOW_STEP LEFT JOIN  T_WORKFLOW_STEP_POSITION ON T_WORKFLOW_STEP.stepID = T_WORKFLOW_STEP_POSITION.stepID WHERE workflowID="+workflowID
end function


'Coleta os Dados do Workflow
function SQL_CONSULTA_WORKFLOW_PARENT_STEP_POSITION(parentStepID)
	SQL_CONSULTA_WORKFLOW_PARENT_STEP_POSITION = "Select * from T_WORKFLOW_STEP_POSITION WHERE stepID="+parentStepID
end function


'Remove um usuário 
function SQL_DELETE_USUARIO_FROM_STEP(user)
	SQL_DELETE_USUARIO_FROM_STEP = "DELETE from T_WORKFLOW_STEP_X_USER where email='"+user+"'"
end function

'Atualiza um workflow
function SQL_ATUALIZA_WORKFLOW(workflowID, description, goal, expResult)
	SQL_ATUALIZA_WORKFLOW = "UPDATE T_WORKFLOW SET description='"+description+"', goal='"+goal+"', expectedresult='"+expResult+"' WHERE workflowID="+workflowID
end function


'Atualiza um workflow
function SQL_SET_STATUS_WORKFLOW(workflowID, status)
	SQL_SET_STATUS_WORKFLOW = "UPDATE T_WORKFLOW SET status="+cstr(status)+" WHERE workflowID="+workflowID
end function


'Atualiza um workflow
function SQL_SET_STATUS_WORKFLOW_STEPS(workflowID, status)
	SQL_SET_STATUS_WORKFLOW_STEPS = "UPDATE T_WORKFLOW_STEP SET status="+cstr(status)+" WHERE workflowID="+workflowID
end function


'Atualiza um workflow
function SQL_SET_STATUS_WORKFLOW_PRIMARY_STEPS(workflowID, status)
	SQL_SET_STATUS_WORKFLOW_PRIMARY_STEPS = "UPDATE T_WORKFLOW_STEP SET status="+cstr(status)+" WHERE workflowID="+workflowID + " and stepID NOT IN (SELECT stepID from T_WORKFLOW_STEP_X_STEP)"
end function



'Coleta os Dados do Workflow
function SQL_CONSULTA_WORKFLOW_STEPS_BY_OWNER_AND_STATUS(email, status)
	SQL_CONSULTA_WORKFLOW_STEPS_BY_OWNER_AND_STATUS = "Select T_WORKFLOW_STEP.*, T_WORKFLOW.*, T_WORKFLOW_STEP_X_USER.role from T_WORKFLOW_STEP LEFT JOIN T_WORKFLOW ON T_WORKFLOW.workflowID = T_WORKFLOW_STEP.workflowID JOIN T_WORKFLOW_STEP_X_USER ON  T_WORKFLOW_STEP_X_USER.stepID = T_WORKFLOW_STEP.stepID WHERE T_WORKFLOW_STEP_X_USER.email='"+email+"' and T_WORKFLOW_STEP.status=" +cstr(status)
end function


'Coleta os Dados do Workflow
function SQL_CONSULTA_WORKFLOW_STEP_ID(stepID)
	SQL_CONSULTA_WORKFLOW_STEP_ID = "Select * from T_WORKFLOW_STEP where stepID="+stepID
end function


'Coleta os Dados do Workflow
function SQL_CONSULTA_WORKFLOW_AVAILABLE_USERS_BY_STEP_ROLE(stepID, role)
	SQL_CONSULTA_WORKFLOW_AVAILABLE_USERS_BY_STEP_ROLE = "Select distinct t_user.email, t_user.name from T_USER WHERE t_user.email NOT IN (SELECT email from T_WORKFLOW_STEP_X_USER WHERE T_WORKFLOW_STEP_X_USER.stepID=" + stepID + " and T_WORKFLOW_STEP_X_USER.role='" + role + "') order by t_user.name"
end function


'Coleta os Dados do Workflow
function SQL_CONSULTA_STEP_X_USER_BY_STEPID_ROLE(stepID, role)
	SQL_CONSULTA_STEP_X_USER_BY_STEPID_ROLE = "Select * from T_WORKFLOW_STEP_X_USER JOIN T_USER ON T_USER.email=T_WORKFLOW_STEP_X_USER.email WHERE role='"+role+"' and stepID=" + stepID
end function




'Coleta os Dados do Workflow
function SQL_CONSULTA_ACCESS_WORKFLOW(email, workflowID)
	SQL_CONSULTA_ACCESS_WORKFLOW = "Select * from T_WORKFLOW WHERE owner='"+email+"' and workflowID=" + workflowID
end function

'Coleta os Dados do Workflow
function SQL_CONSULTA_ACCESS_STEP(email, stepID)
	SQL_CONSULTA_ACCESS_STEP = "Select * from T_WORKFLOW_STEP_X_USER WHERE email='"+email+"' and stepID=" + stepID
end function


'Remove as pessoas de um passo do workflow
function SQL_DELETE_USERS_FROM_WORKFLOW_STEP_BY_STEPID_EMAIL_ROLE(stepID, email, role)
	SQL_DELETE_USERS_FROM_WORKFLOW_STEP_BY_STEPID_EMAIL_ROLE = "DELETE from T_WORKFLOW_STEP_X_USER where stepID="+stepID + " and email='"+ email + "' and role='"+role +"'"
end function


'Remove as pessoas de um passo do workflow
function SQL_CONSULTA_USERS_FROM_WORKFLOW_STEP_BY_STEPID_EMAIL_ROLE(stepID, email, role)
	SQL_CONSULTA_USERS_FROM_WORKFLOW_STEP_BY_STEPID_EMAIL_ROLE = "Select * from T_WORKFLOW_STEP_X_USER JOIN T_USER ON T_USER.email=T_WORKFLOW_STEP_X_USER.email WHERE role='"+role+"' and stepID=" + stepID + " and T_WORKFLOW_STEP_X_USER.email='"+ email + "'"
end function



'Coleta os Dados do Workflow
function SQL_CONSULTA_SUB_WORKFLOW_BY_PARENTSTEP(parentStepID)
	SQL_CONSULTA_SUB_WORKFLOW_BY_PARENTSTEP = "Select T_WORKFLOW.*, T_USER.name from T_WORKFLOW JOIN T_USER ON T_WORKFLOW.owner = T_USER.email WHERE T_WORKFLOW.parentStepID="+parentStepID
end function


'Coleta os Dados do Workflow
function SQL_CONSULTA_SUB_WORKFLOW_BY_WORKFLOWID(workflowID)
	SQL_CONSULTA_SUB_WORKFLOW_BY_WORKFLOWID = "Select T_WORKFLOW.* from T_WORKFLOW JOIN T_WORKFLOW_STEP ON T_WORKFLOW.parentStepID = T_WORKFLOW_STEP.stepID WHERE T_WORKFLOW_STEP.workflowID="+workflowID
end function

' Adiciona um STEP
function SQL_CRIA_WORKFLOW_STEP(stepID, parentStepID)
	SQL_CRIA_WORKFLOW_STEP = "INSERT INTO T_WORKFLOW_STEP_X_STEP(stepID, parentStepID) VALUES (" + stepID + ", " + parentStepID + ")" 
end function

' Remove um STEP X STEP
function SQL_DELETE_WORKFLOW_STEP_PARENT(stepID, parentStepID)
	SQL_DELETE_WORKFLOW_STEP_PARENT = "DELETE T_WORKFLOW_STEP_X_STEP WHERE stepID = "+stepID+" and parentStepID="+parentStepID
end function

' Remove um STEP
function SQL_DELETE_WORKFLOW_STEP(stepID)
	SQL_DELETE_WORKFLOW_STEP = "DELETE T_WORKFLOW_STEP WHERE stepID = "+stepID
end function

' Remove todos os STEP X STEP de um step
function SQL_DELETE_WORKFLOW_STEP_X_STEP(stepID)
	SQL_DELETE_WORKFLOW_STEP_X_STEP = "DELETE T_WORKFLOW_STEP_X_STEP WHERE stepID = "+stepID 
end function

' Adiciona um supporting information
function SQL_CRIA_STEP_SUPPORTING_INFORMATION(stepID, filepath)
	SQL_CRIA_STEP_SUPPORTING_INFORMATION = "INSERT INTO T_STEP_SUPPORTING_INFORMATION (stepID, filepath) VALUES (" + stepID + ", '" + filepath + "')" 
end function


' Adiciona um supporting information
function SQL_CRIA_WORKFLOW_SUPPORTING_INFORMATION(workflowID, filepath)
	SQL_CRIA_WORKFLOW_SUPPORTING_INFORMATION = "INSERT INTO T_WORKFLOW_SUPPORTING_INFORMATION (workflowID, filepath) VALUES (" + workflowID + ", '" + filepath + "')" 
end function

'Coleta os Dados do Workflow
function SQL_CONSULTA_WORKFLOW_NEXT_STEPS(parentStepID)
	SQL_CONSULTA_WORKFLOW_NEXT_STEPS = "Select * from T_WORKFLOW_STEP where stepID IN (SELECT stepID from T_WORKFLOW_STEP_X_STEP WHERE parentStepID="+parentStepID +")"
end function


'Atualiza um workflow
function SQL_SET_STATUS_WORKFLOW_STEP(stepID, status)
	SQL_SET_STATUS_WORKFLOW_STEP = "UPDATE T_WORKFLOW_STEP SET status="+cstr(status)+" WHERE stepID="+stepID
end function



'Coleta os Dados do Workflow
function SQL_CONSULTA_WORKFLOW_STEP_SUPPORTING_INFORMATION(stepID)
	SQL_CONSULTA_WORKFLOW_STEP_SUPPORTING_INFORMATION = "Select T_STEP_SUPPORTING_INFORMATION.*, T_WORKFLOW_STEP.* from T_WORKFLOW_STEP LEFT JOIN T_STEP_SUPPORTING_INFORMATION ON T_WORKFLOW_STEP.stepID = T_STEP_SUPPORTING_INFORMATION.stepID WHERE T_WORKFLOW_STEP.stepID="+stepID
end function


'Coleta os Dados do Workflow
function SQL_CONSULTA_WORKFLOW_SUPPORTING_INFORMATION(workflowID)
	SQL_CONSULTA_WORKFLOW_SUPPORTING_INFORMATION = "Select T_WORKFLOW_SUPPORTING_INFORMATION.*, T_WORKFLOW.* from T_WORKFLOW LEFT JOIN T_WORKFLOW_SUPPORTING_INFORMATION ON T_WORKFLOW.workflowID = T_WORKFLOW_SUPPORTING_INFORMATION.workflowID WHERE T_WORKFLOW.workflowID="+workflowID
end function



'Coleta os Dados do Workflow
function SQL_CONSULTA_SUB_WORKFLOW_SUPPORTING_INFORMATION(parentStepID)
	SQL_CONSULTA_SUB_WORKFLOW_SUPPORTING_INFORMATION = "Select T_WORKFLOW_SUPPORTING_INFORMATION.*, T_WORKFLOW.* from T_WORKFLOW LEFT JOIN T_WORKFLOW_SUPPORTING_INFORMATION ON T_WORKFLOW.workflowID = T_WORKFLOW_SUPPORTING_INFORMATION.workflowID WHERE T_WORKFLOW.parentStepID="+parentStepID
end function



'Coleta os Dados do Workflow
function SQL_DELETE_WORKFLOW_STEP_SUPPORTING_INFORMATION(stepID, filepath)
	SQL_DELETE_WORKFLOW_STEP_SUPPORTING_INFORMATION = "DELETE FROM T_STEP_SUPPORTING_INFORMATION WHERE T_STEP_SUPPORTING_INFORMATION.stepID="+stepID +" and T_STEP_SUPPORTING_INFORMATION.filepath='"+filepath+"'"
end function


'Coleta os Dados do Workflow
function SQL_DELETE_WORKFLOW_SUPPORTING_INFORMATION(workflowID, filepath)
	SQL_DELETE_WORKFLOW_SUPPORTING_INFORMATION = "DELETE FROM T_WORKFLOW_SUPPORTING_INFORMATION WHERE T_WORKFLOW_SUPPORTING_INFORMATION.workflowID="+workflowID+" and T_WORKFLOW_SUPPORTING_INFORMATION.filepath='"+filepath+"'"
end function


function SQL_CONSULTA_SUB_WORKFLOWS_BY_WORKFLOW_ID(workflowID)
	SQL_CONSULTA_SUB_WORKFLOWS_BY_WORKFLOW_ID = "Select T_WORKFLOW.* from T_WORKFLOW_STEP join T_WORKFLOW ON T_WORKFLOW.parentStepID = T_WORKFLOW_STEP.stepID  WHERE T_WORKFLOW_STEP.type=0 and T_WORKFLOW_STEP.workflowID="+workflowID
end function

function SQL_CONSULTA_NUM_STEPS_BY_WORKFLOW_ID(workflowID)
	SQL_CONSULTA_NUM_STEPS_BY_WORKFLOW_ID = "Select count(T_WORKFLOW_STEP.stepID) as steps from T_WORKFLOW_STEP WHERE T_WORKFLOW_STEP.type>0 and T_WORKFLOW_STEP.workflowID="+workflowID
end function



function SQL_CONSULTA_NUM_STEPS_BY_WORKFLOW_ID(workflowID)
	SQL_CONSULTA_NUM_STEPS_BY_WORKFLOW_ID = "Select count(T_WORKFLOW_STEP.stepID) as steps from T_WORKFLOW_STEP WHERE T_WORKFLOW_STEP.type>0 and T_WORKFLOW_STEP.workflowID="+workflowID
end function



' Adiciona um STEP INVITATION
function SQL_CRIA_WORKFLOW_STEP_INVITATION(stepID, role, workflowID, code, verification)
	SQL_CRIA_WORKFLOW_STEP_INVITATION = "INSERT INTO T_WORKFLOW_STEP_X_USER_INVITATION(stepID, role,  workflowID, code, verification) VALUES (" + stepID + ", '" + role + "', " + workflowID + ", '" + code + "', '" + verification +"')" 
end function


function SQL_CONSULTA_WORKFLOW_STEP_INVITATION(stepID, role, workflowID, code, verification)
	SQL_CONSULTA_WORKFLOW_STEP_INVITATION = "Select * from T_WORKFLOW_STEP_X_USER_INVITATION WHERE stepID = " +stepID+ " and role = '"+role+"' and code = '"+code+"' and verification = '"+verification+"'  and workflowID="+workflowID
end function

function SQL_CONSULTA_WORKFLOW_STEP_INVITATION_VALIDATION(code, verification)
	SQL_CONSULTA_WORKFLOW_STEP_INVITATION_VALIDATION = "Select inv.*, step.type, workflow.* from T_WORKFLOW_STEP_X_USER_INVITATION inv JOIN T_WORKFLOW_STEP step on inv.stepID = step.stepID  join T_WORKFLOW workflow on step.workflowID = workflow.workflowID WHERE inv.code = '"+code+"' and inv.verification = '"+verification+"'"  
end function



' Adiciona um Reset Link
function SQL_CRIA_USER_RESET(email, verification)
	d_added=DateAdd("d",1,Now)
	SQL_CRIA_USER_RESET = "INSERT INTO T_USER_RESET(email, verification, timeLimit) VALUES ('" + email + "', '" + verification + "',  TRY_CONVERT( DATETIME, '" + cstr(d_added)+ "') )" 
end function


function SQL_CONSULTA_USER_RESET_VALIDATION(email, verification)
	SQL_CONSULTA_USER_RESET_VALIDATION = "Select * from T_USER_RESET WHERE email = '"+email+"' and verification = '"+verification+"'"  
end function


function SQL_DELETE_EXPIRED_USER_RESET()
	SQL_DELETE_EXPIRED_USER_RESET = "DELETE FROM T_USER_RESET WHERE CURRENT_TIMESTAMP > timeLimit"
end function


%>