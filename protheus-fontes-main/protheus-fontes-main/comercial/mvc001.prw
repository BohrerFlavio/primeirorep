#INCLUDE "PROTHEUS.CH"
#INCLUDE "FWMVCDEF.CH"

//-------------------------------------------------------------------
/*/{Protheus.doc} MVC001 - FUNÇÃO PRINCIPAL
Função para cadastro e manutenção de especificações de produtos
@author 	Evandro Mugnol
@since 		Out/2021
@version    1.0
/*/
//-------------------------------------------------------------------
User Function MVC001()

	// Função que retorna um objeto Browse de uma rotina.
	// A rotina deve implementar o método BrowseDef onde deve retornar o objeto de browse.
	// Retorno: Objeto FWMBrowse gerado pela função Browsedef da rotina.
	Local oBrowse := FwLoadBrw("MVC001")

	// Função que retorna o array com os dados do menu da rotina.
	Private aRotina := FwLoadMenuDef("MVC001")

	oBrowse:Activate()

Return


//-----------------------------------------------------------------------------
/*/{Protheus.doc} BrowseDef - BROWSER
Funcao de chamada do Browse
@author     Evandro Mugnol
@since      Out/2021
@version    1.0
/*/
//------------------------------------------------------------------------------
Static Function BrowseDef()

	// Instanciação do Browser
	Local oBrowse := FwMBrowse():New()

	// Definição da tabela principal e título
	oBrowse:SetAlias("Z02")
	oBrowse:SetDescription("Especificações de Produtos")

	// Demais definições do Browser

Return(oBrowse)


//-----------------------------------------------------------------------------
/*/{Protheus.doc} MenuDef  - OPERAÇÕES
Funcao de chamada do menu
@author     Evandro Mugnol
@since      Out/2021
@version    1.0
/*/
//-----------------------------------------------------------------------------
Static Function MenuDef()
	Local nX      := 0
	Local aRotina := {}
	Local aRotAux := FwMVCMenu("MVC001") 		// Retorna as opções padrões para o MenuDef de uma rotina em MVC.
												// Opções padrões:
												// * Visualizar
												// * Incluir
												// * Alterar
												// * Excluir
												// * Imprimir
												// * Cópia

	// Adiciona a opção de Pesquisa
	ADD OPTION aRotina TITLE "Pesquisar" ACTION "VIEWDEF.MVC001" OPERATION 1 ACCESS 0

	// Adiciona as demais operações
	For nX := 1 To Len(aRotAux)
		aAdd(aRotina, aRotAux[nX])
	Next nX

Return(aRotina)


//-----------------------------------------------------------------------------
/*/{Protheus.doc} ModelDef - REGRA DE NEGÓCIOS
Funcao de definição das regras
@author     Evandro Mugnol
@since      Out/2021
@version    1.0
/*/
//------------------------------------------------------------------------------
Static Function ModelDef()

	// Blocos de código nas validações
	//Local bPre 	:= {|| U_Z02Pre()} 	// Função chamada antes de abrir a tela
	//Local bPos 	:= {|| U_Z02Pos()} 	// Função chamada de validação ao clicar no Confirmar
	//Local bCommit := {|| U_Z02Com()} 	// Função chamada no commit
	//Local bCancel := {|| U_Z02Can()} 	// Função chamada ao cancelar

	// Instancia o modelo
	Local oModel := MPFormModel():New("MVC001M", /*bPre*/, /*bPos*/, /*bCommit*/, /*bCancel*/)

	// Instancia o submodelo
	Local oStruZ02 := FwFormStruct(1, "Z02")

	// Define o submodelo como Field
	oModel:AddFields("MD_MASTERZ02", /*cOwner*/, oStruZ02)

	// Descrição do modelo
	oModel:SetDescription("Cadastro de Especificações de Produtos")

	// Descrição do submodelo
	oModel:GetModel("MD_MASTERZ02"):SetDescription("Especificações de Produtos")

    // Demais definições da regra de negócios

Return(oModel)


//-----------------------------------------------------------------------------
/*/{Protheus.doc} ViewDef - INTERFACE GRÁFICA
Interface do cadastro de especificações de produtos
@author     Evandro Mugnol
@since      Out/2021
@version    1.0
/*/
//------------------------------------------------------------------------------
Static Function ViewDef()

    // Instancia a view
    Local oView := FwFormView():New()

    // Instancia a subview
    Local oStruZ02 := FwFormStruct(2, "Z02")

    // Recebe o modelo de dados
    Local oModel := FwLoadModel("MVC001")

    // Remove campos
    oStruZ02:RemoveField("Z02_FILIAL")

    // Indica o modelo da view
    oView:SetModel(oModel)

    // Cria estrutura visual de campos
    oView:AddField("VW_MASTERZ02", oStruZ02, "MD_MASTERZ02") 	// View, Struct, Model

    // Cria BOX horizontal
    oView:CreateHorizontalBox("BOX_TOTAL", 100) 				// BOX, Percentual

	// Colocando título do formulário
	oView:EnableTitleView("VW_MASTERZ02", "Preencha os campos abaixo para serem utilizados na tabela de custos dos produtos")  

	// Força o fechamento da janela na confirmação
	oView:SetCloseOnOk({||.F.})

    // Relaciona o BOX com a estrutura visual
    oView:SetOwnerView("VW_MASTERZ02", "BOX_TOTAL") 			// View, BOX

Return (oView)
