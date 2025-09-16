#INCLUDE "OMSR060.CH"
//#INCLUDE "PROTHEUS.CH"
#IFNDEF WINDOWS
#DEFINE PSAY SAY
#ENDIF
#DEFINE CHRCOMP If(aReturn[4]==1,15,18)

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Programa  ³MLOMS060  ³ Autor ³ Henry Fila            ³ Data ³ 20.06.01 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³Relatorio de Roteirizacao                                   ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Retorno   ³Nenhum                                                      ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³Nenhum                                                      ³±±
±±³          ³                                                            ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³   DATA   ³ Programador   ³Manutencao efetuada                         ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³          ³               ³                                            ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/

user Function MLOMS060()

	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³Define Variaveis                                                        ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	#IFDEF WINDOWS
	Local Titulo  := OemToAnsi(STR0001) //"Roteirizacao"
	Local cDesc1  := OemToAnsi(STR0002) //""  // Descricao 1
	Local cDesc2  := OemToAnsi(STR0003) //""  // Descricao 2
	Local cDesc3  := OemToAnsi(STR0004) //""  // Descricao 3
	#ELSE
	Local Titulo  := ""
	Local cDesc1  := ""
	Local cDesc2  := ""
	Local cDesc3  := ""
	#ENDIF
	Local cString := "DA8"  // Alias utilizado na Filtragem
	Local lDic    := .F. // Habilita/Desabilita Dicionario
	Local lComp   := .T. // Habilita/Desabilita o Formato Comprimido/Expandido
	Local lFiltro := .T. // Habilita/Desabilita o Filtro
	Local wnrel   := "OMSR060"  // Nome do Arquivo utilizado no Spool
	Local nomeprog:= "OMSR060"  // nome do programa

	Private Tamanho := "G" // P/M/G
	Private Limite  := 132 // 80/132/220
	Private aOrdem  := {OemtoAnsi(STR0007),OemtoAnsi(STR0008)}  // Ordem do Relatorio
	Private cPerg   := "OMR060"
	Private aReturn := { OemtoAnsi(STR0005), 1,OemtoAnsi(STR0006), 1, 2, 1, "",1 } //"Zebrado"###"Administracao"
	//[1] Reservado para Formulario
	//[2] Reservado para N§ de Vias
	//[3] Destinatario
	//[4] Formato => 1-Comprimido 2-Normal
	//[5] Midia   => 1-Disco 2-Impressora
	//[6] Porta ou Arquivo 1-LPT1... 4-COM1...
	//[7] Expressao do Filtro
	//[8] Ordem a ser selecionada
	//[9]..[10]..[n] Campos a Processar (se houver)

	Private lEnd    := .F.// Controle de cancelamento do relatorio
	Private m_pag   := 1  // Contador de Paginas
	Private nLastKey:= 0  // Controla o cancelamento da SetPrint e SetDefault

	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³Verifica as Perguntas Seleciondas                                       ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	AjustaSx1()
	Pergunte(cPerg,.F.)
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³Envia para a SetPrinter                                                 ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	wnrel:=SetPrint(cString,wnrel,cPerg,@titulo,cDesc1,cDesc2,cDesc3,lDic,aOrdem,lComp,Tamanho,lFiltro)
	If ( nLastKey==27 )
		dbSelectArea(cString)
		dbSetOrder(1)
		Set Filter to
		Return
	Endif
	SetDefault(aReturn,cString)
	If ( nLastKey==27 )
		dbSelectArea(cString)
		dbSetOrder(1)
		Set Filter to
		Return
	Endif
	#IFDEF WINDOWS
	RptStatus({|lEnd| ImpDet(@lEnd,wnRel,cString,nomeprog,Titulo)},Titulo)
	#ELSE
	ImpDet(.F.,wnrel,cString,nomeprog,Titulo)
	#ENDIF

Return(.T.)

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Program   ³ ImpDet   ³ Autor ³ Eduardo Riera         ³ Data ³02.07.1998³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³Controle de Fluxo do Relatorio.                             ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Retorno   ³Nenhum                                                      ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³Nenhum                                                      ³±±
±±³          ³                                                            ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³   DATA   ³ Programador   ³Manutencao efetuada                         ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³          ³               ³                                            ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/

Static Function ImpDet(lEnd,wnrel,cString,nomeprog,Titulo)

	Local aCeps     := {}
	Local aStrucDA8 := {}

	Local li        := 100 // Contador de Linhas
	Local lImp      := .F. // Indica se algo foi impresso
	Local lCabOut   := .T.
	Local cbCont    := 0   // Numero de Registros Processados
	Local cbText    := ""  // Mensagem do Rodape
	Local cQuery    := ""
	Local cAlias    := ""
	Local cAliasDA5 := "DA5"
	Local cAliasDA6 := "DA6"
	Local cAliasDA7 := "DA7"
	Local cAliasDA8 := "DA8"
	Local cAliasDA9 := "DA9"
	Local cAliasSA1 := "SA1"
	Local cName     := ""
	Local cQryAd    := ""
	Local cIndSA1   := ""
	Local cKeySA1   := ""
	Local cCondSA1  := ""
	Local cDbMs

	Local lQuery    := .F.                     
	Local lRot      := .T.
	Local lFiltro   := .T.
	Local lImpOut   := .T.

	Local nIndSA1   := 0
	Local nX        := 0

	//
	//                         1         2         3         4         5         6         7         8         9        10        11        12        13        14        15        16        17        18        19        20        21        22
	//               01234567890123456789012345678901234567890123456789012345678901234567890123456789012345678901234567890123456789012345678901234567890123456789012345678901234567890123456789012345678901234567890123456789012345678901234567890
	//               XXXXXX XXXXXXXXXXXXXXXXXXXXXXXXXXXXXX XXXXXX XXXXXXXXXXXXXXXXXXXXXXXXXXXXXX XXXXXX XXX XXXXXXXXXX
	//               SEQUENCIA	 CEP INICIAL    CEP FINAL    REFERENCIA" 

	Local cCabec1 := ""
	Local cCabec2 := ""

	If aReturn[8] == 1
		cCabec1 :=  OemtoAnsi(STR0009) //"ROTA   DESCRICAO                      SEQUENCIA ZONA   DESCRICAO                      SETOR  DESCRICAO"
		cCabec2 :=  ""	
		#IFDEF TOP

		If TcSrvType() <> "AS/400"
			lQuery    := .T.
			cAlias    := "QRYROT"
			cAliasDA5 := "QRYROT"
			cAliasDA6 := "QRYROT"
			cAliasDA7 := "QRYROT"
			cAliasDA8 := "QRYROT"
			cAliasDA9 := "QRYROT"						
			cAliasSA1 := "QRYROT"		

			aStrucDA8 := DA8->(dbStruct())			

			cQuery := "SELECT "

			If !Empty(aReturn[7])
				For nX := 1 To DA8->(FCount())
					cName := DA8->(FieldName(nX))
					If AllTrim( cName ) $ aReturn[7]
						If aStrucDA8[nX,2] <> "M"  
							If !cName $ cQuery .And. !cName $ cQryAd
								cQryAd += cName +","
							Endif 	
						EndIf
					EndIf 			       	
				Next nX
			Endif    

			cQuery += cQryAd					
			cQuery += "DA8_COD,DA8_DESC,DA9_FILIAL,DA9_ROTEIR,DA9_SEQUEN,DA9_PERCUR,"
			cQuery += "DA9_ROTA,DA5_COD,DA5_DESC,DA6_ROTA,DA6_REF,DA7_FILIAL,DA7_SEQUEN,"
			cQuery += "DA7_PERCUR,DA7_ROTA,DA7_CLIENT,DA7_LOJA,DA7_CEPDE,DA7_CEPATE,DA7_REF,A1_NOME,A1_END,A1_MUN,A1_EST,A1_CEP FROM "
			cQuery += RetSqlName("DA5") + " DA5 ,"
			cQuery += RetSqlName("DA6") + " DA6 ,"
			cQuery += RetSqlName("DA7") + " DA7 ,"		
			cQuery += RetSqlName("DA8") + " DA8 ,"		
			cQuery += RetSqlName("DA9") + " DA9 ,"
			cQuery += RetSqlName("SA1") + " SA1 "				
			cQuery += "WHERE "    
			cQuery += "DA8_FILIAL = '"+xFilial("DA8")+"' AND "		
			cQuery += "DA8_COD >= '"+mv_par01+"' AND "
			cQuery += "DA8_COD <= '"+mv_par02+"' AND "             
			cQuery += "DA9_FILIAL = '"+xFilial("DA9")+"' AND "		
			cQuery += "DA9_PERCUR >= '"+mv_par03+"' AND "
			cQuery += "DA9_PERCUR <= '"+mv_par04+"' AND "		
			cQuery += "DA9_ROTA >= '"+mv_par05+"' AND "		
			cQuery += "DA9_ROTA <= '"+mv_par06+"' AND "				
			cQuery += "DA8_COD = DA9_ROTEIR AND "
			cQuery += "DA8.D_E_L_E_T_ = ' ' AND "
			cQuery += "DA9.D_E_L_E_T_ = ' ' AND "		

			cQuery += "DA7_FILIAL = '"+xFilial("DA7")+"' AND "
			cQuery += "DA7_PERCUR = DA9_PERCUR AND "
			cQuery += "DA7_ROTA = DA9_ROTA AND "
			cQuery += "DA7_CLIENT >= '"+mv_par07+"' AND "
			cQuery += "DA7_CLIENT <= '"+mv_par08+"' AND "
			cQuery += "DA7_LOJA >= '"+mv_par09+"' AND "
			cQuery += "DA7_LOJA <= '"+mv_par10+"' AND "		
			cQuery += "DA7.D_E_L_E_T_ = ' ' AND "		

			cQuery += "A1_FILIAL = '"+xFilial("SA1")+"' AND "		
			cQuery += "A1_COD = DA7_CLIENT AND "
			cQuery += "A1_LOJA = DA7_LOJA AND "
			cQuery += "A1_CEP >= '"+mv_par11+"' AND "
			cQuery += "A1_CEP <= '"+mv_par12+"' AND "
			cQuery += "SA1.D_E_L_E_T_ = ' ' AND "		

			cQuery += "DA6_FILIAL = '"+xFilial("DA6")+"' AND "
			cQuery += "DA6_PERCUR = DA9_PERCUR AND "		
			cQuery += "DA6_ROTA = DA9_ROTA AND "
			cQuery += "DA6.D_E_L_E_T_ = ' ' AND "

			cQuery += "DA5_FILIAL = '"+xFilial("DA5")+"' AND "
			cQuery += "DA5_COD = DA9_PERCUR AND "
			cQuery += "DA5_VENDED >= '"+mv_par13+"' AND "
			cQuery += "DA5_VENDED <= '"+mv_par14+"' AND "			
			cQuery += "DA5.D_E_L_E_T_ = ' ' "

			cQuery += "ORDER BY DA8_COD,DA9_SEQUEN,DA9_PERCUR,DA9_ROTA,DA7_SEQUEN,DA7_CLIENT,DA7_LOJA"

			cQuery := ChangeQuery(cQuery)
			dBUseArea(.t.,"TOPCONN",TCGENQRY(,,cQuery),cAlias,.f.,.t.)

			bWhile := {|| (cAliasDA5)->(!Eof())}
		Else  	 		
			#ENDIF	 		

			dbSelectArea(cAliasDA8)
			dbSetOrder(1)
			MsSeek(xFilial("DA8")+mv_par01,.T.)       

			bWhile := {|| (cAliasDA8)->(!Eof()) .And. (cAliasDA8)->DA8_COD <= mv_par02 }

			#IFDEF TOP
		Endif
		#ENDIF	    	


		While Eval(bWhile)

			lImp    := .T.
			lSkip   := .F.
			lRot    := .T.
			lImpOut := .T.
			#IFNDEF WINDOWS
			If LastKey() = 286
				lEnd := .T.
			EndIf
			#ENDIF
			If lEnd
				@ Prow()+1,001 PSAY STR0007 //"CANCELADO PELO OPERADOR"
				Exit
			EndIf

			If !Empty(aReturn[7]) 
				lFiltro := Iif(&(aReturn[7]),.T.,.F.)	
			Endif	

			If lFiltro

				If ( li > 58 )
					li := cabec(Titulo,cCabec1,cCabec2,nomeprog,Tamanho,CHRCOMP)
					li++
				Endif

				lCabOut := .T.

				If !lQuery
					dbSelectArea("DA9")
					dbSetOrder(1)
					MsSeek(xFilial("DA9")+(cAliasDA8)->DA8_COD)
				Endif

				cRota := (cAliasDA8)->DA8_COD

				While (cAliasDA9)->(!Eof()) .And. (cAliasDA9)->DA9_FILIAL+(cAliasDA9)->DA9_ROTEIR == ;
				xFilial("DA8")+cRota

					aCeps   := {}	
					lImpOut := .T.

					If !lQuery
						dbSelectArea(cAliasDA5)
						dbSetOrder(1)
						MsSeek(xFilial("DA5")+(cAliasDA9)->DA9_PERCUR)

						If (cAliasDA5)->DA5_VENDED < mv_par13 .Or. (cAliasDA5)->DA5_VENDED > mv_par14
							lImpOut := .F.
						Endif	

					Endif	

					If !lQuery
						dbSelectArea(cAliasDA6)
						dbSetOrder(1)
						MsSeek(xFilial("DA6")+(cAliasDA9)->DA9_PERCUR+(cAliasDA9)->DA9_ROTA)
					Endif	

					If lImpOut	

						If lCabOut
							@ li,000 PSAY (cAliasDA8)->DA8_COD
							@ li,007 PSAY (cAliasDA8)->DA8_DESC
							li++
							lCabOut := .F.
						Endif	

						@ li,000 PSAY __PrtThinLine()
						li++                                 
						@ li,000 PSAY OemtoAnsi(STR0016)
						@ li,038 PSAY (cAliasDA9)->DA9_SEQUEN
						@ li,048 PSAY (cAliasDA9)->DA9_PERCUR
						@ li,055 PSAY (cAliasDA5)->DA5_DESC			
						@ li,086 PSAY (cAliasDA9)->DA9_ROTA
						@ li,093 PSAY (cAliasDA6)->DA6_REF			

						li++
						@ li,000 PSAY __PrtThinLine()
						li++

						If !lQuery
							dbSelectArea(cAliasDA7)
							dbSetOrder(1)
							MsSeek(xFilial("DA7")+(cAliasDA9)->DA9_PERCUR+(cAliasDA9)->DA9_ROTA)
						Endif	

						cZonaSetor := (cAliasDA9)->DA9_PERCUR+(cAliasDA9)->DA9_ROTA
						li++
						@ li,000 PSAY OemtoAnsi(STR0010) //"SEQUENCIA CLIENTE LOJA  NOME                                     ENDERECO                                 CIDADE          ESTADO  CEP"
						li++
						@ li,000 PSAY __PrtThinLine()
						li++

						While (cAliasDA7)->(!Eof()) .And. (cAliasDA7)->DA7_FILIAL == xFilial("DA7") .And. ;
						(cAliasDA7)->DA7_PERCUR+(cAliasDA7)->DA7_ROTA == cZonaSetor

							If lEnd
								@ Prow()+1,001 PSAY STR0007 //"CANCELADO PELO OPERADOR"
								Exit
							EndIf
							If ( li > 58 )
								li := cabec(Titulo,cCabec1,cCabec2,nomeprog,Tamanho,CHRCOMP)
								li++
							Endif

							If !lQuery
								dbSelectArea(cAliasSA1)
								dbSetOrder(1)
								MsSeek(xFilial("SA1")+(cAliasDA7)->DA7_CLIENT+(cAliasDA7)->DA7_LOJA )
							Endif

							If (cAliasSA1)->A1_CEP >= mv_par11 .And. (cAliasSA1)->A1_CEP <= mv_par12 .And.;
							!Empty((cAliasDA7)->DA7_CLIENT) .And. !Empty((cAliasDA7)->DA7_LOJA)

								@ li,000 PSAY (cAliasDA7)->DA7_SEQUEN
								@ li,010 PSAY (cAliasDA7)->DA7_CLIENT
								@ li,018 PSAY (cAliasDA7)->DA7_LOJA
								@ li,024 PSAY (cAliasSA1)->A1_NOME
								@ li,065 PSAY substr((cAliasSA1)->A1_END,1,38)
								@ li,106 PSAY substr((cAliasSA1)->A1_MUN,1,15)        			
								@ li,122 PSAY (cAliasSA1)->A1_EST        			        			
								@ li,129 PSAY (cAliasSA1)->A1_CEP        			        			        			        			                                                    
								li++
							Else 
								Aadd(aCeps,{(cAliasDA7)->DA7_SEQUEN,(cAliasDA7)->DA7_CEPDE,(cAliasDA7)->DA7_CEPATE,(cAliasDA7)->DA7_REF})
							Endif	        			        			

							dbSelectArea(cAliasDA7)
							dbSkip()                               
							lSkip := .T.

						Enddo

						If Len(aCeps) > 0

							li++
							@ li,000 PSAY OemtoAnsi(STR0015) //"SEQUENCIA	 CEP INICIAL    CEP FINAL    REFERENCIA"
							li++
							@ li,000 PSAY __PrtThinLine()
							li++

							For nX := 1 to Len(aCeps)
								@ li,000 PSAY aCeps[nX][1]
								@ li,010 PSAY aCeps[nX][2] PICTURE PesqPict("DA7","DA7_CEPDE")  
								@ li,025 PSAY aCeps[nX][3] PICTURE PesqPict("DA7","DA7_CEPATE")  
								@ li,038 PSAY aCeps[nX][4] PICTURE PesqPict("DA7","DA7_REF")  
								li++
							Next

						Endif

						li++

					Endif	

					If !lQuery .Or. !lSkip
						dbSelectArea(cAliasDA9)                  	
						dbSkip()
					Endif			

				Enddo				

				If !lCabOut
					li := 60
				Endif	

			Endif

			If !lQuery .Or. !lSkip
				dbSelectArea(cAliasDA8)                  	
				dbSkip()
			Endif			

		Enddo

		If lQuery
			dbSelectArea(cAliasDA5)
			dbCloseArea()
			dbSelectArea("DA5")
		Endif	

	Else

		//                          1         2         3         4         5         6         7         8         9        10        11        12        13        14        15        16        17        18        19        20        21        22
		//               01234567890123456789012345678901234567890123456789012345678901234567890123456789012345678901234567890123456789012345678901234567890123456789012345678901234567890123456789012345678901234567890123456789012345678901234567890
		//               XXXXXX  XX     XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX XXXXXXXXXXXXXXX XX     XXXXXXXXX     

		cCabec1 :=  OemtoAnsi(STR0011) //"CLIENTE LOJA   NOME                                     ENDERECO                                 CIDADE          ESTADO CEP"
		cCabec2 :=  ""	
		#IFDEF TOP
		If TcSrvType() <> "AS/400"            

			cDbMs	 := UPPER(TcGetDb())		
			lQuery    := .T.
			cAlias    := "QRYROT"
			cAliasSA1 := "QRYROT"
			cAliasDA7 := "QRYROT"

			cQuery := "SELECT A1_COD,A1_LOJA,A1_NOME,A1_END,A1_MUN,A1_EST,A1_CEP,DA7_PERCUR,DA7_ROTA,DA7_CLIENT,DA7_LOJA,DA7_SEQUEN "
			cQuery += "FROM "
			cQuery += RetSqlName("SA1")+ " SA1 "						

			If cDbMs == "INFORMIX"
				cQuery += ", OUTER "+ RetSqlName("DA7") + " DA7 "
			ElseIf cDbMs == "POSTGRES"
				cQuery += " LEFT OUTER JOIN "+ RetSqlName("DA7") + " DA7 ON (SA1.A1_COD = DA7.DA7_CLIENT AND SA1.A1_LOJA = DA7.DA7_LOJA)" 
			Else
				cQuery += ", "+ RetSqlName("DA7")+ " DA7 "			
			Endif	

			cQuery += " WHERE "

			cQuery += "A1_FILIAL = '"+xFilial("SA1")+"' AND "
			cQuery += "A1_COD >= '"+mv_par07+"' AND "			
			cQuery += "A1_COD <= '"+mv_par08+"' AND "						
			cQuery += "A1_LOJA >= '"+mv_par09+"' AND "
			cQuery += "A1_LOJA <= '"+mv_par10+"' AND "			
			If cDbMs != "POSTGRES"			
				cQuery += "A1_COD *= DA7_CLIENT AND "
				cQuery += "A1_LOJA *= DA7_LOJA AND "      
			Endif	
			cQuery += "SA1.D_E_L_E_T_ = ' ' AND " 
			cQuery += "DA7.D_E_L_E_T_ = ' ' "

			cQuery += "ORDER BY A1_COD,A1_LOJA,DA7_PERCUR,DA7_ROTA"

			cQuery := ChangeQuery(cQuery)      
			dBUseArea(.t.,"TOPCONN",TCGENQRY(,,cQuery),cAlias,.f.,.t.)

			bWhile := {|| (cAliasSA1)->(!Eof())}
		Else  	 		
			#ENDIF	 		

			dbSelectArea("SA1")
			dbSetOrder(1)
			cIndSA1 := CriaTrab(NIL,.F.)

			cKeySA1  := IndexKey()
			cCondSA1 += 'A1_FILIAL = "'+xFilial("SA1")+'" .And.' 
			cCondSA1 += 'A1_COD >= "'+mv_par07+'" .And. A1_COD <= "'+mv_par08+'" .And.'
			cCondSA1 += 'A1_LOJA >= "'+mv_par09+'" .And. A1_LOJA <= "'+mv_par10+'" .And.'			
			cCondSA1 += 'A1_CEP >= "'+mv_par11+'" .And. A1_CEP <= "'+mv_par12+'" '
			IndRegua("SA1",cIndSA1,cKeySA1,,cCondSA1) //"Selecionando Registros ..."
			nIndSA1 := RetIndex("SA1")
			#IFNDEF TOP
			dbSetIndex(cIndSA1+OrdBagExT())
			#ENDIF
			dbSetOrder(nIndSA1+1)       
			dbGotop()

			bWhile := {|| (cAliasSA1)->(!Eof())}

			#IFDEF TOP
		Endif
		#ENDIF	    	

		While Eval(bWhile)

			lImp    := .T.
			lSkip   := .F.           
			lCabOut := .T.
			lImpOut := .T.
			#IFNDEF WINDOWS
			If LastKey() = 286
				lEnd := .T.
			EndIf
			#ENDIF
			If lEnd
				@ Prow()+1,001 PSAY STR0007 //"CANCELADO PELO OPERADOR"
				Exit
			EndIf
			If ( li > 58 )
				li := cabec(Titulo,cCabec1,cCabec2,nomeprog,Tamanho,CHRCOMP)
				li++
			Endif


			//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
			//³Verifica se o cliente possui rotierizacao            ³
			//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ

			If lQuery
				If Empty((cAliasDA7)->DA7_PERCUR) .And. Empty((cAliasSA1)->DA7_ROTA)

					@ li,000 PSAY (cAliasSA1)->A1_COD
					@ li,008 PSAY (cAliasSA1)->A1_LOJA
					@ li,015 PSAY (cAliasSA1)->A1_NOME
					@ li,056 PSAY substr((cAliasSA1)->A1_END,1,38)
					@ li,097 PSAY substr((cAliasSA1)->A1_MUN,1,15)
					@ li,113 PSAY (cAliasSA1)->A1_EST
					@ li,120 PSAY (cAliasSA1)->A1_CEP
					li++
					@ li,000 PSAY __PrtThinLine()
					li++

					@ li,000 PSAY OemtoAnsi(STR0012) //"CLIENTE SEM ROTEIRIZACAO - NAO CADASTRADO EM NENHUMA ZONA / SETOR"
					li++
					@ li,000 PSAY __PrtThinLine()
					li++				
					lRot := .F.					
				Endif
			Else     
				dbSelectArea(cAliasDA7)
				dbSetOrder(2)
				If !MsSeek(xFilial("DA7")+(cAliasSA1)->A1_COD+(cAliasSA1)->A1_LOJA)

					@ li,000 PSAY (cAliasSA1)->A1_COD
					@ li,008 PSAY (cAliasSA1)->A1_LOJA
					@ li,015 PSAY (cAliasSA1)->A1_NOME
					@ li,056 PSAY substr((cAliasSA1)->A1_END,1,38)
					@ li,097 PSAY substr((cAliasSA1)->A1_MUN,1,15)
					@ li,113 PSAY (cAliasSA1)->A1_EST
					@ li,120 PSAY (cAliasSA1)->A1_CEP
					li++
					@ li,000 PSAY __PrtThinLine()
					li++
					@ li,000 PSAY OemtoAnsi(STR0012) //"CLIENTE SEM ROTEIRIZACAO - NAO CADASTRADO EM NENHUMA ZONA / SETOR"
					li++
					@ li,000 PSAY __PrtThinLine()
					li++				
					lRot := .F.					
				Endif	   
			Endif										

			If lRot

				cClienteLoja := (cAliasSA1)->A1_COD+(cAliasSA1)->A1_LOJA

				//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
				//³Imprime cabecalho de zonas e setores                      ³
				//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
				//                       1         2         3         4         5         6         7         8         9        10        11        12        13        14        15        16        17        18        19        20        21        22
				//             01234567890123456789012345678901234567890123456789012345678901234567890123456789012345678901234567890123456789012345678901234567890123456789012345678901234567890123456789012345678901234567890123456789012345678901234567890
				//             XXXXXX XXXXXXXXXXXXXXXXXXXXXXXXXXXXXX   XXXXXX XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX       


				While (cAliasDA7)->(!Eof()) .And. (cAliasDA7)->DA7_CLIENT+(cAliasDA7)->DA7_LOJA == cClienteLoja

					If ( li > 58 )
						li := cabec(Titulo,cCabec1,cCabec2,nomeprog,Tamanho,CHRCOMP)
						li++
					Endif

					//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
					//³Busca descricao da zona                                 ³ 
					//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
					dbSelectArea(cAliasDA5)
					dbSetOrder(1)
					MsSeek(xFilial("DA5")+(cAliasDA7)->DA7_PERCUR)

					If (cAliasDA5)->DA5_VENDED < mv_par13 .Or. (cAliasDA5)->DA5_VENDED > mv_par14
						lImpOut := .F.
					Endif	

					If lImpOut

						If lCabOut			
							@ li,000 PSAY (cAliasSA1)->A1_COD
							@ li,008 PSAY (cAliasSA1)->A1_LOJA
							@ li,015 PSAY (cAliasSA1)->A1_NOME
							@ li,056 PSAY substr((cAliasSA1)->A1_END,1,38)
							@ li,097 PSAY substr((cAliasSA1)->A1_MUN,1,15)
							@ li,113 PSAY (cAliasSA1)->A1_EST
							@ li,120 PSAY (cAliasSA1)->A1_CEP
							li++
							@ li,000 PSAY __PrtThinLine()
							li++
							@ li,000 PSAY OemtoAnsi(STR0013) //"ZONA   DESCRICAO                        SETOR  DESCRICAO                                SEQUENCIA   ROTA   DESCRICAO                      SEQUENCIA"   
							li++                                                                                                    
							@ li,000 PSAY __PrtThinLine()
							li++
							lCabOut := .F.
						Endif	


						dbSelectArea(cAliasDA6)
						dbSetOrder(1)
						MsSeek(xFilial("DA5")+(cAliasDA7)->DA7_PERCUR+(cAliasDA7)->DA7_ROTA)

						@ li,000 PSAY (cAliasDA7)->DA7_PERCUR
						@ li,007 PSAY (cAliasDA5)->DA5_DESC	
						@ li,040 PSAY (cAliasDA7)->DA7_ROTA
						@ li,047 PSAY (cAliasDA6)->DA6_REF
						@ li,088 PSAY (cAliasDA7)->DA7_SEQUEN


						dbSelectArea(cAliasDA9)
						dbSetOrder(2)
						If MsSeek(xFilial("DA9")+(cAliasDA7)->DA7_PERCUR+(cAliasDA7)->DA7_ROTA)

							While (cAliasDA9)->(!Eof()) .And. (cAliasDA9)->DA9_FILIAL == xFilial("DA9") .And. ;
							(cAliasDA9)->DA9_PERCUR == (cAliasDA7)->DA7_PERCUR .And. ;
							(cAliasDA9)->DA9_ROTA == (cAliasDA7)->DA7_ROTA

								If ( li > 58 )
									li := cabec(Titulo,cCabec1,cCabec2,nomeprog,Tamanho,CHRCOMP)
									li++
								Endif

								dbSelectArea(cAliasDA8)
								dbSetOrder(1)
								MsSeek(xFilial("DA8")+(cAliasDA9)->DA9_ROTEIR)

								@ li,100 PSAY (cAliasDA9)->DA9_ROTEIR
								@ li,107 PSAY (cAliasDA8)->DA8_DESC
								@ li,139 PSAY (cAliasDA9)->DA9_SEQUEN
								li++
								dbSelectArea(cAliasDA9)
								dbSkip()

							Enddo				
						Else 
							@ li,100 PSAY OemtoAnsi(STR0014) //"ZONA E SETOR NAO CADASTRADO EM NENHUMA ROTA"
							li++
						Endif


						@ li,000 PSAY __PrtThinLine()
						li++

					Endif

					dbSelectArea(cAliasDA7)
					dbSkip()
					lSkip:=.T.

				Enddo		   	

			Endif

			If !lQuery .Or.!lSkip .Or. !lRot
				dbSelectArea(cAliasSA1)
				dbSkip()
			Endif		        

			If !lCabOut
				li += 2
			Endif	

		Enddo

		If !lQuery
			dbSelectArea("SA1")
			Ferase(cIndSA1+OrdBagExt())
			RetIndex("SA1")
		Else
			dbSelectArea(cAliasSA1)
			dbCloseArea()
			dbSelectArea("DA5")
		Endif			

	Endif


	If ( lImp )
		Roda(cbCont,cbText,Tamanho)
	EndIf

	Set Device To Screen
	Set Printer To
	If ( aReturn[5] = 1 )
		dbCommitAll()
		OurSpool(wnrel)
	Endif
	MS_FLUSH()
Return(.T.)


/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³AjustaSX1 ºAutor  ³Leonardo Gentile    º Data ³  18/02/03   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³                                                            º±±
±±º          ³                                                            º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ MATR550 AP6                                                º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Static Function AjustaSX1()

	PutSx1(cPerg,"13","De Vendedor?","¿De Vendedor ?","From Sales Repres.?","mv_chd","C",6,0,0,"G","","SA3","","","mv_par19","","","",""," "," "," "," "," "," "," "," "," ","","","",{},{},{},".MTR68016.")
	PutSx1(cPerg,"14","Ate Vendedor?","¿A Vendedor ?","To Sales Represent.?","mv_che","C",6,0,0,"G","","SA3","","","mv_par20","","","","ZZZZZZ"," "," "," "," "," "," "," "," "," ","","","",{},{},{},".MTR68017.")

Return
