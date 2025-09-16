#INCLUDE "rwmake.ch"
#INCLUDE "topconn.ch"
/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³FA080TIT   º Autor ³ Giuliano Forgiariniº Data ³  11/05/    º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDescricao ³ Ponto de Entrada que mostra se o titulo possui uma NPR     º±±
±±º          ³ vinculada a ele. Também irá verificar se está bloqueado ou º±±
±±º          ³ não para fazer a baixa                                     º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ AP6 Financeiro                                             º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/

User Function FA080TIT()
	local _ret := .t.
	_area := getArea()

	if empty(xfilial('SE4'))
		if SE2->E2_NPR = 'S'
			msgbox('Este título possui uma NPR vinculada!')
		endif
	endif

	if SE2->E2_BLQPAG = 'S'
		msgbox('Título bloqueado para pagamento!') 
		_ret := .f.
	endif       

	//_nIndex := RetIndex('SE2')
	_cForn  := SE2->E2_FORNECE
	_cLoja  := SE2->E2_LOJA   

	//_cRecno := recno()

	cQuery := "SELECT E2_NUM FROM "+RetSqlName("SE2")+" SE2 "
	cQuery += " WHERE " + RetSQLFil('SE2')
	cQuery += " AND E2_FORNECE = '" + _cForn + "'"
	cQuery += " AND E2_LOJA = '" + _cLoja + "'"
	cQuery += " AND E2_TIPO IN ('PA','NDF') "
	cQuery += " AND (E2_BAIXA = '' OR E2_SALDO <> 0)"
	cQuery += " AND " + RetSQLDel('SE2')

	cQuery := ChangeQuery(cQuery)

	//	* Mostrar a consulta */
	//@ 116,090 To 416,707 Dialog oDlgMemo Title "Consulta"
	//@ 055,005 Get cQuery Size 250,080 MEMO Object oMemo
	//Activate Dialog oDlgMemo

	If Select("TMP")<>0
		TMP->(dbCloseArea())
	Endif

	TCQUERY cQuery NEW ALIAS "TMP"

	TMP->(DbGoTop())
	While TMP->(!eof())
		if !msgbox('PA/NDF de número ' + TMP->E2_NUM + ' deste fornecedor em aberto. Continuar?(S/N)','ATENÇÃO!!','YESNO')
			_ret := .f.                                                                                               
			exit
		endif
		TMP->(DbSkip())
	enddo

	TMP->(dbCloseArea())
	
	RestArea(_area)

Return(_ret)
