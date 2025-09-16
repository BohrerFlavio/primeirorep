#INCLUDE "PROTHEUS.CH"
#INCLUDE "RWMAKE.CH"

/*/{Protheus.doc} GJF123
Rotina de cálculo e descálculo de depreciação para apuração de crédito de PIS e COFINS de bens de ativo
@author 	Ajustado por Evandro Mugnol
@since 		27/01/2020
@return 	lRet
@obs 		Nil
/*/

User Function GJF123()

	Local cPerg       := "GJF123"
	Private _cPeriodo := "" 

	If !Pergunte(cPerg,.T. ) 
		Return
	Endif

	// Variaveis para tratamento de perguntas
	_cBaseIni := mv_par01                 // Bem Inicial
	_cBaseFim := mv_par02                 // Bem Final
	_dData    := mv_par03
	_cData    := Dtos(mv_par03)
	_cPeriodo := Substr(_cData,1,6)       // Período

	If mv_par04 =1
		Processa({||Calcula()} ,"CÁLCULO DE PARCELAS", "Executando cálculo das parcelas...")
	ElseIf mv_par04 = 2                                                                    
		Processa({||Descalcula()} ,"DESCÁLCULO DE PARCELAS", "Executando descálculo das parcelas...")
	Endif

Return


//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Função que efetua o CÁLCULO                                  ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
Static Function Calcula()

	ProcRegua(ZB2->(RecCount()))

	DbSelectArea("ZB2")
	DbSetOrder(1)
	DbSeek(xFilial("ZB2") + _cBaseIni, .T.)
	While !Eof() .And. ZB2->ZB2_FILIAL == xFilial("ZB2") .And. ZB2->ZB2_CBASE <= _cBaseFim 

		If ZB2->ZB2_ATIVO == "N"
		    DbSelectArea("ZB2")
			DbSkip()
			Loop
		Endif

		If ZB2->ZB2_MESCPI <= ZB2->ZB2_PCRED
		    DbSelectArea("ZB2")
			DbSkip()
			Loop			
		Endif 

		_nParcTot := ZB2->ZB2_MESCPI  	// Numero total de parcelas
		_nParcCal := ZB2->ZB2_PCRED		// Numero de parcelas calculadas
		_dAquisi  := ZB2_AQUISI       	// Data de aquisição
		_nVlrPISM := ZB2->ZB2_VLRPIS  	// Valor PIS Mes
		_nVlrCOFM := ZB2->ZB2_VLRCOF  	// Valor COF Mes
		_nVlrPIST := ZB2->ZB2_VLPIST  	// Valor Total PIS
		_nVlrCOFT := ZB2->ZB2_VLCOFT  	// Valor Total Cofins
		_nSldPIS  := ZB2->ZB2_SLDPIS	// Saldo PIS
		_nSldCOF  := ZB2->ZB2_SLDCOF	// Saldo COFINS
		_nSldTot  := ZB2->ZB2_SLDTOT	// Saldo Total

		IncProc()
		
		DbSelectArea("ZB3")
		DbSetOrder(1)
		DbSeek(xFilial("ZB3") + ZB2->ZB2_CBASE + ZB2->ZB2_ITEM + _cPeriodo)
		If Found()		// Se já existe registro da parcela calculada ...
			DbSelectArea("ZB2")
			DbSkip()
			Loop
		Else			// Verifica a sequencia de períodos 
			_cUltPer := ""
			_cUltPar := ""
			DbSelectArea("ZB3")
			DbSetOrder(1)
			DbSeek(xFilial("ZB3") +ZB2->ZB2_CBASE + ZB2->ZB2_ITEM)
			If Found() 
				While !Eof() .And. ZB3->ZB3_FILIAL + ZB3->ZB3_CBASE + ZB3->ZB3_ITEM == xFilial("ZB3") +ZB2->ZB2_CBASE + ZB2->ZB2_ITEM
					_cUltPer := ZB3->ZB3_PERIOD
					_cUltPar := ZB3->ZB3_PARCEL
					
					DbSelectArea("ZB3")
					DbSkip()
				EndDo
			Endif      

			_cUltPer := _Periodo(_cUltPer)

			If _nSldTot == 0 .Or. _nParcTot == _nParcCal
				DbSelectArea("ZB2")
				DbSkip()
				Loop
			Else 
				DbSelectArea("ZB3")
				RecLock("ZB3",.T.)
				ZB3->ZB3_FILIAL  := xFilial("ZB3")
				ZB3->ZB3_CBASE   := ZB2->ZB2_CBASE
				ZB3->ZB3_ITEM    := ZB2->ZB2_ITEM
				ZB3->ZB3_DATA    := _dData
				ZB3->ZB3_PARCEL  := StrZero( (Val(_cUltPar) + 1), 2, 0)
				ZB3->ZB3_VLRPIS  := _nVlrPISM
				ZB3->ZB3_VLRCOF  := _nVlrCOFM
				ZB3->ZB3_PERIOD  := _cUltPer     
				ZB3->ZB3_SLDPIS  := _nSldPIS - _nVlrPISM
				ZB3->ZB3_SLDCOF  := _nSldCOF - _nVlrCOFM
				MsUnlock()

				DbSelectArea("ZB2")
				RecLock("ZB2",.F.)
				ZB2->ZB2_SLDPIS := _nSldPIS - _nVlrPISM
				ZB2->ZB2_SLDCOF := _nSldCOF - _nVlrCOFM
				ZB2->ZB2_PCRED  := _nParcCal + 1
				ZB2->ZB2_SLDTOT := ZB2->ZB2_SLDTOT - (_nVlrPISM + _nVlrCOFM) 
				ZB2->ZB2_DTCALC := DDATABASE
				MsUnlock()
			Endif
		Endif

		DbSelectArea("ZB2")
		DbSkip()
	EndDo

Return


//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Função que retorna o período da ZB3                          ³
//³ Se não tiver registros na ZB3, então pega o período da data  ³
//³ de aquisição calculado com as parcelas                       ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
Static Function _Periodo(_cPer)

	Local _RetPer   := ""

	If Empty(_cPer)			// Se não tem registro na ZB3
		_RetPer := Substr( Dtos(ZB2->ZB2_AQUISI), 1, 6 )
	Else					// Se já existem registros na ZB3
		_dUltData := Stod(_cPer + "01")
		_dPrxData := MonthSum(_dUltData,1)				// Soma mes(es) a uma Data 
		_RetPer   := Substr( Dtos(_dPrxData), 1, 6 )
	Endif

Return(_RetPer)


//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Função que efetua o DESCÁLCULO                               ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
Static Function Descalcula()

	ProcRegua(ZB2->(RecCount()))

	DbSelectArea("ZB2")
	DbSetOrder(1)
	DbSeek(xFilial("ZB2") + _cBaseIni, .T.)
	While !Eof() .And. ZB2->ZB2_FILIAL == xFilial("ZB2") .And. ZB2->ZB2_CBASE <= _cBaseFim 

		If ZB2->ZB2_ATIVO == "N"
		    DbSelectArea("ZB2")
			DbSkip()
			Loop
		Endif

		If ZB2->ZB2_PCRED == 0    
		    DbSelectArea("ZB2")
			DbSkip()
			Loop
		Endif    

		_nParcTot := ZB2->ZB2_MESCPI  	// Numero total de parcelas
		_nParcCal := ZB2->ZB2_PCRED		// Numero de parcelas calculadas
		_dAquisi  := ZB2_AQUISI       	// Data de aquisição
		_nVlrPISM := ZB2->ZB2_VLRPIS  	// Valor PIS Mes
		_nVlrCOFM := ZB2->ZB2_VLRCOF  	// Valor COF Mes
		_nVlrPIST := ZB2->ZB2_VLPIST  	// Valor Total PIS
		_nVlrCOFT := ZB2->ZB2_VLCOFT  	// Valor Total Cofins
		_nSldPIS  := ZB2->ZB2_SLDPIS	// Saldo PIS
		_nSldCOF  := ZB2->ZB2_SLDCOF	// Saldo COFINS
		_nSldTot  := ZB2->ZB2_SLDTOT	// Saldo Total

		IncProc()

		_cUltPer := ""
		DbSelectArea("ZB3")
		DbSetOrder(1)
		DbSeek(xFilial("ZB3") +ZB2->ZB2_CBASE + ZB2->ZB2_ITEM)
		If Found() 
			While !Eof() .And. ZB3->ZB3_FILIAL + ZB3->ZB3_CBASE + ZB3->ZB3_ITEM == xFilial("ZB3") +ZB2->ZB2_CBASE + ZB2->ZB2_ITEM
				_cUltPer := ZB3->ZB3_PERIOD
				
				DbSelectArea("ZB3")
				DbSkip()
			EndDo
		Endif      

		If _cPeriodo == _cUltPer
			_nSldCOF := ZB2->ZB2_SLDCOF + ZB2->ZB2_VLRCOF
			_nSldPIS := ZB2->ZB2_SLDPIS + ZB2->ZB2_VLRPIS
			_nPCred  := ZB2->ZB2_PCRED - 1           

			DbSelectArea("ZB3")
			DbSetOrder(1)
			DbSeek(xFilial("ZB3") + ZB2->ZB2_CBASE + ZB2->ZB2_ITEM + _cUltPer)
			If Found()
				RecLock("ZB3",.F.)
				DbDelete()
				MsUnlock()

				DbSelectArea("ZB2")
				RecLock("ZB2",.F.)
				ZB2->ZB2_SLDPIS := _nSldPIS + _nVlrPISM
				ZB2->ZB2_SLDCOF := _nSldCOF + _nVlrCOFM
				ZB2->ZB2_PCRED  := _nParcCal - 1
				ZB2->ZB2_SLDTOT := ZB2->ZB2_SLDTOT + (_nVlrPISM + _nVlrCOFM) 
				MsUnlock()
			Endif
		Endif

		DbSelectArea("ZB2")
		DbSkip()
	EndDo

Return
