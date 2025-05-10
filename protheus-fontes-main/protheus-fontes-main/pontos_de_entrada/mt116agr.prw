#INCLUDE "totvs.ch"

/*/{Protheus.doc} XMT116AGR
Ponto de entrada Lançamento de Frete de Compras 
@type function
@version  
@author Mario Zimmermann 
@since 30.06.2004 
@return variant, return_description
/*/
User Function XMT116AGR()

	Local 		aAreaOld 	:= GetArea()
	Local 		_cDoc       := cNFiscal
	Local 		_cSerie     := cSerie
	Local 		_cForne     := cA100For
	Local 		_cLoja      := cLoja
	Local 		_cOrigDoc   := SF8->F8_NFORIG
	Local 		_cOrigSerie := SF8->F8_SERORIG
	Local 		_cOrigForne := SF8->F8_FORNECE
	Local 		_cOrigLoja  := SF8->F8_LOJA
	Local 		aAreaSD1	:= SD1->(GetArea())
	Local 		aAreaSF8 	:= SF8->(GetArea())
	Local 		aAreaSF4 	:= SF4->(GetArea())
	Local 		aAreaSB1 	:= SB1->(GetArea())
	Local 		aAreaSF1 	:= SF1->(GetArea())
	
	// Gravar o nome do usuário na tabela SF1 (Solicitação Cristiane Contabilidade 02/05/23)
	DbSelectArea("SF1")
	DbSetOrder(1)
	If DbSeek(xFilial("SF1")+_cDoc+_cSerie+_cForne+_cLoja)
		RecLock("SF1", .F.)
		SF1->F1_SILVA := AllTrim(UsrFullName(RetCodUsr()))
		MsUnLock()
	Endif 

	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Faz a leitura dos itens da nota que foi confirmada neste momento ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	DbSelectArea("SD1")
	DbSetOrder(1)
	DbSeek(xFilial("SD1")+_cDoc+_cSerie+_cForne+_cLoja)
	While !Eof() .And. SD1->D1_FILIAL+SD1->D1_DOC+SD1->D1_SERIE+SD1->D1_FORNECE+SD1->D1_LOJA == xFilial("SD1")+_cDoc+_cSerie+_cForne+_cLoja
		
		DbSelectArea("SF4")
		DbSeek(xFilial("SF4")+SD1->D1_TES)
		If !Found() .Or. SF4->F4_UPRC == "N"
			DbSelectArea("SD1")
			DbSkip()
			Loop
		Endif
		
		_xTotQtde := 0
		_cProd    := SD1->D1_COD
	
		aAreaSD1	:= SD1->(GetArea())

		DbSelectArea("SF8")
		DbSetOrder(1)
		DbSeek(xFilial("SF8")+SD1->D1_DOC+SD1->D1_SERIE)
		Do While !EOF() .And. SF8->F8_FILIAL+SF8->F8_NFDIFRE+SF8->F8_SEDIFRE == xFilial("SF8")+SD1->D1_DOC+SD1->D1_SERIE
			If SF8->F8_TRANSP == _cForne .And.  SF8->F8_LOJTRAN == _cLoja
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
			EndIf
			DbSelectArea("SF8")
			DbSkip()
		Enddo
		RestArea(aAreaSD1)
		
		DbSelectArea("SB1")
		DbSetOrder(1)
		If DbSeek(xFilial("SB1")+_cProd) .And. _xTotQtde > 0
			RecLock("SB1",.F.)
			Replace B1_CUSTD  With B1_CUSTD + (SD1->D1_CUSTO / _xTotQtde)
			Replace B1_DATREF With dDataBase
			MsUnlock()
		Endif

		DbSelectArea("SD1")
		DbSkip()
	Enddo

	RestArea(aAreaSB1)
	RestArea(aAreaSF4)
	RestArea(aAreaSD1)
	RestArea(aAreaSF1)
	RestArea(aAreaSF8)
	RestArea(aAreaOld)


Return
