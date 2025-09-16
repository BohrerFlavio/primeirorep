#INCLUDE "rwmake.ch"
#INCLUDE "protheus.ch"
#INCLUDE "topconn.ch"

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³GJF184    ºAutor  ³Giuliano Forgiarini º Data ³  17/01/14   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³Atualização automática de tabela de preços conforme tabela  º±±
±±º          ³ mãe referenciada                                           º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³Comercial                                                   º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
User Function GJF184()

	Local nOpca	   := 0
	Local aSays	   := {}
	Local aButtons := {}
	
	Private cCadastro := "Atualização Automática de Tabela de Preços"

	cPerg := "GJF184"
	Pergunte(cPerg,.f.)

	AADD (aSays, "  Este programa tem como objetivo atualizar automaticamente as  ")  //
	AADD (aSays, "  tabelas de preços de acordo com o apontamento da tabela mãe   ")  //
	AADD (aSays, "  refletindo seus valores às demais tabelas de nível menor e    ")
	AADD (aSays, "  dependentes conforme parametrização desta.                    ")  //

	AADD(aButtons, { 1,.T.,{|o| nOpca:= 1,o:oWnd:End()}} )
	AADD(aButtons, { 2,.T.,{|o| o:oWnd:End() }} )
	AADD(aButtons, { 5,.T.,{|o| Pergunte(cPerg,.T. ) } } )

	FormBatch( cCadastro, aSays, aButtons )

	If nOpca == 1

		DA0->(DbSetOrder(1))
		If DA0->(DbSeek(xfilial('DA0') + mv_par01))
			If DA0->DA0_NIVEL == '1'

				MsgRun("Selecionando itens da tabela mãe...",,{||  GeraITENS()})
				MsgRun("Selecionando tabelas filhas..."     ,,{||  GeraTABS()})

				Processa({||Processar() },"PROCESSAMENTO DE TABELAS DE PREÇO","Realizando atualização..." )
			Else
				MsgAlert('Esta tabela não é uma tabela mãe!')
			EndIf
		Else
			MsgAlert('Tabela não encontrada!')
		EndIf

	EndIf
Return


/*====================================================================*
| Função:  		GeraITENS                                             |
| Descrição:	Gera query para selecionar itens da tabela mãe...     |
*====================================================================*/
Static Function GeraITENS()

	_cQuery := "SELECT * "
	_cquery += "  FROM " + RetSQLTab("DA1")
	_cQuery += " WHERE "
	_cQuery += RetSQLFil('DA1') + " AND DA1_CODTAB = '" + mv_par01 + "' AND " + RetSQLDel('DA1')

	_cQuery := ChangeQuery(_cQuery)

	If Select("ITENS") != 0
		ITENS->(dbCloseArea())
	EndIf

	TCQUERY _cQuery NEW ALIAS "ITENS"

Return


/*====================================================================*
| Função:  		GeraTABS                                              |
| Descrição:	Gera query para selecionar tabelas...                 |
*====================================================================*/
Static Function GeraTABS()

	_cQuery := "SELECT * "
	_cquery += "  FROM " + RetSQLTab("DA0")
	_cQuery += " WHERE "
	_cQuery += RetSQLFil('DA0') + " AND DA0_MAE = '" + mv_par01 + "' AND DA0_NIVEL = '2' AND " + RetSQLDel('DA0')
	_cQuery += " ORDER BY DA0_CODTAB "

	_cQuery  := ChangeQuery(_cQuery)

	If Select("TABS") != 0
		TABS->(dbCloseArea())
	EndIf

	TCQUERY _cQuery NEW ALIAS "TABS"

Return


/*====================================================================*
| Função:  		GeraTABS                                              |
| Descrição:	Função para processamento geral                       |
*====================================================================*/
Static Function Processar()

	Local Cont := 0

	_cNumAtu := GETSXENUM("Z08","Z08_NUMATU")
	ConfirmSX8()

	TABS->(DbGoTop())
	While TABS->(!Eof())
		Cont++
		TABS->(DbSkip())
	EndDo

	ProcRegua(Cont)

	TABS->(DbGoTop())
	While TABS->(!Eof())

		IncProc('Atualizando tabela '+ TABS->(DA0_CODTAB) + ': ' + alltrim(TABS->DA0_DESCRI) + '...')

		ITENS->(DbGoTop())
		While ITENS->(!Eof())
			DA1->(DbSetOrder(1))
			If DA1->(DbSeek(xfilial('DA1') + TABS->DA0_CODTAB + ITENS->DA1_CODPRO ) )
				_nRapel  := TABS->DA0_RAPEL
				_nFrete  := TABS->DA0_FRETE + ITENS->DA1_PRCVEN
				_nOutros := TABS->DA0_OUTROS
				_nPreco  := (_nFrete / (1-(_nRapel/100) ) ) + _nOutros

				_nPreco := TrataPreco(_nPreco)

				RecLock('DA1', .F.)
				DA1->DA1_PRCVEN := _nPreco
				MsUnLock()

				// Efetua gravação do logs de atualizacao DA1 X Z07 para utilizacao do BI
				_aDadosSB1 := GetAdvFVal("SB1", {"B1_CODCUS" , "B1_DESC"   }, xFilial("SB1") + ITENS->DA1_CODPRO 	    , 1, {Space(TamSx3("B1_CODCUS")[1]) , Space(TamSx3("B1_DESC")[1])} , .T.)
				_aDadosZ07 := GetAdvFVal("Z07", {"Z07_CODCUS", "Z07_PRCCUS"}, xFilial("Z07") + MV_PAR02 + _aDadosSB1[1] , 2, {Space(TamSx3("Z07_CODCUS")[1]), 0							 } , .T.)
				_cDescrZ03 := GetAdvFVal("Z03", "Z03_DESCUS"                , xFilial("Z03") + _aDadosSB1[1]            , 1, Space(TamSx3("Z03_DESCUS")[1]) 							   , .T.)

				DbSelectArea("Z08")
				RecLock("Z08", .T.)
				Z08->Z08_FILIAL := xFilial("Z08")
				Z08->Z08_NUMATU := _cNumAtu
				Z08->Z08_DATATU := DATE()
				Z08->Z08_USUATU := AllTrim(UsrFullName(__CUSERID))
				Z08->Z08_TABDA1 := ITENS->DA1_CODTAB
				Z08->Z08_CODDA1 := ITENS->DA1_CODPRO
				Z08->Z08_DESDA1 := _aDadosSB1[2]
				Z08->Z08_PRCDA1 := ITENS->DA1_PRCVEN
				Z08->Z08_TABZ07 := MV_PAR02
				Z08->Z08_CODZ07 := _aDadosZ07[1] 
				Z08->Z08_DESZ07 := _cDescrZ03
				Z08->Z08_PRCZ07 := _aDadosZ07[2]
				Z08->Z08_ORIGEM := "GJF184"
				MsUnLock()
			EndIf

			ITENS->(DbSkip())
		EndDo

		TABS->(DbSkip())
	EndDo

	TABS->(dbCloseArea())
	ITENS->(dbCloseArea())

Return


/*====================================================================*
| Função:  		TrataPreco                                            |
| Descrição:	Função para tratamento do preco de venda              |
*====================================================================*/
Static Function TrataPreco(_n)

	Local _cStrPrc    := ''
	Local _cStrUn     := ''
	Local _cStrUlDec  := ''
	Local _nPrc       := 0.00

	_n := Round(_n,2)

	If _n <= 99.99
		_cStrPrc := AllTrim(Transform(_n, "@E 99.99"))
	Else
		_cStrPrc := AllTrim(Transform(_n, "@E 999.99"))
	EndIf

	If Len(_cStrPrc) = 5
		_cStrUn     := Substr(_cStrPrc,1,2)
		_cStrPenDec := Substr(_cStrPrc,4,1)
		_cStrUlDec  := Substr(_cStrPrc,5,1)
	ElseIf Len(_cStrPrc) = 6
		_cStrUn     := Substr(_cStrPrc,1,3)
		_cStrPenDec := Substr(_cStrPrc,5,1)
		_cStrUlDec  := Substr(_cStrPrc,6,1)
	Else
		_cStrUn     := Substr(_cStrPrc,1,1)
		_cStrPenDec := Substr(_cStrPrc,3,1)
		_cStrUlDec  := Substr(_cStrPrc,4,1)
	EndIf

	If (Val(_cStrUlDec) < 5 .And. Val(_cStrUlDec) <> 0)
		_cStrPrc := _cStrUn +'.' +  _cStrPenDec + '5'
		_nPrc    := Val(_cStrPrc)

	ElseIf (Val(_cStrUlDec) > 5)
		_nPrc := Round(_n,1)
	Else
		_nPrc := _n
	EndIf

Return _nPrc
