#INCLUDE "rwmake.ch"
#INCLUDE "topconn.ch"
#INCLUDE "totvs.ch"

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³MLR02     º Autor ³ Mauricio Roehrsº Data ³  20/07/12       º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDescricao ³ Rotina para Calculo de peso médio de caixas de PA              º±±
±±º          ³                                                            º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ SIGAPCP/SIGAOMS                                            º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/

User Function MLR02()
	local nOpca	:=0
	local aSays:={}, aButtons:={}

	Private cCadastro := "Calculo de Media dos Pesos de PA"
	Private cPerg     := "MLR02"
	Private _nNumProd := 0

	Pergunte(cPerg,.f.)

	AADD (aSays, "  Esta rotina tem como objetivo realizar o calculo do peso medio    ")  //
	AADD (aSays, "  das caixas de produto acabado   ")  //

	AADD(aButtons, { 1,.T.,{|o| nOpca:= 1,o:oWnd:End()}} )
	AADD(aButtons, { 2,.T.,{|o| o:oWnd:End() }} )
	AADD(aButtons, { 5,.T.,{|o| Pergunte(cPerg,.T. ) } } )
	FormBatch( cCadastro, aSays, aButtons )

	If nopca == 1
		Processa({||u_mlr02Pr(mv_par01,mv_par02)},"CALCULO DO PESO MEDIO","Realizando calculo...")
	endif

return

User Function mlr02Pr(_prod,_quant)

	Local	   _nSoma    := 0
	Local 	_nCount   := 0

	_nNumProd := 0

	if _quant = 0
		alert('Quantidade de Caixas deve ser Preenchida!')
		return .f.
	endif

	if empty(mv_par01)
		_cChave  :=  FWxfilial('SB1') + 'PA'
		_cChave2 :=  "SB1->(B1_FILIAL + B1_TIPO)"
	else
		_cChave  :=  FWxfilial('SB1') + 'PA' + alltrim(mv_par01)
		_cChave2 :=  "SB1->(B1_FILIAL + B1_TIPO + alltrim(B1_COD))"
	endif

	DbSelectArea('SB1')
	SB1->(DbSetOrder(2))
	if SB1->(MsSeek(_cChave))
		while SB1->(!eof()) .and. _cChave = &_cChave2
			_nNumProd++
			SB1->(DbSkip())
		enddo
	endif

	SB1->(DbGoTop())
	if SB1->(MsSeek(_cChave))

		ProcRegua(_nNumProd)

		while SB1->(!eof()) .and. _cChave = &_cChave2

			incproc('Processando produto de código ' + SB1->B1_COD)

			if SB1->B1_TIPO <> 'PA'
				SB1->(DbSkip())
				loop
			endif

			if SB1->B1_MSBLQL = '1'
				SB1->(DbSkip())
				loop
			endif

			if SB1->B1_SEGUM <> 'CX'
				SB1->(DbSkip())
				loop
			endif

			if SB1->B1_UM = 'UN'
				SB1->(DbSkip())
				loop
			endif

			cQuery := " SELECT TOP " + str(_quant) + " Z8_PESO, Z8_DATA FROM  " + RetSQLTab('SZ8')
			cQuery += " WHERE " + RetSQLFil('SZ8') + " AND " + RetSQLDel('SZ8')
			cQuery += " AND Z8_FIL = '"+ cFilAnt + "' AND Z8_COD = '" + alltrim(SB1->B1_COD) + "'"
			cQuery += " ORDER BY Z8_DATA DESC "

			//	* Mostrar a consulta */
			//@ 116,090 To 416,707 Dialog oDlgMemo Title "Consulta"
			//@ 055,005 Get cQuery Size 250,080 MEMO Object oMemo
			//Activate Dialog oDlgMemo
			cQuery  := ChangeQuery(cQuery)

			If Select("POS") != 0
				POS->(dbCloseArea())
			Endif

			TCQUERY cQuery NEW ALIAS "POS"

			_nSoma    := 0
			_nCount   := 0

			POS->(DbGoTop())

			_nMaior := POS->Z8_PESO
			_nMenor := POS->Z8_PESO
			_nMedia := 0

			while POS->(!eof())
				if POS->Z8_PESO > _nMaior
					_nMenor := POS->Z8_PESO
				endif

				if POS->Z8_PESO < _nMenor
					_nMaior := POS->Z8_PESO
				endif

				_nSoma += POS->Z8_PESO
				_nCount++

				POS->(DbSkip())
			enddo

			POS->(dbCloseArea())

			if _nCount > 2
				_nSoma  := _nSoma - _nMaior - _nMenor
				_nCount -= 2
				_nMedia := (_nSoma / _nCount)
			endif

			if _nMedia <> 0
				reclock('SB1',.f.)
				SB1->B1_PMCAIX := _nMedia
				MsUnlock()			
			endif

			SB1->(DbSkip())

		enddo

	else
		alert('Processamento nulo!')
	endif

Return
