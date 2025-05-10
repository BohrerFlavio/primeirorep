#INCLUDE "rwmake.ch"
#INCLUDE "topconn.ch"

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³DTI151    ºAutor  ³Lucas Bolzan     º Data ³  31/08/22      º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³  Relatório com a todas as marcações de ponto juntamente    º±±
±±º          ³  com marcação do almoço/janta                              º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ SIGAPCP           .                                        º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/

User Function dti151()
	
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Declaracao de Variaveis                                             ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ

	Local cDesc1         := "Este programa tem como objetivo imprimir relatorio"
	Local cDesc2         := "para conferencia registro de ponto e registro de"
	Local cDesc3         := "refeição."	
	Local titulo         := "RELATORIO PARA CONF. DE PONTO/REFEIC."
	Local Cabec1         := ""
	Local Cabec2         := "                       Matricula       Nome do Funcionario                  Registro do Ponto            Registro da Refeição"	
	Local aOrd           := {}
	Private nLin         := 80
	Private lEnd         := .F.
	Private lAbortPrint  := .F.
	Private CbTxt        := Space(10)
	Private limite       := 80
	Private tamanho      := "M"
	Private nomeprog     := "DTI151" // Coloque aqui o nome do programa para impressao no cabecalho
	Private nTipo        := 18
	Private aReturn      := { "Zebrado", 1, "Administracao", 2, 2, 1, "", 1}
	Private nLastKey     := 0
	Private cPerg   	 := "DTI151"
	Private cbcont       := 00
	Private CONTFL       := 01
	Private m_pag        := 01
	Private wnrel        := "DTI151" // Coloque aqui o nome do arquivo usado para impressao em disco
	Private _aBatidas    := {}
	
	pergunte(cPerg,.F.)
	_aDados	 := {}
	_aCabec	 := {}

	Cabec1 := 'Do período de ' + dtoc(mv_par01) + ' até ' + dtoc(mv_par02)

	wnrel := SetPrint('SP8',NomeProg,cPerg,@titulo,cDesc1,cDesc2,cDesc3,.T.,aOrd,.T.,Tamanho,,.T.)	

	MsgRun("Aguarde... Realizando contagem de registros...",,{||  GeraTMP() })

	If nLastKey == 27
		Return
	Endif

	SetDefault(aReturn,'SP8')

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
	_cCC      := '' //utilizado no vetor

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

		_nPos := aScan(_aBatidas,{|aVal|aVal[1] = TMP->MAT})
		//_aBatidas = {Matricula, Bat Cheg, Bat Alm, Bat Ret, Bat Sai, Hora Caf, Hora Alm, Hora Lan, Data, CC}
		if _nPos != 0
			_aBatidas[_nPos, 2] := TMP->HORAE1
			_aBatidas[_nPos, 3] := TMP->HORAS1
			_aBatidas[_nPos, 4] := TMP->HORAE2
			_aBatidas[_nPos, 5] := TMP->HORAS2
			_aBatidas[_nPos, 6] := AllTrim(TMP->HORAM)
			_aBatidas[_nPos, 7] := AllTrim(TMP->HORAA)
			_aBatidas[_nPos, 8] := AllTrim(TMP->HORAL)
			_aBatidas[_nPos, 9] := AllTrim(TMP->DATAB)
			_aBatidas[_nPos, 10] := TMP->CC
		else
			_nCont++
			_nPos := _nCont
			aadd(_aBatidas, {AllTrim(TMP->MAT), TMP->HORAE1, TMP->HORAS1, TMP->HORAE2, TMP->HORAS2, AllTrim(TMP->HORAM), AllTrim(TMP->HORAA), AllTrim(TMP->HORAL), AllTrim(TMP->DATAB), AllTrim(TMP->CC)})
		endif

		if (AllTrim(_cData) != _aBatidas[_nPos, 9])  //quebra por data
			@nlin,01 psay replicate('-', 132)
			nlin++
			@nlin,01 psay "Data: "
			@nlin,10 psay stod(_aBatidas[_nPos, 9])
			nlin++
			@nlin,01 psay replicate('-', 132)
			nlin++
			_cData := _aBatidas[_nPos, 9]
			if mv_par08 = 1
                AADD(_aDados, { "Data: ",;
								stod(_aBatidas[_nPos, 9]),;
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

		if (_cCC != _aBatidas[_nPos, 10]) //quebra por centro de custo
			@nlin,01 psay "Centro de Custo: "
			@nlin,18 psay AllTrim(_aBatidas[_nPos, 10])
			nlin++
			_cCC := _aBatidas[_nPos, 10]
			if mv_par08 = 1
                AADD(_aDados, { "Centro de Custo: ",;
								_aBatidas[_nPos, 10],;
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

		if mv_par07 = 1
			@nlin,025 psay _aBatidas[_nPos, 1]		// Matricula
			@nlin,035 psay substr(TMP->NOME,1,35)		// Nome
			@nlin,070 psay iif(!Empty(_aBatidas[_nPos,2]), StrTran(transform(_aBatidas[_nPos,2],'@E 99.99'),',',':'), '-----')   // batida 1
			@nlin,077 psay iif(!Empty(_aBatidas[_nPos,3]), StrTran(transform(_aBatidas[_nPos,3],'@E 99.99'),',',':'), '-----')   // batida 2
			@nlin,085 psay iif(!Empty(_aBatidas[_nPos,4]), StrTran(transform(_aBatidas[_nPos,4],'@E 99.99'),',',':'), '-----')   // batida 3
			@nlin,092 psay iif(!Empty(_aBatidas[_nPos,5]), StrTran(transform(_aBatidas[_nPos,5],'@E 99.99'),',',':'), '-----')   // batida 4
			@nlin,102 psay iif(!Empty(_aBatidas[_nPos,6]), _aBatidas[_nPos,6], '-----')   // refeicao 1
			@nlin,112 psay iif(!Empty(_aBatidas[_nPos,7]), _aBatidas[_nPos,7], '-----')   // refeicao 2
			@nlin,122 psay iif(!Empty(_aBatidas[_nPos,8]), _aBatidas[_nPos,8], '-----')   // refeicao 3
			nlin++
			if mv_par08 = 1
                AADD(_aDados, { _aBatidas[_nPos, 1],;
								substr(TMP->NOME,1,35),;
								iif(!Empty(_aBatidas[_nPos,2]), StrTran(transform(_aBatidas[_nPos,2],'@E 99.99'),',',':'), '-----'),;
								iif(!Empty(_aBatidas[_nPos,3]), StrTran(transform(_aBatidas[_nPos,3],'@E 99.99'),',',':'), '-----'),;
								iif(!Empty(_aBatidas[_nPos,4]), StrTran(transform(_aBatidas[_nPos,4],'@E 99.99'),',',':'), '-----'),;
								iif(!Empty(_aBatidas[_nPos,5]), StrTran(transform(_aBatidas[_nPos,5],'@E 99.99'),',',':'), '-----'),;
								iif(!Empty(_aBatidas[_nPos,6]), _aBatidas[_nPos,6], '-----'),;
								iif(!Empty(_aBatidas[_nPos,7]), _aBatidas[_nPos,7], '-----'),;
								iif(!Empty(_aBatidas[_nPos,8]), _aBatidas[_nPos,8], '-----'),;
				})
            endif
		else
			@nlin,025 psay _aBatidas[_nPos, 1]		// Matricula
			@nlin,035 psay substr(TMP->NOME,1,35)		// Nome
			@nlin,070 psay iif(!Empty(_aBatidas[_nPos,2]), StrTran(transform(_aBatidas[_nPos,2],'@E 99.99'),',',':'), '-----')   // batida 1
			@nlin,077 psay iif(!Empty(_aBatidas[_nPos,6]), _aBatidas[_nPos,6], '-----')   // refeicao 1
			@nlin,085 psay iif(!Empty(_aBatidas[_nPos,3]), StrTran(transform(_aBatidas[_nPos,3],'@E 99.99'),',',':'), '-----')   // batida 2
			@nlin,092 psay iif(!Empty(_aBatidas[_nPos,7]), _aBatidas[_nPos,7], '-----')   // refeicao 2
			@nlin,102 psay iif(!Empty(_aBatidas[_nPos,4]), StrTran(transform(_aBatidas[_nPos,4],'@E 99.99'),',',':'), '-----')   // batida 3
			nlin++
			if mv_par08 = 1
                AADD(_aDados, { _aBatidas[_nPos, 1],;
								substr(TMP->NOME,1,35),;
								iif(!Empty(_aBatidas[_nPos,2]), StrTran(transform(_aBatidas[_nPos,2],'@E 99.99'),',',':'), '-----'),;
								iif(!Empty(_aBatidas[_nPos,6]), _aBatidas[_nPos,6], '-----'),;
								iif(!Empty(_aBatidas[_nPos,3]), StrTran(transform(_aBatidas[_nPos,3],'@E 99.99'),',',':'), '-----'),;
								iif(!Empty(_aBatidas[_nPos,7]), _aBatidas[_nPos,7], '-----'),;
								iif(!Empty(_aBatidas[_nPos,4]), StrTran(transform(_aBatidas[_nPos,4],'@E 99.99'),',',':'), '-----'),;
								,;
								,;
				})
            endif
		endif

		TMP->(dbSkip()) // Avanca o ponteiro do registro no arquivo
	end

	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Finaliza a execucao do relatorio...                                 ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ

	SET DEVICE TO SCREEN

	if mv_par07 = 1
		If Len(_aDados) > 0		// Gera e mostra no Excel
			AADD( _aCabec, {"Matricula",	"C", 02, 0} )
			AADD( _aCabec, {"Nome",	"C", 10, 0} )
			AADD( _aCabec, {"Entrada 1",	"D", 09, 0} )
			AADD( _aCabec, {"Saída 1",		"C", 12, 2} )
			AADD( _aCabec, {"Entrada 2",	"N", 12, 2} )
			AADD( _aCabec, {"Saída 2",	"N", 12, 2} )
			AADD( _aCabec, {"Café 1",	"N", 12, 2} )
			AADD( _aCabec, {"Refeição",	"N", 12, 2} )
			AADD( _aCabec, {"Café 2",	"N", 12, 2} )
			U_GERAEXCEL(nomeprog, _aDados, _aCabec, .T., .T.)
		Endif
	else
		If Len(_aDados) > 0		// Gera e mostra no Excel
			AADD( _aCabec, {"Matricula",	"C", 02, 0} )
			AADD( _aCabec, {"Nome",	"C", 10, 0} )
			AADD( _aCabec, {"Entrada 1",	"D", 09, 0} )
			AADD( _aCabec, {"Café",		"C", 12, 2} )
			AADD( _aCabec, {"Saída 1",	"N", 12, 2} )
			AADD( _aCabec, {"Almoço",	"N", 12, 2} )
			AADD( _aCabec, {"Entrada 2",	"N", 12, 2} )
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

	_cQuery := " SELECT P8_MAT AS MAT, P8_DATAAPO AS DATAB, RA_NOME AS NOME, P8_CC AS CC,"
	_cQuery += " MAX(CASE WHEN P8_TPMARCA = '1E' THEN P8_HORA END) AS HORAE1,"
	_cQuery += " MAX(CASE WHEN P8_TPMARCA = '1S' THEN P8_HORA END) AS HORAS1,"
	_cQuery += " MAX(CASE WHEN P8_TPMARCA = '2E' THEN P8_HORA END) AS HORAE2,"
	_cQuery += " MAX(CASE WHEN P8_TPMARCA = '2S' THEN P8_HORA END) AS HORAS2,"
	_cQuery += " MAX(CASE WHEN (ZB8_CODREF = 001 OR ZB8_CODREF = 005) THEN ZB8_HORA END) AS HORAM,"
	_cQuery += " MAX(CASE WHEN (ZB8_CODREF = 002 OR ZB8_CODREF = 004 OR ZB8_CODREF = 006) THEN ZB8_HORA END) AS HORAA,"
	_cQuery += " MAX(CASE WHEN (ZB8_CODREF = 003) THEN ZB8_HORA END) AS HORAL"
	_cQuery += " FROM  " + RetSQLTab('SP8') + "LEFT JOIN " + RetSQLTab('ZB8') + " ON (SP8.P8_MAT = ZB8.ZB8_MAT)"
	_cQuery += " LEFT JOIN " + RetSQLTab('SRA') + " ON (SP8.P8_MAT = SRA.RA_MAT)"
	_cQuery += " WHERE " + RetSQLFil('SP8') + " AND " + RetSQLFil('ZB8') + " AND " + RetSQLFil('SRA') + " AND"
	_cQuery += " SP8.P8_DATAAPO BETWEEN '" + DTOS(mv_par01) + "' AND '" + DTOS(mv_par02) + "' AND"
	_cQuery += " SP8.P8_MAT  BETWEEN '" + mv_par03 + "' AND '" + mv_par04 + "' AND P8_CC BETWEEN '" + mv_par05 + "' AND '" + mv_par06 + "' AND "
	_cQuery += " SP8.P8_TIPOREG = 'O' AND P8_MOTIVRG = '' AND ZB8.ZB8_MAT = SP8.P8_MAT AND SP8.P8_DATAAPO = ZB8.ZB8_DATA"
	_cQuery += " AND " + RetSQLDel('SP8') + " AND " + RetSQLDel('ZB8') + " AND " + RetSQLDel('SRA')
	_cQuery += " GROUP BY P8_MAT, P8_DATAAPO, RA_NOME, P8_CC"
	_cQuery += " ORDER BY P8_DATAAPO, P8_CC, P8_MAT"

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
