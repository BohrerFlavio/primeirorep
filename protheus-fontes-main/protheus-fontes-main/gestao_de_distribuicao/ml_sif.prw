#INCLUDE "rwmake.ch"
#INCLUDE "topconn.ch"   

// Programa: ML_SIF
// Autor...: Alexandre Dalpiaz
// Data....: 23/06/03
// Funcao..: Emissao do certIficados de inspecao sanitaria

///////////////////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////////////////
User Function ML_SIF()
	///////////////////////
	Local _aArqTrb      := {} // ProcData 04/2023
	
	Private lInverte := .f.
	Private cMark   := GetMark()  
	Private oMark
	cPerg    := "CSIF" + cFilAnt
	cDelFunc := ".T."
	ValidPerg()
	nCont 	:= .f.// Verifica se o formulario esta posicionado

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

	//cArq  := CriaTrab( Nil, .F. )                                                 //Cria arquivo temporário
	aStru := {}                                          

	AADD(aStru,{"F2_OK"      ,"C"	,2		,0		})
	AADD(aStru,{"F2_DOC"     ,"C"	,9		,0		})
	AADD(aStru,{"F2_SERIE"   ,"C"	,3		,0		})
	AADD(aStru,{"F2_CLIENTE" ,"C"	,6		,0		})
	AADD(aStru,{"F2_LOJA"    ,"C"	,2		,0		})

	//dbcreate(cArq,aStru)                                                          //Cria a estrutura do vetor no TMP criado 
	//dbUseArea( .T.,,cArq,"TMP", .F. , .F. )

	// ProcData 04/2023 - Chamada para criação do arquivo de trabalho
	U_ArqTrb("Cria", "TMP", aStru, {}, @_aArqTrb)
	
	RES->(dbgotop()) 
	while RES->(!eof()) 

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

	TButton():New(170, 020, "Imprimir"    , oDlg,{|| Processa({|| U_ProcSIF(1)}) },40,020,,,.F.,.T.,.F.,,.F.,,,.F. )   
	TButton():New(170, 070, "Imp.Invert." , oDlg,{|| Processa({|| U_ProcSIF(2)}) },40,020,,,.F.,.T.,.F.,,.F.,,,.F. )   
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
Return()

///////////////////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////////////////
User Function ProcSIF(mod)
	/////////////////////////

	_cNotas   := ''        

	TMP->(DbGotop())

	Do While TMP->(!eof())     
		//+ iif(mod=1," AND F2_OK <> '' AND "," AND F2_OK = '' AND ") 	
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
	//202304 - colocado nome na coluna do X5
	_cQuery := "SELECT Z3_DESCRI, Z3_ESPSIF, Z3_TIPO, X5_DESCRI as DESCRI, Z3_COMEST, D2_DOC, Z3_AGLUT,D2_UM,"
	_cQuery += 	     " D2_SEGUM, "
	_cQuery += 	     " D2_QTSEGUM, "
	_cQuery += 	     " D2_QUANT, "
	//_cQuery += 	     " (CASE WHEN D2_UM = 'KG' THEN D2_SEGUM ELSE D2_UM END), "
	//_cQuery += 	     " (CASE WHEN D2_UM = 'KG' THEN D2_QTSEGUM ELSE D2_QUANT END) D2_QTSEGUM, "
	//_cQuery += 	     " (CASE WHEN D2_UM = 'KG' THEN D2_QUANT ELSE D2_QTSEGUM END) D2_QUANT, "
	_cQuery += " (CASE WHEN RTRIM(D2_CF) IN ('" + _cIn + "') THEN '" + alltrim(mv_par15) + "' ELSE RTRIM(A1_MUN) + '/' + A1_EST END) A1_MUN "
	_cQuery += " FROM " + RetSqlName("SX5") + " SX5, "
	_cQuery +=            RetSqlName("SB1") + " SB1, " + RetSqlName("SZ3") + " SZ3, "
	_cQuery +=            RetSqlName("SA1") + " SA1, " + RetSqlName("SD2") + " SD2 "
	_cQuery += " WHERE "
	_cQuery +=  RetSQLFil('SX5')
	_cQuery += " AND " + RetSQLFil('SZ3')
	_cQuery += " AND " + RetSQLFil('SB1')
	_cQuery += " AND " + RetSQLFil('SA1')
	_cQuery += " AND " + RetSQLFil('SD2')   
	_cQuery += " AND SX5.X5_TABELA = '98'"
	_cQuery += " AND SX5.X5_CHAVE = SB1.B1_CLSIF"
	_cQuery += " AND SZ3.Z3_ESPSIF = SB1.B1_ESPSIF"
	_cQuery += " AND SB1.B1_COD = SD2.D2_COD"  
	_cQuery += " AND SB1.B1_MSBLQL <> '1' "
	_cQuery += " AND SA1.A1_COD = SD2.D2_CLIENTE"
	_cQuery += " AND SA1.A1_LOJA = SD2.D2_LOJA"
	_cQuery += " AND SA1.A1_MSBLQL <> '1'"
	_cQuery += " AND SD2.D2_SERIE = '" + mv_par03 + "'"
	_cQuery += " AND SD2.D2_DOC IN (" + _cNotas + ")"
	_cQuery += " AND " + RetSQLDel('SX5')
	_cQuery += " AND " + RetSQLDel('SZ3')
	_cQuery += " AND " + RetSQLDel('SB1')
	_cQuery += " AND " + RetSQLDel('SA1')
	_cQuery += " AND " + RetSQLDel('SD2')

	_cQuery += " ORDER BY A1_MUN, Z3_COMEST, Z3_ESPSIF"
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

	oDlg:end()

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
	nomeprog := wnrel := "ML_SIF"
	nLastKey := 0
	nBegin   := 0
	aLinha   := { }
	limite   := 132
	cString  := "SD2"

	SetPrint(cString,wnrel,,@Titulo,cDesc1,cDesc2,cDesc3,.F.,"",,tamanho)

	If LastKey()=27 .or. nLastKey=27
		Return
	EndIf

	fErase(__RelDir + wnrel + '.##r')
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
	Local nn
	Local _nI
	Local _aArqTrb      := {} // ProcData 04/2023
	
	_aEstru := {}
	aAdd(_aEstru, {'INDICE'  , 'C',  80, 0})
	aAdd(_aEstru, {'ESPECIE' , 'C', 250, 0})
	aAdd(_aEstru, {'PESO'    , 'N',  12, 2})
	aAdd(_aEstru, {'VOLUMES' , 'N',  05, 0})
	aAdd(_aEstru, {'NAT_VOL' , 'C',  32, 0})
	
	
	//_cArq := CriaTrab(_aEstru,.t.)
	//DbUseArea(.t.,,_cArq,'TRA',.t.,.f.)
	//Index on INDICE to &_cArq
	
	// ProcData 04/2023 - Chamada para criação do arquivo de trabalho
	U_ArqTrb("Cria", "TRB", _aEstru, {}, @_aArqTrb)	

	_cTeste	= 'N'

	DbSelectArea("TRB")
	Do While !Eof()

		_cMun    := TRB->A1_MUN

		Do While _cMun = TRB->A1_MUN .and. !eof()	// agrupa por municipio

			DbSelectArea('TRA')
			DbGoTop()
			Do While !eof()
				RecLock('TRA',.f.)
				DbDelete()
				MsUnLock()
				DbSkip()
			EndDo
			DbGoTop()

			DbSelectArea('TRB')

			_xComest := iif(TRB->Z3_COMEST = "S", "COMESTIVEL", "NAO COMESTIVEL")
			_aTemp   := {}							// array com as temperaturas
			_aNF     := {}							// array com as notas fiscais no certificado

			_cComest := TRB->Z3_COMEST
			Do While _cMun = TRB->A1_MUN .and. _cComest = TRB->Z3_COMEST .and. !eof()	// agrupa por comestivel / nao comestivel

				If aScan(_aNF, TRB->D2_DOC) = 0			// notas fiscais
					aAdd(_aNF, TRB->D2_DOC)
				EndIf

				If aScan(_aTemp, TRB->Z3_TIPO) = 0		// temperaturas
					aAdd(_aTemp, TRB->Z3_TIPO)
				EndIf

				DbSelectArea('TRA')
				_cNatVol := Posicione('SAH',1,xFilial('SAH') + iif(TRB->D2_UM = 'KG',TRB->D2_SEGUM,TRB->D2_UM),'AH_UMRES')

				If TRB->Z3_AGLUT = 'N'
					If !DbSeek(alltrim(_cNatVol) + alltrim(TRB->Z3_DESCRI)+'('+ alltrim(TRB-DESCRI) + ')', .f.)
						RecLock('TRA',.t.)
						TRA->ESPECIE := alltrim(TRB->Z3_DESCRI) + '(' + alltrim(TRB->DESCRI) + ')'
						TRA->INDICE  := alltrim(_cNatVol) + left(TRA->ESPECIE,60)
						TRA->PESO    := iif(TRB->D2_UM = 'KG',TRB->D2_QUANT,TRB->D2_QTSEGUM)
						TRA->VOLUMES := iif(TRB->D2_UM = 'KG',TRB->D2_QTSEGUM,TRB->D2_QUANT)
						TRA->NAT_VOL := _cNatVol
					Else
						RecLock('TRA',.f.)
						TRA->PESO    += iif(TRB->D2_UM = 'KG',TRB->D2_QUANT,TRB->D2_QTSEGUM)     
						TRA->VOLUMES += iif(TRB->D2_UM = 'KG',TRB->D2_QTSEGUM,TRB->D2_QUANT)
					EndIf
					MsUnLock()
				Else
					If !DbSeek(alltrim(_cNatVol) + alltrim(TRB->Z3_DESCRI)+'(', .f.)
						RecLock('TRA',.t.)
						TRA->ESPECIE := alltrim(TRB->Z3_DESCRI) + '(' + alltrim(TRB->DESCRI) + ','
						TRA->INDICE  := alltrim(_cNatVol) + left(TRA->ESPECIE,60)
						TRA->PESO    := iif(TRB->D2_UM = 'KG',TRB->D2_QUANT,TRB->D2_QTSEGUM)     
						TRA->VOLUMES := iif(TRB->D2_UM = 'KG',TRB->D2_QTSEGUM,TRB->D2_QUANT)
						TRA->NAT_VOL := _cNatVol
					Else
						RecLock('TRA',.f.)
						If !(alltrim(TRB->DESCRI)+',' $ TRA->ESPECIE)
							TRA->ESPECIE := alltrim(TRA->ESPECIE) + alltrim(TRB->DESCRI) + ','
						EndIf
						TRA->INDICE  := left(TRA->INDICE,80)
						TRA->PESO    += iif(TRB->D2_UM = 'KG',TRB->D2_QUANT,TRB->D2_QTSEGUM)     
						TRA->VOLUMES += iif(TRB->D2_UM = 'KG',TRB->D2_QTSEGUM,TRB->D2_QUANT)
						If !(alltrim(_cNatVol) $ TRA->NAT_VOL)
							TRA->NAT_VOL  := alltrim(TRA->NAT_VOL) + ',' + alltrim(Posicione('SAH',1,xFilial('SAH') + iif(TRB->D2_UM = 'KG',TRB->D2_SEGUM,D2_UM),'AH_UMRES'))
						EndIf
					EndIf
					MsUnLock()
				EndIf
				DbSelectArea('TRB')
				DbSkip()

			EndDo


			For nn := 16 to 21

				_cVar := "mv_par" + Strzero( nn,2 )   
				If !empty(&_cVar)

					If nn =16  
						_cMens := "Data de Producao: " + alltrim(mv_par16)
					ElseIf nn = 17 
						_cMens := "Data de Validade: " + alltrim(mv_par17)
					Else
						_cMens := alltrim(&_cVar)
					EndIf

					RecLock('TRA',.t.)
					TRA->ESPECIE := _cMens
					TRA->INDICE  := 'Z99' + Strzero( nn,2 ) + left(TRA->INDICE,50)
					MsUnLock()

				EndIf

			Next

			///////// aqui começa a impressao do certificado

			aSort(_aTemp)
			_cTemp  := ''
			For _nI := 1 to len(_aTemp)
				If _aTemp[_nI] = 'A'
					_cTemp += "Ambiente"
				EndIf
				If _aTemp[_nI] = 'C'
					_cTemp += iif(!empty(_cTemp),' / ','') + alltrim(mv_par04)
				EndIf
				If _aTemp[_nI] = 'R'
					_cTemp += iif(!empty(_cTemp),' / ','') + alltrim(mv_par05)
				EndIf
			Next

			SetPrc(0,0)
			_nLin := 0
			@ 000,000 pSay chr(15)
			If _nLin = 0 .and. aReturn[5] <> 1
				//@ 000 , 000 pSay chr(27)+"2"  // inicia impressao em sexto
			EndIf
			@ _nLin+=05, 100 pSay _xComest   // ERA _nLin+=05
			_nLin+=06								// ERA 	_nLin+=07


			DbSelectArea('TRA')
			DbGoTop()

			_nQtLin := 0
			Do While !eof()
				_nAux   := len(alltrim(TRA->ESPECIE)) / 65
				_nQtLin := _nQtLin + iif(int(_nAux)=_nAux,0,1)
				DbSkip()
			EndDo
			DbGoTop()

			_xQtLin := 0
			Do While !eof()

				If left(TRA->INDICE,3) <> 'Z99'	// imprime itens

					RecLock('TRA',.f.)
					TRA->ESPECIE := left(TRA->ESPECIE,len(alltrim(TRA->ESPECIE))-1) + ')'
					MsUnLock()

					_nPosic := 0
					_nTam   := len(alltrim(TRA->ESPECIE))
					_nImpr  := 0
					Do While _nImpr < _nTam

						_cEspecie := alltrim(substr(TRA->ESPECIE,_nImpr+1,65))
						For _nI := len(_cEspecie) to 1 step -1
							_nPosic := _nI
							If substr(_cEspecie,_nI,1) $ ',) '
								Exit
							EndIf
						Next
						_nImpr += _nPosic

						If ++_xQtLin > 8 .and. _nQtLin > 9 .and. !eof()	// inicia novo formulario
							_nQtLin -= 8
							++_xQtLin
							@ ++_nLin  , 003 pSay 'Continua no proximo formulario...'
							FechaForm()   
							setprc(0,0)
							@ _nLin+=05 , 100 pSay _xComest  //era 04
							++_xQtLin
							@ _nLin+=09 , 003 pSay '...Continuacao do formulario anterior'
							_cTeste	:= 'S'
						EndIf

						@ ++_nLin, 003 pSay left(_cEspecie,_nPosic)


					EndDo

					_cVolume := 0

					If _nQtdNFS = _nLastRec	//  se for somente uma nota

						_cQuery := "SELECT DISTINCT C5_ESPECI1, C5_VOLUME1"
						_cQuery += " FROM " + RetSqlName('SC5') + " SC5, " + RetSqlName('SC6') + " SC6"
						_cQuery += " WHERE C5_NUM = C6_NUM"
						_cQuery +=   " AND SC5.D_E_L_E_T_ <> '*'"
						_cQuery +=   " AND SC6.D_E_L_E_T_ <> '*'"
						_cQuery +=   " AND C6_NOTA = '" + _cNF + "'"
						_cQuery +=   " AND C5_FILIAL = '" + xFilial('SC5') + "'"
						_cQuery +=   " AND C6_FILIAL = '" + xFilial('SC6') + "'"

						DbUseArea(.t.,'TOPCONN',TcGenQry(,,_cQuery),'TRC',.f.,.f.)
						_cVolume  := TRC->C5_VOLUME1
						_cEspecie := TRC->C5_ESPECI1
						DbCloseArea()

						DbSelectArea('TRA')

					EndIf

					If empty(_cEspecie)

						_cVolume  := TRA->VOLUMES
						_cEspecie := TRA->NAT_VOL

					EndIf

					@ _nLin, 070 pSay TRA->PESO    Picture "@E 99,999.99"
					@ _nLin, 090 pSay TRA->VOLUMES Picture "99999"   // _cVolumes Evandro
					@ _nLin, 105 pSay TRA->NAT_VOL                   // _cEspecie Evandro

				Else										// imprime mensagens

					@ ++_nLin, 003 pSay alltrim(TRA->ESPECIE)
					++_xQtLin

				EndIf

				DbSkip()

				If _xQtLin > 8 .and. _nQtLin > 9 .and. !eof()	// inicia novo formulario
					++_xQtLin
					_nQtLin := _nQtLin - 8
					@ ++_nLin  , 003 pSay 'Continua no proximo formulario...'
					FechaForm()
					setprc(0,0)
					@ _nLin+=05 , 100 pSay _xComest	//era 04
					++_xQtLin				
					@ _nLin+=09 , 003 pSay '...Continuacao do formulario anterior'
					_cTeste	:= 'S'				
				EndIf

			EndDo

			For _nI := _xQtLin to Iif(_cTeste='S',7,8)	// preenche as linhas que sobraram
				@ ++_nLin , 004 pSay "X"
				@ _nLin   , 021 pSay "X"
				@ _nLin   , 041 pSay "X"
				@ _nLin   , 071 pSay "X"
				@ _nLin   , 089 pSay "X"
				@ _nLin   , 107 pSay "X"
			Next

			FechaForm()

			DbSelectArea('TRB')

		EndDo

	EndDo

	If aReturn[5]=1
		dbcommitAll()
		ourspool(wnrel)
	Endif

	SetPgEject(.F.) 
	MS_FLUSH()

	TRA->(DbCloseArea())
	TRB->(DbCloseArea())

	fErase(_cArq + '.dbf')
	fErase(_cArq + '.cdx')
	
	// ProcData 04/2023 - Chamada para fechar arquivo de trabalho
	u_arqtrb ("FechaTodos",,,, @_aArqTrb) 

Return

//////////////////////////////////////////////////////////////////////////////////////////
//////////////////////////////////////////////////////////////////////////////////////////
Static Function FechaForm()
	///////////////////////////
	Local _nI
	_cSequen := ""
	_nLin++
	If len(_aNF) > 1  // imprime sequencia de notas fiscais
		@ _nLin+=1, 022 pSay "(Cfe. Obs NF) "
		aSort(_aNF)
		For _nI := 1 to len(_aNf)
			_cSequen += _aNF[_nI] + ","
		Next
	Else
		@ _nLin+=1, 023 pSay _aNF[1]
		@ _nLIn   , 045 PSay left(mv_par03,3)
	EndIf

	@ _nLin, 065 pSay "Temp.: " + _cTemp

	@ _nLin+=2, 003 pSay "Obs NF: "+left(_cSequen,len(_cSequen)-1)

	@ ++_nLin , 025 pSay iif(empty(SM0->M0_CIDENT),alltrim(SM0->M0_CIDCOB)+" - "+SM0->M0_ESTCOB,alltrim(SM0->M0_CIDENT)+" - "+SM0->M0_ESTENT)
	@ _nLin   , 092 pSay left(SM0->M0_NOMECOM,41)

	@ ++_nLin , 025 pSay mv_par06

	If len(_aNF) > 1		// verifica se ha mais de uma nota fiscal
		_xCliente := "DIVERSOS"
	Else
		SF2->(DbSeek(xFilial("SC5") + SD2->D2_Pedido) )
		If Posicione('SF2', 1, xFilial('SF2') + _aNF[1] + mv_par03, 'F2_TIPO') $ "DB"
			_xCliente := alltrim(Posicione('SA2', 1, xFilial('SA2') + SF2->F2_CLIENTE + SF2->F2_LOJA, 'A2_NOME'))
		Else
			_xCliente := alltrim(Posicione('SA1', 1, xFilial('SA1') + SF2->F2_CLIENTE + SF2->F2_LOJA, 'A1_NOME'))
		EndIf
	EndIf
	@ _nLin   , 092 pSay _xCliente

	@ ++_nLin , 035 pSay "SIF: " + alltrim(mv_par07)
	@ _nLin   , 050 pSay iif(empty(mv_par08),".","SIF: " + alltrim(mv_par08))
	@ _nLin   , 092 pSay left(SM0->M0_NOMECOM,41)

	@ ++_nLin , 025 pSay "RODOVIARIO - PLACA: " + alltrim(mv_par10)
	@ _nLin   , 092 pSay alltrim(_cMun)

	@ ++_nLin , 035 pSay alltrim(mv_par09)
	@ _nLin   , 092 pSay left(mv_par11,41)

	//If mv_par28 = 1
	@ _nLin+=1, 077 pSay mv_par12 Picture "99"
	@ _nLin+=3, 060 pSay SM0->M0_CIDENT
	@ _nLin   , 085 pSay Strzero(day(dDataBase),2)
	@ _nLin   , 100 pSay MesExtenso(month(dDataBase))
	@ _nLin   , 125 pSay str(year(dDataBase),4)
	//Else
	//	@ ++_nLin , 077 pSay mv_par12 Picture "99"
	//	@ _nLin+=2, 060 pSay SM0->M0_CIDENT
	//	@ _nLin   , 086 pSay Strzero(day(dDataBase),2)
	//	@ _nLin   , 100 pSay MesExtenso(month(dDataBase))
	//	@ _nLin   , 125 pSay Right(str(year(dDataBase),4),1)
	//Endif                                                      

	// mensagem adicional do sif, pega todas que estao na tabela Z4 do configurador por jrl em 13/05/2004 //

	_cMenad1 := ''
	_cMenad2 := ''
	_cMenad3 := ''
	_cMenad4 := ''
	_cMenad5 := ''
	_cMenad6 := ''

	_cMenad1 := Substr(Posicione('SX5',1,xFilial('SX5')+'Z4'+'000001','X5_Descri'),1,40)
	_cMenad2 := Substr(Posicione('SX5',1,xFilial('SX5')+'Z4'+'000002','X5_Descri'),1,40)
	_cMenad3 := Substr(Posicione('SX5',1,xFilial('SX5')+'Z4'+'000003','X5_Descri'),1,40)
	_cMenad4 := Substr(Posicione('SX5',1,xFilial('SX5')+'Z4'+'000004','X5_Descri'),1,40)
	_cMenad5 := Substr(Posicione('SX5',1,xFilial('SX5')+'Z4'+'000005','X5_Descri'),1,40)
	_cMenad6 := Substr(Posicione('SX5',1,xFilial('SX5')+'Z4'+'000006','X5_Descri'),1,40)

	@ _nLin+=2, 000 pSay _cMenad1
	@ _nLin+=1, 000 pSay _cMenad2
	@ _nLin+=1, 000 pSay _cMenad3
	@ _nLin+=1, 000 pSay _cMenad4
	@ _nLin+=1, 000 pSay _cMenad5
	@ _nLin+=1, 000 pSay _cMenad6

	////////////////////////////////////////////////////////////////

	//@ _nLin+=3, 070 pSay mv_par18
	//@ _nLin+=3, 070 pSay mv_par19          

	//@ _nLin+=iif(mv_par28=1,11,11), 000 pSay '.'  // Era 10,10 em 03/11/2004
	_xQtLin := 0
	_nLin   := 0
Return

///////////////////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////////////////
Static Function ValidPerg()
	///////////////////////////

	Local i
	Local j
	cAlias := Alias()
	aPerg  := {}

	// Grupo/Ordem/Pergunta/Variavel/Tipo/Tamanho/Decimal/Presel/GSC/Valid/                            Var01/Def01/Cnt01/Var02/Def02/Cnt02/Var03/Def03/Cnt03/Var04/Def04/Cnt04/Var05/Def05/Cnt05
	aAdd( aPerg , {cPerg, "01", "Da Nota Fiscal.......?", "","", "mv_ch1", "C",  9 , 0, 0, "G", "", "mv_par01", "", "", "", "", "", "", "", "", "", "", "", "", "", "", "", "", "", "", "", "", "", "", "","", "", "", "",""})
	aAdd( aPerg , {cPerg, "02", "Ate a Nota Fiscal....?", "","", "mv_ch2", "C",  9 , 0, 0, "G", "", "mv_par02", "", "", "", "", "", "", "", "", "", "", "", "", "", "", "", "", "", "", "", "", "", "", "","", "", "", "",""})
	aAdd( aPerg , {cPerg, "03", "Serie da Nota .......?", "","", "mv_ch3", "C",  3 , 0, 0, "G", "", "mv_par03", "", "", "", "", "", "", "", "", "", "", "", "", "", "", "", "", "", "", "", "", "", "", "","", "", "", "",""})
	aAdd( aPerg , {cPerg, "04", "Temperat - Congelados?", "","", "mv_ch4", "C", 13 , 0, 0, "G", "", "mv_par04", "", "", "", "", "", "", "", "", "", "", "", "", "", "", "", "", "", "", "", "", "", "", "","", "", "", "",""})
	aAdd( aPerg , {cPerg, "05", "Temperat - Resfriados?", "","", "mv_ch5", "C", 13 , 0, 0, "G", "", "mv_par05", "", "", "", "", "", "", "", "", "", "", "", "", "", "", "", "", "", "", "", "", "", "", "","", "", "", "",""})
	aAdd( aPerg , {cPerg, "06", "Marca ou Letreiro....?", "","", "mv_ch6", "C", 20 , 0, 0, "G", "", "mv_par06", "", "", "", "", "", "", "", "", "", "", "", "", "", "", "", "", "", "", "", "", "", "", "","", "", "", "",""})
	aAdd( aPerg , {cPerg, "07", "SIF - Emitente.......?", "","", "mv_ch7", "C", 13 , 0, 0, "G", "", "mv_par07", "", "", "", "", "", "", "", "", "", "", "", "", "", "", "", "", "", "", "", "", "", "", "","", "", "", "",""})
	aAdd( aPerg , {cPerg, "08", "SIF - Destinatario...?", "","", "mv_ch8", "C", 13 , 0, 0, "G", "", "mv_par08", "", "", "", "", "", "", "", "", "", "", "", "", "", "", "", "", "", "", "", "", "", "", "","", "", "", "",""})
	aAdd( aPerg , {cPerg, "09", "Hora da Lacracao.....?", "","", "mv_ch9", "C",  5 , 0, 0, "G", "", "mv_par09", "", "", "", "", "", "", "", "", "", "", "", "", "", "", "", "", "", "", "", "", "", "", "","", "", "", "",""})
	aAdd( aPerg , {cPerg, "10", "Placa do veiculo.....?", "","", "mv_chA", "C", 20 , 0, 0, "G", "", "mv_par10", "", "", "", "", "", "", "", "", "", "", "", "", "", "", "", "", "", "", "", "", "", "", "","", "", "", "",""})
	aAdd( aPerg , {cPerg, "11", "Numero do Lacre......?", "","", "mv_chB", "C", 50 , 0, 0, "G", "", "mv_par11", "", "", "", "", "", "", "", "", "", "", "", "", "", "", "", "", "", "", "", "", "", "", "","", "", "", "",""})
	aAdd( aPerg , {cPerg, "12", "Numero de Vias.......?", "","", "mv_chC", "N",  2 , 0, 0, "G", "", "mv_par12", "", "", "", "", "", "", "", "", "", "", "", "", "", "", "", "", "", "", "", "", "", "", "","", "", "", "",""})
	aAdd( aPerg , {cPerg, "13", "Nome Responsavel.....?", "","", "mv_chI", "C", 40 , 0, 0, "G", "", "mv_par13", "", "", "", "", "", "", "", "", "", "", "", "", "", "", "", "", "", "", "", "", "", "", "","", "", "", "",""})
	aAdd( aPerg , {cPerg, "14", "Cargo Responsavel....?", "","", "mv_chJ", "C", 40 , 0, 0, "G", "", "mv_par14", "", "", "", "", "", "", "", "", "", "", "", "", "", "", "", "", "", "", "", "", "", "", "","", "", "", "",""})
	aAdd( aPerg , {cPerg, "15", "Cidade Destino.......?", "","", "mv_chk", "C", 40 , 0, 0, "G", "", "mv_par15", "", "", "", "", "", "", "", "", "", "", "", "", "", "", "", "", "", "", "", "", "", "", "","", "", "", "",""})
	aAdd( aPerg , {cPerg, "16", "Periodo de Produção..?", "","", "mv_chl", "C", 40 , 0, 0, "G", "", "mv_par16", "", "", "", "", "", "", "", "", "", "", "", "", "", "", "", "", "", "", "", "", "", "", "","", "", "", "",""})
	aAdd( aPerg , {cPerg, "17", "Periodo de Validade..?", "","", "mv_chm", "C", 40 , 0, 0, "G", "", "mv_par17", "", "", "", "", "", "", "", "", "", "", "", "", "", "", "", "", "", "", "", "", "", "", "","", "", "", "",""})
	aAdd( aPerg , {cPerg, "18", "Mensagem Exportacao..?", "","", "mv_chn", "C", 80 , 0, 0, "G", "", "mv_par18", "", "", "", "", "", "", "", "", "", "", "", "", "", "", "", "", "", "", "", "", "", "", "","", "", "", "",""})
	aAdd( aPerg , {cPerg, "19", "Mensagem Exportacao2.?", "","", "mv_cho", "C", 80 , 0, 0, "G", "", "mv_par19", "", "", "", "", "", "", "", "", "", "", "", "", "", "", "", "", "", "", "", "", "", "", "","", "", "", "",""})
	aAdd( aPerg , {cPerg, "20", "Mensagem Exportacao3.?", "","", "mv_chp", "C", 80 , 0, 0, "G", "", "mv_par20", "", "", "", "", "", "", "", "", "", "", "", "", "", "", "", "", "", "", "", "", "", "", "","", "", "", "",""})
	aAdd( aPerg , {cPerg, "21", "Mensagem Exportacao4.?", "","", "mv_chq", "C", 80 , 0, 0, "G", "", "mv_par21", "", "", "", "", "", "", "", "", "", "", "", "", "", "", "", "", "", "", "", "", "", "", "","", "", "", "",""})
	aAdd( aPerg , {cPerg, "22", "CFOs para Destino Excl", "","", "mv_chr", "C", 80 , 0, 0, "G", "", "mv_par22", "", "", "", "", "", "", "", "", "", "", "", "", "", "", "", "", "", "", "", "", "", "", "","", "", "", "",""})

	//"5414/7101/7949"
	DbSelectArea("SX1")
	DbSetOrder(1)
	For i:=1 to Len(aPerg)
		RecLock("SX1",!DbSeek(cPerg+aPerg[i,2]))
		For j:=1 to FCount()
			If j <= Len(aPerg[i]) .and. !(left(alltrim(FieldName(j)),6) $ 'X1_PRE/X1_CNT')
				FieldPut(j,aPerg[i,j])
			EndIf
		Next
		MsUnlock()
	Next

	DbSelectArea(cAlias)
Return


