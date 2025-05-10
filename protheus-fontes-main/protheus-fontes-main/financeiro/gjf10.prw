#INCLUDE "rwmake.ch"

User Function GJF10()

	//зддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
	//Ё Declaracao de Variaveis                                             Ё
	//юддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды

	Local cDesc1         := "Este programa tem como objetivo imprimir relatorio "
	Local cDesc2         := "de acordo com os parametros informados pelo usuario."
	Local cDesc3         := "RelaГЦo de SituaГЦo de Clientes"
	Local cPict          := ""
	Local titulo       := "RelaГЦo de SituaГЦo de Clientes"
	Local nLin         := 80

	Local Cabec1       := "Cod.:   Loja:   Cliente:                                    SituaГЦo:"
	Local Cabec2       := ""
	Local imprime      := .T.
	Local aOrd := {}
	Private lEnd         := .F.
	Private lAbortPrint  := .F.
	Private CbTxt        := ""
	Private limite           := 80
	Private tamanho          := "P"
	Private nomeprog         := "GJF10" // Coloque aqui o nome do programa para impressao no cabecalho
	Private nTipo            := 18
	Private aReturn          := { "Zebrado", 1, "Administracao", 2, 2, 1, "", 1}
	Private nLastKey        := 0
	Private cPerg       := "GJF10"
	Private cbtxt      := Space(10)
	Private cbcont     := 00
	Private CONTFL     := 01
	Private m_pag      := 01
	Private wnrel      := "NOME" // Coloque aqui o nome do arquivo usado para impressao em disco

	Private cString := "SA1"

	dbSelectArea("SA1")
	dbSetOrder(1)


	pergunte(cPerg,.F.)

	//зддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
	//Ё Monta a interface padrao com o usuario...                           Ё
	//юддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды

	wnrel := SetPrint(cString,NomeProg,cPerg,@titulo,cDesc1,cDesc2,cDesc3,.T.,aOrd,.T.,Tamanho,,.T.)

	If nLastKey == 27
		Return
	Endif

	SetDefault(aReturn,cString)

	If nLastKey == 27
		Return
	Endif

	nTipo := If(aReturn[4]==1,15,18)

	//зддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
	//Ё Processamento. RPTSTATUS monta janela com a regua de processamento. Ё
	//юддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды

	RptStatus({|| RunReport(Cabec1,Cabec2,Titulo,nLin) },Titulo)
Return

Static Function RunReport(Cabec1,Cabec2,Titulo,nLin)

	Local nOrdem

	dbSelectArea(cString)
	dbSetOrder(1)

	SetRegua(RecCount())
	dbGoTop()
	While !EOF()
		if SA1->A1_VEND < mv_par01 .or. SA1->A1_VEND > mv_par02
			dbskip()
			loop
		endif
		if mv_par03 <> 3
			if SA1->A1_MSBLQL <> str(mv_par03,1)
				dbskip()
				loop
			endif
		endif

		//зддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
		//Ё Verifica o cancelamento pelo usuario...                             Ё
		//юддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды

		If lAbortPrint
			@nLin,00 PSAY "*** CANCELADO PELO OPERADOR ***"
			Exit
		Endif

		//зддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
		//Ё Impressao do cabecalho do relatorio. . .                            Ё
		//юддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды

		If nLin > 55 // Salto de PАgina. Neste caso o formulario tem 55 linhas...
			Cabec(Titulo,Cabec1,Cabec2,NomeProg,Tamanho,nTipo)
			nLin := 8
		Endif

		// Coloque aqui a logica da impressao do seu programa...
		// Utilize PSAY para saida na impressora. Por exemplo:

		@nlin,00 PSAY SA1->A1_COD
		@nlin,10 PSAY SA1->A1_LOJA
		@nlin,16 PSAY SA1->A1_NOME
		if SA1->A1_MSBLQL = "1"
			@nlin,60 PSAY "Bloqueado"
		else
			@nlin,60 PSAY "Liberado"
		endif
		nLin := nLin + 1 // Avanca a linha de impressao

		dbSkip() // Avanca o ponteiro do registro no arquivo
	EndDo

	//зддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
	//Ё Finaliza a execucao do relatorio...                                 Ё
	//юддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды

	SET DEVICE TO SCREEN

	//зддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
	//Ё Se impressao em disco, chama o gerenciador de impressao...          Ё
	//юддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды

	If aReturn[5]==1
		dbCommitAll()
		SET PRINTER TO
		OurSpool(wnrel)
	Endif

	MS_FLUSH()

Return
