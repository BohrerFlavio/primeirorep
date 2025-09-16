#INCLUDE "rwmake.ch"
#INCLUDE "topconn.ch"
#INCLUDE "totvs.ch"

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³DTI160    ºAutor  ³Adonai Gabriel      º Data ³  12/12/22   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³   Relatorio para conferencia de total de Descontos e       º±±
±±º          ³   Acrescimos por Representante                             º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ Comercial                                                  º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/

User Function DTI160()
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Declaracao de Variaveis                                             ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ

	Local cDesc1         := "Este programa tem como objetivo imprimir relatorio para"
	Local cDesc2         := "conferencia dos valores de desconto e acrescimo dos pre-pedidos"
	Local cDesc3         := "faturados contidos entre as datas de carreg. para um representante"
	Local titulo         := "RELATORIO DE DESC/ACRESC POR REPRESENTANTE"
	Local cabec1         := ""
	Local cabec2         := ""
	Local aOrd           := {}
	Private nlin         := 80
	Private lEnd         := .F.
	Private lAbortPrint  := .F.
	Private CbTxt        := ""
	Private limite       := 220
	Private tamanho      := "G"
	Private nomeprog     := "DTI160" // Coloque aqui o nome do programa para impressao no cabecalho
	Private nTipo        := 18
	Private aReturn      := { "Zebrado", 1, "Administracao", 2, 2, 1, "", 1}
	Private nLastKey     := 0
	Private cPerg   	 := "DTI160"
	Private cbcont       := 00
	Private CONTFL       := 01
	Private m_pag        := 01
	Private wnrel        := "DTI160" // Coloque aqui o nome do arquivo usado para impressao em disco 
	pergunte(cPerg,.F.)

	wnrel := SetPrint('ZZ3',NomeProg,cPerg,@titulo,cDesc1,cDesc2,cDesc3,.T.,aOrd,.T.,Tamanho,,.T.)

	MsgRun("Aguarde... Realizando contagem de registros...",,{||  GeraTMP() })

	cabec1 += 'Carregamentos do período de ' + dtoc(mv_par01) + ' até ' + dtoc(mv_par02)

	If nLastKey == 27
		Return
	Endif

	SetDefault(aReturn,'ZZ3')

	If nLastKey == 27
		Return
	Endif

	nTipo := If(aReturn[4]==1,15,18)

	if mv_par05 = 1
		cabec2 += "                Cod.Cli./Loja         Cliente        Cod.Prod.         Produto         Peso(kg) Prç.(R$) Tp.Boni. Boni.(R$) Prç.F.(R$)  Total Boni.(R$)"
	endif

	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Processamento. RPTSTATUS monta janela com a regua de processamento. ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ

	RptStatus({|| RunReport(cabec1,cabec2,Titulo,nlin) },Titulo)
Return

Static Function RunReport(cabec1,cabec2,Titulo,nlin)

	Cabec(Titulo,cabec1,cabec2,NomeProg,Tamanho,nTipo)
	nlin := 9

	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ SETREGUA -> Indica quantos registros serao processados para a regua ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ

	TMP1->(SetRegua(RecCount()))

	TMP1->(dbGoTop())
	_dData 	  := ""
	_cNum 	  := ""
	_nTotDesc  := 0
	_nTotAcres := 0
	_cLojaCli  := ""

	While TMP1->(!EOF())

		incregua()

		If lAbortPrint
			@nlin,00 PSAY "*** CANCELADO PELO OPERADOR ***"
			Exit
		Endif

		If nlin > 70 // Salto de Página. Neste caso o formulario tem 55 linhas...
			Cabec(Titulo,cabec1,cabec2,NomeProg,Tamanho,nTipo)
            nlin := 9
		Endif

		if nlin = 9
			@nlin,01 psay replicate('-', limite)
            nlin++
            @nlin,05 psay "Representante: " + alltrim(TMP1->ZZ4_NOMREP) + " (" + alltrim(TMP1->ZZ4_REPRES) + ")"
            nlin++
            @nlin,01 psay replicate('-', limite)
			nlin++
		endif

		if mv_par05 = 1 //se for analitico
			_cNomeCli := GetAdvFVal('SA1','A1_NOME',FWxfilial('SA1')+alltrim(TMP1->ZZ4_CODCLI)+alltrim(TMP1->ZZ4_LOJA),1)
			@nlin,05 psay stod(TMP1->ZZ3_DTCAR)
			@nlin,17 psay TMP1->ZZ4_CODCLI + " / " + TMP1->ZZ4_LOJA
			@nlin,31 psay alltrim(substr(_cNomeCli,1,20))
			@nlin,54 psay alltrim(TMP1->ZZ5_COD)
			@nlin,64 psay substr(TMP1->ZZ5_DESC,1,20)
			@nlin,84 psay transform(TMP1->ZZ5_QRPESO,'@E 999,999.99')
			@nlin,97 psay transform(TMP1->ZZ5_PRECO,'@E 999.99')
			_nDesc := TMP1->ZZ5_BONIF 

			if TMP1->ZZ5_TPBONI = 'D'
				@nlin,105 psay 	'Desconto'
				_nDesc *= -1
			else 
				@nlin,105 psay 	'Acrescimo'
			endif
			@nlin,115 psay transform(TMP1->ZZ5_BONIF,'@E 999.99')
			@nlin,125 psay transform((TMP1->ZZ5_PRECO + _nDesc),'@E 999.99')
			@nlin,138 psay transform(TMP1->DESAC,'@E 999,999.99')
			nlin++
		endif

		if TMP1->ZZ5_TPBONI = 'D'
			_nTotDesc += TMP1->DESAC
		elseif TMP1->ZZ5_TPBONI = 'A'
			_nTotAcres += TMP1->DESAC
		endif

		TMP1->(dbSkip()) // Avanca o ponteiro do registro no arquivo
	EndDo

	if mv_par04 = 2

		@nlin,01 psay replicate('.', limite)
		nlin++
		cabec2 := "                     Motivo                                                Total Boni.(R$)"

		TMP2->(SetRegua(RecCount()))

		TMP2->(dbGoTop())

		While TMP2->(!EOF())

			incregua()

			If lAbortPrint
				@nlin,00 PSAY "*** CANCELADO PELO OPERADOR ***"
				Exit
			Endif

			If nlin > 70 // Salto de Página. Neste caso o formulario tem 55 linhas...
				Cabec(Titulo,cabec1,cabec2,NomeProg,Tamanho,nTipo)
				nlin := 9
			Endif

			if nlin = 9
				@nlin,01 psay replicate('-', limite)
				nlin++
				@nlin,05 psay "Representante: " + alltrim(TMP2->ZCC_NOMREP) + " (" + alltrim(TMP2->ZCC_REPRES) + ")"
				nlin++
				@nlin,01 psay replicate('-', limite)
				nlin++
			endif

			if mv_par05 = 1 //se for analitico
				@nlin,05 psay stod(TMP2->ZCC_DATA)
				@nlin,20 psay alltrim(TMP2->ZCC_MOTIV)
				@nlin,75 psay transform(TMP2->ZCC_VALOR,'@E 999,999.99')
				nlin++
			endif

			if TMP2->ZCC_TPBONI = 'D'
				_nTotDesc += TMP2->ZCC_VALOR
			elseif TMP2->ZCC_TPBONI = 'A'
				_nTotAcres += TMP2->ZCC_VALOR
			endif

			TMP2->(dbSkip()) // Avanca o ponteiro do registro no arquivo
		enddo

	endif

	@nlin,01 psay replicate('=', limite)
    nlin++
	@nlin,123 psay 'Acrescimo: ' + transform(_nTotAcres,'@E 999,999,999.99')
	nlin++
	@nlin,123 psay 'Desconto:  '  + transform(_nTotDesc,'@E 999,999,999.99')
	nlin++
	@nlin,123 psay 'Saldo:     ' + transform((_nTotAcres-_nTotDesc),'@E 999,999,999.99')
	nlin++
	@nlin,01 psay replicate('=', limite)

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

	_cQuery := "SELECT DISTINCT ZZ3_DTCAR, ZZ5_NUM, ZZ5_COD, ZZ5_DESC, ZZ5_TPBONI, ZZ5_QRPESO, ZZ5_BONIF, ZZ5_PRECO, ZZ4_CODCLI, ZZ4_LOJA,"
	_cQuery += " ZZ4_NOMREP, ZZ4_REPRES, (ZZ5_QRPESO * ZZ5_BONIF) AS DESAC"
	_cQuery += " FROM " + retSqlTab('ZZ3')
	_cQuery += " INNER JOIN " + retSqlTab('ZZ4') + " ON (ZZ3_NUM = ZZ4_PRECAR)"
	_cQuery += " INNER JOIN " + retSqlTab('ZZ5') + " ON (ZZ4_NUM = ZZ5_NUM)"
	_cQuery += " WHERE " + retSqlFil('ZZ3') + " AND " + retSqlFil('ZZ4') + " AND " + retSqlFil('ZZ5')
	_cQuery += " AND ZZ5_TPBONI IN ('D','A') AND ZZ5_QRPESO > 0 AND ZZ5_BONIF > 0"
	_cQuery += " AND ZZ4_STATUS = 'F' AND ZZ3_DTCAR BETWEEN '" + dtos(mv_par01) + "' AND '" + dtos(mv_par02) + "'"
    _cQuery += " AND ZZ4_REPRES = '" + mv_par03 + iif(mv_par04 = 2, "' AND ZZ5_CCOR = '1'", "' AND ZZ5_CCOR <> '1'")
	_cQuery += " AND " + retSqlDel('ZZ3') + " AND " + retSqlDel('ZZ4') + " AND " + retSqlDel('ZZ5')
	_cQuery += " GROUP BY ZZ3_DTCAR, ZZ5_NUM, ZZ5_COD, ZZ5_DESC, ZZ5_TPBONI, ZZ5_QRPESO, ZZ5_BONIF, ZZ5_PRECO, ZZ4_CODCLI, ZZ4_LOJA, ZZ4_NOMREP, ZZ4_REPRES"
	_cQuery += " ORDER BY ZZ3_DTCAR, ZZ5_NUM"

	_cQuery  := ChangeQuery(_cQuery)

	If Select("TMP1") != 0
		TMP1->(dbCloseArea())
	Endif

	TCQUERY _cQuery NEW ALIAS "TMP1"

	if mv_par04 = 2
		//Query2 para buscar da tabela de conta corrente
		cQuery2 := "SELECT ZCC_REPRES, ZCC_NOMREP, ZCC_TPBONI, ZCC_VALOR, ZCC_MOTIV, ZCC_DATA"
		cQuery2 += " FROM " + retSqlTab('ZCC')
		cQuery2 += " WHERE " + retSqlFil('ZCC')
		cQuery2 += " AND ZCC_DATA BETWEEN '" + dtos(mv_par01)+"' AND '"+ dtos(mv_par02) + "'"
		cQuery2 += " AND ZCC_TPBONI IN ('D','A')"
		cQuery2 += " AND ZCC_REPRES = '" + mv_par03 + "'"
		cQuery2 += " AND " + retSqlDel('ZCC')
		cQuery2 += " ORDER BY ZCC_NUM

		cQuery2 := ChangeQuery(cQuery2)

		if Select("TMP2") != 0
			TMP2->(dbCloseArea())
		endif

		TCQUERY cQuery2 NEW ALIAS "TMP2"
	endif

return
