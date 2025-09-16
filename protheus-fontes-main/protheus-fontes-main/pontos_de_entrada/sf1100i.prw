#INCLUDE "rwmake.ch"

User Function SF1100I()

	/*/
	ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
	±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
	±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
	±±³Programa  ³ SF1100I  ³ Autor ³ Ricardo Rech / Leandro³ Data ³ 01.07.04 ³±±
	±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
	±±³Descricao ³ Atualiza Contas a Pagar                                    ³±±
	±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
	±±³Retorno   ³                                                            ³±±
	±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
	±±³Utilizacao³ Especifico para Clientes Microsiga                         ³±±
	±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
	±±³   Data   ³ Programador   ³Manutencao Efetuada                         ³±±
	±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
	±±³          ³               ³                                            ³±±
	±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
	±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
	ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
	/*/

	_cAlias := Alias()

	DbSelectArea("SF1")      // Cabecalho da NF de Entrada
	_nRecSF1  := Recno()
	_nDbOrSF1 := DbSetOrder()

	DbSelectArea("SD1")      // Itens da NF de Entrada
	_nRecSD1  := Recno()
	_nDbOrSD1 := DbSetOrder()

	DbSelectArea("SF3")      // Livros
	_nRecSF3  := Recno()
	_nDbOrSF3 := DbSetOrder()

	DbSelectArea("SE2")      // Contas a Pagar
	_nRecSE2  := Recno()
	_nDbOrSE2 := DbSetOrder()

	DbSelectArea("SED")      // Cabecalho Naturezas
	_nRecSED  := Recno()
	_nDbOrSED := DbSetOrder()

	DbSelectArea("SA2")      // Cabecalho Fornecedor
	_nRecSA2  := Recno()
	_nDbOrSA2 := DbSetOrder()

	_xDoc     := SF1->F1_DOC
	_xSerie   := SF1->F1_SERIE
	_xFornece := SF1->F1_FORNECE
	_xLoja    := SF1->F1_LOJA
	_nValIpi  := SF1->F1_VALIPI
	_cTpFor   := SA2->A2_TIPO 
	_cFormul  := SF1->F1_FORMUL  
	_nPLiq    := SF1->F1_PLIQUI
	_nPBrut   := SF1->F1_PBRUTO 
	_nQtSeg   := SF1->F1_VOLUME1   
	_cEsp     := SF1->F1_ESPECI1


	DbSelectArea("SF1")
	DbSetOrder(1)
	DbSeek(xFilial("SF1")+_xDOC+_xSERIE+_xFORNECE+_xLOJA)
	Do While !Eof() .And. xFilial("SF1") == SF1->F1_FILIAL .And. SF1->F1_DOC+SF1->F1_SERIE+SF1->F1_FORNECE+SF1->F1_LOJA == _xDoc+_xSerie+_xFornece+_xLoja
		_xVlTit  := 0
		xPrefixo := _GetParam()     // Prefixo dos titulos na matriz/filiais

		DbSelectArea("SE2")
		DbSetOrder(1)
		DbSeek(xFilial("SE2")+&xPrefixo+" "+_xDoc)
		Do While !Eof() .And. xFilial("SE2")==SE2->E2_FILIAL .And. SE2->E2_PREFIXO+SE2->E2_NUM == &xPrefixo+" "+_xDoc
			_xVlTit += SE2->E2_VLCRUZ        // Soma Valor Titulos p/ Gravar SF1
			DbSelectArea("SE2")
			DbSkip()
		Enddo


		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄH¿
		//³Bloco para atualizar peso bruto e peso liquido total da NFe ³
		//³quando esta for contra-nota de compra de gado               ³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄHÙ

		_nPLiq  := SF1->F1_PLIQUI
		_nPBrut := SF1->F1_PBRUTO
		_nQtSeg := SF1->F1_VOLUME1

		if _xSerie = '10' .and. ;
		_cFormul = 'S' .and. ;
		_nPLiq  = 0    .and. ;
		_nPBrut = 0    .and. ;
		_nQtSeg = 0    .and. ;
		empty(_cEsp)

			SD1->(DbSetOrder(1))
			if SD1->(DbSeek(xfilial('SD1')+_xDoc+_xSerie+_xFornece+_xLoja )) 

				while SD1->(!eof()) .and. (xfilial('SD1')+_xDoc+_xSerie+_xFornece+_xLoja) = SD1->(D1_FILIAL+D1_DOC+D1_SERIE+D1_FORNECE+D1_LOJA)
					if !(SD1->D1_TES $ '200/205/190/192/328') .or. SD1->D1_SEGUM <> 'CB'
						SD1->(DbSkip())
						loop
					else
						_cEsp := 'CABECA'
					endif      

					_nPliq  += SD1->D1_QUANT
					_nPBrut += SD1->D1_QUANT
					_nQtSeg += SD1->D1_QTSEGUM  

					SD1->(DbSkip())
				enddo
			endif

		endif

		DbSelectArea("SF1") 
		RecLock("SF1",.F.)
		SF1->F1_VALTIT  := _xVlTit 
		SF1->F1_PLIQUI  := _nPLiq 
		SF1->F1_PBRUTO  := _nPBrut 
		SF1->F1_VOLUME1 := _nQtSeg    
		SF1->F1_ESPECI1 := _cEsp
		MsUnLock()
		DbSelectArea("SF1")
		DbSkip()
	Enddo


	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Retorna Posicao Original do Arquivo                          ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	DbSelectArea("SF1")
	Go _nRecSF1
	DbSetOrder(_nDbOrSF1)

	DbSelectArea("SD1")
	Go _nRecSD1
	DbSetOrder(_nDbOrSD1)

	DbSelectArea("SF3")
	Go _nRecSF3
	DbSetOrder(_nDbOrSF3)

	DbSelectArea("SE2")
	Go _nRecSE2
	DbSetOrder(_nDbOrSE2)

	DbSelectArea("SED")
	Go _nRecSED
	DbSetOrder(_nDbOrSED)

	DbSelectArea("SA2")
	Go _nRecSA2
	DbSetOrder(_nDbOrSA2)

	DbSelectArea(_cAlias)

Return(.T.)


Static Function _GetParam()

	_cRet := GetMv("MV_2DUPREF")

Return(_cRet)

