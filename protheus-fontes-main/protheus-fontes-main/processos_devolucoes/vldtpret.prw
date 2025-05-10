#INCLUDE "TOTVS.CH"

//--------------------------------------------------------------------------------------
/*/{Protheus.doc} VLDTPRET
@Type			: Função de Usuário
@Sample			: U_VLDTPRET()
@Description	: Função que efetua validação do campo ZH5_NUMREC na rotina de
                  controle de recebimento e inspeção de devolução (CRI_DEV.PRW)
@Param			: Número Recibo
@Return			: Lógico - .T. ou .F.
@ --------------|-----------------------------------------------------------------------
@Author			: Evandro Mugnol
@Since			: Dez/2025
@version		: Protheus 12.1.2310 e posteriores
@Comments		: Nenhum
/*/
//--------------------------------------------------------------------------------------
User Function VLDTPRET(_cNumRec)

	Local aArea  := FWGetArea()
	Local _lRet  := .T.

	DbSelectArea("ZH2")
	DbSetOrder(1)
	If DbSeek(FWxFilial("ZH2") + _cNumRec)
		If ZH2->ZH2_TIPRET == "1" .Or. ZH2->ZH2_TIPRET == "2"		// ZH2->ZH2_TIPRET <> "3"
			FWAlertError("Informe um número de recibo que seja do tipo retorno 'Retorno Físico Frigorífico' ou pesquise via F3.", "Número do recibo informado não possui tipo retorno igual a 'Retorno Físico Frigorífico'")
			_lRet := .F.
		//ElseIf ZH2->ZH2_TIPRET == "3" .And. ZH2->ZH2_STATUS <> "1" 
		//	FWAlertError("Informe um número de recibo cuja pré nota de devolução ainda não esteja lançada.","Número do recibo informado já possui pré nota de devolução lançada.")
		//	_lRet := .F.
		EndIf
	EndIf

	FWRestArea(aArea)

Return _lRet
