#INCLUDE "PROTHEUS.CH"
#INCLUDE "FWMVCDEF.CH"

// Variáveis Estáticas
Static cTitulo := "Log de Atualizacao da tabela de precos X tabela de custos dos produtos"

//--------------------------------------------------------------------------------------
/*/{Protheus.doc} MVCZ08
Função para mostrar log de atualizacao de tabela de precos X tabela de custos dos produtos
@author 	Evandro Mugnol
@since 		Nov/2023
@return 	Nil, Função não tem retorno
@obs 		Não se pode executar função MVC dentro do fórmulas
/*/
//--------------------------------------------------------------------------------------
User Function MVCZ08()

	Local aArea := GetArea()
	Local oBrowse

	Private aRotina := MenuDef()

	// Instânciando FWMBrowse - Somente com dicionário de dados
	oBrowse := FWMBrowse():New()

	// Setando a tabela de cadastro
	oBrowse:SetAlias("Z08")

	// Setando a descrição da rotina
	oBrowse:SetDescription(cTitulo)

	// Ativa a Browse
	oBrowse:Activate()

	RestArea(aArea)

Return Nil


/*====================================================================*
| Função:  		MenuDef                                               |
| Descrição:	Criação do menu MVC                                   |
*====================================================================*/
Static Function MenuDef()

	Local aRotina := {}

	// Adicionando opções
	ADD OPTION aRotina TITLE "Pesquisar"  ACTION "VIEWDEF.MVCZ08" OPERATION 1 						ACCESS 0 // OPERATION 1
	ADD OPTION aRotina TITLE "Visualizar" ACTION "VIEWDEF.MVCZ08" OPERATION MODEL_OPERATION_VIEW	ACCESS 0 // OPERATION 2

Return aRotina


/*====================================================================*
| Função:  		ModelDef                                              |
| Descrição:	Criação do modelo de dados MVC                        |
*====================================================================*/
Static Function ModelDef()

	// Blocos de código nas validações
	//Local bPre 	:= {|| U_Z081Pre()} 	// Função chamada antes de abrir a tela
	//Local bPos 	:= {|| U_Z081Pos()} 	// Função chamada de validação ao clicar no Confirmar
	//Local bCommit := {|| U_Z081Com()} 	// Função chamada no commit
	//Local bCancel := {|| U_Z081Can()} 	// Função chamada ao cancelar

	// Criação do objeto do modelo de dados
	Local oModel := Nil

	// Criação da estrutura de dados utilizada na interface
	Local oStZ08 := FWFormStruct(1, "Z08")

	// Instanciando o modelo, não é recomendado colocar nome da user function (por causa do u_), respeitando 10 caracteres
	oModel := MPFormModel():New("MVCZ08M",/*bPre*/, /*bPos*/,/*bCommit*/,/*bCancel*/)

	// Atribuindo formulários para o modelo
	oModel:AddFields("FORMZ08",/*cOwner*/,oStZ08)

	// Setando a chave primária da rotina
	oModel:SetPrimaryKey({"Z08_FILIAL","Z08_NUMATU"})

	// Adicionando descrição ao modelo
	oModel:SetDescription(cTitulo)

	// Setando a descrição do formulário
	oModel:GetModel("FORMZ08"):SetDescription(cTitulo)

Return oModel


/*====================================================================*
| Função:  		ViewDef                                               |
| Descrição:	Criação da visão MVC                                  |
*====================================================================*/
Static Function ViewDef()

	// Criação do objeto do modelo de dados da interface do cadastro
	Local oModel := FWLoadModel("MVCZ08")

	// Criação da estrutura de dados utilizada na interface do cadastro
	Local oStZ08 := FWFormStruct(2, "Z08")  // pode se usar um terceiro parâmetro para filtrar os campos exibidos { |cCampo| cCampo $ 'XXX_NOME|XXX_DATAI|'}

	// Criando oView como nulo
	Local oView := Nil

	// Criando a view que será o retorno da função e setando o modelo da rotina
	oView := FWFormView():New()
	oView:SetModel(oModel)

	// Atribuindo formulários para interface
	oView:AddField("VIEW_Z08", oStZ08, "FORMZ08")

	// Criando um container com nome tela com 100%
	oView:CreateHorizontalBox("TELA",100)

	// Força o fechamento da janela na confirmação
	oView:SetCloseOnOk({||.T.})

	// O formulário da interface será colocado dentro do container
	oView:SetOwnerView("VIEW_Z08","TELA")

Return oView
