#INCLUDE "rwmake.ch"
#INCLUDE "topconn.ch"

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³GJF202   º Autor ³ Giuliano Forgiarini  º Data ³  09/02/15  º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDescricao ³ Relatório de Estoque modelo III                            º±±
±±º          ³                                                            º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ PCP                                                       º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/

User Function GJF202()


	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Declaracao de Variaveis                                             ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ

	Local cDesc1         := "Este programa tem como objetivo imprimir relatorio  "
	Local cDesc2         := "de conferencia de estoque de Produto Acabado        "
	Local cDesc3         := "de acordo com os parâmetros apontados               "
	Local cPict          := "empresa"
	Local titulo         := "CONFERENCIA DE ESTOQUE DE PRODUTO ACABADO"
	Local nLin           := 80

	Local Cabec1         := ""                   
	Local Cabec2         := ""

	Local imprime        := .T.
	Local aOrd := {}
	Private lEnd         := .F.
	Private lAbortPrint  := .F.
	Private CbTxt        := ""
	Private limite       := 132
	Private tamanho      := "M"
	Private nomeprog     := "GJF202" // Coloque aqui o nome do programa para impressao no cabecalho
	Private nTipo        := 18
	Private aReturn      := { "Zebrado", 1, "Administracao", 2, 2, 1, "", 1}
	Private nLastKey     := 0
	Private cPerg        := "GJF202"
	Private cbtxt       := Space(10)
	Private cbcont      := 00
	Private CONTFL      := 01
	Private m_pag       := 01
	Private wnrel       := "GJF196" // Coloque aqui o nome do arquivo usado para impressao em disco    

	pergunte(cPerg,.f.)

	_cFarm := iif(mv_par01 = 1,'C',iif(mv_par01 = 2, 'R','S'))

	wnrel := SetPrint('SZN',NomeProg,cPerg,@titulo,cDesc1,cDesc2,cDesc3,.T.,aOrd,.T.,Tamanho,,.T.)

	//para verificação se existe previsao de pesagem
	cQuery := "SELECT * "
	cQuery += " FROM  " + RetSqlTab("ZAI") 
	cQuery += " WHERE " + RetSqlFil('ZAI') 
	cQuery += " AND ZAI_ BETWEEN '" + dtos(mv_par01) + "' AND '" + dtos(mv_par02) + "' "
	cQuery += iif(_cDest <> "'T'"," AND ZN_DESTINO IN (" + _cDest+ ")","")
	cQuery += " AND " + RetSqlDel('SZN')
	cQuery += " AND ZN_CLIENTE BETWEEN '" + mv_par04 + "' AND '" + mv_par05 + "'" 
	cQuery += " AND ZN_LOJA BETWEEN '" + mv_par06 + "' AND '" + mv_par07 + "'" 
	cQuery += " AND " + RetSQLDel('SZN')
	cQuery += "ORDER BY  ZN_CLIENTE, ZN_LOJA, ZN_DTENTR,ZN_DESTINO,ZN_COD " 

	cQuery := ChangeQuery(cQuery)

	//	* Mostrar a consulta */
	//@ 116,090 To 416,707 Dialog oDlgMemo Title "Consulta"
	//@ 055,005 Get cQuery Size 250,080 MEMO Object oMemo
	//Activate Dialog oDlgMemo
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Monta a interface padrao com o usuario...                           ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ   


	If Select("DEV") != 0
		DEV->(dbCloseArea())
	Endif  

	TCQUERY cQuery NEW ALIAS "DEV"

	If nLastKey == 27
		Return
	Endif

	SetDefault(aReturn,'SZN')

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


	_cCliLoj  := ''
	_dData    := ''
	_cDestino := ''  
	_nTotCli  := 0.00
	_nTotData := 0.00
	_nTotDest := 0.00

	DEV->(dbGoTop())

	DEV->(SetRegua(RecCount()))

	While DEV->(!EOF())

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

		if _cCliLoj <> DEV->(ZN_CLIENTE+ZN_LOJA)
			nlin++
			@nlin,001 psay	'Cliente: ' + DEV->ZN_CLIENTE+"/"+DEV->ZN_LOJA + "  " + fBuscaCPO('SA1',1,xfilial('SA1')+DEV->(ZN_CLIENTE+ZN_LOJA),'A1_NOME')
			nlin++
			_cCliLoj := DEV->(ZN_CLIENTE+ZN_LOJA)
		endif 

		if _dData <> DEV->ZN_DTENTR       
			nlin++
			@nlin,010 psay 'Data de Entrada: ' + dtoc(stod(DEV->ZN_DTENTR)) 
			nlin++
			_dData := DEV->ZN_DTENTR
		endif 

		if _cDestino <> DEV->ZN_DESTINO      
			nlin++
			@nlin,020 psay 'Destino: ' + iif(DEV->ZN_DESTINO  = 'E','Estoque',;
			iif(DEV->ZN_DESTINO  = 'P','Repesagem',;
			iif(DEV->ZN_DESTINO  = 'R','Reprocesso',;
			iif(DEV->ZN_DESTINO  = 'C','Charque','Graxaria'))))
			nlin++
			_cDestino := DEV->ZN_DESTINO
		endif 

		@nlin,030 psay DEV->ZN_NUM  
		@nlin,042 psay DEV->ZN_CONTROL
		@nlin,054 psay substr(DEV->ZN_COD,1,6)
		@nlin,062 psay substr(DEV->ZN_DESC,1,30)
		@nlin,090 psay transform(DEV->ZN_PESOL,'@E 999.99')
		@nlin,100 psay dtoc(stod(DEV->ZN_DTSAIDA))

		_nTotCli  += DEV->ZN_PESOL  
		_nTotData += DEV->ZN_PESOL  
		_nTotDest += DEV->ZN_PESOL
		nlin++

		DEV->(dbSkip()) // Avanca o ponteiro do registro no arquivo 

		if _cDestino <> DEV->ZN_DESTINO .or. DEV->(eof())
			@nlin,020 psay 'Total Destino: ' + transform(_nTotDest,'@E 999,999.99')    
			_nTotDest := 0.00
			nlin++	
		endif

		if _dData <> DEV->ZN_DTENTR  .or. DEV->(eof())
			@nlin,010 psay 'Total Data Entrada: ' + transform(_nTotData,'@E 999,999.99')    
			_nTotData := 0.00
			nlin++	
		endif


		if _cCliLoj <> DEV->(ZN_CLIENTE+ZN_LOJA) .or. DEV->(eof())
			@nlin,001 psay 'Total Cliente: ' + transform(_nTotCli,'@E 999,999.99')
			_nTotCli := 0.00	                    
			nlin++
		endif

	EndDo

	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Finaliza a execucao do relatorio...                                 ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ

	DbCloseArea('DEV')

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
