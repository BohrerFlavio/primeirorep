#INCLUDE "rwmake.ch"
#INCLUDE "topconn.ch"

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³DTI48   º Autor ³ Flávio Bohrer Flôres  º Data ³  03/02/18  º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDescricao ³ Relatório de conferência de Pedidos x Notas				  º±±
±±º          ³                                                            º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ Compras (SIGACOM) 		                                  º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/

User Function DTI48()


	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Declaracao de Variaveis                                             ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ

	Local cDesc1         := "Este programa tem como objetivo imprimir relatorio  "
	Local cDesc2         := "que visualiza os pedidos e suas respectivas notas"
	Local cDesc3         := "Identificando quais notas são de quais pedidos"
	Local cPict          := ""
	Local titulo         := "Notas x Pedidos"
	Local nLin           := 80
	Local _cNotaok 		 := 'N'
	Local Cabec1         := space(20)+"  Relatório referente a Pedidos de Compras x Notas Fiscais Recebidas"                   
	Local Cabec2         := "                   Nr Pedido         Cod.Produto     Desc.Produto                                    Valor Total     "                        
	Local imprime        := .T.
	Local aOrd 			 := {}
	Private lEnd         := .F.
	Private lAbortPrint  := .F.
	Private limite       := 132
	Private tamanho      := "M"
	Private nomeprog     := "DTI48" // Coloque aqui o nome do programa para impressao no cabecalho
	Private nTipo        := 18
	Private aReturn      := { "Zebrado", 1, "Administracao", 2, 2, 1, "", 1}
	Private nLastKey     := 0
	Private cPerg        := "DTI48"
	Private cbcont      := 00
	Private CONTFL      := 01
	Private m_pag       := 01
	Private wnrel       := "DTI48" // Coloque aqui o nome do arquivo usado para impressao em disco    



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
	else
		//mv_par03 = 5//Kelen
		_cLibapro := '000036'	
	endif 

	//alert(mv_par03)
	//alert(_cLibapro)
	cQuery :="SELECT CR_NUM AS PEDIDO,CR_LIBAPRO AS APROVADOR, CR_TOTAL AS VTOTAL,CR_DATALIB AS DATAL"
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
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Monta a interface padrao com o usuario...                           ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ   


	If Select("TMPSCR") != 0
		TMPSCR->(dbCloseArea())
	Endif

	TCQUERY cQuery NEW ALIAS "TMPSCR"

	//alert('100')
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
	//alert(Cabec1+"-"+Cabec2+"-"+Titulo)
	//alert(nLin)

	RptStatus({|| RunReport(Cabec1,Cabec2,Titulo,nLin) },Titulo)
Return

Static Function RunReport(Cabec1,Cabec2,Titulo,nLin)

	Local nOrdem
	Local _cAprov := "      "
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ SETREGUA -> Indica quantos registros serao processados para a regua ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	//SCR->(DbSetOrder(1))
	TMPSCR->(dbGoTop())
	TMPSCR->(SetRegua(RecCount()))

	While TMPSCR->(!EOF())

		incregua()


		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³ Verifica o cancelamento pelo usuario...                             ³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		_cNotaok := 'N'	
		If lAbortPrint
			@nLin,00 PSAY "*** CANCELADO PELO OPERADOR ***"
			Exit
		Endif


		If nLin > 75 // Salto de Página. Neste caso o formulario tem 55 linhas...
			Cabec(Titulo,Cabec1,Cabec2,NomeProg,Tamanho,nTipo)
			nLin := 9
		Endif 
		if  (alltrim(_cAprov) # alltrim(TMPSCR->APROVADOR)) 
			_cDescr := fBuscaCpo('SAK',1,xFilial('SAK') + alltrim(TMPSCR->APROVADOR),'AK_NOME')
			@nlin,01 psay 'Aprovador: ' + TMPSCR->APROVADOR + ' - '+ alltrim(_cDescr)
			_cAprov := alltrim(TMPSCR->APROVADOR)
			nlin++
		endif
		nlin++																

		@nlin,26 psay 'Nr.Pedido : ' +TMPSCR->PEDIDO 
		@nlin,81 psay ' Vlr. Total Pedido:' + transform(TMPSCR->VTOTAL,'@E 999,999,999,999.99')
		nlin++	
		// Busca Itens

		/*Função que busca o valor da nota e ítens*/ 
		nLin:= Bitem(TMPSCR->PEDIDO,nlin,Titulo,Cabec1,Cabec2,NomeProg,Tamanho,nTipo)
		/* Caso o pedido ainda não tenha recebido Nota então buscar itens do Pedido*/
		if _cNotaok = 'N'
			// Escrever o ítem do produto
			//_cCodPro := fBuscaCpo('SC7',1,xFilial('SC7') + alltrim(SCR->PEDIDO),'C7_DESCRI')
			nlin++	
			@nlin,26 psay 'OBS - Sem NF ' 
			nlin++
			nLin:= Bitemped(TMPSCR->PEDIDO,nlin,Titulo,Cabec1,Cabec2,NomeProg,Tamanho,nTipo)

		endif	
		nLin++
		@nLin,30 psay REPLICATE("-",70)

		TMPSCR->(dbSkip())	

	EndDo




	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Finaliza a execucao do relatorio...                                 ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ


	DbCloseArea('TMPSCR')
	DbCloseArea('ITEM')
	DbCloseArea('ITSC7')
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

Static Function Bitem(_cPedido,_nlinh,T1,T2,T3,T4,T5,T6)
	Local _cTOTAL := ''
	// -----------inicio
	//Query2 para listar os itens das notas e valor total da nota

	cQuery2 := " SELECT D1_PEDIDO AS PEDIDO, D1_ITEMPC AS ITEMPC , D1_DOC AS DOC,D1_SERIE AS SERIE, D1_TOTAL AS TOTAL, D1_COD AS COD, D1_DESCRI AS DESCRI"
	cQuery2 += " FROM "+retSqlTab('SD1')
	cQuery2 += " WHERE "+retSqlFil('SD1')
	cQuery2 += " AND D1_PEDIDO = '"+alltrim(_cPedido) + "'"	
	cQuery2 += " AND " + retSqlDel('SD1')
	cQuery2 += " ORDER BY D1_ITEMPC"

	cQuery2 := ChangeQuery(cQuery2)

	If Select("ITEM") != 0
		ITEM->(dbCloseArea())
	Endif

	TCQUERY cQuery2 NEW ALIAS "ITEM"

	//	* Mostrar a consulta */
	//@ 116,090 To 416,707 Dialog oDlgMemo Title "Consulta"
	//@ 055,005 Get cQuery2 Size 250,080 MEMO Object oMemo
	//Activate Dialog oDlgMemo

	ITEM->(dbGoTop())
	ITEM->(SetRegua(RecCount()))

	_nCont := 0	

	While ITEM->(!EOF())

		incregua()
		if _nCont = 0
			_cTOTAL := fBuscaCpo('SF1',1,xFilial('SF1') + alltrim(ITEM->DOC)+alltrim(ITEM->SERIE),'F1_VALBRUT')		
			_nlinh++ 
			@_nlinh,30 psay  "Nr Nota:"+space(3)+ ITEM->DOC + ' - Valor Nota: '+ space(5)+alltrim(transform(_cTOTAL,'@E 999,999,999,999.99'))
			_nlinh++
			_nlinh++
			_nCont++
		endif

		If _nlinh > 75 // Salto de Página. Neste caso o formulario tem 55 linhas...
			Cabec(T1,T2,T3,T4,T5,T6)
			_nlinh := 9
		Endif 	

		@_nlinh,40 psay  alltrim(ITEM->COD) + ' - ' + substr(ITEM->DESCRI,1,40)
		_nlinh++	
		_cNotaok = 'S'	
		ITEM->(dbSkip())	

	EndDo


Return (_nlinh)


Static Function Bitemped(_cPedido,_nlinh,T1,T2,T3,T4,T5,T6)

	cQuery3 := " SELECT C7_NUM AS PEDIDO, C7_PRODUTO AS PROD, C7_DESCRI AS DESCRI"
	cQuery3 += " FROM "+retSqlTab('SC7')
	cQuery3 += " WHERE "+retSqlFil('SC7')
	cQuery3 += " AND C7_NUM = '"+alltrim(_cPedido) + "'"	
	cQuery3 += " AND " + retSqlDel('SC7')
	cQuery3 += " ORDER BY C7_ITEM"

	cQuery3 := ChangeQuery(cQuery3)

	If Select("ITSC7") != 0
		ITSC7->(dbCloseArea())
	Endif

	TCQUERY cQuery3 NEW ALIAS "ITSC7"

	//	* Mostrar a consulta */
	//@ 116,090 To 416,707 Dialog oDlgMemo Title "Consulta"
	//@ 055,005 Get cQuery2 Size 250,080 MEMO Object oMemo
	//Activate Dialog oDlgMemo

	ITSC7->(dbGoTop())
	ITSC7->(SetRegua(RecCount()))

	While ITSC7->(!EOF())

		incregua()

		If _nlinh > 75 // Salto de Página. Neste caso o formulario tem 55 linhas...
			Cabec(T1,T2,T3,T4,T5,T6)
			_nlinh := 9
		Endif 	

		@_nlinh,40 psay  alltrim(ITSC7->PROD) + ' - ' + substr(ITSC7->DESCRI,1,40)
		_nlinh++	
		ITSC7->(dbSkip())	

	EndDo


Return (_nlinh)
