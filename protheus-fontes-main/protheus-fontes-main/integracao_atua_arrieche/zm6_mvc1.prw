#INCLUDE "PROTHEUS.CH"
#INCLUDE "FWMVCDEF.CH"

Static cTitulo    := "Despesas Lançadas no Atua"
Static cTabPai    := "ZM6"
Static cTabFilho1 := "ZM7"
Static cTabFilho2 := "ZM8"

//--------------------------------------------------------------------------------------
/*/{Protheus.doc} ZM6_MVC1
@Type			: Função de Usuário
@Sample			: U_ZM6_MVC1()
@Description	: Rotina em MVC para visualizar os dados das Despesas (tabelas ZM6, ZM7 e ZM8)
@Param			: N/A
@Return			: Nulo
@ --------------|-----------------------------------------------------------------------
@Author			: Evandro Mugnol
@Since			: Fev/2024
@version		: Protheus 12.1.2210 e posteriores
@Comments		: Executado através do botão "Visualizar" na importação das Despesas.
/*/
//--------------------------------------------------------------------------------------
User Function ZM6_MVC1()

	Local aArea := GetArea()
	Local oBrowse

	Private aRotina := MenuDef()

	// Instânciando FWMBrowse - Somente com dicionário de dados
	oBrowse := FWMBrowse():New()

	// Setando a tabela de cadastro
	oBrowse:SetAlias(cTabPai)

	// Setando a descrição da rotina
	oBrowse:SetDescription(cTitulo)

    oBrowse:DisableDetails()
 
	// Ativa a Browse
	oBrowse:Activate()

	RestArea(aArea)

Return Nil


//-----------------------------------------------------------------------
/*/{Protheus.doc} MenuDef
Função de criação do menu MVC
@author     Evandro Mugnol
@since      Fev/2024
/*/
//-----------------------------------------------------------------------
Static Function MenuDef()

	Local aRotina := {}

	// Adicionando opções
	ADD OPTION aRotina TITLE "Visualizar" ACTION "VIEWDEF.ZM6_MVC1" OPERATION MODEL_OPERATION_VIEW	 ACCESS 0 	// OPERATION 2

Return aRotina


//-----------------------------------------------------------------------
/*/{Protheus.doc} ModelDef
Função de criação do modelo de dados MVC
@author     Evandro Mugnol
@since      Fev/2024
/*/
//-----------------------------------------------------------------------
Static Function ModelDef()

	// Criação do objeto do modelo de dados
	Local oModel := Nil

	// Criação da estrutura de dados utilizada na interface
    Local oStrPai    := FWFormStruct(1, cTabPai)
    Local oStrFilho1 := FWFormStruct(1, cTabFilho1)
    Local oStrFilho2 := FWFormStruct(1, cTabFilho2)
    Local aRelation  := {}
    Local aRelation2 := {}

	// Criando o modelo e os relacionamentos
	oModel := MPFormModel():New("ZM6MVC1M" , /*bPreValidacao*/,/*bPosValidacao*/,/*bCommit*/,/*bCancel*/,/*bLoad*/ )
	oModel:AddFields("ZM6MASTER",/*cOwner*/,oStrPai,/*bPreVld*/, /*bPost*/ ,)
    oModel:AddGrid("ZM7DETAIL","ZM6MASTER",oStrFilho1,/*bLinePre*/, /*bLinePost*/,/*bPre - Grid Inteiro*/,/*bPos - Grid Inteiro*/,/*bLoad - Carga do modelo manualmente*/)
    oModel:AddGrid("ZM8DETAIL","ZM6MASTER",oStrFilho2,/*bLinePre*/, /*bLinePost*/,/*bPre - Grid Inteiro*/,/*bPos - Grid Inteiro*/,/*bLoad - Carga do modelo manualmente*/)

	// Fazendo o relacionamento entre o Pai e Filho
    aAdd(aRelation, {"ZM7_FILIAL", "FWxFilial('ZM7')"} )
    aAdd(aRelation, {"ZM7_IDDESP", "ZM6_IDDESP"})
    oModel:SetRelation("ZM7DETAIL", aRelation, ZM7->(IndexKey(2)))      // IndexKey -> quero a ordenação e depois filtrado
 
    aAdd(aRelation2, {"ZM8_FILIAL", "FWxFilial('ZM8')"} )
    aAdd(aRelation2, {"ZM8_IDDESP", "ZM6_IDDESP"})
    oModel:SetRelation("ZM8DETAIL", aRelation2, ZM8->(IndexKey(1)))     // IndexKey -> quero a ordenação e depois filtrado

	oModel:SetPrimaryKey({})

	// Setando as descrições
    oModel:SetDescription("Modelo de dados - " + cTitulo)
    oModel:GetModel("ZM6MASTER"):SetDescription( "Dados de - " + cTitulo)
    oModel:GetModel("ZM7DETAIL"):SetDescription( "Grid ZM7 de - " + cTitulo)
    oModel:GetModel("ZM8DETAIL"):SetDescription( "Grid ZM8 de - " + cTitulo)

Return oModel


//-----------------------------------------------------------------------
/*/{Protheus.doc} ViewlDef
Função de criação da visão MVC
@author     Evandro Mugnol
@since      Fev/2024
/*/
//-----------------------------------------------------------------------
Static Function ViewDef()

	// Criando oView como nulo
	Local oView	:= Nil

	// Criação do objeto do modelo de dados da interface do cadastro
    Local oModel     := FWLoadModel("ZM6_MVC1")
    Local oStrPai    := FWFormStruct(2, cTabPai)
    Local oStrFilho1 := FWFormStruct(2, cTabFilho1)
    Local oStrFilho2 := FWFormStruct(2, cTabFilho2)

	// Criando a view que será o retorno da função e setando o modelo da rotina
    oView := FWFormView():New()
    oView:SetModel(oModel)

	// Adicionando os campos do cabeçalho e o grid dos filhos
    oView:AddField("VIEW_ZM6", oStrPai, "ZM6MASTER")

    // Grids dos filhos
    oView:AddGrid("VIEW_ZM7",  oStrFilho1,  "ZM7DETAIL")
    oView:AddGrid("VIEW_ZM8",  oStrFilho2,  "ZM8DETAIL")

    // Setando o dimensionamento de tamanho
    oView:CreateHorizontalBox("CABEC", 60)
    oView:CreateHorizontalBox("GRID", 40)

    // Criando a folder dos produtos (filhos)
    oView:CreateFolder("PASTA_FILHOS", "GRID")
    oView:AddSheet("PASTA_FILHOS", "ABA_FILHO01", "Produtos")
    oView:AddSheet("PASTA_FILHOS", "ABA_FILHO02", "Financeiro")
 
    // Criando os vinculos onde serão mostrado os dados
    oView:CreateHorizontalBox("ITENS_FILHO01", 100,,, "PASTA_FILHOS", "ABA_FILHO01" )
    oView:CreateHorizontalBox("ITENS_FILHO02", 100,,, "PASTA_FILHOS", "ABA_FILHO02" )

   // Amarrando a view com as box
    oView:SetOwnerView("VIEW_ZM6", "CABEC")
    oView:SetOwnerView("VIEW_ZM7", "ITENS_FILHO01")
    oView:SetOwnerView("VIEW_ZM8", "ITENS_FILHO02")
 
    // Removendo campos
    oStrFilho1:RemoveField("ZM7_FILIAL")
    //oStrFilho1:RemoveField("ZM7_IDDESP")
    oStrFilho2:RemoveField("ZM8_FILIAL")
    //oStrFilho2:RemoveField("ZM8_IDDESP")
 
	// Força o fechamento da janela na confirmação
	oView:SetCloseOnOk({||.T.})

	// Habilitando título
    oView:EnableTitleView("VIEW_ZM6", "Cabeçalho da Despesa")

Return oView
