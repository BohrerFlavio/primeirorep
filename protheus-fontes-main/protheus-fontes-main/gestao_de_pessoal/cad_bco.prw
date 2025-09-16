#INCLUDE "PROTHEUS.CH"
#INCLUDE "FWMVCDEF.CH"

// Variáveis Estáticas
Static cTitulo := "Cadastro de Bancos p/ Beneficiários do RH"

//-------------------------------------------------------------------
/*/{Protheus.doc} CAD_BCO
Função para cadastro e manutenção de bancos utilizado para Beneficiários do RH - Modelo 1 em MVC
@author 	Evandro Mugnol
@since 		Out/2020
@return 	Nil, Função não tem retorno
@obs 		Não se pode executar função MVC dentro do fórmulas
/*/
//-------------------------------------------------------------------

User Function CAD_BCO()

	Local aArea := GetArea()
	Local oBrowse

	Private aRotina := MenuDef()

	// Instânciando FWMBrowse - Somente com dicionário de dados
	oBrowse := FWMBrowse():New()

	// Setando a tabela de cadastro
	oBrowse:SetAlias("ZD6")

	// Setando a descrição da rotina
	oBrowse:SetDescription(cTitulo)

	// Legendas
	oBrowse:AddLegend( "ZD6->ZD6_BLOQ == '2'", "GREEN",	"Conta Corrente Liberada para Beneficiários" )
	oBrowse:AddLegend( "ZD6->ZD6_BLOQ == '1'", "RED",	"Conta Corrente Bloqueada para Beneficiários" )

	// Ativa a Browse
	oBrowse:Activate()

	RestArea(aArea)

Return Nil


//-------------------------------------------------------------------
/*/{Protheus.doc} MenuDef
Criação do Menu MVC
@author     Evandro
@since      Out/2020
@return     N/A
@obs        N/A
/*/
//-------------------------------------------------------------------
Static Function MenuDef()

	Local aRotina := {}

	// Adicionando opções
	ADD OPTION aRotina TITLE "Visualizar" ACTION "VIEWDEF.CAD_BCO" 	OPERATION MODEL_OPERATION_VIEW	 ACCESS 0 // OPERATION 2
	ADD OPTION aRotina TITLE "Incluir"    ACTION "VIEWDEF.CAD_BCO" 	OPERATION MODEL_OPERATION_INSERT ACCESS 0 // OPERATION 3
	ADD OPTION aRotina TITLE "Alterar"    ACTION "VIEWDEF.CAD_BCO" 	OPERATION MODEL_OPERATION_UPDATE ACCESS 0 // OPERATION 4
	ADD OPTION aRotina TITLE "Excluir"    ACTION "VIEWDEF.CAD_BCO" 	OPERATION MODEL_OPERATION_DELETE ACCESS 0 // OPERATION 5
	ADD OPTION aRotina TITLE "Legenda"    ACTION "U_BCOLeg" 	    OPERATION 6                      ACCESS 0 // OPERATION X

Return aRotina


//-------------------------------------------------------------------
/*/{Protheus.doc} ModelDef
Criação do Modelo de Dados MVC
@author     Evandro
@since      Out/2020
@return     N/A
@obs        N/A
/*/
//-------------------------------------------------------------------
Static Function ModelDef()

	// Blocos de código nas validações
	//Local bPre 	:= {|| U_ZD6Pre()} 	// Função chamada antes de abrir a tela
	//Local bPos 	:= {|| U_ZD6Pos()} 	// Função chamada de validação ao clicar no Confirmar
	//Local bCommit := {|| U_ZD6Com()} 	// Função chamada no commit
	//Local bCancel := {|| U_ZD6Can()} 	// Função chamada ao cancelar

	// Criação do objeto do modelo de dados
	Local oModel := Nil

	// Criação da estrutura de dados utilizada na interface
	Local oStZD6 := FWFormStruct(1, "ZD6")

	// Instanciando o modelo, não é recomendado colocar nome da user function (por causa do u_), respeitando 10 caracteres
	oModel := MPFormModel():New("STIZD6M",/*bPre*/, /*bPos*/,/*bCommit*/,/*bCancel*/) 

	// Atribuindo formulários para o modelo
	oModel:AddFields("FORMZD6",/*cOwner*/,oStZD6)

	// Setando a chave primária da rotina
	oModel:SetPrimaryKey({"ZD6_FILIAL","ZD6_COD","ZD6_AGENC","ZD6_NUMCON"})

	// Adicionando descrição ao modelo
	oModel:SetDescription(cTitulo)

	// Setando a descrição do formulário
	oModel:GetModel("FORMZD6"):SetDescription("Formulário do " + cTitulo)

Return oModel


//-------------------------------------------------------------------
/*/{Protheus.doc} ViewDef
Criação da Visão MVC
@author     Evandro
@since      Out/2020
@return     N/A
@obs        N/A
/*/
//-------------------------------------------------------------------
Static Function ViewDef()

	// Criação do objeto do modelo de dados da interface do cadastro
	Local oModel := FWLoadModel("CAD_BCO")

	// Criação da estrutura de dados utilizada na interface do cadastro
	Local oStZD6 := FWFormStruct(2, "ZD6")  // pode se usar um terceiro parâmetro para filtrar os campos exibidos { |cCampo| cCampo $ 'XXX_NOME|XXX_DATAI|'}

	// Criando oView como nulo
	Local oView := Nil

	// Criando a view que será o retorno da função e setando o modelo da rotina
	oView := FWFormView():New()
	oView:SetModel(oModel)

	// Atribuindo formulários para interface
	oView:AddField("VIEW_ZD6", oStZD6, "FORMZD6")

	// Criando um container com nome tela com 100%
	oView:CreateHorizontalBox("TELA",100)

	// Colocando título do formulário
	oView:EnableTitleView('VIEW_ZD6', 'Os dados abaixo serão utilizados exclusivamente para informar no cadastro de beneficiários do RH' )  

	// Força o fechamento da janela na confirmação
	oView:SetCloseOnOk({||.T.})

	// O formulário da interface será colocado dentro do container
	oView:SetOwnerView("VIEW_ZD6","TELA")

Return oView


//-------------------------------------------------------------------
/*/{Protheus.doc} BCOLeg
Função para mostrar a legenda da rotina em MVC
@author 	Evandro Mugnol
@since 		Out/2020
/*/
//-------------------------------------------------------------------
User Function BCOLeg()

	Local aLegenda := {}

	// Monta as cores
	AADD(aLegenda,{"BR_VERDE",		"Conta Corrente Liberada para Beneficiários" })
	AADD(aLegenda,{"BR_VERMELHO",	"Conta Corrente Bloqueada para Beneficiários" })

	BrwLegenda(cTitulo, "Legenda", aLegenda)

Return


//-------------------------------------------------------------------
/*/{Protheus.doc} ZD6Pos
Função chamada no clique do botão Ok do Modelo de Dados (pós-validação)
@author		Evandro Mugnol
@since		Out/2020
/*/
//-------------------------------------------------------------------
User Function ZD6Pos()

	Local lRet       := .T.
	Local oModel  	 := FWModelActive()
	Local nOperation := oModel:GetOperation()
	Local cCampo     := oModel:GetValue("FORMZD6", "ZD6_COD")

Return lRet


//-------------------------------------------------------------------
/*/{Protheus.doc} AlfaNum
Valida se a string passada como parametro contem somente letras de "A a Z" e ou numeros de "0 a 9"
@author     Evandro
@since      Out/2020
@param		cString = String a ser validada
@return     Retorna .T. quando a string contem somente letras e ou numeros ou .F. caso contrario
@obs        N/A
/*/
//-------------------------------------------------------------------
User Function AlfaNum(cString)                                                         

	Local lRet  := .T.			// Conteudo de retorno
	Local nInd  := 0			// Indexadora de laço For/Next             

	// Valida entrada de caracteres especiais caso o campo referente ao dígito verificador do número de conta estiver em uso
	If _Usado("ZD6_DVAGE") .And. _Usado("ZD6_DVCTA")
		cString := Upper(AllTrim(cString))
		For nInd := 1 To Len(cString)
			If !SubStr(cString,nInd,1) $ "0123456789ABCDEFGHIJKLMNOPQRSTUVWXYZ" 
				If FunName() == "CAD_BCO" 
					Aviso("Atenção","Somente números e letras são permitidos neste campo",{"OK"})
				EndIf	
				lRet := .F.
				Exit
			EndIf
		Next
	EndIf

Return(lRet)


//-------------------------------------------------------------------
/*/{Protheus.doc} _Usado
Valida se o campo pasado como parametro consta como usado na estrutura do SX3.
@author     Evandro
@since      Out/2020
@param		cCampo = Nome do campo a ser validado
@return     lógico = .T. ou .F.
@obs        N/A
/*/
//-------------------------------------------------------------------
Static Function _Usado(cCampo)                                                         

	Local aArea := GetArea()	// Salva ambiente para posterior restauracao
	Local lRet  := .T.			// Conteudo de retorno

	//dbSelectArea("SX3")	   		// Dicionario de dados
	//SX3->(dbSetOrder(2))  		// Ordem: Nome do Campo
	//lRet := ( SX3->(MsSeek(cCampo) ) .And. X3Uso(SX3->X3_USADO) ) 

	lRet := X3Uso(GetSx3Cache(cCampo, 'X3_USADO'))

	RestArea(aArea)

Return(lRet)
