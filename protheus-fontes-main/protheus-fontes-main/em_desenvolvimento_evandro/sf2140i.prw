#INCLUDE "TOTVS.CH"

//--------------------------------------------------------------------------------------
/*/{Protheus.doc} SF1140I
@Type			: Ponto de Entrada
@Sample			: U_SF1140I()
@Description	: Ponto de Entrada que se encontra na Function Ma140Grava(), portanto 
                  será acionado após o salvamento da pré-nota.
@Param			: PARAMIXB[1]	Logico	Informa se está sendo realizada a inclusão do
                                        pré-documento de entrada.
				  PARAMIXB[2]	Logico	Informa se está sendo realizada a alteração do
				                        pré-documento de entrada.
@Return			: Nulo
@ --------------|-----------------------------------------------------------------------
@Author			: Evandro Mugnol
@Since			: Jan/2025
@version		: Protheus 12.1.2310 e posteriores
@Comments		: Responsável por atualizar as informações do cabeçalho de um
                  Pré-Documento de Entrada e seus anexos.
/*/
//--------------------------------------------------------------------------------------
User Function SF1140I()

	Local aArea    := FWGetArea()
	Local aAreaSF1 := SF1->( FWGetArea() )
	Local aAreaSD1 := SD1->( FWGetArea() )
	Local lInclui  := PARAMIXB[01]
	Local lAltera  := PARAMIXB[02]

	// Somente se for nota devolução grava campos de controle referente processos de devoluções
	If cTipo == "D"
		
		If lInclui .Or. lAltera
			DbSelectArea("SF1")
			RecLock("SF1", .F.)
			SF1->F1_NUMREC  := SD1->D1_NUMREC
			SF1->F1_STATUS  := "B"
			SF1->F1_STATCON := ""
			MsUnlock()


			// Atualiza nfiscal e série de devolução, bem como status na tabela ZH2
			DbSelectArea("ZH2")
			DbSetOrder(1)
			If DbSeek(FWxFilial("ZH2") + SF1->F1_NUMREC)
				DbSelectArea("ZH2")
				RecLock("ZH2", .F.)
				ZH2->ZH2_NFDEV  := SF1->F1_DOC
				ZH2->ZH2_SERDEV := SF1->F1_SERIE
			    ZH2->ZH2_VLRDEV := SF1->F1_VALBRUT
				ZH2->ZH2_STATUS := "2"
				MsUnlock()
			EndIf


			// Quando "Tipo Retorno" do recibo for refaturamento, grava registro de vinculo NFe
			_cTipoRet := GetAdvFVal("ZH2", "ZH2_TIPRET", FWxFilial("ZH2") + SF1->F1_NUMREC, 1, Space(TamSx3("ZH2_TIPRET")[1]), .T.)
			If _cTipoRet == "1" .Or. _cTipoRet == "2"

				_cCliOri := GetAdvFVal("SF2", "F2_CLIENTE", FWxFilial("SF2") + SD1->D1_NFORI + SD1->D1_SERIORI, 1, Space(TamSx3("F2_CLIENTE")[1]), .T.)
				_cLojOri := GetAdvFVal("SF2", "F2_LOJA"   , FWxFilial("SF2") + SD1->D1_NFORI + SD1->D1_SERIORI, 1, Space(TamSx3("F2_LOJA")[1])   , .T.)
				_cChvOri := GetAdvFVal("SF2", "F2_CHVNFE" , FWxFilial("SF2") + SD1->D1_NFORI + SD1->D1_SERIORI, 1, Space(TamSx3("F2_CHVNFE")[1]) , .T.)

				// Grava cabeçalho do vínculo de notas fiscais de devolução
				DbSelectArea("ZH3")
				DbSetOrder(1)
				If !DbSeek(FWxFilial("ZH3") + SD1->D1_NFORI + SD1->D1_SERIORI + _cCliOri + _cLojOri)
					DbSelectArea("ZH3")
					RecLock("ZH3", .T.)
					ZH3->ZH3_FILIAL := FWxFilial("ZH3")
					ZH3->ZH3_NUMREC := SF1->F1_NUMREC
					ZH3->ZH3_NFDEV  := SF1->F1_DOC
					ZH3->ZH3_SERDEV := SF1->F1_SERIE
					ZH3->ZH3_CLIDEV := SF1->F1_FORNECE
					ZH3->ZH3_LOJDEV := SF1->F1_LOJA
					ZH3->ZH3_CHVDEV := SF1->F1_CHVNFE
					ZH3->ZH3_NFORI  := SD1->D1_NFORI
					ZH3->ZH3_SERORI := SD1->D1_SERIORI
					ZH3->ZH3_CLIORI := _cCliOri
					ZH3->ZH3_LOJORI := _cLojOri
					ZH3->ZH3_CHVORI := _cChvOri
					ZH3->ZH3_TIPRET := _cTipoRet
					ZH3->ZH3_STATUS := "1"			// 1=Refaturamento Pendente;2=Refaturamento Parcialmente Realizado;3=Refaturamento Totalmente Realizado
					MsUnlock()


					// Grava itens do vínculo de pré notas fiscais de devolução referente dados da nota de devolução
					DbselectArea("SD1")
					DbSetOrder(1)
					DbSeek(FWxFilial("SD1") + SF1->F1_DOC + SF1->F1_SERIE + SF1->F1_FORNECE + SF1->F1_LOJA)
					Do While !Eof() .And. SD1->D1_FILIAL + SD1->D1_DOC + SD1->D1_SERIE + SD1->D1_FORNECE + SD1->D1_LOJA == FWxFilial("SD1") + SF1->F1_DOC + SF1->F1_SERIE + SF1->F1_FORNECE + SF1->F1_LOJA
						DbSelectArea("ZH4")
						RecLock("ZH4", .T.)
						ZH4->ZH4_FILIAL := FWxFilial("ZH4")
						ZH4->ZH4_NFDEV  := SD1->D1_DOC
						ZH4->ZH4_SERDEV := SD1->D1_SERIE
						ZH4->ZH4_CLIDEV := SD1->D1_FORNECE
						ZH4->ZH4_LOJDEV := SD1->D1_LOJA
						ZH4->ZH4_ITEDEV := SD1->D1_ITEMORI
						ZH4->ZH4_PRDDEV := SD1->D1_COD
						ZH4->ZH4_DESDEV := SD1->D1_DESCRI
						ZH4->ZH4_LOCDEV := SD1->D1_LOCAL
						ZH4->ZH4_UMDEV  := SD1->D1_UM
						ZH4->ZH4_2UMDEV := SD1->D1_SEGUM
						ZH4->ZH4_QTDDEV := SD1->D1_QUANT
						ZH4->ZH4_2QTDEV := SD1->D1_QTSEGUM
						ZH4->ZH4_VUNDEV := SD1->D1_VUNIT
						ZH4->ZH4_TOTDEV := SD1->D1_TOTAL
						ZH4->ZH4_EMIDEV := SD1->D1_EMISSAO
						MsUnlock()

						DbSelectArea("SD1")
						DbSkip()
					EndDo

				EndIf
			EndIf


			// Atualiza motivo e descrição da devolução informado no recibo de autorização de devolução
			DbSelectArea("SD1")
			DbSetOrder(1)
			If DbSeek(FWxfilial("SD1") + SF1->F1_DOC + SF1->F1_SERIE + SF1->F1_FORNECE + SF1->F1_LOJA)
				While !Eof() .And. SD1->D1_FILIAL + SD1->D1_DOC + SD1->D1_SERIE + SD1->D1_FORNECE + SD1->D1_LOJA == FWxfilial("SD1") + SF1->F1_DOC + SF1->F1_SERIE + SF1->F1_FORNECE + SF1->F1_LOJA
					_cMotDev := GetAdvFVal("ZH2", "ZH2_MOTDEV", FWxFilial("ZH2") + SD1->D1_NUMREC, 1, Space(TamSx3("ZH2_MOTDEV")[1]), .T.)
					_cDesDev := GetAdvFVal("ZH2", "ZH2_DESDEV", FWxFilial("ZH2") + SD1->D1_NUMREC, 1, Space(TamSx3("ZH2_DESDEV")[1]), .T.)

					DbSelectArea("SD1")
					RecLock("SD1", .F.)
					SD1->D1_XMOTDEV := _cMotDev
					SD1->D1_XDESDEV := _cDesDev
					MsUnlock()
					
					DbSelectArea("SD1")
					DbSkip()
				EndDo
			EndIf

		EndIf
	
	EndIf

	FWRestArea(aAreaSD1)
	FWRestArea(aAreaSF1)
	FWRestArea(aArea)

Return
