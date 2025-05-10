#INCLUDE "rwmake.ch"
#INCLUDE "topconn.ch"

/*/
эээээээээээээээээээээээээээээээээээээээээээээээээээээээээээээээээээээээээээээ
╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠
╠╠иммммммммммяммммммммммкмммммммяммммммммммммммммммммкммммммяммммммммммммм╩╠╠
╠╠╨Programa  ЁMLR12    ╨ Autor Ё Mauricio Roehrs  Data Ё 23/04/2013       ╨╠╠
╠╠лммммммммммьммммммммммймммммммоммммммммммммммммммммйммммммоммммммммммммм╧╠╠
╠╠╨Descricao Ё Relatorio de Faturamento por Vendedor		      	        ╨╠╠
╠╠╨          Ё                                                            ╨╠╠
╠╠лммммммммммьмммммммммммммммммммммммммммммммммммммммммммммммммммммммммммм╧╠╠
╠╠╨Uso       Ё Comercial								                  		  ╨╠╠
╠╠хммммммммммомммммммммммммммммммммммммммммммммммммммммммммммммммммммммммм╪╠╠
╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠
ъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъ
/*/

User Function MLR12()


	//зддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
	//Ё Declaracao de Variaveis                                             Ё
	//юддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды

	Local cDesc1          := "Este programa tem como objetivo imprimir relatorio"
	Local cDesc2          := "para conferencia do Faturamento por VENDEDOR"
	Local cDesc3          := ""
	Local cPict           := "xxxxxxxxx"
	Local titulo          := "RELATORIO DE CONFERйNCIA DE FATURAMENTO POR VENDEDOR"
	Local Cabec1          := "Cod. Vend        Nome do Vendedor                   Bruto Faturado                  DevoluГУes                Liquido Faturado"
	Local Cabec2          := "                                                 (Kg)           (R$)            (Kg)           (R$)         (Kg)            (R$)"                   
	Local imprime         := .T.
	Local aOrd            := {}  
	Private nLin          := 80
	Private lEnd          := .F.
	Private lAbortPrint   := .F.
	Private CbTxt         := ""
	Private limite        := 80
	Private tamanho       := "M"
	Private nomeprog      := "MLR12" // Coloque aqui o nome do programa para impressao no cabecalho
	Private nTipo         := 18
	Private aReturn       := { "Zebrado", 1, "Administracao", 2, 2, 1, "", 1}
	Private nLastKey      := 0
	Private cPerg   		 := "MLR12"
	Private cbtxt      	 := Space(10)
	Private cbcont        := 00
	Private CONTFL        := 01
	Private m_pag         := 01
	Private wnrel         := "MLR12" // Coloque aqui o nome do arquivo usado para impressao em disco    
	Private _nTOTAL       := 0.00

	pergunte(cPerg,.F.)

	wnrel := SetPrint('SA3',NomeProg,cPerg,@titulo,cDesc1,cDesc2,cDesc3,.T.,aOrd,.T.,Tamanho,,.T.)  


	If nLastKey == 27
		Return
	Endif

	SetDefault(aReturn,'SA3')

	If nLastKey == 27
		Return
	Endif

	nTipo := If(aReturn[4]==1,15,18)

	//зддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
	//Ё Processamento. RPTSTATUS monta janela com a regua de processamento. Ё
	//юддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды

	RptStatus({|| RunReport(Cabec1,Cabec2,Titulo,nLin) },Titulo)
Return

Static Function RunReport(Cabec1,Cabec2,Titulo,nLin)

	Local nOrdem

	Cabec(Titulo,Cabec1,Cabec2,NomeProg,Tamanho,nTipo)
	nLin := 9


	//зддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
	//Ё SETREGUA -> Indica quantos registros serao processados para a regua Ё
	//юддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды

	SA3->(SetRegua(RecCount()))
	DbSelectArea('SA3')
	SA3->(DbSetOrder(1))   
	SA3->(DbSeek(xfilial('SA3') + mv_par03,.t.))


	_nPesLiq     := 0
	_nTotLiq     := 0
	_nValTotBrut := 0
	_nPesTotBrut := 0
	_nValTotLiq  := 0
	_nPesTotLiq  := 0
	_nDevTot     := 0
	_nDevPes     := 0

	While SA3->(!EOF()) .and. SA3->A3_FILIAL = xFilial('SA3') .and. SA3->A3_COD <= mv_par04 

		incregua()

		//зддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
		//Ё Verifica o cancelamento pelo usuario...                             Ё
		//юддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды

		If lAbortPrint
			@nLin,00 PSAY "*** CANCELADO PELO OPERADOR ***"
			Exit
		Endif

		If nLin > 70 // Salto de PАgina. Neste caso o formulario tem 55 linhas...
			Cabec(Titulo,Cabec1,Cabec2,NomeProg,Tamanho,nTipo)
			nLin := 9
		Endif

		if SA3->A3_TIPVEN != 'V'
			SA3->(DbSkip())
			loop		
		endif 	

		TrataFat(SA3->A3_COD) 

		if FAT->TOTAL = 0
			SA3->(DbSkip())
			loop	
		endif	

		TrataDev(SA3->A3_COD)    

		//if FAT->TOTAL = 0 .and. DEV->TOTAL = 0
		//	SA3->(DbSkip())
		//	loop
		//endif

		_nPesLiq := FAT->PESO  - DEV->PESO	
		_nTotLiq := FAT->TOTAL - DEV->TOTAL

		@nlin,001 psay alltrim(SA3->A3_COD)
		@nlin,008 psay "|"
		@nlin,010 psay substr(SA3->A3_NOME,1,25)
		@nlin,040 psay "|"                 
		@nlin,042 psay transform(FAT->PESO,'@E 999,999,999.99')
		@nlin,057 psay transform(FAT->TOTAL,'@E 999,999,999.99')
		@nlin,071 psay "|"
		@nlin,072 psay transform(DEV->PESO,'@E 999,999,999.99') 
		@nlin,087 psay transform(DEV->TOTAL,'@E 999,999,999.99')
		@nlin,101 psay "|"
		@nlin,103 psay alltrim(transform(_nPesLiq,'@E 999,999,999.99'))  
		@nlin,117 psay alltrim(transform(_nTotLiq,'@E 999,999,999.99'))  

		nlin++

		_nPesTotBrut += FAT->PESO
		_nValTotBrut += FAT->TOTAL

		_nPesTotLiq  += _nPesLiq
		_nValTotLiq  += _nTotLiq

		_nDevPes     += DEV->PESO
		_nDevTot     += DEV->TOTAL

		SA3->(DbSkip())						

	Enddo
	nlin++
	@nlin,000 psay replicate('-',132)
	nlin++
	@nlin,001 psay "TOTAIS ---------->
	@nlin,040 psay "|"                 
	@nlin,043 psay alltrim(transform(_nPesTotBrut,'@E 999,999,999.99')) 
	@nlin,057 psay alltrim(transform(_nValTotBrut,'@E 999,999,999.99'))
	@nlin,071 psay "|"
	@nlin,073 psay alltrim(transform(_nDevPes,'@E 999,999,999.99')) 
	@nlin,087 psay alltrim(transform(_nDevTot,'@E 999,999,999.99'))
	@nlin,101 psay "|"
	@nlin,103 psay alltrim(transform(_nPesTotLiq,'@E 999,999,999.99'))  
	@nlin,117 psay alltrim(transform(_nValTotLiq,'@E 999,999,999.99'))     


	//зддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
	//Ё Finaliza a execucao do relatorio...                                 Ё
	//юддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды


	SET DEVICE TO SCREEN

	//зддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
	//Ё Se impressao em disco, chama o gerenciador de impressao...          Ё
	//юддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды

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

//зддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
//Ё FunГЦo que trata os Faturamentos	                                 Ё
//юддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды
Static Function TrataFat(_vend)

	_cQuery := " SELECT SUM(D2_QUANT) AS PESO, SUM(D2_TOTAL) AS TOTAL
	_cQuery += " FROM " + RetSQLTab('SF2') + ", " + RetSQLTab('SD2') + ", " + RetSQLTab('SF4') 
	_cQuery += " WHERE " + RetSQLFil('SF2') + " AND " + RetSQLFil('SD2') + " AND " + RetSQLFil('SF4') + " AND"
	_cQuery += " D2_DOC  = F2_DOC AND D2_SERIE = F2_SERIE AND F2_CLIENTE = D2_CLIENTE AND D2_LOJA = F2_LOJA AND "
	_cQuery += " D2_TES  = F4_CODIGO AND F4_DUPLIC = 'S' AND F4_TIPO = 'S' AND "
	_cQuery += " F2_VEND1   = '" + _vend + "' AND "
	_cQuery += " F2_EMISSAO BETWEEN '" + DTOS(mv_par01) + "' AND '" + DTOS(mv_par02) + "'"
	_cQuery += " AND " + RetSQLDel('SF2') + " AND " + RetSQLDel('SD2') + " AND " + RetSQLDel('SF4')


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

//зддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
//Ё FunГЦo que trata as DevoluГУes		                                 Ё
//юддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды
Static Function TrataDev(_vend)

	_cQuery2 := " SELECT SUM(D1_QUANT) AS PESO, SUM(D1_TOTAL) AS TOTAL
	_cQuery2 += " FROM " + RetSQLTab('SD1') + ", " + RetSQLTab('SF4')
	_cQuery2 += " WHERE " + RetSQLFil('SD1') + " AND " + RetSQLFil('SF4') + " AND "
	_cQuery2 += " D1_TES = F4_CODIGO  AND"
	_cQuery2 += " F4_TIPO = 'E' AND F4_DUPLIC = 'S' AND D1_TIPO = 'D' AND"  
	_cQuery2 += " D1_NFORI  <> '' AND D1_SERIORI <> '' AND" 
	_cQuery2 += " D1_DTDIGIT BETWEEN '" + DTOS(mv_par01) + "' AND '" + DTOS(mv_par02) + "' AND"           
	//subquery para selecionar as notas devolvidas +D1_SERIORI - +D2_SERIE
	_cQuery2 += " D1_NFORI IN (SELECT D2_DOC "
	_cQuery2 += "              FROM " + RetSQLTab('SD2') + "," + RetSQLTab('SF2') 
	_cQuery2 += "              WHERE F2_DOC = D2_DOC AND F2_SERIE = D2_SERIE AND F2_VEND1 = '" + _vend + "' AND "
	_cQuery2 += "              D2_DOC = D1_NFORI AND D2_SERIE = D1_SERIORI"
	_cQuery2 += "              GROUP BY D2_DOC)

	_cQuery2 += " AND " + RetSQLDel('SD1') + " AND " + RetSQLDel('SF4')

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

