#INCLUDE "rwmake.ch"
#INCLUDE "topconn.ch"

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³MLR11    º Autor ³ Mauricio Roehrs  Data ³ 23/04/2013       º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDescricao ³ Relatorio de Faturamento por Cliente/Produto               º±±
±±º          ³                                                            º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ Comercial								                          º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/

User Function MLR11b()


	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Declaracao de Variaveis                                             ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ

	Local cDesc1          := "Este programa tem como objetivo imprimir relatorio"
	Local cDesc2          := "para conferencia do Faturamento por Cliente/Produto"
	Local cDesc3          := ""
	Local cPict           := "xxxxxxxxx"
	Local titulo          := "RELATORIO DE CONF. DE FATURAMENTO POR CLIENTE/PRODUTO"
	Local Cabec1          := "Estado                Prod.                Cliente                  Peso           Valor          Rapel       Comiss        Frete"
	Local Cabec2          := "Cod. Cliente                                                        (Kg)            (R$)          (R$)         (R$)          (R$)"                   
	Local imprime         := .T.
	Local aOrd            := {}  
	Private nLin          := 80
	Private lEnd          := .F.
	Private lAbortPrint   := .F.
	Private CbTxt         := ""
	Private limite        := 80
	Private tamanho       := "M"
	Private nomeprog      := "MLR11b" // Coloque aqui o nome do programa para impressao no cabecalho
	Private nTipo         := 18
	Private aReturn       := { "Zebrado", 1, "Administracao", 2, 2, 1, "", 1}
	Private nLastKey      := 0
	Private cPerg   		 := "MLR11"
	Private cbtxt      	 := Space(10)
	Private cbcont        := 00
	Private CONTFL        := 01
	Private m_pag         := 01
	Private wnrel         := "MLR11b" // Coloque aqui o nome do arquivo usado para impressao em disco    
	Private _nTOTAL       := 0.00

	pergunte(cPerg,.F.)

	wnrel := SetPrint('SD2',NomeProg,cPerg,@titulo,cDesc1,cDesc2,cDesc3,.T.,aOrd,.T.,Tamanho,,.T.)  


	If nLastKey == 27
		Return
	Endif

	SetDefault(aReturn,'SD2')

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

	SA1->(SetRegua(RecCount()))
	DbSelectArea('SA1')

	_cEst    := ''
	_cCli    := ''
	_cLoj    := ''
	_cDCli   := ''
	_nGeralTot := 0 //valor total faturado
	_nGeralPes := 0 //peso total faturado
	_nTotGerDev  := 0 //valor total faturado deduzindo devolução
	_nPesoGerDev := 0 //peso total faturado deduzindo devolução
	_nPesCli := 0
	_nTotCli := 0
	_nTotLoj := 0
	_nPesLoj := 0
	_nDevPesLoj := 0 //Devoluções em Peso da Loja
	_nDevTotLoj := 0 //Devoluções em Valor da Loja
	_nDevPesCli := 0 //Devoluções em Peso do Cliente          
	_nDevTotCli := 0 //Devoluções em Valor do Cliente
	_nTotDevPesLoj := 0 //Peso Total deduzindo Devoluções da Loja
	_nTotDevTotLoj := 0 //Valor Total deduzindo Devoluções da Loja
	_nTotDevPesCli := 0 //Peso Total deduzindo Devoluções do Cliente
	_nTotDevTotCli := 0 //Valor Total deduzindo Devoluções do Cliente
	_nAcumTot := 0
	_nAcumPes := 0 
	_nRapel := 0
	_nComis := 0
	_nFrete := 0

	TrataCli()

	While CLI->(!EOF())

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


		TrataFat()//chama função que trata o faturamento
		TrataDev()//chama a função que trata as devoluções

		if FAT->TOTAL <> 0 .or. DEV->TOTAL <> 0

			_cDescCli := fBuscaCPO('SA1',1,xfilial('SA1') + CLI->CLIENTE,'A1_NOME')

			//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
			//³ Quebra por Estado						                                 ³
			//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
			if _cEst <> CLI->EST
				@nlin,00 psay "Estado: " + CLI->EST
				nlin++
				_cEst    := CLI->EST
				_cCli    := ''
				_cLoj    := ''
			endif

			//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
			//³ Quebra por Clientes					                                    ³
			//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
			if _cCli <> CLI->CLIENTE
				@nlin,000 psay replicate('-',132)
				nlin++
				@nlin,001 psay CLI->CLIENTE
				@nlin,030 psay _cDescCli
				@nlin,068 psay "Peso(Kg):"
				@nlin,082 psay "Valor(R$): "
				@nlin,096 psay "Rapel(R$):"
				@nlin,110 psay "Comiss(R$):"
				@nlin,123 psay "Frete(R$):"
				nlin++
				_cCli  := CLI->CLIENTE
				_cLoj  := ''
			endif

			//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
			//³ Quebra por Lojas							                                 ³
			//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
			if _cLoj <> CLI->LOJA
				@nlin,000 psay replicate('-',132)
				nlin++
				@nlin,001 psay "Loja: " + CLI->LOJA
				if mv_par11 = 2 //se for analitico
					@nlin,012 psay '|' + replicate('-',15) + "PRODUTOS FATURADOS" + replicate('-',15) + '|'
				endif
				nlin++
				_cLoj  := CLI->LOJA

				_nDevPesLoj += DEV->PESO   //peso total das devoluções da loja
				_nDevTotLoj += DEV->TOTAL  //valor total das devoluções da loja

				_nDevPesCli += DEV->PESO   //peso total das devoluções do cliente
				_nDevTotCli += DEV->TOTAL  //valor total das devoluções do cliente

			endif

			//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
			//³ Lista de Produtos						                                 ³
			//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
			while FAT->(!eof())
				if mv_par11 = 2	//se for analitico
					If nLin > 70 // Salto de Página. Neste caso o formulario tem 55 linhas...
						Cabec(Titulo,Cabec1,Cabec2,NomeProg,Tamanho,nTipo)
						nLin := 9
					Endif
					_cDescPro := fBuscaCPO('SB1',1,xfilial('SB1') + FAT->PROD,'B1_DESC')
					//	@nlin,005 psay " | "
					@nlin,003 psay alltrim(FAT->PROD)
					@nlin,011 psay " | "
					@nlin,017 psay substr(_cDescPro,1,35)
					@nlin,060 psay " | "
					@nlin,064 psay Transform(FAT->PESO,'@E 999,999.99') + " | "
					@nlin,080 psay Transform(FAT->TOTAL,'@E 999,999.99')  + " | "
					_nRapel := (FAT->TOTAL * (CLI->RAPEL/100))
					@nlin,094 psay transform(_nRapel,'@E 999,999.99') + " | "  
					_nComis := (FAT->TOTAL - _nRapel) * (CLI->COMIS/100)
					@nlin,108 psay transform(_nComis,'@E 999,999.99') + " | "
					_nZ4frete := fBuscaCpo('ZZ4',2,xFilial('ZZ4') + FAT->PREPED,'ZZ4_VFRETE')				    
					_nFrete := FAT->PESO * _nZ4frete
					@nlin,122 psay transform(_nFrete,'@E 999,999.99') + " | "
					nlin++
				endif

				_nGeralTot += FAT->TOTAL //Valor total faturado
				_nGeralPes += FAT->PESO  //Peso total faturado

				_nTotCli += FAT->TOTAL //Valor Total faturado do Cliente
				_nPesCli += FAT->PESO  //Peso Total faturado do Cliente

				_nTotLoj += FAT->TOTAL //Valor Total faturado da Loja
				_nPesLoj += FAT->PESO  //Peso Total faturado da Loja

				FAT->(DbSkip())
			enddo
		endif
		CLI->(dbSkip()) // Avanca o ponteiro do registro no arquivo

		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³ Totalizador da Loja						                                 ³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		if (_cLoj <> CLI->LOJA .or. _cCli <> CLI->CLIENTE) .or. CLI->(eof())
			_nTotDevPesLoj := _nPesLoj - _nDevPesLoj //calculo para deduzir as devoluções em peso da loja
			_nTotDevTotLoj := _nTotLoj - _nDevTotLoj //calculo para deduzir as devoluções em valor da loja

			if _nTotDevPesLoj <> 0 .and. _nTotDevTotLoj <> 0     
				if mv_par11 = 2 //se for analitico
					@nlin,012 psay '|' + replicate('-',15) + "PRODUTOS FATURADOS" + replicate('-',15) + '|'
				endif
				nlin++
				@nlin,004 psay "Total Faturado da Loja --------> "
				@nlin,060 psay transform(_nPesLoj,'@E 999,999,999.99')
				@nlin,075 psay transform(_nTotLoj,'@E 999,999,999.99')
				nlin++
				@nlin,004 psay "Total de Devoluções da Loja --------> "
				@nlin,060 psay transform(_nDevPesLoj,'@E 999,999,999.99')
				@nlin,075 psay transform(_nDevTotLoj,'@E 999,999,999.99')
				nlin++
				@nlin,004 psay "Total Liquido da Loja ------------------> "
				@nlin,060 psay transform(_nTotDevPesLoj,'@E 999,999,999.99')
				@nlin,075 psay transform(_nTotDevTotLoj,'@E 999,999,999.99')
				nlin++
			endif
			_nTotLoj 		:= 0 //Valor total Faturado da Loja
			_nPesLoj 		:= 0 //Peso total faturado da loja
			_nDevPesLoj 	:= 0 //Peso das devoluções da loja
			_nDevTotLoj 	:= 0 //Valor das devoluções da loja
			_nTotDevPesLoj := 0 //Peso total deduzindo devolução da loja
			_nTotDevTotLoj := 0 //Valor total deduzindo devolução da loja
		endif

		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³ Totalizador do Cliente					                                 ³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ

		if (_cCli <> CLI->CLIENTE .or. CLI->EST<>_cEst) .or. CLI->(eof())
			_nTotDevPesCli := _nPesCli - _nDevPesCli //calculo para deduzir as devoluções em peso do cliente
			_nTotDevTotCli := _nTotCli - _nDevTotCli //caculo para deduzir as devoluções em valor do cliente

			_nAcumTot += _nDevTotCli //acumula os valores de devolução
			_nAcumPes += _nDevPesCli //acumula os pesos de devolução		

			if _nTotDevPesCli <> 0  .and. _nTotDevTotCli <> 0
				nlin++
				@nlin,004 psay "Total Faturado do Cliente -----------> "
				@nlin,060 psay transform(_nPesCli,'@E 999,999,999.99')
				@nlin,075 psay transform(_nTotCli,'@E 999,999,999.99')
				nlin++
				@nlin,004 psay "Total de Devoluções do Cliente --------> "
				@nlin,060 psay transform(_nDevPesCli,'@E 999,999,999.99')
				@nlin,075 psay transform(_nDevTotCli,'@E 999,999,999.99')
				nlin++
				@nlin,004 psay "Total Liquido do Cliente ------------------> "
				@nlin,060 psay transform(_nTotDevPesCli,'@E 999,999,999.99')
				@nlin,075 psay transform(_nTotDevTotCli,'@E 999,999,999.99')
				nlin++
			endif
			_nTotCli	 		:= 0 //Valor total faturado do cliente
			_nPesCli 		:= 0 //Peso total faturado do cliente
			_nDevTotCli 	:= 0 //Valor das devoluções do cliente
			_nDevPesCli 	:= 0 //Peso das devoluções do cliente
			_nTotDevPesCli := 0 //Peso total deduzindo devolução do cliente
			_nTotDevTotCli := 0 //Valor total deduzindo devolução do cliente
		endif

	EndDo

	_nTotGerDev   := _nGeralTot - _nAcumTot //Valor Total Geral Faturado deduzindo Devoluções
	_nPesoGerDev  := _nGeralPes - _nAcumPes  //Peso Total Geral faturado deduzindo Devoluções
	nlin++

	If nLin+4 > 70 // Salto de Página. Neste caso o formulario tem 55 linhas...
		Cabec(Titulo,Cabec1,Cabec2,NomeProg,Tamanho,nTipo)
		nLin := 9
	Endif

	@nlin,000 psay replicate('-',132)			
	nlin++
	@nlin,004 psay "Total Bruto Faturado ------------------> "
	@nlin,060 psay transform(_nGeralPes,'@E 999,999,999.99')
	@nlin,075 psay transform(_nGeralTot,'@E 999,999,999.99')
	nlin++														 
	@nlin,004 psay "Total Liquido Faturado -------------------> "
	@nlin,060 psay transform(_nPesoGerDev,'@E 999,999,999.99')
	@nlin,075 psay transform(_nTotGerDev,'@E 999,999,999.99')
	nlin++																		                                                                                                                             	
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

	If Select("TMP") != 0
		TMP->(dbCloseArea())
	Endif

	TCQUERY _cQuery NEW ALIAS "TMP"

return

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Função que trata os Faturamentos	                                 ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
Static Function TrataFat()

	_cQuery := " SELECT D2_COD AS PROD, SUM(D2_QUANT) AS PESO, SUM(D2_TOTAL) AS TOTAL,D2_PREPED AS PREPED
	_cQuery += " FROM "  + RetSQLTab('SD2') + ", " + RetSQLTab('SF4') + ", " + RetSQLTab('SA1') + ", " + RetSQLTab('SF2') 
	_cQuery += " WHERE " + RetSQLFil('SD2') + " AND " + RetSQLFil('SA1') + " AND " + RetSQLFil('SF4') + " AND " + RetSQLFil('SF2') + " AND"
	_cQuery += " D2_CLIENTE = A1_COD     AND   F2_CLIENTE = D2_CLIENTE AND"
	_cQuery += " D2_LOJA    = A1_LOJA    AND   F2_LOJA    = D2_LOJA    AND"
	_cQuery += " D2_EST     = A1_EST     AND   F2_DOC     = D2_DOC     AND"
	_cQuery += " D2_TES     = F4_CODIGO  AND   F2_SERIE   = D2_SERIE   AND"
	_cQuery += " F4_TIPO = 'S' AND F4_DUPLIC = 'S' AND"
	_cQuery += " D2_EMISSAO BETWEEN '" + DTOS(mv_par01) + "' AND '" + DTOS(mv_par02) + "' AND"
	_cQuery += " A1_COD  = 	   '" + CLI->CLIENTE + "' AND"
	_cQuery += " A1_LOJA =     '" + CLI->LOJA    + "' AND"
	_cQuery += " A1_EST  =     '" + CLI->EST     + "' AND"
	_cQuery += " D2_COD BETWEEN  '" + mv_par09 + "' AND '" + mv_par10 + "'"
	_cQuery += " AND " + RetSQLDel('SD2') + " AND " + RetSQLDel('SA1') + " AND " + RetSQLDel('SF4') + " AND " + RetSQLDel('SF2') 
	_cQuery += " GROUP BY  D2_COD,D2_PREPED"

	_cQuery  := ChangeQuery(_cQuery)

	//	* Mostrar a consulta */
	//@ 116,090 To 416,707 Dialog oDlgMemo Title "Consulta"
	//@ 055,005 Get _cQuery Size 250,080 MEMO Object oMemo
	//Activate Dialog oDlgMemo

	If Select("FAT") != 0
		FAT->(dbCloseArea())
	Endif

	TCQUERY _cQuery NEW ALIAS "FAT"
return

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Função que trata as Devoluções		                                 ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
Static Function TrataDev()

	_cQuery2 := " SELECT SUM(D1_QUANT) AS PESO, SUM(D1_TOTAL) AS TOTAL
	_cQuery2 += " FROM " + RetSQLTab('SD1') + "," + RetSQLTab('SA1') + ", " + RetSQLTab('SF4') + ", " + RetSQLTab('SF1')
	_cQuery2 += " WHERE " + RetSQLFil('SD1') + " AND " + RetSQLFil('SA1') + " AND " + RetSQLFil('SF4') + " AND " + RetSQLFil('SF1') + " AND"
	_cQuery2 += " A1_COD     = D1_FORNECE AND"
	_cQuery2 += " A1_LOJA    = D1_LOJA    AND"
	_cQuery2 += " F1_DOC     = D1_DOC     AND"
	_cQuery2 += " F1_SERIE   = D1_SERIE   AND"
	_cQuery2 += " F1_FORNECE = D1_FORNECE AND"
	_cQuery2 += " F1_LOJA	 = D1_LOJA    AND"
	_cQuery2 += " D1_TES     = F4_CODIGO  AND"
	_cQuery2 += " F4_TIPO = 'E' AND F4_DUPLIC = 'S' AND F1_TIPO = 'D' AND"  
	_cQuery2 += " D1_FORNECE = '" + CLI->CLIENTE + "' AND"
	_cQuery2 += " D1_LOJA    = '" + CLI->LOJA    + "' AND"
	_cQuery2 += " D1_NFORI  <> '' AND D1_SERIORI <> '' AND" 
	_cQuery2 += " D1_DTDIGIT BETWEEN '" + DTOS(mv_par01) + "' AND '" + DTOS(mv_par02) + "' AND"
	_cQuery2 += " D1_COD BETWEEN  '" + mv_par09 + "' AND '" + mv_par10 + "'"
	_cQuery2 += " AND " + RetSQLDel('SD1') + " AND " + RetSQLDel('SA1') +" AND " + RetSQLDel('SF4') + " AND " + RetSQLDel('SF1')

	_cQuery2  := ChangeQuery(_cQuery2)

	//	* Mostrar a consulta */
	//@ 116,090 To 416,707 Dialog oDlgMemo Title "Consulta"
	//@ 055,005 Get _cQuery2 Size 250,080 MEMO Object oMemo
	//Activate Dialog oDlgMemo 

	If Select("DEV") != 0
		DEV->(dbCloseArea())
	Endif

	TCQUERY _cQuery2 NEW ALIAS "DEV"


return                                                                                                                          

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Função que trata o Cliente    		                                 ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
Static Function TrataCli()

	_cQuery3 := " SELECT A1_COD AS CLIENTE, A1_LOJA AS LOJA, A1_EST AS EST,A1_VEND AS VEND, A1_PRAPEL AS RAPEL, A1_COMIS AS COMIS
	_cQuery3 += " FROM "  + RetSQLTab('SA1')"
	_cQuery3 += " WHERE "  + RetSQLFil('SA1') + " AND"
	_cQuery3 += " A1_COD     BETWEEN '" + mv_par03 + "' AND '" + mv_par04 + "' AND "
	_cQuery3 += " A1_LOJA    BETWEEN '" + mv_par05 + "' AND '" + mv_par06 + "' AND "
	_cQuery3 += " A1_EST     BETWEEN '" + mv_par07 + "' AND '" + mv_par08 + "'"
	_cQuery3 += " AND " + RetSQLDel('SA1') + " AND"   

	if  !empty(mv_par12)                                                              
		_cQuery3 += " A1_VEND = '" + mv_par12 + "' AND " 
	endif

	if !empty(alltrim(mv_par13))
		_cQuery3 += " A1_MUN LIKE '" + mv_par13 + "%' AND "
	endif   

	_cQuery3 += " (( SELECT COUNT(F2_CLIENTE)"
	_cQuery3 += "   FROM "  + RetSQLTab('SF2')
	_cQuery3 += "   WHERE " + RetSQLFil('SF2') + " AND " 
	_cQuery3 += "   F2_CLIENTE = A1_COD     AND"
	_cQuery3 += "   F2_EMISSAO BETWEEN '" + DTOS(mv_par01) + "' AND '" + DTOS(mv_par02) + "'"
	_cQuery3 += "   AND " + RetSQLDel('SF2') + " AND " + RetSQLDel('SA1') + ") > 0 OR "
	_cQuery3 += " ( SELECT COUNT(D1_FORNECE)
	_cQuery3 += "   FROM " + RetSQLTab('SD1') 
	_cQuery3 += "   WHERE " + RetSQLFil('SD1')+ " AND " + RetSQLFil('SA1') + " AND"
	_cQuery3 += " A1_COD     = D1_FORNECE AND"
	_cQuery3 += " D1_NFORI  <> '' AND D1_SERIORI <> '' AND" 
	_cQuery3 += " D1_DTDIGIT BETWEEN '" + DTOS(mv_par01) + "' AND '" + DTOS(mv_par02) + "'"
	_cQuery3 += " AND " + RetSQLDel('SD1') + " AND " +RetSQLDel('SA1') + ") > 0)" 
	_cQuery3 += " GROUP BY A1_EST, A1_COD, A1_LOJA,A1_VEND,A1_PRAPEL,A1_COMIS"
	_cQuery3 += " ORDER BY A1_EST, A1_COD, A1_LOJA"


	_cQuery3  := ChangeQuery(_cQuery3)

	//	* Mostrar a consulta */
	//@ 116,090 To 416,707 Dialog oDlgMemo Title "Consulta"
	//@ 055,005 Get _cQuery3 Size 250,080 MEMO Object oMemo
	//Activate Dialog oDlgMemo 

	If Select("CLI") != 0
		CLI->(dbCloseArea())
	Endif

	TCQUERY _cQuery3 NEW ALIAS "CLI"

return                                                                                                                          


/*
_cQuery := " SELECT D2_COD AS PROD, SUM(D2_QUANT) AS PESO, SUM(D2_TOTAL) AS TOTAL
_cQuery += " FROM "  + RetSQLTab('SD2') + ", " + RetSQLTab('SF4') + ", " + RetSQLTab('SA1') 
_cQuery += " WHERE " + RetSQLFil('SD2') + " AND " + RetSQLFil('SA1') + " AND " + RetSQLFil('SF4') + " AND "
_cQuery += " D2_CLIENTE = A1_COD     AND"
_cQuery += " D2_LOJA    = A1_LOJA    AND"
_cQuery += " D2_EST     = A1_EST     AND"
_cQuery += " D2_TES     = F4_CODIGO  AND"
_cQuery += " F4_TIPO = 'S' AND F4_DUPLIC = 'S' AND"  
_cQuery += " D2_EMISSAO BETWEEN '" + DTOS(mv_par01) + "' AND '" + DTOS(mv_par02) + "' AND"
_cQuery += " A1_COD  = 	   '" + CLI->CLIENTE + "' AND"
_cQuery += " A1_LOJA =     '" + CLI->LOJA    + "' AND"
_cQuery += " A1_EST  =     '" + CLI->EST     + "' AND"
_cQuery += " D2_COD BETWEEN  '" + mv_par09 + "' AND '" + mv_par10 + "'"
_cQuery += " AND " + RetSQLDel('SD2') + " AND " + RetSQLDel('SA1') + " AND " + RetSQLDel('SF4') 
_cQuery += " GROUP BY  D2_COD"
*/
