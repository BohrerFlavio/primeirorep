#INCLUDE 'TBICONN.CH'
/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³PS140MAN  ºAutor  ³Ezequiel Pianegonda º Data ³  07/08/2017 º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³Exclusao  de solicitacao                                    º±±
±±º          ³                                                            º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ AP                                                        º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/

User Function PS140MAN()
	Local cHtml:= ""
	Local cSol:= HTTPPOST->SOLICITACAO
	Local oDlg:= Nil
	Local oTab1:= Nil
	Local oTab2:= Nil
	Local oGet:= Nil
	Local oAlert:= Nil
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
			oAlert:= PSWebAlert():New("ps140man_alert", "Solicitacao ja finalizada.", HTTPSESSION->cLogo)
			cHtml:= oAlert:show()
			Return cHtml
		EndIf

		If Left(ZP2->ZP2_STATUS, 1) != "1"
			oAlert:= PSWebAlert():New("ps140man_alert", "Solicitacao ja iniciada portanto nao pode ser excluida.", HTTPSESSION->cLogo)
			cHtml:= oAlert:show()
			Return cHtml
		EndIf

		ZP3->(dbSetOrder(1))
		If ZP3->(dbSeek(xFilial("ZP3")+ZP2->ZP2_MAQ))

			oDlg:= PSWebDialog():New("ps140man_dialog_excluir", HTTPSESSION->cLogo+"<br>Excluir Solicitacao", "ps140man_form_excluir",,,,,.T.)

			oTab1:= PSWebTab():New('oTab1', 'Cadastrais', .T.)
			oTab2:= PSWebTab():New('oTab2', 'Atendimento', .F.)

			oGet:= PSWebGet():New("ps140man_get_solicitacao", "hidden", "",,ZP2->ZP2_CODIGO)
			oTab1:AddControl(oGet)

			oGet:= PSWebGet():New("ps140man_get_data", "date", "Data*",,SubStr(DtoS(ZP2->ZP2_DATA), 1, 4)+"-"+SubStr(DtoS(ZP2->ZP2_DATA), 5, 2)+"-"+SubStr(DtoS(ZP2->ZP2_DATA), 7, 2))
			oDlg:AddScript("$('#ps140man_get_data').prop('readonly',true);")
			oTab1:AddControl(oGet)

			oGet:= PSWebGet():New("ps140man_get_sol", "text", "Solicitante*",,ZP2->ZP2_USER)
			oDlg:AddScript("$('#ps140man_get_sol').prop('readonly',true);")
			oTab1:AddControl(oGet)

			oGet:= PSWebGet():New("ps140man_get_desc", "text", "Descricao*",,ZP2->ZP2_DESC)
			oDlg:AddScript("$('#ps140man_get_desc').prop('readonly',true);")
			oTab1:AddControl(oGet)

			oMulti:= PSWebMultiget():New("ps140man_get_situacao", "Situacao*", 5, StrTran(Alltrim(ZP2->ZP2_HIST), Chr(13)+Chr(10), "\n"))
			oDlg:AddScript("$('#ps140man_get_situacao').prop('readonly',true);")
			oTab1:AddControl(oMulti)

			oGet:= PSWebGet():New("ps140man_get_maquina", "text", "Cod.Maquina*", .T.,ZP2->ZP2_MAQ)
			oDlg:AddScript("$('#ps140man_get_maquina').prop('readonly',true);")
			oTab1:AddControl(oGet)

			oGet:= PSWebGet():New("ps140man_get_dmaquina", "text", "Desc.Maquina*",,ZP3->ZP3_NOME)
			oDlg:AddScript("$('#ps140man_get_dmaquina').prop('readonly',true);")
			oTab1:AddControl(oGet)

			oGet:= PSWebGet():New("ps140man_get_gmaquina", "date", "Garantia Maquina*",,IIF(!Empty(ZP3->ZP3_GAR), SubStr(DtoS(ZP3->ZP3_GAR), 1, 4)+"-"+SubStr(DtoS(ZP3->ZP3_GAR), 5, 2)+"-"+SubStr(DtoS(ZP3->ZP3_GAR), 7, 2), ""))
			oDlg:AddScript("$('#ps140man_get_gmaquina').prop('readonly',true);")
			oTab1:AddControl(oGet)

			oGet:= PSWebGet():New("ps140man_get_cc", "text", "Centro de custo*",,ZP2->ZP2_CC)
			oDlg:AddScript("$('#ps140man_get_cc').prop('readonly',true);")
			oTab1:AddControl(oGet)

			dbSelectArea("CTT")
			oGet:= PSWebGet():New("ps140man_get_dcc", "text", "Desc.Centro de custo*",,Alltrim(fBuscaCpo("CTT", 1, xFilial("CTT")+ZP2->ZP2_CC, "CTT_DESC01")))
			oDlg:AddScript("$('#ps140man_get_dcc').prop('readonly',true);")
			oTab1:AddControl(oGet)

			oCombo:= PSWebCombo():New("ps140man_combo_maquina_parada", "Maquina parada*", "S=SIM;N=NAO", ZP2->ZP2_MAQPAR)
			oDlg:AddScript("$('#ps140man_combo_maquina_parada').attr('disabled',true);")
			oTab1:AddControl(oCombo)

			oCombo:= PSWebCombo():New("ps140man_combo_tipo", "Tipo Solicitacao*", "M=MECANICA;E=ELETRICA;I=INFORMATICA;L=LIMPEZA;P=MANUTENCAO EXTERNA - PATIO;3=OBRAS ROBSON;1=SERVICO - ISO PAINEL;2=SERVICO - ISOLAMENTO;4=SERVICO - PINTURA;5=SERVICO - PISO;6=SERVICO - TERCEIROS", ZP2->ZP2_TIPO)
			oDlg:AddScript("$('#ps140man_combo_tipo').prop('disabled',true);")
			oTab2:AddControl(oCombo)

			oCombo:= PSWebCombo():New("ps140man_combo_prioridade", "Prioridade*", "B=BAIXA;M=MEDIA;A=ALTA", ZP2->ZP2_PRIOR)
			oDlg:AddScript("$('#ps140man_combo_prioridade').prop('disabled',true);")
			oTab2:AddControl(oCombo)

			oGet:= PSWebGet():New("ps140man_get_prazo", "date", "Prazo*",,SubStr(DtoS(ZP2->ZP2_PRAZO), 1, 4)+"-"+SubStr(DtoS(ZP2->ZP2_PRAZO), 5, 2)+"-"+SubStr(DtoS(ZP2->ZP2_PRAZO), 7, 2))
			oDlg:AddScript("$('#ps140man_get_prazo').prop('readonly',true);")
			oTab2:AddControl(oGet)

			oCombo:= PSWebCombo():New("ps140man_combo_mauuso", "Mau Uso*", "N=NAO;S=SIM", ZP2->ZP2_MAUUSO)
			oDlg:AddScript("$('#ps140man_combo_mauuso').prop('disabled',true);")
			oTab2:AddControl(oCombo)

			oCombo:= PSWebCombo():New("ps140man_combo_preventiva", "Preventiva*", "N=NAO;S=SIM", ZP2->ZP2_PREVEN)
			oDlg:AddScript("$('#ps140man_combo_preventiva').prop('disabled',true);")
			oTab2:AddControl(oCombo)

			oCombo:= PSWebCombo():New("ps140man_combo_corretiva", "Corretiva*", "N=NAO;S=SIM", ZP2->ZP2_CORRET)
			oDlg:AddScript("$('#ps140man_combo_corretiva').prop('disabled',true);")
			oTab2:AddControl(oCombo)

			oCombo:= PSWebCombo():New("ps140man_combo_melhoria", "Melhoria*", "N=NAO;S=SIM", ZP2->ZP2_MELHOR)
			oDlg:AddScript("$('#ps140man_combo_melhoria').prop('disabled',true);")
			oTab2:AddControl(oCombo)

			oCombo:= PSWebCombo():New("ps140man_combo_qualidade", "Retrabalho da Manutencao*", "N=NAO;S=SIM", ZP2->ZP2_QUALID)//era Qualidade
			oDlg:AddScript("$('#ps140man_combo_qualidade').prop('disabled',true);")
			oTab2:AddControl(oCombo)

			oDlg:AddTab(oTab1)
			oDlg:Addtab(oTab2)

			oBtn:= PSWebButton():New("ps140man_btn_excluir", "Excluir")
			oDlg:AddButton(oBtn)
			cScript:= "$('#ps140man_btn_excluir').click(function(){"
			cScript+= "$(this).prop('disabled', true);"
			cScript+= "  $.ajax({"
			cScript+= "          async: true,"
			cScript+= "          method: 'POST',"
			cScript+= "          url: 'u_ps141man.apw',"
			cScript+= "          data: $('#ps140man_form_excluir').serialize()"
			cScript+= "         }).done(function(data){$('#ps140man_btn_excluir').prop('disabled', false);eval(data);});"
			cScript+= "});"
			oDlg:AddScript(cScript)

			oBtn:= PSWebButton():New("ps140man_btn_cancelar", "Cancelar")
			oDlg:AddButton(oBtn)
			cScript:= "$('#ps140man_btn_cancelar').click(function(){"
			cScript+= "$(this).prop('disabled', true);"
			cScript+= "  $.ajax({"
			cScript+= "          async: true,"
			cScript+= "          method: 'POST',"
			cScript+= "          url: 'u_ps101man.apw',"
			cScript+= "          data: {'PS100MAN_GET_USER':'"+HTTPSESSION->cUSER+"','PS100MAN_GET_PASS':'"+HTTPSESSION->cPASS+"'}"
			cScript+= "         }).done(function(data){$('#ps140man_btn_cancelar').prop('disabled', false);eval(data);});"
			cScript+= "});"
			oDlg:AddScript(cScript)

			cHtml+= oDlg:Show()
		Else
			oAlert:= PSWebAlert():New("ps140man_alert", "Maquina "+ZP2->ZP2_MAQ+", nao encontrada.", HTTPSESSION->cLogo)
			cHtml:= oAlert:show()
		EndIf

	Else
		oAlert:= PSWebAlert():New("ps140man_alert", "Solicitacao "+cSol+", nao encontrada.", HTTPSESSION->cLogo)
		cHtml:= oAlert:show()
	EndIf
Return cHtml
