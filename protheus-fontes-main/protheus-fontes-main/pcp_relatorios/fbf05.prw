#INCLUDE "rwmake.ch"

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  FBF05      º Autor ³ Flávio B. Flôres   º Data ³  10/06/08   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDescricao ³ Relatório de produção de caixas                            º±±
±±º          ³                                                            º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ Sigapcp,Sigaoms                                            º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/

User Function FBF05()

	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Declaracao de Variaveis                                             ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	Local cDesc1         	:= "Este relatório imprime o resultado de produção de   "
	Local cDesc2         	:= "caixas de produto acabado mediante os parametros    "
	Local cDesc3         	:= "apontados pelo usuário."
	Local cPict       		:= ""
	Local titulo       		:= "Relatório de Produção De Caixas"
	Local nLin     			:= 80
	Local Cabec1       		:= "Produto    Nome Prod.                             Qt.Caixa       P.Liq.            P.Bruto      "
	Local Cabec2       		:= ""
	Local imprime      		:= .T.
	Local aOrd 	   			:= {}
	Private lEnd         	:= .F.
	Private lAbortPrint  	:= .F.
	Private CbTxt        	:= ""
	Private limite          := 80
	Private tamanho         := "M"
	Private nomeprog        := "FBF05" // Coloque aqui o nome do programa para impressao no cabecalho
	Private nTipo           := 18
	Private aReturn         := { "Zebrado", 1, "Administracao", 2, 2, 1, "", 1}
	Private nLastKey        := 0
	Private cPerg       	   := "FBF05"
	Private cbtxt      		:= Space(10)
	Private cbcont     		:= 00
	Private CONTFL     		:= 01
	Private m_pag      		:= 01
	Private wnrel      		:= "FBF05" // Coloque aqui o nome do arquivo usado para impressao em disco
	Private cString	 		:= "SZ8"
	Private cont				:=0

	dbSelectArea("SZ8")
	SZ8->(dbSetOrder(4))

	pergunte(cPerg,.T.)

	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Monta a interface padrao com o usuario...                           ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ

	wnrel := SetPrint(cString,NomeProg,cPerg,@titulo,cDesc1,cDesc2,cDesc3,.T.,aOrd,.T.,Tamanho,,.T.)

	If nLastKey == 27
		Return
	Endif

	SetDefault(aReturn,cString)

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
	Local _pcod		:= replicate("0",6)
	Local _marc		:=0
	Local _qcaix	:=0
	Local _pliq		:=0
	Local _pbruto	:=0
	Local _caixan	:=0
	Local _esc 		:="f"
	Local _variable :=0
	Local _contador :=0
	Local _pdesc    :="                                        "
	Local _ptf		:=" "

	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ SETREGUA -> Indica quantos registros serao processados para a regua ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ

	SetRegua(SZ8->(RecCount()))
	SZ8->(dbsetorder(4))              //Marcação do índice em que se vai trabalhar
	SZ8->(Dbseek(xfilial('SZ8')+alltrim(mv_par03),.t.))

	While SZ8->(!EOF()) .and. SZ8->Z8_COD <= alltrim(mv_par04)

		incRegua()

		// Caixa deve estar no intervalo das datas mv_par01 a mv_par02
		if SZ8->Z8_DATA < mv_par01 .or. SZ8->Z8_DATA > mv_par02
			SZ8->(dbskip())
			loop
		endif

		if !empty(SZ8->Z8_HORAE) .or. !empty(SZ8->Z8_DATAE)
			SZ8->(dbskip())
			loop
		endif

		_grupo := FBuscaCPO('SB1',1,xfilial('SB1')+SZ8->Z8_COD,'B1_GRUPO')

		if _grupo < mv_par05 .or. _grupo > mv_par06

			SZ8->(dbskip())
			loop
		endif

		if _marc = 0
			_pcod 	:= alltrim(SZ8->Z8_COD)
			_pdesc	:= substr(fBuscaCPO('SB1',1,xfilial('SB1')+SZ8->Z8_COD,'B1_DESC'),0,40 )
			_qcaix	:=1
			_pliq	:=SZ8->Z8_PESO
			_pbruto	:=SZ8->Z8_PESOBR
			_cont	:=1
			_ptf	:= SZ8->Z8_TF
			_esc :="t"

		endif
		// Soma as caixas para apresentar em uma linha só
		if _pcod = alltrim(SZ8->Z8_COD) .and. _esc = "f"       // o "esc" é para delimitar a primeira marcação
			_qcaix	:= _qcaix+1
			_pliq		:=	_pliq + SZ8->Z8_PESO
			_pbruto	:= 	_pbruto + SZ8->Z8_PESOBR
			_pdesc	:= substr(fBuscaCPO('SB1',1,xfilial('SB1')+SZ8->Z8_COD,'B1_DESC'),0,40 )
			_ptf		:= SZ8->Z8_TF
		endif
		_esc:="f"


		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³ Verifica o cancelamento pelo usuario...                             ³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ

		If lAbortPrint
			@nLin,00 PSAY "*** CANCELADO PELO OPERADOR ***"
			Exit
		Endif

		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³ Impressao do cabecalho do relatorio. . .                            ³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ

		If nLin > 55 // Salto de Página. Neste caso o formulario tem 55 linhas...
			Cabec(Titulo,Cabec1,Cabec2,NomeProg,Tamanho,nTipo)
			nLin := 8
		Endif

		if _pcod != alltrim(SZ8->Z8_COD)
			@nlin,01  psay _pcod       //6 caracteres cod do produto
			@nlin,11  psay _pdesc
			@nlin,55  psay _qcaix
			@nlin,60  psay _pliq		picture '@E 999,999.99'	//Peso Liquido
			@nlin,80  psay _pbruto  	picture '@E 999,999.99'	//Peso Bruto
			//	@nlin,97  psay _ptf
			_pcod 	:= alltrim(SZ8->Z8_COD)
			_qcaix	:=1
			_pliq		:=SZ8->Z8_PESO
			_pbruto	:=SZ8->Z8_PESOBR
			//@nlin++
			nLin++ // Avanca a linha de impressao
			//variable := 2
		endif
		_marc++
		dbSkip() // Avanca o ponteiro do registro no arquivo

	EndDo

	//**********Impressão do último produto************************
	@nlin,01  psay _pcod       //6 caracteres cod do produto
	@nlin,11  psay _pdesc
	@nlin,55  psay _qcaix
	@nlin,60  psay _pliq			picture '@E 999,999.99'	//Peso Liquido
	@nlin,80  psay _pbruto  	picture '@E 999,999.99'	//Peso Bruto
	//	@nlin,97  psay _ptf
	//@nlin++
	nLin++ // Avanca a linha de impressao

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
