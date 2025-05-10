#INCLUDE "TOTVS.CH"
#INCLUDE "FWMVCDEF.CH"

//Variveis Estaticas
Static cTitulo    := "Cadastro de Usuários de Devoluções por Nível"
Static cTabPai    := "ZH1"

//--------------------------------------------------------------------------------------
/*/{Protheus.doc} MVCNIV
@Type			: Função de Usuário
@Sample			: U_MVCNIV()
@Description	: Cadastro de Usuários de Devoluções por Nível
@Param			: N/A
@Return			: Nulo
@ --------------|-----------------------------------------------------------------------
@Author			: Evandro Mugnol
@Since			: Nov/2024
@version		: Protheus 12.1.2310 e posteriores
@Comments		: Nenhum
/*/
//--------------------------------------------------------------------------------------
User Function MVCNIV()

	Local aArea := FWGetArea()
	Local oBrowse

	Private aRotina := {}

	// Definição do menu
	aRotina := MenuDef()

	// Instanciando o browse
	oBrowse := FWMBrowse():New()
	oBrowse:SetAlias(cTabPai)
	oBrowse:SetDescription(cTitulo)

	// Adicionando as Legendas
	oBrowse:AddLegend("ZH1->ZH1_NIVEL = '1'", "GREEN" , "Usuário Autorizador")
	oBrowse:AddLegend("ZH1->ZH1_NIVEL = '2'", "ORANGE", "Usuário Supervisor")
	oBrowse:AddLegend("ZH1->ZH1_NIVEL = '3'", "BLUE"  , "Usuário Qualidade")

	// Ativa a Browse
	oBrowse:Activate()

	FWRestArea(aArea)

Return

//-----------------------------------------------------------------------
/*/{Protheus.doc} MenuDef  - OPERAÇÕES
Funcao de chamada do menu
@Author     Evandro Mugnol
@Since      Nov/2024
@Comments	Nenhum
/*/
//-----------------------------------------------------------------------
Static Function MenuDef()

	Local aRotina := {}

	// Adicionando opcoes do menu
	ADD OPTION aRotina TITLE "Visualizar" ACTION "VIEWDEF.MVCNIV" OPERATION 1 ACCESS 0
	ADD OPTION aRotina TITLE "Incluir" 	  ACTION "VIEWDEF.MVCNIV" OPERATION 3 ACCESS 0
	ADD OPTION aRotina TITLE "Alterar" 	  ACTION "VIEWDEF.MVCNIV" OPERATION 4 ACCESS 0
	ADD OPTION aRotina TITLE "Excluir" 	  ACTION "VIEWDEF.MVCNIV" OPERATION 5 ACCESS 0

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
	Local oStruPai   := FWFormStruct( 1, cTabPai, {|x|  Alltrim(x)+"|" $ "ZH1_NIVEL|ZH1_DESCRI|"})
	Local oStruFilho := FWFormStruct( 1, cTabPai, {|x|  !Alltrim(x)+"|" $ "ZH1_NIVEL|ZH1_DESCRI|"})
	Local aRelation  := {}
	Local oModel
	Local bPre 		 := Nil
	Local bPos 		 := Nil
	Local bCommit	 := Nil
	Local bCancel 	 := Nil
	Local aGatilhos  := {}
	Local nAtual

	// Adicionando um gatilho
	aAdd(aGatilhos, FWStruTrigger(;
								  "ZH1_NIVEL"	,;      // Campo Origem
								  "ZH1_DESCRI"	,;      // Campo Destino
								  "IIF(M->ZH1_NIVEL='1','Usuario Autorizador',IIF(M->ZH1_NIVEL='2','Usuario Supervisor','Usuario Qualidade'))",;	// Regra de Preenchimento
								  .F.			,;      // Irá Posicionar?
								  ""			,;      // Alias de Posicionamento
								  0				,;      // Índice de Posicionamento
								  ''			,;      // Chave de Posicionamento
								  NIL			,;      // Condição para execução do gatilho
								  "01")			 ;      // Sequência do gatilho
		)

	// Percorrendo os gatilhos e adicionando na Struct
	For nAtual := 1 To Len(aGatilhos)
		oStruPai:AddTrigger(;
							aGatilhos[nAtual][01],; 	// Campo Origem
							aGatilhos[nAtual][02],; 	// Campo Destino
							aGatilhos[nAtual][03],; 	// Bloco de código na validação da execução do gatilho
							aGatilhos[nAtual][04] ;  	// Bloco de código de execução do gatilho
						   )
	Next
		
	// Cria o modelo de dados para cadastro
	oModel := MPFormModel():New("MVCNIVM", bPre, bPos, bCommit, bCancel)
	oModel:AddFields("ZH1MASTER", /*cOwner*/, oStruPai)
	oModel:AddGrid("ZH1DETAIL","ZH1MASTER",oStruFilho,/*bLinePre*/, /*bLinePost*/,/*bPre - Grid Inteiro*/,/*bPos - Grid Inteiro*/,/*bLoad - Carga do modelo manualmente*/)
	oModel:SetDescription(cTitulo)
	oModel:GetModel("ZH1MASTER"):SetDescription(cTitulo)
	oModel:GetModel("ZH1DETAIL"):SetDescription(cTitulo)
	oModel:SetPrimaryKey({'FWxFilial("ZH1")','ZH1_NIVEL','ZH1_CODUSU'})

	// Fazendo o relacionamento
	aAdd(aRelation, {"ZH1_FILIAL", "FWxFilial('ZH1')"} )
	aAdd(aRelation, {"ZH1_NIVEL", "ZH1_NIVEL"})
	//aAdd(aRelation, {"ZH1_DESCRI", "ZH1_DESCRI"})
	oModel:SetRelation("ZH1DETAIL", aRelation, ZH1->(IndexKey(1)))

	// Definindo campos unicos da linha
	oModel:GetModel("ZH1DETAIL"):SetUniqueLine({'ZH1_CODUSU'})

	//Modo de edição
	oStruPai:SetProperty( 'ZH1_NIVEL' , MODEL_FIELD_WHEN,{|| INCLUI})

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
	Local oStruPai   := FWFormStruct( 2, cTabPai, {|x|  Alltrim(x)+"|" $ "ZH1_NIVEL|ZH1_DESCRI|"})
	Local oStruFilho := FWFormStruct( 2, cTabPai, {|x|  !Alltrim(x)+"|" $ "ZH1_NIVEL|ZH1_DESCRI|"})
	Local oModel     := FWLoadModel("MVCNIV")
	Local oView

	// Cria a visualizacao do cadastro
	oView := FWFormView():New()
	oView:SetModel(oModel)
	oView:AddField("VIEW_ZH1", oStruPai, "ZH1MASTER")
	oView:AddGrid("GRID_ZH1",  oStruFilho, "ZH1DETAIL")

	// Partes da tela
	oView:CreateHorizontalBox("CABEC", 30)
	oView:CreateHorizontalBox("GRID", 70)
	oView:SetOwnerView("VIEW_ZH1", "CABEC")
	oView:SetOwnerView("GRID_ZH1", "GRID")

	// Titulos
	oView:EnableTitleView("VIEW_ZH1", "Definição do Nível")
	oView:EnableTitleView("GRID_ZH1", "Usuários Habilitados")

Return oView
