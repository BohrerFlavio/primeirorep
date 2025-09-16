#INCLUDE "RWMAKE.CH"
#INCLUDE "TOPCONN.CH"

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³ GJF53A º Autor ³ Giuliano Forgiarini  º Data ³  14/09/08   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDescricao ³ Relatorio de manifesto de cargas analitico                 º±±
±±º          ³ 														      º±±
±±º Em 2019  ³ Solicitação de criação feita pela qualidade para que se    º±±
±±º          ³ possa visualizar o peso(ZAJ_PESO)                          º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ Comercial e expedições (SIGAPCP e SIGAOMS)                 º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºAlteração ³ Criado essa nova versão para subtotalizar por peças        º±±
±±º          ³ Em 17/12/2020                                              º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/

User Function GJF53A()

	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Declaracao de Variaveis                                             ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ

	Local cDesc1        := "Este programa tem como objetivo imprimir relatorio  "
	Local cDesc2        := "de manifesto de carga analítico listando as caixas ou"
	Local cDesc3        := "peças que formaram esta carga."
	//Local cPict         := ""
	Local titulo       	:= "MANIFESTO DE CARGA ANALÍTICO"
	Local nLin         	:= 80
	Local Cabec1       	:= "              Frigorifico Silva Industria e Comercio Ltda. - BR 392 Km 8 Passo das Tropas - Santa Maria - RS - Brasil"
	Local Cabec2       	:= "  Carga    Placa      Data   Observação"

	//Local imprime      	:= .T.
	Local aOrd 			:= {}
	Private lEnd        := .F.
	Private lAbortPrint := .F.
	Private CbTxt       := ""
	Private limite      := 128
	Private tamanho     := "M"
	Private nomeprog    := "GJF53A" // Coloque aqui o nome do programa para impressao no cabecalho
	Private nTipo       := 18
	Private aReturn     := { "Zebrado", 1, "Administracao", 2, 2, 1, "", 1}
	Private nLastKey    := 0
	Private cPerg   	:= "GJF53"
	//Private cbtxt      	:= Space(10)
	Private cbcont     	:= 00
	Private CONTFL     	:= 01
	Private m_pag      	:= 01
	Private wnrel      	:= "GJF53A" // Coloque aqui o nome do arquivo usado para impressao em disco
	Private TotCaix    	:= 0.00
	Private TotPeso    	:= 0.00
	Private _aParc     	:= {}
	Private _aDtEmb     := {}

	Pergunte(cPerg,.F.)

	wnrel := SetPrint('SZ8',NomeProg,cPerg,@titulo,cDesc1,cDesc2,cDesc3,.T.,aOrd,.T.,Tamanho,,.T.)

	// para verificação se existe previsao de pesagem
	cQuery := " SELECT ZZ3_NUM AS CARGA, ZZ4_NUM AS PREPED,ZZ5_ITEM AS NUM_ITEM, ZZ5_COD AS ITEM, ZZ5_QRCAIX AS QRCAIX, ZZ5_QRPESO AS QRPESO,"
	cQuery += " ZZ4_CODCLI, ZZ4_LOJA, ZZ4_MUN, ZZ4_MARCA, ZZ4_QPPESO, ZZ4_NUMPED AS NUMPED "
	cQuery += " FROM " + RetSqlTab("ZZ5") + ", " + RetSqlTab("ZZ4")  + ", " + RetSqlTab("ZZ3")
	cQuery += " WHERE " + RetSQLFil('ZZ5') + " AND " + RetSQLFil('ZZ4') + " AND " + RetSQLFil('ZZ3') + " AND "
	cQuery += " ZZ3_NUM = ZZ4_PRECAR AND  ZZ4_NUM = ZZ5_NUM AND  ZZ5_QRPESO <> 0 AND "
	cQuery += " (ZZ3_NUM BETWEEN '" + mv_par01 + "' AND '" + mv_par02 +"') AND "
	cQuery += " (ZZ4_NUM BETWEEN '" + mv_par03 + "' AND '" + mv_par04 +"') AND "
	cQuery +=  RetSQLDel('ZZ3') + " AND " + RetSQLDel('ZZ4') + " AND " + RetSQLDel('ZZ5')
	If mv_par08 = 1
		cQuery += " ORDER BY ZZ3_NUM,ZZ4_NUM,ZZ5_ITEM"
	Else
		cQuery += " ORDER BY ZZ3_NUM,ZZ4_CODCLI,ZZ4_LOJA,ZZ4_MUN, ZZ4_MARCA,ZZ4_QPPESO"
	Endif

	cQuery := ChangeQuery(cQuery)

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


//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Chamada da função RunReport                                         ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
Static Function RunReport(Cabec1,Cabec2,Titulo,nLin)

	//Local nOrdem
	Local i, j

	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ SETREGUA -> Indica quantos registros serao processados para a regua ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	CAR->(dbGoTop())
	CAR->(SetRegua(RecCount()))

	_cPrecar   := ' '
	_cPrecar2  := CAR->CARGA
	_cPreped   := ' '
	_nTotCaix  := 0
	_nTotPeca  := 0
	_nTotPesoL := 0
	_nTotPesoB := 0
	_lAbt      := .F.
	_lClass    := .F.
	_nQtPeca   := 0
	_nQtPC     := 0

	While CAR->(!Eof())

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

		If  CAR->CARGA != _cPrecar
			@nlin,002 psay CAR->CARGA
			@nlin,010 psay Posicione('ZZ3',2,xfilial('ZZ3')+alltrim(CAR->CARGA),'ZZ3_PLACA')
			@nlin,020 psay Posicione('ZZ3',2,xfilial('ZZ3')+alltrim(CAR->CARGA),'ZZ3_DTCAR')
			@nlin,030 psay Posicione('ZZ3',2,xfilial('ZZ3')+alltrim(CAR->CARGA),'ZZ3_OBS')
			nlin++
			@nlin,00 psay replicate('=',132)
			_cPrecar := CAR->CARGA
			nlin++
		Endif
		
		If CAR->PREPED != _cPreped
			_nTotCaixPP := 0
			_nTotPesoPP := 0

			If !Empty(mv_par05)
				cQuery2 := " SELECT COUNT(Z2_NUMAM) AS NUMAM"
				cQuery2 += " FROM " + RetSqlTab("ZZ4") + ", " + RetSqlTab("SZ8") + ", " + RetSqlTab("SZ2")
				cQuery2 += " WHERE " + RetSQLFil ("ZZ4") + " AND " + RetSQLFil("SZ8")+ " AND " + RetSQLFil("SZ2")
				cQuery2 += " AND ZZ4_NUM = Z8_PREPED AND Z8_PREDES = Z2_NUM "
				cQuery2 += " AND Z8_FIL = '" + cFilant + "'  AND  Z2_NUMAM = '" + mv_par05 + "'"
				If !Empty(mv_par06)
					cQuery2 += " AND Z2_CLASSIF = '" + mv_par06 + "'"
				Endif
				cQuery2 += "AND" + RetSQLDel("ZZ4") + " AND " + RetSQLDel("SZ8") + " AND " + RetSQLDel("SZ2")

				cQuery2 := ChangeQuery(cQuery2)

				If Select("CAR2") != 0
					CAR2->(dbCloseArea())
				Endif

				TCQUERY cQuery2 NEW ALIAS "CAR2"

				If CAR2->NUMAM = 0
					CAR->(DbSkip())
					Loop
				Endif
			Endif

			nlin++
			@nlin,010 psay CAR->PREPED

			_cCliente := Posicione('ZZ4',2,xfilial('ZZ4')+alltrim(CAR->PREPED),'ZZ4_CODCLI')
			_cLoja    := Posicione('ZZ4',2,xfilial('ZZ4')+alltrim(CAR->PREPED),'ZZ4_LOJA')
			_cDoc     := Posicione('SD2',8,xfilial('SD2')+alltrim(CAR->NUMPED),'D2_DOC')
			_cSerie   := Posicione('SD2',8,xfilial('SD2')+alltrim(CAR->NUMPED),'D2_SERIE')

			@nlin,020 psay _cCliente + "/" + _cLoja
			@nlin,030 psay Posicione('SA1',1,xfilial('SA1')+_cCliente + _cLoja,'A1_NOME')
			@nlin,070 psay alltrim(CAR->ZZ4_MUN) + '   Marca: ' +alltrim(CAR->ZZ4_MARCA)
			nlin++

			@nlin,00 psay replicate('-',132)
			nlin++
			_cPreped := CAR->PREPED
		Endif

		_cPreItem := alltrim(CAR->PREPED)+alltrim(CAR->ITEM)
		_c2UM     := Posicione('SB1',1,xfilial('SB1')+alltrim(CAR->ITEM),'B1_SEGUM')
		_cGrupo   := Posicione('SB1',1,xfilial('SB1')+alltrim(CAR->ITEM),'B1_GRUPO')
		_cDescri  := alltrim(Posicione('SB1',1,xfilial('SB1')+alltrim(CAR->ITEM),'B1_DESC')) + '   ('+_c2UM + ')'

		If Posicione('ZZ5',1,xfilial('ZZ5')+alltrim(CAR->(PREPED+NUM_ITEM)),'ZZ5_QRCAIX') != 0
			@nlin,020 psay CAR->ITEM
			@nlin,030 psay substr(_cDescri,1,38)
			If mv_par07 = 1 .And. _c2UM <> 'PC'
				@nlin,075 psay 'Caixas/Peças: ' + transform(CAR->QRCAIX,'@E 9,999')
				@nlin,103 psay 'Peso Líquido: ' + transform(CAR->QRPESO,'@E 999,999.99')
				nlin++
				@nlin,015 psay 'Cod. Caixa'
				@nlin,032 psay 'Quant.'
				@nlin,041 psay 'Peso B.'
				@nlin,055 psay 'Tara'
				@nlin,067 psay 'Peso L.'
				If mv_par09 = 1
					@nlin,080 psay 'Dt. Abate'  //'Dt. Prod.'	//modificação feita por solicitação da IF e alterada por Mauricio Roehrs
				Endif
				@nlin,095 psay 'Dt. Emb.'  //'Dt. Valid.' //em caso de mudança apenas apague o que não esta comentado e descomente
				@nlin,108 psay 'Dt. Valid.' //'Dt. Abate'  //os mesmos.
				@nlin,121 psay 'Classif.'
			Endif

			If _c2UM  = 'CX' .and. ((_cGrupo < '6000' .or. _cGrupo > '6999') .and. (_cGrupo < '8000' .or. _cGrupo > '8999'))
				nlin++
				SZ8->(dbsetorder(26))
				If SZ8->(dbseek(xfilial('SZ8') +xfilial('SB1') + _cPreItem,.t.))

					_nTotCaixItem := 0
					_nTotPesoItem := 0
					_aParc := {}
					_aDtEmb := {}
					While SZ8->(!Eof()) .and. SZ8->Z8_FIL = xfilial('SB1') .and. SZ8->(Z8_PREPED + Z8_COD) = _cPreItem
						_cNumAbt     := ''
						_dDtAbate    := ''
						//_dDtDesos	 := ''
						_cClassific  := ''

						_cNumAbt := Posicione('SZ2',2,xfilial('SZ2')+SZ8->Z8_PREDES,'Z2_NUMAM')

						If !Empty(mv_par05)
							If _cNumAbt <> mv_par05
								SZ8->(DbSkip())
								Loop
							Endif
						Endif

						//_dDtDesos	:= Posicione('SZ2',2,'00'+SZ8->Z8_PREDES,'Z2_DTPROD')
						_dDtAbate   := Posicione('SZ2', 2, iif(!Empty(xFilial('SZ8')), xFilial('SZ8'), '00')+SZ8->Z8_PREDES, 'Z2_DATAABT')
						_cClassific := Posicione('SZ2', 2, iif(!Empty(xFilial('SZ8')), xFilial('SZ8'), '00')+SZ8->Z8_PREDES, 'Z2_CLASSIF')
						_cClassEsp	:= Posicione('SZ2', 2, iif(!Empty(xFilial('SZ8')), xFilial('SZ8'), '00')+SZ8->Z8_PREDES, 'Z2_CLASESP')//prioridade por Classificação Especial

						If !Empty(mv_par06)
							If _cClassific <> mv_par06
								SZ8->(DbSkip())
								Loop
							Endif
						Endif

						If nLin > 75 // Salto de Página. Neste caso o formulario tem 55 linhas...
							Cabec(Titulo,Cabec1,Cabec2,NomeProg,Tamanho,nTipo)
							nLin := 9
						Endif

						_nPos := aScan(_aParc,{|aVal|aVal[1] = _dDtAbate})

						If _nPos <> 0
							_aParc[_nPos,2] += 1
							_aParc[_nPos,3] += SZ8->Z8_PESO
							_aParc[_nPos,4] := SZ8->Z8_PREDES
							_nCont := 0
							For j:=1 To Len(_aParc[_nPos,5])
								if _aParc[_nPos,5,j] = SZ8->Z8_DATAP
									_nCont++
								endif
							Next
							if _nCont = 0
								aadd(_aParc[_nPos,5],SZ8->Z8_DATAP)
							endif
						Else
							aadd(_aParc,{_dDtAbate,1,SZ8->Z8_PESO,SZ8->Z8_PREDES,{SZ8->Z8_DATAP}})
						Endif

						If mv_par07 = 1
							@nlin,015 psay SZ8->Z8_CONTROL
							@nlin,032 psay transform(SZ8->Z8_QUANT,'@E 999')
							@nlin,041 psay transform(SZ8->Z8_PESOBR,'@E 999.99')
							@nlin,055 psay transform(SZ8->Z8_TARA,'@E 99.999')
							@nlin,067 psay transform(SZ8->Z8_PESO,'@E 999.99')
							If mv_par09 = 1
								@nlin,080 psay iif(empty(_dDtAbate) .and. substr(SZ8->Z8_PREDES,1,3) = 'SIF', alltrim(SZ8->Z8_PREDES),_dDtAbate)
							Endif
							@nlin,095 psay SZ8->Z8_DATAP
							// @nlin,116 psay 'Abate: ' + 	_cNumPrevDes
							@nlin,110 psay SZ8->Z8_DATAVAL
							@nlin,122 psay iif(!empty(_cClassific) .and. _cClassEsp = 'S',_cClassific + '->UY',_cClassific)
							nlin++
						Endif

						_nQtPeca += SZ8->Z8_QUANT
						_nTotCaix++
						_nTotPesoL += SZ8->Z8_PESO
						_nTotPesoB += SZ8->Z8_PESOBR

						_nTotCaixItem++
						_nTotPesoItem += SZ8->Z8_PESO

						SZ8->(dbskip())
					Enddo

					If mv_par09 = 1

						For i:=1 To Len(_aParc)
							If nLin > 75 // Salto de Página. Neste caso o formulario tem 55 linhas...
								Cabec(Titulo,Cabec1,Cabec2,NomeProg,Tamanho,nTipo)
								nLin := 9
							Endif

							nlin++
							If mv_par07 = 1
								@nlin,15 psay 'Total de Caixas no dia: ' + dtoc(_aParc[i,1]) + ' - ' + transform(_aParc[i,2],'@E 999,999') + ' - Peso Liq.: ' + transform(_aParc[i,3],'@E 999,999.99')
							Else
								//@nlin,15 psay 'Data do Abate: ' + dtoc(_aParc[i,1]) + ' - ' + 'Data da Desossa: ' + ' - ' + 'Quant CX: ' + transform(_aParc[i,2],'@E 999,999')
								@nlin,15 psay 'Total de Caixas do Abate dia: ' + dtoc(_aParc[i,1]) + ' - ' + transform(_aParc[i,2],'@E 999,999') + ' - Peso Liq.: ' + transform(_aParc[i,3],'@E 999,999.99')
								nlin++

								//buscaDtDso(_aParc[i,1],alltrim(CAR->PREPED),alltrim(CAR->ITEM))
								//TMP->(dbGoTop())
								@nlin,15 psay 'Data(s) de Embalagem: '
								nlin++
								if !empty(_aParc[i,5]) .or. Len(_aParc[i,5]) > 0
									For j:=1 To Len(_aParc[i,5])
										@nlin,15 psay dtoc(_aParc[i,5,j])
										nlin++
									Next
								endif
								/*while TMP->(!eof())
									@nlin,15 psay stod(TMP->Z8_DATAP)
									nlin++
									TMP->(dbSkip())
								Enddo*/
							Endif
						Next

					Endif

					nlin++
					@nlin,15 psay 'Total de pecas: ' + transform(_nQtPeca,'@E 999,999')
					nlin++
					@nlin,01 psay replicate('-',132)
					nlin++
					_nQtPeca := 0
				Endif

			ElseIf _c2UM = 'CX' .and. ((_cGrupo >= '6000' .and. _cGrupo <= '6999') .or. (_cGrupo >= '8000' .and. _cGrupo <= '8999'))
				nlin++
				SZ8->(dbsetorder(26))
				If	SZ8->(dbseek(xfilial('SZ8') + xfilial('SB1') + _cPreItem,.t.))

					_nTotCaixItem := 0
					_nTotPesoItem := 0

					While  SZ8->(!eof()) .and. SZ8->(Z8_PREPED + Z8_COD) = _cPreItem  .and. SZ8->Z8_FIL = xfilial('SB1') .and. SZ8->Z8_TERC = 'S'
						If nLin > 75 // Salto de Página. Neste caso o formulario tem 55 linhas...
							Cabec(Titulo,Cabec1,Cabec2,NomeProg,Tamanho,nTipo)
							nLin := 9
						Endif

						If mv_par07 = 1
							@nlin,15 psay SZ8->Z8_CONTROL
							@nlin,41 psay transform(SZ8->Z8_PESO,'@E 999.99')
							@nlin,67 psay transform(SZ8->Z8_PESO,'@E 999.99')
							@nlin,87 psay "Produto 3°"
							nlin++
						Endif

						_nTotCaix++
						_nTotPesoL += SZ8->Z8_PESO
						_nTotPesoB += SZ8->Z8_PESO

						_nTotCaixItem++
						_nTotPesoItem += SZ8->Z8_PESO

						SZ8->(dbskip())

					Enddo
				Endif

			Elseif _c2UM = 'PC'

				nlin++
				ZZ2->(dbsetorder(4))
				ZZ2->(dbgotop())
				if ZZ2->(dbseek(xfilial('ZZ2') + CAR->CARGA + CAR->PREPED + CAR->NUM_ITEM))
					_nTotCaixItem := 0
					_nTotPesoItem := 0
					_cod := ''
					_cTpOper := Posicione('ZZ4',2,xFilial('ZZ4') + ZZ2->ZZ2_PREPED,'ZZ4_TPOPER')

					If _cTpOper == 'C'
						_nTotQntCmp  := 0 //quantidade total comprada
						_nTotPesLCmp := 0 //peso liquido total comprado
						_nTotPesBCmp := 0 //peso bruto total comprado
						_nTotTaraCmp := 0 //tara total comprada

						If mv_par07 == 1//se for analitico e tipo de operação for compra

							@nlin,15 psay 'Cod. Prod           Descricao             Quantidade        Peso Bruto         Tara         Peso Liquido'
							nlin++
						Endif
					Endif

					While ZZ2->(!Eof()) .and. alltrim(ZZ2->(ZZ2_PRECAR + ZZ2_PREPED + ZZ2_ITEM)) == alltrim(CAR->(CARGA+PREPED+NUM_ITEM)) .and. ZZ2->ZZ2_FILIAL = xfilial('ZZ2')
						//while ZZ2->(!eof()) .and. ZZ2->(ZZ2_PREPED+ZZ2_COD) = _cPreItem .and. ZZ2->ZZ2_FILIAL = xfilial('ZZ2')
						If nLin > 65 // Salto de Página. Neste caso o formulario tem 55 linhas...
							Cabec(Titulo,Cabec1,Cabec2,NomeProg,Tamanho,nTipo)
							nLin := 9
						Endif

						If _cTpOper == 'C

							If _cod <> ZZ2->ZZ2_COD
								_cod := ZZ2->ZZ2_COD
							Endif

							If mv_par07 == 1 //se for analitico e tipo de operação for compra
								@nlin,15 psay ZZ2->ZZ2_COD
								@nlin,33 psay ZZ2->ZZ2_DESCRI
								@nlin,60 psay transform(ZZ2->ZZ2_QUANT,'@E 999')
								@nlin,76 psay transform(ZZ2->ZZ2_PESOB,'@E 999.99')
								@nlin,93 psay transform(ZZ2->ZZ2_TARA,'@E 99.99')
								@nlin,110 psay transform(ZZ2->ZZ2_PESOL,'@E 999.99')
								nlin++
							Endif

							_nTotQntCmp  += ZZ2->ZZ2_QUANT //quantidade total comprada
							_nTotPesLCmp += ZZ2->ZZ2_PESOL //peso liquido total comprado
							_nTotPesBCmp += ZZ2->ZZ2_PESOB //peso bruto total comprado
							_nTotTaraCmp += ZZ2->ZZ2_TARA //tara total comprada
						Endif
						
						_nTotPeca += ZZ2->ZZ2_QUANT
						//_nTotCaix  += ZZ2->ZZ2_QUANT
						_nTotPesoL += ZZ2->ZZ2_PESOL
						_nTotPesoB += ZZ2->ZZ2_PESOL

						_nTotCaixItem++
						_nTotPesoItem += ZZ2->ZZ2_PESOL

						ZZ2->(dbskip())
						If _cTpOper == 'C'
							If _cod <> ZZ2->ZZ2_COD .or. ZZ2->(eof())

								@nlin,15 psay space(42) + 'Quantidade        Peso Bruto         Tara         Peso Liquido'
								nlin++

								@nlin,020 psay 'TOTAL:'
								@nlin,060 psay transform(_nTotQntCmp,'@E 999,999')
								@nlin,076 psay transform(_nTotPesBCmp,'@E 9,999,999.99')
								@nlin,093 psay transform(_nTotTaraCmp,'@E 9,999.99')
								@nlin,110 psay transform(_nTotPesLCmp,'@E 9,999,999.99')
								nlin++

								@nlin,01 psay replicate('-',132)
								nlin++

								_nTotQntCmp  := 0 //quantidade total comprada
								_nTotPesLCmp := 0 //peso liquido total comprado
								_nTotPesBCmp := 0 //peso bruto total comprado
								_nTotTaraCmp := 0 //tara total comprada
							Endif
						Endif
					Enddo
				Endif

				ZZ2->(dbsetorder(4))
				ZZ2->(dbgotop())
				ZZ2->(dbseek(xfilial('ZZ2') + CAR->CARGA + CAR->PREPED + CAR->NUM_ITEM))//para reposicionar na tabela

				ZAJ->(dbSetOrder(3))
				ZAJ->(dbGoTop())
				If ZAJ->(dbSeek(xFilial('ZAJ') + ZZ2->(ZZ2_PRECAR + ZZ2_PREPED + ZZ2_ITEM)))

					_aParc := {}
					If mv_par07 = 1
						@nlin,15 psay 'Cod. Pc          Sequencial      Dt.Abate       Dt.Carreg.      Dt.Valid.     Classif.    Peso Unit.'
						nlin++
					Endif

					While ZAJ->(!eof()) .and. ZAJ->ZAJ_FILIAL = xFilial('ZAJ') .and. ZAJ->(ZAJ_PRECAR + ZAJ_PREPED + ZAJ_ITEM) == ZZ2->(ZZ2_PRECAR+ZZ2_PREPED+ZZ2_ITEM)
						If nLin > 65 // Salto de Página. Neste caso o formulario tem 55 linhas...
							Cabec(Titulo,Cabec1,Cabec2,NomeProg,Tamanho,nTipo)
							nLin := 9
						Endif

						dbSelectArea('SB1')
						_nDiasVal := Posicione('SB1',1,xFilial('SB1') + ZZ2->ZZ2_COD,'B1_VALID')
						_dDtAbte  := Posicione('SZG',1,xFilial('SZG') + ZAJ->ZAJ_NUMAM,'ZG_DATA')
						_dDtValid := _dDtAbte + _nDiasVal
						_cClassif := Posicione('SZK',5,xFilial('SZK') + ZAJ->(ZAJ_NUMAM + ZAJ_LOTE + ZAJ_CONTRO),'ZK_CLASSIF')
						_cClasesp := Posicione('SZK',5,xFilial('SZK') + ZAJ->(ZAJ_NUMAM + ZAJ_LOTE + ZAJ_CONTRO),'ZK_CLASESP')

						_nPos := aScan(_aParc,{|aVal|aVal[1] = _dDtAbte})

						If _nPos <> 0
							_aParc[_nPos,2]+=1
						Else
							aadd(_aParc,{_dDtAbte,1})
						Endif

						If mv_par07 == 1//se for analitico
							@nlin,15 psay ZAJ->ZAJ_NUM
							@nlin,33 psay ZAJ->ZAJ_CONTRO
							@nlin,48 psay _dDtAbte
							@nlin,64 psay ZAJ->ZAJ_DATAS
							@nlin,79 psay _dDtValid
							//@nlin,96 psay _cClassif
							@nlin,96 psay iif(!empty(_cClassif) .and. _cClasesp = '1',_cClassif + '->UY',_cClassif)
							/* Solicitado pela ariane que volte o peso dia 02/02/21*/
							@nlin,106 psay transform(ZAJ->ZAJ_PESO,'@E 999.99')
							nlin++
						Endif

						_nQtPC += 1

						ZAJ->(dbSkip())

					Enddo
				Endif

				If mv_par09 = 1
					For i:=1 to len(_aParc)
						If nLin > 75 // Salto de Página. Neste caso o formulario tem 55 linhas...
							Cabec(Titulo,Cabec1,Cabec2,NomeProg,Tamanho,nTipo)
							nLin := 9
						Endif
						nlin++
						@nlin,15 psay 'Total de Caixas no dia: ' + dtoc(_aParc[i,1]) + ' - ' + transform(_aParc[i,2],'@E 999,999')
					Next
				Endif
			Endif

			If _nQtPC > 0
				nlin++
				@nlin,15 psay 'Total de PC: ' + transform(_nQtPC,'@E 999,999')
				nlin++
				@nlin,01 psay replicate('-',132)
				nlin++
			Endif
			
			_nQtPC := 0

			If mv_par07 = 2
				@nlin,80 psay transform(_nTotCaixItem,'@E 999,999')
				@nlin,95 psay transform(_nTotPesoItem,'@E 999,999.99')
			Endif
		Endif
		nlin++

		CAR->(dbSkip()) // Avanca o ponteiro do registro no arquivo

		If CAR->(Eof()) .or.  CAR->CARGA <> _cPrecar2
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
		Endif

	Enddo

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


//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Chamada da função BuscaDtDso                                        ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
Static Function BuscaDtDso(_dtabate,_cPreped,_cProd)

	cQuery3 := " SELECT Z8_DATAP, Z2_DATAABT "
	cQuery3 += " FROM " + RetSqlTab("SZ2") + ", " + retSqlTab('SZ8')
	cQuery3 += " WHERE " + RetSQLFil('SZ2') + " AND " + retSqlFil('SZ8')
	cQuery3 += " AND Z2_NUM = Z8_PREDES AND Z8_PREPED = '"+_cPreped+"' AND Z8_COD = '"+_cProd+"'"
	cQuery3 += " AND Z2_DATAABT = '" + dtos(_dtabate) + "' AND Z8_FIL = '"+cFilAnt+"'"
	cQuery3 += " AND " + RetSQLDel('SZ2') + " AND " + retSqlDel('SZ8')
	cQuery3 += " GROUP BY Z8_DATAP,Z2_DATAABT"

	cQuery3 := ChangeQuery(cQuery3)

	If Select("TMP") != 0
		TMP->(dbCloseArea())
	Endif
	TCQUERY cQuery3 NEW ALIAS "TMP"

Return
