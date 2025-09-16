#INCLUDE "rwmake.ch"
#INCLUDE "topconn.ch"

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³GJF38     º Autor Giuliano Forgiarini  º Data ³  06/06/08   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDescricao ³Relatorio que lista, por cliente os títulos vencidos e a    º±±
±±º          vencer.                                                      º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³sigafin                                                     º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/

User Function GJF38()

	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Declaracao de Variaveis                                             ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ

	Local cDesc1         := "Este programa tem como objetivo imprimir relatorio "
	Local cDesc2         := "de títulos a receber vencidos ou a vencer, por     "
	Local cDesc3         := "cliente, de acordo com os parametros"
	Local cPict          := ""
	Local titulo         := "Posição de Vencimento"
	Local nLin           := 80

	Local Cabec1         := "Codigo   Razão Social               Vlr. Vencidos   Vlr. a Vencer     Total"
	Local Cabec2         := ""
	Local imprime        := .T.
	Local aOrd := {}
	Private lEnd         := .F.
	Private lAbortPrint  := .F.
	Private CbTxt        := ""
	Private limite       := 80
	Private tamanho      := "P"
	Private nomeprog     := "GJF38" // Coloque aqui o nome do programa para impressao no cabecalho
	Private nTipo        := 18
	Private aReturn      := { "Zebrado", 1, "Administracao", 2, 2, 1, "", 1}
	Private nLastKey     := 0
	Private cPerg        := "GJF38"
	Private cbtxt        := Space(10)
	Private cbcont       := 00
	Private CONTFL       := 01
	Private m_pag        := 01
	Private wnrel        := "GJF38" // Coloque aqui o nome do arquivo usado para impressao em disco

	Private cString := "SA1"

	dbSelectArea("SA1")
	dbSetOrder(1)

	pergunte(cPerg,.F.)

	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Monta a interface padrao com o usuario...                           ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ

	wnrel := SetPrint(cString,NomeProg,cPerg,titulo,cDesc1,cDesc2,cDesc3,.T.,aOrd,.T.,Tamanho,,.T.)

	If nLastKey == 27
		Return
	Endif

	SetDefault(aReturn,cString)

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

	Sub1   := 0
	Sub2   := 0
	total  := 0

	//query para listar os fornecedores e o total de titulos abertos
	cQuery := "SELECT E1_CLIENTE AS CLIENTE, SUM(E1_SALDO) AS VALOR"+;
	"  FROM "+RetSqlName("SE1")+" SE1"  +;
	"  WHERE SE1.D_E_L_E_T_ <> '*' " +;
	"  AND SE1.E1_CLIENTE BETWEEN '" + mv_par01 +"' AND " +" '" + mv_par02 + "'"+;
	"  AND SE1.E1_STATUS = 'A' "+;
	"  GROUP BY E1_CLIENTE "+;
	"  ORDER BY VALOR DESC"

	cQuery := ChangeQuery(cQuery)

	TCQUERY cQuery NEW ALIAS "QRY"

	QRY->(dbgotop())

	SetRegua(QRY->(RecCount()))

	flagV := .f.

	While QRY->(!EOF())

		IncRegua()

		dbselectarea('SA1')
		_nat := fBuscaCPO('SA1',1,xfilial('SA1')+QRY->CLIENTE,'A1_NATUREZ')
		SA1->(dbclosearea())

		if _nat < mv_par04 .or. _nat > mv_par05
			QRY->(dbskip())
			loop
		endif

		If lAbortPrint
			@nLin,00 PSAY "*** CANCELADO PELO OPERADOR ***"
			Exit
		Endif

		//query para listar os títulos vencidos
		cQuery1 := "SELECT SUM(E1_SALDO) AS VALOR "+;
		"  FROM "+RetSqlName("SE1")+" SE1"+;
		"  WHERE SE1.D_E_L_E_T_ <> '*' " +;
		"  AND SE1.E1_CLIENTE = '"+ QRY->CLIENTE +"'" +;
		"  AND SE1.E1_VENCTO <= " + DTOS(mv_par03)	+;
		"  AND SE1.E1_STATUS = 'A' "

		//query para listar os titulos a vencer
		cQuery2 := "SELECT SUM(E1_SALDO) AS VALOR "+;
		"  FROM "+RetSqlName("SE1")+" SE1"+;
		"  WHERE SE1.D_E_L_E_T_ <> '*' " +;
		"  AND SE1.E1_CLIENTE = '" + QRY->CLIENTE +"'"+;
		"  AND SE1.E1_VENCTO > " + DTOS(mv_par03) +;
		"  AND SE1.E1_STATUS = 'A' "

		cQuery1 := ChangeQuery(cQuery1)
		cQuery2 := ChangeQuery(cQuery2)

		TCQUERY cQuery1 NEW ALIAS "QRY1"
		val1 := QRY1->VALOR
		QRY1->(dbclosearea())

		TCQUERY cQuery2 NEW ALIAS "QRY2"
		val2 := QRY2->VALOR
		QRY2->(dbclosearea())

		if empty(val1) .and. empty(val2)
			QRY->(dbskip())
			loop
		endif

		If nLin > 55 // Salto de Página. Neste caso o formulario tem 55 linhas...
			Cabec(Titulo,Cabec1,Cabec2,NomeProg,Tamanho,nTipo)
			nLin := 8
		Endif

		if !flagV
			@nLin,00 PSAY "Vencimento: " + dtoc(mv_par03)
			flagV := .t.
			nlin += 2
		endif

		@nlin,00 psay QRY->CLIENTE
		dbselectarea('SA1')
		_nome := fBuscaCPO('SA1',1,xfilial('SA1')+QRY->CLIENTE,'A1_NOME')
		SA1->(dbclosearea())
		if len(alltrim(_nome)) > 20
			@nlin,10 psay substr(_nome,1,20) + '...'
		else
			@nlin,10 psay substr(_nome,1,20)
		endif

		@nlin,35 psay val1       picture "@E 999,999,999.99"
		@nlin,50 psay val2       picture "@E 999,999,999.99"
		@nlin,65 psay QRY->VALOR picture "@E 999,999,999.99"

		sub1  += val1
		sub2  += val2
		total += QRY->VALOR

		nLin++ // Avanca a linha de impressao

		If Select("QRY1") != 0
			QRY1->(dbCloseArea())
		Endif
		If Select("QRY2") != 0
			QRY2->(dbCloseArea())
		Endif

		QRY->(dbSkip()) // Avanca o ponteiro do registro no arquivo

	EndDo

	If Select("QRY") != 0
		QRY->(dbCloseArea())
	Endif

	If nLin > 55 // Salto de Página. Neste caso o formulario tem 55 linhas...
		Cabec(Titulo,Cabec1,Cabec2,NomeProg,Tamanho,nTipo)
		nLin := 8
	Endif
	nlin++
	@nlin,00 psay "TOTAIS ------------------------->"
	@nlin,35 psay sub1  picture "@E 999,999,999.99"
	@nlin,50 psay sub2  picture "@E 999,999,999.99"
	@nlin,65 psay total picture "@E 999,999,999.99"

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
