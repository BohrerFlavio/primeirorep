#INCLUDE "rwmake.ch"
#INCLUDE "topconn.ch"

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³GJF240     ºAutor  ³Giuliano Forgiariniº Data ³  05/01/16   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³   Relatorio de lotes de PA de porcionados  a serem         º±±
±±º          ³   produzidos e aglutinados por batelada/molde/gramatura    º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ PCP  porcionados                                           º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/

User Function GJF240()


	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Declaracao de Variaveis                                             ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ

	Local cDesc1         := "Este programa tem como objetivo imprimir relatorio"
	Local cDesc2         := "para acompanhamento de lotes a serem produzidos de"
	Local cDesc3         := "PAs de porcionados aglutinados por                "
	Local cPict          := "batelada/molde/gramatura para fatiadoras.         "
	Local titulo         := "PRODUÇÃO DE LOTES AGLUTINADAS POR BATELADA/MOLDE/GRAMATURA"
	Local Cabec1         := ""
	Local Cabec2         := ""
	Local imprime        := .T.
	Local aOrd           := {}  
	Private nLin         := 80
	Private lEnd         := .F.
	Private lAbortPrint  := .F.
	Private CbTxt        := ""
	Private limite       := 132
	Private tamanho      := "M"
	Private nomeprog     := "GJF240" // Coloque aqui o nome do programa para impressao no cabecalho
	Private nTipo        := 18
	Private aReturn      := { "Zebrado", 1, "Administracao", 2, 2, 1, "", 1}
	Private nLastKey     := 0
	Private cPerg   		:= "GJF240"
	Private cbtxt      	:= Space(10)
	Private cbcont     	:= 00
	Private CONTFL     	:= 01
	Private m_pag      	:= 01
	Private wnrel      	:= "GJF240" // Coloque aqui o nome do arquivo usado para impressao em disco    
	Private _nTotReg     := 0 
	Private _cQuery      := ''

	pergunte(cPerg,.F.)


	Cabec1 := 'Data de produção apontada: ' + dtoc(mv_par01)
	Cabec2 := ''

	wnrel := SetPrint('ZAU',NomeProg,cPerg,@titulo,cDesc1,cDesc2,cDesc3,.T.,aOrd,.T.,Tamanho,,.T.)  

	If nLastKey == 27
		Return
	Endif

	SetDefault(aReturn,'ZAU')

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

	Cabec(Titulo,Cabec1,Cabec2,NomeProg,Tamanho,nTipo)
	nLin := 9


	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ SETREGUA -> Indica quantos registros serao processados para a regua ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ

	MsgRun("Selecionando os registros...",,{|| GeraQuery()})

	SetRegua(_nTotReg)

	_cBatel  := ''
	_cMolde  := ''
	_nGramat := 0   
	_cLayEtq := ''

	while PROD->(!eof())  

		incregua()

		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³ Verifica o cancelamento pelo usuario...                             ³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ

		If lAbortPrint
			@nLin,00 PSAY "*** CANCELADO PELO OPERADOR ***"
			Exit
		Endif

		if empty(PROD->ZAU_MOLDE) .or. PROD->ZAU_GRAMAT = 0
			PROD->(Dbskip())
			loop  
		endif

		//Quebra molde
		if _cMolde <> PROD->ZAU_MOLDE

			_cDescMolde := fBuscaCPO('SX5',1,xfilial('SX5')+'ZD' + PROD->ZAU_MOLDE,'X5_DESCRI')

			If nLin > 75 // Salto de Página. Neste caso o formulario tem 55 linhas...
				Cabec(Titulo,Cabec1,Cabec2,NomeProg,Tamanho,nTipo)
				nLin := 9
			Endif	     

			nlin++
			@nlin,000 psay replicate('=',132)
			nlin++ 

			@nlin,000 psay 'Molde ' + PROD->ZAU_MOLDE + '   ' + _cDescMolde

			nlin++        

			_cBatel  := ''
			_cLayEtq := ''
			_nGramat := 0       
			_cMolde  := PROD->ZAU_MOLDE
		endif


		//Quebra gramatura
		if _nGramat <> PROD->ZAU_GRAMAT

			If nLin > 75 // Salto de Página. Neste caso o formulario tem 55 linhas...
				Cabec(Titulo,Cabec1,Cabec2,NomeProg,Tamanho,nTipo)
				nLin := 9
			Endif  

			@nlin,000 psay replicate('-',132)
			nlin++

			@nlin,003 psay 'Gramatura: ' + transform(PROD->ZAU_GRAMAT,'@E 999')

			nlin++

			_cBatel  := ''
			_cLayEtq := ''          
			_nGramat := PROD->ZAU_GRAMAT
		endif

		//Quebra Batelada
		if _cBatel <> PROD->ZAU_BATEL

			_cDescBatel := fBuscaCPO('ZAX',1,xfilial('ZAX') + PROD->ZAU_BATEL,'ZAX_DESCRI')
			_cCodMP     := fBuscaCPO('ZAX',1,xfilial('ZAX') + PROD->ZAU_BATEL,'ZAX_CODMP')

			If nLin > 75 // Salto de Página. Neste caso o formulario tem 55 linhas...
				Cabec(Titulo,Cabec1,Cabec2,NomeProg,Tamanho,nTipo)
				nLin := 9
			Endif      

			@nlin,006 psay 'Batelada: ' + PROD->ZAU_BATEL + '   ' + _cCodMP + '   ' +_cDescBatel
			nlin++

			_cBatel  := PROD->ZAU_BATEL
			_cLayEtq := ''
		endif


		//Quebra LAYOUT ETIQUETA
		if _cLayEtq <> PROD->ZAU_LAYETQ     

			_cDescLayEtq := fBuscaCPO('SX5',1,xfilial('SX5')+'ZC' + PROD->ZAU_LAYETQ,'X5_DESCRI')

			If nLin > 75 // Salto de Página. Neste caso o formulario tem 55 linhas...
				Cabec(Titulo,Cabec1,Cabec2,NomeProg,Tamanho,nTipo)
				nLin := 9
			Endif

			@nlin,009 psay 'Layout: ' + PROD->ZAU_LAYETQ + '   ' + _cDescLayEtq

			nlin++

			_cLayEtq := PROD->ZAU_LAYETQ
		endif

		If nLin  > 75 // Salto de Página. Neste caso o formulario tem 55 linhas...
			Cabec(Titulo,Cabec1,Cabec2,NomeProg,Tamanho,nTipo)
			nLin := 9
		Endif

		@nlin,015 psay  'Lote: ' + PROD->ZAU_NUM  + '   ' + alltrim(PROD->ZAU_COD) + ' (' + substr(PROD->ZAU_DESC,1,25) + '...)'
		@nlin,075 psay  'Unid.: '  + transform(PROD->ZAU_QPUNI,'@E 999,999') + '   Peso: ' + transform(PROD->ZAU_QPPESO,'@E 999,999.99') +;
		'   Caixas: ' + transform(PROD->ZAU_QPCAIX,'@E 999,999') 
		nlin++  

		PROD->(DbSkip())			  

	enddo 

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

//Função para gerar a query...
Static Function GeraQuery()

	_cQuery := " SELECT ZAU_NUM, ZAU_COD, ZAU_DESC, ZAU_BATEL, ZAU_MOLDE, ZAU_GRAMAT, "
	_cQuery += " ZAU_QPPESO, ZAU_QPUNI, ZAU_QPCAIX, ZAU_QRPESO,ZAU_QRCAIX,ZAU_QRUNI, "
	_cQuery += " ZAU_QTDMP,ZAU_CODMP, ZAU_LAYETQ " 
	_cQuery += " FROM " + RetSqlTab("ZAU") 
	_cQuery += " WHERE "
	_cQuery += RetSQLFil('ZAU') + " AND ZAU_DTPROD = '" + dtos(mv_par01) + "' AND ZAU_CODMP<> 'RECEIT' AND "
	_cQuery += RetSQLDel('ZAU')
	_cQuery += " ORDER BY ZAU_MOLDE, ZAU_GRAMAT,ZAU_BATEL, ZAU_LAYETQ "

	_cQuery := ChangeQuery(_cQuery)

	//	* Mostrar a consulta */
	//@ 116,090 To 416,707 Dialog oDlgMemo Title "Consulta"
	//@ 055,005 Get _cQuery Size 250,080 MEMO Object oMemo
	//Activate Dialog oDlgMemo
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Monta a interface padrao com o usuario...                           ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ   


	If Select("PROD") != 0
		PROD->(dbCloseArea())
	Endif
	TCQUERY _cQuery NEW ALIAS "PROD" 

	while PROD->(!eof())
		_nTotReg++
		PROD->(DbSkip())
	enddo

	PROD->(DbGoTop())

return
