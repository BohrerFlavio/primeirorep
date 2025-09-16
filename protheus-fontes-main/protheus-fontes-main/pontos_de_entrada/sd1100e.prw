#INCLUDE "PROTHEUS.CH"

User Function SD1100E()

	/*/{Protheus.doc} SD1100E
	Ponto de entrada antes de deletar o registro no SD1 na exclusão da Nota de Entrada
	@author 		Evandro Mugnol
	@since 		Dez/2017
	@return 		Nil, Função não tem retorno
	@obs 			N/A
	/*/

	Local _aArea := GetArea()   

	If cEmpAnt == "01"
		If !Empty(SF1->F1_NUMAM) .And. !Empty(SF1->F1_LOTE)

			// Efetua exclusão da comissão
			DbSelectArea("SE3")
			DbSetOrder(5)
			DbSeek(xFilial("SE3") + SD1->D1_PEDIDO + Space(03))
			While !Eof() .And. SE3->E3_FILIAL + SE3->E3_NUM == xFilial("SE3") + SD1->D1_PEDIDO + Space(03) 
				RecLock("SE3", .F.)	
				DbDelete()
				MsUnLock()
				DbSkip()
			Enddo

			// Efetua exclusão de pedido de compra
			DbSelectArea("SC7")
			DbSetOrder(1) //C7_FILIAL+C7_NUM+C7_ITEM+C7_SEQUEN
			If DbSeek(xFilial("SC7") + SD1->D1_PEDIDO + SD1->D1_ITEMPC)
				RecLock("SC7", .F.)	
				DbDelete()
				MsUnLock()
			Endif

			// Efetua abertura do fechamento da compra de gado (ZAG)
			DbSelectArea("ZAG")
			DbSetOrder(3)
			DbSeek(xFilial("ZAG") + SF1->F1_NUMAM)
			While !Eof() .And. ZAG->ZAG_FILIAL + ZAG->ZAG_NUMAM == xFilial("ZAG") + SF1->F1_NUMAM
				If ZAG->ZAG_FORNEC + ZAG->ZAG_LOJA == SF1->F1_FORNECE + SF1->F1_LOJA .And. ZAG->ZAG_STATUS == "E"
					DbSelectArea("ZAG")
					RecLock("ZAG",.F.)
					ZAG->ZAG_STATUS := "A"
					ZAG->ZAG_SLDP	:= ZAG->ZAG_PESO
					MsUnlock()
				Endif
				DbSelectArea("ZAG")
				DbSkip()
			Enddo

		Endif 	
	Endif

	// Correção da exclusão das tabelas do ativo na exclusão do documento de entrada
	SN1->(DbSetOrder(1))
	If SN1->(MsSeek(xFilial("SN1") + SD1->D1_CBASEAF))
		AF010DELATU("SN3")
	Endif

	RestArea(_aArea)

Return
