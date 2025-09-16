#INCLUDE "rwmake.ch"
#INCLUDE "topconn.ch"

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³FBF12   º Autor ³ Flávio               º Data ³  27/01/09   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDescricao ³ R7 - Relatorio de Rastreabilidade - Produção da Embalagem  º±±
±±º          ³                                                            º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ Qualidade e PCP (SIGAPCP)                                  º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/

User Function FBF12()


	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Declaracao de Variaveis                                             ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ

	Local cDesc1         := "Este programa tem como objetivo imprimir relatorio  "
	Local cDesc2         := "de produção de caixas no setor de embalagem da empresa"
	Local cDesc3         := "para aplicação do processo de rastreabilidade bovina"
	Local cPict          := ""
	Local titulo         := "R7 - PRODUCAO DA EMBALAGEM"
	Local nLin           := 80
	Local Cabec1         := "Ordem de Matança e Previsões da Entrada da Desossa"                   
	Local Cabec2         := "Codigo   Produto                                                     Quant.     Caixas       Peso          "+;
	"Data Produção"
	Local imprime        := .T.
	Local aOrd := {}
	Private lEnd         := .F.
	Private lAbortPrint  := .F.
	Private CbTxt        := ""
	Private limite       := 132
	Private tamanho      := "M"
	Private nomeprog     := "FBF12" // Coloque aqui o nome do programa para impressao no cabecalho
	Private nTipo        := 18
	Private aReturn      := { "Zebrado", 1, "Administracao", 2, 2, 1, "", 1}
	Private nLastKey     := 0
	Private cPerg        := "FBF12"
	Private cbtxt       := Space(10)
	Private cbcont      := 00
	Private CONTFL      := 01
	Private m_pag       := 01
	Private wnrel       := "FBF12" // Coloque aqui o nome do arquivo usado para impressao em disco    
	Private _cNUMAM     := ''
	Private _cPreDes    := '' 
	Private _cClassif   := ''
	Private _cTipifi    := ''
	Private _cDescCort  := '' 
	Private _cDescProd  := ''
	Private _nQtPecas   := 0.00

	pergunte(cPerg,.F.)

	wnrel := SetPrint('SZ8',NomeProg,cPerg,@titulo,cDesc1,cDesc2,cDesc3,.T.,aOrd,.T.,Tamanho,,.T.)

	//para verificação se existe previsao de pesagem

	cQuery := " SELECT Z2_NUMAM AS NUMAM, Z2_NUM AS PREDES, Z8_COD AS COD, SUM(Z8_PESO) AS PESO, "
	cQuery += " SUM(Z8_QUANT) AS QUANT, COUNT(Z8_CONTROL) AS CAIX,Z8_DATAP AS DATAP"
	cQuery += " FROM " + RetSqlName("SZ8") + ", " + RetSqlName("SZU")  + ", " + RetSqlName("SZ2")+","+RetSqlName("SB1")
	cQuery += " WHERE  SZ8010.D_E_L_E_T_ <> '*'      AND "
	cQuery += "        SZ2010.D_E_L_E_T_ <> '*'      AND "
	cQuery += "        SZU010.D_E_L_E_T_ <> '*'      AND "   
	cQuery += " Z2_FILIAL = '" + xFilial("SZ2") + "' AND "
	cQuery += " ZU_FILIAL = '" + xFilial("SZU") + "' AND " 
	cQuery += " B1_FILIAL = '" + xFilial("SB1") + "' AND "                                                          
	cQuery += " Z8_FILIAL = '" + xFilial("SZ8") + "' AND " 
	cQuery += " Z8_NUMPREV = ZU_NUM AND"    
	cQuery += " Z8_PREDES  = Z2_NUM AND"          
	cQuery += " (ZU_NUM   BETWEEN '" + mv_par03 + "' AND '" + mv_par04 + "') AND"                                                         
	cQuery += " (Z2_NUM   BETWEEN '" + mv_par05 + "' AND '" + mv_par06 + "') AND" 
	cQuery += " (Z8_DATAP BETWEEN '" + DTOS(mv_par07) + "' AND '" + DTOS(mv_par08) + "')" 
	//mv_par02    NUMAM
	if !empty(mv_par01)
		cQuery += " AND Z2_CLASSIF  = '" + mv_par01 + "'"
	endif
	if !empty(mv_par02)
		cQuery += " AND Z2_NUMAM  = '" + mv_par02 + "'"
	endif
	cQuery += " GROUP BY Z2_NUMAM, Z2_NUM, Z8_COD, Z8_DATAP "  
	cQuery += " ORDER BY Z2_NUMAM, Z2_NUM, Z8_COD, Z8_DATAP"

	//cQuery += " (Z2_NUMAM BETWEEN '" + mv_par01 + "' AND '" + mv_par02 + "') AND" 
	cQuery := ChangeQuery(cQuery)

	/* Mostrar a consulta */
	//@ 116,090 To 416,707 Dialog oDlgMemo Title "Consulta"
	//@ 055,005 Get cQuery Size 250,080 MEMO Object oMemo
	//Activate Dialog oDlgMemo
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Monta a interface padrao com o usuario...                           ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ   


	If Select("EMB") != 0
		EMB->(dbCloseArea())
	Endif
	TCQUERY cQuery NEW ALIAS "EMB"

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

	EMB->(dbGoTop())

	EMB->(SetRegua(RecCount()))

	_NumIF := GetMv("MV_NUMIF")

	While EMB->(!EOF())

		incregua()

		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³ Verifica o cancelamento pelo usuario...                             ³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ

		If lAbortPrint
			@nLin,00 PSAY "*** CANCELADO PELO OPERADOR ***"
			Exit
		Endif


		If nLin > 55 // Salto de Página. Neste caso o formulario tem 55 linhas...
			Cabec(Titulo,Cabec1,Cabec2,NomeProg,Tamanho,nTipo)
			nLin := 9
		Endif 

		if _cNUMAM <> EMB->NUMAM
			_cNUMAM   := EMB->NUMAM
			nlin++
			@nlin,00 psay replicate('=',132)
			nlin++
			_dDtAbate := dtoc(fBuscaCPO('SZG',1,xfilial('SZG') + _cNUMAM,'ZG_DATA'))
			_cDiaAM   := substr(_dDtAbate,1,2)
			_cMesAM   := substr(_dDtAbate,4,2)
			_cAnoAM   := substr(_dDtAbate,7,2) 
			_cRastro := _NumIF + _cDiaAM + _cMesAM + _cAnoAM +'0000'
			@nlin,01 psay 'Ordem de Matança: ' + EMB->NUMAM + '   ' + 'Data de Abate: ' + _dDtAbate
			nlin++
			@nlin,01 psay 'Rastreabilidade:  ' + _cRastro
			nlin++
			@nlin,00 psay replicate('=',132)
			nlin += 2
		endif  
		if _cPreDes <> EMB->PREDES
			_cPreDes   := EMB->PREDES
			_cClassif  := fbuscaCPO('SZ2',2,xfilial('SZ2')+EMB->PREDES,'Z2_CLASSIF')
			_cTipifi   := fbuscaCPO('SZ2',2,xfilial('SZ2')+EMB->PREDES,'Z2_TIPIFI') 
			_cDescCort := fbuscaCPO('SZ2',2,xfilial('SZ2')+EMB->PREDES,'Z2_DESCRI') 
			//_nQtPecas  := fbuscaCPO('SZ2',2,xfilial('SZ2')+EMB->PREDES,'Z2_QRPECA') 
			@nlin,01 psay 'Prev. Prod. Desossa: ' + EMB->PREDES + '   ' + 'Corte de Origem: ' + _cDescCort
			nlin++
			@nlin,01 psay 'Classificação:       ' + _cClassif + '   ' + iif(!empty(_cTipifi),'Tipif.: '+_cTipifi,'')  
			nlin++ 
			@nlin,00 psay replicate('-',132)
			nlin++
		endif 
		_cDescProd := fBuscaCPO('SB1',1,xfilial('SB1')+ EMB->COD,'B1_DESC')
		@nlin,01 psay alltrim(EMB->COD)  
		@nlin,10 psay substr(_cDescProd,1,55)
		@nlin,70 psay EMB->QUANT
		@nlin,80 psay EMB->CAIX
		@nlin,90 psay transform(EMB->PESO,'@E 99,999,999.99')
		@nlin,110 psay stod(EMB->DATAP)
		nlin++

		EMB->(dbSkip()) // Avanca o ponteiro do registro no arquivo 
		if EMB->PREDES <> _cPreDes
			@nlin,00 psay replicate('-',132)
			nlin++
		endif
	EndDo

	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Finaliza a execucao do relatorio...                                 ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ

	DbCloseArea('EMB')

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
