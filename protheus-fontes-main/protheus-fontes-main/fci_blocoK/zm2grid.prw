#INCLUDE "TOTVS.CH"
#INCLUDE "FWBROWSE.CH"

//--------------------------------------------------------------------------------------
/*/{Protheus.doc} ZM2GRID
@Type			: Função de Usuário
@Sample			: U_ZM2GRID()
@Description	: Função para visualizar log da tabela temporária ZM2
@Param			: Nenhum
@Return			: Nenhum
@ --------------|-----------------------------------------------------------------------
@Author			: Evandro Mugnol
@Since			: Ago/2024
@version		: Protheus 12.1.2310 e posteriores
@Comments		: Nenhum 
/*/
//--------------------------------------------------------------------------------------
User Function ZM2GRID()

	Local oBrowse

	// Abertura da tabela
	DbSelectArea("ZM2")
	DbSetOrder(1)

	// Define o Browse
	oBrowse := FWMBrowse():New()
	oBrowse:SetDataTable(.T.)
	oBrowse:SetAlias("ZM2")

	// Adiciona botão de Sair no Browse
	oBrowse:AddButton("SAIR",{|| MsAguarde({|| CloseBrowse() },'Encerrando...')  },,2,,.F.)

	// Adiciona legenda no Browse
	oBrowse:AddLegend('!Empty(ZM2_DATRF)'  ,"GREEN","OP Encerrada com Sucesso")
	oBrowse:AddLegend('Empty(ZM2_DATRF)'   ,"RED"  ,"OP Não está Encerrada")

	// Ativação do Browse
	oBrowse:Activate()

Return
