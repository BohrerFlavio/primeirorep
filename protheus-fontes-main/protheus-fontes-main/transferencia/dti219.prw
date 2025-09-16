#INCLUDE "rwmake.ch"
#INCLUDE "totvs.ch"
#INCLUDE "topconn.ch"

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³ DTI219    ºAutor  ³Adonai Gabriel   º Data ³  15/01/25     º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³ Relatório para conferência de transferências de caixas     º±±
±±º          ³ de matéria-prima para o Porcionados.                       º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ PCP                                                        º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/

User Function DTI219()

    //ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Declaracao de Variaveis                                             ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ

	Local cDesc1         := "Este programa tem como objetivo imprimir um relatório"
	Local cDesc2         := "para conferência de transferências de caixas"
	Local cDesc3         := "de matéria-prima para o Porcionados."
	Local titulo         := "TRANSFERÊNCIAS DE MP - PORCIONADOS"
	Local Cabec1         := ""
	Local Cabec2         := "                CAIXA         DATA PROD.    PESO LIQ.      LOCAL   TIPO"
	Local aOrd           := {}
	Private nlin         := 80
	Private lEnd         := .F.
	Private lAbortPrint  := .F.
	Private CbTxt        := ""
	Private limite       := 132
	Private tamanho      := "M"
	Private nomeprog     := "DTI219" // Coloque aqui o nome do programa para impressao no cabecalho
	Private nTipo        := 18
	Private aReturn      := { "Zebrado", 1, "Administracao", 2, 2, 1, "", 1}
	Private nLastKey     := 0
	Private cPerg   	 := "DTI219"
	Private cbcont     	 := 00
	Private CONTFL    	 := 01
	Private m_pag      	 := 01
	Private wnrel      	 := "DTI219" // Coloque aqui o nome do arquivo usado para impressao em disco

	pergunte(cPerg,.F.)

	wnrel := SetPrint('ZAS',NomeProg,cPerg,@titulo,cDesc1,cDesc2,cDesc3,.T.,aOrd,.T.,Tamanho,,.T.)

	while empty(mv_par01) .or. empty(mv_par02)
		FWAlertError('Por favor, informe um intervalo da data!','ALERTA!')
		pergunte(cPerg,.T.)
	end

	Cabec1 += 'De data de - ' +  DTOC(mv_par01) + " - até - " + DTOC(mv_par02)

	MsgRun("Aguarde... Realizando o processamento dos registros...",,{|| GeraTMP()})

	If nLastKey == 27
		Return
	Endif

	SetDefault(aReturn,'ZAS')

    //ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Processamento. RPTSTATUS monta janela com a regua de processamento. ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ

	RptStatus({|| RunReport(Cabec1,Cabec2,Titulo,nlin) },Titulo)

Return


Static Function RunReport(Cabec1,Cabec2,Titulo,nlin)

	Cabec(Titulo,Cabec1,Cabec2,NomeProg,Tamanho,nTipo)
	nlin := 9

    TMP->(dbGoTop())
	TMP->(SetRegua(RecCount()))

	_cDtTransf := ""
	_cCod := ""

	if mv_par03 != 3
		nlin+=2
		@nlin,01 psay " --- CAIXAS TRANSFERIDAS QUE NÃO FORAM RECEBIDAS --- "
		nlin+=2

		While TMP->(!EOF()) .and. empty(TMP->DT_RECEB)

			incregua()

			If lAbortPrint
				@nlin,00 PSAY "*** CANCELADO PELO OPERADOR ***"
				Exit
			Endif

			If nlin > 70 // Salto de Página. Neste caso o formulario tem 55 linhas...
				Cabec(Titulo,Cabec1,Cabec2,NomeProg,Tamanho,nTipo)
				nlin := 9
			Endif

			if _cDtTransf <> TMP->DT_TRASNF
				@nlin,00 psay replicate("=",132)
				nlin++
				@nlin,05 psay "Data de transferência: " + dtoc(stod(TMP->DT_TRASNF))
				nlin++
				@nlin,00 psay replicate("=",132)
				nlin++
				_cDtTransf := TMP->DT_TRASNF
			endif

			if _cCod <> TMP->COD
				@nlin,00 psay replicate("-",132)
				nlin++
				@nlin,05 psay "Produto: " + alltrim(TMP->COD) + " - " + alltrim(TMP->DESCRI)
				nlin++
				@nlin,00 psay replicate("-",132)
				nlin++
				_cCod := TMP->COD
			endif

			@nlin,15 psay TMP->CAIXA
			@nlin,30 psay dtoc(stod(TMP->DATA_PROD))
			@nlin,45 psay transform(TMP->PESO,'@E 999.99')
			@nlin,55 psay alltrim(TMP->LOCALD)
			@nlin,65 psay iif(TMP->TIPO = 'P', 'PA', 'MP')
			nlin++

			TMP->(dbSkip()) // Avanca o ponteiro do registro no arquivo
		enddo
	endif

	_cCod := ""
	_cDtTransf := ""

	if mv_par03 != 2
		nlin+=2
		@nlin,01 psay " --- CAIXAS QUE FORAM RECEBIDAS --- "
		nlin+=2

		While TMP->(!EOF())

			incregua()

			If lAbortPrint
				@nlin,00 PSAY "*** CANCELADO PELO OPERADOR ***"
				Exit
			Endif

			If nlin > 70 // Salto de Página. Neste caso o formulario tem 55 linhas...
				Cabec(Titulo,Cabec1,Cabec2,NomeProg,Tamanho,nTipo)
				nlin := 9
			Endif

			if _cDtTransf <> TMP->DT_TRASNF
				@nlin,00 psay replicate("=",132)
				nlin++
				@nlin,05 psay "Data de transferência: " + dtoc(stod(TMP->DT_TRASNF))
				nlin++
				@nlin,00 psay replicate("=",132)
				nlin++
				_cDtTransf := TMP->DT_TRASNF
			endif

			if _cCod <> TMP->COD
				@nlin,00 psay replicate("-",132)
				nlin++
				@nlin,05 psay "Produto: " + alltrim(TMP->COD) + " - " + alltrim(TMP->DESCRI)
				nlin++
				@nlin,00 psay replicate("-",132)
				nlin++
				_cCod := TMP->COD
			endif

			@nlin,15 psay TMP->CAIXA
			@nlin,30 psay dtoc(stod(TMP->DATA_PROD))
			@nlin,45 psay transform(TMP->PESO,'@E 999.99')
			@nlin,55 psay alltrim(TMP->LOCALD)
			@nlin,65 psay iif(TMP->TIPO = 'P', 'PA', 'MP')
			nlin++

			TMP->(dbSkip()) // Avanca o ponteiro do registro no arquivo
		enddo
	endif

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

Static Function GeraTMP()
	Local _cQuery := ""

	_cQuery := "SELECT DISTINCT ZAS_CODTRA AS TRANSF, ZAS_ITETRA AS ITEM, ZAS_DTRANS AS DT_TRASNF, ZAS_DTRMP AS DT_RECEB, ZAS_CONTRO AS CAIXA, ZAS_COD AS COD, ZAS_DESC AS DESCRI,"
	_cQuery += " ZAS_DTPROD AS DATA_PROD, ZAS_PESOL AS PESO, ZAS_LOCAL AS LOCALD, ZAS_LOCALI AS LOCALIZ, ZAS_PALLET AS PALLET, ZAS_BATEL AS BATEL, ZAS_TIPO AS TIPO"
	_cQuery += " FROM  " + RetSQLTab('ZAS') + " (NOLOCK)"
	_cQuery += " INNER JOIN  " + RetSQLTab('ZMP') + " (NOLOCK) ON (ZAS.ZAS_CODTRA = ZMP.ZMP_NUM)"
    _cQuery += " INNER JOIN  " + RetSQLTab('ZMQ') + " (NOLOCK) ON (ZAS.ZAS_CODTRA = ZMQ.ZMQ_NUM AND ZAS.ZAS_ITETRA = ZMQ.ZMQ_ITEM)"
	_cQuery += " WHERE " + RetSQLFil('ZAS') + " AND " + RetSQLFil('ZMP') + " AND " + RetSQLFil('ZMQ')
	_cQuery += " AND (ZMP.ZMP_DATA BETWEEN '" + DTOS(mv_par01) + "' AND '" + DTOS(mv_par02) + "')"
	_cQuery += " AND " + RetSQLDel('ZAS') + " AND " + RetSQLDel('ZMP') + " AND " + RetSQLDel('ZMQ')
	_cQuery += " UNION ALL"
	_cQuery += " SELECT DISTINCT Z8_CODTRAI AS TRANSF, Z8_ITETRAI AS ITEM, Z8_DTRANSI AS DT_TRASNF, Z8_DTRPOR AS DT_RECEB, Z8_CONTROL AS CAIXA, Z8_COD AS COD, Z8_DESCRI AS DESCRI,"
	_cQuery += " Z8_DATAP AS DATA_PROD, Z8_PESO AS PESO, Z8_LOCAL AS LOCALD, Z8_LOCALIZ AS LOCALIZ, Z8_PALLET AS PALLET, Z8_BATEL AS BATEL, Z8_TIPO AS TIPO"
	_cQuery += " FROM  " + RetSQLTab('SZ8') + " (NOLOCK)"
	_cQuery += " INNER JOIN  " + RetSQLTab('ZMP') + " (NOLOCK) ON (SZ8.Z8_CODTRAI = ZMP.ZMP_NUM)"
    _cQuery += " INNER JOIN  " + RetSQLTab('ZMQ') + " (NOLOCK) ON (SZ8.Z8_CODTRAI = ZMQ.ZMQ_NUM AND SZ8.Z8_ITETRAI = ZMQ.ZMQ_ITEM)"
	_cQuery += " WHERE " + RetSQLFil('SZ8') + " AND " + RetSQLFil('ZMP') + " AND " + RetSQLFil('ZMQ')
	_cQuery += " AND (ZMP.ZMP_DATA BETWEEN '" + DTOS(mv_par01) + "' AND '" + DTOS(mv_par02) + "')"
	_cQuery += " AND " + RetSQLDel('SZ8') + " AND " + RetSQLDel('ZMP') + " AND " + RetSQLDel('ZMQ')
	_cQuery += " ORDER BY DT_RECEB, TRANSF, ITEM, COD"

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
