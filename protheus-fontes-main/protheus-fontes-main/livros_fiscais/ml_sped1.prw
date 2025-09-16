#INCLUDE "rwmake.ch"
#INCLUDE "protheus.ch"
#INCLUDE "topconn.ch"
#INCLUDE "fileio.ch"

User Function ML_SPED1()

	/*/
	ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
	±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
	±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
	±±³Programa  ³ ML_SPED1 ³ Autor ³ Evandro Mugnol        ³ Data ³21/09/2011³±±
	±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
	±±³Unidade   ³ Serra Gaucha     ³Contato ³                                ³±±
	±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
	±±³Descricao ³ Ajusta valores de PIS e COFINS na tabela SD1 cfe regras    ³±±
	±±³          ³ definidas                                                  ³±±
	±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
	±±³Parametros³                                                            ³±±
	±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
	±±³Uso       ³ Especifico para clientes TOTVS                            ³±±
	±±ÃÄÄÄÄÄÄÄÄÄÄÁÄÄÄÂÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
	±±³Analista Resp.³  Data  ³ Manutencao Efetuada                           ³±±
	±±ÃÄÄÄÄÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
	±±³              ³        ³                                               ³±±
	±±³              ³        ³                                               ³±±
	±±ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
	±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
	ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
	/*/

	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Define variaveis locais                                      ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	Local oDlg
	Local cCadastro := "Ajusta PIS e COFINS na tabela SD1"
	LOCAL nOpca     := 0
	Local aSays     := {}
	Local aButtons  := {}

	Private _aLog:= {}

	cPerg := "ML_SPED1"

	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Verifica as perguntas selecionadas                           ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	Pergunte(cPerg,.T.)

	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Definicoes de tela                                           ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	AADD(aSays,OemToAnsi(" Este programa tem como objetivo efetuar os ajustes de     "))
	AADD(aSays,OemToAnsi(" PIS e COFINS na tabela SD1 conforme regras definidas.     "))
	AADD(aSays,OemToAnsi(" Confirma Processamento ?                                  "))

	AADD(aButtons, {5, .T. ,{|| Pergunte(cPerg,.T. ) } } )
	AADD(aButtons, {1, .T. ,{|o| nOpca:= 1, o:oWnd:End()}})
	AADD(aButtons, {2, .T. ,{|o| o:oWnd:End()}})

	FormBatch(cCadastro, aSays, aButtons ,, 220, 380)

	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Processamento                                                ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	If nOpca == 1
		Processa({|lEnd| ProcEXC()})
		If Len(_aLog) > 0
			MostraLog()
		EndIf
	Endif

Return(.T.)


/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Funcao    ³ ProcEXC  ³ Autor ³ Evandro Mugnol        ³ Data ³21/09/2011³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descricao ³ Processamento                                              ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Uso       ³ ML_SPED1                                                   ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Static Function ProcEXC()

	If mv_par01 == 1
		// NFs de Entrada
		_nVez := 1
		DbSelectArea("SD1")
		DbSetOrder(6)
		DbSeek(xFilial("SD1") + Dtos(mv_par02), .T.)
		ProcRegua(RecCount())
		Do While !Eof() .And. SD1->D1_FILIAL == xFilial("SD1") .And. SD1->D1_DTDIGIT <= mv_par03
			Incproc("Ajustando SD1. Aguarde....")
			_cPessoa := fBuscaCPO("SA2", 1, xFilial("SA2") + SD1->D1_FORNECE + SD1->D1_LOJA, "A2_TIPO")

			If _nVez == 1
				AADD(_aLog, Space(101) + "A N T E S       P I S" + Space(10) + "D E P O I S     P I S" + Space(30) + "A N T E S       C O F" + Space(10) + "D E P O I S     C O F")
				AADD(_aLog, Space(101) + "BASE   ALIQ     VALOR" + Space(10) + "BASE   ALIQ     VALOR" + Space(30) + "BASE   ALIQ     VALOR" + Space(10) + "BASE   ALIQ     VALOR")
				_nVez := 2
			Endif

			If (SD1->D1_TES $ "190/001/328" .And. AllTrim(SD1->D1_COD) <> "000238") .And. _cPessoa <> "J"
				//If SD1->D1_TES $ "150/151" 
				_nNewBas6 := SD1->D1_TOTAL
				_nNewAlq6 := 0.825
				_nNewVal6 := (SD1->D1_TOTAL * 0.825) / 100
				_nNewBas5 := SD1->D1_TOTAL
				_nNewAlq5 := 3.80
				_nNewVal5 := (SD1->D1_TOTAL * 3.80) / 100

				If mv_par04 == 1
					AADD(_aLog, SD1->D1_DOC + "-" + SD1->D1_SERIE + "   " + SD1->D1_COD + SD1->D1_DESCRI + ;
					Transform(SD1->D1_BASIMP6, '@E 999,999,999.99') + ;
					Transform(SD1->D1_ALQIMP6, '@E 999.999') + ;
					Transform(SD1->D1_VALIMP6, '@E 999,999.99') + ;
					Transform(_nNewBas6, '@E 999,999,999.99') + ;
					Transform(_nNewAlq6, '@E 999.999') + ;
					Transform(_nNewVal6, '@E 999,999.99') + ;
					Space(20) + ;
					Transform(SD1->D1_BASIMP5, '@E 999,999,999.99') + ;
					Transform(SD1->D1_ALQIMP5, '@E 999.999') + ;
					Transform(SD1->D1_VALIMP5, '@E 999,999.99') + ;
					Transform(_nNewBas5, '@E 999,999,999.99') + ;
					Transform(_nNewAlq5, '@E 999.999') + ;
					Transform(_nNewVal5, '@E 999,999.99') )
				Else
					AADD(_aLog, SD1->D1_DOC + "-" + SD1->D1_SERIE + "   " + SD1->D1_COD + SD1->D1_DESCRI + ;
					Transform(SD1->D1_BASIMP6, '@E 999,999,999.99') + ;
					Transform(SD1->D1_ALQIMP6, '@E 999.999') + ;
					Transform(SD1->D1_VALIMP6, '@E 999,999.99') + ;
					Transform(_nNewBas6, '@E 999,999,999.99') + ;
					Transform(_nNewAlq6, '@E 999.999') + ;
					Transform(_nNewVal6, '@E 999,999.99') + ;
					Space(20) + ;
					Transform(SD1->D1_BASIMP5, '@E 999,999,999.99') + ;
					Transform(SD1->D1_ALQIMP5, '@E 999.999') + ;
					Transform(SD1->D1_VALIMP5, '@E 999,999.99') + ;
					Transform(_nNewBas5, '@E 999,999,999.99') + ;
					Transform(_nNewAlq5, '@E 999.999') + ;
					Transform(_nNewVal5, '@E 999,999.99') )

					DbSelectArea("SD1")
					RecLock("SD1",.F.)
					SD1->D1_BASIMP6 := _nNewBas6
					SD1->D1_ALQIMP6 := _nNewAlq6
					SD1->D1_VALIMP6 := _nNewVal6
					SD1->D1_BASIMP5 := _nNewBas5
					SD1->D1_ALQIMP5 := _nNewAlq5
					SD1->D1_VALIMP5 := _nNewVal5
					MsUnlock()
				Endif
			Endif

			DbSelectArea("SD1")
			DbSkip()
		Enddo
	Else
		// NFs de Saída
		_nVez := 1
		DbSelectArea("SD2")
		DbSetOrder(5)
		DbSeek(xFilial("SD2") + Dtos(mv_par02), .T.)
		ProcRegua(RecCount())
		Do While !Eof() .And. SD2->D2_FILIAL == xFilial("SD2") .And. SD2->D2_EMISSAO <= mv_par03
			Incproc("Ajustando SD2. Aguarde....")

			If _nVez == 1
				AADD(_aLog, Space(101) + "A N T E S       P I S" + Space(10) + "D E P O I S     P I S" + Space(30) + "A N T E S       C O F" + Space(10) + "D E P O I S     C O F")
				AADD(_aLog, Space(101) + "BASE   ALIQ     VALOR" + Space(10) + "BASE   ALIQ     VALOR" + Space(30) + "BASE   ALIQ     VALOR" + Space(10) + "BASE   ALIQ     VALOR")
				_nVez := 2
			Endif

			//If SD2->D2_TES == "508"
			If SD2->D2_TES == "501"
				_nNewBas6 := SD2->D2_TOTAL + SD2->D2_VALFRE
				_nNewAlq6 := 1.650
				_nNewVal6 := ((SD2->D2_TOTAL + SD2->D2_VALFRE) * 1.650) / 100
				_nNewBas5 := SD2->D2_TOTAL + SD2->D2_VALFRE
				_nNewAlq5 := 7.600
				_nNewVal5 := ((SD2->D2_TOTAL + SD2->D2_VALFRE) * 7.600) / 100

				If mv_par04 == 1
					AADD(_aLog, SD2->D2_DOC + "-" + SD2->D2_SERIE + "   " + SD2->D2_COD + SD2->D2_DESCRI + ;
					Transform(SD2->D2_BASIMP6, '@E 999,999,999.99') + ;
					Transform(SD2->D2_ALQIMP6, '@E 999.999') + ;
					Transform(SD2->D2_VALIMP6, '@E 999,999.99') + ;
					Transform(_nNewBas6, '@E 999,999,999.99') + ;
					Transform(_nNewAlq6, '@E 999.999') + ;
					Transform(_nNewVal6, '@E 999,999.99') + ;
					Space(20) + ;
					Transform(SD2->D2_BASIMP5, '@E 999,999,999.99') + ;
					Transform(SD2->D2_ALQIMP5, '@E 999.999') + ;
					Transform(SD2->D2_VALIMP5, '@E 999,999.99') + ;
					Transform(_nNewBas5, '@E 999,999,999.99') + ;
					Transform(_nNewAlq5, '@E 999.999') + ;
					Transform(_nNewVal5, '@E 999,999.99') )
				Else
					AADD(_aLog, SD2->D2_DOC + "-" + SD2->D2_SERIE + "   " + SD2->D2_COD + SD2->D2_DESCRI + ;
					Transform(SD2->D2_BASIMP6, '@E 999,999,999.99') + ;
					Transform(SD2->D2_ALQIMP6, '@E 999.999') + ;
					Transform(SD2->D2_VALIMP6, '@E 999,999.99') + ;
					Transform(_nNewBas6, '@E 999,999,999.99') + ;
					Transform(_nNewAlq6, '@E 999.999') + ;
					Transform(_nNewVal6, '@E 999,999.99') + ;
					Space(20) + ;
					Transform(SD2->D2_BASIMP5, '@E 999,999,999.99') + ;
					Transform(SD2->D2_ALQIMP5, '@E 999.999') + ;
					Transform(SD2->D2_VALIMP5, '@E 999,999.99') + ;
					Transform(_nNewBas5, '@E 999,999,999.99') + ;
					Transform(_nNewAlq5, '@E 999.999') + ;
					Transform(_nNewVal5, '@E 999,999.99') )

					DbSelectArea("SD2")
					RecLock("SD2",.F.)
					SD2->D2_BASIMP6 := _nNewBas6
					SD2->D2_ALQIMP6 := _nNewAlq6
					SD2->D2_VALIMP6 := _nNewVal6
					SD2->D2_BASIMP5 := _nNewBas5
					SD2->D2_ALQIMP5 := _nNewAlq5
					SD2->D2_VALIMP5 := _nNewVal5
					MsUnlock()
				Endif
			Endif

			DbSelectArea("SD2")
			DbSkip()
		Enddo
	Endif

	MsgInfo("Processo Finalizado com Sucesso! ")

Return


/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Programa  ³ MostraLog³ Autor ³ Evandro Mungol        ³ Data ³21/09/2011³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Unidade   ³ Serra Gaucha     ³Contato ³                                ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descricao ³ Cria a tela de log do processo permitindo ao usuario salvar³±±
±±³          ³ o resultado em um arquivo texto.                           ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Uso       ³ ML_SPED1                                                   ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÁÄÄÄÄÁÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/

Static Function MostraLog()          

	DEFINE FONT oFont NAME "Mono AS" SIZE 6,15
	DEFINE MSDIALOG oDlg TITLE "Processo Concluído" From 3, 0 to 340, 417 PIXEL
	@ 5, 5 LISTBOX oList FIELDS HEADER "Log da Importação" SIZE 200, 145 OF oDlg PIXEL 
	oList:SetArray(_aLog)
	oList:bLine:= {|| {_aLog[oList:nat]}}
	oList:oFont:= oFont
	oList:SetFocus()

	DEFINE SBUTTON FROM 153,175 TYPE 1  ACTION oDlg:End() ENABLE OF oDlg PIXEL                                                                                			// Apaga
	DEFINE SBUTTON FROM 153,145 TYPE 13 ACTION (cFile:= cGetFile("Arquivos Texto (*.TXT) |*.txt|", ""),IIF(cFile == "", .t., GravaLog(cFile))) ENABLE OF oDlg PIXEL   // Salva e Apaga   // "Salvar Como..."
	ACTIVATE MSDIALOG oDlg CENTER

Return

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³ GravaLog º Autor ³ Evandro Mugnol     º Data ³  21/09/2011 º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³ Faz a gravacao do log em um arquivo texto                  º±±
±±º          ³                                                            º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ MostraLog                                                 º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Static Function GravaLog(_sArqLog)
	Local _nHdl    := 0
	Local i
	
	If file (_sArqLog)
		_nHdl = fOpen(_sArqLog, 1)
	Else
		_nHdl = fCreate(_sArqLog, 0)                                            
	Endif

	fSeek(_nHdl, 0, 2)      // Encontra final do arquivo
	for i:= 1 to len(_aLog)
		fWrite(_nHdl, _aLog[i] + chr (13) + chr (10))
	next
	fClose(_nHdl)

Return
