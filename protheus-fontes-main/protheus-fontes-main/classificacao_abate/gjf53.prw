#INCLUDE "topconn.ch"
#INCLUDE "totvs.ch"

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³GJF53   º Autor ³ Giuliano Forgiarini  º Data ³  14/09/08   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDescricao ³ Relatorio de manifesto de cargas analitico                 º±±
±±º          ³                                                            º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ Comercial e expedições (SIGAPCP e SIGAOMS)                 º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/

User Function GJF53()

	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Declaracao de Variaveis                                             ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ

	Local cDesc1         := "Este programa tem como objetivo imprimir relatorio  "
	Local cDesc2         := "de manifesto de carga analítico listando as caixas ou"
	Local cDesc3         := "peças que formaram esta carga."
	Local titulo       	 := "MANIFESTO DE CARGA ANALÍTICO"
	Local nLin         	 := 80
	Local Cabec1       	 := "              Frigorifico Silva Industria e Comercio Ltda. - BR 392 Km 8 Passo das Tropas - Santa Maria - RS - Brasil"
	Local Cabec2       	 := "  Carga    Placa      Data   Observação"
	//Local imprime      := .T.
	Local aOrd := {}

	Private lEnd         	:= .F.
	Private lAbortPrint  	:= .F.
	Private CbTxt        	:= ""
	Private limite          := 128
	Private tamanho         := "M"
	Private nomeprog        := "GJF53" // Coloque aqui o nome do programa para impressao no cabecalho
	Private nTipo           := 18
	Private aReturn         := { "Zebrado", 1, "Administracao", 2, 2, 1, "", 1}
	Private nLastKey        := 0
	Private cPerg   		:= "GJF53"
	Private cbcont     		:= 00
	Private CONTFL     		:= 01
	Private m_pag      		:= 01
	Private wnrel      		:= "GJF53" // Coloque aqui o nome do arquivo usado para impressao em disco
	Private TotCaix    		:= 0.00
	Private TotPeso    		:= 0.00
	Private _aParc     		:= {}
	Private _aDtEmb     	:= {}
	Private _cGrpMds		:= GETMV('MV_GRPMDS')
	Private _cCodLote		:= alltrim(GETMV('SI_LOTPRED'))
	Private _cGrpChar 	 	:= alltrim(GetMV('MV_GRPCHRQ'))
	Private _cGrpPorc 	 	:= alltrim(GetMV('MV_GRPPORC'))

	pergunte(cPerg,.F.)

	//para verificação se existe previsao de pesagem

	wnrel := SetPrint('SZ8',NomeProg,cPerg,@titulo,cDesc1,cDesc2,cDesc3,.T.,aOrd,.T.,Tamanho,,.T.)

	cQuery := " SELECT ZZ3_NUM AS CARGA, ZZ4_NUM AS PREPED,ZZ5_ITEM AS NUM_ITEM, ZZ5_COD AS ITEM, ZZ5_QRCAIX AS QRCAIX, ZZ5_QRPESO AS QRPESO,"
	cQuery += " ZZ4_CODCLI, ZZ4_LOJA, ZZ4_MUN, ZZ4_MARCA, ZZ4_QPPESO, ZZ4_NUMPED AS NUMPED, ZZ3_ISUSA AS ISUSA"
	cQuery += " FROM " + RetSqlTab("ZZ5") + ", " + RetSqlTab("ZZ4")  + ", " + RetSqlTab("ZZ3")
	cQuery += " WHERE " + RetSQLFil('ZZ5') + " AND " + RetSQLFil('ZZ4') + " AND " + RetSQLFil('ZZ3') + " AND "
	cQuery += " ZZ3_NUM = ZZ4_PRECAR AND  ZZ4_NUM = ZZ5_NUM AND  ZZ5_QRPESO <> 0 AND "
	cQuery += " (ZZ3_NUM BETWEEN '" + mv_par01 + "' AND '" + mv_par02 +"') AND "
	cQuery += " (ZZ4_NUM BETWEEN '" + mv_par03 + "' AND '" + mv_par04 +"') AND "
	cQuery +=  RetSQLDel('ZZ3') + " AND " + RetSQLDel('ZZ4') + " AND " + RetSQLDel('ZZ5')
	if mv_par08 = 1
		cQuery += " ORDER BY ZZ3_NUM,ZZ4_NUM,ZZ5_ITEM"
	else
		cQuery += " ORDER BY ZZ3_NUM,ZZ4_CODCLI,ZZ4_LOJA,ZZ4_MUN, ZZ4_MARCA,ZZ4_QPPESO"
	endif

	cQuery := ChangeQuery(cQuery)
	
	//	* Mostrar a consulta */
	//@ 116,090 To 416,707 Dialog oDlgMemo Title "Consulta"
	//@ 055,005 Get cQuery Size 250,080 MEMO Object oMemo
	//Activate Dialog oDlgMemo
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Monta a interface padrao com o usuario...                           ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ

	If Select("CAR") != 0
		CAR->(dbCloseArea())
	endif
	TCQUERY cQuery NEW ALIAS "CAR"

	If nLastKey == 27
		Return
	endif

	SetDefault(aReturn,'SZ8')

	If nLastKey == 27
		Return
	endif

	nTipo := If(aReturn[4]==1,15,18)

	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Processamento. RPTSTATUS monta janela com a regua de processamento. ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ

	RptStatus({|| RunReport(Cabec1,Cabec2,Titulo,nLin) },Titulo)
Return

Static Function RunReport(Cabec1,Cabec2,Titulo,nLin)

	//Local nOrdem
	Local i
	Local _aShipM  := {}
	Local _aTotSM  := {}

	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ SETREGUA -> Indica quantos registros serao processados para a regua ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ

	CAR->(dbGoTop())

	CAR->(SetRegua(RecCount()))

	_cShipMark 		:= ''
	_cTempSM 		:= ''
	_cTempLU 		:= ''
	_cLote 			:= ''
	_cPrecar  		:= ' '
	_cPrecar2 		:= CAR->CARGA
	_cPreped  		:= ' '
	_nTotCaix  		:= 0
	_nTotPeca 		:= 0
	_nTotPesoL 		:= 0
	_nTotPesoB 		:= 0
	_lAbt      		:= .f.
	_lClass    		:= .f.
	_nQtPeca 		:= 0
	_nTotCaixItem 	:= 0
	_nTotPesoItem 	:= 0
	_nQuantB1 		:= 0

	While CAR->(!EOF())

		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³ Verifica o cancelamento pelo usuario...                             ³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ

		If lAbortPrint
			@nLin,00 PSAY "*** CANCELADO PELO OPERADOR ***"
			Exit
		endif

		If nLin > 75 // Salto de Página. Neste caso o formulario tem 55 linhas...
			Cabec(Titulo,Cabec1,Cabec2,NomeProg,Tamanho,nTipo)
			nLin := 9
		endif
		if  CAR->CARGA != _cPrecar
			@nlin,002 psay CAR->CARGA
			@nlin,010 psay GetAdvFVal('ZZ3','ZZ3_PLACA',FWxfilial('ZZ3')+alltrim(CAR->CARGA),2)
			@nlin,020 psay GetAdvFVal('ZZ3','ZZ3_DTCAR',FWxfilial('ZZ3')+alltrim(CAR->CARGA),2)
			@nlin,030 psay GetAdvFVal('ZZ3','ZZ3_OBS',FWxfilial('ZZ3')+alltrim(CAR->CARGA),2)
			nlin++
			@nlin,00 psay replicate('=',132)
			_cPrecar := CAR->CARGA
			nlin++
		endif
		if CAR->PREPED != _cPreped

			_nTotCaixPP := 0
			_nTotPesoPP := 0

			if !empty(mv_par05)
				cQuery2 := " SELECT COUNT(Z2_NUMAM) AS NUMAM"
				cQuery2 += " FROM " + RetSqlTab("ZZ4") + ", " + RetSqlTab("SZ8") + ", " + RetSqlTab("SZ2")
				cQuery2 += " WHERE " + RetSQLFil ("ZZ4") + " AND " + RetSQLFil("SZ8")+ " AND " + RetSQLFil("SZ2")
				cQuery2 += " AND ZZ4_NUM = Z8_PREPED AND Z8_PREDES = Z2_NUM "
				cQuery2 += " AND Z8_FIL = '" + cFilant + "'  AND  Z2_NUMAM = '" + mv_par05 + "'"
				if !empty(mv_par06)
					cQuery2 += " AND Z2_CLASSIF = '" + mv_par06 + "'"
				endif
				cQuery2 += "AND" + RetSQLDel("ZZ4") + " AND " + RetSQLDel("SZ8") + " AND " + RetSQLDel("SZ2")

				cQuery2 := ChangeQuery(cQuery2)

				//	* Mostrar a consulta */
				//@ 116,090 To 416,707 Dialog oDlgMemo Title "Consulta"
				//@ 055,005 Get cQuery Size 250,080 MEMO Object oMemo
				//Activate Dialog oDlgMemo

				If Select("CAR2") != 0
					CAR2->(dbCloseArea())
				endif
				TCQUERY cQuery2 NEW ALIAS "CAR2"
				if CAR2->NUMAM = 0
					CAR->(DbSkip())
					loop
				endif
			endif

			nlin++
			@nlin,010 psay CAR->PREPED

			_cCliente := GetAdvFVal('ZZ4','ZZ4_CODCLI',FWxfilial('ZZ4')+alltrim(CAR->PREPED),2)
			_cLoja    := GetAdvFVal('ZZ4','ZZ4_LOJA',FWxfilial('ZZ4')+alltrim(CAR->PREPED),2)
			_cDoc     := GetAdvFVal('SD2','D2_DOC',FWxfilial('SD2')+alltrim(CAR->NUMPED),8)
			_cSerie   := GetAdvFVal('SD2','D2_SERIE',FWxfilial('SD2')+alltrim(CAR->NUMPED),8)
			@nlin,020 psay _cCliente + "/" + _cLoja
			@nlin,030 psay GetAdvFVal('SA1','A1_NOME',FWxfilial('SA1')+_cCliente + _cLoja,1)
			@nlin,070 psay alltrim(CAR->ZZ4_MUN) + '   Marca: ' +alltrim(CAR->ZZ4_MARCA)
			nlin++			
			@nlin,00 psay replicate('-',132)
			nlin++
			_cPreped := CAR->PREPED
		endif

		_cPreItem := alltrim(CAR->PREPED)+alltrim(CAR->ITEM)
		_c2UM     := GetAdvFVal('SB1','B1_SEGUM',FWxfilial('SB1')+alltrim(CAR->ITEM),1)
		_cGrupo   := GetAdvFVal('SB1','B1_GRUPO',FWxfilial('SB1')+alltrim(CAR->ITEM),1)
		_cDescri  := alltrim(GetAdvFVal('SB1','B1_DESC',FWxfilial('SB1')+alltrim(CAR->ITEM),1)) + '   ('+_c2UM + ')'
		_nPesFix  := GetAdvFVal('SB1','B1_PESFIX',FWxfilial('SB1')+alltrim(CAR->ITEM),1)

		if GetAdvFVal('ZZ5','ZZ5_QRCAIX',FWxfilial('ZZ5')+alltrim(CAR->(PREPED+NUM_ITEM)),1) != 0
			@nlin,020 psay CAR->ITEM
			@nlin,030 psay substr(_cDescri,1,38)
			if mv_par07 = 1 .And. _c2UM <> 'PC'
				@nlin,075 psay 'Caixas/Peças: ' + transform(CAR->QRCAIX,'@E 9,999')
				@nlin,103 psay 'Peso Líquido: ' + transform(CAR->QRPESO,'@E 999,999.99')
				nlin++
				@nlin,015 psay 'Cod. Caixa'
				@nlin,030 psay 'Quant.'
				@nlin,037 psay 'Peso B.'
				@nlin,047 psay 'Tara'
				@nlin,055 psay 'Peso L.'
				if mv_par11 = 1
					if alltrim(CAR->ITEM) $ _cCodLote
						@nlin,065 psay 'Lote'
					elseif GetAdvFVal('SB1','B1_CADMERC',FWxfilial('SB1')+alltrim(CAR->ITEM),1) $ 'U/C'
						@nlin,065 psay 'Lote USA'
					else
						// Para futuras alterações
					endif
				endif
				@nlin,101 psay 'Dt. Emb.'  //'Dt. Valid.' //em caso de mudança apenas apague o que não esta comentado e descomente
				@nlin,111 psay 'Dt. Valid.' //'Dt. Abate'  //os mesmos
				//@nlin,121 psay 'Classif.'
				IF cFilAnt = '01'
					@nlin,122 psay 'Dt. Transf'
				elseif _cGrupo $ _cGrpChar
					@nlin,122 psay 'Dt. Estufa'
				else
					@nlin,122 psay 'Dt. Abate'
				endif
			endif
			if  _c2UM  $ 'CX/SC' //.and. ((_cGrupo < '6000' .or. _cGrupo > '6999') .and. (_cGrupo < '8000' .or. _cGrupo > '8999'))
				nlin++
				SZ8->(dbsetorder(26))
				if	SZ8->(MsSeek(FWxfilial('SZ8') +FWxfilial('SB1') + _cPreItem,.t.))

					_nTotCaixItem := 0
					_nTotPesoItem := 0
					_aParc := {}
					_aDtEmb := {}
					while  SZ8->(!eof()) .and. SZ8->Z8_FIL = FWxfilial('SB1') .and. SZ8->(Z8_PREPED + Z8_COD) = _cPreItem
						_cNumAbt     := ''
						_dDatE    := ''
						//_dDtDesos	 := ''
						_cClassific  := ''
						_cNumAbt := GetAdvFVal('SZ2','Z2_NUMAM',FWxfilial('SZ2')+SZ8->Z8_PREDES,2)

						if !empty(mv_par05)
							if _cNumAbt <> mv_par05
								SZ8->(DbSkip())
								loop
							endif
						endif

						//_dDtDesos	 := GetAdvFVal('SZ2','Z2_DTPROD','00'+SZ8->Z8_PREDES,2)
						if _cGrupo $ _cGrpPorc
							_dDtAbate := stod('')
						else
							_dDtAbate := GetAdvFVal('SZ2','Z2_DATAABT',iif(!Empty(FWxFilial('SZ8')), FWxFilial('SZ8'),'00')+SZ8->Z8_PREDES,2)
						endif
						if mv_par12 = 1
							_nQuantB1 := GetAdvFVal('SB1','B1_QTBCAIX',FWxFilial('SB1')+SZ8->Z8_COD,1)
						endif
						_dDatE  := SZ8->Z8_DATAP
						/*if mv_par09 = 1
							_dDatE  := iif(Empty(SZ8->Z8_PREDES), SZ8->Z8_DATAP, _dDtAbate)
						else
							_dDatE  := SZ8->Z8_DATAP
						endif*/
						//_dDatE:= GetAdvFVal('SZ2','Z2_DATAABT',FWxFilial('SZ8') + SZ8->Z8_PREDES,2)
						_cClassific := GetAdvFVal('SZ2','Z2_CLASSIF',iif(!Empty(FWxFilial('SZ8')),FWxFilial('SZ8'),'00')+SZ8->Z8_PREDES,2)
						//_cClassEsp	 := GetAdvFVal('SZ2','Z2_CLASESP','00'+SZ8->Z8_PREDES,2)//prioridade por Classificação Especial
						if !empty(mv_par06)
							if _cClassific <> mv_par06
								SZ8->(DbSkip())
								loop
							endif
						endif

						If nLin > 75 // Salto de Página. Neste caso o formulario tem 55 linhas...
							Cabec(Titulo,Cabec1,Cabec2,NomeProg,Tamanho,nTipo)
							nLin := 9
						endif

						//_nPos := aScan(_aParc,{|aVal|aVal[1] = _dDtAbate})
						_cTempSM := GetAdvFVal("SZU",'ZU_SHIPPIN',FWxfilial('SZU')+SZ8->Z8_NUMPREV,2)
						if !empty(_cTempSM)
							_nPosP := aScan(_aParc,{|aVal| aVal[1] = _dDatE .and. aVal[5] = _dDtAbate .and. aVal[7] = SZ8->Z8_NUMPREV})
						else
							_nPosP := aScan(_aParc,{|aVal| aVal[1] = _dDatE .and. aVal[5] = _dDtAbate})
						endif
						_dDataVal = iif(_cGrupo $ _cGrpMds, _dDtAbate, _dDatE) + GetAdvFVal("SB1",'B1_VALID',FWxfilial('SB1')+SZ8->Z8_COD,1)
						if _nPosP <> 0
							_aParc[_nPosP,2] += 1
							_aParc[_nPosP,3] += iif(mv_par10 = 1 .and. _nPesFix != 0.0, _nPesFix, SZ8->Z8_PESO)
							_aParc[_nPosP,4] := SZ8->Z8_PREDES
							//_aParc[_nPosP,5] := _dDtAbate
							_aParc[_nPosP,6] := _dDataVal
							_aParc[_nPosP,7] := SZ8->Z8_NUMPREV
						else
							aadd(_aParc,{_dDatE,1,iif(mv_par10 = 1 .and. _nPesFix != 0.0, _nPesFix, SZ8->Z8_PESO),SZ8->Z8_PREDES, _dDtAbate, _dDataVal, SZ8->Z8_NUMPREV})
						endif

						if !empty(_cTempSM) .and. _cShipMark <>_cTempSM
							@nlin,001 psay replicate('-',132)
							nlin++
							@nlin,001 psay "Shipping Mark: "
							@nlin,020 psay _cTempSM
							nlin++
							@nlin,001 psay replicate('-',132)
							nlin++
							_cShipMark := _cTempSM

							_nPos := aScan(_aShipM,{|aVal| aVal = _cTempSM})
							if _nPos = 0
								aadd(_aShipM, _cTempSM)
							endif
						endif

						if mv_par07 = 1
							_cCheck := ""
							if SZ8->Z8_CHKCARR == '0'
								_cCheck := "Carreg. corret."
							elseif SZ8->Z8_CHKCARR == '1'
								_cCheck := "Em outro carreg"
							elseif SZ8->Z8_CHKCARR == '2'
								_cCheck := "Em estoque"
							endif
							@nlin,015 psay SZ8->Z8_CONTROL
							if mv_par12 = 1
								@nlin,030 psay transform(_nQuantB1,'@E 999')
							else
								@nlin,030 psay transform(SZ8->Z8_QUANT,'@E 999')
							endif
							@nlin,037 psay transform(SZ8->Z8_PESOBR,'@E 999.99')
							@nlin,045 psay transform(SZ8->Z8_TARA,'@E 99.999')
							@nlin,055 psay transform(iif(mv_par10 = 1 .and. _nPesFix != 0.0, _nPesFix, SZ8->Z8_PESO),'@E 999.99')
							if mv_par11 = 1
								if alltrim(CAR->ITEM) $ _cCodLote
									@nlin,063 psay alltrim(SZ8->Z8_PREDES)
								elseif GetAdvFVal('SB1','B1_CADMERC',FWxfilial('SB1')+alltrim(CAR->ITEM),1) $ 'U/C'
									@nlin,063 psay alltrim(GetAdvFVal("SZU",'ZU_LOTEUA',FWxfilial('SZU')+SZ8->Z8_NUMPREV,2))
								else
									// Para futuras alterações
								endif
							endif
							@nlin,083 psay padr(_cCheck,15)
							@nlin,100 psay DToC(SZ8->Z8_DATAP)
							@nlin,110 psay DToC(SZ8->Z8_DATAVAL)
							/* Dia 08/06/22 - Ajuste solicitado pelo Philip para visualizar data de transferência*/
							IF cFilAnt = '01'
								@nlin,122 psay SZ8->Z8_DTRANSF
							elseif _cGrupo $ _cGrpChar
								@nlin,122 psay dtoc(GetAdvFVal("SZU",'ZU_DTEST',FWxfilial('SZU')+SZ8->Z8_NUMPREV,2))
							else
								@nlin,122 psay DToC(_dDtAbate)
							endif

							nlin++
						endif

						if mv_par12 = 1
							_nQtPeca += _nQuantB1
						else
							_nQtPeca += SZ8->Z8_QUANT
						endif
						_nTotCaix++
						_nTotPesoL += iif(mv_par10 = 1 .and. _nPesFix != 0.0, _nPesFix, SZ8->Z8_PESO)
						_nTotPesoB += SZ8->Z8_PESOBR
						_nTotCaixItem++
						_nTotPesoItem += iif(mv_par10 = 1 .and. _nPesFix != 0.0, _nPesFix, SZ8->Z8_PESO)

						SZ8->(dbskip())
					enddo

					for i:=1 to len(_aParc)
						If nLin > 75 // Salto de Página. Neste caso o formulario tem 55 linhas...
							Cabec(Titulo,Cabec1,Cabec2,NomeProg,Tamanho,nTipo)
							nLin := 9
						endif

						nlin++
						if mv_par07 = 1
							@nlin,15 psay 'Total de Caixas no dia: ' + dtoc(_aParc[i,1]) + ' - ' + transform(_aParc[i,2],'@E 999,999') + ' - Peso Liq.: ' + transform(_aParc[i,3],'@E 999,999.99')
						else
							/*buscaDtDso(_aParc[i,5],alltrim(CAR->PREPED),alltrim(CAR->ITEM))
							TMP->(dbGoTop())
							_z8_Data := ''
							while TMP->(!eof())
								_z8_Data := iif(Empty(_aParc[i,4]), TMP->Z8_DATAP, TMP->Z2_DATAABT)
								TMP->(dbSkip())
							enddo*/
							_cTempSM := GetAdvFVal("SZU",'ZU_SHIPPIN',FWxfilial('SZU')+_aParc[i,7],2,"",.T.)
							_cTempLU := alltrim(GetAdvFVal("SZU",'ZU_LOTEUA',FWxfilial('SZU')+_aParc[i,7],2,"",.T.))
							if mv_par07 = 2 .and. mv_par11 = 1 .and. !empty(_cTempSM) .and. _cLote <> _cTempLU
								nlin++
								@nlin,001 psay "Lote USA: "
								@nlin,011 psay _cTempLU
								nlin+=2
								_cLote := _cTempLU
							endif

							if mv_par09 = 1
								//if Empty(_aParc[i,4])
									//@nlin,15 psay 'Data(s) de Embalagem: '+ DToC(_aParc[i,1]) + space(10) +'Data de validade: ' + DToC(_aParc[i,5]) + space(10) +  transform(_aParc[i,2],'@E 999,999') + ' - Peso Liq.: ' + transform(_aParc[i,3],'@E 999,999.99')
								//else
								@nlin,5 psay 'Dt. de Abate: '+ DToC(_aParc[i,5]) + ' | Dt. de Embal.: '+ DToC(_aParc[i,1]) + ' | Dt. de Valid.: ' + DToC(_aParc[i,6]) + ' | Qtd. Caixas: ' +  transform(_aParc[i,2],'@E 999,999') + ' | Peso Liq.: ' + transform(_aParc[i,3],'@E 999,999.99')
								//endif
							else
								@nlin,5 psay 'Data(s) de Embalagem: '+ DToC(_aParc[i,1]) + space(10) +'Data de Validade: ' + DToC(_aParc[i,6]) + space(10) +  transform(_aParc[i,2],'@E 999,999') + ' - Peso Liq.: ' + transform(_aParc[i,3],'@E 999,999.99')
							endif
							nlin++
						endif
					next

					nlin++
					@nlin,15 psay 'Total de pecas: ' + transform(_nQtPeca,'@E 999,999')
					nlin++
					@nlin,01 psay replicate('-',132)
					nlin++
					_nQtPeca := 0
				endif

			/*elseif _c2UM $ 'CX/SC' .and. ((_cGrupo >= '6000' .and. _cGrupo <= '6999') .or. (_cGrupo >= '8000' .and. _cGrupo <= '8999'))
				nlin++
				SZ8->(dbsetorder(26))
				if	SZ8->(MsSeek(FWxfilial('SZ8') + FWxfilial('SB1') + _cPreItem,.t.))

					_nTotCaixItem := 0
					_nTotPesoItem := 0

					while  SZ8->(!eof()) .and. SZ8->(Z8_PREPED + Z8_COD) = _cPreItem  .and. SZ8->Z8_FIL = FWxfilial('SB1');
					.and. SZ8->Z8_TERC = 'S'
						If nLin > 75 // Salto de Página. Neste caso o formulario tem 55 linhas...
							Cabec(Titulo,Cabec1,Cabec2,NomeProg,Tamanho,nTipo)
							nLin := 9
						endif

						if mv_par07 = 1
							@nlin,15 psay SZ8->Z8_CONTROL
							@nlin,41 psay transform(iif(mv_par10 = 1 .and. _nPesFix != 0.0, _nPesFix, SZ8->Z8_PESO),'@E 999.99')
							@nlin,67 psay transform(iif(mv_par10 = 1 .and. _nPesFix != 0.0, _nPesFix, SZ8->Z8_PESO),'@E 999.99')
							@nlin,87 psay "Produto 3°"
							nlin++
						endif

						_nTotCaix++
						_nTotPesoL += iif(mv_par10 = 1 .and. _nPesFix != 0.0, _nPesFix, SZ8->Z8_PESO)
						_nTotPesoB += iif(mv_par10 = 1 .and. _nPesFix != 0.0, _nPesFix, SZ8->Z8_PESO)

						_nTotCaixItem++
						_nTotPesoItem += iif(mv_par10 = 1 .and. _nPesFix != 0.0, _nPesFix, SZ8->Z8_PESO)

						SZ8->(dbskip())

					enddo
				endif*/

			elseif _c2UM = 'PC'

				nlin++
				ZZ2->(dbsetorder(4))
				ZZ2->(dbgotop())
				if ZZ2->(MsSeek(FWxfilial('ZZ2') + CAR->CARGA + CAR->PREPED + CAR->NUM_ITEM))
					_nTotCaixItem := 0
					_nTotPesoItem := 0
					_cod := ''
					_cTpOper := GetAdvFVal('ZZ4','ZZ4_TPOPER',FWxFilial('ZZ4') + ZZ2->ZZ2_PREPED,2)

					if _cTpOper == 'C'

						_nTotQntCmp := 0 //quantidade total comprada
						_nTotPesLCmp := 0 //peso liquido total comprado
						_nTotPesBCmp := 0 //peso bruto total comprado
						_nTotTaraCmp := 0 //tara total comprada

						if mv_par07 == 1//se for analitico e tipo de operação for compra

							@nlin,15 psay 'Cod. Prod           Descricao             Quantidade        Peso Bruto         Tara         Peso Liquido'
							nlin++
						endif

					endif

					while ZZ2->(!eof()) .and. alltrim(ZZ2->(ZZ2_PRECAR + ZZ2_PREPED + ZZ2_ITEM)) == alltrim(CAR->(CARGA+PREPED+NUM_ITEM)) .and. ZZ2->ZZ2_FILIAL = FWxfilial('ZZ2')
						//while ZZ2->(!eof()) .and. ZZ2->(ZZ2_PREPED+ZZ2_COD) = _cPreItem .and. ZZ2->ZZ2_FILIAL = FWxfilial('ZZ2')
						If nLin > 65 // Salto de Página. Neste caso o formulario tem 55 linhas...
							Cabec(Titulo,Cabec1,Cabec2,NomeProg,Tamanho,nTipo)
							nLin := 9
						endif

						if _cTpOper == 'C

							if _cod <> ZZ2->ZZ2_COD
								_cod := ZZ2->ZZ2_COD
							endif

							if mv_par07 == 1 //se for analitico e tipo de operação for compra

								@nlin,15 psay ZZ2->ZZ2_COD
								@nlin,33 psay ZZ2->ZZ2_DESCRI
								@nlin,60 psay transform(ZZ2->ZZ2_QUANT,'@E 999')
								@nlin,76 psay transform(ZZ2->ZZ2_PESOB,'@E 999.99')
								@nlin,93 psay transform(ZZ2->ZZ2_TARA,'@E 99.99')
								@nlin,110 psay transform(ZZ2->ZZ2_PESOL,'@E 999.99')
								nlin++

							endif

							_nTotQntCmp  += ZZ2->ZZ2_QUANT //quantidade total comprada
							_nTotPesLCmp += ZZ2->ZZ2_PESOL //peso liquido total comprado
							_nTotPesBCmp += ZZ2->ZZ2_PESOB //peso bruto total comprado
							_nTotTaraCmp += ZZ2->ZZ2_TARA //tara total comprada

						endif
						_nTotPeca += ZZ2->ZZ2_QUANT
						//_nTotCaix  += ZZ2->ZZ2_QUANT
						_nTotPesoL += ZZ2->ZZ2_PESOL
						_nTotPesoB += ZZ2->ZZ2_PESOL

						_nTotCaixItem++
						_nTotPesoItem += ZZ2->ZZ2_PESOL

						ZZ2->(dbskip())
						if _cTpOper == 'C'
							if _cod <> ZZ2->ZZ2_COD .or. ZZ2->(eof())

								@nlin,15 psay space(42) + 'Quantidade        Peso Bruto         Tara         Peso Liquido'
								nlin++

								@nlin,20 psay 'TOTAL:'
								@nlin,60 psay transform(_nTotQntCmp,'@E 999,999')
								@nlin,76 psay transform(_nTotPesBCmp,'@E 9,999,999.99')
								@nlin,93 psay transform(_nTotTaraCmp,'@E 9,999.99')
								@nlin,110 psay transform(_nTotPesLCmp,'@E 9,999,999.99')
								nlin++

								@nlin,01 psay replicate('-',132)
								nlin++

								_nTotQntCmp  := 0 //quantidade total comprada
								_nTotPesLCmp := 0 //peso liquido total comprado
								_nTotPesBCmp := 0 //peso bruto total comprado
								_nTotTaraCmp := 0 //tara total comprada

							endif
						endif
					enddo
				endif

				ZZ2->(dbsetorder(4))
				ZZ2->(dbgotop())
				ZZ2->(MsSeek(FWxfilial('ZZ2') + CAR->CARGA + CAR->PREPED + CAR->NUM_ITEM))//para reposicionar na tabela

				ZAJ->(dbSetOrder(3))
				ZAJ->(dbGoTop())
				if ZAJ->(MsSeek(FWxFilial('ZAJ') + ZZ2->(ZZ2_PRECAR + ZZ2_PREPED + ZZ2_ITEM)))

					_aParc := {}
					if mv_par07 = 1
						@nlin,15 psay 'Cod. Pc          Sequencial      Dt.Abate       Dt.Carreg.      Dt.Valid.     Classif.    Peso Unit.'
						nlin++
					endif
					while ZAJ->(!eof()) .and. ZAJ->ZAJ_FILIAL = FWxFilial('ZAJ') .and. ZAJ->(ZAJ_PRECAR + ZAJ_PREPED + ZAJ_ITEM) == ZZ2->(ZZ2_PRECAR+ZZ2_PREPED+ZZ2_ITEM)
						If nLin > 65 // Salto de Página. Neste caso o formulario tem 55 linhas...
							Cabec(Titulo,Cabec1,Cabec2,NomeProg,Tamanho,nTipo)
							nLin := 9
						endif

						dbSelectArea('SB1')
						_nDiasVal := GetAdvFVal('SB1','B1_VALID',FWxFilial('SB1') + ZZ2->ZZ2_COD,1)
						_dDtAbte  := GetAdvFVal('SZG','ZG_DATA',FWxFilial('SZG') + ZAJ->ZAJ_NUMAM,1)
						_dDtValid := _dDtAbte + _nDiasVal
						_cClassif := GetAdvFVal('SZK','ZK_CLASSIF',FWxFilial('SZK') + ZAJ->(ZAJ_NUMAM + ZAJ_LOTE + ZAJ_CONTRO),5)
						_cClasesp := GetAdvFVal('SZK','ZK_CLASESP',FWxFilial('SZK') + ZAJ->(ZAJ_NUMAM + ZAJ_LOTE + ZAJ_CONTRO),5)

						_nPos := aScan(_aParc,{|aVal|aVal[1] = _dDtAbte})

						if _nPos <> 0
							_aParc[_nPos,2]+=1
						else
							aadd(_aParc,{_dDtAbte,1})
						endif

						if mv_par07 == 1//se for analitico
							@nlin,15 psay ZAJ->ZAJ_NUM
							@nlin,33 psay ZAJ->ZAJ_CONTRO
							@nlin,48 psay _dDtAbte
							@nlin,64 psay ZAJ->ZAJ_DATAS
							@nlin,79 psay _dDtValid
							//@nlin,96 psay _cClassif
							@nlin,96 psay iif(!empty(_cClassif) .and. _cClasesp = '1',_cClassif + '->UY',_cClassif)
							//@nlin,106 psay transform(ZAJ->ZAJ_PESO,'@E 999.99')
							nlin++
						endif
						ZAJ->(dbSkip())

					enddo
				endif

				if mv_par09 = 1
					for i:=1 to len(_aParc)
						If nLin > 75 // Salto de Página. Neste caso o formulario tem 55 linhas...
							Cabec(Titulo,Cabec1,Cabec2,NomeProg,Tamanho,nTipo)
							nLin := 9
						endif
						nlin++
						@nlin,15 psay 'Total de Caixas no dia: ' + dtoc(_aParc[i,1]) + ' - ' + transform(_aParc[i,2],'@E 999,999')
					next
				endif
			endif
			if mv_par07 = 2
				@nlin,80 psay transform(_nTotCaixItem,'@E 999,999')
				@nlin,95 psay transform(_nTotPesoItem,'@E 999,999.99')
			endif
		endif
		nlin++

		CAR->(dbSkip()) // Avanca o ponteiro do registro no arquivo

		if CAR->(eof()) .or.  CAR->CARGA <> _cPrecar2
			If nLin > 75 // Salto de Página. Neste caso o formulario tem 55 linhas...
				Cabec(Titulo,Cabec1,Cabec2,NomeProg,Tamanho,nTipo)
				nLin := 9
			endif
			nlin++
			@nlin,00 psay replicate('=',132)
			nlin++
			@nlin,02 psay 'NUMERO TOTAL DE CAIXAS DA CARGA:        ' + transform(_nTotCaix, '@E 999,999')
			nlin += 2
			@nlin,02 psay 'NUMERO TOTAL DE PECAS:                  ' + transform(_nTotPeca, '@E 999,999')
			nlin += 2
			@nlin,02 psay 'PESO LIQUIDO TOTAL DA CARGA:     ' + transform(_nTotPesoL,'@E 999,999,999.99')
			nlin += 2
			@nlin,02 psay 'PESO BRUTO TOTAL DA CARGA:       ' + transform(_nTotPesoB,'@E 999,999,999.99')
			if !empty(_aShipM)
				for i := 1 to len(_aShipM)
					If nLin > 75 // Salto de Página. Neste caso o formulario tem 55 linhas...
						Cabec(Titulo,Cabec1,Cabec2,NomeProg,Tamanho,nTipo)
						nLin := 9
					endif
					_aTotSM := SumShipM(_aShipM[i])
					nlin += 2
					@nlin,02 psay 'TOTAL DE CAIXAS DO SHIPPING MARK '+_aShipM[i]+': ' + transform(_aTotSM[1],'@E 999,999')
					nlin += 2
					@nlin,02 psay 'PESO TOTAL DO SHIPPING MARK '+_aShipM[i]+': ' + transform(_aTotSM[2],'@E 999,999,999.99')
				next
			endif
			nlin++
			@nlin,00 psay replicate('=',132)
			_cPrecar2 := CAR->CARGA
		endif

	EndDo

	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Finaliza a execucao do relatorio...                                 ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ

	DbCloseArea('CAR')

	SET DEVICE TO SCREEN

	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Se impressao em disco, chama o gerenciador de impressao...          ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ

	If aReturn[5]==1
		dbCommitAll()
		SET PRINTER TO
		OurSpool(wnrel)
	endif

	MS_FLUSH()

Return

static function buscaDtDso(_dtabate,_cPreped,_cProd)
	
	cQuery3 := " SELECT Z8_DATAP, Z2_DATAABT"
	cQuery3 += " FROM " + RetSqlTab("SZ2") + ", " + retSqlTab('SZ8')
	cQuery3 += " WHERE " + RetSQLFil('SZ2') + " AND " + retSqlFil('SZ8')
	cQuery3 += " AND Z2_NUM = Z8_PREDES AND Z8_PREPED = '"+_cPreped+"' AND Z8_COD = '"+_cProd+"'"
	cQuery3 += " AND Z2_DATAABT = '" + dtos(_dtabate) + "' AND Z8_FIL = '"+cFilAnt+"'"
	cQuery3 += " AND " + RetSQLDel('SZ2') + " AND " + retSqlDel('SZ8')
	cQuery3 += " GROUP BY Z8_DATAP, Z2_DATAABT"
	cQuery3 := ChangeQuery(cQuery3)
	/*
	cQuery3 := " SELECT Z8_DATAP "
	cQuery3 += " FROM "  + retSqlTab('SZ8')
	cQuery3 += " WHERE " + retSqlFil('SZ8')
	cQuery3 += " AND Z8_PREPED = '"+_cPreped+"' AND Z8_COD = '"+_cProd+"'"
	cQuery3 += " AND Z8_FIL = '"+cFilAnt+"'"
	cQuery3 += " AND "+ retSqlDel('SZ8')
	cQuery3 += " GROUP BY Z8_DATAP"
	cQuery3 := ChangeQuery(cQuery3)
	*/
	//	* Mostrar a consulta */
	//	@ 116,090 To 416,707 Dialog oDlgMemo Title "Consulta"
	//	@ 055,005 Get cQuery3 Size 250,080 MEMO Object oMemo
	//	Activate Dialog oDlgMemo
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Monta a interface padrao com o usuario...                           ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	If Select("TMP") != 0
		TMP->(dbCloseArea())
	endif
	TCQUERY cQuery3 NEW ALIAS "TMP"

return

Static Function SumShipM(_cShipM)
	cQuery4 := " SELECT COUNT(Z8_CONTROL) AS CAIXAS, SUM(Z8_PESO) AS PESO"
	cQuery4 += " FROM " + retSqlTab('SZ8')
	cQuery4 += " INNER JOIN " + retSqlTab('SZU') + "ON (Z8_NUMPREV = ZU_NUM)"
	cQuery4 += " WHERE " + retSqlFil('SZ8') + " AND " + retSqlFil('SZU')
	cQuery4 += " AND Z8_FIL = '" + cFilAnt + "'"
	cQuery4 += " AND Z8_PRECAR BETWEEN '" + mv_par01 + "' AND '" + mv_par02 + "'"
	cQuery4 += " AND ZU_SHIPPIN = '" + alltrim(_cShipM) + "'"
	cQuery4 += " AND " + retSqlDel('SZ8') + " AND " + retSqlDel('SZU')

	cQuery4 := ChangeQuery(cQuery4)

	//	* Mostrar a consulta */
	//@ 116,090 To 416,707 Dialog oDlgMemo Title "Consulta"
	//@ 055,005 Get cQuery2 Size 250,080 MEMO Object oMemo
	//Activate Dialog oDlgMemo

	if Select("TMP") != 0
		TMP->(dbCloseArea())
	endif

	TCQUERY cQuery4 NEW ALIAS "TMP"

Return {TMP->CAIXAS, TMP->PESO}
