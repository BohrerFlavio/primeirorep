#INCLUDE 'TBICONN.CH'

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³PS101MAN  ºAutor  ³Ezequiel Pianegonda º Data ³  20/06/2017 º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³Validacao do usuario e abertura do browser principal        º±±
±±º          ³                                                            º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ AP                                                        º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/

User Function PS101MAN()
	Local cHtml:= ""
	Local oDlg:= Nil
	Local oBtn:= Nil
	Local cScript:= ""
	Local oAlert:= Nil
	Local cUser:= HTTPPOST->PS100MAN_GET_USER
	Local cPass:= HTTPPOST->PS100MAN_GET_PASS

	If ValType(HTTPSESSION->cEMP) == "U" .OR. ValType(HTTPSESSION->cFil) == "U" .OR. ValType(HTTPSESSION->cCC) == "U"
		cHtml:= "  $.ajax({"
		cHtml+= "          async: true,"
		cHtml+= "          method: 'POST',"
		cHtml+= "          url: 'u_ps001man.apw',"
		cHtml+= "         }).done(function(data){eval(data);});"
		Return cHtml
	EndIf

	//RPCSetType(3)
	RESET ENVIRONMENT
	PREPARE ENVIRONMENT EMPRESA HTTPSESSION->cEmp FILIAL HTTPSESSION->cFil

	PswOrder(2)
	If PswSeek(Alltrim(cUser), .T.)
		If PswName(cPass)
			aUser:= PswRet()
			ZP1->(dbSetOrder(1))
			If ZP1->(dbSeek(xFilial("ZP2")+aUser[1, 1]))
				HTTPSESSION->cUser:= cUser
				HTTPSESSION->cPass:= cPass

				HTTPSESSION->cCC:= ""
				If !Empty(ZP1->ZP1_CC)
					HTTPSESSION->cCC+= Alltrim(ZP1->ZP1_CC)+";"
				EndIf
				If !Empty(ZP1->ZP1_CC1)
					HTTPSESSION->cCC+= Alltrim(ZP1->ZP1_CC1)+";"
				EndIf
				If !Empty(ZP1->ZP1_CC2)
					HTTPSESSION->cCC+= Alltrim(ZP1->ZP1_CC2)+";"
				EndIf
				If !Empty(ZP1->ZP1_CC3)
					HTTPSESSION->cCC+= Alltrim(ZP1->ZP1_CC3)+";"
				EndIf
				If !Empty(ZP1->ZP1_CC4)
					HTTPSESSION->cCC+= Alltrim(ZP1->ZP1_CC4)+";"
				EndIf
				If !Empty(ZP1->ZP1_CC5)
					HTTPSESSION->cCC+= Alltrim(ZP1->ZP1_CC5)+";"
				EndIf

				If Empty(HTTPSESSION->cCC)
					ZP3->(dbSetOrder(1))
					Do While !ZP3->(EOF())
						HTTPSESSION->cCC+= ZP3->ZP3_CC+";"
						ZP3->(dbSkip())
					EndDo
				EndIf

				HTTPSESSION->lINCLUI:= UPPER(ZP1->ZP1_INC)=="S"
				HTTPSESSION->lALTERA:= UPPER(ZP1->ZP1_ALT)=="S"
				HTTPSESSION->lEXCLUI:= UPPER(ZP1->ZP1_EXC)=="S"
				HTTPSESSION->lCOMPLEMENTA:= UPPER(ZP1->ZP1_COMPL)=="S"
				HTTPSESSION->lHISTORICO:= UPPER(ZP1->ZP1_HIST)=="S"
				HTTPSESSION->lSOLICITA:= UPPER(ZP1->ZP1_SOLICI)=="S"
				
				
				//_cTeste := Left(ZP2->ZP2_STATUS, 1) == 2
				
				oDlg:= PSWebDialog():New("ps101man_dialog_main", HTTPSESSION->cLogo+"<br>Portal de manutencoes",,,,,,.T.)																																																																																																																																																																																																										                         //o conteudo do  ultimo parametro era "ZP2_DTRFIM=##"
				oGrid:= PSWebGrid():New("ps101man_grid_main", HTTPSESSION->cEmp, HTTPSESSION->cFil, "ZP2_LEGEND:Legenda:true;ZP2_STATUS:Status:true;ZP2_CODIGO:Solicitacao:true;ZP2_DATA:Inclusao:true;ZP2_USER:Usuario:true;ZP2_DESC:Descricao:true;ZP2_PRIOR:Prioridade:true;ZP2_NPRIOR:Nova_Prioridade:false;ZP2_PRAZO:Prazo:true;ZP2_NPRAZO:Novo_Prazo:true;ZP2_TIPO:Tipo:false;ZP2_MAQ:Maquina:false;ZP2_MAQPAR:Maq_Parada:false;ZP2_CC:CC:false;ZP2_MAUUSO:Mau_Uso:false;ZP2_NMAUUS:Novo_Mau_Uso:false;ZP2_PREVEN:Preventiva:false;ZP2_CORRET:Corretiva:false;ZP2_MELHOR:Melhoria:false;ZP2_QUALID:Retrabalho_Manut:false;ZP2_DTINI:Data_Inicio:false;ZP2_DTFIN:Data_Fim:false;ZP2_HRINI:Hora_Inicio:false;ZP2_HRFIN:Hora_Fim:false;ZP2_DTSC:DT_Sol_Compra:false;ZP2_DTPC:DT_Ped_Compra:false;ZP2_DTLPC:DT_Lib_Ped_Compra:false;ZP2_DTENT:DT_Entrega:false;ZP2_DTFSC:DT_Final_Sol_Compra:false;ZP2_DTRFIM:DT_Fim_Solicitacao:false;ZP2_HRRFIM:HR_Fim_Solicitacao:false;ZP2_MANUTE:Manutentor:true;ZP2_REATIV:Reativado:false", "ZP2", "substring(ZP2_STATUS,1,1) <> 5") 
				//oGrid:= PSWebGrid():New("ps101man_grid_main", HTTPSESSION->cEmp, HTTPSESSION->cFil, "ZP2_LEGEND:Legenda:true;ZP2_STATUS:Status:true;ZP2_CODIGO:Solicitacao:true;ZP2_DATA:Inclusao:true;ZP2_USER:Usuario:true;ZP2_DESC:Descricao:true;ZP2_PRIOR:Prioridade:true;ZP2_NPRIOR:Nova_Prioridade:false;ZP2_PRAZO:Prazo:true;ZP2_NPRAZO:Novo_Prazo:true;ZP2_TIPO:Tipo:false;ZP2_MAQ:Maquina:false;ZP2_MAQPAR:Maq_Parada:false;ZP2_CC:CC:false;ZP2_MAUUSO:Mau_Uso:false;ZP2_NMAUUS:Novo_Mau_Uso:false;ZP2_PREVEN:Preventiva:false;ZP2_CORRET:Corretiva:false;ZP2_MELHOR:Melhoria:false;ZP2_QUALID:Qualidade:false;ZP2_DTINI:Data_Inicio:false;ZP2_DTFIN:Data_Fim:false;ZP2_HRINI:Hora_Inicio:false;ZP2_HRFIN:Hora_Fim:false;ZP2_DTSC:DT_Sol_Compra:false;ZP2_DTPC:DT_Ped_Compra:false;ZP2_DTLPC:DT_Lib_Ped_Compra:false;ZP2_DTENT:DT_Entrega:false;ZP2_DTFSC:DT_Final_Sol_Compra:false;ZP2_DTRFIM:DT_Fim_Solicitacao:false;ZP2_HRRFIM:HR_Fim_Solicitacao:false;ZP2_MANUTE:Manutentor:true;ZP2_REATIV:Reativado:false", "ZP2", "")
				oDlg:AddControl(oGrid)

				If HTTPSESSION->lINCLUI
					oBtn:= PSWebButton():New("ps101man_btn_incluir", "Incluir")
					oDlg:AddButton(oBtn)
					cScript:= "$('#ps101man_btn_incluir').click(function(){"
					cScript+= "$(this).prop('disabled', true);"
					cScript+= "  $.ajax({"
					cScript+= "          async: true,"
					cScript+= "          method: 'POST',"
					cScript+= "          url: 'u_ps110man.apw',"
					cScript+= "         }).done(function(data){$('#ps101man_btn_incluir').prop('disabled', false);eval(data);});"
					cScript+= "});"
					oDlg:AddScript(cScript)
				EndIf

				If HTTPSESSION->lALTERA
					oBtn:= PSWebButton():New("ps101man_btn_alterar", "Alterar")
					oDlg:AddButton(oBtn)
					cScript:= "$('#ps101man_btn_alterar').click(function(){"
					cScript+= "$(this).prop('disabled', true);"
					cScript+= "  $.ajax({"
					cScript+= "          async: true,"
					cScript+= "          method: 'POST',"
					cScript+= "          url: 'u_ps130man.apw',"
					cScript+= "          data:'solicitacao='+table.row('.selected').data()[2]"
					cScript+= "         }).done(function(data){$('#ps101man_btn_alterar').prop('disabled', false);eval(data);});"
					cScript+= "});"
					oDlg:AddScript(cScript)
				EndIf

				If HTTPSESSION->lEXCLUI
					oBtn:= PSWebButton():New("ps101man_btn_excluir", "Excluir")
					oDlg:AddButton(oBtn)
					cScript:= "$('#ps101man_btn_excluir').click(function(){"
					cScript+= "$(this).prop('disabled', true);"
					cScript+= "  $.ajax({"
					cScript+= "          async: true,"
					cScript+= "          method: 'POST',"
					cScript+= "          url: 'u_ps140man.apw',"
					cScript+= "          data:'solicitacao='+table.row('.selected').data()[2]"
					cScript+= "         }).done(function(data){$('#ps101man_btn_excluir').prop('disabled', false);eval(data);});"
					cScript+= "});"
					oDlg:AddScript(cScript)
				EndIf

				If HTTPSESSION->lCOMPLEMENTA
					oBtn:= PSWebButton():New("ps101man_btn_complementar", "Complementar")
					oDlg:AddButton(oBtn)
					cScript:= "$('#ps101man_btn_complementar').click(function(){"
					cScript+= "$(this).prop('disabled', true);"
					cScript+= "  $.ajax({"
					cScript+= "          async: true,"
					cScript+= "          method: 'POST',"
					cScript+= "          url: 'u_ps120man.apw',"
					cScript+= "          data:'solicitacao='+table.row('.selected').data()[2]"
					cScript+= "         }).done(function(data){$('#ps101man_btn_complementar').prop('disabled', false);eval(data);});"
					cScript+= "});"
					oDlg:AddScript(cScript)
				EndIf

				If HTTPSESSION->lHISTORICO
					oBtn:= PSWebButton():New("ps101man_btn_historico", "Historico")
					cScript:= "$('#ps101man_btn_historico').click(function(){"
					cScript+= "$(this).prop('disabled', true);"
					cScript+= "      $.ajax({"
					cScript+= "          async: true,"
					cScript+= "          method: 'POST',"
					cScript+= "          url: 'u_ps150man.apw',"
					cScript+= "          data:'solicitacao='+table.row('.selected').data()[2]"
					cScript+= "         }).done(function(data){$('#ps101man_btn_historico').prop('disabled', false);eval(data);});"
					cScript+= "});"
					oDlg:AddScript(cScript)
					oDlg:AddButton(oBtn)
				EndIf

				If HTTPSESSION->lHISTORICO
					oBtn:= PSWebButton():New("ps101man_btn_excel", "Exp. Excel")
					cScript:= "$('#ps101man_btn_excel').click(function(){"
					cScript+= "$(this).prop('disabled', true);"
					cScript+= "  var filteredRows = table.rows({filter: 'applied'});"
					cScript+= "  var filtro = filteredRows[0]+'';"
					cScript+= "  filtro = filtro.split(',');"
					cScript+= "  var solicitacoes = '';"
					cScript+= "  for (var i = 0; i < filtro.length; i++ ) {"
					cScript+= "    solicitacoes+= table.row(filtro[i]).data()[2]+',';"
					cScript+= "  };"
					//cScript+= "    alert(solicitacoes);"
					cScript+= "    $.ajax({"
					cScript+= "        async: true,"
					cScript+= "        method: 'POST',"
					cScript+= "        url: 'u_ps160man.apw',"
					cScript+= "        data:'solicitacoes='+solicitacoes"
					cScript+= "       }).done(function(data){$('#ps101man_btn_excel').prop('disabled', false);eval(data);});"
					cScript+= "});"
					oDlg:AddScript(cScript)
					oDlg:AddButton(oBtn)
				EndIf

				If HTTPSESSION->lHISTORICO
					oBtn:= PSWebButton():New("ps101man_btn_relatorio", "Rel. Gerencial")
					cScript:= "$('#ps101man_btn_relatorio').click(function(){"
					cScript+= "$(this).prop('disabled', true);"
					cScript+= "  var filteredRows = table.rows({filter: 'applied'});"
					cScript+= "  var filtro = filteredRows[0]+'';"
					cScript+= "  filtro = filtro.split(',');"
					cScript+= "  var solicitacoes = '';"
					cScript+= "  for (var i = 0; i < filtro.length; i++ ) {"
					cScript+= "    solicitacoes+= table.row(filtro[i]).data()[2]+',';"
					cScript+= "  };"
					//cScript+= "    alert(solicitacoes);"
					cScript+= "    $.ajax({"
					cScript+= "        async: true,"
					cScript+= "        method: 'POST',"
					cScript+= "        url: 'u_ps180man.apw',"
					cScript+= "        data:'solicitacoes='+solicitacoes"
					cScript+= "       }).done(function(data){$('#ps101man_btn_relatorio').prop('disabled', false);eval(data);});"
					cScript+= "});"
					oDlg:AddScript(cScript)
					oDlg:AddButton(oBtn)
				EndIf

				If HTTPSESSION->lHISTORICO
					oBtn:= PSWebButton():New("ps101man_btn_posicao", "Posicao")
					cScript:= "$('#ps101man_btn_posicao').click(function(){"
					cScript+= "$(this).prop('disabled', true);"
					cScript+= "      $.ajax({"
					cScript+= "          async: true,"
					cScript+= "          method: 'POST',"
					cScript+= "          url: 'u_ps190man.apw',"
					cScript+= "          data:'solicitacao='+table.row('.selected').data()[2]"
					cScript+= "         }).done(function(data){$('#ps101man_btn_posicao').prop('disabled', false);eval(data);});"
					cScript+= "});"
					oDlg:AddScript(cScript)
					oDlg:AddButton(oBtn)
				EndIf

				oBtn:= PSWebButton():New("ps101man_btn_legenda", "Legenda")
				cScript:= "$('#ps101man_btn_legenda').click(function(){"
				cScript+= "$(this).prop('disabled', true);"
				cScript+= "      $.ajax({"
				cScript+= "             async: true,"
				cScript+= "             method: 'POST',"
				cScript+= "             url: 'u_ps170man.apw',"
				cScript+= "           }).done(function(data){$('#ps101man_btn_legenda').prop('disabled', false);eval(data);});"
				cScript+= "});"
				oDlg:AddScript(cScript)
				oDlg:AddButton(oBtn)

				oBtn:= PSWebButton():New("ps101man_btn_sair", "Sair")
				cScript:= "$('#ps101man_btn_sair').click(function(){"
				cScript+= "$(this).prop('disabled', true);"
				cScript+= "      $.ajax({"
				cScript+= "             async: true,"
				cScript+= "             method: 'POST',"
				cScript+= "             url: 'u_ps100man.apw',"
				cScript+= "           }).done(function(data){$('#ps101man_btn_sair').prop('disabled', false);eval(data);});"
				cScript+= "});"
				oDlg:AddScript(cScript)
				oDlg:AddButton(oBtn)

				cHtml+= oDlg:Show()
			Else
				oAlert:= PSWebAlert():New("ps101man_alert", "Usuario sem permissao para acessar o portal.", HTTPSESSION->cLogo)
				cHtml:= oAlert:show()
			EndIf
		Else
			oAlert:= PSWebAlert():New("ps101man_alert", "Usuario ou senha invalidos, verifique e tente novamente.", HTTPSESSION->cLogo)
			cHtml:= oAlert:show()
		EndIf
	Else
		oAlert:= PSWebAlert():New("ps101man_alert", "Usuario ou senha invalidos, verifique e tente novamente.", HTTPSESSION->cLogo)
		cHtml:= oAlert:show()
	EndIf

Return cHtml
