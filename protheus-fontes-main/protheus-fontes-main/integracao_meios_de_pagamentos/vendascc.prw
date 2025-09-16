#INCLUDE "TOTVS.CH"
#INCLUDE "TOPCONN.CH"                           

/*/{Protheus.doc} VENDASCC
Relatório de vendas efetuadas para recebimento com cartão de crédito.
@author 	Evandro Mugnol
@since 		Dez/2020
@return 	Nil, Função não tem retorno
@obs 		N/A
/*/

User Function VENDASCC()

	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Variaveis obrigatorias dos programas de relatorio            ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	cString  := "SF2"
	cDesc1   := "Este programa tem como objetivo, imprimir o relatório de"
	cDesc2   := "vendas efetuadas para recebimento com cartão de crédito."
	cDesc3   := ""
	tamanho  := "G"
	aReturn  := {"Zebrado", 1,"Administracao", 1, 2, 1, "",1}
	aLinha   := {}
	nLastKey := 0
	cPerg    := "VENDASCC"
	titulo   := "Vendas Cartão Crédito"
	wnrel    := "VENDASCC"
	nTipo    := 0

	Private aDadosSM0:= FWSM0Util():GetSM0Data( cEmpAnt, cFilAnt , { "M0_CODFIL"} ) 

	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Perguntas no Arquivo SX1                                     ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	Pergunte(cPerg,.F.)

	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Envia controle para a funcao SETPRINT                        ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	wnrel:=SetPrint(cString,wnrel,cPerg,titulo,cDesc1,cDesc2,cDesc3,.F.)

	If nLastKey == 27
		Return
	Endif
	SetDefault(aReturn,cString)
	If nLastKey == 27
		Return
	Endif

	RptStatus({|| RptDetail()})

Return


Static Function RptDetail()

	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Inicializa regua de impressao                             ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	SetRegua(LastRec())

	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Inicializa os codigos de caracter Comprimido/Normal da impressora ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	nTipo  := IIF(aReturn[4]==1,15,18)
	nLin   := 80
	m_pag  := 1
	titulo += " - emissão de" + Dtoc(MV_PAR01) + " até " + Dtoc(MV_PAR02)

	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Cria o cabecalho.                                        ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	cabec1 := "                                                                                  VALOR                       VALOR                                                                                                 "
	cabec2 := "NFISCAL/SERIE EMISSAO    C  L  I  E  N  T  E                                    NFISCAL PRF TITULO   PARC    TITULO INTEGRADORA     CHECKOUT ID                               STATUS COBRANÇA                       "
	//***      XXXXXXXXX XX  XX/XX/XXXX XXXXXX-XX X--------------------------------------X  999.999,99 XXX XXXXXXXXX XX 999.999,99 X-------------X XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX X------------------------------------X
	//***                1         2         3         4         5         6         7         8         9        10        11        12        13        14        15        16        17        18        19        20        21
	//***      012345678901234567890123456789012345678901234567890123456789012345678901234567890123456789012345678901234567890123456789012345678901234567890123456789012345678901234567890123456789012345678901234567890123456789012

	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Seleção das notas faturadas como cartão de crédito       ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	_cQuery := "SELECT F2_DOC, F2_SERIE, F2_CLIENTE, F2_LOJA, F2_VALBRUT, F2_EMISSAO "
	_cQuery += "  FROM " + RetSQLTab("SF2")
	_cQuery += " WHERE	" + RetSQLFil("SF2")
	_cQuery += "   AND F2_EMISSAO BETWEEN '" + DTOS(mv_par01) + "' AND '" + DTOS(mv_par02) + "'"
	_cQuery += "   AND F2_DOC BETWEEN '" + mv_par03 + "' AND '" + mv_par04 + "'"
	_cQuery += "   AND F2_SERIE BETWEEN '" + mv_par05 + "' AND '" + mv_par06 + "'"
	_cQuery += "   AND F2_FRMREC = '5'"					// Somente Forma de Recebimento igual a Cartão de Crédito
	_cQuery += "   AND " + RetSQLDel("SF2")
	_cQuery += " ORDER BY F2_DOC, F2_SERIE "

	_cQuery := ChangeQuery(_cQuery)

	If Select("TRB1") != 0
		TRB1 -> (DbCloseArea())
	Endif

	TCQUERY _cQuery NEW ALIAS "TRB1"

	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Impressão dos Dados                                      ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	DbSelectArea("TRB1")
	DbGoTop()
	SetRegua(RecCount())
	Do While ! TRB1 -> (Eof ())
		IncRegua()

		If nLin > 65
			Cabec(titulo,Cabec1,Cabec2,wnrel,tamanho,nTipo)
			nLin := 9
		Endif 

		@ nLin, 000 PSAY TRB1->F2_DOC
		@ nLin, 010 PSAY TRB1->F2_SERIE
		@ nLin, 014 PSAY DTOC(STOD(TRB1->F2_EMISSAO))
		@ nLin, 025 PSAY TRB1->F2_CLIENTE + "-" + TRB1->F2_LOJA + " " + fBuscaCpo("SA1", 1, xFilial("SA1") + TRB1->F2_CLIENTE + TRB1->F2_LOJA, "A1_NOME")
		@ nLin, 077 PSAY Transform(TRB1->F2_VALBRUT, '@E 999,999.99')

		_TemE1 := .F.
		SE1->(DbSetOrder(1))
		SE1->(MsSeek(xFilial("SE1") + Left(aDadosSM0[1][2],3) + TRB1->F2_DOC, .T.))		// Busca dados do SM0, pois grava prefixo do título com filial de origem
		While !SE1->(Eof()) .And. SE1->E1_FILIAL + SE1->E1_PREFIXO + SE1->E1_NUM == xFilial("SE1") + Left(aDadosSM0[1][2],3) + TRB1->F2_DOC
			// Verifica o cliente
			If (SE1->E1_CLIENTE + SE1->E1_LOJA <> TRB1->F2_CLIENTE + TRB1->F2_LOJA)
				SE1->(DbSkip())
				Loop
			Endif

			If nLin > 65
				Cabec(titulo,Cabec1,Cabec2,wnrel,tamanho,nTipo)
				nLin := 9
			Endif 

			@ nLin, 088 PSAY SE1->E1_PREFIXO
			@ nLin, 092 PSAY SE1->E1_NUM
			@ nLin, 102 PSAY SE1->E1_PARCELA
			@ nLin, 105 PSAY Transform(SE1->E1_VALOR, '@E 999,999.99')
			@ nLin, 116 PSAY Left(fBuscaCpo("ZK0", 1, xFilial("ZK0") + SE1->E1_INTEGRA, "ZK0_NOMINT"), 15)
			@ nLin, 132 PSAY SE1->E1_CHKID
			@ nLin, 174 PSAY Left(SE1->E1_STATRET, 38)
			nLin++ 
			_TemE1 := .T.

			SE1->(DbSkip())
		EndDo

		If !_TemE1
			nLin++
		EndIf 

		TRB1->(dbSkip())	 // Avanca o ponteiro do registro no arquivo 
	EndDo

	TRB1 -> (DbCloseArea())

	/*
	If nLin > 65
		Cabec(titulo,Cabec1,Cabec2,wnrel,tamanho,nTipo)
		nLin := 9
	Endif 

	@ nLin, 060 PSAY "====================="
	nLin++
	@ nLin, 040 PSAY "T O T A L  ==> "
	@ nLin, 061 PSAY Transform(_nTotPeso,'@E 999,999.99')
	@ nLin, 074 PSAY Transform(_nTotCxs,'@E 999,999')
	*/

	Set Device To Screen

	If aReturn[5]==1
		Set Printer TO
		dbcommitAll()
		ourspool(wnrel)
	Endif

	MS_FLUSH()   // Libera fila de relatorios em spool (Tipo Rede Netware)
Return
