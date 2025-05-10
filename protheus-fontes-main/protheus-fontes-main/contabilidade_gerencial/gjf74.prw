#INCLUDE "CTBR110.Ch"
#INCLUDE "PROTHEUS.Ch"
/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o    ³ GJF74  ³ Autor ³ Giuliano Forgiraini³ Data ³ 28.01.09    ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³ Diario Geral                                               ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³ CTBR110(void)                                              ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Retorno   ³ modificação da rotina CTBR110 - esperamos que de certo     ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ Generico                                                   ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³ Nenhum                                                     ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
User Function GJF74()

	Local WnRel
	Local aCtbMoeda:={}

	LOCAL cString	:= "CT2"
	LOCAL cDesc1 	:= OemToAnsi(STR0001)  //"Este programa ir  imprimir o Di rio Geral Modelo 1, de acordo"
	LOCAL cDesc2 	:= OemToAnsi(STR0002)  //"com os parƒmetros sugeridos pelo usuario. Este modelo e ideal"
	LOCAL cDesc3	:= OemToAnsi(STR0003)  //"para Plano de Contas que possuam codigos nao muito extensos"

	Local Titulo 	:= OemToAnsi(STR0006)				// Emissao do Diario Geral
	Local lRet		:= .T.  
	Local nQuadro	:= 0 

	PRIVATE Tamanho	:= "M"
	PRIVATE aLinha  	:= { }
	PRIVATE aReturn 	:= { OemToAnsi(STR0004), 1,OemToAnsi(STR0005), 2, 2, 1, "",1 }  //"Zebrado"###"Administracao"

	PRIVATE cPerg   	:= "CTR110"
	PRIVATE nomeprog	:= "CTBR110"
	PRIVATE nLastKey	:= 0


	If ( !AMIIn(34) )		// Acesso somente pelo SIGACTB
		Return
	EndIf

	wnrel :="CTBR110"

	CTR110SX1()

	Pergunte("CTR110",.F.)

	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Variaveis utilizadas para parametros                         ³
	//³ mv_par01  	      	// Data Inicial                          ³
	//³ mv_par02            // Data Final                            ³
	//³ mv_par03            // Moeda?                                ³
	//³ mv_par04				// Set Of Books				    		     ³
	//³ mv_par05				// Tipo Lcto? Real / Orcad / Gerenc / Pre³
	//³ mv_par06  	      	// Pagina Inicial                        ³
	//³ mv_par07         	// Pagina Final                          ³
	//³ mv_par08         	// Pagina ao Reiniciar                   ³
	//³ mv_par09         	// So Livro/Livro e Termos/So Termos     ³
	//³ mv_par10         	// Imprime Balancete                     ³
	//³ mv_par11         	// Imprime Plano de contas               ³ 
	//³ mv_par12         	// Imprime Valor 0.00	                 ³
	//³ mv_par13         	// Impr Cod(Normal/Reduz/Cod.Impressao)  ³ /// CT1_CODIMP
	//³ mv_par14            // Num.linhas p/ o diario?				 ³ 
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	wnrel := SetPrint(cString,wnrel,cPerg,@titulo,cDesc1,cDesc2,cDesc3,.F.,"",,Tamanho)

	If nLastKey = 27
		Set Filter To
		Return
	Endif

	Private aQuadro := { "","","","","","","",""}              

	For nQuadro :=1 To Len(aQuadro)
		aQuadro[nQuadro] := Space(Len(CriaVar("CT1_CONTA")))
	Next	

	CtbCarTxt()


	If mv_par10 = 1
		Pergunte("CTR040",.T.)
		Pergunte("CTR110",.F.)	
	Endif

	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Verifica se usa Set Of Books + Plano Gerencial (Se usar Plano³
	//³ Gerencial -> montagem especifica para impressao)		     ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	If !ct040Valid(mv_par04)
		lRet := .F.
	Else
		aSetOfBook := CTBSetOf(mv_par04)
	EndIf

	If lRet
		aCtbMoeda	:= CtbMoeda(mv_par03)
		If Empty(aCtbMoeda[1])
			Help(" ",1,"NOMOEDA")
			lRet := .F.
		EndIf	
	EndIf

	If !lRet	
		Set Filter To
		Return
	EndIf

	SetDefault(aReturn,cString)

	If nLastKey = 27
		Set Filter To
		Return
	Endif

	RptStatus({|lEnd| CTR110Imp(@lEnd,wnRel,cString,aSetOfBook,aCtbMoeda)})
Return 

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³ Fun‡…o    ³CTR110IMP ³ Autor ³ Pilar S. Albaladejo   ³ Data ³ 10/11/00 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Descri‡…o ³ Impressao do Diario Geral                                  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Sintaxe   ³ CTR110Imp(lEnd,wnRel,cString,aSetOfBook,aCebMoeda)         ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Retorno   ³ Nenhum                                                     ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso       ³ SIGACTB                                                    ³±±
±±ÅÄÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÅ±±
±±³Parametros ³ ExpL1   - A‡ao do Codeblock                                ³±±
±±³           ³ ExpC1   - T¡tulo do relat¢rio                              ³±±
±±³           ³ ExpC2   - Mensagem                                         ³±±
±±³           ³ ExpA1   - Matriz ref. Config. Relatorio                    ³±±
±±³           ³ ExpA2   - Matriz ref. a moeda                              ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Static Function GJF74Imp(lEnd,WnRel,cString,aSetOfBook,aCtbMoeda)
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Define Variaveis                                             ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	Local CbTxt
	Local Cbcont
	Local Cabec1		:= OemToAnsi("            C O N T A                     H I S T O R I C O                        NUMERO                         V  A  L  O  R")
	Local Cabec2		:= OemToAnsi("D E B I T O          C R E D I T O                                                 LANCTO                      DEBITO        CREDITO")
	Local Titulo		:= ""

	Local cPicture
	Local cDescMoeda
	Local cSeparador	:= ""
	Local cMascara
	Local cLote			:= ""
	Local cSubLote		:= ""
	Local cDoc			:= ""
	Local cCancel		:= OemToAnsi(STR0012)

	Local dData			:= Ctod("")
	Local dDataFim		:= mv_par02

	Local lData			:= .T.
	Local lFirst		:= .T.
	Local lImpLivro	:= .T.
	Local lImpTermos	:= .F.								
	Local	lPrintZero	:= Iif(mv_par12 == 1,.T.,.F.)
	Local nTotDiaD		:= 0
	Local nTotDiaC		:= 0
	Local nTotMesD		:= 0
	Local nTotMesC		:= 0
	Local nTotDeb		:= 0
	Local nTotCred	 	:= 0
	Local nDia
	Local nMes
	Local nTamDeb		:= 15			// Tamanho da coluna de DEBITO
	Local nTamCrd		:= 14			// Tamanho da coluna de CREDITO
	Local nRecCT2		:= 0
	Local nColDeb		:= 102			// Coluna de impressao do DEBITO
	Local nColCrd		:= 118			// Coluna de impressao do CREDITO

	Local bPular		:= { || 	CT2->CT2_MOEDLC <> cMoeda .Or.;                    
	CT2->CT2_VALOR = 0 .Or.;
	(CT2->CT2_TPSALD # mv_par05 .And. mv_par05 # "*") }
	Local cFilCT1		:= xFilial("CT1")
	Local cSeqLan		:= ""
	Local cSeqHis		:= ""
	Local cEmpOri		:= ""
	Local cFilOri		:= ""
	Local nPagIni		:= mv_par06
	Local nPagFim		:= mv_par07
	Local nReinicia		:= mv_par08
	Local nBloco		:= 0
	Local nBlCount		:= 0
	Local i
	Local l1StQb		:= .T.
	Local lEmissUnica	:= If(GetNewPar("MV_CTBQBPG","M") == "M",.T.,.F.)			/// U=Quebra única (.F.) ; M=Multiplas quebras (.T.)
	Local lNewPAGFIM	:= If(nReinicia > nPagFim,.T.,.F.)
	Local nMaxLin   	:= mv_par14
	Local LIMITE		:= If(TAMANHO=="G",220,If(TAMANHO=="M",132,80))
	Local nInutLin		:= 1

	If lEmissUnica
		m_pag    := 1
		CtbQbPg(.T.,@nPagIni,@nPagFim,@nReinicia,@m_pag,@nBloco,@nBlCount)		/// FUNCAO PARA TRATAMENTO DA QUEBRA //.T. INICIALIZA VARIAVEIS
	Else
		m_pag 	:= mv_par06
	Endif

	Private cMoeda

	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Variaveis utilizadas para Impressao do Cabecalho e Rodape    ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	cbtxt    := SPACE(10)
	cbcont   := 0
	li       := 80
	cMoeda	:= mv_par03

	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Carregando definicoes para impressao -> Decimais, Picture,   ³
	//³ Mascara da Conta                                             ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	cDescMoeda 	:= aCtbMoeda[2]
	nDecimais 	:= DecimalCTB(aSetOfBook,cMoeda)

	If Empty(aSetOfBook[2])
		cMascara := GetMv("MV_MASCARA")
	Else
		cMascara := RetMasCtb(aSetOfBook[2],@cSeparador)
	EndIf
	cPicture 	:= aSetOfBook[4]

	Titulo		:= 	OemToAnsi(STR0009) + DTOC(mv_par01) + OemToAnsi(STR0010) +;
	DTOC(mv_par02) + OemToAnsi(STR0011) + cDescMoeda + CtbTitSaldo(mv_par05)

	dbSelectAre("CT2")
	dbSetOrder(1)
	SetRegua(Reccount())
	dbSeek(xFilial()+Dtos(mv_par01),.T.)

	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Impressao de Termo / Livro                                   ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	Do Case
		Case mv_par09==1 ; lImpLivro:=.t. ; lImpTermos:=.f.
		Case mv_par09==2 ; lImpLivro:=.t. ; lImpTermos:=.t.
		Case mv_par09==3 ; lImpLivro:=.f. ; lImpTermos:=.t.
	EndCase		

	While 	lImpLivro .And. !Eof() .and. CT2->CT2_FILIAL == xFilial() .And.;
	DTOS(CT2->CT2_DATA) <= DTOS(mv_par02)

		IF lEnd
			@Prow()+1, 0 PSAY cCancel 
			Exit
		EndIF

		If Eval(bPular)
			dbSkip()
			Loop
		EndIf

		nMes := Month(CT2->CT2_DATA)

		While ! Eof() .And. CT2->CT2_FILIAL == xFilial() .And. ;
		DTOS(CT2->CT2_DATA) <= DTOS(mv_par02) .And.;
		Month(CT2->CT2_DATA) == nMes

			If Eval(bPular)
				dbSkip()
				Loop
			EndIf

			nDia := Day(CT2->CT2_DATA)
			lData:= .T.		
			While !Eof() .And. CT2->CT2_FILIAL == xFilial() .And.;
			DTOS(CT2->CT2_DATA) <= DTOS(mv_par02) .And.;
			Month(CT2->CT2_DATA) == nMes .And. Day(CT2->CT2_DATA) == nDia

				IF lEnd
					@Prow()+1, 0 PSAY cCancel 
					Exit
				EndIF

				IncRegua()

				If Eval(bPular)
					dbSkip()
					Loop
				EndIf

				cDoc 		:= CT2->CT2_DOC
				cLote		:= CT2->CT2_LOTE
				cSubLote	:= CT2->CT2_SBLOTE

				// Loop para imprimir mesmo lote / documento / continuacao de historico
				While !Eof() .And. CT2->CT2_FILIAL == xFilial() 		.And.;
				CT2->CT2_DOC == cDoc 				.And.;
				CT2->CT2_LOTE == cLote 			.And.;
				CT2->CT2_SBLOTE == cSubLote 		.And.;
				DTOS(CT2->CT2_DATA) <= DTOS(mv_par02) 	.And.;
				Month(CT2->CT2_DATA) == nMes 			.And.;
				Day(CT2->CT2_DATA) == nDia

					If Eval(bPular)
						dbSkip()
						Loop
					EndIf

					If li > nMaxLin
						li++
						//	Imprime "a transportar ----->" ao final da pagina
						If !lFirst .And. (nTotDiaD <> 0 .or. nTotDiaC <> 0)
							@li,055 PSAY OemToAnsi(STR0013)						// A transportar
							If nTotDiaD <> 0
								ValorCTB(nTotDiaD,li,nColDeb,nTamDeb,nDecimais,.F.,cPicture,"1")
							EndIf
							If nTotDiaC <> 0
								ValorCTB(nTotDiaC,li,nColCrd,nTamCrd,nDecimais,.F.,cPicture,"2")
							EndIf                                               
							li++
						EndIF             

						If lEmissUnica
							CtbQbPg(.F.,@nPagIni,@nPagFim,@nReinicia,@m_pag,@nBloco,@nBlCount)		/// FUNCAO PARA TRATAMENTO DA QUEBRA //.F. EFETUA QUEBRA
						Else
							// Reinicia numeracao de pagina
							If m_pag > mv_par07
								If lNewPAGFIM
									mv_par07	:= m_pag+mv_par07		//// ACUMULA A QTDE ATUAL NA NUMERACAO FINAL
									If l1StQb							//// SE FOR A 1ª QUEBRA
										m_pag		:= mv_par08			//// VOLTA A NUMERACAO COM O PARAMETRO
										l1StQb := .F.					//// INDICA Q NÃO É MAIS A 1ª QUEBRA
									Endif
								Else
									m_pag := nReinicia
								Endif
							Endif
						Endif
						CtCGCCabec(,,,Cabec1,Cabec2,dDataFim,Titulo,,"2",Tamanho)
						// Imprime "de transporte -------->" no inicio da pagina
						If !lFirst .And. (nTotDiaD <> 0 .or. nTotDiaC <> 0)
							li++                                           
							@li,000 PSAY DTOC(CT2->CT2_DATA)
							@li,055 PSAY OemToAnsi(STR0014)
							If nTotDiaD <> 0
								ValorCTB(nTotDiaD,li,nColDeb,nTamDeb,nDecimais,.F.,cPicture,"1")
							EndIf
							If nTotDiaC <> 0
								ValorCTB(nTotDiaC,li,nColCrd,nTamCrd,nDecimais,.F.,cPicture,"2")
							EndIf                                               
							li+=2
						EndIF
						lFirst := .F.
					EndIF

					If lData
						li++
						@ li, 000 PSAY DTOC(CT2->CT2_DATA)
						li++
						lData := .F.
					EndIf

					If !Empty(CT2->CT2_DEBITO)					/// Se a Conta a Debito estiver preenchida
						dbSelectArea("CT1")
						dbSetOrder(1)
						If MsSeek(cFilCT1+CT2->CT2_DEBITO,.F.)	/// e existir no plano de contas
							If mv_par13 == 2							/// Impressao do Codigo Reduzido
								EntidadeCTB(CT1->CT1_RES,li,00,20,.F.,cMascara,cSeparador)
							ElseIf mv_par13 == 3 			 	/// Impressao do Codigo de Impressao (se o campo existir)
								EntidadeCTB(CT1->CT1_CODIMP,li,00,20,.F.,cMascara,cSeparador)
							Else										/// Impressao do Codigo Normal
								EntidadeCTB(CT2->CT2_DEBITO,li,00,20,.F.,cMascara,cSeparador)
							Endif
						Else
							EntidadeCTB(CT2->CT2_DEBITO,li,00,20,.F.,cMascara,cSeparador)						
						Endif
					Endif                              

					If !Empty(CT2->CT2_CREDIT)
						dbSelectArea("CT1")
						dbSetOrder(1)
						If MsSeek(cFilCT1+CT2->CT2_CREDIT,.F.)
							If mv_par13 == 2							/// Impressao do Codigo Reduzido
								EntidadeCTB(CT1->CT1_RES,li,21,20,.F.,cMascara,cSeparador)			
							ElseIf mv_par13 == 3 						/// Impressao do Codigo de Impressao (se o campo existir)
								EntidadeCTB(CT1->CT1_CODIMP,li,21,20,.F.,cMascara,cSeparador)
							Else										/// Impressao do Codigo Normal
								EntidadeCTB(CT2->CT2_CREDIT,li,21,20,.F.,cMascara,cSeparador)					
							Endif
						Else
							EntidadeCTB(CT2->CT2_CREDIT,li,21,20,.F.,cMascara,cSeparador)					
						Endif
					Endif

					If cPaisLoc == "CHI"
						@ li, 042 PSAY Substr(CT2->CT2_HIST,1,34)
						@ li, 077 PSAY CT2->CT2_LOTE+CT2->CT2_SBLOTE+" "+CT2->CT2_SEGOFI+CT2->CT2_LINHA
					Else
						@ li, 042 PSAY Substr(CT2->CT2_HIST,1,40)
						@ li, 083 PSAY CT2->CT2_LOTE+CT2->CT2_SBLOTE+CT2->CT2_DOC+CT2->CT2_LINHA
					EndIf					
					nValor := CT2->CT2_VALOR
					If CT2->CT2_DC == "1" .Or. CT2->CT2_DC == "3"
						ValorCTB(nValor,li,nColDeb,nTamDeb,nDecimais,.F.,cPicture,"1", , , , , ,lPrintZero)
					EndIf
					If CT2->CT2_DC == "2" .Or. CT2->CT2_DC == "3"
						ValorCTB(nValor,li,nColCrd,nTamCrd,nDecimais,.F.,cPicture,"2", , , , , ,lPrintZero)
					EndIf

					If CT2->CT2_DC == "1" .Or. CT2->CT2_DC == "3"	
						nTotDeb 	+= CT2->CT2_VALOR
						nTotDiaD	+= CT2->CT2_VALOR
						nTotMesD	+= CT2->CT2_VALOR
					EndIf
					If CT2->CT2_DC == "2" .Or. CT2->CT2_DC == "3"
						nTotCred += CT2->CT2_VALOR
						nTotdiaC += CT2->CT2_VALOR
						nTotMesC += CT2->CT2_VALOR
					EndIf

					// Procura pelo complemento de historico        
					nRecCT2 := CT2->(Recno())
					dData	:= CT2->CT2_DATA
					cSeqLan := CT2->CT2_SEQLAN
					cSeqHis	:= CT2->CT2_SEQHIS
					cEmpOri	:= CT2->CT2_EMPORI
					cFilOri	:= CT2->CT2_FILORI

					dbSelectArea("CT2")
					dbSetOrder(11)
					If dbSeek(xFilial()+DTOS(dData)+cLote+cSubLote+cDoc+cSeqLan+'01'+cSeqHis+cEmpOri+cFilOri)
						dbSkip()
						While !Eof() .And. CT2->CT2_FILIAL == xFilial() 	.And.;
						CT2->CT2_LOTE == cLote 		.And.;
						CT2->CT2_SBLOTE == cSubLote 	.And.;
						CT2->CT2_DOC == cDoc 			.And.;
						CT2->CT2_SEQLAN == cSeqLan 	.And.;
						Dtos(CT2->CT2_DATA) == DTOS(dData) 

							If CT2->CT2_MOEDLC <> '01' .or. CT2->CT2_EMPORI <> cEmpOri .or. ;
							CT2->CT2_FILORI <> cFilOri .or. CT2->CT2_DC <> "4" 
								dbSkip()
								Loop
							EndIf
							li++
							If li >= nMaxlin
								//	Imprime "a transportar ----->" ao final da pagina
								If !lFirst .And. (nTotDiaD <> 0 .or. nTotDiaC <> 0)
									@li,055 PSAY OemToAnsi(STR0013)						// A transportar
									If nTotDiaD <> 0
										ValorCTB(nTotDiaD,li,nColDeb,nTamDeb,nDecimais,.F.,cPicture,"1")
									EndIf
									If nTotDiaC <> 0
										ValorCTB(nTotDiaC,li,nColCrd,nTamCrd,nDecimais,.F.,cPicture,"2")
									EndIf                                               
									li++
								EndIF             
								If lEmissUnica
									CtbQbPg(.F.,@nPagIni,@nPagFim,@nReinicia,@m_pag,@nBloco,@nBlCount)		/// FUNCAO PARA TRATAMENTO DA QUEBRA //.F. EFETUA QUEBRA
								Else
									// Reinicia numeracao de pagina
									If m_pag > mv_par07
										If lNewPAGFIM
											mv_par07	:= m_pag+mv_par07		//// ACUMULA A QTDE ATUAL NA NUMERACAO FINAL
											If l1StQb							//// SE FOR A 1ª QUEBRA
												m_pag		:= mv_par08			//// VOLTA A NUMERACAO COM O PARAMETRO
												l1StQb := .F.					//// INDICA Q NÃO É MAIS A 1ª QUEBRA
											Endif
										Else
											m_pag := nReinicia
										Endif
									Endif
								Endif
								CtCGCCabec(,,,Cabec1,Cabec2,dDataFim,Titulo,,"2",Tamanho)
								// Imprime "de transporte -------->" no inicio da pagina
								If !lFirst .And. (nTotDiaD <> 0 .or. nTotDiaC <> 0)
									li++                 
									@ li, 000 PSAY DTOC(CT2->CT2_DATA)
									@li,055 PSAY OemToAnsi(STR0014)
									If nTotDiaD <> 0
										ValorCTB(nTotDiaD,li,nColDeb,nTamDeb,nDecimais,.F.,cPicture,"1")
									EndIf
									If nTotDiaC <> 0
										ValorCTB(nTotDiaC,li,nColCrd,nTamCrd,nDecimais,.F.,cPicture,"2")
									EndIf                                               
									li+=2
								EndIF        
								lFirst := .F.
							EndIF						
							@ li, 042 PSAY Substr(CT2->CT2_HIST,1,40)
							cLinha := CT2->CT2_LINHA
							dbSkip()
						EndDo	
						dbGoto(nRecCT2)
						dbSetOrder(1)					
						dbSkip()					
					Else         
						dbGoto(nRecCT2)
						dbSetOrder(1)
						dbSkip()			
					EndIf 			
					dbSetOrder(1)
					li++				

				EndDo
			EndDO
			If lEnd
				Exit
			Endif	
			IF (nTotDiad+nTotDiac)>0
				li++
				@li,055 PSAY OemToAnsi(STR0015)			// Totais do Dia
				ValorCTB(nTotDiaD,li,nColDeb,nTamDeb,nDecimais,.F.,cPicture,"1")
				ValorCTB(nTotDiaC,li,nColCrd,nTamCrd,nDecimais,.F.,cPicture,"2")
				nTotDiaD	:= 0
				nTotDiaC	:= 0
				li+=1
			EndIF
		EndDO
		If lEnd
			Exit
		End	
		// Totais do Mes
		IF (nTotMesd+nTotMesc) > 0
			li++
			@li,055 PSAY OemToAnsi(STR0016)				// Totais do Mes
			ValorCTB(nTotMesD,li,nColDeb,nTamDeb,nDecimais,.F.,cPicture,"1")
			ValorCTB(nTotMesC,li,nColCrd,nTamCrd,nDecimais,.F.,cPicture,"2")
			nTotMesD := 0
			nTotMesC := 0
			li+=2
		EndIF
	EndDO

	IF (nTotDiad+nTotDiac)>0 .And. !lEnd
		// Totais do Dia - Ultimo impresso
		li++
		@li,055 PSAY OemToAnsi(STR0015)				// Totais do Dia
		ValorCTB(nTotDiaD,li,nColDeb,nTamDeb,nDecimais,.F.,cPicture,"1")
		ValorCTB(nTotDiaC,li,nColCrd,nTamCrd,nDecimais,.F.,cPicture,"2")
		li++

		// Totais do Mes - Ultimo impresso
		@li,055 PSAY OemToAnsi(STR0016)  			// Totais do Mes
		ValorCTB(nTotMesD,li,nColDeb,nTamDeb,nDecimais,.F.,cPicture,"1")
		ValorCTB(nTotMesC,li,nColCrd,nTamCrd,nDecimais,.F.,cPicture,"2")
		li++
	EndIF

	// Total Geral impresso
	IF (nTotDeb + nTotCred) > 0 .And. !lEnd
		@li,055 PSAY OemToAnsi(STR0017)				// Total Geral
		ValorCTB(nTotDeb ,li,nColDeb,nTamDeb,nDecimais,.F.,cPicture,"1")
		ValorCTB(nTotCred,li,nColCrd,nTamCrd,nDecimais,.F.,cPicture,"2")
	EndIF

	nLinAst := GetNewPar("MV_INUTLIN",0)
	If li < nMaxLin .and. nLinAst <> 0 .and. !lEnd
		For nInutLin := 1 to nLinAst
			li++
			@li,00 PSAY REPLICATE("*",LIMITE)	
			If li == nMaxLin
				Exit
			EndIf
		Next
	EndIf

	If li <= 60 .and. !lEnd .and. !lImpTermos
		Roda(,,Tamanho)
	EndIf
	dbSelectarea("CT2")
	dbSetOrder(1)
	Set Filter To  

	If mv_par10 == 1
		Ctbr040(wnRel)
		Pergunte( "CTR110", .F. )
	EndIf
	If mv_par11 == 1
		Ctbr010(wnRel,mv_par02,mv_par03)
	Endif

	If lImpTermos 							// Impressao dos Termos

		Pergunte( "CTR110", .F. )

		cArqAbert:=GetMv("MV_LDIARAB")
		cArqEncer:=GetMv("MV_LDIAREN")

		dbSelectArea("SM0")
		aVariaveis:={}

		For i:=1 to FCount()	
			If FieldName(i)=="M0_CGC"
				AADD(aVariaveis,{FieldName(i),Transform(FieldGet(i),"@R 99.999.999/9999-99")})
			Else
				If FieldName(i)=="M0_NOME"
					Loop
				EndIf
				AADD(aVariaveis,{FieldName(i),FieldGet(i)})
			Endif
		Next

		If !File(cArqAbert)
			aSavSet:=__SetSets()
			cArqAbert:=CFGX024(,"Diario Geral.") // Editor de Termos de Livros
			__SetSets(aSavSet)
			Set(24,Set(24),.t.)
		Endif

		If !File(cArqEncer)
			aSavSet:=__SetSets()
			cArqEncer:=CFGX024(,"Diario Geral.") // Editor de Termos de Livros
			__SetSets(aSavSet)
			Set(24,Set(24),.t.)
		Endif

		If cArqAbert#NIL
			ImpTerm(cArqAbert,aVariaveis,AvalImp(132))
		Endif

		If cArqEncer#NIL
			ImpTerm(cArqEncer,aVariaveis,AvalImp(132))
		Endif	 
	Endif

	If aReturn[5] = 1
		Set Printer To
		Commit
		Ourspool(wnrel)
	End
	MS_FLUSH()

Return

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³CtbQbPg   ºAutor  ³Marcos S. Lobo      º Data ³  12/02/03   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³Controla a quebra de pagina dos relatorios SIGACTB          º±±
±±º          ³quando possuem os parametros de PAG.INICAL-FINAL-REINICIAR  º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºParametro1³ lNewVars  = (.T.=Inicializa variaveis/.F.=Trata Quebra)    º±±
±±º         2³ nPagIni 	 = Pagina Inicial do relatorio.               	  º±±
±±º         3³ nPagFim 	 = Pagina Final do relatorio               	 	  º±±
±±º         4³ nReinicia = Pagina ao Reiniciar do relatorio               º±±
±±º         5³ m_pag 	 = Numero da pagina usada na Cabec()              º±±
±±º         6³ nBloco    = Bloco de paginas (intervalo de quebra)		  º±±
±±º         7³ nBlCount  = Contador de páginas (zerado na qebra de bloco) º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Static Function CtbQbPg(lNewVars,nPagIni,nPagFim,nReinicia,m_pag,nBloco,nBlCount)

	DEFAULT lNewVars := .F.

	If lNewVars					/// INICIALIZA AS VARIAVEIS
		nBloco		:= (nPagFim+1) - nPagIni				/// (PAG. FIM + 1) - PAG. INICIAL - BLOCO DE PAG. PARA IMPRESSAO
		nBlCount	:= 0
		m_pag		:= nPagIni
	Else						/// NAO INICIALIZA - TRATA A QUEBRA DE PAGINA
		nBlCount++
		If nBlCount > nBloco 							/// SE A QUANTIDADE DE PAGINAS IMPRESSAO FOR IGUAL AO BLOCO DEFINIDO
			If nReinicia > nPagFim						/// SE A PAG. DE REINICIO FOR MAIOR QUE A PAGINA FINAL (ATUAL)
				nUltPg	  := m_pag						/// GUARDA A ULTIMA PAG. IMPRESSA
				m_pag 	  := nReinicia					/// REINICIA A NUMERACAO DE PAG. (m_pag atual ainda não foi)
				nPagFim   := nReinicia+nBloco 			/// DEFINE O NOVO NUMERO DA PAGINA FIM
				nReinicia := nPagFim+(nReinicia-nUltPg)	/// DEFINE A PROX. PAG. AO REINICIAR PELA DIFERENCA COM  FINAL
			Else										/// SE A PAG. DE REINICIO FOR MENOR OU IGUAL A PAGINA FINAL                                                                
				m_pag := nReinicia						/// SO REINICIA A NUMERACAO DE PAG.
			Endif
			nBlCount := 1
		EndIf	
	Endif

Return

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o    ³ CTR110SX1    ³Autor ³  Simone Mie Sato     ³Data³ 05/08/04 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³ Cria nova pergunta para o relatorio.                       ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Static Function CTR110SX1()

	Local aSaveArea 	:= GetArea()
	Local aPergs		:= {}
	Local aHelpPor		:= {}
	Local aHelpEng		:= {}
	Local aHelpSpa		:= {}

	aHelpPor	:= {} 
	aHelpEng	:= {}	
	aHelpSpa	:= {}

	Aadd(aHelpPor,"Informe a quantidade de linhas ")			
	Aadd(aHelpPor,"que serao impressas em cada pag.")
	Aadd(aHelpPor,"do diario.")

	Aadd(aHelpEng,"Enter the number of rows to ")
	Aadd(aHelpEng,"be printed in each daybook ")
	Aadd(aHelpEng,"page.")

	Aadd(aHelpSpa,"Indique la cantidad de lineas ")
	Aadd(aHelpSpa,"que imprimiran en cada pag. ")
	Aadd(aHelpspa,"del libro diario.")                             


	Aadd(aPergs,{"Num.linhas p/ o diario?","¨Num.lineas p/libro diario?","No.of rows for the daybook?","mv_che","N",2,0,0,"G",,"mv_par14","","","","","","","","","","","","","","","","","","","","","","","","","","","S","",aHelpPor,aHelpEng,aHelpSpa})

	AjustaSx1("CTR110",aPergs)   

	RestArea(aSaveArea)

Return
