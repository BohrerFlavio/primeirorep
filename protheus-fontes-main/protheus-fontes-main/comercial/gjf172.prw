#INCLUDE "rwmake.ch"
#INCLUDE "topconn.ch"

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³GJF172     º Autor Giuliano Forgiarini  º Data ³  17/06/13  º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDescricao ³Relatorio de preços médios de carne com osso                º±±
±±º                                                                       º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³sigafin                                                     º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/

User Function GJF172()

	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Declaracao de Variaveis                                             ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ

	Local cDesc1         := "Este programa tem como objetivo imprimir relatorio "
	Local cDesc2         := "para a conferencia de preços médios de venda de    "
	Local cDesc3         := " carne com osso de acordo com parametros informados"
	Local cPict          := ""
	Local titulo         := "Preços Médios de Carne com Osso"
	Local nLin           := 80

	Local Cabec1         := "              Cod.             Descri. Produto                      Qnt. Peças       Peso(Kg)     Valor Total (R$)  Preço Medio(R$)"
	Local Cabec2         := ""
	Local imprime        := .T.
	Local aOrd := {}
	Private lEnd         := .F.
	Private lAbortPrint  := .F.
	Private CbTxt        := ""
	Private limite       := 132
	Private tamanho      := "M"
	Private nomeprog     := "GJF172" // Coloque aqui o nome do programa para impressao no cabecalho
	Private nTipo        := 18
	Private aReturn      := { "Zebrado", 1, "Administracao", 2, 2, 1, "", 1}
	Private nLastKey     := 0
	Private cPerg        := "GJF172"
	Private cbtxt        := Space(10)
	Private cbcont       := 00
	Private CONTFL       := 01
	Private m_pag        := 01
	Private wnrel        := "GJF172" // Coloque aqui o nome do arquivo usado para impressao em disco     
	Private _cCodPro     := '' 


	Private cString := "ZZ4"

	dbSelectArea("ZZ4")
	dbSetOrder(1)

	pergunte(cPerg,.F.)

	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Monta a interface padrao com o usuario...                           ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ

	wnrel := SetPrint(cString,NomeProg,cPerg,titulo,cDesc1,cDesc2,cDesc3,.T.,aOrd,.T.,Tamanho,,.T.)

	If nLastKey == 27
		Return
	Endif

	SetDefault(aReturn,cString)

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


	cQuery := " SELECT ZZ5_COD AS COD, A1_COD, A1_LOJA ,SUM(ZZ5_QRCAIX) AS PECAVEN, SUM(ZZ5_QRPESO) AS PESOVEN,"
	cQuery += " SUM(ZZ5_PRCFIN * ZZ5_QRPESO) AS VALORVEN "
	cQuery += " FROM " + RetSQLTab('ZZ5') + "," + RetSQLTab('ZZ4') + "," + RetSQLTab('SB1') + "," + RetSQLTab('SA1') 
	cQuery += " WHERE " + RetSQLFil('ZZ4') + " AND " +  RetSQLFil('ZZ5') + " AND " +  RetSQLFil('SB1') + " AND " +  RetSQLFil('SA1')
	cQuery += " AND ZZ5_NUM = ZZ4_NUM AND ZZ5_COD = B1_COD AND ZZ4_TPOPER = 'V' AND ZZ4_STATUS = 'F' "
	cQuery += " AND B1_SEGUM = 'PC' AND A1_COD = ZZ4_CODCLI AND A1_LOJA = ZZ4_LOJA "
	cQuery += " AND ZZ4_DATAPV BETWEEN '" + dtos(mv_par01) + "' AND '" + dtos(mv_par02) + "'"
	cQuery += " AND " + RetSQLDel('ZZ5') + " AND " + RetSQLDel('ZZ4') + " AND " + RetSQLDel('SB1')+ " AND " + RetSQLDel('SA1')
	cQuery += " GROUP BY ZZ5_COD,A1_COD,A1_LOJA"
	cQuery += " ORDER BY ZZ5_COD,A1_COD,A1_LOJA"



	cQuery := ChangeQuery(cQuery)

	//memowrite("ZZZ_GJF172.TXT",cQuery)


	If Select("QRY") != 0
		QRY->(dbCloseArea())
	Endif


	TCQUERY cQuery NEW ALIAS "QRY"  

	//	* Mostrar a consulta */
	//@ 116,090 To 416,707 Dialog oDlgMemo Title "Consulta"
	//@ 055,005 Get cQuery Size 250,080 MEMO Object oMemo
	//Activate Dialog oDlgMemo

	QRY->(dbgotop())

	SetRegua(QRY->(RecCount()))

	_nPrcMed    := 0   
	_nPrcTotMed := 0  
	_nTotVal    := 0
	_nTotPes    := 0      
	_nTotQnt    := 0
	_cDescri    := 0
	_nTotGerVal := 0
	_nTotGerPes := 0      
	_nTotGerQnt := 0

	_cCodPro := QRY->COD

	While QRY->(!EOF())

		IncRegua()


		If lAbortPrint
			@nLin,00 PSAY "*** CANCELADO PELO OPERADOR ***"
			Exit
		Endif

		If nLin > 75 // Salto de Página. Neste caso o formulario tem 55 linhas...
			Cabec(Titulo,Cabec1,Cabec2,NomeProg,Tamanho,nTipo)
			nLin := 9
		Endif 

		_cCodPro := QRY->COD

		_nValRap 	:= fBuscaCPO("SA1",1,xfilial('SA1')+QRY->(A1_COD+A1_LOJA),"A1_PRAPEL")/100   
		_cDescri 	:= fBuscaCPO("SB1",1,xfilial('SB1')+QRY->COD,"B1_DESC")
		_nTotPes 	+= QRY->PESOVEN                                                                 
		//se considera rapel
		if mv_par03 = 1 
			_nTotVal 	+= iif(_nValRap <> 0,QRY->VALORVEN * (1-_nValRap),QRY->VALORVEN)
		else
			_nTotVal 	+= QRY->VALORVEN 
		endif                                 
		_nTotQnt 	+= QRY->PECAVEN 


		_nTotGerPes += QRY->PESOVEN 
		//se considera rapel
		if mv_par03 = 1
			_nTotGerVal += iif(_nValRap <> 0,QRY->VALORVEN * (1-_nValRap),QRY->VALORVEN)
		else
			_nTotGerVal += QRY->VALORVEN
		endif	
		_nTotGerQnt += QRY->PECAVEN



		/*	 
		_nTotPes += QRY->PESOVEN
		_nTotVal += QRY->VALORVEN
		_nTotQnt += QRY->PECAVEN


		_nPrcMed := (QRY->VALORVEN / QRY->PESOVEN ) 

		@nlin,012 psay alltrim(QRY->COD)
		@nlin,022 psay " | "
		@nlin,030 psay substr(QRY->DESCRI,1,35)
		@nlin,067 psay " | "
		@nlin,070 psay transform(QRY->PECAVEN,"@E 99999")
		@nlin,077 psay " | "
		@nlin,083 psay transform(QRY->PESOVEN,"@E 999,999.99")
		@nlin,096 psay " | "
		@nlin,100 psay transform(QRY->VALORVEN,"@E 9,999,999.99")
		@nlin,114 psay " | "
		@nlin,118 psay transform(_nPrcMed,"@E 999.99")
		nlin++

		*/
		QRY->(dbSkip()) // Avanca o ponteiro do registro no arquivo

		if _cCodPro <> QRY->COD .or. QRY->(eof())
			_nPrcMed := (_nTotVal / _nTotPes) 

			@nlin,012 psay alltrim(_cCodPro) 
			@nlin,022 psay " | "	
			@nlin,030 psay substr(_cDescri,1,35)                    
			@nlin,067 psay " | "	
			@nlin,070 psay transform(_nTotQnt,"@E 99999")	
			@nlin,077 psay " | "	
			@nlin,083 psay transform(_nTotPes,"@E 999,999.99") 
			@nlin,096 psay " | "	
			@nlin,100 psay transform(_nTotVal,"@E 9,999,999.99") 
			@nlin,114 psay " | "	
			@nlin,118 psay transform(_nPrcMed,"@E 999.99")
			nlin++

			_nTotPes := 0
			_nTotVal := 0
			_nTotQnt := 0
			_nPrcMed := 0	
		endif

	EndDo

	_nPrcTotMed := (_nTotGerVal / _nTotGerPes)

	@nlin,001 psay replicate('-',132)
	nlin++
	@nlin,030 psay "Média Total ------------------->" 
	@nlin,067 psay " | "
	@nlin,070 psay transform(_nTotGerQnt,"@E 99999")
	@nlin,077 psay " | "
	@nlin,083 psay transform(_nTotGerPes,"@E 999,999.99")
	@nlin,096 psay " | "
	@nlin,100 psay transform(_nTotGerVal,"@E 9,999,999.99")
	@nlin,114 psay " | "
	@nlin,118 psay transform(_nPrcTotMed,"@E 999.99")

	DbCloseArea('QRY')

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
