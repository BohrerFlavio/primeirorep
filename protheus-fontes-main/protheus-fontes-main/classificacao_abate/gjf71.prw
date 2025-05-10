#INCLUDE "rwmake.ch"
#INCLUDE "topconn.ch"

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³GJF71     ºGiuliano José Forgiarini   º Data ³  30/12/08    º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDescricao ³ Relatorio de carcaças a serem processadas em previsão      º±±
±±º          ³ de produção na entrada da desossa                          º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ Producao (SIGAPCP)                                         º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/

User Function GJF71()


	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Declaracao de Variaveis                                             ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ

	Local cDesc1         := "Este programa tem como objetivo imprimir relatorio  "
	Local cDesc2         := "de carcaças a serem processadas em uma determinada  "
	Local cDesc3         := "previsão de produção para a entrada da desossa      "
	Local cPict          := ""                                         
	Local titulo       	:= "R5 - PREVISAO DE PRODUCAO DA DESOSSA"
	Local nLin         	:= 80

	Local Cabec1       	:= "Dados da Previsao de Produção"
	Local Cabec2       	:= "         Rastro:        Seq. Classif.:"+;
	"            Rastro:        Seq. Classif.:"+;
	"            Rastro:        Seq. Classif.:"
	Local imprime      	:= .T.
	Local aOrd := {}
	Private lEnd         := .F.
	Private lAbortPrint  := .F.
	Private CbTxt        := ""
	Private limite       := 132
	Private Tamanho      := "M"
	Private nomeprog     := "GJF71" // Coloque aqui o nome do programa para impressao no cabecalho
	Private nTipo        := 18
	Private aReturn      := { "Zebrado", 1, "Administracao", 2, 2, 1, "", 1}
	Private nLastKey     := 0
	Private cPerg   		:= "GJF71"
	Private cbtxt      	:= Space(10)
	Private cbcont     	:= 00
	Private CONTFL     	:= 01
	Private m_pag      	:= 01
	Private wnrel      	:= "GJF71" // Coloque aqui o nome do arquivo usado para impressao em disco    
	Private _cLado		:= ''
	DbSelectArea('SZ2')

	pergunte(cPerg,.F.)

	wnrel := SetPrint('SZ2',NomeProg,cPerg,@titulo,cDesc1,cDesc2,cDesc3,.T.,aOrd,.T.,Tamanho,,.T.)

	cQuery := " SELECT Z2_NUM AS PREVISAO ,Z2_NUMAM AS AVISO, Z2_DTPROD AS DATA_PRODUCAO,"
	cQuery += " Z2_DATAABT AS DATA_ABATE, Z2_CLASSIF AS CLASSIFICACAO,"
	cQuery += "Z2_DESCRI  AS TIPO_DE_PECA, Z2_QPPECA AS QUANT_PREVISTA,"
	cQuery += "Z2_QRPECA  AS QUANT_REALIZADA,Z2_COD AS CODPECA,"
	cQuery += "Z2_DIASVAL AS DIAS, Z2_TIPIFI AS TIPIFICACAO"
	cQuery += " FROM " + RetSqlTab("SZ2") 
	cQuery += " WHERE " + RetSQLFil('SZ2') + " AND " 
	cQuery += " Z2_NUMAM = '" + mv_par01 + "' AND "
	cQuery += " (Z2_NUM BETWEEN '" + mv_par02 + "' AND '" + mv_par03 + "')    " 
	if !empty(mv_par05)
		cQuery += "AND Z2_CLASSIF = '"+mv_par05+"'"// se traseiro esse 			
	endif  
	cQuery += " AND " + RetSQLDel('SZ2')

	cQuery := ChangeQuery(cQuery)

	//	* Mostrar a consulta */
	//@ 116,090 To 416,707 Dialog oDlgMemo Title "Consulta"
	//@ 055,005 Get cQuery Size 250,080 MEMO Object oMemo
	//Activate Dialog oDlgMemo
	//Return .t.
	
	If Select("OP") != 0
		OP->(dbCloseArea())
	Endif
	TCQUERY cQuery NEW ALIAS "OP"

	If nLastKey == 27
		Return
	Endif

	SetDefault(aReturn,'SZ2')

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
	Local _cLado := ''
	Local _cVar	 := ''
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ SETREGUA -> Indica quantos registros serao processados para a regua ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ

	//alert(OP->PREVISAO)

	//OP->(SetRegua(RecCount()))
	OP->(DbGoTop())
	//alert(OP->PREVISAO)
	
	while  OP->(!eof()) 


		//incregua()
		//alert('linha 126'+OP->PREVISAO)
		If nLin > 75  // Salto de Página. Neste caso o formulario tem 55 linhas...
			Cabec(Titulo,Cabec1,Cabec2,NomeProg,Tamanho,nTipo)
			nLin := 9
		Endif 
		//alert('Linha - 125')
		//alert(OP->PREVISAO)
		@nlin,02 psay 'Previsão Nr.: ' + OP->PREVISAO  
		nlin++ 

		If nLin > 75  // Salto de Página. Neste caso o formulario tem 55 linhas...
			Cabec(Titulo,Cabec1,Cabec2,NomeProg,Tamanho,nTipo)
			nLin := 9
		Endif 

		@nlin,02 psay 'Ordem de Matança: ' + OP->AVISO 
		@nlin,35 psay 'Data de Produção: de '
		@nlin,56 psay stod(OP->DATA_PRODUCAO)
		@nlin,65 psay 'até '    
		@nlin,70 psay stod(OP->DATA_PRODUCAO)+OP->DIAS
		nlin++
		@nlin,02 psay 'Data de Abate: '
		@nlin,20 psay stod(OP->DATA_ABATE)
		If nLin > 75  // Salto de Página. Neste caso o formulario tem 55 linhas...
			Cabec(Titulo,Cabec1,Cabec2,NomeProg,Tamanho,nTipo)
			nLin := 9
		Endif 
		if !empty(OP->CLASSIFICACAO)
			@nlin,35 psay 'Classificação: ' + OP->CLASSIFICACAO
		endif
		if !empty(OP->TIPIFICACAO)
			@nlin,50 psay 'Tipif.: ' + OP->TIPIFICACAO 
		endif 
		nlin++
		If nLin > 75  // Salto de Página. Neste caso o formulario tem 55 linhas...
			Cabec(Titulo,Cabec1,Cabec2,NomeProg,Tamanho,nTipo)
			nLin := 9
		Endif 
		@nlin,02 psay 'Tipo de Peça: ' + OP->TIPO_DE_PECA 
		nlin++
		If nLin > 75  // Salto de Página. Neste caso o formulario tem 55 linhas...
			Cabec(Titulo,Cabec1,Cabec2,NomeProg,Tamanho,nTipo)
			nLin := 9
		Endif 
		@nlin,02 psay 'Quant. Prevista:  ' + transform(OP->QUANT_PREVISTA, '@E 9,999')

		/*if OP->QUANT_REALIZADA <> 0 Pedido para tirar pelo marcelo dia 07-06-2010
		nlin++
		@nlin,02 psay 'Quant. Realizada: ' + transform(OP->QUANT_REALIZADA, '@E 9,999')
		endif */

		// Segunda etapa  mostrar as carcaças      
		//alert('linha 178'+OP->PREVISAO)
		
		ZAJ->(DbSetOrder(4))
		ZAJ->(DbGotop())
		ZAJ->(DbSeek(xfilial('ZAJ')+OP->PREVISAO))


		cont := 0   
		cont2:= 0
		nlin++
		nlin++
		while ZAJ->(!eof()) .and. ZAJ->ZAJ_FILIAL = xfilial('ZAJ') .and. ZAJ->ZAJ_PREDES = OP->PREVISAO

			//Terceira etapa  Filtro  com parametro mv_par04   (mostrar pendentes SIM)
			if mv_par04 =1
				if OP->CODPECA = '005016'     // se TRASEIRO 
					if SEG->TRASEIROS = 2     // se ja produzida toda peça
						SEG->(dbskip())
						loop
					endif 
					if SEG->TRASEIROS = 0 

						_aBate := OP->DATA_ABATE
						_cDataAM := OP->DATA_ABATE
						_cDiaAM  := substr(_cDataAM,7,2)
						_cMesAM  := substr(_cDataAM,5,2)
						_cAnoAM  := substr(_cDataAM,3,2) 
						_cRastro := '[ ]D [ ]E ' + '1733'+_cDiaAM+_cMesAM+_cAnoAM+'0000'+'  ' //SEG->CONTROL
						if cont2 = 0
							@nlin,02 psay _cRastro
							cont2++		
						elseif cont2 = 1
							@nlin,48 psay _cRastro
							cont2++
						elseif cont2 = 2
							@nlin,87 psay _cRastro
							nlin++
							cont2 = 0
						endif 
						If nLin > 75  // Salto de Página. Neste caso o formulario tem 55 linhas...
							Cabec(Titulo,Cabec1,Cabec2,NomeProg,Tamanho,nTipo)
							nLin := 9
						Endif 
					endif
					if SEG->TRASEIROS = 1      
						// Localizar qual foi produzida
						// query para verificar isso
						_cRast := SEG->(AVISO+LOTE+CONTROL)
						SZN->(DbSetOrder(2))
						SZN->(DbSeek(xfilial('SZN')+_cRast))
						while SZN->(!eof()) .and. SZN->ZN_FILIAL = xfilial('SZN') .and. SZN->ZN_RASTRO = _cRast     
							if SZN->ZN_COD <> OP->CODPECA   // Elimina  
								SZN->(dbskip())
								loop
							endif
							_cLado := iif(SZN->ZN_LADO = 'D','E','D') 
							if _cLado = 'D'
								_cMarca =  '[ ]D   '
							elseif _cLado = 'E'
								_cMarca =   '     [ ]E'
							else // caso não tenha registro na SZN cai aqui 
								_cVar := 'SEM'
							endif
							_aBate 	 := OP->DATA_ABATE
							_cDataAM := OP->DATA_ABATE
							_cDiaAM  := substr(_cDataAM,7,2)
							_cMesAM  := substr(_cDataAM,5,2)
							_cAnoAM  := substr(_cDataAM,3,2) 
							_cRastro := _cMarca+' '+'1733'+_cDiaAM+_cMesAM+_cAnoAM+'0000'+'  '

							if cont2 = 0
								@nlin,02 psay _cRastro
								cont2++		
							elseif cont2 = 1
								@nlin,48 psay _cRastro
								cont2++
							elseif cont2 = 2
								@nlin,87 psay _cRastro
								nlin++
								cont2 = 0
							endif
							If nLin > 75  // Salto de Página. Neste caso o formulario tem 55 linhas...
								Cabec(Titulo,Cabec1,Cabec2,NomeProg,Tamanho,nTipo)
								nLin := 9
							Endif 	

							SZN->(dbskip())

						enddo    
						if _cVar = 'SEM' 

							// se carcaça nao produzida , então carregada no tendal ---buscar na ZZG
							cQuery3 := "select ZG_RASTRO as RASTRO,ZG_COD AS CODPECA, ZG_CODORI AS ESP"
							cQuery3 += " FROM " + RetSqlName("SZG") 
							cQuery3 += " WHERE ZG_RASTRO = '"+_cRast+"' AND" 
							cQuery3 += " SZG010.D_E_L_E_T_ <> '*'       " 

							cQuery3 := ChangeQuery(cQuery3)  

							If Select("TER") != 0
								TER->(dbCloseArea())
							Endif
							TCQUERY cQuery3 NEW ALIAS "TER"
							//	SetDefault(aReturn,'OP2')      
							TER->(dbGoTop())
							while TER->(!eof())

								_cLado := iif(SZN->ZN_LADO = 'D','E','D') 
								if _cLado = 'D'
									_cMarca =  '[ ]D   '
								elseif _cLado = 'E'
									_cMarca =   '     [ ]E'
								endif

								_aBate 	 := OP->DATA_ABATE
								_cDataAM := OP->DATA_ABATE
								_cDiaAM  := substr(_cDataAM,7,2)
								_cMesAM  := substr(_cDataAM,5,2)
								_cAnoAM  := substr(_cDataAM,3,2)
								_cControl := TER->RASTRO 
								_cRastro := _cMarca+' '+'1733'+_cDiaAM+_cMesAM+_cAnoAM+'0000'+'  '

								if cont2 = 0
									@nlin,02 psay _cRastro
									cont2++		
								elseif cont2 = 1
									@nlin,48 psay _cRastro
									cont2++
								elseif cont2 = 2
									@nlin,87 psay _cRastro
									nlin++
									cont2 = 0
								endif
								If nLin > 75  // Salto de Página. Neste caso o formulario tem 55 linhas...
									Cabec(Titulo,Cabec1,Cabec2,NomeProg,Tamanho,nTipo)
									nLin := 9
								Endif 			
								TER->(dbskip())

							enddo

						endif
					endif

				elseif OP->CODPECA = '000031'  // se dianteiro
					if SEG->DIANTEIROS = 2     // se ja produzida toda peça 
						SEG->(dbskip())
						loop
					endif
					if SEG->DIANTEIROS = 0 

						_aBate := OP->DATA_ABATE
						_cDataAM := OP->DATA_ABATE
						_cDiaAM  := substr(_cDataAM,7,2)
						_cMesAM  := substr(_cDataAM,5,2)
						_cAnoAM  := substr(_cDataAM,3,2) 
						_cRastro := '[ ]D [ ]E ' + '1733'+_cDiaAM+_cMesAM+_cAnoAM+'0000'+'  '
						if cont2 = 0
							@nlin,02 psay _cRastro
							cont2++		
						elseif cont2 = 1
							@nlin,48 psay _cRastro
							cont2++
						elseif cont2 = 2
							@nlin,87 psay _cRastro
							nlin++
							cont2 = 0
						endif
						If nLin > 75  // Salto de Página. Neste caso o formulario tem 55 linhas...
							Cabec(Titulo,Cabec1,Cabec2,NomeProg,Tamanho,nTipo)
							nLin := 9
						Endif 
					endif
					if SEG->DIANTEIROS = 1      
						// Localizar qual foi produzida ou carregada
						// query para verificar isso
						_cRast := SEG->(AVISO+LOTE+CONTROL)
						SZN->(DbSetOrder(2))
						SZN->(DbSeek(xfilial('SZN')+_cRast))
						while SZN->(!eof()) .and. SZN->ZN_FILIAL = xfilial('SZN') .and. SZN->ZN_RASTRO = _cRast     
							if SZN->ZN_COD <> OP->CODPECA
								SZN->(dbskip())
								loop
							endif
							_cLado := iif(SZN->ZN_LADO = 'D','E','D') 
							if _cLado = 'D'
								_cMarca =  '[ ]    '
							elseif _cLado = 'E'
								_cMarca =   '     [ ]'
							else // caso não tenha registro na SZN cai aqui 
								_cVar := 'SEM'
							endif
							_aBate := OP->DATA_ABATE
							_cDataAM := OP->DATA_ABATE
							_cDiaAM  := substr(_cDataAM,7,2)
							_cMesAM  := substr(_cDataAM,5,2)
							_cAnoAM  := substr(_cDataAM,3,2) 
							_cRastro := _cMarca+_cLado+' '+'1733'+_cDiaAM+_cMesAM+_cAnoAM+'0000'+'  '

							if cont2 = 0
								@nlin,02 psay _cRastro
								cont2++		
							elseif cont2 = 1
								@nlin,48 psay _cRastro
								cont2++
							elseif cont2 = 2
								@nlin,87 psay _cRastro
								nlin++
								cont2 = 0
							endif
							If nLin > 75  // Salto de Página. Neste caso o formulario tem 55 linhas...
								Cabec(Titulo,Cabec1,Cabec2,NomeProg,Tamanho,nTipo)
								nLin := 9
							Endif 			
							SZN->(dbskip())
						enddo
						if _cVar = 'SEM' 

							// se carcaça nao produzida , então carregada no tendal ---buscar na ZZG
							cQuery3 := "select ZG_RASTRO as RASTRO,ZG_COD AS CODPECA, ZG_CODORI AS ESP"
							cQuery3 += " FROM " + RetSqlName("SZG") 
							cQuery3 += " WHERE ZG_RASTRO = '"+_cRast+"' AND" 
							cQuery3 += " SZG010.D_E_L_E_T_ <> '*'       " 

							cQuery3 := ChangeQuery(cQuery3)  

							If Select("TER") != 0
								TER->(dbCloseArea())
							Endif
							TCQUERY cQuery3 NEW ALIAS "TER"
							//	SetDefault(aReturn,'OP2')      
							TER->(dbGoTop())
							while TER->(!eof())

								_cLado := iif(SZN->ZN_LADO = 'D','E','D') 
								if _cLado = 'D'
									_cMarca =  '[ ]D   '
								elseif _cLado = 'E'
									_cMarca =   '     [ ]E'
								endif

								_aBate 	 := OP->DATA_ABATE
								_cDataAM := OP->DATA_ABATE
								_cDiaAM  := substr(_cDataAM,7,2)
								_cMesAM  := substr(_cDataAM,5,2)
								_cAnoAM  := substr(_cDataAM,3,2)
								_cControl := TER->RASTRO 
								_cRastro := _cMarca+' '+'1733'+_cDiaAM+_cMesAM+_cAnoAM+'0000'+'  '

								if cont2 = 0
									@nlin,02 psay _cRastro
									cont2++		
								elseif cont2 = 1
									@nlin,48 psay _cRastro
									cont2++
								elseif cont2 = 2
									@nlin,87 psay _cRastro
									nlin++
									cont2 = 0
								endif
								If nLin > 75  // Salto de Página. Neste caso o formulario tem 55 linhas...
									Cabec(Titulo,Cabec1,Cabec2,NomeProg,Tamanho,nTipo)
									nLin := 9
								Endif 			
								TER->(dbskip())

							enddo

						endif

					endif

				endif	
			else // se mv_par04=2, igual a não
				_aBate := OP->DATA_ABATE
				_cDataAM := OP->DATA_ABATE
				_cDiaAM  := substr(_cDataAM,7,2)
				_cMesAM  := substr(_cDataAM,5,2)
				_cAnoAM  := substr(_cDataAM,3,2) 
				_cRastro := '[ ]D [ ]E ' + '1733'+'  '+_cDiaAM+_cMesAM+_cAnoAM+'0000'+'  '

				if cont2 = 0
					@nlin,02 psay _cRastro
					cont2++		
				elseif cont2 = 1
					@nlin,48 psay _cRastro
					cont2++
				elseif cont2 = 2
					@nlin,87 psay _cRastro
					nlin++
					cont2 = 0
				endif
				If nLin > 75  // Salto de Página. Neste caso o formulario tem 55 linhas...
					Cabec(Titulo,Cabec1,Cabec2,NomeProg,Tamanho,nTipo)
					nLin := 9
				Endif
			endif
			SEG->(dbskip())
			ZAJ->(dbskip())	
			cont++
		enddo



		nlin += 3
		OP->(dbskip())
	enddo
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


