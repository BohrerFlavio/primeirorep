#INCLUDE "rwmake.ch"
#INCLUDE "topconn.ch"

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³GJF136  º Autor ³ Giuliano Forgiarini  º Data ³  28/03/12   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDescricao ³ Relatorio Cadastral de Funcionarios                        º±±
±±º          ³                                                            º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ RH/DP                                                      º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/

User Function GJF136()


	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Declaracao de Variaveis                                             ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ

	Local cDesc1         	:= "Este programa tem como objetivo imprimir relatorio  "
	Local cDesc2         	:= "de cadastro de funcionarios de acordo com os parametros"
	Local cDesc3         	:= "especificados nesta rotina"
	Local cPict          	:= "Relatorio Cadastral de Funcionários"
	Local titulo       		:= "RELATORIO CADASTRAL DE FUNCIONARIOS"
	Local nLin         		:= 80

	Local Cabec1       		:= ""
	Local Cabec2       		:= ""
	Local imprime      		:= .T.
	Local aOrd := {}
	Private lEnd         	:= .F.
	Private lAbortPrint  	:= .F.
	Private CbTxt        	:= ""
	Private limite           := 80
	Private tamanho          := "M"
	Private nomeprog         := "GJ136" // Coloque aqui o nome do programa para impressao no cabecalho
	Private nTipo            := 18
	Private aReturn          := { "Zebrado", 1, "Administracao", 2, 2, 1, "", 1}
	Private nLastKey        := 0
	Private cPerg   := "GJF136"
	Private cbtxt      := Space(10)
	Private cbcont     := 00
	Private CONTFL     := 01
	Private m_pag      := 01
	Private wnrel      := "GJF136" // Coloque aqui o nome do arquivo usado para impressao em disco    

	pergunte(cPerg,.F.)

	//para verificação se existe previsao de pesagem

	wnrel := SetPrint('SRA',NomeProg,cPerg,@titulo,cDesc1,cDesc2,cDesc3,.T.,aOrd,.T.,Tamanho,,.T.)

	Do case
		Case mv_par07 = 1   //Situação Normal
		_cSit := ' '
		Case mv_par07 = 2   //Afastado Temporariamente
		_cSit := 'A'    
		Case mv_par07 = 3   //Demitido
		_cSit := 'D'    
		Case mv_par07 = 4   //Ferias
		_cSit := 'F'
		Otherwise
		_cSit  := "' '/A/D/F/T"
	endcase

	cQuery := "  SELECT RA_MAT AS MAT, RA_NOME AS NOME, RA_ADMISSA AS ADMISSA, RA_CODFUNC AS CODFUNC, "
	cQuery += "  RA_SALARIO AS SALARIO, RA_CC AS CC, RA_DEP2 AS DEP2,RA_SITFOLH AS SITFOLH "
	cQuery += "  FROM " + RetSQLName('SRA') + " SRA  "
	cQuery += "  WHERE  SRA.D_E_L_E_T_ <> '*' AND  "
	cQuery += "  (RA_FILIAL BETWEEN '" + mv_par01 + "' AND  '" + mv_par02 + "') AND "
	cQuery += "  (RA_CC BETWEEN '" + mv_par03 + "' AND  '" + mv_par04 + "') AND "
	cQuery += "  (RA_DEP2 BETWEEN '" + mv_par05 + "' AND  '" + mv_par06 + "') " 
	cQuery += "   ORDER BY RA_CC,RA_DEP2,RA_NOME "
	cQuery := ChangeQuery(cQuery)

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
	TCQUERY cQuery NEW ALIAS "QRY"


	If nLastKey == 27
		Return
	Endif

	SetDefault(aReturn,'SRA')

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
	Local _cFunc      := ''
	Local _cDescFunc  := ''
	Local _cCC        := ''
	Local _cDescCC    := ''
	Local _cDepto     := ''
	Local _cDescDepto := ''

	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ SETREGUA -> Indica quantos registros serao processados para a regua ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ

	QRY->(dbGoTop())

	QRY->(SetRegua(RecCount()))

	While QRY->(!EOF())

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

		if  !(QRY->SITFOLH $ _cSit)
			QRY->(DbSkip())
			loop
		endif

		if _cCC <> QRY->CC 

			_cDescCC := fBuscaCPO('CTT',1,xfilial('CTT')+QRY->CC,'CTT_DESC01')

			@nlin,00 psay replicate('-',132)
			nlin++
			@nlin,00 psay 'Centro de Custo: ' + QRY->CC  + ' - ' + _cDescCC
			nlin++
			@nlin,00 psay replicate('-',132)

			_cCC := QRY->CC 

			nlin += 2
		endif

		if _cDepto <> QRY->DEP2 

			_cDescDepto := fBuscaCPO('SZJ',1,xfilial('SZJ')+QRY->DEP2,'ZJ_DESC')  

			nlin++

			@nlin,05 psay QRY->DEP2
			@nlin,15 psay ' - ' + _cDescDepto

			_cDepto := QRY->DEP2
			nlin += 2
		endif

		_cFunc := alltrim(fBuscaCPO('SRJ',1,xfilial('SRJ')+alltrim(QRY->CODFUNC),'RJ_DESC'))

		@nlin,015 psay QRY->MAT
		@nlin,025 psay substr(QRY->NOME,1,40)
		@nlin,070 psay stod(QRY->ADMISSA)
		@nlin,090 psay transform(QRY->SALARIO,'@E 999,999.99')		
		nlin++

		QRY->(dbSkip()) // Avanca o ponteiro do registro no arquivo    

	EndDo

	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Finaliza a execucao do relatorio...                                 ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ

	DbCloseArea('QRY')

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
