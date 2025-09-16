#INCLUDE "TOTVS.CH"
#INCLUDE "FWBROWSE.CH"
#INCLUDE "FWMVCDEF.CH"

// Variáveis Estáticas
Static cTitulo := "Log de Importação - Pedidos Demander"

//--------------------------------------------------------------------------------------
/*/{Protheus.doc} LOG_DEM
@Type			: Função de Usuário
@Sample			: U_LOG_DEM()
@Description	: Função para visualizar log de importação dos pedidos da Demander
@Param			: Nenhum
@Return			: Nenhum
@ --------------|-----------------------------------------------------------------------
@Author			: Evandro Mugnol
@Since			: Dez/2024
@version		: Protheus 12.1.2310 e posteriores
@Comments		: Nenhum 
/*/
//--------------------------------------------------------------------------------------
User Function LOG_DEM()


	Local aArea := FWGetArea()
	Local oBrowse

	Private aRotina := MenuDef()

	// Instânciando FWMBrowse - Somente com dicionário de dados
	oBrowse := FWMBrowse():New()

	// Setando a tabela de cadastro de Autor/Interprete
	oBrowse:SetAlias("ZLD")

	// Setando a descrição da rotina
	oBrowse:SetDescription(cTitulo)

	// Adiciona legenda no Browse
	oBrowse:AddLegend('ZLD_SEVERI == "1"' , "GREEN"  , "Informativo")
	oBrowse:AddLegend('ZLD_SEVERI == "2"' , "YELLOW" , "Alerta"     )
	oBrowse:AddLegend('ZLD_SEVERI == "3"' , "RED"    , "Crítico"    )

	// Ativa a Browse
	oBrowse:Activate()

	FWRestArea(aArea)

Return


//-------------------------------------------------------------------
/*/{Protheus.doc} MenuDef
Definicao do aRotina (Menu funcional)
@author     Evandro
@since      Mai/2021
@return     N/A
@obs        N/A
/*/
//-------------------------------------------------------------------
Static Function MenuDef()

	Local aRotina := {}

	// Adicionando opções
	ADD OPTION aRotina TITLE "Visualizar" ACTION "VIEWDEF.LOG_DEM" OPERATION MODEL_OPERATION_VIEW	ACCESS 0 // OPERATION 2
	ADD OPTION aRotina TITLE "Pesquisar"  ACTION "PesqBrw"   	   OPERATION 1                   	ACCESS 0 // OPERATION 1

Return aRotina


//-------------------------------------------------------------------
/*/{Protheus.doc} ModelDef
Definicao do modelo do cadastro
@author     Evandro
@since      Dez/2024
@return     N/A
@obs        N/A
/*/
//-------------------------------------------------------------------
Static Function ModelDef()

	// Blocos de código nas validações
	//Local bPre 	:= {|| U_ZLDPre()} 	// Função chamada antes de abrir a tela
	//Local bPos 	:= {|| U_ZLDPos()} 	// Função chamada de validação ao clicar no Confirmar
	//Local bCommit := {|| U_ZLDCom()} 	// Função chamada no commit
	//Local bCancel := {|| U_ZLDCan()} 	// Função chamada ao cancelar

	// Criação do objeto do modelo de dados
	Local oModel := Nil

	// Criação da estrutura de dados utilizada na interface
	Local oStZLD := FWFormStruct(1, "ZLD")

	// Instanciando o modelo, não é recomendado colocar nome da user function (por causa do u_), respeitando 10 caracteres
	oModel := MPFormModel():New("LOGDEMM",/*bPre*/, /*bPos*/,/*bCommit*/,/*bCancel*/) 

	// Atribuindo formulários para o modelo
	oModel:AddFields("FORMZLD",/*cOwner*/,oStZLD)

	// Setando a chave primária da rotina
	oModel:SetPrimaryKey({"ZLD_FILIAL","ZLD_IDDEM"})

	// Adicionando descrição ao modelo
	oModel:SetDescription(cTitulo)

	// Setando a descrição do formulário
	oModel:GetModel("FORMZLD"):SetDescription(cTitulo)

Return oModel


//-------------------------------------------------------------------
/*/{Protheus.doc} ViewDef
Definicao da interface do cadastro
@author     Evandro
@since      Dez/2024
@return     N/A
@obs        N/A
/*/
//-------------------------------------------------------------------
Static Function ViewDef()

	// Criação do objeto do modelo de dados da interface do cadastro
	Local oModel := FWLoadModel("LOG_DEM")

	// Criação da estrutura de dados utilizada na interface do cadastro
	Local oStZLD := FWFormStruct(2, "ZLD")  // pode se usar um terceiro parâmetro para filtrar os campos exibidos { |cCampo| cCampo $ 'XXX_NOME|XXX_DATAI|'}

	// Criando oView como nulo
	Local oView := Nil

	// Criando a view que será o retorno da função e setando o modelo da rotina
	oView := FWFormView():New()
	oView:SetModel(oModel)

	// Atribuindo formulários para interface
	oView:AddField("VIEW_ZLD", oStZLD, "FORMZLD")

	// Criando um container com nome tela com 100%
	oView:CreateHorizontalBox("TELA",100)

	// Força o fechamento da janela na confirmação
	oView:SetCloseOnOk({||.F.})

	// O formulário da interface será colocado dentro do container
	oView:SetOwnerView("VIEW_ZLD","TELA")

Return oView
