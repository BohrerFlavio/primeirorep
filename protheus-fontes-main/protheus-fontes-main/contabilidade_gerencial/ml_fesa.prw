#INCLUDE "rwmake.ch"
#INCLUDE "totvs.ch"
#INCLUDE "topconn.ch"

/*/
	ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
	±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
	±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
	±±³Programa  ³ ML_FESA  ³ Autor ³ Evandro Mugnol        ³ Data ³ 20.04.04 ³±±
	±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
	±±³Descricao ³ Calcula imposto do FESA na confirmacao da nota fiscal de   ³±±
	±±³          ³ entrada a partir do cadastro de impostos variaveis         ³±±
	±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
	±±³Uso       ³ Especifico para Frigorifico Silva                          ³±±
	±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
	±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
	ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
	/*/

User Function ML_FESA()

	Local _nI
	_aAlias    := GetArea()
	_aAliasSFC := SFC->(GetArea())
	_nFesa     := 0

	If FunName() $ 'MATA103' .Or. FunName() $ 'STI_RG06'
		_nI :=len(aCols)
		_lTodos := .f.

		For _nI := 1 to 20
			If ProcName(_nI) == 'A103FORF4'   // verifica se a nota está sendo "puxada" de um pedido de compras
				_lTodos := .t.
				Exit
			EndIf
		Next
		If _lTodos      // se é de pedido de compras, atualiza sempre a última linha do acols
			For _nI := 1 to len(aCols) 
				If SFC->(MsSeek(FWxFilial('SFC') + GdFieldGet('D1_TES',_nI),.f.)) // procura no cadastro de impostos variáveis se está cadastrado o tes utilizado
					_nFesa := GdFieldGet("D1_QTSEGUM",_nI) * GetAdvFVal('SB1','B1_FESA',FWxFilial('SB1') + GdFieldGet('D1_COD',_nI),1)
				EndIf
			Next
		Else            // senão atualiza a linha atual do acols (n)
			If SFC->(MsSeek(FWxFilial('SFC') + GdFieldGet('D1_TES'),.f.))       // procura no cadastro de impostos variáveis se está cadastrado o tes utilizado
				_nFesa := GdFieldGet("D1_QTSEGUM") * GetAdvFVal('SB1','B1_FESA',FWxFilial('SB1') + GdFieldGet('D1_COD'),1)
			EndIf
		EndIf
	ElseIf FunName() $ 'MATA121'
		If SFC->(MsSeek(FWxFilial('SFC') + GdFieldGet('C7_TES'),.f.))          // procura no cadastro de impostos variáveis se está cadastrado o tes utilizado
			_nFesa  := GdFieldGet("C7_QTSEGUM") * GetAdvFVal('SB1','B1_FESA',FWxFilial('SB1') + GdFieldGet('C7_PRODUTO'),1)
		EndIf
	ElseIf FunName() $ 'MATA410'
		if empty(SC6->C6_NUM)
			If SFC->(MsSeek(FWxFilial('SFC') + GdFieldGet('C6_TES'),.f.))          // procura no cadastro de impostos variáveis se está cadastrado o tes utilizado
				_nFesa  := GdFieldGet("C6_UNSVEN") * GetAdvFVal('SB1','B1_FESA',FWxFilial('SB1') + GdFieldGet('C6_PRODUTO'),1)
			EndIf
		else
			If SFC->(MsSeek(FWxFilial('SFC') + SC6->C6_TES,.f.))          // procura no cadastro de impostos variáveis se está cadastrado o tes utilizado
				_nFesa  := SC6->C6_UNSVEN * GetAdvFVal('SB1','B1_FESA',FWxFilial('SB1') + SC6->C6_PRODUTO,1)
			EndIf
		endif
		/*
		If SFC->(MsSeek(FWxFilial('SFC') + SC6->C6_TES,.f.))          // procura no cadastro de impostos variáveis se está cadastrado o tes utilizado
		_nFesa  := SC6->C6_UNSVEN * GetAdvFVal('SB1','B1_FESA',FWxFilial('SB1') + SC6->C6_PRODUTO,1)
		EndIf
		*/
	ElseIf FunName() $ 'MATA460A'
		If SFC->(MsSeek(FWxFilial('SFC') + SC6->C6_TES,.f.))                     // procura no cadastro de impostos variáveis se está cadastrado o tes utilizado
			_nFesa  := GetAdvFVal('SC6','C6_UNSVEN',FWxFilial('SC6') + SC9->C9_PEDIDO + SC9->C9_ITEM + SC9->C9_PRODUTO,1) * GetAdvFVal('SB1','B1_FESA',FWxFilial('SB1') + SC6->C6_PRODUTO,1)
		EndIf
	EndIf

	RestArea(_aAliasSFC)
	RestArea(_aAlias)

Return(_nFesa)


User Function SI_FESA()

return 1
