#INCLUDE "rwmake.ch"
#INCLUDE "totvs.ch"
#INCLUDE "topconn.ch"

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³MLR04   º Autor ³ Mauricio Roehrs  º Data ³  17/08/12       º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDescricao ³ Relatorio de Expedição de peças                            º±±
±±º          ³                                                            º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ Qualidade e PCP (SIGAPCP)                                  º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/

User Function MLR04()

	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Declaracao de Variaveis                                             ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ

	Local cDesc1         := "Este programa tem como objetivo imprimir relatorio  "
	Local cDesc2         := "de expedição de peças para fins de controle de      "
	Local cDesc3         := "estoque de peças proprias                          "
	//Local cPict          := ""
	Local titulo         := "RELATORIO DE PEÇAS CARREGADAS"
	Local nLin           := 80
	Local Cabec1         := "Dados das Peças Carregadas"
	Local Cabec2         := "  Data    Cort.Orig     Cod.Prod.       Descri. Pro                       Quantidade     Peso"
	//Local imprime        := .T.
	Local aOrd := {}
	Private lEnd         := .F.
	Private lAbortPrint  := .F.
	Private CbTxt        := ""
	Private limite       := 132
	Private tamanho      := "M"
	Private nomeprog     := "MLR04" // Coloque aqui o nome do programa para impressao no cabecalho
	Private nTipo        := 18
	Private aReturn      := { "Zebrado", 1, "Administracao", 2, 2, 1, "", 1}
	Private nLastKey     := 0
	Private cPerg        := "MLR04"
	//Private cbtxt       := Space(10)
	Private cbcont      := 00
	Private CONTFL      := 01
	Private m_pag       := 01
	Private wnrel       := "MLR04" // Coloque aqui o nome do arquivo usado para impressao em disco

	pergunte(cPerg,.F.)

	if mv_par06=2
		Cabec2 := "  Data    Cort.Orig     Cod.Prod.       Descri. Pro                       Quantidade     Peso    Data de Abate"
	endif

	wnrel := SetPrint('ZZ2',NomeProg,cPerg,@titulo,cDesc1,cDesc2,cDesc3,.T.,aOrd,.T.,Tamanho,,.T.)

	if mv_par06 = 1
		cQuery := "SELECT B1_CORORI, SUM(ZZ2_QUANT) AS QUANT, SUM(ZZ2_PESOL) AS PESO, ZZ2_DATAC AS DATAS, ZZ2_COD AS COD" + iif(mv_par04 = 2,", ZZ4_CODCLI", "")
		cQuery += " FROM " + RetSQLTab('ZZ2') + " (NOLOCK)"
		cQuery += " INNER JOIN " + RetSQLTab('SB1') + " (NOLOCK) ON (B1_COD = ZZ2_COD)"
		cQuery += " INNER JOIN " + RetSQLTab('ZZ4') + " (NOLOCK) ON (ZZ2_PREPED = ZZ4_NUM AND ZZ2_PRECAR = ZZ4_PRECAR)"
		cQuery += " WHERE " + RetSQLFil('SB1') + " AND " + RetSQLFil('ZZ4') + " AND " + RetSQLFil('ZZ2')
		cQuery += " AND ZZ4_TPOPER IN ('V','E') AND ZZ4_STATUS = 'F'"
		cQuery += " AND B1_TIPO IN ('PA','PR') AND B1_SEGUM = 'PC' AND B1_MSBLQL = '2'"
		cQuery += " AND ZZ2_DATAC BETWEEN '" + dtos(mv_par01) + "' AND '" + dtos(mv_par02) + "'"
		if !empty(mv_par05)
			cQuery += " AND ZZ4_CODCLI = '" + mv_par05 + "'"
		endif
		if mv_par03 = 2
			cQuery += " AND (B1_PROGRAM LIKE '%006%' OR B1_PROGRAM LIKE '%021%')"
		elseif mv_par03 = 3
			cQuery += " AND (B1_PROGRAM LIKE '%002%' OR B1_PROGRAM LIKE '%022%')"
		endif
		cQuery += " AND " + RetSQLDel('ZZ2') + " AND " + RetSQLDel('SB1') + " AND " + RetSQLDel('ZZ4')
		cQuery += " GROUP BY ZZ2_DATAC, B1_CORORI, ZZ2_COD" + iif(mv_par04 = 2,", ZZ4_CODCLI", "")
		cQuery += " ORDER BY ZZ2_DATAC" + iif(mv_par04 = 2,", ZZ4_CODCLI", "")
	else
		cQuery := "SELECT B1_CORORI, COUNT(ZAJ_NUM) AS QUANT, SUM(ZAJ_PESO) AS PESO, ZAJ_DATAS AS DATAS, ZAJ_CODPA AS COD, ZAJ_NUMAM" + iif(mv_par04 = 2,", ZZ4_CODCLI", "")
		cQuery += " FROM " + RetSQLTab('ZAJ') + " (NOLOCK)"
		cQuery += " INNER JOIN " + RetSQLTab('SB1') + " (NOLOCK) ON (B1_COD = ZAJ_CODPA)"
		cQuery += " INNER JOIN " + RetSQLTab('ZZ4') + " (NOLOCK) ON (ZAJ_PREPED = ZZ4_NUM AND ZAJ_PRECAR = ZZ4_PRECAR)"
		cQuery += " WHERE " + RetSQLFil('SB1') + " AND " + RetSQLFil('ZZ4') + " AND " + RetSQLFil('ZAJ')
		cQuery += " AND ZZ4_TPOPER IN ('V','E') AND ZZ4_STATUS = 'F'"
		cQuery += " AND B1_TIPO IN ('PA','PR') AND B1_SEGUM = 'PC' AND B1_MSBLQL = '2'"
		cQuery += " AND ZAJ_DATAS BETWEEN '" + dtos(mv_par01) + "' AND '" + dtos(mv_par02) + "'"
		cQuery += " AND ZAJ_DEST = 'R' AND ZAJ_PRECAR <> 'ACERTO'"
		if !empty(mv_par05)
			cQuery += " AND ZZ4_CODCLI = '" + mv_par05 + "'"
		endif
		if mv_par03 = 2
			cQuery += " AND (B1_PROGRAM LIKE '%006%' OR B1_PROGRAM LIKE '%021%')"
		elseif mv_par03 = 3
			cQuery += " AND (B1_PROGRAM LIKE '%002%' OR B1_PROGRAM LIKE '%022%')"
		endif
		cQuery += " AND " + RetSQLDel('ZAJ') + " AND " + RetSQLDel('SB1') + " AND " + RetSQLDel('ZZ4')
		cQuery += " GROUP BY ZAJ_DATAS, B1_CORORI, ZAJ_CODPA, ZAJ_NUMAM" + iif(mv_par04 = 2,", ZZ4_CODCLI", "")
		cQuery += " ORDER BY ZAJ_DATAS" + iif(mv_par04 = 2,", ZZ4_CODCLI", "")
	endif

	cQuery := ChangeQuery(cQuery)

	//	* Mostrar a consulta */
	//@ 116,090 To 416,707 Dialog oDlgMemo Title "Consulta"
	//@ 055,005 Get cQuery Size 250,080 MEMO Object oMemo
	//Activate Dialog oDlgMemo    

	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Monta a interface padrao com o usuario...                           ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ

	If Select("TMP") != 0
		TMP->(dbCloseArea())
	Endif
	TCQUERY cQuery NEW ALIAS "TMP"

	If nLastKey == 27
		Return
	Endif

	SetDefault(aReturn,'TMP')

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
	Local _lLin   := .t.
	//Local _Seq    := space(6)
	Local _nT     := 0  //total de traseiros
	Local _nD     := 0  //total de dianteiros
	Local _nC     := 0  //total de costelas
	Local _nE     := 0  //total de meia-res
	Local _nEd    := 0  //total de dianteiros somado a meia-res
	Local _nEt    := 0  //total de traseiros somado a meia-res
	Local _nEc    := 0  //total de costelas somado a meia-res
	Local _nToT   := 0  //total geral de pecas

	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ SETREGUA -> Indica quantos registros serao processados para a regua ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ

	TMP->(dbGoTop())

	TMP->(SetRegua(RecCount()))

	Cabec(Titulo,Cabec1,Cabec2,NomeProg,Tamanho,nTipo)
	nLin := 9

	_cData := ''
	_cTipo := ''
	_cCli  := ''

	While TMP->(!EOF())

		incregua()
		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³ Verifica o cancelamento pelo usuario...                             ³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ

		If lAbortPrint
			@nLin,00 PSAY "*** CANCELADO PELO OPERADOR ***"
			Exit
		Endif

		If nLin > 75 // Salto de Página. Neste caso o formulario tem 55 linhas...
			Cabec(Titulo,Cabec1,Cabec2,NomeProg,Tamanho,nTipo)
			nLin := 9
		Endif
		_cOri := TMP->B1_CORORI		
		_nToT += TMP->QUANT

		if _cData <> TMP->DATAS
			@nlin,00 psay replicate('=',limite)
			nlin++
			@nlin, 001 psay stod(TMP->DATAS)
			nlin++
			@nlin,00 psay replicate('=',limite)
			nlin++
			_cData := TMP->DATAS
		endif

		if mv_par04 = 2
			if _cCli <> TMP->ZZ4_CODCLI
				@nlin,00 psay replicate('-',limite)
				nlin++
				@nlin, 001 psay alltrim(GetAdvFVal('SA1','A1_NOME',FWxfilial('SA1')+TMP->ZZ4_CODCLI,1))
				nlin++
				@nlin,00 psay replicate('-',limite)
				nlin++
				_cCli := TMP->ZZ4_CODCLI
			endif
		endif

		do case
			case _cOri = 'D'
			_cOri := 'Dianteiro'
			_nD += TMP->QUANT
			case _cOri = 'T'
			_cOri := 'Traseiro'
			_nT += TMP->QUANT
			case _cOri = 'C'
			_cOri := 'Costela'
			_nC += TMP->QUANT
			case _cOri = 'E'
			_cOri := 'Meia Res'
			_nE += TMP->QUANT   
			case _cOri = 'P'
			_cOri := 'Tras.Cap'
			_nE += TMP->QUANT			
		endcase

		if _cTipo <> _cOri
			@nlin, 10 psay _cOri
			nlin++
			_cTipo := _cOri
		endif

		_cDescri := GetAdvFVal('SB1','B1_DESCRED',FWxfilial('SB1')+TMP->COD,1)

		@nlin, 25 psay TMP->COD
		@nlin, 36 psay alltrim(_cDescri)
		@nlin, 75 psay transform(TMP->QUANT,'@E 99,999')
		@nlin, 85 psay transform(TMP->PESO,'@E 999,999.99')
		if mv_par06 = 2
			@nlin,100 psay dtoc(GetAdvFVal('SZG','ZG_DATA',FWxfilial('SZG')+TMP->ZAJ_NUMAM,1))
		endif

		nlin++
		_lLin := !_lLin

		If nLin > 75 // Salto de Página. Neste caso o formulario tem 55 linhas...
			Cabec(Titulo,Cabec1,Cabec2,NomeProg,Tamanho,nTipo)
			nLin := 9
		Endif
		TMP->(dbSkip()) // Avanca o ponteiro do registro no arquivo

	enddo
	_nTotal := _nD + _nT + _nC + _nE  //Total de Peças

	_nEd  := _nD + _nE //Total de Dianteiros + Dianteiros da Meia Res
	_nEt  := _nT + _nE //Total de Traseiros + Traseiros da Meia Res
	_nEc  := _nC + _nE	//Total de Costelas + Costelas da Meia Res

	nlin += 2
	if _nD <> 0
		@nlin,02 psay 'Numero de Dianteiros: ' + transform(_nD,'@E 9,999')
		nlin++
	endif

	if _nT <> 0
		@nlin,02 psay 'Numero de Traseiros:  ' + transform(_nT,'@E 9,999')
		nlin++
	endif

	if _nC <> 0
		@nlin,02 psay 'Numero de Costelas:  ' + transform(_nC,'@E 9,999')
		nlin++
	endif

	if _nE <> 0
		@nlin,02 psay 'Numero de Meia Res:  ' + transform(_nE,'@E 9,999')
		nlin++
	endif
	nlin += 2
	@nlin,02 psay 'Numero Total de Peças:  ' + transform(_nToT,'@E 999,999,999')
	nlin += 2

	If nLin > 75 // Salto de Página. Neste caso o formulario tem 55 linhas...
		Cabec(Titulo,Cabec1,Cabec2,NomeProg,Tamanho,nTipo)
		nLin := 9
	Endif
	nlin += 2
	@nLin,02 psay '----------------------------------------------------------------------'
	nlin += 2
	if _nEd <> 0
		@nlin,02 psay 'Numero de Dianteiros Somado a Meia Res: ' + transform(_nEd,'@E 9,999')
		nlin++
	endif

	if _nEt <> 0
		@nlin,02 psay 'Numero de Traseiros Somado a Meia Res: ' + transform(_nEt,'@E 9,999')
		nlin++
	endif

	if _nEc <> 0
		@nlin,02 psay 'Numero de Costelas Somado a Meia Res: ' + transform(_nEc,'@E 9,999')
		nlin++
	endif


	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Finaliza a execucao do relatorio...                                 ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ

	DbCloseArea('TMP')

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
