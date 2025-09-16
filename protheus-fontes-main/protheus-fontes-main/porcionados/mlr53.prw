#INCLUDE "rwmake.ch"
#INCLUDE "vkey.ch"
#INCLUDE "protheus.ch"
#INCLUDE "topconn.ch"
#INCLUDE "colors.ch"

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³MLR53     ºAutor  ³Mauricio Roehrs     º Data ³  14/09/15   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³ Relatorio para Impressão de relatorio de rendimentos       º±±
±±º          ³ por batelada                                               º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ Porcionados							                      º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/

User Function MLR53()
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Declaracao de Variaveis                                             ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ

	Local cDesc1         := "Este programa tem como objetivo imprimir relatorio"
	Local cDesc2         := "para conferencia dos rendimentos por batelada"
	Local cDesc3         := ""
	Local cPict          := "vai porra"
	Local titulo         := "RELATORIO DE RENDIMENTOS POR BATELADA"
	Local Cabec1         := "      Batelada          Codigo M.P           Descricao         Quant. Prevista(kg)     Quant. Consumida(kg)"
	Local Cabec2         := ""
	Local imprime        := .T.
	Local aOrd           := {}
	Private nLin         := 80
	Private lEnd         := .F.
	Private lAbortPrint  := .F.
	Private CbTxt        := ""
	Private limite       := 80
	Private tamanho      := "M"
	Private nomeprog     := "MLR53" // Coloque aqui o nome do programa para impressao no cabecalho
	Private nTipo        := 18
	Private aReturn      := { "Zebrado", 1, "Administracao", 2, 2, 1, "", 1}
	Private nLastKey     := 0
	Private cPerg   		:= "MLR53"
	Private cbtxt      	:= Space(10)
	Private cbcont     	:= 00
	Private CONTFL     	:= 01
	Private m_pag      	:= 01
	Private wnrel      	:= "MLR53" // Coloque aqui o nome do arquivo usado para impressao em disco
	pergunte(cPerg,.F.)

	wnrel := SetPrint('ZAS',NomeProg,cPerg,@titulo,cDesc1,cDesc2,cDesc3,.T.,aOrd,.T.,Tamanho,,.T.)

	_cQuery := " SELECT  ZAS_DESTIN AS DESTINO, ZAS_BATEL AS BATELADA, SUM(ZAS_PESOL) AS PESOL, ZAS_TIPO AS TIPO, ZAX_DTPROD AS DTPROD
	_cQuery += " FROM  " + RetSQLTab('ZAS') + " , " + retSqlTab('ZAX')
	_cQuery += " WHERE " + RetSQLFil('ZAS') + " AND " + retSqlFil('ZAX') + " AND ZAS_BATEL = ZAX_NUM
	_cQuery += " AND ZAS_TIPO IN ('QR','QF','PP','MP') AND ZAS_DESTIN <> ''
	_cQuery += " AND ZAX_DTPROD BETWEEN '" + dtos(mv_par01) + "' AND '" + dtos(mv_par02) + "'"
	_cQuery += " AND   " + RetSQLDel('ZAS') + " AND " + retSqlDel('ZAX')
	_cQuery += " GROUP BY ZAS_DESTIN, ZAS_BATEL, ZAS_TIPO, ZAX_DTPROD
	_cQuery += " ORDER BY ZAS_BATEL, ZAS_TIPO,ZAS_DESTIN

	_cQuery  := ChangeQuery(_cQuery)

	//_log(_cQuery)

	//	* Mostrar a consulta */
	//@ 116,090 To 416,707 Dialog oDlgMemo Title "Consulta"
	//@ 055,005 Get _cQuery Size 250,080 MEMO Object oMemo
	//Activate Dialog oDlgMemo

	MsgRun("Aguarde... Realizando contagem de registros...",,{||  GeraTMP() })

	If nLastKey == 27
		Return
	Endif

	SetDefault(aReturn,'ZAS')

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

	Cabec(Titulo,Cabec1,Cabec2,NomeProg,Tamanho,nTipo)
	nLin := 9

	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ SETREGUA -> Indica quantos registros serao processados para a regua ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ

	TMP->(SetRegua(RecCount()))

	_cBatel    := ''
	_cDestino  := ''
	_cTipo     := ''
	_cCodMp    := ''
	_cDesMp    := ''
	_nQtdMp    := 0
	_nQtdMpc   := 0
	_nTotQrb   := 0
	_nPercent  := 0
	TMP->(dbGoTop())

	While TMP->(!EOF())

		incregua()

		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³ Verifica o cancelamento pelo usuario...                             ³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ

		If lAbortPrint
			@nLin,00 PSAY "*** CANCELADO PELO OPERADOR ***"
			Exit
		Endif

		If nLin > 70 // Salto de Página. Neste caso o formulario tem 55 linhas...
			Cabec(Titulo,Cabec1,Cabec2,NomeProg,Tamanho,nTipo)
			nLin := 9
		Endif

		_cDescDest := fBuscaCpo('SX5',1,xFilial('SX5')+'ZP'+TMP->DESTINO,'X5_DESCRI')

		//BATELADA
		if _cBatel <> TMP->BATELADA

			_cCodMp  := alltrim(fBuscaCpo('ZAX',1,xFilial('ZAX') + TMP->BATELADA,'ZAX_CODMP'))
			_cDesMp  := alltrim(fBuscaCpo('ZAX',1,xFilial('ZAX') + TMP->BATELADA,'ZAX_DESCRI'))
			_nQtdMp  := fBuscaCpo('ZAX',1,xFilial('ZAX') + TMP->BATELADA,'ZAX_QTDMP')
			_nQtdMpc := fBuscaCpo('ZAX',1,xFilial('ZAX') + TMP->BATELADA,'ZAX_QTDMPC')

			@nlin,01 psay replicate('-',132)
			nlin++
			@nlin,05 psay TMP->BATELADA
			@nlin,25 psay _cCodMp
			@nlin,38 psay substr(_cDesMp,1,20)
			@nlin,65 psay transform(_nQtdMp,'@E 999,999.99')
			@nlin,90 psay transform(_nQtdMpc,'@E 999,999.99')
			_cBatel := TMP->BATELADA
			nlin++
			@nlin,01 psay replicate('-',132)
			nlin++

			if _cTipo = TMP->TIPO
				@nlin,15 psay 'Origem: ' + iif(TMP->TIPO = 'QR','Quebra de refile',iif(TMP->TIPO = 'QF','Quebra de fatiadora','MP. Refilada'))
				nlin++
			endif

			if _cDestino == TMP->DESTINO
				@nlin,30 psay 'Destino: ' + _cDescDest + ' -> '
				@nlin,63 psay transform(TMP->PESOL,'@E 9,999.99')+ ' kg'
				nlin++
			endif

		endif

		//ORIGEM
		if _cTipo <> TMP->TIPO
			@nlin,15 psay 'Origem: ' + iif(TMP->TIPO = 'QR','Quebra de refile',iif(TMP->TIPO = 'QF','Quebra de fatiadora','MP. Refilada'))
			_cTipo := TMP->TIPO
			nlin++

			if _cDestino == TMP->DESTINO
				@nlin,30 psay 'Destino: ' + _cDescDest + ' -> '
				@nlin,63 psay transform(TMP->PESOL,'@E 9,999.99')+ ' kg'
				nlin++
			endif
		endif

		//DESTINO
		if _cDestino <> TMP->DESTINO
			@nlin,30 psay 'Destino: ' + _cDescDest + ' -> '
			@nlin,63 psay transform(TMP->PESOL,'@E 9,999.99')+ ' kg'
			_cDestino := TMP->DESTINO
			nlin++
		endif

		nlin++

		if TMP->DESTINO <> '007'//diferente de bife
			_nTotQrb += TMP->PESOL
		endif
		TMP->(dbSkip()) // Avanca o ponteiro do registro no arquivo

		if TMP->(eof()) .or. _cBatel <> TMP->BATELADA
			_nPercent := (1- (_nTotQrb / _nQtdMpc)) * 100
			nlin++
			@nlin,15 psay 'RENDIMENTO -->'
			@nlin,61 psay transform((_nQtdMpc - _nTotQrb),'@E 999,999.99')+ ' kg'
			@nlin,78 psay '(' + transform(_nPercent,'@E 999.99')+ '%)'
			nlin++
			_nTotQrb := 0
		endif

	EndDo

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

	_cQuery  := ChangeQuery(_cQuery)

	//	* Mostrar a consulta */
	//@ 116,090 To 416,707 Dialog oDlgMemo Title "Consulta"
	//@ 055,005 Get _cQuery Size 250,080 MEMO Object oMemo
	//Activate Dialog oDlgMemo

	If Select("TMP") != 0
		TMP->(dbCloseArea())
	Endif

	TCQUERY _cQuery NEW ALIAS "TMP"

return

/*
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Grava arquivo de log para conferencia                        ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
Static Function _Log(_sTexto)

Local _nHdl    := 0
Local _sArqLog := "\MLR53.txt"

If File (_sArqLog)
_nHdl = fOpen(_sArqLog, 1)
Else
_nHdl = fCreate(_sArqLog, 0)
Endif

fSeek(_nHdl, 0, 2)      // Encontra final do arquivo
fWrite(_nHdl, _sTexto + chr (13) + chr (10))
fClose(_nHdl)

Return
*/
