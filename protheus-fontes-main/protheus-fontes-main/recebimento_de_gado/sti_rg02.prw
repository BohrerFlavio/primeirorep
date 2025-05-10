#INCLUDE "PROTHEUS.CH"
#INCLUDE "TOPCONN.CH"
#INCLUDE "RWMAKE.CH"           

/*/{Protheus.doc} STI_RG02
Rotina para gerar 'Solicitações de Compra' e 'Ordens de Recebimento' automaticamente conforme data de embarque dos romaneios de embarque
@author 	Evandro Mugnol
@since 		Set/2017
@return 	Nil, Função não tem retorno
@obs 		N/A.
/*/

User Function STI_RG02()

	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Define Variaveis                                             ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	Local nOpc		:= 0
	Local aSays		:= {}
	Local aButtons	:= {}

	Private _nRegua
	Private cPerg	 := "STI_RG02"
	Private lTMSOPdg := AliasInDic("DEG") .And. SuperGetMV("MV_TMSOPDG",,"0") == "2"
	Private lPyme	 := Iif(Type("__lPyme") <> "U",__lPyme,.F.) 
	Private lIntLox	 := GetMV("MV_QALOGIX") == "1"
	Private INCLUI 	 := .T.
	Private ALTERA   := .F.

	/*
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Verifica a existência do parâmetro, caso não tenha cria 			 	      ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	_cNomePar := "FS_CTRASC"
	DbSelectArea("SX6")
	DbSetorder(1)
	If !MsSeek(cFilAnt + _cNomePar)
		RecLock("SX6",.T.)
		SX6->X6_FIL	 	:= cFilAnt
		SX6->X6_VAR	 	:= _cNomePar
		SX6->X6_TIPO 	:= "C"
		SX6->X6_DESCRIC := "Define o codigo da transportadora default    "
		SX6->X6_DSCSPA	:= "Define o codigo da transportadora default    "
		SX6->X6_DSCENG	:= "Define o codigo da transportadora default    "
		SX6->X6_DESC1 	:= "para o cabecalho das solicitaçoes de compra  "
		SX6->X6_DSCSPA1 := "para o cabecalho das solicitaçoes de compra  "
		SX6->X6_DSCENG1 := "para o cabecalho das solicitaçoes de compra  "
		SX6->X6_DESC2 	:= "do portal do gado									  "
		SX6->X6_DSCSPA2 := "do portal do gado									  "
		SX6->X6_DSCENG2 := "do portal do gado									  "
		//SX6->X6_CONTEUD := "000130" alterado por Fabian Maurer no dia 03/02/20 por solicitação do Anthony.Paz
		SX6->X6_CONTEUD := "TRANTY"
		//SX6->X6_CONTSPA := "000130" alterado por Fabian Maurer no dia 03/02/20 por solicitação do Anthony.Paz
		SX6->X6_CONTSPA := "TRANTY"
		//SX6->X6_CONTENG := "000130" alterado por Fabian Maurer no dia 03/02/20 por solicitação do Anthony.Paz
		SX6->X6_CONTENG := "TRANTY"
		SX6->X6_PROPRI  := "U"
		SX6->(MsUnlock())
		MsUnLock()
	EndIf
	*/

	AADD(aSays, "Rotina responsável pela geração das Solicitações Compra e Ordens Recebimento")
	AADD(aSays, "automaticamente conforme a data de embarque dos romaneios                   ")
	AADD(aSays, "Para executar as informações necessárias, informe os parâmetros necessários.")

	AADD(aButtons, {1, .T., {|o| nOpc:= 1, o:oWnd:End()}})
	AADD(aButtons, {2, .T., {|o| o:oWnd:End()}})
	AADD(aButtons, {5, .T., {|o| Pergunte(cPerg, .T.)}})

	FormBatch("Geração Solicitações de Compra e Ordens de Recebimento", aSays, aButtons,,200)

	If nOpc != 0
		Pergunte(cPerg, .F.)
		Processa({|| GeraSCOR()}, "")
	Endif

Return


/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Funcao    ³ GeraSCOR  ³ Autor ³ Evandro Mugnol       ³ Data ³ Set/2017 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descricao ³ Tratamento para a utilização do tNewProcess				  ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/

Static Function GeraSCOR()

	SCORProc()

Return


/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Funcao    ³ SCORProc  ³ Autor ³ Evandro Mugnol       ³ Data ³ Set/2017 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descricao ³ Função que efetua o processamento das informações          ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/

Static Function SCORProc()

	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Calcula total de registros a serem processados corretamente ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	cQuery := "SELECT COUNT( ZAQ.R_E_C_N_O_ ) TOTREG "
	cQuery += "  FROM " + RetSQLTab("ZAQ")
	cQuery += " WHERE " + RetSQLFil("ZAQ")
	cQuery += "   AND ZAQ_DATAEM = '" + dtos(mv_par01) + "'"
	cQuery += "   AND " + RetSQLDel("ZAQ")

	cQuery := ChangeQuery(cQuery)

	dbUseArea(.T.,"TOPCONN",TcGenQry(,,cQuery),"TRBTOT",.T.,.T.)

	ProcRegua(TRBTOT->TOTREG)

	TRBTOT->( DbCloseArea() )


	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Bloco de código para chamar tela de inclusão de fornecedores que ainda não estão cadastrados na tabela SA2       ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	// Seleção dos romaneios (ZAQ)
	cQuery := "SELECT *"
	cQuery += "  FROM " + RetSQLTab("ZAQ")
	cQuery += " WHERE	" + RetSQLFil("ZAQ")
	cQuery += "   AND ZAQ_DATAEM = '" + dtos(mv_par01) + "'"
	cQuery += "   AND ZAQ_NUMSC = '      '"
	cQuery += "   AND " + RetSQLDel("ZAQ")
	cQuery += " ORDER BY ZAQ_CNPJ, ZAQ_INSCR, ZAQ_CODCOM"

	cQuery := ChangeQuery(cQuery)

	DbUseArea( .T., "TOPCONN", TCGENQRY(,,cQuery), "TRB", .F., .T.)

	TRB->(dbGoTop())
	While TRB->(!Eof())
		_cCNPJ  := PADR(AllTrim(StrTran(StrTran(StrTran(StrTran(AllTrim(TRB->ZAQ_CNPJ) ,"/",""),".",""),"-","")," ","")), TamSX3("A2_CGC")[1], " ")
		_cINSCR := PADR(AllTrim(StrTran(StrTran(StrTran(StrTran(AllTrim(TRB->ZAQ_INSCR),"/",""),".",""),"-","")," ","")), TamSX3("A2_INSCR")[1], " ")

		DbSelectArea("SA2")
		DbOrderNickName("CNPJINSCR")
		MsSeek(FWxFilial("SA2") + _cCNPJ + _cINSCR)
		If !Found()
			IncSA2()		// Chamada da função para incluir fornecedor. Função associada ao PE MA020BUT.PRW
		Endif

		TRB->(DbSkip())
	Enddo

	TRB->(DbCloseArea())


	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Processamento dos Dados                                  ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	// Seleção dos romaneios (ZAQ)
	cQuery := "SELECT ZAQ_CNPJ, ZAQ_INSCR, ZAQ_CODCOM, ZAQ_DATAEM, ZAQ_NUM, ZAQ_TPCOM, ZAQ_NGQTD AS NGQTD, ZAQ_NGPRC AS NGPRC, ZAQ_NGPRCB AS NGPRCB, ZAQ_NGPES AS NGPES,"
	cQuery += "                                                                        ZAQ_VGQTD AS VGQTD, ZAQ_VGPRC AS VGPRC, ZAQ_VGPRCB AS VGPRCB, ZAQ_VGPES AS VGPES,"
	cQuery += "                                                                        ZAQ_TGQTD AS TGQTD, ZAQ_TGPRC AS TGPRC, ZAQ_TGPRCB AS TGPRCB, ZAQ_TGPES AS TGPES,"
	cQuery += "                                                                        ZAQ_BGQTD AS BGQTD, ZAQ_BGPRC AS BGPRC, ZAQ_BGPRCB AS BGPRCB, ZAQ_BGPES AS BGPES,"
	cQuery += "                                                                        ZAQ_BAQTD AS BAQTD, ZAQ_BAPRC AS BAPRC, ZAQ_BAPRCB AS BAPRCB, ZAQ_BAPES AS BAPES"
	cQuery += "  FROM " + RetSQLTab("ZAQ")
	cQuery += " WHERE " + RetSQLFil("ZAQ")
	cQuery += "   AND ZAQ_DATAEM = '" + dtos(mv_par01) + "'"
	cQuery += "   AND ZAQ_NUMSC = '      '"
	cQuery += "   AND " + RetSQLDel("ZAQ")
	cQuery += " ORDER BY ZAQ_CNPJ, ZAQ_INSCR, ZAQ_CODCOM"

	cQuery := ChangeQuery(cQuery)

	DbUseArea( .T., "TOPCONN", TCGENQRY(,,cQuery), "TRB", .F., .T.)

	_zCNPJ     := "##############"
	_zINSCR    := "##########"
	_cSCIni    := ""
	_cSCFim    := ""
	_dAbateIni := Ctod("")
	_dAbateFim := Ctod("")
	_nRegua    := 0
	_dEmbarque := Ctod("")
	_cNumerSC  := ""
	_dDtAbate  := Ctod("")

	TRB->(dbGoTop())
	While TRB->(!Eof())
		_cCNPJ    := PADR(AllTrim(StrTran(StrTran(StrTran(StrTran(AllTrim(TRB->ZAQ_CNPJ) ,"/",""),".",""),"-","")," ","")), TamSX3("A2_CGC")[1], " ")
		_cINSCR   := PADR(AllTrim(StrTran(StrTran(StrTran(StrTran(AllTrim(TRB->ZAQ_INSCR),"/",""),".",""),"-","")," ","")), TamSX3("A2_INSCR")[1], " ")
		_cNumRoma := TRB->ZAQ_NUM

		IncProc()

		_cCodiFor := ""
		_cLojaFor := ""
		_cNomeFor := ""

		DbSelectArea("SA2")
		DbOrderNickName("CNPJINSCR")
		MsSeek(FWxFilial("SA2") + _cCNPJ + _cINSCR)
		While !Eof() .And. SA2->A2_FILIAL + SA2->A2_CGC + SA2->A2_INSCR == FWxFilial("SA2") + _cCNPJ + _cINSCR 
			If SA2->A2_MSBLQL == "2"
				_cCodiFor := SA2->A2_COD
				_cLojaFor := SA2->A2_LOJA
				_cNomeFor := SA2->A2_NOME
				Exit
			Endif
			DbSelectArea("SA2")
			DbSkip()
		Enddo

		DbSelectArea("TRB")

		/*
		DbSelectArea("SA2")
		DbOrderNickName("CNPJINSCR")
		If MsSeek(FWxFilial("SA2") + _cCNPJ + _cINSCR)
		_cCodiFor := SA2->A2_COD
		_cLojaFor := SA2->A2_LOJA
		_cNomeFor := SA2->A2_NOME
		Else
		_cCodiFor := ""
		_cLojaFor := ""
		_cNomeFor := ""
		Endif
		*/

		If Empty(_cCodiFor) .Or. Empty(_cLojaFor)
			MsgAlert("Não foi encontrado fornecedor cadastrado para o CNPJ / Inscrição " + _cCNPJ + " / " + _cINSCR + " referente ao Romaneio " + _cNumRoma + ". " + ;
			"Não Será gerado Solicitação de Compra e Ordem de Recebimento para o referido Romaneio. Verifique!")
			TRB->(DbSkip())
			Loop
		Endif

		_nQtde    := 0
		_nValor   := 0
		//If _zCNPJ + _zINSCR <> _cCNPJ + _cINSCR
			_cNumerSC := GetSxeNum("SZA", "ZA_NUMERO")
			If Empty(_cSCIni)
				_cSCIni := _cNumerSC					  				// Guarda número da solicitação de compra inicial para geração das ordens de recebimento
				_dAbateIni := Stod(TRB->ZAQ_DATAEM) + 1		// Guarda data do abate da solicitação de compra inicial para geração das ordens de recebimento
				_dEmbarque := Stod(TRB->ZAQ_DATAEM)
			Endif
			//_zCNPJ  := _cCNPJ
			//_zINSCR := _cINSCR
		//Endif

		// QUANTIDADES
		_nNGQTD := TRB->NGQTD	 	// Novilhos -> código 000230 (boi)
		_nVGQTD := TRB->VGQTD		// Vacas    -> código 000231 (vaca)
		_nTGQTD := TRB->TGQTD		// Touros   -> código 001075 (touro)
		_nBGQTD := TRB->BGQTD		// Búfalos  -> código 001073 (bufalo)
		_nBAQTD := TRB->BAQTD		// Búfalas  -> código 001074 (bufala)

		// PREÇOS
		_nNGPRC := TRB->NGPRC
		_nVGPRC := TRB->VGPRC
		_nTGPRC := TRB->TGPRC
		_nBGPRC := TRB->BGPRC
		_nBAPRC := TRB->BAPRC

		// PREÇOS BONUS
		_nNGPRCB := TRB->NGPRCB
		_nVGPRCB := TRB->VGPRCB
		_nTGPRCB := TRB->TGPRCB
		_nBGPRCB := TRB->BGPRCB
		_nBAPRCB := TRB->BAPRCB

		// PESOS
		_nNGPES := TRB->NGPES
		_nVGPES := TRB->VGPES
		_nTGPES := TRB->TGPES
		_nBGPES := TRB->BGPES
		_nBAPES := TRB->BAPES

		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³Grava SZA (inclusão do cabeçalho solicitação de compra)       ³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		DbSelectArea("SZA")
		DbSetOrder(1)
		MsSeek(FWxFilial("SZA") + _cNumerSC)
		If !Found()
			RecLock("SZA",.T.)
			SZA->ZA_FILIAL  := FWxFilial("SZA")
			SZA->ZA_NUMERO  := _cNumerSC
			SZA->ZA_EMISSAO := DDATABASE
			SZA->ZA_ABATE   := Stod(TRB->ZAQ_DATAEM) + 1			// Sempre 1 dia posterior a data de embarque do romaneio conforme passado por Leonardo
			SZA->ZA_CODFOR  := _cCodiFor
			SZA->ZA_LOJA    := _cLojaFor
			SZA->ZA_INSCR   := _cINSCR
			SZA->ZA_COMPRA  := TRB->ZAQ_CODCOM
			SZA->ZA_CODTRA  := _GetParam()
			SZA->ZA_TPCOM   := TRB->ZAQ_TPCOM						// "R" - Retirado para usar do cadastro de romaneios
			SZA->ZA_PROGRA  := 0
			SZA->ZA_FPAG    := "3"
			SZA->ZA_CONDPG  := "009"
			MsUnlock()

			// Grava número da SC no romaneio
			DbSelectArea("ZAQ")
			DbSetOrder(1)
			MsSeek(FWxFilial("ZAQ") + _cNumRoma)
			If Found()
				RecLock("ZAQ",.F.)
				ZAQ->ZAQ_NUMSC := _cNumerSC
				MsUnlock()
			Endif
		Endif

		_cItem := "000"

		If _nNGQTD > 0			// Novilho (Boi)
			_cItem := Soma1(_cItem)
			_cProd := "000230"
			/*DbSelectArea("SZ9")
			DbSetOrder(5)
			MsSeek(FWxFilial("SZ9") + _cNumerSC + _cProd)
			If Found()
				RecLock("SZ9",.F.)
				SZ9->Z9_QUANT += _nNGQTD
				SZ9->Z9_PESO  += _nNGPES
			Else*/
				RecLock("SZ9",.T.)
				SZ9->Z9_FILIAL  := FWxFilial("SZ9")
				SZ9->Z9_NUMERO  := _cNumerSC
				SZ9->Z9_ITEM    := _cItem
				SZ9->Z9_RASTRO  := "N"
				SZ9->Z9_PRODUTO := _cProd
				SZ9->Z9_UM      := "CB"
				SZ9->Z9_QUANT   := _nNGQTD
				SZ9->Z9_PRECO   := _nNGPRC
				SZ9->Z9_PESO    := _nNGPES
				SZ9->Z9_FORNECE := _cCodiFor
				SZ9->Z9_LOJA    := _cLojaFor
				SZ9->Z9_NOMFOR  := _cNomeFor
				SZ9->Z9_DATA    := Stod(TRB->ZAQ_DATAEM) + 1			// Sempre 1 dia posterior a data de embarque do romaneio conforme passado por Leonardo
				SZ9->Z9_PRECOBN := _nNGPRCB		 					// Preço Bonus informado no romaneio
				SZ9->Z9_CATEG   := GetAdvFval("SZ5", "Z5_COD", FWxFilial("SZ5") + _cProd, 3)
			//Endif
			MsUnlock()

			// Grava item da SC no romaneio para Novilhos Gordos
			DbSelectArea("ZAQ")
			DbSetOrder(1)
			MsSeek(FWxFilial("ZAQ") + _cNumRoma)
			If Found()
				RecLock("ZAQ",.F.)
				ZAQ->ZAQ_NGITSC := _cItem
				MsUnlock()
			Endif

			// Acumula totais para gravar no cabeçalho da solicitação
			_nQtde += _nNGQTD

			If SZA->ZA_TPCOM == "R"
				_nRend  := GetAdvFVal("SZ5", "Z5_REND", FWxFilial("SZ5") + SZ9->Z9_CATEG, 1)
				_nRend  := If(Empty(_nRend),100, _nRend) 			// Caso a categoria não tenha sido definida
				_nValor += (_nNGQTD * _nNGPRC) * (_nNGPES * (_nRend / 100))
			Else
				_nValor += _nNGQTD * _nNGPRC * _nNGPES
			Endif
		Endif

		If _nVGQTD > 0			// Vaca
			_cItem := Soma1(_cItem)
			_cProd := "000231"
			/*DbSelectArea("SZ9")
			DbSetOrder(5)
			MsSeek(FWxFilial("SZ9") + _cNumerSC + _cProd)
			If Found()
				RecLock("SZ9",.F.)
				SZ9->Z9_QUANT += _nVGQTD
				SZ9->Z9_PESO  += _nVGPES
			Else*/
				RecLock("SZ9",.T.)
				SZ9->Z9_FILIAL  := FWxFilial("SZ9")
				SZ9->Z9_NUMERO  := _cNumerSC
				SZ9->Z9_ITEM    := _cItem
				SZ9->Z9_RASTRO  := "N"
				SZ9->Z9_PRODUTO := _cProd
				SZ9->Z9_UM      := "CB"
				SZ9->Z9_QUANT 	:= _nVGQTD
				SZ9->Z9_PRECO   := _nVGPRC
				SZ9->Z9_PESO  	:= _nVGPES
				SZ9->Z9_FORNECE := _cCodiFor
				SZ9->Z9_LOJA    := _cLojaFor
				SZ9->Z9_NOMFOR  := _cNomeFor
				SZ9->Z9_DATA    := Stod(TRB->ZAQ_DATAEM) + 1			// Sempre 1 dia posterior a data de embarque do romaneio conforme passado por Leonardo
				SZ9->Z9_PRECOBN := _nVGPRCB								// Preço Bonus informado no romaneio
				SZ9->Z9_CATEG   := GetAdvFval("SZ5", "Z5_COD", FWxFilial("SZ5") + _cProd, 3)
			//Endif
			MsUnlock()

			// Grava item da SC no romaneio para Vacas Gordas
			DbSelectArea("ZAQ")
			DbSetOrder(1)
			MsSeek(FWxFilial("ZAQ") + _cNumRoma)
			If Found()
				RecLock("ZAQ",.F.)
				ZAQ->ZAQ_VGITSC := _cItem
				MsUnlock()
			Endif

			// Acumula totais para gravar no cabeçalho da solicitação
			_nQtde += _nVGQTD

			If SZA->ZA_TPCOM == "R"
				_nRend  := GetAdvFVal("SZ5", "Z5_REND", FWxFilial("SZ5") + SZ9->Z9_CATEG, 1)
				_nRend  := If(Empty(_nRend),100, _nRend) 			// Caso a categoria não tenha sido definida
				_nValor += (_nVGQTD * _nVGPRC) * (_nVGPES * (_nRend / 100))
			Else
				_nValor += _nVGQTD * _nVGPRC * _nVGPES
			Endif
		Endif

		If _nTGQTD > 0 		// Touro
			_cItem := Soma1(_cItem)
			_cProd := "001075"
			/*DbSelectArea("SZ9")
			DbSetOrder(5)
			MsSeek(FWxFilial("SZ9") + _cNumerSC + _cProd)
			If Found()
				RecLock("SZ9",.F.)
				SZ9->Z9_QUANT += _nTGQTD
				SZ9->Z9_PESO  += _nTGPES
			Else*/
				RecLock("SZ9",.T.)
				SZ9->Z9_FILIAL  := FWxFilial("SZ9")
				SZ9->Z9_NUMERO  := _cNumerSC
				SZ9->Z9_ITEM    := _cItem
				SZ9->Z9_RASTRO  := "N"
				SZ9->Z9_PRODUTO := _cProd
				SZ9->Z9_UM      := "CB"
				SZ9->Z9_QUANT 	:= _nTGQTD
				SZ9->Z9_PRECO   := _nTGPRC
				SZ9->Z9_PESO  	:= _nTGPES
				SZ9->Z9_FORNECE := _cCodiFor
				SZ9->Z9_LOJA    := _cLojaFor
				SZ9->Z9_NOMFOR  := _cNomeFor
				SZ9->Z9_DATA    := Stod(TRB->ZAQ_DATAEM) + 1			// Sempre 1 dia posterior a data de embarque do romaneio conforme passado por Leonardo
				SZ9->Z9_PRECOBN := _nTGPRCB								// Preço Bonus informado no romaneio
				SZ9->Z9_CATEG   := GetAdvFval("SZ5", "Z5_COD", FWxFilial("SZ5") + _cProd, 3)
			//Endif
			MsUnlock()

			// Grava item da SC no romaneio para Touros Gordos
			DbSelectArea("ZAQ")
			DbSetOrder(1)
			MsSeek(FWxFilial("ZAQ") + _cNumRoma)
			If Found()
				RecLock("ZAQ",.F.)
				ZAQ->ZAQ_TGITSC := _cItem
				MsUnlock()
			Endif

			// Acumula totais para gravar no cabeçalho da solicitação
			_nQtde += _nTGQTD

			If SZA->ZA_TPCOM == "R"
				_nRend  := GetAdvFVal("SZ5", "Z5_REND", FWxFilial("SZ5") + SZ9->Z9_CATEG, 1)
				_nRend  := If(Empty(_nRend),100, _nRend) 			// Caso a categoria não tenha sido definida
				_nValor += (_nTGQTD * _nTGPRC) * (_nTGPES * (_nRend / 100))
			Else
				_nValor += _nTGQTD * _nTGPRC * _nTGPES
			Endif
		Endif

		If _nBGQTD > 0			// Búfalo
			_cItem := Soma1(_cItem)
			_cProd := "001073"
			/*DbSelectArea("SZ9")
			DbSetOrder(5)
			MsSeek(FWxFilial("SZ9") + _cNumerSC + _cProd)
			If Found()
				RecLock("SZ9",.F.)
				SZ9->Z9_QUANT += _nBGQTD
				SZ9->Z9_PESO  += _nBGPES
			Else*/
				RecLock("SZ9",.T.)
				SZ9->Z9_FILIAL  := FWxFilial("SZ9")
				SZ9->Z9_NUMERO  := _cNumerSC
				SZ9->Z9_ITEM    := _cItem
				SZ9->Z9_RASTRO  := "N"
				SZ9->Z9_PRODUTO := _cProd
				SZ9->Z9_UM      := "CB"
				SZ9->Z9_QUANT 	:= _nBGQTD
				SZ9->Z9_PRECO   := _nBGPRC
				SZ9->Z9_PESO  	:= _nBGPES
				SZ9->Z9_FORNECE := _cCodiFor
				SZ9->Z9_LOJA    := _cLojaFor
				SZ9->Z9_NOMFOR  := _cNomeFor
				SZ9->Z9_DATA    := Stod(TRB->ZAQ_DATAEM) + 1			// Sempre 1 dia posterior a data de embarque do romaneio conforme passado por Leonardo
				SZ9->Z9_PRECOBN := _nBGPRCB								// Preço Bonus informado no romaneio
				SZ9->Z9_CATEG   := GetAdvFval("SZ5", "Z5_COD", FWxFilial("SZ5") + _cProd, 3)
			//Endif
			MsUnlock()

			// Grava item da SC no romaneio para Búfalos Gordos
			DbSelectArea("ZAQ")
			DbSetOrder(1)
			MsSeek(FWxFilial("ZAQ") + _cNumRoma)
			If Found()
				RecLock("ZAQ",.F.)
				ZAQ->ZAQ_BGITSC := _cItem
				MsUnlock()
			Endif

			// Acumula totais para gravar no cabeçalho da solicitação
			_nQtde += _nBGQTD

			If SZA->ZA_TPCOM == "R"
				_nRend  := GetAdvFVal("SZ5", "Z5_REND", FWxFilial("SZ5") + SZ9->Z9_CATEG, 1)
				_nRend  := If(Empty(_nRend),100, _nRend) 			// Caso a categoria não tenha sido definida
				_nValor += (_nBGQTD * _nBGPRC) * (_nBGPES * (_nRend / 100))
			Else
				_nValor += _nBGQTD * _nBGPRC * _nBGPES
			Endif
		Endif

		If _nBAQTD > 0			// Búfala
			_cItem := Soma1(_cItem)
			_cProd := "001074"
			/*DbSelectArea("SZ9")
			DbSetOrder(5)
			MsSeek(FWxFilial("SZ9") + _cNumerSC + _cProd)
			If Found()
				RecLock("SZ9",.F.)
				SZ9->Z9_QUANT += _nBAQTD
				SZ9->Z9_PESO  += _nBAPES
			Else*/
				RecLock("SZ9",.T.)
				SZ9->Z9_FILIAL  := FWxFilial("SZ9")
				SZ9->Z9_NUMERO  := _cNumerSC
				SZ9->Z9_ITEM    := _cItem
				SZ9->Z9_RASTRO  := "N"
				SZ9->Z9_PRODUTO := _cProd
				SZ9->Z9_UM      := "CB"
				SZ9->Z9_QUANT 	:= _nBAQTD
				SZ9->Z9_PRECO   := _nBAPRC
				SZ9->Z9_PESO  	:= _nBAPES
				SZ9->Z9_FORNECE := _cCodiFor
				SZ9->Z9_LOJA    := _cLojaFor
				SZ9->Z9_NOMFOR  := _cNomeFor
				SZ9->Z9_DATA    := Stod(TRB->ZAQ_DATAEM) + 1			// Sempre 1 dia posterior a data de embarque do romaneio conforme passado por Leonardo
				SZ9->Z9_PRECOBN := _nBAPRCB								// Preço Bonus informado no romaneio
				SZ9->Z9_CATEG   := GetAdvFval("SZ5", "Z5_COD", FWxFilial("SZ5") + _cProd, 3)
			//Endif
			MsUnlock()

			// Grava item da SC no romaneio para Búfalas Gordas
			DbSelectArea("ZAQ")
			DbSetOrder(1)
			MsSeek(FWxFilial("ZAQ") + _cNumRoma)
			If Found()
				RecLock("ZAQ",.F.)
				ZAQ->ZAQ_BAITSC := _cItem
				MsUnlock()
			Endif

			// Acumula totais para gravar no cabeçalho da solicitação
			_nQtde += _nBAQTD

			If SZA->ZA_TPCOM == "R"
				_nRend  := GetAdvFVal("SZ5", "Z5_REND", FWxFilial("SZ5") + SZ9->Z9_CATEG, 1)
				_nRend  := If(Empty(_nRend),100, _nRend) 			// Caso a categoria não tenha sido definida
				_nValor += (_nBAQTD * _nBAPRC) * (_nBAPES * (_nRend / 100))
			Else
				_nValor += _nBAQTD * _nBAPRC * _nBAPES
			Endif
		Endif

		// Guarda data de abate para ser usado nos parâmetros de geração das ordens de recebimento
		_dDtAbate := Stod(TRB->ZAQ_DATAEM) + 1

		// Atualiza Dados do Cabeçalho da Solicitação de Compra
		DbSelectArea("SZA")
		RecLock("SZA",.F.)
		SZA->ZA_TOTALQT := _nQtde
		SZA->ZA_VALTOT  := _nValor
		MsUnlock()

		ConfirmSX8()

		_nRegua ++

		TRB->(DbSkip())
	Enddo

	_cSCFim 	:= _cNumerSC		// Guarda número da solicitação de compra final para geração das ordens de recebimento
	_dAbateFim 	:= _dDtAbate		// Guarda data do abate da solicitação de compra final para geração das ordens de recebimento

	TRB->(DbCloseArea())

	// Chama rotina de geração das ordens de recebimento referente solicitações de compra geradas
	Processa( {|| _GeraOR(_cSCIni,_cSCFim,_dAbateIni,_dAbateFim,_nRegua,_dEmbarque) }, "Aguarde...", "Gerando Ordens de Recebimento...",.F.)

Return


/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Funcao    ³ _GeraOR   ³ Autor ³ Evandro Mugnol       ³ Data ³ Set/2017 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descricao ³ Função que efetua a geração das ordens de recebimento      ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Static Function _GeraOR(_cSCIni,_cSCFim,_dAbateIni,_dAbateFim,_nRegua,_dEmbarque)            

	Local ix
	ProcRegua(_nRegua)

	BEGIN TRANSACTION

		SZA->(DbSetOrder(1))
		SZA->(MsSeek(FWxFilial("SZA") + _cSCIni)) 
		While !SZA->(Eof()) .And. SZA->ZA_FILIAL == FWxFilial("SZA") .And. SZA->ZA_NUMERO <= _cSCFim
			_FornLoja := SZA->ZA_CODFOR+SZA->ZA_LOJA
			SA2->(DbSetOrder(1))
			SA2->(MsSeek(FWxFilial("SA2") + _FornLoja))

			_cNumerOR := GetSxeNum("SZD", "ZD_NUMERO")
			_Item     := "000"
			_nAnimais := 0
			_mObs 	  := ''
			_dRecebto := _dEmbarque

			//While !SZA->(Eof()) .And. SZA->ZA_FILIAL == FWxFilial("SZA") .And. SZA->ZA_NUMERO <= _cSCFim  .And. SZA->ZA_CODFOR + SZA->ZA_LOJA == _FornLoja
				If SZA->ZA_ABATE < _dAbateIni .Or. SZA->ZA_ABATE > _dAbateFim
					SZA->(DbSkip())
					Loop
				Endif

				// Verifica se para esta SC não foi gravado a ordem de recebimento
				If !Empty(SZA->ZA_ORDREC)
					SZA->(DbSkip())
					Loop
				Endif

				// Percorre os itens da SC
				_mObs += SZA->ZA_OBS
				SZ9->(DbSetOrder(1))
				SZ9->(MsSeek(FWxFilial("SZ9") + SZA->ZA_NUMERO))
				While !SZ9->(Eof()) .And. SZ9->Z9_FILIAL + SZ9->Z9_NUMERO == FWxFilial("SZ9") + SZA->ZA_NUMERO

					// Grava itens (caso rastreado, abre para cada qtde. unitaria)
					qtos := IIF(SZ9->Z9_RASTRO <> "S", 1, SZ9->Z9_QUANT)

					For ix := 1 To qtos
						DbSelectArea("SZE")
						RecLock("SZE",.T.)
						SZE->ZE_FILIAL     := FWxFilial("SZE")
						SZE->ZE_NUMERO     := _cNumerOR
						SZE->ZE_ITEM       := Soma1(_Item)
						SZE->ZE_PRODUTO    := SZ9->Z9_PRODUTO
						SZE->ZE_DESCRI     := GetAdvFval("SB1", "B1_DESC", FWxFilial("SB1") + SZ9->Z9_PRODUTO, 1)
						SZE->ZE_QTD1UM     := IIF(SZ9->Z9_RASTRO == "S", 1, SZ9->Z9_QUANT)
						SZE->ZE_UM         := SZ9->Z9_UM
						SZE->ZE_SEGUM      := "KG"
						SZE->ZE_LOCAL      := SZ9->Z9_LOCAL
						SZE->ZE_CATEG      := SZ9->Z9_CATEG
						SZE->ZE_RACA       := SZ9->Z9_RACA
						SZE->ZE_NUMSC      := SZ9->Z9_NUMERO
						SZE->ZE_ITEMSC     := SZ9->Z9_ITEM
						SZE->ZE_TPCOM      := SZA->ZA_TPCOM
						SZE->ZE_OBS        := "0"  				// 0=Ok ; 1=S/Brinco ; 2=Brinco Errado ; 3=Sexo Errado ; 4=Idade ; 5=Propriedade ; 6=Localidade
						SZE->ZE_PROGRAM    := SZ9->Z9_PROGRAM
						MsUnlock()

						_Item := Soma1(_Item)
						_nAnimais += IIF(SZ9->Z9_RASTRO == "S", 1, SZ9->Z9_QUANT)
					Next

					// Atualiza a qtde entregue da SC
					DbSelectArea("SZ9")
					RecLock("SZ9",.F.)
					SZ9->Z9_QTDENT := SZ9->Z9_QUANT
					MsUnlock()

					SZ9->(DbSkip())
				Enddo

				// Atualizao o numero da ordem de recebimento na SC
				DbSelectArea("SZA")
				RecLock("SZA",.F.)
				SZA->ZA_ORDREC := _cNumerOR
				MsUnlock()

				//SZA->(DbSkip())
			//Enddo

			// Grava cabecalho da ordem de recebimento
			DbSelectArea("SZD")
			RecLock("SZD",.T.)
			SZD->ZD_FILIAL  := FWxFilial("SZD")
			SZD->ZD_NUMERO  := _cNumerOR
			SZD->ZD_FORNECE := SA2->A2_COD
			SZD->ZD_LOJA    := SA2->A2_LOJA
			SZD->ZD_DATA    := _dRecebto
			SZD->ZD_HORA    := "00:00"
			SZD->ZD_MUN     := SA2->A2_MUN
			SZD->ZD_TRANSP  := _GetParam()
			SZD->ZD_QTDTOT  := _nAnimais
			SZD->ZD_OBSC    := _mObs
			SZD->ZD_TRACE   := GetAdvFval("SA2", "A2_TRACE", FWxFilial("SA2") + SA2->A2_COD + SA2->A2_LOJA, 1)
			MsUnlock()

			ConfirmSx8()

			SZA->(DbSkip())
		Enddo

	END TRANSACTION

Return


/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Funcao    ³ IncSA2    ³ Autor ³ Evandro Mugnol       ³ Data ³ Set/2017 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descricao ³ Função para abrir a inclusão de fornecedores.              ³±±
±±³          ³ A rotina inicializa as variáveis privates excênciais para  ³±±
±±³          ³ a abertura da rotina A020Inclui.                           ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Static Function IncSA2()

	Private aParam    := {}
	Private aRotAuto  := Nil
	Private cCadastro := OemtoAnsi("Fornecedores")

	A020Inclui("SA2",,3)

Return


Static Function _GetParam()

	_cRet := GetMv("FS_CTRASC")

Return(_cRet)

