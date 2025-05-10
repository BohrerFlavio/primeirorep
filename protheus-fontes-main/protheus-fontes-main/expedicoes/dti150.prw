#INCLUDE "rwmake.ch"
#INCLUDE "topconn.ch"

/*/
эээээээээээээээээээээээээээээээээээээээээээээээээээээээээээээээээээээээээээээ
╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠
╠╠иммммммммммяммммммммммкмммммммяммммммммммммммммммммкммммммяммммммммммммм╩╠╠
╠╠╨Programa  ЁDTI150     ╨ Autor Mateus Escobar       ╨ Data Ё  28/03/2022╨╠╠
╠╠лммммммммммьммммммммммймммммммоммммммммммммммммммммйммммммоммммммммммммм╧╠╠
╠╠╨Descricao ЁRelatorio caixas que faltam ser carregadas                  ╨╠╠
╠╠╨                                                                       ╨╠╠
╠╠лммммммммммьмммммммммммммммммммммммммммммммммммммммммммммммммммммммммммм╧╠╠
╠╠╨Uso       Ё                                                            ╨╠╠
╠╠хммммммммммомммммммммммммммммммммммммммммммммммммммммммммммммммммммммммм╪╠╠
╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠
ъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъ
/*/

User Function DTI150()

	//зддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
	//Ё Declaracao de Variaveis                                             Ё
	//юддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды

	Local cDesc1         := "Este programa tem como objetivo imprimir relatorio "
	Local cDesc2         := "para buscar as caixas que faltam ser carregadas.   "
	//Local cDesc2		 := ""
	Local titulo         := "RELATсRIO CAIXAS A SEREM CARREGADAS"
	Local nLin           := 80
	//Local cPict          := ""
	Local Cabec1         := "    NЗm. PrИ Pedido   Item   CСd. Produto   Caixas a Carregar  Caixas Carregadas  "
	Local Cabec2         := ""
	Local aOrd := {}
	//Local imprime        := .T.
	//Local cCont          := 0

	Private lEnd         := .F.
	Private lAbortPrint  := .F.
	Private CbTxt        := ""
	Private limite       := 132
	Private tamanho      := "P"
	Private nomeprog     := "DTI150" // Coloque aqui o nome do programa para impressao no cabecalho
	Private nTipo        := 18
	Private aReturn      := { "Zebrado", 1, "Administracao", 2, 2, 1, "", 1}
	Private nLastKey     := 0
	Private cPerg        := "DTI150"
	Private cbcont       := 00
	Private CONTFL       := 01
	//Private cbtxt        := Space(10)
	Private m_pag        := 01
	Private wnrel        := "DTI150" // Coloque aqui o nome do arquivo usado para impressao em disco      
	//Private _nHora 		 := 
	//Private _nPeso 		 := 
	//Private _nNum		 :=
	//Private _cString     :=	
	

	Private cString := "ZZ5"

	dbSelectArea("ZZ5")
	dbSetOrder(1)

	pergunte(cPerg,.F.)

	//зддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
	//Ё Monta a interface padrao com o usuario...                           Ё
	//юддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды

	wnrel := SetPrint(cString,NomeProg,cPerg,titulo,cDesc1,cDesc2,cDesc2,.T.,aOrd,.T.,Tamanho,,.T.)

	If nLastKey == 27
		Return
	Endif

	SetDefault(aReturn,cString)

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
	
	

	//зддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
	//Ё SETREGUA -> Indica quantos registros serao processados para a regua Ё
	//юддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды

	_cQuery := " SELECT ZZ5_NUM AS NUMERO, ZZ5_ITEM AS ITEM, ZZ5_COD AS CODIGO, SUM(ZZ5_QPCAIX) AS PREVISTO, SUM(ZZ5_QRCAIX) AS REAIS, ZZ3_NUM AS CARREGAMENTO
	_cQuery += " FROM " + retSqlTab('ZZ5') + ", " + retSqlTab('ZZ3') + ", " + retSqlTab('ZZ4')
	_cQuery += " WHERE " + retSqlFil('ZZ5') + " AND " + retSqlFil('ZZ3') + " AND " + retSqlFil('ZZ4') 
	//_cQuery += " AND ZZ5_NUM = '" + mv_par01 + "'
	_cQuery += " AND ZZ3_NUM = '" + mv_par01 + "'
	_cQuery += " AND ZZ4_PRECAR = ZZ3_NUM
	_cQuery += " AND ZZ5_NUM= ZZ4_NUM
	_cQuery += " AND " + retSqlDel('ZZ5') + "  AND " + retSqlDel('ZZ3') + "  AND " + retSqlDel('ZZ4')  
	_cQuery += " GROUP BY ZZ5_NUM, ZZ5_COD, ZZ5_ITEM, ZZ5_QPCAIX, ZZ5_QRCAIX, ZZ3_NUM
	_cQuery += " ORDER BY ZZ5_NUM, ZZ5_ITEM
	_cQuery  := ChangeQuery(_cQuery)


	If Select("QRY") != 0
		QRY->(dbCloseArea())
	Endif


	TCQUERY _cQuery NEW ALIAS "QRY"  

	//	* Mostrar a consulta */
	//@ 116,090 To 416,707 Dialog oDlgMemo Title "Consulta"
	//@ 055,005 Get cQuery Size 250,080 MEMO Object oMemo
	//Activate Dialog oDlgMemo

	
	QRY->(dbgotop())

	SetRegua(QRY->(RecCount()))

	While QRY->(!EOF())
		IncRegua()

	//VARIAVEIS DECLARADAS PUXANDO AS TABELAS
	cCarr:= CARREGAMENTO
	//==================================================//

		If lAbortPrint
			@nLin,00 PSAY "*** CANCELADO PELO OPERADOR ***"
			Exit
		Endif

		If nLin > 75 // Salto de PАgina. Neste caso o formulario tem 55 linhas...
			Cabec(Titulo,Cabec1,Cabec2,NomeProg,Tamanho,nTipo)
			nLin := 9
		Endif
			@nlin,001 psay 'Pre-Carregamento: ' 
			@nlin,0020 psay cCarr
			nlin++
			nlin++
	
		QRY->(dbGoTop())
		
		while QRY->(!eof())
		cNum:= NUMERO
		nPrevi:= PREVISTO
		nReais:=REAIS
		cCod:= CODIGO
		cItem:=ITEM
		if QRY->(!eof()) 
			@nlin,005 psay cNum
			@nlin,016 psay " | "
			@nlin,022 psay cItem
			@nlin,028 psay " | "
			@nlin,034 psay cCod
			@nlin,046 psay " | "
			@nlin,054 psay nPrevi
            @nlin,063 psay " | "
			@nlin,070 psay nReais				                    
			nlin++		

		endif
		QRY->(dbSkip()) // Avanca o ponteiro do registro no arquivo
		enddo
		 

	EndDo

	DbCloseArea('QRY')

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
