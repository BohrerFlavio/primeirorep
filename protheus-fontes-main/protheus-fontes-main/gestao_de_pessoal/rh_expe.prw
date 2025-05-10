#INCLUDE "rwmake.ch"        // incluido pelo assistente de conversao do AP5 IDE em 11/10/00
#IFNDEF WINDOWS
#DEFINE PSAY SAY
#ENDIF

User Function ml_cont()        // incluido pelo assistente de conversao do AP5 IDE em 11/10/00

	// Programa..: ML_CONT.PRX
	// Autor.....: Rosmari Arboit   
	// Data......: 26/04/2001
	// Nota......: Emissao Relatorio Contrato de Experiencia em 01 pagina

	#IFNDEF WINDOWS
	// Movido para o inicio do arquivo pelo assistente de conversao do AP5 IDE em 11/10/00 ==>    #DEFINE PSAY SAY
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
	cDesc1  :="Este programa tem como objetivo, Imprimir o Contrato   "
	cDesc2  :="de Experiencia             "
	cDesc3  :=""
	tamanho :="P"
	aReturn :={ "Zebrado", 1,"Administracao", 2, 2, 1, "",1 }
	aLinha  :={ }
	nLastKey:=0
	cPerg   :="ML_CON"
	titulo  :="Contrato de Experiencia        "
	wnrel   :="ML_CONT"
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
	RptStatus({|| RptDetail()})// Substituido pelo assistente de conversao do AP5 IDE em 11/10/00 ==>    RptStatus({|| Execute(RptDetail)})
Return
// Substituido pelo assistente de conversao do AP5 IDE em 11/10/00 ==>    Function RptDetail
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
		_xFuncao:=SRA->RA_CODFUNC
		_xSal:=IIF(SRA->RA_SITFOLH="H",(SRA->RA_SALARIO * SRA->RA_HRSMES),SRA->RA_SALARIO)
		If _zMAT <> _xMAT
			If _zMAT <> "######" 
				li := 0
			Endif
			_zMAT:=_xMAT
		Endif
		li := li + 3
		@ li, 020 PSAY chr(27)+"  "+"CONTRATO DE TRABALHO A TITULO DE EXPERIENCIA"+chr(27)+"  "
		li := li + 3
		@ LI, 000 PSAY "Entre a Empresa  "+SM0->M0_NOMECOM
		li := li + 1
		@ li, 000 PSAY "com sede em  "+SM0->M0_CIDCOB+SPACE(10)+"a"+SPACE(10)+SM0->M0_ENDCOB
		li := li + 1
		@ li, 000 PSAY "CGC  "
		@ LI, 010 PSAY SM0->M0_CGC Picture"@R 99.999.999/9999-99"
		@ li, 036 PSAY "doravante designada simplesmante EMPREGADORA  e"
		li := li + 1
		@ li, 000 PSAY SRA->RA_NOME+SPACE(5)+space(15)+"portador da CTPS "+SRA->RA_NUMCP+SPACE(1)+"/"+SPACE(2)+SRA->RA_SERCP
		li := li + 1
		@ li, 000 PSAY "a seguir chamado apenas EMPREGADO, e celebrado o presente  CONTRATO DE EXPERIENCIA,"
		li := li + 1
		@ li, 000 PSAY "que tera  vigencia a partir  da data de inicio da prestacao de  servicos de  acordo"
		li := li + 1
		@ li, 000 PSAY "com as condicoes a seguir especificadas:"
		li := li + 2
		// @ li, 000 PSAY "Para exercer as funcoes de" 
		DbSelectArea("SRJ")                // * Funcao
		DbSetOrder(1)
		DbSeek(xFilial()+_xFuncao,.T.)
		// @ li, 030 PSAY SRJ->RJ_DESC
		// li := li + 1
		//@ li, 000 PSAY "com salario de R$"+left(str(_xSal),11,2) +"("+Substr(EXTENSO(_xSal),1,56)+Replicate("*",56-Len(EXTENSO(_xSal))) 
		//li := li + 1
		//@ li, 000 PSAY "("+Substr(EXTENSO(_xSal),57,70)+Replicate("*",70-Len(EXTENSO(_xSal)))+")" 
		@ li, 000 PSAY "1-)Fica o EMPREGADO admitido no quadro de funcionarios da  EMPREGADORA para exercer "
		li := li + 1
		@ li, 000 PSAY "as funcoes de "+SRJ->RJ_DESC+SPACE(01)+"a circunstancia, porem, de ser especificada  nao"
		li := li + 1
		@ li, 000 PSAY "importa na  intransferibilidade do EMPREGADO, para outro servico, no qual demonstre"
		li := li + 1
		@ li, 000 PSAY "melhor capacidade de adaptacao desde que compativel com sua condicao pessoal."
		li := li + 2
		@ li, 000 PSAY "2-)A remuneracao do empregado sera de R$"+str(_xSal,9,2) +"("+Substr(EXTENSO(_xSal),1,33)+Replicate("*",33-Len(EXTENSO(_xSal))) 
		li := li + 1
		@ li, 000 PSAY Substr(EXTENSO(_xSal),34,80)+Replicate("*",60-Len(EXTENSO(_xSal)))+") por mes de trabalho." 
		li := li + 1
		@ li, 000 PSAY "3-) O horario a ser obedecido sera o seguinte:                                     "
		li := li + 1
		@ li, 000 PSAY "4-) Este contrato tem inicio a partir de __/__/__, vencendo-se em __/__/__, podendo"
		li := li + 1
		@ li, 000 PSAY "    ser prorrogado, obedecido os Artigos 445 e 451 da C.L.T.                       "
		li := li + 1
		@ li, 000 PSAY "5-) O Empregado se compromete a trabalhar em regime de compensacao e de prorrogacao"
		li := li + 1
		@ li, 000 PSAY "    de horas, inclusive em periodo noturno, sempre que a necessidade assim o exigir"
		li := li + 1
		@ li, 000 PSAY "    observadas as formalidades legais.                                             "
		li := li + 1
		@ li, 000 PSAY "6-) Obriga-se o Empregado, alem de executar com dedicacao e lealdade o seu servico,"
		li := li + 1
		@ li, 000 PSAY "    a cumprir o Regulamento Intermo da Empregadora, as instrucoes  de sua  Adminis-"    
		li := li + 1
		@ li, 000 PSAY "    tradora e as ordens de seus chefes e superiores hierarquicos, relativas as  pe-"
		li := li + 1
		@ li, 000 PSAY "    culiaridades dos servicos que lhe forem confiados."
		li := li + 1
		@ li, 000 PSAY "7-) Se qualquer das partes quiser rescindir este contrato antes do termino previsto"
		li := li + 1
		@ li, 000 PSAY "    no item 3, aplicar-se-a o disposto nos artigos 479 e 480 da  CLT, isto e,  sera"
		li := li + 1
		@ li, 000 PSAY "    devida a indenizacao por metade que resultaria ate o  termo  final do  presente"
		li := li + 1
		@ li, 000 PSAY "    contrato.                                                                      " 
		li := li + 1
		@ li, 000 PSAY "8-) Alem dos descontos de lei, reserva-se o  Empregador o direito de  descontar  do"
		li := li + 1
		@ li, 000 PSAY "    do empregado os prejuizos ou danos causados por dolo, imprudencia,  negligencia"
		li := li + 1
		@ li, 000 PSAY "    ou impericia.                                                                  "
		li := li + 1
		@ li, 000 PSAY "9-) O presente contrato reger-se-a pelas normas constituidas  na  Consolidacao  das"
		li := li + 1
		@ li, 000 PSAY "    Leis do Trabalho e na Legislacao Trabalhista nao consolidada.                  "
		li := li + 1
		@ li, 000 PSAY "10-)Vencido o periodo de experiencia e continuando o empregado a prestar servicos a"
		li := li + 1
		@ li, 000 PSAY "    Empregadora, por tempo indeterminado, ficam prorrogadas todas as clausulas aqui" 
		li := li + 1
		@ li, 000 PSAY "    estabelecidas, enquanto nao se rescindir o Contrato de Trabalho.               "
		li := li + 2
		@ li, 000 PSAY "E por estarem de pleno acordo, assinam ambas as partes, em duas vias de igual teor."
		li := li + 3
		@ li, 000 PSAY SPACE(40)+SM0->M0_CIDCOB+", "+right(STR(DAY(DDATABASE)),2)+" de "+MESEXTENSO(MONTH(DDATABASE))+" de "+right(STR(year(ddatabase)),4)
		li := li + 3
		@ li, 000 PSAY "---------------------------"+SPACE(11)+"-------------------------------------------"
		li := li + 1
		@ li, 000 PSAY "            DATA           "+SPACE(11)+"     ASSINATURA RESPONSAVEL QUANDO MENOR   "
		li := li + 3
		@ li, 000 PSAY "---------------------------"+SPACE(11)+"-------------------------------------------"
		li := li + 1
		@ li, 000 PSAY "        EMPREGADORA        "+SPACE(11)+"              EMPREGADO                    "
		li := li + 4
		@ li, 000 PSAY  chr(27)+"  "+"                      T E R M O   D E   P R O R R O G A C A O                      "
		li := li + 1
		@ li, 000 PSAY "Por mutuo acordo entre as partes,fica o presente Contrato de Experencia,que deveria"
		li := li + 1
		@ li, 000 PSAY "vencer nesta data, prorrogado ate___/___/_____."
		li := li + 2
		@ li, 000 PSAY SM0->M0_CIDCOB+","+"___/ de __________________ de ______."
		li := li + 3
		@ li, 000 PSAY "---------------------------"+SPACE(11)+"-------------------------------------------"
		li := li + 1
		@ li, 000 PSAY "         EMPREGADORA       "+SPACE(11)+"              EMPREGADO                     
		li := li + 3
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
// Substituido pelo assistente de conversao do AP5 IDE em 11/10/00 ==> Function ValidPerg
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
