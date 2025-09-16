#INCLUDE "rwmake.ch"
#INCLUDE "topconn.ch"

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³DTI84   º Autor ³ Fabian Maurer  º Data ³  25/06/19         º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDescricao ³ Relatorio distribuição de carcaças por classificações      º±±
±±º          ³ e Data Que estão em estoque                                º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ Comercial e PCP (SIGAPCP)                                  º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/

User Function DTI84()


	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Declaracao de Variaveis                                             ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ

	Local cDesc1         := "Este programa tem como objetivo imprimir relatorio   "
	Local cDesc2         := "de carcaças produzidas no abate distribuidas por suas"
	Local cDesc3         := "variadas classificações, algutinando suas quantidades"
	Local cPict          := "para utilização do PCP na programação da produção."
	Local titulo         := "ESTOQUE DE CARCACAS"
	Local nLin           := 80
	Local Cabec1         := " Categoria          Classif.  Carcaças  Tras. Diant. Cost. TF. Cons. Dent.  Gord.  Dt. Abate       UY?        Camara"                   
	Local Cabec2         := "     Programa                                               "
	//Local imprime        := .T.
	Local aOrd           := {}
	Private lEnd         := .F.
	Private lAbortPrint  := .F.
	Private CbTxt        := ""
	Private limite       := 80
	Private tamanho      := "G"
	Private nomeprog     := "DTI84" // Coloque aqui o nome do programa para impressao no cabecalho
	Private nTipo        := 18
	Private aReturn      := { "Zebrado", 1, "Administracao", 2, 2, 1, "", 1}
	Private nLastKey     := 0
	Private cPerg   	 := "DTI84"
	Private cbtxt      	 := Space(10)
	Private cbcont     	 := 00
	Private CONTFL       := 01
	Private m_pag        := 01
	Private wnrel        := "DTI84" // Coloque aqui o nome do arquivo usado para impressao em disco    
	Private TotCaix      := 0.00
	Private TotPeso      := 0.00

	pergunte(cPerg,.F.)

	//para verificação se existe previsao de pesagem

	wnrel := SetPrint('SZK',NomeProg,cPerg,@titulo,cDesc1,cDesc2,cDesc3,.T.,aOrd,.T.,Tamanho,,.T.)

//	cQuery := " SELECT  ZK_CATEG, ZK_PROGRAM, ZK_CLASSIF, ZK_TIPIFI, ZK_DENT AS ZK_DENT, ZK_COBGOR AS ZK_GOR,COUNT(ZK_NUMAM) AS ZK_NCARC, ZK_NUMAM"
//	cQuery += " FROM " + RetSqlTab("SZK") + " 
//	cQuery += " WHERE  " + REtSQLFil('SZK') + " AND "
//	cQuery += " ZK_NUMAM BETWEEN '" + mv_par01 + "' AND '" + mv_par02 + "'" 
//	cQuery += " AND " + RetSQLDel('SZK')	
//	cQuery += " GROUP BY ZK_NUMAM,ZK_CATEG,ZK_PROGRAM, ZK_CLASSIF, ZK_TIPIFI,ZK_DENT,ZK_COBGOR" 
//	cQuery += " ORDER BY ZK_NUMAM,ZK_CATEG,ZK_PROGRAM, ZK_CLASSIF, ZK_TIPIFI,ZK_DENT,ZK_COBGOR"


	cQuery := " SELECT  ZK_CATEG, ZK_PROGRAM, ZK_CLASSIF, ZK_TIPIFI, ZK_DENT AS ZK_DENT, ZK_COBGOR AS ZK_GOR,COUNT(ZK_NUMAM) AS ZK_NCARC,ZK_DESTINO, ZK_NUMAM, ZK_CLASESP, ZG_DATA"
	cQuery += " FROM " + RetSqlTab("SZK") + ", " + retSqlTab('SZG') + " 
	cQuery += " WHERE  " + REtSQLFil('SZK') + " AND " + retSqlFil('SZG') 
	cQuery += " AND ZG_DATA BETWEEN '" + dtos(mv_par01) + "' AND '" + dtos(mv_par02) + "'" 
	cQuery += " AND ZK_NUMAM = ZG_NUMAM AND " + RetSQLDel('SZK') + " AND " + retSqlDel('SZG')	
	cQuery += " GROUP BY ZG_DATA,ZK_NUMAM,ZK_CATEG,ZK_PROGRAM, ZK_CLASSIF, ZK_DESTINO, ZK_TIPIFI,ZK_DENT,ZK_COBGOR,ZK_CLASESP" 
	cQuery += " ORDER BY ZG_DATA,ZK_NUMAM,ZK_CATEG,ZK_PROGRAM, ZK_CLASSIF, ZK_DESTINO, ZK_TIPIFI,ZK_DENT,ZK_COBGOR,ZK_CLASESP"

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
	Local _cNumam := ''  
	Local _ll     := .f.
	Local i

	Cabec(Titulo,Cabec1,Cabec2,NomeProg,Tamanho,nTipo)
	nLin := 9

	/*
	@nlin,01 psay 'AVISO DE MATANÇA: ' + mv_par01
	nlin++
	@nlin,01 psay 'Abate do Dia : '+ dtoc(fBuscaCPO('SZG',1,xfilial('SZG')+mv_par01,'ZG_DATA'))
	nlin++
	*/

	TMP->(dbGoTop())

	_nTotD  := 0
	_nTotC  := 0
	_nTotT  := 0
	//_nTotUY := 0
	_nTotAngus := 0
	_nTotHer   := 0
	_nTotMagro := 0
	_nTotPGo   := 0
	_nTotLeite := 0
	_nTotCar   := 0
	_nTotTor   := 0
	_nTotPGos  := 0
	_nTotTer   := 0
	_nTotBran  := 0
	_nTotGen   := 0
	_nTotGeral := 0
	_nTotBL    := 0
	_nTotSem   := 0
	_nTotUY    := 0
	
	_aTotal   := {}
	_aTotalUY := {}

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
		cQueryT += " WHERE " + RetSQLFil('ZAJ') + " AND " + RetSQLFil('SZK') + " AND ZK_NUMAM = ZAJ_NUMAM AND ZK_CONTROL  = ZAJ_CONTRO AND ZK_CLASESP = '" + TMP->ZK_CLASESP + "' AND"
		cQueryT += " ZK_DESTINO <> 'T' AND ZK_DESTINO <> 'R' AND ZK_CATEG = '" + TMP->ZK_CATEG + "' AND ZK_PROGRAM = '" + TMP->ZK_PROGRAM + "' AND ZK_CLASSIF = '" + TMP->ZK_CLASSIF + "' AND "
		cqueryT += " ZK_DENT = '" + TMP->ZK_DENT + "' AND ZK_COBGOR = '" + TMP->ZK_GOR + "' AND ZAJ_HORAS = '' AND ZAJ_DATAS = '' AND"
		cQueryT += " ZAJ_CORORI = 'T' AND ZAJ_REGORI = '0000000000' AND ZK_NUMAM = '" + TMP->ZK_NUMAM + "' AND " + RetSQLDel('ZAJ')
		 
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
		cQueryD += " WHERE " + RetSQLFil('ZAJ') + " AND " + RetSQLFil('SZK') + " AND ZK_NUMAM = ZAJ_NUMAM AND ZK_CONTROL  = ZAJ_CONTRO AND ZK_CLASESP = '" + TMP->ZK_CLASESP + "' AND"
		cQueryD += " ZK_DESTINO <> 'T' AND ZK_DESTINO <> 'R' AND ZK_CATEG = '" + TMP->ZK_CATEG + "' AND ZK_PROGRAM = '" + TMP->ZK_PROGRAM + "' AND ZK_CLASSIF = '" + TMP->ZK_CLASSIF + "' AND "
		cqueryD += " ZK_DENT = '" + TMP->ZK_DENT + "' AND ZK_COBGOR = '" + TMP->ZK_GOR + "' AND ZAJ_HORAS = '' AND ZAJ_DATAS = '' AND"
		cQueryD += " ZAJ_CORORI = 'D' AND ZAJ_REGORI = '0000000000' AND ZK_NUMAM = '" + TMP->ZK_NUMAM + "' AND " + RetSQLDel('ZAJ')
		
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
		cQueryC += " WHERE " + RetSQLFil('ZAJ') + " AND " + RetSQLFil('SZK') + " AND ZK_NUMAM = ZAJ_NUMAM AND ZK_CONTROL  = ZAJ_CONTRO AND ZK_CLASESP = '" + TMP->ZK_CLASESP + "' AND"
		cQueryC += " ZK_DESTINO <> 'T' AND ZK_DESTINO <> 'R' AND ZK_CATEG = '" + TMP->ZK_CATEG + "' AND ZK_PROGRAM = '" + TMP->ZK_PROGRAM + "' AND ZK_CLASSIF = '" + TMP->ZK_CLASSIF + "' AND "
		cqueryC += " ZK_DENT = '" + TMP->ZK_DENT + "' AND ZK_COBGOR = '" + TMP->ZK_GOR + "' AND ZAJ_HORAS = '' AND ZAJ_DATAS = '' AND"
		cQueryC += " ZAJ_CORORI = 'C' AND ZAJ_REGORI = '0000000000' AND ZK_NUMAM = '" + TMP->ZK_NUMAM + "' AND " + RetSQLDel('ZAJ')
		
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
		
		
		//Query para Caracaças - TF
		//////////////////////

		cQueryF := " SELECT  COUNT(*) AS NCARCTF FROM " + RetSQLTab('ZAJ') + "," + RetSQLTab('SZK')
		cQueryF += " WHERE " + RetSQLFil('ZAJ') + " AND " + RetSQLFil('SZK') + " AND ZK_NUMAM = ZAJ_NUMAM AND ZK_CONTROL  = ZAJ_CONTRO AND ZK_CLASESP = '" + TMP->ZK_CLASESP + "' AND"
		cQueryF += " ZK_DESTINO = 'T' AND ZK_CATEG = '" + TMP->ZK_CATEG + "' AND ZK_PROGRAM = '" + TMP->ZK_PROGRAM + "' AND ZK_CLASSIF = '" + TMP->ZK_CLASSIF + "' AND "
		cqueryF += " ZK_DENT = '" + TMP->ZK_DENT + "' AND ZK_COBGOR = '" + TMP->ZK_GOR + "' AND ZAJ_HORAS = '' AND ZAJ_DATAS = '' AND"
		cQueryF += " (ZAJ_CORORI = 'T' OR ZAJ_CORORI = 'D' OR ZAJ_CORORI = 'C') AND ZAJ_REGORI = '0000000000' AND ZK_NUMAM = '" + TMP->ZK_NUMAM + "' AND " + RetSQLDel('ZAJ')
		 
		cQueryF := ChangeQuery(cQueryF)

		//	* Mostrar a consulta */
		//@ 116,090 To 416,707 Dialog oDlgMemo Title "Consulta"
		//@ 055,005 Get cQueryT Size 250,080 MEMO Object oMemo
		//Activate Dialog oDlgMemo
		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³ Monta a interface padrao com o usuario...                           ³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ

		If Select("TMPF") != 0
			TMPF->(dbCloseArea())
		Endif
		TCQUERY cQueryF NEW ALIAS "TMPF"

		_nCARF := TMPF->NCARCTF
		
		//Query para Carcaças - Conserva
		//////////////////////

		cQueryR := " SELECT  COUNT(*) AS NCARCON FROM " + RetSQLTab('ZAJ') + "," + RetSQLTab('SZK')
		cQueryR += " WHERE " + RetSQLFil('ZAJ') + " AND " + RetSQLFil('SZK') + " AND ZK_NUMAM = ZAJ_NUMAM AND ZK_CONTROL  = ZAJ_CONTRO AND ZK_CLASESP = '" + TMP->ZK_CLASESP + "' AND"
		cQueryR += " ZK_DESTINO = 'R' AND ZK_CATEG = '" + TMP->ZK_CATEG + "' AND ZK_PROGRAM = '" + TMP->ZK_PROGRAM + "' AND ZK_CLASSIF = '" + TMP->ZK_CLASSIF + "' AND "
		cqueryR += " ZK_DENT = '" + TMP->ZK_DENT + "' AND ZK_COBGOR = '" + TMP->ZK_GOR + "' AND ZAJ_HORAS = '' AND ZAJ_DATAS = '' AND"
		cQueryR += " (ZAJ_CORORI = 'T' OR ZAJ_CORORI = 'D' OR ZAJ_CORORI = 'C') AND ZAJ_REGORI = '0000000000' AND ZK_NUMAM = '" + TMP->ZK_NUMAM + "' AND " + RetSQLDel('ZAJ')
		 
		cQueryR := ChangeQuery(cQueryR)

		//	* Mostrar a consulta */
		//@ 116,090 To 416,707 Dialog oDlgMemo Title "Consulta"
		//@ 055,005 Get cQueryT Size 250,080 MEMO Object oMemo
		//Activate Dialog oDlgMemo
		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³ Monta a interface padrao com o usuario...                           ³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ

		If Select("TMPR") != 0
			TMPR->(dbCloseArea())
		Endif
		TCQUERY cQueryR NEW ALIAS "TMPR"

		_nCARC := TMPR->NCARCON

		
		_cDCat  := 'Categoria: ' + fBuscaCPO('SZ5',1,xfilial('SZ5')+TMP->ZK_CATEG,'Z5_DESC')
		_cDProg := fBuscaCPO('SZ6',1,xfilial('SZ6')+TMP->ZK_PROGRAM,'Z6_DESC')
		
		
		
		IF _cNUMAM <> TMP->ZK_NUMAM
			@nlin,00 psay replicate('=',110)
			nlin++
			@nlin,01 psay 'AVISO DE MATANÇA: ' + TMP->ZK_NUMAM
			nlin++
			@nlin,01 psay 'Abate do Dia : '+ dtoc(fBuscaCPO('SZG',1,xfilial('SZG')+TMP->ZK_NUMAM,'ZG_DATA'))
			nlin++
			_cNUMAM := TMP->ZK_NUMAM
		ENDIF

		if _cCateg <> TMP->ZK_CATEG
			nlin++
			@nlin,00 psay replicate('=',110)
			nlin++
			@nlin,001 psay _cDCat
			nlin++
			@nlin,00 psay replicate('=',110)
			_cCateg := TMP->ZK_CATEG
			_ll := .t.
			nlin++
		endif

		if _cProg <> TMP->ZK_PROGRAM
			if !_ll
				nlin++
				@nlin,00 psay replicate('-',110)
				nlin++
			endif
			_ll := .f.
			@nlin,005 psay iif(_cDProg <> ' ',alltrim(_cDProg),'<Sem Programa>')
			_cProg := TMP->ZK_PROGRAM
		else
			@nlin,005 psay iif(_cDProg <> ' ',alltrim(_cDProg),'<Sem Programa>')
			_cProg := TMP->ZK_PROGRAM
		endif

		@nlin,023 psay alltrim(TMP->ZK_CLASSIF)
		@nlin,033 psay TMP->ZK_NCARC
		@nlin,042 psay _nTras
		@nlin,049 psay _nDia
		@nlin,055 psay _nCos
		@nlin,060 psay _nCARF
		@nlin,065 psay _nCARC
		@nlin,072 psay TMP->ZK_DENT
		@nlin,078 psay TMP->ZK_GOR
		@nlin,084 psay dtoc(fBuscaCPO('SZG',1,xfilial('SZG')+TMP->ZK_NUMAM,'ZG_DATA'))
		@nlin,100 psay iif(TMP->ZK_CLASESP = '1','UY','')
		nlin++
		
		_nTotT  += TMPT->NTRAS
		_nTotD  += TMPD->NDIA
		_nTotC  += TMPC->NCOS
		//_nTotUY += 0
		
		
		_key  := TMP->ZK_PROGRAM
		_npos := aScan(_aTotal,{|aVal|aVal[1] = _key})

		if _npos <> 0
			_aTotal[_npos,2] += _nTras
			_aTotal[_npos,3] += _nDia
			_aTotal[_npos,4] += _nCos
		else
			aAdd(_aTotal,{_key, _nTras,_nDia,_nCos})
		endif
		
		
		_npos2 := aScan(_aTotalUY,{|aVal|aVal[1] = TMP->ZK_CLASESP})

		if _npos2 <> 0
			_aTotalUY[_npos2,2] += _nTras
			_aTotalUY[_npos2,3] += _nDia
			_aTotalUY[_npos2,4] += _nCos
		else
			aAdd(_aTotalUY,{TMP->ZK_CLASESP, _nTras,_nDia,_nCos})
		endif
		
		
		If TMP->ZK_PROGRAM = '001'
			_nTotMagro++
		ElseIf TMP->ZK_PROGRAM = '002'
			_nTotHer++
		ElseIf TMP->ZK_PROGRAM = '004'
			_nTotPGo++
		ElseIf TMP->ZK_PROGRAM = '005'
			_nTotLeite++
		ElseIf TMP->ZK_PROGRAM = '006'
			_nTotAngus++
		ElseIf TMP->ZK_PROGRAM = '007'
			_nTotCar++
		ElseIf TMP->ZK_PROGRAM = '008'
			_nTotTor++
		ElseIf TMP->ZK_PROGRAM = '009'
			_nTotPGos++
		ElseIf TMP->ZK_PROGRAM = '010'
			_nTotTer++
		ElseIf TMP->ZK_PROGRAM = '011'
			_nTotBran++
		ElseIf TMP->ZK_PROGRAM = '012'
			_nTotGen++
		ElseIf TMP->ZK_PROGRAM = '013'
			_nTotGeral++
		ElseIf TMP->ZK_PROGRAM = '014'
			_nTotBL++
		ElseIf TMP->ZK_PROGRAM = '   '
			_nTotSem++
		EndIf
		
		If TMP->ZK_CLASESP = '1'
			_nTotUY++
		EndIf
		
		TMP->(dbSkip()) // Avanca o ponteiro do registro no arquivo
		
	EndDo
	
			nlin++ 
				@nlin,00 psay replicate('=',110) 
		    nlin++ 
		    	@nlin,01 psay 'TOTAIS: '
			nlin++
			
			for i:=1 to len(_aTotal)
				_cDProgt := fBuscaCPO('SZ6',1,xfilial('SZ6')+_aTotal[i,1],'Z6_DESC')
				@nlin,05 psay iif(_cDProgt <> ' ',alltrim(_cDProgt),'<Sem Programa>')
				//@nlin,05 psay _cDProgt //codigo do programa
			 	@nlin,42 psay _aTotal[i,2] //traseiro
			 	@nlin,49 psay _aTotal[i,3] //dianteiro
			 	@nlin,55 psay _aTotal[i,4] //costela
			 	nlin++
			next
			
			for i:=1 to len(_aTotalUY)
				If _aTotalUY[i,1] = '1'
					nlin++
					@nlin,05 psay 'Pecas UY: '
				 	@nlin,42 psay _aTotalUY[i,2] //traseiro
				 	@nlin,49 psay _aTotalUY[i,3] //dianteiro
				 	@nlin,55 psay _aTotalUY[i,4] //costela
				 	nlin++
			 	EndIf
			next
			
			nlin++
			@nlin,05 psay 'Total Geral: '
			@nlin,37 psay transform(_nTotT,'@E 999,999')
			@nlin,44 psay transform(_nTotD,'@E 999,999')
			@nlin,50 psay transform(_nTotC,'@E 999,999')
			//@nlin,80 psay 'Pecas UY: + 'transform(_nTotUY,'@E 9,999,999.99')
			nlin++


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
