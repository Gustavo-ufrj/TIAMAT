
<%
class Regression

	public id, coef, result, dbg
	
	public sub class_initialize()
		coef = 0
		dbg = false
	end sub
	
	Public Property Let stepID(newid)
		id = newid
	End Property

		
	public sub execute()
		call getRecordSet(SQL_READ_INFORMATION(me.id), ri)
		adjtype = ri("adj_type")
		
		adjtype_split = Split(adjtype,"|")
		upperlimit = .0
		if UBound(adjtype_split) = 1 then 
			adjtype = adjtype_split(0)
			upperlimit = Cdbl(adjtype_split(1))
		end if
		ri.close
		
		select case adjtype
			case "linear" 
				'call r.LinearRegression (stepID)
				call me.polyRegression (1)
				
			case "quad" 
				call me.polyRegression (2)
				
			case "cub" 
				call me.polyRegression (3)
				
			case "exp" 
				call me.expRegression (false, false)
				
			case "negexp" 
				call me.expRegression (true, false)
				
			case "invexp" 
				call me.expRegression (false, true)
				
			case "niexp" 
				call me.expRegression (true, true)
				
			case "pearl" 
				call me.pearlRegression (upperlimit)
				
			case "gompertz" 
				call me.gompertzRegression (upperlimit)
				
			case "bestfit"
				dim r2, res
				
				' Linear
				call me.polyRegression (1)
					r2 = me.coef
					res = me.result
				
				' Quad
				call me.polyRegression (2)
				if abs(1 - me.coef) < abs(1 - r2) then
					r2 = me.coef
					res = me.result
				end if
				
				' Cubic
				call me.polyRegression (3)
				if abs(1 - me.coef) < abs(1 - r2) then
					r2 = me.coef
					res = me.result
				end if
				
				call me.polyRegression (4)
				if abs(1 - me.coef) < abs(1 - r2) then
					r2 = me.coef
					res = me.result
				end if
				
				call me.polyRegression (5)
				if abs(1 - me.coef) < abs(1 - r2) then
					r2 = me.coef
					res = me.result
				end if
				
				call me.polyRegression (6)
				if abs(1 - me.coef) < abs(1 - r2) then
					r2 = me.coef
					res = me.result
				end if

				
				' Exp
				call me.expRegression (false, false)
				if abs(1 - me.coef) < abs(1 - r2) then
					r2 = me.coef
					res = me.result
				end if
				
				' Neg Exp
				call me.expRegression (true, false)
				if abs(1 - me.coef) < abs(1 - r2) then
					r2 = me.coef
					res = me.result
				end if
				
				' Inv Exp
				call me.expRegression (false, true)
				if abs(1 - me.coef) < abs(1 - r2) then
					r2 = me.coef
					res = me.result
				end if
				
				' Neg/Inv Exp
				call me.expRegression (true, true)
				if abs(1 - me.coef) < abs(1 - r2) then
					r2 = me.coef
					res = me.result
				end if
				
				me.coef = r2
				me.result = res
				
		end select
		
	end sub
	
	
	public sub LinearRegression() 
		dim ri, rp, index

		if me.id <> "" then
				
			call getRecordSet(SQL_READ_POINTS_FOR_GRAPH(me.id), rp)
			if rp.eof then 
				call Response.Write ("Empty data.")
				exit sub
			end if
						
			call getRecordSet(SQL_READ_INFORMATION(me.id), ri)
					
			' meanStep = 0
			' first_x = rp("x")
			' last_x = rp("x")
		
			' do while not rp.eof		
				' meanStep = meanStep + rp("x") - last_x
				' last_x = rp("x")
				' rp.movenext 
			' loop
			' rp.moveFirst
			' meanStep = meanStep / (rp.recordCount - 1)
			meanStep = 1
			
			range = ri("range")
			if range <> "" then
				range = CDbl(ri("range"))
			' else range = last_x + meanStep
			end if		
				
			' y = a0 + a1*x
			' a1 = ((n * sum(x*y)) - (sum(x) * sum(y)) / ((n * sum(x^2)) - (sum(x)^2)))
			' a0 = ((sum(y) - (a1 * sum(x))) / n)
			
			' Linear least squares
			x_sum = 0
			x2_sum = 0
			y_sum = 0
			xy_sum = 0
			y_mean = 0
			rp.moveFirst
			do while not rp.eof		
				x_sum = x_sum + rp("x")	
				y_sum = y_sum + rp("y") 
				x2_sum = x2_sum + (rp("x") * rp("x"))
				xy_sum = xy_sum + (rp("x") * rp("y"))
				rp.movenext 
			loop
			rp.moveFirst
			y_mean = y_sum / rp.recordCount
			a1 = ((rp.recordCount * xy_sum) - (x_sum * y_sum)) / ((rp.recordCount * x2_sum) - (x_sum * x_sum))
			a0 = (y_sum - (x_sum * a1)) / rp.recordCount
			
			dim l1()
			redim preserve l1(rp.recordCount)
			
			index = 0
			rp.moveFirst
			do while not rp.eof	
				set d = createObject("scripting.dictionary")	
				d.add "x", CDbl(rp("x"))
				d.add "y", CDbl(rp("y"))
				d.add "z", a0 + a1*CDbl(rp("x"))
				set l1(index) = d
				index = index + 1
				rp.moveNext
			loop
			rp.moveLast
			x = rp("x") + meanStep
			index = rp.recordCount
			'do while x < ((range/100 * last_x) + (last_x + meanStep))
			do while x < range
				redim preserve l1(index)
				set d = createObject("scripting.dictionary")	
				d.add "x", x
				d.add "y", Empty
				d.add "z", a0 + a1*x
				set l1(index) = d
				index = index + 1
				x = x + meanStep
			loop
			redim preserve l1(index)
			set d = createObject("scripting.dictionary")	
			d.add "x", range
			d.add "y", Empty
			d.add "z", a0 + a1*range
			set l1(index) = d
			
			'Determination coeficient
			sq_exp = 0
			sq_tot = 0
			rp.moveFirst
			do while not rp.eof
				sq_exp = sq_exp + ((a0 + a1*(cdbl(rp("x"))) - y_mean)^2)
				sq_tot = sq_tot + (		    (cdbl(rp("y"))  - y_mean)^2)
				rp.moveNext
			loop
			coef = sq_exp / sq_tot
			
			set dp = createObject("scripting.dictionary")
			dp.add "method", "linear"	
			dp.add "R2", coef
			dp.add "a0", a0
			dp.add "a1", a1
			set d = createObject("scripting.dictionary")	
			d.add "parameters", dp
			d.add "values", l1
			
			'save dp, ll
			me.result = array(dp,ll)
			'result = (new JSON)(Empty, d, false)
			'Response.ContentType = "application/json; charset=utf-8"
			'Response.Write (jsonResult)
			'Response.End
			
		end if 
		
	end sub
		
	sub expRegression(negative, inverse) 
		dim ri, rp, index
		
		method = ""
		if negative = true then 
			if inverse = true then 	method = "niexp"  else method = "negexp"
		else 
			if inverse = true then 	method = "invexp" else method = "exp"
		end	if
		
		if dbg = true then response.write vbCrLf & "Exponential Regression --- " & method & vbcrlf end if
		
		if me.id <> "" then
				
			call getRecordSet(SQL_READ_POINTS_FOR_GRAPH(me.id), rp)
			if rp.eof then 
				call Response.Write ("Empty data.")
				exit sub
			end if
		
			call getRecordSet(SQL_READ_INFORMATION(me.id), ri)
			' meanStep = 0
			' first_x = rp("x")
			' last_x = rp("x")

			' do while not rp.eof		
				' meanStep = meanStep + rp("x") - last_x
				' last_x = rp("x")
				' rp.movenext 
			' loop
			' rp.moveFirst
			' meanStep = meanStep / (rp.recordCount - 1)
			meanStep = 1
			
			range = ri("range")
			if range <> "" then
				range = CDbl(ri("range"))
			' else range = last_x + meanStep 
			end if
				
			' y = e^(a0 + a1*x) -> exp
			' y = e^(a0 - a1*x) -> invexp
			' ln y = a0 +- a1*x
			' ==> w = v +- u*x
			' w = ln y; v = a0; u = +-a1
			' u = ((n * sum(x*w)) - (sum(x) * sum(w)) / ((n * sum(x^2)) - (sum(x)^2)))
			' v = ((sum(w) - (a * sum(x))) / n)
				
			' Linear least squares
			x_sum = 0
			x2_sum = 0
			w_sum = 0
			xw_sum = 0
			do while not rp.eof	
				if rp("y") > 0 then
					x_sum = x_sum + rp("x")	
					x2_sum = x2_sum + (rp("x") * rp("x"))
					w_sum = w_sum + log(rp("y")) 
					xw_sum = xw_sum + (rp("x") * log(rp("y")))
				end if
				rp.movenext 
			loop
			
			if dbg = true then
				response.write " x_sum = " 	& x_sum		& vbCrLf
				response.write " x2_sum = " & x2_sum    & vbCrLf
				response.write " w_sum = " 	& w_sum     & vbCrLf
				response.write " xw_sum = " & xw_sum    & vbCrLf
			response.write vbcrlf
			end if
			
			rp.moveFirst
			u = ((rp.recordCount * xw_sum) - (x_sum * w_sum)) / ((rp.recordCount * x2_sum) - (x_sum * x_sum))
			v = (w_sum - (x_sum * u)) / rp.recordCount
			if negative = false then a1 = u else a1 = -1*u end if
			if inverse = false then a1 = a1 else a1 = 1/a1 end if
			a0 = v
			
			if dbg = true then
				response.write " a0 = " 	& a0	& vbCrLf
				response.write " a1 = " 	& a1    & vbCrLf
			response.write vbcrlf
			end if
			
			
			dim l()
			redim preserve l(rp.recordCount)
			
			index = 0
			rp.movefirst
			do while not rp.eof	
				set d = createObject("scripting.dictionary")	
				d.add "x", CDbl(rp("x"))
				d.add "y", CDbl(rp("y"))
				d.add "z", exp(a0 + a1*CDbl(rp("x")))
				set l(index) = d
				index = index + 1
				rp.moveNext
			loop
			x = last_x + meanStep
			index = rp.recordCount
			'do while x < ((range/100 * last_x) + (last_x + meanStep))
			do while x < range
				redim preserve l(index)
				set d = createObject("scripting.dictionary")	
				d.add "x", x
				d.add "y", Empty
				d.add "z", exp(a0 + a1*x)
				set l(index) = d
				index = index + 1
				x = x + meanStep
			loop
			redim preserve l(index)
			set d = createObject("scripting.dictionary")	
			d.add "x", range
			d.add "y", Empty
			d.add "z", exp(a0 + a1*range)
			set l(index) = d
			
			'Determination coeficient
			sq_exp = 0
			sq_tot = 0
			rp.moveFirst
			do while not rp.eof
				sq_exp = sq_exp + ((a0*exp(a1*cdbl(rp("x"))) - y_mean)^2)
				sq_tot = sq_tot + (		   (cdbl(rp("y"))  - y_mean)^2)
				rp.moveNext
			loop
			coef = sq_exp / sq_tot
			if dbg = true then
				Response.Write "End. R2 = " & sq_exp & "/" & sq_tot & " = " & coef & vbCrLf
			end if
				
			set dp = createObject("scripting.dictionary")	
			dp.add "method", method
			dp.add "R2", coef
			dp.add "a0", a0
			dp.add "a1", a1
			set d = createObject("scripting.dictionary")	
			d.add "parameters", dp
			d.add "values", l
			
			'save dp, l
			me.result = array(dp,l)
			'result = (new JSON)(Empty, d, false)
			'Response.ContentType = "application/json; charset=utf-8"
			'Response.Write (result)
			'Response.End
		
			
		end if
		
	end sub
		
		
	sub polyRegression (degree) 
		dim ri, rp, index
		if dbg = true then response.write vbCrLf & "Polynomial Regression --- Initial degree: " & degree & vbcrlf end if
		APPROX =  0.0000000001
		
		if me.id <> "" then
				
			call getRecordSet(SQL_READ_POINTS_FOR_GRAPH(me.id), rp)
			if rp.eof then 
				call Response.Write ("Empty data.")
				exit sub
			end if

			call getRecordSet(SQL_READ_INFORMATION(me.id), ri)
					
			' meanStep = 0
			' first_x = rp("x")
			' last_x = rp("x")
		
			' do while not rp.eof		
				' meanStep = meanStep + rp("x") - last_x
				' last_x = rp("x")
				' rp.movenext 
			' loop
			' rp.moveFirst
			' meanStep = meanStep / (rp.recordCount - 1)
			meanStep = 1
			
			range = ri("range")
			if range <> "" then
				range = CDbl(ri("range"))
			' else range = last_x + meanStep 
			end if
					

			y_mean = 0
			rp.moveFirst
			do while not rp.eof
				y_mean = y_mean + cdbl(rp("y"))
				rp.moveNext
			loop
			y_mean = y_mean/rp.recordCount
			
			'matrix for x sums: [n, sum(x), sum(x^2), ... , sum(x^(n+2))]
			dim sumx()
			redim sumx(2 * degree + 1)
			sumx(0) = rp.recordCount
			n = 1
			do while n < 2 * degree + 1
				sum = 0	
				rp.movefirst						
				do while not rp.eof	
					sum = sum + (CDbl(rp("x"))^n)
					rp.moveNext
				loop
				sumx(n) = sum
				n = n + 1
			loop
			
			if dbg = true then
			v = 0
			response.write " sumx = " 
			do while v < 2 * degree + 1
				response.write(sumx(v)) & " | "
				v = v + 1
			loop
			response.write vbcrlf
			end if
			
			'matrix for xy sums = [sum(y), sum(yx), sum(yx^2), ..., sum(yx^n)]
			dim sumxy()
			redim sumxy(degree + 1)
			n = 0
			do while n <= degree
				sum = 0	
				rp.movefirst						
				do while not rp.eof	
					sum = sum + (rp("y")*((rp("x")^n)))
					rp.moveNext
				loop
				rp.movefirst
				sumxy(n) = sum
				n = n + 1
			loop
			
			if dbg = true then
			v = 0
			response.write " sumxy = " 
			do while v < degree + 1
				response.write(sumxy(v)) & " | "
				v = v + 1
			loop
			response.write vbcrlf
			end if
			
			'Gauss elimination
			
			'augmented matrix
			dim a()
			redim a(degree+1,degree+2)
			i = 0 
			do while i < degree+1
				j = 0
				do while j < degree + 2
					if j = degree + 1 then a(i,j) = sumxy(i) else a(i,j) = sumx(i+j) end if
					j = j + 1
				loop
				i = i + 1
			loop

			if dbg = true then
			i = 0
			response.write "a = " & vbcrlf
			do while i < degree+1
				j = 0
				do while j < degree+2
					response.write a(i,j) & " "
					j = j + 1
				loop
				response.write vbCrLf
				i = i + 1
			loop
			end if
			
			i = 0
			dim m()
			do while i < degree
			
				'multipliers matrix 
				redim m(degree-i-1)
				j = i + 1
				n = 0
				do while j <= degree and n <= degree
					if a(i,i) <> 0 then m(n) = (-1)*a(j,i)/a(i,i) else m(n) = 0 end if
					j = j + 1
					n = n + 1
				loop
				
				'elimination
				i1 = i + 1
				do while i1 <= degree 
					j1 = i
					do while j1 <= degree + 1
						a(i1,j1) = a(i1,j1) + m(i1-i-1)*a(i,j1)
						if abs(a(i1,j1)) < APPROX then a(i1,j1) = 0 end if
						j1 = j1 + 1
						loop
					i1 = i1 + 1
				loop
				
			if dbg = true then
			p = 0
			response.write "m = " & vbcrlf
			do while p < degree+1
				q = 0
				do while q < degree+2
					response.write a(p,q) & " "
					q = q + 1
				loop
				response.write vbCrLf
				p = p + 1
			loop
			end if
			
				
				i = i + 1
			loop
			
			'coeficients
			dim r()
			redim r(degree+1)
			n = 1
			'r(degree) = a(degree,degree+1) / a(degree,degree)
			i = degree '- 1
								
			do while i >= 0
				j = degree
				s = a(i,degree+1)
				if dbg = true then response.write "r(" & i & ")= " & s end if
				do while j > i 
					s = s - (a(i,j) * r(j))
					if dbg = true then response.write " - (" & a(i,j) & " * " & r(j) & ")" end if
					j = j - 1
				loop
				if a(i,j) <> 0 then r(i) = s / a(i,j) else r(i) = 0 end if
				if dbg = true then response.write " / " & a(i,j) & vbcrlf end if 
				if dbg = true then response.write "r(" & i & ")= " & r(i) & vbcrlf end if
				i = i - 1
			loop
			
			' coeficient cleaning
			q = degree
			dg = degree
			do while q > 0
				if abs(r(q)) = 0 then 
					if dbg = true then response.write "Reducing r(" & q & ")= " & r(q) & vbcrlf end if
					dg = dg - 1
					redim preserve r(dg+1)
				else 
					exit do
				end if
				q = q - 1
			loop
			
			'result
			dim lp()
			redim preserve lp(rp.recordCount)
			
			index = 0
			rp.movefirst
			do while not rp.eof	
				set d = createObject("scripting.dictionary")	
				d.add "x", CDbl(rp("x"))
				d.add "y", CDbl(rp("y"))
				z = 0
				n = 0
				do while z <= dg
					n = n + ((CDbl(rp("x")))^(z))*r(z)
					z = z + 1
				loop
				d.add "z", n
				set lp(index) = d
				index = index + 1
				rp.moveNext
			loop
			
			rp.moveLast
			x = CDbl(rp("x")) + meanStep
			index = rp.recordCount
			'do while x < ((range/100 * last_x) + (last_x + meanStep))
			do while x < range
				redim preserve lp(index)
				set d = createObject("scripting.dictionary")	
				d.add "x", x
				d.add "y", Empty
				z = 0
				n = 0
				do while z <= dg
					n = n + (x^z)*r(z)
					z = z + 1
				loop
				d.add "z", n
				set lp(index) = d
				index = index + 1
				x = x + meanStep
			loop
			redim preserve lp(index)
			set d = createObject("scripting.dictionary")	
			d.add "x", range
			d.add "y", Empty
			z = 0
			n = 0
			do while z <= dg
				n = n + (range^z)*r(z)
				z = z + 1
			loop
			d.add "z", n
			set lp(index) = d
			
			
			'Determination coeficient
			sq_exp = 0
			sq_tot = 0
			rp.moveFirst
			do while not rp.eof
				z = 0
				n = 0
				do while z <= dg
					n = n + ((cdbl(rp("x")))^z)*r(z)
					z = z + 1
				loop
				sq_exp = sq_exp + ((            n - y_mean)^2)
				sq_tot = sq_tot + ((cdbl(rp("y")) - y_mean)^2)
				rp.moveNext
			loop
			coef = sq_exp / sq_tot
			if dbg = true then
				Response.Write "End. Final degree = " & dg & vbCrLf & "R2 = " & sq_exp & "/" & sq_tot & " = " & coef & vbCrLf
			end if
			
			if 		dg = 1 then	
				method = "linear"
			elseif 	dg = 2 then	
				method = "quad"
			elseif 	dg = 3 then	
				method = "cubic"
			elseif	dg > 3 then	
				method = dg & "-degree"
			end if
					
			set dp = createObject("scripting.dictionary")	
			dp.add "method", method
			dp.add "R2", coef
			z = 0
			do while z <= dg
					dp.add "a"&z, r(z)
					z = z + 1
			loop
			set d = createObject("scripting.dictionary")	
			d.add "parameters", dp
			d.add "values", lp
			
			'save dp, lp
			me.result = array(dp, lp)
			'result = (new JSON)(Empty, d, false)
			'Response.ContentType = "application/json; charset=utf-8"
			'Response.Write (result)
			'Response.End	
					
		end if
		
	end sub
	
	sub pearlRegression(upperlimit)
		dim ri, rp, index
		if me.id <> "" then
				
			call getRecordSet(SQL_READ_POINTS_FOR_GRAPH(me.id), rp)
			if rp.eof then 
				call Response.Write ("Empty data.")
				exit sub
			end if
						
			call getRecordSet(SQL_READ_INFORMATION(me.id), ri)
				
			meanStep = 1
			
			range = ri("range")
			if range <> "" then
				range = CDbl(ri("range"))
			' else range = last_x + meanStep
			end if		
				
			' y = L / (1 + a*exp(-bx))
			' Substitution: x'=0 at initial series period
			' a -> first tuple (x'=0) -> y = L / (1 + a) -> a = (L - y) / y
			' b -> another tuple (here, series end) -> b = -(log((L-y)/ya))/x
			
			rp.moveFirst
			
			' Substitution: x' = x - x(0)
			x_sub = rp("x")
			
			' Finding a
			a = (upperlimit - rp("y"))/rp("y")
			
			' Finding b
			'if rp.recordCount mod 2 = 0 then
			'	rp.move(rp.recordCount \ 2)
			'else
			'	rp.move((rp.recordCount-1) \ 2)
			'end if
			rp.moveLast
			
			b = (-1)*log((upperlimit-rp("y"))/(rp("y")*a))/(rp("x")-x_sub)
			

			dim l1()
			redim preserve l1(rp.recordCount)
							
			' y = L / (1 + a*exp(-bx))
			
			index = 0
			rp.moveFirst
			do while not rp.eof	
				set d = createObject("scripting.dictionary")	
				d.add "x", CDbl(rp("x"))
				d.add "y", CDbl(rp("y"))
				d.add "z", (upperlimit / (1 + a*exp((-1)*b*(rp("x")-x_sub))))
				set l1(index) = d
				index = index + 1
				rp.moveNext
			loop
			rp.moveLast
			x = rp("x") + meanStep
			index = rp.recordCount
			'do while x < ((range/100 * last_x) + (last_x + meanStep))
			do while x < range
				redim preserve l1(index)
				set d = createObject("scripting.dictionary")	
				d.add "x", x
				d.add "y", Empty
				d.add "z", (upperlimit / (1 + a*exp((-1)*b*(x-x_sub))))
				set l1(index) = d
				index = index + 1
				x = x + meanStep
			loop
			redim preserve l1(index)
			set d = createObject("scripting.dictionary")	
			d.add "x", range
			d.add "y", Empty
			d.add "z", (upperlimit / (1 + a*exp((-1)*b*(range-x_sub))))
			set l1(index) = d
			
			'Determination coeficient
			sq_exp = 0
			sq_tot = 0
			rp.moveFirst
			do while not rp.eof
				sq_exp = sq_exp + (((upperlimit / (1 + a*exp((-1)*b*(rp("x")-x_sub)))) - y_mean)^2)
				sq_tot = sq_tot + (		    							(cdbl(rp("y")) - y_mean)^2)
				rp.moveNext
			loop
			coef = sq_exp / sq_tot
			
			set dp = createObject("scripting.dictionary")
			dp.add "method", "pearl"	
			dp.add "R2", coef
			dp.add "a", a
			dp.add "b", b
			set d = createObject("scripting.dictionary")	
			d.add "parameters", dp
			d.add "values", l1
			'save dp, ll
			me.result = array(dp,l1)
			'result = (new JSON)(Empty, d, false)
			'Response.ContentType = "application/json; charset=utf-8"
			'Response.Write (jsonResult)
			'Response.End
			
		end if 
		
	end sub
		
		
	sub gompertzRegression(upperlimit)
		dim ri, rp, index
		if me.id <> "" then
				
			call getRecordSet(SQL_READ_POINTS_FOR_GRAPH(me.id), rp)
			if rp.eof then 
				call Response.Write ("Empty data.")
				exit sub
			end if
						
			call getRecordSet(SQL_READ_INFORMATION(me.id), ri)
				
			meanStep = 1
			
			range = ri("range")
			if range <> "" then
				range = CDbl(ri("range"))
			' else range = last_x + meanStep
			end if		
				
			' y = L * exp( -b * exp(-kx) )
			' Substitution: x'=0 at initial series period
			' b -> first tuple (x'=0)
			' y = L /(exp(b))
			' b = ln(L/y)
			' k -> another tuple (here, series end)
			' exp( -b * exp(-kx) ) = y/L
			' exp( b * exp(-kx) ) = L/y
			' b * exp(-kx) = ln(L/y)
			' exp(-kx) = ln(L/y)/b
			' exp(kx) = b/ln(L/y)
			' kx = ln(b/ln(L/y))
			' k = ln(b/ln(L/y))/x
			
			rp.moveFirst
			
			' Substitution: x' = x - x(0)
			x_sub = rp("x")
			
			' Finding b
			b = log(upperlimit/rp("y"))
			
			' Finding k
			'if rp.recordCount mod 2 = 0 then
			'	rp.move(rp.recordCount \ 2)
			'else
			'	rp.move((rp.recordCount-1) \ 2)
			'end if
			rp.moveLast
			
			k = (log(b/(log(upperlimit/rp("y")))))/(rp("x")-x_sub)
			response.write b & vbCrLf & k
			

			dim l1()
			redim preserve l1(rp.recordCount)
							
			' y = L * exp( b * exp(-kx) )
			index = 0
			rp.moveFirst
			do while not rp.eof	
				set d = createObject("scripting.dictionary")	
				d.add "x", CDbl(rp("x"))
				d.add "y", CDbl(rp("y"))
				d.add "z", (upperlimit * (exp((-1)*b*exp((-1)*k*(rp("x")-x_sub)))))
				set l1(index) = d
				index = index + 1
				rp.moveNext
			loop
			rp.moveLast
			x = rp("x") + meanStep
			index = rp.recordCount
			'do while x < ((range/100 * last_x) + (last_x + meanStep))
			do while x < range
				redim preserve l1(index)
				set d = createObject("scripting.dictionary")	
				d.add "x", x
				d.add "y", Empty
				d.add "z", (upperlimit * (exp((-1)*b*exp((-1)*k*(x-x_sub)))))
				set l1(index) = d
				index = index + 1
				x = x + meanStep
			loop
			redim preserve l1(index)
			set d = createObject("scripting.dictionary")	
			d.add "x", range
			d.add "y", Empty
			d.add "z", (upperlimit * (exp((-1)*b*exp((-1)*k*(range-x_sub)))))
			set l1(index) = d
			
			'Determination coeficient
			sq_exp = 0
			sq_tot = 0
			rp.moveFirst
			do while not rp.eof
				sq_exp = sq_exp + (((upperlimit * (exp((-1)*b*exp((-1)*k*(rp("x")-x_sub))))) - y_mean)^2)
				sq_tot = sq_tot + (		    			       			   	  (cdbl(rp("y")) - y_mean)^2)
				rp.moveNext
			loop
			coef = sq_exp / sq_tot
			
			set dp = createObject("scripting.dictionary")
			dp.add "method", "gompertz"	
			dp.add "R2", coef
			dp.add "a", a
			dp.add "b", b
			set d = createObject("scripting.dictionary")	
			d.add "parameters", dp
			d.add "values", l1
			'save dp, ll
			me.result = array(dp,l1)
			'result = (new JSON)(Empty, d, false)
			'Response.ContentType = "application/json; charset=utf-8"
			'Response.Write (jsonResult)
			'Response.End
			
		end if 
		
	end sub
		
end class

%>