#INCLUDE "TOTVS.CH"
#INCLUDE "TOPCONN.CH"

//--------------------------------------------------------------------------------------
/*/{Protheus.doc} MSD2520
@Type			   : Função de Usuário
@Sample			: U_MSD2520()
@Description	: Ponto Entrada executado antes da exclusão dos itens da nota saida
@Param			: Nulo
@Return			: Nulo
@ --------------|-----------------------------------------------------------------------
@Author			: Evandro Mugnol
@Since			: Mar/2023
@version		   : Protheus 12.1.33 e posteriores
@Comments		: N/A
/*/
//--------------------------------------------------------------------------------------
User Function MSD2520()

	Local _aArea    := GetArea()
	Local _aAreaSD2 := SD2->(GetArea())

	// Grava histórico de CANCELAMENTO de faturamento na tabela SZU
	If AllTrim(SD2->D2_SEGUM) == "CX" .and. !empty(SD2->D2_PREPED)
		DbSelectArea("SZ8")
		DbSetOrder(26)
		MsSeek(FWxFilial("SZ8") + SD2->D2_FILIAL + SD2->D2_PREPED + Left(SD2->D2_COD,14))
		While !Eof() .And. SZ8->Z8_FILIAL + SZ8->Z8_FIL + SZ8->Z8_PREPED + SZ8->Z8_COD == FWxFilial("SZ8") + SD2->D2_FILIAL + SD2->D2_PREPED + Left(SD2->D2_COD,14)

			DbSelectArea("SZV")
			RecLock("SZV",.T.)
			SZV->ZV_FILIAL  := FWxFilial("SZV")
			SZV->ZV_ID      := GetSx8Num("SZV","ZV_ID")
			ConfirmSx8()
			SZV->ZV_CONTROL := SZ8->Z8_CONTROL
			SZV->ZV_DATA    := date()//SD2->D2_EMISSAO
			SZV->ZV_HORA    := Time()
			SZV->ZV_DESC    := "CANC. FATURAMENTO NF. NUM.: " + SD2->D2_DOC + " SERIE: " + SD2->D2_SERIE
			SZV->ZV_USAR    := cUserName
			SZV->ZV_EST     := GetComputerName()
			SZV->ZV_TIPO    := "M"
			SZV->ZV_CODMSG  := "000035"
			MsUnLock()

			DbSelectArea("SZ8")
			DbSkip()
		EndDo
	EndIf


	// ------- INÍCIO bloco de código para tratamentos dos PROCESSOS DE DEVOLUÇÕES
	// Limpa itens do vínculo de notas fiscais de devolução referente dados da nota de venda cancelada (REFATURAMENTO)
	_cNotaVda := SD2->D2_DOC
	_cSeriVda := SD2->D2_SERIE
	_cClieVda := SD2->D2_CLIENTE
	_cLojaVda := SD2->D2_LOJA
	_cProdVda := SD2->D2_COD
	_cItemVda := SD2->D2_ITEM

	DbSelectArea("ZH4")
	DbSetOrder(2)
	If DbSeek(FWxFilial("ZH4") + _cNotaVda + _cSeriVda + _cClieVda + _cLojaVda + _cProdVda + _cItemVda)
		RecLock("ZH4", .F.)
		ZH4->ZH4_NFVDA  := ""
		ZH4->ZH4_SERVDA := ""
		ZH4->ZH4_CLIVDA := ""
		ZH4->ZH4_LOJVDA := ""
		ZH4->ZH4_ITEVDA := ""
		ZH4->ZH4_PRDVDA := ""
		ZH4->ZH4_DESVDA := ""
		ZH4->ZH4_LOCVDA := ""
		ZH4->ZH4_UMVDA  := ""
		ZH4->ZH4_2UMVDA := ""
		ZH4->ZH4_QTDVDA := 0
		ZH4->ZH4_2QTVDA := 0
		ZH4->ZH4_VUNVDA := 0
		ZH4->ZH4_TOTVDA := 0
		ZH4->ZH4_EMIVDA := Ctod("")
		MsUnlock()
	EndIf

	// Varre tabela ZH4 (itens do vínculo de notas fiscais de devolução) para atualizar Status do recibo ref. Autorização de Devolução
	_lEncRecib := .F.
	_cNotaDev  := SD2->D2_NFORI
	_cSeriDev  := SD2->D2_SERIORI
	If !Empty(SF2->F2_CLIRET) .And. !Empty(SF2->F2_LOJARET)
		_cClieDev := SF2->F2_CLIRET
		_cLojaDev := SF2->F2_LOJARET
	Else
		_cClieDev := GetAdvFVal("SF1", "F1_FORNECE", FWxFilial("SF1") + SD2->D2_NFORI + SD2->D2_SERIORI, 1, Space(TamSx3("F1_FORNECE")[1]), .T.)
		_cLojaDev := GetAdvFVal("SF1", "F1_LOJA"   , FWxFilial("SF1") + SD2->D2_NFORI + SD2->D2_SERIORI, 1, Space(TamSx3("F1_LOJA")[1])   , .T.)
	EndIf

	DbSelectArea("ZH4")
	DbGoTop()
	DbSetOrder(1)
	DbSeek(FWxFilial("ZH4") + _cNotaDev + _cSeriDev + _cClieDev + _cLojaDev)
	While !Eof() .And. ZH4->ZH4_FILIAL + ZH4->ZH4_NFDEV + ZH4->ZH4_SERDEV + ZH4->ZH4_CLIDEV + ZH4->ZH4_LOJDEV == FWxFilial("ZH4") + _cNotaDev + _cSeriDev + _cClieDev + _cLojaDev
		If !Empty(ZH4->ZH4_NFDEV) .And. !Empty(ZH4->ZH4_NFVDA)
			_lEncRecib := .F.
			Exit
		Else
			_lEncRecib := .T.
		EndIf
		DbSelectArea("ZH4")
		DbSkip()
	EndDo

	// Procura número do recibo e encerra o mesmo mudando o status na tabela ZH2 
	_cNumRecib := GetAdvFVal("ZH3", "ZH3_NUMREC", FWxFilial("ZH3") + _cNotaDev + _cSeriDev + _cClieDev + _cLojaDev, 1, Space(TamSx3("ZH3_NUMREC")[1]), .T.)
	If _lEncRecib
		// Atualiza status na tabela ZH2
		DbSelectArea("ZH2")
		DbSetOrder(1)
		If DbSeek(FWxFilial("ZH2") + _cNumRecib)
			DbSelectArea("ZH2")
			RecLock("ZH2", .F.)
			ZH2->ZH2_STATUS := "4"
			MsUnlock()
		EndIf

		// Atualiza status na tabela ZH3
		DbSelectArea("ZH3")
		DbSetOrder(3)
		If DbSeek(FWxFilial("ZH3") + _cNumRecib)
			DbSelectArea("ZH3")
			RecLock("ZH3", .F.)
			ZH3->ZH3_STATUS := "1"		// 1=Refaturamento Pendente;2=Refaturamento Parcialmente Realizado;3=Refaturamento Totalmente Realizado
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

	RestArea(_aAreaSD2)
	RestArea(_aArea)

Return(.T.)
