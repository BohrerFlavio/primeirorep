#INCLUDE "PROTHEUS.CH"
#INCLUDE "FWMVCDEF.CH"

//--------------------------------------------------------------------------------------
/*/{Protheus.doc} ZH3_MVC1
@Type			: Função de Usuário
@Sample			: U_ZH3_MVC1()
@Description	: Rotina em MVC para visualizar os dados dos vínculoS de notas fiscais
                  de devolução X refaturamento (tabelas ZH3 e ZH4)
@Param			: N/A
@Return			: Nulo
@ --------------|-----------------------------------------------------------------------
@Author			: Evandro Mugnol
@Since			: Mar/2025
@version		: Protheus 12.1.2310 e posteriores
@Comments		: Nenhum
/*/
//--------------------------------------------------------------------------------------
User Function ZH3_MVC1()

	Local aArea := GetArea()
	Local oBrowse

	Private aRotina := MenuDef()

	// Instânciando FWMBrowse - Somente com dicionário de dados
	oBrowse := FWMBrowse():New()

	// Setando a tabela de cadastro
	oBrowse:SetAlias("ZH3")

	// Setando a descrição da rotina
	oBrowse:SetDescription("Vínculos de notas fiscais de devolução X refaturamento")

    // Adicionando a primeira legenda
	oBrowse:AddLegend("ZH3->ZH3_STATUS = '1'", "RED"   , "Refaturamento Pendente"		 	   )
	oBrowse:AddLegend("ZH3->ZH3_STATUS = '2'", "ORANGE", "Refaturamento Parcialmente Realizado")
	oBrowse:AddLegend("ZH3->ZH3_STATUS = '3'", "GREEN" , "Refaturamento Totalmente Realizado"  )

	// Ativa a Browse
	oBrowse:Activate()

	RestArea(aArea)

Return Nil


//-----------------------------------------------------------------------
/*/{Protheus.doc} MenuDef
Função de criação do menu MVC
@author     Evandro Mugnol
@since      Mar/2025
/*/
//-----------------------------------------------------------------------
Static Function MenuDef()

	Local aRotina := {}

	// Adicionando opções
	ADD OPTION aRotina TITLE "Visualizar" ACTION "VIEWDEF.ZH3_MVC1" OPERATION MODEL_OPERATION_VIEW	 ACCESS 0 	// OPERATION 2

Return aRotina


//-----------------------------------------------------------------------
/*/{Protheus.doc} ModelDef
Função de criação do modelo de dados MVC
@author     Evandro Mugnol
@since      Mar/2025
/*/
//-----------------------------------------------------------------------
Static Function ModelDef()

	// Criação do objeto do modelo de dados
	Local oModel   := Nil

	// Criação da estrutura de dados utilizada na interface
	Local oStPai   := FWFormStruct(1, "ZH3", /*bAvalCampo*/, /*lViewUsado*/)
	Local oStFilho := FWFormStruct(1, "ZH4", /*bAvalCampo*/, /*lViewUsado*/)
	Local aZH4Rel  := {}

	// Criando o modelo e os relacionamentos
	oModel := MPFormModel():New("ZH3MVC1M" , /*bPreValidacao*/,/*bPosValidacao*/,/*bCommit*/,/*bCancel*/,/*bLoad*/ )
	oModel:AddFields("ZH3MASTER",/*cOwner*/,oStPai,/*bPreVld*/, /*bPost*/ ,)
	oModel:AddGrid("ZH4DETAIL","ZH3MASTER",oStFilho,/*bLinePre*/, /*bLinePost*/,/*bPreVal - Grid Inteiro*/,/*bPosVal - Grid Inteiro*/,/*bLoad - Carga do modelo manualmente*/)  	// cOwner é para quem pertence

	// Fazendo o relacionamento entre o Pai e Filho
	aAdd(aZH4Rel, {"ZH4_FILIAL", "ZH3_FILIAL"})
	aAdd(aZH4Rel, {"ZH4_NFDEV" , "ZH3_NFDEV" })
	aAdd(aZH4Rel, {"ZH4_SERDEV", "ZH3_SERDEV"})
	aAdd(aZH4Rel, {"ZH4_CLIDEV", "ZH3_CLIDEV"})
	aAdd(aZH4Rel, {"ZH4_LOJDEV", "ZH3_LOJDEV"})

	oModel:SetRelation("ZH4DETAIL", aZH4Rel, ZH4->(IndexKey(1))) 					// IndexKey -> quero a ordenação e depois filtrado
	oModel:SetPrimaryKey({})

	// Setando as descrições
	oModel:SetDescription("Vínculos de notas fiscais de devolução X refaturamento")
	//oModel:GetModel("ZH3MASTER"):SetDescription("Cabeçalho - Vínculos de notas fiscais de devolução X refaturamento")
	oModel:GetModel("ZH4DETAIL"):SetDescription("Itens - Vínculos de notas fiscais de devolução X refaturamento")

Return oModel


//-----------------------------------------------------------------------
/*/{Protheus.doc} ViewlDef
Função de criação da visão MVC
@author     Evandro Mugnol
@since      Mar/2025
/*/
//-----------------------------------------------------------------------
Static Function ViewDef()

	// Criando oView como nulo
	Local oView	   := Nil

	// Criação do objeto do modelo de dados da interface do cadastro
	Local oModel   := FWLoadModel("ZH3_MVC1")
	Local oStPai   := FWFormStruct(2, "ZH3")
	Local oStFilho := FWFormStruct(2, "ZH4")

	// Criando a view que será o retorno da função e setando o modelo da rotina
	oView := FWFormView():New()
	oView:SetModel(oModel)

	// Adicionando os campos do cabeçalho e o grid dos filhos
	oView:AddField("VIEW_ZH3",oStPai,"ZH3MASTER")
	oView:AddGrid("VIEW_ZH4",oStFilho,"ZH4DETAIL")

	// Setando o dimensionamento de tamanho
	oView:CreateHorizontalBox("CABEC",60)
	oView:CreateHorizontalBox("GRID", 40)

	// Força o fechamento da janela na confirmação
	oView:SetCloseOnOk({||.T.})

	// Amarrando a view com as box
	oView:SetOwnerView("VIEW_ZH3","CABEC")
	oView:SetOwnerView("VIEW_ZH4","GRID")

	// Seta a cor de backgroud da linha selecionda
	oView:SetViewProperty( "VIEW_ZH4", "SETCSS", { "QTableView { selection-background-color: #0091FF; }" } )

	// Habilitando título
	//oView:EnableTitleView("VIEW_ZH3","Cabeçalho - Vínculos de notas fiscais de devolução X refaturamento")
	oView:EnableTitleView("VIEW_ZH4","Itens - Vínculos de notas fiscais de devolução X refaturamento")

Return oView
