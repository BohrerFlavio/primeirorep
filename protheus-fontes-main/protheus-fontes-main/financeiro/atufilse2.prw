#INCLUDE "TOTVS.CH"

/*/{Protheus.doc} ATUFILSE2
Rotina efetua atualização da tabela (SE2) ref. E5_FILORIG conforme arquivo Excel (.CSV)
@author     Evandro
@since      Jun/2022
@return     Nil
@obs        N/A
/*/

User Function ATUFILSE2()

	Private _cArq      :=  Space(500)	
	Private _nNumReg   := 0
	Private _nNumLendo := 0
	Private _nI        := 0
	Private _nJ        := 0
	Private _cLinha    := ""
	Private _lPrim     := .T.
	Private _aCampos   := {}
	Private _aDados    := {}
	Private _cCampo    := ""
	Private _cDlgTab   := "SE2"	
	Private _cNL       := CHR(13) + CHR(10)
	Private _oDlgArq
	Private _oDlgTab

	// Inicio da tela de importacao
	DEFINE MSDIALOG _oDlg FROM 001,001 TO 140,450 TITLE "Atualização E5_FILORIG na Tabela SE2" PIXEL

	@ 001,001 TO 069,226 LABEL "" OF _oDlg PIXEL

	@ 025,010 SAY "Arquivo:"			SIZE 120, 7 PIXEL OF _oDlg
	@ 024,035 MSGET _oDlgArq VAR _cArq	SIZE 165, 7 WHEN .T. PIXEL OF _oDlg
	@ 027,200 BUTTON "..."				SIZE 014, 7 PIXEL OF _oDlg Action (_cArq := cGetFile("*.CSV","Selecione o Arquivo a ser importado...",1,"C:\",.T.,16,.F.))

	DEFINE SBUTTON _oBtn1 FROM 040,035 	TYPE 1 ACTION (Processa({ || _PREPARIMP()}, "Atualizando dados para a tabela " + _cDlgTab + "...", "por favor, aguarde.", .F.)) ENABLE OF _oDlg
	_oBtn1:cCaption := "Atualizar"
	_oBtn1:cToolTip := "Atualizar dados do arquivo para campo E5_FILORIG na tabela SE2."

	DEFINE SBUTTON _oBtn2 FROM 040,065 TYPE 2 ACTION (_oDlg:End()) ENABLE OF _oDlg
	_oBtn2:cToolTip := "Sair da Rotina"

	ACTIVATE MSDIALOG _oDlg CENTERED

Return


//-------------------------------------------------------------------
/*/{Protheus.doc} _PREPARIMP
Função que prepara ambiente para a importacao dos dados da planilha
@author     Evandro
@since      Jun/2022
@param      N/A
@return     Nil
/*/
//-------------------------------------------------------------------
Static Function _PREPARIMP()

	// Importa os dados do arquivo para um vetor
	Processa({ || _ARQ_VET()}, "Efetuando Carga de Dados. Por Favor, aguarde.", "", .F.)

	// Importa os dados do vetor para a tabela
	If MsgYesNo("Leitura Concluída com Sucesso." + _cNl + "Deseja continuar e realizar a atualização dos registros?")
		Processa({ || _IMPORTA()}, "Importando dados. Por Favor, aguarde.", "", .F.)
		MsgAlert("Importação Concluída com Sucesso!" + _cNl + "Verifique a Situação da Importação no Arquivo de LOG em C:\Temp\LogSE2.LOG")
	Else
		MsgAlert("Atualização dos Registros Cancelada pelo Usuário!")	
	EndIf

	// Limpa os dados para importar outro arquivo
	_cArq := Space(500)

Return


//-------------------------------------------------------------------
/*/{Protheus.doc} _ARQ_VET
Função que importa os dados do arquivo para um vetor
@author     Evandro
@since      Jun/2022
@param      N/A
@return     Nil
/*/
//-------------------------------------------------------------------
Static Function _ARQ_VET()

	// Verifica se o arquivo existe
	If !File(_cArq)
		MsgStop("O arquivo '" + _cArq + "' não foi encontrado. A importação será abortada.", "[" + FunName() + "] - Atenção!")
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

		If _lPrim 					// Se for o primeiro registro entao os dados contem os nomes dos campos que serao inseridos
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
@author     Evandro
@since      Jun/2022
@param      N/A
@return     Nil
/*/
//-------------------------------------------------------------------
Static Function _IMPORTA()

	Local _nPos  	:= 0
	Local _aArea	:= GetArea()
	Local _aAreaSE2 := GetArea("SE2")	

	_nNumReg := Len(_aDados)

	ProcRegua(_nNumReg)

	_nNumLendo := 0

	For _nPos := 1 To Len(_aDados)

		_nNumLendo++

		_cPrf := PADR(_aDados[_nPos,1] , 3, "")
		_cNum := PADR(_aDados[_nPos,2] , 9, "")
		_cPar := PADR(_aDados[_nPos,3] , 2, "")
		_cTip := PADR(_aDados[_nPos,4] , 3, "")
		_cFor := PADR(_aDados[_nPos,5] , 6, "")
		_cLoj := PADR(_aDados[_nPos,6] , 2, "")
		_cFlo := PADR(_aDados[_nPos,7] , 2, "")

		IncProc("Atualizando registro " + cValToChar(_nNumLendo) + " de " + cValToChar(_nNumReg) + " na tabela SE2...")

		DbSelectArea("SE2")
		SE2->(dbSetOrder(1))
		SE2->(dbGoTop())
		If SE2->(dbSeek(xFilial("SE2") + _cPrf + _cNum + _cPar + _cTip + _cFor + _cLoj))
			DbSelectArea("SE2")
			RecLock("SE2", .F.)				
			SE2->E2_FILORIG := _cFlo
			MsUnlock()
			_LOG("ATUALIZADO SE2: " + _cPrf + "|" + _cNum + "|" + _cPar + "|" + _cTip + "|" + _cFor + "|" + _cLoj + "| com E2_FILORIG: " + _cFlo)
		Else
			_LOG("NAO ENCONTRADO: " + _cPrf + "|" + _cNum + "|" + _cPar + "|" + _cTip + "|" + _cFor + "|" + _cLoj)
		EndIf

		DbCloseArea()

	Next _nPos

	RestArea(_aArea)
	RestArea(_aAreaSE2)	 

Return


//-------------------------------------------------------------------
/*/{Protheus.doc} _LOG
Função que Grava arquivo de log para conferência
@author     Evandro
@since      Jun/2022
@param      N/A
@return     Nil
/*/
//-------------------------------------------------------------------
Static Function _LOG(_sTexto)

	Local _nHdl     := 0
	Local _cDir     := "C:\Temp\"
	Local _cNomeArq := "LogSE2_" + cEmpAnt + ".LOG"
	Local _sArqLog  := ""

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
