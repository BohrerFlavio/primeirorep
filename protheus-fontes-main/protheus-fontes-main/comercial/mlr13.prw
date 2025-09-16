#INCLUDE "rwmake.ch"
#INCLUDE "topconn.ch"

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³MLR13    º Autor ³ Mauricio Roehrs		Data 06/05/2013     º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDescricao ³ Relatorio de Resumo Sintético de Cargas                    º±±
±±º          ³                                                            º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ Comercial(SIGAOMS)-Expedições(SIGAPCP)                     º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/ 


User Function MLR13()


	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Declaracao de Variaveis                                             ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ

	Local cDesc1         := "Este programa tem como objetivo imprimir relatorio"
	Local cDesc2         := "para conferencia de cargas para carregamento"
	Local cDesc3         := " "
	Local cPict          := "vai porra"
	Local titulo         := "RESUMO SINTÉTICO DE CARGAS"
	Local Cabec1         := "                    Produto                  Descr. do Produto                            Qnt. Caixas             Peso "
	Local Cabec2         := ""
	Local imprime         := .T.
	Local aOrd            := {}  
	Private nLin          := 80
	Private lEnd          := .F.
	Private lAbortPrint   := .F.
	Private CbTxt         := ""
	Private limite        := 80
	Private tamanho       := "M"
	Private nomeprog      := "MLR13" // Coloque aqui o nome do programa para impressao no cabecalho
	Private nTipo         := 18
	Private aReturn       := { "Zebrado", 1, "Administracao", 2, 2, 1, "", 1}
	Private nLastKey      := 0
	Private cPerg   		 := "MLR13"
	Private cbtxt      	 := Space(10)
	Private cbcont     := 00
	Private CONTFL     := 01
	Private m_pag      := 01
	Private wnrel      := "MLR13" // Coloque aqui o nome do arquivo usado para impressao em disco    
	Private _nTOTAL    := 0.00
	pergunte(cPerg,.F.)

	wnrel := SetPrint('ZZ5',NomeProg,cPerg,@titulo,cDesc1,cDesc2,cDesc3,.T.,aOrd,.T.,Tamanho,,.T.)  

	_cQuery := " SELECT  ZZ5_COD AS COD, ZZ5_DESC AS PROD, BM_FARM AS FARM, SUM(ZZ5_QPCAIX - ZZ5_QRCAIX) AS CAIXA, SUM(ZZ5_QPPESO - ZZ5_QRPESO) AS PESO"
	_cQuery += " FROM " + RetSQLTab('ZZ5') + ", " + RetSQLTab('ZZ4') + ", " + RetSQLTab('SB1') + ", " + RetSQLTab('SBM')
	_cQuery += " WHERE" + RetSQLFil('ZZ5') + " AND " + RetSQLFil('ZZ4') + " AND " + RetSQLFil('SB1') + " AND " + RetSQLFil('SBM') + " AND"
	_cQuery += " ZZ5_NUM  = ZZ4_NUM  AND ZZ4_STATUS NOT IN('E','F') AND"
	_cQuery += " B1_GRUPO = BM_GRUPO AND"
	_cQuery += " ZZ5_COD  = B1_COD   AND ZZ4_PRECAR <> '' AND"
	_cQuery += " B1_TIPO IN('PA','PR') AND B1_MSBLQL = '2' AND B1_SEGUM = 'CX' AND"
	_cQuery += " ZZ4_DATA BETWEEN '" + DTOS(mv_par01) + "' AND '" + DTOS(mv_par02) + "'"
	_cQuery += " AND " + RetSQLDel('ZZ5') + " AND " + RetSQLDel('ZZ4') + " AND " + RetSQLDel('SB1') + " AND " + RetSQLDel('SBM')
	_cQuery += " GROUP BY BM_FARM, ZZ5_COD, ZZ5_DESC 
	_cQuery += " HAVING SUM(ZZ5_QPCAIX - ZZ5_QRCAIX) >= " + str(mv_par03) "
	_cQuery += " ORDER BY BM_FARM,ZZ5_COD

	_cQuery  := ChangeQuery(_cQuery)

	MsgRun("Aguarde... Realizando contagem de registros...",,{||  GeraTMP() })

	If nLastKey == 27
		Return
	Endif

	SetDefault(aReturn,'SFT')

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

	Cabec(Titulo,Cabec1,Cabec2,NomeProg,Tamanho,nTipo)
	nLin := 9


	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ SETREGUA -> Indica quantos registros serao processados para a regua ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ


	TMP->(SetRegua(RecCount()))

	TMP->(dbGoTop())

	_cFarm := ''

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

		if TMP->PESO <= 0
			TMP->(DbSkip())
			loop
		endif


		if _cFarm <> TMP->FARM
			@nlin,010 psay replicate('-',116)
			if TMP->FARM = 'C'
				nlin++
				@nlin,010 psay "|"
				@nlin,013 psay "Congelado:"
				@nlin,125 psay "|"      	
			endif	
			if TMP->FARM = 'R'
				nlin++            
				@nlin,010 psay "|"   		
				@nlin,013 psay "Resfriado:"
				@nlin,125 psay "|"    		
			endif
			if TMP->FARM = 'S'
				nlin++            
				@nlin,010 psay "|"    		
				@nlin,013 psay "Salgado:"
				@nlin,125 psay "|"    		
			endif
			nlin++
			_cFarm := TMP->FARM
		endif

		@nlin,010 psay "|"
		@nlin,023 psay TMP->COD
		@nlin,045 psay TMP->PROD
		@nlin,090 psay transform(TMP->CAIXA,'@E 999,999')
		@nlin,110 psay transform(TMP->PESO,'@E 999,999.99')		
		@nlin,125 psay "|"		
		nlin++

		TMP->(dbSkip()) // Avanca o ponteiro do registro no arquivo



	EndDo
	@nlin,010 psay replicate('-',116)                                                                                                                            


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
