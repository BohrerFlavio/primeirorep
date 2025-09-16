#INCLUDE "totvs.ch"
#INCLUDE "topconn.ch"

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³DTI165    ºAutor  ³Adonai Gabriel   º Data ³  05/01/22      º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³  Relatório com a quantidade e total de valor de refeições  º±±
±±º          ³  por centro de custo                                       º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ SIGAPCP           .                                        º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/

User Function dti165()
	
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Declaracao de Variaveis                                             ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ

	Local cDesc1         := "Este programa tem como objetivo imprimir um relatorio"
	Local cDesc2         := "para conferencia de quantidade e valor total de refeições"
	Local cDesc3         := "por centro de custo."	
	Local titulo         := "RELATORIO QUANT E VALOR REFEIC. POR C.C."
	Local Cabec1         := ""
	Local Cabec2         := "      CC  Tipo de Refeição      Quantidade          Valor Refeição(R$)  Valor Desconto(R$)  Valor Resultante(R$)"	
	Local aOrd           := {}
	Local nS
	Private nLin         := 80
	Private lEnd         := .F.
	Private lAbortPrint  := .F.
	Private CbTxt        := Space(10)
	Private limite       := 80
	Private tamanho      := "M"
	Private nomeprog     := "DTI165" // Coloque aqui o nome do programa para impressao no cabecalho
	Private nTipo        := 18
	Private aReturn      := { "Zebrado", 1, "Administracao", 2, 2, 1, "", 1}
	Private nLastKey     := 0
	Private cPerg   	 := "DTI165"
	Private cbcont       := 00
	Private CONTFL       := 01
	Private m_pag        := 01
	Private wnrel        := "DTI165" // Coloque aqui o nome do arquivo usado para impressao em disco
	
	pergunte(cPerg,.F.)
	_aDados	 := {}
	_aCabec	 := {}

    Cabec1 += 'Do período de ' + dtoc(mv_par01) + ' até ' + dtoc(mv_par02)

	wnrel := SetPrint('ZB8',NomeProg,cPerg,@titulo,cDesc1,cDesc2,cDesc3,.T.,aOrd,.T.,Tamanho,,.T.)

	_cSituacao  := mv_par05
	_cCategoria := mv_par06
	//-- Modifica variaveis para a Query
	cSitQuery := ""
	For nS:=1 to Len(_cSituacao)
		cSitQuery += "'"+Subs(_cSituacao,nS,1)+"'"
		If ( nS+1) <= Len(_cSituacao)
			cSitQuery += "," 
		Endif
	Next nS        

	cCatQuery := ""
	For nS:=1 to Len(_cCategoria)
		cCatQuery += "'"+Subs(_cCategoria,nS,1)+"'"
		If ( nS+1) <= Len(_cCategoria)
			cCatQuery += "," 
		Endif
	Next nS

    MsgRun("Aguarde... Realizando contagem de registros...",,{||  GeraTMP(cCatQuery, cSitQuery) })

	If nLastKey == 27
		Return
	Endif

	SetDefault(aReturn,'ZB8')

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
	Cabec(Titulo,Cabec1,Cabec2,NomeProg,Tamanho,nTipo)
	nLin := 9

	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ SETREGUA -> Indica quantos registros serao processados para a regua ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ

	TMP->(SetRegua(RecCount()))

	TMP->(dbGoTop())

	_cData	  := ''
	_cCC      := TMP->ZB8_CC
    _nQtdT3   := 0				// Quantidade de refeições do tipo 003 por centro de custo
	_nVlrT3   := 0				// Valor total de refeições do tipo 003 por centro de custo
	_nDscT3   := 0				// Valor total de desconto de refeições do tipo 003 por centro de custo
    _nQtdT6   := 0				// Quantidade de refeições do tipo 006 por centro de custo
	_nVlrT6   := 0				// Valor total de refeições do tipo 006 por centro de custo
	_nDscT6   := 0				// Valor total de desconto de refeições do tipo 006 por centro de custo

	_nQtdS3   := 0				// Quantidade de refeições do tipo 003 de todos os centros de custo
	_nVlrS3   := 0				// Valor total de refeições do tipo 003 de todos os centros de custo
	_nDscS3   := 0				// Valor total de desconto de refeições do tipo 003 de todos os centros de custo
    _nQtdS6   := 0				// Quantidade de refeições do tipo 006 de todos os centros de custo
	_nVlrS6   := 0				// Valor total de refeições do tipo 006 de todos os centros de custo
	_nDscS6   := 0				// Valor total de desconto de refeições do tipo 006 de todos os centros de custo

	while TMP->(!EOF())

		incregua()

		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³ Verifica o cancelamento pelo usuario...                             ³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ

		If lAbortPrint
			@nLin,00 PSAY "*** CANCELADO PELO OPERADOR ***"
			Exit
		Endif

		If nLin > 70 // Salto de Página. Neste caso o formulario tem 55 linhas...
			Cabec(Titulo,Cabec1,Cabec2,NomeProg,Tamanho,nTipo)
			nLin := 9
		Endif

        if (_cCC != TMP->ZB8_CC) //quebra por centro de custo
            _cDscCC := GetAdvFVal('CTT','CTT_DESC01',FWxFilial('CTT') + _cCC,1)
            @nlin,01 psay replicate('-', 132)
            nlin++
            @nlin,05 psay _cCC
            @nlin,15 psay substr(_cDscCC,1,25)
            nlin++
            @nlin,01 psay replicate('-', 132)
            nlin++
            _cCC := TMP->ZB8_CC

            @nlin,010 psay "CAFÉ E DOIS PÃES -> "
            @nlin,035 psay _nQtdT3
            @nlin,050 psay transform(_nVlrT3,'@E 999,999,999.99')
            @nlin,070 psay transform(_nDscT3,'@E 999,999,999.99')
            @nlin,090 psay transform((_nVlrT3-_nDscT3),'@E 999,999,999.99')
            nlin++
            @nlin,010 psay "REFEIÇÃO -> "
            @nlin,035 psay _nQtdT6
            @nlin,050 psay transform(_nVlrT6,'@E 999,999,999.99')
            @nlin,070 psay transform(_nDscT6,'@E 999,999,999.99')
            @nlin,090 psay transform((_nVlrT6-_nDscT6),'@E 999,999,999.99')
            nlin++
			_nQtdS3 += _nQtdT3
			_nVlrS3 += _nVlrT3
			_nDscS3 += _nDscT3
			_nQtdS6 += _nQtdT6
			_nVlrS6 += _nVlrT6
			_nDscS6 += _nDscT6

			_nQtdT3  := 0
			_nVlrT3  := 0
			_nDscT3  := 0
			_nVlrRT3 := 0
			_nQtdT6  := 0
			_nVlrT6  := 0
			_nDscT6  := 0
			_nVlrRT6 := 0
        endif

        if TMP->ZB8_TPREF = '003'
            _nQtdT3 += 1
            _nVlrT3 += TMP->ZB8_VLREF
            _nDscT3 += TMP->ZB8_VLDSC
        else
            _nQtdT6 += 1
            _nVlrT6 += TMP->ZB8_VLREF
            _nDscT6 += TMP->ZB8_VLDSC
        endif

		TMP->(dbSkip()) // Avanca o ponteiro do registro no arquivo
	end

	_cDscCC := GetAdvFVal('CTT','CTT_DESC01',FWxFilial('CTT') + _cCC,1)
	@nlin,01 psay replicate('-', 132)
	nlin++
	@nlin,05 psay _cCC
	@nlin,15 psay substr(_cDscCC,1,25)
	nlin++
	@nlin,01 psay replicate('-', 132)
	nlin++

	@nlin,010 psay "CAFÉ E DOIS PÃES -> "
	@nlin,035 psay _nQtdT3
	@nlin,050 psay transform(_nVlrT3,'@E 999,999,999.99')
	@nlin,070 psay transform(_nDscT3,'@E 999,999,999.99')
	@nlin,090 psay transform((_nVlrT3-_nDscT3),'@E 999,999,999.99')
	nlin++
	@nlin,010 psay "REFEIÇÃO -> "
	@nlin,035 psay _nQtdT6
	@nlin,050 psay transform(_nVlrT6,'@E 999,999,999.99')
	@nlin,070 psay transform(_nDscT6,'@E 999,999,999.99')
	@nlin,090 psay transform((_nVlrT6-_nDscT6),'@E 999,999,999.99')
	nlin++
	@nlin,01 psay replicate('-', 132)
	nlin++
	_nQtdS3 += _nQtdT3
	_nVlrS3 += _nVlrT3
	_nDscS3 += _nDscT3
	_nQtdS6 += _nQtdT6
	_nVlrS6 += _nVlrT6
	_nDscS6 += _nDscT6
	nlin++
	@nlin,005 psay "TOTAL CAFÉ E DOIS PÃES -> "
	@nlin,035 psay _nQtdS3
	@nlin,050 psay transform(_nVlrS3,'@E 999,999,999.99')
	@nlin,070 psay transform(_nDscS3,'@E 999,999,999.99')
	@nlin,090 psay transform((_nVlrS3-_nDscS3),'@E 999,999,999.99')
	nlin++
	@nlin,005 psay "TOTAL REFEIÇÃO -> "
	@nlin,035 psay _nQtdS6
	@nlin,050 psay transform(_nVlrS6,'@E 999,999,999.99')
	@nlin,070 psay transform(_nDscS6,'@E 999,999,999.99')
	@nlin,090 psay transform((_nVlrS6-_nDscS6),'@E 999,999,999.99')

	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Finaliza a execucao do relatorio...                                 ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ

	SET DEVICE TO SCREEN

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

Static Function GeraTMP(cCatQuery, cSitQuery)

	ZB6->(dbSetOrder(1))
	ZB6->(dbGoBottom())
	Local _cCodRef := ZB6->ZB6_COD

	_cQuery := " SELECT ZB8_DATA, ZB8_TPREF, ZB8_VLREF, ZB8_VLDSC, ZB8_CC"
	_cQuery += " FROM " + retSqlTab('ZB8') + " , " + retSqlTab('SRA')
	_cQuery += " WHERE " + retSqlFil('ZB8') + " AND " + retSqlFil('SRA')
	_cQuery += " AND ZB8_MAT = RA_MAT"
	_cQuery += " AND ZB8_CC BETWEEN '" + mv_par03 + "' AND '" + mv_par04 + "'"
	_cQuery += " AND RA_PROCES BETWEEN '" + mv_par07 + "' AND '" + mv_par08 + "'"
	_cQuery += " AND ZB8_DATA BETWEEN '" + dtos(mv_par01) + "' AND '" + dtos(mv_par02) + "'"
	_cQuery += " AND RA_CATFUNC IN (" + Upper(cCatQuery) + ")"
	_cQuery += " AND RA_SITFOLH IN (" + Upper(cSitQuery) + ")"
	_cQuery += " AND ZB8_CODREF BETWEEN '" + iif(!empty(mv_par09), mv_par09, "001") + "' AND '" + iif(!empty(mv_par10), mv_par10, _cCodRef) + "'"
	if mv_par11 = 2
		_cQuery += " AND ZB8_TPREF = '003'"
	elseif mv_par11 = 3
		_cQuery += " AND ZB8_TPREF = '006'"
	endif
	_cQuery += " AND " + retSqlDel('ZB8') + " AND " + retSqlDel('SRA')
	_cQuery += " ORDER BY ZB8_CC, ZB8_DATA"

	_cQuery  := ChangeQuery(_cQuery)

	//	* Mostrar a consulta */
	//@ 116,090 To 416,707 Dialog oDlgMemo Title "Consulta"
	//@ 055,005 Get _cQuery Size 250,080 MEMO Object oMemo
	//Activate Dialog oDlgMemo

	If Select("TMP") != 0
		TMP->(dbCloseArea())
	Endif

	TCQUERY _cQuery NEW ALIAS "TMP"

return
