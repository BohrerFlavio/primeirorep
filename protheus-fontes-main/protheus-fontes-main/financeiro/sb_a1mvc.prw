#INCLUDE "PROTHEUS.CH"
#INCLUDE "FWMVCDEF.CH"           
#INCLUDE "FWMBROWSE.CH"

// Variáveis Estáticas
Static cTitulo := "Cadastro de Clientes"

/*/{Protheus.doc} SB_A1MVC
Cadastro de Clientes em MVC para ser utilizado na função SBA1VEN()
@author 	Evandro Mugnol
@since 		07/08/2016
@version 	1.0
@obs 		Não se pode executar função MVC dentro do fórmulas
/*/

User Function SB_A1MVC()
Local aArea   := GetArea()
Local oBrowse
	
// Instânciando FWMBrowse - Somente com dicionário de dados
oBrowse := FWMBrowse():New()
	
// Setando a tabela de cadastro de clientes
oBrowse:SetAlias("SA1")
	
// Setando a descrição da rotina
oBrowse:SetDescription(cTitulo)

// Ativa a Browse
oBrowse:Activate()
	
RestArea(aArea)

Return Nil


//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Função MenuDef para criação do menu MVC                                ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
Static Function MenuDef()

Local aRot := {}
	
// Adicionando opções
ADD OPTION aRot TITLE 'Pesquisar'  ACTION 'VIEWDEF.SB_A1MVC' OPERATION MODEL_OPERATION_VIEW	 ACCESS 0 	// OPERATION 1
ADD OPTION aRot TITLE 'Visualizar' ACTION 'VIEWDEF.SB_A1MVC' OPERATION 1					   	 ACCESS 0 	// OPERATION 2
ADD OPTION aRot TITLE 'Incluir'    ACTION 'VIEWDEF.SB_A1MVC' OPERATION MODEL_OPERATION_INSERT ACCESS 0 	// OPERATION 3
ADD OPTION aRot TITLE 'Alterar'    ACTION 'VIEWDEF.SB_A1MVC' OPERATION MODEL_OPERATION_UPDATE ACCESS 0 	// OPERATION 4
ADD OPTION aRot TITLE 'Excluir'    ACTION 'VIEWDEF.SB_A1MVC' OPERATION MODEL_OPERATION_DELETE ACCESS 0 	// OPERATION 5

Return aRot


//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Função ModelDef para criação do modelo de dados MVC                    ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
Static Function ModelDef()

// Criação do objeto do modelo de dados
Local oModel := Nil
	
// Criação da estrutura de dados utilizada na interface
Local oStSA1 := FWFormStruct(1, "SA1")
	
// Instanciando o modelo, não é recomendado colocar nome da user function (por causa do u_), respeitando 10 caracteres
oModel := MPFormModel():New("M_A1MVC",/*bPre*/, /*bPos*/,/*bCommit*/,/*bCancel*/) 
	
// Atribuindo formulários para o modelo
oModel:AddFields("FORMSA1",/*cOwner*/,oStSA1)
	
// Setando a chave primária da rotina
oModel:SetPrimaryKey({"A1_FILIAL","A1_COD","A1_LOJA"})
	
// Adicionando descrição ao modelo
oModel:SetDescription("Modelo de Dados do Cadastro " + cTitulo)
	
// Setando a descrição do formulário
oModel:GetModel("FORMSA1"):SetDescription("Formulário do Cadastro " + cTitulo)

Return oModel


//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Função ViewDef para criação da visão MVC                               ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
Static Function ViewDef()

// Criação do objeto do modelo de dados da Interface do Cadastro de Autor/Interprete
Local oModel := FWLoadModel("SB_A1MVC")
	
// Criação da estrutura de dados utilizada na interface do cadastro de Autor
Local oStSA1 := FWFormStruct(2, "SA1")  // pode se usar um terceiro parâmetro para filtrar os campos exibidos { |cCampo| cCampo $ "A1_NOME|A1_TEL|"}
	
// Criando oView como nulo
Local oView := Nil

// Criando a view que será o retorno da função e setando o modelo da rotina
oView := FWFormView():New()
oView:SetModel(oModel)
	
// Atribuindo formulários para interface
oView:AddField("VIEW_SA1", oStSA1, "FORMSA1")
	
// Criando um container com nome tela com 100%
oView:CreateHorizontalBox("TELA",100)
	
// Colocando título do formulário
oView:EnableTitleView("VIEW_SA1", "Dados do Cadastro de Clientes")  
	
// Força o fechamento da janela na confirmação
oView:SetCloseOnOk({||.T.})
	
// O formulário da interface será colocado dentro do container
oView:SetOwnerView("VIEW_SA1","TELA")

Return oView
