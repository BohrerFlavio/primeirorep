#INCLUDE "rwmake.ch"
#INCLUDE "topconn.ch"
#INCLUDE "totvs.ch"

User Function MTA410()

	/*/
	ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
	±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
	±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
	±±³Programa  ³ MTA410   ³ Autor ³ Evandro Mugnol        ³ Data ³ 17.06.04 ³±±
	±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
	±±³Descricao ³ Ponto Entrada para validar a gravacao do pedido de venda   ³±±
	±±³          ³                                                            ³±±
	±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
	±±³Uso       ³ Especifico para Frigorifico Silva                          ³±±
	±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
	±±³Observacao³ Altera o valor unitario diminuindo o frete conforme rateio ³±±
	±±³          ³ dos valores para pedidos de exportacao ( MOEDA <> 1 )      ³±±
	±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
	±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
	ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
	/*/
	
	Local nCol
	_aArea := GetArea()
	_lRet  := .T.

	If M->C5_TPFRETE == "C" .And. M->C5_FRETE > 0 .And. M->C5_MOEDA <> 1
		If MsgBox("Executa rateio do valor do frete nos produtos?","Rateio do Frete","YesNo")
			nValTot    := 0
			nSomaFrete := 0
			nQdeTot    := 0
			For nCol := 1 to len(aCols)
				If !GdDeleted(nCol)
					nValTot += GdFieldGet('C6_VALOR',nCol)
					nQdeTot += GdFieldGet('C6_QTDVEN',nCol)
				EndIf
			Next

			If M->C5_FRETE > nValTot
				MsgBox("Valor do frete maior que a soma dos itens, nao sera efetuado o rateio do frete sobre os itens")
			Else
				nRatFrete := Round(M->C5_FRETE / nQdeTot,6)
				For nCol := 1 to len(aCols)
					If !GdDeleted(nCol)
						GdFieldPut('C6_PRCVEN', GdFieldGet('C6_PRCVEN',nCol) - nRatFrete, nCol)
						GdFieldPut('C6_PRUNIT', GdFieldGet('C6_PRCVEN',nCol), nCol)
						GdFieldPut('C6_VALOR' , GdFieldGet('C6_QTDVEN',nCol) * GdFieldGet('C6_PRCVEN', nCol), nCol)
					EndIf
				Next
			EndIf
		EndIf
	EndIf

	if !empty(M->C5_PCOMPRA)  // Para preenchimento automático de código de pedido de venda em cada item
		for nCol := 1 to len(aCols)
			GdFieldPut('C6_NUMPCOM', alltrim(M->C5_PCOMPRA), nCol)
		next
	EndIf

	RestArea(_aArea)

Return(_lRet)
