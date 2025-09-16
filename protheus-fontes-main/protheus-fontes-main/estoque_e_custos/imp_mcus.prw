#INCLUDE "TOTVS.CH"

/*/{Protheus.doc} IMP_MCUS
Rotina efetua importação dos saldos/custos virada (SB9) conforme arquivo Excel (.CSV)
@author     Evandro
@since      Fev/2021
@return     Nil
@obs        N/A
/*/

User Function IMP_MCUS()

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
	Private _cDlgTab   := "SB9"	
	Private _cNL       := CHR(13) + CHR(10)
	Private _oDlgArq
	Private _oDlgTab
	Private Valor1 := stod('')
	Private campoA := stod('')

	// Inicio da tela de importacao
	DEFINE MSDIALOG _oDlg FROM 001,001 TO 140,450 TITLE "Importação Saldos/Custos Virada SB9" PIXEL

	@ 001,001 TO 069,226 LABEL "" OF _oDlg PIXEL
	@ 010,010 SAY "Data de Proces.:"			SIZE 120, 7 PIXEL OF _oDlg
	@ 010,060 MSGET campoA VAR Valor1 	SIZE 055,10 COLOR CLR_GREEN	PIXEL OF _oDlg

	@ 020,010 SAY "Arquivo:"			SIZE 120, 7 PIXEL OF _oDlg

	@ 024,035 MSGET _oDlgArq VAR _cArq	SIZE 165, 7 WHEN .T. PIXEL OF _oDlg
	@ 027,200 BUTTON "..."				SIZE 014, 7 PIXEL OF _oDlg Action (_cArq := cGetFile("*.CSV","Selecione o Arquivo a ser importado...",1,"C:\",.T.,16,.F.))

	DEFINE SBUTTON _oBtn1 FROM 040,035 	TYPE 1 ACTION (Processa({ || _PREPARIMP()}, "Importando dados para a tabela " + _cDlgTab + "...", "por favor, aguarde.", .F.)) ENABLE OF _oDlg
	_oBtn1:cCaption := "Importar"
	_oBtn1:cToolTip := "Importar dados do arquivo para atualizar saldos/custos virada SB9."

	DEFINE SBUTTON _oBtn2 FROM 040,065 TYPE 2 ACTION (_oDlg:End()) ENABLE OF _oDlg
	_oBtn2:cToolTip := "Sair da Rotina"

	ACTIVATE MSDIALOG _oDlg CENTERED

Return


//-------------------------------------------------------------------
/*/{Protheus.doc} _PREPARIMP
Função que prepara ambiente para a importacao dos dados da planilha
@author     Evandro
@since      Fev/2021
@param      N/A
@return     Nil
/*/
//-------------------------------------------------------------------
Static Function _PREPARIMP()

	// Importa os dados do arquivo para um vetor
	Processa({ || _ARQ_VET()}, "Efetuando Carga de Dados. Por Favor, aguarde.", "", .F.)

	// Importa os dados do vetor para a tabela
	If MsgYesNo("Leitura Concluída com Sucesso." + _cNl + "Deseja continuar e realizar a atualização dos registros?")
		If MsgYesNo("Deseja gerar somente LOG de processamento antes de atualizar informações?")
			_cGrava := "N"
			//alert('1 Gerar Log !!--'+_cGrava)
			//return
		Else
			_cGrava := "S"
			//alert('2 Gerar Log !!--'+_cGrava)
			//return
		Endif
		Processa({ || _IMPORTA(_cGrava,Valor1)}, "Importando dados. Por Favor, aguarde.", "", .F.)
		MsgAlert("Importação Concluída com Sucesso!" + _cNl + "Verifique a Situação da Importação no Arquivo de LOG em C:\Temp\LogSB9_Saldos_Virada.LOG")
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
@since      Fev/2021
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
@since      Fev/2021
@param      _cGrava
@return     Nil
/*/
//-------------------------------------------------------------------
Static Function _IMPORTA(_cGravaB9,Valor1)

	Local _nPos  	:= 0
	Local _aArea	:= GetArea()
	Local _aAreaZB1 := GetArea("SB9")	

	_nNumReg := Len(_aDados)

	ProcRegua(_nNumReg)

	_nNumLendo := 0

	For _nPos := 1 To Len(_aDados)

		_nNumLendo++

		IncProc("Atualizando/Incluindo registro " + cValToChar(_nNumLendo) + " de " + cValToChar(_nNumReg) + " na tabela SB9...")

		DbSelectArea("SB1")
		_cLocPad := fBuscaCpo("SB1", 1, xFilial("SB1") + _aDados[_nPos,1], "B1_LOCPAD")	
		//_dDataB9 := Ctod("31/12/2023")		// Deve ser trocado todos os anos		
		_dDataB9 := Valor1
		_nCustD  := Val(StrTran(_aDados[_nPos,2],",","."))
		_nCm1	 := Val(StrTran(_aDados[_nPos,2],",","."))
		_nQini	 := Val(StrTran(_aDados[_nPos,3],",","."))
		_nVini1  := Val(StrTran(_aDados[_nPos,4],",","."))

		DbSelectArea("SB9")
		SB9->(dbSetOrder(1))
		SB9->(dbGoTop())

		If !SB9->(dbSeek(xFilial("SB9") + PADR(_aDados[_nPos,1],15," ") + _cLocPad + Dtos(_dDataB9)))

			If _cGravaB9 == "S"
				Reclock("SB9",.T.)   
				SB9->B9_FILIAL := xFilial("SB9")                              
				SB9->B9_COD    := _aDados[_nPos,1]
				//SB9->B9_DATA   := Ctod("31/12/2023")// Deve ser trocado todos os anos				
				SB9->B9_DATA   := Valor1
				SB9->B9_LOCAL  := _cLocPad
				SB9->B9_CUSTD  := _nCustD
				SB9->B9_CM1    := _nCm1
				SB9->B9_QINI   := _nQini
				SB9->B9_VINI1  := _nVini1
				SB9->B9_MCUSTD := "1"				
				MsUnlock()
				
				_LOG("INCLUIDO SB9 SIM     => CODIGO: " + _aDados[_nPos,1] + " - Custo Unitário: " + Transform(_nCm1, "@E 9,999,999.9999") + " - Qtde Inicial Mes: " +  Transform(_nQini, "@E 9,999,999,999.9999999") + " - Saldo Inicial Mês em Valor: " + Transform(_nVini1, "@E 9,999,999,999.9999999") )
				_LOG("")
			Else
				_LOG("INCLUIDO SB9 NAO     => CODIGO: " + _aDados[_nPos,1] + " - Custo Unitário: " + Transform(_nCm1, "@E 9,999,999.9999") + " - Qtde Inicial Mes: " +  Transform(_nQini, "@E 9,999,999,999.9999999") + " - Saldo Inicial Mês em Valor: " + Transform(_nVini1, "@E 9,999,999,999.9999999") )
				_LOG("")
			Endif
			//alert('INCLUIDO COD'+SB9->B9_COD+'-CUSTD  - '+str(SB9->B9_CUSTD)+'#Custo Unitário-'+str(SB9->B9_CM1)+'#QTD INI-'+str(SB9->B9_QINI)+'#Saldo inicial-'+str(SB9->B9_VINI1))
			
		Else 
			If _cGravaB9 == "S"
				_nCm1Old   := SB9->B9_CM1
				_nQiniOld  := SB9->B9_QINI
				_nVini1Old := SB9->B9_VINI1
				
				Reclock("SB9",.F.)
				SB9->B9_CUSTD := _nCustD
				SB9->B9_CM1   := _nCm1
				SB9->B9_QINI  := _nQini
				SB9->B9_VINI1 := _nVini1				
				MsUnlock()
				_LOG("ALTERADO SB9 ANTES   => CODIGO: " + _aDados[_nPos,1] + " - Custo Unitário: " + Transform(_nCm1Old, "@E 9,999,999.9999") + " - Qtde Inicial Mes: " +  Transform(_nQiniOld, "@E 9,999,999,999.9999999") + " - Saldo Inicial Mês em Valor: " + Transform(_nVini1Old, "@E 9,999,999,999.9999999") )
				_LOG("             DEPOIS  => CODIGO: " + _aDados[_nPos,1] + " - Custo Unitário: " + Transform(_nCm1, "@E 9,999,999.9999")       + " - Qtde Inicial Mes: " +  Transform(_nQini, "@E 9,999,999,999.9999999")       + " - Saldo Inicial Mês em Valor: " + Transform(_nVini1, "@E 9,999,999,999.9999999") )
				_LOG("")
			Else
				_LOG("ALTERADO SB9 ANTES   => CODIGO: " + _aDados[_nPos,1] + " - Custo Unitário: " + Transform(SB9->B9_CM1, "@E 9,999,999.9999")      + " - Qtde Inicial Mes: " +  Transform(SB9->B9_QINI, "@E 9,999,999,999.9999999")     + " - Saldo Inicial Mês em Valor: " + Transform(SB9->B9_VINI1, "@E 9,999,999,999.9999999") )
				_LOG("             DEPOIS  => CODIGO: " + _aDados[_nPos,1] + " - Custo Unitário: " + Transform(_nCm1, "@E 9,999,999.9999")       + " - Qtde Inicial Mes: " +  Transform(_nQini, "@E 9,999,999,999.9999999")       + " - Saldo Inicial Mês em Valor: " + Transform(_nVini1, "@E 9,999,999,999.9999999") )
				_LOG("")
			Endif
			//alert('ALTERADO  COD'+SB9->B9_COD+'-CUSTD  - '+str(SB9->B9_CUSTD)+'#Custo Unitário-'+str(SB9->B9_CM1)+'#QTD INI-'+str(SB9->B9_QINI)+'#Saldo inicial-'+str(SB9->B9_VINI1))
			//Return
		Endif

		dbCloseArea()

	Next _nPos

	RestArea(_aArea)
	RestArea(_aAreaZB1)	 

Return


//-------------------------------------------------------------------
/*/{Protheus.doc} _LOG
Função que Grava arquivo de log para conferência
@author     Evandro
@since      Fev/2021
@param      N/A
@return     Nil
/*/
//-------------------------------------------------------------------
Static Function _LOG(_sTexto)

	Local _nHdl     := 0
	Local _cDir     := "C:\Temp\"
	Local _cNomeArq := "LogSB9_Saldos_Virada_Empresa_" + cEmpAnt + ".LOG"
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
