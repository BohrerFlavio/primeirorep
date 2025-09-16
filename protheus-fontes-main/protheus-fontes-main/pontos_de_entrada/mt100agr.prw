#INCLUDE "rwmake.ch"
//#INCLUDE "topconn.ch"
//#INCLUDE "protheus.ch"

User Function MT100AGR()                                                                    

	/*/
	ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
	±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
	±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
	±±³Programa  ³ MT100AGR ³ Autor ³ Evandro Mugnol        ³ Data ³ 17.06.04 ³±±
	±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
	±±³Descricao ³ Zera aliquota e base do imposto1 (FESA) gerados pela rotina³±±
	±±³          ³ de impostos variaveis                                      ³±±
	±±³          ³ Grava dados do transportador e motorista                   ³±±
	±±³          ³ Recalcula PIS e COFINS para pessoa fisica e juridica       ³±±
	±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
	±±³Uso       ³ Especifico para Frigorifico Silva                          ³±±
	±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
	±±³Observacao³                                                            ³±±
	±±³          ³                                                            ³±±
	±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
	±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
	ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
	/*/

	Local _cGerNPR  := ""
	Local _cGerDesc := SA2->A2_GERDESC

	If !l103class .And. !INCLUI
		Return	
	Endif

	If IsInCallStack("U_PMXML005")
		Return
	Endif

	If IsInCallStack("U_FFM18")
		Return
	Endif

	If INCLUI .Or. l103Class
		RecLock("SF1", .F.)
		SF1->F1_SILVA := AllTrim(UsrFullName(RetCodUsr()))
		MsUnLock()
	EndIf

	If IsInCallStack("U_STI_RG06")
		_dVencto := dVencto		// Variável dVencto originária do fonte STI_RG06
		_cGerNPR := cGerNPR		// Variável cGerNPR originária do fonte STI_RG06
		_Executa := "S"
		_nVlDesc := GetMv("FS_E2VLDES")		// Valor do decréscimo a ser gravado no SE2 

		// Grava Vencimento informado na rotina STI_RG06
		DbSelectArea("SE2")
		SE2->(DbSetOrder(6))
		SE2->(MsSeek(FWxFilial("SE2")+SF1->F1_FORNECE+SF1->F1_LOJA+SF1->F1_SERIE+SF1->F1_DOC))
		While SE2->(!Eof()) .And. SE2->E2_FILIAL+SE2->E2_FORNECE+SE2->E2_LOJA+SE2->E2_PREFIXO+SE2->E2_NUM == FWxFilial("SE2")+SF1->F1_FORNECE+SF1->F1_LOJA+SF1->F1_SERIE+SF1->F1_DOC
			Reclock("SE2",.F.)
			SE2->E2_VENCTO  := _dVencto
			SE2->E2_VENCREA := _dVencto
			SE2->E2_VENCORI := _dVencto
			If _cGerDesc == "S"
				SE2->E2_DECRESC := _nVlDesc 
				SE2->E2_SDDECRE := _nVlDesc
			Endif
			If SF1->F1_CONTSOC > 0 .And. SF1->F1_FORMUL == "S"
				SE2->E2_VLCRUZ := SE2->E2_VALOR
			EndIf
			MsUnlock()      
			SE2->(DbSkip())
		Enddo
	Else
		_dVencto := Ctod("")
		_cGerNPR := "2"
		_Executa := "N"
	Endif

	_cAlias := Alias()

	_cTipoNf := SF1->F1_TIPO

	If SF1->F1_TIPO == "D"
		RecLock("SF1",.F.)
		SF1->F1_EST := SA1->A1_EST
		MsUnLock()

		RecLock("SF3",.F.)
		SF3->F3_ESTADO := SA1->A1_EST
		MsUnLock()
	EndIf

	/*
	If SF1->F1_TIPO $ "DB"
	_cCgc := Posicione("SA1", 1, FWxFilial("SA1") + SF1->F1_FORNECE + SF1->F1_LOJA, "A1_CGC")
	Else
	_cCgc := Posicione("SA2", 1, FWxFilial("SA2") + SF1->F1_FORNECE + SF1->F1_LOJA, "A2_CGC")
	Endif

	If Len(AllTrim(_cCgc)) = 14
	_cTpCli := "J"
	Else
	_cTpCli := "F"
	Endif

	_nTValImp5 := 0
	_nTValImp6 := 0
	DbSelectArea("SD1")        // Vare os itens da NFE
	DbSetOrder(1)
	MsSeek(FWxFilial("SD1")+SF1->F1_DOC+SF1->F1_SERIE+SF1->F1_FORNECE+SF1->F1_LOJA)
	Do While !Eof() .And. SD1->D1_FILIAL+SD1->D1_DOC+SD1->D1_SERIE+SD1->D1_FORNECE+SD1->D1_LOJA=FWxFilial("SD1")+SF1->F1_DOC+SF1->F1_SERIE+SF1->F1_FORNECE+SF1->F1_LOJA
	// Recalcula PIS e COFINS para pessoa fisica
	If _cTpCli = "F"
	_cPisCred := Posicione("SF4",1,FWxFilial("SF4") + SD1->D1_TES,"F4_PISCRED")     //credita pis/cofins
	_cPisCof  := Posicione("SF4",1,FWxFilial("SF4") + SD1->D1_TES,"F4_PISCOF")      //define se gera pis/cofins
	_nPercPIS := Posicione("SB1",1,FWxFilial("SB1") + SD1->D1_COD,"B1_PPIS")        //percentual pis
	_nPercCOF := Posicione("SB1",1,FWxFilial("SB1") + SD1->D1_COD,"B1_PCOFINS")     //percentual cofins
	If _cPisCred = "1" .And. _cPisCof = "3" .And. _nPercPIS > 0.00 .And. _nPercCOF > 0.00
	DbSelectArea("SD1")
	RecLock("SD1",.F.)
	SD1->D1_ALQIMP6 := GetMv("ML_TXPISF")                                      //taxa para calculo do pis pessoa física
	SD1->D1_ALQIMP5 := GetMv("ML_TXCOFIF")                                     //taca para calculo do cofins pessoa fisica
	// PIS
	SD1->D1_CUSTO   := SD1->D1_CUSTO + SD1->D1_VALIMP6
	SD1->D1_VALIMP6 := (SD1->D1_BASIMP6 * SD1->D1_ALQIMP6) / 100
	SD1->D1_CUSTO   := SD1->D1_CUSTO - SD1->D1_VALIMP6
	// COFINS
	SD1->D1_CUSTO   := SD1->D1_CUSTO + SD1->D1_VALIMP5
	SD1->D1_VALIMP5 := (SD1->D1_BASIMP5 * SD1->D1_ALQIMP5) / 100
	SD1->D1_CUSTO   := SD1->D1_CUSTO - SD1->D1_VALIMP5
	MsUnlock()
	Endif
	Endif

	DbSelectArea("SD1")
	RecLock("SD1",.F.)
	SD1->D1_BASIMP1 := 0
	SD1->D1_ALQIMP1 := 0
	MsUnlock()

	_nTValImp5 := _nTValImp5 + SD1->D1_VALIMP5
	_nTValImp6 := _nTValImp6 + SD1->D1_VALIMP6
	DbSkip()
	Enddo
	*/	

	If !IsInCallStack("U_STI_RG06") .and. SF1->F1_FORMUL = "S"	// Executa quando não for gerado nota fiscal pela rotina automática no fonte STI_RG06
		_xTransp := Space(06)
		_xNomeTr := Space(60)
		_xMotori := Space(06)
		_xNomeMt := Space(60)
		_xMens1  := Space(80)
		_xMens2  := Space(80)
		_xMens3  := Space(80)
		_xMens4  := Space(80)

		@ 150,030 TO 350,660 DIALOG oDlg1 TITLE "Dados Complementares"
		@ 005,005 SAY "Transportador "
		@ 015,005 SAY "Motorista     "

		If _cTipoNf == "I"
			@ 033,005 SAY "MENSAGEM PARA NOTAS DE CREDITO A SEREM IMPRESSAS NA NOTA FISCAL"
			@ 034,005 SAY "________________________________________________________________"
			@ 045,005 SAY "Mensagem  1 "
			@ 055,005 SAY "Mensagem  2 "
			@ 065,005 SAY "Mensagem  3 "
			@ 075,005 SAY "Mensagem  4 "
		Else
			@ 033,005 SAY "MENSAGEM PARA NOTAS FISCAIS A SEREM IMPRESSAS NA DANFE"
			@ 034,005 SAY "________________________________________________________"
			@ 045,005 SAY "Mensagem  1 "
			@ 055,005 SAY "Mensagem  2 "
			@ 065,005 SAY "Mensagem  3 "
			@ 075,005 SAY "Mensagem  4 "
		Endif

		@ 005,050 GET _xTransp  Picture "@!" F3 "SA4" Valid Empty(_xTransp) .Or. VldTra() SIZE 040, 11
		@ 005,100 GET _xNomeTr  Picture "@!" When .F. SIZE 200, 11
		@ 015,050 GET _xMotori  Picture "@!" F3 "DA4" Valid Empty(_xMotori) .Or. VldMot() SIZE 040, 11
		@ 015,100 GET _xNomeMt  Picture "@!" When .t. SIZE 200, 11

		//If _cTipoNf == "I"
		//   @ 045, 050 GET _xMens1   When .T. SIZE 250, 11
		//   @ 055, 050 GET _xMens2   When .T. SIZE 250, 11
		//   @ 065, 050 GET _xMens3   When .T. SIZE 250, 11
		//   @ 075, 050 GET _xMens4   When .T. SIZE 250, 11
		//Else 
		@ 045,050 GET _xMens1   When .T. SIZE 250, 11
		@ 055,050 GET _xMens2   When .T. SIZE 250, 11
		@ 065,050 GET _xMens3   When .T. SIZE 250, 11
		@ 075,050 GET _xMens4   When .T. SIZE 250, 11
		//Endif

		@ 095,275 BMPBUTTON TYPE 1 ACTION Close(oDlg1)
		ACTIVATE DIALOG oDlg1 CENTERED

		DbSelectArea("SF1")
		RecLock("SF1",.F.)
		//SF1->F1_BASIMP1 := 0
		//SF1->F1_VALIMP5 := _nTValImp5
		//SF1->F1_VALIMP6 := _nTValImp6
		If _cTipoNF <> 'C'
			SF1->F1_TRANSP  := _xTransp
			SF1->F1_MOTORIS := _xMotori
			SF1->F1_NOMEMOT := _xNomeMt 
		Endif

		If _cTipoNf == "I"
			SF1->F1_MENCRD1 := _xMens1
			SF1->F1_MENCRD2 := _xMens2
			SF1->F1_MENCRD3 := _xMens3
			SF1->F1_MENCRD4 := _xMens4	
		Else
			SF1->F1_MENDFE1 := _xMens1
			SF1->F1_MENDFE2 := _xMens2
			SF1->F1_MENDFE3 := _xMens3
			SF1->F1_MENDFE4 := _xMens4
		Endif
		MsUnlock()
	Endif

	/*	
	SF3->(DbSetOrder(4))
	If SF3->(MsSeek(FWxFilial("SF3") + SF1->F1_FORNECE + SF1->F1_LOJA + SF1->F1_DOC + SF1->F1_SERIE, .f.) )
	RecLock("SF3",.F.)
	SF3->F3_ALQIMP5 := GetMv("ML_TXCOFIF")
	SF3->F3_VALIMP5 := _nTValImp5
	SF3->F3_BASIMP5 := SF1->F1_BASIMP5
	SF3->F3_ALQIMP6 := GetMv("ML_TXPISF")
	SF3->F3_VALIMP6 := _nTValImp6
	SF3->F3_BASIMP6 := SF1->F1_BASIMP6
	If AllTrim(SF3->F3_CFO) == "1949"
	SF3->F3_OBSERV := ""
	Endif
	MsUnLock()
	Endif
	*/  

	// Função que chama a janela de confirmação de NPR
	DlgNPR(_Executa,_cGerNPR)

	// Função que chama o tratamento para retenção do PIS, COFINS e CSLL
	RetImp()

	// Função que chama tela para vincular XML  
	//u_gjf121()

	DbSelectArea(_cAlias)

Return


//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³Efetua Consistencia no Transportador                          ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
Static Function VldTra()

	DbSelectArea("SA4")
	MsSeek(FWxFilial("SA4")+_xTransp)
	If Found()
		lVal     := .T.
		_xNomeTr := SA4->A4_NOME
	Else
		lVal := .F.
		FWAlertWarning("Transportador Invalido. Informe um Transportador Valido!","ATENÇÃO!")
	EndIf
Return lVal


//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³Efetua Consistencia no Motorista                              ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
Static Function VldMot()

	DbSelectArea("DA4")
	MsSeek(FWxFilial("DA4")+_xMotori)
	If Found()
		lVal     := .T.
		_xNomeMt := DA4->DA4_NOME
	Else
		lVal := .F.
		FWAlertWarning("Motorista Invalido. Informe um Motorista Valido!","ATENÇÃO!")
	EndIf

Return lVal 


//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//Caixa de Diálogo para a NPR                                    ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
Static Function DlgNPR(_Executa,_cGerNPR)

	_lNPR := .F.

	DbSelectArea("SD1")        // Vare os itens da NFE
	DbSetOrder(1)
	MsSeek(FWxFilial("SD1")+SF1->F1_DOC+SF1->F1_SERIE+SF1->F1_FORNECE+SF1->F1_LOJA)
	Do While !Eof() .And. SD1->D1_FILIAL+SD1->D1_DOC+SD1->D1_SERIE+SD1->D1_FORNECE+SD1->D1_LOJA == FWxFilial("SD1")+SF1->F1_DOC+SF1->F1_SERIE+SF1->F1_FORNECE+SF1->F1_LOJA
		If SD1->D1_TES $ "001/190/328"
			_lNPR := .T.
			Exit
		Else
			DbSkip()
		endif
	Enddo     

	// Tratamento para NPR
	If _lNPR
		If _Executa == "S" .And. _cGerNPR == "1"
			RecLock("SF1",.F.)
			SF1->F1_NPR := "S"
			MsUnlock()

			DbSelectArea("SE2")
			SE2->(DbSetOrder(6))
			SE2->(MsSeek(FWxFilial("SE2")+SF1->F1_FORNECE+SF1->F1_LOJA+SF1->F1_SERIE+SF1->F1_DOC))
			While SE2->(!Eof()) .And. SE2->E2_FILIAL+SE2->E2_FORNECE+SE2->E2_LOJA+SE2->E2_PREFIXO+SE2->E2_NUM == FWxFilial("SE2")+SF1->F1_FORNECE+SF1->F1_LOJA+SF1->F1_SERIE+SF1->F1_DOC
				Reclock("SE2",.F.)
				SE2->E2_NPR := "S"
				MsUnlock()      
				SE2->(DbSkip())
			Enddo
		Endif
	Endif    

Return


//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³Rotina que fará a retenção de PIS, COFINS e CSLL acumulada ³
//³nas NFs de entrada com valor menor de R$ 5.000, 00         ³
//³(Lei 11.925)                                               ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
Static Function RetImp() 

	DbSelectArea("SE2")
	SE2->(DbSetOrder(1))
	SE2->(MsSeek(FWxFilial("SE2") + SF1->F1_SERIE + SF1->F1_DOC))
	While SE2->(!Eof()) .And. SE2->E2_FILIAL + SE2->E2_PREFIXO + SE2->E2_NUM == FWxFilial("SE2") + SF1->F1_SERIE + SF1->F1_DOC
		If SF1->F1_FORNECE + SF1->F1_LOJA <> Substr(SE2->E2_TITPAI,18,8) 
			SE2->(DbSkip())
			Loop
		Endif

		If SE2->E2_TIPO <> "TX" 
			SE2->(DbSkip())
			Loop
		Endif  

		Reclock("SF1",.F.)
		If SE2->E2_NATUREZ == "120309"
			SF1->F1_FRETPIS := SE2->E2_VALOR
		ElseIf SE2->E2_NATUREZ == "120311"
			SF1->F1_FRETCOF := SE2->E2_VALOR  
		ElseIf SE2->E2_NATUREZ == "120312"
			SF1->F1_FRETCSL := SE2->E2_VALOR
		Endif  
		MsUnlock()

		SE2->(DbSkip())
	Enddo

Return
