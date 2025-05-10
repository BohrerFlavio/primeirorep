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
±±ºPrograma  ³DTI43  ºAutor  ³Mauricio Roehrs º Data ³  01/09/17          º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³ Relatorio para verificar quem ultrapassou total de hras	  º±±
±± 			 ³ extras  												  	              º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ SIGAGPE - SIGAPON		                                      º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/

User Function DTI43()
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Declaracao de Variaveis                                             ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ

	Local cDesc1       	:= "Este programa tem como objetivo imprimir relatorio "
	Local cDesc2       	:= "de acordo com os parametros informados pelo usuario."
	Local cDesc3       	:= "Limite Hras. Extras Ultrapassadas"
	Local cPict        	:= ""
	Local titulo       	:= "Relatorio de Limite Hras. Extras Ultrapassadas"
	Local Cabec1       	:= "Matricula           Nome                         Data       Hras. Extras  Hras. Diarias    Turno       Insalub."
	Local Cabec2         := ""
	Local imprime        := .T.
	Local aOrd           := {}
	Private nLin         := 132
	Private lEnd         := .F.
	Private lAbortPrint  := .F.
	Private CbTxt        := ""
	Private limite       := 132
	Private tamanho      := "M"
	Private nomeprog     := "DTI43" // Coloque aqui o nome do programa para impressao no cabecalho
	Private nTipo        := 18
	Private aReturn      := { "Zebrado", 1, "Administracao", 2, 2, 1, "", 1}
	Private nLastKey     := 0
	Private cPerg   	 := "DTI43"
	Private cbtxt      	 := Space(10)                          	
	Private cbcont     	 := 00
	Private CONTFL     	 := 01
	Private m_pag      	 := 01
	Private wnrel      	 := "DTI43" // Coloque aqui o nome do arquivo usado para impressao em disco

	pergunte(cPerg,.F.)

	wnrel := SetPrint('SPC',NomeProg,cPerg,@titulo,cDesc1,cDesc2,cDesc3,.T.,aOrd,.T.,Tamanho,,.T.)

	_cQuery := " SELECT RA_MAT, RA_TNOTRAB, RA_INSMED, RA_INSMAX, PC_DATA, PC_PD, PC_QUANTC, R6_HRSDIAR, RA_CC, RA_NOME
	_cQuery += " FROM " + retSqlTab('SRA') + ", " + retSqlTab('SPC') + " , " + retSqlTab('SR6')
	_cQuery += " WHERE " + retSqlFil('SRA') + " AND " + retSqlFil('SPC')
	_cQuery += " AND RA_MAT = PC_MAT AND PC_PD IN ('105','109') AND RA_SITFOLH = ''
	_cQuery += " AND RA_TNOTRAB = R6_TURNO
	_cQuery += " AND RA_MAT BETWEEN '" + mv_par01 + "' AND '" + mv_par02 + "'"
	_cQuery += " AND PC_DATA  BETWEEN '" + dtos(mv_par03) + "' AND '" + dtos(mv_par04) + "'"
	_cQuery += " AND RA_CC BETWEEN '" + mv_par05 + "' AND '" + mv_par06 + "'"
	_cQuery += " AND " + retSqlDel('SRA') + " AND " + retSqlDel('SPC') + " AND " + retSqlDel('SR6') 
	_cQuery += " ORDER BY RA_CC, RA_MAT, RA_NOME, PC_DATA, R6_HRSDIAR, RA_INSMED, RA_INSMAX 


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

	SetDefault(aReturn,'SPC')

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

		if nLin > 75 // Salto de Página. Neste caso o formulario tem 75 linhas...
			Cabec(Titulo,Cabec1,Cabec2,NomeProg,Tamanho,nTipo)
			nLin := 9                    		
		endif



		//GANHAM INSALUBRIDADE
		//se fizer 8 horas diarias, receber alguma insalubridade e tiver hora extra, então escreve
		//if TMP->R6_HRSDIAR == "08:00" .and. (TMP->RA_INSMED > 0 .or. TMP->RA_INSMAX > 0) .and. TMP->PC_QUANTC > 0
		//se ganha insalubridade e fez alguma hora extra
		if (TMP->RA_INSMED > 0 .or. TMP->RA_INSMAX > 0) .and. TMP->PC_QUANTC > 0

			if _cCC <> TMP->RA_CC                   						
				_cDescCC := fBuscaCpo('CTT',1,xFilial('CTT') + alltrim(TMP->RA_CC),'CTT_DESC01')
				@nlin,00 psay replicate('-',132)
				nlin++
				@nlin,01 psay "Centro de Custo: " + _cDescCC
				nlin++	                        
				@nlin,00 psay replicate('-',132)
				nlin++			
				_cCC := TMP->RA_CC	
			endif  

			//escreve	 		
			@nlin,00 psay TMP->RA_MAT   
			@nlin,10 psay substr(TMP->RA_NOME,1,35)
			@nlin,48 psay stod(TMP->PC_DATA)
			@nlin,60 psay StrTran(Transform( TMP->PC_QUANTC, '@e 9999.99' ),',',':' )//TMP->PC_QUANTC
			@nlin,75 psay TMP->R6_HRSDIAR 
			@nlin,90 psay TMP->RA_TNOTRAB
			@nlin,105 psay iif(TMP->RA_INSMED > 0, TMP->RA_INSMED,TMP->RA_INSMAX)		
			nlin++
		endif        

		//NÃO GANHAM INSALUBRIDADE                                                                           
		//se fizer 8.48 diarias, não receber insalubridade e tiver mais que 1.12hras de hora extra, então escreve
		if TMP->R6_HRSDIAR == "08:48" .and. (TMP->RA_INSMED == 0 .or. TMP->RA_INSMAX == 0) .and. TMP->PC_QUANTC > 1.12    

			if _cCC <> TMP->RA_CC                   
				_cDescCC := fBuscaCpo('CTT',1,xFilial('CTT') + alltrim(TMP->RA_CC),'CTT_DESC01')
				@nlin,00 psay replicate('-',132)
				nlin++			
				@nlin,01 psay "Centro de Custo: " + _cDescCC
				nlin++	
				@nlin,00 psay replicate('-',132)
				nlin++			
				_cCC := TMP->RA_CC	
			endif   	    

			//escreve	    
			@nlin,00 psay TMP->RA_MAT   
			@nlin,10 psay substr(TMP->RA_NOME,1,35)
			@nlin,48 psay stod(TMP->PC_DATA)
			@nlin,60 psay StrTran(Transform(TMP->PC_QUANTC , '@e 9999.99' ),',',':' )//TMP->PC_QUANTC
			@nlin,75 psay TMP->R6_HRSDIAR 
			@nlin,90 psay TMP->RA_TNOTRAB
			@nlin,105 psay iif(TMP->RA_INSMED > 0, TMP->RA_INSMED,TMP->RA_INSMAX)		
			nlin++
		endif        

		//se fizer 8.00 diarias, não receber insalubridade e tiver mais que 2.00hras de hora extra, então escreve
		if TMP->R6_HRSDIAR == "08:00" .and. (TMP->RA_INSMED == 0 .or. TMP->RA_INSMAX == 0) .and. TMP->PC_QUANTC > 2.00
			if _cCC <> TMP->RA_CC                   
				_cDescCC := fBuscaCpo('CTT',1,xFilial('CTT') + alltrim(TMP->RA_CC),'CTT_DESC01')
				@nlin,00 psay replicate('-',132)
				nlin++			
				@nlin,01 psay "Centro de Custo: " + _cDescCC
				nlin++
				@nlin,00 psay replicate('-',132)
				nlin++				
				_cCC := TMP->RA_CC	
			endif   	
			//escreve	
			@nlin,00 psay TMP->RA_MAT   
			@nlin,10 psay substr(TMP->RA_NOME,1,35)
			@nlin,48 psay stod(TMP->PC_DATA)
			@nlin,60 psay StrTran(Transform( TMP->PC_QUANTC, '@e 9999.99' ),',',':' )//TMP->PC_QUANTC
			@nlin,75 psay TMP->R6_HRSDIAR 
			@nlin,90 psay TMP->RA_TNOTRAB
			@nlin,105 psay iif(TMP->RA_INSMED > 0, TMP->RA_INSMED,TMP->RA_INSMAX)		
			nlin++
		endif        


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
