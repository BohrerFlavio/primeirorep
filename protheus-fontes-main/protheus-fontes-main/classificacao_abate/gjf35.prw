#INCLUDE "rwmake.ch"
#INCLUDE "topconn.ch"

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³GJF35   º Autor ³ Giuliano Forgiarini  º Data ³  04/09/2013 º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDescricao ³ Relatorio de Estoque de Peças                              º±±
±±º          ³                                                            º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ Comercial e PCP (SIGAPCP)                                  º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/

User Function GJF35()


	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Declaracao de Variaveis                                             ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ

	Local cDesc1         := "Este programa tem como objetivo imprimir relatorio   "
	Local cDesc2         := "de carcaças produzidas no abate distribuidas por suas"
	Local cDesc3         := "variadas classificações, algutinando suas quantidades"
	//Local cPict          := "para utilização do PCP na programação da produção."
	Local titulo         := "ESTOQUE DE PEÇAS"
	Local nLin         := 80

	Local Cabec1       := ""                   
	Local Cabec2       := ""

	//Local imprime      := .T.
	Local aOrd := {}
	Private lEnd         := .F.
	Private lAbortPrint  := .F.
	Private CbTxt        := ""
	Private limite       := 132
	Private tamanho      := "M"
	Private nomeprog     := "GJF35" // Coloque aqui o nome do programa para impressao no cabecalho
	Private nTipo        := 18
	Private aReturn      := { "Zebrado", 1, "Administracao", 2, 2, 1, "", 1}
	Private nLastKey     := 0
	Private cPerg   	:= "GJF35"
	//Private cbtxt      := Space(10)
	Private cbcont     := 00
	Private CONTFL     := 01
	Private m_pag      := 01
	Private wnrel      := "GJF35" // Coloque aqui o nome do arquivo usado para impressao em disco    
	Private TotCaix    := 0.00
	Private TotPeso    := 0.00

	pergunte(cPerg,.F.)

	//para verificação se existe previsao de pesagem

	wnrel := SetPrint('SZK',NomeProg,cPerg,@titulo,cDesc1,cDesc2,cDesc3,.T.,aOrd,.T.,Tamanho,,.T.)

	cQuery := " SELECT  ZAJ_DATA,ZAJ_CORORI,ZAJ_NUM,ZAJ_CDIAN,ZK_CATEG,ZK_PROGRAM,ZK_CLASSIF,ZK_DENT,ZK_COBGOR"
	cQuery += " FROM " + RetSqlTab("SZK") + "," +  RetSqlTab("ZAJ")
	cQuery += " WHERE  " + RetSQLFil('SZK') + " AND " + RetSQLFil('ZAJ') + " AND " 
	cQuery +=" ZK_NUMAM = ZAJ_NUMAM AND ZK_CONTROL = ZAJ_CONTRO " 

	if !empty(mv_par01)
		cQuery += " AND ZAJ_NUMAM = '" + mv_par01 + "'"      
	endif   

	cQuery += " AND (ZAJ_DATA BETWEEN '" + dtos(mv_par02) + "' AND '" + dtos(mv_par03) + "')"    

	if mv_par04 <> 4
		cQuery += " AND ZAJ_CORORI = '" + iif(mv_par04 = 1,'T',iif(mv_par04 = 2,'D','C')) + "'" 
	endif    

	if !empty(mv_par05)
		cQuery += " AND ZK_PROGRAM = '" + mv_par05 + "'"
	endif

	if !empty(mv_par06)
		cQuery += " AND ZK_CATEG = '" + mv_par06 + "'"
	endif

	if !empty(mv_par07)
		cQuery += " AND ZK_CLASSIF = '" + mv_par07 + "'"
	endif

	if (mv_par08 <> 3) .and. (mv_par04 = 2)
		cQuery += " AND ZAJ_CDIAN = '" + iif(mv_par08 = 1,'C','N') + "'"	
	endif

	cQuery += " AND ZAJ_DATAS = '' AND ZAJ_HORAS = '' AND ZAJ_REGORI = '0000000000' "                      
	cQuery += " AND " + RetSQLDel('SZK') + " AND " + RetSQLDel('ZAJ')	 
	cQuery += " GROUP BY ZAJ_DATA,ZAJ_CORORI,ZK_CATEG,ZK_PROGRAM,ZK_CLASSIF,ZK_DENT,ZK_COBGOR,ZAJ_NUM,ZAJ_CDIAN" 
	cQuery += " ORDER BY ZAJ_DATA,ZAJ_CORORI,ZK_CATEG,ZK_PROGRAM,ZK_CLASSIF,ZK_DENT,ZK_COBGOR,ZAJ_NUM,ZAJ_CDIAN"

	cQuery := ChangeQuery(cQuery)

	//	* Mostrar a consulta */
	//@ 116,090 To 416,707 Dialog oDlgMemo Title "Consulta"
	//@ 055,005 Get cQuery Size 250,080 MEMO Object oMemo
	//Activate Dialog oDlgMemo
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Monta a interface padrao com o usuario...                           ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ

	If Select("TMP") != 0
		TMP->(dbCloseArea())
	Endif
	TCQUERY cQuery NEW ALIAS "TMP"

	If nLastKey == 27
		Return
	Endif

	SetDefault(aReturn,'SZK')

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
	Local _cData    := ''
	Local _cCorori  := ''
	Local _cCateg   := ''
	Local _cProgram := '' 
	Local _cClassif := '' 
	Local _cDent    := ''
	Local _cCobGor  := ''
	Local _nCol     := 1
	Local _lLin     := .f.

	Cabec(Titulo,Cabec1,Cabec2,NomeProg,Tamanho,nTipo)
	nLin := 9

	TMP->(dbGoTop())

	TMP->(SetRegua(RecCount()))

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

		if _cData <> TMP->ZAJ_DATA 
			if _ncol <> 0 .and. !_lLin
				_lLin := .t.
				nlin++
			endif
			@nlin,01 psay 'Data de Produção: ' + dtoc(stod(TMP->ZAJ_DATA))
			_cData := TMP->ZAJ_DATA 
			_nCol := 10		   
			nlin++
		endif

		if _cCorori <> TMP->ZAJ_CORORI   
			if _ncol <> 0 .and. !_lLin
				_lLin := .t.
				nlin++
			endif
			@nlin,01 psay replicate('-',132)	
			nlin++
			@nlin,01 psay 'Corte: ' + iif(TMP->ZAJ_CORORI = 'T','Traseiro',iif(TMP->ZAJ_CORORI = 'D','Dianteiro','Costela'))
			_cCorori := TMP->ZAJ_CORORI
			_nCol := 10		   
			nlin++
		endif

		if _cCateg <>  TMP->ZK_CATEG
			if _ncol <> 0 .and. !_lLin
				_lLin := .t.
				nlin++
			endif	
			@nlin,01 psay'Categoria: ' + fBuscaCPO('SZ5',1,xfilial('SZ5')+TMP->ZK_CATEG,'Z5_DESC')
			_cCateg := TMP->ZK_CATEG
			_nCol := 10		   
			nlin++
		endif

		if _cProgram <> TMP->ZK_PROGRAM
			if _ncol <> 0 .and. !_lLin
				_lLin := .t.
				nlin++
			endif	  
			@nlin,01 psay replicate('-',132)
			nlin++	   
			@nlin,01 psay 'Programa: ' + fBuscaCPO('SZ6',1,xfilial('SZ6')+TMP->ZK_PROGRAM,'Z6_DESC')
			_cProgram := TMP->ZK_PROGRAM
			_nCol := 10		   
			nlin++

			if _cClassif = TMP->ZK_CLASSIF  //Quando quebrar por Programa e a Classificação for igual ao ultimo registro antes da quebra,
				@nlin,01 psay  'Classificação: ' +  TMP->ZK_CLASSIF	//reescreve a classifcação
				_cClassif := TMP->ZK_CLASSIF
				nlin++
			endif
		endif                          

		if _cClassif <> TMP->ZK_CLASSIF
			if _ncol <> 0 .and. !_lLin
				_lLin := .t.
				nlin++
			endif	
			@nlin,01 psay  'Classificação: ' +  TMP->ZK_CLASSIF	
			_cClassif := TMP->ZK_CLASSIF
			_nCol := 10		   
			nlin++

			if _cDent = TMP->ZK_DENT //Quando quebrar por Classificação e a Dentição for igual ao ultimo registro antes da quebra reescreve a Dentição
				@nlin,01 psay replicate('-',132)		 //e reescreve a dentição
				nlin++	   
				@nlin,01 psay 'Dentição: ' + TMP->ZK_DENT		
				nlin++

				if _cCobGor = TMP->ZK_COBGOR   //se quebrar por classifcação e a dentição e a gordura forem iguals ao ultimo registro escrito reescreve 
					@nlin,01 psay replicate('-',132)   //a gordura
					nlin++	 		
					@nlin,05 psay 'Gordura: ' + TMP->ZK_COBGOR 
					nlin++					
				endif	
			endif

		endif         

		if _cDent <> TMP->ZK_DENT
			if _ncol <> 0 .and. !_lLin
				_lLin := .t.
				nlin++
			endif	                              
			@nlin,01 psay replicate('-',132)		
			nlin++	   
			@nlin,01 psay 'Dentição: ' + TMP->ZK_DENT		
			_cDent := TMP->ZK_DENT   			
			_nCol := 10		                                 
			nlin++  

			if _cCobGor = TMP->ZK_COBGOR //Quando quebrar por dentição e a Gordura for igual ao ultimo registro antes da quebra reescreve a Gordura
				@nlin,01 psay replicate('-',132)
				nlin++	 		
				@nlin,05 psay 'Gordura: ' + TMP->ZK_COBGOR 
				nlin++			
			endif				
		endif    

		if _cCobGor <> TMP->ZK_COBGOR
			if _ncol <> 0 .and. !_lLin
				_lLin := .t.
				nlin++
			endif	  	                                 
			@nlin,01 psay replicate('-',132)
			nlin++	   
			@nlin,05 psay 'Gordura: ' + TMP->ZK_COBGOR
			_cCobGor := TMP->ZK_COBGOR
			_nCol := 10		   
			nlin++
		endif    

		@nlin,_nCol    psay TMP->ZAJ_NUM
		@nlin,_nCol+12 psay TMP->ZAJ_CDIAN

		_lLin := .f.

		TMP->(DbSkip())

		if _nCol = 10
			_nCol := 30
		elseif _nCol = 30
			_nCol := 50
		elseif _nCol = 50
			_nCol := 70
		elseif _nCol = 70 
			_nCol := 90
		elseif _nCol = 90                                      	
			_nCol := 110
		elseif _nCol = 110
			_nCol := 10
			if _cDent = TMP->ZK_DENT
				nlin++     
			endif
		endif			
	EndDo


	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Finaliza a execucao do relatorio...                                 ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ

	DbCloseArea('TMP')

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
