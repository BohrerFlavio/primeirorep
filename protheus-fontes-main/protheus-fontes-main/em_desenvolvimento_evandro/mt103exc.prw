#INCLUDE "TOTVS.CH"

//--------------------------------------------------------------------------------------
/*/{Protheus.doc} MT103EXC
@Type			: Ponto de Entrada
@Sample			: U_MT103EXC()
@Description	: Ponto de Entrada para validação da exclusão do documento de entrada
@Param			: Nenhum
@Return			: ExpL1(logico)
                  Se retornado (.F.) não permite excluir o documento
				  Se retornado (.T.) permite excluir o documento
@ --------------|-----------------------------------------------------------------------
@Author			: Evandro Mugnol
@Since			: Mar/2025
@version		: Protheus 12.1.2310 e posteriores
@Comments		: Valida a exclusão de uma pré nota --> ExpL1
/*/
//--------------------------------------------------------------------------------------
User Function MT103EXC()

	Local _lRet := .T.

	If SF1->F1_TIPO == "D"
		// Quando "Tipo Retorno" do recibo for refaturamento, deleta registros de vinculo NFe
		_cTipoRet := GetAdvFVal("ZH2", "ZH2_TIPRET", FWxFilial("ZH2") + SF1->F1_NUMREC, 1, Space(TamSx3("ZH2_TIPRET")[1]), .T.)
		If _cTipoRet == "1" .Or. _cTipoRet == "2"

			DbSelectArea("ZH3")
			DbSetOrder(3)
			If DbSeek(FWxFilial("ZH3") + SF1->F1_NUMREC)
				// Percorre ZH4 para deletar itens
				DbSelectArea("ZH4")
				DbGoTop()
				DbSetOrder(1)
				DbSeek(FWxFilial("ZH4") + ZH3->ZH3_NFDEV + ZH3->ZH3_SERDEV + ZH3->ZH3_CLIDEV + ZH3->ZH3_LOJDEV)
				While !Eof() .And. ZH4->ZH4_FILIAL + ZH4->ZH4_NFDEV + ZH4->ZH4_SERDEV + ZH4->ZH4_CLIDEV + ZH4->ZH4_LOJDEV == FWxFilial("ZH4") + ZH3->ZH3_NFDEV + ZH3->ZH3_SERDEV + ZH3->ZH3_CLIDEV + ZH3->ZH3_LOJDEV
					DbSelectArea("ZH4")
					RecLock("ZH4", .F.)	
					DbDelete()
					MsUnLock()
					DbSkip()
				EndDo

				DbSelectArea("ZH3")
				RecLock("ZH3", .F.)	
				DbDelete()
				MsUnLock()
			EndIf
		
		EndIf

		// Atualiza nfiscal e série de devolução, bem como status na tabela ZH2
		DbSelectArea("ZH2")
		DbSetOrder(1)
		If DbSeek(FWxFilial("ZH2") + SF1->F1_NUMREC)
			DbSelectArea("ZH2")
			RecLock("ZH2", .F.)
			ZH2->ZH2_NFDEV  := ""
			ZH2->ZH2_SERDEV := ""
			ZH2->ZH2_VLRDEV := 0
			ZH2->ZH2_STATUS := "1"
			MsUnlock()
		EndIf
	EndIf
	
Return _lRet
