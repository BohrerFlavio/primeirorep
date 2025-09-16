#INCLUDE "rwmake.ch"
#INCLUDE "topconn.ch"

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³MLR38     ºAutor  ³Mauricio Roehrs     º Data ³  09/08/14   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³ Relatorio para conferencia da produção referente           º±±
±±º          ³                                                            º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ AP Qualidade, Pcp                                          º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/


User Function MLR38()
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Declaracao de Variaveis                                             ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ

	Local cDesc1         := "Este programa tem como objetivo imprimir relatorio"
	Local cDesc2         := "para conferencia da produção de caixas com base no"
	Local cDesc3         := "aviso de matança"
	Local cPict          := "vai porra"
	Local titulo         := "RELATORIO PARA CONFERENCIA DE PRODUÇÃO"
	Local Cabec1         := ""
	Local Cabec2         := ""
	Local imprime         := .T.
	Local aOrd            := {}  
	Private nLin           := 80
	Private lEnd          := .F.
	Private lAbortPrint   := .F.
	Private CbTxt         := ""
	Private limite        := 80
	Private tamanho       := "M"
	Private nomeprog      := "MLR38" // Coloque aqui o nome do programa para impressao no cabecalho
	Private nTipo         := 18                                                                     
	Private aReturn       := { "Zebrado", 1, "Administracao", 2, 2, 1, "", 1}
	Private nLastKey      := 0
	Private cPerg   	  := "MLR38"
	Private cbtxt      	:= Space(10)
	Private cbcont     := 00
	Private CONTFL     := 01
	Private m_pag      := 01
	Private wnrel      := "MLR38" // Coloque aqui o nome do arquivo usado para impressao em disco    
	Private _aBatidas  := {}
	pergunte(cPerg,.F.)


	wnrel := SetPrint('SZ2',NomeProg,cPerg,@titulo,cDesc1,cDesc2,cDesc3,.T.,aOrd,.T.,Tamanho,,.T.)  


	_cQuery := " SELECT Z2_NUMAM,Z2_CLASSIF,Z2_DTPROD, Z8_CONTROL, Z8_COD, Z8_DESCRI,Z8_LOCAL,Z8_LOCALIZ"
	_cQuery += " FROM  " + retSqlTab('SZ2') + "  ,  " + retSqlTab('SZU') + "  ,  " + retSqlTab('SZ8')
	_cQuery += " WHERE " + retSqlFil('SZ2') + " AND " + retSqlFil('SZU') + " AND " + retSqlFil('SZ8')
	_cQuery += " AND Z2_NUMAM = '" + mv_par01 + "' AND Z2_NUM = ZU_PREDES"
	_cQuery += " AND ZU_NUM = Z8_NUMPREV AND Z8_PREDES = Z2_NUM" 
	_cQuery += " AND Z2_DTPROD BETWEEN '" + dtos(mv_par02) + "' AND '" + dtos(mv_par03) + "'" 

	if !empty(mv_par04)
		_cQuery += " AND Z2_CLASSIF = '" + mv_par04 + "'"
	endif  

	_cQuery += " AND   " + retSqlDel('SZ2') + " AND " + retSqlDel('SZU') + " AND " + retSqlDel('SZ8')    

	_cQuery += " GROUP BY Z2_NUMAM, Z2_CLASSIF,Z2_DTPROD, Z8_LOCAL,Z8_LOCALIZ, Z8_COD, Z8_DESCRI, Z8_CONTROL
	_cQuery += " ORDER BY Z2_NUMAM, Z2_CLASSIF, Z2_DTPROD,Z8_LOCAL, Z8_LOCALIZ, Z8_COD, Z8_CONTROL



	_cQuery  := ChangeQuery(_cQuery)

	//	* Mostrar a consulta */
	//@ 116,090 To 416,707 Dialog oDlgMemo Title "Consulta"
	//@ 055,005 Get _cQuery Size 250,080 MEMO Object oMemo
	//Activate Dialog oDlgMemo

	MsgRun("Aguarde... Realizando contagem de registros...",,{||  GeraTMP() })

	If nLastKey == 27
		Return
	Endif

	SetDefault(aReturn,'SP8')

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

	_dDtDes   := ''     
	_cCodProd := ''
	_dDtEmb   := ''  
	_cNumam   := ''   
	_cClassif := ''
	_cRua 	 := ''
	_cPredo   := ''
	_cAndar   := ''
	_cApto	 := ''  
	_cLocal	 := ''
	_nCol     := 13
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

		//se for mercado interno		
		if mv_par05 = 1         
			_cDestino := fBuscaCpo('SB1',1,xFilial('SB1') + TMP->Z8_COD,'B1_DESTINO')
			if _cDestino <> 'MI'	
				TMP->(DbSkip())
				loop   
			endif
		elseif mv_par05 = 2 //se for mercado externo
			_cDestino := fBuscaCpo('SB1',1,xFilial('SB1') + TMP->Z8_COD,'B1_DESTINO')
			if _cDestino <> 'ME'	
				TMP->(DbSkip())
				loop   
			endif	   
		endif

		if _cNumam <> TMP->Z2_NUMAM	
			@nlin,01 psay "Aviso de Matanca: " + TMP->Z2_NUMAM + "  " + "Data de Abate: "
			@nlin,45 psay fBuscaCpo('SZG',1,xFilial('SZG')+TMP->Z2_NUMAM,'ZG_DATA') //data de abate
			nlin++
			_cNumam := TMP->Z2_NUMAM
		endif

		if _cClassif <> TMP->Z2_CLASSIF
			@nlin,03 psay "Classificacao: " + TMP->Z2_CLASSIF
			nlin++
			_cClassif := TMP->Z2_CLASSIF  		    
		endif                          

		//quebra por data de desossa	
		if _dDtDes <> TMP->Z2_DTPROD
			@nlin,05 psay "Data de Desossa: "// + TMP->ZAJ_DATAS
			@nlin,30 psay stod(TMP->Z2_DTPROD)
			nlin++
			_dDtDes := TMP->Z2_DTPROD
		endif			                

		/*	if _dDtEmb <> TMP->Z8_DATAP    
		@nlin,08 psay "Data de Embalagem: " //+ stod(TMP->Z8_DATAP)
		@nlin,30 psay stod(TMP->Z8_DATAP)
		nlin++
		@nlin,01 psay replicate('-',132)
		nlin++   	
		_dDtEmb := TMP->Z8_DATAP		
		endif*/

		if _cLocal <> TMP->Z8_LOCAL
			@nlin,05 psay "Camara: " + TMP->Z8_LOCAL	
			nlin++
			_cLocal := TMP->Z8_LOCAL		  
		endif  

		if _cCodProd <> TMP->Z8_COD   
			@nlin,08 psay alltrim(TMP->Z8_COD) + "   " + TMP->Z8_DESCRI 
			if !empty(TMP->Z8_LOCALIZ)
				@nlin,40 psay "Rua" + "      " + "Predio"+"      "+"Andar"+"      "+"Apto"
				@nlin,95 psay "Rua" + "      " + "Predio"+"      "+"Andar"+"      "+"Apto"		
			endif	
			nlin++
			@nlin,01 psay replicate('-',132)
			nlin++
			_cCodProd := TMP->Z8_COD	
		endif


		_cRua		:= substr(TMP->Z8_LOCALIZ,3,2)		
		_cPredio := substr(TMP->Z8_LOCALIZ,5,2)
		_cAndar  := substr(TMP->Z8_LOCALIZ,7,2)
		_cApto   := substr(TMP->Z8_LOCALIZ,9,2)
		//se a localização não tiver em branco faz duas colunas	
		if !empty(TMP->Z8_LOCALIZ)	   	
			if _nCol = 13 
				@nlin,_nCol psay TMP->Z8_CONTROL
				//@nlin,_nCol+15 psay "Rua: " + _cRua + "  " + " Predio: " + _cPredio + "  " + "Andar: " + _cAndar + "  " + "Apto: " + _cApto	  	    	
				@nlin,_nCol+27 psay  _cRua + "        " + _cPredio + "         " + _cAndar + "         " +  _cApto	  	    	
				_nCol := 80

			elseif _nCol = 80
				@nlin,_nCol psay TMP->Z8_CONTROL   
				//@nlin,_nCol+15 psay "Rua: " + _cRua + "  " + " Predio: " + _cPredio + "  " + "Andar: " + _cAndar + "  " + "Apto: " + _cApto
				@nlin,_nCol+15 psay  _cRua + "        " + _cPredio + "         " + _cAndar + "         " +  _cApto	  	    	
				_nCol := 13      
				nlin++    	
			endif
		else //senão faz quatro colunas
			if _nCol = 13 
				@nlin,_nCol psay TMP->Z8_CONTROL	  	    	
				_nCol := 40

			elseif _nCol = 40
				@nlin,_nCol psay TMP->Z8_CONTROL   
				_nCol := 70      	
			elseif _nCol = 70
				@nlin,_nCol psay TMP->Z8_CONTROL
				_nCol := 105  
			else
				@nlin,_nCol psay TMP->Z8_CONTROL
				_nCol := 13
				nlin++

			endif
		endif	

		TMP->(dbSkip()) // Avanca o ponteiro do registro no arquivo
		if _cLocal <> TMP->Z8_LOCAL
			nlin++
		endif 

		if _cCodProd <> TMP->Z8_COD .or. TMP->(eof())	
			nlin++
			@nlin,01 psay replicate('-',132)				
			nlin++
			_nCol := 13	
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

	//	* Mostrar a consulta */
	//@ 116,090 To 416,707 Dialog oDlgMemo Title "Consulta"
	//@ 055,005 Get _cQuery Size 250,080 MEMO Object oMemo
	//Activate Dialog oDlgMemo

	If Select("TMP") != 0
		TMP->(dbCloseArea())
	Endif

	TCQUERY _cQuery NEW ALIAS "TMP"

return
