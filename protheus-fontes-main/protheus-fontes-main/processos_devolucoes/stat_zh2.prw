#INCLUDE "TOTVS.CH"

//--------------------------------------------------------------------------------------
/*/{Protheus.doc} STAT_ZH2
@Type			: Função de Usuário
@Sample			: U_STAT_ZH2()
@Description	: Função para retornar uma lista de opções em um campo combo
@Param			: Nenhum
@Return			: _cOpcoes
@ --------------|-----------------------------------------------------------------------
@Author			: Evandro Mugnol
@Since			: Mar/2025
@version		: Protheus 12.1.2310 e posteriores
@Comments		: Chamada de user function no X3_CBOX do campo ZH2_STATUS '#U_STAT_ZH2()'
/*/
//--------------------------------------------------------------------------------------
User Function STAT_ZH2()

	Local _aArea   := FWGetArea()
	Local _cOpcoes := ""

    // Montando as opções de retorno
	_cOpcoes += "1=Aut. Dev. s/ Pré Nota;"
	_cOpcoes += "2=Aut. Dev. c/ Pré Nota Lançada;"
	_cOpcoes += "3=Aut. Dev. Liberada Supervisor ou Qualidade;"
	_cOpcoes += "4=Aut. Dev. Encerrada c/ NF Classificada;"
	_cOpcoes += "5=Aut. Dev. Encerrada c/ NF Classificada e Refaturamento Realizado"

	FWRestArea(_aArea)

Return(_cOpcoes)
