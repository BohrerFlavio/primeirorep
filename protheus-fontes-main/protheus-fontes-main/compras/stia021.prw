#INCLUDE "PROTHEUS.CH"
#INCLUDE "FWMVCDEF.CH"

//-------------------------------------------------------------------
/*/{Protheus.doc} ModelDef
Definição do Model da tela de Usuários por Fornecedor que lançam pré nota de entrada sem validar PC, Qtde e Vlr. Unitário
@author     Evandro
@since      04/06/2020
@return     N/A
@obs        N/A
/*/
//-------------------------------------------------------------------
Static Function ModelDef()

	Local oStruSA2 := FWFormStruct(1, "SA2", {|cCampo| ValidaCpo(cCampo,"SA2")})
	Local oStruZLP := FWFormStruct(1, "ZLP", {|cCampo| ValidaCpo(cCampo,"ZLP")}) 					    
	Local oModel
	Local aRelation := {{'ZLP_FILIAL','xFilial("ZLP")'},{'ZLP_CODFOR','A2_COD'},{'ZLP_LOJFOR','A2_LOJA'}}

	oModel := MPFormModel():New("STIA021", ,{ |oModel| STIA021Pos(oModel)})	
	oModel:AddFields("SA2MASTER",,oStruSA2)
	oModel:AddGrid("ZLPDETAIL","SA2MASTER",oStruZLP)

	oModel:SetPrimaryKey({'ZLP_FILIAL', 'ZLP_CODFOR', 'ZLP_LOJFOR', 'ZLP_CODUSU'})

	oModel:GetModel("ZLPDETAIL"):SetUniqueLine({"ZLP_CODUSU"})		
	oModel:SetRelation("ZLPDETAIL", aRelation, ZLP->(IndexKey(1)))

	oModel:SetVldActivate({|oModel| ModelValid(oModel)})

	oStruSA2:SetProperty("A2_NOME",MODEL_FIELD_WHEN,{||.F.})

Return oModel


//-------------------------------------------------------------------
/*/{Protheus.doc} ViewDef
Definição do View da tela de Usuários por Fornecedor que lançam pré nota de entrada sem validar PC, Qtde e Vlr. Unitário
@author     Evandro
@since      04/06/2020
@return     N/A
@obs        N/A
/*/
//-------------------------------------------------------------------
Static Function ViewDef()

	Local oModel   := FWLoadModel("STIA021")
	Local oStruSA2 := FWFormStruct(2,"SA2", {|cCampo| ValidaCpo(cCampo,"SA2")})
	Local oStruZLP := FWFormStruct(2,"ZLP", {|cCampo| ValidaCpo(cCampo,"ZLP")})
	Local oView

	oStruZLP:SetProperty('ZLP_CODUSU'	,MVC_VIEW_ORDEM ,'01')
	oStruZLP:SetProperty('ZLP_NOMUSU'	,MVC_VIEW_ORDEM ,'02')

	oView := FWFormView():New()
	oView:SetModel(oModel)
	oView:AddField("ViewField",oStruSA2,"SA2MASTER")
	oView:AddGrid("ViewGrid",oStruZLP,"ZLPDETAIL")

	oView:CreateHorizontalBox("ViewSA2",30) 
	oView:CreateHorizontalBox("GridZLP",70)

	oView:SetOwnerView("ViewField","ViewSA2")	 
	oView:SetOwnerView("ViewGrid","GridZLP") 

	oView:EnableTitleView("ViewField",OemToANSI("Dados do Fornecedor"))
	oView:EnableTitleView("ViewGrid",OemToANSI("Usuários que lançam pré nota de entrada sem validar PC, Qtde e Vlr. Unitário"))

Return oView


//-------------------------------------------------------------------
/*/{Protheus.doc} ValidaCpo
Função para selecionar os campos do Model e View
@author     Evandro
@since      04/06/2020
@return     N/A
@obs        N/A
/*/
//-------------------------------------------------------------------
Static Function ValidaCpo(cCampo, cAlias)

	Local lRet 	   := .F.
	Local cNomeCpo := ""

	cNomeCpo := AllTrim(cCampo)

	If cAlias == "SA2"			// Campo do SA2 para mostrar no cabeçalho
		If cNomeCpo == "A2_FILIAL" .OR. cNomeCpo == "A2_COD" .OR. cNomeCpo == "A2_LOJA" .OR. cNomeCpo == "A2_NOME" 
			lRet := .T.
		Endif
	ElseIf cAlias == "ZLP"		// Campos da ZLP para não mostrar na Grid
		lRet := .T.
		If cNomeCpo == "ZLP_CODFOR" .OR. cNomeCpo == "ZLP_LOJFOR"
			lRet := .F.
		Endif
	Endif

Return lRet


//------------------------------------------------------------------------
/*/{Protheus.doc} ModelValid
Função para validar o Modelo MVC - Somente irá validar se o Fornecedor não estiver bloqueado 
@author     Evandro
@since      04/06/2020
@return 	lRet, Se .T. o Model poderá ser utilizado, se .F. não 
@obs        N/A
/*/
//------------------------------------------------------------------------
Static Function ModelValid(oModel)

	Local lRet := .T.
	Local cBloq := AllTrim(SA2->A2_MSBLQL)

	IF cBloq == '1'
		lRet := .F.
		Help(,,"ModelValid STIA021",,OemToANSI("Não é possível associar um Usuário à um Fornecedor bloqueado."), 1, 0 )
	Endif

Return lRet


//-------------------------------------------------------------------
/*/{Protheus.doc} STIA31Valid
Função para validação (<descrever se necessário utilizar>)
@author     Evandro
@since      04/06/2020
@return 	lRet, Se .T. o usuário é válido, se .F. inválido 
@obs        N/A
/*/
//-------------------------------------------------------------------
Static Function STIA21Valid()

	Local lRet 		 := .T.
	Local cUsuario 	 := ""
	Local cAreaAnt 	 := GetArea()

	cUsuario := M->ZLP_CODUSU				

	/*
	DbSelectArea("XXX")
	DbSetOrder(1)
	// Se o código informado não estiver cadastrado na tabela XXX, não valida
	If !DbSeek(xFilial("XXX") + cUsuario)
		Help(,,"STIA21Valid",,OemToAnsi("Usuario não cadastrado."), 1, 0 ) 
		lRet := .F.
	EndIf
	*/ 

	RestArea(cAreaAnt)

Return lRet


//-------------------------------------------------------------------
/*/{Protheus.doc} STIA021Pos
Função para validação complementar (<descrever se necessário utilizar>)
@author     Evandro
@since      04/06/2020
@param 		oModel, objeto, Objeto Model da rotina
@return 	lógico,Indica se o registro foi validado 
@obs        N/A
/*/
//-------------------------------------------------------------------
Static Function STIA021Pos(oModel)

	Local lRet		 := .T.
	Local nOperation := oModel:GetOperation()
	Local oModelZLP	 := oModel:GetModel('ZLPDETAIL')
	Local nX		 := 0
	Local aUsers	 := {}
	Local cId		 := ""

	/*
	For nX := 1 To oModelZLP:Length()
		oModelZLP:GoLine(nX)

		If !oModelZLP:IsDeleted()
			cId := GetAdvFVal("XXX","XXX_ID", xFilial("XXX") + oModelZLP:GetValue("ZLP_CODUSU"))
			Aadd(aUserS, cId)
		EndIf
	Next nX
	*/

Return lRet
