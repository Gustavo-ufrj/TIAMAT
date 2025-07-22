
<!--#include virtual="/system.asp"-->
<!--#include file="INC_TIA.inc"-->
<!--#include virtual="/includes/JSON.asp"-->
<!--#include virtual="/FTA/extrapolation/regression.asp"-->
<!--#include file="tia.asp"-->

<%
	Session.LCID = 1033 ' IMPORTANT
	
	public sub saveBaseExtrapolation(id, parametersDict, resultArray)
	
		parametersJSON = (new JSON)(Empty, parametersDict, false)
		call ExecuteSQL(SQL_UPDATE_PARAMETERS(id,parametersJSON))
		
		call ExecuteSQL(SQL_DELETE_ALL_RESULTPOINTS(id))
		
		For n = 0 To UBound(resultArray)
			set dic = resultArray(n)
			'response.write dic("x")& " | " & dic("y") & " | " & dic("z") & "<br /> " & vbCrLf
			point_x = dic("x")
			point_y = dic("y")
			point_z = dic("z")
			scenario = 0
			if (point_y) then scenario = -1 end if
			'response.write SQL_CREATE_RESULTPOINT(n, id, scenario, point_x, point_y, point_z, "Baseline") & "<br /> " & vbCrLf
			call ExecuteSQL(SQL_CREATE_RESULTPOINT(n, id, scenario, point_x, point_y, point_z, "Baseline"))
		Next
	end sub
	
	public sub executeTIA(stepID)
		call ExecuteSQL(SQL_DELETE_ALL_RESULTPOINTS(stepID))
		set re = new Regression
		re.id = stepID
		re.execute()
		call saveBaseExtrapolation(re.id,re.result(0),re.result(1))
		set t = new TIA
		
		t.id = stepID
		t.baseExtrapolation = re.result
		t.execute()
	end sub
	
	dim action
	dim ri, rp, index
	
	action = Request.Querystring("action")
	
	pointID = Request.Querystring("pointID")
	x = Request.Querystring("x")
	y = Request.Querystring("y")
	
	eventID		= Request.QueryString("eventID")
	stepID		= Request.QueryString("stepID")
	title		= Request.QueryString("title")
	description	= Request.QueryString("description")
	probability	= CDbl(Request.QueryString("probability"))
	max_impact	= CDbl(Request.QueryString("max_impact"))
	ss_impact	= CDbl(Request.QueryString("ss_impact"))
	max_time	= CDbl(Request.QueryString("max_time"))
	ss_time		= CDbl(Request.QueryString("ss_time"))
	
	stepID = Request.Form("stepID")
	if stepID = "" then stepID = Request.QueryString("stepID") end if
	
	if stepID = "" then
		call response.write ("Invalid step supplied. Please inform the system administrator.")
	
	else
	
		select case action
		
			case "import"
			
					' Merged to "data.asp"
					
					' ' Information
					' extrapolation_step_id = Request.Form("extrapolation_step_id")
					' call getRecordSet(SQL_READ_EXTRAPOLATION_INFORMATION(extrapolation_step_id), ri)
					' xn = ri("x_name")
					' xd = ri("x_desc")
					' yn = ri("y_name")
					' yd = ri("y_desc")
					' ad = ri("adj_type")
					' call getRecordSet(SQL_READ_INFORMATION(stepID), ri)
					' if not ri.eof then
					' 	call ExecuteSQL(SQL_UPDATE_INFORMATION(stepID, xn, xd, yn, yd, ad, .0, extrapolation_step_id, 0))
					' else 
					' 	call ExecuteSQL(SQL_CREATE_INFORMATION(stepID, xn, xd, yn, yd, ad, .0, extrapolation_step_id, 0))
					' end if
					' 
					' ' Points
					' call ExecuteSQL(SQL_DELETE_ALL_POINTS(stepID))
					' call getRecordSet(SQL_READ_EXTRAPOLATION_POINTS(extrapolation_step_id), rp)
					' index = 1
					' rp.moveFirst
					' do until rp.eof
					' 	x = rp("X")
					' 	y = rp("Y")
					' 	call ExecuteSQL(SQL_CREATE_POINT(index, stepID, x, y))
					' 	index = index + 1
					' 	rp.moveNext
					' loop
					' 
					' response.redirect "details.asp?stepID="+stepID
							
					
			case "setinfo"
			
					x_name = Request.Form("x_name")
					x_desc = Request.Form("x_desc")
					y_name = Request.Form("y_name")
					y_desc = Request.Form("y_desc")
					adj_type = Request.Form("adj_type")
					range = Request.Form("range")
					source = Request.Form("source")
					scenarios = Request.Form("scenarios")
					call getRecordSet(SQL_READ_INFORMATION(stepID), ri)
					if not ri.eof then
						call ExecuteSQL(SQL_UPDATE_INFORMATION(stepID, x_name, x_desc, y_name, y_desc, adj_type, range, source, scenarios))
					else 
						call ExecuteSQL(SQL_CREATE_INFORMATION(stepID, x_name, x_desc, y_name, y_desc, adj_type, range, source, scenarios))
					end if
					' if source <> "" then
					 	response.redirect "events.asp?stepID="+stepID
					' else
					' 	response.redirect "data.asp?stepID="+stepID
					' end if
			
			case "list"
			
					call getRecordSet(SQL_READ_POINTS(stepID), rp)
					if not rp.eof then
						r  = (new JSON)(Empty, rp, false)
					else
						r  = (new JSON)(Empty, Empty, true)
					end if 
					
					Response.ContentType = "application/json; charset=utf-8"
					Response.Write (r)
					Response.End
					
			case "listresult"
			
					call getRecordSet(SQL_READ_RESULT(stepID), rr)
					if not rr.eof then
						r  = (new JSON)(Empty, rr, false)
					else
						r  = (new JSON)(Empty, Empty, true)
					end if 
					
					Response.ContentType = "application/json; charset=utf-8"
					Response.Write (r)
					Response.End
									
				
			case "insert"
			
				if x <> "NaN" and y <> "NaN" then
				
					call getRecordSet(SQL_READ_POINTS(stepID), rp)
					newID = 1
					if not rp.eof then
						rp.MoveLast 'find last ID
						lastID = rp("pointID")
						newID = CInt(lastID) + 1
					end if
					call ExecuteSQL(SQL_CREATE_POINT(newID, stepID,x, y))
					call getRecordSet(SQL_READ_POINT(newID), p)
					executeTIA(stepID)
					r  = (new JSON)(Empty, p, false)
					Response.ContentType = "application/json; charset=utf-8"
					Response.Write (Mid(r,2,Len(r)-2)) ' to remove brackets
					Response.End
					
				end if
				
			case "update" 
			
				if pointID <> "" and x <> "NaN" and y <> "NaN" then
					call ExecuteSQL(SQL_UPDATE_POINT(pointID,stepID,x,y))
					call getRecordSet(SQL_READ_POINT(pointID,stepID), rp)
					r  = (new JSON)(Empty, rp, false)
					executeTIA(stepID)
					Response.ContentType = "application/json; charset=utf-8"
					Response.Write (Mid(r,2,Len(r)-2)) ' to remove brackets
					Response.End
				end if
				
			case "delete" 
			
				if pointID <> "" then
					call ExecuteSQL(SQL_DELETE_POINT(pointID, stepID))
					executeTIA(stepID)
				end if
				
						
			case "listEvents"
			
					call getRecordSet(SQL_READ_EVENTS(stepID), rp)
					if not rp.eof then
						r  = (new JSON)(Empty, rp, false)
					else
						r  = (new JSON)(Empty, Empty, true)
					end if 
					
					Response.ContentType = "application/json; charset=utf-8"
					Response.Write (r)
					Response.End
					
				
			case "insertEvent"
				
				if title <> "" then
		
					call getRecordSet(SQL_READ_EVENTS(stepID), rp)
					eventID = 1
					if not rp.eof then
						rp.MoveLast 'find last ID
						lastID = rp("eventID")
						eventID = CInt(lastID) + 1
					end if
					call ExecuteSQL(SQL_CREATE_EVENT(eventID, stepID, title, description, probability, max_impact, ss_impact, max_time, ss_time))
					'response.write "inseri: "&eventID&"|"&stepID&"|"&title&"|"&description&"|"&probability&"|"&max_impact&"|"&ss_impact&"|"&max_time&"|"&ss_time
					call getRecordSet(SQL_READ_EVENT(eventID, stepID), e)
					r  = (new JSON)(Empty, e, false)
					Response.ContentType = "application/json; charset=utf-8"
					Response.Write (Mid(r,2,Len(r)-2)) ' to remove brackets
					Response.End
				
				end if
				
			case "updateEvent" 
			
				if eventID <> "" then
					call ExecuteSQL(SQL_UPDATE_EVENT(eventID, stepID, title, description, probability, max_impact, ss_impact, max_time, ss_time))
					call getRecordSet(SQL_READ_EVENT(eventID, stepID), rp)
					r  = (new JSON)(Empty, rp, false)
					Response.ContentType = "application/json; charset=utf-8"
					Response.Write (Mid(r,2,Len(r)-2)) ' to remove brackets
					Response.End
				end if
				
			case "deleteEvent" 
			
				if eventID <> "" then
					call ExecuteSQL(SQL_DELETE_EVENT(eventID, stepID))
				end if
				
			case "execute"
				
				executeTIA(stepID)
				response.redirect "index.asp?stepID="+stepID
				
				
			case "graph"
				
					call getRecordSet(SQL_READ_POINTS_FOR_GRAPH(stepID), rp)
					r  = (new JSON)(Empty, rp, false)
					Response.ContentType = "application/json; charset=utf-8"
					'Response.Write (Mid(r,2,Len(r)-2)) ' to remove brackets
					Response.Write (r) ' to remove brackets
					Response.End
				
			case "result" 
			
				call getRecordSet(SQL_READ_INFORMATION(stepID), ri)
				call getRecordSet(SQL_READ_RESULTPOINTS(stepID), rp)
				if rp.eof then 
				
					call Response.Write ("No data available.")
					
				else
					scenarios = ri("scenarios")
					parameters = ri("parameters")
					'r = (new JSON)("parameters", parameters, true)
					s = (new JSON)("values", rp, true)
					
					Response.ContentType = "application/json; charset=utf-8"
					Response.Write "{""scenarios"": " & scenarios & ",""parameters"": " & parameters & ", " & s & "}"
					Response.End	
					
				end if
				
			case "save"
			
					source = ""
					file = Request.QueryString("file")
					database = Request.Form("database")
					extrapolation_step_id = Request.Form("extrapolation_step_id")
					
					if extrapolation_step_id <> "" then 'IMPORT
					
					' Information
					call getRecordSet(SQL_READ_EXTRAPOLATION_INFORMATION(extrapolation_step_id), ri)
					xn = ri("x_name")
					xd = ri("x_desc")
					yn = ri("y_name")
					yd = ri("y_desc")
					ad = ri("adj_type")
					rg = ri("range")
					call getRecordSet(SQL_READ_INFORMATION(stepID), ri)
					if not ri.eof then
						call ExecuteSQL(SQL_UPDATE_INFORMATION(stepID, xn, xd, yn, yd, ad, rg, extrapolation_step_id, 0))
					else 
						response.write SQL_CREATE_INFORMATION(stepID, xn, xd, yn, yd, ad, rg, extrapolation_step_id, 0)
						call ExecuteSQL(SQL_CREATE_INFORMATION(stepID, xn, xd, yn, yd, ad, rg, extrapolation_step_id, 0))
					end if
					
					' Points
					call ExecuteSQL(SQL_DELETE_ALL_POINTS(stepID))
					call getRecordSet(SQL_READ_EXTRAPOLATION_POINTS(extrapolation_step_id), rp)
					index = 1
					rp.moveFirst
					do until rp.eof
						x = rp("X")
						y = rp("Y")
						call ExecuteSQL(SQL_CREATE_POINT(index, stepID, x, y))
						index = index + 1
						rp.moveNext
					loop
					
					response.redirect "details.asp?stepID="+stepID
					
				
					elseif file <> "" and database = "" then 'FILE
					
						source = "file"
					
						call getRecordSet(SQL_READ_POINTS(stepID), rp)
						call getRecordSet(SQL_READ_INFORMATION(stepID), ri)
						
						if not rp.eof then 'update (delete all + create)
							call ExecuteSQL(SQL_DELETE_ALL_POINTS(stepID))
						end if 
						
						set fso = CreateObject("Scripting.FileSystemObject") 
						set fs = fso.OpenTextFile("C:\Inetpub\wwwroot\tiamat\" & file, 1, true) 
												
						dim lineData, splittedData
						index = 1
						Do Until fs.AtEndOfStream 
							lineData = fs.ReadLine
							splittedData = Split(lineData,",")
							if UBound(splittedData) = 0 then splittedData = Split(lineData,";") end if
								if UBound(splittedData) = 1 then
								' skipping first line if doesn't contain numbers
									if isNumeric(Trim(splittedData(0))) then
										call ExecuteSQL(SQL_CREATE_POINT(stepID & "_" & index, stepID, CDbl(Trim(splittedData(0))), CDbl(Trim(splittedData(1)))))
										index = index + 1
									end if
							end if
						Loop 
						
						
					elseif database <> "" then 'DATABASE
						source = "database"
						dim server, username, password, database, table
					
						server = Request.Form("server")
						username = Request.Form("uid")
						password = Request.Form("pw")
						database = Request.Form("database")
						table = Request.Form("table")
						
						dim cnn : set cnn = CreateObject("ADODB.Connection")
						cnn.Open "Provider=SQLOLEDB;DATA SOURCE="&server&";DATABASE="&database&";UID="&username&";PWD="&password&";"
						
						set record = CreateObject("ADODB.RecordSet")
						record.CursorLocation = adUseClient
						record.Open "SELECT * FROM " & table, cnn, adOpenStatic, adLockReadOnly
						'set record.ActiveConnection = nothing
						if record.Fields.Count < 2 then
							response.write ("Table does not contain 2 columns.")
							response.end
						elseif record.eof then
							response.write ("No data available.")
							response.end
						else
						
							call getRecordSet(SQL_READ_POINTS(stepID), rp)
							
							if not rp.eof then 'update (delete all + create)
								call ExecuteSQL(SQL_DELETE_ALL_POINTS(stepID))
							end if 
							
							index = 1
							record.moveFirst
							do until record.eof
								pointID = index
								x = record.Fields(0)
								y = record.Fields(1)
								
								'response.write "x = " & x & ", y = " & y
								'y = Replace(record.Fields(1), ",", ".")
								call ExecuteSQL(SQL_CREATE_POINT(pointID, stepID, x, y))
								index = index + 1
								record.moveNext
							loop
							
						end if
						
						set record.ActiveConnection = nothing
						set cnn = nothing
								 
					end if
				
				call ExecuteSQL(SQL_UPDATE_DATASOURCE(stepID, source))
					
				set r = new Regression
				r.id = stepID
				r.execute()
				'call saveExtrapolationResult(r.id,r.result(0),r.result(1))
				
				Response.Write ("<script>window.close();opener.location.href = ""index.asp?stepID=" & stepID & """</script>")
					
					
			case "end"

					call endStep(stepID)
					response.redirect "/workplace.asp"
			
			case else
				call response.write ("Invalid action supplied. Please inform the system administrator.")

		end select
		
	end if
	
%>

<script>
window.opener.location.reload();
window.close();
</script>