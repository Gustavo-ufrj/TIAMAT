
<%
class TIA

	public id, baseExtrapolation, result, dbg
	
	public sub class_initialize()
		id = 0
		result = ""
		dbg = false
	end sub
	
	' step ID
	Public Property Let stepID(newID)
		id = newID
	End Property
	
	' Array(parametersDict, resultArray)
	Public Property Let baseExtr(base)
		baseExtrapolation = base
	End Property
	
	' public sub extrapolateByParameters(x)
		' parameters = me.baseExtrapolation(0)
		' method = parameters("method")
		' degree = len(parameters.keys) - 2
		' y = 0
		' for d = (degree - 1) to 0
			' y = y + parameters("a"&d)*(x^degree)
		' next
		' if InStr(1, method, "exp") > 0 then ' Exp
			' y = exp(y)
		' end if
		' return y
	' end sub
	
	public sub execute()
	
		if dbg = true then response.write "> Starting TIA" end if
	
		call getRecordSet(SQL_READ_INFORMATION(me.id), ri)
		scenarios = cint(ri("scenarios"))
		
		if dbg = true then response.write "> Scenarios: " & scenarios & vbcrlf  end if
				
		call getRecordSet(SQL_READ_POINTS_FOR_GRAPH(me.id), rp)
		rp.moveLast
		lowerbound = CInt(rp("x"))
		upperbound = (ri("range"))
		
		if dbg = true then response.write "> Range: " & lowerbound & " - " & upperbound & vbcrlf  end if
		
		' result = baseExtrapolation(1)
		' redim preserve result(len(result)+upperbound-lowerbound)
		
		call getRecordSet(SQL_READ_EVENTS(me.id), re)
		num_events = re.recordCount
		dim probability() 
		redim preserve probability(num_events)
		dim max_impact() 
		redim preserve max_impact(num_events)
		dim ss_impact() 
		redim preserve ss_impact(num_events)
		dim max_time() 
		redim preserve max_time(num_events)
		dim ss_time() 
		redim preserve ss_time(num_events)
		
		index_e = 0	
		re.moveFirst
		do while not re.eof
			probability(index_e) = CDbl(re("probability"))
			max_impact(index_e) = CDbl(re("max_impact"))
			ss_impact(index_e) = CDbl(re("ss_impact"))
			max_time(index_e) = CDbl(re("max_time"))
			ss_time(index_e) = CDbl(re("ss_time"))
			if dbg = true then response.write "* E" & index_e + 1 & ": max(t" & max_time(index_e) & "|" & max_impact(index_e) & "%); ss(t" & ss_time(index_e) & "|" & ss_impact(index_e) & "%)" & vbcrlf
			index_e = index_e + 1
			re.moveNext
		loop
		
		dim event_occur() 
		redim preserve event_occur(num_events)
		dim event_start() 
		redim preserve event_start(num_events)
			
		for index_s = 1 to scenarios
		
			if dbg = true then response.write "Scenario " & index_s & vbcrlf  end if
						
			index_e = 0			
			do while index_e < num_events
			
				Randomize()
				rand_prob = CInt(100 * Rnd())
				if rand_prob <= probability(index_e) then
					event_occur(index_e) = 1
					if dbg = true then response.write "* Event " & index_e + 1 & ": occurring "  end if
				else
					event_occur(index_e) = 0
					if dbg = true then response.write "* Event " & index_e + 1 & ": not occurring" & vbcrlf  end if
				end if
				
				' Randomize()
				if event_occur(index_e) = 1 then
					event_start(index_e) = CInt((upperbound - lowerbound) * Rnd()) + lowerbound
					if dbg = true then response.write "at " & event_start(index_e) & vbcrlf  end if
				else
					event_start(index_e) = 0
				end if
				
				index_e = index_e + 1
			loop
			
						
			' Per occurring event, 3(4) stages:
			
			' Stage 0: x < event_start (no changes)
			' y' = y
			
			' Stage 1: event_start <= x < max_time
			' Proportional impact (linear):
			'            x          vs    impact
			'     event_start       -      0
			' event_start+max_time  -  max_impact
			'      x (given)        -   y (calc)
			'
			' a = (y2-y1)/(x2-x1)
			' coef = max_impact/max_time
			' b = y-ax
			' offset = max_impact - (coef*(event_start+max_time))
			' prob_frac = coef*x + offset
			' y' = y * (1 + (prob_frac/100))
			
			' Stage 2: max_time <= x < ss_time
			' Proportional impact (linear):
			'            x          vs    impact
			' event_start+max_time  -  max_impact
			'  event_start+ss_time  -  ss_impact
			'      x (given)        -  y (calc)
			'
			' a = (y2-y1)/(x2-x1)
			' coef = (ss_impact - max_impact)/(ss_time - max_time)
			' b = y-ax
			' offset = ss_impact - (coef*(event_start+ss_time))
			' prob_frac = coef*x + offset
			' y' = y * (1 + (prob_frac/100))
			
			' Stage 3: x >= ss_time (steady_state)
			' y' = y * (1 + (ss_impact/100))
			
			call getRecordSet(SQL_READ_BASERESULTPOINTS(me.id), br1)
			br1.moveFirst
			
			pointID = 1

			max_diff = 0
			ss_diff = 0
			
			do while not br1.eof
				
				x = CDbl(br1("X"))
				y = CDbl(br1("Z"))
				if dbg = true then response.write "- Point: (" & x & "," & y & ")"  end if
				
				for index_e = 0 to num_events-1
				
					if event_occur(index_e) = 1 then
					
					
						' Stage 0
						if x <= event_start(index_e) then
							y = y
						
						' Stage 1
						elseif x >= event_start(index_e) and x < event_start(index_e)+max_time(index_e) then
							coef = max_impact(index_e)/max_time(index_e)
							offset = max_impact(index_e) - (coef*(event_start(index_e)+max_time(index_e)))
							prob_frac = coef*x + offset
							y = y * (1 + (prob_frac/100))
							if dbg = true then response.write " | 1-E" & index_e+1 & "S1: " & prob_frac & "%"  end if
							if x = event_start(index_e)+max_time(index_e) then max_diff = y - CDbl(br1("Z")) end if
						
						' Stage 2
						elseif x >= event_start(index_e)+max_time(index_e) and x < event_start(index_e)+ss_time(index_e) then
							if ss_impact(index_e) - max_impact(index_e) <> 0 then
								coef = (ss_impact(index_e) - max_impact(index_e))/(ss_time(index_e) - max_time(index_e))
								offset = max_impact(index_e) - (coef*(event_start(index_e)+max_time(index_e)))
								prob_frac = coef*x + offset
								y = y * (1 + (prob_frac/100))
							else 
								y = y + max_diff
							end if
							if dbg = true then response.write " | 2-E" & index_e+1 & "S2: " & prob_frac & "%"   end if
							if x = event_start(index_e)+ss_time(index_e) then ss_diff = y - CDbl(br1("Z")) end if
							
						' Stage 3
						elseif x > event_start(index_e)+ss_time(index_e) then
							y = y  + ss_diff
							if dbg = true then response.write " | 3-E" & index_e+1 & "S3: " & ss_impact(index_e) & "%"  end if
						end if
						
					end if
					
				next
				call ExecuteSQL(SQL_CREATE_RESULTPOINT(pointID, me.id, index_s, x, Empty, y, Null))
				
				if dbg = true then response.write " => (" & x & "," & y & ")" & vbCrLf  end if
				pointID = pointID + 1
				br1.moveNext
				
			loop
			
		next
		
		' Min/Max/Median
		dim rx, rz, min, med, max
		call getRecordSet(SQL_READ_X_FORECAST(me.id), rx)
		do while not rx.eof
			'response.write rx("x") & " -> " 
			base_x = rx("x")
			call getRecordSet(SQL_READ_Z_FORECAST(me.id, rx("x")), rz)
			rz.moveFirst
			call ExecuteSQL(SQL_CREATE_RESULTPOINT(rx("pointID"), me.id, 0, base_x, Empty, rz("z"), "Min"))
			rz.moveLast
			call ExecuteSQL(SQL_CREATE_RESULTPOINT(rx("pointID"), me.id, 0, base_x, Empty, rz("z"), "Max"))
			med = .0
			rz.moveFirst
			if rz.recordCount mod 2 = 0 then
				rz.move(rz.recordCount \ 2)
				med = med + CDbl(rz("z"))
				rz.movePrevious
				med = med + CDbl(rz("z"))
				med = med / 2
			else
				rz.move((rz.recordCount-1) \ 2)
				med = rz("z")
			end if
			call ExecuteSQL(SQL_CREATE_RESULTPOINT(rx("pointID"), me.id, 0, base_x, Empty, rz("z"), "Median"))
			'response.write  "min=" & min & " | med=" & med & " | max=" & max
			response.write vbCrLf
			rx.moveNext
		loop	
		
		
		
		
	end sub

end class

%>