#INCLUDE "rwmake.ch"
#INCLUDE "topconn.ch"
#INCLUDE "protheus.ch"

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³DTI168    ºAutor  ³Adonai Gabriel   º Data ³  14/02/23      º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³  Relatório para conferência de caixas de produto acabado   º±±
±±º          ³  em estoque. Buscando não só da tabela SZ8, mas também     º±±
±±º          ³  na tabela SZV, para visualização do histórico.           º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ SIGAPCP           .                                        º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/

User Function DTI168()
	
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Declaracao de Variaveis                                             ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ

	Local cDesc1         := "Este programa tem como objetivo imprimir um relatorio"
	Local cDesc2         := "para conferência de caixas de produto acabado em"
	Local cDesc3         := "estoque."	
	Local titulo         := "RELATÓRIO PARA CONFERÊNCIA DE PA EM ESTOQUE"
	Local Cabec1         := ""
	Local Cabec2         := ""
	Local aOrd           := {}
	Local param1		 := ""
	Local param2		 := ""
	Local param3		 := ""
	Local param4		 := ""
	Local param5		 := ""
	Local param6		 := ""
	Private nlin         := 80
	Private lEnd         := .F.
	Private lAbortPrint  := .F.
	Private CbTxt        := Space(10)
	Private limite       := 132
	Private tamanho      := "M"
	Private nomeprog     := "DTI168" // Coloque aqui o nome do programa para impressao no cabecalho
	Private nTipo        := 18
	Private aReturn      := { "Zebrado", 1, "Administracao", 2, 2, 1, "", 1}
	Private nLastKey     := 0
	Private cPerg   	 := "DTI168"
	Private cbcont       := 00
	Private CONTFL       := 01
	Private m_pag        := 01
	Private wnrel        := "DTI168" // Coloque aqui o nome do arquivo usado para impressao em disco
	pergunte(cPerg,.F.)

	wnrel := SetPrint('SZ8',NomeProg,cPerg,@titulo,cDesc1,cDesc2,cDesc3,.T.,aOrd,.T.,Tamanho,,.T.)

    MsgRun("Aguarde... Realizando contagem de registros...",,{||  GeraTMP() })

	SetDefault(aReturn,'SZ8')

	If nLastKey == 27
		Return
	Endif

	param1 := iif(mv_par01 = 1, "Todas", iif(mv_par01 = 2, "Congelado", iif(mv_par01 = 3, "Resfriado", "Salgado")))
	param2 := iif(mv_par02 = 1, "Ambos", iif(mv_par03 = 2, "Embalagem", "Porcionados"))
	param3 := iif(mv_par03 = 1, "Sim (Terc.)", "Não (Terc.)")
	param4 := iif(mv_par04 = 1, "Sintético", "Analítico")
	param5 := iif(mv_par05 = 1, "Pré-inventário", "Pós-inventário")
	param6 := iif(mv_par06 = 1, "Não (Hist.)", "Sim (Hist.)")

	if mv_par06 = 1
		Cabec1 += "                             Caixas/Peças         Peso Líq.    Câmara          Localização       Pallet       Encontrada"
	else
		Cabec1 += "                             Caixas/Peças            Data       Hora             Estação        Descrição      Código"
	endif
    Cabec2 += 'Parâmetros: ' + param1 + ", " + param2 + ", " + param3 + ", " + param4 + ", " + param5 + ", " + param6

	nTipo := If(aReturn[4]==1,15,18)

	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Processamento. RPTSTATUS monta janela com a regua de processamento. ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ

	RptStatus({|| RunReport(Cabec1,Cabec2,Titulo,nlin) },Titulo)
Return

Static Function RunReport(Cabec1,Cabec2,Titulo,nlin)
	Cabec(Titulo,Cabec1,Cabec2,NomeProg,Tamanho,nTipo)
	nlin := 9

	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ SETREGUA -> Indica quantos registros serao processados para a regua ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ

	TMP->(SetRegua(RecCount()))

	TMP->(dbGoTop())

	_lIni	  := .F.			// Variável lógica para controle de impressão de total de caixas por produto
	_cCod	  := ''				// Código de produto
	_nCaix	  := 0				// Total de caixas por produto
	_nCaixEnt := 0				// Caixas que entraram em estoque por produto
	_nCaixBai := 0				// Caixas que saíram do estoque por produto
    _nTotCaix := 0				// Total de caixas filtradas
	_nTotEnt  := 0				// Total de caixas que entraram no estoque
	_nTotBaix := 0				// Total de caixas que saíram do estoque

	while TMP->(!EOF())

		incregua()

		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³ Verifica o cancelamento pelo usuario...                             ³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ

		if lAbortPrint
			@nlin,00 PSAY "*** CANCELADO PELO OPERADOR ***"
			Exit
		endif

		if nlin > 80 // Salto de Página. Neste caso o formulario tem 55 linhas...
			Cabec(Titulo,Cabec1,Cabec2,NomeProg,Tamanho,nTipo)
			nlin := 9
		endif

		if mv_par06 = 1
			if _cCod != TMP->Z8_COD
				_cCod := TMP->Z8_COD
				if _lIni
					if mv_par05 = 1
						@nlin,015 psay "Total = " + transform(_nCaix,'@E 999,999') + " caixas em estoque"
						nlin++
					else
						@nlin,015 psay "Total = " + transform(_nCaix,'@E 999,999') + " caixas | Em estoque = " + transform(_nCaixEnt,'@E 999,999') + " caixas | Baixadas = " + transform(_nCaixBai,'@E 999,999') + " caixas"
						nlin++
					endif
				endif
				_cDesc := alltrim(GetAdvFVal('SB1', 'B1_DESC', FWxfilial('SB1')+alltrim(_cCod), 1))
				@nlin,01 psay replicate('-', limite)
				nlin++
				@nlin,05 psay "Produto -> " + alltrim(_cCod) + "  -  " + _cDesc
				nlin++
				@nlin,01 psay replicate('-', limite)
				nlin++
				_nTotCaix += _nCaix
				_nTotEnt += _nCaixEnt
				_nTotBaix += _nCaixBai
				_nCaix := 0
				_nCaixEnt := 0
				_nCaixBai := 0
			endif

			if !_lIni
				_lIni := .T.
			endif

			if mv_par05 = 1
				if empty(TMP->Z8_DATAS)
					_nCaixEnt++
				else
					_nCaixBai++
				endif
			else
				if TMP->Z8_ENCONTR = "S"
					_nCaixEnt++
				elseif TMP->Z8_ENCONTR = "N"
					_nCaixBai++
				endif
			endif

			if mv_par04 = 2
				@nlin,030 psay TMP->Z8_CONTROL
				@nlin,050 psay transform(TMP->Z8_PESO,'@E 999.99')
				@nlin,065 psay TMP->Z8_LOCAL
				@nlin,080 psay TMP->Z8_LOCALIZ
				@nlin,095 psay TMP->Z8_PALLET
				@nlin,110 psay iif(TMP->Z8_ENCONTR = 'N', 'Não', 'Sim')
				nlin++
			endif

			_nCaix++
		else
			if _cCod != TMP->ZV_CODMSG
				_cCod := TMP->ZV_CODMSG
				@nlin,01 psay replicate('-', limite)
				nlin++
				@nlin,05 psay "Código -> " + alltrim(_cCod) + " | Descrição -> " + iif(TMP->ZV_CODMSG = '000021' .or. TMP->ZV_CODMSG = '000036',; 
							"Entrada no estoque", iif(TMP->ZV_CODMSG = '000022' .or. TMP->ZV_CODMSG = '000037', "Saída do estoque", "Em estoque"))
				nlin++
				@nlin,01 psay replicate('-', limite)
				nlin++
				if _cCod = '000022' .or. _cCod = '000037'
					_nTotEnt := _nCaix
					_nTotCaix := _nCaix
				elseif _cCod = '000033'
					_nTotBaix := _nCaix
					_nTotCaix += _nCaix
				endif
				_nCaix := 0
			endif

			@nlin,030 psay TMP->ZV_CONTROL
			@nlin,050 psay dtoc(stod(TMP->ZV_DATA))
			@nlin,065 psay TMP->ZV_HORA
			@nlin,080 psay TMP->ZV_EST
			@nlin,095 psay TMP->ZV_DESC
			@nlin,110 psay TMP->ZV_CODMSG
			nlin++

			_nCaix++
		endif

		TMP->(dbSkip()) // Avanca o ponteiro do registro no arquivo
	end

	if mv_par06 = 1
		_nTotCaix += _nCaix
		_nTotEnt += _nCaixEnt
		_nTotBaix += _nCaixBai

		if mv_par05 = 1
			@nlin,015 psay "Total = " + transform(_nCaix,'@E 999,999') + " caixas em estoque"
			nlin++
		else
			@nlin,015 psay "Total = " + transform(_nCaix,'@E 999,999') + " caixas | Incluídas = " + transform(_nCaixEnt,'@E 999,999') + " caixas | Baixadas = " + transform(_nCaixBai,'@E 999,999') + " caixas"
			nlin++
		endif
	else
		_nTotCaix += _nCaix
	endif

	if mv_par05 = 1
		nlin++
		@nlin,00 psay replicate("=", limite)
		nlin++
		@nlin,015 psay "Total de caixas: " + transform(_nTotCaix, "@E 999,999,999") + " caixas"
		nlin++
		@nlin,015 psay "Caixas em estoque:" + transform(_nTotEnt, "@E 999,999,999") + " caixas"
		nlin++
		@nlin,015 psay "Caixas baixadas: " + transform(_nTotBaix, "@E 999,999,999") + " caixas"
		nlin++
		@nlin,00 psay replicate("=", limite)
	else
		nlin++
		@nlin,00 psay replicate("=", limite)
		nlin++
		@nlin,015 psay "Total de caixas: " + transform(_nTotCaix, "@E 999,999,999") + " caixas"
		nlin++
		@nlin,015 psay "Caixas incluídas:" + transform(_nTotEnt, "@E 999,999,999") + " caixas"
		nlin++
		@nlin,015 psay "Caixas baixadas: " + transform(_nTotBaix, "@E 999,999,999") + " caixas"
		nlin++
		@nlin,00 psay replicate("=", limite)
	endif

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

	if mv_par06 = 1
		cQuery := "SELECT Z8_CONTROL, Z8_COD, Z8_LOCAL, Z8_LOCALIZ, Z8_PALLET, Z8_DATAS, Z8_PESO, Z8_ENCONTR"
		cQuery += " FROM " + retSqlTab('SZ8')
		cQuery += " INNER JOIN " + retSqlTab('SB1') + " (NOLOCK) ON (SZ8.Z8_COD = SB1.B1_COD)"
		cQuery += " INNER JOIN " + retSqlTab('SBM') + " (NOLOCK) ON (SB1.B1_GRUPO = SBM.BM_GRUPO)"
		cQuery += " WHERE " + retSqlFil('SZ8') + " AND Z8_FIL = '" + cFilAnt + "'" + " AND " + retSqlFil('SB1') + " AND " + retSqlFil('SBM')
		if mv_par01 = 2
			cQuery += " AND BM_FARM = 'C'"
			//cQuery += " AND Z8_FARM = 'C'"
		elseif mv_par01 = 3
			cQuery += " AND BM_FARM = 'R'"
			//cQuery += " AND Z8_FARM = 'R'"
		elseif mv_par01 = 4
			cQuery += " AND BM_FARM = 'S'"
			//cQuery += " AND Z8_FARM = 'S'"
		endif
		//cQuery += iif(mv_par02 = 2, " AND Z8_SETPRO = 'E'", iif(mv_par02 = 3, " AND Z8_SETPRO = 'P'", ""))
		cQuery += iif(mv_par02 = 2, " AND Z8_LOTEPOR = ''", iif(mv_par02 = 3, " AND Z8_LOTEPOR <> ''", ""))
		cQuery += iif(mv_par03 = 2, " AND Z8_TERC = ''", "")
		if mv_par05 = 1
			cQuery += " AND Z8_DATAS = ''"
		else
			cQuery += " AND (Z8_DATAS = '' OR Z8_DATAS BETWEEN '" + dtos(mv_par07) + "' AND '" + dtos(mv_par08) + "')"
		endif
		if mv_par09 = 2
			cQuery += " AND Z8_ITEM = ''"
		elseif mv_par09 = 3
			cQuery += " AND (Z8_ITEM = 'INV' AND Z8_DATAS BETWEEN '" + dtos(mv_par07) + "' AND '" + dtos(mv_par08) + "')"
		endif
		cQuery += " AND " + retSqlDel('SZ8') + " AND " + retSqlDel('SB1') + " AND " + retSqlDel('SBM')
		cQuery += " ORDER BY Z8_COD, Z8_CONTROL"
	else
		cQuery := "SELECT ZV_CONTROL, ZV_DATA, ZV_HORA, ZV_EST, ZV_DESC, ZV_CODMSG"
		cQuery += " FROM " + retSqlTab('SZV')
		cQuery += " WHERE " + retSqlFil('SZV')
		if mv_par02 = 2
			cQuery += iif(mv_par09 = 2, " AND ZV_CODMSG IN ('000021')", iif(mv_par09 = 3, " AND ZV_CODMSG IN ('000022')", " AND ZV_CODMSG IN ('000021','000022','000033')"))
		elseif mv_par02 = 3
			cQuery += iif(mv_par09 = 2, " AND ZV_CODMSG IN ('000036')", iif(mv_par09 = 3, " AND ZV_CODMSG IN ('000037')", " AND ZV_CODMSG IN ('000036','000037')"))
		else
			cQuery += iif(mv_par09 = 2, " AND ZV_CODMSG IN ('000021','000036')", iif(mv_par09 = 3, " AND ZV_CODMSG IN ('000022','000037')", " AND ZV_CODMSG IN ('000021','000022','000033','000036','000037')"))
		endif
		cQuery += " AND ZV_DATA BETWEEN " + dtos(mv_par07) + " AND " + dtos(mv_par08)
		cQuery += " AND " + retSqlDel('SZV')
		cQuery += " ORDER BY ZV_CODMSG, ZV_DATA, ZV_HORA"
	endif

	cQuery  := ChangeQuery(cQuery)

	If Select("TMP") != 0
		TMP->(dbCloseArea())
	Endif

	TCQUERY cQuery NEW ALIAS "TMP"

Return
