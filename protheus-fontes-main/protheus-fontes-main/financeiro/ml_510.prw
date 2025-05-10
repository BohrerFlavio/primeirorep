#INCLUDE "FINR510.CH"

User Function ML_510()

	/*/
	ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
	±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
	±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
	±±³Programa  ³  ML_510  ³ Autor ³ Evandro Mugnol        ³ Data ³ Abr/2003 ³±±
	±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
	±±³Descricao ³ Alteracao do Fonte Padrao (Diario Auxiliar Cli / For)      ³±±
	±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
	±±³Retorno   ³                                                            ³±±
	±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
	±±³Utilizacao³ Especifico para Frigorifico Silva                          ³±±
	±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
	±±³   Data   ³ Programador   ³Manutencao Efetuada                         ³±±
	±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
	±±³03/07/2019³ Evandro       ³Adequação query SE5 e demais testes no laço ³±±
	±±³          ³               ³while ref. ao resultado da query devido     ³±±
	±±³          ³               ³atualizações que o módulo sofreu c/ tempo.  ³±±
	±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
	±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
	ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
	/*/
	
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Define Variaveis                                             ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	LOCAL cDesc1 := OemToAnsi(STR0001)  //"Este programa ir  emitir o Diario Auxiliar de Clientes ou Fornecedores."
	LOCAL cDesc2 := OemToAnsi(STR0002)  //"Poder  imprimir os valores financeiros, ou demonstrar somente os valo-"
	LOCAL cDesc3 := OemToAnsi(STR0003)  //"res originais."
	LOCAL aTam   := TAMSX3("E1_CLIENTE")
	LOCAL limite := IIF(aTam[1] > 6 ,220,132)
	LOCAL Tamanho:= IIF(aTam[1] > 6 ,"G","M")
	LOCAL cString:= "SE1"

	PRIVATE titulo  := OemToAnsi(STR0004)  //"Diario Auxiliar de Clientes/Fornecedores"
	PRIVATE cabec1
	PRIVATE cabec2
	PRIVATE aReturn := { OemToAnsi(STR0005), 1,OemToAnsi(STR0006), 2, 2, 1, "",1 }  //"Zebrado"###"Administracao"
	PRIVATE nomeprog:= "ML_510"
	PRIVATE aLinha  := { },nLastKey := 0
	PRIVATE cPerg   := "ML_510"
	PRIVATE cTipos  := ""

	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Verifica as perguntas selecionadas                           ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	//ValidPerg()
	Pergunte(cPerg,.F.)

	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Variaveis utilizadas para parametros                        ³
	//³ mv_par01         // A partir de                             ³
	//³ mv_par02         // Ate a data                              ³
	//³ mv_par03         // Cliente / Fornecedor                    ³
	//³ mv_par04         // Do Codigo                               ³
	//³ mv_par05         // Ate o Codigo                            ³
	//³ mv_par06         // Pagina Inicial                          ³
	//³ mv_par07         // Pagina Final                            ³
	//³ mv_par08         // Abertura/Encerramento/Nenhum            ³
	//³ mv_par09         // So o termo                              ³
	//³ mv_par10         // Imprime valores financeiros?            ³
	//³ mv_par11         // Imprime (Todos / Normais / Adiant.)     ³
	//³ mv_par12         // Prefixo de                              ³
	//³ mv_par13         // Prefixo ate                             ³ 
	//³ mv_par14         // Lista Por 1 - Filial  2 -Empresa        ³
	//³ mv_par15         // Seleciona Tipos?                        ³
	//³ mv_par16         // Natureza de  ?                          ³
	//³ mv_par17         // Natureza ate ?                          ³
	//³ mv_par18         // Converte por ?                          ³
	//³ mv_par19         // Lista Bx Estornadas ?                   ³
	//³ mv_par20         // Conta Contabil Inicial                  ³
	//³ mv_par21         // Conta Contabil Final                    ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Envia controle para a funcao SETPRINT                       ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	wnrel := "ML_510"            //Nome Default do relatorio em Disco
	wnrel := SetPrint(cString,wnrel,cPerg,@titulo,cDesc1,cDesc2,cDesc3,.F.,"",.T.,Tamanho,"",.F.)
	If nLastKey == 27
		Return
	Endif
	SetDefault(aReturn,cString)
	If nLastKey == 27
		Return
	Endif

	RptStatus({|lEnd| Fa510Imp(@lEnd,wnRel,cString)},Titulo)

Return


/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o    ³ FA510Imp ³ Autor ³ Wagner Xavier         ³ Data ³ 25.11.92 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³ Diario Auxiliar Clientes / Fornecedores                    ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe e ³ FA510Imp(lEnd,wnRel,cString)                               ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ Generico                                                   ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Static Function FA510Imp(lEnd,wnRel,cString)

	LOCAL CbCont,CbTxt
	LOCAL cCodigo,lTermo:=.T.
	LOCAL cNome,cIdent,aCampos:={},cNomeArq,nCompress,nC,nQuebra:=0
	LOCAL nTotTit:=0,nTotDeb:=0,nTotCrd:=0
	LOCAL nGerTit:=0,nGerDeb:=0,nGerCrd:=0
	LOCAL dEmissao,dVencto,dDtDigit
	LOCAL nRec,nPrim,cPrefixo,cNumero,cParcela,cTipo,cNaturez,nValliq
	LOCAL nAnterior:=0,cRecPag,cFornece,nRec1, nIndex,cLoja
	LOCAL aInd:={}
	LOCAL cCondE1:=cCondE2:=cCondE5:=""
	LOCAL cIndE1 :=cIndE2 :=cIndE5 :=""
	LOCAL nTamNro
	LOCAL nRegSe1Atu := SE1->(RecNo())
	LOCAL nOrdSe1Atu := SE1->(IndexOrd())
	LOCAL lBaixa     := .F.
	LOCAL nRegSe2Atu := SE2->(RecNo())
	LOCAL nOrdSe2Atu := SE2->(IndexOrd())
	LOCAL cChaveSe1
	LOCAL cChaveSe2
	Local aStru      := SE1->(dbStruct()), ni
	Local cAlias510  := Alias()
	Local aVariaveis := {}, aSavSet := {}
	LOCAL aTam       := TAMSX3("E1_CLIENTE")
	LOCAL limite     := IIF(aTam[1] > 6 ,220,132)
	LOCAL Tamanho    := IIF(aTam[1] > 6 ,"G","M")
	Local aColu      := {}
	Local nMoedaBco  :=	1
	Local nMoedaTit  :=	1
	Local nMoedaT    :=      1
	Local cAliasTmp
	Local dDataConv
	Local nX
	Local cSimb  	  :=	""
	Local cSimbolo	  :=	""
	Local i
	
	Private nDecs    := GetMv("MV_CENT")

	If ExistBlock("FR510TIP")
		cTipos := ExecBlock("FR510TIP")
	Endif
	//para realizar o filtro

	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Variaveis utilizadas para Impressao do Cabecalho e Rodape	  ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	cbtxt  := SPACE(10)
	cbcont := 0
	li     := 80

	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Impress„o dos Termos (Abertura / Encerramento)               ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	If mv_par08 != 3
		lImprimiu := .F.
		cArqAbert:=SubStr(cArqRel,1,7)+"A.TRM"
		cArqEncer:=SubStr(cArqRel,1,7)+"E.TRM"
		aVariaveis := {}
		dbSelectArea("SM0")
		For i:=1 to FCount()
			If FieldName(i)=="M0_CGC"
				AADD(aVariaveis,{FieldName(i),Transform(FieldGet(i),"@R 99.999.999/9999-99")})
			Else
				If FieldName(i)=="M0_NOME"
					Loop
				Endif
				AADD(aVariaveis,{FieldName(i),FieldGet(i)})
			Endif
		Next
		If mv_par08 == 1	// Termo de Abertura
			aSavSet:=__SetSets()
			cArqAbert:=CFGX024(cArqAbert,STR0004) //"Diario Auxiliar de Clientes/Fornecedores"
			__SetSets(aSavSet)
			Set(24,Set(24),.t.)
			lImprimiu := ImpTerm(cArqAbert,aVariaveis,AvalImp(Limite))
		ElseIf mv_par08 == 2	// Termo de Encerramento
			aSavSet:=__SetSets()
			cArqEncer:=CFGX024(cArqEncer,STR0004)  //"Diario Auxiliar de Clientes/Fornecedores"
			__SetSets(aSavSet)
			Set(24,Set(24),.t.)
			lImprimiu := ImpTerm(cArqEncer,aVariaveis,AvalImp(Limite))
		Endif
		If lImprimiu
			Eject
		Endif
		If mv_par09 == 1	// Impress„o apenas dos termos
			Set Device To Screen
			If lImprimiu
				If aReturn[5] = 1
					Set Printer To
					Commit
					ourspool(wnrel)
					MS_FLUSH()
				Endif
			Endif
			Return
		Endif
	Endif

	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Verifica se seleciona tipos											³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	If mv_par15 == 1
		finRTipos()
	Endif

	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ For‡a ser por filial quando exista somente 1 filial,indepen- ³
	//³ dente da resposta                                            ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	mv_par14 := Iif(SM0->(Reccount())==1,1,mv_par14)

	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Definicao dos cabecalhos												  ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	titulo:= OemToAnsi(STR0007)   +IIF(mv_par03==1,OemToAnsi(STR0008),OemToAnsi(STR0009))  //"DIARIO AUXILIAR DE C/C "###"CLIENTES"###"FORNECEDORES"

	m_pag := mv_par06

	IF mv_par03==1
		cNome :=OemToAnsi(STR0010)  //"NOME DO CLIENTE              "
		cIdent:=OemToAnsi(STR0011)  //"CLIENTE"
	Else
		cNome :=OemToAnsi(STR0012)  //"NOME DO FORNECEDOR            "
		cIdent:=OemToAnsi(STR0013)  //"FORNEC "
	Endif

	nCompress:=aReturn[4]
	cabec1 := OemToAnsi(STR0014)+IIf(aTam[1]>6,Space(14),"")+cNome+ OemToAnsi(STR0015)   //"  DATA   PREF  NUM  PC CODIGO "###" DT EMIS  VENCTO   HISTORICO                DEBITO         CREDITO"
	cabec2 := Space(30)+cIdent+IIf(aTam[1]>6,Space(48),Space(34))+OemToAnsi(STR0032)  // "REAL"

	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Gera arquivo de Trabalho												  ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	aTam:=TamSX3("E1_CLIENTE")
	AADD(aCampos,{"CODIGO"  ,"C",aTam[1],aTam[2]})
	aTam:=TamSX3("E1_LOJA")
	AADD(aCampos,{"LOJA"    ,"C",aTam[1],aTam[2]})
	aTam:=TamSX3("E1_EMISSAO")
	AADD(aCampos,{"DATAX"    ,"D",aTam[1],aTam[2]})
	AADD(aCampos,{"NUMERO"  ,"C",16,0})
	aTam:=TamSX3("E1_EMISSAO")
	AADD(aCampos,{"EMISSAO" ,"D",aTam[1],aTam[2]})
	aTam:=TamSX3("E1_VENCREA")
	AADD(aCampos,{"VENCREA","D",aTam[1],aTam[2]})
	aTam:=TamSX3("E1_VLCRUZ")
	AADD(aCampos,{"VALOR"   ,"N",aTam[1],aTam[2]})
	AADD(aCampos,{"HISTOR"  ,"C",40,0})
	AADD(aCampos,{"DC"      ,"C",1,0})

	//cNomeArq:=CriaTrab(aCampos)
	//dbUseArea( .T.,, cNomeArq, "cNomeArq", if(.F. .OR. .F., !.F., NIL), .F. )
	//IndRegua("cNomeArq",cNomeArq,"Dtos(DataX)+Numero+Codigo+DC",,,OemToAnsi(STR0016))  //"Selecionando Registros..."

	_aArqTrb := {}
	If Select('TRB')<>0                                  //Se um tmp com alias TMP existir, fecha-o
		TRB->(dbCloseArea())
		u_arqtrb ("FechaTodos",,,, @_aArqTrb)
	Endif

	U_ArqTrb("Cria", "TRB", aCampos, {"DATAX","NUMERO","CODIGO","DC"}, @_aArqTrb)

	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Localiza e grava titulos a receber dentro dos parametros	  ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	If mv_par03 == 1
		dbSelectArea("SE1")
		dbSetOrder(6)
		#IFDEF TOP
		If TcSrvType() != "AS/400"
			cCondE1:=".T."
			cQuery := "SELECT * FROM " + RetSqlName("SE1") + " WHERE"
			cIndE1 :=IndexKey()

			If mv_par14 = 1
				cQuery += " E1_FILIAL = '" + xFilial("SE1") + "' AND "
			else
				cQuery += " E1_FILIAL BETWEEN '  ' AND 'ZZ' AND"
				cIndE1 :=Right(cIndE1,Len(cIndE1)-10)
			Endif
			cIndE1 := SqlOrder(cIndE1)

			dbSelectArea("SE1")
			dbCloseArea()
			dbSelectArea("SA1")

			cQuery += " E1_EMISSAO BETWEEN '" + DTOS(mv_par01) + "' AND '" + DTOS(mv_par02) + "'"
			cQuery += " AND E1_CLIENTE BETWEEN '" + mv_par04 + "' AND '" + mv_par05 + "'"
			cQuery += " AND E1_EMISSAO <= '" + DTOS(dDataBase) + "'"
			cQuery += " AND E1_TIPO NOT LIKE 'PR%'"
			If cPaisLoc <> "BRA"
				cQuery += " AND E1_TIPO NOT IN ('"+cSimb+"')"
			Endif
			cQuery += " AND E1_PREFIXO BETWEEN '" + mv_par12 + "' AND '" + mv_par13 + "'"
			cQuery += " AND E1_NATUREZ BETWEEN '" + mv_par16 + "' AND '" + mv_par17 + "'"
			cQuery += " AND D_E_L_E_T_ <> '*'"
			cQuery += " ORDER BY " + cIndE1

			cQuery := ChangeQuery(cQuery)
			dbUseArea(.T., "TOPCONN", TCGenQry(,,cQuery), 'SE1', .F., .T.)

			For ni := 1 to Len(aStru)
				If aStru[ni,2] != 'C'
					TCSetField('SE1', aStru[ni,1], aStru[ni,2],aStru[ni,3],aStru[ni,4])
				Endif
			Next
		else
			If mv_par14 = 1
				dbSeek(xFilial()+Dtos(mv_par01),.t.)
				cCondE1:="xFilial()==E1_FILIAL .and. E1_EMISSAO>=mv_par01 ..and. E1_EMISSAO<=mv_par02"
			Else
				cArqTrab :=CriaTrab(NIL,.F.)
				AADD(aInd,cArqTrab)
				cIndE1	:=IndexKey()
				cIndE1	:=Right(cIndE1,Len(cIndE1)-10)
				IndRegua("SE1",cArqTrab,cIndE1,,cCondE1,OemToAnsi(STR0016))  //"Selecionando Registros..."
				cCondE1:="E1_EMISSAO>=mv_par01 .and. E1_EMISSAO<=mv_par02"
				dbCommit()
				nIndex:=RetIndex("SE1")
				dbSelectArea("SE1")
				#IFNDEF TOP
				dbSetIndex(cArqTrab+OrdBagExt())
				#ENDIF

				dbSetOrder(nIndex+1)
				dbSeek(Dtos(mv_par01),.t.)
			Endif

		Endif
		#ENDIF

		dbSelectArea("SE1")
		While !Eof() .and. &(cCondE1)
			IF SE1->E1_CLIENTE < mv_par04 .or. SE1->E1_CLIENTE > mv_par05 .or. SE1->E1_EMISSAO > dDataBase
				dbskip()
				Loop
			Endif
			IF SE1->E1_TIPO $ MVPROVIS
				dbskip()
				Loop
			Endif
			If mv_par11 == 2 .and. E1_TIPO $ MVRECANT+"/"+MV_CRNEG
				dbskip()
				Loop
			Endif
			If mv_par11 == 3 .and. !(E1_TIPO $ MVRECANT+"/"+MV_CRNEG)
				dbskip()
				Loop
			Endif
			If cPaisLoc <> "BRA" .And. IsMoney(E1_TIPO)
				dbskip()
				Loop
			Endif
			If !Empty( mv_par12 )
				If SE1->E1_PREFIXO < mv_par12
					dbskip()
					Loop
				Endif
			Endif
			If !Empty( mv_par13 )
				If SE1->E1_PREFIXO > mv_par13
					dbskip()
					Loop
				Endif
			Endif
			If ( SE1->E1_NATUREZ < MV_PAR16 .Or. SE1->E1_NATUREZ > MV_PAR17 )
				dbskip()
				Loop
			Endif
			If ! Inside(SE1->E1_TIPO)
				dbskip()
				Loop
			Endif

			//  Teste da Conta Contabil
			DbSelectArea("SA1")
			DbSetOrder(1)
			DbSeek(xFilial("SA1")+SE1->E1_CLIENTE+SE1->E1_LOJA)
			If Found()
				If SA1->A1_CONTA < mv_par20 .Or. SA1->A1_CONTA > mv_par21
					dbSelectArea("SE1")
					dbskip()
					Loop
				Endif
			Endif
			DbSelectArea("SE1")

			//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
			//³ Grava debito no arquivo de trabalho - Emiss„o					  ³
			//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
			If mv_par18 == 1
				dDataConv := SE1->E1_EMISSAO
			Elseif mv_par18 == 2
				dDataConv := dDataBase
			Elseif mv_par18 == 3
				dDataConv := SE1->E1_VENCREA
			Else
				dDataConv := mv_par02
			Endif

			Reclock("TRB",.T.)
			Replace CODIGO  With SE1->E1_CLIENTE
			Replace LOJA    With SE1->E1_LOJA
			Replace DATAX   With SE1->E1_EMISSAO
			Replace NUMERO  With SE1->E1_PREFIXO+SE1->E1_NUM+SE1->E1_PARCELA
			Replace EMISSAO With SE1->E1_EMISSAO
			Replace VALOR   With If(mv_par18==1,SE1->E1_VLCRUZ,xMoeda(SE1->E1_VALOR,SE1->E1_MOEDA,1,dDataConv))
			Replace HISTOR  With Iif(Empty(SE1->E1_HIST),STR0031,SE1->E1_HIST)
			Replace VENCREA With SE1->E1_VENCREA

			IF !SE1->E1_TIPO $ MVABATIM .and. ! ( SE1->E1_TIPO $ MVRECANT+"/"+MV_CRNEG )
				Replace DC	 With "D"
			Else
				Replace DC	 With "C"    //Abatimentos/RA/NCC
			Endif
			MsUnlock()
			IF SE1->E1_TIPO $ MVABATIM .and. !Empty(SE1->E1_FATURA) .and. SE1->E1_FATURA != "NOTFAT" .and. SE1->E1_DTFATUR <= mv_par02
				Reclock("TRB",.T.)
				Replace CODIGO  With SE1->E1_CLIENTE
				Replace LOJA    With SE1->E1_LOJA
				Replace DATAX   With SE1->E1_DTFATUR
				Replace NUMERO  With SE1->E1_PREFIXO+SE1->E1_NUM+SE1->E1_PARCELA
				Replace EMISSAO With SE1->E1_DTFATUR
				Replace VALOR	 With If(mv_par18==1,SE1->E1_VLCRUZ,xMoeda(SE1->E1_VALOR,SE1->E1_MOEDA,1,dDataConv))
				Replace HISTOR  With STR0035+SE1->E1_FATURA  //"BX EMIS FAT "
				Replace VENCREA With SE1->E1_VENCREA
				Replace DC      With "D"
				MsUnlock()
			Endif

			dbSelectArea("SE1")
			dbSkip()
		Enddo
		#IFDEF TOP
		If TcSrvType() != "AS/400"
			DBSelectArea("SE1")
			DbCloseArea()
			ChkFile("SE1")
		Endif
		#ENDIF
	Endif

	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Localiza e grava titulos a pagar dentro dos parametros		  ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	if mv_par03 == 2
		aStru := SE2->(dbStruct())
		dbSelectArea("SE2")
		#IFDEF TOP
		If TcSrvType() != "AS/400"
			cCondE2:=".T."

			cQuery := "SELECT * FROM " + RetSqlName("SE2") + " WHERE"
			cIndE2 :=IndexKey()
			If mv_par14 = 1
				cQuery += " E2_FILIAL = '" + xFilial("SE2") + "' AND "
			else
				cQuery += " E2_FILIAL BETWEEN '  ' AND 'ZZ' AND"
				cIndE2 :=Right(cIndE2,Len(cIndE2)-10)
			Endif
			cIndE2 := SqlOrder(cIndE2)

			dbSelectArea("SE2")
			dbCloseArea()
			dbSelectArea("SA1")

			cQuery += " E2_EMIS1 BETWEEN '" + DTOS(mv_par01) + "' AND '" + DTOS(mv_par02) + "'"
			cQuery += " AND E2_FORNECE BETWEEN '" + mv_par04 + "' AND '" + mv_par05 + "'"
			cQuery += " AND E2_EMIS1 <= '" + DTOS(dDataBase) + "'"
			cQuery += " AND E2_PREFIXO BETWEEN '" + mv_par12 + "' AND '" + mv_par13 + "'"
			cQuery += " AND E2_NATUREZ BETWEEN '" + mv_par16 + "' AND '" + mv_par17 + "'"
			cQuery += " AND D_E_L_E_T_ <> '*'"
			cQuery += " ORDER BY " + cIndE2

			cQuery := ChangeQuery(cQuery)
			dbUseArea(.T., "TOPCONN", TCGenQry(,,cQuery), 'SE2', .F., .T.)

			For ni := 1 to Len(aStru)
				If aStru[ni,2] != 'C'
					TCSetField('SE2', aStru[ni,1], aStru[ni,2],aStru[ni,3],aStru[ni,4])
				Endif
			Next
		Else
			If mv_par14 = 1
				dbSetOrder(7)
				dbSeek(xFilial()+Dtos(mv_par01),.T.)
				cCondE2:="xFilial()==E2_FILIAL .and. E2_EMIS1>=mv_par01 .and. E2_EMIS1<=mv_par02"
			Else
				cArqTrab:=CriaTrab(NIL,.F.)
				AADD(aInd,cArqTrab)
				cIndE2:="Dtos(E2_EMIS1)+E2_PREFIXO+E2_NUM+E2_PARCELA+E2_TIPO+E2_FORNECE"
				IndRegua("SE2",cArqTrab,cIndE2,,,OemToAnsi(STR0016)) //"Selecionando Registros..."
				cCondE2:="E2_EMIS1>=mv_par01 .and. E2_EMIS1<=mv_par02"
				dbCommit()
				nIndex:=RetIndex("SE2")
				dbSelectArea("SE2")
				#IFNDEF TOP
				dbSetIndex(cArqTrab+OrdBagExt())
				#ENDIF
				dbSetOrder(nIndex+1)
				dbSeek(Dtos(mv_par01),.T.)
			Endif
		Endif
		#ENDIF

		While !Eof() .and. &(cCondE2)
			IF SE2->E2_FORNECE < mv_par04 .or. SE2->E2_FORNECE > mv_par05 .or. SE2->E2_EMIS1 > dDataBase
				dbskip()
				Loop
			Endif
			If mv_par03 == 1 .or. SE2->E2_TIPO $ MVPROVIS
				dbskip()
				Loop
			Endif
			If mv_par11 == 2 .and. (E2_TIPO $ MVPAGANT+"/"+MV_CPNEG)
				dbskip()
				Loop
			Endif
			If mv_par11 == 3 .and. ! ( E2_TIPO $ MVPAGANT+"/"+MV_CPNEG)
				dbskip()
				Loop
			Endif
			If !Empty( mv_par12 )
				If SE2->E2_PREFIXO < mv_par12
					dbskip()
					Loop
				Endif
			Endif
			If !Empty( mv_par13 )
				If SE2->E2_PREFIXO > mv_par13
					dbskip()
					Loop
				Endif
			Endif
			If ( SE2->E2_NATUREZ < MV_PAR16 .Or. SE2->E2_NATUREZ > MV_PAR17 )
				dbskip()
				Loop
			Endif
			If !Inside(SE2->E2_TIPO)
				dbskip()
				Loop
			Endif

			//  Teste da Conta Contabil
			DbSelectArea("SA2")
			DbSetOrder(1)
			DbSeek(xFilial("SA2")+SE2->E2_FORNECE+SE2->E2_LOJA)
			If Found()
				If SA2->A2_CONTA < mv_par20 .Or. SA2->A2_CONTA > mv_par21
					DbSelectArea("SE2")
					dbskip()
					Loop
				Endif
			Endif
			DbSelectArea("SE2")

			//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
			//³ Grava debito no arquivo de trabalho - Emiss„o					  ³
			//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
			If mv_par18 == 1
				dDataConv := SE2->E2_EMIS1			// emissao da contabilizacao
			Elseif mv_par18 == 2
				dDataConv := dDataBase
			Elseif mv_par18 == 3
				dDataConv := SE2->E2_VENCREA
			Else
				dDataConv := mv_par02
			Endif

			//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
			//³ Grava credito no arquivo de trabalho	- Emiss„o              ³
			//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
			Reclock("TRB",.T.)
			Replace CODIGO  With SE2->E2_FORNECE
			Replace LOJA    With SE2->E2_LOJA
			Replace DATAX   With SE2->E2_EMIS1
			Replace NUMERO  With SE2->E2_PREFIXO+SE2->E2_NUM+SE2->E2_PARCELA
			Replace EMISSAO With SE2->E2_EMISSAO
			Replace VALOR   With If(mv_par18==1,SE2->E2_VLCRUZ,xMoeda(SE2->E2_VALOR,SE2->E2_MOEDA,1,dDataConv))
			Replace HISTOR  With Iif(Empty(SE2->E2_HIST),STR0031,SE2->E2_HIST)
			Replace VENCREA With SE2->E2_VENCREA

			If !(SE2->E2_TIPO $ MVABATIM) .and. ! ( SE2->E2_TIPO $ MVPAGANT+"/"+MV_CPNEG)
				Replace DC	 With "C"
			Else
				Replace DC	 With "D"    //Abatimentos
			Endif
			MsUnlock()
			IF SE2->E2_TIPO $ MVABATIM .and. !Empty(SE2->E2_FATURA) .and. SE2->E2_FATURA != "NOTFAT" .and. SE2->E2_DTFATUR <= mv_par02
				Reclock("TRB",.T.)
				Replace CODIGO  With SE2->E2_FORNECE
				Replace LOJA    With SE2->E2_LOJA
				Replace DATAX   With SE2->E2_DTFATUR
				Replace NUMERO  With SE2->E2_PREFIXO+SE2->E2_NUM+SE2->E2_PARCELA
				Replace EMISSAO With SE2->E2_DTFATUR
				Replace VALOR   With If(mv_par18==1,SE2->E2_VLCRUZ,xMoeda(SE2->E2_VALOR,SE2->E2_MOEDA,1,dDataConv))
				Replace HISTOR  With STR0035+SE2->E2_FATURA  //"BX EMIS FAT "
				Replace VENCREA With SE2->E2_VENCREA
				Replace DC      With "C"
				MsUnlock()
			Endif

			dbSelectArea("SE2")
			dbSkip()
		Enddo

		#IFDEF TOP
		If TcSrvType() != "AS/400"
			DBSelectArea("SE2")
			DbCloseArea()
			ChkFile("SE2")
		Endif
		#ENDIF
	Endif

	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Localiza na movimenta‡„o banc ria, os titulos do periodo	  ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	dbSelectArea("SE5")
	dbSetOrder(4)

	#IFDEF TOP
	If TcSrvType() != "AS/400"
		cAliasTmp := "NEWSE5"
		aStru := SE5->(dbStruct())
		cCondE5:=".T."

		cQuery := "SELECT E5_FILIAL,E5_DATA,E5_TIPO,E5_MOEDA,CASE E5_TIPO WHEN 'NDF' THEN E5_VALOR-E5_VLJUROS ELSE E5_VALOR END AS E5_VALOR,"
		cQuery += "       E5_NATUREZ,E5_BANCO,E5_AGENCIA,E5_CONTA,E5_NUMCHEQ,E5_VENCTO,E5_RECPAG,E5_HISTOR,E5_TIPODOC,E5_VLMOED2,E5_SITUACA,"
		cQuery += "       E5_PREFIXO,E5_NUMERO,E5_PARCELA,E5_CLIFOR,E5_LOJA,E5_DTDIGIT,E5_MOTBX,E5_SEQ,E5_ORDREC,E5_VLJUROS,E5_VLMULTA,E5_VLCORRE,"
		cQuery += "       E5_VLDESCO,E5_FATURA,E5_TXMOEDA,E5_CLIENTE,E5_FORNECE,E5_VRETPIS,E5_VRETCOF,E5_VRETCSL,E5_PRETPIS,E5_PRETCOF,E5_PRETCSL,"
		cQuery += "       E5_FILORIG,E5_TABORI,E5_IDORIG FROM " + RetSqlName("SE5") + " WHERE"
		cIndE5 :=IndexKey()

		cQuery += " E5_FILIAL = '" + xFilial("SE5") + "' AND "
		cIndE5 := SqlOrder(cIndE5)
		dbSelectArea("SA1")

		cQuery += " E5_FILORIG BETWEEN '  ' AND 'ZZ' AND "
		cQuery += " E5_DTDIGIT BETWEEN '" + DTOS(mv_par01) + "' AND '" + DTOS(mv_par02) + "'"
		cQuery += " AND E5_NUMERO <> '" +space(TamSX3("E5_NUMERO")[1])+"'"
		cQuery += " AND E5_SITUACA <> 'C'"
		cQuery += " AND (E5_VALOR <> 0 OR (E5_VLDESCO > 0 AND E5_VALOR = 0))"
		cQuery += " AND E5_DTDIGIT <= '"+DTOS(dDataBase)+ "'"
		cQuery += " AND E5_CLIFOR BETWEEN '" + mv_par04 + "' AND '" + mv_par05 + "'"
		cQuery += " AND E5_PREFIXO BETWEEN '" + mv_par12 + "' AND '" + mv_par13 + "'"
		cQuery += " AND E5_NATUREZ BETWEEN '" + mv_par16 + "' AND '" + mv_par17 + "'"
		//cQuery += " AND E5_TIPODOC IN ('VL','VM','BA','CP','LJ','V2','ES','PA','RA','VA')"
		cQuery += " AND D_E_L_E_T_ = ' '"
		If cPaisLoc <> "BRA"
			cQuery += " AND (E5_TIPO NOT IN ('"+cSimb+"') AND E5_TIPODOC <> 'LJ' ) "
		Endif
		If mv_par03 == 1
			cQuery += " AND ((E5_RECPAG = 'R')"
			cQuery += " OR (E5_TIPODOC = 'ES' AND E5_RECPAG = 'P')"
			cQuery += " OR (E5_TIPO IN "+FormatIn(MV_CRNEG+"|"+MVRECANT,If("|"$MV_CRNEG+"|"+MVRECANT,"|",","))+" AND E5_RECPAG = 'P'))"
		Endif
		If mv_par03 == 2
			cQuery += " AND ((E5_RECPAG = 'P')"
			cQuery += " OR  (E5_TIPODOC = 'ES' AND E5_RECPAG = 'R')"
			cQuery += " OR  (E5_TIPO IN "+FormatIn(MV_CPNEG+"|"+MVPAGANT,If("|"$MV_CPNEG+"|"+MVPAGANT,"|",","))+" AND E5_RECPAG = 'R'))"
		Endif

		cQuery += " ORDER BY " + cIndE5

		cQuery := ChangeQuery(cQuery)
		
		dbUseArea(.T., "TOPCONN", TCGenQry(,,cQuery), cAliasTmp, .F., .T.)

		For ni := 1 to Len(aStru)
			If aStru[ni,2] != 'C'
				TCSetField(cAliasTmp, aStru[ni,1], aStru[ni,2],aStru[ni,3],aStru[ni,4])
			Endif
		Next
	Else
		cAliasTmp := "SE5"
		If mv_par14 = 1
			dbSeek(xFilial(),.T.)
			cCondE5:="xFilial()==E5_FILIAL"
		Else
			cArqTrab :=CriaTrab(NIL,.F.)
			AADD(aInd,cArqTrab)
			cIndE5	:=IndexKey()
			cIndE5	:=Right(cIndE5,Len(cIndE5)-10)
			IndRegua("SE5",cArqTrab,cIndE5,,,OemToAnsi(STR0016))  //"Selecionando Registros..."
			cCondE5:=".T."
			dbCommit()
			nIndex:=RetIndex("SE5")
			dbSelectArea("SE5")
			#IFNDEF TOP
			dbSetIndex(cArqTrab+ordBagExt())
			#ENDIF
			dbSetOrder(nIndex+1)
			dbGoTop()
		Endif

	Endif
	#ENDIF

	If mv_par14 == 2
		If mv_par03 == 1
			// SE1
			dbSelectArea("SE1")
			dbSetOrder(1)
			cArqTrab :=CriaTrab(NIL,.F.)
			AADD(aInd,cArqTrab)
			cIndE1:=IndexKey()
			cIndE1:=Right(cIndE1,Len(cIndE1)-10)
			IndRegua("SE1",cArqTrab,cIndE1,,,OemToAnsi(STR0016)) //"Selecionando Registros..."
			dbCommit()
			nIndex:=RetIndex("SE1")
			dbSelectArea("SE1")
			#IFNDEF TOP
			dbSetIndex(cArqTrab+OrdBagExT())
			#ENDIF
			dbSetOrder(nIndex+1)
			dbGotop()
		Endif
		If mv_par03 == 2
			// SE2
			dbSelectArea("SE2")
			dbSetOrder(1)
			cArqTrab :=CriaTrab(NIL,.F.)
			AADD(aInd,cArqTrab)
			cIndE2:=IndexKey()
			cIndE2:=Right(cIndE2,Len(cIndE2)-10)
			IndRegua("SE2",cArqTrab,cIndE2,,,OemToAnsi(STR0016) )  //"Selecionando Registros..."
			dbCommit()
			nIndex:=RetIndex("SE2")
			dbSelectArea("SE2")
			#IFNDEF TOP
			dbSetIndex(cArqTrab+OrdBagExt())
			#ENDIF
			dbSetOrder(nIndex+1)
			dbGoTop()
		Endif
	Endif

	dbSelectArea(cAliasTmp)

	While !Eof() .and. &(cCondE5)

		// Se for um recebimento de Titulo pago em dinheiro originado pelo SIGALOJA, nao imprime o mov.
		If (cAliasTmp)->E5_TIPODOC == "BA" .AND. (cAliasTmp)->E5_MOTBX == "LOJ" .AND. IsMoney((cAliasTmp)->E5_MOEDA)
			(cAliasTmp)->(dbSkip())
			Loop
		EndIf

		IF (Empty(E5_NUMERO)) .or. (E5_SITUACA = "C") .or. (E5_DTDIGIT > dDataBase)
			dbskip()
			Loop
		Endif

		If	!(cAliasTmp)->E5_TIPODOC $ "VL/VM/BA/CP/V2/LJ/ES/PA/RA"
			(cAliasTmp)->(dbSkip())
			Loop
		Endif

		If (cAliasTmp)->E5_MOTBX == "DSD"
			(cAliasTmp)->(dbSkip())
			Loop
		EndIf
		//Ignorar baixas do Loja de titulos a vista
		If cPaisLoc <> "BRA" .And. E5_RECPAG=='R' .And. IsMoney((cAliasTmp)->E5_TIPO) .And. E5_TIPODOC == "LJ"
			(cAliasTmp)->(dbSkip())
			Loop
		EndIf

		If mv_par19 == 2
			//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
			//³ Verifica se existe estorno para esta baixa                       ³
			//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
			dbSelectArea(cAliasTmp)
			If TemBxCanc((cAliasTmp)->(	E5_PREFIXO+E5_NUMERO+E5_PARCELA+E5_TIPO+E5_CLIFOR+E5_LOJA+E5_SEQ))
				(cAliasTmp)->( dbSkip())
				Loop
			EndIf
		Endif

		If ((cAliasTmp)->E5_TIPO $ MVRECANT) .and. (cAliasTmp)->E5_TIPODOC == "ES" .and. mv_par03 == 1
			dbSelectArea("SE1")
			If mv_par14 = 1
				SE1->(dbSetOrder(1))
				SE1->(dbSeek(xFilial()+(cAliasTmp)->(E5_PREFIXO+E5_NUMERO+E5_PARCELA+E5_TIPO)))
			Else
				SE1->(dbSeek((cAliasTmp)->(E5_PREFIXO+E5_NUMERO+E5_PARCELA+E5_TIPO)))
			Endif
			If !(Found())
				dbSelectArea(cAliasTmp)
				(cAliasTmp)->(dbSkip())
				Loop
			Endif
		Endif

		If ((cAliasTmp)->E5_TIPO $ MVPAGANT) .and. (cAliasTmp)->E5_TIPODOC == "ES"  .and. mv_par03 == 2
			dbSelectArea("SE2")
			If mv_par14 = 1
				SE2->(dbSetOrder(1))
				SE2->(dbSeek(xFilial()+(cAliasTmp)->(E5_PREFIXO+E5_NUMERO+E5_PARCELA+E5_TIPO+E5_CLIFOR+E5_LOJA)))
			Else
				SE2->(dbSeek((cAliasTmp)->(E5_PREFIXO+E5_NUMERO+E5_PARCELA+E5_TIPO+E5_CLIFOR+E5_LOJA)))
			Endif
			If !(Found())
				dbSelectArea(cAliasTmp)
				(cAliasTmp)->(dbSkip())
				Loop
			Endif
		Endif
		dbSelectArea(cAliasTmp)

		IF E5_DTDIGIT < mv_par01 .or. E5_DTDIGIT > mv_par02
			dbskip()
			Loop
		Endif

		IF E5_CLIFOR < mv_par04  .or. E5_CLIFOR > mv_par05
			dbskip()
			Loop
		Endif

		// Clientes
		If mv_par03 == 1 //.And. (cAliasTmp)->E5_RECPAG == "R"
			//  Teste da Conta Contabil
			DbSelectArea("SA1")
			DbSetOrder(1)
			DbSeek(xFilial("SA1")+(cAliasTmp)->E5_CLIFOR+(cAliasTmp)->E5_LOJA)
			If Found()
				If SA1->A1_CONTA < mv_par20 .Or. SA1->A1_CONTA > mv_par21
					dbSelectArea(cAliasTmp)
					(cAliasTmp)->(dbSkip())
					Loop
				Endif
			Endif
			dbSelectArea((cAliasTmp))
		Endif

		// Fornecedores
		If mv_par03 == 2 //.And. (cAliasTmp)->E5_RECPAG == "P"
			//  Teste da Conta Contabil
			DbSelectArea("SA2")
			DbSetOrder(1)
			DbSeek(xFilial("SA2")+(cAliasTmp)->E5_CLIFOR+(cAliasTmp)->E5_LOJA)
			If Found()
				If SA2->A2_CONTA < mv_par20 .Or. SA2->A2_CONTA > mv_par21
					dbSelectArea(cAliasTmp)
					(cAliasTmp)->(dbSkip())
					Loop
				Endif
			Endif
			dbSelectArea((cAliasTmp))
			//
		Endif

		If !Empty( mv_par12 )
			If (cAliasTmp)->E5_PREFIXO < mv_par12
				dbskip()
				Loop
			Endif
		Endif

		If !Empty( mv_par13 )
			If (cAliasTmp)->E5_PREFIXO > mv_par13
				dbskip()
				Loop
			Endif
		Endif

		If ( (cAliasTmp)->E5_NATUREZ < MV_PAR16 .Or. (cAliasTmp)->E5_NATUREZ > MV_PAR17 )
			dbskip()
			Loop
		Endif

		If (cAliasTmp)->E5_RECPAG == "R" .and. mv_par03 == 1
			//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
			//³ Verifica quais serao impressos										  ³
			//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
			If mv_par11 == 2 .and. (E5_TIPO $ MVRECANT) // So'Normais
				dbskip()
				Loop
			Endif

			If mv_par11 == 3 .and. !(E5_TIPO $ MVRECANT)  //So'Adiantamentos
				dbskip()
				Loop
			Endif
		ElseIf (cAliasTmp)->E5_RECPAG == "P" .and. mv_par03 == 2
			//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
			//³ Verifica quais serao impressos										  ³
			//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
			If mv_par11 == 2 .and. (E5_TIPO $ MVPAGANT) // So'Normais
				dbskip()
				Loop
			Endif
			If mv_par11 == 3 .and. !(E5_TIPO $ MVPAGANT) //So'Adiantamentos
				dbskip()
				Loop
			Endif
			//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
			//³ Ignora PA's pagos com Junta de Cheque                        ³
			//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
			If (E5_TIPO $ MVPAGANT) .and. E5_TIPODOC == "BA" .And. !E5_MOTBX $ "CMP"	// .and. !empty(E5_NUMCHEQ)
				dbskip()
				Loop
			Endif
		Endif

		If mv_par03 == 1 .and. (cAliasTmp)->E5_RECPAG == "R" .and. (cAliasTmp)->E5_TIPODOC =="ES" .and. !((cAliasTmp)->E5_TIPO $ MVRECANT+"/"+MV_CRNEG)
			dbskip()
			loop
		Elseif mv_par03 == 2 .and. (cAliasTmp)->E5_RECPAG == "P" .and. (cAliasTmp)->E5_TIPODOC =="ES"  .and. !((cAliasTmp)->E5_TIPO $ MVPAGANT+"/"+MV_CPNEG)
			dbskip()
			loop
		Endif

		IF mv_par03 == 1 .and. (cAliasTmp)->E5_RECPAG != "R"
			If (!((cAliasTmp)->E5_TIPO $ MVRECANT+"/"+MV_CRNEG ) .AND. (cAliasTmp)->E5_TIPODOC !="ES") .or. ; //Baixa de RA
			((cAliasTmp)->E5_TIPO $ MVPAGANT+"/"+MV_CPNEG .AND. (cAliasTmp)->E5_TIPODOC =="ES") .or. ;  //Estorno da Baixa de PA
			(( (cAliasTmp)->E5_TIPO $ MVRECANT) .AND. mv_par11 == 2).or. ;
			(!((cAliasTmp)->E5_TIPO $ MVRECANT) .AND. mv_par11 == 3)

				(cAliasTmp)->(dbSkip())
				Loop
			Endif
		Endif
		IF mv_par03 == 2 .and. (cAliasTmp)->E5_RECPAG != "P"
			If (!( (cAliasTmp)->E5_TIPO $ MVPAGANT+"/"+MV_CPNEG ) .AND. (cAliasTmp)->E5_TIPODOC !="ES") .or.;   //Baixa de PA
				((cAliasTmp)->E5_TIPO $ MVRECANT+"/"+MV_CRNEG .AND. (cAliasTmp)->E5_TIPODOC =="ES") .or. ;  //Estorno da Baixa de RA
				(( (cAliasTmp)->E5_TIPO $ MVPAGANT) .AND. mv_par11 == 2).or. ;
				(!((cAliasTmp)->E5_TIPO $ MVPAGANT) .AND. mv_par11 == 3)

				(cAliasTmp)->(dbSkip())
				Loop
			Endif
		Endif

		If mv_par03 == 1 		 // Se for baixa de adiantamentos															//DC retirado
			If (cAliasTmp)->E5_RECPAG == "R" .and. E5_TIPO $ MVPAGANT+"/"+MV_CPNEG .AND. (cAliasTmp)->E5_TIPODOC $ "VL/BA/D2/MT/JR/J2/M2/CM/C2/CX/VA"
				dbskip()
				LOOP
			Endif
		Endif

		If mv_par03 == 2			// Se for baixa de adiantamentos														//DC retirado
			If (cAliasTmp)->E5_RECPAG == "P" .and. E5_TIPO $ MVRECANT+"/"+MV_CRNEG .AND. (cAliasTmp)->E5_TIPODOC $ "VL/BA/D2/MT/JR/J2/M2/CM/C2/CX/VA"
				dbskip()
				LOOP
			Endif
		Endif

		If cPaisLoc<>"BRA" .And. E5_TIPO=="EF |TF" .And. !Empty(E5_ORDREC)
			dbskip()
			Loop
		Endif

		If ! Inside((cAliasTmp)->E5_TIPO)
			dbskip()
			Loop
		Endif

		IF Empty(E5_NUMERO) .or. E5_SITUACA = "C"
			(cAliasTmp)->(dbSkip())
			Loop
		Endif

		nRec	:= (cAliasTmp)->(Recno())

		nPrim    := 0
		cPrefixo := E5_PREFIXO
		cNumero  := E5_NUMERO
		cParcela := E5_PARCELA
		cTipo    := E5_TIPO
		cNaturez := E5_NATUREZ
		nValliq  := 0
		cFornece := E5_CLIFOR
		dDtDigit := E5_DTDIGIT
		cRecPag  := E5_RECPAG
		cLoja    := E5_LOJA

		#IFNDEF TOP
		If mv_par03 == 1
			If nAnterior = 0
				nAnterior := 1
				If mv_par14 = 1
					dbSeek(xFilial("SE5")+cNaturez+cPrefixo+cNumero+cParcela+cTipo+Dtos(dDtDigit)+cRecPag)
				Else
					dbSeek(cNaturez+cPrefixo+cNumero+cParcela+cTipo+Dtos(dDtDigit)+cRecPag)
				Endif
			Endif
		Elseif mv_par03 == 2
			If nAnterior = 0
				nAnterior := 1
				If mv_par14 = 1
					dbSeek(xFilial("SE5")+cNaturez+cPrefixo+cNumero+cParcela+cTipo+Dtos(dDtDigit)+cRecPag+cFornece+cLoja)
				Else
					dbSeek(cNaturez+cPrefixo+cNumero+cParcela+cTipo+Dtos(dDtDigit)+cRecPag+cFornece+cLoja)
				Endif
			Endif
		Endif
		#ELSE
		If TcSrvType() == "AS/400"
			dbSelectArea(cAliasTmp)
			If mv_par03 == 1
				If nAnterior = 0
					nAnterior := 1
					If mv_par14 = 1
						dbSetOrder(4)
						dbSeek(xFilial("SE5")+cNaturez+cPrefixo+cNumero+cParcela+cTipo+Dtos(dDtDigit)+cRecPag)
					Else
						dbSeek(cNaturez+cPrefixo+cNumero+cParcela+cTipo+Dtos(dDtDigit)+cRecPag)
					Endif
				Endif
			Elseif mv_par03 == 2
				If nAnterior = 0
					nAnterior := 1
					If mv_par14 = 1
						dbSetOrder(4)
						dbSeek(xFilial("SE5")+cNaturez+cPrefixo+cNumero+cParcela+cTipo+Dtos(dDtDigit)+cRecPag+cFornece+cLoja)
					Else
						dbSeek(cNaturez+cPrefixo+cNumero+cParcela+cTipo+Dtos(dDtDigit)+cRecPag+cFornece+cLoja)
					Endif
				Endif
			Endif
		Endif
		#ENDIF

		While !Eof() .and. E5_PREFIXO == cPrefixo .and. E5_NUMERO == cNumero	.and. E5_PARCELA == cParcela .and. E5_TIPO == cTipo .and. E5_NATUREZ == cNaturez .and. E5_DTDIGIT == dDtDigit .and. E5_RECPAG	== cRecPag
			If mv_par03 == 2 .and. E5_CLIFOR+E5_LOJA != cFornece+cLoja
				Exit
			Endif

			If mv_par19 == 2
				//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
				//³ Verifica se existe estorno para esta baixa                       ³
				//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
				dbSelectArea( cAliasTmp)
				If TemBxCanc(	(cAliasTmp)->(	E5_PREFIXO+E5_NUMERO	+;
				E5_PARCELA+E5_TIPO	+;
				E5_CLIFOR+E5_LOJA+E5_SEQ))
					(cAliasTmp)->( dbSkip())
					Loop
				EndIf
			Endif

			//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
			//³ Devera' ser considerado o valor liquido da baixa          ³
			//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
			IF Empty(E5_NUMERO) .or. E5_SITUACA = "C"
				dbSkip()
				Loop
			Endif

			IF E5_DTDIGIT < mv_par01 .or. E5_DTDIGIT > mv_par02
				dbSkip()
				Loop
			Endif

			IF E5_CLIFOR < mv_par04 .or. E5_CLIFOR > mv_par05
				dbSkip()
				Loop
			Endif

			IF mv_par03 == 1 .and. (cAliasTmp)->E5_RECPAG != "R"
				If (!((cAliasTmp)->E5_TIPO $ MVRECANT+"/"+MV_CRNEG ) .AND. (cAliasTmp)->E5_TIPODOC !="ES") .or. ; //Baixa de RA
				((cAliasTmp)->E5_TIPO $ MVPAGANT+"/"+MV_CPNEG .AND. (cAliasTmp)->E5_TIPODOC =="ES")  //Estorno da Baixa de PA
					(cAliasTmp)->(dbSkip())
					Loop
				Endif
			Endif

			IF mv_par03 == 2 .and. (cAliasTmp)->E5_RECPAG != "P"
				If (!( (cAliasTmp)->E5_TIPO $ MVPAGANT+"/"+MV_CPNEG ) .AND. (cAliasTmp)->E5_TIPODOC !="ES") .or.;   //Baixa de PA
				((cAliasTmp)->E5_TIPO $ MVRECANT+"/"+MV_CRNEG .AND. (cAliasTmp)->E5_TIPODOC =="ES")  //Estorno da Baixa de RA
					(cAliasTmp)->(dbSkip())
					Loop
				Endif
			Endif
			If mv_par03 == 1        // Se for baixa de adiantamentos
				If (cAliasTmp)->E5_RECPAG == "R" .and. E5_TIPO $ MVPAGANT+"/"+MV_CPNEG .AND. (cAliasTmp)->E5_TIPODOC $ "VL/BA/DC/D2/MT/JR/J2/M2/CM/C2/CX"
					dbSkip()
					LOOP
				Endif
			Endif

			If mv_par03 == 2        // Se for baixa de adiantamentos
				If (cAliasTmp)->E5_RECPAG == "P" .and. E5_TIPO $ MVRECANT+"/"+MV_CRNEG .AND. (cAliasTmp)->E5_TIPODOC $ "VL/BA/DC/D2/MT/JR/J2/M2/CM/C2/CX"
					dbSkip()
					LOOP
				Endif
			Endif

			// Clientes
			If mv_par03 == 1 //.And. (cAliasTmp)->E5_RECPAG == "R"
				//  Teste da Conta Contabil
				DbSelectArea("SA1")
				DbSetOrder(1)
				DbSeek(xFilial("SA1")+(cAliasTmp)->E5_CLIFOR+(cAliasTmp)->E5_LOJA)
				If Found()
					If SA1->A1_CONTA < mv_par20 .Or. SA1->A1_CONTA > mv_par21
						dbSelectArea(cAliasTmp)
						(cAliasTmp)->(dbSkip())
						Loop
					Endif
				Endif
				dbSelectArea((cAliasTmp))
			Endif

			// Fornecedores
			If mv_par03 == 2 //.And. (cAliasTmp)->E5_RECPAG == "P"
				//  Teste da Conta Contabil
				DbSelectArea("SA2")
				DbSetOrder(1)
				DbSeek(xFilial("SA2")+(cAliasTmp)->E5_CLIFOR+(cAliasTmp)->E5_LOJA)
				If Found()
					If SA2->A2_CONTA < mv_par20 .Or. SA2->A2_CONTA > mv_par21
						dbSelectArea(cAliasTmp)
						(cAliasTmp)->(dbSkip())
						Loop
					Endif
				Endif
				dbSelectArea((cAliasTmp))
			Endif

			IF nPrim == 0
				//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
				//³ Localiza o cliente ou fornecedor								  ³
				//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
				cCarteira := E5_RECPAG
				If E5_RECPAG == "R"
					If ( E5_TIPO$ MVPAGANT+"/"+MV_CPNEG).and.E5_TIPODOC $ "BAüVL" .OR. E5_TIPODOC =="ES"
						cCarteira := "P"        //Baixa de adiantamento (inverte)
					Endif
					IF	(E5_TIPO$ MVRECANT+"/"+MV_CRNEG)
						cCarteira := "R"		  //Cancelamento da Baixa Adiantamento
					Endif
				Endif

				If E5_RECPAG == "P"
					If (E5_TIPO$MVRECANT+"/"+MV_CRNEG).and.E5_TIPODOC $ "BAüVL" .OR. E5_TIPODOC =="ES"
						cCarteira := "R"        //Baixa de adiantamento (inverte)
					Endif
					IF	(E5_TIPO$ MVPAGANT+"/"+MV_CPNEG)
						cCarteira := "P"		  //Cancelamento da Baixa Adiantamento
					Endif
				Endif

				dbSelectArea(cAliasTmp)
				IF cCarteira == "R"
					If mv_par14 = 1
						SE1->(dbSetOrder(1))
						SE1->(dbSeek(xFilial()+(cAliasTmp)->(E5_PREFIXO+E5_NUMERO+E5_PARCELA+E5_TIPO)))
					Else
						SE1->(dbSeek((cAliasTmp)->(E5_PREFIXO+E5_NUMERO+E5_PARCELA+E5_TIPO)))
					Endif
					If SE1->(!Found())
						dbSelectArea(cAliasTmp)
						DbSkip()
						Loop
					Endif
				Else
					If mv_par14 = 1
						SE2->(dbSetOrder(1))
						SE2->(dbSeek(xFilial()+(cAliasTmp)->(E5_PREFIXO+E5_NUMERO+E5_PARCELA+E5_TIPO+E5_CLIFOR+E5_LOJA)))
					Else
						SE2->(dbSeek((cAliasTmp)->(E5_PREFIXO+E5_NUMERO+E5_PARCELA+E5_TIPO+E5_CLIFOR+E5_LOJA)))
					Endif
					If SE2->(!Found())
						dbSelectArea(cAliasTmp)
						DbSkip()
						Loop
					Endif
				Endif
				IF cCarteira == "R"
					dEmissao:=SE1->E1_EMISSAO
					dVencto :=SE1->E1_VENCREA
					nMoedaT	:=	SE1->E1_MOEDA
					If mv_par18 == 1
						dDataConv := SE1->E1_EMISSAO
					Elseif mv_par18 == 2
						dDataConv := dDataBase
					Elseif mv_par18 == 3
						dDataConv := SE1->E1_VENCREA
					Else
						dDataConv := mv_par02
					Endif
				Else
					dEmissao:=SE2->E2_EMIS1
					dVencto :=SE2->E2_VENCREA
					nMoedaT	:=	SE2->E2_MOEDA
					If mv_par18 == 1
						dDataConv := SE2->E2_EMIS1
					Elseif mv_par18 == 2
						dDataConv := dDataBase
					Elseif mv_par18 == 3
						dDataConv := SE2->E2_VENCREA
					Else
						dDataConv := mv_par02
					Endif
				Endif
				nPrim++
			Endif

			//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
			//³ Monta Array com dados do titulo Pai. Usado apenas quando for       ³
			//³ TOP, nÆo AS/400, e NÆo imprimir valores financeiros (mv_par10 = 2) ³
			//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
			#IFDEF TOP
			If TcSrvType() != "AS/400" .and. mv_par10 == 2
				aDadosSe5 := TrabDados(cAliasTmp)
			Endif
			#ENDIF
			//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
			//³ A fun‡Æo TRABDADOS() ‚ utilizada para montar array com os da-³
			//³ dos necessarios do SE5 para a grava‡Æo no arquivo de trabalho³
			//³ Isto se deve ao fato de no SQL, quando mv_par10 = 2 (nÆo im- ³
			//³ prime valores financeiros), a Query est  sempre um registro  ³
			//³ posterior a montagem dos valores e nÆo ser possivel reposi-  ³
			//³ cionar no registro devido                                    ³
			//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
			IF E5_TIPODOC $ "VL/LJ/ES"
				nValliq+=IIf(cPaisLoc=="BRA",E5_VALOR,xMoeda(E5_VLMOED2,nMoedaT,1,dDataConv))
				IIF(mv_par10==1,GRAVATRAB("B",dEmissao,dVencto,,TrabDados(cAliasTmp),cAliasTmp,dDataConv),NIL)
			ElseIF E5_TIPODOC $ "BA/V2/CP"
				nValliq+=	IIf(cPaisLoc=="BRA",E5_VALOR,xMoeda(E5_VLMOED2,nMoedaT,1,dDataConv))
				IIF(mv_par10==1,GRAVATRAB("B",dEmissao,dVencto,,TrabDados(cAliasTmp),cAliasTmp,dDataConv),NIL)
			ElseIF E5_TIPODOC $ "DC/D2"
				nValliq+=	IIf(cPaisLoc=="BRA",E5_VALOR,xMoeda(E5_VLMOED2,nMoedaT,1,dDataConv))
				IIF(mv_par10==1,GRAVATRAB("D",dEmissao,dVencto,,TrabDados(cAliasTmp),cAliasTmp,dDataConv),NIL)
			Elseif E5_TIPODOC $ "MT/JR/J2/M2"
				IIF(mv_par10==1,GRAVATRAB("M",dEmissao,dVencto,,TrabDados(cAliasTmp),cAliasTmp,dDataConv),NIL)
				nValliq-=	IIf(cPaisLoc=="BRA",E5_VALOR,xMoeda(E5_VLMOED2,nMoedaT,1,dDataConv))
			Elseif E5_TIPODOC $ "CM/C2/CX"
				IIF(mv_par10==1,GRAVATRAB("C",dEmissao,dVencto,,TrabDados(cAliasTmp),cAliasTmp,dDataConv),NIL)
				nValliq-=	IIf(cPaisLoc=="BRA",E5_VALOR,xMoeda(E5_VLMOED2,nMoedaT,1,dDataConv))
			Endif
			dbSkip()
		Enddo
		#IFNDEF TOP
		nRec1 := (cAliasTmp)->(Recno())
		dBGoto(nRec)
		#ENDIF

		IF mv_par10==2 .and. nValLiq != 0
			#IFDEF TOP
			If TcSrvType() != "AS/400"
				GravaTrab("B",dEmissao,dVencto,nValLiq,aDadosSE5,cAliasTmp,dDataConv)
			Else
				GravaTrab("B",dEmissao,dVencto,nValLiq,TrabDados(cAliasTmp),cAliasTmp,dDataConv)
			Endif
			#ENDIF
		Endif
		#IFNDEF TOP
		dbGoto(nRec1)
		#ENDIF
		nAnterior := 0
	Enddo
	#IFDEF TOP
	If TcSrvType() != "AS/400"
		DBSelectArea(cAliasTmp)
		DbCloseArea()
		ChkFile("SE5")
	Endif
	#ENDIF

	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Inicia rotina de impressao											  ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	dbSelectArea("TRB")
	dbGoTop()

	SetRegua(RecCount())

	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Array com colunas da impressao										  ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	aTam	:= TAMSX3("E1_CLIENTE")
	aColu   := IIF (aTam[1] > 6,{051,073,084,095,117,132},{037,059,070,081,103,118})
	_lSaldo := IIF(mv_par20==mv_par21,.T.,.F.)
	_lVez   := .T.

	While !Eof()
		IF lEnd
			@PROW()+1,0 PSAY OemToAnsi(STR0017)  //"Cancelado pelo Operador"
			Exit
		Endif

		IF li > 58
			IF m_pag == mv_par07
				m_pag := 2
			Endif
			cabec(titulo,cabec1,cabec2,nomeprog,tamanho,IIF(nCompress==1,15,18))
		Endif

		IF nQuebra == 0
			dData := DATAX
			nTotTit := 0
			nTotDeb := 0
			nTotCrd := 0
			nQuebra := 1
		Endif

		IF dData != DATAX
			SubTot510(dData,nTotTit,nTotDeb,nTotCrd,aColu)
			nGerTit += nTotTit
			nGerDeb += nTotDeb
			nGerCrd += nTotCrd
			nQuebra := 0
			li ++; li ++
			Loop
		Endif
		nTamNro:= TamSx3("E1_NUM")[1]
		IncRegua()
		If _lSaldo .And. _lVez

			//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
			//³ BUSCA SALDO ANTERIOR CONTÁBIL			  				     ³
			//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
			/*
			A função SaldoCT7Fil retorna um array contendo os valores de saldos para uma determinada conta contábil em uma data informada.

			Sintaxe da Função:
			SaldoCT7Fil(cConta,dData,cMoeda,cTpSald,cRotina,lImpAntLP,dDataLP,aSelFil)

			Parametros:
			cConta 		= Conta Contabil (Caracter)
			dData 		= Data do Saldo Contabil (Data)
			cTpSald 	= Tipo de Saldo Contabil (1-Real) (Caracter)
			cRotina 	= Rotina que chama a função (Caracter)
			lImpAntLP 	= Indica se considera saldo antes da Apuração de Resultado (Logico .T. ou .F.)
			dDataLP 	= Data de Apuracao de Resultado (Data)
			aSelFil 	= Array com as Filiais consideradas para saldo (Array) - Este parametro somente deve ser passado quando necessário somar 
			saldo de 2 ou mais filiais, por padrão, considera a filial posicionada

			Retorno:
			[1] Saldo Atual (com sinal) 
			[2] Debito na Data
			[3] Credito na Data
			[4] Saldo Atual Devedor
			[5] Saldo Atual Credor
			[6] Saldo Anterior (com sinal)
			[7] Saldo Anterior Devedor
			[8] Saldo Anterior Cred
			*/

			_cConta  := mv_par20
			_cMoeda  := "01"
			_cTpSald := "1"
			_dData 	 := mv_par01

			_xSALDOANT := SaldoCT7Fil(_cConta,_dData,_cMoeda,_cTpSald,"ML_510")[6]

			nC := aColu[6]
			@li, nC-35 PSAY "Saldo Anterior Contabil"
			@li, nC    PSAY _xSALDOANT      Picture tm(VALOR,14,nDecs)

			DbSelectArea("TRB")
			li+= 2
			_lVez := .F.
		Endif
		@li,  0 PSAY DATAX
		@li, 11 PSAY Substr(NUMERO,1,3)+"-"+Substr(NUMERO,4,nTamNro)
		@li, 28 PSAY Substr(NUMERO,nTamNro+4,1)
		@li, 30 PSAY CODIGO

		IF mv_par03 == 1
			dbSelectArea("SA1")
		Else
			dbSelectArea("SA2")
		Endif
		dbSeek(xFilial()+TRB->CODIGO+TRB->LOJA)
		@li,aColu[1] PSAY IIF(mv_par03==1,Substr(SA1->A1_NOME,1,21),Substr(SA2->A2_NOME,1,21))
		DbSelectArea("TRB")
		@li,aColu[2] PSAY EMISSAO
		@li,aColu[3] PSAY VENCREA
		@li,aColu[4] PSAY SubStr(HISTOR, 1, 22)
		nC := IIF( DC = "D",aColu[5],aColu[6])
		@li, nC PSAY VALOR 	Picture tm(VALOR,14,nDecs)
		If Len(AllTrim(HISTOR)) > 22
			li++
			@li,aColu[4] PSAY SubStr(HISTOR,23,17)
		Endif
		nTotTit ++
		IF DC == "D"
			nTotDeb    += VALOR
			If mv_par03 == 2
				_xSALDOANT -= VALOR
			Else
				_xSALDOANT -= VALOR
			Endif
		Else
			nTotCrd    += VALOR
			If mv_par03 == 2
				_xSALDOANT += VALOR
			Else
				_xSALDOANT += VALOR
			Endif
		Endif
		li ++
		dbSkip()
	Enddo

	IF li != 80
		IF li > 55
			cabec(titulo,cabec1,cabec2,nomeprog,tamanho,IIF(nCompress==1,15,18))
		Endif
		SubTot510(dData,nTotTit,nTotDeb,nTotCrd,aColu)
		nGerTit += nTotTit
		nGerDeb += nTotDeb
		nGerCrd += nTotCrd
		li += 2
		@li,000 PSAY OemToAnsi(STR0018)  //"T O T A L  G E R A L ->"
		@li,030 PSAY nGerTit 		Picture "9999"
		@li,035 PSAY OemToAnsi(STR0019)  //"Movimentacoes"
		@li,aColu[5] PSAY nGerDeb 	Picture tm(nGerDeb,14,nDecs)
		@li,aColu[6] PSAY nGerCrd 	Picture tm(nGerCrd,14,nDecs)
		li += 2
		@li, nC-35 PSAY "Saldo Atual"
		@li, nC    PSAY _xSALDOANT      Picture tm(VALOR,14,nDecs)
		li += 2

		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³ BUSCA SALDO FINAL CONTÁBIL				  				     ³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		/*
		A função SaldoCT7Fil retorna um array contendo os valores de saldos para uma determinada conta contábil em uma data informada.

		Sintaxe da Função:
		SaldoCT7Fil(cConta,dData,cMoeda,cTpSald,cRotina,lImpAntLP,dDataLP,aSelFil)

		Parametros:
		cConta 		= Conta Contabil (Caracter)
		dData 		= Data do Saldo Contabil (Data)
		cTpSald 	= Tipo de Saldo Contabil (1-Real) (Caracter)
		cRotina 	= Rotina que chama a função (Caracter)
		lImpAntLP 	= Indica se considera saldo antes da Apuração de Resultado (Logico .T. ou .F.)
		dDataLP 	= Data de Apuracao de Resultado (Data)
		aSelFil 	= Array com as Filiais consideradas para saldo (Array) - Este parametro somente deve ser passado quando necessário somar 
		saldo de 2 ou mais filiais, por padrão, considera a filial posicionada

		Retorno:
		[1] Saldo Atual (com sinal) 
		[2] Debito na Data
		[3] Credito na Data
		[4] Saldo Atual Devedor
		[5] Saldo Atual Credor
		[6] Saldo Anterior (com sinal)
		[7] Saldo Anterior Devedor
		[8] Saldo Anterior Cred
		*/

		_cConta  := mv_par21
		_cMoeda  := "01"
		_cTpSald := "1"
		_dData 	 := mv_par02

		_xSALDOFIM := SaldoCT7Fil(_cConta,_dData,_cMoeda,_cTpSald,"ML_510")[1]

		@li, nC-35 PSAY "Saldo Final Contabil"
		@li, nC    PSAY _xSALDOFIM                 Picture tm(VALOR,14,nDecs)
		li += 2
		@li, nC-35 PSAY "Diferenca Contabil - Financeiro"
		@li, nC    PSAY _xSALDOFIM-_xSALDOANT      Picture tm(VALOR,14,nDecs)

		roda(cbcont,cbtxt,Tamanho)
	Endif

	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³Apaga arquivo e indice temporario ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	//dbSelectArea("TRB")
	TRB->(dbCloseArea())
	//Ferase(cNomeArq+GetDBExtension())
	//Ferase(cNomeArq+OrdBagExt())
	Set Device To Screen

	#IFDEF TOP
	If TcSrvType() != "AS/400"
		dbSelectArea("SE1")
		dbCloseArea()
		ChKFile("SE1")
		dbSelectArea("SE1")
		dbSetOrder(1)

		dbSelectArea("SE2")
		dbCloseArea()
		ChKFile("SE2")
		dbSelectArea("SE2")
		dbSetOrder(1)

		dbSelectArea("SE5")
		dbSetOrder(1)
	Else
		dbSelectArea("SE1")
		RetIndex("SE1")
		dbSetOrder(1)
		Set Filter To

		dbSelectArea("SE2")
		RetIndex("SE2")
		dbSetOrder(1)
		Set Filter To

		dbSelectArea("SE5")
		RetIndex("SE5")
		dbSetOrder(1)
		Set Filter To
	Endif
	#ENDIF

	For nI:=1 to Len(aInd)
		If File(aInd[nI]+OrdBagExt())
			Ferase(aInd[nI]+OrdBagExt())
		Endif
	Next

	If aReturn[5] = 1
		Set Printer TO
		dbCommitall()
		ourspool(wnrel)
	End
	MS_FLUSH()

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o	 ³ SubTot510³ Autor ³ Wagner Xavier 		  ³ Data ³ 25.11.92 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³Imprime subtotal do Relatorio - Diario Auxiliar				  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe e ³ SubTot510() 															  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³ Data,Total de Titulos,Total Debito,Total Credito			  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso		 ³ FINR510																	  ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
STATIC Function SubTot510(dData,nTotTit,nTotDeb,nTotCrd,aColu)

	li++
	@li,	0 PSAY OemToAnsi(STR0027)+Dtoc(dData)  //"TOTAL DO DIA "
	@li,aColu[5] PSAY nTotDeb 	Picture tm(nTotDeb,14,nDecs)
	@li,aColu[6] PSAY nTotCrd 	Picture tm(nTotCrd,14,nDecs)
Return (.t.)

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o	 ³ GravaTrab³ Autor ³ Wagner Xavier 		  ³ Data ³ 25.11.92 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³ Grava registro de trabalho.										  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe e ³ GravaTrab() 															  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso		 ³ Generico 																  ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Static Function GravaTrab( cTipo,dEmissao,dVencto,nValor,aDados,cAliasTmp,dDataConv)
	LOCAL cDCR,cDCP,cAlias:=Alias()
	Local nMoedaBco	:=	1

	//Controla o Pis Cofins e Csll na RA (1 = Controla retenção de impostos no RA; ou 2 = Não controla retenção de impostos no RA(default))
	Local lRaRtImp  := FRaRtImp()

	If cPaisLoc	# "BRA"
		If !Empty((cAliasTmp)->E5_BANCO+(cAliasTmp)->E5_AGENCIA+(cAliasTmp)->E5_CONTA)
			SA6->(DbSetOrder(1))
			SA6->(DbSeek(xFilial()+(cAliasTmp)->E5_BANCO+(cAliasTmp)->E5_AGENCIA+(cAliasTmp)->E5_CONTA))
			nMoedaBco	:=	Max(SA6->A6_MOEDA,1)
		EnDif
		nValor	:=	Iif( nValor=Nil,Round(xMoeda((cAliasTmp)->E5_VALOR,nMoedaBco,1,dDataConv,nDecs+1),nDecs),nValor )
	Else
		nValor	:= Iif( nValor=Nil,(cAliasTmp)->E5_VALOR,nValor )
	Endif
	Do Case
		Case cTipo == "B"
		cDCR="C"
		cDCP="D"
		CASE cTipo == "D"
		cDCR="C"
		cDCP="D"
		Case cTipo == "M"
		cDCR="D"
		cDCP="C"
		OtherWise
		cDCR="D"
		cDCP="C"
	EndCase

	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Grava registro no arquivo de trabalho 							  ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	Reclock("TRB",.t.)
	Replace CODIGO  With aDados[1]	// SE5->E5_CLIFOR
	Replace LOJA	 With aDados[2]	// SE5->E5_LOJA
	Replace DATAX	 With aDados[3]	// SE5->E5_DTDIGIT
	Replace NUMERO  With aDados[4]	// SE5->E5_PREFIXO+SE5->E5_NUMERO+SE5->E5_PARCELA
	Replace VALOR	 With nValor
	Replace EMISSAO With aDados[5]	//	SE5->E5_DATA
	Replace HISTOR  With Iif(Empty(aDados[6]) .Or.;
	Upper(aDados[6]) = Upper(OemToAnsi(STR0033)),;  // "Valor recebido s/ Titulo"
	OemtoAnsi(STR0034), aDados[6]) // "Baixa de Titulo"
	Replace VENCREA With dVencto

	IF aDados[7] = "R" 					//SE5->E5_RECPAG
		Replace DC With Iif( ! ( aDados[8] $MVRECANT+"/"+MV_CRNEG) .or. ;  //SE5->E5_TIPO
		aDados[9]=="ES",cDCR,cDCP) 						 //SE5->E5_TIPODOC
	Else
		Replace DC With Iif( ! ( aDados[8] $MVPAGANT+"/"+MV_CPNEG) .or. ;  //SE5->E5_TIPO
		aDados[9]=="ES",cDCP,cDCR)						 //SE5->E5_TIPODOC
	Endif
	MsUnlock()
	dbSelectArea(cAlias)
Return Nil

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o	 ³ Inside 	³ Autor ³                       ³ Data ³          ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³                                                            ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe	 ³         																	  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso		 ³ Generico 																  ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Static Function InSide(cTp)
	IF mv_par15 != 1 .And. Empty(cTipos)
		Return .t.
	Else
		Return (cTp$cTipos)
	Endif

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o	 ³ AndaTRB	³ Autor ³ Emerson / Sandro      ³ Data ³ 20.09.99 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³ Movimenta area temporaria e reposiciona SE1 ou SE2 ou SE5  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe	 ³         																	  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso		 ³ Generico 																  ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Static Function AndaTRB()
	#IFDEF TOP
	If TcSrvType() != "AS/400"
		TRB510->(dbSkip())
		dbGoTo(TRB510->Recno)
	Else
		dbSkip()
	Endif
	#ELSE
	dbSkip()
	#ENDIF

Return

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o	 ³ TrabDados³ Autor ³ Mauricio Pequim Jr    ³ Data ³ 22.03.00 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³ Monta array com dados do titulo para grava‡Æo do TRB  	  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe e ³ TrabDados() 															  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso		 ³ Generico 																  ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Static Function TrabDados(cAliasTmp)
	LOCAL aDados := Array(9)
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Grava registro no array de trabalho 							  ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	aDados[1] := E5_CLIFOR
	aDados[2] := E5_LOJA
	aDados[3] := E5_DTDIGIT
	aDados[4] := E5_PREFIXO+(cAliasTmp)->E5_NUMERO+(cAliasTmp)->E5_PARCELA
	aDados[5] := E5_DATA
	aDados[6] := E5_HISTOR
	aDados[7] := E5_RECPAG
	aDados[8] := E5_TIPO
	aDados[9] := E5_TIPODOC

	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³  necess rio for‡ar o historico quando for TOP, nÆo AS/400, e NÆo  ³
	//³imprimir valores financeiros (mv_par10 = 2) pois os dados guardados ³
	//³no array, caso o titulo sofreu desconto (por ex.), ‚ o do registro  ³
	//³do desconto no SE5, o que causaria informa‡Æo de hist¢rico errado   ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	#IFDEF TOP
	If TcSrvType() != "AS/400" .and. mv_par10 == 2 .and. ;
	(Empty(aDados[6]) .or. !(adados[9] $ "VL/BA/CP/PA/RA/ES"))
		aDados[6] := OemToAnsi(STR0034)  // "Baixa de Titulo"
	Endif
	#ENDIF

Return aDados
