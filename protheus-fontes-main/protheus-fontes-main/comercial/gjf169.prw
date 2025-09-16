#INCLUDE "topconn.ch"
#INCLUDE "rwmake.ch"
#INCLUDE "protheus.ch"
#INCLUDE "SHELL.CH"

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³GJF169    º Autor ³ Giuliano Forgiariniº Data ³  25/05/13   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDescricao ³ Calculo de estoque de PA para consulta on-line             º±±
±±º          ³                                                            º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ Comercial                                                  º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/

User Function GJF169()
	//local aResult := {}
	Private _cFarm := ''

	//RpcSetType(3) 		// Executa via job para nao consumir licensas
	//WFPrepEnv( '01', '00',, {"ZAI","ZZ3","ZZ4","ZZ5","SZ8","SZU","SB1","SBM","SZI","SG1"}, "PCP")
	//aTables := {'SZG','SZK','SZ4','SZD','SZE','SZ8','SB1','ZAA','SZP','ZAJ','SZL'}
	//RPCSetEnv('01','00','industria','industria',"ACD","U_GJF169",aTables,,,,)
	
	u_gjf95()

	//_cSQL := " execute dbo.SI_estoqueSZI"

	//_nStat := TCSQLExec(_cSQL)
	
	//conout(_nStat)
	
	//If !(TCIsConnected())
	//	conout("Erro de conexão com o banco...")
	//	return
	//EndIf

	//aResult := TCSPEXEC("execute dbo.SI_estoqueSZI")
	//aResult := TCSPEXEC(xProcedures("dbo.SI_estoqueSZI"))
	
	//conout(TcSqlError())

	//IF empty(aResult)
	//	Conout('Erro na execução da Stored Procedure : '+TcSqlError())
		//conout(TcSqlError())
	//Else
	//	Conout("Retorno String : "+aResult[1])
	//	Conout("Retorno Numerico : "+str(aResult[2]))
	//	MsgInfo("Procedure Executada")
	//Endif

	RpcClearEnv()

Return

Static Function CalcSZI()
//	Local _nQtPeso  := 0
//	Local _cProd    := ''

	//conout("Início calculo estoque...")

	cQuery := " SELECT B1_COD FROM " + RetSQLTab('SB1')
	cQuery += " WHERE " + RetSQLFil('SB1') + " AND B1_TIPO IN ('PA','PR') AND B1_MSBLQL = '2' AND " + RetSQLDel('SB1')

	cQuery  := ChangeQuery(cQuery)

	//	* Mostrar a consulta */
	//@ 116,090 To 416,707 Dialog oDlgMemo Title "Consulta"
	//@ 055,005 Get cQuery Size 250,080 MEMO Object oMemo
	//Activate Dialog oDlgMemo

	If Select("PROD") != 0
		PROD->(dbCloseArea())
	Endif

	TCQUERY cQuery NEW ALIAS "PROD"

	_nCaixas := 0
	_nPeso   := 0
	_ntot := 0
	while PROD->(!eof())

		cQuery := " SELECT COUNT(*) AS CAIX, SUM(Z8_PESO) AS PESO FROM " + RetSQLTab('SZ8')
		cQuery += " WHERE " + RetSQLFil('SZ8') + " AND Z8_FIL = '" + cFilAnt + "' AND Z8_DATAS = '' AND Z8_COD = '" + PROD->B1_COD + "'"
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

		SZI->(DbSetOrder(1))
		if SZI->(DbSeek(xfilial('SZI') + alltrim(PROD->B1_COD)))
			reclock('SZI',.f.)
			SZI->ZI_QTCAIX := POS->CAIX
			SZI->ZI_QTPESO := POS->PESO
			SZI->ZI_DATA   := date()
			SZI->ZI_HORA   := time()
			msunlock()
			//		conout("Achou " + SB1->B1_COD)
		else
			reclock('SZI',.t.)
			SZI->ZI_FILIAL := xfilial('SZI')
			SZI->ZI_COD    := SB1->B1_COD
			SZI->ZI_QTCAIX := POS->CAIX
			SZI->ZI_QTPESO := POS->PESO
			SZI->ZI_DATA   := date()
			SZI->ZI_HORA   := time()
			msunlock()
			//		conout("Não achou " + SB1->B1_COD)
		endif
		_nTot++
		POS->(dbCloseArea())

		PROD->(DbSkip())
	enddo
	//conout("Job JOBEST: fim do calculo SZI!")
Return

