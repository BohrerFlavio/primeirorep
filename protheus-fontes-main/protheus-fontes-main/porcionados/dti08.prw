#INCLUDE "topconn.ch"
#INCLUDE "rwmake.ch"
#INCLUDE "vkey.ch"
#INCLUDE "protheus.ch"
#INCLUDE "colors.ch"
#INCLUDE "tbiconn.ch"

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³DTI08  ºAutor  ³Flávio Bohrer Flôres º Data ³  14/07/15     º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     Relatório de produção de  M1, M2, M3, TU, GR                 º±±
±±º          ³porcionados   											  º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ Sigapcp - Frigorifico Silva                                º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/

User Function DTI08()
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Declaracao de Variaveis                                             ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ

	Local cDesc1         := "Este relatório tem como objetivo Listar a Produção"
	Local cDesc2         := "de Quebras nos Porcionados."
	Local cDesc3         := ""
	//Local cPict          := ""
	Local titulo         := ""
	Local Cabec1         := "                                             Relatório de Produção por Quebras"
	Local Cabec2         := ""
	//Local imprime        := .T.
	Local aOrd           := {}
	Private nLin         := 80
	Private lEnd         := .F.
	Private lAbortPrint  := .F.
	Private CbTxt        := ""
	Private limite       := 80
	Private tamanho      := "M"
	Private nomeprog     := "DTI08" // Coloque aqui o nome do programa para impressao no cabecalho
	Private nTipo        := 18
	Private aReturn      := { "Zebrado", 1, "Administracao", 2, 2, 1, "", 1}
	Private nLastKey     := 0
	Private cPerg   		:= "DTI08"
	//Private cbtxt      	:= Space(10)
	Private cbcont     	:= 00
	Private CONTFL     	:= 01
	Private m_pag      	:= 01
	Private wnrel      	:= "DTI08" // Coloque aqui o nome do arquivo usado para impressao em disco
	Private _aTotal     := {}
	pergunte(cPerg,.F.)

	wnrel := SetPrint('ZAS',NomeProg,cPerg,@titulo,cDesc1,cDesc2,cDesc3,.T.,aOrd,.T.,Tamanho,,.T.)

	_cQuery1 := " SELECT ZAS_COD AS _COD,ZAS_DESTIN AS _DESTIN, ZAS_TIPO AS _TIPO,ZAS_TERC AS _TERC,ZAS_PESOL AS _PESOT"
	_cQuery1 += " FROM " + RetSQLTab('ZAS') + " WHERE " + RetSQLFil('ZAS')
	_cQuery1 += " AND ZAS_DTPROD BETWEEN '" + dtos(mv_par01) + "' AND '" + dtos(mv_par02) + "'"
	_cQuery1 += " AND ZAS_DATAS = '' AND ZAS_HORAS = '' "
	_cQuery1 += " AND ZAS_DESTIN NOT IN ('007','008','   ')"
	_cQuery1 += " AND " + RetSQLDel('ZAS')
	_cQuery1 += " ORDER BY ZAS_DESTIN, ZAS_COD"
	_cQuery1 := ChangeQuery(_cQuery1)

	_nQtcai := 0
	_nPeso1 := 0.00

	_cPosCa := 64
	_cPosPe := 92

	MsgRun("Aguarde.... Realizando contagem de registros...",,{||  GeraTMP() })

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

	//Local nOrdem
	Local i

	Cabec(Titulo,Cabec1,Cabec2,NomeProg,Tamanho,nTipo)
	nLin := 9

	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ SETREGUA -> Indica quantos registros serao processados para a regua ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ

	EST1->(SetRegua(RecCount()))

	_cBatel    := ''
	_nTotPesF  := 0
	_cTipo := ''
	_nCont := 0

	EST1->(dbGoTop())

	@nlin,01 psay 'Data Início da  Produção: ' + dtoc(mv_par01)
	nlin++
	@nlin,01 psay 'Data Final da Produção:   ' + dtoc(mv_par02)
	nlin++

	While EST1->(!EOF())

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

		_key  := EST1->_DESTIN
		_npos := aScan(_aTotal,{|aVal|aVal[1] = _key})

		if _npos <> 0
			_aTotal[_npos,2] ++
			_aTotal[_npos,3] += EST1->_PESOT
		else
			aAdd(_aTotal,{_key, 1,EST1->_PESOT})
		endif

		EST1->(dbSkip()) // Avanca o ponteiro do registro no arquivo

	EndDo

	nLin++
	@nlin,25 psay 'Resultado total:                      Quant. Caixas               Peso Líquido (kg)'
	nLin+=2

	for i=1 to len(_aTotal)
		_cDescDest := fBuscaCpo('SX5',1,xFilial('SX5')+'ZP'+_aTotal[i,1],'X5_DESCRI')
		@nlin,25 psay _cDescDest
		@nlin,_cPosCa psay Transform(_aTotal[i,2],'@E 999,999')
		@nlin,_cPosPe psay Transform(_aTotal[i,3],'@E 999,999,999.99')

		nLin++
		_nQtcai += _aTotal[i,2]
		_nPeso1 += _aTotal[i,3]
	next

	nlin+=2
	@nlin,25 psay 'Total   :'
	@nlin,_cPosCa psay Transform(_nQtcai,'@E 999,999')
	@nlin,_cPosPe psay Transform(_nPeso1,'@E 999,999,999.99')

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

	//	* Mostrar a consulta */
	//@ 116,090 To 416,707 Dialog oDlgMemo Title "Consulta"
	//	@ 055,005 Get _cQuery1 Size 250,080 MEMO Object oMemo
	//	Activate Dialog oDlgMemo

	If Select("EST1") != 0
		EST1->(dbCloseArea())
	Endif

	TCQUERY _cQuery1 NEW ALIAS "EST1"

return
