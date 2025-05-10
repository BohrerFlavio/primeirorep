#INCLUDE "rwmake.ch"
#INCLUDE "topconn.ch"


/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³GJF133    º Autor ³ Giuliano Forgiariniº Data ³  16/02/12   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDescricao ³ Rotina para ajustar periodo de datas de produção indicado  º±±
±±º          ³ para ser carregado.                                        º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ Comercial                                                  º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/

User Function GJF133()

	LOCAL nOpca	:=0
	LOCAL aSays:={}, aButtons:={}
	Private cCadastro := "AJUSTE DE DATAS DE PRODUÇÃO PARA EMPENHO"    
	Private _area := getarea()

	AADD (aSays, "  Esta rotina tem como objetivo realizar o ajuste e definição  ")  //
	AADD (aSays, "  dos intervalos de datas de produção a serem considerados no  ")  //
	AADD (aSays, "  carregamento dos itens, conforme seu empenho, por pedido.    ")  //

	AADD(aButtons, { 1,.T.,{|o| nOpca:= 1,o:oWnd:End()}} )
	AADD(aButtons, { 2,.T.,{|o| o:oWnd:End() }} )
	FormBatch( cCadastro, aSays, aButtons )
	If nopca == 1                                                                                              
		Processa({||Zerar(ZZ4->ZZ4_NUM)},"INÍCIO DE PROCESSO","Realizando limpeza de reservas do pré-pedido...")
		Processa({||Processo(ZZ4->ZZ4_NUM)},"AJUSTE DE DATAS","Realizando operação nos registros de empenho...")
		alert('Ajuste de datas efetivado!')	
	Endif

return

//Zerando as reservas de caixas
Static Function Zerar(_num)

	_nProc := 0

	SZ8->(DbSetOrder(22))
	SZ8->(DbSeek(xfilial('SZ8') + _num)) 
	While SZ8->(!eof()) .and. SZ8->Z8_FILIAL = xfilial('SZ8') + SZ8->Z8_FIL = cFilAnt .and. SZ8->Z8_EMPENHO = _num 

		_nProc++

		SZ8->(DbSkip())
	enddo

	SZ8->(DbGoTop())

	ProcRegua(_nProc)

	SZ8->(DbSetOrder(22))
	SZ8->(DbSeek(xfilial('SZ8') + _num)) 
	While SZ8->(!eof()) .and. SZ8->Z8_FILIAL = xfilial('SZ8') + SZ8->Z8_FIL = cFilAnt .and. SZ8->Z8_EMPENHO = _num 

		IncProc()

		reclock('SZ8',.f.)
		SZ8->Z8_EMPENHO := ''
		msunlock()  

		SZ8->(DbSkip())
	enddo
return


Static Function Processo(_num)
	Local area := getarea()
	Local _FlagEmp := GetMv('SI_EMPENHO') 

	if !empty(_FlagEmp)
		if alltrim(_FlagEmp) <> alltrim(cUserName)
			alert('Esta rotina já está sendo executada pelo usuário ' + _FlagEmp + '!')
			return
		endif
	endif

	PutMv('SI_EMPENHO',cUserName)

	ZZ5->(DbSetOrder(1))
	ZZ5->(DbSeek(xfilial('ZZ5') + _num))

	While ZZ5->(!eof()) .and. ZZ5->ZZ5_NUM = _num
		IncProc()
		//Query que determinará as caixas mais antigas
		cQuery := "SELECT TOP " + str(ZZ5->ZZ5_QPCAIX) + " Z8_CONTROL AS CONTROL, Z8_COD AS  COD, Z8_DATAP AS DATAP"
		cQuery += " FROM "+RetSqlName("SZ8") + " SZ8"
		cQuery += " WHERE  " + RetSQLFil('SZ8')
		cQuery += " AND SZ8.Z8_FIL = '" + cFilAnt + "'"
		cQuery += " AND SZ8.Z8_DATAS = '' "
		cQuery += " AND SZ8.Z8_HORAS = '' "
		cQuery += " AND SZ8.Z8_ITEM = '' "
		cQuery += " AND SZ8.Z8_PREPED = '' "
		cQuery += " AND SZ8.Z8_PRECAR = '' " 
		cQuery += " AND SZ8.Z8_EMPENHO = '' "
		cQuery += " AND SZ8.Z8_COD = '" + ZZ5->ZZ5_COD + "'"
		cQuery += " AND " + RetSQLDel('SZ8')
		cQuery += " ORDER BY Z8_DATAP ASC "

		cQuery := ChangeQuery(cQuery)

		//	* Mostrar a consulta */
		// @ 116,090 To 416,707 Dialog oDlgMemo Title "Consulta"
		// @ 055,005 Get cQuery Size 250,080 MEMO Object oMemo
		// Activate Dialog oDlgMemo 
		if Select("QRY")<>0
			QRY->(dbCloseArea())
		endif

		TCQUERY cQuery NEW ALIAS "QRY"

		//Inicio do processo de coleta das datas de produção

		QRY->(DbGoTop())

		_dtIni := stod(QRY->DATAP)
		_dtFim := stod(QRY->DATAP) 

		while QRY->(!eof())  

			//Reserva as caixas com o pre-pedido em processamento
			SZ8->(DbSetOrder(3))
			SZ8->(DbSeek(xfilial('SZ8') + QRY->CONTROL))
			reclock('SZ8',.f.)                 
			SZ8->Z8_EMPENHO = _num
			msunlock()

			QRY->(DbSkip())

			if QRY->(!eof())
				_dtFim := stod(QRY->DATAP)   
			endif                           

		enddo

		QRY->(dbclosearea())
		//Fim do processo de coleta das datas de produção

		reclock('ZZ5',.f.)
		ZZ5->ZZ5_DTPINI := _dtIni
		ZZ5->ZZ5_DTPFIM := _dtFim
		msunlock() 

		ZZ5->(DbSkip())
	enddo

	restarea(area)


	PutMv('SI_EMPENHO','')
	restarea(_area)
return
