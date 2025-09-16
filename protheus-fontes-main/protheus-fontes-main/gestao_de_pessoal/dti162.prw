#INCLUDE "rwmake.ch"
#INCLUDE "totvs.ch"
#INCLUDE "topconn.ch"

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³DTI162    ºAutor  ³Adonai Gabriel   º Data ³  16/12/22      º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³  Relatório com o valor de refeições (almoço e janta)       º±±
±±º          ³  de funcionário que ganham até 5 salário mínimos           º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ SIGAPCP                                                    º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/

User Function dti162()
	
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Declaracao de Variaveis                                             ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ

	Local cDesc1         := "Este programa tem como objetivo imprimir relatorio"
	Local cDesc2         := "para conferencia registro de ponto e registro de"
	Local cDesc3         := "refeição."	
	Local titulo         := "RELATORIO PARA CONF. DE VALOR DE REFEICOES."
	Local Cabec1         := ""
	Local Cabec2         := "      CC  Hora    Matricula     Nome do Funcionario              Refeicao                Vlr.Ref.  Vlr.Dsc.  Vlr.Res.     Salario"	
	Local aOrd           := {}
    Local nS             := 0
	Private nLin         := 80
	Private lEnd         := .F.
	Private lAbortPrint  := .F.
	Private CbTxt        := Space(10)
	Private limite       := 80
	Private tamanho      := "M"
	Private nomeprog     := "DTI162" // Coloque aqui o nome do programa para impressao no cabecalho
	Private nTipo        := 18
	Private aReturn      := { "Zebrado", 1, "Administracao", 2, 2, 1, "", 1}
	Private nLastKey     := 0
	Private cPerg   	 := "DTI162"
	Private cbcont       := 00
	Private CONTFL       := 01
	Private m_pag        := 01
	Private wnrel        := "DTI162" // Coloque aqui o nome do arquivo usado para impressao em disco
	
	pergunte(cPerg,.F.)
	_aDados	 := {}
	_aCabec	 := {}

    Cabec1 += 'Do período de ' + dtoc(mv_par03) + ' até ' + dtoc(mv_par04)

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

    MsgRun("Aguarde... Realizando contagem de registros...",,{||  GeraTMP(cSitQuery, cCatQuery) })

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
	_nCont    := 0
	_cCC      := ''
    _nQtdTot  := 0
	_nVlrTot  := 0
	_nDscTot  := 0
	_nVlrFinTot  := 0

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

        if mv_par08 = 1
            if (_cData != TMP->DATAR)  //quebra por data
                @nlin,01 psay replicate('-', 132)
                nlin++
                @nlin,01 psay "Data: "
                @nlin,10 psay stod(TMP->DATAR)
                nlin++
                @nlin,01 psay replicate('-', 132)
                nlin++
                _cData := TMP->DATAR
				If mv_par11 == 1	// Popula o arquivo Excel
					AADD(_aDados, { TMP->DATAR ,;
								,;
								,;
								,;
								,;
								,;
								,;
								,;
								,;
								,;
					})
				endif
            endif

            if (_cCC != TMP->CC) //quebra por centro de custo
                _cDscCC := fBuscaCpo('CTT',1,xFilial('CTT') + TMP->CC,'CTT_DESC01')
                nlin++
                @nlin,05 psay TMP->CC
                @nlin,15 psay substr(_cDscCC,1,25)
                _cCC := TMP->CC
                nlin+=2
				If mv_par11 == 1	// Popula o arquivo Excel
					AADD(_aDados, { ,;
								TMP->CC ,;
								,;
								,;
								,;
								,;
								,;
								,;
								,;
								,;
					})
				endif
            endif

            @nlin,010 psay TMP->HORA
            @nlin,020 psay TMP->MAT
			@nlin,030 psay substr(TMP->NOME,1,30)
			@nlin,065 psay substr(TMP->DSCREF,1,15)
			@nlin,085 psay transform(TMP->VLREF,'@E 999,999.99')
			@nlin,095 psay transform(TMP->VLDSC,'@E 999,999.99')
			@nlin,105 psay transform((TMP->VLREF - TMP->VLDSC),'@E 999,999.99')
			@nlin,120 psay transform(TMP->SALTOTAL,'@E 999,999.99')

			If mv_par11 == 1	// Popula o arquivo Excel
				AADD(_aDados, { ,;
								,;
							TMP->HORA ,;
							TMP->MAT ,;
							substr(TMP->NOME,1,30) ,;
							substr(TMP->DSCREF,1,15) ,;
							transform(TMP->VLREF,'@E 999,999.99') ,;
							transform(TMP->VLDSC,'@E 999,999.99') ,;
							transform((TMP->VLREF - TMP->VLDSC),'@E 999,999.99') ,;
							transform(TMP->SALTOTAL,'@E 999,999.99') ,;
				})
			endif

            nlin++
        endif

        _nQtdTot += 1
        _nVlrTot += TMP->VLREF
        _nDscTot += TMP->VLDSC
        _nVlrFinTot += (TMP->VLREF - TMP->VLDSC)		

		TMP->(dbSkip()) // Avanca o ponteiro do registro no arquivo
	end

	nlin++
	@nlin,01 psay replicate('-', 132)
	nlin++
	@nlin,002 psay 'TOTAL: '
	@nlin,012 psay "| N° Refeições = "
	@nlin,028 psay alltrim(transform(_nQtdTot,'@E 999,999'))
	@nlin,038 psay "| Vlr. Ref. = "
	@nlin,053 psay alltrim(transform(_nVlrTot,'@E 999,999.99'))
	@nlin,070 psay "| Vlr. Dsc = "
	@nlin,090 psay alltrim(transform(_nDscTot,'@E 999,999.99'))
	@nlin,100 psay "| Vlr. Fin. = "
	@nlin,115 psay alltrim(transform(_nVlrFinTot,'@E 999,999.99'))
	nlin++
	@nlin,01 psay replicate('-', 132)
	nlin++
	If mv_par11 == 1	// Popula o arquivo Excel
		AADD(_aDados, { alltrim(transform(_nQtdTot,'@E 999,999')) ,;
					alltrim(transform(_nVlrTot,'@E 999,999.99')) ,;
					alltrim(transform(_nDscTot,'@E 999,999.99')) ,;
					alltrim(transform(_nVlrFinTot,'@E 999,999.99')) ,;
		})
	endif

	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Finaliza a execucao do relatorio...                                 ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ

	if mv_par08 = 1
		If Len(_aDados) > 0		// Gera e mostra no Excel
			AADD( _aCabec, {"Data", "D", 10, 0} )
			AADD( _aCabec, {"Centro de Custo", "C", 10, 0} )
			AADD( _aCabec, {"Hora", "C", 05, 0} )
			AADD( _aCabec, {"Matricula", "C", 08, 0} )
			AADD( _aCabec, {"Nome", "C", 30, 0} )
			AADD( _aCabec, {"Refeição", "C", 15, 0} )
			AADD( _aCabec, {"Valor da Refeição (R$)", "N", 06, 0} )
			AADD( _aCabec, {"Valor do Desconto (R$)", "N", 06, 0} )
			AADD( _aCabec, {"Valor Final (R$)", "N", 06, 0} )
			AADD( _aCabec, {"Salário (R$)", "N", 06, 0} )
			U_GERAEXCEL(nomeprog, _aDados, _aCabec, .T., .T.)
		Endif
	else
		If Len(_aDados) > 0		// Gera e mostra no Excel
			AADD( _aCabec, {"N° Total de Refeições", "N", 20, 0} )
			AADD( _aCabec, {"Valor Total das Refeições (R$)", "N", 30, 0} )
			AADD( _aCabec, {"Valor Total de Desconto (R$)", "N", 30, 0} )
			AADD( _aCabec, {"Valor Final Total das Refeições (R$)", "N", 30, 0} )
			U_GERAEXCEL(nomeprog, _aDados, _aCabec, .T., .T.)
		Endif
	endif

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

Static Function GeraTMP(cSitQuery, cCatQuery)

    _cFiltro := "RCC_CODIGO = 'S004'"
    DbSelectArea("RCC")
    RCC->(DbSetOrder(RetOrder("RCC","RCC_FILIAL+RCC_CODIGO")))
    RCC->(DbSetFilter({||&_cFiltro}, _cFiltro))
    RCC->(dbGoTop())
	while (SubStr(DToS(mv_par03), 1, 4) != SubStr(AllTrim(RCC->RCC_CONTEU), 1, 4)) .and. RCC->(!EOF())
		RCC->(dbSkip())
	end
    _nSalMin := ATail(StrTokArr(AllTrim(RCC->RCC_CONTEU), ' '))

	_cQuery := " SELECT ZB8_DATA AS DATAR, ZB8_HORA AS HORA, ZB8_DSCREF AS DSCREF, ZB8_VLREF AS VLREF, ZB8_VLDSC AS VLDSC, RA_CC AS CC, RA_MAT AS MAT, RA_NOME AS NOME"
	_cQuery += " ,(RA_SALARIO + (RA_SALARIO*RA_ADCCONF*0.01) + (IIF(RA_PERICUL > 0, RA_SALARIO*0.3, 0)) + (IIF(RA_ADCINS='2'," + _nSalMin + "*0.1,0)"
	_cQuery += " +IIF(RA_ADCINS='3'," + _nSalMin + "*0.2,0)+IIF(RA_ADCINS='4'," + _nSalMin + "*0.4,0)) +"
	_cQuery += " IIF(((DATEDIFF(DAY, CAST(RA_ADMISSA AS DATETIME), GETDATE()))/365/5) > 0,"
	_cQuery += " ((DATEDIFF(DAY, CAST(RA_ADMISSA AS DATETIME), GETDATE()))/365/5)*RA_SALARIO*0.05, 0.0)) AS SALTOTAL"
	_cQuery += " FROM " + retSqlTab('ZB8') + " , " + retSqlTab('SRA')
	_cQuery += " WHERE " + retSqlFil('ZB8') + " AND " + retSqlFil('SRA')
	_cQuery += " AND ZB8_MAT = RA_MAT"
	_cQuery += " AND RA_PROCES BETWEEN '" + mv_par09 + "' AND '" + mv_par10 + "'"
	_cQuery += " AND RA_CC BETWEEN '" + mv_par01 + "' AND '" + mv_par02 + "'"
	_cQuery += " AND ZB8_DATA BETWEEN '" + dtos(mv_par03) + "' AND '" + dtos(mv_par04) + "'"
	_cQuery += " AND RA_CATFUNC IN (" + Upper(cCatQuery) + ")"
	_cQuery += " AND RA_SITFOLH IN (" + Upper(cSitQuery) + ")"

	if mv_par07 = 1
		_cQuery += " AND ZB8_TPREF = '006'"
	else
		_cQuery += " AND ZB8_TPREF = '003'"
	endif

	_cQuery += " AND (RA_SALARIO + (RA_SALARIO*RA_ADCCONF*0.01) + (IIF(RA_PERICUL > 0, RA_SALARIO*0.3, 0)) + (IIF(RA_ADCINS='2'," + _nSalMin + "*0.1,0)"
	_cQuery += " +IIF(RA_ADCINS='3'," + _nSalMin + "*0.2,0)+IIF(RA_ADCINS='4'," + _nSalMin + "*0.4,0)) +"
	_cQuery += " IIF(((DATEDIFF(DAY, CAST(RA_ADMISSA AS DATETIME), GETDATE()))/365/5) > 0,"
	_cQuery += " ((DATEDIFF(DAY, CAST(RA_ADMISSA AS DATETIME), GETDATE()))/365/5)*RA_SALARIO*0.05, 0.0)) <= (5*" + _nSalMin + ")"
	_cQuery += " AND " + retSqlDel('ZB8') + " AND " + retSqlDel('SRA')
	_cQuery += " ORDER BY ZB8_DATA, RA_CC, ZB8_HORA, RA_MAT"

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
