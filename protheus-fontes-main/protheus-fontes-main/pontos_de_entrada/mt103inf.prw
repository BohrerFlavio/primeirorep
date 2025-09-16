#INCLUDE "Protheus.ch"

User Function MT103INF()

	/*/
	ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
	±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
	±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
	±±³Programa  ³ MT103INF ³ Autor ³ Evandro Mugnol        ³ Data ³ Jan/2013 ³±±
	±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
	±±³Descricao ³ Ponto entrada para atualizar a função fiscal com base no   ³±±
	±±³          ³ item do documento de saida e atualizar o aCols também.     ³±±
	±±³          ³ Na nota de entrada, no momento de importar o item da nota  ³±±
	±±³          ³ original. Ex: nf de devolucao o item da nota original      ³±±
	±±³          ³ encontra-se posicionado:  SD2 (Brasil)                     ³±±
	±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
	±±³Utilizacao³ Especifico para clientes TOTVS                             ³±±
	±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
	±±³   Data   ³ Programador   ³Manutencao Efetuada                         ³±±
	±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
	±±³          ³               ³                                            ³±±
	±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
	±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
	ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
	/*/

	Local _aArea     := GetArea()
	Local _nLinAcols := PARAMIXB[1]

	_nPosTES := AScan( aHeader, { |x| AllTrim( x[2] ) == "D1_TES"     } )
	_nPosNFO := AScan( aHeader, { |x| AllTrim( x[2] ) == "D1_NFORI"   } )
	_nPosSER := AScan( aHeader, { |x| AllTrim( x[2] ) == "D1_SERIORI" } )
	_nPosITE := AScan( aHeader, { |x| AllTrim( x[2] ) == "D1_ITEMORI" } )
	_nPosCOD := AScan( aHeader, { |x| AllTrim( x[2] ) == "D1_COD"     } )

	// Executa somente se for informado TES e a operação for de Classificação
	If _nPosTES > 0 .And. l103Class
		_cTESDev  := aCols[ _nLinAcols, _nPosTES ]
		_cNFiscal := aCols[ _nLinAcols, _nPosNFO ]
		_cSerie   := aCols[ _nLinAcols, _nPosSER ]
		_cItemNF  := aCols[ _nLinAcols, _nPosITE ]
		_cProduto := aCols[ _nLinAcols, _nPosCOD ]

		If cTipo == "D" .And. !Empty(_cNFiscal) .And. !Empty(_cSerie) .And. !Empty(_cItemNF) .And. !Empty(_cProduto)
			// Busca TES de Devolução a partir do TES do Item da Nota de Origem
			DbSelectArea("SD2")
			DbSetOrder(3)
			MsSeek(FWxFilial("SD2") + _cNFiscal + _cSerie + ca100For + cLoja + _cProduto + _cItemNF)
			If Found()
				GdFieldPut("D1_TES", GetAdvFVal("SF4", "F4_TESDV", FWxFilial("SF4") + SD2->D2_TES, 1), _nLinAcols)
				MaFisAlt("IT_TES", GetAdvFVal("SF4", "F4_TESDV", FWxFilial("SF4") + SD2->D2_TES, 1), _nLinAcols)
			Else
				GdFieldPut("D1_TES", _cTESDev, _nLinAcols)
				MaFisAlt("IT_TES", _cTESDev, _nLinAcols)
			Endif
		Endif
	EndIf

	RestArea(_aArea)

Return
