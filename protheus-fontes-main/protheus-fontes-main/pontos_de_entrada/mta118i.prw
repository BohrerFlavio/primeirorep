#INCLUDE "rwmake.ch"     

User Function MTA118I()  

	/*
	ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
	±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
	±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄ¿±±
	±±³Programa  ³ MTA118I  ³ Autor ³ Mario Zimmermann    ³ Data ³ 30.06.2004 ³±±
	±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄ´±±
	±±³Descricao ³ Atualiza B1_CUSTD no Lancamento da NF Despesas de Importac ³±±
	±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
	±±³ Uso      ³ Especifico para Clientes Microsiga                         ³±±
	±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
	±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
	ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
	*/

	_xAlias  := { Alias(), IndexOrd(), RecNo()}

	_cDoc       := SF8->F8_NFDIFRE
	_cSerie     := SF8->F8_SEDIFRE
	_cForne     := SF8->F8_TRANSP
	_cLoja      := SF8->F8_LOJTRAN
	_cOrigDoc   := SF8->F8_NFORIG
	_cOrigSerie := SF8->F8_SERORIG
	_cOrigForne := SF8->F8_FORNECE
	_cOrigLoja  := SF8->F8_LOJA
	_nTotal     := 0
	_nImpos     := 0
	_credicm    := ""

	DbSelectArea("SD1")
	_xAliasSd1  := { Alias(), IndexOrd(), RecNo()}

	DbSelectArea("SF8")
	_xAliasSf8  := { Alias(), IndexOrd(), RecNo()}

	DbSelectArea("SF4")
	_xAliasSf4  := { Alias(), IndexOrd(), RecNo()}

	DbSelectArea("SB1")
	_xAliasSb1  := { Alias(), IndexOrd(), RecNo()}

	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Faz a leitura dos itens da nota que foi confirmada neste momento ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	DbSelectArea("SD1")
	DbSetOrder(1)
	DbSeek(xFilial("SD1")+_cDoc+_cSerie+_cForne+_cLoja)
	Do While !Eof() .And. SD1->D1_FILIAL+SD1->D1_DOC+SD1->D1_SERIE+SD1->D1_FORNECE+SD1->D1_LOJA == xFilial("SD1")+_cDoc+_cSerie+_cForne+_cLoja
		_credicm := ""     
		_nvalicm := 0
		_nTotal  := SD1->D1_TOTAL
		DbSelectArea("SF4")
		DbSeek(xFilial("SF4")+SD1->D1_TES)
		If Found() .And. (Empty(SF4->F4_UPRC) .Or. SF4->F4_UPRC == "S")
			If SF4->F4_CREDICM == "S"
				_nvalicm  := SD1->D1_VALICM
			EndIf
		Endif

		_xTotQtde := 0     
		_cProd    := SD1->D1_COD
		DbSelectArea("SD1")
		_SavSd12  := { Alias(), IndexOrd(), RecNo()}

		DbSelectArea("SF8")
		DbSetOrder(1)
		DbSeek(xFilial("SF8")+SD1->D1_DOC+SD1->D1_SERIE+SD1->D1_FORNECE+SD1->D1_LOJA)
		Do While !EOF() .And. SF8->F8_FILIAL+SF8->F8_NFDIFRE+SF8->F8_SEDIFRE+SF8->F8_FORNECE+SF8->F8_LOJA == xFilial("SF8")+SD1->D1_DOC+SD1->D1_SERIE+SD1->D1_FORNECE+SD1->D1_LOJA
			_cOrigDoc   := SF8->F8_NFORIG
			_cOrigSerie := SF8->F8_SERORIG
			_cOrigForne := SF8->F8_FORNECE
			_cOrigLoja  := SF8->F8_LOJA

			DbSelectArea("SD1")
			DbSetOrder(2)
			DbSeek(xFilial("SD1")+_cProd+_cOrigDoc+_cOrigSerie+_cOrigForne+_cOrigLoja)
			Do While !EOF() .And. xFilial("SD1")+_cProd+_cOrigDoc+_cOrigSerie+_cOrigForne+_cOrigLoja == SD1->D1_FILIAL+SD1->D1_COD+SD1->D1_DOC+SD1->D1_SERIE+SD1->D1_FORNECE+SD1->D1_LOJA
				_xTotQtde += SD1->D1_QUANT
				DbSelectArea("SD1")
				DbSkip()
			EndDo
			DbSelectArea("SF8")
			DbSkip()
		EndDo                     

		DbSelectArea(_SavSd12[1])
		DbSetOrder(_SavSd12[2])
		DBGoto(_SavSd12[3])

		DbSelectArea("SB1")
		DbSetOrder(1)
		DbSeek(xFilial("SB1")+_cProd)
		If Found() .And. _xTotQtde > 0
			RecLock("SB1",.F.)
			Replace B1_CUSTD  With B1_CUSTD + ((_nTotal - _nvalicm) / _xTotQtde)
			Replace B1_DATREF With dDataBase
			MsUnlock()
		Endif

		DbSelectArea("SD1")
		DbSkip()
	Enddo

	DbSelectArea(_xAliasSb1[1])
	DbSetOrder(_xAliasSb1[2])
	DBGoto(_xAliasSb1[3])

	DbSelectArea(_xAliasSd1[1])
	DbSetOrder(_xAliasSd1[2])
	DBGoto(_xAliasSd1[3])

	DbSelectArea(_xAliasSf4[1])
	DbSetOrder(_xAliasSf4[2])
	DBGoto(_xAliasSf4[3])

	DbSelectArea(_xAliasSf8[1])
	DbSetOrder(_xAliasSf8[2])
	DBGoto(_xAliasSf8[3])

	DbSelectArea(_xAlias[1])
	DbSetOrder(_xAlias[2])
	DBGoto(_xAlias[3])

Return(.T.)        
