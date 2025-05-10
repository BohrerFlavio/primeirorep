#INCLUDE "TOTVS.CH"
#INCLUDE "RESTFUL.CH"
#INCLUDE "FILEIO.CH"
#INCLUDE "XMLXFUN.CH"
#INCLUDE "COLORS.CH"
#INCLUDE "TOPCONN.CH"

#DEFINE CRLF Chr(13) + Chr(10)

// Legendas
Static oBmpVerde    := LoadBitmap( GetResources(), "BR_VERDE")
Static oBmpVermelho := LoadBitmap( GetResources(), "BR_VERMELHO")
Static oBmpLaranja  := LoadBitmap( GetResources(), "BR_LARANJA")
Static oBmpCancel   := LoadBitmap( GetResources(), "BR_CANCEL")
Static oBmpInativo  := LoadBitmap( GetResources(), "BR_PRETO")

//--------------------------------------------------------------------------------------
/*/{Protheus.doc} ATUA_003
@Type			: Função de Usuário
@Sample			: U_ATUA_003()
@Description	: Rotina de REST para buscar POST do cadastro de Veículos da Atua Sistemas
@Param			: N/A
@Return			: Nulo
@ --------------|-----------------------------------------------------------------------
@Author			: Evandro Mugnol
@Since			: Dez/2023
@version		: Protheus 12.1.2210 e posteriores
@Comments		: N/A
/*/
//--------------------------------------------------------------------------------------
User Function ATUA_003(_cCNPJ,_dDtIni,_dDtFim,_cID)

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
	cPostParams += 'veiculos'
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
Função que pega os dados do arquivo XML e grava a tabela temporária ZM3
@author     Evandro Mugnol
@since      Dez/2023
/*/
//-----------------------------------------------------------------------
Static Function _GetXML(cXML)

	Local oXML
	Local nQtBalance   := 0  // Quantidade de lançamentos
	Local aListBalance := {}
	Local nX		   := 1
	Local aListAppor   := {}
	Local cPathBalance := "/veiculos" 
	Local cCaminho	   := "/cavalo"

	Default cXML := ""

	// Deleta dados da tabela ZM3 para nova carga de dados
	_cQuery := "DELETE FROM " + RetSqlName("ZM3")
	_cQuery += " WHERE ZM3_FILIAL = '" + FWxFilial("ZM3") + "'" 

	If TcSQLExec(_cQuery) < 0	
		MsgStop(TcSqlError())
	Endif

	oXML := TXMLManager():New()

	If oXML:Parse( cXML )
		// Quantidade de filhos do nó "veiculos"
		nQtBalance := oXml:XPAthChildCount(cPathBalance)
		
		// Retorna um array com os nós filhos do nó apontado pela expressão cPathBalance 
		aListBalance := oXml:XPathGetChildArray(cPathBalance)

		While nX <= nQtBalance
			cLibera := oXml:XPathGetChildArray(aListBalance[nX,2])[5][3]	// Liberado
			cDtHora := oXml:XPathGetChildArray(aListBalance[nX,2])[6][3]	// Última atualização

			aListAppor := oXml:XPathGetChildArray(aListBalance[nX,2] + cCaminho)

			// Cria registros na tabela intermediária de importação dos veículos importados da Atua
			DbSelectArea("ZM3")
			Reclock("ZM3",.T.)
			ZM3->ZM3_FILIAL := FWxFilial("ZM3")
			ZM3->ZM3_IDATUA := PadL(AllTrim(aListAppor[1,3]), TamSX3("ZM3_IDATUA")[01], "0")
			ZM3->ZM3_PLACA  := aListAppor[2,3]
			ZM3->ZM3_RENAVA := aListAppor[3,3]
			ZM3->ZM3_LIBERA := cLibera
			ZM3->ZM3_DTHORA := cDtHora
			MsUnlock()

			nX++
		EndDo	

		// Monta tela para processamento dos dados importados e posteriormente grava e/ou atualiza os veículos na tabela DA3
		_TelaVeic()
	Else
		MsgAlert("Error: " + oXML:Error())
		Return
	EndIf

Return


//-----------------------------------------------------------------------
/*/{Protheus.doc} _TelaVeic
Função que monta tela para processamento dos dados no Protheus
@author     Evandro Mugnol
@since      Dez/2023
/*/
//-----------------------------------------------------------------------
Static Function _TelaVeic()

	Local aCpos	   := {}
	Local nX	   := 0
	Local aArea	   := FWGetArea()
	Local aAreaSX3 := SX3->(FWGetArea())
	Local aSize    := {}
	Local aInfo    := {}

	Private aHead1   := {}
	Private aCols1   := {}
	Private aPosObj  := {}
	Private aObjects := {}
	Private lChkSel  := .F.
	Private oDlgVeic
	Private oGetDad1

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
	// Neste caso serão 4 colunas incluindo o campo que possui caixa de seleção ou checkBox e legendas
	aAdd(aCpos,"ZM3_PLACA" )
	aAdd(aCpos,"ZM3_RENAVA")
	aAdd(aCpos,"ZM3_IDATUA")
	aAdd(aCpos,"ZM3_DTHORA")

	aAdd(aHead1, { ''	 	 , 'CHECKBOL', '@BMP', 2, 0,     ,, 'C',, 'V',,,'', 'V' } )
	aAdd(aHead1, { 'Atua'	 , "XX_COR"  , '@BMP', 2, 0,".F.",, "C",, "V",,,'', 'V' } )
	aAdd(aHead1, { 'Protheus', "XX_COR"  , '@BMP', 2, 0,".F.",, "C",, "V",,,'', 'V' } )

	SX3->(dbSetOrder(2))
	For nX := 1 to Len(aCpos)
		If SX3->( MsSeek(aCpos[nX]) )
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

	FWRestArea( aAreaSX3 )
	FWRestArea( aArea )

	DEFINE MSDIALOG oDlgVeic TITLE "Veículos Lidos da Importação da Atua Sistemas" From aSize[7],0 to aSize[6],aSize[5] of oMainWnd PIXEL
	
	_oPanel := TPanel():New(aPosObj[1,1], aPosObj[1,2], , oDlgVeic ,, .F., ,, , aPosObj[1,4], aPosObj[1,3], .T., .F.)

	@ 010, 550 BUTTON "Processar" SIZE 060, 015 ACTION (_Processa()) OF _oPanel PIXEL

	// Objeto oChk de checkbox e variável lChkSel. Quando clicado, executa o método "Seleciona" e possibilita
	// que o usuário selecione todas as linhas ao mesmo tempo.
	@ 025, 003 CHECKBOX oChk VAR lChkSel PROMPT "Marca/Desmarca Todos" SIZE 070, 007 on CLICK Seleciona(lChkSel) OF _oPanel PIXEL

	aObjSay := tSay():New(000, 090, {|| OemToAnsi('Legenda Atua')} 						, _oPanel,,oFontLeg,,,, .T., RGB(031, 073, 125), , 100, 020)

	aObjBmp := TBitmap():New(011, 090, 068, 010, 'BR_VERDE'  							, , .T., _oPanel, {|| }, {|| }, .F., .F.,,, .F.,, .T.,, .F.)
	aObjSay := tSay():New(012, 100, {|| OemToAnsi('Veículo Normal')}  					, _oPanel,,,,,, .T., CLR_BLACK, CLR_WHITE, 100, 020)

	aObjBmp := TBitmap():New(019, 090, 068, 010, 'BR_LARANJA'  							, , .T., _oPanel, {|| }, {|| }, .F., .F.,,, .F.,, .T.,, .F.)
	aObjSay := tSay():New(020, 100, {|| OemToAnsi('Veículo Pendente')}  				, _oPanel,,,,,, .T., CLR_BLACK, CLR_WHITE, 100, 020)

	aObjBmp := TBitmap():New(027, 090, 068, 010, 'BR_CANCEL'  							, , .T., _oPanel, {|| }, {|| }, .F., .F.,,, .F.,, .T.,, .F.)
	aObjSay := tSay():New(028, 100, {|| OemToAnsi('Veículo Cancelado')} 				, _oPanel,,,,,, .T., CLR_BLACK, CLR_WHITE, 100, 020)

	aObjSay := tSay():New(000, 240, {|| OemToAnsi('Legenda Protheus')}  				, _oPanel,,oFontLeg,,,, .T., RGB(031, 073, 125), , 100, 020)

	aObjBmp := TBitmap():New(011, 240, 068, 010, 'BR_VERDE'  							, , .T., _oPanel, {|| }, {|| }, .F., .F.,,, .F.,, .T.,, .F.)
	aObjSay := tSay():New(012, 250, {|| OemToAnsi('Veículo Já Cadastrado')} 			, _oPanel,,,,,, .T., CLR_BLACK, CLR_WHITE, 100, 020)

	aObjBmp := TBitmap():New(019, 240, 068, 010, 'BR_VERMELHO'  						, , .T., _oPanel, {|| }, {|| }, .F., .F.,,, .F.,, .T.,, .F.)
	aObjSay := tSay():New(020, 250, {|| OemToAnsi('Veículo Não Cadastrado')}			, _oPanel,,,,,, .T., CLR_BLACK, CLR_WHITE, 100, 020)

	aObjBmp := TBitmap():New(027, 240, 068, 010, 'BR_PRETO'  						  	, , .T., _oPanel, {|| }, {|| }, .F., .F.,,, .F.,, .T.,, .F.)
	aObjSay := tSay():New(028, 250, {|| OemToAnsi('Veículo Já Cadastrado e Inativo')} 	, _oPanel,,,,,, .T., CLR_BLACK, CLR_WHITE, 100, 020)

	oGetDad1:= MsNewGetDados():New((aPosObj[2,1]),(aPosObj[2,2])+3, aPosObj[3,3], aPosObj[3,4]+8,GD_UPDATE,/*LinOk*/,/*[cTudoOk]*/,/*[cIniCpos]*/,{'CHECKBOL'},1,9999,/*[cCampoOk]*/,/*[cSuperApagar]*/,/*[cApagaOk]*/,oDlgVeic,aHead1,aCols1)

	// Antes de ativar a tela (oDlgVeic) busca todas informações para carregar o oGetDad1
	_BuscaZM3()

	oDlgVeic:lEscClose := .F.
  	ACTIVATE MSDIALOG oDlgVeic CENTERED ON INIT EnchoiceBar(oDlgVeic, {||oDlgVeic:End()}, { ||oDlgVeic:End()},,,,,.T.,.T., .T., .F.,.T.,)

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
	oDlgVeic:Refresh()

Return


//-----------------------------------------------------------------------
/*/{Protheus.doc} _BuscaZM3
Função que carrega todos registros da tabela intermediária ZM3 para tela
@author     Evandro Mugnol
@since      Dez/2023
/*/
//-----------------------------------------------------------------------
Static Function _BuscaZM3()

	Local oBmpAtua
	Local oBmpProt
	
	Private aCols1 := {}

	// Atualiza/Recarrega o oGetDad1 e o oDlgVeic antes de receber novos dados          
	_Refresh(aCols1)

	DbSelectArea("ZM3")
	DbSetOrder(1)
	DbGoTop()
	DbSeek(FWxFilial("ZM3"))
	While !Eof() .And. ZM3->ZM3_FILIAL == FWxFilial("ZM3")

		DO CASE
			CASE ZM3->ZM3_LIBERA == "0"		// Cancelado
				oBmpAtua := oBmpCancel
			CASE ZM3->ZM3_LIBERA == "1"		// Pendente
				oBmpAtua := oBmpLaranja
			CASE ZM3->ZM3_LIBERA == "2"		// Normal
				oBmpAtua := oBmpVerde
			OTHERWISE
				oBmpAtua := oBmpVerde
		ENDCASE

		DbSelectArea("DA3")
		DbSetOrder(3)
		DbSeek(FWxFilial("DA3") + ZM3->ZM3_PLACA)
		If Found()
			If DA3->DA3_ATIVO == "2"
				oBmpProt := oBmpInativo
			Else
				oBmpProt := oBmpVerde
			EndIf
		Else
			oBmpProt := oBmpVermelho
		EndIf

		DbSelectArea("ZM3")
		If ZM3->ZM3_LIBERA == "0"
			aAdd(aCols1, {'LBOK', oBmpAtua, oBmpProt, ZM3->ZM3_PLACA, ZM3->ZM3_RENAVA, ZM3->ZM3_IDATUA, ZM3->ZM3_DTHORA, .F.})
		Else
			aAdd(aCols1, {'LBNO', oBmpAtua, oBmpProt, ZM3->ZM3_PLACA, ZM3->ZM3_RENAVA, ZM3->ZM3_IDATUA, ZM3->ZM3_DTHORA, .F.})
		EndIf

		DbSelectArea("ZM3")
		DbSkip()
	EndDo

	// Atualiza o oGetDad1 com o novo array
	_Refresh(aCols1)

Return


//-----------------------------------------------------------------------
/*/{Protheus.doc} _Refresh
Função que refersh do oGetDad1
@author     Evandro Mugnol
@since      Dez/2023
/*/
//-----------------------------------------------------------------------
Static Function _Refresh(aDados)

	oGetDad1:oBrowse:Refresh()
	oDlgVeic:Refresh()

	oGetDad1:= MsNewGetDados():New((aPosObj[2,1]),(aPosObj[2,2])+3, aPosObj[3,3], aPosObj[3,4]+8,GD_UPDATE,/*LinOk*/,/*[cTudoOk]*/,/*[cIniCpos]*/,{'CHECKBOL'},1,9999,/*[cCampoOk]*/,/*[cSuperApagar]*/,/*[cApagaOk]*/,oDlgVeic,aHead1,aCols1)
	oGetDad1:oBrowse:bLDblClick := {|| oGetDad1:EditCell(), oGetDad1:aCols[oGetDad1:nAt,1] := iif(oGetDad1:aCols[oGetDad1:nAt,1] == 'LBOK','LBNO','LBOK')}

Return


//-----------------------------------------------------------------------
/*/{Protheus.doc} _Processa
Função que efetua do processamento dos registros marcados na tela
@author     Evandro Mugnol
@since      Dez/2023
/*/
//-----------------------------------------------------------------------
Static Function _Processa()

	Local i
	
	For i := 1 To Len(oGetDad1:aCols)
		If oGetDad1:aCols[i,1] == 'LBOK'
			
			DbSelectArea("DA3")
			DbSetOrder(3)
			DbSeek(FWxFilial("DA3") + oGetDad1:aCols[i,4])
			If Found()
				// Verifica na ZM3 o código de liberação que veio do Atua
				DbSelectArea("ZM3")
				DbGotop()
				DbSetOrder(1)
				DbSeek(FWxFilial("ZM3") + DA3->DA3_PLACA)
				If Found()
					_cLibera := ZM3->ZM3_LIBERA
				Else
					_cLibera := "2"
				EndIf
				
				// Caso o código de liberação do Atua é zero (0=Cancelado), invativa veículo no Protheus 
				If _cLibera == "0"
					Reclock("DA3",.F.)
					DA3->DA3_ATIVO  := "2" 
					MsUnlock()
				Else
					Reclock("DA3",.F.)
					DA3->DA3_RENAVA := oGetDad1:aCols[i,5]
					DA3->DA3_ATIVO  := "1" 
					DA3->DA3_DATSTS := STOD(Substr(oGetDad1:aCols[i,7],1,4) + Substr(oGetDad1:aCols[i,7],6,2) + Substr(oGetDad1:aCols[i,7],9,2))
					DA3->DA3_HORSTS := Substr(oGetDad1:aCols[i,7],12,2) + Substr(oGetDad1:aCols[i,7],15,2)
					MsUnlock()
				EndIf
			Else
				Reclock("DA3",.T.)
				DA3->DA3_FILIAL := FWxFilial("DA3") 
				DA3->DA3_COD    := oGetDad1:aCols[i,4]
				DA3->DA3_PLACA  := oGetDad1:aCols[i,4]
				DA3->DA3_RENAVA := oGetDad1:aCols[i,5]
				DA3->DA3_ATIVO  := "1" 
				DA3->DA3_FILATU := FWxFilial("DA3") 
				DA3->DA3_FROVEI := "1" 
				DA3->DA3_CODFOR := "000006"
				DA3->DA3_LOJFOR := "01"
				DA3->DA3_VEIRAS := "2" 
				DA3->DA3_STATUS := "1"
				DA3->DA3_GSTDMD := "1"
				DA3->DA3_DATSTS := STOD(Substr(oGetDad1:aCols[i,7],1,4) + Substr(oGetDad1:aCols[i,7],6,2) + Substr(oGetDad1:aCols[i,7],9,2))
				DA3->DA3_HORSTS := Substr(oGetDad1:aCols[i,7],12,2) + Substr(oGetDad1:aCols[i,7],15,2)
				DA3->DA3_INTEGR := "2" 
				MsUnlock()
			EndIf
		EndIf
	Next i

	oDlgVeic:End()

Return
