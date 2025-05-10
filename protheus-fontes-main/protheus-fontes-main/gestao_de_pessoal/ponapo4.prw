/*FS
Ponto de entrada utilizado para gerar eventos de compensações nas horas extras e faltas
na tabela SPC conforme cadastro de regras na tabela ZD0/ZD1
Autor: André R. Lerner - 8bit Soluções em TI
Data: março 2018
*/
#INCLUDE "TOPCONN.CH"
#INCLUDE 'Protheus.ch'
#INCLUDE "rwmake.ch"
User Function PonaPo4()
	//Local __aMarcacoes  := aClone( ParamIxb[1] )
	Local __aTabCalend  := aClone( ParamIxb[2] )
	Local _aSaveA3  := GetArea()
	local _cPdBco   := "501"

	// Realiza o backup do order e recno da SPC e SPK
	Local nOrderSPC	:= SPC->( indexOrd() )
	Local nRecnoSPC	:= SPC->( recno() )

	Local nOrderSPK	:= SPK->( indexOrd() )
	Local nRecnoSPK	:= SPK->( recno() )

	Private _cMatri	:= SRA->RA_MAT
	Private _cFilial  := SRA->RA_FILIAL

	private _cPdExtra1 := "105" //código do evento de hora extra
	private _cPdExtra2 := "109" //código do evento de hora extra noturna
	private _cPdExtra3 := "107" //código do evento de hora extra compensado
	private _cPdDescBen:= "800" //código do evento para gerar desconto benefício
	private _cPdEvNoti := "802" //código do evento para notificação
	private _cAbTr     := "017" //evento troca de roupa.
	

	Private _cCc     := SRA->RA_CC

	Private _cSeqTur := SRA->RA_SEQTURN

	Private _sIni    := dtos(__aTabCalend[1][1])
	Private _sFinal  := dtos(__aTabCalend[len(__aTabCalend)][48])
	Private _cTurno  := u_ob_cTurno(SRA->RA_FILIAL, SRA->RA_MAT, _sFinal )

	if _sIni == SUBSTR(GETMV("MV_PONMES"),1,8)

		if (SM0->M0_CODIGO == "01" .and. _cFilial == "00") .or. SM0->M0_CODIGO == "08"
			if _trazBH() == "S"
				DbSelectArea("SPC")
				DbSetOrder(2)
				DbSeek(_cFilial+ _cMatri + _sIni , .T.)
				do while !eof() .and. SPC->PC_FILIAL == _cFilial .and. SPC->PC_MAT == _cMatri .AND. DTOS(SPC->PC_DATA) <= _sFinal
					if SPC->PC_PDI == _cPdBco
						DbSelectArea("SPC")
						RecLock( "SPC" , .F. , .F. )
						SPC->PC_PDI    := ''
						SPC->PC_QUANTI := 0
						MsUnLock()
					endif
					if SPC->PC_ABONO == _cAbTr
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
				DbSeek(_cFilial+ _cMatri + _sIni , .T.)
				do while !eof() .and. SPK->PK_FILIAL == _cFilial .and. SPK->PK_MAT == _cMatri .AND. DTOS(SPK->PK_DATA) <= _sFinal
					if SPK->PK_CODABO == _cAbTr
						DbSelectArea("SPK")
						RecLock("SPK",.F.)
						DbDelete()
						MsUnLock()
					endif
					dbSelectArea("SPK")
					dbSkip()
				enddo
				Private __aResult  := aClone( aEventos )
				_gDescBen() //gera desconto benefício caso funcionário não cumpriu horário
				_gEvNoti()  //gera evento nofificação

				aEventos := aClone( __aResult )
				_limpaZBC()
			endif
		endif
	endif
	RestArea(_aSaveA3)
	// Restaura a ordem e recno
	SPC->( dbSetOrder( nOrderSPC ) )
	SPC->( dbGoTo( nRecnoSPC ) )

	SPK->( dbSetOrder( nOrderSPK ) )
	SPK->( dbGoTo( nRecnoSPK ) )

Return( NIL )

static function _trazBH()
	Local _cBH := ""
	//query para encontrar se funcionário tem banco de horas
	_cQuery := " SELECT RA_BHFOL "
	_cQuery += " FROM " + RETSQLNAME ("SRA") +" AS SRA "
	_cQuery += " WHERE SRA.D_E_L_E_T_ = '' "
	_cQuery += " AND RA_FILIAL = '"+_cFilial+"' "
	_cQuery += " AND RA_MAT = '"+_cMatri+"' "

	tcquery _cQuery new alias _trbb
	do while ! _trbb -> (eof ())
		_cBH  := _trbb->RA_BHFOL
		dbSelectArea("_trbb")
		dbSkip()
	enddo
	dbSelectArea("_trbb")
	_trbb->(DbCloseArea())
return(_cBH)


static function _gDescBen()
	Local _nx6 := 0
	Local _nHrsExt := 0
	_cQuery3 := " SELECT ZD5_DIA, (CAST(ZD5_QTDHEI AS INTEGER) + (((ZD5_QTDHEI - CAST(ZD5_QTDHEI AS INTEGER))*100) /60)) as ZD5_QTDHEI "
	_cQuery3 += " FROM " + RETSQLNAME ("ZD5") +" AS ZD5 "
	_cQuery3 += " INNER JOIN " + RETSQLNAME ("ZD4") +" AS ZD4 ON ZD4_DATA = ZD5_DATA AND ZD4_CC = ZD5_CC "
	_cQuery3 += " AND ZD4_TURNO = ZD5_TURNO AND ZD4.D_E_L_E_T_ = '' AND ZD4_DESCBE = 'S' "
	_cQuery3 += " WHERE ZD5.D_E_L_E_T_ = '' AND ZD5_CC = '"+_cCc+"' AND ZD5_TURNO = '"+_cTurno+"' "
	_cQuery3 += " AND ZD5_DIA between '"+_sIni+"' and '"+_sFinal+"' AND ZD5_TPEVEN = '1' "

	tcquery _cQuery3 new alias _trbd
	do while ! _trbd -> (eof ())
		_nHrsExt := 0
		if !u_ob_lTAfa(_cFilial, _cMatri, _trbd->ZD5_DIA) .and. !u_ob_lTApo(_cFilial, _cMatri, _trbd->ZD5_DIA)
			for _nx6:=1 to len( __aResult )
				if _trbd->ZD5_DIA == dtos(__aResult[_nx6][1]) .and. ;
						(__aResult [_nx6][2] == _cPdExtra1 .or.  __aResult [_nx6][2] == _cPdExtra2 .or.  __aResult [_nx6][2] == _cPdExtra3)
					_nHrsExt += fConvHr(__aResult[_nx6][3],'D')
				endif
			next
			if !_lTemExc(_trbd->ZD5_DIA) .and. _trbd->ZD5_QTDHEI > _nHrsExt .and. _lAtFunc(_trbd->ZD5_DIA)
				_geraSPC(stod(_trbd->ZD5_DIA), fConvHr(_trbd->ZD5_QTDHEI,'H'), _cPdDescBen, _cCc, _cTurno, _cSeqTur)
			endif
		endif
		dbSelectArea("_trbd")
		dbSkip()
	enddo
	dbSelectArea("_trbd")
	_trbd->(DbCloseArea())
return()


/*
Verifica se teve notificação no período
*/
static function _gEvNoti()
	Local _aSaveA3 := GetArea()
	Local _cQuery := ""

	_cQuery := " SELECT ZD2_DTANOT "
	_cQuery += " FROM " + RETSQLNAME ("ZD2") +" AS ZD2 "
	_cQuery += " WHERE ZD2.D_E_L_E_T_ = '' AND ZD2_MAT = '"+_cMatri+"' AND ZD2_FILFUN = '"+_cFilial+"' "
	_cQuery += " AND ZD2_DTANOT BETWEEN '"+_sIni+"' AND '"+_sFinal+"' "

	tcquery _cQuery new alias _trbb

	do while !_trbb->(eof())
		_geraSPC(stod(_trbb->ZD2_DTANOT), 1, _cPdEvNoti, _cCc, _cTurno, _cSeqTur)
		dbSelectArea("_trbb")
		dbSkip()
	enddo
	dbSelectArea("_trbb")
	_trbb->(DbCloseArea())
	RestArea(_aSaveA3)
return()

/*
Se funcionário está cadastrado na exceção
*/
static function _lTemExc(_sD)
	Local _aSaveA3 := GetArea()
	Local _lRet1 := .F.

	_cQuery3 := " SELECT COUNT(*) AS QTDE FROM " + RETSQLNAME ("ZD1") +" AS ZD1 "
	_cQuery3 += " WHERE ZD1.D_E_L_E_T_ = '' AND ZD1_MAT = '"+_cMatri+"' AND ZD1_DATA = '"+_sD+"' "
	tcquery _cQuery3 new alias _trbi

	do while !_trbi->(eof())
		if _trbi->QTDE > 0
			_lRet1 := .T.
		endif
		dbSelectArea("_trbi")
		dbSkip()
	enddo
	dbSelectArea("_trbi")
	_trbi->(DbCloseArea())
	RestArea(_aSaveA3)
return(_lRet1)


/*
Se funcionário está cadastrado na exceção
*/
static function _lAtFunc(_sD)
	Local _aSaveA3 := GetArea()
	Local _lRet1 := .F.

	_cQuery3 := " SELECT COUNT(*) AS QTDE FROM " + RETSQLNAME ("SRA") +" AS SRA "
	_cQuery3 += " WHERE SRA.D_E_L_E_T_ = '' AND RA_MAT = '"+_cMatri+"' AND RA_FILIAL = '"+_cFilial+"' AND RA_ADMISSA <= '"+_sD+"' AND (RA_DEMISSA  = '' OR RA_DEMISSA >= '"+_sD+"' ) "
	tcquery _cQuery3 new alias _trbi

	do while !_trbi->(eof())
		if _trbi->QTDE > 0
			_lRet1 := .T.
		endif
		dbSelectArea("_trbi")
		dbSkip()
	enddo
	dbSelectArea("_trbi")
	_trbi->(DbCloseArea())
	RestArea(_aSaveA3)
return(_lRet1)


/*
Limpa tabela ZBC banco de horas
*/
static function _limpaZBC()
	ZBB->(dbSetOrder(1))
	ZBB->(dbSeek(_cFilial + _cMatri))
	ZBC->(dbSetOrder(1))
	ZBC->(dbGoTop())
	if ZBC->(dbSeek(_cFilial + _cMatri))
		do while ZBC->(!eof()) .and. ALLTRIM(ZBC->ZBC_MAT) == ALLTRIM(_cMatri)
			if dtos(ZBC->ZBC_DTREF) >= _sIni .and. dtos(ZBC->ZBC_DTREF) <= _sFinal .and. ZBC->ZBC_APONTA == 'P'
				_nHrZBC := ZBC->ZBC_HRBAIX
				DbSelectArea("ZBC")
				reclock('ZBC',.F.)
				dbdelete()
				msunlock()

				_nHrZBB  := ZBB->ZBB_SLDATU + _nHrZBC
				_nHrAZBB := ZBB->ZBB_SLDANT + _nHrZBC
				DbSelectArea("ZBB")
				reclock('ZBB',.f.)
				ZBB->ZBB_SLDATU := _nHrZBB
				ZBB->ZBB_SLDANT := _nHrAZBB
				msunlock()

			endif
			ZBC->(dbSkip())
		enddo
	endif

return

static function _geraSPC(_dDt1, _nHr1, _cEv1, _cCc1, _cTurno1, _cSeq1)

	fGeraRes( __aResult ,;  //01 -> Array com os Resultados do Dia
	_dDt1                 ,;  //02 -> Data da Geracao
	_nHr1                 ,;  //03 -> Numero de Horas Resultantes
	_cEv1                 ,;  //04 -> Codigo do Evento
	_cCc1                 ,;  //05 -> Centro de Custo a ser Gravado
	NIL                   ,; //06 -> Tipo de Marcacao
	.F.                   ,; //07 -> True para Acumular as Horas
	NIL                   ,; //08 -> Periodo de Apuracao
	NIL                   ,; //09 -> Tolerancia
	NIL                   ,; //10 -> Tipo de Arredondamento a Ser Utilizado
	.T.                   ,; //11 -> Substitui a(s) Hora(s) Existente(s) ( Garanto Apenas 1 DSR por Data )
	,; //12 -> Funcao
	,; //13 -> Depto para gravacao
	,; //14 -> Posto para gravacao
	,; //15 -> Periodo para Gravacao
	,; //16 -> Processo para Gravacao
	,; //17 -> Periodo para Gravacao
	,; //18 -> NumPagto para Gravacao
	_cTurno1    ,; //19 -> Turno de Trabalho
	_cSeq1      ;  //20 -> Semana/Sequencia do Turno
	)
return()


	/*
	Local _aSaveA3 := GetArea()
	Local _aRegra  := {}
	Local _aPerACP := {}
	Local _nQtde   := 0
	Local _nProcPd := 0
	Local __aTabCalend  := aClone( ParamIxb[2] )

	Private _cInicio := dtos(__aTabCalend[1][1])
	Private _cFim    := dtos(__aTabCalend[len(__aTabCalend)][48])
	Private _cMatri  := SRA->RA_MAT
	Private _cFilial := SRA->RA_FILIAL
	Private _cCc     := SRA->RA_CC
	Private _cTurno  := SRA->RA_TNOTRAB
	Private _cSeqTur := SRA->RA_SEQTURN
	Private _nx  := 1
	Private _nx2 := 1
	Private __aResult := aClone( aEventos )
	private _cPdExtra1 := "105" //código do evento de hora extra
	private _cPdExtra3 := "107" //código do evento de hora extra compensado
	private _cPdExtra2 := "109" //código do evento de hora extra noturna
	private _cPdFalta  := "409" //código do evento de hora falta	
	private _cPdDsr     := "465" //código do evento de desconto DSR
	private _cPdCpEx    := "403" //código do evento de compensação de horas extras
	private _cPdCpFalta := "203" //código do evento de compensação de faltas
	private _cPdAcordo  := "015" //código do evento de geração do banco de horas troca de roupa
	private _cPdSaiAnt  := "463" //código do evento de saída antecipada
	private _cPdCpAtest := "204" //código do evento de compensação de atestado
	private _cPdDescBen := "800" //código do evento para gerar desconto benefício
	private _cPdEvNC    := "801" //código do evento para não cumprimento do compensação
	private _cPdEvNoti  := "802" //código do evento para notificação
	private _cPdHrsNorm := "996" //código do evento para horas normais

	if (SM0->M0_CODIGO == "01" .and. _cFilial == "00") .or. SM0->M0_CODIGO == "08"
	_gCompHE()  //gera compensações de horas extras e faltas
	_vCompPA()  //procuro compensações para o primeiro sábado do período
	_gCompAt()  // gera compensação por atestado caso tenha que fazer HE de compensação no dia do atestado
	_limpaZBC() //limpa banco de horas troca de roupa
	_gCompSA()  //gera compensações de saída antecipada
	_gDescBen() //gera desconto benefício caso funcionário não cumpriu horário
	_gEvNCH()   //gera evento de não cumpriu horário compensação
	//if SM0->M0_CODIGO == "01"
	_gBH()      //gera banco de horas troca de roupa
	//endif
	_gEvNoti()  //gera evento nofificação
	aEventos := aClone( __aResult )
	endif
	RestArea(_aSaveA3)

	Return( NIL )

	//Gera apontamento

static function _geraSPC(_dDt1, _nHr1, _cEv1, _cCc1, _cTurno1, _cSeq1)

	fGeraRes( __aResult ,;  //01 -> Array com os Resultados do Dia
	_dDt1                 ,;  //02 -> Data da Geracao
	_nHr1                 ,;  //03 -> Numero de Horas Resultantes
	_cEv1                 ,;  //04 -> Codigo do Evento
	_cCc1                 ,;  //05 -> Centro de Custo a ser Gravado
	NIL                   ,; //06 -> Tipo de Marcacao
	.F.                   ,; //07 -> True para Acumular as Horas
	NIL                   ,; //08 -> Periodo de Apuracao
	NIL                   ,; //09 -> Tolerancia
	NIL                   ,; //10 -> Tipo de Arredondamento a Ser Utilizado
	.T.                   ,; //11 -> Substitui a(s) Hora(s) Existente(s) ( Garanto Apenas 1 DSR por Data )
	,; //12 -> Funcao
	,; //13 -> Depto para gravacao
	,; //14 -> Posto para gravacao
	,; //15 -> Periodo para Gravacao
	,; //16 -> Processo para Gravacao
	,; //17 -> Periodo para Gravacao
	,; //18 -> NumPagto para Gravacao
	_cTurno1    ,; //19 -> Turno de Trabalho
	_cSeq1      ;  //20 -> Semana/Sequencia do Turno
	)
	return()

	//Busca compensações do período anterior

static function _BuscaCP (_dDataI, _dDataF, _dDataIS, _dDataFS )
	Local _aRetPA := {}
	Local _aSaveA2 := GetArea()
	Local _sRetDtCp:= ""

	_cQuery := " SELECT ISNULL(sum(CAST(PC_QUANTC AS INT)+(((PC_QUANTC - CAST(PC_QUANTC AS INT)) /60) *100)),0) AS PC_QUANTC, PC_DATA, "
	_cQuery += " ZD0_DATAC2, ZD0_DATAC3, ZD0_DATAC4, ZD0_DATAC5, ZD0_DATAC6, ZD0_DATAC7 "
	_cQuery += " FROM " + RETSQLNAME ("SPC") +" AS SPC "
	_cQuery += " INNER JOIN " + RETSQLNAME ("ZD0") +" AS ZD0 ON ZD0_CC = PC_CC AND ZD0_TURNO = PC_TURNO AND ZD0.D_E_L_E_T_ = '' "
	_cQuery += " AND (ZD0_DATAC2 BETWEEN '"+dtos(_dDataIS)+"' AND '"+dtos(_dDataFS)+"' or ZD0_DATAC3 BETWEEN '"+dtos(_dDataIS)+"' AND '"+dtos(_dDataFS)+"' "
	_cQuery += " or ZD0_DATAC4 BETWEEN '"+dtos(_dDataIS)+"' AND '"+dtos(_dDataFS)+"' or ZD0_DATAC5 BETWEEN '"+dtos(_dDataIS)+"' AND '"+dtos(_dDataFS)+"' "
	_cQuery += " or ZD0_DATAC6 BETWEEN '"+dtos(_dDataIS)+"' AND '"+dtos(_dDataFS)+"' or ZD0_DATAC7 BETWEEN '"+dtos(_dDataIS)+"' AND '"+dtos(_dDataFS)+"')
	_cQuery += " WHERE SPC.D_E_L_E_T_ = '' AND PC_DATA BETWEEN '"+dtos(_dDataI)+"' AND '"+dtos(_dDataF)+"' "
	_cQuery += " AND PC_MAT = '"+_cMatri+"' AND PC_FILIAL = '"+_cFilial+"' AND PC_PD = '"+_cPdCpEx+"' "
	_cQuery += " GROUP BY PC_DATA, ZD0_DATAC2, ZD0_DATAC3, ZD0_DATAC4, ZD0_DATAC5, ZD0_DATAC6, ZD0_DATAC7 "
	_cQuery += " UNION ALL "
	_cQuery += " SELECT ISNULL(sum(CAST(PH_QUANTC AS INT)+(((PH_QUANTC - CAST(PH_QUANTC AS INT)) /60) *100)),0) AS PC_QUANTC, PH_DATA AS PC_DATA, "
	_cQuery += " ZD0_DATAC2, ZD0_DATAC3, ZD0_DATAC4, ZD0_DATAC5, ZD0_DATAC6, ZD0_DATAC7 "
	_cQuery += " FROM " + RETSQLNAME ("SPH") +" AS SPH "
	_cQuery += " INNER JOIN " + RETSQLNAME ("ZD0") +" AS ZD0 ON ZD0_CC = PH_CC AND ZD0_TURNO = PH_TURNO AND ZD0.D_E_L_E_T_ = '' "
	_cQuery += " AND (ZD0_DATAC2 BETWEEN '"+dtos(_dDataIS)+"' AND '"+dtos(_dDataFS)+"' or ZD0_DATAC3 BETWEEN '"+dtos(_dDataIS)+"' AND '"+dtos(_dDataFS)+"' "
	_cQuery += " or ZD0_DATAC4 BETWEEN '"+dtos(_dDataIS)+"' AND '"+dtos(_dDataFS)+"' or ZD0_DATAC5 BETWEEN '"+dtos(_dDataIS)+"' AND '"+dtos(_dDataFS)+"' "
	_cQuery += " or ZD0_DATAC6 BETWEEN '"+dtos(_dDataIS)+"' AND '"+dtos(_dDataFS)+"' or ZD0_DATAC7 BETWEEN '"+dtos(_dDataIS)+"' AND '"+dtos(_dDataFS)+"')
	_cQuery += " WHERE SPH.D_E_L_E_T_ = '' AND PH_DATA BETWEEN '"+dtos(_dDataI)+"' AND '"+dtos(_dDataF)+"' "
	_cQuery += " AND PH_MAT = '"+_cMatri+"' AND PH_FILIAL = '"+_cFilial+"' AND PH_PD = '"+_cPdCpEx+"' "
	_cQuery += " GROUP BY PH_DATA, ZD0_DATAC2, ZD0_DATAC3, ZD0_DATAC4, ZD0_DATAC5, ZD0_DATAC6, ZD0_DATAC7 "
	tcquery _cQuery new alias _trba
	do while ! _trba -> (eof ())
		if Dow(stod(_trba->PC_DATA)) == 2
	_sRetDtCp:= _trba->ZD0_DATAC2
		elseif Dow(stod(_trba->PC_DATA)) == 3
	_sRetDtCp:= _trba->ZD0_DATAC3
		elseif Dow(stod(_trba->PC_DATA)) == 4
	_sRetDtCp:= _trba->ZD0_DATAC4
		elseif Dow(stod(_trba->PC_DATA)) == 5
	_sRetDtCp:= _trba->ZD0_DATAC5
		elseif Dow(stod(_trba->PC_DATA)) == 6
	_sRetDtCp:= _trba->ZD0_DATAC6
		elseif Dow(stod(_trba->PC_DATA)) == 7
	_sRetDtCp:= _trba->ZD0_DATAC7
		endif

	_nPosPA := ASCAN(_aRetPA, {|x|x[1] == _sRetDtCp})
		if _nPosPA == 0
	AADD(_aRetPA, { _sRetDtCp, fConvHr(_trba->PC_QUANTC, 'H')})
		else
	_aRetPA[_nPosPA][2] := fConvHr(fConvHr(_aRetPA[_nPosPA][2],'D') + _trba->PC_QUANTC, 'H')
		endif
	dbSelectArea("_trba")
	dbSkip()
	enddo
	dbSelectArea("_trba")
	_trba->(DbCloseArea())
	RestArea(_aSaveA2)

	return (_aRetPA)

	//Retorna Regra

static function _verRegra (_dData, _cCc2, _cTurno2 )
	Local _aRegra1 := {}
	Local _aSaveA2 := GetArea()
	Local _cQuant  :=  "ZD0_QUANT"+ALLTRIM(STR(dow(_dData)))
	Local _cQuanh  :=  "ZD0_QUANH"+ALLTRIM(STR(dow(_dData)))
	Local _cData   :=  "ZD0_DATA"+ALLTRIM(STR(dow(_dData)))
	Local _cDataCP :=  "ZD0_DATAC"+ALLTRIM(STR(dow(_dData)))

	_cQuery := " SELECT "+_cQuant +" AS QTDE, "+_cDataCP +" AS DATACP  "
	_cQuery += " FROM " + RETSQLNAME ("ZD0") +" AS ZD0  "
	_cQuery += " WHERE ZD0.D_E_L_E_T_ = '' "
	_cQuery += " AND ZD0_CC = '"+_cCc2+"' AND ZD0_TURNO = '"+_cTurno2+"' "
	_cQuery += " AND "+_cData +" = '"+dtos(_dData)+"' "
	//_cQuery += " AND "+_cQuanh +" = 0 "
	//_cQuery += " AND "+_cQuant +" > 0"  //retirado por solicitação do Dyeison
	_cQuery += " AND '"+dtos(_dData)+_cMatri +"' NOT IN (SELECT ZD1_DATA + ZD1_MAT FROM " + RETSQLNAME ("ZD1") +" AS ZD1 "
	_cQuery += " WHERE ZD1.D_E_L_E_T_ = '' AND ZD1_COD = ZD0_COD) "

	tcquery _cQuery new alias _trba
	do while ! _trba -> (eof ())
	AADD(_aRegra1, { _trba->QTDE, _trba->DATACP})
	dbSelectArea("_trba")
	dbSkip()
	enddo
	dbSelectArea("_trba")
	_trba->(DbCloseArea())
	RestArea(_aSaveA2)

	return (_aRegra1)


	//Retorna Regra ATESTADO

static function _aRegAt (_dData, _cCc2, _cTurno2 )
	Local _aRegra1 := {}
	Local _aSaveA2 := GetArea()
	Local _cQuant  :=  "ZD0_QUANT"+ALLTRIM(STR(dow(_dData)))
	Local _cData   :=  "ZD0_DATA"+ALLTRIM(STR(dow(_dData)))
	Local _cDataCP :=  "ZD0_DATAC"+ALLTRIM(STR(dow(_dData)))

	_cQuery := " SELECT "+_cQuant +" AS QTDE, "+_cDataCP +" AS DATACP "
	_cQuery += " FROM " + RETSQLNAME ("ZD0") +" AS ZD0  "
	_cQuery += " WHERE ZD0.D_E_L_E_T_ = '' "
	_cQuery += " AND ZD0_CC = '"+_cCc2+"' AND ZD0_TURNO = '"+_cTurno2+"' "
	_cQuery += " AND "+_cData +" = '"+dtos(_dData)+"' "
	_cQuery += " AND "+_cQuant +" > 0"
	_cQuery += " AND '"+dtos(_dData)+_cMatri +"' NOT IN (SELECT ZD1_DATA + ZD1_MAT FROM " + RETSQLNAME ("ZD1") +" AS ZD1 "
	_cQuery += " WHERE ZD1.D_E_L_E_T_ = '' AND ZD1_COD = ZD0_COD) "

	tcquery _cQuery new alias _trba
	do while ! _trba -> (eof ())
	AADD(_aRegra1, { _trba->QTDE, _trba->DATACP})
	dbSelectArea("_trba")
	dbSkip()
	enddo
	dbSelectArea("_trba")
	_trba->(DbCloseArea())
	RestArea(_aSaveA2)

	return (_aRegra1)


	//Retorna Regra BH FALTA Sábado

static function _cCompFSa (_dData, _cCc2, _cTurno2 )
	Local _aSaveA2 := GetArea()
	Local _cCont := 0

	_cQuery := " SELECT max(ZD0_FSDBH) AS CONTAR "
	_cQuery += " FROM " + RETSQLNAME ("ZD0") +" AS ZD0  "
	_cQuery += " WHERE ZD0.D_E_L_E_T_ = '' "
	_cQuery += " AND ZD0_CC = '"+_cCc2+"' AND ZD0_TURNO = '"+_cTurno2+"' "
	//_cQuery += " AND ZD0_FSDBH = '1' "
	_cQuery += " AND CONVERT(VARCHAR(12),DATEADD(DAY,5 ,CAST(ZD0_DTAREF AS DATETIME)),112) = '"+dtos(_dData)+"' "
	_cQuery += " AND '"+dtos(_dData)+_cMatri +"' NOT IN (SELECT ZD1_DATA + ZD1_MAT FROM " + RETSQLNAME ("ZD1") +" AS ZD1 "
	_cQuery += " WHERE ZD1.D_E_L_E_T_ = '' AND ZD1_COD = ZD0_COD) "

	tcquery _cQuery new alias _trba
	do while ! _trba -> (eof ())
	_cCont := _trba ->CONTAR
	dbSelectArea("_trba")
	dbSkip()
	enddo
	dbSelectArea("_trba")
	_trba->(DbCloseArea())
	RestArea(_aSaveA2)

	return (_cCont)


	//Retorna Regra BH FALTA Semana

static function _cCompFSe(_dData, _cCc2, _cTurno2 )
	Local _aSaveA2 := GetArea()
	Local _cCont := 0

	_cQuery := " SELECT max(ZD0_FSEMDB) AS CONTAR "
	_cQuery += " FROM " + RETSQLNAME ("ZD0") +" AS ZD0  "
	_cQuery += " WHERE ZD0.D_E_L_E_T_ = '' "
	_cQuery += " AND ZD0_CC = '"+_cCc2+"' AND ZD0_TURNO = '"+_cTurno2+"' "
	//_cQuery += " AND ZD0_FSEMDB = '1' "
	_cQuery += " AND ZD0_DTAREF = '"+dtos(_dData-(dow(_dData)-2)) +"' "
	_cQuery += " AND '"+dtos(_dData)+_cMatri +"' NOT IN (SELECT ZD1_DATA + ZD1_MAT FROM " + RETSQLNAME ("ZD1") +" AS ZD1 "
	_cQuery += " WHERE ZD1.D_E_L_E_T_ = '' AND ZD1_COD = ZD0_COD) "

	tcquery _cQuery new alias _trba
	do while ! _trba -> (eof ())
	_cCont := _trba ->CONTAR
	dbSelectArea("_trba")
	dbSkip()
	enddo
	dbSelectArea("_trba")
	_trba->(DbCloseArea())
	RestArea(_aSaveA2)

	return (_cCont)


	//Retorna Regra BH saída antecipada

static function _cCompSA (_dData, _cCc2, _cTurno2 )
	Local _aSaveA2 := GetArea()
	Local _cCont := 0

	_cQuery := " SELECT max(ZD0_SADBH) AS CONTAR "
	_cQuery += " FROM " + RETSQLNAME ("ZD0") +" AS ZD0  "
	_cQuery += " WHERE ZD0.D_E_L_E_T_ = '' "
	_cQuery += " AND ZD0_CC = '"+_cCc2+"' AND ZD0_TURNO = '"+_cTurno2+"' "
	//_cQuery += " AND ZD0_SADBH = '1' "
	_cQuery += " AND ZD0_DTAREF = '"+dtos(_dData-(dow(_dData)-2)) +"' "
	_cQuery += " AND '"+dtos(_dData)+_cMatri +"' NOT IN (SELECT ZD1_DATA + ZD1_MAT FROM " + RETSQLNAME ("ZD1") +" AS ZD1 "
	_cQuery += " WHERE ZD1.D_E_L_E_T_ = '' AND ZD1_COD = ZD0_COD) "

	tcquery _cQuery new alias _trba
	do while ! _trba -> (eof ())
	_cCont := _trba ->CONTAR
	dbSelectArea("_trba")
	dbSkip()
	enddo
	dbSelectArea("_trba")
	_trba->(DbCloseArea())
	RestArea(_aSaveA2)

	return (_cCont)

	//Gera desconto benefício caso funcionário não cumpra horas extras solicitadas

static function _gDescBen()
	Local _aSaveA2 := GetArea()
	Local _cQuery := ""
	Local _dDia := stod(_cInicio)

	do while _dDia <= stod(_cFim)
	//if __aResult [_nx6][2] == _cPdFalta .or. __aResult [_nx6][2] == _cPdHrsNorm
	_cQuery := ""
		if !_lTemAbono(_dDia, "")
			if dow(_dDia) == 2
	_cQuery := " SELECT ZD0_DATA2 AS DATA, ZD0_QUANT2 + ZD0_QUANH2 AS QTDE, ZD0_LINFC2 + ZD0_LINFH2 AS LIMINF, "
	_cQuery += " ZD0_LSUPC2 + ZD0_LSUPH2 AS LIMSUP"
	_cQuery += " FROM " + RETSQLNAME ("ZD0") + " AS ZD0 "
	_cQuery += " WHERE ZD0.D_E_L_E_T_ = '' AND ZD0_CC = '"+_cCc+"' AND ZD0_TURNO = '"+_cTurno+"' "
	_cQuery += " AND ZD0_DATA2 = '"+dtos(_dDia) +"' "
	_cQuery += " AND ZD0_QUANT2 + ZD0_QUANH2 > 0 AND ZD0_DESCBE = '1' "
			elseif dow(_dDia) == 3
	_cQuery := " SELECT ZD0_DATA3 AS DATA, ZD0_QUANT3 + ZD0_QUANH3 AS QTDE, ZD0_LINFC3 + ZD0_LINFH3 AS LIMINF, "
	_cQuery += " ZD0_LSUPC3 + ZD0_LSUPH3 AS LIMSUP"
	_cQuery += " FROM " + RETSQLNAME ("ZD0") + " AS ZD0 "
	_cQuery += " WHERE ZD0.D_E_L_E_T_ = '' AND ZD0_CC = '"+_cCc+"' AND ZD0_TURNO = '"+_cTurno+"' "
	_cQuery += " AND ZD0_DATA3 = '"+dtos(_dDia) +"' "
	_cQuery += " AND ZD0_QUANT3 + ZD0_QUANH3 > 0 AND ZD0_DESCBE = '1' "
			elseif dow(_dDia) == 4
	_cQuery := " SELECT ZD0_DATA4 AS DATA, ZD0_QUANT4 + ZD0_QUANH4 AS QTDE, ZD0_LINFC4 + ZD0_LINFH4 AS LIMINF, "
	_cQuery += " ZD0_LSUPC4 + ZD0_LSUPH4 AS LIMSUP"
	_cQuery += " FROM " + RETSQLNAME ("ZD0") + " AS ZD0 "
	_cQuery += " WHERE ZD0.D_E_L_E_T_ = '' AND ZD0_CC = '"+_cCc+"' AND ZD0_TURNO = '"+_cTurno+"' "
	_cQuery += " AND ZD0_DATA4 = '"+dtos(_dDia) +"' "
	_cQuery += " AND ZD0_QUANT4 + ZD0_QUANH4 > 0 AND ZD0_DESCBE = '1' "
			elseif dow(_dDia) == 5
	_cQuery := " SELECT ZD0_DATA5 AS DATA, ZD0_QUANT5 + ZD0_QUANH5 AS QTDE, ZD0_LINFC5 + ZD0_LINFH5 AS LIMINF, "
	_cQuery += " ZD0_LSUPC5 + ZD0_LSUPH5 AS LIMSUP"
	_cQuery += " FROM " + RETSQLNAME ("ZD0") + " AS ZD0 "
	_cQuery += " WHERE ZD0.D_E_L_E_T_ = '' AND ZD0_CC = '"+_cCc+"' AND ZD0_TURNO = '"+_cTurno+"' "
	_cQuery += " AND ZD0_DATA5 = '"+dtos(_dDia) +"' "
	_cQuery += " AND ZD0_QUANT5 + ZD0_QUANH5 > 0 AND ZD0_DESCBE = '1' "
			elseif dow(_dDia) == 6
	_cQuery := " SELECT ZD0_DATA6 AS DATA, ZD0_QUANT6 + ZD0_QUANH6 AS QTDE, ZD0_LINFC6 + ZD0_LINFH6 AS LIMINF, "
	_cQuery += " ZD0_LSUPC6 + ZD0_LSUPH6 AS LIMSUP"
	_cQuery += " FROM " + RETSQLNAME ("ZD0") + " AS ZD0 "
	_cQuery += " WHERE ZD0.D_E_L_E_T_ = '' AND ZD0_CC = '"+_cCc+"' AND ZD0_TURNO = '"+_cTurno+"' "
	_cQuery += " AND ZD0_DATA6 = '"+dtos(_dDia) +"' "
	_cQuery += " AND ZD0_QUANT6 + ZD0_QUANH6 > 0 AND ZD0_DESCBE = '1' "
			elseif dow(_dDia) == 7
	_cQuery := " SELECT ZD0_DATA7 AS DATA, ZD0_QUANT7 + ZD0_QUANH7 AS QTDE, ZD0_LINFC7 + ZD0_LINFH7 AS LIMINF, "
	_cQuery += " ZD0_LSUPC7 + ZD0_LSUPH7 AS LIMSUP"
	_cQuery += " FROM " + RETSQLNAME ("ZD0") + " AS ZD0 "
	_cQuery += " WHERE ZD0.D_E_L_E_T_ = '' AND ZD0_CC = '"+_cCc+"' AND ZD0_TURNO = '"+_cTurno+"' "
	_cQuery += " AND ZD0_DATA7 = '"+dtos(_dDia) +"' "
	_cQuery += " AND ZD0_QUANT7 + ZD0_QUANH7 > 0 AND ZD0_DESCBE = '1' "
			endif
			if !empty(_cQuery)
	_cQuery += " AND '"+dtos(_dDia)+_cMatri +"' NOT IN (SELECT ZD1_DATA + ZD1_MAT FROM " + RETSQLNAME ("ZD1") +" AS ZD1 "
	_cQuery += " WHERE ZD1.D_E_L_E_T_ = '' AND ZD1_COD = ZD0_COD) "
	tcquery _cQuery new alias _trba
				do while ! _trba -> (eof ())
	_nPosHE1 := ASCAN(__aResult, {|x|dtos(x[1])+AllTrim(x[2]) == _trba->DATA+_cPdExtra1})
	_nPosHE2 := ASCAN(__aResult, {|x|dtos(x[1])+AllTrim(x[2]) == _trba->DATA+_cPdExtra2})
	_nPosHE3 := ASCAN(__aResult, {|x|dtos(x[1])+AllTrim(x[2]) == _trba->DATA+_cPdExtra3})
					if _nPosHE1 > 0 .and. _trba->LIMINF <= __aResult [_nPosHE1][3] .and. __aResult [_nPosHE1][3] <= _trba->LIMSUP
	//
					elseif _nPosHE2 > 0 .and. _trba->LIMINF <= __aResult [_nPosHE2][3] .and. __aResult [_nPosHE2][3] <= _trba->LIMSUP
	//
					elseif _nPosHE3 > 0 .and. _trba->LIMINF <= __aResult [_nPosHE3][3] .and. __aResult [_nPosHE3][3] <= _trba->LIMSUP
	//
					else
	_geraSPC(_dDia , _trba->QTDE , _cPdDescBen, _cCc, _cTurno, _cSeqTur)
					endif
	dbSelectArea("_trba")
	dbSkip()
				enddo
	dbSelectArea("_trba")
	_trba->(DbCloseArea())
			endif
		endif
	//endif
	_dDia+=1
	enddo

	RestArea(_aSaveA2)
	return()

	//Gera evento de não cumprimento de horas extras solicitadas
	//Caso tenha esse evento gerará falta no dia da compensação e não troca de roupa 

static function _gEvNCH()
	Local _aSaveA2 := GetArea()
	Local _cQuery := ""
	Local _nx6

	for _nx6:=1 to len( __aResult )
		if __aResult [_nx6][2] == _cPdFalta .or. __aResult [_nx6][2] == _cPdHrsNorm
			if !_lTemAbono(__aResult [_nx6][1], __aResult [_nx6][2] )
				if dow(__aResult [_nx6][1]) == 2
	_cQuery := " SELECT ZD0_DATA2 AS DATA, ZD0_QUANT2 + ZD0_QUANH2 AS QTDE, ZD0_LINFC2 + ZD0_LINFH2 AS LIMINF, "
	_cQuery += " ZD0_LSUPC2 + ZD0_LSUPH2 AS LIMSUP"
	_cQuery += " FROM " + RETSQLNAME ("ZD0") + " AS ZD0 "
	_cQuery += " WHERE ZD0.D_E_L_E_T_ = '' AND ZD0_CC = '"+__aResult[_nx6][4]+"' AND ZD0_TURNO = '"+__aResult[_nx6][17]+"' "
	_cQuery += " AND ZD0_DATA2 = '"+dtos(__aResult [_nx6][1]) +"' "
	_cQuery += " AND ZD0_QUANT2 + ZD0_QUANH2 > 0 AND (ZD0_DESCBE = '2' or ZD0_DESCBE = '') "
				elseif dow(__aResult [_nx6][1]) == 3
	_cQuery := " SELECT ZD0_DATA3 AS DATA, ZD0_QUANT3 + ZD0_QUANH3 AS QTDE, ZD0_LINFC3 + ZD0_LINFH3 AS LIMINF, "
	_cQuery += " ZD0_LSUPC3 + ZD0_LSUPH3 AS LIMSUP"
	_cQuery += " FROM " + RETSQLNAME ("ZD0") + " AS ZD0 "
	_cQuery += " WHERE ZD0.D_E_L_E_T_ = '' AND ZD0_CC = '"+__aResult[_nx6][4]+"' AND ZD0_TURNO = '"+__aResult[_nx6][17]+"' "
	_cQuery += " AND ZD0_DATA3 = '"+dtos(__aResult [_nx6][1]) +"' "
	_cQuery += " AND ZD0_QUANT3 + ZD0_QUANH3 > 0 AND (ZD0_DESCBE = '2' or ZD0_DESCBE = '') "
				elseif dow(__aResult [_nx6][1]) == 4
	_cQuery := " SELECT ZD0_DATA4 AS DATA, ZD0_QUANT4 + ZD0_QUANH4 AS QTDE, ZD0_LINFC4 + ZD0_LINFH4 AS LIMINF, "
	_cQuery += " ZD0_LSUPC4 + ZD0_LSUPH4 AS LIMSUP"
	_cQuery += " FROM " + RETSQLNAME ("ZD0") + " AS ZD0 "
	_cQuery += " WHERE ZD0.D_E_L_E_T_ = '' AND ZD0_CC = '"+__aResult[_nx6][4]+"' AND ZD0_TURNO = '"+__aResult[_nx6][17]+"' "
	_cQuery += " AND ZD0_DATA4 = '"+dtos(__aResult [_nx6][1]) +"' "
	_cQuery += " AND ZD0_QUANT4 + ZD0_QUANH4 > 0 AND (ZD0_DESCBE = '2' or ZD0_DESCBE = '') "
				elseif dow(__aResult [_nx6][1]) == 5
	_cQuery := " SELECT ZD0_DATA5 AS DATA, ZD0_QUANT5 + ZD0_QUANH5 AS QTDE, ZD0_LINFC5 + ZD0_LINFH5 AS LIMINF, "
	_cQuery += " ZD0_LSUPC5 + ZD0_LSUPH5 AS LIMSUP"
	_cQuery += " FROM " + RETSQLNAME ("ZD0") + " AS ZD0 "
	_cQuery += " WHERE ZD0.D_E_L_E_T_ = '' AND ZD0_CC = '"+__aResult[_nx6][4]+"' AND ZD0_TURNO = '"+__aResult[_nx6][17]+"' "
	_cQuery += " AND ZD0_DATA5 = '"+dtos(__aResult [_nx6][1]) +"' "
	_cQuery += " AND ZD0_QUANT5 + ZD0_QUANH5 > 0 AND (ZD0_DESCBE = '2' or ZD0_DESCBE = '') "
				elseif dow(__aResult [_nx6][1]) == 6
	_cQuery := " SELECT ZD0_DATA6 AS DATA, ZD0_QUANT6 + ZD0_QUANH6 AS QTDE, ZD0_LINFC6 + ZD0_LINFH6 AS LIMINF, "
	_cQuery += " ZD0_LSUPC6 + ZD0_LSUPH6 AS LIMSUP"
	_cQuery += " FROM " + RETSQLNAME ("ZD0") + " AS ZD0 "
	_cQuery += " WHERE ZD0.D_E_L_E_T_ = '' AND ZD0_CC = '"+__aResult[_nx6][4]+"' AND ZD0_TURNO = '"+__aResult[_nx6][17]+"' "
	_cQuery += " AND ZD0_DATA6 = '"+dtos(__aResult [_nx6][1]) +"' "
	_cQuery += " AND ZD0_QUANT6 + ZD0_QUANH6 > 0 AND (ZD0_DESCBE = '2' or ZD0_DESCBE = '') "
				elseif dow(__aResult [_nx6][1]) == 7
	_cQuery := " SELECT ZD0_DATA7 AS DATA, ZD0_QUANT7 + ZD0_QUANH7 AS QTDE, ZD0_LINFC7 + ZD0_LINFH7 AS LIMINF, "
	_cQuery += " ZD0_LSUPC7 + ZD0_LSUPH7 AS LIMSUP"
	_cQuery += " FROM " + RETSQLNAME ("ZD0") + " AS ZD0 "
	_cQuery += " WHERE ZD0.D_E_L_E_T_ = '' AND ZD0_CC = '"+__aResult[_nx6][4]+"' AND ZD0_TURNO = '"+__aResult[_nx6][17]+"' "
	_cQuery += " AND ZD0_DATA7 = '"+dtos(__aResult [_nx6][1]) +"' "
	_cQuery += " AND ZD0_QUANT7 + ZD0_QUANH7 > 0 AND (ZD0_DESCBE = '2' or ZD0_DESCBE = '') "
				endif
				if !empty(_cQuery)
	_cQuery += " AND '"+dtos(__aResult [_nx6][1])+_cMatri +"' NOT IN (SELECT ZD1_DATA + ZD1_MAT FROM " + RETSQLNAME ("ZD1") +" AS ZD1 "
	_cQuery += " WHERE ZD1.D_E_L_E_T_ = '' AND ZD1_COD = ZD0_COD) "
	tcquery _cQuery new alias _trba
					do while ! _trba -> (eof ())
	_nPosHE1 := ASCAN(__aResult, {|x|dtos(x[1])+AllTrim(x[2]) == _trba->DATA+_cPdExtra1})
	_nPosHE2 := ASCAN(__aResult, {|x|dtos(x[1])+AllTrim(x[2]) == _trba->DATA+_cPdExtra2})
	_nPosHE3 := ASCAN(__aResult, {|x|dtos(x[1])+AllTrim(x[2]) == _trba->DATA+_cPdExtra3})
						if _nPosHE1 > 0 .and. _trba->LIMINF <= __aResult [_nPosHE1][3] .and. __aResult [_nPosHE1][3] <= _trba->LIMSUP
	//
						elseif _nPosHE2 > 0 .and. _trba->LIMINF <= __aResult [_nPosHE2][3] .and. __aResult [_nPosHE2][3] <= _trba->LIMSUP
	//
						elseif _nPosHE3 > 0 .and. _trba->LIMINF <= __aResult [_nPosHE3][3] .and. __aResult [_nPosHE3][3] <= _trba->LIMSUP
	//
						else
	_geraSPC(__aResult[_nx6][1] , _trba->QTDE , _cPdEvNC, __aResult[_nx6][4], __aResult[_nx6][17], __aResult[_nx6][18])
						endif
	dbSelectArea("_trba")
	dbSkip()
					enddo
	dbSelectArea("_trba")
	_trba->(DbCloseArea())
				endif
			endif
		endif
	next _nx6

	RestArea(_aSaveA2)
	return()


static function _somaHrs(_nHr1, _nHr2)
	Local _nSoma1 := 0
	Local _nSoma2 := 0
	_nSoma1 := int(_nHr1) + (((_nHr1 - int(_nHr1)) / 60) * 100) + int(_nHr2) + (((_nHr2 - int(_nHr2)) / 60) * 100)
	_nSoma2 := int(_nSoma1) + (((_nSoma1 - int(_nSoma1)) * 60) / 100)
	return(_nSoma2)


static function _subHrs(_nHr1, _nHr2)
	Local _nSub1 := 0
	Local _nSub2 := 0
	//_nSub1 := (int(_nHr1) + (((_nHr1 - int(_nHr1)) / 60) * 100)) - (int(_nHr2) + (((_nHr2 - int(_nHr2)) / 60) * 100))
	//_nSub2 := int(_nSub1) + (((_nSub1 - int(_nSub1)) * 60) / 100)
	_nSub2 := fConvHr(_nHr1, "D") - fConvHr(_nHr2, "D")

	return(_nSub2)

	//Limpa tabela ZBC banco de horas

static function _limpaZBC()
	ZBB->(dbSetOrder(1))
	ZBB->(dbSeek(_cFilial + _cMatri))
	ZBC->(dbSetOrder(1))
	ZBC->(dbGoTop())
	if ZBC->(dbSeek(_cFilial + _cMatri))
		do while ZBC->(!eof()) .and. ALLTRIM(ZBC->ZBC_MAT) == ALLTRIM(_cMatri)
			if ZBC->ZBC_DTREF >= stod(_cInicio) .and. ZBC->ZBC_DTREF <= stod(_cFim)  .and. ZBC->ZBC_APONTA == 'P'
	_nHrZBC := ZBC->ZBC_HRBAIX
	reclock('ZBC',.F.)
	dbdelete()
	msunlock()

	_nHrZBB  := ZBB->ZBB_SLDATU + _nHrZBC
	_nHrAZBB := ZBB->ZBB_SLDANT + _nHrZBC
	reclock('ZBB',.f.)
	ZBB->ZBB_SLDATU := _nHrZBB
	ZBB->ZBB_SLDANT := _nHrAZBB
	msunlock()
			endif
	ZBC->(dbSkip())
		enddo
	endif

	return

static function _gravaZBC(_dData, _nHrs6)
	Local _nHrs5 := round(_nHrs6, 2)

	reclock('ZBC',.T.)
	ZBC->ZBC_FILIAL := _cFilial
	ZBC->ZBC_MAT    := _cMatri
	ZBC->ZBC_DTREF  := _dData
	ZBC->ZBC_HRBAIX := _nHrs5
	ZBC->ZBC_APONTA := 'P'
	msunlock()

	if ZBB->(dbSeek(xFilial('ZBB') + _cMatri))
	_nHrZBC := ZBC->ZBC_HRBAIX
	_nHrZBB  := ZBB->ZBB_SLDATU - _nHrZBC
	_nHrAZBB := ZBB->ZBB_SLDANT - _nHrZBC
	reclock('ZBB',.f.)
	ZBB->ZBB_SLDATU := _nHrZBB
	ZBB->ZBB_SLDANT := _nHrAZBB
	msunlock()
	else
	reclock('ZBB',.T.)
	ZBB->ZBB_FILIAL := _cFilial
	ZBB->ZBB_MAT 	:= _cMatri
	ZBB->ZBB_CC     := alltrim(_cCc)
	ZBB->ZBB_SLDATU := _nHrs5*-1
	ZBB->ZBB_SLDANT := 0
	ZBB->ZBB_ULTPER := GETMV('MV_PAPONTA')
	msunlock()
	endif

	return

	//Verifica se evento foi abonado

static function _lTemAbono(_dData1, _cPdAb)
	Local _cQuery := ""
	Local _nCount := 0
	_cQuery := " SELECT COUNT(*) AS CONT "
	_cQuery += " FROM " + RETSQLNAME ("SPK") +" AS SPK  "
	_cQuery += " WHERE SPK.D_E_L_E_T_ = '' AND PK_MAT = '"+_cMatri+"' AND PK_FILIAL = '"+_cFilial+"' "
	_cQuery += " AND PK_DATA = '"+dtos(_dData1)+"' " //"AND PK_CODEVE = '"+_cPdAb+"' "

	tcquery _cQuery new alias _trbb

	do while !_trbb->(eof())
	_nCount := _trbb->CONT
	dbSelectArea("_trbb")
	dbSkip()
	enddo
	dbSelectArea("_trbb")
	_trbb->(DbCloseArea())

	return(_nCount > 0)

	//Verifica se tem perda de benefício

static function _lTemPBen(_dData3)

	Local _nCount3 := 0
	//Local _dIni3 :=  _dData3-(dow(_dData3)-2)
	//Local _dFim3 :=  _dData3+(7-dow(_dData3))
	Local _nQtde   := 0	
	Local _nx6
	for _nx6:=1 to len( __aResult )
		if (__aResult[_nx6][2] == _cPdDescBen .or. __aResult[_nx6][2] == _cPdEvNC) .and. __aResult[_nx6][1] == _dData3
	_nCount3 += fConvHr(__aResult[_nx6][3],'D')
		endif
	next _nx6
	return(_nCount3 > 0)

	//Verifica se teve notificação no período

static function _gEvNoti()
	Local _aSaveA3 := GetArea()
	Local _cQuery := ""

	_cQuery := " SELECT ZD2_DTANOT "
	_cQuery += " FROM " + RETSQLNAME ("ZD2") +" AS ZD2 "
	_cQuery += " WHERE ZD2.D_E_L_E_T_ = '' AND ZD2_MAT = '"+_cMatri+"' AND ZD2_FILFUN = '"+_cFilial+"' "
	_cQuery += " AND ZD2_DTANOT BETWEEN '"+_cInicio+"' AND '"+_cFim+"' "

	tcquery _cQuery new alias _trbb

	do while !_trbb->(eof())
	_geraSPC(stod(_trbb->ZD2_DTANOT), 1, _cPdEvNoti, _cCc, _cTurno, _cSeqTur)
	dbSelectArea("_trbb")
	dbSkip()
	enddo
	dbSelectArea("_trbb")
	_trbb->(DbCloseArea())
	RestArea(_aSaveA3)
	return()

	//gera compensações de horas extras e faltas

static function _gCompHE()
	Local _nx
	//gera verbas compensação 203 e 403 
	for _nx:=1 to len( __aResult )
	_aRegra := {}
	_nQtde  := 0
		if __aResult [_nx][2] == _cPdExtra1 .or. __aResult [_nx][2] == _cPdExtra2 .or. __aResult [_nx][2] == _cPdExtra3
			if dow(__aResult[_nx][1]) > 1 //.and. dow(__aResult[_nx][1]) < 7
	_aRegra := _verRegra(__aResult[_nx][1], __aResult[_nx][4], __aResult[_nx][17])
			endif
	//se tem regra de compensação para o dia
			if len(_aRegra) > 0 .and. __aResult[_nx][1] <> stod(_aRegra[1][2])
	//verifico se existe falta ou saída antecipada para o dia destino da compensação
	//somente centros de custo abate e afins

	//****falta testar se na regra tem abono de faltas
	_nPosFalt := ASCAN(__aResult, {|x|dtos(x[1])+AllTrim(x[2]) == _aRegra[1][2]+_cPdFalta})
				if _lTemAbono(stod(_aRegra[1][2]), _cPdFalta )
	_nPosFalt := 0
				endif
	//****falta testar se na regra tem abono de saída antecipada 
	_nPosSAnt := ASCAN(__aResult, {|x|dtos(x[1])+AllTrim(x[2]) == _aRegra[1][2]+_cPdSaiAnt})
				if _lTemAbono(stod(_aRegra[1][2]), _cPdSaiAnt )
	_nPosSAnt := 0
				endif

	//se existir gero a compensação ou se o dia da compensação for do próximo período
				if (_nPosSAnt +  _nPosFalt > 0) .or. _aRegra[1][2] > _cFim
	//procuro se evento já existe para o dia
	//_nProcPd := ASCAN(__aResult, {|x|dtos(x[1])+AllTrim(x[2]) == _aRegra[1][2]+_cPdCpEx})

	_nProcPd := ASCAN(__aResult, {|x|dtos(x[1])+AllTrim(x[2]) == dtos(__aResult[_nx][1])+_cPdCpEx})
					if _nProcPd > 0
	__aResult[_nProcPd][3] := _somaHrs(__aResult[_nProcPd][3], __aResult[_nx][3])

					else
	_geraSPC(__aResult[_nx][1] , __aResult[_nx][3], _cPdCpEx, __aResult[_nx][4], __aResult[_nx][17], __aResult[_nx][18])
					endif
	//verifico se o dia destino da compensação ainda é do período atual 
					if _aRegra[1][2] <= _cFim
	//procuro se evento já existe para o dia
	_nProcPd := ASCAN(__aResult, {|x|dtos(x[1])+AllTrim(x[2]) == _aRegra[1][2]+_cPdCpFalta})
						if _nProcPd > 0
	__aResult[_nProcPd][3] := _somaHrs(__aResult[_nProcPd][3], __aResult[_nx][3])
						else
	_geraSPC(stod(_aRegra[1][2]) , __aResult[_nx][3], _cPdCpFalta, __aResult[_nx][4], __aResult[_nx][17], __aResult[_nx][18])
						endif
					endif
				endif
			endif
		endif
	next _nx
	return()


static function _vCompPA()
	Local _nx88
	//se período inicia terça, quarta, quinta ou sexta procuro compensações

	if (dow(stod(_cInicio)) == 3 .or. dow(stod(_cInicio)) == 4 .or. dow(stod(_cInicio)) == 5 .or. dow(stod(_cInicio)) == 6 .or. dow(stod(_cInicio)) == 7)
	//carrega data inicial da semana do período anterior
	_dDtPerAnt :=  DaySub( stod(_cInicio) , dow(stod(_cInicio)) - 2 )

	//Busca compensações do período anterior
	_aPerACP  := _BuscaCP( _dDtPerAnt, DaySub( stod(_cInicio) , 1), stod(_cInicio), DaySum( stod(_cInicio) , 7-dow(stod(_cInicio))  ) )

		for _nx88:=1 to len( _aPerACP )

	_nProcPd := ASCAN(__aResult, {|x|dtos(x[1])+AllTrim(x[2]) == _aPerACP[_nx88][1]+_cPdCpFalta})
			if _nProcPd > 0
	//__aResult[_nProcPd][3] += _aPerACP[1][2]
	__aResult[_nProcPd][3] := _somaHrs(__aResult[_nProcPd][3], _aPerACP[_nx88][2])
			else
	_geraSPC(stod(_aPerACP[_nx88][1]), _aPerACP[_nx88][2], _cPdCpFalta, _cCC, _cTurno, _cSeqTur)
			endif

	//verifico se no dia da compensação de falta ou saída antecipada, coisa que não consigo identificar de um mes para o outro
	// se não tiver gero hora extra e se tiver será compensado
	//verifico se tem falta no dia da compensação
	_nPosFalt := ASCAN(__aResult, {|x|dtos(x[1])+AllTrim(x[2]) == _aPerACP[_nx88][1]+_cPdFalta})

			if _lTemAbono(stod(_aPerACP[_nx88][1]), _cPdFalta )
	_nPosFalt := 0
			endif
	//verifico se tem saída antecipada no dia da compensação
	_nPosSAnt := ASCAN(__aResult, {|x|dtos(x[1])+AllTrim(x[2]) == _aPerACP[_nx88][1]+_cPdSaiAnt})
			if _lTemAbono(stod(_aPerACP[_nx88][1]), _cPdSaiAnt )
	_nPosSAnt := 0
			endif
			if _nPosFalt + _nPosSAnt == 0
	_nProcPd := ASCAN(__aResult, {|x|dtos(x[1])+AllTrim(x[2]) == _aPerACP[_nx88][1]+_cPdExtra1})
				if _nProcPd > 0
	__aResult[_nProcPd][3] := _somaHrs(__aResult[_nProcPd][3], _aPerACP[_nx88][2])
				else
	_geraSPC(stod(_aPerACP[_nx88][1]), _aPerACP[_nx88][2], _cPdExtra1, _cCC, _cTurno, _cSeqTur)
				endif
			endif
		next _nx88

	endif

	return()
	//Gera compensações por atestado

static function _gCompAt()
	Local _aRegra1 := {}
	Local _nx3
	//verifica se funcionário teve atestado no dia que havia compensação
	//somente para esses centros de custo, ver como melhorar isso para o proximo período
	for _nx3:=1 to len( __aResult )
	_aRegra1 := {}
	_nQtde  := 0
		if (__aResult [_nx3][2] == _cPdFalta .or. __aResult [_nx3][2] ==_cPdSaiAnt)  .and. dow(__aResult[_nx3][1]) > 1 //.and.  dow(__aResult[_nx3][1]) < 7
	_aRegra1 := _aRegAt(__aResult[_nx3][1], __aResult[_nx3][4], __aResult[_nx3][17])
			if len(_aRegra1) > 0 .and. _lTemAbono(__aResult[_nx3][1], __aResult [_nx3][2] )
	//verifico se o sábado ainda é do período atual 
				if _aRegra1[1][2] <= _cFim
	//procuro se evento já existe para o dia
	_nProcPd := ASCAN(__aResult, {|x|dtos(x[1])+AllTrim(x[2]) == _aRegra1[1][2]+_cPdCpAtest})
					if _nProcPd > 0
	__aResult[_nProcPd][3] := _somaHrs(__aResult[_nProcPd][3], _aRegra1[1][1])
					else
	_geraSPC(stod(_aRegra1[1][2]) , _aRegra1[1][1], _cPdCpAtest, __aResult[_nx3][4], __aResult[_nx3][17], __aResult[_nx3][18])
					endif
				endif
			endif
		endif
	next _nx3
	return()

	//Gera compensações saída antecipada

static function _gCompSA()
	Local _cTpComp := ""
	Local _nx4
	for _nx4:=1 to len( __aResult )
	_cTpComp := _cCompSA(__aResult[_nx4][1], __aResult[_nx4][4], __aResult[_nx4][17])
		if __aResult[_nx4][2] == _cPdSaiAnt

			if _cTpComp == '1' .or. _cTpComp == '3' //sim ou positivo
				if !_lTemAbono(__aResult[_nx4][1], __aResult[_nx4][2] )
	_nProcPd := ASCAN(__aResult, {|x|dtos(x[1])+AllTrim(x[2]) == dtos(__aResult[_nx4][1])+_cPdCpFalta})
	_nAtest  := ASCAN(__aResult, {|x|dtos(x[1])+AllTrim(x[2]) == dtos(__aResult[_nx4][1])+_cPdCpAtest})
	_nTotCp := 0
					if (_nProcPd > 0 .or. _nAtest > 0)
						if _nProcPd > 0
	_nTotCp := __aResult[_nProcPd][3]
						endif
						if _nAtest > 0
	_nTotCp := fConvHr(fConvHr(__aResult[_nAtest][3], 'D') + fConvHr(_nTotCp, 'D'),'H')
						endif
						if __aResult[_nx4][3] >= _nTotCp
	//_nHoras := fConvHr(_subHrs(__aResult[_nx4][3], _nTotCp),'D')
	_nHoras := _subHrs(__aResult[_nx4][3], _nTotCp)
							if !_lTemPBen(__aResult[_nx4][1]) .and. (_cTpComp == '1' .or. ( _cTpComp == '3' .and. POSICIONE("ZBB", 1, _cFilial + _cMatri, "ZBB_SLDATU") > 0))
	_geraSPC(__aResult[_nx4][1], fConvHr(_nHoras,'H'), _cPdAcordo, __aResult[_nx4][4], __aResult[_nx4][17], __aResult[_nx4][18])

	//GRAVAR TABELA TROCA DE ROUPA
								if _nHoras > 0
	_gravaZBC(__aResult[_nx4][1], _nHoras)
								endif
							endif
						else
	//_nHoras := fConvHr(_subHrs(_nTotCp, __aResult[_nx4][3]),'D')
	_nHoras := _subHrs(_nTotCp, __aResult[_nx4][3])
	_geraSPC(__aResult[_nx4][1], fConvHr(_nHoras,'H'), _cPdExtra1, __aResult[_nx4][4], __aResult[_nx4][17], __aResult[_nx4][18])
						endif
					else
	//_nHoras := fConvHr(__aResult[_nx4][3],'D')
	_nHoras := __aResult[_nx4][3]
						if !_lTemPBen(__aResult[_nx4][1]) .and. (_cTpComp == '1' .or. ( _cTpComp == '3' .and. POSICIONE("ZBB", 1, _cFilial + _cMatri, "ZBB_SLDATU") > 0))
	_geraSPC(__aResult[_nx4][1], _nHoras, _cPdAcordo, __aResult[_nx4][4], __aResult[_nx4][17], __aResult[_nx4][18])

	//GRAVAR TABELA TROCA DE ROUPA
	_gravaZBC(__aResult[_nx4][1], fConvHr(_nHoras, 'D'))
						endif
					endif
				endif
			else
				if !_lTemAbono(__aResult[_nx4][1], __aResult[_nx4][2] )
	//testo se tem compensações maior que saída antecipada e gero horas extras da diferença
	_nProcPd := ASCAN(__aResult, {|x|dtos(x[1])+AllTrim(x[2]) == dtos(__aResult[_nx4][1])+_cPdCpFalta})
	_nAtest  := ASCAN(__aResult, {|x|dtos(x[1])+AllTrim(x[2]) == dtos(__aResult[_nx4][1])+_cPdCpAtest})
	_nTotCp  := 0
					if (_nProcPd > 0 .or. _nAtest > 0)
						if _nProcPd > 0
	_nTotCp := __aResult[_nProcPd][3]
						endif
						if _nAtest > 0
	_nTotCp := fConvHr(fConvHr(__aResult[_nAtest][3], 'D') + fConvHr(_nTotCp, 'D'),'H')
						endif
						if _nTotCp > __aResult[_nx4][3]

	_nHoras := _subHrs(_nTotCp, __aResult[_nx4][3])
	_geraSPC(__aResult[_nx4][1], fConvHr(_nHoras,'H'), _cPdExtra1, __aResult[_nx4][4], __aResult[_nx4][17], __aResult[_nx4][18])
						endif
					endif
				endif
			endif
		endif
	next _nx4

	return()

	//Gera banco de horas troca de roupa

static function _gBH()
	//joga faltas de sábado para banco de horas troca de roupa	
	Local _cTpCSa := ""
	Local _cTpFSe := ""
	Local _nx2
	for _nx2:=1 to len( __aResult )
	_cTpCSa := _cCompFSa(__aResult[_nx2][1], __aResult[_nx2][4], __aResult[_nx2][17])
	_cTpFSe := _cCompFSe(__aResult[_nx2][1], __aResult[_nx2][4], __aResult[_nx2][17])
		if __aResult[_nx2][2] == _cPdFalta .and. ;
	(((_cTpCSa == '1' .or. _cTpCSa == '3') .AND. DOW(__aResult[_nx2][1]) == 7) .OR. ;
	((_cTpFSe == '1' .or. _cTpFSe == '3')  .AND. DOW(__aResult[_nx2][1]) < 7)) .and. SM0->M0_CODIGO == "01"
				if !_lTemAbono(__aResult[_nx2][1], __aResult[_nx2][2] )
	_nProcPd := ASCAN(__aResult, {|x|dtos(x[1])+AllTrim(x[2]) == dtos(__aResult[_nx2][1])+_cPdCpFalta})
	_nAtest  := ASCAN(__aResult, {|x|dtos(x[1])+AllTrim(x[2]) == dtos(__aResult[_nx2][1])+_cPdCpAtest})
	_nTotCp := 0
				if (_nProcPd > 0 .or. _nAtest > 0)
					if _nProcPd > 0
	_nTotCp := __aResult[_nProcPd][3]
					endif
					if _nAtest > 0
	_nTotCp := fConvHr(fConvHr(__aResult[_nAtest][3], 'D') + fConvHr(_nTotCp, 'D'),'H')
					endif

					if __aResult[_nx2][3] >= _nTotCp
	//_nHoras := fConvHr(_subHrs(__aResult[_nx2][3], _nTotCp),'D')
	_nHoras := _subHrs(__aResult[_nx2][3], _nTotCp)
						if !_lTemPBen(__aResult[_nx2][1]) .and. ;
	(((_cTpCSa == '1' .or. ( _cTpCSa == '3' .and. POSICIONE("ZBB", 1, _cFilial + _cMatri, "ZBB_SLDATU") > 0)) .AND. DOW(__aResult[_nx2][1]) == 7) .or. ;
	((_cTpFSe == '1' .or. ( _cTpFSe == '3' .and. POSICIONE("ZBB", 1, _cFilial + _cMatri, "ZBB_SLDATU") > 0)) .AND. DOW(__aResult[_nx2][1]) < 7))
	_geraSPC(__aResult[_nx2][1], fConvHr(_nHoras,'H'), _cPdAcordo, __aResult[_nx2][4], __aResult[_nx2][17], __aResult[_nx2][18])

	//GRAVAR TABELA TROCA DE ROUPA
								if _nHoras > 0
	_gravaZBC(__aResult[_nx2][1], _nHoras)
							endif

	//gera 437 com a diferença da falta e da compensação, pois a 409 estava gerando dsr	
						elseif !_lTemPBen(__aResult[_nx2][1]) .and. ;
	(((_cTpCSa == '3' .and. POSICIONE("ZBB", 1, _cFilial + _cMatri, "ZBB_SLDATU") <= 0) .AND. DOW(__aResult[_nx2][1]) == 7) .or. ;
	(( _cTpFSe == '3' .and. POSICIONE("ZBB", 1, _cFilial + _cMatri, "ZBB_SLDATU") <= 0) .AND. DOW(__aResult[_nx2][1]) < 7))
	//_geraSPC(__aResult[_nx2][1], fConvHr(_nHoras,'H'), _cPdAcordo, __aResult[_nx2][4], __aResult[_nx2][17], __aResult[_nx2][18])

	//GRAVAR TABELA TROCA DE ROUPA
								if _nHoras > 0
	_geraSPC(__aResult[_nx2][1], fConvHr(_nHoras,'H'), _cPdSaiAnt, __aResult[_nx2][4], __aResult[_nx2][17], __aResult[_nx2][18])
	__aResult[_nx2][3] := _nTotCp
							endif
						endif
					else
	//_nHoras := fConvHr(_subHrs(_nTotCp, __aResult[_nx2][3]),'D')						
	_nHoras := _subHrs(_nTotCp, __aResult[_nx2][3])
	_geraSPC(__aResult[_nx2][1], fConvHr(_nHoras,'H'), _cPdExtra1, __aResult[_nx2][4], __aResult[_nx2][17], __aResult[_nx2][18])
					endif
				else
	_nHoras := __aResult[_nx2][3]
					if !_lTemPBen(__aResult[_nx2][1]) .and. ;
	(((_cTpCSa == '1' .or. ( _cTpCSa == '3' .and. POSICIONE("ZBB", 1, _cFilial + _cMatri, "ZBB_SLDATU") > 0)) .AND. DOW(__aResult[_nx2][1]) == 7) .or. ;
	((_cTpFSe == '1' .or. ( _cTpFSe == '3' .and. POSICIONE("ZBB", 1, _cFilial + _cMatri, "ZBB_SLDATU") > 0))  .AND. DOW(__aResult[_nx2][1]) < 7))
	_geraSPC(__aResult[_nx2][1], _nHoras, _cPdAcordo, __aResult[_nx2][4], __aResult[_nx2][17], __aResult[_nx2][18])

	//GRAVAR TABELA TROCA DE ROUPA
	_gravaZBC(__aResult[_nx2][1], fConvHr(_nHoras,'C'))
						endif
				endif
			endif
		elseif __aResult[_nx2][2] == _cPdFalta .and. ;
	(((_cTpCSa == '0' .or. _cTpCSa == '2') .AND. DOW(__aResult[_nx2][1]) == 7) .OR. ;
	((_cTpFSe == '0' .or. _cTpFSe == '2')  .AND. DOW(__aResult[_nx2][1]) < 7))	
	_nProcPd := ASCAN(__aResult, {|x|dtos(x[1])+AllTrim(x[2]) == dtos(__aResult[_nx2][1])+_cPdCpFalta})
	_nTotCp := 0			
				if _nProcPd > 0
	_nTotCp := __aResult[_nProcPd][3]
	//_nHoras := fConvHr(_subHrs(_nTotCp, __aResult[_nx2][3]),'D')
				if _nTotCp >= __aResult[_nx2][3]
	_nHoras := _subHrs(_nTotCp, __aResult[_nx2][3])
	_geraSPC(__aResult[_nx2][1], fConvHr(_nHoras,'H'), _cPdExtra1, __aResult[_nx2][4], __aResult[_nx2][17], __aResult[_nx2][18])
				else //gera 437 com a diferença da falta e da compensação, pois a 409 estava gerando dsr
	_nHoras := _subHrs(__aResult[_nx2][3], _nTotCp )
	_geraSPC(__aResult[_nx2][1], fConvHr(_nHoras,'H'), _cPdSaiAnt, __aResult[_nx2][4], __aResult[_nx2][17], __aResult[_nx2][18])
	__aResult[_nx2][3] := _nTotCp
				endif
			endif
		endif
	next _nx2
	return()
	*/
