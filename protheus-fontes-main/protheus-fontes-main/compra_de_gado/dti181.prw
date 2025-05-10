#INCLUDE "rwmake.ch"
#INCLUDE "topconn.ch"
#INCLUDE "totvs.ch"

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³ DTI181  º Autor ³ Adonai Gabriel       º Data ³  31/07/23  º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍLÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³ Relatório de Rendimento de peso por lote de abate por      º±±
±±º          ³ intervalo de tempo.                                        º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ PROGEPEC - Frigorifico Silva                               º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/

User Function DTI181()

	//ÃšÃ„Ã„Ã„Ã„Ã„Ã„Ã„Ã„Ã„Ã„Ã„Ã„Ã„Ã„Ã„Ã„Ã„Ã„Ã„Ã„Ã„Ã„Ã„Ã„Ã„Ã„Ã„Ã„Ã„Ã„Ã„Ã„Ã„Ã„Ã„Ã„Ã„Ã„Ã„Ã„Ã„Ã„Ã„Ã„Ã„Ã„Ã„Ã„Ã„Ã„Ã„Ã„Ã„Ã„Ã„Ã„Ã„Ã„Ã„Ã„Ã„Ã„Ã„Ã„Ã„Ã„Ã„Ã„Ã„Â¿
	//Â³ Declaracao de Variaveis                                             Â³
	//Ã€Ã„Ã„Ã„Ã„Ã„Ã„Ã„Ã„Ã„Ã„Ã„Ã„Ã„Ã„Ã„Ã„Ã„Ã„Ã„Ã„Ã„Ã„Ã„Ã„Ã„Ã„Ã„Ã„Ã„Ã„Ã„Ã„Ã„Ã„Ã„Ã„Ã„Ã„Ã„Ã„Ã„Ã„Ã„Ã„Ã„Ã„Ã„Ã„Ã„Ã„Ã„Ã„Ã„Ã„Ã„Ã„Ã„Ã„Ã„Ã„Ã„Ã„Ã„Ã„Ã„Ã„Ã„Ã„Ã„Ã™

	Local cDesc1         := "Este programa tem como objetivo imprimir relatorio  "
	Local cDesc2         := "de rendimento de peso por lote de abate por "
	Local cDesc3         := "intervalo de tempo. "
	Local titulo         := "RENDIMENTO DE PESO POR LOTE"
	Local nlin           := 80
	Local Cabec1         := ""
	Local Cabec2         := ""
	Local aOrd 			 := {}
	Private lEnd         := .F.
	Private lAbortPrint  := .F.
	Private CbTxt        := ""
	Private limite       := 132
	Private tamanho      := "M"
	Private nomeprog     := "DTI181" // Coloque aqui o nome do programa para impressao no cabecalho
	Private nTipo        := 18
	Private aReturn      := { "Zebrado", 1, "Administracao", 2, 2, 1, "", 1}
	Private nLastKey     := 0
	Private cPerg        := "DTI181"
	Private cbcont       := 00
	Private CONTFL       := 01
	Private m_pag        := 01
	Private wnrel        := "DTI181" // Coloque aqui o nome do arquivo usado para impressao em disco
	Private _aDados 	 := {}
	Private _aCabec		 := {}

	pergunte(cPerg,.F.)

	wnrel := SetPrint('SZK',NomeProg,cPerg,@titulo,cDesc1,cDesc2,cDesc3,.T.,aOrd,.T.,Tamanho,,.T.)

    Cabec1 := "Abates de " + dtoc(mv_par01) + " ate " + dtoc(mv_par02)
	Cabec2 := "                          Lote    Categoria   Quantidade   Rendimento de Origem    Rendimento Frigorifico      Quebra de Peso"

	if (!empty(mv_par04) .and. empty(mv_par05)) .or. (empty(mv_par04) .and. !empty(mv_par05))
		while (!empty(mv_par04) .and. empty(mv_par05)) .or. (empty(mv_par04) .and. !empty(mv_par05))
			FWAlertWarning("Informe o código do fornecedor e loja ou deixe ambos em branco!","ATENÇÃO!")
			pergunte(cPerg,.T.)
			if nLastKey = 27
				Return
			endif
		end
	endif

	MsgRun("Aguarde... Realizando contagem de registros...",,{||  GeraQuery()})

	if nLastKey = 27
		Return
	endif

	SetDefault(aReturn,'SZK')

	if nLastKey = 27
		Return
	endif

	nTipo := if(aReturn[4]=1,15,18)

	//ÃšÃ„Ã„Ã„Ã„Ã„Ã„Ã„Ã„Ã„Ã„Ã„Ã„Ã„Ã„Ã„Ã„Ã„Ã„Ã„Ã„Ã„Ã„Ã„Ã„Ã„Ã„Ã„Ã„Ã„Ã„Ã„Ã„Ã„Ã„Ã„Ã„Ã„Ã„Ã„Ã„Ã„Ã„Ã„Ã„Ã„Ã„Ã„Ã„Ã„Ã„Ã„Ã„Ã„Ã„Ã„Ã„Ã„Ã„Ã„Ã„Ã„Ã„Ã„Ã„Ã„Ã„Ã„Ã„Ã„Â¿
	//Â³ Processamento. RPTSTATUS monta janela com a regua de processamento. Â³
	//Ã€Ã„Ã„Ã„Ã„Ã„Ã„Ã„Ã„Ã„Ã„Ã„Ã„Ã„Ã„Ã„Ã„Ã„Ã„Ã„Ã„Ã„Ã„Ã„Ã„Ã„Ã„Ã„Ã„Ã„Ã„Ã„Ã„Ã„Ã„Ã„Ã„Ã„Ã„Ã„Ã„Ã„Ã„Ã„Ã„Ã„Ã„Ã„Ã„Ã„Ã„Ã„Ã„Ã„Ã„Ã„Ã„Ã„Ã„Ã„Ã„Ã„Ã„Ã„Ã„Ã„Ã„Ã„Ã„Ã„Ã™

	RptStatus({|| RunReport(Cabec1,Cabec2,Titulo,nlin) },Titulo)
Return

Static Function RunReport(Cabec1,Cabec2,Titulo,nlin)

	//ÃšÃ„Ã„Ã„Ã„Ã„Ã„Ã„Ã„Ã„Ã„Ã„Ã„Ã„Ã„Ã„Ã„Ã„Ã„Ã„Ã„Ã„Ã„Ã„Ã„Ã„Ã„Ã„Ã„Ã„Ã„Ã„Ã„Ã„Ã„Ã„Ã„Ã„Ã„Ã„Ã„Ã„Ã„Ã„Ã„Ã„Ã„Ã„Ã„Ã„Ã„Ã„Ã„Ã„Ã„Ã„Ã„Ã„Ã„Ã„Ã„Ã„Ã„Ã„Ã„Ã„Ã„Ã„Ã„Ã„Â¿
	//Â³ SETREGUA -> Indica quantos registros serao processados para a regua Â³
	//Ã€Ã„Ã„Ã„Ã„Ã„Ã„Ã„Ã„Ã„Ã„Ã„Ã„Ã„Ã„Ã„Ã„Ã„Ã„Ã„Ã„Ã„Ã„Ã„Ã„Ã„Ã„Ã„Ã„Ã„Ã„Ã„Ã„Ã„Ã„Ã„Ã„Ã„Ã„Ã„Ã„Ã„Ã„Ã„Ã„Ã„Ã„Ã„Ã„Ã„Ã„Ã„Ã„Ã„Ã„Ã„Ã„Ã„Ã„Ã„Ã„Ã„Ã„Ã„Ã„Ã„Ã„Ã„Ã„Ã„Ã™

	TMP->(dbGoTop())

	TMP->(SetRegua(RecCount()))

	_dDtAbt := stod("")         // Data de abate
    _aPesos := 0                // Array de pesos e % {Proprietario,Frigo,Quebra}
    _nRendO := 0                // Rendimento origem
    _nRendF := 0                // Rendimento frigorÃ­fico

    SZR->(dbSetOrder(1))
    SZE->(dbSetorder(2))

	while TMP->(!EOF())

		incregua()

		//ÃšÃ„Ã„Ã„Ã„Ã„Ã„Ã„Ã„Ã„Ã„Ã„Ã„Ã„Ã„Ã„Ã„Ã„Ã„Ã„Ã„Ã„Ã„Ã„Ã„Ã„Ã„Ã„Ã„Ã„Ã„Ã„Ã„Ã„Ã„Ã„Ã„Ã„Ã„Ã„Ã„Ã„Ã„Ã„Ã„Ã„Ã„Ã„Ã„Ã„Ã„Ã„Ã„Ã„Ã„Ã„Ã„Ã„Ã„Ã„Ã„Ã„Ã„Ã„Ã„Ã„Ã„Ã„Ã„Ã„Â¿
		//Â³ Verifica o cancelamento pelo usuario...                             Â³
		//Ã€Ã„Ã„Ã„Ã„Ã„Ã„Ã„Ã„Ã„Ã„Ã„Ã„Ã„Ã„Ã„Ã„Ã„Ã„Ã„Ã„Ã„Ã„Ã„Ã„Ã„Ã„Ã„Ã„Ã„Ã„Ã„Ã„Ã„Ã„Ã„Ã„Ã„Ã„Ã„Ã„Ã„Ã„Ã„Ã„Ã„Ã„Ã„Ã„Ã„Ã„Ã„Ã„Ã„Ã„Ã„Ã„Ã„Ã„Ã„Ã„Ã„Ã„Ã„Ã„Ã„Ã„Ã„Ã„Ã„Ã™

		if lAbortPrint
			@nlin,00 PSAY "*** CANCELADO PELO OPERADOR ***"
			Exit
		endif

		if nlin > 55 // Salto de PÃ¡gina. Neste caso o formulario tem 55 linhas...
			Cabec(Titulo,Cabec1,Cabec2,NomeProg,Tamanho,nTipo)
			nlin := 9
		endif

		if _dDtAbt != stod(TMP->ZK_DATAABT)
			@nlin,01 psay replicate('-', limite)
			nlin++
            _dDtAbt := stod(TMP->ZK_DATAABT)
            @nlin,01 psay "Aviso de Matanca -> " + transform(TMP->ZK_NUMAM,"@R 99.9999/99") + "  -  " + dtoc(_dDtAbt)
			nlin++
			@nlin,01 psay replicate('-', limite)
			nlin++
		endif

		SZE->(MsSeek(FWxFilial('SZE')+TMP->(ZK_NUMAM+ZK_LOTE)))
		_aPesos := PesosReceb(SZE->ZE_NUMERO,SZE->ZE_CATEG, iif(Empty(SZE->ZE_RASTRO),'N','S')) // {_nPesoP,_nPesoF,_nPercQ}

		//Rendimento origem
		If _aPesos[1] > 0
			_nRendO := (TMP->PETOTAL/_aPesos[1]) * 100
		Else
			_nRendO := 0
		Endif

		//Rendimento frigorifico
		If _aPesos[2] > 0
			_nRendF := (TMP->PETOTAL/_aPesos[2]) * 100
		Else
			_nRendF := 0
		Endif

		@nlin,25 psay TMP->ZK_LOTE
		@nlin,35 psay iif(TMP->ZK_CATEG = "001", "MACHO", iif(TMP->ZK_CATEG = "002", "FEMEA", "TOURO"))
		@nlin,50 psay TMP->QUANT
		@nlin,60 psay transform(_nRendO,'@E 999,999.99')+' %'
		@nlin,85 psay transform(_nRendF,'@E 999,999.99')+' %'
		@nlin,110 psay transform(_aPesos[3],'@E 999,999.99')+' %'
		nlin++
		if mv_par03 = 1
			aadd(_aDados, {_dDtAbt, TMP->ZK_LOTE, iif(TMP->ZK_CATEG = "001", "MACHO", iif(TMP->ZK_CATEG = "002", "FEMEA", "TOURO")), TMP->QUANT, transform(_nRendO,'@E 999,999.99')+' %', transform(_nRendF,'@E 999,999.99')+' %', transform(_aPesos[3],'@E 999,999.99')+' %'})
		endif

		TMP->(dbSkip()) // Avanca o ponteiro do registro no arquivo
	endDo

	//ÃšÃ„Ã„Ã„Ã„Ã„Ã„Ã„Ã„Ã„Ã„Ã„Ã„Ã„Ã„Ã„Ã„Ã„Ã„Ã„Ã„Ã„Ã„Ã„Ã„Ã„Ã„Ã„Ã„Ã„Ã„Ã„Ã„Ã„Ã„Ã„Ã„Ã„Ã„Ã„Ã„Ã„Ã„Ã„Ã„Ã„Ã„Ã„Ã„Ã„Ã„Ã„Ã„Ã„Ã„Ã„Ã„Ã„Ã„Ã„Ã„Ã„Ã„Ã„Ã„Ã„Ã„Ã„Ã„Ã„Â¿
	//Â³ Finaliza a execucao do relatorio...                                 Â³
	//Ã€Ã„Ã„Ã„Ã„Ã„Ã„Ã„Ã„Ã„Ã„Ã„Ã„Ã„Ã„Ã„Ã„Ã„Ã„Ã„Ã„Ã„Ã„Ã„Ã„Ã„Ã„Ã„Ã„Ã„Ã„Ã„Ã„Ã„Ã„Ã„Ã„Ã„Ã„Ã„Ã„Ã„Ã„Ã„Ã„Ã„Ã„Ã„Ã„Ã„Ã„Ã„Ã„Ã„Ã„Ã„Ã„Ã„Ã„Ã„Ã„Ã„Ã„Ã„Ã„Ã„Ã„Ã„Ã„Ã„Ã™

	DbCloseArea()

	SET DEVICE TO SCREEN

	If Len(_aDados) > 0		// Gera e mostra no Excel
		AADD( _aCabec, {"DATA DE ABATE", "D", 10, 0} )
		AADD( _aCabec, {"LOTE", "C", 6, 0} )
		AADD( _aCabec, {"CATEGORIA", "C", 5, 0} )
		AADD( _aCabec, {"QUANTIDADE", "N", 6, 0} )
		AADD( _aCabec, {"RENDIMENTO DE ORIGEM",	"C", 8, 0} )
		AADD( _aCabec, {"RENDIMENTO FRIGORÍFICO", "C", 8, 0} )
		AADD( _aCabec, {"QUEBRA DE PESO", "C", 8, 0} )
		U_GERAEXCEL(nomeprog, _aDados, _aCabec, .T., .T.)
	Endif

	//ÃšÃ„Ã„Ã„Ã„Ã„Ã„Ã„Ã„Ã„Ã„Ã„Ã„Ã„Ã„Ã„Ã„Ã„Ã„Ã„Ã„Ã„Ã„Ã„Ã„Ã„Ã„Ã„Ã„Ã„Ã„Ã„Ã„Ã„Ã„Ã„Ã„Ã„Ã„Ã„Ã„Ã„Ã„Ã„Ã„Ã„Ã„Ã„Ã„Ã„Ã„Ã„Ã„Ã„Ã„Ã„Ã„Ã„Ã„Ã„Ã„Ã„Ã„Ã„Ã„Ã„Ã„Ã„Ã„Ã„Â¿
	//Â³ Se impressao em disco, chama o gerenciador de impressao...          Â³
	//Ã€Ã„Ã„Ã„Ã„Ã„Ã„Ã„Ã„Ã„Ã„Ã„Ã„Ã„Ã„Ã„Ã„Ã„Ã„Ã„Ã„Ã„Ã„Ã„Ã„Ã„Ã„Ã„Ã„Ã„Ã„Ã„Ã„Ã„Ã„Ã„Ã„Ã„Ã„Ã„Ã„Ã„Ã„Ã„Ã„Ã„Ã„Ã„Ã„Ã„Ã„Ã„Ã„Ã„Ã„Ã„Ã„Ã„Ã„Ã„Ã„Ã„Ã„Ã„Ã„Ã„Ã„Ã„Ã„Ã„Ã™

	if aReturn[5]=1
		dbCommitAll()
		SET PRINTER TO
		OurSpool(wnrel)
	endif

	MS_FLUSH()

Return

Static Function GeraQuery(_cGrupo)

    cQuery := "SELECT ZK_DATAABT, ZK_NUMAM, ZK_LOTE, ZK_CATEG, COUNT(ZK_CONTROL) AS QUANT, SUM(CASE WHEN ZK_IF = 'S' THEN ZK_PETOTAL*0.92 ELSE ZK_PETOTAL END) AS PETOTAL"
    cQuery += " FROM " + RetSqlTab("SZK")
	if !empty(mv_par04) .and. !empty(mv_par05)
		cQuery += " INNER JOIN" + RetSqlTab("SZ4") + " ON (Z4_NUMAM = ZK_NUMAM AND Z4_LOTE = ZK_LOTE)"
	endif
    cQuery += " WHERE " + RetSqlFil("SZK") + iif(!empty(mv_par04) .and. !empty(mv_par05), " AND " + RetSqlFil("SZ4"), "")
    cQuery += " AND (ZK_DATAABT BETWEEN '" + DTOS(mv_par01) + "' AND '" + DTOS(mv_par02) + "')"
	if !empty(mv_par04) .and. !empty(mv_par05)
		cQuery += " AND Z4_FORNECE = '" + mv_par04 + "'"
		cQuery += " AND Z4_LOJA = '" + mv_par05 + "'"
	endif
    cQuery += " AND " + RetSQLDel('SZK') + iif(!empty(mv_par04) .and. !empty(mv_par05), " AND " + RetSQLDel("SZ4"), "")
	cQuery += " GROUP BY ZK_NUMAM, ZK_LOTE, ZK_CATEG, ZK_DATAABT"
    cQuery += " ORDER BY ZK_NUMAM, ZK_LOTE"

	cQuery := ChangeQuery(cQuery)

	//	* Mostrar a consulta */
	//@ 116,090 To 416,707 Dialog oDlgMemo Title "Consulta"
	//@ 055,005 Get cQuery Size 250,080 MEMO Object oMemo
	//Activate Dialog oDlgMemo

	if Select("TMP") != 0
		TMP->(dbCloseArea())
	endif

	TCQUERY cQuery NEW ALIAS "TMP"

Return

// Peso propriedade da categoria+rastro no receb, modificado para "peso lote origem"
Static Function PesosReceb(receb, categ, rastreado)
	Local _nPesoP := 0
	Local _nPesoF := 0
	Local _nPercQ := 0

	SZR->(MsSeek(FWxFilial('SZR')+receb+categ)) 
	While !SZR->(Eof()) .and. receb+categ == SZR->(ZR_RECEB+ZR_CATEG)
		if SZR->ZR_RASTRO = rastreado
			_nPesoP += SZR->ZR_PESO
			_nPesoF += SZR->ZR_PESOFRI
		endif

		SZR->(dbSkip())
	Enddo

	_nPercQ := (1-(_nPesoF/iif(_nPesoP > 0.0, _nPesoP, 1.0)))*100

Return {_nPesoP,_nPesoF,iif(_nPercQ >= 100, 0, iif(_nPercQ < 0, 0, _nPercQ))}
