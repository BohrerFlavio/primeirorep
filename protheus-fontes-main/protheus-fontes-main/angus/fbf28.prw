#INCLUDE "rwmake.ch"
#INCLUDE "topconn.ch"

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³FBF28    ºFlavio Bohrer        			º Data ³  30/11/10  º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDescricao ³ Relatorio de Resumo de Carga                               º±±
±±º          ³                                                            º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ Específico Dos Certificadores Angus			                 º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/

User Function FBF28()


	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Declaracao de Variaveis                                             ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ

	Local cDesc1        := "Este programa tem como objetivo imprimir relatorio    "
	Local cDesc2        := "de resumo de carga,discriminando apenas as quantidades"
	Local cDesc3        := "dos produtos em cada carregamento.                    "
	Local cPict         := ""
	Local titulo        := "RESUMO DE CARGA Angus"
	Local nLin          := 80

	Local Cabec1        := " Numero    Placa      Dt.Carreg.   Observacao                  Responsavel"
	Local Cabec2        := "                Codigo             Produto                                          Quant.                Peso"
	Local imprime       := .T.
	Local aOrd := {}
	Private lEnd         := .F.
	Private lAbortPrint  := .F.
	Private CbTxt        := ""
	Private limite           := 132
	Private tamanho          := "M"
	Private nomeprog         := "FBF28" // Coloque aqui o nome do programa para impressao no cabecalho
	Private nTipo            := 18
	Private aReturn          := { "Zebrado", 1, "Administracao", 2, 2, 1, "", 1}
	Private nLastKey         := 0
	Private cPerg      := "FBF28"
	Private cbtxt      := Space(10)
	Private cbcont     := 00
	Private CONTFL     := 01
	Private m_pag      := 01
	Private wnrel      := "FBF28" // Coloque aqui o nome do arquivo usado para impressao em disco    
	Private TotCaix    := 0.00
	Private TotPeso    := 0.00

	pergunte(cPerg,.F.)

	wnrel := SetPrint('ZZ3',NomeProg,cPerg,@titulo,cDesc1,cDesc2,cDesc3,.T.,aOrd,.T.,Tamanho,,.T.)

	//para verificação se existe previsao de pesagem
	cQuery := " SELECT BM_FILIAL,ZZ3_NUM AS NUM, BM_FARM AS FARM, B1_SEGUM AS SEGUM,ZZ5_COD AS COD,"
	cQuery += " SUM(ZZ5_QPCAIX)AS CAIX,SUM(ZZ5_QPPESO)AS PESO "   

	cQuery += " FROM " + RetSqlName("ZZ4") + " ZZ4 INNER JOIN " + RetSqlName("ZZ3") + " ZZ3 ON (ZZ3.ZZ3_NUM = ZZ4.ZZ4_PRECAR "  
	cQuery +=                                                               " AND ZZ3.D_E_L_E_T_ <> '*' " 
	cquery +=                                                               " AND ZZ3.ZZ3_FILIAL = '" + xFilial("ZZ3") + "'" 
	cQuery +=                                                               " AND  (ZZ3.ZZ3_NUM BETWEEN '" + mv_par01 + "' AND '" + mv_par02 + "')"
	cQuery +=   																				" AND  (ZZ3.ZZ3_DTCAR BETWEEN '" + DTOS(mv_par03) + "' AND '" + DTOS(mv_par04) + "')"
	cQuery +=  																					" AND ZZ4.D_E_L_E_T_ <> '*' AND ZZ4.ZZ4_FILIAL = '" + xFilial("ZZ4") + "')" 
	cQuery +=                                "     INNER JOIN " + RetSqlName("ZZ5") + " ZZ5 ON (ZZ4.ZZ4_NUM = ZZ5.ZZ5_NUM " 
	cQuery +=                                                               " AND ZZ5.D_E_L_E_T_ <> '*' "    
	cQuery +=                                                               " AND ZZ5.ZZ5_FILIAL = '" + xFilial("ZZ5") + "')"
	cQuery +=                                "     INNER JOIN " + RetSqlName("SB1") + " SB1 ON (ZZ5.ZZ5_COD = SB1.B1_COD " 
	cQuery +=                                                               " AND  SB1.D_E_L_E_T_ <> '*' " 
	cQuery +=                                                               " AND  SB1.B1_MSBLQL = '2' "
	cQuery +=                                                               " AND  SB1.B1_TIPO IN('PA','PR') " 
	cQuery +=                                                               " AND (B1_FAM = '016' OR B1_FAM = '017')"
	cQuery +=                                                               " AND  SB1.B1_FILIAL = '" + xFilial("SB1") + "')
	cQuery +=                                "     INNER JOIN " + RetSqlName("SBM") + " SBM ON (SB1.B1_GRUPO  = SBM.BM_GRUPO "  
	cQuery +=                                                               " AND  SBM.D_E_L_E_T_ <> '*' " 
	cQuery +=                                                               " AND  SBM.BM_FILIAL = '" + xFilial("SBM") + "')"

	cQuery += " GROUP BY SBM.BM_FILIAL,ZZ3.ZZ3_NUM,SBM.BM_FARM,SB1.B1_SEGUM,ZZ5.ZZ5_COD"   
	cQuery += " ORDER BY SBM.BM_FILIAL,ZZ3.ZZ3_NUM,SBM.BM_FARM,SB1.B1_SEGUM,ZZ5.ZZ5_COD"

	cQuery := ChangeQuery(cQuery)

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

	Local nOrdem

	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ SETREGUA -> Indica quantos registros serao processados para a regua ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ

	CAR->(SetRegua(RecCount()))

	CAR->(dbGoTop())

	nCarga := ' '
	cArm   := ' ' 
	cSeg   := ' '

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

			If nLin > 75 // Salto de Página. Neste caso o formulario tem 55 linhas...
				Cabec(Titulo,Cabec1,Cabec2,NomeProg,Tamanho,nTipo)
				nLin := 9
			Endif  

			@nLin,01 PSAY CAR->NUM
			ZZ3->(dbsetorder(2))
			ZZ3->(DBSeek(xfilial('ZZ3')+alltrim(CAR->NUM)))
			@nlin,11 PSAY ZZ3->ZZ3_PLACA
			@nlin,22 PSAY ZZ3->ZZ3_DTCAR
			@nlin,35 PSAY ZZ3->ZZ3_OBS
			@nlin,85 PSAY ZZ3->ZZ3_USUAR
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

		if cArm != alltrim(CAR->FARM)
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
			cArm := alltrim(CAR->FARM) 
			nlin++
		endif

		if cSeg != CAR->SEGUM
			@nlin,01 PSAY CAR->SEGUM
			cSeg := CAR->SEGUM 
			nlin++
		endif
		If nLin > 75 // Salto de Página. Neste caso o formulario tem 55 linhas...
			Cabec(Titulo,Cabec1,Cabec2,NomeProg,Tamanho,nTipo)
			nLin := 9
		Endif  

		@nlin,015 PSAY alltrim(CAR->COD)
		@nlin,035 PSAY substr(fBuscaCPO('SB1',1,xfilial('SB1')+CAR->COD,'B1_DESCRED'),1,30)
		@nlin,085 PSAY transform(CAR->CAIX, '@E 9,999')
		@nlin,100 PSAY transform(CAR->PESO, '@E 999,999.99') 

		TotCaix += CAR->CAIX
		TotPeso += CAR->PESO     

		nLin++ // Avanca a linha de impressao

		CAR->(dbSkip()) // Avanca o ponteiro do registro no arquivo 

		if nCarga != CAR->NUM  	
			If nLin > 75 // Salto de Página. Neste caso o formulario tem 55 linhas...
				Cabec(Titulo,Cabec1,Cabec2,NomeProg,Tamanho,nTipo)
				nLin := 9
			Endif  

			nlin++ 
			@nlin,10 PSAY "TOTAL DA CARGA:--------------------->"
			@nlin,50 PSAY transform(TotCaix, '@E 9,999')
			@nlin,60 PSAY transform(TotPeso, '@E 999,999.99') 


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
