#INCLUDE "TOTVS.CH"
#INCLUDE "FWMVCDEF.CH"

//--------------------------------------------------------------------------------------
/*/{Protheus.doc} FC030CON
@Type			: Ponto de Entrada
@Sample			: U_FC030CON()
@Description	: O ponto de entrada FC030CON habilita a opção Cons. Especif na consulta
                  Posição de Fornecedor (FINC030) que contém a ação estabelecida do 
				  ponto de entrada.
@Return			: Nenhum
@ --------------|-----------------------------------------------------------------------
@Author			: Evandro Mugnol
@Since			: Out/2024
@version		: Protheus 12.1.2310 e posteriores
@Comments		: Nenhum
/*/
//--------------------------------------------------------------------------------------
User Function FC030CON()

	Local _aArea := FWGetArea()

	FA885ChPix()	// Chama a rotina de chaves PIX do fornecedor posicionado

	FWRestArea(_aArea)

Return
