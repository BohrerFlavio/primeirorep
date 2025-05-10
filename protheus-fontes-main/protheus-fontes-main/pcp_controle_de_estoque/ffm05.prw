#INCLUDE "rwmake.ch"
#INCLUDE "topconn.ch"

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³FFM05     º Autor ³ Fabian Maurerº Data ³  05/09/13         º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDescricao ³ Rotina para Calculo de médias de Peças                     º±±
±±º          ³                                                            º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ SIGAPCP/SIGAOMS                                            º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/

User Function FFM05()
	local nOpca	:=0
	local aSays:={}, aButtons:={}

	Private cCadastro := "Calculo de Media dos Pesos de Pecas"
	Private cPerg     := "FFM05"
	Private _nNumProd := 0

	Pergunte(cPerg,.f.)

	AADD (aSays, "  Esta rotina tem como objetivo realizar o calculo do peso medio    ")  //
	AADD (aSays, "  das Peças   ")  //

	AADD(aButtons, { 1,.T.,{|o| nOpca:= 1,o:oWnd:End()}} )
	AADD(aButtons, { 2,.T.,{|o| o:oWnd:End() }} )
	AADD(aButtons, { 5,.T.,{|o| Pergunte(cPerg,.T. ) } } )
	FormBatch( cCadastro, aSays, aButtons )

	If nopca == 1
		Processa({||u_FFM05Pr(mv_par01,mv_par02)},"CALCULO DO PESO MEDIO DE PEÇAS","Realizando calculo...")
	endif

return

User Function FFM05Pr(_prod,_quant)

	Local	   _nSoma    := 0
	Local 	_nCount   := 0

	_nNumProd := 0

	if _quant = 0
		alert('Quantidade de Pecas deve ser Preenchida!')
		return .f.
	endif

	if empty(mv_par01)
		_cChave  :=  xfilial('SB1') + 'PA'
		_cChave2 :=  "SB1->(B1_FILIAL + B1_TIPO)"
	else
		_cChave  :=  xfilial('SB1') + 'PA' + alltrim(mv_par01)
		_cChave2 :=  "SB1->(B1_FILIAL + B1_TIPO + alltrim(B1_COD))"
	endif

	DbSelectArea('SB1')
	SB1->(DbSetOrder(2))
	if SB1->(DbSeek(_cChave))
		while SB1->(!eof()) .and. _cChave = &_cChave2
			_nNumProd++
			SB1->(DbSkip())
		enddo
	endif

	SB1->(DbGoTop())
	if SB1->(DbSeek(_cChave))

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

			if SB1->B1_SEGUM <> 'PC'
				SB1->(DbSkip())
				loop
			endif

			cQuery := " SELECT TOP " + str(_quant) + " (ZZ5_QRPESO/ZZ5_QRCAIX) AS PESO, ZZ4_DATA FROM  " + RetSQLTab('ZZ5') + "," + RetSQLTab('ZZ4')
			cQuery += " WHERE " + RetSQLFil('ZZ4') + " AND " + RetSQLFil('ZZ5') + " AND " + RetSQLDel('ZZ4') + " AND " + RetSQLDel('ZZ5')
			cQuery += " AND ZZ4_NUM = ZZ5_NUM AND ZZ4_STATUS = 'F'"
			cQuery += " AND ZZ4_FILIAL = '" + xfilial('ZZ4') + "' AND ZZ5_FILIAL = '" + xfilial('ZZ5') + "' AND ZZ5_COD = '" + alltrim(SB1->B1_COD) + "'"
			cQuery += " ORDER BY ZZ4_DATA DESC "

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

			_nMaior := POS->PESO
			_nMenor := POS->PESO                       

			_nMedia := 0

			while POS->(!eof())
				if POS->PESO > _nMaior
					_nMenor := POS->PESO
				endif

				if POS->PESO < _nMenor
					_nMaior := POS->PESO
				endif

				_nSoma += POS->PESO
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
				SB1->B1_PMPEC := _nMedia
				MsUnlock()			
			endif

			SB1->(DbSkip())

		enddo

	else
		alert('Processamento nulo!')
	endif

Return
