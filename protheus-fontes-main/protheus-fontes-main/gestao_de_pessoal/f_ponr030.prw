#INCLUDE 'rwmake.ch'

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡„o    ³ PONR030  ³ Autor ³ J.Ricardo             ³ Data ³ 07.04.96 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡„o ³ Discrepancias da folha                                     ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³ PONR030(void)                                              ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³                                                            ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ Generico                                                   ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³         ATUALIZACOES SOFRIDAS DESDE A CONSTRU€AO INICIAL.             ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Programador ³ Data   ³ BOPS ³  Motivo da Alteracao                     ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³            ³        ³      ³                                          ³±±
±±³Mauricio MR ³16/10/01³------³ Correcao quebra de Turno/Seq da Tabela	  ³±±
±±³Mauricio MR ³21/10/01³010600³ Implementacao de identificacao de presen-³±±
±±³            ³        ³      ³ ca e ausencia por jornadas.    	  	  ³±±  
±±³Mauricio MR ³13/11/01³------³ Correcao Impressao Ano com 4 digitos.    ³±±
±±³Marinaldo   ³19/11/01³Melhor³A funcao GetMarcacoes passara a utilizar a³±±
±±³            ³--------³------³Funcao fDiasFolga() para Verificar as  Fol³±±
±±³            ³--------³------³gas Automaticas.						  ³±±  
±±³Mauricio MR ³27/11/01³Melhor³ Impressao de Cabecalho UNICO para todos  ³±±
±±³            ³        ³------³ os funcionarios quando for solicitada a  ³±±
±±³            ³        ³------³ verificacao de somente 1(um) Dia.        ³±±
±±³Mauricio MR ³28/11/01³Melhor³ Melhoria na Performance com Limitacao da ³±±
±±³            ³        ³------³ Classificacao de Jornadas e Selecao das  ³±±
±±³            ³        ³------³ marcacoes.                               ³±±
±±³Mauricio MR ³11/12/01³Melhor³ Impressao do Cracha do Funcionario.      ³±±
±±³Mauricio MR ³14/01/02³Melhor³ Alteracao do Pergunte para uma melhor Com³±± 
±±³            ³        ³------³ preensao da verificacao das jornadas.    ³±±
±±³=======================================================================³±± 
±±³                         *** Versao 7.10 ***                           ³±± 
±±³=======================================================================³±± 
±±³Mauricio MR ³21/02/02³Melhor³A)Retirada de Perguntas pois foram trans- ³±± 
±±³            ³        ³      ³feridas para o SX1.                       ³±± 
±±³Mauricio MR ³07/03/02³Melhor³ Acrescido novas Perguntas/Parametros -SX1³±± 
±±³            ³        ³      ³ p/Verif. Inicio de jornada e para forne -³±± 
±±³            ³        ³------³ cer a Hora de checagem das Jornadas.     ³±±
±±³Mauricio MR ³15/01/04³Acerto³ Verificacao de Afastamento tipo ferias   ³±± 
±±³            ³        ³      ³ para Ausentes em virtude de mudanca na   ³±± 
±±³            ³        ³      ³ montagem do calendario (PonxFun) onde os ³±± 
±±³            ³        ³      ³ dias para o periodo do afastamento passa ³±± 
±±³            ³        ³      ³ ram a ser considerados como nao trabalha ³±± 
±±³            ³        ³      ³ dos.									  ³±± 
±±ÀÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/

User Function F_PONR030()          

	//Especifico para o Frigorifico Silva

	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Define Variaveis Locais (Basicas)                            ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	Local cDesc1  := 'Discrepâncias do ponto'
	Local cDesc2  := 'Lista a comparação das marcacoes com o horario padrao'
	Local cDesc3  := 'do funcionario'
	Local cString := 'SRA' //-- Alias do arquivo principal (Base)
	//Local aOrd    := { 'Matricula', 'Centro de Custo' , 'Nome' , 'Turno' , 'C.Custo+Nome' } 
	Local aOrd    := { 'C.Custo+Nome', 'Matricula'  } 
	Local wnRel   := ''

	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Define Variaveis Private(Basicas)                            ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	Private aReturn    := { 'Zebrado' , 1, 'Administração' , 2, 2, 1, '',1 } 
	Private nomeprog   := 'PONR030'
	Private aLinha     := {}
	Private nLastKey   := 0
	Private cPerg      := "SNR030"
	Private aTabCalend := {}
	Private aMarcacoes := {}

	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Variaveis Utilizadas na funcao IMPR                          ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	Private Titulo   := OemToAnsi('Discrepâncias do ponto' ) 
	Private cCabec   := Titulo
	Private AT_PRG   := 'SNR030'
	Private wCabec0  := 0
	Private ContFl   := 1
	Private Li       := 0
	Private nTamanho := 'M'

	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Define Variaveis Private(Programa)                           ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	Private cFor       := ''
	Private cIndCond   := ''
	Private nOrdem     := 0
	Private dPerIni    := CtoD('  /  /  ')
	Private dPerFim    := CtoD('  /  /  ')
	Private aInfo      := {}
	Private aTurnos    := {}
	Private aTabPadrao := {}
	Private nPagAtu    := 1
	Private lUmDia	   := .F.      
	Private nAjusteFol := 0


	//-- Parƒmetro MV_PAPONTA
	dPerIni := CtoD('  /  /  ')
	dPerFim := CtoD('  /  /  ')
	If !PerAponta(@dPerIni, @dPerFim )
		Return Nil
	Endif	

	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Verifica as perguntas e adiciona caso nao exista             ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	aRegs := {}

	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Verifica as perguntas selecionadas                           ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	Pergunte(cPerg,.F.)
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Envia controle para a funcao SETPRINT                        ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	wnRel := 'PONR030' //-- Nome Default do relatorio em Disco
	wnRel := SetPrint(cString, wnRel, cPerg, @Titulo, cDesc1, cDesc2, cDesc3, .F., aOrd,,nTamanho)

	nOrdem    := aReturn[8]	

	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Variaveis utilizadas para parametros                         ³
	//³ mv_par01        //  Filial  De                               ³
	//³ mv_par02        //  Filial  Ate                              ³
	//³ mv_par03        //  Centro de Custo De                       ³
	//³ mv_par04        //  Centro de Custo Ate                      ³
	//³ mv_par05        //  Turno De                                 ³
	//³ mv_par06        //  Turno Ate                                ³
	//³ mv_par07        //  Matricula De                             ³
	//³ mv_par08        //  Matricula Ate                            ³
	//³ mv_par09        //  Nome De                                  ³
	//³ mv_par00        //  Nome Ate                                 ³
	//³ mv_par11        //  Situacao                                 ³
	//³ mv_par12        //  Categoria                                ³
	//³ mv_par13        //  Data a listar De                         ³
	//³ mv_par14        //  Data a listar Ate                        ³
	//³ mv_par15        //  Presentes ou Ausentes                	 ³
	//³ mv_par16        //  Listar CC em outra pagina                ³
	//³ mv_par17        //  Verificar as Jornadas do Dia      		 ³
	//³ mv_par18        //  Quais as Jornadas 			     		 ³
	//³ mv_par19        //  Presenca/Ausencia (Em Todas ou Pelo - 1) ³
	//³ mv_par20        //  Listar Crachas Provisorios               ³
	//³ mv_par21        //  Verificar Inicio de Jornadas             ³
	//³ mv_par22        //  Hora limite para checar Inicio Jornadas  ³
	//³ mv_par23        //  1-Todos, 2-Normais, 3-Atraso ou H.Extra  ³   
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ  



	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Carregando variaveis mv_par?? para Variaveis do Sistema.     ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ

	FilialDe  := mv_par01
	FilialAte := mv_par02
	CcDe      := mv_par03
	CcAte     := mv_par04
	TurDe     := mv_par05
	TurAte    := mv_par06
	MatDe     := mv_par07
	MatAte    := mv_par08
	NomDe     := mv_par09
	NomAte    := mv_par10
	cSit      := mv_par11
	cCat      := mv_par12
	dRefDe    := If(mv_par13<dPerIni,dPerIni,mv_par13)
	dRefAte   := If(mv_par14>dPerFim,dPerFim,mv_par14)
	lAusente  := If(mv_par15 == 1,.T.,.F.)
	lCCTur    := If(mv_par16 == 1,.T.,.F.)
	lsithor   := mv_par23

	lNaoVerifJrn := If(mv_par17==1,.T.,.F.) // .T. - Nao Verifica Jornadas
	cJornadas := mv_par18  //-- Jornadas Escolhidas para verificacao
	lTodasJrn := If(mv_par19 ==1 .AND. Len(Alltrim(StrTran(mv_par18,"*","")))>3,.T.,.F.) // .T. Considerar Ocorrencia de Ausencia/Presenca em Todas as Jornadas(Valido apenas para escolha de 2 ou mais jornadas a serem verificadas)
	lCracha   := If(mv_par20 == 1,.T.,.F.) //.T. Imprime Cracha
	lCkIniJorn:= If(mv_par21 == 1,.T.,.F.) //.T. Checa inicio de jornada
	nSerHoraCk:= fDHtoNS(dRefAte,mv_par22)  // Hora inicio de Jornadas

	lUmdia	  := If(dRefDe==dRefAte,.T.,.F.) //.T. verifica 1 (um) Dia Apenas
	If lUmDia
		wCabec0:=2
		wCabec1		:= '          |              Horario Programado               | |             Horario Realizado                 | H.Extras   Atrasos  ' 
		wCabec2      := 'Data      |1a.E. 1a.S.|2a.E. 2a.S.|3a.E. 3a.S.|4a.E. 4a.S.| |1a.E. 1a.S.|2a.E. 2a.S.|3a.E. 3a.S.|4a.E. 4a.S.|                     '
		nAjusteFol:=3                                                                   
	Endif

	If	nLastKey == 27
		Return Nil
	Endif

	SetDefault(aReturn,cString)

	If nLastKey == 27
		Return Nil
	Endif

	Titulo := OemToAnsi('Discrepâncias do ponto') 
	RptStatus({|lEnd| POR030Imp(@lEnd,wnRel,cString)},Titulo)

Return Nil

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o    ³ POR030Imp³ Autor ³ J.Ricardo             ³ Data ³ 07.04.96 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³ Relatorio de discrepancias da folha                        ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe e ³ POR030Imp(lEnd,wnRel,cString)                              ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³ lEnd        - A‡Æo do Codelock                             ³±±
±±³          ³ wnRel       - T¡tulo do relat¢rio                          ³±±
±±³Parametros³ cString     - Mensagem                                     ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ Generico                                                   ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/
Static Function POR030Imp(lEnd,WnRel,cString)

	//-- Defini‡„o de Variaveis Locais
	Local cSeqAnt       := '  '
	Local aPrevisto  	:= {}
	Local aRealizado   	:= {}
	Local aFun          := {}
	Local nCal       	:= 1
	Local nX            := 0
	Local cPrevisto  	:= ''
	Local cRealizado 	:= '' 
	Local cDet       	:= ''
	Local cOrdem        := ''
	Local dDtAfas    	:= CtoD('  /  /  ')
	Local dDtRet     	:= CtoD('  /  /  ')
	Local cAcessaSRA := &("{ || " + ChkRH("PONR030","SRA","2") + "}")
	Local nLenCalend	:= 0
	Local nLenMarc 	    := 0
	Local nLenPrev		:= 0 
	Local nLenaJornada  := 0
	Local nOcorr		:= 0 
	Local nPre			:= 0
	Local aOcorr		:=	{}
	Local aJornada		:=	{}
	Local nPosjrn		:=	0
	Local nPosocor		:=	0
	Local cOcorr		:=	''
	Local nNumMarc		:=	0
	Local cTipoDia      :=  ''
	Local nQtdeHoras    :=  0
	Local dData			:= Ctod('')
	Local aHorarios     := {}
	Local lOcorr		:= .F.
	Local lAfastado		:= .F.

	Private cCcAnt      := Space(9)
	Private cTnoAnt     := Space(3)
	Private cFilAnte    := '  '
	Private lRoda		:= .F. 
	Private aProvis		:= {}


	Private aCodigos   := {}                   // Codigos para leitura dos apontamentos
	IF !fCargaId(@aCodigos,SRA->RA_FILIAL)
		Return( NIL )
	EndIF   

	Private aControl := {} //eventos controladas
	dbSelectArea('SP9')
	dbGotop()
	Do While !Eof()
		If SP9->P9_CONTROL $  'AE'  //A-Atraso,E-Extra
			Aadd( aControl, { SP9->P9_CODIGO, SP9->P9_CONTROL } )
		Endif
		dbSkip()
	Enddo


	dbSelectArea( 'SRA' )
	dbGoTop()
	//DbSetOrder(nOrdem)

	If nOrdem == 1
		dbSetOrder(8)
		dbSeek(FilialDe + CcDe + NomDe,.T.)
		cInicio  := 'SRA->RA_FILIAL + SRA->RA_CC + SRA->RA_NOME'
		cFim     := FilialAte + CcAte + NomAte
	ElseIf nOrdem == 2  
		dbSetOrder(1)
		dbSeek(FilialDe + MatDe,.T.)
		cInicio  := 'SRA->RA_FILIAL + SRA->RA_MAT'
		cFim     := FilialAte + MatAte
	Endif

	SetRegua(SRA->(RecCount()))


	ttHe := 0  // total geral hora extra
	ttAt := 0  // total geral atraso


	//-- Looping principal dos funcionarios.
	While !SRA->(Eof()) .And. &(cInicio) <= cFim

		//-- Movimenta Regua.
		IncRegua()

		//-- Cancela Impressao caso se pressione Ctrl + A
		If lEnd
			Impr(cCancela,'C')
			Exit
		EndIF

		//-- Processa quebra de Filial.
		If SRA->RA_FILIAL # cFilAnte 
			//--Somente "Zera" as variaveis se jah foi impresso algo para nao pula 
			//--de pagina na primeira vez
			If !Empty(cTnoAnt)
				cTnoAnt := 'úúú'
				cSeqAnt := 'úú'
				cCcAnt  := '!!!!!!!!!'
			Endif

			If !fInfo(@aInfo,SRA->RA_FILIAL)
				Exit
			Endif	
			/*
			ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
			³ Carrega Crachas Provisorios                   			  ³
			ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ*/
			If lCracha
				//-- Se For Exclusivo, carrega crachas provisorios para a Filial Lida 
				If !Empty(xFilial("SPE"))
					aProvis:={}
					LoadCracha(@aProvis,SRA->RA_FILIAL)
				Else
					//-- Se compartilhado, carrega Todos os Registros se estiver vazio
					If Len(aProvis)==0
						LoadCracha(@aProvis)
					Endif
				Endif
			Endif

		Endif

		If cTnoAnt + cSeqAnt # SRA->RA_TNOTRAB + SRA->RA_SEQTURN
			If !Empty(cTnoAnt)
				cTnoAnt := 'úúú'
			Endif
			cSeqAnt := SRA->RA_SEQTURN
		Endif

		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³ Consiste controle de acessos e filiais validas               ³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		If SRA->(  !(RA_FILIAL $ fValidFil()) .Or. !Eval(cAcessaSRA) )
			fCabTotal()
			Loop
		EndIf

		//-- Consiste Parametrizacao do Intervalo de Impressao.
		If (SRA->RA_TNOTRAB < TurDe) .Or. (SRA->RA_TNOTRAB > TurAte) .Or. ;
		(SRA->RA_NOME < NomDe) .Or. (SRA->Ra_NOME > NomAte) .Or. ;
		(SRA->RA_MAT < MatDe) .Or. (SRA->Ra_MAT > MatAte) .Or. ;
		(SRA->RA_CC < CCDe) .Or. (SRA->RA_CC > CCAte)
			fCabTotal()
			Loop
		Endif

		//-- Consiste Situacao e Categoria a Imprimir.
		If !(Sra->Ra_SitFolh $ cSit) .Or. !(Sra->Ra_CatFunc $ cCat)
			fCabTotal()
			Loop
		Endif

		//-- Reinicializa Variaveis do Funcionario
		aTabCalend := {} ; aTurnos   := {} ; aMarcacoes := {}

		//-- Carrega as Marcacoes do Periodo
		IF !GetMarcacoes( @aMarcacoes		,;	//Marcacoes dos Funcionarios
		@aTabCalend		,;	//Calendario de Marcacoes
		@aTabPadrao		,;	//Tabela Padrao
		@aTurnos			,;	//Turnos de Trabalho
		dPerIni 			,;	//Periodo Inicial
		dPerFim			,;	//Periodo Final
		SRA->RA_FILIAL	,;	//Filial
		SRA->RA_MAT		,;	//Matricula
		SRA->RA_TNOTRAB	,;	//Turno
		SRA->RA_SEQTURN	,;	//Sequencia de Turno
		SRA->RA_CC		,;	//Centro de Custo
		"SP8"				,;	//Alias para Carga das Marcacoes
		.F.    			,;	//Se carrega Recno em aMarcacoes
		.T.      			,;	//Se considera Apenas Ordenadas
		.T.      			,;	//Se Verifica as Folgas Automaticas
		.F.      			 ;	//Se Grava Evento de Folga Automatica Periodo Anterior
		)
			Set Device to Screen
			Help(' ',1,'PONSCALEND')
			Set Device to Printer
			Exit
		EndIF

		//-- Verifica  os apontamentos -- // RPS
		#DEFINE DESC_DATA   1
		#DEFINE DESC_EXTRA  2
		#DEFINE DESC_ATRASO 3
		aDescrep   := {}

		lControl := .F.

		dbSelectArea('SP9') // eventos
		dbSetOrder(1) //filial+codigo


		ntHe := 0
		ntAt := 0

		dbSelectArea('SPC') // apontamentos
		dbSetOrder(2) //filial+matricula+data 
		dbSeek( xFilial('SPC')+SRA->RA_MAT+DTOS(dRefDe),.T.)   
		Do While !Eof() .AND. SPC->PC_MAT == SRA->RA_MAT .AND. SPC->PC_DATA <= dRefAte
			SP9->( dbSeek(xFilial('SP9')+SPC->PC_PD ) )
			If SP9->P9_CONTROL $ 'AE'
				lControl := .T.
				onde := Ascan( aDescrep, { |reg| reg[DESC_DATA ] == SPC->PC_DATA } )
				IF onde == 0  //    DATA                    HORA EXTRA                              ATRASO
					AADD( aDescrep,{ SPC->PC_DATA, If(SP9->P9_CONTROL=='E',SPC->PC_QUANTC , 0 ), If(SP9->P9_CONTROL=='A',SPC->PC_QUANTC , 0 ) } )
				Else          //   Adiciona
					If SP9->P9_CONTROL=='E'
						aDescrep[ onde, DESC_EXTRA  ] += SPC->PC_QUANTC
					Else      
						aDescrep[ onde, DESC_ATRASO ] += SPC->PC_QUANTC
					Endif
				Endif

				If SP9->P9_CONTROL=='E'
					ntHe +=  fConvHr(SPC->PC_QUANTC ,  'D') 
					ttHe +=  fConvHr(SPC->PC_QUANTC ,  'D') 
				Else
					ntAt +=  fConvHr(SPC->PC_QUANTC ,  'D') 
					ttAt +=  fConvHr(SPC->PC_QUANTC ,  'D') 
				Endif

			Endif
			dbSkip()
		Enddo  

		//-- Consiste situacao horario 
		If ( lsithor == 2  .AND. lControl      )  .OR. ;// normais
		( lsithor == 3  .AND. !lControl     )        // atrasos e h.extra
			fCabTotal()
			Loop
		Endif

		//-- Monta Array com Marcacoes Previstas.
		nCal 		:= aScan( aTabCalend, { |x| x[4] == '1E' .and. x[1] >= Max( dPerIni , SRA->RA_ADMISSA ) } )
		nCal 		:= If(nCal>0,nCal,1)
		aPrevisto 	:= {}	
		aJornada	:= {}    
		nLenCalend	:= Len(aTabCalend)

		//-- Corre Todas as Previsoes de Horarios
		While nCal <= nLenCalend	
			//-- Desconsidera Datas Fora do Periodo
			If (aTabCalend[nCal,1] < dRefDe .Or. aTabCalend[nCal,1] > dRefAte).OR.;
			aTabCalend[nCal,4]<>"1E"
				nCal ++
				Loop
			EndIf


			cOrdem     := aTabCalend[nCal,2] //-- Ordem
			dData	   := aTabCalend[nCal,1] //-- Data da Tabela Hor. Padrao	
			cTipoDia   := aTabCalend[nCal,6] //-- Tipo do Dia
			nQtdeHoras := aTabCalend[nCal,7] //-- Qtde de Horas trab. no Dia
			lAfastado  := aTabCalend[nCal,24] //-- Afastamento


			onde := ASCAN( aDescrep,{|reg| reg[DESC_DATA] == dData } )

			If ( lsithor == 2  .AND. onde <> 0      )  .OR. ;// normais
			( lsithor == 3  .AND. onde == 0      )        // atrasos e h.extra
				nCal++
				Loop
			Endif

			//-- Se Verifica Jornada e deve checar Inicio Jornada e a
			//-- Hora inicial da Tabela for superior/igual a hora de checagem
			If !lNaoVerifJrn .AND. lCkIniJorn .AND. nSerHoraCk < fDhtoNs(dData,aTabCalend[nCal,3]) 
				nCal ++
				Loop
			Endif 
			cPrevisto  :=''  
			aHorarios  :={}

			//-- Corre as Previsoes de mesma Ordem
			While cOrdem == aTabCalend[nCal,2]
				//-- Cria String com os Horarios Previstos
				cPrevisto+= StrZero(aTabCalend[nCal,3],5,2) + Space(1)
				//-- Somente Para Entradas Considera Inicio de Jornadas
				If Substr(aTabCalend[nCal,4],2,1)='E'
					aAdd(aHorarios,	;
					Jornadas(aTabCalend[nCal,4],;	//1e/2e/3e/4e 
					aTabCalend[nCal,1],;    		//Data de Referencia Lim Inferior
					aTabCalend[nCal,3],;	 		//Limite Inferior da Jornada em Serial
					aTabCalend[nCal+1,1],;    		//Data de Referencia Lim Sup
					aTabCalend[nCal+1,3]))			//Limite Superior da Jornada em Serial

				Endif      			 
				nCal ++                  
				If	nCal > nLenCalend
					Exit
				Endif    
			EndDo
			//-- Cria Elemento com Data/Horario/Ordem/Tipo do Dia/Afastado
			aAdd( aPrevisto, {dData, cPrevisto, cOrdem, cTipoDia, lAfastado})
			//-- Cria Elemento com os Horarios das Jornadas como SubArray
			aAdd(aJornada,{	cOrdem,Aclone(aHorarios),nQtdeHoras})
		EndDo

		//-- Monta Array com Marcacoes Realizadas.
		nPosJrn		:=0
		aRealizado 	:= {}
		nNumMarc   	:=0
		nLenMarc	:=Len(aMarcacoes)
		nLenaJornada:=Len(aJornada)

		//-- Se Existirem Marcacoes
		If !EMPTY(nLenMarc)
			//Corre Todas as Ordens (Cada Elemento em aJornada contem todas as Jornadas de mesma ordem)  
			For nX:=1 To nLenaJornada
				cOrdem := aJornada[nX,1]

				//-- Obtem a 1a das Marcacoes Segunda a Ordem Lida
				nPosJrn:= Ascan(aMarcacoes,{|x| x[3]==cOrdem})
				//-- Se Nao Existir Marcacao para a Ordem despreza 
				If Empty(nPosJrn)
					Loop
				Endif
				//-- Corre as Marcacoes da ordem
				nNumMarc	:=0
				cRealizado	:=''
				nMarc		:=nPosJrn
				While cOrdem == aMarcacoes[nMarc,3]
					nNumMarc++
					cRealizado += StrZero(aMarcacoes[nMarc,2],5,2) + Space(1)
					//-- Verifica Ausencia/Presenca nas Jornadas conforme Marcacao
					Classifica(aMarcacoes[nMarc,1], aMarcacoes[nMarc,2],@aJornada,nX,nNumMarc)
					nMarc++
					//-- Se o contador ultrapassar o total de Marcacoes abandona loop
					If nMarc>nLenMarc
						Exit
					Endif   
				EndDo
				//-- Cria Elemento que conterah as marcacoes realizadas
				aAdd(aRealizado, {aMarcacoes[nPosJrn,1], cRealizado, cOrdem})
			Next nX
		Endif 

		//-- Para Jornadas Sem Classificacao Considera que Houve Ausencia do Funcionario
		//-- Y[4]:= A1E OU A2E OU A3E ....
		AEVAL(aJornada,{|x| Aeval(x[2],{|y|if(Empty(y[4]),y[4]:='A'+Y[3],Nil)})})
		nPosJrn	:=0
		//-- Monta array com as Marcacoes a serem impressas.
		aFun 		:= {}         
		nLenPrev	:=Len(aPrevisto)
		cRealizado	:=''
		For nPre := 1 to nLenPrev		
			cPrevisto  := ''
			cRealizado := '' 
			cDet       := ''
			cTipAfas   := ''
			dDtAfas    := CtoD('  /  /  ')
			dDtRet     := CtoD('  /  /  ')		

			cPrevisto := StrTran(aPrevisto[nPre,2],'.',':')
			cPrevisto += Space(24-Len(cPrevisto))
			If ( nPos := aScan( aRealizado, { |x| x[3] == aPrevisto[nPre,3] } ) ) > 0
				cRealizado := StrTran(aRealizado[nPos,2],'.',':')
			EndIf
			cDet := Padr(PADR(DtoC(aPrevisto[nPre,1]),10) + DetHorario(cPrevisto,4),59)

			//-- Procura pelas Jornadas da Ordem
			nPosJrn:=Ascan(aJornada,{|x|x[1]==aPrevisto[nPre,3]})

			//-- Verifica se houve Ausencia em alguma das Jornadas da Ordem
			nPosOcor:=Ascan(aJornada[nPosJrn,2],{|x|Substr(x[4],1,1)=='A'}) 

			If !lAusente //-- Presentes 

				//-- Se nao Houve Marcacoes ou (se Ocorreu Alguma Ausencia e o usuario
				//-- deseja presenca no dia todo)
				//-- Desconsidera Marcacoes do dia para Relacao de Presentes
				If Len(cRealizado) <= 0 
					Loop
				EndIf  
				//-- Se Nao Verifica Jornadas
				If lNaoVerifJrn 		        
					//-- Alimenta String com as Marcacoes Ocorridas
					cOcorr:=cRealizado
				Else    
					//-- Carrega Presencas nas Jornadas do Dia Lido
					aOcorr:={}
					Aeval(aJornada[nPosJrn,2],{|x|iF(Substr(x[4],1,1)=='P' .AND. !Empty(Substr(x[4],2,1)),aAdd(aOcorr,Substr(x[4],2,2)),Nil)})				
					//-- Para Dias sem horario a Tabela Padrao Gera uma Jornada com horarios Zerados
					//-- a Funcao Classifica acusa presenca para funcionarios com marcacoes nesse dia
					//-- colocando no 4o. Elemento a letra 'P' sem a definicao da entrada (1E/2E...)
					//-- Deste modo adotamos que, para dias sem horario mas com marcacao, o funcionario
					//-- este presente em todas as jornadas. 

					//-- Se Nao houver a identificacao da jornada 
					If Empty(Len(aOcorr))
						//-- Se Nao ocorreram ausencias
						//-- funcionario fez horario em dia NAO TRABALHADO
						If Empty(nPosOcor)
							cOcorr:=cRealizado
						Else
							//-- Funcionario Nao Veio nas Jornadas Solicitadas, embora
							//-- Possa ter realizado marcacoes em outro horario(Fora da Tabela)
							Loop
						Endif   
					Else
						cOcorr:=''
						//-- Se Deve Verificar Presenca em Todas as Jornadas
						//-- Verifica se houve Presenca Parcial
						If lTodasJrn
							//-- Se o Func. teve Presenca Parcial (Total de Presenca <> Total de Jornadas)
							//-- e Escolheu mais que uma Jornada
							If Len(aOcorr)#Len(aJornada[nPosJrn,2]) 
								Loop
							Endif
							cOcorr:= cRealizado
						Else
							//-- Imprime Jornadas com Presenca 
							For nOcorr:=1 To Len(aOcorr)
								//--Verifica se a Ocorrencia existiu em uma das Jornadas Selecionadas
								If aOcorr[nOcorr]$cjornadas
									cOcorr:= cRealizado
									Exit
								Endif	
							Next nOcorr              
						Endif

						//-- Para as Jornadas selecionadas o func nao esteve presente
						//-- embora tenha marcacao para outras jornadas do dia.
						If Empty(cOcorr)
							Loop
						Endif   
					Endif
				Endif
				//-- Imprime Jornadas com Presenca 
				cDet += Space(1) + DetHorario(cOcorr,5)

			Else //-- Ausentes
				//-- Se Nao Houve Ausencias
				//-- Ou Tipo de Dia Diferente de Trabalhado/Feriado ou
				//-- situacao de Transferido/ferias e demissao
				If	Empty(nPosOcor) .OR. ;
				(aPrevisto[nPre,4] # 'S' .AND. !aPrevisto[nPre,5])  .Or. ;
				fFeriado(SRA->RA_Filial,aPrevisto[nPre,1]) .Or. ;
				SRA->RA_SitFolha $ 'DúT' .And. aPrevisto[nPre,1] > SRA->RA_Demissa
					Loop
				EndIf


				//-- Carrega as Ocorrencias de Ausencias nas Jornadas do Dia Lido
				aOcorr:={}
				Aeval(aJornada[nPosJrn,2],{|x|iF(Substr(x[4],1,1)=='A',aAdd(aOcorr,Substr(x[4],2,2)),Nil)})		   		    

				//-- Se Nao Verifica Jornadas
				if lNaoVerifJrn     
					//-- Se ocorreu marcacoes desconsidera o dia
					If Len(cRealizado) > 0 
						Loop
					EndIf  
					If fAfasta( SRA->RA_Filial,SRA->RA_Mat,aPrevisto[nPre,1],@dDtafas,@dDtRet,@cTipAfas) .Or. ;
					SRA->RA_SitFolh $ 'DúT' .And. aPrevisto[nPre,1] > SRA->RA_DEMISSA
						cDet += Space(1) + '|'+PADC(If(cTipAfas=='F','           ** Ferias **            ' ,'          ** Afastado **           '),59)+'|'
						// '           ** Ferias **            '###'          ** Afastado **           '

					Else   

						cDet+=Space(1)+DetAusencia(aOcorr,Len(aJornada[nPosJrn,2]))
					Endif 

				Else
					//-- Se optou por Verificar Jornadas
					//-- Verifica Afastamentos
					If fAfasta( SRA->RA_Filial,SRA->RA_Mat,aPrevisto[nPre,1],@dDtafas,@dDtRet,@cTipAfas) .Or. ;
					SRA->RA_SitFolh $ 'DúT' .And. aPrevisto[nPre,1] > SRA->RA_DEMISSA
						cDet += Space(1) + '|'+PADC(If(cTipAfas=='F','           ** Ferias **            ' ,'          ** Afastado **           '),59)+'|' // '           ** Ferias **            '###'          ** Afastado **           '
					Else
						lOcorr:=.F.
						//-- Se Deve Verificar Ausencia em Todas as Jornadas
						//-- Verifica se houve Ausencia Parcial
						If lTodasJrn
							//-- Se o Func. teve Ausencia Parcial (Total de ausencia <> Total de Jornadas)
							If Len(aOcorr)#Len(aJornada[nPosJrn,2]) 
								Loop
							Endif 
							lOcorr:= .T.
						Else	
							//-- Imprime Jornadas com Presenca 
							For nOcorr:=1 To Len(aOcorr)
								//--Verifica se a Ocorrencia existiu em uma das Jornadas Selecionadas
								If aOcorr[nOcorr]$cjornadas
									lOcorr:= .T.
									Exit
								Endif	
							Next nOcorr  
						Endif                
						//-- Para as Jornadas selecionadas o func nao esteve presente
						//-- embora tenha marcacao para outras jornadas do dia.
						If !lOcorr
							Loop
						Endif  
						cDet+=Space(1)+DetAusencia(aOcorr,Len(aJornada[nPosJrn,2]))
					Endif
				Endif   	   
			EndIf           

			cDet := Substr(cDet,1,111)+fImpDescr( aPrevisto[nPre,1] ) 

			aAdd(aFun, cDet)		
			aOcorr:={}                            

		Next nPre

		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³ Imprime Funcionarios                                         ³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		lTot := fImpFun(@aFun)
		fCabTotal()

		if lcontrol .AND. lTot                                    
			@ Li,001  PSAY 'Total Funcionário:'
			@ Li,111  PSAY StrTran(Transform( fConvHr( ntHe,'H'), '@e 9999.99' ),',',':' )
			@ Li,122  PSAY StrTran(Transform( fConvHr( ntAt,'H'), '@e 9999.99' ),',',':' )
			Li+=2       
		Endif


	EndDo

	if lsithor == 3 
		Li+=2
		@ Li,001  PSAY 'Total Geral:'
		@ Li,110  PSAY StrTran(Transform(fConvHr( ttHe,'H'), '@e 99999.99' ),',',':' )
		@ Li,121  PSAY StrTran(Transform(fConvHr( ttAt,'H'), '@e 99999.99' ),',',':' )
	Endif



	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Imprime Rodape de Pagina na Ultima Pagina do Relatorio       ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	IF lRoda
		IF Li < 58
			Li := 58
		EndIF
		Impr("","F")	
	EndIF

	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Termino do relatorio                                         ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	dbSelectArea('SRA')
	dbSetOrder(1)
	Set Device To Screen
	If aReturn[5] == 1
		Set Printer To
		Commit
		ourspool(wnrel)
	Endif

	MS_FLUSH()

	Return Nil

	*---------------------------*
Static Function fCabTotal()
	*---------------------------*
	dbSelectArea( "SRA" )
	dbSkip()

	nPagAtu := ContFl

	Return( NIL )

	*-------------------------------------------*
Static Function fImpFun(aFun)            // Imprime um Funcionario e Executa Quebras
	*-------------------------------------------*

	IF	Len(aFun) == 0
		Return .F.
	EndIF

	If cCcAnt # SRA->RA_CC .And. SRA->( !Eof() ) .And. (nOrdem == 1 ) .and.	;
	cFilAnte == SRA->RA_FILIAL // Quebra p/ C.Custo
		fImprime({},2)
	ElseIf cFilAnte # SRA->RA_FILIAL .And. SRA->( !Eof() ) // Quebra p/ Filial
		fImprime({},3)
	Endif

	cFilAnte:= SRA->RA_FILIAL
	cCcAnt  := SRA->RA_CC
	cTnoAnt := SRA->RA_TNOTRAB

	fImprime(aFun,1)
	aFun := {}

	Return .T. 

	*-----------------------------------------------*
Static Function fImprime(aFun,nTipo)
	*-----------------------------------------------*
	// nTipo: 1- Funcionario
	//        2- Centro de Custo
	//        3- Filial
	//        4- Turno

	Local Det    := ""
	Local nPre   := 0
	Local nLenFun:= 0

	If nTipo == 2	// Salta pagina a cada Centro de Custo
		If lCCTur .And. !Empty(cCcAnt)
			fPNR030Linha(2,,"P")
		Else
			fPNR030Linha(2)
		Endif
	ElseIf nTipo == 3	// Salta pagina a cada Filial
		If nOrdem == 1
			fPNR030Linha(nOrdem,,"P")
		Else
			fPNR030Linha(3,,"P")
		Endif
	ElseIf nTipo == 4	// Salta pagina a cada Filial
		If lCCTur .And. !Empty(cTnoAnt) //Salta Pagina a Cada Turno
			fPNR030Linha(4,,"P")	// Imprime cabecalho do Turno
		Else
			fPNR030Linha(4)			// Imprime cabecalho do Turno
		Endif
	Endif

	If nTipo == 1
		Det := "MATR: " + SRA->RA_MAT + ' ' + "NOME: " + SRA->RA_NOME + Space(1) // "MATR: "###"NOME: "
		Det += "C.CUSTO: " + SRA->RA_CC + Space(2) //+ Posicione('CTT', 1, xFilial('CTT')+SRA->RA_CC, 'CTT_DESC01' )
		Det := Left(Det,132)
		fPNR030Linha(1,Det)
		fPNR030Linha(1,Replicate("-",132)) 
		//-- Se o periodo Apresenta Varios dias, exibe-se o cabecalho da linha
		//-- para cada funcionario lido
		If !lUmDia
			//-- Imprime o Cabec da Linha Detalhe
			Det:= '          |              Horario Programado               | |             Horario Realizado                 | H.Extras   Atrasos  ' 
			Det := Left(Det,132)
			fPNR030Linha(1,Det)
			//-- Linha 2 do Cabec Linha Detalhe
			Det:= 'Data      |1a.E. 1a.S.|2a.E. 2a.S.|3a.E. 3a.S.|4a.E. 4a.S.| |1a.E. 1a.S.|2a.E. 2a.S.|3a.E. 3a.S.|4a.E. 4a.S.|                     ' 
			Det := Left(Det,132)	
			fPNR030Linha(1,Det)   
			//-- Separador 
			fPNR030Linha(1,Replicate("-",132))
		Endif
		//-- Imprime as Linhas Detalhes  
		nLenFun:=Len(aFun)

		For nPre := 1 to nLenFun
			If Li >= (52+nAjusteFol)
				If nOrdem == 1 
					fPNR030Linha(nOrdem,,"P")
				Else
					fPNR030Linha(3,,"P")
				Endif
				//-- Imprime a Identificacao do Funcionario
				Det := "MATR: " + SRA->RA_MAT + ' ' + "NOME: " + SRA->RA_NOME+" "+"C.CUSTO: "+SRA->RA_CC+"  " 
				//Det += "TURNO ATUAL: " + SRA->RA_TNOTRAB + ' '+fDescTno(SRA->RA_FILIAL,SRA->RA_TNOTRAB)			//"TURNO ATUAL: "
				Det := Left(Det,132)
				fPNR030Linha(1,Det)   
				fPNR030Linha(1,Replicate("-",132))
				//-- Se o periodo Apresenta Varios dias, exibe-se o cabecalho da linha
				//-- para cada funcionario lido
				If !lUmDia
					//-- Imprime o Cabec da Linha Detalhe
					Det:= '          |              Horario Programado               | |             Horario Realizado                 |  H.Extras   Atrasos  ' 
					Det := Left(Det,132)
					fPNR030Linha(1,Det)
					//-- Linha 2 do Cabec Linha Detalhe
					Det:= 'Data      |1a.E. 1a.S.|2a.E. 2a.S.|3a.E. 3a.S.|4a.E. 4a.S.| |1a.E. 1a.S.|2a.E. 2a.S.|3a.E. 3a.S.|4a.E. 4a.S.|                      '
					Det := Left(Det,132)	
					fPNR030Linha(1,Det)   
					//-- Separador 
					fPNR030Linha(1,Replicate("-",132))
				Endif
			Endif
			//-- Imprime a Linha Detalhe
			fPNR030Linha(1,Left(aFun[nPre],132))
		Next nPre
		fPNR030Linha(1,'')                    
		//-- Separador de Funcionario
		fPNR030Linha(1,Replicate("-",132))
	EndIF	

	Return( NIL )

	*-------------------------------------------*
Static Function fPNR030Linha(nTipo,Det,cPara)	// Imprime cabecalhos
	*-------------------------------------------*
	Local cDet:=""

	nTipo := If(nTipo==NIL,0,nTipo)
	cPara := If(cPara==Nil,"C",cPara)

	If Li >= (52+nAjusteFol) .Or. cPara == "P"
		Impr("","P")
	Endif
	If nTipo == 1
		Impr(Det,"C")
		lRoda := .T.
	ElseIf nTipo > 0
		If nTipo == 2 .Or. nTipo == 5 .Or. nPagAtu <> ContFl
			cDet:= "Filial: "+SRA->RA_FILIAL+" - "+"    C.C: "+SRA->RA_CC+" - "+DescCc(SRA->RA_CC,SRA->RA_FILIAL)		//"Filial: "###"    C.C: "
		Elseif nTipo == 3 .Or. nPagAtu <> ContFl
			cDet:= "Filial: "+SRA->RA_FILIAL+" - "+aInfo[1]		//"Filial: "
		Elseif nTipo == 4 .Or. nPagAtu <> ContFl
			cDet:= "Filial: "+SRA->RA_FILIAL+" - "+" Turno: "+SRA->RA_TNOTRAB+" - "+FDescTno(SRA->RA_FILIAL,SRA->RA_TNOTRAB)		//"Filial: "###" Turno: "
		Endif
		Impr(cDet,cPara)
		Impr(Replicate("-",132),"C")
		lRoda := .T.
	Endif
	nPagAtu := ContFl

Return( NIL )
/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡„o    ³DetHorario  ³ Autor ³ Mauricio MR           ³ Data ³26/10/01³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³ Imprime Linha Detalhe de Marcacoes                         ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³ DetHorario(cHorario,nTam)                                  ³±±
±±³          ³ cHorario -> Texto com as marcacoes 08:00 12:00 13:00 17:00 ³±±
±±³          ³ nTam     -> Numero de jornadas (Pares de horarios)         ³±± 
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Retorno   ³ cTexto   -> Jornadas Delimitadas por '|'                   ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³Ponr030                                                     ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/

Static Function DetHorario(cHorario,nTam)
	Local cTexto	:='|'
	Local nPos		:= 1 
	Local cHora		:= ''
	Local nHorario	:=	0

	cHorario:=ALLTRIM(cHorario)

	//-- Corre Todas as Jornadas (Max de 5 conforme cabecalho) 
	For nHorario:=1 To nTam
		cHora:=Substr(cHorario,npos,11)
		If !Empty(cHora)
			cTexto+=PADR(cHora,11)
		Else
			cTexto+=Space(11)
		Endif	             
		cTexto+='|'
		npos+=12
	Next nHorario    

Return cTexto  


/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡„o    ³DetAusencia ³ Autor ³ Mauricio MR           ³ Data ³26/10/01³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³ Imprime Linha Detalhe de Marcacoes                         ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³ DetAusencia(aOcorr,nNumJrn)                                ³±±
±±³          ³ aOcorr    -> Array com as Ocorrencias: A1e / A2e ...       ³±±
±±³          ³ nNumJrn   -> Qtde de Jornadas Previstas                    ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Retorno   ³ cTexto   -> 1a Letra de cada Ocorrencia Centralizada e     ³±±
±±³          ³             Delimitada por '|'                             ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³Ponr030                                                     ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/


Static Function DetAusencia(aOcorr,nNumJrn)
	Local nJornada 	:= 0
	Local cTexto	:='|'
	Local nPos		:= 0 


	//-- Corre Todas as Jornadas (Max de 5 conforme cabecalho) 
	For nJornada:=1 To 5
		//-- Se Nao Verifica Jornadas
		if lNaoVerifJrn     
			cTexto+=If(nJornada<=nNumJrn,Space(5) +'A'+Space(5),Space(11)) 	
		Else
			//Verifica se Ocorrencia estah entre as Jornadas Solicitadas
			npos:=Ascan(aOcorr,{|x| Val(substr(x,1,1))==nJornada})
			If !Empty(nPos) .AND. nJornada<=nNumJrn  
				cTexto+=Space(5) +'A'+Space(5) 
			Else
				cTexto+=Space(11)
			Endif	             
		Endif
		cTexto+='|'
	Next nJornada    

Return cTexto             








/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡„o    ³fValidJorn  ³ Autor ³Equipe Advanced RH     ³ Data ³22/10/01³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄ´±±
±±³Descri‡„o ³Validar a multipla escolha do tipo de marcacao 1E/2E/3E/4E  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³fValidJorn( l1Elem , cTipo )                                ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Observa‡„o³ Retorna Marcacoes de Entrada para Escolha de Jornada       ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³Ponr030                                                     ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/

Static Function fValidJorn( l1Elem , cTipo )

	Local aMarc		:= {}
	Local cMarc		:= ""
	Local cTitulo	:= 'Selecione as Jornadas com Inicio na: '
	Local MvParDef	:= ""
	Local MvPar		:= &( Alltrim( ReadVar() ) )
	Local nX		:= 0.00
	Local nCampos	:= SPJ->( fCount() )
	Local lRet	    := .T.

	l1Elem			:= IF( l1Elem == NIL .and. ValType( l1Elem ) != "L" , .F. , .T. )
	MvRet			:= Alltrim( ReadVar() )

	IF cTipo != 'I'       

		For nX := 1 To nCampos
			cCampo := SPJ->( FieldName( nX ) )
			IF Subs(cCampo,1,8) == "PJ_ENTRA" 
				cMarc := Subs( cCampo , 9 , 1) + Subs( cCampo , 4 , 1 )
				MvParDef += ( cMarc + "-" )
				aAdd( aMarc , cMarc += ( "-" + GetDescMarc( cMarc  ) ) )
			EndIF
		Next nX
	Else
		aAdd( aMarc , "I1-" + GetDescMarc( "I1" ) )
		aAdd( aMarc , "I2-" + GetDescMarc( "I2" ) )
		aAdd( aMarc , "I3-" + GetDescMarc( "I3" ) )
		MvParDef := "I1-I2-I3-"
	EndIF

	IF MvPar != NIL
		f_Opcoes(@MvPar,cTitulo,aMarc,MvParDef,12,49,l1Elem,3)
	EndIF	

	lRet:=.T.
	&(MvRet) := MvPar
	if Empty(&(MvRet))
		lRet:=.F.
	Endif


Return( lRet )


/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡„o    ³Classifica³ Autor ³ Mauricio MR           ³ Data ³ 26/10/01 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³ Classifica ARRAY aJornadas de Acordo com Existencia de     ³±±
±±³          ³ Marcacoes nas respectivas Jornadas.                        ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³ classifica(dMarc,hMarc,aJornada,nPos,nMarc)                ³±±
±±³          ³ dMarc     -> Data da Marcacao                              ³±±
±±³          ³ hMarc     -> Hora da Marcacao                              ³±±
±±³          ³ aJornada  -> Array com a Estrutura:                        ³±±
±±³          ³              [1] Ordem do Dia                              ³±±
±±³          ³              [2] [1] Hora Inicial Jornada em No.Serial     ³±±
±±³          ³              [2] [2] Hora Final                            ³±±
±±³          ³              [2] [3] Tipo de Entrada: 1e/2e/3e...          ³±±
±±³          ³              [2] [4] Ausencia/Presenca: A/P ou A1e/P1e...  ³±±
±±³          ³              [3] Total de Horas da Jornada                 ³±±
±±³          ³ nPos      -> Posicao da Jornada Lida                       ³±±
±±³          ³ nMarc     -> Numero da Marcacao da Ordem                   ³±±
±±³          ³ Retorna   -> aJornada[2][4] com A-Ausencia/P-Presenca      ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ Ponr030                                                    ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/

static function classifica(dMarc,hMarc,aJornada,nPos,nMarc)
	Local nSerMarc	:=0
	Local nW     	:=0
	Local nFim 		:=0

	//-- Obtem o numero de horas/minutos da Marcacao
	nSerMarc := 0
	nSerMarc := NoRound(fDHtoNS(dMarc,hMarc))
	//-- Corre todas as Jornadas do Dia
	nW 	:= 0     
	nFim:=Len(aJornada[nPos,2])
	For nW := 1 To nFim
		//-- Se o Total de Horas da Tabela Padrao for Nulo ou ,seja, nao foram definidos
		//-- horarios e o func. teve marcacoes consideramos como todas as jornadas trabalhadas
		//-- para considera-lo presente no dia.
		//-- Idem Se Nao Verificamos Jornadas e se o funcionario teve marcacoes
		//-- embora elas nao estejam compreendidas pelos horarios da tab.padrao

		If Empty(aJornada[nPos,3]) .OR. lNaoVerifJrn
			aJornada[nPos,2,nW,4]:='P'  //Presente na Jornada
		Endif

		nIniJrn  := aJornada[nPos,2,nW,1] //Limite Inferior da Jornada
		nFimJrn  := aJornada[nPos,2,nW,2] //Limite Superior da Jornada

		//-- Se a Marcacao For Inferior ao Limite Superior da Jornada 
		//-- OU
		//-- A Marcacao eh igual ao limite Superior da Jornada (saida) e 
		//-----Nao eh a 1a.Marcacao do Dia(ou seja o func. nao chegou na saida da jornada),
		//-- Entao o funcionario esteve presente na jornada
		If  nSerMarc < nFimJrn   .OR.;
		(nSerMarc = nFimJrn .AND. nMarc>1)        
			//-- Funcionario Presente na Jornada
			If Empty(aJornada[nPos,2,nW,4])
				aJornada[nPos,2,nW,4]:='P'+aJornada[nPos,2,nW,3]  //Presente na Jornada
			Endif
			Exit
		Else
			//--Se a Marcacao for Maior que o Limite Superior da Jornada
			//--E se nao houve outra marcacao inferior 
			//--Funcionario Ausente na Jornada 
			If Empty(aJornada[nPos,2,nW,4])
				aJornada[nPos,2,nW,4]:='A'+aJornada[nPos,2,nW,3]  //Ausente na Jornada
			Endif
		Endif                          

	Next nW
Return Nil


/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡„o    ³Jornadas  ³ Autor ³ Mauricio MR           ³ Data ³ 26/10/01 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³ Cria ARRAY aJornadas a partir das Marcacoes de Entrada     ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³ Jornadas(cTipo, dDataInf, LimInf,dDataSup,LimSuper)        ³±±
±±³          ³ cTipo     -> Tipo da Entrada : 1e/2e/3e...                 ³±±
±±³          ³ dDataInf  -> Data da Jornada Lim Inf                       ³±±
±±³          ³ LimInf    -> Hora Inicial da Jornada                       ³±±
±±³          ³ dDataSup  -> Data da Jornada Lim Sup                       ³±±
±±³          ³ LimSuper  -> Hora Final da Jornada                         ³±±
±±³          ³ Retorna   -> aRet Array aJornada                           ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ Ponr030                                                    ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/


static function Jornadas(cTipo,dDataInf,LimInf,dDataSup,LimSuper)
	Local aRet:={}


	If Substr(cTipo,2,1)='E'

		aret:={NoRound(fDhToNs(dDataInf,LimInf))	,;	//Limite Inferior da Jornada em Serial
		NoRound(fDhToNs(dDataSup,LimSuper))	,;	//Limite Superior da Jornada em Serial
		cTipo		   						,;	//Jornada com Inicio na 1e/2e/...
		{}}                	 					//Reservado para Conter Ocorrencias
	Endif

Return aRet


/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡„o    ³GetCracha ³ Autor ³ Mauricio MR           ³ Data ³ 11/12/01 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³ Obtem o Cracha do funcionario em determinada data          ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³ GetCracha(dData)                                           ³±±
±±³          ³ Retorna   -> cCracha do Dia                                ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ Ponr030                                                    ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/


Static Function GetCracha(dData,aProvis,cCracha,cMat)

	PUBLIC  cCracha	:=SRA->RA_CRACHA 
	PUBLIC  cMat	:=SRA->RA_MAT

	nPos:=Ascan(aProvis,{|x| x[1]<=dData .AND. x[2]>=dData .And. x[4]==cMat})
	If nPos>0
		cCracha:=aProvis[nPos,3]
	Endif

Return cCracha


/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡„o    ³LoadCracha³ Autor ³ Mauricio MR           ³ Data ³ 11/12/01 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³ Carrega Crachas da Filial(Exclusivo) ou Todos(Compartilhado³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³ LoadCracha(@aCracha,cFil)                                  ³±±
±±³          ³ Retorna   -> aCracha                                       ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ Ponr030                                                    ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/


Static Function LoadCracha(aCracha,cFil)
	Local aArea:=GetArea()
	Local aAreaSPE:=SPE->(GetArea())
	Local cRefDE:=Dtos(dRefDE),cRefATE:=Dtos(dRefATE),cdIni,cdFim
	PUBLIC  cFil := fFilFunc("SPE") 

	SPE->(dbsetorder(1))
	SPE->(Dbseek(cFil))

	//-- Carrega crachas da filial (se Exclusivo) ou Todos (caso contrario)
	While !SPE->(Eof()) .AND. SPE->PE_FILIAL == cFil                          
		cdIni:=Dtos(SPE->PE_DATAINI)
		cdFim:=Dtos(SPE->PE_DATAFIM)
		//-- Somente Considera Intervalos que compreende o Periodo Solicitado
		If (cRefDE  >= cdIni   .AND. cRefDE  <= cdFim   ) .OR.;
		(cRefATE >= cdIni   .AND. cRefATE <= cdFim   ) .OR. ;
		(cdIni   >= cRefDE  .AND. cdIni   <= cRefATE )  .OR.;
		(cdFim   >= cRefDE  .AND. cdFim   <= cRefATE )         
			aAdd(aCracha,{SPE->PE_DATAINI,SPE->PE_DATAFIM,SPE->PE_MATPROV,SPE->PE_MAT})
		Endif
		SPE->(dbSkip())
	Enddo

	RestArea(aAreaSPE)
	RestArea(aArea)

Return aCracha



Static Function fImpDescr( datax )     
	LocaL ret := ''
	Local onde := ASCAN( aDescrep, {|reg| reg[1] == datax } )
	if onde <> 0 
		ret := StrTran(Transform(aDescrep[onde,DESC_EXTRA],'@e 9999.99'),',',':' )+'  | '+ StrTran(Transform(aDescrep[onde,DESC_ATRASO],'@e 9999.99'),',',':')
		//ret :=   '9999.99'+'  | '+'9999.99'
	else
		ret :=   '       '+'  | '+'       '
	endif
Return ret





/*BEGINDOC
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³Alteracoes Realizadas³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
---------------------------------------------------------------------------------------------------
Data        Autor   Descricao
---------------------------------------------------------------------------------------------------
21-04-2006  Raul    Criado parametro 23 para escolha da situacao do horario do funcionario no dia
1-Qualquer situacao  2-Sem atrasos ou hora extra  3-Somente com atrasos ou 
hora extra.

05-05-2006  Raul    Leitura dos apontamentos para verificar quais correspondem ao parametro definido
acima. Tabela SPC

Solicitacoes da Jacque

* Mudar titulo para: Discrepâncias do ponto  
* Ativar impressão de parâmetros da folha de pagamento

* Ordens de CC+Nome e Matricula
* Colocar total de Hora extra e Total Atraso
* Tirar a informação do turno de trabalho  
* Totalizar horas extras e atrasos
* Tirar pametros presentes e ausentes


ENDDOC */
