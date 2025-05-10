#INCLUDE "rwmake.ch"
#INCLUDE "topconn.ch"

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³FFM06     ºFabian Ferreira Maurer     º Data ³  16/09/2013  º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDescricao ³ Relatorio de Manifesto de carga com Redistribuicao         º±±
±±º          ³                                                            º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ Comercial e expedições (SIGAPCP e SIGAOMS)                 º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/

User Function FFM06()


	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Declaracao de Variaveis                                             ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ

	Local cDesc1        := "Este programa tem como objetivo imprimir relatorio       "
	Local cDesc2        := "de Manifesto de carga,discriminando apenas as quantidades"
	Local cDesc3        := "dos produtos em cada carregamento para redistribuicao.   "
	Local cPict         := ""
	Local titulo       	:= "MANIFESTO DE REDISTRIBUICAO"
	Local nLin         	:= 80

	Local Cabec1       	:= " Cliente                                                    Municipio           " 
	Local Cabec2       	:= " Codigo    Produto                        Quant.      P.Bruto           P.Liq."
	Local imprime      	:= .T.
	Local aOrd := {}
	Private lEnd        := .F.
	Private lAbortPrint := .F.
	Private CbTxt       := ""
	Private limite      := 80
	Private Tamanho     := "P"
	Private nomeprog    := "FFM06" // Coloque aqui o nome do programa para impressao no cabecalho
	Private nTipo       := 18
	Private aReturn     := { "Zebrado", 1, "Administracao", 2, 2, 1, "", 1}
	Private nLastKey    := 0
	Private cPerg   	:= "FFM06"
	Private cbtxt      	:= Space(10)
	Private cbcont     	:= 00
	Private CONTFL     	:= 01
	Private m_pag      	:= 01
	Private wnrel      	:= "FFM06" // Coloque aqui o nome do arquivo usado para impressao em disco
	Private TotCaix    	:= 0.00
	Private TotPeso    	:= 0.00
	Private _cDesc			:= ''

	pergunte(cPerg,.F.)

	wnrel := SetPrint('ZZ3',NomeProg,cPerg,@titulo,cDesc1,cDesc2,cDesc3,.T.,aOrd,.T.,Tamanho,,.T.)

	cQuery := " SELECT ZZ4_PRECAR AS NUM, ZZ4_CODCLI AS CODCLI, ZZ4_NOME AS NOME, ZZ4_MUN AS MUNICIPIO,"
	cQuery += " ZZ5_COD AS COD, SUM(ZZ5_QRCAIX) AS CAIX,SUM(ZZ5_QRPESB) AS PESOB,SUM(ZZ5_QRPESO) AS PESO"
	cQuery += " FROM "  + RetSqlTab("ZZ4") + ", " + RetSqlTab("ZZ5")
	cQuery += " WHERE " + RetSqlFil("ZZ5")
	cQuery += "  AND  " + RetSqlFil("ZZ4")
	cQuery += "  AND  ZZ4.ZZ4_PRECAR = '" + mv_par01 + "'" 
	cQuery += "  AND  ZZ4.ZZ4_NUM = ZZ5.ZZ5_NUM " 
	cQuery += "  AND  ZZ4.ZZ4_TPOPER <> 'C' " 
	if mv_par03 = 2 .or. empty(mv_par03)
		cQuery += " AND ZZ4.ZZ4_REDIST = '2' "
	else
		cQuery += " AND ZZ4.ZZ4_REDIST = '1' "
	endif
	cQuery += "  AND  " + RetSqlDel("ZZ4")
	cQuery += "  AND  " + RetSqlDel("ZZ5")
	cQuery += " GROUP BY ZZ4.ZZ4_PRECAR, ZZ4.ZZ4_CODCLI, ZZ4.ZZ4_NOME, ZZ4.ZZ4_MUN, ZZ5.ZZ5_COD"
	cQuery += " ORDER BY ZZ4.ZZ4_CODCLI, ZZ4.ZZ4_NOME, ZZ4.ZZ4_PRECAR, ZZ4.ZZ4_MUN, ZZ5.ZZ5_COD"

	cQuery := ChangeQuery(cQuery)

	If Select("CAR") != 0
		CAR->(dbCloseArea())
	Endif

	If nLastKey == 27
		Return
	Endif

	TCQUERY cQuery NEW ALIAS "CAR"

	//	* Mostrar a consulta */
	//@ 116,090 To 416,707 Dialog oDlgMemo Title "Consulta"
	//@ 055,005 Get cQuery Size 250,080 MEMO Object oMemo
	//Activate Dialog oDlgMemo

	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Monta a interface padrao com o usuario...                           ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ

	SetDefault(aReturn,'ZZ3')


	nTipo := If(aReturn[4]==1,15,18)

	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Processamento. RPTSTATUS monta janela com a regua de processamento. ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ

	RptStatus({|| RunReport(Cabec1,Cabec2,Titulo,nLin) },Titulo)
Return

Static Function RunReport(Cabec1,Cabec2,Titulo,nLin)

	Local nOrdem

	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ SETREGUA -> Indica quantos registros serao processados para a regua ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ

	CAR->(dbGoTop())

	CAR->(SetRegua(RecCount()))

	nCarga := ' '
	_nCLI   := ' '
	TotCaix  := 0      // Acumula por Cliente
	TotPeso  := 0      // Acumula por Cliente
	TotPesoB := 0      // Acumula por Cliente

	TotCaixF  := 0     // Acumula Total
	TotPesoF  := 0     // Acumula Total
	TotPesoBF := 0     // Acumula Total

	Cabec(Titulo,Cabec1,Cabec2,NomeProg,Tamanho,nTipo)
	nLin := 9

	While CAR->(!EOF())

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

			// Dados so Pre-Carregamento

			@nLin,01 PSAY 'Nº.Carreg.:' + CAR->NUM
			ZZ3->(dbsetorder(2))
			ZZ3->(DBSeek(xfilial('ZZ3')+alltrim(CAR->NUM)))
			@nlin,20 PSAY 'Placa:' + ZZ3->ZZ3_PLACA
			@nlin,34 PSAY 'Dt.Carreg.:' + dtoc(ZZ3->ZZ3_DTCAR)
			@nlin,55 PSAY 'Obs:' + substr(ZZ3->ZZ3_OBS,0,23)

			// Fim dos Dados do Pre-Carregamento

			nlin++

			@nLin,01 PSAY replicate('-',80)

			//seleção de status
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
			endcase       //Ver do caminhão                                       // se caminhão não saiu

			dbSelectArea("SZT")
			SZT->(dbSetOrder(3))
			if SZT->(Dbseek(xfilial('SZT')+alltrim(mv_par02)))

				//  colocar pesos da carga conforme parametro

				if !empty(mv_par02) .and. alltrim(SZT->ZT_PLACA) == alltrim(ZZ3->ZZ3_PLACA)
					nlin++
					if !empty(SZT->ZT_PESOE)
						@nlin,10 PSAY 'Peso Inicial:'
						@nlin,23 PSAY SZT->ZT_PESOE	picture '@E 999,999.99'
					endif
					if !empty(SZT->ZT_PESOS)
						@nlin,40 PSAY 'Peso Final:'
						@nlin,55 PSAY SZT->ZT_PESOS	picture '@E 999,999.99'

					endif
					nLin++
					@nlin,10 PSAY 'Peso Liquido do Balancao:'
					_liqBalancao := SZT->ZT_PESOS - SZT->ZT_PESOE
					@nlin,51 PSAY _liqBalancao picture '@E 999,999.99'

				endif
			endif

			nLin++

			@nLin,01 PSAY replicate('-',80)

			nCarga := CAR->NUM
		endif

		If nLin > 59  // Salto de Página. Neste caso o formulario tem 55 linhas...
			Cabec(Titulo,Cabec1,Cabec2,NomeProg,Tamanho,nTipo)
			nLin := 9
		Endif

		// Identificação dos Produtos
		_cGrupo := fBuscaCPO('SB1',1,xfilial('SB1')+CAR->COD,'B1_GRUPO')
		_cSegum := fBuscaCPO('SB1',1,xfilial('SB1')+CAR->COD,'B1_SEGUM')
		_cDescri = fBuscaCPO('SB1',1,xfilial('SB1')+CAR->COD,'B1_DESCRED')
		// Fim identificação dos Produtos

		// Verificação de Cliente a Cliente
		if mv_par03 = 1
			if _nCLI != CAR->NOME
				nlin++
				@nlin,01 PSAY CAR->NOME 
				@nlin,58 PSAY CAR->MUNICIPIO
				nlin++
				_nCLI := CAR->NOME
			endif
		endif
		// Fim da verificação de Cilente a Cliente	

		@nlin,02 PSAY substr(CAR->COD,1,6)

		// Verificação dos Produtos Carregados
		if (_cGrupo >= '6000'.and. _cGrupo <= '6999') .or. (_cGrupo >= '8000'.and. _cGrupo <='8999')       //Terceiros
			_cDesc := substr(_cDescri,1,20)
			_cDesc	+="    (T)"
			@nlin,12 PSAY _cDesc
		else
			@nlin,12 PSAY substr(_cDescri,1,20)
		endif

		@nlin,42 PSAY transform(CAR->CAIX,  '@E 999')

		TotCaix += CAR->CAIX    // Acumula por Cliente
		TotPeso += CAR->PESO    // Acumula por Cliente

		TotCaixF += CAR->CAIX   // Acumula Total
		TotPesoF += CAR->PESO   // Acumula Total


		do case
			case (_cGrupo >= '6000'.and. _cGrupo <= '6999') .or. (_cGrupo >= '8000'.and. _cGrupo <='8999') ;      //Terceiros
			.and. _cSegum = 'CX'
			@nlin,51 PSAY transform(CAR->PESO, '@E 999,999.99')
			TotPesoB += CAR->PESO    // Acumula por Cliente
			TotPesoBF += CAR->PESO    //Acumula Total
			case (_cGrupo < '6000' .or. _cGrupo > '6999') .and. (_cGrupo < '8000'.or. _cGrupo < '8999') ;
			.and. _cSegum = 'PC'
			@nlin,51 PSAY transform(CAR->PESO, '@E 999,999.99')
			TotPesoB += CAR->PESO   // Acumula por Cliente
			TotPesoBF += CAR->PESO  // Acumula Toatal
			case (_cGrupo < '6000' .or. _cGrupo > '6999') .and. (_cGrupo < '8000'.or. _cGrupo < '8999') ;
			.and. _cSegum = 'CX'
			@nlin,51 PSAY transform(CAR->PESOB, '@E 999,999.99')
			TotPesoB += CAR->PESOB    // Acumula por Cliente
			TotPesoBF += CAR->PESOB   // Acumula Total
		endcase
		// Fim da Verificação dos Produtos Carregados

		@nlin,68 psay transform(CAR->PESO,  '@E 999,999.99')


		nLin++ // Avanca a linha de impressao


		CAR->(dbSkip()) // Avanca o ponteiro do registro no arquivo

		if _nCLI != CAR->NOME .or. CAR->(eof())		
			@nlin,32 psay '*Total->'              
			@nlin,42 psay transform(TotCaix,  '@E 999')
			@nlin,51 psay transform(TotPesoB, '@E 999,999.99')
			@nlin,68 psay transform(TotPeso, '@E 999,999.99')        


			TotCaix  := 0
			TotPeso  := 0
			TotPesoB := 0

			nLin++

			@nLin,01 PSAY replicate('_',80)

		endif
	EndDo

	If nLin > 59  // Sal to de Página. Neste caso o formulario tem 55 linhas...
		Cabec(Titulo,Cabec1,Cabec2,NomeProg,Tamanho,nTipo)
		nLin := 9
	Endif

	nLin++  // mexi

	// Acumulados Finais
	@nlin,02 PSAY 'TOTAIS:'
	@nlin,42 PSAY transform(TotCaixF,  '@E 999')
	@nlin,51 PSAY transform(TotPesoBF, '@E 999,999.99')
	@nlin,68 PSAY transform(TotPesoF,  '@E 999,999.99')
	// Fim acumulados Finais


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

