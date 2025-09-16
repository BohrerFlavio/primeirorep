#INCLUDE "rwmake.ch"
#INCLUDE "topconn.ch"
#INCLUDE "totvs.ch"

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³GJF41     ºGiuliano Forgiarini        º Data ³  26/08/08    º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDescricao ³ Relatorio de Resumo de Carga                               º±±
±±º          ³                                                            º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ Comercial e expedições (SIGAPCP e SIGAOMS)                 º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/

User Function GJF41()

	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Declaracao de Variaveis                                             ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ

	Local cDesc1         := "Este programa tem como objetivo imprimir relatorio    "
	Local cDesc2         := "de resumo de carga,discriminando apenas as quantidades"
	Local cDesc3         := "dos produtos em cada carregamento.                    "
	//Local cPict          := ""
	Local titulo         := "RELATORIO DE RESUMO DE CARGA"
	Local nLin           := 80
	Local Cabec1         := " Numero   Placa  Dt.Carreg.  Observacao                              Responsavel"
	Local Cabec2         := "    Codigo    Produto                          Quant.   Peso  Pr.Inicial  Pr.Final"
	//Local imprime      := .T.
	Local aOrd := {}
	Private lEnd         := .F.
	Private lAbortPrint  := .F.
	Private CbTxt        := ""
	Private limite       := 132
	Private tamanho      := "P"
	Private nomeprog     := "GJF41" // Coloque aqui o nome do programa para impressao no cabecalho
	Private nTipo        := 18
	Private aReturn      := { "Zebrado", 1, "Administracao", 2, 2, 1, "", 1}
	Private nLastKey     := 0
	Private cPerg      	 := "GJF41"
	//Private cbtxt      := Space(10)
	Private cbcont       := 00
	Private CONTFL       := 01
	Private m_pag        := 01
	Private wnrel        := "GJF41" // Coloque aqui o nome do arquivo usado para impressao em disco
	Private TotCaix      := 0.00
	Private TotPeso      := 0.00

	// Chamado no menu outras opções -> Resumo Carga nos pré-carregamentos
	If AllTrim(FunName()) == "GJF26"
		// Atualiza os valores do SX1
		Pergunte(cPerg,.F.)				// Carrego as MV_PAR's sem exibir a tela

		// Atualizo os valores das perguntas
		SetMvValue(cPerg, "MV_PAR01", ZZ3->ZZ3_NUM)
		SetMvValue(cPerg, "MV_PAR02", ZZ3->ZZ3_NUM)
		SetMvValue(cPerg, "MV_PAR03", ZZ3->ZZ3_DTCAR)
		SetMvValue(cPerg, "MV_PAR04", ZZ3->ZZ3_DTCAR)
		SetMvValue(cPerg, "MV_PAR05", 3)
		SetMvValue(cPerg, "MV_PAR06", 3)
		SetMvValue(cPerg, "MV_PAR07", "   ")
		SetMvValue(cPerg, "MV_PAR08", "ZZZ")
		// Aqui ainda continua com o mesmo valor (as variáveis MV_PAR ainda não foram atualizadas....)

		// Mostra a tela de Pergunte com os parâmetros atualizados
		Pergunte(cPerg,.T.)
	Endif

	wnrel := SetPrint('ZZ3',NomeProg,cPerg,@titulo,cDesc1,cDesc2,cDesc3,.T.,aOrd,.T.,Tamanho,,.T.)

	//para verificação se existe previsao de pesagem
	cQuery := "SELECT BM_FILIAL, ZZ3_NUM AS NUM, BM_FARM AS FARM, BM_PORC AS PORC,"
	cQuery += " B1_SEGUM AS SEGUM, ZZ5_COD AS COD, ZZ5_DTPFIM AS DTPFIM, ZZ5_DTPINI AS DTPINI,"
	cQuery += " SUM(ZZ5_QPCAIX) AS CAIX, SUM(ZZ5_QPPESO) AS PESO"
	cQuery += " FROM " + RetSqlName("ZZ4") + " ZZ4 INNER JOIN " + RetSqlName("ZZ3") + " ZZ3 ON (ZZ3.ZZ3_NUM = ZZ4.ZZ4_PRECAR"
	cQuery += " AND ZZ3.D_E_L_E_T_ = ''"
	cquery += " AND ZZ3.ZZ3_FILIAL = '" + FWxFilial("ZZ3") + "'"
	cQuery += " AND (ZZ3.ZZ3_NUM BETWEEN '" + mv_par01 + "' AND '" + mv_par02 + "')"
	cQuery += " AND (ZZ3.ZZ3_DTCAR BETWEEN '" + dtos(mv_par03) + "' AND '" + dtos(mv_par04) + "')"
	cQuery += " AND ZZ4.D_E_L_E_T_ = '' AND ZZ4.ZZ4_FILIAL = '" + FWxFilial("ZZ4") + "')"
	cQuery += " AND (ZZ4.ZZ4_MARCA BETWEEN '" + alltrim(mv_par07) + "' AND '" + alltrim(mv_par08) + "')"		
	cQuery += " INNER JOIN " + RetSqlName("ZZ5") + " ZZ5 ON (ZZ4.ZZ4_NUM = ZZ5.ZZ5_NUM"
	cQuery += " AND ZZ5.D_E_L_E_T_ = ''"
	cQuery += " AND ZZ5.ZZ5_FILIAL = '" + FWxFilial("ZZ5") + "')"
	cQuery += " INNER JOIN " + RetSqlName("SB1") + " SB1 ON (ZZ5.ZZ5_COD = SB1.B1_COD"
	cQuery += " AND SB1.D_E_L_E_T_ = ''"
	cQuery += " AND SB1.B1_MSBLQL = '2'"
	cQuery += " AND SB1.B1_TIPO IN('PA','PR')"
	cQuery += iif(mv_par06 = 1, " AND SB1.B1_SEGUM = 'CX'", iif(mv_par06 = 2, " AND SB1.B1_SEGUM = 'PC'", " "))//adicionado recentemente
	cQuery += " AND SB1.B1_FILIAL = '" + FWxFilial("SB1") + "')"
	cQuery += " INNER JOIN " + RetSqlName("SBM") + " SBM ON (SB1.B1_GRUPO  = SBM.BM_GRUPO "
	cQuery += iif(mv_Par05 = 1, " AND SBM.BM_PORC = 'S'", iif(mv_par05 = 2, " AND SBM.BM_PORC <> 'S'", " "))
	cQuery += " AND SBM.D_E_L_E_T_ = ''"
	cQuery += " AND SBM.BM_FILIAL = '" + FWxFilial("SBM") + "')"
	cQuery += " GROUP BY SBM.BM_FILIAL, ZZ3.ZZ3_NUM, SBM.BM_FARM, SBM.BM_PORC, SB1.B1_SEGUM, ZZ5.ZZ5_COD, ZZ5.ZZ5_DTPINI, ZZ5.ZZ5_DTPFIM"
	cQuery += " ORDER BY SBM.BM_FILIAL, ZZ3.ZZ3_NUM, SBM.BM_FARM, SBM.BM_PORC, SB1.B1_SEGUM, ZZ5.ZZ5_COD, ZZ5.ZZ5_DTPINI, ZZ5.ZZ5_DTPFIM"

	cQuery := ChangeQuery(cQuery)

	//memowrite("ZZZ_GJF41.TXT",cQuery)

	//	* Mostrar a consulta */
	//@ 116,090 To 416,707 Dialog oDlgMemo Title "Consulta"
	//@ 055,005 Get _cQuery Size 250,080 MEMO Object oMemo
	//Activate Dialog oDlgMemo

	If Select("CAR") != 0
		CAR->(dbCloseArea())
	Endif
	TCQUERY cQuery NEW ALIAS "CAR"

	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Monta a interface padrao com o usuario...                           ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ

	If nLastKey == 27
		Return
	Endif

	SetDefault(aReturn,'ZZ3')

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

	//Local nOrdem

	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ SETREGUA -> Indica quantos registros serao processados para a regua ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ

	CAR->(SetRegua(RecCount()))

	CAR->(dbGoTop())

	nCarga  := ' '
	cArm    := ' '
	cSeg    := ' '
	_cPorc  := ' '
	nQuebra := 62
	_nTCxFarm := 0
	_nTPsFarm := 0

	While CAR->(!EOF())

		incregua()

		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³ Verifica o cancelamento pelo usuario...                             ³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ

		If lAbortPrint
			@nLin,00 PSAY "*** CANCELADO PELO OPERADOR ***"
			Exit
		Endif

		if nCarga != CAR->NUM
			nlin++

			//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
			//³ Impressao do cabecalho do relatorio. . .                            ³
			//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ

			If nLin > nQuebra // Salto de Página. Neste caso o formulario tem 65 linhas...
				Cabec(Titulo,Cabec1,Cabec2,NomeProg,Tamanho,nTipo)
				nLin := 9
			Endif

			@nLin,01 PSAY CAR->NUM
			ZZ3->(dbsetorder(2))
			ZZ3->(MsSeek(FWxfilial('ZZ3')+alltrim(CAR->NUM)))
			@nlin,09 PSAY ZZ3->ZZ3_PLACA
			@nlin,18 PSAY ZZ3->ZZ3_DTCAR
			@nlin,28 PSAY ZZ3->ZZ3_OBS
			@nlin,70 PSAY ZZ3->ZZ3_USUAR
			nlin++

			do case
				case ZZ3->ZZ3_STATUS = 'A'
				@nlin,01 PSAY '[Aberto]'
				case ZZ3->ZZ3_STATUS = 'B'
				@nlin,01 PSAY '[Bloqueado]'
				case ZZ3->ZZ3_STATUS = 'C'
				@nlin,01 PSAY '[Carregando]'
				case ZZ3->ZZ3_STATUS = 'S'
				@nlin,01 PSAY '[Espera]'
				case ZZ3->ZZ3_STATUS = 'E'
				@nlin,01 PSAY '[Encerrado]'
			endcase
			nCarga := CAR->NUM
		endif

		if cArm != alltrim(CAR->FARM+NUM)
			nlin++

			do case
				case CAR->FARM = 'C'
				@nlin,01 PSAY 'CONGELADOS'
				case CAR->FARM = 'R'
				@nlin,01 PSAY 'RESFRIADOS'
				case CAR->FARM = 'S'
				@nlin,01 PSAY 'SALGADOS'
			endcase
			cSeg := ' '
			cArm := alltrim(CAR->FARM+NUM)
			nlin++
		endif

		if cSeg != CAR->SEGUM
			@nlin,01 PSAY CAR->SEGUM
			cSeg := CAR->SEGUM
			_cPorc := ''
			nlin++
		endif

		if _cPorc != CAR->PORC
			if CAR->PORC = 'S'
				@nlin,01 PSAY 'PORCIONADO'
				nlin++
			endif
			//	_cGrupo := CAR->PORC
			_cPorc := CAR->PORC
		endif

		If nLin > nQuebra // Salto de Página. Neste caso o formulario tem 55 linhas...
			Cabec(Titulo,Cabec1,Cabec2,NomeProg,Tamanho,nTipo)
			nLin := 9
		Endif

		@nlin,004 PSAY alltrim(CAR->COD)
		//@nlin,013 PSAY substr(GetAdvFVal('SB1','B1_DESCRED',FWxfilial('SB1')+CAR->COD,1),1,30)
		@nlin,013 PSAY substr(GetAdvFVal('SB1','B1_DESC',FWxfilial('SB1')+CAR->COD,1),1,30)
		@nlin,045 PSAY transform(CAR->CAIX, '@E 9,999')
		@nlin,051 PSAY transform(CAR->PESO, '@E 999,999.99')
		@nlin,063 PSAY STOD(CAR->DTPINI)
		@nlin,073 PSAY STOD(CAR->DTPFIM)
		TotCaix += CAR->CAIX
		TotPeso += CAR->PESO
		_nTCxFarm += CAR->CAIX
		_nTPsFarm += CAR->PESO

		nLin++ // Avanca a linha de impressao

		CAR->(dbSkip()) // Avanca o ponteiro do registro no arquivo

		if CAR->(EOF()) .or. cSeg != CAR->SEGUM .or. cArm != alltrim(CAR->FARM+NUM) .or. _cPorc != CAR->PORC
			nlin++
			@nlin,05 PSAY "TOTAL:------------------------------>"
			@nlin,45 PSAY transform(_nTCxFarm, '@E 9,999')
			@nlin,52 PSAY transform(_nTPsFarm, '@E 999,999.99')
			_nTCxFarm := 0
			_nTPsFarm := 0
			nlin+=2
		endif

		if nCarga != CAR->NUM
			If nLin > nQuebra // Salto de Página. Neste caso o formulario tem 55 linhas...
				Cabec(Titulo,Cabec1,Cabec2,NomeProg,Tamanho,nTipo)
				nLin := 9
			Endif

			nlin++
			@nlin,05 PSAY "TOTAL DA CARGA:--------------------->"
			@nlin,45 PSAY transform(TotCaix, '@E 9,999')
			@nlin,52 PSAY transform(TotPeso, '@E 999,999.99')
			TotCaix := 0
			TotPeso := 0
			nlin += 2

			//Cabec(Titulo,'','',NomeProg,Tamanho,nTipo) //Quebra para proxima pagina
			//	nLin := 9

			ZZ4->(dbsetorder(1))
			ZZ4->(MsSeek(FWxfilial('ZZ4')+nCarga))
			while ZZ4->(!eof()) .and. ZZ4->ZZ4_FILIAL = FWxfilial('ZZ4') .and. nCarga = ZZ4->ZZ4_PRECAR
				ZZ5->(dbsetorder(1))
				ZZ5->(MsSeek(FWxfilial('ZZ5')+ZZ4->ZZ4_NUM))
				while ZZ5->(!eof()) .and. ZZ5->ZZ5_FILIAL = FWxfilial('ZZ5') .and. ZZ5->ZZ5_NUM = ZZ4->ZZ4_NUM

					if empty(ZZ5->ZZ5_OBS)
						ZZ5->(dbskip())
						loop
					endif

					If nLin > nQuebra // Salto de Página. Neste caso o formulario tem 65 linhas...
						Cabec(Titulo,Cabec1,Cabec2,NomeProg,Tamanho,nTipo)
						nLin := 9
					Endif

					@nlin,01 PSAY "Prod.:" + alltrim(ZZ5->ZZ5_COD)+ " Quant:" +;
					transform(ZZ5->ZZ5_QPCAIX,'@E 9,999')  + "  Ped.:" + ZZ5->ZZ5_NUM +;
					" Cli.:" + ZZ4->ZZ4_CODCLI + "/" + ZZ4->ZZ4_LOJA
					if  !empty(ZZ5->ZZ5_OBS)  //Se obs vazio nao imprime obs
						nlin++
						@nlin,01 PSAY "OBS.: " + ZZ5->ZZ5_OBS
					endif
					nlin++
					ZZ5->(dbskip())
				enddo
				ZZ4->(dbskip())
			enddo
			//Cabec(Titulo,Cabec1,Cabec2,NomeProg,Tamanho,nTipo)
			//nLin := 9
		endif

	EndDo

	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Finaliza a execucao do relatorio...                                 ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ

	DbCloseArea('CAR')

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
