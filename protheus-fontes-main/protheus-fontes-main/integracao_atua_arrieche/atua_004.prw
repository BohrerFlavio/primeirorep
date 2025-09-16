#INCLUDE "TOTVS.CH"
#INCLUDE "RESTFUL.CH"
#INCLUDE "FILEIO.CH"
#INCLUDE "XMLXFUN.CH"
#INCLUDE "COLORS.CH"
#INCLUDE "TOPCONN.CH"
#INCLUDE "FWMVCDEF.CH"

#DEFINE CRLF Chr(13) + Chr(10)

// Legendas
Static oBmpVerde    := LoadBitmap( GetResources(), "BR_VERDE")
Static oBmpVermelho := LoadBitmap( GetResources(), "BR_VERMELHO")
Static oBmpLaranja  := LoadBitmap( GetResources(), "BR_LARANJA")
Static oBmpCancel   := LoadBitmap( GetResources(), "BR_CANCEL")
Static oBmpPreto    := LoadBitmap( GetResources(), "BR_PRETO")

//--------------------------------------------------------------------------------------
/*/{Protheus.doc} ATUA_004
@Type			: Função de Usuário
@Sample			: U_ATUA_004()
@Description	: Rotina de REST para buscar POST do CTRCs da Atua Sistemas
@Param			: N/A
@Return			: Nulo
@ --------------|-----------------------------------------------------------------------
@Author			: Evandro Mugnol
@Since			: Dez/2023
@version		: Protheus 12.1.2210 e posteriores
@Comments		: N/A
/*/
//--------------------------------------------------------------------------------------
User Function ATUA_004(_cCNPJ,_dDtIni,_dDtFim,_cID,_cCte,_cAmb)

	Local oRest
	Local cUrl 		  := "https://consulta.maisfrete.com.br"
	Local cPath 	  := "/api/contabilidade/index.php"
	Local cPostParams := ''
	Local aHeader     := {}
	Local cBoundary   := '----WebKitFormBoundary7MA4YWxkTrZu0gW'

	_cCNPJReq := _cCNPJ
	_cDataIni := SubStr(FwTimeStamp(5, _dDtIni), 1, 10)
	_cDataFim := SubStr(FwTimeStamp(5, _dDtFim), 1, 10)
	_cCodID   := _cID
	_cChvCte  := _cCte
	_cCodAmb  := _cAmb

	aAdd(aHeader, 'Authorization: Basic ZXZhbmRyby5tdWdub2w6ZXY1NDc0YXR1QA==')
	aAdd(aHeader, 'Cookie: PHPSESSID=j45a50h2m9emkvs7s4oioq33ti')
	aAdd(aHeader, 'Content-Length: 529')
	aAdd(aHeader, 'Content-Type: multipart/form-data; boundary=' + cBoundary)

	oRest := FWRest():New(cUrl)

	oRest:setPath(cPath)

	cPostParams += CRLF
	cPostParams += '--' + cBoundary
	cPostParams += CRLF
	cPostParams += 'Content-Disposition: form-data; name="conjunto_de_dados"'
	cPostParams += CRLF
	cPostParams += CRLF
	cPostParams += 'ctrcs'
	cPostParams += CRLF

	cPostParams += '--' + cBoundary
	cPostParams += CRLF
	cPostParams += 'Content-Disposition: form-data; name="cnpj"'
	cPostParams += CRLF
	cPostParams += CRLF
	cPostParams += _cCNPJReq
	cPostParams += CRLF

	cPostParams += '--' + cBoundary
	cPostParams += CRLF
	cPostParams += 'Content-Disposition: form-data; name="dt_ini"'
	cPostParams += CRLF
	cPostParams += CRLF
	cPostParams += _cDataIni
	cPostParams += CRLF

	cPostParams += '--' + cBoundary
	cPostParams += CRLF
	cPostParams += 'Content-Disposition: form-data; name="dt_fim"'
	cPostParams += CRLF
	cPostParams += CRLF
	cPostParams += _cDataFim
	cPostParams += CRLF

	cPostParams += '--' + cBoundary
	cPostParams += CRLF
	cPostParams += 'Content-Disposition: form-data; name="id"'
	cPostParams += CRLF
	cPostParams += CRLF
	cPostParams += AllTrim(_cCodID)
	cPostParams += CRLF

	cPostParams += '--' + cBoundary
	cPostParams += CRLF
	cPostParams += 'Content-Disposition: form-data; name="ambiente"'
	cPostParams += CRLF
	cPostParams += CRLF
	cPostParams += AllTrim(_cCodAmb)
	cPostParams += CRLF

	cPostParams += '--' + cBoundary
	cPostParams += CRLF
	cPostParams += 'Content-Disposition: form-data; name="chave_cte"'
	cPostParams += CRLF
	cPostParams += CRLF
	cPostParams += AllTrim(_cChvCte)
	cPostParams += CRLF
	cPostParams += '--' + cBoundary + '--'
	cPostParams += CRLF

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
Função que pega os dados do arquivo XML e grava a tabela temporária ZM3
@author     Evandro Mugnol
@since      Dez/2023
/*/
//-----------------------------------------------------------------------
Static Function _GetXML(cXML)

	Local oXML
	Local nQtBalance   := 0  	// Quantidade de ctrcs
	Local nQtProduto   := 0  	// Quantidade de produtos por ctrc
	Local aListBalance := {}
	Local aListProduto := {}
	Local nX		   := 1
	Local nY		   := 1
	Local cPathBalance := "/ctrcs"
	Local cPathProduto := "/produtos"
	Local aItensBal    := {}
	Local aItensPrd    := {}

	Default cXML := ""

	// Deleta dados da tabela ZM4 para nova carga de dados
	_cQuery1 := "DELETE FROM " + RetSqlName("ZM4")
	_cQuery1 += " WHERE ZM4_FILIAL = '" + FWxFilial("ZM4") + "'" 

	If TcSQLExec(_cQuery1) < 0	
		MsgStop(TcSqlError())
	Endif

	// Deleta dados da tabela ZM5 para nova carga de dados
	_cQuery2 := "DELETE FROM " + RetSqlName("ZM5")
	_cQuery2 += " WHERE ZM5_FILIAL = '" + FWxFilial("ZM5") + "'" 

	If TcSQLExec(_cQuery2) < 0	
		MsgStop(TcSqlError())
	Endif

	oXML := TXMLManager():New()

	If oXML:Parse( cXML )
		// Quantidade de filhos do nó "ctrcs"
		nQtBalance := oXml:XPAthChildCount(cPathBalance)
		
		// Retorna um array com os nós filhos do nó apontado pela expressão cPathBalance 
		aListBalance := oXml:XPathGetChildArray(cPathBalance)

		While nX <= nQtBalance
			aItensBal := oXml:XPathGetChildArray(aListBalance[nX,2])  // Gera Array com os filhos.

			_cIdCtrc := oXml:XPathGetNodeValue('/ctrcs/ctrc[' + str(nX) + ']/id')
			_cAmbiem := oXml:XPathGetNodeValue('/ctrcs/ctrc[' + str(nX) + ']/ambiente')
			_cSituac := oXml:XPathGetNodeValue('/ctrcs/ctrc[' + str(nX) + ']/situacao')
			_cCodRet := oXml:XPathGetNodeValue('/ctrcs/ctrc[' + str(nX) + ']/status')
			_cModelo := oXml:XPathGetNodeValue('/ctrcs/ctrc[' + str(nX) + ']/modelo')
			_cDocto  := oXml:XPathGetNodeValue('/ctrcs/ctrc[' + str(nX) + ']/numero')
			_cSerie  := oXml:XPathGetNodeValue('/ctrcs/ctrc[' + str(nX) + ']/serie')
			_cIdFret := oXml:XPathGetNodeValue('/ctrcs/ctrc[' + str(nX) + ']/idFrete')
			_cIdServ := oXml:XPathGetNodeValue('/ctrcs/ctrc[' + str(nX) + ']/idServico')
			_cIdLota := oXml:XPathGetNodeValue('/ctrcs/ctrc[' + str(nX) + ']/idLotacao')
			_cDtEmis := oXml:XPathGetNodeValue('/ctrcs/ctrc[' + str(nX) + ']/emissao')
			_cCifFob := oXml:XPathGetNodeValue('/ctrcs/ctrc[' + str(nX) + ']/cifFob')
			_ChavCte := oXml:XPathGetNodeValue('/ctrcs/ctrc[' + str(nX) + ']/cte/chave')
			_ProtCte := oXml:XPathGetNodeValue('/ctrcs/ctrc[' + str(nX) + ']/cte/protocolo')
			_cTipCte := oXml:XPathGetNodeValue('/ctrcs/ctrc[' + str(nX) + ']/cte/tpCte')
			_cChvRef := oXml:XPathGetNodeValue('/ctrcs/ctrc[' + str(nX) + ']/cte/nrChaveRef')
			_nVlrFre := Val(StrTran(oXml:XPathGetNodeValue('/ctrcs/ctrc[' + str(nX) + ']/vlFrete'),",","."))
			_nVlrTot := Val(StrTran(oXml:XPathGetNodeValue('/ctrcs/ctrc[' + str(nX) + ']/vlTotal'),",","."))
			_nVlrPed := Val(StrTran(oXml:XPathGetNodeValue('/ctrcs/ctrc[' + str(nX) + ']/vlPegadio'),",","."))
			_cTipPed := oXml:XPathGetNodeValue('/ctrcs/ctrc[' + str(nX) + ']/tipoPegadio')
			_IbgeOri := oXml:XPathGetNodeValue('/ctrcs/ctrc[' + str(nX) + ']/ibgeOrigem')
			_IbgeDes := oXml:XPathGetNodeValue('/ctrcs/ctrc[' + str(nX) + ']/ibgeDestino')
			_cUfOrig := oXml:XPathGetNodeValue('/ctrcs/ctrc[' + str(nX) + ']/ufOrigem')
			_cUfDest := oXml:XPathGetNodeValue('/ctrcs/ctrc[' + str(nX) + ']/ufDestino')
			_cCfop   := oXml:XPathGetNodeValue('/ctrcs/ctrc[' + str(nX) + ']/cfop')
			_cCstIcm := oXml:XPathGetNodeValue('/ctrcs/ctrc[' + str(nX) + ']/icms/cst')
			_nBasIcm := Val(StrTran(oXml:XPathGetNodeValue('/ctrcs/ctrc[' + str(nX) + ']/icms/vlBase'),",","."))
			_nValIcm := Val(StrTran(oXml:XPathGetNodeValue('/ctrcs/ctrc[' + str(nX) + ']/icms/valor'),",","."))
			_nVstIcm := Val(StrTran(oXml:XPathGetNodeValue('/ctrcs/ctrc[' + str(nX) + ']/icms/valorSt'),",","."))
			_nOutIcm := Val(StrTran(oXml:XPathGetNodeValue('/ctrcs/ctrc[' + str(nX) + ']/icms/vlOutras'),",","."))
			_nIseIcm := Val(StrTran(oXml:XPathGetNodeValue('/ctrcs/ctrc[' + str(nX) + ']/icms/vlIsento'),",","."))
			_nVcrIcm := Val(StrTran(oXml:XPathGetNodeValue('/ctrcs/ctrc[' + str(nX) + ']/icms/vlCredito'),",","."))
			_nBOutUf := Val(StrTran(oXml:XPathGetNodeValue('/ctrcs/ctrc[' + str(nX) + ']/icms/vlBaseOutraUF'),",","."))
			_nVOutUf := Val(StrTran(oXml:XPathGetNodeValue('/ctrcs/ctrc[' + str(nX) + ']/icms/vlIcmsOutraUF'),",","."))
			
			_cIdEmi  := oXml:XPathGetNodeValue('/ctrcs/ctrc[' + str(nX) + ']/emitente/id')
			_cCgcEmi := oXml:XPathGetNodeValue('/ctrcs/ctrc[' + str(nX) + ']/emitente/cnpjCpf')

			_Flag := .T.
			DbSelectArea("SA1")
			DbSetOrder(3)
			DbSeek(FWxFilial("SA1") + _cCgcEmi)
			While !Eof() .And. SA1->A1_FILIAL + SA1->A1_CGC == FWxFilial("SA1") + _cCgcEmi
				If SA1->A1_MSBLQL == "2"
					_cCodEmi := SA1->A1_COD
					_cLojEmi := SA1->A1_LOJA
					_Flag := .F.
					Exit
				EndIf
				DbSelectArea("SA1")
				DbSkip()
			EndDo
			
			If _Flag		
				_cCodEmi := GetAdvFVal("SA1", "A1_COD",  FWxFilial("SA1") + _cCgcEmi, 3, Space(TamSx3("A1_COD")[1]),  .T.)
				_cLojEmi := GetAdvFVal("SA1", "A1_LOJA", FWxFilial("SA1") + _cCgcEmi, 3, Space(TamSx3("A1_LOJA")[1]), .T.)
			EndIf

			_cNomEmi := oXml:XPathGetNodeValue('/ctrcs/ctrc[' + str(nX) + ']/emitente/nome')
			_cFanEmi := oXml:XPathGetNodeValue('/ctrcs/ctrc[' + str(nX) + ']/emitente/fantasia')
			_cIeEmi  := oXml:XPathGetNodeValue('/ctrcs/ctrc[' + str(nX) + ']/emitente/ie')
			_cImEmi  := oXml:XPathGetNodeValue('/ctrcs/ctrc[' + str(nX) + ']/emitente/im')
			_cTipEmi := oXml:XPathGetNodeValue('/ctrcs/ctrc[' + str(nX) + ']/emitente/tipo')
			_cUfEmi  := oXml:XPathGetNodeValue('/ctrcs/ctrc[' + str(nX) + ']/emitente/uf')
			_cMunEmi := oXml:XPathGetNodeValue('/ctrcs/ctrc[' + str(nX) + ']/emitente/cidade')
			_cCdmEmi := oXml:XPathGetNodeValue('/ctrcs/ctrc[' + str(nX) + ']/emitente/ibge')
			_cEndEmi := oXml:XPathGetNodeValue('/ctrcs/ctrc[' + str(nX) + ']/emitente/endereco')
			_cComEmi := oXml:XPathGetNodeValue('/ctrcs/ctrc[' + str(nX) + ']/emitente/complemento')
			_cNumEmi := oXml:XPathGetNodeValue('/ctrcs/ctrc[' + str(nX) + ']/emitente/numero')
			_cCepEmi := oXml:XPathGetNodeValue('/ctrcs/ctrc[' + str(nX) + ']/emitente/cep')
			_cBaiEmi := oXml:XPathGetNodeValue('/ctrcs/ctrc[' + str(nX) + ']/emitente/bairro')
			_cTelEmi := oXml:XPathGetNodeValue('/ctrcs/ctrc[' + str(nX) + ']/emitente/telefone')
			_cEmlEmi := oXml:XPathGetNodeValue('/ctrcs/ctrc[' + str(nX) + ']/emitente/email')

			_cIdRem  := oXml:XPathGetNodeValue('/ctrcs/ctrc[' + str(nX) + ']/remetente/id')
			_cCgcRem := oXml:XPathGetNodeValue('/ctrcs/ctrc[' + str(nX) + ']/remetente/cnpjCpf')

			_Flag := .T.
			DbSelectArea("SA1")
			DbSetOrder(3)
			DbSeek(FWxFilial("SA1") + _cCgcRem)
			While !Eof() .And. SA1->A1_FILIAL + SA1->A1_CGC == FWxFilial("SA1") + _cCgcRem
				If SA1->A1_MSBLQL == "2"
					_cCodRem := SA1->A1_COD
					_cLojRem := SA1->A1_LOJA
					_Flag := .F.
					Exit
				EndIf
				DbSelectArea("SA1")
				DbSkip()
			EndDo
			
			If _Flag		
				_cCodRem := GetAdvFVal("SA1", "A1_COD",  FWxFilial("SA1") + _cCgcRem, 3, Space(TamSx3("A1_COD")[1]),  .T.)
				_cLojRem := GetAdvFVal("SA1", "A1_LOJA", FWxFilial("SA1") + _cCgcRem, 3, Space(TamSx3("A1_LOJA")[1]), .T.)
			EndIf

			_cNomRem := oXml:XPathGetNodeValue('/ctrcs/ctrc[' + str(nX) + ']/remetente/nome')
			_cFanRem := oXml:XPathGetNodeValue('/ctrcs/ctrc[' + str(nX) + ']/remetente/fantasia')
			_cIeRem  := oXml:XPathGetNodeValue('/ctrcs/ctrc[' + str(nX) + ']/remetente/ie')
			_cImRem  := oXml:XPathGetNodeValue('/ctrcs/ctrc[' + str(nX) + ']/remetente/im')
			_cTipRem := oXml:XPathGetNodeValue('/ctrcs/ctrc[' + str(nX) + ']/remetente/tipo')
			_cUfRem  := oXml:XPathGetNodeValue('/ctrcs/ctrc[' + str(nX) + ']/remetente/uf')
			_cMunRem := oXml:XPathGetNodeValue('/ctrcs/ctrc[' + str(nX) + ']/remetente/cidade')
			_cCdmRem := oXml:XPathGetNodeValue('/ctrcs/ctrc[' + str(nX) + ']/remetente/ibge')
			_cEndRem := oXml:XPathGetNodeValue('/ctrcs/ctrc[' + str(nX) + ']/remetente/endereco')
			_cComRem := oXml:XPathGetNodeValue('/ctrcs/ctrc[' + str(nX) + ']/remetente/complemento')
			_cNumRem := oXml:XPathGetNodeValue('/ctrcs/ctrc[' + str(nX) + ']/remetente/numero')
			_cCepRem := oXml:XPathGetNodeValue('/ctrcs/ctrc[' + str(nX) + ']/remetente/cep')
			_cBaiRem := oXml:XPathGetNodeValue('/ctrcs/ctrc[' + str(nX) + ']/remetente/bairro')
			_cTelRem := oXml:XPathGetNodeValue('/ctrcs/ctrc[' + str(nX) + ']/remetente/telefone')
			_cEmlRem := oXml:XPathGetNodeValue('/ctrcs/ctrc[' + str(nX) + ']/remetente/email')
			
			_cIdDes  := oXml:XPathGetNodeValue('/ctrcs/ctrc[' + str(nX) + ']/destinatario/id')
			_cCgcDes := oXml:XPathGetNodeValue('/ctrcs/ctrc[' + str(nX) + ']/destinatario/cnpjCpf')
			
			_Flag := .T.
			DbSelectArea("SA1")
			DbSetOrder(3)
			DbSeek(FWxFilial("SA1") + _cCgcDes)
			While !Eof() .And. SA1->A1_FILIAL + SA1->A1_CGC == FWxFilial("SA1") + _cCgcDes
				If SA1->A1_MSBLQL == "2"
					_cCodDes := SA1->A1_COD
					_cLojDes := SA1->A1_LOJA
					_Flag := .F.
					Exit
				EndIf
				DbSelectArea("SA1")
				DbSkip()
			EndDo
			
			If _Flag		
				_cCodDes := GetAdvFVal("SA1", "A1_COD",  FWxFilial("SA1") + _cCgcDes, 3, Space(TamSx3("A1_COD")[1]),  .T.)
				_cLojDes := GetAdvFVal("SA1", "A1_LOJA", FWxFilial("SA1") + _cCgcDes, 3, Space(TamSx3("A1_LOJA")[1]), .T.)
			EndIf

			_cNomDes := oXml:XPathGetNodeValue('/ctrcs/ctrc[' + str(nX) + ']/destinatario/nome')
			_cFanDes := oXml:XPathGetNodeValue('/ctrcs/ctrc[' + str(nX) + ']/destinatario/fantasia')
			_cIeDes  := oXml:XPathGetNodeValue('/ctrcs/ctrc[' + str(nX) + ']/destinatario/ie')
			_cImDes  := oXml:XPathGetNodeValue('/ctrcs/ctrc[' + str(nX) + ']/destinatario/im')
			_cTipDes := oXml:XPathGetNodeValue('/ctrcs/ctrc[' + str(nX) + ']/destinatario/tipo')
			_cUfDes  := oXml:XPathGetNodeValue('/ctrcs/ctrc[' + str(nX) + ']/destinatario/uf')
			_cMunDes := oXml:XPathGetNodeValue('/ctrcs/ctrc[' + str(nX) + ']/destinatario/cidade')
			_cCdmDes := oXml:XPathGetNodeValue('/ctrcs/ctrc[' + str(nX) + ']/destinatario/ibge')
			_cEndDes := oXml:XPathGetNodeValue('/ctrcs/ctrc[' + str(nX) + ']/destinatario/endereco')
			_cComDes := oXml:XPathGetNodeValue('/ctrcs/ctrc[' + str(nX) + ']/destinatario/complemento')
			_cNumDes := oXml:XPathGetNodeValue('/ctrcs/ctrc[' + str(nX) + ']/destinatario/numero')
			_cCepDes := oXml:XPathGetNodeValue('/ctrcs/ctrc[' + str(nX) + ']/destinatario/cep')
			_cBaiDes := oXml:XPathGetNodeValue('/ctrcs/ctrc[' + str(nX) + ']/destinatario/bairro')
			_cTelDes := oXml:XPathGetNodeValue('/ctrcs/ctrc[' + str(nX) + ']/destinatario/telefone')
			_cEmlDes := oXml:XPathGetNodeValue('/ctrcs/ctrc[' + str(nX) + ']/destinatario/email')
			
			_cIdPag  := oXml:XPathGetNodeValue('/ctrcs/ctrc[' + str(nX) + ']/pagador/id')
			_cCgcPag := oXml:XPathGetNodeValue('/ctrcs/ctrc[' + str(nX) + ']/pagador/cnpjCpf')

			_Flag := .T.
			DbSelectArea("SA1")
			DbSetOrder(3)
			DbSeek(FWxFilial("SA1") + _cCgcPag)
			While !Eof() .And. SA1->A1_FILIAL + SA1->A1_CGC == FWxFilial("SA1") + _cCgcPag
				If SA1->A1_MSBLQL == "2"
					_cCodPag := SA1->A1_COD
					_cLojPag := SA1->A1_LOJA
					_Flag := .F.
					Exit
				EndIf
				DbSelectArea("SA1")
				DbSkip()
			EndDo
			
			If _Flag		
				_cCodPag := GetAdvFVal("SA1", "A1_COD",  FWxFilial("SA1") + _cCgcPag, 3, Space(TamSx3("A1_COD")[1]),  .T.)
				_cLojPag := GetAdvFVal("SA1", "A1_LOJA", FWxFilial("SA1") + _cCgcPag, 3, Space(TamSx3("A1_LOJA")[1]), .T.)
			EndIf

			_cNomPag := oXml:XPathGetNodeValue('/ctrcs/ctrc[' + str(nX) + ']/pagador/nome')
			_cFanPag := oXml:XPathGetNodeValue('/ctrcs/ctrc[' + str(nX) + ']/pagador/fantasia')
			_cIePag  := oXml:XPathGetNodeValue('/ctrcs/ctrc[' + str(nX) + ']/pagador/ie')
			_cImPag  := oXml:XPathGetNodeValue('/ctrcs/ctrc[' + str(nX) + ']/pagador/im')
			_cTipPag := oXml:XPathGetNodeValue('/ctrcs/ctrc[' + str(nX) + ']/pagador/tipo')
			_cUfPag  := oXml:XPathGetNodeValue('/ctrcs/ctrc[' + str(nX) + ']/pagador/uf')
			_cMunPag := oXml:XPathGetNodeValue('/ctrcs/ctrc[' + str(nX) + ']/pagador/cidade')
			_cCdmPag := oXml:XPathGetNodeValue('/ctrcs/ctrc[' + str(nX) + ']/pagador/ibge')
			_cEndPag := oXml:XPathGetNodeValue('/ctrcs/ctrc[' + str(nX) + ']/pagador/endereco')
			_cComPag := oXml:XPathGetNodeValue('/ctrcs/ctrc[' + str(nX) + ']/pagador/complemento')
			_cNumPag := oXml:XPathGetNodeValue('/ctrcs/ctrc[' + str(nX) + ']/pagador/numero')
			_cCepPag := oXml:XPathGetNodeValue('/ctrcs/ctrc[' + str(nX) + ']/pagador/cep')
			_cBaiPag := oXml:XPathGetNodeValue('/ctrcs/ctrc[' + str(nX) + ']/pagador/bairro')
			_cTelPag := oXml:XPathGetNodeValue('/ctrcs/ctrc[' + str(nX) + ']/pagador/telefone')
			_cEmlPag := oXml:XPathGetNodeValue('/ctrcs/ctrc[' + str(nX) + ']/pagador/email')
			
			_cIdRec  := oXml:XPathGetNodeValue('/ctrcs/ctrc[' + str(nX) + ']/recebedor/id')
			_cCgcRec := oXml:XPathGetNodeValue('/ctrcs/ctrc[' + str(nX) + ']/recebedor/cnpjCpf')

			_Flag := .T.
			DbSelectArea("SA1")
			DbSetOrder(3)
			DbSeek(FWxFilial("SA1") + _cCgcRec)
			While !Eof() .And. SA1->A1_FILIAL + SA1->A1_CGC == FWxFilial("SA1") + _cCgcRec
				If SA1->A1_MSBLQL == "2"
					_cCodRec := SA1->A1_COD
					_cLojRec := SA1->A1_LOJA
					_Flag := .F.
					Exit
				EndIf
				DbSelectArea("SA1")
				DbSkip()
			EndDo
			
			If _Flag		
				_cCodRec := GetAdvFVal("SA1", "A1_COD",  FWxFilial("SA1") + _cCgcRec, 3, Space(TamSx3("A1_COD")[1]),  .T.)
				_cLojRec := GetAdvFVal("SA1", "A1_LOJA", FWxFilial("SA1") + _cCgcRec, 3, Space(TamSx3("A1_LOJA")[1]), .T.)
			EndIf

			_cNomRec := oXml:XPathGetNodeValue('/ctrcs/ctrc[' + str(nX) + ']/recebedor/nome')
			_cFanRec := oXml:XPathGetNodeValue('/ctrcs/ctrc[' + str(nX) + ']/recebedor/fantasia')
			_cIeRec  := oXml:XPathGetNodeValue('/ctrcs/ctrc[' + str(nX) + ']/recebedor/ie')
			_cImRec  := oXml:XPathGetNodeValue('/ctrcs/ctrc[' + str(nX) + ']/recebedor/im')
			_cTipRec := oXml:XPathGetNodeValue('/ctrcs/ctrc[' + str(nX) + ']/recebedor/tipo')
			_cUfRec  := oXml:XPathGetNodeValue('/ctrcs/ctrc[' + str(nX) + ']/recebedor/uf')
			_cMunRec := oXml:XPathGetNodeValue('/ctrcs/ctrc[' + str(nX) + ']/recebedor/cidade')
			_cCdmRec := oXml:XPathGetNodeValue('/ctrcs/ctrc[' + str(nX) + ']/recebedor/ibge')
			_cEndRec := oXml:XPathGetNodeValue('/ctrcs/ctrc[' + str(nX) + ']/recebedor/endereco')
			_cComRec := oXml:XPathGetNodeValue('/ctrcs/ctrc[' + str(nX) + ']/recebedor/complemento')
			_cNumRec := oXml:XPathGetNodeValue('/ctrcs/ctrc[' + str(nX) + ']/recebedor/numero')
			_cCepRec := oXml:XPathGetNodeValue('/ctrcs/ctrc[' + str(nX) + ']/recebedor/cep')
			_cBaiRec := oXml:XPathGetNodeValue('/ctrcs/ctrc[' + str(nX) + ']/recebedor/bairro')
			_cTelRec := oXml:XPathGetNodeValue('/ctrcs/ctrc[' + str(nX) + ']/recebedor/telefone')
			_cEmlRec := oXml:XPathGetNodeValue('/ctrcs/ctrc[' + str(nX) + ']/recebedor/email')
			
			_cIdExp  := oXml:XPathGetNodeValue('/ctrcs/ctrc[' + str(nX) + ']/expedidor/id')
			_cCgcExp := oXml:XPathGetNodeValue('/ctrcs/ctrc[' + str(nX) + ']/expedidor/cnpjCpf')

			_Flag := .T.
			DbSelectArea("SA1")
			DbSetOrder(3)
			DbSeek(FWxFilial("SA1") + _cCgcExp)
			While !Eof() .And. SA1->A1_FILIAL + SA1->A1_CGC == FWxFilial("SA1") + _cCgcExp
				If SA1->A1_MSBLQL == "2"
					_cCodExp := SA1->A1_COD
					_cLojExp := SA1->A1_LOJA
					_Flag := .F.
					Exit
				EndIf
				DbSelectArea("SA1")
				DbSkip()
			EndDo
			
			If _Flag		
				_cCodExp := GetAdvFVal("SA1", "A1_COD",  FWxFilial("SA1") + _cCgcExp, 3, Space(TamSx3("A1_COD")[1]),  .T.)
				_cLojExp := GetAdvFVal("SA1", "A1_LOJA", FWxFilial("SA1") + _cCgcExp, 3, Space(TamSx3("A1_LOJA")[1]), .T.)
			EndIf
			
			_cNomExp := oXml:XPathGetNodeValue('/ctrcs/ctrc[' + str(nX) + ']/expedidor/nome')
			_cFanExp := oXml:XPathGetNodeValue('/ctrcs/ctrc[' + str(nX) + ']/expedidor/fantasia')
			_cIeExp  := oXml:XPathGetNodeValue('/ctrcs/ctrc[' + str(nX) + ']/expedidor/ie')
			_cImExp  := oXml:XPathGetNodeValue('/ctrcs/ctrc[' + str(nX) + ']/expedidor/im')
			_cTipExp := oXml:XPathGetNodeValue('/ctrcs/ctrc[' + str(nX) + ']/expedidor/tipo')
			_cUfExp  := oXml:XPathGetNodeValue('/ctrcs/ctrc[' + str(nX) + ']/expedidor/uf')
			_cMunExp := oXml:XPathGetNodeValue('/ctrcs/ctrc[' + str(nX) + ']/expedidor/cidade')
			_cCdmExp := oXml:XPathGetNodeValue('/ctrcs/ctrc[' + str(nX) + ']/expedidor/ibge')
			_cEndExp := oXml:XPathGetNodeValue('/ctrcs/ctrc[' + str(nX) + ']/expedidor/endereco')
			_cComExp := oXml:XPathGetNodeValue('/ctrcs/ctrc[' + str(nX) + ']/expedidor/complemento')
			_cNumExp := oXml:XPathGetNodeValue('/ctrcs/ctrc[' + str(nX) + ']/expedidor/numero')
			_cCepExp := oXml:XPathGetNodeValue('/ctrcs/ctrc[' + str(nX) + ']/expedidor/cep')
			_cBaiExp := oXml:XPathGetNodeValue('/ctrcs/ctrc[' + str(nX) + ']/expedidor/bairro')
			_cTelExp := oXml:XPathGetNodeValue('/ctrcs/ctrc[' + str(nX) + ']/expedidor/telefone')
			_cEmlExp := oXml:XPathGetNodeValue('/ctrcs/ctrc[' + str(nX) + ']/expedidor/email')
			
			_cIdMot  := oXml:XPathGetNodeValue('/ctrcs/ctrc[' + str(nX) + ']/motorista/id')
			_cCgcMot := oXml:XPathGetNodeValue('/ctrcs/ctrc[' + str(nX) + ']/motorista/cnpjCpf')
			_cCodMot := GetAdvFVal("DA4", "DA4_COD",  FWxFilial("DA4") + _cCgcMot, 3, Space(TamSx3("DA4_COD")[1]),  .T.)
			_cNomMot := oXml:XPathGetNodeValue('/ctrcs/ctrc[' + str(nX) + ']/motorista/nome')
			_cFanMot := oXml:XPathGetNodeValue('/ctrcs/ctrc[' + str(nX) + ']/motorista/fantasia')
			_cIeMot  := oXml:XPathGetNodeValue('/ctrcs/ctrc[' + str(nX) + ']/motorista/ie')
			_cImMot  := oXml:XPathGetNodeValue('/ctrcs/ctrc[' + str(nX) + ']/motorista/im')
			_cTipMot := oXml:XPathGetNodeValue('/ctrcs/ctrc[' + str(nX) + ']/motorista/tipo')
			_cUfMot  := oXml:XPathGetNodeValue('/ctrcs/ctrc[' + str(nX) + ']/motorista/uf')
			_cMunMot := oXml:XPathGetNodeValue('/ctrcs/ctrc[' + str(nX) + ']/motorista/cidade')
			_cCdmMot := oXml:XPathGetNodeValue('/ctrcs/ctrc[' + str(nX) + ']/motorista/ibge')
			_cEndMot := oXml:XPathGetNodeValue('/ctrcs/ctrc[' + str(nX) + ']/motorista/endereco')
			_cComMot := oXml:XPathGetNodeValue('/ctrcs/ctrc[' + str(nX) + ']/motorista/complemento')
			_cNumMot := oXml:XPathGetNodeValue('/ctrcs/ctrc[' + str(nX) + ']/motorista/numero')
			_cCepMot := oXml:XPathGetNodeValue('/ctrcs/ctrc[' + str(nX) + ']/motorista/cep')
			_cBaiMot := oXml:XPathGetNodeValue('/ctrcs/ctrc[' + str(nX) + ']/motorista/bairro')
			_cTelMot := oXml:XPathGetNodeValue('/ctrcs/ctrc[' + str(nX) + ']/motorista/telefone')
			_cEmlMot := oXml:XPathGetNodeValue('/ctrcs/ctrc[' + str(nX) + ']/motorista/email')
			
			// Cria registros na tabela intermediária de importação dos CTRCs importados da Atua
			DbSelectArea("ZM4")
			Reclock("ZM4",.T.)
			ZM4->ZM4_FILIAL := FWxFilial("ZM4")
			ZM4->ZM4_IDCTRC := PadL(AllTrim(_cIdCtrc), TamSX3("ZM4_IDCTRC")[01], "0")
			ZM4->ZM4_AMBIEN := _cAmbiem
			DO CASE
				CASE AllTrim(_cSituac) == "AUTORIZADO"
					_cSit := "2"
				CASE AllTrim(_cSituac) == "CANCELADO"
					_cSit := "1"
				OTHERWISE
					_cSit := ""
			ENDCASE
			ZM4->ZM4_SITUAC := _cSit
			DO CASE
				CASE AllTrim(_cModelo) == "NFSe"
					_cMod := "1"
				CASE AllTrim(_cModelo) == "CTe"
					_cMod := "2"
				CASE AllTrim(_cModelo) == "CTRC"
					_cMod := "3"
				CASE AllTrim(_cModelo) == "CE"
					_cMod := "4"
				OTHERWISE 
					_cMod := ""
			ENDCASE
			ZM4->ZM4_MODELO := _cMod
			ZM4->ZM4_DOCTO  := PadL(AllTrim(_cDocto), TamSX3("ZM4_DOCTO")[01], "0")
			ZM4->ZM4_SERIE  := _cSerie
			ZM4->ZM4_IDFRET := _cIdFret
			ZM4->ZM4_IDSERV := _cIdServ
			DO CASE
				CASE AllTrim(_cIdLota) == "SIM"
					_cLotac := "1"
				CASE AllTrim(_cIdLota) == "NAO"
					_cLotac := "2"
				OTHERWISE
					_cLotac := ""
			ENDCASE
			ZM4->ZM4_IDLOTA := _cLotac
			ZM4->ZM4_DTEMIS := Ctod(Substr(_cDtEmis,09,02) + "/" + Substr(_cDtEmis,06,02) + "/" + Substr(_cDtEmis,01,04))
			ZM4->ZM4_HREMIS := Substr(_cDtEmis,12,02) + Substr(_cDtEmis,15,02)
			DO CASE
				CASE AllTrim(_cCifFob) == "CIF"
					_cCF := "1"
				CASE AllTrim(_cCifFob) == "FOB"
					_cCF := "2"
				OTHERWISE
					_cCF := ""
			ENDCASE
			ZM4->ZM4_CIFFOB := _cCF
			ZM4->ZM4_CHVCTE := _ChavCte
			ZM4->ZM4_PROCTE := _ProtCte
			DO CASE
				CASE AllTrim(_cTipCte) == "NORMAL"
					_cTipo := "0"
				CASE AllTrim(_cTipCte) == "CTe de Complemento de Valores"
					_cTipo := "1"
				CASE AllTrim(_cTipCte) == "CTe de Anulacao"
					_cTipo := "2"
				CASE AllTrim(_cTipCte) == "CTe Substituto"
					_cTipo := "3"
				OTHERWISE 
					_cTipo := ""
			ENDCASE
			ZM4->ZM4_TIPCTE := _cTipo
			ZM4->ZM4_CHVREF := _cChvRef
			DO CASE
				CASE AllTrim(_cCodRet) == "100"
					_cRetCte := "100 - Autorizado o uso do CTe"
				CASE AllTrim(_cCodRet) == "101"
					_cRetCte := "101 - Cancelamento autorizado"
				CASE AllTrim(_cCodRet) == "102"
					_cRetCte := "102 - Inutilizacao de numero homologado"
				CASE AllTrim(_cCodRet) == "128"
					_cRetCte := "128 - CT-e anulado pelo emissor"
				CASE AllTrim(_cCodRet) == "129"
					_cRetCte := "129 - CT-e substituído pelo emissor"
				CASE AllTrim(_cCodRet) == "130"
					_cRetCte := "130 - Apresentada Carta de Correção Eletrônica – CC-e"
				CASE AllTrim(_cCodRet) == "131"
					_cRetCte := "131 - CT-e desclassificado pelo Fisco"
				CASE AllTrim(_cCodRet) == "134"
					_cRetCte := "134 - Evento registrado e vinculado ao CT-e com alerta para a situação do documento"
				CASE AllTrim(_cCodRet) == "135"
					_cRetCte := "135 - Evento registrado e vinculado a CT-e"
				CASE AllTrim(_cCodRet) == "136"
					_cRetCte := "136 - Evento registrado, mas não vinculado a CT-e"
				CASE AllTrim(_cCodRet) == "212"
					_cRetCte := "212 - Rejeição: Data de emissao CT-e posterior a data de recebimento"
				CASE AllTrim(_cCodRet) == "219"
					_cRetCte := "219 - Rejeição: Circulacao do CT-e verificada"
				CASE AllTrim(_cCodRet) == "220"
					_cRetCte := "220 - Rejeição: CT-e autorizada ha mais de 7 dias (168 horas)"
				CASE AllTrim(_cCodRet) == "302"
					_cRetCte := "302 - Uso denegado: Irregularidade fiscal do remetente"
				CASE AllTrim(_cCodRet) == "303"
					_cRetCte := "303 - Uso denegado: Irregularidade fiscal do destinatário"
				CASE AllTrim(_cCodRet) == "304"
					_cRetCte := "304 - Uso denegado: Irregularidade fiscal do expedidor"
				CASE AllTrim(_cCodRet) == "305"
					_cRetCte := "305 - Uso denegado: Irregularidade fiscal do recebedor"
				CASE AllTrim(_cCodRet) == "306"
					_cRetCte := "306 - Uso denegado: Irregularidade fiscal do tomador"
				OTHERWISE 
					_cRetCte := _cCodRet	// Caso retornar este código sem descrição, verificar e tratar conforme acima
			ENDCASE
			ZM4->ZM4_RETCTE := _cRetCte
			ZM4->ZM4_VLRFRE := _nVlrFre
			ZM4->ZM4_VLRTOT := _nVlrTot
			ZM4->ZM4_VLRPED := _nVlrPed
			ZM4->ZM4_TIPPED := _cTipPed
			ZM4->ZM4_IBGEOR := _IbgeOri
			ZM4->ZM4_IBGEDE := _IbgeDes
			ZM4->ZM4_UFORIG := _cUfOrig
			ZM4->ZM4_UFDEST := _cUfDest
			ZM4->ZM4_CFOP   := _cCfop
			ZM4->ZM4_CSTICM := _cCstIcm
			ZM4->ZM4_BASICM := _nBasIcm
			ZM4->ZM4_VALICM := _nValIcm
			ZM4->ZM4_VSTICM := _nVstIcm
			ZM4->ZM4_OUTICM := _nOutIcm
			ZM4->ZM4_ISEICM := _nIseIcm
			ZM4->ZM4_VCRICM := _nVcrIcm
			ZM4->ZM4_BOUTUF := _nBOutUf
			ZM4->ZM4_VOUTUF := _nVOutUf

			ZM4->ZM4_IDEMI  := PadL(AllTrim(_cIdEmi), TamSX3("ZM4_IDEMI")[01], "0")
			ZM4->ZM4_CODEMI := _cCodEmi
			ZM4->ZM4_LOJEMI := _cLojEmi
			ZM4->ZM4_NOMEMI := _cNomEmi
			ZM4->ZM4_FANEMI := _cFanEmi
			ZM4->ZM4_CGCEMI := _cCgcEmi
			ZM4->ZM4_IEEMI  := _cIeEmi
			ZM4->ZM4_IMEMI  := _cImEmi
			ZM4->ZM4_TIPEMI := _cTipEmi
			ZM4->ZM4_UFEMI  := _cUfEmi
			ZM4->ZM4_MUNEMI := _cMunEmi
			ZM4->ZM4_CDMEMI := _cCdmEmi
			ZM4->ZM4_ENDEMI := _cEndEmi
			ZM4->ZM4_COMEMI := _cComEmi
			ZM4->ZM4_NUMEMI := _cNumEmi
			ZM4->ZM4_CEPEMI := _cCepEmi
			ZM4->ZM4_BAIEMI := _cBaiEmi
			ZM4->ZM4_TELEMI := _cTelEmi
			ZM4->ZM4_EMLEMI := _cEmlEmi

			ZM4->ZM4_IDREM  := PadL(AllTrim(_cIdRem), TamSX3("ZM4_IDREM")[01], "0")
			ZM4->ZM4_CODREM := _cCodRem
			ZM4->ZM4_LOJREM := _cLojRem
			ZM4->ZM4_NOMREM := _cNomRem
			ZM4->ZM4_FANREM := _cFanRem
			ZM4->ZM4_CGCREM := _cCgcRem
			ZM4->ZM4_IEREM  := _cIeRem
			ZM4->ZM4_IMREM  := _cImRem
			ZM4->ZM4_TIPREM := _cTipRem
			ZM4->ZM4_UFREM  := _cUfRem
			ZM4->ZM4_MUNREM := _cMunRem
			ZM4->ZM4_CDMREM := _cCdmRem
			ZM4->ZM4_ENDREM := _cEndRem
			ZM4->ZM4_COMREM := _cComRem
			ZM4->ZM4_NUMREM := _cNumRem
			ZM4->ZM4_CEPREM := _cCepRem
			ZM4->ZM4_BAIREM := _cBaiRem
			ZM4->ZM4_TELREM := _cTelRem
			ZM4->ZM4_EMLREM := _cEmlRem

			ZM4->ZM4_IDDES  := PadL(AllTrim(_cIdDes), TamSX3("ZM4_IDDES")[01], "0")
			ZM4->ZM4_CODDES := _cCodDes
			ZM4->ZM4_LOJDES := _cLojDes
			ZM4->ZM4_NOMDES := _cNomDes
			ZM4->ZM4_FANDES := _cFanDes
			ZM4->ZM4_CGCDES := _cCgcDes
			ZM4->ZM4_IEDES  := _cIeDes
			ZM4->ZM4_IMDES  := _cImDes
			ZM4->ZM4_TIPDES := _cTipDes
			ZM4->ZM4_UFDES  := _cUfDes
			ZM4->ZM4_MUNDES := _cMunDes
			ZM4->ZM4_CDMDES := _cCdmDes
			ZM4->ZM4_ENDDES := _cEndDes
			ZM4->ZM4_COMDES := _cComDes
			ZM4->ZM4_NUMDES := _cMunDes
			ZM4->ZM4_CEPDES := _cCepDes
			ZM4->ZM4_BAIDES := _cBaiDes
			ZM4->ZM4_TELDES := _cTelDes
			ZM4->ZM4_EMLDES := _cEmlDes

			ZM4->ZM4_IDPAG  := PadL(AllTrim(_cIdPag), TamSX3("ZM4_IDPAG")[01], "0")
			ZM4->ZM4_CODPAG := _cCodPag
			ZM4->ZM4_LOJPAG := _cLojPag
			ZM4->ZM4_NOMPAG := _cNomPag
			ZM4->ZM4_FANPAG := _cFanPag
			ZM4->ZM4_CGCPAG := _cCgcPag
			ZM4->ZM4_IEPAG  := _cIePag
			ZM4->ZM4_IMPAG  := _cImPag
			ZM4->ZM4_TIPPAG := _cTipPag
			ZM4->ZM4_UFPAG  := _cUfPag
			ZM4->ZM4_MUNPAG := _cMunPag
			ZM4->ZM4_CDMPAG := _cCdmPag
			ZM4->ZM4_ENDPAG := _cEndPag
			ZM4->ZM4_COMPAG := _cComPag
			ZM4->ZM4_NUMPAG := _cNumPag
			ZM4->ZM4_CEPPAG := _cCepPag
			ZM4->ZM4_BAIPAG := _cBaiPag
			ZM4->ZM4_TELPAG := _cTelPag
			ZM4->ZM4_EMLPAG := _cEmlPag

			ZM4->ZM4_IDREC  := PadL(AllTrim(_cIdRec), TamSX3("ZM4_IDREC")[01], "0")
			ZM4->ZM4_CODREC := _cCodRec
			ZM4->ZM4_LOJREC := _cLojRec
			ZM4->ZM4_NOMREC := _cNomRec
			ZM4->ZM4_FANREC := _cFanRec
			ZM4->ZM4_CGCREC := _cCgcRec
			ZM4->ZM4_IEREC  := _cIeRec
			ZM4->ZM4_IMREC  := _cImRec
			ZM4->ZM4_TIPREC := _cTipRec
			ZM4->ZM4_UFREC  := _cUfRec
			ZM4->ZM4_MUNREC := _cMunRec
			ZM4->ZM4_CDMREC := _cCdmRec
			ZM4->ZM4_ENDREC := _cEndRec
			ZM4->ZM4_COMREC := _cComRec
			ZM4->ZM4_NUMREC := _cNumRec
			ZM4->ZM4_CEPREC := _cCepRec
			ZM4->ZM4_BAIREC := _cBaiRec
			ZM4->ZM4_TELREC := _cTelRec
			ZM4->ZM4_EMLREC := _cEmlRec

			ZM4->ZM4_IDEXP  := PadL(AllTrim(_cIdExp), TamSX3("ZM4_IDEXP")[01], "0")
			ZM4->ZM4_CODEXP := _cCodExp
			ZM4->ZM4_LOJEXP := _cLojExp
			ZM4->ZM4_NOMEXP := _cNomExp
			ZM4->ZM4_FANEXP := _cFanExp
			ZM4->ZM4_CGCEXP := _cCgcExp
			ZM4->ZM4_IEEXP  := _cIeExp
			ZM4->ZM4_IMEXP  := _cImExp
			ZM4->ZM4_TIPEXP := _cTipExp
			ZM4->ZM4_UFEXP  := _cUfExp
			ZM4->ZM4_MUNEXP := _cMunExp
			ZM4->ZM4_CDMEXP := _cCdmExp
			ZM4->ZM4_ENDEXP := _cEndExp
			ZM4->ZM4_COMEXP := _cComExp
			ZM4->ZM4_NUMEXP := _cNumExp
			ZM4->ZM4_CEPEXP := _cCepExp
			ZM4->ZM4_BAIEXP := _cBaiExp
			ZM4->ZM4_TELEXP := _cTelExp
			ZM4->ZM4_EMLEXP := _cEmlExp

			ZM4->ZM4_IDMOT  := PadL(AllTrim(_cIdMot), TamSX3("ZM4_IDMOT")[01], "0")
			ZM4->ZM4_CODMOT := _cCodMot
			ZM4->ZM4_NOMMOT := _cNomMot
			ZM4->ZM4_FANMOT := _cFanMot
			ZM4->ZM4_CGCMOT := _cCgcMot
			ZM4->ZM4_IEMOT  := _cIeMot
			ZM4->ZM4_IMMOT  := _cImMot
			ZM4->ZM4_TIPMOT := _cTipMot
			ZM4->ZM4_UFMOT  := _cUfMot
			ZM4->ZM4_MUNMOT := _cMunMot
			ZM4->ZM4_CDMMOT := _cCdmMot
			ZM4->ZM4_ENDMOT := _cEndMot
			ZM4->ZM4_COMMOT := _cComMot
			ZM4->ZM4_NUMMOT := _cNumMot
			ZM4->ZM4_CEPMOT := _cCepMot
			ZM4->ZM4_BAIMOT := _cBaiMot
			ZM4->ZM4_TELMOT := _cTelMot
			ZM4->ZM4_EMLMOT := _cEmlMot
			MsUnlock()

			// Quantidade de filhos do nó "produtos"
			nQtProduto := oXml:XPAthChildCount(aListBalance[nX,2] + cPathProduto)

			// Retorna um array com os nós filhos do nó apontado pela expressão aListBalance + cPathProduto 
			aListProduto := oXml:XPathGetChildArray(aListBalance[nX,2] + cPathProduto)

			nY := 1
			While nY <= nQtProduto
				aItensPrd := oXml:XPathGetChildArray(aListProduto[nY,2])  // Gera Array com os filhos.

				// Id
				nPos := aScan(aItensPrd,{|x| AllTrim( x[1] ) == 'id' } ) 
				If nPos > 0
					_cIdPrd := aItensPrd[nPos,3]
				Else
					_cIdPrd := ""
				EndIf

				// Item
				nPos := aScan(aItensPrd,{|x| AllTrim( x[1] ) == 'item' } ) 
				If nPos > 0
					_cDesPrd := aItensPrd[nPos,3]
				Else
					_cDesPrd := ""
				EndIf

				// Quantidade
				nPos := aScan(aItensPrd,{|x| AllTrim( x[1] ) == 'quantidade' } ) 
				If nPos > 0
					_cQtdPrd := aItensPrd[nPos,3]
				Else
					_cQtdPrd := ""
				EndIf

				// Peso
				nPos := aScan(aItensPrd,{|x| AllTrim( x[1] ) == 'peso' } ) 
				If nPos > 0
					_cPesPrd := aItensPrd[nPos,3]
				Else
					_cPesPrd := ""
				EndIf

				// Valor
				nPos := aScan(aItensPrd,{|x| AllTrim( x[1] ) == 'valor' } ) 
				If nPos > 0
					_cVlrPrd := aItensPrd[nPos,3]
				Else
					_cVlrPrd := ""
				EndIf

				// Modelo
				nPos := aScan(aItensPrd,{|x| AllTrim( x[1] ) == 'modelo' } ) 
				If nPos > 0
					_cModPrd := aItensPrd[nPos,3]
				Else
					_cModPrd := ""
				EndIf

				// Documento
				nPos := aScan(aItensPrd,{|x| AllTrim( x[1] ) == 'numero' } ) 
				If nPos > 0
					_cDocPrd := aItensPrd[nPos,3]
				Else
					_cDocPrd := ""
				EndIf

				// Serie
				nPos := aScan(aItensPrd,{|x| AllTrim( x[1] ) == 'serie' } ) 
				If nPos > 0
					_cSerPrd := aItensPrd[nPos,3]
				Else
					_cSerPrd := ""
				EndIf

				// Emissao
				nPos := aScan(aItensPrd,{|x| AllTrim( x[1] ) == 'emissao' } ) 
				If nPos > 0
					_cEmiPrd := aItensPrd[nPos,3]
				Else
					_cEmiPrd := ""
				EndIf

				// Chave
				nPos := aScan(aItensPrd,{|x| AllTrim( x[1] ) == 'chave' } ) 
				If nPos > 0
					If ZM4->ZM4_IDCTRC $ "0000010221/0000010222/0000010224/0000010225/0000010323/0000011074/0000011075"
						_cChvPrd := Left(aItensPrd[nPos,3],22) + "101" + Right(aItensPrd[nPos,3],19)
					Else
						_cChvPrd := aItensPrd[nPos,3]
					EndIf
				Else
					_cChvPrd := ""
				EndIf

				//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
				//³ Verifica se existe produto no Protheus, senão cria um novo				³
			    //ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
				DbSelectArea("SB1")
				DbOrderNickName("IDTPATUA")
				If !DbSeek(FWxFilial("SB1") + PadL(AllTrim(_cIdPrd), TamSX3("ZM5_IDPRD")[01], "0") + "T")

					_cTipoPrd  := "ME"
					_cUnidPrd  := "CX"
					_cGrpPrd   := "0001"
					_cNcmPrd   := "02023000"
					_cProdERP  := GetSxeNum("SB1", "B1_COD")
					_cDescERP  := _cDesPrd
					_cCtaEstoq := GetAdvFVal("SBM", "BM_ESTOQUE",  FWxFilial("SBM") + Left(_cGrpPrd,4), 1, Space(TamSx3("BM_ESTOQUE")[1]),  .T.)

					// Pegando o modelo de dados, setando a operação de inclusão
					oModelB1 := FWLoadModel("MATA010")
					oModelB1:SetOperation(MODEL_OPERATION_INSERT)
					oModelB1:Activate()
					
					// Pegando o model e setando os campos, inclusive os obrigatórios
					oSB1Mod := oModelB1:GetModel("SB1MASTER")
					oSB1Mod:SetValue("B1_COD"    , _cProdERP				 								) 
					oSB1Mod:SetValue("B1_DESC"   , _cDescERP										     	) 
					oSB1Mod:SetValue("B1_TIPO"   , _cTipoPrd 												) 
					oSB1Mod:SetValue("B1_UM"     , _cUnidPrd												) 
					oSB1Mod:SetValue("B1_LOCPAD" , "01"														) 
					oSB1Mod:SetValue("B1_GRUPO"  , Left(_cGrpPrd,4)											) 
					oSB1Mod:SetValue("B1_MSBLQL" , "2"														) 
					oSB1Mod:SetValue("B1_POSIPI" , _cNcmPrd													) 
					oSB1Mod:SetValue("B1_ORIGEM" , "0"														) 
					oSB1Mod:SetValue("B1_ESTOQUE", _cCtaEstoq												) 
					oSB1Mod:SetValue("B1_IDATUA" , PadL(AllTrim(_cIdPrd), TamSX3("B1_IDATUA")[01], "0")   	)
					oSB1Mod:SetValue("B1_TPATUA" , "T"														)
					
					// Setando o complemento do produto
					oSB5Mod := oModelB1:GetModel("SB5DETAIL")
					If oSB5Mod != Nil
						oSB5Mod:SetValue("B5_CEME" , _cDescERP												)
					EndIf
					
					// Se conseguir validar as informações
					If oModelB1:VldData()
						oModelB1:CommitData()	// Realiza o Commit
						ConfirmSX8()
					Else
						RollBackSX8()
						FWAlertError(VarInfo("",oModelB1:GetErrorMessage()), "ERRO!")
					EndIf       
						
					oModelB1:DeActivate()
					oModelB1:Destroy()
					
					oModelB1 := NIL
				Else
					_cProdERP := SB1->B1_COD
					_cDescERP := SB1->B1_DESC
				EndIf

				// Volta para a ordem default de índice, pois senão a TMSA050 não gera registros na tabela DTC - NÃO REMOVER
				SB1->(dbSetOrder(1))

				// Cria registros na tabela intermediária de importação dos CTRCs Produtos importados da Atua
				DbSelectArea("ZM5")
				Reclock("ZM5",.T.)
				ZM5->ZM5_FILIAL := FWxFilial("ZM5")
				ZM5->ZM5_ITEPRD := StrZero(nY, 4, 0)
				ZM5->ZM5_IDPRD  := PadL(AllTrim(_cIdPrd), TamSX3("ZM5_IDPRD")[01], "0") 
				ZM5->ZM5_CODPRD := _cProdERP
				ZM5->ZM5_DESPRD := _cDescERP

				//---------- INÍCIO Busca Qtde de Volumes da SF2 da empresa 01 (Frig. Silva)
				_cNota := PadL(AllTrim(_cDocPrd), TamSX3("ZM5_DOCPRD")[01], "0")
				
				cQuery := "SELECT F2_VOLUME1 + F2_VOLUME2 + F2_VOLUME3 + F2_VOLUME4 VOLUME "
				cQuery += "  FROM SF2010"
				cQuery += " WHERE D_E_L_E_T_ = ' ' "
				cQuery += "   AND F2_FILIAL = '00'"
				cQuery += "   AND F2_DOC = '" + _cNota + "' "
				cQuery += "   AND F2_SERIE = '" + _cSerPrd + "' "

				cQuery  := ChangeQuery(cQuery)

				If Select("TMP2") != 0
					TMP2->(dbCloseArea())
				Endif

				TCQUERY cQuery NEW ALIAS "TMP2"

				_nQtdVol := 0
				DbSelectArea("TMP2")
				DbGoTop()
				Do While !Eof()
					_nQtdVol := _nQtdVol + TMP2->VOLUME
					DbSelectArea("TMP2")
					DbSkip()
				EndDo

				TMP2->(DbCloseArea())
				//---------- FINAL Busca Qtde de Volumes da SF2 da empresa 01 (Frig. Silva)
				
				ZM5->ZM5_QTDPRD := Val(StrTran(_cQtdPrd,",","."))
				ZM5->ZM5_PESPRD := Val(StrTran(_cPesPrd,",","."))
				ZM5->ZM5_VLRPRD := Val(StrTran(_cVlrPrd,",","."))
				ZM5->ZM5_QTDVOL := _nQtdVol
				ZM5->ZM5_MODPRD := _cModPrd
				ZM5->ZM5_DOCPRD := PadL(AllTrim(_cDocPrd), TamSX3("ZM5_DOCPRD")[01], "0")
				If ZM4->ZM4_IDCTRC $ "0000010221/0000010222/0000010224/0000010225/0000010323/0000011074/0000011075"
					ZM5->ZM5_SERPRD := "101"
				Else
					ZM5->ZM5_SERPRD := _cSerPrd
				EndIf
				ZM5->ZM5_EMIPRD := Ctod(Substr(_cEmiPrd,09,02) + "/" + Substr(_cEmiPrd,06,02) + "/" + Substr(_cEmiPrd,01,04))
				ZM5->ZM5_CHVPRD := _cChvPrd
				ZM5->ZM5_IDCTRC := ZM4->ZM4_IDCTRC
				ZM5->ZM5_DOCTO  := ZM4->ZM4_DOCTO
				ZM5->ZM5_SERIE  := ZM4->ZM4_SERIE
				ZM5->ZM5_CHVCTE := ZM4->ZM4_CHVCTE
				MsUnlock()

				nY++
			EndDo	

			nX++
		EndDo	

		oXML := Nil

		// Monta tela para processamento dos dados importados e posteriormente gera ou cancela CTe conforme situação
		_TelaCTRC()
	Else
		MsgAlert("Error: " + oXML:Error())
		Return
	EndIf

Return


//-----------------------------------------------------------------------
/*/{Protheus.doc} _TelaCTRC
Função que monta tela para processamento dos dados no Protheus
@author     Evandro Mugnol
@since      Dez/2023
/*/
//-----------------------------------------------------------------------
Static Function _TelaCTRC()

	Local aCpos1   := {}
	Local aCpos2   := {}
	Local nX	   := 0
	Local aArea	   := FWGetArea()
	Local aAreaSX3 := SX3->(FWGetArea())
	Local aSize    := {}
	Local aInfo    := {}
	Local aButtons := {}

	Private aHead1   := {}
	Private aHead2   := {}
	Private aCols1   := {}
	Private aCols2   := {}
	Private aPosObj  := {}
	Private aObjects := {}
	Private lChkSel  := .F.
	Private oDlgCtrc
	Private oGetDad1
	Private oGetDad2

	// Fontes
	Private cFontUti := "Tahoma"
	Private oFontLeg := TFont():New(cFontUti, , -18)

	Static oChk

	aSize := MsAdvSize(.T.)		 // Se a janela de diálogo possuirá enchoicebar (.T.), senão (.F.)
	AAdd( aObjects, { 100, 015, .T., .T. } )
	AAdd( aObjects, { 100, 065, .T., .T. } )
	AAdd( aObjects, { 100, 020, .T., .T. } )
	aInfo := { aSize[ 1 ], aSize[ 2 ], aSize[ 3 ], aSize[ 4 ], 5, 5 }
	aPosObj := MsObjSize( aInfo, aObjects,.T.)

	// Array de cabeçalho do oGetDad1
	// Neste caso serão 12 colunas incluindo o campo que possui caixa de seleção ou checkBox e legendas
	aAdd(aCpos1,"ZM4_IDCTRC")
	aAdd(aCpos1,"ZM4_DTEMIS")
	aAdd(aCpos1,"ZM4_AMBIEN")
	aAdd(aCpos1,"ZM4_SITUAC")
	aAdd(aCpos1,"ZM4_CGCDES")
	aAdd(aCpos1,"ZM4_CODDES")
	aAdd(aCpos1,"ZM4_LOJDES")
	aAdd(aCpos1,"ZM4_NOMDES")
	aAdd(aCpos1,"ZM4_CHVCTE")
	aAdd(aCpos1,"ZM4_PROCTE")
	aAdd(aCpos1,"ZM4_TIPCTE")
	aAdd(aCpos1,"ZM4_VLRFRE")

	aAdd(aHead1, { ''	 	 , 'CHECKBOL', '@BMP', 2, 0,     ,, 'C',, 'V',,,'', 'V' } )
	aAdd(aHead1, { 'Atua'	 , "XX_COR"  , '@BMP', 2, 0,".F.",, "C",, "V",,,'', 'V' } )
	aAdd(aHead1, { 'Protheus', "XX_COR"  , '@BMP', 2, 0,".F.",, "C",, "V",,,'', 'V' } )

	SX3->(dbSetOrder(2))
	For nX := 1 to Len(aCpos1)
		If SX3->( MsSeek(aCpos1[nX]) )
			aAdd( aHead1, { AlLTrim( X3Titulo() )	,; 	// 01 - Titulo
							SX3->X3_CAMPO			,;	// 02 - Campo
							SX3->X3_PICTURE			,;	// 03 - Picture
							SX3->X3_TAMANHO			,;	// 04 - Tamanho
							SX3->X3_DECIMAL			,;	// 05 - Decimal
							SX3->X3_VALID  			,;	// 06 - Valid
							SX3->X3_USADO  			,;	// 07 - Usado
							SX3->X3_TIPO   			,;	// 08 - Tipo
							SX3->X3_F3				,;	// 09 - F3
							SX3->X3_CONTEXT 		,;  // 10 - Contexto
							SX3->X3_CBOX			,;	// 11 - ComboBox
							SX3->X3_RELACAO    		})  // 12 - Relacao
		EndIf
	Next nX

	// Array de itens do oGetDad2
	// Neste caso serão 9 colunas
	aAdd(aCpos2,"ZM5_ITEPRD")
	aAdd(aCpos2,"ZM5_CODPRD")
	aAdd(aCpos2,"ZM5_DESPRD")
	aAdd(aCpos2,"ZM5_VLRPRD")
	aAdd(aCpos2,"ZM5_QTDPRD")
	aAdd(aCpos2,"ZM5_PESPRD")
	aAdd(aCpos2,"ZM5_QTDVOL")
	aAdd(aCpos2,"ZM5_DOCPRD")
	aAdd(aCpos2,"ZM5_SERPRD")

	SX3->(dbSetOrder(2))
	For nX := 1 to Len(aCpos2)
		If SX3->( MsSeek(aCpos2[nX]) )
			aAdd( aHead2, { AlLTrim( X3Titulo() )	,; 	// 01 - Titulo
							SX3->X3_CAMPO			,;	// 02 - Campo
							SX3->X3_PICTURE			,;	// 03 - Picture
							SX3->X3_TAMANHO			,;	// 04 - Tamanho
							SX3->X3_DECIMAL			,;	// 05 - Decimal
							SX3->X3_VALID  			,;	// 06 - Valid
							SX3->X3_USADO  			,;	// 07 - Usado
							SX3->X3_TIPO   			,;	// 08 - Tipo
							SX3->X3_F3				,;	// 09 - F3
							SX3->X3_CONTEXT 		,;  // 10 - Contexto
							SX3->X3_CBOX			,;	// 11 - ComboBox
							SX3->X3_RELACAO    		})  // 12 - Relacao
		EndIf
	Next nX

	FWRestArea( aAreaSX3 )
	FWRestArea( aArea )

	DEFINE MSDIALOG oDlgCtrc TITLE "CTRCs Lidos da Importação da Atua Sistemas" From aSize[7],0 to aSize[6],aSize[5] of oMainWnd PIXEL

	_oPanel := TPanel():New(aPosObj[1,1], aPosObj[1,2], , oDlgCtrc ,, .F., ,, , aPosObj[1,4], aPosObj[1,3], .T., .F.)

	// Objeto oChk de checkbox e variável lChkSel. Quando clicado, executa o método "Seleciona" e possibilita
	// que o usuário selecione todas as linhas ao mesmo tempo.
	@ 025, 003 CHECKBOX oChk VAR lChkSel PROMPT "Marca/Desmarca Todos" SIZE 070, 007 on CLICK Seleciona(lChkSel) OF _oPanel PIXEL

	aObjSay := tSay():New(000, 090, {|| OemToAnsi('Legenda Atua')}  		, _oPanel,,oFontLeg,,,, .T., RGB(031, 073, 125), , 100, 020)

	aObjBmp := TBitmap():New(011, 090, 068, 010, 'BR_VERDE'  				, , .T., _oPanel, {|| }, {|| }, .F., .F.,,, .F.,, .T.,, .F.)
	aObjSay := tSay():New(012, 100, {|| OemToAnsi('CTRC Autorizado')}  		, _oPanel,,,,,, .T., CLR_BLACK, CLR_WHITE, 100, 020)

	aObjBmp := TBitmap():New(019, 090, 068, 010, 'BR_LARANJA'  				, , .T., _oPanel, {|| }, {|| }, .F., .F.,,, .F.,, .T.,, .F.)
	aObjSay := tSay():New(020, 100, {|| OemToAnsi('CTRC Não Previsto')}		, _oPanel,,,,,, .T., CLR_BLACK, CLR_WHITE, 100, 020)

	aObjBmp := TBitmap():New(027, 090, 068, 010, 'BR_CANCEL'  				, , .T., _oPanel, {|| }, {|| }, .F., .F.,,, .F.,, .T.,, .F.)
	aObjSay := tSay():New(028, 100, {|| OemToAnsi('CTRC Cancelado')} 		, _oPanel,,,,,, .T., CLR_BLACK, CLR_WHITE, 100, 020)

	aObjSay := tSay():New(000, 240, {|| OemToAnsi('Legenda Protheus')}  	, _oPanel,,oFontLeg,,,, .T., RGB(031, 073, 125), , 100, 020)

	aObjBmp := TBitmap():New(011, 240, 068, 010, 'BR_VERDE'  				, , .T., _oPanel, {|| }, {|| }, .F., .F.,,, .F.,, .T.,, .F.)
	aObjSay := tSay():New(012, 250, {|| OemToAnsi('CTRC Já Importado')} 	, _oPanel,,,,,, .T., CLR_BLACK, CLR_WHITE, 100, 020)

	aObjBmp := TBitmap():New(019, 240, 068, 010, 'BR_VERMELHO'  			, , .T., _oPanel, {|| }, {|| }, .F., .F.,,, .F.,, .T.,, .F.)
	aObjSay := tSay():New(020, 250, {|| OemToAnsi('CTRC Não Importado')}	, _oPanel,,,,,, .T., CLR_BLACK, CLR_WHITE, 100, 020)

	aObjBmp := TBitmap():New(027, 240, 068, 010, 'BR_PRETO'  					, , .T., _oPanel, {|| }, {|| }, .F., .F.,,, .F.,, .T.,, .F.)
	aObjSay := tSay():New(028, 250, {|| OemToAnsi('Problema Cadastro Cliente')}	, _oPanel,,,,,, .T., CLR_BLACK, CLR_WHITE, 100, 020)

	oGetDad1:= MsNewGetDados():New((aPosObj[2,1])   ,(aPosObj[2,2])+3, aPosObj[2,3]-15, aPosObj[2,4]+8,GD_UPDATE,/*LinOk*/,/*[cTudoOk]*/,/*[cIniCpos]*/,{'CHECKBOL'},1,9999,/*[cCampoOk]*/,/*[cSuperApagar]*/,/*[cApagaOk]*/,oDlgCtrc,aHead1,aCols1)

	oGetDad2:= MsNewGetDados():New((aPosObj[3,1])-15,(aPosObj[3,2])  , aPosObj[3,3]   , aPosObj[3,4]+8,GD_UPDATE,/*LinOk*/,/*[cTudoOk]*/,/*[cIniCpos]*/,/*aAlt*/    ,0,9999,/*[cCampoOk]*/,/*[cSuperApagar]*/,/*[cApagaOk]*/,oDlgCtrc,aHead2,aCols2)

	// Antes de ativar a tela (oDlgCtrc) busca todas informações para carregar o oGetDad1
	_ZM4Cab()

	// Botões da Tela
	@ aPosObj[2,2] * 2, aPosObj[2,4] - 210 BUTTON "Pesquisar"  SIZE 060, 015 ACTION {|| GdSeek(oGetDad1,"Busca Itens",oGetDad1:aHeader,oGetDad1:aCols,If(Type("oGetDad1:aIniCpos")=="A",.T.,)) } OF _oPanel PIXEL
	@ aPosObj[2,2] * 2, aPosObj[2,4] - 140 BUTTON "Visualizar" SIZE 060, 015 ACTION (_Visualiz()) OF _oPanel PIXEL
	@ aPosObj[2,2] * 2, aPosObj[2,4] - 070 BUTTON "Processar"  SIZE 060, 015 ACTION FWMsgRun(, {|oSay| _Processa(oSay) }, "Aguarde", "Processando Geração dos CTRCs no Protheus ...") OF _oPanel PIXEL
																					
	oDlgCtrc:lEscClose := .F.
	ACTIVATE MSDIALOG oDlgCtrc CENTERED ON INIT EnchoiceBar(oDlgCtrc, {||oDlgCtrc:End()}, { ||oDlgCtrc:End()},,aButtons,,,.T.,.T., .T., .F.,.T.,)

Return


//-----------------------------------------------------------------------
/*/{Protheus.doc} Seleciona
Função que faz a marcação dos registros na tela
@author     Evandro Mugnol
@since      Dez/2023
/*/
//-----------------------------------------------------------------------
Static Function Seleciona(lChkSel)

	Local i

	For i := 1 To Len(oGetDad1:aCols)
		// Verifica o valor da variável lChkSel
		// Se verdadeiro, define a primeira coluna do aCols como LBOK ou marcado (checked)
		If lChkSel
			oGetDad1:aCOLS[i,1] := "LBOK"
		Else	//se falso, marca como LBNO ou desmarcado (unchecked)
			oGetDad1:aCOLS[i,1] := "LBNO"
		Endif
	Next i

	// Executa refresh no getdados e na tela
	// esses métodos Refresh() são próprio da classe MsNewGetDados e do dialog
	oGetDad1:oBrowse:Refresh()
	oDlgCtrc:Refresh()

Return


//-----------------------------------------------------------------------
/*/{Protheus.doc} _ZM4Cab
Função que carrega todos registros da tabela intermediária ZM4 para tela
@author     Evandro Mugnol
@since      Dez/2023
/*/
//-----------------------------------------------------------------------
Static Function _ZM4Cab()

	Local oBmpAtua
	Local oBmpProt

	Private aCols1 := {}

	// Atualiza/Recarrega o oGetDad1 e o oDlgCtrc antes de receber novos dados
	_Refresh(aCols1)

	DbSelectArea("ZM4")
	DbSetOrder(1)
	DbGoTop()
	DbSeek(FWxFilial("ZM4"))
	While !Eof() .And. ZM4->ZM4_FILIAL == FWxFilial("ZM4")

		DO CASE
			CASE ZM4->ZM4_SITUAC == "2"		// AUTORIZADO
				oBmpAtua := oBmpVerde
			CASE ZM4->ZM4_SITUAC == "1"		// CANCELADO
				oBmpAtua := oBmpCancel
			OTHERWISE
				oBmpAtua := oBmpLaranja
		ENDCASE

		DbSelectArea("DT6")
		If ZM4->ZM4_TIPCTE == "1"	// CT-e Complementar
			DbSetOrder(1)
			DbSeek(FWxFilial("DT6") + ZM4->ZM4_FILIAL + ZM4->ZM4_DOCTO + ZM4->ZM4_SERIE)		// Filial + Fil.Docto. + No.Docto + Serie Docto
		Else
			DbSetOrder(18)
			DbSeek(FWxFilial("DT6") + ZM4->ZM4_CHVCTE)		// Filial + Chave CT-e
		EndIf
		If Found()
			_cMarcar := "N"
			oBmpProt := oBmpVerde
		Else
			_cMarcar := "S"
			oBmpProt := oBmpVermelho
		EndIf

		// Verifica se está bloqueado no cadastro de cliente ou região do cliente inválida
		_MSBLQL := AllTrim(GetAdvFVal("SA1", "A1_MSBLQL",  FWxFilial("SA1") + ZM4->ZM4_CODDES + ZM4->ZM4_LOJDES, 1, Space(TamSx3("A1_MSBLQL")[1]),  .T.))
		_CDRDES := AllTrim(GetAdvFVal("SA1", "A1_CDRDES",  FWxFilial("SA1") + ZM4->ZM4_CODDES + ZM4->ZM4_LOJDES, 1, Space(TamSx3("A1_CDRDES")[1]),  .T.))

		If _MSBLQL == "1"
			_cMarcar := "X"
			oBmpProt := oBmpPreto
			FWAlertWarning("VERIFICAR  Cliente/Loja: " + ZM4->ZM4_CODDES + "/" + ZM4->ZM4_LOJDES + " está bloqueado.", "Problema com Cadastro do Cliente!")
		Else
			//If Empty(_CDRDES) .Or. AllTrim(_CDRDES) == "000000"  .Or. AllTrim(_CDRDES) == "000001"
			If Len(AllTrim(_CDRDES)) <> 5
				_cMarcar := "X"
				oBmpProt := oBmpPreto
				FWAlertWarning("VERIFICAR  Cliente/Loja: " + ZM4->ZM4_CODDES + "/" + ZM4->ZM4_LOJDES + " região inválida.", "Problema com Cadastro do Cliente!")
			EndIf
		EndIf

		DbSelectArea("ZM4")
		DO CASE
			CASE ZM4->ZM4_SITUAC == "2" .And. _cMarcar == "S"
				aAdd(aCols1, {'LBOK', oBmpAtua, oBmpProt, ZM4->ZM4_IDCTRC, ZM4->ZM4_DTEMIS, ZM4->ZM4_AMBIEN, ZM4->ZM4_SITUAC, ZM4->ZM4_CGCDES, ZM4->ZM4_CODDES, ZM4->ZM4_LOJDES, ZM4->ZM4_NOMDES, ZM4->ZM4_CHVCTE, ZM4->ZM4_PROCTE, ZM4->ZM4_TIPCTE, ZM4->ZM4_VLRFRE, .F.})
			CASE ZM4->ZM4_SITUAC == "1" .And. _cMarcar == "N"
				aAdd(aCols1, {'LBOK', oBmpAtua, oBmpProt, ZM4->ZM4_IDCTRC, ZM4->ZM4_DTEMIS, ZM4->ZM4_AMBIEN, ZM4->ZM4_SITUAC, ZM4->ZM4_CGCDES, ZM4->ZM4_CODDES, ZM4->ZM4_LOJDES, ZM4->ZM4_NOMDES, ZM4->ZM4_CHVCTE, ZM4->ZM4_PROCTE, ZM4->ZM4_TIPCTE, ZM4->ZM4_VLRFRE, .F.})
			OTHERWISE
				aAdd(aCols1, {'LBNO', oBmpAtua, oBmpProt, ZM4->ZM4_IDCTRC, ZM4->ZM4_DTEMIS, ZM4->ZM4_AMBIEN, ZM4->ZM4_SITUAC, ZM4->ZM4_CGCDES, ZM4->ZM4_CODDES, ZM4->ZM4_LOJDES, ZM4->ZM4_NOMDES, ZM4->ZM4_CHVCTE, ZM4->ZM4_PROCTE, ZM4->ZM4_TIPCTE, ZM4->ZM4_VLRFRE, .F.})
		ENDCASE

		DbSelectArea("ZM4")
		DbSkip()
	EndDo

	// Atualiza o oGetDad1 com o novo array
	If Len(aCols1) > 0
		_Refresh(aCols1)
		_RefreshT1()
	EndIf

Return


//-----------------------------------------------------------------------
/*/{Protheus.doc} _Refresh
Função que refresh do oGetDad1
@author     Evandro Mugnol
@since      Dez/2023
/*/
//-----------------------------------------------------------------------
Static Function _Refresh(aDados)

	oGetDad1:oBrowse:Refresh()
	oDlgCtrc:Refresh()

	oGetDad1:= MsNewGetDados():New((aPosObj[2,1]),   (aPosObj[2,2])+3, aPosObj[2,3]-15, aPosObj[2,4]+8,GD_UPDATE,/*LinOk*/,/*[cTudoOk]*/,/*[cIniCpos]*/,{'CHECKBOL'},1,9999,/*[cCampoOk]*/,/*[cSuperApagar]*/,/*[cApagaOk]*/,oDlgCtrc,aHead1,aCols1)
	// Quando clicado duas vezes sobre o aCols[oGetDad1:nAt,1], ou seja, onde ficará a coluna com o checkbox, ele irá alternar de LBOK para LBNO e vice versa
	//oGetDad1:oBrowse:bLDblClick := {|| oGetDad1:EditCell(), oGetDad1:aCols[oGetDad1:nAt,1] := iif(oGetDad1:aCols[oGetDad1:nAt,1] == 'LBOK','LBNO','LBOK')}
	oGetDad1:oBrowse:bLDblClick := {|| oGetDad1:EditCell(), oGetDad1:aCols[oGetDad1:nAt,1] := _VldMarc(oGetDad1:aCols[oGetDad1:nAt,1], oGetDad1:aCols[oGetDad1:nAt,9], oGetDad1:aCols[oGetDad1:nAt,10], oGetDad1:aCols[oGetDad1:nAt,2]:CNAME, oGetDad1:aCols[oGetDad1:nAt,3]:CNAME)}
	// Executa quando troca de linha.
	oGetDad1:oBrowse:bChange    := {|| _ZM5Ite()}

	oGetDad2:oBrowse:Refresh()
	oDlgCtrc:Refresh()

	oGetDad2:= MsNewGetDados():New((aPosObj[3,1])-15,(aPosObj[3,2])  , aPosObj[3,3]   , aPosObj[3,4]+8,GD_UPDATE,/*LinOk*/,/*[cTudoOk]*/,/*[cIniCpos]*/,/*aAlt*/    ,0,9999,/*[cCampoOk]*/,/*[cSuperApagar]*/,/*[cApagaOk]*/,oDlgCtrc,aHead2,aCols2)

Return


//-----------------------------------------------------------------------
/*/{Protheus.doc} _VldMarc
Função que valida a marcação da linha com dados do cliente
@author     Evandro Mugnol
@since      Dez/2023
/*/
//-----------------------------------------------------------------------
Static Function _VldMarc(_cTpMarc, _cCli, _cLoj, _ObjAtua, _ObjProt)

	_RetMarc := _cTpMarc

	If _ObjAtua == _ObjProt
		FWAlertWarning("Não é permitido realizar a marcação desta linha", "CT-e já integrado.")
		_RetMarc := "LBNO"
	Else
		// Verifica se está bloqueado no cadastro de cliente ou região do cliente inválida
		_MSBLQL := AllTrim(GetAdvFVal("SA1", "A1_MSBLQL",  FWxFilial("SA1") + _cCli + _cLoj, 1, Space(TamSx3("A1_MSBLQL")[1]),  .T.))
		_CDRDES := AllTrim(GetAdvFVal("SA1", "A1_CDRDES",  FWxFilial("SA1") + _cCli + _cLoj, 1, Space(TamSx3("A1_CDRDES")[1]),  .T.))

		If _MSBLQL == "1"
			_RetMarc := "LBNO"
			FWAlertWarning("VERIFICAR  Cliente/Loja: " + ZM4->ZM4_CODDES + "/" + ZM4->ZM4_LOJDES + " está bloqueado.", "Problema com Cadastro do Cliente!")
		Else
			If Len(AllTrim(_CDRDES)) <> 5
				_RetMarc := "LBNO"
				FWAlertWarning("VERIFICAR  Cliente/Loja: " + ZM4->ZM4_CODDES + "/" + ZM4->ZM4_LOJDES + " região inválida.", "Problema com Cadastro do Cliente!")
			Else
				_RetMarc := iif(_RetMarc == 'LBOK','LBNO','LBOK')
			EndIf
		EndIf
	EndIf

Return _RetMarc


//-----------------------------------------------------------------------
/*/{Protheus.doc} _RefreshT1
Função de refresh da tela 1 (cabeçalho)
@author     Evandro Mugnol
@since      Dez/2023
/*/
//-----------------------------------------------------------------------
Static function _RefreshT1()

	oGetDad1:aCols := aClone(aCols1)
	oGetDad1:oBrowse:Refresh()

	If len(aCols1) > 0
		_ZM5Ite()
	Else
		aCols2 := {}
		_RefreshT2()
	EndIf

Return


//-----------------------------------------------------------------------
/*/{Protheus.doc} _RefreshT2
Função de refresh da tela 2 (item)
@author     Evandro Mugnol
@since      Dez/2023
/*/
//-----------------------------------------------------------------------
Static function _RefreshT2()

	oGetDad2:aCols := aClone(aCols2)
	oGetDad2:oBrowse:Refresh()

Return


//-----------------------------------------------------------------------
/*/{Protheus.doc} _ZM5Ite
Função que carrega dados do produto da tabela intermediária ZM5 para tela
@author     Evandro Mugnol
@since      Dez/2023
/*/
//-----------------------------------------------------------------------
static function _ZM5Ite()

	_cQuery := " SELECT ZM5_ITEPRD, ZM5_CODPRD, ZM5_DESPRD, ZM5_VLRPRD, ZM5_QTDPRD, ZM5_PESPRD, ZM5_QTDVOL, ZM5_DOCPRD, ZM5_SERPRD "
	_cQuery += "   FROM " + RetSqlTab("ZM5")
	_cQuery += "  WHERE " + RetSqlFil("ZM5")
	_cQuery += "    AND ZM5_CHVCTE = '" + oGetDad1:aCols[oGetDad1:nAt,12] + "' "
	_cQuery += "    AND " + RetSqlDel("ZM5")

	_cQuery  := ChangeQuery(_cQuery)

	If Select("TMP") != 0
		TMP->(dbCloseArea())
	Endif

	TCQUERY _cQuery NEW ALIAS "TMP"

	aCols2 := {}
	DbSelectArea("TMP")
	DbGoTop()
	Do While !Eof()
		aAdd(aCols2, {TMP->ZM5_ITEPRD, TMP->ZM5_CODPRD, TMP->ZM5_DESPRD, TMP->ZM5_VLRPRD, TMP->ZM5_QTDPRD, TMP->ZM5_PESPRD, TMP->ZM5_QTDVOL, TMP->ZM5_DOCPRD, TMP->ZM5_SERPRD, .F.})

		DbSelectArea("TMP")
		DbSkip()
	EndDo

	TMP->(DbCloseArea())

	_RefreshT2()

Return


//-----------------------------------------------------------------------
/*/{Protheus.doc} _Visualiz
Função que efetua a visualização dos dados do registro posicionado na tela
@author     Evandro Mugnol
@since      Dez/2023
/*/
//-----------------------------------------------------------------------
Static Function _Visualiz()

	Local aArea    := FWGetArea()
	Local aAreaZM4 := ZM4->(FWGetArea())

	Private cCadastro := ""

	DbSelectArea("ZM4")
	ZM4->(DbSetOrder(1))
	ZM4->(DbGoTop())

	// Se conseguir posicionar
	If ZM4->(DbSeek(FWxFilial("ZM4") + oGetDad1:aCols[oGetDad1:nAt,12]))

		FWExecView( "Visualização Detalhada CTRC" ,;
					"ZM4_MVC1",;
					MODEL_OPERATION_VIEW,;
					/*oDlg*/,;
					{ || .T. },;
					/*bOk*/,;
					/*nPercReducao*/,;
					/*aEnableButtons*/,;
					/*bCancel*/,;
					/*cOperatId*/,;
					/*cToolBar*/,;
					/*oModel*/)
		EndIf

	FWRestArea(aAreaZM4)
	FWRestArea(aArea)

Return


//-----------------------------------------------------------------------
/*/{Protheus.doc} _Processa
Função que efetua do processamento dos registros marcados na tela
	* A rotina TMSImpDoc efetua a geração do Conhecimento de Frete, assim
 	  como a Escrituração Fiscal do Documento.
	* Essa rotina não efetua o cálculo do frete, é necessário enviar todas
	  as informações prontas para geração dos registros.
@author     Evandro Mugnol
@since      Dez/2023
@param		ExpA1 - Vetor com os campos do documento de transporte.
			ExpA2 - Vetor com os campos da composicao do frete.
			ExpA3 - Vetor com as notas fiscais do documento.
			Expc1 - Número do lote.
			Expl1 - Indica se calcula impostos.
			Expn1 - Percentual de impostos.
			Expn2 - Tipo de imposto (1-ICMS,2-ISS).
			Expl2 - Indica se exibe mensagem de erros.
			Expl3 - Indica se verifica integridade DT6/DTC.
			Expl4 - Indica se verifica integridade DT6/DT8.
			Expl5 - Indica se verifica integridade DT6/Demais Tabelas.
			ExpA4 - Array contendo dados do documento original
					Array aDocOri
					-- [1] - Filial Docto Original 	(caracter)
					-- [2] - No. Docto Original 	(caracter)
					-- [3] - Serie Docto Original 	(caracter)
					-- [4] - % Docto. Orignal 		(numerico)
					-- [5] - Complemento de Imposto (lógico)
					-- [6] - nOpcx - TMSA500        (numerico) (Novo!) 
							// Sendo nOpcx o mesmo do TMSA500:
							// 04-Devolução
							// 05-Reentrega
							// 06-Complemento
							// 07-Cancelamento
							// 08-Aliança
							// 09-Manut. Transp
							// 10-Compl.Impost
							// 11-Armazenagem
							// 12-Anulação
							// 13-Substituição
							// 14-Can.Anul
@comments	 Não é obrigatório o uso do aDocOri, somente no caso de criar um complemento.		
/*/
//-----------------------------------------------------------------------
Static Function _Processa(oSay)

	Local aVetDoc 	  := {}
	Local aVetVlr 	  := {}
	Local aVetNFc 	  := {}
	Local aItemDTC	  := {}
	Local aCabDTC 	  := {}
	Local aItem 	  := {}
	Local aDocOri 	  := {} 	// Array para documentos Complementares
	Local lCont 	  := .T.
	Local cLotNfc 	  := ''
	Local cRet 		  := ''
	Local aCab 		  := {}
	Local aErrMsg 	  := {}
	Local lMsErroAuto := .F.
	Local nY
	Local nZ
	Local nAtual 	  := 0
	Local nTotal 	  := 0

	nModulo := 43

	oSay:SetText("Iniciando processamento...")

	//BEGIN TRANSACTION

	// Apura qtde de notas fiscais do lote a ser gerado
	_nQtdLote := 0
	For nY := 1 To Len(oGetDad1:aCols)
		If oGetDad1:aCols[nY,1] == 'LBOK' .And. oGetDad1:aCols[nY,7] == "2"

			DbSelectArea("ZM5")
			DbSetOrder(1)
			DbSeek(FWxFilial("ZM5") + oGetDad1:aCols[nY,12])
			While !Eof() .And. ZM5->ZM5_FILIAL + ZM5->ZM5_CHVCTE == FWxFilial("ZM5") + oGetDad1:aCols[nY,12]
				_nQtdLote += 1
				DbSelectArea("ZM5")
				DbSkip()
			EndDo

		EndIf
	Next nY

	nVez := 1
	For nZ := 1 To Len(oGetDad1:aCols)
		If oGetDad1:aCols[nZ,1] == 'LBOK'

			If oGetDad1:aCols[nZ,7] == "1"			// Processa Cte CANCELADO

				FWAlertWarning("NÃO CONTEMPLA O PROJETO - Processos para cancelamento.", "Envio de CT-e CANCELADO!")

				/*
				SE1	- SE NÃO ESTIVER BAIXADO, EXCLUIR AS DEMAIS TABELAS, CASO CONTRÁRIO NÃO EXCLUI NADA
				SF3
				SFT
				SF2
				SD2
				CD2
				DUD	- Não grava em ct-e complementar
				DT8
				DT6
				DTC	- Não grava em ct-e complementar
				DTP	
				*/

			ElseIf oGetDad1:aCols[nZ,7] == "2"		// Processa Cte AUTORIZADO

				If oGetDad1:aCols[nZ,14] == "1"		// CT-e Complementar

					aCab := {}

					// Gera Lote de Entrada de Notas Fiscais (Tabela DTP)
					AAdd(aCab, {"DTP_QTDLOT" , 1			,NIL})	// Qtde de notas do lote 
					AAdd(aCab, {"DTP_QTDDIG" , 0			,NIL})
					AAdd(aCab, {"DTP_STATUS" , "1"			,NIL}) 	// Em aberto

					MsExecAuto({|x,y|cRet := TMSA170(x,y)}, aCab, 3)		// Lote de Entrada de Notas Fiscais

					If lMsErroAuto
						MostraErro()
						lCont := .F.
					Else
						cLotNfc := cRet
					EndIf

					oSay:SetText("Processando registro " + cValToChar(1) + " de " + cValToChar(1) + "...")
					ProcessMessages() 					// Força o descongelamento do SMARTCLIENT

					aVetDoc := {}
					aVetVlr := {}
					aVetNFc := {}

					If lCont

						lMsErroAuto := .F.

						DbSelectArea("ZM4")
						DbSetOrder(1)
						DbSeek(FWxFilial("ZM4") + oGetDad1:aCols[nZ,12])
						If Found()
							aDocOri  := {}
							DbSelectArea("ZM5")
							DbSetOrder(1)
							DbSeek(FWxFilial("ZM5") + ZM4->ZM4_CHVCTE)
							If Found()
								_cCDRDES := AllTrim(GetAdvFVal("SA1", "A1_CDRDES",  FWxFilial("SA1") + ZM4->ZM4_CODDES + ZM4->ZM4_LOJDES, 1, Space(TamSx3("A1_CDRDES")[1]), .T.))
								_cCDRCAL := AllTrim(GetAdvFVal("SA1", "A1_CDRDES",  FWxFilial("SA1") + ZM4->ZM4_CODDES + ZM4->ZM4_LOJDES, 1, Space(TamSx3("A1_CDRDES")[1]), .T.))

								// Busca dados do Docto Original para CT-e Complementar
								_aDadosDTC := GetAdvFVal("DTC", {"DTC_FILDOC", "DTC_DOC", "DTC_SERIE"}, FWxFilial("DTC") + ZM5->ZM5_DOCPRD + ZM5->ZM5_SERPRD + ZM4->ZM4_CODREM + ZM4->ZM4_LOJREM + ZM5->ZM5_CODPRD , 2, {Space(TamSx3("DTC_FILDOC")[1]), Space(TamSx3("DTC_DOC")[1]), Space(TamSx3("DTC_SERIE")[1])}, .T.)

								AAdd(aVetDoc,{"DT6_FILORI", "00"												})
								AAdd(aVetDoc,{"DT6_LOTNFC", cLotNfc												})
								AAdd(aVetDoc,{"DT6_FILDOC", "00"												})
								AAdd(aVetDoc,{"DT6_DOC"   , ZM4->ZM4_DOCTO										})
								AAdd(aVetDoc,{"DT6_SERIE" , ZM4->ZM4_SERIE										})
								AAdd(aVetDoc,{"DT6_DATEMI", ZM4->ZM4_DTEMIS										})
								AAdd(aVetDoc,{"DT6_HOREMI", ZM4->ZM4_HREMIS										})
								AAdd(aVetDoc,{"DT6_VOLORI", 0													})
								AAdd(aVetDoc,{"DT6_QTDVOL", 0													})
								AAdd(aVetDoc,{"DT6_PESO"  , 0													})
								AAdd(aVetDoc,{"DT6_PESOM3", 0.0000												})
								AAdd(aVetDoc,{"DT6_PESCOB", 0													})
								AAdd(aVetDoc,{"DT6_METRO3", 0.0000												})
								AAdd(aVetDoc,{"DT6_VALMER", 0													})
								AAdd(aVetDoc,{"DT6_QTDUNI", 0													})
								AAdd(aVetDoc,{"DT6_VALFRE", ZM4->ZM4_VLRTOT										})
								AAdd(aVetDoc,{"DT6_VALIMP", (ZM4->ZM4_VLRTOT * 12) / 100						})
								AAdd(aVetDoc,{"DT6_VALTOT", ZM4->ZM4_VLRTOT										})
								AAdd(aVetDoc,{"DT6_BASSEG", 0.00												})
								AAdd(aVetDoc,{"DT6_SERTMS", "3"													})
								AAdd(aVetDoc,{"DT6_TIPTRA", "1"													})
								AAdd(aVetDoc,{"DT6_DOCTMS", "8"													})
								AAdd(aVetDoc,{"DT6_CDRORI", "01001 "											})
								AAdd(aVetDoc,{"DT6_CDRDES", _cCDRDES											})
								AAdd(aVetDoc,{"DT6_CDRCAL", _cCDRCAL											})
								AAdd(aVetDoc,{"DT6_TABFRE", "0003"												})
								AAdd(aVetDoc,{"DT6_TIPTAB", "01"												})
								AAdd(aVetDoc,{"DT6_SEQTAB", "00"												})
								AAdd(aVetDoc,{"DT6_TIPFRE", ZM4->ZM4_CIFFOB										})
								AAdd(aVetDoc,{"DT6_FILDES", "00"												})
								AAdd(aVetDoc,{"DT6_BLQDOC", "2"													})
								AAdd(aVetDoc,{"DT6_PRIPER", "2"													})
								AAdd(aVetDoc,{"DT6_PERDCO", 0													})
								AAdd(aVetDoc,{"DT6_FILDCO", _aDadosDTC[1]										})
								AAdd(aVetDoc,{"DT6_DOCDCO", _aDadosDTC[2]										})
								AAdd(aVetDoc,{"DT6_SERDCO", _aDadosDTC[3]										})
								AAdd(aVetDoc,{"DT6_CLIREM", Padr(ZM4->ZM4_CODREM, Len(DT6->DT6_CLIREM))			})
								AAdd(aVetDoc,{"DT6_LOJREM", Padr(ZM4->ZM4_LOJREM, Len(DT6->DT6_LOJREM))			})
								AAdd(aVetDoc,{"DT6_CLIDES", Padr(ZM4->ZM4_CODDES, Len(DT6->DT6_CLIDES))			})
								AAdd(aVetDoc,{"DT6_LOJDES", Padr(ZM4->ZM4_LOJDES, Len(DT6->DT6_LOJDES))			})
								AAdd(aVetDoc,{"DT6_CLIDEV", Padr(ZM4->ZM4_CODPAG, Len(DT6->DT6_CLIDEV))			})
								AAdd(aVetDoc,{"DT6_LOJDEV", Padr(ZM4->ZM4_LOJPAG, Len(DT6->DT6_LOJDEV))			})
								AAdd(aVetDoc,{"DT6_CLICAL", Padr(ZM4->ZM4_CODREM, Len(DT6->DT6_CLICAL))			})
								AAdd(aVetDoc,{"DT6_LOJCAL", Padr(ZM4->ZM4_LOJREM, Len(DT6->DT6_LOJCAL))			})
								AAdd(aVetDoc,{"DT6_DEVFRE", "1"													})
								AAdd(aVetDoc,{"DT6_FATURA", ""													})
								AAdd(aVetDoc,{"DT6_SERVIC", "018"												})
								AAdd(aVetDoc,{"DT6_CODMSG", ""													})
								AAdd(aVetDoc,{"DT6_STATUS", "6"													})
								AAdd(aVetDoc,{"DT6_DATEDI", Ctod("")											})
								AAdd(aVetDoc,{"DT6_NUMSOL", ""													})
								AAdd(aVetDoc,{"DT6_VENCTO", Ctod("")											})
								AAdd(aVetDoc,{"DT6_FILDEB", "00"												})
								AAdd(aVetDoc,{"DT6_PREFIX", ZM4->ZM4_SERIE										})
								AAdd(aVetDoc,{"DT6_NUM"   , ZM4->ZM4_DOCTO										})
								AAdd(aVetDoc,{"DT6_TIPO"  , "NF"												})
								AAdd(aVetDoc,{"DT6_MOEDA" , 1													})
								AAdd(aVetDoc,{"DT6_BAIXA" , Ctod("")											})
								AAdd(aVetDoc,{"DT6_FILNEG", "00"												})
								AAdd(aVetDoc,{"DT6_VALFAT", ZM4->ZM4_VLRTOT										})
								AAdd(aVetDoc,{"DT6_ALIANC", ""													})
								AAdd(aVetDoc,{"DT6_REENTR", 0													})
								AAdd(aVetDoc,{"DT6_TIPMAN", ""													})
								AAdd(aVetDoc,{"DT6_PRZENT", Ctod("")											})
								AAdd(aVetDoc,{"DT6_FIMP"  , "1"													})
								
								AAdd(aVetVlr,{{"DT8_CODPAS"	, "37"												},;
											  {"DT8_VALPAS"	, ZM4->ZM4_VLRTOT									},;
											  {"DT8_VALIMP"	, (ZM4->ZM4_VLRTOT * 12) / 100						},;
											  {"DT8_VALTOT"	, ZM4->ZM4_VLRTOT									},;
											  {"DT8_FILORI"	, ""												},;
											  {"DT8_TABFRE"	, ""												},;
											  {"DT8_TIPTAB"	, ""												},;
											  {"DT8_FILDOC"	, "00"												},;
											  {"DT8_CODPRO"	, ZM5->ZM5_CODPRD									},;
											  {"DT8_DOC"	, ZM4->ZM4_DOCTO									},;
											  {"DT8_SERIE"	, ZM4->ZM4_SERIE									},;
											  {"VLR_ICMSOL"	, 0													}})

								AAdd(aVetVlr,{{"DT8_CODPAS" , "TF"												},;
											  {"DT8_VALPAS" , ZM4->ZM4_VLRTOT									},;
											  {"DT8_VALIMP" , (ZM4->ZM4_VLRTOT * 12) / 100						},;
											  {"DT8_VALTOT" , ZM4->ZM4_VLRTOT									},;
											  {"DT8_FILORI" , ""												},;
											  {"DT8_TABFRE" , ""												},;
											  {"DT8_TIPTAB" , ""												},;
											  {"DT8_FILDOC" , "00"												},;
											  {"DT8_CODPRO" , ZM5->ZM5_CODPRD									},;
											  {"DT8_DOC"    , ZM4->ZM4_DOCTO									},;
											  {"DT8_SERIE"  , ZM4->ZM4_SERIE									},;
											  {"VLR_ICMSOL" , 0													}})

								AAdd(aVetNFc,{{"DTC_CLIREM" , Padr(ZM4->ZM4_CODREM, Len(DTC->DTC_CLIREM))		},;
											  {"DTC_LOJREM" , Padr(ZM4->ZM4_LOJREM, Len(DTC->DTC_LOJREM))		},;
											  {"DTC_NUMNFC" , ZM5->ZM5_DOCPRD									},;
											  {"DTC_SERNFC" , ZM5->ZM5_SERPRD									},;
											  {"DTC_CODPRO" , ZM5->ZM5_CODPRD									},;
											  {"DTC_QTDVOL" , ZM5->ZM5_QTDVOL									},;
											  {"DTC_PESO"   , ZM5->ZM5_PESPRD									},;
											  {"DTC_PESOM3" , 0.0000											},;
											  {"DTC_METRO3" , 0.0000											},;
											  {"DTC_VALOR"  , ZM4->ZM4_VLRTOT									}})
								
								aDocOri := { _aDadosDTC[1]	,;   // [1] Filial Docto Original  (caracter)
											 _aDadosDTC[2]	,;   // [2] No. Docto Original     (caracter)
											 _aDadosDTC[3]	,; 	 // [3] Serie Docto Original   (caracter)
											 100			,;   // [4] % Docto. Orignal       (numerico)
											 .F.			,;   // [5] Complemento de Imposto (lógico)
											 6 				 }   // [6] nOpcx - TMSA500        (numerico)

								aErrMsg := TMSImpDoc(aVetDoc, aVetVlr, aVetNFc, cLotNfc, .F., 0, 1, .T., .F., .T., .T., aDocOri)
							Else
								FWAlertError("Não encontrado documento de origem para CTe Complementar", "ERRO!")
							EndIf
						EndIf
					EndIf
				Else
					nTotal := _nQtdLote

					DbSelectArea("DT6")
					DbSetOrder(18)
					DbSeek(FWxFilial("DT6") + oGetDad1:aCols[nZ,12])		// Filial + Chave CT-e
					If !Found()

						// Executa uma única vez para poder contar a qtde de notas do lote a ser gerado
						If nVez == 1 
							If _nQtdLote > 0		
								aCab := {}

								// Gera Lote de Entrada de Notas Fiscais (Tabela DTP)
								AAdd(aCab, {"DTP_QTDLOT" , _nQtdLote	,NIL})	// Qtde de notas do lote 
								AAdd(aCab, {"DTP_QTDDIG" , 0			,NIL})
								AAdd(aCab, {"DTP_STATUS" , "1"			,NIL}) 	// Em aberto

								MsExecAuto({|x,y|cRet := TMSA170(x,y)}, aCab, 3)		// Lote de Entrada de Notas Fiscais

								If lMsErroAuto
									MostraErro()
									lCont := .F.
								Else
									cLotNfc := cRet
								EndIf
							Else
								MsgAlert("Não houve registros marcados a processar e integração não será realizada. Verifique!")
								Return
							EndIf
							nVez := 2
						EndIf

						nAtual++
						oSay:SetText("Processando registro " + cValToChar(nAtual) + " de " + cValToChar(nTotal) + "...")
						ProcessMessages() 					// Força o descongelamento do SMARTCLIENT
						
						If lCont
							lMsErroAuto := .F.

							DbSelectArea("ZM4")
							DbSetOrder(1)
							DbSeek(FWxFilial("ZM4") + oGetDad1:aCols[nZ,12])
							If Found()

								_cCDRDES := AllTrim(GetAdvFVal("SA1", "A1_CDRDES",  FWxFilial("SA1") + ZM4->ZM4_CODDES + ZM4->ZM4_LOJDES, 1, Space(TamSx3("A1_CDRDES")[1]),  .T.))
								_cCDRCAL := AllTrim(GetAdvFVal("SA1", "A1_CDRDES",  FWxFilial("SA1") + ZM4->ZM4_CODDES + ZM4->ZM4_LOJDES, 1, Space(TamSx3("A1_CDRDES")[1]),  .T.))

								aCabDTC := {}
								aCabDTC := {{"DTC_FILORI" , "00" 											, Nil},;
											{"DTC_LOTNFC" , cLotNfc 										, Nil},;
											{"DTC_CLIREM" , Padr(ZM4->ZM4_CODREM, Len(DTC->DTC_CLIREM))		, Nil},;
											{"DTC_LOJREM" , Padr(ZM4->ZM4_LOJREM, Len(DTC->DTC_LOJREM))		, Nil},;
											{"DTC_DATENT" , ZM4->ZM4_DTEMIS			 						, Nil},;
											{"DTC_CLIDES" , Padr(ZM4->ZM4_CODDES, Len(DTC->DTC_CLIREM))		, Nil},;
											{"DTC_LOJDES" , Padr(ZM4->ZM4_LOJDES, Len(DTC->DTC_LOJREM))		, Nil},;
											{"DTC_CLIDEV" , Padr(ZM4->ZM4_CODPAG, Len(DTC->DTC_CLIREM))		, Nil},;
											{"DTC_LOJDEV" , Padr(ZM4->ZM4_LOJPAG, Len(DTC->DTC_LOJREM))		, Nil},;
											{"DTC_CLICAL" , Padr(ZM4->ZM4_CODREM, Len(DTC->DTC_CLIREM))		, Nil},;
											{"DTC_LOJCAL" , Padr(ZM4->ZM4_LOJREM, Len(DTC->DTC_LOJREM))		, Nil},;
											{"DTC_DEVFRE" , "1" 											, Nil},;
											{"DTC_SERTMS" , "3" 											, Nil},;
											{"DTC_TIPTRA" , "1" 											, Nil},;
											{"DTC_SERVIC" , "018"			 								, Nil},;
											{"DTC_TIPNFC" , "0"			 									, Nil},;
											{"DTC_TIPFRE" , ZM4->ZM4_CIFFOB 								, Nil},;
											{"DTC_CODNEG" , "01"		 									, Nil},;
											{"DTC_SELORI" , "1"			 									, Nil},;
											{"DTC_CDRORI" , "01001"											, Nil},;
											{"DTC_CDRDES" , _cCDRDES										, Nil},;
											{"DTC_CDRCAL" , _cCDRCAL										, Nil},;
											{"DTC_DISTIV" , "2"												, Nil} }

								aItem    := {}
								aItemDTC := {}
								nTQtdVol := 0
								nTPeso   := 0
								nTVlMerc := 0
								DbSelectArea("ZM5")
								DbSetOrder(1)
								DbSeek(FWxFilial("ZM5") + ZM4->ZM4_CHVCTE)
								While !Eof() .And. ZM5->ZM5_FILIAL + ZM5->ZM5_CHVCTE == FWxFilial("ZM5") + ZM4->ZM4_CHVCTE
									aItem := {{"DTC_NUMNFC" , ZM5->ZM5_DOCPRD								, Nil},;
											  {"DTC_SERNFC" , ZM5->ZM5_SERPRD								, Nil},;
											  {"DTC_CODPRO" , ZM5->ZM5_CODPRD								, Nil},;
											  {"DTC_CODEMB" , "CX"		 									, Nil},;
											  {"DTC_EMINFC" , ZM5->ZM5_EMIPRD		 						, Nil},;
											  {"DTC_QTDVOL" , ZM5->ZM5_QTDVOL								, Nil},;
											  {"DTC_PESO"   , ZM5->ZM5_PESPRD								, Nil},;
											  {"DTC_PESOM3" , 0.0000										, Nil},;
											  {"DTC_VALOR"  , ZM5->ZM5_VLRPRD								, Nil},;
											  {"DTC_BASSEG" , 0.00 											, Nil},;
											  {"DTC_METRO3" , 0.0000										, Nil},;
											  {"DTC_QTDUNI" , 0 											, Nil},;
											  {"DTC_EDI"    , "2" 											, Nil},;
											  {"DTC_CF"	  	, "5101"										, Nil},;
											  {"DTC_USUAGD"	, __cUserID										, Nil},;
											  {"DTC_DOCREE"	, "2"											, Nil},;
											  {"DTC_PRVENT"	, ZM5->ZM5_EMIPRD + 1							, Nil},;
											  {"DTC_NFENTR"	, "1"											, Nil},;
											  {"DTC_NFEID" 	, ZM5->ZM5_CHVPRD								, Nil} }

									AAdd(aItemDTC,aClone(aItem))

									nTQtdVol += ZM5->ZM5_QTDVOL
									nTPeso   += ZM5->ZM5_PESPRD
									nTVlMerc += ZM5->ZM5_VLRPRD
									cCodProd := ZM5->ZM5_CODPRD

									DbSelectArea("ZM5")
									DbSkip()
								EndDo

								// Parametros da TMSA050 (notas fiscais do cliente)
								// xAutoCab 	--> Cabecalho da nota fiscal
								// xAutoItens 	--> Itens da nota fiscal
								// xItensPesM3 	--> acols de Peso Cubado
								// xItensEnder 	--> acols de Enderecamento
								// nOpcAuto 	--> Opcao rotina automatica
								MSExecAuto({|u,v,x,y,z| TMSA050(u,v,x,y,z)},aCabDTC,aItemDTC,,,3)		// Notas Fiscais do Cliente (Doctos de Entrada)

								If lMsErroAuto
									MostraErro()
									lCont := .F.
								Else
									//MostraErro()
									DTC->(dbCommit())
								EndIf
							EndIf

							aVetDoc := {}
							aVetVlr := {}
							aVetNFc := {}
							If lCont
								AAdd(aVetDoc,{"DT6_FILORI", "00"												})
								AAdd(aVetDoc,{"DT6_LOTNFC", cLotNfc												})
								AAdd(aVetDoc,{"DT6_FILDOC", "00"												})
								AAdd(aVetDoc,{"DT6_DOC"   , ZM4->ZM4_DOCTO										})
								AAdd(aVetDoc,{"DT6_SERIE" , ZM4->ZM4_SERIE										})
								AAdd(aVetDoc,{"DT6_DATEMI", ZM4->ZM4_DTEMIS										})
								AAdd(aVetDoc,{"DT6_HOREMI", ZM4->ZM4_HREMIS										})
								AAdd(aVetDoc,{"DT6_VOLORI", nTQtdVol											})
								AAdd(aVetDoc,{"DT6_QTDVOL", nTQtdVol											})
								AAdd(aVetDoc,{"DT6_PESO"  , nTPeso												})
								AAdd(aVetDoc,{"DT6_PESOM3", 0.0000												})
								AAdd(aVetDoc,{"DT6_PESCOB", nTPeso												})
								AAdd(aVetDoc,{"DT6_METRO3", 0.0000												})
								AAdd(aVetDoc,{"DT6_VALMER", nTVlMerc											})
								AAdd(aVetDoc,{"DT6_QTDUNI", 0													})
								AAdd(aVetDoc,{"DT6_VALFRE", ZM4->ZM4_VLRTOT										})
								AAdd(aVetDoc,{"DT6_VALIMP", 0													})
								AAdd(aVetDoc,{"DT6_VALTOT", ZM4->ZM4_VLRTOT										})
								AAdd(aVetDoc,{"DT6_BASSEG", 0.00												})
								AAdd(aVetDoc,{"DT6_SERTMS", "3"													})
								AAdd(aVetDoc,{"DT6_TIPTRA", "1"													})
								AAdd(aVetDoc,{"DT6_DOCTMS", "2"													})
								AAdd(aVetDoc,{"DT6_CDRORI", "01001"												})
								AAdd(aVetDoc,{"DT6_CDRDES", _cCDRDES											})
								AAdd(aVetDoc,{"DT6_CDRCAL", _cCDRCAL											})
								AAdd(aVetDoc,{"DT6_TABFRE", "0003"												})
								AAdd(aVetDoc,{"DT6_TIPTAB", "01"												})
								AAdd(aVetDoc,{"DT6_SEQTAB", "00"												})
								AAdd(aVetDoc,{"DT6_TIPFRE", ZM4->ZM4_CIFFOB										})
								AAdd(aVetDoc,{"DT6_FILDES", "00"												})
								AAdd(aVetDoc,{"DT6_BLQDOC", "2"													})
								AAdd(aVetDoc,{"DT6_PRIPER", "2"													})
								AAdd(aVetDoc,{"DT6_PERDCO", 0.00000												})
								AAdd(aVetDoc,{"DT6_FILDCO", ""													})
								AAdd(aVetDoc,{"DT6_DOCDCO", ""													})
								AAdd(aVetDoc,{"DT6_SERDCO", ""													})
								AAdd(aVetDoc,{"DT6_CLIREM", Padr(ZM4->ZM4_CODREM, Len(DT6->DT6_CLIREM))			})
								AAdd(aVetDoc,{"DT6_LOJREM", Padr(ZM4->ZM4_LOJREM, Len(DT6->DT6_LOJREM))			})
								AAdd(aVetDoc,{"DT6_CLIDES", Padr(ZM4->ZM4_CODDES, Len(DT6->DT6_CLIDES))			})
								AAdd(aVetDoc,{"DT6_LOJDES", Padr(ZM4->ZM4_LOJDES, Len(DT6->DT6_LOJDES))			})
								AAdd(aVetDoc,{"DT6_CLIDEV", Padr(ZM4->ZM4_CODPAG, Len(DT6->DT6_CLIDEV))			})
								AAdd(aVetDoc,{"DT6_LOJDEV", Padr(ZM4->ZM4_LOJPAG, Len(DT6->DT6_LOJDEV))			})
								AAdd(aVetDoc,{"DT6_CLICAL", Padr(ZM4->ZM4_CODREM, Len(DT6->DT6_CLICAL))			})
								AAdd(aVetDoc,{"DT6_LOJCAL", Padr(ZM4->ZM4_LOJREM, Len(DT6->DT6_LOJCAL))			})
								AAdd(aVetDoc,{"DT6_DEVFRE", "1"													})
								AAdd(aVetDoc,{"DT6_FATURA", ""													})
								AAdd(aVetDoc,{"DT6_SERVIC", "018"												})
								AAdd(aVetDoc,{"DT6_CODMSG", ""													})
								AAdd(aVetDoc,{"DT6_STATUS", "1"													})
								AAdd(aVetDoc,{"DT6_DATEDI", Ctod("")											})
								AAdd(aVetDoc,{"DT6_NUMSOL", ""													})
								AAdd(aVetDoc,{"DT6_VENCTO", Ctod("")											})
								AAdd(aVetDoc,{"DT6_FILDEB", "00"												})
								AAdd(aVetDoc,{"DT6_PREFIX", ZM4->ZM4_SERIE										})
								AAdd(aVetDoc,{"DT6_NUM"   , ZM4->ZM4_DOCTO										})
								AAdd(aVetDoc,{"DT6_TIPO"  , "NF"												})
								AAdd(aVetDoc,{"DT6_MOEDA" , 1													})
								AAdd(aVetDoc,{"DT6_BAIXA" , Ctod("")											})
								AAdd(aVetDoc,{"DT6_FILNEG", "00"												})
								AAdd(aVetDoc,{"DT6_VALFAT", ZM4->ZM4_VLRTOT										})
								AAdd(aVetDoc,{"DT6_ALIANC", ""													})
								AAdd(aVetDoc,{"DT6_REENTR", 0													})
								AAdd(aVetDoc,{"DT6_TIPMAN", ""													})
								AAdd(aVetDoc,{"DT6_PRZENT", Ctod("")											})
								AAdd(aVetDoc,{"DT6_FIMP"  , "1"													})
								
								AAdd(aVetVlr,{{"DT8_CODPAS"	, "37"												},;
											  {"DT8_VALPAS"	, ZM4->ZM4_VLRTOT									},;
											  {"DT8_VALIMP"	, 0													},;
											  {"DT8_VALTOT"	, ZM4->ZM4_VLRTOT									},;
											  {"DT8_FILORI"	, ""												},;
											  {"DT8_TABFRE"	, "0003"											},;
											  {"DT8_TIPTAB"	, ""												},;
											  {"DT8_FILDOC"	, "00"												},;
											  {"DT8_CODPRO"	, cCodProd											},;
											  {"DT8_DOC"	, ZM4->ZM4_DOCTO									},;
											  {"DT8_SERIE"	, ZM4->ZM4_SERIE									},;
											  {"VLR_ICMSOL"	, 0													}})

								AAdd(aVetVlr,{{"DT8_CODPAS" , "TF"												},;
											  {"DT8_VALPAS" , ZM4->ZM4_VLRTOT									},;
											  {"DT8_VALIMP" , 0													},;
											  {"DT8_VALTOT" , ZM4->ZM4_VLRTOT									},;
											  {"DT8_FILORI" , ""												},;
											  {"DT8_TABFRE" , ""												},;
											  {"DT8_TIPTAB" , ""												},;
											  {"DT8_FILDOC" , "00"												},;
											  {"DT8_CODPRO" , cCodProd											},;
											  {"DT8_DOC"    , ZM4->ZM4_DOCTO									},;
											  {"DT8_SERIE"  , ZM4->ZM4_SERIE									},;
											  {"VLR_ICMSOL" , 0													}})

								DbSelectArea("ZM5")
								DbSetOrder(1)
								DbSeek(FWxFilial("ZM5") + ZM4->ZM4_CHVCTE)
								While !Eof() .And. ZM5->ZM5_FILIAL + ZM5->ZM5_CHVCTE == FWxFilial("ZM5") + ZM4->ZM4_CHVCTE
									AAdd(aVetNFc,{{"DTC_CLIREM" , Padr(ZM4->ZM4_CODREM, Len(DTC->DTC_CLIREM))	},;
												  {"DTC_LOJREM" , Padr(ZM4->ZM4_LOJREM, Len(DTC->DTC_LOJREM))	},;
												  {"DTC_NUMNFC" , ZM5->ZM5_DOCPRD								},;
												  {"DTC_SERNFC" , ZM5->ZM5_SERPRD								},;
												  {"DTC_CODPRO" , Padr(ZM5->ZM5_CODPRD,Len(DTC->DTC_CODPRO))	},;
												  {"DTC_QTDVOL" , ZM5->ZM5_QTDVOL								},;
												  {"DTC_PESO"   , ZM5->ZM5_PESPRD								},;
												  {"DTC_PESOM3" , 0.0000										},;
												  {"DTC_METRO3" , 0.0000										},;
												  {"DTC_VALOR"  , ZM5->ZM5_VLRPRD								}})
									DbSelectArea("ZM5")
									DbSkip()
								EndDo

								aErrMsg := TMSImpDoc(aVetDoc, aVetVlr, aVetNFc, cLotNfc, .F., 0, 1, .T., .F., .T., .T.)

								// Mantém o lote aberto enquanto não processar todos os documentos do lote aberto,
								// pois a função acima TMSImpDoc() sempre fecha o lote.
								DbSelectArea("DTP")
								DbSetOrder(1)
								DbSeek(xFilial("DTP") + cLotNfc)
								RecLock("DTP",.F.)
								DTP->DTP_STATUS := "1"
								MsUnlock()

							EndIf
						EndIf
					EndIf
				EndIf
			EndIf
		EndIf
	
	Next nZ

	//END TRANSACTION

	oDlgCtrc:End()

Return
