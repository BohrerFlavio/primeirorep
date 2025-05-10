#INCLUDE "TOTVS.CH"
#INCLUDE "FWMVCDEF.CH"

// Variáveis Estáticas
Static cTitulo := "Retorno de Dados Referente Checkout"

/*/{Protheus.doc} STI_ZK2C
Função para visualizar dados do retorno do método checkout
@author 	Evandro Mugnol
@since 		Nov/2020
@return 	Nil, Função não tem retorno
@obs 		Não se pode executar função MVC dentro do fórmulas
/*/

User Function STI_ZK2C()

	Local aArea := GetArea()
	Local oBrowse

	Private aRotina := MenuDef()

	// Instânciando FWMBrowse - Somente com dicionário de dados
	oBrowse := FWMBrowse():New()

	// Setando a tabela de cadastro
	oBrowse:SetAlias("ZK2")

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
	ADD OPTION aRotina TITLE "Visualizar" ACTION "VIEWDEF.STI_ZK2C"		OPERATION MODEL_OPERATION_VIEW	 ACCESS 0
    ADD OPTION aRotina TITLE "Histórico"  ACTION "U_STI_HIST(Substr(ZK2->ZK2_REFID,1,9), Substr(ZK2->ZK2_REFID,10,3))"	OPERATION MODEL_OPERATION_VIEW ACCESS 0

Return aRotina

/*====================================================================*
| Função:  		ModelDef                                              |
| Descrição:	Criação do modelo de dados MVC                        |
*====================================================================*/
Static Function ModelDef()

	// Blocos de código nas validações
	//Local bPre 	:= {|| U_ZK2CPre()} 	// Função chamada antes de abrir a tela
	//Local bPos 	:= {|| U_ZK2CPos()} 	// Função chamada de validação ao clicar no Confirmar
	//Local bCommit := {|| U_ZK2CCom()} 	// Função chamada no commit
	//Local bCancel := {|| U_ZK2CCan()} 	// Função chamada ao cancelar

	// Criação do objeto do modelo de dados
	Local oModel := Nil

	// Criação da estrutura de dados utilizada na interface
	Local oStZK2 := FWFormStruct(1, "ZK2")

	// Instanciando o modelo, não é recomendado colocar nome da user function (por causa do u_), respeitando 10 caracteres
	oModel := MPFormModel():New("STIZK2CM",/*bPre*/, /*bPos*/,/*bCommit*/,/*bCancel*/)

	// Atribuindo formulários para o modelo
	oModel:AddFields("FORMZK2",/*cOwner*/,oStZK2)

	// Setando a chave primária da rotina
	oModel:SetPrimaryKey({"ZK2_FILIAL","ZK2_CHKID","ZK2_CODINT"})

	// Adicionando descrição ao modelo
	oModel:SetDescription(cTitulo)

	// Setando a descrição do formulário
	oModel:GetModel("FORMZK2"):SetDescription(cTitulo)

Return oModel

/*====================================================================*
| Função:  		ViewDef                                               |
| Descrição:	Criação da visão MVC                                  |
*====================================================================*/
Static Function ViewDef()

	// Criação do objeto do modelo de dados da interface do cadastro
	Local oModel := FWLoadModel("STI_ZK2C")

	// Criação da estrutura de dados utilizada na interface do cadastro
	Local oStZK2 := FWFormStruct(2, "ZK2")  // pode se usar um terceiro parâmetro para filtrar os campos exibidos { |cCampo| cCampo $ 'XXX_NOME|XXX_DATAI|'}

	// Criando oView como nulo
	Local oView := Nil

	// Criando a view que será o retorno da função e setando o modelo da rotina
	oView := FWFormView():New()
	oView:SetModel(oModel)

	// Atribuindo formulários para interface
	oView:AddField("VIEW_ZK2", oStZK2, "FORMZK2")

	// Criando um container com nome tela com 100%
	oView:CreateHorizontalBox("TELA",100)

	// Força o fechamento da janela na confirmação
	oView:SetCloseOnOk({||.T.})

	// O formulário da interface será colocado dentro do container
	oView:SetOwnerView("VIEW_ZK2","TELA")

Return oView
