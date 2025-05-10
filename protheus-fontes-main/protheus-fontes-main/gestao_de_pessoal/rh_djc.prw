#INCLUDE "rwmake.ch"        // incluido pelo assistente de conversao do AP5 IDE em 23/08/00
#IFNDEF WINDOWS
#DEFINE PSAY SAY
#ENDIF

User Function RH_djc()        // incluido pelo assistente de conversao do AP5 IDE em 23/08/00

	//* Programa..: RH_DJC.PRX
	//* Autor.....: Claudioir Macedo     
	//* Data......: 10/04/02
	//* Nota......: Emissao Relatorio Comunicado Rescisao Contrato de Trabalho

	#IFNDEF WINDOWS
	// Movido para o inicio do arquivo pelo assistente de conversao do AP5 IDE em 23/08/00 ==>    #DEFINE PSAY SAY
	#ENDIF

	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Variaveis utilizadas para parametros                         ³
	//³ mv_par01     // Matricula De                                 ³
	//³ mv_par02     // Matricula Ate                                ³
	//³ mv_par01     // Matricula De                                 ³
	//³ mv_par02     // Matricula Ate                                ³
	//³ mv_par01     // Matricula De                                 ³
	//³ mv_par02     // Matricula Ate                                ³
	//³ mv_par01     // Matricula De                                 ³
	//³ mv_par02     // Matricula Ate                                ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ

	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Variaveis obrigatorias dos programas de relatorio            ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	cString :="SRA"
	cDesc1  :="Este programa tem como objetivo, Imprimir o Formulario "
	cDesc2  :="de Demissao por Justa Causa."
	cDesc3  :=""
	tamanho :="P"
	aReturn :={ "Zebrado", 1,"Administracao", 2, 2, 1, "",1 }
	aLinha  :={ }
	nLastKey:=0
	cPerg   :="RH_DJC"
	titulo  :="Demissão por Justa Causa"
	wnrel   :="RH_DJC"
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
	RptStatus({|| RptDetail()})// Substituido pelo assistente de conversao do AP5 IDE em 23/08/00 ==>    RptStatus({|| Execute(RptDetail)})
Return
// Substituido pelo assistente de conversao do AP5 IDE em 23/08/00 ==>    Function RptDetail
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
	DbSelectArea("SRA")                // * Movimentacao mensal
	DbSetOrder(1)
	DbSeek(xFilial()+mv_par01,.T.)
	Do While !Eof() .and. xFilial() == SRA->RA_FILIAL .And. SRA->RA_MAT <= mv_par02 
		_xMat:=SRA->RA_MAT
		//      If SRA->RA_DATAHOM<> mv_par03
		//         DbSelectArea("SRA")
		//         DbSkip()
		//         loop
		//      EndIf

		If _zMAT <> _xMAT
			If _zMAT <> "######" 
				li := 0
			Endif
			_zMAT:=_xMAT
		Endif
		li := li + 3
		@ li, 005 PSAY "COMUNICAÇÃO DE RESCISAO DO CONTRATO DE TRABALHO P/ JUSTA CAUSA"
		li := li + 4
		@ li, 000 PSAY "De....:"+Left(SM0->M0_NOMECOM,30) + Space(10) + " CGC...:  "+SM0->M0_CGC
		li := li + 2
		@ li, 000 PSAY "Para..:"+Left(SRA->RA_NOME,30) + Space(10) + "CTPS..:  "+SRA->RA_NUMCP+"/"+SRA->RA_SERCP
		li := li + 3
		@ li, 000 PSAY replicate("-",80)
		li := li + 2   
		@ li, 004 PSAY "Com fundamento no art.482 da CLT, decidimos rescindir de imediato o seu con-"
		li := li + 2                            
		@ li, 000 PSAY "trato de trabalho. Solicitamos seu comparecimento ao Depto. Pessoal, de posse de"
		li := li + 2
		@ li, 000 PSAY "sua Carteira de Trabalho e Previdencia Social, para dar cumprimento as  formali-"
		li := li + 2
		@ li, 000 PSAY "dades exigidas para a rescisão."
		li := li + 2
		@ li, 004 PSAY "Agradecendo a cooperacao prestada por V.Sa. ate a  presente data,  pedimos a"
		li := li + 2
		@ li, 000 PSAY "devolucao do presente Aviso com seu ciente."
		li := li + 5

		@ li, 004 PSAY +LEFT(SM0->M0_CIDCOB,30)+", "+str(day(mv_par03),2,0)+" de  "+mesextenso(month(mv_par03))+" de  "+str(year(ddatabase),4,0)+"."
		li := li + 4
		@ li, 000 PSAY replicate("_",30)+space(10)+replicate("_",30)
		li := li + 1
		@ li, 000 PSAY LEFT(SM0->M0_NOMECOM,30)+space(10)+Left(SRA->RA_NOME,30)
		li := li + 4
		@li,0     PSAY replicate("-",80)
		li := li + 2
		@ li, 004 PSAY "IMPORTANTE:"
		li := li + 2
		@ li, 004 PSAY "Solicitamos  seu comparecimento no local abaixo indicado no dia " +dtoc(mv_par04)+"  as
		li := li + 1
		@ li, 000 PSAY +mv_par05+" horas, de posse da  C.T.P.S. Sendo Menor de idade devera fazer-se  acompa-"
		li := li + 1
		@ li, 000 PSAY "nhar de um representante legal."
		li := li + 2

		If mv_par06 == 1
			If SRA->RA_SINDICA == "01"

				DbSelectArea("RCE")
				DbSeek(xFilial()+"01")
				@ li, 000 PSAY "Local do acerto: " +Left(RCE->RCE_DESCRI,60)  
				li := li + 1
				@ li, 000 PSAY "Endereco: "  +Left(RCE->RCE_ENDER,25) +" Nº: "+Left(RCE->RCE_NUMER,06)+ "  Bairro: " +Left(RCE->RCE_BAIRRO,10)
				li := li + 1
				@ li, 000 PSAY "Cidade: "+Left(RCE->RCE_MUNIC,15) +" Est: "+Left(RCE->RCE_UF,05)

			Endif
		Endif

		li := li + 1 
		If mv_par06 == 1
			If SRA->RA_SINDICA == "02"

				DbSelectArea("RCE")
				DbSeek(xFilial()+"02")
				@ li, 000 PSAY "Local do acerto: " +Left(RCE->RCE_DESCRI,60)  
				li := li + 1
				@ li, 000 PSAY "Endereco: "  +Left(RCE->RCE_ENDER,25) +" Nº: "+Left(RCE->RCE_NUMER,06)+ "  Bairro: " +Left(RCE->RCE_BAIRRO,10)
				li := li + 1
				@ li, 000 PSAY "Cidade: "+Left(RCE->RCE_MUNIC,15) +" Est: "+Left(RCE->RCE_UF,05)

			Endif
		Endif

		li := li + 1
		If mv_par06 == 1
			If SRA->RA_SINDICA == "03"

				DbSelectArea("RCE")
				DbSeek(xFilial()+"03")
				@ li, 000 PSAY "Local do acerto: " +Left(RCE->RCE_DESCRI,60)  
				li := li + 1
				@ li, 000 PSAY "Endereco: "  +Left(RCE->RCE_ENDER,25) +" Nº: "+Left(RCE->RCE_NUMER,06)+ "  Bairro: " +Left(RCE->RCE_BAIRRO,10)
				li := li + 1
				@ li, 000 PSAY "Cidade: "+Left(RCE->RCE_MUNIC,15) +" Est: "+Left(RCE->RCE_UF,05)

			Endif
		Endif

		li := li + 1
		If mv_par06 == 1
			If SRA->RA_SINDICA == "04"

				DbSelectArea("RCE")
				DbSeek(xFilial()+"04")
				@ li, 000 PSAY "Local do acerto: " +Left(RCE->RCE_DESCRI,60)  
				li := li + 1
				@ li, 000 PSAY "Endereco: "  +Left(RCE->RCE_ENDER,25) +" Nº: "+Left(RCE->RCE_NUMER,06)+ "  Bairro: " +Left(RCE->RCE_BAIRRO,10)
				li := li + 1
				@ li, 000 PSAY "Cidade: "+Left(RCE->RCE_MUNIC,15) +" Est: "+Left(RCE->RCE_UF,05)

			Endif
		Endif

		li := li + 1
		If mv_par06 == 1
			If SRA->RA_SINDICA == "05"

				DbSelectArea("RCE")
				DbSeek(xFilial()+"01")
				@ li, 000 PSAY "Local do acerto: " +Left(RCE->RCE_DESCRI,60)  
				li := li + 1
				@ li, 000 PSAY "Endereco: "  +Left(RCE->RCE_ENDER,25) +" Nº: "+Left(RCE->RCE_NUMER,06)+ "  Bairro: " +Left(RCE->RCE_BAIRRO,10)
				li := li + 1
				@ li, 000 PSAY "Cidade: "+Left(RCE->RCE_MUNIC,15) +" Est: "+Left(RCE->RCE_UF,05)

			Endif
		Endif

		li := li + 1
		If mv_par06 == 2
			@ li, 000 PSAY "Local do acerto: "+Left(SM0->M0_NOMECOM,30)
			li := li + 1
			@ li, 000 PSAY "Endereco: "   +SM0->M0_CIDCOB+" a "+SM0->M0_ENDCOB
		EndIf

		li := li + 1
		If mv_par06 == 3
			@ li, 000 PSAY "Local do acerto: Ministério do Trabalho e Emprego"
			li := li + 1
			@ li, 000 PSAY "Endereco: ________________________________________________"
		EndIf
		li := li + 2
		@li,0     PSAY replicate("-",80)
		li := li + 2
		@ li, 004 PSAY "EXAME MEDICO DEMISSIONAL"
		li := li + 2
		@ li, 004 PSAY "Comparecer no(a): "+mv_par07
		li := li + 1
		@ li, 000 PSAY +mv_par08+mv_par09
		li := li + 1
		@ li, 000 PSAY "no dia "+dtoc(mv_par10)+"  as "+mv_par11+"  horas para exames medicos demissionais."
		li := li + 2
		@ li, 000 PSAY       +LEFT(SM0->M0_CIDCOB,30)+", "+str(day(mv_par03),2,0)+" de  "+mesextenso(month(mv_par03))+" de  "+str(year(mv_par03),4,0)+"."
		li := li + 3
		@ li, 000 PSAY        +replicate("_",27)
		li := li + 1
		@ li, 000 PSAY        +Left(SRA->RA_NOME,30)
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
// Substituido pelo assistente de conversao do AP5 IDE em 23/08/00 ==> Function ValidPerg
Static Function ValidPerg()
	Local i
	Local j
	cAlias := Alias()
	aRegs  :={}

	// Grupo/Ordem/Pergunta/Variavel/Tipo/Tamanho/Decimal/Presel/GSC/Valid/Var01/Def01/Cnt01/Var02/Def02/Cnt02/Var03/Def03/Cnt03/Var04/Def04/Cnt04/Var05/Def05/Cnt05
	AADD(aRegs,{cPerg,"01","Matricula Inicial  ","","","mv_ch1","C",06,0,0,"G","","mv_par01","","","","","","","","","","","","","","","","","","","","","","","","","SRA",""})
	AADD(aRegs,{cPerg,"02","Matricula Final    ","","","mv_ch2","C",06,0,0,"G","","mv_par02","","","","","","","","","","","","","","","","","","","","","","","","","SRA",""})
	AADD(aRegs,{cPerg,"03","Data Demissao      ","","","mv_ch3","D",08,0,0,"G","","mv_par03","","","","","","","","","","","","","","","","","","","","","","","","","",""}) 
	AADD(aRegs,{cPerg,"04","Data do Acerto     ","","","mv_ch4","D",08,0,0,"G","","mv_par04","","","","","","","","","","","","","","","","","","","","","","","","","",""})
	AADD(aRegs,{cPerg,"05","Hora do Acerto     ","","","mv_ch5","C",05,0,0,"G","","mv_par05","","","","","","","","","","","","","","","","","","","","","","","","","",""})
	AADD(aRegs,{cPerg,"06","Local do Acerto    ","","","mv_ch6","N",1,0,2,"C","","mv_par06","Sindicato","","","","","Empresa","","","","","Ministerio","","","","","","","","","","","","","","",""})
	AADD(aRegs,{cPerg,"07","Local do Exame     ","","","mv_ch7","C",40,0,0,"G","","mv_par07","","","","","","","","","","","","","","","","","","","","","","","","","",""})
	AADD(aRegs,{cPerg,"08","Endereco           ","","","mv_ch8","C",40,0,0,"G","","mv_par08","","","","","","","","","","","","","","","","","","","","","","","","","",""})
	AADD(aRegs,{cPerg,"09","Complem.End.       ","","","mv_ch9","C",40,0,0,"G","","mv_par09","","","","","","","","","","","","","","","","","","","","","","","","","",""})
	AADD(aRegs,{cPerg,"10","Data do exame      ","","","mv_ch10","D",08,0,0,"G","","mv_par10","","","","","","","","","","","","","","","","","","","","","","","","","",""})
	AADD(aRegs,{cPerg,"11","Hora do exame      ","","","mv_ch11","C",05,0,0,"G","","mv_par11","","","","","","","","","","","","","","","","","","","","","","","","","",""})


	DbSelectArea("SX1")
	DbSetOrder(1)
	For i:=1 to Len(aRegs)
		If !DbSeek(cPerg+aRegs[i,2])
			RecLock("SX1",.T.)
		else
			RecLock("SX1",.F.)
		endif
		For j:=1 to FCount()

			// Campos CNT nao sao gravados para preservar conteudo anterior.
			If j<=Len(aRegs[i]) .and. left (fieldname (j), 6) != "X1_CNT" .and. fieldname (j) != "X1_PRESEL"
				FieldPut(j,aRegs[i,j])
			Endif
		Next
		MsUnlock()
	Next
	DbSelectArea(cAlias)
Return


