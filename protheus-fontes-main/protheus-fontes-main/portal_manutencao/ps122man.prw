#INCLUDE 'TBICONN.CH'

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³PS122MAN  ºAutor  ³Ezequiel Pianegonda º Data ³  10/07/2017 º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³Gera solicitacao de compra ou solicitacao de armazem        º±±
±±º          ³dos itens requisitados pela OS                              º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ AP                                                        º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/

User Function PS122MAN()
	Local cHtml:= ""
	Local cSol:= HTTPPOST->PS120MAN_GET_SOLICITACAO
	Local cTabela:= HTTPPOST->TABELA
	Local cCC:= HTTPPOST->PS120MAN_GET_CC
	Local _cDescServ := HTTPPOST->PS120MAN_GET_DESC
	Local _cDmaquina := HTTPPOST->PS120MAN_GET_DMAQUINA
	Local nX:= 0
	Local nY:= 0
	Local aTabela:= {}
	Local aLinha:= {}
	Local aCampos:= {}
	Local nSaldo:= 0
	Local cStatus:= ""
	Local cProdut:= ""
	Local cDesc:= ""
	Local nQuant:= 0
	Local cUm:= ""
	Local cSC:= ""
	Local cItSC:= ""
	Local cSA:= ""
	Local cItSA:= ""
	Local lItSA:= .F.
	Local lItSC:= .F.
	Local oAlert:= Nil
	Local aItensSC:= {}
	Local aItensSA:= {}
	Local cItem:= "0000"
	Local cErro:= ""
	Local cUser:= ""

	Private _cSA:= ""

	If ValType(HTTPSESSION->cEMP) == "U" .OR. ValType(HTTPSESSION->cFil) == "U" .OR. ValType(HTTPSESSION->cCC) == "U"
		cHtml:= "  $.ajax({"
		cHtml+= "          async: true,"
		cHtml+= "          method: 'POST',"
		cHtml+= "          url: 'u_ps001man.apw',"
		cHtml+= "         }).done(function(data){eval(data);});"
		Return cHtml
	EndIf

	RESET ENVIRONMENT
	//RPCSetType(3)
	PREPARE ENVIRONMENT EMPRESA HTTPSESSION->cEmp FILIAL HTTPSESSION->cFil USER HTTPSESSION->cUser PASSWORD HTTPSESSION->cPass

	ZP2->(dbSetOrder(1))
	If ZP2->(DbSeek(xFilial("ZP2")+cSol))
		Begin Transaction

			ZP4->(dbSetOrder(1))
			ZP4->(dbSeek(xFilial("ZP4")+cSol))
			Do While !ZP4->(EOF()) .AND. xFilial("ZP4")+cSol == ZP4->ZP4_FILIAL+ZP4->ZP4_CODIGO
				If Empty(ZP4->ZP4_SOLC) .AND. Empty(ZP4->ZP4_SOLA)
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
				cSC:= ""
				cItSC:= ""
				cSA:= ""
				cItSA:= ""
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
							cSC:= aCampos[3]
							Case nY == 7
							cItSC:= aCampos[3]
							Case nY == 8
							cSA:= aCampos[3]
							Case nY == 9
							cItSA:= aCampos[3]
						End Case
					EndIf
				Next nY
				lItSA:= .F.
				lItSC:= .F.
				If Empty(cSC) .AND. Empty(cSA)
					SB1->(dbSetOrder(1))
					If SB1->(dbSeek(xFilial("SB1")+cProdut))
						SB2->(dbSetOrder(1))
						If SB2->(dbSeek(xFilial("SB2")+SB1->B1_COD+SB1->B1_LOCPAD))
							nSaldo:= SaldoSB2()
							If nSaldo >= nQuant					
								AADD(aItensSA, {cProdut, nQuant, cCC})
								lItSA:= .T.
							ElseIf nSaldo <= 0
								AADD(aItensSC, {cProdut, nQuant, cCC,_cDescServ,_cDmaquina})
								lItSC:= .T.
							Else
								AADD(aItensSA, {cProdut, nSaldo, cCC})
								AADD(aItensSC, {cProdut, nQuant-nSaldo, cCC,_cDescServ,_cDmaquina})
								lItSA:= .T.
								lItSC:= .T.
							EndIf
						Else
							CriaSB2(SB1->B1_COD,SB1->B1_LOCPAD)
							//cErro:= "O produto "+Alltrim(SB1->B1_COD)+" nao possui o armazem '"+SB1->B1_LOCPAD+"' criado na SB2, verifique."
						EndIf
					EndIf

					RecLock("ZP4", .T.)
					ZP4->ZP4_FILIAL	:= xFilial("ZP4")
					ZP4->ZP4_CODIGO	:= cSol
					ZP4->ZP4_STATUS	:= cStatus
					ZP4->ZP4_PRODUT	:= cProdut
					ZP4->ZP4_DESC  	:= U_PS002MAN(cDesc)
					ZP4->ZP4_QUANT	:= nQuant
					ZP4->ZP4_UM:= cUm
				EndIf

				If lItSC
					ZP4->ZP4_ITEMSC:= PADL(cValToChar(Len(aItensSC)), 4, "0")
				EndIf
				If lItSA
					ZP4->ZP4_ITEMSA:= PADL(cValToChar(Len(aItensSA)), 2, "0")
				EndIf
				ZP4->(MSUnLock())

			Next nX

			If !Empty(cErro)
				oAlert:= PSWebAlert():New("ps122man_alert", cErro, HTTPSESSION->cLogo)
				cHtml:= oAlert:show()
			ElseIf Len(aItensSC) + Len(aItensSA) == 0
				oAlert:= PSWebAlert():New("ps122man_alert", "Nao existem itens a serem reservados/solicitados.", HTTPSESSION->cLogo)
				cHtml:= oAlert:show()
			Else
				cErro:= ""
				If Len(aItensSC) > 0
					cErro:= GeraSC(cSol, aItensSC)
					If Empty(cErro)
						ZP4->(dbSetOrder(1))
						ZP4->(dbSeek(xFilial("ZP4")+cSol))
						Do While !ZP4->(EOF()) .AND. xFilial("ZP4")+cSol == ZP4->ZP4_FILIAL+ZP4->ZP4_CODIGO
							If Empty(ZP4->ZP4_SOLC)
								If !Empty(ZP4->ZP4_ITEMSC)
									RecLock("ZP4", .F.)
									ZP4->ZP4_SOLC:= SC1->C1_NUM
									ZP4->ZP4_DTSC:= Date()
									ZP4_STATUS:= "2 - Solicitado"
									ZP4->(MsUnLock())
								EndIf
							EndIf
							ZP4->(dbSkip())
						EndDo
					EndIf
				EndIf

				If Empty(cErro)
					If Len(aItensSA) > 0
						cErro:= GeraSA(cSol, aItensSA)
						If Empty(cErro)
							ZP4->(dbSetOrder(1))
							ZP4->(dbSeek(xFilial("ZP4")+cSol))
							Do While !ZP4->(EOF()) .AND. xFilial("ZP4")+cSol == ZP4->ZP4_FILIAL+ZP4->ZP4_CODIGO
								If Empty(ZP4->ZP4_SOLA)
									If !Empty(ZP4->ZP4_ITEMSA)
										RecLock("ZP4", .F.)
										ZP4->ZP4_SOLA:= _cSA//SCP->CP_NUM
										ZP4->ZP4_DTSA:= Date()
										ZP4_STATUS:= "3 - Disponivel"
										ZP4->(MsUnLock())
									EndIf
								EndIf
								ZP4->(dbSkip())
							EndDo
						EndIf
					EndIf
				EndIf

				If Empty(cErro)

					u_PS101MNT(cSol, "Solicitacao manutenida, novos itens foram solicitados")
					//u_PS100MNT(cSol, "Solicitacao '"+cSol+"' manutenida", "Novos itens foram solicitados dia  "+DtoC(Date())+" as "+Time()+" a mautencao '"+cSol+"', para maiores informacoes consultar o portal de solicitacoes pelo endereco http://10.0.0.239:93/u_ps001man.apw.")
					u_PS100MNT(cSol, "Solicitacao '"+cSol+" ("+Alltrim(ZP2->ZP2_STATUS)+")", ZP2->ZP2_HIST+"<br>"+"Data "+DtoC(Date())+" as "+Time(), "")

					cHtml:= "  $.ajax({"
					cHtml+= "          async: true,"
					cHtml+= "          method: 'POST',"
					cHtml+= "          url: 'u_ps101man.apw',"
					cHtml+= "          data: {'PS100MAN_GET_USER':'"+HTTPSESSION->cUSER+"','PS100MAN_GET_PASS':'"+HTTPSESSION->cPASS+"'}"
					cHtml+= "         }).done(function(data){eval(data);});"
				Else
					oAlert:= PSWebAlert():New("ps122man_alert", cErro, HTTPSESSION->cLogo)
					cHtml:= oAlert:show()
				EndIf
			EndIf

		End Transaction
	Else
		oAlert:= PSWebAlert():New("ps122man_alert", "Solicitacao "+cSol+", nao encontrada.", HTTPSESSION->cLogo)
		cHtml:= oAlert:show()
	EndIf


Return cHtml

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³GERASC    ºAutor  ³Ezequiel Pianegonda º Data ³  09/08/2017 º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³Gera a solicitacao de compra                                º±±
±±º          ³                                                            º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ AP                                                        º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/

Static Function GeraSC(cSol, aItensSC)
	Local cRet:= ""
	Local nX:= 0
	Local aCab:= {}
	Local aIten:= {}
	Local cItem:= "0000"
	Local aItens:= {}
	Local aErro:= {}
	Local cErro:= ""

	AADD(aCab, {"C1_FILIAL", xFilial("SC1")			,NIL})
	AADD(aCab, {"C1_SOLICIT", HTTPSESSION->cUser		,NIL})
	AADD(aCab, {"C1_EMISSAO", Date()						,NIL})

	For nX:= 1 To Len(aItensSC)

		aIten:= {}
		cItem:= Soma1(cItem)
		AADD(aIten, {"C1_ITEM", cItem, Nil})
		AADD(aIten, {"C1_PRODUTO", aItensSC[nX, 1], NIL})
		AADD(aIten, {"C1_QUANT", aItensSC[nX, 2], Nil})
		AADD(aIten, {"C1_DATPRF", date(), Nil})
		AADD(aIten, {"C1_OBS", "Sol. manut. num. "+cSol, Nil})
		AADD(aIten, {"C1_CC", aItensSC[nX, 3], Nil})
		AADD(aIten, {"C1_TPSERV", aItensSC[nX, 4], Nil})
		AADD(aIten, {"C1_CCMAQ", aItensSC[nX, 3], Nil})
		AADD(aIten, {"C1_NOMEMAQ", aItensSC[nX, 5], Nil})

		AADD(aItens, aIten)
	Next nX

	If Len(aItens) > 0
		lMsHelpAuto   := .T.
		lMsErroAuto   := .F.
		lAutoErrNoFile:= .T. 
		MSExecAuto({|x, y, z| MATA110(x, y, z)}, aCab, aItens, 3) //Inclusao
		If lMsErroAuto
			DisarmTransaction()
			aErro:= GetAutoGrLog()
			cErro:= ""
			For nX:= 1 To Len(aErro)
				cErro+= StrTran(StrTran(aErro[nX], Chr(13), "<br>"), Chr(10), "")+"<br>"
			Next nX
			//oAlert:= PSWebAlert():New("ps122man_alert", cErro, HTTPSESSION->cLogo)
			//cRet:= oAlert:show()
			cRet:= cErro
		EndIf
	EndIf

Return cRet

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³GeraSA    ºAutor  ³Ezequiel Pianegonda º Data ³  09/08/2017 º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³Gera solicitacao ao armazem para reservar a quantidade      º±±
±±º          ³                                                            º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ AP                                                        º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/

Static Function GeraSA(cSol, aItensSA)
	Local cRet:= ""
	Local cItem:= '00'
	Local aCabec:= {}
	Local aIten:= {}
	Local aItens:= {}    
	Local bBloco:= {|| .T.}
	Local aRecSCP:= {}
	Local nAglutSC:= 0
	Local lRateio:= .F.
	Local aErro:= {}
	Local cErro:= ""
	Local nX:= 0
	Local aArea:= GetArea()
	Local aZP2:= ZP2->(GetArea())

	aCabec:= {}
	AADD(aCabec, {"CP_FILIAL", xFilial("SCP")				, NIL})
	AADD(aCabec, {"CP_SOLICIT", HTTPSESSION->cUser		, NIL})
	AADD(aCabec, {"CP_EMISSAO", Date()						, Nil})

	For nX:=1 To Len(aItensSA)
		aIten:= {}
		cItem:= Soma1(cItem)
		AADD(aIten, {"CP_ITEM", cItem													, Nil})
		AADD(aIten, {"CP_PRODUTO", aItensSA[nX, 1]								, NIL})
		AADD(aIten, {"CP_QUANT", aItensSA[nX, 2]									, Nil})
		AADD(aIten, {"CP_FUNC", "1"													, NIL})
		AADD(aIten, {"CP_CC", aItensSA[nX, 3]										, Nil})
		AADD(aIten, {"CP_OBS", "Sol. manut. num. "+cSol	, Nil})

		AADD(aItens, aIten)
	Next nX

	lMsHelpAuto   := .T.
	lMsErroAuto   := .F.
	lAutoErrNoFile:= .T.
	MSExecAuto({|x,y,z| MATA105(x, y, z)}, aCabec, aItens, 3)   
	If !lMsErroAuto
		SCP->(dbGoBottom())
		//memowrite("ps122man_sa.txt","MATA105 - OK="+SCP->CP_NUM)
		_cSA:= SCP->CP_NUM
		Pergunte("MTA106",.F.)
		//If A106VldRat(@nAglutSC,@lRateio)
		MV_PAR01:= 1
		MV_PAR02:= 2
		MV_PAR03:= 1
		MV_PAR04:= 1
		MV_PAR05:= Space(2)
		MV_PAR06:= "ZZ"
		MV_PAR07:= 1
		MV_PAR08:= 1
		MV_PAR09:= 1
		MV_PAR10:= 1
		MaSaPreReq(.F.,MV_PAR01==1, bBloco,MV_PAR02==1,MV_PAR03==1,MV_PAR04==1,MV_PAR05,MV_PAR06,MV_PAR07==1,MV_PAR08==1,nAglutSC)
		//MaSaPreReq(.F.,MV_PAR01==1, bBloco,MV_PAR02==1,MV_PAR03==1,MV_PAR04==1,MV_PAR05,MV_PAR06,MV_PAR07==1,MV_PAR08==1,nAglutSC,,MV_PAR10==1,@aRecSCP,lRateio)
		//EndIf


		ZP2->(dbSetOrder(1))
		If ZP2->(DbSeek(xFilial("ZP2")+cSol))
			u_PS100MNT(cSol, "Solicitacao '"+cSol+" ("+"Material disponível"+")", ZP2->ZP2_HIST+"<br>"+"Data "+DtoC(Date())+" as "+Time(), "almoxarifado@frigorificosilva.com.br")
		EndIf

	Else
		_cSA:= ""
		DisarmTransaction()
		aErro:= GetAutoGrLog()
		cErro:= ""
		For nX:= 1 To Len(aErro)
			cErro+= StrTran(StrTran(aErro[nX], Chr(13), "<br>"), Chr(10), "")+"<br>"
		Next nX
		//oAlert:= PSWebAlert():New("ps122man_alert", cErro, HTTPSESSION->cLogo)
		//cRet:= oAlert:show()
		cRet:= cErro
	EndIf

	RestArea(aZP2)
	RestArea(aArea)
Return cRet
