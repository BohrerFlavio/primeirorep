#INCLUDE "rwmake.ch"           
#INCLUDE "protheus.ch"    


User Function DTI07()

	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Declaracao de Variaveis                                             ³
	//³ Fonte realizado por Fabian Maurer				Data:06/07/16       ³
	//³ Frigorifico Silva		                                            ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ

	/*Local cVldAlt := ".T." // Validacao para permitir a alteracao. Pode-se utilizar ExecBlock.
	Local cVldExc := ".T." // Validacao para permitir a exclusao. Pode-se utilizar ExecBlock.
	Private aRotina := { {"Imprime Recibos","u_Dti07Imp",0,5} } 

	dbSelectArea("ZZT")
	dbSetOrder(1)

	AxCadastro("ZZT","Recibos Financeiros",cVldExc,cVldAlt)
	*/


	Private cCadastro := "Recibos Financeiros"

	Private aRotina := { {"Pesquisar","AxPesqui",0,1} ,;
	{"Visualizar","AxVisual",0,2} ,;   
	{"Incluir","AxInclui",0,3} ,;
	{"Alterar","AxAltera",0,4},;
	{"Excluir","AxDeleta",0,5},;
	{"Imprimir","u_Dti07Imp",0,2} } 

	Private cDelFunc := ".T." // Validacao para a exclusao. Pode-se utilizar ExecBlock

	Private cString := "ZZT"

	dbSelectArea("ZZT")
	dbSetOrder(1)

	mBrowse(6,1,22,75,cString,,) 

	dbSelectArea(cString)

Return  

User Function Dti07Imp()
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Declaracao de Variaveis                                             ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ

	Local cDesc1         := "Este programa tem como objetivo imprimir Recibo	       "
	Local cDesc2         := "Financeiro																 "
	Local cDesc3         := "																			 "
	Local cPict          := ""                                         
	Local titulo       	:= "Recibo Financeiro"
	Local nLin         	:= 80
	Local Cabec1       	:= "      "
	Local Cabec2       	:= " 		 "
	Local imprime      	:= .T.
	Local aOrd := {}
	Private lEnd         := .F.
	Private lAbortPrint  := .F.
	Private CbTxt        := ""
	Private limite       := 80
	Private Tamanho      := "P"
	Private nomeprog     := "DTI07" // Coloque aqui o nome do programa para impressao no cabecalho
	Private nTipo        := 18
	Private aReturn      := { "Zebrado", 1, "Administracao", 2, 2, 1, "", 1}
	Private nLastKey     := 0
	Private cPerg   	 := "FFM13"
	Private cbtxt      	:= Space(10)
	Private cbcont     	:= 00
	Private CONTFL     	:= 01
	Private m_pag      	:= 01
	Private wnrel      	:= "DTI07" // Coloque aqui o nome do arquivo usado para impressao em disco    



	//pergunte(cPerg,.F.)

	wnrel := SetPrint('',NomeProg,cPerg,@titulo,cDesc1,cDesc2,cDesc3,.T.,aOrd,.T.,Tamanho,,.T.)


	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Monta a interface padrao com o usuario...                           ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ

	If nLastKey == 27
		Return
	Endif

	SetDefault(aReturn,'')

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
	nlin:= 9


	If nLin > 70 // Salto de Página. Neste caso o formulario tem 55 linhas...
		Cabec(Titulo,Cabec1,Cabec2,NomeProg,Tamanho,nTipo)
		nLin := 9
	Endif

	_nNumDoc	 := ZZT->ZZT_NUM
	_nValor		 := ZZT->ZZT_VALOR
	_cReceb		 := ZZT->ZZT_RECEBI
	_cRefer		 := ZZT->ZZT_REFERE
	_dData		 := ZZT->ZZT_DATA
	_cFavor		 := ZZT->ZZT_FAVORE
	_cObs	 	 := ZZT->ZZT_OBS
	_cValExtenso := alltrim(extenso(_nValor,.f.,1))

	@nlin,60	PSAY "Num. Doc. : " + _nNumDoc
	nlin	+= 2
	@nlin,35 PSAY "RECIBO"
	nlin++
	@nlin,60	PSAY "R$ " + Transform(_nValor,'@E 99,999,999.99')
	nlin += 2
	@nlin,01	PSAY "Recebi de : " + _cReceb
	nlin += 2
	If _cObs <> ''
		@nlin,01	PSAY "Com Numero(s) de Documento(s): " + _cObs                            
		nlin++
	EndIf
	nlin++
	if len(_cValExtenso) <= 55 
		@nlin,01	PSAY "A importância de : " + _cValExtenso
	else
		@nlin,01	PSAY "A importância de : " + substr(_cValExtenso,1,55)	
		nlin++
		@nlin,19	PSAY substr(_cValExtenso,56,60)
	endif                                      
	nlin += 2                                  

	@nlin,01	PSAY "Referente a : " + _cRefer
	nlin += 2
	@nlin,30	PSAY "Santa Maria," + alltrim(STR(day(_dData))) +" de " + alltrim(mesextenso(month(_dData))) + " de " + alltrim(STR(year(_dData)))
	nlin += 4
	@nlin,15	PSAY "_________________________________________________________"
	nlin += 2
	@nlin,30	PSAY _cFavor  

	_nNumDoc++


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
