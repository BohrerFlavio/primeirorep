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
/*/{Protheus.doc} ATUA_001
@Type			: Função de Usuário
@Sample			: U_ATUA_001()
@Description	: Rotina de REST para buscar POST do cadastro de Motoristas da Atua Sistemas
@Param			: N/A
@Return			: Nulo
@ --------------|-----------------------------------------------------------------------
@Author			: Evandro Mugnol
@Since			: Dez/2023
@version		: Protheus 12.1.2210 e posteriores
@Comments		: N/A
/*/
//--------------------------------------------------------------------------------------
User Function ATUA_001(_cCNPJ,_dDtIni,_dDtFim,_cID)

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
	aAdd(aHeader, 'Content-Length: 531')
	aAdd(aHeader, 'Content-Type: multipart/form-data; boundary=' + cBoundary)

	oRest := FWRest():New(cUrl)

	oRest:setPath(cPath)

	cPostParams += CRLF
	cPostParams += '--' + cBoundary
	cPostParams += CRLF
	cPostParams += 'Content-Disposition: form-data; name="conjunto_de_dados"'
	cPostParams += CRLF
	cPostParams += CRLF
	cPostParams += 'motoristas'
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
Função que pega os dados do arquivo XML e grava a tabela temporária ZM1
@author     Evandro Mugnol
@since      Dez/2023
/*/
//-----------------------------------------------------------------------
Static Function _GetXML(cXML)

	Local oXML
	Local nQtBalance   := 0  // Quantidade de lançamentos
	Local aListBalance := {}
	Local nX		   := 1
	Local cPathBalance := "/motoristas" 
	Local aItensBal    := {}

	Default cXML := ""

	// Deleta dados da tabela ZM1 para nova carga de dados
	_cQuery := "DELETE FROM " + RetSqlName("ZM1")
	_cQuery += " WHERE ZM1_FILIAL = '" + FWxFilial("ZM1") + "'" 

	If TcSQLExec(_cQuery) < 0	
		MsgStop(TcSqlError())
	Endif

	oXML := TXMLManager():New()

	If oXML:Parse( cXML )
		// Quantidade de filhos do nó "motoristas"
		nQtBalance := oXml:XPAthChildCount(cPathBalance)
		
		// Retorna um array com os nós filhos do nó apontado pela expressão cPathBalance 
		aListBalance := oXml:XPathGetChildArray(cPathBalance)

		While nX <= nQtBalance

			aItensBal := oXml:XPathGetChildArray(aListBalance[nX,2])  // Gera Array com os filhos.

			// Id
			nPos := aScan(aItensBal,{|x| AllTrim( x[1] ) == 'id' } ) 
			If nPos > 0
				cId := aItensBal[nPos,3]
			Else
				cId := ""
			EndIf

			// Nome
			nPos := aScan(aItensBal,{|x| AllTrim( x[1] ) == 'nome' } ) 
			If nPos > 0
				cNome := aItensBal[nPos,3]
			Else
				cNome := ""
			EndIf

			// CPF
			nPos := aScan(aItensBal,{|x| AllTrim( x[1] ) == 'cpf' } ) 
			If nPos > 0
				cCPF := aItensBal[nPos,3]
			Else
				cCPF := ""
			EndIf

			// Celular
			nPos := aScan(aItensBal,{|x| AllTrim( x[1] ) == 'celular' } ) 
			If nPos > 0
				cCelular := aItensBal[nPos,3]
			Else
				cCelular := ""
			EndIf

			// CNH
			nPos := aScan(aItensBal,{|x| AllTrim( x[1] ) == 'cnh' } ) 
			If nPos > 0
				cCNH := aItensBal[nPos,3]
			Else
				cCNH := ""
			EndIf

			// Liberado
			nPos := aScan(aItensBal,{|x| AllTrim( x[1] ) == 'liberado' } ) 
			If nPos > 0
				cLibera := aItensBal[nPos,3]
			Else
				cLibera := ""
			EndIf

			// Última Atualização
			nPos := aScan(aItensBal,{|x| AllTrim( x[1] ) == 'dtHora' } ) 
			If nPos > 0
				cDtHora := aItensBal[nPos,3]
			Else
				cDtHora := ""
			EndIf

			// Cria registros na tabela intermediária de importação dos motoristas importados da Atua
			DbSelectArea("ZM1")
			Reclock("ZM1",.T.)
			ZM1->ZM1_FILIAL := FWxFilial("ZM1")
			ZM1->ZM1_IDATUA := PadL(AllTrim(cId), TamSX3("ZM1_IDATUA")[01], "0")
			ZM1->ZM1_NOME   := cNome
			ZM1->ZM1_CGC    := cCPF
			ZM1->ZM1_TEL    := cCelular
			ZM1->ZM1_NUMCNH := cCNH
			ZM1->ZM1_LIBERA := cLibera
			ZM1->ZM1_DTHORA := cDtHora
			MsUnlock()

			nX++
		EndDo	

		// Monta tela para processamento dos dados importados e posteriormente grava e/ou atualiza os motoristas na tabela DA4
		_TelaMot()
	Else
		MsgAlert("Error: " + oXML:Error())
		Return
	EndIf

Return


//-----------------------------------------------------------------------
/*/{Protheus.doc} _TelaMot
Função que monta tela para processamento dos dados no Protheus
@author     Evandro Mugnol
@since      Dez/2023
/*/
//-----------------------------------------------------------------------
Static Function _TelaMot()

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
	Private oDlgMot
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
	// Neste caso serão 6 colunas incluindo o campo que possui caixa de seleção ou checkBox e legendas
	aAdd(aCpos,"ZM1_NOME" )
	aAdd(aCpos,"ZM1_CGC")
	aAdd(aCpos,"ZM1_TEL")
	aAdd(aCpos,"ZM1_NUMCNH")
	aAdd(aCpos,"ZM1_IDATUA")
	aAdd(aCpos,"ZM1_DTHORA")

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

	DEFINE MSDIALOG oDlgMot TITLE "Motoristas Lidos da Importação da Atua Sistemas" From aSize[7],0 to aSize[6],aSize[5] of oMainWnd PIXEL
	
	_oPanel := TPanel():New(aPosObj[1,1], aPosObj[1,2], , oDlgMot ,, .F., ,, , aPosObj[1,4], aPosObj[1,3], .T., .F.)

	@ 010, 550 BUTTON "Processar" SIZE 060, 015 ACTION (_Processa()) OF _oPanel PIXEL

	// Objeto oChk de checkbox e variável lChkSel. Quando clicado, executa o método "Seleciona" e possibilita
	// que o usuário selecione todas as linhas ao mesmo tempo.
	@ 025, 003 CHECKBOX oChk VAR lChkSel PROMPT "Marca/Desmarca Todos" SIZE 070, 007 on CLICK Seleciona(lChkSel) OF _oPanel PIXEL

	aObjSay := tSay():New(000, 090, {|| OemToAnsi('Legenda Atua')}  					, _oPanel,,oFontLeg,,,, .T., RGB(031, 073, 125), , 100, 020)

	aObjBmp := TBitmap():New(011, 090, 068, 010, 'BR_VERDE'  			  				, , .T., _oPanel, {|| }, {|| }, .F., .F.,,, .F.,, .T.,, .F.)
	aObjSay := tSay():New(012, 100, {|| OemToAnsi('Motorista Normal')}    				, _oPanel,,,,,, .T., CLR_BLACK, CLR_WHITE, 100, 020)

	aObjBmp := TBitmap():New(019, 090, 068, 010, 'BR_LARANJA'  			  				, , .T., _oPanel, {|| }, {|| }, .F., .F.,,, .F.,, .T.,, .F.)
	aObjSay := tSay():New(020, 100, {|| OemToAnsi('Motorista Pendente')}  				, _oPanel,,,,,, .T., CLR_BLACK, CLR_WHITE, 100, 020)

	aObjBmp := TBitmap():New(027, 090, 068, 010, 'BR_CANCEL'  			  				, , .T., _oPanel, {|| }, {|| }, .F., .F.,,, .F.,, .T.,, .F.)
	aObjSay := tSay():New(028, 100, {|| OemToAnsi('Motorista Cancelado')} 				, _oPanel,,,,,, .T., CLR_BLACK, CLR_WHITE, 100, 020)

	aObjSay := tSay():New(000, 240, {|| OemToAnsi('Legenda Protheus')}  				, _oPanel,,oFontLeg,,,, .T., RGB(031, 073, 125), , 100, 020)

	aObjBmp := TBitmap():New(011, 240, 068, 010, 'BR_VERDE'  				  			, , .T., _oPanel, {|| }, {|| }, .F., .F.,,, .F.,, .T.,, .F.)
	aObjSay := tSay():New(012, 250, {|| OemToAnsi('Motorista Já Cadastrado')} 			, _oPanel,,,,,, .T., CLR_BLACK, CLR_WHITE, 100, 020)

	aObjBmp := TBitmap():New(019, 240, 068, 010, 'BR_VERMELHO'  			  			, , .T., _oPanel, {|| }, {|| }, .F., .F.,,, .F.,, .T.,, .F.)
	aObjSay := tSay():New(020, 250, {|| OemToAnsi('Motorista Não Cadastrado')}			, _oPanel,,,,,, .T., CLR_BLACK, CLR_WHITE, 100, 020)

	aObjBmp := TBitmap():New(027, 240, 068, 010, 'BR_PRETO'  						    , , .T., _oPanel, {|| }, {|| }, .F., .F.,,, .F.,, .T.,, .F.)
	aObjSay := tSay():New(028, 250, {|| OemToAnsi('Motorista Já Cadastrado e Inativo')} , _oPanel,,,,,, .T., CLR_BLACK, CLR_WHITE, 100, 020)

	oGetDad1:= MsNewGetDados():New((aPosObj[2,1]),(aPosObj[2,2])+3, aPosObj[3,3], aPosObj[3,4]+8,GD_UPDATE,/*LinOk*/,/*[cTudoOk]*/,/*[cIniCpos]*/,{'CHECKBOL'},1,9999,/*[cCampoOk]*/,/*[cSuperApagar]*/,/*[cApagaOk]*/,oDlgMot,aHead1,aCols1)

	// Antes de ativar a tela (oDlgMot) busca todas informações para carregar o oGetDad1
	_BuscaZM1()

	oDlgMot:lEscClose := .F.
  	ACTIVATE MSDIALOG oDlgMot CENTERED ON INIT EnchoiceBar(oDlgMot, {||oDlgMot:End()}, { ||oDlgMot:End()},,,,,.T.,.T., .T., .F.,.T.,)

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
	oDlgMot:Refresh()

Return


//-----------------------------------------------------------------------
/*/{Protheus.doc} _BuscaZM1
Função que carrega todos registros da tabela intermediária ZM1 para tela
@author     Evandro Mugnol
@since      Dez/2023
/*/
//-----------------------------------------------------------------------
Static Function _BuscaZM1()

	Local oBmpAtua
	Local oBmpProt
	
	Private aCols1 := {}

	// Atualiza/Recarrega o oGetDad1 e o oDlgMot antes de receber novos dados          
	_Refresh(aCols1)

	DbSelectArea("ZM1")
	DbSetOrder(1)
	DbGoTop()
	DbSeek(FWxFilial("ZM1"))
	While !Eof() .And. ZM1->ZM1_FILIAL == FWxFilial("ZM1")

		DO CASE
			CASE ZM1->ZM1_LIBERA == "0"		// Cancelado
				oBmpAtua := oBmpCancel
			CASE ZM1->ZM1_LIBERA == "1"		// Pendente
				oBmpAtua := oBmpLaranja
			CASE ZM1->ZM1_LIBERA == "2"		// Normal
				oBmpAtua := oBmpVerde
			OTHERWISE
				oBmpAtua := oBmpVerde
		ENDCASE

		DbSelectArea("DA4")
		DbSetOrder(3)
		DbSeek(FWxFilial("DA4") + ZM1->ZM1_CGC)
		If Found()
			If DA4->DA4_BLQMOT == "1"
				oBmpProt := oBmpInativo
			Else
				oBmpProt := oBmpVerde
			EndIf
		Else
			oBmpProt := oBmpVermelho
		EndIf

		DbSelectArea("ZM1")
		If ZM1->ZM1_LIBERA == "0"
			aAdd(aCols1, {'LBOK', oBmpAtua, oBmpProt, ZM1->ZM1_NOME, ZM1->ZM1_CGC, ZM1->ZM1_TEL, ZM1->ZM1_NUMCNH, ZM1->ZM1_IDATUA, ZM1->ZM1_DTHORA, .F.})
		Else
			aAdd(aCols1, {'LBNO', oBmpAtua, oBmpProt, ZM1->ZM1_NOME, ZM1->ZM1_CGC, ZM1->ZM1_TEL, ZM1->ZM1_NUMCNH, ZM1->ZM1_IDATUA, ZM1->ZM1_DTHORA, .F.})
		EndIf

		DbSelectArea("ZM1")
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
	oDlgMot:Refresh()

	oGetDad1:= MsNewGetDados():New((aPosObj[2,1]),(aPosObj[2,2])+3, aPosObj[3,3], aPosObj[3,4]+8,GD_UPDATE,/*LinOk*/,/*[cTudoOk]*/,/*[cIniCpos]*/,{'CHECKBOL'},1,9999,/*[cCampoOk]*/,/*[cSuperApagar]*/,/*[cApagaOk]*/,oDlgMot,aHead1,aCols1)
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
			
			DbSelectArea("DA4")
			DbSetOrder(3)
			DbSeek(FWxFilial("DA4") + oGetDad1:aCols[i,5])
			If Found()
				// Verifica na ZM1 o código de liberação que veio do Atua
				DbSelectArea("ZM1")
				DbGotop()
				DbSetOrder(1)
				DbSeek(FWxFilial("ZM1") + DA4->DA4_CGC)
				If Found()
					_cLibera := ZM1->ZM1_LIBERA
				Else
					_cLibera := "2"
				EndIf
				
				// Caso o código de liberação do Atua é zero (0=Cancelado), invativa motorista no Protheus 
				If _cLibera == "0"
					Reclock("DA4",.F.)
					DA4->DA4_BLQMOT := "2" 
					MsUnlock()
				Else
					Reclock("DA4",.F.)
					DA4->DA4_NOME   := oGetDad1:aCols[i,4]
					DA4->DA4_TEL    := oGetDad1:aCols[i,6]
					DA4->DA4_NUMCNH := oGetDad1:aCols[i,7] 
					MsUnlock()
				EndIf
			Else
				// Pegando a próxima sequência
				_cCodMot := GetSXENum("DA4", "DA4_COD")

				Reclock("DA4",.T.)
				DA4->DA4_FILIAL := FWxFilial("DA4") 
				DA4->DA4_COD    := _cCodMot
				DA4->DA4_NOME   := oGetDad1:aCols[i,4]
				DA4->DA4_TIPMOT := "1"
				DA4->DA4_CGC    := oGetDad1:aCols[i,5]
				DA4->DA4_TEL    := oGetDad1:aCols[i,6]
				DA4->DA4_NUMCNH := oGetDad1:aCols[i,7] 
				DA4->DA4_CARPER := "2"
				DA4->DA4_BLQMOT := "2" 
				DA4->DA4_COMISS := "2"
				DA4->DA4_FILATU := FWxFilial("DA4") 
				DA4->DA4_STATUS := "1"
				MsUnlock()
				ConfirmSX8()
			EndIf
		EndIf
	Next i

	oDlgMot:End()

Return
