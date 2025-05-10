#INCLUDE "TOTVS.CH"
#INCLUDE "TOPCONN.CH"

//--------------------------------------------------------------------------------------
/*/{Protheus.doc} FS_REXP
@Type			: Função de Usuário
@Sample			: U_FS_REXP()
@Description	: Relatório de separação de caixas
@Param			: Nulo
@Return			: Nulo
@ --------------|-----------------------------------------------------------------------
@Author			: Evandro Mugnol
@Since			: Mai/2022
@version		: Protheus 12.1.33 e posteriores
@Comments		: N/A
/*/
//--------------------------------------------------------------------------------------
User Function FS_REXP()

	Local aArea   := GetArea()
	Local oReport

	Private cPerg := ""

	// Definições da pergunta
	cPerg := PADR("FS_REXP",10)

	Pergunte(cPerg,.T.)

	// Cria as definições do relatório
	oReport := RptDef()
	oReport:PrintDialog()

	RestArea(aArea)

Return

//-------------------------------------------------------------------
/*/{Protheus.doc} RptDef
Função que monta a definição do relatório
@Since      Mai/2022
/*/
//-------------------------------------------------------------------
Static Function RptDef()

	Local oReport
	Local oSection1 := Nil
	//Local oBreak 	:= Nil

	// Criação do componente de impressão
	oReport := TReport():New("FS_REXP",;													// Nome do Relatório
							 "SEPARAÇÃO DE CAIXAS REF. PRÉ-CARREGAMENTO " + mv_par01,;		// Título do Relatório
							 cPerg,;														// Tela de parametros
							 {|oReport| ReportPrint(oReport)},;								// Chama a função para imprimir o relatório
							 "Este programa tem o objetivo de imprimir dados para SEPARAÇÃO DE CAIXAS",;		// Descrição
							 /*lLandscape*/ , /*uTotalText*/ , /*lTotalInLine*/ , /*cPageTText*/ , /*lPageTInLine*/ , /*lTPageBreak*/;
							)

	oReport:HideFooter(.T.)
	oReport:HideParamPage(.F.)
	oReport:oPage:SetPaperSize(9) 	// Folha A4
	oReport:SetLandscape()

	// Criando a seção de dados
	oSection1 := TRSection():New(oReport,;
								 "Seção 1",;
								 {"QRY_SEC1"};
								)

	// Colunas do relatório
	TRCell():New(oSection1, "ZZ5_COD", 		"QRY_SEC1", "Produto", 			/*Picture*/, 26, /*lPixel*/,/*{|| code-block de impressao }*/,/*cAlign*/,/*lLineBreak*/,"LEFT",  /*lCellBreak*/,/*nColSpace*/,/*lAutoSize*/,/*nClrBack*/,/*nClrFore*/,/*lBold*/)
	TRCell():New(oSection1, "B1_DESC", 		"QRY_SEC1", "Descricao", 		/*Picture*/, 45, /*lPixel*/,/*{|| code-block de impressao }*/,/*cAlign*/,/*lLineBreak*/,"LEFT",  /*lCellBreak*/,/*nColSpace*/,/*lAutoSize*/,/*nClrBack*/,/*nClrFore*/,/*lBold*/)
	TRCell():New(oSection1, "PREVISTO", 	"QRY_SEC1", "Qtde PREVISTA", 	/*Picture*/, 25, /*lPixel*/,/*{|| code-block de impressao }*/,/*cAlign*/,/*lLineBreak*/,"RIGHT", /*lCellBreak*/,/*nColSpace*/,/*lAutoSize*/,/*nClrBack*/,/*nClrFore*/,/*lBold*/)
	TRCell():New(oSection1, "REALIZADO", 	"QRY_SEC1", "Qtde REALIZADA", 	/*Picture*/, 25, /*lPixel*/,/*{|| code-block de impressao }*/,/*cAlign*/,/*lLineBreak*/,"RIGHT", /*lCellBreak*/,/*nColSpace*/,/*lAutoSize*/,/*nClrBack*/,/*nClrFore*/,/*lBold*/)
	
	// Definindo a quebra
	//oBreak := TRBreak():New(oSection1,{|| QRY_SEC1->(ZZ5_COD) },{|| "SEPARACAO DO RELATORIO" })
	//oSection1:SetHeaderBreak(.T.)
	oSection1:OnPrintLine( {|| oReport:SkipLine() } )

Return oReport

//-------------------------------------------------------------------
/*/{Protheus.doc} ReportPrint
Função que imprime o relatório
@Since      Jan/2022
/*/
//-------------------------------------------------------------------
Static Function ReportPrint(oReport)

	Local aArea     := GetArea()
	Local cQuery    := ""
	Local nAtual    := 0
	Local nTotal    := 0
	Local oSection1 := oReport:Section(1)

	// Montando consulta de dados Seção 1
	cQuery := "SELECT ZZ5_COD, B1_DESC, SUM(ZZ5_QPCAIX) AS PREVISTO, " + CRLF
	cQuery += "        (SELECT COUNT(Z8_PICKING) " + CRLF
	cQuery += "		      FROM " + RetSQLTab("SZ8") + CRLF
	cQuery += "		     WHERE " + RetSQLFil("SZ8") + CRLF
	cQuery += "		       AND Z8_CARPICK = '" + mv_par01 + "'" + CRLF
	cQuery += "		       AND Z8_FIL = '" + cFilAnt + "'" + CRLF
	cQuery += "		       AND Z8_COD = ZZ5_COD " + CRLF  
	cQuery += "		       AND Z8_PICKING = 'S' " + CRLF
	cQuery += "		       AND " + RetSQLDel("SZ8") + ") AS REALIZADO " + CRLF
	cQuery += "  FROM " + RetSQLTab("ZZ4")+ "," + RetSQLTab("ZZ5") + CRLF
	cQuery += " INNER JOIN " + RetSqlTab("SB1") + " ON B1_FILIAL = '" + xFilial("SB1") + "' AND B1_COD = ZZ5_COD AND " + RetSQLDel("SB1") + CRLF
	cQuery += " WHERE " + RetSQLFil("ZZ4") + " AND " + RetSQLFil("ZZ5") + CRLF
	cQuery += "   AND ZZ4_PRECAR = '" + mv_par01 + "'" + CRLF
	cQuery += "   AND ZZ5_NUM = ZZ4_NUM " + CRLF  
	cQuery += "   AND " + RetSQLDel("ZZ4") + " AND " + RetSQLDel("ZZ5")	+ CRLF
	cQuery += " GROUP BY ZZ5_COD, B1_DESC " + CRLF
	cQuery += " ORDER BY ZZ5_COD, B1_DESC " + CRLF

	cQuery:= ChangeQuery(cQuery)

	//memowrite('c:\temp\query.txt',cQuery)

	If ( SELECT("QRY_SEC1") ) > 0
		dbSelectArea("QRY_SEC1")
		QRY_SEC1->(dbCloseArea())
	EndIf

	// Executando consulta e setando o total da régua
	TCQuery cQuery New Alias "QRY_SEC1"
	Count to nTotal
	oReport:SetMeter(nTotal)

	// Enquanto houver dados
	oSection1:Init()
	QRY_SEC1->(DbGoTop())
	While QRY_SEC1->(!Eof())
		// Incrementando a régua
		nAtual++
		oReport:SetMsgPrint("Imprimindo registro " + cValToChar(nAtual) + " de " + cValToChar(nTotal) + "...")
		oReport:IncMeter()

		// Imprimindo a linha atual
		oSection1:PrintLine()

		QRY_SEC1->(DbSkip())
	EndDo
	oSection1:Finish()
	QRY_SEC1->(DbCloseArea())

	RestArea(aArea)

Return
