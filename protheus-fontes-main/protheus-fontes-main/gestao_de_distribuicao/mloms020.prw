#INCLUDE "OMSR020.CH"
#IFNDEF WINDOWS
#DEFINE PSAY SAY
#ENDIF
#DEFINE CHRCOMP If(aReturn[4]==1,15,18)

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Programa  ³MLOMS020   ³ Autor ³ Henry Fila            ³ Data ³ 20.06.01 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³Relatorio de Cargas                                         ³±±
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

user Function MLOMS020()

	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³Define Variaveis                                                        ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	#IFDEF WINDOWS
	Local Titulo  := OemToAnsi(STR0001) //"Listagem de cargas"
	Local cDesc1  := OemToAnsi(STR0002) //"Este relatorio ira imprimir a listagem de cargas de acordo"
	Local cDesc2  := OemToAnsi(STR0003) //"com os parametros informados pelo usuario"
	Local cDesc3  := OemToAnsi("") 
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
	Local wnrel   := "OMSR020"  // Nome do Arquivo utilizado no Spool
	Local nomeprog:= "OMSR020"  // nome do programa

	Private Tamanho := "M" // P/M/G
	Private Limite  := 132 // 80/132/220
	Private cPerg   := "OMR020"
	Private aOrdem  := {STR0019,STR0020}
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

	dbSelectArea("SD2")
	dbSetOrder(1)

Return(.T.)

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Program   ³ ImpDet   ³ Autor ³ Henry Fila            ³ Data ³02.07.1998³±±
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

	Do Case
		Case aReturn[8] == 1 .And. mv_par13 == 1
		ImpSeqSC9(lEnd,wnrel,cString,nomeprog,Titulo)
		Case aReturn[8] == 2 .And. mv_par13 == 1
		ImpPrdSC9(lEnd,wnrel,cString,nomeprog,Titulo)
		Case aReturn[8] == 1 .And. mv_par13 == 2
		ImpSeqSD2(lEnd,wnrel,cString,nomeprog,Titulo)
		Case aReturn[8] == 2 .And. mv_par13 == 2
		ImpPrdSD2(lEnd,wnrel,cString,nomeprog,Titulo)
	EndCase	

Return

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Program   ³ ImpSeqSD2³ Autor ³ Henry Fila            ³ Data ³02.07.1998³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³Controle de Fluxo do Relatorio por sequencia de entrega     ³±±
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

Static Function ImpSeqSD2(lEnd,wnrel,cString,nomeprog,Titulo)

	Local aStruQry  := {}
	Local aStruDAK  := {}  

	Local bWhileDAI := {||.T.}

	Local cbCont    := 0   // Numero de Registros Processados
	Local cbText    := ""  // Mensagem do Rodape
	Local cIndDAK   := ""
	Local cQuery    := "" 
	Local cCodDAK   := ""
	Local cSeqDAK   := ""
	Local cCliDAI   := ""
	Local cPedDAI   := ""
	Local cFilPv    := ""     
	Local cQryAd    := ""
	Local cName     := ""
	Local cAliasDAK := "DAK"
	Local cAliasDAI := "DAI"
	Local cAliasSC9 := "SC9"
	Local cAliasSA1 := "SA1"          
	Local cAliasSB1 := "SB1"

	Local nIndDAK   := 0  
	Local nPeso     := 0
	Local nCapVol   := 0
	Local nTipoOper := OsVlEntCom()
	Local nX        := 0

	Local lFirst    := .T.
	Local lImp      := .F. // Indica se algo foi impresso
	Local lQuery    := .F.

	Local cFilter	 := aReturn[7]
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³Imprime as cargas selecionada    ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ

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



	//Local cCabec1 := OemtoAnsi(STR0004) //"SEQUENCIA PEDIDO CLIENTE   NOME                                    PESO         VOLUME     NOTA  SERIE"
	//Local cCabec2 := OemtoAnsi(STR0005) //"ENTREGA                                                                             M3   FISCAL"

	Local cCabec1 := "SEQUENCIA PEDIDO CLIENTE   NOME                                    PESO                    NOTA  SERIE"
	Local cCabec2 := "ENTREGA                                                                                  FISCAL"


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

		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³Se o relatorio for analitico inclui os campos do SD2                  ³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ

		If mv_par11 == 2

			//MsSeek("D2_QUANT")
			aadd(aStruQry,{"D2_QUANT",GetSX3Cache("D2_QUANT", "X3_TIPO"),TAMSX3("D2_QUANT")[1],TAMSX3("D2_QUANT")[2]})

			//MsSeek("D2_PRCVEN")
			aadd(aStruQry,{"D2_PRCVEN",GetSX3Cache("D2_PRCVEN", "X3_TIPO"),TAMSX3("D2_PRCVEN")[1],TAMSX3("D2_PRCVEN")[2]})			

		Endif		

		cQuery := "SELECT "
		cQuery += "DAK_COD, DAK_SEQCAR, DAK_CAMINH, DAK_MOTORI, DAK_DATA, DAK_PESO, DAK_CAPVOL, DAK_PTOENT, "
		cQuery += "DAK_VALOR, DAK_HORA, DAI_COD, DAI_SEQCAR,DAI_SEQUEN, DAI_PEDIDO, DAI_CLIENT, DAI_LOJA, "
		cQuery += "DAI_PESO, DAI_CAPVOL,A1_NREDUZ,F2_DOC,F2_SERIE,F2_TIPODOC"

		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³Esta Rotina adiciona a cQuery os campos selecionados pelo usuario  |
		//³no filtro do usuario.                                              |
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ	   	

		aStruDAK := DAK->(dbStruct())	
		If !Empty(aReturn[7])
			For nX := 1 To DAK->(FCount())
				cName := DAK->(FieldName(nX))
				If AllTrim( cName ) $ aReturn[7]
					If aStruDAK[nX,2] <> "M"  
						If !cName $ cQuery .And. !cName $ cQryAd
							cQryAd += ","+cName
						Endif 	
					EndIf
				EndIf 			       	
			Next nX

			cQuery += cQryAd 	       

		Endif         

		If nTipoOper == 2 .Or. nTipoOper == 3
			cQuery += ",DAI_FILPV "
		Endif

		If mv_par11 == 2
			cQuery += ",D2_FILIAL, D2_CLIENTE, D2_LOJA, D2_PEDIDO ,D2_ITEMPV, D2_COD    , D2_QUANT , D2_PRCVEN, B1_COD, B1_DESC,B1_PESO,B1_PESBRU"		
		Endif			

		cQuery += " FROM "+ RetSqlName("DAK")+ " DAK , "
		cQuery += RetSqlName("DAI")+ " DAI , "
		cQuery += RetSqlName("SF2")+ " SF2 , "
		cQuery += RetSqlName("SA1")+ " SA1 "

		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³Se o relatorio for analitico inclui os arquivos do SD2                ³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		If mv_par11 == 2
			cQuery += ", "+RetSqlName("SB1")+ " SB1 , "		
			cQuery += RetSqlName("SD2")+ " SD2  "
		Endif			

		cQuery += " WHERE DAK_FILIAL = '"+xFilial("DAK")+"' "                    
		cQuery += " AND DAK_COD >= '"+mv_par01+"' AND DAK_COD <='"+mv_par02+"' "
		cQuery += " AND DAK_SEQCAR >= '"+mv_par03+"' AND DAK_SEQCAR <='"+mv_par04+"' "
		cQuery += " AND DAK_CAMINH >= '"+mv_par05+"' AND DAK_CAMINH <='"+mv_par06+"' "
		cQuery += " AND DAK_MOTORI >= '"+mv_par07+"' AND DAK_MOTORI <='"+mv_par08+"' "                 
		cQuery += " AND DAK_DATA >= '"+Dtos(mv_par09)+"' AND DAK_DATA <='"+Dtos(mv_par10)+"' "
		cQuery += " AND DAK_FEZNF = '1' "		
		cQuery += " AND DAK.D_E_L_E_T_ = ' '"

		cQuery += " AND DAI_FILIAL = '"+xFilial("DAI")+"' "                    
		cQuery += " AND DAI_COD = DAK_COD "		
		cQuery += " AND DAI_SEQCAR = DAK_SEQCAR "		
		cQuery += " AND DAI.D_E_L_E_T_ = ' '"		

		cQuery += " AND F2_FILIAL = "+Iif(nTipoOper == 1 .Or. Empty(xFilial("SF2")) , "'"+xFilial("SF2")+"'", OsFilQry("SF2","DAI.DAI_FILPV") )

		cQuery += " AND F2_CARGA   = DAI_COD    "
		cQuery += " AND F2_SEQCAR  = DAI_SEQCAR "
		cQuery += " AND F2_CLIENTE = DAI_CLIENT "
		cQuery += " AND F2_LOJA    = DAI_LOJA   "      
		cQuery += " AND SF2.D_E_L_E_T_ = ' '"		

		cQuery += " AND A1_FILIAL = "+Iif(nTipoOper == 1, "'"+xFilial("SA1")+"'", OsFilQry("SA1","DAI.DAI_FILPV") )
		cQuery += " AND A1_COD = DAI_CLIENT "
		cQuery += " AND A1_LOJA = DAI_LOJA "       
		cQuery += " AND SA1.D_E_L_E_T_ = ' ' "		    	

		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³Se o relatorio for analitico relaciona os arquivos do SD2             ³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		If mv_par11 == 2


			cQuery += " AND D2_FILIAL = "+Iif(nTipoOper == 1 , "'"+xFilial("SD2")+"'", OsFilQry("SD2","DAI.DAI_FILPV") )
			cQuery += " AND D2_DOC     = F2_DOC     "
			cQuery += " AND D2_SERIE   = F2_SERIE   "      
			cQuery += " AND D2_CLIENTE = F2_CLIENTE "
			cQuery += " AND D2_LOJA    = F2_LOJA    "      
			cQuery += " AND D2_TIPO    = F2_TIPO    "      
			cQuery += " AND SD2.D_E_L_E_T_ = ' '"		


			cQuery += " AND B1_FILIAL = "+Iif(nTipoOper == 1,"'"+xFilial("SB1")+"'",OsFilQry("SB1","SD2.D2_FILIAL") )
			cQuery += " AND B1_COD = D2_COD "
			cQuery += " AND SB1.D_E_L_E_T_ = ' ' "		    	    	

		Endif

		cQuery += "ORDER BY DAK_COD,DAK_SEQCAR,DAI_SEQUEN,DAI_PEDIDO"+Iif(mv_par11 == 2,",D2_ITEMPV","")

		cQuery := ChangeQuery(cQuery)

		dBUseArea(.t.,"TOPCONN",TCGENQRY(,,cQuery),"TRBCAR",.f.,.t.)


		For nX := 1 To Len(aStruQry)
			If ( aStruQry[nX][2] <> "C" )
				TcSetField("TRBCAR",aStruQry[nX][1],aStruQry[nX][2],aStruQry[nX][3],aStruQry[nX][4])
			EndIf
		Next nX

		cAliasDAK := "TRBCAR"
		cAliasDAI := "TRBCAR"
		cAliasSD2 := "TRBCAR"
		cAliasSF2 := "TRBCAR"
		cAliasSA1 := "TRBCAR"
		cAliasSB1 := "TRBCAR"		
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
		cAliasSD2 := "SD2"
		cAliasSF2 := "SF2"
		cAliasSA1 := "SA1"
		cAliasSB1 := "SB1"

		#IFDEF TOP
	Endif
	#ENDIF			


	dbSelectArea(cAliasDAK)

	dbGotop()

	While !Eof() 

		If !Empty(cFilter) .And. !(&cFilter.)
			DbSkip()
			Loop	
		Endif
		lFirst := .T.

		#IFNDEF WINDOWS
		If LastKey() = 286
			lEnd := .T.
		EndIf
		#ENDIF
		If lEnd
			@ Prow()+1,001 PSAY STR0006 //"CANCELADO PELO OPERADOR"
			Exit
		EndIf

		If ( li > 60 )
			li := cabec(Titulo,cCabec1,cCabec2,nomeprog,Tamanho,CHRCOMP)
			li++
		Endif


		dbSelectArea("DA3")
		dbSetOrder(1)
		MsSeek(xFilial("DA3")+(cAliasDAK)->DAK_CAMINH)

		dbSelectArea("DA4")
		dbSetOrder(1)
		MsSeek(xFilial("DA4")+(cAliasDAK)->DAK_MOTORI)

		@ li,000 PSAY OemtoAnsi(STR0006)+(cAliasDAK)->DAK_COD+"-"+(cAliasDAK)->DAK_SEQCAR //"CARGA   : "
		li++
		@ li,000 PSAY OemtoAnsi(STR0007)+ (cAliasDAK)->DAK_CAMINH + " - " + DA3->DA3_DESC //"VEICULO : "
		@ li,055 PSAY OemtoAnsi(STR0008)+(cAliasDAK)->DAK_MOTORI + " - " + DA4->DA4_NOME //"MOTORISTA : "	
		li++
		@ li,000 PSAY OemtoAnsi(STR0009) //"PESO    :" 
		@ li,010 PSAY (cAliasDAK)->DAK_PESO Picture PesqPict("DAK","DAK_PESO")  
		//@ li,025 PSAY OemtoAnsi(STR0010) //"VOLUME M3 : "
		//@ li,037 PSAY (cAliasDAK)->DAK_CAPVOL Picture PesqPict("DAK","DAK_CAPVOL")  	
		@ li,052 PSAY OemtoAnsi(STR0011) //"PTOS ENTREGA : "
		@ li,067 PSAY (cAliasDAK)->DAK_PTOENT Picture PesqPict("DAK","DAK_PTOENT")  	
		@ li,076 PSAY OemtoAnsi(STR0012) //"VALOR : "                                        
		@ li,084 PSAY (cAliasDAK)->DAK_VALOR Picture PesqPict("DAK","DAK_VALOR")  		
		li++ 
		@ li,000 PSAY OemtoAnsi(STR0013) +DtoC((cAliasDAK)->DAK_DATA) + OemtoAnsi(STR0014) + (cAliasDAK)->DAK_HORA
		li++
		@ li,000 PSAY Replicate('-',limite)        
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

		While Eval(bWhileDAI)

			If ( li > 60 )
				li := cabec(Titulo,cCabec1,cCabec2,nomeprog,Tamanho,CHRCOMP)
				li++
			Endif

			If !lQuery

				cFilPv := Iif(nTipoOper == 1, xFilial("SA1"),(cAliasDAI)->DAI_FILPV)

				dbSelectArea(cAliasSA1)
				dbSetOrder(1)
				MsSeek(OsFilial("SA1",cFilPv)+(cAliasDAI)->DAI_CLIENT+(cAliasDAI)->DAI_LOJA)

			Endif				

			If mv_par11 == 1
				// Acrescentado li++ 

				li++
				@ li,000 PSAY (cAliasDAI)->DAI_SEQUEN
				@ li,010 PSAY (cAliasDAI)->DAI_PEDIDO
				@ li,017 PSAY (cAliasDAI)->DAI_CLIENT+"-"+(cAliasDAI)->DAI_LOJA		 
				@ li,027 PSAY Substr((cAliasSA1)->A1_NREDUZ,1,30)
				@ li,059 PSAY (cAliasDAI)->DAI_PESO Picture PesqPict("DAI","DAI_PESO")
				//@ li,074 PSAY (cAliasDAI)->DAI_CAPVOL Picture PesqPict("DAI","DAI_CAPVOL")						
				If !lQuery
					SF2->(DbSetOrder(5))			
					SF2->(MSSeek(xFilial()+(cAliasDAI)->DAI_COD+(cAliasDAI)->DAI_SEQCAR))
				Endif
				If IsRemito(1,"'"+(cAliasSF2)->F2_TIPODOC+"'")
					@ li,089 PSAY Alltrim(GetDescRem()) + STR0018
				Else
					@ li,089 PSAY OemToAnsi(STR0017)
				Endif

				@ li,109 PSAY (cAliasSF2)->F2_DOC
				@ li,124 PSAY (cAliasSF2)->F2_SERIE 

				If lQuery
					dbSelectArea(cAliasDAI)
					dbSkip()
					Loop
				Endif			    	

			Else
				If !lFirst
					@ li,000 PSAY Replicate('-',limite)        
					lFirst := .F.	
				Endif			 

				li++
				@ li,000 PSAY (cAliasDAI)->DAI_SEQUEN
				@ li,010 PSAY (cAliasDAI)->DAI_PEDIDO
				@ li,017 PSAY (cAliasDAI)->DAI_CLIENT+"-"+(cAliasDAI)->DAI_LOJA		 
				@ li,027 PSAY Substr((cAliasSA1)->A1_NREDUZ,1,30)
				@ li,059 PSAY (cAliasDAI)->DAI_PESO Picture PesqPict("DAI","DAI_PESO")
				//@ li,074 PSAY (cAliasDAI)->DAI_CAPVOL Picture PesqPict("DAI","DAI_CAPVOL")						
				If !lQuery
					SF2->(DbSetOrder(5))			
					SF2->(MSSeek(xFilial()+(cAliasDAI)->DAI_COD+(cAliasDAI)->DAI_SEQCAR))
				Endif
				If IsRemito(1,"'"+(cAliasSF2)->F2_TIPODOC+"'")
					@ li,089 PSAY Alltrim(GetDescRem()) + STR0018
				Else
					@ li,089 PSAY OemToAnsi(STR0017)
				Endif

				@ li,109 PSAY (cAliasSF2)->F2_DOC
				@ li,124 PSAY (cAliasSF2)->F2_SERIE 
				li++				

				@ li,000 PSAY Replicate('-',limite)        
				li++				
				//@ li,000 PSAY OemtoAnsi(STR0015) //"ITEM PRODUTO         DESCRICAO                          QUANT.                VALOR            PESO              VOLUME"
				@ li,000 PSAY "ITEM PRODUTO         DESCRICAO                          QUANT.                VALOR            PESO"

				li++				
				@ li,000 PSAY Replicate('-',limite)        

				If lQuery

					cCarDAK := (cAliasDAK)->DAK_COD+(cAliasDAK)->DAK_SEQCAR
					cCliSD2 := (cAliasSD2)->D2_CLIENTE+ (cAliasSD2)->D2_LOJA

					bWhileSD2 := {|| (cAliasSD2)->(!Eof()) .And. (cAliasDAK)->DAK_COD+(cAliasDAK)->DAK_SEQCAR+(cAliasSD2)->D2_CLIENTE + (cAliasSD2)->D2_LOJA == ;
					cCarDAK+cCliSD2}

				Else			

					cFilPv := Iif(nTipoOper == 1 ,xFilial("SF2"), (cAliasDAI)->DAI_FILPV )

					dbSelectArea(cAliasSD2)
					dbSetOrder(3)
					MsSeek(OsFilial("SF2",cFilPv)+(cAliasSF2)->F2_DOC+(cAliasSF2)->F2_SERIE+(cAliasSF2)->F2_CLIENTE+(cAliasSF2)->F2_LOJA)

					bWhileSD2 := {|| !Eof() .And. OsFilial("SF2",cFilPv)+(cAliasSF2)->F2_DOC+(cAliasSF2)->F2_SERIE+(cAliasSF2)->F2_CLIENTE+(cAliasSF2)->F2_LOJA == ;
					OsFilial("SD2",cFilPv)+(cAliasSD2)->D2_DOC+(cAliasSD2)->D2_SERIE+(cAliasSD2)->D2_CLIENTE+(cAliasSD2)->D2_LOJA	}		
				Endif					

				While Eval(bWhileSD2)
					li++								

					If ( li > 60 )
						li := cabec(Titulo,cCabec1,cCabec2,nomeprog,Tamanho,CHRCOMP)
						li++
					Endif

					cFilPv := Iif(nTipoOper == 1, xFilial("SB1"), (cAliasSD2)->D2_FILIAL )

					If !lQuery                                                           

						dbSelectArea(cAliasSB1)
						dbSetOrder(1)
						MsSeek(OsFilial("SB1",(cAliasSD2)->D2_FILIAL)+(cAliasSD2)->D2_COD)

					Endif				   	

					nCapArm := OsPrCapArm((cAliasSB1)->B1_COD, cFilPv)
					nCapVol  := ( nCapArm * (cAliasSD2)->D2_QUANT )
					_PesoCar := _GetParam()
					If _PesoCar == "L"
						nPeso    := ( (cAliasSB1)->B1_PESO   * (cAliasSD2)->D2_QUANT )
					Else                                                         
						nPeso    := ( (cAliasSB1)->B1_PESBRU * (cAliasSD2)->D2_QUANT )				
					Endif	                                 

					@ li,000 PSAY (cAliasSD2)->D2_ITEMPV				    	
					@ li,005 PSAY (cAliasSD2)->D2_COD
					@ li,021 PSAY Substr((cAliasSB1)->B1_DESC,1,30)
					@ li,053 PSAY (cAliasSD2)->D2_QUANT Picture PesqPict("SD2","D2_QUANT")
					@ li,069 PSAY (cAliasSD2)->D2_QUANT *(cAliasSD2)->D2_PRCVEN Picture "@E 999,999,999.99"
					@ li,085 PSAY nPeso Picture "@E 999,999,999.99"				    	
					//@ li,105 PSAY nCapVol Picture "@E 999,999,999.99"				    					    	

					dbSelectArea(cAliasSD2)
					dbSkip()

				Enddo

				If mv_par12 == 1
					li := 80
				Endif				

			Endif					

			li++

			dbSelectArea(cAliasDAI)

			If !lQuery
				dbSkip()
			Endif			

		Enddo

		li := 80

		dbSelectArea(cAliasDAK)
		If !lQuery
			dbSkip()
		Endif			

	Enddo

	If ( lImp )
		Roda(cbCont,cbText,Tamanho)
	EndIf

	If lQuery
		dbSelectArea("TRBCAR")
		dbCloseArea()
	Endif	

	Set Device To Screen
	Set Printer To
	If ( aReturn[5] = 1 )
		dbCommitAll()
		OurSpool(wnrel)
	Endif
	MS_FLUSH()
Return(.T.)


/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Program   ³ ImpPrdSD2³ Autor ³ Henry Fila            ³ Data ³02.07.1998³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³Controle de Fluxo do Relatorio por sequencia de entrega     ³±±
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

Static Function ImpPrdSD2(lEnd,wnrel,cString,nomeprog,Titulo)

	Local aStruQry  := {}
	Local aStruDAK  := {}
	Local aStruSC9  := {}

	Local cbCont    := 0   // Numero de Registros Processados
	Local cbText    := ""  // Mensagem do Rodape
	Local cIndDAK   := ""
	Local cQuery    := "" 
	Local cCodDAK   := ""
	Local cSeqDAK   := ""
	Local cCliDAI   := ""
	Local cPedDAI   := ""
	Local cFilPv    := ""                                        
	Local cArqTRB   := ""

	Local nIndDAK   := 0  
	Local nPeso     := 0
	Local nCapVol   := 0
	Local nTipoOper := OsVlEntCom()
	Local nPosProd  := 0
	Local nX        := 0

	Local lFirst    := .T.
	Local lImp      := .F. // Indica se algo foi impresso
	Local lQuery    := .F.

	Local cFilter	 := aReturn[7]
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

	Local cCabec1 := OemtoAnsi(STR0021)
	Local cCabec2 := ""

	dbSelectArea(cString)
	dbSetOrder(2)
	cIndDAK := CriaTrab(NIL,.F.)

	#IFDEF TOP	      

	If TcSrvType() != "AS/400"	

		aStruDAK := DAK->(dbStruct())
		aStruSD2 := SD2->(dbStruct())		

		Aadd(aStruSD2,{'QTDE' ,'N',18,2})	
		Aadd(aStruSD2,{'VALOR','N',18,2})	

		cAliasQRY := "TRBQRY"

		cQuery := "SELECT F2_CARGA,F2_SEQCAR,DAK_MOTORI,DAK_CAMINH,DAK_DATA,DAK_CAPVOL,DAK_PTOENT,DAK_VALOR,DAK_PESO,"
		cQuery += "DAK_HORA,D2_COD,B1_DESC,B1_PESO,B1_PESBRU, SUM(D2_QUANT) QTDE, SUM(D2_TOTAL) VALOR"
		cQuery += " FROM "              
		cQuery += RetSqlName("SF2") + " SF2, "
		cQuery += RetSqlName("SD2") + " SD2, "
		cQuery += RetSqlName("SB1") + " SB1, "		
		cQuery += RetSqlName("SA1") + " SA1, "				
		cQuery += RetSqlName("DAK") + " DAK "		

		cQuery += " WHERE "		
		cQuery += " F2_FILIAL = "+Iif(nTipoOper == 1 , "'"+xFilial("SF2")+"'", OsFilQry("SF2","DAI.DAI_FILPV") )+" AND "
		cQuery += " F2_CARGA  >= '"+mv_par01+"' AND "		
		cQuery += " F2_CARGA  <= '"+mv_par02+"' AND "			
		cQuery += " F2_SEQCAR >= '"+mv_par03+"' AND "				
		cQuery += " F2_SEQCAR <= '"+mv_par04+"' AND "				
		cQuery += " SF2.D_E_L_E_T_ = ' ' AND "

		cQuery += " D2_FILIAL = "+Iif(nTipoOper == 1 , "'"+xFilial("SD2")+"'", OsFilQry("SD2","DAI.DAI_FILPV") )+" AND "
		cQuery += " D2_DOC     = F2_DOC     AND "
		cQuery += " D2_SERIE   = F2_SERIE   AND "      
		cQuery += " D2_CLIENTE = F2_CLIENTE AND "
		cQuery += " D2_LOJA    = F2_LOJA    AND "      
		cQuery += " D2_TIPO    = F2_TIPO    AND "      
		cQuery += " SD2.D_E_L_E_T_ = ' '    AND "		


		cQuery += "B1_FILIAL = '"+xFilial("SB1")+ "' AND "
		cQuery += "B1_COD    = D2_COD AND "
		cQuery += "SB1.D_E_L_E_T_ = ' ' AND "

		cQuery += "A1_FILIAL = '"+xFilial("SA1")+ "' AND "
		cQuery += "A1_COD    = F2_CLIENTE AND "
		cQuery += "A1_LOJA   = F2_LOJA AND "
		cQuery += "SA1.D_E_L_E_T_ = ' ' AND "

		cQuery += "DAK_FILIAL = '"+xFilial("DAK")+"' AND "
		cQuery += "DAK_COD    = F2_CARGA AND "
		cQuery += "DAK_SEQCAR = F2_SEQCAR AND "
		cQuery += "DAK_FEZNF = '1' AND "		
		cQuery += "DAK.D_E_L_E_T_ = ' ' "

		cQuery += "GROUP BY "
		cQuery += "F2_CARGA,F2_SEQCAR,DAK_MOTORI,DAK_CAMINH,DAK_DATA,DAK_CAPVOL,DAK_PTOENT,DAK_VALOR,DAK_PESO,"
		cQuery += "DAK_HORA,D2_COD,B1_DESC,B1_PESO,B1_PESBRU "

		cQuery += "ORDER BY F2_CARGA,F2_SEQCAR,D2_COD"

		cQuery := ChangeQuery(cQuery)
		dBUseArea(.t.,"TOPCONN",TCGENQRY(,,cQuery),cAliasQRY,.f.,.t.)

		For nX := 1 To Len(aStruDAK)
			If aStruDAK[nX][2]!="C"
				TcSetField(cAliasQRY,aStruDAK[nX][1],aStruDAK[nX][2],aStruDAK[nX][3],aStruDAK[nX][4])
			EndIf
		Next nX			

		For nX := 1 To Len(aStruSD2)
			If aStruSD2[nX][2]!="C"
				TcSetField(cAliasQRY,aStruSD2[nX][1],aStruSD2[nX][2],aStruSD2[nX][3],aStruSD2[nX][4])
			EndIf
		Next nX			

		While (cAliasQRY)->(!Eof())

			If lEnd
				@ Prow()+1,001 PSAY STR0006 //"CANCELADO PELO OPERADOR"
				Exit
			EndIf

			If ( li > 60 )
				li := cabec(Titulo,cCabec1,cCabec2,nomeprog,Tamanho,CHRCOMP)
				li++
			Endif


			dbSelectArea("DA3")
			dbSetOrder(1)
			MsSeek(xFilial("DA3")+(cAliasQRY)->DAK_CAMINH)

			dbSelectArea("DA4")
			dbSetOrder(1)
			MsSeek(xFilial("DA4")+(cAliasQRY)->DAK_MOTORI)

			cCarga := (cAliasQRY)->F2_CARGA+(cAliasQRY)->F2_SEQCAR

			@ li,000 PSAY OemtoAnsi(STR0006)+(cAliasQRY)->F2_CARGA+"-"+(cAliasQRY)->F2_SEQCAR //"CARGA   : "
			li++
			@ li,000 PSAY OemtoAnsi(STR0007)+(cAliasQRY)->DAK_CAMINH + " - " + DA3->DA3_DESC //"VEICULO : "
			@ li,055 PSAY OemtoAnsi(STR0008)+(cAliasQRY)->DAK_MOTORI + " - " + DA4->DA4_NOME //"MOTORISTA : "	
			li++
			@ li,000 PSAY OemtoAnsi(STR0009) //"PESO    :" 
			@ li,010 PSAY (cAliasQRY)->DAK_PESO Picture PesqPict("DAK","DAK_PESO")  
			//@ li,025 PSAY OemtoAnsi(STR0010) //"VOLUME M3 : "
			//@ li,037 PSAY (cAliasQRY)->DAK_CAPVOL Picture PesqPict("DAK","DAK_CAPVOL")  	
			@ li,052 PSAY OemtoAnsi(STR0011) //"PTOS ENTREGA : "
			@ li,067 PSAY (cAliasQRY)->DAK_PTOENT Picture PesqPict("DAK","DAK_PTOENT")  	
			@ li,076 PSAY OemtoAnsi(STR0012) //"VALOR : "                                        
			@ li,084 PSAY (cAliasQRY)->DAK_VALOR Picture PesqPict("DAK","DAK_VALOR")  		
			li++ 
			@ li,000 PSAY OemtoAnsi(STR0013) +DtoC((cAliasQRY)->DAK_DATA) + OemtoAnsi(STR0014) + (cAliasQRY)->DAK_HORA
			li++
			@ li,000 PSAY Replicate('-',limite)        
			li++

			While (cAliasQRY)->(!Eof()) .And. (cAliasQRY)->F2_CARGA+(cAliasQRY)->F2_SEQCAR == cCarga

				If lEnd
					@ Prow()+1,001 PSAY STR0006 //"CANCELADO PELO OPERADOR"
					Exit
				EndIf

				If ( li > 60 )
					li := cabec(Titulo,cCabec1,cCabec2,nomeprog,Tamanho,CHRCOMP)
					li++
				Endif

				cFilPv   := xFilial("SB1")
				nCapArm  := OsPrCapArm((cAliasQRY)->D2_COD, cFilPv)

				_PesoCar := _GetParam()
				If _PesoCar == "L"
					nPeso    := ( (cAliasQRY)->B1_PESO    * (cAliasQRY)->QTDE )
				Else                                                         
					nPeso    := ( (cAliasQRY)->B1_PESBRU * (cAliasQRY)->QTDE )				
				Endif	                                 
				nCapVol  := ( nCapArm * (cAliasQRY)->QTDE )				

				@ li,000 PSAY (cAliasQRY)->D2_COD
				@ li,018 PSAY SubStr((cAliasQRY)->B1_DESC,1,30)
				@ li,049 PSAY (cAliasQRY)->QTDE  Picture "@E 99,999,999.99"
				@ li,065 PSAY nPeso               Picture "@E 99,999.99"			
				//@ li,077 PSAY nCapVol             Picture "@E 99,999.99"			
				@ li,088 PSAY (cAliasQRY)->VALOR  Picture "@E 99,999,999.99"							

				li++			

				(cAliasQRY)->(dbSkip())

			Enddo

			li := 100

		Enddo

		dbSelectArea(cAliasQRY)
		dbCloseArea()

	Else

		#ENDIF

		Omr020Trb(@cArqTrb,aReturn[8])

		dbSelectArea("DAK")
		dbSetOrder(1)
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


		While !DAK->(Eof()) 

			If !Empty(cFilter) .And. !(&cFilter.)
				DbSkip()
				Loop	
			Endif

			//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
			//³Busca itens da carga                              ³
			//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
			DAI->(dbSetOrder(1))
			DAI->(MsSeek(xFilial("DAI")+DAK->DAK_COD+DAK->DAK_SEQCAR))

			While !DAI->(Eof()) .And. DAI->DAI_FILIAL == xFilial("DAI") .And.;
			DAI->DAI_COD    == DAK->DAK_COD .And. ;
			DAI->DAI_SEQCAR == DAK->DAK_SEQCAR		

				//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
				//³Busca pedidos da carga                            ³
				//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ

				cFilPv := Iif(nTipoOper == 1, xFilial("SC9"),DAI->DAI_FILPV)

				SF2->(DbSetOrder(5))			
				SF2->(MSSeek(xFilial()+DAI->DAI_COD+DAI->DAI_SEQCAR))

				SD2->(dbSetOrder(3))
				SD2->(MsSeek(OsFilial("SD2",cFilPv)+SF2->F2_DOC+SF2->F2_SERIE+SF2->F2_CLIENTE+SF2->F2_LOJA))

				bWhileSD2 := {|| !SD2->(Eof()) .And. 	OsFilial("SF2",cFilPv)+SF2->F2_DOC+SF2->F2_SERIE+SF2->F2_CLIENTE+SF2->F2_LOJA == ;
				OsFilial("SD2",cFilPv)+SD2->D2_DOC+SD2->D2_SERIE+SD2->D2_CLIENTE+SD2->D2_LOJA	}		

				While Eval(bWhileSD2)

					//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
					//³Busca produtos para aglutinar conforme o relatório³
					//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ

					SB1->(dbSetOrder(1))	
					SB1->(MsSeek(xFilial("SB1")+SD2->D2_COD))

					nCapArm  := OsPrCapArm(SB1->B1_COD, cFilPv)
					nCapVol  := ( nCapArm   * SD2->D2_QUANT )

					_PesoCar := _GetParam()
					If _PesoCar == "L"
						nPeso    := ( SB1->B1_PESO    * (cAliasSC9)->C9_QTDLIB )
					Else                                                         
						nPeso    := ( SB1->B1_PESBRU * (cAliasSC9)->C9_QTDLIB)				
					Endif	                                 

					dbSelectArea("TRBPRO")
					If !MsSeek(DAK->DAK_COD+DAK->DAK_SEQCAR+SD2->D2_COD)

						RecLock("TRBPRO",.T.)
						TRBPRO->TRB_CODCAR := DAK->DAK_COD 	
						TRBPRO->TRB_SEQCAR := DAK->DAK_SEQCAR
						TRBPRO->TRB_MOTORI := DAK->DAK_MOTORI
						TRBPRO->TRB_VEICUL := DAK->DAK_CAMINH
						TRBPRO->TRB_DATA   := DAK->DAK_DATA
						TRBPRO->TRB_HORA   := DAK->DAK_HORA
						TRBPRO->TRB_PTOENT := DAK->DAK_PTOENT
						TRBPRO->TRB_PESTOT := DAK->DAK_PESO
						TRBPRO->TRB_VOLTOT := DAK->DAK_CAPVOL
						TRBPRO->TRB_VALTOT := DAK->DAK_VALOR
						TRBPRO->TRB_CODPRO := SD2->D2_COD
						TRBPRO->TRB_DESPRO := SB1->B1_DESC
						TRBPRO->TRB_CODCLI := SD2->D2_CLIENTE
						TRBPRO->TRB_LOJA   := SD2->D2_LOJA
					Else
						RecLock("TRBPRO",.F.)								
					Endif        					

					TRBPRO->TRB_QUANT  += SD2->D2_QUANT
					TRBPRO->TRB_PESO   += nPeso								
					TRBPRO->TRB_CAPVOL += nCapvol   
					TRBPRO->TRB_VALOR  += SD2->D2_TOTAL

					MsUnlock()

					SD2->(dbSkip())

				Enddo

				DAI->(dbSkip())

			Enddo                       

			DAK->(dbSkip())			

		Enddo

		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³Impressao do relatorio                            ³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ

		//           1         2         3         4         5         6         7         8         9        10        11        12        13        14        15        16        17        18        19        20        21        22
		//"01234567890123456789012345678901234567890123456789012345678901234567890123456789012345678901234567890123456789012345678901234567890123456789012345678901234567890123456789012345678901234567890123456789012345678901234567890
		//"PRODUTO           DESCRICAO                         QUANTIDADE        PESO      VOLUME          VALOR    "
		//"XXXXXXXXXXXXXXXX  XXXXXXXXXXXXXXXXXXXXXXXXXXXXXX XX,XXX,XXX,XX   XX,XXX,XX   XX,XXX,XX  XX,XXX,XXX,XX


		dbSelectArea("TRBPRO")
		dbGotop()

		While !Eof()

			#IFNDEF WINDOWS
			If LastKey() = 286
				lEnd := .T.
			EndIf
			#ENDIF
			If lEnd
				@ Prow()+1,001 PSAY STR0006 //"CANCELADO PELO OPERADOR"
				Exit
			EndIf

			If ( li > 60 )
				li := cabec(Titulo,cCabec1,cCabec2,nomeprog,Tamanho,CHRCOMP)
				li++
			Endif

			cCarga := TRBPRO->TRB_CODCAR+TRBPRO->TRB_SEQCAR

			@ li,000 PSAY OemtoAnsi(STR0006)+TRBPRO->TRB_CODCAR+"-"+TRBPRO->TRB_SEQCAR //"CARGA   : "
			li++
			@ li,000 PSAY OemtoAnsi(STR0007)+TRBPRO->TRB_VEICUL + " - " + DA3->DA3_DESC //"VEICULO : "
			@ li,055 PSAY OemtoAnsi(STR0008)+TRBPRO->TRB_MOTORI + " - " + DA4->DA4_NOME //"MOTORISTA : "	
			li++
			@ li,000 PSAY OemtoAnsi(STR0009) //"PESO    :" 
			@ li,010 PSAY TRBPRO->TRB_PESTOT Picture PesqPict("DAK","DAK_PESO")  
			//@ li,025 PSAY OemtoAnsi(STR0010) //"VOLUME M3 : "
			//@ li,037 PSAY TRBPRO->TRB_VOLTOT Picture PesqPict("DAK","DAK_CAPVOL")  	
			@ li,052 PSAY OemtoAnsi(STR0011) //"PTOS ENTREGA : "
			@ li,067 PSAY TRBPRO->TRB_PTOENT Picture PesqPict("DAK","DAK_PTOENT")  	
			@ li,076 PSAY OemtoAnsi(STR0012) //"VALOR : "                                        
			@ li,084 PSAY TRBPRO->TRB_VALTOT Picture PesqPict("DAK","DAK_VALOR")  		
			li++ 
			@ li,000 PSAY OemtoAnsi(STR0013) +DtoC(TRBPRO->TRB_DATA) + OemtoAnsi(STR0014) + TRBPRO->TRB_HORA
			li++
			@ li,000 PSAY Replicate('-',limite)        
			li++

			While TRBPRO->(!Eof()) .And. TRBPRO->TRB_CODCAR+TRBPRO->TRB_SEQCAR == cCarga

				If lEnd
					@ Prow()+1,001 PSAY STR0006 //"CANCELADO PELO OPERADOR"
					Exit
				EndIf

				If ( li > 60 )
					li := cabec(Titulo,cCabec1,cCabec2,nomeprog,Tamanho,CHRCOMP)
					li++
				Endif

				@ li,000 PSAY TRBPRO->TRB_CODPRO
				@ li,018 PSAY SubStr(TRBPRO->TRB_DESPRO,1,30)
				@ li,049 PSAY TRBPRO->TRB_QUANT  Picture "@E 99,999,999.99"
				@ li,065 PSAY TRBPRO->TRB_PESO   Picture "@E 99,999.99"			
				//@ li,077 PSAY TRBPRO->TRB_CAPVOL Picture "@E 99,999.99"			
				@ li,088 PSAY TRBPRO->TRB_VALOR  Picture "@E 99,999,999.99"							
				li++			

				TRBPRO->(dbSkip())

			Enddo
			li := 100

		Enddo

		dbCloseArea("TRBPRO")
		Ferase(cArqTrb+GetDBExtension())
		Ferase(cArqTrb+OrdBagExt())

		#IFDEF TOP
	Endif
	#ENDIF			

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

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Program   ³ ImpSeqSC9³ Autor ³ Henry Fila            ³ Data ³02.07.1998³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³Controle de Fluxo do Relatorio por sequencia de entrega     ³±±
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

Static Function ImpSeqSC9(lEnd,wnrel,cString,nomeprog,Titulo)

	Local aStruQry  := {}
	Local aStruDAK  := {}  

	Local bWhileDAI := {||.T.}

	Local cbCont    := 0   // Numero de Registros Processados
	Local cbText    := ""  // Mensagem do Rodape
	Local cIndDAK   := ""
	Local cQuery    := "" 
	Local cCodDAK   := ""
	Local cSeqDAK   := ""
	Local cCliDAI   := ""
	Local cPedDAI   := ""
	Local cFilPv    := ""
	Local cQryAd    := ""
	Local cName     := ""
	Local cAliasDAK := "DAK"
	Local cAliasDAI := "DAI"
	Local cAliasSC9 := "SC9"
	Local cAliasSA1 := "SA1"          
	Local cAliasSB1 := "SB1"


	Local nIndDAK   := 0  
	Local nPeso     := 0
	Local nCapVol   := 0
	Local nTipoOper := OsVlEntCom()
	Local nX        := 0

	Local lFirst    := .T.
	Local lImp      := .F. // Indica se algo foi impresso
	Local lQuery    := .F.

	Local lRemito	 := DAI->(FieldPos("DAI_REMITO")) > 0 .And. DAI->(FieldPos("DAI_SERREM")) > 0
	Local cFilter	 := aReturn[7]
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



	//Local cCabec1 := OemtoAnsi(STR0004) //"SEQUENCIA PEDIDO CLIENTE   NOME                                    PESO         VOLUME     NOTA  SERIE"
	//Local cCabec2 := OemtoAnsi(STR0005) //"ENTREGA                                                                             M3   FISCAL"

	Local cCabec1 := "SEQUENCIA PEDIDO CLIENTE   NOME                                    PESO                    NOTA  SERIE"
	Local cCabec2 := "ENTREGA                                                                                  FISCAL"

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

		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³Se o relatorio for analitico inclui os campos do SC9                  ³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ

		If mv_par11 == 2

			//MsSeek("C9_QTDLIB")
			aadd(aStruQry,{"C9_QTDLIB",GetSX3Cache("C9_QTDLIB", "X3_TIPO"),TAMSX3("C9_QTDLIB")[1],TAMSX3("C9_QTDLIB")[2]})			

			//MsSeek("C9_PRCVEN")
			aadd(aStruQry,{"C9_PRCVEN",GetSX3Cache("C9_PRCVEN", "X3_TIPO"),TAMSX3("C9_PRCVEN")[1],TAMSX3("C9_PRCVEN")[2]})			

		Endif		

		cQuery := "SELECT "
		cQuery += "DAK_COD, DAK_SEQCAR, DAK_CAMINH, DAK_MOTORI, DAK_DATA, DAK_PESO, DAK_CAPVOL, DAK_PTOENT, "
		cQuery += "DAK_VALOR, DAK_HORA, DAI_COD, DAI_SEQCAR,DAI_SEQUEN, DAI_PEDIDO, DAI_CLIENT, DAI_LOJA, "
		cQuery += "DAI_PESO, DAI_CAPVOL, DAI_NFISCA,DAI_SERIE,A1_NREDUZ"


		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³Esta Rotina adiciona a cQuery os campos selecionados pelo usuario  |
		//³no filtro do usuario.                                              |
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ	   	

		aStruDAK := DAK->(dbStruct())	
		If !Empty(aReturn[7])
			For nX := 1 To DAK->(FCount())
				cName := DAK->(FieldName(nX))
				If AllTrim( cName ) $ aReturn[7]
					If aStruDAK[nX,2] <> "M"  
						If !cName $ cQuery .And. !cName $ cQryAd
							cQryAd += ","+cName
						Endif 	
					EndIf
				EndIf 			       	
			Next nX

			cQuery += cQryAd 	       

		Endif         

		If lRemito
			cQuery	+=	", DAI_REMITO, DAI_SERREM "
		Endif
		If nTipoOper == 2 .Or. nTipoOper == 3
			cQuery += ",DAI_FILPV "
		Endif

		If mv_par11 == 2
			cQuery += ",C9_FILIAL, C9_CLIENTE, C9_LOJA, C9_PEDIDO ,C9_ITEM, C9_PRODUTO, C9_QTDLIB, C9_PRCVEN, B1_COD, B1_DESC, B1_PESO, B1_PESBRU  "		
			If cPaisLoc <> "BRA"
				cQuery	+=	", C9_REMITO "
			Endif	
		Endif			

		cQuery += " FROM "+ RetSqlName("DAK")+ " DAK , "
		cQuery += RetSqlName("DAI")+ " DAI , "

		cQuery += RetSqlName("SA1")+ " SA1 "

		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³Se o relatorio for analitico inclui os arquivos do SC9                ³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		If mv_par11 == 2
			cQuery += ", "+RetSqlName("SB1")+ " SB1 , "		
			cQuery += RetSqlName("SC9")+ " SC9   "		
		Endif			

		cQuery += " WHERE DAK_FILIAL = '"+xFilial("DAK")+"' "                    
		cQuery += " AND DAK_COD >= '"+mv_par01+"' AND DAK_COD <='"+mv_par02+"' "
		cQuery += " AND DAK_SEQCAR >= '"+mv_par03+"' AND DAK_SEQCAR <='"+mv_par04+"' "
		cQuery += " AND DAK_CAMINH >= '"+mv_par05+"' AND DAK_CAMINH <='"+mv_par06+"' "
		cQuery += " AND DAK_MOTORI >= '"+mv_par07+"' AND DAK_MOTORI <='"+mv_par08+"' "                 
		cQuery += " AND DAK_DATA >= '"+Dtos(mv_par09)+"' AND DAK_DATA <='"+Dtos(mv_par10)+"' "
		cQuery += " AND DAK.D_E_L_E_T_ = ' '"

		cQuery += " AND DAI_FILIAL = '"+xFilial("DAI")+"' "                    
		cQuery += " AND DAI_COD = DAK_COD "		
		cQuery += " AND DAI_SEQCAR = DAK_SEQCAR "		
		cQuery += " AND DAI.D_E_L_E_T_ = ' '"		
		cQuery += " AND A1_FILIAL = "+Iif(nTipoOper == 1, "'"+xFilial("SA1")+"'", OsFilQry("SA1","DAI.DAI_FILPV") )
		cQuery += " AND A1_COD = DAI_CLIENT "
		cQuery += " AND A1_LOJA = DAI_LOJA "       
		cQuery += " AND SA1.D_E_L_E_T_ = ' ' "		    	

		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³Se o relatorio for analitico relaciona os arquivos do SC9             ³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		If mv_par11 == 2

			cQuery += " AND C9_FILIAL = "+Iif(nTipoOper == 1, "'"+xFilial("SC9")+"'", OsFilQry("SC9","DAI.DAI_FILPV") )

			cQuery += " AND C9_PEDIDO = DAI_PEDIDO "
			cQuery += " AND C9_CLIENTE = DAI_CLIENT "
			cQuery += " AND C9_LOJA = DAI_LOJA "      
			cQuery += " AND C9_CARGA = DAI_COD "
			cQuery += " AND C9_SEQCAR = DAI_SEQCAR "
			cQuery += " AND SC9.D_E_L_E_T_ = ' '"			
			cQuery += " AND B1_FILIAL = "+Iif(nTipoOper == 1,"'"+xFilial("SB1")+"'",OsFilQry("SB1","SC9.C9_FILIAL") )
			If cPaisLoc <> "BRA" .And. SC9->(FieldPos("C9_DOCGER")) > 0  .And. SC9->C9_DOCGER == "2"
				bIfSC9	:=	{|| (cAliasSC9)->C9_REMITO == (cAliasDAI)->DAI_REMITO }
			Else										
				bIfSC9	:=	{|| (cAliasSC9)->(C9_NFISCAL+C9_SERIENF) == (cAliasDAI)->(DAI_NFISCAL+DAI_SERIE) }
			Endif
			cQuery += " AND B1_COD = C9_PRODUTO "
			cQuery += " AND SB1.D_E_L_E_T_ = ' ' "		    	    	
		Endif

		cQuery += "ORDER BY DAK_COD,DAK_SEQCAR,DAI_SEQUEN,DAI_PEDIDO"+Iif(mv_par11 == 2,",C9_ITEM ","")

		cQuery := ChangeQuery(cQuery)

		dBUseArea(.t.,"TOPCONN",TCGENQRY(,,cQuery),"TRBCAR",.f.,.t.)


		For nX := 1 To Len(aStruQry)
			If ( aStruQry[nX][2] <> "C" )
				TcSetField("TRBCAR",aStruQry[nX][1],aStruQry[nX][2],aStruQry[nX][3],aStruQry[nX][4])
			EndIf
		Next nX

		cAliasDAK := "TRBCAR"
		cAliasDAI := "TRBCAR"
		cAliasSC9 := "TRBCAR"

		cAliasSA1 := "TRBCAR"
		cAliasSB1 := "TRBCAR"		
		lQuery    := .T.

	Else

		#ENDIF

		cKey := IndexKey()

		cCondicao := 'DAK_FILIAL == "'+xFilial("DAK")+'".And.' 
		cCondicao += 'DAK_COD >= "'+mv_par01+'".And.DAK_COD <="'+mv_par02+'".And.'
		cCondicao += 'DAK_SEQCAR >= "'+mv_par03+'".And.DAK_SEQCAR <="'+mv_par04+'".And.'
		cCondicao += 'DAK_CAMINH >= "'+mv_par05+'".And.DAK_CAMINH <="'+mv_par06+'".And.'    
		cCondicao += 'DAK_MOTORI >= "'+mv_par07+'".And.DAK_MOTORI <="'+mv_par08+'".And.'		
		cCondicao += 'Dtos(DAK_DATA) >= "'+Dtos(mv_par09)+'".And.Dtos(DAK_DATA) <="'+Dtos(mv_par10)+'"'


		IndRegua("DAK",cIndDAK,cKey,,cCondicao,"Selecionando Registros ...") //"Selecionando Registros ..."
		nIndDAK := RetIndex("DAK")

		dbSetIndex(cIndDAK+OrdBagExT())
		dbSetOrder(nIndDAK+1)

		cAliasDAK := "DAK"
		cAliasDAI := "DAI"
		cAliasSC9 := "SC9"

		cAliasSA1 := "SA1"
		cAliasSB1 := "SB1"

		#IFDEF TOP
	Endif
	#ENDIF			


	dbSelectArea(cAliasDAK)

	dbGotop()

	While !Eof() 

		If !Empty(cFilter) .And. !(&cFilter.)
			DbSkip()
			Loop	
		Endif
		lFirst := .T.

		#IFNDEF WINDOWS
		If LastKey() = 286
			lEnd := .T.
		EndIf
		#ENDIF
		If lEnd
			@ Prow()+1,001 PSAY STR0006 //"CANCELADO PELO OPERADOR"
			Exit
		EndIf

		If ( li > 60 )
			li := cabec(Titulo,cCabec1,cCabec2,nomeprog,Tamanho,CHRCOMP)
			li++
		Endif


		dbSelectArea("DA3")
		dbSetOrder(1)
		MsSeek(xFilial("DA3")+(cAliasDAK)->DAK_CAMINH)

		dbSelectArea("DA4")
		dbSetOrder(1)
		MsSeek(xFilial("DA4")+(cAliasDAK)->DAK_MOTORI)

		@ li,000 PSAY OemtoAnsi(STR0006)+(cAliasDAK)->DAK_COD+"-"+(cAliasDAK)->DAK_SEQCAR //"CARGA   : "
		li++
		@ li,000 PSAY OemtoAnsi(STR0007)+ (cAliasDAK)->DAK_CAMINH + " - " + DA3->DA3_DESC //"VEICULO : "
		@ li,055 PSAY OemtoAnsi(STR0008)+(cAliasDAK)->DAK_MOTORI + " - " + DA4->DA4_NOME //"MOTORISTA : "	
		li++
		@ li,000 PSAY OemtoAnsi(STR0009) //"PESO    :" 
		@ li,010 PSAY (cAliasDAK)->DAK_PESO Picture PesqPict("DAK","DAK_PESO")  
		//@ li,025 PSAY OemtoAnsi(STR0010) //"VOLUME M3 : "
		//@ li,037 PSAY (cAliasDAK)->DAK_CAPVOL Picture PesqPict("DAK","DAK_CAPVOL")  	
		@ li,052 PSAY OemtoAnsi(STR0011) //"PTOS ENTREGA : "
		@ li,067 PSAY (cAliasDAK)->DAK_PTOENT Picture PesqPict("DAK","DAK_PTOENT")  	
		@ li,076 PSAY OemtoAnsi(STR0012) //"VALOR : "                                        
		@ li,084 PSAY (cAliasDAK)->DAK_VALOR Picture PesqPict("DAK","DAK_VALOR")  		
		li++ 
		@ li,000 PSAY OemtoAnsi(STR0013) +DtoC((cAliasDAK)->DAK_DATA) + OemtoAnsi(STR0014) + (cAliasDAK)->DAK_HORA
		li++
		@ li,000 PSAY Replicate('-',limite)        
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

		While Eval(bWhileDAI)

			If ( li > 60 )
				li := cabec(Titulo,cCabec1,cCabec2,nomeprog,Tamanho,CHRCOMP)
				li++
			Endif

			If !lQuery

				cFilPv := Iif(nTipoOper == 1, xFilial("SA1"),(cAliasDAI)->DAI_FILPV)

				dbSelectArea(cAliasSA1)
				dbSetOrder(1)
				MsSeek(OsFilial("SA1",cFilPv)+(cAliasDAI)->DAI_CLIENT+(cAliasDAI)->DAI_LOJA)

			Endif				

			If mv_par11 == 1

				// Acrescentado li++

				li++								

				@ li,000 PSAY (cAliasDAI)->DAI_SEQUEN
				@ li,010 PSAY (cAliasDAI)->DAI_PEDIDO
				@ li,017 PSAY (cAliasDAI)->DAI_CLIENT+"-"+(cAliasDAI)->DAI_LOJA		 
				@ li,027 PSAY Substr((cAliasSA1)->A1_NREDUZ,1,30)
				@ li,059 PSAY (cAliasDAI)->DAI_PESO Picture PesqPict("DAI","DAI_PESO")
				//@ li,074 PSAY (cAliasDAI)->DAI_CAPVOL Picture PesqPict("DAI","DAI_CAPVOL")						
				If lRemito .And. !Empty((cAliasDAI)->DAI_REMITO )
					@ li,089 PSAY Alltrim(RetTitle("DAI_REMITO")) + STR0018
					@ li,109 PSAY (cAliasDAI)->DAI_REMITO 
					@ li,124 PSAY (cAliasDAI)->DAI_SERREM

				ElseIf !Empty((cAliasDAI)->DAI_NFISCA )

					@ li,089 PSAY OemToAnsi(STR0017)
					@ li,109 PSAY (cAliasDAI)->DAI_NFISCA 
					@ li,124 PSAY (cAliasDAI)->DAI_SERIE 

				Endif

				If lQuery
					dbSelectArea(cAliasDAI)
					dbSkip()
					Loop
				Endif			    	

			Else

				If !lFirst
					@ li,000 PSAY Replicate('-',limite)        
					lFirst := .F.	
				Endif			 

				li++
				@ li,000 PSAY (cAliasDAI)->DAI_SEQUEN
				@ li,010 PSAY (cAliasDAI)->DAI_PEDIDO
				@ li,017 PSAY (cAliasDAI)->DAI_CLIENT+"-"+(cAliasDAI)->DAI_LOJA		 
				@ li,027 PSAY Substr((cAliasSA1)->A1_NREDUZ,1,30)
				@ li,059 PSAY (cAliasDAI)->DAI_PESO Picture PesqPict("DAI","DAI_PESO")
				//@ li,074 PSAY (cAliasDAI)->DAI_CAPVOL Picture PesqPict("DAI","DAI_CAPVOL")						
				If lRemito .And. !Empty((cAliasDAI)->DAI_REMITO )
					@ li,089 PSAY Alltrim(RetTitle("DAI_REMITO")) + STR0018
					@ li,109 PSAY (cAliasDAI)->DAI_REMITO 
					@ li,124 PSAY (cAliasDAI)->DAI_SERREM
				ElseIf !Empty((cAliasDAI)->DAI_NFISCA )


					@ li,089 PSAY OemToAnsi(STR0017)
					@ li,109 PSAY (cAliasDAI)->DAI_NFISCA 
					@ li,124 PSAY (cAliasDAI)->DAI_SERIE 
				Endif

				li++				

				@ li,000 PSAY Replicate('-',limite)        
				li++				
				//@ li,000 PSAY OemtoAnsi(STR0015) //"ITEM PRODUTO         DESCRICAO                          QUANT.                VALOR            PESO              VOLUME"
				@ li,000 PSAY "ITEM PRODUTO         DESCRICAO                          QUANT.                VALOR            PESO"
				li++				
				@ li,000 PSAY Replicate('-',limite)        

				If lQuery

					cCarDAK := (cAliasDAK)->DAK_COD+(cAliasDAK)->DAK_SEQCAR
					cCliDAI := (cAliasDAI)->DAI_CLIENT + (cAliasDAI)->DAI_LOJA
					cPedDAI := (cAliasDAI)->DAI_PEDIDO

					bWhileSC9 := {|| (cAliasSC9)->(!Eof()) .And. (cAliasDAK)->DAK_COD+(cAliasDAK)->DAK_SEQCAR+(cAliasSC9)->C9_CLIENTE + (cAliasSC9)->C9_LOJA + (cAliasSC9)->C9_PEDIDO == ;
					cCarDAK+cCliDAI+cPedDAI }

				Else			

					cFilPv := Iif(nTipoOper == 1,xFilial("SC9"), (cAliasDAI)->DAI_FILPV )

					dbSelectArea(cAliasSC9)
					dbSetOrder(2)
					MsSeek(OsFilial("SC9",cFilPv)+(cAliasDAI)->DAI_CLIENT+(cAliasDAI)->DAI_LOJA+(cAliasDAI)->DAI_PEDIDO)

					bWhileSC9 := {|| !Eof() .And. (cAliasSC9)->C9_FILIAL+(cAliasSC9)->C9_CLIENTE+(cAliasSC9)->C9_LOJA+(cAliasSC9)->C9_PEDIDO == ;
					OsFilial("SC9",cFilPv)+(cAliasDAI)->DAI_CLIENT+(cAliasDAI)->DAI_LOJA+(cAliasDAI)->DAI_PEDIDO }

				Endif					
				bIfSC9	:=	{|| .T. }
				If cPaisLoc <> "BRA"
					If SC5->(FieldPos("C5_DOCGER")) > 0 
						cFilPv := Iif(nTipoOper == 1,xFilial("SC9"), (cAliasDAI)->DAI_FILPV )
						SC5->(DbSetOrder(1))
						SC5->(MsSeek(OsFilial('SC5',cFilPv)+(cAliasSC9)->C9_PEDIDO))
						If SC5->C5_DOCGER == "2"
							bIfSC9	:=	{|| (cAliasSC9)->C9_REMITO == (cAliasDAI)->DAI_REMITO }
						Else										
							bIfSC9	:=	{|| (cAliasSC9)->(C9_NFISCAL+C9_SERIENF) == (cAliasDAI)->(DAI_NFISCAL+DAI_SERIE) }
						Endif
					Endif		
				Endif

				While Eval(bWhileSC9)

					If Eval(bIfSC9)

						li++								

						If ( li > 60 )
							li := cabec(Titulo,cCabec1,cCabec2,nomeprog,Tamanho,CHRCOMP)
							li++
						Endif

						cFilPv := Iif(nTipoOper == 1, xFilial("SB1"), (cAliasSC9)->C9_FILIAL )

						If !lQuery                                                           

							dbSelectArea(cAliasSB1)
							dbSetOrder(1)
							MsSeek(OsFilial("SB1",(cAliasSC9)->C9_FILIAL)+(cAliasSC9)->C9_PRODUTO)

						Endif				   	

						nCapArm := OsPrCapArm((cAliasSB1)->B1_COD, cFilPv)

						_PesoCar := _GetParam()
						If _PesoCar == "L"
							nPeso    := ( (cAliasSB1)->B1_PESO   * (cAliasSC9)->C9_QTDLIB )
						Else                                                         
							nPeso    := ( (cAliasSB1)->B1_PESBRU * (cAliasSC9)->C9_QTDLIB )				
						Endif	                                 
						nCapVol  := ( nCapArm * (cAliasSC9)->C9_QTDLIB )

						@ li,000 PSAY (cAliasSC9)->C9_ITEM				    	
						@ li,005 PSAY (cAliasSC9)->C9_PRODUTO
						@ li,021 PSAY Substr((cAliasSB1)->B1_DESC,1,30)
						@ li,053 PSAY (cAliasSC9)->C9_QTDLIB Picture PesqPict("SC9","C9_QTDLIB")
						@ li,069 PSAY (cAliasSC9)->C9_QTDLIB*(cAliasSC9)->C9_PRCVEN Picture "@E 999,999,999.99"
						@ li,085 PSAY nPeso Picture "@E 999,999,999.99"				    	
						//@ li,105 PSAY nCapVol Picture "@E 999,999,999.99"				    					    	
					Endif													

					dbSelectArea(cAliasSC9)
					dbSkip()

				Enddo

				If mv_par12 == 1
					li := 80
				Endif				

			Endif					
			li++

			dbSelectArea(cAliasDAI)

			If !lQuery
				dbSkip()
			Endif			
		Enddo

		li := 80

		dbSelectArea(cAliasDAK)
		If !lQuery
			dbSkip()
		Endif			

	Enddo

	If ( lImp )
		Roda(cbCont,cbText,Tamanho)
	EndIf

	If lQuery
		dbSelectArea("TRBCAR")
		dbCloseArea()
	Endif	

	Set Device To Screen
	Set Printer To
	If ( aReturn[5] = 1 )
		dbCommitAll()
		OurSpool(wnrel)
	Endif
	MS_FLUSH()
Return(.T.)


/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Program   ³ ImpSeqSC9³ Autor ³ Henry Fila            ³ Data ³02.07.1998³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³Controle de Fluxo do Relatorio por sequencia de entrega     ³±±
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

Static Function ImpPrdSC9(lEnd,wnrel,cString,nomeprog,Titulo)

	Local aStruQry  := {}
	Local aStruDAK  := {}
	Local aStruSC9  := {}

	Local cbCont    := 0   // Numero de Registros Processados
	Local cbText    := ""  // Mensagem do Rodape
	Local cIndDAK   := ""
	Local cQuery    := "" 
	Local cCodDAK   := ""
	Local cSeqDAK   := ""
	Local cCliDAI   := ""
	Local cPedDAI   := ""
	Local cFilPv    := ""                                        
	Local cAliasDAK := "DAK"
	Local cAliasDAI := "DAI"
	Local cAliasSA1 := "SA1"
	Local cAliasSC9 := "SC9"
	Local cAliasSB1 := "SB1"
	Local cAliasDA3 := "DA3"
	Local cAliasDA4 := "DA4"
	Local cArqTRB   := ""

	Local nIndDAK   := 0  
	Local nPeso     := 0
	Local nCapVol   := 0
	Local nTipoOper := OsVlEntCom()
	Local nPosProd  := 0
	Local nX        := 0

	Local lFirst    := .T.
	Local lImp      := .F. // Indica se algo foi impresso
	Local lQuery    := .F.

	Local lRemito	 := DAI->(FieldPos("DAI_REMITO")) > 0 .And. DAI->(FieldPos("DAI_SERREM")) > 0
	Local cFilter	 := aReturn[7]
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

	Local cCabec1 := OemtoAnsi(STR0021)
	Local cCabec2 := ""

	dbSelectArea(cString)
	dbSetOrder(2)
	cIndDAK := CriaTrab(NIL,.F.)

	#IFDEF TOP	      

	If TcSrvType() != "AS/400"	

		aStruDAK := DAK->(dbStruct())
		aStruSC9 := SC9->(dbStruct())		

		cAliasQRY := "TRBQRY"

		cAliasDAK := cAliasQRY
		cAliasSA1 := cAliasQRY
		cAliassc9 := cAliasQRY
		cAliasSB1 := cAliasQRY

		cQuery := "SELECT C9_CARGA,C9_SEQCAR,DAK_MOTORI,DAK_CAMINH,DAK_DATA,DAK_CAPVOL,DAK_PTOENT,DAK_VALOR,DAK_PESO,"
		cQuery += "DAK_HORA,C9_PRODUTO,B1_DESC,B1_PESO,B1_PESBRU, SUM(C9_QTDLIB) QTDE, SUM(C9_QTDLIB*C9_PRCVEN) VALOR"
		cQuery += " FROM "              
		cQuery += RetSqlName("SC9") + " SC9, "

		cQuery += RetSqlName("SB1") + " SB1, "		
		cQuery += RetSqlName("SA1") + " SA1, "				
		cQuery += RetSqlName("DAK") + " DAK "		

		cQuery += " WHERE "		
		cQuery += "C9_FILIAL = '"+xFilial("SC9")+"' AND "
		cQuery += "C9_CARGA  >= '"+mv_par01+"' AND "		
		cQuery += "C9_CARGA  <= '"+mv_par02+"' AND "			
		cQuery += "C9_SEQCAR >= '"+mv_par03+"' AND "				
		cQuery += "C9_SEQCAR <= '"+mv_par04+"' AND "				
		cQuery += "SC9.D_E_L_E_T_ = ' ' AND "

		cQuery += "B1_FILIAL = '"+xFilial("SB1")+ "' AND "
		cQuery += "B1_COD = C9_PRODUTO AND "
		cQuery += "SB1.D_E_L_E_T_ = ' ' AND "

		cQuery += "A1_FILIAL = '"+xFilial("SA1")+ "' AND "
		cQuery += "A1_COD    = C9_CLIENTE AND "
		cQuery += "A1_LOJA   = C9_LOJA AND "
		cQuery += "SA1.D_E_L_E_T_ = ' ' AND 

		cQuery += "DAK_FILIAL = '"+xFilial("DAK")+"' AND "
		cQuery += "DAK_COD    = C9_CARGA AND "
		cQuery += "DAK_SEQCAR = C9_SEQCAR AND "
		cQuery += "DAK.D_E_L_E_T_ = ' ' "

		cQuery += "GROUP BY "
		cQuery += "C9_CARGA,C9_SEQCAR,DAK_MOTORI,DAK_CAMINH,DAK_DATA,DAK_CAPVOL,DAK_PTOENT,DAK_VALOR,DAK_PESO,"
		cQuery += "DAK_HORA,C9_PRODUTO,B1_DESC,B1_PESO,B1_PESBRU "

		cQuery += "ORDER BY C9_CARGA,C9_SEQCAR,C9_PRODUTO"

		cQuery := ChangeQuery(cQuery)
		dBUseArea(.t.,"TOPCONN",TCGENQRY(,,cQuery),cAliasQRY,.f.,.t.)

		For nX := 1 To Len(aStruDAK)
			If aStruDAK[nX][2]!="C"
				TcSetField(cAliasDAK,aStruDAK[nX][1],aStruDAK[nX][2],aStruDAK[nX][3],aStruDAK[nX][4])
			EndIf
		Next nX			

		For nX := 1 To Len(aStruSC9)
			If aStruSC9[nX][2]!="C"
				TcSetField(cAliasSC9,aStruSC9[nX][1],aStruSC9[nX][2],aStruSC9[nX][3],aStruSC9[nX][4])
			EndIf
		Next nX			

		While (cAliasQRY)->(!Eof())

			If lEnd
				@ Prow()+1,001 PSAY STR0006 //"CANCELADO PELO OPERADOR"
				Exit
			EndIf

			If ( li > 60 )
				li := cabec(Titulo,cCabec1,cCabec2,nomeprog,Tamanho,CHRCOMP)
				li++
			Endif


			dbSelectArea("DA3")
			dbSetOrder(1)
			MsSeek(xFilial("DA3")+(cAliasDAK)->DAK_CAMINH)

			dbSelectArea("DA4")
			dbSetOrder(1)
			MsSeek(xFilial("DA4")+(cAliasDAK)->DAK_MOTORI)

			cCarga := (cAliasQRY)->C9_CARGA+(cAliasQRY)->C9_SEQCAR

			@ li,000 PSAY OemtoAnsi(STR0006)+(cAliasQRY)->C9_CARGA+"-"+(cAliasQRY)->C9_SEQCAR //"CARGA   : "
			li++
			@ li,000 PSAY OemtoAnsi(STR0007)+(cAliasQRY)->DAK_CAMINH + " - " + DA3->DA3_DESC //"VEICULO : "
			@ li,055 PSAY OemtoAnsi(STR0008)+(cAliasQRY)->DAK_MOTORI + " - " + DA4->DA4_NOME //"MOTORISTA : "	
			li++
			@ li,000 PSAY OemtoAnsi(STR0009) //"PESO    :" 
			@ li,010 PSAY (cAliasQRY)->DAK_PESO Picture PesqPict("DAK","DAK_PESO")  
			//@ li,025 PSAY OemtoAnsi(STR0010) //"VOLUME M3 : "
			//@ li,037 PSAY (cAliasQRY)->DAK_CAPVOL Picture PesqPict("DAK","DAK_CAPVOL")  	
			@ li,052 PSAY OemtoAnsi(STR0011) //"PTOS ENTREGA : "
			@ li,067 PSAY (cAliasQRY)->DAK_PTOENT Picture PesqPict("DAK","DAK_PTOENT")  	
			@ li,076 PSAY OemtoAnsi(STR0012) //"VALOR : "                                        
			@ li,084 PSAY (cAliasQRY)->DAK_VALOR Picture PesqPict("DAK","DAK_VALOR")  		
			li++ 
			@ li,000 PSAY OemtoAnsi(STR0013) +DtoC((cAliasQRY)->DAK_DATA) + OemtoAnsi(STR0014) + (cAliasDAK)->DAK_HORA
			li++
			@ li,000 PSAY Replicate('-',limite)        
			li++

			While (cAliasQRY)->(!Eof()) .And. (cAliasQRY)->C9_CARGA+(cAliasQRY)->C9_SEQCAR == cCarga

				If lEnd
					@ Prow()+1,001 PSAY STR0006 //"CANCELADO PELO OPERADOR"
					Exit
				EndIf

				If ( li > 60 )
					li := cabec(Titulo,cCabec1,cCabec2,nomeprog,Tamanho,CHRCOMP)
					li++
				Endif

				nCapArm := OsPrCapArm((cAliasQRY)->C9_PRODUTO, cFilPv)

				_PesoCar := _GetParam()
				If _PesoCar == "L"
					nPeso    := ( (cAliasSB1)->B1_PESO   * (cAliasQRY)->QTDE )
				Else                                                         
					nPeso    := ( (cAliasSB1)->B1_PESBRU * (cAliasQRY)->QTDE )				
				Endif	                                 

				nCapVol  := ( nCapArm * (cAliasQRY)->QTDE )

				@ li,000 PSAY (cAliasQRY)->C9_PRODUTO
				@ li,018 PSAY substr((cAliasQRY)->B1_DESC,1,30)
				@ li,049 PSAY (cAliasQRY)->QTDE  Picture "@E 99,999,999.99"
				@ li,065 PSAY nPeso               Picture "@E 99,999.99"			
				//@ li,077 PSAY nCapVol             Picture "@E 99,999.99"			
				@ li,088 PSAY (cAliasQRY)->VALOR  Picture "@E 99,999,999.99"							

				li++			

				(cAliasQRY)->(dbSkip())

			Enddo

			li := 100

		Enddo

		dbSelectArea(cAliasQRY)
		dbCloseArea()

	Else

		#ENDIF

		Omr020Trb(@cArqTrb,aReturn[8])

		dbSelectArea("DAK")
		dbSetOrder(1)
		cKey := IndexKey()

		cCondicao := 'DAK_FILIAL == "'+xFilial("DAK")+'".And.' 
		cCondicao += 'DAK_COD >= "'+mv_par01+'".And.DAK_COD <="'+mv_par02+'".And.'
		cCondicao += 'DAK_SEQCAR >= "'+mv_par03+'".And.DAK_SEQCAR <="'+mv_par04+'".And.'
		cCondicao += 'DAK_CAMINH >= "'+mv_par05+'".And.DAK_CAMINH <="'+mv_par06+'".And.'    
		cCondicao += 'DAK_MOTORI >= "'+mv_par07+'".And.DAK_MOTORI <="'+mv_par08+'".And.'		
		cCondicao += 'Dtos(DAK_DATA) >= "'+Dtos(mv_par09)+'".And.Dtos(DAK_DATA) <="'+Dtos(mv_par10)+'"'

		IndRegua("DAK",cIndDAK,cKey,,cCondicao,"Selecionando Registros ...") //"Selecionando Registros ..."
		nIndDAK := RetIndex("DAK")

		dbSetIndex(cIndDAK+OrdBagExT())
		dbSetOrder(nIndDAK+1)

		cAliasDAK := "DAK"
		cAliasDAI := "DAI"
		cAliasSC9 := "SC9"
		cAliasSA1 := "SA1"
		cAliasSB1 := "SB1"

		While (cAliasDAK)->(!Eof() )

			If !Empty(cFilter) .And. !(&cFilter.)
				DbSkip()
				Loop	
			Endif

			//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
			//³Busca itens da carga                              ³
			//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
			DAI->(dbSetOrder(1))
			DAI->(MsSeek(xFilial("DAI")+DAK->DAK_COD+DAK->DAK_SEQCAR))

			While (cAliasDAI)->(!Eof()) .And. DAI->DAI_FILIAL == xFilial("DAI") .And.;
			DAI->DAI_COD    == DAK->DAK_COD .And. ;
			DAI->DAI_SEQCAR == DAK->DAK_SEQCAR		

				//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
				//³Busca pedidos da carga                            ³
				//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ

				cFilPv := Iif(nTipoOper == 1, xFilial("SC9"),(cAliasDAI)->DAI_FILPV)

				(cAliasSC9)->(dbSetOrder(1))
				(cAliasSC9)->(MsSeek(OsFilial("SC9",cFilPv)+(cAliasDAI)->DAI_PEDIDO))

				While (cAliasSC9)->(!Eof()) .And. (cAliasSC9)->C9_FILIAL == xFilial("SC9") .And. ;
				(cAliasSC9)->C9_PEDIDO == (cAliasDAI)->DAI_PEDIDO

					If (cAliasSC9)->C9_CARGA == (cAliasDAK)->DAK_COD .And. ;
					(cAliasSC9)->C9_SEQCAR == (cAliasDAK)->DAK_SEQCAR					

						//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
						//³Busca produtos para aglutinar conforme o relatório³
						//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ

						(cAliasSB1)->(dbSetOrder(1))	
						(cAliasSB1)->(MsSeek(xFilial("SB1")+(cAliasSC9)->C9_PRODUTO))

						nCapArm  := OsPrCapArm((cAliasSB1)->B1_COD, cFilPv)

						_PesoCar := _GetParam()
						If _PesoCar == "L"
							nPeso    := ( (cAliasSB1)->B1_PESO   * (cAliasSC9)->C9_QTDLIB )
						Else                                                         
							nPeso    := ( (cAliasSB1)->B1_PESBRU * (cAliasSC9)->C9_QTDLIB )				
						Endif	                                 

						nCapVol  := ( nCapArm   * (cAliasSC9)->C9_QTDLIB )

						dbSelectArea("TRBPRO")
						If !MsSeek((cAliasDAK)->DAK_COD+(cAliasDAK)->DAK_SEQCAR+(cAliasSC9)->C9_PRODUTO)

							RecLock("TRBPRO",.T.)
							TRBPRO->TRB_CODCAR := (cAliasDAK)->DAK_COD 	
							TRBPRO->TRB_SEQCAR := (cAliasDAK)->DAK_SEQCAR
							TRBPRO->TRB_MOTORI := (cAliasDAK)->DAK_MOTORI
							TRBPRO->TRB_VEICUL := (cAliasDAK)->DAK_CAMINH
							TRBPRO->TRB_DATA   := (cAliasDAK)->DAK_DATA
							TRBPRO->TRB_HORA   := (cAliasDAK)->DAK_HORA
							TRBPRO->TRB_PTOENT := (cAliasDAK)->DAK_PTOENT
							TRBPRO->TRB_PESTOT := (cAliasDAK)->DAK_PESO
							TRBPRO->TRB_VOLTOT := (cAliasDAK)->DAK_CAPVOL
							TRBPRO->TRB_VALTOT := (cAliasDAK)->DAK_VALOR
							TRBPRO->TRB_CODPRO := (cAliasSC9)->C9_PRODUTO
							TRBPRO->TRB_DESPRO := (cAliasSB1)->B1_DESC
							TRBPRO->TRB_CODCLI := (cAliasSC9)->C9_CLIENTE
							TRBPRO->TRB_LOJA   := (cAliasSC9)->C9_LOJA
						Else
							RecLock("TRBPRO",.F.)								
						Endif        					

						TRBPRO->TRB_QUANT  += (cAliasSC9)->C9_QTDLIB
						TRBPRO->TRB_PESO   += nPeso								
						TRBPRO->TRB_CAPVOL += nCapvol   
						TRBPRO->TRB_VALOR  += (cAliasSC9)->C9_QTDLIB * (cAliasSC9)->C9_PRCVEN

						MsUnlock()

					Endif		

					(cAliasSC9)->(dbSkip())

				Enddo

				(cAliasDAI)->(dbSkip())

			Enddo                       

			(cAliasDAK)->(dbSkip())			

		Enddo

		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³Impressao do relatorio                            ³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ

		//           1         2         3         4         5         6         7         8         9        10        11        12        13        14        15        16        17        18        19        20        21        22
		//"01234567890123456789012345678901234567890123456789012345678901234567890123456789012345678901234567890123456789012345678901234567890123456789012345678901234567890123456789012345678901234567890123456789012345678901234567890
		//"PRODUTO           DESCRICAO                         QUANTIDADE        PESO      VOLUME          VALOR    "
		//"XXXXXXXXXXXXXXXX  XXXXXXXXXXXXXXXXXXXXXXXXXXXXXX XX,XXX,XXX,XX   XX,XXX,XX   XX,XXX,XX  XX,XXX,XXX,XX


		dbSelectArea("TRBPRO")
		dbGotop()

		While !Eof()

			#IFNDEF WINDOWS
			If LastKey() = 286
				lEnd := .T.
			EndIf
			#ENDIF
			If lEnd
				@ Prow()+1,001 PSAY STR0006 //"CANCELADO PELO OPERADOR"
				Exit
			EndIf

			If ( li > 60 )
				li := cabec(Titulo,cCabec1,cCabec2,nomeprog,Tamanho,CHRCOMP)
				li++
			Endif

			cCarga := TRBPRO->TRB_CODCAR+TRBPRO->TRB_SEQCAR

			@ li,000 PSAY OemtoAnsi(STR0006)+TRBPRO->TRB_CODCAR+"-"+TRBPRO->TRB_SEQCAR //"CARGA   : "
			li++
			@ li,000 PSAY OemtoAnsi(STR0007)+TRBPRO->TRB_VEICUL + " - " + DA3->DA3_DESC //"VEICULO : "
			@ li,055 PSAY OemtoAnsi(STR0008)+TRBPRO->TRB_MOTORI + " - " + DA4->DA4_NOME //"MOTORISTA : "	
			li++
			@ li,000 PSAY OemtoAnsi(STR0009) //"PESO    :" 
			@ li,010 PSAY TRBPRO->TRB_PESTOT Picture PesqPict("DAK","DAK_PESO")  
			//@ li,025 PSAY OemtoAnsi(STR0010) //"VOLUME M3 : "
			//@ li,037 PSAY TRBPRO->TRB_VOLTOT Picture PesqPict("DAK","DAK_CAPVOL")  	
			@ li,052 PSAY OemtoAnsi(STR0011) //"PTOS ENTREGA : "
			@ li,067 PSAY TRBPRO->TRB_PTOENT Picture PesqPict("DAK","DAK_PTOENT")  	
			@ li,076 PSAY OemtoAnsi(STR0012) //"VALOR : "                                        
			@ li,084 PSAY TRBPRO->TRB_VALTOT Picture PesqPict("DAK","DAK_VALOR")  		
			li++ 
			@ li,000 PSAY OemtoAnsi(STR0013) +DtoC(TRBPRO->TRB_DATA) + OemtoAnsi(STR0014) + TRBPRO->TRB_HORA
			li++
			@ li,000 PSAY Replicate('-',limite)        
			li++

			While TRBPRO->(!Eof()) .And. TRBPRO->TRB_CODCAR+TRBPRO->TRB_SEQCAR == cCarga

				If lEnd
					@ Prow()+1,001 PSAY STR0006 //"CANCELADO PELO OPERADOR"
					Exit
				EndIf

				If ( li > 60 )
					li := cabec(Titulo,cCabec1,cCabec2,nomeprog,Tamanho,CHRCOMP)
					li++
				Endif

				@ li,000 PSAY TRBPRO->TRB_CODPRO
				@ li,018 PSAY TRBPRO->TRB_DESPRO
				@ li,049 PSAY TRBPRO->TRB_QUANT  Picture "@E 99,999,999.99"
				@ li,065 PSAY TRBPRO->TRB_PESO   Picture "@E 99,999.99"			
				//@ li,077 PSAY TRBPRO->TRB_CAPVOL Picture "@E 99,999.99"			
				@ li,088 PSAY TRBPRO->TRB_VALOR  Picture "@E 99,999,999.99"							
				li++			

				TRBPRO->(dbSkip())

			Enddo

		Enddo

		dbCloseArea("TRBPRO")
		Ferase(cArqTrb+GetDBExtension())
		Ferase(cArqTrb+OrdBagExt())

		#IFDEF TOP
	Endif
	#ENDIF			

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
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³OMR020Trb   ºAutor  ³Henry Fila          º Data ³  21/06/01 º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³ Cria arquivo temporario para emissao do relatorio          º±±
±±º          ³                                                            º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºParametros³ExpC1: Nome do arquivo que sera gerado por referencia       º±±
±±º          ³ExpN2: Ordem dos produtos a serem listados                  º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ AP5dl                                                      º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Static Function Omr020Trb(cArqTrb,nOrdem)

	Local aCampos := {}
	Local cAlias  := ""

	AADD(aCampos,{"TRB_CODCAR" ,"C",06,0}) 
	AADD(aCampos,{"TRB_SEQCAR" ,"C",02,0}) 
	AADD(aCampos,{"TRB_MOTORI" ,"C",06,0}) 
	AADD(aCampos,{"TRB_VEICUL" ,"C",08,0}) 
	AADD(aCampos,{"TRB_DATA"   ,"D",08,0}) 
	AADD(aCampos,{"TRB_HORA"   ,"C",05,0}) 
	AADD(aCampos,{"TRB_PTOENT" ,"N",06,0}) 
	AADD(aCampos,{"TRB_PESTOT" ,"N",12,2}) 
	AADD(aCampos,{"TRB_VOLTOT" ,"N",12,2}) 
	AADD(aCampos,{"TRB_VALTOT" ,"N",12,2}) 
	AADD(aCampos,{"TRB_CODPRO" ,"C",15,0}) 
	AADD(aCampos,{"TRB_DESPRO" ,"C",30,0}) 
	AADD(aCampos,{"TRB_CODCLI" ,"C",Len(SA1->A1_COD),0}) 
	AADD(aCampos,{"TRB_LOJA"   ,"C",Len(SA1->A1_LOJA),0}) 
	AADD(aCampos,{"TRB_QUANT"  ,"N",12,2}) 
	AADD(aCampos,{"TRB_PESO"   ,"N",12,2}) 
	AADD(aCampos,{"TRB_CAPVOL" ,"N",12,2}) 
	AADD(aCampos,{"TRB_VALOR"  ,"N",12,2}) 

	cAlias  := "TRBPRO"
	//cArqTRB := CriaTrab(aCampos,.T.)
	//dbUseArea(.T.,,cArqTRB,cAlias,.F.)
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³Mesmo em processadores velozes, a CriaTrab nunca provocar  erros:³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	//IndRegua("TRBPRO",cArqTrb,"TRB_CODCAR+TRB_SEQCAR+TRB_CODPRO+TRB_CODCLI+TRB_LOJA")

	_aArqTrb := {}
	If Select('TRBPRO')<>0                                  //Se um tmp com alias TMP existir, fecha-o
		TRBPRO->(dbCloseArea())
		u_arqtrb ("FechaTodos",,,, @_aArqTrb)
	Endif

	U_ArqTrb("Cria", "TRBPRO", aCampos, {"TRB_CODCAR","TRB_SEQCAR","TRB_CODPRO","TRB_CODCLI","TRB_LOJA"}, @_aArqTrb)

Return


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

	Local aHelpP13 := {}
	Local aHelpE13 := {}
	Local aHelpS13 := {}

	Aadd( aHelpP13, "Informe se o relatorio ira considerar os")
	Aadd( aHelpP13, "pedidos de venda ou as notas fiscais " )
	Aadd( aHelpP13, "ja geradas." )

	Aadd( aHelpE13, "Informe si el informe considerara los")
	Aadd( aHelpE13, "pedidos de venta o las facturas " )
	Aadd( aHelpE13, "ya generadas."  )

	Aadd( aHelpS13, "Inform whether the report will consider " )
	Aadd( aHelpS13, "the sales orders or invoices ")
	Aadd( aHelpS13, "already generated."  )

	PutSx1(cPerg,"13","Carga por?","¿Carga por ?","Carga por?","mv_chc","N",6,0,0,"C","","","","","mv_par19","Pedidos","Pedidos","Order","","Nota Fiscal","Nota Fiscal","Nota Fiscal","","","","","","","","","",aHelpP13,aHelpE13,aHelpS13)


Return


Static Function _GetParam()

	_cRet := Getmv("MV_PESOCAR")

Return(_cRet)
