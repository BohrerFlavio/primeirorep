#INCLUDE "rwmake.ch"
#INCLUDE "topconn.ch"

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³GJF100  º Autor ³ Giuliano Forgiarini  º Data ³  18/11/09   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDescricao ³ Relatorio distribuição de carcaças por classificações      º±±
±±º          ³ Que estão em estoque                                       º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ Comercial e PCP (SIGAPCP)                                  º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/

User Function GJF100()

	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Declaracao de Variaveis                                             ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ

	Local cDesc1         := "Este programa tem como objetivo imprimir relatorio   "
	Local cDesc2         := "de carcaças produzidas no abate distribuidas por suas"
	Local cDesc3         := "variadas classificações, algutinando suas quantidades"
	Local cPict          := "para utilização do PCP na programação da produção."
	Local titulo         := "DISTRIBUIÇÃO CARCAÇAS"
	Local nLin         := 80

	Local Cabec1       := " Categoria        Classificação   Carcaças   Tras.  Diant.  Cost. Dent.  Gord."                   
	Local Cabec2       := "     Programa                                               "

	//Local imprime      := .T.
	Local aOrd := {}
	Private lEnd         := .F.
	Private lAbortPrint  := .F.
	Private CbTxt        := ""
	Private limite           := 80
	Private tamanho          := "P"
	Private nomeprog         := "GJF100" // Coloque aqui o nome do programa para impressao no cabecalho
	Private nTipo            := 18
	Private aReturn          := { "Zebrado", 1, "Administracao", 2, 2, 1, "", 1}
	Private nLastKey        := 0
	Private cPerg   := "GJF100"
	Private cbtxt      := Space(10)
	Private cbcont     := 00
	Private CONTFL     := 01
	Private m_pag      := 01
	Private wnrel      := "GJF100" // Coloque aqui o nome do arquivo usado para impressao em disco    
	Private TotCaix    := 0.00
	Private TotPeso    := 0.00

	pergunte(cPerg,.F.)

	//para verificação se existe previsao de pesagem

	wnrel := SetPrint('SZK',NomeProg,cPerg,@titulo,cDesc1,cDesc2,cDesc3,.T.,aOrd,.T.,Tamanho,,.T.)

	cQuery := " SELECT  ZK_CATEG, ZK_PROGRAM, ZK_CLASSIF, ZK_TIPIFI, ZK_DENT AS ZK_DENT, ZK_COBGOR AS ZK_GOR,COUNT(ZK_NUMAM) AS ZK_NCARC"

	cQuery += " FROM " + RetSqlTab("SZK") + " 
	cQuery += " WHERE  " + REtSQLFil('SZK') + " AND "
	cQuery += " ZK_NUMAM = '" + mv_par01 + "'" 

	cQuery += " AND " + RetSQLDel('SZK')	
	cQuery += " GROUP BY ZK_CATEG,ZK_PROGRAM, ZK_CLASSIF, ZK_TIPIFI,ZK_DENT,ZK_COBGOR" 
	cQuery += " ORDER BY ZK_CATEG,ZK_PROGRAM, ZK_CLASSIF, ZK_TIPIFI,ZK_DENT,ZK_COBGOR"

	cQuery := ChangeQuery(cQuery)

	//	* Mostrar a consulta */
	//@ 116,090 To 416,707 Dialog oDlgMemo Title "Consulta"
	//@ 055,005 Get cQuery Size 250,080 MEMO Object oMemo
	//Activate Dialog oDlgMemo
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Monta a interface padrao com o usuario...                           ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ

	If Select("TMP") != 0
		TMP->(dbCloseArea())
	Endif
	TCQUERY cQuery NEW ALIAS "TMP"


	If nLastKey == 27
		Return
	Endif

	SetDefault(aReturn,'SZK')

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
	Local _cCateg := ''
	Local _cDCat  := ''
	Local _cProg  := ''
	Local _cDProg := ''
	//Local _cClass := ''
	//Local _cTip   := ''  
	Local _ll     := .f.

	Cabec(Titulo,Cabec1,Cabec2,NomeProg,Tamanho,nTipo)
	nLin := 9

	@nlin,01 psay 'AVISO DE MATANÇA: ' + mv_par01
	nlin++
	@nlin,01 psay 'Abate do Dia : '+ dtoc(fBuscaCPO('SZG',1,xfilial('SZG')+mv_par01,'ZG_DATA'))
	nlin++

	TMP->(dbGoTop())

	TMP->(SetRegua(RecCount()))

	While TMP->(!EOF())

		incregua()

		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³ Verifica o cancelamento pelo usuario...                             ³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ

		If lAbortPrint
			@nLin,00 PSAY "*** CANCELADO PELO OPERADOR ***"
			Exit
		Endif

		If nLin > 55 // Salto de Página. Neste caso o formulario tem 55 linhas...
			Cabec(Titulo,Cabec1,Cabec2,NomeProg,Tamanho,nTipo)
			nLin := 9
		Endif

		//Query para traseiros
		//////////////////////

		cQueryT := " SELECT  COUNT(*) AS NTRAS FROM " + RetSQLTab('ZAJ') + "," + RetSQLTab('SZK')
		cQueryT += " WHERE " + RetSQLFil('ZAJ') + " AND " + RetSQLFil('SZK') + " AND ZK_NUMAM = ZAJ_NUMAM AND ZK_CONTROL  = ZAJ_CONTRO AND "
		cQueryT += " ZK_CATEG = '" + TMP->ZK_CATEG + "' AND ZK_PROGRAM = '" + TMP->ZK_PROGRAM + "' AND ZK_CLASSIF = '" + TMP->ZK_CLASSIF + "' AND "
		cqueryT += " ZK_DENT = '" + TMP->ZK_DENT + "' AND ZK_COBGOR = '" + TMP->ZK_GOR + "' AND ZAJ_HORAS = '' AND ZAJ_DATAS = '' AND "
		cQueryT += " ZAJ_CORORI = 'T' AND ZAJ_REGORI = '0000000000' AND ZK_NUMAM = '" + mv_par01 + "' AND " + RetSQLDel('ZAJ')

		cQueryT := ChangeQuery(cQueryT)

		//	* Mostrar a consulta */
		//@ 116,090 To 416,707 Dialog oDlgMemo Title "Consulta"
		//@ 055,005 Get cQueryT Size 250,080 MEMO Object oMemo
		//Activate Dialog oDlgMemo
		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³ Monta a interface padrao com o usuario...                           ³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ

		If Select("TMPT") != 0
			TMPT->(dbCloseArea())
		Endif
		TCQUERY cQueryT NEW ALIAS "TMPT"

		_nTras := TMPT->NTRAS

		//query para dianteiros
		///////////////////////

		cQueryD := " SELECT  COUNT(*) AS NDIA FROM " + RetSQLTab('ZAJ') + "," + RetSQLTab('SZK')
		cQueryD += " WHERE " + RetSQLFil('ZAJ') + " AND " + RetSQLFil('SZK') + " AND ZK_NUMAM = ZAJ_NUMAM AND ZK_CONTROL  = ZAJ_CONTRO AND "
		cQueryD += " ZK_CATEG = '" + TMP->ZK_CATEG + "' AND ZK_PROGRAM = '" + TMP->ZK_PROGRAM + "' AND ZK_CLASSIF = '" + TMP->ZK_CLASSIF + "' AND "
		cqueryD += " ZK_DENT = '" + TMP->ZK_DENT + "' AND ZK_COBGOR = '" + TMP->ZK_GOR + "' AND ZAJ_HORAS = '' AND ZAJ_DATAS = '' AND "
		cQueryD += " ZAJ_CORORI = 'D' AND ZAJ_REGORI = '0000000000' AND ZK_NUMAM = '" + mv_par01 + "' AND " + RetSQLDel('ZAJ')

		cQueryD := ChangeQuery(cQueryD)

		//	* Mostrar a consulta */
		//@ 116,090 To 416,707 Dialog oDlgMemo Title "Consulta"
		//@ 055,005 Get cQueryT Size 250,080 MEMO Object oMemo
		//Activate Dialog oDlgMemo
		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³ Monta a interface padrao com o usuario...                           ³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ

		If Select("TMPD") != 0
			TMPD->(dbCloseArea())
		Endif
		TCQUERY cQueryD NEW ALIAS "TMPD"

		_nDia := TMPD->NDIA

		//query para costelas
		///////////////////////

		cQueryC := " SELECT  COUNT(*) AS NCOS FROM " + RetSQLTab('ZAJ') + "," + RetSQLTab('SZK')
		cQueryC += " WHERE " + RetSQLFil('ZAJ') + " AND " + RetSQLFil('SZK') + " AND ZK_NUMAM = ZAJ_NUMAM AND ZK_CONTROL  = ZAJ_CONTRO AND "
		cQueryC += " ZK_CATEG = '" + TMP->ZK_CATEG + "' AND ZK_PROGRAM = '" + TMP->ZK_PROGRAM + "' AND ZK_CLASSIF = '" + TMP->ZK_CLASSIF + "' AND "
		cqueryC += " ZK_DENT = '" + TMP->ZK_DENT + "' AND ZK_COBGOR = '" + TMP->ZK_GOR + "' AND ZAJ_HORAS = '' AND ZAJ_DATAS = '' AND "
		cQueryC += " ZAJ_CORORI = 'C' AND ZAJ_REGORI = '0000000000' AND ZK_NUMAM = '" + mv_par01 + "' AND " + RetSQLDel('ZAJ')

		cQueryC := ChangeQuery(cQueryC)

		//	* Mostrar a consulta */
		//@ 116,090 To 416,707 Dialog oDlgMemo Title "Consulta"
		//@ 055,005 Get cQueryT Size 250,080 MEMO Object oMemo
		//Activate Dialog oDlgMemo
		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³ Monta a interface padrao com o usuario...                           ³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ

		If Select("TMPC") != 0
			TMPC->(dbCloseArea())
		Endif
		TCQUERY cQueryC NEW ALIAS "TMPC"

		_nCos := TMPC->NCOS


		_cDCat  := 'Categoria: ' + fBuscaCPO('SZ5',1,xfilial('SZ5')+TMP->ZK_CATEG,'Z5_DESC')
		_cDProg := fBuscaCPO('SZ6',1,xfilial('SZ6')+TMP->ZK_PROGRAM,'Z6_DESC')

		if _cCateg <> TMP->ZK_CATEG
			nlin++
			@nlin,00 psay replicate('=',80)
			nlin++
			@nlin,001 psay _cDCat
			nlin++
			@nlin,00 psay replicate('=',80)
			_cCateg := TMP->ZK_CATEG
			_ll := .t.
			nlin++
		endif

		if _cProg <> TMP->ZK_PROGRAM
			if !_ll
				nlin++
				@nlin,00 psay replicate('-',80)
				nlin++
			endif
			_ll := .f.
			@nlin,005 psay iif(_cDProg <> ' ',_cDProg,'<Sem Programa>')
			_cProg := TMP->ZK_PROGRAM

		endif

		@nlin,025 psay TMP->ZK_CLASSIF
		@nlin,038 psay TMP->ZK_NCARC
		@nlin,046 psay _nTras
		@nlin,054 psay _nDia
		@nlin,062 psay _nCos
		@nlin,069 psay TMP->ZK_DENT
		@nlin,075 psay TMP->ZK_GOR
		nlin++

		TMP->(dbSkip()) // Avanca o ponteiro do registro no arquivo

	EndDo


	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Finaliza a execucao do relatorio...                                 ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ

	DbCloseArea('TMP')

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
