#INCLUDE "rwmake.ch"
#INCLUDE "topconn.ch"
#INCLUDE "protheus.ch"

User Function om_mpcar()

	/*/
	ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
	±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
	±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
	±±³Programa  ³ OM_MPCAR ³ Autor ³ Eleandro Casagrande   ³ Data ³ Ago/2004 ³±±
	±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
	±±³Descricao ³ Mapa de Carga na sequencia de entrega                      ³±±
	±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
	±±³Retorno   ³                                                            ³±±
	±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
	±±³Utilizacao³ Especifico Clientes Microsiga                              ³±±
	±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
	±±³   Data   ³ Programador   ³Manutencao Efetuada                         ³±±
	±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
	±±³          ³               ³                                            ³±±
	±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
	±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
	ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
	/*/

	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Variaveis utilizadas para parametros                         ³
	//³ mv_par01     // Carga  de                                    ³
	//³ mv_par02     // Carga ate                                    ³
	//³ mv_par03     // Sequencia de                                 ³
	//³ mv_par04     // Sequencia ate                                ³
	//³ mv_par05     // Veiculo de                                   ³
	//³ mv_par06     // Veiculo ate                                  ³
	//³ mv_par07     // Motorista de                                 ³
	//³ mv_par08     // Motorista ate                                ³
	//³ mv_par09     // Data de                                      ³
	//³ mv_par11     // Representante                                ³
	//³ mv_par12     // Recebimento                                  ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Variaveis obrigatorias dos programas de relatorio            ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	cString :="DAK"
	cDesc1  :="Este programa tem como objetivo, imprimir relatorio de"
	cDesc2  :="Mapa de Carga "
	cDesc3  :=""
	tamanho :="M"
	aReturn :={ "Zebrado", 1,"Administracao", 2, 2, 1, "",1 }
	aLinha  :={ }
	nLastKey:=0
	cPerg   := "OMPCAR"
	titulo := "Mapa de Entrega"
	wnrel   :="OMPCAR"
	nTipo   :=0


	aStruQry  := {}
	aDevol    := {}              
	aFormas   := {}
	cbCont    := 0   // Numero de Registros Processados
	cbText    := ""  // Mensagem do Rodape
	cCpoPeso  := Iif(Getmv("MV_PESOCAR") == "L","SB1->B1_PESO","SB1->B1_PESBRU")
	cIndDAK   := ""
	cQuery    := "" 
	cCodDAK   := ""
	cSeqDAK   := ""
	cCliDAI   := ""
	cPedDAI   := ""
	cAliasDAK := ""
	cAliasDAI := ""
	cAliasSA1 := ""
	cAliasSD2 := "SD2"
	cAliasSF2 := "SF2"
	nIndDAK   := 0  
	nPeso     := 0
	nCapVol   := 0
	nTipoOper := OsVlEntCom()
	nRegSD2   := 0                                 
	nTotForma := 0
	nTotal    := 0
	nX        := 0
	nY        := 0
	aRem      := 0
	nTotRem   := 0
	lFirst    := .T.
	lImp      := .F. // Indica se algo foi impresso
	lQuery    := .F.
	lSkip     := .F.
	_cBDJ300g  := alltrim(GETMV('SI_BDJ300G'))
	_cBDJ320g  := alltrim(GETMV('SI_BDJ320G'))
	_cBDJ360g  := alltrim(GETMV('SI_BDJ360G'))
	_cBDJ400g  := alltrim(GETMV('SI_BDJ400G'))
	_cBDJ450g  := alltrim(GETMV('SI_BDJ450G'))
	_cBDJ480g  := alltrim(GETMV('SI_BDJ480G'))
	_cBDJ500g  := alltrim(GETMV('SI_BDJ500G'))
	_cBDJ502g  := alltrim(GETMV('SI_BDJ502G'))
	_cBDJ503g  := alltrim(GETMV('SI_BDJ503G'))
	_cBDJ600g  := alltrim(GETMV('SI_BDJ600G'))
	_cBDJ720g  := alltrim(GETMV('SI_BDJ720G'))
	_cBDJ800g  := alltrim(GETMV('SI_BDJ800G'))
	_cBDJ802g  := alltrim(GETMV('SI_BDJ8002'))
	_cBDJ900g  := alltrim(GETMV('SI_BDJ900G'))	

	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Pergunta no SX1                                              ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	Pergunte(cPerg,.F.)

	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Envia controle para a funcao SETPRINT                        ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	wnrel:=SetPrint(cString,wnrel,cPerg,titulo,cDesc1,cDesc2,cDesc3,.F.)

	If nLastKey == 27
		Return
	Endif
	SetDefault(aReturn,cString)
	If nLastKey == 27
		Return
	Endif

	RptStatus({|| RptDetail()})
Return

Static Function RptDetail()
	Local nx
	Local nSomaST := 0

	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Inicializa  regua de impressao                            ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	SetRegua(LastRec())

	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Inicializa os codigos de caracter Comprimido/Normal da impressora ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	nTipo := IIF(aReturn[4]==1,15,18)
	li    := 80
	m_pag := 1

	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Cria o cabecalho.                                        ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	cabec1 := "*SEQ ENT  NFISCAL  SERIE  PEDIDO  CLIENTE    NOME DO CLIENTE                       MUNICIPIO              UF       CONDICAO       *"   
	cabec2 := "*PRODUTO  DESCRICAO                                                                QUANT        QUANT 2a.UM   UM 2a.              *"  
	//***       XXXXXX   XXXXXXX  XXXXX  XXXXXX  XXXXXX-XX  XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX  XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX  XXX-XXXXXX
	//***                1         2         3         4         5         6         7         8         9         0         1         2         3
	//***       0123456789012345678901234567890123456789012345678901234567890123456789012345678901234567890123456789012345678901234567890123456789012

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
		aadd(aStruQry,{"DAK_PTOENT",GetSX3Cache("DAK_PTOENT", "X3_TIPO"),TAMSX3("DAK_PTOENT")[1],TAMSX3("DAK_PTOENT")[2]})			

		//MsSeek("DAK_VALOR")
		aadd(aStruQry,{"DAK_VALOR",GetSX3Cache("DAK_VALOR", "X3_TIPO"),TAMSX3("DAK_VALOR")[1],TAMSX3("DAK_VALOR")[2]})			

		//MsSeek("DAI_PESO")
		aadd(aStruQry,{"DAI_PESO",GetSX3Cache("DAI_PESO", "X3_TIPO"),TAMSX3("DAI_PESO")[1],TAMSX3("DAI_PESO")[2]})			

		//MsSeek("DAI_CAPVOL")
		aadd(aStruQry,{"DAI_CAPVOL",GetSX3Cache("DAI_CAPVOL", "X3_TIPO"),TAMSX3("DAI_CAPVOL")[1],TAMSX3("DAI_CAPVOL")[2]})			

		cQuery := "SELECT DAK_COD, DAK_SEQCAR, DAI_SEQUEN, DAI_PEDIDO,C5_NUM,DAK_CAMINH,DAK_MOTORI,DAK_DATA,"
		cQuery += "DAK_PESO,DAK_CAPVOL,DAK_PTOENT,DAK_VALOR,DAK_HORA,DAI_COD, DAI_SEQCAR,DAI_SEQUEN, DAI_PEDIDO,"
		cQuery += " DAI_CLIENT, DAI_LOJA, DAI_PESO, DAI_CAPVOL, DAI_NFISCA,DAI_SERIE,C5_MARCA ,A1_FILIAL, A1_COD,A1_LOJA,"
		cQuery += "A1_NREDUZ, A1_END, A1_MUN,A1_FORMREC,A1_EST"
		
		If nTipoOper == 2 .Or. nTipoOper == 3
			cQuery += ",DAI_FILPV "
		Endif			

		cQuery += " FROM "+ RetSqlName("DAK")+ " DAK "

		cQuery += " INNER JOIN"  + RetSqlTab("DAI") + " ON ( DAK_COD = DAI_COD AND DAK_SEQCAR = DAI_SEQCAR )"
		cQuery += " INNER JOIN"  + RetSqlTab("SC5") + " ON ( DAI_PEDIDO = C5_NUM )"
		cQuery += " INNER JOIN"  + RetSqlTab("SA1") + " ON ( DAI_CLIENT = A1_COD AND DAI_LOJA = A1_LOJA )"

		if !empty(mv_par11)
			cQuery += ","+RetSqlName("SA3")+ " SA3 " 
		endif		

		if !empty(mv_par12)
			cQuery += ","+RetSqlName("SE4")+ " SE4" 
		endif		

		cQuery += " WHERE DAK_FILIAL = '"+xFilial("DAK")+"' "                    
		cQuery += " AND DAK_COD >= '"+mv_par01+"' AND DAK_COD <='"+mv_par02+"' "
		cQuery += " AND DAK_SEQCAR >= '"+mv_par03+"' AND DAK_SEQCAR <='"+mv_par04+"' "
		cQuery += " AND DAK_CAMINH >= '"+mv_par05+"' AND DAK_CAMINH <='"+mv_par06+"' "
		cQuery += " AND DAK_MOTORI >= '"+mv_par07+"' AND DAK_MOTORI <='"+mv_par08+"' "                 
		cQuery += " AND DAK_DATA >= '"+Dtos(mv_par09)+"' AND DAK_DATA <='"+Dtos(mv_par10)+"' "
		if !empty(mv_par14) .OR. !empty(mv_par15)
			cQuery += " AND C5_MARCA >= '"+alltrim(mv_par14)+"' AND C5_MARCA <='"+alltrim(mv_par15)+"' "                 
		endif
		cQuery += " AND DAK_FEZNF = '1'"
		cQuery += " AND DAK.D_E_L_E_T_ = ' '"

		cQuery += " AND DAI_FILIAL = '"+xFilial("DAI")+"' "
		cQuery += " AND DAI.D_E_L_E_T_ = ' '"		

		cQuery += " AND A1_FILIAL = "+Iif(nTipoOper == 1,"'"+xFilial("SA1")+"'", OsFilQry("SA1","DAI.DAI_FILPV") )		
		cQuery += " AND SA1.D_E_L_E_T_ = ' '"   

		if mv_par13 < 3
			if mv_par13 = 1//FILTRA CARTAO DE CREDITO
				cQuery += " AND A1_FORMREC='5'"
			elseif mv_par13 = 2//FILTRA LINK
				cQuery += " AND A1_FORMREC='6'"
			endif
		endif

		if !empty(mv_par11)
			cQuery += " AND A3_COD = A1_VEND AND A3_FILIAL = '" + xfilial('SA3') + "' AND SA3.D_E_L_E_T_ <> '*' "
			cQuery += " AND A3_COD = '" + alltrim(mv_par11) + "'"  	
		endif
		
		if !empty(mv_par12)
			cQuery += " AND A3_COD = E4_FORMA AND E4_FILIAL = '" + xfilial('SA3') + "' AND SA3.D_E_L_E_T_ <> '*' "
			cQuery += " AND A3_COD = '" + alltrim(mv_par12) + "'"  	
		endif

		//cQuery += "ORDER BY DAK_COD,DAK_SEQCAR,DAI_SEQUEN,DAI_PEDIDO"
		cQuery += " ORDER BY  DAK_COD,DAK_SEQCAR,C5_MARCA"
		cQuery := ChangeQuery(cQuery)
		//	* Mostrar a consulta */
		//@ 116,090 To 416,707 Dialog oDlgMemo Title "Consulta"
		//@ 055,005 Get cQuery Size 250,080 MEMO Object oMemo
		//Activate Dialog oDlgMemo

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
	endif		

	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Verifica Dados                                               ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ

	dbSelectArea(cAliasDAK)

	dbGotop()

	Do While !Eof() 

		lFirst := .T.    
		lSkip := .F. 

		If LastKey() = 286
			lEnd := .T.
		EndIf

		If lEnd
			@ Prow()+1,001 PSAY "CANCELADO PELO OPERADOR"
			Exit
		EndIf

		IncRegua()              // Termometro de Impressao

		//*--------------------------------------------- INICIO IMPRESSAO

		If li > 75
			cabec(titulo,cabec1,cabec2,wnrel,tamanho,nTipo)
		Endif

		If !empty(mv_par11)
			_cVend := fBuscaCPO('SA3',1,xfilial('SA3')+mv_par11,'A3_NOME')
			@ li,000 PSAY "REPRESENTANTE: (" + mv_par11 + ") " + _cVend
			li++ 
		endIf
		
		If !empty(mv_par12)
			dbSelectArea("SE4")
			_cRec := fBuscaCPO('SE4',1,xfilial('SE4')+mv_par12,'E4_FORMA')
			@ li,000 PSAY "RECEBIMENTO: (" + mv_par12 + ") " + _cRec
			li++ 
		endIf

		dbSelectArea("DA3")
		dbSetOrder(1)
		MsSeek(xFilial("DA3")+(cAliasDAK)->DAK_CAMINH)

		dbSelectArea("DA4")
		dbSetOrder(1)
		MsSeek(xFilial("DA4")+(cAliasDAK)->DAK_MOTORI)

		@ li,000 PSAY "CARGA   : " + (cAliasDAK)->DAK_COD+"-"+(cAliasDAK)->DAK_SEQCAR 
		li++
		@ li,000 PSAY "VEICULO : " + (cAliasDAK)->DAK_CAMINH + " - " + AllTrim(DA3->DA3_DESC) + "  (" + AllTrim(DA3->DA3_PLACA) + ")"
		@ li,065 PSAY "MOTORISTA : " +(cAliasDAK)->DAK_MOTORI + " - " + DA4->DA4_NOME 
		li++
		@ li,000 PSAY "PESO    :"  
		@ li,010 PSAY (cAliasDAK)->DAK_PESO Picture PesqPict("DAK","DAK_PESO")  		 	
		@ li,062 PSAY "PTOS ENTREGA : " 
		@ li,077 PSAY (cAliasDAK)->DAK_PTOENT Picture PesqPict("DAK","DAK_PTOENT")  					
		li++ 
		@ li,000 PSAY "DATA    :" +DtoC((cAliasDAK)->DAK_DATA) + " as " + (cAliasDAK)->DAK_HORA 
		li++
		@ li,000 PSAY Replicate('-', 132)
		li++

		cCodDAK   := (cAliasDAK)->DAK_COD
		cSeqDAK   := (cAliasDAK)->DAK_SEQCAR			
		bWhileDAI :=  {|| (cAliasDAI)->(!Eof()) .And. (cAliasDAI)->DAI_COD+(cAliasDAI)->DAI_SEQCAR == cCodDAK+cSeqDAK }	

		_xVez:=1
		_nTotQtd :=0
		_nTotQtd2:=0 
		_nTotValo:=0
		_nSubQuan:=_nSubValo:=_nSubQtd2:=0
		
		While Eval(bWhileDAI)

			If li > 75
				cabec(titulo,cabec1,cabec2,wnrel,tamanho,nTipo)
				li++
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

							If li > 75
								cabec(titulo,cabec1,cabec2,wnrel,tamanho,nTipo)
								li++
							Endif

							SE4->(dbSetOrder(1))
							SE4->(MsSeek(xFilial("SE4")+(cAliasSF2)->F2_COND))

							if _xVez==1
								_xVez:=2
							else   
								li++
							endif

							@ li,000 PSAY (cAliasDAI)->DAI_SEQUEN

							If cPaisLoc <> "BRA" 
								If IsRemito(1,cAliasSF2+"->F2_TIPODOC")
									@li,007 PSAY "(2)"
								Else
									@li,007 PSAY "(1)"
								Endif
							Endif

							@ li,010 PSAY (cAliasSF2)->F2_DOC
							@ li,023 PSAY (cAliasSF2)->F2_SERIE
							@ li,026 PSAY (cAliasDAI)->DAI_PEDIDO
							@ li,033 PSAY (cAliasDAI)->DAI_CLIENT+"-"+(cAliasDAI)->DAI_LOJA		 							
							@ li,046 PSAY Substr((cAliasSA1)->A1_NREDUZ,1,35)							
							@ li,069 PSAY Substr((cAliasSA1)->C5_MARCA,1,40)
							@ li,083 PSAY Substr((cAliasSA1)->A1_MUN,1,20)
							@ li,106 PSAY (cAliasSA1)->A1_EST			
														@ li,115 PSAY (cAliasSF2)->F2_COND+"-"+trim(SE4->E4_DESCRI)+"-"+;
																	IIF( (cAliasSA1)->A1_FORMREC=="1", "(R$)",;
																	iif( (cAliasSA1)->A1_FORMREC=="2", "(CH)" ,; 
																	iif( (cAliasSA1)->A1_FORMREC=="3", "(BL)" ,;
																	iif( (cAliasSA1)->A1_FORMREC=="4", "(DP)" ,;
																	iif( (cAliasSA1)->A1_FORMREC=="5", "(CC)" ,"(LK)"))))) 
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

									If li > 75
										cabec(titulo,cabec1,cabec2,wnrel,tamanho,nTipo)
										li++
									Endif           

									@ li,000 PSAY alltrim((cAliasSD2)->D2_COD)
									@ li,010 PSAY SUBSTR(SB1->B1_DESC,1,45)
									//@ li,081 PSAY (cAliasSD2)->D2_QUANT Picture   "9,999.99"   //PesqPict("SD2","D2_QUANT")									
									/*
									If !alltrim((cAliasSD2)->D2_COD) $ _cBDJ300+_cBDJ320+_cBDJ360+_cBDJ400+_cBDJ450+_cBDJ480+_cBDJ500+_cBDJ502+_cBDJ503+_cBDJ600+_cBDJ720+_cBDJ800+_cBDJ802+_cBDJ900
										@ li,081 PSAY (cAliasSD2)->D2_QUANT Picture   "9,999.99"   //PesqPict("SD2","D2_QUANT")
									else
										cPB := AllTrim(STR(GetAdvFval('SF2','F2_PBRUTO',FWxFilial('SF2') + (cAliasSF2)->F2_DOC,1)))
										@ li,081 PSAY cPB Picture "9,999.99" + "Kg"
									endif*/
									_nTaraS   := GetAdvFVal('SB1','B1_CTARASE',FWxfilial('SB1')+(cAliasSD2)->D2_COD,1)     //Linhas inseridas para buscar
									_nTS      := GetAdvFVal('ZAB','ZAB_TARA',FWxfilial('ZAB')+alltrim(_nTaraS),1)  // os campos de codigo das taras secundaria
									_nTaraP   := GetAdvFVal('SB1','B1_CTARAP',FWxfilial('SB1')+(cAliasSD2)->D2_COD,1)      // Linhas inseridas para buscar"_NTARAp"
									_nTP      := GetAdvFVal('ZAB','ZAB_TARA',FWxfilial('ZAB')+alltrim(_nTaraP),1)  // os campos de codigo das taras primarias
									_nQCaix   := GetAdvFVal('SB1','B1_QCAIX',FWxfilial('SB1')+(cAliasSD2)->D2_COD,1)
									If alltrim((cAliasSD2)->D2_COD) $ _cBdj300g
										@ li,081 PSAY ((cAliasSD2)->D2_QUANT * 0.3) + ((cAliasSD2)->D2_QTSEGUM * _nTS)	+ ((cAliasSD2)->D2_QUANT * _nTP) Picture "9,999.99" + " Kg"
										//bandeja 320g
									ElseIf alltrim((cAliasSD2)->D2_COD) $ _cBdj320g
										@ li,081 PSAY ((cAliasSD2)->D2_QUANT * 0.32) + ((cAliasSD2)->D2_QTSEGUM * _nTS)	+ ((cAliasSD2)->D2_QUANT * _nTP) Picture "9,999.99" + " Kg"
									//bandeja 360g
									ElseIf alltrim((cAliasSD2)->D2_COD) $ _cBdj360g
										@ li,081 PSAY ((cAliasSD2)->D2_QUANT * 0.36) + ((cAliasSD2)->D2_QTSEGUM * _nTS)	+ ((cAliasSD2)->D2_QUANT * _nTP) Picture "9,999.99" + " Kg"
									//bandeja 400g
									ElseIf alltrim((cAliasSD2)->D2_COD) $ _cBdj400g
										@ li,081 PSAY ((cAliasSD2)->D2_QUANT * 0.4) + ((cAliasSD2)->D2_QTSEGUM * _nTS)	+ ((cAliasSD2)->D2_QUANT * _nTP) Picture "9,999.99" + " Kg"
									//bandeja 450g
									ElseIf alltrim((cAliasSD2)->D2_COD) $ _cBdj450g
										@ li,081 PSAY ((cAliasSD2)->D2_QUANT * 0.45) + ((cAliasSD2)->D2_QTSEGUM * _nTS)	+ ((cAliasSD2)->D2_QUANT * _nTP) Picture "9,999.99" + " Kg"
									//bandeja 480g
									ElseIf alltrim((cAliasSD2)->D2_COD) $ _cBdj480g
										@ li,081 PSAY ((cAliasSD2)->D2_QUANT * 0.48) + ((cAliasSD2)->D2_QTSEGUM * _nTS)	+ ((cAliasSD2)->D2_QUANT * _nTP) Picture "9,999.99" + " Kg"
									//bandeja 500g
									ElseIf alltrim((cAliasSD2)->D2_COD) $ _cBdj500g .or. alltrim((cAliasSD2)->D2_COD) $ _cBDJ502g .or. alltrim((cAliasSD2)->D2_COD) $ _cBdj503g
										@ li,081 PSAY ((cAliasSD2)->D2_QUANT * 0.5) + ((cAliasSD2)->D2_QTSEGUM * _nTS)	+ ((cAliasSD2)->D2_QUANT * _nTP) Picture "9,999.99" + " Kg"
									//bandeja 600g
									ElseIf alltrim((cAliasSD2)->D2_COD) $ _cBdj600g
										@ li,081 PSAY ((cAliasSD2)->D2_QUANT * 0.6) + ((cAliasSD2)->D2_QTSEGUM * _nTS)	+ ((cAliasSD2)->D2_QUANT * _nTP) Picture "9,999.99" + " Kg"
									//bandeja 720g
									ElseIf alltrim((cAliasSD2)->D2_COD) $ _cBdj720g
										@ li,081 PSAY ((cAliasSD2)->D2_QUANT * 0.72) + ((cAliasSD2)->D2_QTSEGUM * _nTS)	+ ((cAliasSD2)->D2_QUANT * _nTP) Picture "9,999.99" + " Kg"
									//bandeja 800g
									ElseIf alltrim((cAliasSD2)->D2_COD) $ _cBdj800g	.or. alltrim((cAliasSD2)->D2_COD) $ _cBDJ802g
										@ li,081 PSAY ((cAliasSD2)->D2_QUANT * 0.8) + ((cAliasSD2)->D2_QTSEGUM * _nTS)	+ ((cAliasSD2)->D2_QUANT * _nTP) Picture "9,999.99" + " Kg"
									//bandeja 900g
									@ li,081 PSAY ((cAliasSD2)->D2_QUANT * 0.9) + ((cAliasSD2)->D2_QTSEGUM * _nTS)	+ ((cAliasSD2)->D2_QUANT * _nTP) Picture "9,999.99" + " Kg"									
									Else
										@ li,081 PSAY (cAliasSD2)->D2_QUANT Picture   "9,999.99"
									EndIf

									@ li, 093 PSAY (cAliasSD2)->D2_QTSEGUM   Picture "9,999.99"
									@ li, 111 PSAY (cAliasSD2)->D2_SEGUM

									li++                

								Endif	

								_nTotQtd := _nTotQtd  + (cAliasSD2)->D2_QUANT 
								_nTotQtd2:= _nTotQtd2 + (cAliasSD2)->D2_QTSEGUM
								_nTotValo:= _nTotValo + (cAliasSD2)->D2_TOTAL+(cAliasSD2)->D2_VALIPI+(cAliasSD2)->D2_ICMSRET

								_nSubQuan := _nSubQuan + (cAliasSD2)->D2_QUANT
								_nSubValo := _nSubValo + (cAliasSD2)->D2_TOTAL+(cAliasSD2)->D2_VALIPI+(cAliasSD2)->D2_ICMSRET
								_nSubQtd2 := _nSubQtd2 + (cAliasSD2)->D2_QTSEGUM
								(cAliasSD2)->(dbSkip())						                                    

							Enddo						                                    

							If li > 75
								cabec(titulo,cabec1,cabec2,wnrel,tamanho,nTipo)
								li++
							Endif
							
							@ li, 010 PSAY "** Sub-total ==> "
							@ li, 075 PSAY GetAdvFval('SF2','F2_PBRUTO',FWxFilial('SF2') + (cAliasSF2)->F2_DOC,1)  picture "@E 999,999,999.99" +" Kg"  		//@ li, 080 PSAY _nSubQuan  picture "99,999.99"  							
							@ li, 092 PSAY _nSubQtd2  picture "99,999.99" 
							li++
							@ li, 000 PSAY Replicate("-",132)

							nSomaST  := nSomaST + GetAdvFval('SF2','F2_PBRUTO',FWxFilial('SF2') + (cAliasSF2)->F2_DOC,1)

							_nSubQuan:=_nSubValo:=_nSubQtd2:=0

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

		li++
		@ li, 010 PSAY "** T o t a l  ==> "
		@ li, 080 PSAY nSomaST /*_nTotQtd*/  picture "99,999.99"  + " Kg"
		@ li, 093 PSAY _nTotValo  picture "99,999.99"
		@ li, 107 PSAY _nTotQtd2 picture "99,999.99" 

		li   := 80                    
		lImp := .T.

		If !lQuery .Or. !lSkip	
			dbSelectArea(cAliasDAK)
			dbSkip()
		EndIf

	Enddo

	If lQuery
		dbSelectArea("TRBCAR")
		dbCloseArea()
	Else	     
		dbSelectArea("DAK")
		Ferase(cIndDAK+OrdBagExt())
		RetIndex("DAK")
	Endif

	Set Device To Screen

	If aReturn[5]==1
		Set Printer TO
		dbcommitAll()
		ourspool(wnrel)
	Endif

	MS_FLUSH() // Libera fila de relatorios em spool (Tipo Rede Netware)

Return
