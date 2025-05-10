#INCLUDE "PROTHEUS.CH"
#INCLUDE "FWMVCDEF.CH"
#INCLUDE "TOPCONN.CH"

/*/{Protheus.doc} STI_SEGF
Rotina para marcar os fornecedores que se deseja atualizar no processo de cotação. Chamada no ponto de entrada MT131FOR
@author     Evandro
@since      09/06/2020
@param		N/A
@return     Array contendo os dados dos fornecedores selecionados
/*/

User Function STI_SEGF(_cSeg, _cProd)

	Private cSegmentos := _cSeg
	Private cProdutoC1 := _cProd
	Private aRetFor    := ""
	Private oArqTrbFor := Nil
	Private oBrowseFor := Nil

	CriaBrw()
	oArqTrbFor:Delete()

Return aRetFor


//-------------------------------------------------------------------
/*/{Protheus.doc} CriaBrw
Função que efetua a criação do browse
@author     Evandro
@since      09/06/2020
@return     N/A
@obs        N/A
/*/
//-------------------------------------------------------------------
Static Function CriaBrw()

	Local lMarcar  := .F.
	Local _aUltFor := {}
	Local _nCntFor
	
	_aUltFor := aSTIUlForn(10, cProdutoC1)		// Localiza os últimos fornecimentos de um produto (Sempre os últimos 10)

	// Atualiza a 'Data da Última Compra Cotação' no cadastro de fornecedores apurado na função 'aSTIUlForn()' para ser usado na 
	// montagem do browse de seleção, pois tem o objetivo de ordenar o browse por ordem de data descendente. 
	For _nCntFor := 1 To Len(_aUltFor)
		
		if SA2->(MsSeek( xFilial("SA2") + _aUltFor[_nCntFor][1] + _aUltFor[_nCntFor][2] ))
		
		
			RecLock("SA2",.F.)
			SA2->A2_ULTCOMC := _aUltFor[_nCntFor][3]
			MsUnlock()
			
		endif
	Next _nCntFor

	Processa({|| oArqTrbFor := CriaTRB()}, "Aguarde, Carregando Registros...", "", .F.)

	oBrowseFor := FWMarkBrowse():New()
	oBrowseFor:SetAlias(oArqTrbFor:GetAlias())
	oBrowseFor:SetDescription("Selecione os fornecedores para cotação")
	oBrowseFor:SetFieldMark("TAB_OK")
	oBrowseFor:DisableDetails()
	oBrowseFor:SetTemporary(.T.)
	oBrowseFor:SetWalkThru(.F.)
	oBrowseFor:SetIgnoreARotina(.T.)
	oBrowseFor:SetMenuDef("")
	oBrowseFor:oBrowse:SetFixedBrowse(.T.)
	oBrowseFor:oBrowse:SetDBFFilter(.F.)
	oBrowseFor:oBrowse:SetUseFilter(.F.)
	oBrowseFor:oBrowse:SetFilterDefault("")
	oBrowseFor:oBrowse:SetIgnoreARotina(.T.)
	oBrowseFor:oBrowse:SetMenuDef("")

	oBrowseFor:AddButton("Confirmar", { || Confirmar()},,,, .F., 2 )

	oBrowseFor:bAllMark := { || CheckAll(oBrowseFor:Mark() ,lMarcar := !lMarcar), oBrowseFor:Refresh(.T.)}

	oBrowseFor:SetColumns(AddColu("A2_FILIAL",	"Filial",			1, "", 1,  2, 0))
	oBrowseFor:SetColumns(AddColu("ZLR_CODSEG",	"Segmento",			1, "", 1,  3, 0))
	oBrowseFor:SetColumns(AddColu("ZLR_DESSEG",	"Descrição",		1, "", 1, 50, 0))
	oBrowseFor:SetColumns(AddColu("A2_ULTCOMC",	"Última Compra",	1, "", 1,  8, 0))
	oBrowseFor:SetColumns(AddColu("A2_COD",		"Fornecedor",		1, "", 1,  6, 0))
	oBrowseFor:SetColumns(AddColu("A2_LOJA",	"Loja",				1, "", 1,  2, 0))
	oBrowseFor:SetColumns(AddColu("A2_NOME",	"Razão Social",		1, "", 1, 40, 0))

	oBrowseFor:Activate()

Return


//-------------------------------------------------------------------
/*/{Protheus.doc} CriaTRB
Função que efetua a criação do arquivo de trabalho
@author     Evandro
@since      09/06/2020
@return     Objeto com o resultado do arquivo de trabalho
@obs        N/A
/*/
//-------------------------------------------------------------------
Static Function CriaTRB()

	Local aAreaSA2    := SA2->(GetArea())
	Local aCampos     := {}
	Local cUltCod     := ""
	Local cAliasArea  := ""
	Local nRecCount   := 0
	Local oTrb        := Nil

	Aadd(aCampos,{ "TAB_OK",	 "C", TamSX3("A2_OK")[1], 	   0 } )
	Aadd(aCampos,{ "A2_FILIAL",	 "C", TamSX3("A2_FILIAL")[1],  0 } )
	Aadd(aCampos,{ "A2_COD",	 "C", TamSX3("A2_COD")[1], 	   0 } )
	Aadd(aCampos,{ "A2_LOJA",	 "C", TamSX3("A2_LOJA")[1],    0 } )
	Aadd(aCampos,{ "A2_NOME",	 "C", TamSX3("A2_NOME")[1],    0 } )
	Aadd(aCampos,{ "A2_ULTCOMC", "D", TamSX3("A2_ULTCOMC")[1], 0 } )
	Aadd(aCampos,{ "ZLR_CODSEG", "C", TamSX3("ZLR_CODSEG")[1], 0 } )
	Aadd(aCampos,{ "ZLR_DESSEG", "C", TamSX3("ZLR_DESSEG")[1], 0 } )

	oTrb := FWTemporaryTable():New()
	oTrb:SetFields(aCampos)

	//oTrb:AddIndex("IDX1", {"A2_FILIAL", "ZLR_CODSEG", "A2_ULTCOMC", "A2_COD", "A2_LOJA"})

	oTrb:Create()
	cAliasArea := oTrb:GetAlias()

	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Calcula total de registros a serem processados corretamente ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	cQuery := "SELECT COUNT( SA2.R_E_C_N_O_ ) TOTREG "
	cQuery += "  FROM " + RetSQLTab("SA2")
	cQuery += " INNER JOIN " + RetSqlTab("ZLR") + " ON ZLR_FILIAL = '" + xFilial("ZLR") + "' AND ZLR_CODFOR = A2_COD AND ZLR_LOJFOR = A2_LOJA AND ZLR.D_E_L_E_T_ = '' "
	cQuery += " WHERE " + RetSQLFil("SA2")
	cQuery += "   AND A2_MSBLQL <> '1' "
	cQuery += "   AND ZLR_CODSEG IN " + FORMATIN(cSegmentos,",")
	cQuery += "   AND " + RetSQLDel("SA2")

	cQuery := ChangeQuery(cQuery)

	dbUseArea(.T.,"TOPCONN",TcGenQry(,,cQuery),"TRBTOT",.T.,.T.)

	ProcRegua(TRBTOT->TOTREG)

	TRBTOT->( DbCloseArea() )

	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Processamento dos Dados                                  ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	cQuery := "SELECT A2_FILIAL, ZLR_CODSEG, ZLR_DESSEG, A2_ULTCOMC, A2_COD, A2_LOJA, A2_NOME "
	cQuery += "  FROM " + RetSQLTab("SA2")
	cQuery += " INNER JOIN " + RetSqlTab("ZLR") + " ON ZLR_FILIAL = '" + xFilial("ZLR") + "' AND ZLR_CODFOR = A2_COD AND ZLR_LOJFOR = A2_LOJA AND ZLR.D_E_L_E_T_ = '' "
	cQuery += " WHERE " + RetSQLFil("SA2")
	cQuery += "   AND A2_MSBLQL <> '1' "
	cQuery += "   AND ZLR_CODSEG IN " + FORMATIN(cSegmentos,",")
	cQuery += "   AND " + RetSQLDel("SA2")
	cQuery += " ORDER BY A2_FILIAL, ZLR_CODSEG, A2_ULTCOMC DESC, A2_COD, A2_LOJA "

	cQuery := ChangeQuery(cQuery)

	//Memowrite("ZZZ_STI_SEGF", cQuery)

	DbUseArea( .T., 'TOPCONN', TCGENQRY(,,cQuery), "TRB", .F., .T.)

	TRB->(dbGoTop())
	While TRB->(!Eof())

		IncProc("Carregando ...")

		RecLock((cAliasArea), .T.)
		(cAliasArea)->A2_FILIAL	 := TRB->A2_FILIAL
		(cAliasArea)->A2_COD	 := TRB->A2_COD
		(cAliasArea)->A2_LOJA	 := TRB->A2_LOJA
		(cAliasArea)->A2_NOME	 := TRB->A2_NOME
		(cAliasArea)->A2_ULTCOMC := StoD( TRB->A2_ULTCOMC )
		(cAliasArea)->ZLR_CODSEG := TRB->ZLR_CODSEG
		(cAliasArea)->ZLR_DESSEG := TRB->ZLR_DESSEG
		MsUnlock((cAliasArea))

		TRB->(DbSkip())
	Enddo

	TRB->(DbCloseArea())

	RestArea(aAreaSA2)

Return oTrb


//-------------------------------------------------------------------
/*/{Protheus.doc} Confirmar
Função que valida a confirmação da tela de seleção dos fornecedores para cotação.
@author     Evandro
@since      09/06/2020
@return     N/A
@obs        N/A
/*/
//-------------------------------------------------------------------
Static Function Confirmar()

	Local cAliasFor := oArqTrbFor:GetAlias()
	Local nFCount   := 0
	Local nX        := 0
	Local aLinha    := {}

	aRetFor := {}
	nFCount := (cAliasFor)->(FCount())

	(cAliasFor)->(DbGoTop())
	While !((cAliasFor)->(Eof()))

		If (!Empty((cAliasFor)->(TAB_OK)))

			aLinha := {}
			For nX := 2 To nFCount
				aAdd(aLinha, (cAliasFor)->(FieldGet(nX)))
			End

			SA2->(MsSeek( xFilial("SA2") + aLinha[2] + aLinha[3] ))
			aAdd(aRetFor, { aLinha[2], aLinha[3], "ULT. COMPRA EM: " + Dtoc( aLinha[5] ) + " Seg.: " + aLinha[6], "SA2", SA2->(Recno()) } )

		EndIf

		(cAliasFor)->(DbSkip())
	EndDo

	If (Empty(aRetFor))
		MsgStop("É necessário confirmar um dos registros para prosseguir!")
		(cAliasFor)->(DbGoTop())
	Else
		CloseBrowse()
	EndIf

Return


//-------------------------------------------------------------------
/*/{Protheus.doc} AddColu
Função que adiciona colunas no browse
@author     Evandro
@since      09/06/2020
@return     Array com as colunas
@obs        N/A
/*/
//-------------------------------------------------------------------
Static Function AddColu(cCampo,cTitulo,nArrData,cPicture,nAlign,nSize,nDecimal)

	Local aColumn
	Local bData 	 := {||}
	Default nAlign 	 := 1
	Default nSize 	 := 20
	Default nDecimal := 0
	Default nArrData := 0

	If nArrData > 0
		bData := &("{||" + cCampo +"}") //&("{||oBrowseFor:DataArray[oBrowseFor:At(),"+STR(nArrData)+"]}")
	EndIf

	aColumn := {cTitulo,bData,,cPicture,nAlign,nSize,nDecimal,.F.,{||.T.},.F.,{||.T.},NIL,{||.T.},.F.,.F.,{}}

Return { aColumn }


//-------------------------------------------------------------------
/*/{Protheus.doc} CheckAll
Função que verifica os itens marcados
@author     Evandro
@since      09/06/2020
@return     Lógico
@obs        N/A
/*/
//-------------------------------------------------------------------
Static Function CheckAll(cMarca, lMarcar)

	Local cAliasTRB := oArqTrbFor:GetAlias()
	Local aAreaTRB  := (cAliasTRB)->(GetArea())
	Local cTAB_OK   := IIf(lMarcar, cMarca, '  ')

	dbSelectArea(cAliasTRB)
	(cAliasTRB)->(dbGoTop())

	While !(cAliasTRB)->(Eof())
		RecLock((cAliasTRB), .F.)
		(cAliasTRB)->TAB_OK := cTAB_OK
		MsUnlock()

		(cAliasTRB)->(dbSkip())
	EndDo

	RestArea(aAreaTRB)

Return .T.


//-------------------------------------------------------------------
/*/{Protheus.doc} aSTIUlForn
Função que localiza os últimos fornecimentos de um produto
@author     Evandro
@since      09/06/2020
@param		ExpN1: Numero de Fornecedores a serem avaliados
			ExpC2: Codigo do Produto
@return     ExpA1: Array com os ultimos fornecimentos
@example		[1] - Codigo do Fornecedor
				[2] - Loja do Fornecedor
				[3] - Emissao da Nota Fiscal
@obs        N/A
/*/
//-------------------------------------------------------------------
Static Function aSTIUlForn(_nNumFor, _cProduto)

	Local _aArea	 := GetArea()
	Local _aAreaSD1  := SD1->(GetArea())
	Local _aUltFor	 := {}
	Local _cAliasSD1 := "ASTISELFOR"
	Local _cQuery 	 := ""
	Local _nPosFor	 := 0	
	Local _lGrava 	 := .T.

	Default _nNumFor := 0

	_cQuery := "SELECT D1_FORNECE, D1_LOJA, D1_EMISSAO "
	_cQuery += "  FROM " + RetSQLTab("SD1")
	_cQuery += " WHERE " + RetSQLFil("SD1")
	_cQuery += "   AND D1_COD = '" + _cProduto + "'"
	_cQuery += "   AND D1_TIPO = 'N'"
	_cQuery += "   AND " + RetSQLDel("SD1")
	_cQuery += "ORDER BY D1_EMISSAO DESC"

	_cQuery := ChangeQuery(_cQuery)

	DbUseArea(.T.,"TOPCONN",TcGenQry(,,_cQuery),_cAliasSD1,.T.,.T.)

	While Len(_aUltFor) < _nNumFor .And. !(_cAliasSD1)->(Eof())

		_lGrava  := .T.
		_nPosFor := aScan(_aUltFor,{|x| x[1]==(_cAliasSD1)->D1_FORNECE})

		If _nPosFor > 0  
			If  _aUltFor[_nPosFor][2]==(_cAliasSD1)->D1_LOJA
				_lGrava := .F.					
			Else
				_lGrava := .T.
			EndIf
		EndIf

		If _lGrava   
			aadd(_aUltFor,{ (_cAliasSD1)->D1_FORNECE, (_cAliasSD1)->D1_LOJA, StoD((_cAliasSD1)->D1_EMISSAO) })
		EndIf

		(_cAliasSD1)->(DbSkip())

	EndDo	

	DbSelectArea(_cAliasSD1)
	DbCloseArea()

	RestArea(_aAreaSD1)
	RestArea(_aArea)

Return _aUltFor
