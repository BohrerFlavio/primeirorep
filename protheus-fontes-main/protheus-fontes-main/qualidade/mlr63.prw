#INCLUDE "totvs.ch"
#INCLUDE "topconn.ch"

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³ MLR63     ºAutor  ³Microsiga           º Data ³  11/16/15  º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³ Rotina de desclassificação por câmara ou lote              º±±
±±º          ³                                                            º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ Qualidade                                                  º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/

User Function MLR63()
	Local _cLote 	:= ""
	Private cIPerg  := "MLR63"

	if !pergunte(cIPerg,.t.)
		return
	endif

	//	* Mostrar a consulta 
	//@ 116,090 To 416,707 Dialog oDlgMemo Title "Consulta"
	//@ 055,005 Get _cQuery Size 250,080 MEMO Object oMemo
	//Activate Dialog oDlgMemo

	if mv_par02 = 2
		_cLote := GetAdvFVal('SZ4','Z4_LOTE',FWxfilial('SZ4')+alltrim(mv_par01)+alltrim(mv_par07),1,'ERRO',.T.)
		if _cLote = 'ERRO'
			FWAlertError('Lote não encontrado para o aviso de matança selecionado!','ERRO!')
			return
		endif
	endif

	MsgRun("Aguarde... Realizando contagem de registros...",,{||  GeraTMP() })

	confirma()

	if mv_par02 = 1
		u_dtilog(cFilAnt, "MLR63", "Reclassificação da câmara (" + alltrim(mv_par06) + ") de (" + alltrim(mv_par04) + ") para (" + alltrim(mv_par05) + ")", "R")
	else
		u_dtilog(cFilAnt, "MLR63", "Reclassificação do lote (" + alltrim(mv_par07) + ") de (" + alltrim(mv_par04) + ") para (" + alltrim(mv_par05) + ")", "R")
	endif

	FWAlertSuccess('Processo de reclassificação concluído com sucesso!','OPERAÇÃO CONCLUIDA')

return 


Static Function Confirma()

	Processa({||Gravar()} ,"PROCESSAMENTO DE REGISTROS","Efetivando a gravação dos registros...")

return


Static Function Gravar()

	local _aPredesA := {}	// Previsão anterior
	local _aPredesP := {}	// Previsão posterior
	local _nQppeca := 0
	local _nQppeso := 0
	local i := 0
	local nPos := 0
	local lSOP := .F.

	TMP->(dbGoTop())
	SZ2->(DbSetOrder(2))
	ZAJ->(DbSetOrder(1))
	ZAJ->(dbGoTop())
	SZL->(dbSetOrder(1))
	SZL->(dbGoTop())
	SZK->(dbSetOrder(4))
	SZK->(dbGoTop())

	while TMP->(!eof())

		if SZK->(MsSeek(FWxFilial('SZK') + alltrim(TMP->ZK_NUMAM) + alltrim(TMP->ZK_CONTROL)))

			if ZAJ->(MsSeek(FWxFilial('ZAJ') + SZK->(ZK_NUMAM + ZK_CONTROL)))

				_aPredesA := {}
				_aPredesP := {}

				while ZAJ->(!eof()) .and. ZAJ->ZAJ_NUMAM = SZK->ZK_NUMAM .and. ZAJ->ZAJ_CONTRO = SZK->ZK_CONTROL

					if empty(ZAJ->ZAJ_PREDES)
						ZAJ->(DbSkip())
						loop
					endif

					_cClassOP := GetAdvFval('SZ2','Z2_CLASSIF',FWxFilial('SZ2') + ZAJ->ZAJ_PREDES,2)

					nPos := Ascan(_aPredesA, {|x| x[1] = ZAJ->ZAJ_PREDES})
					if nPos = 0 .and. !empty(ZAJ->ZAJ_PREDES)
						aadd(_aPredesA, {ZAJ->ZAJ_PREDES, 1, ZAJ->ZAJ_PESO})
					else
						_aPredesA[nPos,2]++
						_aPredesA[nPos,3] += ZAJ->ZAJ_PESO
					endif

					if GeraOP(mv_par05, SZK->ZK_PROGRAM, ZAJ->ZAJ_COD, SZK->ZK_NUMAM, alltrim(GetAdvFval('SZ2','Z2_OBS',FWxFilial('SZ2') + ZAJ->ZAJ_PREDES,2)), SZK->ZK_BLACK)
						QRY->(dbGoTop())
						reclock('ZAJ',.f.)
						ZAJ->ZAJ_PREDES := QRY->Z2_NUM
						msunlock()

						nPos := Ascan(_aPredesP, {|x| x[1] = QRY->Z2_NUM})
						if nPos = 0 .and. !empty(QRY->Z2_NUM)
							aadd(_aPredesP, {QRY->Z2_NUM, 1, ZAJ->ZAJ_PESO})
						else
							_aPredesP[nPos,2]++
							_aPredesP[nPos,3] += ZAJ->ZAJ_PESO
						endif
					else
						reclock('ZAJ',.f.)
						ZAJ->ZAJ_PREDES := ""
						msunlock()
						lSOP := .T.
					endif

					ZAJ->(DbSkip())
				enddo

				reclock('SZK',.f.)
				if mv_par03 = 1
					SZK->ZK_CLASESP := '1'
					SZK->ZK_CLESPAB := '1'
				elseif mv_par03 = 2
					SZK->ZK_CLASESP := '2'
					SZK->ZK_CLESPAB := '2'
				endif
				SZK->ZK_CLASSIF := mv_par05
				SZK->ZK_CLASSPH := mv_par05
				SZK->ZK_TOP := 'S'
				msunlock()

				if !empty(_aPredesA)
					for i := 1 to len(_aPredesA)
						if SZ2->(MsSeek(FWxFilial('SZ2') + _aPredesA[i,1]))
							_nQppeca := SZ2->Z2_QPPECA - _aPredesA[i,2]
							_nQppeso := SZ2->Z2_QPPESO - _aPredesA[i,3]
							reclock('SZ2',.f.)
							SZ2->Z2_QPPECA := _nQppeca
							SZ2->Z2_QPPESO := _nQppeso
							msunlock()
						endif
					next
				endif

				if !empty(_aPredesP)
					for i := 1 to len(_aPredesP)
						if SZ2->(MsSeek(FWxFilial('SZ2') + _aPredesP[i,1]))
							_nQppeca := SZ2->Z2_QPPECA + _aPredesP[i,2]
							_nQppeso := SZ2->Z2_QPPESO + _aPredesP[i,3]
							reclock('SZ2',.f.)
							SZ2->Z2_QPPECA := _nQppeca
							SZ2->Z2_QPPESO := _nQppeso
							msunlock()
						endif
					next
				endif
			endif
		endif

		for i:= 1 to 2
			if SZL->(MsSeek(FWxFilial('SZL') + alltrim(TMP->ZK_NUMAM) + alltrim(TMP->ZK_CONTROL) + iif(i = 1,'D','E')))
				reclock('SZL',.F.)
				SZL->ZL_CLASNEW := mv_par05
				msunlock()
			endif
		next

		TMP->(dbSkip())
	enddo

	if lSOP
		FWAlertWarning('Algumas carcaças ficaram sem OP para a nova Classificação!','AVISE O PCP!')
	endif

return


Static Function GeraTMP()

	_cQuery := " SELECT ZK_NUMAM, ZK_LOTE, ZK_CONTROL
	_cQuery += " FROM " + retSqlTab('SZK')
	_cQuery += " WHERE " + retSqlFil('SZK')
	_cQuery += " AND ZK_NUMAM = '" + mv_par01 + "'"
	if mv_par02 = 1
		_cQuery += " AND ZK_LOCAL = '" + mv_par06 + "'"
	else
		_cQuery += " AND ZK_LOTE = '" + mv_par07 + "'"
	endif
	_cQuery += " AND ZK_CLASSIF = '" + mv_par04 + "'"
	_cQuery += " AND " + retSqlDel('SZK')
	_cQuery += " ORDER BY ZK_CONTROL

	_cQuery  := ChangeQuery(_cQuery)

	//	* Mostrar a consulta */
	//@ 116,090 To 416,707 Dialog oDlgMemo Title "Consulta"
	//@ 055,005 Get _cQuery Size 250,080 MEMO Object oMemo
	//Activate Dialog oDlgMemo

	If Select("TMP") != 0
		TMP->(dbCloseArea())
	Endif

	TCQUERY _cQuery NEW ALIAS "TMP"

return

//Função auxiliar
Static Function GeraOP(_classif, _program, _cod, _numam, _obs, _black)

	cQuery := "SELECT Z2_NUM"
	cQuery += " FROM " + RetSqlTab("SZ2")
	cQuery += " WHERE " + RetSqlFil("SZ2")
	cQuery += " AND Z2_NUMAM = '" + _numam + "'"
    cQuery += " AND Z2_COD = '" + _cod + "'"
    if !empty(_obs)
        cQuery += " AND Z2_OBS = '" + alltrim(_obs) + "'"
    else
        cQuery += " AND Z2_CLASSIF = '" + _classif + "'"
        if _black = 'S'
            cQuery += " AND Z2_PROGRAM = '014'"
        else
            cQuery += " AND Z2_PROGRAM = '" + _program + "'"
        endif
    endif
	cQuery += " AND Z2_STATUS <> 'E'"
	cQuery += " AND " + RetSQLDel('SZ2')

	cQuery  := ChangeQuery(cQuery)

	//	* Mostrar a consulta */
	//@ 116,090 To 416,707 Dialog oDlgMemo Title "Consulta"
	//@ 055,005 Get cQuery Size 250,080 MEMO Object oMemo
	//Activate Dialog oDlgMemo
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Monta a interface padrao com o usuario...                           ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ

	If Select("QRY") != 0
		QRY->(dbCloseArea())
	Endif

	TCQUERY cQuery NEW ALIAS "QRY"

	//verifica se houve retorno na query
    Count to nCount

    If nCount > 0
        Return .T.
    endif

return .F.
