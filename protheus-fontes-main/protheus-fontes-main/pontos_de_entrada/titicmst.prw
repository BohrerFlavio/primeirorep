#INCLUDE "TOTVS.CH"

//--------------------------------------------------------------------------------------
/*/{Protheus.doc} TITICMST 
@Type			: Ponto de Entrada
@Sample			: U_TITICMST()
@Description	: Ponto de entrada após a gravação dos tributos no título a ser gerado
                  no financeiro.
@Param			: Nil
@Return			: Array - Retorna os campos do numero titulo e data de vencimento titulo
@ --------------|-----------------------------------------------------------------------
@Author			: Evandro Mugnol
@Since			: Jul/2021
@version		: Protheus 12.1.25 e posteriores
@Comments		: N/A
/*/
//--------------------------------------------------------------------------------------

User Function TITICMST()

	Local cOrigem := PARAMIXB[1]

	If AllTrim(cOrigem) == "MATA460A"	    // Documento de Saída
		SE2->E2_VENCTO  := DataValida(SE2->E2_EMISSAO + 1,.T.)
		SE2->E2_VENCREA := DataValida(SE2->E2_EMISSAO + 1,.T.)
	EndIf

Return {SE2->E2_NUM,SE2->E2_VENCTO}
