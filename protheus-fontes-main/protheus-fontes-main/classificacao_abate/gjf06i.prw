#INCLUDE "rwmake.ch"
#INCLUDE "totvs.ch"
#INCLUDE "topconn.ch"

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³ GJF06I    º Autor ³ Adonai Gabriel     º Data ³  25/09/24  º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDescricao ³ Relatorio de produções especiais do Abate para a IF        º±±
±±º          ³                                                            º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ IF (SIGAPCP)                                               º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/

User Function GJF06I()

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
	Local Cabec2         := "           Sequencial     Destino     Classif.    IF?     Câmara"
	//Local imprime        := .T.
	Local aOrd           := {}
	Private lEnd         := .F.
	Private lAbortPrint := .F.
	Private CbTxt       := ""
	Private limite      := 132
	Private tamanho     := "M"
	Private nomeprog    := "GJF06I" // Coloque aqui o nome do programa para impressao no cabecalho
	Private nTipo       := 18
	Private aReturn     := { "Zebrado", 1, "Administracao", 2, 2, 1, "", 1}
	Private nLastKey    := 0
	Private cPerg   	:= "GJF06I"
	//Private cbtxt       := Space(10)
	Private cbcont      := 00
	Private CONTFL      := 01
	Private m_pag       := 01
	Private wnrel       := "GJF06I" // Coloque aqui o nome do arquivo usado para impressao em disco
	Private TotCaix     := 0.00
	Private TotPeso     := 0.00

	pergunte(cPerg,.F.)

	wnrel := SetPrint('SZK',NomeProg,cPerg,@titulo,cDesc1,cDesc2,cDesc3,.T.,aOrd,.T.,Tamanho,,.T.)

	cQuery := " SELECT ZK_NUMAM AS NUMAM, ZK_LOTE AS LOTE, ZK_CONTROL AS CONTROL, ZK_RASTRO AS RASTRO, ZK_DESTINO AS DESTINO,"
	cQuery += " ZK_CLASSIF AS CLASSIF, ZK_IF AS DIF, ZK_LOCAL AS CAMARA"
	cQuery += " FROM  " + RetSqlTab('SZK') + " (NOLOCK)"
	cQuery += " WHERE " + REtSQLFil('SZK') + " AND" 
	cQuery += " ZK_NUMAM = '" + mv_par01 + "' AND "
    cQuery += " (ZK_LOTE BETWEEN '" + mv_par02 + "' AND '" + mv_par03 + "')"

    if mv_par04 = 1
		cQuery += " AND ZK_IF = 'S'"
	elseif mv_par04 = 2
		cQuery += " AND ZK_IF = ' '"
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
	Local _cDest  := ''
	Local _nQuant := 0.0
	Local _nUSA := 0.0, _nHK := 0.0, _nBR := 0.0, _nNE := 0.0

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
			@nlin,00 psay replicate('-',limite)
			nlin++
			@nlin,01 psay 'Lote nr.: ' + ABT->LOTE
			_cLote := ABT->LOTE
			nlin++
			@nlin,00 psay replicate('-',limite)
			nlin++
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
			otherwise
			_cDest := ''
		EndCase

		Do Case
			case AllTrim(ABT->CLASSIF) = 'USA'
			_nUSA++
			case AllTrim(ABT->CLASSIF) = 'HK'
			_nHK++
			case AllTrim(ABT->CLASSIF) = 'BR'
			_nBR++
			case AllTrim(ABT->CLASSIF) = 'NE'
			_nNE++
		Endcase

        @nlin,012 psay ABT->CONTROL
        @nlin,026 psay _cDest
        @nlin,040 psay AllTrim(ABT->CLASSIF)
        @nlin,050 psay iif(ABT->DIF = 'S','Sim','Nao')
        @nlin,060 psay ABT->CAMARA

        nlin++

		_nQuant++

		ABT->(dbSkip()) // Avanca o ponteiro do registro no arquivo

	EndDo

	If nLin > 70 // Salto de Página. Neste caso o formulario tem 75 linhas...
		Cabec(Titulo,Cabec1,Cabec2,NomeProg,Tamanho,nTipo)
		nLin := 9
	Endif

	nlin++

	@nlin,00 psay replicate('=',limite)
	nlin++
	@nlin,005 psay 'Quantidade total de animais abatidos:   ' + transform(_nQuant,'@E 9,999')
	nlin++

	if _nUSA <> 0
		@nlin,005 psay 'Animais classificação USA:  ' + transform(_nUSA,'@E 9,999')
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
