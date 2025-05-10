#INCLUDE "rwmake.ch"
#INCLUDE "topconn.ch"

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³MLR32  º Autor ³ Mauricio Roehrs  º Data ³    30/01/14	  º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDescricao ³ Relatorio de produções especiais do Abate                  º±±
±±º          ³ Com destino a Inspeção federal                             º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ Comercial e expedições (SIGAPCP e SIGAOMS)                 º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/

User Function MLR32()

	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Declaracao de Variaveis                                             ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	Local cDesc1         := "Este programa tem como objetivo imprimir relatorio  "
	Local cDesc2         := "de produção analitico do abate, mediante parametros  "
	Local cDesc3         := "apontados pelo usuário"
	Local cPict          := ""
	Local titulo       	 := "ANALISE DE PRODUCAO DO ABATE(IF)"
	Local nLin         	 := 80

	Local Cabec1         := " Aviso de Matança e Lote "
	Local Cabec2         :=""
	// "                Sequencial     Peso      Gord.  Dent.   Raça      Destino     Hora     Classif.  IF?      Programa"
	Local imprime        := .T.
	Local aOrd           := {}
	Private lEnd         := .F.
	Private lAbortPrint := .F.
	Private CbTxt       := ""
	Private limite      := 132
	Private tamanho     := "M"
	Private nomeprog    := "MLR32" // Coloque aqui o nome do programa para impressao no cabecalho
	Private nTipo       := 18
	Private aReturn     := { "Zebrado", 1, "Administracao", 2, 2, 1, "", 1}
	Private nLastKey    := 0
	Private cPerg   	:= "MLR14"
	Private cbtxt       := Space(10)
	Private cbcont      := 00
	Private CONTFL      := 01
	Private m_pag       := 01
	Private wnrel       := "MLR32" // Coloque aqui o nome do arquivo usado para impressao em disco
	Private _aClassif   := {}
	Private _aCondena   := {}
	pergunte(cPerg,.F.)


	wnrel := SetPrint('SZK',NomeProg,cPerg,@titulo,cDesc1,cDesc2,cDesc3,.T.,aOrd,.T.,Tamanho,,.T.)

	_cQuery := " SELECT ZK_NUMAM AS NUMAM, ZK_LOTE AS LOTE, ZK_CONTROL AS CONTROL, ZK_PETOTAL AS PETOTAL,"
	_cQuery += " ZK_HORA AS HORA, ZK_COBGOR AS COBGOR, ZK_DENT AS DENT, ZK_DESTINO AS DESTINO, ZK_RACA AS RACA,"
	_cQuery += " ZK_CLASABA AS CLASSIF, ZK_IF AS DIF, ZK_PROGRAM AS PROGRAM, Z4_NOME AS NOME"
	_cQuery += " FROM  " + RetSqlTab('SZK') + " ,   " + RetSQLTab('SZ4')
	_cQuery += " WHERE " + RetSQLFil('SZK') + " AND " + RetSQLFil('SZ4') + " AND"
	_cQuery += " Z4_NUMAM = ZK_NUMAM AND Z4_LOTE = ZK_LOTE AND"
	//_cQuery += " Z4_COMPRA <> '' AND" //linha removida a pedido do Diogo Soccal;
	_cQuery += " ZK_NUMAM =      '" + mv_par01 + "' AND "
	_cQuery += " ZK_LOTE BETWEEN '" + mv_par02 + "' AND '" + mv_par03 + "'"
	if !empty(mv_par04)
		_cQuery += " AND ZK_RACA = '" + mv_par04 +"'"
	endif
	_cQuery += " AND " + RetSQLDel('SZK') + " AND " + RetSQLDel('SZ4')
	_cQuery += " ORDER BY ZK_NUMAM, ZK_LOTE, ZK_CONTROL"

	_cQuery := ChangeQuery(_cQuery)

	//	* Mostrar a consulta */
	//@ 116,090 To 416,707 Dialog oDlgMemo Title "Consulta"
	//@ 055,005 Get _cQuery Size 250,080 MEMO Object oMemo
	//Activate Dialog oDlgMemo

	If Select("ABT") != 0
		ABT->(dbCloseArea())
	Endif

	TCQUERY _cQuery NEW ALIAS "ABT"


	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Monta a interface padrao com o usuario...                           ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ


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

	Local nOrdem
	Local _cNumam := ''
	Local _cLote  := ''
	Local _cConf  := ''
	Local _cDest  := ''
	Local _cRaca  := ''
	Local _nPesoL := 0.00
	Local _nQuant := 0.00
	Local _nPesoP := 0.00
	Local _nPesoP2 := 0.00
	Local _nPesoDesc := 0.00
	Local i
	
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


		If nLin > 65 // Salto de Página. Neste caso o formulario tem 70 linhas...
			Cabec(Titulo,Cabec1,Cabec2,NomeProg,Tamanho,nTipo)
			nLin := 9
		Endif

		_dtAbt 		:= dtoc(fBuscaCPO('SZG',1,xfilial('SZG')+ABT->NUMAM,'ZG_DATA'))
		_cRaca  		:= fBuscaCPO('ZA8',1,xfilial('ZA8')+ABT->RACA,'ZA8_DESC')
		_cPrograma  := fBuscaCPO('SZ6',1,xfilial('SZ6')+ABT->PROGRAM,'Z6_DESC')
		//_nPesoP   := ABT->PETOTAL * 0.98
		_nPesoP2  	:= ABT->PETOTAL

		// Nome Municipio
		_cCodNum  	:= fBuscaCPO('SZE',2,xfilial('SZE')+ABT->NUMAM+ABT->LOTE,'ZE_NUMERO')
		_cNomeMun 	:= fBuscaCPO('SZD',1,xfilial('SZD')+_cCodNum,'ZD_MUN')
		// Fim nome Municipio

		// Nome Estado
		_cCodFor 	:= fBuscaCPO('SZD',1,xfilial('SZD')+_cCodNum,'ZD_FORNECE')
		_cNomeEst   := fBuscaCPO('SA2',1,xfilial('SA2')+_cCodFor,'A2_EST')
		// Fim nome Estado

		// Nome Sexo
		_cSexo   := fBuscaCPO('SZ4',1,xfilial('SZ4')+ABT->NUMAM+ABT->LOTE,'Z4_DESCAT')
		// Fim nome Sexo

		/*

		_cQuery2 := " SELECT ZA3_NUMAM AS NUMAM1, ZA3_LOTE AS LOTE1, ZA3_CODCON AS CODCON,"
		_cQuery2 += " ZA3_QUANT AS QUANT"
		_cQuery2 += " FROM  " + RetSqlTab('ZA3')
		_cQuery2 += " WHERE " + RetSQLFil('ZA3') + " AND "
		_cQuery2 += " ZA3_NUMAM = ABT->NUMAM AND ZA3_LOTE = ABT->LOTE AND"
		_cQuery2 += " AND " + RetSQLDel('ZA3')
		_cQuery2 += " ORDER BY ZA3_NUMAM, ZA3_LOTE, ZA3_CODCON"
		_cQuery2 := ChangeQuery(_cQuery2)


		*/

		if ABT->DIF = 'S'
			if _nPesoP2 > 200
				_nPesoP2 := _nPesoP2 - 20
			elseif _nPesoP2 <=200
				_nPesoP2 := _nPesoP2 - 15
			endif
		endif

		_nPesoDesc  := _nPesoP2 * 0.02
		_nPesoP 		:= _nPesoP2

		_nPos := aScan(_aClassif,{|aVal|aVal[1] = ABT->CLASSIF})

		if _nPos <> 0
			_aClassif[_npos,2]++
			_aClassif[_npos,3]+= (_nPesoP - _nPesoDesc)
		else
			aadd(_aClassif,{ABT->CLASSIF,1,_nPesoP})
		endif


		if _cNumam <> ABT->NUMAM
			@nlin,01 psay ABT->NUMAM + '   Abate do dia:  ' + _dtAbt
			_cNumam := ABT->NUMAM
			nlin++
		endif

		if _cLote <> ABT->LOTE
			@nlin,00 psay replicate('-',132)
			nlin++
			@nlin,01 psay 'Lote nr.: ' + ABT->LOTE
			@nlin,18 psay '- ' + substr(ABT->NOME,1,30)
			@nlin,55 psay _cNomeMun
			@nlin,75 psay _cNomeEst
			_cLote := ABT->LOTE
			nlin++

			_cQuery2 := " SELECT ZA3_DESCON AS DESCON, ZA3_QUANT AS QUANT, ZA3_CODCON AS CODCON"
			_cQuery2 += " FROM  " + RetSqlTab('ZA3')
			_cQuery2 += " WHERE " + RetSQLFil('ZA3') + " AND "
			_cQuery2 += " ZA3_NUMAM = '"+ABT->NUMAM+"' AND ZA3_LOTE = '"+ABT->LOTE+"'"
			_cQuery2 += " AND ZA3_CODCON <> '07/10/11/12/14/15/25/26/100/106/165/202/203/204/220/230/232'"
			_cQuery2 += " AND " + RetSQLDel('ZA3')
			_cQuery2 += " ORDER BY ZA3_NUMAM, ZA3_LOTE"

			_cQuery2 := ChangeQuery(_cQuery2)

			If Select("COND") != 0
				COND->(dbCloseArea())
			Endif

			TCQUERY _cQuery2 NEW ALIAS "COND"

			while COND->(!eof())
				@nlin,15 psay COND->DESCON
				@nlin,55 psay COND->QUANT
				nLin++

				If nLin > 65 // Salto de Página. Neste caso o formulario tem 70 linhas...
					Cabec(Titulo,Cabec1,Cabec2,NomeProg,Tamanho,nTipo)
					nLin := 9
				Endif

				COND->(DbSkip())
			enddo
		endif

		Do Case
			case ABT->DESTINO = 'C'
			_cDest := 'Camara'
			case ABT->DESTINO = 'R'
			_cDest := 'Conserva'
			case ABT->DESTINO = 'G'
			_cDest := 'Graxaria'
			case ABT->DESTINO = 'T'
			_cDest := 'TF'
			case ABT->DESTINO = 'I'
			_cDest := 'IF'
		EndCase

		/*
		@nlin,017 psay ABT->CONTROL
		@nlin,030 psay transform(_nPesoP,'@E 999.99')
		@nlin,042 psay ABT->COBGOR
		@nlin,049 psay ABT->DENT
		@nlin,054 psay substr(_cRaca,1,10)
		@nlin,066 psay _cDest
		@nlin,078 psay ABT->HORA
		@nlin,089 psay ABT->CLASSIF
		@nlin,097 psay iif(ABT->DIF = 'S','Sim','Nao')
		@nlin,106 psay _cPrograma

		nlin++
		*/
		_nPesoL += (_nPesoP - _nPesoDesc)
		_nQuant ++

		ABT->(dbSkip()) // Avanca o ponteiro do registro no arquivo

		if(_cLote <> ABT->LOTE) .or. ABT->(eof())
			nlin++
			@nlin,01 psay "Sexo: "
			@nlin,08 psay _cSexo
			nlin++
			@nlin,01 psay "Quant. Animais do Lote: "
			@nlin,26 psay _nQuant
			nlin++
			@nlin,01 psay "Peso Total do Lote: "
			@nlin,24 psay transform(_nPesoL,'@E 999,999.99')
			nlin++
			_nQuant := 0
			_nPesoL := 0
		endif

	EndDo

	_nTotAni := 0
	_nTotPes := 0


	nlin++
	@nlin,00 psay replicate('-',132)
	nlin++

	for i := 1 to len(_aClassif)
		If nLin > 65 // Salto de Página. Neste caso o formulario tem 70 linhas...
			Cabec(Titulo,Cabec1,Cabec2,NomeProg,Tamanho,nTipo)
			nLin := 9
		Endif
		@nlin,01 psay alltrim(_aClassif[i,1])
		@nlin,04 psay transform(_aClassif[i,2],'@E 999')
		nlin++
		_nTotPes +=   _aClassif[i,3]
		_nTotAni +=   _aClassif[i,2]
	next

	If nLin > 65 // Salto de Página. Neste caso o formulario tem 70 linhas...
		Cabec(Titulo,Cabec1,Cabec2,NomeProg,Tamanho,nTipo)
		nLin := 9
	Endif

	nlin++
	@nlin,01 psay alltrim("Peso total dos Animais abatidos: ")
	@nlin,33 psay transform(_nTotPes,'@E 999,999,999.99')
	nlin++
	@nlin,01 psay "Total de Animais Abatidos: "
	@nlin,37 psay _nTotAni
	nlin+=2


	totalCondenas(mv_par01)
	@nlin,01 psay "Total de Doenças dos Animais Abatidos:"
	nlin++
	TOT->(dbGoTop())
	while TOT->(!eof())

		If nLin > 65 // Salto de Página. Neste caso o formulario tem 70 linhas...
			Cabec(Titulo,Cabec1,Cabec2,NomeProg,Tamanho,nTipo)
			nLin := 9
		Endif

		@nlin,01 psay substr(TOT->DESCRI,1,25)
		@nlin,28 psay transform(TOT->TOTAL,'@E 9999')
		nlin++
		TOT->(DbSkip())
	enddo

	//ÚÄn ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Finaliza a execucao do relatorio...                                 ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ

	DbCloseArea('ABT')

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

static function totalCondenas(_cNumam)

	_cQuery3 := " SELECT ZA3_CODCON, ZA3_DESCON AS DESCRI, SUM(ZA3_QUANT) AS TOTAL"
	_cQuery3 += " FROM  " + RetSqlTab('ZA3')
	_cQuery3 += " WHERE " + RetSQLFil('ZA3') + " AND "
	_cQuery3 += " ZA3_NUMAM = '" + alltrim(_cNumam) + "'"
	_cQuery3 += " AND ZA3_CODCON <> '07/10/11/12/14/15/25/26/100/106/165/202/203/204/220/230/232'"
	_cQuery3 += " AND " + RetSQLDel('ZA3')
	_cQuery3 += " GROUP BY ZA3_CODCON, ZA3_DESCON
	_cQuery3 += " ORDER BY ZA3_DESCON

	_cQuery3 := ChangeQuery(_cQuery3)

	If Select("TOT") != 0
		TOT->(dbCloseArea())
	Endif

	TCQUERY _cQuery3 NEW ALIAS "TOT"

return
