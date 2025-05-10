#INCLUDE "TOTVS.CH"
#INCLUDE "TOPCONN.CH"
#INCLUDE "RWMAKE.CH"
#INCLUDE "VKEY.CH"
#INCLUDE "COLORS.CH"

#DEFINE BR Chr(10)

//--------------------------------------------------------------------------------------
/*/{Protheus.doc} ESTO002 
@type			: Função de Usuário
@Sample			: U_ESTO002()
@description	: Consulta de estoque on line de PA por grupo de estoque on line
@Param			: Nulo
@return			: Nulo
@ --------------|-----------------------------------------------------------------------
@author			: Evandro Mugnol
@since			: Mai/2021
@version		: Protheus 12.1.25 e posteriores
/*/
//--------------------------------------------------------------------------------------
User Function ESTO002()

	Local aSize1     := MsAdvSize()
	Local nTop       := 23
	Local nLeft      := 5
	Local nBottom    := aSize1[6]
	Local nRight     := aSize1[5]
	Local nLinaMais  := 0
	Local cButton1   := "QPushButton {" ;
									+ BR + " background: #FF8C00;";							 	// Cor do fundo
									+ BR + " border: 1px solid #096A82;";						// Cor da borda
									+ BR + " outline:0;";
									+ BR + " border-radius: 5px;"; 								// Arrerondamento da borda
									+ BR + " font: normal 15px Arial Black;"; 
									+ BR + " padding: 6px;";
									+ BR + " color: #000000;";									// Cor da fonte
									+ BR + " }";
									+ BR + " QPushButton:pressed {";							// Ações quando pressionado botão
									+ BR + " background-color: #FF8C00;border-style: inset;"; 
									+ BR + " border-color: #FF8C00;";
									+ BR + " color: #000000;";
									+ BR + " }"

	Private cPerg    := "ESTO002"
	Private cPerg2   := "ESTO002A"
	Private aBrowse1 := {}
	
	Private oFont    := tFont():New("Arial",,-18,,.T.,,,,)

	Private oPreC    := 'Pre. Caixas: '
	Private oPreP    := 'Pre. Peso:   '
	Private oProC    := 'Pro. Caixas: '
	Private oProP    := 'Pro. Peso:   ' 
	Private oEstC    := 'Est. Caixas: '
	Private oEstP    := 'Est. Peso:   '
	Private oCarC    := 'Car. Caixas: '
	Private oCarP    := 'Car. Peso:   ' 
	Private oEmpC    := 'Emp. Caixas: '
	Private oEmpP    := 'Emp. Peso:   '          

	Private _cFarm 	  := ''
	Private _aTotais1 := {{0,0},{0,0},{0,0},{0,0},{0,0}}

	aObjects := {}
	aPosObj  := {}
	aInfo    := {}
	aSizeAut := MsAdvSize()

	AAdd( aObjects, { 315, 50, .T., .T. } )
	AAdd( aObjects, { 100, 100, .T., .T. } )
	aInfo   := { aSizeAut[ 1 ], aSizeAut[ 2 ], aSizeAut[ 3 ], aSizeAut[ 4 ], 3, 3 }
	aPosObj := MsObjSize( aInfo, aObjects, .T. )

	aX           :=aPosObj[1]
	aX[3]        +=60
	aPosObj[1]   := aX
	aPosObj[2,1] += 60

	If !Pergunte(cPerg,.T.)
		Return .F.
	Endif

	_cFarm := IIF(mv_par03 == 1, 'R', IIF(mv_par03 == 2, 'C', 'S'))

	// Cabeçalhos das colunas
	aHeader1 := {'','CÓDIGO       ' ,;
					'DESCRIÇÃO    ' ,;
					'PREV. CAIXA  ' ,;
					'PREV. PESO   ' ,;
					'PROD. CAIXA  ' ,;
					'PROD. PESO   ' ,;
					'EST. CAIXA   ' ,;
					'EST. PESO    ' ,;
					'CARREG. CAIXA' ,;
					'CARREG. PESO ' ,;
					'EMP. CAIXA   ' ,;
					'EEMP. PESO   ' ,;
					'SALDO CAIXA  ' ,;
					'SALDO PESO   '  }

	// Largura das colunas
	aLargCol1 := {10, 20, 150, 50, 50, 50, 50, 50, 50, 50, 50, 50, 50, 50, 50}

	nTop    -= nLinAmais
	nBottom += nLinAmais

	DEFINE DIALOG oDlg TITLE "Consulta de Estoque de PA" FROM aSizeAut[7],00 To aSizeAut[6],aSizeAut[5] PIXEL

	// Cria Browse
	oBrowse1 := TCBrowse():New(55+nLinAmais, 005, (nRight-nLeft-20)/2, ((nBottom-nTop-150)/2)-(nLinaMais*1.5),,aHeader1,aLargCol1,oDlg,,,,,{||},,,,,,,.F.,,.T.,,.F.,,, )

	oSayPreC := tSay():New(012,005,{|| oPreC },oDlg,,oFont,,,,.T.,CLR_HBLUE,,250,40)
	oSayPreP := tSay():New(025,005,{|| oPreP },oDlg,,oFont,,,,.T.,CLR_HBLUE,,250,40)

	oSayProC := tSay():New(012,110,{|| oProC },oDlg,,oFont,,,,.T.,CLR_HRED,,250,40)
	oSayProP := tSay():New(025,110,{|| oProP },oDlg,,oFont,,,,.T.,CLR_HRED,,250,40)

	oSayEstC := tSay():New(012,215,{|| oEstC },oDlg,,oFont,,,,.T.,CLR_HBLUE,,250,40)
	oSayEstP := tSay():New(025,215,{|| oEstP },oDlg,,oFont,,,,.T.,CLR_HBLUE,,250,40)

	oSayCarC := tSay():New(012,320,{|| oCarC },oDlg,,oFont,,,,.T.,CLR_HRED,,250,40)
	oSayCarP := tSay():New(025,320,{|| oCarP },oDlg,,oFont,,,,.T.,CLR_HRED,,250,40)

	oSayEmpC := tSay():New(012,425,{|| oEmpC },oDlg,,oFont,,,,.T.,CLR_HBLUE,,250,40)
	oSayEmpP := tSay():New(025,425,{|| oEmpP },oDlg,,oFont,,,,.T.,CLR_HBLUE,,250,40)

	ProcAt()

	oButton1:=TButton():New( 010,535, "Parâmetros" , oDlg,{||pergunte(cPerg,.t.),_cFarm := iif(mv_par03 = 1,'R',iif(mv_par03 = 2,'C','S'))},65,16,,,.F.,.T.,.F.,,.F.,,,.F. )
	oButton1:SetCss(cButton1)
	oButton2:=TButton():New( 028,535, "Atualizar"  , oDlg,{||ProcAt()   },65,16,,,.F.,.T.,.F.,,.F.,,,.F. )
	oButton2:SetCss(cButton1)
	oButton3:=TButton():New( 010,605, "Relatório"  , oDlg,{||Relatorio()},65,16,,,.F.,.T.,.F.,,.F.,,,.F. )
	oButton3:SetCss(cButton1)
	oButton4:=TButton():New( 028,605, "Fechar"     , oDlg,{||oDlg:end() },65,16,,,.F.,.T.,.F.,,.F.,,,.F. )
	oButton4:SetCss(cButton1)

	ACTIVATE DIALOG oDlg CENTERED

Return


//-------------------------------------------------------------------
/*/{Protheus.doc} ProcAt
Chamada da função que fará a atualização do browse
@author     Evandro
@since      Mai/2021
@return     N/A
@obs        N/A
/*/
//-------------------------------------------------------------------
Static Function ProcAt()
	
	MsgRun("Aguarde... Atualizando..." ,,{|| AtuBrow() })

Return


//-------------------------------------------------------------------
/*/{Protheus.doc} AtuBrow
Função destinada a atualização do browse
@author     Evandro
@since      Mai/2021
@return     N/A
@obs        N/A
/*/
//-------------------------------------------------------------------
Static Function AtuBrow()

	_cFarm := IIF(mv_par03 == 1, 'R', IIF(mv_par03 = 2, 'C', 'S'))

	_cSQL := "DECLARE @farm VARCHAR(01) SET @farm = '" + _cFarm + "' EXEC SI_estoqueonline2 @farm OUTPUT"

	_nStat := TCSQLExec(_cSQL)

	Sleep(3000)

	MontaArray()

	oBrowse1:SetArray(aBrowse1)

	// Monta a linha a ser exibina no Browse
	oBrowse1:bLine := {||{aBrowse1[oBrowse1:nAt,01],aBrowse1[oBrowse1:nAt,02],aBrowse1[oBrowse1:nAt,03],;
						  aBrowse1[oBrowse1:nAT,04],aBrowse1[oBrowse1:nAT,05],aBrowse1[oBrowse1:nAT,06],;
						  aBrowse1[oBrowse1:nAT,07],aBrowse1[oBrowse1:nAT,08],aBrowse1[oBrowse1:nAT,09],;
						  aBrowse1[oBrowse1:nAT,10],aBrowse1[oBrowse1:nAT,11],aBrowse1[oBrowse1:nAT,12],;
						  aBrowse1[oBrowse1:nAT,13],aBrowse1[oBrowse1:nAT,14],aBrowse1[oBrowse1:nAT,15]}}

	oBrowse1:nScrollType := 1
	oBrowse1:bLDblClick := {|| EstDet(aBrowse1[oBrowse1:nAt,02]) }

	oBrowse1:DrawSelect()
	oBrowse1:refresh()

	oSayPreC:SetText(oPreC + Transform(_aTotais1[1,1],'@E 99,999,999'))
	oSayPreP:SetText(oPreP + Transform(_aTotais1[1,2],'@E 999,999.99'))
	oSayProC:SetText(oProC + Transform(_aTotais1[2,1],'@E 99,999,999'))
	oSayProP:SetText(oProP + Transform(_aTotais1[2,2],'@E 999,999.99'))
	oSayEstC:SetText(oEstC + Transform(_aTotais1[3,1],'@E 99,999,999'))
	oSayEstP:SetText(oEstP + Transform(_aTotais1[3,2],'@E 999,999.99'))
	oSayCarC:SetText(oCarC + Transform(_aTotais1[4,1],'@E 99,999,999'))
	oSayCarP:SetText(oCarP + Transform(_aTotais1[4,2],'@E 999,999.99'))
	oSayEmpC:SetText(oEmpC + Transform(_aTotais1[5,1],'@E 99,999,999'))
	oSayEmpP:SetText(oEmpP + Transform(_aTotais1[5,2],'@E 999,999.99'))

	oDlg:refresh()

Return


//-------------------------------------------------------------------
/*/{Protheus.doc} MontaArray
Função destinada a montagem do array de registros
@author     Evandro
@since      Mai/2021
@return     N/A
@obs        N/A
/*/
//-------------------------------------------------------------------
Static Function MontaArray()

	// Vetor com elementos do Browse
	aBrowse1   := {}

	_cComp     := ''
	_cDescComp := ''
	_cTipComp  := ''

	_aTotais1  := {{0,0},{0,0},{0,0},{0,0},{0,0}}

	ZE4->(DbSetOrder(2))
	ZE4->(DbGoTop())
	While ZE4->(!Eof())

		DbSelectArea('SB1')
		_cCorOri := fBuscaCPO('SB1',1,xfilial('SB1')+ZE4->ZE4_COD,'B1_CORORI')

		DO CASE
			CASE mv_par01 = 1
				If _cCorOri <> 'D'
					ZE4->(DbSkip())
					Loop
				Endif
			CASE mv_par01 = 2
				If _cCorOri <> 'T'
					ZE4->(DbSkip())
					Loop
				Endif
			CASE mv_par01 = 3
				If _cCorOri <> 'C'
					ZE4->(DbSkip())
					Loop
				Endif
			CASE mv_par01 = 4
				If !(_cCorOri $ 'R/M')
					ZE4->(DbSkip())
					Loop
				Endif
		ENDCASE

		If mv_par02 = 2
			If (ZE4->ZE4_PRCX <= 0) .And.;
			   (ZE4->ZE4_PDCX <= 0) .And.;
			   (ZE4->ZE4_ESCX <= 0) .And.;
			   (ZE4->ZE4_CRCX <= 0) .And.;
			   (ZE4->ZE4_EMCX <= 0)
				ZE4->(DbSkip())
				Loop
			Endif
		Endif

		If ZE4->ZE4_FARM <> _cFarm
			ZE4->(DbSkip())
			Loop
		Endif

		aadd(aBrowse1,{ RetCores('B'),;
						AllTrim(ZE4->ZE4_COD),;
						ZE4->ZE4_DESC,;
						Transform(iif(ZE4->ZE4_PRCX <= 0 ,0,ZE4->ZE4_PRCX),'@E 99,999,999'),;
						Transform(iif(ZE4->ZE4_PRCX <= 0 ,0,ZE4->ZE4_PRPS),'@E 999,999,999.99'),;
						Transform(ZE4->ZE4_PDCX,'@E 99,999,999'),;
						Transform(ZE4->ZE4_PDPS,'@E 999,999,999.99'),;
						Transform(ZE4->ZE4_ESCX,'@E 99,999,999'),;
						Transform(ZE4->ZE4_ESPS,'@E 999,999,999.99'),;
						Transform(ZE4->ZE4_CRCX,'@E 99,999,999'),;
						Transform(ZE4->ZE4_CRPS,'@E 999,999,999.99'),;
						Transform(ZE4->ZE4_EMCX,'@E 99,999,999'),;
						Transform(ZE4->ZE4_EMPS,'@E 999,999,999.99'),;
						Transform(iif(ZE4->ZE4_PRCX <= 0 ,0,ZE4->ZE4_PRCX) + ZE4->ZE4_ESCX - ZE4->ZE4_EMCX,'@E 99,999,999'),;
						Transform(iif(ZE4->ZE4_PRCX <= 0 ,0,ZE4->ZE4_PRPS) + ZE4->ZE4_ESPS - ZE4->ZE4_EMPS,'@E 999,999,999.99')})

		_aTotais1[1,1] += iif(ZE4->ZE4_PRCX <= 0 ,0,ZE4->ZE4_PRCX)
		_aTotais1[1,2] += iif(ZE4->ZE4_PRCX <= 0 ,0,ZE4->ZE4_PRPS)
		_aTotais1[2,1] += ZE4->ZE4_PDCX
		_aTotais1[2,2] += ZE4->ZE4_PDPS
		_aTotais1[3,1] += ZE4->ZE4_ESCX
		_aTotais1[3,2] += ZE4->ZE4_ESPS
		_aTotais1[4,1] += ZE4->ZE4_CRCX
		_aTotais1[4,2] += ZE4->ZE4_CRPS
		_aTotais1[5,1] += ZE4->ZE4_EMCX
		_aTotais1[5,2] += ZE4->ZE4_EMPS

		ZE4->(DbSkip())
	EndDo

Return


//-------------------------------------------------------------------
/*/{Protheus.doc} MontaArray
Função que retorna cor da legenda do browse
@author     Evandro
@since      Mai/2021
@return     N/A
@obs        N/A
/*/
//-------------------------------------------------------------------
Static Function RetCores(_Stt)
	
	Local Ret := iif(_Stt = 'B', LoadBitmap(GetResources(),'br_azul'),iif(_Stt = 'L',LoadBitmap(GetResources(),'br_verde'),;
			 	 iif(_Stt = 'C', LoadBitmap(GetResources(),'br_amarelo'),iif(_Stt = 'S',LoadBitmap(GetResources(),'br_laranja'),;
				 iif(_Stt = 'E', LoadBitmap(GetResources(),'br_vermelho'),iif(_Stt = 'F',LoadBitmap(GetResources(),'br_preto'),''))))))
Return Ret


//-------------------------------------------------------------------
/*/{Protheus.doc} EstDet
Função para estoque detalhado
@author     Evandro
@since      Mai/2021
@return     N/A
@obs        N/A
/*/
//-------------------------------------------------------------------
Static Function EstDet(_Comp)

	Local aSize1     := MsAdvSize()
	Local nTop       := 23
	Local nLeft      := 5
	Local nBottom    := aSize1[6]
	Local nRight     := aSize1[5]
	Local nLinaMais  := 0
	Local cButton2   := "QPushButton {" ;
									+ BR + " background: #3CB371;";							 	// Cor do fundo
									+ BR + " border: 1px solid #096A82;";						// Cor da borda
									+ BR + " outline:0;";
									+ BR + " border-radius: 5px;"; 								// Arrerondamento da borda
									+ BR + " font: normal 15px Arial Black;"; 
									+ BR + " padding: 6px;";
									+ BR + " color: #000000;";									// Cor da fonte
									+ BR + " }";
									+ BR + " QPushButton:pressed {";							// Ações quando pressionado botão
									+ BR + " background-color: #3CB371;border-style: inset;"; 
									+ BR + " border-color: #3CB371;";
									+ BR + " color: #000000;";
									+ BR + " }"
	Pergunte(cPerg2,.F.)

	aBrowse2 := {}

	//Cabeçalhos das colunas
	aHeader2 := {'','CÓDIGO       ' ,;
					'DESCRIÇÃO    ' ,;
					'PREV. CAIXA  ' ,;
					'PREV. PESO   ' ,;
					'PROD. CAIXA  ' ,;
					'PROD. PESO   ' ,;
					'EST. CAIXA   ' ,;
					'EST. PESO    ' ,;
					'CARREG. CAIXA' ,;
					'CARREG. PESO ' ,;
					'EMP. CAIXA   ' ,;
					'EEMP. PESO   ' ,;
					'SALDO CAIXA  ' ,;
					'SALDO PESO   '  }

	// Largura das colunas
	aLargCol2 := {10, 20, 150, 50, 50, 50, 50, 50, 50, 50, 50, 50, 50, 50, 50}

	DbSelectArea('SB1')
	_cDescri := fBuscaCPO('SB1',1,xfilial('SB1')+_Comp,'B1_DESC')

	MsgRun("Aguarde... Realizando contagem do produto " + _cDescri ,,{||MontaA2(_Comp)})

	DEFINE DIALOG oDlg2 TITLE "Detalhes do Estoque" FROM aSizeAut[7],00 To aSizeAut[6],aSizeAut[5] PIXEL

	nTop    -= nLinAmais
	nBottom += nLinAmais

	// Cria Browse
	oBrowse2 := TCBrowse():New(55+nLinAmais, 005, (nRight-nLeft-20)/2, ((nBottom-nTop-150)/2)-(nLinaMais*1.5),,aHeader2,aLargCol2,oDlg2,,,,,{||},,,,,,,.F.,,.T.,,.F.,,, )

	AtuBrow2()

	oButton1:=TButton():New( 020,395, "Atualizar"  , oDlg2,{||Atualiza(_Comp)},65,16,,,.F.,.T.,.F.,,.F.,,,.F. )
	oButton1:SetCss(cButton2)
	oButton2:=TButton():New( 020,465, "Parametros" , oDlg2,{||Pergunte(cPerg2,.t.)},65,16,,,.F.,.T.,.F.,,.F.,,,.F. )
	oButton2:SetCss(cButton2)
	oButton3:=TButton():New( 020,535, "Fechar"     , oDlg2,{||oDlg2:end()},65,16,,,.F.,.T.,.F.,,.F.,,,.F. )
	oButton3:SetCss(cButton2)

	ACTIVATE DIALOG oDlg2 CENTERED

	Pergunte(cPerg ,.F.)

Return


//-------------------------------------------------------------------
/*/{Protheus.doc} MontaA2
Função destinada a montagem do array2 de registros
@author     Evandro
@since      Mai/2021
@return     N/A
@obs        N/A
/*/
//-------------------------------------------------------------------
Static Function MontaA2(_Comp)

	aBrowse2 := {}

	SeleProd(_Comp)

	While QRY->(!Eof())
		_nEstCaix := 0
		_nEstPeso := 0

		Calculo(QRY->COD)

		DbSelectArea('SB1')
		_cDesc := fBuscaCPO('SB1',1,xfilial('SB1')+alltrim(QRY->COD),'B1_DESCRED')
		_cFam  := fBuscaCPO('SB1',1,xfilial('SB1')+alltrim(QRY->COD),'B1_FAM')

		If !Empty(mv_par01)
			If _cFam <> mv_par01
				QRY->(DbSkip())
				Loop
			Endif
		Endif

		If QRY2->C_PREV <= 0 .and.;
		   QRY1->C_PROD <= 0 .and.;
		   _nEstCaix    <= 0 .and.;
		   QRY4->C_CAR  <= 0 .and.;
		   QRY5->C_EMP  <= 0
			QRY->(DbSkip())
			Loop
		Endif

		aadd(aBrowse2,{ RetCores('B'),;
						Alltrim(QRY->COD),;
						Alltrim(_cDesc),;
						Transform(iif(QRY2->C_PREV < 0 .or. QRY2->P_PREV < 0,0,QRY2->C_PREV),'@E 99,999,999'),;
						Transform(iif(QRY2->C_PREV < 0 .or. QRY2->P_PREV < 0,0,QRY2->P_PREV),'@E 999,999,999.99'),;
						Transform(QRY1->C_PROD,'@E 99,999,999'),;
						Transform(QRY1->P_PROD,'@E 999,999,999.99'),;
						Transform(_nEstCaix,'@E 99,999,999'),;
						Transform(_nEstPeso,'@E 999,999,999.99'),;
						Transform(QRY4->C_CAR,'@E 99,999,999'),;
						Transform(QRY4->P_CAR,'@E 999,999,999.99'),;
						Transform(QRY5->C_EMP,'@E 99,999,999'),;
						Transform(QRY5->P_EMP,'@E 999,999,999.99'),;
						Transform(iif(QRY2->C_PREV <= 0,0,QRY2->C_PREV) + _nEstCaix - QRY5->C_EMP,'@E 99,999,999'),;
						Transform(iif(QRY2->C_PREV <= 0,0,QRY2->P_PREV) + _nEstPeso - QRY5->P_EMP,'@E 999,999,999.99')})
		QRY->(DbSkip())
	EndDo

Return


//-------------------------------------------------------------------
/*/{Protheus.doc} AtuBrow2
Função destinada a atualização do browse2 de detalhamento
@author     Evandro
@since      Mai/2021
@return     N/A
@obs        N/A
/*/
//-------------------------------------------------------------------
Static Function AtuBrow2()

	oBrowse2:SetArray(aBrowse2)

	// Monta a linha a ser exibina no Browse
	oBrowse2:bLine := {||{aBrowse2[oBrowse2:nAt,01],aBrowse2[oBrowse2:nAt,02],aBrowse2[oBrowse2:nAt,03],;
						  aBrowse2[oBrowse2:nAT,04],aBrowse2[oBrowse2:nAT,05],aBrowse2[oBrowse2:nAT,06],;
						  aBrowse2[oBrowse2:nAT,07],aBrowse2[oBrowse2:nAT,08],aBrowse2[oBrowse2:nAT,09],;
						  aBrowse2[oBrowse2:nAT,10],aBrowse2[oBrowse2:nAT,11],aBrowse2[oBrowse2:nAT,12],;
						  aBrowse2[oBrowse2:nAT,13],aBrowse2[oBrowse2:nAT,14],aBrowse2[oBrowse2:nAT,15]}}

	oBrowse2:nScrollType := 1

	oBrowse2:DrawSelect()
	oBrowse2:refresh()

Return


//-------------------------------------------------------------------
/*/{Protheus.doc} SeleProd
Função destinada a seleção dos produtos que serão apresentados na consulta
@author     Evandro
@since      Mai/2021
@return     N/A
@obs        N/A
/*/
//-------------------------------------------------------------------
Static Function SeleProd(_Comp)

	cQuery := "SELECT B1_COD AS COD, B1_DESC "
	cQuery += "  FROM " + RetSQLTab("SB1") + "," + RetSQLTab("ZE3") + "," + RetSQLTab("SBM")
	cQuery += " WHERE " + RetSQLFil("SB1") + " AND " + RetSQLFil("ZE3") + " AND " + RetSQLFil("SBM")
	cQuery += "   AND B1_COD = ZE3_CODPRO
	cQuery += "   AND B1_MSBLQL = '2'"
	cQuery += "   AND B1_TIPO IN ('PA','PR') "
	cQuery += "   AND ZE3_CODGRP = '" + _Comp + "'"
	cQuery += "   AND B1_GRUPO = BM_GRUPO
	cQuery += "   AND BM_FARM = '" + _cFarm + "'"
	cQuery += "   AND " + RetSQLDel("SB1") + " AND " + RetSQLDel("ZE3") + " AND " + RetSQLDel("SBM")
	cQuery += " ORDER BY B1_DESC, B1_COD "

	cQuery  := ChangeQuery(cQuery)

	If Select("QRY")<>0
		QRY->(dbCloseArea())
	Endif

	TCQUERY cQuery NEW ALIAS "QRY"

Return


//-------------------------------------------------------------------
/*/{Protheus.doc} Calculo
Função destinada a fazer o calculo de produto a produto
@author     Evandro
@since      Mai/2021
@return     N/A
@obs        N/A
/*/
//-------------------------------------------------------------------
Static Function Calculo(_Prod)

	// Query para calcular o que foi produzido
	cQuery1 := "SELECT SUM(ZU_QRCAIX) AS C_PROD,SUM(ZU_QRPESO) AS P_PROD "
	cQuery1 += "  FROM " + RetSQLTab("SZU") + "," + RetSQLTab("SB1") + "," + RetSQLTab("SBM")
	cQuery1 += " WHERE " + RetSQLFil("SZU") + " AND " + RetSQLFil("SB1") + " AND " + RetSQLFil("SBM")
	cQuery1 += "   AND ZU_COD = '" + AllTrim(_Prod) + "'"
	cQuery1 += "   AND ZU_COD = B1_COD
	cQuery1 += "   AND B1_GRUPO = BM_GRUPO
	cQuery1 += "   AND BM_FARM = '" + _cFarm + "'"
	cQuery1 += "   AND B1_MSBLQL = '2'"
	cQuery1 += "   AND ZU_DTRPRO = '" + Dtos(ddatabase) + "'"
	cQuery1 += "   AND " + RetSQLDel("SZU") + " AND " + RetSQLDel("SB1") + " AND " + RetSQLDel("SBM")

	cQuery1  := ChangeQuery(cQuery1)

	If Select("QRY1")<>0
		QRY1->(dbCloseArea())
	Endif

	TCQUERY cQuery1 NEW ALIAS "QRY1"

	//Query para calcular o que está previsto
	cQuery2 := "SELECT SUM(ZU_QPCAIX-ZU_QRCAIX) AS C_PREV , SUM(ZU_QPPESO-ZU_QRPESO)AS P_PREV "
	cQuery2 += "  FROM " + RetSQLTab("SZU") + "," + RetSQLTab("SB1") + "," + RetSQLTab("SBM")
	cQuery2 += " WHERE " + RetSQLFil("SZU") + " AND " + RetSQLFil("SB1") + " AND " + RetSQLFil("SBM")
	cQuery2 += "   AND ZU_COD = '" + AllTrim(_Prod) + "'"
	cQuery2 += "   AND ZU_FECHADO = 'N'"
	cQuery2 += "   AND ZU_COD = B1_COD
	cQuery2 += "   AND B1_GRUPO = BM_GRUPO
	cQuery2 += "   AND BM_FARM = '" + _cFarm + "'"
	cQuery2 += "   AND B1_MSBLQL = '2'"
	cQuery2 += "   AND ZU_DTRPRO = '" + Dtos(ddatabase) + "'"
	cQuery2 += "   AND " + RetSQLDel("SZU") + " AND " + RetSQLDel("SB1") + " AND " + RetSQLDel("SBM")

	cQuery2 := ChangeQuery(cQuery2)

	If Select("QRY2")<>0
		QRY2->(dbCloseArea())
	Endif

	TCQUERY cQuery2 NEW ALIAS "QRY2"

	// Acessa estoque atual do produto (SZI)
	SZI->(DbSetOrder(1))
	If SZI->(DbSeek(xfilial('SZI')+alltrim(_Prod)))
		_nEstCaix := SZI->ZI_QTCAIX
		_nEstPeso := SZI->ZI_QTPESO
	Else
		_nEstCaix := 0
		_nEstPeso := 0
	Endif

	// Query pra calcular o que foi carregado
	cQuery4 := "SELECT SUM(ZZ5_QRCAIX) AS C_CAR, SUM(ZZ5_QRPESO) AS P_CAR "
	cQuery4 += "  FROM " + RetSQLTab('ZZ5') + "," + RetSQLTab('ZZ4') + "," + RetSQLTab('SB1') + "," + RetSQLTab('SBM')
	cQuery4 += " WHERE " + RetSQLFil('ZZ5') + " AND " + RetSQLFil('ZZ4') + " AND " + RetSQLFil('SB1') + " AND " + RetSQLFil('SBM')
	cQuery4 += "   AND ZZ5_COD = '" + Alltrim(_Prod) + "'"
	cQuery4 += "   AND ZZ5_COD = B1_COD 
	cQuery4 += "   AND BM_GRUPO = B1_GRUPO 
	cQuery4 += "   AND BM_FARM = '" + _cFarm + "'"
	cQuery4 += "   AND B1_MSBLQL = '2' "
	cQuery4 += "   AND ZZ5_NUM = ZZ4_NUM
	cQuery4 += "   AND ZZ4_DATA = '" + dtos(ddatabase) + "'"
	cQuery4 += "   AND ZZ4_TPOPER <> 'C'"
	cQuery4 += "   AND " + RetSQLDel("ZZ5") + " AND " + RetSQLDel("ZZ4") + " AND " + RetSQLDel("SB1") + " AND " + RetSQLDel("SBM")

	cQuery4  := ChangeQuery(cQuery4)

	If Select("QRY4")<>0
		QRY4->(dbCloseArea())
	Endif

	TCQUERY cQuery4 NEW ALIAS "QRY4"

	//Query para calcular o empenho
	cQuery5 := "SELECT SUM(ZZ5_QPCAIX-ZZ5_QRCAIX) AS C_EMP, SUM(ZZ5_QPPESO-ZZ5_QRPESO) AS P_EMP   "
	cQuery5 += "  FROM " + RetSQLTab('ZZ4') + "," + RetSQLTab('ZZ5')  + "," + RetSQLTab('SB1')  + "," + RetSQLTab('SBM')
	cQuery5 += " WHERE " + RetSQLFil('ZZ4') + " AND " + RetSQLFil('ZZ5') + " AND " + RetSQLFil('SB1') + " AND " + RetSQLFil('SBM')
	cQuery5 += "   AND ZZ5_STATUS <> 'E'"
	cQuery5 += "   AND ZZ5_COD = '" + Alltrim(_Prod) + "'"
	cQuery5 += "   AND B1_COD = ZZ5_COD 
	cQuery5 += "   AND B1_GRUPO = BM_GRUPO 
	cQuery5 += "   AND B1_MSBLQL = '2'"
	cQuery5 += "   AND ZZ5_NUM = ZZ4_NUM
	cQuery5 += "   AND (ZZ4_DATA BETWEEN '" + DTOS(ddatabase-1) + "' AND '" + DTOS(ddatabase) + "') "
	cQuery5 += "   AND ZZ4_TPOPER <> 'C' "
	cQuery5 += "   AND ZZ4_STATUS NOT IN('E','F','P') "
	cQuery5 += "   AND " + RetSqlDel('ZZ4') + " AND " + RetSQLDel('ZZ5') + " AND " + RetSQLDel('SB1') + " AND " + RetSQLDel('SBM')

	cQuery5  := ChangeQuery(cQuery5)

	If Select("QRY5")<>0
		QRY5->(dbCloseArea())
	Endif

	TCQUERY cQuery5 NEW ALIAS "QRY5"

Return


//-------------------------------------------------------------------
/*/{Protheus.doc} Atualiza
Função destinada a atualizar os dados 
@author     Evandro
@since      Mai/2021
@return     N/A
@obs        N/A
/*/
//-------------------------------------------------------------------
Static Function Atualiza(_Comp)

	DbSelectArea('SB1')
	_cDescri := fBuscaCPO('SB1',1,xfilial('SB1')+_Comp,'B1_DESC')

	MsgRun("Aguarde... Realizando atualização do produto " + _cDescri ,,{||MontaA2(_Comp)})

	If len(aBrowse2) <> 0
		AtuBrow2()
	Else
		aadd(aBrowse2,{ RetCores('B'),;
						'',;
						'',;
						Transform(0,'@E 99,999,999'),;
						Transform(0,'@E 999,999,999.99'),;
						Transform(0,'@E 99,999,999'),;
						Transform(0,'@E 999,999,999.99'),;
						Transform(0,'@E 99,999,999'),;
						Transform(0,'@E 999,999,999.99'),;
						Transform(0,'@E 99,999,999'),;
						Transform(0,'@E 999,999,999.99'),;
						Transform(0,'@E 99,999,999'),;
						Transform(0,'@E 999,999,999.99'),;
						Transform(0,'@E 99,999,999'),;
						Transform(0,'@E 999,999,999.99')})
		MsgInfo('Revise os parâmetros e atualize a consulta...','Produto sem movimentação ou estoque!','INFO')
	Endif

Return


//-------------------------------------------------------------------
/*/{Protheus.doc} Relatorio
Função destinada a impressão do relatório 
@author     Evandro
@since      Mai/2021
@return     N/A
@obs        N/A
/*/
//-------------------------------------------------------------------
Static Function Relatorio()

	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Declaracao de Variaveis                                             ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	Local cDesc1         := "Este programa tem como objetivo imprimir relatorio  "
	Local cDesc2         := "de conferencia de estoque de produto acabado        "
	Local cDesc3         := "de acordo com os parâmetros apontados               "
	//Local cPict          := "empresa"
	Local titulo         := "CONFERENCIA DE ESTOQUE DE PRODUTO ACABADO"
	Local nLin           := 80

	Local Cabec1         := "           Codigo          Descricao                                Caixas         Peso"
	Local Cabec2         := ""

	//Local imprime        := .T.
	Local aOrd := {}

	Private lEnd         := .F.
	Private lAbortPrint  := .F.
	Private CbTxt        := ""
	Private limite       := 132
	Private tamanho      := "M"
	Private nomeprog     := "ESTO002" // Coloque aqui o nome do programa para impressao no cabecalho
	Private nTipo        := 18
	Private aReturn      := { "Zebrado", 1, "Administracao", 2, 2, 1, "", 1}
	Private nLastKey     := 0
	//Private cbtxt        := Space(10)
	Private cbcont       := 00
	Private CONTFL       := 01
	Private m_pag        := 01
	Private wnrel        := "ESTO002" // Coloque aqui o nome do arquivo usado para impressao em disco
	Private cPerg        := ''

	wnrel := SetPrint('ZE4',NomeProg,cPerg,@titulo,cDesc1,cDesc2,cDesc3,.T.,aOrd,.T.,Tamanho,,.T.)

	If nLastKey == 27
		Return
	Endif

	SetDefault(aReturn,'SZN')

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
	Local i

	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ SETREGUA -> Indica quantos registros serao processados para a regua ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ

	_nTamBrowse := len(aBrowse1)

	SetRegua(_nTamBrowse)

	_cAux := ''

	For i := 1 to _nTamBrowse
		incregua()

		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³ Verifica o cancelamento pelo usuario...                             ³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		If lAbortPrint
			@nLin,00 PSAY "*** CANCELADO PELO OPERADOR ***"
			Exit
		Endif

		If nLin > 70 // Salto de Página. Neste caso o formulario tem 55 linhas...
			Cabec(Titulo,Cabec1,Cabec2,NomeProg,Tamanho,nTipo)
			nLin := 9
		Endif

		_nTotCx	:= 0
		_nTotPs  := 0

		DO CASE
			CASE mv_par01 = 1
				@ nlin,005 psay 'PRODUTOS RESFRIADOS'
				nlin+=3
			CASE mv_par01 = 2
				@ nlin,005 psay 'PRODUTOS CONGELADOS'
				nlin+=3
			CASE mv_par01 = 3
				@ nlin,005 psay 'PRODUTOS SALGADOS'
				nlin+=3
			CASE mv_par01 = 4
				@ nlin,005 psay 'PRODUTOS MIUDOS/RECORTE'
				nlin+=3
		ENDCASE

		@ nlin,010 psay aBrowse1[i,2]
		@ nlin,025 psay substr(aBrowse1[i,3],1,35)
		@ nlin,065 psay aBrowse1[i,8]
		@ nlin,073 psay aBrowse1[i,9]
		nlin++

		SeleProd(aBrowse1[i,2])

		While QRY->(!eof())
			// Acessa estoque atual do produto (SZI)
			SZI->(DbSetOrder(1))
			If SZI->(DbSeek(xfilial('SZI')+alltrim(QRY->COD)))
				_nEstCaix := SZI->ZI_QTCAIX
				_nEstPeso := SZI->ZI_QTPESO
				_nTotCx	 += SZI->ZI_QTCAIX
				_nTotPs   += SZI->ZI_QTPESO
			Else
				_nEstCaix := 0
				_nEstPeso := 0
			Endif

			If _nEstCaix > 0 .or. _nEstPeso > 0
				@ nlin,010 psay QRY->COD
				@ nlin,025 psay substr(QRY->B1_DESC,1,35)
				@ nlin,065 psay Transform(_nEstCaix,'@E 999,999')
				@ nlin,077 psay Transform(_nEstPeso,'@E 999,999.99')
				nlin++
			Endif

			QRY->(DbSkip())

			If nLin > 70 // Salto de Página. Neste caso o formulario tem 55 linhas...
				Cabec(Titulo,Cabec1,Cabec2,NomeProg,Tamanho,nTipo)
				nLin := 9
			Endif
		EndDo

		@ nlin,050 psay substr('TOTAL:',1,35)
		@ nlin,065 psay Transform(_nTotCx,'@E 999,999')
		@ nlin,073 psay Transform(_nTotPs,'@E 999,999,999.99')
		nlin++
		@ nlin,001 psay replicate('-',132)
		nlin++

	Next
	
	If nLin > 70 // Salto de Página. Neste caso o formulario tem 55 linhas...
		Cabec(Titulo,Cabec1,Cabec2,NomeProg,Tamanho,nTipo)
		nLin := 9
	Endif
	
	@ nlin,001 psay replicate('-',132)
	nlin++

	@ nlin,050 psay 'TOTAIS:'
	@ nlin,065 psay 'EST. CAIXA'
	@ nlin,080 psay 'EST. PESO'
	nlin++
	@ nlin,065 psay Transform(_aTotais1[3,1],'@E 999,999')//estoque caixa
	@ nlin,077 psay Transform(_aTotais1[3,2],'@E 999,999.99')//estoque peso
	nlin++
	@ nlin,050 psay 'TOTAIS:'
	@ nlin,065 psay 'EMP. CAIXA'
	@ nlin,080 psay 'EMP. PESO'
	nlin++
	@ nlin,065 psay Transform(_aTotais1[5,1],'@E 999,999')//empenho caixa
	@ nlin,077 psay Transform(_aTotais1[5,2],'@E 999,999.99')//empenho peso

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
