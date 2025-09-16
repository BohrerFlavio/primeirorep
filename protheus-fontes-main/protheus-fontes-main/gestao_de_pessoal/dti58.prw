#INCLUDE "rwmake.ch"
#INCLUDE "protheus.ch"
#INCLUDE "topconn.ch"

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³DTI58    º Autor ³ Mauricio Roehrs em    11/06/18           º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDescricao ³ Relatório para conferencia de funcionarios que não   	  º±±
±±º          ³ realizaram 11 horas de descanso                            º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ SIGAGPE/SIGAPON   	                                      º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/

User Function DTI58()

	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Declaracao de Variaveis                                             ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ

	Local cDesc1         := "Este programa tem como objetivo imprimir relatorio"
	Local cDesc2         := "de listagem de funcionarios que não fizeram "
	Local cDesc3         := "11 horas de descanso"
	Local cPict          := ""
	Local titulo         := "LISTAGEM DE FUNCIONARIOS"
	Local Cabec1         := ""
	Local Cabec2         := ""
	Local imprime        := .T.
	Local aOrd           := {}
	Private nLin         := 80
	Private lEnd         := .F.
	Private lAbortPrint  := .F.
	Private CbTxt        := ""
	Private limite       := 132
	Private tamanho      := "M"
	Private nomeprog     := "DTI58" // Coloque aqui o nome do programa para impressao no cabecalho
	Private nTipo        := 18
	Private aReturn      := { "Zebrado", 1, "Administracao", 2, 2, 1, "", 1}
	Private nLastKey     := 0
	Private cPerg   	 := "DTI58"
	Private cbtxt      	 := Space(10)
	Private cbcont       := 00
	Private CONTFL       := 01
	Private m_pag        := 01
	Private wnrel        := "DTI58" // Coloque aqui o nome do arquivo usado para impressao em disco
	Private _aBatidas    := {}
	pergunte(cPerg,.F.)

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

	Local nOrdem
	Local i

	Cabec(Titulo,Cabec1,Cabec2,NomeProg,Tamanho,nTipo)
	nLin := 9

	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ SETREGUA -> Indica quantos registros serao processados para a regua ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ

	TMP->(SetRegua(RecCount()))

	TMP->(dbGoTop())

	While TMP->(!EOF())

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

		//filtraMat(TMP->P8_MAT, TMP->P8_DATA) MUDEI PARA TESTE 29/10/18
		filtraMat(TMP->P8_MAT, TMP->P8_DATAAPO)

		_nCont := 1
		TMP2->(dbGoTop())
		while TMP2->(!eof())

			//Alimenta o vetor que trará descrito os valores totais de cada tipo de refeição para a empresa
			//_key := TMP2->(P8_MAT+P8_DATA) MUDEI PARA TESTE 29/10/18
			_key := TMP2->(P8_MAT+P8_DATAAPO)
			_npos := aScan(_aBatidas,{|aVal|aVal[1] = _key})

			if _npos <> 0
				//_aBatidas[_npos,2] := TMP2->P8_DATA MUDEI PARA TESTE 29/10/18
				_aBatidas[_npos,2] := TMP2->P8_DATAAPO
				_aBatidas[_npos,5] := TMP2->P8_TURNO
				_aBatidas[_npos,7] := TMP2->P8_CC
				if _nCont == 4
					_aBatidas[_npos,3] := TMP2->P8_HORA
				endif
			else
			if _nCont == 5
				//_key2  := TMP2->(P8_MAT+dtos(stod(P8_DATA)-1)) MUDEI PARA TESTE 29/10/18
				_key2  := TMP2->(P8_MAT+dtos(stod(P8_DATAAPO)-1))
				_npos2 := aScan(_aBatidas,{|aVal|aVal[1] = _key2})
				_aBatidas[_npos2,4] := TMP2->P8_HORA
				//_aBatidas[_npos2,6] := TMP2->P8_DATA MUDEI PARA TESTE 29/10/18
				_aBatidas[_npos2,6] := TMP2->P8_DATAAPO
			endif

				//aAdd(_aBatidas,{_key, TMP2->P8_DATA,TMP2->P8_HORA,0,TMP2->P8_TURNO,TMP2->P8_DATA, TMP2->P8_CC}) MUDEI PARA TESTE 29/10/18
				aAdd(_aBatidas,{_key, TMP2->P8_DATAAPO,TMP2->P8_HORA,0,TMP2->P8_TURNO,TMP2->P8_DATAAPO, TMP2->P8_CC})
			endif

			_nCont++
			TMP2->(dbSkip())
		enddo

		TMP->(dbSkip()) // Avanca o ponteiro do registro no arquivo
	Enddo

	_cMat := ''
	_cCC  := ''

	for i:=1 to len(_aBatidas)

		If nLin > 74 // Salto de Página. Neste caso o formulario tem 55 linhas...
			Cabec(Titulo,Cabec1,Cabec2,NomeProg,Tamanho,nTipo)
			nLin := 9
		Endif

		/** o calculo deve ser feito quando a ultima marcação é menor que 12h deve-se calcular (entrada-saida)
		quando a saida é depois das 12h deve-se calcular ((24-saida) + entrada ) **/

		if _aBatidas[i,3] <> 0 .and. _aBatidas[i,4] <> 0
			if _aBatidas[i,5] $ '076' //valida o turno
				//_nHrFolg := fConvHr(_aBatidas[i,3],'D') - fConvHr(_aBatidas[i,4],'D') MUDEI PARA TESTE 29/10/18
				_nHrFolg := fConvHr(_aBatidas[i,4],'D') - fConvHr(_aBatidas[i,3],'D')
			else
				_nHrFolg := (fConvHr(24,'D') - fConvHr(_aBatidas[i,3],'D')) + fConvHr(_aBatidas[i,4],'D')
			endif

			if fConvHr(_nHrFolg,'H') < 11.00
				If nLin > 74 // Salto de Página. Neste caso o formulario tem 55 linhas...
					Cabec(Titulo,Cabec1,Cabec2,NomeProg,Tamanho,nTipo)
					nLin := 9
				Endif

				if _cCC <> _aBatidas[i,7]
					@nlin,01 psay replicate('-',132)
					nlin++
					_descCC := fBuscaCpo('CTT',1,xFilial('CTT')+ _aBatidas[i,7],'CTT_DESC01')
					@nlin,03 psay 'Centro de Custo: ' + _aBatidas[i,7]
					@nlin,30 psay substr(_descCC,1,20)
					nlin++
					_cCC := _aBatidas[i,7]
				endif

				if _cMat <> substr(_aBatidas[i,1],1,6)
					@nlin,01 psay replicate('-',132)
					nlin++
					@nlin,05 psay substr(_aBatidas[i,1],1,6)
					@nlin,14 psay substr(fBuscaCpo('SRA',1,xFilial('SRA')+substr(_aBatidas[i,1],1,6),'RA_NOME'),1,35)
					nlin++
					_cMat := substr(_aBatidas[i,1],1,6)
				endif

				if _aBatidas[i,3] <> 0 .and. _aBatidas[i,4] <> 0
					@nlin,37 psay 'Data/Hora Saida: '
					@nlin,57 psay stod(_aBatidas[i,2])
					@nlin,67 psay strtran(transform(_aBatidas[i,3],'@E 99.99'),',',':')
					nlin++
					@nlin,37 psay 'Data/Hora Entrada: '
					@nlin,57 psay stod(_aBatidas[i,6])
					@nlin,67 psay strtran(transform(_aBatidas[i,4],'@E 99.99'),',',':')
					nlin++
					@nlin,37 psay 'Descanso: ' + replicate('-',19)
					@nlin,67 psay strtran(transform(fConvHr(_nHrFolg,'H'),'@E 99.99'),',',':')
					nlin+=2
				endif
			endif
		endif

	next

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

	_cQuery := "SELECT P8_MAT, P8_DATA, COUNT(P8_MAT),P8_DATAAPO, P8_CC"
	_cQuery += " FROM " + retSqlTab('SP8')
	_cQuery += " WHERE " + retSqlFil('SP8')
	_cQuery += " AND P8_DATAAPO BETWEEN '"+dtos(mv_par01)+"' AND '"+dtos(mv_par02)+"'"
	_cQuery += " AND P8_MAT BETWEEN '"+mv_par03+"' AND '"+mv_par04+"'"
	_cQuery += " AND P8_CC BETWEEN '"+mv_par05+"' AND '"+mv_par06+"'"
	_cQuery += " AND P8_TPMCREP <> 'D'"
	_cQuery += " AND " + retSqlDel('SP8')
	_cQuery += " GROUP BY P8_MAT, P8_DATA,P8_DATAAPO,P8_CC"
	//_cQuery += " HAVING count(P8_MAT) = 4" //O problema esta aqui pq ele não reconhece a saida na madrugada desse dia
	_cQuery += " ORDER BY P8_CC, P8_MAT, P8_DATA"

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

Static Function filtraMat(_cMat, _dData)

	_cQuery2 := " SELECT TOP 5 P8_MAT, P8_DATA, P8_HORA, P8_TURNO, P8_CC, P8_DATAAPO"
	_cQuery2 += " FROM  " + retSqlTab('SP8')
	_cQUery2 += " WHERE " + retSqlFil('SP8')
	_cQuery2 += " AND P8_MAT = '"+_cMat+"' AND P8_DATAAPO BETWEEN '"+_dData+"' AND '" + dtos((stod(_dData)+1)) + "'"
	_cQuery2 += " AND " + retSqlDel('SP8')
	_cQuery2 += " AND P8_TPMCREP = ''"
	//_cQuery2 += " ORDER BY P8_MAT, P8_DATA, P8_HORA, P8_CC" MUDEI PARA TESTE 29/10/18
	_cQuery2 += " ORDER BY P8_MAT, P8_DATA, P8_DATAAPO, P8_HORA, P8_CC"
	_cQuery2  := ChangeQuery(_cQuery2)

	//	* Mostrar a consulta */
	//@ 116,090 To 416,707 Dialog oDlgMemo Title "Consulta"
	//@ 055,005 Get _cQuery2 Size 250,080 MEMO Object oMemo
	//Activate Dialog oDlgMemo

	If Select("TMP2") != 0
		TMP2->(dbCloseArea())
	Endif

	TCQUERY _cQuery2 NEW ALIAS "TMP2"

return
