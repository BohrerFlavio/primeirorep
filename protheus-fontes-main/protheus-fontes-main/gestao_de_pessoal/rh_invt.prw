#INCLUDE "rwmake.ch"        // incluido pelo assistente de conversao do AP5 IDE em 04/05/01
#IFNDEF WINDOWS
#DEFINE PSAY SAY
#ENDIF

User Function RH_invt()        // incluido pelo assistente de conversao do AP5 IDE em 04/05/01

	/*/
	ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
	±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
	±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
	±±³Programa  ³ ML_INVT  ³ Autor ³     Jeferson Rech     ³ Data ³ Mai/2001 ³±±
	±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
	±±³Descricao ³ Declaracao de Deslocamento - Vale Transporte               ³±±
	±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
	±±³Retorno   ³                                                            ³±±
	±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
	±±³Utilizacao³                                                            ³±±
	±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
	±±³   Data   ³ Programador   ³Manutencao Efetuada                         ³±±
	±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
	±±³          ³               ³                                            ³±±
	±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
	±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
	ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
	/*/
	#IFNDEF WINDOWS
	// Movido para o inicio do arquivo pelo assistente de conversao do AP5 IDE em 04/05/01 ==>    #DEFINE PSAY SAY
	#ENDIF

	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Variaveis utizadas para parametros                           ³
	//³ mv_par01     // Matricula De                                 ³
	//³ mv_par02     // Matricula Ate                                ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ

	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Variaveis obrigatorias dos programas de relatorio            ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	cString := "SRA"
	cDesc1  := "Este programa tem como objetivo, imprimir relatorio de"
	cDesc2  := "Declaracao de Deslocamento - Vale Transporte."
	cDesc3  := ""
	tamanho := "P"
	aReturn := { "Zebrado", 1,"Administracao", 1, 2, 1, "",1 }
	aLinha  := {}
	nLastKey:= 0
	cPerg   := "RH_INV"
	titulo  := "Declaracao de Deslocamento - Vale Transporte"
	wnrel   := "RH_INVT"
	nTipo   := 0

	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Perguntas no arquivo SX1                                     ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	ValidPerg()
	Pergunte(cPerg,.F.)

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
	RptStatus({|| RptDetail()})// Substituido pelo assistente de conversao do AP5 IDE em 04/05/01 ==>    RptStatus({|| Execute(RptDetail)})
Return
// Substituido pelo assistente de conversao do AP5 IDE em 04/05/01 ==>    Function RptDetail
Static Function RptDetail()
	#ENDIF

	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Inicializa regua de impressao                             ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	SetRegua(LastRec())

	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Inicializa os codigos de caracter Comprimido/Normal da impressora ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	nTipo := IIF(aReturn[4]==1,15,18)
	li    := 0
	m_pag := 1

	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Cria o cabecalho.                                        ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	cabec1 :=""
	cabec2 :=""
	*****      XXXX    XXXXXXXXX X-------------------------------------X X,XXX,XXX.XX   XXX.XX
	*****               1         2         3         4         5         6         7         8         9         0         1         2         3
	*****     0123456789012345678901234567890123456789012345678901234567890123456789012345678901234567890123456789012345678901234567890123456789012

	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Verificando Dados                                            ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	DbSelectArea("SRA")
	DbSetOrder(1)
	DbSeek(xFilial()+mv_par01,.T.)
	Do While !Eof() .And. xFilial()==SRA->RA_FILIAL .And. SRA->RA_MAT<=mv_par02
		IncRegua()              // Termometro de Impressao
		li := 7
		_xMAT      := SRA->RA_MAT
		_xNOME     := SRA->RA_NOME
		_xENDEREC  := SRA->RA_ENDEREC
		_xBAIRRO   := SRA->RA_BAIRRO
		_xMUNICIP  := SRA->RA_MUNICIP
		_xESTADO   := SRA->RA_ESTADO
		_xTIPOPGT  := SRA->RA_CATFUNC
		_xSALARIO  := SRA->RA_SALARIO
		_xSERCP    := SRA->RA_SERCP
		_xCTDEPSA  := SRA->RA_CTDEPSA

		If _xTIPOPGT == "H"
			_xTIPO := "hora;"
		Else
			_xTIPO := "mes;"
		Endif

		@ li, 020 PSAY "DECLARACAO DE DESLOCAMENTO - VALE TRANSPORTE"
		li:=li+1
		@ li, 020 PSAY Replicate("-",44)
		li:=li+4
		@ li, 001 PSAY "Eu, "+_xNOME+" , CTPS: "+_xCTDEPSA+" - "+_xSERCP+"  , residente a"
		li:=li+1
		@ li, 001 PSAY _xENDEREC+Space(5)+", Bairro "+_xBAIRRO+Space(5)+", na cidade de"
		li:=li+1
		@ li, 001 PSAY _xMUNICIP+Space(5)+" - "+_xESTADO+" , matricula "+_xMAT+Space(5)+" , com o salario base de"
		li:=li+1
		@ li, 001 PSAY "R$"
		@ li, 004 PSAY _xSALARIO   Picture "@E 9,999,999.99"
		@ li, 017 PSAY "por "+_xTIPO
		li:=li+2
		@ li, 001 PSAY "DECLARACAO DE RESPONSABILIDADE"
		li:=li+1
		@ li, 001 PSAY Replicate("-",30)
		li:=li+2
		@ li, 001 PSAY "Necessito de "+Replicate("_",14)+" Fichas, diariamente, no servico de transporte para"
		li:=li+1
		@ li, 001 PSAY "o seguinte deslocamento:"
		li:=li+2
		@ li, 001 PSAY Replicate("-",78)
		li:=li+1
		@ li, 001 PSAY "|         Sentido         |   Tarifa  |         Sentido          |   Tarifa  |"
		li:=li+1
		@ li, 001 PSAY "|   Casa-Empresa-Linha    |           |    Empresa-Casa-Linha    |           |"
		li:=li+1
		@ li, 001 PSAY "|"+Replicate("-",76)+"|"
		li:=li+1
		@ li, 001 PSAY "|                         |           |                          |           |"
		li:=li+1
		@ li, 001 PSAY "|"+Replicate("-",76)+"|"
		li:=li+1
		@ li, 001 PSAY "|                         |           |                          |           |"
		li:=li+1
		@ li, 001 PSAY "|"+Replicate("-",76)+"|"
		li:=li+1
		@ li, 001 PSAY "|                         |           |                          |           |"
		li:=li+1
		@ li, 001 PSAY "|"+Replicate("-",76)+"|"
		li:=li+1
		@ li, 001 PSAY "|                         |           |                          |           |"
		li:=li+1
		@ li, 001 PSAY "|"+Replicate("-",76)+"|"
		li:=li+1
		@ li, 001 PSAY "|                          |          |                          |           |"
		li:=li+1
		@ li, 001 PSAY Replicate("-",78)
		li:=li+2
		@ li, 001 PSAY "AUTORIZACAO DE DESCONTO"
		li:=li+1
		@ li, 001 PSAY Replicate("-",23)
		li:=li+2
		@ li, 001 PSAY "Autorizo o desconto de 6% (seis por cento) do meu Salario Base para participar"
		li:=li+1
		@ li, 001 PSAY "como beneficiario do Programa Vale Transporte, comprometendo-me  a  utilizacao"
		li:=li+1
		@ li, 001 PSAY "deste beneficio exclusivamente no meu deslocamento residencia-trabalho, sujei-"
		li:=li+1
		@ li, 001 PSAY "tando-me as penalidades previstas em lei."
		li:=li+3
		@ li, 040 PSAY Alltrim(SM0->M0_CIDCOB)+", "+LEFT(DTOC(DDataBase),2)+" de "+Alltrim(MesExtenso(Month(DDataBase)))+" de "+Str(Year(DDatabase),4)+"."
		li:=li+4
		@ li, 040 PSAY Replicate("_",38)
		li:=li+1
		@ li, 045 PSAY Left(_xNOME,30)
		li:=li+1
		@ li, 040 PSAY "Pela  Declaracao  de  Responsabilidade" 
		li:=li+1
		@ li, 040 PSAY "e pela Autorizacao de Desconto." 
		li:=li+1
		@ li, 001 PSAY ""
		li:=li+1
		DbSelectArea("SRA")
		DbSkip()
	Enddo

	SetPrc(0,0)

	Set Device To Screen

	If aReturn[5]==1
		Set Printer TO
		dbcommitAll()
		ourspool(wnrel)
	Endif

	MS_FLUSH() // Libera fila de relatorios em spool (Tipo Rede Netware)

// FIM

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Cria Perguntas no SX1                                        ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
// Substituido pelo assistente de conversao do AP5 IDE em 04/05/01 ==> Function ValidPerg
Static Function ValidPerg()
	Local i
	Local j
	cAlias := Alias()
	aRegs  := {}

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
