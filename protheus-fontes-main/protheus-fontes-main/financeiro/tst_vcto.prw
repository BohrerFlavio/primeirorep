#INCLUDE "TOTVS.CH"

User Function TST_VCTO()

	Local _dVencto := CTOD("01/01/2023")
	Local nX

	MsgAlert("Deseja realizar processamento de Teste", "Teste")

	/*
	_LOG(">>>>>>>>>> SIMULACAO PARA O CLIENTE 002066 <<<<<<<<<<")
	For nX := 1 To 800
		_dVencCalc := _dVencto + nX
		_cDiaVcto  := Day2Str(_dVencCalc)					// Retorna o dia no formato DD
		_cMesVcto  := Month2Str(_dVencCalc)					// Retorna o mês no formato MM
		_cAnoVcto  := Year2Str(_dVencCalc)					// Retorna o dia no formato AAAA

		If Day(_dVencCalc) >= 1 .And. Day(_dVencCalc) <= 10
			
			_dNewVcto := Stod(_cAnoVcto + Month2Str(MonthSum(_dVencCalc,0)) + "10")
			_LOG("1 - Vencimento: " + Dtoc(_dVencCalc) + "     Novo Vencto: " + Dtoc(_dNewVcto))
		
		ElseIf Day(_dVencCalc) >= 11 .And. Day(_dVencCalc) <= 25
			
			_dNewVcto := Stod(_cAnoVcto + _cMesVcto + "25")
			_LOG("2 - Vencimento: " + Dtoc(_dVencCalc) + "     Novo Vencto: " + Dtoc(_dNewVcto))

		ElseIf Day(_dVencCalc) >= 26 .And. Day(_dVencCalc) <= 31
			
			If Month2Str(_dVencCalc) == "12"
				_cAnoVcto := Year2Str(YearSum(_dVencCalc,1))
				_dNewVcto := Stod(_cAnoVcto + Month2Str(MonthSum(_dVencCalc,1)) + "10")
			Else
				_dNewVcto := Stod(_cAnoVcto + Month2Str(MonthSum(_dVencCalc,1)) + "10")
			EndIf
			_LOG("3 - Vencimento: " + Dtoc(_dVencCalc) + "     Novo Vencto: " + Dtoc(_dNewVcto))

		EndIf
	Next
	*/

	/*
	_LOG(">>>>>>>>>> SIMULACAO PARA O CLIENTE 008222 <<<<<<<<<<")
	For nX := 1 To 800
		_dVencCalc := _dVencto + nX
		_cDiaVcto  := Day2Str(_dVencCalc)					// Retorna o dia no formato DD
		_cMesVcto  := Month2Str(_dVencCalc)					// Retorna o mês no formato MM
		_cAnoVcto  := Year2Str(_dVencCalc)					// Retorna o dia no formato AAAA

		If Day(_dVencCalc) >= 1 .And. Day(_dVencCalc) <= 10
			
			_dNewVcto := Stod(_cAnoVcto + Month2Str(MonthSum(_dVencCalc,0)) + "11")
			_LOG("1 - Vencimento: " + Dtoc(_dVencCalc) + "     Novo Vencto: " + Dtoc(_dNewVcto))
		
		ElseIf Day(_dVencCalc) >= 11 .And. Day(_dVencCalc) <= 20
			
			_dNewVcto := Stod(_cAnoVcto + _cMesVcto + "21")
			_LOG("2 - Vencimento: " + Dtoc(_dVencCalc) + "     Novo Vencto: " + Dtoc(_dNewVcto))

		ElseIf Day(_dVencCalc) >= 21 .And. Day(_dVencCalc) <= 31
			
			If Month2Str(_dVencCalc) == "12"
				_cAnoVcto := Year2Str(YearSum(_dVencCalc,1))
				_dNewVcto := Stod(_cAnoVcto + Month2Str(MonthSum(_dVencCalc,1)) + "11")
			Else
				_dNewVcto := Stod(_cAnoVcto + Month2Str(MonthSum(_dVencCalc,1)) + "11")
			EndIf
			_LOG("3 - Vencimento: " + Dtoc(_dVencCalc) + "     Novo Vencto: " + Dtoc(_dNewVcto))

		EndIf
	Next
	*/

	_LOG(">>>>>>>>>> SIMULACAO PARA O CLIENTE 023785 <<<<<<<<<<")
	For nX := 1 To 800
		_dVencCalc := _dVencto + nX
		_cDiaVcto  := Day2Str(_dVencCalc)					// Retorna o dia no formato DD
		_cMesVcto  := Month2Str(_dVencCalc)					// Retorna o mês no formato MM
		_cAnoVcto  := Year2Str(_dVencCalc)					// Retorna o dia no formato AAAA

		If Day(_dVencCalc) >= 1 .And. Day(_dVencCalc) <= 7
			
			_dNewVcto := Stod(_cAnoVcto + Month2Str(MonthSum(_dVencCalc,0)) + "7")
			_LOG("1 - Vencimento: " + Dtoc(_dVencCalc) + "     Novo Vencto: " + Dtoc(_dNewVcto))
		
		ElseIf Day(_dVencCalc) >= 8 .And. Day(_dVencCalc) <= 22
			
			_dNewVcto := Stod(_cAnoVcto + _cMesVcto + "23")
			_LOG("2 - Vencimento: " + Dtoc(_dVencCalc) + "     Novo Vencto: " + Dtoc(_dNewVcto))

		ElseIf Day(_dVencCalc) >= 23 .And. Day(_dVencCalc) <= 31
			
			If Month2Str(_dVencCalc) == "12"
				_cAnoVcto := Year2Str(YearSum(_dVencCalc,1))
				_dNewVcto := Stod(_cAnoVcto + Month2Str(MonthSum(_dVencCalc,1)) + "7")
			Else
				_dNewVcto := Stod(_cAnoVcto + Month2Str(MonthSum(_dVencCalc,1)) + "7")
			EndIf
			_LOG("3 - Vencimento: " + Dtoc(_dVencCalc) + "     Novo Vencto: " + Dtoc(_dNewVcto))

		EndIf
	Next

Return

//-------------------------------------------------------------------
/*/{Protheus.doc} _LOG
Função que Grava arquivo de log para conferência
@author     Evandro
@since      Jan/2023
@return     Nenhum
/*/
//-------------------------------------------------------------------
Static Function _LOG(_sTexto)

	Local _nHdl     := 0
	Local _cDir     := "C:\Temp\"
	Local _cNomeArq := "LogTESTE_CLIENTE-023785.LOG"
	Local _sArqLog  := ""

	_sArqLog := AllTrim(_cDir) + AllTrim(_cNomeArq)

	If file (_sArqLog)
		_nHdl = fOpen(_sArqLog, 1)
	Else
		_nHdl = fCreate(_sArqLog, 0)
	Endif

	fSeek(_nHdl, 0, 2)      // Encontra final do arquivo
	fWrite(_nHdl, _sTexto + chr (13) + chr (10))
	fClose(_nHdl)

Return
