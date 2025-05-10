#INCLUDE 'Protheus.ch'
#INCLUDE "topconn.ch"
User Function PN80GRBH()

	Local _x := 0
	Local _nProv := 0
	Local _nDesc := 0
	Local _nSaldo := 0
	Local _cProv := '896'
	Local _cBHP  := '100'
	Local _cBHN  := '400'

	private _sInicio :=SUBSTR(GETMV("MV_PONMES"),1,8)
	private _sFim    :=SUBSTR(GETMV("MV_PONMES"),10,8)
	private _c1  := PARAMIXB[1]
	private _c2  := PARAMIXB[2]
	private _a1  := PARAMIXB[3]
	private _a2  := PARAMIXB[4]
	private _d1  := PARAMIXB[5]
	private _c3  := PARAMIXB[6]
	Private _cCc   := SRA->RA_CC
	Private _cTurno:= u_ob_cTurno(SRA->RA_FILIAL, SRA->RA_MAT, _sFim )
	Private _cSldTr:= ""

	if (SM0->M0_CODIGO == "01" .and. SRA->RA_FILIAL == "00") .or. SM0->M0_CODIGO == "08"
		if SRA->RA_BHFOL == "S"
			for _x:= 1 to len (_a1)
				if _a1[_x][4] == '1'
					_nProv += _a1[_x][2]
				endif
				if _a1[_x][4] == '2'
					_nDesc += _a1[_x][2]
				endif
			next _x
			_nSaldo := fConvHr(_nProv, "D" ) - fConvHr(_nDesc, "D" )

			dbSelectArea("SPB")
			DbSetOrder(1)
			DbSeek(SRA->RA_FILIAL+ SRA->RA_MAT + _cBHP , .T.)
			do while !eof() .and. SPB->PB_FILIAL == SRA->RA_FILIAL .and. SPB->PB_MAT == SRA->RA_MAT
				if _cBHP == SPB->PB_PD .AND. DTOS(SPB->PB_DATA) == DTOS(_d1)
					reclock('SPB',.F.)
					dbdelete()
					msunlock()
				endif
				dbSelectArea("SPB")
				dbSkip()
			enddo

			if _nSaldo > 0
				RecLock( "SPB" , .T. )
				SPB->PB_FILIAL := SRA->RA_FILIAL
				SPB->PB_CC     := SRA->RA_CC
				SPB->PB_MAT    := SRA->RA_MAT
				SPB->PB_PD     := _cBHP
				SPB->PB_HORAS  := _nSaldo
				SPB->PB_DATA   := _d1
				SPB->PB_TIPO1  := "H"
				SPB->PB_TIPO2  := "G"
				SPB->PB_VALOR  := 0
				SPB->( MsUnlock() )
			endif
		endif
	endif

return()


user function ob_sldBH(_cFilial, _cMatri, _sDIni, _sDFim, _cCc, _cTurno)
	Local _nSaldo := 0
	cQuery := " SELECT SUM(CASE WHEN PI_PD < 500 THEN (CAST(PI_QUANT AS INTEGER) + (((PI_QUANT - CAST(PI_QUANT AS INTEGER))*100) /60)) ELSE 0 END) AS POS, "
	cQuery += " SUM(CASE WHEN PI_PD >= 500 THEN (CAST(PI_QUANT AS INTEGER) + (((PI_QUANT - CAST(PI_QUANT AS INTEGER))*100) /60)) ELSE 0 END) AS NEG "
	cQuery += " FROM " + retsqlname ("SPI") +" AS SPI "
	cQuery += " WHERE SPI.D_E_L_E_T_ = '' AND PI_DATA BETWEEN '"+_sDIni+"' AND '"+_sDFim+"' "
	cQuery += " AND PI_MAT = '"+_cMatri+"' AND PI_FILIAL = '"+_cFilial+"' "
	cQuery += " AND PI_CC = '"+_cCc+"' AND '"+_cTurno+"' IN "
	cQuery += " (SELECT TOP 1 PF_TURNOPA FROM " + retsqlname ("SPF") +" AS SPF "
	cQuery += " WHERE PF_FILIAL = PI_FILIAL AND PF_MAT = PI_MAT AND PF_DATA <= '"+_sDFim+"' "
	cQuery += " ORDER BY PF_DATA DESC ) "
	TcQuery cQuery New ALIAS "TRB"
	DbSelectArea("TRB")
	DbGoTop()
	Do While !Eof()
		_nSaldo := round(TRB->POS-TRB->NEG,2)
		TRB->(DbSkip())
	Enddo
	TRB->(DbCloseArea())
return(_nSaldo)

user function ob_cTurno(_cF, _cM, _sFim )
	Local _cTur := ""
	cQuery := " SELECT TOP 1 PF_TURNOPA FROM " + retsqlname ("SPF") +" AS SPF "
	cQuery += " WHERE PF_FILIAL = '"+_cF+"' AND PF_MAT = '"+_cM+"' AND PF_DATA <= '"+_sFim+"' "
	cQuery += " ORDER BY PF_DATA DESC "
	TcQuery cQuery New ALIAS "TRB"
	DbSelectArea("TRB")
	DbGoTop()
	Do While !Eof()
		_cTur := TRB->PF_TURNOPA
		TRB->(DbSkip())
	Enddo
	TRB->(DbCloseArea())

return(_cTur)

user function ob_sldSet(_cCc, _cTurno, _sFim, _cTpRet)
	Local _nRet := 0

	cQuery := " SELECT ZD4_MEDIA, ZD4_TOLERA FROM " + retsqlname ("ZD4") +" AS ZD4 "
	cQuery += " WHERE ZD4.D_E_L_E_T_ = '' AND ZD4_CC = '"+_cCc+"' AND ZD4_TURNO = '"+_cTurno+"' "
	cQuery += " AND ZD4_DATA <= '"+_sFim+"' "

	TcQuery cQuery New ALIAS "TRB"
	DbSelectArea("TRB")
	DbGoTop()
	Do While !Eof()
		if _cTpRet == "M"
			_nRet := TRB->ZD4_MEDIA
		else
			_nRet := TRB->ZD4_TOLERA
		endif
		TRB->(DbSkip())
	Enddo
	TRB->(DbCloseArea())

return(_nRet )

user function ob_HENTrab(_cF, _cM,_sDIni, _sDFim, _cCc, _cTurno )

	Local _nRet := 0

	cQuery := " SELECT ZD5_DIA,  (CAST(ZD5_QTDHEI AS INTEGER) + (((ZD5_QTDHEI - CAST(ZD5_QTDHEI AS INTEGER))*100) /60)) as ZD5_QTDHEI"
	cQuery += " FROM " + retsqlname ("ZD5") +" AS ZD5 "
	cQuery += " INNER JOIN " + retsqlname ("ZD4") +" AS ZD4 ON ZD4_DATA = ZD5_DATA AND ZD4_CC = ZD5_CC "
	cQuery += " AND ZD4_TURNO = ZD5_TURNO AND ZD4.D_E_L_E_T_ = '' AND ZD4_SALFIM = 'M' "
	cQuery += " WHERE ZD5.D_E_L_E_T_ = '' AND ZD5_CC = '"+_cCc+"' AND ZD5_TURNO = '"+_cTurno+"'
	cQuery += " AND ZD5_DIA between '"+_sDIni+"' and '"+_sDFim+"' AND ZD5_TPEVEN = '1' "

	TcQuery cQuery New ALIAS "TRB"
	DbSelectArea("TRB")
	DbGoTop()
	Do While !Eof()
		if u_ob_lTAfa(_cF, _cM, TRB->ZD5_DIA) .OR. u_ob_lTApo(_cF, _cM, TRB->ZD5_DIA)
			_nRet += TRB->ZD5_QTDHEI
		endif
		DbSelectArea("TRB")
		TRB->(DbSkip())
	Enddo
	TRB->(DbCloseArea())

return(_nRet)

user function ob_lTAfa(_cF1, _cM1, _sDia1)
	Local _lRet2 := .F.
	cQuery := " SELECT count(*) as CONT FROM " + retsqlname ("SR8") +" AS SR8 "
	cQuery += " WHERE SR8.D_E_L_E_T_ = '' AND (('"+_sDia1+"' BETWEEN R8_DATAINI AND R8_DATAFIM) "
	cQuery += " OR (R8_DATAINI <= '"+_sDia1+"' AND R8_DATAFIM = '')) "
	cQuery += " AND R8_MAT = '"+_cM1+"' AND R8_FILIAL = '"+_cF1+"' "

	TcQuery cQuery New ALIAS "TRBU"
	DbSelectArea("TRBU")
	DbGoTop()
	Do While !Eof()
		if TRBU->CONT > 0
			_lRet2 := .T.
		endif
		TRBU->(DbSkip())
	Enddo
	TRBU->(DbCloseArea())
return(_lRet2)


user function ob_lTApo(_cF2, _cM2, _sDia2)
	Local _lRet3 := .F.
	cQuery := " SELECT count(*) as CONT FROM " + retsqlname ("SPC") +" AS SPC "
	cQuery += " WHERE SPC.D_E_L_E_T_ = '' AND PC_DATA = '"+_sDia2+"' AND (PC_PDI <> '' OR PC_ABONO <> '') "
	cQuery += " AND PC_MAT = '"+_cM2+"' AND PC_FILIAL = '"+_cF2+"' "

	TcQuery cQuery New ALIAS "TRBK"
	DbSelectArea("TRBK")
	DbGoTop()
	Do While !Eof()
		if TRBK->CONT > 0
			_lRet3 := .T.
		endif
		TRBK->(DbSkip())
	Enddo
	TRBK->(DbCloseArea())

return(_lRet3)

user function ob_cTrRp(_cCc, _cTurno, _sFim)
	Local _cRet := ""
	//query para encontrar regra para o centro de custo e turno do funcionario

	_cQuery := " SELECT ZD4_SALFIM"
	_cQuery += " FROM " + RETSQLNAME ("ZD4") +" AS ZD4  "
	_cQuery += " WHERE ZD4.D_E_L_E_T_ = '' "
	_cQuery += " AND ZD4_DATA = '"+_sFim+"' "
	_cQuery += " AND ZD4_CC = '"+_cCc+"' and ZD4_TURNO = '"+_cTurno+"' "

	tcquery _cQuery new alias _trbb
	do while ! _trbb -> (eof ())
		_cRet := _trbb->ZD4_SALFIM 
		dbSelectArea("_trbb")
		dbSkip()
	enddo
	dbSelectArea("_trbb")
	_trbb->(DbCloseArea())

return(_cRet)
