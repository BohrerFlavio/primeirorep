#INCLUDE "TOTVS.CH"
#INCLUDE "APWEBSRV.CH"
#INCLUDE "TOPCONN.CH"

//-------------------------------------------------------------------
/*/{Protheus.doc} CHECKOUT
Ponto de Entrada que tem a finalidade de permitir a execução de procedimentos antes que o estorno do documento de saída seja finalizado.
@author 	Evandro Mugnol
@since 		Nov/2020
@return 	Nil, Função não tem retorno
@obs 		N/A
/*/
//-------------------------------------------------------------------

User Function SF2520E()

	Local _aArea  := GetArea()  
	Local _cDocto := SF2->F2_DOC
	Local _cSerie := SF2->F2_SERIE
	Local _cClien := SF2->F2_CLIENTE
	Local _cLoja  := SF2->F2_LOJA
	Local _nVBrut := SF2->F2_VALBRUT
	Local _cChkID := SF2->F2_CHKID
	Local _cInteg := SF2->F2_CODINT
	Local _cStatR := SF2->F2_STATRET
	Local _cFormR := SF2->F2_FRMREC  

	If SF2->F2_TIPO $ "D/B"
		Return
	Else
		// Somente Executa para Empresa Frigorífico Silva
		If cEmpAnt == "01"
			// Somente chama método de cancelamento se forma de recebimento igual a 5 (cartão de crédito)
			// e se status do retorno referente ao envio for igual a PAID 
			If _cFormR == "5" .And. AllTrim(_cStatR) == "PAID" 
				_cCliID := GetAdvFVal("SA1", "A1_CGC", xFilial("SA1") + SF2->F2_CLIENTE + SF2->F2_LOJA, 1)
	
				U_CANCEL(_cDocto, _cSerie, _cClien, _cLoja, _nVBrut, _cChkID, _cInteg, _cCliID)		// Chama Método Cancel
			Endif

			// Efetua exclusão dos títulos de rapel gerados no cálculo da nota fiscal
 			If SF2->F2_CLIENTE == "000173" .Or. SF2->F2_CLIENTE == "000174" .Or. SF2->F2_CLIENTE == "001110" .Or. SF2->F2_CLIENTE == "010343" .Or. SF2->F2_CLIENTE == "020031"

				SE1->(DbOrderNickName("SE1NUMPARC"))
				SE1->(DbSeek(xFilial("SE1") + SF2->F2_DOC))
				While !SE1->(Eof()) .And. SE1->E1_FILIAL + SE1->E1_NUM == xFilial("SE1") + SF2->F2_DOC

					If AllTrim(SE1->E1_PREFIXO) == "R"
						RecLock("SE1",.F.)
						SE1->(DbDelete())
						SE1->(MsUnLock())
					EndIf

					SE1->(DbSkip())
				EndDo
			EndIf
		EndIf
	EndIf
	
	RestArea(_aArea)

Return
