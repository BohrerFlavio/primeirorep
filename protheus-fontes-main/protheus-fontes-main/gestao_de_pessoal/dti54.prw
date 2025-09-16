#INCLUDE "rwmake.ch"
#INCLUDE "protheus.ch"
#INCLUDE "topconn.ch"

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³DTI54    º Autor ³ Lucas Bolzan       01/12/22              º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDescricao ³ Relatório para conferencia de horas trabalhadas sem		  º±±
±±º          ³ intervalo                                                  º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ SIGAGPE/SIGAPON   	                                      º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/

User Function DTI54()
	
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Declaracao de Variaveis                                             ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ

	Local cDesc1         := "Este programa tem como objetivo imprimir relatorio"
	Local cDesc2         := "de listagem de funcionarios que fizeram mais de "
	Local cDesc3         := "seis horas corridas sem intervalo"	
	Local titulo         := "LISTAGEM DE FUNCIONARIOS"
	Local Cabec1         := ""
	Local Cabec2         := "    Matricula         Nome                       Data      Entrada  Saida      Horas Trab."
	Local aOrd           := {}
	Private nLin         := 80
	Private lEnd         := .F.
	Private lAbortPrint  := .F.
	Private CbTxt        := Space(10)
	Private limite       := 80
	Private tamanho      := "M"
	Private nomeprog     := "DTI54" // Coloque aqui o nome do programa para impressao no cabecalho
	Private nTipo        := 18
	Private aReturn      := { "Zebrado", 1, "Administracao", 2, 2, 1, "", 1}
	Private nLastKey     := 0
	Private cPerg   	 := "DTI54"
	Private cbcont       := 00
	Private CONTFL       := 01
	Private m_pag        := 01
	Private wnrel        := "DTI54" // Coloque aqui o nome do arquivo usado para impressao em disco
	Private _aBatidas    := {}
	
	pergunte(cPerg,.F.)

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
			_aBatidas[_nPos, 6] := AllTrim(TMP->DATAB)
			_aBatidas[_nPos, 7] := TMP->CC
		else
			_nCont++
			_nPos := _nCont
			aadd(_aBatidas, {AllTrim(TMP->MAT), TMP->HORAE1, TMP->HORAS1, TMP->HORAE2, TMP->HORAS2, AllTrim(TMP->DATAB), AllTrim(TMP->CC)})
		endif

		_nHras1J := ELAPTIME((StrTran(transform( _aBatidas[_nPos, 2],'@E 99.99'),',',':') + ":00"), (StrTran(transform( _aBatidas[_nPos, 3],'@E 99.99'),',',':') + ":00"))
		_nHras2J := ELAPTIME((StrTran(transform( _aBatidas[_nPos, 4],'@E 99.99'),',',':') + ":00"), (StrTran(transform( _aBatidas[_nPos, 5],'@E 99.99'),',',':') + ":00"))

		if (Val(SubStr(_nHras1J, 1, 2) + "." + SubStr(_nHras1J, 4, 2)) > 6.0 .or. Val(SubStr(_nHras2J, 1, 2) + "." + SubStr(_nHras2J, 4, 2)) > 6.0)
			/*
			@nlin,04 psay "Ficam advertidos os funcionários abaixo devido ao descumprimento da orientação "
			nlin++
			@nlin,04 psay "para não exceder a jornada de 6 horas trabalhadas seguidas sem o intervalo.  " 
			nlin++
			nlin++
			@nlin,04 psay "Ficam cientes que a reincidência implicará na adoção de outras medidas cabíveis,"
			nlin++
			@nlin,04 psay "conforme autoriza a legislação trabalhista. " 	
			nlin++
			@nlin,01 psay replicate('-', 132)
			nlin++
			*/
			if (AllTrim(_cData) != _aBatidas[_nPos, 6])  //quebra por data			
				@nlin,01 psay replicate('-', 132)
				nlin++
				@nlin,47 psay stod(_aBatidas[_nPos, 6])
				nlin++
				@nlin,01 psay replicate('-', 132)
				nlin++
				_cData := _aBatidas[_nPos, 6]
			endif

			if (_cCC != _aBatidas[_nPos, 7]) //quebra por centro de custo
				nlin++
				@nlin,4 psay "Centro de Custo: "
				@nlin,20 psay AllTrim(_aBatidas[_nPos, 7])
				_descCC := fBuscaCpo('CTT',1,xFilial('CTT')+ _aBatidas[_nPos,7],'CTT_DESC01')
				@nlin,30 psay substr(_descCC,1,20)
				nlin+=2
				_cCC := _aBatidas[_nPos, 7]
			endif

			@nlin,004 psay _aBatidas[_nPos, 1]		// Matricula
			@nlin,015 psay substr(TMP->NOME,1,35)	// Nome

			if Val(SubStr(_nHras1J, 1, 2) + "." + SubStr(_nHras1J, 4, 2)) > 6.0
				@nlin,060 psay iif(!Empty(_aBatidas[_nPos,2]), StrTran(transform(_aBatidas[_nPos,2],'@E 99.99'),',',':'), '-----')   // batida 1
				@nlin,067 psay iif(!Empty(_aBatidas[_nPos,3]), StrTran(transform(_aBatidas[_nPos,3],'@E 99.99'),',',':'), '-----')   // batida 2
				if Empty(_aBatidas[_nPos,2])
					@nlin,078 psay "Sem marcação de entrada"
				else
					@nlin,078 psay _nHras1J
				endif
			else
				@nlin,060 psay iif(!Empty(_aBatidas[_nPos,4]), StrTran(transform(_aBatidas[_nPos,4],'@E 99.99'),',',':'), '-----')   // batida 3
				@nlin,067 psay iif(!Empty(_aBatidas[_nPos,5]), StrTran(transform(_aBatidas[_nPos,5],'@E 99.99'),',',':'), '-----')   // batida 4
				if Empty(_aBatidas[_nPos,4])
					@nlin,078 psay "Sem marcação de entrada"
				else
					@nlin,078 psay _nHras2J
				endif
			endif
			nlin++
		endif

		TMP->(dbSkip()) // Avanca o ponteiro do registro no arquivo
	end

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

/*
*	Converte tempo decimal em string no formato hh:mm, porque a função padrão ConvTime(nTime)() é uma merda
*	Ex.: 2.88 -> 02:52
*/
Static Function ConvTime(nTime)
	nHora := Int(nTime)
	nMin := Int(((nTime - nHora) * 60))
	cTime := PadL(nHora, 2, "0") + ":" + PadL(nMin, 2, "0")

return cTime

Static Function GeraTMP()

	_cQuery := "SELECT P8_MAT AS MAT, P8_DATAAPO AS DATAB, RA_NOME AS NOME, P8_CC AS CC,"
	_cQuery += " MAX(CASE WHEN P8_TPMARCA = '1E' THEN P8_HORA END) AS HORAE1,"
	_cQuery += " MAX(CASE WHEN P8_TPMARCA = '1S' THEN P8_HORA END) AS HORAS1,"
	_cQuery += " MAX(CASE WHEN P8_TPMARCA = '2E' THEN P8_HORA END) AS HORAE2,"
	_cQuery += " MAX(CASE WHEN P8_TPMARCA = '2S' THEN P8_HORA END) AS HORAS2"
	_cQuery += " FROM  " + RetSQLTab('SP8')
	_cQuery += " LEFT JOIN " + RetSQLTab('SRA') + " ON (SP8.P8_MAT = SRA.RA_MAT)"
	_cQuery += " WHERE " + RetSQLFil('SP8') + " AND " + RetSQLFil('SRA') + " AND"
	_cQuery += " SP8.P8_DATAAPO BETWEEN '" + DTOS(mv_par01) + "' AND '" + DTOS(mv_par02) + "' AND"
	_cQuery += " SP8.P8_MAT  BETWEEN '" + mv_par03 + "' AND '" + mv_par04 + "' AND"
	_cQuery += " SP8.P8_TPMCREP <> 'D' AND "
	_cQuery += RetSQLDel('SP8') + " AND " + RetSQLDel('SRA')
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
