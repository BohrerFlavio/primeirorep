#INCLUDE "PROTHEUS.CH"
#INCLUDE "FWMVCDEF.CH"

//--------------------------------------------------------------------------------------
/*/{Protheus.doc} ZM4_MVC1
@Type			: Função de Usuário
@Sample			: U_ZM4_MVC1()
@Description	: Rotina em MVC para visualizar os dados dos CTRCs (tabelas ZM4 e ZM5)
@Param			: N/A
@Return			: Nulo
@ --------------|-----------------------------------------------------------------------
@Author			: Evandro Mugnol
@Since			: Dez/2023
@version		: Protheus 12.1.2210 e posteriores
@Comments		: Executado através do botão "Visualizar" na importação dos CTRCs.
/*/
//--------------------------------------------------------------------------------------
User Function ZM4_MVC1()

	Local aArea := GetArea()
	Local oBrowse

	Private aRotina := MenuDef()

	// Instânciando FWMBrowse - Somente com dicionário de dados
	oBrowse := FWMBrowse():New()

	// Setando a tabela de cadastro
	oBrowse:SetAlias("ZM4")

	// Setando a descrição da rotina
	oBrowse:SetDescription("TESTE")

	// Ativa a Browse
	oBrowse:Activate()

	RestArea(aArea)

Return Nil


//-----------------------------------------------------------------------
/*/{Protheus.doc} MenuDef
Função de criação do menu MVC
@author     Evandro Mugnol
@since      Dez/2023
/*/
//-----------------------------------------------------------------------
Static Function MenuDef()

	Local aRotina := {}

	// Adicionando opções
	ADD OPTION aRotina TITLE "Visualizar" ACTION "VIEWDEF.ZM4_MVC1" OPERATION MODEL_OPERATION_VIEW	 ACCESS 0 	// OPERATION 2

Return aRotina


//-----------------------------------------------------------------------
/*/{Protheus.doc} ModelDef
Função de criação do modelo de dados MVC
@author     Evandro Mugnol
@since      Dez/2023
/*/
//-----------------------------------------------------------------------
Static Function ModelDef()

	// Criação do objeto do modelo de dados
	Local oModel   := Nil

	// Criação da estrutura de dados utilizada na interface
	Local oStPai   := FWFormStruct(1, "ZM4", /*bAvalCampo*/, /*lViewUsado*/)
	Local oStFilho := FWFormStruct(1, "ZM5", /*bAvalCampo*/, /*lViewUsado*/)
	Local aZM5Rel  := {}

	// Criando o modelo e os relacionamentos
	oModel := MPFormModel():New("ZM4MVC1M" , /*bPreValidacao*/,/*bPosValidacao*/,/*bCommit*/,/*bCancel*/,/*bLoad*/ )
	oModel:AddFields("ZM4MASTER",/*cOwner*/,oStPai,/*bPreVld*/, /*bPost*/ ,)
	oModel:AddGrid("ZM5DETAIL","ZM4MASTER",oStFilho,/*bLinePre*/, /*bLinePost*/,/*bPreVal - Grid Inteiro*/,/*bPosVal - Grid Inteiro*/,/*bLoad - Carga do modelo manualmente*/)  	// cOwner é para quem pertence

	// Fazendo o relacionamento entre o Pai e Filho
	aAdd(aZM5Rel, {"ZM5_FILIAL", "ZM4_FILIAL"})
	aAdd(aZM5Rel, {"ZM5_CHVCTE", "ZM4_CHVCTE"})

	oModel:SetRelation("ZM5DETAIL", aZM5Rel, ZM5->(IndexKey(1))) 					// IndexKey -> quero a ordenação e depois filtrado
	oModel:SetPrimaryKey({})

	// Setando as descrições
	oModel:SetDescription("CTRCs Importados do Atua")
	oModel:GetModel("ZM4MASTER"):SetDescription("Cabeçalho - CTRCs Importados do Atua")
	oModel:GetModel("ZM5DETAIL"):SetDescription("Produtos - CTRCs Importados do Atua")

Return oModel


//-----------------------------------------------------------------------
/*/{Protheus.doc} ViewlDef
Função de criação da visão MVC
@author     Evandro Mugnol
@since      Dez/2023
/*/
//-----------------------------------------------------------------------
Static Function ViewDef()

	// Criando oView como nulo
	Local oView	   := Nil

	// Criação do objeto do modelo de dados da interface do cadastro
	Local oModel   := FWLoadModel("ZM4_MVC1")
	Local oStPai   := FWFormStruct(2, "ZM4")
	Local oStFilho := FWFormStruct(2, "ZM5")

	// Criando a view que será o retorno da função e setando o modelo da rotina
	oView := FWFormView():New()
	oView:SetModel(oModel)

	// Adicionando os campos do cabeçalho e o grid dos filhos
	oView:AddField("VIEW_ZM4",oStPai,"ZM4MASTER")
	oView:AddGrid("VIEW_ZM5",oStFilho,"ZM5DETAIL")

	// Setando o dimensionamento de tamanho
	oView:CreateHorizontalBox("CABEC",70)
	oView:CreateHorizontalBox("GRID", 30)

	// Força o fechamento da janela na confirmação
	oView:SetCloseOnOk({||.T.})

	// Amarrando a view com as box
	oView:SetOwnerView("VIEW_ZM4","CABEC")
	oView:SetOwnerView("VIEW_ZM5","GRID")

	// Habilitando título
	oView:EnableTitleView("VIEW_ZM4","Cabeçalho - CTRCs Importados do Atua")
	oView:EnableTitleView("VIEW_ZM5","Produtos - CTRCs Importados do Atua")

Return oView
