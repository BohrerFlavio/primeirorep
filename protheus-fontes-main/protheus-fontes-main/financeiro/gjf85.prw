#INCLUDE "rwmake.ch"
#INCLUDE "topconn.ch"
/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³GJF85     º Autor ³ Giuliano Forgiariniº Data ³  12/06/09   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDescricao ³ Função para bloqueio de clientes conforme análise de limiteº±±
±±º          ³ de crédito                                                 º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ Financeiro                                                 º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/

User Function GJF85(_cli,_lj)

	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Declaracao de Variaveis                                             ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ

	Local _VlrTit  := 0           //Valor dos titulos
	Local _VlrPP   := 0           //Valor dos pre-pedidos
	Local _LimCre  := 0           //Valor do limite de credito
	Local _VenCre                 //Data do limite de credito
	Local _nSaldo  := 0           //Valor do saldo
	Local _nTPPAtu := 0           //Valor do pre-pedido atual
	Local _cNPPAtu := M->ZZ4_NUM  //Numero do pre-pedido atual
	Local _Ok      := .t.         //Flag
	Local nIt 

	_LimCre := GetAdvFVal('SA1','A1_LC',FWxfilial('SA1')+_cli+_lj,1)
	_VenCre := GetAdvFVal('SA1','A1_VENCLC',FWxfilial('SA1')+_cli+_lj,1)
	_Bloq   := GetAdvFVal('SA1','A1_MSBLQL',FWxfilial('SA1')+_cli+_lj,1)
	_CPag   := GetAdvFVal('SA1','A1_COND',FWxfilial('SA1')+_cli+_lj,1)

	M->ZZ4_CREVIG := _LimCre

	if _CPag = '001'
		FWAlertWarning("Cliente com depósito antecipado!", "AVISO!")
	endif

	if _LimCre = 0
		//msgbox('Limite de Credito do cliente não definido!','OPERAÇÃO NEGADA!','STOP')
		// 09/12/22 -> Solicitação de remoção de aviso pelo Rodrigo Abelin
		//Help(" ",1,'OPERAÇÃO NEGADA!',,'Limite de Credito do cliente não definido!',4,1)
		M->ZZ4_LIMCRE := 'B' 
		M->ZZ4_SIBLQL := '1'
		return .f.
	endif 

	if empty(_VenCre)
		//msgbox('Data de Limite de Credito do cliente não definida!','OPERAÇÃO NEGADA!','STOP')
		Help(" ",1,'OPERAÇÃO NEGADA!',,'Data de Limite de Credito do cliente não definida!',4,1)
		M->ZZ4_LIMCRE := 'B'
		M->ZZ4_SIBLQL := '1'
		return .f.
	endif
	/*
	dbSelectArea("SE1")
	SE1->(dbSetOrder(8))
	SE1->(DbGotop())
	SE1->(MsSeek(FWxfilial('SE1')+_cli+_lj+'A'))

	while SE1->(!eof()) .and. SE1->E1_FILIAL = FWxfilial('SE1') ;
	.and. SE1->E1_CLIENTE = _cli ;
	.and. SE1->E1_LOJA = _lj ;
	.and. SE1->E1_STATUS = 'A'

	if !empty(SE1->E1_BAIXA)
	SE1->(DbSkip())
	loop
	endif

	if SE1->E1_TIPO <> "NF"
	dbskip()
	loop
	endif

	_VlrTit += SE1->E1_SALDO

	SE1->(DbSkip())
	enddo
	*/

	cQuery := " SELECT SUM(E1_SALDO) AS SALDO "
	cQuery += " FROM " + RetSQLTab('SE1')
	cQuery += " WHERE " + RetSQLFil('SE1')
	cQuery += " AND E1_CLIENTE = '" + _cli + "' AND E1_LOJA = '" + _lj + "' AND E1_STATUS = 'A'"
	cQuery += " AND E1_BAIXA = '' AND E1_TIPO = 'NF'"
	cQuery += " AND " + RetSQLDel('SE1')

	cQuery := ChangeQuery(cQuery)

	//	* Mostrar a consulta */
	//@ 116,090 To 416,707 Dialog oDlgMemo Title "Consulta"
	//@ 055,005 Get cQuery Size 250,080 MEMO Object oMemo
	//Activate Dialog oDlgMemo

	If Select("LIM")<>0
		LIM->(dbCloseArea())
	Endif

	TCQUERY cQuery NEW ALIAS "LIM"

	_VlrTit := LIM->SALDO

	For nIt := 1 To Len(aCols)
		_nTPPAtu := M->ZZ4_TOTAL
	next

	area := getarea()
	/*
	DbSelectArea('ZZ4')
	ZZ4->(DbSetOrder(4))
	ZZ4->(DbGoTop()) 
	if ZZ4->(MsSeek(FWxfilial('ZZ4')+_cli+_lj))

	while ZZ4->(!eof()) .and. FWxfilial('ZZ4') = ZZ4->ZZ4_FILIAL ;
	.and. ZZ4->ZZ4_CODCLI = _cli ;
	.and. ZZ4->ZZ4_LOJA = _lj 

	if ZZ4->ZZ4_STATUS $ 'E/F'
	ZZ4->(DbSkip())
	loop
	endif    

	if ZZ4->ZZ4_NUM = M->ZZ4_NUM
	ZZ4->(DbSkip())
	loop
	endif

	if _cNPPAtu = ZZ4->ZZ4_STATUS
	ZZ4->(DbSkip())
	loop
	endif

	_VlrPP += ZZ4->ZZ4_TOTAL

	ZZ4->(DbSkip())
	enddo   

	endif 
	*/

	cQuery := " SELECT SUM(ZZ4_TOTAL) AS TOTAL "
	cQuery += " FROM " + RetSQLTab('ZZ4')
	cQuery += " WHERE " + RetSQLFil('ZZ4')
	cQuery += " AND ZZ4_CODCLI = '" + _cli + "' AND ZZ4_LOJA = '" + _lj + "' AND ZZ4_STATUS NOT IN('E','F','C','P')"
	cQuery += " AND ZZ4_NUM <> '" + _cNPPAtu + "'"
	cQuery += " AND " + RetSQLDel('ZZ4')

	cQuery := ChangeQuery(cQuery)

	//	* Mostrar a consulta */
	//@ 116,090 To 416,707 Dialog oDlgMemo Title "Consulta"
	//@ 055,005 Get cQuery Size 250,080 MEMO Object oMemo
	//Activate Dialog oDlgMemo

	If Select("LIM2")<>0
		LIM2->(dbCloseArea())
	Endif

	TCQUERY cQuery NEW ALIAS "LIM2"

	_VlrPP := LIM2->TOTAL

	if ALTERA
		ZZ4->(DbGoTop())
		ZZ4->(DbSetOrder(2))
		ZZ4->(MsSeek(FWxfilial('ZZ4')+M->ZZ4_NUM))
	endif

	restarea(area) 

	_nSaldo := _LimCre - (_VlrPP + _nTPPAtu +_VlrTit)

	if (_nSaldo < 0) .or. (date() > _VenCre)
		M->ZZ4_LIMCRE := 'B'
		M->ZZ4_SIBLQL := '1'
		_Ok := .f.
	else
		M->ZZ4_LIMCRE := 'L'
		M->ZZ4_SIBLQL := iif(_Bloq = '1','1','2')
	endif  

	_nSaldo  := 0
	_VlrPP   := 0
	_nTPPAtu := 0
	_VlrTit  := 0

Return _Ok


User Function GJF85C(_cli,_lj)
	Local _VlrTit  := 0           //Valor dos titulos
	Local _VlrPP   := 0           //Valor dos pre-pedidos
	Local _LimCre  := 0           //Valor do limite de credito
	Local _nSaldo  := 0           //Valor do saldo
	Local _nTPPAtu := 0           //Valor do pre-pedido atual
	Local _cNPPAtu := M->ZZ4_NUM  //Numero do pre-pedido atual
	Local nIt

	if empty(_cli) .or. empty(_lj)
		_cli := M->ZZ4_CODCLI
		_lj  := M->ZZ4_LOJA
	endif

	_LimCre := GetAdvFVal('SA1','A1_LC',FWxfilial('SA1')+_cli+_lj,1)

	dbSelectArea("SE1")
	SE1->(dbSetOrder(8))
	SE1->(DbGotop())   
	/*
	SE1->(MsSeek(FWxfilial('SE1')+_cli+_lj+'A'))

	while SE1->(!eof()) .and. SE1->E1_FILIAL = FWxfilial('SE1') ;
	.and. SE1->E1_CLIENTE = _cli ;
	.and. SE1->E1_LOJA = _lj ;
	.and. SE1->E1_STATUS = 'A'

	if !empty(SE1->E1_BAIXA)
	SE1->(DbSkip())
	loop
	endif

	if SE1->E1_TIPO <> "NF"
	dbskip()
	loop
	endif

	_VlrTit += SE1->E1_SALDO

	SE1->(DbSkip())
	enddo              
	*/

	cQuery := " SELECT SUM(E1_SALDO) AS SALDO "
	cQuery += " FROM " + RetSQLTab('SE1')
	cQuery += " WHERE " + RetSQLFil('SE1')
	cQuery += " AND E1_CLIENTE = '" + _cli + "' AND E1_LOJA = '" + _lj + "' AND E1_STATUS = 'A'"
	cQuery += " AND E1_BAIXA = '' AND E1_TIPO = 'NF'"
	cQuery += " AND " + RetSQLDel('SE1')

	cQuery := ChangeQuery(cQuery)

	//	* Mostrar a consulta */
	//@ 116,090 To 416,707 Dialog oDlgMemo Title "Consulta"
	//@ 055,005 Get cQuery Size 250,080 MEMO Object oMemo
	//Activate Dialog oDlgMemo

	If Select("LIM")<>0
		LIM->(dbCloseArea())
	Endif

	TCQUERY cQuery NEW ALIAS "LIM"

	_VlrTit := LIM->SALDO

	For nIt := 1 To Len(aCols)
		_nTPPAtu := M->ZZ4_TOTAL
	next

	area := getarea()  
	/*
	DbSelectArea('ZZ4')
	ZZ4->(DbSetOrder(4))
	ZZ4->(DbGoTop()) 
	if ZZ4->(MsSeek(FWxfilial('ZZ4')+_cli+_lj))

	while ZZ4->(!eof()) .and. FWxfilial('ZZ4') = ZZ4->ZZ4_FILIAL ;
	.and. ZZ4->ZZ4_CODCLI = _cli ;
	.and. ZZ4->ZZ4_LOJA = _lj 

	if ZZ4->ZZ4_STATUS $ 'E/F/C'
	ZZ4->(DbSkip())
	loop
	endif    

	if _cNPPAtu = ZZ4->ZZ4_STATUS
	ZZ4->(DbSkip())
	loop
	endif

	if ZZ4->ZZ4_NUM = M->ZZ4_NUM
	ZZ4->(DbSkip())
	loop
	endif

	_VlrPP += ZZ4->ZZ4_TOTAL

	ZZ4->(DbSkip())
	enddo   

	endif      
	*/

	cQuery := " SELECT SUM(ZZ4_TOTAL) AS TOTAL "
	cQuery += " FROM " + RetSQLTab('ZZ4')
	cQuery += " WHERE " + RetSQLFil('ZZ4')
	cQuery += " AND ZZ4_CODCLI = '" + _cli + "' AND ZZ4_LOJA = '" + _lj + "' AND ZZ4_STATUS NOT IN('E','F','C','P')"
	cQuery += " AND ZZ4_NUM <> '" + _cNPPAtu + "'"
	cQuery += " AND " + RetSQLDel('ZZ4')

	cQuery := ChangeQuery(cQuery)

	//	* Mostrar a consulta */
	//@ 116,090 To 416,707 Dialog oDlgMemo Title "Consulta"
	//@ 055,005 Get cQuery Size 250,080 MEMO Object oMemo
	//Activate Dialog oDlgMemo

	If Select("LIM2")<>0
		LIM2->(dbCloseArea())
	Endif

	TCQUERY cQuery NEW ALIAS "LIM2"

	_VlrPP := LIM2->TOTAL

	if !INCLUI
		ZZ4->(DbGoTop())
		ZZ4->(DbSetOrder(2))
		ZZ4->(MsSeek(FWxfilial('ZZ4')+M->ZZ4_NUM))
	endif

	restarea(area)  

	_nSaldo := _LimCre - (_VlrPP + _nTPPAtu +_VlrTit)

	//msgbox('Saldo de limite de crédito: ' + transform(_nSaldo,'@E 999,999,999.99'),'LIMITE DE CREDITO','INFO')
	Help(" ",1,'LIMITE DE CREDITO',,'Saldo de limite de crédito: ' + transform(_nSaldo,'@E 999,999,999.99'),4,1)

	_nSaldo  := 0
	_VlrPP   := 0
	_nTPPAtu := 0
	_VlrTit  := 0

Return

User Function GJF85S(_cli,_lj)

	Local _lRet := .T.

	cQuery := " SELECT E1_SALDO"
	cQuery += " FROM " + RetSQLTab('SE1')
	cQuery += " WHERE " + RetSQLFil('SE1')
	cQuery += " AND E1_CLIENTE = '" + _cli + "' AND E1_LOJA = '" + _lj + "' AND E1_STATUS = 'A'"
	cQuery += " AND E1_BAIXA = '' AND E1_TIPO = 'NF' AND E1_VENCREA < '" + dtos(ddatabase) + "'"
	cQuery += " AND " + RetSQLDel('SE1')

	cQuery := ChangeQuery(cQuery)

	//	* Mostrar a consulta */
	//@ 116,090 To 416,707 Dialog oDlgMemo Title "Consulta"
	//@ 055,005 Get cQuery Size 250,080 MEMO Object oMemo
	//Activate Dialog oDlgMemo

	If Select("LIM")<>0
		LIM->(dbCloseArea())
	Endif

	TCQUERY cQuery NEW ALIAS "LIM"
	LIM->(dbGoTop())

	//verifica se houve retorno na query
    Count to nCount

    If nCount > 0
		_lRet := .F.
    endif

Return _lRet
