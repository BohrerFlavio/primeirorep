#INCLUDE "rwmake.ch"        // incluido pelo assistente de conversao do AP5 IDE em 11/10/00
#IFNDEF WINDOWS
#DEFINE PSAY SAY
#ENDIF

User Function ml_exp()        // incluido pelo assistente de conversao do AP5 IDE em 11/10/00

	// Programa..: ML_EXP.PRX
	// Autor.....: Fernando Possoli 
	// Data......: 23/08/2000
	// Nota......: Emissao Relatorio Contrato de Experiencia

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
	cPerg   :="ML_EXP"
	titulo  :="Contrato de Experiencia        "
	wnrel   :="RH_EXP"
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
		li := li + 2
		@ li, 020 PSAY "   C O N T R A T O   D E   T R A B A L H O  "
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
		@ li, 000 PSAY "01-Fica o EMPREGADO admitido no quadro de funcionarios da  EMPREGADORA para exercer "
		li := li + 1
		@ li, 000 PSAY "as funcoes de "+SRJ->RJ_DESC+SPACE(01)+"a circunstancia, porem, de ser especificada  nao"
		li := li + 1
		@ li, 000 PSAY "importa na  intransferibilidade do EMPREGADO, para outro servico, no qual demonstre"
		li := li + 1
		@ li, 000 PSAY "melhor capacidade de adaptacao desde que compativel com sua condicao pessoal."
		li := li + 2
		@ li, 000 PSAY "02-A remuneracao do empregado sera de R$"+str(_xSal,9,2) +"("+Substr(EXTENSO(_xSal),1,33)+Replicate("*",33-Len(EXTENSO(_xSal))) 
		li := li + 1
		@ li, 000 PSAY Substr(EXTENSO(_xSal),34,80)+Replicate("*",60-Len(EXTENSO(_xSal)))+") por mes de trabalho." 
		li := li + 2
		@ li, 000 PSAY "03-O horario de trabalho sera anotado na sua ficha de registro e a eventual reducao"
		li := li + 1
		@ li, 000 PSAY "da jornada, por determinacao da EMPREGADORA, nao inovara este ajuste,  permanecendo"
		li := li + 1
		@ li, 000 PSAY "sempre integra a obrigacao do EMPREGADO, de  cumprir  o horario que lhe for  deter-"
		li := li + 1
		@ li, 000 PSAY "minado, observando o limite legal."
		li := li + 2
		@ li, 000 PSAY "04-O EMPREGADO fica obrigado a cumprir o horario de trabalho estabelecido pela  em-"
		li := li + 1
		@ li, 000 PSAY "presa, em cada uma das unidades, seja ele diurno, noturno ou misto,  em  regime  de"
		li := li + 1
		@ li, 000 PSAY "compensacao horaria ou nao, o que, desde ja fica acordado entre as partes, nos ter-"
		li := li + 1
		@ li, 000 PSAY "mos legais, podendo ser alterado pela mesma, a qualquer tempo, mediante simples co-"
		li := li + 1
		@ li, 000 PSAY "municacao verbal ou escrita."  
		li := li + 2
		@ li, 000 PSAY "05-O EMPREGADO estará sujeito a nao marcacao do horario de trabalho, conforme  rege"
		li := li + 1
		@ li, 000 PSAY "a CLT em seu artigo 62, incisos I e II, quando ocupar cargos de  confianca ou  suas"
		li := li + 1
		@ li, 000 PSAY "funcoes forem exercidas fora do local de trabalho, conforme especificado na descri-"
		li := li + 1
		@ li, 000 PSAY "cao de cargos, no Manual da Qualidade interno da empregadora."
		li := li + 2
		@ li, 000 PSAY "06-Fica ajustado nos termos de que dispoe o paragrafo 1. do Art. 469 da CLT, que  o"
		li := li + 1
		@ li, 000 PSAY "EMPREGADO acatara ordem emanada da EMPREGADORA  para  a prestacao de servicos tanto"
		li := li + 1
		@ li, 000 PSAY "na localidade de celebracao do CONTRATO DE TRABALHO, como em qualquer outra cidade,"
		li := li + 1
		@ li, 000 PSAY "capital  ou vila do territorio nacional, quer esta transferencia  seja transitoria,"
		li := li + 1
		@ li, 000 PSAY "quer seja definitiva."
		li := li + 2
		@ li, 000 PSAY "07-No ato da assinatura deste contrato, o EMPREGADO recebe  Regulamento Interno  da"
		li := li + 1
		@ li, 000 PSAY "Empresa, cujas clausulas fazem parte do Contrato de Trabalho, e a violacao de qual-"
		li := li + 1
		@ li, 000 PSAY "quer delas implicara em sancao cuja graduacao dependera da gravidade da mesma, cul-"
		li := li + 1
		@ li, 000 PSAY "minando com a Rescisao do Contrato."
		li := li + 2
		@ li, 000 PSAY "08-Em caso de dano causado pelo EMPREGADO, fica a EMPREGADORA,autorizada a efetivar"
		li := li + 1
		@ li, 000 PSAY "o desconto da importancia correspondente ao prejuizo, o qual fara,com fundamento no"
		li := li + 1
		@ li, 000 PSAY "paragrafo 1. do artigo 462 da CLT,ja que essa possibilidade fica expressamente pre-"
		li := li + 1
		@ li, 000 PSAY "vista em contrato."
		li := li + 2
		@ li, 000 PSAY "09-O Presente contrato, vigira  durante 60 (Sessenta)Dias, sendo  celebrado para as"
		li := li + 1
		@ li, 000 PSAY "partes verificarem reciprocamente,a conveniencia ou nao de se vincularem em carater"
		li := li + 1
		@ li, 000 PSAY "definitivo a um Contrato de Trabalho por Prazo Indeterminado."
		li := li + 1
		@ li, 000 PSAY "A empresa passando a conhecer as aptidoes do  EMPREGADO e sua qualidades pessoais e"
		li := li + 1
		@ li, 000 PSAY "morais; o EMPREGADO verificando se o ambiente e os metodos atendem a sua convenien-"
		li := li + 1
		@ li, 000 PSAY "cia."
		li := li + 2
		@ li, 000 PSAY "10-Opera-se a rescisao do presente contrato pela decorrencia  do prazo supra ou por"
		li := li + 1
		@ li, 000 PSAY "vontade de uma das partes; rescindindo-se por vontade do EMPREGADO ou pela EMPREGA-"
		li := li + 1
		@ li, 000 PSAY "DORA com justa causa nenhuma indenizacao e devida; rescindindo-se  antes  do  prazo"
		li := li + 1
		@ li, 000 PSAY "pela EMPREGADORA, fica esta obrigada a pagar  50%  dos salarios devidos ate o final"
		li := 0
		li := 3
		@ li, 000 PSAY "(metade do tempo combinado restante) nos termos do art.479 da CLT, sem prejuizo  do"
		li := li + 1
		@ li, 000 PSAY "disposto no Reg. do FGTS. Nenhum  aviso  previo e devido  pela rescisao do presente"
		li := li + 1
		@ li, 000 PSAY "contrato."
		li := li + 2
		@ li, 000 PSAY "11-Na hipotese deste ajuste transformar-se em Contrato por Prazo Indeterminado pelo"
		li := li + 1
		@ li, 000 PSAY "decurso do tempo, continuarao em plena vigencia as clausulas de 1(Um) a 7(Sete) en-"
		li := li + 1
		@ li, 000 PSAY "quanto durarem as relacoes do EMPREGADO com a EMPREGADORA."
		li := li + 2
		@ li, 000 PSAY "12-As omissoes do presente contrato serao dirimidas pela CLT e  legislacao  vigente"
		li := li + 1
		@ li, 000 PSAY "ou reguladas posteriormente pela empregadora, escrita ou verbalmente."              
		li := li + 2
		@ li, 000 PSAY "E por estarem de pleno acordo, as partes contratantes, assinam o presente  Contrato"
		li := li + 1
		@ li, 000 PSAY "de Experiencia em duas vias, ficando a primeira em poder da EMPREGADORA,e a segunda"
		li := li + 1
		@ li, 000 PSAY "com o EMPREGADO, que dela dara o competente recibo."
		li := li + 3
		@ li, 000 PSAY SPACE(40)+SM0->M0_CIDCOB+", "+right(STR(DAY(DDATABASE)),2)+" de "+MESEXTENSO(MONTH(DDATABASE))+" de "+right(STR(year(ddatabase)),4)
		li := li + 3
		@ li, 000 PSAY "---------------------------"+SPACE(11)+"-------------------------------------------"
		li := li + 1
		@ li, 000 PSAY "         TESTEMUNHA        "+SPACE(11)+"     EMPREGADO OU RESPONS.QUANDO MENOR     "
		li := li + 3
		@ li, 000 PSAY "---------------------------"+SPACE(11)+"-------------------------------------------"
		li := li + 1
		@ li, 000 PSAY "         TESTEMUNHA        "+SPACE(11)+"              EMPREGADOR                   "
		li := li + 6
		@ li, 000 PSAY  chr(27)+"  "+"                      T E R M O   D E   P R O R R O G A C A O                      "
		li := li + 2
		@ li, 000 PSAY "Por mutuo acordo entre as partes,fica o presente Contrato de Experencia,que deveria"
		li := li + 1
		@ li, 000 PSAY "vencer nesta data, prorrogado ate___/___/_____."
		li := li + 2
		@ li, 000 PSAY SM0->M0_CIDCOB+","+"___/ de __________________ de ______."
		li := li + 3
		@ li, 000 PSAY "---------------------------"+SPACE(11)+"-------------------------------------------"
		li := li + 1
		@ li, 000 PSAY "         TESTEMUNHA        "+SPACE(11)+"     EMPREGADO OU RESPONS.QUANDO MENOR     "
		li := li + 3
		@ li, 000 PSAY "---------------------------"+SPACE(11)+"-------------------------------------------"
		li := li + 1
		@ li, 000 PSAY "         TESTEMUNHA        "+SPACE(11)+"              EMPREGADOR                   "+chr(27)+"  "
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
