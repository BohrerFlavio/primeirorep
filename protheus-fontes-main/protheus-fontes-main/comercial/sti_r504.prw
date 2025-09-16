#INCLUDE "PROTHEUS.CH"
#INCLUDE "RWMAKE.CH"
#INCLUDE "TOPCONN.CH"                           

/*/{Protheus.doc} STI_R504
Relatório de preço médio de venda desconsiderando desconto rapel do cliente.
@author 	Evandro Mugnol
@since 		Nov/2018
@return 	Nil, Função não tem retorno
@obs 		N/A
/*/

User Function STI_R504()

	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Variaveis obrigatorias dos programas de relatorio            ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	cString  := "ZZ4"
	cDesc1   := "Este programa tem como objetivo, Imprimir o relatório de "
	cDesc2   := "preço médio de venda da carne conforme parâmetros defini-"
	cDesc3   := "dos pelo usuário."
	tamanho  := "M"
	aReturn  := {"Zebrado", 1,"Administracao", 1, 2, 1, "",1}
	aLinha   := {}
	nLastKey := 0
	cPerg    := "STI_R504"
	titulo   := "Preço Médio (- Rapel)"
	wnrel    := "STI_R504"
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
	titulo := "Preço Médio (- Rapel) De " + DTOC(MV_PAR01) + " Até " + DTOC(MV_PAR02) 

	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Cria o cabecalho.                                        ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	cabec1 := "                                                                      QTDE            PESO     VALOR TOTAL     PREÇO MÉDIO"
	cabec2 := "P  R  O  D  U  T  O                                                  PEÇAS            (Kg)            (R$)            (R$)"
	//***      XXXXXX X----------------------------------------------------------XXXX.XXX      XXX.XXX,XX    X.XXX.XXX,XX     XXX.XXX,XX     
	//***                1         2         3         4         5         6         7         8         9        10        11  
	//***      01234567890123456789012345678901234567890123456789012345678901234567890123456789012345678901234567890123456789012

	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Seleção de dados ref. solicitação produção F9            ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	cQuery1 := "SELECT ZZ5_COD AS COD, A1_COD,A1_LOJA, SUM(ZZ5_QRCAIX) AS PECAVEN, SUM(ZZ5_QRPESO) AS PESOVEN, SUM(ZZ5_PRCFIN * ZZ5_QRPESO) AS VALORVEN" 
	cQuery1 += "  FROM " + RetSQLTab("ZZ4") + "," + RetSQLTab("ZZ5") + "," + RetSQLTab("SA1") + "," + RetSQLTab("SB1")
	cQuery1 += " WHERE	" + RetSQLFil("ZZ4") + " AND " + RetSQLFil("ZZ5") + " AND " + RetSQLFil("SA1") + " AND " + RetSQLFil("SB1")
	cQuery1 += "   AND ZZ4_NUM = ZZ5_NUM
	cQuery1 += "   AND ZZ4_CODCLI = A1_COD
	cQuery1 += "   AND ZZ4_LOJA = A1_LOJA
	cQuery1 += "   AND ZZ5_COD = B1_COD
	cQuery1 += "   AND ZZ4_TPOPER = 'V'"
	cQuery1 += "   AND ZZ4_STATUS = 'F'"
	cQuery1 += "   AND ZZ4_DATAPV BETWEEN '" + DTOS(mv_par01) + "' AND '" + DTOS(mv_par02) + "'"
	cQuery1 += "   AND ZZ5_COD BETWEEN '" + mv_par03 + "' AND '" + mv_par04 + "'"
	cQuery1 += "   AND " + RetSQLDel("ZZ4") + " AND " + RetSQLDel("ZZ5") + " AND " + RetSQLDel("SA1") + " AND " + RetSQLDel("SB1")
	cQuery1 += "  GROUP BY ZZ5_COD, A1_COD, A1_LOJA"
	cQuery1 += "  ORDER BY ZZ5_COD, A1_COD, A1_LOJA"

	cQuery1 := ChangeQuery(cQuery1)
	
	//memowrite("ZZZ_STI_R504.TXT",cQuery1)

	If Select("TRB1") != 0
		TRB1 -> (DbCloseArea())
	Endif

	TCQUERY cQuery1 NEW ALIAS "TRB1"

	_nTotQnt := 0
	_nTotPes := 0
	_nTotVal := 0
	_nPrcMed := 0	
	_nTotGerQnt := 0
	_nTotGerPes := 0
	_nTotGerVal := 0
	_nPrcTotMed := 0	
	
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Impressão dos Dados                                      ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	DbSelectArea("TRB1")
	DbGoTop()
	SetRegua(RecCount())
	Do While ! TRB1 -> (Eof ())
		IncRegua()

		If nLin > 75
			Cabec(titulo,Cabec1,Cabec2,wnrel,tamanho,nTipo)
			nLin := 9
		Endif 

		_cCodPro := TRB1->COD
		_nValRap := fBuscaCPO("SA1", 1, xFilial("SA1") + TRB1->A1_COD + TRB1->A1_LOJA, "A1_PRAPEL") / 100

		If _nValRap > 0
			_nTotVal += IIF(_nValRap <> 0, TRB1->VALORVEN * (1 - _nValRap), TRB1->VALORVEN)
		Else
			_nTotVal += TRB1->VALORVEN 
		Endif                                 
		
		_nTotPes += TRB1->PESOVEN                                                                 
		_nTotQnt += TRB1->PECAVEN 
 
		If _nValRap > 0
			_nTotGerVal += IIF(_nValRap <> 0, TRB1->VALORVEN * (1 - _nValRap), TRB1->VALORVEN)
		Else
			_nTotGerVal += TRB1->VALORVEN
		Endif	

 		_nTotGerPes += TRB1->PESOVEN 
		_nTotGerQnt += TRB1->PECAVEN
   
		TRB1->(dbSkip())	 // Avanca o ponteiro do registro no arquivo 

		If _cCodPro <> TRB1->COD .Or. TRB1-> ( Eof() )
			_nPrcMed := (_nTotVal / _nTotPes) 

			@ nLin, 000 PSAY Left(_cCodPro,6) 
			@ nLin, 007 PSAY Left(fBuscaCPO('SB1', 1, xFilial('SB1') + _cCodPro, 'B1_DESC'),60)                    
			@ nLin, 067 PSAY Transform(_nTotQnt, "@E 999,999")	
			@ nLin, 080 PSAY Transform(_nTotPes, "@E 999,999.99") 
			@ nLin, 093 PSAY Transform(_nTotVal, "@E 9,999,999.99") 
			@ nLin, 112 PSAY Transform(_nPrcMed, "@E 999,999.99")
			nLin++

			_nTotQnt := 0
			_nTotPes := 0
			_nTotVal := 0
			_nPrcMed := 0	
		Endif
	EndDo

	TRB1 -> (DbCloseArea())

	If nLin > 75
		Cabec(titulo,Cabec1,Cabec2,wnrel,tamanho,nTipo)
		nLin := 9
	Endif 

	_nPrcTotMed := (_nTotGerVal / _nTotGerPes)

	If nLin > 75
		Cabec(titulo,Cabec1,Cabec2,wnrel,tamanho,nTipo)
		nLin := 9
	Endif 

	@ nLin, 067 PSAY Replicate("=", 57)
	nLin++
	@ nLin, 038 PSAY "MÉDIA  T O T A L ==>" 
	@ nLin, 067 PSAY Transform(_nTotGerQnt, "@E 999,999")
	@ nLin, 080 PSAY Transform(_nTotGerPes, "@E 999,999.99")
	@ nLin, 093 PSAY Transform(_nTotGerVal, "@E 9,999,999.99")
	@ nLin, 112 PSAY Transform(_nPrcTotMed, "@E 999,999.99")

	Set Device To Screen

	If aReturn[5]==1
		Set Printer TO
		dbcommitAll()
		ourspool(wnrel)
	Endif

	MS_FLUSH()   // Libera fila de relatorios em spool (Tipo Rede Netware)
Return
