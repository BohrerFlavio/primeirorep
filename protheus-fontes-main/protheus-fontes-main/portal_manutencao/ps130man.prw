#INCLUDE 'TBICONN.CH'
/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³PS130MAN  ºAutor  ³Ezequiel Pianegonda º Data ³  07/08/2017 º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³Alteracao de solicitacao                                    º±±
±±º          ³                                                            º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ AP                                                        º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/

User Function PS130MAN()
	Local cHtml:= ""
	Local cSol:= HTTPPOST->SOLICITACAO
	Local oDlg:= Nil
	Local oTab1:= Nil
	Local oTab2:= Nil
	Local oGet:= Nil
	Local oAlert:= Nil
	Local cScript:= ""
	Local nBaixo:= 0
	Local nMedio:= 0
	Local nAlto:= 0

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

		If Alltrim(HTTPSESSION->cUser) != Alltrim(ZP2->ZP2_USER)
			oAlert:= PSWebAlert():New("ps130man_alert", "Somente o usuario '"+Alltrim(ZP2->ZP2_USER)+"' pode alterar esta solicitacao.", HTTPSESSION->cLogo)
			cHtml:= oAlert:show()
			Return cHtml
		EndIf

		If !Empty(ZP2->ZP2_DTRFIM)
			oAlert:= PSWebAlert():New("ps130man_alert", "Solicitacao ja finalizada.", HTTPSESSION->cLogo)
			cHtml:= oAlert:show()
			Return cHtml
		EndIf

		If Left(ZP2->ZP2_STATUS, 1) $ "2|3|5"
			oAlert:= PSWebAlert():New("ps130man_alert", "Solicitacao ja iniciada ou ainda nao finalizada pela manutencao, portanto nao pode ser alterada.", HTTPSESSION->cLogo)
			cHtml:= oAlert:show()
			Return cHtml
		EndIf

		ZP3->(dbSetOrder(1))
		If ZP3->(dbSeek(xFilial("ZP3")+ZP2->ZP2_MAQ))

			//parametros para calculo do prazo
			nBaixo:= SuperGetMv("PS_MANBAI", .F., 7)
			nMedio:= SuperGetMv("PS_MANMED", .F., 2)
			nAlto:= SuperGetMv("PS_MANALT", .F., 0)

			oDlg:= PSWebDialog():New("ps130man_dialog_alterar", HTTPSESSION->cLogo+"<br>Alterar Solicitacao", "ps130man_form_alterar",,,,,.T.)

			oTab1:= PSWebTab():New('oTab1', 'Cadastrais', .T.)
			oTab2:= PSWebTab():New('oTab2', 'Atendimento', .F.)

			oGet:= PSWebGet():New("ps130man_get_solicitacao", "hidden", "",,ZP2->ZP2_CODIGO)
			oTab1:AddControl(oGet)

			oGet:= PSWebGet():New("ps130man_get_data", "date", "Data*",,SubStr(DtoS(ZP2->ZP2_DATA), 1, 4)+"-"+SubStr(DtoS(ZP2->ZP2_DATA), 5, 2)+"-"+SubStr(DtoS(ZP2->ZP2_DATA), 7, 2))
			oDlg:AddScript("$('#ps130man_get_data').prop('readonly',true);")
			oTab1:AddControl(oGet)

			oGet:= PSWebGet():New("ps130man_get_sol", "text", "Solicitante*",,ZP2->ZP2_USER)
			oDlg:AddScript("$('#ps130man_get_sol').prop('readonly',true);")
			oTab1:AddControl(oGet)

			oGet:= PSWebGet():New("ps130man_get_desc", "text", "Descricao*",,ZP2->ZP2_DESC)
			oTab1:AddControl(oGet)
			If Left(ZP2->ZP2_STATUS, 1) == "4"
				oDlg:AddScript("$('#ps130man_get_desc').prop('readonly',true);")
			EndIf

			oMulti:= PSWebMultiget():New("ps130man_get_situacao_anterior", "Situacao.Anterior", 5, StrTran(Alltrim(ZP2->ZP2_HIST), Chr(13)+Chr(10), "\n"))
			oDlg:AddScript("$('#ps130man_get_situacao_anterior').prop('readonly',true);")
			oTab1:AddControl(oMulti)

			oMulti:= PSWebMultiget():New("ps130man_get_situacao", "Situacao", 5)
			oTab1:AddControl(oMulti)

			oGet:= PSWebGet():New("ps130man_get_maquina", "text", "Cod.Maquina*", .T.,ZP2->ZP2_MAQ)
			oTab1:AddControl(oGet)
			If Left(ZP2->ZP2_STATUS, 1) == "1"
				cScript:= "$('#ps130man_get_maquina_F3').click(function(){"
				cScript+= "  $.ajax({"
				cScript+= "          async: false,"
				cScript+= "          method: 'POST',"
				cScript+= "          url: 'u_pswebf3.apw',"
				cScript+= "          data: {'titulo':'Consulta maquina', 'id':'id_dialog', 'emp':'"+HTTPSESSION->cEmp+"', 'fil':'"+HTTPSESSION->cFil+"', 'cols':'ZP3_COD:Codigo;ZP3_NOME:Nome;ZP3_GAR:Garantia;ZP3_CC:CC;CTT_DESC01:Descricao', 'from_':'ZP3,CTT', 'where':'CTT_CUSTO=ZP3_CC AND ZP3_CC IN "+PSWFormat(HTTPSESSION->cCC)+" ','ret':'ps130man_get_maquina:0;ps130man_get_dmaquina:1;ps130man_get_gmaquina:2;ps130man_get_cc:3;ps130man_get_dcc:4'},"
				cScript+= "         }).done(function(data){eval(data);});"
				cScript+= "});"
				oDlg:AddScript(cScript)
			ElseIf Left(ZP2->ZP2_STATUS, 1) == "4"
				oDlg:AddScript("$('#ps130man_get_maquina').prop('readonly',true);")
			EndIf

			oGet:= PSWebGet():New("ps130man_get_dmaquina", "text", "Desc.Maquina*",,ZP3->ZP3_NOME)
			oDlg:AddScript("$('#ps130man_get_dmaquina').prop('readonly',true);")
			oTab1:AddControl(oGet)

			oGet:= PSWebGet():New("ps130man_get_gmaquina", "date", "Garantia Maquina*",,IIF(!Empty(ZP3->ZP3_GAR), SubStr(DtoS(ZP3->ZP3_GAR), 1, 4)+"-"+SubStr(DtoS(ZP3->ZP3_GAR), 5, 2)+"-"+SubStr(DtoS(ZP3->ZP3_GAR), 7, 2), ""))
			oDlg:AddScript("$('#ps130man_get_gmaquina').prop('readonly',true);")
			oTab1:AddControl(oGet)

			oGet:= PSWebGet():New("ps130man_get_cc", "text", "Centro de custo*",,ZP2->ZP2_CC)
			oDlg:AddScript("$('#ps130man_get_cc').prop('readonly',true);")
			oTab1:AddControl(oGet)

			dbSelectArea("CTT")
			oGet:= PSWebGet():New("ps130man_get_dcc", "text", "Desc.Centro de custo*",,Alltrim(fBuscaCpo("CTT", 1, xFilial("CTT")+ZP2->ZP2_CC, "CTT_DESC01")))
			oDlg:AddScript("$('#ps130man_get_dcc').prop('readonly',true);")
			oTab1:AddControl(oGet)

			oCombo:= PSWebCombo():New("ps130man_combo_maquina_parada", "Maquina parada*", "S=SIM;N=NAO", ZP2->ZP2_MAQPAR)
			oDlg:AddScript("$('#ps130man_combo_maquina_parada').attr('disabled',true);")
			oTab1:AddControl(oCombo)

			oCombo:= PSWebCombo():New("ps130man_combo_final", "Finalizar*", " =&nbsp;N=NAO;S=SIM")
			If Alltrim(HTTPSESSION->cUser) != Alltrim(ZP2->ZP2_USER)
				oDlg:AddScript("$('#ps120man_combo_final').attr('disabled',true);")
			EndIf
			oTab2:AddControl(oCombo)

			oCombo:= PSWebCombo():New("ps130man_combo_tipo", "Tipo Solicitacao*", "M=MECANICA;E=ELETRICA;I=INFORMATICA;L=LIMPEZA;P=MANUTENCAO EXTERNA - PATIO;3=OBRAS LUIZ;1=SERVICO - ISO PAINEL;2=SERVICO - ISOLAMENTO;4=SERVICO - PINTURA;5=SERVICO - PISO;6=SERVICO - TERCEIROS", ZP2->ZP2_TIPO)
			oTab2:AddControl(oCombo)
			If Left(ZP2->ZP2_STATUS, 1) == "4"
				oDlg:AddScript("$('#ps130man_combo_tipo').prop('disabled',true);")
			EndIf

			oCombo:= PSWebCombo():New("ps130man_combo_prioridade", "Prioridade*", "B=BAIXA;M=MEDIA;A=ALTA", ZP2->ZP2_PRIOR)
			If Left(ZP2->ZP2_STATUS, 1) == "1"	
				cScript:= "$('#ps130man_combo_prioridade').on('change', function() {"
				cScript+= "if (this.value == 'A') {"
				cScript+= "  $('#ps130man_get_prazo').val('"+SubStr(DtoS(Date()+nAlto), 1, 4)+"-"+SubStr(DtoS(Date()+nAlto), 5, 2)+"-"+SubStr(DtoS(Date()+nAlto), 7, 2)+"');"
				cScript+= "}else if (this.value == 'M') {"
				cScript+= "  $('#ps130man_get_prazo').val('"+SubStr(DtoS(Date()+nMedio), 1, 4)+"-"+SubStr(DtoS(Date()+nMedio), 5, 2)+"-"+SubStr(DtoS(Date()+nMedio), 7, 2)+"');"
				cScript+= "}else if (this.value == 'B') {"
				cScript+= "  $('#ps130man_get_prazo').val('"+SubStr(DtoS(Date()+nBaixo), 1, 4)+"-"+SubStr(DtoS(Date()+nBaixo), 5, 2)+"-"+SubStr(DtoS(Date()+nBaixo), 7, 2)+"');"
				cScript+= "}"
				cScript+= "});"
				oDlg:AddScript(cScript)
			ElseIf Left(ZP2->ZP2_STATUS, 1) == "4"
				oDlg:AddScript("$('#ps130man_combo_prioridade').prop('disabled',true);")
			EndIf
			oTab2:AddControl(oCombo)

			oGet:= PSWebGet():New("ps130man_get_prazo", "date", "Prazo*",,SubStr(DtoS(ZP2->ZP2_PRAZO), 1, 4)+"-"+SubStr(DtoS(ZP2->ZP2_PRAZO), 5, 2)+"-"+SubStr(DtoS(ZP2->ZP2_PRAZO), 7, 2))
			oTab2:AddControl(oGet)
			If Left(ZP2->ZP2_STATUS, 1) == "4"
				oDlg:AddScript("$('#ps130man_get_prazo').prop('readonly',true);")
			EndIf

			oCombo:= PSWebCombo():New("ps130man_combo_mauuso", "Mau Uso*", "N=NAO;S=SIM", ZP2->ZP2_MAUUSO)
			oTab2:AddControl(oCombo)
			If Left(ZP2->ZP2_STATUS, 1) == "4"
				oDlg:AddScript("$('#ps130man_combo_mauuso').prop('disabled',true);")
			EndIf

			oCombo:= PSWebCombo():New("ps130man_combo_preventiva", "Preventiva*", "N=NAO;S=SIM", ZP2->ZP2_PREVEN)
			oTab2:AddControl(oCombo)
			If Left(ZP2->ZP2_STATUS, 1) == "4"
				oDlg:AddScript("$('#ps130man_combo_preventiva').prop('disabled',true);")
			EndIf

			oCombo:= PSWebCombo():New("ps130man_combo_corretiva", "Corretiva*", "N=NAO;S=SIM", ZP2->ZP2_CORRET)
			oTab2:AddControl(oCombo)
			If Left(ZP2->ZP2_STATUS, 1) == "4"
				oDlg:AddScript("$('#ps130man_combo_corretiva').prop('disabled',true);")
			EndIf

			oCombo:= PSWebCombo():New("ps130man_combo_melhoria", "Melhoria*", "N=NAO;S=SIM", ZP2->ZP2_MELHOR)
			oTab2:AddControl(oCombo)
			If Left(ZP2->ZP2_STATUS, 1) == "4"
				oDlg:AddScript("$('#ps130man_combo_melhoria').prop('disabled',true);")
			EndIf

			oCombo:= PSWebCombo():New("ps130man_combo_qualidade", "Retrabalho da Manutencao*", "N=NAO;S=SIM", ZP2->ZP2_QUALID)//era Qualidade
			oTab2:AddControl(oCombo)
			If Left(ZP2->ZP2_STATUS, 1) == "4"
				oDlg:AddScript("$('#ps130man_combo_qualidade').prop('disabled',true);")
			EndIf

			oDlg:AddTab(oTab1)
			oDlg:Addtab(oTab2)

			oBtn:= PSWebButton():New("ps130man_btn_alterar", "Alterar")
			oDlg:AddButton(oBtn)
			cScript:= "$('#ps130man_btn_alterar').click(function(){"
			cScript+= "$(this).prop('disabled', true);"
			cScript+= "  $.ajax({"
			cScript+= "          async: true,"
			cScript+= "          method: 'POST',"
			cScript+= "          url: 'u_ps131man.apw',"
			cScript+= "          data: $('#ps130man_form_alterar').serialize()"
			cScript+= "         }).done(function(data){$('#ps130man_btn_alterar').prop('disabled', false);eval(data);});"
			cScript+= "});"
			oDlg:AddScript(cScript)

			oBtn:= PSWebButton():New("ps130man_btn_cancelar", "Cancelar")
			oDlg:AddButton(oBtn)
			cScript:= "$('#ps130man_btn_cancelar').click(function(){"
			cScript+= "$(this).prop('disabled', true);"
			cScript+= "  $.ajax({"
			cScript+= "          async: true,"
			cScript+= "          method: 'POST',"
			cScript+= "          url: 'u_ps101man.apw',"
			cScript+= "          data: {'PS100MAN_GET_USER':'"+HTTPSESSION->cUSER+"','PS100MAN_GET_PASS':'"+HTTPSESSION->cPASS+"'}"
			cScript+= "         }).done(function(data){$('#ps130man_btn_cancelar').prop('disabled', false);eval(data);});"
			cScript+= "});"
			oDlg:AddScript(cScript)

			cHtml+= oDlg:Show()
		Else
			oAlert:= PSWebAlert():New("ps130man_alert", "Maquina "+ZP2->ZP2_MAQ+", nao encontrada.", HTTPSESSION->cLogo)
			cHtml:= oAlert:show()
		EndIf

	Else
		oAlert:= PSWebAlert():New("ps130man_alert", "Solicitacao "+cSol+", nao encontrada.", HTTPSESSION->cLogo)
		cHtml:= oAlert:show()
	EndIf
Return cHtml

Static Function PSWFormat(cExp)
	Local cRet:= ""

	cRet:= FormatIn(cExp, ";")
	cRet:= StrTran(cRet, "'", "#")
Return cRet
