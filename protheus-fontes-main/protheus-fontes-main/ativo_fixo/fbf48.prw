#INCLUDE "rwmake.ch"
#INCLUDE "topconn.ch"

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³FBF48   º Autor ³ Flavio Bohrer Flores  º Data ³  31/09/11  º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDescricao ³ Relatório Creditos Pis/COFINS - Depreciação  para   		  º±±
±±º          ³   conferência e lançamentos dos Créditos na Contabilidade  º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ Apoio para conferência no Ativo Fixo                       º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/

User Function FBF48()


	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Declaracao de Variaveis                                             ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ

	Local cDesc1        := "Este programa tem como objetivo imprimir relatorio    "
	Local cDesc2        := "de Resultado da depreciação acumulada "
	Local cDesc3        := ""
	Local cPict         := ""
	Local titulo       	:= "Crédito Pis/Cofins Pós-Depreciação - "
	Local nLin         	:= 80
	Local Cabec1       	:= ""
	Local Cabec2       	:= ""
	Local imprime      	:= .T.
	Local aOrd 			:= {}
	Private lEnd        := .F.
	Private lAbortPrint := .F.
	Private limite      := 80
	Private Tamanho     := "M"
	Private nomeprog    := "FBF48" // Coloque aqui o nome do programa para impressao no cabecalho
	Private nTipo       := 18
	Private aReturn     := { "Zebrado", 1, "Administracao", 2, 2, 1, "", 1}
	Private nLastKey    := 0
	Private cPerg       := "FBF48"
	Private m_pag      	:= 01
	Private wnrel      	:= "FBF48" // Coloque aqui o nome do arquivo usado para impressao em disco    

	pergunte(cPerg,.F.) 

	titulo += "Perído: ** " +DTOC(mv_par01)+" **" 
	wnrel := SetPrint('SN1',NomeProg,cPerg,@titulo,cDesc1,cDesc2,cDesc3,.T.,aOrd,.T.,Tamanho,,.T.)

	if mv_par02 = 1 
		Cabec1       	:= "Conta Contábil"
		Cabec2       	:= "Produto      Item   C.Custo     Descrição                                  Data             Base           Tot. Pis      Tot.Cof	"
	elseif mv_par02 = 2  
		Cabec1       	:= "Conta Contábil"
		Cabec2       	:= "     C. Custo                                                                               Base          Tot. Pis        Tot.Cof	"
	endif

	if mv_par02 = 1

		cQuery := " SELECT 	N4_CBASE AS CODIGO, N4_ITEM AS ITEM,"
		cQuery += "  		   N4_CONTA AS CONTA ,N4_CCUSTO AS CCUSTO,"
		cQuery += "   		   N4_VLROC1 AS VLRMO1 , N1_AQUISIC AS DTAQUI,"
		cQuery += "			   N1_DESCRIC AS DESCRIC "
		cQuery += " FROM  SN1010, SN4010 "
		cQuery += " WHERE SN4010.D_E_L_E_T_ <> '*' AND SN1010.D_E_L_E_T_ <> '*'"
		cQuery += " 	AND N4_FILIAL = '" + xfilial('SN4') + "'  AND N1_FILIAL = '" + xfilial('SN1') + "'"
		cQuery += " 	AND N4_CBASE = N1_CBASE "	
		cQuery += " 	AND N4_ITEM = N1_ITEM "	
		cQuery += " 	AND N4_DATA = '" + dtos(mv_par01) + "' "
		cQuery += " 	AND N4_OCORR = '06' "
		cQuery += " 	AND N4_TIPOCNT = '4' "
		cQuery += " 	AND N1_CALCPIS = '1' "
		cQuery += " 	AND (N1_AQUISIC BETWEEN   '" + dtos(mv_par03) + "' AND '" + dtos(mv_par04) + "' ) "  
		cQuery += " ORDER BY N4_CONTA,N1_AQUISIC, N4_CBASE, N4_ITEM" 

	endif	  

	if mv_par02 = 2

		cQuery := " SELECT N4_CCUSTO AS CCUSTO,sum( N4_VLROC1) AS VLRMO1 "
		cQuery += " FROM  SN1010, SN4010 "
		cQuery += " WHERE SN4010.D_E_L_E_T_ <> '*' AND SN1010.D_E_L_E_T_ <> '*' "
		cQuery += " 	AND N4_FILIAL = '" + xfilial('SN4') + "'  AND N1_FILIAL = '" + xfilial('SN1') + "'    "
		cQuery += " 	AND N4_CBASE = N1_CBASE 	      		"
		cQuery += " 	AND N4_ITEM = N1_ITEM               	"
		cQuery += " 	AND N4_DATA = '" + dtos(mv_par01) + "'	"
		cQuery += " 	AND N4_OCORR = '06'           			"
		cQuery += " 	AND N4_TIPOCNT = '4'             		"
		cQuery += " 	AND N1_CALCPIS = '1'           			"  
		cQuery += " 	AND (N1_AQUISIC BETWEEN   '" + dtos(mv_par03) + "' AND '" + dtos(mv_par04) + "' ) "    
		cQuery += " GROUP BY  N4_CCUSTO     		"  
		cQuery += " ORDER BY  N4_CCUSTO     		"

	endif
	cQuery := ChangeQuery(cQuery)
	//	cQuery += " GROUP BY N4_CONTA, N4_CCUSTO     		"  
	If Select("ATF") != 0
		ATF->(dbCloseArea())
	Endif
	TCQUERY cQuery NEW ALIAS "ATF"  


	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Monta a interface padrao com o usuario...                           ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ

	If nLastKey == 27
		Return
	Endif

	SetDefault(aReturn,'SN1')

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

	Local _nCont 				:= 0
	Local _cDescr				:= " " 
	Local _cContaContabil  	:= " "
	Local _cDConta				:= " "
	Local _cCCusto				:= " " 
	Local _nCPis				:= 0 
	Local _nCof					:= 0 
	Local _nCPisTot			:= 0
	Local _nCofTot          := 0 
	Local _nBase 				:= 0
	Local _nVlCredPis			:= 0
	Local _nVCPis           := 0
	Local _nVCCOF           := 0
	Local _nVlCredCof	    	:= 0
	Local _nVlrTot1         := 0
	Local _nBase            := 0
	Local _cCCUSTO          :=	""
	Local _cDescriCC        :=	""     
	Local _nVg1    			:= 0
	Local _nVg2					:= 0
	Local _nVg3					:= 0
	Local _nVlro1				:= 0

	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ SETREGUA -> Indica quantos registros serao processados para a regua ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ

	ATF->(SetRegua(RecCount()))

	ATF->(dbGoTop())
	_cCCUSTO := ATF->CCUSTO 
	While ATF->(!EOF())

		incregua()

		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³ Verifica o cancelamento pelo usuario...                             ³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		if nLin > 70
			Cabec(Titulo,Cabec1,Cabec2,NomeProg,Tamanho,nTipo)
			nLin := 9
		endif

		If lAbortPrint
			@nLin,00 PSAY "*** CANCELADO PELO OPERADOR ***"
			Exit
		Endif              

		if ATF->VLRMO1 = 0 // se bem zerado não mostrar
			ATF->(DbSkip())
			loop	    	    	
		endif

		if mv_par02 = 2  .AND. _nVCPis > 0  		
			_cDescriCC := fBuscaCPO('CTT',1,xfilial('CTT') + _cCCUSTO,'CTT_DESC01')
			if nLin > 70
				Cabec(Titulo,Cabec1,Cabec2,NomeProg,Tamanho,nTipo)
				nLin := 9
			endif
			@nlin,05  psay _cCCUSTO
			@nlin,25  psay _cDescriCC
			@nlin,83  psay transform(_nBase,'@E 999,999,999.99')
			@nlin,98  psay transform(_nVCPis,'@E 999,999,999.99')
			@nlin,115 psay transform(_nVCCOF , '@E 999,999,999.99')
			_cCCUSTO  	:= ATF->CCUSTO
			_nVg1		:=	_nVg1 + _nBase
			_nVg2 		:=	_nVg2 + _nVCPis
			_nVg3 		:=	_nVg3 +_nVCCOF
			_nBase   	:= 0
			_nVCPis		:= 0
			_nVCCOF 	:= 0
			nLin++
		endif	

		if mv_par02 = 1 
			if _cContaContabil != ATF->CONTA        	
				if  _nCof > 0 .AND.	_nCPis > 0
					nLin++      // Total por conta
					if nLin > 70
						Cabec(Titulo,Cabec1,Cabec2,NomeProg,Tamanho,nTipo)
						nLin := 9
					endif
					@nLin,60  psay "Total PIS/COF : "
					@nLin,83  psay transform(_nVlro1,'@E 999,999,999.99')
					@nLin,98  psay transform(_nCPis,'@E 999,999,999.99')
					@nLin,115  psay transform(_nCof,'@E 999,999,999.99')   

					_nVlrTot1	:=	_nVlrTot1 + _nVlro1
					_nCPisTot 	:=	_nCPisTot + _nCPis
					_nCofTot 	:=	_nCofTot  + _nCof
					_nVlro1		:= 	0
					_nCPis 		:=	0
					_nCof 		:=	0
					nLin++
				endif
				_cDConta := fBuscaCPO('CT1',1,xfilial('CT1') +ATF->CONTA,'CT1_DESC01')
				@nlin,01  psay Alltrim(ATF->CONTA) 
				@nlin,18  psay Alltrim(_cDConta)
				_cContaContabil := ATF->CONTA
				nLin++     
				nLin++ 

			endif
			if nLin > 70
				Cabec(Titulo,Cabec1,Cabec2,NomeProg,Tamanho,nTipo)
				nLin := 9
			endif

			@nLin,01 psay ATF->CODIGO
			@nLin,12 psay ATF->ITEM
			@nLin,18 psay ATF->CCUSTO
			@nLin,30 psay SUBSTR(ATF->DESCRIC,1,40)   
			@nLin,73 psay STOD(ATF->DTAQUI)
			@nLin,83 psay transform(ATF->VLRMO1,'@E 999,999,999.99')
			@nLin,98 psay transform(((ATF->VLRMO1*1.65)/100),'@E 999,999,999.99')
			@nLin,115 psay transform(((ATF->VLRMO1*7.6)/100), '@E 999,999,999.99')
			_nVlro1 := 	_nVlro1+ ATF->VLRMO1
			_nCPis	:=	_nCPis + ((ATF->VLRMO1*1.65)/100)
			_nCof	:=	_nCof  + ((ATF->VLRMO1*7.6)/100)
			nLin++         

		endif


		if  mv_par02 = 2 	  		

			if _cCCUSTO != ATF->CCUSTO 
				_cDescriCC := fBuscaCPO('CTT',1,xfilial('CTT') + _cCCUSTO,'CTT_DESC01')
				@nlin,05  psay _cCCUSTO
				@nlin,25  psay _cDescriCC
				@nlin,83  psay transform(_nBase,'@E 999,999,999.99')
				@nlin,98  psay transform(_nVCPis,'@E 999,999,999.99')
				@nlin,115 psay transform(_nVCCOF , '@E 999,999,999.99')
				_cCCUSTO  	:= ATF->CCUSTO 
				_nVg1		:=	_nVg1 + _nBase
				_nVg2 		:=	_nVg2 + _nVCPis
				_nVg3 		:=	_nVg3 +_nVCCOF
				_nBase   	:= ATF->VLRMO1
				_nVCPis		:= ((ATF->VLRMO1*1.65)/100)
				_nVCCOF 	:= ((ATF->VLRMO1*7.6)/100)			
				nLin++                             

			elseif _cCCUSTO = ATF->CCUSTO        // soma os resiltados 

				_nBase 		:= _nBase  + ATF->VLRMO1
				_nVCPis		:= _nVCPis + ((ATF->VLRMO1*1.65)/100)
				_nVCCOF 	:= _nVCCOF + ((ATF->VLRMO1*7.6)/100) 

			endif

		endif


		ATF->(dbSkip()) // Avanca o ponteiro do registro no arquivo


	EndDo
	if  mv_par02 = 1
		nLin++
		if nLin > 70
			Cabec(Titulo,Cabec1,Cabec2,NomeProg,Tamanho,nTipo)
			nLin := 9
		endif
		@nlin,60   psay "Total PIS/COF: " 
		@nlin,83   psay transform(_nVlro1,'@E 999,999,999.99') 
		@nlin,98   psay transform(_nCPis,'@E 999,999,999.99') 
		@nlin,115  psay transform(_nCof, '@E 999,999,999.99')
		_nVlrTot1	:= 	_nVlrTot1 + _nVlro1
		_nCPisTot 	:=	_nCPisTot + _nCPis   
		_nCofTot 	:=	_nCofTot  + _nCof   

		nLin++ 
		nLin++
		nLin++ 
		if nLin > 70
			Cabec(Titulo,Cabec1,Cabec2,NomeProg,Tamanho,nTipo)
			nLin := 9
		endif
		@nlin,60   psay "Saldo Total PIS/COF: "
		@nlin,83   psay transform(_nVlrTot1,'@E 999,999,999.99') 
		@nlin,98   psay transform(_nCPisTot,'@E 999,999,999.99') 
		@nlin,115  psay transform(_nCofTot, '@E 999,999,999.99')
	endif  
	if mv_par02 = 2
		if nLin > 70
			Cabec(Titulo,Cabec1,Cabec2,NomeProg,Tamanho,nTipo)
			nLin := 9
		endif
		_cDescriCC := fBuscaCPO('CTT',1,xfilial('CTT') + _cCCUSTO,'CTT_DESC01') 
		@nlin,05  psay _cCCUSTO
		@nlin,25  psay _cDescriCC
		@nlin,83  psay transform(_nBase,'@E 999,999,999.99')
		@nlin,98  psay transform(_nVCPis,'@E 999,999,999.99')
		@nlin,115 psay transform(_nVCCOF , '@E 999,999,999.99')
		nLin++          
		nLin++   
		nLin++
		_nVg1	:=	_nVg1 + _nBase
		_nVg2 	:=	_nVg2 + _nVCPis
		_nVg3 	:=	_nVg3 +_nVCCOF
		if nLin > 70
			Cabec(Titulo,Cabec1,Cabec2,NomeProg,Tamanho,nTipo)
			nLin := 9
		endif
		@nlin,20   psay "Saldo Total PIS/COF: "
		@nlin,83   psay transform(_nVg1,'@E 999,999,999.99') 
		@nlin,98   psay transform(_nVg2,'@E 999,999,999.99') 
		@nlin,115  psay transform(_nVg3, '@E 999,999,999.99')
	endif
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Finaliza a execucao do relatorio...                                 ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ


	DbCloseArea('ATF')



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
