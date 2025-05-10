#INCLUDE "topconn.ch"
#INCLUDE "rwmake.ch"
#INCLUDE "vkey.ch"
#INCLUDE "protheus.ch"
#INCLUDE "colors.ch"
#INCLUDE "tbiconn.ch"


/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³DTI40  ºAutor  ³Mauricio Roehrs º Data ³  03/07/17          º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³ Relatorio para verificação das folgas					  º±±
±± 			 ³  													  	  º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ SIGAGPE - SIGAPON		                                  º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/

User Function DTI40()
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Declaracao de Variaveis                                             ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ

	Local cDesc1       	:= "Este programa tem como objetivo imprimir relatorio "
	Local cDesc2       	:= "de acordo com os parametros informados pelo usuario."
	Local cDesc3       	:= "Saldo de horas da troca de roupas"
	Local cPict        	:= ""
	Local titulo       	:= "Saldo de Horas da Troca de Roupas"
	Local Cabec1       	:= "Matricula           Nome        	            Saldo de Horas"
	Local Cabec2         := ""
	Local imprime        := .T.
	Local aOrd           := {}
	Local nS
	Private nLin         := 80
	Private lEnd         := .F.
	Private lAbortPrint  := .F.
	Private CbTxt        := ""
	Private limite       := 80
	Private tamanho      := "P"
	Private nomeprog     := "DTI40" // Coloque aqui o nome do programa para impressao no cabecalho
	Private nTipo        := 18
	Private aReturn      := { "Zebrado", 1, "Administracao", 2, 2, 1, "", 1}
	Private nLastKey     := 0
	Private cPerg   	 := "DTI40"
	Private cbtxt      	 := Space(10)
	Private cbcont     	 := 00
	Private CONTFL     	 := 01
	Private m_pag      	 := 01
	Private wnrel      	 := "DTI40" // Coloque aqui o nome do arquivo usado para impressao em disco

	pergunte(cPerg,.F.)

	wnrel := SetPrint('ZBB',NomeProg,cPerg,@titulo,cDesc1,cDesc2,cDesc3,.T.,aOrd,.T.,Tamanho,,.T.)

	_cSituacao  := mv_par05
	//-- Modifica variaveis para a Query
	cSitQuery := ""
	For nS:=1 to Len(_cSituacao)
		cSitQuery += "'"+Subs(_cSituacao,nS,1)+"'"
		If ( nS+1) <= Len(_cSituacao)
			cSitQuery += ","
		Endif
	Next nS


	_cQuery := " SELECT ZBB_MAT, ZBB_CC, ZBB_SLDATU
	_cQuery += " FROM " + retSqlTab('ZBB') + " , " + retSqlTab('SRA')
	_cQuery += " WHERE " + retSqlFil('ZBB') + " AND " + retSqlFil('SRA')
	_cQuery += " AND RA_MAT = ZBB_MAT
	_cQuery += " AND ZBB_MAT BETWEEN '" + mv_par01 + "' AND '" + mv_par02 + "'"
	_cQuery += " AND ZBB_CC  BETWEEN '" + mv_par03 + "' AND '" + mv_par04 + "'"
	_cQuery += " AND RA_SITFOLH IN (" + Upper(cSitQuery) + ")"
	_cQuery += " AND " + retSqlDel('ZBB') + " AND " + retSqlDel('SRA')
	_cQuery += " ORDER BY ZBB_CC, ZBB_MAT


	_cQuery  := ChangeQuery(_cQuery)

	//	* Mostrar a consulta */
	//@ 116,090 To 416,707 Dialog oDlgMemo Title "Consulta"
	//@ 055,005 Get _cQuery Size 250,080 MEMO Object oMemo
	//Activate Dialog oDlgMemo

	if Select("TMP") != 0
		TMP->(dbCloseArea())
	endif

	TCQUERY _cQuery NEW ALIAS "TMP"


	if nLastKey == 27
		Return
	endif

	SetDefault(aReturn,'ZBB')

	if nLastKey == 27
		Return
	endif

	nTipo := if(aReturn[4]==1,15,18)

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

	_cCC := ''
	TMP->(dbGoTop())
	while TMP->(!EOF())

		incregua()

		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³ Verifica o cancelamento pelo usuario...                             ³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ

		if lAbortPrint
			@nLin,00 PSAY "*** CANCELADO PELO OPERADOR ***"
			exit
		endif

		if nLin > 60 // Salto de Página. Neste caso o formulario tem 55 linhas...
			Cabec(Titulo,Cabec1,Cabec2,NomeProg,Tamanho,nTipo)
			nLin := 9                    		
		endif

		if _cCC <> TMP->ZBB_CC
			_cDescCC := fBuscaCpo('CTT',1,xFilial('CTT') + TMP->ZBB_CC,'CTT_DESC01')		                         
			@nlin,01 psay replicate('-',80)
			nlin++					

			@nlin,05 psay 'Centro de Custo: ' + TMP->ZBB_CC	+ ' - ' + _cDescCC
			nlin++          

			@nlin,01 psay replicate('-',80)
			nlin++					

			_cCC := TMP->ZBB_CC		                                 
		endif

		//função que busca as folgas                             
		buscaFolgas(TMP->ZBB_MAT)	                                            
		TMP2->(dbGoTop())		

		//faz a contagem dos registros
		count to nRecTmp2		

		//if nRecTmp2 > 0
		//	@nlin,01 psay replicate('-',80)	
		//	nlin++
		//endif

		@nlin,05 psay TMP->ZBB_MAT   
		@nlin,15 psay substr(fBuscaCpo('SRA',1,xFilial('SRA') + TMP->ZBB_MAT,'RA_NOME'),1,25)
		@nlin,50 psay StrTran(Transform( fConvHr( TMP->ZBB_SLDATU,'H'), '@e 9999.99' ),',',':' )
		nlin++

		if nRecTmp2 > 0			
			@nlin,07 psay 'Data da Folga' + space(10) + "Horas de Folga"
			nlin++			
		endif

		TMP2->(dbGoTop())	
		while TMP2->(!eof())
			if nLin > 60 // Salto de Página. Neste caso o formulario tem 55 linhas...
				Cabec(Titulo,Cabec1,Cabec2,NomeProg,Tamanho,nTipo)
				nLin := 9                    		
			endif

			@nlin,10 psay stod(TMP2->ZBC_DTREF)
			@nlin,30 psay StrTran(Transform( fConvHr( TMP2->ZBC_HRBAIX,'H'), '@e 9999.99' ),',',':' )
			nlin++          	   			      		
			TMP2->(dbSkip())	

			if TMP2->(eof())
				nlin++		
			endif
		enddo	    

		TMP->(dbSkip()) // Avanca o ponteiro do registro no arquivo

	enddo

	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Finaliza a execucao do relatorio...                                 ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ

	SET DEVICE TO SCREEN

	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Se impressao em disco, chama o gerenciador de impressao...          ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ

	if aReturn[5]==1
		dbCommitAll()
		SET PRINTER TO
		OurSpool(wnrel)
	endif

	MS_FLUSH()

Return                       


Static Function buscaFolgas(_cMat)

	_cQuery2 := " SELECT ZBC_DTREF, ZBC_HRBAIX
	_cQuery2 += " FROM " + retSqlTab('ZBC')
	_cQuery2 += " WHERE " + retSqlFil('ZBC')
	_cQuery2 += " AND ZBC_MAT = '" + _cMat + "'"
	_cQuery2 += " AND " + retSqlDel('ZBC')
	_cQuery2 += " ORDER BY ZBC_DTREF


	_cQuery2  := ChangeQuery(_cQuery2)

	//	* Mostrar a consulta */
	//@ 116,090 To 416,707 Dialog oDlgMemo Title "Consulta"
	//@ 055,005 Get _cQuery2 Size 250,080 MEMO Object oMemo
	//Activate Dialog oDlgMemo

	if Select("TMP2") != 0
		TMP2->(dbCloseArea())
	endif

	TCQUERY _cQuery2 NEW ALIAS "TMP2"

return
