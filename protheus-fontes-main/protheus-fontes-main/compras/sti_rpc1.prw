#INCLUDE "PROTHEUS.CH"
#INCLUDE "RWMAKE.CH"
#INCLUDE "TOPCONN.CH"                           

Static nPAJ_MSBLQL := SAJ->(FieldPos("AJ_MSBLQL"))

/*/{Protheus.doc} STI_RPC1
Relatório de rastreabilidade de pedidos de compra.
@author 	Evandro Mugnol
@since 		Abr/2023
@return 	Nil, Função não tem retorno
@obs 		N/A
/*/

User Function STI_RPC1()

	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Declaracao de Variaveis                                             ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ

	Local cDesc1         := "Este programa tem como objetivo imprimir um relatório"
	Local cDesc2         := "para conferência de rastreabilidade de pedidos de compra."
	Local cDesc3         := ""
	Local titulo         := "RASTREABILIDADE DE PEDIDOS"
	Local aOrd           := {}
	Private nlin         := 80
	Private lEnd         := .F.
	Private lAbortPrint  := .F.
	Private CbTxt        := ""
	Private limite       := 132
	Private tamanho      := "M"
	Private nomeprog     := "STI_RPC1" // Coloque aqui o nome do programa para impressao no cabecalho
	Private nTipo        := 18
	Private aReturn      := { "Zebrado", 1, "Administracao", 2, 2, 1, "", 1}
	Private nLastKey     := 0
	Private cPerg   	 := "STI_RPC1"
	Private cbcont     	 := 00
	Private CONTFL    	 := 01
	Private m_pag      	 := 01
	Private wnrel      	 := "STI_RPC1" // Coloque aqui o nome do arquivo usado para impressao em disco

	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Perguntas no Arquivo SX1                                     ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	Pergunte(cPerg,.F.)

	_cNomArq := "RASTREABILIDADE_PC_DE_" + SUBSTR(DTOS(MV_PAR02),7,2) + SUBSTR(DTOS(MV_PAR02),5,2) + SUBSTR(DTOS(MV_PAR02),3,2)+ "_ATE_" + SUBSTR(DTOS(MV_PAR03),7,2) + SUBSTR(DTOS(MV_PAR03),5,2) + SUBSTR(DTOS(MV_PAR03),3,2)
	_aCabec	 := {}
	_aDados	 := {}

	wnrel := SetPrint('SC7',NomeProg,cPerg,@titulo,cDesc1,cDesc2,cDesc3,.T.,aOrd,.T.,Tamanho,,.T.)

	If nLastKey == 27
		Return
	Endif

	SetDefault(aReturn,'SC7')

	MsAguarde({|lFim| ProcExcel()},"Rastreabilidade de Pedidos de Compra","Aguarde Processando as Informações Solicitadas...")

Return


//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Chamada da função ProcExcel()                            ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
Static Function ProcExcel()

	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Seleção de dados                                         ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	cQuery := "SELECT C7_USER, C7_TIPO, C7_APROV, C7_CONAPRO, C7_GRUPCOM, C7_NUMSC, C7_ITEMSC, C7_NUMCOT, C7_NUM, C7_ITEM, C7_FORNECE, C7_LOJA, A2_NOME, C7_PRODUTO, C7_DESCRI, C7_GRUPO, C7_EMISSAO, CR_DATALIB, C1_DATPRF, C7_DATPRF, C7_RESIDUO" 
	cQuery += " FROM " + RetSqlTab("SC7")
	cQuery += " INNER JOIN " + RetSqlTab("SA2") + " ON A2_FILIAL = '" + FWxFilial("SA2") + "' AND A2_COD = C7_FORNECE AND A2_LOJA = C7_LOJA AND " + RetSQLDel("SA2")
	cQuery += "	LEFT JOIN " + RetSQLTab("SC1") + " ON C7_FILIAL = C1_FILIAL AND C7_NUMSC = C1_NUM AND C7_ITEMSC = C1_ITEM AND " + RetSQLDel("SC1")
	cQuery += "	LEFT JOIN " + RetSQLTab("SCR") + " ON CR_FILIAL = C7_FILIAL AND CR_NUM = C7_NUM  AND CR_DATALIB <> '' AND CR_LIBAPRO <> '' AND CR_VALLIB > 0 AND " + RetSQLDel("SCR")
	cQuery += " WHERE " + RetSqlFil("SC7") 
	If MV_PAR01 == 1
		cQuery += " AND C7_EMISSAO BETWEEN '" + DTOS(MV_PAR02) + "' AND '" + DTOS(MV_PAR03) + "'"
	Else
		cQuery += " AND C7_DATPRF BETWEEN '" + DTOS(MV_PAR02) + "' AND '" + DTOS(MV_PAR03) + "'"
	EndIf
	cQuery += " AND C7_FORNECE BETWEEN '" + MV_PAR04 + "' AND '" + MV_PAR05 + "'"
	cQuery += " AND C7_PRODUTO BETWEEN '" + MV_PAR06 + "' AND '" + MV_PAR07 + "'"
	cQuery += " AND C7_USER BETWEEN '" + MV_PAR08 + "' AND '" + MV_PAR09 + "'"
	if !empty(MV_PAR10) .or. !empty(MV_PAR11)
		cQuery += " AND C7_NUM BETWEEN '" + MV_PAR10 + "' AND '" + MV_PAR11 + "'"
	endif
	if MV_PAR12 = 2
		cQuery += " AND ((C7_QUANT-C7_QUJE) > 0)"
		cQuery += " AND C7_RESIDUO = ''"
	elseif MV_PAR12 = 3
		cQuery += " AND C7_RESIDUO <> ''"
	elseif MV_PAR12 = 4
		cQuery += " AND C7_QUANT <= C7_QUJE"
	elseif MV_PAR12 = 5
		cQuery += " AND C7_CONAPRO = 'B'"
	endif
	cQuery += " AND " + RetSqlDel("SC7")
	cQuery += " ORDER BY C7_FILIAL, C7_NUM"

	cQuery := ChangeQuery(cQuery)

	If Select("TRB") != 0
		TRB -> (DbCloseArea())
	Endif

	TCQUERY cQuery NEW ALIAS "TRB"

	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Carrega Array para Excel                                 ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	cFilSCR	:= FWxFilial("SCR")
	cFilSAJ	:= FWxFilial("SAJ")	

	DbSelectArea("TRB")
	DbGoTop()
	Do While !TRB -> (Eof ())

		_dEmissao := GetAdvFVal("SD1", "D1_EMISSAO", FWxFilial("SD1") + TRB->C7_NUM + TRB->C7_ITEM, 22, Space(TamSx3("D1_EMISSAO")[1]), .T.) 
		_dEntrega := GetAdvFVal("SD1", "D1_DTDIGIT", FWxFilial("SD1") + TRB->C7_NUM + TRB->C7_ITEM, 22, Space(TamSx3("D1_DTDIGIT")[1]), .T.) 

		_cNumNF   := GetAdvFVal("SD1", "D1_DOC"	   , FWxFilial("SD1") + TRB->C7_NUM + TRB->C7_ITEM, 22, Space(TamSx3("D1_DOC")[1]), .T.) 
		_cSerNF   := GetAdvFVal("SD1", "D1_SERIE"  , FWxFilial("SD1") + TRB->C7_NUM + TRB->C7_ITEM, 22, Space(TamSx3("D1_SERIE")[1]), .T.) 
		_cFornec  := GetAdvFVal("SD1", "D1_FORNECE", FWxFilial("SD1") + TRB->C7_NUM + TRB->C7_ITEM, 22, Space(TamSx3("D1_FORNECE")[1]), .T.) 
		_cLoja    := GetAdvFVal("SD1", "D1_LOJA"   , FWxFilial("SD1") + TRB->C7_NUM + TRB->C7_ITEM, 22, Space(TamSx3("D1_LOJA")[1]), .T.) 
		_cProdNF  := GetAdvFVal("SD1", "D1_COD"	   , FWxFilial("SD1") + TRB->C7_NUM + TRB->C7_ITEM, 22, Space(TamSx3("D1_COD")[1]), .T.) 
		_cItemNF  := GetAdvFVal("SD1", "D1_ITEM"   , FWxFilial("SD1") + TRB->C7_NUM + TRB->C7_ITEM, 22, Space(TamSx3("D1_ITEM")[1]), .T.) 

		_cCodTran := GetAdvFVal("SF8", "F8_TRANSP" , FWxFilial("SF8") + _cNumNF + _cSerNF + _cFornec + _cLoja,  2, Space(TamSx3("F8_TRANSP")[1]), .T.) 
		_cLojTran := GetAdvFVal("SF8", "F8_LOJTRAN", FWxFilial("SF8") + _cNumNF + _cSerNF + _cFornec + _cLoja,  2, Space(TamSx3("F8_LOJTRAN")[1]), .T.) 
		_cNomTran := GetAdvFVal("SA2", "A2_NOME"   , FWxFilial("SA2") + _cCodTran + _cLojTran				 ,  1, Space(TamSx3("A2_NOME")[1]), .T.) 
		_cNFDiFre := GetAdvFVal("SF8", "F8_NFDIFRE", FWxFilial("SF8") + _cNumNF + _cSerNF + _cFornec + _cLoja,  2, Space(TamSx3("F8_NFDIFRE")[1]), .T.) 
		_cSEDiFre := GetAdvFVal("SF8", "F8_SEDIFRE", FWxFilial("SF8") + _cNumNF + _cSerNF + _cFornec + _cLoja,  2, Space(TamSx3("F8_SEDIFRE")[1]), .T.) 

		_nVlFrete := GetAdvFVal("SD1", "D1_TOTAL"  , FWxFilial("SD1") + _cNFDiFre + _cSEDiFre + _cCodTran + _cLojTran + _cProdNF + _cItemNF,  1, Space(TamSx3("D1_TOTAL")[1]), .T.) 

		_dRecebto := GetAdvFVal("SF1", "F1_RECBMTO", FWxFilial("SF1") + _cNumNF + _cSerNF + _cFornec + _cLoja,  1, Space(TamSx3("F1_RECBMTO")[1]), .T.)		// Data Recebimento do Documento de Entrada
		_dDigitac := GetAdvFVal("SF1", "F1_DTDIGIT", FWxFilial("SF1") + _cNumNF + _cSerNF + _cFornec + _cLoja,  1, Space(TamSx3("F1_DTDIGIT")[1]), .T.)		// Data Classificacao do Documento de Entrada
		_dContabi := GetAdvFVal("SF1", "F1_DTLANC" , FWxFilial("SF1") + _cNumNF + _cSerNF + _cFornec + _cLoja,  1, Space(TamSx3("F1_DTLANC")[1]), .T.)		// Data Contabilizacao do Documento de Entrada

		//If !Empty(_dEntrega) .And. !Empty(STOD(TRB->C1_DATPRF))
		If !Empty(_dRecebto) .And. !Empty(STOD(TRB->C1_DATPRF))
			_nDiasAtr := _dRecebto - STOD(TRB->C1_DATPRF)
		Else
			_nDiasAtr := 0
		EndIf

		// Tratamento para pedidos bloqueados
		cComprador := ""
		cAlter	   := ""
		cAprov	   := ""
		lNewAlc	   := .F.
		lLiber 	   := .F.
		lRejeit	   := .F.

		// Incluida validação para os pedidos de compras por item do pedido  (IP/alçada)
		cTipoSC7 := IIF((TRB->C7_TIPO == 1 .OR. TRB->C7_TIPO == 3),"PC","AE") 

		If cTipoSC7 == "PC"
			If SCR->(MsSeek(cFilSCR + cTipoSC7 + TRB->C7_NUM))
				cTst := ""
			Else
				If SCR->(MsSeek(cFilSCR + "IP" + TRB->C7_NUM))
					cTst := ""
				EndIf
			EndIf
		Else
			SCR->(MsSeek(cFilSCR + cTipoSC7 + SC7->C7_NUM))
		EndIf

		If !Empty(TRB->C7_APROV) .Or. (Empty(TRB->C7_APROV) .And. SCR->CR_TIPO == "IP")
			lNewAlc := .T.
			cComprador := UsrFullName(TRB->C7_USER)
			If TRB->C7_CONAPRO != "B"
				IF TRB->C7_CONAPRO == "R"
					lRejeit	:= .T.
				Else
					lLiber  := .T.
				EndIf
			EndIf

			While !Eof() .And. SCR->CR_FILIAL+Alltrim(SCR->CR_NUM) == cFilSCR+Alltrim(SC7->C7_NUM) .And. SCR->CR_TIPO $ "PC|AE|IP"
				cAprov += AllTrim(UsrFullName(SCR->CR_USER))+" ["
				Do Case
					Case SCR->CR_STATUS == "02" 	// Pendente
						cAprov += "BLQ"
					Case SCR->CR_STATUS == "03" 	// Liberado
						cAprov += "Ok"
					Case SCR->CR_STATUS == "04" 	// Bloqueado
						cAprov += "BLQ"
					Case SCR->CR_STATUS == "05" 	// Nivel Liberado
						cAprov += "##"
					Case SCR->CR_STATUS == "06" 	// Rejeitado
						cAprov += "REJ"
					OtherWise                 		// Aguar.Lib
						cAprov += "??"
				EndCase
				cAprov += "] - "

				SCR->(dbSkip())
			Enddo

			If !Empty(TRB->C7_GRUPCOM)
				SAJ->(MsSeek(cFilSAJ + TRB->C7_GRUPCOM))
				While !Eof() .And. SAJ->AJ_FILIAL + SAJ->AJ_GRCOM == cFilSAJ + TRB->C7_GRUPCOM
					If SAJ->AJ_USER != TRB->C7_USER
						If nPAJ_MSBLQL > 0
							If SAJ->AJ_MSBLQL == "1"
								DbSkip()
								Loop
							EndIf 
						EndIf
						cAlter += AllTrim(UsrFullName(SAJ->AJ_USER)) + "/"
					EndIf
					
					SAJ->(dbSkip())
				EndDo
			EndIf
			If "[BLQ]" $ cAprov
				lLiber := .F.
			EndIf
		EndIf

		AADD(_aDados, { AllTrim(UsrFullName(TRB->C7_USER))		,;
						TRB->C7_NUMSC + "/" + TRB->C7_ITEMSC	,;
						TRB->C7_NUMCOT							,;
						TRB->C7_NUM								,;
						TRB->C7_FORNECE							,;
						TRB->C7_LOJA							,;
						TRB->A2_NOME 							,;
						TRB->C7_PRODUTO							,;
						TRB->C7_DESCRI							,;
						TRB->C7_GRUPO							,;
						STOD(TRB->C7_EMISSAO)					,;
						STOD(TRB->CR_DATALIB)					,;
						STOD(TRB->C1_DATPRF)					,;
						STOD(TRB->C7_DATPRF)					,;
						_dRecebto								,;
						_cNumNF + "/" + _cSerNF					,;
						_dEmissao								,;
						_cCodTran								,;
						_cLojTran								,;
						_cNomTran								,;
						_nVlFrete								,;
						_nDiasAtr								,;
						_dContabi								,;
						IIF(Empty(TRB->C7_RESIDUO),"   ","SIM")	,;
						IIF(lLiber, "   ", "BLQ")				})

		TRB->(dbSkip())	 	// Avanca o ponteiro do registro no arquivo 
	EndDo

	TRB -> (DbCloseArea())

	If Len(_aDados) > 0
		AADD( _aCabec, {"USUARIO",				"C", 030, 0} )
		AADD( _aCabec, {"SOLICITACAO/ITEM",		"C", 011, 0} )
		AADD( _aCabec, {"COTACAO",				"C", 006, 0} )
		AADD( _aCabec, {"PEDIDO",				"C", 006, 0} )
		AADD( _aCabec, {"FORNECEDOR",			"C", 006, 0} )
		AADD( _aCabec, {"LOJA",					"C", 002, 0} )
		AADD( _aCabec, {"RAZAO SOCIAL",			"C", 040, 0} )
		AADD( _aCabec, {"PRODUTO",				"C", 015, 0} )
		AADD( _aCabec, {"DESCRICAO",			"C", 160, 0} )
		AADD( _aCabec, {"GRUPO",				"C", 004, 0} )
		AADD( _aCabec, {"ANALISE PEDIDO",		"D", 08,  0} )
		AADD( _aCabec, {"DATA LIBERACAO",		"D", 08,  0} )
		AADD( _aCabec, {"DATA NECESSIDADE",		"D", 08,  0} )
		AADD( _aCabec, {"DATA ENTREGA NOVA",	"D", 08,  0} )
		AADD( _aCabec, {"DATA ENTREGA",			"D", 08,  0} )
		AADD( _aCabec, {"NFISCAL/SERIE",		"C", 013, 0} )
		AADD( _aCabec, {"DATA EMISSAO NF",		"D", 08,  0} )
		AADD( _aCabec, {"TRANSPORTADORA",		"C", 006, 0} )
		AADD( _aCabec, {"LOJA",					"C", 002, 0} )
		AADD( _aCabec, {"NOME TRANSP.",			"C", 040, 0} )
		AADD( _aCabec, {"VALOR FRETE",			"N", 12,  2} )
		AADD( _aCabec, {"DIAS ATRASO",			"N", 04,  0} )
		AADD( _aCabec, {"DATA CONTABILIZACAO",	"D", 08,  0} )
		AADD( _aCabec, {"ELIMIN. RESIDUO",		"C", 03,  0} )
		AADD( _aCabec, {"STATUS",				"C", 03,  0} )
		U_GERAEXCEL(_cNomArq, _aDados, _aCabec, .T.)
	Endif

Return
