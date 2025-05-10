#INCLUDE "totvs.ch"
#INCLUDE "topconn.ch"

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³ DTI207    ºAutor  ³Adonai Gabriel   º Data ³  02/03/24     º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³ Relatório para conferência de carregamentos com picking    º±±
±±º          ³ liberado conforme data.                                    º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ Direção                                                    º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/

User Function DTI207()

    //ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Declaracao de Variaveis                                             ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ

	Local cDesc1         := "Este programa tem como objetivo imprimir um relatório"
	Local cDesc2         := "para conferência de carregamentos com picking liberado."
	Local cDesc3         := ""
	Local titulo         := "CARREGAMENTOS COM PICKING LIBERADO"
	Local Cabec1         := ""
	Local Cabec2         := "                              CODIGO         DESCRIÇÃO                           QUANT. PREV.  QUANT. ESTOQUE"
	Local aOrd           := {}
	Local i				 := 0
	Private nlin         := 80
	Private lEnd         := .F.
	Private lAbortPrint  := .F.
	Private CbTxt        := ""
	Private limite       := 132
	Private tamanho      := "M"
	Private nomeprog     := "DTI207" // Coloque aqui o nome do programa para impressao no cabecalho
	Private nTipo        := 18
	Private aReturn      := { "Zebrado", 1, "Administracao", 2, 2, 1, "", 1}
	Private nLastKey     := 0
	Private cPerg   	 := "DTI207"
	Private cbcont     	 := 00
	Private CONTFL    	 := 01
	Private m_pag      	 := 01
	Private wnrel      	 := "DTI207" // Coloque aqui o nome do arquivo usado para impressao em disco
	Private _aDados 	 := {}
	Private _aCabec		 := {}
	Private _cGrpMds     := alltrim(GETMV('MV_GRPMDS'))
	Private _cGrpPorc 	 := alltrim(GetMV('MV_GRPPORC'))
	Private _cGrpChar 	 := alltrim(GetMV('MV_GRPCHRQ'))
	Private _cMPChar 	 := "'001108','009168','009170'"	// MP Charque
	Private _cProdZaf 	 := "'001427','001508','001430','001082','021959','022350','001508','002192','002194','002228','002193','001654','002191','002190'," // Produtos Zaffari
	_cProdZaf 	 		 += "'002189','002195','005510','002203','001082','001508','001541','000574','001430','000578','001061','001772','005658','001116'," // Produtos Zaffari
	_cProdZaf 	 		 += "'001388','013091','001415','001414','001413','002021','001412','001386','001449','002667','003586','009606','001427','002076'," // Produtos Zaffari
	_cProdZaf 	 		 += "'001478','001382','001983','001383','001973','001107','000717','000718','000715','000722','001040','000714','000721','000713'," // Produtos Zaffari
	_cProdZaf 	 		 += "'001738','001387','000734','002200','002627'"	// Produtos Zaffari
	Private _cFamZaf 	 := ""
	Private aGrupos 	 := {}

	pergunte(cPerg,.F.)

	wnrel := SetPrint('ZZ3',NomeProg,cPerg,@titulo,cDesc1,cDesc2,cDesc3,.T.,aOrd,.T.,Tamanho,,.T.)

	while empty(mv_par01) .or. empty(mv_par02)
		FWAlertError('Por favor, informe um intervalo da data!','ALERTA!')
		pergunte(cPerg,.T.)
	end

	Cabec1 += 'De data de carregamento - ' +  DTOC(mv_par01) + " - até - " + DTOC(mv_par02)

	_cGrupo := ""
	if mv_par04 = 1
		aGrupos := StrTokArr(_cGrpPorc, '/')
		for i := 1 to len(aGrupos)
			if i < len(aGrupos)
				_cGrupo += "'" + aGrupos[i] + "'" + ","
			else
				_cGrupo += "'" + aGrupos[i] + "'"
			endif
		next
	elseif mv_par04 = 2
		aGrupos := StrTokArr((_cGrpPorc + "/" + _cGrpChar), '/')
		for i := 1 to len(aGrupos)
			if i < len(aGrupos)
				_cGrupo += "'" + aGrupos[i] + "'" + ","
			else
				_cGrupo += "'" + aGrupos[i] + "'"
			endif
		next
	endif

	MsgRun("Aguarde... Realizando o processamento dos registros...",,{|| GeraCAR(_cGrupo)})

	If nLastKey == 27
		Return
	Endif

	SetDefault(aReturn,'ZZ3')

    //ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Processamento. RPTSTATUS monta janela com a regua de processamento. ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ

	RptStatus({|| RunReport(Cabec1,Cabec2,Titulo,nlin) },Titulo)

Return


Static Function RunReport(Cabec1,Cabec2,Titulo,nlin)

	Local i := 0

	Cabec(Titulo,Cabec1,Cabec2,NomeProg,Tamanho,nTipo)
	nlin := 9

    CAR->(dbGoTop())
	CAR->(SetRegua(RecCount()))

	nPos := 0
	_lAux := .F.
	_cCarr := ""
	_aCarr := {}
	_cStatus := ""
	_nTotalP := 0
	_nTotalE := 0

    While CAR->(!EOF())

		incregua()

        If lAbortPrint
            @nlin,00 PSAY "*** CANCELADO PELO OPERADOR ***"
            Exit
        Endif

		if CAR->ESTOQUE < CAR->CAIXAS
			do case
				case CAR->ZZ3_STATUS = 'A'
					_cStatus := "ABERTO"
				case CAR->ZZ3_STATUS = 'C'
					_cStatus := "CARREGANDO"
				case CAR->ZZ3_STATUS = 'E'
					_cStatus := "ENCERRADO"
				case CAR->ZZ3_STATUS = 'S'
					_cStatus := "EM ESPERA"
				case CAR->ZZ3_STATUS = 'B'
					_cStatus := "BLOQUEADO"
			endcase

			aadd(_aCarr, {CAR->ZZ3_NUM, alltrim(CAR->ZZ3_OBS), _cStatus, dtoc(stod(CAR->ZZ3_DTCAR)), alltrim(CAR->ZZ5_COD),;
							alltrim(substr(GetAdvFval('SB1','B1_DESCRED',FwxFilial('SB1')+alltrim(CAR->ZZ5_COD),1),1,40)), CAR->CAIXAS, CAR->ESTOQUE})

			if mv_par03 = 2
				aadd(_aDados, {CAR->ZZ3_NUM, alltrim(CAR->ZZ3_OBS), _cStatus, dtoc(stod(CAR->ZZ3_DTCAR)), alltrim(CAR->ZZ5_COD), _aCarr[len(_aCarr),6],;
					transform(CAR->CAIXAS,'@E 999,999'), transform(CAR->ESTOQUE,'@E 999,999')})
			endif
		endif

		CAR->(dbSkip()) // Avanca o ponteiro do registro no arquivo
    enddo

	for i := 1 to len(_aCarr)
		If nlin > 60 // Salto de Página. Neste caso o formulario tem 55 linhas...
            Cabec(Titulo,Cabec1,Cabec2,NomeProg,Tamanho,nTipo)
            nlin := 9
        Endif

		if _cCarr <> _aCarr[i,1]
			if _lAux
				@nlin,00 psay replicate('-',limite)
				nlin++
				@nlin,70 psay 'Total: '
				@nlin,82 psay transform(_nTotalP,'@E 999,999')
				@nlin,95 psay transform(_nTotalE,'@E 999,999')
				nlin++
				_nTotalP := 0
				_nTotalE := 0
			endif
			@nlin,00 psay replicate('=',limite)
			nlin++
			@nlin,05 psay 'Carregamento: ' + _aCarr[i,1] + " | " + _aCarr[i,2] + " | " + _aCarr[i,3] + " | " + _aCarr[i,4]
			nlin++
			@nlin,00 psay replicate('=',limite)
			nlin++
			_cCarr := _aCarr[i,1]
			_lAux := .T.
		endif

		@nlin,30 psay _aCarr[i,5]
		@nlin,40 psay _aCarr[i,6]
		@nlin,82 psay transform(_aCarr[i,7],'@E 999,999')
		@nlin,95 psay transform(_aCarr[i,8],'@E 999,999')
		nlin++

		_nTotalP += _aCarr[i,7]
		_nTotalE += _aCarr[i,8]
	next

	@nlin,00 psay replicate('-',limite)
	nlin++
	@nlin,70 psay 'Total: '
	@nlin,82 psay transform(_nTotalP,'@E 999,999')
	@nlin,95 psay transform(_nTotalE,'@E 999,999')
	nlin++

    //ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Finaliza a execucao do relatorio...                                 ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ

	SET DEVICE TO SCREEN

	if mv_par03 = 2
		If Len(_aDados) > 0		// Gera e mostra no Excel
			AADD( _aCabec, {"NUM. DO CARREG.", "C", 6, 0})
			AADD( _aCabec, {"OBSERVAÇÃO", "C", 20, 0})
			AADD( _aCabec, {"STATUS", "C", 10, 0})
			AADD( _aCabec, {"DATA DE CARREG.", "D", 8, 0})
			AADD( _aCabec, {"COD. PRODUTO", "C", 6, 0})
			AADD( _aCabec, {"DESC. PROD.", "C", 30, 0})
			AADD( _aCabec, {"QUANT. PREVISTA",	"N", 9, 0})
			AADD( _aCabec, {"QUANT. ESTOQUE",	"N", 9, 0})
			U_GERAEXCEL(nomeprog, _aDados, _aCabec, .T., .T.)
		Endif
	endif

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

Static Function GeraCAR(_cGrupo)

	cQuery := "SELECT ZZ3_NUM, ZZ3_DTCAR, ZZ3_OBS, ZZ5_COD, SUM(ZZ5_QPCAIX - ZZ5_QRCAIX) AS CAIXAS, ZZ3_STATUS,"
	cQuery += " (SELECT COUNT(Z8_CONTROL) AS ESTOQUE"
	cQuery += " FROM " + RetSQLTab('SZ8')
	cQuery += " WHERE " + RetSQLFil('SZ8')
	cQuery += " AND Z8_FIL = '" + cFilAnt + "'"
	cQuery += " AND Z8_COD = ZZ5_COD"
	cQuery += " AND Z8_DATAVAL >= '" + dtos(ddatabase) + "'"
	cQuery += " AND Z8_DATAS = ''"
	cQuery += " AND " + RetSQLDel('SZ8')
	cQuery += ") AS ESTOQUE FROM " + RetSQLTab('ZZ3')
    cQuery += " INNER JOIN " + RetSQLTab('ZZ4') + " (NOLOCK) ON (ZZ4_PRECAR = ZZ3_NUM)"
    cQuery += " INNER JOIN " + RetSQLTab('ZZ5') + " (NOLOCK) ON (ZZ5_NUM = ZZ4_NUM)"
	cQuery += " INNER JOIN " + RetSQLTab('SB1') + " (NOLOCK) ON (ZZ5_COD = B1_COD)"
	cQuery += " INNER JOIN " + RetSQLTab('SBM') + " (NOLOCK) ON (B1_GRUPO = BM_GRUPO)"
	cQuery += " WHERE " + RetSQLFil('ZZ3') + " AND " + RetSQLFil('ZZ4') + " AND " + RetSQLFil('ZZ5') + " AND " + RetSQLFil('SB1') + " AND " + RetSQLFil('SBM')
	cQuery += " AND (ZZ3_DTCAR BETWEEN '" + DTOS(mv_par01) + "' AND '" + DTOS(mv_par02) + "')"
	cQuery += " AND ZZ3_STATUS <> 'F'"
	cQuery += " AND ZZ3_STPCK <> 'B'"
	cQuery += " AND B1_SEGUM <> 'PC'"
	if mv_par04 = 1
		cQuery += " AND B1_GRUPO IN (" + _cGrupo + ")"
	elseif mv_par04 = 2
		cQuery += " AND B1_GRUPO NOT IN (" + _cGrupo + ")"
		cQuery += " AND B1_COD NOT IN (" + _cProdZaf + ")" // Produtos Zaffari
	endif
	if mv_par05 = 1
		cQuery += " AND BM_FARM = 'C'"
    elseif mv_par05 = 2
		cQuery += " AND BM_FARM = 'R'"
    elseif mv_par05 = 3
		cQuery += " AND BM_FARM = 'S'"
    endif
	cQuery += " AND " + RetSQLDel('ZZ3') + " AND " + RetSQLDel('ZZ4') + " AND " + RetSQLDel('ZZ5') + " AND " + RetSQLDel('SB1') + " AND " + RetSQLDel('SBM')
    cQuery += " GROUP BY ZZ3_NUM, ZZ3_DTCAR, ZZ3_OBS, ZZ5_COD, ZZ3_STATUS"
	cQuery += " ORDER BY ZZ3_DTCAR, ZZ3_NUM, ZZ5_COD"

	cQuery  := ChangeQuery(cQuery)

	//	* Mostrar a consulta */
	//@ 116,090 To 416,707 Dialog oDlgMemo Title "Consulta"
	//@ 055,005 Get cQuery Size 250,080 MEMO Object oMemo
	//Activate Dialog oDlgMemo

	If Select("CAR") != 0
		CAR->(dbCloseArea())
	Endif

	TCQUERY cQuery NEW ALIAS "CAR"

return
