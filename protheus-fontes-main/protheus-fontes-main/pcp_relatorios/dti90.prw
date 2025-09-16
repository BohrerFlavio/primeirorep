#INCLUDE "rwmake.ch"
#INCLUDE "topconn.ch"

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³DTI90   º Autor ³ Fabian Maurer  º Data ³  05/08/20	      º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDescricao ³ Relatorio de Endereçamento de Peças		                  º±±
±±º          ³ 		 						                              º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ PCP (SIGAPCP)					  	 	                  º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/

User Function DTI90()


	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Declaracao de Variaveis                                             ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ

	Local cDesc1         	:= "Este programa tem como objetivo imprimir relatorio  "
	Local cDesc2         	:= "de enderecamento de pecas    "
	Local cDesc3         	:= ""
	Local cPict          	:= "Relatorio de Enderecamento de Pecas  "
	Local titulo       		:= "ENDERECAMENTO DE PECAS"
	Local nLin         		:= 80

	Local Cabec1       		:= 	  "  Numero          Control          Codigo          Descri          Numam         Lote          Lado          Peso          Local          Corte Origem"                   
	Local Cabec2       		:= 	  " "
	Local imprime      		:= .T.
	Local aOrd := {}
	Private lEnd         	:= .F.
	Private lAbortPrint  	:= .F.
	Private CbTxt        	:= ""
	Private limite           := 80
	Private tamanho          := "G"
	Private nomeprog         := "DTI90" // Coloque aqui o nome do programa para impressao no cabecalho
	Private nTipo            := 18
	Private aReturn          := { "Zebrado", 1, "Administracao", 2, 2, 1, "", 1}
	Private nLastKey        := 0
	Private cPerg   := "DTI90"
	Private cbtxt      := Space(10)
	Private cbcont     := 00
	Private CONTFL     := 01
	Private m_pag      := 01
	Private wnrel      := "DTI90" // Coloque aqui o nome do arquivo usado para impressao em disco    

	pergunte(cPerg,.F.)

	//para verificação se existe previsao de pesagem 

	//u_mlr05b()

	wnrel := SetPrint('ZAJ',NomeProg,cPerg,@titulo,cDesc1,cDesc2,cDesc3,.T.,aOrd,.T.,Tamanho,,.T.)

	cQuery := " SELECT ZAJ_NUM, ZAJ_CONTRO, ZAJ_COD, ZAJ_DESCRI, ZAJ_NUMAM, ZAJ_LOTE, ZAJ_LADO, ZAJ_PESO, ZAJ_DATA, ZAJ_LOCAL, ZAJ_CORORI"
	cQuery += " FROM " + RetSQLTab('ZAJ')
	cQuery += " WHERE " + RetSQLFil('ZAJ') + " AND ZAJ_FILIAL = '" + cFilAnt  + "' AND "
	cQuery += " ZAJ_DATAS = ' ' AND ZAJ_HORAS = ' ' AND ZAJ_PRECAR = ' ' AND ZAJ_PREPED = ' ' AND ZAJ_ITEM = ' ' " 
	
	if mv_par01 <> 4
		cQuery += " AND ZAJ_CORORI = '" + iif(mv_par01 = 1,'T',iif(mv_par04 = 2,'D','C')) + "'" 
	endif
	
	cQuery += " AND " +RetSQLDel('ZAJ')
 
	cQuery += " ORDER BY ZAJ_LOCAL, ZAJ_COD, ZAJ_DESCRI, ZAJ_DATA, ZAJ_CONTRO"

	cQuery := ChangeQuery(cQuery)

	//	* Mostrar a consulta */
	//@ 116,090 To 416,707 Dialog oDlgMemo Title "Consulta"
	//@ 055,005 Get cQuery Size 250,080 MEMO Object oMemo
	//Activate Dialog oDlgMemo
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Monta a interface padrao com o usuario...                           ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ

	If Select("QRY") != 0
		QRY->(dbCloseArea())
	Endif
	TCQUERY cQuery NEW ALIAS "QRY"
	
	
	If nLastKey == 27
		Return
	Endif

	SetDefault(aReturn,'ZAJ')

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
	//Local _ntotCaix
	//Local _ntotPeso
	//Local _nTotGerCaix := 0
	//Local _nTotGerPeso := 0
	
	Local nOrdem
	Local _cData    := ''
	Local _cCorori  := ''
	Local _cCam		:= ''
	Local _nCol     := 1
	Local _lLin     := .f.

	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ SETREGUA -> Indica quantos registros serao processados para a regua ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	_cCod := space(6)
 
	QRY->(dbGoTop())

	QRY->(SetRegua(RecCount()))

	While QRY->(!EOF())

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

		if _cData <> QRY->ZAJ_DATA 
			if _ncol <> 0 .and. !_lLin
				_lLin := .t.
				nlin++
			endif
			@nlin,01 psay 'Data de Produção: ' + dtoc(stod(QRY->ZAJ_DATA))
			_cData := QRY->ZAJ_DATA 
			_nCol := 10		   
			nlin++
		endif
		
		if _cCam <> QRY->ZAJ_LOCAL 
			if _ncol <> 0 .and. !_lLin
				_lLin := .t.
				nlin++
			endif
			@nlin,01 psay replicate('*',132)	
			nlin++
			@nlin,01 psay 'Camara: ' + QRY->ZAJ_LOCAL
			_cCam := QRY->ZAJ_LOCAL 
			_nCol := 10		   
			nlin++
			@nlin,01 psay replicate('*',132)	
			nlin++
		endif

		if _cCorori <> QRY->ZAJ_CORORI   
			if _ncol <> 0 .and. !_lLin
				_lLin := .t.
				nlin++
			endif
			@nlin,01 psay replicate('-',132)	
			nlin++
			@nlin,01 psay 'Corte: ' + iif(QRY->ZAJ_CORORI = 'T','Traseiro',iif(QRY->ZAJ_CORORI = 'D','Dianteiro','Costela'))
			_cCorori := QRY->ZAJ_CORORI
			_nCol := 10		   
			nlin++
		endif
		
		@nlin,_nCol    psay QRY->ZAJ_NUM
		//nlin++

		/*if _cCod <> QRY->ZAJ_COD
			nlin++
			@nlin,02 psay alltrim(QRY->ZAJ_NUM) + '   ' + fbuscaCPO('SB1',1,xfilial('SB1')+alltrim(QRY->ZAJ_COD), 'B1_DESCRED')
			nlin++  
			_nTotCaix := 0 
			_nTotPeso := 0
			_cCod := QRY->ZAJ_COD
		endif

		_cPeca := QRY->ZAJ_CONTRO  +  '   ' + transform(QRY->ZAJ_PESO,'@E 999,999.99') +;
		'      '+ DTOC(STOD(QRY->ZAJ_DATA)) + '      ' + QRY->ZAJ_LOCAL;
		//'   ' + QRY->HORA + '   ' + alltrim(QRY->BALAN) + '   ' + DTOC(STOD(QRY->DATAR)) + '   ' + transform(QRY->TARA,'@E 9.999') + ;
		//'   ' + transform(QRY->QUANT,'@E 999') + '   ' +  transform(QRY->PESOBR,'@E 999,999.99') + '   ' + QRY->OPERA     

		@nlin,02 psay _cPeca  
		_nTotCaix++
		_nTotPeso += QRY->ZAJ_PESO
		_nTotGerCaix++
		_nTotGerPeso += QRY->ZAJ_PESO
		nlin++              
*/
	
	    _lLin := .f.
		
		QRY->(dbSkip()) // Avanca o ponteiro do registro no arquivo  

		/*if _cCod <> QRY->ZAJ_COD 

			If nLin > 75 // Salto de Página. Neste caso o formulario tem 55 linhas...
				Cabec(Titulo,Cabec1,Cabec2,NomeProg,Tamanho,nTipo)
				nLin := 9
			Endif 

			@nlin,02 psay 'Total Pecas: ' + transform(_nTotCaix,'@E 999,999')+ '   '+ 'Total Peso: '+ transform(_nTotPeso,'@E 999,999.99')
			nlin++ 
		endif
		*/
		
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
			nlin++
		endif
		
	EndDo 

	nlin++
	
	/*QRY2->(dbGoTop())

	QRY2->(SetRegua(RecCount()))

	While QRY2->(!EOF())

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

		if _cCod <> QRY2->COD2
			nlin++
			@nlin,02 psay alltrim(QRY2->COD2) + '   ' + fbuscaCPO('SB1',1,xfilial('SB1')+alltrim(QRY2->COD2), 'B1_DESCRED')
			nlin++  
			_nTotCaix := 0 
			_nTotPeso := 0
			_cCod := QRY2->COD2
		endif
		
		_dDtProd  := QRY2->DATAP2
		_dDtValid := STOD(_dDtProd) + QRY2->VALID2

		_cCaixa := QRY2->CONTROL2  + '   ' + transform(QRY2->PESO2,'@E 999,999.99') +;
		'      '+ DTOC(STOD(QRY2->DATAP2)) + '      ' + DTOC(_dDtValid) + '      ' + QRY2->CAMARA2;
		//'   ' +  transform(QRY2->PESOBR2,'@E 999,999.99') + '   ' + transform(QRY2->TARA2,'@E 9.999') +;
		//'   ' + DTOC(STOD(QRY2->DATAR2)) + '   ' + QRY2->HORA2 +'   ' + alltrim(QRY2->BALAN2) +;
		//'   ' + QRY2->OPERA2 + '   ' + iif(QRY2->TF2 = 'S','Sim','  ') + '   ' + QRY2->CAMARA2    

		@nlin,02 psay _cCaixa  
		_nTotCaix++
		_nTotPeso += QRY2->PESO2
		_nTotGerCaix++
		_nTotGerPeso += QRY2->PESO2
		nlin++              

		QRY2->(dbSkip()) // Avanca o ponteiro do registro no arquivo  

		if _cCod <> QRY2->COD2 

			If nLin > 75 // Salto de Página. Neste caso o formulario tem 55 linhas...
				Cabec(Titulo,Cabec1,Cabec2,NomeProg,Tamanho,nTipo)
				nLin := 9
			Endif 

			@nlin,02 psay 'Total Caixas: ' + transform(_nTotCaix,'@E 999,999')+ '   '+ 'Total Peso: '+ transform(_nTotPeso,'@E 999,999.99')
			nlin++ 
		endif
	EndDo 

	nlin++


	If nLin > 75 // Salto de Página. Neste caso o formulario tem 55 linhas...
		Cabec(Titulo,Cabec1,Cabec2,NomeProg,Tamanho,nTipo)
		nLin := 9
	Endif 
	
	
	@nlin,02 psay 'Total Geral Caixas: ' + transform(_nTotGerCaix,'@E 999,999')+ '   '+;
	'Total Geral Peso: '+ transform(_nTotGerPeso,'@E 999,999.99')	
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Finaliza a execucao do relatorio...                                 ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ

	DbCloseArea('QRY2')
*/
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
