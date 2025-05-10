#INCLUDE "rwmake.ch"
#INCLUDE "topconn.ch"

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

User Function GJF53m()

	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Declaracao de Variaveis                                             ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ

	Local cDesc1         := "Este programa tem como objetivo imprimir relatorio  "
	Local cDesc2         := "de manifesto de carga analítico listando as caixas ou"
	Local cDesc3         := "peças que formaram esta carga."
//	Local cPict          := ""
	Local titulo       	 := "MANIFESTO DE CARGA ANALÍTICO"
	Local nLin         	 := 80
	Local Cabec1       	 := "              Frigorifico Silva Industria e Comercio Ltda. - BR 392 Km 8 Passo das Tropas - Santa Maria - RS - Brasil"
	Local Cabec2       	 := "  Carga    Placa      Data   Observação"

	//Local imprime      := .T.
	Local aOrd := {}
	Private lEnd         := .F.
	Private lAbortPrint  := .F.
	Private CbTxt        := ""
	Private limite           := 128
	Private tamanho          := "M"
	Private nomeprog         := "GJF53" // Coloque aqui o nome do programa para impressao no cabecalho
	Private nTipo            := 18
	Private aReturn          := { "Zebrado", 1, "Administracao", 2, 2, 1, "", 1}
	Private nLastKey        := 0
	Private cPerg   := "GJF53"
	//Private cbtxt      := Space(10)
	Private cbcont     := 00
	Private CONTFL     := 01
	Private m_pag      := 01
	Private wnrel      := "GJF53" // Coloque aqui o nome do arquivo usado para impressao em disco
	Private TotCaix    := 0.00
	Private TotPeso    := 0.00
	Private _aParc     := {}
	Private _aDtEmb     := {}

	pergunte(cPerg,.F.)

	//para verificação se existe previsao de pesagem

	wnrel := SetPrint('SZ8',NomeProg,cPerg,@titulo,cDesc1,cDesc2,cDesc3,.T.,aOrd,.T.,Tamanho,,.T.)

	cQuery := " SELECT ZZ3_NUM AS CARGA, ZZ4_NUM AS PREPED,ZZ5_ITEM AS NUM_ITEM, ZZ5_COD AS ITEM, ZZ5_QRCAIX AS QRCAIX, ZZ5_QRPESO AS QRPESO,"
	cQuery += " ZZ4_CODCLI, ZZ4_LOJA, ZZ4_MUN, ZZ4_MARCA, ZZ4_QPPESO, ZZ4_NUMPED AS NUMPED "
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
	Endif
	TCQUERY cQuery NEW ALIAS "CAR"

	If nLastKey == 27
		Return
	Endif

	SetDefault(aReturn,'SZ8')

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

	CAR->(dbGoTop())

	CAR->(SetRegua(RecCount()))

	_cPrecar  := ' '
	_cPrecar2 := CAR->CARGA
	_cPreped  := ' '
	_nTotCaix  := 0
	_nTotPeca := 0
	_nTotPesoL := 0
	_nTotPesoB := 0
	_lAbt      := .f.
	_lClass    := .f.
	_nQtPeca := 0

	While CAR->(!EOF())

		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³ Verifica o cancelamento pelo usuario...                             ³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ

		If lAbortPrint
			@nLin,00 PSAY "*** CANCELADO PELO OPERADOR ***"
			Exit
		Endif

		If nLin > 75 // Salto de Página. Neste caso o formulario tem 55 linhas...
			Cabec(Titulo,Cabec1,Cabec2,NomeProg,Tamanho,nTipo)
			nLin := 9
		Endif
		if  CAR->CARGA != _cPrecar
			@nlin,002 psay CAR->CARGA
			@nlin,010 psay fBuscaCPO('ZZ3',2,xfilial('ZZ3')+alltrim(CAR->CARGA),'ZZ3_PLACA')
			@nlin,020 psay fBuscaCPO('ZZ3',2,xfilial('ZZ3')+alltrim(CAR->CARGA),'ZZ3_DTCAR')
			@nlin,030 psay fBuscaCPO('ZZ3',2,xfilial('ZZ3')+alltrim(CAR->CARGA),'ZZ3_OBS')
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
				Endif
				TCQUERY cQuery2 NEW ALIAS "CAR2"
				if CAR2->NUMAM = 0
					CAR->(DbSkip())
					loop
				endif
			endif

			nlin++
			@nlin,010 psay CAR->PREPED

			_cCliente := fBuscaCPO('ZZ4',2,xfilial('ZZ4')+alltrim(CAR->PREPED),'ZZ4_CODCLI')
			_cLoja    := fBuscaCPO('ZZ4',2,xfilial('ZZ4')+alltrim(CAR->PREPED),'ZZ4_LOJA')
			_cDoc     := fBuscaCPO('SD2',8,xfilial('SD2')+alltrim(CAR->NUMPED),'D2_DOC')
			_cSerie   := fBuscaCPO('SD2',8,xfilial('SD2')+alltrim(CAR->NUMPED),'D2_SERIE')
			@nlin,020 psay _cCliente + "/" + _cLoja
			@nlin,030 psay fBuscaCPO('SA1',1,xfilial('SA1')+_cCliente + _cLoja,'A1_NOME')
			@nlin,070 psay alltrim(CAR->ZZ4_MUN) + '   Marca: ' +alltrim(CAR->ZZ4_MARCA)
			nlin++			
			@nlin,00 psay replicate('-',132)
			nlin++
			_cPreped := CAR->PREPED
		endif

		_cPreItem := alltrim(CAR->PREPED)+alltrim(CAR->ITEM)
		_c2UM     := fBuscaCPO('SB1',1,xfilial('SB1')+alltrim(CAR->ITEM),'B1_SEGUM')
		_cGrupo   := fBuscaCPO('SB1',1,xfilial('SB1')+alltrim(CAR->ITEM),'B1_GRUPO')
		_cDescri  := alltrim(fBuscaCPO('SB1',1,xfilial('SB1')+alltrim(CAR->ITEM),'B1_DESC')) + '   ('+_c2UM + ')'

		if fBuscaCPO('ZZ5',1,xfilial('ZZ5')+alltrim(CAR->(PREPED+NUM_ITEM)),'ZZ5_QRCAIX') != 0
			@nlin,020 psay CAR->ITEM
			@nlin,030 psay substr(_cDescri,1,38)
			if mv_par07 = 1 .And. _c2UM <> 'PC'
				@nlin,075 psay 'Caixas/Peças: ' + transform(CAR->QRCAIX,'@E 9,999')
				@nlin,103 psay 'Peso Líquido: ' + transform(CAR->QRPESO,'@E 999,999.99')
				nlin++
				@nlin,015 psay 'Cod. Caixa'
				@nlin,032 psay 'Quant.'
				@nlin,041 psay 'Peso B.'
				@nlin,055 psay 'Tara'
				@nlin,067 psay 'Peso L.'
				if mv_par09 = 1
					@nlin,080 psay 'Dt. Abate'  //'Dt. Prod.'	//modificação feita por solicitação da IF e alterada por Mauricio Roehrs
				endif
				@nlin,095 psay 'Dt. Emb.'  //'Dt. Valid.' //em caso de mudança apenas apague o que não esta comentado e descomente
				@nlin,108 psay 'Dt. Valid.' //'Dt. Abate'  //os mesmos
				//@nlin,121 psay 'Classif.'
					IF cFilAnt = '01'
						@nlin,121 psay 'Dt.Transf'
					Else								
						@nlin,121 psay 'Classif.'
					Endif
			endif

			if  _c2UM  = 'CX' .and. ((_cGrupo < '6000' .or. _cGrupo > '6999') .and. (_cGrupo < '8000' .or. _cGrupo > '8999'))
				nlin++
				SZ8->(dbsetorder(26))
				if	SZ8->(dbseek(xfilial('SZ8') +xfilial('SB1') + _cPreItem,.t.))

					_nTotCaixItem := 0
					_nTotPesoItem := 0
					_aParc := {}
					_aDtEmb := {}
					while  SZ8->(!eof()) .and. SZ8->Z8_FIL = xfilial('SB1') .and. SZ8->(Z8_PREPED + Z8_COD) = _cPreItem
						_cNumAbt     := ''
						_dDtAbate    := ''
						_dDtDesos	 := ''
						_cClassific  := ''

						_cNumAbt := fBuscaCPO('SZ2',2,xfilial('SZ2')+SZ8->Z8_PREDES,'Z2_NUMAM')

						if !empty(mv_par05)
							if _cNumAbt <> mv_par05
								SZ8->(DbSkip())
								loop
							endif
						endif

						_dDtDesos	 := fBuscaCPO('SZ2',2,'00'+SZ8->Z8_PREDES,'Z2_DTPROD')
						_dDtAbate    := fBuscaCPO('SZ2',2,'00'+SZ8->Z8_PREDES,'Z2_DATAABT')
						_cClassific  := fBuscaCPO('SZ2',2,'00'+SZ8->Z8_PREDES,'Z2_CLASSIF')
						_cClassEsp	 := fBuscaCPO('SZ2',2,'00'+SZ8->Z8_PREDES,'Z2_CLASESP')//prioridade por Classificação Especial

						if !empty(mv_par06)
							if _cClassific <> mv_par06
								SZ8->(DbSkip())
								loop
							endif
						endif

						If nLin > 75 // Salto de Página. Neste caso o formulario tem 55 linhas...
							Cabec(Titulo,Cabec1,Cabec2,NomeProg,Tamanho,nTipo)
							nLin := 9
						Endif

						/*if _dtParc <> _dDtAbate
						nlin++
						@nlin,15 psay 'Total Parcial por Data: ' + transform(_totParc,'@E 999,999')
						nlin++
						_totParc := 0
						_dtParc  := _dDtAbate
						else
						_totParc++
						endif*/

						_nPos := aScan(_aParc,{|aVal|aVal[1] = _dDtAbate})

						if _nPos <> 0
							_aParc[_nPos,2] += 1
							_aParc[_nPos,3] += SZ8->Z8_PESO
							_aParc[_nPos,4] := SZ8->Z8_PREDES

						else
							aadd(_aParc,{_dDtAbate,1,SZ8->Z8_PESO,SZ8->Z8_PREDES})
						endif

						if mv_par07 = 1
							@nlin,015 psay SZ8->Z8_CONTROL
							@nlin,032 psay transform(SZ8->Z8_QUANT,'@E 999')
							@nlin,041 psay transform(SZ8->Z8_PESOBR,'@E 999.99')
							@nlin,055 psay transform(SZ8->Z8_TARA,'@E 99.999')
							@nlin,067 psay transform(SZ8->Z8_PESO,'@E 999.99')
							if mv_par09 = 1
								@nlin,080 psay iif(empty(_dDtAbate) .and. substr(SZ8->Z8_PREDES,1,3) = 'SIF', alltrim(SZ8->Z8_PREDES),_dDtAbate)
							endif
							@nlin,095 psay SZ8->Z8_DATAP
							// @nlin,116 psay 'Abate: ' + 	_cNumPrevDes
							@nlin,110 psay SZ8->Z8_DATAVAL
							/* Dia 08/06/22 - Ajuste solicitado pelo Philip para visualizar data de transferência*/
							IF cFilAnt = '01'
								@nlin,122 psay SZ8->Z8_DTRANSF
							Else								
								@nlin,122 psay iif(!empty(_cClassific) .and. _cClassEsp = 'S',_cClassific + '->UY',_cClassific)
							ENDIF

							nlin++
						endif

						_nQtPeca += SZ8->Z8_QUANT
						_nTotCaix++
						_nTotPesoL += SZ8->Z8_PESO
						_nTotPesoB += SZ8->Z8_PESOBR

						_nTotCaixItem++
						_nTotPesoItem += SZ8->Z8_PESO

						SZ8->(dbskip())

					enddo

					if mv_par09 = 1

						for i:=1 to len(_aParc)
							If nLin > 75 // Salto de Página. Neste caso o formulario tem 55 linhas...
								Cabec(Titulo,Cabec1,Cabec2,NomeProg,Tamanho,nTipo)
								nLin := 9
							Endif

							nlin++
							if mv_par07 = 1
								@nlin,15 psay 'Total de Caixas no dia: ' + dtoc(_aParc[i,1]) + ' - ' + transform(_aParc[i,2],'@E 999,999') + ' - Peso Liq.: ' + transform(_aParc[i,3],'@E 999,999.99')
							else
								//@nlin,15 psay 'Data do Abate: ' + dtoc(_aParc[i,1]) + ' - ' + 'Data da Desossa: ' + ' - ' + 'Quant CX: ' + transform(_aParc[i,2],'@E 999,999')
								@nlin,15 psay 'Total de Caixas do Abate dia: ' + dtoc(_aParc[i,1]) + ' - ' + transform(_aParc[i,2],'@E 999,999') + ' - Peso Liq.: ' + transform(_aParc[i,3],'@E 999,999.99')
								nlin++

								buscaDtDso(_aParc[i,1],alltrim(CAR->PREPED),alltrim(CAR->ITEM))
								TMP->(dbGoTop())
								@nlin,15 psay 'Data(s) de Embalagem: '
								nlin++
								while TMP->(!eof())
									@nlin,15 psay stod(TMP->Z8_DATAP)
									nlin++
									TMP->(dbSkip())
								enddo
							endif
						next

					endif

					nlin++
					@nlin,15 psay 'Total de pecas: ' + transform(_nQtPeca,'@E 999,999')
					nlin++
					@nlin,01 psay replicate('-',132)
					nlin++
					_nQtPeca := 0
				endif

			elseif _c2UM = 'CX' .and. ((_cGrupo >= '6000' .and. _cGrupo <= '6999') .or. (_cGrupo >= '8000' .and. _cGrupo <= '8999'))
				nlin++
				SZ8->(dbsetorder(26))
				if	SZ8->(dbseek(xfilial('SZ8') + xfilial('SB1') + _cPreItem,.t.))

					_nTotCaixItem := 0
					_nTotPesoItem := 0

					while  SZ8->(!eof()) .and. SZ8->(Z8_PREPED + Z8_COD) = _cPreItem  .and. SZ8->Z8_FIL = xfilial('SB1');
					.and. SZ8->Z8_TERC = 'S'
						If nLin > 75 // Salto de Página. Neste caso o formulario tem 55 linhas...
							Cabec(Titulo,Cabec1,Cabec2,NomeProg,Tamanho,nTipo)
							nLin := 9
						Endif

						if mv_par07 = 1
							@nlin,15 psay SZ8->Z8_CONTROL
							@nlin,41 psay transform(SZ8->Z8_PESO,'@E 999.99')
							@nlin,67 psay transform(SZ8->Z8_PESO,'@E 999.99')
							@nlin,87 psay "Produto 3°"
							nlin++
						endif

						_nTotCaix++
						_nTotPesoL += SZ8->Z8_PESO
						_nTotPesoB += SZ8->Z8_PESO

						_nTotCaixItem++
						_nTotPesoItem += SZ8->Z8_PESO

						SZ8->(dbskip())

					enddo
				endif

			elseif _c2UM = 'PC'

				nlin++
				ZZ2->(dbsetorder(4))
				ZZ2->(dbgotop())
				if ZZ2->(dbseek(xfilial('ZZ2') + CAR->CARGA + CAR->PREPED + CAR->NUM_ITEM))
					_nTotCaixItem := 0
					_nTotPesoItem := 0
					_cod := ''
					_cTpOper := fBuscaCpo('ZZ4',2,xFilial('ZZ4') + ZZ2->ZZ2_PREPED,'ZZ4_TPOPER')

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

					while ZZ2->(!eof()) .and. alltrim(ZZ2->(ZZ2_PRECAR + ZZ2_PREPED + ZZ2_ITEM)) == alltrim(CAR->(CARGA+PREPED+NUM_ITEM)) .and. ZZ2->ZZ2_FILIAL = xfilial('ZZ2')
						//while ZZ2->(!eof()) .and. ZZ2->(ZZ2_PREPED+ZZ2_COD) = _cPreItem .and. ZZ2->ZZ2_FILIAL = xfilial('ZZ2')
						If nLin > 65 // Salto de Página. Neste caso o formulario tem 55 linhas...
							Cabec(Titulo,Cabec1,Cabec2,NomeProg,Tamanho,nTipo)
							nLin := 9
						Endif

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
				ZZ2->(dbseek(xfilial('ZZ2') + CAR->CARGA + CAR->PREPED + CAR->NUM_ITEM))//para reposicionar na tabela

				ZAJ->(dbSetOrder(3))
				ZAJ->(dbGoTop())
				if ZAJ->(dbSeek(xFilial('ZAJ') + ZZ2->(ZZ2_PRECAR + ZZ2_PREPED + ZZ2_ITEM)))

					_aParc := {}
					if mv_par07 = 1
						@nlin,15 psay 'Cod. Pc          Sequencial      Dt.Abate       Dt.Carreg.      Dt.Valid.     Classif.    Peso Unit.'
						nlin++
					endif
					while ZAJ->(!eof()) .and. ZAJ->ZAJ_FILIAL = xFilial('ZAJ') .and. ZAJ->(ZAJ_PRECAR + ZAJ_PREPED + ZAJ_ITEM) == ZZ2->(ZZ2_PRECAR+ZZ2_PREPED+ZZ2_ITEM)
						If nLin > 65 // Salto de Página. Neste caso o formulario tem 55 linhas...
							Cabec(Titulo,Cabec1,Cabec2,NomeProg,Tamanho,nTipo)
							nLin := 9
						Endif

						dbSelectArea('SB1')
						_nDiasVal := fBuscaCpo('SB1',1,xFilial('SB1') + ZZ2->ZZ2_COD,'B1_VALID')
						_dDtAbte  := fBuscaCpo('SZG',1,xFilial('SZG') + ZAJ->ZAJ_NUMAM,'ZG_DATA')
						_dDtValid := _dDtAbte + _nDiasVal
						_cClassif := fBuscaCpo('SZK',5,xFilial('SZK') + ZAJ->(ZAJ_NUMAM + ZAJ_LOTE + ZAJ_CONTRO),'ZK_CLASSIF')
						_cClasesp := fBuscaCpo('SZK',5,xFilial('SZK') + ZAJ->(ZAJ_NUMAM + ZAJ_LOTE + ZAJ_CONTRO),'ZK_CLASESP')

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
//							@nlin,106 psay transform(ZAJ->ZAJ_PESO,'@E 999.99')
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
						Endif
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
			Endif
			nlin++
			@nlin,00 psay replicate('=',132)
			nlin++
			@nlin,02 psay 'NUMERO TOTAL DE CAIXAS DA CARGA:        ' + transform(_nTotCaix, '@E 999,999')
			nlin += 2
			@nlin,02 psay 'NUMERO TOTAL DE PECAS:                  ' + transform(_nTotPeca, '@E 999,999')
			nlin += 2
			@nlin,02 psay 'PESO LIQUIDO TOTAL DA CARGA    : ' + transform(_nTotPesoL,'@E 999,999,999.99')
			nlin += 2
			@nlin,02 psay 'PESO BRUTO TOTAL DA CARGA      : ' + transform(_nTotPesoB,'@E 999,999,999.99')
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
	Endif

	MS_FLUSH()

Return

static function buscaDtDso(_dtabate,_cPreped,_cProd)

	cQuery3 := " SELECT Z8_DATAP, Z2_DATAABT "
	cQuery3 += " FROM " + RetSqlTab("SZ2") + ", " + retSqlTab('SZ8')
	cQuery3 += " WHERE " + RetSQLFil('SZ2') + " AND " + retSqlFil('SZ8')
	cQuery3 += " AND Z2_NUM = Z8_PREDES AND Z8_PREPED = '"+_cPreped+"' AND Z8_COD = '"+_cProd+"'"
	cQuery3 += " AND Z2_DATAABT = '" + dtos(_dtabate) + "' AND Z8_FIL = '"+cFilAnt+"'"
	cQuery3 += " AND " + RetSQLDel('SZ2') + " AND " + retSqlDel('SZ8')

	cQuery3 += " GROUP BY Z8_DATAP,Z2_DATAABT"

	cQuery3 := ChangeQuery(cQuery3)

	//alert('1')
	//alert(_aParc[i,1])
	//alert('2')
	//alert(SZ2->Z2_DATAABT)
	//	* Mostrar a consulta */
	//	@ 116,090 To 416,707 Dialog oDlgMemo Title "Consulta"
	//	@ 055,005 Get cQuery3 Size 250,080 MEMO Object oMemo
	//	Activate Dialog oDlgMemo
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Monta a interface padrao com o usuario...                           ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	If Select("TMP") != 0
		TMP->(dbCloseArea())
	Endif
	TCQUERY cQuery3 NEW ALIAS "TMP"

return
