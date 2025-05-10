#INCLUDE "rwmake.ch"        // incluido pelo assistente de conversao do AP5 IDE em 05/07/01
#IFNDEF WINDOWS
#DEFINE PSAY SAY
#ENDIF

User Function Ml_ficha()        // incluido pelo assistente de conversao do AP5 IDE em 05/07/01

	//* Programa..: ML_FICH.PRX
	//* Autor.....: Fernando Possoli 
	//* Data......: 23/08/2000
	//* Nota......: Emissao Ficha Registro

	#IFNDEF WINDOWS
	// Movido para o inicio do arquivo pelo assistente de conversao do AP5 IDE em 05/07/01 ==>    #DEFINE PSAY SAY
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
	cDesc1  :="Este programa tem como objetivo, Imprimir o Formulario "
	cDesc2  :="de Ficha Registro"
	cDesc3  :=""
	tamanho :="P"
	aReturn :={ "Zebrado", 1,"Administracao", 2, 2, 1, "",1 }
	aLinha  :={ }
	nLastKey:=0
	cPerg   :="ML_FIC"
	titulo  :="Emissao Ficha Registro         "
	wnrel   :="ML_FIC"
	nTipo   :=0
	nLin    :=0
	nTamNf  :=32
	_xvez   :=0
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
	RptStatus({|| RptDetail()})// Substituido pelo assistente de conversao do AP5 IDE em 05/07/01 ==>    RptStatus({|| Execute(RptDetail)})
Return
// Substituido pelo assistente de conversao do AP5 IDE em 05/07/01 ==>    Function RptDetail
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
		_xSal:=Iif(SRA->RA_CATFUNC="H",(SRA->RA_SALARIO * SRA->RA_HRSMES),SRA->RA_SALARIO)
		_xSalHora:=Iif(SRA->RA_CATFUNC="M",(SRA->RA_SALARIO / SRA->RA_HRSMES),SRA->RA_SALARIO)
		If _zMAT <> _xMAT
			Cabec()
			If _zMAT <> "######"
				li := 0
			Endif
			_zMAT:=_xMAT
		Endif
		li := li + 1
		@ li, 000 PSAY chr(204)+replicate(chr(205),20)+chr(203)+REPLICATE(chr(205),111)+chr(185)
		li := li + 1
		@ li, 000 PSAY chr(186)+space(20)+chr(186)+"Nome...:"+LEFT(SRA->RA_NOME,45)+space(20)+"Matricula..:"+SRA->RA_MAT+space(14)+"No. Ordem..:"+"00"+LEFT(SRA->RA_FICHA,10)+SPACE(01)+chr(186)
		li := li + 1
		@ li, 000 PSAY chr(186)+space(20)+chr(204)+REPLICATE(chr(205),111)+chr(185)
		li := li + 1
		@ li, 000 PSAY chr(186)+space(20)+chr(186)+"Filiacao.:   Pai:"+LEFT(SRA->RA_PAI,45)+SPACE(54)+chr(186)
		li := li + 1
		@ li, 000 PSAY chr(186)+space(20)+chr(186)+"             Mae:"+LEFT(SRA->RA_MAE,45)+SPACE(54)+chr(186)
		li := li + 1
		@ li, 000 PSAY chr(186)+space(20)+chr(204)+REPLICATE(chr(205),111)+chr(185)
		li := li + 1
		@ li, 000 PSAY chr(186)+space(20)+chr(186)+"Cart Profissional: "+SRA->RA_NUMCP+SPACE(04)+"Serie..: "+SRA->RA_SERCP+SPACE(04)+"Emissao..: "+SPACE(10)+"Identidade..: "+SRA->RA_RG+SPACE(13)+chr(186)
		li := li + 1
		@ li, 000 PSAY chr(186)+space(20)+chr(186)+"Cart Reservista  : "+LEFT(SRA->RA_RESERVI+SPACE(12),12)+SPACE(38)+"Categoria...: "+SPACE(28)+chr(186)
		li := li + 1
		@ li, 000 PSAY chr(186)+space(20)+chr(186)+"Tit do Eleitor   : "+LEFT(SRA->RA_TITULOE+SPACE(12),12)+SPACE(05)+"Zona/Secao..: "+LEFT(SRA->RA_ZONASEC+SPACE(08),08)+SPACE(53)+chr(186)
		li := li + 1
		@ li, 000 PSAY chr(186)+space(20)+chr(186)+"C.P.F.           : "+SRA->RA_CIC+SPACE(06)+"PIS/PASEP...: "+SRA->RA_PIS+SPACE(08)+"Data Cad.PIS..:"+SPACE(27)+chr(186)
		li := li + 1
		@ li, 000 PSAY chr(186)+space(20)+chr(186)+"Cart Habilitacao : "+LEFT(SRA->RA_HABILIT+SPACE(11),11)+SPACE(06)+"Tipo Habili.: "+SPACE(19)+"Reg Profissio.:"+SPACE(27)+chr(186)
		li := li + 1
		@ li, 000 PSAY chr(204)+replicate(chr(205),20)+chr(202)+REPLICATE(chr(205),111)+chr(185)
		li := li + 1
		//DbSelectArea("SX5")
		//DbSetOrder(1)
		//DbSeek(xFilial()+"26"+SRA->RA_GRINRAI)
		//If Found()
		//	_xGrau:=LEFT(SX5->X5_DESCRI,35)
		//Else
		//	_xGrau:=replicate("?",35)
		//Endif
		_xGrau := Left(FWGetSX5("26", SRA->RA_GRINRAI)[1][4],35)
		@ li, 000 PSAY chr(186)+"Data Nascimento  : "+DTOC(SRA->RA_NASC)+SPACE(05)+"Est Civil...: "+LEFT(IIF(SRA->RA_ESTCIVI=="C","Casado","Solteiro")+SPACE(10),10)+SPACE(05)+"Sexo.:"+IIF(SRA->RA_SEXO=="M","Masculino"," Feminino")+SPACE(05)+"Grau Inst..: "+_xGrau+SPACE(03)+chr(186)
		li := li + 1
		//DbSelectArea("SX5")
		//DbSetOrder(1)
		//DbSeek(xFilial()+"34"+SRA->RA_NACIONA)
		//If Found()
		//	_xNaci:=LEFT(SX5->X5_DESCRI,35)
		//Else
		//	_xNaci:=replicate("?",35)
		//Endif
		_xNaci := Left(FWGetSX5("34", SRA->RA_NACIONA)[1][4],35)

		//DbSelectArea("SX5")
		//DbSetOrder(1)
		//DbSeek(xFilial()+"12"+SRA->RA_NATURAL)
		//If Found()
		//	_xEst:=LEFT(SX5->X5_DESCRI,35)
		//Else
		//	_xEst:=replicate("?",35)
		//Endif
		_xEst := Left(FWGetSX5("12", SRA->RA_NATURAL)[1][4],35)
		@ li, 000 PSAY chr(186)+"Nacionalidade    : "+_xNaci+SPACE(27)+"Naturalidade  :"+_xEst+SPACE(1)+Chr(186)
		li := li + 1
		@ li, 000 PSAY chr(204)+REPLICATE(chr(205),132)+chr(185)
		li := li + 1
		@ li, 000 PSAY chr(186)+"Quando Estrangeiro"+SPACE(114)+Chr(186)
		li := li + 1
		@ li, 000 PSAY chr(186)+"Data da Chegada..:"+SPACE(15)+"Naturalizado..:"+Space(15)+"Conjuge Brasileiro..:"+SPACE(15)+"No da Carteira..:"+SPACE(16)+Chr(186)
		li := li + 1
		@ li, 000 PSAY chr(186)+"Tem Filhos Bras..:"+SPACE(15)+"No. de Filhos.:"+Space(15)+"No. Reg. Geral......:"+SPACE(15)+"No Decreto......:"+SPACE(16)+Chr(186)
		li := li + 1
		@ li, 000 PSAY chr(186)+"Tipo de Visto....:"+SPACE(45)+"Val Cart Identidade.:"+SPACE(15)+"Val Cart Traba..:"+SPACE(16)+Chr(186)
		li := li + 1
		@ li, 000 PSAY chr(204)+REPLICATE(chr(205),132)+chr(185)
		li := li + 1
		@ li, 000 PSAY chr(186)+"Endereco Atual...:"+LEFT(SRA->RA_ENDERECO+SPACE(40),40)+SPACE(02)+"Bairro.:"+LEFT(SRA->RA_BAIRRO+SPACE(20),20)+SPACE(05)+"Cidade..:"+LEFT(SRA->RA_MUNICIP+SPACE(30),30)+Chr(186)
		li := li + 1
		@ li, 000 PSAY chr(186)+"Estado...........:"+SRA->RA_UFCP+SPACE(40)+"CEP....: "+SRA->RA_CEP+SPACE(15)+SPACE(40)+Chr(186)
		li := li + 1

		DbSelectArea("SR9")                // * Movimentacao mensal
		DbSetOrder(1)
		DbSeek(xFilial()+SRA->RA_MAT+"RA_ENDEREC")
		_xTeste:=0
		_xMend:=SPACE(35)
		Do While !Eof() .and. xFilial() == SR9->R9_FILIAL .And. SR9->R9_MAT == SRA->RA_MAT .AND. SR9->R9_CAMPO == "RA_ENDEREC"
			//   _xMend:=LEFT(SR9->R9_DESC,35)
			_wReg:=Recno()
			_xTeste:=1
			DbSelectArea("SR9")                // * Movimentacao mensal
			DbSkip()
		Enddo
		If _xTeste == 1
			go _wReg
			DbSkip(-1)
			_xMend:=LEFT(SR9->R9_DESC,35)
		Endif

		DbSelectArea("SR9")                // * Movimentacao mensal
		DbSetOrder(1)
		DbSeek(xFilial()+SRA->RA_MAT+"RA_BAIRRO")
		_xTeste1:=0
		_xMBairro:=SPACE(20)
		Do While !Eof() .and. xFilial() == SR9->R9_FILIAL .And. SR9->R9_MAT == SRA->RA_MAT .AND. SR9->R9_CAMPO == "RA_BAIRRO"
			//   _xMBairro:=LEFT(SR9->R9_DESC,20)
			_wReg:=Recno()
			_xTeste1:=1
			DbSelectArea("SR9")                // * Movimentacao mensal
			DbSkip()
		Enddo
		If _xTeste1 == 1
			go _wReg
			DbSkip(-1)
			_xBairro:=LEFT(SR9->R9_DESC,20)
		Endif

		DbSelectArea("SR9")                // * Movimentacao mensal
		DbSetOrder(1)
		DbSeek(xFilial()+SRA->RA_MAT+"RA_MUNICIP")
		_xTeste3:=0
		_xMcidade:=SPACE(30)
		Do While !Eof() .and. xFilial() == SR9->R9_FILIAL .And. SR9->R9_MAT == SRA->RA_MAT .AND. SR9->R9_CAMPO == "RA_MUNICIP"
			//   _xMCidade:=LEFT(SR9->R9_DESC,35)
			_wReg:=Recno()
			_xTeste3:=1
			DbSelectArea("SR9")                // * Movimentacao mensal
			DbSkip()
		Enddo
		If _xTeste3 == 1
			go _wReg
			DbSkip(-1)
			_xMcidade:=LEFT(SR9->R9_DESC,30)
		Endif

		DbSelectArea("SR9")                // * Movimentacao mensal
		DbSetOrder(1)
		DbSeek(xFilial()+SRA->RA_MAT+"RA_ESTADO")
		_xTeste4:=0
		_xMestado:=SPACE(02)
		Do While !Eof() .and. xFilial() == SR9->R9_FILIAL .And. SR9->R9_MAT == SRA->RA_MAT .AND. SR9->R9_CAMPO == "RA_ESTADO"
			//   _xMestado:=LEFT(SR9->R9_DESC,2)
			_wReg:=Recno()
			_xTeste4:=1
			DbSelectArea("SR9")                // * Movimentacao mensal
			DbSkip()
		Enddo
		If _xTeste4 == 1
			go _wReg
			DbSkip(-1)
			_xMestado:=SR9->R9_DESC
		Endif

		DbSelectArea("SR9")                // * Movimentacao mensal
		DbSetOrder(1)
		DbSeek(xFilial()+SRA->RA_MAT+"RA_CEP")
		_xTeste5:=0
		_xMcep:=SPACE(08)
		Do While !Eof() .and. xFilial() == SR9->R9_FILIAL .And. SR9->R9_MAT == SRA->RA_MAT .AND. SR9->R9_CAMPO == "RA_CEP"
			//   _xMcep:=SR9->R9_DESC
			_wReg:=Recno()
			_xTeste5:=1
			DbSelectArea("SR9")                // * Movimentacao mensal
			DbSkip()
		Enddo
		If _xTeste5 == 1
			go _wReg
			DbSkip(-1)
			_xMcep:=SR9->R9_DESC
		Endif
		If li>58
			Cabec()
		Endif
		@ li, 000 PSAY chr(186)+"Mud.Endereco.....:"+_xMend+SPACE(07)+"Bairro.:"+_xMBairro+SPACE(05)+"Cidade..:"+_xMCidade+Chr(186)
		li := li + 1
		@ li, 000 PSAY chr(186)+"Estado...........:"+_xMEstado+SPACE(40)+"CEP....: "+_xMCep+SPACE(55)+Chr(186)
		li := li + 1
		@ li, 000 PSAY chr(204)+REPLICATE(chr(205),132)+chr(185)
		li := li + 1
		@ li, 000 PSAY chr(186)+"Beneficiarios :   "+SPACE(114)+Chr(186)
		li := li + 1
		DbSelectArea("SRB")                // * Movimentacao mensal
		DbSetOrder(1)
		DbSeek(xFilial()+SRA->RA_MAT,.F.)
		Do While !Eof() .and. xFilial() == SRB->RB_FILIAL .And. SRB->RB_MAT == SRA->RA_MAT 
			@ li, 000 PSAY chr(186)+"Nome.: "+LEFT(SRB->RB_NOME+SPACE(40),40)+"Nascimento..: "+DTOC(RB_DTNASC)+SPACE(10)+"Estado Civil..: "+SPACE(10)+"Parentesco..: "+Iif(SRB->RB_GRAUPAR=="F","Filho  ","Conjuge")+SPACE(06)+Chr(186)
			li := li + 1
			DbSelectArea("SRB")
			DbSkip()
		Enddo
		@ li, 000 PSAY chr(204)+REPLICATE(chr(205),132)+chr(185)
		li := li + 1
		//DbSelectArea("SX5")
		//DbSetOrder(1)
		//DbSeek(xFilial()+"28"+SRA->RA_CATFUNC)
		//If Found()
		//	_xCateg:=LEFT(SX5->X5_DESCRI,20)
		//Else
		//	_xCateg:=replicate("?",20)
		//Endif
		_xCateg := Left(FWGetSX5("28", SRA->RA_CATFUNC)[1][4],20)
		If li>58
			Cabec()
		Endif
		@ li, 000 PSAY chr(186)+"Data Admissao.: "+dtoc(SRA->RA_ADMISSA)+SPACE(15)+"Data Opcao FGTS..: "+dtoc(SRA->RA_ADMISSA)+SPACE(30)+"Forma Pagam.: "+_xCateg+SPACE(02)+Chr(186)
		li := li + 1

		DbSelectArea("SRJ")
		DbSetOrder(1)
		DbSeek(xFilial()+SRA->RA_CODFUNC)
		If Found()
			_xFunc:=LEFT(SRJ->RJ_DESC,20)
		Else
			_xFunc:=replicate("?",20)
		Endif
		@ li, 000 PSAY chr(186)+"Cargo.........: "+_xFunc+SPACE(03)+"N§ CBO.........: " + SRA->RA_CBO + SPACE(07) +"Salario..: "+str(_xSal)+SPACE(06)+"Adicional: "+Iif(SRA->RA_INSMED > .00,"Insal 20% ",Iif(SRA->RA_INSMAX > .00,"Insal 40% ","         "))+"             "+Chr(186)
		@ li, 097 PSAY Iif(SRA->RA_PERICUL > .00,"Periculosidade", "              ")+space(22)+Chr(186)
		li := li + 1
		@ li, 000 PSAY chr(204)+REPLICATE(chr(205),132)+chr(185)
		li := li + 1
		//DbSelectArea("SR8")                // * Movimentacao mensal
		//DbSetOrder(1)
		//DbSeek(xFilial()+SRA->RA_MAT,.F.)
		//Do While !Eof() .and. xFilial() == SR8->R8_FILIAL .And. SR8->R8_MAT == SRA->RA_MAT                                                                                                                                          
		//   If SR8->R8_TIPO <> "F"
		//        DbSelectArea("SR8")
		//        DbSkip()
		//        LOOP
		//   Endif
		//           If li>58
		//              Cabec()
		//           Endif
		//           @ li, 000 PSAY chr(186)+"Inicio.: "+dtoc(SR8->R8_DATAINI)+SPACE(20)+"Fim.:"+dtoc(SR8->R8_DATAFIM)+SPACE(82)+Chr(186)
		//           li := li + 1
		//   DbSelectArea("SR8")
		//   DbSkip()
		//Enddo
		//DbSelectArea("SR3")                // * Movimentacao mensal
		//DbSetOrder(1)
		//DbSeek(xFilial()+SRA->RA_MAT,.F.)
		//Do While !Eof() .and. xFilial() == SR3->R3_FILIAL .And. SR3->R3_MAT == SRA->RA_MAT
		//           @ li, 000 PSAY chr(186)+DTOC(SR3->R3_DATA)+SPACE(10)+str(SR3->R3_VALOR)+SPACE(10)+LEFT(SR3->R3_DESCPD,14)+SPACE(77)+Chr(186)
		//           li := li + 1
		//   DbSelectArea("SR3")
		//   DbSkip()
		//Enddo

		//DbSelectArea("SR7")                // * Movimentacao mensal
		//DbSetOrder(1)
		//DbSeek(xFilial()+SRA->RA_MAT,.F.)
		//Do While !Eof() .and. xFilial() == SR7->R7_FILIAL .And. SR7->R7_MAT == SRA->RA_MAT
		//           If li>58
		//              Cabec()
		//           Endif
		//           @ li, 000 PSAY chr(186)+DTOC(SR7->R7_DATA)+SPACE(10)+SR7->R7_DESCFUNC+SPACE(94)+Chr(186)
		//           li := li + 1
		//   DbSelectArea("SR7")
		//   DbSkip()
		//Enddo

		//DbSelectArea("SR8")                // * Movimentacao mensal
		//DbSetOrder(1)
		//DbSeek(xFilial()+SRA->RA_MAT,.F.)
		//Do While !Eof() .and. xFilial() == SR8->R8_FILIAL .And. SR8->R8_MAT == SRA->RA_MAT

		//   DbSelectArea("SX5")
		//   DbSetOrder(1)
		//   DbSeek(xFilial()+"31"+SR8->R8_TIPO)
		//       If Found()
		//         _xAfast:=LEFT(SX5->X5_DESCRI,20)
		//       Else
		//         _xAfast:=replicate("?",20)
		//       Endif
		//           If li>58
		//              Cabec()
		//           Endif
		//           @ li, 000 PSAY chr(186)+DTOC(SR8->R8_DATAINI)+SPACE(15)+DTOC(SR8->R8_DATAFIM)+SPACE(37)+_xAfast+SPACE(44)+Chr(186)
		//           li := li + 1
		//   DbSelectArea("SR8")
		//   DbSkip()
		//Enddo
		DbSelectArea("SR6")
		DbSetOrder(1)
		DbSeek(xFilial()+SRA->RA_TNOTRAB)
		If Found()
			_xTurno:=LEFT(SR6->R6_DESC,35)
		Else
			_xTurno:=replicate("?",35)
		Endif
		@ li, 000 PSAY chr(186)+"Horarios de Trabalho:   "+SPACE(10)+_xTurno+SPACE(63)+Chr(186)
		li := li + 1
		@ li, 000 PSAY chr(204)+REPLICATE(chr(205),132)+chr(185)
		li := li + 1
		@ li, 000 PSAY chr(186)+"Ultimo Exame Medico :   "+SPACE(108)+Chr(186)
		li := li + 1
		@ li, 000 PSAY chr(204)+REPLICATE(chr(205),132)+chr(185)
		li := li + 1
		@ li, 000 PSAY chr(186)+"Vencimento Experiencia :"+Dtoc(SRA->RA_VCTOEXP)+SPACE(100)+Chr(186)
		li := li + 1
		@ li, 000 PSAY chr(204)+REPLICATE(chr(205),132)+chr(185)
		li := li + 1
		@ li, 000 PSAY chr(186)+"Anotacoes Gerais    :   "+SPACE(108)+Chr(186)
		li := li + 1
		@ li, 000 PSAY chr(186)+"                        "+SPACE(108)+Chr(186)
		li := li + 1
		@ li, 000 PSAY chr(186)+"                        "+SPACE(108)+Chr(186)
		li := li + 1
		@ li, 000 PSAY chr(186)+"                        "+SPACE(108)+Chr(186)
		li := li + 1
		@ li, 000 PSAY chr(186)+"                        "+SPACE(108)+Chr(186)
		li := li + 1
		@ li, 000 PSAY chr(186)+"                        "+SPACE(108)+Chr(186)
		li := li + 1
		@ li, 000 PSAY chr(186)+"                        "+SPACE(108)+Chr(186)
		li := li + 1
		@ li, 000 PSAY chr(186)+"                        "+SPACE(108)+Chr(186)
		li := li + 1
		@ li, 000 PSAY chr(186)+"                        "+SPACE(108)+Chr(186)
		li := li + 1
		@ li, 000 PSAY chr(186)+"                        "+SPACE(108)+Chr(186)
		li := li + 1
		@ li, 000 PSAY chr(204)+REPLICATE(chr(205),47)+chr(203)+REPLICATE(chr(205),39)+chr(203)+REPLICATE(chr(205),44)+chr(185)
		li := li + 1
		If li>58
			Cabec()
		Endif
		@ li, 000 PSAY Chr(186)+"Data de Admissao : "+DTOC(SRA->RA_ADMISSA)+SPACE(20)+Chr(186)+SPACE(02)+"Ass do Empregador :"+SPACE(20)+"Ass do Funcionario :"+SPACE(23)+CHR(186)
		li := li + 1
		@ li, 000 PSAY chr(200)+REPLICATE(chr(205),47)+chr(202)+REPLICATE(chr(205),39)+chr(202)+REPLICATE(chr(205),44)+chr(188)
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
// Substituido pelo assistente de conversao do AP5 IDE em 05/07/01 ==> Function ValidPerg
Static Function ValidPerg()
	Local i
	Local j
	cAlias := Alias()
	aRegs  :={}

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


// Substituido pelo assistente de conversao do AP5 IDE em 05/07/01 ==> Function Cabec
Static Function Cabec()
	If _xVez == 1
		@ li, 000 PSAY chr(200)+REPLICATE(chr(205),132)+chr(188)
		li := li + 1
	Endif   
	li:=0
	@ li, 000 PSAY chr(201)+REPLICATE(chr(205),132)+chr(187)
	li := li + 1
	@ li, 000 PSAY chr(186)+"                          FICHA REGISTRO DE FUNCIONARIOS                              Pagina          |"+SPACE(29)+chr(186)
	li := li + 1
	@ LI, 000 PSAY chr(186)+space(02)+"Empresa...:"+LEFT(SM0->M0_NOMECOM+SPACE(40),40)+"                                                 |"+space(29)+chr(186)
	li := li + 1
	@ LI, 000 PSAY chr(186)+space(02)+"Endereco..:"+LEFT(SM0->M0_ENDCOB+SPACE(40),30) +"Numero..:"+space(20)+"Complem........:"+"              |"+space(29)+chr(186)
	li := li + 1
	@ LI, 000 PSAY chr(186)+space(02)+"Bairro....:"+LEFT(SM0->M0_baircob+SPACE(40),30)+"Cidade..:"+LEFT(SM0->M0_CIDCOB+SPACE(30),20)+"Cod.Munic...:"+LEFT(SM0->M0_CODMUN+SPACE(17),17)+"|"+space(29)+chr(186)
	li := li + 1
	@ LI, 000 PSAY chr(186)+space(02)+"Cep.......:"+LEFT(SM0->M0_CEPCOB+SPACE(40),30) +"ESTADO..:"+LEFT(SM0->M0_ESTCOB+SPACE(30),20)+"Ativ.Econom.:"+LEFT(SM0->M0_COD_ATV+SPACE(17),17)+"|"+space(29)+chr(186)
	li := li + 1
	@ LI, 000 PSAY chr(186)+space(02)+"Emissao...:"+LEFT(dtoc(ddatabase),40)+SPACE(22)+"HORA....:"+LEFT(TIME()+SPACE(30),20)+"CNPJ.......:"
	@ LI, 085 PSAY SM0->M0_CGC Picture"@R 99.999.999/9999-99"+"|"+"         Autenticacao        "+chr(186)
	If _xVez==1
		li := li + 1
		@ li, 000 PSAY chr(204)+REPLICATE(chr(205),132)+chr(185)
		li := li + 1
	Endif
	_xVez:=1
Return
