#INCLUDE "rwmake.ch"
#INCLUDE "topconn.ch"

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³MLR39     ºAutor  ³Mauricio Roehrs     º Data ³  16/10/14   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³   Relatorio para conferencia de total de Descontos e       º±±
±±º          ³   Acrescimos                                               º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ AP                                                         º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/


User Function MLR39()


	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Declaracao de Variaveis                                             ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ

	Local cDesc1         := "Este programa tem como objetivo imprimir relatorio"
	Local cDesc2         := "para conferencia dos valores de desconto e acrescimo"
	Local cDesc3         := "dos pre-pedidos faturados contidos entre as datas de carreg. "
	Local cPict          := "vai porra"
	Local titulo         := "RELATORIO PARA CONF. DE DESC/ACRESC"
	Local Cabec1         := ""
	Local Cabec2         := "              Cod.Prod.     Descrição                    Peso(kg)        Preço(R$)  Tp.Bonific.   Bonific.(R$)   Prc.Final(R$) "
	Local imprime         := .T.
	Local aOrd            := {}  
	Private nLin           := 80
	Private lEnd          := .F.
	Private lAbortPrint   := .F.
	Private CbTxt         := ""
	Private limite        := 80
	Private tamanho       := "M"
	Private nomeprog      := "MLR39" // Coloque aqui o nome do programa para impressao no cabecalho
	Private nTipo         := 18
	Private aReturn       := { "Zebrado", 1, "Administracao", 2, 2, 1, "", 1}
	Private nLastKey      := 0
	Private cPerg   		 := "MLR39"
	Private cbtxt      	:= Space(10)
	Private cbcont     := 00
	Private CONTFL     := 01
	Private m_pag      := 01
	Private wnrel      := "MLR39" // Coloque aqui o nome do arquivo usado para impressao em disco    
	pergunte(cPerg,.F.)


	wnrel := SetPrint('ZZ3',NomeProg,cPerg,@titulo,cDesc1,cDesc2,cDesc3,.T.,aOrd,.T.,Tamanho,,.T.)  

	cabec1 += 'Carregamentos do período de ' + dtoc(mv_par01) + ' até ' + dtoc(mv_par02)

	_cQuery := " SELECT ZZ3_DTCAR, ZZ5_NUM, ZZ5_COD, ZZ5_DESC, ZZ5_TPBONI, ZZ5_QRPESO, ZZ5_BONIF, ZZ5_PRECO,ZZ4_CODCLI,ZZ4_LOJA,
	_cQuery += " (ZZ5_QRPESO * ZZ5_BONIF) AS DESAC
	_cQuery += " FROM  " + retSqlTab('ZZ3') + " , " + retSqlTab('ZZ4') + " , " + retSqlTab('ZZ5')
	_cQuery += " WHERE " + retSqlFil('ZZ3') + " AND " + retSqlFil('ZZ4') + " AND " + retSqlFil('ZZ5')                    
	_cQuery += " AND ZZ3_NUM = ZZ4_PRECAR AND ZZ4_NUM = ZZ5_NUM AND ZZ5_TPBONI IN('D','A') AND ZZ5_QRPESO > 0 AND ZZ5_BONIF > 0"
	_cQuery += " AND ZZ4_STATUS = 'F' AND ZZ3_DTCAR BETWEEN '" + dtos(mv_par01) + "' AND '" + dtos(mv_par02) + "'"
	_cQuery += " AND " + retSqlDel('ZZ3') + " AND " + retSqlDel('ZZ4') + " AND " + retSqlDel('ZZ5') 
	_cQuery += " ORDER BY ZZ3_DTCAR,ZZ5_NUM

	_cQuery  := ChangeQuery(_cQuery)

	//	* Mostrar a consulta */
	//@ 116,090 To 416,707 Dialog oDlgMemo Title "Consulta"
	//@ 055,005 Get _cQuery Size 250,080 MEMO Object oMemo
	//Activate Dialog oDlgMemo

	MsgRun("Aguarde... Realizando contagem de registros...",,{||  GeraTMP() })

	If nLastKey == 27
		Return
	Endif

	SetDefault(aReturn,'ZZ3')

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

	Cabec(Titulo,Cabec1,Cabec2,NomeProg,Tamanho,nTipo)
	nLin := 9


	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ SETREGUA -> Indica quantos registros serao processados para a regua ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ

	TMP->(SetRegua(RecCount()))

	TMP->(dbGoTop())
	_dData 	  := ""
	_cNum 	  := ""
	_nTotDesc  := 0
	_nTotAcres := 0  
	_cLojaCli  := ""

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


		if mv_par03 = 1 //se for analitico

			_cCodCli  := alltrim(TMP->ZZ4_CODCLI)
			_cLoja    := alltrim(TMP->ZZ4_LOJA)
			_cNomeCli := fBuscaCPO('SA1',1,xfilial('SA1')+_cCodCli+_cLoja,'A1_NOME')	


			@nlin,05 psay stod(TMP->ZZ3_DTCAR)
			@nlin,17 psay TMP->ZZ4_CODCLI + " / " + TMP->ZZ4_LOJA						
			@nlin,31 psay alltrim(substr(_cNomeCli,1,20))

			@nlin,54 psay alltrim(TMP->ZZ5_COD)
			@nlin,64 psay substr(TMP->ZZ5_DESC,1,20)
			@nlin,84 psay transform(TMP->ZZ5_QRPESO,'@E 999,999.99')
			@nlin,97 psay transform(TMP->ZZ5_PRECO,'@E 99.99')			
			_nDesc := TMP->ZZ5_BONIF 

			if TMP->ZZ5_TPBONI = 'D'
				@nlin,105 psay 	'Desconto'  
				_nDesc := _nDesc * (-1)
			else 
				@nlin,105 psay 	'Acrescimo'
			endif
			@nlin,115 psay transform(TMP->ZZ5_BONIF,'@E 99.99')
			@nlin,125 psay transform(TMP->(ZZ5_PRECO + _nDesc),'@E 99.99')	
			nlin++					
		endif


		if TMP->ZZ5_TPBONI = 'D' 
			_nTotDesc += TMP->DESAC
		elseif TMP->ZZ5_TPBONI = 'A' 
			_nTotAcres += TMP->DESAC
		endif		


		TMP->(dbSkip()) // Avanca o ponteiro do registro no arquivo

	EndDo  
	@nlin,01 psay replicate('-',132)
	nlin++   
	@nlin,10 psay 'TOTAIS'
	nlin++
	@nlin,20 psay 'Desconto:  '  + transform(_nTotDesc,'@E 999,999,999.99')  
	nlin++
	@nlin,20 psay 'Acrescimo: ' + transform(_nTotAcres,'@E 999,999,999.99') 


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


Static Function GeraTMP()   

	_cQuery  := ChangeQuery(_cQuery)

	//	* Mostrar a consulta */
	//@ 116,090 To 416,707 Dialog oDlgMemo Title "Consulta"
	//@ 055,005 Get _cQuery Size 250,080 MEMO Object oMemo
	//Activate Dialog oDlgMemo

	If Select("TMP") != 0
		TMP->(dbCloseArea())
	Endif

	TCQUERY _cQuery NEW ALIAS "TMP"

return                                                                                                                     


