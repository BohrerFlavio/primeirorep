#INCLUDE "rwmake.ch"
#INCLUDE "topconn.ch"

User Function M030INC()

	/*/
	ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
	±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
	±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
	±±³Programa  ³ M030INC  ³ Autor ³ Evandro Mugnol        ³ Data ³ 16/10/08 ³±±
	±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
	±±³Descricao ³ Ponto Entrada Apos Inclusao do Cad. Clientes para limpar o ³±±
	±±³          ³ campo A1_CGC caso o campo A1_TIPO = "X" e A1_EST = "EX"    ³±±
	±±³          ³ Isso se deve ao fato de gerar nota fiscal eletronica de    ³±±
	±±³          ³ exportacao.                                                ³±±
	±±³          ³                                                            ³±±
	±±³          ³ Replica cadastro do cliente para empresa 07 na inclusao    ³±±
	±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
	±±³Utilizacao³ Especifico para Frigorifico Silva                          ³±±
	±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
	±±³   DATA   ³ Programador   ³ Manutencao Efetuada                        ³±±
	±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
	±±³          ³               ³                                            ³±±
	±±³          ³               ³                                            ³±±
	±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
	±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
	ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
	/*/

	_aArea := GetArea()                             
	// Ajustado por Flávio para que o sistema volte a gravar automático na SA1070
	// If ParamIXB == 0    // Somente se estiver incluindo e não foi cancelada a tela de inclusão
	If SA1->A1_TIPO == "X" .And. SA1->A1_EST == "EX"
		DbSelectArea("SA1")
		RecLock("SA1",.F.)
		SA1->A1_CGC := ""
		MsUnlock()
	Endif

	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³Replica o cliente incluido na empresa 07                         ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ

	If cEmpAnt == "01"  // .And. cFilAnt == "00"
		_ReplSA1()
	Endif
	//endif

	RestArea(_aArea)

Return(.T.)


//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³Chamada da funcao _ReplSA1                                       ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
Static Function _ReplSA1 ()
	Local nI
	
	cAlias := Alias()
	cCli   := SA1->A1_COD
	cLoj   := SA1->A1_LOJA

	aEstruExp := (cAlias)->( dbStruct() )

	cQueryAux := "SELECT "
	For nI := 1 To Len( aEstruExp )
		If nI > 1
			cQueryAux += ", "
		EndIf
		cQueryAux += aEstruExp[ nI, 1 ]
	Next

	cQueryAux += ", D_E_L_E_T_, " + _CalcRecA1()
	cQueryAux += "FROM " + RetSqlName(cAlias) + " " + cAlias + " "
	cQueryAux += "WHERE " + "A1_FILIAL = '" + xFilial(cAlias) + "'"
	cQueryAux += "  AND " + "A1_COD    = '" + cCli + "'"
	cQueryAux += "  AND " + "A1_LOJA   = '" + cLoj + "'"
	cQueryAux += "  AND D_E_L_E_T_ = ' ' "

	//-- ChangeQuery()
	//-- 1o Parametro : Query
	//-- 2o Parametro : Se .F., nao insere FOR READ ONLY no final das querys para AS/400 e/ou DB2
	cQueryAux := ChangeQuery(cQueryAux, .F.)

	cTemp  := "SA1070"
	cQuery := "INSERT INTO " + cTemp + " ( "
	For nI := 1 To Len( aEstruExp )
		If nI > 1
			cQuery += ", "
		EndIf
		cQuery += aEstruExp[ nI, 1 ]
	Next

	cQuery += ", D_E_L_E_T_, R_E_C_N_O_) " + cQueryAux

	If TCSqlExec( cQuery ) <> 0 

		dbCloseArea()
		Return ( .F. )
	EndIf

	TCRefresh(cTemp)

	// Atualiza A1_CONTRIB após cópia do cliente
	cContrib := "2"
	_cQuery := "UPDATE SA1070"
	_cQuery += " SET A1_CONTRIB = '" + cContrib + "' "
	_cQuery += " WHERE D_E_L_E_T_ <> '*'"
	_cQuery += " AND A1_COD    = '" + cCli + "' "
	_cQuery += " AND A1_LOJA   = '" + cLoj + "' "
	_cQuery += " AND A1_FILIAL = '  ' "
	TcSqlExec(_cQuery)


	// Atualiza A1_MSBLQL após cópia do cliente
	cMsBlQl := "2"
	_cQuery := "UPDATE SA1070"
	_cQuery += " SET A1_MSBLQL = '" + cMsBlQl + "' "
	_cQuery += " WHERE D_E_L_E_T_ <> '*'"
	_cQuery += " AND A1_COD    = '" + cCli + "' "
	_cQuery += " AND A1_LOJA   = '" + cLoj + "' "
	_cQuery += " AND A1_FILIAL = '  ' "
	TcSqlExec(_cQuery)

Return


//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³Chamada da funcao _CalcRecA1()                                   ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
Static Function _CalcRecA1()

	cQueryN := "SELECT MAX (R_E_C_N_O_) + 1 AS PROXREC FROM SA1070"

	TCQuery cQueryN New Alias _QRY
	_ProxRec := AllTrim(Str(_QRY->PROXREC))

	DbCloseArea()

Return(_ProxRec)
