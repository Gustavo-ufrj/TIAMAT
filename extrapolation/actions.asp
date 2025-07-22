
<!--#include virtual="/system.asp"-->
<!--#include virtual="/includes/JSON.asp"-->
<!--#include file="INC_EXTRAPOLATION.inc"-->
<!--#include file="regression.asp"-->

<%
	Session.LCID = 1033 ' IMPORTANT

	public sub saveExtrapolationResult(id, parametersDict, resultArray)
	
		parametersJSON = (new JSON)(Empty, parametersDict, false)
		call ExecuteSQL(SQL_UPDATE_PARAMETERS(id,parametersJSON))
		
		call ExecuteSQL(SQL_DELETE_ALL_RESULTPOINTS(id))
		
		For n = 0 To UBound(resultArray)
			set dic = resultArray(n)
			point_x = dic("x")
			point_y = dic("y")
			point_z = dic("z")
			ExecuteSQL(SQL_CREATE_RESULTPOINT(n, id, point_x, point_y, point_z))
		Next	
	end sub
	
	public sub executeExtrapolation(stepID)
		set r = new Regression
		r.id = stepID
		r.execute()
		call saveExtrapolationResult(r.id,r.result(0),r.result(1))
	end sub
		
	dim action
	dim ri, rp, index
	
	action = Request.Querystring("action")
	pointID = Request.Querystring("pointid")
	x = Request.Querystring("x")
	y = Request.Querystring("y")
	
	stepID = Request.Form("stepID")
	if stepID = "" then stepID = Request.QueryString("stepID") end if
	
	if stepID = "" then
		call response.write ("Invalid step supplied. Please inform the system administrator.")
	
	else
	
		select case action
		
			case "setinfo"
			
					x_name = Request.Form("x_name")
					x_desc = Request.Form("x_desc")
					y_name = Request.Form("y_name")
					y_desc = Request.Form("y_desc")
					adj_type = Request.Form("adj_type")
					if adj_type = "pearl" or adj_type = "gompertz" then
						adj_type = adj_type + "|" + Request.Form("upperlimit")
					end if
					
					range = Request.Form("range")
					source = Request.Form("source")
					call getRecordSet(SQL_READ_INFORMATION(stepID), ri)
					if not ri.eof then
						call ExecuteSQL(SQL_UPDATE_INFORMATION(stepID, x_name, x_desc, y_name, y_desc, adj_type, range, source))
					else
						call ExecuteSQL(SQL_CREATE_INFORMATION(stepID, x_name, x_desc, y_name, y_desc, adj_type, range, source))
					end if
					response.redirect "actions.asp?action=execute&stepID="+stepID
			
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
						lastID = CInt(rp("pointID"))
						newID = lastID + 1
					end if
					call ExecuteSQL(SQL_CREATE_POINT(newID, stepID, x, y))
					call getRecordSet(SQL_READ_POINT(newID, stepID), p)
					q  = (new JSON)(Empty, p, false)
					Response.ContentType = "application/json; charset=utf-8"
					Response.Write (Mid(q,2,Len(q)-2)) ' to remove brackets
					Response.End
					
				end if
				
			case "update" 
			
				if pointID <> "" and x <> "NaN" and y <> "NaN" then
					call ExecuteSQL(SQL_UPDATE_POINT(pointID, stepID,x,y))
					call getRecordSet(SQL_READ_POINT(pointID, stepID), rp)
					executeExtrapolation(stepID)
					p  = (new JSON)(Empty, rp, false)
					Response.ContentType = "application/json; charset=utf-8"
					Response.Write (Mid(p,2,Len(p)-2)) ' to remove brackets
					Response.End
					
				end if
				
			case "delete" 
			
				if pointID <> "" then
					call ExecuteSQL(SQL_DELETE_POINT(pointID, stepID))
					executeExtrapolation(stepID)
				end if
				
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
					parameters = ri("parameters")
					'r = (new JSON)("parameters", parameters, true)
					s = (new JSON)("values", rp, true)
					
					Response.ContentType = "application/json; charset=utf-8"
					Response.Write "{""parameters"": " & parameters & ", " & s & "}"
					Response.End	
					
				end if
				
			case "save"
		
				source = ""
				file = Request.QueryString("file")
				database = Request.Form("database")
			
				if file <> "" and database = "" then 'FILE
				
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
						splittedData = Split(lineData,vbTab) 
						if UBound(splittedData) = 0 then splittedData = Split(lineData,";") end if
						if UBound(splittedData) = 0 then splittedData = Split(lineData,",") end if
							if UBound(splittedData) = 1 then
							' skipping first line if doesn't contain numbers
								if isNumeric(Trim(splittedData(0))) then
									call ExecuteSQL(SQL_CREATE_POINT(index, stepID, CDbl(Trim(splittedData(0))), CDbl(Trim(splittedData(1)))))	
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
				
				
					
				Response.Write ("<script>window.close();opener.location.href = ""details.asp?stepID=" & stepID & """</script>")
						
			case "execute"
			
				executeExtrapolation(stepID)
				
				response.redirect "index.asp?stepID="+stepID
					
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