#INCLUDE "rwmake.ch"

User Function ML_906()


	/*/
	ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
	±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
	±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
	±±³Programa  ³ ML_906   ³ Autor ³ Nereu Humberto Jr.    ³ Data ³ 17.06.04 ³±±
	±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
	±±³Descricao ³ Relatorio de PIS e COFINS                                  ³±±
	±±³          ³ Alterado para buscar as aliquotas do PIS/COFINS que estao  ³±±
	±±³          ³ gravadas no SD1 e SD2                                      ³±±
	±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
	±±³Uso       ³ Especifico para Frigorifico Silva                          ³±±
	±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
	±±³Observacao³                                                            ³±±
	±±³          ³                                                            ³±±
	±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
	±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
	ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
	/*/
	Local _aArqTrb   := {} // ProcData 04/2023
	Local   cText1   := "Este programa emite Relatorio das Contribuicoes ao PIS e COFINS"
	Local   cString  := "SD2"
	Local	aOrd	 := {"Cfop","Num. Nf+Serie+Emissao"}
	Private cTitulo  := "Relatorio - (PIS/COFINS)"
	Private cPerg    := "MTR906"
	Private nLastKey := 0
	Private m_pag    := 01
	Private Limite   := 220
	Private cTamanho := "G"
	Private lEnd     := .F.
	Private NomeProg := "ML_906"
	Private aReturn  := { "Zebrado" , 1, "Administracao", 2, 2, 1, "",1 } //"Zebrado" , "Administracao"
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Variaveis utilizadas para parametros                     ³
	//³ mv_par01            // Pis/Cofins/Ambos ?                ³
	//³ mv_par02            // Data Inicial                      ³
	//³ mv_par03            // Data Final                        ³
	//³ mv_par04            // Analitico/Sintetico               ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	Pergunte(cPerg,.F.)

	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Envia controle para a funcao SETPRINT                        ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	wnrel:="ML_906"   // nome default do relatorio em disco
	wnrel:=SetPrint(cString,wnrel,cPerg,cTitulo,cText1,,,.F.,aOrd,,cTamanho,,.F.)
	If nLastKey==27
		dbClearFilter()
		Return
	Endif
	fErase(__RelDir + wnrel + '.##r')
	SetDefault(aReturn,cString)
	If nLastKey==27
		dbClearFilter()
		Return
	Endif

	RptStatus({|lEnd| a906Relat(@lEnd,wnRel,cString,cTamanho)},cTitulo)

	// ProcData 04/2023 - Chamada para fechar arquivo de trabalho
	u_arqtrb ("FechaTodos",,,, @_aArqTrb) 
Return

/*ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o    ³ A906Relat    ³ Autor ³Edstron E. Correia ³ Data ³ 02/07/01 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³ Selecao e Emissao das Contribuicoes ao PIS e COFINS        ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/
Static Function A906Relat(lEnd,WnRel,cString,cTamanho)
	Local _aArqTrb   := {} // ProcData 04/2023
	Local aStruSD1   := {}
	Local aStruSD2   := {}
	Local aStruSB1   := {}
	Local aStruSF2   := {}
	Local aStruSF1   := {}
	Local aStruSF4   := {}
	Local cAliasSD2  := "SD2"
	Local cAliasSD1  := "SD1"
	Local cAliasSB1  := "SB1"
	Local cAliasSF4  := "SF4"
	Local cAliasSF2  := "SF2"
	Local cAliasSF1  := "SF1"
	Local cCpVlPisEn := ""
	Local cCpBsPisEn := ""
	Local cCpVlPisSa := ""
	Local cCpBsPisSa := ""
	Local cCpVlCofEn :=  ""
	Local cCpBsCofEn :=  ""
	Local cCpVlCofSa :=  ""
	Local cCpBsCofSa :=  ""
	Local cLinha     := ""
	Local cArqTemp   := ""
	Local cabec1     := ""
	Local cabec2     := ""
	Local cQuebra    := ""
	Local cTipo      := ""
	Local cContArq   := ""
	Local cLinArq    := ""
	Local cArqCp     := ""
	Local aArqTemp   := {}
	Local aArqIni    := {}
	Local aPIS		  := {}
	Local aCOFINS	  := {}
	Local aRelImp	  := MaFisRelImp("MT100",{ "SD1" })
	Local aRelImp2	  := MaFisRelImp("MT100",{ "SD2" })
	Local aTotaisPIS := Array( 8 )
	Local aTotaisCOF := Array( 8 )
	Local nPos		  := 0
	Local nX		     := 0
	Local nRedPis	  := 1
	Local nRedCOF	  := 1
	Local nValPisPas := 0
	Local nBasPisPas := 0
	Local nPsVlPisEn := 0
	Local nPsBsPisEn := 0
	Local nPsVlPisSa := 0
	Local nPsBsPisSa := 0
	Local nPosCofins := 0
	Local nValCofins := 0
	Local nBasCofins := 0
	Local nPsVlCofEn := 0
	Local nPsBsCofEn := 0
	Local nPsVlCofSa := 0
	Local nPsBsCofSa := 0
	Local nScanPis   := 0
	Local nScanCof   := 0
	Local nTxPis     := 0
	Local nTxCof     := 0
	Local nCredPis   := 0
	Local nCredCof   := 0
	Local nValCont   := 0
	Local nZFranca   := 0
	Local nValDebi   := 0
	Local nValCred   := 0
	Local nBasDebi   := 0
	Local nBasCred   := 0
	Local nGValCont  := 0
	Local nGZFranca  := 0
	Local nGValDebi  := 0
	Local nGValCred  := 0
	Local nGBasDebi  := 0
	Local nGBasCred  := 0
	Local nValContri := 0
	Local nContCp    := 0
	Local lRet       := .F.
	Local lContinua  := .T.
	Local lEntrada   := .F.
	Local lQuebra    := .F.
	Local lFirst     := .F.
	Local lResumo	 := .F.
	Local nValDevVend := 0
	Local nValComp    := 0
	Local nValVend    := 0
	Local nValDevComp := 0
	Local nVendTrib	  := 0
	Local nDevCompT   := 0
	Local nCompTrib   := 0
	Local nDevVendT   := 0
	Local aAliqs 	  := {}
	Local nPosAliq    := 0
	Local aDados      := {}

	cbtxt      := Space(10)
	cbcont     := 00
	li         := 80

	If mv_par04 == 1
		Cabec1 := " Produto          NCM         Valor Contabil            Zona Franca      Aliquota              Valor da Contribuicao                            Base da Contribuicao              Documento   Serie  Emissao                "
	Else
		Cabec1 := " Produto          NCM         Valor Contabil            Zona Franca      Aliquota              Valor da Contribuicao                            Base da Contribuicao"
	Endif

	Cabec2 := "                                                          Desconto                             Debito                 Credito                  Debito                 Credito"

	// " Produto          NCM         Valor Contabil            Zona Franca      Aliquota              Valor da Contribuicao                            Base da Contribuicao              Documento   Serie  Emissao                "
	// "                                                          Desconto                             Debito                 Credito                  Debito                 Credito"
	// "XXXXXXXXXXXXXXX  XXXXXXXXXX  999,999,999,999.99   999,999,999,999.99    99.99%    999,999,999,999.99      999,999,999,999.99      999,999,999,999.99      999,999,999,999.99
	// 0         1         2         3         4         5         6         7         8         9         10        11        12        13        14        15        16        17        18        19        20        21        22
	// 012345678901234567890123456789012345678901234567890123456789012345678901234567890123456789012345678901234567890123456789012345678901234567890123456789012345678901234567890123456789012345678901234567890123456789012345678901

	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Tratamento para os campos do PIS - Entrada                        ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ

	If !Empty( nScanPis := aScan(aRelImp,{|x| x[1]=="SD1" .And. x[3]=="IT_BASEPS2"} ) )
		cCpBsPisEn := aRelImp[nScanPis,2]
		nPsBsPisEn := SD1->(FieldPos(cCpBsPisEn))
	EndIf
	If !Empty( nScanPis := aScan(aRelImp,{|x| x[1]=="SD1" .And. x[3]=="IT_VALPS2"} ) )
		cCpVlPisEn := aRelImp[nScanPis,2]
		nPsVlPisEn := SD1->(FieldPos(cCpVlPisEn))
	EndIf
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Tratamento para os campos do PIS - Saida                          ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	If !Empty( nScanPis := aScan(aRelImp2,{|x| x[1]=="SD2" .And. x[3]=="IT_BASEPS2"} ) )
		cCpBsPisSa := aRelImp2[nScanPis,2]
		nPsBsPisSa := SD2->(FieldPos(cCpBsPisSa))
	EndIf
	If !Empty( nScanPis := aScan(aRelImp2,{|x| x[1]=="SD2" .And. x[3]=="IT_VALPS2"} ) )
		cCpVlPisSa := aRelImp2[nScanPis,2]
		nPsVlPisSa := SD2->(FieldPos(cCpVlPisSa))
	EndIf

	AFill( aTotaisCof, 0 )

	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Tratamento para os campos do COF - Entrada                        ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	If !Empty( nScanCof := aScan(aRelImp,{|x| x[1]=="SD1" .And. x[3]=="IT_BASECF2"} ) )
		cCpBsCofEn := aRelImp[nScanCof,2]
		nPsBsCofEn := SD1->(FieldPos(cCpBsCofEn))
	EndIf

	If !Empty( nScanCof := aScan(aRelImp,{|x| x[1]=="SD1" .And. x[3]=="IT_VALCF2"} ) )
		cCpVlCofEn := aRelImp[nScanCof,2]
		nPsVlCofEn := SD1->(FieldPos(cCpVlCofEn))
	EndIf

	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Tratamento para os campos do COF - Saida                          ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	If !Empty( nScanCof := aScan(aRelImp2,{|x| x[1]=="SD2" .And. x[3]=="IT_BASECF2"} ) )
		cCpBsCofSa := aRelImp2[nScanCof,2]
		nPsBsCofSa := SD2->(FieldPos(cCpBsCofSa))
	EndIf

	If !Empty( nScanCof := aScan(aRelImp2,{|x| x[1]=="SD2" .And. x[3]=="IT_VALCF2"} ) )
		cCpVlCofSa := aRelImp2[nScanCof,2]
		nPsVlCofSa := SD2->(FieldPos(cCpVlCofSa))
	EndIf

	AADD(aArqTemp,{"NUMNF"		,"C",09,0})
	AADD(aArqTemp,{"SERIE"		,"C",03,0})
	AADD(aArqTemp,{"EMISSAO"   ,"D",08,0})
	AADD(aArqTemp,{"TIPO"		,"C",03,0})
	AADD(aArqTemp,{"CFOP"	    ,"C",04,0})
	AADD(aArqTemp,{"PRODUTO"	,"C",15,0})
	AADD(aArqTemp,{"NCM"		,"C",10,0})
	AADD(aArqTemp,{"VALORCONT"	,"N",14,2})
	AADD(aArqTemp,{"ZFRANCA"	,"N",14,2})
	AADD(aArqTemp,{"ALIQ"		,"N",05,2})
	AADD(aArqTemp,{"PISCSAI"	,"N",14,2})
	AADD(aArqTemp,{"PISDSAI"	,"N",14,2})
	AADD(aArqTemp,{"BASPICSAI"	,"N",14,2})
	AADD(aArqTemp,{"BASPIDSAI"	,"N",14,2})
	AADD(aArqTemp,{"PISCENT"	,"N",14,2})
	AADD(aArqTemp,{"PISDENT"	,"N",14,2})
	AADD(aArqTemp,{"BASPICENT"	,"N",14,2})
	AADD(aArqTemp,{"BASPIDENT"	,"N",14,2})
	AADD(aArqTemp,{"COFCSAI"	,"N",14,2})
	AADD(aArqTemp,{"COFDSAI"	,"N",14,2})
	AADD(aArqTemp,{"BASCOCSAI"	,"N",14,2})
	AADD(aArqTemp,{"BASCODSAI"	,"N",14,2})
	AADD(aArqTemp,{"COFCENT"	,"N",14,2})
	AADD(aArqTemp,{"COFDENT"	,"N",14,2})
	AADD(aArqTemp,{"BASCOCENT"	,"N",14,2})
	AADD(aArqTemp,{"BASCODENT"	,"N",14,2})
	AADD(aArqTemp,{"ES"	,		 "C",01,0})

	//cArqTemp := CriaTrab(aArqTemp)

	//dbUseArea(.T.,__LocalDriver,cArqTemp,"TRB")
	//IndRegua("TRB",cArqTemp,"TIPO+CFOP")
	
	// ProcData 04/2023 - Chamada para criação do arquivo de trabalho
	U_ArqTrb("Cria", "TRB", aArqTemp, {"TIPO","CFOP"}, @_aArqTrb)	

	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Processamento das Saidas                                          ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	dbSelectArea("SD2")
	SD2->(dbSetOrder(5))
	#IFDEF TOP
	lQuery := .T.
	cAliasSD2 := "a906AMontSD2"
	cAliasSF2 := "a906AMontSD2"
	cAliasSF4 := "a906AMontSD2"
	cAliasSB1 := "a906AMontSD2"

	aStruSD2  := SD2->(dbStruct())
	aStruSB1  := SB1->(dbStruct())
	aStruSF4  := SF4->(dbStruct())
	aStruSF2  := SF2->(dbStruct())

	cQuery 	:= "SELECT F4_AGREG,F2_SERIE,F2_DOC,F2_SEGURO,F2_FRETE,F2_DESPESA,F2_VALMERC,D2_TOTAL,D2_DOC,D2_SERIE,D2_EMISSAO,D2_CF,D2_COD,D2_DESCZFR,B1_POSIPI,D2_TIPO,"
	cQuery  += "D2_ICMSRET,D2_VALIPI,D2_VALFRE,D2_SEGURO,D2_DESPESA, D2_ALQIMP6, D2_VALIMP6 "
	If !Empty( nPsVlPisSa )
		cQuery += "," + cCpVlPisSa
	EndIf

	If !Empty( nPsBsPisSa )
		cQuery += "," + cCpBsPisSa
	EndIf

	If !Empty( nPsVlCofSa )
		cQuery += "," + cCpVlCOfSa
	EndIf

	If !Empty( nPsBsCofSa )
		cQuery += "," + cCpBsCofSa
	EndIf

	If SB1->(FieldPos("B1_PPIS")) >0
		cQuery += ",B1_PPIS "
	Endif

	If SB1->(FieldPos("B1_REDPIS")) > 0
		cQuery += ",B1_REDPIS "
	Endif

	If SB1->(FieldPos("B1_REDCOF")) > 0
		cQuery += ",B1_REDCOF "
	Endif

	If SB1->(FieldPos("B1_PCOFINS")) > 0
		cQuery += ",B1_PCOFINS "
	Endif

	If SF4->(FieldPos("F4_BASEPIS")) > 0
		cQuery += ",F4_BASEPIS "
	Endif

	If SF4->(FieldPos("F4_BASECOF")) > 0
		cQuery += ",F4_BASECOF "
	Endif

	If SF4->(FieldPos("F4_PISCOF")) > 0
		cQuery += ",F4_PISCOF "
	Endif

	If SF4->(FieldPos("F4_PISCRED")) > 0
		cQuery += ",F4_PISCRED "
	Endif

	cQuery 	+= "FROM "+RetSqlName("SD2")+" SD2, "
	cQuery 	+= RetSqlName("SF4")+" SF4, "
	cQuery 	+= RetSqlName("SB1")+" SB1, "
	cQuery 	+= RetSqlName("SF2")+" SF2 "

	cQuery 	+= "WHERE D2_FILIAL='"+xFilial("SD2")+"' AND "
	cQuery 	+= "D2_EMISSAO>='"+Dtos(MV_PAR02)+"' AND "
	cQuery 	+= "D2_EMISSAO<='"+Dtos(MV_PAR03)+"' AND "
	cQuery  += "SD2.D_E_L_E_T_ = ' ' AND "

	cQuery  += "F4_FILIAL = '"+xFilial("SF4")+"' AND "
	cQuery  += "F4_CODIGO = D2_TES AND "
	cQuery  += "SF4.D_E_L_E_T_ = ' ' AND "

	cQuery  += "B1_FILIAL = '"+xFilial("SB1")+"' AND "
	cQuery  += "B1_COD = D2_COD AND "
	cQuery  += "SB1.D_E_L_E_T_ = ' ' AND "

	cQuery  += "F2_FILIAL = '"+xFilial("SF2")+"' AND "
	cQuery  += "F2_DOC = D2_DOC AND "
	cQuery  += "F2_SERIE = D2_SERIE AND "
	cQuery  += "F2_CLIENTE = D2_CLIENTE AND "
	cQuery  += "F2_LOJA = D2_LOJA AND "
	cQuery  += "F2_EMISSAO = D2_EMISSAO AND "
	cQuery  += "SF2.D_E_L_E_T_ = ' ' "

	If ExistBlock("MT996QRY")
		cQuery := ExecBlock("MT996QRY",.F.,.F.,{cQuery,1})
	EndIf

	cQuery += "ORDER BY D2_CF, D2_COD"

	cQuery := ChangeQuery(cQuery)
	MsAguarde( {|| dbUseArea(.T.,"TOPCONN",TcGenQry(,,cQuery),cAliasSD2,.T.,.T.)},'Pesquisando Notas de Saida')
	count to _nLastSD2
	DbGoTop()

	For nX := 1 To len(aStruSD2)
		If aStruSD2[nX][2] <> "C" .And. FieldPos(aStruSD2[nX][1])<>0
			TcSetField(cAliasSD2,aStruSD2[nX][1],aStruSD2[nX][2],aStruSD2[nX][3],aStruSD2[nX][4])
		EndIf
	Next nX

	For nX := 1 To len(aStruSB1)
		If aStruSB1[nX][2] <> "C" .And. FieldPos(aStruSB1[nX][1])<>0
			TcSetField(cAliasSB1,aStruSB1[nX][1],aStruSB1[nX][2],aStruSB1[nX][3],aStruSB1[nX][4])
		EndIf
	Next nX

	For nX := 1 To len(aStruSF4)
		If aStruSF4[nX][2] <> "C" .And. FieldPos(aStruSF4[nX][1])<>0
			TcSetField(cAliasSF4,aStruSF4[nX][1],aStruSF4[nX][2],aStruSF4[nX][3],aStruSF4[nX][4])
		EndIf
	Next nX

	For nX := 1 To len(aStruSF2)
		If aStruSF2[nX][2] <> "C" .And. FieldPos(aStruSF2[nX][1])<>0
			TcSetField(cAliasSF2,aStruSF2[nX][1],aStruSF2[nX][2],aStruSF2[nX][3],aStruSF2[nX][4])
		EndIf
	Next nX

	dbSelectArea(cAliasSD2)
	nPsVlPisSa := ( cAliasSD2 )->( FieldPos( cCpVlPisSa ) )
	nPsBsPisSa := ( cAliasSD2 )->( FieldPos( cCpBsPisSa ) )
	nPsVlCofSa := ( cAliasSD2 )->( FieldPos( cCpVlCofSa ) )
	nPsBsCOfSa := ( cAliasSD2 )->( FieldPos( cCpBsCofSa ) )
	#ELSE
	cAliasSD2 := "SD2"
	cIndex    := CriaTrab(NIL,.F.)
	cKey	  := 'D2_CF'
	cCondicao := 'D2_FILIAL=="'+xFilial("SD2")+'".And.'
	cCondicao += 'DTOS(D2_EMISSAO)>="'+DTOS(MV_PAR02)+'".And.DTOS(D2_EMISSAO)<="'+DTOS(MV_PAR03)+'"'
	IndRegua(cAliasSD2,cIndex,cKey,,cCondicao)
	count to _nLastSD2
	DbGoTop()
	nIndex := RetIndex("SD2")
	dbSelectArea("SD2")
	dbSetIndex(cIndex+OrdBagExt())

	dbSetOrder(nIndex+1)
	dbGoTop()
	dbSelectArea(cAliasSD2)
	#ENDIF
	SetRegua(_nLastSD2)
	While (cAliasSD2)->(!Eof())

		IncRegua()
		If !lQuery
			SF4->(dbSetOrder(1))
			SF4->(MsSeek(xFilial("SF4")+(cAliasSD2)->D2_TES))
			SB1->(dbSetOrder(1))
			SB1->(MsSeek(xFilial("SB1")+(cAliasSD2)->D2_COD))
			SF2->(dbSetOrder(1))
			SF2->(MsSeek(xFilial("SF2")+(cAliasSD2)->D2_DOC+(cAliasSD2)->D2_SERIE+(cAliasSD2)->D2_CLIENTE+(cAliasSD2)->D2_LOJA))
		EndIf

		If (cAliasSF4)->F4_AGREG <> "N"

			If SB1->(FieldPos("B1_PPIS")) >0
				nTxPIS	:= 	(cAliasSB1)->D2_ALQIMP6
			Endif

			If SB1->(FieldPos("B1_REDPIS")) > 0
				nRedPIS	:= 	Iif((cAliasSB1)->B1_REDPIS > 0,1-((cAliasSB1)->B1_REDPIS / 100 ), 1 )
			Endif
			If SF4->(FieldPos("F4_BASEPIS")) > 0
				nRedPIS	*= 	Iif((cAliasSF4)->F4_BASEPIS > 0,1-((cAliasSF4)->F4_BASEPIS / 100 ), 1 )
			Endif

			If SB1->(FieldPos("B1_REDCOF")) > 0
				nRedCOF	:= 	Iif((cAliasSB1)->B1_REDCOF > 0,1-((cAliasSB1)->B1_REDCOF / 100 ), 1 )
			EndIf

			If SF4->(FieldPos("F4_BASECOF")) > 0
				nRedCOF	*= 	Iif((cAliasSF4)->F4_BASECOF > 0,1-((cAliasSF4)->F4_BASECOF / 100 ), 1 )
			EndIf

			If SB1->(FieldPos("B1_PCOFINS")) > 0
				nTxCOF	:= 	(cAliasSB1)->D2_ALQIMP6
			Endif

			If SF4->(FieldPos("F4_PISCOF")) > 0
				If (cAliasSF4)->F4_PISCOF $ "13" //1-PIS;3-Ambos
					nValPisPas := 0
					nBasPisPas := 0
					//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
					//³ Verifica se existem os campos para gravacao do valor/base do PIS  ³
					//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
					If !Empty( nPsVlPisSa ) .And. !Empty( nPsBsPisSa )
						nValPisPas := ( cAliasSD2 )->( FieldGet( nPsVlPisSa ) )
						nBasPisPas := ( cAliasSD2 )->( FieldGet( nPsBsPisSa ) )
					EndIf

					If mv_par01 <> 2 //PIS e Ambos
						RecLock("TRB",.T.)
						TRB->NUMNF     := (cAliasSD2)->D2_DOC
						TRB->SERIE     := (cAliasSD2)->D2_SERIE
						TRB->EMISSAO   := (cAliasSD2)->D2_EMISSAO
						TRB->CFOP      := (cAliasSD2)->D2_CF
						TRB->PRODUTO   := (cAliasSD2)->D2_COD
						TRB->NCM       := (cAliasSB1)->B1_POSIPI
						TRB->VALORCONT := (cAliasSD2)->D2_TOTAL+(cAliasSD2)->D2_ICMSRET+(cAliasSD2)->D2_VALIPI+(cAliasSD2)->D2_VALFRE+(cAliasSD2)->D2_SEGURO+(cAliasSD2)->D2_DESPESA
						TRB->ZFRANCA   := (cAliasSD2)->D2_DESCZFR
						TRB->ALIQ      := nTxPIS
						TRB->TIPO      := "PIS"
						TRB->ES			:=	"S"
						MsUnlock()
						//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
						//³ Verifica se existe algum valor gravado, se nao, calcula           ³
						//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
						If !Empty( nValPisPas ) .And. !Empty( nBasPisPas )
							//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
							//³ Sempre efetua o debito na saida                                   ³
							//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
							RecLock("TRB",.F.)
							TRB->PISDSAI   := nValPisPas
							TRB->BASPIDSAI := nBasPisPas
							If SF4->(FieldPos("F4_PISCRED")) >0
								If (cAliasSF4)->F4_PISCRED =="1"  //1-Credita;2-Debita
									TRB->PISCSAI   := nValPisPas
									TRB->BASPICSAI := nBasPisPas
								Endif
							Endif
							MsUnlock()
						Else
							//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
							//³ Sempre efetua o debito na saida                                   ³
							//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
							RecLock("TRB",.F.)
							TRB->PISDSAI   := ( ( (cAliasSD2)->D2_TOTAL+((cAliasSD2)->D2_TOTAL*((cAliasSF2)->F2_SEGURO+(cAliasSF2)->F2_DESPESA+(cAliasSF2)->F2_FRETE)/(cAliasSF2)->F2_VALMERC) ) * nRedPis ) * (TRB->ALIQ/100)
							TRB->BASPIDSAI := ( (cAliasSD2)->D2_TOTAL+((cAliasSD2)->D2_TOTAL*((cAliasSF2)->F2_SEGURO+(cAliasSF2)->F2_DESPESA+(cAliasSF2)->F2_FRETE)/(cAliasSF2)->F2_VALMERC)  ) * nRedPis
							If SF4->(FieldPos("F4_PISCRED")) >0
								If (cAliasSF4)->F4_PISCRED =="1"  //1-Credita;2-Debita
									TRB->PISCSAI   := ( ( (cAliasSD2)->D2_TOTAL+((cAliasSD2)->D2_TOTAL*((cAliasSF2)->F2_SEGURO+(cAliasSF2)->F2_DESPESA+(cAliasSF2)->F2_FRETE)/(cAliasSF2)->F2_VALMERC) )  * nRedPis) * (TRB->ALIQ/100)
									TRB->BASPICSAI := ( (cAliasSD2)->D2_TOTAL+((cAliasSD2)->D2_TOTAL*((cAliasSF2)->F2_SEGURO+(cAliasSF2)->F2_DESPESA+(cAliasSF2)->F2_FRETE)/(cAliasSF2)->F2_VALMERC)  ) * nRedPis
								Endif
							Endif
							MsUnlock()
						EndIf
					Endif
				EndIf
				If (cAliasSF4)->F4_PISCOF $ "23" .And. mv_par01 <> 1 // 2-Cofins; 3- Ambos
					nValCofins := 0
					nBasCofins := 0
					//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
					//³ Verifica se existem os campos para gravacao do valor/base do PIS  ³
					//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
					If !Empty( nPsVlCofSa ) .And. !Empty( nPsBsCofSa )
						nValCofins := ( cAliasSD2 )->( FieldGet( nPsVlCofSa ) )
						nBasCofins := ( cAliasSD2 )->( FieldGet( nPsBsCofSa ) )
					EndIf

					RecLock("TRB",.T.)
					TRB->NUMNF     := (cAliasSD2)->D2_DOC
					TRB->SERIE     := (cAliasSD2)->D2_SERIE
					TRB->EMISSAO   := (cAliasSD2)->D2_EMISSAO
					TRB->CFOP      := (cAliasSD2)->D2_CF
					TRB->PRODUTO   := (cAliasSD2)->D2_COD
					TRB->NCM       := (cAliasSB1)->B1_POSIPI
					TRB->VALORCONT := (cAliasSD2)->D2_TOTAL+(cAliasSD2)->D2_ICMSRET+(cAliasSD2)->D2_VALIPI+(cAliasSD2)->D2_VALFRE+(cAliasSD2)->D2_SEGURO+(cAliasSD2)->D2_DESPESA
					TRB->ZFRANCA   := (cAliasSD2)->D2_DESCZFR
					TRB->ALIQ      := nTxCOF
					TRB->TIPO      := "COF"
					TRB->ES        := "S"
					//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
					//³ Verifica se existe algum valor gravado, se nao, calcula           ³
					//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
					If !Empty( nValCofins ) .And. !Empty( nBasCofins )

						RecLock("TRB",.F.)
						TRB->COFDSAI   := nValCofins
						TRB->BASCODSAI := nBasCofins
						If SF4->(FieldPos("F4_PISCRED")) >0
							If (cAliasSF4)->F4_PISCRED =="1"  //1-Credita;2-Debita
								TRB->COFCSAI   := nValCofins
								TRB->BASCOCSAI := nBasCofins
							Endif
						Endif
						MsUnlock()
					Else
						TRB->COFDSAI   := ( ( (cAliasSD2)->D2_TOTAL+((cAliasSD2)->D2_TOTAL*((cAliasSF2)->F2_SEGURO+(cAliasSF2)->F2_DESPESA+(cAliasSF2)->F2_FRETE)/(cAliasSF2)->F2_VALMERC) ) * nRedCOF) * (TRB->ALIQ/100)
						TRB->BASCODSAI := ( (cAliasSD2)->D2_TOTAL+((cAliasSD2)->D2_TOTAL*((cAliasSF2)->F2_SEGURO+(cAliasSF2)->F2_DESPESA+(cAliasSF2)->F2_FRETE)/(cAliasSF2)->F2_VALMERC)  ) * nRedCOF
						If SF4->(FieldPos("F4_PISCRED")) >0
							If (cAliasSF4)->F4_PISCRED =="1"  //1-Credita ;2-Debita
								TRB->COFCSAI   := ( ( (cAliasSD2)->D2_TOTAL+((cAliasSD2)->D2_TOTAL*((cAliasSF2)->F2_SEGURO+(cAliasSF2)->F2_DESPESA+(cAliasSF2)->F2_FRETE)/(cAliasSF2)->F2_VALMERC) )  * nRedCOF) * (TRB->ALIQ/100)
								TRB->BASCOCSAI := ( (cAliasSD2)->D2_TOTAL+((cAliasSD2)->D2_TOTAL*((cAliasSF2)->F2_SEGURO+(cAliasSF2)->F2_DESPESA+(cAliasSF2)->F2_FRETE)/(cAliasSF2)->F2_VALMERC)  ) * nRedCOF
							Endif
						Endif
						MsUnlock()
					Endif
				EndIf

				//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
				//³ Gera as informacoes para o Resumo -  Saida ³
				//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ

				If (cAliasSF4)->F4_PISCOF $ "123" //1-PIS;2-COFINS;3-Ambos

					If !(cAliasSD2)->D2_TIPO $ "BD"
						nVendTrib += (cAliasSD2)->D2_TOTAL+(cAliasSD2)->D2_ICMSRET+(cAliasSD2)->D2_VALIPI+(cAliasSD2)->D2_VALFRE+(cAliasSD2)->D2_SEGURO+(cAliasSD2)->D2_DESPESA
					EndIf

					If (cAliasSD2)->D2_TIPO == "D"
						nDevCompT += (cAliasSD2)->D2_TOTAL+(cAliasSD2)->D2_ICMSRET+(cAliasSD2)->D2_VALIPI+(cAliasSD2)->D2_VALFRE+(cAliasSD2)->D2_SEGURO+(cAliasSD2)->D2_DESPESA
					EndIF

				ELSE
					If !(cAliasSD2)->D2_TIPO $ "BD"
						nValVend += (cAliasSD2)->D2_TOTAL+(cAliasSD2)->D2_ICMSRET+(cAliasSD2)->D2_VALIPI+(cAliasSD2)->D2_VALFRE+(cAliasSD2)->D2_SEGURO+(cAliasSD2)->D2_DESPESA
					EndIF

					If (cAliasSD2)->D2_TIPO == "D"
						nValDevComp += (cAliasSD2)->D2_TOTAL+(cAliasSD2)->D2_ICMSRET+(cAliasSD2)->D2_VALIPI+(cAliasSD2)->D2_VALFRE+(cAliasSD2)->D2_SEGURO+(cAliasSD2)->D2_DESPESA // Devolucoes Compras D2
					EndIF
				Endif

			EndIf
		EndIf


		(cAliasSD2)->( dbSkip())
		IncRegua()
	EndDo
	If lQuery
		dbSelectArea(cAliasSD2)
		dbCloseArea()
		dbSelectArea("SD2")
	Else
		dbSelectArea("SD2")
		RetIndex("SD2")
		dbClearFilter()
		Ferase(cIndex+OrdBagExt())
	EndIf



	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Processamento das Entradas                                        ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	dbSelectArea("SD1")
	SD1->(dbSetOrder(6))
	#IFDEF TOP
	lQuery := .T.
	cAliasSD1 := "a906AMontSD1"
	cAliasSF4 := "a906AMontSD1"
	cAliasSB1 := "a906AMontSD1"
	cAliasSF1 := "a906AMontSD1"

	aStruSD1  := SD1->(dbStruct())
	aStruSB1  := SB1->(dbStruct())
	aStruSF4  := SF4->(dbStruct())
	aStruSF1  := SF1->(dbStruct())

	cQuery 	:= "SELECT D1_CF, D1_COD, D1_TOTAL, D1_VALDESC, B1_POSIPI, D1_DOC, D1_SERIE, D1_DTDIGIT, D1_TIPO, "
	cQuery  += "D1_ICMSRET,D1_VALIPI,D1_VALFRE,D1_SEGURO,D1_DESPESA, D1_ALQIMP5, D1_VALIMP5, D1_ALQIMP6, D1_VALIMP6, "

	If !Empty( nPsVlPisEn )
		cQuery += cCpVlPisEn + ","
	EndIf

	If !Empty( nPsBsPisEn )
		cQuery += cCpBsPisEn + ","
	EndIf

	If !Empty( nPsVlCofEn )
		cQuery += cCpVlCofEn + ","
	EndIf

	If !Empty( nPsBsCofEn )
		cQuery += cCpBsCofEn + ","
	EndIf

	cQuery  += "F4_AGREG, F4_PISCOF, F1_SEGURO, F1_FRETE, F1_DESPESA, F1_VALMERC, F1_DOC,F1_SERIE,F1_FORNECE,F1_LOJA "

	If SB1->(FieldPos("B1_PPIS")) >0
		cQuery += ",B1_PPIS "
	Endif

	If SB1->(FieldPos("B1_REDPIS")) > 0
		cQuery += ",B1_REDPIS "
	Endif

	If SB1->(FieldPos("B1_REDCOF")) > 0
		cQuery += ",B1_REDCOF "
	Endif

	If SB1->(FieldPos("B1_PCOFINS")) > 0
		cQuery += ",B1_PCOFINS "
	Endif

	If SF4->(FieldPos("F4_BASEPIS")) > 0
		cQuery += ",F4_BASEPIS "
	Endif


	If SF4->(FieldPos("F4_PISCOF")) > 0
		cQuery += ",F4_PISCOF "
	Endif

	If SF4->(FieldPos("F4_BASECOF")) > 0
		cQuery += ",F4_BASECOF "
	Endif

	If SF4->(FieldPos("F4_PISCRED")) > 0
		cQuery += ",F4_PISCRED "
	Endif

	cQuery 	+= "FROM "+RetSqlName("SD1")+" SD1, "
	cQuery 	+= RetSqlName("SF4")+" SF4, "
	cQuery 	+= RetSqlName("SB1")+" SB1, "
	cQuery 	+= RetSqlName("SF1")+" SF1 "

	cQuery 	+= "WHERE D1_FILIAL='"+xFilial("SD1")+"' AND "
	cQuery 	+= "D1_DTDIGIT>='"+Dtos(MV_PAR02)+"' AND "
	cQuery 	+= "D1_DTDIGIT<='"+Dtos(MV_PAR03)+"' AND "
	cQuery  += "SD1.D_E_L_E_T_ = ' ' AND "

	cQuery  += "F4_FILIAL ='"+xFilial("SF4")+"' AND "
	cQuery  += "F4_CODIGO = D1_TES AND "
	cQuery  += "SF4.D_E_L_E_T_ = ' ' AND "

	cQuery  += "B1_FILIAL = '"+xFilial("SB1")+"' AND "
	cQuery  += "B1_COD = D1_COD AND "
	cQuery  += "SB1.D_E_L_E_T_ = ' ' AND "

	cQuery  += "F1_FILIAL = '"+xFilial("SF1")+"' AND "
	cQuery  += "F1_DOC = D1_DOC AND "
	cQuery  += "F1_SERIE = D1_SERIE AND "
	cQuery  += "F1_FORNECE = D1_FORNECE AND "
	cQuery  += "F1_LOJA = F1_LOJA AND "
	cQuery  += "F1_DTDIGIT = D1_DTDIGIT AND "
	cQuery  += "SF1.D_E_L_E_T_ = ' ' "

	If ExistBlock("MT996QRY")
		cQuery := ExecBlock("MT996QRY",.F.,.F.,{cQuery,2})
	EndIf

	cQuery += "ORDER BY D1_CF, D1_COD"

	cQuery := ChangeQuery(cQuery)
	MsAguarde( {|| dbUseArea(.T.,"TOPCONN",TcGenQry(,,cQuery),cAliasSD1,.T.,.T.)},'Pesquisando Notas de Entrada')
	count to _nLastSD1
	DbGoTop()

	For nX := 1 To len(aStruSD1)
		If aStruSD1[nX][2] <> "C" .And. FieldPos(aStruSD1[nX][1])<>0
			TcSetField(cAliasSD1,aStruSD1[nX][1],aStruSD1[nX][2],aStruSD1[nX][3],aStruSD1[nX][4])
		EndIf
	Next nX

	For nX := 1 To len(aStruSB1)
		If aStruSB1[nX][2] <> "C" .And. FieldPos(aStruSB1[nX][1])<>0
			TcSetField(cAliasSB1,aStruSB1[nX][1],aStruSB1[nX][2],aStruSB1[nX][3],aStruSB1[nX][4])
		EndIf
	Next nX

	For nX := 1 To len(aStruSF4)
		If aStruSF4[nX][2] <> "C" .And. FieldPos(aStruSF4[nX][1])<>0
			TcSetField(cAliasSF4,aStruSF4[nX][1],aStruSF4[nX][2],aStruSF4[nX][3],aStruSF4[nX][4])
		EndIf
	Next nX

	For nX := 1 To len(aStruSF1)
		If aStruSF1[nX][2] <> "C" .And. FieldPos(aStruSF1[nX][1])<>0
			TcSetField(cAliasSF1,aStruSF1[nX][1],aStruSF1[nX][2],aStruSF1[nX][3],aStruSF1[nX][4])
		EndIf
	Next nX
	dbSelectArea(cAliasSD1)
	nPsVlPisEn := ( cAliasSD1 )->( FieldPos( cCpVlPisEn ) )
	nPsBsPisEn := ( cAliasSD1 )->( FieldPos( cCpBsPisEn ) )
	nPsVlCofEn := ( cAliasSD1 )->( FieldPos( cCpVlCofEn ) )
	nPsBsCofEn := ( cAliasSD1 )->( FieldPos( cCpBsCofEn ) )
	#ELSE
	cAliasSD1 := "SD1"
	cIndex1   := CriaTrab(NIL,.F.)
	cKey	  := 'D1_CF'
	cCondicao := 'D1_FILIAL=="'+xFilial("SD1")+'".And.'
	cCondicao += 'DTOS(D1_DTDIGIT)>="'+DTOS(MV_PAR02)+'".And.DTOS(D1_DTDIGIT)<="'+DTOS(MV_PAR03)+'"'
	IndRegua(cAliasSD1,cIndex1,cKey,,cCondicao)
	count to _nLastSD1
	DbGoTop()
	nIndex := RetIndex("SD1")
	dbSelectArea("SD1")
	dbSetIndex(cIndex1+OrdBagExt())

	dbSetOrder(nIndex+1)
	dbGoTop()
	dbSelectArea(cAliasSD1)
	#ENDIF
	SetRegua(_nLastSD1)
	While (cAliasSD1)->(!Eof())
		IncRegua()
		If !lQuery
			SF4->(dbSetOrder(1))
			SF4->(MsSeek(xFilial("SF4")+(cAliasSD1)->D1_TES))
			SB1->(dbSetOrder(1))
			SB1->(MsSeek(xFilial("SB1")+(cAliasSD1)->D1_COD))
			SF1->(dbSetOrder(1))
			SF1->(MsSeek(xFilial("SF1")+(cAliasSD1)->D1_DOC+(cAliasSD1)->D1_SERIE+(cAliasSD1)->D1_FORNECE+(cAliasSD1)->D1_LOJA+(cAliasSD1)->D1_TIPO))
		EndIf

		If (cAliasSF4)->F4_AGREG <> "N"
			If SB1->(FieldPos("B1_PPIS")) >0
				nTxPIS	:= 	(cAliasSB1)->D1_ALQIMP6
			Endif
			If SB1->(FieldPos("B1_REDPIS")) > 0
				nRedPIS	:= 	Iif((cAliasSB1)->B1_REDPIS > 0,1-((cAliasSB1)->B1_REDPIS / 100 ), 1 )
			Endif
			If SF4->(FieldPos("F4_BASEPIS")) > 0
				nRedPIS	*= 	Iif((cAliasSF4)->F4_BASEPIS > 0,1-((cAliasSF4)->F4_BASEPIS / 100 ), 1 )
			Endif
			If SB1->(FieldPos("B1_REDCOF")) > 0
				nRedCOF	:= 	Iif((cAliasSB1)->B1_REDCOF > 0,1-((cAliasSB1)->B1_REDCOF / 100 ), 1 )
			Endif
			If SF4->(FieldPos("F4_BASECOF")) > 0
				nRedCOF	*= 	Iif((cAliasSF4)->F4_BASECOF > 0,1-((cAliasSF4)->F4_BASECOF / 100 ), 1 )
			EndIf
			If SB1->(FieldPos("B1_PCOFINS")) > 0
				nTxCOF	:= 	(cAliasSB1)->D1_ALQIMP5
			Endif
			If SF4->(FieldPos("F4_PISCOF")) >0
				If (cAliasSF4)->F4_PISCOF $ "13" //1-PIS,3=Ambos
					If SF4->(FieldPos("F4_PISCRED")) >0
						nValPisPas := 0
						nBasPisPas := 0
						//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
						//³ Verifica se existem os campos para gravacao do valor/base do PIS  ³
						//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
						If !Empty( nPsVlPisEn ) .And. !Empty( nPsBsPisEn )
							nValPisPas := ( cAliasSD1 )->( FieldGet( nPsVlPisEn ) )
							nBasPisPas := ( cAliasSD1 )->( FieldGet( nPsBsPisEn ) )
						EndIf
						If mv_par01 <> 2 //PIS e Ambos
							RecLock("TRB",.T.)
							TRB->NUMNF     := (cAliasSD1)->D1_DOC
							TRB->SERIE     := (cAliasSD1)->D1_SERIE
							TRB->EMISSAO   := (cAliasSD1)->D1_DTDIGIT
							TRB->CFOP      := (cAliasSD1)->D1_CF
							TRB->PRODUTO   := (cAliasSD1)->D1_COD
							TRB->NCM       := (cAliasSB1)->B1_POSIPI
							TRB->VALORCONT := ((cAliasSD1)->D1_TOTAL+(cAliasSD1)->D1_ICMSRET+(cAliasSD1)->D1_VALIPI+(cAliasSD1)->D1_VALFRE+(cAliasSD1)->D1_SEGURO+(cAliasSD1)->D1_DESPESA)-(cAliasSD1)->D1_VALDESC
							TRB->ZFRANCA   := 0
							TRB->ALIQ      := nTxPIS
							TRB->TIPO      := "PIS"
							TRB->ES			:=	"E"
							MsUnlock()
							//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
							//³ Verifica se existe algum valor gravado, se nao, calcula           ³
							//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
							If !Empty( nValPisPas ) .And. !Empty( nBasPisPas )
								RecLock("TRB",.F.)
								If (cAliasSF4)->F4_PISCRED =="1"  //1-Credita;2-Debita
									TRB->PISCENT   := nValPisPas
									TRB->BASPICENT := nBasPisPas
								ElseIf (cAliasSF4)->F4_PISCRED =="2"
									TRB->PISDENT   := nValPisPas
									TRB->BASPIDENT := nBasPisPas
								Endif
								MsUnlock()
							Else
								RecLock("TRB",.F.)
								If (cAliasSF4)->F4_PISCRED =="1"  //1-Credita;2-Debita
									TRB->PISCENT   := ( ( (cAliasSD1)->D1_TOTAL+((cAliasSD1)->D1_TOTAL*((cAliasSF1)->F1_SEGURO+(cAliasSF1)->F1_DESPESA+(cAliasSF1)->F1_FRETE)/(cAliasSF1)->F1_VALMERC)-(cAliasSD1)->D1_VALDESC) * nRedPis) * (TRB->ALIQ/100)
									TRB->BASPICENT := ( (cAliasSD1)->D1_TOTAL+((cAliasSD1)->D1_TOTAL*((cAliasSF1)->F1_SEGURO+(cAliasSF1)->F1_DESPESA+(cAliasSF1)->F1_FRETE)/(cAliasSF1)->F1_VALMERC)-(cAliasSD1)->D1_VALDESC )  * nRedPis
								ElseIf (cAliasSF4)->F4_PISCRED =="2"
									TRB->PISDENT   := ( ( (cAliasSD1)->D1_TOTAL+((cAliasSD1)->D1_TOTAL*((cAliasSF1)->F1_SEGURO+(cAliasSF1)->F1_DESPESA+(cAliasSF1)->F1_FRETE)/(cAliasSF1)->F1_VALMERC)-(cAliasSD1)->D1_VALDESC) * nRedPis) * (TRB->ALIQ/100)
									TRB->BASPIDENT := ( (cAliasSD1)->D1_TOTAL+((cAliasSD1)->D1_TOTAL*((cAliasSF1)->F1_SEGURO+(cAliasSF1)->F1_DESPESA+(cAliasSF1)->F1_FRETE)/(cAliasSF1)->F1_VALMERC)-(cAliasSD1)->D1_VALDESC  ) * nRedPis
								Endif
								MsUnlock()
							EndIf
						Endif
					EndIf
				Endif
				If (cAliasSF4)->F4_PISCOF $ "23" .And. mv_par01 <> 1 //2-COFINS;3-Ambos
					If SF4->(FieldPos("F4_PISCRED")) >0
						nValCofins := 0
						nBasCofins := 0
						//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
						//³ Verifica se existem os campos para gravacao do valor/base da COFINS ³
						//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
						If !Empty( nPsVlCofEn ) .And. !Empty( nPsBsCofEn )
							nValCofins := ( cAliasSD1 )->( FieldGet( nPsVlCofEn ) )
							nBasCofins := ( cAliasSD1 )->( FieldGet( nPsBsCofEn ) )
						EndIf

						RecLock("TRB",.T.)
						TRB->NUMNF     := (cAliasSD1)->D1_DOC
						TRB->SERIE     := (cAliasSD1)->D1_SERIE
						TRB->EMISSAO   := (cAliasSD1)->D1_DTDIGIT
						TRB->CFOP      := (cAliasSD1)->D1_CF
						TRB->PRODUTO   := (cAliasSD1)->D1_COD
						TRB->NCM       := (cAliasSB1)->B1_POSIPI
						TRB->VALORCONT := ((cAliasSD1)->D1_TOTAL+(cAliasSD1)->D1_ICMSRET+(cAliasSD1)->D1_VALIPI+(cAliasSD1)->D1_VALFRE+(cAliasSD1)->D1_SEGURO+(cAliasSD1)->D1_DESPESA)-(cAliasSD1)->D1_VALDESC
						TRB->ZFRANCA   := 0
						TRB->ALIQ      := nTxCOF
						TRB->TIPO      := "COF"
						TRB->ES        := "E"
						MsUnlock()
						//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
						//³ Verifica se existe algum valor gravado, se nao, calcula           ³
						//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
						If !Empty( nValCofins ) .And. !Empty( nBasCofins )
							RecLock("TRB",.F.)
							If (cAliasSF4)->F4_PISCRED =="1"  //1-Credita;2-Debita
								TRB->COFCENT   := nValCofins
								TRB->BASCOCENT := nBasCofins
							ElseIf (cAliasSF4)->F4_PISCRED =="2"
								TRB->COFDENT   := nValCofins
								TRB->BASCODENT := nBasCofins
							Endif
							MsUnlock()
						Else
							RecLock("TRB",.F.)
							If (cAliasSF4)->F4_PISCRED =="1"  //1-Credita ;2-Debita
								TRB->COFCENT   := ( ( (cAliasSD1)->D1_TOTAL+((cAliasSD1)->D1_TOTAL*((cAliasSF1)->F1_SEGURO+(cAliasSF1)->F1_DESPESA+(cAliasSF1)->F1_FRETE)/(cAliasSF1)->F1_VALMERC)-(cAliasSD1)->D1_VALDESC )  * nRedCOF) * (TRB->ALIQ/100)
								TRB->BASCOCENT := ( (cAliasSD1)->D1_TOTAL+((cAliasSD1)->D1_TOTAL*((cAliasSF1)->F1_SEGURO+(cAliasSF1)->F1_DESPESA+(cAliasSF1)->F1_FRETE)/(cAliasSF1)->F1_VALMERC)-(cAliasSD1)->D1_VALDESC  ) * nRedCOF
							ElseIf	(cAliasSF4)->F4_PISCRED =="2"
								TRB->COFDENT   := ( ( (cAliasSD1)->D1_TOTAL+((cAliasSD1)->D1_TOTAL*((cAliasSF1)->F1_SEGURO+(cAliasSF1)->F1_DESPESA+(cAliasSF1)->F1_FRETE)/(cAliasSF1)->F1_VALMERC)-(cAliasSD1)->D1_VALDESC )  * nRedCOF) * (TRB->ALIQ/100)
								TRB->BASCODENT := ( (cAliasSD1)->D1_TOTAL+((cAliasSD1)->D1_TOTAL*((cAliasSF1)->F1_SEGURO+(cAliasSF1)->F1_DESPESA+(cAliasSF1)->F1_FRETE)/(cAliasSF1)->F1_VALMERC)-(cAliasSD1)->D1_VALDESC  ) * nRedCOF
							Endif
							MsUnlock()
						Endif
					Endif
				Endif

				//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
				//³ Gera as informacoes para o Resumo -  Entrada ³
				//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ

				If (cAliasSF4)->F4_PISCOF $ "123" //1-PIS;2-COFINS;3-Ambos

					If !(cAliasSD1)->D1_TIPO $ "BD"
						nCompTrib += ((cAliasSD1)->D1_TOTAL+(cAliasSD1)->D1_ICMSRET+(cAliasSD1)->D1_VALIPI+(cAliasSD1)->D1_VALFRE+(cAliasSD1)->D1_SEGURO+(cAliasSD1)->D1_DESPESA)-(cAliasSD1)->D1_VALDESC
					EndIf

					If (cAliasSD1)->D1_TIPO == "D"
						nDevVendT += ((cAliasSD1)->D1_TOTAL+(cAliasSD1)->D1_ICMSRET+(cAliasSD1)->D1_VALIPI+(cAliasSD1)->D1_VALFRE+(cAliasSD1)->D1_SEGURO+(cAliasSD1)->D1_DESPESA)-(cAliasSD1)->D1_VALDESC
					EndIF

				ELSE
					If !(cAliasSD1)->D1_TIPO $ "BD"
						nValComp += ((cAliasSD1)->D1_TOTAL+(cAliasSD1)->D1_ICMSRET+(cAliasSD1)->D1_VALIPI+(cAliasSD1)->D1_VALFRE+(cAliasSD1)->D1_SEGURO+(cAliasSD1)->D1_DESPESA)-(cAliasSD1)->D1_VALDESC
					EndIF
					If (cAliasSD1)->D1_TIPO == "D"
						nValDevVend += ((cAliasSD1)->D1_TOTAL+(cAliasSD1)->D1_ICMSRET+(cAliasSD1)->D1_VALIPI+(cAliasSD1)->D1_VALFRE+(cAliasSD1)->D1_SEGURO+(cAliasSD1)->D1_DESPESA)-(cAliasSD1)->D1_VALDESC
					EndIF
				EndIf
			EndIf
		EndIf

		(cAliasSD1)->( dbSkip())
		IncRegua()
	EndDo

	If lQuery
		dbSelectArea(cAliasSD1)
		dbCloseArea()
		dbSelectArea("SD1")
	Else
		dbSelectArea("SD1")
		RetIndex("SD1")
		dbClearFilter()
		Ferase(cIndex1+OrdBagExt())
	EndIf

	dbSelectArea("TRB")
	SetRegua(RecCount())		// Total de Elementos da regua
	dbGoTop()

	If (aReturn[8]==2)
		R906Imp (cArqTemp)
		lResumo	:=	.T.
	Else
		While !Eof() .And. lContinua

			IF lEnd
				@Prow()+1,001 PSAY "CANCELADO PELO OPERADOR"
				lContinua := .F.
				Exit
			Endif

			IncRegua()

			If li > 58
				cabec(ctitulo,cabec1,cabec2,nomeprog,ctamanho,15)
			EndIf

			nValCont := 0
			nZFranca := 0
			nValDebi := 0
			nValCred := 0
			nBasDebi := 0
			nBasCred := 0

			cQuebra  := TRB->TIPO+TRB->CFOP
			lEntrada := IIf(Substr(TRB->CFOP,1,1) < "5",.T.,.F.)

			If !lFirst
				@Li, 001 Psay "Empresa : " + SM0->M0_NOMECOM
				Li++
				@Li, 001 Psay "CNPJ    : " + Transform(SM0->M0_CGC,"@R 99.999.999/9999-99") //"CNPJ    : "
				Li++
				@Li, 001 Psay "Periodo : " + Dtoc(mv_par02) + " - " + Dtoc(mv_par03) //"Periodo : "
				Li := Li + 2
				lFirst := .T.
			Endif

			If TRB->TIPO <> cTipo .Or. lQuebra
				If lQuebra .And. TRB->TIPO <> cTipo
					cabec(ctitulo,cabec1,cabec2,nomeprog,ctamanho,15)
				Endif
				@Li, 001 PSAY IIf(TRB->TIPO == "PIS",PADC("PIS - Programa de Integracao Social"+IIf(Substr(TRB->CFOP,1,1) < "5"," - ENTRADAS"," - SAIDAS"),Limite),;
				PADC("COFINS - Contribuicao para o Financiamento da Seguridade Social"+IIf(Substr(TRB->CFOP,1,1) < "5"," - ENTRADAS"," - SAIDAS"),Limite))
				Li := Li + 2
				cTipo := TRB->TIPO
				lQuebra  := .F.
			Endif

			//202304 - busca informações do SX5 com a função FWGetSX5
			//	@Li, 001 PSAY TRB->CFOP+IIF(SX5->(MsSeek(xFilial("SX5")+"13"+TRB->CFOP))," - "+AllTrim(SX5->X5_DESCRI),"")
			aDados := FWGetSX5("13",TRB->CFOP)
			if len(aDados) > 0
				_cDescCFOP := " - " + alltrim(aDados[1,4])
			else
				_cDescCFOP := ''
			endif 
			@Li, 001 PSAY TRB->CFOP + _cDescCFOP


			Li++

			While !Eof() .And. TRB->TIPO+TRB->CFOP == cQuebra

				If li > 58
					cabec(ctitulo,cabec1,cabec2,nomeprog,ctamanho,15)
				EndIf

				If mv_par04 == 1
					@Li , 001 PSAY TRB->PRODUTO
					@Li , 018 PSAY TRB->NCM
					@Li , 030 PSAY TRB->VALORCONT Picture PesqPict("SD2","D2_TOTAL",14)
					@Li , 050 PSAY TRB->ZFRANCA   Picture PesqPict("SD2","D2_DESCZFR",14)
					@Li , 073 PSAY Transform(TRB->ALIQ,"@E 99.99%")

					If Substr(TRB->CFOP,1,1) >= "5"
						@Li , 083 PSAY IIF(TRB->TIPO == "PIS",TRB->PISDSAI,TRB->COFDSAI)     Picture PesqPict("SD2","D2_TOTAL",14)
						@Li , 107 PSAY IIF(TRB->TIPO == "PIS",TRB->PISCSAI,TRB->COFCSAI)     Picture PesqPict("SD2","D2_TOTAL",14)
						@Li , 131 PSAY IIF(TRB->TIPO == "PIS",TRB->BASPIDSAI,TRB->BASCODSAI) Picture PesqPict("SD2","D2_TOTAL",14)
						@Li , 155 PSAY IIF(TRB->TIPO == "PIS",TRB->BASPICSAI,TRB->BASCOCSAI) Picture PesqPict("SD2","D2_TOTAL",14)
					Else
						@Li , 083 PSAY IIF(TRB->TIPO == "PIS",TRB->PISDENT,TRB->COFDENT)     Picture PesqPict("SD2","D2_TOTAL",14)
						@Li , 107 PSAY IIF(TRB->TIPO == "PIS",TRB->PISCENT,TRB->COFCENT)     Picture PesqPict("SD2","D2_TOTAL",14)
						@Li , 131 PSAY IIF(TRB->TIPO == "PIS",TRB->BASPIDENT,TRB->BASCODENT) Picture PesqPict("SD2","D2_TOTAL",14)
						@Li , 155 PSAY IIF(TRB->TIPO == "PIS",TRB->BASPICENT,TRB->BASCOCENT) Picture PesqPict("SD2","D2_TOTAL",14)
					Endif

					@Li , 178 PSAY TRB->NUMNF
					@Li , 191 PSAY TRB->SERIE
					@Li , 198 PSAY TRB->EMISSAO
				Endif


				nValCont += TRB->VALORCONT
				nZFranca += TRB->ZFRANCA

				nGValCont += TRB->VALORCONT
				nGZFranca += TRB->ZFRANCA


				If Substr(TRB->CFOP,1,1) >= "5"
					nValDebi += IIF(TRB->TIPO == "PIS",TRB->PISDSAI,TRB->COFDSAI)
					nValCred += IIF(TRB->TIPO == "PIS",TRB->PISCSAI,TRB->COFCSAI)
					nBasDebi += IIF(TRB->TIPO == "PIS",TRB->BASPIDSAI,TRB->BASCODSAI)
					nBasCred += IIF(TRB->TIPO == "PIS",TRB->BASPICSAI,TRB->BASCOCSAI)

					nGValDebi += IIF(TRB->TIPO == "PIS",TRB->PISDSAI,TRB->COFDSAI)
					nGValCred += IIF(TRB->TIPO == "PIS",TRB->PISCSAI,TRB->COFCSAI)
					nGBasDebi += IIF(TRB->TIPO == "PIS",TRB->BASPIDSAI,TRB->BASCODSAI)
					nGBasCred += IIF(TRB->TIPO == "PIS",TRB->BASPICSAI,TRB->BASCOCSAI)

					nPosAliq := Ascan(aAliqs,{|x| x[1]==TRB->ALIQ})
					If nPosAliq > 0
						aAliqs[nPosAliq][2] += IIF(TRB->TIPO == "PIS",TRB->PISDSAI,TRB->COFDSAI)-IIF(TRB->TIPO == "PIS",TRB->PISCSAI,TRB->COFCSAI)
						aAliqs[nPosAliq][3] += TRB->VALORCONT
						aAliqs[nPosAliq][4] += TRB->ZFRANCA
						aAliqs[nPosAliq][5] += IIF(TRB->TIPO == "PIS",TRB->PISDSAI,TRB->COFDSAI)
						aAliqs[nPosAliq][6] += IIF(TRB->TIPO == "PIS",TRB->PISCSAI,TRB->COFCSAI)
						aAliqs[nPosAliq][7] += IIF(TRB->TIPO == "PIS",TRB->BASPIDSAI,TRB->BASCODSAI)
						aAliqs[nPosAliq][8] += IIF(TRB->TIPO == "PIS",TRB->BASPICSAI,TRB->BASCOCSAI)
					Else
						AADD(aAliqs,{TRB->ALIQ,;
						IIF(TRB->TIPO == "PIS",TRB->PISDSAI,TRB->COFDSAI)-IIF(TRB->TIPO == "PIS",TRB->PISCSAI,TRB->COFCSAI),;
						TRB->VALORCONT,;
						TRB->ZFRANCA,;
						IIF(TRB->TIPO == "PIS",TRB->PISDSAI,TRB->COFDSAI),;
						IIF(TRB->TIPO == "PIS",TRB->PISCSAI,TRB->COFCSAI),;
						IIF(TRB->TIPO == "PIS",TRB->BASPIDSAI,TRB->BASCODSAI),;
						IIF(TRB->TIPO == "PIS",TRB->BASPICSAI,TRB->BASCOCSAI)})
					Endif
				Else
					nValDebi += IIF(TRB->TIPO == "PIS",TRB->PISDENT,TRB->COFDENT)
					nValCred += IIF(TRB->TIPO == "PIS",TRB->PISCENT,TRB->COFCENT)
					nBasDebi += IIF(TRB->TIPO == "PIS",TRB->BASPIDENT,TRB->BASCODENT)
					nBasCred += IIF(TRB->TIPO == "PIS",TRB->BASPICENT,TRB->BASCOCENT)

					nGValDebi += IIF(TRB->TIPO == "PIS",TRB->PISDENT,TRB->COFDENT)
					nGValCred += IIF(TRB->TIPO == "PIS",TRB->PISCENT,TRB->COFCENT)
					nGBasDebi += IIF(TRB->TIPO == "PIS",TRB->BASPIDENT,TRB->BASCODENT)
					nGBasCred += IIF(TRB->TIPO == "PIS",TRB->BASPICENT,TRB->BASCOCENT)

					nPosAliq := Ascan(aAliqs,{|x| x[1]==TRB->ALIQ})
					If nPosAliq > 0
						aAliqs[nPosAliq][2] += IIF(TRB->TIPO == "PIS",TRB->PISDENT,TRB->COFDENT)-IIF(TRB->TIPO == "PIS",TRB->PISCENT,TRB->COFCENT)
						aAliqs[nPosAliq][3] += TRB->VALORCONT
						aAliqs[nPosAliq][4] += TRB->ZFRANCA
						aAliqs[nPosAliq][5] += IIF(TRB->TIPO == "PIS",TRB->PISDENT,TRB->COFDENT)
						aAliqs[nPosAliq][6] += IIF(TRB->TIPO == "PIS",TRB->PISCENT,TRB->COFCENT)
						aAliqs[nPosAliq][7] += IIF(TRB->TIPO == "PIS",TRB->BASPIDENT,TRB->BASCODENT)
						aAliqs[nPosAliq][8] += IIF(TRB->TIPO == "PIS",TRB->BASPICENT,TRB->BASCOCENT)
					Else
						AADD(aAliqs,{TRB->ALIQ,;
						IIF(TRB->TIPO == "PIS",TRB->PISDENT,TRB->COFDENT)-IIF(TRB->TIPO == "PIS",TRB->PISCENT,TRB->COFCENT),;
						TRB->VALORCONT,;
						TRB->ZFRANCA,;
						IIF(TRB->TIPO == "PIS",TRB->PISDENT,TRB->COFDENT),;
						IIF(TRB->TIPO == "PIS",TRB->PISCENT,TRB->COFCENT),;
						IIF(TRB->TIPO == "PIS",TRB->BASPIDENT,TRB->BASCODENT),;
						IIF(TRB->TIPO == "PIS",TRB->BASPICENT,TRB->BASCOCENT)})
					Endif
				Endif

				If mv_par04 == 1
					Li++
				Endif

				TRB->(dbSkip())

				If TRB->CFOP <> Substr(cQuebra,4,4)
					@Li, 001 Psay __PrtThinLine()
					Li++
					@Li, 001 PSAY "Total do CFOP - "+Substr(cQuebra,4,4)  //"Total do CFOP - "
					@Li, 030 PSAY nValCont Picture PesqPict("SD2","D2_TOTAL",14)
					@Li, 050 PSAY nZFranca Picture PesqPict("SD2","D2_DESCZFR",14)
					@Li, 083 PSAY nValDebi Picture PesqPict("SD2","D2_TOTAL",14)
					@Li, 107 PSAY nValCred Picture PesqPict("SD2","D2_TOTAL",14)
					@Li, 131 PSAY nBasDebi Picture PesqPict("SD2","D2_TOTAL",14)
					@Li, 155 PSAY nBasCred Picture PesqPict("SD2","D2_TOTAL",14)
					Li := Li + 2
				Endif

				If ( (Substr(TRB->CFOP,1,1) >= "5" .And. lEntrada) .Or. TRB->(Eof()) ) .Or. (!lEntrada .And. TRB->(Eof())) .Or. TRB->TIPO <> cTipo
					@Li, 001 Psay __PrtThinLine()
					Li++
					For nX := 1 To Len(aAliqs)
						If Li > 58
							Cabec(ctitulo,cabec1,cabec2,nomeprog,ctamanho,15)
						EndIf
						@Li, 001 PSAY "Total da Aliquota "+Transform(aAliqs[nX][1],"@E 99.99%") //"Total da Aliquota "
						@Li, 030 PSAY aAliqs[nX][3] Picture PesqPict("SD2","D2_TOTAL",14)
						@Li, 050 PSAY aAliqs[nX][4] Picture PesqPict("SD2","D2_DESCZFR",14)
						@Li, 083 PSAY aAliqs[nX][5] Picture PesqPict("SD2","D2_TOTAL",14)
						@Li, 107 PSAY aAliqs[nX][6] Picture PesqPict("SD2","D2_TOTAL",14)
						@Li, 131 PSAY aAliqs[nX][7] Picture PesqPict("SD2","D2_TOTAL",14)
						@Li, 155 PSAY aAliqs[nX][8] Picture PesqPict("SD2","D2_TOTAL",14)
						Li++
					Next
					Li++
					@Li, 001 PSAY "Total de "+IIF(lEntrada,"Entradas","Saidas") //"Total de " + "Entradas","Saidas"
					@Li, 030 PSAY nGValCont Picture PesqPict("SD2","D2_TOTAL",14)
					@Li, 050 PSAY nGZFranca Picture PesqPict("SD2","D2_DESCZFR",14)
					@Li, 083 PSAY nGValDebi Picture PesqPict("SD2","D2_TOTAL",14)
					@Li, 107 PSAY nGValCred Picture PesqPict("SD2","D2_TOTAL",14)
					@Li, 131 PSAY nGBasDebi Picture PesqPict("SD2","D2_TOTAL",14)
					@Li, 155 PSAY nGBasCred Picture PesqPict("SD2","D2_TOTAL",14)
					Li := Li + 3

					nValContri += nGValDebi-nGValCred
					If TRB->TIPO <> cTipo
						@Li, 001 Psay Repli("-",Limite)
						Li++
						@Li, 001 Psay "Contribuicao : "
						Li++
						Li++
						For nX := 1 To Len(aAliqs)
							If Li > 58
								Cabec(ctitulo,cabec1,cabec2,nomeprog,ctamanho,15)
							EndIf
							@Li, 001 PSAY "Aliquota : "+Transform(aAliqs[nX][1],"@E 99.99%")+"  "+"Valor : "+Transform(aAliqs[nX][2],PesqPict("SD2","D2_TOTAL",14)) //Aliquota :  //Valor :
							Li++
						Next
						Li++
						@Li, 001 PSAY "Valor da Contribuicao : "+Transform(nValContri,PesqPict("SD2","D2_TOTAL",14)) //"Valor da Contribuicao : "
						nValContri := 0
						aAliqs := {}
						Li++
					Else
						aAliqs := {}
					Endif

					lEntrada := .F.
					lQuebra  := .T.

					nGValCont := 0
					nGZFranca := 0
					nGValDebi := 0
					nGValCred := 0
					nGBasDebi := 0
					nGBasCred := 0
				Endif
			EndDo
			lResumo:= .T.
		EndDo
	EndIf

	cArqCp :=strzero(month(mv_par02),2)+substr(strzero(year(mv_par02),4),3,2)+SM0->M0_CODIGO+SM0->M0_CODFIL+".CP"
	If File(cArqCp)
		cTitulo := "Informacoes Complementares da Apuracao"
		cabec1  := " Descricao                                                                            Valores"
		cabec2  := ""
		cabec(ctitulo,cabec1,cabec2,nomeprog,ctamanho,15)

		cContArq	:=	MemoRead(cArqCp)
		For nContCp :=1 to MlCount(cContArq,100)
			cLinArq :=MemoLine(cContArq,100,nContCp)
			@Li, 001 PSAY Substr(cLinArq,01,70)
			@Li, 071 PSAY Val(Substr(cLinArq,71,14)) Picture PesqPict("SD2","D2_TOTAL",14)
			Li++
		Next
		lResumo:= .T.
	Endif

	If lResumo
		cTitulo := "Resumo"
		cabec1  := "Valores para Calculo              Tributado           Outros            Total"
		cabec2  := ""
		cabec(ctitulo,cabec1,cabec2,nomeprog,ctamanho,15)
		@Li,   001 PSAY "Saídas                   "+Transform(nVendTrib,PesqPict("SD2","D2_TOTAL",17))+Transform(nValVend,PesqPict("SD2","D2_TOTAL",17))+Transform(nVendTrib+nValVend,PesqPict("SD2","D2_TOTAL",17))  // "Saídas                   "
		@Li+1, 001 PSAY "Devoluções de Saídas     "+Transform(nDevCompT,PesqPict("SD2","D2_TOTAL",17))+Transform(nValDevComp,PesqPict("SD2","D2_TOTAL",17))+Transform(nDevCompT+nValDevComp,PesqPict("SD2","D2_TOTAL",17)) // "Devoluções de Saídas     "
		@Li+2, 001 PSAY "Entradas                 "+Transform(nCompTrib,PesqPict("SD2","D2_TOTAL",17))+Transform(nValComp,PesqPict("SD2","D2_TOTAL",17))+Transform(nCompTrib+nValComp,PesqPict("SD2","D2_TOTAL",17))// "Entradas                 "
		@Li+3, 001 PSAY "Devoluções de Entradas   "+Transform(nDevVendT,PesqPict("SD2","D2_TOTAL",17))+Transform(nValDevVend,PesqPict("SD2","D2_TOTAL",17))+Transform(nDevVendT+nValDevVend,PesqPict("SD2","D2_TOTAL",17)) // "Devoluções de Entradas   "
	EndIf


	Roda(cbcont,cbtxt,ctamanho)

	dbSelectArea("TRB")
	dbCloseArea()
	Ferase(cArqTemp+GetDBExtension())
	Ferase(cArqTemp+OrdBagExt())

	If aReturn[5] == 1
		Set Printer TO
		dbcommitAll()
		OurSpool(wnrel)
	Endif

	MS_FLUSH()

Return
/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Funcao    ³R906Imp   ³ Autor ³Gustavo G. Rueda       ³ Data ³05/01/2004³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³Rotina de impressao por nota fiscal.                        ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Retorno   ³Nenhum                                                      ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Static Function R906Imp (cArqTemp)
	Local	aLay[2]
	Local	cCabec1		:=	""
	Local	cCabec2		:=	""
	Local	cQuebra  	:= 	""
	Local	cTipo		:=	""
	Local	lFirst		:=	.F.
	Local	aImp		:=	{}
	Local 	aAliqs 	  	:= 	{}
	Local	Lin		:=	1
	Local	nContribC	:=	0
	Local	nContribD	:=	0
	Local	nContribBC	:=	0
	Local	nContribBD	:=	0
	Local	nValCont	:= 	0
	Local	nZFranca	:= 	0
	Local	nValDebi	:= 	0
	Local	nValCred	:= 	0
	Local	nBasDebi	:= 	0
	Local	nBasCred	:= 	0
	Local	nGValDebi 	:= 	0
	Local	nGValCred 	:= 	0
	Local	nPosAliq	:=	0
	Local 	lContinua  	:= .T.
	Local	nX			:=	1
	Local	cCfop		:=	""
	//
	cCabec1	:=	" Documento    Serie  Emissao   Produto          NCM         Valor Contabil      Zona Franca         Aliquota           Valor da Contribuicao                     Base da Contribuicao          "
	cCabec2	:=	"                                                                                                                    Credito              Debito               Credito             Debito       "
	aLay[1]	:=	"  ######      ###    ########  ###############  ##########  ##################  ##################  #####%    ##################  ##################    ##################  ################## "
	aLay[2]	:= "  ########################################################  ##################  ##################  #####%    ##################  ##################    ##################  ################## "
	Li		:=	99
	//
	IndRegua ("TRB", cArqTemp, "TIPO+ES+NUMNF+SERIE+DToS (EMISSAO)")
	//
	Do While !TRB->(Eof ()) .And. (lContinua)

		If (lEnd)
			@ Prow()+1,001 PSay "CANCELADO PELO OPERADOR"
			lContinua := .F.
			Exit
		Endif
		//
		IncRegua()
		//
		If (Li>58)
			cabec (ctitulo, cCabec1, cCabec2, nomeprog, ctamanho, 15)
		EndIf
		//
		If !(lFirst)
			@ Li, 001 Psay "Empresa : " + SM0->M0_NOMECOM //
			Li++
			@ Li, 001 Psay "CNPJ    : " + Transform(SM0->M0_CGC,"@R 99.999.999/9999-99")  //"CNPJ    : "
			Li++
			@ Li, 001 Psay "Periodo : " + Dtoc(mv_par02) + " - " + Dtoc(mv_par03) //"Periodo : "
			Li++
		Endif
		//
		If (TRB->TIPO<>cTipo) .Or. (TRB->ES<>cCfop)
			//
			If (lFirst)
				@ Li, 001 PSAY Repli ("-", Limite)
				Li++
				//
				For nX := 1 To Len (aALiqs)
					FmtLin ({"Total da Aliquota "+Transform(aAliqs[nX][1],"@E 99.99%"), Transform (aALiqs[nX][3], "@E 999,999,999,999.99"), Transform (aALiqs[nX][4], "@E 999,999,999,999.99"),;
					Transform (aALiqs[nX][5], "@E 999,999,999,999.99"), Transform (aALiqs[nX][6], "@E 999,999,999,999.99"),;
					Transform (aALiqs[nX][7], "@E 999,999,999,999.99"), Transform (aALiqs[nX][8], "@E 999,999,999,999.99")},aLay[2],,"@X",@Li)
				Next (nX)
				//
				@ Li, 001 PSAY Repli("-", Limite)
				Li++
				//
				FmtLin ({Iif (TRB->ES=="S", "Total de "+"Entradas", "Total de "+"Saidas"), Transform (nValCont, "@E 999,999,999,999.99"), Transform (nZFranca, "@E 999,999,999,999.99"),;
				Transform (nValDebi, "@E 999,999,999,999.99"), Transform (nValCred, "@E 999,999,999,999.99"),;
				Transform (nBasDebi, "@E 999,999,999,999.99"), Transform (nBasCred, "@E 999,999,999,999.99")}, aLay[2],,"@X",@Li)
				//
				If (TRB->TIPO<>cTipo)
					//
					@ Li, 001 Psay Repli("-",Limite)
					Li++
					@ Li, 001 Psay "Contribuicao : "
					Li	+=	2
					//
					For nX := 1 To Len (aAliqs)
						If (Li>58)
							Cabec (ctitulo, cCabec1, cCabec2, nomeprog, cTamanho, 15)
						EndIf
						//
						@ Li, 001 PSay "Aliquota : "+Transform (aAliqs[nX][1],"@E 99.99%")+"  "+"Valor : "+Transform (aAliqs[nX][2], PesqPict("SD2","D2_TOTAL",14)) //Aliquota :  //Valor :
						Li++
					Next
					Li++
					@Li, 001 PSAY "Valor da Contribuicao : "+Transform(nGValDebi-nGValCred, PesqPict("SD2","D2_TOTAL",14)) //"Valor da Contribuicao : "
					//
					nGValDebi 	:= 0
					nGValCred 	:= 0
				EndIf
				aAliqs	:=	{}
				//
				nValCont	:= 	0
				nZFranca 	:= 	0
				nValDebi	:= 	0
				nValCred 	:= 	0
				nBasDebi 	:= 	0
				nBasCred 	:=	0
			EndIf
			//
			If (TRB->TIPO<>cTipo) .And. lFirst
				Cabec (cTitulo, cCabec1, cCabec2, nomeprog, cTamanho, 15)
			EndIf
			//
			Li++
			@ Li, 001 PSay IIf (TRB->TIPO=="PIS", PadC ("PIS - Programa de Integracao Social"+ Iif (SubStr (TRB->CFOP, 1, 1)<"5", " - ENTRADAS", " - SAIDAS"), Limite),;
			PadC ("COFINS - Contribuicao para o Financiamento da Seguridade Social"+Iif (SubStr (TRB->CFOP, 1, 1)<"5", " - ENTRADAS", " - SAIDAS"), Limite))
			Li	+=	2
			cTipo 	:=	TRB->TIPO
			cCfop	:=	TRB->ES
			lFirst	:=	.T.
		Endif
		//
		If (MV_PAR04==1)
			If (SubStr (TRB->CFOP, 1, 1)>="5")
				nContribC	:=	Iif (TRB->TIPO=="PIS", TRB->PISDSAI, TRB->COFDSAI)
				nContribD	:=	Iif (TRB->TIPO=="PIS", TRB->PISCSAI, TRB->COFCSAI)
				nContribBC	:=	Iif (TRB->TIPO=="PIS", TRB->BASPIDSAI, TRB->BASCODSAI)
				nContribBD	:=	Iif (TRB->TIPO=="PIS", TRB->BASPICSAI, TRB->BASCOCSAI)
			Else
				nContribC	:=	Iif (TRB->TIPO=="PIS", TRB->PISDENT, TRB->COFDENT)
				nContribD	:=	Iif (TRB->TIPO=="PIS", TRB->PISCENT, TRB->COFCENT)
				nContribBC	:=	Iif (TRB->TIPO=="PIS", TRB->BASPIDENT, TRB->BASCODENT)
				nContribBD	:=	Iif (TRB->TIPO=="PIS", TRB->BASPICENT, TRB->BASCOCENT)
			Endif
			//
			aImp	:=	{TRB->NUMNF, TRB->SERIE, TRB->EMISSAO, TRB->PRODUTO, TRB->NCM, Transform (TRB->VALORCONT, "@E 999,999,999,999.99"),;
			Transform (TRB->ZFRANCA, "@E 999,999,999,999.99"), 	Transform(TRB->ALIQ,"@E 99.99%"), Transform (nContribC, "@E 999,999,999,999.99"),;
			Transform (nContribD, "@E 999,999,999,999.99"), Transform (nContribBC, "@E 999,999,999,999.99"), Transform (nContribBD, "@E 999,999,999,999.99")}
			//
			FmtLin (aImp, aLay[1],,, @Li)
		Endif
		//
		nValCont	+= 	TRB->VALORCONT
		nZFranca 	+= 	TRB->ZFRANCA
		//
		If (SubStr (TRB->CFOP, 1, 1)>="5")
			nValDebi	+= 	Iif (TRB->TIPO=="PIS", TRB->PISDSAI, TRB->COFDSAI)
			nValCred 	+= 	Iif (TRB->TIPO=="PIS", TRB->PISCSAI, TRB->COFCSAI)
			nBasDebi 	+= 	Iif (TRB->TIPO=="PIS", TRB->BASPIDSAI, TRB->BASCODSAI)
			nBasCred 	+=	Iif (TRB->TIPO=="PIS", TRB->BASPICSAI, TRB->BASCOCSAI)
			nGValDebi 	+= 	Iif (TRB->TIPO=="PIS", TRB->PISDSAI, TRB->COFDSAI)
			nGValCred 	+= 	Iif (TRB->TIPO=="PIS", TRB->PISCSAI, TRB->COFCSAI)
			//
			nPosAliq	:=	Ascan(aAliqs,{|x| x[1]==TRB->ALIQ})
			If (nPosAliq>0)
				aAliqs[nPosAliq][2] += IIF(TRB->TIPO == "PIS",TRB->PISDSAI,TRB->COFDSAI)-IIF(TRB->TIPO == "PIS",TRB->PISCSAI,TRB->COFCSAI)
				aAliqs[nPosAliq][3] += TRB->VALORCONT
				aAliqs[nPosAliq][4] += TRB->ZFRANCA
				aAliqs[nPosAliq][5] += IIF(TRB->TIPO == "PIS",TRB->PISDSAI,TRB->COFDSAI)
				aAliqs[nPosAliq][6] += IIF(TRB->TIPO == "PIS",TRB->PISCSAI,TRB->COFCSAI)
				aAliqs[nPosAliq][7] += IIF(TRB->TIPO == "PIS",TRB->BASPIDSAI,TRB->BASCODSAI)
				aAliqs[nPosAliq][8] += IIF(TRB->TIPO == "PIS",TRB->BASPICSAI,TRB->BASCOCSAI)
			Else
				aAdd (aAliqs, {TRB->ALIQ,;
				Iif (TRB->TIPO=="PIS", TRB->PISDSAI, TRB->COFDSAI)-Iif (TRB->TIPO=="PIS", TRB->PISCSAI, TRB->COFCSAI),;
				TRB->VALORCONT, TRB->ZFRANCA,;
				Iif (TRB->TIPO=="PIS", TRB->PISDSAI, TRB->COFDSAI),;
				Iif (TRB->TIPO == "PIS",TRB->PISCSAI,TRB->COFCSAI),;
				Iif (TRB->TIPO=="PIS", TRB->BASPIDSAI, TRB->BASCODSAI),;
				Iif (TRB->TIPO == "PIS",TRB->BASPICSAI,TRB->BASCOCSAI)})
			Endif
		Else
			nValDebi 	+=	Iif (TRB->TIPO=="PIS", TRB->PISDENT, TRB->COFDENT)
			nValCred 	+= 	Iif (TRB->TIPO=="PIS", TRB->PISCENT, TRB->COFCENT)
			nBasDebi 	+= 	Iif (TRB->TIPO=="PIS", TRB->BASPIDENT, TRB->BASCODENT)
			nBasCred 	+= 	Iif (TRB->TIPO=="PIS", TRB->BASPICENT, TRB->BASCOCENT)
			nGValDebi	+= 	Iif (TRB->TIPO=="PIS", TRB->PISDENT, TRB->COFDENT)
			nGValCred	+= 	Iif (TRB->TIPO=="PIS", TRB->PISCENT, TRB->COFCENT)
			//
			nPosAliq	:=	Ascan(aAliqs,{|x| x[1]==TRB->ALIQ})
			If (nPosAliq>0)
				aAliqs[nPosAliq][2]		+= 	Iif (TRB->TIPO=="PIS", TRB->PISDENT, TRB->COFDENT)-Iif (TRB->TIPO=="PIS", TRB->PISCENT, TRB->COFCENT)
				aAliqs[nPosAliq][3] 	+= 	TRB->VALORCONT
				aAliqs[nPosAliq][4] 	+= 	TRB->ZFRANCA
				aAliqs[nPosAliq][5] 	+= 	Iif (TRB->TIPO=="PIS", TRB->PISDENT, TRB->COFDENT)
				aAliqs[nPosAliq][6] 	+= 	Iif (TRB->TIPO=="PIS", TRB->PISCENT, TRB->COFCENT)
				aAliqs[nPosAliq][7] 	+= 	Iif (TRB->TIPO=="PIS", TRB->BASPIDENT, TRB->BASCODENT)
				aAliqs[nPosAliq][8] 	+=	Iif (TRB->TIPO=="PIS", TRB->BASPICENT, TRB->BASCOCENT)
			Else
				aAdd (aAliqs, {TRB->ALIQ,;
				Iif (TRB->TIPO=="PIS", TRB->PISDENT, TRB->COFDENT)-Iif (TRB->TIPO=="PIS", TRB->PISCENT, TRB->COFCENT),;
				TRB->VALORCONT,;
				TRB->ZFRANCA,;
				Iif (TRB->TIPO=="PIS", TRB->PISDENT, TRB->COFDENT),;
				Iif (TRB->TIPO=="PIS", TRB->PISCENT, TRB->COFCENT),;
				Iif (TRB->TIPO=="PIS", TRB->BASPIDENT, TRB->BASCODENT),;
				Iif (TRB->TIPO=="PIS", TRB->BASPICENT, TRB->BASCOCENT)})
			Endif
		Endif
		TRB->(DbSkip ())
	EndDo
	//
	@ Li, 001 PSAY Repli("-", Limite)
	Li++
	//
	For nX := 1 To Len (aALiqs)
		FmtLin ({"Total da Aliquota "+Transform (aAliqs[nX][1],"@E 99.99%"), Transform (aALiqs[nX][3], "@E 999,999,999,999.99"), Transform (aALiqs[nX][4], "@E 999,999,999,999.99"),;
		Transform (aALiqs[nX][5], "@E 999,999,999,999.99"), Transform (aALiqs[nX][6], "@E 999,999,999,999.99"),;
		Transform (aALiqs[nX][7], "@E 999,999,999,999.99"), Transform (aALiqs[nX][8], "@E 999,999,999,999.99")},aLay[2],,"@X",@Li)
	Next (nX)
	//
	@ Li, 001 PSAY Repli("-", Limite)
	Li++
	//
	FmtLin ({Iif (TRB->ES=="S","Total de "+"Entradas", "Total de "+"Saidas"), Transform (nValCont, "@E 999,999,999,999.99"), Transform (nZFranca, "@E 999,999,999,999.99"),;
	Transform (nValDebi, "@E 999,999,999,999.99"), Transform (nValCred, "@E 999,999,999,999.99"),;
	Transform (nBasDebi, "@E 999,999,999,999.99"), Transform (nBasCred, "@E 999,999,999,999.99")}, aLay[2],,"@X",@Li)
	//
	@ Li, 001 Psay Repli("-",Limite)
	Li++
	@ Li, 001 Psay "Contribuicao : "
	Li	+=	2
	//
	For nX := 1 To Len (aAliqs)
		If (Li>58)
			Cabec (ctitulo, cCabec1, cCabec2, nomeprog, cTamanho, 15)
		EndIf
		@ Li, 001 PSay "Aliquota : "+Transform (aAliqs[nX][1],"@E 99.99%")+"  "+"Valor : "+Transform(aAliqs[nX][2],PesqPict("SD2","D2_TOTAL",14)) //Aliquota :  //Valor :
		Li++
	Next
	Li++
	@Li, 001 PSAY "Total da Contribuicao....: "+Transform(nGValDebi-nGValCred, PesqPict("SD2","D2_TOTAL",14)) //"Valor da Contribuicao : "
Return (.T.)
