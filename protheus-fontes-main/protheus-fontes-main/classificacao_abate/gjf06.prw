#INCLUDE "rwmake.ch"
#INCLUDE "topconn.ch"

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³GJF06   º Autor ³ Giuliano Forgiarini  º Data ³  07/10/09   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDescricao ³ Relatorio de produções especiais do Abate                  º±±
±±º          ³                                                            º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ Comercial e expedições (SIGAPCP e SIGAOMS)                 º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/

User Function GJF06()

	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Declaracao de Variaveis                                             ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ

	Local cDesc1         := "Este programa tem como objetivo imprimir relatorio  "
	Local cDesc2         := "de produção analitico do abate, mediante parametros  "
	Local cDesc3         := "apontados pelo usuário"
	//Local cPict          := ""
	Local titulo       	 := "ANALISE DE PRODUCAO DO ABATE"
	Local nLin         	 := 80
	Local Cabec1         := " Aviso de Matança e Lote "
	Local Cabec2         := "           Sequencial     Peso      Gord.  Dent.   Conf.     Destino     Hora     Classif.  IF?      Programa   Cntsao? Cntmina? Regiao"
	//Local imprime        := .T.
	Local aOrd           := {}
	Private lEnd         := .F.
	Private lAbortPrint := .F.
	Private CbTxt       := ""
	Private limite      := 132
	Private tamanho     := "M"
	Private nomeprog    := "GJF06" // Coloque aqui o nome do programa para impressao no cabecalho
	Private nTipo       := 18
	Private aReturn     := { "Zebrado", 1, "Administracao", 2, 2, 1, "", 1}
	Private nLastKey    := 0
	Private cPerg   	:= "GJF06"
	//Private cbtxt       := Space(10)
	Private cbcont      := 00
	Private CONTFL      := 01
	Private m_pag       := 01
	Private wnrel       := "GJF06" // Coloque aqui o nome do arquivo usado para impressao em disco
	Private TotCaix     := 0.00
	Private TotPeso     := 0.00

	pergunte(cPerg,.F.)

	wnrel := SetPrint('SZK',NomeProg,cPerg,@titulo,cDesc1,cDesc2,cDesc3,.T.,aOrd,.T.,Tamanho,,.T.)

	cQuery := " SELECT ZK_NUMAM AS NUMAM, ZK_LOTE AS LOTE, ZK_CONTROL AS CONTROL, ZK_RASTRO AS RASTRO, ZK_PETOTAL AS PETOTAL, ZK_HORA AS HORA,"
	cQuery += " ZK_COBGOR AS COBGOR, ZK_DENT AS DENT, ZK_CONFORM AS CONFORM, ZK_DESTINO AS DESTINO, ZK_CLASSIF AS CLASSIF, ZK_IF AS DIF, ZK_RACA AS RACA,"
	cQuery += " ZK_PROGRAM AS PROGRAM, ZK_BLACK AS BLACK, ZK_CONTUSA AS CONTUSAO, ZK_CNTMINA AS CONTAMINA, ZK_REGICTS AS REGIAO, ZK_BRINCO AS BRINCO"
	cQuery += " FROM  " + RetSqlTab('SZK') + " (NOLOCK)"
	cQuery += " WHERE " + REtSQLFil('SZK') + " AND" 
	cQuery += " ZK_NUMAM = '" + mv_par01 + "' AND "
	cQuery += " (ZK_LOTE BETWEEN '" + mv_par02 + "' AND '" + mv_par03 + "')"
	cQuery += " AND ZK_CONTROL <> '' "

	if !empty(mv_par04)
		if mv_par04 $ "006/021"
			cQuery += " AND ZK_PROGRAM IN ('006','021')"
		elseif mv_par04 $ "002/022"
			cQuery += " AND ZK_PROGRAM IN ('002','022')"
		else
			cQuery += " AND ZK_PROGRAM = '" + mv_par04 + "'"
		endif
	endif

	if !empty(mv_par05)
		cQuery += " AND ZK_CATEG = '" + mv_par05 + "'"
	endif

	if mv_par06 = 1
		cQuery += " AND ZK_RASTRO <> ' '"
	elseif mv_par06 = 2
		cQuery += " AND ZK_RASTRO = ' '"
	endif

	IF !empty(mv_par07)
		cQuery += " AND ZK_RACA = '" + mv_par07 + "'"
	EndIf

	if mv_par08 = 1
		cQuery += " AND ZK_BLACK = 'N'"
	elseif mv_par08 = 2
		cQuery += " AND ZK_BLACK = 'S'"
	endif 

	cQuery += " AND " + RetSQLDel('SZK')

	cQuery += "ORDER BY ZK_NUMAM, ZK_LOTE, ZK_CONTROL"

	cQuery := ChangeQuery(cQuery)

	//	* Mostrar a consulta */
	//@ 116,090 To 416,707 Dialog oDlgMemo Title "Consulta"
	//@ 055,005 Get cQuery Size 250,080 MEMO Object oMemo
	//Activate Dialog oDlgMemo
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Monta a interface padrao com o usuario...                           ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ

	IF mv_par12 = 1
		Cabec2         := "           Sequencial     Peso      Gord.  Dent.   Conf.     Destino     Hora     Classif.  IF?      Programa   Cntsao? Cntmina? Regiao"
	else	
		Cabec2         := "           Sequencial     Peso      Codigo do Brinco         Destino     Hora     Classif.  IF?      Programa   Cntsao? Cntmina? Regiao"
	ENDIF


	If Select("ABT") != 0
		ABT->(dbCloseArea())
	Endif
	TCQUERY cQuery NEW ALIAS "ABT"

	If nLastKey == 27
		Return
	Endif

	SetDefault(aReturn,'SZK')

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

	Local _cNumam := ''
	Local _cLote  := ''
	Local _cConf  := ''
	Local _cDest  := ''
	Local _nPesoT := 0.0
	Local _nQuant := 0.0
	Local _nPesLo := 0.0
	Local _nQntLo := 0.0
	Local _nPesoP := 0.0
	Local _nUSA := 0.0, _nRT := 0, _nHK := 0.0, _nBR := 0.0, _nNE := 0.0

	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ SETREGUA -> Indica quantos registros serao processados para a regua ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ

	ABT->(dbGoTop())
	ABT->(SetRegua(RecCount()))

	While ABT->(!EOF())

		incregua()

		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³ Verifica o cancelamento pelo usuario...                             ³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ

		If lAbortPrint
			@nLin,00 PSAY "*** CANCELADO PELO OPERADOR ***"
			Exit
		Endif

		If nLin > 75 // Salto de Página. Neste caso o formulario tem 75 linhas...
			Cabec(Titulo,Cabec1,Cabec2,NomeProg,Tamanho,nTipo)
			nLin := 9
		Endif   

		if _cNumam <> ABT->NUMAM
			@nlin,01 psay ABT->NUMAM + '   Abate do dia:  ' + dtoc(GetAdvFVal('SZG','ZG_DATA',FWxfilial('SZG')+ABT->NUMAM,1))
			_cNumam := ABT->NUMAM
			nlin++
		endif

		if _cLote <> ABT->LOTE
			if !empty(_cLote)
				nlin++
				@nlin,005 psay 'Peso total do lote:      ' + transform(_nPesLo,'@E 999,999.999')
				nlin++
				@nlin,005 psay 'Peso médio do lote:      ' + transform(_nPesLo/_nQntLo,'@E 999,999.999')
				nlin++
			endif
			@nlin,00 psay replicate('-',limite)
			nlin++
			@nlin,01 psay 'Lote nr.: ' + ABT->LOTE
			_cLote := ABT->LOTE
			_nQntLo := 0.0
			_nPesLo := 0.0
			nlin++
			@nlin,00 psay replicate('-',limite)
			nlin++
		endif

		Do Case
			case ABT->CONFORM = '1'
			_cConf := 'CNX'
			case ABT->CONFORM = '2'
			_cConf := 'RET'
			case ABT->CONFORM = '3'
			_cConf := 'CNV'
			otherwise
			_cConf := ''
		EndCase

		Do Case
			case ABT->DESTINO = 'C'
			_cDest := 'Camara'
			case ABT->DESTINO = 'R'
			_cDest := 'Conserva'
			case ABT->DESTINO = 'G'
			_cDest := 'Graxaria'
			case ABT->DESTINO = 'T'
			_cDest := 'TF' // (Tratamento pelo frio)
			case ABT->DESTINO = 'I'
			_cDest := 'IF'
			case ABT->DESTINO = 'S'
			_cDest := 'TS' // (tratamento por salga)
			otherwise
			_cDest := ''
		EndCase

		Do Case
			case AllTrim(ABT->CLASSIF) = 'USA'
			_nUSA++
			case AllTrim(ABT->CLASSIF) = 'RT'
			_nRT++
			case AllTrim(ABT->CLASSIF) = 'HK'
			_nHK++
			case AllTrim(ABT->CLASSIF) = 'BR'
			_nBR++
			case AllTrim(ABT->CLASSIF) = 'NE'
			_nNE++
		Endcase

		//_cRaca := GetAdvFVal('ZA8','ZA8_DESC',FWxFilial('ZA8')+_ZK_RACA,1)
		if ABT->BLACK = 'S'
			_cProgram := alltrim(GetAdvFVal('SZ6','Z6_DESC',FWxFilial('SZ6') + ABT->PROGRAM,1))
			_cProgram := "BL-" + _cProgram
		else
			_cProgram := alltrim(GetAdvFVal('SZ6','Z6_DESC',FWxFilial('SZ6') + ABT->PROGRAM,1))
		endif
		//_nPesoP := ABT->PETOTAL * 0.98
		if ABT->DIF = 'S' .and. mv_par10 = 2
			_nPesoP := ABT->PETOTAL * 0.92
		else
			_nPesoP := ABT->PETOTAL
		endif

		GeraTMP(ABT->NUMAM, ABT->CONTROL)

		if TMP->(!eof())
			@nlin,009 psay ABT->CONTROL
			@nlin,022 psay transform(_nPesoP,'@E 999.99')
			IF mv_par12 = 1
				@nlin,034 psay ABT->COBGOR
				@nlin,041 psay ABT->DENT
				@nlin,048 psay _cConf
			else	
				@nlin,034 psay ABT->BRINCO
			Endif
			@nlin,058 psay _cDest
			@nlin,070 psay ABT->HORA
			@nlin,081 psay AllTrim(ABT->CLASSIF)
			@nlin,089 psay iif(ABT->DIF = 'S','Sim','Nao')
			@nlin,098 psay _cProgram
			@nlin,115 psay iif(ABT->CONTUSAO = 'S', 'Sim','Nao')
			@nlin,122 psay iif(ABT->CONTAMINA = 'S', 'Sim','Nao')
			@nlin,127 psay iif(ABT->REGIAO = 'P','Peito',;
			iif(ABT->REGIAO = 'C','Costela',;
			iif(ABT->REGIAO = 'R','Reto',;
			iif(ABT->REGIAO = 'O','Diant.',;
			iif(ABT->REGIAO = 'T','Trasei.',;
			iif(ABT->REGIAO = 'B','Bile',''))))))

			nlin++
		endif

		if mv_par09 = 1
			while TMP->(!eof())

				@nlin,015 psay TMP->ZAJ_NUM
				@nlin,027 psay TMP->ZAJ_DESCRI
				if empty(TMP->ZAJ_PRECAR)
					@nlin,047 psay 'OP Desossa : '+ TMP->ZAJ_PREDES
				else
					@nlin,047 psay 'Carregamento : '+ TMP->ZAJ_PRECAR
				endif
				nlin++

				TMP->(DbSkip())
			enddo
			//nlin++
		Endif

		_nQuant++
		_nPesoT += _nPesoP
		_nQntLo++
		_nPesLo += _nPesoP

		ABT->(dbSkip()) // Avanca o ponteiro do registro no arquivo

	EndDo

	If nLin > 70 // Salto de Página. Neste caso o formulario tem 75 linhas...
		Cabec(Titulo,Cabec1,Cabec2,NomeProg,Tamanho,nTipo)
		nLin := 9
	Endif

	nlin++
	@nlin,005 psay 'Peso total do lote:      ' + transform(_nPesLo,'@E 999,999.999')
	nlin++
	@nlin,005 psay 'Peso médio do lote:      ' + transform(_nPesLo/_nQntLo,'@E 999,999.999')
	nlin++

	nlin++

	@nlin,00 psay replicate('=',limite)
	nlin++
	@nlin,005 psay 'Quantidade total de animais abatidos:   ' + transform(_nQuant,'@E 9,999')
	nlin++

	if _nUSA <> 0
		@nlin,005 psay 'Animais classificação USA:  ' + transform(_nUSA,'@E 9,999')
		nlin++
	endif

	if _nRT <> 0
		@nlin,005 psay 'Animais classificação RT:   ' + transform(_nRT,'@E 9,999')
		nlin++
	endif

	if _nHK <> 0 
		@nlin,005 psay 'Animais classificação HK:   ' + transform(_nHK,'@E 9,999')
		nlin++
	endif

	if _nBR <> 0
		@nlin,005 psay 'Animais classificação BR:   ' + transform(_nBR,'@E 9,999')
		nlin++
	endif

	if _nNE <> 0
		@nlin,005 psay 'Animais classificação NE:   ' + transform(_nNE,'@E 9,999')
		nlin++
	endif

	@nlin,005 psay 'Peso total dos animais abatidos:      ' + transform(_nPesoT,'@E 999,999.999')

	nlin++

	@nlin,005 psay 'Peso médio dos animais abatidos:      ' + transform(_nPesoT/_nQuant,'@E 999,999.999')
	nlin++
	@nlin,00 psay replicate('=',limite)

	//ÚÄn ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
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


Static Function GeraTMP(_Numan, _Contro)

	_cQuery2 := "SELECT ZAJ_NUMAM, ZAJ_NUM, ZAJ_PREDES, ZAJ_DESCRI, ZAJ_PRECAR"
	_cQuery2 += " FROM  " + RetSQLTab('ZAJ') + " (NOLOCK)"
	_cQuery2 += " WHERE " + RetSQLFil('ZAJ')
	_cQuery2 += " AND ZAJ_NUMAM = '" + _Numan + "'"
	_cQuery2 += " AND ZAJ_CONTRO = '" + _Contro + "'"
	_cQuery2 += " AND ZAJ_PRECAR <> 'ACERTO'"
	if mv_par11 = 1
		_cQuery2 += " AND (ZAJ_PREDES <> '' OR ZAJ_COD = '005018')"
	elseif mv_par11 = 2
		_cQuery2 += " AND (ZAJ_PREDES = '' AND ZAJ_COD IN ('005016','005020'))"
	endif
	_cQuery2 += " AND " + RetSQLDel('ZAJ')
	_cQuery2 += " ORDER BY ZAJ_NUM"

	_cQuery2  := ChangeQuery(_cQuery2)

	//	* Mostrar a consulta */
	//@ 116,090 To 416,707 Dialog oDlgMemo Title "Consulta"
	//@ 055,005 Get _cQuery2 Size 250,080 MEMO Object oMemo
	//Activate Dialog oDlgMemo

	If Select("TMP") != 0
		TMP->(dbCloseArea())
	Endif

	TCQUERY _cQuery2 NEW ALIAS "TMP"

	TMP->(dbGoTop())

return
