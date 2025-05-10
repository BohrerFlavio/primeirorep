#INCLUDE "rwmake.ch"
#INCLUDE "totvs.ch"
#INCLUDE "topconn.ch"

User Function SF2460I()

	/*/
	ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
	±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
	±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
	±±³Programa  ³ SF2460I  ³ Autor ³ Evandro Mugnol        ³ Data ³ 28.07.04 ³±±
	±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
	±±³Descricao ³ Ponto Entrada para atualizar dados nos titulos a receber   ³±±
	±±³          ³ apos a geracao do documento de saida                       ³±±
	±±³          ³Incrementado por Giuliano Forgiarini em 10.06.11 para       ³±±
	±±³          ³controle mais aprimorado do financeiro no controle de       ³±±
	±±³          ³ utilizando o campo A1_RISCO para tratar os bloqueios       ³±±
	±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
	±±³Uso       ³ Especifico para Frigorifico Silva                          ³±±
	±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
	±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
	ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
	/*/
	Local x
	Local nI

	_aArea    := GetArea()
	_aAreaSF2 := SF2->(GetArea())
	_aAreaSE1 := SE1->(GetArea())
	_aAreaSA1 := SA1->(GetArea())
	_xDOC     := SF2->F2_DOC
	_xSERIE   := SF2->F2_PREFIXO
	_xCLIENTE := SF2->F2_CLIENTE
	_xLOJA    := SF2->F2_LOJA
	_dEmissao := SF2->F2_EMISSAO
	_cCondPgt := SF2->F2_COND

	SA1->(DbSetOrder(1))
	SA1->(MsSeek(FWxfilial('SA1')+_xCLIENTE+_xLOJA))

	_xFORMREC := SA1->A1_FORMREC

	// Implementado em 07/08/2017 cfe solicitação do Clailton para calcular vencimentos fixos solicitados por algumas redes de mercados/clientes
	// conforme parametrizado os 6 campos abaixo no cadastro de clientes
	_cRECVCTO := SA1->A1_RECVCTO		// Recalcula Vencimento do Título no Financeiro
	_nDIASCAL := SA1->A1_DIASCAL		// Dias p/ Calculo do vencimento a ser considerado
	_nDIAINI  := SA1->A1_DIAINI      	// Dia Inicial para testar na data de emissão calculada
	_nDIAFIN  := SA1->A1_DIAFIN			// Dia Final para testar na data de emissão calculada
	_nDIAVCT1 := SA1->A1_DIAVCT1		// Dia Vencto Fixo 1 Mes Subsequente a ser considerado
	_nDIAVCT2 := SA1->A1_DIAVCT2		// Dia Vencto Fixo 2 Mes Subsequente a ser considerado
	If SF2->F2_CLIENTE == "000173" .Or. SF2->F2_CLIENTE == "000174" .Or. SF2->F2_CLIENTE == "001110" .Or. SF2->F2_CLIENTE == "010343" .Or. SF2->F2_CLIENTE == "020031"
		_nPRapel  := SA1->A1_PRAPEL + SA1->A1_PLOGIST
	Else
		_nPRapel  := SA1->A1_PRAPEL
	EndIf

	_cUltProd := ""
	_aVolume  := {}
	xPESO_L   := 0
	xPESO_B   := 0
	_nTS      := ''

	// Início bloco tratamento para apuração dos campos de quantidade, espécie, peso liquido e bruto para impressão na Danfe e geração do CTE
	If Empty(SC5->C5_VOLUME1) .And. Empty(SC5->C5_ESPECI1)
		DbSelectArea("SD2")
		DbOrderNickName("_D2CF")
		MsSeek(FWxFilial("SD2") + SF2->F2_DOC + SF2->F2_SERIE)
		Do While !Eof() .And. SD2->D2_FILIAL + SD2->D2_DOC + SD2->D2_SERIE == FWxFilial("SD2") + SF2->F2_DOC + SF2->F2_SERIE
			xTARAS := 0

			//Calcula a tara exata com base na media do pré-pedido de venda
			_lClc := _GetParam()

			if _lClc
				ZZ4->(DbSetOrder(6))
				If ZZ4->(MsSeek(FWxFilial('ZZ4')+SD2->D2_PEDIDO)) .and. _cUltProd <> SD2->D2_COD
					ZZ5->(DbSetOrder(1))
					If ZZ5->(MsSeek(FWxFilial('ZZ5')+ZZ4->ZZ4_NUM))
						While ZZ5->(!Eof()) .And. ZZ5->ZZ5_FILIAL + ZZ5->ZZ5_NUM = FWxfilial('ZZ5') + ZZ4->ZZ4_NUM
							If alltrim(ZZ5->ZZ5_COD) <> alltrim(SD2->D2_COD)
								ZZ5->(DbSkip())
								Loop
							Else
								DbSelectArea('SB1')
								_cUn := GetAdvFVal('SB1','B1_SEGUM',FWxfilial('SB1')+ZZ5->ZZ5_COD,1)
								If _cUn != 'PC'
									XTARAS += (ZZ5->ZZ5_QRPESB - ZZ5->ZZ5_QRPESO)
								Endif
							Endif
							ZZ5->(DbSkip())
						Enddo
					Endif
				Endif
			endif
	
			//Fim do calculo da tara com base na média do pré-pedido de venda
			if  cEmpAnt = '01'
				If SD2->D2_UM $ "KG/UN/M3/MC"
					xPESO_L := xPESO_L + SD2->D2_QUANT                       // Apuracao do Peso Liquido
					If xTARAS = 0
						//xTARAS  := Posicione("SB1",1,FWxFilial("SB1")+SD2->D2_COD,"B1_TARAS")
						_nTS := GetAdvFVal('SB1','B1_CTARASE',FWxfilial('SB1')+ SB1->B1_COD,1)  //Linhas acescentadas para
						xTARAS := GetAdvFVal('ZAB','ZAB_TARA',FWxfilial('ZAB')+alltrim(_nTS),1)   //buscar o codigo das taras
					Endif

					if xTARAS = 0
						xTARAS := xPESO_L * 0.96
					endif

					If _cUltProd <> SD2->D2_COD
						xPESO_B := xPESO_B + (SD2->D2_QUANT + XTARAS)         // Apuracao do Peso Bruto
					Else
						xPESO_B := xPESO_B + SD2->D2_QUANT
					Endif

					// Apura Volumes e Especies dos Produtos
					_nPos := aScan(_aVolume,{ |x| AllTrim(X[1]) = SD2->D2_SEGUM})
					If _nPos = 0
						AADD(_aVolume,{SD2->D2_SEGUM,0})
						_nPos := Len(_aVolume)
					EndIf
					_aVolume[_nPos,2] += SD2->D2_QTSEGUM
				Else
					xPESO_L := xPESO_L + SD2->D2_QTSEGUM                    // Apuracao do Peso Liquido
					//xTARAS  := Posicione("SB1",1,FWxFilial("SB1")+SD2->D2_COD,"B1_TARAS")
					_nTS := GetAdvFVal('SB1','B1_CTARASE',FWxfilial('SB1')+ SB1->B1_COD,1) //Linhas acescentadas para
					xTARAS := GetAdvFVal('ZAB','ZAB_TARA',FWxfilial('ZAB')+alltrim(_nTS),1) //buscar o codigo das taras
					xPESO_B := xPESO_B + (SD2->D2_QTSEGUM + XTARAS)         // Apuracao do Peso Bruto

					// Apura Volumes e Especies dos Produtos
					_nPos := aScan(_aVolume,{ |x| AllTrim(X[1]) = SD2->D2_UM})
					If _nPos = 0
						AADD(_aVolume,{SD2->D2_UM,0})
						_nPos := len(_aVolume)
					EndIf
					_aVolume[_nPos,2] += SD2->D2_QUANT
				EndIf
			Else
				xPESO_L := 0
				xPESO_B := 0
			endif

			_cUltProd := SD2->D2_COD

			DbSelectArea("SD2")
			DbSkip()
		Enddo

		For x:=1 to Len(_aVolume)
			DbSelectArea("SF2")
			RecLock("SF2",.F.)
			DO CASE
				CASE x == 1
					SF2->F2_ESPECI1 := AllTrim(Posicione("SAH",1,FWxFilial("SAH")+_aVolume[x,1],"AH_UMRES"))
					SF2->F2_VOLUME1 := NoRound(_aVolume[x,2],0)
				CASE x == 2
					SF2->F2_ESPECI2 := AllTrim(Posicione("SAH",1,FWxFilial("SAH")+_aVolume[x,1],"AH_UMRES"))
					SF2->F2_VOLUME2 := NoRound(_aVolume[x,2],0)
				CASE x == 3
					SF2->F2_ESPECI3 := AllTrim(Posicione("SAH",1,FWxFilial("SAH")+_aVolume[x,1],"AH_UMRES"))
					SF2->F2_VOLUME3 := NoRound(_aVolume[x,2],0)
				CASE x == 4
					SF2->F2_ESPECI4 := AllTrim(Posicione("SAH",1,FWxFilial("SAH")+_aVolume[x,1],"AH_UMRES"))
					SF2->F2_VOLUME4 := NoRound(_aVolume[x,2],0)
			ENDCASE
			MsUnLock()
		Next

		Dbselectarea("SF2")
		IF SC5->C5_PESOL == 0 .And. SC5->C5_PBRUTO == 0
			RecLock("SF2",.F.)
			SF2->F2_PLIQUI := xPESO_L
			SF2->F2_PBRUTO := iif(xPESO_B <> 0,xPESO_B,xPESO_L)
			MsUnlock()
		ENDIF
	Endif
	// Final bloco tratamento para apuração dos campos de quantidade, espécie, peso liquido e bruto - para impressão na Danfe e geração do CTE

	// TRANSFERIDO DO FONTE NFESEFAZ.PRW EM 13/11/2024
	// ------------- Inicio bloco feito para calcular o peso liquido de tubete sobre UNIDADE DE MEDIDA = UN - SILVA
	If cEmpAnt == "01"
		_nSomaQuant   := 0
		_nPesoBruto   := 0
		_nTara		  := 0
		_lExist010825 := .f.

		If cEmpAnt == '01'
			SD2->(DbSetOrder(3))
			If SD2->(MsSeek(FWxfilial('SD2')+SF2->(F2_DOC+F2_SERIE+F2_CLIENTE+F2_LOJA)))
				While SD2->(!Eof()) .And. SD2->D2_FILIAL = FWxfilial('SD2') .And. SF2->(F2_DOC+F2_SERIE+F2_CLIENTE+F2_LOJA) = SD2->(D2_DOC+D2_SERIE+D2_CLIENTE+D2_LOJA)
					_nTaraS   := GetAdvFVal('SB1','B1_CTARASE',FWxfilial('SB1')+SD2->D2_COD,1)     //Linhas inseridas para buscar
					_nTS      := GetAdvFVal('ZAB','ZAB_TARA',FWxfilial('ZAB')+alltrim(_nTaraS),1)  // os campos de codigo das taras secundaria
					_nTaraP   := GetAdvFVal('SB1','B1_CTARAP',FWxfilial('SB1')+SD2->D2_COD,1)      // Linhas inseridas para buscar"_NTARAp"
					_nTP      := GetAdvFVal('ZAB','ZAB_TARA',FWxfilial('ZAB')+alltrim(_nTaraP),1)  // os campos de codigo das taras primarias
					_nQCaix   := GetAdvFVal('SB1','B1_QCAIX',FWxfilial('SB1')+SD2->D2_COD,1)
					_cBdj300g := _GetPar1()
					_cBdj320g := _GetPar2()
					_cBdj360g := _GetPar3()
					_cBdj400g := _GetPar4()
					_cBdj450g := _GetPar5()
					_cBdj480g := _GetPar6()
					_cBdj500g := _GetPar7()
					_cBdj502g := _GetPar8()
					_cBdj503g := _GetPar9()
					_cBdj600g := _GetPar10()
					_cBdj720g := _GetPar11()
					_cBdj800g := _GetPar12()
					_2cBdj800g:= _GetPar13()
					_cBdj900g := _GetPar14()

					//bandeja 300g
					If alltrim(SD2->D2_COD) $ _cBdj300g
						_nSomaQuant += (SD2->D2_QUANT * 0.3)
						_lExist010825 := .t.
						_nTara  += (SD2->D2_QTSEGUM * _nTS)	+ (SD2->D2_QUANT * _nTP)
					//bandeja 320g
					ElseIf alltrim(SD2->D2_COD) $ _cBdj320g
						_nSomaQuant += (SD2->D2_QUANT * 0.32)
						_lExist010825 := .t.
						_nTara  += (SD2->D2_QTSEGUM * _nTS)	+ (SD2->D2_QUANT * _nTP)
					//bandeja 360g
					ElseIf alltrim(SD2->D2_COD) $ _cBdj360g
						_nSomaQuant += (SD2->D2_QUANT * 0.36)
						_lExist010825 := .t.
						_nTara  += (SD2->D2_QTSEGUM * _nTS)	+ (SD2->D2_QUANT * _nTP)
					//bandeja 400g
					ElseIf alltrim(SD2->D2_COD) $ _cBdj400g
						_nSomaQuant += (SD2->D2_QUANT * 0.4)
						_lExist010825 := .t.
						_nTara  += (SD2->D2_QTSEGUM * _nTS)	+ (SD2->D2_QUANT * _nTP)
					//bandeja 450g
					ElseIf alltrim(SD2->D2_COD) $ _cBdj450g
						_nSomaQuant += (SD2->D2_QUANT * 0.45)
						_lExist010825 := .t.
						_nTara  += (SD2->D2_QTSEGUM * _nTS)	+ (SD2->D2_QUANT * _nTP)
					//bandeja 480g
					ElseIf alltrim(SD2->D2_COD) $ _cBdj480g
						_nSomaQuant += (SD2->D2_QUANT * 0.48)
						_lExist010825 := .t.
						_nTara  += (SD2->D2_QTSEGUM * _nTS)	+ (SD2->D2_QUANT * _nTP)
					//bandeja 500g
					ElseIf alltrim(SD2->D2_COD) $ _cBdj500g .or. alltrim(SD2->D2_COD) $ _cBDJ502g .or. alltrim(SD2->D2_COD) $ _cBdj503g
						_nSomaQuant += (SD2->D2_QUANT * 0.5)
						_lExist010825 := .t.
						_nTara  += (SD2->D2_QTSEGUM * _nTS)	+ (SD2->D2_QUANT * _nTP)
					//bandeja 600g
					ElseIf alltrim(SD2->D2_COD) $ _cBdj600g
						_nSomaQuant += (SD2->D2_QUANT * 0.6)
						_lExist010825 := .t.
						_nTara  += (SD2->D2_QTSEGUM * _nTS)	+ (SD2->D2_QUANT * _nTP)
					//bandeja 720g
					ElseIf alltrim(SD2->D2_COD) $ _cBdj720g
						_nSomaQuant += (SD2->D2_QUANT * 0.72)
						_lExist010825 := .t.
						_nTara  += (SD2->D2_QTSEGUM * _nTS)	+ (SD2->D2_QUANT * _nTP)
					//bandeja 800g
					ElseIf alltrim(SD2->D2_COD) $ _cBdj800g	.or. alltrim(SD2->D2_COD) $ _2cBdj800g
						_nSomaQuant += (SD2->D2_QUANT * 0.8)
						_lExist010825 := .t.
						_nTara  += (SD2->D2_QTSEGUM * _nTS)	+ (SD2->D2_QUANT * _nTP)
					//bandeja 900g
					ElseIf alltrim(SD2->D2_COD) $ _cBdj900g
						_nSomaQuant += (SD2->D2_QUANT * 0.9)
						_lExist010825 := .t.
						_nTara  += (SD2->D2_QTSEGUM * _nTS)	+ (SD2->D2_QUANT * _nTP)
					Else
						_nTara += (SD2->D2_QTSEGUM * _nTS) + (( _nQCaix *SD2->D2_QTSEGUM)* _nTP )
						_nSomaQuant += SD2->D2_QUANT
					Endif

					SD2->(DbSkip())
				EndDo

				//Reposiciona a SD2
				SD2->(DbGoTop())
				SD2->(MsSeek(FWxfilial('SD2')+SF2->(F2_DOC+F2_SERIE+F2_CLIENTE+F2_LOJA)))
			EndIf
		EndIf

		If _lExist010825
			_nPesoBruto := _nSomaQuant + _nTara

			RecLock("SF2",.F.)
			SF2->F2_PLIQUI := _nSomaQuant
			SF2->F2_PBRUTO := _nPesoBruto
			MsUnlock()
		Endif

	EndIf
	// ------------- Fim bloco feito para calcular o peso liquido de tubete sobre UNIDADE DE MEDIDA = UN - SILVA

	If cEmpAnt == "01"
		//If SF2->F2_CLIENTE == "000173" .Or. SF2->F2_CLIENTE == "000174" .Or. SF2->F2_CLIENTE == "001110" .Or. SF2->F2_CLIENTE == "010343" .Or. SF2->F2_CLIENTE == "020031"
		// Soma total de todas verbas dos itens da nota fiscal para ser rateado
		// nas parcelas do financeiro
		_nVTVerbas := 0
		DbSelectArea("SD2")
		DbOrderNickName("_D2CF")
		MsSeek(FWxFilial("SD2") + SF2->F2_DOC + SF2->F2_SERIE)
		Do While !Eof() .And. SD2->D2_FILIAL + SD2->D2_DOC + SD2->D2_SERIE == FWxFilial("SD2") + SF2->F2_DOC + SF2->F2_SERIE
			// Clailton pediu para retirar em 29/07/2024 Verba Extra e Verba Logística, pois não deve ser usado para o rapel no financeiro
			//_nVTVerbas := _nVTVerbas + (SD2->D2_VLRAPEL + SD2->D2_VLIQF + SD2->D2_VLLOGIS + SD2->D2_VLVBEXT + SD2->D2_VLMCPRO)
			If SF2->F2_CLIENTE == "000173" .Or. SF2->F2_CLIENTE == "000174" .Or. SF2->F2_CLIENTE == "001110" .Or. SF2->F2_CLIENTE == "010343" .Or. SF2->F2_CLIENTE == "020031"
				_nVTVerbas := _nVTVerbas + SD2->D2_VLRAPEL
			Else
				_nVTVerbas := _nVTVerbas + (SD2->D2_VLRAPEL + SD2->D2_VLIQF + SD2->D2_VLMCPRO)
			EndIf
			DbSelectArea("SD2")
			DbSkip()
		Enddo

		// Não mover esta estrutura desta parte  do fonte, pois os vencimentos são recalculados
		// posteriormente, senão os testes com o resultado da função condição não funcionarão
		If _nVTVerbas > 0
			DbSelectArea("SE1")
			DbSetOrder(1)
			MsSeek(FWxFilial("SE1")+_xSERIE+_xDOC)
			Do While !Eof() .And. SE1->E1_FILIAL+SE1->E1_PREFIXO+SE1->E1_NUM == FWxFilial("SE1")+_xSERIE+_xDOC
				If SE1->E1_CLIENTE==_xCLIENTE .And. SE1->E1_LOJA==_xLOJA

					// Monta o array que e calcula as datas de vencimento e os valores gerados
					// a partir da condição de pagamento e data emissão da nota fiscal para que
					// se percorra o array e se divida o total das verbas nas N parcelas
					_aCond := Condicao( _nVTVerbas, _cCondPgt, , _dEmissao )

					For nI:=1 To Len(_aCond)
						_dVctCond := _aCond[nI, 1]
						_nVlrCond := NoRound(_aCond[nI, 2], 2)
						If SE1->E1_VENCTO == _dVctCond
							RecLock("SE1",.F.)
							If SF2->F2_CLIENTE == "000173" .Or. SF2->F2_CLIENTE == "000174" .Or. SF2->F2_CLIENTE == "001110" .Or. SF2->F2_CLIENTE == "010343" .Or. SF2->F2_CLIENTE == "020031"
								SE1->E1_PRAPEL 	:= _nPRapel
								SE1->E1_VLRAPEL := _nVlrCond
							Else
								SE1->E1_PRAPEL 	:= _nPRapel
								SE1->E1_VLRAPEL := _nVlrCond
							EndIf
							MsUnlock()

							Exit
						Endif
					Next nI

				Endif
				DbSelectArea("SE1")
				DbSkip()
			Enddo
		EndIf
		//EndIf
	EndIf

	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Atualiza Titulos a Receber                                   ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	DbSelectArea("SE1")
	DbSetOrder(1)
	MsSeek(FWxFilial("SE1")+_xSERIE+_xDOC)
	Do While !Eof() .And. SE1->E1_FILIAL+SE1->E1_PREFIXO+SE1->E1_NUM == FWxFilial("SE1")+_xSERIE+_xDOC
		If SE1->E1_CLIENTE==_xCLIENTE .And. SE1->E1_LOJA==_xLOJA
			RecLock("SE1",.F.)
			SE1->E1_FRMREC := _xFORMREC
			MsUnLock()

			If _cRECVCTO == "S"

				If SE1->E1_CLIENTE == "002066"		// Regra específica para este cliente criada em 02/01/2023 cfe solicitado por Clailton

					_dVencCalc := SE1->E1_VENCTO
					_cDiaVcto  := Day2Str(_dVencCalc)					// Retorna o dia no formato DD
					_cMesVcto  := Month2Str(_dVencCalc)					// Retorna o mês no formato MM
					_cAnoVcto  := Year2Str(_dVencCalc)					// Retorna o dia no formato AAAA

					If Day(_dVencCalc) <= 10
						_dNewVcto := Stod(_cAnoVcto + Month2Str(MonthSum(_dVencCalc,0)) + "10")
					ElseIf Day(_dVencCalc) >= 11 .And. Day(_dVencCalc) <= 25
						_dNewVcto := Stod(_cAnoVcto + _cMesVcto + "25")
					ElseIf Day(_dVencCalc) >= 26
						If Month2Str(_dVencCalc) == "12"
							_cAnoVcto := Year2Str(YearSum(_dVencCalc,1))
							_dNewVcto := Stod(_cAnoVcto + Month2Str(MonthSum(_dVencCalc,1)) + "10")
						Else
							_dNewVcto := Stod(_cAnoVcto + Month2Str(MonthSum(_dVencCalc,1)) + "10")
						EndIf
					EndIf

				Else

					_dEmisCalc := DaySum(SE1->E1_EMISSAO,_nDIASCAL)					//	Soma dia(s) a uma Data 			[DaySum(Data,nDias)]

					If Day(_dEmisCalc) >= _nDIAINI .And. Day(_dEmisCalc) <= _nDIAFIN
						If Month2Str(_dEmisCalc) == "12"
							_cAnoVcto := Year2Str(YearSum(_dEmisCalc,0))			// Retorna o ano no formato AAAA	[Year2Str(Data)] e Soma ano(s) a uma data		[YearSum(Data,nAno)]
						Else
							_cAnoVcto := Year2Str(_dEmisCalc)						// Retorna o ano no formato AAAA	[Year2Str(Data)]
						Endif
						_dMesVcto := Month2Str(MonthSum(_dEmisCalc,0))				// Retorna o mês no formato MM		[Month2Str(Data)] e Soma mes(es) a uma Data	[MonthSum(Data,nMes)]
						_dDiaVcto := StrZero(_nDIAVCT1,2,0)
						If _dMesVcto == "02" .And. Val(_dDiaVcto) > 28
							_dNewVcto := Stod(_cAnoVcto+_dMesVcto+"28")
						Else
							_dNewVcto := Stod(_cAnoVcto+_dMesVcto+_dDiaVcto)
						Endif
					Else
						If Month2Str(_dEmisCalc) == "12"
							_cAnoVcto := Year2Str(YearSum(_dEmisCalc,0))			// Retorna o ano no formato AAAA	[Year2Str(Data)] e Soma ano(s) a uma data		[YearSum(Data,nAno)]
						Else
							_cAnoVcto := Year2Str(_dEmisCalc)						// Retorna o ano no formato AAAA	[Year2Str(Data)]
						Endif
						_dMesVcto := Month2Str(MonthSum(_dEmisCalc,0))				// Retorna o mês no formato MM	[Month2Str(Data)] e Soma mes(es) a uma Data	[MonthSum(Data,nMes)]
						_dDiaVcto := StrZero(_nDIAVCT2,2,0)
						If _dMesVcto == "02" .And. Val(_dDiaVcto) > 28
							_dNewVcto := Stod(_cAnoVcto+_dMesVcto+"28")
						Else
							_dNewVcto := Stod(_cAnoVcto+_dMesVcto+_dDiaVcto)
						Endif
					Endif
				EndIf

				RecLock("SE1",.F.)
				SE1->E1_VENCTO  := _dNewVcto
				SE1->E1_VENCREA := _dNewVcto
				SE1->E1_VENCORI := _dNewVcto
				MsUnLock()

			Endif

		Endif
		DbSelectArea("SE1")
		DbSkip()
	Enddo

	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Grava dados gerais no cabecalho da nota fiscal               ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	DbSelectArea("SF2")
	RecLock("SF2",.F.)
	SF2->F2_NOMCLI  := SA1->A1_NOME
	SF2->F2_FRMREC  := SA1->A1_FORMREC
	SF2->F2_MENNOTA := SC5->C5_MENNOTA
	SF2->F2_MENNF2  := SC5->C5_MENNF2
	SF2->F2_NUMPEDV := SC5->C5_NUM
	SF2->F2_MARCA   := SC5->C5_MARCA

	If cEmpAnt == "01"	// Executa somente para a empresa 01
		//Validação inserida por Fabian Maurer dia 28/10/14 para validar
		//por data o vencimento do campo Rapel Solicitado por Clailton
		If SA1->A1_VENRAP >= date()
			If SF2->F2_CLIENTE == "000173" .Or. SF2->F2_CLIENTE == "000174" .Or. SF2->F2_CLIENTE == "001110" .Or. SF2->F2_CLIENTE == "010343" .Or. SF2->F2_CLIENTE == "020031"
				SF2->F2_PRAPEL  := SA1->A1_PRAPEL + SA1->A1_PLOGIST
				SF2->F2_VLRAPEL := (SF2->F2_VALBRUT * (SA1->A1_PRAPEL + SA1->A1_PLOGIST)) / 100
			Else
				SF2->F2_PRAPEL  := SA1->A1_PRAPEL
				SF2->F2_VLRAPEL := (SF2->F2_VALBRUT * SA1->A1_PRAPEL) / 100
			EndIf
		Endif
		SF2->F2_PREPED := SC5->C5_PREPED		// Usado para integração com Fusion
	Endif

	// Implementado por PRIMME em 07/01/2014
	If !Empty(SF2->F2_VEICUL1)
		SF2->F2_PLACA	:= GetAdvFVal("DA3", "DA3_PLACA", FWxFilial("DA3") + SF2->F2_VEICUL1, 1)
		SF2->F2_PLACA2  := GetMv("PS_PLACARB")
		SF2->F2_ESTPLA  := GetAdvFVal("DA3", "DA3_ESTPLA", FWxFilial("DA3") + SF2->F2_VEICUL1, 1)
	Else
		SF2->F2_PLACA	:= SC5->C5_PLACA
		SF2->F2_PLACA2  := SC5->C5_PLACA2
		SF2->F2_ESTPLA  := SC5->C5_ESTPLA
	Endif

	MsUnlock()

	// Aqui chama método CHECKOUT para venda efetuada com cartão de crédito somente para a empresa 01
	//Chamada desabilitada dia 04/07/24 pois serviço foi descontinuado
	/*If cEmpAnt == "01"
		If SF2->F2_FRMREC == "5" .And. Empty(SF2->F2_CHKID) .And. Empty(SF2->F2_CODINT)
			U_CHECKOUT(SF2->F2_DOC, SF2->F2_SERIE, SF2->F2_CLIENTE, SF2->F2_LOJA, SF2->F2_VALBRUT)		// Chama Método Checkout
		Endif
	Endif*/

	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ UFSM -  Comunicação com o programa das Tabelas da Rastreabilidade ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	
	// Aguardando teste e ok Vinicius Dia 07/11/21
	/*
	if  GetMV('SI_BRCSTAR')
		CriaRastExpedicaoPendurados(_xDOC, _sSERIE, _cFILIAL)
	Endif
	*/
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Controle de créditos conforme o campo A1_RISCO              ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ

	/*
	if SA1->A1_RISCO = 'E'
	RecLock('SA1',.f.)
	SA1->A1_MSBLQL := '1'
	SA1->A1_SIBLQL := '1'
	MsUnlock()
	endif
	*/

	RestArea(_aAreaSA1)
	RestArea(_aAreaSE1)
	RestArea(_aAreaSF2)
	RestArea(_aArea)

Return


Static Function getJson(NF_DOC, NF_SERIE, NF_FILIAL)
	local jJson
	jJson := JsonObject():New()

	jJson["USUARIO"] := "usuario@protheus"
	jJson["SENHA"] := "admin"
	jJson["NF_DOC"] := NF_DOC
	jJson["NF_SERIE"] := NF_SERIE
	jJson["NF_FILIAL"] := NF_FILIAL
return jJson:ToJson()


Static function CriaRastExpedicaoPendurados(NF_DOC, NF_SERIE, NF_FILIAL)

	Local aHeader as array
	Local cResource as char
	Local cServer as char
	Local cPort as char
	Local cURI as char
	Local oRestClient as object

	aHeader := {}
	cResource := "/protheus/expedicao-pendurados"
	//cServer := "10.0.20.7" // URL (IP) DO SERVIDOR
	cServer := "10.0.20.9" // URL (IP) DO SERVIDOR
	cPort := "80" // PORTA DO SERVIÇO REST
	cURI := "http://" + cServer + "/api" // URI DO SERVIÇO REST

	oRestClient := FwRest():New(cURI)

	AAdd(aHeader, "Content-Type: application/json; charset=UTF-8")
	AAdd(aHeader, "Accept: application/json")
	AAdd(aHeader, "User-Agent: Chrome/65.0 (compatible; Protheus " + GetBuild() + ")")

	oRestClient:setPath(cResource)
	oRestClient:SetPostParams(getJson(NF_DOC, NF_SERIE, NF_FILIAL))

	if oRestClient:Post(aHeader)
		showResult(oRestClient:GetResult())
	else
		showResult(oRestClient:GetLastError())
	endIf

	FreeObj(oRestClient)

return

Static function showResult(cValue)
	if IsBlind()
		//Conout(cValue)
	else
		//MsgInfo(cValue)
	endif
return

Static Function _GetParam()

	_cRet := GetMV('SI_CLCTARA')

Return(_cRet)


//---------------- Início bloco personalizado - SILVA
Static Function _GetPar1()
	_cRet := alltrim(getmv('SI_BDJ300G'))
Return(_cRet)

Static Function _GetPar2()
	_cRet := alltrim(getmv('SI_BDJ320G'))
Return(_cRet)

Static Function _GetPar3()
	_cRet := alltrim(getmv('SI_BDJ360G'))
Return(_cRet)

Static Function _GetPar4()
	_cRet := alltrim(getmv('SI_BDJ400G'))
Return(_cRet)

Static Function _GetPar5()
	_cRet := alltrim(getmv('SI_BDJ450G'))
Return(_cRet)

Static Function _GetPar6()
	_cRet := alltrim(getmv('SI_BDJ480G'))
Return(_cRet)

Static Function _GetPar7()
	_cRet := alltrim(getmv('SI_BDJ500G'))
Return(_cRet)

Static Function _GetPar8()
	_cRet := alltrim(getmv('SI_BDJ502G'))
Return(_cRet)

Static Function _GetPar9()
	_cRet := alltrim(getmv('SI_BDJ503G'))
Return(_cRet)

Static Function _GetPar10()
	_cRet := alltrim(getmv('SI_BDJ600G'))
Return(_cRet)

Static Function _GetPar11()
	_cRet := alltrim(getmv('SI_BDJ720G'))
Return(_cRet)

Static Function _GetPar12()
	_cRet := alltrim(getmv('SI_BDJ800G'))
Return(_cRet)

Static Function _GetPar13()
	_cRet := alltrim(getmv('SI_BDJ8002'))
Return(_cRet)

Static Function _GetPar14()
	_cRet := alltrim(getmv('SI_BDJ900G'))
Return(_cRet)
//---------------- Fim bloco personalizado - SILVA
