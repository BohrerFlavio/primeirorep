#INCLUDE "rwmake.ch"

User Function VL_CNPJ()

	/*/
	ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
	±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
	±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
	±±³Programa  ³ VL_CNPJ  ³ Autor ³ Evandro Mugnol        ³ Data ³ 16.06.04 ³±±
	±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
	±±³Descricao ³ Validacao para o campo CNPJ do cadastro de clientes e do   ³±±
	±±³          ³ cadastro de fornecedores                                   ³±±
	±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
	±±³Uso       ³ Especifico para Frigorifico Silva                          ³±±
	±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
	±±³Observacao³                                                            ³±±
	±±³          ³                                                            ³±±
	±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
	±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
	ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
	/*/

	_xRet:=.T.

	If FunName() = "MATA030"
		If M->A1_TIPO <> "X"
			_xRet := .F.
			If CGC(M->A1_CGC)
				If !ExistChav("SA1",M->A1_CGC,3,"A1_CGC")
					If MsgYesNo("CNPJ já existe para este Cliente. Deseja incluí-lo?")
						_xRet := .T.
					Endif
				Else
					_xRet := .T.
				Endif
			Else
				_xRet := .F.
			Endif
		Else
			If M->A1_CGC <> "00000000000000"
				_xRet := .F.
				MsgAlert("CNPJ para Cliente Exportação deve ser 00000000000000")
			Endif
		Endif
	ElseIf FunName() = "MATA020"
		If M->A2_TIPO <> "X"
			_xRet := .F.
			If CGC(M->A2_CGC)
				If !ExistChav("SA2",M->A2_CGC,3,"A2_CGC")
					If MsgYesNo("CNPJ já existe para este Fornecedor. Deseja incluí-lo?")
						_xRet := .T.
					Endif
				Else
					_xRet := .T.
				Endif
			Else
				_xRet := .F.
			Endif
			/*/
			If Trim(M->A2_TPFOR) <> "R"
			If Vazio().Or.(Cgc(M->A2_CGC).And.Existchav("SA2",M->A2_CGC,3,"A2_CGC"))
			_xRet := .T.
			Else
			_xRet := .F.
			Endif
			Else
			_xRet := .F.
			If MsgYesNo("CNPJ já existe para este Fornecedor. Deseja incluí-lo?")
			_xRet := .T.
			Endif
			Endif
			/*/
		Else
			If M->A2_CGC <> "00000000000000"
				_xRet := .F.
				MsgAlert("CNPJ para Fornecedor Importacao deve ser 00000000000000")
			Endif
		Endif
	EndIf

Return(_xRet)
