#INCLUDE "TOTVS.CH"
#INCLUDE "FWMVCDEF.CH"

// Variáveis Estáticas
Static cTitulo := "Logs de Erros - Meios de Pagamentos"

/*/{Protheus.doc} STI_ZK3C
Função para visualizar logs de erros referente aos métodos
@author 	Evandro Mugnol
@since 		Nov/2020
@return 	Nil, Função não tem retorno
@obs 		Não se pode executar função MVC dentro do fórmulas
/*/

User Function STI_ZK3C()

	Local aArea := GetArea()
	Local oBrowse

	Private aRotina := MenuDef()

	// Instânciando FWMBrowse - Somente com dicionário de dados
	oBrowse := FWMBrowse():New()

	// Setando a tabela de cadastro
	oBrowse:SetAlias("ZK3")

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
	ADD OPTION aRotina TITLE "Visualizar" ACTION "VIEWDEF.STI_ZK3C" OPERATION MODEL_OPERATION_VIEW	 ACCESS 0 // OPERATION 2

Return aRotina

/*====================================================================*
| Função:  		ModelDef                                              |
| Descrição:	Criação do modelo de dados MVC                        |
*====================================================================*/
Static Function ModelDef()

	// Blocos de código nas validações
	//Local bPre 	:= {|| U_ZK3CPre()} 	// Função chamada antes de abrir a tela
	//Local bPos 	:= {|| U_ZK3CPos()} 	// Função chamada de validação ao clicar no Confirmar
	//Local bCommit := {|| U_ZK3CCom()} 	// Função chamada no commit
	//Local bCancel := {|| U_ZK3CCan()} 	// Função chamada ao cancelar

	// Criação do objeto do modelo de dados
	Local oModel := Nil

	// Criação da estrutura de dados utilizada na interface
	Local oStZK3 := FWFormStruct(1, "ZK3")

	// Instanciando o modelo, não é recomendado colocar nome da user function (por causa do u_), respeitando 10 caracteres
	oModel := MPFormModel():New("STIZK3CM",/*bPre*/, /*bPos*/,/*bCommit*/,/*bCancel*/)

	// Atribuindo formulários para o modelo
	oModel:AddFields("FORMZK3",/*cOwner*/,oStZK3)

	// Setando a chave primária da rotina
	oModel:SetPrimaryKey({"ZK3_FILIAL","ZK3_DOC","ZK3_SERIE","ZK3_CLIENTE","ZK3_LOJA","ZK3_SEQ"})

	// Adicionando descrição ao modelo
	oModel:SetDescription(cTitulo)

	// Setando a descrição do formulário
	oModel:GetModel("FORMZK3"):SetDescription(cTitulo)

Return oModel

/*====================================================================*
| Função:  		ViewDef                                               |
| Descrição:	Criação da visão MVC                                  |
*====================================================================*/
Static Function ViewDef()

	// Criação do objeto do modelo de dados da interface do cadastro
	Local oModel := FWLoadModel("STI_ZK3C")

	// Criação da estrutura de dados utilizada na interface do cadastro
	Local oStZK3 := FWFormStruct(2, "ZK3")  // pode se usar um terceiro parâmetro para filtrar os campos exibidos { |cCampo| cCampo $ 'XXX_NOME|XXX_DATAI|'}

	// Criando oView como nulo
	Local oView := Nil

	// Criando a view que será o retorno da função e setando o modelo da rotina
	oView := FWFormView():New()
	oView:SetModel(oModel)

	// Atribuindo formulários para interface
	oView:AddField("VIEW_ZK3", oStZK3, "FORMZK3")

	// Criando um container com nome tela com 100%
	oView:CreateHorizontalBox("TELA",100)

	// Força o fechamento da janela na confirmação
	oView:SetCloseOnOk({||.T.})

	// O formulário da interface será colocado dentro do container
	oView:SetOwnerView("VIEW_ZK3","TELA")

Return oView
