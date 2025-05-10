#INCLUDE "PROTHEUS.CH"
#INCLUDE "RWMAKE.CH"
#INCLUDE "TOPCONN.CH"                           

/*/{Protheus.doc} STI_R500
RelatСrio de TF liberados desconsiderando empenhos.
@author 	Evandro Mugnol
@since 		Set/2018
@return 	Nil, FunГЦo nЦo tem retorno
@obs 		N/A
/*/

User Function STI_R501()

	//здддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
	//Ё Variaveis obrigatorias dos programas de relatorio            Ё
	//юдддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды
	cString  := "SZ8"
	cDesc1   := "Este programa tem como objetivo, Imprimir o relatСrio de "
	cDesc2   := "TF liberados desconsiderando empenhos.                   "
	cDesc3   := ""
	tamanho  := "M"
	aReturn  := {"Zebrado", 1,"Administracao", 1, 2, 1, "",1}
	aLinha   := {}
	nLastKey := 0
	cPerg    := "STI_R501"
	titulo   := "RelaГЦo de TF Liberados"
	wnrel    := "STI_R501"
	nTipo    := 0

	//здддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
	//Ё Perguntas no Arquivo SX1                                     Ё
	//юдддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды
	Pergunte(cPerg,.F.)


	//здддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
	//Ё VariАveis utilizadas para gerar em Excel                     Ё
	//юдддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды
	_cNomArq := "TF_LIBERADOS_" + SUBSTR(dtos(mv_par01),1,4) + "-" + SUBSTR(dtos(mv_par01),5,2) + "-" + SUBSTR(dtos(mv_par01),7,2)
	_aCabec	 := {}
	_aDados	 := {}

	//здддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
	//Ё Envia controle para a funcao SETPRINT                        Ё
	//юдддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды
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

	//зддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
	//Ё Inicializa regua de impressao                             Ё
	//юддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды
	SetRegua(LastRec())

	//зддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
	//Ё Inicializa os codigos de caracter Comprimido/Normal da impressora Ё
	//юддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды
	nTipo := IIF(aReturn[4]==1,15,18)
	nLin  := 80
	m_pag := 1

	//здддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
	//Ё Cria o cabecalho.                                        Ё
	//юдддддддддддддддддддддддддддддддддддддддддддддддддддддддддды
	cabec1 := "                                        TABELA DE CONGELADOS                                                    "
	cabec2 := "CODIGO          P R O D U T O                                                   CAIXAS         PESO       PREгOS"
	//***      XXXXXXXXXXXXXXX X-----------------------------------------------------------X  XXX.XXX   XXX.XXX,XX   XXX.XXX,XX
	//***                1         2         3         4         5         6         7         8         9        10        11  
	//***      01234567890123456789012345678901234567890123456789012345678901234567890123456789012345678901234567890123456789012

	/*
	//здддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
	//Ё SeleГЦo de dados via F10 nos prИ-pedidos                 Ё
	//юдддддддддддддддддддддддддддддддддддддддддддддддддддддддддды
	cQuery1 := " SELECT Z8_COD AS COD, SUM (Z8_PESO) AS PESO, COUNT(*) AS QTDCXS" 
	cQuery1 += "   FROM " + RetSqlTab("SZ8") 
	cQuery1 += "  WHERE " + RetSqlFil("SZ8") 
	cQuery1 += "    AND Z8_FIL = '" + cFilAnt + "'"
	cQuery1 += "    AND Z8_DATAE = ' '"
	cQuery1 += "    AND Z8_DATAS = ' '"
	cQuery1 += "    AND Z8_DATAP <= '" + dtos(mv_par01 - 13) + "'"
	cQuery1 += "    AND Z8_TF = 'S'"
	cQuery1 += "    AND " + RetSqlDel("SZ8")
	cQuery1 += "  GROUP BY Z8_COD"
	cQuery1 += " HAVING COUNT (Z8_COD) >= 1"
	cQuery1 += "  ORDER BY Z8_COD"
	*/

	//здддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
	//Ё SeleГЦo de dados via F12 nos prИ-pedidos                 Ё
	//юдддддддддддддддддддддддддддддддддддддддддддддддддддддддддды
	_dtIni := ctod("01/01/2000")
	_dtFim := mv_par01 - 13

	cQuery1 := " SELECT Z8_COD AS COD, SUM (Z8_PESO) AS PESO, COUNT(*) AS QTDCXS" 
	cQuery1 += "   FROM " + RetSqlTab("SZ8") 
	cQuery1 += "  WHERE " + RetSqlFil("SZ8") 
	cQuery1 += "    AND Z8_FIL = '" + cFilAnt + "'"
	cQuery1 += "    AND Z8_DATAS = ' '"
	cQuery1 += "    AND Z8_HORAS = ' '"
	cQuery1 += "    AND Z8_PREPED = ' '"
	cQuery1 += "    AND Z8_PRECAR = ' '"
	cQuery1 += "    AND Z8_ITEM = ' '"
	cQuery1 += "    AND (SZ8.Z8_DATAP BETWEEN '" + dtos(_dtIni) + "' AND '" + dtos(_dtFim)+"')"
	cQuery1 += "    AND Z8_TF = 'S'"
	cQuery1 += "    AND " + RetSqlDel("SZ8")
	cQuery1 += "  GROUP BY Z8_COD"
	cQuery1 += " HAVING COUNT (Z8_COD) >= 1"
	cQuery1 += "  ORDER BY Z8_COD"

	cQuery1 := ChangeQuery(cQuery1)

	//memowrite("ZZZ_STI_R501.TXT",cQuery1)

	If Select("TRB1") != 0
		TRB1 -> (DbCloseArea())
	Endif

	TCQUERY cQuery1 NEW ALIAS "TRB1"

	//здддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
	//Ё ImpressЦo dos Dados                                      Ё
	//юдддддддддддддддддддддддддддддддддддддддддддддддддддддддддды
	_nTotCxs  := 0
	_nTotPeso := 0

	DbSelectArea("TRB1")
	DbGoTop()
	SetRegua(RecCount())
	Do While ! TRB1 -> (Eof ())
		IncRegua()

		pre  	:= "ZZZZZZ"
		prod 	:= TRB1->COD
		estTFcx := TRB1->QTDCXS
		estTFps := TRB1->PESO

		If nLin > 75
			Cabec(titulo,Cabec1,Cabec2,wnrel,tamanho,nTipo)
			nLin := 9
		Endif 

		// Query para trazer o que jА estА empenhado em prИ-pedidos relativo ao produto
		cQuery3 := "SELECT SUM(ZZ5_QPCAIX) AS QPCAIX, SUM(ZZ5_QRCAIX) AS QRCAIX, ZZ4_DATA AS DTEMP, "
		cQuery3 += " SUM(ZZ5_QPPESO) AS QPPESO, SUM(ZZ5_QRPESO) AS QRPESO
		cQuery3 += "  FROM " + RetSqlTab("ZZ5") + "," + RetSqlTab("ZZ4")
		cQuery3 += " WHERE " + RetSqlFil('ZZ5') + " AND " + RetSqlFil('ZZ4')
		cQuery3 += "   AND ZZ5_STATUS <> 'E'
		cQuery3 += "   AND ZZ4_NUM = ZZ5_NUM "
		cQuery3 += "   AND (ZZ4_STATUS <> 'E'"
		cQuery3 += "   AND ZZ4_STATUS <> 'P'"
		cQuery3 += "   AND ZZ4_STATUS <> 'F')"
		cQuery3 += "   AND ZZ4_TPOPER <> 'C'"
		cQuery3 += "   AND ZZ4_DATA = '" + dtos(mv_par01) + "'"
		cQuery3 += "   AND ZZ4_NUM <> '" + pre + "'"
		cQuery3 += "   AND ZZ5_COD = '" + prod + "'"
		cQuery3 += "   AND " + RetSqlDel("ZZ4")
		cQuery3 += "   AND " + RetSqlDel("ZZ5")
		cQuery3 += " GROUP BY ZZ4_DATA"

		cQuery3 := ChangeQuery(cQuery3)

		If Select("QRY3")<>0
			QRY3->(DbCloseArea())
		Endif

		TCQUERY cQuery3 NEW ALIAS "QRY3"

		empC  := 0
		empP  := 0
		_demp := Date()
		If (QRY3->QRCAIX < QRY3->QPCAIX) .Or. (QRY3->QRPESO < QRY3->QPPESO)
			empC  := QRY3->(QPCAIX - QRCAIX)
			empP  := QRY3->(QPPESO - QRPESO)
			_demp := stod(QRY3->DTEMP)
		Endif

		QRY3->(DbCloseArea())


		// Query para trazer o que jА estА empenhado em prИ-pedidos relativo ao produto do dia anterior
		cQuery5 := "SELECT SUM(ZZ5_QPCAIX) AS QPCAIX, SUM(ZZ5_QRCAIX) AS QRCAIX,
		cQuery5 += " SUM(ZZ5_QPPESO) AS QPPESO, SUM(ZZ5_QRPESO) AS QRPESO
		cQuery5 += "  FROM " + RetSqlTab("ZZ5") + "," + RetSqlTab("ZZ4")
		cQuery5 += " WHERE " + RetSqlFil('ZZ5') + " AND " + RetSqlFil('ZZ4')
		cQuery5 += "   AND ZZ5_STATUS <> 'E'
		cQuery5 += "   AND ZZ4_NUM = ZZ5.ZZ5_NUM "
		cQuery5 += "   AND (ZZ4_STATUS <> 'E'"
		cQuery5 += "   AND ZZ4_STATUS <> 'P'"
		cQuery5 += "   AND ZZ4_STATUS <> 'F')"
		cQuery5 += "   AND ZZ4_TPOPER <> 'C'"
		cQuery5 += "   AND ZZ4_DATA = '" + dtos(mv_par01 - 1) + "'"
		cQuery5 += "   AND ZZ4_NUM <> '" + pre + "'"
		cQuery5 += "   AND ZZ5_COD = '" + prod + "'"
		cQuery5 += "   AND " + RetSqlDel("ZZ4")
		cQuery5 += "   AND " + RetSqlDel("ZZ5")

		cQuery5 := ChangeQuery(cQuery5)

		If Select("QRY5")<>0
			QRY5->(DbCloseArea())
		Endif

		TCQUERY cQuery5 NEW ALIAS "QRY5"

		empantC := 0
		empantP := 0
		If (QRY5->QRCAIX < QRY5->QPCAIX) .Or. (QRY5->QRPESO < QRY5->QPPESO)
			empantC := QRY5->(QPCAIX - QRCAIX)
			empantP := QRY5->(QPPESO - QRPESO)
		Endif

		QRY5->(DbCloseArea())


		QTDc := 0
		QTDp := 0
		DbSelectArea('ZZ5')
		qCpc := fBuscaCPO('ZZ5', 2, xFilial('ZZ5') + pre + prod, 'ZZ5_QRCAIX')
		qCpp := fBuscaCPO('ZZ5', 2, xFilial('ZZ5') + pre + prod, 'ZZ5_QRCAIX')
		QTDc := iif((QTDc - qCpc) < 0, 0, (QTDc - qCpc))
		QTDp := iif((QTDp - qCpp) < 0, 0, (QTDp - qCpp))

		If  _demp == date()
			saldoC := estTFcx - (empC + empantC + QTDc)
			saldoP := estTFps - (empP + empantP + QTDp)
		Else
			saldoC := estTFcx - empC + empantC
			saldoP := estTFps - empP + empantP
		Endif

		_nPrcTab := fBuscaCpo("DA1", 1, xFilial("DA1") + "001" + TRB1->COD, "DA1_PRCVEN")

		@ nLin, 000 PSAY TRB1->COD
		@ nLin, 016 PSAY Left(fBuscaCPO('SB1', 1, xFilial('SB1') + TRB1->COD, 'B1_DESC'),60)
		@ nLin, 079 PSAY Transform(saldoC, '@E 999,999')
		@ nLin, 089 PSAY Transform(saldoP, '@E 999,999.99')
		@ nLin, 102 PSAY Transform(_nPrcTab, '@E 999,999.99')
		nLin++ 

		_nTotCxs  += saldoC
		_nTotPeso += saldoP

		If mv_par02 == 1	// Gera e mostra no Excel
			AADD(_aDados, { TRB1->COD															,;
			Left(fBuscaCPO('SB1', 1, xFilial('SB1') + TRB1->COD, 'B1_DESC'),60)	,;
			saldoC																,;
			saldoP																,;
			_nPrcTab															})
		Endif

		TRB1->(dbSkip())	 // Avanca o ponteiro do registro no arquivo 
	EndDo

	TRB1 -> (DbCloseArea())

	If nLin > 75
		Cabec(titulo,Cabec1,Cabec2,wnrel,tamanho,nTipo)
		nLin := 9
	Endif 

	@ nLin, 079 PSAY "====================="
	nLin++
	@ nLin, 050 PSAY "T O T A L  ==> "
	@ nLin, 079 PSAY Transform(_nTotCxs,'@E 999,999')
	@ nLin, 089 PSAY Transform(_nTotPeso,'@E 999,999.99')

	If mv_par02 == 1	// Gera e mostra no Excel
		AADD(_aDados, { ""         			,;
		"T O T A L  ==> " 	,;
		_nTotCxs			,;
		_nTotPeso			,;
		0       			})
	Endif

	Set Device To Screen

	If Len(_aDados) > 0
		AADD( _aCabec, {"CODIGO",	"C", 02, 0} )
		AADD( _aCabec, {"PRODUTO",	"C", 10, 0} )
		AADD( _aCabec, {"CAIXAS",	"N", 09, 0} )
		AADD( _aCabec, {"PESO",		"N", 12, 2} )
		AADD( _aCabec, {"PRECOS",	"N", 12, 2} )
		U_GERAEXCEL(_cNomArq, _aDados, _aCabec, .T.)
	Endif

	If aReturn[5]==1
		Set Printer TO
		dbcommitAll()
		ourspool(wnrel)
	Endif

	MS_FLUSH()   // Libera fila de relatorios em spool (Tipo Rede Netware)

Return
