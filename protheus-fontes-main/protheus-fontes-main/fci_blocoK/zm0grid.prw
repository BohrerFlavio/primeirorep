#INCLUDE "TOTVS.CH"
#INCLUDE "FWBROWSE.CH"

//--------------------------------------------------------------------------------------
/*/{Protheus.doc} ZM0GRID
@Type			: Função de Usuário
@Sample			: U_ZM0GRID()
@Description	: Função para visualizar log da tabela temporária ZM0
@Param			: Nenhum
@Return			: Nenhum
@ --------------|-----------------------------------------------------------------------
@Author			: Evandro Mugnol
@Since			: Jul/2024
@version		: Protheus 12.1.2310 e posteriores
@Comments		: Nenhum 
/*/
//--------------------------------------------------------------------------------------
User Function ZM0GRID()

	Local oBrowse
	
	// Abertura da tabela
	DbSelectArea("ZM0")
	DbSetOrder(1)

	// Define o Browse
	oBrowse := FWMBrowse():New()
	oBrowse:SetDataTable(.T.)
	oBrowse:SetAlias("ZM0")

	// Adiciona botão de Sair no Browse
	oBrowse:AddButton("SAIR",{|| MsAguarde({|| CloseBrowse() },'Encerrando...')  },,2,,.F.)

	// Adiciona legenda no Browse
	oBrowse:AddLegend('ZM0_NUM <> "      "',"GREEN","OP Gerada com Sucesso")
	oBrowse:AddLegend('ZM0_NUM = "      "' ,"RED"  ,"OP Não foi Gerada")

	// Ativação do Browse
	oBrowse:Activate()

Return
