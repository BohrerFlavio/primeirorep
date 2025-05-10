#INCLUDE "PROTHEUS.CH"
#INCLUDE "FWMVCDEF.CH"

// Variáveis Estáticas
Static cTitulo := "Segmentos de Fornecedores"

/*/{Protheus.doc} STI_ZLQ
Função para cadastro e manutenção de segmentos de fornecedores do protheus - Modelo 1 em MVC
@author 	Evandro Mugnol
@since 		09/06/2020
@return 	Nil, Função não tem retorno
@obs 		Não se pode executar função MVC dentro do fórmulas
/*/

User Function STI_ZLQ()

	Local aArea := GetArea()
	Local oBrowse

	Private aRotina := MenuDef()

	// Instânciando FWMBrowse - Somente com dicionário de dados
	oBrowse := FWMBrowse():New()

	// Setando a tabela de cadastro
	oBrowse:SetAlias("ZLQ")

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
	ADD OPTION aRotina TITLE "Visualizar" ACTION "VIEWDEF.STI_ZLQ" 	OPERATION MODEL_OPERATION_VIEW	 ACCESS 0 // OPERATION 2
	ADD OPTION aRotina TITLE "Incluir"    ACTION "VIEWDEF.STI_ZLQ" 	OPERATION MODEL_OPERATION_INSERT ACCESS 0 // OPERATION 3
	ADD OPTION aRotina TITLE "Alterar"    ACTION "VIEWDEF.STI_ZLQ" 	OPERATION MODEL_OPERATION_UPDATE ACCESS 0 // OPERATION 4
	ADD OPTION aRotina TITLE "Excluir"    ACTION "VIEWDEF.STI_ZLQ" 	OPERATION MODEL_OPERATION_DELETE ACCESS 0 // OPERATION 5

Return aRotina


/*====================================================================*
| Função:  		ModelDef                                              |
| Descrição:	Criação do modelo de dados MVC                        |
*====================================================================*/
Static Function ModelDef()

	// Blocos de código nas validações
	//Local bPre 	:= {|| U_ZLQPre()} 	// Função chamada antes de abrir a tela
	//Local bPos 	:= {|| U_ZLQPos()} 	// Função chamada de validação ao clicar no Confirmar
	//Local bCommit := {|| U_ZLQCom()} 	// Função chamada no commit
	//Local bCancel := {|| U_ZLQCan()} 	// Função chamada ao cancelar

	// Criação do objeto do modelo de dados
	Local oModel := Nil

	// Criação da estrutura de dados utilizada na interface
	Local oStZLQ := FWFormStruct(1, "ZLQ")

	// Instanciando o modelo, não é recomendado colocar nome da user function (por causa do u_), respeitando 10 caracteres
	oModel := MPFormModel():New("STIZLQM",/*bPre*/, /*bPos*/,/*bCommit*/,/*bCancel*/) 

	// Atribuindo formulários para o modelo
	oModel:AddFields("FORMZLQ",/*cOwner*/,oStZLQ)

	// Setando a chave primária da rotina
	oModel:SetPrimaryKey({"ZLQ_FILIAL","ZLQ_CODSEG"})

	// Adicionando descrição ao modelo
	oModel:SetDescription("Cadastro de " + cTitulo)

	// Setando a descrição do formulário
	oModel:GetModel("FORMZLQ"):SetDescription("Formulário do Cadastro " + cTitulo)

Return oModel


/*====================================================================*
| Função:  		ViewDef                                               |
| Descrição:	Criação da visão MVC                                  |
*====================================================================*/
Static Function ViewDef()

	// Criação do objeto do modelo de dados da interface do cadastro
	Local oModel := FWLoadModel("STI_ZLQ")

	// Criação da estrutura de dados utilizada na interface do cadastro
	Local oStZLQ := FWFormStruct(2, "ZLQ")  // pode se usar um terceiro parâmetro para filtrar os campos exibidos { |cCampo| cCampo $ 'XXX_NOME|XXX_DATAI|'}

	// Criando oView como nulo
	Local oView := Nil

	// Criando a view que será o retorno da função e setando o modelo da rotina
	oView := FWFormView():New()
	oView:SetModel(oModel)

	// Atribuindo formulários para interface
	oView:AddField("VIEW_ZLQ", oStZLQ, "FORMZLQ")

	// Criando um container com nome tela com 100%
	oView:CreateHorizontalBox("TELA",100)

	// Colocando título do formulário
	oView:EnableTitleView('VIEW_ZLQ', 'Preencha os campos abaixo para serem considerados no cadastro de fornecedores -> Outras Opções -> Segmentos x Fornecedor' )  

	// Força o fechamento da janela na confirmação
	oView:SetCloseOnOk({||.F.})

	// O formulário da interface será colocado dentro do container
	oView:SetOwnerView("VIEW_ZLQ","TELA")

Return oView


//-------------------------------------------------------------------
/*/{Protheus.doc} ZLQPos
Função chamada no clique do botão Ok do Modelo de Dados (pós-validação)
@author		Evandro Mugnol
@since		09/06/2020
/*/
//-------------------------------------------------------------------
User Function ZLQPos()

	Local lRet       := .T.
	Local oModel  	 := FWModelActive()
	Local nOperation := oModel:GetOperation()
	Local cCampo     := oModel:GetValue("FORMZLQ", "ZLQ_CODSEG")

Return lRet
