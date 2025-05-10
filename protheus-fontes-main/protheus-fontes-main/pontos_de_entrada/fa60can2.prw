#INCLUDE "TOTVS.CH"

//--------------------------------------------------------------------------------------
/*/{Protheus.doc} FA60CAN2
@Type			: Ponto de Entrada
@Sample			: U_FA60CAN2()
@Description	: Ponto de entrada será executado após gravar o SE1 (restauração) no 
                  estorno do borderô.
@Param			: Nenhum
@Return			: Nenhum
@ --------------|-----------------------------------------------------------------------
@Author			: Evandro Mugnol
@Since			: Nov/2024
@version		: Protheus 12.1.2310 e posteriores
@Comments		: Recebe variável pública criada no P.E. FA60CAN1
/*/
//--------------------------------------------------------------------------------------
User Function FA60CAN2()

	If !Empty(_cNumBco)
		RecLock("SE1",.F.)
		SE1->E1_NUMBCO := _cNumBco
		MsUnlock()
	Endif

Return
