#INCLUDE "topconn.ch"
#INCLUDE "rwmake.ch"
#INCLUDE "vkey.ch"
#INCLUDE "colors.ch"
#INCLUDE "tbiconn.ch"
#INCLUDE "totvs.ch"

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³MAX04     º Autor ³ AP6 IDE            º Data ³  11/12/15   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDescricao ³ Codigo gerado pelo AP6 IDE.                                º±±
±±º          ³                                                            º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ AP6 IDE                                                    º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/

User Function MAX04()

	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Declaracao de Variaveis                                             ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ

	Local cDesc1         := "Este programa tem como objetivo imprimir relatorio "
	Local cDesc2         := "de acordo com os parametros informados pelo usuario."
	Local cDesc3         := "Relatorio de materia prima"
	Local titulo       	 := "RELATORIO DE CONSUMO DE MATERIA PRIMA"
	Local nLin        	 := 80
	Local Cabec1       	 := "|Codigo caixa      |Data produçao    |Data Recebim.    |Codigo produto      |Descrição produto         |SIF Terc.   |Peso liq."
	Local Cabec2       	 := ""	
	Private aOrd         := {"Control"}
	Private lEnd         := .F.
	Private lAbortPrint  := .F.
	Private CbTxt        := ""
	Private limite       := 80
	Private tamanho      := "M"
	Private nomeprog     := "MAX04" // Coloque aqui o nome do programa para impressao no cabecalho
	Private nTipo        := 18
	Private aReturn      := { "Zebrado", 1, "Administracao", 2, 2, 1, "", 1}
	Private cPerg   	 := "MAX04"
	Private nLastKey     := 0
	Private cbcont       := 00
	Private CONTFL       := 01
	Private m_pag        := 01
	Private wnrel        := "MAX04" // Coloque aqui o nome do arquivo usado para impressao em disco
	Private cString 	 := "ZAS"
	Private _aPrd 	 	 := {}

	Pergunte(cPerg,.F.)

	wnrel := SetPrint('ZAS',NomeProg,cPerg,@titulo,cDesc1,cDesc2,cDesc3,.T.,aOrd,.T.,Tamanho,,.T.)

	_cQuery := " SELECT DISTINCT ZAS_CONTRO AS CONTROL, ZAS_COD AS COD, ZAS_DESC AS DESCRI, ZAS_PESOL AS PESOL, ZAS_DTRMP AS DTRMP, ZAS_SIF AS SIF, ZAS_HORAS AS HORAS,"
	_cQuery += " ZAS_DATAS AS DATAS, ZAS_BATEL AS BATEL, ZAS_PREDES AS PREDES, ZAS_DTABAT AS DTABATE, ZAS_DTPROD AS DTPROD, ZAS_TERC AS TERC, ZAS_COD3 AS COD3"
	_cQuery += " FROM " + retSqlTab('ZAS') + " (NOLOCK)"
	if mv_par04 = 1
		_cQuery += " INNER JOIN " + retSqlTab('SG1') + " (NOLOCK) ON (ZAS_COD = G1_COMP AND G1_TPPORC = 'RM')"
	elseif mv_par04 = 2
		_cQuery += " INNER JOIN " + retSqlTab('SG1') + " (NOLOCK) ON (ZAS_COD = G1_COMP AND G1_TPPORC <> 'RM')"
	endif

	_cQuery += " WHERE "  + retSqlFil('ZAS')
	if mv_par04 = 1 .or. mv_par04 = 2
		_cQuery += " AND " + retSqlFil('SG1')
	endif

	_cQuery += " AND ZAS_TIPO = 'MP' AND ZAS_DATAS BETWEEN '" + dtos(mv_par01) + "' AND '" + dtos(mv_par02) + "'"
	_cQuery += " AND ZAS_DATAS <> ''"

	if mv_par03 = 1
		_cQuery += " AND ZAS_BATEL <> ''"
	elseif mv_par03 = 2
		_cQuery += " AND ZAS_BATEL = ''"
	endif

	_cQuery += " AND " + retSqlDel('ZAS')
	if mv_par04 = 1 .or. mv_par04 = 2
		_cQuery += " AND " + retSqlDel('SG1')
	endif

	_cQuery += " ORDER BY ZAS_DATAS, ZAS_BATEL, ZAS_CONTRO, ZAS_COD"

	_cQuery := ChangeQuery(_cQuery)

	//	* Mostrar a consulta */
	//@ 116,090 To 416,707 Dialog oDlgMemo Title "Consulta"
	//@ 055,005 Get _cQuery Size 250,080 MEMO Object oMemo
	//Activate Dialog oDlgMemo

	MsgRun("Aguarde... Realizando contagem de registros ...",,{||  GeraTMP() })

	If nLastKey == 27
		Return
	Endif

	SetDefault(aReturn,'ZAS')

	If nLastKey == 27
		Return
	Endif

	nTipo := If(aReturn[4]==1,15,18)
	RptStatus({|| RunReport(Cabec1,Cabec2,Titulo,nLin) },Titulo)
Return

Static Function RunReport(Cabec1,Cabec2,Titulo,nLin)

	Local i
	Cabec(Titulo,Cabec1,Cabec2,NomeProg,Tamanho,nTipo)
	nLin := 9

	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ SETREGUA -> Indica quantos registros serao processados para a regua ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ

	TMP->(SetRegua(RecCount()))
	_dData     := ''
	_cBatel    := ''
	_nPeTotal  := 0.00
	_nTotBatel := 0.00

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

		//quebra por data
		if _dData <> TMP->DATAS
			@nlin,00 psay replicate('-',132)
			nlin++
			@nlin,05 psay 'Data de consumo: ' + dtoc(stod(TMP->DATAS))
			nlin++
			_dData := TMP->DATAS
		endif

		//quebra por batelada
		if _cBatel <> TMP->BATEL
			@nlin,00 psay replicate('-',132)
			nlin++
			_cCodMP  := alltrim(GetAdvFVal('ZAX','ZAX_CODMP',FWxfilial('ZAX') + TMP->BATEL,1))
			if len(_cCodMP) <= 4
				_cDescMp := alltrim(GetAdvFVal('ZG0','ZG0_DESC',FWxfilial('ZG0') + _cCodMp,1))
			else
				_cDescMp := alltrim(GetAdvFVal('SB1','B1_IMPCOM',FWxFilial('SB1') + _cCodMp,1))
			endif
			@nlin,55 psay 'Batelada: ' + _cDescMp
			nlin++

			ZAU->(DbSetOrder(7))
			if ZAU->(MsSeek(FWxfilial('ZAU') + alltrim(TMP->BATEL)))

				@nlin,10 psay 'Lotes derivados de PA: '
				nlin++

				while ZAU->(!eof()) .and. ZAU->ZAU_FILIAL = FWxfilial('ZAU') .and. ZAU->ZAU_BATEL = alltrim(TMP->BATEL)
					@nlin,15 psay ZAU->ZAU_NUM
					@nlin,30 psay 'Codigo PA: ' + ZAU->ZAU_COD
					@nlin,50 psay alltrim(ZAU->ZAU_DESC)
					nlin++
					ZAU->(DbSkip())
				enddo
			else

				ZAV->(DbSetOrder(3))
				if  ZAV->(MsSeek(FWxfilial('ZAV') + alltrim(TMP->BATEL)))
					@nlin,10 psay 'Lotes derivados de PA: '
					nlin++

					while ZAV->(!eof()) .and. ZAV->ZAV_FILIAL = FWxfilial('ZAV') .and. ZAV->ZAV_BATEL = alltrim(TMP->BATEL)
						ZAU->(DbSetOrder(1))
						if ZAU->(MsSeek(FWxfilial('ZAU') + ZAV->ZAV_NUM))
							@nlin,15 psay ZAU->ZAU_NUM
							@nlin,30 psay 'Codigo PA: ' + ZAU->ZAU_COD
							@nlin,50 psay GetAdvFVal('SB1','B1_DESC',FWxfilial('SB1') + alltrim(ZAU->ZAU_COD),1)
							nlin++
						endif
						ZAV->(DbSkip())
					enddo
				endif
			endif
			nlin++

			_cBatel := TMP->BATEL

		endif

		//lista as caixas
		@nlin,01 psay TMP->CONTROL  //codigo da caixa
		@nlin,20 psay dtoc(stod(TMP->DTPROD))
		@nlin,37 psay dtoc(stod(TMP->DTRMP)) 
		@nlin,47 psay TMP->HORAS

		//pega descrição do código de produto
		_cDescTerc := GetAdvFVal('SB1','B1_DESCRED',FWxFilial('SB1') + TMP->COD3,1)
		@nlin,58 psay iif(TMP->TERC = 'S', TMP->COD3, TMP->COD)     //codigo do produto
		@nlin,75 psay iif(TMP->TERC = 'S', substr(_cDescTerc,1,25),substr(TMP->DESCRI,1,25)) //descrição do produto
		@nlin,107 psay iif(!empty(TMP->SIF),TMP->SIF,'1733')
		@nlin,118 psay transform(TMP->PESOL,'@E 999.99') //peso l
		nlin++

		_nTotBatel += TMP->PESOL
		_nPeTotal += TMP->PESOL

		//Alimenta o vetor
		_npos := aScan(_aPrd,{|aVal|aVal[1] = iif(TMP->TERC = 'S', TMP->COD3, TMP->COD)})

		if _npos <> 0
			_aPrd[_npos,2]+= TMP->PESOL
		else
			aAdd(_aPrd,{iif(TMP->TERC = 'S', TMP->COD3, TMP->COD), TMP->PESOL})
		endif 

		TMP->(dbSkip()) // Avanca o ponteiro do registro no arquivo
		// totalizador da batelada
		if _cBatel <> TMP->BATEL .or. TMP->(eof())
			@nlin,95 psay '_____________________________'
			@nlin++
			@nlin,95 psay 'TOTAL (KG): ' + transform(_nTotBatel,'@E 999,999.99')
			nlin++
			_nTotBatel := 0.00

			for i:=1 to len(_aPrd)
				@nlin,95 psay _aPrd[i,1]
				@nlin,105 psay transform(_aPrd[i,2],'@E 999,999.99') + ' kg'
				nlin++
			next

			_aPrd:={}
		endif

	EndDo

	nlin++

	If nLin > 70 // Salto de Página. Neste caso o formulario tem 55 linhas...
		Cabec(Titulo,Cabec1,Cabec2,NomeProg,Tamanho,nTipo)
		nLin := 9
	endif

	@nlin,05 psay 'TOTAL DE MP CONSUMIDO(kg): ' + transform(_nPeTotal,'@E 999,999.99') //peso l

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
