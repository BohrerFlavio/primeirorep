#INCLUDE "TOPCONN.CH"
#INCLUDE 'Protheus.ch'
#INCLUDE "rwmake.ch"
/*
Criação do ponto de Entrada PNAPOSPC, para que após as gravações dos registros dos apontamentos na tabela SPC, 
possa ser alterada a tabela, de acordo com a filial e matrícula posicionada.
*/
User Function PNAPOSPC()

	Local _aSave   := GetArea()
	private _cFil  := PARAMIXB[1]
	private _cMat  := PARAMIXB[2]
	private _sInicio :=SUBSTR(GETMV("MV_PONMES"),1,8)
	private _sFim    :=SUBSTR(GETMV("MV_PONMES"),10,8)
	Private _sIniTab    := dtos(aTabCalend[1][1])
	Private _sFinalTab  := dtos(aTabCalend[len(aTabCalend)][48])
	private _cPdFalta  := "409" //código do evento de hora falta
	private _cPdSaiAnt := "463" //código do evento de saída antecipada
	private _cPdBco     := "501"
	private _cPdTrRoupa := "017"
	Private _cCc    :=  ""
	Private _cTurno :=  ""
	Private _cFalta := ""
	Private _cSAnt  := ""
	Private _lTemReg := .F.

	if (SM0->M0_CODIGO == "01" .and. _cFil == "00") .or. SM0->M0_CODIGO == "08"
		if _sInicio == _sIniTab // somente faz as regras se o período selicionado é igual ao ponmes
			if _trazBH() == "S"
				//traz centro de custo e turno do funcionário
				_cCCTurno()
				if !empty(_cCc) .and. !empty(_cTurno)
					//tive que colocar novamente uma rotina que limpe as trocas de roupas e o banco de horas antes de apontar novamente
					//porque o ponto de entrada ponapo4 deixou de funcionar, não limpando mais os abonos quando executado apontamento pela miscelania
					//imagino que tenha um array que guarde os abonos ao entrar nos apontamentos e depois grave novamente
					_limpa()
					_Regra()
				endif
			endif
		endif
	endif

	RestArea(_aSave)

Return

static function _cCCTurno()
	Local _aSave1   := GetArea()
	_cCc    := ""
	_cTurno := ""
	_cQuery := " SELECT TOP 1 PC_CC, PC_TURNO "
	_cQuery += " FROM " + RETSQLNAME ("SPC") +" AS SPC  "
	_cQuery += " INNER JOIN " + RETSQLNAME ("SRA") +" AS SRA ON RA_FILIAL = PC_FILIAL AND RA_MAT = PC_MAT "
	_cQuery += " AND RA_ACUMBH = 'S' AND SRA.D_E_L_E_T_ = '' "
	_cQuery += " WHERE SPC.D_E_L_E_T_ = '' AND PC_FILIAL = '"+_cFil+"' AND PC_MAT = '"+_cMat+"'  "
	_cQuery += " AND PC_DATA BETWEEN '"+_sInicio+"' AND '"+_sFim+"' "
	_cQuery += " ORDER BY PC_DATA DESC "

	tcquery _cQuery new alias _trba
	do while ! _trba -> (eof ())
		_cCc    := _trba->PC_CC
		_cTurno := _trba->PC_TURNO
		dbSelectArea("_trba")
		dbSkip()
	enddo
	dbSelectArea("_trba")
	_trba->(DbCloseArea())
	RestArea(_aSave1)
return()

static function _excZD1(_dData)
	Local _lRet := .F.
	Local _aSave2   := GetArea()
	_cQuery2 := " SELECT COUNT(*) AS CONTAD "
	_cQuery2 += " FROM " + RETSQLNAME ("ZD1") +" AS ZD1 "
	_cQuery2 += " WHERE ZD1.D_E_L_E_T_ = '' AND ZD1_MAT = '"+_cMat+"'  "
	_cQuery2 += " AND ZD1_DATA = '"+dtos(_dData)+"' "

	tcquery _cQuery2 new alias _trbc
	do while ! _trbc -> (eof ())
		if _trbc->CONTAD > 0
			_lRet := .T.
		endif
		dbSelectArea("_trbc")
		dbSkip()
	enddo
	dbSelectArea("_trbc")
	_trbc->(DbCloseArea())
	RestArea(_aSave2)
return(_lRet)

static function _Regra()

	Local _cQuery := ""
	Local _aRegra := {}
	Local _aSave3   := GetArea()
	//query para encontrar regra para o centro de custo e turno do funcionário

	_cQuery := " SELECT ZD4_SANTEC, ISNULL(ZD5_DIA,'') AS DIA, ISNULL(ZD5_TPEVEN,'') AS TPEVEN "
	_cQuery += " FROM " + RETSQLNAME ("ZD4") +" AS ZD4  "
	_cQuery += " LEFT JOIN " + RETSQLNAME ("ZD5") +" AS ZD5 ON ZD4_TURNO = ZD5_TURNO AND ZD4_CC = ZD5_CC AND ZD4_DATA = ZD5_DATA AND (ZD5_TPEVEN = '2' OR ZD5_TPEVEN = '3') AND ZD5.D_E_L_E_T_ = ''"
	_cQuery += " WHERE ZD4.D_E_L_E_T_ = '' "
	_cQuery += " AND ZD4_DATA = '"+_sFim+"' "
	_cQuery += " AND ZD4_CC = '"+_cCc+"' and ZD4_TURNO = '"+_cTurno+"' "
	_cQuery += " ORDER BY ZD5_DIA "

	tcquery _cQuery new alias _trbb
	do while ! _trbb -> (eof ())
		_cSAnt  := _trbb->ZD4_SANTEC
		if !empty(_trbb->DIA) .and. !empty(_trbb->TPEVEN)
			aadd(_aRegra, {_trbb->DIA, _trbb->TPEVEN })
		endif
		_lTemReg := .T.
		dbSelectArea("_trbb")
		dbSkip()
	enddo
	dbSelectArea("_trbb")
	_trbb->(DbCloseArea())

	if _lTemReg
		DbSelectArea("SPC")
		DbSetOrder(2)
		DbSeek(_cFil+ _cMat + _sInicio , .T.)

		do while !eof() .and. SPC->PC_FILIAL == _cFil .and. SPC->PC_MAT == _cMat .AND. DTOS(SPC->PC_DATA) <= _sFim

			if (SPC->PC_PD == _cPdFalta .or. SPC->PC_PD == _cPdSaiAnt) .and. empty(SPC->PC_ABONO) .and. empty(SPC->PC_PDI) .and. !_excZD1(SPC->PC_DATA)
				_nPos := ASCAN(_aRegra, {|x|x[1] == DTOS(SPC->PC_DATA)})
				if _nPos > 0
					if _aRegra[_nPos][2] == "2"
						dbSelectArea("SPC")
						RecLock( "SPC" , .F. , .F. )
						SPC->PC_PDI    := _cPdBco
						SPC->PC_QUANTI := SPC->PC_QUANTC
						MsUnLock()
					endif
					if _aRegra[_nPos][2] == "3" .and. (empty(SPC->PC_ABONO) .or. SPC->PC_ABONO == _cPdTrRoupa)
						dbSelectArea("SPC")
						RecLock( "SPC" , .F. , .F. )
						SPC->PC_ABONO   := _cPdTrRoupa
						SPC->PC_QTABONO := SPC->PC_QUANTC
						MsUnLock()
						_gravaZBC(SPC->PC_DATA, SPC->PC_QUANTC)
						dbSelectArea("SPK")
						RecLock('SPK',.T.)
						SPK->PK_FILIAL  := _cFil
						SPK->PK_MAT     := _cMat
						SPK->PK_CODABO  := _cPdTrRoupa
						SPK->PK_CODEVE  := SPC->PC_PD
						SPK->PK_DATA    := SPC->PC_DATA
						SPK->PK_HRSABO  := SPC->PC_QUANTC
						SPK->PK_CC      := SPC->PC_CC
						SPK->PK_FLAG    := "I"
						SPK->(MsUnLock())
					endif
				endif
			endif
			if SPC->PC_PD == _cPdSaiAnt .and. empty(SPC->PC_ABONO) .and. empty(SPC->PC_PDI) .and. !_excZD1(SPC->PC_DATA)
				if _cSAnt == "S"
					dbSelectArea("SPC")
					RecLock( "SPC" , .F. , .F. )
					SPC->PC_PDI    := _cPdBco
					SPC->PC_QUANTI := SPC->PC_QUANTC
					MsUnLock()
				elseif _cSAnt == "N" .and. (empty(SPC->PC_ABONO) .or. SPC->PC_ABONO == _cPdTrRoupa)
					dbSelectArea("SPC")
					RecLock( "SPC" , .F. , .F. )
					SPC->PC_ABONO   := _cPdTrRoupa
					SPC->PC_QTABONO := SPC->PC_QUANTC
					MsUnLock()
					_gravaZBC(SPC->PC_DATA, SPC->PC_QUANTC)
					dbSelectArea("SPK")
					RecLock('SPK',.T.)
					SPK->PK_FILIAL  := _cFil
					SPK->PK_MAT     := _cMat
					SPK->PK_CODABO  := _cPdTrRoupa
					SPK->PK_CODEVE  := SPC->PC_PD
					SPK->PK_DATA    := SPC->PC_DATA
					SPK->PK_HRSABO  := SPC->PC_QUANTC
					SPK->PK_CC      := SPC->PC_CC
					SPK->PK_FLAG    := "I"
					SPK->(MsUnLock())
				endif
			endif
			dbSelectArea("SPC")
			dbSkip()
		enddo
	endif
	RestArea(_aSave3)
return()

static function _gravaZBC(_dData, _nHrs6)
	Local _nHrs5 := round(fConvHr(_nHrs6, 'D'), 2)
	Local _aSave4   := GetArea()
	dbSelectArea("ZBC")
	reclock('ZBC',.T.)
	ZBC->ZBC_FILIAL := _cFil
	ZBC->ZBC_MAT    := _cMat
	ZBC->ZBC_DTREF  := _dData
	ZBC->ZBC_HRBAIX := _nHrs5
	ZBC->ZBC_APONTA := 'P'
	msunlock()

	if ZBB->(dbSeek(xFilial('ZBB') + _cMat))
		_nHrZBC := ZBC->ZBC_HRBAIX
		_nHrZBB  := ZBB->ZBB_SLDATU - _nHrZBC
		_nHrAZBB := ZBB->ZBB_SLDANT - _nHrZBC
		dbSelectArea("ZBB")
		reclock('ZBB',.f.)
		ZBB->ZBB_SLDATU := _nHrZBB
		ZBB->ZBB_SLDANT := _nHrAZBB
		msunlock()
	else
		dbSelectArea("ZBB")
		reclock('ZBB',.T.)
		ZBB->ZBB_FILIAL := _cFil
		ZBB->ZBB_MAT 	:= _cMat
		ZBB->ZBB_CC     := alltrim(_cCc)
		ZBB->ZBB_SLDATU := _nHrs5*-1
		ZBB->ZBB_SLDANT := 0
		ZBB->ZBB_ULTPER := GETMV('MV_PAPONTA')
		msunlock()
	endif
	RestArea(_aSave4)
return


static function _trazBH()
	Local _cBH := ""
	Local _aSave5   := GetArea()
	//query para encontrar se funcionário tem banco de horas
	_cQuery := " SELECT RA_BHFOL "
	_cQuery += " FROM " + RETSQLNAME ("SRA") +" AS SRA "
	_cQuery += " WHERE SRA.D_E_L_E_T_ = '' "
	_cQuery += " AND RA_FILIAL = '"+_cFil+"' "
	_cQuery += " AND RA_MAT = '"+_cMat+"' "

	tcquery _cQuery new alias _trbb
	do while ! _trbb -> (eof ())
		_cBH  := _trbb->RA_BHFOL
		dbSelectArea("_trbb")
		dbSkip()
	enddo
	dbSelectArea("_trbb")
	_trbb->(DbCloseArea())
	RestArea(_aSave5)
return(_cBH)

static function _limpa()

	DbSelectArea("SPC")
	DbSetOrder(2)
	DbSeek(_cFil+ _cMat + _sInicio , .T.)
	do while !eof() .and. SPC->PC_FILIAL == _cFil .and. SPC->PC_MAT == _cMat .AND. DTOS(SPC->PC_DATA) <= _sFim
		if SPC->PC_PDI == _cPdBco
			DbSelectArea("SPC")
			RecLock( "SPC" , .F. , .F. )
			SPC->PC_PDI    := ''
			SPC->PC_QUANTI := 0
			MsUnLock()
		endif
		if SPC->PC_ABONO == _cPdTrRoupa
			DbSelectArea("SPC")
			RecLock( "SPC" , .F. , .F. )
			SPC->PC_ABONO   := ''
			SPC->PC_QTABONO := 0
			MsUnLock()
		endif
		dbSelectArea("SPC")
		dbSkip()
	enddo
	dbSelectArea("SPK")
	DbSetOrder(1)
	DbSeek(_cFil+ _cMat + _sInicio , .T.)
	do while !eof() .and. SPK->PK_FILIAL == _cFil .and. SPK->PK_MAT == _cMat .AND. DTOS(SPK->PK_DATA) <= _sFim
		if SPK->PK_CODABO == _cPdTrRoupa
			DbSelectArea("SPK")
			RecLock("SPK",.F.)
			DbDelete()
			MsUnLock()
		endif
		dbSelectArea("SPK")
		dbSkip()
	enddo


return()
/*
Local _cFil  := PARAMIXB[1]
Local _cMat  := PARAMIXB[2]
//MsgAlert("Filial: "+_cFil + " Matricula: " + _cMat)
Local _aDias := {}

Local _aSave := GetArea()
Local _dInicio :=SUBSTR(GETMV("MV_PONMES"),1,8)
Local _dFim    :=SUBSTR(GETMV("MV_PONMES"),10,8)

private _cPdFalJus  := "410" //código do evento de hora falta justificada
private _cPdFalta  := "409" //código do evento de hora falta		
private _cPdCpFalta := "203" //código do evento de compensação de faltas	
private _cPdAcordo  := "015" //código do evento de geração do banco de horas troca de roupa

//Ajuste feito por Flávio dia 06/05/2019
//Solicitado Pelo Dyeison para incluir empresa transportadora

//if SM0->M0_CODIGO == "01" 
if SM0->M0_CODIGO == "01" .OR. SM0->M0_CODIGO == "07"
DbSelectArea("SPC")
DbSetOrder(1)
dbGoTop()
if DbSeek(_cFil+ _cMat)
do while !eof() .AND. SPC->PC_FILIAL == _cFil .AND. SPC->PC_MAT == _cMat

if (SPC->PC_PD == _cPdAcordo .or. SPC->PC_PD == _cPdCpFalta) .and. DTOS(SPC->PC_DATA) >= _dInicio .AND. DTOS(SPC->PC_DATA) <= _dFim
if ASCAN(_aDias, SPC->PC_DATA) == 0
aadd(_aDias, SPC->PC_DATA)
endif
endif		
DbSelectArea("SPC")
DbSetOrder(1)
dbSkip()
enddo
endif		
DbSelectArea("SPC")
DbSetOrder(1)
dbGoTop()
if DbSeek(_cFil+ _cMat)
do while !eof() .AND. SPC->PC_FILIAL == _cFil .AND. SPC->PC_MAT == _cMat
if SPC->PC_PD == _cPdFalta .and. empty(SPC->PC_PDI) .and. empty(SPC->PC_ABONO) .and. ASCAN(_aDias, SPC->PC_DATA) > 0 .AND. DTOS(SPC->PC_DATA) >= _dInicio .AND. DTOS(SPC->PC_DATA) <= _dFim
RecLock( "SPC" , .F. , .F. )
SPC->PC_PDI :=_cPdFalJus
SPC->PC_QUANTI := SPC->PC_QUANTC
MsUnLock()
endif		
DbSelectArea("SPC")
DbSetOrder(1)
dbSkip()
enddo			
endif
endif
RestArea(_aSave)

Return
*/
