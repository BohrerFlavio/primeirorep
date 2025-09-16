#INCLUDE "rwmake.ch"        // incluido pelo assistente de conversao do AP5 IDE em 23/08/00
#IFNDEF WINDOWS
#DEFINE PSAY SAY
#ENDIF

User Function rh_aco()        // incluido pelo assistente de conversao do AP5 IDE em 23/08/00

	//* Programa..: rh_aco.PRX
	//* Autor.....: Claudioir Macedo     
	//* Data......: 10/04/02
	//* Nota......: Emissao Relatorio Acordo de Compensação


	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Variaveis utilizadas para parametros                         ³
	//³ mv_par01     // Matricula De                                 ³
	//³ mv_par02     // Matricula Ate                                ³
	//³ mv_par01     // Matricula De                                 ³
	//³ mv_par02     // Matricula Ate                                ³
	//³ mv_par01     // Matricula De                                 ³
	//³ mv_par02     // Matricula Ate                                ³
	//³ mv_par01     // Matricula De                                 ³
	//³ mv_par02     // Matricula Ate                                ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ

	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Variaveis obrigatorias dos programas de relatorio            ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	cString :="SRA"
	cDesc1  :="Este programa tem como objetivo, Imprimir o Formulario "
	cDesc2  :="de Acordo de Compensação de Horas."
	cDesc3  :=""
	tamanho :="P"
	aReturn :={ "Zebrado", 1,"Administracao", 2, 2, 1, "",1 }
	aLinha  :={ }
	nLastKey:=0
	cPerg   :="RH_ACO"
	titulo  :="Acordo Comp. Horas"
	wnrel   :="rh_aco"
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
	DbSelectArea("SRA")                // * Funcionários       
	DbSetOrder(1)
	DbSeek(xFilial()+mv_par01,.T.)
	Do While !Eof() .and. xFilial() == SRA->RA_FILIAL .And. SRA->RA_MAT <= mv_par02 
		_xMat:=SRA->RA_MAT
		//      If SRA->RA_DATAHOM<> mv_par03
		//         DbSelectArea("SRA")
		//         DbSkip()
		//         loop
		//      EndIf

		If _zMAT <> _xMAT
			If _zMAT <> "######" 
				li := 0
			Endif
			_zMAT:=_xMAT
		Endif
		li := li + 2
		@ li, 020 PSAY "  ACORDO DE COMPENSACAO DE HORAS"
		li := li + 3
		@ li, 004 PSAY "Pelo  presente  Acordo  de Compensacao de Horas, celebrado  entre  a empresa:"
		li := li + 2
		@ li, 000 PSAY Left(SM0->M0_NOMECOM,40)+ ", CGC..:"
		@ LI, 047 PSAY SM0->M0_CGC Picture"@R 99.999.999/9999-99"

		@ li, 073 PSAY ", sita a " 
		li := li + 2
		@ li, 000 PSAY Left(SM0->M0_CIDCOB,13)+" a "+Left(SM0->M0_ENDCOB,16)+" e seu empregado:"+LEFT(SRA->RA_NOME,30)
		@ li, 080 PSAY ","
		li := li + 2
		@ li, 000 PSAY "Cargo: "+left(SRJ->RJ_DESC,20)+", CTPS..: "+SRA->RA_NUMCP+"/"+SRA->RA_SERCP+ "."
		li := li + 3
		@ li, 004 PSAY "FICA ESTIPULADO O SEGUINTE:"
		li := li + 3                                               
		@ li, 004 PSAY "I - Que o horario de trabalho sera prorrogado por mais minutos de trabalho, a"
		li := li + 2
		@ li, 000 PSAY "titulo de compensacao do horario de sabado, do qual, em consequencia, ficara dis-"
		li := li + 2
		@ li, 000 PSAY "pensado ou tera o  seu horario de trabalho diminuido;"
		li := li + 2
		@ li, 004 PSAY "II - Que o presente acordo podera ser rescindido  entre  as partes,  mediante"
		li := li + 2
		@ li, 000 PSAY "simples notificacao por escrito da parte interessada, passando a prevalecer o ho-"
		li := li + 2
		@ li, 000 PSAY "rario normal aos sabados;"
		li := li + 2
		@ li, 004 PSAY "III - O horario de  trabalho, face  a compensacao do presente acordo e o  se-" 
		li := li + 2
		@ li, 000 PSAY 	"guinte:
		li := li + 1


		@ li, 004 PSAY +Left(SR6->R6_DESC,60) 
		li := li + 3
		@ li, 004 PSAY "O presente acordo vigorara por tempo indeterminado."
		li := li + 2
		@ li, 004 PSAY "E por estarem ambas as partes assim acordadas, firmam o presente em duas vias"
		li := li + 2
		@ li, 000 PSAY " de igual teor e para os mesmos fins, perante duas testemunhas."
		li := li + 3
		@ li, 004 PSAY LEFT(SM0->M0_CIDCOB,30)+", "+str(day(ddatabase),2,0)+" de  "+mesextenso(month(ddatabase))+" de  "+str(year(ddatabase),4,0)+"."
		li := li + 4
		@ li, 000 PSAY replicate("_",30)+space(10)+replicate("_",30)
		li := li + 1
		@ li, 000 PSAY LEFT(SM0->M0_NOMECOM,30)+space(10)+LEFT(SRA->RA_NOME,30) 
		li := li + 4 
		@ li, 000 PSAY "TESTEMUNHAS:
		li := li + 3  
		@ li, 000 PSAY replicate("_",30)+space(10)+replicate("_",30)
		li := li + 1
		@ li, 001 PSAY "CPF:" +SPACE (37)+ "CPF:"
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
	DbSelectArea("SX1")
	DbSetOrder(1)
	For i:=1 to Len(aRegs)
		If !DbSeek(cPerg+aRegs[i,2])
			RecLock("SX1",.T.)
		else
			RecLock("SX1",.F.)
		endif
		For j:=1 to FCount()

			// Campos CNT nao sao gravados para preservar conteudo anterior.
			If j<=Len(aRegs[i]) .and. left (fieldname (j), 6) != "X1_CNT" .and. fieldname (j) != "X1_PRESEL"
				FieldPut(j,aRegs[i,j])
			Endif
		Next
		MsUnlock()
	Next
	DbSelectArea(cAlias)
Return


