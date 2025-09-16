#INCLUDE "rwmake.ch"
//#INCLUDE "GPEM410.CH"
/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o    ³ GPEM410  ³ Autor ³ R.H. - Mauro          ³ Data ³ 10.04.96 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³ Geracao de Liquidos em disquete                            ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³                                                            ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ Generico                                                   ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³         ATUALIZACOES SOFRIDAS DESDE A CONSTRU€AO INICIAL.             ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Programador ³ Data   ³ BOPS ³  Motivo da Alteracao                     ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Priscila    ³06/05/02³------³Inclusao da variavel cCPF, que armazena o ³±±
±±³            ³        ³------³Nr. do CPF do Funcionario e Beneficiario. ³±±
±±³Priscila    ³27/08/02³------³Exclusao da variavel TARSEM, pois a mesma ³±±
±±³            ³        ³------³nao esta sendo utilizada na Rotina.       ³±±
±±³Priscila    ³27/08/02³------³Carregada as variaveis mv_par21 e mv_par27³±±
±±³            ³        ³------³para as variaveis do sistema.             ³±±
±±³Emerson     ³12/09/02³------³Passar a executar TcSetField() na query.  ³±±
±±³Emerson     ³08/11/02³------³Alterar pergunta "Data Ini.Ferias De/Ate" ³±±
±±³            ³--------³------³para "Data de Pagamento De/Ate".		  ³±±
±±³Emerson     ³31/03/03³------³Passar a nao filtrar Bco/Age pelo SRA para³±±
±±³            ³--------³------³nao perder a impressao dos beneficiarios. ³±±
±±³Emerson     ³09/06/03³------³Passar aValBenfef de Local para Private.  ³±±
±±³Mauro       ³10/09/03³Melhor³Criado parametro data referencia e passa  ³±±
±±³            ³        ³------³a gerar sobre meses anteriores.           ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/
User Function GPEM410()
	Local nOpca

	Local aSays			:={ }, aButtons:= { } //<== arrays locais de preferencia
	Local aRegs         := {}
	Private cCadastro 	:= OemToAnsi("Gera liquido em disquete") //"Gera‡„o de liquido em disquete"
	Private nSavRec  	:= RECNO()
	nOpca := 0
	cPerg := "GPM410"

	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Verifica as perguntas selecionadas                           ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	pergunte(cPerg,.F.)

	AADD(aSays,OemToAnsi(" Este programa tem o objetivo de gerar o arquivo de liquido em disco.") )  //" Este programa tem o objetivo de gerar o arquivo de liquido em disco."
	AADD(aSays,OemToAnsi(" Antes de rodar este programa  ‚  necess rio cadastrar o lay-out do  ") )  //" Antes de rodar este programa  ‚  necess rio cadastrar o lay-out do  "
	AADD(aSays,OemToAnsi(" arquivo. Modulo SIGACFG op‡„o CNAB a Receber. ") )  //" arquivo. Modulo SIGACFG op‡„o CNAB a Receber. "

	AADD(aButtons, { 5,.T.,{|| Pergunte(cPerg,.T. ) } } )
	AADD(aButtons, { 1,.T.,{|o| nOpca := 1,IF(gpconfOK(),FechaBatch(),nOpca:=0) }} )
	AADD(aButtons, { 2,.T.,{|o| FechaBatch() }} )

	FormBatch( cCadastro, aSays, aButtons )

	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Variaveis utilizadas para parametros                         ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	If nOpca == 1
		Processa({|lEnd| GPM410Processa(),"Gera liquido em disquete"})  //"Gera‡„o de liquido em disquete"
	Endif

	Return

	*-------------------------------*
Static Function Gpm410processa()
	*-------------------------------*
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Define Variaveis Locais (Programa)                           ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	Local nExtra
	Local aCodFol:={}
	Local lHeader:=.F.,lFirst:=.F.,lGrava:=.F.
	Local aBenefCop := {}
	Local nCntP
	Local aStruSRA
	Local cAliasSRA := "SRA" 	//Alias da Query

	//--Arquivo meses Anteriores
	Local cMesArqRef 	:= ""
	Local cAliasMov	 	:= ""
	Local cArqMov	 	:= ""
	Local aOrdBag	 	:= {}
	Local cCompetencia 	:= SuperGetMv( "MV_FOLMES",,Space(06) )
	Local nS
	#IFDEF TOP
	Local nX
	#ENDIF

	Private cNome,cBanco,cConta,cCPF
	Private aValBenef := {}

	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Variaveis de Acesso do Usuario                               ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	Private cAcessaSR1	:= &( " { || " + ChkRH( "GPER280" , "SR1" , "2" ) + " } " )
	Private cAcessaSRA	:= &( " { || " + ChkRH( "GPER280" , "SRA" , "2" ) + " } " )
	Private cAcessaSRC	:= &( " { || " + ChkRH( "GPER280" , "SRC" , "2" ) + " } " )
	Private cAcessaSRG	:= &( " { || " + ChkRH( "GPER280" , "SRG" , "2" ) + " } " )
	Private cAcessaSRH	:= &( " { || " + ChkRH( "GPER280" , "SRH" , "2" ) + " } " )
	Private cAcessaSRI	:= &( " { || " + ChkRH( "GPER280" , "SRI" , "2" ) + " } " )
	Private cAcessaSRR	:= &( " { || " + ChkRH( "GPER280" , "SRR" , "2" ) + " } " )

	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Define Variaveis PRIVADAS BASICAS                            ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	Private aABD := { "Drive A","Drive B","Abandona" } //"Drive A"###"Drive B"###"Abandona"
	Private aTA  := { "Tente novamente!","Abandona" } //"Tenta Novamente"###"Abandona"

	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Define Variaveis PRIVADAS DO PROGRAMA                        ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	Private nEspaco := nDisco := nGravados := 0
	Private cDrive := " "
	Private nArq, cTipInsc

	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Variaveis Usadas no Arquivo de Cadastramento                 ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	Private nSeq      := 0
	Private nValor    := 0
	Private nTotal    := 0
	Private nTotFunc  := 0

	Private nHdlBco :=0,nHdlSaida:=0
	Private xConteudo

	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Variaveis utilizadas para parametros                         ³
	//³ mv_par01        //  Adiantamento                             ³
	//³ mv_par02        //  Folha                                    ³
	//³ mv_par03        //  1¦Parc. 13§ Sal rio                      ³
	//³ mv_par04        //  2¦Parc. 13§ Sal rio                      ³
	//³ mv_par05        //  F‚rias                                   ³
	//³ mv_par06        //  Extras                                   ³
	//³ mv_par07        //  Numero da Semana                         ³
	//³ mv_par08        //  Filial  De                               ³
	//³ mv_par09        //  Filial  Ate                              ³
	//³ mv_par10        //  Centro de Custo De                       ³
	//³ mv_par11        //  Centro de Custo Ate                      ³
	//³ mv_par12        //  Banco /Agencia De                        ³
	//³ mv_par13        //  Banco /Agencia Ate                       ³
	//³ mv_par14        //  Matricula De                             ³
	//³ mv_par15        //  Matricula Ate                            ³
	//³ mv_par16        //  Nome De                                  ³
	//³ mv_par17        //  Nome Ate                                 ³
	//³ mv_par18        //  Conta Corrente De                        ³
	//³ mv_par19        //  Conta Corrente Ate                       ³
	//³ mv_par20        //  Situacao                                 ³
	//³ mv_par21        //  Arquivo de configuracao                  ³
	//³ mv_par22        //  nome do arquivo de saida                 ³
	//³ mv_par23        //  data de credito                          ³
	//³ mv_par24        //  Data de Pagamento De                     ³
	//³ mv_par25        //  Data de Pagamento Ate                    ³
	//³ mv_par26        //  Categorias                               ³
	//³ mv_par27        //  Configura‡Æo CNAB                        ³
	//³ mv_par28        //  Rescisao			                     ³
	//³ mv_par29        //  Imprimir			                     ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ

	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Carregando variaveis mv_par?? para Variaveis do Sistema.     ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	lAdianta  := If(mv_par01 == 1,.T.,.F.)
	lFolha    := If(mv_par02 == 1,.T.,.F.)
	lPrimeira := If(mv_par03 == 1,.T.,.F.)
	lSegunda  := If(mv_par04 == 1,.T.,.F.)
	lFerias   := If(mv_par05 == 1,.T.,.F.)
	lExtras   := If(mv_par06 == 1,.T.,.F.)
	Semana    := mv_par07
	cFilDe    := mv_par08
	cFilAte   := mv_par09
	cCcDe     := mv_par10
	cCcate    := mv_par11
	cBcoDe    := mv_par12
	cBcoAte   := mv_par13
	cMatDe    := mv_par14
	cMatAte   := mv_par15
	cNomDe    := mv_par16
	cNomAte   := mv_par17
	cCtaDe    := mv_par18
	cCtaAte   := mv_par19
	cSituacao := mv_par20
	cArqent   := mv_par21
	cArqSaida := mv_par22
	dDataPgto := mv_par23
	dDataDe   := mv_par24
	dDataAte  := mv_par25
	cCategoria:= mv_par26
	nModelo	  := mv_par27
	lRescisao := If(mv_par28 == 1,.T.,.F.)
	nFunBenAmb:= mv_par29  // 1-Funcionarios  2-Beneficiarias  3-Ambos
	dDataRef  := If (Empty(mv_par30), dDataBase,mv_par30) 



	//Abertura de Arquivo de outros meses

	If !Empty( cCompetencia )
		If !Empty( cCompetencia ) .And. MesAno( dDataRef ) > cCompetencia
			Aviso( "Atencao", "Nao existe arquivo de fechamento referente a data base solicitada" + ": "+Subs(MesAno(dDataRef),5,2)+"/"+Subs(MesAno(ddataref),1,4), { "Ok" } ) //##"Atencao"##"Nao existe arquivo de fechamento referente a data base solicitada"##"Ok"
			Return .F.
		Endif	
	Endif
	cMesArqRef := StrZero(Month(dDataRef),2) + StrZero(Year(dDataRef),4)
	If !OpenSrc( cMesArqRef, @cAliasMov, @aOrdBag, @cArqMov, dDataRef , , ,.T.)
		Return .f.
	Endif

	//-- Modifica variaveis para a Query
	cSitQuery := ""
	For nS:=1 to Len(cSituacao)
		cSitQuery += "'"+Subs(cSituacao,nS,1)+"'"
		If ( nS+1) <= Len(cSituacao)
			cSitQuery += "," 
		Endif
	Next nS
	cCatQuery := ""
	For nS:=1 to Len(cCategoria)
		cCatQuery += "'"+Subs(cCategoria,nS,1)+"'"
		If ( nS+1) <= Len(cCategoria)
			cCatQuery += "," 
		Endif
	Next nS

	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Define se devera ser impresso Funcionarios ou Beneficiarios  ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	dbSelectArea( "SRQ" )
	lImprFunci  := ( nFunBenAmb # 2 )
	lImprBenef  := ( nFunBenAmb # 1 .And. FieldPos( "RQ_BCDEPBE" ) # 0 .And. FieldPos( "RQ_CTDEPBE" ) # 0 )

	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Informa a nao existencia dos campos de bco/age/conta corrente³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	If nFunBenAmb # 1 .And. !lImprBenef
		fAvisoBC()
		Return .F.
	Endif

	If !AbrePar()    //Abertura Arquivo ASC II
		Return
	Endif

	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Desenha cursor para movimentacao                          ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	ProcRegua(SRA->(RecCount()))

	FilAnt := "!!"
	BcoAnt := Space(08)
	CcAnt  := Space(09)
	CtaAnt := Space(12)
	NomAnt := Space(30)

	//--Posiciona no Primeiro Selecionado no De/Ate
	dbSelectArea( "SRA" )

	#IFDEF TOP
	If TcSrvType() != "AS/400"
		cQuery := "SELECT COUNT(*) TOTAL "
		cQuery += "  FROM "+	RetSqlName("SRA")
		cQuery += " WHERE RA_FILIAL  between '" + cFilDe + "' AND '" + cFilAte + "'"
		cQuery += "   AND RA_MAT     between '" + cMatDe + "' AND '" + cMatAte + "'"
		cQuery += "   AND RA_NOME    between '" + cNomDe + "' AND '" + cNomAte + "'"
		cQuery += "   AND RA_CC      between '" + cCcDe  + "' AND '" + cCcate  + "'"
		cQuery += " AND RA_CATFUNC IN (" + Upper(cCatQuery) + ")" 
		cQuery += " AND RA_SITFOLH IN (" + Upper(cSitQuery) + ")" 
		cQuery += "   AND D_E_L_E_T_ <> '*' "		
	Else
		cQuery := "SELECT COUNT(*) TOTAL "
		cQuery += "  FROM "+	RetSqlName("SRA")
		cQuery += " WHERE RA_FILIAL  >= '" + cFilDe + "' AND RA_FILIAL  <= '" + cFilAte + "'"
		cQuery += "   AND RA_MAT     >= '" + cMatDe + "' AND RA_MAT     <= '" + cMatAte + "'"
		cQuery += "   AND RA_NOME    >= '" + cNomDe + "' AND RA_NOME    <= '" + cNomAte + "'"
		cQuery += "   AND RA_CC      >= '" + cCcDe  + "' AND RA_CC      <= '" + cCcate  + "'"
		cQuery += "   AND @DELETED@ <> '*' "		
	Endif		

	dbUseArea(.T., "TOPCONN", TCGenQry(,,cQuery), 'QUERY', .F., .T.)
	dbSelectArea("QUERY")
	nTotalQ := QUERY->TOTAL
	ProcRegua(nTotalQ)		// Total de Elementos da regua	
	Query->( dbCloseArea() )
	dbSelectArea("SRA")		

	If TcSrvType() != "AS/400"
		cQuery := "SELECT * "		
		cQuery += "  FROM "+	RetSqlName("SRA")
		cQuery += " WHERE RA_FILIAL  between '" + cFilDe + "' AND '" + cFilAte + "'"
		cQuery += "   AND RA_MAT     between '" + cMatDe + "' AND '" + cMatAte + "'"
		cQuery += "   AND RA_NOME    between '" + cNomDe + "' AND '" + cNomAte + "'"
		cQuery += "   AND RA_CC      between '" + cCcDe  + "' AND '" + cCcate  + "'"
		cQuery += " AND RA_CATFUNC IN (" + Upper(cCatQuery) + ")" 
		cQuery += " AND RA_SITFOLH IN (" + Upper(cSitQuery) + ")" 
		cQuery += "   AND D_E_L_E_T_ <> '*' "		
	Else
		cQuery := "SELECT * "
		cQuery += "  FROM "+	RetSqlName("SRA")
		cQuery += " WHERE RA_FILIAL  >= '" + cFilDe + "' AND RA_FILIAL  <= '" + cFilAte + "'"
		cQuery += "   AND RA_MAT     >= '" + cMatDe + "' AND RA_MAT     <= '" + cMatAte + "'"
		cQuery += "   AND RA_NOME    >= '" + cNomDe + "' AND RA_NOME    <= '" + cNomAte + "'"
		cQuery += "   AND RA_CC      >= '" + cCcDe  + "' AND RA_CC      <= '" + cCcate  + "'"
		cQuery += "   AND @DELETED@ <> '*' "		
	Endif		
	cQuery   += " ORDER BY RA_FILIAL, RA_MAT"
	aStruSRA := SRA->(dbStruct())
	SRA->( dbCloseArea() )
	dbSelectArea("SRC")
	dbUseArea(.T., "TOPCONN", TCGenQry(,,cQuery), 'SRA', .F., .T.)
	For nX := 1 To Len(aStruSRA)
		If ( aStruSRA[nX][2] <> "C" )
			TcSetField(cAliasSRA,aStruSRA[nX][1],aStruSRA[nX][2],aStruSRA[nX][3],aStruSRA[nX][4])
		EndIf
	Next nX
	#ELSE
	dbSetOrder(1)
	dbSeek( cFilDe + cMatDe , .T. )
	#ENDIF

	WHILE ! Eof() .And. SRA->RA_FILIAL + SRA->RA_MAT <= cFilAte + cMatAte

		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³ Movimenta Cursor                                          ³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		IncProc("Liquido em Disquete") //"Liquido em Disquete"

		nValor     := 0
		aValBenef := {}

		If SRA->RA_FILIAL # FilAnt
			If !Fp_CodFol(@aCodFol,SRA->RA_FILIAL)
				Exit
			Endif                 
			FilAnt := SRA->RA_FILIAL
		Endif

		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³ Consiste Parametrizacao do Intervalo de Impressao            ³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		If  (SRA->RA_NOME    < cNomDe) .Or. (SRA->RA_NOME    > cNomAte) .Or. ;
		(SRA->RA_MAT     < cMatDe) .Or. (SRA->RA_MAT     > cMatAte) .Or. ;
		(SRA->RA_CC      < cCcDe)  .Or. (SRA->RA_CC      > cCcate)
			SRA->(dbSkip(1))
			Loop
		EndIf

		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³ Ponto de Entrada para despresar funcionario caso retorne .F. ³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		//If ExistBlock("GP410DES")
		//	If !(ExecBlock("GP410DES",.F.,.F.))
		//		SRA->(dbSkip(1))
		//		Loop
		//	EndIf
		//EndIf

		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³ Busca os valores de Liquido e Beneficios                     ³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		fBuscaLiq(@nValor,@aValBenef,aCodFol)

		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³ Consiste parametros de banco e conta do funcionario			 ³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		If (SRA->RA_BCDEPSA < cBcoDe) .Or. (SRA->RA_BCDEPSA > cBcoAte) .Or.;
		(SRA->RA_CTDEPSA < cCtaDe) .Or. (SRA->RA_CTDEPSA > cCtaAte)
			nValor := 0
		EndIf

		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³ Consiste parametros de banco e conta do beneficiario 		 ³
		//³ aValBenef: 1-Nome  2-Banco  3-Conta  4-Verba  5-Valor  6-CPF ³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		If Len(aValBenef) > 0
			aBenefCop  := ACLONE(aValBenef)
			aValBenef  := {}
			Aeval(aBenefCop, { |X| If( ( X[2] >= cBcoDe .And. X[2] <= cBcoAte) .And.;
			( X[3] >= cCtaDe .And. X[3] <= cCtaAte),;
			AADD(aValBenef, X), "" ) })
		EndIf

		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³ Testa Situacao do Funcionario na Folha                       ³
		//³ Testa Categoria do Funcionario na Folha                      ³
		//³ Testa se Valor == 0                                          ³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		If !( SRA->RA_SITFOLH $ cSituacao ) .Or. !(SRA->RA_CATFUNC $ cCategoria) .Or.;
		( nValor == 0 .And. Len(aValBenef) == 0 )
			dbSelectArea( "SRA" )
			dbSkip()
			Loop
		Endif

		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³ Adiciona o funcionario no array para inclusao no arquivo	 ³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		If lImprFunci
			Aadd(aValBenef, {  SRA->RA_NOME, SRA->RA_BCDEPSA, SRA->RA_CTDEPSA, "", nValor,SRA->RA_CIC } )
		EndIf

		For nCntP := 1 To Len(aValBenef)

			cNome   := aValBenef[nCntP,1]
			cBanco  := aValBenef[nCntP,2]
			cConta  := aValBenef[nCntP,3]
			cCPF	:= aValBenef[nCntP,6] 	
			//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
			//³ Verifica valor e banco/agencia dos beneficiarios			 ³
			//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
			If aValBenef[nCntP,5] == 0 .Or. Empty(cBanco) .Or. cBanco < cBcoDe .Or. cBanco > cBcoAte
				Loop
			EndIf

			//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
			//³ Iguala nas Variaveis Usadas do arquivo de cadastramento      ³
			//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
			nValor := NoRound(aValBenef[nCntP,5] * 100,0)
			nTotal += nValor
			nTotFunc ++
			nSeq++
			If ( nModelo == 1 )
				//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
				//³ Le Arquivo de Parametrizacao                                 ³
				//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
				nLidos:=0
				fSeek(nHdlBco,0,0)
				nTamArq:=FSEEK(nHdlBco,0,2)
				fSeek(nHdlBco,0,0)

				While nLidos <= nTamArq
					//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
					//³ Verifica o tipo qual registro foi lido                       ³
					//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
					xBuffer:=Space(85)
					FREAD(nHdlBco,@xBuffer,85)

					Do case
						Case SubStr(xBuffer,1,1) == CHR(1)
						IF lHeader
							nLidos+=85
							Loop
						EndIF
						Case SubStr(xBuffer,1,1) == CHR(2)
						IF !lFirst
							lFirst := .T.
							FWRITE(nHdlSaida,CHR(13)+CHR(10))
						EndIF
						Case SubStr(xBuffer,1,1) == CHR(3)
						nLidos+=85
						Loop
						Otherwise
						nLidos+=85
						Loop
					EndCase

					nTam := 1+(Val(SubStr(xBuffer,20,3))-Val(SubStr(xBuffer,17,3)))
					nDec := Val(SubStr(xBuffer,23,1))
					cConteudo:= SubStr(xBuffer,24,60)
					lGrava := fM410Grava(nTam,nDec,cConteudo)
					IF !lGrava
						Exit
					End
					nLidos+=85
				EndDO
				IF !lGrava
					Exit
				End
			Else
				lGrava := fM410Grava(,,,)
			EndIf
			If lGrava
				If ( nModelo == 1 )
					fWrite(nHdlSaida,CHR(13)+CHR(10))
					IF !lHeader
						lHeader := .T.
					EndIF
				EndIf
			EndIf
		Next nCntP
		dbSelectArea( "SRA" )
		SRA->( dbSkip( ) )
	Enddo

	If ( nModelo == 1 )
		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³ Monta Registro Trailler                                      ³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		nSeq++
		nLidos:=0
		FSEEK(nHdlBco,0,0)
		nTamArq:=FSEEK(nHdlBco,0,2)
		FSEEK(nHdlBco,0,0)

		While nLidos <= nTamArq

			IF !lGrava
				Exit
			End

			//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
			//³ Tipo qual registro foi lido                                  ³
			//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
			xBuffer:=Space(85)
			FREAD(nHdlBco,@xBuffer,85)

			IF SubStr(xBuffer,1,1) == CHR(3)
				nTam := 1+(Val(SubStr(xBuffer,20,3))-Val(SubStr(xBuffer,17,3)))
				nDec := Val(SubStr(xBuffer,23,1))
				cConteudo:= SubStr(xBuffer,24,60)
				lGrava:=fM410Grava( nTam,nDec,cConteudo )
				IF !lGrava
					Exit
				End
			EndIF
			nLidos+=85
		EndDO
	Else
		RodaCnab2(nHdlSaida,cArqent)
	EndIf
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Termino do relatorio                                         ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ

	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Seleciona arq. defaut do Siga caso Imp. Mov. Anteriores      ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	If !Empty( cAliasMov )
		fFimArqMov( cAliasMov , aOrdBag , cArqMov )
	EndIf

	dbSelectArea("SRA")
	dbCloseArea()
	ChkFile("SRA")

	fClose(nHdlSaida)
	dbSelectArea( "SRI" )
	dbSetOrder(1)
	dbSelectArea( "SRA" )
Return

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o    ³AbrePar   ³ Autor ³ Wagner Xavier         ³ Data ³ 26/05/92 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³Abre arquivo de Parametros                                  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³AbrePar()                                                   ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³GPEM410                                                     ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß/*/
Static Function AbrePar()
	Local cArqEnt := cArqent

	IF !FILE(cArqEnt)
		Help(" ",1,"NOARQPAR")
		Return .F.
	Else
		If ( nModelo == 1 )
			nHdlBco:=FOPEN(cArqEnt,0+64)
		EndIf
	EndIF

	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Cria Arquivo Saida                                       ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	If ( nModelo == 1 )
		nHdlSaida:=MSFCREATE(cArqSaida,0)
	Else
		nHdlSaida:=HeadCnab2(cArqSaida,cArqent)
	EndIf
Return .T.

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o    ³fM410Grava³ Autor ³ Wagner Xavier         ³ Data ³ 26/05/92 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³Rotina de Geracao do Arquivo de Remessa de Comunicacao      ³±±
±±³          ³Bancaria                                                    ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³ExpL1:=fM410Grava(ExpN1,ExpN2,ExpC1)                        ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ GPEM410                                                    ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß/*/
STATIC Function fM410Grava( nTam,nDec,cConteudo )
	Local lConteudo := .T.

	While .T.
		If ( nModelo == 1 )
			//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
			//³ Analisa conteudo                                         ³
			//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
			IF Empty(cConteudo)
				cCampo:=Space(nTam)
			Else
				lConteudo := fM410Orig( cConteudo )
				IF !lConteudo
					Exit
				Else
					IF ValType(xConteudo)="D"
						cCampo := GravaData(xConteudo,.F.)
					Elseif ValType(xConteudo)="N"
						cCampo:=Substr(Strzero(xConteudo,nTam,nDec),1,nTam)
					Else
						cCampo:=Substr(xConteudo,1,nTam)
					End
				End
			End
			IF Len(cCampo) < nTam  //Preenche campo a ser gravado, caso menor
				cCampo:=cCampo+Space(nTam-Len(cCampo))
			End
			Fwrite( nHdlSaida,cCampo,nTam )
		Else
			DetCnab2(nHdlSaida,cArqent)
		EndIf
		Exit
	End
Return lConteudo

/*/
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o    ³fM410Orig ³ Autor ³ Wagner Xavier         ³ Data ³ 10/11/92 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³Verifica se expressao e' valida para Remessa CNAB.          ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³GPEM410                                                     ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß/*/
Static Function fM410Orig( cForm )
	Local bBlock:=ErrorBlock(),bErro := ErrorBlock( { |e| ChecErr260(e,cForm) } )
	Private lRet := .T.

	BEGIN SEQUENCE
		xConteudo := &cForm
	END SEQUENCE
	ErrorBlock(bBlock)
Return lRet
