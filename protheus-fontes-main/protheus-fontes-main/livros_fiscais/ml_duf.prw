#INCLUDE "rwmake.ch"
#IFNDEF WINDOWS
#DEFINE PSAY SAY
#ENDIF

User Function Ml_duf()

	/*/
	ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
	±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
	±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
	±±³Programa  ³ ML_DUF   ³ Autor ³    Jeferson Rech      ³ Data ³ Mar/2003 ³±±
	±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
	±±³Descricao ³ Rel. Detalhamento Operacoes p/ UF                          ³±±
	±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
	±±³Retorno   ³                                                            ³±±
	±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
	±±³Utilizacao³ Especifico para LINPAC - Pisani                            ³±±
	±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
	±±³   Data   ³ Programador   ³Manutencao Efetuada                         ³±±
	±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
	±±³          ³               ³                                            ³±±
	±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
	±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
	ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
	/*/

	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Variaveis utilizadas para parametros                         ³
	//³ mv_par01     // Data Movto De                                ³
	//³ mv_par02     // Data Movto Ate                               ³
	//³ mv_par03     // Entr. / Saidas                               ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Variaveis obrigatorias dos programas de relatorio            ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	cString :="SF3"
	cDesc1  :="Este programa tem como objetivo, imprimir relatorio de"
	cDesc2  :="Detalhamento de Operacoes p/ UF."
	cDesc3  :=""
	tamanho :="M"
	aReturn :={ "Zebrado", 1,"Administracao", 2, 2, 1, "",1 }
	aLinha  :={ }
	nLastKey:=0
	cPerg   :="ML_DUF"
	titulo  :=""
	wnrel   :="ML_DUF"
	nTipo   :=0

	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Pergunta no SX1                                              ³
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

	RptStatus({|| RptDetail()})
Return
Static Function RptDetail()
	local oTable as object

	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Inicializa  regua de impressao                            ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	SetRegua(LastRec())

	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Inicializa os codigos de caracter Comprimido/Normal da impressora ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	nTipo := IIF(aReturn[4]==1,15,18)
	li    := 80
	m_pag := 1

	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Cria o cabecalho.                                        ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	cabec1 := "*UF          Valor Contabil   Base de Calculo           Isentas            Outras       Tributadas         Val. IPI  Valor Contabil*"
	cabec2 := "*                                                                                                                           (-) IPI*"
	*****       XXXX      X.XXX.XXX.XXX,XX    XXX.XXX.XXX,XX    XXX.XXX.XXX,XX    XXX.XXX.XXX,XX   XXX.XXX.XXX,XX   XXX.XXX.XXX,XX   XXX.XXX.XXX,XX
	*****                1         2         3         4         5         6         7         8         9         0         1         2         3
	*****      0123456789012345678901234567890123456789012345678901234567890123456789012345678901234567890123456789012345678901234567890123456789012
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Gera arquivo de Trabalho                                     ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	aCampos := {}
	aTam:=TamSX3("F3_ESTADO")
	AADD(aCampos,{"ESTADO"  ,"C",2,0})
	aTam:=TamSX3("F3_VALCONT")
	AADD(aCampos,{"VALCONT" ,"N",aTam[1],aTam[2]})
	aTam:=TamSX3("F3_BASEICM")
	AADD(aCampos,{"BASE"    ,"N",aTam[1],aTam[2]})
	aTam:=TamSX3("F3_ISENICM")
	AADD(aCampos,{"ISENTOS" ,"N",aTam[1],aTam[2]})
	aTam:=TamSX3("F3_OUTRICM")
	AADD(aCampos,{"OUTROS"  ,"N",aTam[1],aTam[2]})
	aTam:=TamSX3("F3_VALICM")
	AADD(aCampos,{"VALICM"  ,"N",aTam[1],aTam[2]})
	aTam:=TamSX3("F3_VALIPI")
	AADD(aCampos,{"IPI"     ,"N",aTam[1],aTam[2]})
	aTam:=TamSX3("F3_VALCONT")
	AADD(aCampos,{"CONTIPI" ,"N",aTam[1],aTam[2]})

	// ProcData 04/2023 - Chamada para fechar arquivo de trabalho
	oTable := FWTemporaryTable():New( /*cAlias*/, /*aFields*/)
	oTable:SetFields(aCampos)
	oTable:AddIndex("01", {"ESTADO"} )
	oTable:Create()
	cArqTra := oTable:GetAlias()
	
	//cArqTra := CriaTrab(aCampos)
	//DbUseArea( .T.,, cArqTra,cArqTra, .T. , .F. )

	cArqTra1:=Substr(cArqTra,1,7)+"1"

	DbSelectArea(cArqTra)
	//Index on ESTADO to &cArqTra1

	titulo := "Detalhamento p/ UF "+IIF(mv_par03==1,"Entradas","Saidas")
	titulo += " - Periodo De "+Dtoc(mv_par01)+ " Ate "+Dtoc(mv_par02)

	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Verifica Dados                                               ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	DbSelectArea("SF3")
	DbSetOrder(1)
	DbSeek(xFilial()+Dtos(mv_par01),.T.)
	Do While !Eof() .and. xFilial()==SF3->F3_FILIAL .and. Dtos(SF3->F3_ENTRADA)<=Dtos(mv_par02)
		IncRegua()              // Termometro de Impressao
		If !EMPTY(SF3->F3_DTCANC)
			DbSelectArea("SF3")
			DbSkip()
			Loop
		EndIf
		If mv_par03==2 .AND. SF3->F3_CFO<"500"
			DbSelectArea("SF3")
			DbSkip()
			Loop
		EndIf
		If mv_par03==1 .AND. SF3->F3_CFO>"499"
			DbSelectArea("SF3")
			DbSkip()
			Loop
		EndIf
		If SF3->F3_ENTRADA < mv_par01 .Or. SF3->F3_ENTRADA > mv_par02
			DbSelectArea("SF3")
			DbSkip()
			Loop
		EndIf

		_wEST     :=SF3->F3_ESTADO
		_wVALCONT :=SF3->F3_VALCONT
		_wBASE    :=SF3->F3_BASEICM
		_wISENTOS :=SF3->F3_ISENICM
		_wOUTROS  :=SF3->F3_OUTRICM
		_wVALICM  :=SF3->F3_VALICM
		_wIPI     :=(SF3->F3_VALIPI+SF3->F3_IPIOBS)
		_wCONTIPI :=(SF3->F3_VALCONT-(SF3->F3_VALIPI+SF3->F3_IPIOBS))

		DbSelectArea(cArqTra)
		DbSeek(_wEST)
		If Found()
			Reclock(cArqTra,.F.)
		Else
			Reclock(cArqTra,.T.)
		Endif

		Replace ESTADO  With  _wEST               ,;
		VALCONT With  VALCONT + _wVALCONT ,;
		BASE    With  BASE    + _wBASE    ,;
		ISENTOS With  ISENTOS + _wISENTOS ,;
		OUTROS  With  OUTROS  + _wOUTROS  ,;
		VALICM  With  VALICM  + _wVALICM  ,;
		IPI     With  IPI     + _wIPI     ,;
		CONTIPI With  CONTIPI + _wCONTIPI
		MsUnLock()

		DbSelectArea("SF3")
		DbSkip()
	Enddo

	_TCONT   :=0
	_TBASE   :=0
	_TISENTOS:=0
	_TOUTROS :=0
	_TVALICM :=0
	_TIPI    :=0
	_TCONTIPI:=0

	DbSelectArea(cArqTra)
	DbGoTop()
	Do While !Eof()
		IncRegua()              // Termometro de Impressao
		*--------------------------------------------- INICIO IMPRESSAO
		If li>58
			cabec(titulo,cabec1,cabec2,wnrel,tamanho,nTipo)
		Endif
		@ li, 001 PSAY ESTADO
		@ li, 011 PSAY VALCONT    Picture "@E 9,999,999,999.99"
		@ li, 031 PSAY BASE       Picture "@E 999,999,999.99"
		@ li, 049 PSAY ISENTOS    Picture "@E 999,999,999.99"
		@ li, 067 PSAY OUTROS     Picture "@E 999,999,999.99"
		@ li, 084 PSAY VALICM     Picture "@E 999,999,999.99"
		@ li, 101 PSAY IPI        Picture "@E 999,999,999.99"
		@ li, 118 PSAY CONTIPI    Picture "@E 999,999,999.99"
		li:=li+2
		_TCONT   :=_TCONT    + VALCONT
		_TBASE   :=_TBASE    + BASE
		_TISENTOS:=_TISENTOS + ISENTOS
		_TOUTROS :=_TOUTROS  + OUTROS
		_TVALICM :=_TVALICM  + VALICM
		_TIPI    :=_TIPI     + IPI
		_TCONTIPI:=_TCONTIPI + CONTIPI
		DbSelectArea(cArqTra)
		DbSkip()
	Enddo

	If _TCONT > 0
		If li>58
			cabec(titulo,cabec1,cabec2,wnrel,tamanho,nTipo)
		Endif
		@ li, 001 PSAY "TOTAL ->"
		@ li, 010 PSAY _TCONT       Picture "@E 99,999,999,999.99"
		@ li, 031 PSAY _TBASE       Picture "@E 999,999,999.99"
		@ li, 049 PSAY _TISENTOS    Picture "@E 999,999,999.99"
		@ li, 067 PSAY _TOUTROS     Picture "@E 999,999,999.99"
		@ li, 084 PSAY _TVALICM     Picture "@E 999,999,999.99"
		@ li, 101 PSAY _TIPI        Picture "@E 999,999,999.99"
		@ li, 118 PSAY _TCONTIPI    Picture "@E 999,999,999.99"
	Endif

	If li!=80
		Roda(0,"",Tamanho)
	Endif

	Set Device To Screen

	If aReturn[5]==1
		Set Printer TO
		dbcommitAll()
		ourspool(wnrel)
	Endif

	MS_FLUSH() // Libera fila de relatorios em spool (Tipo Rede Netware)

	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Deleta Arquivo de Trabalho                                   ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	DbSelectArea(cArqTra)
	DbCloseArea()
	cDelArq:=cArqTra+".DBF"
	fErase(cDelArq)
	cDelArq:=SubStr(cArqTra,1,7)+"*"+OrdBagExt()
	fErase(cDelArq)

// Fim

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Cria Perguntas no SX1                                        ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
Static Function ValidPerg()
	Local i
	Local j
	cAlias := Alias()
	aRegs  := {}

	// Grupo/Ordem/Pergunta/Variavel/Tipo/Tamanho/Decimal/Presel/GSC/Valid/Var01/Def01/Cnt01/Var02/Def02/Cnt02/Var03/Def03/Cnt03/Var04/Def04/Cnt04/Var05/Def05/Cnt05
	AADD(aRegs,{cPerg,"01","Data Movto De      ?","","","mv_ch1","D",8,0,0,"G","","mv_par01","","","","","","","","","","","","","","",""})
	AADD(aRegs,{cPerg,"02","Data Movto Ate     ?","","","mv_ch2","D",8,0,0,"G","","mv_par02","","","","","","","","","","","","","","",""})
	AADD(aRegs,{cPerg,"03","E-Entr. / S-Saidas ?","","","mv_ch3","C",1,0,0,"C","","mv_par03","N.F. Entradas","","","","","N.F. Saidas","","","","","","","","","","",""})

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
