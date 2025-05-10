#INCLUDE 'TBICONN.CH'

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³PS120MAN  ºAutor  ³Ezequiel Pianegonda º Data ³  28/06/2017 º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³Complementar Solicitacao                                    º±±
±±º          ³                                                            º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ AP                                                        º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/

User Function PS120MAN()
	Local cHtml:= ""
	Local cSol:= HTTPPOST->SOLICITACAO
	Local oDlg:= Nil
	Local oTab1:= Nil
	Local oTab2:= Nil
	Local oTab3:= Nil
	Local oGet:= Nil
	Local oAlert:= Nil
	Local dGar:= Date()
	Local cScript:= ""

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

	ZP2->(dbSetOrder(1))
	If ZP2->(dbSeek(xFilial("ZP2")+cSol))

		If !Empty(ZP2->ZP2_DTRFIM)
			oAlert:= PSWebAlert():New("ps120man_alert", "Solicitacao ja finalizada pela manutencao e solicitante.", HTTPSESSION->cLogo)
			cHtml:= oAlert:show()
			Return cHtml
		EndIf

		If !Empty(ZP2->ZP2_DTINI) .AND.!Empty(ZP2->ZP2_DTFIN)
			oAlert:= PSWebAlert():New("ps121man_alert", "Solicitacao ja finalizada pela manutencao, aguardando finalizacao do solicitante.", HTTPSESSION->cLogo)
			cHtml:= oAlert:show()
			Return cHtml
		EndIf

		ZP3->(dbSetOrder(1))
		If ZP3->(dbSeek(xFilial("ZP3")+ZP2->ZP2_MAQ))

			oDlg:= PSWebDialog():New("ps120man_dialog_alterar", HTTPSESSION->cLogo+"<br>Complementar Solicitacao", "ps120man_form_alterar",,,,,.T.)

			oTab1:= PSWebTab():New('oTab1', 'Cadastrais', .T.)
			oTab2:= PSWebTab():New('oTab2', 'Atendimento', .F.)
			If Date() > ZP3->(ZP3_GAR) .AND. HTTPSESSION->lSolicita
				oTab3:= PSWebTab():New('oTab3', 'Materiais', .F.)
			EndIf

			//tab1
			oGet:= PSWebGet():New("ps120man_get_solicitacao", "text", "Solicitacao*",,cSol)
			oDlg:AddScript("$('#ps120man_get_solicitacao').prop('readonly',true);")
			oTab1:AddControl(oGet)

			oGet:= PSWebGet():New("ps120man_get_data", "date", "Data*",,SubStr(DtoS(ZP2->ZP2_DATA), 1, 4)+"-"+SubStr(DtoS(ZP2->ZP2_DATA), 5, 2)+"-"+SubStr(DtoS(ZP2->ZP2_DATA), 7, 2))
			oDlg:AddScript("$('#ps120man_get_data').prop('readonly',true);")
			oTab1:AddControl(oGet)

			oGet:= PSWebGet():New("ps120man_get_sol", "text", "Solicitante*",,Alltrim(ZP2->ZP2_USER))
			oDlg:AddScript("$('#ps120man_get_sol').prop('readonly',true);")
			oTab1:AddControl(oGet)

			oGet:= PSWebGet():New("ps120man_get_desc", "text", "Descricao*",, Alltrim(ZP2->ZP2_DESC))
			oDlg:AddScript("$('#ps120man_get_desc').prop('readonly',true);")
			oTab1:AddControl(oGet)

			oMulti:= PSWebMultiget():New("ps120man_get_situacao_anterior", "Situacao.Anterior", 5, StrTran(Alltrim(ZP2->ZP2_HIST), Chr(13)+Chr(10), "\n"))
			oDlg:AddScript("$('#ps120man_get_situacao_anterior').prop('readonly',true);")
			oTab1:AddControl(oMulti)

			oMulti:= PSWebMultiget():New("ps120man_get_situacao", "Situacao", 5)
			oTab1:AddControl(oMulti)

			oGet:= PSWebGet():New("ps120man_get_maquina", "text", "Cod.Maquina*",, ZP2->ZP2_MAQ)
			oDlg:AddScript("$('#ps120man_get_maquina').prop('readonly',true);")
			oTab1:AddControl(oGet)

			oGet:= PSWebGet():New("ps120man_get_dmaquina", "text", "Desc.Maquina*",, ZP3->ZP3_NOME)
			oDlg:AddScript("$('#ps120man_get_dmaquina').prop('readonly',true);")
			oTab1:AddControl(oGet)

			dGar:= ZP3->(ZP3_GAR)
			oGet:= PSWebGet():New("ps120man_get_gmaquina", "date", "Garantia.Maquina*",, IIF(!Empty(dGar), SubStr(DtoS(dGar), 1, 4)+"-"+SubStr(DtoS(dGar), 5, 2)+"-"+SubStr(DtoS(dGar), 7, 2), ""))
			oDlg:AddScript("$('#ps120man_get_gmaquina').prop('readonly',true);")
			oTab1:AddControl(oGet)

			oGet:= PSWebGet():New("ps120man_get_cc", "text", "Centro de custo*",, ZP2->ZP2_CC)
			oDlg:AddScript("$('#ps120man_get_cc').prop('readonly',true);")
			oTab1:AddControl(oGet)

			oGet:= PSWebGet():New("ps120man_get_dcc", "text", "Desc.Centro de custo*",, Alltrim(CTT->(fBuscaCpo("CTT", 1, xFilial("CTT")+ZP2->ZP2_CC, "CTT_DESC01"))))
			oDlg:AddScript("$('#ps120man_get_dcc').prop('readonly',true);")
			oTab1:AddControl(oGet)

			oCombo:= PSWebCombo():New("ps120man_combo_maquina_parada", "Maquina parada*", "S=SIM;N=NAO", ZP2->ZP2_MAQPAR)
			oDlg:AddScript("$('#ps120man_combo_maquina_parada').attr('disabled',true);")
			oTab1:AddControl(oCombo)

			//tab2
			oCombo:= PSWebCombo():New("ps120man_combo_tipo", "Tipo Solicitacao*", "M=MECANICA;E=ELETRICA;I=INFORMATICA;L=LIMPEZA;P=MANUTENCAO EXTERNA - PATIO;3=OBRAS ROBSON;1=SERVICO - ISO PAINEL;2=SERVICO - ISOLAMENTO;4=SERVICO - PINTURA;5=SERVICO - PISO;6=SERVICO - TERCEIROS", ZP2->ZP2_TIPO)
			oTab2:AddControl(oCombo)

			oCombo:= PSWebCombo():New("ps120man_combo_prioridade", "Prioridade*", "B=BAIXA;M=MEDIA;A=ALTA", ZP2->ZP2_PRIOR)
			oDlg:AddScript("$('#ps120man_combo_prioridade').attr('disabled',true);")
			oTab2:AddControl(oCombo)

			oGet:= PSWebGet():New("ps120man_get_prazo", "date", "Prazo*",, SubStr(DtoS(ZP2->ZP2_PRAZO), 1, 4)+"-"+SubStr(DtoS(ZP2->ZP2_PRAZO), 5, 2)+"-"+SubStr(DtoS(ZP2->ZP2_PRAZO), 7, 2))
			oDlg:AddScript("$('#ps120man_get_prazo').prop('readonly',true);")
			oTab2:AddControl(oGet)

			oCombo:= PSWebCombo():New("ps120man_combo_nprioridade", "Nova Prioridade", " =&nbsp;B=BAIXA;M=MEDIA;A=ALTA", " ")
			oTab2:AddControl(oCombo)

			oGet:= PSWebGet():New("ps120man_get_nprazo", "date", "Novo Prazo",, /*SubStr(DtoS(ZP2->ZP2_NPRAZO), 1, 4)+"-"+SubStr(DtoS(ZP2->ZP2_NPRAZO), 5, 2)+"-"+SubStr(DtoS(ZP2->ZP2_NPRAZO), 7, 2)*/)
			oTab2:AddControl(oGet)

			oCombo:= PSWebCombo():New("ps120man_combo_mauuso", "Mau Uso*", "N=NAO;S=SIM", ZP2->ZP2_MAUUSO)
			oDlg:AddScript("$('#ps120man_combo_mauuso').prop('disabled',true);")
			oTab2:AddControl(oCombo)

			oCombo:= PSWebCombo():New("ps120man_combo_nmauuso", "Novo Mau Uso*", " =&nbsp;N=NAO;S=SIM", ZP2->ZP2_NMAUUS)
			oTab2:AddControl(oCombo)

			oCombo:= PSWebCombo():New("ps120man_combo_preventiva", "Preventiva*", " =&nbsp;N=NAO;S=SIM", ZP2->ZP2_PREVEN)
			oTab2:AddControl(oCombo)

			oCombo:= PSWebCombo():New("ps120man_combo_corretiva", "Corretiva*", " =&nbsp;N=NAO;S=SIM", ZP2->ZP2_CORRET)
			oTab2:AddControl(oCombo)

			oCombo:= PSWebCombo():New("ps120man_combo_melhoria", "Melhoria*", " =&nbsp;N=NAO;S=SIM", ZP2->ZP2_MELHOR)
			oTab2:AddControl(oCombo)

			oCombo:= PSWebCombo():New("ps120man_combo_qualidade", "Retrabalho da Manutencao*", " =&nbsp;N=NAO;S=SIM", ZP2->ZP2_QUALID)//era Qualidade 
			oTab2:AddControl(oCombo)

			oGet:= PSWebGet():New("ps120man_get_dataini", "date", "Dt.Inicio Serv.",, SubStr(DtoS(ZP2->ZP2_DTINI), 1, 4)+"-"+SubStr(DtoS(ZP2->ZP2_DTINI), 5, 2)+"-"+SubStr(DtoS(ZP2->ZP2_DTINI), 7, 2))
			If !Empty(ZP2->ZP2_DTINI)
				oDlg:AddScript("$('#ps120man_get_dataini').prop('readonly',true);")
			EndIf
			oTab2:AddControl(oGet)

			oGet:= PSWebGet():New("ps120man_get_horaini", "time", "Hr.Inicio Serv.",, ZP2->ZP2_HRINI)
			If !Empty(ZP2->ZP2_HRINI)
				oDlg:AddScript("$('#ps120man_get_horaini').prop('readonly',true);")
			EndIf
			oTab2:AddControl(oGet)

			oGet:= PSWebGet():New("ps120man_get_datafin", "date", "Dt.Fin.Serv.",, SubStr(DtoS(ZP2->ZP2_DTFIN), 1, 4)+"-"+SubStr(DtoS(ZP2->ZP2_DTFIN), 5, 2)+"-"+SubStr(DtoS(ZP2->ZP2_DTFIN), 7, 2))
			If Empty(ZP2->ZP2_DTINI)
				oDlg:AddScript("$('#ps120man_get_datafin').prop('readonly',true);")
			EndIf
			oTab2:AddControl(oGet)

			oGet:= PSWebGet():New("ps120man_get_horafin", "time", "Hr.Fin.Serv.",, ZP2->ZP2_HRFIN)
			If Empty(ZP2->ZP2_DTINI)
				oDlg:AddScript("$('#ps120man_get_horafin').prop('readonly',true);")
			EndIf
			oTab2:AddControl(oGet)

			oGet:= PSWebGet():New("ps120man_get_manutentor", "text", "Manutentor*",, ZP2->ZP2_MANUTE)
			//If Empty(ZP2->ZP2_DTINI)
			//	oDlg:AddScript("$('#ps120man_get_manutentor').prop('readonly',true);")
			//EndIf
			oTab2:AddControl(oGet)

			//tab3
			If Date() > ZP3->(ZP3_GAR) .AND. HTTPSESSION->lSolicita
				oGetDados:= PSWebGetDados():New("ps120man_getdados_grid", HTTPSESSION->cEmp, HTTPSESSION->cFil, "ZP4", "ZP4_CODIGO = #"+cSol+"#")
				oGet:= PSWebGet():New("ZP4_STATUS", "text", "Status",, "1 - Pendente")
				oGetDados:AddControl(oGet)
				oGet:= PSWebGet():New("ZP4_PRODUT", "text", "Produto", .T.)
				oGetDados:AddControl(oGet)
				oGet:= PSWebGet():New("ZP4_DESC", "text", "Descricao")
				oGetDados:AddControl(oGet)
				oGet:= PSWebGet():New("ZP4_QUANT", "text", "Quantidade",,"0,00")
				oGetDados:AddControl(oGet)
				oGet:= PSWebGet():New("ZP4_UM", "text", "UM")
				oGetDados:AddControl(oGet)
				oGet:= PSWebGet():New("ZP4_SOLC", "text", "SC")
				oGetDados:AddControl(oGet)
				oGet:= PSWebGet():New("ZP4_ITEMSC", "text", "ItSC")
				oGetDados:AddControl(oGet)
				oGet:= PSWebGet():New("ZP4_SOLA", "text", "SA")
				oGetDados:AddControl(oGet)
				oGet:= PSWebGet():New("ZP4_ITEMSA", "text", "ItSA")
				oGetDados:AddControl(oGet)
				oTab3:AddControl(oGetDados)

				cScript:= "$('#ZP4_QUANT').blur(function(){"
				cScript+= "  var valor = $(this).val();"
				cScript+= "  valor = parseFloat(valor.replace('.', '').replace('.', '').replace(',', '.'));"
				cScript+= "  if (valor <= 0){"
				cScript+= "    $(this).focus();"
				cScript+= "  }else{"
				cScript+= "  if ($(this).val() == ''){"
				cScript+= "    $(this).focus();"
				cScript+= "  }}"
				cScript+= "});"
				oGetDados:AddScript(cScript)

				cScript:= "$('#ZP4_PRODUT_F3').click(function(){"
				cScript+= "  $.ajax({"
				cScript+= "          async: false,"
				cScript+= "          method: 'POST',"
				cScript+= "          url: 'u_pswebf3.apw',"
				cScript+= "          data: {'titulo':'Consulta padrao', 'id':'id_dialog', 'emp':'"+HTTPSESSION->cEmp+"', 'fil':'"+HTTPSESSION->cFil+"', 'cols':'B1_COD:Codigo;B1_DESC:Descricao;B1_UM:UM', 'from_':'SB1', 'where':'(B1_GRUPO BETWEEN #1100# AND #1600# OR B1_GRUPO = #9999#) AND B1_MSBLQL <> #1#','ret':'ZP4_PRODUT:0;ZP4_DESC:1;ZP4_UM:2'},"
				cScript+= "         }).done(function(data){eval(data);});"
				cScript+= "});"
				cScript+= "$('#ZP4_STATUS').attr('disabled',true);"
				cScript+= "$('#ZP4_DESC').attr('disabled',true);"
				cScript+= "$('#ZP4_UM').attr('disabled',true);"
				cScript+= "$('#ZP4_SOLC').attr('disabled',true);"
				cScript+= "$('#ZP4_ITEMSC').attr('disabled',true);"
				cScript+= "$('#ZP4_SOLA').attr('disabled',true);"
				cScript+= "$('#ZP4_ITEMSA').attr('disabled',true);"
				cScript+= "$('#ZP4_QUANT').mask('#.##0,00', {reverse: true});"
				oGetDados:AddScript(cScript)

				oBtn:= PSWebButton():New("ps120man_btn_estoque", "Consulta estoque")
				oGetDados:AddButton(oBtn)

				cScript:= "$('#ps120man_btn_estoque').click(function(){"
				cScript+= "$(this).prop('disabled', true);"
				cScript+= "var getDados = $('#ps120man_getdados_grid');"
				cScript+= "var tabela = '';"
				cScript+= "getDados.find('tr').each(function(linha){"
				cScript+= "		$(this).find('td').each(function(coluna){"
				cScript+= "			tabela+= linha+':'+coluna+':'+$(this).text()+';';"
				cScript+= "		});"
				cScript+= "    tabela+= '|';"
				cScript+= "});"
				cScript+= "  $.ajax({"
				cScript+= "          async: true,"
				cScript+= "          method: 'POST',"
				cScript+= "          url: 'u_ps123man.apw',"
				cScript+= "          data: $('#ps120man_form_alterar').serialize()+'&tabela='+tabela"
				cScript+= "         }).done(function(data){$('#ps120man_btn_estoque').prop('disabled', false);eval(data);});"
				cScript+= "});"
				oDlg:AddScript(cScript)

				oBtn:= PSWebButton():New("ps120man_btn_reserva", "Reservar/Solicitar")
				oGetDados:AddButton(oBtn)

				cScript:= "$('#ps120man_btn_reserva').click(function(){"
				cScript+= "$(this).prop('disabled', true);"
				cScript+= "var getDados = $('#ps120man_getdados_grid');"
				cScript+= "var tabela = '';"
				cScript+= "getDados.find('tr').each(function(linha){"
				cScript+= "		$(this).find('td').each(function(coluna){"
				cScript+= "			tabela+= linha+':'+coluna+':'+$(this).text()+';';"
				cScript+= "		});"
				cScript+= "    tabela+= '|';"
				cScript+= "});"
				cScript+= "  $.ajax({"
				cScript+= "          async: true,"
				cScript+= "          method: 'POST',"
				cScript+= "          url: 'u_ps122man.apw',"
				cScript+= "          data: $('#ps120man_form_alterar').serialize()+'&tabela='+tabela"
				cScript+= "         }).done(function(data){$('#ps120man_btn_reserva').prop('disabled', false);eval(data);});"
				cScript+= "});"
				oDlg:AddScript(cScript)
			EndIf

			oDlg:AddTab(oTab1)
			oDlg:AddTab(oTab2)
			If Date() > ZP3->(ZP3_GAR) .AND. HTTPSESSION->lSolicita
				oDlg:AddTab(oTab3)
			EndIf

			oBtn:= PSWebButton():New("ps120man_btn_alterar", "Complementar")
			oDlg:AddButton(oBtn)
			cScript:= "$('#ps120man_btn_alterar').click(function(){"
			cScript+= "$(this).prop('disabled', true);"
			cScript+= "var getDados = $('#ps120man_getdados_grid');"
			cScript+= "var tabela = '';"
			cScript+= "getDados.find('tr').each(function(linha){"
			cScript+= "		$(this).find('td').each(function(coluna){"
			cScript+= "			tabela+= linha+':'+coluna+':'+$(this).text()+';';"
			cScript+= "		});"
			cScript+= "    tabela+= '|';"
			cScript+= "});"
			cScript+= "    $.ajax({"
			cScript+= "          async: true,"
			cScript+= "          method: 'POST',"
			cScript+= "          url: 'u_ps121man.apw',"
			cScript+= "          data: $('#ps120man_form_alterar').serialize()+'&tabela='+tabela"
			cScript+= "         }).done(function(data){$('#ps120man_btn_alterar').prop('disabled', false);eval(data);});"
			cScript+= "});"
			oDlg:AddScript(cScript)

			oBtn:= PSWebButton():New("ps120man_btn_cancelar", "Cancelar")
			oDlg:AddButton(oBtn)
			cScript:= "$('#ps120man_btn_cancelar').click(function(){"
			cScript+= "$(this).prop('disabled', true);"
			cScript+= "  $.ajax({"
			cScript+= "          async: true,"
			cScript+= "          method: 'POST',"
			cScript+= "          url: 'u_ps101man.apw',"
			cScript+= "          data: {'PS100MAN_GET_USER':'"+HTTPSESSION->cUSER+"','PS100MAN_GET_PASS':'"+HTTPSESSION->cPASS+"'}"
			cScript+= "         }).done(function(data){eval(data);});"
			cScript+= "});"
			oDlg:AddScript(cScript)

			cHtml+= oDlg:Show()
		Else
			oAlert:= PSWebAlert():New("ps120man_alert", "Maquina "+ZP2->ZP2_MAQ+", nao encontrada.", HTTPSESSION->cLogo)
			cHtml:= oAlert:show()
		EndIf
	Else
		oAlert:= PSWebAlert():New("ps120man_alert", "Solicitacao "+cSol+", nao encontrada.", HTTPSESSION->cLogo)
		cHtml:= oAlert:show()
	EndIf

Return cHtml
