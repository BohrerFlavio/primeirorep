#INCLUDE "rwmake.ch"
#INCLUDE "topconn.ch"

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³GJF12B   º Autor ³ Flavio		    	  º Data ³  07/06/11   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDescricao ³ Relatorio de produções especiais para a entrada da desossa º±±
±±º          ³ Adaptado para apresentação de novos dados a direção        º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ 					  PCP   (SIGAPCP )			              º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/

User Function GJF12B()


	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Declaracao de Variaveis                                             ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ

	Local cDesc1         := "Este programa tem como objetivo imprimir relatorio    "
	Local cDesc2         := "analítico de produções especiais da desossa, mediante "
	Local cDesc3         := "parametros apontados pelo usuário"
	Local cPict          := ""
	Local titulo       	 := "DESOSSA DE PRODUÇÕES ESPECIAIS"
	Local nLin         	 := 80

	Local Cabec1         := "Hora  Peça  Class. Peso  Programa  Dent    |Hora  Peça  Class. Peso  Programa  Dent    |"+;
	"Hora    Peça  Class. Peso  Programa  Dent    "
	Local Cabec2         := " "

	Local imprime        := .T.
	Local aOrd := {}
	Private lEnd        := .F.
	Private lAbortPrint := .F.
	Private CbTxt       := ""
	Private limite      := 132
	Private tamanho     := "M"
	Private nomeprog    := "GJF12B" // Coloque aqui o nome do programa para impressao no cabecalho
	Private nTipo       := 18
	Private aReturn     := { "Zebrado", 1, "Administracao", 2, 2, 1, "", 1}
	Private nLastKey    := 0
	Private cPerg   := "GJF12B"
	Private cbtxt      := Space(10)
	Private cbcont     := 00
	Private CONTFL     := 01
	Private m_pag      := 01
	Private wnrel      := "GJF12B" // Coloque aqui o nome do arquivo usado para impressao em disco    
	Private TotCaix    := 0.00
	Private TotPeso    := 0.00

	pergunte(cPerg,.F.)


	wnrel := SetPrint('SZN',NomeProg,cPerg,@titulo,cDesc1,cDesc2,cDesc3,.T.,aOrd,.T.,Tamanho,,.T.)

	cQuery := " SELECT ZN_RASTRO AS IDENTIF, ZN_EXPORT AS CLASSIF, ZN_DTENTR AS DATAD, ZN_HORA AS HORA,ZN_LADO AS LADO, ZN_PROCPCP AS PROCPCP,"
	cQuery += " ZN_PESOP AS PESO, ZN_DESCRI AS DESCRI, ZN_COD AS COD,ZN_TPTRASE AS TPTRASE,ZN_PROGRAM AS PROGRAMA,ZN_NUMAM AS NUMAM,ZN_SEQUEN AS SEQ"
	cQuery += " FROM " + RetSqlName("SZN") 
	cQuery += " WHERE SZN010.D_E_L_E_T_ <> '*' AND "
	cQuery += " ZN_FILIAL = '" + xFilial("SZN") + "' AND" 
	cQuery += " (ZN_DTENTR BETWEEN '" + dtos(mv_par01) + "' AND '" + dtos(mv_par02) + "') AND"
	cQuery += " (ZN_HORA BETWEEN '" + mv_par03 + "' AND '" + mv_par04 + "')    "  

	if !empty(mv_par05)
		cQuery += " AND ZN_EXPORT = '" + mv_par05 + "' " 
	endif

	Do case
		case mv_par06 = 1
		cQuery += " AND ZN_PROCPCP = 1 " 
		case mv_par06 = 2     
		cQuery += " AND ZN_PROCPCP = 2  " 
		case mv_par06 = 3       
		cQuery += " AND ZN_PROCPCP = 3  " 
	endcase       

	if mv_par07 = 1
		cQuery += " AND ZN_COD = '00005016' "  
	elseif mv_par07 = 2
		cQuery += " AND ZN_COD = '005020' "  
	endif


	cQuery += " ORDER BY ZN_DTENTR, ZN_HORA"

	cQuery := ChangeQuery(cQuery)

	//	* Mostrar a consulta */
	//@ 116,090 To 416,707 Dialog oDlgMemo Title "Consulta"
	//@ 055,005 Get cQuery Size 250,080 MEMO Object oMemo
	//Activate Dialog oDlgMemo
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Monta a interface padrao com o usuario...                           ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ

	If Select("TMP") != 0
		TMP->(dbCloseArea())
	Endif
	TCQUERY cQuery NEW ALIAS "TMP"


	If nLastKey == 27
		Return
	Endif

	SetDefault(aReturn,'SZN')

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
	Local _dDtProd := ''
	Local _cProc   := ''
	Local _lCol    := 1
	Local _nQuant  := 0
	Local _nPeso   := 0.00
	Local _nQtT    := 0
	Local _nQtD    := 0
	Local _cDent	:= ''

	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ SETREGUA -> Indica quantos registros serao processados para a regua ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ

	TMP->(dbGoTop())
	TMP->(SetRegua(RecCount()))

	While TMP->(!EOF())

		incregua()


		if TMP->COD = '000032' 
			TMP->(dbSkip()) 
			loop
		endif  

		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³ Verifica o cancelamento pelo usuario...                             ³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ

		If lAbortPrint
			@nLin,00 PSAY "*** CANCELADO PELO OPERADOR ***"
			Exit
		Endif

		If nLin > 75 // Salto de Página. Neste caso o formulario tem 75 linhas...
			Cabec(Titulo,Cabec1,Cabec2,NomeProg,Tamanho,nTipo)
			nLin := 9
		Endif   

		if _dDtProd <> TMP->DATAD
			nlin++
			@nlin,01 psay stod(TMP->DATAD)
			_dDtProd := TMP->DATAD  
			nlin++
			_lCol := 1
		endif  

		if TMP->COD = '005020'
			_nQtD++
		elseif TMP->COD = '005016'
			_nQtT++
		endif

		_nQuant++
		_nPeso += TMP->PESO     

		_cDent := fBuscaCPO('SZK',4,xfilial('SZK')+alltrim(TMP->NUMAM)+alltrim(TMP->SEQ),'ZK_DENT')
		if _lCol = 1

			@nlin,00 psay TMP->HORA 
			//@nlin,07 psay substr(TMP->IDENTIF,15,6)      
			if TMP->COD = '000031'
				//@nlin,15 psay 'Diant.'
				@nlin,07 psay 'Diant.'
			elseif TMP->COD = '000030'
				if TMP->TPTRASE = 'L'  
					//@nlin,15 psay 'T.Largo'
					@nlin,07 psay 'T.Largo'
				else  
					//@nlin,15 psay 'T.Estr.'
					@nlin,07 psay 'T.Estr.'
				endif
			endif

			//@nlin,23 psay TMP->CLASSIF
			@nlin,15 psay TMP->CLASSIF
			//@nlin,27 psay transform(TMP->PESO,'@E 99.99')
			@nlin,19 psay transform(TMP->PESO,'@E 99.99')
			//@nlin,33 psay TMP->PROGRAMA
			@nlin,25 psay  SUBSTR(fBuscaCPO('SZ6',1,xfilial('SZ6')+TMP->PROGRAMA,'Z6_DESC'),1,11)
			@nlin,37 psay _cDent


			_lCol := 2
		elseif _lCol = 2
			@nlin,43 psay '|'

			@nlin,44 psay TMP->HORA 
			//@nlin,51 psay substr(TMP->IDENTIF,15,6) 

			if TMP->COD = '005020'
				//@nlin,59 psay 'Diant.'
				@nlin,51 psay 'Diant.'
			elseif TMP->COD = '005016'
				if TMP->TPTRASE = 'L'  
					@nlin,51 psay 'T.Largo'
				else  
					@nlin,51 psay 'T.Estr.'
				endif
			endif

			@nlin,59 psay TMP->CLASSIF
			@nlin,63 psay transform(TMP->PESO,'@E 99.99')
			@nlin,69 psay SUBSTR(fBuscaCPO('SZ6',1,xfilial('SZ6')+TMP->PROGRAMA,'Z6_DESC'),1,11)
			@nlin,81 psay _cDent
			_lCol := 3

		elseif _lCol = 3
			@nlin,088 psay '|'
			@nlin,089 psay TMP->HORA 
			//@nlin,096 psay substr(TMP->IDENTIF,15,6) 
			if TMP->COD = '005020'
				@nlin,96 psay 'Diant.'
			elseif TMP->COD = '005016'
				if TMP->TPTRASE = 'L'  
					@nlin,96 psay 'T.Largo'
				else  
					@nlin,96 psay 'T.Estr.'
				endif
			endif

			@nlin,104 psay TMP->CLASSIF
			@nlin,108 psay transform(TMP->PESO,'@E 99.99')
			@nlin,114 psay SUBSTR(fBuscaCPO('SZ6',1,xfilial('SZ6')+TMP->PROGRAMA,'Z6_DESC'),1,11)
			@nlin,126 psay _cDent
			_lCol := 1
			nlin++
		endif

		TMP->(dbSkip()) // Avanca o ponteiro do registro no arquivo 

		_cProc := space(8)

	EndDo    

	nlin += 2

	If nLin > 63 // Salto de Página. Neste caso o formulario tem 75 linhas...
		Cabec(Titulo,Cabec1,Cabec2,NomeProg,Tamanho,nTipo)
		nLin := 9
	Endif   

	@nlin,00 psay replicate('-',132)
	nlin++

	@nlin,05 psay 'Total de Peças Desossadas: ' + transform(_nQuant,'@E 999,999')
	nlin++
	@nlin,05 psay 'Total de Peso Desossado:   ' + transform(_nPeso,'@E 999,999.99')

	if _nQtT <> 0
		nlin++
		@nlin,05 psay 'Total de Traseiros:  ' + transform(_nQtT,'@E 999')
	endif

	if _nQtD <> 0
		nlin++
		@nlin,05 psay 'Total de Dianteiros: ' + transform(_nQtD,'@E 999')
	endif

	//ÚÄn ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
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
