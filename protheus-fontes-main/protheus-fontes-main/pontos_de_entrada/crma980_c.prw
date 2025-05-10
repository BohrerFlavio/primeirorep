#INCLUDE "Protheus.ch"
#INCLUDE "FWMVCDEF.CH"
#INCLUDE "rwmake.ch"
#INCLUDE "topconn.ch"

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³ CRMA980_C                             º Data ³  24/01/23   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDescricao ³ Ponto Entrada Apos Inclusao do Cad. Clientes para limpar o ³±±
±±³          ³ campo A1_CGC caso o campo A1_TIPO = "X" e A1_EST = "EX"    ³±±
±±³          ³ Isso se deve ao fato de gerar nota fiscal eletronica de    ³±±
±±³          ³ exportacao.                                                ³±±
±±³          ³                                                            ³±±
±±³          ³ Replica cadastro do cliente para empresa 07 na inclusao    ³±±
±±º          ³                                                            º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/

User Function CRMA980() ///cXXX1,cXXX2,cXXX3,cXXX4,cXXX5,cXXX6

	Local aParam        := PARAMIXB
    Local xRet          := .T.
    Local cIdPonto      := ''
    Local cIdModel      := ''
    Local oObj          := NIL

	if aParam <> NIL
		oObj        := aParam[1]
        cIdPonto    := aParam[2]
        cIdModel    := aParam[3]
		nOperation := oObj:GetOperation()

		if (cIdPonto == "FORMCOMMITTTSPOS")
			//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
			//³Replica o cliente incluido na empresa 07                         ³
			//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ

			if cEmpAnt == "01" .and. nOperation = 3
				xRet := _ReplSA1()
			//elseif cEmpAnt == "01" .and. nOperation = 4
			//	xRet := _AltSA1()
			endif

		endif
	endif

Return xRet

Static Function _LimpaCGC()
	If SA1->A1_TIPO == "X" .And. SA1->A1_EST == "EX"
		RecLock("SA1",.F.)
		SA1->A1_CGC := ""
		MsUnlock()
	Endif
Return

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³Chamada da funcao _AltSA1                                       ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
Static Function _AltSA1()

	_LimpaCGC()
	// Atualiza A1_MSBLQL e A1_CONTRIB
	cCli   := SA1->A1_COD
	cLoj   := SA1->A1_LOJA
	cContr := SA1->A1_CONTRIB
	cBloq  := SA1->A1_MSBLQL

	// Atualiza A1_CONTRIB
	_cQuery := "UPDATE SA1070"
	_cQuery += " SET A1_CONTRIB = '" + cContr + "' "
	_cQuery += " WHERE D_E_L_E_T_ <> '*'"
	_cQuery += " AND A1_COD    = '" + cCli + "' "
	_cQuery += " AND A1_LOJA   = '" + cLoj + "' "
	_cQuery += " AND A1_FILIAL = '  ' "
	TcSqlExec(_cQuery)

	// Atualiza A1_MSBLQL
	_cQuery := "UPDATE SA1070"
	_cQuery += " SET A1_MSBLQL = '" + cBloq + "' "
	_cQuery += " WHERE D_E_L_E_T_ <> '*'"
	_cQuery += " AND A1_COD    = '" + cCli + "' "
	_cQuery += " AND A1_LOJA   = '" + cLoj + "' "
	_cQuery += " AND A1_FILIAL = '  ' "
	TcSqlExec(_cQuery)
Return (.T.)

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³Chamada da funcao _ReplSA1                                       ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
Static Function _ReplSA1()
	Local nI

	_LimpaCGC()

	cCli   := SA1->A1_COD
	cLoj   := SA1->A1_LOJA

	aEstruExp := SA1->(dbStruct())

	cQueryAux := "SELECT "
	For nI := 1 To Len(aEstruExp)
		If nI > 1
			cQueryAux += ", "
		EndIf
		cQueryAux += aEstruExp[nI, 1]
	Next

	cQueryAux += ", D_E_L_E_T_, " + _CalcRecA1()
	cQueryAux += "FROM " + RetSqlTab("SA1")
	cQueryAux += " WHERE " + "A1_FILIAL = '" + xFilial("SA1") + "'"
	cQueryAux += " AND " + "A1_COD    = '" + cCli + "'"
	cQueryAux += " AND " + "A1_LOJA   = '" + cLoj + "'"
	cQueryAux += " AND D_E_L_E_T_ <> '*' "

	//-- ChangeQuery()
	//-- 1o Parametro : Query
	//-- 2o Parametro : Se .F., nao insere FOR READ ONLY no final das querys para AS/400 e/ou DB2
	cQueryAux := ChangeQuery(cQueryAux, .F.)

	cTemp  := "SA1070"
	cQuery := "INSERT INTO " + cTemp + " ( "
	For nI := 1 To Len(aEstruExp)
		If nI > 1
			cQuery += ", "
		EndIf
		cQuery += aEstruExp[nI, 1]
	Next

	cQuery += ", D_E_L_E_T_, R_E_C_N_O_) " + cQueryAux

	If TCSqlExec(cQuery) <> 0 
		dbCloseArea()
		Return (.F.)
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

Return (.T.)

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³Chamada da funcao _CalcRecA1()                                   ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
Static Function _CalcRecA1()

	cQueryN := "SELECT MAX (R_E_C_N_O_) + 1 AS PROXREC FROM SA1070"

	TCQuery cQueryN New Alias _QRY
	_ProxRec := AllTrim(Str(_QRY->PROXREC))

	DbCloseArea()

Return (_ProxRec)
