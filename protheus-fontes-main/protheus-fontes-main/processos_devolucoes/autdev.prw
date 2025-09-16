#INCLUDE "TOTVS.CH"
#INCLUDE "FWMVCDEF.CH"

//--------------------------------------------------------------------------------------
/*/{Protheus.doc} AUTDEV
@Type			: Função de Usuário
@Sample			: U_AUTDEV()
@Description	: Cadastro de Autorização de Devolução
@Param			: N/A
@Return			: Nulo
@ --------------|-----------------------------------------------------------------------
@Author			: Evandro Mugnol
@Since			: Nov/2024
@version		: Protheus 12.1.2310 e posteriores
@Comments		: Nenhum
/*/
//--------------------------------------------------------------------------------------
User Function AUTDEV()

	// Função que retorna um objeto Browse de uma rotina.
	// A rotina deve implementar o método BrowseDef onde deve retornar o objeto de browse.
	// Retorno: Objeto FWMBrowse gerado pela função Browsedef da rotina.
	Local oBrowse := FwLoadBrw("AUTDEV")

	// Função que retorna o array com os dados do menu da rotina.
	Private aRotina := FwLoadMenuDef("AUTDEV")

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
	oBrowse:SetAlias("ZH2")
	oBrowse:SetDescription("Autorização de Devolução")

    // Adicionando a primeira legenda
	oBrowse:AddLegend("ZH2->ZH2_STATUS = '1'", "RED"    , "Autorização Dev. Incluída s/ Pré Nota de Devolução"		 			 , "1")
	oBrowse:AddLegend("ZH2->ZH2_STATUS = '2'", "YELLOW" , "Autorização Dev. Incluída c/ Pré Nota de Devolução Lançada e Bloqueada", "1")
	oBrowse:AddLegend("ZH2->ZH2_STATUS = '3'", "GREEN"  , "Autorização Dev. Liberada p/ Supervisor ou Qualidade"					 , "1")
	oBrowse:AddLegend("ZH2->ZH2_STATUS = '4'", "BLACK"  , "Autorização Dev. Encerrada c/ NF Classificada"			 			 , "1")
	oBrowse:AddLegend("ZH2->ZH2_STATUS = '5'", "CHECKED", "Autorização Dev. Encerrada c/ NF Classificada e Refaturamento Realizado"			 			 , "1")

    // Adicionando a segunda legenda
    oBrowse:AddLegend("ZH2->ZH2_TIPRET = '1'", "PRECO"    , "Refaturamento Mesmo Cliente" , "2")
    oBrowse:AddLegend("ZH2->ZH2_TIPRET = '2'", "LJPRECO"  , "Refaturamento Outro Cliente" , "2")
    oBrowse:AddLegend("ZH2->ZH2_TIPRET = '3'", "BLEFT"    , "Retorno Físico Frigorífico"  , "2")
    oBrowse:AddLegend("ZH2->ZH2_TIPRET = '4'", "NOCHECKED", "Sem Retorno"  				, "2")

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
	Local aRotAux := FwMVCMenu("AUTDEV") 		// Retorna as opções padrões para o MenuDef de uma rotina em MVC.
												// Opções padrões:
												// * Visualizar
												// * Incluir
												// * Alterar
												// * Excluir
												// * Imprimir
												// * Cópia

	// Adiciona a opção de Pesquisa
	ADD OPTION aRotina TITLE "Pesquisar" ACTION "VIEWDEF.AUTDEV" OPERATION 1 ACCESS 0

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
	//Local bPre 	:= {|| U_ZH2Pre()} 	// Função chamada antes de abrir a tela
	//Local bPos 	:= {|| U_ZH2Pos()} 	// Função chamada de validação ao clicar no Confirmar
	//Local bCommit := {|| U_ZH2Com()} 	// Função chamada no commit
	//Local bCancel := {|| U_ZH2Can()} 	// Função chamada ao cancelar

	// Instancia o modelo
	Local oModel := MPFormModel():New("AUTDEVM", /*bPre*/, /*bPos*/, /*bCommit*/, /*bCancel*/)

	// Instancia o submodelo
	Local oStruZH2 := FwFormStruct(1, "ZH2")

	// Define o submodelo como Field
	oModel:AddFields("MD_MASTERZH2", /*cOwner*/, oStruZH2)

	// Descrição do modelo
	oModel:SetDescription("Cadastro de Autorização de Devolução")

	// Descrição do submodelo
	oModel:GetModel("MD_MASTERZH2"):SetDescription("Autorização de Devolução")

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
    Local oStruZH2 := FwFormStruct(2, "ZH2")

    // Recebe o modelo de dados
    Local oModel := FwLoadModel("AUTDEV")

    // Remove campos
    oStruZH2:RemoveField("ZH2_FILIAL")
    oStruZH2:RemoveField("ZH2_STATUS")

    // Indica o modelo da view
    oView:SetModel(oModel)

    // Cria estrutura visual de campos
    oView:AddField("VW_MASTERZH2", oStruZH2, "MD_MASTERZH2") 	// View, Struct, Model

    // Cria BOX horizontal
    oView:CreateHorizontalBox("BOX_TOTAL", 100) 				// BOX, Percentual

	// Colocando título do formulário
	oView:EnableTitleView("VW_MASTERZH2", "Preencha os campos abaixo para criar um novo processo de autorização de devolução")  

	// Força o fechamento da janela na confirmação
	//oView:SetCloseOnOk({||.F.})

    // Relaciona o BOX com a estrutura visual
    oView:SetOwnerView("VW_MASTERZH2", "BOX_TOTAL") 			// View, BOX

	// Define se pode abrir a tela ou não. Executado no Botão -> INCLUIR / ALTERAR / EXCLUIR / VISUALIZAR / COPIAR
	oView:SetViewCanActivate( {|oView| ZH2Pre(oView)} )

Return oView


//-----------------------------------------------------------------------
/*/{Protheus.doc} ZH2Pre
Função de pré-validação para saber se usuário logado pode incluir
autorização de devolução
@Author     Evandro Mugnol
@Since      Nov/2024
@Comments	Nenhum
/*/
//-----------------------------------------------------------------------
Static Function ZH2Pre(oView)

	Local aSaveArea	 := FWGetArea()
	Local lRet		 := .T.
	Local nOperation := oView:GetOperation()

	If nOperation == MODEL_OPERATION_INSERT					// Inclusão
		DbSelectArea("ZH1")
		DbSetOrder(1)
		If !DbSeek(xFilial("ZH1") + "1" + RetCodUsr())		// 1=Usuário Autorizador
			lRet := .F.
			FWAlertWarning("", "Você não tem permissão para incluir autorizações de devolução!!")
		EndIf
	ElseIf nOperation == MODEL_OPERATION_DELETE				// Exclusão
		DbSelectArea("ZH1")
		DbSetOrder(1)
		If DbSeek(xFilial("ZH1") + "1" + RetCodUsr())		// 1=Usuário Autorizador
			If ZH2->ZH2_STATUS <> "1"
				lRet := .F.
				FWAlertWarning("", "Você não tem permissão para excluir autorizações de devolução!!")
			EndIf
		Else
			lRet := .F.
			FWAlertWarning("", "Somente usuário Autorizador tem permissão para excluir autorizações de devolução!!")
		EndIf
	ElseIf nOperation == MODEL_OPERATION_UPDATE				// Alteração
		DbSelectArea("ZH1")
		DbSetOrder(1)
		If DbSeek(xFilial("ZH1") + "1" + RetCodUsr())		// 1=Usuário Autorizador
			If ZH2->ZH2_STATUS <> "1"
				lRet := .F.
				FWAlertWarning("", "Você não tem permissão para alterar autorizações de devolução!!")
			EndIf
		Else
			lRet := .F.
			FWAlertWarning("", "Somente usuário Autorizador tem permissão para alterar autorizações de devolução!!")
		EndIf
	EndIf
	
	FWRestArea(aSaveArea)

Return lRet
