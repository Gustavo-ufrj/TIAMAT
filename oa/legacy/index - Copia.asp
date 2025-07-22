<!--#include virtual="/system.asp"-->
<!--#include virtual="/checkstep.asp"-->
<!--#include file="INC_OA.inc"-->

<%saveCurrentURL
													
call getRecordSet (SQL_CONSULTA_OA(request.querystring("stepID")), rs)
												
if rs.eof then
	response.redirect "editOA.asp?stepID="+request.querystring("stepID")
	response.end
end if

render.renderTitle()

%>



<%

function ConvertImpact(impact)
ImpactList = Array("++","+","=","-","--","?")
ConvertImpact = ImpactList(impact-1)
end function



Dim rsOptions, rsCriteria, rsEffect



 call getRecordSet(SQL_CONSULTA_EFFECT(cstr(rs("OAID"))),rsEffect)
  
 call getRecordSet(SQL_CONSULTA_OPTION(cstr(rs("OAID"))),rsOptions)

Dim larguraTabela

larguraTabela = rsOptions.recordCount * 2 + 3

%>


							<table class="principal" width=100%>
								<tr>
									<td width=20px>
										&nbsp;
									</td>
									<td align=center>
										<table width=1184 class="padded">

											<!-- INICIO AREA EDITAVEL -->
							

											<tr>
												<td>
													<table width=100%>
														<tr>
															<td>
																<p class="font_6" align="justify">OPTION ANALYSIS <font color="red">//</font></p>							
															</td>
															<td align=right>
																<%if getStatusStep(request.querystring("stepID")) = STATE_ACTIVE then %>
																<button class="TIAMATButton" style="width:200px;" onclick="window.location.href='/stepsupportInformation.asp?stepID=<%=request.queryString("stepID")%>';">Supporting Information</button>
																<button class="TIAMATButton" onclick="window.location.href='/workflowActions.asp?action=end&stepID=<%=request.queryString("stepID")%>'">Finish</button>
																<%end if%>
															</td>
														</tr>
													</table>
												</td>
											</tr>
											<tr>
												<td>
												<hr class="linhaDupla">
												</td>
											</tr>

											<tr>
												<td>
													<table width=100% class="padded">
														<tr>
															<td>
																
																
																<table style="border: solid 1px black;" width=100%>
																	<tr style="border: solid 1px black;">
																		<td align=right><b>Benefit: &nbsp;</b></td>	
																		<td colspan=<%=larguraTabela-1%>><%=rs("benefit")%></td>
																	</tr>
																	
																	<tr style="border: solid 1px black;">
																		<td style="border: solid 1px black;text-align:center;">Effect</td>
																		<td style="border: solid 1px black;text-align:center;">Nature of Effect</td>
																		
																		<% 
																		dim i
																		i=1
																		while not rsOptions.eof 
																		%>
																		<td colspan=2 style="border: solid 1px black;text-align:center;">
																			Option <%=cstr(i)%><br><%=rsOptions("Name")%>
																		</td>
																		<% 
																			i=i+1
																			rsOptions.movenext
																			Wend
																			on error resume next
																			rsOptions.MoveFirst
																			on error goto 0
																		%>

																		<td style="border: solid 1px black;text-align:center;">Status Quo</td>																		
																	</tr>
																	
																	
																	<%
																	
																	while not rsEffect.eof
																	
																		call getRecordSet(SQL_CONSULTA_CRITERIA(cstr(rsEffect("effectID"))),rsCriteria)
																		if not rsCriteria.eof then
																	%>
																	<tr>
																		<td rowspan=<%=rsCriteria.RecordCount%> style="border: solid 1px black;text-align:center;"><%=rsEffect("desiredeffect")%></td>
																		
																																					
																			<%
																			while not rsCriteria.eof 
																			%>
																			<% if rsCriteria.AbsolutePosition > 1 then%> <tr> <%end if%> 
																			
																				<td style="border: solid 1px black;text-align:center;">
																				<%=rsCriteria("natureofeffect")%>
																				</td>

																				
																				<%
																				while not rsOptions.eof
																				
																					call getRecordSet(SQL_CONSULTA_IMPACT_BY_OPTIONID_CRITERIAID(cstr(rsOptions("optionID")), cstr(rsCriteria("criteriaID"))), rsImpact)
																					if not rsImpact.eof then
																					
																				%>
																					<td style="border: solid 1px black;padding:3px;vertical-align:top;"> <%=rsImpact("effect")%></td>
																					<td width=20px style="border: solid 1px black;text-align:center;vertical-align:top;"> <%=ConvertImpact(rsImpact("impact"))%></td>
																				<%else%>															
																					<td style="border: solid 1px black;text-align:center;">&nbsp;</td>
																					<td width=20px style="border: solid 1px black;text-align:center;">&nbsp;</td>
																				<%
																				end if
																				rsOptions.movenext
																				wend
																				on error resume next
																				rsOptions.MoveFirst
																				on error goto 0
																				
																				%>	

																				<td style="border: solid 1px black;padding:3px;vertical-align:top;">
																				<%=rsCriteria("statusquo")%>
																				</td>
																				
																				 </tr>  
																			
																			<% 																			
																				rsCriteria.movenext
																				Wend
																				
																			%>
																			
																			
																		
																		
																	</tr>
																		<% 		end if																	
																				rsEffect.movenext
																				Wend
																		%>

																	
																</table>
<pre>
++ Large positive impact compared to the status quo.
+  Small positive impact compared to the status quo.
=  No impact compared to the status quo. 
-  Small negative impact compared to the status quo.
-- Large negative impact compared to the status quo.
?  No evidentiary basis for evaluating the effect.
</pre>
																
																
																
																
															</td>
														</tr>
													</table>
												</td>
											</tr>
											<tr>
												<td>
													<hr class="linhaDupla">
												</td>
											</tr>
											
											<tr>
												<td align=center>
												<%if getStatusStep(request.querystring("stepID")) = STATE_ACTIVE then %>
												<button class="TIAMATButton" style="width:150px;" onclick="window.location.href='editOA.asp?stepID=<%=request.queryString("stepID")%>'">Manage Benefit</button>
												<button class="TIAMATButton" style="width:150px;" onclick="window.location.href='manageEffects.asp?stepID=<%=request.queryString("stepID")%>&OAID=<%=cstr(rs("OAID"))%>'">Manage Effects</button>
												<button class="TIAMATButton" style="width:150px;" onclick="window.location.href='manageOptions.asp?stepID=<%=request.queryString("stepID")%>&OAID=<%=cstr(rs("OAID"))%>'">Manage Options</button>
												<button class="TIAMATButton" style="width:150px;" onclick="window.location.href='manageImpacts.asp?stepID=<%=request.queryString("stepID")%>&OAID=<%=cstr(rs("OAID"))%>'">Manage Impacts</button>
												<%end if%>
												</td>
											

										<!-- FIM AREA EDITAVEL -->

											</tr>
										</table>
									</td>
									<td width=20px>
									&nbsp;&nbsp;&nbsp;
									</td>
								</tr>
							</table>
<%
render.renderFooter()
%>
