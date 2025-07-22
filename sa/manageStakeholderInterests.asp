<!--#include virtual="/system.asp"-->
<!--#include virtual="/checklogin.asp"-->
<!--#include virtual="/checkadmin.asp"-->
<!--#include file="INC_SA.inc"-->

<%
saveCurrentURL

tiamat.addCSS("sa.css")

render.renderTitle()
%>

<%
' Calculo das opções de Critérios 

	Dim stakeholderList, interestList
	call getRecordSet(SQL_CONSULTA_STAKEHOLDER(Request.QueryString("SAID")), rs)

	stakeholderList = ""

	if not rs.eof then
		while not rs.eof
			stakeholderList = stakeholderList + "{ Value: '"+ cstr(rs("stakeholderID"))+"', DisplayText: '" +rs("ContactName")+ "'}"
			rs.movenext
		if not rs.eof then
		stakeholderList = stakeholderList + ", "
		end if
		wend
	end if

	stakeholderList = "[" + stakeholderList + "]"


' Calculo das opções de Opções

	call getRecordSet(SQL_CONSULTA_INTEREST(Request.QueryString("SAID")), rs)

	interestList = ""

	if not rs.eof then
		while not rs.eof
			interestList = interestList + "{ Value: '"+ cstr(rs("interestID"))+"', DisplayText: '" +rs("Interest")+ "'}"
			rs.movenext
		if not rs.eof then
		interestList = interestList + ", "
		end if
		wend
	end if

	interestList = "[" + interestList + "]"

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
													<p class="font_6" align="justify">MANAGE STAKEHOLDER INTERESTS <font color="red">//</font></p>
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
																title: 'Stakeholder List',
																paging: false, //Enable paging
																sorting: false, //Enable sorting
																columnResizable: false, //Disable column resizing
																columnSelectable: false, //Disable column selecting
																openChildAsAccordion: true, //Enable this line to show child tables as accordion style
																actions: {
																	listAction: 'stakeholderInterestsAction.asp?action=list&SAID=<%=Request.QueryString("SAID")%>',
																	createAction: 'stakeholderInterestsAction.asp?action=new&SAID=<%=Request.QueryString("SAID")%>',
																	updateAction: 'stakeholderInterestsAction.asp?action=update&SAID=<%=Request.QueryString("SAID")%>',
																	deleteAction: 'stakeholderInterestsAction.asp?action=delete&SAID=<%=Request.QueryString("SAID")%>'
																},
																fields: {
																	stakeholderinterestid: {
																		title: 'StakeholderInterestID',																		
																		key: true,
																		edit: false,
																		visibility: 'hidden' 																		
																	},
																	
																	stakeholderid: {
																		title: 'Stakeholder',
																		width: '50%',
																		options: <%=stakeholderList%>
																	},
																	
																	interestid: {
																		title: 'Interest',
																		width: '50%',
																		options: <%=interestList%>
																	}
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