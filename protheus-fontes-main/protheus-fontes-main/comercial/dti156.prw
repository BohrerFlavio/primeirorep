#INCLUDE 'rwmake.ch'
#INCLUDE 'totvs.ch'
#INCLUDE 'topconn.ch'

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³DTI156    º Autor ³ Lucas Bolzan       º Data ³  13/11/22   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDescricao ³ Relatório para rebailt  	-Lucas                            º±±
±±º          ³                                                            º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ Comercial   - Rodrigo                                      º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/

USER FUNCTION DTI156()
    Local cDesc1       	 := "Este programa tem como objetivo imprimir relatorio "
	Local cDesc2       	 := "de acordo com os parametros informados pelo usuario."
	//Local cDesc3       	:= "Relatório para Rebailt"
	Local titulo       	 := "Relatório para Rebailt"
	Local nLin           := 80	
	Local Cabec1       	 := "              Cliente                                                    NFe          Emissão                           Produto                                 Quantidade(Kg)         Valor(R$)   Situação"
    Local Cabec2         := ""
	Local aOrd 			 := {}
	Private lEnd         := .F.
	Private lAbortPrint  := .F.
	Private CbTxt        := ""
	Private limite       := 132
	Private tamanho      := "G"
	Private nomeprog     := "DTI156" // Coloque aqui o nome do programa para impressao no cabecalho
	Private nTipo        := 18
	Private aReturn      := { "Zebrado", 1, "Administracao", 2, 2, 1, "", 1}
	Private nLastKey     := 0
	Private cPerg        := "DTI156"
	Private cbcont       := 00
	Private CONTFL       := 01
	Private m_pag        := 01
	Private wnrel        := "DTI156" // Coloque aqui o nome do arquivo usado para impressao em disco
	//Private _cData       := Ctod("")
	Private nNumReg 	 := 0	//Armazena número de registros no relatório
	Private nCountReg 	 := 0
	Private cString 	 := "ZZ3"
	Private _aDados	 	 := {}
	Private _aCabec	 	 := {}

	dbSelectArea("ZZ3")
	dbSetOrder(1)

	pergunte(cPerg,.F.)

    if Empty(mv_par03)
        mv_par03 := "''"
    endif

	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Monta a interface padrao com o usuario...                           ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ

	wnrel := SetPrint(cString,NomeProg,cPerg,titulo,cDesc1,cDesc2,cDesc2,.T.,aOrd,.T.,Tamanho,,.T.)

	If nLastKey == 27
		Return
	Endif

	SetDefault(aReturn,cString)

	If nLastKey == 27
		Return
	Endif

	nTipo := If(aReturn[4]==1,15,18)

	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Processamento. RPTSTATUS monta janela com a regua de processamento. ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ

	RptStatus({|| RunReport(Cabec1,Cabec2,Titulo,nLin) },Titulo)
Return


Static Function RunReport(Cabec1,Cabec2,Titulo,nLin)

	_cQuery := "SELECT "+iif(mv_par06 = 1,"E1_BAIXA AS DATAA, ","F2_EMISSAO AS DATAA, ")+"F2_NOMCLI AS CLIENTE, F2_DOC AS NFE, D2_DESCRI AS PRODUTO, D2_QUANT AS QUANTIDADE, D2_TOTAL AS VALOR, D2_VALFRE AS FRETE, F2_VALBRUT AS VALBRUT"
    _cQuery += "FROM " + retSqlTab('SF2')
    _cQuery += "INNER JOIN " + retSqlTab('SD2') + " ON (SF2.F2_FILIAL = SD2.D2_FILIAL AND SF2.F2_DOC = SD2.D2_DOC) "
	_cQuery += "INNER JOIN " + retSqlTab('SF4') + " ON (SF4.F4_FILIAL = SD2.D2_FILIAL AND SF4.F4_CODIGO = SD2.D2_TES) "
	_cQuery += "INNER JOIN " + retSqlTab('SA1') + " ON (SA1.A1_FILIAL IS NOT NULL AND SA1.A1_COD = SF2.F2_CLIENTE AND SA1.A1_LOJA = SF2.F2_LOJA) "
	if mv_par06 = 1
		_cQuery += "INNER JOIN " + retSqlTab('SE1') + " ON (SF2.F2_DOC = SE1.E1_NUM AND SE1.E1_CLIENTE = SF2.F2_CLIENTE AND SE1.E1_LOJA = SF2.F2_LOJA) "
	endif
    _cQuery += "WHERE " + retSqlFil('SD2') + " AND " + retSqlFil('SF2') + " "
	if mv_par06 = 1
		_cQuery += "AND SE1.E1_BAIXA BETWEEN '" + DTOS(mv_par01) + "' AND '" + DTOS(mv_par02) + "' "
		_cQuery += "AND SE1.E1_SALDO = 0.0 "
	else
		_cQuery += "AND SF2.F2_EMISSAO BETWEEN '" + DTOS(mv_par01) + "' AND '" + DTOS(mv_par02) + "' "
	endif
	_cQuery += "AND SD2.D2_TIPO NOT IN ('D', 'B') "
	_cQuery += "AND SD2.D2_SERIE = '10' "
	_cQuery += "AND SF4.F4_MSBLQL <> '1' "
	_cQuery += "AND SF4.F4_TIPO = 'S' "
	_cQuery += "AND SF4.F4_DUPLIC = 'S' "
	_cQuery += "AND SF2.F2_TPFRETE IN ('C', 'F', 'S', 'T') "
	_cQuery += "AND SD2.D_E_L_E_T_ = '' "
	_cQuery += "AND SF2.D_E_L_E_T_ = '' "
	_cQuery += "AND SF4.D_E_L_E_T_ = '' "
	_cQuery += "AND SA1.D_E_L_E_T_ = '' "
	if mv_par06 = 1
		_cQuery += "AND SE1.D_E_L_E_T_ = '' "
	endif
	_cQuery += "AND SA1.A1_GRPVEN = '" + mv_par03 + "' "
	if mv_par06 = 1
		_cQuery += "GROUP BY F2_NOMCLI, F2_DOC, E1_BAIXA, D2_DESCRI, D2_QUANT, D2_TOTAL, D2_VALFRE, F2_VALBRUT "
	else
		_cQuery += "GROUP BY F2_NOMCLI, F2_DOC, F2_EMISSAO, D2_DESCRI, D2_QUANT, D2_TOTAL, D2_VALFRE, F2_VALBRUT "
	endif
	_cQuery += "UNION ALL "
	_cQuery += "SELECT A1_NOME AS CLIENTE, D1_DOC AS NFE, F1_DTDIGIT AS DATAA, D1_DESCRI AS PRODUTO, D1_QUANT AS QUANTIDADE, -D1_TOTAL AS VALOR, D1_VALFRE AS FRETE, F1_VALBRUT AS VALBRUT "
    _cQuery += "FROM " + retSqlTab('SD1')
	_cQuery += "INNER JOIN " + retSqlTab('SF1') + " ON (SF1.F1_FILIAL = SD1.D1_FILIAL AND SF1.F1_DOC = SD1.D1_DOC AND SF1.F1_SERIE = SD1.D1_SERIE) "
    _cQuery += "INNER JOIN " + retSqlTab('SF4') + " ON (SF4.F4_FILIAL = SD1.D1_FILIAL AND SF4.F4_CODIGO = SD1.D1_TES) "
	_cQuery += "INNER JOIN " + retSqlTab('SA1') + " ON (SA1.A1_FILIAL IS NOT NULL AND SA1.A1_COD = SD1.D1_FORNECE AND SA1.A1_LOJA = SD1.D1_LOJA) "
	_cQuery += "INNER JOIN " + retSqlTab('SA3') + " ON (SA3.A3_FILIAL IS NOT NULL AND SA3.A3_COD = SA1.A1_VEND) "
    _cQuery += "WHERE " + retSqlFil('SD1') + " AND " + retSqlFil('SF4') + " AND " + retSqlFil('SF1') + " "
	_cQuery += "AND SD1.D1_TIPO = 'D' "
	_cQuery += "AND SD1.D1_NFORI <> '' "
	_cQuery += "AND SD1.D1_SERIORI = '10' "
	_cQuery += "AND SF4.F4_TIPO = 'E' "
	_cQuery += "AND SF4.F4_DUPLIC = 'S' "
	_cQuery += "AND SF4.F4_MSBLQL <> '1' "
	_cQuery += "AND SF4.D_E_L_E_T_ = '' "
	_cQuery += "AND SD1.D_E_L_E_T_ = '' "
	_cQuery += "AND SA1.D_E_L_E_T_ = '' "
	_cQuery += "AND SA3.D_E_L_E_T_ = '' "
	_cQuery += "AND SF1.D_E_L_E_T_ = '' "
	_cQuery += "AND SF1.F1_DTDIGIT BETWEEN '" + DTOS(mv_par01) + "' AND '" + DTOS(mv_par02) + "' "
	_cQuery += "AND SA1.A1_GRPVEN = '" + mv_par03 + "' "
    _cQuery += "GROUP BY A1_NOME, D1_DOC, F1_DTDIGIT, D1_DESCRI, D1_QUANT, D1_TOTAL, D1_VALFRE, F1_VALBRUT"

	_cQuery := ChangeQuery(_cQuery)

	If Select("QRY") != 0
		QRY->(dbCloseArea())
	Endif

	TCQUERY _cQuery NEW ALIAS "QRY"

	/*
	//Mostrar a consulta
	@ 116,090 To 416,707 Dialog oDlgMemo Title "Consulta"
	@ 055,005 Get _cQuery Size 250,080 MEMO Object oMemo
	Activate Dialog oDlgMemo
	*/

	QRY->(dbgotop())

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ SETREGUA -> Indica quantos registros serao processados para a regua ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	SetRegua(QRY->(RecCount()))
	//_cData := mv_par01//QRY->DAT

	aVetor := {'0'}
	nCountReg := 0
    nSomaValor := 0
	nValorFrete := 0
	_cStatus := "PENDENTE"

	While QRY->(!EOF())

		IncRegua()

		If lAbortPrint
			@nLin,00 PSAY "*** CANCELADO PELO OPERADOR ***"
			Exit
		Endif

		If nLin > 75 // Salto de Página. Neste caso o formulario tem 55 linhas...
			Cabec(Titulo,Cabec1,Cabec2,NomeProg,Tamanho,nTipo)
			nLin := 9
		Endif	

		nSomaValor  := nSomaValor + QRY->VALOR
		nValorFrete := nValorFrete + QRY->FRETE
		nCountReg++

		//@nlin,001 PSAY (nCountReg)
        @nlin,010 PSAY QRY->CLIENTE
        @nlin,070 PSAY QRY->NFE
        @nlin,085 PSAY stod(alltrim(QRY->DATAA))
        @nlin,100 PSAY QRY->PRODUTO
        @nlin,165 PSAY transform(QRY->QUANTIDADE,'@E 999,999.99')
        @nlin,180 PSAY transform(QRY->VALOR,'@E 999,999.99')
		if mv_par05 = 1
			if buscaSaldo(QRY->NFE) > 0
				@nlin,195 PSAY _cStatus
			else
				_cStatus := "QUITADA"
				@nlin,195 PSAY _cStatus
			endif
		endif
        nlin++

		If mv_par04 == 1	// Gera e mostra no Excel
			AADD(_aDados, { QRY->CLIENTE								,;
							QRY->NFE									,;
							alltrim(QRY->DATAA)							,;
							QRY->PRODUTO								,;
							transform(QRY->QUANTIDADE,'@E 999,999.99')	,;
							transform(QRY->VALOR,'@E 999,999.99')		,;
							iif(mv_par05 = 1, _cStatus, "")				 ;
			})
		Endif

		if mv_par05 = 1
			_cStatus := "PENDENTE"
		endif

		QRY->(dbSkip()) // Avanca o ponteiro do registro no arquivo
	EndDo

	If mv_par04 == 1	// Gera e mostra no Excel
		AADD(_aDados, {			,;
								,;
								,;
								,;
				"TOTAL-->"		,;
				nSomaValor	 	,;
		})
	Endif

    //@nlin,180 PSAY transform(nSomaValor,'@E 999,999.99')
    nlin++
    @nlin,165 PSAY "TOTAL: "
    @nlin,182 PSAY nSomaValor + nValorFrete

	DbCloseArea('QRY')

	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Finaliza a execucao do relatorio...                                 ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ

	SET DEVICE TO SCREEN

	If Len(_aDados) > 0
		AADD( _aCabec, {"CLIENTE",			"C", 02, 0} )
		AADD( _aCabec, {"NFE",				"C", 10, 0} )
		AADD( _aCabec, {"EMISSAO",			"D", 09, 0} )
		AADD( _aCabec, {"PRODUTO",			"C", 12, 2} )
		AADD( _aCabec, {"QUANTIDADE (kg)",	"N", 12, 2} )
		AADD( _aCabec, {"VALOR (R$)",		"N", 12, 2} )
		if mv_par05 = 1
			AADD( _aCabec, {"SITUAÇÃO",			"C", 20, 2} )
		endif
		U_GERAEXCEL(nomeprog, _aDados, _aCabec, .T., .T.)
	Endif	

	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Se impressao em disco, chama o gerenciador de impressao...          ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ

	If aReturn[5]==1
		dbCommitAll()
		SET PRINTER TO
		OurSpool(wnrel)
	Endif

	MS_FLUSH()
RETURN

// Busca saldo da nota para identificar se a nota foi liquidada ou não
Static Function buscaSaldo(_cNFE)

	_nRet := 0

	_cQuery2 := "SELECT E1_SALDO AS SALDO"
	_cQuery2 += " FROM " + RetSqlTab('SE1') + " (NOLOCK)"
	_cQuery2 += " WHERE " + RetSQLFil('SE1')
	_cQuery2 += " AND E1_NUM = '" + _cNFE + "'"
	_cQuery2 += " AND E1_TIPO = 'NF'"
	_cQuery2 += " AND" + RetSQLDel('SE1')

	_cQuery2  := ChangeQuery(_cQuery2)

	//	* Mostrar a consulta */
	//@ 116,090 To 416,707 Dialog oDlgMemo Title "Consulta"
	//@ 055,005 Get _cQuery2 Size 250,080 MEMO Object oMemo
	//Activate Dialog oDlgMemo

	If Select("TMP") != 0
		TMP->(dbCloseArea())
	Endif

	TCQUERY _cQuery2 NEW ALIAS "TMP"

	if TMP->(!EOF())
		_nRet := TMP->SALDO
	endif

Return _nRet
