#INCLUDE "rwmake.ch"
#INCLUDE "topconn.ch"

User Function WFW120P()

	/*/
	ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
	±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
	±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
	±±³Programa  ³ WFW120P  ³ Autor ³ Evandro Mugnol        ³ Data ³ 01.07.04 ³±±
	±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
	±±³Descricao ³ Ponto Entrada que verifica se existe o alias ML_120 e grava³±±
	±±³          ³ o fornecedor alterado e fecha o alias                      ³±±
	±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
	±±³Uso       ³ Especifico para Frigorifico Silva                          ³±±
	±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
	±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
	ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
	/*/ 

	If Select("ML_120") <> 0
		_aAlias := GetArea()

		DbSelectArea("ML_120")
		DbGoTop()
		_cArq := ML_120->CAMPO
		DbGoTo(2)
		_cFornece := Left(ML_120->CAMPO,6)
		_cLoja    := Substr(ML_120->CAMPO,7,2)

		ML_120->(DbCloseArea())
		FErase(_cArq+'.dbf')

		If !Empty(_cFornece+_cLoja)
			_cQuery := "UPDATE " + RetSqlName('SC7')
			_cQuery += " SET C7_FORNECE = '" + _cFornece + "', "
			_cQuery +=     " C7_LOJA = '" + _cLoja + "'"
			_cQuery += " WHERE D_E_L_E_T_ <> '*'"
			_cQuery += " AND C7_NUM = '" + substr(Paramixb,3) + "'"
			_cQuery += " AND C7_FILIAL = '" + xFilial('SC7') + "'"
			TcSqlExec(_cQuery)
		EndIf
		RestArea(_aAlias)
	EndIf

	//////////////////////////////////////////////////////////////////////
	//AJUSTES PARA DIRECIONAMENTO DE REAPROVAÇÃO DOS PEDIDOS EM 27.05.2014
	//////////////////////////////////////////////////////////////////////

	//Parametro que direciona a aprovação a um determinado usuário
	_cCodUser := GetMV('SI_DIRAPRO')
	//alert(_cCodUser)
	SC7->(DbSetOrder(1))
	SC7->(DbSeek(PARAMIXB))

	//Se for operação de alterar, houver usuário apontado e grupo de compradores = 000004
	if ALTERA .and. !empty(_cCodUser) .and. SC7->C7_GRUPCOM = '000004'
		if !msgbox('Necessária aprovação da diretoria? (S/N)','DIRECIONAMENTO DE APROVAÇÃO','YESNO')

			SAK->(DbSetOrder(2))
			if !SAK->(DbSeek(xfilial('SAK')+_cCodUser))
				alert('Usuario apontado não cadastrado para liberação!')
				return
			endif

			_cCodLib := SAK->AK_COD

			_cQuery := "UPDATE " + RetSqlName('SCR')
			_cQuery += " SET D_E_L_E_T_ = '*'"		
			_cQuery += " WHERE CR_NUM = '"+substr(Paramixb,3)+ "' AND CR_NIVEL = '01' AND CR_STATUS = '02' AND CR_TIPO = 'PC'"
			_cQuery += " AND CR_USERLIB = '' AND CR_USER <> '" + alltrim(_cCodUser) + "' AND CR_APROV <> '" + alltrim(_cCodLib) + "'"

			//	* Mostrar a consulta */
			//@ 116,090 To 416,707 Dialog oDlgMemo Title "Consulta"
			//@ 055,005 Get _cQuery Size 250,080 MEMO Object oMemo
			//Activate Dialog oDlgMemo

			TcSqlExec(_cQuery)

		endif
	endif

return
