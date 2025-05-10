/*
Ponto de entrada utilizado para gerar compensações nas horas extras e faltas
no cálculo de resultados do ponto eletrônico
conforme cadastro de regras\ na tabela ZD0/ZD1
Autor: André R. Lerner - 8bit Soluções em TI
Data: março 2018
*/
#INCLUDE 'Protheus.ch'
#INCLUDE "TOPCONN.CH"
User Function PONCALATOT()

	Local _nx  := 1
	Local _nx2 := 1
	Private _aTotEve    := PARAMIXB[3]	

	Private _cFilial    := PARAMIXB[1]
	Private _cMatri     := PARAMIXB[2]

	/*
	Local dPerIni    := PARAMIXB[4]
	Local dPerFim     := PARAMIXB[5]
	Local aCalend     := PARAMIXB[6]
	*/
	Private _dInicio := PARAMIXB[4]
	Private _dFim    := PARAMIXB[5]
	Private _dDAtu   := _dInicio

	private _cPdExtra1 := "105" //código do evento de hora extra	
	private _cPdExtra2 := "109" //código do evento de hora extra noturna
	private _cPdExtra3 := "107" //código do evento de hora compensada
	private _cPdFalta  := "409" //código do evento de hora falta	
	private _cPdFalJus  := "410" //código do evento de hora falta
	private _cPdDsr    := "465" //código do evento de desconto DSR
	private _cPdCpEx   := "403" //código do evento de compensação de horas extras
	private _cPdCpFalta := "203" //código do evento de compensação de faltas
	private _cPdAcordo  := "015" //código do evento de geração do banco de horas troca de roupa
	private _cPdSaiAnt  := "463" //código do evento de saída antecipada
	private _cPdCpAtest := "204" //código do evento de compensação de atestado

	if (SM0->M0_CODIGO == "01" .and. _cFilial == "00") .or. SM0->M0_CODIGO == "08"

		/*
		for _nx:=1 to len( _aTotEve )		
		//COMPENSA HORA EXTRA
		if _aTotEve[_nx][2] == _cPdExtra1 .or. _aTotEve[_nx][2] == _cPdExtra2 .or. _aTotEve[_nx][2] == _cPdExtra3
		_nQtdeCP := _procCP(_cFilial, _cMatri, _aTotEve[_nx][7], _cPdCpEx, _cPdAcordo, _cPdCpAtest )
		if _nQtdeCP > 0
		_aTotEve[_nx][3] := _subHrs(_aTotEve[_nx][3], _nQtdeCP)
		endif
		endif
		*/
		while _dDAtu <= _dFim
			_nQtdeCP := _procCP(_cFilial, _cMatri, dtos(_dDAtu), _cPdCpEx, _cPdAcordo, _cPdCpAtest )
			if _nQtdeCP > 0
				_nProcEx1 := ASCAN(_aTotEve, {|x|dtos(x[1])+AllTrim(x[2]) == dtos(_dDAtu)+_cPdExtra1})
				_nProcEx2 := ASCAN(_aTotEve, {|x|dtos(x[1])+AllTrim(x[2]) == dtos(_dDAtu)+_cPdExtra2})
				_nProcEx3 := ASCAN(_aTotEve, {|x|dtos(x[1])+AllTrim(x[2]) == dtos(_dDAtu)+_cPdExtra3})
				if _nProcEx1 > 0
					if _nQtdeCP > _aTotEve[_nProcEx1][3]
						_nQtdeCP := _nQtdeCP - _aTotEve[_nProcEx1][3]
						_aTotEve[_nProcEx1][3] := 0
					else
						_aTotEve[_nProcEx1][3] := _subHrs(_aTotEve[_nProcEx1][3], _nQtdeCP)
						_nQtdeCP := 0
					endif
				endif
				if _nProcEx2 > 0 .and. _nQtdeCP > 0
					if _nQtdeCP > _aTotEve[_nProcEx2][3]
						_nQtdeCP := _nQtdeCP - _aTotEve[_nProcEx2][3]
						_aTotEve[_nProcEx2][3] := 0
					else
						_aTotEve[_nProcEx2][3] := _subHrs(_aTotEve[_nProcEx2][3], _nQtdeCP)
						_nQtdeCP := 0
					endif
				endif
				if _nProcEx3 > 0 .and. _nQtdeCP > 0
					if _nQtdeCP > _aTotEve[_nProcEx3][3]
						_nQtdeCP := _nQtdeCP - _aTotEve[_nProcEx3][3]
						_aTotEve[_nProcEx3][3] := 0
					else
						_aTotEve[_nProcEx3][3] := _subHrs(_aTotEve[_nProcEx3][3], _nQtdeCP)
						_nQtdeCP := 0
					endif
				endif
			endif	
			_dDAtu++				
		enddo

		for _nx:=1 to len( _aTotEve )
			//COMPENSA FALTAS / SAIDA ANTECIPADA //.AND. DOW(_aTotEve[_nx][1]) == 7
			if (_aTotEve[_nx][2] == _cPdFalta .or. _aTotEve[_nx][2] == _cPdSaiAnt .or. _aTotEve[_nx][2] == _cPdFalJus);			 	
			.AND. !_lTemAbono(_aTotEve[_nx][1], _aTotEve[_nx][2])
				_nQtdeFal:= 0 
				_nQtdeCP := _procCP(_cFilial, _cMatri, _aTotEve[_nx][7], _cPdCpFalta, _cPdAcordo, _cPdCpAtest )
				// se tem falta e saída antecipada no mesmo dia não deve compensar a saída antecipada 
				if _aTotEve[_nx][2] == _cPdSaiAnt 
					_nQtdeFal := _procCP(_cFilial, _cMatri, _aTotEve[_nx][7], _cPdFalta, _cPdFalta, _cPdFalta )
				endif				
				if _nQtdeCP > 0 .and. _nQtdeFal == 0
					if _aTotEve[_nx][3] > _nQtdeCP
						_aTotEve[_nx][3] := _subHrs(_aTotEve[_nx][3], _nQtdeCP)
					else
						_aTotEve[_nx][3] := 0
					endif	
				endif
				
				
				/*
				//ZERA DESCONTO DSR DA FALTA
				if _aTotEve[_nx][3] == 0
				_dData := DaySum( _aTotEve[_nx][1] , 1 )
				//se o final do período termina sábado, verificar se gera desconto dsr em qual data 
				if _dData <= stod(_cFim)
				for _nx2:=1 to len( _aTotEve )						
				if _aTotEve[_nx2][2] == _cPdDsr .and. DOW(_aTotEve[_nx2][1]) == 1 .and. _dData == _aTotEve[_nx2][1]
				_aTotEve[_nx2][3] := 0
				endif
				next _nx2
				endif
				endif

				//ZERA DESCONTO DSR DA FALTA
				if _aTotEve[_nx][3] == 0
				_dData := DaySum( _aTotEve[_nx][1] , 1 )
				//se o final do período termina sábado, verificar se gera desconto dsr em qual data 
				if _dData <= stod(_cFim)
				for _nx2:=1 to len( _aTotEve )						
				if _aTotEve[_nx2][2] == _cPdDsr .and. DOW(_aTotEve[_nx2][1]) == 1 .and. _dData == _aTotEve[_nx2][1]
				_aTotEve[_nx2][3] := 0
				endif
				next _nx2
				endif
				endif
				*/
			endif

			/*
			//REGRA ESPECÍFICA PARA CC PENDURADOS, VERIFICAR COMO FAZER NOS PRÓXIMOS MESES
			//JOGA SAÍDA ANTECIPADA PARA BANCO DE HORAS
			if _aTotEve[_nx][2] == _cPdSaiAnt .AND. alltrim(_aTotEve[_nx][5]) == '1132001' .AND. !_lTemAbono(_aTotEve[_nx][1], _aTotEve[_nx][2])
			_nQtdeCP := _procCP(_cFilial, _cMatri, _aTotEve[_nx][7], _cPdSaiAnt, _cPdAcordo, _cPdCpAtest )
			if _nQtdeCP > 0
			if _aTotEve[_nx][3] > _nQtdeCP
			_aTotEve[_nx][3] := _subHrs(_aTotEve[_nx][3], _nQtdeCP)
			else
			_aTotEve[_nx][3] := 0
			endif
			endif
			endif
			*/	
		next _nx
		/*
		for _nx3:=1 to len( _aTotEve )
		//COMPENSA SAÍDA ANTECIPADA DA SEMANA ABATE 1131002 e afins
		if ((alltrim(_aTotEve[_nx3][5]) $ '1131002/1131001/1131003/1131010/1131011/1131012/1132006') .OR.;
		(alltrim(_aTotEve[_nx3][5]) == '1132017' .AND. SRA->RA_TNOTRAB == '103')); 		 
		.AND. !_lTemAbono(_aTotEve[_nx3][1], _aTotEve[_nx3][2]) .and. DOW(_aTotEve[_nx3][1]) < 7

		//se tem saída antecipada ou falta se não 
		if (_aTotEve[_nx3][2] == _cPdSaiAnt .or. _aTotEve[_nx3][2] == _cPdFalta)		 
		_nQtdeCP := _procCP(_cFilial, _cMatri, _aTotEve[_nx3][7], _cPdCpFalta, _cPdAcordo, _cPdCpAtest )
		if _nQtdeCP > 0
		if _aTotEve[_nx3][3] >= _nQtdeCP
		_aTotEve[_nx3][3] := _subHrs(_aTotEve[_nx3][3], _nQtdeCP)
		else	
		aAdd( _aTotEve, { _aTotEve[_nx3][1],;
		_cPdExtra1,;
		_subHrs(_nQtdeCP, _aTotEve[_nx3][3]),;
		"992",;
		SRA->RA_CC,;
		0,;
		_aTotEve[_nx3][7],;
		Nil,;
		Nil,;
		Nil,;
		Nil,;
		Nil,;
		Nil,;
		Nil,;
		"",;
		0 } )
		_aTotEve[_nx3][3] := 0
		endif
		endif				
		endif	
		endif	
		next _nx3
		*/
	endif
Return _aTotEve

/*
Retorna quantidade compensada
*/
static function _procCP (_cFilial, _cMat, _sData, _cEvento1, _cEvento2, _cEvento3 )
	Local _aSaveA2 := GetArea()
	Local _nQtde := 0

	_cQuery := " SELECT ISNULL(sum(CAST(PC_QUANTC AS INT)+(((PC_QUANTC - CAST(PC_QUANTC AS INT)) /60) *100)),0) AS QTDE "
	_cQuery += " FROM " + RETSQLNAME ("SPC") +" AS SPC "
	_cQuery += " WHERE SPC.D_E_L_E_T_ = '' AND PC_DATA = '"+_sData+"' AND PC_MAT = '"+_cMat+"' "
	_cQuery += " AND (PC_PD = '"+_cEvento1+"' or PC_PD = '"+_cEvento2+"' or PC_PD = '"+_cEvento3+"')  "

	tcquery _cQuery new alias _trba
	do while ! _trba -> (eof ())
		_nQtde := _trba->QTDE
		dbSelectArea("_trba")
		dbSkip()
	enddo
	dbSelectArea("_trba")
	_trba->(DbCloseArea())
	RestArea(_aSaveA2)

return (fConvHr(_nQtde, 'H'))


static function _subHrs(_nHr1, _nHr2)

	Local _nSub1 := 0 
	Local _nSub2 := 0

	_nSub1 := (int(_nHr1) + (((_nHr1 - int(_nHr1)) / 60) * 100)) - (int(_nHr2) + (((_nHr2 - int(_nHr2)) / 60) * 100))
	_nSub2 := int(_nSub1) + (((_nSub1 - int(_nSub1)) * 60) / 100)

return(_nSub2)

static function _lTemAbono(_dData1, _cPd)
	Local _cQuery := ""
	Local _nCount := 0
	_cQuery := " SELECT COUNT(*) AS CONT "
	_cQuery += " FROM " + RETSQLNAME ("SPK") +" AS SPK  "
	_cQuery += " WHERE SPK.D_E_L_E_T_ = '' AND PK_MAT = '"+_cMatri+"' AND PK_FILIAL = '"+_cFilial+"' " 
	_cQuery += " AND PK_DATA = '"+dtos(_dData1)+"' AND PK_CODEVE = '"+_cPd+"' " 

	tcquery _cQuery new alias _trbb

	do while !_trbb->(eof())
		_nCount := _trbb->CONT
		dbSelectArea("_trbb")
		dbSkip()
	enddo
	dbSelectArea("_trbb")
	_trbb->(DbCloseArea())

return(_nCount > 0)
