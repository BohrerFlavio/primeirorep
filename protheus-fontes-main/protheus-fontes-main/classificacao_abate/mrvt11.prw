#INCLUDE "Rwmake.ch"
#INCLUDE "Protheus.ch"
#INCLUDE "Topconn.ch"
#INCLUDE "APVT100.CH"
#INCLUDE "tbiconn.ch"

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³MRVT11     º Autor ³Mauricio Roehrsº   Data ³  22/06/15     º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDescricao ³ Aplicação para microterminais VT-100 para rotina de        º±±
±±º          ³ Apontamento de PH                                          º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ AP6 IDE                                                    º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/

//Função para Inventario
User Function MRVT11(_usuario)

	Local _cCod       := space(10)
	Private _cModelo  := ''
	Private _lOk      := .t.
	Private _cPhD 	   := '0.00'
	Private _cPhE 	   := '0.00'

	ZAA->(DbSetOrder(2))
	ZAA->(MsSeek(FWxfilial('ZAA')+_usuario))

	if ZAA->ZAA_APL12 <> 'S'
		VTAlert('Opção negada para o usuario!','Aviso',.T.,1000,1)
		return .t.
	endif

	//Define o tamanho da Tela
	_cModelo = VTModelo()

	if _cModelo <> 'RF'
		VTSetSize(2,16)
	else
		VTSetSize(20,30)
	endif

	VTClear()
	VTClearBuffer()

	while _lOk

		_cCod := Space(10)

		VTRead

		@ 01,06 VTSay "Apontamento de PH"
		@ 05,03 VTSay "Ph Direito"
		@ 05,15 VTSay "Ph Esquerdo"
		@ 06,03 VTSay "[    ]"
		@ 06,15 VTSay "[    ]"
		@ 07,06 VTSay "Codigo de Barras"
		@ 08,08 VTSay "[          ]"
		@ 06,04 VTGet _cPhD Pict "@!" VALID !empty(_cPhD) .and. (val(_cPhD) > 0 .and. val(_cPhD) < 14)
		@ 06,16 VTGet _cPhE Pict "@!" VALID !empty(_cPhE) .and. (val(_cPhE) > 0 .and. val(_cPhE) < 14)
		@ 08,09 VTGet _cCod Pict "@!" VALID valCod(_cCod)

		VTRead

		If (VTLastKey() == 27)
			VTAlert('Aplicação Finalizada!','Aviso de Encerramento(01)',.T.,500,1)
			exit
		EndIF
		_cPhD := '0.00'
		_cPhE := '0.00'
		_cCod := space(10)
		VTClearBuffer()
	enddo

	VTClear()
	VTClearBuffer()

Return

Static Function valCod(_codBar)

	local _cNumam   := ''
	local _cLote    := ''
	local _cControl := ''
	//local _cLado    := ''
	local _cClasAnt := ''
	local _cClasNew := ''
	local _lInsert  := .f.
	//local _lAchou 	:= .f.
	//local _cPhD	:= ''
	//local _cPhE	:= ''
	if empty(_codBar)
		return .t.
	endif

	ZAJ->(dbSetOrder(2))
	ZAJ->(dbGoTop())
	if !ZAJ->(MsSeek(FWxFilial('ZAJ') + _codBar))
		VTAlert('Carcaca nao encontrada!','Problema na leitura!',.T.,2000,1)
		return .f.
	else

		_cNumam   := ZAJ->ZAJ_NUMAM
		_cLote    := ZAJ->ZAJ_LOTE
		_cControl := ZAJ->ZAJ_CONTRO
		_cEspNew  := GetAdvFval('SZK','ZK_CLASESP',FWxFilial('SZK') + _cNumam + _cLote + _cControl,5)

		//Verifica se já foi inserido registro da carcaça em questão
		//e atribuiu os valores dos PH's de cada uma das duas carcaças
		SZL->(dbSetOrder(1))
		SZL->(dbGoTop())
		if SZL->(MsSeek(FWxFilial('SZL') + _cNumam + _cControl))//se achou a carcaça na tebela
			//A Classificação Anterior se mantem a mesma
			_cClasAnt := alltrim(SZL->ZL_CLASANT)
			_cClasNeW := _cClasAnt

			if (val(_cPhD) != SZL->ZL_PH) .or. (val(_cPhE) != SZL->ZL_PH)
				if VtYesNo("Voltar a Classif. Anterior?","Atencao!",.T.) //se sim, volta a classificação anteiror
					_cClasAnt := alltrim(SZL->ZL_CLASNEW)	//para reclassificação e troca de OP
					_cClasNew := SZL->ZL_CLASANT	//senão mantem a mesma classificação
				else
					if _cClasAnt $ 'USA/RT'
						if val(_cPhD) >= 5.98 .or. val(_cPhE) >= 5.98
							_cClasNew := 'HK'
						else
							if _cClasAnt = 'USA'
								_cClasNew := 'USA'
							else
								_cClasNew := 'RT'
							endif
						endif
					endif
				endif
			endif

			_lInsert  := .f.
		else//se não achou na SZL vai criar o registro na tabela

			_cClasAnt := alltrim(GetAdvFval('SZK','ZK_CLASSIF',FWxFilial('SZK') + _cNumam + _cLote + _cControl,5))
			_cEspNew  := GetAdvFval('SZK','ZK_CLASESP',FWxFilial('SZK') + _cNumam + _cLote + _cControl,5)
			_cClasNeW := _cClasAnt

			if _cClasAnt $ 'USA/RT'
				if val(_cPhD) >= 5.98 .or. val(_cPhE) >= 5.98
					_cClasNew := 'HK'
				else
					if _cClasAnt = 'USA'
						_cClasNew := 'USA'
					else
						_cClasNew := 'RT'
					endif
				endif
			endif

			_lInsert := .t.
		endif

		if gravaSZL(_cNumam, _cControl, _cClasAnt, _cClasNew,_lInsert)
			if _cClasNew <> _cClasAnt
				if reclas(_cNumam,_cLote, _cControl,_cClasNew,_cEspNew)
					mensagem('Carcaça : ' + _cControl, 'Clas. Antiga: ' + _cClasAnt, 'Clas. Nova: ' + _cClasNew)
				else
					mensagem('Erro ao Reclassificar!','Refaca a Operacao!')
				endif
			endif
			mensagem('Carcaça : ' + _cControl, 'Clas. Atual: ' + _cClasNew)
		else
			mensagem('Erro de insercao dos dados!','Refaca a Operacao!')
		endif
	endif

	_cPhE := '0.00'
	_cPhD := '0.00'
	_codBar := space(10)

return .t.

Static Function gravaSZL(_cNumam, _cControl, _cClasAnt, _cClasNew, _lInsert)

	local _lGrav := .f.
	local i

	if _lInsert//Cria os registros na SZL
		for i:= 1 to 2
			reclock('SZL',_lInsert)
			SZL->ZL_FILIAL  := FWxfilial('SZL')
			SZL->ZL_NUMAM   := _cNumam
			SZL->ZL_SEQUEN  := _cControl
			SZL->ZL_PH      := iif(i = 1,val(_cPhD),val(_cPhE))
			SZL->ZL_SEQPH   := iif(i = 1,'D','E')
			SZL->ZL_CLASANT := _cClasAnt
			SZL->ZL_CLASNEW := _cClasNew
			msunlock()
		next
		_lGrav := .t.
	else
		SZL->(dbSetOrder(1))
		SZL->(dbGoTop())
		for i:= 1 to 2
			if SZL->(MsSeek(FWxFilial('SZL') + _cNumam + _cControl+iif(i = 1,'D','E')))
				reclock('SZL',_lInsert)
				SZL->ZL_PH      := iif(i = 1,val(_cPhD),val(_cPhE))
				SZL->ZL_CLASANT := _cClasAnt
				SZL->ZL_CLASNEW := _cClasNew
				msunlock()
			endif
			_lGrav := .t.
		next

	endif

return _lGrav

Static Function reclas(_cNumam, _cLote, _cControl, _cClasNew,_cEspNew)

	local _lGrav := .f.
	local _aPredesA := {}	// Previsão anterior
	local _aPredesP := {}	// Previsão posterior
	local _nQppeca := 0
	local _nQppeso := 0
	local i := 0
	local nPos := 0

	SZK->(dbSetOrder(4))
	SZK->(dbGoTop())
	SZ2->(DbSetOrder(2))
	ZAJ->(DbSetOrder(1))

	if SZK->(MsSeek(FWxFilial('SZK') + _cNumam + _cControl))
		reclock('SZK',.f.)
		SZK->ZK_CLASSIF := _cClasNew
		SZK->ZK_CLASSPH := _cClasNew
		SZK->ZK_CLASESP := _cEspNew
		msunlock()

		if ZAJ->(MsSeek(FWxFilial('ZAJ') + SZK->(ZK_NUMAM + ZK_CONTROL)))

			while ZAJ->(!eof()) .and. ZAJ->ZAJ_NUMAM = SZK->ZK_NUMAM .and. ZAJ->ZAJ_CONTRO = SZK->ZK_CONTROL

				if empty(ZAJ->ZAJ_PREDES)
					ZAJ->(DbSkip())
					loop
				endif

				//_cPriorid := GetAdvFval('SZ2','Z2_PRIORID',FWxFilial('SZ2') + ZAJ->ZAJ_PREDES,2)
				_cClassOP := GetAdvFval('SZ2','Z2_CLASSIF',FWxFilial('SZ2') + ZAJ->ZAJ_PREDES,2)

				nPos := Ascan(_aPredesA, {|x| x[1] = ZAJ->ZAJ_PREDES})
				if nPos = 0 .and. !empty(ZAJ->ZAJ_PREDES)
					aadd(_aPredesA, {ZAJ->ZAJ_PREDES, 1, ZAJ->ZAJ_PESO})
				else
					_aPredesA[nPos,2]++
					_aPredesA[nPos,3] += ZAJ->ZAJ_PESO
				endif

				//_cOpEsp   := GetAdvFval('SZ2','Z2_CLASESP',FWxFilial('SZ2') + ZAJ->ZAJ_PREDES,2)
				//_cClasN := 	rec(SZK->ZK_CLASSIF,_cClassOP)

				if (_cClassOP <> _cClasNew)// .and. (_cPriorid == 'R')) .or. (_cOpEsp == 'S' .and. _cEspNew = '2')

					if GeraOP(_cClasNew, SZK->ZK_PROGRAM, ZAJ->ZAJ_COD, SZK->ZK_NUMAM, alltrim(GetAdvFval('SZ2','Z2_OBS',FWxFilial('SZ2') + ZAJ->ZAJ_PREDES,2)), SZK->ZK_BLACK)
						TMP->(dbGoTop())
						reclock('ZAJ',.f.)
						ZAJ->ZAJ_PREDES := TMP->Z2_NUM
						msunlock()

						nPos := Ascan(_aPredesP, {|x| x[1] = TMP->Z2_NUM})
						if nPos = 0 .and. !empty(TMP->Z2_NUM)
							aadd(_aPredesP, {TMP->Z2_NUM, 1, ZAJ->ZAJ_PESO})
						else
							_aPredesP[nPos,2]++
							_aPredesP[nPos,3] += ZAJ->ZAJ_PESO
						endif
					else
						reclock('ZAJ',.f.)
						ZAJ->ZAJ_PREDES := ""
						msunlock()
						VTAlert('Sem OP para nova Classif.!','Avise o PCP!',.T.,1000,1)
					endif

				endif

				ZAJ->(DbSkip())
			enddo
		endif

		SZ2->(DbSetOrder(2))
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

		_lGrav := .t.
	endif

return _lGrav

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

	If Select("TMP") != 0
		TMP->(dbCloseArea())
	Endif

	TCQUERY cQuery NEW ALIAS "TMP"

	//verifica se houve retorno na query
    Count to nCount

    If nCount > 0
        Return .T.
    endif

return .F.

/*Static Function rec(_ClasAtu,_ClasComp)
	Local _ClasNova  := ''
	Local _VlClasA   := VlrClas(_ClasAtu)
	Local _VlClasC   := VlrClas(_ClasComp)
	Local _VlClasN   := 1

	if _VlClasC > _VlClasA
		_VlClasN := _VlClasC
	else
		_VlClasN := _VlClasA
	endif

	_ClasNova := ClasVlr(_VlClasN)

return _ClasNova

//Função auxiliar
Static Function VlrClas(_classe)
	Local _valor := 0
	do case
		case  AllTrim(_classe) = 'NE'
		_valor := 4
		case  AllTrim(_classe) = 'HK'
		_valor := 3
		case  AllTrim(_classe) = 'RU'
		_valor := 2
		case  AllTrim(_classe) = 'RT'
		_valor := 1
	endcase

return _valor

//Função auxiliar
Static Function ClasVlr(_valor)
	Local _classe := ''
	do case
		case  _valor = 4
		_classe := 'NE'
		case _valor = 3
		_classe := 'HK'
		case _valor = 2
		_classe := 'RU'
		case _valor = 1
		_classe := 'RT'
	endcase
return _classe*/

Static Function mensagem(_cMens,_cMens2,_cMens3)

	Local _branco := space(50)

	VTBeep(1)
	@10,00 VTSay _branco
	@11,00 VTSay _branco
	@12,00 VTSay _branco

	@10,05 VTSay _cMens
	@11,05 VTSay _cMens2
	@12,05 VTSay _cMens3

	_cCod := Space(11)

return .f.



/*
DbSelectArea('SZU')
SZU->(DbSetOrder(4))
if SZU->(MsSeek(FWxfilial('SZU') + ZAJ->ZAJ_PREDES))

while SZU->(!eof()) .and. SZU->ZU_FILIAL = FWxfilial('SZU') .and. SZU->ZU_PREDES = ZAJ->ZAJ_PREDES

if	SZU->ZU_FECHADO <> 'S' .and.;            // se a previsão ainda não encerrou e
SZU->ZU_CONTEXA  = 'S' .and.;       // a prev. da embalagem estiver com contagem exata = 'S'
SZU->ZU_TOLERA   = 0   .and.;       // tolerancia = 0 e
SZU->ZU_PRIORI   = 'E' .and.;       //prioridade  = 'E' (peças)
SZU->ZU_QPQUANT <> 0

reclock('SZU',.f.)
SZU->ZU_QPQUANT -= 1

if SZU->ZU_QPQUANT  <= SZU->ZU_QRQUANT
SZU->ZU_FECHADO := 'S'
('Fechou Previsão de Embalagem (ZU_FECHADO = "S")')
endif
msunlock()

endif

SZU->(DbSkip())
enddo
endif
*/
