#INCLUDE "rwmake.ch"
#INCLUDE "topconn.ch"

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³DTI152 º Autor ³ Flávio Bohrer Flôres  º Data ³  24/08/2022 º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDescricao ³ Relatorio de Estoque de Peças                              º±±
±±º          ³ Solicitado por Adriana para buscar informações da          º±±
±±º          ³ nova rotina mrvt13                                         º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³  PCP (SIGAPCP)                                             º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/

User Function DTI152()
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Declaracao de Variaveis                                             ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ

	Local cDesc1         := "Este programa tem como objetivo imprimir relatorio   "
	Local cDesc2         := "de carcaças produzidas no abate distribuidas por suas"
	Local cDesc3         := "variadas classificações, algutinando suas quantidades"
	Local titulo         := "Peças em Estoque"
	Local nLin         := 80
	Local Cabec1       := SPACE(45)+"Peças em Estoque - Divisão Costela"                   
	Local Cabec2       := SPACE(3)+"Abate"+SPACE(5)+"Numero Peça"+SPACE(3)+"Seq."+SPACE(6)+"Raça"+SPACE(8)+"Dent."+SPACE(8)+"Programa "
	Local aOrd := {}
	Private lEnd         := .F.
	Private lAbortPrint  := .F.
	Private CbTxt        := ""
	Private limite       := 132
	Private tamanho      := "M"
	Private nomeprog     := "DTI152" // Coloque aqui o nome do programa para impressao no cabecalho
	Private nTipo        := 18
	Private aReturn      := { "Zebrado", 1, "Administracao", 2, 2, 1, "", 1}
	Private nLastKey     := 0
	Private cPerg   := "DTI152"
	Private cbcont     := 00
	Private CONTFL     := 01
	Private m_pag      := 01
	Private wnrel      := "DTI152" // Coloque aqui o nome do arquivo usado para impressao em disco    
	Private TotCaix    := 0.00
	Private TotPeso    := 0.00

	pergunte(cPerg,.F.)
	
    wnrel := SetPrint('SZK',NomeProg,cPerg,@titulo,cDesc1,cDesc2,cDesc3,.T.,aOrd,.T.,Tamanho,,.T.)
	/* Precisa ser conversado para adaptar o sistema com relação a busca da localização*/
	cQuery := " SELECT  ZAJ_CORORI,ZAJ_NUM,ZAJ_CONTRO,ZK_CATEG,ZK_PROGRAM AS PROGRAM,ZK_CLASSIF AS CLASSIF,ZK_DENT AS DENT,ZK_RACA AS RACA,ZK_BLACK AS BLACK,ZG_DATA AS DABATE,ZAW_LOCAL AS CAMARA"
	cQuery += " FROM " + RetSqlTab("SZK") + "," +  RetSqlTab("ZAJ") + "," +  RetSqlTab("SZG")+ "," +  RetSqlTab("ZAW")
	cQuery += " WHERE  " + RetSQLFil('SZK') + " AND " + RetSQLFil('ZAJ') + " AND "  + RetSQLFil('SZG') + " AND " + RetSQLFil('ZAW') + " AND "
	cQuery +=" ZK_NUMAM = ZAJ_NUMAM AND ZK_CONTROL = ZAJ_CONTRO AND ZK_NUMAM = ZG_NUMAM AND ZAW_NUM = ZAJ_NUM " 

    if !empty(mv_par01)
		cQuery += " AND ZAJ_NUMAM = '" + mv_par01 + "'"      
	endif   
      
    //cQuery += " AND ZAJ_DATAS = '' AND ZAJ_HORAS = '' AND ZAJ_REGORI = '0000000000' "                      
	cQuery += " AND " + RetSQLDel('SZK') + " AND " + RetSQLDel('ZAJ')	 
	cQuery += " GROUP BY ZAJ_CORORI,ZK_CATEG,ZK_PROGRAM,ZK_CLASSIF,ZK_RACA,ZK_DENT,ZK_BLACK,ZAJ_NUM,ZAJ_CONTRO,ZG_DATA,ZAW_LOCAL" 
	cQuery += " ORDER BY ZAJ_CORORI,ZK_CATEG,ZK_PROGRAM,ZK_CLASSIF,ZK_RACA,ZK_DENT,ZK_BLACK,ZAJ_NUM,ZAJ_CONTRO,ZG_DATA,ZAW_LOCAL"
	//alert('linha 67')
    //	* Mostrar a consulta */
	//@ 116,090 To 416,707 Dialog oDlgMemo Title "Consulta"
	//@ 055,005 Get cQuery Size 250,080 MEMO Object oMemo
	//Activate Dialog oDlgMemo
    
    If Select("TMP") != 0
		TMP->(dbCloseArea())
	Endif
	TCQUERY cQuery NEW ALIAS "TMP"

	If nLastKey == 27
		Return
	Endif

	SetDefault(aReturn,'SZK')

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
	Local _nCol     := 1
	Local nCont 	:= 0 
	Local _nQRac  := 0
	Local _nQRaca := 0
	Local _nQRach := 0
	Local _nQRacb := 0
	Local _nQRacg := 0 
	Local _nQRacbr:= 0 
	Local _nQRacch:= 0
	Local _nQRace := 0
	Local _sDTA 	:= ''
	Local _cCAMARA 	:= ''
	Local  _cClass := ''
	Local _n8de := 0 
	Local _n8des := 0 
	Local _n6de := 0 
	Local _nQBlack := 0

	Cabec(Titulo,Cabec1,Cabec2,NomeProg,Tamanho,nTipo)
	nLin := 9

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


		If nLin > 70 // Salto de Página. Neste caso o formulario tem 55 linhas...
			
			Cabec(Titulo,Cabec1,Cabec2,NomeProg,Tamanho,nTipo)
			nLin := 9
			_nCol := 1	

		Endif
		IF mv_par02 = 1

			/* Raça
			RACA == "Vazio"  - sem raça
			001-ANGUS               
			002-HEREFORD            
			003-BRAFORD             
			004-GERAL               
			005-BRANGUS             
			006-CRUZ HER            
			007-EUROPEU              	
			*/
			if alltrim(TMP->RACA) = ''
				_nQRac++
			Elseif alltrim(TMP->RACA) = '001'
				_nQRaca++
			Elseif alltrim(TMP->RACA) = '002'
				_nQRach++
			Elseif alltrim(TMP->RACA) = '003'
				_nQRacb++
			Elseif alltrim(TMP->RACA) = '004'
				_nQRacg++
			Elseif alltrim(TMP->RACA) = '005'
				_nQRacbr++
			Elseif alltrim(TMP->RACA) = '006'
				_nQRacch++
			Elseif alltrim(TMP->RACA) = '007'
				_nQRace++
			Endif
			// Se for  sintética
			_sDTA := TMP->DABATE			
			_cCamara := TMP->CAMARA					
			_cClass := TMP->CLASSIF
			_cRaca := TMP->RACA+'-'+fBuscaCPO('ZA8', 1, xFilial('ZA8')+TMP->RACA , 'ZA8_DESC')
			//_cRaca := TMP->RACA
				
			nCont++

		Else 
			// Se for Analítica
			_cRaca := TMP->RACA+'-'+fBuscaCPO('ZA8', 1, xFilial('ZA8')+TMP->RACA , 'ZA8_DESC')

			@nlin,_nCol    psay STOD(TMP->DABATE)
			@nlin,_nCol+12 psay TMP->ZAJ_NUM		
			@nlin,_nCol+24 psay TMP->ZAJ_CONTRO
			@nlin,_nCol+34 psay _cRaca
			@nlin,_nCol+50 psay TMP->DENT
			@nlin,_nCol+55 psay'Programa->'+ TMP->PROGRAM
			if TMP->BLACK = 'S'
				@nlin,_nCol+75 psay'Carcaça Black'
			endif
			nCont++

			_sDTA := TMP->DABATE			
			_cCamara := TMP->CAMARA					
			_cClass := TMP->CLASSIF
			
			if TMP->BLACK = 'S'
				/* Se for Black */
				_nQBlack++
			elseif alltrim(TMP->RACA) = ''
				if TMP->DENT = '8' .AND. !empty(alltrim(TMP->PROGRAM))
					_n8de++
				Elseif TMP->DENT = '8'
					_n8des++
				Else	
					_n6de++
				endif
				_nQRac++
			Elseif alltrim(TMP->RACA) = '001'
				_nQRaca++
			Elseif alltrim(TMP->RACA) = '002'
				_nQRach++
			Elseif alltrim(TMP->RACA) = '003'
				_nQRacb++
			Elseif alltrim(TMP->RACA) = '004'
				_nQRacg++
			Elseif alltrim(TMP->RACA) = '005'
				_nQRacbr++
			Elseif alltrim(TMP->RACA) = '006'
				_nQRacch++
			Elseif alltrim(TMP->RACA) = '007'
				_nQRace++
			Endif
				
		endif
		
		nlin++
		TMP->(DbSkip())

	EndDo
	// Total Sintético			
	If nLin > 70 // Salto de Página. Neste caso o formulario tem 55 linhas...
			
		Cabec(Titulo,Cabec1,Cabec2,NomeProg,Tamanho,nTipo)
		nLin := 9
		_nCol := 1	

	Endif		
	IF mv_par02 = 1

		@nlin,_nCol    psay 'Fechamento'
		nlin++
		@nlin,_nCol    psay 'Data do abate:'
		@nlin,_nCol+14 psay STOD(_sDTA)
		@nlin,_nCol+24 psay 'Camara:'
		@nlin,_nCol+34 psay _cCamara	
		@nlin,_nCol+39 psay 'Classificação:'
		@nlin,_nCol+54 psay _cClass
		@nlin,_nCol+58 psay 'Total de Peças:'
		@nlin,_nCol+73 psay nCont
		//* Separação por Raça *//
		// 
		/* Raça
		RACA == "Vazio"  - sem raça
		001-ANGUS               
		002-HEREFORD            
		003-BRAFORD             
		004-GERAL               
		005-BRANGUS             
		006-CRUZ HER            
		007-EUROPEU              	
		*/

	else
		// Analítico
		nlin++
		nlin++
		@nlin,_nCol    psay 'Fechamento Analítico'
		nlin++
		@nlin,_nCol    psay 'Data do abate:'
		@nlin,_nCol+14 psay STOD(_sDTA)
		@nlin,_nCol+24 psay 'Camara:'
		@nlin,_nCol+34 psay _cCamara	
		@nlin,_nCol+39 psay 'Classificação:'
		@nlin,_nCol+54 psay _cClass
		@nlin,_nCol+58 psay 'Total de Peças:'
		@nlin,_nCol+73 psay nCont
		//* Separação por Raça *//

		
		
			if _nQRac > 0 
				//nlin++
				//@nlin,_nCol    psay 'Total sem Raca:' + STR(_nQRac)
			
				if _n8de > 0 
					/*  8 dentes e classificada com  programa= BestBeef */
					nlin++
					@nlin,_nCol    psay 'Total BestBeef:' + alltrim(STR(_n8de))
				Endif
				if _n8des > 0 
					/*  8 dentes  */
					nlin++
					@nlin,_nCol    psay 'Total BestBeef s/Progama:' + alltrim(STR(_n8des))
				Endif
				if _n6de > 0 
					/*	até 6 dentes e não classificada com  programa*/
					nlin++
					@nlin,_nCol    psay 'Total Novilho:' + alltrim(STR(_n6de))
				Endif
			endif
			if _nQRaca > 0	
				nlin++			
				@nlin,_nCol    psay 'Total Ângus   :' + alltrim(STR(_nQRaca))
			Endif
			if _nQRach > 0 			
				nlin++
				@nlin,_nCol    psay 'Total Hereford:' + alltrim(STR(_nQRach))
			Endif
			if _nQRacb > 0				
				nlin++
				@nlin,_nCol    psay 'Total Braford  :' + alltrim(STR(_nQRacb))
			Endif
			if _nQRacg > 0			
				nlin++
				@nlin,_nCol    psay 'Total Geral   :' + alltrim(STR(_nQRacg))
			Endif
			if _nQRacbr > 0				
				nlin++
				@nlin,_nCol    psay 'Total Brangus :' + alltrim(STR(_nQRacbr))
			Endif
			if _nQRacch > 0				
				nlin++
				@nlin,_nCol    psay 'Total Cruz Her:' + alltrim(STR(_nQRacch))
			Endif
			if _nQRace > 0				
				nlin++
				@nlin,_nCol    psay 'Total Europeu:' + alltrim(STR(_nQRace))
			Endif
			if _nQBlack > 0				
				nlin++
				@nlin,_nCol    psay 'Total Black:' + alltrim(STR(_nQBlack))
			endif
		
	Endif
	
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Finaliza a execucao do relatorio...                                 ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ

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
