#INCLUDE "TOTVS.CH"
#INCLUDE "TOPCONN.CH"

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Programa  ³ M460FIM  ³ Autor ³ Evandro Mugnol        ³ Data ³ 28.07.04 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descricao ³ Ponto Entrada para alimentar percentual e valor de desconto³±±
±±³          ³ rapel nos titulos do contas a receber                      ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Uso       ³ Especifico para Frigorifico Silva                          ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
User Function M460FIM()

	Local aArea   := FWGetArea()
	Local aAreaF2 := SF2->(FWGetArea())
	Local aAreaD2 := SD2->(FWGetArea())

	// Bloco atualizado para tratar desconto rapel
	// Validação inserida por Fabian Maurer dia 28/10/14 para validar
	// por data o vencimento do campo Rapel Solicitado por Clailton
	If cEmpAnt == "01"	// Executa somente para a empresa 01
		If SA1->A1_VENRAP >= date()
			/*
			_cQuery1 := "UPDATE " + RetSqlName("SE1")
			_cQuery1 += "   SET E1_PRAPEL = " + Str(SA1->A1_PRAPEL,5,2) +" , "
			_cQuery1 += "       E1_VLRAPEL = E1_VALOR * " + str(SA1->A1_PRAPEL,5,2) + " / 100 "
			_cQuery1 += " WHERE D_E_L_E_T_ <> '*'"
			_cQuery1 += "   AND E1_NUM = '" + SF2->F2_DOC + "' "
			_cQuery1 += "   AND E1_PREFIXO = '" + &(GetMv("MV_1DUPREF")) + "' "
			_cQuery1 += "   AND E1_FILIAL = '" + xFilial("SE1") + "' "
			TcSqlExec(_cQuery1)
			*/

			If SF2->F2_CLIENTE == "000173" .Or. SF2->F2_CLIENTE == "000174" .Or. SF2->F2_CLIENTE == "001110" .Or. SF2->F2_CLIENTE == "010343" .Or. SF2->F2_CLIENTE == "020031"
				// Query para criar os títulos de rapel
				_cQuery2 := "SELECT * "
				_cQuery2 += "  FROM " + RetSQLTab("SE1")
				_cQuery2 += " WHERE " + RetSQLFil("SE1")
				_cQuery2 += "   AND E1_NUM = '" + SF2->F2_DOC + "' "
				_cQuery2 += "   AND E1_PREFIXO = '" + &(GetMv("MV_1DUPREF")) + "' "
				_cQuery2 += "   AND " + RetSQLDel("SE1")

				_cQuery2 := ChangeQuery(_cQuery2)

				DbUseArea( .T., "TOPCONN", TCGENQRY(,,_cQuery2), "TRB", .F., .T.)

				TRB->(dbGoTop())
				While TRB->(!Eof())

					//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
					//³ Gera novo título de rapel no SE1                             ³
					//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
					aVetSE1 := {}

					aAdd(aVetSE1, {"E1_FILIAL"	, TRB->E1_FILIAL				, Nil})
					aAdd(aVetSE1, {"E1_PREFIXO"	, "R"							, Nil})
					aAdd(aVetSE1, {"E1_NUM"		, TRB->E1_NUM					, Nil})
					aAdd(aVetSE1, {"E1_PARCELA"	, TRB->E1_PARCELA				, Nil})
					aAdd(aVetSE1, {"E1_TIPO"	, "RAP"							, Nil})
					aAdd(aVetSE1, {"E1_NATUREZ"	, "110107"						, Nil})
					aAdd(aVetSE1, {"E1_PORTADO"	, "RAP"							, Nil})
					aAdd(aVetSE1, {"E1_AGEDEP"	, "001  "						, Nil})
					aAdd(aVetSE1, {"E1_CLIENTE"	, TRB->E1_CLIENTE				, Nil})
					aAdd(aVetSE1, {"E1_LOJA"	, TRB->E1_LOJA					, Nil})
					aAdd(aVetSE1, {"E1_NOMCLI"	, TRB->E1_NOMCLI				, Nil})
					aAdd(aVetSE1, {"E1_EMISSAO"	, Stod(TRB->E1_EMISSAO)			, Nil})
					aAdd(aVetSE1, {"E1_VENCTO"	, Stod(TRB->E1_VENCTO)			, Nil})
					aAdd(aVetSE1, {"E1_VENCREA"	, Stod(TRB->E1_VENCREA)			, Nil})
					aAdd(aVetSE1, {"E1_VALOR"	, TRB->E1_VLRAPEL				, Nil})
					aAdd(aVetSE1, {"E1_VEND1"	, TRB->E1_VEND1					, Nil})
					aAdd(aVetSE1, {"E1_CONTA"	, "00001     "					, Nil})
					aAdd(aVetSE1, {"E1_MOEDA"	, TRB->E1_MOEDA					, Nil})
					aAdd(aVetSE1, {"E1_PEDIDO"	, TRB->E1_PEDIDO				, Nil})
					aAdd(aVetSE1, {"E1_SERIE"	, TRB->E1_SERIE					, Nil})
					aAdd(aVetSE1, {"E1_ORIGEM"	, "LOJA010"						, Nil})
					aAdd(aVetSE1, {"E1_FRMREC"	, TRB->E1_FRMREC				, Nil})
					aAdd(aVetSE1, {"E1_SDOC"	, TRB->E1_SDOC					, Nil})

					// Chama a rotina automática
					lMsErroAuto := .F.

					MSExecAuto({|x,y| FINA040(x,y)}, aVetSE1, 3)

					// Se houve erro, mostra o erro ao usuário e desarma a transação
					If lMsErroAuto
						MostraErro()
						DisarmTransaction()
					EndIf

					TRB->(DbSkip())
				Enddo
				TRB->(DbCloseArea())
			EndIf
		Endif

		// ------- INÍCIO bloco de código para tratamentos dos PROCESSOS DE DEVOLUÇÕES
		// Grava itens do vínculo de notas fiscais de devolução referente dados da nota de venda (REFATURAMENTO)
		DbSelectArea("SD2")
		DbSetOrder(3)
		DbSeek(FWxFilial("SD2") + SF2->F2_DOC + SF2->F2_SERIE + SF2->F2_CLIENTE + SF2->F2_LOJA)
		While !Eof() .And. SD2->D2_FILIAL + SD2->D2_DOC + SD2->D2_SERIE + SD2->D2_CLIENTE + SD2->D2_LOJA == FWxFilial("SD2") + SF2->F2_DOC + SF2->F2_SERIE + SF2->F2_CLIENTE + SF2->F2_LOJA
			_cNotaOrig := SD2->D2_NFORI
			_cSeriOrig := SD2->D2_SERIORI
			If !Empty(SF2->F2_CLIRET) .And. !Empty(SF2->F2_LOJARET)
				_cClieOrig := SF2->F2_CLIRET
				_cLojaOrig := SF2->F2_LOJARET
			Else
				_cClieOrig := GetAdvFVal("SF1", "F1_FORNECE", FWxFilial("SF1") + SD2->D2_NFORI + SD2->D2_SERIORI, 1, Space(TamSx3("F1_FORNECE")[1]), .T.)
				_cLojaOrig := GetAdvFVal("SF1", "F1_LOJA"   , FWxFilial("SF1") + SD2->D2_NFORI + SD2->D2_SERIORI, 1, Space(TamSx3("F1_LOJA")[1])   , .T.)
			EndIf

			If !Empty(SD2->D2_NFORI)
				DbSelectArea("ZH4")
				DbSetOrder(1)
				If DbSeek(FWxFilial("ZH4") + _cNotaOrig + _cSeriOrig + _cClieOrig + _cLojaOrig + SD2->D2_COD + SD2->D2_ITEM)
					RecLock("ZH4", .F.)
					ZH4->ZH4_NFVDA  := SD2->D2_DOC
					ZH4->ZH4_SERVDA := SD2->D2_SERIE
					ZH4->ZH4_CLIVDA := SD2->D2_CLIENTE
					ZH4->ZH4_LOJVDA := SD2->D2_LOJA
					ZH4->ZH4_ITEVDA := SD2->D2_ITEM
					ZH4->ZH4_PRDVDA := SD2->D2_COD
					ZH4->ZH4_DESVDA := SD2->D2_DESCRI
					ZH4->ZH4_LOCVDA := SD2->D2_LOCAL
					ZH4->ZH4_UMVDA  := SD2->D2_UM
					ZH4->ZH4_2UMVDA := SD2->D2_SEGUM
					ZH4->ZH4_QTDVDA := SD2->D2_QUANT
					ZH4->ZH4_2QTVDA := SD2->D2_QTSEGUM
					ZH4->ZH4_VUNVDA := SD2->D2_PRCVEN
					ZH4->ZH4_TOTVDA := SD2->D2_TOTAL
					ZH4->ZH4_EMIVDA := SD2->D2_EMISSAO
					MsUnlock()
				EndIf
			EndIf

			DbSelectArea("SD2")
			DbSkip()
		EndDo

		// Varre tabela ZH4 (itens do vínculo de notas fiscais de devolução) para atualizar Status do recibo ref. Autorização de Devolução
		_lEncRecib := .F.
		DbSelectArea("ZH4")
		DbGoTop()
		DbSetOrder(1)
		DbSeek(FWxFilial("ZH4") + _cNotaOrig + _cSeriOrig + _cClieOrig + _cLojaOrig)
		While !Eof() .And. ZH4->ZH4_FILIAL + ZH4->ZH4_NFDEV + ZH4->ZH4_SERDEV + ZH4->ZH4_CLIDEV + ZH4->ZH4_LOJDEV == FWxFilial("ZH4") + _cNotaOrig + _cSeriOrig + _cClieOrig + _cLojaOrig
			If !Empty(ZH4->ZH4_NFDEV) .And. !Empty(ZH4->ZH4_NFVDA)
				_lEncRecib := .T.
			Else
				_lEncRecib := .F.
				Exit
			EndIf
			DbSelectArea("ZH4")
			DbSkip()
		EndDo

		// Procura número do recibo e encerra o mesmo mudando o status na tabela ZH2 
		_cNumRecib := GetAdvFVal("ZH3", "ZH3_NUMREC", FWxFilial("ZH3") + _cNotaOrig + _cSeriOrig + _cClieOrig + _cLojaOrig, 1, Space(TamSx3("ZH3_NUMREC")[1]), .T.)
		If _lEncRecib
			// Atualiza status na tabela ZH2
			DbSelectArea("ZH2")
			DbSetOrder(1)
			If DbSeek(FWxFilial("ZH2") + _cNumRecib)
				DbSelectArea("ZH2")
				RecLock("ZH2", .F.)
				ZH2->ZH2_STATUS := "5"		// DEFINIR
				MsUnlock()
			EndIf

			// Atualiza status na tabela ZH3
			DbSelectArea("ZH3")
			DbSetOrder(3)
			If DbSeek(FWxFilial("ZH3") + _cNumRecib)
				DbSelectArea("ZH3")
				RecLock("ZH3", .F.)
				ZH3->ZH3_STATUS := "3"		// 1=Refaturamento Pendente;2=Refaturamento Parcialmente Realizado;3=Refaturamento Totalmente Realizado
				MsUnlock()
			EndIf
		Else
			// Atualiza status na tabela ZH3
			DbSelectArea("ZH3")
			DbSetOrder(3)
			If DbSeek(FWxFilial("ZH3") + _cNumRecib)
				DbSelectArea("ZH3")
				RecLock("ZH3", .F.)
				ZH3->ZH3_STATUS := "2"		// 1=Refaturamento Pendente;2=Refaturamento Parcialmente Realizado;3=Refaturamento Totalmente Realizado
				MsUnlock()
			EndIf
		EndIf
		// ------- FINAL bloco de código para tratamentos dos PROCESSOS DE DEVOLUÇÕES

	Endif

	FWRestArea(aArea)
	FWRestArea(aAreaD2)
	FWRestArea(aAreaF2)

Return
