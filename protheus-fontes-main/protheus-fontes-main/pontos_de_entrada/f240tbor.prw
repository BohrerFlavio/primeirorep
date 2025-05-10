#INCLUDE "TOTVS.CH"

//-------------------------------------------------------------------
/*/{Protheus.doc} F240TBOR
Ponto de entrada executado após a gravação dos dados do bordero de pagamento
@author 	Evandro Mugnol
@since 		Set/2021
@return 	Nil, Função não tem retorno
@obs 		N/A
/*/
//-------------------------------------------------------------------

User Function F240TBOR()

	RecLock("SE2", .F.)
	SE2->E2_FDTPGTO := GetMv("FS_FDTPGTO")
	MsUnlock()

Return
