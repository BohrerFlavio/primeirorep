#INCLUDE "TOTVS.CH"
#INCLUDE "Rwmake.ch"
#INCLUDE "Protheus.ch"
#INCLUDE "Topconn.ch"
#INCLUDE "tbiconn.ch"
#INCLUDE "colors.ch"
#INCLUDE "vkey.ch"

//--------------------------------------------------------------------------------------
/*/{Protheus.doc} DTI118
Rotina efetua importação dos preços de venda (DA1) conforme arquivo Excel (.CSV)
@author     Mauro
@since      Mar/2021
@return     Nil
@obs        N/A
/*/
//--------------------------------------------------------------------------------------
User Function DTI118()

	Private _cArq      :=  Space(500)
	Private _nNumReg   := 0
	Private _nNumLendo := 0
	Private _nI        := 0
	Private _nJ        := 0
	Private _cLinha    := ""
	Private _lPrim     := .F.
	Private _lProcArq  := .T.
	Private _aCampos   := {}
	Private _aDados    := {}
	Private _cCampo    := ""
	Private _cDlgTab   := "DA1"
	Private _cNL       := CHR(13) + CHR(10)
	Private _oDlgArq
	Private _oDlgTab
	Private  nStatus   := 0
	Private aItens	   := {}
	Private aTabs	   := {}
	Private cExcTabP   := AllTrim(GetMV('SI_EXCTABP'))

	// Inicio da tela de importacao
	DEFINE MSDIALOG _oDlg FROM 001,001 TO 140,450 TITLE "Importação de Preços de Venda DA1" PIXEL

	@ 001,001 TO 069,226 LABEL "" OF _oDlg PIXEL

	@ 025,010 SAY "Arquivo:"			SIZE 120, 7 PIXEL OF _oDlg
	@ 024,035 MSGET _oDlgArq VAR _cArq	SIZE 165, 7 WHEN .T. PIXEL OF _oDlg
	@ 027,200 BUTTON "..."				SIZE 014, 7 PIXEL OF _oDlg Action (_cArq := cGetFile("*.CSV","Selecione o Arquivo a ser importado...",1,"C:\",.T.,16,.F.))

	DEFINE SBUTTON _oBtn1 FROM 040,035 	TYPE 1 ACTION (Processa({ || _PREPARIMP()}, "Importando dados para a tabela " + _cDlgTab + "...", "por favor, aguarde.", .F.)) ENABLE OF _oDlg
	_oBtn1:cCaption := "Importar"
	_oBtn1:cToolTip := "Importar dados do arquivo para atualizar Preços de Venda"

	DEFINE SBUTTON _oBtn2 FROM 040,065 TYPE 2 ACTION (_oDlg:End()) ENABLE OF _oDlg
	_oBtn2:cToolTip := "Sair da Rotina"

	ACTIVATE MSDIALOG _oDlg CENTERED

Return


//-------------------------------------------------------------------
/*/{Protheus.doc} _PREPARIMP
Função que prepara ambiente para a importacao dos dados da planilha
@author     Mauro
@since      Mar/2021
@param      N/A
@return     Nil
/*/
//-------------------------------------------------------------------
Static Function _PREPARIMP()

	// Importa os dados do arquivo para um vetor
	Processa({ || _ARQ_VET()}, "Efetuando Carga de Dados. Por Favor, aguarde.", "", .F.)

	If _lProcArq
		_LOG("---------------------- Data de Importação " + DTOC(Date()) + " " + TIME() + " Feito por: " + cUserName + " No " + GetComputerName() + " ----------------------")
		Processa({ || _IMPORTA()}, "Importando dados. Por Favor, aguarde.", "", .F.)
		MsgInfo("Importação Concluída com Sucesso!" + _cNL + "Verifique a Situação da Importação no Arquivo de LOG em C:\Temp\Log_Alteracao_Precos_de_Venda.LOG")
	Endif

	_aDados  := {}
	_cArq    := Space(500)

Return


//-------------------------------------------------------------------
/*/{Protheus.doc} _ARQ_VET
Função que importa os dados do arquivo para um vetor.
O arquivo precisa ter o formato:
- Col 1: Cod. Produto (Tam. 6)
- Col 2: Cod. Tab (Tam. 3)
- Col 3: Preço Venda (@99.99)
@author     Mauro
@since      Mar/2021
@param      N/A
@return     Nil
/*/
//-------------------------------------------------------------------
Static Function _ARQ_VET()

	// Verifica se o arquivo existe
	If !File(_cArq)
		MsgStop("O arquivo '" + _cArq + "' não foi encontrado. A importação será abortada.", "[" + FunName() + "] - Atenção!")
		_aDados := {}
		_lProcArq  := .F.
		Return
	EndIf

	FT_FUSE(_cArq) 				// Seleciona o arquivo para usar
	ProcRegua(FT_FLASTREC()) 	// Seta a regua para o numero de registros encontrados
	_nNumReg := FT_FLASTREC() 	// Seta o _nNumReg para o numero de registros encontrados, para usar no IncProc
	FT_FGOTOP() 				// Posiciona o arquivo no primeiro registro

	_nNumLendo := 0
	While !FT_FEOF()

		_nNumLendo++

		IncProc("Lendo registro " + cValToChar(_nNumLendo) + " de " + cValToChar(_nNumReg) + "...")

		_cLinha := FT_FREADLN() 	// Joga a linha do arquivo para a variavel

		If _lPrim 	// Se for o primeiro registro entao os dados contem os nomes dos campos que serao inseridos
			_aCampos := Separa(_cLinha, ";", .T.)
			_lPrim := .F.
		Else
			aAdd(_aDados, Separa(_cLinha, ";", .T.))
		EndIf

		FT_FSKIP()
	EndDo

	FT_FUSE() 					// Fecha o arquivo que estava em uso

Return


//-------------------------------------------------------------------
/*/{Protheus.doc} _IMPORTA
Função que importa os dados do vetor para a tabela
@author     Mauro
@since      Mar/2021
@return     Nil
/*/
//-------------------------------------------------------------------
Static Function _IMPORTA()

	Local nPos  	:= 0
	Local _nPos  	:= 0
	Local _aErr     := {}

	Private _oTela, _oConfir, _bOk
	Private _cTitulo    := OemToAnsi("Tabela de Custos de Produtos")
	Private _cTabCus    := Space(04)
	Private _oFtArial24 := TFont():New ("Arial"      , 10, 24)
	Private _oFtArial30 := TFont():New ("Arial"      , 10, 34)
	Private _oFCourier  := TFont():New ("Courier New",   , 24,,.T.)

	_nNumReg := Len(_aDados)

	ProcRegua(_nNumReg)

	_nNumLendo := 0

	// Abre tela para informar tabela de custos de produtos
	_cTabCus := Space(04)

	DEFINE MSDIALOG _oTela TITLE _cTitulo FROM C(0), C(0) TO C(100), C(700) PIXEL
	@ C(003), C(035) SAY "Informe a Tabela de Custos de Produtos Para Geração de LOG DE ATUALIZAÇÃO"  Size C(300), C(12) FONT _oFtArial30 COLOR CLR_HRED PIXEL OF _oTela

	@ C(025), C(010) SAY "Tabela de Custo:" 		       								Size C(080), C(10) FONT _oFtArial24 COLOR CLR_GREEN PIXEL OF _oTela
	@ C(025), C(070) MSGET _cTabCus Picture "@!" When .T. Valid VldTab() F3 "Z05MVC"	Size C(045), C(08) FONT _oFCourier  COLOR CLR_GREEN	PIXEL OF _oTela

	DEFINE SBUTTON FROM C(033), C(290) TYPE 1 OBJECT _oConfir ENABLE OF _oTela	ACTION (_bOk := .T., _oTela:End())

	ACTIVATE MSDIALOG _oTela CENTERED

	_cNumAtu := GETSXENUM("Z08","Z08_NUMATU")
	ConfirmSX8()

	For nPos := 1 To Len(_aDados)

		_nNumLendo++
		_nCodPro := StrZero(Val(_aDados[nPos,1]), 6)
		_nTab    := StrZero(Val(_aDados[nPos,2]), 3)
		_nPrcVen := Val(StrTran(_aDados[nPos,3], ",", "."))

		IncProc("Atualizando registro " + cValToChar(_nNumLendo) + " de " + cValToChar(_nNumReg) + " na tabela DA1...")

		// validacao produto
		DbSelectArea("SB1")
		SB1->(DbSetOrder(1))
		If !SB1->(MsSeek(FWxFilial('SB1') + _nCodPro))
			aAdd(_aErr, "LINHA  '" + cValToChar(nPos) + "' ====> Código do Produto ['" + _nCodPro + "'] Produto não encontrado.")
			LOOP
		endif

		// validacao tabela
		DbSelectArea("DA0")
		DA0->(DbSetOrder(1))
		If !DA0->(MsSeek(FWxFilial('DA0') + _nTab))
			aAdd(_aErr, "LINHA  '" + cValToChar(nPos) + "' ====> Código Tabela ['" + _nTab + "'] Tabela não encontrada.")
			LOOP
		Endif

		DbSelectArea("DA1")
		DA1->(DbSetOrder(2))
		If DA1->(MsSeek(FWxFilial("DA1") + (_nCodPro + space(15 - LEN(_nCodPro))) + _nTab))
			_valAnt := DA1->DA1_PRCVEN

			RecLock("DA1", .F.)
			DA1->DA1_PRCVEN := _nPrcVen
			DA1->DA1_USALTE := AllTrim(cUserName)
			DA1->DA1_HRALTE := Substr(Time(),1,2) + ":" + Substr(Time(),4,2)
			DA1->DA1_DTALTE := DATE()
			MsUnLock()

			// Efetua gravação do logs de atualizacao DA1 X Z07 para utilizacao do BI
			_aDadosSB1 := GetAdvFVal("SB1", {"B1_CODCUS" , "B1_DESC"   }, FWxFilial("SB1") + _nCodPro				  , 1, {Space(TamSx3("B1_CODCUS")[1]) , Space(TamSx3("B1_DESC")[1])} , .T.)
			_aDadosZ07 := GetAdvFVal("Z07", {"Z07_CODCUS", "Z07_PRCCUS"}, FWxFilial("Z07") + _cTabCus + _aDadosSB1[1] , 2, {Space(TamSx3("Z07_CODCUS")[1]), 0						   } , .T.)
			_cDescrZ03 := GetAdvFVal("Z03", "Z03_DESCUS"                , FWxFilial("Z03") + _aDadosSB1[1]            , 1, Space(TamSx3("Z03_DESCUS")[1]) 							     , .T.)

			DbSelectArea("Z08")
			RecLock("Z08", .T.)
			Z08->Z08_FILIAL := FWxFilial("Z08")
			Z08->Z08_NUMATU := _cNumAtu
			Z08->Z08_DATATU := DATE()
			Z08->Z08_USUATU := AllTrim(UsrFullName(__CUSERID))
			Z08->Z08_TABDA1 := DA1->DA1_CODTAB
			Z08->Z08_CODDA1 := DA1->DA1_CODPRO
			Z08->Z08_DESDA1 := _aDadosSB1[2]
			Z08->Z08_PRCDA1 := DA1->DA1_PRCVEN
			Z08->Z08_TABZ07 := _cTabCus
			Z08->Z08_CODZ07 := _aDadosZ07[1]
			Z08->Z08_DESZ07 := _cDescrZ03
			Z08->Z08_PRCZ07 := _aDadosZ07[2]
			Z08->Z08_ORIGEM := "DTI118"
			MsUnLock()

			_LOG("LINHA  '" + cValToChar(nPos) + "' ====> Código do Produto ['" + _nCodPro + "'] E Tabela ['" + _nTab + "'] Preço de Venda Alterado de ['" + cValToChar(_valAnt) + "'] para ['" + cValToChar(_nPrcVen) + "']")
		Else
			aAdd(_aErr, "LINHA  '" + cValToChar(nPos) + "' ====> Código do Produto ['" + _nCodPro + "'] E Tabela ['" + _nTab + "'] Erro na Alteração / Registro não encontrado.")
		EndIf

		if !(_nTab $ cExcTabP)
			aAdd(aItens, {_nTab, _nCodPro})

			_nPos := aScan(aTabs,{|aVal| aVal = _nTab})
			if _nPos = 0
				aAdd(aTabs, _nTab)
			endif
		endif

	Next _nPos

	if !empty(aTabs)
		limpaTab(aTabs, aItens)
	endif

	If Len(_aErr) > 0
		_LOG("---------------------- ERROS DE IMPORTAÇÃO ----------------------")
		For _nPos := 1 To Len(_aErr)
			_LOG(_aErr[_nPos])
		Next _nPos
	EndIf

Return

//-------------------------------------------------------------------
/*/{Protheus.doc} _LOG
Função que Grava arquivo de log para conferência
@author     Mauro
@since      Mar/2021
@return     Nil
/*/
//-------------------------------------------------------------------
Static Function _LOG(_sTexto)

	Local _nHdl     := 0
	Local _cDir     := "C:\Temp\"
	Local _cNomeArq := "Log_Alteracao_Precos_de_Venda.LOG"
	Local _sArqLog  := ""

	If !ExistDir(_cDir)
		MakeDir(_cDir)
	EndIf

	_sArqLog := AllTrim(_cDir) + AllTrim(_cNomeArq)

	If file (_sArqLog)
		_nHdl = fOpen(_sArqLog, 1)
	Else
		_nHdl = fCreate(_sArqLog, 0)
	Endif

	fSeek(_nHdl, 0, 2)      // Encontra final do arquivo
	fWrite(_nHdl, _sTexto + chr (13) + chr (10))
	fClose(_nHdl)

Return

// Função para excluir os registros não importados da mesma tabela
Static Function limpaTab(aTabs, aItens)
	Local _nPos := 0
	Local i := 0

	for i := 1 to Len(aTabs)
		DbSelectArea("DA1")
		DA1->(DbSetOrder(1))
		DA1->(DbGoTop())
		DA1->(MsSeek(FWxFilial("DA1") + aTabs[i]))

		while DA1->(!eof()) .and. DA1->DA1_CODTAB = aTabs[i]
			_nPos := aScan(aItens,{|aVal| aVal[1] = aTabs[i] .and. aVal[2] = AllTrim(DA1->DA1_CODPRO)})

			if _nPos = 0
				RecLock("DA1", .F.)
					DbDelete()
				MsUnLock()
			endif

			DA1->(DbSkip())
		end
	next

Return
