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
±±ºPrograma  ³DTI39  ºAutor  ³Flavio Bohrer º Data ³  03/07/17            º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³ Relatorio para soma das hroas por centro de Custo     	  º±±
±± 			 ³  										                  º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ SIGAGPE - SIGAPON		                                  º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/

User Function DTI39()
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Declaracao de Variaveis                                             ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ

	Local cDesc1       	:= "Este programa tem como objetivo imprimir relatorio "
	Local cDesc2       	:= "de de soma das horas por Centro de Custo"
	Local cDesc3       	:= ""
	Local cPict        	:= ""
	Local titulo       	:= "CALCULO DE HORAS TRABALHADAS POR CC"
	Local Cabec1       	:= space(20)+"Período gerado : "
	Local Cabec2         := ""
	Local imprime        := .T.
	Local aOrd           := {}
	Private nLin         := 0
	Private lEnd         := .F.
	Private lAbortPrint  := .F.
	Private CbTxt        := ""
	Private limite       := 80
	Private tamanho      := "M"
	Private nomeprog     := "DTI39" // Coloque aqui o nome do programa para impressao no cabecalho
	Private nTipo        := 18
	Private aReturn      := { "Zebrado", 1, "Administracao", 2, 2, 1, "", 1}
	Private nLastKey     := 0
	Private cPerg   	 := "DTI39"
	Private cbtxt      	 := Space(10)
	Private cbcont     	 := 00
	Private CONTFL     	 := 01
	Private m_pag      	 := 01
	Private wnrel      	 := "DTI39" // Coloque aqui o nome do arquivo usado para impressao em disco

	pergunte(cPerg,.F.)

	// Período Atual
	if mv_par03 = 1
		//alert('59 - par 1 Atual')
		wnrel := SetPrint('SPC',NomeProg,cPerg,@titulo,cDesc1,cDesc2,cDesc3,.T.,aOrd,.T.,Tamanho,,.T.)
		_cQuery := " SELECT PC_MAT AS MATRICULA, PC_DATA AS DATA, PC_CC AS CC,PC_QUANTC AS HORAS,PC_PD AS PD"
		_cQuery += " FROM  " + retSqlTab('SPC')
		_cQuery += " WHERE " + retSqlFil('SPC')
		_cQuery += " AND PC_DATA BETWEEN '" + dtos(mv_par01) + "' AND '" + dtos(mv_par02) + "'"
		_cQuery += " AND PC_PD IN ('105','106','107','108','113','996')"
		_cQuery += " AND " + retSqlDel('SPC') 
		_cQuery += " ORDER BY PC_CC, PC_MAT"    
					
	Elseif  mv_par03 = 2     
	    //  alert('70 - par 2 Anterior')     
	    // Períodos Anteriores
		wnrel := SetPrint('SPH',NomeProg,cPerg,@titulo,cDesc1,cDesc2,cDesc3,.T.,aOrd,.T.,Tamanho,,.T.)
		_cQuery := " SELECT PH_MAT AS MATRICULA, PH_DATA AS DATA, PH_CC AS CC,PH_QUANTC AS HORAS,PH_PD AS PD"
		_cQuery += " FROM  " + retSqlTab('SPH')
		_cQuery += " WHERE " + retSqlFil('SPH')
		_cQuery += " AND PH_DATA BETWEEN '" + dtos(mv_par01) + "' AND '" + dtos(mv_par02) + "'"
		_cQuery += " AND PH_PD IN ('105','106','107','108','113','996')"
		_cQuery += " AND " + retSqlDel('SPH') 
		_cQuery += " ORDER BY PH_CC, PH_MAT" 
		
	endif
	_cQuery  := ChangeQuery(_cQuery)


	//	* Mostrar a consulta */
	//@ 116,090 To 416,707 Dialog oDlgMemo Title "Consulta"
	//@ 055,005 Get _cQuery Size 250,080 MEMO Object oMemo
	//Activate Dialog oDlgMemo

	if Select("TMP") != 0
		TMP->(dbCloseArea())
	endif

	TCQUERY _cQuery NEW ALIAS "TMP"
	//	* Mostrar a consulta */
	//@ 116,090 To 416,707 Dialog oDlgMemo Title "Consulta"
	//@ 055,005 Get cQuery Size 250,080 MEMO Object oMemo
	//Activate Dialog oDlgMemo

	if nLastKey == 27
		Return
	endif
	if mv_par03 = 1
		
		//alert('102 - Se atual ')
		SetDefault(aReturn,'SPC')
		
	Elseif mv_par03 = 2
		
		//alert('107 - Se anterior ')
		SetDefault(aReturn,'SPH')
	Endif

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
	Local cc  := ' '
	//hora      := 0  
	Local hora996   := 0
	Local hora105   := 0
	Local hora106   := 0
	Local hora107   := 0     
	Local hora108   := 0
	Local hora113   := 0
	Local minuto    := 0
	Local minutos   := 0
	Local minutos996 := 0
	Local minutos105 := 0
	Local minutos106 := 0
	Local minutos107 := 0
	Local minutos108 := 0
	Local minutos113 := 0
	Local minuto996 := 0
	Local minuto105 := 0
	Local minuto106 := 0
	Local minuto107 := 0 
	Local minuto108 := 0
	Local minuto113 := 0
	Local horas     := 0 
	Local sHoras    := 0
	Local sHorast   := 0	
	Local PD996     := 0
	Local PD105     := 0
	Local PD106     := 0
	Local PD107     := 0
	Local PD108     := 0
	Local PD113     := 0


	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ SETREGUA -> Indica quantos registros serao processados para a regua ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	Cabec1  +=  alltrim(dtoc(mv_par01))+" até :"+alltrim(dtoc(mv_par02))

	Cabec(Titulo,Cabec1,Cabec2,NomeProg,Tamanho,nTipo)

	TMP->(SetRegua(RecCount()))
	_cCC := ''
	_nLincab := 7
	TMP->(dbGoTop())
	nLin := _nLincab       



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
			nLin := _nLincab                    		
		endif
		
		if TMP->CC != _cCC  

			If (PD996 > 0 .OR. PD105 > 0 .OR. PD106 > 0 .OR. PD107 > 0 .OR. PD108 > 0 .OR. PD113 > 0)
				nLin +=2 
				
				If (PD996 > 0)
					_cCC := alltrim(_cCC + fBuscaCPO('SI3',1,xfilial('SI3')+_cCC,'I3_DESC'))
					@nLin,10 PSAY '--- RESMO DO SETOR '+_cCC+' ---'
					nLin ++								
					@nlin,20  PSAY "Horas normais - 996:..................."+StrTran(Transform( fConvHr( PD996,'H'), '@e 999,999,9999.99' ),',',':' )		
					nlin ++
					sHoras += PD996
					
				
				Endif    

				If (PD105 > 0)
					@nlin,20  PSAY "Horas extras 60% - 105:................"+StrTran(Transform( fConvHr( PD105,'H'), '@e 999,9999.99' ),',',':' )
					nlin ++  
					sHoras += PD105
					
				Endif

				If (PD106 > 0)
					@nlin,20  PSAY "Horas extras 100% - 106:..............."+StrTran(Transform( fConvHr( PD106,'H'), '@e 999,9999.99' ),',',':' )		
					nlin ++
					sHoras += PD106    

				Endif
				If (PD107 > 0)
					@nlin,20  PSAY "Horas extras 60% COMP. - 107:..........."+StrTran(Transform( fConvHr( PD107,'H'), '@e 999,9999.99' ),',',':' )
					nlin ++
					sHoras += PD107 

				Endif
				If (PD108 > 0)
					@nlin,20  PSAY "Horas extras 100% feriado - 108:......."+StrTran(Transform( fConvHr( PD108,'H'), '@e 999,9999.99' ),',',':' )		
					nlin ++   
					sHoras += PD108

				Endif

				If (PD113 > 0)
					@nlin,20  PSAY "Horas extras 100% fer.not.:...... -113"+StrTran(Transform( fConvHr( PD113,'H'), '@e 999,9999.99' ),',',':' )
					nlin ++
					sHoras += PD113								 
				Endif
				@nlin,20  PSAY "Total Horas.:...................."+StrTran(Transform( fConvHr( sHoras,'H'), '@e 999,9999.99' ),',',':' )
				sHorast += sHoras
				nlin ++

			Endif 

			_cCC	:= TMP->CC    
			PD996 := 0
			PD105 := 0
			PD106 := 0
			PD107 := 0
			PD108 := 0
			PD113	:= 0
			sHoras := 0

		endif	

		hora    := fConvHr(TMP->HORAS ,'D')
		minuto  := TMP->HORAS - hora
		horas   += hora
		minutos += minuto

		if TMP->PD = "996"

			hora996	:= fConvHr(TMP->HORAS,'D')
			minuto996  :=	fConvHr(TMP->HORAS ,'D') - hora996
			PD996   += hora996
			minutos996 += minuto996
			//alert(TMP->HORAS)
			//alert(hora996)
		endif
		if TMP->PD = "105" 		
			hora105 := fConvHr(TMP->HORAS ,'D')
			minuto105  := fConvHr(TMP->HORAS ,'D') - hora105
			PD105   += hora105
			minutos105 += minuto105

		endif
		if TMP->PD = "106"		
			hora106	 := fConvHr(TMP->HORAS ,'D')		
			minuto106 := fConvHr(TMP->HORAS ,'D') - hora106		
			PD106      += hora106
			minutos106 += minuto106
		endif
		if TMP->PD = "107"  	                              
			hora107    := fConvHr(TMP->HORAS ,'D')		
			minuto107  := fConvHr(TMP->HORAS ,'D') - hora107
			PD107      += hora107
			minutos107 += minuto107
		endif     
		if TMP->PD = "108"      	
			hora108 := fConvHr(TMP->HORAS ,'D')					
			minuto108:= fConvHr(TMP->HORAS ,'D') - hora108		
			PD108      += hora108
			minutos108 += minuto108
		endif     
		if TMP->PD = "113"
			hora113 := fConvHr(TMP->HORAS ,'D')		
			minuto113 := fConvHr(TMP->HORAS ,'D') - hora113
			PD113      += hora113
			minutos113 += minuto113
		endif     	   

		TMP->(dbSkip()) // Avanca o ponteiro do registro no arquivo

	enddo  

	If (PD996 > 0 .OR. PD105 > 0 .OR. PD106 > 0 .OR. PD107 > 0 .OR. PD108 > 0 .OR. PD113 > 0)
		nLin +=2  
		_cCC := alltrim(_cCC + fBuscaCPO('SI3',1,xfilial('SI3')+_cCC,'I3_DESC'))
		@nLin,10 PSAY '--- RESMO DO SETOR '+_cCC+' ---'
		nLin ++
		

		If (PD996 > 0)
			@nlin,20  PSAY "Horas normais:..................."+StrTran(Transform( fConvHr( PD996,'H'), '@e 999,9999.99' ),',',':' )	 
			sHoras += PD996
			nlin ++
			//alert(PD996)
			//alert(type(PD996))
		Endif    
		If (PD105 > 0)
			@nlin,20  PSAY "Horas extras 60%:..................."+StrTran(Transform( fConvHr( PD105,'H'), '@e 999,999.99' ),',',':' )
			sHoras += PD105
			nlin ++  
			//alert(PD105)
			//alert(type(PD105))
		Endif 
		If (PD106 > 0)
			@nlin,20  PSAY "Horas extras 100%:..............."+StrTran(Transform( fConvHr( PD106,'H'), '@e 999,999.99' ),',',':' )		
			sHoras += PD106
			nlin ++       
		Endif
		If (PD107 > 0)
			@nlin,20  PSAY "Horas extras 60% COMP.:..........."+StrTran(Transform( fConvHr( PD107,'H'), '@e 999,999.99' ),',',':' ) 
			sHoras += PD107
			nlin ++ 				
		Endif
		If (PD108 > 0)
			@nlin,20  PSAY "Horas extras 100% feriado:......."+StrTran(Transform( fConvHr( PD108,'H'), '@e 999,999.99' ),',',':' ) 
			sHoras += PD108		
			nlin ++   			 
		Endif 
		If (PD113 > 0)
			@nlin,20  PSAY "Horas extras 100% fer.not.:......"+StrTran(Transform( fConvHr( PD113,'H'), '@e 999,999.99' ),',',':' )
			sHoras += PD113
			nlin ++						 
		Endif
		if nLin > 60 // Salto de Página. Neste caso o formulario tem 55 linhas...
			Cabec(Titulo,Cabec1,Cabec2,NomeProg,Tamanho,nTipo)
			nLin := _nLincab                    		
		endif
		
		//if alltrim(_cCC) $ '1111001'
		//	alert(sHoras)
		//endif
		//alert(sHoras)
		//alert(sHorast)
		@nlin,20  PSAY "Total Horas.:...................."+StrTran(Transform( fConvHr( sHoras,'H'), '@e 999,9999.99' ),',',':' )
		sHorast += sHoras
		nlin += 3
		@nlin,15  PSAY "Total Horas Geral da Empresa :.."+StrTran(Transform( fConvHr( sHorast,'H'), '@e 999,999,9999.99' ),',',':' )
	Endif

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
