#INCLUDE "rwmake.ch"

User Function ML_FESA1()

	/*/
	ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
	±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
	±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
	±±³Programa  ³ ML_FESA1 ³ Autor ³ Evandro Mugnol        ³ Data ³ 20.04.04 ³±±
	±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
	±±³Descricao ³ Apura total do imposto Fesa a partir na nota de entrada e  ³±±
	±±³          ³ gera titulo conforme solicitacao do usuario                ³±±
	±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
	±±³Uso       ³ Especifico para Frigorifico Silva                          ³±±
	±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
	±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
	ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
	/*/

	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Declaracao de Variaveis                                             ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	cString  := "SF1"
	titulo   := "Apuracao do FESA"
	cDesc1   := "Este programa tem como objetivo imprimir relatorio "
	cDesc2   := "de apuracao do imposto do fesa e gerar o titulo no "
	cDesc3   := "contas a pagar conforme solicitacao do usuario.    "
	tamanho  := "P"
	limite   := 80
	aReturn  := { "Zebrado", 1,"Administracao", 1, 2, 1, "", 1 }
	nomeprog := "MLFESA"
	aLinha   := { }
	nLastKey := 0
	cPerg    := "MLFESA"
	nTipo    := 15
	nLin     := 80
	Cabec1   := "DATA NFE  NUMERO/SER  F O R N E C E D O R                              VLR FESA"
	Cabec2   := ""
	//           XX.XX.XX  XXXXXX XXX  XXXXXX-XX X----------------------------------X  XX.XXX,XX

	ValidPerg()
	Pergunte(cPerg,.F.)

	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Variaveis utilizadas para parametros                         ³
	//³ mv_par01          // Da Data                                 ³
	//³ mv_par02          // Ate a Data                              ³
	//³ mv_par03          // Gera Contas a Pagar                     ³
	//³ mv_par04          // Prefixo (FESA)                          ³
	//³ mv_par05          // Numero (FESA)                           ³
	//³ mv_par06          // Vencimento (FESA)                       ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ

	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Envia controle para a funcao SETPRINT                        ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	wnrel := "MLFESA"
	wnrel := SetPrint(cString,wnrel,cPerg,@titulo,cDesc1,cDesc2,cDesc3,.F.,,,tamanho)

	If nLastKey == 27
		Return
	Endif
	SetDefault(aReturn,cString)
	If nLastKey == 27
		Return
	Endif

	titulo := "Valor FESA de "+Dtoc(mv_par01)+" ate "+Dtoc(mv_par02)
	nTipo  := If(aReturn[4]==1,15,18)

	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Variaveis utilizadas para Impressao do Cabecalho e Rodape    ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	cbtxt  := ""
	cbcont := 0
	li     := 80
	m_pag  := 1

	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Inicio do Processamento                                      ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	RptStatus({|| Ml_Fesa(Cabec1,Cabec2,Titulo,nLin) },Titulo)
Return

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºFuncao    ³ ML_FESA  º Autor ³ Evandro Mugnol     º Data ³  12.06.03   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDescricao ³ Funcao auxiliar chamada pela RPTSTATUS.                    º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/

Static Function Ml_Fesa(Cabec1,Cabec2,Titulo,nLin)

	DbSelectArea("SF1")
	DbSetOrder(6)
	DbSeek(xFilial("SF1")+Dtos(MV_PAR01),.T.)
	SetRegua(RecCount())
	_nTotFesa := 0
	While !Eof() .And. SF1->F1_FILIAL == xFilial("SF1") .And. SF1->F1_EMISSAO <= MV_PAR02
		If SF1->F1_EMISSAO < MV_PAR01 .Or. SF1->F1_EMISSAO > MV_PAR02
			DbSelectArea("SF1")
			DbSkip()
			Loop
		Endif
		If SF1->F1_VALIMP1 == 0.00
			DbSelectArea("SF1")
			DbSkip()
			Loop
		Endif

		IncRegua()
		_dEmissao := SF1->F1_EMISSAO
		_cNumero  := SF1->F1_DOC
		_cSerie   := SF1->F1_SERIE
		_cFornece := SF1->F1_FORNECE
		_cLoja    := SF1->F1_LOJA
		_nValFesa := SF1->F1_VALIMP1

		DbSelectArea("SA2")
		DbSeek(xFilial("SA2")+_cFornece+_cLoja)
		If Found()
			_cNomeFor := Left(SA2->A2_NOME,36)
		Else
			_cNomeFor := Replicate("?",36)
		Endif

		If li > 60
			cabec(titulo,cabec1,cabec2,nomeprog,tamanho,nTipo)
		Endif
		@ li, 000 PSAY _dEmissao
		@ li, 010 PSAY _cNumero
		@ li, 017 PSAY _cSerie
		@ li, 022 PSAY _cFornece+"-"+_cLoja
		@ li, 032 PSAY _cNomeFor
		@ li, 070 PSAY _nValFesa Picture "@E 99,999.99"
		_nTotFesa := _nTotFesa + _nValFesa
		li := li + 1
		DbSelectArea("SF1")
		DbSkip()
	Enddo

	If li > 60
		cabec(titulo,cabec1,cabec2,nomeprog,tamanho,nTipo)
	Endif
	li:=li+1
	@ li, 050 PSAY "T O T A L ==>"
	@ li, 069 PSAY _nTotFesa Picture "@E 999,999.99"

	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Gera contas a pagar baseado nos parametros                   ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	_Flag := 0
	If mv_par03 == 1
		DbSelectArea("SE2")
		DbSetOrder(1)
		DbSeek(xFilial("SE2")+MV_PAR04+MV_PAR05+" TX 00129201")
		If Found()
			Help(" ",1,"SE2TXFESA",,"TITULO NAO GERADO. Tipo TX ja existe"+chr(13)+"no contas a pagar.",3,1)
			_Flag := 1
		Endif
		If Empty(MV_PAR06) .Or. MV_PAR06 < dDataBase
			Help(" ",1,"SE2VCFESA",,"TITULO NAO GERADO. Data do vencimento"+chr(13)+"invalida ou menor que database do sistema.",3,1)
			_Flag := 1
		Endif
		If _nTotFesa <= 0
			Help(" ",1,"SE2VLFESA",,"TITULO NAO GERADO. Nao foi apurado"+chr(13)+"valor do FESA neste periodo.",3,1)
			_Flag := 1
		Endif

		If _Flag == 0
			If MsgYesNo("Titulo sera gerado com data de emissao de "+dtoc(ddatabase)+". Confirma geracao?")
				DbSelectArea("SA2")
				DbSeek(xFilial("SA2")+"00129201")
				If Found()
					_cNatur := SA2->A2_NATUREZ
					_cReduz := SA2->A2_NREDUZ
				Else
					_cNatur := ""
					_cReduz := "FESA"
				Endif

				DbSelectArea("SE2")        // Cria o titulo de imposto do FESA
				RecLock("SE2",.T.)
				SE2->E2_FILIAL  := xFilial("SE2")
				SE2->E2_PREFIXO := MV_PAR04
				SE2->E2_NUM     := MV_PAR05
				SE2->E2_PARCELA := " "
				SE2->E2_TIPO    := "TX "
				SE2->E2_NATUREZ := _cNatur
				SE2->E2_FORNECE := "001292"
				SE2->E2_LOJA    := "01"
				SE2->E2_NOMFOR  := _cReduz
				SE2->E2_EMISSAO := dDataBase
				SE2->E2_VENCTO  := MV_PAR06
				SE2->E2_VENCREA := DataValida(MV_PAR06,.T.)
				SE2->E2_VALOR   := _nTotFesa * 2
				SE2->E2_EMIS1   := dDataBase
				SE2->E2_LA      := "S"
				SE2->E2_SALDO   := _nTotFesa * 2
				SE2->E2_VENCORI := MV_PAR06
				SE2->E2_MOEDA   := 1
				SE2->E2_RATEIO  := "N"
				SE2->E2_VLCRUZ  := _nTotFesa * 2
				SE2->E2_OCORREN := "01"
				SE2->E2_FLUXO   := "S"
				SE2->E2_ORIGEM  := "FINA050"
				SE2->E2_DESDOBR := "N"
				SE2->E2_MULTNAT := "2"
				SE2->E2_PROJPMS := "2"
				SE2->E2_DIRF    := "2"
				SE2->E2_MODSPB  := "1"
				MsUnlock()
			Endif
		Endif
	Endif

	If ( Li != 80 )
		Roda(cbcont,cbtxt,tamanho)
	EndIf

	Set Device To Screen
	If aReturn[5]==1
		dbCommitAll()
		SET PRINTER TO
		OurSpool(wnrel)
	Endif

	MS_FLUSH()

Return


//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Cria Perguntas no SX1                                        ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
Static Function ValidPerg()
	Local i
	Local j
	_aAlias := GetArea()
	aPerg   := {}
	//..             Grupo    Ordem    Perguntas                 Variavel  Tipo Tam Dec  Variavel  GSC   F3    Def01 Def02 Def03 Def04 Def05
	AADD( aPerg , { cPerg, "01", "Da Data                      ?","","", "mv_ch1", "D",  8 , 0, 0, "G", "", "mv_par01", "", "", "", "", "", "", "", "", "", "", "", "", "", "", "", "", "", "", "", "", "", "", "",""})
	AADD( aPerg , { cPerg, "02", "Ate a Data                   ?","","", "mv_ch2", "D",  8 , 0, 0, "G", "", "mv_par02", "", "", "", "", "", "", "", "", "", "", "", "", "", "", "", "", "", "", "", "", "", "", "",""})
	AADD( aPerg , { cPerg, "03", "Gera Contas a Pagar          ?","","", "mv_ch3", "N",  1 , 0, 0, "C", "", "mv_par03", "Sim", "", "", "", "", "Nao", "", "", "", "", "", "", "", "", "", "", "", "", "", "", "", "", "",""})
	AADD( aPerg , { cPerg, "04", "Prefixo (FESA)               ?","","", "mv_ch4", "C",  3 , 0, 0, "G", "", "mv_par04", "", "", "", "", "", "", "", "", "", "", "", "", "", "", "", "", "", "", "", "", "", "", "",""})
	AADD( aPerg , { cPerg, "05", "Numero (FESA)                ?","","", "mv_ch5", "C",  9 , 0, 0, "G", "", "mv_par05", "", "", "", "", "", "", "", "", "", "", "", "", "", "", "", "", "", "", "", "", "", "", "",""})
	AADD( aPerg , { cPerg, "06", "Vencimento (FESA)            ?","","", "mv_ch6", "D",  8 , 0, 0, "G", "", "mv_par06", "", "", "", "", "", "", "", "", "", "", "", "", "", "", "", "", "", "", "", "", "", "", "",""})

	DbSelectArea("SX1")
	DbSetOrder(1)
	For i:=1 to Len(aPerg)
		RecLock("SX1",!DbSeek(cPerg + aPerg[i, 2]))
		For j := 1 to (FCount())
			If j <= Len(aPerg[i]) .and. !(left(alltrim(FieldName(j)),6) $ 'X1_PRE/X1_CNT')
				FieldPut(j, aPerg[i, j])
			Endif
		Next
		MsUnlock()
	Next
	RestArea(_aAlias)
Return
