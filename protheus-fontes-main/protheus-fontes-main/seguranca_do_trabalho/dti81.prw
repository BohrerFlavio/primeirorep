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
±±ºDesc.     ³ Relatorio para soma das horas Trabalhadas		    	  º±±
±± 			 ³  										                  º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ SIGAGPE - SIGAPON		                                  º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/

User Function DTI81()
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Declaracao de Variaveis                                             ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ

	Local cDesc1       	:= "Este programa tem como objetivo imprimir relatorio "
	Local cDesc2       	:= "de de soma das horas "
	Local cDesc3       	:= " dos Períodos já encerrados do ponto."
	Local cPict        	:= ""
	Local titulo       	:= "CALCULO DE HORAS TRABALHADAS - Período Encerrado"
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
	Private nomeprog     := "DTI81" // Coloque aqui o nome do programa para impressao no cabecalho
	Private nTipo        := 18
	Private aReturn      := { "Zebrado", 1, "Administracao", 2, 2, 1, "", 1}
	Private nLastKey     := 0
	Private cPerg   	 := "DTI81"
	Private cbtxt      	 := Space(10)
	Private cbcont     	 := 00
	Private CONTFL     	 := 01
	Private m_pag      	 := 01
	Private wnrel      	 := "DTI39" // Coloque aqui o nome do arquivo usado para impressao em disco

	pergunte(cPerg,.F.)
	
	   
	wnrel := SetPrint('SPH',NomeProg,cPerg,@titulo,cDesc1,cDesc2,cDesc3,.T.,aOrd,.T.,Tamanho,,.T.)
	_cQuery := " SELECT PH_MAT AS MATRICULA, PH_DATA AS DATA, PH_CC AS CC,PH_QUANTC AS HORAS,PH_PD AS PD"
	_cQuery += " FROM  " + retSqlTab('SPH')
	_cQuery += " WHERE " + retSqlFil('SPH')
	_cQuery += " AND PH_DATA BETWEEN '" + dtos(mv_par01) + "' AND '" + dtos(mv_par02) + "'"
	_cQuery += " AND PH_PD IN ('105','106','107','108','113','996')"
	_cQuery += " AND " + retSqlDel('SPH') 
	_cQuery += " ORDER BY PH_CC, PH_MAT" 
		
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
	
	SetDefault(aReturn,'SPH')
	
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
	//_cCC := ''
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
		
		

		If (PD996 > 0 .OR. PD105 > 0 .OR. PD106 > 0 .OR. PD107 > 0 .OR. PD108 > 0 .OR. PD113 > 0)	
			
			If (PD996 > 0)
					
				sHoras += PD996		
				
			Endif    

			If (PD105 > 0)
				
				sHoras += PD105
				
			Endif

			If (PD106 > 0)
				
				sHoras += PD106    

			Endif
			If (PD107 > 0)
				
				sHoras += PD107 

			Endif
			If (PD108 > 0)
				 
				sHoras += PD108

			Endif

			If (PD113 > 0)
				
				sHoras += PD113								 
			Endif
			
			sHorast += sHoras
			
		Endif 
  
		PD996 := 0
		PD105 := 0
		PD106 := 0
		PD107 := 0
		PD108 := 0
		PD113 := 0
		sHoras:= 0
	

		hora    := fConvHr(TMP->HORAS ,'D')
		minuto  := TMP->HORAS - hora
		horas   += hora
		minutos += minuto

		if TMP->PD = "996"

			hora996	:= fConvHr(TMP->HORAS,'D')
			minuto996  :=	fConvHr(TMP->HORAS ,'D') - hora996
			PD996   += hora996
			minutos996 += minuto996
			
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
		
		If (PD996 > 0)			
			sHoras += PD996			
		elseif (PD105 > 0)
			sHoras += PD105
		Elseif (PD106 > 0)
			sHoras += PD106
		Elseif (PD107 > 0)
			sHoras += PD107
		Elseif (PD108 > 0)
			sHoras += PD108	
		Elseif (PD113 > 0)
			sHoras += PD113
		EndIf
		sHorast += sHoras
		 nlin += 10
		
		@nlin,15  PSAY "Total Horas Geral da Empresa :.."+StrTran(Transform( fConvHr( sHorast,'H'), '@e 999,999,999,999.99'),',',':' )
	
	
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
