#INCLUDE "PROTHEUS.CH"
#INCLUDE "FWMVCDEF.CH"

// Variáveis Estáticas
Static cTitulo := "Histórico Antes Importação de Saldos e Valores da Tabela SN3"

/*/{Protheus.doc} STI_ATF1
Função para mostrar histórico antes da importação da taxa anual depreciação importada do Excel (.CSV)
@author 	Evandro Mugnol
@since 		26/05/2020
@return 	Nil, Função não tem retorno
@obs 		Não se pode executar função MVC dentro do fórmulas
/*/

User Function STI_ATF1()

	Local aArea := GetArea()
	Local oBrowse

	Private aRotina := MenuDef()

	// Instânciando FWMBrowse - Somente com dicionário de dados
	oBrowse := FWMBrowse():New()

	// Setando a tabela de cadastro
	oBrowse:SetAlias("SZ0")

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
	ADD OPTION aRotina TITLE "Visualizar" ACTION "VIEWDEF.STI_ATF1" OPERATION MODEL_OPERATION_VIEW	 ACCESS 0 // OPERATION 2

Return aRotina

/*====================================================================*
| Função:  		ModelDef                                              |
| Descrição:	Criação do modelo de dados MVC                        |
*====================================================================*/
Static Function ModelDef()

	// Blocos de código nas validações
	//Local bPre 	:= {|| U_ATF1Pre()} 	// Função chamada antes de abrir a tela
	//Local bPos 	:= {|| U_ATF1Pos()} 	// Função chamada de validação ao clicar no Confirmar
	//Local bCommit := {|| U_ATF1Com()} 	// Função chamada no commit
	//Local bCancel := {|| U_ATF1Can()} 	// Função chamada ao cancelar

	// Criação do objeto do modelo de dados
	Local oModel := Nil

	// Criação da estrutura de dados utilizada na interface
	Local oStSZ0 := FWFormStruct(1, "SZ0")

	// Instanciando o modelo, não é recomendado colocar nome da user function (por causa do u_), respeitando 10 caracteres
	oModel := MPFormModel():New("STIATF1M",/*bPre*/, /*bPos*/,/*bCommit*/,/*bCancel*/)

	// Atribuindo formulários para o modelo
	oModel:AddFields("FORMSZ0",/*cOwner*/,oStSZ0)

	// Setando a chave primária da rotina
	oModel:SetPrimaryKey({"Z0_FILIAL","Z0_CBASE","Z0_ITEM"})

	// Adicionando descrição ao modelo
	oModel:SetDescription(cTitulo)

	// Setando a descrição do formulário
	oModel:GetModel("FORMSZ0"):SetDescription(cTitulo)

Return oModel

/*====================================================================*
| Função:  		ViewDef                                               |
| Descrição:	Criação da visão MVC                                  |
*====================================================================*/
Static Function ViewDef()

	// Criação do objeto do modelo de dados da interface do cadastro
	Local oModel := FWLoadModel("STI_ATF1")

	// Criação da estrutura de dados utilizada na interface do cadastro
	Local oStSZ0 := FWFormStruct(2, "SZ0")  // pode se usar um terceiro parâmetro para filtrar os campos exibidos { |cCampo| cCampo $ 'XXX_NOME|XXX_DATAI|'}

	// Criando oView como nulo
	Local oView := Nil

	// Criando a view que será o retorno da função e setando o modelo da rotina
	oView := FWFormView():New()
	oView:SetModel(oModel)

	// Atribuindo formulários para interface
	oView:AddField("VIEW_SZ0", oStSZ0, "FORMSZ0")

	// Criando um container com nome tela com 100%
	oView:CreateHorizontalBox("TELA",100)

	// Força o fechamento da janela na confirmação
	oView:SetCloseOnOk({||.T.})

	// O formulário da interface será colocado dentro do container
	oView:SetOwnerView("VIEW_SZ0","TELA")

Return oView
