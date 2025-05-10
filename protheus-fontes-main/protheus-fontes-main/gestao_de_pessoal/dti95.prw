#INCLUDE "rwmake.ch"
#INCLUDE "topconn.ch"

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³DTI95    º Autor ³ Flávio Bohrer  em    05/03/20            º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDescricao ³ Relatório de total de Funcionarios  Afastados              º±±
±±º          ³                                                            º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ DP/RH		    	                                      º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/

User Function DTI95()

	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄSÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Declaracao de Variaveis                                             ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ

	Local cDesc1         := "Este programa tem como objetivo imprimir relatorio"
	Local cDesc2         := "de Funcionário Afastados "
	Local cDesc3         := ""
	Local cPict          := ""
	Local titulo         := "FUNCIONARIO AFASTADOS QUE NÂO ESTÂO EM FÉRIAS"
	Local Cabec1         := "    Matricula        Nome       "
	Local Cabec2         := ""
	Local imprime        := .T.
	Local aOrd           := {}
	Local nS
	Private nLin         := 80
	Private lEnd         := .F.
	Private lAbortPrint  := .F.
	Private CbTxt        := ""
	Private limite       := 132
	Private tamanho      := "M"
	Private nomeprog     := "DTI95" // Coloque aqui o nome do programa para impressao no cabecalho
	Private nTipo        := 18
	Private aReturn      := { "Zebrado", 1, "Administracao", 2, 2, 1, "", 1}
	Private nLastKey     := 0
	Private cPerg   	 := "DTI95"
	Private cbtxt      	 := Space(10)
	Private cbcont       := 00
	Private CONTFL       := 01
	Private m_pag        := 01
	Private wnrel        := "DTI95" // Coloque aqui o nome do arquivo usado para impressao em disco
	Private _aPrd 		 := {}
	Private mvp01 := ''
	Private mvp02 := ''
	Private cCatQuery
	Private cSitQuery
	
	
	
	
	pergunte(cPerg,.F.)

	wnrel := SetPrint('SRA',NomeProg,cPerg,@titulo,cDesc1,cDesc2,cDesc3,.T.,aOrd,.T.,Tamanho,,.T.)

	_cSituacao  := mv_par03
	_cCategoria := mv_par04    
	mvp01 := mv_par01
	mvp02 := mv_par02
	
	cSitQuery := ""
	For nS:=1 to Len(_cSituacao)
		cSitQuery += "'"+Subs(_cSituacao,nS,1)+"'"
		If ( nS+1) <= Len(_cSituacao)
			cSitQuery += "," 
		Endif
	Next nS        

	cCatQuery := ""
	For nS:=1 to Len(_cCategoria)
		cCatQuery += "'"+Subs(_cCategoria,nS,1)+"'"
		If ( nS+1) <= Len(_cCategoria)
			cCatQuery += "," 
		Endif
	Next nS


	_cQuery := " SELECT R8_MAT,R8_TIPOAFA, RA_NOME "
	_cQuery += " FROM "  + retSqlTab('SR8') + ", "+ retSqlTab('SRA')
	_cQuery += " WHERE " + retSqlFil('SR8') + " AND "+ retSqlFil('SRA')
	_cQuery += " AND RA_MAT BETWEEN '" + mv_par01+"' AND '" + mv_par02 + "'"
	_cQuery += " AND R8_MAT = RA_MAT"
	_cQuery += " AND R8_TIPOAFA <> '001'"
	_cQuery += " AND RA_CATFUNC IN (" + Upper(cCatQuery) + ")" 
	_cQuery += " AND RA_SITFOLH IN (" + Upper(cSitQuery) + ")"	
	_cQuery += " AND "+retSqlDel('SR8')+" AND "+ retSqlDel('SRA')
	_cQuery += " ORDER BY R8_MAT, RA_NOME


	_cQuery  := ChangeQuery(_cQuery)
	//_cQuery += " AND R8_TIPOAFA NOT IN ('001')"
	//	* Mostrar a consulta */
	//@ 116,090 To 416,707 Dialog oDlgMemo Title "Consulta"
	//@ 055,005 Get _cQuery Size 250,080 MEMO Object oMemo
	//Activate Dialog oDlgMemo

	MsgRun("Aguarde... Realizando contagem de registros...",,{||  GeraTMP() })

	If nLastKey == 27
		Return
	Endif

	SetDefault(aReturn,'SRA')

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
	Local _aArqTrb      := {} // ProcData 04/2023
	Local nOrdem
	Local nCont := 0
	Local cMat := ''
	Local cArqTrb, cIndice1
	
	Cabec(Titulo,Cabec1,Cabec2,NomeProg,Tamanho,nTipo)
	nLin := 9

	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ SETREGUA -> Indica quantos registros serao processados para a regua ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ

	TMP->(SetRegua(RecCount()))

	TMP->(dbGoTop())

	_cLin  := ''
	_cProd := ''
	

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
		
		// Se funcionário não esta em férias  R8_TIPOAFA <> '001'
		If alltrim(cMat) <> alltrim(TMP->R8_MAT)
			
			@nlin,05 psay TMP->R8_MAT
			@nlin,13 psay substr(TMP->RA_NOME,1,35)
			
			nCont++
			nlin++
			cMat := TMP->R8_MAT
				
		Endif


		TMP->(dbSkip()) // Avanca o ponteiro do registro no arquivo

	EndDo
	
	nLin+5
	
	@nlin,12 psay 'Total de:'
	@nlin,23 psay transform(nCont,'@E 9999')
	@nlin,30 psay 'Funcionários Afastados'
	
	
	//SELECT R8_MAT,R8_TIPOAFA, RA_NOME	
	//Inicio da Criação da tabela TMP3 - temporária para armazenar o somatório dos TIPOAFAs
	
	
	//cArq  := CriaTrab( Nil, .F. )
	aStru := dbStruct()                                                           
	aadd(aStru,{"MAT"  , "C", 6, 0,   "" , 'Matricula ' })
	aadd(aStru,{"TIPOAFA" , "C", 3,  0,   "" , 'TIPO_AFA'})
	aadd(aStru,{"QUANT" , "C", 4,  0,   "" , 'Somatório'})
	
	//dbcreate(cArq,aStru)  
    // ProcData 04/2023 - Chamada para criação do arquivo de trabalho
	U_ArqTrb("Cria", "TMP3", aStru, {"TIPOAFA"}, @_aArqTrb) 	
	
	//Definir indices da tabela
	//cIndice1 := Alltrim(CriaTrab(,.F.))	
	//cIndice1 := Left(cIndice1,5)+Right(cIndice1,2)+"A"
	//If File(cIndice1+OrdBagExt())
	//	FErase(cIndice1+OrdBagExt())
	//EndIf
	
	If Select('TMP3')<>0                                                           //Se um tmp com alias TMP existir, fecha-o
		TMP3->(dbCloseArea())
	Endif
	//Manda usar o TMP
	//dbUseArea( .T.,,cArq,"TMP3", .F. , .F. )
	
	/*Criar indice*/
	//IndRegua("TMP3", cIndice1,"TIPOAFA",,,"Indice TIPOAFA...")
	//dbClearIndex()
	//dbSetIndex(cIndice1+OrdBagExt())
	
	//Fim da Criação da tabela TMP3 - temporária para armazenar o somatório dos TIPOAFAs	
		
		
		
	cntMot := 0 
	cTipoAfa:=''
	
	/*
	nCont2 := 0
	GeraTMP2(mvp01,mvp02,cCatQuery,cSitQuery)
	// Somatório de todos os motivos de Afastamento R8_TIPOAFA 
	//Aqui contabiliza e salva em uma TMP3
	TMP2->(dbGoTop())
	
	While TMP2->(!EOF()) 
		
		if nCont2 = 0 
			//TMP2->(dbseek(TMP2->R8_TIPOAFA+TMP2->R8_MAT,.t.))
			cTipoAfa := TMP2->R8_TIPOAFA
			nCont2 ++
		endif
		IF  TMP2->R8_TIPOAFA <> cTipoAfa
			reclock('TMP3',.t.) 
		 		TMP3->MAT     := TMP2->R8_MAT		
		 		TMP3->TIPOAFA := TMP2->R8_TIPOAFA
		 		TMP3->QUANT	  := str(nCont2)
			msunlock()
			cTipoAfa := TMP2->R8_TIPOAFA
			nCont2 := 0 
		Endif
		nCont2++
		TMP2->(dbSkip())
	EndDo
	TMP->(dbgotop()) 
	//  Aqui imprime o TMP3
	TMP3->(dbGoTop())
	While TMP3->(!EOF()) 
			nlin++
			@nlin,12 psay 'Motivo :'+TMP3->TIPOAFA+ ' Quantidade:'+TMP3->QUANT+' - fim'		
			TMP3->(dbSkip())
	EndDo
	*/
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

	//	* Mostrar a consulta */
	//@ 116,090 To 416,707 Dialog oDlgMemo Title "Consulta"
	//@ 055,005 Get _cQuery Size 250,080 MEMO Object oMemo
	//Activate Dialog oDlgMemo
	
	
	If Select("TMP") != 0
		TMP->(dbCloseArea())
	Endif

	TCQUERY _cQuery NEW ALIAS "TMP"

return


Static Function GeraTMP2(par1,par2,catfunc,sitfolh)

	_cQuery2 := " SELECT R8_MAT,R8_TIPOAFA, RA_NOME "
	_cQuery2 += " FROM "  + retSqlTab('SR8') + ", "+ retSqlTab('SRA')
	_cQuery2 += " WHERE " + retSqlFil('SR8') + " AND "+ retSqlFil('SRA')
	_cQuery2 += " AND RA_MAT BETWEEN '" + par1+"' AND '" + par2 + "'"
	_cQuery2 += " AND R8_MAT = RA_MAT"
	_cQuery2 += " AND R8_MAT NOT IN ('001')"
	_cQuery2 += " AND RA_CATFUNC IN (" + Upper(catfunc) + ")" 
	_cQuery2 += " AND RA_SITFOLH IN (" + Upper(sitfolh) + ")"	
	_cQuery2 += " AND "+retSqlDel('SR8')+" AND "+ retSqlDel('SRA')
	_cQuery2 += " ORDER BY R8_MAT, RA_NOME


	_cQuery2  := ChangeQuery(_cQuery2)

	//	* Mostrar a consulta */
	//@ 116,090 To 416,707 Dialog oDlgMemo Title "Consulta"
	//@ 055,005 Get _cQuery Size 250,080 MEMO Object oMemo
	//Activate Dialog oDlgMemo
	
	//Return .t.
	If Select("TMP2") != 0
		TMP2->(dbCloseArea())
	Endif

	TCQUERY _cQuery2 NEW ALIAS "TMP2"

Return .t.
