#INCLUDE "OMSR030.CH"
#IFNDEF WINDOWS
#DEFINE PSAY SAY
#ENDIF
#DEFINE CHRCOMP If(aReturn[4]==1,15,18)

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Programa  ³gOMSR030   ³ Autor ³ Henry Fila ³Modificado em   ³ 17.10.07 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³Relatorio de Cargas... modificado por Giuliano Forgiarini   ³±±
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

User Function gOMSR030()

	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³Define Variaveis                                                        ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	#IFDEF WINDOWS
	Local Titulo  := OemToAnsi(STR0001) //"Mapa de Entregas"
	Local cDesc1  := OemToAnsi(STR0002) //"Este relatorio ira imprimir o mapa de entregas de acordo"
	Local cDesc2  := OemToAnsi(STR0003) //"com os parametros informados pelo usuario"
	Local cDesc3  := OemToAnsi("") //""  // Descricao 3
	#ELSE
	Local Titulo  := STR0001// "Listagem de Precos"
	Local cDesc1  := STR0002 
	Local cDesc2  := STR0003
	Local cDesc3  := ""
	#ENDIF
	Local cString := "DAK"  // Alias utilizado na Filtragem
	Local lDic    := .F. // Habilita/Desabilita Dicionario
	Local lComp   := .T. // Habilita/Desabilita o Formato Comprimido/Expandido
	Local lFiltro := .T. // Habilita/Desabilita o Filtro
	Local wnrel   := "OMSR030"  // Nome do Arquivo utilizado no Spool
	Local nomeprog:= "gOMSR030"  // nome do programa

	Private Tamanho := "G" // P/M/G
	Private Limite  := 220 // 80/132/220
	Private cPerg   := "OMR030"
	Private aReturn := { STR0002, 1,STR0003, 1, 2, 1, "",1 } //"Zebrado"###"Administracao"
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

	AjustaSx1()
	Pergunte(cPerg,.F.)
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³Envia para a SetPrinter                                                 ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	wnrel:=SetPrint(cString,wnrel,cPerg,@titulo,cDesc1,cDesc2,cDesc3,lDic,,lComp,Tamanho,lFiltro)
	If ( nLastKey==27 )
		dbSelectArea(cString)
		dbSetOrder(1)
		dbclearfilter()
		Return
	Endif
	SetDefault(aReturn,cString)
	If ( nLastKey==27 )
		dbSelectArea(cString)
		dbSetOrder(1)
		dbclearfilter()
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

	Local aStruQry  := {}
	Local aDevol    := {}              
	Local aFormas   := {}

	Local cbCont    := 0   // Numero de Registros Processados
	Local cbText    := ""  // Mensagem do Rodape
	//Local cCpoPeso  := Iif(Getmv("MV_PESOCAR") == "L","SB1->B1_PESO","SB1->B1_PESBRU")
	Local cIndDAK   := ""
	Local cQuery    := "" 
	Local cCodDAK   := ""
	Local cSeqDAK   := ""
	//Local cCliDAI   := ""
	//Local cPedDAI   := ""
	Local cAliasDAK := ""
	Local cAliasDAI := ""
	Local cAliasSA1 := ""
	Local cAliasSD2 := "SD2"
	Local cAliasSF2 := "SF2"
	Local nIndDAK   := 0  
	//Local nPeso     := 0
	//Local nCapVol   := 0
	Local nTipoOper := OsVlEntCom()
	//Local nRegSD2   := 0                                 
	Local nTotForma := 0
	Local nTotal    := 0
	Local nX        := 0
	Local nY        := 0
	Local aRem,nTotRem	:=	0
	Local lFirst    := .T.
	Local lImp      := .F. // Indica se algo foi impresso
	Local lQuery    := .F.
	Local lSkip     := .F.
	Local aImpostos
	Local nImpos	:=	0
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³Imprime as cargas selecionada    ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ

	Local cTabant := ""
	Local li      := 100 // Contador de Linhas

	//                           1         2         3         4         5         6         7         8         9        10        11        12        13        14        15        16        17        18        19        20        21        22
	//                 01234567890123456789012345678901234567890123456789012345678901234567890123456789012345678901234567890123456789012345678901234567890123456789012345678901234567890123456789012345678901234567890123456789012345678901234567890
	//                 XXXXXXXXXXXXXXX XXXXXXXXXXXXXXXXXXXXXXXXXXXXXX XX  XXXXXX   XXX,XXX.XX XXX,XXX.XX  XXX,XXX.XX XXX,XXX.XX  XXX.XXX     XX  XXXXXXXXXX

	//                 CARGA   : XXXXXX-XX           
	//                 VEICULO : XXXXXXXX - XXXXXXXXXXXXXXXXXXXXXXXXXXXXX     MOTORISTA : XXXXXX - XXXXXXXXXXXXXXXXXXXXXXXXXX
	//                 PESO    : XXXX,XXX.XX    VOLUME M3 : XXXX,XXX.XX    PTOS ENTREGA : XXXXXX   VALOR : XXX,XXX,XXX.XX
	//                 DATA    : XX/XX/XX AS XX:XX		

	//
	//                                    1         2         3         4         5         6         7         8         9        10        11        12        13        14        15        16        17        18        19        20        21        22
	//                          01234567890123456789012345678901234567890123456789012345678901234567890123456789012345678901234567890123456789012345678901234567890123456789012345678901234567890123456789012345678901234567890123456789012345678901234567890


	//                                                1         2         3         4         5         6         7         8         9        10        11        12        13        14        15        16        17        18        19        20        21        22
	//                                      01234567890123456789012345678901234567890123456789012345678901234567890123456789012345678901234567890123456789012345678901234567890123456789012345678901234567890123456789012345678901234567890123456789012345678901234567890

	Local cCabec1 := OemtoAnsi(STR0004) //"SEQUENCIA NOTA   SERIE  PEDIDO  CLIENTE   NOME                 ENDERECO                                 "
	Local cCabec2 := OemtoAnsi(STR0005) //"ENTREGA   FISCAL                                                                                        "

	cCabec1	+= Upper(Substr(Padr(RetTitle('A1_MUN'),16),1,16)+ Substr(Padr(RetTitle('A1_EST'),6),1,6))+STR0022 // " COND. PAGO"

	If cPaisLoc <> "BRA"
		cCabec1 	:= OemtoAnsi(STR0018) // "SECUENCIA FACTURA(1)    SERIE PEDIDO  CLIENTE   NOMBRE               DIRECCION                                "
		cCabec1	+= Upper(Substr(Padr(RetTitle('A1_MUN'),16),1,16)+ Substr(Padr(RetTitle('A1_EST'),6),1,6)) +STR0022 // " COND. PAGO"
		cCabec2 	:= OemtoAnsi(STR0019)+Upper(Substr(GetDescRem(),1,7))+"(2)" //"ENTREGA   "
	Endif
	dbSelectArea(cString)
	dbSetOrder(2)
	cIndDAK := CriaTrab(NIL,.F.)

	#IFDEF TOP	      

	If TcSrvType() != "AS/400"	
		//dbSelectArea("SX3")
		///dbSetOrder(2)
		//MsSeek("DAK_DATA")
		aadd(aStruQry,{"DAK_DATA",GetSX3Cache("DAK_DATA", "X3_TIPO"),TAMSX3("DAK_DATA")[1],TAMSX3("DAK_DATA")[2]})			

		//MsSeek("DAK_PESO")
		aadd(aStruQry,{"DAK_PESO",GetSX3Cache("DAK_PESO", "X3_TIPO"),TAMSX3("DAK_PESO")[1],TAMSX3("DAK_PESO")[2]})			

		//MsSeek("DAK_CAPVOL")
		aadd(aStruQry,{"DAK_CAPVOL",GetSX3Cache("DAK_CAPVOL", "X3_TIPO"),TAMSX3("DAK_CAPVOL")[1],TAMSX3("DAK_CAPVOL")[2]})			

		//MsSeek("DAK_PTOENT")
		aadd(aStruQry,{"DAK_PTOENT",GetSX3Cache("DAK_PTOENT", "X3_TIPO"),TAMSX3("DAK_PRTENT")[1],TAMSX3("DAK_PTOENT")[2]})			

		//MsSeek("DAK_VALOR")
		aadd(aStruQry,{"DAK_VALOR",GetSX3Cache("DAK_VALOR", "X3_TIPO"),TAMSX3("DAK_VALOR")[1],TAMSX3("DAK_VALOR")[2]})			

		//MsSeek("DAI_PESO")
		aadd(aStruQry,{"DAI_PESO",GetSX3Cache("DAI_PESO", "X3_TIPO"),TAMSX3("DAI_PESO")[1],TAMSX3("DAI_PESO")[2]})			

		//MsSeek("DAI_CAPVOL")
		aadd(aStruQry,{"DAI_CAPVOL",GetSX3Cache("DAI_CAPVOL", "X3_TIPO"),TAMSX3("DAI_CAPVOL")[1],TAMSX3("DAI_CAPVOL")[2]})			

		cQuery := "SELECT DAK_COD, DAK_SEQCAR, DAK_CAMINH, DAK_MOTORI, DAK_DATA, DAK_PESO, DAK_CAPVOL, DAK_PTOENT, "
		cQuery += "DAK_VALOR, DAK_HORA, DAI_COD, DAI_SEQCAR,DAI_SEQUEN, DAI_PEDIDO, DAI_CLIENT, DAI_LOJA, DAI_PESO, DAI_CAPVOL, DAI_NFISCA, "
		cQuery += "DAI_SERIE, A1_FILIAL, A1_COD,A1_LOJA, A1_NREDUZ, A1_END, A1_MUN, A1_EST "		

		If nTipoOper == 2 .Or. nTipoOper == 3
			cQuery += ",DAI_FILPV "
		Endif			

		cQuery += " FROM "+ RetSqlName("DAK")+ " DAK ,"
		cQuery += RetSqlName("DAI")+ " DAI ,"
		cQuery += RetSqlName("SA1")+ " SA1 " 		

		cQuery += " WHERE DAK_FILIAL = '"+xFilial("DAK")+"' "                    
		cQuery += " AND DAK_COD >= '"+mv_par01+"' AND DAK_COD <='"+mv_par02+"' "
		cQuery += " AND DAK_SEQCAR >= '"+mv_par03+"' AND DAK_SEQCAR <='"+mv_par04+"' "
		cQuery += " AND DAK_CAMINH >= '"+mv_par05+"' AND DAK_CAMINH <='"+mv_par06+"' "
		cQuery += " AND DAK_MOTORI >= '"+mv_par07+"' AND DAK_MOTORI <='"+mv_par08+"' "                 
		cQuery += " AND DAK_DATA >= '"+Dtos(mv_par09)+"' AND DAK_DATA <='"+Dtos(mv_par10)+"' "
		cQuery += " AND DAK_FEZNF = '1'"
		cQuery += " AND DAK.D_E_L_E_T_ = ' '"

		cQuery += " AND DAI_FILIAL = '"+xFilial("DAI")+"' "
		cQuery += " AND DAI_COD = DAK_COD "		
		cQuery += " AND DAI_SEQCAR = DAK_SEQCAR "		
		cQuery += " AND DAI.D_E_L_E_T_ = ' '"		

		cQuery += " AND A1_FILIAL = "+Iif(nTipoOper == 1,"'"+xFilial("SA1")+"'", OsFilQry("SA1","DAI.DAI_FILPV") )
		cQuery += " AND A1_COD = DAI_CLIENT "
		cQuery += " AND A1_LOJA = DAI_LOJA "
		cQuery += " AND SA1.D_E_L_E_T_ = ' '"    	

		cQuery += "ORDER BY DAK_COD,DAK_SEQCAR,DAI_SEQUEN,DAI_PEDIDO"

		cQuery := ChangeQuery(cQuery)
		dBUseArea(.t.,"TOPCONN",TCGENQRY(,,cQuery),"TRBCAR",.f.,.t.)		

		For nX := 1 To Len(aStruQry)
			If ( aStruQry[nX][2] <> "C" )
				TcSetField("TRBCAR",aStruQry[nX][1],aStruQry[nX][2],aStruQry[nX][3],aStruQry[nX][4])
			EndIf
		Next nX

		cAliasDAK := "TRBCAR"
		cAliasDAI := "TRBCAR"
		cAliasSA1 := "TRBCAR"          
		lQuery    := .T.

	Else

		#ENDIF

		cKey := IndexKey()

		cCondicao := 'DAK_FILIAL == "'+xFilial("DAK")+'".And.' 
		cCondicao += 'DAK_COD >= "'+mv_par01+'".And.DAK_COD <="'+mv_par02+'".And.'
		cCondicao += 'DAK_SEQCAR >= "'+mv_par03+'".And.DAK_SEQCAR <="'+mv_par04+'".And.'
		cCondicao += 'DAK_CAMINH >= "'+mv_par05+'".And.DAK_CAMINH <="'+mv_par06+'".And.'    
		cCondicao += 'DAK_MOTORI >= "'+mv_par07+'".And.DAK_MOTORI <="'+mv_par08+'".And.'		
		cCondicao += 'Dtos(DAK_DATA) >= "'+Dtos(mv_par09)+'".And.Dtos(DAK_DATA) <="'+Dtos(mv_par10)+'".And.'
		cCondicao += 'DAK_FEZNF == "1"'

		IndRegua("DAK",cIndDAK,cKey,,cCondicao,"Selecionando Registros ...") //"Selecionando Registros ..."
		nIndDAK := RetIndex("DAK")

		dbSetIndex(cIndDAK+OrdBagExT())
		dbSetOrder(nIndDAK+1)

		cAliasDAK := "DAK"
		cAliasDAI := "DAI"
		cAliasSA1 := "SA1"

		#IFDEF TOP
	Endif
	#ENDIF			


	dbSelectArea(cAliasDAK)

	dbGotop()

	While !Eof() 

		lFirst := .T.    
		lSkip := .F. 

		#IFNDEF WINDOWS
		If LastKey() = 286
			lEnd := .T.
		EndIf
		#ENDIF
		If lEnd
			@ Prow()+1,001 PSAY STR0006 //"CANCELADO PELO OPERADOR"
			Exit
		EndIf

		If ( li > 57 )
			li := cabec(Titulo,cCabec1,cCabec2,nomeprog,Tamanho,CHRCOMP)
			li++
		Endif


		dbSelectArea("DA3")
		dbSetOrder(1)
		MsSeek(xFilial("DA3")+(cAliasDAK)->DAK_CAMINH)

		dbSelectArea("DA4")
		dbSetOrder(1)
		MsSeek(xFilial("DA4")+(cAliasDAK)->DAK_MOTORI)

		@ li,000 PSAY OemtoAnsi(STR0006)+ (cAliasDAK)->DAK_COD+"-"+(cAliasDAK)->DAK_SEQCAR //"CARGA   : "
		li++
		@ li,000 PSAY OemtoAnsi(STR0007)+ (cAliasDAK)->DAK_CAMINH + " - " + DA3->DA3_DESC  //"VEICULO : "
		@ li,055 PSAY OemtoAnsi(STR0008)+(cAliasDAK)->DAK_MOTORI + " - " + DA4->DA4_NOME //"MOTORISTA : "
		li++
		@ li,000 PSAY OemtoAnsi(STR0009) //"PESO    :" 
		@ li,010 PSAY (cAliasDAK)->DAK_PESO Picture PesqPict("DAK","DAK_PESO")  
		@ li,025 PSAY OemtoAnsi(STR0010) //"VOLUME M3 : "
		@ li,037 PSAY (cAliasDAK)->DAK_CAPVOL Picture PesqPict("DAK","DAK_CAPVOL")  	
		@ li,052 PSAY OemtoAnsi(STR0011) //"PTOS ENTREGA : "
		@ li,067 PSAY (cAliasDAK)->DAK_PTOENT Picture PesqPict("DAK","DAK_PTOENT")  	
		//@ li,076 PSAY OemtoAnsi(STR0012) //"VALOR : "                                        
		//@ li,084 PSAY (cAliasDAK)->DAK_VALOR Picture PesqPict("DAK","DAK_VALOR")  		
		li++ 
		@ li,000 PSAY OemtoAnsi(STR0013) +DtoC((cAliasDAK)->DAK_DATA) + OemtoAnsi(STR0014) + (cAliasDAK)->DAK_HORA //"DATA    :"
		li++
		li++

		If !lQuery
			dbSelectArea(cAliasDAI)
			dbSetOrder(1)
			MsSeek(xfilial("DAI")+(cAliasDAK)->DAK_COD+(cAliasDAK)->DAK_SEQCAR)

			bWhileDAI := { || !Eof() .And. (cAliasDAI)->DAI_FILIAL+(cAliasDAI)->DAI_COD+(cAliasDAI)->DAI_SEQCAR == ;
			xFilial("DAI")+(cAliasDAK)->DAK_COD+(cAliasDAK)->DAK_SEQCAR }
		Else   
			cCodDAK   := (cAliasDAK)->DAK_COD
			cSeqDAK   := (cAliasDAK)->DAK_SEQCAR		
			bWhileDAI :=  {|| (cAliasDAI)->(!Eof()) .And. (cAliasDAI)->DAI_COD+(cAliasDAI)->DAI_SEQCAR == ;
			cCodDAK+cSeqDAK }	
		Endif		

		aFormas := OsFormasPg((cAliasDAI)->DAI_COD,(cAliasDAI)->DAI_SEQCAR,1,3,@aDevol)

		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³Imprime formas de pagamento por cliente                  ³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		If Len(aFormas) > 0
			aFormas := aSort(aFormas,,,{|x,y| x[2] < y[2] } )		

			@ li,000 PSAY OemtoAnsi(STR0015) //"FORMAS DE PAGAMENTO"      	  
			li++

			For nX := 1 to Len(aFormas)

				#IFNDEF WINDOWS
				If LastKey() = 286
					lEnd := .T.
				EndIf
				#ENDIF
				If lEnd
					@ Prow()+1,001 PSAY STR0006 //"CANCELADO PELO OPERADOR"
					Exit
				EndIf

				If ( li > 57 )
					li := cabec(Titulo,cCabec1,cCabec2,nomeprog,Tamanho,CHRCOMP)
					li++
				Endif

				SA1->(dbSetOrder(1))
				SA1->(MsSeek(xFilial("SA1")+aFormas[nX][2]))

				@ li,000 PSAY OemtoAnsi(STR0016) //"CLIENTE :"
				@ li,011 PSAY SA1->A1_COD+"-"+SA1->A1_LOJA+" "+Alltrim(SA1->A1_NOME) + "  " + SA1->A1_MUN

				li++

				cCliLoja := aFormas[nX][2]
				nTotForma := 0					

				For nY := nX to Len(aFormas)

					#IFNDEF WINDOWS
					If LastKey() = 286
						lEnd := .T.
					EndIf
					#ENDIF
					If lEnd
						@ Prow()+1,001 PSAY STR0006 //"CANCELADO PELO OPERADOR"
						Exit
					EndIf

					If ( li > 57 )
						li := cabec(Titulo,cCabec1,cCabec2,nomeprog,Tamanho,CHRCOMP)
						li++
					Endif

					If aFormas[nY][2] == cCliLoja
						If !Empty(	aFormas[nY][3]+aFormas[nY][4])
							@ li,005 PSAY Alltrim(aFormas[nY][3])
							@ li,010 PSAY Alltrim(aFormas[nY][4])
						Else
							@ li,005 PSAY STR0021 //"Nao informada"
						Endif
						@ li,036 PSAY aFormas[nY][5] Picture "@E 99,999,999.99"
						nTotForma += aFormas[nY][5]
						li++
					Else        			    
						@ li,000 PSAY Replicate("-",50)
						li++
						@ li,000 PSAY OemtoAnsi(STR0017) //"TOTAL =>"
						@ li,036 PSAY nTotForma  Picture "@E 99,999,999.99"
						li++
						li++
						Exit	
					Endif	        			
				Next nY		

				nX := nY-1

			Next nX

			@ li,000 PSAY Replicate("-",50)
			li++
			@ li,000 PSAY OemtoAnsi(STR0017) //"TOTAL =>"
			@ li,036 PSAY nTotForma  Picture "@E 99,999,999.99"
			li++
			li++

		Endif

		@ li,000 PSAY __PrtThinLine()
		li++

		While Eval(bWhileDAI)

			If ( li > 57 )
				li := cabec(Titulo,cCabec1,cCabec2,nomeprog,Tamanho,CHRCOMP)
				li++
			Endif

			If !lQuery                

				cFilPv := Iif(nTipoOper == 1, xFilial("SA1"), (cAliasDAI)->DAI_FILPV )

				dbSelectArea(cAliasSA1)
				dbSetOrder(1)
				MsSeek(OsFilial("SA1",cFilPv)+(cAliasDAI)->DAI_CLIENT+(cAliasDAI)->DAI_LOJA)
			Endif				

			cFilPv := Iif(nTipoOper == 1, xFilial("SD2"), (cAliasDAI)->DAI_FILPV )
			dbSelectArea(cAliasSD2)
			dbSetOrder(8)
			If MsSeek(OsFilial("SD2",cFilPv)+(cAliasDAI)->DAI_PEDIDO)

				While (cAliasSD2)->(!Eof()) .And. (cAliasSD2)->D2_FILIAL+(cAliasSD2)->D2_PEDIDO  == ;
				OsFilial("SD2",cFilPv)+(cAliasDAI)->DAI_PEDIDO

					cFilPv := Iif(nTipoOper == 1, xFilial("SF2"), (cAliasSD2)->D2_FILIAL )

					dbSkip()
					nRecSD2 := (cAliasSD2)->(Recno())
					dbSkip(-1)

					dbSelectArea(cAliasSF2)
					dbSetOrder(1)
					If MsSeek(OsFilial("SF2",cFilPv)+SD2->D2_DOC+SD2->D2_SERIE+SD2->D2_CLIENTE+SD2->D2_LOJA)

						If ( SF2->F2_CARGA >= mv_par01 .Or. SF2->F2_CARGA <= mv_par02 ) .And. ( SF2->F2_CARGA == (cAliasDAK)->DAK_COD .And. ;
						SF2->F2_SEQCAR == (cAliasDAK)->DAK_SEQCAR )

							If ( li > 57 )
								li := cabec(Titulo,cCabec1,cCabec2,nomeprog,Tamanho,CHRCOMP)
								li++
							Endif

							SE4->(dbSetOrder(1))
							SE4->(MsSeek(xFilial("SE4")+(cAliasSF2)->F2_COND))

							@ li,000 PSAY (cAliasDAI)->DAI_SEQUEN
							If cPaisLoc <> "BRA" 
								If IsRemito(1,cAliasSF2+"->F2_TIPODOC")
									@li,007 PSAY "(2)"
								Else
									@li,007 PSAY "(1)"
								Endif
							Endif

							@ li,010 PSAY (cAliasSF2)->F2_DOC
							@ li,024 PSAY (cAliasSF2)->F2_SERIE
							@ li,030 PSAY (cAliasDAI)->DAI_PEDIDO
							@ li,038 PSAY (cAliasDAI)->DAI_CLIENT+"-"+(cAliasDAI)->DAI_LOJA		 
							@ li,048 PSAY Substr((cAliasSA1)->A1_NREDUZ,1,20)
							@ li,069 PSAY Substr((cAliasSA1)->A1_END,1,40)
							@ li,110 PSAY Substr((cAliasSA1)->A1_MUN,1,15)
							@ li,126 PSAY (cAliasSA1)->A1_EST
							@ li,133 PSAY (cAliasSF2)->F2_COND+"-"+SE4->E4_DESCRI
							li++

							If mv_par11 == 1

								li++
								@ li,000 PSAY STR0020 //"PRODUTO              DESCRICAO                                 QTDE             VALOR"
								li++
								@ li,000 PSAY __PrtThinLine()     							
								li++

								dbSelectArea(cAliasSD2)
								dbSetOrder(3)
								MsSeek(xFilial("SD2")+(cAliasSF2)->F2_DOC+(cAliasSF2)->F2_SERIE+(cAliasSF2)->F2_CLIENTE+(cAliasSF2)->F2_LOJA)


								nTotal := 0	
								While (cAliasSD2)->(!Eof()) .And. (cAliasSD2)->D2_FILIAL == xFilial("SD2") .And. ;
								(cAliasSD2)->D2_DOC == (cAliasSF2)->F2_DOC .And.;
								(cAliasSD2)->D2_SERIE == (cAliasSF2)->F2_SERIE .And.;
								(cAliasSD2)->D2_CLIENTE == (cAliasSF2)->F2_CLIENTE .And.;
								(cAliasSD2)->D2_LOJA == (cAliasSF2)->F2_LOJA

									If (cAliasSD2)->D2_PEDIDO == (cAliasDAI)->DAI_PEDIDO

										SB1->(dbSetOrder(1))
										SB1->(MsSeek(OsFilial("SB1",cFilPv)+(cAliasSD2)->D2_COD))

										@ li,000 PSAY (cAliasSD2)->D2_COD
										@ li,021 PSAY SB1->B1_DESC
										@ li,056 PSAY (cAliasSD2)->D2_QUANT Picture PesqPict("SD2","D2_QUANT")
										nImpos	:=	0
										If cPaisLoc == "BRA"
											@ li,071 PSAY (cAliasSD2)->D2_TOTAL+(cAliasSD2)->D2_VALIPI+(cAliasSD2)->D2_ICMSRET Picture PesqPict("SD2","D2_TOTAL")
											nTotal += (cAliasSD2)->D2_TOTAL+(cAliasSD2)->D2_VALIPI+(cAliasSD2)->D2_ICMSRET
										Else
											aImpostos	:=	TesImpInf((cAliasSD2)->D2_TES)
											For nY:=1 to Len(aImpostos)
												If ( aImpostos[nY][3]=="1" )
													nImpos+=(cAliasSD2)->&(aImpostos[nY][2])
												Endif
											Next
											@ li,071 PSAY (cAliasSD2)->D2_TOTAL+nImpos Picture PesqPict("SD2","D2_TOTAL")
											nTotal += (cAliasSD2)->D2_TOTAL+nImpos	        							
										Endif
										li++                
									Endif	

									(cAliasSD2)->(dbSkip())						                                    
								Enddo						                                    

								@ li,000 PSAY __PrtThinLine()     

								li++
								@ li,055 PSAY OemtoAnsi(STR0017) //"TOTAL ==>"
								@ li,071 PSAY nTotal Picture PesqPict("SF2","F2_VALBRUT")
								li++
								li++

							Endif

							Exit

						Endif

					Endif	

					dbSelectArea(cAliasSD2)
					dbSetOrder(8)					
					MsGoto(nRecSd2)

				Enddo
			Endif			

			dbSelectArea(cAliasDAI)
			dbSkip()
			lSkip := .T.

		Enddo		

		li   := 80                    
		lImp := .T.

		If !lQuery .Or. !lSkip	
			dbSelectArea(cAliasDAK)
			dbSkip()
		EndIf

	Enddo

	If ( lImp )
		Roda(cbCont,cbText,Tamanho)
	EndIf

	If lQuery
		dbSelectArea("TRBCAR")
		dbCloseArea()
	Else	     
		dbSelectArea("DAK")
		Ferase(cIndDAK+OrdBagExt())
		RetIndex("DAK")
	Endif

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
±±ºPrograma  ³AjustaSX1 ºAutor  ³  Sabrina Passini   º Data ³  29/04/05   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³                                                            º±±
±±º          ³                                                            º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ OMSR030 MP8  				                              º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Static Function AjustaSX1()

	Local aHelp	:= {}  

	Aadd(aHelp,{{"Informe o numero da carga inicial a ser considerado na selecao"   },{"Informe el numero de la carga inicial que se considerara en la seleccion"}, {" "	}})
	Aadd(aHelp,{{"Informe o numero da carga final a ser considerado na selecao"   	},{"Informe el numero de la carga final que se considerara en la seleccion"},	{" "	}})
	Aadd(aHelp,{{"Informe a sequencia inicial da carga a ser considerado na selecao"},{"Informe la secuencia inicial de la carga que se considerara en la seleccion"},	{" "	}})
	Aadd(aHelp,{{"Informe a sequencia final da carga a ser considerado na selecao"	 },{"Informe la secuencia final de la carga que se considerara en la seleccion"	},	{" "	}})
	Aadd(aHelp,{{"Informe o codigo do veiculo inicial a ser considerado na selecao" },{"Informe el codigo del vehiculo inicial que se considerara en la seleccion" },	{" "	}})
	Aadd(aHelp,{{"Informe o codigo do veiculo final a ser considerado na selecao"	},{"Informe el codigo del vehiculo final que se considerara en la seleccion"	},	{" "	}})
	Aadd(aHelp,{{"Informe o codigo do motorista inicial a ser considerado na selecao"},	{"Informe el codigo del conductor inicial que se considerara en la seleccion"	},	{" "	}})
	Aadd(aHelp,{{"Informe o codigo do motorista final a ser considerado na selecao"	},{"Informe el codigo del conductor final que se considerara en la seleccion"	},	{" "	}})
	Aadd(aHelp,{{"Informe a data inicial da geracao da carga a ser considerado na selecao" },{"Informe la fecha inicial de la generacion de la carga que se considerara en la seleccion"	},	{" "	}})
	Aadd(aHelp,{{"Informe a data final da geracao da carga a ser considerado na selecao" },	{"Informe la fecha final de la generacion de la carga que se considerara en la seleccion"	},	{" "	}})
	Aadd(aHelp,{{"Informe o codigo da loja do cliente final a ser considerado na selecao"	},	{"Informe el Tipo de Informe"},	{" "	}})

	PutSx1(cPerg, '01', 'Carga de         ?', 'De Carga       ?', 'Load from      ?', 'mv_ch1', 'C', 6, 0, 0, 'G', '', '', '', '', 'mv_par01', 'Sim'    , 'Si'     , 'Yes'  , '', 'Nao'        , 'No'         , 'No'         ,'','','','','','','','','', aHelp[1][1],aHelp[1][2],aHelp[1][3])
	PutSx1(cPerg, '02', 'Carga ate        ?', 'A Carga        ?', 'Load to        ?', 'mv_ch2', 'C', 6, 0, 0, 'G', '', '', '', '', 'mv_par02', 'Sim'    , 'Si'     , 'Yes'  , '', 'Nao'        , 'No'         , 'No'         ,'','','','','','','','','', aHelp[2][1],aHelp[2][2],aHelp[2][3])
	PutSx1(cPerg, '03', 'Sequencia de     ?', 'De Secuencia   ?', 'Sequence from  ?', 'mv_ch3', 'C', 2, 0, 0, 'G', '', '', '', '', 'mv_par03', 'Sim'    , 'Si'     , 'Yes'  , '', 'Nao'        , 'No'         , 'No'         ,'','','','','','','','','', aHelp[3][1],aHelp[3][2],aHelp[3][3])
	PutSx1(cPerg, '04', 'Sequencia ate    ?', 'A Secuencia    ?', 'Sequence to    ?', 'mv_ch4', 'C', 2, 0, 0, 'G', '', '', '', '', 'mv_par04', 'Sim'    , 'Si'     , 'Yes'  , '', 'Nao'        , 'No'         , 'No'         ,'','','','','','','','','', aHelp[4][1],aHelp[4][2],aHelp[4][3])
	PutSx1(cPerg, '05', 'Veiculo de       ?', 'De Vehiculo    ?', 'Vehicle from   ?', 'mv_ch5', 'C', 8, 0, 0, 'G', '', 'DA3', '', '', 'mv_par05', 'Sim'    , 'Si'     , 'Yes'  , '', 'Nao'        , 'No'         , 'No'         ,'','','','','','','','','', aHelp[5][1],aHelp[5][2],aHelp[5][3])
	PutSx1(cPerg, '06', 'Veiculo ate      ?', 'A Vehiculo     ?', 'Vehicle to     ?', 'mv_ch6', 'C', 8, 0, 0, 'G', '', 'DA3', '', '', 'mv_par06', 'Sim'    , 'Si'     , 'Yes'  , '', 'Nao'        , 'No'         , 'No'         ,'','','','','','','','','', aHelp[6][1],aHelp[6][2],aHelp[6][3])
	PutSx1(cPerg, '07', 'Motorista de     ?', 'De Conductor   ?', 'Driver from    ?', 'mv_ch7', 'C', 6, 0, 0, 'G', '', 'DA4', '', '', 'mv_par07', 'Sim'    , 'Si'     , 'Yes'  , '', 'Nao'        , 'No'         , 'No'         ,'','','','','','','','','', aHelp[7][1],aHelp[7][2],aHelp[7][3])
	PutSx1(cPerg, '08', 'Motorista ate    ?', 'A Conductor    ?', 'Driver to      ?', 'mv_ch8', 'C', 6, 0, 0, 'G', '', 'DA4', '', '', 'mv_par08', 'Sim'    , 'Si'     , 'Yes'  , '', 'Nao'        , 'No'         , 'No'         ,'','','','','','','','','', aHelp[8][1],aHelp[8][2],aHelp[8][3])
	PutSx1(cPerg, '09', 'Data de          ?', 'De Fecha       ?', 'Date from      ?', 'mv_ch9', 'D', 8, 0, 0, 'G', '', '', '', '', 'mv_par09', 'Sim'    , 'Si'     , 'Yes'  , '', 'Nao'        , 'No'         , 'No'         ,'','','','','','','','','', aHelp[9][1],aHelp[9][2],aHelp[9][3])
	PutSx1(cPerg, '10', 'Data ate         ?', 'A Fecha        ?', 'Date to        ?', 'mv_chA', 'D', 8, 0, 0, 'G', '', '', '', '', 'mv_par10', 'Sim'    , 'Si'     , 'Yes'  , '', 'Nao'        , 'No'         , 'No'         ,'','','','','','','','','', aHelp[10][1],aHelp[10][2],aHelp[10][3])
	PutSx1(cPerg, '11', 'Tipo Relatorio   ?', 'Tipo de Informe?', 'Type of Report ?', 'mv_chB', 'N', 1, 0, 0, 'C', '', '', '', '', 'mv_par11', 'Analitico'    , 'Analitico'     , 'Detailed'  , '', 'Sintetico'        , 'Sintetico'         , 'Summarized'         ,'','','','','','','','','', aHelp[11][1],aHelp[11][2],aHelp[11][3])

Return Nil

