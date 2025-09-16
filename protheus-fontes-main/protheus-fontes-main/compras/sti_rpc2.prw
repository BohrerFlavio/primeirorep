#INCLUDE "PROTHEUS.CH"
#INCLUDE "RWMAKE.CH"
#INCLUDE "TOPCONN.CH"                           

/*/{Protheus.doc} STI_RPC2
Relatório de rastreabilidade de pedidos de compra por valores.
@author 	Evandro Mugnol
@since 		Mai/2023
@return 	Nil, Função não tem retorno
@obs 		N/A
/*/

User Function STI_RPC2()
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Perguntas no Arquivo SX1                                     ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	cPerg := "STI_RPC2"
	Pergunte(cPerg,.T.)

	_cNomArq := "RASTREABILIDADE_PC_POR_VALORES_DE_" + SUBSTR(DTOS(MV_PAR01),7,2) + SUBSTR(DTOS(MV_PAR01),5,2) + SUBSTR(DTOS(MV_PAR01),3,2)+ "_ATE_" + SUBSTR(DTOS(MV_PAR02),7,2) + SUBSTR(DTOS(MV_PAR02),5,2) + SUBSTR(DTOS(MV_PAR02),3,2)
	_aCabec	 := {}
	_aDados	 := {}

	MsAguarde({|lFim| ProcExcel()},"Rastreabilidade de Pedidos de Compra por valores","Aguarde Processando as Informações Solicitadas...")
	
Return


//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Chamada da função ProcExcel()                            ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
Static Function ProcExcel()

	Local x

	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Seleção de dados                                         ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	cQuery := " SELECT C7_USER, C7_FORNECE, C7_LOJA, A2_NOME, C7_GRUPO, BM_DESC, C7_PRODUTO, C7_DESCRI, C7_NUM, C7_ITEM, C7_PRECO, C7_EMISSAO, C7_QUANT" 
	cQuery += "   FROM " + RetSqlTab("SC7")
	cQuery += "  INNER JOIN " + RetSqlTab("SA2") + " ON A2_FILIAL = '" + xFilial("SA2") + "' AND A2_COD = C7_FORNECE AND A2_LOJA = C7_LOJA AND " + RetSQLDel("SA2")
	cQuery += "  INNER JOIN " + RetSqlTab("SBM") + " ON BM_FILIAL = '" + xFilial("SBM") + "' AND BM_GRUPO = C7_GRUPO AND " + RetSQLDel("SBM")
	cQuery += "  WHERE " + RetSqlFil("SC7") 
	cQuery += "    AND C7_EMISSAO BETWEEN '" + DTOS(MV_PAR01) + "' AND '" + DTOS(MV_PAR02) + "'"
	cQuery += "    AND C7_PRODUTO BETWEEN '" + MV_PAR03 + "' AND '" + MV_PAR04 + "'"
	cQuery += "    AND C7_GRUPO BETWEEN '" + MV_PAR05 + "' AND '" + MV_PAR06 + "'"
	cQuery += "    AND C7_USER BETWEEN '" + MV_PAR07 + "' AND '" + MV_PAR08 + "'"
	cQuery += "    AND " + RetSqlDel("SC7")
	cQuery += "  ORDER BY C7_FILIAL, C7_NUM"

	cQuery := ChangeQuery(cQuery)

	//memowrite("ZZZ_1111.TXT", cQuery)

	If Select("TRB") != 0
		TRB -> (DbCloseArea())
	Endif

	TCQUERY cQuery NEW ALIAS "TRB"

	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Carrega Array para Excel                                 ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	DbSelectArea("TRB")
	DbGoTop()
	Do While !TRB -> (Eof ())

		// ---- Início Busca Dados Última Nota Fiscal
		cQuery1 := " SELECT TOP 1 *" 
		cQuery1 += "   FROM " + RetSqlTab("SD1")
		cQuery1 += "  WHERE " + RetSqlFil("SD1") 
		cQuery1 += "    AND D1_COD = '" + TRB->C7_PRODUTO + "' "
		cQuery1 += "    AND D1_EMISSAO < '" + TRB->C7_EMISSAO + "' "
		cQuery1 += "    AND D1_TES <> '" + Space(Len(SD1->D1_TES)) + "' "
		cQuery1 += "    AND D1_TIPO <> 'C' "
		cQuery1 += "    AND " + RetSqlDel("SD1")
		cQuery1 += "  ORDER BY D1_NUMSEQ DESC"

		cQuery1 := ChangeQuery(cQuery1)

		//memowrite("ZZZ_2222.TXT", cQuery1)

		If Select("TRB1") != 0
			TRB1 -> (DbCloseArea())
		Endif

		TCQUERY cQuery1 NEW ALIAS "TRB1"

		DbSelectArea("TRB1")
		_dDtDigUlc := TRB1->D1_DTDIGIT
		_dDtEntUlc := TRB1->D1_EMISSAO
		_cPdUlComp := TRB1->D1_PEDIDO
		_cItUlComp := TRB1->D1_ITEMPC
		_nVlUlComp := IIF(TRB1->D1_TIPO $ "NDB",((TRB1->D1_TOTAL - TRB1->D1_VALDESC) / TRB1->D1_QUANT), TRB1->D1_VUNIT)
		_nQtUlComp := TRB1->D1_QUANT

		TRB1 -> (DbCloseArea())
		// ---- Final Busca Dados Última Nota Fiscal

		DbSelectArea("TRB")
		_nDifFin := _nVlUlComp - TRB->C7_PRECO

		// Faz a composição dos segmentos
		_aSegmtos := {}
		_cSegmtos := ""
		DbSelectArea("ZLR")
		DbSetOrder(1)
		DbSeek(xFilial("ZLR") + TRB->C7_FORNECE + TRB->C7_LOJA)
		While !Eof() .And. ZLR->ZLR_FILIAL + ZLR->ZLR_CODFOR + ZLR->ZLR_LOJFOR == xFilial("ZLR") + TRB->C7_FORNECE + TRB->C7_LOJA
			_cSegmto := ZLR->ZLR_CODSEG + "-" + AllTrim(ZLR->ZLR_DESSEG)
			If aScan(_aSegmtos, _cSegmto) == 0 .And. !Empty(_cSegmto)
				AADD(_aSegmtos, _cSegmto)
			Endif
			DbSelectArea("ZLR")
			DbSkip()
		Enddo
		
		If Len(_aSegmtos) > 0
			For x := 1 To Len(_aSegmtos)
				_cSegmtos += IIF(x==1,_aSegmtos[x]," / "+_aSegmtos[x])
			Next
		Endif

		AADD(_aDados, { AllTrim(UsrFullName(TRB->C7_USER))	,;
						TRB->C7_FORNECE						,;
						TRB->C7_LOJA						,;
						TRB->A2_NOME 						,;
						TRB->C7_GRUPO						,;
						TRB->C7_PRODUTO						,;
						STRTRAN(TRB->C7_DESCRI, ";", " ")	,;
						_cSegmtos							,;
						_cPdUlComp							,;
						_cItUlComp							,;
						_nVlUlComp							,;
						_nQtUlComp							,;
						STOD(_dDtDigUlc)					,;
						STOD(_dDtEntUlc)					,;
						TRB->C7_NUM							,;
						TRB->C7_ITEM						,;
						TRB->C7_PRECO						,;
						TRB->C7_QUANT						,;
						STOD(TRB->C7_EMISSAO)				,;
						_nDifFin							,;
						_nDifFin * _nQtUlComp				})

		TRB->(dbSkip())	 	// Avanca o ponteiro do registro no arquivo 
	EndDo

	TRB -> (DbCloseArea())

	If Len(_aDados) > 0
		AADD( _aCabec, {"USUARIO",				"C", 030, 0} )
		AADD( _aCabec, {"FORNECEDOR",			"C", 006, 0} )
		AADD( _aCabec, {"LOJA",					"C", 002, 0} )
		AADD( _aCabec, {"RAZAO SOCIAL",			"C", 040, 0} )
		AADD( _aCabec, {"GRUPO",				"C", 004, 0} )
		AADD( _aCabec, {"PRODUTO",				"C", 015, 0} )
		AADD( _aCabec, {"DESCRICAO",			"C", 160, 0} )
		AADD( _aCabec, {"SEGMENTO",				"C", 006, 0} )
		AADD( _aCabec, {"ULT PEDIDO",			"C", 006, 0} )
		AADD( _aCabec, {"ULT ITEM",				"C", 004, 0} )
		AADD( _aCabec, {"PRECO ULT COMPRA",		"N", 018, 7} )
		AADD( _aCabec, {"QUANT ULT COMPRA",		"N", 018, 7} )
		AADD( _aCabec, {"ENTRADA ULT COMPRA",	"D", 008, 0} )
		AADD( _aCabec, {"EMISSAO ULT COMPRA",	"D", 008, 0} )
		AADD( _aCabec, {"PEDIDO",				"C", 006, 0} )
		AADD( _aCabec, {"ITEM",					"C", 004, 0} )
		AADD( _aCabec, {"PRECO COMPRA",			"N", 018, 7} )
		AADD( _aCabec, {"QUANT COMPRA",			"N", 018, 7} )
		AADD( _aCabec, {"DATA EMISSAO",			"D", 008, 0} )
		AADD( _aCabec, {"DIFERENCA R$",			"N", 018, 7} )
		AADD( _aCabec, {"ECONOMIA R$",			"N", 018, 7} )
		U_GERAEXCEL(_cNomArq, _aDados, _aCabec, .T.)
	Endif

Return
