#INCLUDE "rwmake.ch"
#INCLUDE "topconn.ch"

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³FBF22     º Autor Flávio  º Data ³  27/10/10                º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDescricao ³ Relatório de Departamentos								  º±±
±±º          ³                                                            º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ AP6 IDE                                                    º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/

User Function FBF22()

	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Declaracao de Variaveis                                             ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ

	Local cDesc1         := "Este programa tem como objetivo imprimir relatorio "
	Local cDesc2         := "Funcionarios , subdividindo por Departamentos"
	Local cDesc3         := ""
	Local cPict          := ""
	Local titulo         := "Novo - Departamentos"
	Local nLin           := 75

	Local Cabec1         := "   Matr.  Nome                                  DT ADMIS.     Função                            Salário        Status"
	Local Cabec2         := "                  "
	Local Cabec3         := " "
	Local imprime        := .T.
	Local aOrd           := {}
	Private lEnd         := .F.
	Private lAbortPrint  := .F.
	Private CbTxt        := ""
	Private limite       := 132
	Private tamanho      := "M"
	Private nomeprog     := "FBF22" // Coloque aqui o nome do programa para impressao no cabecalho
	Private nTipo        := 18
	Private aReturn      := { "Zebrado", 1, "Administracao", 2, 2, 1, "", 1}
	Private nLastKey     := 0
	Private cPerg        := "FBF22"
	Private cbtxt        := Space(10)
	Private cbcont       := 00
	Private CONTFL       := 01
	Private m_pag        := 01
	Private wnrel        := "FBF22" // Coloque aqui o nome do arquivo usado para impressao em disco
	Private cString 	 	:= "FUN"
	Private _cCentro	 	:= ''
	Private _cDepto		:= ''
	Private _cFuncao	   := '' 
	Private _cDepartamento:=''
	Private _cNdepto     :=''
	Private _nTotCC       := 0
	Private _nTotDEPTO    := 0
	Private _nTotal       := 0
	Private _cTotpess 	 :=0
	Private _cTotpescc 	 :=0
	Private _cTPG		 	 :=0


	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³  Variaveis utilizadas para parametros                                  ³
	//³  mv_par01            //     Busca do Centro de custo                   ³
	//³  mv_par02            //     ao Centro de custo                         ³
	//³  mv_par03            //     Da Matrícula                               ³
	//³  mv_par04            //     A Matrícula                                ³
	//³  mv_par05            //     Do Nome                                    ³
	//³  mv-par06            //     Ao Nome                                    ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ

	dbSelectArea("SRA")

	pergunte(cPerg,.F.)

	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Monta a interface padrao com o usuario...                           ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ

	wnrel := SetPrint('SRA',NomeProg,cPerg,@titulo,cDesc1,cDesc2,cDesc3,.T.,aOrd,.T.,Tamanho,,.T.)


	/***********QUERY***************/ 
	// Falta a questão dos departamentos
	cQuery := " SELECT RA_MAT AS MATRICULA, RA_NOME AS NOME, RA_ADMISSA AS ADMISSAO,RA_CODFUNC AS FUNCAO, RA_SALARIO AS SALARIO,"
	cQuery += " I3_DESC AS CENTRO,RA_SITFOLH AS SIT  , RA_DEP2 AS DEPTO, RA_CC AS CC, RA_SITFOLH AS SITUACAO" 
	cQuery += " FROM " + RetSqlName("SRA") + " , " + RetSqlName("SI3") 
	cQuery += " WHERE SRA010.D_E_L_E_T_ <> '*' AND " 
	cQuery += " 		SI3010.D_E_L_E_T_ <> '*' AND "
	cQuery += " RA_FILIAL = '" + xFilial("SRA") + "' AND"
	cQuery += " I3_FILIAL = '" + xFilial("SI3") + "' AND"
	cQuery += " RA_CC = I3_CUSTO 		AND" 
	cQuery += " RA_SITFOLH <> 'D' 	AND"  
	cQuery += " RA_CC >= '"+mv_par01+"' AND RA_CC <='"+mv_par02+"' AND"
	cQuery += " RA_MAT >= '"+mv_par03+"' AND RA_MAT <='"+mv_par04+"' AND"
	cQuery += " RA_NOME >= '"+mv_par05+"' AND RA_NOME <='"+mv_par06+"' "
	cQuery += " ORDER BY RA_CC,RA_DEP2, RA_NOME" 

	cQuery := ChangeQuery(cQuery)

	//	* Mostrar a consulta */
	//@ 116,090 To 416,707 Dialog oDlgMemo Title "Consulta"
	//@ 055,005 Get cQuery Size 250,080 MEMO Object oMemo
	//Activate Dialog oDlgMemo



	/*************FIM QUERY********************/


	If Select("FUN") != 0
		dbCloseArea()
	Endif

	TCQUERY cQuery NEW ALIAS "FUN"


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



	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ SETREGUA -> Indica quantos registros serao processados para a regua ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ

	FUN->(dbGoTop())

	FUN->(SetRegua(RecCount()))


	While !EOF() 
		incregua()  

		If nLin > 70 
			Cabec(Titulo,Cabec1,Cabec2,NomeProg,Tamanho,nTipo)
			nLin := 8
		endif 

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

		If nLin > 70 
			Cabec(Titulo,Cabec1,Cabec2,NomeProg,Tamanho,nTipo)
			nLin := 8
		endif 

		if _cCentro <> FUN->CC 
			if _nTotDEPTO <> 0
				nLin++  
				@nLin,50 psay 'TOTAL Depto:'
				@nLin,89 psay transform(_nTotDEPTO,'@E 999,999,999.99')
				nLin++
				@nLin,50 psay 'TOT Pessoas:'
				@nLin,100 psay _cTotpess 
				nLin++
				_nTotal 		+= _nTotDEPTO 
				_nTotCC 		+= _nTotDEPTO	
				_cTotpescc	+= _cTotpess 
				_cTPG 		+= _cTotpess
				_nTotDEPTO 	:= 0 
				_cTotpess 	:=0
			endif 
			if _nTotCC <> 0
				nLin++  
				@nLin,79 psay 'TOTAL CC:'
				@nLin,89 psay transform(_nTotCC,'@E 999,999,999.99')
				nLin++ 
				@nLin,50 psay 'TOT Pessoas CC:'
				@nLin,100 psay _cTotpescc
				nLin++ 		
				_nTotal 		+= _nTotDEPTO
				_cTPG 		+= _cTotpess 	
				_nTotDEPTO := 0
				_nTotCC    := 0 
				_cTotpescc := 0
			endif


			nLin++     
			@nLin,6 psay 'CENTRO CUSTO: '+FUN->CENTRO
			_cCentro := FUN->CC
			nLin++	
		endif  

		if _cDepto <> FUN->DEPTO

			if _nTotDEPTO <> 0
				nLin++  
				@nLin,50 psay 'TOTAL Depto:'
				@nLin,89 psay transform(_nTotDEPTO,'@E 999,999,999.99')
				nLin++
				@nLin,50 psay 'Pessoas Depto:'
				@nLin,100 psay _cTotpess 
				nLin++
				_nTotal 		+= _nTotDEPTO 
				_nTotCC 		+= _nTotDEPTO
				_cTotpescc 	+=_cTotpess
				_cTPG 		+= _cTotpess
				_cTotpess 	:= 0	
				_nTotDEPTO 	:= 0 
			endif   

			_cNdepto :=fBuscaCPO('SZJ',1,xfilial('SZJ') +FUN->DEPTO,'ZJ_DESC')
			@nLin,25 psay 'DEPTO: '+_cNdepto
			_cDepto := FUN->DEPTO
			nLin++	
		endif       
		/*BUSCA DAS FUNCOES */   
		_cFuncao :=fBuscaCPO('SRJ',1,xfilial('SRJ') +FUN->FUNCAO,'RJ_DESC')

		@nLin,03 psay FUN->MATRICULA 
		@nLin,11 psay substr(FUN->NOME,1,40)
		@nLin,55 psay STOD(FUN->ADMISSAO)
		@nLin,67 psay substr(_cFuncao,1,20) 
		@nLin,89 psay transform(FUN->SALARIO,'@E 999,999,999.99')	 

		do case
			case FUN->SITUACAO = 'A'
			@nLin,109 psay 'AFASTADO'
			case FUN->SITUACAO = 'D'
			@nLin,109 psay 'DEMITIDO'
			case FUN->SITUACAO = 'F'
			@nLin,109 psay 'EM FERIAS'
			case FUN->SITUACAO = 'T'
			@nLin,109 psay 'TRANSFERIDO'
			otherwise

		endcase  

		//@nLin,109 psay FUN->SITUACAO     

		_nTotDEPTO += FUN->SALARIO
		_cTotpess++   
		nLin++

		FUN->(dbSkip()) // Avanca o ponteiro do registro no arquivo
	EndDo  

	nLin++  
	@nLin,60 psay 'TOTAL CC:'
	@nLin,89 psay transform(_nTotDEPTO,'@E 999,999,999.99')
	nLin++ 
	@nLin,60 psay 'TOT Pessoas CC:'
	@nLin,100 psay _cTotpescc
	nLin++  
	_cTPG	+=	_cTotpescc


	nLin	+=	5   
	@nLin,60 psay 'TOTAL :'
	@nLin,89 psay transform(_nTotal,'@E 999,999,999.99')
	nLin++   
	@nLin,60 psay 'TOTAL Pessoas :'
	@nLin,93 psay _cTPG


	DbCloseArea('FUN')
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

