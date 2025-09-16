#INCLUDE "rwmake.ch"
#INCLUDE "topconn.ch"

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³DTI49   º Autor ³ Flávio Bohrer Flôres  º Data ³  03/02/18  º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDescricao ³ Relatório de conferência de Pedidos x Clientes       	  º±±
±±º          ³                                                            º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ Compras (SIGACOM) 		                                  º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/

User Function DTI49()


	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Declaracao de Variaveis                                             ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ

	Local cDesc1         := "Este programa tem como objetivo imprimir relatorio  "
	Local cDesc2         := "que visualiza a quantidade de pedidos feitos por Fornecedor"
	Local cDesc3         := "em um determinado período"
	Local cPict          := ""
	Local titulo         := "Pedidos X Fornecedor"
	Local nLin           := 80
	Local _cNotaok 		 := 'N'
	Local Cabec1         := space(20)+"  Relatório referente a somatório de pedidos por Fornecedor"                   
	Local Cabec2         := "               Fornecedor                                                    Quant. Pedidos     "                        
	Local imprime        := .T.
	Local aOrd 			 := {}

	Private lEnd         := .F.
	Private lAbortPrint  := .F.
	Private limite       := 132
	Private tamanho      := "M"
	Private nomeprog     := "DTI49" // Coloque aqui o nome do programa para impressao no cabecalho
	Private nTipo        := 18
	Private aReturn      := { "Zebrado", 1, "Administracao", 2, 2, 1, "", 1}
	Private nLastKey     := 0
	Private cPerg        := "DTI49"
	Private cbcont      := 00
	Private CONTFL      := 01
	Private m_pag       := 01
	Private wnrel       := "DTI49" // Coloque aqui o nome do arquivo usado para impressao em disco    
	Private aStru	    := {}
	pergunte(cPerg,.F.)

	wnrel := SetPrint('SCR',NomeProg,cPerg,@titulo,cDesc1,cDesc2,cDesc3,.T.,aOrd,.T.,Tamanho,,.T.)

	//para verificação se existe previsao de pesagem
	// SD1 

	if mv_par03 = 1 // ivon 
		_cLibapro := '000028' 
	elseif mv_par03 = 2 // Matheus
		_cLibapro := '000044' 
	elseif  mv_par03 = 3 // clailton
		_cLibapro := '000033'
	elseif  mv_par03 = 4 // rodrigo
		_cLibapro := '000027'
	elseif  mv_par03 = 5//Kelen
		_cLibapro := '000036'	
	endif 

	cQuery :="SELECT CR_NUM AS PEDIDO,CR_LIBAPRO AS APROVADOR, CR_TOTAL AS VTOTAL"
	cQuery += " FROM " + RetSqlTab("SCR")"
	cQuery += " WHERE CR_FILIAL = '" + xFilial("SCR") + "' AND "  
	cQuery += " (CR_DATALIB BETWEEN '" + DTOS(mv_par01) + "' AND '" + DTOS(mv_par02) + "')  AND"
	cQuery += " CR_LIBAPRO = '" + _cLibapro + "' "
	cQuery += " ORDER BY CR_LIBAPRO,CR_DATALIB,CR_NUM"

	cQuery := ChangeQuery(cQuery)

	//	* Mostrar a consulta */
	//@ 116,090 To 416,707 Dialog oDlgMemo Title "Consulta"
	//@ 055,005 Get cQuery Size 250,080 MEMO Object oMemo
	//Activate Dialog oDlgMemo

	If Select("TMPSCR") != 0
		TMPSCR->(dbCloseArea())
	Endif

	TCQUERY cQuery NEW ALIAS "TMPSCR"

	If nLastKey == 27
		Return
	Endif

	SetDefault(aReturn,'TMPSCR')

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
	Local _cAprov := '      '
	Local aArea		:= GetArea()
	Local lRetorno	:= .T.
	Local cArqTrab	:= ""
	Local aInd		:= {}
	Local aTamSX3	:= {}
	Local aCampos	:= {}
	Local nA

	/*Criando a tabela temporária*/
	aAdd(aCampos,{"C7_NUM","C",06,0})
	aAdd(aCampos,{"C7_FORNECE","C",06,0})
	aAdd(aCampos,{"C7_NOME","C",45,0})
	aAdd(aCampos,{"C7_LOJA","C",02,0})
	aAdd(aCampos,{"C7_CONT","N",05,0})

	aAdd(aInd,{CriaTrab(Nil,.F.),"C7_FORNECE+C7_LOJA","Fornecedor+Loja"})

	_aArqTrb := {}
	//cArqTrab	:= CriaTrab(aCampos,.T.)
	//dbUseArea(.T.,,cArqTrab,"ARQTMP",.T.,.F.)

	If Select('ARQTMP')<>0                               //Se um tmp com alias TMP existir, fecha-o
		ARQTMP->(dbCloseArea())
		u_arqtrb ("FechaTodos",,,, @_aArqTrb)
	Endif

	U_ArqTrb("Cria", "ARQTMP", aCampos, {}, @_aArqTrb)

	dbSelectArea("ARQTMP")

	//Após selecionada a área do arquivo temporário...
	//For nA	:= 1 to Len(aInd)
		//Cria os índices utiliando o comando IndRegua
	//	IndRegua("ARQTMP",aInd[nA,1],aInd[nA,2],,,OemToAnsi("Criando Índice Temporário..."))
	//Next nA

	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ SETREGUA -> Indica quantos registros serao processados para a regua ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ

	TMPSCR->(dbGoTop())
	TMPSCR->(SetRegua(RecCount()))

	While TMPSCR->(!EOF())

		incregua()

		If lAbortPrint
			@nLin,00 PSAY "*** CANCELADO PELO OPERADOR ***"
			Exit
		Endif

		If nLin > 75 // Salto de Página. Neste caso o formulario tem 75 linhas...
			Cabec(Titulo,Cabec1,Cabec2,NomeProg,Tamanho,nTipo)
			nLin := 9
		Endif 

		if  (alltrim(_cAprov) # alltrim(TMPSCR->APROVADOR)) 
			_cDescr := fBuscaCpo('SAK',1,xFilial('SAK') + alltrim(TMPSCR->APROVADOR),'AK_NOME')
			@nlin,01 psay 'Aprovador: ' + TMPSCR->APROVADOR + ' - '+ alltrim(_cDescr)
			_cAprov := alltrim(TMPSCR->APROVADOR)
			nlin++
		endif															

		//chama uma função genérica pra testar nosso arquivo temporário
		Gravar(TMPSCR->PEDIDO)
		//RestArea(aArea)	 
		TMPSCR->(dbSkip())	

	EndDo


	dbSelectArea("ARQTMP")
	dbGoTop()
	Do While !EOF()

		incregua()

		If lAbortPrint
			@nLin,00 PSAY "*** CANCELADO PELO OPERADOR ***"
			Exit
		Endif

		If nLin > 75 // Salto de Página. Neste caso o formulario tem 75 linhas...
			Cabec(Titulo,Cabec1,Cabec2,NomeProg,Tamanho,nTipo)
			nLin := 9
		Endif 


		nlin++
		@nlin,15 psay ARQTMP->C7_FORNECE+'-'+ARQTMP->C7_LOJA +space(10)+ substr(ARQTMP->C7_NOME,1,40)
		@nlin,85 psay ARQTMP->C7_CONT	
		nlin++



		ARQTMP->(dbSkip())
	EndDo
	*/

	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Finaliza a execucao do relatorio...                                 ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ

	ARQTMP->(DbCloseArea())
	TMPSCR->(DbCloseArea())

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


Static Function Gravar(_cPedido)
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³Declaração de variáveis³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ

	_cForn  := "      "
	_cLoja  := "  "
	_cVal 	:= 'F'
	dbSelectArea("ARQTMP")

	// acrescentar ou verificar se ja tem fornecedor na tabela temporária
	_cForn  := fBuscaCPO('SC7',1,xfilial('SC7')+alltrim(_cPedido),'C7_FORNECE')
	_cLoja	:= fBuscaCPO('SC7',1,xfilial('SC7')+alltrim(_cPedido),'C7_LOJA')
	_cNome	:= fBuscaCPO('SA2',1,xfilial('SA2')+alltrim(_cForn)+alltrim(_cLoja),'A2_NOME')

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³Imprime todos os registros armazenados³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	//alert(_cForn+'-- Loja-'+_cLoja)
	//alert(_cPedido+'-'+'251')
	dbSelectArea("ARQTMP")
	dbGoTop()
	Do While !EOF()
		//alert(_cPedido+'-'+'251')
		If alltrim(_cForn) = alltrim(ARQTMP->C7_FORNECE)
			// se existir o fornecedor soma no campo cont
			dbSelectArea("ARQTMP")
			RecLock("ARQTMP",.F.)
			ARQTMP->C7_CONT := ARQTMP->C7_CONT + 1
			ARQTMP->(MsUnlock())
			_cVal := 'T'

			// Verificação dos pedidos
			/*
			if (alltrim(ARQTMP->C7_FORNECE) = '000084') //.or. (alltrim(ARQTMP->C7_FORNECE) = '004326') .or. (alltrim(ARQTMP->C7_FORNECE) = '012021')		
			alert(_cPedido+'--'+ARQTMP->C7_FORNECE+'-'+ARQTMP->C7_NOME)			
			Endif
			*/
		endif
		//dbSelectArea("ARQTMP")
		ARQTMP->(dbSkip())
	EndDo



	If _cVal = 'F'

		// Se não existir o fornecedor inclui um registro
		dbSelectArea("ARQTMP")
		RecLock("ARQTMP",.T.)
		ARQTMP->C7_FORNECE	:= _cForn		
		ARQTMP->C7_LOJA	:= _cLoja
		ARQTMP->C7_NOME	:= _cNome
		ARQTMP->C7_CONT	:= 1						
		ARQTMP->(MsUnlock())

	Endif

	// Verificação dos pedidos
	/*	
	if (alltrim(ARQTMP->C7_FORNECE) = '000084') //.or. (alltrim(ARQTMP->C7_FORNECE) = '004326') .or. (alltrim(ARQTMP->C7_FORNECE) = '012021')

	alert(_cPedido+'--'+ARQTMP->C7_FORNECE+'-'+ARQTMP->C7_NOME)

	Endif
	*/

Return
