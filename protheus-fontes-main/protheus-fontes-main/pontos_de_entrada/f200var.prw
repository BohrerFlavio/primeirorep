#INCLUDE "rwmake.ch"

User Function F200VAR()

	/*
	ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
	±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
	±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
	±±³Programa  ³ F200VAR  ³ Autor ³    Jeferson Rech      ³ Data ³ Mai/2005 ³±±
	±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
	±±³Descricao ³ Tratamento Recepcao Bancaria CNAB - Compatibiliza Baixas   ³±±
	±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
	±±³Retorno   ³                                                            ³±±
	±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
	±±³Utilizacao³ Especifico para Clientes Microsiga                         ³±±
	±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
	±±³   Data   ³ Programador   ³Manutencao Efetuada                         ³±±
	±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
	±±³          ³               ³                                            ³±±
	±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
	±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
	ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
	*/
	
	// aValores[01] - Numero do titulo
	// aValores[02] - Data da baixa
	// aValores[03] - Tipo do titulo
	// aValores[04] - Nosso numero
	// aValores[05] - Valor da despesa
	// aValores[06] - Valor do desconto
	// aValores[07] - Valor do abatimento
	// aValores[08] - Valor recebido
	// aValores[09] - Valor dos juros
	// aValores[10] - Valor da multa
	// aValores[11] - Valor de outras depesas
	// aValores[12] - Valor do credito
	// aValores[13] - Data do credito
	// aValores[14] - Ocorrencia
	// aValores[15] - Motivo da baixa
	// aValores[16] - Linha Inteira
	// aValores[17] - Data de vencimento

	Local _aArea := GetArea()
	Local _lRet  := .T.

	cNumTit   := ParamIxb[01][01]
	dBaixa    := ParamIxb[01][02]
	cTipo     := ParamIxb[01][03]
	cNsNum    := ParamIxb[01][04]
	nDespes   := ParamIxb[01][05]
	nDescont  := ParamIxb[01][06]
	nAbatim   := ParamIxb[01][07]
	nValrec   := ParamIxb[01][08]
	nJuros    := ParamIxb[01][09]
	nMulta    := ParamIxb[01][10]
	nOutrDesp := ParamIxb[01][11]
	nValCc    := ParamIxb[01][12]
	dDataCred := ParamIxb[01][13]
	cOcorr    := ParamIxb[01][14]
	cMotBan   := ParamIxb[01][15]
	dDtVc     := ParamIxb[01][17]

	DbSelectArea("SE1")
	DbSetOrder(1)
	DbSeek(xFilial("SE1")+cNumTit)
	
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Acertos de Compatibilização - Tratamento banco a banco      ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	If cBanco == "041"      // Banco Banrisul
		/*
		If nDescont > 0 .Or. nAbatim > 0
			_nDescCli := nDescont
			_nAbatCli := nAbatim

			@ 200, 100 TO 350, 550 DIALOG oDlg1 TITLE "Desc./Abat. Retorno Cobrança"
			@ 010, 005 SAY "Vlr Desconto  "
			@ 025, 005 SAY "Vlr Abatimento"
			@ 010, 070 GET _nDescCli Picture "@E 999,999,999.99" When .T. SIZE 060, 11
			@ 025, 070 GET _nAbatCli Picture "@E 999,999,999.99" When .T. SIZE 060, 11

			@ 050, 100 BUTTON "Consulta" Size 040, 012 ACTION Fc040Con()
			@ 050, 150 BUTTON "Confirma" Size 040, 012 ACTION (oDlg1:End ())
			ACTIVATE DIALOG oDlg1 CENTERED

			nDescont := _nDescCli + _nAbatCli
			nAbatim  := 0
		Endif
		*/
	Endif
	
	// Iguala a Data da Baixa do Arquivo com a Data Base
	dbaixa := dDataBase

	RestArea(_aArea)

Return(_lRet)

