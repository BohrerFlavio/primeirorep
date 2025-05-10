#INCLUDE "rwmake.ch"
#INCLUDE "totvs.ch"
#INCLUDE "topconn.ch"

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³GJF213  º Autor ³ Giuliano Forgiraini  º Data ³ 04/02/2015  º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDescricao ³Controle de estoque de MP, PP, PA, QR, QF da indústria de   º±±
±±º          ³porcionados                                                 º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ PCP porcionados                                            º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/    
User Function GJF213()

	Private _aBrowse1  := {}
	Private _aBrowse2  := {}
	Private _nQtdCaix1 := 0
	Private _nQtdPeso1 := 0.00
	Private _nQtdPeso2 := 0.00
	Private _nQtdPBloq := 0.00
	Private _nQtdPBl2  := 0.00
	Private _cPGCX     := alltrim(GetMV("SI_PRODGRX"))
	Private _nAtHead1  := 2
	Private _nAtHead2  := 6

	aObjects := {}    //dimensao janelas
	aPosObj  := {}
	aInfo    := {}

	aSizeAut := MsAdvSize()

	AAdd( aObjects, { 315, 50, .T., .T. } )
	AAdd( aObjects, { 100, 100, .T., .T. } )
	aInfo := { aSizeAut[ 1 ], aSizeAut[ 2 ], aSizeAut[ 3 ], aSizeAut[ 4 ], 3, 3 }
	aPosObj := MsObjSize( aInfo, aObjects, .T. )

	cPerg := "GJF213"

	If !Pergunte(cPerg,.T.)
		Return
	Endif

	_aHeader1  := {'Produto','Descriçao   ','Tipo','MP Terceiro?','Qtd. Caixas','Qtd. Peso','Qtd. Bloq'}
	_aLargCol1 := {   20    ,   100        ,  20  ,       40     ,     40      ,    40     , 40}

	oFont   := tFont():New("arial",,-12,,.t.,,,,)
	_oTotC  := 'Total de Caixas: '
	_oTotP  := 'Total de Peso Liquido: '
	_oTotPBl  := 'Total de Peso Bloqueado: '

	DEFINE DIALOG oDlg TITLE "Controle de Estoque Industria Porcionados" FROM 020,50 To 600,1200 PIXEL

	// Cria Browse
	oBrowse1 := TCBrowse():New(10,10,480,250,,_aHeader1,_aLargCol1,oDlg,,,,,{||},,,,,,,.F.,,.T.,,.F.,,, )
	oBrowse1:bHeaderClick := {|| SetAHead1(oBrowse1:nColPos)}

	oSayTotC 	:= tSay():New(270, 060,{||_oTotC},oDlg,,oFont,,,,.T.,,,200,30)
	oSayTotP 	:= tSay():New(270, 200,{||_oTotP},oDlg,,oFont,,,,.T.,,,200,30)
	oSayTotPBl 	:= tSay():New(270, 340,{||_oTotPBl},oDlg,,oFont,,,,.T.,,,200,30)

	GeraTMP1(_nAtHead1)

	oBtn2 := TButton():New(020, 520, "Relatório "   , oDlg,{|| _Relmlr59()  },040,015,,,.F.,.T.,.F.,,.F.,,,.F. )
	oBtn2 := TButton():New(040, 520, "Parametros"   , oDlg,{|| Parametros() },040,015,,,.F.,.T.,.F.,,.F.,,,.F. )
	oBtn1 := TButton():New(060, 520, "Sair"         , oDlg,{|| oDlg:end()   },040,015,,,.F.,.T.,.F.,,.F.,,,.F. )

	ACTIVATE DIALOG oDlg CENTERED

return

// Para alterar a variável _nAtHead1
Static Function SetAHead1(_nVal)
	_nAtHead1 := _nVal
	GeraTMP1(_nAtHead1)
	oBrowse1:DrawSelect()
	oBrowse1:Refresh()
	oDlg:Refresh()
Return

// Para alterar a variável _nAtHead1
Static Function SetAHead2(_cod,_nVal)
	_nAtHead2 := _nVal
	GeraTMP2(_cod, _nAtHead2)
	oBrowse2:DrawSelect()
	oBrowse2:Refresh()
	oDlg2:Refresh()
Return

static function _Relmlr59()
	Local nX := 0
	Local aMvPar := {}

	//No início de sua customização, antes de qualquer validação
	For nX := 1 To 40
		aAdd( aMvPar, &( "MV_PAR" + StrZero( nX, 2, 0 ) ) )
	Next nX

	u_mlr59()

	//No final da customização
	For nX := 1 To Len( aMvPar )
		&( "MV_PAR" + StrZero( nX, 2, 0 ) ) := aMvPar[ nX ]
	Next nX
return()

//Gera primeiro arquivo temporário
Static Function GeraTMP1(_nOrder)

	_nQtdCaix1 := 0
	_nQtdPeso1 := 0.00
	_nQtdPBloq := 0.00
	//Se estiver selecionado o filtro para
	//MP ou PP somente
	if mv_par03 <= 3

		_cCodMP   := u_GF211MP(mv_par05) //Achou o codigo da matéria-prima
		_cCodAlt  := u_GF211AL(_cCodMP)  //Achou o codigo da matéria-prima alternativa

		if empty(mv_par07)
			alert('Informe Local nos parametros iniciais!')
		endif

		_cQuery1 := " SELECT ZAS_COD AS _COD, ZAS_DESC AS _DESC, ZAS_TIPO AS _TIPO,ZAS_TERC AS _TERC, COUNT(*) AS _QUANT, SUM(ZAS_PESOL) AS _PESOT, SUM(CASE WHEN ZAS_DTBLOQ = '' THEN 0 ELSE ZAS_PESOL END) AS _PBLOQ "
		_cQuery1 += " FROM " + RetSQLTab('ZAS') + " WHERE " + RetSQLFil('ZAS')
		_cQuery1 += " AND ZAS_DTPROD BETWEEN '" + dtos(mv_par01) + "' AND '" + dtos(mv_par02) + "'"
		_cQuery1 += " AND ZAS_DATAS = '' AND ZAS_HORAS = '' "
		_cQuery1 += " AND ZAS_LOCAL = '" + mv_par07 +"'  "
		_cQuery1 += iif(mv_par03 = 1 ,"AND ZAS_TIPO = 'MP' ",iif(mv_par03 = 2," AND ZAS_TIPO = 'PP' ", " AND ZAS_TIPO IN('QR','QF','M1','M2','TU','GR') "))
		_cQuery1 += iif(mv_par04 = 1," AND ZAS_TERC = 'N' "   ,iif(mv_par04 = 2," AND ZAS_TERC = 'S' " ,""))
		_cQuery1 += iif(!empty(mv_par06)," AND ZAS_COD = '" + mv_par06 + "' ","")
		_cQuery1 += iif(!empty(mv_par05),iif(!empty(_cCodAlt)," AND (ZAS_COD = '" +_cCodMP+"' OR ZAS_COD = '"+_cCodAlt+"')"," AND ZAS_COD ='"+_cCodMP+"'"),"")
		_cQuery1 += "AND " + RetSQLDel('ZAS')
		_cQuery1 += " GROUP BY ZAS_COD, ZAS_DESC, ZAS_TIPO, ZAS_TERC "
		if _nOrder = 1
			_cQuery1 += " ORDER BY ZAS_COD, ZAS_DESC "
		elseif _nOrder = 2
			_cQuery1 += " ORDER BY ZAS_DESC, ZAS_COD "
		else
			_cQuery1 += " ORDER BY ZAS_DESC, ZAS_COD "
		endif

		//se estiver selecionado para PA
	else

		_cQuery1 := " SELECT Z8_COD AS _COD, Z8_DESCRI AS _DESC, Z8_TERC AS _TERC, COUNT(*) AS _QUANT, SUM(Z8_PESO) AS _PESOT, 0 AS _PBLOQ "
		_cQuery1 += " FROM " + RetSQLTab('SZ8') + " WHERE " + RetSQLFil('SZ8')
		_cQuery1 += " AND  Z8_DATAS = '' AND Z8_HORAS = '' AND Z8_DATAP BETWEEN '" + dtos(mv_par01) + "' AND '" + dtos(mv_par02) + "'"
		//_cQuery1 += iif(mv_par04 = 1," AND Z8_TERC = '' "   ,iif(mv_par04 = 2," AND Z8_TERC = 'S' " ,""))
		_cQuery1 += " AND Z8_LOTEPOR <> '' "
		_cQuery1 += iif(!empty(mv_par06)," AND Z8_COD = '" + mv_par06 + "' ","")
		_cQuery1 += "AND " + RetSQLDel('SZ8')
		_cQuery1 += " GROUP BY Z8_COD, Z8_DESCRI, Z8_TERC "
		if _nOrder = 1
			_cQuery1 += " ORDER BY Z8_COD, Z8_DESCRI "
		elseif _nOrder = 2
			_cQuery1 += " ORDER BY Z8_DESCRI, Z8_COD "
		else
			_cQuery1 += " ORDER BY Z8_DESCRI, Z8_COD "
		endif

	endif

	_cQuery1 := ChangeQuery(_cQuery1)

	//	* Mostrar a consulta */
	//@ 116,090 To 416,707 Dialog oDlgMemo Title "Consulta"
	//@ 055,005 Get _cQuery1 Size 250,080 MEMO Object oMemo
	//Activate Dialog oDlgMemo
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Monta a interface padrao com o usuario...                           ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ

	If Select("EST1") != 0
		EST1->(dbCloseArea())
	Endif

	TCQUERY _cQuery1 NEW ALIAS "EST1"

	_aBrowse1 := {}

	While EST1->(!eof())

		if mv_par03 <= 3
			aadd(_aBrowse1,{EST1->_COD,;
				PADR(EST1->_DESC,60," "),;
				iif(mv_par03 = 4,'PA',EST1->_TIPO),;
				iif(EST1->_TERC = 'S','Sim',''),;
				transform(EST1->_QUANT,"@E 999,999"),;
				transform(EST1->_PESOT,"@E 999,999.99"),;
				transform(EST1->_PBLOQ,"@E 999,999.99")})

			_nQtdCaix1 += EST1->_QUANT
			_nQtdPeso1 += EST1->_PESOT
			_nQtdPBloq += EST1->_PBLOQ
		else
			aadd(_aBrowse1,{EST1->_COD,;
				PADR(EST1->_DESC,60," "),;
				iif(mv_par03 = 4,'PA',EST1->_TIPO),;
				iif(EST1->_TERC = 'S','Sim',''),;
				transform(EST1->_QUANT,"@E 999,999"),;
				transform(EST1->_PESOT,"@E 999,999.99")})

			_nQtdCaix1 += EST1->_QUANT
			_nQtdPeso1 += EST1->_PESOT
		endif
		EST1->(DbSkip())
	enddo

	if len(_aBrowse1) == 0
		if mv_par03 <= 3
			aadd(_aBrowse1,{'','','','','','',''})
		else
			aadd(_aBrowse1,{'','','','','',''})
		endif
	endif

	// Seta vetor para a browse
	oBrowse1:SetArray(_aBrowse1)

	// Monta a linha a ser exibina no Browse
	if mv_par03 <= 3
		oBrowse1:bLine := {||{_aBrowse1[oBrowse1:nAt,01],_aBrowse1[oBrowse1:nAt,02],_aBrowse1[oBrowse1:nAt,03],;
			_aBrowse1[oBrowse1:nAT,04],_aBrowse1[oBrowse1:nAT,05],_aBrowse1[oBrowse1:nAT,06],_aBrowse1[oBrowse1:nAT,07]}}
	else
		oBrowse1:bLine := {||{_aBrowse1[oBrowse1:nAt,01],_aBrowse1[oBrowse1:nAt,02],_aBrowse1[oBrowse1:nAt,03],;
			_aBrowse1[oBrowse1:nAT,04],_aBrowse1[oBrowse1:nAT,05],_aBrowse1[oBrowse1:nAT,06]}}
	endif
	oBrowse1:bLDblClick  := {|| Detalhe(_aBrowse1[oBrowse1:nAt,01]) }
	//codigo,descricao,tipo,terc,caixas,peso

	oSayTotC:SetText(_oTotC + Transform(_nQtdCaix1,'@E 999,999'))
	oSaytotP:SetText(_oTotP + Transform(_nQtdPeso1,'@E 999,999,999.99'))
	oSayTotPBl:SetText(_oTotPBl + Transform(_nQtdPBloq,'@E 999,999,999.99'))

return

//Gera segundo arquivo temporário
Static Function GeraTMP2(_cod, _nOrder)

	_nQtdCaix2 := 0
	_nQtdPeso2 := 0.00
	_nQtdPBl2  := 0.00

	//MP ou PP de terceiros
	if (mv_par03 < 4 .and. mv_par04 = 2)

		_cQuery2 := " SELECT ZAS_CONTRO AS _CONTRO, ZAS_COD AS _COD, ZAS_DESC AS _DESC, ZAS_PERCCX AS _PERCCX, ZAS_COD3 AS _COD3,"
		_cQuery2 += " ZAS_TIPO AS _TIPO,ZAS_TERC AS _TERC,  ZAS_PESOL AS _PESOL, ZAS_DTABAT AS _DTABAT, ZAS_DTBLOQ AS _DTBLOQ,"
		_cQuery2 += " (dateadd(day, ZAS_VALID, CONVERT(DATE, ZAS_DTABAT))) AS _DATAVAL, ZAS_PALLET AS _PALLET, ZAS_LOCALI AS _LOCALIZ, ZAS_PREDES AS _PREDES "
		_cQuery2 += " FROM " + RetSQLTab('ZAS') + " WHERE " + RetSQLFil('ZAS') + " AND  ZAS_COD = '" + _cod + "'"
		_cQuery2 += " AND ZAS_LOCAL = '" + mv_par07 +"' "
		_cQuery2 += " AND  ZAS_DATAS = ' ' AND ZAS_HORAS = ' ' AND ZAS_DTABAT BETWEEN '" + dtos(mv_par01) + "' AND '" + dtos(mv_par02) + "'"
		_cQuery2 += iif(mv_par03 = 1," AND ZAS_TIPO = 'MP' ",iif(mv_par03 = 2," AND ZAS_TIPO = 'PP' ",iif(mv_par03 = 3," AND ZAS_TIPO = 'QR' "," AND ZAS_TIPO = 'QF' ")))
		_cQuery2 += iif(mv_par04 = 1," AND ZAS_TERC = 'N' "   ,iif(mv_par04 = 2," AND ZAS_TERC = 'S' " ,""))
		//_cQuery2 += iif(!empty(mv_par06)," AND ZAS_COD = '" + mv_par06 + "' ","")
		_cQuery2 += " AND " + RetSQLDel('ZAS')
		if _nOrder = 1
			_cQuery2 += " ORDER BY ZAS_CONTRO "
		elseif _nOrder = 4
			_cQuery2 += " ORDER BY ZAS_PERCCX "
		elseif _nOrder = 10
			_cQuery2 += " ORDER BY ZAS_LOCALI "
		elseif _nOrder = 11
			_cQuery2 += " ORDER BY ZAS_DTABAT "
		else
			_cQuery2 += " ORDER BY ZAS_DTABAT "
		endif

		//MP ou PP própria
	elseif(mv_par03 < 4 .and. mv_par04 = 1)

		_cQuery2 := " SELECT ZAS_CONTRO AS _CONTRO, ZAS_COD AS _COD, ZAS_DESC AS _DESC, ZAS_PERCCX AS _PERCCX, ZAS_COD3 AS _COD3,"
		_cQuery2 += " ZAS_TIPO AS _TIPO,ZAS_TERC AS _TERC,  ZAS_PESOL AS _PESOL, ZAS_DTPROD AS _DTPROD, ZAS_DTBLOQ AS _DTBLOQ, "
		_cQuery2 += " (dateadd(day, ZAS_VALID, CONVERT(DATE, ZAS_DTPROD))) AS _DATAVAL, ZAS_PALLET AS _PALLET, ZAS_LOCALI AS _LOCALIZ, ZAS_PREDES AS _PREDES "
		_cQuery2 += " FROM " + RetSQLTab('ZAS') + " WHERE " + RetSQLFil('ZAS') + " AND  ZAS_COD = '" + _cod + "'"
		_cQuery2 += " AND ZAS_LOCAL = '" + mv_par07 +"'  "
		_cQuery2 += " AND  ZAS_DATAS = ' ' AND ZAS_HORAS = ' ' AND ZAS_DTPROD BETWEEN '" + dtos(mv_par01) + "' AND '" + dtos(mv_par02) + "'"
		_cQuery2 += iif(mv_par03 = 1," AND ZAS_TIPO = 'MP' ",iif(mv_par03 = 2," AND ZAS_TIPO = 'PP' ",iif(mv_par03 = 3," AND ZAS_TIPO = 'QR' "," AND ZAS_TIPO = 'QF' ")))
		_cQuery2 += iif(mv_par04 = 1," AND ZAS_TERC = 'N' "   ,iif(mv_par04 = 2," AND ZAS_TERC = 'S' " ,""))
		//_cQuery2 += iif(!empty(mv_par06)," AND ZAS_COD = '" + mv_par06 + "' ","")
		_cQuery2 += " AND " + RetSQLDel('ZAS')
		if _nOrder = 1
			_cQuery2 += " ORDER BY ZAS_CONTRO "
		elseif _nOrder = 4
			_cQuery2 += " ORDER BY ZAS_PERCCX "
		elseif _nOrder = 6
			_cQuery2 += " ORDER BY ZAS_DTPROD "
		elseif _nOrder = 10
			_cQuery2 += " ORDER BY ZAS_LOCALI "
		else
			_cQuery2 += " ORDER BY ZAS_DTPROD "
		endif

	else

		_cQuery2 := " SELECT Z8_CONTROL AS _CONTRO, Z8_COD AS _COD, Z8_DESCRI AS _DESC, Z8_PERCRXN AS _PERCCX, '' AS _DTBLOQ, "
		_cQuery2 += " Z8_PESO AS _PESOL, Z8_DATAP AS _DTPROD, Z8_DATAVAL AS _DATAVAL, Z8_PALLET AS _PALLET, Z8_LOCALIZ AS _LOCALIZ, Z8_PREDES AS _PREDES "
		_cQuery2 += " FROM " + RetSQLTab('SZ8') + " WHERE " + RetSQLFil('SZ8') +  " AND  Z8_COD = '" + _cod + "'"
		_cQuery2 += " AND  Z8_DATAS = ' ' AND Z8_HORAS = ' ' AND Z8_DATAP BETWEEN '" + dtos(mv_par01) + "' AND '" + dtos(mv_par02) + "'"
		//_cQuery2 += iif(mv_par04 = 1," AND Z8_TERC = '' "   ,iif(mv_par04 = 2," AND Z8_TERC = 'S' " ,""))
		_cQuery2 += " AND Z8_LOTEPOR <> '' "
		//_cQuery2 += iif(!empty(mv_par06)," AND Z8_COD = '" + mv_par06 + "' ","")
		_cQuery2 += "AND " + RetSQLDel('SZ8')
		if _nOrder = 1
			_cQuery2 += " ORDER BY Z8_CONTROL "
		elseif _nOrder = 4
			_cQuery2 += " ORDER BY Z8_PERCRXN "
		elseif _nOrder = 6
			_cQuery2 += " ORDER BY Z8_DATAP "
		elseif _nOrder = 10
			_cQuery2 += " ORDER BY Z8_LOCALIZ "
		else
			_cQuery2 += " ORDER BY Z8_DATAP "
		endif

	endif

	_cQuery2 := ChangeQuery(_cQuery2)

	//	* Mostrar a consulta */
	//@ 116,090 To 416,707 Dialog oDlgMemo Title "Consulta"
	//@ 055,005 Get cQuery Size 250,080 MEMO Object oMemo
	//Activate Dialog oDlgMemo
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Monta a interface padrao com o usuario...                           ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ

	If Select("EST2") != 0
		EST2->(dbCloseArea())
	Endif

	TCQUERY _cQuery2 NEW ALIAS "EST2"

	_aBrowse2 := {}

	While EST2->(!eof())
		if (mv_par03 < 4 .and. mv_par04 = 2)
			aadd(_aBrowse2,{EST2->_CONTRO,;
				EST2->_COD,;
				PADR(EST2->_DESC,60," "),;
				rangeGordRX(EST2->_COD,EST2->_PERCCX),;
				iif(mv_par03 = 1,EST2->_COD3,''),;
				dtoc(stod(EST2->_DTABAT)),;
				iif(mv_par03 = 4,EST2->_DATAVAL, EST2->_DATAVAL),;
				transform(EST2->_PESOL,"@E 999.999"),;
				EST2->_PALLET,;
				transform(EST2->_LOCALIZ,"@R !!.!!.!!.!!.!!"),;
				GetAdvFVal('SZ2','Z2_DATAABT',FWxFilial('SZ2') + EST2->_PREDES,2),;
				dtoc(stod(EST2->_DTBLOQ))})
			_nQtdPeso2 += EST2->_PESOL
			_nQtdPBl2  += iif(empty(EST2->_DTBLOQ),0,EST2->_PESOL)

			EST2->(DbSkip())
		else
			aadd(_aBrowse2,{EST2->_CONTRO,;
				EST2->_COD,;
				PADR(EST2->_DESC,60," "),;
				rangeGordRX(EST2->_COD,EST2->_PERCCX),;
				iif(mv_par03 = 1,EST2->_COD3,''),;
				dtoc(stod(EST2->_DTPROD)),;
				iif(mv_par03 = 4,EST2->_DATAVAL, EST2->_DATAVAL),;
				transform(EST2->_PESOL,"@E 999.999"),;
				EST2->_PALLET,;
				transform(EST2->_LOCALIZ,"@R !!.!!.!!.!!.!!"),;
				GetAdvFVal('SZ2','Z2_DATAABT',FWxFilial('SZ2') + EST2->_PREDES,2),;
				dtoc(stod(EST2->_DTBLOQ))})
			_nQtdPeso2 += EST2->_PESOL
			_nQtdPBl2  += iif(empty(EST2->_DTBLOQ),0,EST2->_PESOL)

			EST2->(DbSkip())
		endif
	enddo

	if len(_aBrowse2) == 0
		aadd(_aBrowse2,{'','','','','','','','','','','',''})
	endif

	// Seta vetor para a browse
	oBrowse2:SetArray(_aBrowse2)

	// Monta a linha a ser exibina no Browse
	oBrowse2:bLine := {||{_aBrowse2[oBrowse2:nAt,01],_aBrowse2[oBrowse2:nAt,02],;
		_aBrowse2[oBrowse2:nAt,03],_aBrowse2[oBrowse2:nAT,04],;
		_aBrowse2[oBrowse2:nAt,05],_aBrowse2[oBrowse2:nAT,06],;
		_aBrowse2[oBrowse2:nAT,07],_aBrowse2[oBrowse2:nAT,08],;
		_aBrowse2[oBrowse2:nAT,09],_aBrowse2[oBrowse2:nAT,10],;
		_aBrowse2[oBrowse2:nAT,11],_aBrowse2[oBrowse2:nAT,12]}}

	//codigo,descricao,tipo,terc,caixas,peso

	oSaytotP2:SetText(_oTotP2 + Transform(_nQtdPeso2,'@E 999,999,999.99'))
	oSaytotPB2:SetText(_oTotPBl2 + Transform(_nQtdPBl2,'@E 999,999,999.99'))

return

//Função acionada pelo botão parâmetros
Static Function Parametros()
	Pergunte(cPerg,.T.)
	GeraTMP1(_nAtHead1)
	oBrowse1:DrawSelect()
	oDlg:Refresh()
Return

//Função acionada pelo botão Entrada
//Faz a entrada da caixa em estoque
Static Function Entrada()
	Local _cContro := _aBrowse1[oBrowse2:nAt,01]
	GeraTMP2()
	oBrowse2:DrawSelect()
	oDlg2:Refresh()
Return

//Função acionada pelo botão parâmetros
//Faz a saída da caixa em estoque
Static Function Saida()
	GeraTMP2()
	oBrowse2:DrawSelect()
	oDlg2:Refresh()
Return

// Retorna o range de porcentagem de gordura
Static Function rangeGordRX(_cCod,_nPecCRX)

	Local cPGCX := ""
	Local nPGCX := 0

	nPGCX := 100-_nPecCRX
	if (alltrim(_cCod) $ _cPGCX)
		if(nPGCX <= 20)
			cPGCX := '20-'
		elseif (nPGCX >= 21 .and. nPGCX <= 25)
			cPGCX := '20/25'
		elseif (nPGCX > 25 .and. nPGCX < 100)
			cPGCX := '25+'
		else
			cPGCX := '----'
		endif
	else
		if(nPGCX < 25)
			cPGCX := '25-'
		elseif (nPGCX >= 25 .and. nPGCX <= 33)
			cPGCX := '25/33'
		elseif (nPGCX > 33 .and. nPGCX < 100)
			cPGCX := '33+'
		else
			cPGCX := '----'
		endif
	endif

Return cPGCX

//Segunda tela
//Para exibição do estoque detalhado
//por cada caixa de produto
Static Function Detalhe(_cod)

	_aBrowse2  := {}

	_aHeader2  := {'Codigo','Produto','Descriçao   ','% Gordura','Cod. Terc.','Data Prod.','Data Valid.','Peso','Pallet','Localização','Data Abate','Data Bloqueio'}
	_aLargCol2 := {  40    ,   30    ,  100         ,    30     ,    40      ,  35        ,    35       , 40   ,   40    ,     40    ,      40     ,      40     }

	_oTotP2  := 'Total de Peso Liquido: '
	_oTotPBl2  := 'Total de Peso Bloqueado: '

	DEFINE DIALOG oDlg2 TITLE "Controle de Estoque Industria Porcionados - Detalhamento Produto " + _cod FROM 020,50 To 600,1200 PIXEL

	// Cria Browse
	oBrowse2 := TCBrowse():New(10,10,500,250,,_aHeader2,_aLargCol2,oDlg2,,,,,{||},,,,,,,.F.,,.T.,,.F.,,, )
	oBrowse2:bHeaderClick := {|| SetAHead2(_cod,oBrowse2:nColPos)}

	oSayTotP2 :=  tSay():New(270, 200,{||_oTotP2},oDlg2,,oFont,,,,.T.,,,200,30)
	oSayTotPB2 := tSay():New(270, 340,{||_oTotPBl2},oDlg2,,oFont,,,,.T.,,,200,30)

	GeraTMP2(_cod, _nAtHead2)

	oBtn4 := TButton():New(020, 520, "Bloquear"         , oDlg2,{|| BloqDesb(1)   },050,015,,,.F.,.T.,.F.,,.F.,,,.F. )
	oBtn4 := TButton():New(040, 520, "Bloquear Todos"   , oDlg2,{|| BloqDesb(2)   },050,015,,,.F.,.T.,.F.,,.F.,,,.F. )
	oBtn4 := TButton():New(060, 520, "Desbloquear"      , oDlg2,{|| BloqDesb(3)   },050,015,,,.F.,.T.,.F.,,.F.,,,.F. )
	oBtn4 := TButton():New(080, 520, "Desbloquear Todos", oDlg2,{|| BloqDesb(4)   },050,015,,,.F.,.T.,.F.,,.F.,,,.F. )
	oBtn3 := TButton():New(100, 520, "Sair"             , oDlg2,{|| oDlg2:end()   },050,015,,,.F.,.T.,.F.,,.F.,,,.F. )

	ACTIVATE DIALOG oDlg2 CENTERED

	GeraTMP1(_nAtHead1)
	oBrowse1:DrawSelect()
	oDlg:Refresh()

return

/*
Bloqueia/desbloqueia produtos
*/
static function BloqDesb(_nTp)
	Local i:= 0
	//MP ou PP somente
	if mv_par03 <= 3

		ZAA->(DbSetOrder(2))
		ZAA->(MsSeek(FWxfilial('ZAA')+RetCodUsr()))

		if ZAA->ZAA_APL30 <> 'S'
			MsgAlert('Opção negada para o usuario!','Aviso')
			return .t.
		endif

		if _nTp == 1 .or. _nTp == 3
			dbSelectArea("ZAS")
			dbSetOrder(1)
			if MsSeek(fwFilial("ZAS")+_aBrowse2[oBrowse2:nAT,1])
				_aBrowse2[oBrowse2:nAT,12] := iif(_nTp == 1, DTOC(date()), DTOC(stod('')))
				oBrowse2:DrawSelect()
				oDlg2:Refresh()
				if _nTp == 1 .and. empty(ZAS->ZAS_DTBLOQ)
					_nQtdPBl2 += ZAS->ZAS_PESOL
				elseif _nTp == 3 .and. !empty(ZAS->ZAS_DTBLOQ)
					_nQtdPBl2 -= ZAS->ZAS_PESOL
				endif
				RECLOCK( "ZAS", .F. )
				ZAS->ZAS_DTBLOQ := iif(_nTp == 1, Date(), STOD(''))
				MSUNLOCK()
				u_obit02(ZAS->ZAS_CONTRO, retCodUsr(), ZAS->ZAS_LOCAL, ZAS->ZAS_LOCALI, iif(!empty(ZAS->ZAS_DTBLOQ), "Bloqueado Consumo", "Desbloqueado Consumo"), ZAS->ZAS_PALLET, "ZAS", alltrim(FUNNAME()))
			endif
		else
			For i := 1 To Len(oBrowse2:aArray)
				dbSelectArea("ZAS")
				dbSetOrder(1)
				if MsSeek(fwFilial("ZAS")+_aBrowse2[i,1])
					_aBrowse2[i,12] := iif(_nTp == 2, DTOC(date()), DTOC(stod('')))
					oBrowse2:DrawSelect()
					oDlg2:Refresh()
					if _nTp == 2 .and. empty(ZAS->ZAS_DTBLOQ)
						_nQtdPBl2 += ZAS->ZAS_PESOL
					elseif _nTp == 4 .and. !empty(ZAS->ZAS_DTBLOQ)
						_nQtdPBl2 -= ZAS->ZAS_PESOL
					endif
					RECLOCK( "ZAS", .F. )
					ZAS->ZAS_DTBLOQ := iif(_nTp == 2, Date(), STOD(''))
					MSUNLOCK()
					u_obit02(ZAS->ZAS_CONTRO, retCodUsr(), ZAS->ZAS_LOCAL, ZAS->ZAS_LOCALI, iif(!empty(ZAS->ZAS_DTBLOQ), "Bloqueado Consumo", "Desbloqueado Consumo"), ZAS->ZAS_PALLET, "ZAS", alltrim(FUNNAME()))
				endif
			Next i
		endif
		oSaytotPB2:SetText(_oTotPBl2 + Transform(_nQtdPBl2,'@E 999,999,999.99'))
	else
		MsgAlert('Somente para MP ou PP.!','Aviso')
	endif
return()
