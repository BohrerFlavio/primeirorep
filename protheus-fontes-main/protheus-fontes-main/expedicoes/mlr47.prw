#INCLUDE "rwmake.ch"
#INCLUDE "topconn.ch"

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³MLR47     ºMauricio Roehrs        º Data ³  12/06/15        º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDescricao ³ Relatorio de Resumo de Carga com quebra por marca          º±±
±±º          ³                                                            º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ Comercial e expedições (SIGAPCP e SIGAOMS)                 º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/

User Function MLR47()


	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Declaracao de Variaveis                                             ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ

	Local cDesc1         := "Este programa tem como objetivo imprimir relatorio    "
	Local cDesc2         := "de resumo de carga,discriminando apenas as quantidades"
	Local cDesc3         := "dos produtos em cada carregamento.                    "
	Local cPict          := ""
	Local titulo         := "RELATORIO DE RESUMO DE CARGA POR MARCA"
	Local nLin           := 80

	Local Cabec1       := space(15) +" Numero   Placa  Dt.Carreg.  Observacao                              Responsavel"
	Local Cabec2       := space(15) +"    Codigo    Produto                          Quant.   Peso  Pr.Inicial  Pr.Final"
	Local imprime      := .T.
	Local aOrd := {}
	Private lEnd         := .F.
	Private lAbortPrint  := .F.
	Private CbTxt        := ""
	Private limite           := 132
	Private tamanho          := "M"
	Private nomeprog         := "MLR47" // Coloque aqui o nome do programa para impressao no cabecalho
	Private nTipo            := 18
	Private aReturn          := { "Zebrado", 1, "Administracao", 2, 2, 1, "", 1}
	Private nLastKey         := 0
	Private cPerg      := "GJF41"
	Private cbtxt      := Space(10)
	Private cbcont     := 00
	Private CONTFL     := 01
	Private m_pag      := 01
	Private wnrel      := "MLR47" // Coloque aqui o nome do arquivo usado para impressao em disco    
	Private TotCaix    := 0.00
	Private TotPeso    := 0.00

	pergunte(cPerg,.F.)

	wnrel := SetPrint('ZZ3',NomeProg,cPerg,@titulo,cDesc1,cDesc2,cDesc3,.T.,aOrd,.T.,Tamanho,,.T.)

	//para verificação se existe previsao de pesagem
	cQuery := " SELECT BM_FILIAL,ZZ3_NUM AS NUM, BM_FARM AS FARM, B1_SEGUM AS SEGUM,ZZ5_COD AS COD,ZZ5_DTPFIM AS DTPFIM, ZZ5_DTPINI AS DTPINI,"
	cQuery += " SUM(ZZ5_QPCAIX)AS CAIX,SUM(ZZ5_QPPESO)AS PESO, ZZ4_MARCA AS MARCA, ZZ4_CODCLI AS CODCLI, ZZ4_LOJA AS LOJA, ZZ4_NOME AS NOME  "   

	cQuery += " FROM " + RetSqlName("ZZ4") + " ZZ4 INNER JOIN " + RetSqlName("ZZ3") + " ZZ3 ON (ZZ3.ZZ3_NUM = ZZ4.ZZ4_PRECAR "  
	cQuery +=                                       " AND ZZ3.D_E_L_E_T_ <> '*' " 
	cquery +=                                       " AND ZZ3.ZZ3_FILIAL = '" + xFilial("ZZ3") + "'" 
	cQuery +=                                       " AND  (ZZ3.ZZ3_NUM BETWEEN '" + mv_par01 + "' AND '" + mv_par02 + "') "
	cQuery +=                                       " AND  (ZZ3.ZZ3_DTCAR BETWEEN '" + dtos(mv_par03) + "' AND '" + dtos(mv_par04) + "')"
	cQuery +=                                       " AND ZZ4.D_E_L_E_T_ <> '*' AND ZZ4.ZZ4_FILIAL = '" + xFilial("ZZ4") + "')" 
	cQuery +=                                "     INNER JOIN " + RetSqlName("ZZ5") + " ZZ5 ON (ZZ4.ZZ4_NUM = ZZ5.ZZ5_NUM " 
	cQuery +=                                       " AND ZZ5.D_E_L_E_T_ <> '*' "    
	cQuery +=                                       " AND ZZ5.ZZ5_FILIAL = '" + xFilial("ZZ5") + "')"
	cQuery +=                                "     INNER JOIN " + RetSqlName("SB1") + " SB1 ON (ZZ5.ZZ5_COD = SB1.B1_COD " 
	cQuery +=                                       " AND  SB1.D_E_L_E_T_ <> '*' " 
	cQuery +=                                       " AND  SB1.B1_MSBLQL = '2' "
	cQuery +=                                       " AND  SB1.B1_TIPO IN('PA','PR') "
	cQuery +=                                       " AND  SB1.B1_FILIAL = '" + xFilial("SB1") + "')
	cQuery +=                                "     INNER JOIN " + RetSqlName("SBM") + " SBM ON (SB1.B1_GRUPO  = SBM.BM_GRUPO "  
	cQuery +=                                iif(mv_Par05 = 1," AND SBM.BM_PORC = 'S' ",iif(mv_par05 = 2," AND SBM.BM_PORC <> 'S'"," "))
	cQuery +=                                       " AND  SBM.D_E_L_E_T_ <> '*' " 
	cQuery +=                                       " AND  SBM.BM_FILIAL = '" + xFilial("SBM") + "')"

	cQuery += " GROUP BY SBM.BM_FILIAL,ZZ3.ZZ3_NUM,SBM.BM_FARM,ZZ4.ZZ4_MARCA,ZZ4.ZZ4_CODCLI,ZZ4.ZZ4_LOJA,ZZ4.ZZ4_NOME,SB1.B1_SEGUM,ZZ5.ZZ5_COD,ZZ5.ZZ5_DTPINI,ZZ5.ZZ5_DTPFIM"   
	cQuery += " ORDER BY SBM.BM_FILIAL,ZZ3.ZZ3_NUM,SBM.BM_FARM,ZZ4.ZZ4_MARCA,ZZ4.ZZ4_CODCLI,ZZ4.ZZ4_LOJA,ZZ4.ZZ4_NOME,SB1.B1_SEGUM,ZZ5.ZZ5_COD,ZZ5.ZZ5_DTPINI,ZZ5.ZZ5_DTPFIM"

	cQuery := ChangeQuery(cQuery)

	//	* Mostrar a consulta */
	//@ 116,090 To 416,707 Dialog oDlgMemo Title "Consulta"
	//@ 055,005 Get cQuery Size 250,080 MEMO Object oMemo
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

	Local nOrdem

	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ SETREGUA -> Indica quantos registros serao processados para a regua ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ

	CAR->(SetRegua(RecCount()))

	CAR->(dbGoTop())

	nCarga   := ' '
	cArm     := ' ' 
	cSeg     := ' '
	cMarca   := ' '
	nQuebra  := 73
	_nBranco := 18
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
			ZZ3->(DBSeek(xfilial('ZZ3')+alltrim(CAR->NUM)))
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

		if cMarca != alltrim(CAR->MARCA) 
			nlin++
			@nlin,01+_nBranco PSAY 'Marca: ' + iif(!empty(alltrim(CAR->MARCA)),alltrim(CAR->MARCA),'SEM MARCA') + " " + CAR->CODCLI+ "-" + CAR->LOJA + ": " +  CAR->NOME
			nlin++
			cMarca := alltrim(CAR->MARCA)	
		endif	

		if cSeg != CAR->SEGUM
			@nlin,01+_nBranco PSAY CAR->SEGUM
			cSeg := CAR->SEGUM 
			nlin++
		endif

		If nLin > nQuebra // Salto de Página. Neste caso o formulario tem 55 linhas...
			Cabec(Titulo,Cabec1,Cabec2,NomeProg,Tamanho,nTipo)
			nLin := 9
		Endif  

		@nlin,004+_nBranco PSAY alltrim(CAR->COD)
		@nlin,013+_nBranco PSAY substr(fBuscaCPO('SB1',1,xfilial('SB1')+CAR->COD,'B1_DESCRED'),1,30)
		@nlin,045+_nBranco PSAY transform(CAR->CAIX, '@E 9,999')
		@nlin,051+_nBranco PSAY transform(CAR->PESO, '@E 999,999.99') 
		@nlin,063+_nBranco PSAY STOD(CAR->DTPINI) 
		@nlin,073+_nBranco PSAY STOD(CAR->DTPFIM) 
		TotCaix += CAR->CAIX
		TotPeso += CAR->PESO     

		nLin++ // Avanca a linha de impressao

		CAR->(dbSkip()) // Avanca o ponteiro do registro no arquivo 

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
			//nLin := 9    

			ZZ4->(dbsetorder(1))
			ZZ4->(dbseek(xfilial('ZZ4')+nCarga))
			while ZZ4->(!eof()) .and. ZZ4->ZZ4_FILIAL = xfilial('ZZ4') .and. nCarga = ZZ4->ZZ4_PRECAR 
				ZZ5->(dbsetorder(1))
				ZZ5->(dbseek(xfilial('ZZ5')+ZZ4->ZZ4_NUM))
				while ZZ5->(!eof()) .and. ZZ5->ZZ5_FILIAL = xfilial('ZZ5') .and. ZZ5->ZZ5_NUM = ZZ4->ZZ4_NUM 

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
			//@nlin,01 psay replicate('-',132)
			//nlin++
			Cabec(Titulo,Cabec1,Cabec2,NomeProg,Tamanho,nTipo)
			nLin := 9
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



