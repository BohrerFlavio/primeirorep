#INCLUDE "rwmake.ch"
#INCLUDE "topconn.ch"

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³GJF23     º Autor ³ Giuliano Forgiariniº Data ³  09/06/10   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDescricao ³ Relatorio de Posição de Estoque de PA Versão 2             º±±
±±º          ³                                                            º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ Comercial e expedições (SIGAPCP e SIGAOMS)                 º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/

User Function GJF23()


	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Declaracao de Variaveis                                             ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ

	Local cDesc1         := "Este programa tem como objetivo imprimir relatorio"
	Local cDesc2         := "de Posição de Estoque de Produto Acabado (Caixas) "
	Local cDesc3         := "produzidas, estocadas e expedidas de acordo com o "
	Local cPict          := "período declarado."
	Local titulo         := "RELATORIO DE POSICAO DE ESTOQUE DE PA"
	Local nLin           := 80

	Local Cabec1       := "                                                          "+;
	"Posição Enterior   |         Entrada        | Transferencia Entrada  "+;
	"|          Saída         | Transferencia Saida    "+;
	"|      Posição Final     |"

	Local Cabec2       := "                                                          "+;
	"Caixas      Peso   |     Caixas      Peso   |     Caixas      Peso   "+;
	"|     Caixas      Peso   |     Caixas      Peso   "+;
	"|     Caixas      Peso   |"

	Local imprime       := .T.
	Local aOrd          := {}
	Private lEnd        := .F.
	Private lAbortPrint := .F.
	Private CbTxt       := ""
	Private limite      := 80
	Private tamanho     := "G"
	Private nomeprog    := "GJF23" // Coloque aqui o nome do programa para impressao no cabecalho
	Private nTipo       := 18
	Private aReturn     := { "Zebrado", 1, "Administracao", 2, 2, 1, "", 1}
	Private nLastKey    := 0
	Private cPerg       := "GJF42"
	Private cbtxt       := Space(10)
	Private cbcont      := 00
	Private CONTFL      := 01
	Private m_pag       := 01
	Private wnrel       := "GJF23" // Coloque aqui o nome do arquivo usado para impressao em disco    
	Private TotCaix     := 0.00
	Private TotPeso     := 0.00 
	Private _QUANT      := 0
	Private _PESO       := 0
	Private _QUANT2     := 0
	Private _PESO2      := 0

	pergunte(cPerg,.F.)

	wnrel := SetPrint('ZA2',NomeProg,cPerg,@titulo,cDesc1,cDesc2,cDesc3,.T.,aOrd,.T.,Tamanho,,.T.)  

	do case
		case mv_par03 = 1
		fArm := 'R'
		case mv_par03 = 2
		fArm := 'C'
		case mv_par03 = 3
		fArm := 'S'
		otherwise
		fArm := 'T'
	endcase            

	//para verificação se existe previsao de pesagem
	cQuery := " SELECT  BM_FARM AS FARM, B1_GRUPO AS GRUPO, B1_COD AS COD, B1_POSIPI AS POSIPI, B1_CLEBER AS CLEBER, "

	//Estoque inicial
	cQuery += " (SELECT ZA2_QTEST FROM " + RetSQLTab('ZA2') + " WHERE " + RetSQLDel('ZA2') + " AND " 
	cQuery += " ZA2_DATA = '" + dtos(mv_par01) + "' AND B1_COD = ZA2_COD AND "
	cquery +=  RetSQLFil('ZA2') + ") AS  EST_CAIX,"

	cQuery += " (SELECT ZA2_PESEST FROM " + RetSQLTab('ZA2') + " WHERE " +  RetSQLDel('ZA2') + " AND " 
	cQuery += " ZA2_DATA = '" + dtos(mv_par01) + "' AND B1_COD = ZA2_COD AND "
	cquery +=  RetSQLFil('ZA2') + ") AS  EST_PESO,"

	//Entradas do período
	cQuery += " (SELECT SUM(ZA2_QTENT) FROM " + RetSQLTab("ZA2") + " WHERE " + RetSQLDel('ZA2') + " AND " 
	cQuery += " (ZA2_DATA BETWEEN '" + dtos(mv_par01) + "' AND '" + dtos(mv_par02) + "') AND B1_COD = ZA2_COD AND "
	cquery += RetSQLFil('ZA2') + ") AS  ENT_CAIX,"

	cQuery += " (SELECT SUM(ZA2_PESENT) FROM " + RetSQLTab("ZA2") + " WHERE " + RetSQLDel('ZA2') + " AND " 
	cQuery += " (ZA2_DATA BETWEEN '" + dtos(mv_par01) + "' AND '" + dtos(mv_par02) + "') AND B1_COD = ZA2_COD AND "
	cquery += RetSQLFil('ZA2') + ") AS  ENT_PESO,"

	//Saídas do período
	cQuery += " (SELECT SUM(ZA2_QTSAI) FROM " + RetSQLTab("ZA2") + " WHERE " + RetSQLDel('ZA2') + " AND " 
	cQuery += " (ZA2_DATA BETWEEN '" + dtos(mv_par01) + "' AND '" + dtos(mv_par02) + "') AND B1_COD = ZA2_COD AND "
	cquery += RetSQLFil('ZA2') + ") AS  SAI_CAIX,"

	cQuery += " (SELECT SUM(ZA2_PESSAI) FROM " + RetSQLTab("ZA2") + " WHERE " + RetSQLDel('ZA2') + " AND " 
	cQuery += " (ZA2_DATA BETWEEN '" + dtos(mv_par01) + "' AND '" + dtos(mv_par02) + "') AND B1_COD = ZA2_COD AND "
	cquery += RetSQLFil('ZA2') + ") AS  SAI_PESO,"

	//Transferencias de entrada do período
	cQuery += " (SELECT SUM(ZA2_QTRANE) FROM " + RetSQLTab("ZA2") + " WHERE " + RetSQLDel('ZA2') + " AND " 
	cQuery += " (ZA2_DATA BETWEEN '" + dtos(mv_par01) + "' AND '" + dtos(mv_par02) + "') AND B1_COD = ZA2_COD AND "
	cQuery += RetSQLFil('ZA2') + ") AS  TRAN_ENT_CAIX,"

	cQuery += " (SELECT SUM(ZA2_PTRANE) FROM " + RetSQLTab("ZA2") + " WHERE "  + RetSQLDel('ZA2') + " AND " 
	cQuery += " (ZA2_DATA BETWEEN '" + dtos(mv_par01) + "' AND '" + dtos(mv_par02) + "') AND B1_COD = ZA2_COD AND "
	cquery += RetSQLFil('ZA2') + ") AS  TRAN_ENT_PESO,"

	//Transferencias de saídas do período

	cQuery += " (SELECT SUM(ZA2_QTRANS) FROM " + RetSQLTab("ZA2") + " WHERE "  + RetSQLDel('ZA2') + " AND " 
	cQuery += " (ZA2_DATA BETWEEN '" + dtos(mv_par01) + "' AND '" + dtos(mv_par02) + "') AND B1_COD = ZA2_COD AND "
	cquery += RetSQLFil('ZA2') + ") AS  TRAN_SAI_CAIX,"

	cQuery += " (SELECT SUM(ZA2_PTRANS) FROM " + RetSQLTab("ZA2") + " WHERE "  + RetSQLDel('ZA2') + " AND " 
	cQuery += " (ZA2_DATA BETWEEN '" + dtos(mv_par01) + "' AND '" + dtos(mv_par02) + "') AND B1_COD = ZA2_COD AND "
	cquery += RetSQLFil('ZA2') + ") AS  TRAN_SAI_PESO"


	cQuery += " FROM "  + RetSQLTab('SB1') +  ", "  + RetSQLTab('SBM')
	cQuery += " WHERE " +  RetSQLDel('SB1') + " AND " 
	cQuery +=              RetSQLDel('SBM')
	cQuery += " AND B1_TIPO IN('PA','PR') AND " + RetSQLFil('SB1')
	cQuery += " AND " + RetSQLFil('SBM')
	cQuery += " AND BM_GRUPO = B1_GRUPO AND (B1_SEGUM = 'CX' OR B1_SEGUM = 'SC') AND B1_MSBLQL = 2 "


	if fArm != 'T'
		cQuery  += " AND BM_FARM = '" +fArm + "'"  
	endif

	if !empty(mv_par05)
		cQuery  += " AND B1_FAM = '" + mv_par05 + "'"    
	endif  

	if mv_par06 != 5
		do Case
			case mv_par06 = 1
			cQuery  += " AND B1_CORORI = 'T'"  
			case mv_par06 = 2
			cQuery  += " AND B1_CORORI = 'D'"  
			case mv_par06 = 3
			cQuery  += " AND B1_CORORI = 'C'"  
			case mv_par06 = 4
			cQuery  += " AND (B1_CORORI = 'R' OR B1_CORORI = 'M')" 
		endcase  
	endif

	if mv_par07 = 1
		cQuery  += " AND SUBSTRING(B1_GRUPO,1,1) IN('6','8')"
	elseif mv_par07 = 2
		cQuery += " AND SUBSTRING(B1_GRUPO,1,1) NOT IN('6','8')"
	endif

	if mv_par08 = 2
		cQuery  += " AND B1_CLEBER <> '' "
	endif

	//Filtra desossa, porcionados ou todos
	if mv_par09 = 1
		cQuery += " AND B1_GRUPO NOT IN('5611','5612','5613','5614','5621') "
	elseif  mv_par09 = 2
		cQuery += " AND B1_GRUPO IN('5611','5612','5613','5614','5621') "	   
	endif  

	if mv_par08 = 1
		cQuery  +=  " ORDER BY BM_FARM,B1_GRUPO,B1_COD"
	else
		cQuery  +=  " ORDER BY B1_CLEBER,B1_COD"
	endif



	cQuery  := ChangeQuery(cQuery)


	//	* Mostrar a consulta */
	// @ 116,090 To 416,707 Dialog oDlgMemo Title "Consulta"
	// @ 055,005 Get cQuery Size 250,080 MEMO Object oMemo
	// Activate Dialog oDlgMemo
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Monta a interface padrao com o usuario...                           ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ

	If Select("POS") != 0
		POS->(dbCloseArea())
	Endif
	TCQUERY cQuery NEW ALIAS "POS"

	If nLastKey == 27
		Return
	Endif

	SetDefault(aReturn,'ZA2')

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

	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ SETREGUA -> Indica quantos registros serao processados para a regua ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ

	POS->(SetRegua(RecCount()))

	POS->(dbGoTop())

	cGrupo := '' 
	_cFarm := ''

	While POS->(!EOF())


		incregua()

		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³ Verifica o cancelamento pelo usuario...                             ³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ

		If lAbortPrint
			@nLin,00 PSAY "*** CANCELADO PELO OPERADOR ***"
			Exit
		Endif

		if   mv_par04 = 2
			if  empty(POS->EST_CAIX) .and.;
			empty(POS->ENT_CAIX) .and.; 
			empty(POS->TRAN_ENT_CAIX)
				POS->(dbskip())
				loop  
			endif
		endif

		If nLin > 65 // Salto de Página. Neste caso o formulario tem 55 linhas...
			Cabec(Titulo,Cabec1,Cabec2,NomeProg,Tamanho,nTipo)
			nLin := 9
		Endif      

		if mv_par08 = 1	
			if _cFarm != POS->FARM
				nlin++    
				do case
					case POS->FARM = 'C'
					@nlin,001 psay 'CONGELADOS:'
					nlin++
					_cFarm := POS->FARM 
					case POS->FARM = 'R'
					@nlin,001 psay 'RESFRIADOS:'
					nlin++
					_cFarm := POS->FARM
					case POS->FARM = 'S'
					@nlin,001 psay 'SALGADOS:'
					nlin++
					_cFarm := POS->FARM  
				endcase
			endif

			if cGrupo != POS->GRUPO	
				nlin++
				@nlin,001 psay 'Grupo:  '+ POS->GRUPO + '  ' + fBuscaCPO('SBM',1,xfilial('SBM')+POS->GRUPO,'BM_DESC')
				nlin++
				cGrupo := POS->GRUPO
			endif     

		else
			if cGrupo != POS->CLEBER
				nlin++
				@nlin,001 psay POS->CLEBER + '  ' + fBuscaCPO('SX5',1,xfilial('SX5')+'ZA' + POS->CLEBER,'X5_DESCRI')
				nlin++
				cGrupo := POS->CLEBER
			endif     

		endif

		_SaldoCaix := POS->(EST_CAIX + ENT_CAIX + TRAN_ENT_CAIX - SAI_CAIX - TRAN_SAI_CAIX)
		_SaldoPeso := POS->(EST_PESO + ENT_PESO + TRAN_ENT_PESO - SAI_PESO - TRAN_SAI_PESO )	

		@nlin,001 psay alltrim(POS->COD)
		if mv_par08 = 1
			@nlin,008 psay substr(fBuscaCPO('SB1',1,xfilial('SB1')+POS->COD,'B1_DESCRED'),1,30) 
			@nlin,041 psay 'NCM '+ alltrim(POS->POSIPI)
		else 
			@nlin,008 psay substr(fBuscaCPO('SB1',1,xfilial('SB1')+POS->COD,'B1_DCLEBER'),1,30) 
		endif
		@nlin,055 psay transform(POS->EST_CAIX          ,'@E 9,999')
		@nlin,065 psay transform(POS->EST_PESO          ,'@E 999,999.99') + '  |'
		@nlin,080 psay transform(POS->ENT_CAIX          ,'@E 9,999')
		@nlin,090 psay transform(POS->ENT_PESO          ,'@E 999,999.99') + '  |' 
		@nlin,105 psay transform(POS->TRAN_ENT_CAIX     ,'@E 9,999')
		@nlin,115 psay transform(POS->TRAN_ENT_PESO     ,'@E 999,999.99') + '  |'
		@nlin,130 psay transform(POS->SAI_CAIX          ,'@E 9,999')
		@nlin,140 psay transform(POS->SAI_PESO          ,'@E 999,999.99') + '  |'
		@nlin,155 psay transform(POS->TRAN_SAI_CAIX     ,'@E 9,999')
		@nlin,165 psay transform(POS->TRAN_SAI_PESO     ,'@E 999,999.99') + '  |'                                           
		@nlin,180 psay transform(_SaldoCaix             ,'@E 9,999')
		@nlin,195 psay transform(_SaldoPeso             ,'@E 999,999.99') + '  |'
		nlin++

		POS->(dbSkip()) // Avanca o ponteiro do registro no arquivo 

	EndDo

	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Finaliza a execucao do relatorio...                                 ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ

	DbCloseArea('POS')

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
