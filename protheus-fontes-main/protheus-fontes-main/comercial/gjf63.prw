#INCLUDE "rwmake.ch"
#INCLUDE "topconn.ch"

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³GJF63     º Autor ³ Giuliano Forgiariniº Data ³  28/10/08   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDescricao ³ Relatorio de precos medios e descontos medios dos produtos º±±
±±º          ³                                                            º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ Comercial e expedições (SIGAPCP e SIGAOMS)                 º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/

User Function GJF63()


	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Declaracao de Variaveis                                             ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ

	Local cDesc1         := "Este programa tem como objetivo imprimir relatorio"
	Local cDesc2         := "de preços médios e descontos médios dos produtos  "
	Local cDesc3         := "acabados faturados de acordo com parametros       "
	Local cPict          := "informados pelo usuário"
	Local titulo       := "RELATORIO DE PREÇOS E DESCONTOS MÉDIOS"
	Local nLin         := 80

	Local Cabec1       := " Codigo Descricao                            Preço Medio   Des/Acr  Preço Medio"
	Local Cabec2       := "        do Produto                             Original     Médio    Praticado "
	Local imprime      := .T.
	Local aOrd := {}
	Private lEnd       := .F.
	Private lAbortPrint:= .F.
	Private CbTxt      := ""
	Private limite     := 80
	Private tamanho    := "P"
	Private nomeprog   := "GJF63" // Coloque aqui o nome do programa para impressao no cabecalho
	Private nTipo      := 18
	Private aReturn    := { "Zebrado", 1, "Administracao", 2, 2, 1, "", 1}
	Private nLastKey   := 0
	Private cPerg      := "GJF63"
	Private cbtxt      := Space(10)
	Private cbcont     := 00
	Private CONTFL     := 01
	Private m_pag      := 01
	Private wnrel      := "GJF63" // Coloque aqui o nome do arquivo usado para impressao em disco    
	Private TotCaix    := 0.00
	Private TotPeso    := 0.00

	pergunte(cPerg,.F.)

	If Select("PRC") != 0
		PRC->(dbCloseArea())
	Endif       

	_cQuery :=  ''
	wnrel := SetPrint('ZZ5',NomeProg,cPerg,@titulo,cDesc1,cDesc2,cDesc3,.T.,aOrd,.T.,Tamanho,,.T.)  

	_cQuery := " SELECT  B1_COD AS COD,B1_DESC AS DESCRI, " 
	//Bloco que faz o calculo do somatorio do que foi faturado
	_cQuery += " (SELECT SUM(ZZ5_PRECO*ZZ5_QPPESO)/SUM(ZZ5_QPPESO)"
	_cQuery += " FROM " + RetSqlName("ZZ5") + "," + RetSqlName("ZZ4") + "," + RetSqlName("SA1") 
	_cQuery += " WHERE "+RetSqlName("ZZ4")+".D_E_L_E_T_ <> '*'"
	_cQuery += " AND " + RetSqlName("ZZ5")+".D_E_L_E_T_ <> '*' AND "+RetSqlName("SA1")+".D_E_L_E_T_ <> '*' "  
	_cQuery += "      AND ZZ5_FILIAL = '" + xfilial('ZZ5') + "' AND ZZ4_FILIAL = '" + xfilial('ZZ4') + "'"
	_cQuery += "      AND ZZ4_NUM = ZZ5_NUM AND ZZ5_COD = B1_COD "    //anterior  
	_cQuery += "      AND ZZ4_TPOPER = 'V' AND ZZ4_STATUS = 'F'"    
	_cQuery += "      AND ZZ4_CODCLI = A1_COD AND  ZZ4_LOJA = A1_LOJA "
	_cQuery += "      AND ZZ4_CODCLI BETWEEN '" + mv_par04 + "' AND '" + mv_par06 + "'"
	_cQuery += "      AND ZZ4_LOJA   BETWEEN '" + mv_par05 + "' AND '" + mv_par07 + "'"  
	if !empty(mv_par10)
		_cQuery += " AND A1_TABELA = '" + mv_par10 + "'"
	endif
	_cQuery += "    AND ZZ4_DATAPV BETWEEN  '" + dtos(mv_par01) + "' AND '" + dtos(mv_par02) + "') AS PRECOM, "  

	_cQuery += " (SELECT SUM(CASE ZZ5_TPBONI WHEN 'D' THEN ZZ5_BONIF * (-1) WHEN 'A' THEN ZZ5_BONIF WHEN '' THEN 0 END * ZZ5_QPPESO)/SUM(ZZ5_QPPESO)"
	_cQuery += " FROM " + RetSqlName("ZZ5") + "," + RetSqlName("ZZ4") + "," +  RetSqlName("SA1") 
	_cQuery += " WHERE "+RetSqlName("ZZ4")+".D_E_L_E_T_ <> '*'"
	_cQuery += " AND " + RetSqlName("ZZ5")+".D_E_L_E_T_ <> '*' AND "+RetSqlName("SA1")+".D_E_L_E_T_ <> '*' "  
	_cQuery += "      AND ZZ5_FILIAL = '" + xfilial('ZZ5') + "' AND ZZ4_FILIAL = '" + xfilial('ZZ4') + "'"
	_cQuery += "      AND ZZ4_NUM = ZZ5_NUM AND ZZ5_COD = B1_COD "    //anterior  
	_cQuery += "      AND ZZ4_TPOPER = 'V' AND ZZ4_STATUS = 'F'"                
	_cQuery += "      AND ZZ4_CODCLI = A1_COD AND  ZZ4_LOJA = A1_LOJA "
	_cQuery += "      AND ZZ4_CODCLI BETWEEN '" + mv_par04 + "' AND '" + mv_par06 + "'"
	_cQuery += "      AND ZZ4_LOJA   BETWEEN '" + mv_par05 + "' AND '" + mv_par07 + "'"  
	if !empty(mv_par10)
		_cQuery += " AND A1_TABELA = '" + mv_par10 + "'"
	endif
	_cQuery += "      AND ZZ4_DATAPV BETWEEN  '" + dtos(mv_par01) + "' AND '" + dtos(mv_par02) + "') AS BONIM "   

	_cQuery += " FROM " + RetSqlName("SB1") 
	_cQuery += " WHERE B1_TIPO IN('PR','PA') AND B1_FILIAL = '" + xFilial("SB1") +"'"
	_cQuery += "      AND B1_SEGUM = 'CX' AND B1_MSBLQL = 2 "

	if !empty(mv_par08)
		_cQuery += " AND B1_FAM = '" +mv_par08 + "'"    
	endif

	if mv_par09 = 1
		_cQuery += " ORDER BY B1_COD, B1_DESC"
	else
		_cQuery += " ORDER BY B1_DESC, B1_COD"
	endif   

	_cQuery := ChangeQuery(_cQuery)
	//	* Mostrar a consulta */
	//@ 116,090 To 416,707 Dialog oDlgMemo Title "Consulta"
	//@ 055,005 Get _cQuery Size 250,080 MEMO Object oMemo
	//Activate Dialog oDlgMemo
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Monta a interface padrao com o usuario...                           ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ



	If Select("PRC") != 0
		PRC->(dbCloseArea())
	Endif
	TCQUERY _cQuery NEW ALIAS "PRC"


	If nLastKey == 27
		Return
	Endif

	SetDefault(aReturn,'ZZ5')

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

	PRC->(SetRegua(RecCount()))

	PRC->(dbGoTop())

	While PRC->(!EOF())

		incregua()

		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³ Verifica o cancelamento pelo usuario...                             ³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		if mv_par03 = 2
			if empty(PRC->PRECOM) .and. empty(PRC->BONIM)
				PRC->(dbskip())
				loop
			endif
		endif



		If lAbortPrint
			@nLin,00 PSAY "*** CANCELADO PELO OPERADOR ***"
			Exit
		Endif


		If nLin > 55 // Salto de Página. Neste caso o formulario tem 55 linhas...
			Cabec(Titulo,Cabec1,Cabec2,NomeProg,Tamanho,nTipo)
			nLin := 9
		Endif      
		//Inclusão da tabela	
		@nlin,001 psay alltrim(PRC->COD)
		@nlin,008 psay substr(PRC->DESCRI,1,35)
		@nlin,049 psay transform(PRC->PRECOM,'@E 99.99')
		@nlin,059 psay transform(PRC->BONIM,'@E 99.99')
		@nlin,069 psay transform(PRC->(PRECOM + BONIM),'@E 99.99')

		nlin++	 
		PRC->(dbSkip()) // Avanca o ponteiro do registro no arquivo 

	EndDo

	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Finaliza a execucao do relatorio...                                 ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ

	DbCloseArea('PRC')

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
