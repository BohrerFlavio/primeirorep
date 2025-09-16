#INCLUDE "rwmake.ch"
USER FUNCTION MT103QPC
	Local cQry:=ParamIxb[1]
	Local nOpc:=ParamIxb[2]
	Local cQryRet:= ""
	//	* Mostrar a consulta */
	//@ 116,090 To 416,707 Dialog oDlgMemo Title "Consulta"
	//@ 055,005 Get cQry Size 250,080 MEMO Object oMemo
	//Activate Dialog oDlgMemo   

	if cEspecie <> 'NFP'
		cQryRet  := cQry
	else
		cQryRet := " SELECT R_E_C_N_O_ RECSC7 "
		cQryRet += " FROM " + RetSQLTab('SC7')
		cQryRet += " WHERE  C7_FILENT = '" + xfilial('SC7') + "'"
		cQryRet += " AND C7_FORNECE = '" + CA100FOR + "'"
		cQryRet += " AND (C7_QUANT-C7_QUJE-C7_QTDACLA)>0 AND C7_RESIDUO=' ' "
		cQryRet += " AND C7_TPOP<>'P' AND C7_CONAPRO<>'B' "
		cQryRet += " AND C7_LOJA = '" + CLOJA + "'"  
		cQryRet += " AND SC7.D_E_L_E_T_ = ' ' "
		cQryRet += " AND SC7.C7_PCNOTA = 'NFP' "
		cQryRet += " ORDER BY  C7_FILENT,C7_FORNECE,C7_LOJA,C7_NUM "
	endif

Return cQryRet
