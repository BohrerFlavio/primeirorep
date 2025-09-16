#INCLUDE "TOTVS.CH"
#INCLUDE "FWMVCDEF.CH"

//--------------------------------------------------------------------------------------
/*/{Protheus.doc} MVCMOT
@Type			: Função de Usuário
@Sample			: U_MVCMOT()
@Description	: Cadastro de Motivos de Devolução
@Param			: N/A
@Return			: Nulo
@ --------------|-----------------------------------------------------------------------
@Author			: Evandro Mugnol
@Since			: Nov/2024
@version		: Protheus 12.1.2310 e posteriores
@Comments		: Nenhum
/*/
//--------------------------------------------------------------------------------------
User Function MVCMOT()

	// Função que retorna um objeto Browse de uma rotina.
	// A rotina deve implementar o método BrowseDef onde deve retornar o objeto de browse.
	// Retorno: Objeto FWMBrowse gerado pela função Browsedef da rotina.
	Local oBrowse := FwLoadBrw("MVCMOT")

	// Função que retorna o array com os dados do menu da rotina.
	Private aRotina := FwLoadMenuDef("MVCMOT")

	oBrowse:Activate()

Return


//-----------------------------------------------------------------------------
/*/{Protheus.doc} BrowseDef - BROWSER
Funcao de chamada do Browse
@Author     Evandro Mugnol
@Since      Nov/2024
@Comments	Nenhum
/*/
//------------------------------------------------------------------------------
Static Function BrowseDef()

	// Instanciação do Browser
	Local oBrowse := FwMBrowse():New()

	// Definição da tabela principal e título
	oBrowse:SetAlias("ZH0")
	oBrowse:SetDescription("Motivos de Devolução")

Return oBrowse


//-----------------------------------------------------------------------
/*/{Protheus.doc} MenuDef  - OPERAÇÕES
Funcao de chamada do menu
@Author     Evandro Mugnol
@Since      Nov/2024
@Comments	Nenhum
/*/
//-----------------------------------------------------------------------
Static Function MenuDef()

	Local nX      := 0
	Local aRotina := {}
	Local aRotAux := FwMVCMenu("MVCMOT") 		// Retorna as opções padrões para o MenuDef de uma rotina em MVC.
												// Opções padrões:
												// * Visualizar
												// * Incluir
												// * Alterar
												// * Excluir
												// * Imprimir
												// * Cópia

	// Adiciona a opção de Pesquisa
	ADD OPTION aRotina TITLE "Pesquisar" ACTION "VIEWDEF.MVCMOT" OPERATION 1 ACCESS 0

	// Adiciona as demais operações
	For nX := 1 To Len(aRotAux)
		aAdd(aRotina, aRotAux[nX])
	Next nX

Return aRotina


//-----------------------------------------------------------------------
/*/{Protheus.doc} ModelDef - REGRA DE NEGÓCIOS
Funcao de definição das regras
@Author     Evandro Mugnol
@Since      Nov/2024
@Comments	Nenhum
/*/
//-----------------------------------------------------------------------
Static Function ModelDef()

	// Blocos de código nas validações
	//Local bPre 	:= {|| U_ZH0Pre()} 	// Função chamada antes de abrir a tela
	//Local bPos 	:= {|| U_ZH0Pos()} 	// Função chamada de validação ao clicar no Confirmar
	//Local bCommit := {|| U_ZH0Com()} 	// Função chamada no commit
	//Local bCancel := {|| U_ZH0Can()} 	// Função chamada ao cancelar

	// Instancia o modelo
	Local oModel := MPFormModel():New("MVCMOTM", /*bPre*/, /*bPos*/, /*bCommit*/, /*bCancel*/)

	// Instancia o submodelo
	Local oStruZH0 := FwFormStruct(1, "ZH0")

	// Define o submodelo como Field
	oModel:AddFields("MD_MASTERZH0", /*cOwner*/, oStruZH0)

	// Descrição do modelo
	oModel:SetDescription("Cadastro de Motivos de Devolução")

	// Descrição do submodelo
	oModel:GetModel("MD_MASTERZH0"):SetDescription("Motivos de Devolução")

Return oModel


//-----------------------------------------------------------------------
/*/{Protheus.doc} ViewDef - INTERFACE GRÁFICA
Interface do cadastro de motivos de devolução
@Author     Evandro Mugnol
@Since      Nov/2024
@Comments	Nenhum
/*/
//-----------------------------------------------------------------------
Static Function ViewDef()

    // Instancia a view
    Local oView := FwFormView():New()

    // Instancia a subview
    Local oStruZH0 := FwFormStruct(2, "ZH0")

    // Recebe o modelo de dados
    Local oModel := FwLoadModel("MVCMOT")

    // Remove campos
    oStruZH0:RemoveField("ZH0_FILIAL")

    // Indica o modelo da view
    oView:SetModel(oModel)

    // Cria estrutura visual de campos
    oView:AddField("VW_MASTERZH0", oStruZH0, "MD_MASTERZH0") 	// View, Struct, Model

    // Cria BOX horizontal
    oView:CreateHorizontalBox("BOX_TOTAL", 100) 				// BOX, Percentual

	// Colocando título do formulário
	oView:EnableTitleView("VW_MASTERZH0", "Preencha os campos abaixo para serem utilizados nos processos de devoluções")  

	// Força o fechamento da janela na confirmação
	//oView:SetCloseOnOk({||.F.})

    // Relaciona o BOX com a estrutura visual
    oView:SetOwnerView("VW_MASTERZH0", "BOX_TOTAL") 			// View, BOX

Return oView
