#INCLUDE "topconn.ch"
#INCLUDE "rwmake.ch"
#INCLUDE "protheus.ch"

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณDTI22     บAutor  ณMauricio Roehrs     บ Data ณ  02/02/17   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณ Fonte destinado เ altera็ใo do horario de entrada          บฑฑ
ฑฑบ          ณ dos funcionแrios de acordo com solicita็ใo da diretoria    บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ Dire็ao				                                      บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/

User Function dti22()

	cPerg := "DTI22"

	if !pergunte(cPerg,.t.)
		return
	endif

	Processa({||montareg()} ,"PROCESSAMENTO DE REGISTROS","Separando dados dos funcionแrios...")

	msgbox('Horแrios alterados!','ALTERAวีES EFETIVADAS!','INFO')

return

Static Function montaReg()

	_cQuery := " SELECT P8_MAT, P8_DATA, P8_HORA, P8_CC
	_cQuery += " FROM  " + retSqlTab('SP8')
	_cQuery += " WHERE " + retSqlFil('SP8')
	_cQuery += " AND P8_DATA BETWEEN '" + dtos(mv_par01) + "' AND '" + dtos(mv_par02) + "'"
	_cQuery += " AND P8_CC  BETWEEN '" +    mv_par03    + "' AND '" +    mv_par04    + "'" 
	_cQuery += " AND P8_TPMCREP <> 'D' AND " + retSqlDel('SP8')
	_cQuery += " ORDER BY P8_MAT, P8_DATA, P8_HORA

	_cQuery  := ChangeQuery(_cQuery)

	//	* Mostrar a consulta */
	//@ 116,090 To 416,707 Dialog oDlgMemo Title "Consulta"
	//@ 055,005 Get _cQuery Size 250,080 MEMO Object oMemo
	//Activate Dialog oDlgMemo

	If Select("QRY") != 0
		QRY->(dbCloseArea())
	Endif

	TCQUERY _cQuery NEW ALIAS "QRY"

	QRY->(dbGoTop())
	Procregua(recCount("QRY"))
	While QRY->(!eof())

		IncProc('Processando dados da matricula: ' + QRY->P8_MAT)

		dbSelectArea('SRA')
		_nHraEnt := fbuscaCpo('SRA',1,xFilial('SRA') + QRY->P8_MAT,'RA_HRAENT')

		_nHraEnt2 := fConvHr(_nHraEnt,'D')
		_nHraP8   := fConvHr(QRY->P8_HORA,'D')
		_nDif 	  := _nHraEnt2 - _nHraP8



		if _nHraEnt == 0
			QRY->(dbSkip())
			loop
		endif

		if QRY->P8_HORA >= _nHraEnt
			QRY->(dbSkip())
			loop
		endif
		
		//valida็ใo adicionada dia 22/10/18
		if _nDif <= 0.14 //0.09 em decimal ้ igual a 0.05 em hexasegimal(hora)
			QRY->(dbSkip())
			loop
		endif

		dbSelectArea('SP8')
		SP8->(dbSetOrder(2))
		SP8->(dbGoTop())
		if SP8->(dbSeek(xFilial('SP8') + QRY->P8_MAT + QRY->P8_DATA + str(QRY->P8_HORA,5,2)))

			_cFil  		:= SP8->P8_FILIAL
			_cMat  		:= SP8->P8_MAT
			_dData 		:= SP8->P8_DATA
			_cCC   		:= SP8->P8_CC
			_cOrd  		:= SP8->P8_ORDEM
			_cFlag 		:= SP8->P8_FLAG
			_cApont 	:= SP8->P8_APONTA
			_cTurno 	:= SP8->P8_TURNO
			_cRelog  	:= SP8->P8_RELOGIO
			_cFunc   	:= SP8->P8_FUNCAO
			_cGiro   	:= SP8->P8_GIRO
			_cTpMarca 	:= SP8->P8_TPMARCA
			_cPaponta   := SP8->P8_PAPONTA
			_cUsrLgi    := SP8->P8_USERLGI
			_cUsrLga 	:= SP8->P8_USERLGA
			_cSemana    := SP8->P8_SEMANA
			_dDtApo     := SP8->P8_DATAAPO
			_cNumRep	:= SP8->P8_NUMREP
			_cTPMCREP	:= SP8->P8_TPMCREP
			_cTpReg 	:= SP8->P8_TIPOREG
			_cMotiReg	:= SP8->P8_MOTIVRG
			_cEmpReg	:= SP8->P8_EMPORG
			_cFilOri	:= SP8->P8_FILORG
			_cMatOri	:= SP8->P8_MATORG
			_cDhOri		:= SP8->P8_DHORG
			_cProces	:= SP8->P8_PROCES
			_cIdOri		:= SP8->P8_IDORG
			_cRoteir	:= SP8->P8_ROTEIR
			_dDtAlt		:= SP8->P8_DATAALT
			_cPeriodo	:= SP8->P8_PERIODO
			_cHraAlt	:= SP8->P8_HORAALT
			_cNumPag	:= SP8->P8_NUMPAG
			_cUsuario	:= SP8->P8_USUARIO
			_cDepto		:= SP8->P8_DEPTO
			_cPosto		:= SP8->P8_POSTO
			_cCodFunc 	:= SP8->P8_CODFUNC
			_nSeqJrn	:= SP8->P8_SEQJRN

			reclock('SP8',.f.)
			SP8->P8_TPMCREP	:= "D"
			SP8->P8_TIPOREG	:= "O"
			SP8->P8_MOTIVRG	:= "EXCLUSAO MANUAL"			
			msunlock()
 
			reclock('SP8',.T.)
			SP8->P8_FILIAL 		:= _cFil
			SP8->P8_MAT			:= _cMat
			SP8->P8_DATA 		:= _dData
			SP8->P8_HORA		:= _nHraEnt
			SP8->P8_CC			:= _cCC
			SP8->P8_ORDEM 		:= _cOrd
			SP8->P8_FLAG		:= "M"
			SP8->P8_APONTA 		:= _cApont
			SP8->P8_TURNO 		:= _cTurno
			SP8->P8_RELOGIO		:= _cRelog
			SP8->P8_FUNCAO		:= _cFunc
			SP8->P8_GIRO		:= _cGiro
			SP8->P8_TPMARCA		:= _cTpMarca
			SP8->P8_PAPONTA 	:= _cPaponta
			SP8->P8_USERLGI		:= _cUsrLgi
			SP8->P8_USERLGA		:= _cUsrLga
			//SP8->P8_SEMANA		:= _cSemana
			SP8->P8_DATAAPO		:= _dDtApo
			SP8->P8_NUMREP		:= _cNumRep
			SP8->P8_TPMCREP		:= _cTPMCREP
			SP8->P8_TIPOREG		:= "I"
			SP8->P8_MOTIVRG		:= 'INCLUSAO MANUAL'
			//SP8->P8_EMPORG		:= _cEmpReg
			//SP8->P8_FILORG		:= _cFilOri
			//SP8->P8_MATORG		:= _cMatOri
			//SP8->P8_DHORG		:= _cDhOri
			SP8->P8_PROCES		:= _cProces
			SP8->P8_IDORG		:= _cIdOri
			SP8->P8_ROTEIR		:= _cRoteir
			SP8->P8_DATAALT		:= _dDtAlt
			SP8->P8_PERIODO		:= _cPeriodo
			SP8->P8_HORAALT		:= _cHraAlt
			SP8->P8_NUMPAG		:= _cNumPag
			SP8->P8_USUARIO		:= _cUsuario
			SP8->P8_DEPTO		:= _cDepto
			SP8->P8_POSTO		:= _cPosto
			SP8->P8_CODFUNC		:= _cCodFunc
			SP8->P8_SEQJRN		:= _nSeqJrn
			msunlock()

		endif

		QRY->(DbSkip())
	enddo

return

/*
//backup fonte 05/11/2018 - Andr้ Lerner

User Function dti22()

	cPerg := "DTI22"

	if !pergunte(cPerg,.t.)
		return
	endif

	Processa({||montareg()} ,"PROCESSAMENTO DE REGISTROS","Separando dados dos funcionแrios...")

	msgbox('Horแrios alterados!','ALTERAวีES EFETIVADAS!','INFO')

return

Static Function montaReg()

	_cQuery := " SELECT P8_MAT, P8_DATA, P8_HORA, P8_CC
	_cQuery += " FROM  " + retSqlTab('SP8')
	_cQuery += " WHERE " + retSqlFil('SP8')
	_cQuery += " AND P8_DATA BETWEEN '" + dtos(mv_par01) + "' AND '" + dtos(mv_par02) + "'"
	_cQuery += " AND P8_CC = '" + mv_par03 + "'"
	_cQuery += " AND P8_TPMCREP <> 'D' AND " + retSqlDel('SP8')
	_cQuery += " ORDER BY P8_MAT, P8_DATA, P8_HORA

	_cQuery  := ChangeQuery(_cQuery)

	//	
	//@ 116,090 To 416,707 Dialog oDlgMemo Title "Consulta"
	//@ 055,005 Get _cQuery Size 250,080 MEMO Object oMemo
	//Activate Dialog oDlgMemo

	If Select("QRY") != 0
		QRY->(dbCloseArea())
	Endif

	TCQUERY _cQuery NEW ALIAS "QRY"

	QRY->(dbGoTop())
	Procregua(recCount("QRY"))
	While QRY->(!eof())

		IncProc('Processando dados da matricula: ' + QRY->P8_MAT)

		dbSelectArea('SRA')
		_nHraEnt := fbuscaCpo('SRA',1,xFilial('SRA') + QRY->P8_MAT,'RA_HRAENT')

		_nHraEnt2 := fConvHr(_nHraEnt,'D')
		_nHraP8   := fConvHr(QRY->P8_HORA,'D')
		_nDif 	  := _nHraEnt2 - _nHraP8



		if _nHraEnt == 0
			QRY->(dbSkip())
			loop
		endif

		if QRY->P8_HORA >= _nHraEnt
			QRY->(dbSkip())
			loop
		endif
		
		//valida็ใo adicionada dia 22/10/18
		if _nDif <= 0.14 //0.09 em decimal ้ igual a 0.05 em hexasegimal(hora)
			QRY->(dbSkip())
			loop
		endif

		dbSelectArea('SP8')
		SP8->(dbSetOrder(2))
		SP8->(dbGoTop())
		if SP8->(dbSeek(xFilial('SP8') + QRY->P8_MAT + QRY->P8_DATA + str(QRY->P8_HORA,5,2)))

			_cFil  		:= SP8->P8_FILIAL
			_cMat  		:= SP8->P8_MAT
			_dData 		:= SP8->P8_DATA
			_cCC   		:= SP8->P8_CC
			_cOrd  		:= SP8->P8_ORDEM
			_cFlag 		:= SP8->P8_FLAG
			_cApont 	:= SP8->P8_APONTA
			_cTurno 	:= SP8->P8_TURNO
			_cRelog  	:= SP8->P8_RELOGIO
			_cFunc   	:= SP8->P8_FUNCAO
			_cGiro   	:= SP8->P8_GIRO
			_cTpMarca 	:= SP8->P8_TPMARCA
			_cPaponta   := SP8->P8_PAPONTA
			_cUsrLgi    := SP8->P8_USERLGI
			_cUsrLga 	:= SP8->P8_USERLGA
			_cSemana    := SP8->P8_SEMANA
			_dDtApo     := SP8->P8_DATAAPO
			_cNumRep	:= SP8->P8_NUMREP
			_cTPMCREP	:= SP8->P8_TPMCREP
			_cTpReg 	:= SP8->P8_TIPOREG
			_cMotiReg	:= SP8->P8_MOTIVRG
			_cEmpReg	:= SP8->P8_EMPORG
			_cFilOri	:= SP8->P8_FILORG
			_cMatOri	:= SP8->P8_MATORG
			_cDhOri		:= SP8->P8_DHORG
			_cProces	:= SP8->P8_PROCES
			_cIdOri		:= SP8->P8_IDORG
			_cRoteir	:= SP8->P8_ROTEIR
			_dDtAlt		:= SP8->P8_DATAALT
			_cPeriodo	:= SP8->P8_PERIODO
			_cHraAlt	:= SP8->P8_HORAALT
			_cNumPag	:= SP8->P8_NUMPAG
			_cUsuario	:= SP8->P8_USUARIO
			_cDepto		:= SP8->P8_DEPTO
			_cPosto		:= SP8->P8_POSTO
			_cCodFunc 	:= SP8->P8_CODFUNC
			_nSeqJrn	:= SP8->P8_SEQJRN

			reclock('SP8',.f.)
			dbdelete()
			msunlock()

			reclock('SP8',.T.)
			SP8->P8_FILIAL 		:= _cFil
			SP8->P8_MAT			:= _cMat
			SP8->P8_DATA 		:= _dData
			SP8->P8_HORA		:= _nHraEnt
			SP8->P8_CC			:= _cCC
			SP8->P8_ORDEM 		:= _cOrd
			SP8->P8_FLAG		:= _cFlag
			SP8->P8_APONTA 		:= _cApont
			SP8->P8_TURNO 		:= _cTurno
			SP8->P8_RELOGIO		:= _cRelog
			SP8->P8_FUNCAO		:= _cFunc
			SP8->P8_GIRO		:= _cGiro
			SP8->P8_TPMARCA		:= _cTpMarca
			SP8->P8_PAPONTA 	:= _cPaponta
			SP8->P8_USERLGI		:= _cUsrLgi
			SP8->P8_USERLGA		:= _cUsrLga
			SP8->P8_SEMANA		:= _cSemana
			SP8->P8_DATAAPO		:= _dDtApo
			SP8->P8_NUMREP		:= _cNumRep
			SP8->P8_TPMCREP		:= _cTPMCREP
			SP8->P8_TIPOREG		:= _cTpReg
			SP8->P8_MOTIVRG		:= _cMotiReg
			SP8->P8_EMPORG		:= _cEmpReg
			SP8->P8_FILORG		:= _cFilOri
			SP8->P8_MATORG		:= _cMatOri
			SP8->P8_DHORG		:= _cDhOri
			SP8->P8_PROCES		:= _cProces
			SP8->P8_IDORG		:= _cIdOri
			SP8->P8_ROTEIR		:= _cRoteir
			SP8->P8_DATAALT		:= _dDtAlt
			SP8->P8_PERIODO		:= _cPeriodo
			SP8->P8_HORAALT		:= _cHraAlt
			SP8->P8_NUMPAG		:= _cNumPag
			SP8->P8_USUARIO		:= _cUsuario
			SP8->P8_DEPTO		:= _cDepto
			SP8->P8_POSTO		:= _cPosto
			SP8->P8_CODFUNC		:= _cCodFunc
			SP8->P8_SEQJRN		:= _nSeqJrn
			msunlock()

		endif

		QRY->(DbSkip())
	enddo

return
*/
