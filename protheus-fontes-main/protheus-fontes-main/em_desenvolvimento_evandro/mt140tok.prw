#INCLUDE "PROTHEUS.CH"
#INCLUDE "TOTVS.CH"

/*/{Protheus.doc} MT140TOK
Ponto Entrada executado após verificar se existem itens a serem gravados e tem como objetivo validar todos os itens da pré-nota de entrada.
@author     Evandro
@since      04/06/2020
@param		PARAMIXB[1] - [Variável lógica -> .T. dados válidos ou .F. dados inválidos]
@return     lRet(lógico) - .T. dados válidos ou .F. dados inválidos
@obs        N/A
/*/

User Function MT140TOK()

	Local lRet 	   := PARAMIXB[1]
	Local _bOk	   := .T.
	Local _cTipoNF := cTipo			// Tipo da Nota Fiscal

	Private oTela, oCancel, oConfir
	Private _cTitulo    := OemToAnsi("Número do Recibo de Autorização de Devolução")
	Private _oFtArial24 := TFont():New ("Arial"      , 10, 24)
	Private _oFtArial30 := TFont():New ("Arial"      , 10, 34)
	Private _oFCourier  := TFont():New ("Courier New",   , 24,,.T.)
	Private _cNumRec  	:= SF1->F1_NUMREC

	// Quando for empresa 01 e pré nota de devolução, obriga a informar o número do recibo de autorização de devolução
	If cEmpAnt == "01" .And. _cTipoNF == "D"

		DEFINE MSDIALOG oTela TITLE _cTitulo FROM C(0), C(0) TO C(210), C(370) PIXEL STYLE DS_MODALFRAME 	// Dialog sem o X para fechar
    	oTela:lEscClose := .F. 		// Desabilita fechar a janela ao pressinar ESC
	
		@ C(005), C(005) SAY "Deverá ser informado abaixo o número do recido de"	Size C(300), C(12) FONT _oFtArial24 COLOR CLR_BLUE 	PIXEL OF oTela
		@ C(015), C(005) SAY "autorização de devolução para que esta pré nota"		Size C(300), C(12) FONT _oFtArial24 COLOR CLR_BLUE 	PIXEL OF oTela
		@ C(025), C(005) SAY "de entrada possa ser finalizada."						Size C(300), C(12) FONT _oFtArial24 COLOR CLR_BLUE 	PIXEL OF oTela
		@ C(040), C(005) SAY ">>>>>>>>>>  Informação Obrigatória  <<<<<<<<<<"		Size C(300), C(12) FONT _oFtArial24 COLOR CLR_HRED 	PIXEL OF oTela

		@ C(070), C(010) SAY "Número Recibo: "                                 	  	Size C(100), C(10) FONT _oFtArial24 COLOR CLR_HBLUE PIXEL OF oTela
		@ C(070), C(070) MSGET _cNumRec VALID _VldRec() F3 "ZH2" 		           	Size C(060), C(10) FONT _oFCourier  COLOR CLR_HBLUE	PIXEL OF oTela

		DEFINE SBUTTON FROM C(090), C(100) TYPE 1 OBJECT oConfir ENABLE OF oTela ACTION (_bOk := .T., lRet := _Process())
		DEFINE SBUTTON FROM C(090), C(140) TYPE 2 OBJECT oCancel ENABLE OF oTela ACTION (_bOk := .F., oTela:End())

		ACTIVATE MSDIALOG oTela CENTERED

	EndIf

	If _bOk
		If cEmpAnt <> "07"
			If FWAlertNoYes('Gerar relatório de divergências?', 'Confirmação')
				_cPedido := GDFieldGet( "D1_PEDIDO"  , 1)
				Pergunte("GJF16", .F.) //Carrega as MV_PAR's sem exibir a tela
				//Enviar o 4º parâmetro como .T. para atualizar no SX1/Profile
				SetMVValue("GJF16", "MV_PAR01", _cPedido, .T.) //Atualiza o valor da pergunta selecionada para o valor do terceiro parâmetro
				SetMVValue("GJF16", "MV_PAR02", _cPedido, .T.)
				SetMVValue("GJF16", "MV_PAR03", (dDEmissao-365), .T.)
				SetMVValue("GJF16", "MV_PAR04", Date(), .T.)
				U_GJF16()
			EndIf
		EndIf
	Else
		lRet := _bOk
	EndIf

Return lRet


//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³Efetua Consistencia no Número do Recibo                        ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
Static Function _VldRec()

	Local nX
	Local _lRetVld := .T.

	DbSelectArea("ZH2")
	DbSetOrder(1)
	If DbSeek(FWxFilial("ZH2") + _cNumRec)
		If ZH2->ZH2_TIPRET == "1" .Or. ZH2->ZH2_TIPRET == "2"		// ZH2->ZH2_TIPRET <> "3"
			If ZH2->ZH2_CODCLI + ZH2->ZH2_LOJCLI + ZH2->ZH2_NFORI + ZH2->ZH2_SERORI <> CA100FOR + CLOJA + GdFieldGet("D1_NFORI") + GdFieldGet("D1_SERIORI")
				FWAlertError("Selecione um recibo cuja NF Original seja igual da pré nota de devolução.", "NF Original da Pré Nota Difere da NF Original do Recibo")
				_lRetVld := .F.
			Else
				For nX := 1 To Len(aCols)
					If !GdDeleted(nX)
						GdFieldPut('D1_NUMREC', _cNumRec, nX)
					EndIf
				Next nX
			Endif
		Else
			//DbSelectArea("ZH5")
			//DbSetOrder(1)
			//If !DbSeek(FWxFilial("ZH5") + _cNumRec)
			//	FWAlertError("Cadastre o controle de recebimento e inspeção de devoluções para posteriormente gerar a pré nota de devolução.", "Não é permitido gerar pré nota de devolução sem controle de recebimento e inspeção de devoluções cadastrado.")
			//	_lRetVld := .F.
			//Else
				For nX := 1 To Len(aCols)
					If !GdDeleted(nX)
						GdFieldPut('D1_NUMREC', _cNumRec, nX)
					EndIf
				Next nX
			//EndIf
		EndIf
	Else
		FWAlertError("Informe um número de recibo válido.", "Número do Recibo de Autorização de Devolução Inválido ou em Branco")
		_lRetVld := .F.
	Endif

Return(_lRetVld)


//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³Efetua Processamento dos Dados Informados                      ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
Static Function _Process()

	_lRetProc := .T.
	
	If Empty(_cNumRec)
		FWAlertError("Informe um número de recibo.", "É obrigatório informar um número de recibo")
		_lRetProc := .F.
	EndIf

	oTela:End()

Return(_lRetProc)
