#INCLUDE "PROTHEUS.CH"
#INCLUDE "RWMAKE.CH"
#INCLUDE "TOPCONN.CH"                           

/*/{Protheus.doc} STI_RANK
Relatório de ranking fornecedores conforme ordem escolhida.
@author 	Evandro Mugnol
@since 		Fev/2019
@return 	Nil, Função não tem retorno
@obs 		N/A
/*/

User Function STI_RANK()
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Perguntas no Arquivo SX1                                     ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	cPerg := "STI_RANK"
	Pergunte(cPerg,.T.)

	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Variáveis utilizadas para gerar em Excel                     ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	DO CASE
		CASE MV_PAR05 == 1
			_cTp := "VALOR"
		CASE MV_PAR05 == 2
			_cTp := "PRODUTO"
		CASE MV_PAR05 == 3
			_cTp := "FORNECEDOR"
		OTHERWISE
			_cTp := ""
	ENDCASE

	_cNomArq := "RANKING_" + _cTp + "_DE_" + SUBSTR(DTOS(MV_PAR01),7,2) + SUBSTR(DTOS(MV_PAR01),5,2) + SUBSTR(DTOS(MV_PAR01),3,2)+ "_ATE_" + SUBSTR(DTOS(MV_PAR02),7,2) + SUBSTR(DTOS(MV_PAR02),5,2) + SUBSTR(DTOS(MV_PAR02),3,2)
	_aCabec	 := {}
	_aDados	 := {}

	MsAguarde({|lFim| ProcExcel()},"Ranking de Compras","Aguarde Processando as Informações Solicitadas...")

Return


//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Chamada da função ProcExcel()                            ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
Static Function ProcExcel()

	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Seleção de dados                                         ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	DO CASE
		CASE MV_PAR05 == 1		// POR VALOR (R$)
			cQuery := " SELECT D1_COD, D1_DESCRI, D1_FORNECE, D1_LOJA, A2_NOME, D1_TOTAL, D1_EMISSAO, D1_PEDIDO, D1_GRUPO" 
			cQuery += "   FROM " + RetSqlTab("SD1")
			cQuery += "  INNER JOIN " + RetSqlTab("SF4") + " ON F4_FILIAL = '" + xFilial("SF4") + "' AND F4_CODIGO = D1_TES AND F4_TIPO = 'E' AND  F4_DUPLIC = 'S' AND SF4.D_E_L_E_T_ = '' "
			cQuery += "  INNER JOIN " + RetSqlTab("SA2") + " ON A2_FILIAL = '" + xFilial("SA2") + "' AND A2_COD = D1_FORNECE AND A2_LOJA = D1_LOJA AND SA2.D_E_L_E_T_ = '' "
			cQuery += "  WHERE " + RetSqlFil("SD1") 
			cQuery += "    AND D1_EMISSAO BETWEEN '" + DTOS(MV_PAR01) + "' AND '" + DTOS(MV_PAR02) + "'"
			cQuery += "    AND D1_GRUPO BETWEEN '" + MV_PAR03 + "' AND '" + MV_PAR04 + "'"
			cQuery += "    AND D1_TIPO = 'N'"
			cQuery += "    AND " + RetSqlDel("SD1")
			cQuery += "  ORDER BY D1_GRUPO, D1_TOTAL DESC"
		
			cQuery := ChangeQuery(cQuery)
		
			If Select("TRB") != 0
				TRB->(DbCloseArea())
			Endif

			TCQUERY cQuery NEW ALIAS "TRB"

		CASE MV_PAR05 == 2		// POR PRODUTO
			cQuery := " SELECT D1_COD, D1_DESCRI, D1_TOTAL, D1_EMISSAO, D1_PEDIDO, D1_GRUPO, " 
			cQuery += "        (SELECT COUNT(*) QTDE "
			cQuery += " 		  FROM " + RetSqlName("SD1") + " XD1"
			cQuery += "  		 INNER JOIN " + RetSqlTab("SF4") + " ON F4_FILIAL = '" + xFilial("SF4") + "' AND F4_CODIGO = D1_TES AND F4_TIPO = 'E' AND  F4_DUPLIC = 'S' AND SF4.D_E_L_E_T_ = '' "
			cQuery += " 		 WHERE " + RetSqlFil("SD1") 
			cQuery += "            AND XD1.D1_COD = SD1.D1_COD"
			cQuery += "    		   AND D1_EMISSAO BETWEEN '" + DTOS(MV_PAR01) + "' AND '" + DTOS(MV_PAR02) + "'"
			cQuery += "            AND D1_GRUPO BETWEEN '" + MV_PAR03 + "' AND '" + MV_PAR04 + "'"
			cQuery += "            AND D1_TIPO = 'N'"
			cQuery += "            AND " + RetSqlDel("SD1") + ") TOTALCP"
			cQuery += "   FROM " + RetSqlTab("SD1")
			cQuery += "  INNER JOIN " + RetSqlTab("SF4") + " ON F4_FILIAL = '" + xFilial("SF4") + "' AND F4_CODIGO = D1_TES AND F4_TIPO = 'E' AND  F4_DUPLIC = 'S' AND SF4.D_E_L_E_T_ = '' "
			cQuery += "  WHERE " + RetSqlFil("SD1") 
			cQuery += "    AND D1_EMISSAO BETWEEN '" + DTOS(MV_PAR01) + "' AND '" + DTOS(MV_PAR02) + "'"
			cQuery += "    AND D1_GRUPO BETWEEN '" + MV_PAR03 + "' AND '" + MV_PAR04 + "'"
			cQuery += "    AND D1_TIPO = 'N'"
			cQuery += "    AND " + RetSqlDel("SD1")
			cQuery += "  ORDER BY D1_GRUPO, TOTALCP DESC, D1_COD, D1_EMISSAO"

			cQuery := ChangeQuery(cQuery)

			If Select("TRB") != 0
				TRB->(DbCloseArea())
			Endif

			TCQUERY cQuery NEW ALIAS "TRB"

 		CASE MV_PAR05 == 3		// POR FORNECEDOR
			cQuery := " SELECT A2_COD, A2_LOJA, A2_NOME," 
			cQuery += "        ISNULL((SELECT SUM(D1_TOTAL) "
			cQuery += " 		  		 FROM " + RetSqlTab("SD1")
			cQuery += "  		 	    INNER JOIN " + RetSqlTab("SF4") + " ON F4_FILIAL = '" + xFilial("SF4") + "' AND F4_CODIGO = D1_TES AND F4_TIPO = 'E' AND  F4_DUPLIC = 'S' AND SF4.D_E_L_E_T_ = '' "
			cQuery += " 		        WHERE " + RetSqlFil("SD1") 
			cQuery += "    		          AND D1_EMISSAO BETWEEN '" + DTOS(MV_PAR01) + "' AND '" + DTOS(MV_PAR02) + "'"
			cQuery += "                   AND D1_GRUPO BETWEEN '" + MV_PAR03 + "' AND '" + MV_PAR04 + "'"
			cQuery += "                   AND D1_FORNECE = A2_COD"
			cQuery += "                   AND D1_LOJA = A2_LOJA"
			cQuery += "                   AND D1_TIPO = 'N'"
			cQuery += "                   AND " + RetSqlDel("SD1") + "),0) TOTAL"
			cQuery += "   FROM " + RetSqlTab("SA2")
			cQuery += "  WHERE " + RetSqlFil("SA2") 
			cQuery += "    AND A2_COD BETWEEN '      ' AND 'ZZZZZZ'"
			cQuery += "    AND A2_LOJA BETWEEN '  ' AND 'ZZ'"
			cQuery += "    AND " + RetSqlDel("SA2")
			cQuery += "  ORDER BY TOTAL DESC"
			cQuery := ChangeQuery(cQuery)

			If Select("TRB") != 0
				TRB->(DbCloseArea())
			Endif

			TCQUERY cQuery NEW ALIAS "TRB"
	ENDCASE

	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Carrega Array para Excel                                 ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	DbSelectArea("TRB")
	DbGoTop()
	Do While !TRB->(Eof())

		DO CASE
			CASE MV_PAR05 == 1		// POR VALOR (R$)
				AADD(_aDados, { TRB->D1_GRUPO				,;
								Posicione("SBM", 1, xFilial("SBM") + TRB->D1_GRUPO, "BM_DESC") ,;
								TRB->D1_COD					,;
								TRB->D1_DESCRI				,;
								TRB->D1_FORNECE				,;
								TRB->D1_LOJA				,;
								TRB->A2_NOME				,;
								TRB->D1_TOTAL				,;
								STOD(TRB->D1_EMISSAO)		,;
								TRB->D1_PEDIDO				,;
								_UsrName(Posicione("SC7", 1, xFilial("SC7") + TRB->D1_PEDIDO, "C7_USER"))})

			CASE MV_PAR05 == 2		// POR PRODUTO
				AADD(_aDados, { TRB->D1_GRUPO				,;
								Posicione("SBM", 1, xFilial("SBM") + TRB->D1_GRUPO, "BM_DESC") ,;
								TRB->TOTALCP				,;
								TRB->D1_COD					,;
								TRB->D1_DESCRI				,;
								TRB->D1_TOTAL				,;
								STOD(TRB->D1_EMISSAO)		,;
								TRB->D1_PEDIDO				,;
								_UsrName(Posicione("SC7", 1, xFilial("SC7") + TRB->D1_PEDIDO, "C7_USER"))})

			CASE MV_PAR05 == 3		// POR FORNECEDOR
				AADD(_aDados, { TRB->A2_COD					,;
								TRB->A2_LOJA  				,;
								TRB->A2_NOME 				,;
								TRB->TOTAL           		})
		ENDCASE

		TRB->(dbSkip())	 // Avanca o ponteiro do registro no arquivo 
	EndDo

	TRB -> (DbCloseArea())

	DO CASE
		CASE MV_PAR05 == 1		// POR VALOR (R$)
			If Len(_aDados) > 0
				AADD( _aCabec, {"GRUPO",			"C", 04, 0} )
				AADD( _aCabec, {"DESC. GRUPO",		"C", 30, 0} )
				AADD( _aCabec, {"PRODUTO",			"C", 15, 0} )
				AADD( _aCabec, {"DESCRICAO",		"C", 60, 0} )
				AADD( _aCabec, {"FORNECEDOR",		"C", 06, 0} )
				AADD( _aCabec, {"LOJA",				"C", 02, 0} )
				AADD( _aCabec, {"RAZAO SOCIAL",		"C", 40, 0} )
				AADD( _aCabec, {"VALOR TOTAL",		"N", 12, 2} )
				AADD( _aCabec, {"DATA EMISSAO",		"D", 08, 0} )
				AADD( _aCabec, {"PEDIDO",			"C", 06, 0} )
				AADD( _aCabec, {"USUARIO",			"C", 30, 0} )
				U_GERAEXCEL(_cNomArq, _aDados, _aCabec, .T.)
			Endif

		CASE MV_PAR05 == 2		// POR PRODUTO
			If Len(_aDados) > 0
				AADD( _aCabec, {"GRUPO",			"C", 04, 0} )
				AADD( _aCabec, {"DESC. GRUPO",		"C", 30, 0} )
				AADD( _aCabec, {"QTDE COMPRAS",		"N", 06, 0} )
				AADD( _aCabec, {"PRODUTO",			"C", 15, 0} )
				AADD( _aCabec, {"DESCRICAO",		"C", 60, 0} )
				AADD( _aCabec, {"VALOR TOTAL",		"N", 12, 2} )
				AADD( _aCabec, {"DATA EMISSAO",		"D", 08, 0} )
				AADD( _aCabec, {"PEDIDO",			"C", 06, 0} )
				AADD( _aCabec, {"USUARIO",			"C", 30, 0} )
				U_GERAEXCEL(_cNomArq, _aDados, _aCabec, .T.)
			Endif

		CASE MV_PAR05 == 3		// POR FORNECEDOR
			If Len(_aDados) > 0
				AADD( _aCabec, {"FORNECEDOR",		"C", 06, 0} )
				AADD( _aCabec, {"LOJA",				"C", 02, 0} )
				AADD( _aCabec, {"RAZAO SOCIAL",		"C", 40, 0} )
				AADD( _aCabec, {"VALOR TOTAL",		"N", 12, 2} )
				U_GERAEXCEL(_cNomArq, _aDados, _aCabec, .T.)
			Endif
	ENDCASE

Return


//--------------------------------------------------------------------------------------
/*/{Protheus.doc} _UsrName
@Description	: Função chamada externamente, pois não permite execuçao de API em Loop
                  devido os SXs estarem sendo utilizados no banco de dados
@Param			: _cCodUser - Código do Usuário
@Return			: _NomeUser - Nome Completo do Usuário
@Author			: Evandro Mugnol
@Since			: Abr/2023
/*/
//--------------------------------------------------------------------------------------
Static Function _UsrName(_cCodUser)

	_NomeUser := FwGetUserName(_cCodUser)

Return(_NomeUser)
