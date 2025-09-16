#INCLUDE "TOTVS.CH"
#INCLUDE "FWMVCDEF.CH"

//-------------------------------------------------------------------
/*/{Protheus.doc} MVC000 - FUNÇÃO PRINCIPAL
Função para cadastro e manutenção de consumo de embalagens
@author     Evandro Mugnol
@since      Set/2021
@version    1.0
/*/
//-------------------------------------------------------------------
User Function MVC000()
	
	// Função que retorna um objeto Browse de uma rotina.
	// A rotina deve implementar o método BrowseDef onde deve retornar o objeto de browse.
	// Retorno: Objeto FWMBrowse gerado pela função Browsedef da rotina.
    Local oBrowse   := FwLoadBrw("MVC000")

	// Função que retorna o array com os dados do menu da rotina.
	Private aRotina := FwLoadMenuDef("MVC000")

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
	oBrowse:SetAlias("Z00")
	oBrowse:SetDescription("Consumo de Embalagens")

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
	Local aRotAux := FwMVCMenu("MVC000") 		// Retorna as opções padrões para o MenuDef de uma rotina em MVC.
												// Opções padrões:
												// * Visualizar
												// * Incluir
												// * Alterar
												// * Excluir
												// * Imprimir
												// * Cópia

	// Adiciona a opção de Pesquisa
	ADD OPTION aRotina TITLE "Pesquisar" ACTION "VIEWDEF.MVC000" 	OPERATION 1 ACCESS 0

	// Adiciona as demais operações
	For nX := 1 To Len(aRotAux)
		aAdd(aRotina, aRotAux[nX])
	Next nX

	ADD OPTION aRotina TITLE "Fechamento"  ACTION "U_FechCons()" 	OPERATION 6 ACCESS 0

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
	//Local bPre 	:= {|| U_Z00Pre()} 	// Função chamada antes de abrir a tela
	//Local bPos 	:= {|| U_Z00Pos()} 	// Função chamada de validação ao clicar no Confirmar
	//Local bCommit := {|| U_Z00Com()} 	// Função chamada no commit
	//Local bCancel := {|| U_Z00Can()} 	// Função chamada ao cancelar

	// Instancia o modelo
	Local oModel := MPFormModel():New("MVC000M", /*bPre*/, {|oModel| _PosVld(oModel)} /*bPos*/, /*bCommit*/, /*bCancel*/)

	// Instancia os submodelos
	Local oStruZ00 := FwFormStruct(1, "Z00")
	Local oStruZ01 := FwFormStruct(1, "Z01")

    // Valida se pode entrar na tela
    oModel:SetVldActive( {|oModel| _VldAcess(oModel)}  )

	// Define se os submodelos serão Field ou Grid
	oModel:AddFields("MD_MASTERZ00", NIL, oStruZ00)

	// Define se os submodelos serão Field ou Grid
	oModel:AddGrid("MD_DETAILZ01", "MD_MASTERZ00", oStruZ01)

    // Define a relação entre os submodelos (CSUBMODELO, {ARELATION1, ARELATION2}, CINDEXFILHO)
	oModel:SetRelation("MD_DETAILZ01", {{"Z01_FILIAL", "FwXFilial('Z01')"}, {"Z01_DTCONS", "Z00_DTCONS"}, {"Z01_LOCUSO", "Z00_LOCUSO"}}, Z01->(IndexKey( 1 )))

    // Controle de não repetição de dados
	oModel:GetModel("MD_DETAILZ01"):SetUniqueLine({"Z01_DTCONS", "Z01_LOCUSO", "Z01_ITEM", "Z01_PRDINS", "Z01_LOTINS"})

	// Descrição do modelo
	oModel:SetDescription("Cadastro de Consumo de Embalagens")

	// Descrição do submodelo
	oModel:GetModel("MD_MASTERZ00"):SetDescription("Cabeçalho")
	oModel:GetModel("MD_DETAILZ01"):SetDescription("Itens")

    // Define campos que não serão copiados na opção de cópia 
    oModel:GetModel("MD_MASTERZ00"):SetFldNoCopy({"Z00_DTCONS","Z00_LOCUSO","Z00_FECHTO","Z00_HORFEC","Z00_USRFEC"})
    oModel:GetModel("MD_DETAILZ01"):SetFldNoCopy({"Z01_DTCONS","Z01_LOCUSO","Z01_QTDINS","Z01_LOTINS","Z01_VLDINS","Z01_QTDAL1","Z01_LOTAL1","Z01_VLDAL1","Z01_QTDAL2","Z01_LOTAL2","Z01_VLDAL2","Z01_HORLCT","Z01_USRLCT"})

   	// Demais definições da regra de negócios

Return(oModel)


//-----------------------------------------------------------------------------
/*/{Protheus.doc} ViewDef - INTERFACE GRÁFICA
Interface do cadastro de consumo de embalagens
@author     Evandro Mugnol
@since      Out/2021
@version    1.0
/*/
//------------------------------------------------------------------------------
Static Function ViewDef()

    // Instancia a view
	Local oView := FwFormView():New()

    // Instancia as subviews
	Local oStruZ00 := FwFormStruct(2, "Z00")
	Local oStruZ01 := FwFormStruct(2, "Z01")

    // Recebe o modelo de dados
	Local oModel := FwLoadModel("MVC000")

    // Remove campos
	oStruZ00:RemoveField("Z00_FILIAL")
	oStruZ01:RemoveField("Z01_FILIAL")
	oStruZ01:RemoveField("Z01_DTCONS")
	oStruZ01:RemoveField("Z01_LOCUSO")

    // Indica o modelo da view
	oView:SetModel(oModel)

    // Cria estrutura visual de campos
	oView:AddField("VW_MASTERZ00", oStruZ00, "MD_MASTERZ00")
	oView:AddGrid("VW_DETAILZ01", oStruZ01, "MD_DETAILZ01")

    // Cria BOX horizontal
	oView:CreateHorizontalBox("BOX_SUPERIOR", 25)
	oView:CreateHorizontalBox("BOX_INFERIOR", 75)

	// Força o fechamento da janela na confirmação
	oView:SetCloseOnOk({||.T.})

	// Relaciona os BOXES com as estruturas visuais
	oView:SetOwnerView("VW_MASTERZ00", "BOX_SUPERIOR")
	oView:SetOwnerView("VW_DETAILZ01", "BOX_INFERIOR")

	// Define auto-incremento ao campo
	oView:AddIncrementField("VW_DETAILZ01", "Z01_ITEM")

    // Define os títulos da subviews
	oView:EnableTitleView("VW_DETAILZ01", "Preencha os campos abaixo para serem utilizados no recálculo dos empenhos na rotina Bloco K - 5")

    // Demais definições de interface gráfica

Return(oView)


//-----------------------------------------------------------------------------
/*/{Protheus.doc} _VldAcess
Efetua validações se pode ou não entrar na tela
@author     Evandro Mugnol
@since      Out/2021
@version    1.0
/*/
//------------------------------------------------------------------------------
Static Function _VldAcess(oModel)

	Local lValid  	 := .T.
	Local nOperation := oModel:GetOperation()

	If nOperation == MODEL_OPERATION_UPDATE 			// Alterar
		If !Empty(Z00->Z00_FECHTO)
			Help( ,, "MDL_PREVLD",, "Não é permitido ALTERAR, pois fechamento já foi realizado para esta data consumo / local de uso.", 1, 0,,,,,, {"Selecione outra data consumo / local de uso."})
			lValid := .F.
		EndIf
	ElseIf nOperation == MODEL_OPERATION_DELETE 		// Excluir
		If !Empty(Z00->Z00_FECHTO)
			Help( ,, "MDL_PREVLD",, "Não é permitido EXCLUIR, pois fechamento já foi realizado para esta data consumo / local de uso.", 1, 0,,,,,, {"Selecione outra data consumo / local de uso."})
			lValid := .F.
		EndIf
	EndIf

Return(lValid)


//-----------------------------------------------------------------------------
/*/{Protheus.doc} _PosVld
Efetua validações na confirmação do modelo
@author     Evandro Mugnol
@since      Out/2021
@version    1.0
/*/
//------------------------------------------------------------------------------
Static Function _PosVld(oModel)

    Local nX      := 0                               	// Controle do laço
    Local lValid  := .T.                             	// Controle da transação
    Local aLines  := FwSaveRows()                    	// Armazena estado das linhas
    Local oMdlZ01 := oModel:GetModel("MD_DETAILZ01") 	// Guarda o submodelo Z01

    // Laço até a quantidade de linhas
    For nX := 1 To oMdlZ01:Length()
        
		oMdlZ01:GoLine(nX) 		// Posiciona na linha referente ao contador

        // Verifica se a linha não está deletada e se foi informado quantidades alternativas para produtos alternativos
        If (!oMdlZ01:IsDeleted() .And. (!Empty(oMdlZ01:GetValue("Z01_PRDAL1")) .And. oMdlZ01:GetValue("Z01_QTDAL1") == 0))
	        lValid := .F.
        EndIf

        If (!oMdlZ01:IsDeleted() .And. (!Empty(oMdlZ01:GetValue("Z01_PRDAL2")) .And. oMdlZ01:GetValue("Z01_QTDAL2") == 0))
            lValid := .F.
        EndIf

    Next nX

	If !lValid
		Help( ,, "MDL_VLDPRDALT",, "Existem produtos ALTERNATIVOS informados com quantidade ZERO.", 1, 0,,,,,, {"Corrija os dados para confirmar o cadastramento."})
	EndIf

    // Restaura o estado anterior das linhas
    FwRestRows(aLines)

Return(lValid)


//-----------------------------------------------------------------------------
/*/{Protheus.doc} FechCons
Fechamento do Consumo na Data/Local Posicionado
@author     Evandro Mugnol
@since      Out/2021
@version    1.0
/*/
//------------------------------------------------------------------------------
User Function FechCons()

	If !Empty(Z00->Z00_FECHTO)
		Help( ,, "MDL_FECHTO",, "Não é permitido realizar FECHAMENTO para uma data consumo / local de uso já fechado.", 1, 0,,,,,, {"Selecione uma data consumo / local de uso que ainda não tenha sido fechado."})
	Else
		If MsgYesNo("Confirma fechamento dos lançamentos de insumos informados?. Após não será mais permitido manutenção.", "MDL_FECHTO")
			RecLock("Z00",.F.)
			Z00->Z00_FECHTO := Date()
			Z00->Z00_HORFEC := Time()
			Z00->Z00_USRFEC := AllTrim(PswChave(__CUSERID))
			Z00->(MsUnlock())
		EndIf
	EndIf

Return
