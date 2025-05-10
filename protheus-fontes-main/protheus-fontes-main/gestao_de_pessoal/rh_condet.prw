#INCLUDE "rwmake.ch"        // incluido pelo assistente de conversao do AP5 IDE em 11/10/00
#IFNDEF WINDOWS
#DEFINE PSAY SAY
#ENDIF

User Function rh_condet()        // incluido pelo assistente de conversao do AP5 IDE em 11/10/00

	// Programa..: rh_condet.PRX
	// Autor.....: Claudioir Macedo
	// Data......: 10/04/02
	// Nota......: Emissao Relatorio Contrato de Prazo Determidado

	#IFNDEF WINDOWS
	// Movido para o inicio do arquivo pelo assistente de conversao do AP5 IDE em 11/10/00 ==>    #DEFINE PSAY SAY
	#ENDIF

	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Variaveis utilizadas para parametros                         ³
	//³ mv_par01     // Matricula De                                 ³
	//³ mv_par02     // Matricula Ate                                *
	//* mv_par03     // Dias Experiencia                             ³
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
	cPerg   :="RH_CON"
	titulo  :="Contrato de Experiencia        "
	wnrel   :="RH_COND"
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
		_xTurno:=SRA->RA_TNOTRAB
		_xSal:=IIF(SRA->RA_SITFOLH="H",(SRA->RA_SALARIO * SRA->RA_HRSMES),SRA->RA_SALARIO)
		If _zMAT <> _xMAT
			If _zMAT <> "######"
				li := 0
			Endif
			_zMAT:=_xMAT
		Endif
		li := li + 2
		@ li, 020 PSAY "C O N T R A T O   D E   T R A B A L H O   "  
		li := li + 2
		@ li, 020 PSAY "P O R   P R A Z O  D E T E R M I N A D O "
		li := li + 3
		@ LI, 000 PSAY "Entre a Empresa  "+SM0->M0_NOMECOM
		li := li + 1
		@ li, 000 PSAY "com sede em  "+SM0->M0_CIDCOB+SPACE(10)+"a"+SPACE(10)+SM0->M0_ENDCOB
		li := li + 1
		@ li, 000 PSAY "CGC  "
		@ LI, 010 PSAY SM0->M0_CGC Picture"@R 99.999.999/9999-99"
		@ li, 036 PSAY "doravante designada simplesmente EMPREGADORA"
		li := li + 1
		@ li, 000 PSAY "e "+SRA->RA_NOME+SPACE(5)+space(10)+"portador da CTPS "+SRA->RA_NUMCP+"/"+SPACE(1)+SRA->RA_SERCP
		li := li + 1
		@ li, 000 PSAY "a seguir chamado apenas EMPREGADO,e celebrado o presente CONTRATO TRABALHO   POR"
		li := li + 1
		@ li, 000 PSAY "PRAZO DETERMINADO  que tera vigencia a partir da data de inicio da  prestacao de"  
		li := li + 1
		@ li, 000 PSAY "servicos de acordo com as condicoes a seguir especificadas:"
		li := li + 2
		// @ li, 000 PSAY "Para exercer as funcoes de"
		DbSelectArea("SRJ")                // * Funcao
		DbSetOrder(1)
		DbSeek(xFilial()+_xFuncao,.T.)
		@ li, 000 PSAY "01- O(A) EMPREGADO(A), é contratado(a), nesta data, para prestar serviços  a  EM-"
		li := li + 1
		@ li, 000 PSAY "PREGADORA, para exercer as funcoes de "+SRJ->RJ_DESC+SPACE(01)+"estando a seu cargo"
		li := li + 1
		@ li, 000 PSAY "direto, os trabalhos de controlar a entrada do produto e o fogo necessário para o"
		li := li + 1
		@ li, 000 PSAY "secador, coletar amostras de cereais, efetuar a especificação,  anotar  dados  em"
		li := li + 1
		@ li, 000 PSAY "formulários, proceder a limpeza periódica do  secador e do ambiente de trabalho e"
		li := li + 1
		@ li, 000 PSAY "mais os que vierem a ser objeto de ordens  verbais, cartas ou avisos, de   acordo "
		li := li + 1
		@ li, 000 PSAY "com as necessidades da EMPREGADORA e uma vez que sejam compatíveis e estejam  en-"
		li := li + 1
		@ li, 000 PSAY "quadrados, dentro de  suas  atribuições,  considerando-se falta grave a do(a) em-" 
		li := li + 1
		@ li, 000 PSAY "pregado(a), a recusa de executar qualquer dos serviços referidos."
		li := li + 2
		@ li, 000 PSAY "02-A remuneracao do empregado sera de R$"+str(_xSal,9,2) +"("+Substr(EXTENSO(_xSal),1,30)+Replicate("*",30-Len(EXTENSO(_xSal)))
		li := li + 1
		@ li, 000 PSAY Substr(EXTENSO(_xSal),31,77)+Replicate("*",60-Len(EXTENSO(_xSal)))+") por "+IIF (SRA->RA_CATFUNC="H","hora de trabalho.","mes de trabalho.")
		li := li + 2
		@ li, 000 PSAY "03-A EMPREGADORA, a seu exclusivo criterio e sem nenhum carater obrigacional, po-"
		li := li + 1
		@ li, 000 PSAY "dera antecipar adiantamentos  salariais , efetuando cabivel compensacao do  valor"
		li := li + 1
		@ li, 000 PSAY "adiantado, na contraprestacao normal, em creditos de toda  e  qualquer  natureza,"
		li := li + 1
		@ li, 000 PSAY "do(a) EMPREGADO(A)."
		li := li + 2   
		@ li, 000 PSAY "04-O(A) EMPREGADO(A), cumprira o seguinte horario, em regime  de compensacao  ou"
		li := li + 1   
		@ li, 000 PSAY "nao, das 07:30 as 12:00 e das 13:30 as 17:45 horas de segundas as sextas-feiras."
		li := li + 2
		@ li, 000 PSAY "05-O Presente contrato, vigira  durante 90(noventa)Dias, no periodo de "+DTOC(SRA->RA_ADMISSA)
		li := li + 1
		@ li, 000 PSAY "a "+DTOC(SRA->RA_VCTOEXP)+", vencendo-se independentemente , de quaisquer  interrupcoes ou sus-"
		li := li + 1
		@ li, 000 PSAY "pensoes, e findo o prazo estará extindo, sem que  caiba  a  qualquer das  partes"
		li := li + 1
		@ li, 000 PSAY "aviso previo ou indenizacao."
		li := li + 2
		@ li, 000 PSAY "06-O EMPREGADO fica obrigado a cumprir horario de trabalho estabelecido pela  em-"
		li := li + 1
		@ li, 000 PSAY "presa, em cada uma das unidades, seja ele diurno, noturno ou misto, em regime  de"
		li := li + 1
		@ li, 000 PSAY "compensacao horaria ou nao, o que , desde ja fica  acordado  entre as partes, nos"
		li := li + 1
		@ li, 000 PSAY "termos legais, podendo ser alterado pela mesma, a qualquer tempo,  mediante  sim-"
		li := li + 1
		@ li, 000 PSAY "ples comunicacao verbal ou escrita."
		li := li + 2
		@ li, 000 PSAY "07-Fica ajustado nos termos de que dispoe o paragrafo 1.do Art.469 da CLT, que  o"
		li := li + 1
		@ li, 000 PSAY "EMPREGADO acatara ordem emanada da EMPREGADORA para a prestacao de servicos  tan-"
		li := li + 1
		@ li, 000 PSAY "to na localidade de celebracao do CONTRATO DE TRABALHO, como em  qualquer   outra"
		li := li + 1
		@ li, 000 PSAY "cidade, capital ou vila  do  territorio  nacional, quer  esta  transferencia seja"
		li := li + 1
		@ li, 000 PSAY "transitoria, quer seja definitiva."
		li := li + 2
		@ li, 000 PSAY "08-O(A) EMPREGADO(A) compromete-se a prestar 44 (quarenta e quatro) horas de tra-"
		li := li + 1
		@ li, 000 PSAY "balho semanais, número este, passível de alteracao, conforme as necessidades   da"
		li := li + 1
		@ li, 000 PSAY "EMPREGADORA , por acordo individual ou coletivo de trabalho que,   para  todos os"
		li := li + 1
		@ li, 000 PSAY "efeitos, ficará fazendo parte integrante deste instrumento."
		li := li + 1
		@ li, 000 PSAY "Nas hipóteses previstas no Artigo 61 , paragrafo 3º, da CLT, sera facultado a EM-"
		li := li + 1
		@ li, 000 PSAY "PREGADORA, o uso do direito de recuperacao do tempo perdido."
		li := li + 1
		@ li, 000 PSAY "O(A) EMPREGADO(A) concorda, na forma do disposto no  paragrafo 2º, Artigo 59,  da"
		li := li + 1
		@ li, 000 PSAY "CLT, que podera ser dispensado o acréscimo do  salário, se o excesso de horas  em"
		li := li + 1
		@ li, 000 PSAY "um dia, forem compensados pela correspondente diminuicao em outro dia,  inclusive"
		li := li + 1
		@ li, 000 PSAY "sabados e sabados a tarde, de maneira que nao exceda o  horario normal da semana,
		li := li + 1
		@ li, 000 PSAY "nem seja ultrapassado o limite maximo de 10(dez) horas diarias."
		li := 0
		li := li + 3
		@ li, 000 PSAY "09-O Equipamento de  Protecao Individual(EPI), que  for entregue   ao(a) EMPREGA-"
		Li := li + 1
		@ li, 000 PSAY "DO(A), pela EMPREGADORA, devera ser usado durante o horario  de  trabalho,   apos"
		li := li + 1
		@ li, 000 PSAY "guardado no local apropriado, a ele indicado e, ao final  do  contrato, devolvido"
		li := li + 1
		@ li, 000 PSAY "em normais condicoes de conservacao."
		li := li + 1
		@ li, 000 PSAY "Os danos do EPI, em virtude de uso indevido e inadequado, ou  sua  nao  devolucao"
		li := li + 1
		@ li, 000 PSAY "nas  condicoes  antes mencionadas, sujeitarao o(a) EMREGADO(A)  ao  pagamento  de"
		li := li + 1
		@ li, 000 PSAY "indenizacao, em valor equivalente ao preco de seu custo, vigente na  data  de sua"
		li := li + 1
		@ li, 000 PSAY "substituicao ou da extincao do contrato de trabalho."
		li := li + 2
		@ li, 000 PSAY "10-Se o EMPREGADO(A), vier a fazer uso de  vale  transporte  regular publico,  em"
		li := li + 1
		@ li, 000 PSAY "seu deslocamento, residencia-trabalho e vice-versa, devera solicitar  a   EMPRE-"
		li := li + 1
		@ li, 000 PSAY "GADORA, por escrito e contra-recibo, o fornecimento de vale-transporte."
		li := li + 2 
		@ li, 000 PSAY "11-A EMPREGADORA, admite o(a) EMPREGADO(A), no regime do FUNDO DE  GARANTIA  POR"
		li := li + 1
		@ li, 000 PSAY "TEMPO DE SERVICO-FGTS- Lei 8.036/90, regulamentada pelo Decreto nº 99.684/90."
		li := li + 2
		@ li, 000 PSAY "12-As partes elegem o Foro de Ijui(RS), como unico  competente    para   dirimir"
		li := li + 1
		@ li, 000 PSAY "quaisquer litigios oriundos do presente contrato."
		li := li + 2
		@ li, 000 PSAY "E por estarem de pleno acordo, as partes contratantes assinam o presente Contra-"
		li := li + 1
		@ li, 000 PSAY "to de Experiencia em duas vias, ficando a primeira em poder da EMPREGADORA  e  a"
		li := li + 1
		@ li, 000 PSAY "segunda com o EMPREGADO, que dela dara o competente recibo."
		li := li + 3
		@ li, 000 PSAY +SM0->M0_CIDCOB+"," +str(day(SRA->RA_ADMISSA),2,0)+" de "+mesextenso(month(SRA->RA_ADMISSA))+" de "+str(year(SRA->RA_ADMISSA),4,0)
		li := li + 4
		@ li, 000 PSAY replicate("_",27)+"" +SPACE(08)+""+replicate("_",30)
		li := li + 1
		@ li, 000 PSAY "         TESTEMUNHA        "+SPACE(08)+" "+Left(SRA->RA_NOME,30)
		li := li + 4
		@ li, 000 PSAY replicate("_",27)+"" +SPACE(08)+""+replicate("_",30)
		li := li + 1
		@ li, 000 PSAY "         TESTEMUNHA        "+SPACE(08)+" "+Left(SM0->M0_NOMECOM,30)
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
	AADD(aRegs,{cPerg,"03","Dias Experiencia   ?","","","mv_ch3","N",02,0,0,"G","","mv_par03","","","","","","","","","","","","","","","","","","","","","","","","","",""})

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
