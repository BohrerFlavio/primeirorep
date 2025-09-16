#INCLUDE "PROTHEUS.CH"
#INCLUDE "RWMAKE.CH"
#INCLUDE "TOPCONN.CH"                           

/*/{Protheus.doc} STI_R503
Relatório de controle de produção dos bifes comparando solicitado X produzido.
@author 	Evandro Mugnol
@since 		Nov/2018
@return 	Nil, Função não tem retorno
@obs 		N/A
/*/

User Function STI_R503()

	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Variaveis obrigatorias dos programas de relatorio            ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	cString  := "SZZ"
	cDesc1   := "Este programa tem como objetivo, Imprimir o relatório de "
	cDesc2   := "controle de produção bifes efetuando um comparativo entre"
	cDesc3   := "solicitado X produzido"
	tamanho  := "M"
	aReturn  := {"Zebrado", 1,"Administracao", 1, 2, 1, "",1}
	aLinha   := {}
	nLastKey := 0
	cPerg    := "STI_R503"
	titulo   := "Controle Produção Bifes"
	wnrel    := "STI_R503"
	nTipo    := 0

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
	titulo := "Controle Produção Solicitado X Produzido em " + DTOC(MV_PAR01)

	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Cria o cabecalho.                                        ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	cabec1 := "                                                                        C A I X A S                    P E S O       "
	cabec2 := "P  R  O  D  U  T  O                                                SOLICITADO  PRODUZIDO       SOLICITADO   PRODUZIDO"
	//***      XXXXXX X----------------------------------------------------------X  XXX.XXX   XXX.XXX         XXX.XXX,XX  XXX.XXX,XX 
	//***                1         2         3         4         5         6         7         8         9        10        11  
	//***      01234567890123456789012345678901234567890123456789012345678901234567890123456789012345678901234567890123456789012

	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Seleção de dados ref. solicitação produção F9            ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	cQuery1 := " SELECT ZZ_CODPRD, SUM(ZZ_QTDPES) AS PESOSOL, SUM(ZZ_QTDSOL) AS CAIXSOL" 
	cQuery1 += "   FROM " + RetSqlTab("SZZ") 
	cQuery1 += "  WHERE " + RetSqlFil("SZZ") 
	cQuery1 += "    AND ZZ_DTSPOR = '" + DTOS(MV_PAR01) + "'"
	cQuery1 += "    AND " + RetSqlDel("SZZ")
	cQuery1 += "  GROUP BY ZZ_CODPRD"
	cQuery1 += "  ORDER BY ZZ_CODPRD"

	cQuery1 := ChangeQuery(cQuery1)

	If Select("TRB1") != 0
		TRB1 -> (DbCloseArea())
	Endif

	TCQUERY cQuery1 NEW ALIAS "TRB1"

	_nTotCaxS := 0
	_nTotCaxP := 0
	_nTotPesS := 0
	_nTotPesP := 0
	
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Impressão dos Dados                                      ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	DbSelectArea("TRB1")
	DbGoTop()
	SetRegua(RecCount())
	Do While ! TRB1 -> (Eof ())
		IncRegua()

		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³ Seleção de dados ref. produzidos                         ³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		cQuery2 := " SELECT Z8_COD, SUM(Z8_PESO) AS PESOP, COUNT(*) AS CAIXP "
		cQuery2 += " FROM " + RetSqlTab("SZ8") + ", " + RetSqlTab("SBM")  + ", " + RetSqlTab("SB1")
		cQuery2 += " WHERE "
		cQuery2 += RetSQLFil('SB1') + " AND"
		cQuery2 += RetSQLFil('SBM') + " AND"
		cQuery2 += RetSQLFil('SZ8') + " AND"
		cQuery2 += " Z8_FILORI = '" + cFilAnt + "' AND  B1_TIPO = 'PA' AND B1_COD = Z8_COD AND "
		cQuery2 += " Z8_DATA = '" + DTOS(MV_PAR01) + "' AND"
		cQuery2 += " B1_COD = '" + TRB1->ZZ_CODPRD + "' AND "
		cQuery2 += " Z8_DATAE = ' ' AND BM_GRUPO = B1_GRUPO AND BM_PORC = 'S' AND "
		cQuery2 += RetSQLDel('SB1') + " AND " + RetSQLDel('SZ8') + " AND " + RetSQLDel('SBM')
		cQuery2 += " GROUP BY Z8_COD"
		cQuery2 += " ORDER BY Z8_COD"
	
		cQuery2 := ChangeQuery(cQuery2)

		If Select("TRB2") != 0
			TRB2 -> (DbCloseArea())
		Endif

		TCQUERY cQuery2 NEW ALIAS "TRB2"

		_nCaixP := 0
		_nPesoP := 0
		
		DbSelectArea("TRB2")
		DbGoTop()
		SetRegua(RecCount())
		Do While ! TRB2 -> (Eof ())
			_nCaixP += TRB2->CAIXP
			_nPesoP += TRB2->PESOP

			TRB2->(dbSkip())	 // Avanca o ponteiro do registro no arquivo 
		EndDo

		TRB2 -> (DbCloseArea())

		If nLin > 75
			Cabec(titulo,Cabec1,Cabec2,wnrel,tamanho,nTipo)
			nLin := 9
		Endif 

		DbSelectArea("TRB1")

		@ nLin, 000 PSAY Left(TRB1->ZZ_CODPRD,6)
		@ nLin, 007 PSAY Left(fBuscaCPO('SB1', 1, xFilial('SB1') + TRB1->ZZ_CODPRD, 'B1_DESC'),60)
		@ nLin, 069 PSAY Transform(TRB1->CAIXSOL, '@E 999,999')
		@ nLin, 080 PSAY Transform(_nCaixP      , '@E 999,999')
		@ nLin, 095 PSAY Transform(TRB1->PESOSOL, '@E 999,999.99')
		@ nLin, 107 PSAY Transform(_nPesoP      , '@E 999,999.99')
		nLin++ 

		_nTotCaxS += TRB1->CAIXSOL
		_nTotCaxP += _nCaixP
		_nTotPesS += TRB1->PESOSOL
		_nTotPesP += _nPesoP

		TRB1->(dbSkip())	 // Avanca o ponteiro do registro no arquivo 
	EndDo

	TRB1 -> (DbCloseArea())

	If nLin > 75
		Cabec(titulo,Cabec1,Cabec2,wnrel,tamanho,nTipo)
		nLin := 9
	Endif 

	@ nLin, 067 PSAY "======================="
	@ nLin, 094 PSAY "======================="
	nLin++
	@ nLin, 050 PSAY "T O T A I S ==> "
	@ nLin, 069 PSAY Transform(_nTotCaxS, '@E 999,999')
	@ nLin, 080 PSAY Transform(_nTotCaxP, '@E 999,999')
	@ nLin, 095 PSAY Transform(_nTotPesS, '@E 999,999.99')
	@ nLin, 107 PSAY Transform(_nTotPesp, '@E 999,999.99')

	Set Device To Screen

	If aReturn[5]==1
		Set Printer TO
		dbcommitAll()
		ourspool(wnrel)
	Endif

	MS_FLUSH()   // Libera fila de relatorios em spool (Tipo Rede Netware)
Return
