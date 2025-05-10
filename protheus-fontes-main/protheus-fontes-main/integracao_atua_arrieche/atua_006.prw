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
/*/{Protheus.doc} ATUA_006
@Type			: Função de Usuário
@Sample			: U_ATUA_006()
@Description	: Rotina de REST para buscar POST das Despesas da Atua Sistemas
@Param			: N/A
@Return			: Nulo
@ --------------|-----------------------------------------------------------------------
@Author			: Evandro Mugnol
@Since			: Fev/2024
@version		: Protheus 12.1.2210 e posteriores
@Comments		: N/A
/*/
//--------------------------------------------------------------------------------------
User Function ATUA_006(_cCNPJ,_dDtIni,_dDtFim,_cID)

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

	aAdd(aHeader, 'Authorization: Basic ZXZhbmRyby5tdWdub2w6ZXY1NDc0YXR1QA==')
	aAdd(aHeader, 'Cookie: PHPSESSID=mrtb0jvaos5t2ckac5j9h508a5')
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
	cPostParams += 'despesas'
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
Função que pega os dados do arquivo XML e grava a tabela temporária ZM6/ZM7
@author    Evandro Mugnol
@since     Fev/2024
/*/
//-----------------------------------------------------------------------
Static Function _GetXML(cXML)

	Local oXML
	Local nQtBalance   := 0  	// Quantidade de despesas
	Local nQtProduto   := 0  	// Quantidade de produtos por despesa
	Local aListBalance := {}
	Local aListProduto := {}
	Local nX		   := 1
	Local nY		   := 1
	Local cPathBalance := "/despesas"
	Local cPathProduto := "/produtos"
	Local aItensPrd    := {}
	Local oModelA2 	   := Nil
	Local oModelB1 	   := Nil

	Private lMsErroAuto := .F.

	Default cXML := ""

	// Deleta dados da tabela ZM6 para nova carga de dados
	_cQuery1 := "DELETE FROM " + RetSqlName("ZM6")
	_cQuery1 += " WHERE ZM6_FILIAL = '" + FWxFilial("ZM6") + "'" 

	If TcSQLExec(_cQuery1) < 0	
		MsgStop(TcSqlError())
	Endif

	// Deleta dados da tabela ZM7 para nova carga de dados
	_cQuery2 := "DELETE FROM " + RetSqlName("ZM7")
	_cQuery2 += " WHERE ZM7_FILIAL = '" + FWxFilial("ZM7") + "'" 

	If TcSQLExec(_cQuery2) < 0	
		MsgStop(TcSqlError())
	Endif

	oXML := TXMLManager():New()

	If oXML:Parse( cXML )
		// Quantidade de filhos do nó "despesas"
		nQtBalance := oXml:XPAthChildCount(cPathBalance)
		
		// Retorna um array com os nós filhos do nó apontado pela expressão cPathBalance 
		aListBalance := oXml:XPathGetChildArray(cPathBalance)

		While nX <= nQtBalance

			_cIdDesp := oXml:XPathGetNodeValue('/despesas/despesa[' + str(nX) + ']/id')
			_cModelo := oXml:XPathGetNodeValue('/despesas/despesa[' + str(nX) + ']/modelo')
			_cSerie  := oXml:XPathGetNodeValue('/despesas/despesa[' + str(nX) + ']/serie')
			_cCodRet := oXml:XPathGetNodeValue('/despesas/despesa[' + str(nX) + ']/status')
			_cDocto  := oXml:XPathGetNodeValue('/despesas/despesa[' + str(nX) + ']/numero')
			_cDtDoc  := oXml:XPathGetNodeValue('/despesas/despesa[' + str(nX) + ']/dtDocumento')
			_cDtCtb  := oXml:XPathGetNodeValue('/despesas/despesa[' + str(nX) + ']/dtContabil')
			_cDtLct  := oXml:XPathGetNodeValue('/despesas/despesa[' + str(nX) + ']/dtLancamento')
			_cCfop   := oXml:XPathGetNodeValue('/despesas/despesa[' + str(nX) + ']/cfop')
			_ChavNfe := oXml:XPathGetNodeValue('/despesas/despesa[' + str(nX) + ']/nfe/chave')
			_ProtNfe := oXml:XPathGetNodeValue('/despesas/despesa[' + str(nX) + ']/nfe/protocolo')
			_nVlrRet := Val(StrTran(oXml:XPathGetNodeValue('/despesas/despesa[' + str(nX) + ']/vlRetencoes'),",","."))
			_nVlrLiq := Val(StrTran(oXml:XPathGetNodeValue('/despesas/despesa[' + str(nX) + ']/vlLiquido'),",","."))
			_nVlrTot := Val(StrTran(oXml:XPathGetNodeValue('/despesas/despesa[' + str(nX) + ']/vlTotal'),",","."))
			_cHistor := oXml:XPathGetNodeValue('/despesas/despesa[' + str(nX) + ']/historico')
			_cIdHist := oXml:XPathGetNodeValue('/despesas/despesa[' + str(nX) + ']/idHistorico')
			_cIdFav  := oXml:XPathGetNodeValue('/despesas/despesa[' + str(nX) + ']/favorecido/id')
			_cNomFav := oXml:XPathGetNodeValue('/despesas/despesa[' + str(nX) + ']/favorecido/nome')
			_cFanFav := oXml:XPathGetNodeValue('/despesas/despesa[' + str(nX) + ']/favorecido/fantasia')
			_cCgcFav := oXml:XPathGetNodeValue('/despesas/despesa[' + str(nX) + ']/favorecido/cnpjCpf')
			_cIeFav  := oXml:XPathGetNodeValue('/despesas/despesa[' + str(nX) + ']/favorecido/ie')
			_cImFav  := oXml:XPathGetNodeValue('/despesas/despesa[' + str(nX) + ']/favorecido/im')
			_cTipFav := oXml:XPathGetNodeValue('/despesas/despesa[' + str(nX) + ']/favorecido/tipo')
			_cUfFav  := oXml:XPathGetNodeValue('/despesas/despesa[' + str(nX) + ']/favorecido/uf')
			_cMunFav := oXml:XPathGetNodeValue('/despesas/despesa[' + str(nX) + ']/favorecido/cidade')
			_cCdmFav := oXml:XPathGetNodeValue('/despesas/despesa[' + str(nX) + ']/favorecido/ibge')
			_cEndFav := oXml:XPathGetNodeValue('/despesas/despesa[' + str(nX) + ']/favorecido/endereco')
			_cComFav := oXml:XPathGetNodeValue('/despesas/despesa[' + str(nX) + ']/favorecido/complemento')
			_cNumFav := oXml:XPathGetNodeValue('/despesas/despesa[' + str(nX) + ']/favorecido/numero')
			_cCepFav := oXml:XPathGetNodeValue('/despesas/despesa[' + str(nX) + ']/favorecido/cep')
			_cBaiFav := oXml:XPathGetNodeValue('/despesas/despesa[' + str(nX) + ']/favorecido/bairro')
			_cTelFav := oXml:XPathGetNodeValue('/despesas/despesa[' + str(nX) + ']/favorecido/telefone')
			_cEmlFav := oXml:XPathGetNodeValue('/despesas/despesa[' + str(nX) + ']/favorecido/email')
			_cOperac := oXml:XPathGetNodeValue('/despesas/despesa[' + str(nX) + ']/operacao/nome')
			_cCCusto := oXml:XPathGetNodeValue('/despesas/despesa[' + str(nX) + ']/participacoes/participacao/centro_custo/nome')

			//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
			//³ Verifica se existe o fornecedor no Protheus, senão cria um novo			³
			//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
			DbSelectArea("SA2")
			DbSetOrder(3)
			If !DbSeek(FWxFilial("SA2") + _cCgcFav)

				// Pegando o modelo de dados, setando a operação de inclusão
				oModelA2 := FWLoadModel("MATA020")
				oModelA2:SetOperation(MODEL_OPERATION_INSERT)
				oModelA2:Activate()
				
				// Pegando o model e setando os campos, inclusive os obrigatórios
				oSA2Mod := oModelA2:GetModel("SA2MASTER")
				oSA2Mod:SetValue("A2_COD"    , GetSxeNum("SA2", "A2_COD") 							) 
				oSA2Mod:SetValue("A2_LOJA"   , "01"											     	) 
				oSA2Mod:SetValue("A2_NOME"   , _cNomFav												) 
				oSA2Mod:SetValue("A2_NREDUZ" , _cFanFav												) 
				oSA2Mod:SetValue("A2_END"    , _cEndFav												) 
				oSA2Mod:SetValue("A2_BAIRRO" , _cBaiFav												) 
				oSA2Mod:SetValue("A2_EST"    , _cUfFav												) 
				oSA2Mod:SetValue("A2_COD_MUN", _cCdmFav 											) 
				oSA2Mod:SetValue("A2_MUN"    , _cMunFav												) 
				oSA2Mod:SetValue("A2_CEP"    , _cCepFav												)
				oSA2Mod:SetValue("A2_TIPO"   , IIF(_cTipFav=="1","F","J")							)
				oSA2Mod:SetValue("A2_CGC"    , _cCgcFav												)
				oSA2Mod:SetValue("A2_INSCR"  , _cIeFav												)
				oSA2Mod:SetValue("A2_EMAIL"  , _cEmlFav												)
				oSA2Mod:SetValue("A2_NATUREZ", "120102"												)
				oSA2Mod:SetValue("A2_COND"   , "005"												)	// DEFINIR
				oSA2Mod:SetValue("A2_CONTA"  , "2101011001"											)
				oSA2Mod:SetValue("A2_CODPAIS", "01058"												)
				oSA2Mod:SetValue("A2_SIMPNAC", "2"													)	// DEFINIR
				oSA2Mod:SetValue("A2_CDPAIS" , "105"												)
				
				// Se conseguir validar as informações
				If oModelA2:VldData()
					oModelA2:CommitData()	// Realiza o Commit
					ConfirmSX8()
				Else
					RollBackSX8()
					VarInfo("",oModelA2:GetErrorMessage())
				EndIf       
					
				oModelA2:DeActivate()
				oModelA2:Destroy()
				
				oModelA2 := NIL
			EndIf

			// Volta para a ordem default de índice - NÃO REMOVER
			SA2->(dbSetOrder(1))

			_cCodFav := GetAdvFVal("SA2", "A2_COD",  FWxFilial("SA2") + _cCgcFav, 3, Space(TamSx3("A2_COD")[1]),  .T.)
			_cLojFav := GetAdvFVal("SA2", "A2_LOJA", FWxFilial("SA2") + _cCgcFav, 3, Space(TamSx3("A2_LOJA")[1]), .T.)

			// Cria registros na tabela intermediária de importação das Despesas importados da Atua
			DbSelectArea("ZM6")
			Reclock("ZM6",.T.)
			ZM6->ZM6_FILIAL := FWxFilial("ZM6")
			ZM6->ZM6_IDDESP := PadL(AllTrim(_cIdDesp), TamSX3("ZM6_IDDESP")[01], "0")
			If Upper(AllTrim(_cOperac)) == "DESPESA"
				_cOper := "1"
			Else
				_cOper := "2"
			EndIf
			ZM6->ZM6_OPERAC := _cOPer 
			ZM6->ZM6_MODELO := _cModelo
			ZM6->ZM6_DOCTO  := PadL(AllTrim(_cDocto), TamSX3("ZM6_DOCTO")[01], "0")
			ZM6->ZM6_SERIE  := _cSerie
			ZM6->ZM6_DTDOC  := Ctod(Substr(_cDtDoc,09,02) + "/" + Substr(_cDtDoc,06,02) + "/" + Substr(_cDtDoc,01,04))
			ZM6->ZM6_DTCTB  := Ctod(Substr(_cDtCtb,09,02) + "/" + Substr(_cDtCtb,06,02) + "/" + Substr(_cDtCtb,01,04))
			ZM6->ZM6_DTLCTO := Ctod(Substr(_cDtLct,09,02) + "/" + Substr(_cDtLct,06,02) + "/" + Substr(_cDtLct,01,04))
			ZM6->ZM6_HRLCTO := Substr(_cDtLct,12,02) + Substr(_cDtLct,15,02)
			ZM6->ZM6_CFOP   := _cCfop
			ZM6->ZM6_CHVNFE := _ChavNfe
			ZM6->ZM6_PRONFE := _ProtNfe
			DO CASE
				CASE AllTrim(_cCodRet) == "100"
					_cRetNfe := "100 - Autorizado o uso da NF-e"
				CASE AllTrim(_cCodRet) == "101"
					_cRetNfe := "101 - Cancelamento de NF-e homologado"
				CASE AllTrim(_cCodRet) == "102"
					_cRetNfe := "102 - Inutilizacao de numero homologado"
				CASE AllTrim(_cCodRet) == "124"
					_cRetNfe := "124 - DPEC recebido pelo Sistema de Contingencia Eletronica"
				CASE AllTrim(_cCodRet) == "125"
					_cRetNfe := "125 - DPEC localizado"
				CASE AllTrim(_cCodRet) == "126"
					_cRetNfe := "126 - Inexiste DPEC para o numero de registro de DPEC informado"
				CASE AllTrim(_cCodRet) == "127"
					_cRetNfe := "127 - Inexiste DPEC para a chave de acesso da NF-e informada"
				CASE AllTrim(_cCodRet) == "150"
					_cRetNfe := "150 - Autorizado o uso da NF-e, autorizacao concedida fora de prazo"
				CASE AllTrim(_cCodRet) == "151"
					_cRetNfe := "151 - Cancelamento de NF-e homologado fora do prazo"
				CASE AllTrim(_cCodRet) == "155"
					_cRetNfe := "155 - Cancelamento homologado fora de prazo"
				OTHERWISE 
					_cRetNfe := _cCodRet	// Caso retornar este código sem descrição, verificar e tratar conforme acima
			ENDCASE
			ZM6->ZM6_RETNFE := _cRetNfe
			ZM6->ZM6_VLRRET := _nVlrRet
			ZM6->ZM6_VLRLIQ := _nVlrLiq
			ZM6->ZM6_VLRTOT := _nVlrTot
			ZM6->ZM6_IDHIST := _cIdHist
			ZM6->ZM6_HISTOR := _cHistor
			ZM6->ZM6_IDFAV  := PadL(AllTrim(_cIdFav), TamSX3("ZM6_IDFAV")[01], "0")
			ZM6->ZM6_CODFAV := _cCodFav
			ZM6->ZM6_LOJFAV := _cLojFav
			ZM6->ZM6_NOMFAV := _cNomFav
			ZM6->ZM6_FANFAV := _cFanFav
			ZM6->ZM6_CGCFAV := _cCgcFav
			ZM6->ZM6_IEFAV  := _cIeFav
			ZM6->ZM6_IMFAV  := _cImFav
			ZM6->ZM6_TIPFAV := _cTipFav
			ZM6->ZM6_UFFAV  := _cUfFav
			ZM6->ZM6_MUNFAV := _cMunFav
			ZM6->ZM6_CDMFAV := _cCdmFav
			ZM6->ZM6_ENDFAV := _cEndFav
			ZM6->ZM6_COMFAV := _cComFav
			ZM6->ZM6_NUMFAV := _cNumFav
			ZM6->ZM6_CEPFAV := _cCepFav
			ZM6->ZM6_BAIFAV := _cBaiFav
			ZM6->ZM6_TELFAV := _cTelFav
			ZM6->ZM6_EMLFAV := _cEmlFav
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

				// Item / Descrição do produto
				nPos := aScan(aItensPrd,{|x| AllTrim( x[1] ) == 'item' } ) 
				If nPos > 0
					_cDesPrd := aItensPrd[nPos,3]
				Else
					_cDesPrd := ""
				EndIf

				// Grupo do produto
				nPos := aScan(aItensPrd,{|x| AllTrim( x[1] ) == 'grupo' } ) 
				If nPos > 0
					_cGrpPrd := aItensPrd[nPos,3]
				Else
					_cGrpPrd := ""
				EndIf

				// Tipo do produto
				nPos := aScan(aItensPrd,{|x| AllTrim( x[1] ) == 'tipoProduto' } ) 
				If nPos > 0
					_cTipPrd := aItensPrd[nPos,3]
				Else
					_cTipPrd := ""
				EndIf

				// NCM
				nPos := aScan(aItensPrd,{|x| AllTrim( x[1] ) == 'ncm' } ) 
				If nPos > 0
					_cNcmPrd := aItensPrd[nPos,3]
				Else
					_cNcmPrd := "00000000"
				EndIf

				// Quantidade
				nPos := aScan(aItensPrd,{|x| AllTrim( x[1] ) == 'quantidade' } ) 
				If nPos > 0
					_cQtdPrd := aItensPrd[nPos,3]
				Else
					_cQtdPrd := ""
				EndIf

				// Valor
				nPos := aScan(aItensPrd,{|x| AllTrim( x[1] ) == 'valor' } ) 
				If nPos > 0
					_cVlrPrd := aItensPrd[nPos,3]
				Else
					_cVlrPrd := ""
				EndIf

				// Valor Total
				nPos := aScan(aItensPrd,{|x| AllTrim( x[1] ) == 'vlTotal' } ) 
				If nPos > 0
					_cVlTotPrd := aItensPrd[nPos,3]
				Else
					_cVlTotPrd := ""
				EndIf

				// Valor Desconto
				nPos := aScan(aItensPrd,{|x| AllTrim( x[1] ) == 'vlDesconto' } ) 
				If nPos > 0
					_cVlDesPrd := aItensPrd[nPos,3]
				Else
					_cVlDesPrd := ""
				EndIf

				// Historico
				nPos := aScan(aItensPrd,{|x| AllTrim( x[1] ) == 'historico' } ) 
				If nPos > 0
					_cHisPrd := aItensPrd[nPos,3]
				Else
					_cHisPrd := ""
				EndIf

				// Id Historico
				nPos := aScan(aItensPrd,{|x| AllTrim( x[1] ) == 'idHistorico' } ) 
				If nPos > 0
					_cIdHisPrd := aItensPrd[nPos,3]
				Else
					_cIdHisPrd := ""
				EndIf

				_cVlBasPrd := oXml:XPathGetNodeValue('/despesas/despesa[' + str(nY) + ']/produtos/produto/icms/vlBase')
				_cVlIcmPrd := oXml:XPathGetNodeValue('/despesas/despesa[' + str(nY) + ']/produtos/produto/icms/vlIcms')
				_cVlIsePrd := oXml:XPathGetNodeValue('/despesas/despesa[' + str(nY) + ']/produtos/produto/icms/vlIsento')
				_cVlOutPrd := oXml:XPathGetNodeValue('/despesas/despesa[' + str(nY) + ']/produtos/produto/icms/vlOutras')
				_cVlBasImf := oXml:XPathGetNodeValue('/despesas/despesa[' + str(nY) + ']/produtos/produto/impostoFederal/vlBase')
				_cVlPisImf := oXml:XPathGetNodeValue('/despesas/despesa[' + str(nY) + ']/produtos/produto/impostoFederal/pis')
				_cVlCofImf := oXml:XPathGetNodeValue('/despesas/despesa[' + str(nY) + ']/produtos/produto/impostoFederal/cofins')

				//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
				//³ Verifica se existe produto no Protheus, senão cria um novo				³
			    //ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
				DbSelectArea("SB1")
				DbOrderNickName("IDTPATUA")
				If !DbSeek(FWxFilial("SB1") + PadL(AllTrim(_cIdPrd), TamSX3("ZM7_IDPRD")[01], "0") + "C")

					DO CASE
						CASE Upper(AllTrim(_cTipPrd)) == "OUTROS"
							_cTipoPrd := "MC"
							_cUnidPrd := "UN"
						CASE Upper(AllTrim(_cTipPrd)) == "DIESEL"
							_cTipoPrd := "MC"
							_cUnidPrd := "LT"
						CASE Upper(AllTrim(_cTipPrd)) == "ARLA"
							_cTipoPrd := "MC"
							_cUnidPrd := "LT"
						OTHERWISE
							_cTipoPrd := "MC"
							_cUnidPrd := "UN"
					ENDCASE

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
					oSB1Mod:SetValue("B1_TPATUA" , "C"														)
					
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

				//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
				//³ Pesquisa Conta Contabil do Protheus pelo Código do Histório do Atua		³
			    //ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
				DbSelectArea("CT1")
				DbOrderNickName("IDHISTATUA")
				If DbSeek(FWxFilial("CT1") + PadL(AllTrim(_cIdHisPrd), TamSX3("ZM7_IDHIST")[01], "0"))
					_cContaCtb := CT1->CT1_CONTA
				Else
					_cContaCtb := ""
				EndIf

				//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
				//³ Pesquisa Item Contabil do Protheus pelo Nome do Centro de Custo do Atua	³
			    //ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
				DbSelectArea("CTD")
				DbSetOrder(4)
				If DbSeek(FWxFilial("CTD") + AllTrim(_cCCusto))
					_cItemCtb := CTD->CTD_ITEM
				Else
					_cItemCtb := ""
				EndIf

				// Cria registros na tabela intermediária de importação dos CTRCs Produtos importados da Atua
				DbSelectArea("ZM7")
				Reclock("ZM7",.T.)
				ZM7->ZM7_FILIAL := FWxFilial("ZM7")
				ZM7->ZM7_ITEPRD := StrZero(nY, 4, 0)
				ZM7->ZM7_IDPRD  := PadL(AllTrim(_cIdPrd), TamSX3("ZM7_IDPRD")[01], "0") 
				ZM7->ZM7_DESATU := _cDesPrd 
				ZM7->ZM7_NCMPRD := _cNcmPrd
				ZM7->ZM7_CODPRD := _cProdERP
				ZM7->ZM7_DESPRD := _cDescERP
				ZM7->ZM7_QTDPRD := Val(StrTran(_cQtdPrd,",","."))
				ZM7->ZM7_VLRPRD := Val(StrTran(_cVlrPrd,",","."))
				ZM7->ZM7_TOTPRD := Val(StrTran(_cVlTotPrd,",","."))
				ZM7->ZM7_DESCON := Val(StrTran(_cVlDesPrd,",","."))
				ZM7->ZM7_IDHIST := _cIdHisPrd
				ZM7->ZM7_HISTOR := _cHisPrd
				ZM7->ZM7_CTACTB := _cContaCtb 
				ZM7->ZM7_ITECTB := _cItemCtb
				ZM7->ZM7_BASICM := Val(StrTran(_cVlBasPrd,",","."))
				ZM7->ZM7_VALICM := Val(StrTran(_cVlIcmPrd,",","."))
				ZM7->ZM7_ISEICM := Val(StrTran(_cVlIsePrd,",","."))
				ZM7->ZM7_OUTICM := Val(StrTran(_cVlOutPrd,",","."))
				ZM7->ZM7_BASEPC := Val(StrTran(_cVlBasImf,",","."))
				ZM7->ZM7_VALPIS := Val(StrTran(_cVlPisImf,",","."))
				ZM7->ZM7_VALCOF := Val(StrTran(_cVlCofImf,",","."))
				ZM7->ZM7_GRPPRD := _cGrpPrd
				ZM7->ZM7_TIPPRD := _cTipPrd
				ZM7->ZM7_DOCTO  := ZM6->ZM6_DOCTO
				ZM7->ZM7_SERIE  := ZM6->ZM6_SERIE
				ZM7->ZM7_CODFAV := ZM6->ZM6_CODFAV
				ZM7->ZM7_LOJFAV := ZM6->ZM6_LOJFAV
				ZM7->ZM7_IDDESP := ZM6->ZM6_IDDESP
				MsUnlock()

				nY++
			EndDo	

			nX++
		EndDo	

		oXML := Nil

		// Monta tela para processamento dos dados importados e posteriormente gera ou cancela CTe conforme situação
		_TelaDesp()
	Else
		MsgAlert("Error: " + oXML:Error())
		Return
	EndIf

Return


//-----------------------------------------------------------------------
/*/{Protheus.doc} _TelaDesp
Função que monta tela para processamento dos dados no Protheus
@author     Evandro Mugnol
@since      Fev/2024
/*/
//-----------------------------------------------------------------------
Static Function _TelaDesp()

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
	Private oDlgDesp
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
	// Neste caso serão 15 colunas incluindo o campo que possui caixa de seleção ou checkBox e legendas
	aAdd(aCpos1,"ZM6_IDDESP")
	aAdd(aCpos1,"ZM6_OPERAC")
	aAdd(aCpos1,"ZM6_DOCTO")
	aAdd(aCpos1,"ZM6_SERIE")
	aAdd(aCpos1,"ZM6_CGCFAV")
	aAdd(aCpos1,"ZM6_CODFAV")
	aAdd(aCpos1,"ZM6_LOJFAV")
	aAdd(aCpos1,"ZM6_NOMFAV")
	aAdd(aCpos1,"ZM6_DTDOC")
	aAdd(aCpos1,"ZM6_DTLCTO")
	aAdd(aCpos1,"ZM6_HRLCTO")
	aAdd(aCpos1,"ZM6_CHVNFE")
	aAdd(aCpos1,"ZM6_PRONFE")
	aAdd(aCpos1,"ZM6_VLRLIQ")
	aAdd(aCpos1,"ZM6_VLRTOT")

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
	// Neste caso serão 11 colunas
	aAdd(aCpos2,"ZM7_ITEPRD")
	aAdd(aCpos2,"ZM7_DESATU")
	aAdd(aCpos2,"ZM7_NCMPRD")
	aAdd(aCpos2,"ZM7_CODPRD")
	aAdd(aCpos2,"ZM7_DESPRD")
	aAdd(aCpos2,"ZM7_QTDPRD")
	aAdd(aCpos2,"ZM7_VLRPRD")
	aAdd(aCpos2,"ZM7_TOTPRD")
	aAdd(aCpos2,"ZM7_CTACTB")
	aAdd(aCpos2,"ZM7_ITECTB")
	aAdd(aCpos2,"ZM7_DESCON")
	aAdd(aCpos2,"ZM7_VALICM")
	aAdd(aCpos2,"ZM7_VALPIS")
	aAdd(aCpos2,"ZM7_VALCOF")
	aAdd(aCpos2,"ZM7_IDDESP")

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

	DEFINE MSDIALOG oDlgDesp TITLE "Despesas Lidas da Importação da Atua Sistemas" From aSize[7],0 to aSize[6],aSize[5] of oMainWnd PIXEL

	_oPanel := TPanel():New(aPosObj[1,1], aPosObj[1,2], , oDlgDesp ,, .F., ,, , aPosObj[1,4], aPosObj[1,3], .T., .F.)

	// Objeto oChk de checkbox e variável lChkSel. Quando clicado, executa o método "Seleciona" e possibilita
	// que o usuário selecione todas as linhas ao mesmo tempo.
	@ 025, 003 CHECKBOX oChk VAR lChkSel PROMPT "Marca/Desmarca Todos" SIZE 070, 007 on CLICK Seleciona(lChkSel) OF _oPanel PIXEL

	aObjSay := tSay():New(000, 090, {|| OemToAnsi('Legenda Atua')}  			, _oPanel,,oFontLeg,,,, .T., RGB(031, 073, 125), , 100, 020)

	aObjBmp := TBitmap():New(011, 090, 068, 010, 'BR_VERDE'  					, , .T., _oPanel, {|| }, {|| }, .F., .F.,,, .F.,, .T.,, .F.)
	aObjSay := tSay():New(012, 100, {|| OemToAnsi('Despesa Lançada')}  			, _oPanel,,,,,, .T., CLR_BLACK, CLR_WHITE, 100, 020)

	aObjSay := tSay():New(000, 240, {|| OemToAnsi('Legenda Protheus')}  		, _oPanel,,oFontLeg,,,, .T., RGB(031, 073, 125), , 100, 020)

	aObjBmp := TBitmap():New(011, 240, 068, 010, 'BR_VERDE'  					, , .T., _oPanel, {|| }, {|| }, .F., .F.,,, .F.,, .T.,, .F.)
	aObjSay := tSay():New(012, 250, {|| OemToAnsi('Despesa Já Importada')} 		, _oPanel,,,,,, .T., CLR_BLACK, CLR_WHITE, 100, 020)

	aObjBmp := TBitmap():New(019, 240, 068, 010, 'BR_VERMELHO'  				, , .T., _oPanel, {|| }, {|| }, .F., .F.,,, .F.,, .T.,, .F.)
	aObjSay := tSay():New(020, 250, {|| OemToAnsi('Despesa Não Importada')}		, _oPanel,,,,,, .T., CLR_BLACK, CLR_WHITE, 100, 020)

	aObjBmp := TBitmap():New(027, 240, 068, 010, 'BR_PRETO'  						, , .T., _oPanel, {|| }, {|| }, .F., .F.,,, .F.,, .T.,, .F.)
	aObjSay := tSay():New(028, 250, {|| OemToAnsi('Problema Cadastro Fornecedor')}	, _oPanel,,,,,, .T., CLR_BLACK, CLR_WHITE, 100, 020)

	aObjBmp := TBitmap():New(035, 240, 068, 010, 'BR_CANCEL'  						, , .T., _oPanel, {|| }, {|| }, .F., .F.,,, .F.,, .T.,, .F.)
	aObjSay := tSay():New(036, 250, {|| OemToAnsi('Despesa com Problema no Atua')}	, _oPanel,,,,,, .T., CLR_BLACK, CLR_WHITE, 100, 020)

	oGetDad1:= MsNewGetDados():New((aPosObj[2,1])   ,(aPosObj[2,2])+3, aPosObj[2,3]-15, aPosObj[2,4]+8,GD_UPDATE,/*LinOk*/,/*[cTudoOk]*/,/*[cIniCpos]*/,{'CHECKBOL'},1,9999,/*[cCampoOk]*/,/*[cSuperApagar]*/,/*[cApagaOk]*/,oDlgDesp,aHead1,aCols1)

	oGetDad2:= MsNewGetDados():New((aPosObj[3,1])-15,(aPosObj[3,2])  , aPosObj[3,3]   , aPosObj[3,4]+8,GD_UPDATE,/*LinOk*/,/*[cTudoOk]*/,/*[cIniCpos]*/,/*aAlt*/    ,0,9999,/*[cCampoOk]*/,/*[cSuperApagar]*/,/*[cApagaOk]*/,oDlgDesp,aHead2,aCols2)

	// Antes de ativar a tela (oDlgDesp) busca todas informações para carregar o oGetDad1
	_ZM6Cab()

	// Botões da Tela
	@ aPosObj[2,2] * 2, aPosObj[2,4] - 210 BUTTON "Pesquisar"  SIZE 060, 015 ACTION {|| GdSeek(oGetDad1,"Busca Itens",oGetDad1:aHeader,oGetDad1:aCols,If(Type("oGetDad1:aIniCpos")=="A",.T.,)) } OF _oPanel PIXEL
	@ aPosObj[2,2] * 2, aPosObj[2,4] - 140 BUTTON "Visualizar" SIZE 060, 015 ACTION (_Visualiz()) OF _oPanel PIXEL
	@ aPosObj[2,2] * 2, aPosObj[2,4] - 070 BUTTON "Processar"  SIZE 060, 015 ACTION FWMsgRun(, {|oSay| _Processa(oSay) }, "Aguarde", "Processando Geração das Pré-Notas no Protheus ...") OF _oPanel PIXEL

	oDlgDesp:lEscClose := .F.
	ACTIVATE MSDIALOG oDlgDesp CENTERED ON INIT EnchoiceBar(oDlgDesp, {||oDlgDesp:End()}, { ||oDlgDesp:End()},,aButtons,,,.T.,.T., .T., .F.,.T.,)

Return


//-----------------------------------------------------------------------
/*/{Protheus.doc} Seleciona
Função que faz a marcação dos registros na tela
@author     Evandro Mugnol
@since      Fev/2024
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
	oDlgDesp:Refresh()

Return


//-----------------------------------------------------------------------
/*/{Protheus.doc} _ZM6Cab
Função que carrega todos registros da tabela intermediária ZM6 para tela
@author     Evandro Mugnol
@since      Fev/2024
/*/
//-----------------------------------------------------------------------
Static Function _ZM6Cab()

	Local oBmpAtua
	Local oBmpProt

	Private aCols1 := {}

	// Atualiza/Recarrega o oGetDad1 e o oDlgDesp antes de receber novos dados
	_Refresh(aCols1)

	DbSelectArea("ZM6")
	DbSetOrder(1)
	DbGoTop()
	DbSeek(FWxFilial("ZM6"))
	While !Eof() .And. ZM6->ZM6_FILIAL == FWxFilial("ZM6")
		oBmpAtua := oBmpVerde

		DbSelectArea("SF1")
		DbSetOrder(1)
		DbSeek(FWxFilial("SF1") + ZM6->ZM6_DOCTO + ZM6->ZM6_SERIE + ZM6->ZM6_CODFAV + ZM6->ZM6_LOJFAV)	// Filial + Documento + Serie + Fornecedor + Loja
		If Found()
			_cMarcar := "N"
			oBmpProt := oBmpVerde
		Else
			_cMarcar := "S"
			oBmpProt := oBmpVermelho
		EndIf

		// Verifica se está bloqueado no cadastro de fornecedores
		_MSBLQL := AllTrim(GetAdvFVal("SA2", "A2_MSBLQL",  FWxFilial("SA2") + ZM6->ZM6_CODFAV + ZM6->ZM6_LOJFAV, 1, Space(TamSx3("A2_MSBLQL")[1]),  .T.))

		If _MSBLQL == "1"
			_cMarcar := "N"
			oBmpProt := oBmpPreto
			FWAlertWarning("VERIFICAR  Fornecedor/Loja: " + ZM6->ZM6_CODFAV + "/" + ZM6->ZM6_LOJFAV + " está bloqueado.", "Problema com Cadastro do Fornecedor!")
		Else
			DbSelectArea("ZM7")
			DbSetOrder(2)
			DbSeek(FWxFilial("ZM7") + ZM6->ZM6_IDDESP)
			If !Found()	
				_cMarcar := "N"
				oBmpProt := oBmpCancel
				FWAlertWarning("Despesa ref. documento/serie: " + ZM6->ZM6_DOCTO + "/" + ZM6->ZM6_SERIE + " não tem produto/serviço informado.", "Problema Oriundo do Sistema Atua!")
			EndIf
		EndIf

		DbSelectArea("ZM6")
		If _cMarcar == "S"
			aAdd(aCols1, {'LBOK', oBmpAtua, oBmpProt, ZM6->ZM6_IDDESP, ZM6->ZM6_OPERAC, ZM6->ZM6_DOCTO, ZM6->ZM6_SERIE, ZM6->ZM6_CGCFAV, ZM6->ZM6_CODFAV, ZM6->ZM6_LOJFAV, ZM6->ZM6_NOMFAV, ZM6->ZM6_DTDOC, ZM6->ZM6_DTLCTO, ZM6->ZM6_HRLCTO, ZM6->ZM6_CHVNFE, ZM6->ZM6_PRONFE, ZM6->ZM6_VLRLIQ, ZM6->ZM6_VLRTOT, .F.})
		Else
			aAdd(aCols1, {'LBNO', oBmpAtua, oBmpProt, ZM6->ZM6_IDDESP, ZM6->ZM6_OPERAC, ZM6->ZM6_DOCTO, ZM6->ZM6_SERIE, ZM6->ZM6_CGCFAV, ZM6->ZM6_CODFAV, ZM6->ZM6_LOJFAV, ZM6->ZM6_NOMFAV, ZM6->ZM6_DTDOC, ZM6->ZM6_DTLCTO, ZM6->ZM6_HRLCTO, ZM6->ZM6_CHVNFE, ZM6->ZM6_PRONFE, ZM6->ZM6_VLRLIQ, ZM6->ZM6_VLRTOT, .F.})
		EndIf

		DbSelectArea("ZM6")
		DbSkip()
	EndDo

	// Atualiza o oGetDad1 com o novo array
	_Refresh(aCols1)
	_RefreshT1()

Return


//-----------------------------------------------------------------------
/*/{Protheus.doc} _Refresh
Função que refersh do oGetDad1
@author     Evandro Mugnol
@since     	Fev/2024
/*/
//-----------------------------------------------------------------------
Static Function _Refresh(aDados)

	oGetDad1:oBrowse:Refresh()
	oDlgDesp:Refresh()

	oGetDad1:= MsNewGetDados():New((aPosObj[2,1]),   (aPosObj[2,2])+3, aPosObj[2,3]-15, aPosObj[2,4]+8,GD_UPDATE,/*LinOk*/,/*[cTudoOk]*/,/*[cIniCpos]*/,{'CHECKBOL'},1,9999,/*[cCampoOk]*/,/*[cSuperApagar]*/,/*[cApagaOk]*/,oDlgDesp,aHead1,aCols1)
	// Quando clicado duas vezes sobre o aCols[oGetDad1:nAt,1], ou seja, onde ficará a coluna com o checkbox, ele irá alternar de LBOK para LBNO e vice versa
	//oGetDad1:oBrowse:bLDblClick := {|| oGetDad1:EditCell(), oGetDad1:aCols[oGetDad1:nAt,1] := iif(oGetDad1:aCols[oGetDad1:nAt,1] == 'LBOK','LBNO','LBOK')}
	oGetDad1:oBrowse:bLDblClick := {|| oGetDad1:EditCell(), oGetDad1:aCols[oGetDad1:nAt,1] := _VldMarc(oGetDad1:aCols[oGetDad1:nAt,1], oGetDad1:aCols[oGetDad1:nAt,4], oGetDad1:aCols[oGetDad1:nAt,6], oGetDad1:aCols[oGetDad1:nAt,7], oGetDad1:aCols[oGetDad1:nAt,9], oGetDad1:aCols[oGetDad1:nAt,10], oGetDad1:aCols[oGetDad1:nAt,2]:CNAME, oGetDad1:aCols[oGetDad1:nAt,3]:CNAME)}
	// Executa quando troca de linha.
	oGetDad1:oBrowse:bChange    := {|| _ZM7Ite()}

	oGetDad2:oBrowse:Refresh()
	oDlgDesp:Refresh()

	oGetDad2:= MsNewGetDados():New((aPosObj[3,1])-15,(aPosObj[3,2])  , aPosObj[3,3]   , aPosObj[3,4]+8,GD_UPDATE,/*LinOk*/,/*[cTudoOk]*/,/*[cIniCpos]*/,/*aAlt*/    ,0,9999,/*[cCampoOk]*/,/*[cSuperApagar]*/,/*[cApagaOk]*/,oDlgDesp,aHead2,aCols2)

Return


//-----------------------------------------------------------------------
/*/{Protheus.doc} _VldMarc
Função que valida a marcação da linha com dados do cliente
@author     Evandro Mugnol
@since      Dez/2023
/*/
//-----------------------------------------------------------------------
Static Function _VldMarc(_cTpMarc, _IdDesp, _cDoc, _cSer, _Forn, _Loja, _ObjAtua, _ObjProt)

	_RetMarc := _cTpMarc

	If _ObjAtua == _ObjProt
		FWAlertWarning("Não é permitido realizar a marcação desta linha", "Despesa já integrada.")
		_RetMarc := "LBNO"
	Else
		// Verifica se está bloqueado no cadastro de fornecedores
		_MSBLQL := AllTrim(GetAdvFVal("SA2", "A2_MSBLQL",  FWxFilial("SA2") + _Forn + _Loja, 1, Space(TamSx3("A2_MSBLQL")[1]),  .T.))

		If _MSBLQL == "1"
			_RetMarc := "LBNO"
			FWAlertWarning("VERIFICAR  Fornecedor/Loja: " + _Forn + "/" + _Loja + " está bloqueado.", "Problema com Cadastro do Fornecedor!")
		Else
			DbSelectArea("ZM7")
			DbSetOrder(2)
			DbSeek(FWxFilial("ZM7") + _IdDesp)
			If !Found()	
				_RetMarc := "LBNO"
				FWAlertWarning("Despesa ref. documento/serie: " + _cDoc + "/" + _cSer + " não tem produto/serviço informado.", "Problema Oriundo do Sistema Atua!")
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
@since      Fev/2024
/*/
//-----------------------------------------------------------------------
Static function _RefreshT1()

	oGetDad1:aCols := aClone(aCols1)
	oGetDad1:oBrowse:Refresh()

	If len(aCols1) > 0
		_ZM7Ite()
	Else
		aCols2 := {}
		_RefreshT2()
	EndIf

Return


//-----------------------------------------------------------------------
/*/{Protheus.doc} _RefreshT2
Função de refresh da tela 2 (item)
@author     Evandro Mugnol
@since      Fev/2024
/*/
//-----------------------------------------------------------------------
Static function _RefreshT2()

	oGetDad2:aCols := aClone(aCols2)
	oGetDad2:oBrowse:Refresh()

Return


//-----------------------------------------------------------------------
/*/{Protheus.doc} _ZM7Ite
Função que carrega dados do produto da tabela intermediária ZM7 para tela
@author     Evandro Mugnol
@since      Fev/2024
/*/
//-----------------------------------------------------------------------
static function _ZM7Ite()

	_cQuery := " SELECT ZM7_ITEPRD, ZM7_DESATU, ZM7_NCMPRD, ZM7_CODPRD, ZM7_DESPRD, ZM7_QTDPRD, ZM7_VLRPRD, ZM7_TOTPRD, ZM7_CTACTB, ZM7_ITECTB, ZM7_DESCON, ZM7_VALICM, ZM7_VALPIS, ZM7_VALCOF "
	_cQuery += "   FROM " + RetSqlTab("ZM7")
	_cQuery += "  WHERE " + RetSqlFil("ZM7")
	_cQuery += "    AND ZM7_IDDESP = '" + oGetDad1:aCols[oGetDad1:nAt,4] + "' "
	_cQuery += "    AND " + RetSqlDel("ZM7")

	_cQuery  := ChangeQuery(_cQuery)

	If Select("TMP") != 0
		TMP->(dbCloseArea())
	Endif

	TCQUERY _cQuery NEW ALIAS "TMP"

	aCols2 := {}
	DbSelectArea("TMP")
	DbGoTop()
	Do While !eof()
		aAdd(aCols2, {TMP->ZM7_ITEPRD, TMP->ZM7_DESATU, TMP->ZM7_NCMPRD, TMP->ZM7_CODPRD, TMP->ZM7_DESPRD, TMP->ZM7_QTDPRD, TMP->ZM7_VLRPRD, TMP->ZM7_TOTPRD, TMP->ZM7_CTACTB, TMP->ZM7_ITECTB, TMP->ZM7_DESCON, TMP->ZM7_VALICM, TMP->ZM7_VALPIS, TMP->ZM7_VALCOF, .F.})

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
@since      Fev/2024
/*/
//-----------------------------------------------------------------------
Static Function _Visualiz()

	Local aArea    := FWGetArea()
	Local aAreaZM6 := ZM6->(FWGetArea())

	Private cCadastro := ""

	DbSelectArea("ZM6")
	ZM6->(DbSetOrder(2))
	ZM6->(DbGoTop())

	// Se conseguir posicionar
	If ZM6->(DbSeek(FWxFilial("ZM6") + oGetDad1:aCols[oGetDad1:nAt,4]))

		FWExecView( "Visualização Detalhada Despesa" ,;
					"ZM6_MVC1",;
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

	FWRestArea(aAreaZM6)
	FWRestArea(aArea)

Return


//-----------------------------------------------------------------------
/*/{Protheus.doc} _Processa
Função que efetua a inclusão de Notas Fiscais de Entrada sem os dados Fiscais,
através do mecanismo de rotina automática.
@author     Evandro Mugnol
@since      Fev/2024
@param		aCabec		Array of Record		Cabeçalho da nota
			aItens		Array of Record		Itens da nota
			nOpc		Array of Record		3=Inclusão, 4=Alteração, 5=Exclusão, 7=Estorna Classificação	
			lSimula		Lógico				.T. para habilitar simulação / .F. para desabilitar a simulação	
			nTelaAuto	Numérico			0=Não mostra tela, 1=Mostra tela e valida tudo, 2=Mostra tela e valida somente cabeçalho
@comments	Para opção Inclusão
			Quando utilizado o Formulário Próprio = "S", deve-se enviar somente a serie do documento
			LINPOS
			cSerie := "001"
			
			aAdd(aCab,{"F1_SERIE" ,cSerie ,NIL})
/*/
//-----------------------------------------------------------------------
Static Function _Processa(oSay)

	Local nAtual := 0
	Local nTotal := 0
	Local nZ
	Local nOpc 	 := 3
		
	Private aCabec      := {}
	Private aItens      := {}
	Private aLinha      := {}
	Private lMsErroAuto := .F.
		
	oSay:SetText("Iniciando processamento...")

	// Altera a ordem das perguntas para gravar itens na ordem do recebimento
	Pergunte("MTA140",.F.)
	SetMVValue("MTA140","MV_PAR01", 1)		// Aplicar Reajuste - 1=Sim ; 2=Não
	SetMVValue("MTA140","MV_PAR02", 1)		// Quanto ao PC - 1=Fornecedor+Loja ; 2=Fornecedor
	SetMVValue("MTA140","MV_PAR03", 2)		// Ordenar itens por - 1=Codigo Produto ; 2=Item

	BEGIN TRANSACTION

	nTotal := Len(oGetDad1:aCols)

	For nZ := 1 To Len(oGetDad1:aCols)

		If oGetDad1:aCols[nZ,1] == 'LBOK'

			nAtual++
			oSay:SetText("Processando registro " + cValToChar(nAtual) + " de " + cValToChar(nTotal) + "...")
			ProcessMessages() 					// Força o descongelamento do SMARTCLIENT

			aCabec      := {}
			aLinha      := {}
			lMsErroAuto := .F.

			DbSelectArea("ZM6")
			DbSetOrder(2)
			DbSeek(FWxFilial("ZM6") + oGetDad1:aCols[nZ,4])
			If Found()
				aAdd(aCabec,{"F1_TIPO"	 , "N"													,NIL})
				aAdd(aCabec,{"F1_FORMUL" , "N"													,NIL})
				aAdd(aCabec,{"F1_DOC"	 , ZM6->ZM6_DOCTO										,NIL})
				aAdd(aCabec,{"F1_SERIE"	 , ZM6->ZM6_SERIE										,NIL})
				aAdd(aCabec,{"F1_EMISSAO", ZM6->ZM6_DTDOC										,NIL})
				aAdd(aCabec,{"F1_DTDIGIT", ZM6->ZM6_DTLCTO										,NIL})
				aAdd(aCabec,{"F1_FORNECE", ZM6->ZM6_CODFAV										,NIL})
				aAdd(aCabec,{"F1_LOJA"	 , ZM6->ZM6_LOJFAV										,NIL})
				aAdd(aCabec,{"F1_ESPECIE", IIF(AllTrim(ZM6->ZM6_MODELO)=="55","SPED","NFS")		,NIL})
				aAdd(aCabec,{"F1_COND"	 , ""													,NIL})
				aAdd(aCabec,{"F1_STATUS" , ""													,NIL})
			
				DbSelectArea("ZM7")
				DbSetOrder(1)
				DbSeek(FWxFilial("ZM7") + ZM6->ZM6_DOCTO + ZM6->ZM6_SERIE + ZM6->ZM6_CODFAV + ZM6->ZM6_LOJFAV)
				While !Eof() .And. ZM7->ZM7_FILIAL + ZM7->ZM7_DOCTO + ZM7->ZM7_SERIE + ZM7->ZM7_CODFAV + ZM7->ZM7_LOJFAV == FWxFilial("ZM7") + ZM6->ZM6_DOCTO + ZM6->ZM6_SERIE + ZM6->ZM6_CODFAV + ZM6->ZM6_LOJFAV
					aItens := {}
					aAdd(aItens,{"D1_ITEM"   , ZM7->ZM7_ITEPRD																							,NIL})
					aAdd(aItens,{"D1_COD"    , ZM7->ZM7_CODPRD																							,NIL})
					aAdd(aItens,{"D1_DESCRI" , GetAdvFVal("SB1", "B1_DESC", FWxFilial("SB1") + ZM7->ZM7_CODPRD, 1, Space(TamSx3("B1_DESC")[1]),  .T.)	,NIL})
					aAdd(aItens,{"D1_QUANT"  , ZM7->ZM7_QTDPRD																							,Nil})
					aAdd(aItens,{"D1_VUNIT"  , ZM7->ZM7_VLRPRD																							,Nil})
					aAdd(aItens,{"D1_TOTAL"  , ZM7->ZM7_TOTPRD + ZM7->ZM7_DESCON																		,Nil})
					aAdd(aItens,{"D1_TES"    , ""																										,NIL})
					aAdd(aItens,{"D1_CONTA"  , ZM7->ZM7_CTACTB																							,NIL})
					aAdd(aItens,{"D1_CC"     , ""																										,NIL})
					aAdd(aItens,{"D1_ITEMCTA", ZM7->ZM7_ITECTB																							,NIL})
					aAdd(aItens,{"D1_VALDESC", ZM7->ZM7_DESCON																							,Nil})
					
					aAdd(aLinha,aItens)

					DbSelectArea("ZM7")
					DbSkip()
				EndDo

				MSExecAuto({|x,y,z,a,b| MATA140(x,y,z,a,b)}, aCabec, aLinha, nOpc)

				If lMsErroAuto
					MostraErro()
				EndIf
			EndIf

		EndIf
	Next nZ

	END TRANSACTION

	// Restaura a ordem das perguntas para gravar itens na ordem do recebimento
	Pergunte("MTA140",.F.)
	SetMVValue("MTA140","MV_PAR01", 1)		// Aplicar Reajuste - 1=Sim ; 2=Não
	SetMVValue("MTA140","MV_PAR02", 1)		// Quanto ao PC - 1=Fornecedor+Loja ; 2=Fornecedor
	SetMVValue("MTA140","MV_PAR03", 1)		// Ordenar itens por - 1=Codigo Produto ; 2=Item

	oDlgDesp:End()

Return
