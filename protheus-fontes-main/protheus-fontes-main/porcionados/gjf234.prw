#INCLUDE "rwmake.ch"
#INCLUDE "topconn.ch"

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³GJ234   º Autor ³ Giuliano Forgiarini  º Data ³  05/11/15   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDescricao ³ Relatorio Produção do setor de embalagem Porcionados       º±±
±±º          ³                                                            º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ PCP Porcionados                                            º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/

User Function GJF234()

	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Declaracao de Variaveis                                             ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ

	Local cDesc1         := "Este programa tem como objetivo imprimir relatorio  "
	Local cDesc2         := "de produção de caixas no setor de embalagem da empresa"
	Local cDesc3         := "podendo-se definir uma balança específica ou listando"
	//Local cPict          := "todas elas de acordo com os parametros"
	Local titulo         := "RELATORIO PRODUÇÃO DE CAIXAS - EMBALAGEM PORCIONADOS"
	Local nLin           := 80

	local Cabec1         := "Grupo de produtos"
	Local Cabec2         := "Codigo     Desc.Reduzida             Desc.Completa                                                   Nº. de Caixas     Pes.Total"

	//Local imprime        := .T.
	Local aOrd := {}
	Private lEnd         := .F.
	Private lAbortPrint  := .F.
	Private CbTxt        := ""
	Private limite       := 80
	Private tamanho      := "M"
	Private nomeprog     := "GJF234" // Coloque aqui o nome do programa para impressao no cabecalho
	Private nTipo        := 18
	Private aReturn      := { "Zebrado", 1, "Administracao", 2, 2, 1, "", 1}
	Private nLastKey     := 0
	Private cPerg        := "GJF234"
	//Private cbtxt      := Space(10)
	Private cbcont     := 00
	Private CONTFL     := 01
	Private m_pag      := 01
	Private wnrel      := "GJF234" // Coloque aqui o nome do arquivo usado para impressao em disco
	Private TotCaix    := 0.00
	Private TotPeso    := 0.00

	pergunte(cPerg,.F.)

	wnrel := SetPrint('SZ8',NomeProg,cPerg,@titulo,cDesc1,cDesc2,cDesc3,.T.,aOrd,.T.,Tamanho,,.T.)

	//para verificação se existe previsao de pesagem
	/*
	cQuery := " SELECT BM_GRUPO, Z8_COD, SUM(Z8_PESO) AS PESO,COUNT(*) AS CAIX "
	cQuery += " FROM " + RetSqlTab("SZ8") + ", " + RetSqlTab("SBM")  + ", " + RetSqlTab("SB1")
	cQuery += " WHERE "
	cQuery += RetSQLFil('SB1') + " AND"
	cQuery += RetSQLFil('SBM') + " AND"
	cQuery += RetSQLFil('SZ8') + " AND"
	cQuery +=" Z8_FILORI = '" + cFilAnt + "' AND  B1_TIPO = 'PA' AND B1_COD = Z8_COD AND "
	cQuery +=" (Z8_DATA BETWEEN '" + DTOS(mv_par01) +"' AND '" + DTOS(mv_par02) + "') AND"
	cQuery += iif(!empty(mv_par03), " B1_GRUPO = '" + mv_par03 + "' AND ","")
	cQuery += iif(!empty(mv_par04), " B1_COD = '" + mv_par04 + "' AND ","")
	cQuery +=" Z8_DATAE = ' ' AND BM_GRUPO = B1_GRUPO AND BM_PORC = 'S' AND "
	cQuery += iif(!empty(mv_par05),"B1_FAM = '" +mv_par05 + "' AND "," ")
	cQuery += RetSQLDel('SB1') + " AND " + RetSQLDel('SZ8') + " AND " + RetSQLDel('SBM')
	cQuery += " GROUP BY BM_GRUPO, Z8_COD"
	cQuery += " ORDER BY BM_GRUPO, Z8_COD"
	*/
	//alert(mv_par07)
	cQuery := " SELECT BM_GRUPO, Z8_COD, SUM(Z8_PESO) AS PESO,COUNT(*) AS CAIX "
	cQuery += " FROM " + RetSqlTab("SZ8") + ", " + RetSqlTab("SBM")  + ", " + RetSqlTab("SB1")
	cQuery += " WHERE "
	cQuery += RetSQLFil('SB1') + " AND"
	cQuery += RetSQLFil('SBM') + " AND"
	cQuery += RetSQLFil('SZ8') + " AND"
	cQuery +=" Z8_FILORI = '" + cFilAnt + "' AND  B1_TIPO = 'PA' AND B1_COD = Z8_COD AND "
	IF mv_par07 = 2
			cQuery += " Z8_TIPO = 'P' AND "
	elseif mv_par07 = 3
		cQuery += "  Z8_TIPO = 'R' AND "
	Endif	
	cQuery +=" (Z8_DATA BETWEEN '" + DTOS(mv_par01) +"' AND '" + DTOS(mv_par02) + "') AND"
	cQuery += iif(!empty(mv_par03), " B1_GRUPO = '" + mv_par03 + "' AND ","")
	cQuery += iif(!empty(mv_par04), " B1_COD = '" + mv_par04 + "' AND ","")	
	cQuery +=" Z8_DATAE = ' ' AND BM_GRUPO = B1_GRUPO AND BM_PORC = 'S' AND Z8_LOTEPOR <> '' AND "
	cQuery += iif(!empty(mv_par05),"B1_FAM = '" +mv_par05 + "' AND "," ")
	cQuery += RetSQLDel('SB1') + " AND " + RetSQLDel('SZ8') + " AND " + RetSQLDel('SBM')
	cQuery += " GROUP BY BM_GRUPO, Z8_COD"
	cQuery += " ORDER BY BM_GRUPO, Z8_COD"
	cQuery := ChangeQuery(cQuery)
	//alert(type(mv_par07))
	
	//memowrite("ZZZ_GJF234.TXT",cQuery)

	//	* Mostrar a consulta */
	//@ 116,090 To 416,707 Dialog oDlgMemo Title "Consulta"
	//@ 055,005 Get cQuery Size 250,080 MEMO Object oMemo
	//Activate Dialog oDlgMemo
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Monta a interface padrao com o usuario...                           ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ

	If Select("PROD") != 0
		PROD->(dbCloseArea())
	Endif
	TCQUERY cQuery NEW ALIAS "PROD"

	If nLastKey == 27
		Return
	Endif

	SetDefault(aReturn,'SZ8')

	If nLastKey == 27
		Return
	Endif

	nTipo := If(aReturn[4]==1,15,18)

	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Processamento. RPTSTATUS monta janela com a regua de processamento. ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ

	RptStatus({|| RunReport(Cabec1,Cabec2,Titulo,nLin) },Titulo)
Return

Static Function RunReport(Cabec1,Cabec2,Titulo,nLin)

	//Local nOrdem

	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ SETREGUA -> Indica quantos registros serao processados para a regua ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ

	PROD->(dbGoTop())

	PROD->(SetRegua(RecCount()))

	_cCodigo  := ''
	_Grupo    := ''
	_TotCaix  := 0.00
	_TotPeso  := 0.00
	_TotCaixG := 0.00
	_TotPesoG := 0.00

	While PROD->(!EOF())

		incregua()

		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³ Verifica o cancelamento pelo usuario...                             ³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ

		If lAbortPrint
			@nLin,00 PSAY "*** CANCELADO PELO OPERADOR ***"
			Exit
		Endif

		If nLin > 75 // Salto de Página. Neste caso o formulario tem 55 linhas...
			Cabec(Titulo,Cabec1,Cabec2,NomeProg,Tamanho,nTipo)
			nLin := 9
		Endif

		if _Grupo != PROD->BM_GRUPO
			nlin++
			@nlin,001 psay "Grupo: " + PROD->BM_GRUPO + " " + fBuscaCpo('SBM',1,xfilial('SBM')+PROD->BM_GRUPO,'BM_DESC')
			_Grupo := PROD->BM_GRUPO
			nlin++
		endif

		DbSelectArea('SB1')
		_cDesc     := fBuscaCPO('SB1',1,xfilial('SB1') + substr(PROD->Z8_COD,1,6),'B1_DESC')
		_cDescRed  := fBuscaCPO('SB1',1,xfilial('SB1') + substr(PROD->Z8_COD,1,6),'B1_DESCRED')
		@nlin,001 psay substr(PROD->Z8_COD,1,6)
		@nlin,010 psay _cDescRed
		@nlin,035 psay substr(_cDesc,1,60)
		@nlin,095 psay transform(PROD->CAIX,'@E 9,999,999')
		@nlin,115 psay transform(PROD->PESO,'@E 999,999.99')
		nlin++

		//Bloco para listar as caixass se for modo analitico
		if mv_par06 = 1
			@nlin,003 psay 'Caixas'
			@nlin,022 psay 'Descrição'
			@nlin,049 psay 'Peso'
			@nlin,069 psay 'Lote Porc.'
			@nlin,089 psay 'Dt.Producao'
			//@nlin,109 psay 'Dt.Abate'
			nlin++
			ListCaix(PROD->Z8_COD)

			While PROD2->(!eof())

				If nLin > 75 // Salto de Página. Neste caso o formulario tem 55 linhas...
					Cabec(Titulo,Cabec1,Cabec2,NomeProg,Tamanho,nTipo)
					nLin := 9
				Endif

				_dDtProd := fBuscaCPO('ZAU',1,xfilial('ZAU') + PROD2->LOTEPOR,'ZAU_DTPROD')
				_dDtAbt := fBuscaCPO('ZAU',1,xfilial('ZAU') + PROD2->LOTEPOR,'ZAU_DTABAT')
				
				@nlin,001 psay PROD2->CONTROL
				@nlin,020 psay PROD2->DESCRI
				@nlin,050 psay transform(PROD2->PESO,'@E 99.99')
				@nlin,070 psay PROD2->LOTEPOR
				@nlin,090 psay dtoc(_dDtProd)
				//@nlin,110 psay dtoc(_dDtAbt)
				nlin++
				PROD2->(Dbskip())
			Enddo
			@nlin,01 psay replicate('-',132)
			nlin++
		endif
		//Fim do bloco para listar caixas se for modo analitico

		_TotCaixG += PROD->CAIX
		_TotPesoG += PROD->PESO
		_TotCaix  += PROD->CAIX
		_TotPeso  += PROD->PESO
		PROD->(dbSkip()) // Avanca o ponteiro do registro no arquivo

		if _Grupo <> PROD->BM_GRUPO
			@nlin,001 psay 'TOTAIS DO GRUPO:'
			@nlin,096 psay  + transform(_TotCaixG,'@E 999,999')
			@nlin,110 psay  + transform(_TotPesoG,'@E 999,999,999.99')
			nlin++
			_TotPesoG := 0
			_TotCaixG := 0
			@nlin,01 psay replicate('-',132)
			@nlin++
		endif

	EndDo

	//Cabec(Titulo,Cabec1,Cabec2,NomeProg,Tamanho,nTipo)
	//nLin := 9 pula a linha

	nlin += 2
	@nlin,001 psay 'TOTAIS DO PERÍODO: --------------------> '
	@nlin,050 psay transform(_TotCaix,'@E 999,999')
	@nlin,065 psay transform(_TotPeso,'@E 999,999,999.99')

	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Finaliza a execucao do relatorio...                                 ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ

	DbCloseArea('PROD')

	SET DEVICE TO SCREEN

	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Se impressao em disco, chama o gerenciador de impressao...          ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ

	If aReturn[5]==1
		dbCommitAll()
		SET PRINTER TO
		OurSpool(wnrel)
	Endif

	MS_FLUSH()

Return

Static Function ListCaix(_cod)
	/*
	cQuery2 := " SELECT BM_GRUPO, Z8_COD, Z8_DESCRI AS DESCRI, Z8_PESO AS PESO, Z8_CONTROL AS CONTROL, Z8_LOTEPOR AS LOTEPOR "
	cQuery2 += " FROM " + RetSqlTab("SZ8") + ", " + RetSqlTab("SBM")  + ", " + RetSqlTab("SB1")
	cQuery2 += " WHERE "
	cQuery2 += RetSQLFil('SB1') + " AND"
	cQuery2 += RetSQLFil('SBM') + " AND"
	cQuery2 += RetSQLFil('SZ8') + " AND"
	cQuery2 +=" Z8_FILORI = '" + cFilAnt + "' AND  B1_TIPO = 'PA' AND B1_COD = Z8_CODORI AND B1_COD = '" + _cod + "' AND "
	cQuery2 +=" (Z8_DATA BETWEEN '" + DTOS(mv_par01) +"' AND '" + DTOS(mv_par02) + "') AND"
	cQuery2 += iif(!empty(mv_par03), " B1_GRUPO = '" + mv_par03 + "' AND ","")
	cQuery2 += iif(!empty(mv_par04), " B1_COD = '" + mv_par04 + "' AND ","")
	cQuery2 +=" Z8_DATAE = ' ' AND BM_GRUPO = B1_GRUPO AND BM_PORC = 'S' AND "
	cQuery2 += iif(!empty(mv_par05)," AND B1_FAM = '" +mv_par05 + "' AND "," ")
	cQuery2 += RetSQLDel('SB1') + " AND " + RetSQLDel('SZ8') + " AND " + RetSQLDel('SBM')
	*/
	cQuery2 := " SELECT BM_GRUPO, Z8_COD, Z8_DESCRI AS DESCRI, Z8_PESO AS PESO, Z8_CONTROL AS CONTROL, Z8_LOTEPOR AS LOTEPOR "
	cQuery2 += " FROM " + RetSqlTab("SZ8") + ", " + RetSqlTab("SBM")  + ", " + RetSqlTab("SB1")
	cQuery2 += " WHERE "
	cQuery2 += RetSQLFil('SB1') + " AND"
	cQuery2 += RetSQLFil('SBM') + " AND"
	cQuery2 += RetSQLFil('SZ8') + " AND"
	cQuery2 +=" Z8_FILORI = '" + cFilAnt + "' AND  B1_TIPO = 'PA' AND B1_COD = Z8_CODORI AND B1_COD = '" + _cod + "' AND "
	IF mv_par07 = 2
		cQuery2 += " Z8_TIPO = 'P' AND "
	elseif mv_par07 = 3
		cQuery2 += "  Z8_TIPO = 'R' AND "
	Endif
	cQuery2 +=" (Z8_DATA BETWEEN '" + DTOS(mv_par01) +"' AND '" + DTOS(mv_par02) + "') AND"
	cQuery2 += iif(!empty(mv_par03), " B1_GRUPO = '" + mv_par03 + "' AND ","")
	cQuery2 += iif(!empty(mv_par04), " B1_COD = '" + mv_par04 + "' AND ","")
	cQuery2 +=" Z8_DATAE = ' ' AND BM_GRUPO = B1_GRUPO AND BM_PORC = 'S' AND "
	cQuery2 += iif(!empty(mv_par05)," AND B1_FAM = '" +mv_par05 + "' AND "," ")
	cQuery2 += RetSQLDel('SB1') + " AND " + RetSQLDel('SZ8') + " AND " + RetSQLDel('SBM')


	cQuery2 := ChangeQuery(cQuery2)

	//memowrite("ZZZ_GJF234A.TXT",cQuery2)

	//	* Mostrar a consulta */
	//@ 116,090 To 416,707 Dialog oDlgMemo Title "Consulta"
	//@ 055,005 Get cQuery Size 250,080 MEMO Object oMemo
	//Activate Dialog oDlgMemo
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Monta a interface padrao com o usuario...                           ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ

	If Select("PROD2") != 0
		PROD2->(dbCloseArea())
	Endif
	TCQUERY cQuery2 NEW ALIAS "PROD2"

Return
