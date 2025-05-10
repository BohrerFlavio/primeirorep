#INCLUDE "rwmake.ch"
#INCLUDE "topconn.ch"

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณMLR24     บAutor  ณMauricio Roehrs     บ Data ณ  28/10/13   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณ  Fonte destinado a gera็ใo de verba para calculo de        บฑฑ
ฑฑบ          ณ  de horas extras para semana compensada, onde o sabado	  บฑฑ
ฑฑบ	       ณ   ้ feriado                                                บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso DPL   ณ AP                                                         บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/

User Function MLR24

	Private _cDtPeriodo := GETMV('MV_PAPONTA')
	Private _cDtIni     := substr(_cDtPeriodo,1,8)
	Private _cDtFim 	  := substr(_cDtPeriodo,10,18)
	Private _nTotHrSem  := 0

	_cQuery := " SELECT P3_DATA
	_cQuery += " FROM " + RetSQLTab('SP3')
	_cQuery += " WHERE " + RetSQLFil('SP3') + " AND"
	_cQuery += " P3_DATA BETWEEN '" + _cDtIni + "' AND  '" + _cDtFim + "' AND"
	_cQuery += " P3_SABFERI = 'S'
	_cQUery += " AND " + RetSQLDel('SP3')
	_cQuery += " ORDER BY P3_DATA

	//	* Mostrar a consulta */
	//@ 116,090 To 416,707 Dialog oDlgMemo Title "Consulta"
	//@ 055,005 Get _cQuery Size 250,080 MEMO Object oMemo
	//Activate Dialog oDlgMemo

	If Select("TMP")<>0
		TMP->(dbCloseArea())
	Endif

	_cQuery := ChangeQuery(_cQuery)
	TCQUERY _cQuery NEW ALIAS "TMP"

	_aBat := {}

	TMP->(DbGoTop())
	while TMP->(!eof())

		_dIniSem := stod(TMP->P3_DATA) - 5
		_dFimSem := stod(TMP->P3_DATA) - 1

		/*PRIMEIRAMENTE VERIFICA NA TABELA DE MARCAวีES(SP8)*/
		SP8->(DbSetOrder(2))	
		if SP8->(DbSeek(xFilial('SP8') + SRA->RA_MAT + dtos(_dIniSem))) .and. alltrim(SRA->RA_CC) $ '1111001/1111003/1121002'

			while xFilial('SP8') = SP8->P8_FILIAL .and. SRA->RA_MAT  = SP8->P8_MAT .and. SP8->P8_DATA <= _dFimSem
				_dDataCorrente := SP8->P8_DATA

				/*Ignora marca็๕es que foram rejeitados automaticamente pelo sistema */
				if SP8->P8_TIPOREG = 'O' .and. !empty(SP8->P8_MOTIVRG )
					SP8->(DbSkip())
					if _dDataCorrente <> SP8->P8_DATA .or. SP8->(eof())
						aSort(_aBat)
						_nTotHrSem += calcula(_aBat)
						_aBat := {}
					endif
					loop
				endif

				/*Ignora marca็๕es que foram excluidas manualmente*/
				if SP8->P8_TIPOREG = 'I' .and. (SP8->P8_MOTIVRG $ 'MARC INVERTIDA' .or. SP8->P8_MOTIVRG $ 'MARCACAO INVERTIDA')
					SP8->(DbSkip())
					if _dDataCorrente <> SP8->P8_DATA .or. SP8->(eof())
						aSort(_aBat)
						_nTotHrSem += calcula(_aBat)
						_aBat := {}
					endif
					loop
				endif

				/*Ignora marca็๕es que foram excluidas manualmente*/
				if SP8->P8_TIPOREG = 'I' .and. (SP8->P8_MOTIVRG $ 'MARC INCORRETA' .or. SP8->P8_MOTIVRG $ 'MARCACAO INCORRETA')
					SP8->(DbSkip())
					if _dDataCorrente <> SP8->P8_DATA .or. SP8->(eof())
						aSort(_aBat)
						_nTotHrSem += calcula(_aBat)
						_aBat := {}
					endif
					loop
				endif

				/*Ignora marca็๕es que foram excluidas manualmente*/
				if SP8->P8_TIPOREG = 'I' .and. SP8->P8_MOTIVRG $ 'EXCLUSAO MANUAL'
					SP8->(DbSkip())
					if _dDataCorrente <> SP8->P8_DATA .or. SP8->(eof())
						aSort(_aBat)
						_nTotHrSem += calcula(_aBat)
						_aBat := {}
					endif
					loop
				endif

				aAdd(_aBat,SP8->P8_HORA)

				SP8->(DbSkip())

				if _dDataCorrente <> SP8->P8_DATA .or. SP8->(eof())
					aSort(_aBat)
					_nTotHrSem += calcula(_aBat)  
					_aBat := {}
				endif

			enddo
		endif

		/*CASO NรO EXISTA NA TABELA DE MARCAวีES(SP8) IRม VERIFICAR NA TABELA DE ACUMULADOS(SPG)*/
		SPG->(DbSetOrder(2))
		if SPG->(DbSeek(xFilial('SPG') + SRA->RA_MAT + dtos(_dIniSem)))

			while xFilial('SPG') = SPG->PG_FILIAL .and. SRA->RA_MAT = SPG->PG_MAT .and. SPG->PG_DATA <= _dFimSem

				_dDataCorrente := SPG->PG_DATA

				/*Ignora marca็๕es que foram rejeitados automaticamente pelo sistema */
				if SPG->PG_TIPOREG = 'O' .and. !empty(SPG->PG_MOTIVRG )
					SPG->(DbSkip())
					if _dDataCorrente <> SPG->PG_DATA .or. SPG->(eof())
						aSort(_aBat)
						_nTotHrSem += calcula(_aBat)
						_aBat := {}
					endif
					loop
				endif

				/*Ignora marca็๕es que foram excluidas manualmente*/
				if SPG->PG_TIPOREG = 'I' .and. (SPG->PG_MOTIVRG $ 'MARC INVERTIDA' .or. SPG->PG_MOTIVRG $ 'MARCACAO INVERTIDA')
					SPG->(DbSkip())
					if _dDataCorrente <> SPG->PG_DATA .or. SPG->(eof())
						aSort(_aBat)
						_nTotHrSem += calcula(_aBat)
						_aBat := {}
					endif
					loop
				endif

				/*Ignora marca็๕es que foram excluidas manualmente*/
				if SPG->PG_TIPOREG = 'I' .and. (SPG->PG_MOTIVRG $ 'MARC INCORRETA' .or. SPG->PG_MOTIVRG $ 'MARCACAO INCORRETA')
					SPG->(DbSkip())
					if _dDataCorrente <> SPG->PG_DATA .or. SPG->(eof())
						aSort(_aBat)
						_nTotHrSem += calcula(_aBat)
						_aBat := {}
					endif
					loop
				endif

				/*Ignora marca็๕es que foram excluidas manualmente*/
				if SPG->PG_TIPOREG = 'I' .and. SPG->PG_MOTIVRG $ 'EXCLUSAO MANUAL'
					SPG->(DbSkip())
					if _dDataCorrente <> SPG->PG_DATA .or. SPG->(eof())
						aSort(_aBat)
						_nTotHrSem += calcula(_aBat)
						_aBat := {}
					endif
					loop
				endif

				aAdd(_aBat,SPG->PG_HORA)

				SPG->(DbSkip())

				if _dDataCorrente <> SPG->PG_DATA .or. SPG->(eof())
					aSort(_aBat)
					_nTotHrSem += calcula(_aBat)
					_aBat := {}
				endif
			enddo
		endif

		TMP->(DbSkip())
	enddo

	//se for transportadora calcula hora extra a 50%
	if cEmpAnt = '07'
		if SRA->RA_ADCINS = "3" //se insalubridade media diferente de zero   
			_nInsMed := (@VAL_SALMIN * 0.20) / SRA->RA_INSMAX                       
			fGeraVerba("272",((SALHORA + _nInsMed) * 1.5) * _nTotHrSem,_nTotHrSem,,,"V","I",,,,.T.)        
			
		elseif SRA->RA_ADCINS = "4" //se insalubridade maxima diferente de zero
			_nInsMax := (@VAL_SALMIN * 0.40) / SRA->RA_INSMAX                 
			fGeraVerba("272",((SALHORA + _nInsMax) * 1.5) * _nTotHrSem,_nTotHrSem,,,"V","I",,,,.T.)	 					
			
		else 
			fGeraVerba("272",(SALHORA * 1.5) * _nTotHrSem,_nTotHrSem,,,"V","I",,,,.T.)	    			
		endif
	else
		if SRA->RA_ADCINS = "3" //se insalubridade media diferente de zero    
			_nInsMed := (@VAL_SALMIN * 0.20) / SRA->RA_INSMAX                       
			fGeraVerba("272",((SALHORA + _nInsMed) * 1.6) * _nTotHrSem,_nTotHrSem,,,"V","I",,,,.T.)
						
		elseif SRA->RA_ADCINS = "4" //se insalubridade maxima diferente de zero
			_nInsMax := (@VAL_SALMIN * 0.40) / SRA->RA_INSMAX          
			fGeraVerba("272",((SALHORA + _nInsMax) * 1.6) * _nTotHrSem,_nTotHrSem,,,"V","I",,,,.T.) 		         
		
		else                                                        
			fGeraVerba("272",(SALHORA * 1.6) * _nTotHrSem,_nTotHrSem,,,"V","I",,,,.T.)    		
			
		endif
	endif

	_nTotHrSem := 0
return

Static Function Calcula(_aBatida)
	Local i
	Local _nTotHrs  := 0
	Local _nHoras   := 0
	Local _nCalcHrs := 0 
	Local _nHrOito	 := fConvHr(8.00,'D')
	Local _nHrOito2 := fConvHr(8.48,'D')
	Local _nMinuto	 := fConvHr(0.48,'D')

	for i:=1 to len(_aBatida)
		if mod(i,2) == 0
			//alert(fConvHr(_aBatida[i],'D'))
			//alert(fConvHr(_aBatida[i-1],'D')) 

			_nCalcHrs := fConvHr(_aBatida[i],'D') - fConvHr(_aBatida[i-1],'D')

			_nTotHrs += _nCalcHrs

		endif
	next
	//alert(_nTotHrs)
	if _nTotHrs >= _nHrOito2

		_nHoras := _nMinuto

	elseif _nTotHrs > _nHrOito .and. _nTotHrs < _nHrOito2

		_nHoras := _nTotHrs - _nHrOito
		//_nHoras := fConvHr(_nHoras,'H')
	else
		_nHoras := 0	
	endif

return _nHoras
