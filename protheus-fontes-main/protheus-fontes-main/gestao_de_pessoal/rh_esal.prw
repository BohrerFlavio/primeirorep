#INCLUDE "rwmake.ch"    

User Function rh_esal() 

	//* Programa..: ML_ESAL.PRX
	//* Autor.....: Claudioir
	//* Data......: 13:00pm Set 01,1999
	//* Nota......: Evolucao Salarial

	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Variaveis utilizadas para parametros                         ³
	//³ mv_par01     // Matricula De                                 ³
	//³ mv_par02     // Matricula Ate                                ³
	//³ mv_par03     // Nome De                                      ³
	//³ mv_par04     // Nome Ate                                     ³
	//³ mv_par05     // Centro Custo De                              ³
	//³ mv_par06     // Centro Custo Ate                             ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ

	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Variaveis obrigatorias dos programas de relatorio            ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	cString :="SRA"
	cDesc1  :="Este programa tem como objetivo, imprimir relatorio de"
	cDesc2  :="Evolucao Salarial"
	cDesc3  :=""
	tamanho :="P"
	aReturn :={ "Zebrado", 1,"Administracao", 2, 2, 1, "",1 }
	aLinha  :={ }
	nLastKey:=0
	cPerg   :="RH_SAL"
	titulo  :="Evolucao Salarial"
	wnrel   :="RH_SAL"
	nTipo   :=0
	nOrdem  :=0

	ValidPerg()
	Pergunte(cPerg,.F.)      // Pergunta no SX1

	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Envia controle para a funcao SETPRINT                        ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	aOrd :={"Por Matricula","Por Centro Custo","Por Nome"}
	wnrel:=SetPrint(cString,wnrel,cPerg,titulo,cDesc1,cDesc2,cDesc3,.F.,aOrd)

	If nLastKey == 27
		Return
	Endif
	ferase(__reldir + wnrel + '.##r')
	SetDefault(aReturn,cString)
	If nLastKey == 27
		Return
	Endif

	RptStatus({|| RptDetail()})
Return


Static Function RptDetail()

	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Inicializa  regua de impressao                            ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ

	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Inicializa os codigos de caracter Comprimido/Normal da impressora ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	nTipo  := IIF(aReturn[4]==1,15,18)
	li     := 80
	m_pag  := 1
	nOrdem := aReturn[8]

	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Cria o cabecalho.                                        ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	cabec1 := "Tipo Aumento        Dt Aumen. Funcao                             Valor   %Aumen." 
	cabec2 := "                                                                                "
	*****      XXX X-------------X XX.XX.XX  X-----------------------X XXX,XXX,XXX.XX   XXX,XX
	*****                1         2         3         4         5         6         7         8         9         0         1         2         3
	*****      0123456789012345678901234567890123456789012345678901234567890123456789012345678901234567890123456789012345678901234567890123456789012

	DbSelectArea("SRA")
	If nOrdem == 1
		dbSetOrder(1)
		dbSeek(xFilial()+mv_par01,.T.)
		cCond1 := "RA_MAT <= mv_par02"
		titulo := titulo + " Por Matricula"
	Elseif nOrdem == 2
		dbSetOrder(2)
		dbSeek(xFilial()+mv_par05,.T.)
		cCond1 := "RA_CC <= mv_par06"
		titulo := titulo + " Por Centro Custo"
	Elseif nOrdem == 3
		DbSetOrder(3)
		dbSeek(xFilial()+mv_par03,.T.)
		cCond1 := "RA_NOME <= mv_par04"
		titulo := titulo + " Por Nome"
	Endif

	SetRegua(LastRec())
	_xMAT:="######"
	_xTeste1:= 0
	_VAR:=0
	Do While !Eof() .And. xFilial()==RA_FILIAL .And. &cCond1
		IncRegua()              // Termometro de Impressao
		If SRA->RA_MAT < MV_PAR01 .Or. SRA->RA_MAT > MV_PAR02
			DbSelectArea("SRA")
			DbSkip()
			Loop
		Endif
		If SRA->RA_NOME < MV_PAR03 .Or. SRA->RA_NOME > MV_PAR04
			DbSelectArea("SRA")
			DbSkip()
			Loop
		Endif
		If SRA->RA_CC < MV_PAR05 .Or. SRA->RA_CC > MV_PAR06
			DbSelectArea("SRA")
			DbSkip()
			Loop
		Endif
		_cMat   := SRA->RA_MAT
		_cNome  := SRA->RA_NOME
		_dAdm   := SRA->RA_ADMISSA
		_xValor := SRA->RA_SALARIO
		_xFuncao:= SRA->RA_CODFUNC
		_xTeste := 0
		If li>58
			cabec(titulo,cabec1,cabec2,wnrel,tamanho,nTipo)
		Endif
		DbSelectArea("SR7")
		DbSetOrder(1)
		DbSeek(xFilial()+_cMat)
		Do While !Eof() .And. xFilial() == R7_FILIAL .And. R7_MAT <= _cMat
			_xTeste := 1
			_xTeste1:= 1
			If li>58
				cabec(titulo,cabec1,cabec2,wnrel,tamanho,nTipo)
			Endif
			If _xMAT<>SR7->R7_MAT
				If li>58
					cabec(titulo,cabec1,cabec2,wnrel,tamanho,nTipo)
				Endif
				If _xMAT<>"######"
					@ li, 000 PSAY Replicate("-",81)
					li:=li+1
				EndIf
				@ li, 000 PSAY "Funcionario : "+SR7->R7_MAT+" "+_cNome+"  Data Admis.:"+Dtoc(_dAdm)
				li:=li+1
				_xMAT:=SR7->R7_MAT
				_VAR:=0  
			EndIf
			//DbSelectArea("SX5")
			//DbSeek(xFilial()+"41"+SR7->R7_TIPO)
			@ li, 000 PSAY SR7->R7_TIPO
			@ li, 004 PSAY Left(FWGetSX5("41", SR7->R7_TIPO)[1][4],15)
			If SR7->R7_TIPO<>"001"
				@ li, 020 PSAY DTOC(SR7->R7_DATA)
			EndIf
			@ li, 030 PSAY LEFT(SR7->R7_DESCFUN,25)
			DbSelectArea("SR3")
			DbSeek(xFilial()+SR7->R7_MAT+Dtos(SR7->R7_DATA)+SR7->R7_TIPO)
			IF found()
				_VALOR:=SR3->R3_VALOR
			Else
				_VALOR:=0
			EndIf
			@ li, 056 PSAY _VALOR Picture "@E 999,999,999.99"
			IF SR7->R7_TIPO <> "005"
				@ li, 073 PSAY IIF(_VAR > 0,((_VALOR*100)/_VAR)-100,0) Picture "@E 999.99" 
			ENDIF
			_VAR:=_VALOR
			li:=li+1
			DbSelectArea("SR7")
			DbSkip()
		Enddo
		If _xTeste == 0
			@ li, 000 PSAY Replicate("-",81)
			li:=li+1
			@ li, 000 PSAY "*Funcionario: "+_cMAT+" "+_cNome+"  Data Admis.:"+Dtoc(_dAdm)
			li:=li+1
			@ li, 000 PSAY "001"
			@ li, 004 PSAY "SALARIO INICIAL"
			DbSelectArea("SRJ")
			DbSeek(xFilial()+_xFuncao)
			If found()
				@ li, 030 PSAY LEFT(SRJ->RJ_DESC,25)
			Else
				@ li, 030 PSAY Replicate("?",25)
			Endif
			@ li, 056 PSAY _xVALOR Picture "@E 999,999,999.99"
			li:=li+1
			If _xTeste1 == 0
				@ li, 000 PSAY Replicate("-",81)
				li:=li+1
			Endif
		Endif
		DbSelectArea("SRA")
		DbSkip()
	Enddo

	IF li!=80
		Roda(0,"",Tamanho)
	Endif

	Set Device To Screen

	If aReturn[5]==1
		Set Printer TO
		dbcommitAll()
		ourspool(wnrel)
	Endif
	MS_FLUSH() //Libera fila de relatorios em spool (Tipo Rede Netware)

	*FIM

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Cria Perguntas no SX1                                        ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
// Substituido pelo assistente de conversao do AP5 IDE em 09/04/01 ==> Function ValidPerg
Static Function ValidPerg()
	Local i
	Local j
	cAlias := Alias()
	aRegs  :={}

	// Grupo/Ordem/Pergunta/Variavel/Tipo/Tamanho/Decimal/Presel/GSC/Valid/Var01/Def01/Cnt01/Var02/Def02/Cnt02/Var03/Def03/Cnt03/Var04/Def04/Cnt04/Var05/Def05/Cnt05
	AADD(aRegs,{cPerg,"01","Matricula De       ?","","","mv_ch1","C",6 ,0,0,"G","","mv_par01","","","","","","","","","","","","","","","SRA"})
	AADD(aRegs,{cPerg,"02","Matricula Ate      ?","","","mv_ch2","C",6 ,0,0,"G","","mv_par02","","","","","","","","","","","","","","","SRA"})
	AADD(aRegs,{cPerg,"03","Nome De            ?","","","mv_ch3","C",30,0,0,"G","","mv_par03","","","","","","","","","","","","","","",""})
	AADD(aRegs,{cPerg,"04","Nome Ate           ?","","","mv_ch4","C",30,0,0,"G","","mv_par04","","","","","","","","","","","","","","",""})
	AADD(aRegs,{cPerg,"05","Centro Custo De    ?","","","mv_ch5","C",9 ,0,0,"G","","mv_par05","","","","","","","","","","","","","","","SI3"})
	AADD(aRegs,{cPerg,"06","Centro Custo Ate   ?","","","mv_ch6","C",9 ,0,0,"G","","mv_par06","","","","","","","","","","","","","","","SI3"})

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

