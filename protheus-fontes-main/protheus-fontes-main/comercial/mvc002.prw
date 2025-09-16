#INCLUDE "PROTHEUS.CH"
#INCLUDE "FWMVCDEF.CH"

//-------------------------------------------------------------------
/*/{Protheus.doc} MVC002 - FUNÇÃO PRINCIPAL
Função para cadastro e manutenção de produtos para custos
@author 	Evandro Mugnol
@since 		Out/2021
@version    1.0
/*/
//-------------------------------------------------------------------
User Function MVC002()

	// Função que retorna um objeto Browse de uma rotina.
	// A rotina deve implementar o método BrowseDef onde deve retornar o objeto de browse.
	// Retorno: Objeto FWMBrowse gerado pela função Browsedef da rotina.
	Local oBrowse := FwLoadBrw("MVC002")

	// Função que retorna o array com os dados do menu da rotina.
	Private aRotina := FwLoadMenuDef("MVC002")

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
	oBrowse:SetAlias("Z03")
	oBrowse:SetDescription("Produtos para Custos")

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
	Local aRotAux := FwMVCMenu("MVC002") 		// Retorna as opções padrões para o MenuDef de uma rotina em MVC.
												// Opções padrões:
												// * Visualizar
												// * Incluir
												// * Alterar
												// * Excluir
												// * Imprimir
												// * Cópia

	// Adiciona a opção de Pesquisa
	ADD OPTION aRotina TITLE "Pesquisar" ACTION "VIEWDEF.MVC002" OPERATION 1 ACCESS 0

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
	//Local bPre 	:= {|| U_Z03Pre()} 	// Função chamada antes de abrir a tela
	//Local bPos 	:= {|| U_Z03Pos()} 	// Função chamada de validação ao clicar no Confirmar
	//Local bCommit := {|| U_Z03Com()} 	// Função chamada no commit
	//Local bCancel := {|| U_Z03Can()} 	// Função chamada ao cancelar

	// Instancia o modelo
	Local oModel := MPFormModel():New("MVC002M", /*bPre*/, /*bPos*/, /*bCommit*/, /*bCancel*/)

	// Instancia o submodelo
	Local oStruZ03 := FwFormStruct(1, "Z03")

	// Define o submodelo como Field
	oModel:AddFields("MD_MASTERZ03", /*cOwner*/, oStruZ03)

	// Descrição do modelo
	oModel:SetDescription("Cadastro de Produtos para Custos")

	// Descrição do submodelo
	oModel:GetModel("MD_MASTERZ03"):SetDescription("Produtos para Custos")

    // Demais definições da regra de negócios

Return(oModel)


//-----------------------------------------------------------------------------
/*/{Protheus.doc} ViewDef - INTERFACE GRÁFICA
Interface do cadastro de produtos para custos
@author     Evandro Mugnol
@since      Out/2021
@version    1.0
/*/
//------------------------------------------------------------------------------
Static Function ViewDef()

    // Instancia a view
    Local oView := FwFormView():New()

    // Instancia a subview
    Local oStruZ03 := FwFormStruct(2, "Z03")

    // Recebe o modelo de dados
    Local oModel := FwLoadModel("MVC002")

    // Remove campos
    oStruZ03:RemoveField("Z03_FILIAL")

    // Indica o modelo da view
    oView:SetModel(oModel)

    // Cria estrutura visual de campos
    oView:AddField("VW_MASTERZ03", oStruZ03, "MD_MASTERZ03") 	// View, Struct, Model

    // Cria BOX horizontal
    oView:CreateHorizontalBox("BOX_TOTAL", 100) 				// BOX, Percentual

	// Colocando título do formulário
	oView:EnableTitleView("VW_MASTERZ03", "Preencha os campos abaixo para serem utilizados na tabela de custos dos produtos")  

	// Força o fechamento da janela na confirmação
	oView:SetCloseOnOk({||.F.})

    // Relaciona o BOX com a estrutura visual
    oView:SetOwnerView("VW_MASTERZ03", "BOX_TOTAL") 			// View, BOX

Return (oView)
