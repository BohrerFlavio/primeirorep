#INCLUDE "rwmake.ch"        // incluido pelo assistente de conversao do AP5 IDE em 11/10/00
#IFNDEF WINDOWS
#DEFINE PSAY SAY
#ENDIF

User Function rh_ctpr()        // incluido pelo assistente de conversao do AP5 IDE em 11/10/00

	// Programa..: rh_ctpr.PRX
	// Autor.....: Claudioir Macedo  
	// Data......: 10/04/02
	// Nota......: Emissao Relatorio Termo Prorogacaoo do Contrato de Experiencia

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
	cDesc1  :="Este programa tem como objetivo, Imprimir o Termo"
	cDesc2  :="de Prorrogacao do Contrato de Experiencia        "
	cDesc3  :=""

	tamanho :="P"
	aReturn :={ "Zebrado", 1,"Administracao", 2, 2, 1, "",1 }
	aLinha  :={ }
	nLastKey:=0
	cPerg   :="RHCTPR"
	titulo  :="Prorrogação Contrato Experiência"
	wnrel   :="RHCTPR"
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

		li := li + 6
		@ li, 000 PSAY  chr(20)+"  "+"             T E R M O    D E    P R O R R O G A C A O "
		li := li + 2
		@ li, 000 PSAY  chr(20)+"  "+"                       DO CONTRATO DE EXPERIENCIA"
		li := li + 4
		@ li, 004 PSAY "Por este  instrumento particular,      "+Left(SM0->M0_NOMECOM,30)+"       e" 
		li := li + 2
		@ li, 000 PSAY +Left(SRA->RA_NOME,30)+", partes integrantes  do  CONTRATO  DE  EXPERIENCIA"
		li := li + 2
		@ li, 000 PSAY "firmado em "+str(day(SRA->RA_ADMISSA),2,0)+" de "+mesextenso(month(SRA->RA_ADMISSA))+"  de "+str(year(SRA->RA_ADMISSA),4,0)+", que  deveria  expirar em "+str(day(SRA->RA_VCTOEXP),2,0)+" de "+mesextenso(month(SRA->RA_VCTOEXP))+" de "+str(year(SRA->RA_VCTOEXP),4,0)
		@ li, 080 PSAY ","
		li := li + 2
		ddatafim:=SRA->RA_VCTEXP2+MV_PAR03
		@ li, 000 PSAY "convencionam  prorroga-lo pelo prazo de "+Alltrim(STR(mv_par03))+" ("+left(STRTRAN(EXTENSO(mv_par03),"REAIS"," "),16)+") dias, expirando na data de"
		li := li + 2
		@ li, 000 PSAY str(day(SRA->RA_VCTEXP2),2,0)+" de "+mesextenso(month(SRA->RA_VCTEXP2))+" de "+str(year(SRA->RA_VCTEXP2),4,0)+", deixando certo,  para  fins  do artigo 451 da  CLT, ser esta"
		li := li + 2
		@ li, 000 PSAY "a primeira e  unica prorrogacao do mencionado contrato."
		li := li + 4
		@ li, 004 PSAY LEFT(SM0->M0_CIDCOB,30)+", "+str(day(SRA->RA_VCTOEXP),2,0)+" de  "+mesextenso(month(SRA->RA_VCTOEXP))+" de  "+str(year(SRA->RA_VCTOEXP),4,0)+"."
		li := li + 4
		@ li, 000 PSAY replicate("_",30)+SPACE(06)+replicate("_",30)
		li := li + 1
		@ li, 000 PSAY +Left(SM0->M0_NOMECOM,30)+SPACE(08)+Left(SRA->RA_NOME,30)      
		li := li + 4
		@ li, 000 PSAY replicate("_",30)+SPACE(06)+replicate("_",30)
		li := li + 1
		@ li, 000 PSAY "         TESTEMUNHA        "+SPACE(08)+"        TESTEMUNHA"
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
	AADD(aRegs,{cPerg,"03","Dias de Prorrogacao?","","","mv_ch3","N",02,0,0,"G","","mv_par03","","","","","","","","","","","","","","","","","","","","","","","","","",""})
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
