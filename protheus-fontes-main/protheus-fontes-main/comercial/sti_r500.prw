#INCLUDE "PROTHEUS.CH"
#INCLUDE "RWMAKE.CH"
#INCLUDE "TOPCONN.CH"                           

/*/{Protheus.doc} STI_R500
Relatório de caixas velhas descosiderando empenhos.
@author 	Evandro Mugnol
@since 		Ago/2018
@return 	Nil, Função não tem retorno
@obs 		N/A
/*/

User Function STI_R500()

	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Variaveis obrigatorias dos programas de relatorio            ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	Private cString := "SZ8"
	Private cDesc1  := "Este programa tem como objetivo, Imprimir o relatório de "
	Private cDesc2  := "caixas velhas desconsiderando empenhos dos pré-pedidos.  "
	Private cDesc3  := ""
	Private tamanho := "G"
	Private aReturn := {"Zebrado", 1,"Administracao", 1, 2, 1, "",1}
	Private aLinha  := {}
	Private nLastKey:= 0
	Private nomeprog:= "STI_R500" // Coloque aqui o nome do programa para impressao no cabecalho
	Private cPerg   := "STI_R500"
	Private titulo  := "Caixas Velhas - Empenhos"
	Private wnrel   := "STI_R500"
	Private nTipo   := 0
	Private _aAux 	:= {}
	Private _aDados := {}
	Private _aCabec	:= {}

	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Perguntas no Arquivo SX1                                     ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	Pergunte(cPerg,.F.)

	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Envia controle para a funcao SETPRINT                        ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	wnrel:=SetPrint(cString,nomeprog,cPerg,titulo,cDesc1,cDesc2,cDesc3,.F.)

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
	//SetRegua(LastRec())

	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Inicializa os codigos de caracter Comprimido/Normal da impressora ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	Local i := 0
	nTipo := IIF(aReturn[4]==1,15,18)
	nLin  := 80
	m_pag := 1

	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Cria o cabecalho.                                        ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	cabec1 := "DESOSSADA                                                      CODIGO          CAIXAS     PRODUCAO     VALIDADE        PESO       --------------- E M P E N H O S ----------------"
	cabec2 := "                                                                                                                                  CAIXAS          PESO    PROD. INIC   PROD. FINAL"
	//***      X-----------------------------------------------------------X  XXXXXXXXXXXXXXX  X.XXX     XX/XX/XX     XX/XX/XX  XXX.XXX,XX        X.XXX    XXX.XXX,XX     XX/XX/XX      XX/XX/XX
	//***                1         2         3         4         5         6         7         8         9        10        11        12        13        14        15        16        17        18

	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Seleção de dados                                         ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	DO CASE
		CASE mv_par03 = 1
		_Farm := 'C'
		CASE mv_par03 = 2
		_Farm := 'R'
		CASE mv_par03 = 3
		_Farm := 'S'
		OTHERWISE
		_Farm := 'T'
	ENDCASE

	cQuery1 := "SELECT Z8_COD AS COD, Z8_DATAVAL AS DATAVAL, Z8_DATAP AS DATAP, SUM(Z8_PESO) AS PESO, B1_DESC AS DESCR,"
	cQuery1 += " COUNT(Z8_COD) AS QTDCXS, (CASE WHEN Z8_DATAVAL <= '" + DTOS(mv_par13) + "' THEN '1VERMELHO' ELSE '2AMARELO' END) AS STATVENC"
	cQuery1 += " FROM " + RetSqlTab("SZ8")
	cQuery1 += " INNER JOIN " + RetSqlTab("SB1") + "ON (SZ8.Z8_COD = SB1.B1_COD)"
	cQuery1 += " INNER JOIN " + RetSqlTab("SBM") + "ON (SB1.B1_GRUPO = SBM.BM_GRUPO)"
	cQuery1 += " WHERE " + RetSqlFil("SZ8") + " AND " + RetSqlFil("SBM")  + " AND " + RetSqlFil("SB1") + " AND"
	cQuery1 += " B1_TIPO IN('PR','PA') AND"
	cQuery1 += " Z8_FIL = '" + cFilAnt + "' AND"
	cQuery1 += " Z8_TERC = '' AND Z8_ENCONTR <> 'N' AND"
	cQuery1 += " (Z8_DATAVAL BETWEEN '" + DTOS(mv_par01) + "' AND '" + DTOS(mv_par02) + "') AND"
	cQuery1 += " (Z8_DATAP BETWEEN '" + DTOS(mv_par07) + "' AND '" + DTOS(mv_par08) + "') AND"

	if mv_par14 = 1
		cQuery1 += " Z8_DATAS = '' AND"// Z8_AUTOPED = '' AND"
	endif

	If _Farm != 'T'
		cQuery1 += " BM_FARM = '" + _Farm + "' AND"
	Endif

	/*If !Empty(mv_par04)
	cQuery1 += " B1_FAM = '" + mv_par04 + "' AND"
	Endif
	*/

	If !Empty(mv_par05)
		cQuery1 += " B1_COD = '" + mv_par05 + "' AND"
	Endif

	/*
	If !Empty(mv_par06)
	cQuery1 += " Z8_LOCAL = '" + mv_par06 + "' AND"
	Endif
	*/

	If mv_par10 = 1		// com endereçamento
		cQuery1 += " Z8_LOCAL <> '' AND Z8_LOCALIZ <> '' AND"
	ElseIf mv_par10 = 2	// sem endereçamento
		cQuery1 += " Z8_LOCAL = '' AND Z8_LOCALIZ = '' AND"
	Endif

	If mv_par12 = 1		// filtra porcionados
		cQuery1 += " Z8_LOTEPOR = '' AND"
	ElseIf mv_par12 = 2		// filtra desossa
		cQuery1 += " Z8_LOTEPOR <> '' AND"
	Endif

	cQuery1 += RetSqlDel("SZ8") + " AND " + RetSqlDel("SBM")  + " AND " + RetSqlDel("SB1")
	cQuery1 += " GROUP BY Z8_COD, Z8_DATAVAL, Z8_DATAP, B1_DESC"
	cQuery1 += " HAVING COUNT(Z8_DATAVAL) >= 1"
	cQuery1 += " ORDER BY STATVENC, Z8_COD, Z8_DATAVAL"

	cQuery1 := ChangeQuery(cQuery1)

	If Select("TRB1") != 0
		TRB1->(DbCloseArea())
	Endif

	TCQUERY cQuery1 NEW ALIAS "TRB1"

	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Processamento dos Dados                                  ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	DbSelectArea("TRB1")
	TRB1->(dbGoTop())
	SetRegua(RecCount())
	_dDtProdu := Ctod("")
	_Prod     := ''
	_Vez      := 1
	_nTotCxs  := 0
	_nTotCxsE := 0

	While !TRB1->(Eof())
		IncRegua()

		If nLin > 58
			Cabec(titulo,Cabec1,Cabec2,nomeprog,tamanho,nTipo)
			nLin := 9
		Endif

		If !Empty(mv_par09)
			_ProdComp := GetAdvFVal('SG1','G1_COMP',FWxfilial('SG1') + TRB1->COD,1)
			If AllTrim(mv_par09) <> AllTrim(_ProdComp)
				TRB1->(DbSkip())
				Loop
			Endif
		Endif

		If _Vez = 1
			@ nLin, 063 PSAY "ALERTA  V E R M E L H O  -  Vencimento até " + Dtoc(MV_PAR13) 
			nLin++
			nLin++
			_Vez := 2
		elseif _Vez = 2 .and. TRB1->STATVENC = '2AMARELO'
			@ nLin, 060 PSAY "=========================="
			@ nLin, 129 PSAY "======="
			nLin++
			@ nLin, 060 PSAY "Total Caixas ==> "
			@ nLin, 079 PSAY Transform(_nTotCxs,'@E 999,999')
			@ nLin, 103 PSAY "Total Empenhos ==> "
			@ nLin, 130 PSAY Transform(_nTotCxsE,'@E 999,999')
			_nTotCxs  := 0
			_nTotCxsE := 0

			nLin++
			nLin++
			nLin++
			@ nLin, 000 PSAY Replicate("#",220)
			If nLin > 58
				Cabec(titulo,Cabec1,Cabec2,nomeprog,tamanho,nTipo)
				nLin := 9
			Endif
			nLin++
			nLin++
			@ nLin, 063 PSAY "ALERTA  A M A R E L O  -  Vencimento de " + Dtoc(MV_PAR13 + 1) + " até " + Dtoc(MV_PAR02)
			nLin++
			nLin++
			_Vez := 3
		Endif

		// bloco para verificar quais familias não devem ser aparecer no relatorio
		If Empty(mv_par04) .And. !Empty(mv_par11)
			If TRB1->FAM $ AllTrim(mv_par11)
				TRB1->(DbSkip())
				Loop
			Endif
		Endif

		If _Prod != TRB1->COD
			@ nLin, 000 PSAY __PrtThinLine()
			nLin++
			@ nLin, 000 PSAY Left(alltrim(TRB1->DESCR),60)
			@ nLin, 063 PSAY TRB1->COD
			nLin++
			_Prod := TRB1->COD
		Endif

		_cCodProd := alltrim(TRB1->COD)
		_dDataVal := STOD(TRB1->DATAVAL)
		_dDatProd := STOD(TRB1->DATAP)
		_lVez := .T.

		If _dDtProdu <> _dDatProd		// Testa data da produção

			//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
			//³ Seleção de dados ref. empenhos                           ³
			//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
			cQuery2 := "SELECT ZZ5_COD AS COD, ZZ5_QPCAIX AS QPCAIX, ZZ5_QPPESO AS QPPESO, ZZ5_DTPINI AS DTPINI, ZZ5_DTPFIM AS DTPFIM"
			cQuery2 += " FROM " + RetSqlTab("ZZ4")
			cQuery2 += " INNER JOIN " + RetSqlTab("ZZ5") + "ON (ZZ4_NUM = ZZ5_NUM)"
			cQuery2 += " WHERE " + RetSqlFil("ZZ5") + " AND " + RetSqlFil("ZZ4")
			cQuery2 += " AND ZZ5_DTPINI BETWEEN '" + DTOS(mv_par07) + "' AND '" + DTOS(mv_par08) + "'"
			cQuery2 += " AND ZZ5_STATUS <> 'E'"
			cQuery2 += " AND ZZ4_NUM = ZZ5_NUM"
			cQuery2 += " AND ZZ4_STATUS NOT IN ('E', 'P', 'F')"
			cQuery2 += " AND ZZ4_TPOPER <> 'C'"
			cQuery2 += " AND ZZ5_COD = '" + _cCodProd + "'"
			cQuery2 += " AND " + RetSqlDel("ZZ4")
			cQuery2 += " AND " + RetSqlDel("ZZ5")
			cQuery2 += " ORDER BY ZZ4_NUM"

			cQuery2 := ChangeQuery(cQuery2)

			If Select("TRB2") != 0
				TRB2->(DbCloseArea())
			Endif

			TCQUERY cQuery2 NEW ALIAS "TRB2"

			If _lVez
				@ nLin, 080 PSAY Transform(TRB1->QTDCXS,'@E 999,999')
				@ nLin, 090 PSAY Dtoc(STOD(TRB1->DATAP))
				@ nLin, 103 PSAY Dtoc(STOD(TRB1->DATAVAL))
				@ nLin, 113 PSAY Transform(TRB1->PESO,'@E 999,999.99')

				If mv_par15 = 1
					_nPos := aScan(_aAux,{|aVal|aVal[1] = AllTrim(TRB1->COD)})
					if _nPos != 0
						_aAux[_nPos, 2] += TRB1->QTDCXS
						_aAux[_nPos, 4] += alltrim(str(TRB1->QTDCXS))+"("+substr(Dtoc(STOD(TRB1->DATAVAL)),1,5)+") "
					else
						aadd(_aAux, {AllTrim(TRB1->COD), TRB1->QTDCXS, alltrim(TRB1->DESCR), alltrim(str(TRB1->QTDCXS))+"("+substr(Dtoc(STOD(TRB1->DATAVAL)),1,5)+") "})
					endif
				endif

				_nTotCxs  += TRB1->QTDCXS
				_lVez := .F.
			endif

			DbSelectArea("TRB2")
			TRB2->(DbGoTop())
			While !TRB2->(Eof())
				If _dDatProd >= STOD(TRB2->DTPINI) .And. _dDatProd <= STOD(TRB2->DTPFIM)
					@ nLin, 131 PSAY Transform(TRB2->QPCAIX,'@E 999,999')
					@ nLin, 140 PSAY Transform(TRB2->QPPESO,'@E 999,999.99')
					@ nLin, 155 PSAY Dtoc(STOD(TRB2->DTPINI))
					@ nLin, 169 PSAY Dtoc(STOD(TRB2->DTPFIM))

					If mv_par15 = 1
						_nPos := aScan(_aAux,{|aVal|aVal[1] = AllTrim(TRB2->COD)})
						if _nPos != 0
							_aAux[_nPos, 2] -= TRB2->QPCAIX
						endif
					endif

					_nTotCxsE += TRB2->QPCAIX
					nLin++
				Endif

				TRB2->(dbSkip())	 // Avanca o ponteiro do registro no arquivo
			End
			_dDtProdu := _dDatProd
		endif
		nLin++
		TRB1->(dbSkip())	 // Avanca o ponteiro do registro no arquivo
	End

	If nLin > 58
		Cabec(titulo,Cabec1,Cabec2,nomeprog,tamanho,nTipo)
		nLin := 9
	Endif 

	@ nLin, 060 PSAY "=========================="
	@ nLin, 129 PSAY "======="
	nLin++
	@ nLin, 060 PSAY "Total Caixas ==> "
	@ nLin, 079 PSAY Transform(_nTotCxs,'@E 999,999')
	@ nLin, 103 PSAY "Total Empenhos ==> "
	@ nLin, 130 PSAY Transform(_nTotCxsE,'@E 999,999')

	If mv_par15 = 1
		for i := 1 to len(_aAux)
			if _aAux[i,2] > 0
				aadd(_aDados, {_aAux[i,1], _aAux[i,3], _aAux[i,2], _aAux[i,4]})
			endif
		next i
	endif

	TRB2->(DbCloseArea())
	TRB1->(DbCloseArea())

	Set Device To Screen

	If Len(_aDados) > 0		// Gera e mostra no Excel
		AADD( _aCabec, {dtoc(ddatabase), "C", 10, 0} )
		AADD( _aCabec, {"VALIDADE ATÉ " + dtoc(mv_par13), "C", 25, 0} )
		AADD( _aCabec, {"CXS", "N", 3, 0} )
		AADD( _aCabec, {"VALIDADE",	"C", 30, 0} )
		U_GERAEXCEL(nomeprog, _aDados, _aCabec, .T., .T.)
	Endif

	If aReturn[5]==1
		Set Printer TO
		dbcommitAll()
		ourspool(wnrel)
	Endif

	MS_FLUSH()   //Libera fila de relatorios em spool (Tipo Rede Netware)

Return
