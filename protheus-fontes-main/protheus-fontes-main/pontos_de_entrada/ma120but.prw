#INCLUDE "rwmake.ch"

User Function MA120BUT()

	/*/
	ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
	±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
	±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
	±±³Programa  ³ MA120BUT ³ Autor ³ Evandro Mugnol        ³ Data ³ 01.07.04 ³±±
	±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
	±±³Descricao ³ Ponto Entrada que cria um botao na barra de ferramentas do ³±±
	±±³          ³ pedido de compras possibilitando alterar o fornecedor      ³±±
	±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
	±±³Uso       ³ Especifico para Frigorifico Silva                          ³±±
	±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
	±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
	ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
	±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
	±±³Adicionado botão para preenchimento de dados da DI para importação por ³±±    
	±±³Giuliano Forgiarini em 01/10/10.                                       ³±±
	±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
	/*/

	_aAlias := GetArea()
	_aRet   := {}

	If Altera
		_xRet := '{{"USER_OCEAN",{|| U_ML_120() }, "Alt Forn"}}'
		_aRet := &_xRet
	EndIf

	RestArea(_aAlias)

Return(_aRet)


//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Inicio do Processamento                                      ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
User Function ML_120()

	_cQuery := "SELECT SUM(C7_QUJE) C7_QUJE "
	_cQuery += " FROM " + RetSqlName('SC7')
	_cQuery += " WHERE D_E_L_E_T_ <> '*'"
	_cQuery += " AND C7_FILIAL = '" + FWxFilial('SC7') + "'"
	_cQuery += " AND C7_NUM = '" + CA120NUM + "'"

	DbUseArea(.T.,'TOPCONN',TcGenQry(,,_cQuery),'TRB',.F.,.F.)
	_nQuant := TRB->C7_QUJE
	DbCloseArea()

	If _nQuant > 0
		MsgAlert("Fornecedor não pode ser alterado para este pedido, pois o mesmo já está TOTAL ou PARCIALMENTE atendido","")
		Return
	EndIf

	If Select('ML_120') <> 0
		DbSelectArea('ML_120')
		DbGoTo(2)
		_cFornece := Left(ML_120->CAMPO,6)
		_cLoja    := Substr(ML_120->CAMPO,7,2)
	Else
		_aEstru := {{'CAMPO','C',10,0}}
		//_cArq   := CriaTrab(_aEstru,.t.)
		//DbUseArea(.t.,,_cArq,'ML_120',.T.,.F.)

		// ProcData 04/2023 - Chamada para criação do arquivo de trabalho
		_aArqTrb := {}

		U_ArqTrb("Cria", "ML_120", _aEstru, {}, @_aArqTrb)

		RecLock('ML_120',.T.)
		ML_120->CAMPO := "ML_120"
		MsUnLock()
		RecLock('ML_120',.T.)
		MsUnLock()

		_cFornece := '      '
		_cLoja    := '  '
	EndIf

	Do While .T.
		_lCancela := .T.
		@ 000, 000 To 100, 190 DIALOG oDlg1 TITLE "Alteracao do Fornecedor"
		@ 005, 005 SAY "Fornecedor"
		@ 015, 005 SAY "Loja"
		@ 005, 050 GET _cFornece  F3 "SA2" SIZE 040, 11
		@ 015, 050 GET _cLoja              SIZE 020, 11
		@ 030, 025 BMPBUTTON TYPE 1 ACTION (_lCancela := .F., Close(oDlg1))
		@ 030, 055 BMPBUTTON TYPE 2 ACTION (_lCancela := .T., Close(oDlg1))

		ACTIVATE DIALOG oDlg1 CENTERED

		If _lCancela
			Exit
		EndIf

		If !Empty(GetAdvFVal('SA2','A2_NOME',FWxFilial('SA2') + _cFornece + _cLoja,1))
			Exit
		EndIf
	Enddo

	If !_lCancela .And. !Empty(_cFornece+_cLoja)
		DbGoTo(2)
		RecLock('ML_120',.F.)
		ML_120->CAMPO := _cFornece+_cLoja
		MsUnLock()
	EndIf                               

Return

