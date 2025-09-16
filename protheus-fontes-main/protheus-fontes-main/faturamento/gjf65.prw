#INCLUDE "rwmake.ch"
#INCLUDE "topconn.ch"   

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณGJF65     บAutor  ณGiuliano Forgiarini บ Data ณ  09/25/13   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณ Impressใo de Certificados SIF 2ช Edi็ใo                    บฑฑ
ฑฑบ          ณ                                                            บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ Faturamento                                                บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/

User Function GJF65()

	Private lInverte := .f.
	Private cMark   := GetMark()  
	Private oMark
	cPerg    := "CSIF" + cFilAnt

	nCont 	:= .f.		// Verifica se o formulario esta posicionado

	if !Pergunte(cPerg, .T.)
		return
	endif
	//Do While Pergunte(cPerg, .T.)

	_cNotas   := ''
	_nLastRec := 0

	_cQuery := " SELECT * FROM " + RetSQLTab('SF2') + " WHERE "
	_cQuery +=  RetSQLFil('SF2') + " AND "
	_cQuery += " F2_DOC BETWEEN '" + mv_par01 + "' AND '" + mv_par02 + "' AND"
	_cQuery += " F2_SERIE = '" + mv_par03 + "' AND"
	_cQuery +=  RetSQLDel('SF2')
	_cQuery += " ORDER BY F2_DOC " 

	_cQuery := ChangeQuery(_cQuery)

	If Select("TMP")<>0
		TMP->(dbCloseArea())
	Endif

	If Select("RES")<>0
		RES->(dbCloseArea())
	Endif

	aCampos := {}     

	aadd(aCampos,{ "F2_OK"	    ,, "OK"       ,"@!"})
	aadd(aCampos,{ "F2_DOC"	    ,, "Doc"      ,"@!"})
	aadd(aCampos,{ "F2_SERIE"   ,, "Serie"    ,"@!"})
	aadd(aCampos,{ "F2_CLIENTE" ,, "Cliente"  ,"@!"})
	aadd(aCampos,{ "F2_LOJA"    ,, "Loja"     ,"@!"})

	TCQUERY _cQuery NEW ALIAS "RES"  

	//cArq  := CriaTrab( Nil, .F. )                                                 //Cria arquivo temporแrio
	_aArqTrb := {}
	aStru := {}                                          

	AADD(aStru,{"F2_OK"      ,"C"	,2		,0		})
	AADD(aStru,{"F2_DOC"     ,"C"	,9		,0		})
	AADD(aStru,{"F2_SERIE"   ,"C"	,3		,0		})
	AADD(aStru,{"F2_CLIENTE" ,"C"	,6		,0		})
	AADD(aStru,{"F2_LOJA"    ,"C"	,2		,0		})

	//dbcreate(cArq,aStru)                                                          //Cria a estrutura do vetor no TMP criado 
	//dbUseArea( .T.,,cArq,"TMP", .F. , .F. )

	If Select('TMP')<>0                                  //Se um tmp com alias TMP existir, fecha-o
		TMP->(dbCloseArea())
		u_arqtrb ("FechaTodos",,,, @_aArqTrb)
	Endif

	U_ArqTrb("Cria", "TMP", aStru, {}, @_aArqTrb)

	RES->(dbgotop()) 
	while RES->(!eof()) 
		DbSelectArea('TMP')
		reclock('TMP',.t.)
		TMP->F2_DOC     := RES->F2_DOC
		TMP->F2_SERIE   := RES->F2_SERIE
		TMP->F2_CLIENTE := RES->F2_CLIENTE
		TMP->F2_LOJA    := RES->F2_LOJA
		msunlock()
		RES->(dbskip())
	enddo

	TMP->(dbgotop())   	

	DEFINE MSDIALOG oDlg TITLE "Emissao de Certificado SIF" From 9,0 To 400,800 PIXEL
	oMark := MsSelect():New("TMP","F2_OK","",aCampos,@lInverte,@cMark,{17,1,160,400},,,,,) 
	oMark:bMark := {| | Disp()}        

	TButton():New(170, 020, "Imprimir"    , oDlg,{|| Processa({|| ProcSIF(1)}) },40,020,,,.F.,.T.,.F.,,.F.,,,.F. )   
	TButton():New(170, 070, "Imp.Invert." , oDlg,{|| Processa({|| ProcSIF(2)}) },40,020,,,.F.,.T.,.F.,,.F.,,,.F. )   
	TButton():New(170, 300, "Sair"        , oDlg,{|| oDlg:end() },40,020,,,.F.,.T.,.F.,,.F.,,,.F. )

	ACTIVATE MSDIALOG oDlg CENTERED 

Return(.T.)

Static Function Disp()

	RecLock("TMP",.F.)
	If Marked("F2_OK")	   
		TMP->F2_OK := cMark
	Else     
		TMP->F2_OK := ""
	Endif             

	msunlock()
	oMark:oBrowse:Refresh()

Return

Static Function ProcSIF(mod)

	_cNotas  := ''        

	oDlg:end()

	TMP->(DbGotop())

	Do While TMP->(!eof())     

		if mod = 1
			if !empty(TMP->F2_OK)
				_cNotas += "'" + TMP->F2_DOC + "',"
			endif
		else
			if empty(TMP->F2_OK)
				_cNotas += "'" + TMP->F2_DOC + "',"
			endif		
		endif


		TMP->(DbSkip())
	EndDo

	IncProc()
	If empty(_cNotas)// se nao foi escolhida nenhuma nota
		MsgBox("Nenhuma nota selecionada!","ATENCAO!!!","YESNO")
		Return
	EndIf

	_cNotas := Substr(_cNotas,1,Len(_cNotas)-1)
	_cIn    := strtran(alltrim(mv_par22),",","','") 
	_cQuery := "SELECT Z3_DESCRED, Z3_ESPSIF, Z3_COMEST, D2_DOC, D2_SERIE,D2_UM, D2_SEGUM, D2_QTSEGUM, D2_QUANT, B1_CORORI,BM_FARM "
	_cQuery += " FROM " + RetSqlTab("SB1") + "," + RetSqlTab("SZ3") + "," + RetSqlTab("SD2") + "," + RetSqlTab("SBM")
	_cQuery += " WHERE "
	_cQuery +=  RetSQLFil('SZ3')+ " AND " + RetSQLFil('SB1') + " AND " + RetSQLFil('SD2') + " AND " + RetSQLFil('SBM')   
	_cQuery += " AND Z3_ESPSIF = B1_ESPSIF AND B1_COD = D2_COD  AND B1_MSBLQL <> '1' AND BM_GRUPO = B1_GRUPO"
	_cQuery += " AND D2_SERIE = '" + mv_par03 + "'"
	_cQuery += " AND D2_DOC IN (" + _cNotas + ")"
	_cQuery += " AND " + RetSQLDel('SZ3') + " AND " + RetSQLDel('SB1') + " AND " + RetSQLDel('SD2') + " AND " + RetSQLDel('SBM')
	_cQuery += " ORDER BY BM_FARM, Z3_DESCRED,D2_SEGUM" 

	//	* Mostrar a consulta */
	//@ 116,090 To 416,707 Dialog oDlgMemo Title "Consulta"
	//@ 055,005 Get _cQuery Size 250,080 MEMO Object oMemo
	//Activate Dialog oDlgMemo

	DbUseArea(.t.,'TOPCONN',TcGenQry(,,_cQuery),'TRB',.f.,.f.)

	_cNF := TRB->D2_DOC
	count for D2_DOC = _cNF to _nQtdNFS
	count to _nLastRec

	DbGoTop()
	IncProc()
	If _nLastRec > 0
		ML_EMITE()
	Else
		MsgBox('Nao ha registros para listar.','ATENCAO!!!','STOP')
	EndIf

	If Select('TRB') > 0
		DbSelectArea('TRB')
		DbCloseArea()
	EndIf


Return

///////////////////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////////////////
Static Function ML_EMITE()
	//////////////////////////

	cSavCur1 := cSavRow1 := cSavCol1 := cSavCor1 := cSavScr1 := wnrel := ''
	Tamanho  := "P"
	titulo   := "EMISSAO DO CERTIFICADO "
	cDesc1   := "Emissao do certificado nas notas fiscais de saidas"
	cDesc2   := ""
	cDesc3   := ""
	aReturn  := { "Zebrado", 1,"Administracao", 2, 1, 1, "",0 }
	nomeprog := wnrel := "GJF65"
	nLastKey := 0
	nBegin   := 0
	aLinha   := { }
	limite   := 132
	cString  := "SD2"

	SetPrint(cString,wnrel,,@Titulo,cDesc1,cDesc2,cDesc3,.F.,"",,tamanho)

	If LastKey()=27 .or. nLastKey=27
		Return
	EndIf

	SetDefault(aReturn,cString)

	If LastKey()=27 .OR. nLastKey=27
		Return
	EndIf

	Do While !nCont .and. aReturn[5] <> 1
		nCont := MsgBox("Formulario posicionado..? ","Relatorio","YESNO")
	EndDo
	RptStatus({|| RunReport()})

Return

///////////////////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////////////////
Static Function RunReport()
	///////////////////////////
	Local i
	Local j
	_nPos    := 0       
	_nPos2   := 0
	_aEstru  := {}
	_aNF     := {}
	_cEsp    := ''   

	DbSelectArea("TRB")

	TRB->(DbGoTop())  

	Do While TRB->(!Eof())


		_nPos  := aScan(_aEstru,{|aVal| aVal[1] = TRB->BM_FARM     .and.;
		aVal[2] = TRB->Z3_DESCRED  .and.;
		aVal[3] = TRB->D2_SEGUM    .and.;
		aVal[4] = TRB->Z3_COMEST})  

		//Monta um vetor com todos os elementos do certificado
		if _nPos <> 0
			_aEstru[_nPos,5] += TRB->D2_QUANT
			_aEstru[_nPos,6] += TRB->D2_QTSEGUM
		else
			aadd(_aEstru,{TRB->BM_FARM,TRB->Z3_DESCRED,TRB->D2_SEGUM,TRB->Z3_COMEST,TRB->D2_QUANT,TRB->D2_QTSEGUM})
		endif            //     1                 2               3              4             5               6                 

		_nPos2 := aScan(_aNF,TRB->D2_DOC)

		//Monta um vetor com os numeros da NF
		if _nPos2 = 0
			aadd(_aNF,TRB->D2_DOC)
		endif 	

		TRB->(DbSkip())	

	EndDo


	//Inicio do processo de impressใo
	_lPag    := .t.
	_nLin    :=  2  

	aSort(_aNF)

	_Fim := len(_aNF)

	_cNFIni := _aNF[1] 
	_cNFFim := _aNF[_Fim]

	_nPosResf := aScan(_aEstru,{|aVal| 'RESFR' $ aVal[2] })
	_nPosCong := aScan(_aEstru,{|aVal| 'CONG' $ aVal[2] })

	for i := 1 to len(_aEstru)   

		_xComest := iif(_aEstru[i,4] = "S", "COMESTIVEL", "NAO COMESTIVEL")

		if _lPag   
			SetPrc(0,0)
			@ _nLin, 100 pSay _xComest
			_nLin+=08                  
			_lPag := .f.
		endif

		_cEspVol := fBuscaCPO('SAH',1,xfilial('SAH')+_aEstru[i,3],'AH_UMRES')

		@ _nLin, 003 pSay iif(_aEstru[i,3] = 'CX'    .and.;
		!("MIUDO"   $ _aEstru[i,2]) .and.;
		!("CHARQUE" $ _aEstru[i,2])      , alltrim(_aEstru[i,2])+" (CORTES)", _aEstru[i,2])  
		@ _nLin, 070 pSay _aEstru[i,5]  Picture "@E 99,999.99"
		@ _nLin, 090 pSay _aEstru[i,6]  Picture "99999"   // _cVolumes Evandro
		@ _nLin, 105 pSay _cEspVol                   // _cEspecie Evandro	

		_nLin++		
	next      

	//Mensagens
	if !empty(mv_par13)
		@ _nLin   , 003 pSay mv_par13   
		_nLin++
		i++
	endif

	if !empty(mv_par14)
		@ _nLin   , 003 pSay mv_par14   
		_nLin++
		i++
	endif

	if !empty(mv_par15)
		@ _nLin   , 003 pSay mv_par15   
		_nLin++
		i++
	endif

	if !empty(mv_par16)
		@ _nLin   , 003 pSay mv_par16   
		_nLin++
		i++
	endif

	if i < 9
		i := 9 - i
		for j := 1 to i
			@ _nLin, 003 pSay 'X' + space(10) + 'X' + space(10) + 'X'
			@ _nLin, 070 pSay 'X'  
			@ _nLin, 090 pSay 'X'  
			@ _nLin, 105 pSay 'X'
			_nLin++
		next
	endif

	Fechaform()	

	If aReturn[5]=1
		dbcommitAll()
		ourspool(wnrel)
	Endif

	SetPgEject(.F.) 
	MS_FLUSH()

	TRA->(DbCloseArea())
	TRB->(DbCloseArea())

	//fErase(_cArq + '.dbf')
	//fErase(_cArq + '.cdx')

Return


Static Function FechaForm()
	_cMun    := ''
	_cSequen := ""
	_nLin++

	@ _nLin+=1, 022 pSay "(Cfe. Obs NF) "    

	@ _nLin, 065 pSay "Temp.: "+iif(_nPosResf <> 0 .and. _nPosCong <> 0,mv_par05 + " / " + mv_par04,;
	iif(_nPosResf <> 0 .and. _nPosCong =  0,mv_par05,;
	iif(_nPosResf =  0 .and. _nPosCong <> 0,mv_par04,''))) 

	@ _nLin+=1, 003 pSay iif( !empty(mv_par17) .and. !empty(mv_par18),"Data de Produ็ใo: " + dtoc(mv_par17)  + "    /    Data de Validade: " + dtoc(mv_par18),"")    

	@ _nLin+=1, 003 pSay "Obs NF: " + iif(_cNFIni <> _cNFFim, _cNFIni + ' a ' + _cNFFim ,_cNFIni)

	@ ++_nLin , 025 pSay iif(empty(SM0->M0_CIDENT),alltrim(SM0->M0_CIDCOB) + " - " + SM0->M0_ESTCOB,alltrim(SM0->M0_CIDENT)+" - "+SM0->M0_ESTENT)
	@ _nLin   , 092 pSay left(SM0->M0_NOMECOM,41)

	@ ++_nLin , 025 pSay mv_par06

	If _cNFIni <> _cNFFim  .and. _aEstru[1,4] = "S"		// verifica se ha mais de uma nota fiscal
		_xCliente := "DIVERSOS"
	Else
		SF2->(DbSeek(xFilial("SF2") + _cNFIni + mv_par03) )   

		If SF2->F2_TIPO $ "DB"
			_xCliente := alltrim(fBuscaCPO('SA2', 1, xFilial('SA2') + SF2->F2_CLIENTE + SF2->F2_LOJA, 'A2_NOME'))
			_cMun     := alltrim(fBuscaCPO('SA2', 1, xFilial('SA2') + SF2->F2_CLIENTE + SF2->F2_LOJA, 'A2_MUN'))
		Else
			_xCliente := alltrim(fBuscaCPO('SA1', 1, xFilial('SA1') + SF2->F2_CLIENTE + SF2->F2_LOJA, 'A1_NOME')) 
			_cMun     := alltrim(fBuscaCPO('SA1', 1, xFilial('SA1') + SF2->F2_CLIENTE + SF2->F2_LOJA, 'A1_MUN'))		
		EndIf
	EndIf
	@ _nLin   , 092 pSay _xCliente

	@ ++_nLin , 035 pSay "SIF: " + alltrim(mv_par07)
	@ _nLin   , 050 pSay iif(empty(mv_par08),".","SIF: " + alltrim(mv_par08))
	@ _nLin   , 092 pSay left(SM0->M0_NOMECOM,41)

	@ ++_nLin , 025 pSay "RODOVIARIO - PLACA: " + alltrim(mv_par10)
	@ _nLin   , 092 pSay iif(!empty(_cMun),alltrim(_cMun),'DIVERSOS')

	@ ++_nLin , 035 pSay alltrim(mv_par09)
	@ _nLin   , 092 pSay left(mv_par11,41)

	@ _nLin+=1, 077 pSay mv_par12 Picture "99"
	@ _nLin+=3, 060 pSay SM0->M0_CIDENT
	@ _nLin   , 085 pSay Strzero(day(dDataBase),2)
	@ _nLin   , 100 pSay MesExtenso(month(dDataBase))
	@ _nLin   , 125 pSay str(year(dDataBase),4)


	_xQtLin := 0
	_nLin   := 0
Return

