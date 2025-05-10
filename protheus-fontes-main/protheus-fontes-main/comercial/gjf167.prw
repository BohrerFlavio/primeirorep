#INCLUDE "topconn.ch"         
#INCLUDE "rwmake.ch"
#INCLUDE "vkey.ch"
#INCLUDE "protheus.ch"
#INCLUDE "colors.ch" 

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³GJF167    º Autor ³ Giuliano Forgiariniº Data ³  15/05/13   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDescricao ³ Consulta de Estoque de PA aglutinada On-line               º±±
±±º          ³                                                            º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ Comercial                                                  º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/

User Function GJF167()  

	aObjects            := {}                                                                 
	aPosObj             := {}
	aInfo               := {}
	aSizeAut            := MsAdvSize()

	AAdd( aObjects, { 315, 50, .T., .T. } )
	AAdd( aObjects, { 100, 100, .T., .T. } )
	aInfo := { aSizeAut[ 1 ], aSizeAut[ 2 ], aSizeAut[ 3 ], aSizeAut[ 4 ], 3, 3 }
	aPosObj := MsObjSize( aInfo, aObjects, .T. )

	aX           :=aPosObj[1]                                                            
	aX[3]        +=60
	aPosObj[1]   := aX
	aPosObj[2,1] += 60

	Private cPerg    := "GJF167"
	Private cPerg2   := "GJF167a"
	Private aBrowse1 := {}
	Private oFont    := tFont():New("courier new",,-12,,.t.,,,,)	    

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

	Private _cFarm := ''

	Private _aTotais1 := {{0,0},{0,0},{0,0},{0,0},{0,0}}

	if !pergunte(cPerg,.t.)
		return .f.
	endif

	_cFarm := iif(mv_par03 = 1,'R',iif(mv_par03 = 2,'C','S'))

	//Cabeçalhos das colunas  
	aHeader1 := {'','Codigo       ',;
	'Descrição    ',;
	'Prev. Caixa  ',;
	'Prev. Peso   ',;
	'Prod. Caixa  ',;
	'Prod. Peso   ',;                
	'Est. Caixa   ',;
	'Est. Peso    ',;
	'Carreg. Caixa',;
	'Carreg. Peso ',;
	'Emp. Caixa   ',;
	'Emp. Peso    ',;
	'Saldo Caixa  ',;
	'Saldo Peso   '}
	//Largura das colunas
	aLargCol1 := {20,30,60,30,30,30,30,30,30,30,30,30,30,30,30}


	DEFINE DIALOG oDlg TITLE "Consulta de Estoque de PA" FROM aSizeAut[7],00 To aSizeAut[6],aSizeAut[5] PIXEL		
	//DEFINE DIALOG oDlg TITLE "Consulta de Estoque de PA" FROM 020,50 To 700,1000 PIXEL			
	// Cria Browse		
	oBrowse1 := TCBrowse():New(00,20,530,280,,aHeader1,aLargCol1,oDlg,,,,,{||},,,,,,,.F.,,.T.,,.F.,,, )		

	oSayPreC := tSay():New(070,560,{|| oPreC },oDlg,,oFont,,,,.T.,,,200,30) 
	oSayPreP := tSay():New(080,560,{|| oPreP },oDlg,,oFont,,,,.T.,,,200,30) 

	oSayProC := tSay():New(100,560,{|| oProC },oDlg,,oFont,,,,.T.,,,200,30) 
	oSayProP := tSay():New(110,560,{|| oProP },oDlg,,oFont,,,,.T.,,,200,30)

	oSayEstC := tSay():New(130,560,{|| oEstC },oDlg,,oFont,,,,.T.,,,200,30) 
	oSayEstP := tSay():New(140,560,{|| oEstP },oDlg,,oFont,,,,.T.,,,200,30)

	oSayCarC := tSay():New(160,560,{|| oCarC },oDlg,,oFont,,,,.T.,,,200,30) 
	oSayCarP := tSay():New(170,560,{|| oCarP },oDlg,,oFont,,,,.T.,,,200,30)

	oSayEmpC := tSay():New(190,560,{|| oEmpC },oDlg,,oFont,,,,.T.,,,200,30) 
	oSayEmpP := tSay():New(200,560,{|| oEmpP },oDlg,,oFont,,,,.T.,,,200,30)

	ProcAt()

	//oTimer1 := TTimer():New(5000, {|| ProcAt() }, oDlg)  
	//oTimer1:Activate() 

	TButton():New( 015,600, "Parametros" , oDlg,{||pergunte(cPerg,.t.),_cFarm := iif(mv_par03 = 1,'R',iif(mv_par03 = 2,'C','S'))},40,010,,,.F.,.T.,.F.,,.F.,,,.F. ) 	 
	TButton():New( 030,600, "Atualizar"  , oDlg,{||ProcAt()   },40,010,,,.F.,.T.,.F.,,.F.,,,.F. )   
	TButton():New( 045,600, "Relatorio"  , oDlg,{||Relatorio()},40,010,,,.F.,.T.,.F.,,.F.,,,.F. )   
	TButton():New( 060,600, "Fechar"     , oDlg,{||oDlg:end() },40,010,,,.F.,.T.,.F.,,.F.,,,.F. )   
	//TButton():New( 030,600, "Ativar",    oDlg,{||Ativar()   },40,010,,,.F.,.T.,.F.,,.F.,,,.F. )	    


	ACTIVATE DIALOG oDlg CENTERED 

Return 


//Função destinada a montagem do array de registros
Static Function MontaArray()  

	// Vetor com elementos do Browse
	aBrowse1 := {}		

	_cComp     := '' 
	_cDescComp := '' 
	_cTipComp  := ''  

	_aTotais1 := {{0,0},{0,0},{0,0},{0,0},{0,0}}

	ZAI->(DbSetOrder(2))
	ZAI->(DbGoTop())
	while ZAI->(!eof())

		DbSelectArea('SB1')   
		_cCorOri := fBuscaCPO('SB1',1,xfilial('SB1')+ZAI->ZAI_COD,'B1_CORORI')

		do case
			case mv_par01 = 1
			if _cCorOri <> 'D'
				ZAI->(DbSkip())
				loop
			endif
			case mv_par01 = 2
			if _cCorOri <> 'T'
				ZAI->(DbSkip())
				loop
			endif		
			case mv_par01 = 3
			if _cCorOri <> 'C'
				ZAI->(DbSkip())
				loop
			endif		
			case mv_par01 = 4
			if !(_cCorOri $ 'R/M')
				ZAI->(DbSkip())
				loop
			endif		
		endcase			

		if mv_par02 = 2
			if (ZAI->ZAI_PRCX <= 0) .and.;
			(ZAI->ZAI_PDCX <= 0) .and.;
			(ZAI->ZAI_ESCX  <= 0) .and.;
			(ZAI->ZAI_CRCX  <= 0) .and.;
			(ZAI->ZAI_EMCX  <= 0) 
				ZAI->(DbSkip())
				loop
			endif
		endif

		if ZAI->ZAI_FARM <> _cFarm
			ZAI->(DbSkip())
			loop
		endif


		aadd(aBrowse1,{RetCores('B'),;
		ZAI->ZAI_COD,;
		ZAI->ZAI_DESC,;
		transform(iif(ZAI->ZAI_PRCX <= 0 ,0,ZAI->ZAI_PRCX),'@E 999,999'),;
		transform(iif(ZAI->ZAI_PRCX <= 0 ,0,ZAI->ZAI_PRPS),'@E 999,999,999.99'),;
		transform(ZAI->ZAI_PDCX,'@E 999,999'),;
		transform(ZAI->ZAI_PDPS,'@E 999,999,999.99'),;
		transform(ZAI->ZAI_ESCX,'@E 999,999'),;
		transform(ZAI->ZAI_ESPS,'@E 999,999,999.99'),;
		transform(ZAI->ZAI_CRCX,'@E 999,999'),;
		transform(ZAI->ZAI_CRPS,'@E 999,999,999.99'),;
		transform(ZAI->ZAI_EMCX,'@E 999,999'),;
		transform(ZAI->ZAI_EMPS,'@E 999,999,999.99'),;                     
		transform(iif(ZAI->ZAI_PRCX <= 0 ,0,ZAI->ZAI_PRCX) + ZAI->ZAI_ESCX - ZAI->ZAI_EMCX,'@E 999,999'),;      
		transform(iif(ZAI->ZAI_PRCX <= 0 ,0,ZAI->ZAI_PRPS) + ZAI->ZAI_ESPS - ZAI->ZAI_EMPS,'@E 999,999,999.99')})	  

		// {{0,0},{0,0},{0,0},{0,0},{0,0}}
		_aTotais1[1,1] += iif(ZAI->ZAI_PRCX <= 0 ,0,ZAI->ZAI_PRCX)
		_aTotais1[1,2] += iif(ZAI->ZAI_PRCX <= 0 ,0,ZAI->ZAI_PRPS)
		_aTotais1[2,1] += ZAI->ZAI_PDCX
		_aTotais1[2,2] += ZAI->ZAI_PDPS
		_aTotais1[3,1] += ZAI->ZAI_ESCX
		_aTotais1[3,2] += ZAI->ZAI_ESPS
		_aTotais1[4,1] += ZAI->ZAI_CRCX 
		_aTotais1[4,2] += ZAI->ZAI_CRPS
		_aTotais1[5,1] += ZAI->ZAI_EMCX
		_aTotais1[5,2] += ZAI->ZAI_EMPS

		ZAI->(DbSkip())
	enddo

return 


//Função destinada a atualização do browse pelo timer
Static Function AtuBrow()  

	_cFarm := iif(mv_par03 = 1,'R',iif(mv_par03 = 2,'C','S'))  

	_cSQL := "DECLARE @farm VARCHAR(01) SET @farm = '"+_cFarm+"' EXEC SI_estoqueonline @farm OUTPUT"    

	_nStat := TCSQLExec(_cSQL)   

	sleep(3000)  

	MontaArray()

	oBrowse1:SetArray(aBrowse1)

	// Monta a linha a ser exibina no Browse
	oBrowse1:bLine := {||{aBrowse1[oBrowse1:nAt,01],aBrowse1[oBrowse1:nAt,02],aBrowse1[oBrowse1:nAt,03],;
	aBrowse1[oBrowse1:nAT,04],aBrowse1[oBrowse1:nAT,05],aBrowse1[oBrowse1:nAT,06],;
	aBrowse1[oBrowse1:nAT,07],aBrowse1[oBrowse1:nAT,08],aBrowse1[oBrowse1:nAT,09],;
	aBrowse1[oBrowse1:nAT,10],aBrowse1[oBrowse1:nAT,11],aBrowse1[oBrowse1:nAT,12],;
	aBrowse1[oBrowse1:nAT,13],aBrowse1[oBrowse1:nAT,14],aBrowse1[oBrowse1:nAT,15]}}

	oBrowse1:nScrollType := 1
	oBrowse1:bLDblClick   := {|| EstDet(aBrowse1[oBrowse1:nAt,02]) }

	oBrowse1:DrawSelect()
	oBrowse1:refresh()

	oSayPreC:SetText(oPreC + Transform(_aTotais1[1,1],'@E 999,999'))
	oSayPreP:SetText(oPreP + Transform(_aTotais1[1,2],'@E 999,999.99'))
	oSayProC:SetText(oProC + Transform(_aTotais1[2,1],'@E 999,999'))
	oSayProP:SetText(oProP + Transform(_aTotais1[2,2],'@E 999,999.99'))
	oSayEstC:SetText(oEstC + Transform(_aTotais1[3,1],'@E 999,999'))
	oSayEstP:SetText(oEstP + Transform(_aTotais1[3,2],'@E 999,999.99'))
	oSayCarC:SetText(oCarC + Transform(_aTotais1[4,1],'@E 999,999'))
	oSayCarP:SetText(oCarP + Transform(_aTotais1[4,2],'@E 999,999.99'))
	oSayEmpC:SetText(oEmpC + Transform(_aTotais1[5,1],'@E 999,999'))
	oSayEmpP:SetText(oEmpP + Transform(_aTotais1[5,2],'@E 999,999.99'))

	oDlg:refresh()

return   

Static Function RetCores(_Stt)
	local ret   := iif(_Stt = 'B', LoadBitmap(GetResources(),'br_azul'),iif(_Stt = 'L',LoadBitmap(GetResources(),'br_verde'),;
	iif(_Stt = 'C', LoadBitmap(GetResources(),'br_amarelo'),iif(_Stt = 'S',LoadBitmap(GetResources(),'br_laranja'),;
	iif(_Stt = 'E', LoadBitmap(GetResources(),'br_vermelho'),iif(_Stt = 'F',LoadBitmap(GetResources(),'br_preto'),''))))))
return  ret


//Função para estoque detalhado 
Static Function EstDet(_Comp)

	Pergunte(cPerg2,.f.)

	aBrowse2 := {}

	//Cabeçalhos das colunas  
	aHeader2 := {'','Codigo       ',;
	'Descrição    ',;
	'Prev. Caixa  ',;
	'Prev. Peso   ',;
	'Prod. Caixa  ',;
	'Prod. Peso   ',;                
	'Est. Caixa   ',;
	'Est. Peso    ',;
	'Carreg. Caixa',;
	'Carreg. Peso ',;
	'Emp. Caixa   ',;
	'Emp. Peso    ',;
	'Saldo Caixa  ',;
	'Saldo Peso   '}
	//Largura das colunas
	aLargCol2 := {20,30,60,30,30,30,30,30,30,30,30,30,30,30,30}

	DbSelectArea('SB1')
	_cDescri := fBuscaCPO('SB1',1,xfilial('SB1')+_Comp,'B1_DESC')

	MsgRun("Aguarde... Realizando contagem do produto " + _cDescri ,,{||MontaA2(_Comp)})

	DEFINE DIALOG oDlg2 TITLE "Detalhes do Estoque" FROM aSizeAut[7],00 To aSizeAut[6],aSizeAut[5] PIXEL		

	// Cria Browse		
	oBrowse2 := TCBrowse():New(00,20,550,280,,aHeader2,aLargCol2,oDlg2,,,,,{||},,,,,,,.F.,,.T.,,.F.,,, )		

	AtuBrow2()

	TButton():New( 015,600, "Atualizar"  , oDlg2,{||Atualiza(_Comp)},40,010,,,.F.,.T.,.F.,,.F.,,,.F. ) 	 
	TButton():New( 030,600, "Parametros" , oDlg2,{||Pergunte(cPerg2,.t.)},40,010,,,.F.,.T.,.F.,,.F.,,,.F. ) 	 
	TButton():New( 060,600, "Fechar"     , oDlg2,{||oDlg2:end()   },40,010,,,.F.,.T.,.F.,,.F.,,,.F. )   
	//TButton():New( 060,600, "Ativar",    oDlg,{||Ativar()   },40,010,,,.F.,.T.,.F.,,.F.,,,.F. )	    


	ACTIVATE DIALOG oDlg2 CENTERED 

	Pergunte(cPerg ,.f.)

Return 


//Função destinada a atualização do 2º browse de detalhamento
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

return   
//Função que faz o calculo de produto a produto
Static Function Calculo(_Prod) 

	//Query para calcular o que foi produzido
	cQuery1 := " SELECT SUM(ZU_QRCAIX) AS C_PROD,SUM(ZU_QRPESO) AS P_PROD FROM " + RetSQLTab('SZU') + "," + RetSQLTab('SB1') + "," + RetSQLTab('SBM')
	cQuery1 += " WHERE " + RetSQLFil('SZU') +  " AND " + RetSQLFil('SB1') + " AND "  + RetSQLFil('SBM')
	cQuery1 += " AND ZU_COD =  '" + alltrim(_Prod) + "' AND ZU_COD = B1_COD AND BM_GRUPO = B1_GRUPO AND BM_FARM = '" + _cFarm + "' AND B1_MSBLQL = '2' "
	cQuery1 += " AND ZU_DTRPRO = '" + dtos(ddatabase) + "' AND " + RetSQLDel('SZU') + " AND " + RetSQLDel('SB1') + " AND " + RetSQLDel('SBM')

	cQuery1  := ChangeQuery(cQuery1)

	If Select("QRY1")<>0
		QRY1->(dbCloseArea())
	Endif

	TCQUERY cQuery1 NEW ALIAS "QRY1"       


	//Query para calcular o que está previsto
	cQuery2 := "SELECT SUM(ZU_QPCAIX-ZU_QRCAIX) AS C_PREV , SUM(ZU_QPPESO-ZU_QRPESO)AS P_PREV "
	cQuery2 += " FROM " + RetSQLTab('SZU')  + "," + RetSQLTab('SB1') + "," + RetSQLTab('SBM') 
	cQuery2 += " WHERE " + RetSQLFil('SZU') + " AND " + RetSQLFil('SB1') + " AND " + RetSQLFil('SBM') 
	cQuery2 += " AND ZU_COD  = '" + alltrim(_Prod) + "' AND ZU_FECHADO = 'N' AND ZU_COD = B1_COD AND BM_GRUPO = B1_GRUPO AND BM_FARM = '" + _cFarm + "' AND B1_MSBLQL = '2' "
	cQuery2 += " AND ZU_DTRPRO = '" + dtos(ddatabase) + "' AND " + RetSQLDel('SZU') + " AND " + RetSQLDel('SB1') + " AND " + RetSQLDel('SBM')

	cQuery2 := ChangeQuery(cQuery2)

	If Select("QRY2")<>0
		QRY2->(dbCloseArea())
	Endif

	TCQUERY cQuery2 NEW ALIAS "QRY2"   


	//Acessa estoque atual do produto (SZI)
	SZI->(DbSetOrder(1))
	if SZI->(DbSeek(xfilial('SZI')+alltrim(_Prod)))
		_nEstCaix := SZI->ZI_QTCAIX
		_nEstPeso := SZI->ZI_QTPESO
	else
		_nEstCaix := 0
		_nEstPeso := 0   
	endif

	//Query pra calcular o que foi carregado
	cQuery4 := "SELECT SUM(ZZ5_QRCAIX) AS C_CAR, SUM(ZZ5_QRPESO) AS P_CAR "
	cQuery4 += " FROM " + RetSQLTab('ZZ5') + "," + RetSQLTab('ZZ4') + "," + RetSQLTab('SB1') + "," + RetSQLTab('SBM')  
	cQuery4 += " WHERE " + RetSQLFil('ZZ5') + " AND " + RetSQLFil('ZZ4') + " AND " + RetSQLFil('SB1') + " AND " + RetSQLFil('SBM') 
	cQuery4 += " AND ZZ5_COD  = '" + alltrim(_Prod) + "' AND ZZ5_COD = B1_COD AND BM_GRUPO = B1_GRUPO AND BM_FARM = '" + _cFarm + "' AND B1_MSBLQL = '2' "
	cQuery4 += " AND ZZ5_NUM = ZZ4_NUM AND "
	cQuery4 += " ZZ4_DATA = '" + dtos(ddatabase) + "'"
	cQuery4 += " AND ZZ4_TPOPER <> 'C'" 
	cQuery4 += " AND " + RetSQLDel('ZZ4')
	cQuery4 += " AND " + RetSQLDel('ZZ5')
	cQuery4 += " AND " + RetSQLDel('SB1')
	cQuery4 += " AND " + RetSQLDel('SBM')   
	cQuery4  := ChangeQuery(cQuery4)

	If Select("QRY4")<>0
		QRY4->(dbCloseArea())
	Endif

	TCQUERY cQuery4 NEW ALIAS "QRY4"

	//Query para calcular o empenho
	cQuery5 := " SELECT SUM(ZZ5_QPCAIX-ZZ5_QRCAIX) AS C_EMP, SUM(ZZ5_QPPESO-ZZ5_QRPESO) AS P_EMP   "
	cQuery5 += " FROM " + RetSQLTab('ZZ5') + "," + RetSQLTab('ZZ4')  + "," + RetSQLTab('SB1')  + "," + RetSQLTab('SBM') 
	cQuery5 += " WHERE  " + RetSQLFil('ZZ4') + " AND " + RetSQLFil('ZZ5') + " AND " + RetSQLFil('SB1') + " AND " + RetSQLFil('SBM')  
	cQuery5 += " AND ZZ5_STATUS <> 'E' AND ZZ5_COD = '" + alltrim(_Prod) + "' AND B1_COD = ZZ5_COD AND B1_GRUPO = BM_GRUPO AND B1_MSBLQL = '2' "
	cQuery5 += " AND ZZ5_NUM = ZZ4_NUM " 
	cQuery5 += " AND (ZZ4_DATA BETWEEN '" + DTOS(ddatabase-1) + "' AND '" + DTOS(ddatabase) + "') "
	cQuery5 += " AND ZZ4_TPOPER <> 'C' " 
	cQuery5 += " AND ZZ4_STATUS NOT IN('E','F','P') " 
	cQuery5 += " AND " + RetSqlDel('ZZ4') + " AND " + RetSQLDel('ZZ5') + " AND " + RetSQLDel('SB1') + " AND " + RetSQLDel('SBM')

	cQuery5  := ChangeQuery(cQuery5)

	If Select("QRY5")<>0
		QRY5->(dbCloseArea())
	Endif

	TCQUERY cQuery5 NEW ALIAS "QRY5"

return     

//Função destinada a seleção dos produtos que vão na consulta
Static Function SeleProd(_Comp)    

	//_cFarm := iif(mv_par01 = 1,'C',iif(mv_par01 = 2,'R', 'S'))

	cQuery := " SELECT B1_COD AS COD, B1_DESC"
	cQuery += " FROM " + RetSQLTab('SB1') + "," + RetSQLTab('SG1')  + "," + RetSQLTab('SBM')
	cQuery += " WHERE  " + RetSQLFil('SB1') + " AND "  + RetSQLFil('SG1') + " AND "  + RetSQLFil('SBM') 
	cQuery += " AND B1_COD = G1_COD AND B1_MSBLQL = '2' AND B1_TIPO IN('PA','PR') AND G1_COMP = '" + _Comp + "'"
	cQuery += " AND B1_GRUPO = BM_GRUPO AND BM_FARM = '" + _cFarm + "' AND B1_MSBLQL = '2' AND "
	cQuery += RetSqlDel('SB1') + " AND " + RetSQLDel('SG1') + " AND " + RetSQLDel('SBM')
	cQuery += " ORDER BY B1_DESC,B1_COD "

	//	* Mostrar a consulta */
	//@ 116,090 To 416,707 Dialog oDlgMemo Title "Consulta"
	//@ 055,005 Get cQuery Size 250,080 MEMO Object oMemo
	//Activate Dialog oDlgMemo


	cQuery  := ChangeQuery(cQuery)

	If Select("QRY")<>0
		QRY->(dbCloseArea())
	Endif

	TCQUERY cQuery NEW ALIAS "QRY"

return     

Static Function MontaA2(_Comp)

	aBrowse2 := {}

	SeleProd(_Comp)

	while QRY->(!eof())

		_nEstCaix := 0
		_nEstPeso := 0

		Calculo(QRY->COD)

		DbSelectArea('SB1')
		_cDesc  := fBuscaCPO('SB1',1,xfilial('SB1')+alltrim(QRY->COD),'B1_DESCRED')
		_cFam   := fBuscaCPO('SB1',1,xfilial('SB1')+alltrim(QRY->COD),'B1_FAM')

		if !empty(mv_par01)
			if _cFam <> mv_par01
				QRY->(DbSkip())
				loop
			endif
		endif

		if QRY2->C_PREV <= 0 .and.;
		QRY1->C_PROD <= 0 .and.;
		_nEstCaix    <= 0 .and.;
		QRY4->C_CAR  <= 0 .and.;
		QRY5->C_EMP  <= 0
			QRY->(DbSkip())
			loop 	   
		endif

		aadd(aBrowse2,{RetCores('B'),;
		alltrim(QRY->COD),;
		alltrim(_cDesc),;
		transform(iif(QRY2->C_PREV < 0 .or. QRY2->P_PREV < 0,0,QRY2->C_PREV),'@E 999,999'),;
		transform(iif(QRY2->C_PREV < 0 .or. QRY2->P_PREV < 0,0,QRY2->P_PREV),'@E 999,999,999.99'),;
		transform(QRY1->C_PROD,'@E 999,999'),;
		transform(QRY1->P_PROD,'@E 999,999,999.99'),;
		transform(_nEstCaix,'@E 999,999'),;
		transform(_nEstPeso,'@E 999,999,999.99'),;
		transform(QRY4->C_CAR,'@E 999,999'),;
		transform(QRY4->P_CAR,'@E 999,999,999.99'),;
		transform(QRY5->C_EMP,'@E 999,999'),;
		transform(QRY5->P_EMP,'@E 999,999,999.99'),;                     
		transform(iif(QRY2->C_PREV <= 0,0,QRY2->C_PREV) + _nEstCaix - QRY5->C_EMP,'@E 999,999'),;      
		transform(iif(QRY2->C_PREV <= 0,0,QRY2->P_PREV) + _nEstPeso - QRY5->P_EMP,'@E 999,999,999.99')})
		QRY->(DbSkip())
	enddo

return   

Static Function Atualiza(_Comp)

	DbSelectArea('SB1')
	_cDescri := fBuscaCPO('SB1',1,xfilial('SB1')+_Comp,'B1_DESC')

	MsgRun("Aguarde... Realizando atualização do produto " + _cDescri ,,{||MontaA2(_Comp)}) 

	if len(aBrowse2) <> 0
		AtuBrow2()           
	else
		aadd(aBrowse2,{RetCores('B'),;
		'',;
		'',;
		transform(0,'@E 999,999'),;
		transform(0,'@E 999,999,999.99'),;
		transform(0,'@E 999,999'),;
		transform(0,'@E 999,999,999.99'),;
		transform(0,'@E 999,999'),;
		transform(0,'@E 999,999,999.99'),;
		transform(0,'@E 999,999'),;
		transform(0,'@E 999,999,999.99'),;
		transform(0,'@E 999,999'),;
		transform(0,'@E 999,999,999.99'),;                     
		transform(0,'@E 999,999'),;      
		transform(0,'@E 999,999,999.99')})
		msgbox('Revise os parametros e atualize a consulta...','Produto sem movimentação ou estoque!','INFO')
	endif
return     

static function ProcAt()    
	MsgRun("Aguarde... Atualizando.." ,,{|| AtuBrow() })
return             

//Impressão do relatório pro Ivonzinho...
Static Function Relatorio()


	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Declaracao de Variaveis                                             ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ

	Local cDesc1         := "Este programa tem como objetivo imprimir relatorio  "
	Local cDesc2         := "de conferencia de estoque de Produto Acabado        "
	Local cDesc3         := "de acordo com os parâmetros apontados               "
	Local cPict          := "empresa"
	Local titulo         := "CONFERENCIA DE ESTOQUE DE PRODUTO ACABADO"
	Local nLin           := 80

	Local Cabec1         := "           Codigo          Descricao                                Caixas         Peso"                   
	Local Cabec2         := ""

	Local imprime        := .T.
	Local aOrd := {}
	Private lEnd         := .F.
	Private lAbortPrint  := .F.
	Private CbTxt        := ""
	Private limite       := 132
	Private tamanho      := "M"
	Private nomeprog     := "GJ196" // Coloque aqui o nome do programa para impressao no cabecalho
	Private nTipo        := 18
	Private aReturn      := { "Zebrado", 1, "Administracao", 2, 2, 1, "", 1}
	Private nLastKey     := 0
	Private cbtxt       := Space(10)
	Private cbcont      := 00
	Private CONTFL      := 01
	Private m_pag       := 01
	Private wnrel       := "GJF196" // Coloque aqui o nome do arquivo usado para impressao em disco    
	Private cPerg       := ''	                         
	//pergunte(cPerg,.f.)


	wnrel := SetPrint('ZAI',NomeProg,cPerg,@titulo,cDesc1,cDesc2,cDesc3,.T.,aOrd,.T.,Tamanho,,.T.)


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

	Local nOrdem
	Local i

	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ SETREGUA -> Indica quantos registros serao processados para a regua ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ

	_nTamBrowse := len(aBrowse1)

	SetRegua(_nTamBrowse)

	_cAux := ''

	for i := 1 to _nTamBrowse

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

		do case
			case mv_par01 = 1
			@nlin,005 psay 'PRODUTOS RESFRIADOS' 	
			nlin+=3
			case mv_par01 = 2
			@nlin,005 psay 'PRODUTOS CONGELADOS' 					
			nlin+=3
			case mv_par01 = 3
			@nlin,005 psay 'PRODUTOS SALGADOS' 					
			nlin+=3
			case mv_par01 = 4
			@nlin,005 psay 'PRODUTOS MIUDOS/RECORTE' 					
			nlin+=3		   
		endcase

		@nlin,010 psay aBrowse1[i,2]
		@nlin,025 psay substr(aBrowse1[i,3],1,35)	 
		@nlin,065 psay aBrowse1[i,8]	 
		@nlin,073 psay aBrowse1[i,9]	 
		nlin++

		SeleProd(aBrowse1[i,2]) 
		while QRY->(!eof())	

			//Acessa estoque atual do produto (SZI)
			SZI->(DbSetOrder(1))
			if SZI->(DbSeek(xfilial('SZI')+alltrim(QRY->COD)))
				_nEstCaix := SZI->ZI_QTCAIX
				_nEstPeso := SZI->ZI_QTPESO
				_nTotCx	 += SZI->ZI_QTCAIX
				_nTotPs   += SZI->ZI_QTPESO
			else
				_nEstCaix := 0
				_nEstPeso := 0   
			endif

			if _nEstCaix > 0 .or. _nEstPeso > 0	                  
				@nlin,010 psay QRY->COD
				@nlin,025 psay substr(QRY->B1_DESC,1,35)
				@nlin,065 psay transform(_nEstCaix,'@E 999,999')
				@nlin,077 psay transform(_nEstPeso,'@E 999,999.99')
				nlin++	
			endif 					   			

			QRY->(DbSkip())

			If nLin > 70 // Salto de Página. Neste caso o formulario tem 55 linhas...
				Cabec(Titulo,Cabec1,Cabec2,NomeProg,Tamanho,nTipo)
				nLin := 9
			Endif
		enddo 
		@nlin,050 psay substr('TOTAL:',1,35)
		@nlin,065 psay transform(_nTotCx,'@E 999,999')
		@nlin,073 psay transform(_nTotPs,'@E 999,999,999.99')
		nlin++
		@nlin,001 psay replicate('-',132)
		nlin++

	next
	If nLin > 70 // Salto de Página. Neste caso o formulario tem 55 linhas...
		Cabec(Titulo,Cabec1,Cabec2,NomeProg,Tamanho,nTipo)
		nLin := 9
	Endif   
	@nlin,001 psay replicate('-',132)
	nlin++    

	@nlin,050 psay 'TOTAIS:'
	@nlin,065 psay 'EST. CAIXA'
	@nlin,080 psay 'EST. PESO'
	nlin++ 	
	@nlin,065 psay Transform(_aTotais1[3,1],'@E 999,999')//estoque caixa
	@nlin,077 psay Transform(_aTotais1[3,2],'@E 999,999.99')//estoque peso   
	nlin++
	@nlin,050 psay 'TOTAIS:'
	@nlin,065 psay 'EMP. CAIXA'
	@nlin,080 psay 'EMP. PESO'
	nlin++
	@nlin,065 psay Transform(_aTotais1[5,1],'@E 999,999')//empenho caixa
	@nlin,077 psay Transform(_aTotais1[5,2],'@E 999,999.99')//empenho peso

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
