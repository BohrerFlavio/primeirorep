#INCLUDE "topconn.ch"
#INCLUDE "rwmake.ch"
#INCLUDE "protheus.ch"

/*
Ajuste tabela SPG com base na tabela RFH
*/

User Function ob_ajSPG()

	cPerg := "ob_ajSPG"

	ValidPerg()
	
	if !pergunte(cPerg,.t.)
		return
	endif

	Processa({||montareg()} ,"PROCESSAMENTO DE REGISTROS","Processando dados da tabela SPG...")

	msgbox('Ajustes realizados!','ALTERA합ES EFETIVADAS!','INFO')

return


Static Function montaReg()

	_cQuery := " SELECT RFH_FILIAL, RFH_DATA, RFH_MATORG, RFH_NUMREP, RFH_DHORG, RFH_IDORG, RFH_RELOGI, RFH_HORA,"
	_cQuery += " PG_PAPONTA, PG_DATAAPO, PG_SEMANA, PG_TURNO, PG_CC, PG_ORDEM, PG_TURNO, PG_SEQJRN "
	_cQuery += " FROM " + RETSQLNAME ("RFH") + " AS RFH
	_cQuery += " INNER JOIN " + RETSQLNAME ("SPG") + " AS SPG ON RFH_NUMREP = PG_NUMREP "
	_cQuery += " AND RFH_IDORG = PG_IDORG AND RFH_DHORG = PG_DHORG "
	_cQuery += " AND RFH_MATORG = PG_MAT AND SPG.D_E_L_E_T_ = '' "
	_cQuery += " AND RFH_RELOGI = PG_RELOGIO AND PG_FLAG = 'E' "
	_cQuery += " WHERE RFH_DATA BETWEEN '"+DTOS(MV_PAR03)+"' AND '"+DTOS(MV_PAR04)+"' AND "
	_cQuery += " RFH.D_E_L_E_T_ = '' " //AND RFH_HORA <> PG_HORA "
	_cQuery += " and RFH_MATORG BETWEEN '"+MV_PAR01+"' AND '"+MV_PAR02+"' "
	_cQuery += " and RFH_NUMREP + RFH_IDORG + RFH_DHORG + RFH_MATORG + RFH_RELOGI +  CAST(RFH_HORA AS CHAR) "
	_cQuery += " NOT IN "
	_cQuery += " (SELECT PG_NUMREP + PG_IDORG + PG_DHORG + PG_MATORG + PG_RELOGIO + CAST(PG_HORA AS CHAR) "
	_cQuery += " FROM " + RETSQLNAME ("SPG") + " AS SPG2 WHERE RFH_NUMREP = SPG2.PG_NUMREP AND RFH_IDORG = SPG2.PG_IDORG AND RFH_DHORG = SPG2.PG_DHORG "
	_cQuery += " AND RFH_MATORG = SPG2.PG_MAT AND SPG2.D_E_L_E_T_ = '' "
	_cQuery += " AND RFH_RELOGI = SPG2.PG_RELOGIO AND SPG2.PG_FLAG = 'E' AND SPG2.PG_DATA = RFH_DATA ) "
	_cQuery += " order by RFH_DATA "
	

	_cQuery  := ChangeQuery(_cQuery)

	If Select("QRY") != 0
		QRY->(dbCloseArea())
	Endif

	TCQUERY _cQuery NEW ALIAS "QRY"

	QRY->(dbGoTop())
	Procregua(recCount("QRY"))
	While QRY->(!eof())

		IncProc('Processando dados da matricula: ' + QRY->RFH_MATORG)

		reclock('SPG',.T.)
		SPG->PG_FILIAL 	:= QRY->RFH_FILIAL
		SPG->PG_MAT		:= QRY->RFH_MATORG
		SPG->PG_DATA 		:= stod(QRY->RFH_DATA)
		SPG->PG_HORA		:= QRY->RFH_HORA
		SPG->PG_CC			:= QRY->PG_CC
		SPG->PG_ORDEM 	:= QRY->PG_ORDEM
		SPG->PG_FLAG		:= "E"
		SPG->PG_APONTA 	:= "N"
		SPG->PG_PAPONTA 	:= QRY->PG_PAPONTA
		SPG->PG_DATAAPO	:= STOD(QRY->PG_DATAAPO)
		SPG->PG_SEMANA	:= QRY->PG_SEMANA
		SPG->PG_TURNO 	:= QRY->PG_TURNO
		SPG->PG_RELOGIO	:= QRY->RFH_RELOGI
			//SP8->P8_FUNCAO	:= QRY->
			//SP8->P8_GIRO		:= QRY->
			//SP8->P8_TPMARCA	:= QRY->			
			//SP8->P8_USERLGI	:= QRY->
			//SP8->P8_USERLGA	:= QRY->			
		SPG->PG_NUMREP	:= QRY->RFH_NUMREP
		SPG->PG_TPMCREP	:= "D"
		SPG->PG_TIPOREG	:= "O"
		SPG->PG_MOTIVRG	:= "EXCLUSAO MANUAL"
		SPG->PG_EMPORG	:= SM0->M0_CODIGO
		SPG->PG_FILORG	:= QRY->RFH_FILIAL
		SPG->PG_MATORG	:= QRY->RFH_MATORG
		SPG->PG_DHORG		:= QRY->RFH_DHORG
			//SP8->P8_PROCES	:= QRY->
		SPG->PG_IDORG		:= QRY->RFH_IDORG
			//SP8->P8_ROTEIR	:= QRY->
			//SP8->P8_DATAALT	:= QRY->
			//SP8->P8_PERIODO	:= QRY->
			//SP8->P8_HORAALT	:= QRY->
			//SP8->P8_NUMPAG	:= QRY->
		SPG->PG_USUARIO	:= "000000"
		SPG->PG_SEQJRN	:= QRY->PG_SEQJRN
		SPG->PG_DATAALT	:= STOD('20181029')
		SPG->PG_HORAALT	:= '110000'
		msunlock()

		QRY->(DbSkip())
	enddo
	
	QRY->(dbCloseArea())
	
	_cQuery := " UPDATE " + RETSQLNAME ("SPG") + " SET PG_FLAG = 'M', PG_MOTIVRG = 'INCLUSAO MANUAL',PG_TIPOREG = 'I' "
	_cquery += " FROM "+ RetSqlName("SPG") +" SPG "
	_cQuery += " WHERE PG_DATA BETWEEN '"+DTOS(MV_PAR03)+"' AND '"+DTOS(MV_PAR04)+"' AND " 
	_cQuery += " SPG.D_E_L_E_T_ = '' AND PG_MAT BETWEEN '"+MV_PAR01+"' AND '"+MV_PAR02+"' " 
	_cQuery += " AND PG_FLAG = 'E' AND PG_TPMCREP = '' "
	_cQuery += " AND PG_DATA + CAST(PG_HORA AS CHAR) " 
	_cQuery += " NOT IN "
	_cQuery += " (SELECT RFH_DATA + CAST(RFH_HORA AS CHAR) "
	_cQuery += " FROM "+ RetSqlName("RFH") +" AS RFH2 "
	_cQuery += " WHERE RFH2.RFH_DATA = PG_DATA "
	_cQuery += " AND RFH2.RFH_MATORG = PG_MAT AND RFH2.D_E_L_E_T_ = '') " 

	TCSQLExec(_cQuery)

return


//旼컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴커
//� Cria Perguntas no SX1                                        �
//읕컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴켸
Static Function ValidPerg()
	Local i
	Local j
	cAlias := Alias()
	aRegs  := {}

// Grupo/Ordem/Pergunta/Variavel/Tipo/Tamanho/Decimal/Presel/GSC/Valid/Var01/Def01/Cnt01/Var02/Def02/Cnt02/Var03/Def03/Cnt03/Var04/Def04/Cnt04/Var05/Def05/Cnt05
	AADD(aRegs,{cPerg,"01","Matricula De       ?","","","mv_ch1","C",6,0,0,"G","","mv_par01","","","","","","","","","","","","","","","","","","","","","","","","","SRA",""})
	AADD(aRegs,{cPerg,"02","Matricula Ate      ?","","","mv_ch2","C",6,0,0,"G","","mv_par02","","","","","","","","","","","","","","","","","","","","","","","","","SRA",""})
	AADD(aRegs,{cPerg,"03","Data De            ?","","","mv_ch3","D",8,0,0,"G","","mv_par03","","","","","","","","","","","","","","","","","","","","","","","","","",""})
	AADD(aRegs,{cPerg,"04","Data Ate           ?","","","mv_ch4","D",8,0,0,"G","","mv_par04","","","","","","","","","","","","","","","","","","","","","","","","","",""})

	DbSelectArea("SX1")
	DbSetOrder(1)
	For i:=1 to Len(aRegs)
		If !DbSeek(cPerg+aRegs[i,2])
			RecLock("SX1",.T.)
			For j:=1 to FCount()
				If j<=Len(aRegs[i])
					FieldPut(j,aRegs[i,j])
				Endif
			Next
			MsUnlock()
		Endif
	Next
	DbSelectArea(cAlias)
Return
