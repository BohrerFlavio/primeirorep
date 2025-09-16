#INCLUDE "TOTVS.CH"
#INCLUDE "TOPCONN.CH"

//--------------------------------------------------------------------------------------
/*/{Protheus.doc} F811QRY 
@Type			: Ponto de Entrada
@Sample			: U_F811QRY()
@Description	: ponto de entrada que permite complementar a query que considera os
                  parâmetros informados para listas os clientes disponíveis. Esse ponto
                  de entrada é executado na terceira janela do wizard (Seleção de Clientes)
                  de envio das cartas de cobrança.
@Param			: N/A
@Return			: cQuery - Query que será usada para completar filtrar os registros do 
                           processo 
--------------|-----------------------------------------------------------------------
@Author			: Evandro Mugnol
@Since			: Jul/2021
@version		: Protheus 12.1.25 e posteriores
@Comments		: N/A
/*/
//--------------------------------------------------------------------------------------

User Function F811QRY()

    Local cQry := ""

    // Não modificar o critério abaixo senão o complemento da query deixa de funcionar
    // O motivo é devido como está estruturado o fonte padrão e isso é para retornar 
    // todos os clientes para seleção independente de estarem ativos ou inativos.
    cQry += " SA1.A1_NOME <> '' "
    cQry += " OR SA1.A1_MSBLQL <> '' "

Return(cQry)
