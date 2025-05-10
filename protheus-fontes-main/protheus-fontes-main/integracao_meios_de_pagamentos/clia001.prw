#INCLUDE "TOTVS.CH"
#INCLUDE "FWMVCDEF.CH"

//-------------------------------------------------------------------
/*/{Protheus.doc} ModelDef
Definição do Model da tela de Cartão de Crédito por Cliente que será usado no processo de integração dos Meios de Pagamentos
@author     Evandro
@since      Out/2020
@return     N/A
@obs        N/A
/*/
//-------------------------------------------------------------------
Static Function ModelDef()

	Local oStruSA1 := FWFormStruct(1, "SA1", {|cCampo| ValidaCpo(cCampo,"SA1")})
	Local oStruZK1 := FWFormStruct(1, "ZK1", {|cCampo| ValidaCpo(cCampo,"ZK1")}) 					    
	Local oModel
	Local aRelation := {{'ZK1_FILIAL','xFilial("ZK1")'},{'ZK1_CODCLI','A1_COD'},{'ZK1_LOJCLI','A1_LOJA'}}

	oModel := MPFormModel():New("CLIA001", ,{ |oModel| CLIA001Pos(oModel)})	

	oModel:AddFields("SA1MASTER",,oStruSA1)
	oModel:AddGrid("ZK1DETAIL","SA1MASTER",oStruZK1)

	oModel:SetPrimaryKey({'ZK1_FILIAL', 'ZK1_CODCLI', 'ZK1_LOJCLI', 'ZK1_CCRED'})

	oModel:GetModel("ZK1DETAIL"):SetUniqueLine({"ZK1_CCRED"})		
	oModel:SetRelation("ZK1DETAIL", aRelation, ZK1->(IndexKey(1)))

	oModel:SetVldActivate({|oModel| ModelValid(oModel)})

	oStruSA1:SetProperty("A1_NOME",MODEL_FIELD_WHEN,{||.F.})
	oStruSA1:SetProperty("A1_CGC",MODEL_FIELD_WHEN,{||.F.})

Return oModel


//-------------------------------------------------------------------
/*/{Protheus.doc} ViewDef
Definição do View da tela de Cartão de Crédito por Cliente que será usado no processo de integração dos Meios de Pagamentos
@author     Evandro
@since      Out/2020
@return     N/A
@obs        N/A
/*/
//-------------------------------------------------------------------
Static Function ViewDef()

	Local oModel   := FWLoadModel("CLIA001")
	Local oStruSA1 := FWFormStruct(2,"SA1", {|cCampo| ValidaCpo(cCampo,"SA1")})
	Local oStruZK1 := FWFormStruct(2,"ZK1", {|cCampo| ValidaCpo(cCampo,"ZK1")})
	Local oView

	oView := FWFormView():New()
	oView:SetModel(oModel)
	oView:AddField("ViewField",oStruSA1,"SA1MASTER")
	oView:AddGrid("ViewGrid",oStruZK1,"ZK1DETAIL")

	oView:CreateHorizontalBox("ViewSA1",30) 
	oView:CreateHorizontalBox("GridZK1",70)

	oView:SetOwnerView("ViewField","ViewSA1")	 
	oView:SetOwnerView("ViewGrid","GridZK1") 

	oView:EnableTitleView("ViewField",OemToANSI("Dados do Cliente"))
	oView:EnableTitleView("ViewGrid",OemToANSI("Cartões de Crédito que podem ser utilizados. Importante: Definir apenas 1(um) cartão preferencial"))

Return oView


//-------------------------------------------------------------------
/*/{Protheus.doc} ValidaCpo
Função para selecionar os campos do Model e View
@author     Evandro
@since      Out/2020
@return     N/A
@obs        N/A
/*/
//-------------------------------------------------------------------
Static Function ValidaCpo(cCampo, cAlias)

	Local lRet 	   := .F.
	Local cNomeCpo := ""

	cNomeCpo := AllTrim(cCampo)

	If cAlias == "SA1"			// Campo do SA1 para mostrar no cabeçalho
		If cNomeCpo == "A1_FILIAL" .OR. cNomeCpo == "A1_COD" .OR. cNomeCpo == "A1_LOJA" .OR. cNomeCpo == "A1_NOME" .OR. cNomeCpo == "A1_CGC" 
			lRet := .T.
		Endif
	ElseIf cAlias == "ZK1"		// Campos da ZK1 para não mostrar na Grid
		lRet := .T.
		If cNomeCpo == "ZK1_CODCLI" .OR. cNomeCpo == "ZK1_LOJCLI"
			lRet := .F.
		Endif
	Endif

Return lRet


//------------------------------------------------------------------------
/*/{Protheus.doc} ModelValid
Função para validar o Modelo MVC - Somente irá validar se o Cliente não estiver bloqueado 
@author     Evandro
@since      Out/2020
@return 	lRet, Se .T. o Model poderá ser utilizado, se .F. não 
@obs        N/A
/*/
//------------------------------------------------------------------------
Static Function ModelValid(oModel)

	Local lRet := .T.
	Local cBloq := AllTrim(SA1->A1_MSBLQL)

	IF cBloq == '1'
		lRet := .F.
		Help(,,"ModelValid CLIA001",,OemToANSI("Não é possível associar um Cartão de Crédito à um Cliente bloqueado."), 1, 0 )
	Endif

Return lRet


//-------------------------------------------------------------------
/*/{Protheus.doc} CLIA001Pos
Função para validação complementar (<descrever se necessário utilizar>)
@author     Evandro
@since      Out/2020
@param 		oModel, objeto, Objeto Model da rotina
@return 	lógico,Indica se o registro foi validado 
@obs        N/A
/*/
//-------------------------------------------------------------------
Static Function CLIA001Pos(oModel)

	Local lRet		 := .T.
	//Local nOperation := oModel:GetOperation()
	Local oModelZK1	 := oModel:GetModel('ZK1DETAIL')
	Local oModelSA1	 := oModel:GetModel('SA1MASTER')
	Local nX		 := 0

	_TotSim := 0
	_TotNao := 0
	For nX := 1 To oModelZK1:Length()
		oModelZK1:GoLine(nX)

		If !oModelZK1:IsDeleted()
			_cCNPJCPF := fBuscaCpo("SA1", 1, xFilial("SA1") + oModelSA1:GetValue("A1_COD") + oModelSA1:GetValue("A1_LOJA"), "A1_CGC")
			_cDesc 	  := fBuscaCpo("ZK0", 1, xFilial("ZK0") + oModelZK1:GetValue("ZK1_CODINT"), "ZK0_NOMINT")
			_cCardCod := Right(AllTrim(oModelZK1:GetValue("ZK1_CCRED")),4) + AllTrim(oModelZK1:GetValue("ZK1_CODCVV"))
			
			oModel:SetValue('ZK1DETAIL', 'ZK1_CGCCLI', _cCNPJCPF)
			oModel:SetValue('ZK1DETAIL', 'ZK1_NOMINT', _cDesc)
			oModel:SetValue('ZK1DETAIL', 'ZK1_CARDCD', _cCardCod)

			_cCCPref := oModelZK1:GetValue("ZK1_CCPREF")

			If _cCCPref == "1"
				_TotSim := _TotSim + 1
			Else
				_TotNao := _TotNao + 1
			Endif

		EndIf

	Next nX

	If _TotSim > 1
		MsgAlert("Não é permitido informar mais que um cartão preferencial. Verifique!")
		lRet := .F.
	Endif
	
Return lRet
