#INCLUDE "rwmake.ch"
#INCLUDE "protheus.ch"

User Function PS901CLI(lBat,nOpcao)

	/*/
	ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
	±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
	±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
	±±³Programa  ³ PS901CLI  ³ Autor ³ Evandro Mugnol       ³ Data ³ Dez/2012 ³±±
	±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
	±±³Descricao ³ Programa para efetuar a troca dos codigos e lojas dos      ³±±
	±±³          ³ clientes com o conteúdo dos códigos e lojas novos.         ³±±
	±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
	±±³Uso       ³ Especifico para Clientes TOTVS                             ³±±
	±±ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
	±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
	ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
	/*/

	If cEmpAnt <> "07"
		MsgStop("Rotina não pode ser executada nesta empresa. Somente na Transportadora." + chr(13) + chr(13) + "Verifique qual empresa está selecionada!")
		Return
	Endif

	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Define Variaveis                                             ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	nOpca     := 0
	cCadastro := OemtoAnsi("Efetua Troca Código e Loja dos Clientes")
	aSays     := {}
	aButtons  := {}
	cMens     := ""
	cPerg     := "PS901CLI"

	lBat   := If(lBat == NIL,.F.,lBat)
	nOpcao := If(ValType(nOpcao) # "N",0,nOpcao)

	#IFDEF TOP
	TCInternal(5,"*OFF")        // Desliga Refresh no Lock do Top
	#ENDIF

	If !lBat
		cMens := OemToAnsi("Esta rotina será  executada em modo") + chr(13)
		cMens += OemToAnsi("exclusivo, conforme necessidade do ") + chr(13)
		cMens += OemToAnsi("sistema. Continua com o processo ? ") + chr(13)

		If !MsgYesNo(cMens,OemToAnsi("ATENÇÃO"))
			Return
		EndIf

		AADD(aSays,OemToAnsi("Através deste programa o sistema irá efetuar a troca dos códigos e  "))
		AADD(aSays,OemToAnsi("lojas dos clientes nas tabelas envolvidas desta empresa, auxiliando "))
		AADD(aSays,OemToAnsi("a implantação de dados no sistema de maneira consistente e rápida.  "))

		AADD(aButtons,{1,.T.,{|o| nOpca:= 1,(nOpca:= 1,nOpcao:=1,o:oWnd:End()) } } )
		AADD(aButtons,{2,.T.,{|o| o:oWnd:End()}})

		FormBatch( cCadastro, aSays, aButtons,,200,405 )
	Else
		nOpca:=1
	EndIf

	If nOpcA == 1
		Processa({|lEnd| ProcCLI(nOpcao),"Troca de Código e Loja dos Clientes"})
	Endif

Return


/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Funcao    ³ ProcCLI  ³ Autor ³ Evandro Mugnol        ³ Data ³ Dez/2012 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descricao ³ Processamento                                              ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Uso       ³ PS901CLI                                                   ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Static Function ProcCLI(nOpcao)

	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Processa trocas de códigos e lojas nas tabelas/campos passadas no parametro ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ 
	_Executa("AAM","AAM->AAM_CODCLI","AAM->AAM_LOJA")
	_Executa("CD2","CD2->CD2_CODCLI","CD2->CD2_LOJCLI")
	_Executa("DT4","DT4->DT4_CLIREM","DT4->DT4_LOJREM")
	_Executa("DT4","DT4->DT4_CLIDEV","DT4->DT4_LOJDEV")
	_Executa("DT6","DT6->DT6_CLIREM","DT6->DT6_LOJREM")
	_Executa("DT6","DT6->DT6_CLIDES","DT6->DT6_LOJDES")
	_Executa("DT6","DT6->DT6_CLIDEV","DT6->DT6_LOJDEV")
	_Executa("DT6","DT6->DT6_CLICAL","DT6->DT6_LOJCAL")
	_Executa("DTC","DTC->DTC_CLIREM","DTC->DTC_LOJREM")
	_Executa("DTC","DTC->DTC_CLIDES","DTC->DTC_LOJDES")
	_Executa("DTC","DTC->DTC_CLIDEV","DTC->DTC_LOJDEV")
	_Executa("DTC","DTC->DTC_CLICAL","DTC->DTC_LOJCAL")
	_Executa("DTR","DTR->DTR_CREADI","DTR->DTR_LOJCRE")
	_Executa("DUE","DUE->DUE_CODCLI","DUE->DUE_LOJCLI")
	_Executa("DUO","DUO->DUO_CODCLI","DUO->DUO_LOJCLI")
	_Executa("DV1","DV1->DV1_CODCLI","DV1->DV1_LOJCLI")
	_Executa("DVR","DVR->DVR_CLIREM","DVR->DVR_LOJREM")
	_Executa("DVR","DVR->DVR_CLIDES","DVR->DVR_LOJDES")
	_Executa("DVU","DVU->DVU_CLIREM","DVU->DVU_LOJREM")
	_Executa("SB6","SB6->B6_CLIFOR" ,"SB6->B6_LOJA")
	_Executa("SC5","SC5->C5_CLIENTE","SC5->C5_LOJACLI")
	_Executa("SC5","SC5->C5_CLIENT" ,"SC5->C5_LOJAENT")
	_Executa("SC6","SC6->C6_CLI"    ,"SC6->C6_LOJA")
	_Executa("SC9","SC9->C9_CLIENTE","SC9->C9_LOJA")
	_Executa("SD2","SD2->D2_CLIENTE","SD2->D2_LOJA")
	_Executa("SE1","SE1->E1_CLIENTE","SE1->E1_LOJA")
	_Executa("SE5","SE5->E5_CLIFOR" ,"SE5->E5_LOJA")
	_Executa("SF2","SF2->F2_CLIENTE","SF2->F2_LOJA")
	_Executa("SF3","SF3->F3_CLIEFOR","SF3->F3_LOJA")
	_Executa("SF3","SF3->F3_CLIENT" ,"SF3->F3_LOJENT")
	_Executa("SFT","SFT->FT_CLIEFOR","SFT->FT_LOJA")
	_Executa("SFT","SFT->FT_CLIENT" ,"SFT->FT_LOJENT")

Return

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Funcao    ³ _Executa ³ Autor ³ Evandro Mugnol         ³ Data ³ Dez/2012 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descricao ³ Executa campos das tabelas                                  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Uso       ³ PS901CLI                                                    ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßÄßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Static Function _Executa(_cAlias,_cCampo1,_cCampo2)

	Local lGrava := .F.

	DbSelectArea(_cAlias)
	ProcRegua(RecCount())    
	DbGoTop()
	Do While !Eof()
		IncProc("Processando Campos " + _cCampo1 + " / " + _cCampo2)

		If AllTrim(_cAlias) == "SE5"
			If (AllTrim(SE5->E5_RECPAG) == "R" .And. AllTrim(SE5->E5_TIPO) == "PA") .Or. AllTrim(SE5->E5_RECPAG) == "P"
				DbSelectArea(_cAlias)
				DbSkip()
				Loop
			Endif
		Endif

		If AllTrim(_cAlias) == "SF3"
			If AllTrim(SF3->F3_CFO) < "5000"
				DbSelectArea(_cAlias)
				DbSkip()
				Loop
			Endif
		Endif

		If AllTrim(_cAlias) == "SFT"
			If AllTrim(SFT->FT_CFOP) < "5000"
				DbSelectArea(_cAlias)
				DbSkip()
				Loop
			Endif
		Endif

		// Se campo igual a branco pula registro
		If Alltrim(&(_cCampo1)) == Alltrim("") .Or. Alltrim(&(_cCampo1)) == "*"
			DbSelectArea(_cAlias)
			Dbskip()
			Loop
		Endif

		_cCodAnt := &(_cCampo1)+&(_cCampo2)		//	Possui o codigo+loja antigo do cliente
		DbSelectArea("SA1")
		DbSetOrder(1) 		  							//	Verificar qual é a ordem
		If DbSeek(xFilial("SA1") + _cCodAnt)	//	Pesquisa qual é o novo código do cliente
			lGrava := .T. 								// Encontrou pelo menos 1 registro
			_cCodNew := SA1->A1_CODNEW
			_cLojNew := SA1->A1_LOJNEW

			// Grava novo código e loja na tabela
			If AllTrim(_cAlias) == "SE5"
				DbSelectArea(_cAlias)
				RecLock(_cAlias,.F.)
				&(_cCampo1) := _cCodNew
				&(_cCampo2) := _cLojNew
				SE5->E5_CLIENTE := _cCodNew
				MsUnlock()
			Else
				DbSelectArea(_cAlias)
				RecLock(_cAlias,.F.)
				&(_cCampo1) := _cCodNew
				&(_cCampo2) := _cLojNew
				MsUnlock()
			Endif
		Else
			_titulo := "COD_" + _cAlias
			_log("Nao encontrado " + _cCodAnt + " no cadastro de clientes para a tabela " + _cAlias,_titulo)
		Endif

		DbSelectArea(_cAlias)
		DbSkip()

	Enddo

	If !lGrava
		_titulo := "NCOD_"+_cAlias
		_log("Nenhuma ocorrencia para a tabela "+_cAlias,_titulo)
	Endif

Return


//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Grava arquivo de log para conferencia                           ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
Static Function _Log(_sTexto,titulo)

	Local _nHdl    := 0
	Local _sArqLog := Alltrim(titulo)+".log"

	If file (_sArqLog)
		_nHdl = fOpen(_sArqLog, 1)
	Else
		_nHdl = fCreate(_sArqLog, 0)
	Endif

	fSeek(_nHdl, 0, 2)      // Encontra final do arquivo
	fWrite(_nHdl, _sTexto + chr (13) + chr (10))
	fClose(_nHdl)

Return 
