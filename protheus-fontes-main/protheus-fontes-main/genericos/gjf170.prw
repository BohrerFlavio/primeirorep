#INCLUDE "topconn.ch"
#INCLUDE "rwmake.ch"
#INCLUDE "SHELL.CH"
#INCLUDE "vkey.ch"
#INCLUDE "colors.ch"
#INCLUDE "tbiconn.ch"
#INCLUDE "totvs.ch"

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณGJF170    บ Autor ณ Giuliano Forgiariniบ Data ณ  25/05/13   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDescricao ณ Rotina para limpeza de tabelas temporarias                 บฑฑ
ฑฑบ          ณ                                                            บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ Comercial, Expedi็ใo, Desossa, Embalagem                   บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
/*/

User Function GJF170()

	Local i
	Local _cMat := ''
	Local _cCont := 0

	//aTables := {'ZZ6','ZZ9','ZZD','ZZA','ZA9','ZA2','ZAF','ZC9'}
	//RPCSetEnv('01','00','industria','industria',"ACD","U_GJF170",aTables,,,,)
	PREPARE ENVIRONMENT EMPRESA "01" FILIAL "00" MODULO "PCP"

	PutMV('SI_LIMPTAB',dtos(Date()))

	If !(TCIsConnected())
		//conout("Erro de conexใo com o banco...")
		return
	EndIf

	//Tabela ZZ6
	_cQRYDel1 := " DELETE FROM ZZ6010 WHERE ZZ6_DATAS < '" + dtos(date()-90) + "'"

	_nStat := TCSQLExec(_cQRYDel1)

	/*if _nStat < 0
		conout("Job JOBTAB: Erro Limpeza ZZ6: " + TCSQLError())
	else
		conout("Job JOBTAB: ZZ6 limpeza executada!")
	endif*/

	//Tabela ZZ9
	_cQRYDel2 := " DELETE FROM ZZ9010 WHERE ZZ9_DATA < '" + dtos(date()-180) + "'"

	_nStat := TCSQLExec(_cQRYDel2)

	/*if _nStat < 0
		conout("Job JOBTAB: Erro Limpeza ZZ9: " + TCSQLError())
	else
		conout("Job JOBTAB: ZZ9 limpeza executada!")
	endif*/

	//Tabela ZZD
	_cQRYDel3 := " DELETE FROM ZZD010 WHERE ZZD_DATA < '" + dtos(date()-180) + "'"

	_nStat := TCSQLExec(_cQRYDel3)

	/*if _nStat < 0
		conout("Job JOBTAB: Erro Limpeza ZZD: " + TCSQLError())
	else
		conout("Job JOBTAB: ZZD limpeza executada!")
	endif*/

	//Tabela ZZA
	_cQRYDel4 := " DELETE FROM ZZA010 WHERE ZZA_DATAC < '" + dtos(date()-90) + "'"

	_nStat := TCSQLExec(_cQRYDel4)

	/*if _nStat < 0
		conout("Job JOBTAB: Erro Limpeza ZZA: " + TCSQLError())
	else
		conout("Job JOBTAB: ZZA limpeza executada!")
	endif*/

	//Tabela ZA9
	_cQRYDel5 := " DELETE FROM ZA9010 WHERE ZA9_DATA < '" + dtos(date()-60) + "'"

	_nStat := TCSQLExec(_cQRYDel5)

	/*if _nStat < 0
		conout("Job JOBTAB: Erro Limpeza ZA9: " + TCSQLError())
	else
		conout("Job JOBTAB: ZA9 limpeza executada!")
	endif*/

	//Tabela ZA2
	_cQRYDel6 := " DELETE FROM ZA2010 WHERE ZA2_DATA < '" + dtos(date()-365) + "'"

	_nStat := TCSQLExec(_cQRYDel6)

	/*if _nStat < 0
		conout("Job JOBTAB: Erro Limpeza ZA2: " + TCSQLError())
	else
		conout("Job JOBTAB: ZA2 limpeza executada!")
	endif*/

	//Tabela ZAI
	_cQRYDel7 := " DELETE FROM  ZAI010 "
	_nStat := TCSQLExec(_cQRYDel7)

	/*if _nStat < 0
		conout("Job JOBEST: Erro Limpeza ZAI: " + TCSQLError())
	else
		conout("Job JOBEST: ZAI limpeza executada!")
	endif*/

	for i := 1 to 3
		_cFarm := iif(i = 1,'R',iif(i = 2, 'C','S'))
		_cSQL := "DECLARE @farm VARCHAR(01) SET @farm = '"+ _cFarm +"' EXEC  SI_estoqueonline @farm OUTPUT"

		_nStat := TCSQLExec(_cSQL)
	next

	//Tabela ZAS
	_cQRYDel8 := " DELETE FROM ZAS010 WHERE ZAS_DTPROD <= '" + dtos(date() - 1095) + "'"

	_nStat := TCSQLExec(_cQRYDel8)

	//Tabela SZ8
	_cQRYDel9 := " DELETE FROM SZ8010 WHERE Z8_DATAP <= '" + dtos(date() - 1095) + "'"

	_nStat := TCSQLExec(_cQRYDel9)

	/*if _nStat < 0
		conout("Job JOBTAB: Erro Limpeza SZ8: " + TCSQLError())
	else
		conout("Job JOBTAB: SZ8 limpeza executada!")
	endif*/

	//Tabela SZV
	_cQRYDel10 := " DELETE FROM SZV010 WHERE ZV_CONTROL NOT IN(SELECT Z8_CONTROL FROM SZ8010 )"

	_nStat := TCSQLExec(_cQRYDel10)

	/*if _nStat < 0
		conout("Job JOBTAB: Erro Limpeza SZV: " + TCSQLError())
	else
		conout("Job JOBTAB: SZV limpeza executada!")
	endif*/

	//Tabela ZAF
	_cQRYDel11 := " DELETE FROM ZAF010 WHERE ZAF_DATA < '" + dtos(date()-7) + "'"

	_nStat := TCSQLExec(_cQRYDel11)

	/*if _nStat < 0
		conout("Job JOBTAB: Erro Limpeza ZAF: " + TCSQLError())
	else
		conout("Job JOBTAB: ZAf limpeza executada!")
	endif*/

	//Tabela ZC9
	_cQRYDel12 := " DELETE FROM ZC9010 WHERE ZC9_DATA < '" + dtos(date()-30) + "'"

	_nStat := TCSQLExec(_cQRYDel12)

	/*if _nStat < 0
		conout("Job JOBTAB: Erro Limpeza ZC9: " + TCSQLError())
	else
		conout("Job JOBTAB: ZC9 limpeza executada!")
	endif*/

	//Tabela ZZR
	_cQRYDel13 := " DELETE FROM ZZR010 WHERE ZZR_DTIMP < '" + dtos(date()-1095) + "' OR ZZR010.D_E_L_E_T_ = '*'"

	_nStat := TCSQLExec(_cQRYDel13)

	/*if _nStat < 0
		conout("Job JOBTAB: Erro Limpeza ZZR: " + TCSQLError())
	else
		conout("Job JOBTAB: ZZR limpeza executada!")
	endif*/

	_cQuery := " SELECT RA_MAT,RA_SITFOLH"
	_cQuery += " FROM  " + retSqlTab('SRA')
	_cQuery += " WHERE " + retSqlFil('SRA')
	_cQuery += " AND " + retSqlDel('SRA')
	_cQuery += " AND RA_SITFOLH IN ('A','F')"

	_cQuery  := ChangeQuery(_cQuery)

	//	* Mostrar a consulta */
	//@ 116,090 To 416,707 Dialog oDlgMemo Title "Consulta"
	//@ 055,005 Get _cQuery Size 250,080 MEMO Object oMemo
	//Activate Dialog oDlgMemo
	//Return .t.

	If Select("QRY") != 0
		QRY->(dbCloseArea())
	Endif

	TCQUERY _cQuery NEW ALIAS "QRY"

	QRY->(dbGoTop())
	While QRY->(!eof())

		If _cCont = 0
			_cMat := alltrim(QRY->RA_MAT)
			versr8(alltrim(_cMat))
		Endif

		if _cMat <> alltrim(QRY->RA_MAT)
			versr8(alltrim(_cMat))
			_cMat := alltrim(QRY->RA_MAT)
		Endif

		_cCont++
		QRY->(DbSkip())

	enddo

	DbSelectArea('SZU')
    SZU->(dbSetOrder(1))
	SZU->(dbGoTop())
    SZU->(MsSeek(FWxFilial('SZU') + DtoS(Date()-7)))

    while (SZU->(!EOF()) .and. SZU->ZU_DTRPRO <= Date())
        reclock('SZU',.f.)
        SZU->ZU_FECHADO := 'B'
        msunlock()

        SZU->(dbSkip()) // Avanca o ponteiro do registro no arquivo
    end

	chkPallets()
	QRY3->(dbGoTop())
    SZP->(DbSetOrder(1))
    SZP->(DbGoTop())

    While QRY3->(!EOF())
        if QRY3->STATUS = 'Not Exist'
            if SZP->(MsSeek(FWxfilial('SZP') + alltrim(QRY3->PALLET)))
                RecLock("SZP",.F.)
                DbDelete()
                MsUnlock()
            endif
        endif
        QRY3->(dbSkip()) // Avanca o ponteiro do registro no arquivo
    enddo

	RESET ENVIRONMENT

Return


Static Function versr8(_cMat)

	_cQuery2 := " SELECT TOP 1 * "
	_cQuery2 += " FROM  " + retSqlTab('SR8')
	_cQuery2 += " WHERE " + retSqlFil('SR8')
	_cQuery2 += " AND " + retSqlDel('SR8')
	_cQuery2 += " AND R8_MAT = '" + _cMat + "'"
	_cquery2 += " ORDER BY R8_SEQ DESC"

	_cQuery2  := ChangeQuery(_cQuery2)

	//	* Mostrar a consulta */
	//@ 116,090 To 416,707 Dialog oDlgMemo Title "Consulta"
	//@ 055,005 Get _cQuery2 Size 250,080 MEMO Object oMemo
	//Activate Dialog oDlgMemo
	//Return .t.

	If Select("QRY2") != 0
		QRY2->(dbCloseArea())
	Endif

	TCQUERY _cQuery2 NEW ALIAS "QRY2"

	QRY2->(dbGoTop())
	While QRY2->(!eof())	

		if empty(QRY2->R8_DATAFIM)
		Else
			if QRY2->R8_DATAFIM < dtos(date())
					SRA->(dbSetOrder(1))
					SRA->(MsSeek(FWxFilial('SRA')+QRY2->R8_MAT))
					reclock('SRA',.F.)
						SRA->RA_SITFOLH := ''
					msunlock()
			endif
		endif

		QRY2->(DbSkip())

	enddo

return

/*/{Protheus.doc} chkPallets
	Busca os pallets que nใo possuem refer๊ncia na SZ8
	@type Function
	@author Adonai
	@since 11/03/2024
/*/
Static Function chkPallets()

	Local _cQuery := ""
	Local _cDtBase := dtos(ddatabase)

	_cQuery := "SELECT ZP_COD AS PALLET,"
    _cQuery += " CASE WHEN EXISTS(SELECT *"
	_cQuery += " FROM  " + retSqlTab('SZ8')
    _cQuery += " WHERE " + retSqlFil('SZ8')
    _cQuery += " AND Z8_PALLET = ZP_COD"
	_cQuery += " AND Z8_DATAP BETWEEN '" + (_cDtBase-7) + "' AND '" + _cDtBase + "'"
	_cQuery += " AND " + retSqlDel('SZ8') + " AND " + retSqlDel('SZP') + ") THEN 'Exist'"
	_cQuery += " ELSE 'Not Exist'"
    _cQuery += " END AS STATUS"
    _cQuery += " FROM  " + retSqlTab('SZP')
    _cQuery += " WHERE " + retSqlFil('SZP')
	_cQuery += " AND ZP_DATA BETWEEN '" + (_cDtBase-7) + "' AND '" + _cDtBase + "'"
    _cQuery += " AND " + retSqlDel('SZP')

	_cQuery  := ChangeQuery(_cQuery)

	//	* Mostrar a consulta */
	//@ 116,090 To 416,707 Dialog oDlgMemo Title "Consulta"
	//@ 055,005 Get _cQuery Size 250,080 MEMO Object oMemo
	//Activate Dialog oDlgMemo

	If Select("QRY3") != 0
		QRY3->(dbCloseArea())
	Endif

	TCQUERY _cQuery NEW ALIAS "QRY3"

Return
