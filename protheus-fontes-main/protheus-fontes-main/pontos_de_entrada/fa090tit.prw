#INCLUDE "TOTVS.CH"
#INCLUDE "TOPCONN.CH"

//--------------------------------------------------------------------------------------
/*/{Protheus.doc} FA090TIT 
@Type			: Ponto de Entrada
@Sample			: U_MGT_BLK1()
@Description	: ponto de entrada FA090TIT será utilizado na confirmacao da baixa dos
                  títulos. Nesse momento o SE2 está filtrado e posicionado.
@Param			: cBanco, cAgencia, cConta, cCheque
@Return			: .T. para confirmar a baixa ou .F. para ir para o próximo título
@ --------------|-----------------------------------------------------------------------
@Author			: Evandro Mugnol
@Since			: Jun/2021
@version		: Protheus 12.1.25 e posteriores
@Comments		: N/A
/*/
//--------------------------------------------------------------------------------------

User Function FA090TIT()

	Local _Area := GetArea()
	Local _lRet := .T.

	If Empty(xFilial('SE4'))
		If SE2->E2_NPR = 'S'
			MsgAlert('Este título possui uma NPR vinculada!')
		Endif
	Endif

	If SE2->E2_BLQPAG = 'S'
		MsgAlert('Título bloqueado para pagamento!')
		_lRet := .F.
	Endif

	_cForn  := SE2->E2_FORNECE
	_cLoja  := SE2->E2_LOJA

	cQuery := "SELECT E2_NUM FROM "+RetSqlName("SE2")+" SE2 "
	cQuery += " WHERE " + RetSQLFil('SE2')
	cQuery += " AND E2_FORNECE = '" + _cForn + "'"
	cQuery += " AND E2_LOJA = '" + _cLoja + "'"
	cQuery += " AND E2_TIPO IN ('PA','NDF') "
	cQuery += " AND (E2_BAIXA = '' OR E2_SALDO <> 0)"
	cQuery += " AND " + RetSQLDel('SE2')

	cQuery := ChangeQuery(cQuery)

	If Select("TMP")<>0
		TMP->(dbCloseArea())
	Endif

	TCQUERY cQuery NEW ALIAS "TMP"

	TMP->(DbGoTop())
	While TMP->(!eof())
		If !MsgYesNo('PA/NDF de número ' + TMP->E2_NUM + ' deste fornecedor em aberto. Continuar?(S/N)')
			_lRet := .F.
			Exit
		Endif
		TMP->(DbSkip())
	EndDo

	TMP->(dbCloseArea())

	RestArea(_area)

Return(_lRet)
