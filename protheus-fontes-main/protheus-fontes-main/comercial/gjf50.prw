#INCLUDE "rwmake.ch"
#INCLUDE "topconn.ch"

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³GJF50   º Autor ³ Giuliano Forgiarini  º Data ³  14/09/08   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDescricao ³ Relatorio de expedição de caixas de PA                     º±±
±±º          ³                                                            º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ Comercial e expedições (SIGAPCP e SIGAOMS)                 º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/

User Function GJF50()


	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Declaracao de Variaveis                                             ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ

	Local cDesc1         := "Este programa tem como objetivo imprimir relatorio  "
	Local cDesc2         := "de expedição de caixas de acordo com o período informado"
	Local cDesc3         := "listando os valores agrupados por produtos trazendo os"
	Local cPict          := "totais de caixas e peso líquido expedidos"
	Local titulo       := "EXPEDIÇÃO DE CAIXAS"
	Local nLin         := 80

	Local Cabec1       := "Codigo      Descricao Produto                Qt.Caixas              Peso  "                   
	Local Cabec2       := ""

	Local imprime      := .T.
	Local aOrd := {}
	Private lEnd         := .F.
	Private lAbortPrint  := .F.
	Private CbTxt        := ""
	Private limite           := 80
	Private tamanho          := "P"
	Private nomeprog         := "GJF50" // Coloque aqui o nome do programa para impressao no cabecalho
	Private nTipo            := 18
	Private aReturn          := { "Zebrado", 1, "Administracao", 2, 2, 1, "", 1}
	Private nLastKey        := 0
	Private cPerg   := "GJF50"
	Private cbtxt      := Space(10)
	Private cbcont     := 00
	Private CONTFL     := 01
	Private m_pag      := 01
	Private wnrel      := "GJF50" // Coloque aqui o nome do arquivo usado para impressao em disco    
	Private TotCaix    := 0.00
	Private TotPeso    := 0.00

	pergunte(cPerg,.F.)

	//para verificação se existe previsao de pesagem

	wnrel := SetPrint('SZ8',NomeProg,cPerg,@titulo,cDesc1,cDesc2,cDesc3,.T.,aOrd,.T.,Tamanho,,.T.)

	cQuery := " SELECT BM_FARM AS FARM, BM_DESC AS GRUPO, Z8_COD AS COD,"+; 
	" Z8_DESCRI AS DESCRI, COUNT(Z8_COD) AS CAIX,"+;
	" SUM(Z8_PESO) AS PESO " +;
	" FROM " + RetSqlName("SZ8") + ", " + RetSqlName("SBM")  + ", " + RetSqlName("SB1") +;
	" WHERE SB1010.D_E_L_E_T_ <> '*' AND "+;
	"       SZ8010.D_E_L_E_T_ <> '*' AND "+;
	"       SBM010.D_E_L_E_T_ <> '*' AND "+;
	" B1_TIPO IN('PA','PR') AND "+;
	" B1_FILIAL = '" + xFilial("SB1") + "' AND"+;
	" BM_FILIAL = '" + xFilial("SBM") + "' AND"+;
	" Z8_FILIAL = '" + xFilial("SZ8") + "' AND"+; 
	" Z8_FIL = '"    + xFilial("SB1") + "' AND"+; 
	" (Z8_DATAS BETWEEN '" + DTOS(mv_par01) +"' AND '" + DTOS(mv_par02) + "') AND"+;  
	" Z8_DATAE = ' ' AND" +;
	" Z8_DATAS <> ' ' AND" +;          
	" Z8_PREPED <> 'ACERTO' AND" +; 
	" BM_GRUPO = B1_GRUPO AND B1_COD = Z8_COD"

	if mv_par04 = 1 
		cQuery += " AND Z8_TERC = 'S' "    
	elseif mv_par04 = 2
		cQuery += " AND Z8_TERC <> 'S' "    
	endif  

	if !empty(mv_par05)
		cQuery += " AND Z8_LOCAL = '" + mv_par05 + "'" 
	endif

	cQuery += " GROUP BY BM_FARM, BM_DESC, Z8_COD, Z8_DESCRI" +;
	" ORDER BY BM_FARM, BM_DESC, Z8_COD" 
	do case
		case mv_par03 = 1
		_Farm := 'C'
		case mv_par03 = 2
		_Farm := 'R'
		case mv_par03 = 3
		_Farm := 'S'
		otherwise
		_Farm := 'T'
	endcase     


	cQuery := ChangeQuery(cQuery)

	//	* Mostrar a consulta */
	//@ 116,090 To 416,707 Dialog oDlgMemo Title "Consulta"
	//@ 055,005 Get cQuery Size 250,080 MEMO Object oMemo
	//Activate Dialog oDlgMemo
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Monta a interface padrao com o usuario...                           ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ

	If Select("PROD") != 0
		POS->(dbCloseArea())
	Endif
	TCQUERY cQuery NEW ALIAS "PROD"


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

	Local nOrdem

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

		If nLin > 55 // Salto de Página. Neste caso o formulario tem 55 linhas...
			Cabec(Titulo,Cabec1,Cabec2,NomeProg,Tamanho,nTipo)
			nLin := 9
		Endif 

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
			@nlin,001 psay "Grupo: " + fBuscacpo('SB1',1,xfilial('SB1')+PROD->COD,'B1_GRUPO')+ '  ' + PROD->GRUPO
			_Grupo := PROD->GRUPO
			nlin++
		endif

		@nlin,001 psay PROD->COD
		@nlin,010 psay substr(PROD->DESCRI,1,30)
		@nlin,050 psay transform(PROD->CAIX,'@E 9,999')
		@nlin,065 psay transform(PROD->PESO,'@E 999,999.99')

		nlin++ 

		_TotCaix += PROD->CAIX
		_TotPeso += PROD->PESO

		PROD->(dbSkip()) // Avanca o ponteiro do registro no arquivo 

	EndDo

	Cabec(Titulo,Cabec1,Cabec2,NomeProg,Tamanho,nTipo)
	nLin := 9

	nlin += 2
	@nlin,001 psay 'TOTAIS DO PERÍODO: --------------------> '
	@nlin,050 psay transform(_TotCaix,'@E 999,999')
	@nlin,065 psay transform(_TotPeso,'@E 999,999.99')

	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Finaliza a execucao do relatorio...                                 ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ

	DbCloseArea('PROD')

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
