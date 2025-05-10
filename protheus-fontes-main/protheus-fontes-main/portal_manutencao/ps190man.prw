#INCLUDE 'TBICONN.CH'

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³PS190MAN  ºAutor  ³Ezequiel Pianegonda º Data ³  27/03/2018 º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³Consulta posicao da solicitacao                             º±±
±±º          ³                                                            º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ AP                                                        º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/

User Function PS190MAN()
	Local cHtml:= ""
	Local cSol:= HTTPPOST->SOLICITACAO
	Local oHtml:= Nil
	Local oDlg:= Nil
	Local cTable:= ""

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

			oDlg:= PSWebDialog():New("ps190man_dialog_posicao", HTTPSESSION->cLogo+"<br>Posicao", "ps190man_form_posicao",,,,,.T.)

			cTable:= "<table width=100% border=1 style='border-collapse:collapse'>"
			cTable+= "<tr>"
			cTable+= "<td width=10%><b>Solicitacao</b></td><td>"+cSol+"</td>"
			cTable+= "<td width=10%><b>Data</b></td><td>"+DtoC(ZP2->ZP2_DATA)+"</td>"
			cTable+= "<td width=10%><b>Solicitante</b></td><td>"+ZP2->ZP2_USER+"</td>"
			cTable+= "</tr>"
			cTable+= "<tr>"
			cTable+= "<td width=10%><b>Descricao</b></td><td>"+ZP2->ZP2_DESC+"</td>"
			cTable+= "<td width=10%><b>Situacao</b></td><td>"+StrTran(ZP2->ZP2_HIST, Chr(13)+Chr(10), "")+"</td>"
			cTable+= "<td width=10%><b>Cod.Maquina</b></td><td>"+ZP2->ZP2_MAQ+"</td>"
			cTable+= "</tr>"
			cTable+= "<tr>"
			cTable+= "<td width=10%><b>Desc.Maquina</b></td><td>"+ZP3->ZP3_NOME+"</td>"
			cTable+= "<td width=10%><b>Garantia.Maquina</b></td><td>"+DtoC(ZP3->(ZP3_GAR))+"</td>"
			cTable+= "<td width=10%><b>Centro de custo</b></td><td>"+ZP2->ZP2_CC+"</td>"
			cTable+= "</tr>"
			cTable+= "<tr>"
			cTable+= "<td width=10%><b>Desc.Centro de custo</b></td><td>"+Alltrim(CTT->(fBuscaCpo('CTT', 1, xFilial('CTT')+ZP2->ZP2_CC, 'CTT_DESC01')))+"</td>"
			cTable+= "<td width=10%><b>Maquina parada</b></td><td>"+IIF(ZP2->ZP2_MAQPAR == "S", "SIM", "NAO")+"</td>"
			cTable+= "<td width=10%><b>Tipo Solicitacao</b></td><td>"+GetTipo(ZP2->ZP2_TIPO)+"</td>"
			cTable+= "</tr>"
			cTable+= "<tr>"
			cTable+= "<td width=10%><b>Prioridade</b></td><td>"+GetPrior(ZP2->ZP2_PRIOR)+"</td>"
			cTable+= "<td width=10%><b>Prazo</b></td><td>"+DtoC(ZP2->ZP2_PRAZO)+"</td>"
			cTable+= "<td width=10%><b>Nova Prioridade</b></td><td>"+GetPrior(ZP2->ZP2_NPRIOR)+"</td>"
			cTable+= "</tr>"
			cTable+= "<tr>"
			cTable+= "<td width=10%><b>Novo Prazo</b></td><td>"+DtoC(ZP2->ZP2_NPRAZO)+"</td>"
			cTable+= "<td width=10%><b>Mau Uso</b></td><td>"+IIF(ZP2->ZP2_MAUUSO == "S", "SIM", "NAO")+"</td>"
			cTable+= "<td width=10%><b>Novo Mau Uso</b></td><td>"+IIF(ZP2->ZP2_NMAUUS == "S", "SIM", "NAO")+"</td>"
			cTable+= "</tr>"
			cTable+= "<tr>"
			cTable+= "<td width=10%><b>Preventiva</b></td><td>"+IIF(ZP2->ZP2_PREVEN == "S", "SIM", "NAO")+"</td>"
			cTable+= "<td width=10%><b>Corretiva</b></td><td>"+IIF(ZP2->ZP2_CORRET == "S", "SIM", "NAO")+"</td>"
			cTable+= "<td width=10%><b>Melhoria</b></td><td>"+IIF(ZP2->ZP2_MELHOR == "S", "SIM", "NAO")+"</td>"
			cTable+= "</tr>"
			cTable+= "<tr>"
			cTable+= "<td width=10%><b>Retrabalho Manutencao</b></td><td>"+IIF(ZP2->ZP2_QUALID == "S", "SIM", "NAO")+"</td>"
			cTable+= "<td width=10%><b>Dt.Inicio Serv</b></td><td>"+DtoC(ZP2->ZP2_DTINI)+"</td>"
			cTable+= "<td width=10%><b>Hr.Inicio Serv</b></td><td>"+ZP2->ZP2_HRINI+"</td>"
			cTable+= "</tr>"
			cTable+= "<tr>"
			cTable+= "<td width=10%><b>Dt.Fin.Serv</b></td><td>"+DtoC(ZP2->ZP2_DTFIN)+"</td>"
			cTable+= "<td width=10%><b>Hr.Fin.Serv</b></td><td>"+ZP2->ZP2_HRFIN+"</td>"
			cTable+= "<td width=10%><b>Manutentor</b></td><td>"+ZP2->ZP2_MANUTE+"</td>"
			cTable+= "</tr>"
			cTable+= "</table>"
			oHtml:= PSWebHtml():New(cTable)
			oDlg:AddControl(oHtml)

			cTable:= "<table width=100% border=1 style='border-collapse:collapse'>"
			cTable+= "<tr>"
			SX3->(dbSetOrder(2))
			SX3->(dbSeek("ZP4_STATUS"))
			cTable+= "<td><b>"+X3Titulo()+"</b></td>"
			SX3->(dbSetOrder(2))
			SX3->(dbSeek("ZP4_PRODUT"))
			cTable+= "<td><b>"+X3Titulo()+"</b></td>"
			SX3->(dbSetOrder(2))
			SX3->(dbSeek("ZP4_QUANT"))
			cTable+= "<td><b>"+X3Titulo()+"</b></td>"
			SX3->(dbSetOrder(2))
			SX3->(dbSeek("ZP4_UM"))
			cTable+= "<td><b>"+X3Titulo()+"</b></td>"
			SX3->(dbSetOrder(2))
			SX3->(dbSeek("ZP4_DESC"))
			cTable+= "<td><b>"+X3Titulo()+"</b></td>"
			SX3->(dbSetOrder(2))
			SX3->(dbSeek("ZP4_SOLC"))
			cTable+= "<td><b>"+X3Titulo()+"</b></td>"
			SX3->(dbSetOrder(2))
			SX3->(dbSeek("ZP4_ITEMSC"))
			cTable+= "<td><b>"+X3Titulo()+"</b></td>"
			SX3->(dbSetOrder(2))
			SX3->(dbSeek("ZP4_SOLA"))
			cTable+= "<td><b>"+X3Titulo()+"</b></td>"
			SX3->(dbSetOrder(2))
			SX3->(dbSeek("ZP4_ITEMSA"))
			cTable+= "<td><b>"+X3Titulo()+"</b></td>"
			SX3->(dbSetOrder(2))
			SX3->(dbSeek("ZP4_DTSC"))
			cTable+= "<td><b>"+X3Titulo()+"</b></td>"
			SX3->(dbSetOrder(2))
			SX3->(dbSeek("ZP4_DTSA"))
			cTable+= "<td><b>"+X3Titulo()+"</b></td>"
			SX3->(dbSetOrder(2))
			SX3->(dbSeek("ZP4_PC"))
			cTable+= "<td><b>"+X3Titulo()+"</b></td>"
			SX3->(dbSetOrder(2))
			SX3->(dbSeek("ZP4_ITEMPC"))
			cTable+= "<td><b>"+X3Titulo()+"</b></td>"
			SX3->(dbSetOrder(2))
			SX3->(dbSeek("ZP4_DTPC"))
			cTable+= "<td><b>"+X3Titulo()+"</b></td>"
			SX3->(dbSetOrder(2))
			SX3->(dbSeek("ZP4_DTLPC"))
			cTable+= "<td><b>"+X3Titulo()+"</b></td>"
			SX3->(dbSetOrder(2))
			SX3->(dbSeek("ZP4_DTEPC"))
			cTable+= "<td><b>"+X3Titulo()+"</b></td>"
			cTable+= "</tr>"

			ZP4->(dbSetOrder(1))
			ZP4->(dbSeek(xfilial("ZP4")+ZP2->ZP2_CODIGO))

			Do While !ZP4->(EOF()) .AND. xfilial("ZP4")+ZP2->ZP2_CODIGO == ZP4->ZP4_FILIAL+ZP4->ZP4_CODIGO
				cTable+= "<tr>"
				cTable+= "<td>"+ZP4->ZP4_STATUS+"</td>"
				cTable+= "<td>"+ZP4->ZP4_PRODUT+"</td>"
				cTable+= "<td>"+Transform(ZP4->ZP4_QUANT, "@e 999,999,999.99")+"</td>"
				cTable+= "<td>"+ZP4->ZP4_UM+"</td>"
				cTable+= "<td>"+ZP4->ZP4_DESC+"</td>"
				cTable+= "<td>"+ZP4->ZP4_SOLC+"</td>"
				cTable+= "<td>"+ZP4->ZP4_ITEMSC+"</td>"
				cTable+= "<td>"+ZP4->ZP4_SOLA+"</td>"
				cTable+= "<td>"+ZP4->ZP4_ITEMSA+"</td>"
				cTable+= "<td>"+DtoC(ZP4->ZP4_DTSC)+"</td>"
				cTable+= "<td>"+DtoC(ZP4->ZP4_DTSA)+"</td>"
				cTable+= "<td>"+ZP4->ZP4_PC+"</td>"
				cTable+= "<td>"+ZP4->ZP4_ITEMPC+"</td>"
				cTable+= "<td>"+DtoC(ZP4->ZP4_DTPC)+"</td>"
				cTable+= "<td>"+DtoC(ZP4->ZP4_DTLPC)+"</td>"
				cTable+= "<td>"+DtoC(ZP4->ZP4_DTEPC)+"</td>"
				cTable+= "</tr>"
				ZP4->(dbSkip())
			EndDo 

			cTable+= "</table>"
			oHtml:= PSWebHtml():New(cTable)
			oDlg:AddControl(oHtml)

			oBtn:= PSWebButton():New("ps190man_btn_cancelar", "Cancelar")
			oDlg:AddButton(oBtn)
			cScript:= "$('#ps190man_btn_cancelar').click(function(){"
			cScript+= "$(this).prop('disabled', true);"
			cScript+= "  $.ajax({"
			cScript+= "          async: true,"
			cScript+= "          method: 'POST',"
			cScript+= "          url: 'u_ps101man.apw',"
			cScript+= "          data: {'PS100MAN_GET_USER':'"+HTTPSESSION->cUSER+"','PS100MAN_GET_PASS':'"+HTTPSESSION->cPASS+"'}"
			cScript+= "         }).done(function(data){$('#ps190man_btn_cancelar').prop('disabled', false);eval(data);});"
			cScript+= "});"
			oDlg:AddScript(cScript)	
			cHtml+= oDlg:Show()
		Else
			oAlert:= PSWebAlert():New("ps190man_alert", "Maquina '"+ZP2->ZP2_MAQ+"' nao encontrada", HTTPSESSION->cLogo)
			cHtml:= oAlert:show()
		EndIf

	Else
		oAlert:= PSWebAlert():New("ps190man_alert", "Solicitacao '"+cSol+"' nao encontrada", HTTPSESSION->cLogo)
		cHtml:= oAlert:show()
	EndIf
Return cHtml

Static Function GetTipo(cTipo)
	Local cRet:= ""

	Do Case
		Case cTipo == "M"
		cRet:= "MECANICA"
		Case cTipo == "E"
		cRet:= "ELETRICA"
		Case cTipo == "I"
		cRet:= "INFORMATICA"
		Case cTipo == "L"
		cRet:= "LIMPEZA"
		Case cTipo == "P"
		cRet:= "MANUTENCAO EXTERNA - PATIO"
		Case cTipo == "1"
		cRet:= "SERVICO - ISO PAINEL"
		Case cTipo == "2"
		cRet:= "SERVICO - ISOLAMENTO"
		Case cTipo == "3"
		cRet:= "OBRAS LUIZ"
		Case cTipo == "4"
		cRet:= "SERVICO - PINTURA"
		Case cTipo == "5"
		cRet:= "SERVICO - PISO"
		Case cTipo == "6"
		cRet:= "SERVICO - TERCEIROS"
	Endcase

Return cRet

Static Function GetPrior(cPrior)
	Local cRet:= ""

	Do Case
		Case cPrior == "N"
		cRet:= "NORMAL"
		Case cPrior == "B"
		cRet:= "BAIXA"
		Case cPrior == "M"
		cRet:= "MEDIA"
		Case cPrior == "A"
		cRet:= "ALTA"
	EndCase

Return cRet
