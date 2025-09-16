#INCLUDE "PROTHEUS.CH"
#INCLUDE "FWMVCDEF.CH"

//-------------------------------------------------------------------
/*/{Protheus.doc} MVC004 - FUNÇÃO PRINCIPAL
Função para cadastro e manutenção de códigos de classificação do abate
@author 	Evandro Mugnol
@since 		Out/2022
@version    1.0
/*/
//-------------------------------------------------------------------
User Function MVC004()

	// Função que retorna um objeto Browse de uma rotina.
	// A rotina deve implementar o método BrowseDef onde deve retornar o objeto de browse.
	// Retorno: Objeto FWMBrowse gerado pela função Browsedef da rotina.
	Local oBrowse := FwLoadBrw("MVC004")

	// Função que retorna o array com os dados do menu da rotina.
	Private aRotina := FwLoadMenuDef("MVC004")

	oBrowse:Activate()

Return


//-----------------------------------------------------------------------------
/*/{Protheus.doc} BrowseDef - BROWSER
Funcao de chamada do Browse
@author     Evandro Mugnol
@since      Out/2022
@version    1.0
/*/
//------------------------------------------------------------------------------
Static Function BrowseDef()

	// Instanciação do Browser
	Local oBrowse := FwMBrowse():New()

	// Definição da tabela principal e título
	oBrowse:SetAlias("ZP6")
	oBrowse:SetDescription("Códigos Classificação do Abate")

	// Demais definições do Browser

Return(oBrowse)


//-----------------------------------------------------------------------------
/*/{Protheus.doc} MenuDef  - OPERAÇÕES
Funcao de chamada do menu
@author     Evandro Mugnol
@since      Out/2022
@version    1.0
/*/
//-----------------------------------------------------------------------------
Static Function MenuDef()
	Local nX      := 0
	Local aRotina := {}
	Local aRotAux := FwMVCMenu("MVC004") 		// Retorna as opções padrões para o MenuDef de uma rotina em MVC.
												// Opções padrões:
												// * Visualizar
												// * Incluir
												// * Alterar
												// * Excluir
												// * Imprimir
												// * Cópia

	// Adiciona a opção de Pesquisa
	ADD OPTION aRotina TITLE "Pesquisar" ACTION "VIEWDEF.MVC004" OPERATION 1 ACCESS 0

	// Adiciona as demais operações
	For nX := 1 To Len(aRotAux)
		aAdd(aRotina, aRotAux[nX])
	Next nX

Return(aRotina)


//-----------------------------------------------------------------------------
/*/{Protheus.doc} ModelDef - REGRA DE NEGÓCIOS
Funcao de definição das regras
@author     Evandro Mugnol
@since      Out/2022
@version    1.0
/*/
//------------------------------------------------------------------------------
Static Function ModelDef()

	// Blocos de código nas validações
	//Local bPre 	:= {|| U_ZP6Pre()} 	// Função chamada antes de abrir a tela
	//Local bPos 	:= {|| U_ZP6Pos()} 	// Função chamada de validação ao clicar no Confirmar
	//Local bCommit := {|| U_ZP6Com()} 	// Função chamada no commit
	//Local bCancel := {|| U_ZP6Can()} 	// Função chamada ao cancelar

	// Instancia o modelo
	Local oModel := MPFormModel():New("MVC004M", /*bPre*/, /*bPos*/, /*bCommit*/, /*bCancel*/)

	// Instancia o submodelo
	Local oStruZP6 := FwFormStruct(1, "ZP6")

	// Define o submodelo como Field
	oModel:AddFields("MD_MASTERZP6", /*cOwner*/, oStruZP6)

	// Descrição do modelo
	oModel:SetDescription("Cadastro de Códigos Classificação do Abate")

	// Descrição do submodelo
	oModel:GetModel("MD_MASTERZP6"):SetDescription("Códigos Classificação do Abate")

    // Demais definições da regra de negócios

Return(oModel)


//-----------------------------------------------------------------------------
/*/{Protheus.doc} ViewDef - INTERFACE GRÁFICA
Interface do cadastro de códigos de classificação do abate
@author     Evandro Mugnol
@since      Out/2022
@version    1.0
/*/
//------------------------------------------------------------------------------
Static Function ViewDef()

    // Instancia a view
    Local oView := FwFormView():New()

    // Instancia a subview
    Local oStruZP6 := FwFormStruct(2, "ZP6")

    // Recebe o modelo de dados
    Local oModel := FwLoadModel("MVC004")

    // Remove campos
    oStruZP6:RemoveField("ZP6_FILIAL")

    // Indica o modelo da view
    oView:SetModel(oModel)

    // Cria estrutura visual de campos
    oView:AddField("VW_MASTERZP6", oStruZP6, "MD_MASTERZP6") 	// View, Struct, Model

    // Cria BOX horizontal
    oView:CreateHorizontalBox("BOX_TOTAL", 100) 				// BOX, Percentual

	// Colocando título do formulário
	oView:EnableTitleView("VW_MASTERZP6", "Preencha os campos abaixo para serem utilizados nos processos de classificação do abate")

	// Força o fechamento da janela na confirmação
	oView:SetCloseOnOk({||.F.})

    // Relaciona o BOX com a estrutura visual
    oView:SetOwnerView("VW_MASTERZP6", "BOX_TOTAL") 			// View, BOX

    // Demais definições de interface gráfica

Return (oView)
