#INCLUDE "rwmake.ch"
#INCLUDE "topconn.ch"

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³MLR15    º Autor ³ Mauricio Roehrs º Data ³ 01/04/2015      º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDescricao ³ Relatorio para conferencia de vales-transporte             º±±
±±º          ³                                                            º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ Gestão de Pessoal		                                      º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/

User Function MLR42()


	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Declaracao de Variaveis                                             ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ

	Local cDesc1         := "Este programa tem como objetivo imprimir relatorio"
	Local cDesc2         := "para conferencia dos valores de vales-transporte."
	Local cDesc3         := ""
	Local cPict          := "vai porra"
	Local titulo         := "RELATORIO PARA CONF. DE VALES TRANSPORTE"
	Local Cabec1         := ""
	Local Cabec2         := "        Matricula            Nome do Funcionario          Centro de Custo    Valor em Vales     Valor Descontado"
	Local imprime         := .T.
	Local aOrd            := {}  
	Private nLin           := 80
	Private lEnd          := .F.
	Private lAbortPrint   := .F.
	Private CbTxt         := ""
	Private limite        := 80
	Private tamanho       := "M"
	Private nomeprog      := "MLR42" // Coloque aqui o nome do programa para impressao no cabecalho
	Private nTipo         := 18
	Private aReturn       := { "Zebrado", 1, "Administracao", 2, 2, 1, "", 1}
	Private nLastKey      := 0
	Private cPerg   		 := "MLR42"
	Private cbtxt      	:= Space(10)
	Private cbcont     := 00
	Private CONTFL     := 01
	Private m_pag      := 01
	Private wnrel      := "MLR42" // Coloque aqui o nome do arquivo usado para impressao em disco    
	Private _aBatidas  := {}
	pergunte(cPerg,.F.)

	cabec1 += 'Mes/Ano de Referencia: ' + mv_par01 + '/' + mv_par02

	wnrel := SetPrint('ZZQ',NomeProg,cPerg,@titulo,cDesc1,cDesc2,cDesc3,.T.,aOrd,.T.,Tamanho,,.T.)  

	_cQuery := " SELECT ZZQ_MAT, ZZQ_VLVAL, ZZQ_TPVAL, ZZQ_MES, ZZQ_ANO, RA_NOMECMP, RA_CC,RA_SALARIO"
	_cQuery += " FROM " + retSqlTab('ZZQ') + " , " +retSqlTab('SRA')
	_cQuery += " WHERE " + retSqlFil('ZZQ') + " AND " + retSqlFil('SRA')
	_cQuery += " AND ZZQ_MES = '" +mv_par01+"' AND ZZQ_ANO = '"+mv_par02+"' AND RA_MAT = ZZQ_MAT"

	if mv_par03 <> 5 .and. mv_par03 <> 4
		_cQuery += " AND ZZQ_TPVAL = "+iif(mv_par03=1,"'A'",;
										iif(mv_par03=3,"'S'",;
										iif(mv_par03=2,"'F'",;
										iif(mv_par04=1,"'V'",;
										iif(mv_par04=2,"'T'","''")))))
				
		//iif(mv_par03=1,"'A'",;		
		//iif(mv_par03=3,"'S'",;
		//iif(mv_par03=2,"'F'","''")))											 
	elseif mv_par03= 4											 	
		_cQuery += " AND ZZQ_TPVAL IN ('V','B')"					  															 
	endif        

	_cQuery += " AND " + retSqlDel('ZZQ') + " AND " + retSqlDel('SRA')      
	
	if mv_par05 = 1
		_cQuery += " ORDER BY ZZQ_TPVAL, ZZQ_MAT, RA_NOMECMP, RA_CC"
	else
		_cQuery += " ORDER BY ZZQ_TPVAL, RA_CC, RA_NOMECMP, ZZQ_MAT"
	endif

	_cQuery  := ChangeQuery(_cQuery)

	//	* Mostrar a consulta */
	//@ 116,090 To 416,707 Dialog oDlgMemo Title "Consulta"
	//@ 055,005 Get _cQuery Size 250,080 MEMO Object oMemo
	//Activate Dialog oDlgMemo

	MsgRun("Aguarde... Realizando contagem de registros...",,{||  GeraTMP() })

	If nLastKey == 27
		Return
	Endif

	SetDefault(aReturn,'ZZQ')

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

	Local nOrdem

	Cabec(Titulo,Cabec1,Cabec2,NomeProg,Tamanho,nTipo)
	nLin := 9


	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ SETREGUA -> Indica quantos registros serao processados para a regua ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ

	TMP->(SetRegua(RecCount()))

	TMP->(dbGoTop())

	_cTpVal   := ""       
	_cDscTp   := ""
	_nTotVal  := 0   
	_nTotDsc  := 0
	_nVlDsc   := 0 
	_nTotFunc := 0


	While TMP->(!EOF())

		incregua()

		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³ Verifica o cancelamento pelo usuario...                             ³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ

		If lAbortPrint
			@nLin,00 PSAY "*** CANCELADO PELO OPERADOR ***"
			Exit
		Endif

		If nLin > 70 // Salto de Página. Neste caso o formulario tem 55 linhas...
			Cabec(Titulo,Cabec1,Cabec2,NomeProg,Tamanho,nTipo)
			nLin := 9
		Endif

		if _cTpVal <> TMP->ZZQ_TPVAL
			_cDscTp := iif(TMP->ZZQ_TPVAL = 'A','ATU',;
			iif(TMP->ZZQ_TPVAL = 'S','SAO SEPE',;
			iif(TMP->ZZQ_TPVAL = 'F','FORMIGUEIRO',;
			iif(TMP->ZZQ_TPVAL = 'V','Fretado',;
			iif(TMP->ZZQ_TPVAL = 'T','ATU/Fretado',;
			iif(TMP->ZZQ_TPVAL = 'B','VILA BLOCK',''))))))					                                  					
			@nlin,05 psay "Valores Referente a: "+_cDscTp		
			nlin++                                        
			@nlin,01 psay replicate('_',132)
			nlin++	
			_cTpVal := TMP->ZZQ_TPVAL 			
		endif	 	 	                       

		_nPercDesc := fBuscaCpo('SRV',1,xFilial('SRV') + '493','RV_PERC')/*Busca o percentual de desconto no cadastro de verbas*/
		_nPercSal  := TMP->RA_SALARIO * (_nPercDesc / 100) /*Calcula 6% do salario*/

		/*calculo para valor descontado do funcionario*/
		if _nPercSal > TMP->ZZQ_VLVAL 
			_nVlDsc := TMP->ZZQ_VLVAL
		else             
			_nVlDsc := _nPercSal
		endif

		@nlin,10 psay TMP->ZZQ_MAT
		@nlin,25 psay substr(TMP->RA_NOMECMP,1,25)	
		@nlin,60 psay TMP->RA_CC
		@nlin,80 psay transform(TMP->ZZQ_VLVAL,'@E 999.99') 
		@nlin,95 psay transform(_nVlDsc,'@E 999.99')
		nlin++

		_nTotVal += TMP->ZZQ_VLVAL 				 				
		_nTotDsc += _nVlDsc
		_nTotFunc ++

		TMP->(dbSkip()) // Avanca o ponteiro do registro no arquivo

		if _cTpVal <> TMP->ZZQ_TPVAL .or. TMP->(eof())   
			nlin++
			@nlin,65 psay "TOTAL CREDITADO:       " + transform(_nTotVal,'@E 999,999,999.99')		
			nlin++
			@nlin,65 psay "TOTAL DESCONTADO:      " + transform(_nTotDsc,'@E 999,999,999.99')
			nlin++
			@nlin,65 psay "TOTAL DE FUNCIONARIOS: " + transform(_nTotFunc,'@E 999,999,999.99')
			nlin+=2
			_nTotVal  := 0                                            
			_nTotDsc  := 0
			_nTotFunc := 0
		endif

	EndDo 


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


Static Function GeraTMP()   

	_cQuery  := ChangeQuery(_cQuery)

	If Select("TMP") != 0
		TMP->(dbCloseArea())
	Endif

	TCQUERY _cQuery NEW ALIAS "TMP"

return
