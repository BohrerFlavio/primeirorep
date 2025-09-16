#INCLUDE "rwmake.ch"
#INCLUDE "topconn.ch"
#INCLUDE "protheus.ch"

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³GJF73   º Autor ³ Giuliano Forgiarini  º Data ³  27/01/09   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDescricao ³ R7 - Relatorio de Rastreabilidade - Produção da Embalagem  º±±
±±º          ³                                                            º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ Qualidade e PCP (SIGAPCP)                                  º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/

User Function GJF73()

	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Declaracao de Variaveis                                             ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ

	Local cDesc1         := "Este programa tem como objetivo imprimir relatorio  "
	Local cDesc2         := "de produção de caixas no setor de embalagem da empresa"
	Local cDesc3         := "para aplicação do processo de rastreabilidade bovina"
	Local titulo         := "R7 - PRODUCAO DA EMBALAGEM"
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
	Private nomeprog     := "GJF73" // Coloque aqui o nome do programa para impressao no cabecalho
	Private nTipo        := 18
	Private aReturn      := { "Zebrado", 1, "Administracao", 2, 2, 1, "", 1}
	Private nLastKey     := 0
	Private cPerg        := "GJF73"
	Private cbcont       := 00
	Private CONTFL       := 01
	Private m_pag        := 01
	Private wnrel        := "GJF73" // Coloque aqui o nome do arquivo usado para impressao em disco
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

	wnrel := SetPrint('SZ8',NomeProg,cPerg,@titulo,cDesc1,cDesc2,cDesc3,.T.,aOrd,.T.,Tamanho,,.T.)

	Cabec2 := "                     Codigo      Produto            Caixa      Quant.       Peso   Peso Bruto   " + iif(mv_par10 = 1, " Hora ", "Caixas") + "       Data Embal. Data " + iif(mv_par08 = 4, "Estufa", "Abate")

	_cGrupo := ""
	if mv_par08 = 2
		aGrupos := StrTokArr(_cGrpMds, '/')
		for i := 1 to len(aGrupos)
			if i < len(aGrupos)
				_cGrupo += "'" + aGrupos[i] + "'" + ","
			else
				_cGrupo += "'" + aGrupos[i] + "'"
			endif
		next
	elseif mv_par08 = 3
		aGrupos := StrTokArr(_cGrpPorc, '/')
		for i := 1 to len(aGrupos)
			if i < len(aGrupos)
				_cGrupo += "'" + aGrupos[i] + "'" + ","
			else
				_cGrupo += "'" + aGrupos[i] + "'"
			endif
		next
	elseif mv_par08 = 4
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

	SetDefault(aReturn,'SZ8')

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

	dbSelectArea('SB1')

	_cCod := ""
	_cLote := "_"
	_aSumLot := {}
	// Variáveis para somatórios
	_nQuant := 0
	_nCaix := 0
	_nPeso := 0
	_nPesoBr := 0
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

		if mv_par12 = 1
			if _cLote != EMB->LOTE .and. !empty(alltrim(EMB->LOTE))
				@nlin,01 psay replicate('=', limite)
				nlin++
				_aSumLot := SumLotUSA(EMB->LOTE)
				@nlin,05 psay "Lote EUA -> " + alltrim(EMB->LOTE) + " | Caixas -> " + alltrim(str(_aSumLot[1])) + " | Peso -> " + alltrim(str(_aSumLot[2])) + " | Shipping Mark -> " + alltrim(EMB->SHIPM)
				_cLote := EMB->LOTE
				nlin++
				@nlin,01 psay replicate('=', limite)
				nlin++
			endif
		endif

		if _cCod != EMB->COD
			@nlin,01 psay replicate('-', limite)
			nlin++
			if EMB->FIL = '01'
				_cCod := EMB->CODORI
				@nlin,10 psay "Produto -> " + alltrim(_cCod) + "  -  " + EMB->DESCR
			Else
				_cCod := EMB->COD
				@nlin,10 psay "Produto -> " + alltrim(_cCod) + "  -  " + EMB->DESCR
			endif
			nlin++
			@nlin,01 psay replicate('-', limite)
			nlin++
		endif

		if mv_par10 = 1
			@nlin,50 psay EMB->CONTROL
		endif
		@nlin,65 psay EMB->QUANT
		@nlin,75 psay alltrim(transform(EMB->PESO,'@E 999,999.99'))
		@nlin,85 psay alltrim(transform(EMB->PESOBR,'@E 999,999.99'))
		@nlin,97 psay iif(mv_par10 = 1, alltrim(EMB->HORAP), alltrim(transform(EMB->CAIX,'@E 999,999')))
		@nlin,110 psay dtoc(stod(EMB->DATAP))
		if (mv_par08 = 1 .or. mv_par08 = 5 .or. mv_par08 = 2)
			@nlin,122 psay dtoc(stod(EMB->DTABT))
		elseif mv_par08 = 4
			@nlin,122 psay dtoc(GetAdvFVal("SZU",'ZU_DTEST',FWxfilial('SZU')+EMB->NUMPREV,2))
		endif
		nlin++

		_nQuant += EMB->QUANT
		if mv_par10 = 1
			_nCaix++
		else
			_nCaix += EMB->CAIX
		endif
		_nPeso += EMB->PESO
		_nPesoBr += EMB->PESOBR

		EMB->(dbSkip()) // Avanca o ponteiro do registro no arquivo

		if _cCod != EMB->COD .and. EMB->(!EOF())
			if !empty(_cCod)
				@nlin,50 psay "TOTAL -> "
				@nlin,65 psay _nQuant
				@nlin,75 psay alltrim(transform(_nPeso,'@E 999,999.99'))
				@nlin,85 psay alltrim(transform(_nPesoBr,'@E 999,999.99'))
				@nlin,97 psay _nCaix
				_nTotC += _nCaix
				_nQuant := 0
				_nCaix := 0
				_nPeso := 0
				nlin++
			endif
		endif
	endDo

	@nlin,50 psay "TOTAL -> "
	@nlin,65 psay _nQuant
	@nlin,75 psay alltrim(transform(_nPeso,'@E 999,999.99'))
	@nlin,85 psay alltrim(transform(_nPesoBr,'@E 999,999.99'))
	@nlin,97 psay _nCaix
	nlin++
	_nTotC += _nCaix

	if mv_par07 = 1

		PEC->(dbGoTop())

		PEC->(SetRegua(RecCount()))
		_cNumam := ''

		@nlin,00 psay replicate('-',132)
		nlin++
		@nlin,10 psay 'AVISOS DE MATANÇA QUE COMPREENDEM A PRODUÇÃO DAS CAIXAS'
		nlin++

		while PEC->(!EOF())

			incregua()

			if lAbortPrint
				@nlin,00 PSAY "*** CANCELADO PELO OPERADOR ***"
				Exit
			endif

			if nlin > 55 // Salto de Página. Neste caso o formulario tem 55 linhas...
				Cabec(Titulo,Cabec1,Cabec2,NomeProg,Tamanho,nTipo)
				nlin := 9
			endif

			_dtIniAbt := GetAdvFVal('SZG','ZG_DATA',FWxfilial('SZG') + mv_par01,1)
			_dtAbte   := GetAdvFVal('SZG','ZG_DATA',FWxfilial('SZG') + PEC->NUMAM,1)

			if _dtAbte < _dtIniAbt
				PEC->(dbSkip())
				loop
			endif

			if _cNumam != PEC->NUMAM			
				@nlin,05 psay 'Aviso de Matança: ' + PEC->NUMAM		
				@nlin,35 psay 'Data de Abate: ' + dtoc(_dtAbte)
				nlin++
				_cNumam := PEC->NUMAM
			endif

			@nlin,10 psay transform(PEC->QTDPEC,'@E 99999')
			@nlin,17 psay iif(PEC->CORORI = 'D','Dianteiros',;
			iif(PEC->CORORI = 'T','Traseiros',;
			iif(PEC->CORORI = 'C','Costelas','')))
			nlin++

			PEC->(dbSkip())
		enddo           
	endif

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
	if mv_par10 = 1
		cQuery := "SELECT Z8_COD AS COD, Z8_CONTROL AS CONTROL, Z8_CODORI AS CODORI, Z8_FIL AS FIL, Z8_PESOBR AS PESOBR, Z8_PESO AS PESO, B1_DESC AS DESCR," + iif(mv_par12 = 1," ZU_LOTEUA AS LOTE, ZU_SHIPPIN AS SHIPM,","")
		IF (mv_par13 = 1)
			cQuery += " Z8_QUANT AS QUANT, Z8_DATAP AS DATAP, Z8_HORA AS HORAP, Z8_NUMPREV AS NUMPREV" + iif((mv_par08 = 1 .or. mv_par08 = 5 .or. mv_par08 = 2), ", Z2_DATAABT AS DTABT", "") // Se precisa de data de abate (Desossa, Miúdos ou Todos), une com a SZ2
		ELSEIF (mv_par13 = 2)
			cQuery += " B1_QTBCAIX AS QUANT, Z8_DATAP AS DATAP, Z8_HORA AS HORAP, Z8_NUMPREV AS NUMPREV" + iif((mv_par08 = 1 .or. mv_par08 = 5 .or. mv_par08 = 2), ", Z2_DATAABT AS DTABT", "") // Se precisa de data de abate (Desossa, Miúdos ou Todos), une com a SZ2
		ENDIF
		cQuery += " FROM " + RetSqlTab("SZ8")
		cQuery += " INNER JOIN"  + RetSqlTab("SB1") + " ON (Z8_CODORI = B1_COD)"
		// Se precisa de data de abate (Desossa, Miúdos ou Todos), une com a SZ2
		if mv_par08 = 1 .or. mv_par08 = 5 .or. mv_par08 = 2
			cQuery += " INNER JOIN"  + RetSqlTab("SZ2") + " ON (Z8_PREDES = Z2_NUM)"
		endif
		// Se precisa mostrar somente produtos com lote dos EUA
		if mv_par12 = 1
			cQuery += " INNER JOIN"  + RetSqlTab("SZU") + " ON (Z8_NUMPREV = ZU_NUM)"
		endif
		cQuery += " WHERE " + RetSqlFil("SZ8") + " AND Z8_FILORI = '" + cFilAnt + "' AND " + RetSqlFil("SB1")
		// Se precisa de data de abate (Desossa, Miúdos ou Todos), une com a SZ2
		if mv_par08 = 1 .or. mv_par08 = 5 .or. mv_par08 = 2
			cQuery += " AND " + RetSqlFil("SZ2")
		endif
		// Se precisa mostrar somente produtos com lote dos EUA
		if mv_par12 = 1
			cQuery += " AND " + RetSqlFil("SZU")
			cQuery += " AND LEN(ZU_LOTEUA) <= 16 "
			cQuery += " AND " + RetSQLDel('SZU')
		endif
		cQuery += " AND (Z8_DATAP BETWEEN '" + DTOS(mv_par02) + "' AND '" + DTOS(mv_par03) + "')"
		cQuery += " AND (Z8_HORA BETWEEN '" + iif(empty(mv_par04), '00:00', StrTran(padL(alltrim(transform(mv_par04, "@E 99.99")), 5, '0'), ',', ':')) + "' AND '" + iif(empty(mv_par05), '23:59', StrTran(padL(alltrim(transform(mv_par05, "@E 99.99")), 5, '0'), ',', ':')) + "')"
		// Busca somente produtos dos grupos do local de produção selecionado
		if mv_par08 = 4
			cQuery += " AND (B1_GRUPO IN (" + _cGrupo + ") OR B1_COD IN (" + _cMPChar + "))"
		elseif mv_par08 = 2 .or. mv_par08 = 3
			cQuery += " AND B1_GRUPO IN (" + _cGrupo + ")"
		elseif mv_par08 = 1
			cQuery += " AND B1_GRUPO NOT IN (" + _cGrupo + ")"
		endif
		// Se for selecionado um produto específico
		if !empty(mv_par06)
			cQuery += " AND Z8_COD = '" + mv_par06 + "'"
		endif
		// Se for selecionado um destino específico
		if mv_par09 = 2
			cQuery += " AND B1_DESTINO = 'MI'"
		elseif mv_par09 = 3
			cQuery += " AND B1_DESTINO = 'ME'"
		endif
		// Se for selecionado um aviso de matança específico, filtra pela data de abate
		if !empty(mv_par01)
			cQuery += " AND (Z2_DATAABT BETWEEN '" + DTOS(mv_par01) + "' AND '" + DTOS(mv_par01) + "')"
		endif
		// Filtro para mostrar caixas em que foi dado baixa ou não
		if mv_par11 = 2
			cQuery += " AND (Z8_DATAS <> '' AND Z8_ITEM = 'EST')"
		elseif mv_par11 = 3
			cQuery += " AND Z8_ITEM <> 'EST'"
		endif
		cQuery += " AND " + RetSQLDel('SZ8') + " AND " + RetSQLDel('SB1') + iif((mv_par08 = 1 .or. mv_par08 = 5 .or. mv_par08 = 2), " AND " + RetSQLDel('SZ2'), "") // Se precisa de data de abate (Desossa, Miúdos ou Todos), une com a SZ2
		if mv_par12 = 1
			cQuery += " ORDER BY ZU_SHIPPIN, ZU_LOTEUA, Z8_CODORI, Z8_DATAP, Z8_HORA"
		else
			cQuery += " ORDER BY Z8_CODORI, Z8_DATAP, Z8_HORA"
		endif
	// Caso seja sintético
	else
		cQuery := "SELECT Z8_COD AS COD, Z8_CODORI AS CODORI, Z8_FIL AS FIL, SUM(Z8_PESO) AS PESO, SUM(Z8_PESOBR) AS PESOBR, B1_DESC AS DESCR," + iif(mv_par12 = 1," ZU_LOTEUA AS LOTE, ZU_SHIPPIN AS SHIPM,","")
		cQuery += " SUM(Z8_QUANT) AS QUANT, COUNT(Z8_CONTROL) AS CAIX, Z8_DATAP AS DATAP, Z8_NUMPREV AS NUMPREV" + iif((mv_par08 = 1 .or. mv_par08 = 5 .or. mv_par08 = 2), ", Z2_DATAABT AS DTABT", "") // Se precisa de data de abate (Desossa, Miúdos ou Todos), une com a SZ2
		cQuery += " FROM " + RetSqlTab("SZ8")
		cQuery += " INNER JOIN"  + RetSqlTab("SB1") + " ON (Z8_CODORI = B1_COD)"
		// Se precisa de data de abate (Desossa, Miúdos ou Todos), une com a SZ2
		if mv_par08 = 1 .or. mv_par08 = 5 .or. mv_par08 = 2
			cQuery += " INNER JOIN"  + RetSqlTab("SZ2") + " ON (Z8_PREDES = Z2_NUM)"
		endif
		// Se precisa mostrar somente produtos com lote dos EUA
		if mv_par12 = 1
			cQuery += " INNER JOIN"  + RetSqlTab("SZU") + " ON (Z8_NUMPREV = ZU_NUM)"
		endif
		cQuery += " WHERE " + RetSqlFil("SZ8") + " AND Z8_FILORI = '" + cFilAnt + "' AND " + RetSqlFil("SB1")
		// Se precisa de data de abate (Desossa, Miúdos ou Todos), une com a SZ2
		if mv_par08 = 1 .or. mv_par08 = 5 .or. mv_par08 = 2
			cQuery += " AND " + RetSqlFil("SZ2")
		endif
		// Se precisa mostrar somente produtos com lote dos EUA
		if mv_par12 = 1
			cQuery += " AND " + RetSqlFil("SZU")
			cQuery += " AND LEN(ZU_LOTEUA) <= 16 "
			cQuery += " AND " + RetSQLDel('SZU')
		endif
		cQuery += " AND (Z8_DATAP BETWEEN '" + DTOS(mv_par02) + "' AND '" + DTOS(mv_par03) + "')"
		cQuery += " AND (Z8_HORA BETWEEN '" + iif(empty(mv_par04), '00:00', StrTran(padL(alltrim(transform(mv_par04, "@E 99.99")), 5, '0'), ',', ':')) + "' AND '" + iif(empty(mv_par05), '23:59', StrTran(padL(alltrim(transform(mv_par05, "@E 99.99")), 5, '0'), ',', ':')) + "')"
		// Busca somente produtos dos grupos do local de produção selecionado
		if mv_par08 = 4
			cQuery += " AND (B1_GRUPO IN (" + _cGrupo + ") OR B1_COD IN (" + _cMPChar + "))"
		elseif mv_par08 = 2 .or. mv_par08 = 3
			cQuery += " AND B1_GRUPO IN (" + _cGrupo + ")"
		elseif mv_par08 = 1
			cQuery += " AND B1_GRUPO NOT IN (" + _cGrupo + ")"
		endif
		// Se for selecionado um produto específico
		if !empty(mv_par06)
			cQuery += " AND Z8_COD = '" + mv_par06 + "'"
		endif
		// Se for selecionado um destino específico
		if mv_par09 = 2
			cQuery += " AND B1_DESTINO = 'MI'"
		elseif mv_par09 = 3
			cQuery += " AND B1_DESTINO = 'ME'"
		endif
		// Se for selecionado um aviso de matança específico, filtra pela data de abate
		if !empty(mv_par01)
			cQuery += " AND (Z2_DATAABT BETWEEN '" + DTOS(mv_par01) + "' AND '" + DTOS(mv_par01) + "')"
		endif
		// Filtro para mostrar caixas em que foi dado baixa ou não
		if mv_par11 = 2
			cQuery += " AND (Z8_DATAS <> '' AND Z8_ITEM = 'EST')"
		elseif mv_par11 = 3
			cQuery += " AND Z8_ITEM <> 'EST'"
		endif
		cQuery += " AND " + RetSQLDel('SZ8') + " AND " + RetSQLDel('SB1') + iif((mv_par08 = 1 .or. mv_par08 = 5 .or. mv_par08 = 2), " AND " + RetSQLDel('SZ2'), "") // Se precisa de data de abate (Desossa, Miúdos ou Todos), une com a SZ2
		// Se precisa mostrar somente produtos com lote dos EUA
		if mv_par12 = 1
			cQuery += " GROUP BY ZU_SHIPPIN, ZU_LOTEUA, Z8_CODORI, Z8_DATAP, Z8_COD, Z8_FIL, B1_DESC, Z8_NUMPREV" + iif((mv_par08 = 1 .or. mv_par08 = 5 .or. mv_par08 = 2  ), ", Z2_DATAABT", "") // Se precisa de data de abate (Desossa, Miúdos ou Todos), une com a SZ2
			cQuery += " ORDER BY ZU_SHIPPIN, ZU_LOTEUA, Z8_CODORI, Z8_DATAP"
		else
			cQuery += " GROUP BY Z8_CODORI, Z8_DATAP, Z8_COD, Z8_FIL, B1_DESC, Z8_NUMPREV" + iif((mv_par08 = 1 .or. mv_par08 = 5 .or. mv_par08 = 2  ), ", Z2_DATAABT", "") // Se precisa de data de abate (Desossa, Miúdos ou Todos), une com a SZ2
			cQuery += " ORDER BY Z8_CODORI, Z8_DATAP"
		endif
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

	//Query2 para listar totais de peças
	_corOri    := GetAdvFVal('SB1','B1_CORORI',FWxFilial('SB1') + mv_par06,1)

	cQuery2 := " SELECT COUNT(ZAJ_NUM) AS QTDPEC, ZAJ_CORORI AS CORORI, ZAJ_NUMAM AS NUMAM
	cQuery2 += " FROM " + retSqlTab('ZAJ') + ", " + retSqlTab('SZ2')
	cQuery2 += " WHERE " + retSqlFil('ZAJ') + " AND " + retSqlFil('SZ2')
	cQuery2 += " AND ZAJ_DATAS BETWEEN '" +dtos(mv_par02)+"' AND '"+dtos(mv_par03) + "'"
	cQuery2 += " AND ZAJ_PRECAR = '' AND ZAJ_PREPED = '' AND ZAJ_ITEM = ''
	cQuery2 += " AND ZAJ_CORORI = '" + _corOri + "'
	cQuery2 += " AND ZAJ_CORORI != 'C' AND Z2_NUM = ZAJ_PREDES AND Z2_CLASESP = 'S'
	cQuery2 += " AND " + retSqlDel('ZAJ') + " AND " + retSqlDel('SZ2')
	cQuery2 += " GROUP BY ZAJ_CORORI, ZAJ_NUMAM
	cQuery2 += " ORDER BY ZAJ_NUMAM

	cQuery2 := ChangeQuery(cQuery2)

	//	* Mostrar a consulta */
	//@ 116,090 To 416,707 Dialog oDlgMemo Title "Consulta"
	//@ 055,005 Get cQuery2 Size 250,080 MEMO Object oMemo
	//Activate Dialog oDlgMemo

	if Select("PEC") != 0
		PEC->(dbCloseArea())
	endif

	TCQUERY cQuery2 NEW ALIAS "PEC"

Return

Static Function SumLotUSA(_cLoteUSA)
	cQuery3 := " SELECT COUNT(Z8_CONTROL) AS CAIXAS, SUM(Z8_PESO) AS PESO"
	cQuery3 += " FROM " + retSqlTab('SZ8')
	cQuery3 += " INNER JOIN " + retSqlTab('SZU') + "ON (Z8_NUMPREV = ZU_NUM)"
	cQuery3 += " WHERE " + retSqlFil('SZ8') + " AND " + retSqlFil('SZU')
	cQuery3 += " AND Z8_DATAS = '' AND Z8_FIL = '" + cFilAnt + "'"
	cQuery3 += " AND ZU_LOTEUA = '" + alltrim(_cLoteUSA) + "'"
	cQuery3 += " AND " + retSqlDel('SZ8') + " AND " + retSqlDel('SZU')

	cQuery3 := ChangeQuery(cQuery3)

	//	* Mostrar a consulta */
	//@ 116,090 To 416,707 Dialog oDlgMemo Title "Consulta"
	//@ 055,005 Get cQuery2 Size 250,080 MEMO Object oMemo
	//Activate Dialog oDlgMemo

	if Select("TMP") != 0
		TMP->(dbCloseArea())
	endif

	TCQUERY cQuery3 NEW ALIAS "TMP"

Return {TMP->CAIXAS, TMP->PESO}
