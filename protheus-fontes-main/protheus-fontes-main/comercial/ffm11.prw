#INCLUDE "rwmake.ch"
#INCLUDE "topconn.ch"

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³FFM11    º Autor ³ Mauricio Roehrs em 31/03/2014            º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDescricao ³ Relatorio para redistribuidores					          º±±
±±º          ³                                                            º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ Comercial 				                                  º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/

User Function FFM11()


	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Declaracao de Variaveis                                             ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ

	Local cDesc1         := "Este programa tem como objetivo imprimir relatorio"
	Local cDesc2         := "para controle de saida para redistribuidores"
	Local cDesc3         := ""
	Local cPict          := "Frigorifico Silva"
	Local titulo         := "RELATORIO DE SAIDA PARA REDISTRIBUIDORES"
	Local Cabec1         := "Cod. Redistrib      Redistribuidor"
	Local Cabec2         := "       Nota        Cod. Cli  Loja                Cliente                 Pre-Pedido          Peso Liq.          Peso Bruto"
	Local imprime         := .T.
	Local aOrd            := {}  
	Private nLin           := 80
	Private lEnd          := .F.
	Private lAbortPrint   := .F.
	Private CbTxt         := ""
	Private limite        := 80
	Private tamanho       := "M"
	Private nomeprog      := "FFM11" // Coloque aqui o nome do programa para impressao no cabecalho
	Private nTipo         := 18
	Private aReturn       := { "Zebrado", 1, "Administracao", 2, 2, 1, "", 1}
	Private nLastKey      := 0
	Private cPerg   	  := "FFM11"
	Private cbtxt      	:= Space(10)
	Private cbcont     := 00
	Private CONTFL     := 01                           

	Private m_pag      := 01
	Private wnrel      := "FFM11" // Coloque aqui o nome do arquivo usado para impressao em disco    
	Private _cRedis	 := ''
	pergunte(cPerg,.F.)


	wnrel := SetPrint('SC5',NomeProg,cPerg,@titulo,cDesc1,cDesc2,cDesc3,.T.,aOrd,.T.,Tamanho,,.T.)  

	_cQuery := " SELECT C5_NOTA, C5_CLIENTE, C5_LOJACLI, C5_REDIS, C5_PREPED, SUM(C6_QTDVEN) AS C6_PESOL
	_cQuery += " FROM  " + retSqlTab('SC5') + " , " + retSqlTab('SC6')
	_cQuery += " WHERE " + retSqlFil('SC5') + " AND " + retSqlFil('SC6')  
	_cQuery += " AND C5_REDIS <> '' AND C5_NUM = C6_NUM"  
	_cQuery += " AND C5_EMISSAO BETWEEN '" + dtos(mv_par01) + "' AND '" + dtos(mv_par02) + "'"
	_cQuery += " AND C5_CLIENTE BETWEEN '" +    mv_par03    + "' AND '" +    mv_par04    + "'"                               
	_cQuery += " AND C5_LOJACLI BETWEEN '" +    mv_par05    + "' AND '" +    mv_par06    + "'"
	If MV_PAR08 = 1
		_cQuery += " AND SUBSTRING(C6_GRUPO,1,2) = '56'"	// Quando for produtos do Porcionados feito por Fabian Maurer 07/04/16
	ElseIf MV_PAR08 = 2
		_cQuery += " AND SUBSTRING(C6_GRUPO,1,2) <> '56'"	// Quando não for produtos do Porcionados feito por Fabian Maurer 07/04/16
	EndIf
	if !empty(mv_par07)
		//_cRedis := alltrim(fBuscaCPO('SX5',1,xfilial('SX5')+'ZB'+alltrim(mv_par07),'X5_CHAVE')) 
		_cRedis := alltrim(fBuscaCPO('SA4',1,xfilial('SA4')+ alltrim(mv_par07),'A4_COD'))
		_cQuery += " AND C5_REDIS = '" + _cRedis + "'"  
	endif
	_cQuery += " AND " + retSqlDel('SC5')
	_cQuery += " GROUP BY C5_REDIS, C5_CLIENTE, C5_LOJACLI, C5_NOTA, C5_PESOL, C5_PBRUTO,C5_PREPED
	_cQuery += " ORDER BY C5_REDIS, C5_CLIENTE, C5_LOJACLI, C5_NOTA
	_cQuery  := ChangeQuery(_cQuery)

	//	* Mostrar a consulta */
	//@ 116,090 To 416,707 Dialog oDlgMemo Title "Consulta"
	//@ 055,005 Get _cQuery Size 250,080 MEMO Object oMemo
	//Activate Dialog oDlgMemo

	MsgRun("Aguarde... Realizando contagem de registros...",,{||  GeraTMP() })

	If nLastKey == 27
		Return
	Endif

	SetDefault(aReturn,'SP8')

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

	_cRedis     := ''
	_cPreped    := '' 
	_nPesBruto  := 0.00
	_cCli		   := ''
	_cDescRedis := ''
	_nTotPesL   := 0.00
	_nTotPesB	:= 0.00

	@nlin,01 psay replicate('-',132)
	nlin++
	If mv_par08 = 1
		@nlin,01 psay 'Total de Produtos Porcionados Carregando'
	ElseIf mv_par08 = 2
		@nlin,01 psay 'Total de Produtos Frigorifico Carregado'
	Else
		@nlin,01 psay 'Total de Ambos Produtos Carregados'
	EndIf
	nlin++
	@nlin,01 psay replicate('-',132)
	nlin++
	nlin++
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

		/*função que retorna o peso bruto*/		
		_nPesBruto := pesoBruto(TMP->C5_PREPED)//só haverá peso bruto se for gerado um pre-pedido pelo comercial 

		_cCli 	   := fBuscaCPO('SA1',1,xFilial('SA1') + TMP->C5_CLIENTE + TMP->C5_LOJACLI,'A1_NOME')
		//_cDescRedis := alltrim(fBuscaCPO('SX5',1,xfilial('SX5')+'ZB'+alltrim(mv_par07),'X5_DESCRI'))
		_cDescRedis := alltrim(fBuscaCPO('SA4',1,xfilial('SA4') + alltrim(mv_par07),'A4_NREDUZ'))
		//fBuscaCPO('SA2',1,xFilial('SA2') + TMP->C5_REDIS,'A2_NOME')

		/*quebra por redistribuidor*/ 

		if _cRedis <> TMP->C5_REDIS
			@nlin,02 psay TMP->C5_REDIS //Codigo do redistribuidor 
			@nlin,18 psay substr(_cDescRedis,1,25)
			nlin++               
			_cRedis := TMP->C5_REDIS		
			nlin++
		endif


		_nTotPesL += TMP->C6_PESOL
		_nTotPesB += _nPesBruto

		@nlin,05 psay TMP->C5_NOTA   								//Nota Fiscal
		@nlin,20 psay substr(TMP->C5_CLIENTE,1,6)					//Codigo do Cliente
		@nlin,30 psay TMP->C5_LOJACLI    							//loja do cliente
		@nlin,40 psay substr(_cCli,1,25)							//nome do cliente
		@nlin,75 psay TMP->C5_PREPED   								//pre-pedido de venda
		@nlin,90 psay transform(TMP->C6_PESOL,'@E 999,999.99')      //Peso Liquido
		@nlin,110 psay transform(_nPesBruto,'@E 999,999.99')        //PesoBruto
		nlin++


		TMP->(dbSkip()) // Avanca o ponteiro do registro no arquivo

		if _cRedis <> TMP->C5_REDIS .or. TMP->(eof())
			nlin++
			@nlin,70 psay 'Total ------------>' 
			@nlin,90 psay transform(_nTotPesL,'@E 999,999.99') //Total de peso liquido
			@nlin,110 psay transform(_nTotPesB,'@E 999,999.99') //Total de peso bruto
			nlin++
			@nlin,01 psay replicate('-',132)
			nlin++
			_nTotPesL := 0.00
			_nTotPesB := 0.00
		endif

	EndDo 
	nlin+=10
	@nlin,40 psay replicate('_',50)
	nlin++
	@nlin,58 psay 'ASS. RECEBEDOR'

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

Static Function pesoBruto(_cPrePed)


	_cQuery2 := " SELECT SUM(ZZ5_QRPESB) AS PESBRUTO
	_cQuery2 += " FROM  " + retSqlTab('ZZ5')
	_cQuery2 += " WHERE " + retSqlFil('ZZ5')
	_cQuery2 += " AND ZZ5_NUM = '" + _cPrePed + "'"
	_cQuery2 += " AND " + retSqlDel('ZZ5') 

	_cQuery2  := ChangeQuery(_cQuery2)

	//	* Mostrar a consulta */
	//@ 116,090 To 416,707 Dialog oDlgMemo Title "Consulta"
	//@ 055,005 Get _cQuery Size 250,080 MEMO Object oMemo
	//Activate Dialog oDlgMemo

	If Select("TMP2") != 0
		TMP2->(dbCloseArea())
	Endif

	TCQUERY _cQuery2 NEW ALIAS "TMP2"

return TMP2->PESBRUTO
