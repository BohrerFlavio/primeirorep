#INCLUDE "TOTVS.CH"
#INCLUDE "RESTFUL.CH"
#INCLUDE "FILEIO.CH"
#INCLUDE "XMLXFUN.CH"
#INCLUDE "COLORS.CH"
#INCLUDE "TOPCONN.CH"
#INCLUDE "FWMVCDEF.CH"

#DEFINE CRLF Chr(13) + Chr(10)

//--------------------------------------------------------------------------------------
/*/{Protheus.doc} ATUA_005
@Type			: Função de Usuário
@Sample			: U_ATUA_005()
@Description	: Rotina de REST para buscar POST do Contas a Pagar da Atua Sistemas
@Param			: N/A
@Return			: Nulo
@ --------------|-----------------------------------------------------------------------
@Author			: Evandro Mugnol
@Since			: Fev/2024
@version		: Protheus 12.1.2210 e posteriores
@Comments		: N/A
/*/
//--------------------------------------------------------------------------------------
User Function ATUA_005(_cCNPJ,_dDtIni,_dDtFim,_cID)

	Local oRest
	Local cUrl 		  := "https://consulta.maisfrete.com.br"
	Local cPath 	  := "/api/contabilidade/index.php"
	Local cPostParams := ''
	Local aHeader     := {}

	_cCNPJReq := _cCNPJ
	_cDataIni := SubStr(FwTimeStamp(5, _dDtIni), 1, 10)
	_cDataFim := SubStr(FwTimeStamp(5, _dDtFim), 1, 10)
	_cCodID   := _cID

	aAdd(aHeader, 'Content-Type: application/x-www-form-urlencoded')
	aAdd(aHeader, 'Authorization: Basic ZXZhbmRyby5tdWdub2w6ZXY1NDc0YXR1QA==')
	aAdd(aHeader, 'Cookie: PHPSESSID=mrtb0jvaos5t2ckac5j9h508a5')
	aAdd(aHeader, 'Content-Length: 90')

	oRest := FWRest():New(cUrl)

	oRest:setPath(cPath)

	cPostParams += "conjunto_de_dados=contasAPagar"
	cPostParams += "&cnpj=" + _cCNPJReq
	cPostParams += "&dt_ini=" + _cDataIni
	cPostParams += "&dt_fim=" + _cDataFim
	cPostParams += "&id=" + AllTrim(_cCodID)

   	oRest:SetPostParams(cPostParams)

	If oRest:Post(aHeader)
		cError := ""
		nStatus := HTTPGetStatus(@cError)

		If nStatus >= 200 .And. nStatus <= 299
			If Empty(oRest:GetResult())
				MsgInfo(nStatus)
			Else
				_GetXML(oRest:GetResult())
			EndIf
		Else
			MsgStop(cError)
		EndIf
	Else
		MsgStop(oRest:GetLastError() + CRLF + oRest:GetResult())
	EndIf

	FreeObj(oRest)

Return


//-----------------------------------------------------------------------
/*/{Protheus.doc} _GetXML
Função que pega os dados do arquivo XML e grava a tabela temporária ZM8
@author     Evandro Mugnol
@since      Dez/2023
/*/
//-----------------------------------------------------------------------
Static Function _GetXML(cXML)

	Local oXML
	Local nQtBalance   := 0  	// Quantidade de contasAPagar
	Local nX		   := 1
	Local cPathBalance := "/contasAPagar"

	Default cXML := ""

	// Deleta dados da tabela ZM8 para nova carga de dados
	_cQuery1 := "DELETE FROM " + RetSqlName("ZM8")
	_cQuery1 += " WHERE ZM8_FILIAL = '" + FWxFilial("ZM8") + "'" 

	If TcSQLExec(_cQuery1) < 0	
		MsgStop(TcSqlError())
	Endif

	oXML := TXMLManager():New()

	If oXML:Parse( cXML )
		// Quantidade de filhos do nó "contasAPagar"
		nQtBalance := oXml:XPAthChildCount(cPathBalance)
		
		While nX <= nQtBalance

			_cIdPag  := oXml:XPathGetNodeValue('/contasAPagar/contaAPagar[' + str(nX) + ']/id')
			_cNumTit := oXml:XPathGetNodeValue('/contasAPagar/contaAPagar[' + str(nX) + ']/numero')
			_cParTit := oXml:XPathGetNodeValue('/contasAPagar/contaAPagar[' + str(nX) + ']/parcela')
			_cEmiTit := oXml:XPathGetNodeValue('/contasAPagar/contaAPagar[' + str(nX) + ']/emissao')
			_cVctTit := oXml:XPathGetNodeValue('/contasAPagar/contaAPagar[' + str(nX) + ']/vencimento')
			_nValTit := Val(StrTran(oXml:XPathGetNodeValue('/contasAPagar/contaAPagar[' + str(nX) + ']/valor'),",","."))
			_nAcrTit := Val(StrTran(oXml:XPathGetNodeValue('/contasAPagar/contaAPagar[' + str(nX) + ']/vlAcrescimo'),",","."))
			_nDesTit := Val(StrTran(oXml:XPathGetNodeValue('/contasAPagar/contaAPagar[' + str(nX) + ']/vlDesconto'),",","."))
			_nJurTit := Val(StrTran(oXml:XPathGetNodeValue('/contasAPagar/contaAPagar[' + str(nX) + ']/vlJuro'),",","."))
			_nMulTit := Val(StrTran(oXml:XPathGetNodeValue('/contasAPagar/contaAPagar[' + str(nX) + ']/vlMulta'),",","."))
			_cCgcFav := oXml:XPathGetNodeValue('/contasAPagar/contaAPagar[' + str(nX) + ']/cnpjCpfFavorecido')
			_cIdDesp := oXml:XPathGetNodeValue('/contasAPagar/contaAPagar[' + str(nX) + ']/despesas/despesa/id')
			
			// Cria registros na tabela intermediária de importação dos Contas a Pagar importados da Atua
			DbSelectArea("ZM8")
			Reclock("ZM8",.T.)
			ZM8->ZM8_FILIAL := FWxFilial("ZM8")
			ZM8->ZM8_IDPAG  := PadL(AllTrim(_cIdPag), TamSX3("ZM8_IDPAG")[01], "0")
			ZM8->ZM8_NUMPAG := _cNumTit
			ZM8->ZM8_PARPAG := _cParTit
			ZM8->ZM8_EMIPAG := Ctod(Substr(_cEmiTit,09,02) + "/" + Substr(_cEmiTit,06,02) + "/" + Substr(_cEmiTit,01,04))
			ZM8->ZM8_VCTPAG := Ctod(Substr(_cVctTit,09,02) + "/" + Substr(_cVctTit,06,02) + "/" + Substr(_cVctTit,01,04))
			ZM8->ZM8_VLRPAG := _nValTit
			ZM8->ZM8_ACRPAG := _nAcrTit
			ZM8->ZM8_DESPAG := _nDesTit
			ZM8->ZM8_JURPAG := _nJurTit
			ZM8->ZM8_MULPAG := _nMulTit
			ZM8->ZM8_FAVPAG := _cCgcFav
			ZM8->ZM8_IDDESP := PadL(AllTrim(_cIdDesp), TamSX3("ZM8_IDDESP")[01], "0")
			MsUnlock()

			nX++
		EndDo	

		oXML := Nil
	Else
		MsgAlert("Error: " + oXML:Error())
		Return
	EndIf

Return
