#INCLUDE "FINR170.CH"
#INCLUDE "PROTHEUS.CH"

/*ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±ÀÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
Relatorio de Bordero alterado e customizado por Giuliano Forgiarini
29/04/2009 - Modulo Financeiro
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/
User Function gFi170() 

	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Define Variaveis                                             ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	Local cDesc1  := STR0001  //"Este programa tem a fun‡„o de emitir os borderos de cobran‡a"
	Local cDesc2  := STR0002  //"ou pagamentos gerados pelo usuario."
	Local cDesc3  := ""
	Local wnrel
	Local tamanho := "P"
	Local cString := "SEA"
	Local nOpca	  := 0
	Local nI := 0
	Local nCount := 0

	Private cabec1
	Private cabec2
	Private titulo   := STR0006  //"Emiss„o de Borderos"
	Private aReturn  := { OemToAnsi(STR0007), 1,OemToAnsi(STR0008), 2, 2, 1, "",1 }  //"Zebrado"###"Administracao"
	Private nomeprog := "FINR170"
	Private aLinha   := { },nLastKey := 0
	Private cPerg    := "FIN170"
	Private cComple1 := Space(79)
	Private cComple2 := Space(79)
	Private cComple3 := Space(79)

	pergunte("FIN170",.F.)

	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Variaveis utilizadas para parametros                        ³
	//³ mv_par01        	// Carteira (R/P)                          ³
	//³ mv_par02        	// Numero do Bordero Inicial               ³
	//³ mv_par03        	// Numero do Bordero Final                 ³
	//³ mv_par04        	// considera filial                        ³
	//³ mv_par05        	// da filial                               ³
	//³ mv_par06        	// ate a filial                            ³
	//³ mv_par07        	// moeda                                   ³
	//³ mv_par08        	// imprime outras moedas                   ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Envia controle para a funcao SETPRINT                        ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	wnrel := "FINR170"            //Nome Default do relatorio em Disco
	wnrel := SetPrint(cString,wnrel,cPerg,@titulo,cDesc1,cDesc2,cDesc3,.F.,"",,Tamanho)

	If nLastKey == 27
		Return
	EndIf

	SetDefault(aReturn,cString)

	If nLastKey == 27
		Return
	EndIf

	DEFINE MSDIALOG oDlg FROM  92,70 TO 221,463 TITLE OemToAnsi(STR0009) PIXEL  //  "Mensagem Complementar"
	@ 09, 02 SAY STR0036 SIZE 24, 7 OF oDlg PIXEL  //"Linha 1"
	@ 24, 02 SAY STR0037 SIZE 25, 7 OF oDlg PIXEL  //"Linha 2"
	@ 38, 03 SAY STR0038 SIZE 25, 7 OF oDlg PIXEL  //"Linha 3"
	@ 07, 31 MSGET cComple1 Picture "@S48" SIZE 163, 10 OF oDlg PIXEL
	@ 21, 31 MSGET cComple2 Picture "@S48" SIZE 163, 10 OF oDlg PIXEL
	@ 36, 31 MSGET cComple3 Picture "@S48" SIZE 163, 10 OF oDlg PIXEL

	DEFINE SBUTTON FROM 50, 139 TYPE 1 ENABLE OF oDlg ACTION (nOpca:=1,oDlg:End())
	DEFINE SBUTTON FROM 50, 167 TYPE 2 ENABLE OF oDlg ACTION oDlg:End()

	ACTIVATE MSDIALOG oDlg CENTERED

	If nOpca#1
		cComple1 := ""
		cComple2 := ""
		cComple3 := ""
	EndIf

	RptStatus({|lEnd| Fa170Imp(@lEnd,wnRel,cString)},Titulo)
Return

/*ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o    ³ FA170Imp ³ Autor ³ Wagner Xavier         ³ Data ³ 05.10.92 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³ Rela‡„o de Borderos para cobranca / pagamentos             ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe e ³ FA170Imp(lEnd,wnRel,cString)                               ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³ lEnd     -  A‡Æo do CodeBlock                              ³±±
±±³          ³ wnRel    -  T¡tulo do relat¢rio                            ³±±
±±³          ³ cString  -  Mensagem                                       ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ Generico                                                   ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/
Static Function FA170Imp(lEnd,wnRel,cString)

	Local cCodigo,cNome,nValor:=0,nValTot:=0,dVencto
	Local nContador := 0
	Local cbcont,CbTxt
	Local nAbat     := 0
	Local cLoja            
	Local cFilDe,cFilAte
	Local nRegEmp   := SM0->(RecNo())
	Local aTam      := TAMSX3("E1_CLIENTE")
	Local aColu     := {}
	Local ndecs     := Msdecimais(mv_par07)
	Local cCampo    := If(mv_par01==1,"E1_PARCELA","E2_PARCELA")
	Local cChave
	Local cCampoSea := "SEA->EA_FILIAL"  


	Local cCondWhile:= ""
	Local nRecno := 0 
	Local lAchou := .F.
	Local cNumCheque  := ""
	Local lMostraChq  := .F.
	Local nFiltro := 0
	Local cChaveAnt := ""
	Local lUltRodape := .F.
	#IFDEF TOP
	Local aStru     := SEA->(dbStruct())
	Local nI  := 0
	Local cOrder    := ""
	#ELSE
	Local lAchouFil := .F.
	#ENDIF

	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Variaveis utilizadas para Impressao do Cabecalho e Rodape    ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	cbtxt    := SPACE(10)
	cbcont   := 0
	li       := 80
	m_pag    := 1

	If Empty(mv_par02)
		If Empty(mv_par03)
			//sem filtro de Numero de Bordero
			nFiltro := 0
		Else
			//Ate o Bornero Y
			nFiltro := 3	
		EndIf
	Else
		If Empty(mv_par03)
			//Iniciando no Bordero N
			nFiltro := 1
		Else
			//Iniciando no Bordero N ate o Bordero Y
			nFiltro := 2
		EndIf
	EndIf
	nContador := 0

	dbSelectArea("SEA")
	dbSetOrder(1)

	#IFDEF TOP

	cOrder := SqlOrder(IndexKey())
	cQuery := "SELECT * "
	cQuery += "  FROM "+	RetSqlName("SEA")
	cQuery += " WHERE " 

	If mv_par04 == 2 // Somente filial corrente
		cQuery += "EA_FILIAL = '"+ xFilial("SEA") + "' AND "
	Else
		cQuery += "EA_FILIAL Between '" + mv_par05 + "' AND '" + mv_par06 + "' AND "
	Endif

	If nFiltro # 0
		Do Case
			Case nFiltro == 1
			cQuery += "EA_NUMBOR >= '" + mv_par02 + "' AND "			
			Case nFiltro == 2
			cQuery += "EA_NUMBOR >= '" + mv_par02 + "' AND "
			cQuery += "EA_NUMBOR <= '" + mv_par03 + "' AND "
			Case nFiltro == 3
			cQuery += "EA_NUMBOR <= '" + mv_par03 + "' AND "
		EndCase
	Endif

	If mv_par01 == 1
		cQuery += "EA_CART = 'R' AND "
	EndIf

	If mv_par01 == 2
		cQuery += "EA_CART = 'P' AND "
	EndIf   

	cQuery += "EA_TIPO NOT IN ('" + MV_CRNEG + "','" + MV_CPNEG + "','" + MVABATIM + "')  AND "    
	cQuery += "D_E_L_E_T_ <> '*' "   

	cQuery += " ORDER BY " + cOrder
	cQuery := ChangeQuery(cQuery)

	dbSelectArea("SEA")
	dbCloseArea()
	dbUseArea(.T., "TOPCONN", TCGenQry(,,cQuery), 'SEA', .F., .T.)

	For ni := 1 to Len(aStru)
		If aStru[ni,2] != 'C'
			TCSetField('SEA', aStru[ni,1], aStru[ni,2],aStru[ni,3],aStru[ni,4])
		Endif
	Next 

	dbSelectArea("SEA")
	dbGotop()
	If EOF() .AND. BOF()
		DbCloseArea()
		ChkFile("SEA")
		dbSetOrder(1)
		Return
	Endif

	#ENDIF	

	SetRegua(RecCount())

	If mv_par04 == 1
		cFilDe  := mv_par05
		cFilAte := mv_par06
	Else
		cFilDe  := cFilAnt
		cFilAte := cFilAnt
	EndIf

	dbSelectArea("SM0")
	dbSeek(cEmpAnt+cFilDe,.T.)

	aColu := IIF (aTam[1] > 6,;
	TamParcela(cCampo,{040,041,066,067,077,079,095},;
	{041,042,067,068,078,080,096},;
	{042,043,068,069,079,081,097}),;							
	TamParcela(cCampo,{026,027,052,053,063,065,079},;
	{027,028,053,054,064,066,080},;
	{028,029,054,055,065,067,081}))

	While !Eof() .and. M0_CODIGO == cEmpAnt .and. M0_CODFIL <= cFilAte
		cFilAnt := M0_CODFIL		// Mudar filial atual temporariamente

		dbSelectArea("SEA")

		#IFNDEF TOP
		Set Softseek On
		dbSeek(cFilAnt+IIf(nFiltro==1 .Or. nFiltro == 2, mv_par02,""))
		Set SoftSeek Off
		If EOF()
			DbSelectArea("SM0")
			DbSkip()
			Loop
		Else
			lAchouFil := .T.
		EndIf
		#ENDIF     

		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³ Existe a possibilidade ser gerado um bordero para varias     ³
		//³ filiais                                                      ³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ

		#IFDEF TOP
		If nFiltro # 0
			Do Case
				Case nFiltro == 1
				cCondWhile := "EA_NUMBOR >= mv_par02"
				Case nFiltro == 2
				cCondWhile := "(EA_NUMBOR >= mv_par02 .And. "
				cCondWhile += "EA_NUMBOR <= mv_par03)"
				Case nFiltro == 3
				cCondWhile := "EA_NUMBOR <= mv_par03"
			EndCase
		Else
			cCondWhile:=".T."
		Endif
		#ELSE
		If nFiltro # 0
			Do Case
				Case nFiltro == 1
				cCondWhile := "EA_NUMBOR >= mv_par02"
				Case nFiltro == 2
				cCondWhile := "(EA_NUMBOR >= mv_par02 .And. "
				cCondWhile += "EA_NUMBOR <= mv_par03)"
				Case nFiltro == 3
				cCondWhile := "EA_NUMBOR <= mv_par03"
			EndCase
		Else
			cCondWhile:=".T."			
		Endif
		cCondWhile += " .and. EA_FILIAL == xFilial()"
		#ENDIF				 

		While !Eof() .And. &(cCondWhile)

			If ( lEnd )
				@Prow()+1,001 PSAY OemToAnsi(STR0010)  //"CANCELADO PELO OPERADOR"
				Exit
			EndIf

			IncRegua()

			If ( Empty(EA_NUMBOR) )
				dbSkip()
				Loop
			EndIf

			If ( mv_par01 == 1 .and. EA_CART = "P" )
				dbSkip()
				Loop
			EndIf

			If ( mv_par01 == 2 .and. EA_CART = "R" )
				dbSkip()
				Loop
			EndIf

			If SEA->EA_TIPO $ MV_CRNEG+"/"+MV_CPNEG+"/"+MVABATIM
				dbSkip()
				Loop
			Endif	

			lAchou := .F.
			If ( mv_par01 == 1 )
				If Empty(SEA->EA_FILORIG) .AND. !Empty(xFilial("SE1"))
					cChave 	 := xFilial("SE1")+SEA->EA_NUMBOR
				Else
					cChave 	 := SEA->(EA_FILORIG+EA_NUMBOR)
					cCampoSea := "SEA->EA_FILORIG"
				Endif	

				// posiciono no titulo ORIGINAL (principal com tipo)
				dbSelectArea( "SE1" )
				dbSeek( cChave )
				While !Eof() .and. SE1->(E1_FILIAL+E1_PREFIXO+E1_NUM+E1_PARCELA+E1_TIPO) == cChave+SEA->EA_TIPO
					If SE1->E1_NUMBOR == SEA->EA_NUMBOR
						lAchou := .T.
						Exit
					Else
						dbSkip()
					Endif
				Enddo
				//Caso não tenha achado titulo no SE1, desconsidera para o bordero
				If !lAchou
					dbSelectArea("SEA")
					dbSkip()
					Loop
				Endif			
				nValor:= xMoeda(SE1->E1_SALDO+SE1->E1_SDACRES-SE1->E1_SDDECRE,SE1->E1_MOEDA,mv_par07,,ndecs+1)
				dVencto:= E1_VENCTO
				cCodigo:= E1_CLIENTE
				cLoja	 := E1_LOJA
				If cPaisLoc == "PAR" .And. FieldPos("E1_NUMCHQ") > 0 .And. AllTrim(E1_ORIGEM) == "LOJA010"			   
					cNumCheque  := E1_NUMCHQ
					lMostraChq  := .T.
				EndIf   			
				nRecno := Recno()
				dbSelectArea( "SA1" )
				dbSeek(cFilial+cCodigo+cLoja)
				cNome  := SubStr(A1_NOME,1,25)
				dbSelectArea("SEA")
				If !(SEA->EA_TIPO $ MV_CRNEG+"/"+MVABATIM)
					// procura pelos abatimentos do titulo (sem tipo, para pegar todos)
					dbSelectArea("SE1")
					dbSeek( cChave )
					While !Eof() .and. &cCampoSea+SEA->(EA_PREFIXO+EA_NUM+EA_PARCELA)==SE1->E1_FILIAL+SE1->E1_PREFIXO+SE1->E1_NUM+SE1->E1_PARCELA
						//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
						//³ Verifica se deve imprimir outras moedas³
						//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
						If mv_par08 == 2 // nao imprime
							If SE1->E1_MOEDA != mv_par07 //verifica moeda do campo=moeda parametro
								dbSkip()
								Loop
							Endif	
						Endif

						If SE1->(E1_CLIENTE+E1_LOJA) != cCodigo+cLoja
							dbSkip()
							Loop
						Endif					

						If SE1->E1_TIPO $ MV_CRNEG+"/"+MVABATIM
							nAbat += xMoeda(SE1->E1_SALDO,SE1->E1_MOEDA,mv_par07,,ndecs+1)
						Endif
						dbSkip()
					Enddo
				Endif
			Else
				If Empty(SEA->EA_FILORIG) .AND. !Empty(xFilial("SE2"))
					cChave 	 := xFilial("SE2")+SEA->(EA_PREFIXO+EA_NUM+EA_PARCELA)
				Else
					cChave 	 := SEA->(EA_FILORIG+EA_PREFIXO+EA_NUM+EA_PARCELA)
					cCampoSea := "SEA->EA_FILORIG"
				Endif	
				cLoja := Iif ( Empty(SEA->EA_LOJA) , "" , SEA->EA_LOJA )
				dbSelectArea( "SE2" )
				dbSeek(cChave+SEA->EA_TIPO+SEA->EA_FORNECE + cLoja )
				While !Eof() .and. SE2->(E2_FILIAL+E2_PREFIXO+E2_NUM+E2_PARCELA+E2_TIPO+E2_FORNECE+E2_LOJA) == ;
				cChave+SEA->(EA_TIPO+EA_FORNECE+EA_LOJA)
					If SE2->E2_NUMBOR == SEA->EA_NUMBOR
						lAchou := .T.
						Exit
					Else
						dbSkip()
					Endif
				Enddo
				//Caso não tenha achado titulo no SE1, desconsidera para o bordero
				If !lAchou
					dbSelectArea("SEA")
					dbSkip()
					Loop
				Endif			
				nValor:=xMoeda(SE2->E2_SALDO+SE2->E2_SDACRES-SE2->E2_SDDECRE,SE2->E2_MOEDA,mv_par07,,ndecs+1)
				dVencto:=E2_VENCTO
				cCodigo:=E2_FORNECE
				nRecno := Recno()
				dbSelectArea( "SA2" )
				dbSeek(xFilial("SA2")+cCodigo+cLoja)
				cNome  :=SubStr(A2_NOME,1,25)
				dbSelectArea("SEA")
				If !(SEA->EA_TIPO $ MV_CPNEG+"/"+MVABATIM)
					// procura pelos abatimentos do titulo (sem tipo, para pegar todos)
					dbSelectArea("SE2")
					dbSeek( cChave )
					While !Eof() .and. &cCampoSea+SEA->(EA_PREFIXO+EA_NUM+EA_PARCELA)==SE2->E2_FILIAL+SE2->E2_PREFIXO+SE2->E2_NUM+SE2->E2_PARCELA
						//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
						//³ Verifica se deve imprimir outras moedas³
						//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
						If mv_par08 == 2 // nao imprime
							If SE2->E2_MOEDA != mv_par07 //verifica moeda do campo=moeda parametro
								dbSkip()
								Loop
							Endif	
						Endif

						If SE2->E2_TIPO $ MV_CPNEG+"/"+MVABATIM .AND. SEA->EA_FORNECE==SE2->E2_FORNECE
							nAbat += xMoeda(SE2->E2_SALDO,SE2->E2_MOEDA,mv_par07,,ndecs+1)
						Endif
						dbSkip()
					Enddo
				Endif
			EndIf
			// volta ao titulo ORIGINAL (principal com tipo)
			dbSelectArea(IIF(mv_par08 == 1, "SE1","SE2"))
			dbGoTo(nRecno)
			dbSelectArea( "SEA" )
			If  nValor > 0
				If ( li > 55 )  .Or. cChaveAnt#SEA->EA_FILIAL+SEA->EA_NUMBOR
					If cChaveAnt==SEA->EA_FILIAL+SEA->EA_NUMBOR//( m_pag != 1 )
						li++
						@li, 0 PSAY REPLICATE("-",IIf(aTam[1] > 6,TamParcela(cCampo,96,97,98),TamParcela(cCampo,81,82,83)))
					EndIf
					If cChaveAnt#SEA->EA_FILIAL+SEA->EA_NUMBOR .And. !Empty(cChaveAnt)
						F170Rodape(SM0->M0_NOMECOM, nValTot, aTam, cCampo, li, aColu, nContador)
						lUltRodape := .F.
						nValTot:=0
						nContador:=0
					EndIf
					li++
					li++				
					fr170cabec(lMostraChq, cChaveAnt#SEA->EA_FILIAL+SEA->EA_NUMBOR)
					lUltRodape := .T.
					m_pag++
					cChaveAnt:=SEA->EA_FILIAL+SEA->EA_NUMBOR
				EndIf
				li++
				@li, 0 PSAY "|"
				If lMostraChq
					@li, 1 PSAY cNumCheque
				Else			
					@li, 1 PSAY EA_PREFIXO
					@li, 5 PSAY EA_NUM
				EndIf   
				@li,17 PSAY "|"
				@li,18 PSAY TamParcela(cCampo,Left(EA_PARCELA,1),Left(EA_PARCELA,2),Left(EA_PARCELA,3))
				@li,TamParcela(cCampo,19,20,21) PSAY "|"
				@li,TamParcela(cCampo,20,21,22) PSAY cCodigo
				@li,aColu[1] PSAY "|"
				@li,aColu[2] PSAY cNome
				@li,aColu[3] PSAY "|"
				@li,aColu[4] PSAY dVencto
				@li,aColu[5] PSAY "|"
				@li,aColu[6] PSAY (nValor - nAbat) Picture PesqPict("SE1","E1_VALOR",14,MV_PAR07)
				@li,aColu[7] PSAY "|"
				nValTot += nValor - nAbat
				nContador ++
				nAbat := 0
			EndIf
			dbSkip()
		EndDo
		#IFDEF TOP
		Exit
		#ELSE		
		If Empty(xFilial("SEA"))
			Exit
		Endif
		dbSelectArea("SM0")
		dbSkip()
		#ENDIF	
	Enddo

	SM0->(dbGoto(nRegEmp))
	cFilAnt := SM0->M0_CODFIL

	If lUltRodape
		F170Rodape(SM0->M0_NOMECOM, nValTot, aTam, cCampo, li, aColu, nContador)
	EndIf

	#IFDEF TOP
	dbSelectArea("SEA")
	DbCloseArea()
	chkfile("SEA")
	#ENDIF

	#IFNDEF TOP
	If !lAchouFil
		Set Device to Screen
		Help(" ",1,"NOBORDERO")
		SM0->(dbGoto(nRegEmp))
		cFilAnt := SM0->M0_CODFIL
		dbSelectArea("SEA")
		dbSetOrder(1)
		Set Filter to
		Return
	Endif
	#ENDIF

	Set Device To Screen
	dbSelectArea("SE1")
	dbSetOrder(22)
	Set Filter To

	If aReturn[5] = 1
		Set Printer To
		dbCommit()
		Ourspool(wnrel)
	EndIf
	MS_FLUSH()

/*ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o    ³fr170cabec³ Autor ³ Wagner Xavier         ³ Data ³ 24.05.93 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³ Cabecalho do Bordero                                       ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe e ³fr170cabec()                                                ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³                                                            ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ Generico                                                   ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/
Static Function fr170cabec(lMostraChq, lNew)

	Local aDriver := ReadDriver()
	Local lWin    := .f.
	Local lFirst  := .T.
	Local nChar   := IIF(aReturn[4]==1,GetMv("MV_COMP"),GetMv("MV_NORM"))
	Local aTam    := TAMSX3("E1_CLIENTE")
	Local cCampo  := If(mv_par01==1,"E1_PARCELA","E2_PARCELA")

	If m_pag == 1

		If TYPE("__DRIVER") == "C"
			If "DEFAULT"$__DRIVER
				lWin := .T.
			EndIf
		EndIf
		nLargura:=080

		If GetMv("MV_SALTPAG",,"S") == "N"
			Setprc(0,0)
		EndIf 

		If nChar == NIL .and. !lWin .and. __cInternet == Nil
			@ 0,0 PSAY &(aDriver[3])
		ElseIf !lWin .and. __cInternet == Nil
			If nChar == 15
				@ 0,0 PSAY &(aDriver[3])
			Else
				@ 0,0 PSAY &(aDriver[4])
			EndIf
		EndIf

		dbSelectArea("SA6")
		dbSeek(cFilial+SEA->EA_PORTADO+SEA->EA_AGEDEP+SEA->EA_NUMCON)
	Endif 

	@ 1,00 PSAY __PrtfatLine()
	@ 2,00 PSAY __PrtLogo()
	@ 3,00 PSAY __PrtfatLine()

	If lNew
		@ 5, 0 PSAY __PrtLeft(OemToAnsi(STR0024)+SA6->A6_NOME) //"AO "
		@ 6, 0 PSAY __PrtLeft(OemToAnsi(STR0016)+SA6->A6_AGENCIA + OemToAnsi(STR0017)+SEA->EA_NUMCON)  // "AGENCIA "###" C/C "
		@ 7, 0 PSAY __PrtLeft(ALLTRIM(SA6->A6_BAIRRO)+" - "+ALLTRIM(SA6->A6_MUN)+" - "+ALLTRIM(SA6->A6_EST))
		@ 8, 0 PSAY __PrtLeft(OemToAnsi(STR0018)+SEA->EA_NUMBOR)  //"BORDERO NRO "
		If mv_par01 == 1
			@ 9, 0 PSAY __PrtLeft(OemToAnsi(STR0019))  //"Solicitamos proceder o recebimento das duplicatas abaixo relacionadas"
			@10, 0 PSAY __PrtLeft(OemToAnsi(STR0020))  //"CREDITANDO-NOS os valores correspondentes."
		Else
			@ 9, 0 PSAY __PrtLeft(OemToAnsi(STR0021))  //"Solicitamos proceder o pagamento das duplicatas abaixo relacionadas"
			@10, 0 PSAY __PrtLeft(OemToAnsi(STR0022))  //"DEBITANDO-NOS os valores correspondentes."
		EndIf
		li:=11
		If ( !Empty ( cComple1 ) )
			@li++, 0 PSAY __PrtLeft(cComple1)
		EndIf
		If	( !Empty ( cComple2 ) )
			@li++, 0 PSAY __PrtLeft(cComple2)
		EndIf
		If !Empty ( cComple3 )
			@li++ , 0 PSAY __PrtLeft(cComple3)
		EndIf
		li+=2
	Else
		li:=5
	EndIf
	@li, 0 PSAY REPLICATE("-",IIf(aTam[1] > 6 , TamParcela(cCampo,96,97,98), TamParcela(cCampo,79,80,81)))
	li++
	If lMostraChq
		@li, 0 PSAY "|"+IIf(aTam[1] > 6,TamParcela(cCampo,STR0031,STR0034,STR0035),TamParcela(cCampo,STR0030,STR0032,STR0033))  //"NUM CHEQUE      |P|CODIGO|R A Z A O   S O C I A L  | VENCTO   |         VALOR |"		
	Else
		@li, 0 PSAY "|"+IIf(aTam[1] > 6,TamParcela(cCampo,STR0025,STR0028,STR0029),TamParcela(cCampo,STR0023,STR0026,STR0027))  //"NUM DUPLIC      |P|CODIGO|R A Z A O   S O C I A L  | VENCTO |         VALOR   |"
	EndIf   
	li++
	@li, 0 PSAY "|"+REPLICATE("-",IIF(aTam[1]>6,TamParcela(cCampo,94,95,96),TamParcela(cCampo,78,79,80)))+"|"
	dbSelectArea( "SEA" )
Return .T.

/*ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o    ³fr170cabec³ Autor ³ Adilson H Yamaguchi   ³ Data ³ 09.05.05 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³ Rodape                                                     ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe e ³f170Rodape()                                                ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³                                                            ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ Generico                                                   ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/
Static Function F170Rodape(cEmpresa, nValTot, aTam, cCampo, li, aColu, nContador)
	If ( nValTot != 0 )
		While ( li <= 49 .and. nValTot != 0 )
			li++
			@li, 0 PSAY "|"
			@li,17 PSAY "|"
			@li,TamParcela(cCampo,19,20,21) PSAY "|"
			@li,aColu[1] PSAY "|"
			@li,aColu[3] PSAY "|"
			@li,aColu[5] PSAY "|"
			@li,aColu[7] PSAY "|"
		Enddo
		li++
		@li, 0 PSAY "|"+REPLICATE("-",IIF(aTam[1]>6,TamParcela(cCampo,94,95,96),TamParcela(cCampo,78,79,80)))+"|"
		li++
		If mv_par01 == 1
			@li, 0 PSAY OemToAnsi(STR0011)+IIF(aTam[1]>6,Space(14),"")+TamParcela(cCampo,"|"," |","  |")+;
			Transform(nValTot,PesqPict("SE1","E1_VALOR",15,MV_PAR07))+IIF(aTam[1]>6,"  |", "|")  //"@E 9999,999,999.99")+"|"  //"|   TOTAL DA RELACAO A CREDITO DE NOSSA CONTA CORRENTE       "
		Else
			@li, 0 PSAY OemToAnsi(STR0012)+IIF(aTam[1]>6,Space(14),"")+TamParcela(cCampo,"|"," |","  |")+;
			Transform(nValTot,PesqPict("SE1","E1_VALOR",15,MV_PAR07))+IIF(aTam[1]>6,"  |", "|")			//Transform(nValTot,"@E 9999,999,999.99")+"|"  //"|   TOTAL DA RELACAO A DEBITO DE NOSSA CONTA CORRENTE        "
		EndIf
		li ++

		@li, 0 PSAY OemToAnsi(STR0013)+IIF(aTam[1]>6,Space(14),"")+TamParcela(cCampo,"|"," |","  |")  //"|   QUANTIDADE  DE TITULOS IMPRESSOS                         "
		@li, aColu[6] PSAY nContador PICTURE "@E 99999999999999"
		@li, aColu[7] PSAY "|"

		li++
		@li, 0 PSAY "|"+REPLICATE("-",iif(aTam[1]>6,TamParcela(cCampo,94,95,96),TamParcela(cCampo,78,79,80)))+"|"
		li+=2
		@li, 0 PSAY OemToAnsi(STR0014) + DTOC(dDataBase)  //"Data: "
		@li,35 PSAY OemToAnsi(STR0015)  //"Atenciosamente"
		li+=1
		@li,35 PSAY cEmpresa
		li+=2
		@li,35 PSAY REPLICATE("-",Len(Trim(cEmpresa)))
		li++
		@li,0  PSAY " "
	EndIf 
Return .T.
