#INCLUDE "rwmake.ch"
#INCLUDE "topconn.ch"

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³GJF95     º Autor ³ Giuliano Forgiariniº Data ³  28/08/09   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDescricao ³ Rotina de acerto do saldo atual dos PA's                   º±±
±±º          ³                                                            º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ SIGAPCP/SIGAOMS                                            º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/

User Function GJF95()

	Local _nQtCaix  := 0
	Local _nQtPeso  := 0
	Local _cProd    := ''

	DbSelectArea('SB1')
	SB1->(DbSetOrder(1))
	_nCaixas := 0
	_nPeso   := 0

	while SB1->(!eof()) .and. SB1->B1_FILIAL = cFilAnt


		if !(SB1->B1_TIPO $ 'PA/PR')
			SB1->(DbSkip())
			loop
		endif

		if SB1->B1_MSBLQL = '1'
			SB1->(DbSkip())
			loop
		endif

		cQuery := " SELECT COUNT(*) AS CAIX, SUM(Z8_PESO) AS PESO FROM " + RetSQLTab('SZ8')
		cQuery += " WHERE " + RetSQLFil('SZ8') + " AND Z8_FIL = '" + cFilAnt + "' AND Z8_DATAS = '' AND Z8_COD = '" + SB1->B1_COD + "'" 
		cQuery += " AND " + RetSQLDel('SZ8')

		cQuery  := ChangeQuery(cQuery)

		//	* Mostrar a consulta */
		//@ 116,090 To 416,707 Dialog oDlgMemo Title "Consulta"
		//@ 055,005 Get cQuery Size 250,080 MEMO Object oMemo
		//Activate Dialog oDlgMemo

		If Select("POS") != 0
			POS->(dbCloseArea())
		Endif

		TCQUERY cQuery NEW ALIAS "POS"

		if SZI->(DbSeek(xfilial('SZI') + alltrim(SB1->B1_COD)))
			reclock('SZI',.f.)
			SZI->ZI_QTCAIX := POS->CAIX
			SZI->ZI_QTPESO := POS->PESO
			SZI->ZI_DATA   := date()
			SZI->ZI_HORA   := time()
			msunlock()
		else
			reclock('SZI',.t.)
			SZI->ZI_FILIAL := xfilial('SZI')
			SZI->ZI_COD    := SB1->B1_COD
			SZI->ZI_QTCAIX := POS->CAIX
			SZI->ZI_QTPESO := POS->PESO
			SZI->ZI_DATA   := date()
			SZI->ZI_HORA   := time()
			msunlock()
		endif

		POS->(dbCloseArea())

		SB1->(DbSkip())
	enddo

Return
