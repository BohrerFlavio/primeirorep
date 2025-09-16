#INCLUDE "totvs.ch"
#INCLUDE "topconn.ch"

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³ DTI197    ºAutor  ³Adonai Gabriel   º Data ³  20/11/23     º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³ Relatório para conferência de resumida de cotações em      º±±
±±º          ³ aberto para facilitar o processo do compras.               º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ COMPRAS                                                    º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/

User Function DTI197()

    //ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Declaracao de Variaveis                                             ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ

	Local cDesc1         := "Este programa tem como objetivo imprimir um relatório"
	Local cDesc2         := "para conferência de um resumo das cotações em aberto."
	Local cDesc3         := ""
	Local titulo         := "RESUMO COTAÇÕES"
	Local Cabec1         := "COTAÇÃO  USUÁRIO SOLICITAÇÃO DATA      DESCRIÇÃO                                                                                           OBSERVAÇÃO"
	Local Cabec2         := ""
	Local aOrd           := {}
	Private nlin         := 80
	Private lEnd         := .F.
	Private lAbortPrint  := .F.
	Private CbTxt        := ""
	Private limite       := 220
	Private tamanho      := "G"
	Private nomeprog     := "DTI197" // Coloque aqui o nome do programa para impressao no cabecalho
	Private nTipo        := 18
	Private aReturn      := { "Zebrado", 1, "Administracao", 2, 2, 1, "", 1}
	Private nLastKey     := 0
	Private cPerg   	 := "DTI197"
	Private cbcont     	 := 00
	Private CONTFL    	 := 01
	Private m_pag      	 := 01
	Private wnrel      	 := "DTI197" // Coloque aqui o nome do arquivo usado para impressao em disco
	Private _aDados 	 := {}
	Private _aCabec		 := {}

	pergunte(cPerg,.F.)

	wnrel := SetPrint('SC8',NomeProg,cPerg,@titulo,cDesc1,cDesc2,cDesc3,.T.,aOrd,.T.,Tamanho,,.T.)

	MsgRun("Aguarde... Realizando o processamento dos registros...",,{|| GeraTMP()})

	If nLastKey == 27
		Return
	Endif

	SetDefault(aReturn,'SC8')

    //ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Processamento. RPTSTATUS monta janela com a regua de processamento. ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ

	RptStatus({|| RunReport(Cabec1,Cabec2,Titulo,nlin) },Titulo)

Return


Static Function RunReport(Cabec1,Cabec2,Titulo,nlin)

	Cabec(Titulo,Cabec1,Cabec2,NomeProg,Tamanho,nTipo)
	nlin := 9

	_aEmail := {}

    TMP->(dbGoTop())
	TMP->(SetRegua(RecCount()))

    While TMP->(!EOF())

		incregua(TMP->C8_NUM)

        If lAbortPrint
            @nlin,00 PSAY "*** CANCELADO PELO OPERADOR ***"
            Exit
        Endif

        If nlin > 65 // Salto de Página. Neste caso o formulario tem 55 linhas...
            Cabec(Titulo,Cabec1,Cabec2,NomeProg,Tamanho,nTipo)
            nlin := 9
        Endif

		_aEmail := StrTokArr(TMP->C8_MAILUSR, '@')

		if mv_par02 = 1
			aadd(_aDados, {TMP->C8_NUM, _aEmail[1], TMP->C8_NUMSC, dtoc(stod(TMP->C1_EMISSAO)), alltrim(TMP->C8_DESCRI2), alltrim(TMP->C1_OBS)})
		endif

		@nlin,01 psay replicate('_', limite)
		@nlin,02 psay TMP->C8_NUM
		@nlin,10 psay _aEmail[1]
		@nlin,20 psay TMP->C8_NUMSC
		@nlin,28 psay dtoc(stod(TMP->C1_EMISSAO))
		@nlin,40 psay alltrim(TMP->C8_DESCRI2)
		@nlin,140 psay alltrim(TMP->C1_OBS)
		nlin++

        TMP->(dbSkip()) // Avanca o ponteiro do registro no arquivo
    enddo

    //ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Finaliza a execucao do relatorio...                                 ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ

	SET DEVICE TO SCREEN

	if mv_par02 = 1
		If Len(_aDados) > 0		// Gera e mostra no Excel
			AADD( _aCabec, {"COTAÇÃO"		, "C", 6, 0} )
			AADD( _aCabec, {"USUÁRIO"		, "C", 10, 0} )
			AADD( _aCabec, {"SOLICITAÇÃO"	, "C", 6, 0} )
			AADD( _aCabec, {"DATA"			, "D", 8, 0} )
			AADD( _aCabec, {"DESCRIÇÃO"		, "C", 70, 0} )
			AADD( _aCabec, {"OBSERVAÇÃO"	, "C", 70, 0} )
			U_GERAEXCEL(nomeprog, _aDados, _aCabec, .T., .T.)
		Endif
	endif

	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Se impressao em disco, chama o gerenciador de impressao...          ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ

	If aReturn[5]==1
		dbCommitAll()
		SET PRINTER TO
		OurSpool(wnrel)
	Endif

	MS_FLUSH()

Return

Static Function GeraTMP()

	_cQuery := "SELECT DISTINCT C8_NUM, C8_MAILUSR, C8_NUMSC, C1_EMISSAO, C8_DESCRI2, C1_OBS"
	_cQuery += " FROM  " + RetSQLTab('SC8')
	_cQuery += " INNER JOIN  " + RetSQLTab('SC1') + " ON (C8_NUMSC = C1_NUM AND C8_NUM = C1_COTACAO AND C8_ITEMSC = C1_ITEM)"
	_cQuery += " WHERE " + RetSQLFil('SC8') + " AND " + RetSQLFil('SC1')
	_cQuery += " AND C8_NUMPED = ''"
	_cQuery += " AND C8_ACCNUM = ''"
	if !empty(mv_par01) // Tabela genérica - 99 - Consulta padrão MC_99
		_cQuery += " AND C8_MAILUSR = '" + alltrim(lower(mv_par01)) + "'"
	endif
	//_cQuery += " AND (C8_PICM = 0.0 OR C8_ALIIPI = 0.0)"
	_cQuery += " AND C1_QUANT <> C1_QUJE"
	_cQuery += " AND " + RetSQLDel('SC8') + " AND " + RetSQLDel('SC1')
	_cQuery += " GROUP BY C8_NUM, C8_MAILUSR, C8_NUMSC, C1_EMISSAO, C8_DESCRI2, C1_OBS"
	_cQuery += " ORDER BY C1_EMISSAO, C8_MAILUSR, C8_NUM"

	_cQuery := ChangeQuery(_cQuery)

	//	* Mostrar a consulta */
	//@ 116,090 To 416,707 Dialog oDlgMemo Title "Consulta"
	//@ 055,005 Get _cQuery Size 250,080 MEMO Object oMemo
	//Activate Dialog oDlgMemo

	If Select("TMP") != 0
		TMP->(dbCloseArea())
	Endif

	TCQUERY _cQuery NEW ALIAS "TMP"

return
