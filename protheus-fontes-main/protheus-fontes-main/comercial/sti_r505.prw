#INCLUDE "PROTHEUS.CH"
#INCLUDE "RWMAKE.CH"
#INCLUDE "TOPCONN.CH"                           

/*/{Protheus.doc} STI_R505
Relatório de faturamento correlação produto alternativo e produto.
@author 	Evandro Mugnol
@since 		Dez/2018
@return 	Nil, Função não tem retorno
@obs 		N/A
/*/

User Function STI_R505()

	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Variaveis obrigatorias dos programas de relatorio            ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	cString  := "ZZ4"
	cDesc1   := "Este programa tem como objetivo, Imprimir o relatório de "
	cDesc2   := "faturamento conforme correlação de produto alternativo e "
	cDesc3   := "produto selecionados nos parâmetros pelo usuário."
	tamanho  := "M"
	aReturn  := {"Zebrado", 1,"Administracao", 1, 2, 1, "",1}
	aLinha   := {}
	nLastKey := 0
	cPerg    := "STI_R505"
	titulo   := "Faturamento Correlação Produto Alternativo e Produto"
	wnrel    := "STI_R505"
	nTipo    := 0
	cCorre 	 := ""

	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Perguntas no Arquivo SX1                                     ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	Pergunte(cPerg,.F.)

	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Envia controle para a funcao SETPRINT                        ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	wnrel:=SetPrint(cString,wnrel,cPerg,titulo,cDesc1,cDesc2,cDesc3,.F.)

	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Seleciona Correlação Produto Alternativo e Produto           ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	_SelCorrel()

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
	titulo := "Faturamento Correlação Produto Alternativo e Produto De " + DTOC(MV_PAR01) + " Até " + DTOC(MV_PAR02) 

	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Cria o cabecalho.                                        ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	cabec1 := "                                                                                QTDE           PESO     VALOR TOTAL       "
	cabec2 := "P  R  O  D  U  T  O                                                              CXS            (Kg)            (R$)      "
	//***      XXXXXX X----------------------------------------------------------X          XXX.XXX      XXX.XXX,XX    X.XXX.XXX,XX     
	//***                1         2         3         4         5         6         7         8         9        10        11  
	//***      01234567890123456789012345678901234567890123456789012345678901234567890123456789012345678901234567890123456789012

	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Seleção de dados ref. correlações                        ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	cQuery1 := "SELECT ZE0_COD, ZE1_CODZE0, ZE1_CODPRD" 
	cQuery1 += "  FROM " + RetSQLTab("ZE0") + "," + RetSQLTab("ZE1")
	cQuery1 += " WHERE " + RetSQLFil("ZE0") + " AND " + RetSQLFil("ZE1")
	cQuery1 += "   AND ZE0_COD = ZE1_CODZE0
	cQuery1 += "   AND ZE0_COD IN " + FORMATIN(cCorre,"/")
	cQuery1 += "   AND " + RetSQLDel("ZE0") + " AND " + RetSQLDel("ZE1")
	cQuery1 += " ORDER BY ZE1_CODPRD"

	cQuery1 := ChangeQuery(cQuery1)
	
	//memowrite("ZZZ_STI_R505A.TXT",cQuery1)

	If Select("TRB1") != 0
		TRB1 -> (DbCloseArea())
	Endif

	TCQUERY cQuery1 NEW ALIAS "TRB1"

	DbSelectArea("TRB1")
	DbGoTop()
	SetRegua(RecCount())
	cProds := ""
	Do While ! TRB1 -> (Eof ())
		IncRegua()

		cProds += TRB1->ZE1_CODPRD + "/"

		TRB1->(dbSkip())	 // Avanca o ponteiro do registro no arquivo 
	EndDo

	TRB1 -> (DbCloseArea())


	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Seleção de dados ref. faturamento                        ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	cQuery2 := "SELECT A1_COD, A1_LOJA, ZZ5_COD AS COD,  SUM(ZZ5_QRCAIX) AS PECAVEN, SUM(ZZ5_QRPESO) AS PESOVEN, SUM(ZZ5_PRCFIN * ZZ5_QRPESO) AS VALORVEN" 
	cQuery2 += "  FROM " + RetSQLTab("ZZ4") + "," + RetSQLTab("ZZ5") + "," + RetSQLTab("SA1") + "," + RetSQLTab("SB1")
	cQuery2 += " WHERE " + RetSQLFil("ZZ4") + " AND " + RetSQLFil("ZZ5") + " AND " + RetSQLFil("SA1") + " AND " + RetSQLFil("SB1")
	cQuery2 += "   AND ZZ4_NUM = ZZ5_NUM
	cQuery2 += "   AND ZZ4_CODCLI = A1_COD
	cQuery2 += "   AND ZZ4_LOJA = A1_LOJA
	cQuery2 += "   AND ZZ5_COD = B1_COD
	cQuery2 += "   AND ZZ4_TPOPER = 'V'"
	cQuery2 += "   AND ZZ4_STATUS = 'F'"
	cQuery2 += "   AND ZZ4_DATAPV BETWEEN '" + DTOS(mv_par01) + "' AND '" + DTOS(mv_par02) + "'"
	cQuery2 += "   AND ZZ4_CODCLI BETWEEN '" + mv_par03 + "' AND '" + mv_par04 + "'"
	cQuery2 += "   AND ZZ5_COD IN " + FORMATIN(cProds,"/")
	cQuery2 += "   AND " + RetSQLDel("ZZ4") + " AND " + RetSQLDel("ZZ5") + " AND " + RetSQLDel("SA1") + " AND " + RetSQLDel("SB1")
	cQuery2 += "  GROUP BY A1_COD, A1_LOJA, ZZ5_COD"
	cQuery2 += "  ORDER BY A1_COD, A1_LOJA, ZZ5_COD"

	cQuery2 := ChangeQuery(cQuery2)
	
	//memowrite("ZZZ_STI_R505B.TXT",cQuery2)

	If Select("TRB1") != 0
		TRB2 -> (DbCloseArea())
	Endif

	TCQUERY cQuery2 NEW ALIAS "TRB2"


	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Gera arquivo de Trabalho                                     ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	_aArqTrb := {}
	aCampos := {}
	AADD(aCampos,{"CODZE0", "C", 06, 0})
	AADD(aCampos,{"CODCLI", "C", 06, 0})
	AADD(aCampos,{"LOJCLI", "C", 02, 0})
	AADD(aCampos,{"CODPRD", "C", 15, 0})
	AADD(aCampos,{"QTDCXS", "N", 06, 0})
	AADD(aCampos,{"QTDPES", "N", 10, 2})
	AADD(aCampos,{"VLRTOT", "N", 12, 2})

	//cNomeArq:=CriaTrab(aCampos)
	//dbUseArea( .T.,, cNomeArq, "cNomeArq", if(.F. .OR. .F., !.F., NIL), .F. )
	//If mv_par05 == 2	// Não Aglutina
	//	IndRegua("cNomeArq",cNomeArq,"CODZE0+CODCLI+LOJCLI+CODPRD",,,OemToAnsi("Selecionando Registros..."))
	//Else
	//	IndRegua("cNomeArq",cNomeArq,"CODZE0+CODCLI+CODPRD",,,OemToAnsi("Selecionando Registros..."))
	//Endif
	
	If Select('TMP')<>0                                                           //Se um tmp com alias TMP existir, fecha-o
		TMP->(dbCloseArea())
		u_arqtrb ("FechaTodos",,,, @_aArqTrb)
	Endif

	If mv_par05 == 2	// Não Aglutina	
		U_ArqTrb("Cria", "TMP", aCampos, {"CODZE0","CODCLI","LOJCLI","CODPRD"}, @_aArqTrb)
	Else
		U_ArqTrb("Cria", "TMP", aCampos, {"CODZE0","CODCLI","CODPRD"}, @_aArqTrb)
	EndIf

	DbSelectArea("TRB2")
	DbGoTop()
	SetRegua(RecCount())
	Do While ! TRB2 -> (Eof ())
		IncRegua()

		DbSelectArea("ZE1")
		DbSetOrder(2)
		DbSeek(xFilial("ZE1") + TRB2->COD)
		If Found()
			_cCodZE0 := ZE1->ZE1_CODZE0
		Else
			MsgAlert("Não Encontrado Produto " + AllTrim(TRB2->COD) + ". Entrar em Contato com DTI.")
			_cCodZE0 := "???????????????"
		Endif

		// GRAVA ARQUIVO DE TRABALHO
		DbSelectArea("TMP")
		DbSetOrder(1)
		If mv_par05 == 2	// Não Aglutina
			DbSeek(_cCodZE0 + TRB2->A1_COD + TRB2->A1_LOJA + TRB2->COD)
		Else
			DbSeek(_cCodZE0 + TRB2->A1_COD + TRB2->COD)
		Endif
		If !Found()
			Reclock("TMP",.T.)
			TMP->CODZE0 := _cCodZE0
			TMP->CODCLI := TRB2->A1_COD
			TMP->LOJCLI := IIF(mv_par05 == 2, TRB2->A1_LOJA, "") 
			TMP->CODPRD := TRB2->COD
			TMP->QTDCXS := TRB2->PECAVEN
			TMP->QTDPES := TRB2->PESOVEN
			TMP->VLRTOT := TRB2->VALORVEN
			MsUnlock()
		Else
			Reclock("TMP",.F.)
			TMP->QTDCXS := QTDCXS + TRB2->PECAVEN
			TMP->QTDPES := QTDPES + TRB2->PESOVEN
			TMP->VLRTOT := VLRTOT + TRB2->VALORVEN
			MsUnlock()
		Endif

		TRB2->(dbSkip())	 // Avanca o ponteiro do registro no arquivo 
	EndDo

	TRB2 -> (DbCloseArea())


	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Impressão dos Dados                                      ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	_zCodZE0  := "######"
	If mv_par05 == 2	// Não Aglutina
		_zClient := "########"
	Else
		_zClient := "######"
	Endif
	_nVez 	  := 1
	_nTotCCxs := 0
	_nTotCPes := 0
	_nTotCVlr := 0
	_nTotGCxs := 0
	_nTotGPes := 0
	_nTotGVlr := 0

	DbSelectArea("TMP")
	DbGotop()
	SetRegua(RecCount())
	Do While !Eof()
		IncRegua()

		If _zCodZE0 <> CODZE0
			If nLin > 75
				Cabec(titulo,Cabec1,Cabec2,wnrel,tamanho,nTipo)
				nLin := 8
			Endif 

			If _nVez <> 1
				@ nLin, 077 PSAY Replicate("=", 47)
				nLin++
				@ nLin, 048 PSAY "T O T A L  Grupo ==>" 
				@ nLin, 077 PSAY Transform(_nTotCCxs, "@E 999,999")
				@ nLin, 090 PSAY Transform(_nTotCPes, "@E 999,999.99")
				@ nLin, 103 PSAY Transform(_nTotCVlr, "@E 9,999,999.99")
				_nTotCCxs := 0
				_nTotCPes := 0
				_nTotCVlr := 0
			Endif
			_nVez := 2

			nLin++
			@ nLin, 000 PSAY Replicate("-", 132)
			nLin++
			@ nLin, 000 PSAY CODZE0 + " - " + fBuscaCpo("ZE0", 1, xFilial("ZE0") + CODZE0, "ZE0_DESCRI")
			nLin++
			@ nLin, 000 PSAY Replicate("-", 132)
			_zCodZE0 := CODZE0
			If mv_par05 == 1	// Aglutina
				_zClient := "######"
			Endif
		Endif
		
		If _zClient <> IIF(mv_par05 == 2, CODCLI + LOJCLI, CODCLI)
			If nLin > 75
				Cabec(titulo,Cabec1,Cabec2,wnrel,tamanho,nTipo)
				nLin := 8
			Endif 

			nLin++
			If mv_par05 == 2	// Não Aglutina
				@ nLin, 000 PSAY "CLI=> " + CODCLI + "-" + LOJCLI + "   " + fBuscaCpo("SA1", 1, xFilial("SA1") + CODCLI + LOJCLI, "A1_NOME")
			Else
				@ nLin, 000 PSAY "CLI=> " + CODCLI + "   " + fBuscaCpo("SA1", 1, xFilial("SA1") + CODCLI, "A1_NOME")
			Endif
			nLin++
			_zClient := IIF(mv_par05 == 2, CODCLI + LOJCLI, CODCLI)
		Endif
		
		@ nLin, 000 PSAY Left(CODPRD,6) + "  " + Left(fBuscaCPO("SB1", 1, xFilial("SB1") + Alltrim(CODPRD), "B1_DESC"),60)
		@ nLin, 077 PSAY Transform(QTDCXS, "@E 999,999")	
		@ nLin, 090 PSAY Transform(QTDPES, "@E 999,999.99") 
		@ nLin, 103 PSAY Transform(VLRTOT, "@E 9,999,999.99") 
		nLin++

		_nTotCCxs += QTDCXS
		_nTotCPes += QTDPES
		_nTotCVlr += VLRTOT
		_nTotGCxs += QTDCXS
		_nTotGPes += QTDPES
		_nTotGVlr += VLRTOT

		DbSelectArea("TMP")
		DbSkip()
	EndDo

	If nLin > 75
		Cabec(titulo,Cabec1,Cabec2,wnrel,tamanho,nTipo)
		nLin := 8
	Endif 

	@ nLin, 077 PSAY Replicate("=", 47)
	nLin++
	@ nLin, 048 PSAY "T O T A L  Grupo ==>" 
	@ nLin, 077 PSAY Transform(_nTotCCxs, "@E 999,999")
	@ nLin, 090 PSAY Transform(_nTotCPes, "@E 999,999.99")
	@ nLin, 103 PSAY Transform(_nTotCVlr, "@E 9,999,999.99")
	nLin++
	nLin++

	@ nLin, 077 PSAY Replicate("=", 47)
	nLin++
	@ nLin, 048 PSAY "T O T A L  Geral ==>" 
	@ nLin, 077 PSAY Transform(_nTotGCxs, "@E 999,999")
	@ nLin, 090 PSAY Transform(_nTotGPes, "@E 999,999.99")
	@ nLin, 103 PSAY Transform(_nTotGVlr, "@E 9,999,999.99")
	
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³Apaga arquivo e indice temporario ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	//dbSelectArea("TMP")
	//dbCloseArea()
	//Ferase(TMP+GetDBExtension())
	//Ferase(TMP+OrdBagExt())

	TMP->(dbCloseArea())
	u_arqtrb ("FechaTodos",,,, @_aArqTrb)

	Set Device To Screen

	If aReturn[5]==1
		Set Printer TO
		dbcommitAll()
		ourspool(wnrel)
	Endif

	MS_FLUSH()   // Libera fila de relatorios em spool (Tipo Rede Netware)

Return


//-----------------------------------------------------------------------------------------------------
/*/{Protheus.doc} _SelCorrel
Função que monta tela para seleção das correlações a serem considerados no processamento 
@author 	Evandro Mugnol
@since 		Dez/2018
@version 	1.0	
/*/
//-----------------------------------------------------------------------------------------------------

Static Function _SelCorrel()

LOCAL cCapital
LOCAL nX
LOCAL cCad   := OemToAnsi("Seleção das Correlações")
LOCAL cAlias := Alias()
LOCAL oOk    := LoadBitmap( GetResources(), "LBOK" )
LOCAL oNo    := LoadBitmap( GetResources(), "LBNO" )
LOCAL oQual
LOCAL cVar   := "  "
LOCAL nOpca
LOCAL oDlg
LOCAL aCorrBack    := {}
LOCAL aCorrs       := {}
LOCAL lRunDblClick := .T.

If Upper(TcGetDb()) <> "AS/400"
	cQueryZE0 := "SELECT ZE0_COD, ZE0_DESCRI" 
	cQueryZE0 += "  FROM " + RetSQLTab("ZE0")
	cQueryZE0 += " WHERE " + RetSQLFil("ZE0")
	cQueryZE0 += "   AND " + RetSQLDel("ZE0")
	cQueryZE0 += "  ORDER BY ZE0_COD"

	cQueryZE0 := ChangeQuery(cQueryZE0)

	If Select("ZE0QRY") > 0
		dbSelectArea("ZE0QRY")
		dbCloseArea()
	Endif

	dbUseArea(.T., "TOPCONN", TCGenQry(,,cQueryZE0), "ZE0QRY", .F., .T.)
	ZE0QRY->(dbGoTop())
	While ZE0QRY->(!Eof())
		Aadd(aCorrs,{.T., ZE0QRY->ZE0_COD + " / " + ZE0QRY->ZE0_DESCRI})
		ZE0QRY->(dbSkip())
	EndDo
EndIf

aCorrBack := aClone(aCorrs)
nOpca := 0
DEFINE MSDIALOG oDlg TITLE cCad From 9,0 To 35,50 OF oMainWnd

@ 0.5, 0.3 TO 13.6, 20.0 LABEL cCad OF oDlg
@ 2.3, 3 Say OemToAnsi("  ")
@ 1.0, .7 LISTBOX oQual VAR cVar Fields HEADER "",OemToAnsi("Seleção das Correlações")  SIZE 150,170 ON DBLCLICK (aCorrBack:=Sel31Troca(oQual:nAt,aCorrBack),oQual:Refresh()) NOSCROLL
oQual:SetArray(aCorrBack)
oQual:bLine := { || {if(aCorrBack[oQual:nAt,1],oOk,oNo),aCorrBack[oQual:nAt,2]}}
oQual:bHeaderClick := {|oObj,nCol| If(lRunDblClick .And. nCol==1, aEval(aCorrBack, {|e| e[1] := !e[1]}),Nil), lRunDblClick := !lRunDblClick, oQual:Refresh()}

DEFINE SBUTTON FROM 10  ,166  TYPE 1 ACTION (nOpca := 1,oDlg:End()) ENABLE OF oDlg
DEFINE SBUTTON FROM 22.5,166  TYPE 2 ACTION oDlg:End() ENABLE OF oDlg

ACTIVATE MSDIALOG oDlg

IF nOpca == 1
	aCorrs := Aclone(aCorrBack)
Endif

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Monta a string das correlações para filtrar                  ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
cCorre := ""
For nX := 1 To Len(aCorrs)
	If aCorrs[nX,1]
		cCorre += SubStr(aCorrs[nX,2],1,6) + "/"
	End
Next nX
DeleteObject(oOk)
DeleteObject(oNo)

dbSelectArea(cAlias)

Return


//-----------------------------------------------------------------------------------------------------
/*/{Protheus.doc} Sel31Troca
Função de inversão de marcação ligada a SelCorrel() 
@author 	Evandro Mugnol
@since 		Dez/2018
@version 	1.0	
/*/
//-----------------------------------------------------------------------------------------------------
Static Function Sel31Troca(nIt,aArray)

aArray[nIt,1] := !aArray[nIt,1]

Return aArray
