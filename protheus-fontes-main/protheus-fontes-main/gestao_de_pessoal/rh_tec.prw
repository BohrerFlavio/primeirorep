#INCLUDE "rwmake.ch"        // incluido pelo assistente de conversao do AP5 IDE em 23/08/00
#IFNDEF WINDOWS
#DEFINE PSAY SAY
#ENDIF

User Function rh_tec()        // incluido pelo assistente de conversao do AP5 IDE em 23/08/00

	//* Programa..:rh_tec.PRX
	//* Autor.....: Fernando Possoli 
	//* Data......: 23/08/2000
	//* Nota......: Emissao Relatorio Aviso de Advertencia

	#IFNDEF WINDOWS
	// Movido para o inicio do arquivo pelo assistente de conversao do AP5 IDE em 23/08/00 ==>    #DEFINE PSAY SAY
	#ENDIF

	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Variaveis utilizadas para parametros                         ³
	//³ mv_par01     // Matricula De                                 ³
	//³ mv_par02     // Matricula Ate                                ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ

	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Variaveis obrigatorias dos programas de relatorio            ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	cString :="SRA"
	cDesc1  :="Este programa tem como objetivo, Imprimir o Formulario "
	cDesc2  :="de Aviso Advertencia."
	cDesc3  :=""
	tamanho :="P"
	aReturn :={ "Zebrado", 1,"Administracao", 2, 2, 1, "",1 }
	aLinha  :={ }
	nLastKey:=0
	cPerg   :="RH_TEC"
	titulo  :="Aviso de Advertencia"
	wnrel   :="RH_TEC"
	nTipo   :=0
	nLin    :=0
	nTamNf  :=32

	ValidPerg()
	Pergunte(cPerg,.F.)      // Pergunta no SX1

	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Envia controle para a funcao SETPRINT                        ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	wnrel:=SetPrint(cString,wnrel,cPerg,titulo,cDesc1,cDesc2,cDesc3,.F.)

	If nLastKey == 27
		Return
	Endif

	SetDefault(aReturn,cString)
	If nLastKey == 27
		Return
	Endif

	#IFDEF WINDOWS
	RptStatus({|| RptDetail()})// Substituido pelo assistente de conversao do AP5 IDE em 23/08/00 ==>    RptStatus({|| Execute(RptDetail)})
Return
// Substituido pelo assistente de conversao do AP5 IDE em 23/08/00 ==>    Function RptDetail
Static Function RptDetail()
	#ENDIF

	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Inicializa  regua de impressao                            ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	SetRegua(LastRec())

	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Inicializa os codigos de caracter Comprimido/Normal da impressora ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	nTipo := IIF(aReturn[4]==1,15,18)
	li    := 0
	m_pag := 1

	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Posiciona o Arquivo na ordem correta.                    ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	_zMAT:="######"
	DbSelectArea("SRA")                // * Cadastro de Funcionarios
	DbSetOrder(1)
	DbSeek(xFilial()+mv_par01,.T.)
	Do While !Eof() .and. xFilial() == SRA->RA_FILIAL .And. SRA->RA_MAT <= mv_par02
		_xMat:=SRA->RA_MAT
		If _zMAT <> _xMAT
			If _zMAT <> "######" 
				li := 0
			Endif
			_zMAT:=_xMAT
		Endif
		li := li + 10
		@ li, 015 PSAY "A V I S O    D E    A D V E R T E N C I A"
		li := li + 4
		@ li, 000 PSAY "De....:"+Left(SM0->M0_NOMECOM,30) + Space(10) + "CGC..:"+SM0->M0_CGC
		li := li + 2
		@ li, 000 PSAY "Para..:"+Left(SRA->RA_NOME,30) + Space(10) + "CTPS..:"+SRA->RA_NUMCP+"/"+SRA->RA_SERCP
		li := li + 2
		@ li, 000 PSAY replicate("-",70)
		li := li + 3
		@ li, 000 PSAY "Na conformidade da Consolidacao das Leis do Trabalho,fica V.Sa. adver-"    
		li := li + 1
		@ li, 000 PSAY "tido(a) pelas faltas abaixo discriminadas:"
		li := li + 2
		@ li, 000 PSAY +mv_par03
		li := li + 2
		@ li, 000 PSAY +mv_par04
		li := li + 2
		@ li, 000 PSAY +mv_par05
		li := li + 2 
		@ li, 000 PSAY +mv_par06
		li := li + 2
		@ li, 000 PSAY +mv_par07
		li := li + 5

		@ li, 000 PSAY "Nao so esperamos que tome as necessarias providencias a fim de que nao"
		li := li + 1
		@ li, 000 PSAY "se repitam as irregularidades acima discriminadas como tambem aprovei-"
		li := li + 1
		@ li, 000 PSAY "tamos para esclarecer-lhe que a repeticao ou praticas nao previstas em" 
		li := li + 1
		@ li, 000 PSAY "nossos Regulamentos e/ou Ordens de Servico, irao contribuir desfavora-"
		li := li + 1
		@ li, 000 PSAY "velmente em seu progresso na firma, alem de  poder acarretar-lhe pena-"
		li := li + 1
		@ li, 000 PSAY "lidades mais severas, conforme preceituam as disposicoes no Artigo 482" 
		li := li + 1
		@ li, 000 PSAY "e suas alineas da Consolidacao das Leis do Trabalho." 
		li := li + 1
		@ li, 000 PSAY "Assim sendo, solicitamos confirmar o recebimento." 
		li := li + 5
		@ li, 045 PSAY "_________________________"
		li := li + 1
		@ li, 046 PSAY "Assinatura do Empregador"
		li := li + 4
		@ li, 000 PSAY LEFT(SM0->M0_CIDCOB,30)+","+DTOC(DDATABASE)
		@ li, 045 PSAY "_________________________"
		li := li + 1
		@ li, 048 PSAY "Ciente do Empregado"
		li := li + 3
		@ li, 000 PSAY "_________________________"
		@ li, 045 PSAY "_________________________"
		li := li + 1
		@ li, 006 PSAY "Testemunha 1"
		@ li, 051 PSAY "Testemunha 2"
		DbSelectArea("SRA")
		DbSkip()
	Enddo

	Set Device To Screen

	If aReturn[5]==1
		Set Printer TO
		dbcommitAll()
		ourspool(wnrel)
	Endif

	MS_FLUSH() //Libera fila de relatorios em spool (Tipo Rede Netware)

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Cria Perguntas no SX1                                        ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
// Substituido pelo assistente de conversao do AP5 IDE em 23/08/00 ==> Function ValidPerg
Static Function ValidPerg()
	Local i
	Local j
	cAlias := Alias()
	aRegs  :={}

	// Grupo/Ordem/Pergunta/Variavel/Tipo/Tamanho/Decimal/Presel/GSC/Valid/Var01/Def01/Cnt01/Var02/Def02/Cnt02/Var03/Def03/Cnt03/Var04/Def04/Cnt04/Var05/Def05/Cnt05
	AADD(aRegs,{cPerg,"01","Matricula Inicial  ?","","","mv_ch1","C",06,0,0,"G","","mv_par01","","","","","","","","","","","","","","","","","","","","","","","","","SRA",""})
	AADD(aRegs,{cPerg,"02","Matricula Final    ?","","","mv_ch2","C",06,0,0,"G","","mv_par02","","","","","","","","","","","","","","","","","","","","","","","","","SRA",""})
	AADD(aRegs,{cPerg,"03","Motivo Advertencia       ","","","mv_ch3","C",80,0,0,"G","","mv_par03","","","","","","","","","","","","","","","","","","","","","","","","","",""})
	AADD(aRegs,{cPerg,"04","Complemento Motivo       ","","","mv_ch4","C",80,0,0,"G","","mv_par04","","","","","","","","","","","","","","","","","","","","","","","","","",""})
	AADD(aRegs,{cPerg,"05","Complemento Motivo       ","","","mv_ch5","C",80,0,0,"G","","mv_par05","","","","","","","","","","","","","","","","","","","","","","","","","",""})
	AADD(aRegs,{cPerg,"06","Complemento Motivo       ","","","mv_ch6","C",80,0,0,"G","","mv_par06","","","","","","","","","","","","","","","","","","","","","","","","","",""})
	AADD(aRegs,{cPerg,"07","Complemento Motivo       ","","","mv_ch7","C",80,0,0,"G","","mv_par07","","","","","","","","","","","","","","","","","","","","","","","","","",""})

	DbSelectArea("SX1")
	DbSetOrder(1)
	For i:=1 to Len(aRegs)
		If !DbSeek(cPerg+aRegs[i,2])
			RecLock("SX1",.T.)
			For j:=1 to FCount()
				If j<=Len(aRegs[i])
					FieldPut(j,aRegs[i,j])
				Endif
			Next
			MsUnlock()
		Endif
	Next
	DbSelectArea(cAlias)
Return
