#INCLUDE "rwmake.ch"
#INCLUDE "topconn.ch"


/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³DTI28     ºAutor  ³Flávio Bohrer Flôresº Data ³  20/03/17   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³ Geração dos comprovantes de Pagamento dos Arquivos vindos  º±±
±±º          ³ Da Caixa Federal                              			  º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ Financeiro			                                       º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/  


User Function DTI28()


	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Declaracao de Variaveis                                             ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ

	Local cDesc1         := "Este programa tem como objetivo imprimir os comprovante de  Pagamento"
	Local cDesc2         := "Conforme arquivo de retorno da Folha de Pagamento pelo banco Caixa."
	Local cDesc3         := ""
	Local cPict          := ""
	Local titulo       	 := "GERAÇÃO DE COMPROVANTES DE PAGAMENTOS"
	Local nLin         	 := 80

	Local Cabec1         := ""
	Local Cabec2         := ""
	Local _aArqTrb       := {}

	Local imprime        := .T.
	Local aOrd           := {}
	Private lEnd         := .F.
	Private lAbortPrint := .F.
	Private CbTxt       := ""
	Private limite      := 132
	Private tamanho     := "M"
	Private nomeprog    := "DTI28" 
	Private nTipo       := 18
	Private aReturn     := { "Zebrado", 1, "Administracao", 2, 2, 1, "", 1}
	Private nLastKey    := 0
	Private cPerg   	  := "DTI28"
	Private cbtxt       := Space(10)
	Private cbcont      := 00
	Private CONTFL      := 01
	Private m_pag       := 01
	Private wnrel       := "DTI28"    
	Private _aClassif   := {}
	Private aStru    		:= {}
	Private aCampos  		:= {}
	Private cArq
	Private cString := "SRA" 
	Private _cImpresso 	:= 'N'
	pergunte(cPerg,.F.)


	wnrel := SetPrint(cString,NomeProg,cPerg,@titulo,cDesc1,cDesc2,cDesc3,.T.,aOrd,.T.,Tamanho,,.T.)


	If nLastKey == 27
		Return
	Endif

	SetDefault(aReturn,'TMP')

	If nLastKey == 27
		Return
	Endif

	nTipo := If(aReturn[4]==1,15,18)

	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Processamento. RPTSTATUS monta janela com a regua de processamento. ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ

	RptStatus({|| RunReport(Cabec1,Cabec2,Titulo,nLin) },Titulo)
	
	// ProcData 04/2023 - Chamada para fechar arquivo de trabalho
	u_arqtrb ("FechaTodos",,,, @_aArqTrb) 
Return

Static Function RunReport(Cabec1,Cabec2,Titulo,nLin)

	Local nOrdem  


	MsgRun("Aguarde... Realizando contagem de registros...",,{||  GeraTMP() })                              
	Processa({|| _lOk := importa(mv_par01)},"PROCESSAMENTO DE REGISTROS","Importando arquivo de refeições...")
	//_cNomeArq := retFileName(mv_par01)
	//frename(mv_par01,'C:\relsiga\arquivo__'+_cNomeArq+'_processado.ret')


	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ SETREGUA -> Indica quantos registros serao processados para a regua ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ

	TMP->(dbGoTop())
	TMP->(SetRegua(RecCount()))


	While TMP->(!EOF())

		incregua()

		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³ Verifica o cancelamento pelo usuario...                             ³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ

		If lAbortPrint
			@nLin,00 PSAY "*** CANCELADO PELO OPERADOR ***"
			Exit
		Endif


		If nLin > 75 // Salto de Página. Neste caso o formulario tem 75 linhas...
			Cabec(Titulo,Cabec1,Cabec2,NomeProg,Tamanho,nTipo)
			nLin := 6
		Endif   

		If  alltrim(TMP->MATRICULA) < alltrim(mv_par02) .or. alltrim(TMP->MATRICULA) > alltrim(mv_par03)  
			TMP->(dbSkip())  
			loop		
		Endif

		If _cImpresso == 'N'
			
			//@nlin,05 psay  "BANCO "+TMP->BANCO+" - CAIXA ECONÔMICA FEDERAL" 
			_cDesc  := fBuscaCPO('SA6',1,xfilial('SA6')+alltrim(TMP->BANCO),'A6_NOME')
			@nlin,05 psay  "BANCO "+TMP->BANCO+" - "+_cDesc
			nlin++
			@nlin,05 psay "Empresa - "+substr(TMP->EMPRESA,1,2)+'.'+substr(TMP->EMPRESA,3,3)+'.'+substr(TMP->EMPRESA,6,3)+'.'+substr(TMP->EMPRESA,10,3)+'/'+substr(TMP->EMPRESA,13,2)+" - "+TMP->NOMEEMP
			nlin+=3
			_cImpresso := 'S'
		Endif	                                                                 

		@nlin,05 psay replicate('_',120)
		nlin++
		@nlin,55 psay "*** RECIBO DE PAGAMENTO ***"
		nlin++
		@nlin,12 psay "Matricula: "+space(8)+TMP->MATRICULA  
		nlin++
		@nlin,12 psay "Nome Favorecido: "+space(5)+TMP->NOME
		nlin++
		@nlin,12 psay "Data Pagamento: "+space(3)+DTOC(TMP->DATAV)
		nlin++
		@nlin,12 psay "Valor Pagamento R$"+transform((val(TMP->VALOR)/100), "@E 999,999.99" )  	
		nlin++	     
		@nlin,12 psay "Ag: "+space(15)+TMP->AG
		nlin++
		@nlin,12 psay "Conta: "+space(12)+TMP->CONTA

		nlin++
		TMP->(dbSkip())

	EndDo    

	DbCloseArea('TMP')

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

Static Function GeraTMP() 
	Local _aArqTrb    := {} 

	aadd(aCampos,{"BANCO" 			,"Banco"						,""})
	aadd(aCampos,{"EMPRESA" 		,"Empresa" 					,""})
	aadd(aCampos,{"NOMEEMP" 		,"NomeEmpresa"				,""})
	aadd(aCampos,{"MATRICULA" 		,"Matrícula"				,""})
	aadd(aCampos,{"NOME"  			,"Nome"						,""}) 
	aadd(aCampos,{"DATAV"  			,"Data"						,"99/99/99"})  
	aadd(aCampos,{"VALOR"  			,"Valor"						,""})
	aadd(aCampos,{"AG"  				,"Agencia"					,""})
	aadd(aCampos,{"CONTA"  			,"Conta"	   				,""})         


	aadd(aStru,{"BANCO" 	, "C",  03,  0,	"@!"        	 	, 'Banco'   	 })
	aadd(aStru,{"EMPRESA" 	, "C",  14,  0,   "@!"        	 	, 'Empresa'   	 })
	aadd(aStru,{"NOMEEMP" 	, "C",  28,  0,   "@!"        	 	, 'NomeEmpresa' })
	aadd(aStru,{"MATRICULA" , "C",  06,  0,   "@!"        	 	, 'Matrícula'   })
	aadd(aStru,{"NOME"   	, "C",  30,  0,   "@!"         		, 'Nome'        })
	aadd(aStru,{"DATAV"   	, "D",  08,  0,   "99/99/99"        , 'Data'    	 })
	aadd(aStru,{"VALOR"  	, "C",  30,  0,   "@!"         		, 'Valor' 		 })
	aadd(aStru,{"AG" 			, "C",  07,  0,   "@!"  				, 'Agencia'     })
	aadd(aStru,{"CONTA" 		, "C",  10,  0,   "@!"  				, 'Conta'       })
	
	If Select("TMP") != 0
		TMP->(DbCloseArea())
		U_ArqTrb("FechaTodos",,,,@_aArqTrb)		
	endif

	U_ArqTrb("Cria", "TMP", aStru, {}, @_aArqTrb)
	
	DbSelectArea('TMP')
	TMP->(DbGoTop())
	//IndRegua("TMP",cArq,"MATRICULA+NOME",,,OemToAnsi("Selecionando Registros..."))

return

Static Function Importa(cArquivo)
	Local aCabec  := {}  
	Local aItens  := {}
	Local aCliente:= {}
	Local aFornece:= {}
	Local nCont   := 0	
	LOCAL nHdl:= nHdlA := 0
	Local nX
	Local nTamFile, nTamLin, cBuffer, nBtLidos
	Local lExiste := .T.
	Local lHabil  := .F.
	Private nHdl  := 0
	Private cEOL  := "CHR(8)"
	Private _cCabec1 := ''
	Private _cMatricula  := ''	
	Private _cNome := ''
	Private _cEntrou := ''
	Private _cBanco := ''
	Private _cEmpresa := ''
	Private _cNomeemp := ''

	If Empty(Alltrim(cArquivo))
		Alert("Nao existem arquivos para importar. Processo ABORTADO")
		Return.F.	
	EndIf

	//+---------------------------------------------------------------------+
	//| Abertura do arquivo texto                                           |
	//+---------------------------------------------------------------------+
	cArqTxt := cArquivo

	nHdl := fOpen(cArqTxt,0 )
	IF nHdl == -1
		IF FERROR()== 516
			ALERT("Feche o programa que gerou o arquivo.")
		EndIF
	EndIf

	//+---------------------------------------------------------------------+
	//| Verifica se foi possível abrir o arquivo                            |
	//+---------------------------------------------------------------------+
	If nHdl == -1
		MsgAlert("O arquivo de nome "+cArquivo+" nao pode ser aberto! Verifique os parametros.","Atencao!" )
		Return
	Endif

	FSEEK(nHdl,0,0 )
	nTamArq:=FSEEK(nHdl,0,2 )
	FSEEK(nHdl,0,0 )
	fClose(nHdl)

	FT_FUse(cArquivo )  //abre o arquivo
	FT_FGoTop()         //posiciona na primeira linha do arquivo
	nTamLinha := Len(FT_FREADLN() ) //Ve o tamanho da linha
	FT_FGOTOP()

	//+---------------------------------------------------------------------+
	//| Verifica quantas linhas tem o arquivo                               |
	//+---------------------------------------------------------------------+
	nLinhas := FT_FLastRec() 

	ProcRegua(nLinhas)

	While !FT_FEOF()        		
		IF nCont > nLinhas
			exit
		endif   

		IncProc("Lendo arquivo texto...Linha "+Alltrim(str(nCont)))

		cLinha := Alltrim(FT_FReadLn())
		nRecno := FT_FRecno() // Retorna a linha corrente
		_cMatricula	:= ''
		_cNome 	:= '' 
		_cCabec1 := substr(cLinha,14,1)
		// Escrever o Banco e empresa
		If _cCabec1 == '0' .and. _cEntrou <> '1' 	
			_cBanco 	:= substr(cLinha,1,3)+' - Caixa'
			_cEmpresa := substr(cLinha,19,14)
			_cNomeemp := substr(cLinha,73,28)
			_cEntrou = '1'	  	
		endif


		if !empty(cLinha )           

			If _cCabec1 == 'A'

				_cMatricula	:= substr(cLinha,74,6)
				_cNome 		:= substr(cLinha,44,30)                           
				_cDia 		:= substr(cLinha,94,2)
				_cMes 		:= substr(cLinha,96,2)
				_cAno 		:= substr(cLinha,98,4)
				_dData  		:=  CTOD(_cDia+'/'+_cMes+'/'+_cAno)
				_cValor		:= substr(cLinha,105,30)
				_cAg			:=	substr(cLinha,24,5)+'-'+substr(cLinha,29,1)
				_cConta		:= substr(cLinha,35,8)+'-'+substr(cLinha,42,1)

				reclock('TMP',.t.)

				TMP->BANCO		 	:= _cBanco 
				TMP->EMPRESA	 	:= _cEmpresa
				TMP->NOMEEMP	 	:= _cNomeemp 
				TMP->MATRICULA 		:= _cMatricula    
				TMP->NOME			:= _cNome
				TMP->DATAV			:= _dData
				TMP->VALOR			:= _cValor
				TMP->AG				:= _cAg
				TMP->CONTA			:= _cConta

				msunlock()

			Endif

		Endif

		FT_FSKIP()  
		nCont++
	EndDo		

	FT_FUSE()
	fClose(nHdl )
Return .t.
