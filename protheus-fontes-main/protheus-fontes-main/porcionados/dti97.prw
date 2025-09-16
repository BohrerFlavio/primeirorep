#INCLUDE "rwmake.ch"
#INCLUDE "topconn.ch"

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณDTI97   บ Autor ณ Flแvio Bohrer    		20/03/20          บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDescricao ณ Relat๓rio de conferencia do Processamento de Bandejas      บฑฑ
ฑฑบ          ณ                                                            บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ Porcionados   		                                      บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
/*/



User Function  DTI97()
	
	Local cDesc1         := "Este programa tem como objetivo imprimir relatorio"
	Local cDesc2         := "de Sobra de bandejas lan็adas "
	Local cDesc3         := ""
	Local cPict          := ""
	Local titulo         := "RELATORIO CONTROLE DE BANDEJAS PRODUZIDAS"
	Local Cabec1         := "     Num.Lote        Cod.    Desc.                        Qtd.Bdejas   Dt.Produ็ใo      "
	Local Cabec2         := ""
	Local imprime        := .T.
	Local aOrd           := {}
	Local nS
	Private nLin         := 80
	Private lEnd         := .F.
	Private lAbortPrint  := .F.
	Private CbTxt        := ""
	Private limite       := 80
	Private tamanho      := "P"
	Private nomeprog     := "RDTI97" // Coloque aqui o nome do programa para impressao no cabecalho
	Private nTipo        := 18
	Private aReturn      := { "Zebrado", 1, "Administracao", 2, 2, 1, "", 1}
	Private nLastKey     := 0
	Private cPerg   	 := "RDTI97"
	Private cbtxt      	 := Space(10)
	Private cbcont       := 00
	Private CONTFL       := 01
	Private m_pag      	 := 01		
	Private wnrel        := "RDTI97" // Coloque aqui o nome do arquivo usado para impressao em disco
	
	pergunte(cPerg,.F.)

	wnrel := SetPrint('ZDA',NomeProg,cPerg,@titulo,cDesc1,cDesc2,cDesc3,.T.,aOrd,.T.,Tamanho,,.T.)
	
	MsgRun("Aguarde... Realizando contagem de registros...",,{||  GeraQ(dtos(mv_par01),dtos(mv_par02)) })

	If nLastKey == 27
		Return
	Endif

	SetDefault(aReturn,'ZDA')

	If nLastKey == 27
		Return
	Endif

	nTipo := If(aReturn[4]==1,15,18)

	//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
	//ณ Processamento. RPTSTATUS monta janela com a regua de processamento. ณ
	//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
	//Cabec1 := Cabec1 + ' Produ็ใo entre : '+ dDatai +' E  '+ dDataF 
	RptStatus({|| RunReport(Cabec1,Cabec2,Titulo,nLin,mv_par01,mv_par02) },Titulo)
	
Return



Static Function GeraQ(dDi,dDf)
	
	/* Query de Status Fechado */	
	_cQuery := " SELECT ZDA_NUMZAU ,ZDA_COD, ZDA_DTPROD,ZDA_DESC,ZDA_QTDBD, ZDA_VALID AS DIASV "
	_cQuery += " FROM "  + retSqlTab('ZDA') 
	_cQuery += " WHERE " + retSqlFil('ZDA') 
	_cQuery += " AND (ZDA_DTPROD BETWEEN '" + dDi + "' AND '" +dDf + "') "
	_cQuery += " AND ZDA_STATUS = 'F' "	
	_cQuery += " AND "+retSqlDel('ZDA')
	_cQuery += " ORDER BY ZDA_DTPROD, ZDA_COD
	_cQuery  := ChangeQuery(_cQuery)
	

	//	* Mostrar a consulta */
	//@ 116,090 To 416,707 Dialog oDlgMemo Title "Consulta"
	//@ 055,005 Get _cQuery Size 250,080 MEMO Object oMemo
	//Activate Dialog oDlgMemo	
	
	If Select("TMP") != 0
		TMP->(dbCloseArea())
	Endif

	TCQUERY _cQuery NEW ALIAS "TMP"
		
		
	/* Query de Status em aberto */	
		
	
	_cQy2 := " SELECT ZDA_NUMZAU ,ZDA_COD, ZDA_DTPROD,ZDA_DESC,ZDA_QTDBD, ZDA_VALID AS DIASV "
	_cQy2 += " FROM "  + retSqlTab('ZDA') 
	_cQy2 += " WHERE " + retSqlFil('ZDA') 
	_cQy2 += " AND (ZDA_DTPROD BETWEEN '" + dDi + "' AND '" +dDf + "') "
	_cQy2 += " AND ZDA_STATUS IN ('A','L') "	
	_cQy2 += " AND "+retSqlDel('ZDA')
	_cQy2 += " ORDER BY ZDA_DTPROD, ZDA_COD
	_cQy2  := ChangeQuery(_cQy2)
	

	//	* Mostrar a consulta */
	//@ 116,090 To 416,707 Dialog oDlgMemo Title "Consulta"
	//@ 055,005 Get _cQy2 Size 250,080 MEMO Object oMemo
	//Activate Dialog oDlgMemo	
	
	If Select("TMP2") != 0
		TMP2->(dbCloseArea())
	Endif

	TCQUERY _cQy2 NEW ALIAS "TMP2"	
			
		
return


Static Function RunReport(Cabec1,Cabec2,Titulo,nLin,dDti,dDtf)
	
	Local nCont := 0 
	
	Cabec(Titulo,Cabec1,Cabec2,NomeProg,Tamanho,nTipo)
	nLin := 9

	//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
	//ณ SETREGUA -> Indica quantos registros serao processados para a regua ณ
	//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู

	TMP->(SetRegua(RecCount()))
	TMP->(dbGoTop())
	
	While TMP->(!EOF())

		incregua()

		//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
		//ณ Verifica o cancelamento pelo usuario...                             ณ
		//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู

		If lAbortPrint
			@nLin,00 PSAY "*** CANCELADO PELO OPERADOR ***"
			Exit
		Endif

		If nLin > 70 // Salto de Pแgina. Neste caso o formulario tem 55 linhas...
			Cabec(Titulo,Cabec1,Cabec2,NomeProg,Tamanho,nTipo)
			nLin := 9
	
		Endif
		If  nCont = 0 
		
			// dDti,dDtf
			
		
			@nlin,005 psay "Produ็ใo de :" 
			@nlin,020 psay dDti
			@nlin,032 psay "At้ : "
			@nlin,040 psay dDtf
			nLin++
			@nlin,005 psay "Sobras de Bandejas PROCESSADAS"
			nLin+=2
			
		Endif	
			
		/* ZDA_NUMZAU ,ZDA_COD, ZDA_DTPROD, ZDA_VALID AS DIASV  */ 		
		@nlin,007 psay TMP->ZDA_NUMZAU
		@nlin,020 psay TMP->ZDA_COD	
		@nlin,028 psay SUBSTR(TMP->ZDA_DESC,1,30)
		@nlin,065 psay TMP->ZDA_QTDBD	
		@nlin,073 psay STOD(TMP->ZDA_DTPROD)
		nlin++ 
			
		nCont++
		TMP->(dbSkip()) // Avanca o ponteiro do registro no arquivo

	EndDo
	nlin++ 
	nlin++ 
	/* TMP2 */
	
	TMP2->(SetRegua(RecCount()))
	TMP2->(dbGoTop())
	nCont := 0
	While TMP2->(!EOF())

		incregua()		

		If nLin > 70 // Salto de Pแgina. Neste caso o formulario tem 55 linhas...
			Cabec(Titulo,Cabec1,Cabec2,NomeProg,Tamanho,nTipo)
			nLin := 9
	
		Endif
		If  nCont = 0 
		
			// dDti,dDtf
			@nlin,005 psay "Sobras de Bandejas ABERTAS"
			nLin+=2
			
		Endif	
			
		/* ZDA_NUMZAU ,ZDA_COD, ZDA_DTPROD, ZDA_VALID AS DIASV  */ 		
		@nlin,007 psay TMP2->ZDA_NUMZAU
		@nlin,020 psay TMP2->ZDA_COD	
		@nlin,028 psay SUBSTR(TMP2->ZDA_DESC,1,30)
		@nlin,065 psay TMP2->ZDA_QTDBD	
		@nlin,073 psay STOD(TMP2->ZDA_DTPROD)
		nlin++ 				
		
		nCont++
		TMP2->(dbSkip()) // Avanca o ponteiro do registro no arquivo

	EndDo   
	                                                                                                                  
	//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
	//ณ Finaliza a execucao do relatorio...                                 ณ
	//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู

	SET DEVICE TO SCREEN

	//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
	//ณ Se impressao em disco, chama o gerenciador de impressao...          ณ
	//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู

	If aReturn[5]==1
		dbCommitAll()
		SET PRINTER TO
		OurSpool(wnrel)
	Endif

	MS_FLUSH()

Return

