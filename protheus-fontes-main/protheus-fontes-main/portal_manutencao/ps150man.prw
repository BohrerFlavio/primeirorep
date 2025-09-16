#INCLUDE 'TBICONN.CH'

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³PS150MAN  ºAutor  ³Ezequiel Pianegonda º Data ³  14/08/2017 º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³Consulta historico e logs de cada solicitacao               º±±
±±º          ³                                                            º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ AP                                                        º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/

User Function PS150MAN()
	Local cHtml:= ""
	Local cSol:= HTTPPOST->SOLICITACAO
	Local cTab:= ""
	Local nX:= 0
	Local aTabela:= {}
	Local aLinha:= {}
	Local oAlert:= Nil
	Local oDlg:= Nil
	Local oTab1:= Nil
	Local oTab2:= Nil
	Local oTab3:= Nil
	Local oGet:= Nil

	If ValType(HTTPSESSION->cEMP) == "U" .OR. ValType(HTTPSESSION->cFil) == "U" .OR. ValType(HTTPSESSION->cCC) == "U"
		cHtml:= "  $.ajax({"
		cHtml+= "          async: true,"
		cHtml+= "          method: 'POST',"
		cHtml+= "          url: 'u_ps001man.apw',"
		cHtml+= "         }).done(function(data){eval(data);});"
		Return cHtml
	EndIf

	RESET ENVIRONMENT
	PREPARE ENVIRONMENT EMPRESA HTTPSESSION->cEmp FILIAL HTTPSESSION->cFil

	ZP2->(dbSetOrder(1))
	If ZP2->(DbSeek(xFilial("ZP2")+cSol))

		ZP3->(dbSetOrder(1))
		If ZP3->(dbSeek(xFilial("ZP3")+ZP2->ZP2_MAQ))

			oDlg:= PSWebDialog():New("ps150man_dialog_historico", HTTPSESSION->cLogo+"<br>Historico", "ps150man_form_historico",,,,,.T.)

			oTab1:= PSWebTab():New('oTab1', 'Cadastrais', .T.)
			oTab2:= PSWebTab():New('oTab2', 'Atendimento', .F.)
			oTab3:= PSWebTab():New('oTab3', 'Materiais', .F.)

			//tab1
			oGet:= PSWebGet():New("ps150man_get_solicitacao", "text", "Solicitacao*",,cSol)
			oDlg:AddScript("$('#ps150man_get_solicitacao').prop('readonly',true);")
			oTab1:AddControl(oGet)

			oGet:= PSWebGet():New("ps150man_get_data", "date", "Data*",,SubStr(DtoS(ZP2->ZP2_DATA), 1, 4)+"-"+SubStr(DtoS(ZP2->ZP2_DATA), 5, 2)+"-"+SubStr(DtoS(ZP2->ZP2_DATA), 7, 2))
			oDlg:AddScript("$('#ps150man_get_data').prop('readonly',true);")
			oTab1:AddControl(oGet)

			oGet:= PSWebGet():New("ps150man_get_sol", "text", "Solicitante*",,Alltrim(ZP2->ZP2_USER))
			oDlg:AddScript("$('#ps150man_get_sol').prop('readonly',true);")
			oTab1:AddControl(oGet)

			oGet:= PSWebGet():New("ps150man_get_desc", "text", "Descricao*",, Alltrim(ZP2->ZP2_DESC))
			oDlg:AddScript("$('#ps150man_get_desc').prop('readonly',true);")
			oTab1:AddControl(oGet)

			oMulti:= PSWebMultiget():New("ps150man_get_situacao", "Situacao*", 5, StrTran(Alltrim(ZP2->ZP2_HIST), Chr(13)+Chr(10), "\n"))
			oTab1:AddControl(oMulti)

			oGet:= PSWebGet():New("ps150man_get_maquina", "text", "Cod.Maquina*",, ZP2->ZP2_MAQ)
			oDlg:AddScript("$('#ps150man_get_maquina').prop('readonly',true);")
			oTab1:AddControl(oGet)

			oGet:= PSWebGet():New("ps150man_get_dmaquina", "text", "Desc.Maquina*",, ZP3->ZP3_NOME)
			oDlg:AddScript("$('#ps150man_get_dmaquina').prop('readonly',true);")
			oTab1:AddControl(oGet)

			dGar:= ZP3->(ZP3_GAR)
			oGet:= PSWebGet():New("ps150man_get_gmaquina", "date", "Garantia.Maquina*",, IIF(!Empty(dGar), SubStr(DtoS(dGar), 1, 4)+"-"+SubStr(DtoS(dGar), 5, 2)+"-"+SubStr(DtoS(dGar), 7, 2), ""))
			oDlg:AddScript("$('#ps150man_get_gmaquina').prop('readonly',true);")
			oTab1:AddControl(oGet)

			oGet:= PSWebGet():New("ps150man_get_cc", "text", "Centro de custo*",, ZP2->ZP2_CC)
			oDlg:AddScript("$('#ps150man_get_cc').prop('readonly',true);")
			oTab1:AddControl(oGet)

			oGet:= PSWebGet():New("ps150man_get_dcc", "text", "Desc.Centro de custo*",, Alltrim(CTT->(fBuscaCpo("CTT", 1, xFilial("CTT")+ZP2->ZP2_CC, "CTT_DESC01"))))
			oDlg:AddScript("$('#ps150man_get_dcc').prop('readonly',true);")
			oTab1:AddControl(oGet)

			oCombo:= PSWebCombo():New("ps150man_combo_maquina_parada", "Maquina parada*", "S=SIM;N=NAO", ZP2->ZP2_MAQPAR)
			oDlg:AddScript("$('#ps150man_combo_maquina_parada').attr('disabled',true);")
			oTab1:AddControl(oCombo)

			//tab2
			oCombo:= PSWebCombo():New("ps150man_combo_tipo", "Tipo Solicitacao*", "M=MECANICA;E=ELETRICA;I=INFORMATICA;L=LIMPEZA;P=MANUTENCAO EXTERNA - PATIO;3=OBRAS ROBSON;1=SERVICO - ISO PAINEL;2=SERVICO - ISOLAMENTO;4=SERVICO - PINTURA;5=SERVICO - PISO;6=SERVICO - TERCEIROS", ZP2->ZP2_TIPO)
			oDlg:AddScript("$('#ps150man_combo_tipo').attr('disabled',true);")
			oTab2:AddControl(oCombo)

			oCombo:= PSWebCombo():New("ps150man_combo_prioridade", "Prioridade*", "B=BAIXA;M=MEDIA;A=ALTA", ZP2->ZP2_PRIOR)
			oDlg:AddScript("$('#ps150man_combo_prioridade').attr('disabled',true);")
			oTab2:AddControl(oCombo)

			oGet:= PSWebGet():New("ps150man_get_prazo", "date", "Prazo*",, SubStr(DtoS(ZP2->ZP2_PRAZO), 1, 4)+"-"+SubStr(DtoS(ZP2->ZP2_PRAZO), 5, 2)+"-"+SubStr(DtoS(ZP2->ZP2_PRAZO), 7, 2))
			oDlg:AddScript("$('#ps150man_get_prazo').prop('readonly',true);")
			oTab2:AddControl(oGet)

			oCombo:= PSWebCombo():New("ps150man_combo_nprioridade", "Nova Prioridade*", " =&nbsp;N=NORMAL;B=BAIXA;M=MEDIA;A=ALTA", ZP2->ZP2_NPRIOR)
			oDlg:AddScript("$('#ps150man_combo_nprioridade').attr('disabled',true);")
			oTab2:AddControl(oCombo)

			oGet:= PSWebGet():New("ps150man_get_nprazo", "date", "Novo Prazo*",, SubStr(DtoS(ZP2->ZP2_NPRAZO), 1, 4)+"-"+SubStr(DtoS(ZP2->ZP2_NPRAZO), 5, 2)+"-"+SubStr(DtoS(ZP2->ZP2_NPRAZO), 7, 2))
			oDlg:AddScript("$('#ps150man_get_nprazo').prop('readonly',true);")
			oTab2:AddControl(oGet)

			oCombo:= PSWebCombo():New("ps150man_combo_mauuso", "Mau Uso*", "N=NAO;S=SIM", ZP2->ZP2_MAUUSO)
			oDlg:AddScript("$('#ps150man_combo_mauuso').prop('disabled',true);")
			oTab2:AddControl(oCombo)

			oCombo:= PSWebCombo():New("ps150man_combo_nmauuso", "Novo Mau Uso*", " =&nbsp;N=NAO;S=SIM", ZP2->ZP2_NMAUUS)
			oDlg:AddScript("$('#ps150man_combo_nmauuso').prop('disabled',true);")
			oTab2:AddControl(oCombo)

			oCombo:= PSWebCombo():New("ps150man_combo_preventiva", "Preventiva*", " =&nbsp;N=NAO;S=SIM", ZP2->ZP2_PREVEN)
			oDlg:AddScript("$('#ps150man_combo_preventiva').prop('disabled',true);")
			oTab2:AddControl(oCombo)

			oCombo:= PSWebCombo():New("ps150man_combo_corretiva", "Corretiva*", " =&nbsp;N=NAO;S=SIM", ZP2->ZP2_CORRET)
			oDlg:AddScript("$('#ps150man_combo_corretiva').prop('disabled',true);")
			oTab2:AddControl(oCombo)

			oCombo:= PSWebCombo():New("ps150man_combo_melhoria", "Melhoria*", " =&nbsp;N=NAO;S=SIM", ZP2->ZP2_MELHOR)
			oDlg:AddScript("$('#ps150man_combo_melhoria').prop('disabled',true);")
			oTab2:AddControl(oCombo)

			oCombo:= PSWebCombo():New("ps150man_combo_qualidade", "Retrabalho da Manutencao*", " =&nbsp;N=NAO;S=SIM", ZP2->ZP2_QUALID)//era Qualidade
			oDlg:AddScript("$('#ps150man_combo_qualidade').prop('disabled',true);")
			oTab2:AddControl(oCombo)

			oGet:= PSWebGet():New("ps150man_get_dataini", "date", "Dt.Inicio Serv.",, SubStr(DtoS(ZP2->ZP2_DTINI), 1, 4)+"-"+SubStr(DtoS(ZP2->ZP2_DTINI), 5, 2)+"-"+SubStr(DtoS(ZP2->ZP2_DTINI), 7, 2))
			oDlg:AddScript("$('#ps150man_get_dataini').prop('readonly',true);")
			oTab2:AddControl(oGet)

			oGet:= PSWebGet():New("ps150man_get_horaini", "time", "Hr.Inicio Serv.",, ZP2->ZP2_HRINI)
			oDlg:AddScript("$('#ps150man_get_horaini').prop('readonly',true);")
			oTab2:AddControl(oGet)

			oGet:= PSWebGet():New("ps150man_get_datafin", "date", "Dt.Fin.Serv.",, SubStr(DtoS(ZP2->ZP2_DTFIN), 1, 4)+"-"+SubStr(DtoS(ZP2->ZP2_DTFIN), 5, 2)+"-"+SubStr(DtoS(ZP2->ZP2_DTFIN), 7, 2))
			oDlg:AddScript("$('#ps150man_get_datafin').prop('readonly',true);")
			oTab2:AddControl(oGet)

			oGet:= PSWebGet():New("ps150man_get_horafin", "time", "Hr.Fin.Serv.",, ZP2->ZP2_HRFIN)
			oDlg:AddScript("$('#ps150man_get_horafin').prop('readonly',true);")
			oTab2:AddControl(oGet)

			oGet:= PSWebGet():New("ps150man_get_manutentor", "text", "Manutentor",, ZP2->ZP2_MANUTE)
			oDlg:AddScript("$('#ps150man_get_manutentor').prop('readonly',true);")
			oTab2:AddControl(oGet)

			//tab3
			oGetDados:= PSWebGetDados():New("ps150man_getdados_grid", HTTPSESSION->cEmp, HTTPSESSION->cFil, "ZP4", "ZP4_CODIGO = #"+cSol+"#")
			oGet:= PSWebGet():New("ZP4_STATUS", "text", "Status")
			oGetDados:AddControl(oGet)
			oGet:= PSWebGet():New("ZP4_PRODUT", "text", "Produto")
			oGetDados:AddControl(oGet)
			oGet:= PSWebGet():New("ZP4_DESC", "text", "Descricao")
			oGetDados:AddControl(oGet)
			oGet:= PSWebGet():New("ZP4_QUANT", "text", "Quantidade")
			oGetDados:AddControl(oGet)
			oGet:= PSWebGet():New("ZP4_UM", "text", "UM")
			oGetDados:AddControl(oGet)
			oGet:= PSWebGet():New("ZP4_SOLC", "text", "SC")
			oGetDados:AddControl(oGet)
			oGet:= PSWebGet():New("ZP4_ITEMSC", "text", "ItSC")
			oGetDados:AddControl(oGet)
			oGet:= PSWebGet():New("ZP4_DTSC", "text", "DtSC")
			oGetDados:AddControl(oGet)
			oGet:= PSWebGet():New("ZP4_SOLA", "text", "SA")
			oGetDados:AddControl(oGet)
			oGet:= PSWebGet():New("ZP4_ITEMSA", "text", "ItSA")
			oGetDados:AddControl(oGet)
			oGet:= PSWebGet():New("ZP4_DTSA", "text", "DtSA")
			oGetDados:AddControl(oGet)
			oGet:= PSWebGet():New("ZP4_PC", "text", "PC")
			oGetDados:AddControl(oGet)
			oGet:= PSWebGet():New("ZP4_ITEMPC", "text", "ItPC")
			oGetDados:AddControl(oGet)
			oGet:= PSWebGet():New("ZP4_DTPC", "text", "DtPC")
			oGetDados:AddControl(oGet)
			oGet:= PSWebGet():New("ZP4_DTLPC", "text", "DtLibPC")
			oGetDados:AddControl(oGet)
			oGet:= PSWebGet():New("ZP4_DTEPC", "text", "DtEntPC")
			oGetDados:AddControl(oGet)
			oTab3:AddControl(oGetDados)


			oDlg:AddTab(oTab1)
			oDlg:AddTab(oTab2)
			oDlg:AddTab(oTab3)

			oBtn:= PSWebButton():New("ps150man_btn_logs", "Logs")
			oDlg:AddButton(oBtn)
			cScript:= "$('#ps150man_btn_logs').click(function(){"
			cScript+= "$(this).prop('disabled', true);"
			cScript+= "  $.ajax({"
			cScript+= "          async: true,"
			cScript+= "          method: 'POST',"
			cScript+= "          url: 'u_ps151man.apw',"
			cScript+= "          data: {'SOLICITACAO':'"+cSol+"'}"
			cScript+= "         }).done(function(data){$('#ps150man_btn_logs').prop('disabled', false);eval(data);});"
			cScript+= "});"
			oDlg:AddScript(cScript)

			oBtn:= PSWebButton():New("ps150man_btn_cancelar", "Cancelar")
			oDlg:AddButton(oBtn)
			cScript:= "$('#ps150man_btn_cancelar').click(function(){"
			cScript+= "$(this).prop('disabled', true);"
			cScript+= "  $.ajax({"
			cScript+= "          async: true,"
			cScript+= "          method: 'POST',"
			cScript+= "          url: 'u_ps101man.apw',"
			cScript+= "          data: {'PS100MAN_GET_USER':'"+HTTPSESSION->cUSER+"','PS100MAN_GET_PASS':'"+HTTPSESSION->cPASS+"'}"
			cScript+= "         }).done(function(data){$('#ps150man_btn_cancelar').prop('disabled', false);eval(data);});"
			cScript+= "});"
			oDlg:AddScript(cScript)

			cHtml+= oDlg:Show()
		Else
			oAlert:= PSWebAlert():New("ps150man_alert", "Maquina "+ZP2->ZP2_MAQ+", nao encontrada.", HTTPSESSION->cLogo)
			cHtml:= oAlert:show()
		EndIf

	Else
		oAlert:= PSWebAlert():New("ps150man_alert", "Solicitacao '"+cSol+"' nao encontrada", HTTPSESSION->cLogo)
		cHtml:= oAlert:show()
	EndIf
Return cHtml
