#INCLUDE "TOTVS.CH"

//--------------------------------------------------------------------------------------
/*/{Protheus.doc} FA60CAN1
@Type			: Ponto de Entrada
@Sample			: U_FA60CAN1()
@Description	: Ponto de entrada FA60CAN1 será executado antes da gravação do SE1 no 
                  estorno do borderô do contas a receber.
@Param			: Nenhum
@Return			: Lógico - .T. ou .F.
@ --------------|-----------------------------------------------------------------------
@Author			: Evandro Mugnol
@Since			: Nov/2024
@version		: Protheus 12.1.2310 e posteriores
@Comments		: Cria variável pública para ser utilizada no P.E. FA60CAN2
/*/
//--------------------------------------------------------------------------------------
User Function FA60CAN1()

    PUBLIC _cNumBco := SE1->E1_NUMBCO

Return .T.
