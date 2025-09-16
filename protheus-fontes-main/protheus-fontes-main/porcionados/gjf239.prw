#INCLUDE "rwmake.ch"
#INCLUDE "topconn.ch"

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³GJF239     ºAutor  ³Giuliano Forgiariniº Data ³  05/01/16   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³   Relatorio de conferencia de produção de PA               º±±
±±º          ³   Com opção Analítico e Sintético                          º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ PCP                                                        º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±ºAjustado em 12/08/16 por Flávio                                        º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/

User Function GJF239()


	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Declaracao de Variaveis                                             ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ

	Local cDesc1         := "Este programa tem como objetivo imprimir relatorio"
	Local cDesc2         := "para conferencia de apontamentos de caixas de PAs "
	Local cDesc3         := "entre o processo de pesagem e estocagem das mesmas"
	//Local cPict          := ""
	Local titulo         := "CONFERENCIA DE PRODUÇÃO DE PA"
	Local Cabec1         := ""
	Local Cabec2         := ""
	//Local imprime        := .T.
	Local aOrd           := {}  
	Private nLin         := 80
	Private lEnd         := .F.
	Private lAbortPrint  := .F.
	Private CbTxt        := ""
	Private limite       := 80
	Private tamanho      := "P"
	Private nomeprog     := "GJF239" // Coloque aqui o nome do programa para impressao no cabecalho
	Private nTipo        := 18
	Private aReturn      := { "Zebrado", 1, "Administracao", 2, 2, 1, "", 1}
	Private nLastKey     := 0
	Private cPerg   	 := "GJF239"
	//Private cbtxt      	 := Space(10)
	Private cbcont     	 := 00
	Private CONTFL     	 := 01
	Private m_pag      	 := 01
	Private wnrel      	 := "GJF239" // Coloque aqui o nome do arquivo usado para impressao em disco    
	Private _nTotReg     := 0 
	Private _cQuery      := ''

	pergunte(cPerg,.F.)

	/* Parâmetros
	mv_par01 = Identifica a Data da Produção a ser filtrada
	mv_par02 = Caso queira filtrar um produto em específico 
	mv_par03 = Escolher se quer o relatório no formato analítico ou sintético.
	mv_par04 = Caso queira que o relatório imprima toda produção (Caixas que estão da câmara), Marcar a Opção "SIM" 
	*/

	wnrel := SetPrint('ZAS',NomeProg,cPerg,@titulo,cDesc1,cDesc2,cDesc3,.T.,aOrd,.T.,Tamanho,,.T.)  

	If nLastKey == 27
		Return
	Endif

	If mv_par03 = 1
		Cabec1 := 'Produto   Descrição'
		Cabec2 := '     Cod. Cx.     Dt. Saida    Hora Saída    Status'
	Elseif mv_par03 = 2     // Sintético com Caixas OK!
		Cabec1 := '    Produto   Descrição'
		Cabec2 := '                                           OK       Ajuste      Fora câmara'
	Elseif mv_par03 = 2 .and. mv_par04 = 2
		Cabec1 := '    Produto   Descrição'
		Cabec2 := '                                                    Ajuste      Fora câmara'
	Endif


	SetDefault(aReturn,'ZAS')

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

	Cabec(Titulo,Cabec1,Cabec2,NomeProg,Tamanho,nTipo)
	nLin := 9


	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ SETREGUA -> Indica quantos registros serao processados para a regua ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ

	MsgRun("Selecionando os registros...",,{|| GeraQuery()})

	SetRegua(_nTotReg)

	_cCodPro := ''
	_nQuant1	 := 0
	_nQuant2	 := 0
	_nQuant3	 := 0
	_nPrim	 := 1
	while PROD->(!eof())  

		incregua()

		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³ Verifica o cancelamento pelo usuario...                             ³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ

		If lAbortPrint
			@nLin,00 PSAY "*** CANCELADO PELO OPERADOR ***"
			Exit
		Endif     

		_CaixaPA := ''  	  		
		DbSelectArea('SZ8')
		_CaixaPA := fBuscaCPO('SZ8',3,xfilial('SZ8') + PROD->ZAS_CONTRO,'Z8_CONTROL')

		if !empty(_CaixaPA)	  	  	

			_cStatus := 'OK!'

		elseif  empty(_CaixaPA) .and. !empty(PROD->ZAS_DATAS) .and. !empty(PROD->ZAS_HORAS)

			_cStatus := 'juste'

		else 

			_cStatus := 'Não Scaneada para as Câmara'

		endif


		If mv_par03 = 1 // Para relatório analítico

			If nLin > 55 
				Cabec(Titulo,Cabec1,Cabec2,NomeProg,Tamanho,nTipo)
				nLin := 9
			Endif

			if  _cCodPro <> PROD->ZAS_COD 		        

				If mv_par04 = 2 .and. _cStatus = 'OK!'  

					// O Sistema não mostra caixas ok


				Else

					@nlin,005 psay PROD->ZAS_COD
					@nlin,015 psay PROD->ZAS_DESC  	  		  	  	    
					_cCodPro := PROD->ZAS_COD	  	  	   
					nlin++

					If nLin > 55 // Salto de Página. Neste caso o formulario tem 55 linhas...
						Cabec(Titulo,Cabec1,Cabec2,NomeProg,Tamanho,nTipo)
						nLin := 9
					Endif

				Endif

			endif

			//_CaixaPA := ''  	  		

			//DbSelectArea('SZ8')
			//_CaixaPA := fBuscaCPO('SZ8',3,xfilial('SZ8') + PROD->ZAS_CONTRO,'Z8_CONTROL')

			//if !empty(_CaixaPA)

			//	_cStatus := 'OK!'

			//elseif  empty(_CaixaPA) .and. !empty(PROD->ZAS_DATAS) .and. !empty(PROD->ZAS_HORAS)
			//if  empty(_CaixaPA) .and. !empty(PROD->ZAS_DATAS) .and. !empty(PROD->ZAS_HORAS)

			//   _cStatus := 'Ajuste'

			//else 

			//   _cStatus := 'Não Scaneada para as Câmara'

			//endif  


			If mv_par04 = 2 .and. _cStatus = 'OK!'  

				// O Sistema não mostra caixas que sestão ok

			Else
				@nlin,005 psay PROD->ZAS_CONTRO  + '      ' +;
				dtoc(stod(PROD->ZAS_DATAS)) + '      ' +;
				PROD->ZAS_HORAS + '      ' + _cStatus
				nlin++
			Endif	  	  	  	  	  	  	  	  	  	  	  	  	


			PROD->(DbSkip())  

		elseif mv_par03 = 2  //.and. _CaixaPA <> 'OK' Para impressão do Relatório Sintético

			if  _cCodPro <> PROD->ZAS_COD 

				If mv_par04 = 2 .and. _cStatus = 'OK!'  

					// O Sistema não mostra caixas ok

				Else
					if _nPrim = 1
						@nlin,005 psay PROD->ZAS_COD
						@nlin,015 psay PROD->ZAS_DESC  	  		  	  	                    
						_cCodPro := PROD->ZAS_COD
						_nPrim++

					Else   
						@nlin,045 psay _nQuant1
						@nlin,055 psay _nQuant2
						@nlin,065 psay _nQuant3
						nlin++ 
						@nlin,005 psay PROD->ZAS_COD
						@nlin,015 psay PROD->ZAS_DESC  	  		  	  	                    


						_nQuant1 := 0	  	  	   
						_nQuant2 := 0
						_nQuant3 := 0
						_cCodPro := PROD->ZAS_COD
						//nlin++  	  				       
					Endif	  

				Endif

			endif

			_CaixaPA := ''  	  		

			DbSelectArea('SZ8')

			_CaixaPA := fBuscaCPO('SZ8',3,xfilial('SZ8') + PROD->ZAS_CONTRO,'Z8_CONTROL')

			If mv_par04 = 2 .and. _cStatus = 'OK!'  
				// Não Mostrar caixas OK!Ä
			Else
				if !empty(_CaixaPA)
					_cStatus := 'OK!'
					_nQuant1++
				elseif  empty(_CaixaPA) .and. !empty(PROD->ZAS_DATAS) .and. !empty(PROD->ZAS_HORAS)
					_cStatus := 'Ajuste'
					_nQuant2++
				else 
					_cStatus := 'Não Scaneada para as Câmara'
					_nQuant3++
				endif  	  	  		 	  

			Endif

			PROD->(DbSkip()) 

		Endif


	enddo 

	If mv_par03 = 2  


		If mv_par04 = 2 .and. _cStatus = 'OK!'  

			// O Sistema não mostra caixas ok

		Else
			@nlin,045 psay _nQuant1	
			@nlin,055 psay _nQuant2
			@nlin,065 psay _nQuant3
			nlin++                 
		Endif

	Endif

	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Finaliza a execucao do relatorio...                                 ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ

	SET DEVICE TO SCREEN

	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Se impreHssao em disco, chama o gerenciador de impressao...          ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ

	If aReturn[5]==1
		dbCommitAll()
		SET PRINTER TO
		OurSpool(wnrel)
	Endif

	MS_FLUSH()

Return

//Função para gerar a query...
Static Function GeraQuery()


	_cQuery := " SELECT * "
	_cQuery += " FROM " + RetSqlTab("ZAS") 
	_cQuery += " WHERE "
	_cQuery += RetSQLFil('ZAS') + " AND ZAS_DTPROD = '" + dtos(mv_par01) + "' AND ZAS_TIPO = 'PA' "      
	_cQuery += " AND " + retSqlDel('ZAS')

	If  !empty(mv_par02)

		_cQuery += " AND ZAS_COD = " + mv_par02	

	Endif

	_cQuery += " ORDER BY  ZAS_COD



	_cQuery := ChangeQuery(_cQuery)

	//	* Mostrar a consulta */
	//@ 116,090 To 416,707 Dialog oDlgMemo Title "Consulta"
	//@ 055,005 Get _cQuery Size 250,080 MEMO Object oMemo
	//Activate Dialog oDlgMemo
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Monta a interface padrao com o usuario...                           ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ   


	If Select("PROD") != 0
		PROD->(dbCloseArea())
	Endif
	TCQUERY _cQuery NEW ALIAS "PROD" 

	while PROD->(!eof())
		_nTotReg++
		PROD->(DbSkip())
	enddo

	PROD->(DbGoTop())

return
