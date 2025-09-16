#INCLUDE "rwmake.ch"
#INCLUDE "topconn.ch"
#INCLUDE "protheus.ch"

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³ DTI185    ºAutor  ³Adonai Gabriel   º Data ³  13/07/23     º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³ Rotina temporária para resolver um problema de gravação    º±±
±±º          ³ incorreta na SE5 de produtos do Porcionados                º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ Expedição                                                  º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/

User Function DTI185()

    //ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Declaracao de Variaveis                                             ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ

	Local cDesc1         := "Este programa tem como objetivo imprimir um relatório"
	Local cDesc2         := "para conferência de movimentos bancários."
	Local cDesc3         := ""
	Local titulo         := "RELATORIO PARA CONF. DE TRANSAÇÕES"
	Local Cabec1         := ""
	Local Cabec2         := "  NÚMERO        BENEFICIÁRIO                               BANCO AGENC. CONTA    CLI./FORNEC. LOJA  DT. PAGAM.       VALOR (R$)"
	Local aOrd           := {}
	Private nlin         := 80
	Private lEnd         := .F.
	Private lAbortPrint  := .F.
	Private CbTxt        := ""
	Private limite       := 132
	Private tamanho      := "M"
	Private nomeprog     := "DTI185" // Coloque aqui o nome do programa para impressao no cabecalho
	Private nTipo        := 18
	Private aReturn      := { "Zebrado", 1, "Administracao", 2, 2, 1, "", 1}
	Private nLastKey     := 0
	Private cPerg   	 := "DTI185"
	Private cbcont     	 := 00
	Private CONTFL    	 := 01
	Private m_pag      	 := 01
	Private wnrel      	 := "DTI185" // Coloque aqui o nome do arquivo usado para impressao em disco

	pergunte(cPerg,.F.)

	wnrel := SetPrint('SE5',NomeProg,cPerg,@titulo,cDesc1,cDesc2,cDesc3,.T.,aOrd,.T.,Tamanho,,.T.)

	while empty(mv_par01) .or. empty(mv_par02)
		FWAlertError('Por favor, informe um intervalo da data!','ALERTA!')
		pergunte(cPerg,.T.)
	end

	FillSE5()

	Cabec1 += 'De data de movimento - ' +  DTOC(mv_par01) + " - até - " + DTOC(mv_par02)

	MsgRun("Aguarde... Realizando o processamento dos registros...",,{|| GeraQRY1()})

	If nLastKey == 27
		Return
	Endif

	SetDefault(aReturn,'SE5')

    //ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Processamento. RPTSTATUS monta janela com a regua de processamento. ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ

	RptStatus({|| RunReport(Cabec1,Cabec2,Titulo,nlin) },Titulo)

Return


Static Function RunReport(Cabec1,Cabec2,Titulo,nlin)

	Cabec(Titulo,Cabec1,Cabec2,NomeProg,Tamanho,nTipo)
	nlin := 9

	Local i := 0
	Local aItens := {}

    QRY1->(dbGoTop())

    While QRY1->(!EOF())

		// Impressão dos movimentos sem vínculo automático de número de cheque
		if empty(QRY1->E5_NUMCHEQ) .or. QRY1->E5_TIPODOC $ "DH"

			aadd(aItens, {iif(!empty(QRY1->NUMERO),substr(alltrim(QRY1->NUMERO),1,9),"---------"),;
						iif(!empty(QRY1->BENEF),substr(alltrim(QRY1->BENEF),1,30),substr(alltrim(QRY1->E5_HISTOR),1,40)),;
						substr(alltrim(QRY1->E5_BANCO),1,3),;
						substr(alltrim(QRY1->E5_AGENCIA),1,5),;
						substr(alltrim(QRY1->E5_CONTA),1,10),;
						iif(!empty(QRY1->E5_CLIFOR),substr(alltrim(QRY1->E5_CLIFOR),1,6),"------"),;
						iif(!empty(QRY1->LOJA),substr(alltrim(QRY1->LOJA),1,2),"--"),;
						dtoc(stod(QRY1->E5_DATA)),;
						QRY1->VALOR;
			})

		endif

        QRY1->(dbSkip()) // Avanca o ponteiro do registro no arquivo
    enddo

	// Impressão dos itens de movimentos de cheque (na SE5 só existe o somatório)
	GeraQRY2()
	QRY2->(dbGoTop())

	While QRY2->(!EOF())

		aadd(aItens, {iif(!empty(QRY2->TITULO),substr(alltrim(QRY2->TITULO),1,9),"---------"),;
					iif(!empty(QRY2->BENEF),substr(alltrim(QRY2->BENEF),1,30),substr(alltrim(QRY2->EF_HIST),1,40)),;
					substr(alltrim(QRY2->EF_BANCO),1,3),;
					substr(alltrim(QRY2->EF_AGENCIA),1,5),;
					substr(alltrim(QRY2->EF_CONTA),1,10),;
					iif(!empty(QRY2->EF_FORNECE),substr(alltrim(QRY2->EF_FORNECE),1,6),"------"),;
					iif(!empty(QRY2->LOJA),substr(alltrim(QRY2->LOJA),1,2),"--"),;
					dtoc(stod(QRY2->EF_DATA)),;
					QRY2->VALOR;
		})

		QRY2->(dbSkip()) // Avanca o ponteiro do registro no arquivo
	enddo

	aSort(aItens,,,{|x,y| x[9] < y[9]})
	_nTotal := 0.0
	_cNumCheq := ""

	for i := 1 to len(aItens)

		If lAbortPrint
			@nlin,00 PSAY "*** CANCELADO PELO OPERADOR ***"
			Exit
		Endif

		If nlin > 65 // Salto de Página. Neste caso o formulario tem 55 linhas...
			Cabec(Titulo,Cabec1,Cabec2,NomeProg,Tamanho,nTipo)
			nlin := 9
		Endif

		if _cNumCheq != alltrim(mv_par06)
			@nlin,01 psay replicate('-', limite)
			nlin++
			@nlin,05 psay "Número do Cheque -> " + alltrim(alltrim(mv_par06))
			_cNumCheq := alltrim(mv_par06)
			nlin++
			@nlin,01 psay replicate('-', limite)
			nlin++
		endif

		@nlin,01 psay aItens[i,1]
		@nlin,15 psay aItens[i,2]
		@nlin,60 psay aItens[i,3]
		@nlin,65 psay aItens[i,4]
		@nlin,72 psay aItens[i,5]
		@nlin,84 psay aItens[i,6]
		@nlin,95 psay aItens[i,7]
		@nlin,100 psay aItens[i,8]
		@nlin,115 psay transform(aItens[i,9],'@E 999,999,999.99')

		_nTotal += aItens[i,9]
		nlin++
	next

	If nlin > 60 // Salto de Página. Neste caso o formulario tem 55 linhas...
		Cabec(Titulo,Cabec1,Cabec2,NomeProg,Tamanho,nTipo)
		nlin := 9
	Endif
	// Impressão do total
    nlin++
    @nlin,01 psay replicate('=',limite)
    nlin++
    @nlin,01 psay "TOTAL: "
	@nlin,115 psay transform(_nTotal,'@E 999,999,999.99')
    nlin++
    @nlin,01 psay replicate('=',limite)
    nlin++

	If nlin > 61 // Salto de Página. Neste caso o formulario tem 55 linhas...
		Cabec(Titulo,Cabec1,Cabec2,NomeProg,Tamanho,nTipo)
		nlin := 9
	Endif
	// Impressão da mensagem de autorização
	nlin++
	@nlin,01 psay "AUTORIZO DÉBITO PARA OS BANCOS/CONTAS ACIMA DOS TÍTULOS RESPECTIVOS DEBITANDO EM NOSSA C/CORRENTE NUM " + alltrim(mv_par05)
	nlin++
	@nlin,01 psay "NO DIA " + dtoc(mv_par02) + " PELO VALOR ACIMA TOTALIZADO."
	nlin+=5
	@nlin,44 psay "-------------------------------------------"
	nlin++
	if cEmpAnt = "07"
		@nlin,47 psay "TRANSPORTADORA ARRIECHE DA SILVA LTDA"
	elseif cEmpAnt = "08"
		@nlin,45 psay "INDÚSTRIA DE RAÇÕES PASSO DAS TROPAS LTDA"
	else
		@nlin,44 psay "FRIGORÍFICO SILVA INDÚSTRIA E COMÉRCIO LTDA"
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

Static Function GeraQRY1()

	_cQuery1 := "SELECT E5_CLIFOR, MAX(E5_LOJA) AS LOJA, MAX(E5_BENEF) AS BENEF, E5_DATA, E5_BANCO, SUM(E5_VALOR) AS VALOR, MAX(E5_NUMERO) AS NUMERO,"
	_cQuery1 += " E5_AGENCIA, E5_CONTA, E5_HISTOR, E5_TIPODOC, E5_NUMCHEQ, CASE WHEN E5_NUMCHEQ = '' THEN E5_VINCHEQ ELSE E5_NUMCHEQ END AS NUMCHEQ"
	_cQuery1 += " FROM  " + RetSQLTab('SE5')
	_cQuery1 += " WHERE " + RetSQLFil('SE5')
	_cQuery1 += " AND (E5_DATA BETWEEN '" + DTOS(mv_par01) + "' AND '" + DTOS(mv_par02) + "')"
	_cQuery1 += " AND E5_SITUACA <> 'C'"
	_cQuery1 += " AND E5_VALOR <> 0"
	_cQuery1 += iif(!empty(mv_par03), " AND E5_BANCO = '" + alltrim(mv_par03) + "'", "")
	_cQuery1 += iif(!empty(mv_par04), " AND E5_AGENCIA = '" + alltrim(mv_par04) + "'", "")
	_cQuery1 += iif(!empty(mv_par05), " AND E5_CONTA = '" + alltrim(mv_par05) + "'", "")
	_cQuery1 += iif(!empty(mv_par06), " AND (E5_NUMCHEQ = '" + alltrim(mv_par06) + "' OR E5_VINCHEQ = '" + alltrim(mv_par06) + "')", "")
	_cQuery1 += " AND E5_TIPODOC NOT IN ('DC','JR','MT','CM','D2','J2','M2','V2','C2','CP','TL','BA','I2','EI')"
	_cQuery1 += " AND NOT(E5_NUMCHEQ BETWEEN '*              ' AND '*ZZZZZZZZZZZZZZ')"
	_cQuery1 += " AND " + RetSQLDel('SE5')
	_cQuery1 += " GROUP BY E5_CLIFOR, E5_DATA, E5_NUMCHEQ, E5_BANCO, E5_AGENCIA, E5_CONTA, E5_HISTOR, E5_TIPODOC, E5_VINCHEQ"
	_cQuery1 += " ORDER BY E5_NUMCHEQ, E5_DATA, VALOR, E5_CLIFOR"

	_cQuery1  := ChangeQuery(_cQuery1)

	//	* Mostrar a consulta */
	//@ 116,090 To 416,707 Dialog oDlgMemo Title "Consulta"
	//@ 055,005 Get _cQuery1 Size 250,080 MEMO Object oMemo
	//Activate Dialog oDlgMemo

	If Select("QRY1") != 0
		QRY1->(dbCloseArea())
	Endif

	TCQUERY _cQuery1 NEW ALIAS "QRY1"

return

Static Function GeraQRY2()

	_cQuery2 := "SELECT EF_FORNECE, MAX(EF_LOJA) AS LOJA, MAX(EF_BENEF) AS BENEF, EF_DATA, EF_NUM, SUM(EF_VALOR) AS VALOR, MAX(EF_TITULO) AS TITULO, EF_BANCO, EF_AGENCIA, EF_CONTA, EF_HIST"
	_cQuery2 += " FROM  " + RetSQLTab('SEF')
	_cQuery2 += " WHERE " + RetSQLFil('SEF')
	_cQuery2 += " AND (EF_DATA BETWEEN '" + DTOS(mv_par01) + "' AND '" + DTOS(mv_par02) + "')"
	_cQuery2 += " AND EF_TITULO <> ''"
	_cQuery2 += " AND EF_VALOR <> 0"
	_cQuery2 += " AND EF_NUM = '" + alltrim(mv_par06) + "'"
	_cQuery2 += iif(!empty(mv_par03), " AND EF_BANCO = '" + alltrim(mv_par03) + "'", "")
	_cQuery2 += iif(!empty(mv_par04), " AND EF_AGENCIA = '" + alltrim(mv_par04) + "'", "")
	_cQuery2 += iif(!empty(mv_par05), " AND EF_CONTA = '" + alltrim(mv_par05) + "'", "")
	_cQuery2 += " AND " + RetSQLDel('SEF')
	_cQuery2 += " GROUP BY EF_FORNECE, EF_DATA, EF_NUM, EF_BANCO, EF_AGENCIA, EF_CONTA, EF_HIST"
	_cQuery2 += " ORDER BY EF_NUM, EF_DATA, VALOR, EF_FORNECE"

	_cQuery2  := ChangeQuery(_cQuery2)

	//	* Mostrar a consulta */
	//@ 116,090 To 416,707 Dialog oDlgMemo Title "Consulta"
	//@ 055,005 Get _cQuery2 Size 250,080 MEMO Object oMemo
	//Activate Dialog oDlgMemo

	If Select("QRY2") != 0
		QRY2->(dbCloseArea())
	Endif

	TCQUERY _cQuery2 NEW ALIAS "QRY2"

return

Static Function FillSE5()

	_cQuery3 := "SELECT E1_PREFIXO, E1_NUM, E1_PARCELA, E1_TIPO, E1_VINCHEQ"
	_cQuery3 += " FROM  " + RetSQLTab('SE1')
	_cQuery3 += " WHERE " + RetSQLFil('SE1')
	_cQuery3 += " AND E1_TIPO = 'NCC'"
	_cQuery3 += " AND E1_VINCHEQ = '" + alltrim(mv_par06) + "'"
	_cQuery3 += " AND " + RetSQLDel('SE1')
	_cQuery3 += " ORDER BY E1_VINCHEQ"

	_cQuery3  := ChangeQuery(_cQuery3)

	//	* Mostrar a consulta */
	//@ 116,090 To 416,707 Dialog oDlgMemo Title "Consulta"
	//@ 055,005 Get _cQuery3 Size 250,080 MEMO Object oMemo
	//Activate Dialog oDlgMemo

	If Select("QRY3") != 0
		QRY3->(dbCloseArea())
	Endif

	TCQUERY _cQuery3 NEW ALIAS "QRY3"

	QRY3->(dbGoTop())

    While QRY3->(!EOF())
		DbSelectArea("SE5")
		SE5->(DbSetOrder(7))
		SE5->(DbSeek(FwxFilial("SE5")+QRY3->(E1_PREFIXO+E1_NUM+E1_PARCELA+E1_TIPO)))
		While SE5->(!EOF()) .and. QRY3->(E1_PREFIXO+E1_NUM+E1_PARCELA+E1_TIPO) = SE5->(E5_PREFIXO+E5_NUMERO+E5_PARCELA+E5_TIPO)
			if empty(SE5->E5_VINCHEQ)
				RecLock("SE5",.F.)
				SE5->E5_VINCHEQ := QRY3->E1_VINCHEQ
				MsUnlock()
			endif

			SE5->(dbSkip()) // Avanca o ponteiro do registro no arquivo
		enddo

		QRY3->(dbSkip()) // Avanca o ponteiro do registro no arquivo
    enddo

return
