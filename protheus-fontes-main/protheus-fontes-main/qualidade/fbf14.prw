#INCLUDE "rwmake.ch"

/*/
эээээээээээээээээээээээээээээээээээээээээээээээээээээээээээээээээээээээээээээ
╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠
╠╠иммммммммммяммммммммммкмммммммяммммммммммммммммммммкммммммяммммммммммммм╩╠╠
╠╠╨Programa  ЁGJF14     ╨ Autor Giuliano Forgiarini  ╨ Data Ё  09/05/07   ╨╠╠
╠╠лммммммммммьммммммммммймммммммоммммммммммммммммммммйммммммоммммммммммммм╧╠╠
╠╠╨Descricao Ё RelatСrio de controle e anАlise de ph por aviso de matanГa ╨╠╠
╠╠╨          Ё                                                            ╨╠╠
╠╠лммммммммммьмммммммммммммммммммммммммммммммммммммммммммммммммммммммммммм╧╠╠
╠╠╨Uso       Ё AP6 IDE                                                    ╨╠╠
╠╠хммммммммммомммммммммммммммммммммммммммммммммммммммммммммммммммммммммммм╪╠╠
╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠
ъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъ
/*/

User Function FBF14()

	//зддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
	//Ё Declaracao de Variaveis                                             Ё
	//юддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды

	Local cDesc1         := "Este programa tem como objetivo imprimir relatorio "
	Local cDesc2         := "para controle e anАlise de pH por carcaГas conforme"
	Local cDesc3         := "o aviso de matanГa indicado"
	Local cPict          := ""
	Local titulo         := "R4 - COMPLEMENTAR"
	Local nLin           := 75

	Local Cabec1         := "                     Dt Prod.   Aviso"
	Local Cabec2         := "                  "
	Local Cabec3         := " "
	Local imprime        := .T.
	Local aOrd           := {}
	Private lEnd         := .F.
	Private lAbortPrint  := .F.
	Private CbTxt        := ""
	Private limite       := 132
	Private tamanho      := "M"
	Private nomeprog     := "FBF14" // Coloque aqui o nome do programa para impressao no cabecalho
	Private nTipo        := 18
	Private aReturn      := { "Zebrado", 1, "Administracao", 2, 2, 1, "", 1}
	Private nLastKey     := 0
	Private cPerg        := "FBF14"
	Private cbtxt        := Space(10)
	Private cbcont       := 00
	Private CONTFL       := 01
	Private m_pag        := 01
	Private wnrel        := "FBF14" // Coloque aqui o nome do arquivo usado para impressao em disco

	Private cString := "ZZD"

	dbSelectArea("ZZD")

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


	//зддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
	//Ё Processamento. RPTSTATUS monta janela com a regua de processamento. Ё
	//юддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды

	RptStatus({|| RunReport(Cabec1,Cabec2,Titulo,nLin) },Titulo)
Return

Static Function RunReport(Cabec1,Cabec2,Titulo,nLin)



	Local _cPrev 	:= ' '
	Local _cCont 	:= 0
	Local _lLin 	:= 1

	//зддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
	//Ё SETREGUA -> Indica quantos registros serao processados para a regua Ё
	//юддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды

	SetRegua(RecCount())
	ZZD->(dbsetorder(2)) 
	ZZD->(dbGoTop())



	While !EOF() 
		incregua()  

		If nLin > 60 
			Cabec(Titulo,Cabec1,Cabec2,NomeProg,Tamanho,nTipo)
			nLin := 8
		endif 

		if  ZZD->ZZD_DATA < mv_par01 .or. ZZD->ZZD_DATA > mv_par02 
			ZZD->(dbskip())
			loop
		endif  

		if ZZD->ZZD_PREV < mv_par03 .or.  ZZD->ZZD_PREV >mv_par04
			ZZD->(dbskip())
			loop
		endif 
		// Nas trocas de previsЦo mostra o numero da nova previsЦook     
		if _cPrev  != ZZD->ZZD_PREV  .or. _cCont = 0

			nLin++
			@nLin,10 PSAY "PrevisЦo: "+ZZD->ZZD_PREV
			nLin++   
			_cPrev := ZZD->ZZD_PREV 
			_cCont++
			nLin++
			_lLin = 1
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

		If nLin > 60 
			Cabec(Titulo,Cabec1,Cabec2,NomeProg,Tamanho,nTipo)
			nLin := 8
		endif 

		if _lLin = 1
			@nlin,08 psay ZZD->ZZD_CONTRO+'  '+DTOC(ZZD->ZZD_DATA)+'  '+substr(ZZD->ZZD_RASTRO,1,8)
			_lLin := 2
		elseif _lLin = 2
			@nlin,43 psay '| '+ZZD->ZZD_CONTRO+'  '+DTOC(ZZD->ZZD_DATA)+'  '+substr(ZZD->ZZD_RASTRO,1,8)
			_lLin := 3
		elseif _lLin = 3
			@nlin,86 psay '| '+ZZD->ZZD_CONTRO+'  '+DTOC(ZZD->ZZD_DATA)+'  '+substr(ZZD->ZZD_RASTRO,1,8)
			_lLin := 1
			nlin++		
		endif



		ZZD->(dbSkip()) // Avanca o ponteiro do registro no arquivo
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
