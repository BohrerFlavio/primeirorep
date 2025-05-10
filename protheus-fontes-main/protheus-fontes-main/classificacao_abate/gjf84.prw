#INCLUDE "rwmake.ch"

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³GJF84     º Autor Giuliano Forgiarini  º Data ³  05/06/09   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDescricao ³ Relatório resumo de rastreabilidade                        º±±
±±º          ³                                                            º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ Qualidade (SIGAPCP)                                        º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/

User Function GJF84()                         

	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Declaracao de Variaveis                                             ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ

	Local cDesc1       := "Este programa tem como objetivo imprimir relatorio "
	Local cDesc2       := "de resumo de informações de desclassificações e    "
	Local cDesc3       := "carcaças com rastreabilidade habilitadas           "
	//Local cPict        := ""
	Local titulo       := "R4 - RESUMO DA RASTREABILIDADE"
	Local Cabec1       := ""
	Local Cabec2       := ""
	//Local imprime      := .T.
	Local aOrd := {}        
	Private nLin         := 80
	Private lEnd        := .F.
	Private lAbortPrint := .F.
	Private CbTxt       := ""
	Private limite      := 132
	Private tamanho     := "M"
	Private nomeprog    := "GJF84" // Coloque aqui o nome do programa para impressao no cabecalho
	Private nTipo       := 18
	Private aReturn     := { "Zebrado", 1, "Administracao", 2, 2, 1, "", 1}
	Private nLastKey    := 0
	Private cPerg       := "GJF84"
	//Private cbtxt       := Space(10)
	Private cbcont      := 00
	Private CONTFL      := 01
	Private m_pag       := 01
	Private wnrel      := "GJF84" // Coloque aqui o nome do arquivo usado para impressao em disco

	Private cString := "SZ4"

	dbSelectArea("SZ4")

	pergunte(cPerg,.F.)

	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Monta a interface padrao com o usuario...                           ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ

	wnrel := SetPrint(cString,NomeProg,cPerg,@titulo,cDesc1,cDesc2,cDesc3,.T.,aOrd,.T.,Tamanho,,.T.)

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

	//Local nOrdem
	//Local _cLote    := space(6)
	//Local _nQtd     := 0            //Quantidade total de animais   
	Local _nQTDL    := 0            //Quantidade de animais por lote
	Local _nDescRec := 0            //Desclassificados no recebimento   
	Local _MotSB    := 0            //Motivo de desclassificação sem brinco  
	Local _MotBR    := 0            //Motivo de desclassificação brinco errado
	Local _MotSE    := 0            //Motivo de desclassificação sexo errado
	Local _MotID    := 0            //Motivo de desclassificação Idade
	Local _MotPr    := 0            //Motivo de desclassificação Propriedade
	Local _MotLc    := 0            //Motivo de desclassificação Localidade     
	Local _MotIF    := 0            //Motivo de desclassificação IF
	Local _MotMt    := 0            //Motivo de desclassificação por maturação
	Local _MotPh    := 0            //Motivo de desclassificação por Ph    
	Local _nGC      := 0            //Graxaria ou Conserva  
	Local _nRast    := 0            //Quantidade de rastreados de fé  
	Local _nIRast   := 0            //Quantidade de animais com rastreabilidade inapta
	Local _nQtdHK   := 0	           	//Quantidade de Animais HK
	Local _nQtdNE   := 0            	//Quantidade de Animais NE
	Local _nQtdRU   := 0 			  	//Quantidade de Animais RU
	Local _nQtdUSA   := 0 			  	//Quantidade de Animais RT
	Local _nQtdRT	:= 0 				//Quantidade de Animais RT
	Local _nTotRT	:= 0 				//Total de Animais RT
	Local _nQtHKUy  := 0 			  	//Quantidade de Animais HK - UY
	Local _nQtHKCn  := 0 			 	//Quantidade de Animais HK - CN
	Local _nQtRuUy  := 0				//Quantidade de Animais RU - UY
	Local _nQtRuCn  := 0				//Quantidade de Anumais Ru - CN
	Local _nQtdBR 	:= 0				//Quantidade de Animais BR
	Local _nTotHK   := 0	          	//Total de Animais HK
	Local _nTotBR 	:= 0 	          	//Total de Animais BR
	Local _nTotNE   := 0           	 	//Total de Animais NE
	Local _nTotRU   := 0 			  	//Total de Animais RU
	Local _nTotUSA   := 0 			  	//Total de Animais RT
	Local _nTtHKUy  := 0 			  	//Total de Animais HK - UY
	Local _nTtHKCn  := 0 			  	//Total de Animais HK - CN
	Local _nTtRuUy  := 0				//Total de Animais RU - UY
	Local _nTtRuCn  := 0				//Total de Animais RU - CN	
	local i

	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ SETREGUA -> Indica quantos registros serao processados para a regua ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ

	SetRegua(RecCount())

	SZ4->(dbGoTop())
	SZ4->(dbsetorder(1))   
	SZ4->(MsSeek(FWxfilial('SZ4')+mv_par01))
	While SZ4->(!EOF()) .and. FWxfilial('SZ4') = SZ4->Z4_FILIAL .and. SZ4->Z4_NUMAM = mv_par01

		incregua()  

		if  SZ4->Z4_LOTE < mv_par02 .or. SZ4->Z4_LOTE > mv_par03
			SZ4->(dbskip())
			loop
		endif

		if mv_par04 = 1
			if SZ4->Z4_RASTRO <> 'S'
				SZ4->(DbSkip())
				loop
			endif
		endif

		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³ Verifica o cancelamento pelo usuario...                             ³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ

		If lAbortPrint
			@nLin,00 PSAY "*** CANCELADO PELO OPERADOR ***"
			Exit
		Endif

		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³ Impressao do cabecalho do relatorio. . .                            ³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ

		_dDtAM := dtoc(GetAdvFval('SZG','ZG_DATA',FWxfilial('SZG')+SZ4->Z4_NUMAM,1))
		_nAnim := GetAdvFval('SZG','ZG_QTDTOT',FWxfilial('SZG')+SZ4->Z4_NUMAM,3)

		Cabec1 := '  Ordem de Matança Nr.: ' + SZ4->Z4_NUMAM + '      Data: ' + _dDtAM + '      Nr. de Animais: ' + transform(_nAnim,"@E 9,999")

		If nLin > 75 
			Cabec(Titulo,Cabec1,Cabec2,NomeProg,Tamanho,nTipo)
			nLin := 8
		endif 

		_nDescRec := 0	          //Desclassificação no recebimento
		_MotSB    := 0            //Motivo de desclassificação sem brinco  
		_MotBR    := 0            //Motivo de desclassificação brinco errado
		_MotSE    := 0            //Motivo de desclassificação sexo errado
		_MotID    := 0            //Motivo de desclassificação Idade
		_MotPr    := 0            //Motivo de desclassificação Propriedade
		_MotLc    := 0            //Motivo de desclassificação Localidade   
		_MotIF    := 0            //Motivo de desclassificação IF
		_MotMt    := 0            //Motivo de desclassificação por maturação
		_MotPh    := 0            //Motivo de desclassificação por Ph 
		_nGC      := 0            //Graxaria ou conserva   
		_nRast    := 0            //Rastreados de fé  
		_nQTDL    := 0            //Quantidade de animais por lote 
		_nIRast   := 0            //Quantidade de animais com rastreabilidade inapta   
		_nQtdHK   := 0	          //Quantidade de Animais HK
		_nQtdBR	  := 0			  //Quantidade de Animais BR
		_nQtdNE   := 0            //Quantidade de Animais NE
		_nQtdRU   := 0 			  //Quantidade de Animais RU
		_nQtdUSA  := 0 			  //Quantidade de Animais USA
		 _nQtdRT  := 0 			  //Quantidade de Animais RT
		_nTotRT	  := 0 			  //Quantidade de Animais RT
		_nQtHKUy  := 0 			  //Quantidade de Animais HK - UY
		_nQtHKCn  := 0 			  //Quantidade de Animais HK - CN
		_nQtRuCn  := 0			  //Quantidade de Animais RU - CN
		_nQtRuUy  := 0			  //Quantidade de Animais RU - UY
		_aCarc    := {}
		i         := 1
		_lLin 	  := 1
		_mMotDescl:='              '

		SZK->(DbSetOrder(2))
		SZK->(DbGoTop())
		SZK->(MsSeek(FWxfilial('SZK')+SZ4->(Z4_NUMAM+Z4_LOTE)))

		while SZK->(!eof()) .and. FWxfilial('SZK') = SZK->ZK_FILIAL .and.	SZK->ZK_NUMAM = SZ4->Z4_NUMAM  .and. SZK->ZK_LOTE = SZ4->Z4_LOTE   

			_nQTDL++ 

			do case
				case AllTrim(SZK->ZK_CLASSIF) = 'HK' .and. SZK->ZK_CLASESP <> '1'
				_nQtdHK++        
				_nTotHK++
				case AllTrim(SZK->ZK_CLASSIF) = 'BR' //.and. SZK->ZK_CLASESP <> '1'
				_nQtdBR++        
				_nTotBR++
				case AllTrim(SZK->ZK_CLASSIF) = 'NE'
				_nQtdNE++
				_nTotNE++
				case AllTrim(SZK->ZK_CLASSIF) = 'RU' .and. SZK->ZK_CLASESP <> '1'
				_nQtdRU++
				_nTotRU++
				case AllTrim(SZK->ZK_CLASSIF) = 'USA'
				_nQtdUSA++
				_nTotUSA++
				case AllTrim(SZK->ZK_CLASSIF) = 'RT'
				_nQtdRT++
				_nTotRT++
				case AllTrim(SZK->ZK_CLASSIF) = 'HK' .and. SZK->ZK_CLASESP = '1' .and. SZK->ZK_DENT > '4'
				_nQtHKUy++
				_nTtHKUy++
				case AllTrim(SZK->ZK_CLASSIF) = 'HK' .and. SZK->ZK_CLASESP = '1' .and. SZK->ZK_DENT <= '4'
				_nQtHKCn++
				_nTtHKCn++
				case AllTrim(SZK->ZK_CLASSIF) = 'RU' .and. SZK->ZK_CLASESP = '1' .and. SZK->ZK_DENT > '4'
				_nQtRuUy++
				_nTtRuUy++
				case AllTrim(SZK->ZK_CLASSIF) = 'RU' .and. SZK->ZK_CLASESP = '1' .and. SZK->ZK_DENT <= '4'
				_nQtRuCn++
				_nTtRuCn++
			endcase

			AADD(_aCarc,{SZK->ZK_CONTROL,1})
			//NUMERO DE ANIMAIS CLASSIFICADOS COM RASTREABILIDADE//
			if AllTrim(SZK->ZK_CLASSIF) $ 'RT'
				_nRast++ 
				AADD(_aCarc,{SZK->ZK_CONTROL,2})
				SZK->(DbSkip())
				loop
			endif

			//DESCLASSIFICAÇÃO DE ANIMAIS NO RECEBIMENTO/CURRAIS//	                           	 
			if SZ4->Z4_RASTRO = 'S'	 
				if !(AllTrim(SZ4->Z4_CLASSIF)  = 'RT')
					_nDescRec++ 
					AADD(_aCarc,{SZK->ZK_CONTROL,3})
					_nIRast++ 
					AADD(_aCarc,{SZK->ZK_CONTROL,4})
				endif    

				if AllTrim(SZ4->Z4_CLASSIF)  = 'RT' .and. SZK->ZK_OBS <> '0' //.and. SZK->ZK_IF <> 'S'
					do case                                                       
						case SZK->ZK_OBS = '1' 
							_MotSB++           //Motivo de desclassificação sem brinco 
							AADD(_aCarc,{SZK->ZK_CONTROL,5})
						case SZK->ZK_OBS = '2'
							_MotBR++           //Motivo de desclassificação brinco errado 
							AADD(_aCarc,{SZK->ZK_CONTROL,6}) 
						case SZK->ZK_OBS = '3'    		                                  
							_MotSE++           //Motivo de desclassificação sexo errado
							AADD(_aCarc,{SZK->ZK_CONTROL,7})
						case SZK->ZK_OBS = '4'     
							_MotID++           //Motivo de desclassificação Idade 
							AADD(_aCarc,{SZK->ZK_CONTROL,8}) 
						case SZK->ZK_OBS = '5'
							_MotPr++           //Motivo de desclassificação Propriedade  
							AADD(_aCarc,{SZK->ZK_CONTROL,9})
						case SZK->ZK_OBS = '6'					
							_MotLc++           //Motivo de desclassificação Localidade
							AADD(_aCarc,{SZK->ZK_CONTROL,10})
					endcase 
					_nIRast++ 
					AADD(_aCarc,{SZK->ZK_CONTROL,4})
				endif 

				if AllTrim(SZK->ZK_CLASABA) <> 'RT'  ;
				.and. SZK->ZK_IF = 'S'         ;
				.and. SZK->ZK_MATURA = 'S'     ;
				.and. SZK->ZK_TUBERC = 'N'             //Motivo de desclassificação pelo DIF 
					_MotIF++ 
					AADD(_aCarc,{SZK->ZK_CONTROL,11})
				endif

				if AllTrim(SZ4->Z4_CLASSIF) = 'RT';
				.and. SZK->ZK_MATURA = 'N'     ; 
				.and. SZK->ZK_TUBERC = 'N'     //Motivo de desclassificação por Maturação
					_MotMt++
					AADD(_aCarc,{SZK->ZK_CONTROL,12})
					_nIRast++
					AADD(_aCarc,{SZK->ZK_CONTROL,4})
				endif

				if SZK->ZK_CLASABA <> SZK->ZK_CLASSIF ;
				.and. SZK->ZK_MATURA = 'S'         ;
				.and. SZK->ZK_TUBERC = 'N'         ;
				.and. AllTrim(SZK->ZK_CLASABA) = 'RT'     	   //Motivo de desclassificação por Ph
					_MotPh++
					AADD(_aCarc,{SZK->ZK_CONTROL,13}) 
					_nIRast++
					AADD(_aCarc,{SZK->ZK_CONTROL,4})
				endif
			endif

			if SZK->ZK_DESTINO $ 'G/S'
				_nGC++
				AADD(_aCarc,{SZK->ZK_CONTROL,14})
			endif

			i++

			SZK->(DbSkip())
		enddo

		If nLin > 75 
			Cabec(Titulo,Cabec1,Cabec2,NomeProg,Tamanho,nTipo)
			nLin := 8
		endif 			

		@nlin,02 psay 'Sequência de Abate: ' + strzero(SZ4->Z4_ORDEM,6) + '       ' +;
		'Lote n.: ' + SZ4->Z4_LOTE                    + '       ' +;
		'Classificação: ' + SZ4->Z4_CLASSIF           + '       ' +;
		'Nr. Animais:   ' + transform(_nQTDL,'@E 999')
		nlin++
		@nlin,02 psay 'Nr.Animais USA:     ' + transform(_nQtdUSA,'@E 999')
		nlin++
		@nlin,02 psay 'Nr.Animais RT:     ' + transform(_nQtdRT,'@E 999')
		nlin++
		@nlin,02 psay 'Nr.Animais HK:      ' + transform(_nQtdHK,'@E 999')
		nlin++
		@nlin,02 psay 'Nr.Animais BR:      ' + transform(_nQtdBR,'@E 999')
		nlin++
		@nlin,02 psay 'Nr.Animais NE:      ' + transform(_nQtdNE,'@E 999')
		nlin++
		@nlin,02 psay 'Nr.Animais RU:      ' + transform(_nQtdRU,'@E 999')
		nlin++
		@nlin,02 psay 'Nr.Animais HK - UY: ' + transform(_nQtHKUy,'@E 999')
		nlin++
		@nlin,02 psay 'Nr.Animais HK - CN: ' + transform(_nQtHKCn,'@E 999')
		nlin++	
		@nlin,02 psay 'Nr.Animais RU - UY: ' + transform(_nQtRuUy,'@E 999')
		nlin++
		@nlin,02 psay 'Nr.Animais RU - CN: ' + transform(_nQtRuCn,'@E 999')

		if SZ4->Z4_RASTRO = 'S'            //Se o lote for de animais rastreados

			@nlin,102 psay '[Lote de animais rastreados]'
			nlin++
			if !(AllTrim(SZ4->Z4_CLASSIF)  $ 'RT/RA') 
				nlin++
				@nlin,02 psay padc('### Lote com rastreabilidade desclassificada por problemas em sua documentação ###',128,'')
				nlin += 2 
				@nlin,00 psay 'Numero de Animais desclassificados no recebimento: ' + transf(_nDescRec++,'@E 999')
				nlin++
				_col := 4
				_lLin = 1
				_nQuant := len(_aCarc) 
				if  _nDescRec > 0 .and. _nQuant > 1
					@nlin,06 psay 'Seq.    câmara           Seq.    câmara       '
					nLin++  
				elseif _nQuant = 1  
					@nlin,06 psay 'Seq.    câmara '
					nLin++
				endif
				for i := 1 to len(_aCarc) 
					if _aCarc[i,2] = 3
						_cam := GetAdvFval('SZK','ZK_LOCAL',FWxfilial('SZK')+SZ4->Z4_NUMAM+_aCarc[i,1],4)
						if _lLin = 1
							@nlin,_col psay _aCarc[i,1] + '       ' + _cam 
							_lLin := 2
						elseif _lLin = 2
							@nlin,24 psay '|'
							@nlin,29 psay _aCarc[i,1] + '       ' + _cam 
							_lLin := 1
							nlin++		
						endif 	
					endif
				next
			else	           
				nlin++   
				@nlin,02 psay 'Total de Animais com rastreabilidade inapta: ' + transform(_nIRast,'@E 999')   
				nlin+=2

				If nLin > 75 
					Cabec(Titulo,Cabec1,Cabec2,NomeProg,Tamanho,nTipo)
					nLin := 8
				endif 		 

				if _MotSB <> 0  //Motivo de desclassificação sem brinco 
					@nlin,04 psay '- Animais sem brinco:                ' + transform(_MotSB,'@E 999') 
					nlin++
					_col := 6
					_lLin = 1 
					if  _MotSB > 0 
						@nlin,06 psay 'Seq.    câmara           Seq.    câmara       '	  
					endif 
					nLin++
					for i := 1 to len(_aCarc) 
						if _aCarc[i,2] = 5 
							_cam := GetAdvFval('SZK','ZK_LOCAL',FWxfilial('SZK')+SZ4->Z4_NUMAM+_aCarc[i,1],4)  
							if _lLin = 1
								@nlin,_col psay _aCarc[i,1] + '       ' + _cam 
								_lLin := 2
							elseif _lLin = 2
								@nlin,24 psay '|'
								@nlin,29 psay _aCarc[i,1] + '       ' + _cam 
								_lLin := 1
								nlin++		
							endif 	
						endif 
					next
					nlin++
				endif
				if _MotBR <> 0            //Motivo de desclassificação brinco errado   
					nlin++
					@nlin,04 psay '- Animais com brinco errado:         ' + transform(_MotBR,'@E 999') 
					nlin++
					_col := 6
					_lLin = 1   

					if  _MotBR > 0 
						@nlin,06 psay 'Seq.    câmara           Seq.    câmara       '
						nLin++
					endif  
					for i := 1 to len(_aCarc) 
						if _aCarc[i,2] = 6
							_cam := GetAdvFval('SZK','ZK_LOCAL',FWxfilial('SZK')+SZ4->Z4_NUMAM+_aCarc[i,1],4)
							if _lLin = 1
								@nlin,_col psay _aCarc[i,1] + '       ' + _cam 
								_lLin := 2
							elseif _lLin = 2
								@nlin,24 psay '|'
								@nlin,29 psay _aCarc[i,1] + '       ' + _cam 
								_lLin := 1
								nlin++		
							endif 	
						endif
					next

					nlin++
				endif

				If nLin > 75 
					Cabec(Titulo,Cabec1,Cabec2,NomeProg,Tamanho,nTipo)
					nLin := 8
				endif 			

				if _MotSE <> 0            //Motivo de desclassificação sexo errado  
					nlin++
					@nlin,04 psay '- Animais com sexo errado:           ' + transform(_MotSE,'@E 999')  
					nlin++
					_col := 6
					_lLin = 1		   	
					_nQuant := 0 
					if  _MotID > 0 
						@nlin,06 psay 'Seq.    câmara           Seq.    câmara       '
						nLin++  
					endif
					for i := 1 to len(_aCarc) 
						if _aCarc[i,2] = 7
							_cam := GetAdvFval('SZK','ZK_LOCAL',FWxfilial('SZK')+SZ4->Z4_NUMAM+_aCarc[i,1],4)
							if _lLin = 1
								@nlin,_col psay _aCarc[i,1] + '       ' + _cam 
								_lLin := 2
							elseif _lLin = 2
								@nlin,24 psay '|'
								@nlin,29 psay _aCarc[i,1] + '       ' + _cam 
								_lLin := 1
								nlin++		
							endif
							_nQuant++
						endif
					next

					nlin++
				endif
				If nLin > 75 
					Cabec(Titulo,Cabec1,Cabec2,NomeProg,Tamanho,nTipo)
					nLin := 8
				endif   

				if _MotID <> 0            //Motivo de desclassificação Idade
					nlin++
					@nlin,04 psay '- Animais com idade errada:          ' + transform(_MotID,'@E 999')
					nlin++
					_col := 6
					_lLin = 1
					_nQuant := len(_aCarc) 
					if  _MotID > 0 .and. _nQuant > 1
						@nlin,06 psay 'Seq.    câmara           Seq.    câmara       '
						nLin++  
					elseif _nQuant = 1  
						@nlin,06 psay 'Seq.    câmara '
						nLin++
					endif
					for i := 1 to len(_aCarc) 
						if _aCarc[i,2] = 8
							_cam := GetAdvFval('SZK','ZK_LOCAL',FWxfilial('SZK')+SZ4->Z4_NUMAM+_aCarc[i,1],4)
							if _lLin = 1
								@nlin,_col psay _aCarc[i,1] + '       ' + _cam 
								_lLin := 2
							elseif _lLin = 2
								@nlin,24 psay '|'
								@nlin,29 psay _aCarc[i,1] + '       ' + _cam 
								_lLin := 1
								nlin++		
							endif 	
						endif
					next
					nlin++
				endif 

				If nLin > 75 
					Cabec(Titulo,Cabec1,Cabec2,NomeProg,Tamanho,nTipo)
					nLin := 8
				endif 			

				if _MotPr <> 0            //Motivo de desclassificação Propriedade  
					nlin++
					@nlin,04 psay '- Animais com - 40 dias na ult. Prop.:     ' + transform(_MotPr,'@E 999')  
					nlin++
					_col := 6
					_lLin = 1
					_nQuant := len(_aCarc) 
					if  _MotPr > 0 .and. _nQuant > 1
						@nlin,06 psay 'Seq.    câmara           Seq.    câmara       '
						nLin++  
					elseif _nQuant = 1  
						@nlin,06 psay 'Seq.    câmara '
						nLin++
					endif
					for i := 1 to len(_aCarc) 
						if _aCarc[i,2] = 9
							_cam := GetAdvFval('SZK','ZK_LOCAL',FWxfilial('SZK')+SZ4->Z4_NUMAM+_aCarc[i,1],4)
							if _lLin = 1
								@nlin,_col psay _aCarc[i,1] + '       ' + _cam 
								_lLin := 2
							elseif _lLin = 2
								@nlin,24 psay '|'
								@nlin,29 psay _aCarc[i,1] + '       ' + _cam 
								_lLin := 1
								nlin++		
							endif 	
						endif
					next

					nlin++
				endif 
				If nLin > 75 
					Cabec(Titulo,Cabec1,Cabec2,NomeProg,Tamanho,nTipo)
					nLin := 8
				endif 				
				if _MotLc <> 0            //Motivo de desclassificação Localidade 
					nlin++
					@nlin,04 psay '- Animais com - 90 dias na Area Hab.:     ' + transform(_MotLc,'@E 999')
					nlin++
					_col := 6
					_lLin = 1   				
					_nQuant := len(_aCarc) 
					if  _MotLc > 0 .and. _nQuant > 1
						@nlin,06 psay 'Seq.    câmara           Seq.    câmara       '
						nLin++  
					elseif _nQuant = 1  
						@nlin,06 psay 'Seq.    câmara '
						nLin++
					endif
					for i := 1 to len(_aCarc) 
						if _aCarc[i,2] = 10
							_cam := GetAdvFval('SZK','ZK_LOCAL',FWxfilial('SZK')+SZ4->Z4_NUMAM+_aCarc[i,1],4)
							if _lLin = 1
								@nlin,_col psay _aCarc[i,1] + '       ' + _cam 
								_lLin := 2
							elseif _lLin = 2
								@nlin,24 psay '|'
								@nlin,29 psay _aCarc[i,1] + '       ' + _cam 
								_lLin := 1
								nlin++		
							endif 	
						endif
					next
					nlin++ 
				endif    
				If nLin > 75 
					Cabec(Titulo,Cabec1,Cabec2,NomeProg,Tamanho,nTipo)
					nLin := 8
				endif 			
				/*
				if (_MotSB+_MotBR+_MotSE+_MotID+_MotPr+_MotLc) <> 0
				@nlin,02 psay 'Total de Animais desclassificados nos currais/Leitura de brincos:' +;
				transform(_MotSB+_MotBR+_MotSE+_MotID+_MotPr+_MotLc,'@E 999')
				nlin++	     	
				endif
				*/
				nlin++
				@nlin,04 psay '- Animais desclassificados pelo DIF:     ' + transform(_MotIF,'@E 999')
				nlin++
				_col := 4 
				_lLin = 1			   	
				_nQuant := len(_aCarc) 
				if  _MotIF > 0 .and. _nQuant > 1
					@nlin,06 psay 'Seq.    câmara           Seq.    câmara       '
					nLin++  
				elseif _nQuant = 1  
					@nlin,06 psay 'Seq.    câmara '
					nLin++
				endif
				for i := 1 to len(_aCarc) 
					if _aCarc[i,2] = 11
						_cam := GetAdvFval('SZK','ZK_LOCAL',FWxfilial('SZK')+SZ4->Z4_NUMAM+_aCarc[i,1],4)
						if _lLin = 1
							@nlin,_col psay _aCarc[i,1] + '       ' + _cam 
							_lLin := 2
						elseif _lLin = 2
							@nlin,24 psay '|'
							@nlin,29 psay _aCarc[i,1] + '       ' + _cam 
							_lLin := 1
							nlin++		
						endif 	
					endif
				next     

				If nLin > 75 
					Cabec(Titulo,Cabec1,Cabec2,NomeProg,Tamanho,nTipo)
					nLin := 8
				endif 			

				nlin++
				@nlin,04 psay '- Animais desclassificados por pH:       ' + transform(_MotPh,'@E 999')
				nlin++
				_col := 4     
				_lLin = 1
				_nQuant := len(_aCarc) 
				if  _MotPh > 0 .and. _nQuant > 1
					@nlin,06 psay 'Seq.    câmara           Seq.    câmara       '
					nLin++  
				elseif _nQuant = 1  
					@nlin,06 psay 'Seq.    câmara '
					nLin++
				endif
				for i := 1 to len(_aCarc) 
					if _aCarc[i,2] = 13
						_cam := GetAdvFval('SZK','ZK_LOCAL',FWxfilial('SZK')+SZ4->Z4_NUMAM+_aCarc[i,1],4)
						if _lLin = 1
							@nlin,_col psay _aCarc[i,1] + '       ' + _cam 
							_lLin := 2
						elseif _lLin = 2
							@nlin,24 psay '|'
							@nlin,29 psay _aCarc[i,1] + '       ' + _cam 
							_lLin := 1
							nlin++		
						endif 	
					endif
				next         

				If nLin > 75 
					Cabec(Titulo,Cabec1,Cabec2,NomeProg,Tamanho,nTipo)
					nLin := 8
				endif 			

				nlin++ 
				@nlin,04 psay '- Animais destinados Graxaria/Conserva:  ' + transform(_nGC,'@E 999')     
				nlin++
				_col := 4
				_lLin = 1
				_nQuant := len(_aCarc) 
				if  _nGC > 0 .and. _nQuant > 1
					@nlin,06 psay 'Seq.    câmara           Seq.    câmara       '
					nLin++  
				elseif _nQuant = 1  
					@nlin,06 psay 'Seq.    câmara '
					nLin++
				endif
				for i := 1 to len(_aCarc) 
					if _aCarc[i,2] = 14
						_cam := GetAdvFval('SZK','ZK_LOCAL',FWxfilial('SZK')+SZ4->Z4_NUMAM+_aCarc[i,1],4)
						if _lLin = 1
							@nlin,_col psay _aCarc[i,1] + '       ' + _cam 
							_lLin := 2
						elseif _lLin = 2
							@nlin,24 psay '|'
							@nlin,29 psay _aCarc[i,1] + '       ' + _cam 
							_lLin := 1
							nlin++		
						endif 
					endif
				next
			endif  	 
		endif  
		If nLin > 75 
			Cabec(Titulo,Cabec1,Cabec2,NomeProg,Tamanho,nTipo)
			nLin := 8
		endif 			
		if SZ4->Z4_RASTRO = 'S'
			/*         Local da rastreabilidade inapta                     */  
			@nlin,25 psay '------------------------------------------------------------------'
			nlin++
			@nlin,02 psay "Total de Animais com rastreabilidade apta:   " + transform(_nRast,'@E 999') 
			nlin++
			_col := 4
			_lLin = 1
			_nQuant := len(_aCarc) 
			if  _nRast > 0 .and. _nQuant > 1
				@nlin,06 psay 'Seq.    câmara           Seq.    câmara       '
				nLin++  
			elseif _nQuant = 1  
				@nlin,06 psay 'Seq.    câmara '
				nLin++
			endif
			for i := 1 to len(_aCarc) 
				if _aCarc[i,2] = 2
					_cam := GetAdvFval('SZK','ZK_LOCAL',FWxfilial('SZK')+SZ4->Z4_NUMAM+_aCarc[i,1],4)
					if _lLin = 1
						@nlin,_col psay _aCarc[i,1] + '       ' + _cam 
						_lLin := 2
					elseif _lLin = 2
						@nlin,24 psay '|'
						@nlin,29 psay _aCarc[i,1] + '       ' + _cam 
						_lLin := 1
						nlin++		
					endif 
				endif
			next
		endif
		nlin++              
		@nlin,00 psay replicate('-',132)
		nlin++

		SZ4->(dbSkip()) // Avanca o ponteiro do registro no arquivo
	EndDo

	nlin++
	@nlin,02 psay 'Tot.Animais RT:     ' + transform(_nTotRT,'@E 999')
	nlin++
	@nlin,02 psay 'Tot.Animais USA:     ' + transform(_nTotUSA,'@E 999')
	nlin++
	@nlin,02 psay 'Tot.Animais HK:      ' + transform(_nTotHK,'@E 999')
	nlin++
	@nlin,02 psay 'Tot.Animais BR:      ' + transform(_nTotBR,'@E 999')
	nlin++
	@nlin,02 psay 'Tot.Animais NE:      ' + transform(_nTotNE,'@E 999')
	nlin++
	@nlin,02 psay 'Tot.Animais RU:      ' + transform(_nTotRU,'@E 999')
	nlin++
	@nlin,02 psay 'Tot.Animais HK - UY: ' + transform(_nTtHKUy,'@E 999')
	nlin++
	@nlin,02 psay 'Tot.Animais HK - CN: ' + transform(_nTtHKCn,'@E 999')
	nlin++
	@nlin,02 psay 'Tot.Animais RU - UY: ' + transform(_nTtRuUy,'@E 999')
	nlin++
	@nlin,02 psay 'Tot.Animais RU - CN: ' + transform(_nTtRuCn,'@E 999')

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

Static Function ImpCar(j)
	Local i
	for i := 1 to len(_aCarc) 
		if _aCarc[i,2] = j
			nlin++  
			@nlin,02 psay _aCarc[i,1]  
		endif
	next
return
