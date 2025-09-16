#INCLUDE "PROTHEUS.CH"
#INCLUDE "FWMVCDEF.CH"

//-------------------------------------------------------------------
/*/{Protheus.doc} ModelDef
Definição do Model da tela de Segmentos por Fornecedor que será usado no processo de cotação
@author     Evandro
@since      09/06/2020
@return     N/A
@obs        N/A
/*/
//-------------------------------------------------------------------
Static Function ModelDef()

	Local oStruSA2 := FWFormStruct(1, "SA2", {|cCampo| ValidaCpo(cCampo,"SA2")})
	Local oStruZLR := FWFormStruct(1, "ZLR", {|cCampo| ValidaCpo(cCampo,"ZLR")}) 					    
	Local oModel
	Local aRelation := {{'ZLR_FILIAL','xFilial("ZLR")'},{'ZLR_CODFOR','A2_COD'},{'ZLR_LOJFOR','A2_LOJA'}}

	oModel := MPFormModel():New("STIA022", ,{ |oModel| STIA022Pos(oModel)})	
	oModel:AddFields("SA2MASTER",,oStruSA2)
	oModel:AddGrid("ZLRDETAIL","SA2MASTER",oStruZLR)

	oModel:SetPrimaryKey({'ZLR_FILIAL', 'ZLR_CODFOR', 'ZLR_LOJFOR', 'ZLR_CODSEG'})

	oModel:GetModel("ZLRDETAIL"):SetUniqueLine({"ZLR_CODSEG"})		
	oModel:SetRelation("ZLRDETAIL", aRelation, ZLR->(IndexKey(1)))

	oModel:SetVldActivate({|oModel| ModelValid(oModel)})

    // Deixa o modelo ZLR como opcional
    oModel:GetModel("ZLRDETAIL"):SetOptional(.T.)

	oStruSA2:SetProperty("A2_NOME",MODEL_FIELD_WHEN,{||.F.})

Return oModel


//-------------------------------------------------------------------
/*/{Protheus.doc} ViewDef
Definição do View da tela de Segmentos por Fornecedor que será usado no processo de cotação
@author     Evandro
@since      09/06/2020
@return     N/A
@obs        N/A
/*/
//-------------------------------------------------------------------
Static Function ViewDef()

	Local oModel   := FWLoadModel("STIA022")
	Local oStruSA2 := FWFormStruct(2,"SA2", {|cCampo| ValidaCpo(cCampo,"SA2")})
	Local oStruZLR := FWFormStruct(2,"ZLR", {|cCampo| ValidaCpo(cCampo,"ZLR")})
	Local oView

	oStruZLR:SetProperty('ZLR_CODSEG'	,MVC_VIEW_ORDEM ,'01')
	oStruZLR:SetProperty('ZLR_DESSEG'	,MVC_VIEW_ORDEM ,'02')

	oView := FWFormView():New()
	oView:SetModel(oModel)
	oView:AddField("ViewField",oStruSA2,"SA2MASTER")
	oView:AddGrid("ViewGrid",oStruZLR,"ZLRDETAIL")

	oView:CreateHorizontalBox("ViewSA2",20) 
	oView:CreateHorizontalBox("GridZLR",80)

	oView:SetOwnerView("ViewField","ViewSA2")	 
	oView:SetOwnerView("ViewGrid","GridZLR") 

	oView:EnableTitleView("ViewField",OemToANSI("Dados do Fornecedor"))
	oView:EnableTitleView("ViewGrid",OemToANSI("Segmentos que serão considerados na filtragem de Fornecedores no processo de Cotação"))

Return oView


//-------------------------------------------------------------------
/*/{Protheus.doc} ValidaCpo
Função para selecionar os campos do Model e View
@author     Evandro
@since      09/06/2020
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
	ElseIf cAlias == "ZLR"		// Campos da ZLR para não mostrar na Grid
		lRet := .T.
		If cNomeCpo == "ZLR_CODFOR" .OR. cNomeCpo == "ZLR_LOJFOR"
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
		Help(,,"ModelValid STIA022",,OemToANSI("Não é possível associar um Segmento à um Fornecedor bloqueado."), 1, 0 )
	Endif

Return lRet


//-------------------------------------------------------------------
/*/{Protheus.doc} STIA22Valid
Função para validação se o segmento informado existe no cadastro de segmentos de fornecedores
@author     Evandro
@since      05/06/2020
@return 	lRet, Se .T. o segmento é válido, se .F. inválido 
@obs        N/A
/*/
//-------------------------------------------------------------------
Static Function STIA22Valid()

	Local lRet 		 := .T.
	Local cUsuario 	 := ""
	Local cAreaAnt 	 := GetArea()

	cSegmento := M->ZLR_CODSEG				

	DbSelectArea("ZLQ")
	DbSetOrder(1)
	// Se o código informado não estiver cadastrado na tabela XXX, não valida
	If !DbSeek(xFilial("ZLQ") + cSegmento)
		Help(,,"STIA22Valid",,OemToAnsi("Segmento não cadastrado."), 1, 0 ) 
		lRet := .F.
	EndIf

	RestArea(cAreaAnt)

Return lRet


//-------------------------------------------------------------------
/*/{Protheus.doc} STIA022Pos
Função para validação complementar (<descrever se necessário utilizar>)
@author     Evandro
@since      04/06/2020
@param 		oModel, objeto, Objeto Model da rotina
@return 	lógico,Indica se o registro foi validado 
@obs        N/A
/*/
//-------------------------------------------------------------------
Static Function STIA022Pos(oModel)

	Local lRet		 := .T.
	Local nOperation := oModel:GetOperation()
	Local oModelZLR	 := oModel:GetModel('ZLRDETAIL')
	Local nX		 := 0
	Local aUsers	 := {}
	Local cId		 := ""

	/*
	For nX := 1 To oModelZLR:Length()
		oModelZLR:GoLine(nX)

		If !oModelZLR:IsDeleted()
			cId := GetAdvFVal("XXX","XXX_ID", xFilial("XXX") + oModelZLR:GetValue("ZLR_CODSEG"))
			Aadd(aUserS, cId)
		EndIf
	Next nX
	*/

Return lRet
