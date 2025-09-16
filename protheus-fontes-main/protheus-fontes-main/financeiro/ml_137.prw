#INCLUDE "finr137.ch"

User Function ML_137()

	/*/
	ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
	±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
	±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
	±±³Funcao    ³ FINR137  ³ Autor ³ Claudio Henrique      ³ Data ³ 27.11.03 ³±±
	±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
	±±³Descricao ³ Posicao de Titulos a Receber por Vendedor                  ³±±
	±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
	±±³Sintaxe   ³ FINR137                                                    ³±±
	±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
	±±³ Uso      ³ Generico                                                   ³±±
	±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
	±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
	ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß

	Historico de alteracoes:
	22/11/2004 - Robert - Criada ordenacao por vencimento dentro do vendedor

	/*/
	Local cDesc1  := STR0001 //"Posicao dos Titulos a Receber por Vendedor"
	Local cDesc2  := ""
	Local cDesc3  := ""
	Local cString := "SE1"
	Local nValor
	Local nSaldo  := 0

	Private  wnrel
	Private titulo   := ""
	Private cabec1   := ""
	Private cabec2   := ""
	Private aLinha   := {}
	Private aReturn  := {STR0002,1,STR0003, 1, 2, 1, "",1 } //"Zebrado"###"Administracao"
	Private cPerg    := "FIN137"
	Private nJuros   := 0
	Private nLastKey := 0
	Private nomeprog := "FINR137"
	Private tamanho  := "G"
	Private aTam     := {}
	Private aCampos  := {}

	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Defini‡„o dos cabe‡alhos ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	titulo := STR0001 //"Posicao dos Titulos a Receber por Vendedor"
	cabec1 := STR0004 //"PRF NUMERO PARC TIPO  CLIENTE LOJA  NOME DO CLIENTE           EMISSAO      VENCIMENTO                     VALOR             SALDO  NATUREZA   DESCRICAO                        VALOR DE JUROS  ATRASO"
	cabec2 := ""

	//PutDtBase()
	pergunte(cperg,.F.)

	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³  Variaveis utilizadas para parametros                                  ³
	//³  mv_par01            // Do Cliente                                     ³
	//³  mv_par02            // Da Loja                                        ³
	//³  mv_par03            // Ate o Cliente                                  ³
	//³  mv_par04            // Ate a Loja                                     ³
	//³  mv_par05            // Da Emissao                                     ³
	//³  mv-par06            // Ate Emissao                                    ³
	//³  mv_par07            // Do vencimento                                  ³
	//³  mv_par08            // Ate o vencimento                               ³
	//³  mv_par09            // Do vendedor                                    ³
	//³  mv_par10            // Ate o vendedor                                 ³
	//³  mv_par11            // Considera Tipos                                ³
	//³  mv_par12            // Nao considera tipos                            ³
	//³  mv_par13            // Qual moeda                                     ³
	//³  mv_par14            // Outras Moedas : 1-converte 2=nao imprime       ³
	//³  mv_par15            // Considera data base : 1-Sim, 2=Nao             ³
	//³  mv_par16            // Database                                       ³
	//³  mv_par17            // Considera Filiais abaixo (1=Sim/2=Nao)         ³
	//³  mv_par18            // Filial De                                      ³
	//³  mv_par19            // Filial Ate                                     ³
	//³  mv_par20            // Ordena por vecto ou nf                         ³
	//³  mv_par21            // Converte valores pela ?                        ³
	//³  mv_par22            // Ordena por:                                    ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ

	//Envia controle para a funcao SETPRINT 								   
	wnrel := "ML_137"            //Nome Default do relatorio em Disco
	wnrel := SetPrint(cString,wnrel,cPerg,@titulo,cDesc1,cDesc2,cDesc3,.F.,,Tamanho)

	If nLastKey == 27
		Return
	Endif

	SetDefault(aReturn,cString)

	If nLastKey == 27
		Return
	Endif

	titulo += STR0005 + GetMv("MV_MOEDA" + Str(mv_par13,1,0) ) //" Valores em  "

	RptStatus({|lEnd| FA137Imp(@lEnd,wnRel,cString)},titulo)  // Chamada do Relatorio

Return


/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡„o    ³ FA137Imp ³ Autor ³ Claudio Henrique    ³ Data ³ 04.12.03   ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡„o ³ Imprime relat¢rio dos T¡tulos a Receber por vendedor       ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe e ³ FA137Imp(lEnd,WnRel,cString)                               ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³ lEnd    - A‡Æo do Codeblock                                ³±±
±±³          ³ wnRel   - T¡tulo do relat¢rio                              ³±±
±±³          ³ cString - Mensagem                                         ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ Generico                                                   ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Static Function FA137Imp(lEnd,WnRel,cString)

	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Variaveis utilizadas para Impressao do Cabecalho e Rodape    ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	Local nTotal      := 0
	Local nTotalGeral := 0
	Local cVend
	Local nAtraso
	Local lFirst  := .T.
	Local aArea   := GetArea()
	Local nTotJur := 0
	Local _nPesoTotG := 0

	#IFDEF TOP
	Local cQuery := ""
	Local nI     := 0
	Local aStru  := SE1->(dbStruct())
	#ENDIF

	cbtxt  := SPACE(10)
	cbcont := 0
	li     := 80
	m_pag  := 1

	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Geracao do arquivo de Trabalho                               ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	aTam:=TamSX3("E1_VEND1")
	AADD(aCampos,{"CODVEND"  ,"C",aTam[1],aTam[2]})
	aTam:=TamSX3("E1_FILIAL")
	AADD(aCampos,{"FILIAL"    ,"C",aTam[1],aTam[2]})
	aTam:=TamSX3("E1_PREFIXO")
	AADD(aCampos,{"PREFIXO"    ,"C",aTam[1],aTam[2]})
	aTam:=TamSX3("E1_NUM")
	AADD(aCampos,{"NUM"    ,"C",aTam[1],aTam[2]})
	aTam:=TamSX3("E1_PARCELA")
	AADD(aCampos,{"PARCELA"    ,"C",aTam[1],aTam[2]})
	aTam:=TamSX3("E1_TIPO")
	AADD(aCampos,{"TIPO"    ,"C",aTam[1],aTam[2]})
	aTam:=TamSX3("E1_SALDO")
	AADD(aCampos,{"SALDO"    ,"N",aTam[1],aTam[2]})
	aTam:=TamSX3("E1_VENCREA")
	AADD(aCampos,{"VENCTO"    ,"D",aTam[1],aTam[2]})
	//cArq:=CriaTrab(aCampos)

	//dbUseArea( .T.,, cArq, "TRB", if(.F. .OR. .F., !.F., NIL), .F. )
	//IndRegua("TRB",cArq,"CODVEND",,,STR0006) //"Selecionando Registros..."  
	//if mv_par22 = 1
	//	IndRegua("TRB",cArq,"CODVEND + DTOS(VENCTO)",,,STR0006) //"Selecionando Registros..."
	//else
	//	IndRegua("TRB",cArq,"CODVEND + PREFIXO + NUM",,,STR0006) //"Selecionando Registros..."
	//endif
	
	_aArqTrb := {}
	If Select('TRB')<>0                                  //Se um tmp com alias TMP existir, fecha-o
		TRB->(dbCloseArea())
		u_arqtrb("FechaTodos",,,, @_aArqTrb)
	Endif

	if mv_par22 = 1
		U_ArqTrb("Cria", "TRB", aCampos, {"CODVEND","VENCTO"}, @_aArqTrb)
	else
		U_ArqTrb("Cria", "TRB", aCampos, {"CODVEND","PREFIXO","NUM"}, @_aArqTrb)
	EndIf

	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Atribui valores as variaveis ref a filiais                ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	If mv_par17 == 2
		cFilDe  := cFilAnt
		cFilAte := cFilAnt
	Else
		cFilDe  := mv_par18      // Todas as filiais
		cFilAte := mv_par19
	Endif

	dbSelectArea("SM0")
	MsSeek(cEmpAnt+cFilDe,.T.)

	nRegSM0 := SM0->(Recno())
	nAtuSM0 := SM0->(Recno())

	While !Eof() .and. M0_CODIGO == cEmpAnt .and. M0_CODFIL <= cFilAte

		dbSelectArea("SE1")
		cFilAnt := SM0->M0_CODFIL
		Set Softseek On

		#IFDEF TOP
		cQuery := "SELECT * FROM " + RetSqlName("SE1") + " WHERE E1_FILIAL = '" + FWxFilial("SE1") + "' AND "
		cQuery += "E1_CLIENTE >= '" + MV_PAR01 + "' AND E1_CLIENTE <= '" + MV_PAR03 + "' AND "
		cQuery += "E1_LOJA >= '" + MV_PAR02 + "' AND E1_LOJA <= '" + MV_PAR04 + "' AND " 		
		cQuery += "E1_EMISSAO >= '" + DTOS(MV_PAR05) + "' AND E1_EMISSAO <= '" + DTOS(MV_PAR06) + "' AND "
		cQuery += "E1_VENCTO >= '" + DTOS(MV_PAR07) + "' AND E1_VENCTO <= '" + DTOS(MV_PAR08) + "' AND "
		cQuery += "D_E_L_E_T_ = ' '" 
		cQuery += "ORDER BY E1_VENCTO,E1_NUM DESC"

		cQuery := ChangeQuery(cQuery)
		dbSelectArea("SE1")
		dbCloseArea()
		dbSelectArea("SA1")
		dbUseArea(.T., "TOPCONN", TCGenQry(,,cQuery),"SE1",.F., .T.)
		For nI := 1 TO LEN(aStru)
			If aStru[nI][2] != "C"
				TCSetField("SE1", aStru[nI][1], aStru[nI][2], aStru[nI][3], aStru[nI][4])
			EndIf
		Next
		dbSelectArea("SE1")
		dbGoTop()
		#ELSE
		cString := 'E1_FILIAL=="'+FWxFilial("SE1")+'".And.'
		cFiltro := "E1_CLIENTE >= '" + MV_PAR01 + "' .AND. E1_CLIENTE <= '" + MV_PAR03 + "' .AND. "
		cFiltro += "E1_LOJA >= '" + MV_PAR02 + "' .AND. E1_LOJA <= '" + MV_PAR04 + "' .AND. "
		cFiltro += "DTOS(E1_EMISSAO) >= '" + DTOS(MV_PAR05) + "' .AND. DTOS(E1_EMISSAO) <= '" + DTOS(MV_PAR06) + "' .AND. "
		cFiltro += "DTOS(E1_VENCTO)  >= '" + DTOS(MV_PAR07) + "' .AND. DTOS(E1_VENCTO)  <= '" + DTOS(MV_PAR08) + "'"
		cIndTmp := CriaTrab(nil,.F.)
		IndRegua("SE1",cIndTmp,IndexKey(),,cFiltro,STR0006)
		nIndexSE1 := RetIndex("SE1")
		dbSetIndex(cIndTmp+OrdBagExt())
		dbSetOrder(nIndexSe1+1)
		dbSelectArea("SE1")
		MsSeek(FWxFilial("SE1"))
		#ENDIF

		While !Eof() .and. SE1->E1_FILIAL == FWxFilial("SE1")

			If mv_par15 == 2 .and. SE1->E1_SALDO == 0
				dbSkip()
				Loop
			Endif

			If SE1->E1_EMISSAO > mv_par16
				dbSkip()
				Loop
			Endif

			IF Empty(SE1->E1_VEND1+SE1->E1_VEND2+SE1->E1_VEND3+SE1->E1_VEND4+SE1->E1_VEND5)
				dbSkip()
				Loop
			ENDIF

			IF MV_PAR14 == 2 .AND. SE1->E1_MOEDA != MV_PAR13
				dbSkip()
				Loop
			ENDIF

			IF !Empty(mv_par11)
				If !SE1->E1_TIPO $ mv_par09
					dbSkip()
					Loop
				Endif
			Endif

			If !Empty(mv_par12)
				If SE1->E1_TIPO $ mv_par10
					dbSkip()
					Loop
				Endif
			Endif  

			If Empty(mv_par12)
				If SE1->E1_TIPO = 'RA'
					dbSkip()
					Loop
				Endif
			Endif       

			if SE1->E1_TIPO <> 'NF' .and. SE1->E1_TIPO <> 'INC'
				dbSkip()
				Loop		
			endif 

			If mv_par15 == 2
				nSaldo:=xMoeda((SE1->E1_SALDO+SE1->E1_SDACRES-SE1->E1_SDDECRE),SE1->E1_MOEDA,MV_PAR13)
			ELSE
				nSaldo:=SaldoTit(SE1->E1_PREFIXO,SE1->E1_NUM,SE1->E1_PARCELA,SE1->E1_TIPO,SE1->E1_NATUREZ,"R",SE1->E1_CLIENTE,mv_par13,mv_par16,,SE1->E1_LOJA,,If(cPaisLoc=="BRA",SE1->E1_TXMOEDA,0))
			Endif

			If ! SE1->E1_TIPO $ MVABATIM
				If ! (SE1->E1_TIPO $ MVRECANT+"/"+MV_CRNEG) .And. ;
				!( MV_PAR15 == 2 .And. nSaldo == 0 )  	// deve olhar abatimento pois e zerado o saldo na liquidacao final do titulo
					nAbatim := SomaAbat(SE1->E1_PREFIXO,SE1->E1_NUM,SE1->E1_PARCELA,"R",mv_par15,,SE1->E1_CLIENTE,SE1->E1_LOJA)
					If STR(nSaldo,17,2) == STR(nAbatim,17,2)
						nSaldo := 0
					Else
						nSaldo-= nAbatim
					Endif
				Endif	
			Else
				dbSkip()
				Loop
			Endif
			nSaldo:=Round(NoRound(nSaldo,3),2)

			If nSaldo <= 0
				dbSkip()
				Loop
			Endif

			IF SE1->E1_VEND1 >= MV_PAR09 .AND. SE1->E1_VEND1 <= MV_PAR10 .AND. !Empty(SE1->E1_VEND1)
				R137TEMP(SE1->E1_VEND1,nSaldo)
			ENDIF

			IF SE1->E1_VEND2 >= MV_PAR09 .AND. SE1->E1_VEND2 <= MV_PAR10 .AND. !Empty(SE1->E1_VEND2)
				R137TEMP(SE1->E1_VEND2,nSaldo)
			ENDIF

			IF SE1->E1_VEND3 >= MV_PAR09 .AND. SE1->E1_VEND3 <= MV_PAR10 .AND. !Empty(SE1->E1_VEND3)
				R137TEMP(SE1->E1_VEND3,nSaldo)
			ENDIF

			IF SE1->E1_VEND4 >= MV_PAR09 .AND. SE1->E1_VEND4 <= MV_PAR10 .AND. !Empty(SE1->E1_VEND4)
				R137TEMP(SE1->E1_VEND4,nSaldo)
			ENDIF

			IF SE1->E1_VEND5 >= MV_PAR09 .AND. SE1->E1_VEND5 <= MV_PAR10 .AND. !Empty(SE1->E1_VEND5)
				R137TEMP(SE1->E1_VEND5,nSaldo)
			ENDIF
			dbSkip()
		Enddo
		If Empty(FWxFilial("SE1"))
			Exit
		Endif
		dbSelectArea("SM0")
		dbSkip()
		Loop
	Enddo	

	SM0->(dbGoTo(nRegSM0))
	cFilAnt := SM0->M0_CODFIL

	#IFDEF TOP
	dbSelectArea("SE1")
	dbCloseArea()
	ChKFile("SE1")
	dbSelectArea("SE1")
	dbSetOrder(1)
	#ELSE
	dbSelectArea("SE1")
	dbClearFil()
	RetIndex("SE1")
	dbSetOrder(1)
	#ENDIF

	TRB->(dbgotop())

	While !TRB->(EOF())

		IF li > 58
			li:=	cabec(titulo,cabec1,cabec2,nomeprog,tamanho,18)
			li++
		Endif

		cVar:= TRB->CODVEND
		nTotal := 0
		nTotJur := 0 
		_nPesoTotG := 0
		cVend:=Space(06)
		While !TRB->(EOF()) .AND. cVar==TRB->CODVEND

			cVend:=TRB->CODVEND

			If lFirst
				dbSelectArea("SA3")
				dbSetOrder(1)
				MsSeek(FWxFilial("SA3") + cVend)
				@Li, 0 PSAY cVend + "-" + SA3->A3_NOME
				lFirst := .F.
				Li+=2	
			Endif		

			SE1->(MsSeek(TRB->(FILIAL+PREFIXO+NUM+PARCELA+TIPO)))
			nValor:=xMoeda(SE1->E1_VALOR,SE1->E1_MOEDA,MV_PAR13)
			nAtraso:=(mv_par16-SE1->E1_VENCTO)
			nAtraso:= If(nAtraso < 0, 0, nAtraso)

			IF li > 58
				li:=	cabec(titulo,cabec1,cabec2,nomeprog,tamanho,18)
				li++
			Endif

			@Li,000 PSAY TRB->PREFIXO
			@Li,004 PSAY TRB->NUM
			@Li,014 PSAY TRB->PARCELA
			@Li,017 PSAY TRB->TIPO
			@Li,023 PSAY SE1->E1_CLIENTE
			@Li,031 PSAY SE1->E1_LOJA
			DbSelectArea("SA1")
			MsSeek(FWxFilial("SA1")+SE1->E1_CLIENTE+SE1->E1_LOJA)
			If Found()
				@Li,036 PSAY SA1->A1_NOME
			Else
				@Li,036 PSAY Replicate("?",40)
			Endif
			dbSelectArea("SE1")
			@Li,078 PSAY SE1->E1_EMISSAO
			@Li,088 PSAY SE1->E1_VENCTO
			@Li,106 PSAY nValor PICTURE "@E 99999,999.99"
			@Li,120 PSAY TRB->SALDO PICTURE "@E 99999,999.99"

			dbSelectArea("SE1")
			nJuros := 0
			fa070juros(mv_par13)
			//@Li,133 PSAY nJuros   PICTURE "@E 999,999.99"
			//@Li,144 PSAY TRB->SALDO+nJuros  PICTURE "@E 99999,999.99"

			dbSelectArea("SF2")
			dbSetOrder(2)
			MsSeek(FWxFilial("SF2") + SE1->E1_CLIENTE + SE1->E1_LOJA + TRB->NUM + "   ")
			If Found()
				_nPesoTot := SF2->F2_PLIQUI
				_Origem   := "FATURAMENTO"
			Else
				_nPesoTot := 0
				_Origem   := "FINANCEIRO"
			Endif          
			@Li,161 PSAY  SA1->A1_DDD        
			@Li,165 PSAY  SA1->A1_TEL  
			//  @Li,156 PSAY _nPesoTot  PICTURE "@E 999999.99"
			//  @Li,170 PSAY _Origem

			_nPesoTotG += _nPesoTot

			//@Li,157 PSAY SE1->E1_NATUREZ
			//dbSelectArea("SED")
			//dbSetOrder(1)
			//MsSeek(FWxFilial("SED") + SE1->E1_NATUREZ)
			//@Li,168 PSAY SED->ED_DESCRIC

			@Li,186 PSAY nAtraso Picture "9999"

			nTotJur += nJuros
			If SE1->E1_TIPO $ MV_CRNEG+"/"+MVRECANT
				nTotal -=  TRB->SALDO
			Else
				nTotal +=  TRB->SALDO
			Endif
			li++

			TRB->(dBskip())
		Enddo
		lFirst := .T.
		dbSelectArea("SA3")
		dbSetOrder(1)
		MsSeek(FWxFilial("SA3") + cVend)

		Li++
		@Li, 000 PSAY STR0007 + cVar + " " + SA3->A3_NOME //"TOTAL DO VENDEDOR : "
		@Li, 117 PSAY nTotal		      PICTURE "@E 99999,999.99" 
		//@Li, 131 PSAY nTotJur      	PICTURE "@E 99999,999.99"
		//@Li, 144 PSAY nTotal+nTotJur	PICTURE "@E 99999,999.99"
		//@Li,156 PSAY _nPesoTotG       PICTURE "@E 999999.99"
		Li++

		nTotalGeral += nTotal+nTotJur
		li+=2

	Enddo

	If nTotalGeral > 0
		li+=2
		@li,   0 PSAY STR0008 //"TOTAL GERAL : "
		@Li ,144 PSAY nTotalGeral               PICTURE  "@E 99999,999.99"
		li++
	Endif

	If Select('TRB')<>0                                  //Se um tmp com alias TMP existir, fecha-o
		TRB->(dbCloseArea())
		u_arqtrb("FechaTodos",,,, @_aArqTrb)
	Endif
	//If Select("TRB") > 0
		//TRB->(dbCloseArea())
		//Ferase(cArq+GetDBExtension())      // Elimina arquivos de Trabalho
		//Ferase(cArq+OrdBagExt())                          // Elimina arquivos de Trabalho
	//Endif

	RestArea(aArea)

	Set Device To Screen
	Set Filter to

	If aReturn[5] = 1
		Set Printer TO
		dbCommitAll()
		Ourspool(wnrel)
	Endif

	MS_FLUSH()

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºFuncao    ³R137TEMP  ºAutor  ³Claudio Henrique    º Data ³  11/28/03   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³Gravacao do arquivo de trabalho                             º±±
±±º          ³                                                            º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ Generico                                                   º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Static Function R137TEMP(cCampo,nSaldo)
	Local aArea := GetArea()

	Reclock("TRB", .T.)
	TRB->CODVEND := cCampo
	TRB->FILIAL  := SE1->E1_FILIAL
	TRB->PREFIXO := SE1->E1_PREFIXO
	TRB->NUM     := SE1->E1_NUM
	TRB->PARCELA := SE1->E1_PARCELA
	TRB->TIPO    := SE1->E1_TIPO
	TRB->VENCTO  := SE1->E1_VENCREA
	TRB->SALDO   := nSaldo
	Msunlock()
	RestArea( aArea )

Return


/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o    ³ PutDtBase³ Autor ³ Mauricio Pequim Jr    ³ Data ³ 18/07/02 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³ Acerta parametro database do relatorio                     ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Uso       ³ Finr137.prx                                                ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
/*
Static Function PutDtBase()
	Local cAlias := Alias()

	dbSelectArea("SX1")
	dbSetOrder(1)
	If MsSeek("FIN137    16")
		//Acerto o parametro com a database
		RecLock("SX1",.F.)
		Replace x1_cnt01 With "'"+DTOC(dDataBase)+"'"
		MsUnlock() 
	Endif
	dbSelectArea(cAlias)

Return
*/
