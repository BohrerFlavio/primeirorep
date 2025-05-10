#INCLUDE "totvs.ch"
#INCLUDE "topconn.ch"

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³ DTI180  º Autor ³ Giuliano Forgiarini  º Data ³  27/01/09   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDescricao ³ R7 - Relatorio de Rastreabilidade - Produção da Embalagem  º±±
±±º          ³                                                            º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ Qualidade e PCP (SIGAPCP)                                  º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/

User Function DTI180()

	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Declaracao de Variaveis                                             ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ

	Local cDesc1         := "Este programa tem como objetivo imprimir relatorio  "
	Local cDesc2         := "de produção de MP no setor de embalagem da empresa"
	Local cDesc3         := "para aplicação do processo de rastreabilidade bovina"
	Local titulo         := "R7.2 - PRODUCAO DE MP DA EMBALAGEM"
	Local nlin           := 80
	//Local Cabec1         := "Ordem de Matança e Previsões da Entrada da Desossa"                   
	Local Cabec1         := "     Embalagem"
	Local Cabec2         := ""
	Local aOrd 			 := {}
	Local i 			 := 0
	Private lEnd         := .F.
	Private lAbortPrint  := .F.
	Private CbTxt        := ""
	Private limite       := 132
	Private tamanho      := "M"
	Private nomeprog     := "DTI180" // Coloque aqui o nome do programa para impressao no cabecalho
	Private nTipo        := 18
	Private aReturn      := { "Zebrado", 1, "Administracao", 2, 2, 1, "", 1}
	Private nLastKey     := 0
	Private cPerg        := "DTI180"
	Private cbcont       := 00
	Private CONTFL       := 01
	Private m_pag        := 01
	Private wnrel        := "DTI180" // Coloque aqui o nome do arquivo usado para impressao em disco
	Private _cNUMAM      := ''
	Private _cPreDes     := '' 
	Private _cClassif    := ''
	Private _cTipifi     := ''
	Private _cDescCort   := '' 
	Private _cDescProd   := ''
	Private _nQtPecas    := 0.00
	Private _dtABATE     := ''
	Private _cGrpMds     := alltrim(GETMV('MV_GRPMDS'))
	Private _cGrpPorc 	 := alltrim(GetMV('MV_GRPPORC'))
	Private _cGrpChar 	 := alltrim(GetMV('MV_GRPCHRQ'))
	Private _cMPChar 	 := "'001108','009168','009170'"	// MP Charque
	Private aGrupos 	 := {}

	pergunte(cPerg,.F.)

	wnrel := SetPrint('SZW',NomeProg,cPerg,@titulo,cDesc1,cDesc2,cDesc3,.T.,aOrd,.T.,Tamanho,,.T.)

	Cabec2 := "                     Codigo      Produto            Caixa           Quant.       Peso          " + iif(mv_par09 = 1, " Hora ", "Caixas") + "       Data Embal. Data Abate"

	_cGrupo := ""
	if mv_par07 = 2
		aGrupos := StrTokArr(_cGrpMds, '/')
		for i := 1 to len(aGrupos)
			if i < len(aGrupos)
				_cGrupo += "'" + aGrupos[i] + "'" + ","
			else
				_cGrupo += "'" + aGrupos[i] + "'"
			endif
		next
	elseif mv_par07 = 3
		aGrupos := StrTokArr(_cGrpPorc, '/')
		for i := 1 to len(aGrupos)
			if i < len(aGrupos)
				_cGrupo += "'" + aGrupos[i] + "'" + ","
			else
				_cGrupo += "'" + aGrupos[i] + "'"
			endif
		next
	elseif mv_par07 = 4
		aGrupos := StrTokArr(_cGrpChar, '/')
		for i := 1 to len(aGrupos)
			if i < len(aGrupos)
				_cGrupo += "'" + aGrupos[i] + "'" + ","
			else
				_cGrupo += "'" + aGrupos[i] + "'"
			endif
		next
	else
		aGrupos := StrTokArr((_cGrpMds + "/" + _cGrpPorc + "/" + _cGrpChar), '/')
		for i := 1 to len(aGrupos)
			if i < len(aGrupos)
				_cGrupo += "'" + aGrupos[i] + "'" + ","
			else
				_cGrupo += "'" + aGrupos[i] + "'"
			endif
		next
	endif

	MsgRun("Aguarde... Realizando contagem de registros...",,{||  GeraQuery(_cGrupo)})

	if nLastKey = 27
		Return
	endif

	SetDefault(aReturn,'SZW')

	if nLastKey = 27
		Return
	endif

	nTipo := if(aReturn[4]=1,15,18)

	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Processamento. RPTSTATUS monta janela com a regua de processamento. ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ

	RptStatus({|| RunReport(Cabec1,Cabec2,Titulo,nlin) },Titulo)
Return

Static Function RunReport(Cabec1,Cabec2,Titulo,nlin)

	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ SETREGUA -> Indica quantos registros serao processados para a regua ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ

	EMB->(dbGoTop())

	EMB->(SetRegua(RecCount()))

	_cCod := ""
	// Variáveis para somatórios
	_nQuant := 0
	_nCaix := 0
	_nPeso := 0
	_nTotC := 0

	while EMB->(!EOF())

		incregua()

		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³ Verifica o cancelamento pelo usuario...                             ³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ

		if lAbortPrint
			@nlin,00 PSAY "*** CANCELADO PELO OPERADOR ***"
			Exit
		endif

		if nlin > 55 // Salto de Página. Neste caso o formulario tem 55 linhas...
			Cabec(Titulo,Cabec1,Cabec2,NomeProg,Tamanho,nTipo)
			nlin := 9
		endif

		if _cCod != EMB->COD
			if !empty(_cCod)
				@nlin,50 psay "TOTAL -> "
				@nlin,70 psay _nQuant
				@nlin,80 psay alltrim(transform(_nPeso,'@E 999,999.99'))
				@nlin,95 psay _nCaix
				_nTotC += _nCaix
				_nQuant := 0
				_nCaix := 0
				_nPeso := 0
				nlin++
			endif
			@nlin,01 psay replicate('-', limite)
			nlin++
			_cCod := EMB->COD
			@nlin,10 psay "Produto -> " + alltrim(_cCod) + "  -  " + alltrim(EMB->DESCR) + " - (" + EMB->TIPO + ")"
			nlin++
			@nlin,01 psay replicate('-', limite)
			nlin++
		endif

		if mv_par09 = 1
			@nlin,50 psay EMB->CONTROL
		endif
		@nlin,70 psay EMB->QUANT
		@nlin,80 psay alltrim(transform(EMB->PESO,'@E 999,999.99'))
		@nlin,95 psay iif(mv_par09 = 1, alltrim(EMB->HORAP), alltrim(transform(EMB->CAIX,'@E 999,999')))
		@nlin,110 psay dtoc(stod(EMB->DATAP))
		if (mv_par07 = 1 .or. mv_par07 = 5 .or. mv_par07 = 2)
			@nlin,120 psay dtoc(stod(EMB->DTABT))
		endif
		nlin++

		_nQuant += EMB->QUANT
		if mv_par09 = 1
			_nCaix++
		else
			_nCaix += EMB->CAIX
		endif
		_nPeso += EMB->PESO

		EMB->(dbSkip()) // Avanca o ponteiro do registro no arquivo
	endDo

	@nlin,50 psay "TOTAL -> "
	@nlin,70 psay _nQuant
	@nlin,80 psay alltrim(transform(_nPeso,'@E 999,999.99'))
	@nlin,95 psay _nCaix
	nlin++
	_nTotC += _nCaix

	nlin++
	@nlin,01 psay replicate('=', limite)
	nlin++
	@nlin,10 psay "TOTAL DE CAIXAS => "
	@nlin,30 psay _nTotC
	nlin++
	@nlin,01 psay replicate('=', limite)
	nlin++

	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Finaliza a execucao do relatorio...                                 ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ

	DbCloseArea()

	SET DEVICE TO SCREEN

	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Se impressao em disco, chama o gerenciador de impressao...          ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ

	if aReturn[5]=1
		dbCommitAll()
		SET PRINTER TO
		OurSpool(wnrel)
	endif

	MS_FLUSH()

Return

Static Function GeraQuery(_cGrupo)

	// Caso seja Analítico
	if mv_par09 = 1
		cQuery := "SELECT ZW_CONTROL AS CONTROL, ZW_COD AS COD, ZW_PESO AS PESO, B1_DESC AS DESCR, ZW_QUANT AS QUANT, ZW_TIPOPRO AS TIPO,"
		cQuery += " ZW_DATAP AS DATAP, ZW_HORA AS HORAP" + iif((mv_par07 = 1 .or. mv_par07 = 5 .or. mv_par07 = 2), ", Z2_DATAABT AS DTABT", "") // Se precisa de data de abate (Desossa, Miúdos ou Todos), une com a SZ2
		cQuery += " FROM " + RetSqlTab("SZW")
		cQuery += " INNER JOIN"  + RetSqlTab("SB1") + " ON (ZW_COD = B1_COD)"
		// Se precisa de data de abate (Desossa, Miúdos ou Todos), une com a SZ2
		if mv_par07 = 1 .or. mv_par07 = 5 .or. mv_par07 = 2
			cQuery += " INNER JOIN"  + RetSqlTab("SZ2") + " ON (ZW_PREDES = Z2_NUM)"
		endif
		cQuery += " WHERE " + RetSqlFil("SZW") + " AND " + RetSqlFil("SB1")
		// Se precisa de data de abate (Desossa, Miúdos ou Todos), une com a SZ2
		if mv_par07 = 1 .or. mv_par07 = 5 .or. mv_par07 = 2
			cQuery += " AND " + RetSqlFil("SZ2")
		endif
		cQuery += " AND (ZW_DATAP BETWEEN '" + DTOS(mv_par02) + "' AND '" + DTOS(mv_par03) + "')"
		cQuery += " AND (ZW_HORA BETWEEN '" + iif(empty(mv_par04), '00:00', StrTran(padL(alltrim(transform(mv_par04, "@E 99.99")), 5, '0'), ',', ':')) + "' AND '" + iif(empty(mv_par05), '23:59', StrTran(padL(alltrim(transform(mv_par05, "@E 99.99")), 5, '0'), ',', ':')) + "')"
		// Busca somente produtos dos grupos do local de produção selecionado
		if mv_par07 = 4
			cQuery += " AND (B1_GRUPO IN (" + _cGrupo + ") OR B1_COD IN (" + _cMPChar + "))"
		elseif mv_par07 = 2 .or. mv_par07 = 3
			cQuery += " AND B1_GRUPO IN (" + _cGrupo + ")"
		elseif mv_par07 = 1
			cQuery += " AND B1_GRUPO NOT IN (" + _cGrupo + ")"
		endif
		// Se for selecionado um produto específico
		if !empty(mv_par06)
			cQuery += " AND ZW_COD = '" + mv_par06 + "'"
		endif
		// Se for selecionado um produto específico
		if mv_par10 = 2
			cQuery += " AND ZW_TIPOPRO = 'PA'"
		elseif mv_par10 = 3
			cQuery += " AND ZW_TIPOPRO = 'MP'"
		endif
		// Se for selecionado um destino específico
		if mv_par08 = 2
			cQuery += " AND B1_DESTINO = 'MI'"
		elseif mv_par08 = 3
			cQuery += " AND B1_DESTINO = 'ME'"
		endif
		// Se for selecionado um aviso de matança específico, filtra pela data de abate
		if !empty(mv_par01)
			cQuery += " AND (Z2_DATAABT BETWEEN '" + DTOS(mv_par01) + "' AND '" + DTOS(mv_par01) + "')"
		endif
		// Se for selecionado somente produtos que passaram no Raio-X
		if mv_par11 = 1
			cQuery += " AND ZW_STRRX <> ''"
		else
			cQuery += " AND ZW_STRRX = ''"
		endif
		// Se for selecionado somente produtos que entraram no estoque ou não
		if mv_par12 = 2
			cQuery += " AND ZW_DATAS <> ''"
		elseif mv_par12 = 3
			cQuery += " AND ZW_DATAS = ''"
		endif
		cQuery += " AND " + RetSQLDel('SZW') + " AND " + RetSQLDel('SB1') + iif((mv_par07 = 1 .or. mv_par07 = 5 .or. mv_par07 = 2), " AND " + RetSQLDel('SZ2'), "") // Se precisa de data de abate (Desossa, Miúdos ou Todos), une com a SZ2
		cQuery += " ORDER BY ZW_COD, ZW_DATAP"
	// Caso seja sintético
	else
		cQuery := "SELECT ZW_COD AS COD, SUM(ZW_PESO) AS PESO, B1_DESC AS DESCR, SUM(ZW_QUANT) AS QUANT, ZW_TIPOPRO AS TIPO,"
		cQuery += " COUNT(ZW_CONTROL) AS CAIX, ZW_DATAP AS DATAP" + iif((mv_par07 = 1 .or. mv_par07 = 5 .or. mv_par07 = 2), ", Z2_DATAABT AS DTABT", "") // Se precisa de data de abate (Desossa, Miúdos ou Todos), une com a SZ2
		cQuery += " FROM " + RetSqlTab("SZW")
		cQuery += " INNER JOIN"  + RetSqlTab("SB1") + " ON (ZW_COD = B1_COD)"
		// Se precisa de data de abate (Desossa, Miúdos ou Todos), une com a SZ2
		if mv_par07 = 1 .or. mv_par07 = 5 .or. mv_par07 = 2
			cQuery += " INNER JOIN"  + RetSqlTab("SZ2") + " ON (ZW_PREDES = Z2_NUM)"
		endif
		cQuery += " WHERE " + RetSqlFil("SZW") + " AND " + RetSqlFil("SB1")
		// Se precisa de data de abate (Desossa, Miúdos ou Todos), une com a SZ2
		if mv_par07 = 1 .or. mv_par07 = 5 .or. mv_par07 = 2
			cQuery += " AND " + RetSqlFil("SZ2")
		endif
		cQuery += " AND (ZW_DATAP BETWEEN '" + DTOS(mv_par02) + "' AND '" + DTOS(mv_par03) + "')"
		cQuery += " AND (ZW_HORA BETWEEN '" + iif(empty(mv_par04), '00:00', StrTran(padL(alltrim(transform(mv_par04, "@E 99.99")), 5, '0'), ',', ':')) + "' AND '" + iif(empty(mv_par05), '23:59', StrTran(padL(alltrim(transform(mv_par05, "@E 99.99")), 5, '0'), ',', ':')) + "')"
		// Busca somente produtos dos grupos do local de produção selecionado
		if mv_par07 = 4
			cQuery += " AND (B1_GRUPO IN (" + _cGrupo + ") OR B1_COD IN (" + _cMPChar + "))"
		elseif mv_par07 = 2 .or. mv_par07 = 3
			cQuery += " AND B1_GRUPO IN (" + _cGrupo + ")"
		elseif mv_par07 = 1
			cQuery += " AND B1_GRUPO NOT IN (" + _cGrupo + ")"
		endif
		// Se for selecionado um produto específico
		if !empty(mv_par06)
			cQuery += " AND ZW_COD = '" + mv_par06 + "'"
		endif
		// Se for selecionado um produto específico
		if mv_par10 = 2
			cQuery += " AND ZW_TIPOPRO = 'PA'"
		elseif mv_par10 = 3
			cQuery += " AND ZW_TIPOPRO = 'MP'"
		endif
		// Se for selecionado um destino específico
		if mv_par08 = 2
			cQuery += " AND B1_DESTINO = 'MI'"
		elseif mv_par08 = 3
			cQuery += " AND B1_DESTINO = 'ME'"
		endif
		// Se for selecionado um aviso de matança específico, filtra pela data de abate
		if !empty(mv_par01)
			cQuery += " AND (Z2_DATAABT BETWEEN '" + DTOS(mv_par01) + "' AND '" + DTOS(mv_par01) + "')"
		endif
		// Se for selecionado somente produtos que passaram no Raio-X
		if mv_par11 = 1
			cQuery += " AND ZW_STRRX <> ''"
		else
			cQuery += " AND ZW_STRRX = ''"
		endif
		// Se for selecionado somente produtos que entraram no estoque ou não
		if mv_par12 = 2
			cQuery += " AND ZW_DATAS <> ''"
		elseif mv_par12 = 3
			cQuery += " AND ZW_DATAS = ''"
		endif
		cQuery += " AND " + RetSQLDel('SZW') + " AND " + RetSQLDel('SB1') + iif((mv_par07 = 1 .or. mv_par07 = 5 .or. mv_par07 = 2), " AND " + RetSQLDel('SZ2'), "") // Se precisa de data de abate (Desossa, Miúdos ou Todos), une com a SZ2
		cQuery += " GROUP BY ZW_COD, ZW_DATAP, ZW_COD, B1_DESC, ZW_TIPOPRO" + iif((mv_par07 = 1 .or. mv_par07 = 5 .or. mv_par07 = 2  ), ", Z2_DATAABT", "") // Se precisa de data de abate (Desossa, Miúdos ou Todos), une com a SZ2
		cQuery += " ORDER BY ZW_COD, ZW_DATAP"
	endif

	cQuery := ChangeQuery(cQuery)

	//	* Mostrar a consulta */
	//@ 116,090 To 416,707 Dialog oDlgMemo Title "Consulta"
	//@ 055,005 Get cQuery Size 250,080 MEMO Object oMemo
	//Activate Dialog oDlgMemo

	if Select("EMB") != 0
		EMB->(dbCloseArea())
	endif

	TCQUERY cQuery NEW ALIAS "EMB"

Return
