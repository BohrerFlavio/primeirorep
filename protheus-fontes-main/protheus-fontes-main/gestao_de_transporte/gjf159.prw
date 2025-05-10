#INCLUDE "rwmake.ch"
#INCLUDE "topconn.ch"

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³GJF159    º Autor ³ Giuliano Forgiarini em 07.01.13         º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDescricao ³ Relatorio para conferencia de receitas                     º±±
±±º          ³                                                            º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ Logistica - Gestão de Distribuicao                         º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/

User Function GJF159()

	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Declaracao de Variaveis                                             ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ

	Local cDesc1         := "Este programa tem como objetivo imprimir relatorio"
	Local cDesc2         := "para conferencia de CT-es emitidos pelo setor de  "
	Local cDesc3         := "faturamento da empresa"
	Local cPict          := ""
	Local titulo         := "RELATORIO RESUMO PARA CONFERENCIA DE EMISSAO DE CT-Es"
	Local Cabec1         := ""
	Local Cabec2         := "      Nota Fiscal  Serie   Dados do Cliente                            Cidade                     Volume     Peso         Valor"
	Local imprime        := .T.
	Local aOrd           := {}
	Private nLin         := 80
	Private lEnd         := .F.
	Private lAbortPrint  := .F.
	Private CbTxt        := ""
	Private limite       := 80
	Private tamanho      := "M"
	Private nomeprog     := "GJF159" // Coloque aqui o nome do programa para impressao no cabecalho
	Private nTipo        := 18
	Private aReturn      := { "Zebrado", 1, "Administracao", 2, 2, 1, "", 1}
	Private nLastKey     := 0
	Private cPerg   	   := "GJF159"
	Private cbtxt     	:= Space(10)
	Private cbcont       := 00
	Private CONTFL       := 01
	Private m_pag        := 01
	Private wnrel        := "GJF159" // Coloque aqui o nome do arquivo usado para impressao em disco
	Private _nTOTAL      := 0.00

	if cEmpant <> '07'
		alert('Geração possível somente na Empresa 07')
		return
	endif

	if !pergunte(cPerg,.t.)
		return
	endif

	cabec1 += 'Do período de ' + dtoc(mv_par01) + ' até ' + dtoc(mv_par02)

	wnrel := SetPrint('DTC',NomeProg,cPerg,@titulo,cDesc1,cDesc2,cDesc3,.T.,aOrd,.T.,Tamanho,,.T.)

	cQuery := " SELECT DT6_DOC, DT6_SERIE, SUM(DTC_QTDVOL) AS QTDVOL, SUM(DTC_PESO) AS PESO,"
	cQuery += "  DTC_CLIDES, DTC_LOJDES, DTC_CARGA,DT6_VALFRE "
	cQuery += " FROM " + RetSQLTab('DTC') + "," + RetSQLTab('DT6')
	cQuery += " WHERE " + RetSQLFil('DTC') + " AND " + RetSQLFil('DT6') + " AND "
	cQuery += " DTC_DOC = DT6_DOC AND "
	cQuery += " (DT6_DATEMI BETWEEN  '" + dtos(mv_par01) + "' AND '" + dtos(mv_par02) + "') AND "
	cQuery += " (DTC_NUMNFC BETWEEN  '" + mv_par03 + "' AND '" + mv_par04 + "') AND "

	if !empty(mv_par07)
		cQuery += " DTC_CLIDES = '" + mv_par07 + "' AND"
	endif

	cQuery += " (DTC_LOJDES BETWEEN '" + mv_par08 + "' AND '" + mv_par09 + "') AND "
	cQuery += " (DTC_CARGA BETWEEN '" + mv_par05 + "' AND '" + mv_par06 + "') AND "
	if (mv_par10 = 1)
		cQuery += " DT6_SITCTE = '2' AND "
	endif
	cQuery += RetSQLDel('DTC') + " AND " + RetSQLDel('DT6')
	cQuery += " GROUP BY DTC_CARGA, DT6_DOC,DT6_SERIE,DTC_CLIDES,DTC_LOJDES,DT6_VALFRE "
	cQuery += " ORDER BY DTC_CARGA, DT6_DOC "

	//	* Mostrar a consulta
	//@ 116,090 To 416,707 Dialog oDlgMemo Title "Consulta"
	//@ 055,005 Get cQuery Size 250,080 MEMO Object oMemo
	//Activate Dialog oDlgMemo

	MsgRun("Aguarde... Realizando processamento de registros...",,{||  GeraTMP() })

	If nLastKey == 27
		Return
	Endif

	SetDefault(aReturn,'DTC')

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
	Local _UltCarga := ''
	Local _UltNFC   := ''
	Local _nTotPesC := 0.00 //Total peso carga
	Local _nTotVolC := 0.00 //Total volume carga
	Local _nTotValC := 0.00 //Total Valor carga
	Local _nTotPesG := 0.00 //Total peso geral
	Local _nTotVolG := 0.00 //Total volume geral
	Local _nTotValG := 0.00 //Total valor geral
	Local _nTotVlfr	:= 0.00 //Total valor do frete
	Local _aCidade := {}
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

		If nLin > 75 // Salto de Página. Neste caso o formulario tem 55 linhas...
			Cabec(Titulo,Cabec1,Cabec2,NomeProg,Tamanho,nTipo)
			nLin := 9
		Endif

		_cNomcli := fBuscaCPO('SA1',1,xfilial('SA1')+TMP->(DTC_CLIDES+DTC_LOJDES),'A1_NOME')
		_cMunCli := fBuscaCPO('SA1',1,xfilial('SA1')+TMP->(DTC_CLIDES+DTC_LOJDES),'A1_MUN')
		_cCodCid := fbuscaCPO('SA1',1,xfilial('SA1')+TMP->(DTC_CLIDES+DTC_LOJDES),'A1_COD_MUN')

		if _UltCarga <> TMP->DTC_CARGA
			cQuery2 := "SELECT DAK_CAMINH FROM DAK010 WHERE DAK_FILIAL  = '00' AND DAK_COD = '" + TMP->DTC_CARGA + "'"
			cQuery2 := ChangeQuery(cQuery2)

			If Select("TMP2") != 0
				TMP2->(dbCloseArea())
			Endif

			TCQUERY cQuery2 NEW ALIAS "TMP2"

			@nlin,00 psay replicate('-',132)
			nlin++
			@nlin,000 psay iif(!empty(TMP->DTC_CARGA), TMP->DTC_CARGA  + " Placa " + TMP2->DAK_CAMINH,'Carga não gerada!')
			nlin++
			@nlin,00 psay replicate('-',132)
			_UltCarga := TMP->DTC_CARGA
			nlin++
		endif
		@nlin,009 psay TMP->DT6_DOC
		@nlin,020 psay TMP->DT6_SERIE
		@nlin,025 psay TMP->DTC_CLIDES
		@nlin,032 psay TMP->DTC_LOJDES
		@nlin,036 psay substr(_cNomCli,1,30)
		@nlin,070 psay substr(_cMuncli,1,30)
		@nlin,095 psay transform(TMP->QTDVOL,'@E 999,999')
		@nlin,105 psay transform(TMP->PESO, '@E 999,999.99')
		
		/* inclusão de coluna para calcular valor do chapa*/
		@nlin,120 psay transform(TMP->DT6_VALFRE,'@E 999,999.99')

		_nTotPesC += TMP->PESO
		_nTotVolC += TMP->QTDVOL
		_nTotValC += TMP->DT6_VALFRE

		_nTotPesG += TMP->PESO
		_nTotVolG += TMP->QTDVOL
		_nTotValG += TMP->DT6_VALFRE

		_nPos := aScan(_aCidade,{|aVal|aVal[1] = _cCodCid})
		if _nPos <> 0

			_aCidade[_npos,2] += TMP->PESO
			_aCidade[_npos,3] += TMP->QTDVOL
			_aCidade[_npos,4] += TMP->DT6_VALFRE

		else
			aadd(_aCidade,{_cCodCid,TMP->PESO,TMP->QTDVOL,TMP->DT6_VALFRE,_cMunCli})
		endif

		nlin++

		TMP->(dbSkip()) // Avanca o ponteiro do registro no arquivo

		if _UltCarga <> TMP->DTC_CARGA .or. TMP->(eof())
			nlin++

			If nLin > 75 // Salto de Página. Neste caso o formulario tem 55 linhas...
				Cabec(Titulo,Cabec1,Cabec2,NomeProg,Tamanho,nTipo)
				nLin := 9
			Endif
			@nlin,009 psay 'Totais da carga:'
			@nlin,095 psay transform(_nTotVolC, '@E 999,999')
			@nlin,105 psay transform(_nTotPesC,'@E 999,999.99')
			@nlin,120 psay transform(_nTotValC,'@E 999,999.99')
			nlin++
			_nTotPesC := 0.00
			_nTotVolC := 0.00
			_nTotValC := 0.00

			nlin++
			@nlin,009 psay 'Totais por cidade:'
			nlin++

			for i:=1 to len(_aCidade)

				@nlin,009 psay _aCidade[i,5]
				@nlin,075 psay transform(_aCidade[i,3], '@E 999,999')
				@nlin,090 psay transform(_aCidade[i,2],'@E 999,999.99')
				if _aCidade[i,2] <=50
					@nlin,105 psay transform(5, '@E 999,999.99')
					_nTotVlfr += 5					
				Elseif _aCidade[i,2] > 50 .and. _aCidade[i,2] <= 70 
					@nlin,105 psay transform(10, '@E 999,999.99')
					_nTotVlfr += 10
				Elseif _aCidade[i,2] > 70 .and. _aCidade[i,2] <= 100 
					@nlin,105 psay transform(15, '@E 999,999.99')
					_nTotVlfr += 15
				Elseif _aCidade[i,2] > 100 .and. _aCidade[i,2] <= 150 
					@nlin,105 psay transform(20, '@E 999,999.99')
					_nTotVlfr += 20
				Elseif _aCidade[i,2] > 150 .and. _aCidade[i,2] <= 350 
					@nlin,105 psay transform(25, '@E 999,999.99')
					_nTotVlfr += 25
				Elseif _aCidade[i,2] > 350 .and. _aCidade[i,2] <= 550 
					@nlin,105 psay transform(30, '@E 999,999.99')
					_nTotVlfr += 30
				Elseif _aCidade[i,2] > 550 .and. _aCidade[i,2] <= 750 
					@nlin,105 psay transform(40, '@E 999,999.99')
					_nTotVlfr += 40
				Elseif _aCidade[i,2] > 750 .and. _aCidade[i,2] <= 850 
					@nlin,105 psay transform(50, '@E 999,999.99')
					_nTotVlfr += 50
				Elseif _aCidade[i,2] > 850 .and. _aCidade[i,2] <= 1100 
					@nlin,105 psay transform(60, '@E 999,999.99')
					_nTotVlfr += 60
				Elseif _aCidade[i,2] > 1100 .and. _aCidade[i,2] <= 1300 
					@nlin,105 psay transform(70, '@E 999,999.99')
					_nTotVlfr += 70
				Elseif _aCidade[i,2] > 1300 .and. _aCidade[i,2] <= 1550 
					@nlin,105 psay transform(80, '@E 999,999.99')
					_nTotVlfr += 80
				Elseif _aCidade[i,2] > 1550 .and. _aCidade[i,2] <= 1900 
					@nlin,105 psay transform(90, '@E 999,999.99')
					_nTotVlfr += 90
				Elseif _aCidade[i,2] > 1900 .and. _aCidade[i,2] <= 2300 
					@nlin,105 psay transform(100, '@E 999,999.99')
					_nTotVlfr += 100
				Elseif _aCidade[i,2] > 2300 .and. _aCidade[i,2] <= 2450 
					@nlin,105 psay transform(110, '@E 999,999.99')
					_nTotVlfr += 110	
				Elseif _aCidade[i,2] > 2450 .and. _aCidade[i,2] <= 2550 
					@nlin,105 psay transform(120, '@E 999,999.99')
					_nTotVlfr += 120
				Elseif _aCidade[i,2] > 2550 .and. _aCidade[i,2] <= 2650 
					@nlin,105 psay transform(130, '@E 999,999.99')
					_nTotVlfr += 130
				Elseif _aCidade[i,2] > 2650 .and. _aCidade[i,2] <= 2750 
					@nlin,105 psay transform(140, '@E 999,999.99')
					_nTotVlfr += 140	
				Elseif _aCidade[i,2] > 2750 .and. _aCidade[i,2] <= 2850 
					@nlin,105 psay transform(160, '@E 999,999.99')
					_nTotVlfr += 160
				Elseif _aCidade[i,2] > 2850 .and. _aCidade[i,2] <= 2950 
					@nlin,105 psay transform(170, '@E 999,999.99')
					_nTotVlfr += 170	
				Elseif _aCidade[i,2] > 2950 .and. _aCidade[i,2] <= 3200 
					@nlin,105 psay transform(180, '@E 999,999.99')
					_nTotVlfr += 180				
				Else 
					@nlin,105 psay transform(200, '@E 999,999.99')
					_nTotVlfr += 200
				Endif
				
				@nlin,120 psay transform(_aCidade[i,4],'@E 999,999.99')
				nlin++

			next
			nlin++
			@nlin,075 psay 'Orcamento de Entregas --->' 
			@nlin,105 psay transform(_nTotVlfr,'@E 999,999.99')
			nlin++
			_nTotVlfr  := 0.00
			_aCidade := {}
		endif
	EndDo

	If nLin > 75 // Salto de Página. Neste caso o formulario tem 55 linhas...
		Cabec(Titulo,Cabec1,Cabec2,NomeProg,Tamanho,nTipo)
		nLin := 9
	Endif

	nlin++

	@nlin,009 psay 'Total Geral:'
	@nlin,095 psay transform(_nTotVolG,'@E 999,999')
	@nlin,105 psay transform(_nTotPesG,'@E 999,999,999.99')
	@nlin,120 psay transform(_nTotValG,'@E 999,999,999.99')

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

//Função para gerar arquivo temporário
Static Function GeraTMP()

	cQuery  := ChangeQuery(cQuery)

	//	* Mostrar a consulta */
	//@ 116,090 To 416,707 Dialog oDlgMemo Title "Consulta"
	//@ 055,005 Get cQuery Size 250,080 MEMO Object oMemo
	//Activate Dialog oDlgMemo

	If Select("TMP") != 0
		TMP->(dbCloseArea())
	Endif

	TCQUERY cQuery NEW ALIAS "TMP"

return

