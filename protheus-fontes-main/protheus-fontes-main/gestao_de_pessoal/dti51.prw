#INCLUDE "topconn.ch"
#INCLUDE "rwmake.ch"
#INCLUDE "protheus.ch"


/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณDTI51   บAutor  ณFlแvio Bohrer Fl๔res  บ Data ณ  20/02/18   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณ Fonte destinado เ altera็ใo do horario de Intervalo        บฑฑ
ฑฑบ          ณ dos funcionแrios de acordo com solicita็ใo da diretoria    บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ Dire็ao	- Fonte de refer๊ncia DTI22                       บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/


User Function dti51()

	Local _nCont2 := 0
	Private _aBatidas  := {}
	Private _lOk := ""
	Private _nVlrAlt := 0
	Private _nValsai := 0

	//Private _cSP8 := getMv('SI_TESTE') 
	cPerg := "DTI51"

	if !pergunte(cPerg,.t.)
		return
	endif


	Processa({||montareg()} ,"PROCESSAMENTO DE REGISTROS","Separando dados dos funcionแrios...")

	msgbox('Horแrios alterados!','ALTERAวีES EFETIVADAS!','INFO')

return

Static Function montaReg()
	Local _nResult :="S"
	Local _cChek := "N"


	_cQuery := " SELECT P8_MAT AS MAT, P8_DATA AS DATA, P8_HORA AS HORA, P8_CC AS CC"
	_cQuery += " FROM  " + retSqlTab('SP8')
	_cQuery += " WHERE " + retSqlFil('SP8')
	_cQuery += " AND (P8_DATA BETWEEN '" + dtos(mv_par01) + "' AND '" + dtos(mv_par02) + "')"
	_cQuery += " AND (P8_CC  BETWEEN '" +    mv_par03    + "' AND '" +    mv_par04    + "')"
	_cQuery += " AND P8_TPMCREP <> 'D' AND " + retSqlDel('SP8')
	_cQuery += " ORDER BY P8_MAT, P8_DATA, P8_HORA"


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
	_cMat := ''
	_cDT := date()-500


	While QRY->(!eof()) 

		IncProc('Processando dados da matricula: ' + QRY->MAT)

		dbSelectArea('SRA')
		_nHraInt := fbuscaCpo('SRA',1,xFilial('SRA') + QRY->MAT,'RA_HRAINT')

		if _nHraInt == 0
			QRY->(dbSkip())
			loop 
		Endif

		If (alltrim(_cMat) <> alltrim(QRY->MAT)) .OR.(_cDT <> QRY->DATA)
			_cDT := QRY->DATA
			_cMat   := alltrim(QRY->MAT)
			_nCont2 := 1
			// Verificar se 
			// Verifica็ใo em uma rotina se tem 4 batidas	
			_nResult := VerBatidas(QRY->MAT,QRY->DATA)
			//If _cMat = '010842'
			//alert(_nResult)
			//alert(_lOk)
			//alert(QRY->DATA)
			//alert(QRY->HORA)
			//@ 116,090 To 416,707 Dialog oDlgMemo Title "Consulta"
			//@ 055,005 Get _cQuery2 Size 250,080 MEMO Object oMemo
			//Activate Dialog oDlgMemo
			//Endif
			// Se a Matrํcula nใo tiver 4 Batidas  entใo pula o registro
			If _nResult = "N"
				QRY->(dbSkip())
				loop
			endif

			// Se o intervalo for maior ou igual ao estipulado no cadastro (RA_HRAINT) entใo nใo altera
			if _lOk = "S"

				QRY->(dbSkip())
				loop

			endif




		Endif


		If _nCont2 = 2 .AND. _lOk = "N"

			_nVSAI := _nValsai
			_nValsai := 0
			_nValsai := fConvHr( _nVSAI,'H')

			dbSelectArea('SP8')
			SP8->(dbSetOrder(2))
			SP8->(dbGoTop())
			if SP8->(dbSeek(xFilial('SP8') + QRY->MAT + QRY->DATA + str(_nValsai,5,2)))

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

				_nVA := _nVlrAlt
				_nVlrAlt := 0
				_nVlrAlt := fConvHr( _nVA,'H')

				reclock('SP8',.T.)
				SP8->P8_FILIAL 		:= _cFil
				SP8->P8_MAT			:= _cMat
				SP8->P8_DATA 		:= _dData
				SP8->P8_HORA		:= _nVlrAlt
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
				SP8->P8_SEMANA		:= _cSemana
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

			Endif

		Endif
		_nCont2++
		QRY->(DbSkip())
	enddo

return        


Static Function VerBatidas(_cMtri,_cDT)
	Local _nCont := 0

	_cQuery2 := " SELECT P8_MAT AS MAT, P8_DATA AS DATA, P8_HORA AS HORA, P8_CC AS CC"
	_cQuery2 += " FROM  " + retSqlTab('SP8')
	_cQuery2 += " WHERE " + retSqlFil('SP8')
	_cQuery2 += " AND P8_DATA = '"+_cDT+"'"
	_cQuery2 += " AND P8_MAT =  '"+_cMtri+"'"
	_cQuery2 += " AND P8_TPMCREP <> 'D'"
	_cQuery2 += " AND " + retSqlDel('SP8')
	_cQuery2 += " ORDER BY P8_MAT, P8_DATA, P8_HORA"


	_cQuery2  := ChangeQuery(_cQuery2)
	//_cQuery2 += " AND P8_TPMCREP <> 'D'"
	//	* Mostrar a consulta */
	//@ 116,090 To 416,707 Dialog oDlgMemo Title "Consulta"
	//@ 055,005 Get _cQuery2 Size 250,080 MEMO Object oMemo
	//Activate Dialog oDlgMemo

	If Select("QRY2") != 0
		QRY2->(dbCloseArea())
	Endif

	//TCQUERY _cQuery NEW ALIAS "QRY2"
	TCQUERY _cQuery2 NEW ALIAS "QRY2"

	QRY2->(dbGoTop())
	Procregua(recCount("QRY2"))
	_nBatida  := 0  //utilizado no vetor
	_nHora    := 0  //utilizado no vetor
	_cData    := '' //ctod('//') //utilizado no vetor
	_cCC      := '' //utilizado no vetor


	While QRY2->(!eof())

		_nCont++

		_nPos := aScan(_aBatidas,{|aVal|aVal[1] = QRY2->MAT})

		if _nPos <> 0
			if _nCont = 2

				_aBatidas[_nPos,2] := _nCont
				_aBatidas[_nPos,3] := QRY2->HORA
				_aBatidas[_nPos,4] := QRY2->DATA
				_aBatidas[_nPos,5] := QRY2->CC
				_aBatidas[_nPos,6] := 0  // segunda batida
				_nValsai := _aBatidas[_nPos,3]
				_cMatric := QRY2->MAT
				_dDT := QRY2->DATA
			elseif _nCont = 3

				_aBatidas[_nPos,6] := QRY2->HORA  
				_nValent := _aBatidas[_nPos,6]
			Endif
		else
			aadd(_aBatidas,{QRY2->MAT,_nBatida,_nHora,_cData,_cCC,_nHora})		
		endif

		QRY2->(DbSkip())
	enddo
	//alert(_cMtri)
	//alert(_nCont)

	// Se Matrํcula tiver 4 batidas
	If _nCont = 4
		//alert('1 if')
		_nVerif := "S"
		// Calcular o valor do intervalo
		/*
		//converte o valor digitado para decimal para poder realizar o calculo                                       
		_nHoraDec := fConvHr(_nHoras,'D')
		// Depois volta para hora paragravar no campo
		fConvHr( _nCalcSld,'H')
		*/
		//alert(_nValsai)
		//alert(_nValent)

		_nVE := _nValent
		_nVS := _nValsai
		_nValent := 0
		_nValsai := 0
		_nValent := fConvHr(_nVE,'D')
		_nValsai := fConvHr(_nVS,'D')
		_nDif 	 := _nValent - _nValsai 
		//alert(_nValent)
		//alert(_nValsai)
		//alert(_nDif)
		_nHraInt := fbuscaCpo('SRA',1,xFilial('SRA') + alltrim(_cMatric),'RA_HRAINT')
		//alert(_nHraInt)
		// Se a diferen็a for maior que a Hora do intervalo
		/*		*/

		_nHI := _nHraInt
		_nHraInt := 0
		_nHraInt := fConvHr(_nHI,'D')
		//alert(_nDif)
		//alert(_nHraInt)
		//alert(_lOk)

		If _nDif >= _nHraInt  // Se intervalo for maior ou = ao intervalo do cadastro nใo faz altera็ใo

			_lOk := "S"		

		Else  // Se intervalo feito for menor que o do cadastro entใo ajusta
			//alert('2 Else')
			// Se diferen็a entre pontos de saida e entrada 
			_lOk := "N"
			_nSub := _nHraInt - _nDif
			//alert(_nSub)
			_nVlrAlt := _nValsai - _nSub
			//alert(_cMatric)
			//alert(_dDT)
			//fConvHr( _nVlrAlt,'H')
			//alert(fConvHr( _nValsai,'H'))
			//alert(fConvHr( _nVlrAlt,'H'))

		Endif
		//alert(_lOk)
	else
		_nVerif := "N"
	Endif



Return (_nVerif)

/*
//backup do fonte antes da altera็ใo Andr้ Lerner 05/11/2018
User Function dti51()

	Local _nCont2 := 0
	Private _aBatidas  := {}
	Private _lOk := ""
	Private _nVlrAlt := 0
	Private _nValsai := 0

	//Private _cSP8 := getMv('SI_TESTE') 
	cPerg := "DTI51"

	if !pergunte(cPerg,.t.)
		return
	endif


	Processa({||montareg()} ,"PROCESSAMENTO DE REGISTROS","Separando dados dos funcionแrios...")

	msgbox('Horแrios alterados!','ALTERAวีES EFETIVADAS!','INFO')

return

Static Function montaReg()
	Local _nResult :="S"
	Local _cChek := "N"


	_cQuery := " SELECT P8_MAT AS MAT, P8_DATA AS DATA, P8_HORA AS HORA, P8_CC AS CC"
	_cQuery += " FROM  " + retSqlTab('SP8')
	_cQuery += " WHERE " + retSqlFil('SP8')
	_cQuery += " AND (P8_DATA BETWEEN '" + dtos(mv_par01) + "' AND '" + dtos(mv_par02) + "')"
	_cQuery += " AND (P8_CC  BETWEEN '" +    mv_par03    + "' AND '" +    mv_par04    + "')"
	_cQuery += " AND P8_TPMCREP <> 'D' AND " + retSqlDel('SP8')
	_cQuery += " ORDER BY P8_MAT, P8_DATA, P8_HORA"


	_cQuery  := ChangeQuery(_cQuery)

	//	 Mostrar a consulta
	//@ 116,090 To 416,707 Dialog oDlgMemo Title "Consulta"
	//@ 055,005 Get _cQuery Size 250,080 MEMO Object oMemo
	//Activate Dialog oDlgMemo

	If Select("QRY") != 0
		QRY->(dbCloseArea())
	Endif

	TCQUERY _cQuery NEW ALIAS "QRY"

	QRY->(dbGoTop())
	Procregua(recCount("QRY"))
	_cMat := ''
	_cDT := date()-500


	While QRY->(!eof()) 

		IncProc('Processando dados da matricula: ' + QRY->MAT)

		dbSelectArea('SRA')
		_nHraInt := fbuscaCpo('SRA',1,xFilial('SRA') + QRY->MAT,'RA_HRAINT')

		if _nHraInt == 0
			QRY->(dbSkip())
			loop 
		Endif

		If (alltrim(_cMat) <> alltrim(QRY->MAT)) .OR.(_cDT <> QRY->DATA)
			_cDT := QRY->DATA
			_cMat   := alltrim(QRY->MAT)
			_nCont2 := 1
			// Verificar se 
			// Verifica็ใo em uma rotina se tem 4 batidas	
			_nResult := VerBatidas(QRY->MAT,QRY->DATA)
			//If _cMat = '010842'
			//alert(_nResult)
			//alert(_lOk)
			//alert(QRY->DATA)
			//alert(QRY->HORA)
			//@ 116,090 To 416,707 Dialog oDlgMemo Title "Consulta"
			//@ 055,005 Get _cQuery2 Size 250,080 MEMO Object oMemo
			//Activate Dialog oDlgMemo
			//Endif
			// Se a Matrํcula nใo tiver 4 Batidas  entใo pula o registro
			If _nResult = "N"
				QRY->(dbSkip())
				loop
			endif

			// Se o intervalo for maior ou igual ao estipulado no cadastro (RA_HRAINT) entใo nใo altera
			if _lOk = "S"

				QRY->(dbSkip())
				loop

			endif




		Endif


		If _nCont2 = 2 .AND. _lOk = "N"

			_nVSAI := _nValsai
			_nValsai := 0
			_nValsai := fConvHr( _nVSAI,'H')

			dbSelectArea('SP8')
			SP8->(dbSetOrder(2))
			SP8->(dbGoTop())
			if SP8->(dbSeek(xFilial('SP8') + QRY->MAT + QRY->DATA + str(_nValsai,5,2)))

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

				_nVA := _nVlrAlt
				_nVlrAlt := 0
				_nVlrAlt := fConvHr( _nVA,'H')

				reclock('SP8',.T.)
				SP8->P8_FILIAL 		:= _cFil
				SP8->P8_MAT			:= _cMat
				SP8->P8_DATA 		:= _dData
				SP8->P8_HORA		:= _nVlrAlt
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

			Endif

		Endif
		_nCont2++
		QRY->(DbSkip())
	enddo

return        


Static Function VerBatidas(_cMtri,_cDT)
	Local _nCont := 0

	_cQuery2 := " SELECT P8_MAT AS MAT, P8_DATA AS DATA, P8_HORA AS HORA, P8_CC AS CC"
	_cQuery2 += " FROM  " + retSqlTab('SP8')
	_cQuery2 += " WHERE " + retSqlFil('SP8')
	_cQuery2 += " AND P8_DATA = '"+_cDT+"'"
	_cQuery2 += " AND P8_MAT =  '"+_cMtri+"'"
	_cQuery2 += " AND P8_TPMCREP <> 'D'"
	_cQuery2 += " AND " + retSqlDel('SP8')
	_cQuery2 += " ORDER BY P8_MAT, P8_DATA, P8_HORA"


	_cQuery2  := ChangeQuery(_cQuery2)
	//_cQuery2 += " AND P8_TPMCREP <> 'D'"
	// Mostrar a consulta
	//@ 116,090 To 416,707 Dialog oDlgMemo Title "Consulta"
	//@ 055,005 Get _cQuery2 Size 250,080 MEMO Object oMemo
	//Activate Dialog oDlgMemo

	If Select("QRY2") != 0
		QRY2->(dbCloseArea())
	Endif

	//TCQUERY _cQuery NEW ALIAS "QRY2"
	TCQUERY _cQuery2 NEW ALIAS "QRY2"

	QRY2->(dbGoTop())
	Procregua(recCount("QRY2"))
	_nBatida  := 0  //utilizado no vetor
	_nHora    := 0  //utilizado no vetor
	_cData    := '' //ctod('//') //utilizado no vetor
	_cCC      := '' //utilizado no vetor


	While QRY2->(!eof())

		_nCont++

		_nPos := aScan(_aBatidas,{|aVal|aVal[1] = QRY2->MAT})

		if _nPos <> 0
			if _nCont = 2

				_aBatidas[_nPos,2] := _nCont
				_aBatidas[_nPos,3] := QRY2->HORA
				_aBatidas[_nPos,4] := QRY2->DATA
				_aBatidas[_nPos,5] := QRY2->CC
				_aBatidas[_nPos,6] := 0  // segunda batida
				_nValsai := _aBatidas[_nPos,3]
				_cMatric := QRY2->MAT
				_dDT := QRY2->DATA
			elseif _nCont = 3

				_aBatidas[_nPos,6] := QRY2->HORA  
				_nValent := _aBatidas[_nPos,6]
			Endif
		else
			aadd(_aBatidas,{QRY2->MAT,_nBatida,_nHora,_cData,_cCC,_nHora})		
		endif

		QRY2->(DbSkip())
	enddo
	//alert(_cMtri)
	//alert(_nCont)

	// Se Matrํcula tiver 4 batidas
	If _nCont = 4
		//alert('1 if')
		_nVerif := "S"
		// Calcular o valor do intervalo
		
		//alert(_nValsai)
		//alert(_nValent)

		_nVE := _nValent
		_nVS := _nValsai
		_nValent := 0
		_nValsai := 0
		_nValent := fConvHr(_nVE,'D')
		_nValsai := fConvHr(_nVS,'D')
		_nDif 	 := _nValent - _nValsai 
		//alert(_nValent)
		//alert(_nValsai)
		//alert(_nDif)
		_nHraInt := fbuscaCpo('SRA',1,xFilial('SRA') + alltrim(_cMatric),'RA_HRAINT')
		//alert(_nHraInt)
		// Se a diferen็a for maior que a Hora do intervalo
		

		_nHI := _nHraInt
		_nHraInt := 0
		_nHraInt := fConvHr(_nHI,'D')
		//alert(_nDif)
		//alert(_nHraInt)
		//alert(_lOk)

		If _nDif >= _nHraInt  // Se intervalo for maior ou = ao intervalo do cadastro nใo faz altera็ใo

			_lOk := "S"		

		Else  // Se intervalo feito for menor que o do cadastro entใo ajusta
			//alert('2 Else')
			// Se diferen็a entre pontos de saida e entrada 
			_lOk := "N"
			_nSub := _nHraInt - _nDif
			//alert(_nSub)
			_nVlrAlt := _nValsai - _nSub
			//alert(_cMatric)
			//alert(_dDT)
			//fConvHr( _nVlrAlt,'H')
			//alert(fConvHr( _nValsai,'H'))
			//alert(fConvHr( _nVlrAlt,'H'))

		Endif
		//alert(_lOk)
	else
		_nVerif := "N"
	Endif



Return (_nVerif)
*/ 
