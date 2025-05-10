#INCLUDE "TOTVS.CH"
#INCLUDE "FWMVCDEF.CH"

//-------------------------------------------------------------------
/*/{Protheus.doc} MVC003 - FUNÇÃO PRINCIPAL
Rotina de manutenção no cadastro de tabelas de custos dos produtos
@author     Evandro Mugnol
@since      Set/2021
@version    1.0
/*/
//-------------------------------------------------------------------
User Function MVC003()

	// Função que retorna um objeto Browse de uma rotina.
	// A rotina deve implementar o método BrowseDef onde deve retornar o objeto de browse.
	// Retorno: Objeto FWMBrowse gerado pela função Browsedef da rotina.
    Local oBrowse := FwLoadBrw("MVC003")
    
	// Função que retorna o array com os dados do menu da rotina.
	Private aRotina := FwLoadMenuDef("MVC003")

    oBrowse:Activate()

Return


//-----------------------------------------------------------------------------
/*/{Protheus.doc} BrowseDef - BROWSER
Funcao de chamada do Browse
@author     Evandro Mugnol
@since      Set/2021
@version    1.0
/*/
//------------------------------------------------------------------------------
Static Function BrowseDef()
    // Instanciação do Browser
    Local oBrowse := FwMBrowse():New()

    // Definição da tabela principal e título
    oBrowse:SetAlias("Z05")
    oBrowse:SetDescription("Tabela de Custos dos Produtos")

    // Demais definições do Browser

Return(oBrowse)


//-----------------------------------------------------------------------------
/*/{Protheus.doc} MenuDef  - OPERAÇÕES
Funcao de chamada do menu
@author     Evandro Mugnol
@since      Set/2021
@version    1.0
/*/
//-----------------------------------------------------------------------------
Static Function MenuDef()
    Local nX      := 0
    Local aRotina := {}
    Local aRotAux := FwMVCMenu("MVC003") 		// Retorna as opções padrões para o MenuDef de uma rotina em MVC.
												// Opções padrões:
												// * Visualizar
												// * Incluir
												// * Alterar
												// * Excluir
												// * Imprimir
												// * Cópia

    // Adiciona a opção de Pesquisa
    ADD OPTION aRotina TITLE "Pesquisar" ACTION "VIEWDEF.MVC003" OPERATION 1 ACCESS 0

    // Adiciona as demais operações
    For nX := 1 To Len(aRotAux)
	    If AllTrim(UPPER(cUserName)) == UPPER("Administrador")      .Or. ;
	       AllTrim(UPPER(cUserName)) == UPPER("ubirajara.munhoz")   .Or. ;
	       AllTrim(UPPER(cUserName)) == UPPER("rodrigo.abelin")     .Or. ;
           AllTrim(UPPER(cUserName)) == UPPER("henrique.jardim")    .Or. ;
           AllTrim(UPPER(cUserName)) == UPPER("wandrize.matos")     .Or. ;
           AllTrim(UPPER(cUserName)) == UPPER("ana.lucia")
           
            aAdd(aRotina, aRotAux[nX])
        Else
            aAdd(aRotina, aRotAux[nX])      // Somente habilita botão 'Visualizar'
            Exit
        EndIf
    Next nX

Return(aRotina)


//-----------------------------------------------------------------------------
/*/{Protheus.doc} ModelDef - REGRA DE NEGÓCIOS
Funcao de definição das regras
@author     Evandro Mugnol
@since      Set/2021
@version    1.0
/*/
//------------------------------------------------------------------------------
Static Function ModelDef()

	// Blocos de código nas validações
	//Local bPre 	:= {|| U_Z05Pre()} 	// Função chamada antes de abrir a tela
	//Local bPos 	:= {|| U_Z05Pos()} 	// Função chamada de validação ao clicar no Confirmar
	//Local bCommit := {|| U_Z05Com()} 	// Função chamada no commit
	//Local bCancel := {|| U_Z05Can()} 	// Função chamada ao cancelar

    // Instancia o modelo
    Local oModel := MPFormModel():New("MVC003M", /*bPre*/, /*bPos*/, /*bCommit*/, /*bCancel*/)

    // Instancia os submodelos
    Local oStruZ05 := FwFormStruct(1, "Z05")		// Tabela de Custos de Produtos
    Local oStruZ06 := FwFormStruct(1, "Z06")		// Especificação de Produto
    Local oStruZ07 := FwFormStruct(1, "Z07")		// Preço de Custo X Especificação de Produto

    // Define se os submodelos serão Field ou Grid
    oModel:AddFields("MD_MASTERZ05", /*cOwner*/, oStruZ05)
    oModel:AddGrid("MD_DETAILZ06", "MD_MASTERZ05", oStruZ06)
    oModel:AddGrid("MD_DETAILZ07", "MD_DETAILZ06", oStruZ07)

    // Defeine a relação entre os submodelos (CSUBMODELO, {ARELATION1, ARELATION2}, CINDEXFILHO)
    oModel:SetRelation("MD_DETAILZ06", {{"Z06_FILIAL", "FwXFilial('Z06')"}, {"Z06_CODTAB", "Z05_CODTAB"}}, Z06->(IndexKey(1)))
    oModel:SetRelation("MD_DETAILZ07", {{"Z07_FILIAL", "FwXFilial('Z07')"}, {"Z07_CODTAB", "Z05_CODTAB"}, {"Z07_CODESP", "Z06_CODESP"}}, Z07->(IndexKey(1)))

    // Controle de não repetição de dados
    oModel:GetModel("MD_DETAILZ06"):SetUniqueLine({"Z06_CODESP"})
    oModel:GetModel("MD_DETAILZ07"):SetUniqueLine({"Z07_CODCUS"})

    // Descrição do modelo
    oModel:SetDescription("Tabela de Custos dos Produtos")

    // Descrição dos submodelos
    oModel:GetModel("MD_MASTERZ05"):SetDescription("Custos dos Produtos")
    oModel:GetModel("MD_DETAILZ06"):SetDescription("Especificações")
    oModel:GetModel("MD_DETAILZ07"):SetDescription("Produtos para Custos")

    // Demais definições da regra de negócios

Return (oModel)


//-----------------------------------------------------------------------------
/*/{Protheus.doc} ViewDef - INTERFACE GRÁFICA
Interface do cadastro de tabelas de custos dos produtos
@author     Evandro Mugnol
@since      Set/2021
@version    1.0
/*/
//------------------------------------------------------------------------------
Static Function ViewDef()

    // Instancia a View
    Local oView := FwFormView():New()

    // Instancia as SubViews
    Local oStruZ05 := FwFormStruct(2, "Z05")
    Local oStruZ06 := FwFormStruct(2, "Z06")
    Local oStruZ07 := FwFormStruct(2, "Z07")

    // Recebe o modelo de dados
    Local oModel := FwLoadModel("MVC003")

    // Indica o modelo da view
    oView:SetModel(oModel)

    // Remove campos
    oStruZ05:RemoveField("Z05_FILIAL")
    oStruZ06:RemoveField("Z06_FILIAL")
    oStruZ06:RemoveField("Z06_CODTAB")
    oStruZ07:RemoveField("Z07_FILIAL")
    oStruZ07:RemoveField("Z07_CODTAB")
    oStruZ07:RemoveField("Z07_CODESP")

    // Cria estrutura visual de campos
    oView:AddField("VW_MASTERZ05", oStruZ05, "MD_MASTERZ05")
    oView:AddGrid("VW_DETAILZ06", oStruZ06, "MD_DETAILZ06")
    oView:AddGrid("VW_DETAILZ07", oStruZ07, "MD_DETAILZ07")

    // Cria opção de pesquisa nos grids
	oView:SetViewProperty("VW_DETAILZ06", "GRIDSEEK", {.T.})
	oView:SetViewProperty("VW_DETAILZ07", "GRIDSEEK", {.T.})

	// Cria os BOXES para receber algum elemento da view
    oView:CreateHorizontalBox("BOX_SUPERIOR", 15)
    oView:CreateHorizontalBox("BOX_INFERIOR", 85)

    oView:CreateVerticalBox("BOX_INFERIOR_ESQUERDO", 45, "BOX_INFERIOR")
    oView:CreateVerticalBox("BOX_INFERIOR_DIREITO", 55, "BOX_INFERIOR")

    // Relaciona os BOXES com as estruturas visuais
    oView:SetOwnerView("VW_MASTERZ05", "BOX_SUPERIOR")
    oView:SetOwnerView("VW_DETAILZ06", "BOX_INFERIOR_ESQUERDO")
    oView:SetOwnerView("VW_DETAILZ07", "BOX_INFERIOR_DIREITO")

    // Define os títulos da subviews
    oView:EnableTitleView("VW_DETAILZ06", "Especificações")
    oView:EnableTitleView("VW_DETAILZ07", "Produtos para Custos")

    // Demais definições de interface gráfica

Return (oView)
