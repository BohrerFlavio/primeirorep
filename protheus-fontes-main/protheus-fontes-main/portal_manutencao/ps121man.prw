#INCLUDE 'TBICONN.CH'

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³PS121MAN  ºAutor  ³Ezequiel Pianegonda º Data ³  07/07/2017 º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³Gravacao da solicitacao (alteracao)                         º±±
±±º          ³                                                            º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ AP                                                        º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/

User Function PS121MAN()
	Local cHtml:= ""
	Local cSol:= HTTPPOST->PS120MAN_GET_SOLICITACAO
	//Local cFinal:= HTTPPOST->PS120MAN_COMBO_FINAL
	Local cHist:= HTTPPOST->PS120MAN_GET_SITUACAO
	Local cTipo:= HTTPPOST->PS120MAN_COMBO_TIPO
	Local cNPrior:= HTTPPOST->PS120MAN_COMBO_NPRIORIDADE
	Local dNPrazo:= StoD(StrTran(HTTPPOST->PS120MAN_GET_NPRAZO, "-", ""))
	Local cMauUso:= HTTPPOST->PS120MAN_COMBO_MAUUSO
	Local cNMauUso:= HTTPPOST->PS120MAN_COMBO_NMAUUSO
	Local cPrevent:= HTTPPOST->PS120MAN_COMBO_PREVENTIVA
	Local cCorret:= HTTPPOST->PS120MAN_COMBO_CORRETIVA
	Local cMelhor:= HTTPPOST->PS120MAN_COMBO_MELHORIA
	Local cQualid:= HTTPPOST->PS120MAN_COMBO_QUALIDADE
	Local dDataIni:= StoD(StrTran(HTTPPOST->PS120MAN_GET_DATAINI, "-", ""))
	Local cHoraIni:= HTTPPOST->PS120MAN_GET_HORAINI
	Local dDataFin:= StoD(StrTran(HTTPPOST->PS120MAN_GET_DATAFIN, "-", ""))
	Local cHoraFin:= HTTPPOST->PS120MAN_GET_HORAFIN
	Local cManut:= HTTPPOST->PS120MAN_GET_MANUTENTOR
	Local cTabela:= HTTPPOST->TABELA
	Local nX:= 0
	Local nY:= 0
	Local aTabela:= {}
	Local aLinha:= {}
	Local aCampos:= {}
	Local cStatus:= ""
	Local cProdut:= ""
	Local cDesc:= ""
	Local nQuant:= 0
	Local cUm:= ""
	Local cSc:= ""
	Local cSa:= ""
	Local cItSc:= ""
	Local cItSa:= ""
	Local lContinua:= .T.
	Local cStatus:= ""
	Local cLegenda:= ""
	Local lNotSol:= .F.
	Local oAlert:= Nil
	Local lDisp:= .F.

	If ValType(HTTPSESSION->cEMP) == "U" .OR. ValType(HTTPSESSION->cFil) == "U" .OR. ValType(HTTPSESSION->cCC) == "U"
		cHtml:= "  $.ajax({"
		cHtml+= "          async: true,"
		cHtml+= "          method: 'POST',"
		cHtml+= "          url: 'u_ps001man.apw',"
		cHtml+= "         }).done(function(data){eval(data);});"
		Return cHtml
	EndIf

	lContinua:= lContinua .AND. !Empty(cSol)
	//lContinua:= lContinua .AND. !Empty(cFinal)
	//lContinua:= lContinua .AND. !Empty(cHist)
	lContinua:= lContinua .AND. !Empty(cTipo)
	//lContinua:= lContinua .AND. !Empty(cNPrior)
	//lContinua:= lContinua .AND. !Empty(dNPrazo)
	lContinua:= lContinua .AND. !Empty(cNMauUso)
	lContinua:= lContinua .AND. !Empty(cPrevent)
	lContinua:= lContinua .AND. !Empty(cCorret)
	lContinua:= lContinua .AND. !Empty(cMelhor)
	lContinua:= lContinua .AND. !Empty(cQualid)
	//lContinua:= lContinua .AND. !Empty(dDataIni)
	//lContinua:= lContinua .AND. !Empty(cHoraIni)
	//lContinua:= lContinua .AND. !Empty(dDataFin)
	//lContinua:= lContinua .AND. !Empty(cHoraFin)
	//lContinua:= lContinua .AND. !Empty(cTabela)

	If lContinua

		//RPCSetType(3)
		RESET ENVIRONMENT
		PREPARE ENVIRONMENT EMPRESA HTTPSESSION->cEmp FILIAL HTTPSESSION->cFil

		ZP2->(dbSetOrder(1))
		If ZP2->(DbSeek(xFilial("ZP2")+cSol))

			//If cFinal == "S" .AND. Alltrim(HTTPSESSION->cUser) != Alltrim(ZP2->ZP2_USER)
			//	oAlert:= PSWebAlert():New("ps121man_alert", "Apenas o solicitante pode finalizar a solicitacao, verifique.", HTTPSESSION->cLogo)
			//	cHtml:= oAlert:show()
			//	Return cHtml
			//EndIf

			If !Empty(ZP2->ZP2_DTRFIM)
				oAlert:= PSWebAlert():New("ps121man_alert", "Solicitacao ja finalizada pela manutencao e solicitante.", HTTPSESSION->cLogo)
				cHtml:= oAlert:show()
				Return cHtml
			EndIf

			If (!Empty(dDataFin) .AND. Empty(cHoraFin)) .OR. (Empty(dDataFin) .AND. !Empty(cHoraFin))
				oAlert:= PSWebAlert():New("ps121man_alert", "Os campos Dt.Fin.Serv e Hr.Fim.Serv devem ser preenchidos.", HTTPSESSION->cLogo)
				cHtml:= oAlert:show()
				Return cHtml
			EndIf

			If !Empty(dDataFin)
				If Empty(cManut)
					oAlert:= PSWebAlert():New("ps121man_alert", "Informe o campo Manutentor.", HTTPSESSION->cLogo)
					cHtml:= oAlert:show()
					Return cHtml
				EndIf
			EndIf

			If !Empty(dDataFin)
				lDisp:= .T.
				ZP4->(dbSetOrder(1))
				ZP4->(dbSeek(xFilial("ZP4")+ZP2->ZP2_CODIGO))
				Do While !ZP4->(EOF()) .AND. xFilial("ZP4")+ZP2->ZP2_CODIGO == ZP4->ZP4_FILIAL + ZP4->ZP4_CODIGO
					If Left(ZP4->ZP4_STATUS, 1) != "3"
						lDisp:= .F.
					EndIf
					ZP4->(dbSkip())
				EndDo
				If !lDisp
					oAlert:= PSWebAlert():New("ps121man_alert", "Nao e possivel finalizar esta solicitacao pois existe itens solicitados nao disponiveis, verifique.", HTTPSESSION->cLogo)
					cHtml:= oAlert:show()
					Return cHtml
				EndIf
			EndIf

			//If !Empty(dNPrazo) .AND. dNPrazo < Date()
			//	oAlert:= PSWebAlert():New("ps121man_alert", "Novo Prazo informado nao pode ser inferior a data de hoje.", HTTPSESSION->cLogo)
			//	cHtml:= oAlert:show()
			//	Return cHtml
			//EndIf

			//If !Empty(dDataIni) .AND.  .AND. dDataIni < Date()
			//	oAlert:= PSWebAlert():New("ps121man_alert", "Data inicio informada nao pode ser inferior a data de hoje.", HTTPSESSION->cLogo)
			//	cHtml:= oAlert:show()
			//	Return cHtml
			//EndIf

			//If !Empty(dDataFin) .AND. dDataFin < Date()
			//	oAlert:= PSWebAlert():New("ps121man_alert", "Data fim informada nao pode ser inferior a data de hoje.", HTTPSESSION->cLogo)
			//	cHtml:= oAlert:show()
			//	Return cHtml
			//EndIf

			//If !Empty(dDataIni) .AND. !Empty(dDataFin) .AND.!Empty(dDataFin)
			//	oAlert:= PSWebAlert():New("ps121man_alert", "Solicitacao ja finalizada pela manutencao, aguardando finalizacao do solicitante.", HTTPSESSION->cLogo)
			//	cHtml:= oAlert:show()
			//	Return cHtml
			//EndIf

			If !Empty(dDataIni) .AND. Empty(dDataFin)
				cStatus:= "3 - Iniciado (Manutencao)"
			ElseIf !Empty(dDataFin)// .AND. cFinal != "S"
				cStatus:= "4 - Finalizado (Manutencao)"
				//ElseIf cFinal == "S"
				//	cStatus:= "5 - Finalizado (Solicitante)"
			Else
				cStatus:= "2 - Sob analise (Manutencao)"
			EndIf

			If Left(cStatus, 1) == "5"
				cLegenda:= "<img src=imagens/vermelho.png>"
			ElseIf Left(cStatus, 1) == "4"
				cLegenda:= "<img src=imagens/azul.png>"
			Else
				cLegenda:= "<img src=imagens/amarelo.png>"
			EndIf

			Begin Transaction

				RecLock("ZP2", .F.)
				ZP2->ZP2_LEGEND:= cLegenda
				ZP2->ZP2_STATUS:= cStatus
				ZP2->ZP2_HIST:= U_PS002MAN(ZP2->ZP2_HIST)+Chr(13)+Chr(10)+U_PS002MAN(cHist)
				ZP2->ZP2_TIPO:= cTipo
				ZP2->ZP2_NPRIOR:= cNPrior
				ZP2->ZP2_NPRAZO:= dNPrazo
				ZP2->ZP2_NMAUUS:= cNMauUso
				ZP2->ZP2_PREVENT:= cPrevent
				ZP2->ZP2_CORRET:= cCorret
				ZP2->ZP2_MELHOR:= cMelhor
				ZP2->ZP2_QUALID:= cQualid
				ZP2->ZP2_DTINI:= dDataIni
				ZP2->ZP2_HRINI:= cHoraIni
				ZP2->ZP2_DTFIN:= dDataFin
				ZP2->ZP2_HRFIN:= cHoraFin
				ZP2->ZP2_MANUTE:= cManut
				ZP2->ZP2_USRCOM:= HTTPSESSION->cUser

				//If cFinal == "S"
				//	ZP2->ZP2_DTRFIM:= Date()
				//	ZP2->ZP2_HRRFIM:= Left(Time(), 5)
				//EndIf
				ZP2->(MsUnLock())
				ZP4->(dbSetOrder(1))
				ZP4->(dbSeek(xFilial("ZP4")+cSol))
				Do While !ZP4->(EOF()) .AND. xFilial("ZP4")+cSol == ZP4->ZP4_FILIAL+ZP4->ZP4_CODIGO
					If Left(ZP4->ZP4_STATUS, 1) == "1"
						RecLock("ZP4", .F.)
						ZP4->(dbDelete())
						ZP4->(MsUnLock())
					EndIf
					ZP4->(dbSkip())
				EndDo

				aTabela:= StrTokArr(cTabela, "|")

				For nX:= 1 To Len(aTabela)
					aLinha:= StrTokArr(aTabela[nX], ";")
					cStatus:= ""
					cProdut:= ""
					cDesc:= ""
					nQuant:= 0
					cUm:= ""
					cSc:= ""
					cSa:= ""
					cItSc:= ""
					cItSa:= ""
					For nY:= 1 To Len(aLinha)
						aCampos:= StrTokArr(aLinha[nY], ":")
						If Len(aCampos) == 3
							Do Case
								Case nY == 1
								cStatus:= aCampos[3]
								Case nY == 2
								cProdut:= aCampos[3]
								Case nY == 3
								cDesc:= aCampos[3]
								Case nY == 4
								nQuant:= val(StrTran(StrTran(aCampos[3], '.', ''), ',', '.'))
								Case nY == 5
								cUm:= aCampos[3]
								Case nY == 6
								cSc:= aCampos[3]
								Case nY == 7
								cItSc:= aCampos[3]
								Case nY == 8
								cSa:= aCampos[3]
								Case nY == 9
								cItSa:= aCampos[3]
							End Dase
						EndIf
					Next nY

					If Left(cStatus, 1) == "1"
						SB1->(dbSetOrder(1))
						If SB1->(dbSeek(xFilial("SB1")+Alltrim(cProdut)))
							SB2->(dbSetOrder(1))
							If !SB2->(dbSeek(xFilial("SB2")+SB1->B1_COD+SB1->B1_LOCPAD))
								CriaSB2(SB1->B1_COD,SB1->B1_LOCPAD)
							EndIf
						EndIf
						RecLock("ZP4", .T.)
						ZP4->ZP4_FILIAL:= xFilial("ZP4")
						ZP4->ZP4_CODIGO:= cSol
						ZP4->ZP4_STATUS:= cStatus
						ZP4->ZP4_PRODUT:= cProdut
						ZP4->ZP4_DESC:= U_PS002MAN(cDesc)
						ZP4->ZP4_QUANT:= nQuant
						ZP4->ZP4_UM:= cUm
						ZP4->ZP4_SOLC:= cSc
						ZP4->ZP4_ITEMSC:= cItSc
						ZP4->ZP4_SOLA:= cSa
						ZP4->ZP4_ITEMSA:= cItSa
						ZP4->(MSUnLock())

						If !lNotSol
							If Empty(cSC) .AND. Empty(cSA)
								lNotSol:= .T.
							EndIf
						EndIf
					EndIf
				Next nX

				u_PS101MNT(cSol, "Solicitacao manutenida")
				//u_PS100MNT(cSol, "Solicitacao '"+cSol+"' manutenida", "A solicitacao '"+cSol+"' foi manutenida dia "+DtoC(Date())+" as "+Time()+", para maiores informacoes consultar o portal de solicitacoes pelo endereco http://10.0.0.239:93/u_ps001man.apw.")
				u_PS100MNT(cSol, "Solicitacao '"+cSol+" ("+Alltrim(ZP2->ZP2_STATUS)+")", ZP2->ZP2_HIST+"<br>"+"Data "+DtoC(Date())+" as "+Time(), "")

				cHtml:= "  $.ajax({"
				cHtml+= "          async: true,"
				cHtml+= "          method: 'POST',"
				cHtml+= "          url: 'u_ps101man.apw',"
				cHtml+= "          data: {'PS100MAN_GET_USER':'"+HTTPSESSION->cUSER+"','PS100MAN_GET_PASS':'"+HTTPSESSION->cPASS+"'}"
				cHtml+= "         }).done(function(data){eval(data);});"
				If lNotSol
					oAlert:= PSWebAlert():New("ps121man_alert", "Solicitacao "+cSol+": Existem itens que nao foram Reservados/Solicitados, por favor, utilize o botao Reservar/solicitar na aba materiais na proxima manutencao.", HTTPSESSION->cLogo)
					cHtml+= oAlert:show()
				EndIf

			End Transaction
		Else
			oAlert:= PSWebAlert():New("ps121man_alert", "Solicitacao "+cSol+", nao encontrada.", HTTPSESSION->cLogo)
			cHtml:= oAlert:show()
		EndIf
	Else
		oAlert:= PSWebAlert():New("ps121man_alert", "Um (ou mais) campo(s) obrigatorio(s) nao foi(foram) preenchido(s). Verifique a descricao dos campos com asterisco (*).", HTTPSESSION->cLogo)
		cHtml:= oAlert:show()
	EndIf


Return cHtml
