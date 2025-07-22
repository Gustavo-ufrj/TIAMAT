<!--#include virtual="/system.asp"-->
<!--#include file="INC_OA.inc"-->
<!--#include virtual="/checklogin.asp"-->
<!--#include virtual="/checkadmin.asp"-->

<%
saveCurrentURL
render.renderTitle()
%>

<%
' Calculo das opções de Critérios 

	Dim criteriaList, optionList
	call getRecordSet(SQL_CONSULTA_CRITERIA_BY_OAID(Request.QueryString("OAID")), rs)

	criteriaList = ""

	if not rs.eof then
		while not rs.eof
			criteriaList = criteriaList + "{ Value: '"+ cstr(rs("criteriaID"))+"', DisplayText: '" +rs("desiredeffect") + " - " + rs("natureofeffect")+ "'}"
			rs.movenext
		if not rs.eof then
		criteriaList = criteriaList + ", "
		end if
		wend
	end if

	criteriaList = "[" + criteriaList + "]"


' Calculo das opções de Opções

	call getRecordSet(SQL_CONSULTA_OPTION(Request.QueryString("OAID")), rs)

	optionList = ""

	if not rs.eof then
		while not rs.eof
			optionList = optionList + "{ Value: '"+ cstr(rs("optionID"))+"', DisplayText: '" +rs("name")+ "'}"
			rs.movenext
		if not rs.eof then
		optionList = optionList + ", "
		end if
		wend
	end if

	optionList = "[" + optionList + "]"

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
													<p class="font_6" align="justify">MANAGE IMPACTS <font color="red">//</font></p>
												</td>
											</tr>
											<tr>
												<td>
												<hr class="linhaDupla">
												</td>
											</tr>
											<tr>
												<td>
													<div id="jTableContainer"></div>
													
													<script type="text/javascript">
														$(document).ready(function () {

															//Prepare jTable
															$('#jTableContainer').jtable({
																title: 'Effect List',
																paging: false, //Enable paging
																sorting: false, //Enable sorting
																columnResizable: false, //Disable column resizing
																columnSelectable: false, //Disable column selecting
																actions: {
																	listAction: 'impactActions.asp?action=list&OAID=<%=Request.QueryString("OAID")%>',
																	createAction: 'impactActions.asp?action=new&OAID=<%=Request.QueryString("OAID")%>',
																	updateAction: 'impactActions.asp?action=update&OAID=<%=Request.QueryString("OAID")%>',
																	deleteAction: 'impactActions.asp?action=delete&OAID=<%=Request.QueryString("OAID")%>'
																},
																fields: {
																	criteriaid: {
																		title: 'Criteria',																		
																		width: '20%',
																		options: <%=criteriaList%>
																	},		
																	optionid: {
																		title: 'Option',																		
																		width: '20%',
																		options: <%=optionList%>
																	},																	
															
																	effect: {
																		title: 'Effect',
																		width: '55%',
																		input: function (data) {
																			if (data.record) {
																				return '<textarea name="effect" style="width:300px; height:100px;">' + data.record.effect + '</textarea>';
																			} else {
																				return '<textarea name="effect" style="width:300px; height:100px;" />';
																			}
																		}
																	},
																	impact: {
																		title: 'Impact',
																		width: '5%',
																		options: [{Value:'1',DisplayText:'++'},{Value:'2',DisplayText:'+'},{Value:'3',DisplayText:'='},{Value:'4',DisplayText:'-'},{Value:'5',DisplayText:'--'},{Value:'6',DisplayText:'?'}]
																	},
																	deletekey: {
																		title: 'Delete Key',																		
																		key: true,
																		create: false,
																		edit: false,
																		visibility: 'hidden' 																		
																	},
																}
															});

															//Load person list from server
															$('#jTableContainer').jtable('load');

														});

													</script>
 
													
												</td>
											</tr>
											<tr>
												<td>
												<hr class="linhaDupla">
												</td>
											</tr>
											
											<tr>
												<td align=center>
														<button class="TIAMATButton" onclick="window.location.href='index.asp?stepID=<%=request.queryString("stepID")%>'">Back</button>
												</td>
											</tr>

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