#INCLUDE "rwmake.ch"
#INCLUDE "topconn.ch"

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³GJF43   º Autor ³ Giuliano Forgiarini  º Data ³  31/08/08   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDescricao ³ Relatorio Produção do setor de embalagem                   º±±
±±º          ³                                                            º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ Comercial e expedições (SIGAPCP e SIGAOMS)                 º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/

User Function GJF43()


	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Declaracao de Variaveis                                             ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ

	Local cDesc1         := "Este programa tem como objetivo imprimir relatorio  "
	Local cDesc2         := "de produção de caixas no setor de embalagem da empresa"
	Local cDesc3         := "podendo-se definir uma balança específica ou listando"
	//Local cPict          := "todas elas de acordo com os parametros"
	Local titulo         := "RELATORIO PRODUÇÃO DE CAIXAS - EMBALAGEM"
	Local nLin           := 80
	Local Cabec1         := "Codigo      Descricao Produto                Qt.Caixas              Peso            Emb. Secundaria"                   
	Local Cabec2         := ""
	//Local imprime        := .T.
	Local aOrd := {}
	Private lEnd         := .F.
	Private lAbortPrint  := .F.
	Private CbTxt        := ""
	Private limite       := 80
	Private tamanho      := "M"
	Private nomeprog     := "GJF43" // Coloque aqui o nome do programa para impressao no cabecalho
	Private nTipo        := 18
	Private aReturn      := { "Zebrado", 1, "Administracao", 2, 2, 1, "", 1}
	Private nLastKey     := 0
	Private cPerg        := "GJF43"
	//Private cbtxt      	:= Space(10)
	Private cbcont     	:= 00
	Private CONTFL     	:= 01
	Private m_pag      	:= 01
	Private wnrel      	:= "GJF43" // Coloque aqui o nome do arquivo usado para impressao em disco    
	Private TotCaix    	:= 0.00
	Private TotPeso    	:= 0.00
	Private _Farm		:= ""

	pergunte(cPerg,.F.)

	wnrel := SetPrint('SZ8',NomeProg,cPerg,@titulo,cDesc1,cDesc2,cDesc3,.T.,aOrd,.T.,Tamanho,,.T.)

	//para verificação se existe previsao de pesagem

	GeraPROD()

	filtraMP()

	If nLastKey == 27
		Return
	Endif

	SetDefault(aReturn,'SZ8')

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

	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ SETREGUA -> Indica quantos registros serao processados para a regua ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ

	PROD->(dbGoTop())

	PROD->(SetRegua(RecCount()))

	_Balan := .f.
	_Arm      := ''
	_Grupo    := ''
	_TotCaix  := 0.00
	_TotPeso  := 0.00

	While PROD->(!EOF())

		incregua()

		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³ Verifica o cancelamento pelo usuario...                             ³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ

		If lAbortPrint
			@nLin,00 PSAY "*** CANCELADO PELO OPERADOR ***"
			Exit
		Endif

		if _Farm != 'T'
			if  PROD->FARM != _Farm
				PROD->(dbskip())
				loop 
			endif
		endif

		If nLin > 75 // Salto de Página. Neste caso o formulario tem 55 linhas...
			Cabec(Titulo,Cabec1,Cabec2,NomeProg,Tamanho,nTipo)
			nLin := 8
			@nlin,005 psay "De data de produção - " + dtoc(mv_par05) + " - até - " + dtoc(mv_par06)
			nlin+=2
		Endif

		if !empty(mv_par04)
			if _Balan = .f.
				@nlin,000   psay "Balança: " + mv_par04
				nlin += 2  
				_Balan := .t.
			endif
		endif

		if _Arm != PROD->FARM   
			if !empty(_Arm)
				nlin += 2  
			endif
			do case
				case PROD->FARM = 'R'
				@nlin,001 psay 'RESFRIADOS:'
				case PROD->FARM = 'C'
				@nlin,001 psay 'CONGELADOS:'
				case PROD->FARM = 'S'
				@nlin,001 psay 'SALGADOS:'
			endcase
			_Arm := PROD->FARM
			nlin++
		endif

		if _Grupo != PROD->GRUPO
			nlin++
			@nlin,001 psay "Grupo: " + GetAdvFVal('SB1','B1_GRUPO',FWxfilial('SB1')+PROD->COD,1)+ '  ' + PROD->GRUPO
			_Grupo := PROD->GRUPO
			nlin++
		endif

		@nlin,001 psay substr(PROD->COD,1,6)
		@nlin,010 psay substr(PROD->DESCRI,1,30)
		@nlin,050 psay transform(PROD->CAIX,'@E 9,999')      
		if mv_par12 = 1
			@nlin,055 psay transform(PROD->QUANT,'@E 9,999,999')
		endif
		@nlin,070 psay transform(PROD->PESO,'@E 999,999.99')

		SG1->(DbSetOrder(1))
		SG1->(DbGoTop())
		if SG1->(MsSeek(FWxfilial('SG1')+alltrim(PROD->COD)))

			while SG1->(!eof()) .and. alltrim(SG1->G1_COD) = alltrim(PROD->COD) 

				if !('PP' $ SG1->G1_COMP)  
					DbSelectArea('SB1')
					_cDesc  := GetAdvFVal('SB1','B1_DESC',FWxfilial('SB1')+SG1->G1_COMP,1)
					_cGrupo := GetAdvFVal('SB1','B1_GRUPO',FWxfilial('SB1')+SG1->G1_COMP,1)

					//Somente grupos de produtos de embalagem secundaria 
					if _cGrupo $ '1201/1202'
						@nlin,086 psay _cDesc
						exit
					endif
				endif 

				SG1->(DbSkip())  

			enddo
		endif     

		nlin++ 

		_TotCaix += PROD->CAIX
		_TotPeso += PROD->PESO

		PROD->(dbSkip()) // Avanca o ponteiro do registro no arquivo 

	EndDo

	If nLin > 75 // Salto de Página. Neste caso o formulario tem 55 linhas...
		Cabec(Titulo,Cabec1,Cabec2,NomeProg,Tamanho,nTipo)
		nLin := 8
		@nlin,005 psay "De data de produção - " + dtoc(mv_par05) + " - até - " + dtoc(mv_par06)
		nlin+=2
	Endif 	

	nlin += 2
	@nlin,001 psay 'TOTAIS DO PERÍODO: --------------------> '
	@nlin,050 psay transform(_TotCaix,'@E 999,999')
	@nlin,065 psay transform(_TotPeso,'@E 999,999,999.99')

	nlin+=2

	//AQUI COMEÇA O BLOCO DE ESCRITA DOS PORCIONADOS
	Cabec(Titulo,Cabec1,Cabec2,NomeProg,Tamanho,nTipo)
	nLin := 8
	@nlin,005 psay "De data de produção - " + dtoc(mv_par05) + " - até - " + dtoc(mv_par06)
	nlin+=2

	@nlin,001 psay 'PORCIONADOS:'
	nlin++

	_TotCaix  := 0.00
	_TotPeso  := 0.00

	QRY->(dbGoTop())
	while QRY->(!eof())

		@nlin,001 psay substr(QRY->COD,1,6)
		@nlin,010 psay substr(QRY->DESCRI,1,30)
		@nlin,050 psay transform(QRY->CAIX,'@E 9,999')      
		@nlin,070 psay transform(QRY->PESO,'@E 999,999.99')
		nlin++
		_TotCaix += QRY->CAIX
		_TotPeso += QRY->PESO

		QRY->(dbSkip())
	enddo

	nlin += 2
	@nlin,001 psay 'TOTAIS DO PERÍODO: --------------------> '
	@nlin,050 psay transform(_TotCaix,'@E 999,999')
	@nlin,065 psay transform(_TotPeso,'@E 999,999,999.99')

	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
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


Static Function GeraPROD()

	if mv_par16 = 1

		if !empty(mv_par04)
			cQuery := "SELECT Z8_BALAN AS BALAN, BM_FARM AS FARM, BM_DESC AS GRUPO, Z8_CODORI AS COD,"
		else
			cQuery := "SELECT BM_FARM AS FARM, BM_DESC AS GRUPO, Z8_CODORI AS COD,"
		endif

		cQuery += " Z8_DESCRI AS DESCRI, COUNT(Z8_CODORI) AS CAIX,"
		cQuery += " SUM(Z8_PESO) AS PESO, "
		cQuery += " SUM(Z8_QUANT) AS QUANT "
		cQuery += " FROM " + RetSqlTab("SZ8") + ", " + RetSqlTab("SBM") + ", " + RetSqlTab("SB1") + ", " + RetSqlTab("SZU")
		cQuery += " WHERE B1_TIPO IN('PR','PA','PP') AND "
		cQuery += RetSQLFil('SB1') + " AND"
		cQuery += RetSQLFil('SBM') + " AND"
		cQuery += RetSQLFil('SZ8') + " AND"
		cQuery += " Z8_FILORI = '" + cFilAnt + "' AND"
		cQuery += RetSQLFil('SZU') + " AND"
		cQuery += " (Z8_DATA BETWEEN '" + DTOS(mv_par01) +"' AND '" + DTOS(mv_par02) + "') AND"
		cQuery += " (Z8_DATAP BETWEEN '" + DTOS(mv_par05) +"' AND '" + DTOS(mv_par06) + "') AND"
		cQuery += " Z8_DATAE = ' ' AND"
		cQuery += " ZU_NUM   = Z8_NUMPREV AND" 
		cQuery += " BM_GRUPO = B1_GRUPO AND B1_COD = Z8_CODORI"

		if mv_par10 = 1 
			cQuery += " AND Z8_TERC = 'S'"
		elseif mv_par10 = 2
			cQuery += " AND Z8_TERC <> 'S'"
		endif

		if mv_par11 = 1 
			cQuery += " AND ZU_TIPO = 'P'"
		elseif mv_par11 = 2
			cQuery += " AND ZU_TIPO = 'R'"
		endif

		If mv_par13 = 2 // Desossa(D/T/C/R)
			cQuery += " AND (B1_CORORI = 'D' OR B1_CORORI = 'T' OR B1_CORORI = 'C' OR B1_CORORI = 'R')"
		EndIf

		If mv_par13 = 3 // Miúdos
			cQuery += " AND B1_CORORI = 'M'"
		EndIf

		do case
			case mv_par03 = 1
			_Farm := 'R'
			case mv_par03 = 2
			_Farm := 'C'
			case mv_par03 = 3
			_Farm := 'S'
			otherwise
			_Farm := 'T'
		endcase

		if _Farm != 'T'
			cQuery += " AND BM_FARM = '" +_Farm + "'"
		endif

		if !empty(mv_par07)
			cQuery += " AND B1_FAM = '" +mv_par07 + "'"
		endif

		do case
			case mv_par08 = 1
			cQuery += " AND Z8_TF = 'S'"
			case mv_par08 = 2
			cQuery += " AND Z8_TF = 'N'"
		endcase

		do case
			case mv_par09 = 1
			cQuery += " AND B1_DESTINO = 'MI'"
			case mv_par09 = 2
			cQuery += " AND B1_DESTINO = 'ME'"
		endcase

		if mv_par14 = 2
			cQuery += " AND (Z8_DATAS <> '' AND Z8_ITEM = 'EST')"
		elseif mv_par14 = 3
			cQuery += " AND Z8_ITEM <> 'EST'"
		endif

		cQuery += " AND " + RetSQLDel('SB1') + " AND " + RetSQLDel('SZ8') + " AND " + RetSQLDel('SBM') + " AND " + RetSQLDel('SZU')

		if !empty(mv_par04)
			cQuery += " AND Z8_BALAN = '" + mv_par04 + "'"
			cQuery += " GROUP BY Z8_BALAN, BM_FARM, BM_DESC, Z8_CODORI, Z8_DESCRI"
			cQuery += " ORDER BY Z8_BALAN, BM_DESC, Z8_CODORI"
		else
			cQuery +=  " GROUP BY BM_FARM, BM_DESC, Z8_CODORI, Z8_DESCRI"
			cQuery +=  " ORDER BY BM_FARM, BM_DESC, Z8_CODORI"
		endif
	else
		if !empty(mv_par04)
			cQuery := "SELECT ZW_BALAN AS BALAN, BM_FARM AS FARM, BM_DESC AS GRUPO, ZW_COD AS COD,"
		else
			cQuery := "SELECT BM_FARM AS FARM, BM_DESC AS GRUPO, ZW_COD AS COD,"
		endif

		cQuery += " ZW_DESCRI AS DESCRI, COUNT(ZW_COD) AS CAIX,"
		cQuery += " SUM(ZW_PESO) AS PESO, "
		cQuery += " SUM(ZW_QUANT) AS QUANT "
		cQuery += " FROM " + RetSqlTab("SZW") + ", " + RetSqlTab("SBM") + ", " + RetSqlTab("SB1") + ", " + RetSqlTab("SZU")
		cQuery += " WHERE B1_TIPO IN('PR','PA','PP') AND "
		cQuery += RetSQLFil('SB1') + " AND"
		cQuery += RetSQLFil('SBM') + " AND"
		cQuery += RetSQLFil('SZW') + " AND"
		cQuery += RetSQLFil('SZU') + " AND"
		cQuery += " (ZW_DATA BETWEEN '" + DTOS(mv_par01) +"' AND '" + DTOS(mv_par02) + "') AND"
		cQuery += " (ZW_DATAP BETWEEN '" + DTOS(mv_par05) +"' AND '" + DTOS(mv_par06) + "') AND"
		cQuery += " ZW_DATAE = ' ' AND"
		cQuery += " ZU_NUM = ZW_NUMPREV AND" 
		cQuery += " BM_GRUPO = B1_GRUPO AND B1_COD = ZW_COD"

		if mv_par10 = 1 
			cQuery += " AND ZW_TERC = 'S'"
		elseif mv_par10 = 2
			cQuery += " AND ZW_TERC <> 'S'"
		endif

		if mv_par11 = 1 
			cQuery += " AND ZU_TIPO = 'P'"
		elseif mv_par11 = 2
			cQuery += " AND ZU_TIPO = 'R'"
		endif

		If mv_par13 = 2 // Desossa(D/T/C/R)
			cQuery += " AND (B1_CORORI = 'D' OR B1_CORORI = 'T' OR B1_CORORI = 'C' OR B1_CORORI = 'R')"
		EndIf

		If mv_par13 = 3 // Miúdos
			cQuery += " AND B1_CORORI = 'M'"
		EndIf

		do case
			case mv_par03 = 1
			_Farm := 'R'
			case mv_par03 = 2
			_Farm := 'C'
			case mv_par03 = 3
			_Farm := 'S'
			otherwise
			_Farm := 'T'
		endcase

		if _Farm != 'T'
			cQuery += " AND BM_FARM = '" + _Farm + "'"
		endif

		if !empty(mv_par07)
			cQuery += " AND B1_FAM = '" + mv_par07 + "'"
		endif

		do case
			case mv_par08 = 1
			cQuery += " AND ZW_TF = 'S'"
			case mv_par08 = 2
			cQuery += " AND ZW_TF = 'N'"
		endcase

		do case
			case mv_par09 = 1
			cQuery += " AND B1_DESTINO = 'MI'"
			case mv_par09 = 2
			cQuery += " AND B1_DESTINO = 'ME'"
		endcase

		if mv_par14 = 2
			cQuery += " AND ZW_DATAE <> ''"
		elseif mv_par14 = 3
			cQuery += " AND ZW_DATAE = ''"
		endif

		if mv_par15 = 2
			cQuery += " AND ZW_DATAS <> ''"
		elseif mv_par15 = 3
			cQuery += " AND ZW_DATAS = ''"
		endif

		if mv_par15 = 2
			cQuery += " AND ZW_STRRX <> ''"
		elseif mv_par15 = 3
			cQuery += " AND ZW_STRRX = ''"
		endif

		cQuery += " AND " + RetSQLDel('SB1') + " AND " + RetSQLDel('SZW') + " AND " + RetSQLDel('SBM') + " AND " + RetSQLDel('SZU')

		if !empty(mv_par04)
			cQuery += " AND ZW_BALAN = '" + mv_par04 + "'"
			cQuery += " GROUP BY ZW_BALAN, BM_FARM, BM_DESC, ZW_COD, ZW_DESCRI"
			cQuery += " ORDER BY ZW_BALAN, BM_DESC, ZW_COD"
		else
			cQuery +=  " GROUP BY BM_FARM, BM_DESC, ZW_COD, ZW_DESCRI"
			cQuery +=  " ORDER BY BM_FARM, BM_DESC, ZW_COD"
		endif
	endif

	cQuery := ChangeQuery(cQuery)

	//	* Mostrar a consulta */
	//@ 116,090 To 416,707 Dialog oDlgMemo Title "Consulta"
	//@ 055,005 Get cQuery Size 250,080 MEMO Object oMemo
	//Activate Dialog oDlgMemo

	If Select("PROD") != 0
		PROD->(dbCloseArea())
	Endif
	TCQUERY cQuery NEW ALIAS "PROD"

Return


static function filtraMP()

	_cQuery2 := " SELECT ZAS_DESC AS DESCRI, COUNT(ZAS_COD) AS CAIX, SUM(ZAS_PESOL) AS PESO, ZAS_COD AS COD"
	_cQuery2 += " FROM " + retSqlTab('ZAS') 
	_cQuery2 += " WHERE " + retSqlFil('ZAS')
	_cQuery2 += " AND ZAS_DTPROD BETWEEN '" + dtos(mv_par05) +"' AND '" + dtos(mv_par06) + "'"
	_cQuery2 += " AND ZAS_TF = 'S'"
	_cQuery2 += " AND " + retSqlDel('ZAS')
	_cQuery2 += " GROUP BY ZAS_DESC, ZAS_COD"

	_cQuery2 := ChangeQuery(_cQuery2)

	//	* Mostrar a consulta */
	//@ 116,090 To 416,707 Dialog oDlgMemo Title "Consulta"
	//@ 055,005 Get cQuery Size 250,080 MEMO Object oMemo
	//Activate Dialog oDlgMemo
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Monta a interface padrao com o usuario...                           ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ   

	If Select("QRY") != 0
		QRY->(dbCloseArea())
	Endif

	TCQUERY _cQuery2 NEW ALIAS "QRY"

return
