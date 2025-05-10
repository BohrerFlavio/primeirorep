#INCLUDE 'PROTHEUS.ch'
#INCLUDE "rwmake.ch"
#INCLUDE "topconn.ch"

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³GJF58   º Autor ³ Giuliano Forgiarini  º Data ³  30/09/08   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDescricao ³ Relatorio caixas de PA por data de validade                º±±
±±º          ³                                                            º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ Comercial e expedições (SIGAPCP e SIGAOMS)                 º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/

User Function GJF58()

	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Declaracao de Variaveis                                             ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ

	Local cDesc1         := "Este programa tem como objetivo imprimir relatorio  "
	Local cDesc2         := "de caixas de produto acabado com data de validade   "
	Local cDesc3         := "no período informado nos parametros da rotina.      "                                                
	Local titulo       	 := "RELAÇÃO DE CAIXAS POR DATA DE VALIDADE DE PRODUTO ACABADO"
	Local nLin         	 := 80
	Local Cabec1       	 := "Codigo   Descricao Produto                                                                Quant.         Peso"                   
	Local Cabec2       	 := "                 Codigo        Lote Porc.    Quant.   Peso Liq.  Produção     Validade   Localizacao    Cod. de Origem       CSN"
	Local aOrd 			 := {}
	Private lEnd         := .F.
	Private lAbortPrint  := .F.
	Private CbTxt        := ""
	Private limite       := 80
	Private tamanho      := "M"
	Private nomeprog     := "GJF58" // Coloque aqui o nome do programa para impressao no cabecalho
	Private nTipo        := 18
	Private aReturn      := { "Zebrado", 1, "Administracao", 2, 2, 1, "", 1}
	Private nLastKey     := 0
	Private cPerg   	 := "GJF58"
	Private cbcont     	 := 00
	Private CONTFL     	 := 01
	Private m_pag      	 := 01
	Private wnrel      	 := "GJF58" // Coloque aqui o nome do arquivo usado para impressao em disco    
	Private TotCaix    	 := 0.00
	Private TotPeso    	 := 0.00
	private numeral    	 := 1

	pergunte(cPerg,.F.)

	wnrel := SetPrint('SZ8',NomeProg,cPerg,@titulo,cDesc1,cDesc2,cDesc3,.T.,aOrd,.T.,Tamanho,,.T.)

	//para verificação se existe previsao de pesagem

	do case
		case mv_par03 = 1
		_Farm := 'C'
		case mv_par03 = 2
		_Farm := 'R'
		case mv_par03 = 3
		_Farm := 'S'
		otherwise
		_Farm := 'T'
	endcase

	cQuery := "SELECT BM_FARM AS FARM, Z8_COD AS COD, B1_DESC AS DESCR, Z8_CONTROL AS CONTROL, Z8_DATAP AS DATAP, Z8_LOTEPOR AS LOTEPOR," + iif(!empty(mv_par16)," ZAC_CERCSN AS NRO_CSN,", "")
	cQuery += " Z8_QUANT AS QUANT, Z8_PESO AS PESO, Z8_DATAVAL AS DATAVAL, Z8_LOCAL AS CAMARA, Z8_FILORI AS FILORI, Z8_CODORI AS CODORI, B1_FAM AS FAM"
	cQuery += " FROM " + RetSqlTab("SZ8")
	cQuery += " INNER JOIN " + RetSqlTab("SB1") + " ON (SZ8.Z8_COD = SB1.B1_COD)"
	cQuery += " INNER JOIN " + RetSqlTab("SBM") + " ON (SB1.B1_GRUPO = SBM.BM_GRUPO)"
	cQuery += iif(!empty(mv_par16)," INNER JOIN " + RetSqlTab("ZAC") + " ON (Z8_CODTRAN = ZAC_NUM)", "")
	cQuery += " WHERE " + RetSqlFil("SZ8") + " AND " + RetSqlFil("SBM")  + " AND " + RetSqlFil("SB1") + " AND"
	cQuery += " B1_TIPO IN('PR','PA') AND"
	cQuery += " Z8_FIL = '" + cFilAnt + "' AND"
	cQuery += " Z8_TERC <> 'S' AND"
	cQuery += " Z8_ENCONTR <> 'N' AND"
	cQuery += " Z8_DATAVAL BETWEEN '" + DTOS(mv_par01) +"' AND '" + DTOS(mv_par02) + "' AND"
	cQuery += " Z8_DATAP BETWEEN '"   + DTOS(mv_par08) +"' AND '" + DTOS(mv_par09) + "' AND"
	cQuery += " Z8_DATAS = '' AND"

	if _Farm != 'T'
		cQuery += " BM_FARM = '" + _Farm + "' AND"
	endif

	if !empty(mv_par04)
		cQuery += " B1_FAM = '" + mv_par04 + "' AND"
	endif

	if !empty(mv_par06)
		cQuery += " B1_COD = '" + mv_par06 + "' AND"
	endif

	if !empty(mv_par07)
		cQuery += " Z8_LOCAL = '" + mv_par07 + "' AND"
	endif

	//com endereçamento
	if mv_par11 == 1
		cQuery += " Z8_LOCAL <> '' AND Z8_LOCALIZ <> '' AND"
		//sem endereçamento
	elseif mv_par11 == 2
		cQuery += " Z8_LOCAL = '' AND Z8_LOCALIZ = '' AND"
	endif

	//filtra desossa ou porcionados
	if mv_par13 == 2
		cQuery += " Z8_LOTEPOR <> '' AND"
	endif

	if !empty(mv_par16)
		cQuery += " ZAC_CERCSN = '" + mv_par16 + "' AND"
	endif

	cQuery +=  RetSqlDel("SZ8") + " AND " + RetSqlDel("SBM")  + " AND " + RetSqlDel("SB1") + iif(!empty(mv_par16)," AND " + RetSqlDel("ZAC"), "")
	
	if mv_par14  = 1
		cQuery +=  " ORDER BY BM_FARM," + iif(!empty(mv_par16)," ZAC_CERCSN,", "") + " Z8_COD, Z8_DATAVAL, Z8_CONTROL"
	else
		cQuery +=  " ORDER BY Z8_DATAVAL, BM_FARM, Z8_COD"
	endif

	cQuery := ChangeQuery(cQuery)

	
	//	* Mostrar a consulta */
	//@ 116,090 To 416,707 Dialog oDlgMemo Title "Consulta"
	//@ 055,005 Get cQuery Size 250,080 MEMO Object oMemo
	//Activate Dialog oDlgMemo
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Monta a interface padrao com o usuario...                           ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ

	If Select("DTVAL") != 0
		DTVAL->(dbCloseArea())
	Endif
	TCQUERY cQuery NEW ALIAS "DTVAL"

	If nLastKey == 27
		Return
	Endif

	SetDefault(aReturn,'SZ8')

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

	Local _nPos := 0

	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ SETREGUA -> Indica quantos registros serao processados para a regua ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	DTVAL->(dbGoTop())

	_nContReg := 0

	while DTVAL->(!eof())
		_nContReg++
		DTVAL->(DbSkip())
	enddo

	DTVAL->(dbGoTop())

	SetRegua(_nContReg)

	_Arm       := ''
	_Prod      := ''
	_nTotProdC := 0
	_nTotProdP := 0.00	
	_aTotProd := {}

	While DTVAL->(!EOF())

		incregua()

		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³ Verifica o cancelamento pelo usuario...                             ³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ

		If lAbortPrint
			@nLin,00 PSAY "*** CANCELADO PELO OPERADOR ***"
			Exit
		Endif

		if !empty(mv_par10)
			_ProdComp := Posicione('SG1',1,FWxfilial('SG1') + DTVAL->COD,'G1_COMP')
			if alltrim(mv_par10) <> alltrim(_ProdComp)
				DTVAL->(DbSkip())
				loop
			endif
		endif

		//bloco para verificar quais familias não devem ser aparecer no relatorio 
		if empty(mv_par04) .and. !empty(mv_par12)
			if DTVAL->FAM $ alltrim(mv_par12)
				DTVAL->(dbSkip())
				loop
			endif
		endif

		If nLin > 75 // Salto de Página. Neste caso o formulario tem 55 linhas...
			Cabec(Titulo,Cabec1,Cabec2,NomeProg,Tamanho,nTipo)
			nLin := 9
		Endif 

		if _Arm != DTVAL->FARM
			if !empty(_Arm)
				nlin += 2
			endif
			do case
				case DTVAL->FARM = 'R'
				@nlin,001 psay 'RESFRIADOS:'
				case DTVAL->FARM = 'C'
				@nlin,001 psay 'CONGELADOS:'
				case DTVAL->FARM = 'S'
				@nlin,001 psay 'SALGADOS:'
			endcase
			_Arm := DTVAL->FARM
			nlin++
		endif

		if _Prod != DTVAL->COD
			nlin++
			@nlin,001 psay substr(DTVAL->COD,1,6) 
			@nlin,009 psay DTVAL->DESCR
			_Prod := DTVAL->COD
			nlin++
			_nTotProdC := 0
			_nTotProdP := 0.00
		endif

		if mv_par05 != 1
			@nlin,010 psay numeral++
			@nlin,015 psay DTVAL->CONTROL
			@nlin,025 psay DTVAL->LOTEPOR
			@nlin,043 psay transform(DTVAL->QUANT,'@E 9,999')
			@nlin,050 psay transform(DTVAL->PESO,'@E 999,999.99')
			@nlin,065 psay stod(DTVAL->DATAP)
			@nlin,077 psay stod(DTVAL->DATAVAL)
			@nlin,090 psay DTVAL->CAMARA
			@nlin,105 psay DTVAL->CODORI
			if !empty(mv_par16)
				@nlin,115 psay DTVAL->NRO_CSN
			endif
			nlin++
		endif

		_nTotProdC++
		_nTotProdP+=DTVAL->PESO

		DTVAL->(dbSkip()) // Avanca o ponteiro do registro no arquivo

		If nLin > 75 // Salto de Página. Neste caso o formulario tem 55 linhas...
			Cabec(Titulo,Cabec1,Cabec2,NomeProg,Tamanho,nTipo)
			nLin := 9
		Endif

		if _Prod != DTVAL->COD
			@nlin,01 psay 'Total de caixas e peso:------------------------------------------------------------------>'
			@nlin,092 psay transform(_nTotProdC,'@E 9,999')
			@nlin,102 psay transform(_nTotProdP,'@E 999,999.99')
			if !empty(mv_par16)
				@nlin,115 psay DTVAL->NRO_CSN
			endif
			_nPos := AScan(_aTotProd, {|aVal|aVal[1] = _Prod})			// Trecho de código para mostrar um resumo no final
			if _nPos != 0
				_aTotProd[_nPos, 3] += _nTotProdC
				_aTotProd[_nPos, 4] += _nTotProdP
			else
				Aadd(_aTotProd, {_Prod, Posicione('SB1',1,FWxfilial('SB1')+alltrim(_Prod),'B1_DESC'), _nTotProdC, _nTotProdP, iif(!empty(mv_par16),DTVAL->NRO_CSN, "")})
			endif
		endif
	EndDo

	// Resumo solicitado pelo Philip
	Cabec(Titulo,Cabec1,Cabec2,NomeProg,Tamanho,nTipo)
	nLin := 9
	@nlin,001 psay "RESUMO DE CAIXAS E PESOS POR PRODUTO"
	nlin++
	nlin++

	for _nPos := 1 to Len(_aTotProd)
		@nlin,001 psay AllTrim(_aTotProd[_nPos, 1])
		@nlin,009 psay AllTrim(_aTotProd[_nPos, 2])
		nlin++
		@nlin,001 psay 'Total de caixas e peso:------------------------------------------------------------------>'
		@nlin,092 psay transform(_aTotProd[_nPos, 3],'@E 9,999')
		@nlin,102 psay transform(_aTotProd[_nPos, 4],'@E 999,999.99')
		@nlin,115 psay _aTotProd[_nPos, 5]
		nlin++
		If nLin > 75 // Salto de Página. Neste caso o formulario tem 55 linhas...
			Cabec(Titulo,Cabec1,Cabec2,NomeProg,Tamanho,nTipo)
			nLin := 9
		Endif
	next

	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Finaliza a execucao do relatorio...                                 ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ

	DbCloseArea()

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
