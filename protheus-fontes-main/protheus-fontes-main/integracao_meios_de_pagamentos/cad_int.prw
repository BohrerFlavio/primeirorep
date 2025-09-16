#INCLUDE "TOTVS.CH"
#INCLUDE "FWMVCDEF.CH"

// Variáveis Estáticas
Static cTitulo := "Cadastro de Integradoras"

//-------------------------------------------------------------------
/*/{Protheus.doc} CAD_INT
Função para cadastro e manutenção de integradoras - Modelo 1 em MVC
@author 	Evandro Mugnol
@since 		Out/2020
@return 	Nil, Função não tem retorno
@obs 		Não se pode executar função MVC dentro do fórmulas
/*/
//-------------------------------------------------------------------

User Function CAD_INT()

	Local aArea := GetArea()
	Local oBrowse

	Private aRotina := MenuDef()

	// Instânciando FWMBrowse - Somente com dicionário de dados
	oBrowse := FWMBrowse():New()

	// Setando a tabela de cadastro
	oBrowse:SetAlias("ZK0")

	// Setando a descrição da rotina
	oBrowse:SetDescription(cTitulo)

	// Ativa a Browse
	oBrowse:Activate()

	RestArea(aArea)

Return Nil


//-------------------------------------------------------------------
/*/{Protheus.doc} MenuDef
Criação do Menu MVC
@author     Evandro
@since      Out/2020
@return     N/A
@obs        N/A
/*/
//-------------------------------------------------------------------
Static Function MenuDef()

	Local aRotina := {}

	// Adicionando opções
	ADD OPTION aRotina TITLE "Visualizar" ACTION "VIEWDEF.CAD_INT" 	OPERATION MODEL_OPERATION_VIEW	 ACCESS 0 // OPERATION 2
	ADD OPTION aRotina TITLE "Incluir"    ACTION "VIEWDEF.CAD_INT" 	OPERATION MODEL_OPERATION_INSERT ACCESS 0 // OPERATION 3
	ADD OPTION aRotina TITLE "Alterar"    ACTION "VIEWDEF.CAD_INT" 	OPERATION MODEL_OPERATION_UPDATE ACCESS 0 // OPERATION 4
	ADD OPTION aRotina TITLE "Excluir"    ACTION "VIEWDEF.CAD_INT" 	OPERATION MODEL_OPERATION_DELETE ACCESS 0 // OPERATION 5

Return aRotina


//-------------------------------------------------------------------
/*/{Protheus.doc} ModelDef
Criação do Modelo de Dados MVC
@author     Evandro
@since      Out/2020
@return     N/A
@obs        N/A
/*/
//-------------------------------------------------------------------
Static Function ModelDef()

	// Blocos de código nas validações
	//Local bPre 	:= {|| U_ZK0Pre()} 	// Função chamada antes de abrir a tela
	//Local bPos 	:= {|| U_ZK0Pos()} 	// Função chamada de validação ao clicar no Confirmar
	//Local bCommit := {|| U_ZK0Com()} 	// Função chamada no commit
	//Local bCancel := {|| U_ZK0Can()} 	// Função chamada ao cancelar

	// Criação do objeto do modelo de dados
	Local oModel := Nil

	// Criação da estrutura de dados utilizada na interface
	Local oStZK0 := FWFormStruct(1, "ZK0")

	// Instanciando o modelo, não é recomendado colocar nome da user function (por causa do u_), respeitando 10 caracteres
	oModel := MPFormModel():New("STIZK0M",/*bPre*/, /*bPos*/,/*bCommit*/,/*bCancel*/) 

	// Atribuindo formulários para o modelo
	oModel:AddFields("FORMZK0",/*cOwner*/,oStZK0)

	// Setando a chave primária da rotina
	oModel:SetPrimaryKey({"ZK0_FILIAL","ZK0_CODINT"})

	// Adicionando descrição ao modelo
	oModel:SetDescription(cTitulo)

	// Setando a descrição do formulário
	oModel:GetModel("FORMZK0"):SetDescription("Formulário do " + cTitulo)

Return oModel


//-------------------------------------------------------------------
/*/{Protheus.doc} ViewDef
Criação da Visão MVC
@author     Evandro
@since      Out/2020
@return     N/A
@obs        N/A
/*/
//-------------------------------------------------------------------
Static Function ViewDef()

	// Criação do objeto do modelo de dados da interface do cadastro
	Local oModel := FWLoadModel("CAD_INT")

	// Criação da estrutura de dados utilizada na interface do cadastro
	Local oStZK0 := FWFormStruct(2, "ZK0")  // pode se usar um terceiro parâmetro para filtrar os campos exibidos { |cCampo| cCampo $ 'XXX_NOME|XXX_DATAI|'}

	// Criando oView como nulo
	Local oView := Nil

	// Criando a view que será o retorno da função e setando o modelo da rotina
	oView := FWFormView():New()
	oView:SetModel(oModel)

	// Atribuindo formulários para interface
	oView:AddField("VIEW_ZK0", oStZK0, "FORMZK0")

	// Criando um container com nome tela com 100%
	oView:CreateHorizontalBox("TELA",100)

	// Colocando título do formulário
	oView:EnableTitleView('VIEW_ZK0', 'Preencha os campos abaixo para serem considerados no cadastro de clientes -> Outras Opções -> Cartões de Crédito X Cliente' )  

	// Força o fechamento da janela na confirmação
	oView:SetCloseOnOk({||.T.})

	// O formulário da interface será colocado dentro do container
	oView:SetOwnerView("VIEW_ZK0","TELA")

Return oView


//-------------------------------------------------------------------
/*/{Protheus.doc} ZK0Pos
Função chamada no clique do botão Ok do Modelo de Dados (pós-validação)
@author		Evandro Mugnol
@since		Out/2020
/*/
//-------------------------------------------------------------------
User Function ZK0Pos()

	Local lRet       := .T.
	Local oModel  	 := FWModelActive()
	Local nOperation := oModel:GetOperation()
	Local cCampo     := oModel:GetValue("FORMZK0", "ZK0_CODINT")

Return lRet
