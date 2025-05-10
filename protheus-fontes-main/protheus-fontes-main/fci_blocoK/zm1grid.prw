#INCLUDE "TOTVS.CH"
#INCLUDE "FWBROWSE.CH"

//--------------------------------------------------------------------------------------
/*/{Protheus.doc} ZM1GRID
@Type			: Função de Usuário
@Sample			: U_ZM1GRID()
@Description	: Função para visualizar log da tabela temporária ZM1
@Param			: Nenhum
@Return			: Nenhum
@ --------------|-----------------------------------------------------------------------
@Author			: Evandro Mugnol
@Since			: Ago/2024
@version		: Protheus 12.1.2310 e posteriores
@Comments		: Nenhum 
/*/
//--------------------------------------------------------------------------------------
User Function ZM1GRID()

	Local oBrowse
	
	// Abertura da tabela
	DbSelectArea("ZM1")
	DbSetOrder(1)

	// Define o Browse
	oBrowse := FWMBrowse():New()
	oBrowse:SetDataTable(.T.)
	oBrowse:SetAlias("ZM1")

	// Adiciona botão de Sair no Browse
	oBrowse:AddButton("SAIR",{|| MsAguarde({|| CloseBrowse() },'Encerrando...')  },,2,,.F.)

	// Adiciona legenda no Browse
	oBrowse:AddLegend('ZM1_INCEMP = "S"'  ,"GREEN","Empenho Múltiplo Alterado com Sucesso")
	oBrowse:AddLegend('ZM1_INCEMP <> "S"' ,"RED"  ,"Empenho Múltiplo Não foi Alterado")

	// Ativação do Browse
	oBrowse:Activate()

Return
