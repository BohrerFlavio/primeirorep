#INCLUDE "rwmake.ch"
#INCLUDE "topconn.ch"

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³GJF86     º Autor Giuliano Forgiarini  º Data ³  16/06/09   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDescricao ³Relatorio de análise de crédito por cliente                 º±±
±±º                                                                       º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³sigafin                                                     º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/

User Function GJF86()

	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Declaracao de Variaveis                                             ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ

	Local cDesc1         := "Este programa tem como objetivo imprimir relatorio "
	Local cDesc2         := "para auxiliar na análise de credito dos clientes   "
	Local cDesc3         := " de acordo com os parametros"
	Local cPict          := ""
	Local titulo         := "Análise de Crédito"
	Local nLin           := 80

	Local Cabec1         := "  Dados do Cliente e Condição de Pagamento"
	Local Cabec2         := "           Titulo       Parcela        Valor          Emissão         Vencto         Baixa         Saldo"
	Local imprime        := .T.
	Local aOrd := {}
	Private lEnd         := .F.
	Private lAbortPrint  := .F.
	Private CbTxt        := ""
	Private limite       := 132
	Private tamanho      := "M"
	Private nomeprog     := "GJF86" // Coloque aqui o nome do programa para impressao no cabecalho
	Private nTipo        := 18
	Private aReturn      := { "Zebrado", 1, "Administracao", 2, 2, 1, "", 1}
	Private nLastKey     := 0
	Private cPerg        := "GJF86"
	Private cbtxt        := Space(10)
	Private cbcont       := 00
	Private CONTFL       := 01
	Private m_pag        := 01
	Private wnrel        := "GJF86" // Coloque aqui o nome do arquivo usado para impressao em disco

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
	Local _cCond
	Local _cNome
	Local _cDesC
	Local _cCli   := Space(1)
	Local _cRel   := Space(1)
	Local _nTotal := 0.00

	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ SETREGUA -> Indica quantos registros serao processados para a regua ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ

	//query para listar os fornecedores e o total de titulos abertos
	cQuery := " SELECT E1_CLIENTE AS CLIENTE, E1_LOJA AS LOJA, E1_NUM AS NUM, E1_PARCELA AS PARCELA,"
	cQuery += " E1_EMISSAO AS EMISSAO, E1_VENCTO AS VENCTO,E1_BAIXA AS BAIXA,E1_SALDO AS SALDO,"
	cQuery += " E1_VALOR AS VALOR"
	cQuery += " FROM "+RetSqlName("SE1")+" SE1"  
	cQuery += " WHERE SE1.D_E_L_E_T_ <> '*' " 
	cQuery += " AND SE1.E1_EMISSAO BETWEEN '" + dtos(mv_par01) +"' AND " +" '" + dtos(mv_par01 + 30) + "'"
	cQuery += " AND SE1.E1_CLIENTE BETWEEN '" + mv_par02 +"' AND " +" '" + mv_par03 + "'"
	cQuery += " AND SE1.E1_TIPO = 'NF' "
	cQuery += " ORDER BY E1_CLIENTE, E1_LOJA, E1_NUM, E1_PARCELA, E1_EMISSAO, E1_VENCTO"

	cQuery := ChangeQuery(cQuery)

	TCQUERY cQuery NEW ALIAS "QRY"

	QRY->(dbgotop())

	SetRegua(QRY->(RecCount()))

	While QRY->(!EOF())

		IncRegua()

		dbselectarea('SA1')

		_cCond  := fBuscaCPO('SA1',1,xfilial('SA1')+QRY->(CLIENTE+LOJA),'A1_COND')
		_cNome  := fBuscaCPO('SA1',1,xfilial('SA1')+QRY->(CLIENTE+LOJA),'A1_NOME') 

		SA1->(dbclosearea()) 

		dbselectarea('SE4')	
		_cDesC  := fBuscaCPO('SE4',1,xfilial('SE4')+_cCond,'E4_COND')
		dbselectarea('SE4')   

		If lAbortPrint
			@nLin,00 PSAY "*** CANCELADO PELO OPERADOR ***"
			Exit
		Endif



		If nLin > 75 // Salto de Página. Neste caso o formulario tem 55 linhas...
			Cabec(Titulo,Cabec1,Cabec2,NomeProg,Tamanho,nTipo)
			nLin := 9
		Endif

		if _cCli <> QRY->(CLIENTE+LOJA)
			@nlin,02 psay QRY->CLIENTE + '/' + QRY->LOJA + '  ' + padr(_cNome,40,'') + '  ' + padr(_cDesC,20,'') 
			nlin++
			_cCli := QRY->(CLIENTE+LOJA)
		endif 

		_cRel := QRY->NUM + '        ' + QRY->PARCELA             + '        ' + transform(QRY->VALOR,'@E 999,999.99');
		+ '        ' + DTOC(STOD(QRY->EMISSAO)) + '        ' + DTOC(STOD(QRY->VENCTO));
		+ '        ' + DTOC(STOD(QRY->BAIXA))   + '        ' + transform(QRY->SALDO,'@E 999,999.99');

		@nlin,10 psay _cRel

		_nTotal +=  QRY->VALOR

		nLin++ // Avanca a linha de impressao

		QRY->(dbSkip()) // Avanca o ponteiro do registro no arquivo

		if  _cCli <> QRY->(CLIENTE+LOJA)
			@nlin, 02 psay 'Total Faturado: ' + transform(_nTotal,'@E 999,999,999.99')
			nlin += 2 
			_nTotal := 0
		endif

	EndDo

	DbCloseArea('QRY')

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
